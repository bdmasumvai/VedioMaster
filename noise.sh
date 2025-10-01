#!/bin/bash

# Noise removal functions for VideoMaster Pro

remove_noise() {
    local input="$1"
    local level="$2"
    if ! validate_file "$input"; then return 1; fi
    if ! check_output_dir; then return 1; fi
    check_memory

    local output=$(get_output_file "$input" "denoised")
    local noise_reduction
    case $level in
        1) noise_reduction=0.1 ;;  # Light
        2) noise_reduction=0.3 ;;  # Medium
        3) noise_reduction=0.5 ;;  # Aggressive
    esac
    echo -e "$YELLOW Removing noise (Level $level)...$RESET"
    ffmpeg -i "$input" -af "afftdn=nr=$noise_reduction" -c:v copy "$output" 2>>"$ERROR_LOG"
    if [ $? -eq 0 ]; then
        echo -e "$GREEN Completed! Saved: $CYAN$output (Size: $(du -sh "$output" | cut -f1))$RESET"
        log_operation "noise_removal" "success" "level:$level output:$output"
    else
        echo -e "$RED Noise removal failed! Details in $CYAN$ERROR_LOG$RESET"
        tail -n 5 "$ERROR_LOG"
        log_operation "noise_removal" "failed" "level:$level input:$input"
        return 1
    fi
}