$(call begin-target, log, staticlib)
    LOCAL_SRCS := $(LOCAL_PATH)/log.c
    EXPORT_CFLAGS := -I$(LOCAL_PATH)
$(end-target)

$(call begin-target, log)
    EXPORT_IMPORTS := log-staticlib
$(end-target)
