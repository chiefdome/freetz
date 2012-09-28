$(call PKG_INIT_LIB, 1.3.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=71b649d3e08e63ece16649df906ce8b9
$(PKG)_SITE:=http://downloads.xiph.org/releases/vorbis

$(PKG)_LIBVERSIONS      := 0.4.6 2.0.9 3.3.5
$(PKG)_LIBNAMES_SHORT   := vorbis vorbisenc vorbisfile
$(PKG)_LIBNAMES_LONG    := $(join $($(PKG)_LIBNAMES_SHORT:%=lib%.so.),$($(PKG)_LIBVERSIONS))
$(PKG)_LIBS_BUILD_DIR   := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DIR)/lib/.libs/%)
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR  := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)

$(PKG)_DEPENDS_ON := libogg

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

# remove 5.1 encoding capabilities, see also 200-remove51.libvorbis.patch
# makes libvorbisenc almost twice as small as with 5.1 features included
$(PKG)_CONFIGURE_PRE_CMDS += $(RM) lib/books/coupled/*51.h lib/modes/*44p51.h;

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --with-ogg-libraries="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"
$(PKG)_CONFIGURE_OPTIONS += --with-ogg-includes="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBVORBIS_DIR) all

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(LIBVORBIS_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(LIBVORBIS_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%.la) \
		$(LIBVORBIS_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBVORBIS_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libvorbis* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/vorbis* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/vorbis* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/vorvis*

$(pkg)-uninstall:
	$(RM) $(LIBVORBIS_TARGET_DIR)/libvorbis*.so*

$(PKG_FINISH)
