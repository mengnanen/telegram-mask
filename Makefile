TARGET = iphone:clang:latest:15.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = Telegram

include $(THEOS)/makefiles/common.mk
TWEAK_NAME = Telegrammask
$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
