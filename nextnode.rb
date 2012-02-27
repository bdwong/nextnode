#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'

class Reservation
  @@list = {}
  def self.list
    @@list
  end
end

def get_nodes_json
  # File.read("sampledata/computer2.out")
  nodes = `curl http://localhost:8080/jenkins/computer/api/json`
  if $? != 0
    raise RuntimeError.new('Error executing curl.')
  end
  nodes
end

def get_nodes
  JSON.parse(get_nodes_json)
end

def reserved?(nodeName)
  return false if Reservation.list[nodeName].nil?
  return Time.now < Reservation.list[nodeName]
end

def reserve(nodeName)
  Reservation.list[nodeName] = Time.now + 900 # reserved for 15 minutes
end

# Reserve the node for the next x minutes.
get "/nextnode" do
  begin
    computers = get_nodes
  rescue RuntimeError => e
    # indicate internal server error.
    return 500
  end
  #puts "regex nil? #{@params["regex"].nil?}"
  found = computers["computer"].find do |c|
    (
      (@params["regex"].nil? || (c["displayName"] =~ Regexp.new(@params["regex"]))) &&
      c["offline"] == true &&
      c["temporarilyOffline"] == false &&
      c["jnlpAgent"] == true &&
      c["manualLaunchAllowed"] == true &&
      !reserved?(c["displayName"])
    )
  end
  if found
    # puts "#{found["displayName"]} #{found["offline"]} #{found["temporarilyOffline"]} #{found["jnlpAgent"]} #{found["manualLaunchAllowed"]}"
    reserve(found["displayName"])
    "#{found["displayName"]}\n"
  else
    ""
  end
end
