#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Actions
  module Staypuft
    module Host
      class PuppetRun < Dynflow::Action

        middleware.use Actions::Staypuft::Middleware::AsCurrentUser

        def plan(host)
          Type! host, ::Host::Base
          plan_self host_id: host.id, name: host.name
        end

        def run
          host_id = input.fetch(:host_id)

          # try puppetrun 3 times
          result = false
          tries = 0
          while !result && tries < 3
            result = ::Host.find(host_id).puppetrun!
            tries += 1
          end

          unless result
            fail(::Staypuft::Exception, "Puppet run failed for host: #{host_id}")
          end

          output[:executed_at] = DateTime.now.iso8601
          output[:tries] = tries
          output[:result] = result
        end

      end
    end
  end
end
