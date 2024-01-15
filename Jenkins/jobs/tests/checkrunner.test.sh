#!/bin/bash
#: checkrunner test
#:
#: File : checkrunner.test.sh
#
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
## Import libraries
TESTORIGINALSCRIPT_PATH=$( dirname $(realpath "$0") )
SCRIPT_PATH=$( dirname "$0")

[ -f $TESTORIGINALSCRIPT_PATH/checkrunner.sh ] &&
	. $TESTORIGINALSCRIPT_PATH/checkrunner.sh
[ -f $TESTORIGINALSCRIPT_PATH/checkrunner.overloader.shinc ] &&
	. $TESTORIGINALSCRIPT_PATH/checkrunner.overloader.shinc
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
		bash -c "cp -r $TESTORIGINALSCRIPT_PATH/../testdata $TESTORIGINALSCRIPT_PATH/"
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
#*  @description    Test checkrunner with a system files patch-set 
#*  	Test checkrunner when :
#*  		- patch-set conatins only system files
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CHECKRUNNER_SYSTEMFILES ()
{
	grep_output=".codechecker<:>.testfiles"
	mktemp_output="tmpfolder"
	checkRunner -jenkinsjob -verbose -user codeman -patchnumber 11 -patchrevision 12223 -changenumber 734223748 \
		-project testproject -workspace $TESTORIGINALSCRIPT_PATH/testdata \
		-utilspath /testhome -home /testhome
	checkrunnerExitCode=$?

	ExpectCall 'grep' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'jq' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'ssh' 3
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'column' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 0
		[ $? -ne 0 ] &&
			return 1
	[ $checkrunnerExitCode -eq 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test checkrunner with a patch-set
#*  				mix of system files and other files
#*  	Test checkrunner when :
#*  		- patch-set conatins system files and other files
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CHECKRUNNER_MIXFILES ()
{
	grep_output=".codechecker<:>readme.md"
	mktemp_output="tmpfolder"
	column_output="unitName<:>unit/path<:>PASSED"
	checkRunner -jenkinsjob -verbose -user codeman -patchnumber 11 -patchrevision 12223 -changenumber 734223748 \
		-project testproject -workspace $TESTORIGINALSCRIPT_PATH/testdata \
		-utilspath /testhome -home /testhome
	checkrunnerExitCode=$?

	ExpectCall 'grep' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'jq' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'ssh' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'column' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 0
		[ $? -ne 0 ] &&
			return 1
	[ $checkrunnerExitCode -eq 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test checkrunner with a patch-set
#*  				with no system file
#*  	Test checkrunner when :
#*  		- patch-set conatins no system files
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CHECKRUNNER_NOSYSTEMFILE ()
{
	mktemp_output="tmpfolder"
	column_output="unitName<:>unit/path<:>PASSED"
	isFileExist_return="0<;>0"
	isDirExist_return="0"
	grep_output="readme.md<;>4<;>0"
	
	checkRunner -jenkinsjob -verbose -user codeman -patchnumber 11 -patchrevision 12223 -changenumber 734223748 \
		-project testproject -workspace $TESTORIGINALSCRIPT_PATH/testdata \
		-utilspath /testhome -home /testhome
	checkrunnerExitCode=$?

	ExpectCall 'grep' 3
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'jq' 3
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'ssh' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'git' 5
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'cd' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'rm' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'column' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 1
		[ $? -ne 0 ] &&
			return 1
	[ $checkrunnerExitCode -ne 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test checkrunner
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CHECKRUNNER ()
{
	return 0
}


# Main - run tests
#---------------------------------------
TEST_CASES=( 'TEST_CHECKRUNNER_SYSTEMFILES' \
	'TEST_CHECKRUNNER_MIXFILES' \
	'TEST_CHECKRUNNER_NOSYSTEMFILE' \
	'TEST_CHECKRUNNER' )

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
