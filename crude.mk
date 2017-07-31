CRUDE_OUT ?= out
CRUDE_TARGETS :=
CRUDE_LABELS :=
CRUDE_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
CRUDE_CLEAN ?= clean

.PHONY: $(CRUDE_CLEAN)

ifeq ($(filter 1 y yes true, $(CRUDE_SHOWCOMMANDS)),)
    CRUDE_AT := @
endif

define _my-makefile
    $(lastword $(filter-out $(CRUDE_DIR)/% $(patsubst ./%,%,$(CRUDE_OUT))/%,$(MAKEFILE_LIST)))
endef

define _my-dir
    $(patsubst %/, %, $(dir $(_my-makefile)))
endef

define _begin-target
    ifeq ($(1),$(CRUDE_CLEAN))
        $$(error Module name cannot be $(CRUDE_CLEAN))
    endif
    LOCAL_MODULE := $(1)
    LOCAL_RULE := $(2)
    LOCAL_TARGET_ID := $(if $(2),$(1)-$(2),$(1))
    LOCAL_MAKEFILE := $(_my-makefile)
    LOCAL_PATH := $(_my-dir)
    LOCAL_INTERMEDIATE := $(CRUDE_OUT)/intermediate/$$(LOCAL_TARGET_ID)
    LOCAL_LABELS := DEFAULT
    .PHONY: $$(LOCAL_MODULE) $$(LOCAL_TARGET_ID)
endef

define _end-target
    include $(CRUDE_DIR)/crude-rule-$$(LOCAL_RULE).mk
    include $(CRUDE_DIR)/crude-common-resource.mk
    include $(CRUDE_DIR)/crude-common-clean.mk
    $$(LOCAL_TARGET): $$(LOCAL_SUBTARGETS)
    $$(LOCAL_TARGET) $$(LOCAL_SUBTARGETS): $$(LOCAL_MAKEFILE) $$(LOCAL_DEPENDS)
    $$(LOCAL_TARGET) $$(LOCAL_SUBTARGETS): $$$$(call import, $$(LOCAL_IMPORTS), TARGET)
    $$(LOCAL_TARGET) $$(LOCAL_SUBTARGETS): $$$$(call whole-import, $$(LOCAL_WHOLE_IMPORTS), TARGET)
    $$(LOCAL_MODULE): $$(LOCAL_TARGET)
    $$(LOCAL_TARGET_ID): $$(LOCAL_TARGET)
    .PHONY: $$(LOCAL_LABELS)
    $$(LOCAL_LABELS): $$(LOCAL_TARGET)
    ifneq ($$(filter $$(LOCAL_TARGET_ID), $$(CRUDE_TARGETS)),)
        $$(error Duplicated module $$(LOCAL_TARGET_ID))
    endif
    CRUDE_TARGETS += $$(LOCAL_TARGET_ID)
    EXPORT_TARGET := $$(LOCAL_TARGET)
    $$(foreach v,$$(LOCAL_LABELS),$$(if $$(filter $$(v),$$(CRUDE_LABELS)),,$$(eval CRUDE_LABELS += $$(v))))
    $$(foreach v,$$(LOCAL_LABELS),$$(eval CRUDE_$$(v)_TARGETS := $$(CRUDE_$$(v)_TARGETS) $$(LOCAL_TARGET_ID)))
    $$(foreach v,$$(filter EXPORT_%,$$(.VARIABLES)),$$(if $$($$(v)),$$(eval CRUDE_EXPORTS-$$(LOCAL_TARGET_ID)-$$(v:EXPORT_%=%) := $$($$(v)))))
    $$(foreach v,$$(filter LOCAL_%_EXPORT,$$(.VARIABLES)),$$(if $$($$(v)),$$(eval CRUDE_EXPORTS-$$(LOCAL_TARGET_ID)-$$(v:LOCAL_%_EXPORT=%) := $$($$(v)))))
    $$(foreach v,$$(filter LOCAL_% EXPORT_%,$$(.VARIABLES)),$$(eval $$(v) :=))
endef

define begin-target
    $(eval $(call _begin-target,$(strip $(1)),$(strip $(2))))
endef

define end-target
    $(eval $(_end-target))
endef

define _expand_aux
    $(1) $(foreach i,$(1),$(call _expand_aux,$(CRUDE_EXPORTS-$(i)-IMPORTS)))
endef

define _expand
    $(eval _uniq :=)
    $(foreach i,$(call _expand_aux,$(1)),$(if $(filter $i,$(_uniq)),,$(eval _uniq += $i)))
    $(_uniq)
endef

# import(module list, variable)
define import
    $(foreach i,$(call _expand,$(1)),$(CRUDE_EXPORTS-$(i)-$(firstword $(2))))
endef

# _filter(module list, rule)
define _filter
    $(if $(2),$(shell for i in $(1); do echo "$$i"; done | egrep $(2)),$(1))
endef

# whole-import(label list + regexp filter, variable)
define whole-import
    $(call import
        ,$(call _filter
            ,$(foreach i, $(filter $(CRUDE_LABELS), $(1)), $(CRUDE_$(i)_TARGETS))
            ,$(filter-out $(CRUDE_LABELS), $(1)))
        ,$(2))
endef

# allow prerequsites to be evaluated later
.SECONDEXPANSION:

# leave intermediate files
