#!/bin/sh
set -ex

device_id="<YOUR-DEVICE-ID>"
xcrun devicectl device install app --device $device_id handmade-ios.ipa
xcrun devicectl device process launch --console --device $device_id com.example.handmade-ios
