ifneq ($(LOCAL_CHECK_SRCS),n)
    LOCAL_NOSRCS := $(filter-out $(wildcard $(LOCAL_SRCS)), $(LOCAL_SRCS))
    ifneq ($(LOCAL_NOSRCS),)
        $(error $(LOCAL_MAKEFILE):$(LOCAL_TARGET_ID): Non existing files: $(LOCAL_NOSRCS))
    endif
endif

LOCAL_INNER_SRCS = $(filter $(LOCAL_PATH)/%, $(LOCAL_SRCS))
LOCAL_OUTER_SRCS = $(filter-out $(LOCAL_PATH)/%, $(LOCAL_SRCS))

LOCAL_OBJS += $(patsubst $(LOCAL_PATH)/%.S, $(LOCAL_INTERMEDIATE)/%.o, \
        $(filter %.S, $(LOCAL_INNER_SRCS)))
LOCAL_OBJS += $(patsubst $(LOCAL_PATH)/%.c, $(LOCAL_INTERMEDIATE)/%.o, \
        $(filter %.c, $(LOCAL_INNER_SRCS)))
LOCAL_OBJS += $(patsubst $(LOCAL_PATH)/%.cpp, $(LOCAL_INTERMEDIATE)/%.o, \
        $(filter %.cpp, $(LOCAL_INNER_SRCS)))
LOCAL_OBJS += $(patsubst %.S, $(LOCAL_INTERMEDIATE)/%.o, \
        $(filter %.S, $(LOCAL_OUTER_SRCS)))
LOCAL_OBJS += $(patsubst %.c, $(LOCAL_INTERMEDIATE)/%.o, \
        $(filter %.c, $(LOCAL_OUTER_SRCS)))
LOCAL_OBJS += $(patsubst %.cpp, $(LOCAL_INTERMEDIATE)/%.o, \
        $(filter %.cpp, $(LOCAL_OUTER_SRCS)))

LOCAL_SUBTARGETS += $(LOCAL_OBJS)

ifneq ($(LOCAL_OBJDEPS)$(LOCAL_OBJ_DEPENDS),)
    $(warning $(LOCAL_MAKEFILE):$(LOCAL_TARGET_ID): uses deprecated LOCAL_OBJDEPS or LOCAL_OBJ_DEPENDS. Use LOCAL_DEPENDS instead)
    LOCAL_DEPENDS += $(LOCAL_OBJDEPS) $(LOCAL_OBJ_DEPENDS)
endif
ifneq ($(LOCAL_SHAREDLIB),)
    $(warning $(LOCAL_MAKEFILE):$(LOCAL_TARGET_ID): uses LOCAL_SHAREDLIB. Should use LOCAL_SHAREDLIBS)
    LOCAL_SHAREDLIBS += $(LOCAL_SHAREDLIB)
endif
ifneq ($(LOCAL_STATICLIB),)
    $(warning $(LOCAL_MAKEFILE):$(LOCAL_TARGET_ID): uses LOCAL_STATICLIB. Should use LOCAL_STATICLIBS)
    LOCAL_STATICLIBS += $(LOCAL_STATICLIB)
endif

LOCAL_IMPORTS += \
        $(foreach l, $(LOCAL_SHAREDLIBS), $(l)-sharedlib) \
        $(foreach l, $(LOCAL_STATICLIBS), $(l)-staticlib)

ifneq ($(filter 1 y yes true, $(CRUDE_MAKEDEPEND)),)
    LOCAL_CFLAGS += -MP -MMD
    LOCAL_CXXFLAGS += -MP -MMD
endif

$(LOCAL_INTERMEDIATE)/%.o: PRIVATE_ASFLAGS := $(LOCAL_ASFLAGS)
$(LOCAL_INTERMEDIATE)/%.o: PRIVATE_CFLAGS := $(LOCAL_CFLAGS)
$(LOCAL_INTERMEDIATE)/%.o: PRIVATE_CXXFLAGS := $(LOCAL_CXXFLAGS)
$(LOCAL_INTERMEDIATE)/%.o: PRIVATE_IMPORTS := $(LOCAL_IMPORTS)

$(LOCAL_INTERMEDIATE)/%.o: $(LOCAL_PATH)/%.S
	@mkdir -p $(dir $@) && echo '[1;37mOBJ [0;37m$@[0m'
	$(CRUDE_AT)$(CC) -c $(PRIVATE_ASFLAGS) $(call import, ASFLAGS, $(PRIVATE_IMPORTS)) $(ASFLAGS) -o $@ $<

$(LOCAL_INTERMEDIATE)/%.o: $(LOCAL_PATH)/%.c
	@mkdir -p $(dir $@) && echo '[1;37mOBJ [0;37m$@[0m'
	$(CRUDE_AT)$(CC) -c $(PRIVATE_CFLAGS) $(call import, CFLAGS, $(PRIVATE_IMPORTS)) $(CFLAGS) -o $@ $<

$(LOCAL_INTERMEDIATE)/%.o: $(LOCAL_PATH)/%.cpp
	@mkdir -p $(dir $@) && echo '[1;37mOBJ [0;37m$@[0m'
	$(CRUDE_AT)$(CXX) -c $(PRIVATE_CXXFLAGS) $(call import, CXXFLAGS, $(PRIVATE_IMPORTS)) $(CXXFLAGS) -o $@ $<

$(LOCAL_INTERMEDIATE)/%.o: %.S
	@mkdir -p $(dir $@) && echo '[1;37mOBJ [0;37m$@[0m'
	$(CRUDE_AT)$(CC) -c $(PRIVATE_ASFLAGS) $(call import, ASFLAGS, $(PRIVATE_IMPORTS)) $(ASFLAGS) -o $@ $<

$(LOCAL_INTERMEDIATE)/%.o: %.c
	@mkdir -p $(dir $@) && echo '[1;37mOBJ [0;37m$@[0m'
	$(CRUDE_AT)$(CC) -c $(PRIVATE_CFLAGS) $(call import, CFLAGS, $(PRIVATE_IMPORTS)) $(CFLAGS) -o $@ $<

$(LOCAL_INTERMEDIATE)/%.o: %.cpp
	@mkdir -p $(dir $@) && echo '[1;37mOBJ [0;37m$@[0m'
	$(CRUDE_AT)$(CXX) -c $(PRIVATE_CXXFLAGS) $(call import, CXXFLAGS, $(PRIVATE_IMPORTS)) $(CXXFLAGS) -o $@ $<

-include $(LOCAL_OBJS:.o=.d)
