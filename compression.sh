#!/bin/bash
# Video Master - Created by Masum Vai
# Compression Functions

# Main compression function
compress_video() {
    local preset="$1"
    
    echo -e "${CYAN}Video Compression - ${preset^^}${NC}"
    echo
    
    # List video files
    if ! list_video_files; then
        return 1
    fi
    
    read -p "Enter video file name: " video_file
    
    if [[ ! -f "$video_file" ]]; then
        show_error "File not found: $video_file"
        return 1
    fi
    
    if ! validate_video_file "$video_file"; then
        return 1
    fi
    
    local output_file="${video_file%.*}_${preset}.mp4"
    
    case $preset in
        "standard")
            compress_standard "$video_file" "$output_file"
            ;;
        "mobile")
            compress_mobile "$video_file" "$output_file"
            ;;
        "web")
            compress_web "$video_file" "$output_file"
            ;;
        "extreme")
            compress_extreme "$video_file" "$output_file"
            ;;
        *)
            show_error "Unknown compression preset"
            return 1
            ;;
    esac
    
    if [[ $? -eq 0 && -f "$output_file" ]]; then
        show_file_comparison "$video_file" "$output_file"
    fi
}

# Standard compression
compress_standard() {
    local input="$1"
    local output="$2"
    
    show_info "Starting standard compression..."
    echo -e "${YELLOW}This may take a while depending on video size...${NC}"
    
    if $FFMPEG_CMD -i "$input" \
        -c:v libx264 -crf 23 -preset medium \
        -c:a aac -b:a 128k \
        "$output"; then
        show_success "Standard compression completed: $output"
    else
        show_error "Standard compression failed"
        return 1
    fi
}

# Mobile compression
compress_mobile() {
    local input="$1"
    local output="$2"
    
    show_info "Starting mobile optimization..."
    echo -e "${YELLOW}Optimizing for mobile devices...${NC}"
    
    if $FFMPEG_CMD -i "$input" \
        -vf "scale=720:-2" \
        -c:v libx264 -crf 25 -preset fast \
        -c:a aac -b:a 96k \
        "$output"; then
        show_success "Mobile optimization completed: $output"
    else
        show_error "Mobile optimization failed"
        return 1
    fi
}

# Web compression
compress_web() {
    local input="$1"
    local output="$2"
    
    show_info "Starting web optimization..."
    echo -e "${YELLOW}Optimizing for web streaming...${NC}"
    
    if $FFMPEG_CMD -i "$input" \
        -vf "scale=480:-2" \
        -c:v libx264 -crf 27 -preset veryfast \
        -c:a aac -b:a 64k \
        "$output"; then
        show_success "Web optimization completed: $output"
    else
        show_error "Web optimization failed"
        return 1
    fi
}

# Extreme compression
compress_extreme() {
    local input="$1"
    local output="$2"
    
    show_info "Starting extreme compression..."
    echo -e "${YELLOW}Maximum compression - may reduce quality...${NC}"
    
    if $FFMPEG_CMD -i "$input" \
        -vf "scale=360:-2" \
        -c:v libx264 -crf 32 -preset ultrafast \
        -c:a aac -b:a 48k \
        "$output"; then
        show_success "Extreme compression completed: $output"
    else
        show_error "Extreme compression failed"
        return 1
    fi
}

# Show file comparison
show_file_comparison() {
    local original="$1"
    local compressed="$2"
    
    if [[ ! -f "$original" || ! -f "$compressed" ]]; then
        show_error "Cannot compare files - one or both files missing"
        return 1
    fi
    
    local original_size=$(get_file_size "$original")
    local compressed_size=$(get_file_size "$compressed")
    
    echo
    echo -e "${WHITE}File Size Comparison:${NC}"
    echo -e "Original:  $(format_file_size $original_size)"
    echo -e "Compressed: $(format_file_size $compressed_size)"
    
    if (( original_size > 0 )); then
        local reduction=$((100 - (compressed_size * 100 / original_size)))
        echo -e "Reduction:  ${GREEN}$reduction%${NC}"
    fi
}

# Show compression info
show_compression_info() {
    echo -e "${YELLOW}Compression Presets Info:${NC}"
    echo
    echo -e "${GREEN}Standard (CRF 23):${NC}"
    echo "• Best quality with good compression"
    echo "• Balanced for most uses"
    echo "• Recommended for general purpose"
    echo
    echo -e "${CYAN}Mobile (720p, CRF 25):${NC}"
    echo "• Optimized for mobile devices"
    echo "• 1280x720 resolution"
    echo "• Good for smartphones and tablets"
    echo
    echo -e "${BLUE}Web (480p, CRF 27):${NC}"
    echo "• Optimized for web streaming"
    echo "• 854x480 resolution"
    echo "• Fast loading for websites"
    echo
    echo -e "${RED}Extreme (360p, CRF 32):${NC}"
    echo "• Maximum compression"
    echo "• Smallest file size"
    echo "• Lower quality - use when size matters most"
    echo
    echo -e "${WHITE}Note: CRF = Constant Rate Factor${NC}"
    echo "Lower CRF = Better quality, Larger file"
    echo "Higher CRF = Lower quality, Smaller file"
    echo
    read -p "Press Enter to continue..."
}
