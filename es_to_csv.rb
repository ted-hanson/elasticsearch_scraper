#!/usr/bin/env ruby
require 'csv'
require 'json'

data = ARGV[0]
size = ARGV[1] if !ARGV[1].nil?

req = `curl 'http://logs.moov.sh:9200/logstash-*/_search?from=0&size=1' -d '#{data}' -s`


CSV.open("logs-#{Time.new.strftime("%m.%d.%y")}.csv", "ab") do |csv|
  #get all hits
  j = JSON.parse(req)
  size = j['hits']['total']
  j = j['hits']['hits']

  #push keys once
  csv << j[0]['_source'].select{|k,v| k != 'message'}.keys

  # pull 10000 values at once
  amt = 10000
  i = 0
  while i < size do
    puts "downloading index #{i}"
    puts amt
    x = `curl -POST 'http://logs.moov.sh:9200/logstash-*/_search?from=#{i}&size=#{amt}' -d '#{data}' -s`

    j = JSON.parse(x)['hits']['hits']
    #iterate through all values and push
    j.each do |hash|
      begin
        csv << hash['_source'].select{|k,v| k != 'message'}.values
      rescue
        puts "Error: #{hash}"
      end
    end

    i += amt
  end
end
