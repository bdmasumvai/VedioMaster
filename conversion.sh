#!/bin/bash

# Video conversion functions for VideoMaster Pro

convert_video() {
    local input="$1"
    local format="$2"
    if ! validate_file "$input"; then return 1; fi
    if ! check_output_dir; then return 1; fi
    check_memory

    local temp_input="$HIDDEN_DIR/temp_preprocessed_$$.mp4"
    echo -e "$YELLOW Pre-processing: Preparing video...$RESET"
    ffmpeg -i "$input" -c:v copy -c:a copy "$temp_input" 2>>"$ERROR_LOG"
    if [ $? -ne 0 ]; then
        echo -e "$RED Pre-processing failed! Details in $CYAN$ERROR_LOG$RESET"
        rm -f "$temp_input" 2>/dev/null
        return 1
    fi

    local output=$(get_output_file "$input" "converted")
    local ext
    case $format in
        1) ext="mp4" ;;
        2) ext="mkv" ;;
        3) ext="mov" ;;
        4) ext="webm" ;;
        5) ext="avi" ;;
    esac
    output="${output%.*}.$ext"
    echo -e "$YELLOW Converting to $ext...$RESET"
    ffmpeg -i "$temp_input" -c:v libx264 -c:a aac "$output" 2>>"$ERROR_LOG"
    if [ $? -eq 0 ]; then
        echo -e "$GREEN Completed! Saved: $CYAN$output$RESET"
        log_operation "convert" "success" "format:$ext output:$output"
    else
        echo -e "$RED Conversion failed! Details in $CYAN$ERROR_LOG$RESET"
        tail -n 5 "$ERROR_LOG"
        log_operation "convert" "failed" "format:$ext input:$input"
        rm -f "$temp_input" 2>/dev/null
        return 1
    fi
    rm -f "$temp_input" 2>/dev/null
}