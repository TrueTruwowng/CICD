@REM ----------------------------------------------------------------------------
@REM Licensed to the Apache Software Foundation (ASF) under one
@REM or more contributor license agreements.  See the NOTICE file
@REM distributed with this work for additional information
@REM regarding copyright ownership.  The ASF licenses this file
@REM to you under the Apache License, Version 2.0 (the
@REM "License"); you may not use this file except in compliance
@REM with the License.  You may obtain a copy of the License at
@REM
@REM    http://www.apache.org/licenses/LICENSE-2.0
@REM
@REM Unless required by applicable law or agreed to in writing,
@REM software distributed under the License is distributed on an
@REM "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
@REM KIND, either express or implied.  See the License for the
@REM specific language governing permissions and limitations
@REM under the License.
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM Maven Start Up Batch script
@REM
@REM Required ENV vars:
@REM JAVA_HOME - location of a JDK home dir
@REM
@REM Optional ENV vars
@REM MAVEN_BATCH_ECHO - set to 'on' to enable the echoing of the batch commands
@REM MAVEN_BATCH_PAUSE - set to 'on' to wait for a keystroke before ending
@REM MAVEN_OPTS - parameters passed to the Java VM when running Maven
@REM     e.g. to debug Maven itself, use
@REM set MAVEN_OPTS=-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000
@REM MAVEN_SKIP_RC - flag to disable loading of mavenrc files
@REM ----------------------------------------------------------------------------

@if "%MAVEN_BATCH_ECHO%"=="on"  echo %MAVEN_BATCH_ECHO%

@setlocal

set ERROR_CODE=0

@REM Resolve current directory (symlinks not handled here)
set SCRIPT_DIR=%~dp0
if "%SCRIPT_DIR%"=="" set SCRIPT_DIR=.
set BASE_DIR=%SCRIPT_DIR%
if exist "%BASE_DIR%\.mvn" goto endDetectBaseDir
set BASE_DIR=%SCRIPT_DIR%..
:endDetectBaseDir

IF NOT EXIST "%BASE_DIR%\.mvn\wrapper\maven-wrapper.properties" (
  echo Cannot find .mvn\wrapper\maven-wrapper.properties in %BASE_DIR%
  goto error
)

@REM Read properties
for /F "usebackq tokens=1,2 delims==" %%A in ("%BASE_DIR%\.mvn\wrapper\maven-wrapper.properties") do (
  if "%%A"=="distributionUrl" set DISTRIBUTION_URL=%%B
  if "%%A"=="wrapperUrl" set WRAPPER_URL=%%B
)

if "%WRAPPER_URL%"=="" set WRAPPER_URL=https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar
set WRAPPER_JAR=%BASE_DIR%\.mvn\wrapper\maven-wrapper.jar

@REM Download wrapper jar if needed
if not exist "%WRAPPER_JAR%" (
  echo Downloading Maven Wrapper JAR from %WRAPPER_URL%
  powershell -ExecutionPolicy Bypass -NoLogo -NonInteractive -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('%WRAPPER_URL%', '%WRAPPER_JAR%')" || (
    echo Failed to download Maven Wrapper JAR
    goto error
  )
)

@REM Locate Java
set JAVA_EXE=
if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" set JAVA_EXE="%JAVA_HOME%\bin\java.exe"
if not defined JAVA_EXE set JAVA_EXE=java

@REM Provide multi-module project directory property for wrapper (was missing)
set MAVEN_PROJECTBASEDIR=%BASE_DIR%

%JAVA_EXE% -Dmaven.multiModuleProjectDirectory=%MAVEN_PROJECTBASEDIR% -classpath "%WRAPPER_JAR%" org.apache.maven.wrapper.MavenWrapperMain %*
if ERRORLEVEL 1 goto error
goto end

:error
set ERROR_CODE=1

:end
@endlocal & set ERROR_CODE=%ERROR_CODE%

if not "%MAVEN_SKIP_RC%"=="" goto skipRcPost
@REM invoke post script if present
if exist "%HOME%\mavenrc_post.bat" call "%HOME%\mavenrc_post.bat"
:skipRcPost

if "%MAVEN_BATCH_PAUSE%"=="on" pause

exit /B %ERROR_CODE%
