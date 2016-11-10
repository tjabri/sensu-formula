#!/usr/bin/env ruby
#
# This mutator enables team-based routing for check results.
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'json'

##
# Sets event[:check][:pager_team] to event[:client][:pager_team]
# if it's not set in event[:check][:pager_team]

event = JSON.parse(STDIN.read, :symbolize_names => true)

if event[:client][:pager_team] && ! event[:check][:pager_team]
  event[:check][:pager_team] = event[:client][:pager_team]
end

event.merge!(:mutated => true)

puts JSON.dump(event)

