#! /bin/bash

TEST_CMD="xcodebuild -scheme MemoryGame -workspace MemoryGame.xcworkspace -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.3.1' build test"

which -s xcpretty
XCPRETTY_INSTALLED=$?

if [[ $TRAVIS || $XCPRETTY_INSTALLED == 0 ]]; then
  eval "${TEST_CMD} | xcpretty"
else
  eval "$TEST_CMD"
  fi
