#!/bin/bash
# Video Master - Created by Masum Vai
# Watermark Functions

# Add text watermark
add_text_watermark() {
    echo -e "${BLUE}Add Text Watermark${NC}"
    
    list_video_files || return 1
    
    read -p "Enter video file name: " video_file
    
    if ! validate_video_file "$video_file"; then
        return 1
    fi
    
    read -p "Enter watermark text: " watermark_text
    watermark_text=${watermark_text:-"Video Master"}
    
    echo -e "${YELLOW}Select position:${NC}"
    echo "1. Top Left"
    echo "2. Top Right" 
    echo "3. Bottom Left"
    echo "4. Bottom Right"
    echo "5. Center"
    
    read -p "Select position (1-5): " position_choice
    
    local position
    case $position_choice in
        1) position="10:10" ;;
        2) position="main_w-text_w-10:10" ;;
        3) position="10:main_h-text_h-10" ;;
        4) position="main_w-text_w-10:main_h-text_h-10" ;;
        5) position="(w-text_w)/2:(h-text_h)/2" ;;
        *) position="main_w-text_w-10:main_h-text_h-10" ;;
    esac
    
    read -p "Font size (default: 24): " font_size
    font_size=${font_size:-24}
    
    local output_file=$(generate_output_filename "$video_file" "watermarked" "mp4")
    
    show_info "Adding text watermark..."
    
    $FFMPEG_CMD -i "$video_file" \
        -vf "drawtext=text='$watermark_text':x=$position:y=10:fontsize=$font_size:fontcolor=white@0.8:box=1:boxcolor=black@0.5:boxborderw=5" \
        -codec:a copy \
        "$output_file"
    
    if [[ $? -eq 0 ]]; then
        show_success "Text watermark added: $(basename "$output_file")"
    else
        show_error "Failed to add watermark"
    fi
}

# Add image watermark
add_image_watermark() {
    echo -e "${BLUE}Add Image Watermark${NC}"
    
    list_video_files || return 1
    
    read -p "Enter video file name: " video_file
    
    if ! validate_video_file "$video_file"; then
        return 1
    fi
    
    # Check for image files
    local image_files=()
    for file in *.{png,jpg,jpeg} 2>/dev/null; do
        if [[ -f "$file" ]]; then
            image_files+=("$file")
        fi
    done
    
    if [[ ${#image_files[@]} -eq 0 ]]; then
        show_error "No image files found (PNG, JPG, JPEG)"
        echo "Please place watermark image in current directory"
        return 1
    fi
    
    echo -e "${YELLOW}Available image files:${NC}"
    for i in "${!image_files[@]}"; do
        echo -e "${GREEN}$((i+1)).${NC} ${image_files[$i]}"
    done
    
    read -p "Select watermark image: " image_choice
    local watermark_image="${image_files[$((image_choice-1))]}"
    
    if [[ -z "$watermark_image" ]]; then
        show_error "Invalid selection"
        return 1
    fi
    
    echo -e "${YELLOW}Select position:${NC}"
    echo "1. Top Left"
    echo "2. Top Right"
    echo "3. Bottom Left" 
    echo "4. Bottom Right"
    
    read -p "Select position (1-4): " position_choice
    
    local position
    case $position_choice in
        1) position="10:10" ;;
        2) position="main_w-overlay_w-10:10" ;;
        3) position="10:main_h-overlay_h-10" ;;
        4) position="main_w-overlay_w-10:main_h-overlay_h-10" ;;
        *) position="main_w-overlay_w-10:main_h-overlay_h-10" ;;
    esac
    
    local output_file=$(generate_output_filename "$video_file" "watermarked" "mp4")
    
    show_info "Adding image watermark..."
    
    $FFMPEG_CMD -i "$video_file" -i "$watermark_image" \
        -filter_complex "overlay=$position" \
        -codec:a copy \
        "$output_file"
    
    if [[ $? -eq 0 ]]; then
        show_success "Image watermark added: $(basename "$output_file")"
    else
        show_error "Failed to add image watermark"
    fi
}

# Custom watermark position
add_custom_watermark() {
    echo -e "${BLUE}Custom Watermark Position${NC}"
    
    list_video_files || return 1
    
    read -p "Enter video file name: " video_file
    
    if ! validate_video_file "$video_file"; then
        return 1
    fi
    
    read -p "Enter watermark text: " watermark_text
    watermark_text=${watermark_text:-"Video Master"}
    
    read -p "X position (default: 10): " x_pos
    x_pos=${x_pos:-10}
    
    read -p "Y position (default: 10): " y_pos
    y_pos=${y_pos:-10}
    
    read -p "Font size (default: 24): " font_size
    font_size=${font_size:-24}
    
    read -p "Font color (default: white): " font_color
    font_color=${font_color:-white}
    
    read -p "Opacity (0.1-1.0, default: 0.8): " opacity
    opacity=${opacity:-0.8}
    
    local output_file=$(generate_output_filename "$video_file" "custom_wm" "mp4")
    
    show_info "Adding custom watermark..."
    
    $FFMPEG_CMD -i "$video_file" \
        -vf "drawtext=text='$watermark_text':x=$x_pos:y=$y_pos:fontsize=$font_size:fontcolor=$font_color@$opacity:box=1:boxcolor=black@0.5" \
        -codec:a copy \
        "$output_file"
    
    if [[ $? -eq 0 ]]; then
        show_success "Custom watermark added: $(basename "$output_file")"
    else
        show_error "Failed to add custom watermark"
    fi
}

# Preview watermark
preview_watermark() {
    echo -e "${BLUE}Watermark Preview${NC}"
    echo "This feature creates a short preview with watermark"
    
    list_video_files || return 1
    
    read -p "Enter video file name: " video_file
    
    if ! validate_video_file "$video_file"; then
        return 1
    fi
    
    read -p "Enter watermark text: " watermark_text
    watermark_text=${watermark_text:-"Video Master"}
    
    local output_file=$(generate_output_filename "$video_file" "preview" "mp4")
    
    show_info "Creating 10-second preview with watermark..."
    
    $FFMPEG_CMD -t 10 -i "$video_file" \
        -vf "drawtext=text='$watermark_text':x=main_w-text_w-10:y=main_h-text_h-10:fontsize=24:fontcolor=white@0.8:box=1:boxcolor=black@0.5" \
        "$output_file"
    
    if [[ $? -eq 0 ]]; then
        show_success "Preview created: $(basename "$output_file")"
        echo -e "${YELLOW}Check the preview before processing full video${NC}"
    else
        show_error "Failed to create preview"
    fi
}
