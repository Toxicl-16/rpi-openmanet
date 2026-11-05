include $(TOPDIR)/rules.mk

PKG_NAME:=openmanet-batman-fix
PKG_RELEASE:=3
PKG_LICENSE:=GPL-2.0-only
PKG_MAINTAINER:=OpenMANET / Build with Parallel integration

include $(INCLUDE_DIR)/package.mk

define Package/openmanet-batman-fix
  SECTION:=net
  CATEGORY:=Network
  TITLE:=OpenMANET BATMAN-V topology repair
  DEPENDS:=+kmod-batman-adv +batctl +rpcd +luci-base
  PKGARCH:=all
endef

define Package/openmanet-batman-fix/description
Keep the OpenMANET 802.11s mesh attached to bat0 using BATMAN-V and place
bat0 on the existing HaLow-side bridge. The repair is idempotent and does
not alter the Ethernet uplink.
endef

define Build/Compile
endef

define Package/openmanet-batman-fix/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface $(1)/etc/init.d $(1)/etc/rc.d $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/libexec/rpcd $(1)/usr/share/rpcd/acl.d $(1)/usr/share/luci/menu.d
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/openmanet
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/99-openmanet-batman $(1)/etc/hotplug.d/iface/99-openmanet-batman
	$(INSTALL_BIN) ./files/etc/init.d/openmanet-batman $(1)/etc/init.d/openmanet-batman
	$(INSTALL_BIN) ./files/usr/sbin/openmanet-batman $(1)/usr/sbin/openmanet-batman
	$(INSTALL_BIN) ./files/usr/libexec/rpcd/openmanet-batman $(1)/usr/libexec/rpcd/openmanet-batman
	$(INSTALL_DATA) ./files/usr/share/rpcd/acl.d/luci-app-openmanet-batman.json $(1)/usr/share/rpcd/acl.d/luci-app-openmanet-batman.json
	$(INSTALL_DATA) ./files/usr/share/luci/menu.d/luci-app-openmanet-batman.json $(1)/usr/share/luci/menu.d/luci-app-openmanet-batman.json
	$(INSTALL_DATA) ./files/www/luci-static/resources/view/openmanet/batman.js $(1)/www/luci-static/resources/view/openmanet/batman.js
	$(LN) ../init.d/openmanet-batman $(1)/etc/rc.d/S99openmanet-batman
endef

$(eval $(call BuildPackage,openmanet-batman-fix))
