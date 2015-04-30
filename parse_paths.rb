#!/usr/bin/env ruby
require 'csv'

file = ARGV[0]

if file.nil?
  raise "Need to specify file"
end

paths = {}
File.open('paths', 'r').each_line do |line|
  row = line.split(': ')
  path = row[0].gsub(/\?.*/, '')
  if paths[path]
    paths[path] += row[1].to_i
  else
    paths[path] = row[1].to_i
  end
end

paths.sort_by {|_key, value| value}.each do |k,v|
  File.open('paths.csv', 'a') {|f| f.puts "#{k}: #{v}"}
end
