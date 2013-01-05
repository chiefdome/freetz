$(call PKG_INIT_BIN, 6.8.1-9)
$(PKG)_SOURCE:=ImageMagick-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=3a85fce351ff38780a60626395756ba9
$(PKG)_SITE:=http://www.$(pkg).org/download

$(PKG)_DIR:=$(SOURCE_DIR)/ImageMagick-$($(PKG)_VERSION)

$(PKG)_BINARIES_ALL := convert mogrify stream montage import identify display conjure compare animate composite
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/utilities/$(if $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC),,.libs/)%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_LIB_CORE := libMagickCore-Q16.so.7.0.0
$(PKG)_LIB_CORE_BUILD_DIR := $($(PKG)_LIB_CORE:%=$($(PKG)_DIR)/magick/.libs/%)
$(PKG)_LIB_CORE_TARGET_DIR := $($(PKG)_LIB_CORE:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_LIB_WAND := libMagickWand-Q16.so.7.0.0
$(PKG)_LIB_WAND_BUILD_DIR := $($(PKG)_LIB_WAND:%=$($(PKG)_DIR)/wand/.libs/%)
$(PKG)_LIB_WAND_TARGET_DIR := $($(PKG)_LIB_WAND:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_XML_CONFIGS := \
	coder.xml colors.xml delegates.xml log.xml magic.xml mime.xml policy.xml \
	thresholds.xml type.xml type-dejavu.xml type-ghostscript.xml type-windows.xml
$(PKG)_XML_CONFIGS_BUILD_DIR := $($(PKG)_XML_CONFIGS:%=$($(PKG)_DIR)/config/%)
$(PKG)_XML_CONFIGS_TARGET_DIR := $($(PKG)_XML_CONFIGS:%=$($(PKG)_DEST_DIR)/etc/ImageMagick/%)

$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))
$(PKG)_NOT_INCLUDED += $(if $(FREETZ_PACKAGE_IMAGEMAGICK_xml),,$($(PKG)_XML_CONFIGS_TARGET_DIR))

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_freetype
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_ghostscript_fonts
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_jpeg
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_libz
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_png
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_xml
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_STATIC

$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_IMAGEMAGICK_freetype),freetype)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_IMAGEMAGICK_ghostscript_fonts),ghostscript-fonts)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_IMAGEMAGICK_jpeg),jpeg)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_IMAGEMAGICK_libz),zlib)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_IMAGEMAGICK_png),libpng)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_IMAGEMAGICK_xml),libxml2)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --with-modules=no
$(PKG)_CONFIGURE_OPTIONS += --enable-hdri=no
$(PKG)_CONFIGURE_OPTIONS += --with-bzlib=no
$(PKG)_CONFIGURE_OPTIONS += --with-autotrace=no
$(PKG)_CONFIGURE_OPTIONS += --with-djvu=no
$(PKG)_CONFIGURE_OPTIONS += --with-dps=no
$(PKG)_CONFIGURE_OPTIONS += --with-fftw=no
$(PKG)_CONFIGURE_OPTIONS += --with-fpx=no
$(PKG)_CONFIGURE_OPTIONS += --with-fontconfig=no
$(PKG)_CONFIGURE_OPTIONS += --with-gs-font-dir=$(GHOSTSCRIPT_FONTS_RUNTIME_DIR)
$(PKG)_CONFIGURE_OPTIONS += --with-gvc=no
$(PKG)_CONFIGURE_OPTIONS += --with-jbig=no
$(PKG)_CONFIGURE_OPTIONS += --with-jp2=no
$(PKG)_CONFIGURE_OPTIONS += --with-lcms=no
$(PKG)_CONFIGURE_OPTIONS += --with-lcms2=no
$(PKG)_CONFIGURE_OPTIONS += --with-lqr=no
$(PKG)_CONFIGURE_OPTIONS += --with-ltdl=no
$(PKG)_CONFIGURE_OPTIONS += --with-lzma=no
$(PKG)_CONFIGURE_OPTIONS += --with-magick-plus-plus=no
$(PKG)_CONFIGURE_OPTIONS += --with-openexr=no
$(PKG)_CONFIGURE_OPTIONS += --with-perl=no
$(PKG)_CONFIGURE_OPTIONS += --with-pango=no
$(PKG)_CONFIGURE_OPTIONS += --with-rsvg=no
$(PKG)_CONFIGURE_OPTIONS += --with-tiff=no
$(PKG)_CONFIGURE_OPTIONS += --with-webp=no
$(PKG)_CONFIGURE_OPTIONS += --with-wmf=no
$(PKG)_CONFIGURE_OPTIONS += --with-x=no

$(PKG)_CONFIGURE_OPTIONS += --enable-static=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --enable-shared=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC),no,yes)

$(PKG)_CONFIGURE_OPTIONS += --with-zlib=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_libz),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --with-jpeg=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_jpeg),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --with-png=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_png),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --with-xml=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_xml),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --with-freetype=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_freetype),yes,no)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $(if $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC),,$($(PKG)_LIB_CORE_BUILD_DIR) $($(PKG)_LIB_WAND_BUILD_DIR)): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(IMAGEMAGICK_DIR)

$($(PKG)_XML_CONFIGS_BUILD_DIR): $($(PKG)_DIR)/config/%: $($(PKG)_DIR)/.configured
	@touch $@

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/utilities/$(if $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC),,.libs/)%
	$(INSTALL_BINARY_STRIP)
$($(PKG)_LIB_CORE_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/magick/.libs/%
	$(INSTALL_LIBRARY_STRIP)
$($(PKG)_LIB_WAND_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/wand/.libs/%
	$(INSTALL_LIBRARY_STRIP)
$($(PKG)_XML_CONFIGS_TARGET_DIR): $($(PKG)_DEST_DIR)/etc/ImageMagick/%: $($(PKG)_DIR)/config/%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: \
	$($(PKG)_BINARIES_TARGET_DIR) \
	$(if $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC),,$($(PKG)_LIB_CORE_TARGET_DIR) $($(PKG)_LIB_WAND_TARGET_DIR)) \
	$(if $(FREETZ_PACKAGE_IMAGEMAGICK_xml),$($(PKG)_XML_CONFIGS_TARGET_DIR))

$(pkg)-clean:
	-$(SUBMAKE) -C $(IMAGEMAGICK_DIR) clean
	$(RM) $(IMAGEMAGICK_DIR)/.configured

$(pkg)-uninstall:
	$(RM) \
		$(IMAGEMAGICK_BINARIES_ALL:%=$(IMAGEMAGICK_DEST_DIR)/usr/bin/%) \
		$(IMAGEMAGICK_LIB_CORE_TARGET_DIR) \
		$(IMAGEMAGICK_LIB_WAND_TARGET_DIR) \
		$(IMAGEMAGICK_XML_CONFIGS_TARGET_DIR)

$(PKG_FINISH)
