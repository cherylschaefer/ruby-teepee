# -*- coding: utf-8 -*-
# -*- mode: Ruby -*-

# Copyright © 2013-2015, Christopher Mark Gore,
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
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#   * Neither the name of Christopher Mark Gore nor the names of other
#     contributors may be used to endorse or promote products derived from
#     this software without specific prior written permission.
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

require 'teepee/constants'
require 'teepee/errors'
require 'teepee/parser-node'
require 'teepee/token'
require 'teepee/commander'
require 'teepee/actionable-commander'
require 'teepee/single-character-token'
require 'teepee/string-token'

include ERB::Util

module Teepee
  class NumberToken < Token
    attr_reader :number, :text

    def initialize(text)
      raise ArgumentError if not text.is_a? String
      @text = text
    end

    def parse
    end

    def to_s
      number.to_s
    end

    def to_html
      to_s
    end

    class << self
      def matches? text
      end
    end
  end

  ###############################################################################

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
           result =        NumberToken.matches?(rest) or
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

  ###############################################################################

  class CommandParser < ParserNode
    attr_reader :command, :expressions

    def initialize(command, expressions)
      raise ArgumentError if not command.is_a? WordToken
      @command = command
      raise ArgumentError if not expressions.is_a? Array
      expressions.each do |expression|
        raise ArgumentError if not expression.kind_of? ParserNode
      end
      @expressions = expressions
    end

    def command_error(message)
      %{<span style="color: red">[#{message}]</span>}
    end

    def to_html
      case command.word
      when "backslash", "bslash"
        @@commander.backslash
      when "left-brace",
           "left_brace",
           "leftbrace",
           "lbrace",
           "opening-brace",
           "opening_brace",
           "openingbrace",
           "obrace"
        @@commander.left_brace
      when "right-brace",
           "right_brace",
           "rightbrace",
           "rbrace",
           "closing-brace",
           "closing_brace",
           "closingbrace",
           "cbrace"
        @@commander.right_brace
      when "br", "newline"
        @@commander.br
      when "bold", "b", "textbf"
        @@commander.b expressions
      when "del",
           "s",
           "strike",
           "strikethrough",
           "strikeout"
        @@commander.del expressions
      when "i"
        @@commander.i
      when "italic",
           "textit",
           "it"
        @@commander.it expressions
      when "underline",
           "u"
        @@commander.u expressions
      when "tt",
           "texttt",
           "teletype",
           "typewriter"
        @@commander.tt expressions
      when "small"
        @@commander.small expressions
      when "big"
        @@commander.big expressions
      when "subscript",
           "sub"
        @@commander.sub expressions
      when "superscript",
           "sup"
        @@commander.sup expressions
      when "user",
           "user-id",
           "user_id"
        @@commander.user first_word_token
      when "link-id",
           "link_id"
        @@commander.link_id first_word_token
      when "keyword-id",
           "keyword_id"
        @@commander.keyword_id first_word_token
      when "tag-id",
           "tag_id"
        @@commander.tag_id first_word_token
      when "forum-id",
           "forum_id"
        @@commander.forum_id first_word_token
      when "folder-id",
           "folder_id"
        @@commander.folder_id first_word_token
      when "bookmarks-folder-id",
           "bookmarks_folder_id",
           "bookmarks_folder-id",
           "bookmarks-folder_id",
           "bookmark-folder-id",
           "bookmark_folder_id",
           "bookmark_folder-id",
           "bookmark-folder_id"
        @@commander.bookmarks_folder_id first_word_token
      when "pi"
        @@commander.pi
      when "e"
        @@commander.e
      when "+"
        @@commander.+ *numbers_from_expressions
      when "-"
        @@commander.- *numbers_from_expressions
      when "*"
        @@commander.* *numbers_from_expressions
      when "/"
        @@commander./ *numbers_from_expressions
      when "%"
        @@commander.% *numbers_from_expressions
      when "^", "**"
        @@commander.** *numbers_from_expressions
      when "sin", "cos", "tan",
        "asin", "acos", "atan",
        "sinh", "cosh", "tanh",
        "asinh", "acosh", "atanh",
        "erf", "erfc",
        "gamma", "log10", "sqrt"
        @@commander.send command.word.to_sym, number_from_expression
      when "d2r",
           "deg->rad",
           "degrees->radians"
        @@commander.degrees2radians number_from_expression
      when "r2d",
           "rad->deg",
           "radians->degrees"
        @@commander.radians2degrees number_from_expression
      when "lgamma"
        @@commander.lgamma number_from_expression
      when "ld",
           "log2"
        @@commander.ld number_from_expression
      when "ln"
        @@commander.ln number_from_expression
      when "log"
        base, number = numbers_from_expressions
        @@commander.log base, number
      when "ldexp"
        fraction, exponent = numbers_from_expressions
        @@commander.ldexp fraction, exponent
      when "hypot"
        @@commander.hypot numbers_from_expressions
      else
        command_error "unknown command #{command.to_html}"
      end
    end

    def html_tag(tag)
      "<#{tag}>" + expressions.map(&:to_html).join + "</#{tag}>"
    end

    def tb_href(target, string)
      %{<a href="#{TB_COM}/#{target}">#{string}</a>}
    end

    def first_word_token
      expressions.select {|expr| expr.is_a? WordToken}.first
    end

    def numbers_from_expressions
      expressions
        .map do |number|
          begin
            Float(number.to_html)
          rescue ArgumentError
            nil
          end
        end.reject &:nil?
    end

    def number_from_expression
      numbers_from_expressions.first
    end

    class << self
      @@commander = Commander.new
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

      def commander= new
        @@commander = new
      end
    end
  end

  ###############################################################################

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

  ###############################################################################

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
