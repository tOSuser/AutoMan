# AutoMan - A CI-CD/CT automation manager
AutoMan is a complete solution for CI-CD/CT flow. It manages all tasks from coding to packaging and implementing
in a continues development environment.
In fact AutoMan is an automation manager that connects timeplaning tools, kanban/scrum boards (such as Deck and Jira),
version tracker and review tools (such as git and  gerrit) and other tools such as Jenkins.

## License
license AGPL-3.0 This code and the package of Shtest are free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License, version 3, as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License, version 3, along with this program. If not, see http://www.gnu.org/licenses/

## A short background
need-to-be-completed

## What AutoMan is
need-to-be-completed

# An overview of AutoMan
need-to-be-completed

# AutoMan features
* need-to-be-completed


# Tests

A project can contain several sub-projects. Each sub-project has its own unittests and block tests. All tests files store in the test folder (`<sub-project name>/tests`). Usally a unit test file bane start with `Test` and a block test file name with `BlockTest`.

## Environment prerequisites

```bash
# Python 2.7
sudo apt install python

# setup pip for python version 2.7
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py
python get-pip.py

# For test enviroment which run unittest and block tests
python -m pip install mock

python -m pip install mysql.connector
python -m pip install requests
python -m pip install configparser

# setup pip for python version 3
# If modules below couldn't be found, it needs to add the universe repository
#apt install software-properties-common
#add-apt-repository universe

sudo apt install python3
sudo apt install python3-pip
pip3 install pymysql
pip3 install requests
pip3 install configparser

# Php
sudo apt install php-cli
sudo apt install phpunit
sudo apt-get install php-curl

# Java 
sudo apt-get install openjdk-8-jdk-headless
sudo apt-get install junit4

#Android
sudo apt install aapt
sudo apt install sdkmanager
sudo /usr/bin/sdkmanager --install "platforms;android-29"
sudo ln -s /opt/android-sdk/platforms/android-29/android.jar /usr/share/java/android.jar
# in the case that sdkmanager was not found (android sdk is installed in /usr/lib/android-sdk)
# sudo apt-get install android-sdk
# sudo ln -s /usr/lib/android-sdk/platforms/android-<xx>/android.jar /usr/share/java/android.jar

# Json
sudo apt install python3-demjson
# In the case that demjson installed by apt was less than 3
#  newr version can be installed by the command below
# pip3 install demjson3

#HTML
sudo apt-get install tidy
# In the case that tidy installed by apt was less than 4
#  newr version can be installed by the command below
# wget https://github.com/htacg/tidy-html5/releases/download/5.8.0/tidy-5.8.0-Linux-64bit.deb
# dpkg -i tidy-5.8.0-Linux-64bit.deb
# rm tidy-5.8.0-Linux-64bit.deb

#XML
sudo apt-get install libxml2-utils

#NodeJS v15 or newer
sudo apt install nodejs
sudo apt install npm

# if it needs the lastest version of Node can be installed by commands below
#cd ~
#curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh
#bash /tmp/nodesource_setup.sh
#sudo apt update
#sudo apt install nodejs

#Angular
sudo npm install -g @angular/cli

# There is no need to install node_modules, it will be downloaded automatically
#  from http://yoursite/reporosity/ by AutoMan if it's need
#  but if it needs, can be downloaded by the commands belows
# sudo apt install wget
# cd ~
# wget http://yoursite/nextreporosity/node_modules.tar.gz
# tar -xf node_modules.tar.gz -C $HOME
# rm /home/<youruser>/node_modules.tar.gz

# 'node_modules' downloaded from http://yoursite/reporosity/
#  has already contained all needed modules
# In the case to re-build the node_modules.tar.gz, 'node_modules' contains
#  all modules installed by 'ng new my-workspace' plus
#
# npm install --save @angular/material --prefix $HOME
# npm install --save-dev @types/jasmine --prefix $HOME
# npm install --save karma-firefox-launcher --prefix $HOME
# npm install --save jest ts-jest babel-jest @babel/preset-env @babel/core --prefix $HOME
# npm install --save-dev jest-preset-angular @types/jest --prefix $HOME
#
# To add React modules to node_modules
# it needs first to fix current dependencies conflicts on node_modules
# npm audit fix --force --prefix $HOME
#
# remove corrent typescript installed by Angular, React installs a newer version throgh react-scripts 
# npm remove typescript --prefix $HOME
#
# Adding modules required for React projects
# npm install --save react-scripts --prefix $HOME
# npm install --save react-dom --prefix $HOME
# npm install --save web-vitals --prefix $HOME
#
# npm install --save @testing-library/react --prefix $HOME
# npm install --save @testing-library/jest-dom --prefix $HOME

# Angular tests needs firfox headlees version
sudo apt-get install xvfb
```

* `trun` that is used to run test check environment requirements for Python at the start.
* To add new requirement checks (for example for other languages), it needs to a new `setupenv` to `utils/` alongside to
`trun` ( to see an example check `utils/setupenv.shinc`)

## Setup test files

To setup unit tests and block tests for a sub-project, it needs to configure 3 files in the root of the sub-project, `.codechecker`, `.sourcepaths` and `.testfiles`. It also needs to create to links to the main tests files stored in the a folder named `utiles` stored in the root of the project.

### Create links to test runner files

In the root of projecrt :

>```bash
>cd <sub-project>
>ln -s utils/runc.py runc.py
>ln -s utils/trun trun
>ln -s utils/ccrun ccrun
>```

### `trun` plugins

`trun` uses plugins to support languages. All plugins are placed in `utils/testrunners`. Each language has two plugin, one to setup environment befor running tests, and an other to run tests if `.testfilles` tagged to use a language for the current project
* `template.env`

>```bash
>#*
>#*  @description    Check xxx
>#*
>#*  @param			none
>#*
>#*  @return			0 if xxx is available, > 0 if atleast one is not available
>#*
>vchecktemplate() #@ USAGE checktemplate
>{
>	templateCheckResult=0
>	return $templateCheckResult
>}
>
>## The main
>## --------------------------------------
>checktemplate
>[[ $? -ne 0 ]] &&
>	exit 1
>```

* `template.runner`

>```bash
>#: Template test runner
>#:
>#: File : template.runner
>#
>#
># Copyright (c) 2023 Nexttop (nexttop.se)
>#---------------------------------------
># check template environment requirements
>if [[ ${TRUNENVCHECK:-1} -eq 1 ]]; then
>	arrSetupTemplateEnvList=(  )
>	for iSetupEnv in "${arrSetupTemplateEnvList[@]}"
>	do
>		. ${ORIGINALSCRIPT_PATH}/testrunners/$iSetupEnv.env
>	done
>fi
>```

### Create configuration files

* `.codechecker` : This file is used by the server side to run Jenkins jobs for the < sub-project>. The file should be like below. The only part that needs to be updated is `subProjectName` which Jenkins job manager used to run code in the server side.[See Jenkins test job to verify commits](/#Jenkins_test_job_to_verify_commits)

* `.sourcepaths` : This file list source folders that needs to be copied the test folder to get unit tests and block tests running. Addresses to the list are relative addresses based on the root of sub-project.
> `.sourcepaths`
>
>>```json
>>["../lib/","../common/src/","src/","../testhelper/","tests/"]
>>```

* **OBS!** Contents of all paths listed in `.sourcepaths` are copied to a temporary folder with same names and paths during running tests. If there is a need to copy content of a source path to a specific path, a source element can be a list which contains two paths, the first one specifies source path and the second points to target path
> `.sourcepaths`
>
>>```json
>>["pconf/",["src/","src"],["../common/angular/","src/libs"],["tests/","tests"]]
>>```

* **OBS!** sourcepaths for java and android projects are the main folder of the project
> `.sourcepaths`
>
>>```json
>>["../YourApp/"]
>>```

* `.testfiles` : This file is used to list test files which will be used by `runc.py`and `trun.sh`to run tests.
>`.testfiles`
>
>>```bash
>>arrTestList=( 'xml'  'html' 'json' 'python' 'php' 'nodejs' 'android' 'angular' )
>>
>>PYTHON_BLOCK_TEST_FILES=(  )
>>PYTHON_UNIT_TEST_FILES=(  )
>>
>>PHP_BLOCK_TEST_FILES=(  )
>>PHP_UNIT_TEST_FILES=(  )
>>
>>arrAndroidProjectList=(  )
>>ANDROID_BLOCK_TEST_FILES_TemplateApp=(  )
>>ANDROID_BLOCK_TEST_FILES_YourApp=(  )
>>ANDROID_UNIT_TEST_FILES_TemplateApp=(  )
>>ANDROID_UNIT_TEST_FILES_YourApp=(  )
>>
>>XML_FILES=(  )
>>XML_STRICT_FILES=( )
>>
>>JSON_STRICT_FILES=(  )
>>JSON_FILES=(  )
>>
>>HTML_FILES=(  )
>>HTML_STRICT_FILES=(  )
>>
>>arrJavaProjectList=( '' )
>>JAVA_BLOCK_TEST_FILES_=(  )
>>JAVA_UNIT_TEST_FILES_=(  )
>>
>>ANGULAR_BLOCK_TEST_FILES=(  )
>>ANGULAR_UNIT_TEST_FILES=(  )
>>
>>NODE_BLOCK_TEST_FILES=(  )
>>NODE_UNIT_TEST_FILES=(  )
>>```

* **OBS!** Definitions for android and java projects are little bit different:
>`.testfiles`
>
>>```bash
>>arrTestList=( 'java' 'android' 'xml' )
>>
>>arrAndroidProjectList=( 'TemplateApp' 'YourApp' )
>>ANDROID_BLOCK_TEST_FILES_TemplateApp=(  )
>>ANDROID_BLOCK_TEST_FILES_YourApp=(  )
>>ANDROID_UNIT_TEST_FILES_TemplateApp=( 'com.yourcom.TemplateApp.TestTemplateApp' )
>>ANDROID_UNIT_TEST_FILES_YourApp=( 'com.yourcom.YourApp.TestAppClient' )
>>
>>XML_FILES=( 'TemplateApp/AndroidManifest.xml' 'TemplateApp/res/layout/activity_main.xml' 'TemplateApp/res/values/strings.xml' 'YourApp/AndroidManifest.xml' 'YourApp/res/layout/activity_main.xml' 'YourApp/res/values/strings.xml')
>>
>>arrJavaProjectList=( '' )
>>JAVA_BLOCK_TEST_FILES_=(  )
>>JAVA_UNIT_TEST_FILES_=(  )
>>```

* **OBS!** Supported languages/files to add to `.testfiles` are : 'python', 'php', 'java', 'android', 'nodjs', 'angular', 'xml', 'html' and 'json'.

## Tests Python

### Python - Test Files

Each test file can contain one or several test classes. A test file with a test class is look like below. imported modules can be vary from a text file to another one.

```python
import sys
import os
from unittest import main, TestCase,runner

patchstr_builtins = '__builtin__.open'
if sys.version_info[0] < 3:
	# 2.7
	from mock import patch, MagicMock, mock_open
	from BaseHTTPServer import HTTPServer,BaseHTTPRequestHandler
	import urllib2 as urllib
	import mysql.connector as unimysql
	patchstr_builtins = '__builtin__.open'
else:
	# > 3
	from unittest.mock import patch, MagicMock, mock_open
	from http.server import HTTPServer,BaseHTTPRequestHandler
	import urllib.request as urllib
	import pymysql as unimysql
	import builtins
	patchstr_builtins = 'builtins.open'

import logging

from nxLogger.nxLogger import nxLogger
from nxEncoder.nxEncoder import nxEncoder
from nxTracer.nxTracer import nxTracer
from nxTracer.nxTracer import colors

from TestHelper import TestHelper
from TestHelper import FakePrint
from TestHelper import FakeURL
from TestHelper import FakeFile
from TestHelper import FakeError
from TestHelper import Fakesqlite3
from TestHelper import DatabaseManagerIfStub

class TestClassName(TestCase,TestHelper):
    """
    ClassName unittest.
        -
        -
    """

    def setUp(self):
        self.INFO("\n[RUN TEST]",False)
        """
        he code to prepare an environment to run test is added here on setUp
        """

    def tearDown(self):
        self.INFO("\n[END TEST]",False)

    def test_classname_funcname(self):
        """
        Test code for the mentioned function is added here
        """
# Main
#---------------------------------------
if __name__ == '__main__':
	if len(sys.argv) > 1:
		if sys.argv[1].lower() == '-info':
			logging.basicConfig(stream=sys.stdout, level=logging.INFO)
		elif sys.argv[1].lower() == '-debug':
			logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
		else:
			logging.basicConfig(stream=sys.stdout, level=logging.CRITICAL)

	test_result = main(argv=[''],verbosity=2, exit=False).result
	#<unittest.runner.TextTestResult run= errors= failures=>
	#test_result.errors
	#test_result.failures
	if len(test_result.errors) > 0 or len(test_result.failures) > 0:
		exit(1)
else:
	logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
```

### Python - Mock and helper functions

* Stubs : All stubs are placed in a file named `TestHelper.py`. To import stubs

```python
from TestHelper import TestHelper
from TestHelper import FakePrint
from TestHelper import FakeURL
from TestHelper import FakeFile
from TestHelper import FakeError
from TestHelper import Fakesqlite3
from TestHelper import Fakemysql
from TestHelper import Fakesoket
from TestHelper import Fakefcntl
from TestHelper import Fakeconfigparser
from TestHelper import DatabaseManagerIfStub
from TestHelper import FakeHTTPRequester
from TestHelper import FakeHTTPServer
```

* FakePrint
> This stub mocks outputs of `print` or similar functions that send its output to stdout.
> The contentes of outputs after runing a test mocked by `FakePrint` can be retrieved from `FakePrint.myvalue`.
> `FakePrint.ncalls` is an array that can be used to see number of calls of functions in the stub for example `FakePrint.ncalls[''write']`.
>
>```python
>.
>myfakeprint = FakePrint()
>sys.stdout = myfakeprint
>.
># myfakeprint.myvalue
># myfakeprint.ncalls[''write']
>.
>```

* FakeFile
> This stub mocks file oprations. To use this stub in a test, `__builtin__.open` should be patched for the test.
> * `FakeFile.fakedata` : data to return when `readlines` is called
> * `FakeFile.fakeoutput` : file writes can be retrieved from this member value
> * `FakeFile.fakeid` : an id to identify FakeFile when more that file needs
> * `FakeFile.ncalls` : an array of number of function calls
>> * `FakeFile.ncalls['write']`
>> * `FakeFile.ncalls['readlines']`
>> * `FakeFile.ncalls['read']`
>> * `FakeFile.ncalls['close']`
>> * `FakeFile.ncalls['__exit__']`
>> * `FakeFile.ncalls['__enter__']`
>
>```python
>@patch('__builtin__.open')
>def test_myfunctotest(self,mock_open):
>    myfakefile = FakeFile('stub_id',data_to_return_when_the_file_is_read)
>
>    def open_side_effect(filepath,mode):
>        self.INFO()
>        return myfakefile
>    mock_open.side_effect = open_side_effect
>.
>.
>```

* FakeError
> This stub is used to generate failure when a function is called
>
>```python
>@patch('__builtin__.open')
>def test_myfunctotest(self,mock_open):
>    myfakefile = FakeFile('stub_id',data_to_return_when_the_file_is_read)
>
>    def open_side_effect(filepath,mode):
>        self.INFO()
>        return myfakefile
>    mock_open.side_effect = open_side_effect
>.
>    myfakeerror= FakeError("File read error")
>    backup_read = myfakefile.readlines
>    myfakefile.readlines = myfakeerror.genrateError
>.
>.
>```

* FakeURL
> This stub mocks `urlopen`, the code below needs to add to the test class that needs to mocks `openurl`
> * `FakeURL.ncalls` : an array of number of function calls
>> * `FakeURL.ncalls['Request']`
>> * `FakeURL.ncalls['urlopen']`
>> * `FakeURL.ncalls['read']`
>> * `FakeURL.ncalls['close']`
>
>```pyhton
>if sys.version_info[0] < 3:
>	# 2.7
>	import urllib2 as urllib
>else:
>	# > 3
>	import urllib.request as urllib
>
> myfakeurl = FakeURL(mysourceurl,self.mydata)
> urllib.urlopen = myfakeurl.urlopen
>```

* Fakemysql
> This stub mocks mysql calls. To mock mysql calls the code below should be added to test `setUp`
> * `Fakemysql.ncalls` : an array of number of function calls
>> * `Fakemysql.ncalls['connect']`
>> * `Fakemysql.ncalls['cursor']`
>> * `Fakemysql.ncalls['execute']`
>> * `Fakemysql.ncalls['close']`
>> * `Fakemysql.ncalls['fetchall']`
>
>```python
>.
>if sys.version_info[0] < 3:
>	# 2.7
>	import mysql.connector as unimysql
>else:
>	# > 3
>	import pymysql as unimysql
>.
>self.myfakemysql = Fakemysql()
>unimysql.connect = self.myfakemysql.connect
>.
>```

* Fakesqlite3
> This stub mocks mysql calls. To mock mysql calls the code below should be added to test `setUp`
> * `Fakesqlite3.ncalls` : an array of number of function calls
>> * `Fakesqlite3.ncalls['connect']`
>> * `Fakesqlite3.ncalls['commit']`
>> * `Fakesqlite3.ncalls['rollback']`
>> * `Fakesqlite3.ncalls['execute']`
>> * `Fakesqlite3.ncalls['close']`
>> * `Fakesqlite3.ncalls['fetchall']`
>
>```python
>.
>self.myfakesqlite3 = Fakesqlite3()
>sqlite3.connect = self.myfakesqlite3.connect
>.
>```

* Fakeconfigparser
> This stub mocks configparser calls. To mock configparser calls the code below should be added to test `setUp` or test bodies. It also needs to mock file oprations by using Fakefile.
> * `Fakeconfigparser.ncalls` : an array of number of function calls
>> * `Fakeconfigparser.ncalls['ConfigParser']`
>> * `Fakeconfigparser.ncalls['write']`
>> * `Fakeconfigparser.ncalls['read']`
>> * `Fakeconfigparser.ncalls['sections']`
>> * `Fakeconfigparser.ncalls['add_section']`
>> * `Fakeconfigparser.ncalls['set']`
>> * `Fakeconfigparser.ncalls['has_option']`
>> * `Fakeconfigparser.ncalls['get']`
>
>```python
>.
>self.wpsitetypecfg = {'DEFAULT' : {'dbuser' : 'wpadmin','dbpass': 'wpdbpass',}}
>
>self.myfakecfg = FakeFile()
>
>def open_side_effect(filepath,mode):
>	if 'wpsitetype.cfg' in filepath:
>		return self.myfakecfg
>
>	mock_open.side_effect = open_side_effect
>	self.myfakesconfigparser = Fakeconfigparser('configparser',self.wpsitetypecfg)
>	configparser.ConfigParser = self.myfakesconfigparser.ConfigParser
>.
>```

* Fakesoket*
> This stub mocks soket calls.
> * `Fakesoket.ncalls` : an array of number of function calls
>> * `Fakesoket.ncalls['soket']`
>> * `Fakesoket.ncalls['fileno']`
>
> **OBS!** This stub is not used for now

* FakeHTTPRequester
> This stub mocks HTTPRequester calls. To mock HTTPRequester calls the code below should be added to test `setUp` or test bodies
> * `FakeHTTPRequester.ncalls` : an array of number of function calls
>> * `FakeHTTPRequester.ncalls['HTTPGet']`
>> * `FakeHTTPRequester.ncalls['HTTPPost']`
>
>```python
>.
>myfakehttprequster = FakeHTTPRequester(self.myresthandler)
>.
>```

* Fakefcntl*
> This stub mocks fcntl calls.
> * `Fakefcntl.ncalls` : an array of number of function calls
>> * `Fakefcntl.ncalls['ioctl']`
>
> **OBS!** This stub is not used for now


* Helper
> * TestHelper - A set of helper functions
>> * `isIpAddress`
>> * `strStr`

## Tests - php

### Php - Test Files

* Each test file can contain one or several test classes. A test file with a test class as general is look like below. imported/included modules can be vary from a test file to another one.

```php
<?php
require "AppClient.php";

use PHPUnit\Framework\TestCase;

class TestAppClient extends TestCase {
    private $myappclient;

    protected function setUp():void {
        $this->myappclient = new AppClient('test');
    }

    protected function tearDown():void {
        $this->myappclient = NULL;
    }

    public function test_AppClient_getName(){
        $this->assertEquals($this->myappclient->getName(), 'test');
    }
}
?>
```

* A test class adapted to the environment is look below:

```php
<?php
include "TestHelper.php";

use PHPUnit\Framework\TestCase;

class TestAppClient extends TestHelper {
    private $mymockedclass;
    private $myclasstotest;

    protected function setUp():void {
        $this->mymockedclass = $this->createMock(MyClass::class);
        $this->myclasstotest = new MyClassToTest($this->mymockedclass);
    }

    protected function tearDown():void {
        $this->myclasstotest = NULL;
    }

    public function test_AppClient_getName(){
        $this->mymockedclass->expects($this->exactly(1))->method('myfunc')
            ->with($this->anything())
                ->willReturn($myreturnvalue));

        // in this case mainfunc() will call myfunc() and return $myreturnvalue
        $this->assertEquals($this->mymockedclass->myfunc(), $myreturnvalue);
        $this->assertEquals($this->myclasstotest->mainfunc(), $myreturnvalue);
    }
}
?>
```

* `phpunit` used by the Jenkins job is version 6, and supports only a few functionalities (the current phpunit version is 10). It does not support stub and advanced functionalities.
* `phpunit` does not support multi expecs, all expects for a method should be added by one statement.

```php
<?php
.
.
.
        // not work if it needs to be expected 2 times
        $this->mymockedclass->expects($this->once())->method('myfunc')
            ->with($this->anything())
                ->willReturn($myreturnvalue1));
        $this->mymockedclass->expects($this->once())->method('myfunc')
            ->with($this->anything())
                ->willReturn($myreturnvalue2));

        // Change it to
        $this->myrestfulermock->expects($this->exactly(2))->method('myfunc')
            ->with($this->anything())
                ->willReturn($myreturnvalue1,$myreturnvalue2);

        // if the parameters sent to the method vary between 2 calls
        $this->myrestfulermock->expects($this->exactly(2))->method('myfunc')
            ->withConsecutive([$param_firstcall],[$param_secondcall])
                ->willReturn($myreturnvalue1,$myreturnvalue2);
?>
```

* `phpunit` can not mock classes that are instanced within the class that will be tested automatically. There are 2 solutions to fix that issue :
> * 1. Develop classes in a way that get the used classes as a parameter in the instancing time, for example instead of the code below
>
>>```php
>>class MyClass{
>>  private inclass;
>>  funnction __construct(){
>>      $this->inclass = new InClass();
>>  }
>>  .
>>  .
>>```
>>
> Use this code :
>
>>```php
>>class MyClass{
>>  private inclass;
>>  funnction __construct($inclass = NULL){
>>    if  ($inclass == NULL){
>>          $this->inclass = new InClass();
>>    }
>>    else{
>>          $this->inclass = $inclass;
>>    }
>>  }
>>  .
>>  .
>>```
>>
> Test :
>
>>```php
>>include "TestHelper.php";
>>
>>use PHPUnit\Framework\TestCase;
>>
>>class TestMyClass extends TestHelper {
>>    private $myinclassmock;
>>    private $myclass;
>>
>>    protected function setUp():void {
>>        $this->$myinclassmock = $this->createMock(InClass::class);
>>        $this->$myclass = new MyClass($this->$myinclassmock);
>>    }
>>
>>    protected function tearDown():void {
>>        $this->$myclass = NULL;
>>    }
>>.
>>.
>>```
>>
> * 2. Create an interface of the class that will be tested and use the interface to test
>
>>```php
>>class MyClass{
>>  private inclass;
>>  funnction __construct(){
>>    $this->inclass = new InClass();
>>  }
>>.
>>.
>>.
>>}
>>
>>class MyClassInterface extends MyClass{
>>  funnction __construct($inclass = NULL){
>>      // overridung the instance
>>      $this->inclass = $this->createMock(InClass::class);
>>  }
>>  .
>>  .
>>}
>>```

* **OBS!** `phpunit` does not support methods that added to the classe that is mocked by extending.

## Tests - java/android

### java/android - Test Files

Each test file can contain one test class only. A test file with a test class is look like below. The package for tests classes should be trhe same as the main file `package com.yourcom.TemplateApp;`.

```java
/*
#
# TestTemplateApp.java
#
# Description :
# --------------------------------------
# TemplateApp unittests
#
# Copyright (c) 2023 Nexttop (nexttop.se)
#---------------------------------------
*/
package com.yourcom.TemplateApp;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotSame;
import org.junit.Test;

public class TestTemplateApp{
	/***
	* @description		test_templateapp_tempfunc
	*
	***/
	@Test
	public void test_templateapp_tempfunc(){
		TemplateApp mytemplateapp = new TemplateApp();
		String message ="hello world";
		assertEquals(message, mytemplateapp.tempfunc(message));
	}
}
```

## Tests - TypeScript/Angular

### TypeScript/Angular - test files

Angular test files have the same name as the main component and ended with `.spec.ts` for example for a component named `apptemplate.component.ts`, thest file name is  `apptemplate.component.spec.ts` and is stored alongside the source file. Angular tests use jasmine as test framework. They will be run by `ng test` and useful to test the final product. In fact by running `ng test` a server will be loaded and then by running a browser and visiting the loaded server angular components are tested.

```javascript
import { TestBed } from '@angular/core/testing';
import { AppTemplateComponent } from './apptemplate.component';

describe('AppTemplateComponent', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [
        AppTemplateComponent
      ],
    }).compileComponents();
  });

  it(`should have as title 'AngularAppTemplate'`, () => {
    const fixture = TestBed.createComponent(AppTemplateComponent);
    const app = fixture.componentInstance;
    expect(app.title).toEqual('AngularAppTemplate');
  });

});
```

### TypeScriptr test files

TypeScript test files are stored in a folder named `tests`in the root of an angular project. Each test file contains only tests for a module/class.  TypeScript tests use jest as test framework. They will be run by `jest` and useful to write unit tests. A test file name is ended with `.test.ts`.

```javascript
import {expect, jest, test} from '@jest/globals';
import { TSModule } from '../src/apps/apptemplate2/tsModule';

describe('testing tsModule', () => {
  test('An empty test', () => {
    moduletInstance : TSModule = new TSModule('myname',1);
    expect(true).toEqual(true);
  });
});
```

## Tests - React

### React - Test files

React test files have the same name as the main app and ended with `.test.js` for example for an app named `apptemplate.js`, thest file name is  `apptemplate.test.js` and is stored alongside the source file. React tests use Jest as test framework. They will be run by `npm run test` and useful to test the final product. In fact by running `npm run test` rendered outputs of the app will be checked to find expected elements.

```javascript
import { render, screen } from '@testing-library/react';
import ReactTemplateApp from './ReactTemplateApp';

test('renders learn react link', () => {
  render(<ReactTemplateApp />);
  const linkElement = screen.getByText(/ReactTemplateApp/i);
  expect(linkElement).toBeInTheDocument();
});
```

* **OBS!** unit tests run with 'jest' need to add some configuration files to the root of projects
> * `babel.config.js`
>
>>```javascript
>>module.exports = {presets: ['@babel/preset-env']}
>>```
>>
> * `jest.config.js`
>
>>```javascript
>>module.exports = {
>>  preset: 'ts-jest',
>>  transform: {
>>    '^.+\\.(ts|tsx)?$': 'ts-jest',
>>    "^.+\\.(js|jsx)$": "babel-jest",
>>  },
>>  testEnvironment: 'node',
>>  testRegex: '/tests/.*\\.(test|spec)?\\.(ts|tsx|js)$',
>>  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node']
>>};
>>```

## Tests - Javascript/NodeJS

### Javascript/NodeJS - Test files

Javascript test files are stored in a folder named `tests`in the root of a project. Each test file contains only tests for a module/class.  Javascript tests use jest as test framework. They will be run by `jest` and useful to write unit tests.  A test file name is ended with `.test.ts`.

```javascript
var myTemplateClass = require('../src/apps/apptemplate2/TemplateClass');

describe('testing TemplateClass', () => {
  test('An empty test', () => {
    var templateClassInstance = new myTemplateClass('myTemplateClass',1);
    expect(true).toEqual(true);
  });
});
```

## Tests - Bash

### Bash script file structures

To make a bash script file testable, it needs to code in a correct way. A good structured bash script file, put all code in functions and calls them in a simple main. Testing functions more easier than a raw script

```bash
function lookForArgument () #@ USAGE lookForArgument argToCheck param1 param2
{
    argToCheck=$1
    inParamArray=($@)
    inParamArray=("${inParamArray[@]:1}")
    inParamTotalElements=${#inParamArray[@]}

    currentElement=0
    for inparam in "${inParamArray[@]}"
    do
        if [ "$inparam" = $argToCheck ]; then
            # The argument was found
            # Return next element if there is more elements
            [ $(( inParamTotalElements - 1 )) -gt $currentElement ] &&
                nextElementId=$(( currentElement + 1 )) &&
                echo "${inParamArray[currentElement + 1]}"
            return 0
        fi
        currentElement=$(( currentElement + 1 ))
    done

    # Not found
    return 1
}
function mainFunction () { #@ USAGE mainFunction param1 param2 ...
    return 0
}
#---------------------------------------
# Main
nextitem=$(lookForArgument "--main" "$@")
[ $? -eq 0 ] &&
    mainFunction "$@" &&
    exit $?
```

### Bash - Test files

Each test group for a bash script contains two files, `<scriptname>.overload.shinc` and `<scriptname>.test.sh`. Overload files overload bash script internal functions that do not need to tests and can be mocked. And test files containes tests. It also uses a mock file named `test.mock.shinc` to mock system functions used within bash scripts
* `<scriptname>.overload.shinc`

```bash
#: Overloading values and data to test a script
## Import libraries
[ -f $TESTORIGINALSCRIPT_PATH/test.mock.shinc ] &&
	. $TESTORIGINALSCRIPT_PATH/test.mock.shinc

#-------------------------------------------------
# Test data to overload packagebuilder.sh
function internalFunc () #@ USAGE internalFunc parameters
{
	mockCallCounter "${FUNCNAME[0]}"
	echo $(mockCallOutput "${FUNCNAME[0]}" "internalFunc :  \"$1\"")
	mockCallReturn "${FUNCNAME[0]}" 0
	return $?
}

echo -e "****Runing in a test mode"
echo -e "-------------------------------------------------"
```

* `<scriptname>.test.shinc`

```bash
#!/bin/bash
#: tests
TESTORIGINALSCRIPT_PATH=$( dirname $(realpath "$0") )
SCRIPT_PATH=$( dirname "$0")

## Import libraries
[ -f $TESTORIGINALSCRIPT_PATH/<scriptname>.sh ] &&
	. $TESTORIGINALSCRIPT_PATH/<scriptname>.sh
[ -f $TESTORIGINALSCRIPT_PATH/<scriptname>.overloader.shinc ] &&
	. $TESTORIGINALSCRIPT_PATH/<scriptname>.overloader.shinc
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
#*  @description    Test
#*
#*  @param
#*
#*  @return			0 SUCCESS, > 0 FAILURE
#*
function TEST_SCRIPT ()
{
	return 0
}

# Main - run tests
#---------------------------------------
TEST_CASES=(  \
	'TEST_SCRIPT' )
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
```

## Run unit tests

To run unit tests a script named `trun` can be used

```bash
# run all unit tests
# Python 2.x & 3.x, php, java and android
./trun -unit
# or
./trun -u

# run all unit tests with info traces (only python for now)
./trun -unit info

# run all unit tests with debug traces
./trun -unit debug

# run all unit tests in a test class (only python for now)
# TestClassName is the name of the Test class in `TestServiceManager.py`
# Running only a test class always is run debug mode
./trun -unit -case TestClassName

# run only one test case (only python for now)
# TestClassName is the name of the Test class in `TestServiceManager.py`
# test_classname_funcname is the name of the test defined in TestClassName
# Running only a test case always is run debug mode
./trun -unit -case TestClassName.test_classname_funcname
```

* **OBS** Running `trun.sh` in the root of the project, run tests defined in all sub-projects.
* **OBS** If a tests files contains more than on test class the neme of the file should be added in the begining of test name if `-case` is used

```bash
./trun -unit -case TestFileName.TestClassName.test_classname_funcname
```

### Run block tests

The Block test files usually have only one test class.
To run block tests a script named `trun.sh` can be used

```bash
# run all tests
# Python 2.x & 3.x, php, java and android
./trun -block
# or
./trun -b

# run all tests with info traces (only python for now)
./trun -block info

# run all tests with debug traces (only python for now)
./trun -block debug

# run only one test case (only python for now)
# test_testname is the name of the test defined in TestCrawlerManager
# Running only a test case always is run debug mode
./trun -block -case BlockTestClassName.test_testname
```

* **OBS** Running `ccrun` in the root of the project, run tests defined in all sub-projects.
* **OBS** If a tests files contains more than on test class the neme of the file should be added in the begining of test name if `-case` is used

```bash
./trun -block -case BlockTestFileName.BlockTestClassName.test_classname_funcname
```

### Run file checker tests (xml, html and json)

Tests are run file by file it means all file should be listed in `.testfils` in the related arrays (`XML_FILES` , `HTML_FILES` or `JSON_FILES`).
To run tests a script named `trun.sh` can be used. in the case of testing only file formats, parameters sent to `trun.sh` is not checked.

```bash
./trun
```

### Android tools

There are some scripts developed to run and test android apps. all scripts are stored in `yourproject/AppClientUnits/android/utils`.
* `aabuilder.sh`
> Build an android app from the given project name. Projects should be stored in `AppClientUnits/android/` and `aabuilder.sh` shoulöd be run in `AppClientUnits/android/utils`. The output is stored in `AppClientUnits/android/utils/apks`
>
>```bash
>./abuilder.sh YourApp
>```
>
> * **OBS!** the script downloads required libs from `yoursite` they do not exist in the local repo.
* `akeygen.sh`
> Usually ther is no need to run this script, key files are downloaded from `yoursite`.
* `arun.sh`
> This script run a given app (an apk file that has already built and stoored in `AppClientUnits/android/utils/apks` by `aabuilder.sh`) in the default android device connected to computer. The script uses `abd` to install, running, closing and uninstalling the app.
>
>```bash
>./arun.sh YourApp
>```
>
* `apktest.sh`
> The script test a given app by using `apkanalyzer`
>
>```bash
>./atest.sh YourApp
>```
>
* `getandroidsdk.sh`
> The script download android-sdk and stores that in the home folder of the current user. to run `atest.sh` it needs to download android-sdk first. `atest.sh` uses `apkanalyzer` installed by `getandroidsdk.sh`
* `mapnextreporosity.sh`
> This script has to developed to map the repository used by environment tools.

* **OBS!** `trun` uses a temporary folder name `bin`to compile codes and running tests. The temporary folder is deleted after running all tests. To not remove temporary folder and keep it after running `trun`, use `-keep` as an argument passed to `trun`
>
>```bash
>./trun -keep -u
>```

* **OBS!** `trun` uses/looks the current user home folder (`$HOME`) for `node_modules` and other modules/files needed to run tests. In the server side, needed modules/files stored in a folder named `codechecker` stored in `/home`. To force `trun` to use `/home/codechecker` as the home folder it needs to use `-servermode` as as an argument passed to `trun`. `.codechecker`filses stored in the project folders use this parameter to run `trun`

### Jenkins test job to verify commits

The test job scenario for sub-project can be updated by commiting `.codechecker` witch is stored in the root of the project (for sub-projects in the root of the sub-projects).

`.codechecker` use a bash script syntax without and bash header. Terminal commands such as `mkdir`, `rm` can be used via a function named `remoterun`. A `.codechecker` script look like the script below :

```bash
subProjectName=AddonsManager
echo "---$subProjectName"

remoterun "mkdir $PROJECT_WORKSPACE/$subProjectName/bin"

remoterun "$PROJECT_WORKSPACE/$subProjectName/$UNIT_TEST_CMD"
exitcode=$?
if [ $exitcode -eq 0 ]; then
	remoterun "$PROJECT_WORKSPACE/$subProjectName/$BLOCK_TEST_CMD"
	exitcode=$?
fi
```

There are several environment variables that are passed to the `.codechecker` witch can be used to find and manage codes

```bash
# Environment variables passd by Gerrit trigger :
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
#   PROJECT_PATH
#   UPDATEDFILES_ARR
#   PATCHSET_TOTALFILES
#   PATCHSET_TOTALENVFILES
#   CHROOT_PATH
#   CHROOT_WORKSPACE
#   JOB_WORKSPACE
#   PROJECT_WORKSPACE
#   exitCode
#
#   remoterun()
#
# Runner variables:
#   UNIT_TEST_CMD
#   BLOCK_TEST_CMD
```

The current `.codechecker` run unit tests and block tests with both Python 2.7 & 3.6, and Php to verify a commit.

**OBS!** No code formatting check has been implemented yet.

### Setup chroot on the serverside for Jenkins jobs

```bash
sudo debootstrap --variant=buildd --arch amd64 bionic /var/lib/tomcat9/webapps/jenkins/workspace/CodeChecker/testroot/ http://archive.ubuntu.com/ubuntu/

# run chroot
sudo chroot /var/lib/tomcat9/webapps/jenkins/workspace/CodeChecker/testroot /bin/bash

# install environment prerequisites
apt update
# install general toolscheckrunner.sh
apt install net-tools
apt install nano
apt install curl
apt install sqlite3

# Python 2.7
apt install python

# setup pip for python version 2.7
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py
python get-pip.py
python -m pip install mock
python -m pip install mysql.connector
python -m pip install requests
python -m pip install configparser

# setup pip for python version 3
apt install software-properties-common
add-apt-repository universe
apt install python3
apt install python3-pip
pip3 install pymysql
pip3 install requests

# Php
apt install php-cli
apt install phpunit
apt install php-curl

># Java
# To install java it needs to mount the /proc filesystem inside the chroot
# run the line below befor run chroot
# sudo mount -o bind /proc /var/lib/tomcat9/webapps/jenkins/workspace/CodeChecker/testroot/proc
apt-get install openjdk-8-jdk-headless
apt-get install junit4

#Android
apt install aapt
apt install sdkmanager
/usr/bin/sdkmanager --install "platforms;android-29"
ln -s /opt/android-sdk/platforms/android-29/android.jar /usr/share/java/android.jar
# in the case that sdkmanager was not found (android sdk is installed in /usr/lib/android-sdk)
# apt-get install android-sdk
# ln -s /usr/lib/android-sdk/platforms/android-<xx>/android.jar /usr/share/java/android.jar

# Json
#apt install python3-demjson
pip3 install demjson3

#HTML
#apt install tidy
wget https://github.com/htacg/tidy-html5/releases/download/5.8.0/tidy-5.8.0-Linux-64bit.deb
dpkg -i tidy-5.8.0-Linux-64bit.de
rm tidy-5.8.0-Linux-64bit.deb 

#XML
apt-get install libxml2-utils

#NodeJS v15 or newer
#apt install nodejs
#sudo apt install npm
cd ~
curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh
bash /tmp/nodesource_setup.sh
sudo apt update
sudo apt install nodejs

#Angular
npm install -g @angular/cli

apt install wget
cd ~
./update_nm.sh
# wget http://yoursite/reporosity/node_modules.tar.gz
# tar -xf node_modules.tar.gz -C $HOME
# rm $HOME/node_modules.tar.gz

# Angular tests needs firfox headlees version
apt install firefox
apt install xvfb
```

* **OBS** `update_nm.sh`
>
>```bash
>#!/bin/bash
>nodeModuleVersion=2
>[ -d /home/codechecker/node_modules ] &&
>        rm -r /home/codechecker/node_modules
>
>[ -f /home/<youruser>/node_modules.tar.gz ] &&
>        rm /home/<youruser>/node_modules.tar.gz
>cd ~
>wget http://yoursite/reporosity/node_modules${nodeModuleVersion}.tar.gz
>tar -xf node_modules${nodeModuleVersion}.tar.gz -C /home/codechecker/
>chmod 777 /home/codechecker/node_modules
>rm /home/<youruser>/node_modules${nodeModuleVersion}.tar.gz
>```

* **OBS!** Java is little bit different from other software. To install and running java in a chroot environment it needs to mount /procfolder in the host to the chroot environment

>```bash
>sudo mount -o bind /proc /var/lib/tomcat9/webapps/jenkins/workspace/CodeChecker/testroot/proc
>```
>
> * To start it in the startup :
>>`sudo nano /etc/fstab`
>>
>>>```bash
>>>/proc /var/lib/tomcat9/webapps/jenkins/workspace/CodeChecker/testroot/proc none defaults,bind 0 0
>>>```

### BlackBox

* To run virtualbox node @ yourserver

>```bash
>ssh xxx.xxx.xxx.xxx VBoxManage startvm mini18-2234-5034 --type headless
>```

* ssh to the vm

>```bash
>ssh -p 2234 xxx.xxx.xxx.xxx
>```
