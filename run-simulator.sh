#!/bin/sh
set -e

IPHONE_15_SIM_ID="9340DADD-23AC-42E0-A6AF-BA720B728DD9"
xcrun simctl bootstatus "$IPHONE_15_SIM_ID" -b > /dev/null
xcrun simctl install "$IPHONE_15_SIM_ID" ./handmade-ios.app
xcrun simctl launch --console "$IPHONE_15_SIM_ID" com.example.handmade-ios
