#! /bin/bash

TEST_CMD="xcodebuild -scheme MemoryGame -workspace MemoryGame.xcworkspace -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.3.1' build test -enableCodeCoverage YES"

eval "$TEST_CMD"
