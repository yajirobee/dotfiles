#! /usr/bin/env python
#coding: utf-8

import sys, os

try:
    import readline
except ImportError:
    sys.stdout.write("Module readline not available.\n")
else:
    import rlcompleter
    readline.parse_and_bind("tab: complete")
