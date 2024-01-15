#
# TestAddonsManager.py
#
# Description :
# --------------------------------------
# Python common Addons Manager unittests
#
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
import sys
import os
from unittest import main, TestCase,runner

patchstr_builtins = '__builtin__.open'
if sys.version_info[0] < 3:
	# 2.7
	from mock import patch, MagicMock, mock_open
	from BaseHTTPServer import HTTPServer,BaseHTTPRequestHandler
	import urllib2 as urllib
	import mysql.connector as unimysql
	patchstr_builtins = '__builtin__.open'
else:
	# > 3
	from unittest.mock import patch, MagicMock, mock_open
	from http.server import HTTPServer,BaseHTTPRequestHandler
	import urllib.request as urllib
	import pymysql as unimysql
	import builtins
	patchstr_builtins = 'builtins.open'

import logging
from datetime import datetime
import sqlite3
import json

from nxLogger.nxLogger import nxLogger
from nxEncoder.nxEncoder import nxEncoder
from nxTracer.nxTracer import nxTracer
from nxTracer.nxTracer import colors

from TestHelper import TestHelper
from TestHelper import FakePrint
from TestHelper import FakeURL
from TestHelper import FakeFile
from TestHelper import FakeError
from TestHelper import Fakesqlite3

from AddonsManager import AddonsManager

from ModuleLoader import ModuleLoader

class FakeModule(TestHelper):
	def __init__(self,validmodule = True,modulename = 'noname',modulesignature = 'general'):
		self.DEBUG()
		if validmodule == True:
			self.addonid = [modulesignature, modulename,[["tag_"+modulename,[],[],'info']]]

	def initAddon(self,api = {}):
		self.DEBUG(self.addonid[1])

	def runTagAction(self,tag,parameters = '',api = {}):
		self.DEBUG(self.addonid[1] + " : " + tag)
		return {}

# TestAddonsManager : Unit tests
#---------------------------------------
class TestAddonsManager(TestCase,TestHelper):
	"""
	Addons manager unittest.
		-
		-
	"""
	addonsignatur = 'general'
	defaultsettings = {
		'addonsfolder' : '',
		'addonslist' : ['validmodule1st','validmodule2nd','wrongsigmodule','invalidmodule','validmodule2nd']}

	"""
		@setUp

		:parameter  none
		:return		none
	"""
	@patch('os.path.exists')
	def setUp(self,mock_exists):
		self.INFO("\n[RUN TEST]",False)
		exists_side_effect_status = True

		def exists_side_effect(dirpath):
			self.DEBUG()
			self.DEBUG("\nos.path.exists\n dirpath : %s " % (dirpath))
			return exists_side_effect_status

		mock_exists.side_effect = exists_side_effect

		myfakesqlite3 = Fakesqlite3()
		sqlite3.connect = myfakesqlite3.connect

		ModuleLoader.getInstance = MagicMock(side_effect=[
			FakeModule(True,'validmodule1st'),
			FakeModule(True,'validmodule2nd'),
			FakeModule(True,'wrongsigmodule','unknown'),
			FakeModule(False,'invalidmodule'),
			FakeModule(True,'validmodule2nd')])
		ModuleLoader.unloadModule = MagicMock()

		self.myaddonsmanager = AddonsManager(self.addonsignatur,self.defaultsettings)

		self.assertEqual(ModuleLoader.getInstance.call_count,4)
		self.assertEqual(ModuleLoader.unloadModule.call_count,2)

		self.assertEqual(len(self.myaddonsmanager.AddonsClaseInstanceList),2)

	"""
		@tearDown

		:parameter  none
		:return		none
	"""
	def tearDown(self):
		self.INFO("\n[END TEST]",False)

	# test_isModuleLoaded
	def test_isModuleLoaded(self):
		self.assertTrue(self.myaddonsmanager._isModuleLoaded('validmodule1st') > -1)
		self.assertEqual(self.myaddonsmanager._isModuleLoaded('invalidmodule'),-1)

	#test_removeModuleLoaded
	def test_removeModuleLoaded(self):
		self.assertEqual(self.myaddonsmanager._removeModuleLoaded('unknownmodule'),False)
		self.assertEqual(self.myaddonsmanager._removeModuleLoaded('validmodule2nd'),True)

	# test_getTagsList
	def test_getTagsList(self):
		self.assertEqual(self.myaddonsmanager.getTagsList(),{'tag_validmodule1st': [[], 'info'], 'tag_validmodule2nd': [[], 'info']})
		self.assertEqual(len(self.myaddonsmanager.getTagsList()),2)

	# test_isModuleHasTag
	def test_isModuleHasTag(self):
		self.assertEqual(self.myaddonsmanager.isModuleHasTag(self.myaddonsmanager.AddonsClaseInstanceList[0],'tag_validmodule1st'),True)
		self.assertEqual(self.myaddonsmanager.isModuleHasTag(self.myaddonsmanager.AddonsClaseInstanceList[0],'tag_validmodule2nd'),False)

	# test_runTagAction
	def test_runTagAction(self):
		self.assertEqual(self.myaddonsmanager.runTagAction('invalidtag'),[False,{}])
		self.assertEqual(self.myaddonsmanager.runTagAction('tag_validmodule1st'),[True,{}])


# Main
#---------------------------------------
if __name__ == '__main__':
	if len(sys.argv) > 1:
		if sys.argv[1].lower() == '-info':
			logging.basicConfig(stream=sys.stdout, level=logging.INFO)
		elif sys.argv[1].lower() == '-debug':
			logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
		else:
			logging.basicConfig(stream=sys.stdout, level=logging.CRITICAL)

	test_result = main(argv=[''],verbosity=2, exit=False).result
	#<unittest.runner.TextTestResult run= errors= failures=>
	#test_result.errors
	#test_result.failures
	if len(test_result.errors) > 0 or len(test_result.failures) > 0:
		exit(1)
else:
	logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)