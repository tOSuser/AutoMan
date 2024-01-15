#!/bin/bash
#: packagebuilder test
#:
#: File : packagebuilder.test.sh
#
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
## Import libraries
TESTORIGINALSCRIPT_PATH=$( dirname $(realpath "$0") )
SCRIPT_PATH=$( dirname "$0")

[ -f $TESTORIGINALSCRIPT_PATH/packagebuilder.sh ] &&
	. $TESTORIGINALSCRIPT_PATH/packagebuilder.sh
[ -f $TESTORIGINALSCRIPT_PATH/packagebuilder.overloader.shinc ] &&
	. $TESTORIGINALSCRIPT_PATH/packagebuilder.overloader.shinc
testExpects="test.expect.shinc"
[ -f $TESTORIGINALSCRIPT_PATH/$testExpects ] &&
	. $TESTORIGINALSCRIPT_PATH/$testExpects

#*
#*  @description    Test setup
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function testSetup()
{
	[ ! -d "$TESTORIGINALSCRIPT_PATH/testdata" ] &&
		bash -c "cp -r $TESTORIGINALSCRIPT_PATH/../testdata $TESTORIGINALSCRIPT_PATH/" &&
		bash -c "mkdir $TESTORIGINALSCRIPT_PATH/testdata/testroot/testhome/testproject/Block1/Unit2/pack"
	return 0
}

#*
#*  @description    Test teardown
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function testTeardown()
{
	return 0
}

#*
#*  @description    Test packageBuilder with no change on packages
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_PACKAGEBUILDER_NOCHANGE ()
{
	jq_output="Block1/Unit1/readme.md"
	isFileExist_return="0"
	isDirExist_return="0<;>0"

	packageBuilder  -jenkinsjob -verbose -user codeman -patchnumber 11 -patchrevision 12223 \
		-project testproject -workspace $TESTORIGINALSCRIPT_PATH/testdata \
		-utilspath /testhome -home /testhome -testroot $TESTORIGINALSCRIPT_PATH/testdata/testroot -buildurl www
	checkrunnerExitCode=$?

	ExpectCall 'jq' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'git' 3
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'ssh' 3
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'runshellcmd' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'mkdir' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'cd' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'rm' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 2
		[ $? -ne 0 ] &&
			return 1
	[ $checkrunnerExitCode -ne 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test packageBuilder with some changes on packages
#*  	- a package is built
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_PACKAGEBUILDER_WITHCHANGES_PACKAGEBUILT ()
{
	jq_output="Block1/Unit2/readme.md<;>readme.md"
	isFileExist_return="0<;>0<;>0"
	isDirExist_return="0<;>0<;>0"

	realpath_output=$TESTORIGINALSCRIPT_PATH/testdata/testroot/testhome/testproject/Block1/Unit2
	packageBuilder -jenkinsjob -verbose -user codeman -patchnumber 11 -patchrevision 12223 \
		-project testproject -workspace $TESTORIGINALSCRIPT_PATH/testdata \
		-utilspath /testhome -home /testhome -testroot $TESTORIGINALSCRIPT_PATH/testdata/testroot -buildurl www
	checkrunnerExitCode=$?

	ExpectCall 'jq' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'git' 3
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'ssh' 3
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'runshellcmd' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'tar' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'mkdir' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'cd' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'rm' 4
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 3
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 3
		[ $? -ne 0 ] &&
			return 1
	[ $checkrunnerExitCode -ne 0 ] &&
		return 1
	return 0
}

#*
#*  @description    Test packageBuilder with some changes on packages
#*  	- a package is built
#*  	- Not tar file is created
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_PACKAGEBUILDER_WITHCHANGES_PACKAGEBUILT_NOTAR ()
{
	jq_output="Block1/Unit2/readme.md<;>readme.md"
	tar_return="1"
	isFileExist_return="0<;>0<;>0"
	isDirExist_return="0<;>0<;>0"

	realpath_output="$TESTORIGINALSCRIPT_PATH/testdata/testroot/testhome/testproject/Block1/Unit2"
	packageBuilder -jenkinsjob -verbose -user codeman -patchnumber 11 -patchrevision 12223 \
		-project testproject -workspace $TESTORIGINALSCRIPT_PATH/testdata \
		-utilspath /testhome -home /testhome -testroot $TESTORIGINALSCRIPT_PATH/testdata/testroot -buildurl www
	checkrunnerExitCode=$?

	ExpectCall 'jq' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'git' 3
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'ssh' 4
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'runshellcmd' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'tar' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'mkdir' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'cd' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'rm' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 3
		[ $? -ne 0 ] &&
			return 1
	[ $checkrunnerExitCode -eq 0 ] &&
		return 1
	return 0
}
#*
#*  @description    Test packageBuilder with some changes on packages
#*  	- no package is built
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_PACKAGEBUILDER_WITHCHANGES_NOPACKAGEBUILT ()
{
	jq_output="Block1/Unit2/readme.md<;>readme.md"
	isFileExist_return="0"
	isDirExist_return="0<;>0<;>1"

	realpath_output=$TESTORIGINALSCRIPT_PATH/testdata/testroot/testhome/testproject/Block1/Unit2
	packageBuilder -jenkinsjob -verbose -user codeman -patchnumber 11 -patchrevision 12223 \
		-project testproject -workspace $TESTORIGINALSCRIPT_PATH/testdata \
		-utilspath /testhome -home /testhome -testroot $TESTORIGINALSCRIPT_PATH/testdata/testroot -buildurl www
	checkrunnerExitCode=$?

	ExpectCall 'jq' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'git' 3
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'ssh' 4
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'runshellcmd' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'tar' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'mkdir' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'cd' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'rm' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 3
		[ $? -ne 0 ] &&
			return 1
	[ $checkrunnerExitCode -eq 0 ] &&
		return 1
	return 0
}


#*
#*  @description    Test packagebuilder
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_PACKAGEBUILDER ()
{
	return 0
}


# Main - run tests
#---------------------------------------
TEST_CASES=( 'TEST_PACKAGEBUILDER_NOCHANGE' \
	'TEST_PACKAGEBUILDER_WITHCHANGES_PACKAGEBUILT' \
	'TEST_PACKAGEBUILDER_WITHCHANGES_PACKAGEBUILT_NOTAR' \
	'TEST_PACKAGEBUILDER_WITHCHANGES_NOPACKAGEBUILT' \
	'TEST_PACKAGEBUILDER' )

exitCode=0
$(testSetup)
for testCase in "${TEST_CASES[@]}"
do
	TESTWORK_DIR=$(bash -c "mktemp -d")
	export TESTWORK_TEMPORARYFOLDER=$TESTWORK_DIR

	echo -e "\n$testCase"

	echo "[RUN]"
	exitCode=1
	$testCase
	exitCode=$?
	[ $exitCode -ne 0 ] &&
		echo "[FAILED]" &&
		exitCode=1 &&
		break

	echo "[PASSED]"

	unset TESTWORK_TEMPORARYFOLDER
	bash -c "rm -r \"$TESTWORK_DIR\""
done
$(testTeardown)

[ $exitCode -ne 0 ] &&
	exit 1

exit 0
