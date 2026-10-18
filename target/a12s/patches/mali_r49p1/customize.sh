SEPOLICY_VERSION="$(tr "." "_" < "$WORK_DIR/vendor/etc/selinux/plat_sepolicy_vers.txt")"

# __libcpp_verbose_abort is missing from the VNDK 33 libc++, bind it weak
HEX_PATCH "$WORK_DIR/vendor/lib64/egl/libGLES_mali.so" \
    "653700001200000000000000000000000000000000000000" "653700002200000000000000000000000000000000000000"
HEX_PATCH "$WORK_DIR/vendor/lib/egl/libGLES_mali.so" \
    "72370000000000000000000012000000" "72370000000000000000000022000000"
HEX_PATCH "$WORK_DIR/vendor/lib64/android.hardware.graphics.allocator-V2-ndk.so" \
    "6a0200001200000000000000000000000000000000000000" "6a0200002200000000000000000000000000000000000000"
HEX_PATCH "$WORK_DIR/vendor/lib/android.hardware.graphics.allocator-V2-ndk.so" \
    "b5020000000000000000000012000000" "b5020000000000000000000022000000"
HEX_PATCH "$WORK_DIR/vendor/lib64/android.hardware.graphics.common-V5-ndk.so" \
    "c00300001200000000000000000000000000000000000000" "c00300002200000000000000000000000000000000000000"
HEX_PATCH "$WORK_DIR/vendor/lib/android.hardware.graphics.common-V5-ndk.so" \
    "ad090000000000000000000012000000" "ad090000000000000000000022000000"

LOG "- Patching /vendor/etc/selinux/vendor_sepolicy.cil"
EVAL "cat \"$MODPATH/vendor_sepolicy.cil.diff\" >> \"$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil\""
for t in "property_type" "vendor_property_type" "vendor_restricted_property_type"; do
    EVAL "sed -i \"s/^(typeattributeset $t (/&vendor_arm_egl_configs_prop vendor_arm_gralloc_prop /\" \"$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil\""
done
for p in "vendor_arm_egl_configs_prop" "vendor_arm_gralloc_prop"; do
    EVAL "echo \"(allow vendor_init_$SEPOLICY_VERSION $p (property_service (set)))\" >> \"$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil\""
    EVAL "echo \"(allow vendor_init_$SEPOLICY_VERSION $p (file (read getattr map open)))\" >> \"$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil\""
done

LOG "- Patching /vendor/etc/selinux/vendor_property_contexts"
EVAL "cat \"$MODPATH/vendor_property_contexts.diff\" >> \"$WORK_DIR/vendor/etc/selinux/vendor_property_contexts\""

LOG "- Patching /vendor/etc/selinux/vendor_file_contexts"
EVAL "echo \"/(vendor|system/vendor)/lib(64)?/android\\\\.hardware\\\\.graphics\\\\.common-V5-ndk\\\\.so u:object_r:same_process_hal_file:s0\" >> \"$WORK_DIR/vendor/etc/selinux/vendor_file_contexts\""
EVAL "echo \"/(vendor|system/vendor)/lib(64)?/android\\\\.hardware\\\\.graphics\\\\.allocator-V2-ndk\\\\.so u:object_r:same_process_hal_file:s0\" >> \"$WORK_DIR/vendor/etc/selinux/vendor_file_contexts\""
