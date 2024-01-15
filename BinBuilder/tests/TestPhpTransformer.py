#
# TestPhpTransformer.py
#
# Description :
# --------------------------------------
# Php Transformer unittests
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

from nxLogger.nxLogger import nxLogger
from nxTracer.nxTracer import nxTracer
from nxTracer.nxTracer import colors

from TestHelper import TestHelper
from TestHelper import FakePrint
from TestHelper import FakeURL
from TestHelper import FakeFile
from TestHelper import FakeError
from TestHelper import Fakesqlite3

from AddonsManager import AddonsManager

from transformers.PhpTransformer import PhpTransformer

# TestPhpTransformer : Unit tests
#---------------------------------------
class TestPhpTransformer(TestCase,TestHelper):
	"""
	Php Transformer unittest.
		-
		-
	"""
	"""
		@setUp

		:parameter  none
		:return		none
	"""
	def setUp(self):
		self.INFO("\n[RUN TEST]",False)
		self.myPhpTransformer= PhpTransformer()

	"""
		@tearDown

		:parameter  none
		:return		none
	"""
	def tearDown(self):
		self.INFO("\n[END TEST]",False)

	# test_initAddons
	def test_initAddons(self):
		pass

	# test_runTagAction
	@patch('shutil.copyfile')
	def test_runTagAction(self,mock_copyfile):

		def copyfile_side_effect(sourcepath,targetpath):
			self.DEBUG()
			self.DEBUG("\nshutil.copyfile\n sourcepath : %s, targetpath : %s " % (sourcepath,targetpath))

		mock_copyfile.side_effect = copyfile_side_effect

		self.assertEqual(self.myPhpTransformer.runTagAction('invalidtag',{'src' : 'source_file','dest' : 'destination_file'}),False)
		self.assertEqual(self.myPhpTransformer.runTagAction('.php',{'src' : 'source_file','dest' : 'destination_file'}),True)

		myfakeerror_copyfile = FakeError("copy error")
		mock_copyfile.side_effect = myfakeerror_copyfile.genrateError
		self.assertEqual(self.myPhpTransformer.runTagAction('.php',{'src' : 'source_file','dest' : 'destination_file'}),False)

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