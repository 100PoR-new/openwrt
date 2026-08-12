define Target/Description
	Build firmware images for Airoha AN7563 (ARMv8 Cortex-A53 running
	in AArch32 mode) based boards.
endef

# Standalone bl2.fip artifact. The U-Boot package installs it as
# $(STAGING_DIR_IMAGE)/an7563_<variant>-bl2.fip via Build/InstallDev.
define Build/an7563-preloader
  cat $(STAGING_DIR_IMAGE)/an7563_$1-bl2.fip >> $@
endef

# Bundled u-boot.fip artifact. For AN7563 the U-Boot package uses the
# legacy fip layout (FIP_LEGACY:=1), so the staged fip already contains
# BL2 + BL31 + U-Boot in a single FIP and is installed under the
# *-bl2-bl31-u-boot.fip name by Build/InstallDev.
define Build/an7563-bl2-bl31-uboot
  head -c $$((0x800)) /dev/zero > $@
  cat $(STAGING_DIR_IMAGE)/an7563_$1-bl2-bl31-u-boot.fip >> $@
  truncate -s $$((0x80000)) $@
endef

define Device/airoha_an7563-evb
  DEVICE_VENDOR := Airoha
  DEVICE_MODEL := AN7563 Evaluation Board
  DEVICE_DTS := an7563-evb
  DEVICE_PACKAGES += kmod-i2c-an7581
  KERNEL_LOADADDR := 0x80088000
  ARTIFACT/preloader.bin := an7563-preloader rfb
  ARTIFACT/bl2-bl31-uboot.bin := an7563-bl2-bl31-uboot rfb
  ARTIFACTS := preloader.bin bl2-bl31-uboot.bin
endef
TARGET_DEVICES += airoha_an7563-evb

define Device/xiaomi_be5000
  DEVICE_VENDOR := Xiaomi
  DEVICE_MODEL := BE5000
  DEVICE_DTS := an7563-xiaomi-be5000
  # kmod-phy-airoha-en8811h: driver for the onboard EN8811H 2.5G PHY
  #   (mdio addr 0xf) - without it, the en8811 ethernet-phy@f node in
  #   the dts has no matching driver and the PHY never binds.
  # airoha-en7581-mt7996-npu-firmware: firmware blobs for the NPU
  #   node the eth driver references via "airoha,npu = <&npu>" -
  #   without it, request_firmware() for the NPU can't complete.
  #   NOTE: picked the mt7996 firmware variant by analogy with
  #   AN7581 boards; not yet confirmed this is the right NPU
  #   firmware variant for the AN7563+MT7991 pairing specifically -
  #   revisit once WiFi bring-up is underway.
  DEVICE_PACKAGES += kmod-i2c-an7581 \
		      kmod-phy-airoha-en8811h \
		      airoha-en7581-mt7996-npu-firmware
  KERNEL_LOADADDR := 0x80088000
  ARTIFACT/preloader.bin := an7563-preloader xiaomi_be5000
  ARTIFACT/bl2-bl31-uboot.bin := an7563-bl2-bl31-uboot xiaomi_be5000
  ARTIFACTS := preloader.bin bl2-bl31-uboot.bin
endef
TARGET_DEVICES += xiaomi_be5000
