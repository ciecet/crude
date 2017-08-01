CRUDE_MAKEDEPEND := 1
include ../crude.mk

.PHONY: all list
all:

include $(wildcard */build.mk)

all: $(CRUDE_TARGETS)

list:
	@echo LABELS: $(CRUDE_LABELS)
	@echo TARGETS: $(CRUDE_TARGETS)
