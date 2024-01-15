#
# TestHelper.py
#
# Description :
# --------------------------------------
# Test helper
#
#
# Copyright (c) 2022 Nexttop (nexttop.se)
#---------------------------------------
import sys
import os

if sys.version_info[0] < 3:
	# 2.7
	import urlparse as uniurlparse
else:
	# > 3
	import urllib.parse as uniurlparse

from nxLogger.nxLogger import nxLogger
from nxEncoder.nxEncoder import nxEncoder
from nxTracer.nxTracer import nxTracer
from nxTracer.nxTracer import colors

# TestHelper : Helper functions used by other tests
#---------------------------------------
class FakePrint(nxTracer):
	"""
	A stub used by tests.
	  -
	  -
	"""

	myvalue = ""
	fakeid ='FakePrint'

	def __init__(self):
		self.ncalls = {}
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		for fname, fattr in FakePrint.__dict__.items():
			if "function" in str(fattr) and not fname.startswith('_'):
				self.ncalls[fname] = 0

	def resetstub_(self):
		for item in self.ncalls:
			self.ncalls[item] = 0

	def _countfunccalls(self,funcname):
		if funcname not in self.ncalls:
			self.ncalls[funcname] = 0
		self.ncalls[funcname] = self.ncalls[funcname] + 1
		self.DEBUG(self.fakeid + ' ' + funcname + ' ' + str(self.ncalls[funcname]))

	def write(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		for item in args:
			self.myvalue = self.myvalue + item
	def flush(self, *args, **kwargs):
		pass

class FakeFile(nxTracer):
	"""
	A stub used by tests.
	  -
	  -
	"""

	fakedata = []
	fakeoutput = ""
	fakeid =''

	def __init__(self,id = 'myfakefilemanager', datatoread= []):
		self.ncalls = {}
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		self.fakeid = id
		self.fakedata = datatoread
		for fname, fattr in FakeFile.__dict__.items():
			if "function" in str(fattr) and not fname.startswith('_'):
				self.ncalls[fname] = 0

	def resetstub_(self):
		for item in self.ncalls:
			self.ncalls[item] = 0

	def _countfunccalls(self,funcname):
		if funcname not in self.ncalls:
			self.ncalls[funcname] = 0
		self.ncalls[funcname] = self.ncalls[funcname] + 1
		self.DEBUG(self.fakeid + ' ' + funcname + ' ' + str(self.ncalls[funcname]))

	def write(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		for item in args:
			self.fakeoutput = self.fakeoutput + item
		self.fakeoutput = self.fakeoutput + '\n'

	def readlines(self):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		return self.fakedata

	def read(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		fakedatastr = ''
		if type(self.fakedata) == list:
			for fakedataline in self.fakedata:
				fakedatastr = fakedatastr + fakedataline + '\n'
		else:
			fakedatastr = self.fakedata
		self.DEBUG(fakedatastr)
		return fakedatastr

	def close(self):
		self._countfunccalls(sys._getframe(0).f_code.co_name)

	def __exit__(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)

	def __enter__(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)

class FakeError(nxTracer):
	"""
	A stub used by tests.
	  -
	  -
	"""

	fakeErrorMessage = ""
	def __init__(self,errorMessage):
		self.fakeErrorMessage = errorMessage

	def genrateError(self,*args, **kwargs):
		self.DEBUG("FakeError.genrateError")
		raise ValueError(self.fakeErrorMessage)

class FakeURL(nxTracer):
	"""
	A stub used by tests.
	  -
	  -
	"""
	fakedata = []
	fakeoutput = ""
	fakeid =''
	readmode = 0

	def __init__(self,id = 'myfakeurl', datatoread= []):
		self.ncalls = {}
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		self.fakeid = id
		self.fakedata = datatoread
		for fname, fattr in FakeURL.__dict__.items():
			if "function" in str(fattr) and not fname.startswith('_'):
				self.ncalls[fname] = 0

	def resetstub_(self):
		for item in self.ncalls:
			self.ncalls[item] = 0

	def _countfunccalls(self,funcname):
		if funcname not in self.ncalls:
			self.ncalls[funcname] = 0
		self.ncalls[funcname] = self.ncalls[funcname] + 1
		self.DEBUG(self.fakeid + ' ' + funcname + ' ' + str(self.ncalls[funcname]))

	def Request(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)

	def urlopen(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		return self

	def read(self):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		if self.readmode != 0 and len(self.fakedata) >= self.ncalls['read']:
			self.DEBUG("readmode %d, %s" % (self.readmode,self.fakedata[self.ncalls['read'] - 1]))
			return self.fakedata[self.ncalls['read'] - 1 ]
		self.DEBUG("readmode %d, %s" % (self.readmode,self.fakedata))
		return self.fakedata

	def close(self):
		self._countfunccalls(sys._getframe(0).f_code.co_name)

class TestHelper(nxTracer):
	# Make a regular expression
	# for validating an Ip-address
	regex = "^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$"

	def __init__(self):
		self.DEBUG()
		self.DEBUG("Run tests on Python ver %d\n" % (sys.version_info[0]))

	# validate an Ip address
	def isIpAddress(self,ipStr):
		# pass the regular expression
		# and the string in search() method
		if(re.search(self.regex, ipStr)):
			return True
		return False

	# @param haystack, a string
	# @param needle, a string
	# @return an integer
	def strStr(self, haystack, needle):
		len1=len(haystack)
		len2=len(needle)
		if len1<len2: return -1
		for i in range(len1-len2+1):
			if haystack[i:i+len2]==needle:return i
		return -1

class Fakemysql(TestHelper):
	"""
	A stub used by tests.
	  -
	  -
	"""

	Error = 0
	fakeid = 'mysql'

	def __init__(self):
		self.db_connection_arr = []
		self.sql_execute_arr = []
		self.ncalls = {}
		self.fetchall_arr = [[]]
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		for fname, fattr in Fakemysql.__dict__.items():
			if "function" in str(fattr) and not fname.startswith('_'):
				self.ncalls[fname] = 0

	def resetstub_(self):
		self.db_connection_arr = []
		self.sql_execute_arr = []
		self.fetchall_arr = [[]]
		for item in self.ncalls:
			self.ncalls[item] = 0

	def _countfunccalls(self,funcname):
		if funcname not in self.ncalls:
			self.ncalls[funcname] = 0
		self.ncalls[funcname] = self.ncalls[funcname] + 1
		self.DEBUG(self.fakeid + ' ' + funcname + ' ' + str(self.ncalls[funcname]))

	def connect(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		connectinfo = ''
		for item in args:
			connectinfo = connectinfo + item
		self.db_connection_arr.append(connectinfo)
		self.DEBUG("Fakemysql.connect : " + connectinfo)
		return self

	def cursor(self):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		self.DEBUG("Fakemysql.cursor")
		return self

	def execute(self,sqlstr):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		self.DEBUG("Fakemysql.execute : " + sqlstr)
		self.sql_execute_arr.append(sqlstr)
		return True

	def close(self):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		self.DEBUG("Fakemysql.close")
		return True

	def fetchall(self):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		self.DEBUG("Fakemysql.fetchall")
		for item in self.fetchall_arr[self.ncalls['fetchall']]:
			self.DEBUG(str(item))
		if len(self.fetchall_arr) >= self.ncalls['fetchall']:
			return self.fetchall_arr[self.ncalls['fetchall']]
		return self.fetchall_arr[0]

class Fakesqlite3(TestHelper):
	"""
	A stub used by tests.
	  -
	  -
	"""

	Error = 0
	fakeid = 'sqlite3'

	def __init__(self):
		self.db_connection_arr = []
		self.sql_execute_arr = []
		self.ncalls = {}
		self.fetchall_arr = [[]]
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		for fname, fattr in Fakesqlite3.__dict__.items():
			if "function" in str(fattr) and not fname.startswith('_'):
				self.ncalls[fname] = 0

	def resetstub_(self):
		self.db_connection_arr = []
		self.sql_execute_arr = []
		self.fetchall_arr = [[]]
		for item in self.ncalls:
			self.ncalls[item] = 0

	def _countfunccalls(self,funcname):
		if funcname not in self.ncalls:
			self.ncalls[funcname] = 0
		self.ncalls[funcname] = self.ncalls[funcname] + 1
		self.DEBUG(self.fakeid + ' ' + funcname + ' ' + str(self.ncalls[funcname]))

	def connect(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		connectinfo = ''
		for item in args:
			connectinfo = connectinfo + item
		self.db_connection_arr.append(connectinfo)
		self.DEBUG("Fakesqlite3.connect : " + connectinfo)
		return self

	def commit(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		return self

	def rollback(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		return self

	def execute(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		sqlstr = ''
		for item in args:
			sqlstr = sqlstr + str(item)
		self.DEBUG("Fakesqlite3.execute : " + sqlstr)
		self.sql_execute_arr.append(sqlstr)
		return self

	def close(self):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		return True

	def fetchall(self):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		self.DEBUG("Fakesqlite3.fetchall")
		for item in self.fetchall_arr[self.ncalls['fetchall']]:
			self.DEBUG(str(item))
		if len(self.fetchall_arr) >= self.ncalls['fetchall']:
			return self.fetchall_arr[self.ncalls['fetchall']]
		return self.fetchall_arr[0]

class Fakesoket(TestHelper):
	"""
	A stub used by tests.
	  -
	  -
	"""

	fakeid = 'soket'
	def __init__(self):
		self.ncalls = {}
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		for fname, fattr in Fakesoket.__dict__.items():
			if "function" in str(fattr) and not fname.startswith('_'):
				self.ncalls[fname] = 0

	def resetstub_(self):
		for item in self.ncalls:
			self.ncalls[item] = 0

	def _countfunccalls(self,funcname):
		if funcname not in self.ncalls:
			self.ncalls[funcname] = 0
		self.ncalls[funcname] = self.ncalls[funcname] + 1
		self.DEBUG(self.fakeid + ' ' + funcname + ' ' + str(self.ncalls[funcname]))

	def soket(self,*args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		self.DEBUG("Fakesoket.soket")
		##return "<socket.socket fd=3, family=AddressFamily.AF_INET, type=SocketKind.SOCK_DGRAM, proto=0, laddr=('0.0.0.0', 0)>"
		return self

	def fileno(self,*args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		self.DEBUG("Fakesoket.fileno")
		return 3

class Fakefcntl(TestHelper):
	"""
	A stub used by tests.
	  -
	  -
	"""

	fakeid = 'fcntl'
	def __init__(self):
		self.ncalls = {}
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		for fname, fattr in Fakefcntl.__dict__.items():
			if "function" in str(fattr) and not fname.startswith('_'):
				self.ncalls[fname] = 0

	def resetstub_(self):
		for item in self.ncalls:
			self.ncalls[item] = 0

	def _countfunccalls(self,funcname):
		if funcname not in self.ncalls:
			self.ncalls[funcname] = 0
		self.ncalls[funcname] = self.ncalls[funcname] + 1
		self.DEBUG(self.fakeid + ' ' + funcname + ' ' + str(self.ncalls[funcname]))
	def ioctl(self,*args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		self.DEBUG("Fakefcntl.ioctl")
		return b'\xc8\x00\x00\x00\x00\x00\x00\x00\xe0;U\x02\x00\x00\x00\x00'

class Fakeconfigparser(TestHelper):
	"""
	A stub used by tests.
	  -
	  -
	"""

	fake_sections_data = {}
	fake_defaults_data = {}
	fakeoutput = ""
	fakeid =''

	def __init__(self,id = 'configparser', defaults_data= {},sections_data = {}):
		self.ncalls = {}
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		self.fakeid = id
		self.fake_defaults_data = defaults_data
		self.fake_sections_data = sections_data
		for fname, fattr in Fakeconfigparser.__dict__.items():
			if "function" in str(fattr) and not fname.startswith('_'):
				self.ncalls[fname] = 0

	def resetstub_(self):
		for item in self.ncalls:
			self.ncalls[item] = 0

	def _countfunccalls(self,funcname):
		if funcname not in self.ncalls:
			self.ncalls[funcname] = 0
		self.ncalls[funcname] = self.ncalls[funcname] + 1
		self.DEBUG(self.fakeid + ' ' + funcname + ' ' + str(self.ncalls[funcname]))

	def ConfigParser(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		return self

	def write(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		for item in args:
			self.fakeoutput = self.fakeoutput + str(item)
		self.fakeoutput = self.fakeoutput + '\n'

	def read(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		#return self.fakedata

	def defaults(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		return self.fake_defaults_data

	def sections(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		return self.fake_sections_data

	def add_section(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)

	def set(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)

	def has_option(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		return True

	def get(self, *args, **kwargs):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		return 'data'

class FakeHTTPRequester(nxTracer):
	"""
	A stub used by tests.
	  -
	  -
	"""

	content = 'Not set yet'
	status_code	= 200
	fakeid = 'FakeHTTPRequester'

	def __init__(self,resthandler):
		self.myresthandler = resthandler
		self.ncalls = {}
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		for fname, fattr in FakeHTTPRequester.__dict__.items():
			if "function" in str(fattr) and not fname.startswith('_'):
				self.ncalls[fname] = 0

	def resetstub_(self):
		for item in self.ncalls:
			self.ncalls[item] = 0

	def _countfunccalls(self,funcname):
		if funcname not in self.ncalls:
			self.ncalls[funcname] = 0
		self.ncalls[funcname] = self.ncalls[funcname] + 1
		self.DEBUG(self.fakeid + ' ' + funcname + ' ' + str(self.ncalls[funcname]))

	def HTTPGet(self,url, params, headers):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		return self

	def HTTPPost(self,url, params, headers):
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		return self

	def get_side_effect(self,*args, **kwargs):
		self.DEBUG()
		path = args[0]
		headers = kwargs['headers']

		contenttype = (None if 'Content-type' not in headers or headers['Content-type'] != "application/x-www-form-urlencoded" else "application/x-www-form-urlencoded")
		acceptedtype = ("text/plain" if 'Accept'not in headers else headers['Accept'])
		parameterstr = uniurlparse.urlparse(path).query

		self.DEBUG("contenttype : %s" % (contenttype))
		self.DEBUG("acceptedtype : %s" % (acceptedtype))
		self.DEBUG("parameterstr : %s" % (parameterstr))

		if (contenttype != None):
			response = self.myresthandler.getResponse(acceptedtype,parameterstr)
			try:
				self.content = response[2]
				self.status_code = response[1]
				#self.sendError(response[1], response[2],acceptedtype)

				self.DEBUG("response %s" % (str(response[2])))
			except Exception as e:
				self.content = "Unknown errors occurred during producing requests"
				self.status_code = 500
		else:
			self.content = "Unknown data type"
			self.status_code = 403
		return self

	def post_side_effect(self,*args, **kwargs):
		self.DEBUG()
		path = args[0]
		headers = kwargs['headers']
		data = kwargs['data']

		contenttype = (None if 'Content-type' not in headers or headers['Content-type'] != "application/x-www-form-urlencoded" else "application/x-www-form-urlencoded")
		acceptedtype = ("text/plain" if 'Accept'not in headers else headers['Accept'])

		try:
			datastr = ''
			for item in data:
				if len(datastr) > 0:
					datastr = datastr +'&'
				datastr = datastr + item + '=' + data[item]
			parameterstr = datastr
		except:
			parameterstr = ""

		self.DEBUG("contenttype : %s" % (contenttype))
		self.DEBUG("acceptedtype : %s" % (acceptedtype))
		self.DEBUG("parameterstr : %s" % (parameterstr))

		if (contenttype != None):
			response = self.myresthandler.getResponse(acceptedtype,parameterstr)
			try:
				self.content = response[2]
				self.status_code = response[1]
				#self.sendError(response[1], response[2],acceptedtype)

				self.DEBUG("response %s" % (str(response[2])))
			except Exception as e:
				self.content = "Unknown errors occurred during producing requests"
				self.status_code = 500
		else:
			self.content = "Unknown data type"
			self.status_code = 403
		return self

class FakeHTTPServer(nxTracer):
	"""
	A stub used by tests.
	  -
	  -
	"""

	fakedata = []
	fakeoutput = ""
	fakeid =''


	def __init__(self,id = 'myhttpserver', datatoread= []):
		self.ncalls = {}
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		self.fakeid = id
		self.fakedata = datatoread
		for fname, fattr in FakeFile.__dict__.items():
			if "function" in str(fattr) and not fname.startswith('_'):
				self.ncalls[fname] = 0
		self.socket = Fakesoket()

	def resetstub_(self):
		for item in self.ncalls:
			self.ncalls[item] = 0

	def _countfunccalls(self,funcname):
		if funcname not in self.ncalls:
			self.ncalls[funcname] = 0
		self.ncalls[funcname] = self.ncalls[funcname] + 1
		self.DEBUG(self.fakeid + ' ' + funcname + ' ' + str(self.ncalls[funcname]))

	def HTTPServer(self,*args, **kwargs):
		self.DEBUG()
		self._countfunccalls(sys._getframe(0).f_code.co_name)
		return self

	def serve_forever(self):
		self.DEBUG()
		self._countfunccalls(sys._getframe(0).f_code.co_name)