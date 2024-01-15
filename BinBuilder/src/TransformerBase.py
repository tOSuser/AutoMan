#
# TransformerBase.py
#
# Description :
# --------------------------------------
# A base class for AddonsManager addons.
#
#
# Copyright (c) 2022 Nexttop (nexttop.se)
#---------------------------------------
import sys
import os

import shutil

from nxLogger.nxLogger import nxLogger
from nxTracer.nxTracer import nxTracer
from nxTracer.nxTracer import colors

from AddonBase import AddonBase

class TransformerBase(AddonBase):
	"""
	Transformer base.
		-
		-
	"""

	"""
		@__init__		Initialaizer / constractor

		:parameter		none
		:return		none
	"""
	def __init__(self):
		self.DEBUG()

	"""
		@__del__		deconstractor

		:parameter		none
		:return		none
	"""
	def __del__(self):
		self.DEBUG("",True)


	"""
		@copyFile		copy a file by giving source and destination

		:parameter
			:param		source / string
			:param		destination / string
		:return		boolean
	"""
	def copyFile(self,source,destination):
		self.DEBUG(source+'->'+destination)
		try:
			shutil.copyfile(source, destination)
		except BaseException as err:
			serr = str(err)
			self.ERROR("copyfile : " + serr)
			return False

		return True