import urllib2
import json

entries = 10000

h = {}

url = 'http://logs.moov.sh:9200/logstash-2014.03.09/_search?from=0&size=1&q=type:"varnish"%20AND%20geoip.country_name:"United%20Kingdom"%20AND%20resp_code:"200"%20AND%20req_method:"GET"'

r = urllib2.urlopen(url)
j = json.loads(r.read())
total_hits = j['hits']['total']

for i in xrange(0, total_hits, entries):
  print "Loading index: " + str(i)
  
  url = 'http://logs.moov.sh:9200/logstash-2014.03.09/_search?from='+str(i)+'&size='+str(entries)+'&q=type:"varnish"%20AND%20geoip.country_name:"United%20Kingdom"%20AND%20resp_code:"200"%20AND%20req_method:"GET"'
  r = urllib2.urlopen(url)
  j = json.loads(r.read())
  
  print "Loaded: "+str(i + entries) + "/" + str(total_hits)
  
  for i in j['hits']['hits']:
    hit = i['_source']
    if 'user_agent' in hit.keys():
      ua = hit['user_agent']      
      try:
        h[ua] += 1
      except KeyError:
        h[ua] = 1
  
  with open('useragent_eu.bin', 'w') as f:
    f.write("USER_AGENT: NUMBER\n")
    for k,v in h.items():
      f.write(k.encode('utf-8') + ': '.encode('utf-8') + str(v).encode('utf-8') + '\n'.encode('utf-8'))
