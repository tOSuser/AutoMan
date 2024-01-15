#
# runbb.py
#
# Description :
# --------------------------------------
# A heleper program to compile and move compiled files to bin/
#   Used by trun
#
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
import sys, getopt
import os

TM_PRODUCT = 0
TM_DEVELOP = 1

binBuilderModuleFolder = 'BinBuilder'
currentPath = os.path.dirname(os.path.abspath(__file__)) + '/'
#originalPath = os.path.dirname(os.path.abspath(currentPath+os.readlink(__file__))) + '/'
originalPath = currentPath
sys.path.append(originalPath + binBuilderModuleFolder)


from BinBuilder import BinBuilder

verboseMode = False
rawMode = False
transformMode = TM_DEVELOP

defaultsettings = {'addonsfolder' : 'transformers',
	'addonslist' : [
		'JavaTransformer',
		'JsonTransformer',
		'JsTransformer',
		'PhpTransformer',
		'WebTransformer',
		'XmlTransformer',
		'ShTransformer',
		'MdTransformer',
		'DataTransformer',
		'XtraTransformer'
		]
	}

if __name__ == '__main__':
	argv = sys.argv[1:]
	opts, args = getopt.getopt(argv, 'vrs:t:m:p:')
	for opt, arg in opts:
		if opt in ['-v']:
			verboseMode = True
		elif opt in ['-r']:
			rawMode = True
		elif opt in ['-s']:
			sourcePath = arg
		elif opt in ['-t']:
			targetPath = arg
		elif opt in ['-m']:
			if (arg.lower() == 'product'):
				transformMode = TM_PRODUCT
		elif opt in ['-p']:
			currentPath = arg

	myBinBuilder = BinBuilder(originalPath,currentPath,defaultsettings,verboseMode,rawMode)
	src_paths_conf = currentPath + '.sourcepaths'

	if os.path.exists(src_paths_conf) == True:
		try :
			frcontent = open(src_paths_conf, "rb")
			src_paths = eval(frcontent.read())
			frcontent.close()
			if (myBinBuilder.run(src_paths,transformMode) != True):
				exit(1)
		except Exception as e:
			print(str(e))
			exit(1)
	exit(0)
