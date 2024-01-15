#!/bin/bash
#: packagebuilder to use within Jenkins Pipline
#:
#: File : packagebuilder.sh
#
#
# Copyright (c) 2023 Nexttop (nexttop.se)
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

## Import libraries
[ -f $ORIGINALSCRIPT_PATH/jenkinsjobshelper.shinc ] &&
    . $ORIGINALSCRIPT_PATH/jenkinsjobshelper.shinc

function runshellcmd () {
    cmdstr="unshare -mr chroot $CHROOT_PATH bash -c \"$1\""
    echo "runshellcmd : \"$1\""
    eval $cmdstr
    return $?
}

function packageBuilder () #@ USAGE checkRunner param1 param2 ...
{
    ## Initialize values
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

    buildURL=$BUILD_URL
    nextitem=$(lookForArgument "-buildurl" "$@")
    manualBuildUrlMode=$?
    [ $manualBuildUrlMode -eq 0 ] &&
        buildURL=$nextitem

	verbosetracer $verbosemode "GERRIT_PATCHSET_NUMBER -patchnumber $patchsetNumber"
	verbosetracer $verbosemode "GERRIT_PATCHSET_REVISION -patchrevision $patchsetRevision"
	verbosetracer $verbosemode "GERRIT_CHANGE_NUMBER -changenumber $patchsetChangeNumber"
	verbosetracer $verbosemode "GERRIT_PROJECT -project $projectName"
	verbosetracer $verbosemode "WORKSPACE -workspace $workspacePath"

	# Clone files to run tests
	git config --global user.name "$GITUSER"
	git config --global user.email $GITUSEREMAIL

	reviewstr="Checking packages dependencies Started.\n\n$buildURL"
	reviewstr=$(echo -e "${reviewstr}")
	ssh -p 29418 $GITUSER@$GERRITURLPATH gerrit review -m \'"${reviewstr}"\' "$patchsetRevision"

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

	runshellcmd "[ -d \"$repoUtilssHome/repoutils\" ]"
	[ $? -ne 0 ] &&
	    echo "'$repoUtilssHome/repoutils' was not found!" &&
	    return 1
	sourceStatements="source $repoUtilssHome/repoutils/ccrun && source $repoUtilssHome/repoutils/trun && "

	PACKAGES_PATH=$workspacePath/packages
    nextitem=$(lookForArgument "-packfolder" "$@")
    [ $? -eq 0 ] &&
        PACKAGES_PATH=$nextitem
    verbosetracer $verbosemode "PACKAGES_PATH $PACKAGES_PATH"
	isDirExist $PACKAGES_PATH
	[ $? -ne 0 ] &&
		mkdir "$PACKAGES_PATH"

	git clone "ssh://$GITUSER@$GERRITPATH/${projectName}" $PROJECT_PATH
	cd $PROJECT_PATH

	export TRUNENVCHECK=0
	# Set default exitCode to '0' SUCCESS
	CCRUNCMD_RUNTEST=runtest
	CCRUNCMD_PACK=pack
	currentCommand=$CCRUNCMD_PACK
	exitCode=0

	currentpatchnumber=$(($patchsetNumber-1))
	UPDATEDFILES_ARR=( $(ssh -p 29418 $GITUSER@$GERRITURLPATH gerrit query --format=JSON --files --patch-sets $patchsetRevision | \
		jq -r ".patchSets[$currentpatchnumber].files[]? | .file") )

	PATCHSET_TOTALFILES=0
	PATCHSET_TOTALENVFILES=0
	for fname in "${UPDATEDFILES_ARR[@]}"
	do
	    PATCHSET_TOTALFILES=$(($PATCHSET_TOTALFILES+1))
	    [[ "$fname" == "."* ]] &&
	    	PATCHSET_TOTALENVFILES=$(($PATCHSET_TOTALENVFILES+1))
	    echo "$fname"
	done
	echo "Total files : $PATCHSET_TOTALFILES"
	echo "Total envionment files : $PATCHSET_TOTALENVFILES"

	# Looking for .packagelist in the main project folder
	arrSubProjects=(  )
	isFileExist "$PROJECT_PATH/.packagelist"
	[ $? -eq 0 ] &&
	    . ${PROJECT_PATH}/.packagelist

	reviewstr=''
	affectedPakagesArr=(  )
	for subProject in ${arrSubProjects[@]}
	do
		eval subProjectName='"${'$subProject'[0]}"'
		eval subProjectPath='"${'$subProject'[1]}"'
		verbosetracer $verbosemode "subProjectName $subProjectName"
		verbosetracer $verbosemode "subProjectPath $subProjectPath"
		projectNeedToBuild=0
		sourceArr=($(echo "$( < ${PROJECT_PATH}/$subProjectPath/.sourcepaths)" | \
			jq -r '.[] | if type=="array" then .[0] else . end'))

		echo -e "\nLooking for changes on the sources used by $subProjectName"
		for sourceitem in ${sourceArr[@]}
		do
			# chroot(testroot) has been installed on codechecker, to avoid duplications
			# packagebuilder uses chroot via a link to the chroot (testroot) on codechecker
			# in case that it needs to find full path by using readlink or realpath
			# it reaturns addresses based on chroot(testroot) installen on codechecker, not packagebuilder
			# replace 'PackageBuilder' with 'CodeChecker'
			#fullpath=$(realpath ${PROJECT_PATH}/$subProjectPath/$sourceitem)
			#fullpath="${fullpath//CodeChecker/PackageBuilder}"
			fullpath=$(realpath ${PROJECT_PATH}/$subProjectPath/$sourceitem)
			dependencypath=${fullpath#$PROJECT_PATH/}
			verbosetracer $verbosemode "${PROJECT_PATH}/$subProjectPath/$sourceitem"
			verbosetracer $verbosemode "fullpath $fullpath"
			verbosetracer $verbosemode "PROJECT_PATH $PROJECT_PATH"
			verbosetracer $verbosemode "dependencypath $dependencypath"

			for updateditem in ${UPDATEDFILES_ARR[@]}
			do
				updateditempath=$(dirname $updateditem)
				verbosetracer $verbosemode "Looing for $updateditempath in $dependencypath"
				[[ "${updateditempath}" == "$dependencypath"* ]] &&
					echo "Some files in $dependencypath have been changed (${updateditem##*/})" &&
					projectNeedToBuild=1 &&
					break
			done

			if [ $projectNeedToBuild -eq 1 ]; then
				affectedPakagesArr=( "${affectedPakagesArr[@]}" $subProjectName )
			    runshellcmd "$sourceStatements ccrun pack -product -rawmode -verbose -utilspath $repoUtilssHome -projectroot $PROJECT_WORKSPACE -path $PROJECT_WORKSPACE/$subProjectPath"
			    exitCode=$?

			    # set default message
			    reviewstr="A package for $subProjectName was built."
			    isDirExist "$PROJECT_PATH/$subProjectPath/pack"
			    if [ $? -eq 0 ] && [ $exitCode -eq 0 ]; then
			    	# Adding a pack id to the package
			    	PackageVersionId=$(date +%y%m%d-%H%I-%s)
			    	echo "$PackageVersionId" > "$PROJECT_PATH/$subProjectPath/pack/.version"

			    	tar -czvf $PACKAGES_PATH/$subProjectName-$PackageVersionId.tar.gz -C $PROJECT_PATH/$subProjectPath/ pack
			    	exitCode=$?

			    	# Create a link to the latest version
			    	if [ $exitCode -eq 0 ]; then
				    	isFileExist "$PACKAGES_PATH/$subProjectName.version"
				    	[ $? -eq 0 ] &&
				    		rm "$PACKAGES_PATH/$subProjectName.version"
				    	echo "$PackageVersionId" > "$PACKAGES_PATH/$subProjectName.version"

			    		isFileExist $PACKAGES_PATH/${subProjectName}.tar.gz
			    		[ $? -eq 0 ] &&
			    			rm $PACKAGES_PATH/${subProjectName}.tar.gz
			    		ln -s $subProjectName-$PackageVersionId.tar.gz $PACKAGES_PATH/${subProjectName}.tar.gz
			    	fi
			    else
			    	exitCode=1
			    	echo "The built package was not found ($PROJECT_PATH/$subProjectPath/pack)"
			    fi
		    	[ $exitCode -ne 0 ] &&
			    	reviewstr="FAILURE : Something went wrong, no package was built for $subProjectName." &&
			    	ssh -p 29418 $GITUSER@$GERRITURLPATH gerrit review -m \'"${reviewstr}"\' "$patchsetRevision"
		    	echo -e "$reviewstr"
				break
			fi
		done
	done

	reviewstr=''
	if [ ${#affectedPakagesArr[@]} -eq 0 ]; then
		reviewstr="No package was affected by this commit."
	else
		reviewstr="The pakages below were affected by this commit:"
		for affectedpackage in ${affectedPakagesArr[@]}
		do
			reviewstr="$reviewstr\n $affectedpackage"
		done

		if [ $exitCode -ne 0 ]; then
			reviewstr="$reviewstr\nFAILURE : Something went wrong, pakages were not built correctly."
		else
			reviewstr="$reviewstr\nSUCCESS : pakages were built successfully."
		fi
	fi
	echo -e "\n---\n${reviewstr}"
	reviewstr="$reviewstr\n\n$buildURL"
	reviewstr=$(echo -e "${reviewstr}")
	ssh -p 29418 $GITUSER@$GERRITURLPATH gerrit review -m \'"${reviewstr}"\' "$patchsetRevision"

	# remove the temporary cloned folder
	cd $workspacePath
	rm -r $PROJECT_PATH
	return $exitCode
}

#---------------------------------------
# Main
nextitem=$(lookForArgument "--main" "$@")
[ $? -eq 0 ] &&
    packageBuilder "$@" &&
    exit $?