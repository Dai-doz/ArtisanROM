if [ "$TARGET_PLATFORM_SDK_VERSION" -lt "34" ]; then
    # Delete old files
    BLOBS_LIST="
    android.hardware.radio.config@1.0.so
    android.hardware.radio.config@1.1.so
    android.hardware.radio.config@1.2.so
    android.hardware.radio.deprecated@1.0.so
    android.hardware.radio@1.3.so
    android.hardware.radio@1.4.so
    android.hardware.radio@1.5.so
    vendor.samsung.hardware.radio.bridge@2.0.so
    vendor.samsung.hardware.radio.bridge@2.1.so
    vendor.samsung.hardware.radio.channel@2.0.so
    vendor.samsung.hardware.radio@2.0.so
    vendor.samsung.hardware.radio@2.1.so
    vendor.samsung.hardware.radio@2.2.so
    "
    for blobs in $BLOBS_LIST; do
      DELETE_FROM_WORK_DIR "vendor" "lib64/$blobs"
    done
    
    # /vendor/bin/hw
    EVAL "cp -f \"$MODPATH/bin/hw/rild\" \"$WORK_DIR/vendor/bin/hw/rild\""
    SET_METADATA "vendor" "bin/hw/rild" 0 2000 755 "u:object_r:rild_exec:s0"
    
    # /vendor/etc/vintf
    EVAL "cp -f \"$MODPATH/etc/vintf/manifest/vendor.samsung.hardware.radio.exclude.slsi.xml\" \"$WORK_DIR/vendor/etc/vintf/manifest/vendor.samsung.hardware.radio.exclude.slsi.xml\""
    EVAL "cp -f \"$MODPATH/etc/vintf/manifest/vendor.samsung.hardware.radio_manifest_2_34.xml\" \"$WORK_DIR/vendor/etc/vintf/manifest/vendor.samsung.hardware.radio_manifest_2_34.xml\""
    EVAL "cp -f \"$MODPATH/etc/vintf/manifest/vendor.samsung.hardware.sehradio_manifest_2_34.xml\" \"$WORK_DIR/vendor/etc/vintf/manifest/vendor.samsung.hardware.sehradio_manifest_2_34.xml\""
    SET_METADATA "vendor" "etc/vintf/manifest/vendor.samsung.hardware.radio.exclude.slsi.xml" 0 0 644 "u:object_r:vendor_configs_file:s0"
    SET_METADATA "vendor" "etc/vintf/manifest/vendor.samsung.hardware.radio_manifest_2_34.xml" 0 0 644 "u:object_r:vendor_configs_file:s0"
    SET_METADATA "vendor" "etc/vintf/manifest/vendor.samsung.hardware.sehradio_manifest_2_34.xml" 0 0 644 "u:object_r:vendor_configs_file:s0"
    
    EVAL "cp -f \"$MODPATH/etc/vintf/manifest_$TARGET_BOARD_API_LEVEL.xml\" \"$WORK_DIR/vendor/etc/vintf/manifest.xml\""
    SET_METADATA "vendor" "etc/vintf/manifest.xml" 0 0 644 "u:object_r:vendor_configs_file:s0"
    
    # /vendor/lib64
    LIBS_LIST="
    lib64/android.hardware.radio.config-V1-ndk.so
    lib64/android.hardware.radio.data-V1-ndk.so
    lib64/android.hardware.radio.messaging-V1-ndk.so
    lib64/android.hardware.radio.modem-V1-ndk.so
    lib64/android.hardware.radio.network-V1-ndk.so
    lib64/android.hardware.radio.sim-V1-ndk.so
    lib64/android.hardware.radio-V1-ndk.so
    lib64/android.hardware.radio.voice-V1-ndk.so
    lib64/libprotobuf-cpp-full-21.7.so
    lib64/libril_sem.so
    lib64/libsec-ril.so
    lib64/libSemDataProps.so
    lib64/libSemTelephonyProps.so
    lib64/vendor.samsung.hardware.radio.bridge-V1-ndk.so
    lib64/vendor.samsung.hardware.radio.channel-V1-ndk.so
    lib64/vendor.samsung.hardware.radio.data-V1-ndk.so
    lib64/vendor.samsung.hardware.radio.messaging-V1-ndk.so
    lib64/vendor.samsung.hardware.radio.network-V1-ndk.so
    lib64/vendor.samsung.hardware.radio.sim-V1-ndk.so
    lib64/vendor.samsung.hardware.radio-V1-ndk.so
    "
    if [[ "$TARGET_BOARD_API_LEVEL" == "31" ]]; then
        LIBS_LIST+="lib64/android.system.keystore2-V1-ndk.so"
    elif [[ "$TARGET_BOARD_API_LEVEL" == "33" ]]; then
        LIBS_LIST+="
        lib64/android.hardware.radio@1.0.so
        lib64/android.hardware.radio@1.1.so
        lib64/android.hardware.radio@1.2.so
        lib64/libprotobuf-cpp-lite-21.7.so
        lib64/librilutils.so
        lib64/libsecril-client.so
        "
    fi

    for lib in $LIBS_LIST; do
      EVAL "cp -f \"$MODPATH/$lib\" \"$WORK_DIR/vendor/$lib\""
      SET_METADATA "vendor" "$lib" 0 0 644 "u:object_r:vendor_file:s0"
    done
        
    # Dual SIM fix - not required for UN1CA but it is for a16+
    EVAL "echo \"    setprop ro.telephony.sim_slots.count 2\" >> \"$WORK_DIR/vendor/etc/init/init.baseband.rc\""
    
    # SELinux
    LOG "- Adding SELinux entries"
    if [[ "$TARGET_BOARD_API_LEVEL" == "31" ]]; then
        {
            echo "(allow vendor_init_31_0 telephony_prop (property_service (set)))"
        } >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    elif [[ "$TARGET_BOARD_API_LEVEL" == "33" ]]; then
        {
            echo "(allow vendor_init_33_0 telephony_prop (property_service (set)))"
        } >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    fi
    
    # Add Samsung Radio AIDL services to vendor_service_contexts on vndk31 devices
    if [[ "$TARGET_BOARD_API_LEVEL" == "31" ]]; then
        VND_CTX="$WORK_DIR/vendor/etc/selinux/vendor_service_contexts"
        echo "" >> "$VND_CTX"
        echo "# Samsung Radio AIDL Services Contexts Mappings" >> "$VND_CTX"
        echo "vendor.samsung.hardware.radio.network.ISehRadioNetwork/slot1      u:object_r:hal_radio_service:s0" >> "$VND_CTX"
        echo "vendor.samsung.hardware.radio.network.ISehRadioNetwork/slot2      u:object_r:hal_radio_service:s0" >> "$VND_CTX"
        echo "vendor.samsung.hardware.radio.bridge.ISehRadioBridge/slot1        u:object_r:hal_radio_service:s0" >> "$VND_CTX"
        echo "vendor.samsung.hardware.radio.bridge.ISehRadioBridge/slot2        u:object_r:hal_radio_service:s0" >> "$VND_CTX"
        echo "vendor.samsung.hardware.radio.channel.ISehRadioChannel/imsd       u:object_r:hal_radio_service:s0" >> "$VND_CTX"
        echo "vendor.samsung.hardware.radio.channel.ISehRadioChannel/imsd2      u:object_r:hal_radio_service:s0" >> "$VND_CTX"
        echo "vendor.samsung.hardware.radio.channel.ISehRadioChannel/epdgd      u:object_r:hal_radio_service:s0" >> "$VND_CTX"
        echo "vendor.samsung.hardware.radio.channel.ISehRadioChannel/epdgd2     u:object_r:hal_radio_service:s0" >> "$VND_CTX"
        echo "vendor.samsung.hardware.radio.data.ISehRadioData/slot1            u:object_r:hal_radio_service:s0" >> "$VND_CTX"
        echo "vendor.samsung.hardware.radio.data.ISehRadioData/slot2            u:object_r:hal_radio_service:s0" >> "$VND_CTX"
        echo "vendor.samsung.hardware.radio.sim.ISehRadioSim/slot1              u:object_r:hal_radio_service:s0" >> "$VND_CTX"
        echo "vendor.samsung.hardware.radio.sim.ISehRadioSim/slot2              u:object_r:hal_radio_service:s0" >> "$VND_CTX"
        echo "vendor.samsung.hardware.radio.messaging.ISehRadioMessaging/slot1  u:object_r:hal_radio_service:s0" >> "$VND_CTX"
        echo "vendor.samsung.hardware.radio.messaging.ISehRadioMessaging/slot2  u:object_r:hal_radio_service:s0" >> "$VND_CTX"
        unset VND_CTX
    fi
    
    # Disable second SIM on vndk31 devices due to a bug in a14 ril hal
    if [[ "$TARGET_BOARD_API_LEVEL" == "31" ]]; then
        echo "service ril-daemon1 /vendor/bin/hw/rild -c 2" > $WORK_DIR/system/system/etc/init/disable_rild2.rc
        echo "    override" >> $WORK_DIR/system/system/etc/init/disable_rild2.rc
        echo "    disabled" >> $WORK_DIR/system/system/etc/init/disable_rild2.rc
        SET_METADATA "system" "system/etc/init/disable_rild2.rc" 0 0 644 "u:object_r:system_file:s0"
    fi

else
    LOG "\033[0;33m! Nothing to do\033[0m"
    return 0
fi
