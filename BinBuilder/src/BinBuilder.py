#
# binbuilder.py
#
# Description :
# --------------------------------------
# Heleper classes to compile and move compiled files to bin/
#   Used by trun
#
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
import sys, getopt
import os
import compileall
import shutil

from AddonsManager import AddonsManager

class VerboseTool():
	"""
	Verbose tool.
		-
		-
	"""
	verboseMode = False
	rawMode = False

	# Define colors
	BGRED=''
	RED=''
	GREEN=''
	YELLOW=''
	BLUE=''
	CYAN=''
	BGGREEN=''
	WHITE=''
	NC='' # No Color

	"""
		@__init__		Initialaizer / constractor

		:parameter		none
		:return		none
	"""
	def __init__(self,verbosemode = False,rawmode = False):
		self.verboseMode = verbosemode
		self.rawMode = rawmode

		self.setColors(self.rawMode)

	"""
		@__del__		deconstractor

		:parameter		none
		:return		none
	"""
	def __del__(self):
		pass

	"""
		@setColors		Set color for non-rawmode

		:parameter
			:param		rawmode / boolean
		:return		none
	"""
	def setColors(self,rawmode = False):
		if ( rawmode == False):
			BGRED='\033[41m'
			RED='\033[31m'
			GREEN='\033[32m'
			YELLOW='\033[33m'
			BLUE='\033[34m'
			CYAN='\033[35m'
			BGGREEN='\033[42m'
			WHITE='\033[37m\033[1m'
			NC='\033[0m' # No Color

	"""
		@verbosePrint		Print out a string if verbose mode is true

		:parameter
			:param		verbosestr / string
		:return		none
	"""
	def verbosePrint(self,verbosestr = ''):
		if (self.verboseMode == True):
			print(verbosestr)


class ProjectHelperIF:
	"""
	Project Helper interface.
		-
		-
	"""
	interfaceId = 'ProjectHelperIF'

	projectRoot = ''

	"""
		@__init__		Initialaizer / constractor

		:parameter
			:param		projectRoot / string

		:return		none
	"""
	def __init__(self, projectroot):
		self.projectRoot = projectroot

	"""
		@__del__		deconstractor

		:parameter		none

		:return		none
	"""
	def __del__(self):
		pass

	"""
		@getProjectRoot		return the current project path root

		:parameter		none

		:return		none
	"""
	def getProjectRoot(self):
		return self.projectRoot


class BinBuilder(VerboseTool):
	"""
	Bin builder.
		-
		-
	"""
	currentPath = ''
	buildPath = ''
	originalPath = ''

	defaultsettings = {}
	addonsignatur = 'transformer'

	CP_SRC = 'src'
	CP_DEST = 'dest'
	CP_TMODE = 'tmode'

	TM_PRODUCT = 0
	TM_DEVELOP = 1

	"""
		@__init__		Initialaizer / constractor

		:parameter
			:param		originalpath / string
			:param		currentpath / string
			:param		defaultsettings / dict
			:param		verbosemode / boolean
			:param		rawmode / boolean

		:return		none
	"""
	def __init__(self,originalpath ,currentpath,defaultsettings = {'addonsfolder' : 'transformers','addonslist' : ''}, verbosemode = False,rawmode = False):
		VerboseTool.__init__(self,verbosemode,rawmode)

		self.defaultsettings = defaultsettings
		self.currentPath = currentpath
		self.buildPath = self.currentPath + "bin/"
		self.originalPath = originalpath
		self.projecthelperif = ProjectHelperIF(self.currentPath)
		self.api = {ProjectHelperIF.interfaceId : self.projecthelperif}

		self.myaddonsmanager = AddonsManager(self.addonsignatur,self.defaultsettings,self.api)

	"""
		@__del__		deconstractor

		:parameter		none
		:return		none
	"""
	def __del__(self):
		pass

	"""
		@run		Looking on source folders to compile python files

		:parameter
			:param		current_path / string
			:param		source_path_list / list
			:param		transformmode / int

		:return		boolean
	"""
	def compileFiles(self,current_path,source_path_list,transformmode = TM_DEVELOP):
		compile_exit_code = False
		for sourceitem in source_path_list:
			source_path = ''
			if type(sourceitem) == str:
				source_path = sourceitem
			elif type(sourceitem) == list:
				source_path = sourceitem[0]

			if source_path != "":
				if sys.version_info[0] < 3:
					#DEBUG
					self.verbosePrint("%s#Compiler : 2.7 %s%s" % (self.CYAN,current_path,self.NC))
					if os.path.isdir(current_path + source_path):
						compile_exit_code = compileall.compile_dir(current_path + source_path, force=True,quiet=1)
				else:
					#DEBUG
					self.verbosePrint("%s#Compiler : > 3 %s%s" % (self.CYAN,current_path,self.NC))
					if os.path.isdir(current_path + source_path):
						compile_exit_code = compileall.compile_dir(current_path + source_path, force=True,legacy=True,quiet=1)
				if (compile_exit_code != True):
					break
		return compile_exit_code

	"""
		@transformFile		Copy/transform files

		:parameter
			:param		tag / string
			:param		source_path / string
			:param		destination_path / string
			:param		transformmode / int

		:return		True/False
	"""
	def transformFile(self,tag,source_path,destination_path,transformmode = TM_DEVELOP):
		transformResult = self.myaddonsmanager.runTagAction(tag,{self.CP_SRC:source_path,self.CP_DEST:destination_path,self.CP_TMODE:transformmode},{})
		if transformResult[0] == False:
			return False
		return transformResult[1]

	"""
		@run		Move/copy files to the bin folder (pyc(s) are moved, other files are copied)

		:parameter
			:param		base_path / string
			:param		current_path / string
			:param		build_path / string
			:param		transformmode / int

		:return		none
	"""
	def moveToNewLocation(self,base_path,current_path,build_path,transformmode = TM_DEVELOP):
		#DEBUG
		self.verbosePrint("%smoveToNewLocation %s%s => %s%s" % (self.BLUE,self.YELLOW,os.path.join(base_path, current_path),build_path,self.NC))
		if os.path.exists(os.path.join(base_path, current_path)):
			if os.path.isdir(os.path.join(base_path, current_path)):
				for file in os.listdir(os.path.join(base_path, current_path)):
					fileExtension = os.path.splitext(file)[-1]
					if not os.path.normpath(os.path.join(base_path, current_path, file)) in build_path:
						if os.path.isdir(os.path.join(base_path, current_path, file)) and os.path.isdir(os.path.join(base_path, current_path, file)):
							self.moveToNewLocation(base_path,os.path.join(current_path, file),build_path,transformmode)
						elif fileExtension == ".pyc":
							dest = os.path.join(build_path, current_path, file)
							#DEBUG
							self.verbosePrint("%smove %s%s %sto%s %s%s" % (self.BLUE,self.YELLOW,os.path.join(base_path, current_path, file),self.BLUE,self.YELLOW, dest,self.NC))
							try:
								os.makedirs(os.path.dirname(dest))
							except:
								pass
							os.rename(os.path.join(base_path, current_path, file), dest)
						elif self.myaddonsmanager.isTagRegistered(fileExtension):
							dest = os.path.join(build_path, current_path, file)
							#DEBUG
							self.verbosePrint("%smove %s%s %sto%s %s%s" % (self.BLUE,self.YELLOW,os.path.join(base_path, current_path, file),self.BLUE,self.YELLOW, dest,self.NC))
							try:
								os.makedirs(os.path.dirname(dest))
							except:
								pass
							self.transformFile(fileExtension,os.path.join(base_path, current_path, file), dest,transformmode)
		else:
			print("Path was not found : " + os.path.join(base_path, current_path))

	"""
		@run		xxx

		:parameter
			:param		source_phat_list / list
			:param		transformmode / int

		:return		boolean
	"""
	def run(self,source_path_list = [],transformmode = TM_DEVELOP):
		if self.compileFiles(self.currentPath,source_path_list,transformmode):
			for sourceitem in source_path_list:
				source_path = ''
				target_path = ''
				if type(sourceitem) == str:
					source_path = sourceitem
					if os.path.isdir(self.currentPath+source_path):
						#DEBUG
						self.verbosePrint("%sSource path %s%s%s" % (self.BLUE,self.YELLOW,self.currentPath+sourceitem,self.NC))
					else:
						#DEBUG
						self.verbosePrint("%sSource file %s%s%s" % (self.BLUE,self.YELLOW,self.currentPath+sourceitem,self.NC))
				elif type(sourceitem) == list:
					source_path = sourceitem[0]
					target_path = sourceitem[1]
					if os.path.isdir(self.currentPath+source_path):
						#DEBUG
						self.verbosePrint("%sSource path %s%s%s" % (self.BLUE,self.YELLOW,self.currentPath+source_path+"=>"+target_path,self.NC))
						if os.path.exists(self.buildPath + target_path) == False:
							os.makedirs(self.buildPath + target_path)
					else:
						#DEBUG
						self.verbosePrint("%sSource file %s%s%s" % (self.BLUE,self.YELLOW,self.currentPath+source_path+"=>"+target_path,self.NC))

				if source_path != "":
					if os.path.isdir(self.currentPath+source_path):
						self.moveToNewLocation(self.currentPath+source_path,"",self.buildPath + target_path,transformmode)
					else:
						try:
							fname = os.path.basename(source_path)
							if target_path != '':
								dest = target_path+ "/" + fname
							else:
								dest = fname
							self.verbosePrint("%scopy %s%s %sto%s %s%s" % (self.BLUE,self.YELLOW,self.currentPath+source_path,self.BLUE,self.YELLOW, self.buildPath + target_path,self.NC))
							shutil.copyfile(self.currentPath+source_path, self.buildPath + dest)
						except BaseException as err:
							serr = str(err)
							print("copyfile : " + serr)
			return True
		return False