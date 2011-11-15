$(call PKG_INIT_BIN, 1.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=11b9f47f9051e25bdfe84a365c961ec1
$(PKG)_SITE:=@SF/$(pkg)
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_DEPENDS_ON := iptables

$(PKG)_CONFIGURE_OPTIONS += --with-firewall=iptables
$(PKG)_CONFIGURE_OPTIONS += --with-iptables=/usr/sbin/iptables
$(PKG)_CONFIGURE_OPTIONS += --with-hostsfile=/etc/hosts.allow

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(SSHGUARD_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SSHGUARD_DIR) clean
	$(RM) $(SSHGUARD_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SSHGUARD_BINARIES_TARGET_DIR)

$(PKG_FINISH)
