#! /usr/bin/env python
#coding: utf-8

import sys, os

try:
    import readline
except ImportError:
    print "Module readline not available."
else:
    import rlcompleter
    readline.parse_and_bind("tab: complete")
