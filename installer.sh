#!/bin/bash

# installer.sh for VideoMaster Pro
# Developer: Masum Vai BD
# Telegram: https://t.me/MasumVaiBD
# GitHub: github.com/bdmasumvai
# Installer Version: 1.4.2
# Purpose: Fully automated installer using git clone with animations

# Configuration
INSTALLER_VERSION="1.4.2"
TOOL_NAME="VideoMaster Pro"
SCRIPT_VERSION="3.3.1"
INSTALL_DIR="/data/data/com.termux/files/usr/bin"
SCRIPT_NAME="videomaster"
REPO_URL="https://github.com/bdmasumvai/VedioMaster.git"
CLONE_DIR="$HOME/videomaster_temp"
HIDDEN_DIR="/sdcard/videomaster/.MasumVault"
LOG_FILE="$HIDDEN_DIR/setup.log"
OLD_LOG_FILE="$HOME/videomaster_setup.log"

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
NC='\033[0m'

# Spinner colors
SPINNER_COLORS=('\033[1;36m' '\033[1;33m' '\033[1;32m' '\033[1;35m' '\033[1;34m')

# Global variable to control live processing output
SHOW_PROCESSING="false"

# Get random spinner color
get_random_spinner_color() {
    echo "${SPINNER_COLORS[$RANDOM % ${#SPINNER_COLORS[@]}]}"
}

# Initialize log
log_message() {
    local message="$1"
    if touch "$LOG_FILE" 2>/dev/null; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE" 2>/dev/null || echo -e "${YELLOW}Warning: Failed to write to $LOG_FILE${NC}" >&2
    else
        echo -e "${YELLOW}Warning: Cannot create $LOG_FILE, logging to stderr${NC}" >&2
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >&2
    fi
}

# Show animated logo
show_logo() {
    clear
    echo -e "${CYAN}"
    echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo "┃ ██╗   ██╗██╗██████╗ ███████╗ ██████╗"
    echo "┃ ██║   ██║██║██╔══██╗██╔════╝██╔═══██╗"
    echo "┃ ██║   ██║██║██║  ██║█████╗  ██║   ██║"
    echo "┃ ╚██╗ ██╔╝██║██║  ██║██╔══╝  ██║   ██║"
    echo "┃  ╚████╔╝ ██║██████╔╝███████╗╚██████╔╝"
    echo "┃   ╚═══╝  ╚═╝╚═════╝ ╚══════╝ ╚═════╝ "
    echo "┠──────────────────────────────────────┨"
    echo "┃ $TOOL_NAME Installer v$INSTALLER_VERSION     "
    echo "┃ by Masum Vai BD                        "
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    echo -e "${NC}"
    local animation=("★" "✦" "✧" "✨" "◉" "●" "○" "◌" "◈" "◆" "◇" "■" "□" "▲" "▼" "▶" "◀" "➤" "➔" "→" "←" "↑" "↓" "✽" "❖" "✿" "❀" "❁" "♠" "♣" "♥" "♦" "♤" "♡" "♢" "♧" "⚡" "☀" "☁" "☂" "☄" "★" "☆" "✪" "✫" "✬" "✯" "✰" "✴" "✵" "✹")
    for i in {1..20}; do
        local color=$(get_random_spinner_color)
        echo -en "\r${YELLOW}Initializing... ${color}${animation[$((i % ${#animation[@]}))]}${NC}"
        sleep 0.05
    done
    echo -e "\r${GREEN}Initialization complete!          ${NC}"
    log_message "Initialized installer"
    sleep 1
}

# Draw boxed UI
draw_box() {
    local title="$1"
    echo -e "${CYAN}"
    echo "┌──────────────────────────────────────┐"
    echo "│ ${title^} "
    echo "└──────────────────────────────────────┘"
    echo -e "${NC}"
}

# Ask user for live processing output preference
ask_live_processing() {
    draw_box "Live Processing Preference Logs"
    echo -ne "${YELLOW}Do you want to see processing output Logs? [Y/n]: ${NC}"
    read choice
    choice=${choice:-Y}
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        SHOW_PROCESSING="true"
        echo -e "${GREEN}Live processing output will be shown.${NC}"
        log_message "Live processing output enabled"
    else
        SHOW_PROCESSING="false"
        echo -e "${GREEN}Live processing output Logs will be hidden.${NC}"
        log_message "Live processing output disabled"
    fi
    sleep 1
}

# Remove previous installation
remove_previous() {
    draw_box "Removing Previous Installation"
    if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        echo -e "${YELLOW}Removing old $SCRIPT_NAME...${NC}"
        if rm -f "$INSTALL_DIR/$SCRIPT_NAME"; then
            echo -e "${GREEN}Old installation removed!${NC}"
            log_message "Removed old $SCRIPT_NAME"
        else
            echo -e "${RED}Failed to remove old $SCRIPT_NAME! Check permissions.${NC}"
            log_message "Failed to remove old $SCRIPT_NAME"
            exit 1
        fi
    else
        echo -e "${GREEN}No previous installation found!${NC}"
        log_message "No previous $SCRIPT_NAME found"
    fi
    if [ -d "$HOME/.videomaster" ]; then
        echo -e "${YELLOW}Removing old config/logs...${NC}"
        if rm -rf "$HOME/.videomaster"; then
            echo -e "${GREEN}Old config/logs removed!${NC}"
            log_message "Removed old config/logs"
        else
            echo -e "${RED}Failed to remove config/logs!${NC}"
            log_message "Failed to remove config/logs"
        fi
    fi
    if [ -f "$OLD_LOG_FILE" ]; then
        echo -e "${YELLOW}Removing old setup log...${NC}"
        if rm -f "$OLD_LOG_FILE"; then
            echo -e "${GREEN}Old setup log removed!${NC}"
            log_message "Removed old setup log at $OLD_LOG_FILE"
        else
            echo -e "${RED}Failed to remove old setup log!${NC}"
            log_message "Failed to remove old setup log at $OLD_LOG_FILE"
        fi
    fi
    if [ -d "$CLONE_DIR" ]; then
        echo -e "${YELLOW}Removing old clone directory...${NC}"
        rm -rf "$CLONE_DIR"
        echo -e "${GREEN}Old clone directory removed!${NC}"
        log_message "Removed old clone directory"
    fi
    sleep 1
}

# Update and upgrade packages
update_packages() {
    draw_box "Update and Upgrade Packages"
    echo -ne "${YELLOW}Do you want to update and upgrade packages? [Y/n]: ${NC}"
    read choice
    choice=${choice:-Y}
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Running pkg update...${NC}"
        local animation=("★" "✦" "✧" "✨" "◉" "●" "○" "◌" "◈" "◆" "◇" "■" "□" "▲" "▼" "▶" "◀" "➤" "➔" "→" "←" "↑" "↓" "✽" "❖" "✿" "❀" "❁" "♠" "♣" "♥" "♦" "♤" "♡" "♢" "♧" "⚡" "☀" "☁" "☂" "☄" "★" "☆" "✪" "✫" "✬" "✯" "✰" "✴" "✵" "✹")
        if [ "$SHOW_PROCESSING" = "true" ]; then
            pkg update -y
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Package update complete!${NC}"
                log_message "Package update successful"
            else
                echo -e "${RED}Failed to update packages! Check network.${NC}"
                log_message "Failed to update packages"
                exit 1
            fi
        else
            (pkg update -y > /dev/null 2>&1) &
            local pid=$!
            local i=0
            while kill -0 $pid 2>/dev/null; do
                local color=$(get_random_spinner_color)
                echo -en "\r${YELLOW}Updating... ${color}${animation[$((i % ${#animation[@]}))]}${NC}"
                sleep 0.05
            done
            wait $pid
            if [ $? -eq 0 ]; then
                echo -e "\r${GREEN}Package update complete!          ${NC}"
                log_message "Package update successful"
            else
                echo -e "\r${RED}Failed to update packages! Check network.${NC}"
                log_message "Failed to update packages"
                exit 1
            fi
        fi
        echo -e "${YELLOW}Running pkg upgrade...${NC}"
        if [ "$SHOW_PROCESSING" = "true" ]; then
            pkg upgrade -y
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Package upgrade complete!${NC}"
                log_message "Package upgrade successful"
            else
                echo -e "${RED}Failed to upgrade packages! Check network.${NC}"
                log_message "Failed to upgrade packages"
                exit 1
            fi
        else
            (pkg upgrade -y > /dev/null 2>&1) &
            local pid=$!
            local i=0
            while kill -0 $pid 2>/dev/null; do
                local color=$(get_random_spinner_color)
                echo -en "\r${YELLOW}Upgrading... ${color}${animation[$((i % ${#animation[@]}))]}${NC}"
                sleep 0.05
            done
            wait $pid
            if [ $? -eq 0 ]; then
                echo -e "\r${GREEN}Package upgrade complete!          ${NC}"
                log_message "Package upgrade successful"
            else
                echo -e "\r${RED}Failed to upgrade packages! Check network.${NC}"
                log_message "Failed to upgrade packages"
                exit 1
            fi
        fi
    else
        echo -e "${GREEN}Skipping package update and upgrade...${NC}"
        log_message "Skipped package update and upgrade"
    fi
    sleep 1
}

# Install dependencies
install_dependencies() {
    draw_box "Installing Dependencies"
    local deps=("ffmpeg" "curl" "git" "ffprobe")
    for dep in "${deps[@]}"; do
        echo -e "${YELLOW}Checking $dep...${NC}"
        if ! command -v "$dep" > /dev/null 2>&1; then
            echo -e "${YELLOW}Installing $dep...${NC}"
            local animation=("★" "✦" "✧" "✨" "◉" "●" "○" "◌" "◈" "◆" "◇" "■" "□" "▲" "▼" "▶" "◀" "➤" "➔" "→" "←" "↑" "↓" "✽" "❖" "✿" "❀" "❁" "♠" "♣" "♥" "♦" "♤" "♡" "♢" "♧" "⚡" "☀" "☁" "☂" "☄" "★" "☆" "✪" "✫" "✬" "✯" "✰" "✴" "✵" "✹")
            if [ "$SHOW_PROCESSING" = "true" ]; then
                pkg install -y "$dep"
                if command -v "$dep" > /dev/null 2>&1; then
                    echo -e "${GREEN}$dep installed successfully!${NC}"
                    log_message "$dep installed"
                else
                    echo -e "${RED}Failed to install $dep! Run 'pkg install $dep' manually.${NC}"
                    echo -e "${YELLOW}1. Run: pkg install $dep"
                    echo -e "${YELLOW}2. Try running the installer again.${NC}"
                    log_message "Failed to install $dep"
                    exit 1
                fi
            else
                (pkg install -y "$dep" > /dev/null 2>&1) &
                local pid=$!
                local i=0
                while kill -0 $pid 2>/dev/null; do
                    local color=$(get_random_spinner_color)
                    echo -en "\r${YELLOW}Installing $dep... ${color}${animation[$((i % ${#animation[@]}))]}${NC}"
                    sleep 0.05
                done
                wait $pid
                if command -v "$dep" > /dev/null 2>&1; then
                    echo -e "\r${GREEN}$dep installed successfully!          ${NC}"
                    log_message "$dep installed"
                else
                    echo -e "\r${RED}Failed to install $dep! Run 'pkg install $dep' manually.${NC}"
                    echo -e "${YELLOW}1. Run: pkg install $dep"
                    echo -e "${YELLOW}2. Try running the installer again.${NC}"
                    log_message "Failed to install $dep"
                    exit 1
                fi
            fi
        else
            echo -e "${GREEN}$dep already installed!${NC}"
            log_message "$dep already installed"
        fi
    done
    sleep 1
}

# Setup storage permission
setup_storage() {
    draw_box "Setting Up Storage Permission"
    echo -e "${YELLOW}Checking storage permission...${NC}"
    if ! [ -d "/sdcard" ] || ! touch "/sdcard/test.txt" 2>/dev/null; then
        echo -e "${YELLOW}Setting up storage access...${NC}"
        local animation=("★" "✦" "✧" "✨" "◉" "●" "○" "◌" "◈" "◆" "◇" "■" "□" "▲" "▼" "▶" "◀" "➤" "➔" "→" "←" "↑" "↓" "✽" "❖" "✿" "❀" "❁" "♠" "♣" "♥" "♦" "♤" "♡" "♢" "♧" "⚡" "☀" "☁" "☂" "☄" "★" "☆" "✪" "✫" "✬" "✯" "✰" "✴" "✵" "✹")
        if [ "$SHOW_PROCESSING" = "true" ]; then
            termux-setup-storage
            if [ -d "/sdcard" ] && touch "/sdcard/test.txt" 2>/dev/null; then
                rm -f "/sdcard/test.txt"
                echo -e "${GREEN}Storage permission granted!${NC}"
                log_message "Storage permission granted"
            else
                echo -e "${RED}Failed to setup storage!${NC}"
                echo -e "${YELLOW}1. Run: termux-setup-storage"
                echo -e "${YELLOW}2. Allow storage permission in Termux settings."
                echo -e "${YELLOW}3. Run the installer again.${NC}"
                log_message "Failed to setup storage"
                exit 1
            fi
        else
            (termux-setup-storage > /dev/null 2>&1) &
            local pid=$!
            local i=0
            while kill -0 $pid 2>/dev/null; do
                local color=$(get_random_spinner_color)
                echo -en "\r${YELLOW}Setting up storage... ${color}${animation[$((i % ${#animation[@]}))]}${NC}"
                sleep 0.05
            done
            wait $pid
            if [ -d "/sdcard" ] && touch "/sdcard/test.txt" 2>/dev/null; then
                rm -f "/sdcard/test.txt"
                echo -e "\r${GREEN}Storage permission granted!          ${NC}"
                log_message "Storage permission granted"
            else
                echo -e "\r${RED}Failed to setup storage!${NC}"
                echo -e "${YELLOW}1. Run: termux-setup-storage"
                echo -e "${YELLOW}2. Allow storage permission in Termux settings."
                echo -e "${YELLOW}3. Run the installer again.${NC}"
                log_message "Failed to setup storage"
                exit 1
            fi
        fi
    else
        rm -f "/sdcard/test.txt" 2>/dev/null
        echo -e "${GREEN}Storage access already granted!${NC}"
        log_message "Storage access already granted"
    fi
    echo -e "${YELLOW}Creating output directory...${NC}"
    if mkdir -p "/sdcard/VideoMaster"; then
        echo -e "${GREEN}Output directory created: /sdcard/VideoMaster${NC}"
        log_message "Created output directory /sdcard/VideoMaster"
    else
        echo -e "${RED}Failed to create /sdcard/VideoMaster! Check permissions.${NC}"
        echo -e "${YELLOW}1. Run: termux-setup-storage"
        echo -e "${YELLOW}2. Allow storage permission in Termux settings."
        echo -e "${YELLOW}3. Run the installer again.${NC}"
        log_message "Failed to create /sdcard/VideoMaster"
        exit 1
    fi
    echo -e "${YELLOW}Creating hidden directory...${NC}"
    if mkdir -p "$HIDDEN_DIR"; then
        echo -e "${GREEN}Hidde
n directory created: $HIDDEN_DIR${NC}"
        log_message "Created hidden directory $HIDDEN_DIR"
    else
        echo -e "${RED}Failed to create $HIDDEN_DIR! Check permissions.${NC}"
        echo -e "${YELLOW}1. Run: termux-setup-storage"
        echo -e "${YELLOW}2. Allow storage permission in Termux settings."
        echo -e "${YELLOW}3. Run the installer again.${NC}"
        log_message "Failed to create $HIDDEN_DIR"
        exit 1
    fi
    sleep 1
}

# Clone repository and install VideoMaster
install_videomaster() {
    draw_box "Installing VideoMaster"
    echo -e "${YELLOW}Cloning repository...${NC}"
    local animation=("★" "✦" "✧" "✨" "◉" "●" "○" "◌" "◈" "◆" "◇" "■" "□" "▲" "▼" "▶" "◀" "➤" "➔" "→" "←" "↑" "↓" "✽" "❖" "✿" "❀" "❁" "♠" "♣" "♥" "♦" "♤" "♡" "♢" "♧" "⚡" "☀" "☁" "☂" "☄" "★" "☆" "✪" "✫" "✬" "✯" "✰" "✴" "✵" "✹")
    if [ -d "$CLONE_DIR" ]; then
        rm -rf "$CLONE_DIR"
    fi
    if [ "$SHOW_PROCESSING" = "true" ]; then
        git clone "$REPO_URL" "$CLONE_DIR"
        if [ $? -eq 0 ] && [ -f "$CLONE_DIR/main.sh" ]; then
            echo -e "${GREEN}Repository cloned successfully!${NC}"
            log_message "Cloned repository from $REPO_URL"
        else
            echo -e "${RED}Failed to clone repository!${NC}"
            echo -e "${YELLOW}1. Check your internet connection."
            echo -e "${YELLOW}2. Verify the repository URL: $REPO_URL"
            echo -e "${YELLOW}3. Run the installer again.${NC}"
            echo -e "${YELLOW}Debug log: $LOG_FILE${NC}"
            log_message "Failed to clone repository"
            exit 1
        fi
    else
        (git clone "$REPO_URL" "$CLONE_DIR" > /dev/null 2>&1) &
        local pid=$!
        local i=0
        while kill -0 $pid 2>/dev/null; do
            local color=$(get_random_spinner_color)
            echo -en "\r${YELLOW}Cloning... ${color}${animation[$((i % ${#animation[@]}))]}${NC}"
            sleep 0.05
        done
        wait $pid
        if [ $? -eq 0 ] && [ -f "$CLONE_DIR/main.sh" ]; then
            echo -e "\r${GREEN}Repository cloned successfully!          ${NC}"
            log_message "Cloned repository from $REPO_URL"
        else
            echo -e "\r${RED}Failed to clone repository!${NC}"
            echo -e "${YELLOW}1. Check your internet connection."
            echo -e "${YELLOW}2. Verify the repository URL: $REPO_URL"
            echo -e "${YELLOW}3. Run the installer again.${NC}"
            echo -e "${YELLOW}Debug log: $LOG_FILE${NC}"
            log_message "Failed to clone repository"
            exit 1
        fi
    fi
    echo -e "${YELLOW}Installing VideoMaster files...${NC}"
    # Create installation directory
    local videomaster_dir="$HOME/.videomaster"
    if [ -d "$videomaster_dir" ]; then
        rm -rf "$videomaster_dir"
    fi
    mkdir -p "$videomaster_dir"
    # Copy all modular files
    local files=("main.sh" "config.sh" "init.sh" "utils.sh" "display.sh" "menus.sh" "compression.sh" "watermark.sh" "conversion.sh" "noise.sh")
    for file in "${files[@]}"; do
        if [ -f "$CLONE_DIR/$file" ]; then
            if cp "$CLONE_DIR/$file" "$videomaster_dir/$file"; then
                chmod +x "$videomaster_dir/$file"
                echo -e "${GREEN}Installed $file to $videomaster_dir/$file${NC}"
                log_message "Installed $file to $videomaster_dir/$file"
            else
                echo -e "${RED}Failed to install $file!${NC}"
                log_message "Failed to install $file"
                exit 1
            fi
        else
            echo -e "${RED}File $file not found in repository!${NC}"
            log_message "File $file not found in repository"
            exit 1
        fi
    done
    # Create launcher script
    cat > "$INSTALL_DIR/$SCRIPT_NAME" << EOL
#!/bin/bash
bash "$videomaster_dir/main.sh"
EOL
    if [ $? -eq 0 ]; then
        chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
        echo -e "${GREEN}Launcher script created at $INSTALL_DIR/$SCRIPT_NAME${NC}"
        log_message "Created launcher script at $INSTALL_DIR/$SCRIPT_NAME"
    else
        echo -e "${RED}Failed to create launcher script!${NC}"
        log_message "Failed to create launcher script"
        exit 1
    fi
    # Clean up
    if [ -d "$CLONE_DIR" ]; then
        rm -rf "$CLONE_DIR"
        log_message "Cleaned up clone directory"
    fi
    sleep 1
}

# Verify installation
verify_installation() {
    draw_box "Verifying Installation"
    local videomaster_dir="$HOME/.videomaster"
    local files=("main.sh" "config.sh" "init.sh" "utils.sh" "display.sh" "menus.sh" "compression.sh" "watermark.sh" "conversion.sh" "noise.sh")
    local all_files_present=true
    for file in "${files[@]}"; do
        if [ ! -f "$videomaster_dir/$file" ]; then
            echo -e "${RED}File $file not found in $videomaster_dir!${NC}"
            log_message "File $file not found in $videomaster_dir"
            all_files_present=false
        fi
    done
    if [ "$all_files_present" = "true" ] && [ -f "$INSTALL_DIR/$SCRIPT_NAME" ] && [ -x "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        echo -e "${GREEN}VideoMaster v$SCRIPT_VERSION installed successfully!${NC}"
        echo -e "${YELLOW}Run it using: ${CYAN}videomaster${NC}"
        log_message "Installation verified"
    else
        echo -e "${RED}Installation failed!${NC}"
        echo -e "${YELLOW}Debug log: $LOG_FILE${NC}"
        log_message "Installation verification failed"
        exit 1
    fi
    sleep 1
}

# Show installation log
show_installation_log() {
    echo -ne "${YELLOW}Do you want to see the installation processing log? [Y/n]: ${NC}"
    read choice
    choice=${choice:-Y}
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        draw_box "Installation Log"
        if [ -f "$LOG_FILE" ]; then
            echo -e "${CYAN}Showing last 20 lines of $LOG_FILE:${NC}"
            tail -n 20 "$LOG_FILE"
            echo -e "${YELLOW}Full log available at: $LOG_FILE${NC}"
        else
            echo -e "${RED}Log file not found at $LOG_FILE!${NC}"
        fi
    else
        echo -e "${GREEN}Skipping installation log display...${NC}"
        echo -e "${YELLOW}Log available at: $LOG_FILE${NC}"
    fi
    sleep 1
}

# Main setup process
main() {
    show_logo
    echo -e "${YELLOW}Starting $TOOL_NAME setup v$INSTALLER_VERSION...${NC}"
    log_message "Started setup v$INSTALLER_VERSION"
    sleep 1
    ask_live_processing
    remove_previous
    update_packages
    install_dependencies
    setup_storage
    install_videomaster
    verify_installation
    show_installation_log
    show_logo
    echo -e "${GREEN}Setup completed successfully!${NC}"
    echo -e "${CYAN}Run VideoMaster by typing: ${YELLOW}videomaster${NC}"
    echo -e "${CYAN}Contact: @MasumVaiBD | github.com/bdmasumvai${NC}"
    log_message "Setup completed successfully"
}

# Execute main
main
