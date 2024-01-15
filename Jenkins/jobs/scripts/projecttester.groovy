// projecttester groovy script to within Jenkins Pipline
//
// File : projecttester.groovy
//
//
// Copyright (c) 2023 Nexttop (nexttop.se)
//---------------------------------------
node {
    //def projectsList = [ 'project1','project2' ];
    def projectsList = [  ];
    def commitsListFile = 'commitslist';
    def pgtReportFile = 'pgtreport.formatted';
    def testsResultReportFile = 'testsresultreport.formatted';

    managerEmail = 'manager@your-email.yoursite';
    nextEnvAdminEmail = 'tsadmin@your-email.yoursite';

    for (projectName in projectsList){
        println("\n\nProject name : ${projectName}\n-----");

        mailSubject ="PGT report - ${projectName}";
        testsResultReportContent = "Tests result - No report has been created";
        def ret_status = sh( script: "<PATH/tomcat9/webapps/jenkins/jobs/projecttester.sh> --main -jenkinsjob -verbose -days 1 -user codeman -project ${projectName} -utilspath <utilspath> -home <homepath> -testroot <PATH/tomcat9/webapps/jenkins/testroot>", returnStatus: true );

        if (fileExists(testsResultReportFile)){
            testsResultReportContent = readFile(testsResultReportFile);
        }

        if (ret_status == 1 ){
            pgtReportContent = "PGT report - No report has been created";
            if ( fileExists(commitsListFile) ){
                try{
                    if (fileExists(pgtReportFile)){
                        pgtReportContent = readFile(pgtReportFile);
                    }

                    def comitlistfile = readFile(commitsListFile);
                    def lines = comitlistfile.readLines();
                    for (line in lines){
                        String[] commitElements;
                        commitElements = line.split("\\|");
                        commitTitle = commitElements[1];
                        commitOwner = commitElements[2];
                        commitOwnerEmail = commitElements[3];

                        mailBody = "Hi ${commitOwner}\n";
                        mailBody = "${mailBody}You have a commit merged after the last time that PGT was passed.\n";
                        mailBody = "${mailBody}There is a possibility that your commit(s) is a reason of issues.\n";
                        mailBody = "${mailBody}Please check your commit(s)\n";
                        mailBody = "${mailBody}Build url: ${BUILD_URL}\n\n"
                        mailBody = "${mailBody}${pgtReportContent}\n\n";
                        mailBody = "${mailBody}${testsResultReportContent}";

                        mail(bcc: '', body : mailBody, cc: '', from: managerEmail, replyTo: '', subject: mailSubject, to: commitOwnerEmail);
                    }
                    mailBody = "Hi\n";
                    mailBody = "${mailBody}Some PGT tests have been failed.\n";
                    mailBody = "${mailBody}Build url: ${BUILD_URL}\n\n";
                    mailBody = "${mailBody}${pgtReportContent}\n\n";
                    mailBody = "${mailBody}${testsResultReportContent}";
                    mail(bcc: '', body : mailBody, cc: '', from: managerEmail, replyTo: '', subject: mailSubject, to: nextEnvAdminEmail);
                } catch (Exception ex){
                    println(ex.message);
                }
            }
            else{
                    mailBody = "Hi\n";
                    mailBody = "${mailBody}Some PGT tests have been failed.\n";
                    mailBody = "${mailBody}Build url: ${BUILD_URL}\n\n";
                    mailBody = "${mailBody}${commitsListFile} has been not created!\n\n";
                    mailBody = "${mailBody}${pgtReportContent}";
                    mail(bcc: '', body : mailBody, cc: '', from: managerEmail, replyTo: '', subject: mailSubject, to: nextEnvAdminEmail);
            }
            currentBuild.result = 'FAILURE';
        }
        else{
            pgtReportContent = "PGT report - No report has been created";
            if (fileExists(pgtReportFile)){
                pgtReportContent = readFile(pgtReportFile);
            }
            mailBody = "Hi\n";
            mailBody = "${mailBody}PGT report\n";
            mailBody = "${mailBody}Build url: ${BUILD_URL}\n\n";
            mailBody = "${mailBody}${pgtReportContent}\n\n";
            mailBody = "${mailBody}${testsResultReportContent}";
            mail(bcc: '', body : mailBody, cc: '', from: managerEmail, replyTo: '', subject: mailSubject, to: nextEnvAdminEmail);

            currentBuild.result = 'SUCCESS';
        }

        try{
            sh( script: "[ -f ${commitsListFile} ] && rm ${commitsListFile}", returnStatus: true );
            sh( script: "[ -f ${pgtReportFile} ] && rm ${pgtReportFile}", returnStatus: true );
            sh( script: "[ -f ${testsResultReportFile} ] && rm ${testsResultReportFile}", returnStatus: true );
            } catch (Exception ex){
            println(ex.message);
        }
    }
}