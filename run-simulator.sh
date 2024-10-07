#!/bin/sh
set -ex

sim_id="<YOUR-SIMULATOR-ID>"
xcrun simctl bootstatus $sim_id -b >/dev/null
xcrun simctl install $sim_id ./handmade-ios.app
xcrun simctl launch --console $sim_id com.example.handmade-ios
