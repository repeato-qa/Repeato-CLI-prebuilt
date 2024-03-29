# You may see available device
adb devices

# Goto build folder and install the app according to emulator architecture
cd demo-app/build/app/outputs/flutter-apk/ && adb install app-x86_64-release.apk

# install relevant repeato cli based on machine types
cd ../../../../../ # Back to root directory
MACHINE_TYPE=`uname -m`

# Use below script to install latest CLI always
RELEASE_URL=$(node ./.github/workflows/latest-cli-release.js "${MACHINE_TYPE}" "") 
wget -q "${RELEASE_URL}" -O repeato-cli.zip
unzip -qq repeato-cli.zip -d repeato-cli/

cd repeato-cli

# log.txt is optional paramter - you may remove it (only needed when you want to send logs to REPEATO for debugging)
node testrun.js --licenseKey "$LICENSE_KEY" --workspaceDir "../workspace-tests" --batchId "0" --outputDir "../batch-report" --logLevel DEBUG > log.txt

# cd ../batch-report # report path which is at root level

# Other available builds for installations
#adb install app-x86_64-release.apk
#adb install app-arm64-v8a-release.apk
#adb install app-armeabi-v7a-release.apk
#adb install app.apk // this works too
