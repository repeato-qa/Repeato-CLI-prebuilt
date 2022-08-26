# Repeato CLI Test Runner

## Introduction

Repeato CLI is a headless test runner that allows you to execute test batches designed with [Repeato Studio](https://www.repeato.app).

![Repeato CLI screenshot](https://www.repeato.app/wp-content/uploads/2022/08/cli-screenshot.png)

We try to rely as much a possible on open standards, so all the workspace data is stored in either image formats or text based formats (mostly JSON).
That makes it possible to generate tests not just with Repeato Studio, but also with tools of your choice.
That's also true for the test run artefacts: All data is stored as image data (screenshots), XML (JUnit export, can be used for Jenkins) and JSON.

Repeato CLI is built using Node.js which makes it possible to run it on almost any system. However, it has dependencies to native modules, which makes it necessary to build parts of it for the target OS and platform. That's why we prebuild the package and ship it this way.

## Inputs:

The testrunner essentially needs two inputs:

1. The path to your workspace containing you batch
2. The batch ID of the batch you want to execute

`node testrun.js --help` will print all the required and optional params:

```
Required params:
  --workspaceDir: Path to the workspace directory
  --deviceId: Optional. The device ID of the device you want to connect to
    List Android devices via 'adb devices' or iOS simulators via 'xcrun simctl list'

Optional params:
  --batchId: Which batch should be executed.
    Just execute testrun.js -w [workspace-dir] to see a list of contained batches
  --runMode: "AllTests" | "OnlyFailed" (default: "AllTests")
  --timeoutFactor: Since some CI servers sometimes don't provide as much performance as local machines,
    it can be useful to increase the timeout when running on a server by a factor. E.g pass 1.5 to increase the timeouts by 50% (default: 1.0)
  --waitDurationBetweenSteps: Additional wait time between step executions can help during debugging or to increase test stability.
    (default: 0, milliseconds)
  --outputDir: Override the default export path for batch run reports (default is: [workspaceDir]/batchRuns)
  --logLevel: "WARN" | "INFO" | "DEBUG" (default: "INFO")
  --force: Ignore errors (DB version mismatch) and execute anyway
  --licenseKey: License key to unlock full feature set of Repeato-CLI

Examples
  $ testrun.js --workspaceDir [path to your workspace]
  List all batches in your workspace, just execute

  $ testrun.js --workspaceDir [path to your workspace] --batchId [ID of your batch]
  Executes all the tests in a given batch)
```

## Outputs:

1. A JUnit xml file is created in the root folder of Repeato CLI
2. For each test a testRun object is created in `[workspaceDir]/[testId]/test.json`
3. For each test step a screenshot is created in `[workspaceDir]/[testId]/testRuns/[deviceId]/`
4. An html batch report is created in the `[workspaceDir]/batchRuns` directory. The exported directory can be shared via a webserver to make the report accessible to your QA team.
5. A batchRun.json file containing all the batch run information in `[workspaceDir]/batchReports/[your batch report]` directory
6. Returns with exit code 0 if batch runner managed to run all tests, even if a test failed. Returns different exit code if some error occured during execution.

## Requirements:

Supported Node.js version: 14.18 (you can use nvm to switch to the right Node.js version: `nvm use 14.18`).

Supported operating systems: MacOS, Windows, Linux

For **Apple Sillicon (M1 / ARM architecture)**, you need to use Node.js v16 (v16.13.0 is tested)

## Installing testrunner

This distribution comes as a prebuilt package. Download from here: https://github.com/repeato-qa/repeato-cli-prebuilt/releases

Just download and extract it to a directory of your choice.

## Additional scripts

- `clearAllTestRunData.js`: Deletes all test run data in the workspace. Execute it each time before a batch run to get a fresh batch run report without any history data from previous batch runs. It's open source, so feel free to edit and adjust it to your needs.
- `server.js`: Demo implementation of a simple Node.js http server for serving batch run results

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
