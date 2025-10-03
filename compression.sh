#!/bin/bash
# Video Master - Created by Masum Vai
# Compression Functions

# Main compression function
compress_video() {
    local preset="$1"
    
    echo -e "${CYAN}Video Compression - ${preset^^}${NC}"
    echo
    
    # List video files
    list_video_files
    
    read -p "Enter video file name: " video_file
    
    if ! validate_video_file "$video_file"; then
        return 1
    fi
    
    local output_file=$(generate_output_filename "$video_file" "$preset" "mp4")
    
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
    
    if [[ $? -eq 0 ]]; then
        show_file_comparison "$video_file" "$output_file"
    fi
}

# Standard compression
compress_standard() {
    local input="$1"
    local output="$2"
    
    show_info "Starting standard compression..."
    
    $FFMPEG_CMD -i "$input" \
        -c:v libx264 -crf 23 -preset medium \
        -c:a aac -b:a 128k \
        "$output"
    
    if [[ $? -eq 0 ]]; then
        show_success "Standard compression completed"
    else
        show_error "Compression failed"
        return 1
    fi
}

# Mobile compression
compress_mobile() {
    local input="$1"
    local output="$2"
    
    show_info "Starting mobile optimization..."
    
    $FFMPEG_CMD -i "$input" \
        -vf "scale=720:-2" \
        -c:v libx264 -crf 25 -preset fast \
        -c:a aac -b:a 96k \
        "$output"
    
    if [[ $? -eq 0 ]]; then
        show_success "Mobile optimization completed"
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
    
    $FFMPEG_CMD -i "$input" \
        -vf "scale=480:-2" \
        -c:v libx264 -crf 27 -preset veryfast \
        -c:a aac -b:a 64k \
        "$output"
    
    if [[ $? -eq 0 ]]; then
        show_success "Web optimization completed"
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
    
    $FFMPEG_CMD -i "$input" \
        -vf "scale=360:-2" \
        -c:v libx264 -crf 32 -preset ultrafast \
        -c:a aac -b:a 48k \
        "$output"
    
    if [[ $? -eq 0 ]]; then
        show_success "Extreme compression completed"
    else
        show_error "Extreme compression failed"
        return 1
    fi
}

# Show compression info
show_compression_info() {
    echo -e "${YELLOW}Compression Presets Info:${NC}"
    echo
    echo -e "${GREEN}Standard (CRF 23):${NC}"
    echo "• Good quality with reasonable file size"
    echo "• Balanced for most uses"
    echo
    echo -e "${CYAN}Mobile (720p, CRF 25):${NC}"
    echo "• Optimized for mobile devices"
    echo "• 1280x720 resolution"
    echo
    echo -e "${BLUE}Web (480p, CRF 27):${NC}"
    echo "• Optimized for web streaming"
    echo "• 854x480 resolution"
    echo
    echo -e "${RED}Extreme (360p, CRF 32):${NC}"
    echo "• Maximum compression"
    echo "• Smallest file size"
    echo
    read -p "Press Enter to continue..."
}

# Compare file sizes
show_file_comparison() {
    local original="$1"
    local compressed="$2"
    
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

# List video files in current directory
list_video_files() {
    local video_files=()
    local count=0
    
    echo -e "${YELLOW}Available video files:${NC}"
    for file in *.{mp4,avi,mkv,mov,webm} 2>/dev/null; do
        if [[ -f "$file" ]]; then
            count=$((count + 1))
            video_files+=("$file")
            local size=$(get_file_size "$file")
            echo -e "${GREEN}$count.${NC} $file - ${CYAN}$(format_file_size $size)${NC}"
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        show_warning "No video files found in current directory"
        echo "Please place video files in: $INPUT_DIR"
        return 1
    fi
    
    echo
    return 0
}
