PYTHON_HOST_VERSION:=2.7.3
PYTHON_HOST_SOURCE:=Python-$(PYTHON_HOST_VERSION).tar.bz2
PYTHON_HOST_MD5:=c57477edd6d18bd9eeca2f21add73919
PYTHON_HOST_SITE:=http://www.python.org/ftp/python/$(PYTHON_HOST_VERSION)

PYTHON_HOST_DIR:=$(TOOLS_SOURCE_DIR)/Python-$(PYTHON_HOST_VERSION)
PYTHON_HOST_BINARY:=$(PYTHON_HOST_DIR)/python
PYTHON_HOST_TARGET_BINARY:=$(HOST_TOOLS_DIR)/usr/bin/python2.7

# used in other python-* makefiles
INVOKE_HOST_PYTHON := PYTHONHOME="$(HOST_TOOLS_DIR)/usr" $(PYTHON_HOST_TARGET_BINARY)

python-host-source: $(DL_DIR)/$(PYTHON_HOST_SOURCE)
$(DL_DIR)/$(PYTHON_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(PYTHON_HOST_SOURCE) $(PYTHON_HOST_SITE) $(PYTHON_HOST_MD5)

python-host-unpacked: $(PYTHON_HOST_DIR)/.unpacked
$(PYTHON_HOST_DIR)/.unpacked: $(DL_DIR)/$(PYTHON_HOST_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(PYTHON_HOST_SOURCE)
	@touch $@

# python quirk:
#  CFLAGS and OPT flags passed here are then used while cross-compiling -> use some target neutral flags
python-host-configured: $(PYTHON_HOST_DIR)/.configured
$(PYTHON_HOST_DIR)/.configured: $(PYTHON_HOST_DIR)/.unpacked
	(cd $(PYTHON_HOST_DIR); $(RM) config.cache; \
		CC=$(TOOLS_CC) \
		CFLAGS="-Os" \
		OPT="-fno-inline" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(GNU_HOST_NAME) \
		--prefix=/usr \
	);
	@touch $@

$(PYTHON_HOST_BINARY): $(PYTHON_HOST_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(PYTHON_HOST_DIR) \
		all Parser/pgen
	@touch -c $@

$(PYTHON_HOST_TARGET_BINARY): $(PYTHON_HOST_BINARY) | $(HOST_TOOLS_DIR)
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(PYTHON_HOST_DIR) \
		DESTDIR="$(HOST_TOOLS_DIR)" \
		install
	cp -a $(PYTHON_HOST_BINARY) $(PYTHON_HOST_DIR)/Parser/pgen \
		$(HOST_TOOLS_DIR)/usr/bin

python-host: $(PYTHON_HOST_TARGET_BINARY)

python-host-clean:
	-$(MAKE) -C $(PYTHON_HOST_DIR) clean

python-host-dirclean:
	$(RM) -r \
		$(PYTHON_HOST_DIR) \
		$(PYTHON_HOST_TARGET_BINARY) \
		$(HOST_TOOLS_DIR)/usr/bin/2to3 \
		$(HOST_TOOLS_DIR)/usr/bin/easy_install* \
		$(HOST_TOOLS_DIR)/usr/bin/idle \
		$(HOST_TOOLS_DIR)/usr/bin/pgen \
		$(HOST_TOOLS_DIR)/usr/bin/pydoc \
		$(HOST_TOOLS_DIR)/usr/bin/python* \
		$(HOST_TOOLS_DIR)/usr/bin/smtpd.py \
		$(HOST_TOOLS_DIR)/usr/include/python2.7 \
		$(HOST_TOOLS_DIR)/usr/lib/libpython2.7.* \
		$(HOST_TOOLS_DIR)/usr/lib/python2.7 \
		$(HOST_TOOLS_DIR)/usr/lib/pkgconfig/python* \
		$(HOST_TOOLS_DIR)/usr/share/python2.7 \
		$(HOST_TOOLS_DIR)/usr/share/man/man1/python2.7.1

.PHONY: python-host-source python-host-unpacked python-host-configured python-host python-host-clean python-host-dirclean
