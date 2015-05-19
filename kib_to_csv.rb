#!/usr/bin/env ruby
require 'csv'
require 'json'

data = ARGV[0]

x = `curl 'logs.moov.sh:9200/_all/_search?pretty' -d '#{data}'`

CSV.open("logs-#{Time.new.strftime("%m.%d.%y")}.csv", "w") do |csv|
  #get all hits
  j = JSON.parse(x)['hits']['hits']
  #push keys once
  csv << j[0]['_source'].select{|k,v| k != 'message'}.keys
  #iterate through all values and push
  j.each do |hash|
    csv << hash['_source'].select{|k,v| k != 'message'}.values 
  end
end
