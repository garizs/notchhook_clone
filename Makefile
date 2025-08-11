APP_NAME=NotchNookClone
BUNDLE_ID=dev.local.notchnookclone
BUILD_DIR=build
APP_DIR=$(BUILD_DIR)/$(APP_NAME).app
MACOS_DIR=$(APP_DIR)/Contents/MacOS
RES_DIR=$(APP_DIR)/Contents/Resources
CONTENTS=$(APP_DIR)/Contents

SWIFTC=swiftc
CLANG=clang

SWIFT_SOURCES=$(wildcard Sources/*.swift)
OBJC_SOURCES=Sources/MediaRemoteBridge.m
OBJC_OBJECTS=$(BUILD_DIR)/MediaRemoteBridge.o
BRIDGING_HEADER=Sources/NotchNookClone-Bridging-Header.h

SWIFTFLAGS= -O -g -enable-bare-slash-regex   -import-objc-header $(BRIDGING_HEADER)   -Xlinker -rpath -Xlinker /System/Library/PrivateFrameworks   -framework AppKit -framework Foundation -framework SwiftUI -framework MediaRemote   -target $(shell uname -m)-apple-macosx14.0

CLANGFLAGS= -fobjc-arc -fmodules -mmacosx-version-min=14.0

.PHONY: all build bundle sign run clean zip

all: run

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(OBJC_OBJECTS): $(OBJC_SOURCES) | $(BUILD_DIR)
	$(CLANG) $(CLANGFLAGS) -c $< -o $@

build-exe: $(SWIFT_SOURCES) $(OBJC_OBJECTS)
	$(SWIFTC) $(SWIFT_SOURCES) $(OBJC_OBJECTS) $(SWIFTFLAGS) -o $(BUILD_DIR)/$(APP_NAME)

bundle: build-exe
	@mkdir -p $(MACOS_DIR) $(RES_DIR)
	@cp $(BUILD_DIR)/$(APP_NAME) $(MACOS_DIR)/$(APP_NAME)
	@cp Support/Info.plist $(CONTENTS)/Info.plist

sign: bundle
	codesign -s - --force --options runtime \
	  --entitlements Support/NotchNookClone.entitlements \
	  "$(APP_DIR)"

build: sign

run: build
	open "$(APP_DIR)"

clean:
	rm -rf $(BUILD_DIR)

zip: clean
	zip -r notchnook-cli.zip . -x "*/\.*" -x "build/*"
