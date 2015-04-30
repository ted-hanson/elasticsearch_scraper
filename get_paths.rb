#!/usr/bin/env ruby
require 'csv'

file = ARGV[0]

if file.nil?
  raise "Need to specify file"
end

paths = {}
CSV.foreach("#{ARGV[0]}", headers: true) do |row|
  u = row['url']
  if paths[u]
    paths[u] += 1
  else
    paths[u] = 1
  end
end

paths.each do |k,v|
  File.open('paths', 'a') { |file| file.puts("#{k}: #{v}") }
end
