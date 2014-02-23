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

require 'spec_helper'

require 'tbmx'

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


describe TBMX::Parser do
  it "can be instantiated" do
    TBMX::Parser.new("").should be_a TBMX::Parser
  end

  describe :parse do
    it "can correctly parse a single word" do
      TBMX::Parser.new("Word").to_html.should == "<p>\nWord\n</p>\n"
    end

    it "can correctly parse a single non-english word" do
      TBMX::Parser.new("Λόγος").to_html.should == "<p>\nΛόγος\n</p>\n"
    end

    it "escapes < and >" do
      TBMX::Parser.new("<b>not bold</b>").to_html.should ==
        "<p>\n&lt;b&gt;not bold&lt;/b&gt;\n</p>\n"
    end

    it "escapes &" do
      TBMX::Parser.new("not &lt; less-than").to_html.should ==
        "<p>\nnot &amp;lt; less-than\n</p>\n"
    end

    it "can correctly split paragraphs" do
      TBMX::Parser.new(TWO_PARAGRAPHS_BEFORE).to_html.should == TWO_PARAGRAPHS_AFTER
    end

    it "can correctly handle bold" do
      TBMX::Parser.new("Soli \\b{Deo} Gloria").to_html.should ==
        "<p>\nSoli <b>Deo</b> Gloria\n</p>\n"
    end

    it "can correctly handle italics" do
      TBMX::Parser.new("Soli \\i{Deo} Gloria").to_html.should ==
        "<p>\nSoli <i>Deo</i> Gloria\n</p>\n"
    end

    it "can correctly handle subscripts" do
      TBMX::Parser.new("Soli \\sub{Deo} Gloria").to_html.should ==
        "<p>\nSoli <sub>Deo</sub> Gloria\n</p>\n"
    end

    it "can correctly handle superscripts" do
      TBMX::Parser.new("Soli \\sup{Deo} Gloria").to_html.should ==
        "<p>\nSoli <sup>Deo</sup> Gloria\n</p>\n"
    end

    it "can correctly handle a command around the entire input" do
      TBMX::Parser.new("\\b{Soli Deo Gloria}").to_html.should ==
        "<p>\n<b>Soli Deo Gloria</b>\n</p>\n"
    end

    it "can correctly handle two commands in a row" do
      TBMX::Parser.new("Soli \\b{Deo} \\i{Gloria}").to_html.should ==
        "<p>\nSoli <b>Deo</b> <i>Gloria</i>\n</p>\n"
    end

    it "can correctly handle nested commands" do
      TBMX::Parser.new("Soli \\b{\\i{Deo}} Gloria").to_html.should ==
        "<p>\nSoli <b><i>Deo</i></b> Gloria\n</p>\n"
    end

    it "can correctly handle three-deep nested commands" do
      TBMX::Parser.new("Soli \\sup{\\b{\\i{Deo}}} Gloria").to_html.should ==
        "<p>\nSoli <sup><b><i>Deo</i></b></sup> Gloria\n</p>\n"
    end

    it "can correctly handle commands split over multiple lines" do
      TBMX::Parser.new(TWO_LINE_BOLD_BEFORE).to_html.should == TWO_LINE_BOLD_AFTER
    end
  end
end
