#!/bin/bash
# Video Master - Created by Masum Vai
# Display Functions

# Show detailed video information
show_detailed_video_info() {
    echo -e "${WHITE}Detailed Video Information${NC}"
    
    list_video_files || return 1
    
    read -p "Enter video file name: " video_file
    
    if [[ ! -f "$video_file" ]]; then
        show_error "File not found: $video_file"
        return 1
    fi
    
    if ! validate_video_file "$video_file"; then
        return 1
    fi
    
    local file_size=$(get_file_size "$video_file")
    local duration=$(get_video_duration "$video_file")
    local resolution=$(get_video_resolution "$video_file")
    
    echo
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${CYAN}📁 FILE INFORMATION${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "Name:     $(basename "$video_file")"
    echo -e "Size:     $(format_file_size $file_size)"
    echo -e "Path:     $(pwd)/$video_file"
    
    if command -v file &> /dev/null; then
        echo -e "Type:     $(file -b "$video_file" 2>/dev/null || echo "Unknown")"
    fi
    
    echo
    echo -e "${CYAN}🎥 VIDEO INFORMATION${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    
    if [[ -n "$duration" && "$duration" != "0" ]]; then
        local minutes=$(echo "scale=2; $duration/60" | bc 2>/dev/null || echo "0")
        local hours=$(echo "scale=2; $duration/3600" | bc 2>/dev/null || echo "0")
        echo -e "Duration: $duration seconds"
        echo -e "          $minutes minutes"
        echo -e "          $hours hours"
    else
        echo -e "Duration: Unknown"
    fi
    
    if [[ -n "$resolution" ]]; then
        echo -e "Resolution: $resolution"
    else
        echo -e "Resolution: Unknown"
    fi
    
    # Get video codec info
    local video_codec=$($FFPROBE_CMD -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$video_file" 2>/dev/null)
    if [[ -n "$video_codec" ]]; then
        echo -e "Video Codec: $video_codec"
    fi
    
    # Get video bitrate
    local video_bitrate=$($FFPROBE_CMD -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$video_file" 2>/dev/null)
    if [[ -n "$video_bitrate" && "$video_bitrate" != "N/A" && "$video_bitrate" -gt 0 ]]; then
        local bitrate_kbps=$((video_bitrate/1000))
        echo -e "Video Bitrate: ${bitrate_kbps} kbps"
    fi
    
    # Get frame rate
    local frame_rate=$($FFPROBE_CMD -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 "$video_file" 2>/dev/null)
    if [[ -n "$frame_rate" ]]; then
        echo -e "Frame Rate: $frame_rate"
    fi
    
    echo
    echo -e "${CYAN}🔊 AUDIO INFORMATION${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    
    # Get audio streams count
    local audio_streams=$($FFPROBE_CMD -v error -select_streams a -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$video_file" 2>/dev/null | wc -l)
    if [[ $audio_streams -gt 0 ]]; then
        echo -e "Audio Streams: $audio_streams"
    else
        echo -e "Audio Streams: None"
    fi
    
    # Get audio codec info
    local audio_codec=$($FFPROBE_CMD -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$video_file" 2>/dev/null)
    if [[ -n "$audio_codec" ]]; then
        echo -e "Audio Codec: $audio_codec"
    fi
    
    # Get audio sample rate
    local sample_rate=$($FFPROBE_CMD -v error -select_streams a:0 -show_entries stream=sample_rate -of default=noprint_wrappers=1:nokey=1 "$video_file" 2>/dev/null)
    if [[ -n "$sample_rate" ]]; then
        echo -e "Sample Rate: ${sample_rate} Hz"
    fi
    
    # Get audio channels
    local channels=$($FFPROBE_CMD -v error -select_streams a:0 -show_entries stream=channels -of default=noprint_wrappers=1:nokey=1 "$video_file" 2>/dev/null)
    if [[ -n "$channels" ]]; then
        echo -e "Channels: $channels"
    fi
    
    echo
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    
    # Show FFprobe full info
    echo
    read -p "Show full technical information? (y/n): " show_full
    if [[ $show_full == "y" || $show_full == "Y" ]]; then
        echo
        echo -e "${YELLOW}Full Technical Information:${NC}"
        $FFPROBE_CMD -i "$video_file" 2>&1 | head -20
    fi
}

# Show storage information
show_storage_info() {
    echo -e "${WHITE}Storage Information${NC}"
    echo
    
    echo -e "${CYAN}Current Directory:${NC}"
    echo -e "Path: $(pwd)"
    if command -v df &> /dev/null; then
        echo -e "Free space: $(df -h . 2>/dev/null | awk 'NR==2 {print $4}' || echo "Unknown")"
    fi
    
    echo
    echo -e "${CYAN}Video Master Directories:${NC}"
    if [[ -d "$BASE_DIR" ]]; then
        echo -e "Base: $BASE_DIR"
        if [[ -d "$INPUT_DIR" ]]; then
            echo -e "Input: $INPUT_DIR ($(du -sh "$INPUT_DIR" 2>/dev/null | cut -f1 || echo 'Empty'))"
        fi
        if [[ -d "$OUTPUT_DIR" ]]; then
            echo -e "Output: $OUTPUT_DIR ($(du -sh "$OUTPUT_DIR" 2>/dev/null | cut -f1 || echo 'Empty'))"
        fi
    else
        echo -e "Not setup yet"
    fi
}

# Show file statistics
show_file_stats() {
    echo -e "${WHITE}File Statistics${NC}"
    echo
    
    local video_count=0
    local audio_count=0
    local total_size=0
    
    # Count video files
    for ext in "${SUPPORTED_VIDEO[@]}"; do
        for file in *."$ext"; do
            if [[ -f "$file" ]]; then
                ((video_count++))
                total_size=$((total_size + $(get_file_size "$file")))
            fi
        done
    done
    
    # Count audio files  
    for ext in "${SUPPORTED_AUDIO[@]}"; do
        for file in *."$ext"; do
            if [[ -f "$file" ]]; then
                ((audio_count++))
                total_size=$((total_size + $(get_file_size "$file")))
            fi
        done
    done
    
    echo -e "${GREEN}File Count:${NC}"
    echo -e "Video files: $video_count"
    echo -e "Audio files: $audio_count"
    echo -e "Total files: $((video_count + audio_count))"
    echo -e "Total size: $(format_file_size $total_size)"
    
    if [[ $video_count -gt 0 ]]; then
        echo
        echo -e "${GREEN}Video Files:${NC}"
        for ext in "${SUPPORTED_VIDEO[@]}"; do
            for file in *."$ext"; do
                if [[ -f "$file" ]]; then
                    local size=$(get_file_size "$file")
                    echo -e "• $file - $(format_file_size $size)"
                fi
            done
        done
    fi
}
