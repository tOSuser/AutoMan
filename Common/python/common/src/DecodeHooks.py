#
# DecodeHooks.py
#
# Description :
# --------------------------------------
# Decode hooks used by json.load and json.loads
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
import os
import sys

sys.path.insert(0, os.path.dirname(os.getcwd()))

from nxLogger.nxLogger import nxLogger
from nxTracer.nxTracer import nxTracer
from nxTracer.nxTracer import colors

# DecodeHooks
#---------------------------------------
class DecodeHooks(nxTracer):
	"""
	Decode hooks.
	  -
	  -
	"""

	"""
		@hook functions to decode from unicode
	"""
	def _decode_list(self,data):
		rv = []
		if sys.version_info[0] < 3:
			# 2.7
			for item in data:
				if isinstance(item, unicode):
					item = item.encode('utf-8')
				elif isinstance(item, list):
					item = self._decode_list(item)
				elif isinstance(item, dict):
					item = self._decode_dict(item)
				rv.append(item)
		else:
			# > 3
			for item in data:
				if isinstance(item, bytes):
					item = item.encode('utf-8')
				elif isinstance(item, list):
					item = self._decode_list(item)
				elif isinstance(item, dict):
					item = self._decode_dict(item)
				rv.append(item)
		return rv

	def _decode_dict(self,data):
		rv = {}
		if sys.version_info[0] < 3:
			# 2.7
			for key, value in data.iteritems():
				if isinstance(key, unicode):
					key = key.encode('utf-8')
				if isinstance(value, unicode):
					value = value.encode('utf-8')
				elif isinstance(value, list):
					value = self._decode_list(value)
				elif isinstance(value, dict):
					value = self._decode_dict(value)
				rv[key] = value
		else:
			# > 3
			for key, value in data.items():
				if isinstance(key, bytes):
					key = key.encode('utf-8')
				if isinstance(value, bytes):
					value = value.encode('utf-8')
				elif isinstance(value, list):
					value = self._decode_list(value)
				elif isinstance(value, dict):
					value = self._decode_dict(value)
				rv[key] = value
		return rv
