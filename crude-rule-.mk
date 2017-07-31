ifndef CRUDE_RULE_
CRUDE_RULE_ := 1
endif

ifeq ($(LOCAL_TARGET),)

ifeq ($(LOCAL_SUBTARGETS),)
    LOCAL_TARGET := $(LOCAL_INTERMEDIATE)
else
    LOCAL_TARGET := $(LOCAL_INTERMEDIATE)/done
endif

$(LOCAL_TARGET): PRIVATE_MODULE := $(LOCAL_MODULE)
$(LOCAL_TARGET):
	@mkdir -p $(dir $@) && echo '[1;35m$(PRIVATE_MODULE) [0;35m$@[0m'
	$(CRUDE_AT)touch $@

endif
