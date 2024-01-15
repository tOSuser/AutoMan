#
# TestJsTransformer.py
#
# Description :
# --------------------------------------
# Js/Ts Transformer unittests
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

from transformers.JsTransformer import JsTransformer

# TestJsTransformer : Unit tests
#---------------------------------------
class TestJsTransformer(TestCase,TestHelper):
	"""
	Js/Ts Transformer unittest.
		-
		-
	"""
	jsSourceCodeSample = """
		import { Injectable } from '@angular/core';

		/**
		 * @description
		 *  A simple typescript template class
		 *
		 */

		@Injectable()
		export class LibTemplate extends nxTracer{
		    private flag : boolean = true;

		    /**
		    *  @description
		    *   Class constructor
		    *
		    *  @param
		    *
		    *  @return
		    */
		  	constructor() {
		        super();this.DEBUG ( "after super ");
		    }

		    /**
		    *  @description
		    *   Get the current flag
		    *
		    *  @return      boolean
		    */
		    DEBUG() : boolean{
		        this.DEBUG();
		        this.INFO ("info") ;
		        return this.flag;
		    }
		}"""

	"""
		@setUp

		:parameter  none
		:return		none
	"""
	def setUp(self):
		self.INFO("\n[RUN TEST]",False)
		self.myJsTransformer= JsTransformer()

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

	# test_transformString
	def test_transformString(self):
		jsCorrectStatements = [
        	['super();this.DEBUG ( "after super ");','super();'],
	        ['this.DEBUG () ;',''],
	        ['this.DEBUG ("with multi item in, %s" % (a)) ;',''],
	        ['this.DEBUG ( "text "); ',' '],
	        ['1this.DEBUG ( "number before this.");',''],
	        ['111this.DEBUG ( "multi number befor this");',''],
	        ['exit();this.DEBUG("multi statements, after another statement");','exit();'],
	        ['this.DEBUG("multi statements, before another statement"); exit();',' exit();'],
	        ['this.DEBUG("multi statements, 2 DEBUGs in a line - 1"); this.DEBUG("multi statements, 2 DEBUGs in a line - 2");',' '],
	        ]

		jsWrongStatements = [
	        'this .DEBUG ("wrong syntax, no instance")',
	        'this.DEBUG ( "wrong syntax, no closed"',
	        'this.debug ( "wrong syntax, lowercases debug");',
	        'this.DEBUG ("wrong syntax, no ; at the end" )',
	        ]

		for jsStatementItem in jsCorrectStatements:
			self.assertEqual(self.myJsTransformer.transformString(jsStatementItem[0]),jsStatementItem[1])

		for jsStatementItem in jsWrongStatements:
			self.assertEqual(self.myJsTransformer.transformString(jsStatementItem),jsStatementItem)

	# test_transformFile
	@patch(patchstr_builtins)
	@patch('os.path.exists')
	def test_transformFile(self,mock_exists,mock_open):
		mysourcefile = 'mysourcefile.js'
		mydestinationfile = 'mydestinationfile.js'
		exists_side_effect_status = True
		def exists_side_effect(dirpath):
			self.DEBUG("\nos.path.exists\n dirpath : %s " % (dirpath))
			if dirpath == mysourcefile:
				return True
			elif dirpath == mydestinationfile:
				return False
			return exists_side_effect_status

		myfakefile = FakeFile()

		linesArray = self.jsSourceCodeSample.splitlines()
		myfakereadfile = FakeFile(mysourcefile,linesArray)
		myfakewritefile = FakeFile(mydestinationfile)

		def open_side_effect(filepath,mode):
			self.DEBUG("\n__builtin__.open\n filepath : %s - mode : %s" % (filepath,mode))
			if mode == 'r':
				return myfakereadfile
			else:
				return myfakewritefile
			return myfakefile

		mock_exists.side_effect = exists_side_effect
		mock_open.side_effect = open_side_effect

		self.assertEqual(self.myJsTransformer.transformFile(mysourcefile,mydestinationfile),True)
		self.assertEqual(len(myfakewritefile.fakeoutput.splitlines()),len(linesArray) - (3+2))

	# test_runTagAction
	@patch('shutil.copyfile')
	def test_runTagAction(self,mock_copyfile):

		def copyfile_side_effect(sourcepath,targetpath):
			self.DEBUG()
			self.DEBUG("\nshutil.copyfile\n sourcepath : %s, targetpath : %s " % (sourcepath,targetpath))

		mock_copyfile.side_effect = copyfile_side_effect

		self.assertEqual(self.myJsTransformer.runTagAction('invalidtag',{'src' : 'source_file','dest' : 'destination_file'}),False)
		self.assertEqual(self.myJsTransformer.runTagAction('.js',{'src' : 'source_file','dest' : 'destination_file'}),True)
		self.assertEqual(self.myJsTransformer.runTagAction('.ts',{'src' : 'source_file','dest' : 'destination_file'}),True)

		myfakeerror_copyfile = FakeError("copy error")
		mock_copyfile.side_effect = myfakeerror_copyfile.genrateError
		self.assertEqual(self.myJsTransformer.runTagAction('.js',{'src' : 'source_file','dest' : 'destination_file'}),False)

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