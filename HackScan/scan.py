#!/usr/bin/env python

from sys import *
import subprocess, os
import ConfigParser
import urllib2
import re
 
# Get the total number of args passed to the demo.py
total = len(argv)
 
# Get the arguments list 
cmdargs = str(argv)

sites = [
  "www.imperialselect.co.za",
  "www.saaad.co.za/demo/index.php"
  ]

for site in sites:
  response = urllib2.urlopen(("http://" + site))
  html = response.read()
  rex = '<!--\w*--><script type="text\/javascript" src="http:\/\/\w*.\w*\/\w*.php?id=\w*"><\/script><!--\/\w*-->'
  rex = '<!--\w*--><script type="text\/javascript" src="http:\/\/\w*.\w*\/\w*.php\?id=\w*"><\/script><!--\/\w*-->'
  m = re.search(rex, html)
  if m:
      print site + " has been HACKED!"
