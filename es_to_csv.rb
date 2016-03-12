#!/usr/bin/env ruby
require 'csv'
require 'json'

# Download logs from Elastic Search
# usage: ./es_to_csv.rb '{ JSON query }' [<max lines>]
# You can get the JSON from ElasticSearch page using the 'i' button to view the JSON.
# max lines: limit the download to this many lines

def time_diff(start)
   (Time.now - start)
end

def fmt_number(num)
   num.round(0).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

data = ARGV[0]
size = ARGV[1] if !ARGV[1].nil?

req = `curl 'http://logs.moov.sh:9200/logstash-*/_search?from=0&size=1' -d '#{data}' -s`
filename = "logs-#{Time.new.strftime("%m.%d.%y_%H.%M.%S")}.csv"
CSV.open(filename, "ab") do |csv|
  #get all hits
  j = JSON.parse(req)
  size = j['hits']['total']
  j = j['hits']['hits']

  #push keys once
  csv << j[0]['_source'].select{|k,v| k != 'message'}.keys

  # pull 15000 values at once
  amt = 15000
  i = 0
  startTime = Time.now
  puts "Starting log download to: #{filename} in #{fmt_number(amt)} line chunks."
  while i < size do

    x = `curl -POST 'http://logs.moov.sh:9200/logstash-*/_search?from=#{i}&size=#{amt}' -d '#{data}' -s`
    fmtNbr = fmt_number(i + amt)
    lps = fmt_number((i + amt) / time_diff(startTime))
    puts "#{Time.new.strftime("%H:%M:%S")} Lines: #{fmtNbr} Lines/Sec: #{lps}"

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
