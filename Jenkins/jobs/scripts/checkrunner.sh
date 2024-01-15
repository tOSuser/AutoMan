#!/bin/bash
#: checkrunner to use within Jenkins Pipline
#:
#: File : checkrunner.sh
#
#
# Copyright (c) 2022 Nexttop (nexttop.se)
#---------------------------------------
#
# Environment variables passd by Gerrit trigger:
#   GERRIT_EVENT_TYPE
#   GERRIT_EVENT_HASH
#   GERRIT_CHANGE_WIP_STATE
#   GERRIT_CHANGE_PRIVATE_STATE
#   GERRIT_BRANCH
#   GERRIT_TOPIC
#   GERRIT_CHANGE_NUMBER
#   GERRIT_CHANGE_ID
#   GERRIT_PATCHSET_NUMBER
#   GERRIT_PATCHSET_REVISION
#   GERRIT_REFSPEC
#   GERRIT_PROJECT
#   GERRIT_CHANGE_SUBJECT
#   GERRIT_CHANGE_COMMIT_MESSAGE
#   GERRIT_CHANGE_URL (link)
#   GERRIT_CHANGE_OWNER
#   GERRIT_CHANGE_OWNER_NAME
#   GERRIT_CHANGE_OWNER_EMAIL
#   GERRIT_PATCHSET_UPLOADER
#   GERRIT_PATCHSET_UPLOADER_NAME
#   GERRIT_PATCHSET_UPLOADER_EMAIL
#   GERRIT_NAME
#   GERRIT_HOST
#   GERRIT_PORT
#   GERRIT_SCHEME
#   GERRIT_VERSION
#
# Environment variables passd by Jenkins:
#   JENKINS_URL
#   PWD
#   WORKSPACE
#   RUN_DISPLAY_URL
#   RUN_CHANGES_DISPLAY_URL
#   RUN_TESTS_DISPLAY_URL
#   NODE_NAME
#   JOB_BASE_NAME
#   JOB_URL
#   BUILD_ID
#   BUILD_NUMBER
#   BUILD_URL
#
# Local variables:
#
#---------------------------------------
ORIGINALSCRIPT_PATH=$( dirname $(realpath "$0") )
SCRIPT_PATH=$( dirname "$0")

TEMPEXTRACTION_DIR=''
TEMPEXTRACTION_FULLPATH=$TEMPEXTRACTION_DIR
TESTRESULTREPORT_FILE='testsresultreport'
failstopmode=1
generalFailure=0
UPDATEDFULLPATH_ARR=()

## Import libraries
[ -f $ORIGINALSCRIPT_PATH/jenkinsjobshelper.shinc ] &&
    . $ORIGINALSCRIPT_PATH/jenkinsjobshelper.shinc

function runshellcmd () {
    cmdstr="unshare -mr chroot $CHROOT_PATH bash -c \"$1\""
    echo "runshellcmd: \"$1\""
    eval $cmdstr
    return $?
}

function runtrun () #@ USAGE runtrun unitName unitPath testGroup param1 param2 ...
{
    unitName=$1
    unitPath=$2
    testGroup=$3
    verbosetracer $verbosemode "runtrun: $unitName, $unitPath , reportfile $TEMPEXTRACTION_DIR/$TESTRESULTREPORT_FILE, $TEMPEXTRACTION_FULLPATH/$TESTRESULTREPORT_FILE"

    [ ! -f $TEMPEXTRACTION_FULLPATH/$TESTRESULTREPORT_FILE ] &&
        echo "|UnitName|unitPath|testGroup|testType|Result" | putToFile "$TEMPEXTRACTION_FULLPATH/$TESTRESULTREPORT_FILE" &&
        echo "|-----|-----|-----|-----|-----" | putToFile "$TEMPEXTRACTION_FULLPATH/$TESTRESULTREPORT_FILE"

    runshellcmd "${@:4} -reportfile $TEMPEXTRACTION_DIR/$TESTRESULTREPORT_FILE -unitname $unitName -unitpath $unitPath"
    testResult=$?
    [ $testResult -ne 0 ] &&
        generalFailure=1

    [ $failstopmode -eq 0 ] &&
        return $testResult
    return 0
}

function affectedByCommit () #@ USAGE affectedByCommit projectPath unitPath unitName  param1 param2 ...
{
    projectPath=$1
    unitPath=$2
    unitName=$3

    verbosetracer $verbosemode "Looking fo changes on '$unitName' at '$unitPath'"

    projectNeedToTest=0
    sourceArr=($(echo "$( < ${projectPath}/$unitPath/.sourcepaths)" | \
        jq -r '.[] | if type=="array" then .[0] else . end'))

    for sourceitem in ${sourceArr[@]}
    do
        fullpath=$(realpath ${projectPath}/$unitPath/$sourceitem)
        dependencypath=${fullpath#$projectPath/}

        #verbosetracer $verbosemode "${projectPath}/$unitPath/$sourceitem"
        #verbosetracer $verbosemode "fullpath $fullpath"
        #verbosetracer $verbosemode "projectPath $projectPath"
        #verbosetracer $verbosemode "dependencypath $dependencypath"

        for updateditem in ${UPDATEDFULLPATH_ARR[@]}
        do
            updateditempath=$(dirname $updateditem)
            verbosetracer $verbosemode "Looing for $updateditempath in $dependencypath"
            [[ "$updateditempath" == "$dependencypath"* ]] &&
                verbosetracer $verbosemode "Some files in $dependencypath have been changed (${updateditem##*/})" &&
                    projectNeedToTest=1 &&
                    break
        done
    done
    [ $projectNeedToTest -eq 1 ] &&
        return 0

    verbosetracer $verbosemode "'$unitName' at '$unitPath' was not affected by this commit."
    return 1
}

function checkRunner () #@ USAGE checkRunner param1 param2 ...
{
    ## Initialize values
    nextitem=$(lookForArgument "-nosyscheck" "$@")
    nosyscheckmode=$?
    nextitem=$(lookForArgument "-product" "$@")
    productmode=$?
    nextitem=$(lookForArgument "-verbose" "$@")
    verbosemode=$?
    nextitem=$(lookForArgument "-keep" "$@")
    keeptempfiles=$?
    nextitem=$(lookForArgument "-jenkinsjob" "$@")
    jenkinsjobmode=$?
    nextitem=$(lookForArgument "-rawmode" "$@")
    rawmode=$?
    nextitem=$(lookForArgument "-debug" "$@")
    debugmode=$?
    nextitem=$(lookForArgument "-info" "$@")
    infomode=$?
    nextitem=$(lookForArgument "-failstop" "$@")
    failstopmode=$?
    nextitem=$(lookForArgument "-color" "$@")
    colormode=$?
    if [ $jenkinsjobmode -eq 0 ] || [ $rawmode -eq 0 ]; then
        colormode=1
    fi

    GERRITURLPATH=gerrit.yourgerritserver.yoursite
    GERRITPATH=gerrit.yourgerritserver.yoursite:29418
    GITUSER=gituser
    GITUSEREMAIL=gituser@youremail.yoursite
    nextitem=$(lookForArgument "-user" "$@")
    manualUserMode=$?
    [ $manualUserMode -eq 0 ] &&
        GITUSER=$nextitem

    patchsetNumber=$GERRIT_PATCHSET_NUMBER
    nextitem=$(lookForArgument "-patchnumber" "$@")
    manualPatchNumberMode=$?
    [ $manualPatchNumberMode -eq 0 ] &&
        patchsetNumber=$nextitem

    patchsetRevision=$GERRIT_PATCHSET_REVISION
    nextitem=$(lookForArgument "-patchrevision" "$@")
    manualPatchRevisionMode=$?
    [ $manualPatchRevisionMode -eq 0 ] &&
        patchsetRevision=$nextitem

    patchsetChangeNumber=$GERRIT_CHANGE_NUMBER
    nextitem=$(lookForArgument "-changenumber" "$@")
    manualChangeNumberMode=$?
    [ $manualChangeNumberMode -eq 0 ] &&
        patchsetChangeNumber=$nextitem

    projectName=$GERRIT_PROJECT
    nextitem=$(lookForArgument "-project" "$@")
    manualProjectMode=$?
    [ $manualProjectMode -eq 0 ] &&
        projectName=$nextitem

    workspacePath=$WORKSPACE
    nextitem=$(lookForArgument "-workspace" "$@")
    manualWorkspaceMode=$?
    [ $manualWorkspaceMode -eq 0 ] &&
        workspacePath=$nextitem

    currentHome=$HOME
    nextitem=$(lookForArgument "-home" "$@")
    manualHomeMode=$?
    [ $manualHomeMode -eq 0 ] &&
        currentHome=$nextitem

    repoUtilssHome=$HOME
    nextitem=$(lookForArgument "-utilspath" "$@")
    manualUtilsPathMode=$?
    [ $manualUtilsPathMode -eq 0 ] &&
        repoUtilssHome=$nextitem

    verbosetracer $verbosemode "GERRIT_PATCHSET_NUMBER -patchnumber $patchsetNumber"
    verbosetracer $verbosemode "GERRIT_PATCHSET_REVISION -patchrevision $patchsetRevision"
    verbosetracer $verbosemode "GERRIT_CHANGE_NUMBER -changenumber $patchsetChangeNumber"
    verbosetracer $verbosemode "GERRIT_PROJECT -project $projectName"
    verbosetracer $verbosemode "WORKSPACE -workspace $workspacePath"

    # Create a list of the files that have been changed
    currentpatchnumber=$(($patchsetNumber-1))
    UPDATEDFULLPATH=$(ssh -p 29418 $GITUSER@$GERRITURLPATH gerrit query --format=JSON --files --patch-sets $patchsetRevision | \
        jq -r ".patchSets[$currentpatchnumber].files[]? | .file")
    UPDATEDFULLPATH_ARR=( $UPDATEDFULLPATH )
    UPDATEDFILES_ARR=( $(echo "$UPDATEDFULLPATH" | \
        grep -oP "[^/]*$") )

    PATCHSET_TOTALFILES=0
    PATCHSET_TOTALENVFILES=0
    for fname in "${UPDATEDFILES_ARR[@]}"
    do
        PATCHSET_TOTALFILES=$(($PATCHSET_TOTALFILES+1))
        [[ "$fname" == "."* ]] && PATCHSET_TOTALENVFILES=$(($PATCHSET_TOTALENVFILES+1))

        echo "$fname"
    done
    echo "Total files: $PATCHSET_TOTALFILES"
    echo "Total envionment files: $PATCHSET_TOTALENVFILES"

    # Check environment files pushed by the patch-set
    if [ $PATCHSET_TOTALENVFILES -ne 0 ] && [ $nosyscheckmode -ne 0 ]; then
        if [ $PATCHSET_TOTALENVFILES -eq $(($PATCHSET_TOTALFILES-1)) ]; then
            reviewstr="Commits with environment files need to be verified manually"
            echo "$reviewstr"
            ssh -p 29418 $GITUSER@$GERRITURLPATH gerrit review -m \'"$reviewstr"\' "$patchsetRevision"
            return 1
        else
            reviewstr="Environment files can not be commited together with other files"
            echo "$reviewstr"
            ssh -p 29418 $GITUSER@$GERRITURLPATH gerrit review -m \'"$reviewstr"\' "$patchsetRevision"
            ssh -p 29418 $GITUSER@$GERRITURLPATH gerrit review --verified -1 "$patchsetRevision"
            return 1
        fi
    fi

    # Clone files to run tests
    git config --global user.name "$GITUSER"
    git config --global user.email $GITUSEREMAIL

    # Clone the project in a temporary folder
    TESTROOT=testroot
    CHROOT_PATH="$workspacePath/$TESTROOT"
    nextitem=$(lookForArgument "-testroot" "$@")
    [ $? -eq 0 ] &&
        CHROOT_PATH=$nextitem

    CHROOT_WORKSPACE=$CHROOT_PATH$currentHome
    JOB_WORKSPACE=$currentHome
    PROJECT_WORKSPACE=$currentHome/$projectName
    PROJECT_PATH="$CHROOT_WORKSPACE/$projectName"
    isDirExist $PROJECT_PATH
    [ $? -eq 0 ] && rm -r $PROJECT_PATH

    verbosetracer $verbosemode "CHROOT_PATH $CHROOT_PATH"
    verbosetracer $verbosemode "CHROOT_WORKSPACE $CHROOT_WORKSPACE"
    verbosetracer $verbosemode "JOB_WORKSPACE $JOB_WORKSPACE"
    verbosetracer $verbosemode "PROJECT_WORKSPACE $PROJECT_WORKSPACE"
    verbosetracer $verbosemode "PROJECT_PATH $PROJECT_PATH"

    git clone "ssh://$GITUSER@$GERRITPATH/${projectName}" $PROJECT_PATH
    cd  $PROJECT_PATH

    # Cherry-pick patch-set
    git remote add gerrit ssh://$GITUSER@$GERRITPATH/$projectName
    git review -x $patchsetChangeNumber

    runshellcmd "[ -d \"$repoUtilssHome/repoutils\" ]"
    [ $? -ne 0 ] &&
        echo "'$repoUtilssHome/repoutils' was not found!" &&
        rm -r $PROJECT_PATH &&
        return 1
    sourceStatements="source $repoUtilssHome/repoutils/ccrun && source $repoUtilssHome/repoutils/trun && "

    export TRUNENVCHECK=0
    UNIT_TEST_CMD="${sourceStatements} trun -rawmode -u -utilspath $repoUtilssHome -projectroot $PROJECT_WORKSPACE"
    BLOCK_TEST_CMD="${sourceStatements} trun -rawmode -b -utilspath $repoUtilssHome -projectroot $PROJECT_WORKSPACE"

    # Create a temporary folder to store tests' results
    TEMPEXTRACTION_DIR=$(mktemp -u)
    runshellcmd "mkdir -p $TEMPEXTRACTION_DIR"
    TEMPEXTRACTION_FULLPATH=$TEMPEXTRACTION_DIR
    [ $jenkinsjobmode -eq 0 ]  &&
        TEMPEXTRACTION_FULLPATH=$CHROOT_PATH$TEMPEXTRACTION_DIR

    # Set default exitCode to '0' SUCCESS
    generalFailure=0
    CCRUNCMD_RUNTEST=runtest
    currentCommand=$CCRUNCMD_RUNTEST
    codeCheckerExitCode=0
    # Looking for .codechecker in the main project folder
    isFileExist "$PROJECT_PATH/.codechecker"
    if [ $? -eq 0 ]; then
        . ${PROJECT_PATH}/.codechecker
        codeCheckerExitCode=$?
    fi

    TOTALRANTESTUNITS=0
    TOTALRANTESTFAILED=0
    TOTALRANTESTPASSED=0
    isFileExist $TEMPEXTRACTION_FULLPATH/$TESTRESULTREPORT_FILE
    if [ $? -eq 0 ]; then
        TestSammaryReportStr="\nTests' results sammary:"
        TestSammaryReportStr="$TestSammaryReportStr\n$(column -tnex -s "|" $TEMPEXTRACTION_FULLPATH/$TESTRESULTREPORT_FILE | column_ansi)"
        echo -e "$TestSammaryReportStr"

        echo "--------------------"
        TOTALRANTESTPASSED=$(grep -oc 'PASSED' $TEMPEXTRACTION_FULLPATH/$TESTRESULTREPORT_FILE)
        TOTALRANTESTFAILED=$(grep -oc 'FAILED' $TEMPEXTRACTION_FULLPATH/$TESTRESULTREPORT_FILE)
        TOTALRANTESTUNITS=$(($TOTALRANTESTPASSED + $TOTALRANTESTFAILED))
        echo -e "Total: $TOTALRANTESTUNITS, Passed: $TOTALRANTESTPASSED, Failed: $TOTALRANTESTFAILED"
        if [ $TOTALRANTESTFAILED -ne 0 ]; then
            echo -e "${BGRED}${WHITE}FAILURE: SOME TESTS DID NOT PASSED.${NC}"
        else
            [ $TOTALRANTESTUNITS -ne 0 ] &&
                echo -e "${BGGREEN}${WHITE}PASS: ALL TESTS PASSED!${NC}"
        fi
    else
        echo -e "WARRNING: No report was created."
    fi

    # Remove the temporary folder created to store tests' results
    runshellcmd "[ -d $TEMPEXTRACTION_DIR ] && rm -r $TEMPEXTRACTION_DIR"

    # remove the temporary cloned folder
    cd $workspacePath
    rm -r $PROJECT_PATH

    [ $generalFailure -ne 0 ] &&
        echo -e "ERROR: Somthing went wrong, check the log to find more info!" &&
        return 1
    [ $TOTALRANTESTFAILED -ne 0 ] && 
        return 1
    return $codeCheckerExitCode
}

#---------------------------------------
# Main
nextitem=$(lookForArgument "--main" "$@")
[ $? -eq 0 ] &&
    checkRunner "$@" &&
    exit $?