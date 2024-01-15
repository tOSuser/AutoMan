#
# AddonsManager.py
#
# Description :
# --------------------------------------
# Python common addons manager
#
#
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
import sys
import os

sys.path.insert(0, os.path.dirname(os.getcwd()))

if sys.version_info[0] < 3:
	# 2.7
	import urlparse as uniurlparse
else:
	# > 3
	import urllib.parse as uniurlparse

import urllib
import importlib
import timeit

from nxLogger.nxLogger import nxLogger
from nxTracer.nxTracer import nxTracer
from nxTracer.nxTracer import colors
from ModuleLoader import ModuleLoader

class AddonsManager(ModuleLoader):
	"""
	Python common addons manager class.
		-
		-
	"""

	AddonsClaseList = []
	AddonsClaseInstanceList = []
	addonsPath = ''

	AID_SIGNATURE = 0
	AID_NAME = 1
	AID_TAGLIST = 2
	AID_TAGACTIONSYNTAX = 0
	AID_TAGACTIONARGS = 1
	AID_OPTIONALARGS = 2
	AID_TAGACTIONHELP = 3

	"""
		@_isModuleLoaded		Check a module is already loaded

		:parameter
			:param		modulename / string
		:return		none
	"""
	def _isModuleLoaded(self,modulename):
		for addonmodule in self.AddonsClaseInstanceList:
			if addonmodule.__modulename__ == modulename:
				return self.AddonsClaseInstanceList.index(addonmodule)
		return -1

	"""
		@_removeModuleLoaded		remove a module it it's already loaded

		:parameter
			:param		modulename / string
		:return		none
	"""
	def _removeModuleLoaded(self,modulename):
		for addonmodule in self.AddonsClaseInstanceList:
			if addonmodule.__modulename__ == modulename:
				self.unloadModule(modulename)
				self.AddonsClaseInstanceList.remove(addonmodule)
				return True
		return False

	"""
		@_loadModules		Modules Initialaizer

		:parameter
			:param		reloadexistingmodule / boolean
			:param		api / dict of api instances
		:return		none
	"""
	def _loadModules(self,reloadexistingmodule = False,api = {}):
		self.DEBUG(self.addonsSignature)
		for modulename in self.AddonsClaseList:
			self.DEBUG("modulename : %s" % (modulename))

			existingmoduleindex = self._isModuleLoaded(modulename)
			if existingmoduleindex != -1 and reloadexistingmodule == False:
				continue

			moduleinstance = self.getInstance(modulename,self.addonsPath,reloadexistingmodule)
			if moduleinstance != None:
				try :
					if (hasattr(moduleinstance, 'addonid')
							and moduleinstance.addonid[self.AID_SIGNATURE] == self.addonsSignature):
						self.DEBUG("module internal name : %s" % (moduleinstance.addonid[self.AID_NAME]))
						moduleinstance.__modulename__ = modulename

						if existingmoduleindex == -1:
							self.AddonsClaseInstanceList.append(moduleinstance)
						else:
							self.DEBUG("modulename %s has already loaded!" % (modulename))
							self.AddonsClaseInstanceList[existingmoduleindex] = moduleinstance

						moduleinstance.initAddon(api)
					else :
						self.unloadModule(modulename)
				except BaseException as err:
					serr = str(err)
					self.DEBUG("Error to check the module '" + str(modulename) + "': " + serr)
					self.unloadModule(modulename)
			else:
				self.ERROR("Can't Load %s" % (modulename))

		self.DEBUG("%d modules were loaded" % (len(self.AddonsClaseInstanceList)))

	"""
		@__init__		Initialaizer / constractor

		:parameter
			:param		addonkey / string
			:param		defaultsettings / dict
		:return		none
	"""
	def __init__(self,addonsignatur = 'general',
		defaultsettings = {'addonsfolder' : '','addonslist' : ''},
		api = {}):
		self.DEBUG(str(self))

		self.AddonsClaseInstanceList = []
		self.DEBUG("%d modules have already loaded" % (len(self.AddonsClaseInstanceList)))

		sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
		self.currentpath = os.path.dirname(os.path.abspath(__file__)) + '/'

		self.addonsSignature = addonsignatur
		if 'addonslist' in defaultsettings:
			self.AddonsClaseList = defaultsettings['addonslist']

		if 'addonsfolder' in defaultsettings:
			self.addonsPath = defaultsettings['addonsfolder']

		self._loadModules(False,api)

	"""
		@__del__		deconstractor

		:parameter		none
		:return		none
	"""
	def __del__(self):
		self.DEBUG("",True)

	"""
		@getTagsList		Check a module has a tag

		:parameter		none
		:return		list
	"""
	def getTagsList(self):
		self.DEBUG()
		tagList = {}
		for addonmodule in self.AddonsClaseInstanceList:
			for moduletags in addonmodule.addonid[self.AID_TAGLIST]:
				tagList[moduletags[self.AID_TAGACTIONSYNTAX]] = [moduletags[self.AID_TAGACTIONARGS],moduletags[self.AID_TAGACTIONHELP]]
		return tagList

	"""
		@isModuleHasTag		Check a module has a tag

		:parameter
			:param		addonsmodule / object
			:param		tag / string
		:return		bool
	"""
	def isModuleHasTag(self,addonmodule, tag):
		self.DEBUG()
		for moduletag in addonmodule.addonid[self.AID_TAGLIST]:
			if tag in moduletag:
				return True
		return False

	"""
		@isTagRegistered		Check a module has been registered for a tag

		:parameter
			:param		tag / string

		:return		bool
	"""
	def isTagRegistered(self,tag):
		self.DEBUG(tag)
		for addonmodule in self.AddonsClaseInstanceList:
			if self.isModuleHasTag(addonmodule,tag) == True:
				return True
		return False

	"""
		@runTagAction		run the action for a tag

		:parameter
			:param		tag / string
			:param		parameters / dict
			:param		api / dict of api instances
		:return		bool
	"""
	def runTagAction(self,tag,parameters = {},api = {}):
		self.DEBUG(tag)
		runTagActionResult = [False,{}]
		for addonmodule in self.AddonsClaseInstanceList:
			if self.isModuleHasTag(addonmodule,tag) == True:
				runTagActionResult =  [True,addonmodule.runTagAction(tag,parameters,api)]
		return runTagActionResult
