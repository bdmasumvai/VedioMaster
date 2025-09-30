#!/bin/bash

# Initialization functions for VideoMaster Pro

check_storage_permission() {
    echo -e "$YELLOW Checking storage permission...$RESET"
    if [ ! -d "/sdcard" ] || [ ! -w "/sdcard" ]; then
        echo -e "$YELLOW Storage access not granted. Setting up storage...$RESET"
        termux-setup-storage
        sleep 2
        if [ ! -d "/sdcard" ] || [ ! -w "/sdcard" ]; then
            echo -e "$RED Error: Storage permission not granted. Please allow storage access in Termux settings and run again.$RESET"
            echo -e "$YELLOW 1. Go to Termux app settings."
            echo -e "$YELLOW 2. Allow storage permission."
            echo -e "$YELLOW 3. Run the script again with: videomaster$RESET"
            exit 1
        fi
    fi
    echo -e "$GREEN Storage permission granted!$RESET"
}

setup_directories() {
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR" || {
            echo -e "$RED Error: Failed to create $OUTPUT_DIR. Check permissions.$RESET"
            echo -e "$YELLOW Try running: termux-setup-storage$RESET"
            exit 1
        }
    fi
    if [ ! -d "$HIDDEN_DIR" ]; then
        mkdir -p "$HIDDEN_DIR" || {
            echo -e "$RED Error: Failed to create $HIDDEN_DIR. Check permissions.$RESET"
            echo -e "$YELLOW Try running: termux-setup-storage$RESET"
            exit 1
        }
    fi
    if [ ! -d "$BASE_DIR" ]; then
        mkdir -p "$BASE_DIR" || {
            echo -e "$RED Error: Failed to create $BASE_DIR. Check permissions.$RESET"
            exit 1
        }
    fi
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Directory setup completed" >> "$OP_LOG" 2>>"$ERROR_LOG"
}