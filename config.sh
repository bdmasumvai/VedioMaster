#!/bin/bash
# Video Master - Created by Masum Vai
# Configuration File

# App Information
APP_NAME="Video Master"
APP_VERSION="2.0"
AUTHOR="Masum Vai"
GITHUB_URL="https://github.com/bdmasumvai/VedioMaster"

# Directories
BASE_DIR="$HOME/videomaster"
INPUT_DIR="$BASE_DIR/input"
OUTPUT_DIR="$BASE_DIR/output"
TEMP_DIR="$BASE_DIR/temp"
LOG_DIR="$BASE_DIR/logs"

# Files
LOG_FILE="$LOG_DIR/videomaster.log"

# FFmpeg Settings
FFMPEG_CMD="ffmpeg -hide_banner -loglevel error -y"
FFPROBE_CMD="ffprobe -hide_banner -loglevel error"

# Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Supported Formats
SUPPORTED_VIDEO=("mp4" "avi" "mkv" "mov" "webm")
SUPPORTED_AUDIO=("mp3" "m4a" "wav" "aac")

# Setup directories
setup_directories() {
    mkdir -p "$BASE_DIR" "$INPUT_DIR" "$OUTPUT_DIR" "$TEMP_DIR" "$LOG_DIR"
    echo -e "${GREEN}✓ Directories created${NC}"
}

# Check dependencies
check_dependencies() {
    local deps=("ffmpeg" "ffprobe")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}✗ Missing dependencies: ${missing[*]}${NC}"
        echo -e "${YELLOW}Please run: pkg install ffmpeg${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ All dependencies found${NC}"
    fi
}

# Show banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════╗"
    echo "║             🅅🄸🄳🄴🄾 🄼🄰🅂🄴🅁          ║"
    echo "║               VIDEO MASTER               ║"
    echo "║             Created by Masum Vai         ║"
    echo "║                Version $APP_VERSION              ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}
