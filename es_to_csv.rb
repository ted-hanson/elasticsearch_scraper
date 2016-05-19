#!/usr/bin/env ruby
require 'csv'
require 'json'

data = ARGV[0]
size = ARGV[1] if !ARGV[1].nil?

host = 'search-moovweb-euu5rinexfwk2e5bpvg45wh35m.us-west-2.es.amazonaws.com'
req = `curl 'http://#{host}/logstash-*/_search?from=0&size=1' -H "Content-Type: application/json" -d '#{data}' -s`


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
    puts "downloading index #{i} - #{i+amt}"
    x = `curl -POST 'http://#{host}/logstash-*/_search?from=#{i}&size=#{amt}' -H "Content-Type: applicaiton/json" -d '#{data}' -s`

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
