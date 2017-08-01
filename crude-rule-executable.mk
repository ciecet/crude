ifndef CRUDE_RULE_EXECUTABLE
CRUDE_RULE_EXECUTABLE := 1
endif

ifeq ($(LOCAL_TARGET),)
    LOCAL_TARGET := $(CRUDE_OUT)/bin/$(LOCAL_MODULE)
endif

include $(CRUDE_DIR)/crude-common-compile.mk

$(LOCAL_TARGET): PRIVATE_OBJS := $(LOCAL_OBJS)
$(LOCAL_TARGET): PRIVATE_LDFLAGS := $(LOCAL_LDFLAGS)
$(LOCAL_TARGET): PRIVATE_IMPORTS := $(LOCAL_IMPORTS)
$(LOCAL_TARGET):
	@mkdir -p $(dir $@) && echo '[1;32mEXECUTABLE [0;32m$@[0m'
	$(CRUDE_AT)$(CXX) -o $@ $(PRIVATE_OBJS) $(call import, OBJS, $(PRIVATE_IMPORTS)) -L$(CRUDE_OUT)/lib -Wl,-rpath-link=$(CRUDE_OUT)/lib -Wl,--start-group $(PRIVATE_LDFLAGS) $(call import, LDFLAGS, $(PRIVATE_IMPORTS)) -Wl,--end-group $(LDFLAGS)
