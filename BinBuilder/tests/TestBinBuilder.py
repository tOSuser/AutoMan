#
# TestBinBuilder.py
#
# Description :
# --------------------------------------
# Bin Builder unittests
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
import shutil

from nxLogger.nxLogger import nxLogger
from nxTracer.nxTracer import nxTracer
from nxTracer.nxTracer import colors

from TestHelper import TestHelper
from TestHelper import FakePrint
from TestHelper import FakeURL
from TestHelper import FakeFile
from TestHelper import FakeError
from TestHelper import Fakesqlite3

from BinBuilder import BinBuilder
from ModuleLoader import ModuleLoader

class FakeModule(TestHelper):
	def __init__(self,validmodule = True,modulename = 'noname',tag = '.tag',modulesignature = 'transformer'):
		self.DEBUG()
		if validmodule == True:
			self.addonid = [modulesignature, modulename,[[("tag_" + modulename if tag == '.tag' else tag),[],[],'info']]]

	def initAddon(self,api = {}):
		self.DEBUG(self.addonid[1])

	def runTagAction(self,tag,parameters = {},api = {}):
		self.DEBUG(self.addonid[1] + " : " + tag + "," + parameters['src']+ "," + parameters['dest'])
		return True

# TestBinBuilder : Unit tests
#---------------------------------------
class TestBinBuilder(TestCase,TestHelper):
	"""
	Addons Template unittest.
		-
		-
	"""
	verboseMode = False
	rawMode = False

	addonsignatur = 'transformer'
	defaultsettings = {
		'addonsfolder' : '',
		'addonslist' : ['jstransformer','tstransformer','wrongsigtransformer','invalidtransformer']}

	sourcepaths = ["path1",["path2","dest1"],"path3","path4"]

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

		ModuleLoader.getInstance = MagicMock(side_effect=[
			FakeModule(True,'jstransformer','.js'),
			FakeModule(True,'tstransformer','.ts'),
			FakeModule(True,'wrongsigtransformer','.php','unknown'),
			FakeModule(False,'invalidtransformer','.json')])
		ModuleLoader.unloadModule = MagicMock()

		sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
		currentPath = os.path.dirname(os.path.abspath(__file__)) + '/'
		originalPath = os.path.dirname(os.path.abspath(os.path.realpath(currentPath+__file__))) + '/'

		self.mybinbuilder  = BinBuilder(originalPath,currentPath,self.defaultsettings,self.verboseMode,self.rawMode)
		src_paths_conf = currentPath + '.sourcepaths'

		self.assertEqual(ModuleLoader.getInstance.call_count,4)
		self.assertEqual(ModuleLoader.unloadModule.call_count,2)

		self.assertEqual(len(self.mybinbuilder.myaddonsmanager.AddonsClaseInstanceList),2)

		self.assertEqual(self.mybinbuilder.myaddonsmanager.isTagRegistered('.js'),True)
		self.assertEqual(self.mybinbuilder.myaddonsmanager.isTagRegistered('.invalid'),False)
	
	"""
		@tearDown

		:parameter  none
		:return		none
	"""
	def tearDown(self):
		self.INFO("\n[END TEST]",False)

	# test_compileFiles
	@patch('os.path.isdir')
	@patch('compileall.compile_dir')
	def test_compileFiles(self,mock_compile_dir,mock_isdir):
		compile_dir_side_effect_status = True
		isdir_side_effect_status = True
		def compile_dir_side_effect(*args, **kwargs):
			self.DEBUG("compileall.compile_dir")
			return compile_dir_side_effect_status

		def isdir_side_effect(dirpath):
			self.DEBUG()
			self.DEBUG("\nos.path.isdir\n dirpath : %s " % (dirpath))
			return isdir_side_effect_status

		mock_compile_dir.side_effect = compile_dir_side_effect
		mock_isdir.side_effect = isdir_side_effect

		compile_dir_side_effect_status = True
		self.assertEqual(self.mybinbuilder.compileFiles('current_path',['source']),True)
		self.assertEqual(self.mybinbuilder.compileFiles('current_path',[['source','destination']]),True)

		compile_dir_side_effect_status = False
		self.assertEqual(self.mybinbuilder.compileFiles('current_path',['source']),False)

	# test_transformFile
	@patch('shutil.copyfile')
	def test_transformFile(self,mock_copyfile):
		def copyfile_side_effect(sourcepath,targetpath):
			self.DEBUG()
			self.DEBUG("\nshutil.copyfile\n sourcepath : %s, targetpath : %s " % (sourcepath,targetpath))

		mock_copyfile.side_effect = copyfile_side_effect

		self.assertEqual(self.mybinbuilder.transformFile('.js','current_path','build_path'),True)
		self.assertEqual(self.mybinbuilder.transformFile('.ts','current_path','build_path'),True)
		self.assertEqual(self.mybinbuilder.transformFile('.java','current_path','build_path'),False)

	# test_moveToNewLocation
	@patch('shutil.copyfile')
	@patch('os.makedirs')
	@patch('os.rename')
	@patch('os.path.isdir')
	@patch('os.listdir')
	@patch('os.path.exists')
	def test_moveToNewLocation(self,mock_exists,mock_listdir,mock_isdir,mock_rename,mock_makedirs,mock_copyfile):
		exists_side_effect_status = True
		isdir_side_effect_status = False

		def exists_side_effect(dirpath):
			self.DEBUG()
			self.DEBUG("\nos.path.exists\n dirpath : %s " % (dirpath))
			return exists_side_effect_status

		def listdir_side_effect(dirpath):
			self.DEBUG()
			self.DEBUG("\nos.listdir\n dirpath : %s " % (dirpath))
			return ['myfile.xxx','myfile.js']

		def isdir_side_effect(dirpath):
			self.DEBUG()
			self.DEBUG("\nos.path.isdir\n dirpath : %s " % (dirpath))
			return isdir_side_effect_status

		def rename_side_effect(sourcepath,targetpath):
			self.DEBUG()
			self.DEBUG("\nos.rename\n sourcepath : %s, targetpath : %s " % (sourcepath,targetpath))

		def makedirs_side_effect(dirpath):
			self.DEBUG()
			self.DEBUG("\nos.makedirs\n dirpath : %s " % (dirpath))

		mock_exists.side_effect = exists_side_effect
		mock_listdir.side_effect = listdir_side_effect
		mock_isdir.side_effect = isdir_side_effect
		mock_rename.side_effect = rename_side_effect
		mock_makedirs.side_effect = makedirs_side_effect

		def copyfile_side_effect(sourcepath,targetpath):
			self.DEBUG()
			self.DEBUG("\nshutil.copyfile\n sourcepath : %s, targetpath : %s " % (sourcepath,targetpath))

		mock_copyfile.side_effect = copyfile_side_effect

		#self.assertEqual(self.mybinbuilder.moveToNewLocation('base_path','current_path','build_path'),True)
		self.mybinbuilder.moveToNewLocation('base_path','current_path','build_path')

	# test_run
	@patch('compileall.compile_dir')
	@patch('shutil.copyfile')
	@patch('os.makedirs')
	@patch('os.rename')
	@patch('os.path.isdir')
	@patch('os.listdir')
	@patch('os.path.exists')
	def test_run(self,mock_exists,mock_listdir,mock_isdir,mock_rename,mock_makedirs,mock_copyfile,mock_compile_dir):
		exists_side_effect_status = True
		self.isdir_side_effect_calls = 0
		isdir_side_effect_status = False
		compile_dir_side_effect_status = True

		def exists_side_effect(dirpath):
			self.DEBUG()
			self.DEBUG("\nos.path.exists\n dirpath : %s " % (dirpath))
			return exists_side_effect_status

		def listdir_side_effect(dirpath):
			self.DEBUG()
			self.DEBUG("\nos.listdir\n dirpath : %s " % (dirpath))
			return ['myfile.xxx','myfile.js']

		def isdir_side_effect(dirpath):
			self.DEBUG()
			self.DEBUG("\nos.path.isdir\n dirpath : %s " % (dirpath))
			self.isdir_side_effect_calls = self.isdir_side_effect_calls + 1
			if self.isdir_side_effect_calls == 1:
				return True
			return isdir_side_effect_status

		def rename_side_effect(sourcepath,targetpath):
			self.DEBUG()
			self.DEBUG("\nos.rename\n sourcepath : %s, targetpath : %s " % (sourcepath,targetpath))

		def makedirs_side_effect(dirpath):
			self.DEBUG()
			self.DEBUG("\nos.makedirs\n dirpath : %s " % (dirpath))

		def copyfile_side_effect(sourcepath,targetpath):
			self.DEBUG()
			self.DEBUG("\nshutil.copyfile\n sourcepath : %s, targetpath : %s " % (sourcepath,targetpath))

		def compile_dir_side_effect(*args, **kwargs):
			self.DEBUG("compileall.compile_dir")
			return compile_dir_side_effect_status

		mock_exists.side_effect = exists_side_effect
		mock_listdir.side_effect = listdir_side_effect
		mock_isdir.side_effect = isdir_side_effect
		mock_rename.side_effect = rename_side_effect
		mock_makedirs.side_effect = makedirs_side_effect
		mock_copyfile.side_effect = copyfile_side_effect
		mock_compile_dir.side_effect = compile_dir_side_effect

		compile_dir_side_effect_status = True
		self.assertEqual(self.mybinbuilder.run(self.sourcepaths),True)

		compile_dir_side_effect_status = False
		self.assertEqual(self.mybinbuilder.run(self.sourcepaths),False)


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