#
# JsTransformer.py
#
# Description :
# --------------------------------------
# Js/Ts file transformer for BinBuilder.
#
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
import sys
import os

sys.path.insert(0, os.path.dirname(os.getcwd()))

import re

from nxLogger.nxLogger import nxLogger
from nxTracer.nxTracer import nxTracer
from nxTracer.nxTracer import colors

from TransformerBase import TransformerBase

class JsTransformer(TransformerBase):
	"""
	Js/Ts/jsx Transformer BinBuilder.
		-
		-
	"""
	addonid = ['transformer', 'JsTransformer',
		[['.js',[],[],'js file transformer'],
		['.ts',[],[],'ts file transformer'],
		['.jsx',[],[],'jsx file transformer']]
		]

	CP_SRC = 'src'
	CP_DEST = 'dest'
	CP_TMODE = 'tmode'

	TM_PRODUCT = 0
	TM_DEVELOP = 1

	logStrings = ['DEBUG','INFO']

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
		@transformString		transform a string by giving string

		:parameter
			:param		linestr / string

		:return		boolean
	"""
	def transformString(self,linestr):
		self.DEBUG()
		currentLine = linestr
		for transformItem in self.logStrings:
			regexMatcherStr = "[a-zA-Z]?[a-zA-Z|0-9]+[.]" + transformItem + "[ ]*[(]{1}[^;]*[)]{1}[ ]*;{1}"
			while True:
				matchedResult = re.search(regexMatcherStr, currentLine)
				if matchedResult == None:
					break
				currentLine = currentLine.replace(matchedResult.group(),'')

		return currentLine

	"""
		@transformFile		transform a file by giving source and destination

		:parameter
			:param		source / string
			:param		destination / string

		:return		boolean
	"""
	def transformFile(self,source,destination):
		self.DEBUG()
		resulttext = ""
		if (os.path.exists(source) == True and  os.path.exists(destination) == False):
			rFile = open(source,"r")
			wFile = open(destination,"w")
			lines = rFile.readlines()
			for line in lines:
				line = self.transformString(line)
				if (len(line.replace(' ','')) != 0):
					wFile.write(line)
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
				if (self.CP_TMODE in parameters and parameters[self.CP_TMODE] == self.TM_PRODUCT ):
					copyResult = self.transformFile(parameters[self.CP_SRC],parameters[self.CP_DEST])
				else:
					copyResult = self.copyFile(parameters[self.CP_SRC],parameters[self.CP_DEST])
				runTagActionResult = copyResult
		return runTagActionResult
