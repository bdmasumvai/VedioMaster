#!/bin/bash

# Utility functions for VideoMaster Pro

log_operation() {
    local action="$1"
    local status="$2"
    local details="$3"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $action | $status | $details" >> "$OP_LOG" 2>>"$ERROR_LOG"
}

check_dependencies() {
    local deps=("ffmpeg" "curl" "git" "ffprobe")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            echo -e "$YELLOW Warning: $dep missing. Attempting install...$RESET"
            if ! pkg install -y "$dep" 2>>"$ERROR_LOG"; then
                echo -e "$RED Error: Failed to install $dep. Install manually.$RESET"
                log_operation "dependency_install" "failed" "dep:$dep"
                exit 1
            fi
        fi
    done
    if ! ffmpeg -encoders 2>>"$ERROR_LOG" | grep -q libx264; then
        echo -e "$RED Warning: libx264 missing. Reinstalling FFmpeg...$RESET"
        pkg install -y ffmpeg
    fi
    echo -e "$GREEN Dependencies ready!$RESET"
    log_operation "check_dependencies" "success" "all_deps_installed"
}

check_memory() {
    local free_mem=$(free -m | grep Mem | awk '{print $4}')
    if [ "$free_mem" -lt 300 ]; then
        echo -e "$YELLOW Warning: Low ram memory ($free_mem MB free). Close Background apps for better performance.$RESET"
        log_operation "check_memory" "warning" "low_memory:$free_mem"
    else
        log_operation "check_memory" "success" "memory:$free_mem"
    fi
}

validate_file() {
    local file="$1"
    if [ -z "$file" ] || [ ! -e "$file" ] || [ ! -f "$file" ] || [ ! -r "$file" ]; then
        echo -e "$RED Error: Invalid or inaccessible file: $file$RESET"
        log_operation "validate_file" "failed" "file:$file"
        return 1
    fi
    if ! ffprobe -v error -show_streams -show_format "$file" > "$HIDDEN_DIR/video_info.txt" 2>>"$ERROR_LOG"; then
        echo -e "$RED Warning: Could not analyze video: $file. File may be corrupted.$RESET"
        log_operation "validate_file" "failed" "invalid_video:$file"
        return 1
    fi
    log_operation "validate_file" "success" "file:$file"
    return 0
}

check_output_dir() {
    if [ ! -d "$OUTPUT_DIR" ] || [ ! -w "$OUTPUT_DIR" ]; then
        echo -e "$RED Error: Output directory $OUTPUT_DIR is not writable. Check permissions.$RESET"
        log_operation "check_output_dir" "failed" "dir:$OUTPUT_DIR"
        return 1
    fi
    if [ ! -d "$HIDDEN_DIR" ] || [ ! -w "$HIDDEN_DIR" ]; then
        echo -e "$RED Error: Hidden directory $HIDDEN_DIR is not writable. Check permissions.$RESET"
        log_operation "check_hidden_dir" "failed" "dir:$HIDDEN_DIR"
        return 1
    fi
    log_operation "check_output_dir" "success" "dir:$OUTPUT_DIR"
    return 0
}

get_output_file() {
    local input="$1"
    local suffix="$2"
    local ext="${input##*.}"
    local base="$(basename "$input" ".$ext")"
    local output="$OUTPUT_DIR/${base}_${suffix}_MasumVaiBD.${ext}"
    local count=1
    while [ -f "$output" ]; do
        output="$OUTPUT_DIR/${base}_${suffix}_bdmasumvai($count).${ext}"
        ((count++))
    done
    echo "$output"
}

display_processing() {
    local message="$1"
    local dots=""
    for i in {1..10}; do
        echo -en "\r$YELLOW $message$dots$RESET"
        dots="$dots."
        sleep 0.05
    done
    echo -en "\r$YELLOW $message...$RESET\n"
}