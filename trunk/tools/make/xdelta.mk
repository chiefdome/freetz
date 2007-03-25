XDELTA_VERSION:=30q
XDELTA_SOURCE:=xdelta$(XDELTA_VERSION).tar.gz
XDELTA_SITE:=http://xdelta.googlecode.com/files
XDELTA_DIR:=$(SOURCE_DIR)/xdelta$(XDELTA_VERSION)
XDELTA_MAKE_DIR:=$(TOOLS_DIR)/make
XDELTA_DESTDIR:=$(shell pwd)/$(TOOLS_DIR)


$(DL_DIR)/$(XDELTA_SOURCE):
	 wget -P $(DL_DIR) $(XDELTA_SITE)/$(XDELTA_SOURCE)

xdelta-source: $(DL_DIR)/$(XDELTA_SOURCE)

$(XDELTA_DIR)/.unpacked: $(DL_DIR)/$(XDELTA_SOURCE)
	@rm -rf $(XDELTA_DIR) && mkdir -p $(XDELTA_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(XDELTA_SOURCE)
	touch $@

$(XDELTA_DIR)/xdelta3: $(XDELTA_DIR)/.unpacked
	$(MAKE) CC="$(TOOLS_CC)" -C $(XDELTA_DIR) xdelta3

$(TOOLS_DIR)/xdelta3: $(XDELTA_DIR)/xdelta3
	cp $(XDELTA_DIR)/xdelta3 $(TOOLS_DIR)/xdelta3

xdelta: $(TOOLS_DIR)/xdelta3

xdelta-clean:
	$(MAKE) -C $(XDELTA_DIR) clean

xdelta-dirclean:
	rm -rf $(XDELTA_DIR)

xdelta-distclean:
	rm -rf $(TOOLS_DIR)/xdelta

