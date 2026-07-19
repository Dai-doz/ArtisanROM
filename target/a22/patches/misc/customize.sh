LOG "- Removing FBE attributes on line 15 in /vendor/etc/fstab.mt6769t"
EVAL "sed -i \"15s/,fileencryption=aes-256-xts:aes-256-cts:v2,/,/g\" \"$WORK_DIR/vendor/etc/fstab.mt6769t\""