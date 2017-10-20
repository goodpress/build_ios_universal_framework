#!/bin/bash
# http://code.hootsuite.com/an-introduction-to-creating-and-distributing-embedded-frameworks-in-ios/
# 1 # Set bash script to exit immediately if any commands fail.
set -ex
 
FRAMEWORK_NAME="sdbsdkResouce"
archiveDir="${HOME}/Desktop/myj_archive"
archiveBundle="${archiveDir}/${FRAMEWORK_NAME}.bundle"
buildBaseDir="${PWD}/Build/Products"
buildIphoneBundle="${buildBaseDir}/Release-iphoneos/${FRAMEWORK_NAME}.bundle"
 
if [ -d "${PWD}/Build" ]; then
	rm -rf "${PWD}/Build"
fi
 
# 4
xcodebuild -workspace sdbsdk.xcworkspace  -scheme "${FRAMEWORK_NAME}" -configuration Release -sdk "iphoneos" >> xcodebuild_output
code=$?
if [[ ${code} -ne 0 ]] ;then
	echo "WARN , xcodebuild device arch return code : ${code}"
fi

 
if [[ ! -d "${buildIphoneBundle}" ]] ;then
	echo " ${buildIphoneBundle}  does not exit "
	exit 1;
fi
# Remove .framework file if exists on Desktop from previous run.
if [ -d "${archiveBundle}" ]; then
	rm -rf ${archiveBundle}
fi
if [ !  -d "${archiveDir}" ]; then
	mkdir -p ${archiveDir}
fi

 
	
cp -r "${buildIphoneBundle}" "${archiveBundle}"
echo "show archive folder info : "
ls -alh  ${archiveDir}
echo " show bundle  size  : "
du -sh "${archiveBundle}"
