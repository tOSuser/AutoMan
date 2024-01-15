#
# nxEncoder.py
#
# Description :
# --------------------------------------
# nxEncoder class
#
#
# Copyright (c) 2021 Nexttop (nexttop.se)
#---------------------------------------

import sys
import os
import logging

sys.path.insert(0,os.path.dirname(os.getcwd()))

from nxLogger.nxLogger import nxLogger
from nxTracer.nxTracer import nxTracer

class nxEncoder(nxTracer):
	"""
	A set encoding and decoding methods
		-
		-
	"""
	def __init__(self):
		# nothing to do at this time
		pass

	"""
		@stringify		convert an object included list,map,set and dict to a formatted string

		:parameter
			:param		inobject    object included list,map,set and dict
			:param		itemconj/string
			:param		cellconj/string

		:return		string
	"""
	def stringify(self, inobject,itemconj,cellconj):
		self.DEBUG()
		objstr=""
		self.DEBUG(type(inobject))
		if (isinstance(inobject,dict)):
			for ikeys in list(inobject):
				self.DEBUG(ikeys)
				if (objstr!= ""):
					objstr+=itemconj
				objstr += ikeys.__str__() + cellconj+inobject[ikeys]
		elif (isinstance(inobject,set)):
			for iitem in inobject:
				self.DEBUG(iitem)
				if sys.version_info[0] < 3:
					# 2.7
					if (objstr!= ""):
						objstr+=itemconj
					objstr +=  iitem[0]+cellconj+iitem[1]
					self.DEBUG("ver 2 %s" % objstr)
				else:
					# 3.x
					if (objstr == ""):
						objstr =  iitem[0]+cellconj+iitem[1]
					else: 
						objstr =  iitem[0]+cellconj+iitem[1] + itemconj + objstr
					self.DEBUG("ver 3 %s" % objstr)
		elif (isinstance(inobject,list)):
			for iitem in inobject:
				if (objstr!= ""):
					objstr+=itemconj
				objstr +=  iitem[0]+cellconj+iitem[1]
		else:
			objstr = str(inobject)
		return objstr

	"""
		@encodeurlstr		encode an object to url parameters

		:parameter
			:param		inobject object included list,map,set and dict

		:return		string
	"""
	def encodeurlstr(self, inobject):
		self.DEBUG()
		return self.stringify(inobject,"&","=")
	"""
		@__del__		deconstractor

		:parameter	none

		:return		none
	"""
	def __del__(self):
		pass
