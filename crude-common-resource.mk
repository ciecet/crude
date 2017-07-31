ifndef CRUDE_COMMON_RESOURCE
CRUDE_COMMON_RESOURCE := 1

CRUDE_RESOURCE_TARGETS :=

define copy_file
$(3)$(1): $(2)$(1)
$(3)$(1): PRIVATE_SOURCE := $(2)$(1)
$$(if $$(findstring $(3)$(1), $$(CRUDE_RESOURCE_TARGETS)), \
    $$(error Resource Conflict on $(3)$(1) in $(LOCAL_MAKEFILE)))
LOCAL_RESOURCE_TARGETS += $(3)$(1)
CRUDE_RESOURCE_TARGETS += $(3)$(1)
endef

define handle_resspec
LOCAL_SRC := $(firstword $(subst :, ,$(1)))
LOCAL_DST := $(CRUDE_OUT)/$(lastword $(subst :, ,$(1)))
LOCAL_DST := $$(patsubst %/,%/$$(notdir $$(LOCAL_SRC)),$$(LOCAL_DST))
$$(if $$(shell test -d $$(LOCAL_SRC) && echo isdir), \
    $$(foreach file,$$(patsubst $$(LOCAL_SRC)%,%,$$(shell find $$(LOCAL_SRC) -type f)),\
            $$(eval $$(call copy_file,$$(file),$$(LOCAL_SRC),$$(LOCAL_DST)))),\
    $$(eval $$(call copy_file,,$$(LOCAL_SRC),$$(LOCAL_DST))))
endef

endif

LOCAL_RESOURCE_TARGETS :=
$(foreach resspec, $(LOCAL_RESOURCES), $(eval $(call handle_resspec,$(resspec))))

LOCAL_SUBTARGETS += $(LOCAL_RESOURCE_TARGETS)

$(LOCAL_RESOURCE_TARGETS):
	@mkdir -p $(dir $@) && echo "RESOURCE $@"
	$(CRUDE_AT)cp $(PRIVATE_SOURCE) $@
