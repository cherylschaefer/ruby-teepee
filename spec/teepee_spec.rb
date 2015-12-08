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

require 'spec_helper'

require 'teepee'

TWO_PARAGRAPHS_BEFORE =
"Line 1
Line 2

Line 3
Line 4"

TWO_PARAGRAPHS_AFTER =
  "<p>
Line 1 Line 2
</p>

<p>
Line 3 Line 4
</p>
"

TWO_LINE_BOLD_BEFORE =
"Line 1
\\b{Line 2
Line 3}
Line 4"

TWO_LINE_BOLD_AFTER =
  "<p>
Line 1 <b>Line 2 Line 3</b> Line 4
</p>
"

def para(string)
  "<p>\n#{string}\n</p>\n"
end

describe Teepee::Parser do
  it "can be instantiated" do
    expect(Teepee::Parser.new(""))
      .to be_a Teepee::Parser
  end

  describe :to_html do
    it "can correctly parse a single word" do
      expect(Teepee::Parser.new("Word").to_html)
            .== para("Word")
    end

    it "can correctly parse a single non-english word" do
      expect(Teepee::Parser.new("Λόγος").to_html)
            .== para("Λόγος")
    end

    it "escapes < and >" do
      expect(Teepee::Parser.new("<b>not bold</b>").to_html)
            .== para("&lt;b&gt;not bold&lt;/b&gt;")
    end

    it "escapes &" do
      expect(Teepee::Parser.new("not &lt; less-than").to_html)
            .== para("not &amp;lt; less-than")
    end

    it "can correctly split paragraphs" do
      expect(Teepee::Parser.new(TWO_PARAGRAPHS_BEFORE).to_html)
            .== TWO_PARAGRAPHS_AFTER
    end

    it "can correctly handle bold" do
      expect(Teepee::Parser.new("Soli \\b{Deo} Gloria").to_html)
            .== para("Soli <b>Deo</b> Gloria")
    end

    it "can correctly handle italics" do
      expect(Teepee::Parser.new("Soli \\it{Deo} Gloria").to_html)
            .== para("Soli <i>Deo</i> Gloria")
    end

    it "can correctly handle subscripts" do
      expect(Teepee::Parser.new("Soli \\sub{Deo} Gloria").to_html)
            .== para("Soli <sub>Deo</sub> Gloria")
    end

    it "can correctly handle superscripts" do
      expect(Teepee::Parser.new("Soli \\sup{Deo} Gloria").to_html)
            .== para("Soli <sup>Deo</sup> Gloria")
    end

    it "can correctly handle a command around the entire input" do
      expect(Teepee::Parser.new("\\b{Soli Deo Gloria}").to_html)
            .== para("<b>Soli Deo Gloria</b>")
    end

    it "can correctly handle two commands in a row" do
      expect(Teepee::Parser.new("Soli \\b{Deo} \\it{Gloria}").to_html)
            .== para("Soli <b>Deo</b> <i>Gloria</i>")
    end

    it "can correctly handle nested commands" do
      expect(Teepee::Parser.new("Soli \\b{\\it{Deo}} Gloria").to_html)
            .== para("Soli <b><i>Deo</i></b> Gloria")
    end

    it "can correctly handle three-deep nested commands" do
      expect(Teepee::Parser.new("Soli \\sup{\\b{\\it{Deo}}} Gloria").to_html)
            .== para("Soli <sup><b><i>Deo</i></b></sup> Gloria")
    end

    it "can correctly handle commands split over multiple lines" do
      expect(Teepee::Parser.new(TWO_LINE_BOLD_BEFORE).to_html)
            .== TWO_LINE_BOLD_AFTER
    end

    describe :addition do
      it "works with multiple arguments" do
        expect(Teepee::Parser.new("\\+{1 2 3 4}").to_html)
          .== para("10.0")
      end

      it "works with a single argument" do
        expect(Teepee::Parser.new("\\+{123}").to_html)
          .== para("123.0")
      end
    end

    describe :subtraction do
      it "works with multiple arguments" do
        expect(Teepee::Parser.new("\\-{10 40}").to_html)
              .== para("-30.0")
      end

      it "works with a single argument" do
        expect(Teepee::Parser.new("\\-{123}").to_html)
          .== para("-123.0")
      end
    end

    describe :multiplication do
      it "works with multiple arguments" do
        expect(Teepee::Parser.new("\\*{10 -4.7}").to_html)
              .== para("-47.0")
      end

      it "works with a single argument" do
        expect(Teepee::Parser.new("\\*{123}").to_html)
              .== para("123.0")
      end
    end

    describe :division do
      it "works with multiple arguments" do
        expect(Teepee::Parser.new("\\/{100 10 2}").to_html)
              .== para("5.0")
      end

      it "works with a single argument" do
        expect(Teepee::Parser.new("\\/{10}").to_html)
              .== para("0.1")
      end
    end

    it "can nest mathematics" do
      expect(Teepee::Parser.new("\\+{10 \\*{3 5} \\-{\\+{4 5} 2}").to_html)
            .== para("32.0")
    end

    it "can calculate some trigonometry" do
      expect(Teepee::Parser.new("\\sin{0}").to_html)
            .== para("0.0")
      expect(Teepee::Parser.new("\\cos{\\pi}").to_html)
            .== para("-1.0")
    end
  end

  describe "degrees->radians" do
    it "converts degrees to radians" do
      expect(Teepee::Parser.new("\\d2r{0}").to_html)
            .== para("0.0")
      expect(Teepee::Parser.new("\\deg->rad{0}").to_html)
            .== para("0.0")
      expect(Teepee::Parser.new("\\degrees->radians{0}").to_html)
            .== para("0.0")
      expect(Teepee::Parser.new("\\d2r{180.0}").to_html)
            .== para(Math::PI.to_s)
    end
  end

  describe "radians->degrees" do
    it "converts radians to degrees" do
      expect(Teepee::Parser.new("\\r2d{0}").to_html)
            .== para("0.0")
      expect(Teepee::Parser.new("\\rad->deg{0}").to_html)
            .== para("0.0")
      expect(Teepee::Parser.new("\\radians->degrees{0}").to_html)
            .== para("0.0")
      expect(Teepee::Parser.new("\\r2d{"+Math::PI.to_s+"}").to_html)
            .== para("180.0")
    end
  end
end