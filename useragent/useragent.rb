require 'rubygems'
require 'json'

def get_json(index, size, loc)
  return JSON.parse(`curl 'http://logs.moov.sh:9200/logstash-2014.03.09/_search?from=#{index}&size=#{size}&q=type:"varnish"%20AND%20geoip.country_name:"#{loc}"%20AND%20resp_code:"200"%20AND%20req_method:"GET"'`)
end

$chunk    = 10000
$loc      = 'United%20States'

@hash = Hash.new(0)

$total_hits = get_json(0, 1, $loc)['hits']['total']

$i = 0
until $i > $total_hits do
  $i += $chunk
  
  $data = get_json($i, $chunk, $loc)['hits']['hits']
  for $elem in $data
    @hash[$elem['_source']['user_agent']] += 1
  end
  f = File.open('blah.asdf', "w")
  @hash.each do |ua, count|
    f.write("#{ua}: #{count}\n")
  end
  f.close()
end
