#!/bin/bash
# Video Master - Created by Masum Vai
# Installer Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Installation directory
INSTALL_DIR="$HOME/videomaster"
GIT_REPO="https://github.com/bdmasumvai/VedioMaster.git"

# Show header
show_header() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════╗"
    echo "║           VIDEO MASTER INSTALLER         ║"
    echo "║             Created by Masum Vai         ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Check if running on Termux
check_termux() {
    if [[ ! -d "/data/data/com.termux" ]]; then
        echo -e "${RED}Error: This script is designed for Termux on Android${NC}"
        echo -e "${YELLOW}Please run this on Termux app${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Termux environment detected${NC}"
}

# Update packages
update_packages() {
    echo -e "${YELLOW}Updating packages...${NC}"
    pkg update -y && pkg upgrade -y
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Packages updated${NC}"
    else
        echo -e "${YELLOW}⚠ Package update completed with warnings${NC}"
    fi
}

# Install dependencies
install_dependencies() {
    echo -e "${YELLOW}Installing dependencies...${NC}"
    
    local deps=("ffmpeg" "git")
    
    for dep in "${deps[@]}"; do
        if pkg install -y "$dep" &> /dev/null; then
            echo -e "${GREEN}✓ Installed: $dep${NC}"
        else
            echo -e "${RED}✗ Failed to install: $dep${NC}"
            return 1
        fi
    done
    return 0
}

# Download Video Master
download_videomaster() {
    echo -e "${YELLOW}Downloading Video Master...${NC}"
    
    if [[ -d "$INSTALL_DIR" ]]; then
        echo -e "${YELLOW}Video Master already exists. Updating...${NC}"
        cd "$INSTALL_DIR"
        if git pull &> /dev/null; then
            echo -e "${GREEN}✓ Updated existing installation${NC}"
        else
            echo -e "${YELLOW}Using existing files${NC}"
        fi
    else
        if git clone "$GIT_REPO" "$INSTALL_DIR" &> /dev/null; then
            echo -e "${GREEN}✓ Downloaded Video Master${NC}"
        else
            echo -e "${RED}✗ Download failed${NC}"
            echo -e "${YELLOW}Creating directory structure...${NC}"
            mkdir -p "$INSTALL_DIR"
            return 1
        fi
    fi
    return 0
}

# Set permissions
set_permissions() {
    echo -e "${YELLOW}Setting permissions...${NC}"
    
    cd "$INSTALL_DIR"
    
    # Make all scripts executable
    chmod +x *.sh 2>/dev/null
    
    # Create symlink for videomaster command
    if [[ -d "$PREFIX/bin" ]]; then
        ln -sf "$INSTALL_DIR/main.sh" "$PREFIX/bin/videomaster" 2>/dev/null
        if [[ -f "$PREFIX/bin/videomaster" ]]; then
            echo -e "${GREEN}✓ Created symlink: videomaster${NC}"
        else
            echo -e "${YELLOW}⚠ Could not create symlink${NC}"
        fi
    fi
    
    # Create termux shortcut
    if [[ -d "$HOME/.shortcuts" ]]; then
        cat > "$HOME/.shortcuts/VideoMaster" << 'EOF'
#!/bin/bash
cd $HOME/videomaster
bash main.sh
EOF
        chmod +x "$HOME/.shortcuts/VideoMaster"
        echo -e "${GREEN}✓ Created Termux shortcut${NC}"
    fi
}

# Setup storage
setup_storage() {
    echo -e "${YELLOW}Setting up storage...${NC}"
    
    if termux-setup-storage &> /dev/null; then
        echo -e "${GREEN}✓ Storage permission granted${NC}"
    else
        echo -e "${YELLOW}⚠ Please grant storage permission manually${NC}"
    fi
}

# Create necessary directories
create_directories() {
    echo -e "${YELLOW}Creating directories...${NC}"
    
    mkdir -p "$INSTALL_DIR/input" "$INSTALL_DIR/output" "$INSTALL_DIR/temp" "$INSTALL_DIR/logs"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Directories created${NC}"
    else
        echo -e "${YELLOW}⚠ Directory creation completed with warnings${NC}"
    fi
}

# Verify installation
verify_installation() {
    echo -e "${YELLOW}Verifying installation...${NC}"
    
    cd "$INSTALL_DIR"
    
    local missing_files=()
    local required_files=("main.sh" "config.sh" "utils.sh" "menus.sh" "compression.sh" "conversion.sh")
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        echo -e "${RED}✗ Missing files: ${missing_files[*]}${NC}"
        return 1
    fi
    
    if ! command -v ffmpeg &> /dev/null; then
        echo -e "${RED}✗ FFmpeg not found${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ Installation verified${NC}"
    return 0
}

# Setup videomaster command
setup_videomaster_command() {
    echo -e "${YELLOW}Setting up 'videomaster' command...${NC}"
    
    # Remove existing symlink if any
    rm -f $PREFIX/bin/videomaster 2>/dev/null
    
    # Create new symlink
    ln -sf $INSTALL_DIR/main.sh $PREFIX/bin/videomaster 2>/dev/null
    chmod +x $PREFIX/bin/videomaster 2>/dev/null
    
    # Create alias in bashrc
    if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -q "alias videomaster" "$HOME/.bashrc"; then
            echo "alias videomaster='cd ~/videomaster && bash main.sh'" >> "$HOME/.bashrc"
        fi
    fi
    
    # Verify
    if [[ -f "$PREFIX/bin/videomaster" ]] || command -v videomaster &> /dev/null; then
        echo -e "${GREEN}✓ 'videomaster' command installed successfully${NC}"
    else
        echo -e "${YELLOW}⚠ 'videomaster' command may not work. Use: cd ~/videomaster && bash main.sh${NC}"
    fi
}

# Show success message
show_success() {
    show_header
    echo -e "${GREEN}🎉 Video Master installed successfully!${NC}"
    echo
    echo -e "${CYAN}Quick Start:${NC}"
    echo -e "1. ${YELLOW}videomaster${NC} - Run Video Master"
    echo -e "2. ${YELLOW}cd ~/videomaster && bash main.sh${NC} - Manual run"
    echo
    echo -e "${GREEN}Usage:${NC}"
    echo -e "• Place videos in: ~/videomaster/input or current directory"
    echo -e "• Processed files in: ~/videomaster/output"
    echo
    echo -e "${CYAN}Features:${NC}"
    echo "• Video Compression"
    echo "• Format Conversion" 
    echo "• Watermark Addition"
    echo "• Noise Removal"
    echo "• Video Information"
    echo
    echo -e "${YELLOW}Support:${NC}"
    echo -e "GitHub: $GIT_REPO"
    echo -e "Developer: Masum Vai"
    echo
    echo -e "${GREEN}Enjoy using Video Master! 🚀${NC}"
}

# Main installation function
main_install() {
    show_header
    check_termux
    update_packages
    install_dependencies
    download_videomaster
    set_permissions
    setup_storage
    create_directories
    setup_videomaster_command
    
    if verify_installation; then
        show_success
    else
        echo -e "${YELLOW}Installation completed with warnings${NC}"
        echo -e "${YELLOW}Some features might not work properly${NC}"
        echo -e "${CYAN}You can still run: cd ~/videomaster && bash main.sh${NC}"
    fi
}

# Run installation
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_install
fi
