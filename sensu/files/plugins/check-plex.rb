#!/usr/bin/env ruby
#
# Check Plex
# ===
#
# Checks for the Plex bid request multiplexer.
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'net/http'
require 'json'

class CheckPlex < Sensu::Plugin::Check::CLI

  option :host,
    :short => '-H HOSTNAME',
    :long => '--hostname HOSTNAME',
    :description => 'Hostname to check',
    :default => 'localhost'

  option :port,
    :short => '-p PORT',
    :long => '--port PORT',
    :proc => proc { |a| a.to_i },
    :default => 8080

  option :timeout,
    :short => '-t TIMEOUT',
    :long => '--timeout TIMEOUT',
    :proc => proc { |a| a.to_i },
    :description => "Timeout in secs",
    :default => 60

  option :buffer_size_above_crit,
    :long => '--buffer-size-above-critical SIZE',
    :proc => proc { |a| a.to_i }

  option :buffer_size_above_warn,
    :long => '--buffer-size-above-warn SIZE',
    :proc => proc { |a| a.to_i }

  option :last_data_push_update_above_crit,
    :long => '--last-data-push-update-above-critical SIZE',
    :proc => proc { |a| a.to_i }

  option :last_data_push_update_above_warn,
    :long => '--last-data-push-update-above-warn SIZE',
    :proc => proc { |a| a.to_i }  

  def run
    begin Timeout.timeout(config[:timeout]) do
        stats = get_statcounters
        if stats.nil?
          unknown "Error getting statcounters"
        else
          case
          when config[:buffer_size_above_crit] || config[:buffer_size_above_warn]
            buffer_size = check_buffer_size(stats)
            ok "Buffer size: #{buffer_size}"
          when config[:last_data_push_update_above_crit] || config[:last_data_push_update_above_warn]
            last_data_push_update = check_last_data_push_update(stats)
            ok "Last data push update: #{last_data_push_update}"
          end
        end
      end
    rescue Timeout::Error
      unknown "Request timed out"
    rescue => e
      unknown "Unknown error: #{e.message}"
    end
  end

  def check_buffer_size(statscounter)
    buffer_size = statscounter["total_buffer_size"]
    if config[:buffer_size_above_crit] && buffer_size > config[:buffer_size_above_crit]
      critical "Buffer size #{buffer_size} exceeds threshold #{config[:buffer_size_above_crit]}"
    end
    if config[:buffer_size_above_warn] && buffer_size > config[:buffer_size_above_warn]
      warning "Buffer size #{buffer_size} exceeds threshold #{config[:buffer_size_above_warn]}"
    end
    buffer_size
  end

  def check_last_data_push_update(statscounter)
    last_data_push_update = statscounter["last_data_push_update"]
    if config[:last_data_push_update_above_crit] && last_data_push_update > config[:last_data_push_update_above_crit]
      critical "Last data push update #{last_data_push_update} exceeds threshold #{config[:last_data_push_update_above_crit]}"
    end
    if config[:last_data_push_update_above_warn] && last_data_push_update > config[:last_data_push_update_above_warn]
      warning "Last data push update #{last_data_push_update} exceeds threshold #{config[:last_data_push_update_above_warn]}"
    end
    last_data_push_update
  end  
  
  def get_statcounters
    http = Net::HTTP.new(config[:host], config[:port])
    req = Net::HTTP::Get.new('/statcounters/')
    res = http.request(req)

    if res.code == "200"
      JSON.parse(res.body)
    else
      nil
    end
  end
end

