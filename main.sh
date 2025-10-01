#!/bin/bash

# VideoMaster Pro - Main entry point
# Version: 3.3.1
# Author: Masum Vai

# Define base directory
BASE_DIR="$HOME/.videomaster"

# Source modules
source "$BASE_DIR/config.sh"
source "$BASE_DIR/init.sh"
source "$BASE_DIR/utils.sh"
source "$BASE_DIR/display.sh"
source "$BASE_DIR/menus.sh"
source "$BASE_DIR/compression.sh"
source "$BASE_DIR/watermark.sh"
source "$BASE_DIR/conversion.sh"
source "$BASE_DIR/noise.sh"

# Start the tool
check_storage_permission
setup_directories
check_dependencies
display_logo
main_menu
