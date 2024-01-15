#!/bin/bash
#: ccrun test
#:
#: File : ccrun.test.sh
#
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
## Import libraries
TESTORIGINALSCRIPT_PATH=$( dirname $(realpath "$0") )
TESTSCRIPT_PATH=$( dirname "$0")

[ -f $TESTORIGINALSCRIPT_PATH/repoutils/ccrun ] &&
	. $TESTORIGINALSCRIPT_PATH/repoutils/ccrun
[ -f $TESTORIGINALSCRIPT_PATH/ccrun.overloader.shinc ] &&
	. $TESTORIGINALSCRIPT_PATH/ccrun.overloader.shinc
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
#*  @description    Test ccrun non-git folder
#*  	Test ccrun when :
#*  		- current folder is not a git folder
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CCRUN_NOGITFOLDER ()
{
	pwd_output="non-gitfolder"
	git_return=1
	mktemp_output="tmpfolder"
	ccrun -verbose -rawmode
	ccrunExitCode=$?

	ExpectCall 'git' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'column' 0
		[ $? -ne 0 ] &&
			return 1
	[ $ccrunExitCode -eq 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test ccrun in a git folder
#*  	Test ccrun when :
#*  		- current folder is a git folder
#*  		- modules folder is found
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CCRUN_GITMODE ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdata/testproject
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdata/testproject
	mktemp_output="tmpfolder"
	column_output="unitName<:>unit/path<:>PASSED"
	isFileExist_return="0<;>0"
	isDirExist_return="0"
	grep_output="1<;>0"

	ccrun -verbose -rawmode
	ccrunExitCode=$?

	ExpectCall 'git' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runshellcmd' 2
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'affectedByCommit' 2
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runtrun' 4
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'column' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'grep' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 1
		[ $? -ne 0 ] &&
			return 1
	[ $ccrunExitCode -ne 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test ccrun in a git folder mode - with path
#*  	Test ccrun when :
#*  		- current folder is a git folder
#*  		- modules folder is found
#*  		- path of unit is passed as arg
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CCRUN_GITMODE_WITHPATH ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdata/testproject
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdata//testproject
	mktemp_output="tmpfolder"
	column_output="unitName<:>unit/path<:>PASSED"
	isFileExist_return="0<;>0"
	isDirExist_return="0"
	grep_output="1<;>0"

	ccrun runtest -verbose -rawmode -path $TESTORIGINALSCRIPT_PATH/testdata/testproject/Block1/Unit1
	ccrunExitCode=$?

	ExpectCall 'git' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runshellcmd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'affectedByCommit' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runtrun' 2
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'column' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'grep' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 1
		[ $? -ne 0 ] &&
			return 1
	[ $ccrunExitCode -ne 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test ccrun passing paths
#*  	Test ccrun when :
#*  		- no modules folder is found
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CCRUN_PATHMODE_NOMODULE ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdata
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdata
	ccrun -rawmode -verbose -utilspath /unknown \
		-projectroot $TESTORIGINALSCRIPT_PATH/testdata/testproject
	ccrunExitCode=$?

	ExpectCall 'git' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'column' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'grep' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 0
		[ $? -ne 0 ] &&
			return 1
	[ $ccrunExitCode -eq 0 ] &&
		return 1
	return 0
}

#*
#*  @description    Test ccrun with passing paths - without path
#*  	Test ccrun when :
#*  		- no path is passed
#*  		- utils path is passed
#*  		- home path is passed
#*  		- modules folder is found
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CCRUN_PATHMODE_WITHOUTPATH ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdata/testproject
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdata/testproject
	mktemp_output="tmpfolder"
	column_output="unitName<:>unit/path<:>PASSED"
	isFileExist_return="0<;>0"
	isDirExist_return="0"
	grep_output="1<;>0"

	ccrun runtest -rawmode -verbose -utilspath $TESTORIGINALSCRIPT_PATH \
		-projectroot $TESTORIGINALSCRIPT_PATH/testdata/testproject
	ccrunExitCode=$?

	ExpectCall 'git' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runshellcmd' 2
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'affectedByCommit' 2
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runtrun' 4
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'column' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'grep' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 1
		[ $? -ne 0 ] &&
			return 1
	[ $ccrunExitCode -ne 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test ccrun with passing paths - with path
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
function TEST_CCRUN_PATHMODE_WITHPATH ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdata
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdata
	mktemp_output="tmpfolder"
	column_output="unitName<:>unit/path<:>PASSED"
	isFileExist_return="0<;>0"
	isDirExist_return="0"
	grep_output="1<;>0"

	ccrun runtest -rawmode -verbose -utilspath $TESTORIGINALSCRIPT_PATH \
		-projectroot $TESTORIGINALSCRIPT_PATH/testdata/testproject \
		-path $TESTORIGINALSCRIPT_PATH/testdata/testproject/Block1/Unit1
	ccrunExitCode=$?

	ExpectCall 'git' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runshellcmd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'affectedByCommit' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runtrun' 2
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'column' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'grep' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 2
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 1
		[ $? -ne 0 ] &&
			return 1
	[ $ccrunExitCode -ne 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test ccrun in a git folder - unknown cmd
#*  	Test ccrun when :
#*  		- path is passed
#*  		- no utils path is passed
#*  		- no home path is passed
#*  		- modules folder is found
#*  		- invalid command
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CCRUN_GITMODE_UNKNOWN_CMD ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdata
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdata
	mktemp_output="tmpfolder"
	isFileExist_return="0"
	isDirExist_return="0"

	ccrun unknoncmd -verbose -rawmode -utilspath $TESTORIGINALSCRIPT_PATH \
		-path $TESTORIGINALSCRIPT_PATH/testdata/testproject/Block1/Unit1
	ccrunExitCode=$?

	ExpectCall 'git' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runshellcmd' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'affectedByCommit' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runtrun' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'column' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'grep' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 1
		[ $? -ne 0 ] &&
			return 1
	[ $ccrunExitCode -eq 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test ccrun in a git folder - valid cmd
#*  	Test ccrun when :
#*  		- path is passed
#*  		- no utils path is passed
#*  		- no home path is passed
#*  		- modules folder is found
#*  		- valid command
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CCRUN_GITMODE_VALID_CMD ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdata/testproject
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdata/testproject
	isFileExist_return="0"
	isDirExist_return="0"

	mktemp_output="tmpfolder"
	ccrun clean -verbose -rawmode -utilspath $TESTORIGINALSCRIPT_PATH \
		-path $TESTORIGINALSCRIPT_PATH/testdata/testproject/Block1/Unit2
	ccrunExitCode=$?

	ExpectCall 'git' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runshellcmd' 8
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'affectedByCommit' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runtrun' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'column' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'grep' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 1
		[ $? -ne 0 ] &&
			return 1

	[ $ccrunExitCode -ne 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test ccrun in a git folder - valid cmd without path
#*  	Test ccrun when :
#*  		- no path is passed
#*  		- no utils path is passed
#*  		- no home path is passed
#*  		- modules folder is found
#*  		- valid command
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CCRUN_GITMODE_VALID_CMD_WITHOUTPATH ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdata/testproject
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdata/testproject
	mktemp_output="tmpfolder"
	isFileExist_return="0"
	isDirExist_return="0"

	ccrun clean -verbose -rawmode
	ccrunExitCode=$?

	ExpectCall 'git' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runshellcmd' 16
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'affectedByCommit' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runtrun' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'column' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'grep' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 1
		[ $? -ne 0 ] &&
			return 1
	[ $ccrunExitCode -ne 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test ccrun passin paths - unknown cmd without path
#*  	Test ccrun when :
#*  		- no path is passed
#*  		- utils path is passed
#*  		- home path is passed
#*  		- modules folder is found
#*  		- unknown command
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CCRUN_PATHMODE_UNKNOWN_CMD_WITHOUTPATH ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdata/testproject
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdata/testproject
	mktemp_output="tmpfolder"
	isFileExist_return="0"
	isDirExist_return="0"

	ccrun unknoncmd -rawmode -verbose -utilspath $TESTORIGINALSCRIPT_PATH \
		-projectroot $TESTORIGINALSCRIPT_PATH/testdata/testproject
	ccrunExitCode=$?

	ExpectCall 'git' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runshellcmd' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'affectedByCommit' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runtrun' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'column' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'grep' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 1
		[ $? -ne 0 ] &&
			return 1
	[ $ccrunExitCode -eq 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test ccrun passing paths - valid cmd without path
#*  	Test ccrun when :
#*  		- no path is passed
#*  		- utils path is passed
#*  		- home path is passed
#*  		- modules folder is found
#*  		- valid command
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CCRUN_PATHMODE_VALID_CMD_WITHOUTPATH ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdata/testproject
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdata/testproject
	mktemp_output="tmpfolder"
	isFileExist_return="0"
	isDirExist_return="0"

	ccrun pack -rawmode -verbose -utilspath $TESTORIGINALSCRIPT_PATH \
		-projectroot $TESTORIGINALSCRIPT_PATH/testdata/testproject
	ccrunExitCode=$?

	ExpectCall 'git' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runshellcmd' 8
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'affectedByCommit' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runtrun' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'column' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'grep' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 1
		[ $? -ne 0 ] &&
			return 1
	[ $ccrunExitCode -ne 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test ccrun passing paths - valid cmd with path
#*  	Test ccrun when :
#*  		- path is passed
#*  		- utils path is passed
#*  		- home path is passed
#*  		- modules folder is found
#*  		- valid command
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CCRUN_PATHMODE_VALID_CMD_WITHPATH_1 ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdata
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdata
	mktemp_output="tmpfolder"
	isFileExist_return="0"
	isDirExist_return="0"

	ccrun pack -rawmode -verbose -utilspath $TESTORIGINALSCRIPT_PATH \
		-projectroot $TESTORIGINALSCRIPT_PATH/testdata/testproject \
		-path $TESTORIGINALSCRIPT_PATH/testdata/testproject/Block1/Unit1
	ccrunExitCode=$?

	ExpectCall 'git' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runshellcmd' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'affectedByCommit' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runtrun' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'column' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'grep' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 1
		[ $? -ne 0 ] &&
			return 1
	[ $ccrunExitCode -ne 0 ] &&
		return 1

	return 0
}

#*
#*  @description    Test ccrun passing paths - valid cmd with path
#*  	Test ccrun when :
#*  		- path is passed
#*  		- utils path is passed
#*  		- home path is passed
#*  		- modules folder is found
#*  		- valid command
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_CCRUN_PATHMODE_VALID_CMD_WITHPATH_2 ()
{
	git_output=$TESTORIGINALSCRIPT_PATH/testdatatestproject/
	git_return=0
	pwd_output=$TESTORIGINALSCRIPT_PATH/testdatatestproject/
	mktemp_output="tmpfolder"
	isFileExist_return="0"
	isDirExist_return="0"

	ccrun pack -product -rawmode -verbose \
		-utilspath $TESTORIGINALSCRIPT_PATH \
		-projectroot $TESTORIGINALSCRIPT_PATH/testdata/testproject \
		-path $TESTORIGINALSCRIPT_PATH/testdata/testproject/Block1/Unit2
	ccrunExitCode=$?

	ExpectCall 'git' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'pwd' 1
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runshellcmd' 8
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'affectedByCommit' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'runtrun' 0
	[ $? -ne 0 ] &&
		return 1
	ExpectCall 'column' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'grep' 0
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isFileExist' 1
		[ $? -ne 0 ] &&
			return 1
	ExpectCall 'isDirExist' 1
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
function TEST_CCRUN ()
{
	return 0
}

# Main - run tests
#---------------------------------------
TEST_CASES=( \
	'TEST_CCRUN_NOGITFOLDER' \
	'TEST_CCRUN_GITMODE' \
	'TEST_CCRUN_GITMODE_WITHPATH' \
	'TEST_CCRUN_PATHMODE_NOMODULE' \
	'TEST_CCRUN_PATHMODE_WITHOUTPATH' \
	'TEST_CCRUN_PATHMODE_WITHPATH' \
	'TEST_CCRUN_GITMODE_UNKNOWN_CMD' \
	'TEST_CCRUN_GITMODE_VALID_CMD' \
	'TEST_CCRUN_GITMODE_VALID_CMD_WITHOUTPATH' \
	'TEST_CCRUN_PATHMODE_UNKNOWN_CMD_WITHOUTPATH' \
	'TEST_CCRUN_PATHMODE_VALID_CMD_WITHOUTPATH' \
	'TEST_CCRUN_PATHMODE_VALID_CMD_WITHPATH_1' \
	'TEST_CCRUN_PATHMODE_VALID_CMD_WITHPATH_2' \
	'TEST_CCRUN' )
#TEST_CASES=( '' )

exitCode=0
testSetup
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
