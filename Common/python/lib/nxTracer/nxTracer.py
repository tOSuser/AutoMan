#
# nxTracer.py
#
# Description :
# --------------------------------------
# A class to trace in a standard way
#
#
# Copyright (c) 2022 Nexttop (nexttop.se)
#---------------------------------------

import sys
import logging

class colors:
	'''Colors class:reset all colors with colors.reset; two
	sub classes fg for foreground
	and bg for background; use as colors.subclass.colorname.
	i.e. colors.fg.red or colors.bg.greenalso, the generic bold, disable,
	underline, reverse, strike through,
	and invisible work with the main class i.e. colors.bold
	'''
	reset='\033[0m'
	bold='\033[01m'
	disable='\033[02m'
	underline='\033[04m'
	reverse='\033[07m'
	strikethrough='\033[09m'
	invisible='\033[08m'
	class fg:
		black='\033[30m'
		red='\033[31m'
		green='\033[32m'
		orange='\033[33m'
		blue='\033[34m'
		purple='\033[35m'
		cyan='\033[36m'
		lightgrey='\033[37m'
		darkgrey='\033[90m'
		lightred='\033[91m'
		lightgreen='\033[92m'
		yellow='\033[93m'
		lightblue='\033[94m'
		pink='\033[95m'
		lightcyan='\033[96m'
	class bg:
		black='\033[40m'
		red='\033[41m'
		green='\033[42m'
		orange='\033[43m'
		blue='\033[44m'
		purple='\033[45m'
		cyan='\033[46m'
		lightgrey='\033[47m'

class traceMode:
	TM_NOTRACELOG = 0
	TM_TRACEINFO = 1
	TM_TRACEDEBUG = 2

class nxTracer (traceMode):
	"""
	A simple trace system
		-
		-
	"""
	tracelevel = traceMode.TM_TRACEINFO
	streamLogger = 'smstream'
	fileLogger = 'smfile'
	rootLogger = 'root'

	"""
		@__init__		initialize the class

		:parameter
			:param		tracelevel/int (traceMode)   referenced trace level 

		:return		none
	"""
	def __init__(self,tracelevel = traceMode.TM_TRACEINFO):
		self.tracelevel = tracelevel

	def INFO(self,extrainfo="",highlighted = True,legacy = False):
		if extrainfo == "" :
			logStr = ("%s : %s(%d): Called from %s(%d)" % (self.__module__ , sys._getframe(1).f_code.co_name,sys._getframe(1).f_lineno, sys._getframe(2).f_code.co_name,sys._getframe(2).f_lineno))
		else:
			logStr = ("%s" % (extrainfo))
		if highlighted == True:
			logStr = (colors.fg.yellow+logStr+colors.reset).format()
		else:
			logStr = (colors.fg.blue+logStr+colors.reset).format()

		try:
			if self.fileLogger in logging.Logger.manager.loggerDict.keys() and legacy == False:
				logging.getLogger(self.fileLogger).info(logStr)
			else :
				logging.info(logStr)
		except Exception as e:
			print(str(e))


	def DEBUG(self,debuginfo="",legacy = False,prefixlinefeed = False):
		linefeedstr = ''
		if prefixlinefeed == True:
			linefeedstr = '\n'

		if debuginfo == "" and legacy == False:
			logStr = ("%s : %s(%d): Called from %s(%d)" % (self.__module__ , sys._getframe(1).f_code.co_name,sys._getframe(1).f_lineno, sys._getframe(2).f_code.co_name,sys._getframe(2).f_lineno))
		else :
			try:
				logStr = ("%s%s : %s(%d): %s" % (linefeedstr,self.__module__ , sys._getframe(1).f_code.co_name,sys._getframe(1).f_lineno,debuginfo))
			except Exception as e:
				print(str(e))
				logStr = ("%s%s : %s" % (linefeedstr,self.__module__ ,debuginfo))

		try:
			if self.fileLogger in logging.Logger.manager.loggerDict.keys() and legacy == False:
				logging.getLogger(self.fileLogger).debug(logStr)
			else :
				logging.debug(logStr)
		except Exception as e:
			print(str(e))

	def WARNING(self,warninginfo,legacy = False):
		logStr = ("%s" % (warninginfo))
		logStr = (colors.fg.orange+logStr+colors.reset).format()
		logStr = ("%s : %s(%d): %s" % (self.__module__ , sys._getframe(1).f_code.co_name,sys._getframe(1).f_lineno,logStr))

		if self.fileLogger in logging.Logger.manager.loggerDict.keys() and legacy == False:
			logging.getLogger(self.fileLogger).warning(logStr)
		else :
			logging.warning(logStr)

	def ERROR(self,errorinfo,legacy = False):
		logStr = ("%s" % (errorinfo))
		logStr = (colors.fg.red+logStr+colors.reset).format()
		logStr = ("%s : %s(%d): %s" % (self.__module__ , sys._getframe(1).f_code.co_name,sys._getframe(1).f_lineno,logStr))

		try:
			if self.fileLogger in logging.Logger.manager.loggerDict.keys() and legacy == False:
				logging.getLogger(self.fileLogger).error(logStr)
			else :
				logging.error(logStr)
		except Exception as e:
			print(str(e))


	def __del__(self):
		pass
