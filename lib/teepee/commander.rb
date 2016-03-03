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

require 'uri'

require 'active_support/all'
require 'monkey-patch'

require 'teepee/constants'
require 'teepee/errors'

include ERB::Util

module Teepee
  class Commander
    def valid_uri? uri
      (!! (u = URI.parse(uri))) and not u.scheme.nil?
    rescue URI::InvalidURIError
      false
    end

    def command_error message
      %{<span style="color: red">[#{message}]</span>}
    end

    def command_not_yet_implemented command
      command_error "The command #{command} is not yet implemented."
    end

    def ensure_numeric number
      if number.kind_of? Complex
        command_error "Complex numbers are not yet supported."
      elsif not number.kind_of? Numeric
        command_error "Non-numeric result."
      else
        number
      end
    end

    def html_tag tag, expressions, attribs=nil
      opening_tag = if attribs
                      attribs_string = attribs.map {|k,v| %{#{k}="#{v}"}}.join " "
                      if expressions.nil?
                        "<#{tag} #{attribs_string}/>"
                      else
                        "<#{tag} #{attribs_string}>"
                      end
                    else
                      if expressions.nil?
                        "<#{tag}/>"
                      else
                        "<#{tag}>"
                      end
                    end
      if expressions.nil?
        opening_tag
      else
        opening_tag + expressions.map(&:to_html).join.strip + "</#{tag}>"
      end
    end

    def tb_href target, string
      %{<a href="#{TB_COM}/#{target}">#{string}</a>}
    end

    def id_command_handler(id,
                           klass,
                           singular = klass.to_s.camelcase_to_snakecase,
                           plural = singular.pluralize,
                           partial = "#{plural}/inline",
                           view="")
      if not id
        command_error "#{singular}_id: error: no #{singular} ID specified"
      elsif not id.to_s =~ /\A[0-9]+\z/
        command_error "#{singular}_id: error: invalid #{singular} ID specified"
      else
        tb_href "#{plural}/#{id.to_s}/#{view}", "#{klass.to_s} ##{id.to_s}"
      end
    end

    def left_strip expressions
      while expressions.first.kind_of? WhitespaceToken
        expressions.shift
      end
      expressions
    end

    def right_strip expressions
      while expressions.last.kind_of? WhitespaceToken
        expressions.pop
      end
      expressions
    end

    def strip expressions
      left_strip right_strip expressions
    end

    #----------------------------------------------------------------------------

    def + *numbers
      ensure_numeric numbers.inject 0, :+
    end

    def - *numbers
      if numbers.length == 1
        ensure_numeric -numbers.first
      else
        ensure_numeric numbers.reduce :-
      end
    end

    def * *numbers
      ensure_numeric numbers.inject 1, :*
    end

    def / *numbers
      if numbers.length == 1
        ensure_numeric 1 / numbers.first
      else
        ensure_numeric numbers.reduce :/
      end
    end

    def ** *numbers
      ensure_numeric numbers.reduce :**
    end

    def % *numbers
      ensure_numeric numbers
      numbers.inject { |base, percent| base*percent/100.0 }
    end

    def add_percentage *numbers
      ensure_numeric numbers
      numbers.inject {|base, percent| base * (1+percent/100.0) }
    end

    def subtract_percentage *numbers
      ensure_numeric numbers
      numbers.inject {|base, percent| base * (1-percent/100.0) }
    end

    def percent_total *numbers
      ensure_numeric numbers
      numbers.inject {|total, part| Float(part)/Float(total)*100.0 }
    end

    def acos number
      ensure_numeric Math.acos number
    end

    def acosh number
      ensure_numeric Math.acosh number
    end

    def asin number
      ensure_numeric Math.asin number
    end

    def asinh number
      ensure_numeric Math.asinh number
    end

    def atan number
      ensure_numeric Math.atan number
    end

    def atanh number
      ensure_numeric Math.atanh number
    end

    def b expressions
      html_tag :b, expressions
    end

    def backslash
      "\\"
    end

    def big expressions
      html_tag :big, expressions
    end

    def bookmarks_folder_id id
      id_command_handler id, :Folder, "folder", "folders", "folders/bookmarks_inline", "bookmarks"
    end

    def br
      html_tag :br, nil
    end

    def cos angle
      ensure_numeric Math.cos angle
    end

    def cosh number
      ensure_numeric Math.cosh number
    end

    def degrees2radians degrees
      ensure_numeric degrees * Math::PI / 180.0
    end

    def del expressions
      html_tag :del, expressions
    end

    def e
      Math::E
    end

    def enumerate expressions
      html_tag :ol, expressions
    end

    def enumerate_numeric expressions
      html_tag :ol, expressions, {type: "1"}
    end

    def enumerate_uppercase expressions
      html_tag :ol, expressions, {type: "A"}
    end

    def enumerate_lowercase expressions
      html_tag :ol, expressions, {type: "a"}
    end

    def enumerate_roman_uppercase expressions
      html_tag :ol, expressions, {type: "I"}
    end

    def enumerate_roman_lowercase expressions
      html_tag :ol, expressions, {type: "i"}
    end

    def erf number
      ensure_numeric Math.erf number
    end

    def erfc number
      ensure_numeric Math.erfc number
    end

    def folder_id id
      id_command_handler id, :Folder
    end

    def forum_id id
      id_command_handler id, :Forum
    end

    def gamma number
      ensure_numeric Math.gamma number
    end

    def h1 expressions
      html_tag :h1, expressions
    end

    def h2 expressions
      html_tag :h2, expressions
    end

    def h3 expressions
      html_tag :h3, expressions
    end

    def h4 expressions
      html_tag :h4, expressions
    end

    def h5 expressions
      html_tag :h5, expressions
    end

    def h6 expressions
      html_tag :h6, expressions
    end

    def i
      command_error "Complex numbers are not yet supported."
    end

    def image expressions
      expressions = strip expressions
      uri, *alt_text = expressions
      uri = ERB::Util.html_escape uri.to_s
      if not valid_uri? uri
        command_error "Not a valid URI for the image."
      else
        if alt_text.empty?
          html_tag :img, nil, {src: uri}
        else
          html_tag :img, nil, {src: uri, alt: alt_text.map(&:to_s).join.strip}
        end
      end
    end

    def it expressions
      html_tag :i, expressions
    end

    def item expressions
      html_tag :li, expressions
    end

    def itemize expressions
      html_tag :ul, expressions
    end

    def itemize_disc expressions
      html_tag :ul, expressions, {style: "list-style-type:disc"}
    end

    def itemize_circle expressions
      html_tag :ul, expressions, {style: "list-style-type:circle"}
    end

    def itemize_square expressions
      html_tag :ul, expressions, {style: "list-style-type:square"}
    end

    def itemize_none expressions
      html_tag :ul, expressions, {style: "list-style-type:none"}
    end

    def hypot numbers
      ensure_numeric Math.sqrt numbers.map {|n| n**2}
    end

    def keyword_id id
      id_command_handler id, :Keyword
    end

    def ld n
      ensure_numeric Math.log2 n
    end

    def ldexp fraction, exponent
      ensure_numeric Math.ldexp fraction, exponent
    end

    def left_brace
      "{"
    end

    def lgamma n
      ensure_numeric Math::lgamma(n).first
    end

    def link expressions
      expressions = strip expressions
      uri, *desc = expressions
      uri = ERB::Util.html_escape uri.to_s
      if not valid_uri? uri
        command_error "Not a valid URI."
      else
        desc = [uri] if desc.empty?
        html_tag :a, desc, {href: uri}
      end
    end

    def link_id id
      id_command_handler id, :Link
    end

    def ln number
      ensure_numeric Math.log number
    end

    def log base, number
      if number.nil?
        number, base = base, number
        ensure_numeric Math.log10 number # default to log base 10
      else
        ensure_numeric Math.log number, base
      end
    end

    def log10 number
      ensure_numeric Math.log10 number
    end

    def mod *numbers
      ensure_numeric numbers.reduce :%
    end

    def nbsp
      "&nbsp;"
    end

    def note_id id
      id_command_handler id, :Note
    end

    def pi
      Math::PI
    end

    def radians2degrees radians
      ensure_numeric(radians * 180.0 / Math::PI)
    end

    def right_brace
      "}"
    end

    def sin angle
      ensure_numeric Math.sin angle
    end

    def sinh number
      ensure_numeric Math.sinh number
    end

    def small expressions
      html_tag :small, expressions
    end

    def sqrt number
      ensure_numeric Math.sqrt number
    end

    def space
      " "
    end

    def sub expressions
      html_tag :sub, expressions
    end

    def sup expressions
      html_tag :sup, expressions
    end

    def table expressions
      html_tag :table, expressions
    end

    def table_data expressions
      html_tag :td, expressions
    end

    def table_header expressions
      html_tag :th, expressions
    end

    def table_row expressions
      html_tag :tr, expressions
    end

    def tag_id id
      id_command_handler id, :Tag
    end

    def tan angle
      ensure_numeric Math.tan angle
    end

    def tanh number
      ensure_numeric Math.tanh number
    end

    def tt expressions
      html_tag :tt, expressions
    end

    def u expressions
      html_tag :u, expressions
    end

    def user user
      if not user
        command_error "user: error: no user specified"
      else
        tb_href "users/#{user}", user.to_s
      end
    end
  end
end
