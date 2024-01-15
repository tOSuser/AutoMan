#!/bin/bash
#: jenkinsjobshelper test
#:
#: File : jenkinsjobshelper.test.sh
#
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
TESTORIGINALSCRIPT_PATH=$( dirname $(realpath "$0") )
SCRIPT_PATH=$( dirname "$0")

## Import libraries
[ -f $TESTORIGINALSCRIPT_PATH/jenkinsjobshelper.shinc ] &&
	. $TESTORIGINALSCRIPT_PATH/jenkinsjobshelper.shinc
[ -f $TESTORIGINALSCRIPT_PATH/jenkinsjobshelper.overloader.shinc ] &&
	. $TESTORIGINALSCRIPT_PATH/jenkinsjobshelper.overloader.shinc
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
#*  @description    Test projecttester
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_JENKINSJOBSHELPER ()
{
	return 0
}


# Main - run tests
#---------------------------------------
TEST_CASES=(  \
	'TEST_JENKINSJOBSHELPER' )
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
