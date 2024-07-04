#!/bin/sh
set -e

xcrun -sdk iphonesimulator clang \
    -fobjc-arc -framework UIKit \
    -o handmade-ios.app/handmade-ios \
    main.m
