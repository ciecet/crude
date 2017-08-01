$(call begin-target, helloworld, executable)
    LOCAL_SRCS := $(LOCAL_PATH)/helloworld.c
    LOCAL_IMPORTS := log
$(end-target)
