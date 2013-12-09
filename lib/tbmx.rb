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

include ERB::Util

module TBMX
  class Token
    class << self
      # The child classes should implement this method.  If there is an
      # immediate match, they should return a newly-created instance of
      # themselves and the rest of the input as a string.  If there is no match,
      # they should return nil.
      def parse? text
        raise NotImplementedError,
              "Child class #{self.class} should implement this."
      end
    end
  end

  class SingleCharacterToken < Token
    class << self
      def character_matched
        self::CHARACTER_MATCHED
      end

      def parse? text
        if text[0] == character_matched
          return [self.new, text[1..-1]]
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

      def parse? text
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
  end

  class WordToken < StringToken
    FULL_MATCH_REGEX = /\A[^\s{}\\]+\z/
    FRONT_MATCH_REGEX = /[^\s{}\\]+/
    COUNT_REGEX = /[\s{}\\]/

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
      rest = text
      while rest.length > 0
        if result = BackslashToken.parse?(rest)     or
           result = LeftBraceToken.parse?(rest)     or
           result = RightBraceToken.parse?(rest)    or
           result = EmptyNewlinesToken.parse?(rest) or
           result = WhitespaceToken.parse?(rest)    or
           result = WordToken.parse?(rest)
        then
          @tokens << result[0]
          rest = result[1]
        else
          raise RuntimeError, "couldn't parse remaining."
        end
      end
      return @tokens
    end
  end

  class HTML
    attr_reader :text, :lines, :paragraphs

    def initialize(text)
      raise ArgumentError if not text.is_a? String
      @text = text
      @lines = text.split("\n").map &:strip
      @paragraphs = @lines.split ""
    end

    def evaluate_command(command, input)
      case command
      when "\\"
        "\\ #{input}"
      when "b"
        "<b>#{input}</b>"
      when "i"
        "<i>#{input}</i>"
      when "lbrace"
        "{"
      when "rbrace"
        "}"
      when "sub"
        "<sub>#{input}</sub>"
      when "sup"
        "<sup>#{input}</sup>"
      else
        "<b>[UNKNOWN COMMAND --- '#{command}']</b>"
      end
    end

    def parse_command(command, rest)
      if rest == nil or rest == ""
        return [evaluate_command(command, rest),
                ""]
      elsif rest[0] =~ /\s/
        return [evaluate_command(command, ""),
                rest[1 .. -1]]
      elsif rest[0] == "{"
        if backslash = rest.index("\\")
          if (closing_brace = rest.index("}")) < backslash
            return [evaluate_command(command, rest[1 ... closing_brace]),
                                              rest[      closing_brace+1 .. -1]]
          elsif closing_brace
            interior = parse_command_body(backslash, rest)
            if new_closing_brace = interior.index("}")
              return [evaluate_command(command,
                                       interior[1 ... new_closing_brace]),
                                       interior[      new_closing_brace+1 .. -1]]
            else # Assume an implied closing brace.
              return [evaluate_command(command, interior[1 .. -1]),
                      ""]
            end
          else
            return evaluate_command(command, parse_command_body(backslash, rest))
          end
        elsif closing_brace = rest.index("}")
          return [evaluate_command(command, rest[1 ... closing_brace]),
                                            rest[      closing_brace+1 .. -1]]
        else # Assume an implied closing brace.
          return [evaluate_command(command, rest[1 .. -1]),
                  ""]
        end
      else
        raise RuntimeError, "Unreachable: probably a bug in parse_command_name."
      end
    end

    def parse_command_name(input)
      if end_command = input.index(/[\{\s]/)
        return [input[0 ... end_command],
                input[      end_command .. -1]]
      else
        return [input, ""]
      end
    end

    def parse_command_body(backslash, input)
      before = input[0 ... backslash]
      command, rest = parse_command_name input[backslash+1 .. -1]
      middle, back = parse_command(command, rest)
      return before + middle + parse_paragraph_body(back)
    end

    def parse_paragraph_body(body)
      return "" if body.nil? or body == ""
      raise ArgumentError, "Body is #{body.class}" if not body.is_a? String
      if backslash = body.index("\\")
        return parse_command_body backslash, body
      else
        return body
      end
    end

    def parse_paragraph(paragraph)
      raise ArgumentError if not paragraph.is_a? Array
      paragraph.each {|line| raise ArgumentError if not line.is_a? String}
      body = paragraph.map do |line|
        html_escape line
      end.join "\n"
      "<p>#{parse_paragraph_body body}</p>"
    end

    def parse
      paragraphs.map {|paragraph| parse_paragraph paragraph}.join "\n\n"
    end
  end
end
