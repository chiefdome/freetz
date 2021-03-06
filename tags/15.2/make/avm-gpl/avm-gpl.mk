ifeq ($(AVM_VERSION),04.30)
AVM_SOURCE_PREFIX:=7141
endif

AVM_SOURCE:=fritzbox$(AVM_SOURCE_PREFIX)-source-files-$(AVM_VERSION).tar.bz2
AVM_SITE:=ftp://ftp.avm.de/develper/opensrc

ifeq ($(AVM_VERSION),r4884)
AVM_SOURCE:=GPL-r4884-8mb_26-tar.bz2
AVM_SITE:=http://www.t-home.de/dlp/eki/downloads/Speedport/Speedport%20W%20701%20V
endif

ifeq ($(AVM_VERSION),r7203)
AVM_SOURCE:=GPL-r7203-4mb_26-tar.bz2
AVM_SITE:=http://www.t-home.de/dlp/eki/downloads/Speedport/Speedport_W501V
endif

AVM_DIR:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)

$(DL_DIR)/$(AVM_SOURCE): | $(DL_DIR)
	wget --passive-ftp -P $(DL_DIR) $(AVM_SITE)/$(AVM_SOURCE)

$(AVM_DIR)/.unpacked: $(DL_DIR)/$(AVM_SOURCE)
	mkdir -p $(AVM_DIR)
	tar -C $(AVM_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(AVM_SOURCE)
	touch $@

avm-gpl-precompiled: $(AVM_DIR)/.unpacked 

avm-gpl-source: $(AVM_DIR)/.unpacked

avm-gpl-clean:

avm-gpl-dirclean:
	rm -rf $(AVM_DIR)
