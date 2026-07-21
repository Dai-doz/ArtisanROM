TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"

if [[ ! -d "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/priv-app/ClockPack_v80" ]]; then
    LOG "\033[0;33m! Nothing to do\033[0m"
    return 0
fi

LOG_STEP_IN "- Removing Always On Display Service"
DELETE_FROM_WORK_DIR "system" "system/etc/permissions/com.samsung.feature.aodservice_v10.xml"
DELETE_FROM_WORK_DIR "system" "system/etc/permissions/privapp-permissions-com.samsung.android.app.aodservice.xml"
DELETE_FROM_WORK_DIR "system" "system/priv-app/AODService_v80"
LOG_STEP_OUT

LOG_STEP_IN "- Adding ClockPack"
ADD_TO_WORK_DIR "a17xxx" "system" "system/etc/permissions/com.samsung.feature.clockpack_v10.xml" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "a17xxx" "system" "system/etc/permissions/privapp-permissions-com.samsung.android.app.clockpack.xml" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "a17xxx" "system" "system/priv-app/ClockPack_v80" 0 0 755 "u:object_r:system_file:s0"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_AOD_ITEM" --delete
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_CLOCKPACK_ITEM" "clockpackversion=7"
LOG_STEP_OUT

unset TARGET_FIRMWARE_PATH
