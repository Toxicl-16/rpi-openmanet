include $(TOPDIR)/rules.mk

PKG_NAME:=iwfcam-rtsp
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Bedz01/iwfcam-rtsp
PKG_SOURCE_VERSION:=5fd29cbef24c8f834542bc0afb3f44ec0f4e4243
PKG_HASH:=skip

PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=OpenMANET / Leland Green

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=iwfcam
GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/iwfcam-rtsp
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=IWFCam H.264 to RTSP bridge
  URL:=https://github.com/Bedz01/iwfcam-rtsp
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/iwfcam-rtsp/description
  Headless RTSP bridge for IWFCam-compatible cameras. The OpenMANET build
  carries a small H.264 Annex-B adaptation for the camera firmware used in
  the field and waits for the configured camera MAC before starting.
endef

define Package/iwfcam-rtsp/conffiles
/etc/config/iwfcam
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	rm -f $(PKG_BUILD_DIR)/testrtsp.go
endef

define Package/iwfcam-rtsp/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d $(1)/usr/sbin
	$(INSTALL_CONF) ./files/iwfcam.config $(1)/etc/config/iwfcam
	$(INSTALL_BIN) ./files/iwfcam.init $(1)/etc/init.d/iwfcam
	$(INSTALL_BIN) ./files/iwfcam-wait $(1)/usr/sbin/iwfcam-wait
	$(INSTALL_DIR) $(1)/usr/share/doc/iwfcam-rtsp $(1)/usr/share/licenses/iwfcam-rtsp
	$(INSTALL_DATA) ./files/README.IWFCam $(1)/usr/share/doc/iwfcam-rtsp/README.IWFCam
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/share/licenses/iwfcam-rtsp/LICENSE
endef

$(eval $(call GoBinPackage,iwfcam-rtsp))
$(eval $(call BuildPackage,iwfcam-rtsp))
