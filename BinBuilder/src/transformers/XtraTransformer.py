#
# XtraTransformer.py
#
# Description :
# --------------------------------------
# A programable file transformer for BinBuilder.
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

class XtraTransformer(TransformerBase):
	"""
	A programable file transformer for BinBuilder.
		The addon reads files' types defined in a configuration file
		named '.transformer' placed in the root of the project alongside '.sourcepaths'
		-
		-
	"""
	addonid = ['transformer', 'XtraTransformer',
		[]
		]

	CP_SRC = 'src'
	CP_DEST = 'dest'
	CP_TMODE = 'tmode'

	TM_PRODUCT = 0
	TM_DEVELOP = 1

	projectHelperIFId = 'ProjectHelperIF'
	configFile = '.transformer'

	"""
		@initAddon		Initialaize the addons

		:parameter	none
		:return		none
	"""
	def initAddon(self,api = {}):
		self.DEBUG()
		if self.projectHelperIFId in api:
			projectPathRoot = api[self.projectHelperIFId].getProjectRoot()
			filetypes_conf = projectPathRoot + self.configFile
			self.DEBUG(filetypes_conf)
			if os.path.exists(filetypes_conf) == True:
				try :
					frcontent = open(filetypes_conf, "rb")
					fileTypes = eval(frcontent.read())
					self.DEBUG(fileTypes)
					frcontent.close()
					for ftype in fileTypes:
						self.addonid[2].append(['.' + ftype,[],[],ftype + ' file copier'])
				except Exception as e:
					print(str(e))

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
