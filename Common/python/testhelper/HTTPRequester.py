#
# httprequester.py
#
# Description :
# --------------------------------------
# A Class to prepare requests to send RESTful services.
#
#
# Copyright (c) 2022 Nexttop (nexttop.se)
#---------------------------------------

import sys
import os
import urllib

sys.path.insert(0, os.path.dirname(os.getcwd()))

if sys.version_info[0] < 3:
	# 2.7
	import urllib as uniurlilib
	import urlparse as uniurlparse
	import urllib2 as urllib
else:
	# > 3
	import urllib.parse as uniurlilib
	import urllib.parse as uniurlparse
	import urllib.request as urllib

import requests
import hmac
import hashlib

from nxTracer.nxTracer import nxTracer

class RequestType:
	RT_GET = 0
	RT_POST = 1
	RT_PUT = 2
	RT_DELETE = 3

class HTTPRequester(RequestType):
	"""
		@HTTPRequest		Make HTTP call

		:parameter
			:param		requesttype / GET,POST,PU,DELETE
			:param		url /full path included port
			:param		params / formated string
			:param		headers / array

		:return		string
	"""
	def HTTPRequest(self,requesttype, myurl, myparams, myheaders):
		try:
			if requesttype == RequestType.RT_POST:
				return requests.post(myurl, data=myparams, headers=myheaders, allow_redirects=False,verify=False)
			elif requesttype == RequestType.RT_GET:
				encodedpayload = uniurlilib.urlencode(myparams).encode('utf-8', 'strict').decode('latin-1')
				return requests.get(myurl+"?"+encodedpayload, data=myparams, headers=myheaders, allow_redirects=False, verify=False)
			"""
			elif requesttype == self.RT_PUT:
			elif requesttype == self.RT_DELETE:
			else:
			"""
		except Exception as e:
			self.ERROR(str(e))
		return None

	"""
		@HTTPGet		Make HTTP-GET call

		:parameter
			:param		url/full path included port
			:param		params / formated string
			:param 		headers / array

		:return		string
	"""
	def HTTPGet(self,url, params, headers):
		return self.HTTPRequest(RequestType.RT_GET, url, params, headers)

	"""
		@HTTPPost		Make HTTP-POST call

		:parameter
			:param		url/full path included port
			:param		params / formated string
			:param		headers / array

		:return		string
	"""
	def HTTPPost(self,url, params, headers):
		return self.HTTPRequest(RequestType.RT_POST, url, params, headers)

	"""
		@HTTPPut		Make HTTP-PUT call

		:parameter
			:param		url/full path included port
			:param		params / formated string
			:param		headers / array

		:return		string
	"""
	def HTTPPut(self,url, params, headers):
		return self.HTTPRequest(RequestType.RT_PUT, url, params, headers)

	"""
		@HTTPDelete		Make HTTP-DELETE call

		:parameter
			:param		url/full path included port
			:param		params / formated string
			:param		headers / array

		:return 		string
	"""
	def HTTPDelete(self,url, params, headers):
		return self.HTTPRequest(RequestType.RT_DELETE, url, params, headers)