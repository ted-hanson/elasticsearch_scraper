#!/usr/bin/env ruby
require 'csv'
require 'json'

data = ARGV[0]
size = ARGV[1] if !ARGV[1].nil?

size = size.to_i

i = 10200000
while i < size do
  puts "downloading index #{i}"  
  amt = [size-i, 1].min 
  puts amt
  x = `curl -POST 'http://logs.moov.sh:9200/logstash-2015.01.23/_search?from=#{i}&size=#{amt}' -d '#{data}'`

  CSV.open("logs-#{Time.new.strftime("%m.%d.%y")}.csv", "ab") do |csv|
    #get all hits
    j = JSON.parse(x)['hits']['hits']
    #push keys once
    csv << j[0]['_source'].select{|k,v| k != 'message'}.keys
    #iterate through all values and push
    j.each do |hash|
      begin
        csv << hash['_source'].select{|k,v| k != 'message'}.values 
      rescue
        puts "Error: #{hash}"
      end
    end
  end

  i += 100000
end
