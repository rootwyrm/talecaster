#!/usr/bin/env python2.7
#
# This code is shamelessly lifted from sickrage/lib/helpers.py
# authored by SickRage - http://sickrage.github.io/

import time
import random
import datetime

def generateApiKey():
	""" Return a new randomized API_KEY"""

	try:
		from hashlib import md5
	except ImportError:
		from md5 import md5

	# Create a seed
	t = str(time.time())
	r = str(random.random())

	# Create MD5 instance seeded with current time
	m = md5(t)
	# Now add salt with random
	m.update(r)

	# Return a hex digest of the MD5
	return m.hexdigest()

print "New API Key: %s" % generateApiKey()
