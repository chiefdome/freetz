FIND_SQUASHFS_SOURCE:=find-squashfs.tar.bz2
FIND_SQUASHFS_DIR:=$(TOOLS_SOURCE_DIR)/find-squashfs


$(FIND_SQUASHFS_DIR)/.unpacked: $(TOOLS_DIR)/source/$(FIND_SQUASHFS_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(TOOLS_DIR)/source/$(FIND_SQUASHFS_SOURCE)
	touch $@

$(FIND_SQUASHFS_DIR)/find-squashfs: $(FIND_SQUASHFS_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" LD="$(TOOLS_LD) -static" \
		-C $(FIND_SQUASHFS_DIR)

$(TOOLS_DIR)/find-squashfs: $(FIND_SQUASHFS_DIR)/find-squashfs
	cp $(FIND_SQUASHFS_DIR)/find-squashfs $(TOOLS_DIR)/find-squashfs

find-squashfs: $(TOOLS_DIR)/find-squashfs

find-squashfs-source: $(FIND_SQUASHFS_DIR)/.unpacked

find-squashfs-clean:
	-$(MAKE) -C $(FIND_SQUASHFS_DIR) clean

find-squashfs-dirclean:
	$(RM) -r $(FIND_SQUASHFS_DIR)

find-squashfs-distclean: find-squashfs-dirclean
	$(RM) $(TOOLS_DIR)/find-squashfs
