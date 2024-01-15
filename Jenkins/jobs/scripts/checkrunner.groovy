// checkrunner groovy script to within Jenkins Pipline
//
// File : checkrunner.groovy
//
//
// Copyright (c) 2023 Nexttop (nexttop.se)
//---------------------------------------
node {
    sh  '<PATH/tomcat9/webapps/jenkins/jobs/checkrunner.sh --main -servermode -verbose -user codeman -utilspath <utilspath> -home <homepath> -testroot <PATH/tomcat9/webapps/jenkins/testroot>'
}
