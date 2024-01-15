# Jenkins jobs' scripts
-----------------------------------------------------
A set of scripts used by Jenkins jobs
- `checkrunner.sh` used by `CodeChecker`job to run tests
- `packagebuilder.sh` used by `PackageBuilder` job to run after merging commits
	* packages will be created in `PATH/tomcat9/webapps/jenkins/workspace/PackageBuilder/packages`
	* A link to the latest version is added to packages folder
	* For now older packages are not removed when a new one is created.

## Located in : `PATH/tomcat9/webapps/jenkins/jobs` :
- `checkrunners.sh`
- `packagebuilder.sh`

