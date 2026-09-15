# SPDX-License-Identifier: GPL-2.0

# Out-of-tree Makefile rules

M ?= $(shell pwd)

KBASE_PATH_RELATIVE = $(M)

ifndef CONFIG_DRM_VERISILICON
# When building out of tree default to build as module
CONFIG_DRM_VERISILICON = m

# apply out-of-tree build 9x00 defaults
ifeq ($(CONFIG_VERISILICON_CHIP_8x00), y)
CONFIG_VERISILICON_CHIP_8x00 ?= y
CONFIG_VERISILICON_CHIP_9x00 = n
CONFIG_VERISILICON_CHIP_dcnano = n
CONFIG_VERISILICON_WRITEBACK ?= y
CONFIG_VERISILICON_DEC ?= y
CONFIG_VERISILICON_MMU ?= n
else ifeq ($(CONFIG_VERISILICON_CHIP_9x00), y)
CONFIG_VERISILICON_CHIP_9x00 ?= y
CONFIG_VERISILICON_CHIP_8x00 = n
CONFIG_VERISILICON_CHIP_dcnano = n
CONFIG_VERISILICON_WRITEBACK ?= y
CONFIG_VERISILICON_PVRIC ?= y
CONFIG_VERISILICON_DEC ?= y
CONFIG_VERISILICON_DEC400A ?= n
CONFIG_VERISILICON_REGMAP ?= y
CONFIG_VERISILICON_FLEXA ?= n
else
CONFIG_VERISILICON_CHIP_dcnano ?= y
CONFIG_VERISILICON_CHIP_9x00 = n
CONFIG_VERISILICON_CHIP_8x00 = n
CONFIG_VERISILICON_DEC ?= y
CONFIG_VERISILICON_QSPI ?= y
endif

CONFIG_VERISILICON_DEBUG ?= n
CONFIG_VERISILICON_REG_DUMP ?= n
CONFIG_VERISILICON_FLEXA ?= n
# verisilicon internal config
CONFIG_VERISILICON_PCIE_GEN7 ?= y
CONFIG_VERISILICON_VIRTUAL_DISPLAY ?= y
CONFIG_VERISILICON_PCIE ?= y


KBUILD_OPTIONS += CONFIG_DRM_VERISILICON=$(CONFIG_DRM_VERISILICON)

VERISILICON_CONFIGS := DEC \
                       PVRIC \
                       DEC400A \
                       WRITEBACK \
                       VIRTUAL_DISPLAY \
                       QSPI \
                       MMU \
                       DEBUG\
                       FLEXA

KBUILD_OPTIONS += $(foreach c,$(VERISILICON_CONFIGS), \
                    $(if $(filter y,$(value $(addsuffix $(c),CONFIG_VERISILICON_))), \
                      CONFIG_VERISILICON_$(c)=$(value $(addsuffix $(c),CONFIG_VERISILICON_))) \
                   )

EXTRA_CFLAGS += $(if $(filter y,$(value CONFIG_VERISILICON_CHIP_9x00)), \
                        -DCONFIG_VERISILICON_CHIP_9x00)
EXTRA_CFLAGS += $(if $(filter y,$(value CONFIG_VERISILICON_CHIP_8x00)), \
                        -DCONFIG_VERISILICON_CHIP_8x00)
EXTRA_CFLAGS += $(if $(filter y,$(value CONFIG_VERISILICON_CHIP_dcnano)), \
                        -DCONFIG_VERISILICON_CHIP_dcnano)
EXTRA_CFLAGS += $(if $(filter y,$(value CONFIG_VERISILICON_PCIE)), \
                        -DCONFIG_VERISILICON_PCIE)
EXTRA_CFLAGS += $(if $(filter y,$(value CONFIG_VERISILICON_PCIE_GEN7)), \
                        -DCONFIG_VERISILICON_PCIE_GEN7)
EXTRA_CFLAGS += $(if $(filter y,$(value CONFIG_VERISILICON_DEBUG)), \
                        -DCONFIG_VERISILICON_DEBUG)
EXTRA_CFLAGS += $(if $(filter y,$(value CONFIG_VERISILICON_REG_DUMP)), \
                        -DCONFIG_VERISILICON_REG_DUMP)
endif

modules modules_install headers_install clean:
		$(MAKE) -C $(KERNEL_SRC) M=$(M) W=1 $(KBUILD_OPTIONS) \
                EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
                KBUILD_EXTRA_SYMBOLS="$(EXTRA_SYMBOLS)" $(@)

modules_install: headers_install
