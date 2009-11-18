$(call PKG_INIT_BIN, 3.0.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.daniel-baumann.ch/software/dosfstools
$(PKG)_SOURCE_MD5:=d48177cde9c6ce64333133424bf32912

$(PKG)_DOSFSCK_BINARY:=$($(PKG)_DIR)/dosfsck
$(PKG)_DOSFSCK_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/dosfsck
$(PKG)_DOSFSLABEL_BINARY:=$($(PKG)_DIR)/dosfslabel
$(PKG)_DOSFSLABEL_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/dosfslabel
$(PKG)_MKDOSFS_BINARY:=$($(PKG)_DIR)/mkdosfs
$(PKG)_MKDOSFS_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/mkdosfs

DOSFSTOOLS_OPTFLAGS = -O2 -fomit-frame-pointer -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
#DOSFSTOOLS_OPTFLAGS = -O2 -fomit-frame-pointer $(shell getconf LFS_CFLAGS)
#DOSFSTOOLS_WARNFLAGS = -Wall -pedantic -std=c99
DOSFSTOOLS_WARNFLAGS = -Wall
DOSFSTOOLS_DEBUGFLAGS = -g
DOSFSTOOLS_CFLAGS += $(DOSFSTOOLS_OPTFLAGS) $(DOSFSTOOLS_WARNFLAGS) $(DOSFSTOOLS_DEBUGFLAGS)

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_DOSFSTOOLS_DOSFSCK
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_DOSFSTOOLS_DOSFSLABEL
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_DOSFSTOOLS_MKDOSFS

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_DOSFSCK_BINARY) $($(PKG)_DOSFSLABEL_BINARY) $($(PKG)_MKDOSFS_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DOSFSTOOLS_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(DOSFSTOOLS_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) $(DOSFSTOOLS_LDFLAGS)" \
		all

# dosfsck
$($(PKG)_DOSFSCK_TARGET_BINARY): $($(PKG)_DOSFSCK_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_DOSFSTOOLS_DOSFSCK)),y)
	$(INSTALL_BINARY_STRIP)
endif

# dosfslabel
$($(PKG)_DOSFSLABEL_TARGET_BINARY): $($(PKG)_DOSFSLABEL_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_DOSFSTOOLS_DOSFSLABEL)),y)
	$(INSTALL_BINARY_STRIP)
endif

# dosfsck
$($(PKG)_MKDOSFS_TARGET_BINARY): $($(PKG)_MKDOSFS_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_DOSFSTOOLS_MKDOSFS)),y)
	$(INSTALL_BINARY_STRIP)
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_DOSFSCK_TARGET_BINARY) \
			$($(PKG)_DOSFSLABEL_TARGET_BINARY) \
			$($(PKG)_MKDOSFS_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DOSFSTOOLS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DOSFSTOOLS_DOSFSCK_TARGET_BINARY) \
		  $(DOSFSTOOLS_DOSFSLABEL_TARGET_BINARY) \
		  $(DOSFSTOOLS_MKDOSFS_TARGET_BINARY)

$(PKG_FINISH)
