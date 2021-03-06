# -*- coding: utf-8 -*-
# -*- mode: Ruby -*-

# Copyright © 2013-2016, Christopher Mark Gore,
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

require 'teepee/token'
require 'teepee/single-character-token'
require 'teepee/string-token'
require 'teepee/number-token'

module Teepee
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
           result =   LeftBracketToken.matches?(rest) or
           result =          PipeToken.matches?(rest) or
           result =    RightBraceToken.matches?(rest) or
           result =  RightBracketToken.matches?(rest) or
           result =     BackquoteToken.matches?(rest) or
           result =      SquiggleToken.matches?(rest) or
           result =        DollarToken.matches?(rest) or
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
end
