#!/bin/bash
my_ip=$(hostname -I | cut -d ' ' -f 1)

curl -X POST "${my_ip}:5601/api/data_views/data_view" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "data_view": {
     "title": "metricbeat-8.5.0-*",
     "name": "My MetricBeat view"
  }
}'
