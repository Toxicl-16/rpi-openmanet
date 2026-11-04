include $(TOPDIR)/rules.mk

PKG_NAME:=openmanet-batman-fix
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-only
PKG_MAINTAINER:=OpenMANET / Build with Parallel integration

include $(INCLUDE_DIR)/package.mk

define Package/openmanet-batman-fix
  SECTION:=net
  CATEGORY:=Network
  TITLE:=OpenMANET BATMAN-V topology repair
  DEPENDS:=+kmod-batman-adv +batctl
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
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/rc.d $(1)/usr/sbin
	$(INSTALL_BIN) ./files/etc/init.d/openmanet-batman $(1)/etc/init.d/openmanet-batman
	$(INSTALL_BIN) ./files/usr/sbin/openmanet-batman $(1)/usr/sbin/openmanet-batman
	$(LN) ../init.d/openmanet-batman $(1)/etc/rc.d/S12openmanet-batman
endef

$(eval $(call BuildPackage,openmanet-batman-fix))
