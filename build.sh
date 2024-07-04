#!/bin/sh
set -e

xcrun -sdk iphonesimulator clang \
    -o handmade-ios.app/handmade-ios \
    main.c
