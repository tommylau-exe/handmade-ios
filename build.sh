#!/bin/sh
set -ex

xcrun -sdk iphoneos clang \
    -fobjc-arc -framework UIKit \
    -o handmade-ios.app/handmade-ios \
    main.m

# codeign our app and executable
certificate_name="<YOUR-CERTIFICATE-NAME>"
codesign -s $certificate_name --entitlements handmade-ios.app/Entitlements.plist -f handmade-ios.app
codesign -s $certificate_name --entitlements handmade-ios.app/Entitlements.plist -f handmade-ios.app/handmade-ios

# package the app into .ipa
rm -rf Payload/ handmade-ios.ipa/
mkdir Payload/
cp -r handmade-ios.app Payload/
zip -0yr handmade-ios.ipa Payload/
rm -rf Payload/
>>>>>>> 362a24c (part 2 blog post solution)
