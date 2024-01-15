#
# AddonBase.py
#
# Description :
# --------------------------------------
# A base class for python common AddonsManager addons.
#
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
import sys
import os

sys.path.insert(0, os.path.dirname(os.getcwd()))

from nxLogger.nxLogger import nxLogger
from nxTracer.nxTracer import nxTracer
from nxTracer.nxTracer import colors

class AddonBase(nxTracer):
	"""
	Addon base.
		-
		-
	"""
	AID_SIGNATURE = 0
	AID_NAME = 1
	AID_TAGLIST = 2
	AID_TAGACTIONSYNTAX = 0
	AID_TAGACTIONARGS = 1
	AID_OPTIONALARGS = 2
	AID_TAGACTIONHELP = 3

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

