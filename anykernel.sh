### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Midori Kernel
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

### AnyKernel install
## boot shell variables
BLOCK=boot
IS_SLOT_DEVICE=auto
RAMDISK_COMPRESSION=auto
PATCH_VBMETA_FLAG=auto
NO_MAGISK_CHECK=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

ui_print "Flashing Midori Kernel..."

# Resolving occasional file system I/O latency issues which may cause binary execution exceptions
sync
sleep 0.5
chmod -R 755 $AKHOME/tools

# Kernel version check
CURRENT_KERNEL_FULL=$(uname -r | cut -d'-' -f1)
CURRENT_KERNEL=$(echo "$CURRENT_KERNEL_FULL" | cut -d'.' -f1,2)

# Check for Image in AK3 root directory first (for raw/VBMETA boots)
if [ -f "$AKHOME/Image" ]; then
    PACKAGE_KERNEL_VER=$(grep -aoE 'Linux version [0-9]+\.[0-9]+\.[0-9]+' "$AKHOME/Image" | head -1 | awk '{print $3}')
    PACKAGE_KERNEL=$(echo "$PACKAGE_KERNEL_VER" | cut -d'.' -f1,2)

    if [ -z "$PACKAGE_KERNEL" ]; then
        ui_print "Warning: Could not detect package kernel version"
    else
        ui_print "Current kernel: $CURRENT_KERNEL_FULL"
        ui_print "Package kernel: $PACKAGE_KERNEL_VER"

        if [ "$CURRENT_KERNEL" != "$PACKAGE_KERNEL" ]; then
            ui_print "Error: Kernel version mismatch!"
            ui_print "Current: $CURRENT_KERNEL_FULL"
            ui_print "Package: $PACKAGE_KERNEL_VER"
            ui_print "Refusing to flash mismatched kernel!"
            exit 1
        fi
    fi
else
    # Fallback: check split_img
    KERNEL_BIN=$(ls split_img/*-zImage split_img/*-Image split_img/*-kernel 2>/dev/null | head -1)
    if [ -f "$KERNEL_BIN" ]; then
        PACKAGE_KERNEL_VER=$(grep -aoE 'Linux version [0-9]+\.[0-9]+\.[0-9]+' "$KERNEL_BIN" | head -1 | awk '{print $3}')
        PACKAGE_KERNEL=$(echo "$PACKAGE_KERNEL_VER" | cut -d'.' -f1,2)

        if [ -z "$PACKAGE_KERNEL" ]; then
            ui_print "Warning: Could not detect package kernel version"
        else
            ui_print "Current kernel: $CURRENT_KERNEL_FULL"
            ui_print "Package kernel: $PACKAGE_KERNEL_VER"

            if [ "$CURRENT_KERNEL" != "$PACKAGE_KERNEL" ]; then
                ui_print "Error: Kernel version mismatch!"
                ui_print "Current: $CURRENT_KERNEL_FULL"
                ui_print "Package: $PACKAGE_KERNEL_VER"
                ui_print "Refusing to flash mismatched kernel!"
                exit 1
            fi
        fi
    else
        ui_print "Warning: No kernel binary found, skipping version check"
    fi
fi

# boot install
split_boot
if [ -f "split_img/ramdisk.cpio" ]; then
    unpack_ramdisk
    write_boot
else
    flash_boot
fi
## end boot install
