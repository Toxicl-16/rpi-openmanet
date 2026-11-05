include $(TOPDIR)/rules.mk

PKG_NAME:=golangtakserver
PKG_VERSION:=1.6.3
PKG_RELEASE:=2
PKG_SOURCE:=golangtakserver-linux-arm64-openmanet-ui1
PKG_SOURCE_URL:=https://github.com/Toxicl-16/rpi-openmanet/releases/download/v0.5.7-native-tak
PKG_HASH:=e4d4bc6dbe47d3c5a90b289271461f15b5210ba50d9ca74f56a77c5110d74541
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=0BSD
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=OpenMANET / Build with Parallel integration

include $(INCLUDE_DIR)/package.mk

define Package/golangtakserver
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GolangTAKServer native TAK service
  DEPENDS:=+ca-bundle
  PKGARCH:=aarch64_cortex-a76
endef

define Package/golangtakserver/description
 Native ARM64 TAK and Cursor-on-Target server for Raspberry Pi 5.
 This experimental OpenMANET package runs GolangTAKServer directly under
 OpenWrt procd without Docker, a database server, or OpenTAKServer.
endef

define Package/golangtakserver/conffiles
/opt/golangtakserver/config.json
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)/golangtakserver
	cp ./files/LICENSE $(PKG_BUILD_DIR)/LICENSE
	chmod 0755 $(PKG_BUILD_DIR)/golangtakserver
endef

define Build/Compile
endef

define Package/golangtakserver/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/usr/bin $(1)/opt/golangtakserver
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/golangtakserver $(1)/usr/bin/golangtakserver
	$(INSTALL_BIN) ./files/golangtakserver.init $(1)/etc/init.d/golangtakserver
	$(INSTALL_CONF) ./files/config.json $(1)/opt/golangtakserver/config.json
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/opt/golangtakserver/LICENSE
	$(INSTALL_DATA) ./files/README.GolangTAKServer $(1)/opt/golangtakserver/README.GolangTAKServer
endef

$(eval $(call BuildPackage,golangtakserver))
