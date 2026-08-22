# SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=rtl826x-firmware
PKG_SOURCE_DATE:=2026-05-28
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/balika011/realtek_phy_firmware
PKG_SOURCE_VERSION:=8438a3c1e032767add9067f47a736af575911b50
PKG_SOURCE_PROTO:=git
PKG_MIRROR_HASH:=9cf7e01ddb334c05ca483f1da832a173a49c79d14d14f8dcf0d04ee69c83fba2

PKG_MAINTAINER:=Balázs Triszka <info@balika011.hu>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	(set -e; cd $(PKG_BUILD_DIR); \
		$(HOSTCC) rtl8261n_rtl8264b.c phy_patch.c -o phy_patch; \
		./phy_patch \
	)
endef

define Package/rtl826x-firmware/Default
  SECTION:=firmware
  CATEGORY:=Firmware
  DEPENDS:=+kmod-phy-realtek
  PKGARCH:=all
endef

define Package/rtl826x-firmware
  $(call Package/rtl826x-firmware/Default)
  TITLE:=Realtek RTL8251L/RTL8261BE/RTL8261N/RTL8254B/RTL8264/RTL8264B firmware
endef

define Package/rtl826x-lp-firmware
  $(call Package/rtl826x-firmware/Default)
  TITLE:=Realtek RTL8251L/RTL8261BE/RTL8261N/RTL8254B/RTL8264/RTL8264B low-power firmware
  PROVIDES:=rtl826x-firmware
  CONFLICTS:=rtl826x-firmware
endef

define Package/rtl826x-firmware/install
	$(INSTALL_DIR) $(1)/lib/firmware
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/rtl8261n.bin \
		$(PKG_BUILD_DIR)/rtl8264b.bin \
		$(1)/lib/firmware/
endef

define Package/rtl826x-lp-firmware/install
	$(INSTALL_DIR) $(1)/lib/firmware
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/rtl8261n_lp.bin \
		$(1)/lib/firmware/rtl8261n.bin
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/rtl8264b.bin \
		$(1)/lib/firmware/
endef

$(eval $(call BuildPackage,rtl826x-firmware))
$(eval $(call BuildPackage,rtl826x-lp-firmware))
