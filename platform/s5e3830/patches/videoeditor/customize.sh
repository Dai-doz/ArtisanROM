# Backup files
cp $SRC_DIR/unica/mods/setupwizard/customize.sh $SRC_DIR/unica/mods/setupwizard/customize.sh.orig
cp $SRC_DIR/unica/mods/settings/smali/system/framework/framework.jar/0002-Introduce-SamsungPropsHooks.patch $SRC_DIR/unica/mods/settings/0002-Introduce-SamsungPropsHooks.patch.orig

# Set common device model depending of device, this will replace SM-A057 value on patch
if [[ "$TARGET_CODENAME" == "a21s" ]]; then
    DEVICE_MODEL=SM-A217
elif [[ "$TARGET_CODENAME" == "a12s" ]]; then
    DEVICE_MODEL=SM-A127
elif [[ "$TARGET_CODENAME" == "m12" ]]; then
    DEVICE_MODEL=SM-M127
elif [[ "$TARGET_CODENAME" == "f12" ]]; then
    DEVICE_MODEL=SM-F127
elif [[ "$TARGET_CODENAME" == "xcover5" ]]; then
    DEVICE_MODEL=SM-G525
elif [[ "$TARGET_CODENAME" == "a13" ]]; then
    DEVICE_MODEL=SM-A135
elif [[ "$TARGET_CODENAME" == "m13" ]]; then
    DEVICE_MODEL=SM-M135
elif [[ "$TARGET_CODENAME" == "f13" ]]; then
    DEVICE_MODEL=SM-E135
elif [[ "$TARGET_CODENAME" == "a04s" ]]; then
    DEVICE_MODEL=SM-A047
elif [[ "$TARGET_CODENAME" == "a14" ]]; then
    DEVICE_MODEL=SM-A145
fi

# Replace value by device
EVAL "sed -i \"s/SM\-A057/$DEVICE_MODEL/g\" \"$SRC_DIR/unica/mods/settings/smali/system/framework/framework.jar/0002-Introduce-SamsungPropsHooks.patch\""

# Restore files after patching was done
echo "rm $SRC_DIR/unica/mods/setupwizard/customize.sh
rm $SRC_DIR/unica/mods/settings/smali/system/framework/framework.jar/0002-Introduce-SamsungPropsHooks.patch
cp $SRC_DIR/unica/mods/setupwizard/customize.sh.orig $SRC_DIR/unica/mods/setupwizard/customize.sh
cp $SRC_DIR/unica/mods/settings/0002-Introduce-SamsungPropsHooks.patch.orig $SRC_DIR/unica/mods/settings/smali/system/framework/framework.jar/0002-Introduce-SamsungPropsHooks.patch
" >> $SRC_DIR/unica/mods/setupwizard/customize.sh