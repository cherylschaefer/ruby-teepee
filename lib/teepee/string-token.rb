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

require 'teepee/token'

module Teepee
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
end
