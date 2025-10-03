#!/bin/bash
# Video Master - Created by Masum Vai
# Noise Removal Functions

# Remove video noise
remove_video_noise() {
    echo -e "${PURPLE}Video Noise Removal${NC}"
    
    list_video_files || return 1
    
    read -p "Enter video file name: " video_file
    
    if ! validate_video_file "$video_file"; then
        return 1
    fi
    
    echo -e "${YELLOW}Select noise removal method:${NC}"
    echo "1. Light Noise Removal (Fast)"
    echo "2. Medium Noise Removal (Balanced)" 
    echo "3. Heavy Noise Removal (Slow)"
    echo "4. Advanced AI-based (Very Slow)"
    
    read -p "Select method (1-4): " method_choice
    
    local output_file=$(generate_output_filename "$video_file" "denoised" "mp4")
    
    show_info "Starting noise removal..."
    show_warning "This may take some time depending on video length"
    
    case $method_choice in
        1)
            # Light noise removal
            $FFMPEG_CMD -i "$video_file" \
                -vf "hqdn3d=4:3:6:4.5" \
                -c:a copy \
                "$output_file"
            ;;
        2)
            # Medium noise removal  
            $FFMPEG_CMD -i "$video_file" \
                -vf "hqdn3d=8:6:12:9" \
                -c:a copy \
                "$output_file"
            ;;
        3)
            # Heavy noise removal
            $FFMPEG_CMD -i "$video_file" \
                -vf "hqdn3d=12:9:18:13.5" \
                -c:a copy \
                "$output_file"
            ;;
        4)
            # Advanced NLMeans
            $FFMPEG_CMD -i "$video_file" \
                -vf "nlmeans=1.0:7:5:3:3" \
                -c:a copy \
                "$output_file"
            ;;
        *)
            show_error "Invalid method selection"
            return 1
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        show_success "Noise removal completed: $(basename "$output_file")"
        echo -e "${GREEN}Noise reduced successfully!${NC}"
    else
        show_error "Noise removal failed"
        show_info "Trying alternative method..."
        
        # Alternative method
        $FFMPEG_CMD -i "$video_file" \
            -vf "removegrain=12" \
            -c:a copy \
            "$output_file"
            
        if [[ $? -eq 0 ]]; then
            show_success "Noise removal completed with alternative method"
        else
            show_error "All noise removal methods failed"
        fi
    fi
}

# Remove audio noise
remove_audio_noise() {
    echo -e "${PURPLE}Audio Noise Removal${NC}"
    
    list_audio_files || return 1
    
    read -p "Enter audio file name: " audio_file
    
    if ! file_exists "$audio_file"; then
        show_error "Audio file not found"
        return 1
    fi
    
    local output_file=$(generate_output_filename "$audio_file" "cleaned" "mp3")
    
    show_info "Removing audio noise..."
    
    $FFMPEG_CMD -i "$audio_file" \
        -af "highpass=300,lowpass=3000,afftdn=nf=-20" \
        "$output_file"
    
    if [[ $? -eq 0 ]]; then
        show_success "Audio noise removal completed: $(basename "$output_file")"
    else
        show_error "Audio noise removal failed"
    fi
}

# Reduce audio background noise
reduce_background_noise() {
    echo -e "${PURPLE}Reduce Background Noise${NC}"
    
    list_audio_files || return 1
    
    read -p "Enter audio file name: " audio_file
    
    if ! file_exists "$audio_file"; then
        show_error "Audio file not found"
        return 1
    fi
    
    local output_file=$(generate_output_filename "$audio_file" "noise_reduced" "mp3")
    
    show_info "Reducing background noise..."
    
    $FFMPEG_CMD -i "$audio_file" \
        -af "arnndn=mode=noise" \
        "$output_file"
    
    if [[ $? -eq 0 ]]; then
        show_success "Background noise reduced: $(basename "$output_file")"
    else
        show_error "Background noise reduction failed"
    fi
}

# List audio files
list_audio_files() {
    local audio_files=()
    local count=0
    
    echo -e "${YELLOW}Available audio files:${NC}"
    for file in *.{mp3,m4a,wav,aac} 2>/dev/null; do
        if [[ -f "$file" ]]; then
            count=$((count + 1))
            audio_files+=("$file")
            local size=$(get_file_size "$file")
            echo -e "${GREEN}$count.${NC} $file - ${CYAN}$(format_file_size $size)${NC}"
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        show_warning "No audio files found"
        return 1
    fi
    
    echo
    return 0
}

# Audio enhancement
enhance_audio() {
    echo -e "${PURPLE}Audio Enhancement${NC}"
    
    list_audio_files || return 1
    
    read -p "Enter audio file name: " audio_file
    
    if ! file_exists "$audio_file"; then
        show_error "Audio file not found"
        return 1
    fi
    
    local output_file=$(generate_output_filename "$audio_file" "enhanced" "mp3")
    
    show_info "Enhancing audio quality..."
    
    $FFMPEG_CMD -i "$audio_file" \
        -af "equalizer=f=1000:width_type=h:width=1000:g=3,compand=attacks=0.1:decays=0.1:points=-80/-80|-30/-10|0/0" \
        "$output_file"
    
    if [[ $? -eq 0 ]]; then
        show_success "Audio enhancement completed: $(basename "$output_file")"
    else
        show_error "Audio enhancement failed"
    fi
}
