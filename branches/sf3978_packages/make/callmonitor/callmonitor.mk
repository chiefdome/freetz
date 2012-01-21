$(call PKG_INIT_BIN, 1.19.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-freetz.tar.bz2
$(PKG)_SOURCE_MD5:=7469041228d8a4899174459b86c6fac6
$(PKG)_SITE:=@SF/callmonitor
$(PKG)_STARTLEVEL=71
$(PKG)_BINARY:=$($(PKG)_DIR)/src/recode
$(PKG)_TARGET_BINARY:=$($(PKG)_DIR)/root/usr/lib/callmonitor/bin/recode

$(PKG)_SUBOPTS := webif actions monitor phonebook
$(PKG)_REBUILD_SUBOPTS += $(foreach subopt,$($(PKG)_SUBOPTS),FREETZ_PACKAGE_CALLMONITOR_$(subopt))
$(PKG)_FEATURES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_SUBOPTS))

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	@echo $(CALLMONITOR_FEATURES) > $(CALLMONITOR_DIR)/.features
	$(SUBMAKE) -C $(CALLMONITOR_DIR) configure
	@touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) $(TARGET_CONFIGURE_ENV) -C $(CALLMONITOR_DIR) build

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
	chmod 755 $@

$(pkg)-clean:
	-$(SUBMAKE) -C $(CALLMONITOR_DIR) clean

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_DIR)/.packaged

$($(PKG)_TARGET_DIR)/.packaged: $($(PKG)_DIR)/.configured $($(PKG)_TARGET_BINARY)
	tar -c -C $(CALLMONITOR_DIR)/root --files-from=$(CALLMONITOR_DIR)/.files | tar -x -C $(CALLMONITOR_DEST_DIR)
	cp $(CALLMONITOR_DIR)/.language $(CALLMONITOR_TARGET_DIR)/
	@touch $@

$(PKG_FINISH)
