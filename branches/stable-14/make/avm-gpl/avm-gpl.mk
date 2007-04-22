ifeq ($(AVM_VERSION),04.30)
AVM_SOURCE_PREFIX:=7141
endif

AVM_SOURCE:=fritzbox$(AVM_SOURCE_PREFIX)-source-files-$(AVM_VERSION).tar.$(AVM_SOURCE_SUFFIX)
AVM_SITE:=ftp://ftp.avm.de/develper/opensrc
AVM_DIR:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)

$(DL_DIR)/$(AVM_SOURCE):
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
