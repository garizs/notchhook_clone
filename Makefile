# ---------- Config ----------
APP_NAME      := NotchNookClone
BUNDLE_ID     := dev.local.notchnookclone
MIN_MACOS     := 14.0

BUILD_DIR     := build_$(APP_NAME)
APP_DIR       := $(BUILD_DIR)/$(APP_NAME).app
CONTENTS_DIR  := $(APP_DIR)/Contents
MACOS_DIR     := $(CONTENTS_DIR)/MacOS
RES_DIR       := $(CONTENTS_DIR)/Resources

SWIFTC        := swiftc
CLANG         := clang

SWIFT_SOURCES := $(wildcard Sources/*.swift)
OBJC_SOURCES  := Sources/MediaRemoteBridge.m
OBJC_OBJECTS  := $(BUILD_DIR)/MediaRemoteBridge.o
BRIDGING_HDR  := Sources/NotchNookClone-Bridging-Header.h

ARCH          := $(shell uname -m)

# ---------- Flags ----------
SWIFTFLAGS := \
  -O -g \
  -import-objc-header $(BRIDGING_HDR) \
  -Xlinker -rpath -Xlinker /System/Library/PrivateFrameworks \
  -framework AppKit -framework Foundation -framework SwiftUI \
  -target $(ARCH)-apple-macosx$(MIN_MACOS)

CLANGFLAGS := -fobjc-arc -fmodules -mmacosx-version-min=$(MIN_MACOS)

# ---------- Phony ----------
.PHONY: all build build-exe bundle sign run clean zip info

# ---------- Default ----------
all: run

# Создаём build/ заранее
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Компилируем ObjC в .o (создаём build/ если нет)
$(OBJC_OBJECTS): $(OBJC_SOURCES) | $(BUILD_DIR)
	$(CLANG) $(CLANGFLAGS) -c $< -o $@

# Сборка бинаря Swift + линковка с ObjC
build-exe: $(SWIFT_SOURCES) $(OBJC_OBJECTS) | $(BUILD_DIR)
	$(SWIFTC) $(SWIFT_SOURCES) $(OBJC_OBJECTS) $(SWIFTFLAGS) -o $(BUILD_DIR)/$(APP_NAME)

# Упаковка .app
bundle: build-exe
	@mkdir -p $(MACOS_DIR) $(RES_DIR)
	@cp $(BUILD_DIR)/$(APP_NAME) $(MACOS_DIR)/$(APP_NAME)
	@cp Support/Info.plist $(CONTENTS_DIR)/Info.plist
	@/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $(BUNDLE_ID)" $(CONTENTS_DIR)/Info.plist >/dev/null 2>&1 || true

# Подпись (ad-hoc, Hardened Runtime, entitlements)
sign: bundle
	@which codesign >/dev/null 2>&1 || { \
	  echo "ERROR: codesign не найден. Установи Command Line Tools: xcode-select --install"; exit 1; }
	codesign -s - --force --options runtime \
	  --entitlements Support/NotchNookClone.entitlements \
	  "$(APP_DIR)"

# Полная сборка
build: sign

# Запуск
run: build
	open "$(APP_DIR)"

# Очистка
clean:
	rm -rf "$(BUILD_DIR)"

# Архив исходников (без build/)
zip:
	@rm -f notchnook-cli.zip
	@zip -rq notchnook-cli.zip . -x "build/*" -x ".git/*" -x ".DS_Store" -x ".gitignore"

# Инфо
info:
	@echo "Arch:      $(ARCH)"
	@$(SWIFTC) --version | sed -n '1p'
	@$(CLANG)  --version | sed -n '1p'
