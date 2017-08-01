ifndef CRUDE_RULE_SHAREDLIB
CRUDE_RULE_SHAREDLIB := 1
endif

ifeq ($(LOCAL_TARGET),)
    LOCAL_TARGET := $(CRUDE_OUT)/lib/lib$(LOCAL_MODULE).so
endif

EXPORT_LDFLAGS += -l$(LOCAL_MODULE)

LOCAL_CFLAGS += -fPIC
LOCAL_CXXFLAGS += -fPIC
include $(CRUDE_DIR)/crude-common-compile.mk

$(LOCAL_TARGET): PRIVATE_OBJS := $(LOCAL_OBJS)
$(LOCAL_TARGET): PRIVATE_LDFLAGS := $(LOCAL_LDFLAGS)
$(LOCAL_TARGET): PRIVATE_IMPORTS := $(LOCAL_IMPORTS)
$(LOCAL_TARGET):
	@mkdir -p $(dir $@) && echo '[1;33mSHAREDLIB [0;33m$@[0m'
	$(CRUDE_AT)$(CXX) -shared -o $@ $(PRIVATE_OBJS) -L$(CRUDE_OUT)/lib -Wl,-rpath-link=$(CRUDE_OUT)/lib -Wl,--start-group $(PRIVATE_LDFLAGS) $(call import, LDFLAGS, $(PRIVATE_IMPORTS)) -Wl,--end-group $(LDFLAGS)
