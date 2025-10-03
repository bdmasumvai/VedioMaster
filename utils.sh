#!/bin/bash
# Video Master - Created by Masum Vai
# Utility Functions

# Log messages
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
}

# Show error and exit
show_error() {
    local message="$1"
    echo -e "${RED}❌ Error: $message${NC}"
    log_message "ERROR: $message"
    sleep 2
}

# Show success message
show_success() {
    local message="$1"
    echo -e "${GREEN}✅ $message${NC}"
    log_message "SUCCESS: $message"
}

# Show info message
show_info() {
    local message="$1"
    echo -e "${CYAN}ℹ️  $message${NC}"
}

# Show warning message
show_warning() {
    local message="$1"
    echo -e "${YELLOW}⚠️  $message${NC}"
}

# Check if file exists
file_exists() {
    [[ -f "$1" ]]
}

# Get file size in bytes
get_file_size() {
    local file="$1"
    if file_exists "$file"; then
        stat -c%s "$file" 2>/dev/null || stat -f%z "$file"
    else
        echo "0"
    fi
}

# Format file size to human readable
format_file_size() {
    local size="$1"
    if (( size >= 1073741824 )); then
        echo "$(echo "scale=2; $size/1073741824" | bc) GB"
    elif (( size >= 1048576 )); then
        echo "$(echo "scale=2; $size/1048576" | bc) MB"
    elif (( size >= 1024 )); then
        echo "$(echo "scale=2; $size/1024" | bc) KB"
    else
        echo "$size bytes"
    fi
}

# Get video duration in seconds
get_video_duration() {
    local video="$1"
    $FFPROBE_CMD -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$video" 2>/dev/null || echo "0"
}

# Get video resolution
get_video_resolution() {
    local video="$1"
    $FFPROBE_CMD -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$video" 2>/dev/null
}

# Validate video file
validate_video_file() {
    local file="$1"
    
    if ! file_exists "$file"; then
        show_error "File not found: $file"
        return 1
    fi
    
    if ! $FFPROBE_CMD -i "$file" &> /dev/null; then
        show_error "Invalid or corrupted video file: $file"
        return 1
    fi
    
    return 0
}

# Create output filename
generate_output_filename() {
    local input_file="$1"
    local suffix="$2"
    local extension="${3:-mp4}"
    
    local filename=$(basename "$input_file")
    local name_no_ext="${filename%.*}"
    
    echo "$OUTPUT_DIR/${name_no_ext}_${suffix}.${extension}"
}

# Progress bar animation
show_progress() {
    local duration="${1:-5}"
    local steps=20
    local step_duration=$(echo "scale=2; $duration/$steps" | bc)
    
    echo -ne "${BLUE}Progress: ["
    for ((i=0; i<steps; i++)); do
        echo -ne "▇"
        sleep "$step_duration"
    done
    echo -e "] 100%${NC}"
}

# Get user input with default value
get_input() {
    local prompt="$1"
    local default="$2"
    local input
    
    read -p "$prompt [$default]: " input
    echo "${input:-$default}"
}
