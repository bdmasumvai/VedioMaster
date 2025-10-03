#!/bin/bash
# Video Master - Created by Masum Vai
# Conversion Functions

# Convert to MP3
convert_to_audio() {
    echo -e "${GREEN}Extract Audio from Video${NC}"
    
    list_video_files || return 1
    
    read -p "Enter video file name: " video_file
    
    if ! validate_video_file "$video_file"; then
        return 1
    fi
    
    local output_file=$(generate_output_filename "$video_file" "audio" "mp3")
    
    show_info "Extracting audio..."
    
    $FFMPEG_CMD -i "$video_file" \
        -q:a 0 -map a \
        "$output_file"
    
    if [[ $? -eq 0 ]]; then
        show_success "Audio extraction completed: $(basename "$output_file")"
    else
        show_error "Audio extraction failed"
    fi
}

# Convert to GIF
convert_to_gif() {
    echo -e "${GREEN}Convert Video to GIF${NC}"
    
    list_video_files || return 1
    
    read -p "Enter video file name: " video_file
    
    if ! validate_video_file "$video_file"; then
        return 1
    fi
    
    read -p "GIF duration in seconds (default: 5): " duration
    duration=${duration:-5}
    
    read -p "GIF width in pixels (default: 320): " width
    width=${width:-320}
    
    local output_file=$(generate_output_filename "$video_file" "animated" "gif")
    
    show_info "Creating GIF..."
    
    $FFMPEG_CMD -t "$duration" -i "$video_file" \
        -vf "fps=10,scale=$width:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
        "$output_file"
    
    if [[ $? -eq 0 ]]; then
        show_success "GIF creation completed: $(basename "$output_file")"
    else
        show_error "GIF creation failed"
    fi
}

# AVI to MP4
convert_avi_to_mp4() {
    echo -e "${GREEN}Convert AVI to MP4${NC}"
    
    local avi_files=()
    
    for file in *.avi 2>/dev/null; do
        if [[ -f "$file" ]]; then
            avi_files+=("$file")
        fi
    done
    
    if [[ ${#avi_files[@]} -eq 0 ]]; then
        show_error "No AVI files found"
        return 1
    fi
    
    echo -e "${YELLOW}Available AVI files:${NC}"
    for i in "${!avi_files[@]}"; do
        echo -e "${GREEN}$((i+1)).${NC} ${avi_files[$i]}"
    done
    
    read -p "Select AVI file: " selection
    local video_file="${avi_files[$((selection-1))]}"
    
    if [[ -z "$video_file" ]]; then
        show_error "Invalid selection"
        return 1
    fi
    
    local output_file=$(generate_output_filename "$video_file" "converted" "mp4")
    
    show_info "Converting AVI to MP4..."
    
    $FFMPEG_CMD -i "$video_file" \
        -c:v libx264 -c:a aac \
        "$output_file"
    
    if [[ $? -eq 0 ]]; then
        show_success "Conversion completed: $(basename "$output_file")"
    else
        show_error "Conversion failed"
    fi
}

# MKV to MP4
convert_mkv_to_mp4() {
    echo -e "${GREEN}Convert MKV to MP4${NC}"
    
    local mkv_files=()
    
    for file in *.mkv 2>/dev/null; do
        if [[ -f "$file" ]]; then
            mkv_files+=("$file")
        fi
    done
    
    if [[ ${#mkv_files[@]} -eq 0 ]]; then
        show_error "No MKV files found"
        return 1
    fi
    
    echo -e "${YELLOW}Available MKV files:${NC}"
    for i in "${!mkv_files[@]}"; do
        echo -e "${GREEN}$((i+1)).${NC} ${mkv_files[$i]}"
    done
    
    read -p "Select MKV file: " selection
    local video_file="${mkv_files[$((selection-1))]}"
    
    if [[ -z "$video_file" ]]; then
        show_error "Invalid selection"
        return 1
    fi
    
    local output_file=$(generate_output_filename "$video_file" "converted" "mp4")
    
    show_info "Converting MKV to MP4..."
    
    $FFMPEG_CMD -i "$video_file" \
        -c copy \
        "$output_file"
    
    if [[ $? -eq 0 ]]; then
        show_success "Conversion completed: $(basename "$output_file")"
    else
        show_error "Conversion failed"
    fi
}

# WEBM to MP4
convert_webm_to_mp4() {
    echo -e "${GREEN}Convert WEBM to MP4${NC}"
    
    local webm_files=()
    
    for file in *.webm 2>/dev/null; do
        if [[ -f "$file" ]]; then
            webm_files+=("$file")
        fi
    done
    
    if [[ ${#webm_files[@]} -eq 0 ]]; then
        show_error "No WEBM files found"
        return 1
    fi
    
    echo -e "${YELLOW}Available WEBM files:${NC}"
    for i in "${!webm_files[@]}"; do
        echo -e "${GREEN}$((i+1)).${NC} ${webm_files[$i]}"
    done
    
    read -p "Select WEBM file: " selection
    local video_file="${webm_files[$((selection-1))]}"
    
    if [[ -z "$video_file" ]]; then
        show_error "Invalid selection"
        return 1
    fi
    
    local output_file=$(generate_output_filename "$video_file" "converted" "mp4")
    
    show_info "Converting WEBM to MP4..."
    
    $FFMPEG_CMD -i "$video_file" \
        -c:v libx264 -c:a aac \
        "$output_file"
    
    if [[ $? -eq 0 ]]; then
        show_success "Conversion completed: $(basename "$output_file")"
    else
        show_error "Conversion failed"
    fi
}

# Batch conversion
batch_convert() {
    echo -e "${GREEN}Batch Format Conversion${NC}"
    
    echo -e "${YELLOW}Select target format:${NC}"
    echo "1. MP4 (Recommended)"
    echo "2. MP3 (Audio only)"
    echo "3. GIF (Animated)"
    echo "4. Back"
    
    read -p "Select format: " format_choice
    
    case $format_choice in
        1) target_ext="mp4" ;;
        2) target_ext="mp3" ;;
        3) target_ext="gif" ;;
        4) return ;;
        *) show_error "Invalid choice"; return 1 ;;
    esac
    
    local converted=0
    local failed=0
    
    for video_file in *.{mp4,avi,mkv,webm,mov} 2>/dev/null; do
        if [[ -f "$video_file" ]]; then
            local output_file=$(generate_output_filename "$video_file" "converted" "$target_ext")
            
            show_info "Converting: $video_file"
            
            case $target_ext in
                "mp4")
                    $FFMPEG_CMD -i "$video_file" -c:v libx264 -c:a aac "$output_file"
                    ;;
                "mp3")
                    $FFMPEG_CMD -i "$video_file" -q:a 0 -map a "$output_file"
                    ;;
                "gif")
                    $FFMPEG_CMD -t 5 -i "$video_file" -vf "fps=10,scale=320:-1:flags=lanczos" "$output_file"
                    ;;
            esac
            
            if [[ $? -eq 0 ]]; then
                show_success "Converted: $(basename "$output_file")"
                ((converted++))
            else
                show_error "Failed: $video_file"
                ((failed++))
            fi
        fi
    done
    
    echo
    echo -e "${GREEN}Batch conversion completed!${NC}"
    echo -e "Successfully converted: ${GREEN}$converted${NC} files"
    echo -e "Failed: ${RED}$failed${NC} files"
}
