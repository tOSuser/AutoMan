#!/bin/bash
#: trun test
#:
#: File : trun.test.sh
#
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
## Import libraries
TESTORIGINALSCRIPT_PATH=$( dirname $(realpath "$0") )
TESTSCRIPT_PATH=$( dirname "$0")

[ -f $TESTORIGINALSCRIPT_PATH/repoutils/trun ] &&
	. $TESTORIGINALSCRIPT_PATH/repoutils/trun
[ -f $TESTORIGINALSCRIPT_PATH/trun.overloader.shinc ] &&
	. $TESTORIGINALSCRIPT_PATH/trun.overloader.shinc
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
#*  @description    Test trun non-git folder
#*  	Test ccrun when :
#*  		- current folder is not a git folder
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_TRUN_NOGITFOLDER ()
{
	pwd_output="non-gitfolder"
	git_return=1
	trun
	trunExitCode=$?

	ExpectCall 'git' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'isFileExist' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 0
		[ $? -ne 0 ] &&
			return 1
	[ $trunExitCode -eq 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test trun in a git folder
#*  	Test ccrun when :
#*  		- current folder is a git folder
#*  		- modules folder is found
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_TRUN_GITMODE ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdata
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdata
	isFileExist_return="0<;>0<;>0"
	isDirExist_return="0"

	trun -u -verbose -rawmode -path $TESTORIGINALSCRIPT_PATH/testdata/testproject/Block1/Unit1
	trunExitCode=$?

	ExpectCall 'git' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'isFileExist' 3
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'dumpyTestRunner' 2
	[ $? -ne 0 ] &&
		return 1
	[ $trunExitCode -ne 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test trun passing paths
#*  	Test ccrun when :
#*  		- current folder is a git folder
#*  		- no modules folder is found
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_TRUN_PATHMODE_NOMODULE ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdata
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdata

	trun -u -rawmode -verbose -path $TESTORIGINALSCRIPT_PATH/testdata/testproject/Block1/Unit1 \
		-projectroot $TESTORIGINALSCRIPT_PATH/testdata/testproject \
		-utilspath /unknown
	trunExitCode=$?

	ExpectCall 'git' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'isFileExist' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'dumpyTestRunner' 0
	[ $? -ne 0 ] &&
		return 1
	[ $trunExitCode -eq 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test trun passing path - with path
#*  	Test ccrun when :
#*  		- path is passed
#*  		- utils path is passed
#*  		- home path is passed
#*  		- modules folder is found
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_TRUN_PATHMODE_WITHPATH ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdata
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdata
	isFileExist_return="0<;>0<;>0"
	isDirExist_return="0"

	trun -b -rawmode -verbose -utilspath $TESTORIGINALSCRIPT_PATH \
		-projectroot $TESTORIGINALSCRIPT_PATH/testdata/testproject \
		-path $TESTORIGINALSCRIPT_PATH/testdata/testproject/Block1/Unit1
	ccrunExitCode=$?

	ExpectCall 'git' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'isFileExist' 3
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 1
		[ $? -ne 0 ] &&
			return 1

	ExpectCall 'dumpyTestRunner' 1
	[ $? -ne 0 ] &&
		return 1
	[ $ccrunExitCode -ne 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test ccrun
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_TRUN ()
{
	return 0
}

# Main - run tests
#---------------------------------------
TEST_CASES=( 'TEST_TRUN_NOGITFOLDER' \
	'TEST_TRUN_GITMODE' \
	'TEST_TRUN_PATHMODE_NOMODULE' \
	'TEST_TRUN_PATHMODE_WITHPATH' \
	'TEST_TRUN' )
#TEST_CASES=( 'TEST_TRUN' )

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
