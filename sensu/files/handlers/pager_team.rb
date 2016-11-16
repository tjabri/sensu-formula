#!/usr/bin/env ruby
#
# This handler dispatches events to other handlers based on the pager_team attribute.
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'

class PagerTeam < Sensu::Handler

  def pager_team
    @event['check']['pager_team'] || @event['client']['pager_team']
  end

  def supported_handlers
    {
      'pagerduty' => {
        'severities' => [
          'ok',
          'critical',
        ],
        'command' => '/opt/sensu/embedded/bin/handler-pagerduty.rb /etc/sensu/conf.d/pagerduty.json',
        'timeout' => 10,
      },
      'hipchat' => {
        'command' => '/opt/sensu/embedded/bin/handler-hipchat.rb /etc/sensu/conf.d/',
        'command_reqs_additional_arg' => true,
        'timeout' => 10,
      },
    }
  end
  
  def handle
    ev = @event.merge('check' => {'pager_team' => pager_team})
    puts ev
    supported_handlers.each do |handler,handler_conf|
      begin
        timeout(handler_conf['timeout']||10) do
          if handler_conf['command_reqs_additional_arg']
            cmd = "echo '#{ev.to_json}' | #{handler_conf['command'] + handler + '_' + pager_team + '.json'}"
          else
            cmd = "echo '#{ev.to_json}' | #{handler_conf['command']}"
          end
          cmd_result_out = %x{#{cmd}}
          cmd_result_exitcode = $?.to_i
          if cmd_result_exitcode != 0
            puts "pager_team -- non-zero exit while calling #{handler}: #{cmd_result_exitcode}"
            puts "pager_team -- output from #{handler} handler: #{cmd_result_out}"
          end
        end
      rescue Timeout::Error
        puts "pager_team -- timed out while attempting to #{@event['action']} on handler #{handler} for incident key #{incident_key}"
      end
    end
  end
  
end
