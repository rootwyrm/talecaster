# sitecustomize.py

# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com>
# 
# COMMERCIAL REDISTRIBUTION EXPRESSLY PROHIBITED

## TaleCaster sitecustomize.py for Alpine hosts
## Do not use for FreeBSD!

import site
import platform
import os
import sys

site_version = sys.version[:3]

path = os.path.join(os.path.sep, 'usr', 'local', 'lib', 'python'+site_version)
if os.path.exists(path): 
	site.addsitedir(path)

path = os.path.join(os.path.sep, 'usr', 'local', 'lib', 'python'+site_version, 'site-packages')
if os.path.exists(path): 
	site.addsitedir(path)

path = os.path.join(os.path.sep, 'opt', 'talecaster', 'lib', 'python'+site_version)
if os.path.exists(path): 
	site.addsitedir(path)

path = os.path.join(os.path.sep, 'opt', 'talecaster', 'lib', 'python'+site_version, 'site-packages')
if os.path.exists(path): 
	site.addsitedir(path)

path = os.path.join(os.path.sep, 'opt', 'lib', 'python'+site_version)
if os.path.exists(path): 
	site.addsitedir(path)

path = os.path.join(os.path.sep, 'opt', 'lib', 'python'+site_version, 'site-packages')
if os.path.exists(path): 
	site.addsitedir(path)

