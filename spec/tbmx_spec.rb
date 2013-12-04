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
"<p>Line 1
Line 2</p>

<p>Line 3
Line 4</p>"

describe TBMX::HTML do
  it "can be instantiated" do
    TBMX::HTML.new("").should be_a TBMX::HTML
  end

  describe :parse do
    it "can correctly parse a single word" do
      TBMX::HTML.new("Word").parse.should == "<p>Word</p>"
    end

    it "can correctly parse a single non-english word" do
      TBMX::HTML.new("Λόγος").parse.should == "<p>Λόγος</p>"
    end

    it "escapes < and >" do
      TBMX::HTML.new("<b>not bold</b>").parse.should ==
        "<p>&lt;b&gt;not bold&lt;/b&gt;</p>"
    end

    it "escapes &" do
      TBMX::HTML.new("not &lt; less-than").parse.should ==
        "<p>not &amp;lt; less-than</p>"
    end

    it "can correctly split paragraphs" do
      TBMX::HTML.new(TWO_PARAGRAPHS_BEFORE).parse.should == TWO_PARAGRAPHS_AFTER
    end
  end
end
