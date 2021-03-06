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

describe Teepee::Parser do
  it "can be instantiated" do
    expect(Teepee::Parser.new(""))
      .to be_a Teepee::Parser
  end

  describe "basic parsing tests" do
    it "can correctly parse a single word" do
      expect(parse("Word"))
        .to eq(para("Word"))
    end

    it "can correctly parse a single non-english word" do
      expect(parse("Λόγος"))
        .to eq(para("Λόγος"))
    end

    it "escapes < and >" do
      expect(parse("<b>not bold</b>"))
        .to eq(para("&lt;b&gt;not bold&lt;/b&gt;"))
    end

    it "escapes &" do
      expect(parse("not &lt; less-than"))
        .to eq(para("not &amp;lt; less-than"))
    end

    it "can correctly split paragraphs" do
      expect(parse(TWO_PARAGRAPHS_BEFORE))
            .to eq(TWO_PARAGRAPHS_AFTER)
    end

    it "can correctly handle a command around the entire input" do
      expect(parse("\\b{Soli Deo Gloria}"))
        .to eq(para("<b>Soli Deo Gloria</b>"))
    end

    it "can correctly handle two commands in a row" do
      expect(parse("Soli \\b{Deo} \\it{Gloria}"))
        .to eq(para("Soli <b>Deo</b> <i>Gloria</i>"))
    end

    it "can correctly handle nested commands" do
      expect(parse("Soli \\b{\\it{Deo}} Gloria"))
        .to eq(para("Soli <b><i>Deo</i></b> Gloria"))
    end

    it "can correctly handle three-deep nested commands" do
      expect(parse("Soli \\sup{\\b{\\it{Deo}}} Gloria"))
        .to eq(para("Soli <sup><b><i>Deo</i></b></sup> Gloria"))
    end

    it "can correctly handle commands split over multiple lines" do
      expect(parse(TWO_LINE_BOLD_BEFORE))
        .to eq(TWO_LINE_BOLD_AFTER)
    end
  end

  describe "basic formatting" do
    it "can correctly handle bold" do
      expect(parse("Soli \\b{Deo} Gloria"))
        .to eq(para("Soli <b>Deo</b> Gloria"))
    end

    it "can correctly handle italics" do
      expect(parse("Soli \\it{Deo} Gloria"))
        .to eq(para("Soli <i>Deo</i> Gloria"))
    end

    it "can correctly handle subscripts" do
      expect(parse("Soli \\sub{Deo} Gloria"))
        .to eq(para("Soli <sub>Deo</sub> Gloria"))
    end

    it "can correctly handle superscripts" do
      expect(parse("Soli \\sup{Deo} Gloria"))
        .to eq(para("Soli <sup>Deo</sup> Gloria"))
    end
  end

  describe :nbsp do
    it "can take no arguments, defaulting to 1" do
      expect(parse("\\_"))
        .to eq(para("&nbsp;"))
    end

    it "can take an optional multiple" do
      expect(parse("\\_{2}"))
        .to eq(para("&nbsp;&nbsp;"))
    end
  end

  describe :headers do
    describe :h1 do
      it "basic test" do
        expect(parse("\\h1{Soli Deo Gloria}"))
          .to eq(para("<h1>Soli Deo Gloria</h1>"))
      end
    end

    describe :h2 do
      it "basic test" do
        expect(parse("\\h2{Soli Deo Gloria}"))
          .to eq(para("<h2>Soli Deo Gloria</h2>"))
      end
    end

    describe :h3 do
      it "basic test" do
        expect(parse("\\h3{Soli Deo Gloria}"))
          .to eq(para("<h3>Soli Deo Gloria</h3>"))
      end
    end

    describe :h4 do
      it "basic test" do
        expect(parse("\\h4{Soli Deo Gloria}"))
          .to eq(para("<h4>Soli Deo Gloria</h4>"))
      end
    end

    describe :h5 do
      it "basic test" do
        expect(parse("\\h5{Soli Deo Gloria}"))
          .to eq(para("<h5>Soli Deo Gloria</h5>"))
      end
    end

    describe :h6 do
      it "basic test" do
        expect(parse("\\h6{Soli Deo Gloria}"))
          .to eq(para("<h6>Soli Deo Gloria</h6>"))
      end
    end
end

  describe "basic mathematics" do
    it "can nest mathematics" do
      expect(parse("\\+{10 \\*{3 5} \\-{\\+{4 5} 2}"))
        .to eq(para("32.0"))
    end
  end

  describe "mathematical constants" do
    describe :pi do
      it "exists" do
        expect(parse("\\pi"))
          .to eq(para(Math::PI.to_s))
      end
    end

    describe :e do
      it "exists" do
        expect(parse("\\e"))
          .to eq(para(Math::E.to_s))
      end
    end

    describe :i
  end

  describe :addition do
    it "works with multiple arguments" do
      expect(parse("\\+{1 2 3 4}"))
        .to eq(para("10.0"))
    end

    it "works with a single argument" do
      expect(parse("\\+{123}"))
        .to eq(para("123.0"))
    end
  end

  describe :subtraction do
    it "works with multiple arguments" do
      expect(parse("\\-{10 40}"))
        .to eq(para("-30.0"))
    end

    it "works with a single argument" do
      expect(parse("\\-{123}"))
        .to eq(para("-123.0"))
    end
  end

  describe :multiplication do
    it "works with multiple arguments" do
      expect(parse("\\*{10 -4.7}"))
        .to eq(para("-47.0"))
    end

    it "works with a single argument" do
      expect(parse("\\*{123}").to_html)
        .to eq(para("123.0"))
    end
  end

  describe :division do
    it "works with multiple arguments" do
      expect(parse("\\/{100 10 2}"))
        .to eq(para("5.0"))
    end

    it "works with a single argument, calculating the inverse" do
      expect(parse("\\/{10}"))
        .to eq(para("0.1"))
    end
  end

  describe :floor do
    it "works for floats" do
      expect(parse("\\floor{12.34}"))
        .to eq(para("12"))
    end
  end

  describe :ceiling do
    it "works for floats" do
      expect(parse("\\ceiling{12.34}"))
        .to eq(para("13"))
    end
  end

  describe :percentages do
    describe :% do
      it "calculates percentages" do
        expect(parse("\\%{120 12}"))
          .to eq(para("14.4"))
        expect(parse("\\%{100 10}"))
          .to eq(para("10.0"))
      end
    end

    describe "+%" do
      it "adds a percentage" do
        expect(parse("\\+%{120 12}"))
          .to eq(para("134.4"))
        expect(parse("\\+%{120 200}"))
          .to eq(para("360.0"))
      end
    end

    describe "-%" do
      it "subtracts a percentage" do
        expect(parse("\\-%{120 12}"))
          .to eq(para("105.6"))
        expect(parse("\\-%{120 200}"))
          .to eq(para("-120.0"))
      end
    end

    describe "%t" do
      it "returns the percentage of the total" do
        expect(parse("\\%t{100 10}"))
          .to eq(para("10.0"))
      end
    end
  end

  describe :comparisons do
    describe :< do
      it "works for no arguments" do
        expect(parse("\\<{}"))
          .to eq(para("true"))
      end

      it "works for one argument" do
        expect(parse("\\<{123}"))
          .to eq(para("true"))
      end

      it "works for two arguments" do
        expect(parse("\\<{123 456}"))
          .to eq(para("true"))
        expect(parse("\\<{123 123}"))
          .to eq(para("false"))
        expect(parse("\\<{123 122.5}"))
          .to eq(para("false"))
      end

      it "works for many arguments" do
        expect(parse("\\<{123 456 789 101112}"))
          .to eq(para("true"))
        expect(parse("\\<{1 2 3 123 123}"))
          .to eq(para("false"))
      end
    end
  end

  describe :trigonometry do
    describe :sin do
      it "basic test" do
        expect(parse("\\sin{0}"))
          .to eq(para("0.0"))
      end
    end

    describe :cosine do
      it "basic test" do
        expect(parse("\\cos{\\pi}"))
          .to eq(para("-1.0"))
      end
    end

    describe :tangent do
      it "basic test" do
        expect(parse("\\tan{0}"))
          .to eq(para("0.0"))
      end
    end

    describe :asin do
      it "basic test" do
        expect(parse("\\asin{0}"))
          .to eq(para("0.0"))
      end
    end

    describe :acos do
      it "basic test" do
        expect(parse("\\acos{1}"))
              .== para("0.0")
      end
    end

    describe :atan do
      it "basic test" do
        expect(parse("\\atan{0}"))
          .to eq(para("0.0"))
      end
    end
  end

  describe "degrees->radians" do
    it "converts degrees to radians" do
      expect(parse("\\d2r{0}"))
        .to eq(para("0.0"))
      expect(parse("\\deg->rad{0}"))
        .to eq(para("0.0"))
      expect(parse("\\degrees->radians{0}"))
        .to eq(para("0.0"))
      expect(parse("\\d2r{180.0}"))
        .to eq(para(Math::PI.to_s))
    end
  end

  describe "radians->degrees" do
    it "converts radians to degrees" do
      expect(parse("\\r2d{0}"))
        .to eq(para("0.0"))
      expect(parse("\\rad->deg{0}"))
        .to eq(para("0.0"))
      expect(parse("\\radians->degrees{0}"))
        .to eq(para("0.0"))
      expect(parse("\\r2d{"+Math::PI.to_s+"}"))
        .to eq(para("180.0"))
    end
  end

  describe "ID commands" do
    describe :link_id do
      it "builds out a href to a ThinkingBicycle Link" do
        expect(parse("\\link-id{123}"))
          .to eq(para("<a href=\"http://thinkingbicycle.com/links/123/\">Link #123</a>"))
      end
    end

    describe :note_id do
      it "builds out a href to a ThinkingBicycle Note" do
        expect(parse("\\note-id{123}"))
          .to eq(para("<a href=\"http://thinkingbicycle.com/notes/123/\">Note #123</a>"))
      end
    end
  end

  describe :link do
    it "works with just a bare URL" do
      expect(parse("\\link{http://www.cgore.com}"))
        .to eq(para("<a href=\"http://www.cgore.com\">http://www.cgore.com</a>"))
    end

    it "works with a URL and a keyword" do
      expect(parse("\\link{http://www.cgore.com cgore dot com}"))
        .to eq(para("<a href=\"http://www.cgore.com\">cgore dot com</a>"))
    end

    it "works with a URL and a multi-word keywords" do
      expect(parse("\\link{http://www.cgore.com Chris Gore}"))
        .to eq(para("<a href=\"http://www.cgore.com\">Chris Gore</a>"))
    end

    it "doesn't get confused by too much whitespace" do
      expect(parse("\\link{http://www.cgore.com    }"))
        .to eq(para("<a href=\"http://www.cgore.com\">http://www.cgore.com</a>"))
      expect(parse("\\link{    http://www.cgore.com}"))
        .to eq(para("<a href=\"http://www.cgore.com\">http://www.cgore.com</a>"))
    end
  end

  describe :image do
    it "works for a bare URL" do
      expect(parse("\\image{http://www.cgore.com/monster.jpeg}"))
        .to eq(para("<img src=\"http://www.cgore.com/monster.jpeg\"/>"))
    end

    it "works for a URL with alt text specified" do
      expect(parse("\\image{http://www.cgore.com/monster.jpeg Scary Monsters}"))
        .to eq(para("<img src=\"http://www.cgore.com/monster.jpeg\" alt=\"Scary Monsters\"/>"))
    end

    it "doesn't get confused by too much whitespace" do
      expect(parse("\\image{http://www.cgore.com/monster.jpeg    }"))
        .to eq(para("<img src=\"http://www.cgore.com/monster.jpeg\"/>"))
      expect(parse("\\image{    http://www.cgore.com/monster.jpeg}"))
        .to eq(para("<img src=\"http://www.cgore.com/monster.jpeg\"/>"))
    end
  end

  describe :mailto do
    it "works for a simple email address" do
      expect(parse("\\mailto{foo@example.com}"))
        .to eq(para("<a href=\"mailto:foo@example.com\">foo@example.com</a>"))
    end
  end

  describe :booleans do
    describe :true do
      it "returns the true constant" do
        expect(parse("\\true"))
          .to eq(para("true"))
      end
    end

    describe :false do
      it "returns the false constant" do
        expect(parse("\\false"))
          .to eq(para("false"))
      end
    end

    describe :boolean_and do
      it "returns true for no arguments" do
        expect(parse("\\and{}"))
          .to eq(para("true"))
      end

      it "returns true for just true" do
        expect(parse("\\and{true}"))
          .to eq(para("true"))
      end

      it "returns false for just false" do
        expect(parse("\\and{false}"))
          .to eq(para("false"))
      end

      it "two-argument tests" do
        expect(parse("\\and{true true}"))
          .to eq(para("true"))
        expect(parse("\\and{true false}"))
          .to eq(para("false"))
        expect(parse("\\and{false true}"))
          .to eq(para("false"))
        expect(parse("\\and{false false}"))
          .to eq(para("false"))
      end
    end

    describe :boolean_nand do
      it "returns false for no arguments" do
        expect(parse("\\nand{}"))
          .to eq(para("false"))
      end

      it "returns false for just true" do
        expect(parse("\\nand{true}"))
          .to eq(para("false"))
      end

      it "returns false for just false" do
        expect(parse("\\nand{false}"))
          .to eq(para("true"))
      end

      it "two-argument tests" do
        expect(parse("\\nand{true true}"))
          .to eq(para("false"))
        expect(parse("\\nand{true false}"))
          .to eq(para("true"))
        expect(parse("\\nand{false true}"))
          .to eq(para("true"))
        expect(parse("\\nand{false false}"))
          .to eq(para("true"))
      end
    end

    describe :boolean_or do
      it "returns false for no arguments" do
        expect(parse("\\or{}"))
          .to eq(para("false"))
      end

      it "returns true for just true" do
        expect(parse("\\or{true}"))
          .to eq(para("true"))
      end

      it "returns false for just false" do
        expect(parse("\\or{false}"))
          .to eq(para("false"))
      end

      it "two-argument tests" do
        expect(parse("\\or{true true}"))
          .to eq(para("true"))
        expect(parse("\\or{true false}"))
          .to eq(para("true"))
        expect(parse("\\or{false true}"))
          .to eq(para("true"))
        expect(parse("\\or{false false}"))
          .to eq(para("false"))
      end
    end

    describe :boolean_nor do
      it "returns true for no arguments" do
        expect(parse("\\nor{}"))
          .to eq(para("true"))
      end

      it "returns false for just true" do
        expect(parse("\\nor{true}"))
          .to eq(para("false"))
      end

      it "returns true for just false" do
        expect(parse("\\nor{false}"))
          .to eq(para("true"))
      end

      it "two-argument tests" do
        expect(parse("\\nor{true true}"))
          .to eq(para("false"))
        expect(parse("\\nor{true false}"))
          .to eq(para("false"))
        expect(parse("\\nor{false true}"))
          .to eq(para("false"))
        expect(parse("\\nor{false false}"))
          .to eq(para("true"))
      end
    end

    describe :boolean_xnor do
      it "returns true for no arguments" do
        expect(parse("\\xnor{}"))
          .to eq(para("true"))
      end

      it "returns false for just true" do
        expect(parse("\\xnor{true}"))
          .to eq(para("false"))
      end

      it "returns true for just false" do
        expect(parse("\\xnor{false}"))
          .to eq(para("true"))
      end

      it "two-argument tests" do
        expect(parse("\\xnor{true true}"))
          .to eq(para("true"))
        expect(parse("\\xnor{true false}"))
          .to eq(para("false"))
        expect(parse("\\xnor{false true}"))
          .to eq(para("false"))
        expect(parse("\\xnor{false false}"))
          .to eq(para("true"))
      end
    end

    describe :boolean_xor do
      it "returns false for no arguments" do
        expect(parse("\\xor{}"))
          .to eq(para("false"))
      end

      it "returns true for just true" do
        expect(parse("\\xor{true}"))
          .to eq(para("true"))
      end

      it "returns false for just false" do
        expect(parse("\\xor{false}"))
          .to eq(para("false"))
      end

      it "two-argument tests" do
        expect(parse("\\xor{true true}"))
          .to eq(para("false"))
        expect(parse("\\xor{true false}"))
          .to eq(para("true"))
        expect(parse("\\xor{false true}"))
          .to eq(para("true"))
        expect(parse("\\xor{false false}"))
          .to eq(para("false"))
      end
    end

    describe :boolean_not do
      it "returns false for true" do
        expect(parse("\\not{true}"))
          .to eq(para("false"))
      end

      it "returns true for false" do
        expect(parse("\\not{false}"))
          .to eq(para("true"))
      end
    end

    describe :span_operator do
      it "wraps in a span tag" do
        expect(parse("\\span{1 2 3}"))
          .to eq(para("<span>1 2 3</span>"))
      end

      it "can nest" do
        expect(parse("\\span{1 2 \\span{3 4 5}}"))
          .to eq(para("<span>1 2 <span>3 4 5</span></span>"))
      end
    end

    describe :comment_operator do
      it "comments out it's expressions" do
        expect(parse("1\\comment{I'm a comment}3"))
          .to eq(para("13"))
        expect(parse("1\\!--{I'm a comment}3"))
          .to eq(para("13"))
        expect(parse("1\\\#{I'm a comment}3"))
          .to eq(para("13"))
      end
    end

    describe :prog1_operator do
      it "pulls out the first expression" do
        expect(parse("\\prog1{foo bar baz}"))
          .to eq(para("foo"))
      end
    end

    describe :progn_operator do
      it "pulls out the last expression" do
        expect(parse("\\progn{foo bar baz}"))
          .to eq(para("baz"))
      end
    end

    describe :if_operator do
      describe :two_argument_variant do
        it "maps true to the true clause" do
          expect(parse("\\if{true foo bar}"))
            .to eq(para("foo"))
        end

        it "maps false to the false clause" do
          expect(parse("\\if{false foo bar}"))
            .to eq(para("bar"))
        end
      end

      describe :one_argument_variant do
        it "maps true to the true clause" do
          expect(parse("\\if{true foo}"))
            .to eq(para("foo"))
        end

        it "maps false to an empty string" do
          expect(parse("\\if{false foo}"))
            .to eq(para(""))
        end
      end

      it "can handle do operators as the two clauses" do
        expect(parse("\\if{true \\span{foo bar} baz}"))
          .to eq(para("<span>foo bar</span>"))
      end

      it "ignores extra leading whitespace" do
        expect(parse("\\if{  true foo bar}"))
          .to eq(para("foo"))
      end

      it "ignores extra trailing whitespace" do
        expect(parse("\\if{false foo bar   }"))
          .to eq(para("bar"))
      end


      it "ignores extra trailing expressions" do
        expect(parse("\\if{false foo bar baz}"))
          .to eq(para("bar"))
      end
    end

    describe :when_operator do
      it "evaluates when the conditional is true" do
        expect(parse("\\when{true red white blue}"))
          .to eq(para("<span>red white blue</span>"))
      end

      it "does not evaluate when the conditional is false" do
        expect(parse("\\when{false red white blue}"))
          .to eq(para(""))
      end

      it "doesn't wrap a single clause in a span" do
        expect(parse("\\when{true lonely}"))
          .to eq(para("lonely"))
      end

      it "doesn't freak out with no body" do
        expect(parse("\\when{true}"))
          .to eq(para(""))
      end
    end

    describe :unless_operator do
      it "evaluates when the conditional is false" do
        expect(parse("\\unless{false red white blue}"))
          .to eq(para("<span>red white blue</span>"))
      end

      it "does not evaluate when the conditional is true" do
        expect(parse("\\unless{true red white blue}"))
          .to eq(para(""))
      end

      it "doesn't wrap a single clause in a span" do
        expect(parse("\\unless{false lonely}"))
          .to eq(para("lonely"))
      end

      it "doesn't freak out with no body" do
        expect(parse("\\unless{false}"))
          .to eq(para(""))
      end
    end

    describe :cond_operator do
      it "does nothing if given no arguments" do
        expect(parse("\\cond{}"))
          .to eq(para(""))
      end

      it "does nothing with just a single conditional" do
        expect(parse("\\cond{true}"))
          .to eq(para(""))
      end

      it "works with a single true clause" do
        expect(parse("\\cond{true foo}"))
          .to eq(para("foo"))
      end

      it "works with a single false clause" do
        expect(parse("\\cond{false foo}"))
          .to eq(para(""))
      end

      it "works with a multi-clause conditional" do
        expect(parse("\\cond{false foo false bar true baz true quux}"))
          .to eq(para("baz"))
      end

      it "works with a multi-clause conditional with no true conditionals" do
        expect(parse("\\cond{false foo false bar false baz false quux}"))
          .to eq(para(""))
      end
    end

    describe :case_operator do
      it "does nothing if given no arguments" do
        expect(parse("\\case{}"))
          .to eq(para(""))
      end

      it "does nothing with just a value" do
        expect(parse("\\case{123}"))
          .to eq(para(""))
      end

      it "works with no match" do
        expect(parse("\\case{123 1 foo 2 bar 3 baz}"))
          .to eq(para(""))
      end

      it "works with a match in the beginning" do
        expect(parse("\\case{123 123 foo 4 bar 5 baz}"))
          .to eq(para("foo"))
      end

      it "works with a match in the middle" do
        expect(parse("\\case{123 1 foo 123 bar 4 baz}"))
          .to eq(para("bar"))
      end

      it "works with a match in the end" do
        expect(parse("\\case{123 1 foo 2 bar 123 baz}"))
          .to eq(para("baz"))
      end

      it "works for non-numerics" do
        expect(parse("\\case{something one foo something bar three baz}"))
          .to eq(para("bar"))
      end
    end
  end
end
