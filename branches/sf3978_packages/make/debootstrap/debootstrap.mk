$(call PKG_INIT_BIN, 1.0.28)
#
# The only binary needed for debootstrap is 'pkgdetails'. In newer debian revisions
# is has moved from package 'debootstrap' to 'base_installer'. So we use an own
# version of debootstrap sources to build this binary.
# All other files are extracted from the current debootstrap source, at the time of
# writing this comment this is version 1.0.28
#
#$(PKG)_SOURCE:=debootstrap_$(DEBOOTSTRAP_VERSION).tar.gz
#$(PKG)_SITE:=http://ftp.de.debian.org/debian/pool/main/d/debootstrap
#$(PKG)_SOURCE_MD5:=f8172809afe7cfdcdc6745229f024d9d

$(PKG)_BINARY:=$($(PKG)_DIR)/pkgdetails
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/debootstrap/pkgdetails

$(PKG_LOCALSOURCE_PACKAGE)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DEBOOTSTRAP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DEBOOTSTRAP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DEBOOTSTRAP_TARGET_BINARY)

$(PKG_FINISH)
