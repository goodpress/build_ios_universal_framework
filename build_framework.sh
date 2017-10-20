#!/bin/bash
# http://code.hootsuite.com/an-introduction-to-creating-and-distributing-embedded-frameworks-in-ios/
# 1
# Set bash script to exit immediately if any commands fail.
set -ex
 
# 2
# Setup some constants for use later on.
FRAMEWORK_NAME="sdbframework"
archiveDir="${HOME}/Desktop/myj_archive"
archiveFrame="${archiveDir}/${FRAMEWORK_NAME}.framework"
archiveFrameCore="${archiveFrame}/${FRAMEWORK_NAME}"
buildBaseDir="${PWD}/Build/Products"
buildIphoneFrame="${buildBaseDir}/Release-iphoneos/${FRAMEWORK_NAME}.framework"
buildIphoneFrameCore="${buildIphoneFrame}/${FRAMEWORK_NAME}"
buildSimulatorFrame="${buildBaseDir}/Release-iphonesimulator/${FRAMEWORK_NAME}.framework"
buildSimulatorFrameCore="${buildSimulatorFrame}/${FRAMEWORK_NAME}"
 
# 3
# If remnants from a previous build exist, delete them.
if [ -d "${PWD}/build" ]; then
	rm -rf "${PWD}/build"
fi
 
# 4
# Build the framework for device and for simulator (using all needed architectures).
# if u project is project , use below  -target module 
#xcodebuild -target "${FRAMEWORK_NAME}" -configuration Release -arch arm64 -arch armv7 -arch armv7s only_active_arch=no defines_module=yes -sdk "iphoneos"
#xcodebuild -target "${FRAMEWORK_NAME}" -configuration Release -arch x86_64 only_active_arch=no defines_module=yes -sdk "iphonesimulator"
xcodebuild -workspace sdbsdk.xcworkspace  -scheme "${FRAMEWORK_NAME}" -configuration Release -arch arm64 -arch armv7 -arch armv7s only_active_arch=no defines_module=yes -sdk "iphoneos" >> xcodebuild_output
code=$?
if [[ ${code} -ne 0 ]] ;then
	echo "WARN , xcodebuild device arch return code : ${code}"
fi
xcodebuild -workspace sdbsdk.xcworkspace  -scheme "${FRAMEWORK_NAME}" -configuration Release -arch x86_64 only_active_arch=no defines_module=yes -sdk "iphonesimulator" >> xcodebuild_output
 
code=$?
if [[ ${code} -ne 0 ]] ;then
	echo "WARN , xcodebuild simulator return code : ${code}"
fi

# 5
# Remove .framework file if exists on Desktop from previous run.
if [ -d "${archiveFrame}" ]; then
	rm -rf ${archiveFrame}
fi
if [ !  -d "${archiveDir}" ]; then
	mkdir -p ${archiveDir}
fi
 
# 6
# Copy the device version of framework to Desktop.
cp -r "${buildIphoneFrame}" "${archiveFrame}"
 
# 7
# Replace the framework executable within the framework with
# a new version created by merging the device and simulator
# frameworks' executables with lipo.
if [[ ! -d "${buildIphoneFrame}" ]] ;then
	echo " ${buildIphoneFrame}  does not exit "
	exit 1;
fi
if [[ ! -d "${buildSimulatorFrame}" ]] ;then
	echo " ${buildSimulatorFrame}  does not exit "
	exit 1;
fi
	

# 8
# Copy the Swift module mappings for the simulator into the 
# framework.  The device mappings already exist from step 6.
tmpSwiftmoduleFile="${buildIphoneFrame}/Modules/${FRAMEWORK_NAME}.swiftmodule"
if [[ -f ${tmpSwiftmoduleFile} ]] ;then
	archiveSwiftModule="${archiveFrame}/Modules/${FRAMEWORK_NAME}.swiftmodule"
	cp -r "${tmpSwiftmoduleFile}"  "${archiveSwiftModule}"
fi

echo "show archive folder info : "
ls -alh  ${archiveDir}
lipo -create  "${buildIphoneFrameCore}"  "${buildSimulatorFrameCore}"  -output  "${archiveFrameCore}"  
echo " show core  info : "
lipo -info "${archiveFrameCore}"
echo " show core  size  : "
du -sh "${archiveFrameCore}"
echo " show core  md5 : "
md5 -q "${archiveFrameCore}"

