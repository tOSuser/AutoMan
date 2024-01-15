#
# ShTransformer.py
#
# Description :
# --------------------------------------
# Bash scripts files (sh, shinc) transformer for BinBuilder.
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

from TransformerBase import TransformerBase

class ShTransformer(TransformerBase):
	"""
	Sh Transformer BinBuilder.
		-
		-
	"""
	addonid = ['transformer', 'ShTransformer',
		[['.sh',[],[],'html file copier'],
		['.shinc',[],[],'shinc file copier'],
		['.ccrcmd',[],[],'ccrcmd file copier'],
		['.ucmd',[],[],'ucmd file copier'],
		['.runner',[],[],'runner file copier'],
		['.env',[],[],'env file copier']]
		]

	CP_SRC = 'src'
	CP_DEST = 'dest'
	CP_TMODE = 'tmode'

	TM_PRODUCT = 0
	TM_DEVELOP = 1
	"""
		@initAddon		Initialaize the addons

		:parameter	none
		:return		none
	"""
	def initAddon(self,api = {}):
		self.DEBUG()

	"""
		@hasTag		Check a tag

		:parameter
			:param		tag / string

		:return		bool
	"""
	def hasTag(self,tag):
		self.DEBUG()
		for registeredtag in self.addonid[self.AID_TAGLIST]:
			if tag in registeredtag:
				return True
		return False

	"""
		@runTagAction		run the action for a tag

		:parameter
			:param		cmd / string
			:param		parameters / dict

		:return		dict
	"""
	def runTagAction(self,tag,parameters = {},api = {}):
		self.DEBUG()
		runTagActionResult = False
		if self.hasTag(tag):
			if (self.CP_SRC in parameters and self.CP_DEST in parameters):
				copyResult = self.copyFile(parameters[self.CP_SRC],parameters[self.CP_DEST])
				runTagActionResult = copyResult
		return runTagActionResult
