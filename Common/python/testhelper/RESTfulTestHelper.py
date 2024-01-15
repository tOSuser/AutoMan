#
# RESTfulTestHelper.py
#
# Description :
# --------------------------------------
# A class to test RESTful services.
#
#
# Copyright (c) 2022 Nexttop (nexttop.se)
#---------------------------------------

import sys
import os

sys.path.insert(0, os.path.dirname(os.getcwd()))

import hmac
import hashlib

from HTTPRequester import HTTPRequester
from nxEncoder.nxEncoder import nxEncoder
from nxTracer.nxTracer import nxTracer
from nxTracer.nxTracer import colors

class RESTfulTestHelper(HTTPRequester,nxTracer):
	rest_addr = ""
	rest_token = ""
	rest_user = ""

	def __init__(self,rest_addr, rest_token,rest_user = ''):
		self.DEBUG("addr: %s,token: %s, user: %s" % (rest_addr,rest_token,rest_user))
		self.rest_addr = rest_addr
		self.rest_token = rest_token
		self.rest_user = rest_user

	"""
		@run		sends a get/post request

		:parameter
			:param		mypayload / string
			:param		format / string
			:param		method / RT_GET/RT_POST
			:param		uid / string

		:return		string
	"""
	def run(self,mypayload,format ,method = HTTPRequester.RT_POST,token = '',uid = ''):
		self.DEBUG("token: %s, uid: %s" % (token,uid))
		headers = None
		if (uid == 'None' or uid == ''):
			headers = {
				'TOKEN': token,
				'Content-type': 'application/x-www-form-urlencoded',
				'Accept': format,
			}
		else:
			headers = {
				'TOKEN': token,
				'UID': uid,
				'Content-type': 'application/x-www-form-urlencoded',
				'Accept': format,
			}

		if (method == HTTPRequester.RT_POST):
			return self.HTTPPost(self.rest_addr,mypayload,headers)
		elif (method == HTTPRequester.RT_GET):
			return self.HTTPGet(self.rest_addr,mypayload,headers)
		else:
			return "An unsupported requested method"
