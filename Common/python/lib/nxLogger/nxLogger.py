#
# nxLogger.py
#
# Description :
# --------------------------------------
# A class to log in a standard way
#
#
# Copyright (c) 2021 Nexttop (nexttop.se)
#---------------------------------------

import datetime
import json

import sys

class logMode:
	LL_NOLOG = 0
	LL_LOGINFO = 1
	LL_DEBUG = 2

class nxLogger (logMode):
	"""
	A simple log system
		-
		-
	"""
	logfilename = None
	loglevel = logMode.LL_LOGINFO

	"""
		@__init__		initialize the class

		:parameter
			:param		logfile/string    log file name included its path or none
			:param		loglevel/int (logMode)   referenced log level 

		:return		none
	"""
	def __init__(self,logfile ='myinfo.log',loglevel = logMode.LL_LOGINFO):
		self.logfilename = logfile
		self.loglevel = loglevel

	"""
		@__stringify(private)		create a formatted string from an object

		:parameter
			:param		inobject    an object included set, list, map, dict and string ...

		:return		string
	"""
	def __stringify(self, inobject):
		outstr = ""
		if (hasattr(inobject, '__iter__') and not isinstance(inobject, str)) :
			if (isinstance(inobject, dict)): # encode dict objects
				for ikeys in list(inobject):
					outstr += ikeys.__str__() + ": '"
					outstr += self.__stringify(inobject[ikeys])+"', "
			else: # encode other objects list, map, str ....
				i = 0;
				for iitem in inobject:
					outstr += self.__stringify(iitem)
					if (not outstr.endswith(", ")):
						if (hasattr(iitem, '__getitem__') and i != len(inobject) - 1): outstr += ":"
						elif (i == len(inobject) - 1 ): outstr += ", "
					i+=1
		else:
			outstr += str(inobject)
		return outstr

	"""
		@__logstring(private)		create a time stamped log info from an object by using @__stringify

		:parameter
			:param		inobject    an object included set, list, map, dict and string ...
			:param		loglevel    log level for the sent object

		:return		none
	"""
	def __logstring(self,logobject,loglevel=logMode.LL_LOGINFO):
		if (loglevel >= self.loglevel):
			logstr =  datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')+" : "
			logstr += self.__stringify(logobject)
			if (self.logfilename != None):
				try :
					with open(self.logfilename, 'a') as log_file:
						log_file.write('{}\n'.format(logstr))
				except IOError:
					print ("IOError : "+IOError.message)
			else:
				print (logstr)

	"""
		@logString		log sent object to file or std output by using @__logstring

		:parameter
			:param		inobject    an object included set, list, map, dict and string ...
			:param		loglevel    log level for the sent object

		:return		none
	"""
	def logString(self,logobject,loglevel=logMode.LL_LOGINFO):
		self.__logstring(logobject,loglevel)

	def __del__(self):
		pass
