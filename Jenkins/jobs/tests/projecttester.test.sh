#!/bin/bash
#: projecttester test
#:
#: File : projecttester.test.sh
#
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
TESTORIGINALSCRIPT_PATH=$( dirname $(realpath "$0") )
SCRIPT_PATH=$( dirname "$0")

## Import libraries
[ -f $TESTORIGINALSCRIPT_PATH/projecttester.sh ] &&
	. $TESTORIGINALSCRIPT_PATH/projecttester.sh
[ -f $TESTORIGINALSCRIPT_PATH/projecttester.overloader.shinc ] &&
	. $TESTORIGINALSCRIPT_PATH/projecttester.overloader.shinc
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
#*  @description    Test projecttester - no new commits
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_PROJECTTESTER_NONEWCOMMIT ()
{
	date_output='2023-09-28'
	ssh_output='{"type": "stats","rowCount": 1,"runTimeMilliseconds": 2,"moreChanges": false}'
	jq_output="0"
	mktemp_output="tmpfolder"
	projectTester -jenkinsjob -verbose -user codeman \
		-project testproject -workspace $TESTORIGINALSCRIPT_PATH/testdata \
		-utilspath /testhome -home /testhome -days 2
	projectTesterExitCode=$?

	ExpectCall 'date' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'ssh' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'jq' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 0
		[ $? -ne 0 ] &&
			return 1
	[ $projectTesterExitCode -ne 0 ] &&
		return 1

	return 0

}

#*
#*  @description    Test projecttester - 1 new commits
#*  	Test projecttester when :
#*  		- 1 new commit
#*  		- All tests are passed
#*  		- No comment needs to be commented
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_PROJECTTESTER_ALLTESTSPASS_NOCOMMENTNEED ()
{
	date_output='2023-09-28<;>2023-09-28 11:11'
	ssh_output='{"type": "stats","rowCount": 1,"runTimeMilliseconds": 2,"moreChanges": false}'
	ssh_output="$ssh_output<;>mergedCommitComments"
	ssh_output="$ssh_output<;>mergedCommitDetails"

	jq_output="1"
	jq_output="$jq_output<;>commitInfo"
	jq_output="$jq_output<;>commitMessage"
	jq_output="$jq_output<;>commitId"
	jq_output="$jq_output<;>commitNumber"
	jq_output="$jq_output<;>commitSubject"
	jq_output="$jq_output<;>commitUrl"
	jq_output="$jq_output<;>commitOwnerUserName"
	jq_output="$jq_output<;>commitOwnerMail"
	jq_output="$jq_output<;>commitMergedReversion"
	jq_output="$jq_output<;>0"

	jq_output="$jq_output<;>comments"
	jq_output="$jq_output<;>mergeComment"
	jq_output="$jq_output<;>timestamp"

	mktemp_output="tmpfolder"
	column_output="unitName<:>unit/path<:>PASSED"
	runshellcmd_return=0
	isFileExist_return="0<;>0<;>0<;>0<;>0"
	isDirExist_return="0<;>0"
	grep_output="1<;>0"

	projectTester -jenkinsjob -verbose -user codeman \
		-project testproject -workspace $TESTORIGINALSCRIPT_PATH/testdata \
		-utilspath /testhome -home /testhome -days 2
	projectTesterExitCode=$?

	ExpectCall 'date' 2
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'ssh' 3
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'jq' 14
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'git' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'cd' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'mktemp' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'runshellcmd' 8
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'affectedByCommit' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'runtrun' 4
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'putToFile' 7
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'rm' 6
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 8
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 3
		[ $? -ne 0 ] &&
			return 1
	[ $projectTesterExitCode -ne 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test projecttester - 1 new commits
#*  	Test projecttester when :
#*  		- 1 new commit
#*  		- All tests are passed
#*  		- One commit needs to be commented
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_PROJECTTESTER_ALLTESTSPASS_ONECOMMENTNEED ()
{
	date_output='2023-09-28<;>2023-09-28 11:11'
	ssh_output='{"type": "stats","rowCount": 1,"runTimeMilliseconds": 2,"moreChanges": false}'
	ssh_output="$ssh_output<;>mergedCommitComments"
	ssh_output="$ssh_output<;>mergedCommitDetails"

	jq_output="1"
	jq_output="$jq_output<;>commitInfo"
	jq_output="$jq_output<;>commitMessage"
	jq_output="$jq_output<;>commitId"
	jq_output="$jq_output<;>commitNumber"
	jq_output="$jq_output<;>commitSubject"
	jq_output="$jq_output<;>commitUrl"
	jq_output="$jq_output<;>commitOwnerUserName"
	jq_output="$jq_output<;>commitOwnerMail"
	jq_output="$jq_output<;>commitMergedReversion"
	jq_output="$jq_output<;>1"

	jq_output="$jq_output<;>comments"
	jq_output="$jq_output<;>mergeComment"
	jq_output="$jq_output<;>timestamp"

	jq_output="$jq_output<;>notimportant<;>notimportant<;>0"

	mktemp_output="tmpfolder"
	column_output="unitName unit/path PASSED"
	runshellcmd_return=0

	isFileExist_return="0<;>0<;>0<;>0<;>0"
	isDirExist_return="0<;>0"
	grep_output="4<;>0"

	projectTester -jenkinsjob -verbose -user codeman \
		-project testproject -workspace $TESTORIGINALSCRIPT_PATH/testdata \
		-utilspath /testhome -home /testhome -days 2
	projectTesterExitCode=$?

	ExpectCall 'date' 2
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'ssh' 3
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'jq' 14
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'git' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'cd' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'mktemp' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'runshellcmd' 8
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'affectedByCommit' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'runtrun' 4
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'putToFile' 7
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'column' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'rm' 6
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 8
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 3
		[ $? -ne 0 ] &&
			return 1
	[ $projectTesterExitCode -ne 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test projecttester - 1 new commits
#*  	Test projecttester when :
#*  		- 1 new commit
#*  		- 1 tests are passed
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_PROJECTTESTER_ONETESTPASS ()
{
	date_output='2023-09-28<;>2023-09-28 11:11'
	ssh_output='{"type": "stats","rowCount": 1,"runTimeMilliseconds": 2,"moreChanges": false}'
	ssh_output="$ssh_output<;>mergedCommitComments"
	ssh_output="$ssh_output<;>mergedCommitDetails"

	jq_output="1"
	jq_output="$jq_output<;>commitInfo"
	jq_output="$jq_output<;>commitMessage"
	jq_output="$jq_output<;>commitId"
	jq_output="$jq_output<;>commitNumber"
	jq_output="$jq_output<;>commitSubject"
	jq_output="$jq_output<;>commitUrl"
	jq_output="$jq_output<;>commitOwnerUserName"
	jq_output="$jq_output<;>commitOwnerMail"
	jq_output="$jq_output<;>commitMergedReversion"

	jq_output="$jq_output<;>comments"
	jq_output="$jq_output<;>mergeComment"
	jq_output="$jq_output<;>timestamp"

	mktemp_output="tmpfolder"

	column_output="unitName unit/path PASSED"
	column_output="$column_output<;>Number Subject Username email"

	runshellcmd_return="0<;>1<;>1<;>1"
	runtrun_return=0
	isFileExist_return="0<;>0<;>0<;>0<;>0"
	isDirExist_return="0<;>0"
	grep_output="1<;>3"

	projectTester -jenkinsjob -verbose -user codeman \
		-project testproject -workspace $TESTORIGINALSCRIPT_PATH/testdata \
		-utilspath /testhome -home /testhome -days 2
	projectTesterExitCode=$?

	ExpectCall 'date' 2
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'ssh' 3
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'jq' 13
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'git' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'cd' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'mktemp' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'runshellcmd' 8
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'affectedByCommit' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'runtrun' 4
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'putToFile' 8
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'column' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'rm' 6
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 8
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 3
		[ $? -ne 0 ] &&
			return 1
	[ $projectTesterExitCode -eq 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test projecttester
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_PROJECTTESTER ()
{
	return 0
}


# Main - run tests
#---------------------------------------
TEST_CASES=( 'TEST_PROJECTTESTER_NONEWCOMMIT' \
	'TEST_PROJECTTESTER_ALLTESTSPASS_NOCOMMENTNEED' \
	'TEST_PROJECTTESTER_ALLTESTSPASS_ONECOMMENTNEED' \
	'TEST_PROJECTTESTER_ONETESTPASS' \
	'TEST_PROJECTTESTER' )
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
