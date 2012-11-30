SSTRIP_VERSION:=1.0
SSTRIP_SOURCE:=sstrip-$(SSTRIP_VERSION).tar.bz2
SSTRIP_DIR:=$(TOOLS_SOURCE_DIR)/sstrip-$(SSTRIP_VERSION)

$(SSTRIP_DIR)/.unpacked: $(TOOLS_DIR)/source/$(SSTRIP_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(TOOLS_DIR)/source/$(SSTRIP_SOURCE)
	touch $@

$(SSTRIP_DIR)/sstrip: $(SSTRIP_DIR)/.unpacked
	$(MAKE) -C $(SSTRIP_DIR) \
		CC="$(TOOLS_CC)" \
		CFLAGS="-Wall -O2" \
		all

$(TOOLS_DIR)/sstrip: $(SSTRIP_DIR)/sstrip
	cp $(SSTRIP_DIR)/sstrip $(TOOLS_DIR)/sstrip

host-sstrip: $(TOOLS_DIR)/sstrip

host-sstrip-source: $(SSTRIP_DIR)/.unpacked

host-sstrip-clean:
	-$(MAKE) -C $(SSTRIP_DIR) clean

host-sstrip-dirclean:
	$(RM) -r $(SSTRIP_DIR)

host-sstrip-distclean: host-sstrip-dirclean
	$(RM) $(TOOLS_DIR)/sstrip
