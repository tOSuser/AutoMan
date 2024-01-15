#
# AddonTemplate.py
#
# Description :
# --------------------------------------
# Addon Template for Python common AddonsManager.
#
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
import sys
import os

sys.path.insert(0, os.path.dirname(os.getcwd()))

from nxLogger.nxLogger import nxLogger
from nxEncoder.nxEncoder import nxEncoder
from nxTracer.nxTracer import nxTracer
from nxTracer.nxTracer import colors

from AddonBase import AddonBase

class AddonTemplate(AddonBase):
	"""
	Addon Template for python common AddonsManager.
		-
		-
	"""
	addonid = ['general', 'template',
		[['tag',[],[],'tag action description']]
		]

	"""
		@initAddon		Initialaize the addons

		:parameter
			:param		api / dict
		:return		none
	"""
	def initAddon(self,api = {}):
		self.DEBUG()

	"""
		@runTagAction		run a tag action

		:parameter
			:param		tag / string
			:param		parameters / dict
			:param		api / dict
		:return		dict
	"""
	def runTagAction(self,tag,parameters = {},api = {}):
		return {}
