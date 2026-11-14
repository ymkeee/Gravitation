THEOS_PACKAGE_SCHEME ?= roothide
TARGET = iphone:clang:16.5:15.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Gravitation

Gravitation_FILES = Tweak.x
Gravitation_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function
Gravitation_FRAMEWORKS = UIKit CoreGraphics QuartzCore CoreMotion AudioToolbox

include $(THEOS)/makefiles/tweak.mk

SUBPROJECTS += gravitationprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
