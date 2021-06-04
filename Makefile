SYSROOT = $(THEOS)/sdks/iPhoneOS13.3.sdk
ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard

FINAL_RELEASE = 1
DEBUG = 0

TWEAK_NAME = Vivy

$(TWEAK_NAME)_FILES = Vivy.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_EXTRA_FRAMEWORKS = CoreGraphics QuartzCore UIKit

SUBPROJECTS += Prefs

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
include $(THEOS_MAKE_PATH)/tweak.mk
