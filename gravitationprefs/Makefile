THEOS_PACKAGE_SCHEME ?= roothide
TARGET = iphone:clang:16.5:15.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = GravitationPrefs

GravitationPrefs_FILES = $(wildcard *.m)
GravitationPrefs_FRAMEWORKS = UIKit CoreGraphics QuartzCore CoreMotion
GravitationPrefs_PRIVATE_FRAMEWORKS = Preferences
GravitationPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function
GravitationPrefs_INSTALL_PATH = /Library/PreferenceBundles

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/GravitationPrefs.plist$(ECHO_END)
	$(ECHO_NOTHING)cp Resources/icon.png $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/GravitationPrefs.png$(ECHO_END)
