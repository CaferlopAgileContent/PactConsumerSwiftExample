#!/bin/bash

xcodebuild clean build test -workspace ../PactConsumerSwiftExample.xcworkspace -scheme "PactConsumerSwiftExampleForTests" -destination "platform=iOS Simulator,name=iPhone 12"
  
