#!/usr/bin/env python

import simplejson
import urllib2
from pprint import pprint

req = urllib2.Request('https://api.twitter.com/1/trends/1.json')
opener = urllib2.build_opener()
f = opener.open(req)

json = simplejson.load(f)

#print simplejson.dumps(json, indent=1)

trends = [trend['name'] for trend in json[0]['trends']]
pprint(trends)