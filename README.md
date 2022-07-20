# Repeato CLI Test Runner

## Introduction

Repeato CLI is a headless test runner that allows you to execute test batches designed with Repeato Studio. We try to rely as much a possible on open standards, so all the workspace data is stored in either image formats or text based formats (mostly JSON).
That makes it possible to generate tests not just with Repeato Studio, but also with tools of your choice.

That's also true for the test run artefacts: All data is stored as image data (screenshots), XML (JUnit export, can be used for Jenkins) and JSON.

Repeato CLI is built using nodejs which makes it possible to run it on almost any system. However, it has dependencies to native modules, which makes it necessary to build parts of it for the target OS and platform. That's why we prebuild the package and ship it this way.

![screenshot of Repeato CLI](https://www.repeato.app/wp-content/uploads/2022/05/repeato-continuous-integration-CLI-testrunner-1024x482.png)

## Inputs:

The testrunner essentially needs two inputs:

1. The path to your workspace containing you batch
2. The batch ID of the batch you want to execute

`node testrun.js --help` will print all the required and optional params:

```
--workspaceDir: path to the workspace directory
--deviceId: optional. The device ID of the device you want to connect to
--batchId: which batch should be executed. just execute testrun.js -w [workspace-dir] to see a list of contained batches
--runMode: "AllTests" | "OnlyFailed" (default: "AllTests")
--waitDurationBetweenSteps: optional. Additional wait time between step executions can help during debugging or to increase test stability. (default: 0, milliseconds)
--outputDir: option to override the default export path (default is: [workspaceDir]/batchRuns)
--logLevel: "TRACE" | "DEBUG" | "INFO" (default: "INFO")
--force: ignore errors (DB version mismatch) and execute anyway
--licenseKey: license key to unlock full feature set of Repeato-CLI
```

## Outputs:

1. An html file containing a table with links pointing to the test run results is created in the root folder of Repeato CLI
2. A JUnit xml file is created in the root folder of Repeato CLI
3. For each test a testRun object is created in `[workspaceDir]/[testId]/test.json`
4. For each test step a screenshot is created in `[workspaceDir]/[testId]/testRuns/[deviceId]/`
5. An html batch report is created in the `[workspaceDir]/batchReports` directory. The batchReport directory can be shared via a webserver to make the report accessible to your QA team.
6. A batchRun.json file containing all the batch run information in `[workspaceDir]/batchReports/[your batch report]` directory

## Requirements:

Supported nodejs version: 14.18 (you can use nvm to switch to the right nodejs version: `nvm use 14.18`).

Supported operating systems: MacOS, Windows, Linux

## Installing testrunner

This distribution comes as a prebuilt package. Just extract it to a directory of your choice.

## Additional scripts

- `clearAllTestRunData.js`: Deletes all test run data in the workspace. Execute it each time before a batch run to get a fresh batch run report without any history data from previous batch runs. It's open source, so feel free to edit and adjust it to your needs.

## Install emulator on Windows

The easiest way to install Emulators on Windows is to download Android Studio: https://developer.android.com/studio

Android Studio comes with a set of tools, one of them being "AVD Manager" (AVD = "Android Virtual Device"), which allows you to easily create and manage AVDs.

## Install emulator on Linux

1. To create AVDs (Android Virtual Devices) you need to use avdmanager. Avdmanager is part of the command line tools, which can be downloaded here: https://developer.android.com/studio#command-tools
2. Install java sdk if needed: `sudo apt install openjdk-11-jdk`
3. Set JAVA_HOME var: `export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64`
4. Create virtual device (AVD): `avdmanager create avd -n test -k "system-images;android-25;google_apis;x86"`

## Test execution

### Run emulator from command line

https://developer.android.com/studio/run/emulator-commandline

### Install app on test device / emulator via ADB

Repeato CLI has ADB on board already:

1. `./testrunner/resources/platform-tools-[yourOS]/adb push myapp/build/apk/myapp.apk /data/local/tmp/com.x.myapp`
2. `./testrunner/resources/platform-tools-[yourOS]/adb shell pm install -t -r -d /data/local/tmp/com.x.myapp`

### Serve test results over http

During the test run, test artifacts are stored to your workspace directory. It's possible to serve those over a small http server:
`node server.js --help`

## Troubleshooting

### Device does not connect on linux

There are two things that need to be set up correctly: each user that wants to use adb needs to be in the `plugdev` group, and the system needs to have udev rules installed that cover the device.

plugdev group: If you see an error message that says you're not in the plugdev group, you'll need to add yourself to the plugdev group:

`sudo usermod -aG plugdev $LOGNAME`

Note that groups only get updated on login, so you'll need to log out for this change to take effect. When you log back in, you can use the `id` command to check that you're now in the plugdev group.

udev rules: The android-sdk-platform-tools-common package contains a community-maintained default set of udev rules for Android devices. To install:

`apt install android-sdk-platform-tools-common`
