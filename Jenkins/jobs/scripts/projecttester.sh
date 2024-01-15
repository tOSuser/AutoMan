#!/bin/bash
#: checkrunner to use within Jenkins Pipline
#:
#: File : projecttester.sh
#
#
# Copyright (c) 2022 Nexttop (nexttop.se)
#---------------------------------------
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

verboseRunStr="Run:"
TEMPEXTRACTION_DIR=''
TESTRESULTREPORT_FILE='testsresultreport'
PGTREPORT_FILE='pgtreport'
COMMITSLIST_FILE='commitslist'
FORMATTEDFILE_EXT='.formatted'
failstopmode=1
generalFailure=0

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
    verbosetracer $verbosemode "runtrun: $unitName, $unitPath"

    isFileExist $TEMPEXTRACTION_FULLPATH/$TESTRESULTREPORT_FILE
    [ $? -ne 0 ] &&
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
    return 0
}

function projectTester () #@ USAGE projectTester param1 param2 ...
{
    ## Initialize values
    nextitem=$(lookForArgument "-verbose" "$@")
    verbosemode=$?
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

    projectName='unknown'
    nextitem=$(lookForArgument "-project" "$@")
    [ $? -eq 0 ] &&
        projectName=$nextitem

    periodDays=1
    nextitem=$(lookForArgument "-days" "$@")
    [ $? -eq 0 ] &&
        periodDays=$nextitem

    verbosetracer $verbosemode "projectName -project $projectName"
    verbosetracer $verbosemode "WORKSPACE -workspace $workspacePath"

    periodStartDate=$(date -d "$periodDays day ago" '+%Y-%m-%d')
    mergedCommits=$(ssh -p 29418 $GITUSER@$GERRITURLPATH gerrit query --format=JSON \
        status:merged after:$periodStartDate project:$projectName)
    [ $? -ne 0 ] &&
        echo "ERROR: '${projectName}' commits can not be fetched." &&
        return 1
    numberOfJsonObjects=$(echo $mergedCommits | jq '. | objects | select(has("rowCount")) | .rowCount ')

    verbosetracer $verbosemode "mergedCommits $mergedCommits"
    verbosetracer $verbosemode "numberOfJsonObjects $numberOfJsonObjects"

    # if number of objects is less than 1 , it means somethings went wrong
    [ $numberOfJsonObjects -lt 1 ] &&
        return 0

    # There are some new commits, cloning the repo and running tests
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
    [ $? -ne 0 ] &&
        echo "ERROR: '${projectName}' can not be cloned." &&
        return 1
    cd  $PROJECT_PATH

    sourceStatements="source $repoUtilssHome/repoutils/ccrun && source $repoUtilssHome/repoutils/trun && "
    export TRUNENVCHECK=0
    UNIT_TEST_CMD="${sourceStatements} trun -rawmode -u -utilspath $repoUtilssHome -projectroot $PROJECT_WORKSPACE"
    BLOCK_TEST_CMD="${sourceStatements} trun -rawmode -b -utilspath $repoUtilssHome -projectroot $PROJECT_WORKSPACE"

    # Create a temporary folder to store tests results
    TEMPEXTRACTION_DIR=$(mktemp -d)
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
        TestSammaryReportStr="\nTests results sammary:"
        TestSammaryReportStr="$TestSammaryReportStr\n$(column -tnex -s "|" $TEMPEXTRACTION_FULLPATH/$TESTRESULTREPORT_FILE | column_ansi)"
        echo -e "$TestSammaryReportStr"

        echo "--------------------"
        TOTALRANTESTPASSED=$(grep -oc 'PASSED' $TEMPEXTRACTION_FULLPATH/$TESTRESULTREPORT_FILE)
        TOTALRANTESTFAILED=$(grep -oc 'FAILED' $TEMPEXTRACTION_FULLPATH/$TESTRESULTREPORT_FILE)
        TOTALRANTESTUNITS=$(($TOTALRANTESTPASSED + $TOTALRANTESTFAILED))
        echo -e "Total: $TOTALRANTESTUNITS, Passed: $TOTALRANTESTPASSED, Failed: $TOTALRANTESTFAILED"

        echo -e "$TestSammaryReportStr" | putToFile "$TEMPEXTRACTION_DIR/$TESTRESULTREPORT_FILE$FORMATTEDFILE_EXT"
        echo -e "Total: $TOTALRANTESTUNITS, Passed: $TOTALRANTESTPASSED, Failed: $TOTALRANTESTFAILED"  | putToFile "$TEMPEXTRACTION_DIR/$TESTRESULTREPORT_FILE$FORMATTEDFILE_EXT"
    else
        echo -e "WARRNING: No report was created."
    fi

    echo "|commitNumber|commitSubject|mergeDate|commitOwner|commitOwnerMail" | putToFile "$TEMPEXTRACTION_DIR/$PGTREPORT_FILE"
    echo "|-----|-----|-----|-----|-----" | putToFile "$TEMPEXTRACTION_DIR/$PGTREPORT_FILE"

    for (( iCommit=0; iCommit<$numberOfJsonObjects; iCommit++ ))
    do
        commitGerritInfo=$(echo $mergedCommits | jq -s ".[$iCommit]")
        commitMessage=$(echo $commitGerritInfo | jq -s '.[] | .commitMessage')
        commitId=$(echo $commitGerritInfo | jq -s '.[] | .id')
        commitNumber=$(echo $commitGerritInfo | jq -s '.[] | .number')
        commitSubject=$(echo $commitGerritInfo | jq -s '.[] | .subject')
        shortCommitSubject="$commitSubject"
        [ "${#shortCommitSubject}" -gt 25 ] &&
            shortCommitSubject="${shortCommitSubject:0:22}..."

        commitUrl=$(echo $commitGerritInfo | jq -s '.[] | .url')
        commitOwnerUserName=$(echo $commitGerritInfo | jq -s '.[] | .owner.username')
        commitOwnerMail=$(echo $commitGerritInfo | jq -s '.[] | .owner.email')
        commitMergedReversion=$(ssh -p 29418 $GITUSER@$GERRITURLPATH gerrit query --format=JSON --current-patch-set $commitId | \
            jq -s ".[0].currentPatchSet.revision" )

        mergedCommitComments=$(ssh -p 29418 $GITUSER@$GERRITURLPATH gerrit query --format=JSON \
            --comments --current-patch-set $commitId)
        jq_query=".[] | select(.message | contains(\"Change has been successfully merged\"))"
        verbosetracer $verbosemode "$jq_query"
        mergeTimeStamp=$(echo $mergedCommitComments | \
            jq -s ".[0].comments" | \
            jq -r  "$jq_query" | \
            jq -r ".timestamp")
        mergeDate=$(date -d @${mergeTimeStamp} "+%Y-%M-%d %H:%M")

        verbosetracer $verbosemode "iCommit $iCommit"
        verbosetracer $verbosemode "commitGerritInfo $commitGerritInfo"
        verbosetracer $verbosemode "commitMessage $commitMessage"
        verbosetracer $verbosemode "commitId $commitId"
        verbosetracer $verbosemode "commitNumber $commitNumber"
        verbosetracer $verbosemode "commitSubject $commitSubject"
        verbosetracer $verbosemode "commitUrl $commitUrl"
        verbosetracer $verbosemode "commitOwnerUserName $commitOwnerUserName"
        verbosetracer $verbosemode "commitOwnerMail $commitOwnerMail"
        verbosetracer $verbosemode "commitMergedReversion $commitMergedReversion"
        verbosetracer $verbosemode "mergeDate $mergeDate"

        if [ $TOTALRANTESTFAILED -eq 0 ]; then
            numberOfJsonCommentObjects=$(echo $mergedCommitComments | jq '. | objects | select(has("rowCount")) | .rowCount ')

            verbosetracer $verbosemode "mergedCommitComments $mergedCommitComments"
            verbosetracer $verbosemode "numberOfJsonCommentObjects $numberOfJsonCommentObjects"

            if [ $numberOfJsonCommentObjects -gt 0 ]; then
                # check any PGT(Project Group Test) comment added before
                jq_query=".[] | select((.reviewer.username == \"$GITUSER\") and (.message | contains(\"PGT\")))"
                verbosetracer $verbosemode "$jq_query"
                numberOfPGTComments=$(echo $mergedCommitComments | \
                    jq -s ".[0].comments" | \
                    jq -r  "$jq_query" | \
                    jq -s ".  | length")

                verbosetracer $verbosemode "numberOfPGTComments $numberOfPGTComments"

                if [ $numberOfPGTComments -eq 0 ] && [ $generalFailure -eq 0 ]; then
                    PGTReviewstr="PGT passed."
                    ssh -p 29418 $GITUSER@$GERRITURLPATH gerrit review -m \'"$PGTReviewstr"\' "$commitMergedReversion"
                fi
            fi
        else
            echo "$commitNumber|$shortCommitSubject|$mergeDate|$commitOwnerUserName|$commitOwnerMail" | putToFile "$TEMPEXTRACTION_DIR/$COMMITSLIST_FILE"
        fi
        echo "|$commitNumber|$shortCommitSubject|$mergeDate|$commitOwnerUserName|$commitOwnerMail" | putToFile "$TEMPEXTRACTION_DIR/$PGTREPORT_FILE"
    done

    # Create a list of commits
    if [ $TOTALRANTESTFAILED -ne 0 ]; then
        PGTReportStr="\nList of commits that can be a reason to issues:"
    else
        PGTReportStr="\nList of commits:"
    fi

    PGTReportStr="$PGTReportStr\n$(column -tnex -s "|" $TEMPEXTRACTION_DIR/$PGTREPORT_FILE | column_ansi)"
    echo -e "$PGTReportStr"
    echo -e "$PGTReportStr" | putToFile "$TEMPEXTRACTION_DIR/$PGTREPORT_FILE$FORMATTEDFILE_EXT"
    echo -e "Total: $numberOfJsonObjects" | putToFile "$TEMPEXTRACTION_DIR/$PGTREPORT_FILE$FORMATTEDFILE_EXT"

    isFileExist $workspacePath/$COMMITSLIST_FILE
    [ $? -eq 0 ] &&
        rm $workspacePath/$COMMITSLIST_FILE
    isFileExist $TEMPEXTRACTION_DIR/$COMMITSLIST_FILE
    [ $? -eq 0 ] &&
        cp $TEMPEXTRACTION_DIR/$COMMITSLIST_FILE $workspacePath/$COMMITSLIST_FILE

    isFileExist "$workspacePath/$TESTRESULTREPORT_FILE$FORMATTEDFILE_EXT"
    [ $? -eq 0 ] &&
        rm "$workspacePath/$TESTRESULTREPORT_FILE$FORMATTEDFILE_EXT"
    isFileExist "$TEMPEXTRACTION_DIR/$TESTRESULTREPORT_FILE$FORMATTEDFILE_EXT"
    [ $? -eq 0 ] &&
        cp "$TEMPEXTRACTION_DIR/$TESTRESULTREPORT_FILE$FORMATTEDFILE_EXT" "$workspacePath/$TESTRESULTREPORT_FILE$FORMATTEDFILE_EXT"

    isFileExist "$workspacePath/$PGTREPORT_FILE$FORMATTEDFILE_EXT"
    [ $? -eq 0 ] &&
        rm "$workspacePath/$PGTREPORT_FILE$FORMATTEDFILE_EXT"
    isFileExist "$TEMPEXTRACTION_DIR/$PGTREPORT_FILE$FORMATTEDFILE_EXT"
    [ $? -eq 0 ] &&
        cp "$TEMPEXTRACTION_DIR/$PGTREPORT_FILE$FORMATTEDFILE_EXT" "$workspacePath/$PGTREPORT_FILE$FORMATTEDFILE_EXT"

    # Remove the temporary folder created to store tests results
    isDirExist $TEMPEXTRACTION_DIR
    [ $? -eq 0 ] &&
        rm -r $TEMPEXTRACTION_DIR

    isDirExist $TEMPEXTRACTION_FULLPATH
    [ $? -eq 0 ] &&
        runshellcmd "rm -r $TEMPEXTRACTION_DIR"

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
    projectTester "$@" &&
    exit $?