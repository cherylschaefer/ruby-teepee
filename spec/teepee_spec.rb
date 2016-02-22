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

def parse(string)
  Teepee::Parser.new(string).to_html
end

describe Teepee::Parser do
  it "can be instantiated" do
    expect(Teepee::Parser.new(""))
      .to be_a Teepee::Parser
  end

  describe "basic parsing tests" do
    it "can correctly parse a single word" do
      expect(parse("Word"))
            .== para("Word")
    end

    it "can correctly parse a single non-english word" do
      expect(parse("Λόγος"))
            .== para("Λόγος")
    end

    it "escapes < and >" do
      expect(parse("<b>not bold</b>"))
            .== para("&lt;b&gt;not bold&lt;/b&gt;")
    end

    it "escapes &" do
      expect(parse("not &lt; less-than"))
            .== para("not &amp;lt; less-than")
    end

    it "can correctly split paragraphs" do
      expect(parse(TWO_PARAGRAPHS_BEFORE))
            .== TWO_PARAGRAPHS_AFTER
    end

    it "can correctly handle a command around the entire input" do
      expect(parse("\\b{Soli Deo Gloria}"))
            .== para("<b>Soli Deo Gloria</b>")
    end

    it "can correctly handle two commands in a row" do
      expect(parse("Soli \\b{Deo} \\it{Gloria}"))
            .== para("Soli <b>Deo</b> <i>Gloria</i>")
    end

    it "can correctly handle nested commands" do
      expect(parse("Soli \\b{\\it{Deo}} Gloria"))
            .== para("Soli <b><i>Deo</i></b> Gloria")
    end

    it "can correctly handle three-deep nested commands" do
      expect(parse("Soli \\sup{\\b{\\it{Deo}}} Gloria"))
            .== para("Soli <sup><b><i>Deo</i></b></sup> Gloria")
    end

    it "can correctly handle commands split over multiple lines" do
      expect(parse(TWO_LINE_BOLD_BEFORE))
            .== TWO_LINE_BOLD_AFTER
    end
  end

  describe "basic formatting" do
    it "can correctly handle bold" do
      expect(parse("Soli \\b{Deo} Gloria"))
            .== para("Soli <b>Deo</b> Gloria")
    end

    it "can correctly handle italics" do
      expect(parse("Soli \\it{Deo} Gloria"))
            .== para("Soli <i>Deo</i> Gloria")
    end

    it "can correctly handle subscripts" do
      expect(parse("Soli \\sub{Deo} Gloria"))
            .== para("Soli <sub>Deo</sub> Gloria")
    end

    it "can correctly handle superscripts" do
      expect(parse("Soli \\sup{Deo} Gloria"))
            .== para("Soli <sup>Deo</sup> Gloria")
    end
  end

  describe :headers do
    describe :h1 do
      it "basic test" do
        expect(parse("\\h1{Soli Deo Gloria}"))
              .== para("<h1>Soli Deo Gloria</h1>")
      end
    end

    describe :h2 do
      it "basic test" do
        expect(parse("\\h2{Soli Deo Gloria}"))
              .== para("<h2>Soli Deo Gloria</h2>")
      end
    end

    describe :h3 do
      it "basic test" do
        expect(parse("\\h3{Soli Deo Gloria}"))
              .== para("<h3>Soli Deo Gloria</h3>")
      end
    end

    describe :h4 do
      it "basic test" do
        expect(parse("\\h4{Soli Deo Gloria}"))
              .== para("<h4>Soli Deo Gloria</h4>")
      end
    end

    describe :h5 do
      it "basic test" do
        expect(parse("\\h5{Soli Deo Gloria}"))
              .== para("<h5>Soli Deo Gloria</h5>")
      end
    end

    describe :h6 do
      it "basic test" do
        expect(parse("\\h6{Soli Deo Gloria}"))
              .== para("<h6>Soli Deo Gloria</h6>")
      end
    end
end

  describe "basic mathematics" do
    it "can nest mathematics" do
      expect(parse("\\+{10 \\*{3 5} \\-{\\+{4 5} 2}"))
            .== para("32.0")
    end
  end

  describe "mathematical constants" do
    describe :pi do
      it "exists" do
        expect(parse("\\pi"))
              .== para(Math::PI.to_s)
      end
    end

    describe :e do
      it "exists" do
        expect(parse("\\e"))
              .== para(Math::E.to_s)
      end
    end

    describe :i
  end

  describe :addition do
    it "works with multiple arguments" do
      expect(parse("\\+{1 2 3 4}"))
            .== para("10.0")
    end

    it "works with a single argument" do
      expect(parse("\\+{123}"))
            .== para("123.0")
    end
  end

  describe :subtraction do
    it "works with multiple arguments" do
      expect(parse("\\-{10 40}"))
            .== para("-30.0")
    end

    it "works with a single argument" do
      expect(parse("\\-{123}"))
            .== para("-123.0")
    end
  end

  describe :multiplication do
    it "works with multiple arguments" do
      expect(parse("\\*{10 -4.7}"))
            .== para("-47.0")
    end

    it "works with a single argument" do
      expect(parse("\\*{123}").to_html)
            .== para("123.0")
    end
  end

  describe :division do
    it "works with multiple arguments" do
      expect(parse("\\/{100 10 2}"))
            .== para("5.0")
    end

    it "works with a single argument, calculating the inverse" do
      expect(parse("\\/{10}"))
            .== para("0.1")
    end
  end

  describe :trigonometry do
    describe :sin do
      it "basic test" do
        expect(parse("\\sin{0}"))
              .== para("0.0")
      end
    end

    describe :cosine do
      it "basic test" do
        expect(parse("\\cos{\\pi}"))
              .== para("-1.0")
      end
    end

    describe :tangent do
      it "basic test" do
        expect(parse("\\tan{0}"))
              .== para("0.0")
      end
    end

    describe :asin do
      it "basic test" do
        expect(parse("\\asin{0}"))
              .== para("0.0")
      end
    end

    describe :acos do
      it "basic test" do
        expect(parse("\\acos{1}"))
              .== para("0.0")
      end
    end

    describe :atang do
      it "basic test" do
        expect(parse("\\atan{0}"))
              .== para("0.0")
      end
    end
  end

  describe "degrees->radians" do
    it "converts degrees to radians" do
      expect(parse("\\d2r{0}"))
            .== para("0.0")
      expect(parse("\\deg->rad{0}"))
            .== para("0.0")
      expect(parse("\\degrees->radians{0}"))
            .== para("0.0")
      expect(parse("\\d2r{180.0}"))
            .== para(Math::PI.to_s)
    end
  end

  describe "radians->degrees" do
    it "converts radians to degrees" do
      expect(parse("\\r2d{0}"))
            .== para("0.0")
      expect(parse("\\rad->deg{0}"))
            .== para("0.0")
      expect(parse("\\radians->degrees{0}"))
            .== para("0.0")
      expect(parse("\\r2d{"+Math::PI.to_s+"}"))
            .== para("180.0")
    end
  end

  describe :link_id do
    it "builds out a href to a ThinkingBicycle Link" do
      expect(parse("\\link-id{123}"))
        .== para("<a href=\"http://thinkingbicycle.com/links/123/\">Link #123</a>")
    end
  end
end
