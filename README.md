# Scripts to Download ES Data

<h2>The main scripts</h2>
* kib_to_csv.rb # gets 500 logs
  - usage ./es_to_csv.rb \<data>
* es_to_csv.rb # gets ALL logs (Make sure to remove size from the JSON!)
  - usage ./es_to_csv.rb \<data> 

Example data:
```
{
  "query": {
    "filtered": {
      "query": {
        "bool": {
          "should": [
            {
              "query_string": {
                "query": "type:\"moovworker\""
              }
            }
          ]
        }
      },
      "filter": {
        "bool": {
          "must": [
            {
              "range": {
                "@timestamp": {
                  "from": 1432078299029,
                  "to": 1432081899029
                }
              }
            }
          ]
        }
      }
    }
  },
  "highlight": {
    "fields": {},
    "fragment_size": 2147483647,
    "pre_tags": [
      "@start-highlight@"
    ],
    "post_tags": [
      "@end-highlight@"
    ]
  },
  "size": 500, //size to comment out
  "sort": [
    {
      "@timestamp": {
        "order": "asc",
        "ignore_unmapped": true
      }
    }
  ]
}
```
