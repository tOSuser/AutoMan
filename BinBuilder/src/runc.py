#
# runc.py
#
# Description :
# --------------------------------------
# A heleper program to compile and move compiled files to bin/
#   Used by trun
#
#
# Copyright (c) 2022 Nexttop (nexttop.se)
#---------------------------------------
import sys, getopt
import os
import compileall
from shutil import copyfile

verboseMode = False
rawMode = False
sourcePath = ''
targetPath = ''

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

def compileFiles(currentpath,srcpathlist):
	compile_exit_code = False
	for srcitem in srcpathlist:
		sourcepath = ''
		if type(srcitem) == str:
			sourcepath = srcitem
		elif type(srcitem) == list:
			sourcepath = srcitem[0]

		if sourcepath != "":
			if sys.version_info[0] < 3:
				#DEBUG
				if (verboseMode == True):
					print ("%s#Compiler : 2.7 %s%s" % (CYAN,currentpath,NC))
				compile_exit_code = compileall.compile_dir(currentpath + sourcepath, force=True,quiet=1)
			else:
				#DEBUG
				if (verboseMode == True):
					print("%s#Compiler : > 3 %s%s" % (CYAN,currentpath,NC))
				compile_exit_code = compileall.compile_dir(currentpath + sourcepath, force=True,legacy=True,quiet=1)
			if (compile_exit_code != True):
				break
	return compile_exit_code

def moveToNewLocation(basepath,currentpath,build_path):
	#DEBUG
	if (verboseMode == True):
		print ("%smoveToNewLocation %s%s => %s%s" % (BLUE,YELLOW,os.path.join(basepath, currentpath),build_path,NC))
	if os.path.exists(os.path.join(basepath, currentpath)):
		for file in os.listdir(os.path.join(basepath, currentpath)):
			if not os.path.normpath(os.path.join(basepath, currentpath, file)) in build_path:
				if os.path.isdir(os.path.join(basepath, currentpath, file)) and os.path.isdir(os.path.join(basepath, currentpath, file)):
					moveToNewLocation(basepath,os.path.join(currentpath, file),build_path)
				elif file.endswith(".pyc"):
					dest = os.path.join(build_path, currentpath, file)
					#DEBUG
					if (verboseMode == True):
						print ("%smove %s%s %sto%s %s%s" % (BLUE,YELLOW,os.path.join(basepath, currentpath, file),BLUE,YELLOW, dest,NC))
					try:
						os.makedirs(os.path.dirname(dest))
					except:
						pass
					os.rename(os.path.join(basepath, currentpath, file), dest)
				elif (file.endswith(".php") or
						file.endswith(".java") or file.endswith(".xml") or
						file.endswith(".json") or
						file.endswith(".html") or file.endswith(".css") or  file.endswith(".ico") or
						file.endswith(".js") or file.endswith(".ts") or
						file.endswith(".png") or file.endswith(".svg")):
					dest = os.path.join(build_path, currentpath, file)
					#DEBUG
					if (verboseMode == True):
						print ("%smove %s%s %sto%s %s%s" % (BLUE,YELLOW,os.path.join(basepath, currentpath, file),BLUE,YELLOW, dest,NC))
					try:
						os.makedirs(os.path.dirname(dest))
					except:
						pass
					copyfile(os.path.join(basepath, currentpath, file), dest)
	else:
		print("Path was not found : " + os.path.join(basepath, currentpath))

# Main
#---------------------------------------
def main(srcphatlis = []):
	sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
	currentpath = os.path.dirname(os.path.abspath(__file__)) + '/'
	build_path = currentpath + "bin/"
	if compileFiles(currentpath,srcphatlis):
		for srcitem in srcphatlis:
			sourcepath = ''
			targetpath = ''
			if type(srcitem) == str:
				sourcepath = srcitem
				#DEBUG
				if (verboseMode == True):
					print ("%sSource path %s%s%s" % (BLUE,YELLOW,currentpath+srcitem,NC))
			elif type(srcitem) == list:
				sourcepath = srcitem[0]
				targetpath = srcitem[1]
				#DEBUG
				if (verboseMode == True):
					print ("%sSource path %s%s%s" % (BLUE,YELLOW,currentpath+sourcepath+"=>"+targetpath,NC))
				if os.path.exists(build_path + targetpath) == False:
					os.makedirs(build_path + targetpath)

			if sourcepath != "":
				moveToNewLocation(currentpath+sourcepath,"",build_path + targetpath)
		return True
	return False

if __name__ == '__main__':
	argv = sys.argv[1:]
	opts, args = getopt.getopt(argv, 'vrs:t:')
	for opt, arg in opts:
		if opt in ['-v']:
			verboseMode = True
		elif opt in ['-r']:
			rawMode = True
		elif opt in ['-s']:
			sourcePath = arg
		elif opt in ['-t']:
			targetPath = arg

	if ( rawMode == False):
	    BGRED='\033[41m'
	    RED='\033[31m'
	    GREEN='\033[32m'
	    YELLOW='\033[33m'
	    BLUE='\033[34m'
	    CYAN='\033[35m'
	    BGGREEN='\033[42m'
	    WHITE='\033[37m\033[1m'
	    NC='\033[0m' # No Color

	sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
	currentpath = os.path.dirname(os.path.abspath(__file__)) + '/'
	src_paths_conf = currentpath + '.sourcepaths'
	if os.path.exists(src_paths_conf) == True:
		try :
			frcontent = open(src_paths_conf, "rb")
			src_paths = eval(frcontent.read())
			frcontent.close()
			if (main(src_paths) != True):
				exit(1)
		except Exception as e:
			print(str(e))
			exit(1)
	exit(0)
