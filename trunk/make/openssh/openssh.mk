$(call PKG_INIT_BIN, 5.5p1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=88633408f4cb1eb11ec7e2ec58b519eb
$(PKG)_SITE:=ftp://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable

# Binaries used:

# Selection "Client" (ssh and scp)
#
# ssh
$(PKG)_CLIENT_SSH_BINARY:=$($(PKG)_DIR)/ssh
$(PKG)_CLIENT_SSH_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ssh
# scp
$(PKG)_CLIENT_SCP_BINARY:=$($(PKG)_DIR)/scp
$(PKG)_CLIENT_SCP_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/scp

# Selection "Clientutils " (ssh-add and ssh-agent)
# ssh-add
$(PKG)_CLIENTUTILS_SSHADD_BINARY:=$($(PKG)_DIR)/ssh-add
$(PKG)_CLIENTUTILS_SSHADD_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ssh-add
# ssh-agent
$(PKG)_CLIENTUTILS_SSHAGENT_BINARY:=$($(PKG)_DIR)/ssh-agent
$(PKG)_CLIENTUTILS_SSHAGENT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ssh-agent

# Selection "Keyutils" (ssh-keygen, ssh-keysign, ssh-keyscan and ssh-rand-helper)
# ssh-keygen
$(PKG)_KEYUTILS_SSHKEYGEN_BINARY:=$($(PKG)_DIR)/ssh-keygen
$(PKG)_KEYUTILS_SSHKEYGEN_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ssh-keygen
# ssh-keysign
$(PKG)_KEYUTILS_SSHKEYSIGN_BINARY:=$($(PKG)_DIR)/ssh-keysign
$(PKG)_KEYUTILS_SSHKEYSIGN_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ssh-keysign
# ssh-keygen
$(PKG)_KEYUTILS_SSHKEYSCAN_BINARY:=$($(PKG)_DIR)/ssh-keyscan
$(PKG)_KEYUTILS_SSHKEYSCAN_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ssh-keyscan
# ssh-rand-helper
$(PKG)_KEYUTILS_SSHRANDHELP_BINARY:=$($(PKG)_DIR)/ssh-rand-helper
$(PKG)_KEYUTILS_SSHRANDHELP_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ssh-rand-helper

# Selection "SSH-Server"
#
$(PKG)_SSHSERVER_BINARY:=$($(PKG)_DIR)/sshd
$(PKG)_SSHSERVER_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/sshd

# Selection "sftp-Server"
#
$(PKG)_SFTP_BINARY:=$($(PKG)_DIR)/sftp-server
$(PKG)_SFTP_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/sftp-server

# Selection "sftp Client"
#
$(PKG)_SFTPCLIENT_BINARY:=$($(PKG)_DIR)/sftp
$(PKG)_SFTPCLIENT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sftp

$(PKG)_DEPENDS_ON := openssl zlib

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENSSH_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENSSH_CLIENT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENSSH_SCP
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENSSH_CLIENTUTILS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENSSH_KEYUTILS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENSSH_SFTP
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENSSH_SFTPCLIENT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENSSH_SSHD

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENSSH_STATIC),--disable-shared,--enable-shared)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENSSH_STATIC),--enable-static,--disable-static)
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-etc-default-login
$(PKG)_CONFIGURE_OPTIONS += --disable-lastlog
$(PKG)_CONFIGURE_OPTIONS += --disable-utmp
$(PKG)_CONFIGURE_OPTIONS += --disable-utmpx
$(PKG)_CONFIGURE_OPTIONS += --disable-wtmp
$(PKG)_CONFIGURE_OPTIONS += --disable-wtmpx
$(PKG)_CONFIGURE_OPTIONS += --without-bsd-auth
$(PKG)_CONFIGURE_OPTIONS += --without-kerberos5

$(PKG)_LDFLAGS := $(echo $(LDFLAGS)) -L. -Lopenbsd-compat/
$(PKG)_LIBS := -lcrypto -lutil -lz -lcrypt -lresolv

ifeq ($(strip $(FREETZ_PACKAGE_OPENSSH_STATIC)),y)
$(PKG)_LDFLAGS += -static -all-static
$(PKG)_LIBS += -ldl
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(pkg)-uninstall)

$(OPENSSH_CLIENT_SSH_BINARY) \
	$(OPENSSH_CLIENT_SCP_BINARY) \
	$(OPENSSH_CLIENTUTILS_SSHADD_BINARY) \
	$(OPENSSH_CLIENTUTILS_SSHAGENT_BINARY) \
	$(OPENSSH_KEYUTILS_SSHKEYGEN_BINARY) \
	$(OPENSSH_KEYUTILS_SSHKEYSIGN_BINARY) \
	$(OPENSSH_KEYUTILS_SSHKEYSCAN_BINARY) \
	$(OPENSSH_KEYUTILS_SSHRANDHELP_BINARY) \
	$(OPENSSH_SSHSERVER_BINARY) \
	$(OPENSSH_SFTP_BINARY) \
	$(OPENSSH_SFTPCLIENT_BINARY) : $(OPENSSH_DIR)/.configured
	$(SUBMAKE) -C $(OPENSSH_DIR) LDFLAGS="$(OPENSSH_LDFLAGS)" LIBS="$(OPENSSH_LIBS)" \
		all

# Client binaries (ssh and scp)
$(OPENSSH_CLIENT_SSH_TARGET_BINARY): $(OPENSSH_CLIENT_SSH_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_OPENSSH_CLIENT)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $(OPENSSH_CLIENT_SSH_TARGET_BINARY)
endif
$(OPENSSH_CLIENT_SCP_TARGET_BINARY): $(OPENSSH_CLIENT_SCP_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_OPENSSH_SCP)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $(OPENSSH_CLIENT_SCP_TARGET_BINARY)
endif

# SSH util binaries
$(OPENSSH_CLIENTUTILS_SSHADD_TARGET_BINARY): $(OPENSSH_CLIENTUTILS_SSHADD_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_OPENSSH_CLIENTUTILS)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $(OPENSSH_CLIENTUTILS_SSHADD_TARGET_BINARY)
endif
$(OPENSSH_CLIENTUTILS_SSHAGENT_TARGET_BINARY): $(OPENSSH_CLIENTUTILS_SSHAGENT_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_OPENSSH_CLIENTUTILS)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $(OPENSSH_CLIENTUTILS_SSHAGENT_TARGET_BINARY)
endif

# SSH keyutil binaries
$(OPENSSH_KEYUTILS_SSHKEYGEN_TARGET_BINARY): $(OPENSSH_KEYUTILS_SSHKEYGEN_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_OPENSSH_KEYUTILS)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $(OPENSSH_KEYUTILS_SSHKEYGEN_TARGET_BINARY)
endif
$(OPENSSH_KEYUTILS_SSHKEYSIGN_TARGET_BINARY): $(OPENSSH_KEYUTILS_SSHKEYSIGN_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_OPENSSH_KEYUTILS)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $(OPENSSH_KEYUTILS_SSHKEYSIGN_TARGET_BINARY)
endif
$(OPENSSH_KEYUTILS_SSHKEYSCAN_TARGET_BINARY): $(OPENSSH_KEYUTILS_SSHKEYSCAN_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_OPENSSH_KEYUTILS)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $(OPENSSH_KEYUTILS_SSHKEYSCAN_TARGET_BINARY)
endif
$(OPENSSH_KEYUTILS_SSHRANDHELP_TARGET_BINARY): $(OPENSSH_KEYUTILS_SSHRANDHELP_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_OPENSSH_KEYUTILS)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $(OPENSSH_KEYUTILS_SSHRANDHELP_TARGET_BINARY)
endif

# SSH-Server uses "GUI", so install or delete it with binary
$(OPENSSH_SSHSERVER_TARGET_BINARY): $(OPENSSH_SSHSERVER_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_OPENSSH_SSHD)),y)
	$(INSTALL_BINARY_STRIP)
	tar -c -C $(OPENSSH_MAKE_DIR)/files --exclude=.svn . | tar -x -C $(OPENSSH_TARGET_DIR)
else
	$(RM) $(OPENSSH_SSHSERVER_TARGET_BINARY)
	$(RM) -rf $(OPENSSH_DEST_DIR)/etc
	$(RM) -rf $(OPENSSH_DEST_DIR)/usr/lib/cgi-bin
endif

# SFTP server
$(OPENSSH_SFTP_TARGET_BINARY): $(OPENSSH_SFTP_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_OPENSSH_SFTP)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $(OPENSSH_SFTP_TARGET_BINARY)
endif

# SFTP client
$(OPENSSH_SFTPCLIENT_TARGET_BINARY): $(OPENSSH_SFTPCLIENT_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_OPENSSH_SFTPCLIENT)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $(OPENSSH_SFTPCLIENT_TARGET_BINARY)
endif

$(pkg):

$(pkg)-precompiled: $(OPENSSH_CLIENT_SSH_TARGET_BINARY) \
	$(OPENSSH_CLIENT_SCP_TARGET_BINARY) \
	$(OPENSSH_CLIENTUTILS_SSHADD_TARGET_BINARY) \
	$(OPENSSH_CLIENTUTILS_SSHAGENT_TARGET_BINARY) \
	$(OPENSSH_KEYUTILS_SSHKEYGEN_TARGET_BINARY) \
	$(OPENSSH_KEYUTILS_SSHKEYSIGN_TARGET_BINARY) \
	$(OPENSSH_KEYUTILS_SSHKEYSCAN_TARGET_BINARY) \
	$(OPENSSH_KEYUTILS_SSHRANDHELP_TARGET_BINARY) \
	$(OPENSSH_SSHSERVER_TARGET_BINARY) \
	$(OPENSSH_SFTP_TARGET_BINARY) \
	$(OPENSSH_SFTPCLIENT_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENSSH_DIR) clean

$(pkg)-uninstall:
	$(RM) $(OPENSSH_CLIENT_SSH_TARGET_BINARY) \
	$(OPENSSH_CLIENT_SCP_TARGET_BINARY) \
	$(OPENSSH_CLIENTUTILS_SSHADD_TARGET_BINARY) \
	$(OPENSSH_CLIENTUTILS_SSHAGENT_TARGET_BINARY) \
	$(OPENSSH_KEYUTILS_SSHKEYGEN_TARGET_BINARY) \
	$(OPENSSH_KEYUTILS_SSHKEYSIGN_TARGET_BINARY) \
	$(OPENSSH_KEYUTILS_SSHKEYSCAN_TARGET_BINARY) \
	$(OPENSSH_KEYUTILS_SSHRANDHELP_TARGET_BINARY) \
	$(OPENSSH_CLIENT_SSHSERVER_TARGET_BINARY) \
	$(OPENSSH_SFTP_TARGET_BINARY) \
	$(OPENSSH_SFTPCLIENT_TARGET_BINARY)

$(PKG_FINISH)
