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
require 'teepee/commander'

include ERB::Util

module Teepee
  class ActionableCommander < Commander
    def initialize action_view, controller
      @action_view = action_view
      @controller = controller
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
        thing = klass.find Integer(id.to_s)
        if thing
          @action_view.render partial: partial,
                              locals: {singular.to_sym => thing}
        else
          command_error "unknown #{singular} ID #{id.to_s}"
        end
      end
    end

    def user user
      if not user
        command_error "user: error: no user specified"
      else
        the_user = User.smart_find user.to_s
        if the_user
          @action_view.render partial: 'users/name_link',
                              locals: {the_user: the_user}
        else
          command_error "unknown user #{user.to_s}"
        end
      end
    end
  end
end
