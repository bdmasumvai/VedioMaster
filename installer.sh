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
    echo -e "${GREEN}✓ Packages updated${NC}"
}

# Install dependencies
install_dependencies() {
    echo -e "${YELLOW}Installing dependencies...${NC}"
    
    local deps=("ffmpeg" "git" "wget")
    
    for dep in "${deps[@]}"; do
        if pkg install -y "$dep" &> /dev/null; then
            echo -e "${GREEN}✓ Installed: $dep${NC}"
        else
            echo -e "${RED}✗ Failed to install: $dep${NC}"
        fi
    done
}

# Clone repository
clone_repo() {
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
            echo -e "${RED}✗ Download failed. Creating manual installation...${NC}"
            create_manual_install
        fi
    fi
}

# Create manual installation
create_manual_install() {
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    echo -e "${YELLOW}Creating manual installation...${NC}"
    
    # This is where you would download files individually
    # For now, we'll just create the directory structure
    mkdir -p input output temp logs
    
    echo -e "${GREEN}✓ Created directory structure${NC}"
    echo -e "${YELLOW}Please manually copy Video Master files to: $INSTALL_DIR${NC}"
}

# Set permissions
set_permissions() {
    echo -e "${YELLOW}Setting permissions...${NC}"
    
    cd "$INSTALL_DIR"
    chmod +x *.sh
    
    # Create symlink in $PREFIX/bin
    if [[ -d "$PREFIX/bin" ]]; then
        ln -sf "$INSTALL_DIR/main.sh" "$PREFIX/bin/videomaster" 2>/dev/null
        echo -e "${GREEN}✓ Created symlink: videomaster${NC}"
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

# Show success message
show_success() {
    show_header
    echo -e "${GREEN}🎉 Video Master installed successfully!${NC}"
    echo
    echo -e "${CYAN}Quick Start:${NC}"
    echo -e "1. ${YELLOW}cd $INSTALL_DIR${NC}"
    echo -e "2. ${YELLOW}bash main.sh${NC}"
    echo -e "3. ${YELLOW}Or run: videomaster${NC}"
    echo
    echo -e "${GREEN}Usage:${NC}"
    echo -e "• Place videos in: $INSTALL_DIR/input"
    echo -e "• Processed files in: $INSTALL_DIR/output"
    echo
    echo -e "${CYAN}Support:${NC}"
    echo -e "GitHub: $GIT_REPO"
    echo -e "Developer: Masum Vai"
    echo
    echo -e "${YELLOW}Enjoy using Video Master! 🚀${NC}"
}

# Main installation function
main_install() {
    show_header
    check_termux
    update_packages
    install_dependencies
    clone_repo
    set_permissions
    setup_storage
    
    if verify_installation; then
        show_success
    else
        echo -e "${RED}Installation completed with warnings${NC}"
        echo -e "${YELLOW}Some features might not work properly${NC}"
    fi
}

# Run installation
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_install
fi
