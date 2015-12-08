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
require 'teepee/number-token'
require 'teepee/tokenizer'
require 'teepee/command-parser'

include ERB::Util

module Teepee
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
