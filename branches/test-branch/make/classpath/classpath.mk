$(call PKG_INIT_BIN, 0.97.2)
$(PKG)_UGLY_VERSION:=0.0.0
$(PKG)_SOURCE:=classpath-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.gnu.org/gnu/classpath
$(PKG)_BINARY:=$($(PKG)_DIR)/lib/mini.jar
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/share/classpath/mini.jar
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/native/jni/java-lang/.libs/libjavalang.so.$($(PKG)_UGLY_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavalang.so.$($(PKG)_UGLY_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/classpath/libjavalang.so.$($(PKG)_UGLY_VERSION)
$(PKG)_SOURCE_MD5:=6a35347901ace03c31cc49751b338f31 

$(PKG)_DEPENDS_ON := libiconv

$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-peer
$(PKG)_CONFIGURE_OPTIONS += --disable-qt-peer
$(PKG)_CONFIGURE_OPTIONS += --disable-gconf-peer
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --disable-plugin       
$(PKG)_CONFIGURE_OPTIONS += --with-ecj               
$(PKG)_CONFIGURE_OPTIONS += --disable-Werror


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CLASSPATH_DIR)
	cp $(CLASSPATH_MAKE_DIR)/mini.classlist $(CLASSPATH_DIR)/lib;
	( cd $(CLASSPATH_DIR)/lib; fastjar -Mcf mini.jar -@ < mini.classlist );

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	cp $(CLASSPATH_BINARY) $(CLASSPATH_TARGET_BINARY)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(CLASSPATH_DIR)/native/jni \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavaio.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavalang.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavalangmanagement.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavalangreflect.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavanet.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavanio.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavautil.la
	touch $@

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjava*.so* $(CLASSPATH_DEST_DIR)/usr/lib/classpath/
	$(TARGET_STRIP) $(CLASSPATH_DEST_DIR)/usr/lib/classpath/libjava*.so*
	touch $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CLASSPATH_DIR) clean

$(pkg)-uninstall:
	$(RM) $(CLASSPATH_TARGET_BINARY)
	$(RM) root/usr/lib/libjava*.so*
	$(RM) $(CLASSPATH_DIR)/.installed

$(PKG_FINISH)