MKLIBS_VERSION:=0.1.30
MKLIBS_SOURCE:=mklibs_$(MKLIBS_VERSION).tar.gz
MKLIBS_SOURCE_MD5:=15d20c45f786126e31aa3ac06fc08da5
MKLIBS_SITE:=http://ftp.de.debian.org/debian/pool/main/m/mklibs
MKLIBS_DIR:=$(TOOLS_SOURCE_DIR)/mklibs
MKLIBS_MAKE_DIR:=$(TOOLS_DIR)/make
MKLIBS_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build/bin
MKLIBS_SCRIPT:=$(MKLIBS_DIR)/src/mklibs
MKLIBS_TARGET_SCRIPT:=$(MKLIBS_DESTDIR)/mklibs
MKLIBS_READELF_BINARY:=$(MKLIBS_DIR)/src/mklibs-readelf
MKLIBS_READELF_TARGET_BINARY:=$(MKLIBS_DESTDIR)/mklibs-readelf

$(DL_DIR)/$(MKLIBS_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(TOOLS_DOT_CONFIG) $(MKLIBS_SOURCE) $(MKLIBS_SITE) $(MKLIBS_SOURCE_MD5)

mklibs-source: $(DL_DIR)/$(MKLIBS_SOURCE)

$(MKLIBS_DIR)/.unpacked: $(DL_DIR)/$(MKLIBS_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(MKLIBS_SOURCE)
	for i in $(MKLIBS_MAKE_DIR)/patches/*.mklibs.patch; do \
		$(PATCH_TOOL) $(MKLIBS_DIR) $$i; \
	done
	touch $@

$(MKLIBS_DIR)/.configured: $(MKLIBS_DIR)/.unpacked
	(cd $(MKLIBS_DIR); rm -rf config.cache; \
		./configure \
		--prefix=/ \
		$(DISABLE_NLS) \
	);
	touch $(MKLIBS_DIR)/.configured

$(MKLIBS_SCRIPT) $(MKLIBS_SCRIPT)-copy $(MKLIBS_READELF_BINARY): $(MKLIBS_DIR)/.configured
	$(MAKE) -C $(MKLIBS_DIR) all

$(MKLIBS_TARGET_SCRIPT): $(MKLIBS_SCRIPT)
	mkdir -p $(dir $@)
	cp $^ $@

$(MKLIBS_TARGET_SCRIPT)-copy: $(MKLIBS_SCRIPT)-copy
	mkdir -p $(dir $@)
	cp $^ $@

$(MKLIBS_TARGET_READELF_BINARY): $(MKLIBS_READELF_BINARY)
	mkdir -p $(dir $@)
	cp $^ $@

mklibs: $(MKLIBS_TARGET_SCRIPT) $(MKLIBS_TARGET_SCRIPT)-copy $(MKLIBS_READELF_TARGET_BINARY)

mklibs-clean:
	$(MAKE) -C $(MKLIBS_DIR) clean

mklibs-dirclean:
	$(RM) -r $(MKLIBS_DIR)

mklibs-distclean:
	$(RM) -r $(MKLIBS_DESTDIR)
