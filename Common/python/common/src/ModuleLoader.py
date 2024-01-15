#
# ModuleLoader.py
#
# Description :
# --------------------------------------
# Module loader
#
#
#
# Copyright (c) 2022 Nexttop (nexttop.se)
#---------------------------------------
import sys
import os

sys.path.insert(0, os.path.dirname(os.getcwd()))

import urllib
import importlib

from nxLogger.nxLogger import nxLogger
from nxTracer.nxTracer import nxTracer
from nxTracer.nxTracer import colors

class ModuleLoader(nxTracer):
	"""
	A Class to load external modules.
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
		@__loadModule
		@__reloadModule
		@__getInstance		3 functions to load modules if they have not been loaded

		:parameter
			:param		moduleName / string
			:param		[param1 / string]

		:return		module/[instance of module]
	"""
	def loadModule(self,moduleName):
		self.DEBUG(moduleName)
		module = None
		try:
			#import sys
			del sys.modules[moduleName]
		except BaseException as err:
			pass
		try:
			#import importlib
			self.DEBUG(moduleName)
			module = importlib.import_module(moduleName)
		except BaseException as err:
			serr = str(err)
			self.ERROR("Error to load the module '" + str(moduleName) + "': " + serr)
		return module

	def reloadModule(self,moduleName):
		self.DEBUG(moduleName)
		module = self.loadModule(moduleName)
		if module != None:
			moduleName, modulePath = str(module).replace("' from '", "||").replace("<module '", '').replace("'>", '').split("||")
			self.DEBUG("%s - %s " % (moduleName,modulePath))
			if (modulePath.endswith(".pyc")):
				#import os
				#os.remove(modulePath)
				module = self.loadModule(moduleName)
		return module

	def getInstance(self,moduleName,modulePath = '',reloadexistingmodule = False):
		self.DEBUG("%s.%s" % (modulePath,moduleName))

		modulePerfix = ''
		if modulePath != '':
			modulePerfix = modulePath + '.'

		# unload the module if it's already loaded
		if moduleName in sys.modules and reloadexistingmodule == True:
			self.DEBUG("unloadModule %s" % (moduleName))
			self.unloadModule(moduleName)

		if moduleName not in sys.modules:
			self.DEBUG("moduleName %s is not in sys.modules" % (moduleName))
			module = self.reloadModule(modulePerfix + moduleName)
			if module != None:
				instance = eval("module." + moduleName + "()")
				return instance
		else:
			self.DEBUG("moduleName %s is already added to sys.modules" % (moduleName))
			module = sys.modules[moduleName]
			if module != None:
				instance = eval("module." + moduleName + "()")
				return instance
		return None

	def unloadModule(self,moduleName):
		self.DEBUG(moduleName)
		if moduleName in sys.modules:
			self.DEBUG("Module %s was unloaded" % (moduleName))
			del sys.modules[moduleName]
