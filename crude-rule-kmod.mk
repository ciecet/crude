ifndef CRUDE_RULE_KMOD
CRUDE_RULE_KMOD := 1
endif

ifeq ($(LOCAL_TARGET),)
    LOCAL_TARGET := $(CRUDE_OUT)/kmod/$(LOCAL_MODULE).ko
endif

LOCAL_SRCS := $(shell find $(LOCAL_M) -type f)
LOCAL_COPIES := $(patsubst $(LOCAL_M)/%, $(LOCAL_INTERMEDIATE)/%, $(LOCAL_SRCS))
$(LOCAL_INTERMEDIATE)/%: $(LOCAL_M)/%
	@mkdir -p $(dir $@)
	$(CRUDE_AT)cp $< $@

$(LOCAL_TARGET): PRIVATE_M := $(LOCAL_INTERMEDIATE)
$(LOCAL_TARGET): PRIVATE_DEFINES := $(LOCAL_DEFINES)
$(LOCAL_TARGET): PRIVATE_KMOD := $(CRUDE_OUT)/intermediate/$(LOCAL_MODULE)-kmod/$(LOCAL_MODULE).ko
$(LOCAL_TARGET): $(LOCAL_COPIES)
	@mkdir -p $(dir $@) && echo '[1;33mKMOD [0;33m$@[0m'
	$(CRUDE_AT)$(MAKE) -C $(LINUX) M=$(shell cd $(PRIVATE_M); pwd) CROSS_COMPILE=$(ACBUILD_TOOLCHAIN_BIN_DIR)/$(ACBUILD_TOOLCHAIN_PREFIX) $(PRIVATE_DEFINES) modules
	$(CRUDE_AT)cp $(PRIVATE_KMOD) $@
