#!/bin/sh
set -e

xcrun --sdk iphonesimulator swiftc \
    -target arm64-apple-ios17.4-simulator \
    -o handmade-ios.app/handmade-ios \
    main.swift
