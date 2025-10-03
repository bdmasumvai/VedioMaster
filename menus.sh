#!/bin/bash
# Video Master - Created by Masum Vai
# Menu System

show_main_menu() {
    clear
    show_banner
    echo -e "${YELLOW}MAIN MENU:${NC}"
    echo -e "1. 📦 ${CYAN}Video Compression${NC}"
    echo -e "2. 🔄 ${GREEN}Format Conversion${NC}"
    echo -e "3. 💧 ${BLUE}Add Watermark${NC}"
    echo -e "4. 🔊 ${PURPLE}Noise Removal${NC}"
    echo -e "5. 📊 ${WHITE}Video Information${NC}"
    echo -e "6. ❓ ${YELLOW}Help & Guide${NC}"
    echo -e "7. ⚙️  ${CYAN}Setup & Update${NC}"
    echo -e "0. 🚪 ${RED}Exit${NC}"
    echo
    read -p "Enter your choice [0-7]: " choice
}

# Compression flow
run_compression() {
    while true; do
        clear
        show_banner
        echo -e "${CYAN}VIDEO COMPRESSION:${NC}"
        echo -e "1. 🎯 Standard Quality (CRF 23)"
        echo -e "2. 📱 Mobile Optimized (720p)"
        echo -e "3. 🌐 Web Optimized (480p)"
        echo -e "4. 💀 Extreme Compression"
        echo -e "5. 📊 Compare File Sizes"
        echo -e "6. ↩️  Back to Main Menu"
        echo
        read -p "Select compression type: " comp_choice
        
        case $comp_choice in
            1) compress_video "standard" ;;
            2) compress_video "mobile" ;;
            3) compress_video "web" ;;
            4) compress_video "extreme" ;;
            5) show_compression_info ;;
            6) return ;;
            *) show_error "Please select 1-6" ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

# Conversion flow
run_conversion() {
    while true; do
        clear
        show_banner
        echo -e "${GREEN}FORMAT CONVERSION:${NC}"
        echo -e "1. 🎵 Extract Audio (MP4 → MP3)"
        echo -e "2. 🎞️  Create GIF (MP4 → GIF)"
        echo -e "3. 🔄 AVI to MP4"
        echo -e "4. 📦 MKV to MP4"
        echo -e "5. 🌐 WEBM to MP4"
        echo -e "6. 🎬 Multiple Format Conversion"
        echo -e "7. ↩️  Back to Main Menu"
        echo
        read -p "Select conversion type: " conv_choice
        
        case $conv_choice in
            1) convert_to_audio ;;
            2) convert_to_gif ;;
            3) convert_avi_to_mp4 ;;
            4) convert_mkv_to_mp4 ;;
            5) convert_webm_to_mp4 ;;
            6) batch_convert ;;
            7) return ;;
            *) show_error "Please select 1-7" ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

# Watermark flow
run_watermark() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}WATERMARK TOOLS:${NC}"
        echo -e "1. 📝 Add Text Watermark"
        echo -e "2. 🖼️  Add Image Watermark"
        echo -e "3. 🎨 Custom Watermark Position"
        echo -e "4. 🔍 Preview Watermark"
        echo -e "5. ↩️  Back to Main Menu"
        echo
        read -p "Select watermark type: " watermark_choice
        
        case $watermark_choice in
            1) add_text_watermark ;;
            2) add_image_watermark ;;
            3) add_custom_watermark ;;
            4) preview_watermark ;;
            5) return ;;
            *) show_error "Please select 1-5" ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

# Noise removal flow
run_noise_removal() {
    clear
    show_banner
    echo -e "${PURPLE}NOISE REMOVAL:${NC}"
    remove_video_noise
    read -p "Press Enter to continue..."
}

# Video info flow
run_video_info() {
    clear
    show_banner
    echo -e "${WHITE}VIDEO INFORMATION:${NC}"
    show_detailed_video_info
    read -p "Press Enter to continue..."
}

# Help section
show_help() {
    clear
    show_banner
    echo -e "${YELLOW}VIDEO MASTER HELP:${NC}"
    echo
    echo -e "${CYAN}📖 HOW TO USE:${NC}"
    echo "1. Place your video files in current directory"
    echo "2. Select your desired operation from menu"
    echo "3. Processed files will be in: $OUTPUT_DIR"
    echo
    echo -e "${GREEN}📁 SUPPORTED FORMATS:${NC}"
    echo "• Input: MP4, AVI, MKV, MOV, WEBM"
    echo "• Output: MP4, MP3, GIF, M4A"
    echo
    echo -e "${BLUE}🛠️ REQUIREMENTS:${NC}"
    echo "• Termux app"
    echo "• FFmpeg package"
    echo "• Storage permission"
    echo
    echo -e "${PURPLE}👨‍💻 DEVELOPER:${NC}"
    echo "• Name: Masum Vai"
    echo "• GitHub: bdmasumvai"
    echo "• Project: Video Master"
    echo
    read -p "Press Enter to return to main menu..."
}

# Setup flow
run_setup() {
    clear
    show_banner
    echo -e "${CYAN}SETUP & UPDATES:${NC}"
    setup_directories
    check_dependencies
    show_success "System setup completed successfully!"
    echo
    echo -e "${GREEN}✓ All directories created${NC}"
    echo -e "${GREEN}✓ Dependencies checked${NC}"
    echo -e "${GREEN}✓ System ready to use${NC}"
    echo
    read -p "Press Enter to continue..."
}
