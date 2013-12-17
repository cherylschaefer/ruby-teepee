# -*- coding: utf-8 -*-
# -*- mode: Ruby -*-

# Copyright © 2013, Christopher Mark Gore,
# Soli Deo Gloria,
# All rights reserved.
#
# 2317 South River Road, Saint Charles, Missouri 63303 USA.
# Web: http://cgore.com
# Email: cgore@cgore.com
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# * Neither the name of Christopher Mark Gore nor the names of other
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'active_support/all'
require 'monkey-patch'

include ERB::Util

module TBMX
  class ParseError < RuntimeError
  end

  class ParserNode
  end

  class Token < ParserNode
    class << self
      # The child classes should implement this method.  If there is an
      # immediate match, they should return a newly-created instance of
      # themselves and the rest of the input as a string.  If there is no match,
      # they should return nil.
      def matches? text
        raise NotImplementedError,
              "Child class #{self.class} should implement this."
      end
    end
  end

  class SingleCharacterToken < Token
    def text
      self.class.character_matched
    end

    class << self
      def character_matched
        self::CHARACTER_MATCHED
      end

      def matches? text
        if text.first == character_matched
          return [self.new, text.rest]
        else
          return nil
        end
      end
    end
  end

  class StringToken < Token
    attr_reader :text

    def initialize(text)
      raise ArgumentError if not text.is_a? String
      raise ArgumentError if not text =~ self.class.full_match_regex
      @text = text
    end

    def to_s
      @text
    end

    def to_html
      @text
    end

    class << self
      def full_match_regex
        self::FULL_MATCH_REGEX # Define this in a child class.
      end

      def front_match_regex
        self::FRONT_MATCH_REGEX # Define this in a child class.
      end

      def count_regex
        self::COUNT_REGEX # Define this in a child class.
      end

      def matches? text
        if text =~ front_match_regex
          count = text.index count_regex
          if count.nil?
            return [self.new(text), ""]
          else
            return [self.new(text[0 ... count]), text[count .. -1]]
          end
        else
          return nil
        end
      end
    end
  end

  class BackslashToken < SingleCharacterToken
    CHARACTER_MATCHED = "\\"
  end

  class LeftBraceToken < SingleCharacterToken
    CHARACTER_MATCHED = "{"
  end

  class RightBraceToken < SingleCharacterToken
    CHARACTER_MATCHED = "}"
  end


  class EmptyNewlinesToken < StringToken
    FULL_MATCH_REGEX = /\A\n\n+\z/
    FRONT_MATCH_REGEX = /\A\n\n+/
    COUNT_REGEX = /[^\n]/

    def newlines
      text
    end
  end

  class WhitespaceToken < StringToken
    FULL_MATCH_REGEX = /\A\s+\z/
    FRONT_MATCH_REGEX = /\A\s+/
    COUNT_REGEX = /\S/

    def whitespace
      text
    end

    def to_html
      " " # Replace all whitespace tokens with a single space.
    end
  end

  class WordToken < StringToken
    FULL_MATCH_REGEX = /\A[^\s{}\\]+\z/
    FRONT_MATCH_REGEX = /[^\s{}\\]+/
    COUNT_REGEX = /[\s{}\\]/

    def to_html
      html_escape text
    end

    def word
      text
    end
  end

  class Tokenizer
    attr_reader :text, :tokens
    def initialize(text)
      @text = text
      tokenize
    end

    def tokenize
      @tokens = []
      rest = text.gsub("\r", "")
      while rest.length > 0
        if result =     BackslashToken.matches?(rest) or # Single Character Tokens
           result =     LeftBraceToken.matches?(rest) or
           result =    RightBraceToken.matches?(rest) or
           result = EmptyNewlinesToken.matches?(rest) or # String Tokens
           result =    WhitespaceToken.matches?(rest) or
           result =          WordToken.matches?(rest)
        then
          @tokens << result[0]
          rest = result[1]
        else
          raise RuntimeError, "Couldn't tokenize the remaining text."
        end
      end
      return @tokens
    end
  end

  class CommandParser < ParserNode
    attr_reader :command, :expressions

    def initialize(command, expressions)
      raise ArgumentError if not command.is_a? WordToken
      @command = command
      raise ArgumentError if not expressions.is_a? Array
      expressions.each {|expression| raise ArgumentError if not expression.kind_of? ParserNode}
      @expressions = expressions
    end

    def command_error(message)
      %{<span style="color: red">[#{message}]</span>}
    end

    def to_html
      case command.word
      when "backslash", "bslash"
        "\\"
      when "left-brace", "left_brace", "leftbrace", "lbrace"
        "{"
      when "right-brace", "right_brace", "rightbrace", "rbrace"
        "}"
      when "br", "newline"
        "\n</br>\n"
      when "bold", "b", "textbf"
        "<b>" + expressions.map(&:to_html).join + "</b>"
      when "italic", "i", "textit"
        "<i>" + expressions.map(&:to_html).join + "</i>"
      when "underline", "u"
        "<u>" + expressions.map(&:to_html).join + "</u>"
      when "subscript", "sub"
        "<sub>" + expressions.map(&:to_html).join + "</sub>"
      when "superscript", "sup"
        "<sup>" + expressions.map(&:to_html).join + "</sup>"
      when "user"
        user_command_handler
      else
        command_error "unknown command #{command.to_html}"
      end
    end

    def user_command_handler
      user = expressions.select {|expr| expr.is_a? WordToken}.first
      if not user
        command_error "NO USER SPECIFIED"
      else
        if @@action_view.kind_of? ActionView::Base
          the_user = User.smart_find user.to_s
          if the_user
            @@action_view.render partial: 'users/name_link',
                                 locals: {the_user: the_user}
          else
            command_error "unknown user #{user.to_s}"
          end
        else
          %{<a href="http://thinkingbicycle.com/users/#{user}">#{user.to_s}</a>}
        end
      end
    end


    class << self
      @@action_view = nil
      @@controller = nil

      def parse(tokens)
        expressions = []
        rest = tokens
        backslash, command, left_brace = rest.shift(3)
        right_brace = nil
        raise ParseError if not backslash.is_a? BackslashToken
        raise ParseError if not command.is_a? WordToken
        if not left_brace.is_a? LeftBraceToken # A command with no interior.
          rest.unshift left_brace if not left_brace.is_a? WhitespaceToken
          return [CommandParser.new(command, []), rest]
        end
        while rest.length > 0
          if rest.first.is_a? WordToken
            expressions << rest.shift
          elsif rest.first.is_a? WhitespaceToken
            expressions << rest.shift
          elsif rest.first.is_a? BackslashToken
            result, rest = CommandParser.parse(rest)
            expressions << result
          elsif rest.first.is_a? RightBraceToken
            right_brace = rest.shift
            return [CommandParser.new(command, expressions), rest]
          else
            raise ParseError
          end
        end
        if right_brace.nil? # Allow a forgotten final right brace.
          return [CommandParser.new(command, expressions), rest]
        end
      end

      def action_view=(new)
        @@action_view = new
      end

      def controller=(new)
        @@controller = new
      end
    end
  end

  class ParagraphParser < ParserNode
    attr_reader :expressions, :tokens

    def initialize(tokens)
      raise ArgumentError if not tokens.is_a? Array
      tokens.each {|token| raise ArgumentError if not token.kind_of? ParserNode}
      @tokens = tokens
      parse
    end

    def parse
      @expressions = []
      rest = tokens
      while rest.length > 0
        if rest.first.is_a? WordToken
          @expressions << rest.shift
        elsif rest.first.is_a? WhitespaceToken
          @expressions << rest.shift
        elsif rest.first.is_a? BackslashToken
          command, rest = CommandParser.parse(rest)
          @expressions << command
        else
          return self
        end
      end
    end

    def to_html
      "<p>\n" + expressions.map(&:to_html).join + "\n</p>\n"
    end
  end

  class Parser < ParserNode
    attr_reader :paragraphs, :split_tokens, :text, :tokenizer

    def tokens
      tokenizer.tokens
    end

    def initialize(text)
      @text = text
      @tokenizer = Tokenizer.new text
      parse
    end

    def parse
      @split_tokens = tokens.split {|token| token.class == EmptyNewlinesToken}
      @paragraphs = @split_tokens.map {|split_tokens| ParagraphParser.new split_tokens}
    end

    def to_html
      paragraphs.map(&:to_html).join "\n"
    end
  end
end
