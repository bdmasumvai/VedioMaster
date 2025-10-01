#!/bin/bash

# Video compression functions for VideoMaster Pro

compress_video() {
    local input="$1"
    local quality="$2"
    if ! validate_file "$input"; then return 1; fi
    if ! check_output_dir; then return 1; fi
    check_memory

    local temp_input="$HIDDEN_DIR/temp_preprocessed_$$.mp4"
    echo -e "$YELLOW Pre-processing: Preparing video...$RESET"
    ffmpeg -i "$input" -c:v copy -c:a copy "$temp_input" 2>>"$ERROR_LOG"
    if [ $? -ne 0 ]; then
        echo -e "$YELLOW Pre-processing failed with copy. Trying re-encoding...$RESET"
        ffmpeg -i "$input" -c:v libx264 -c:a aac -vf "scale=1280:-2" -r 30 "$temp_input" 2>>"$ERROR_LOG"
        if [ $? -ne 0 ]; then
            echo -e "$RED Pre-processing failed! Details in $CYAN$ERROR_LOG$RESET"
            tail -n 5 "$ERROR_LOG"
            rm -f "$temp_input" 2>/dev/null
            log_operation "compress" "failed" "preprocess_all input:$input"
            return 1
        fi
    fi

    local output=$(get_output_file "$input" "compressed")
    local crf preset
    case $quality in
        1) crf=32; preset="ultrafast" ;;
        2) crf=28; preset="superfast" ;;
        3) crf=24; preset="medium" ;;
        4) crf=20; preset="slow" ;;
        5) crf=16; preset="veryslow" ;;
    esac
    echo -e "$YELLOW Compressing video (Level $quality)...$RESET"
    ffmpeg -i "$temp_input" -c:v libx264 -crf "$crf" -preset "$preset" -c:a aac "$output" 2>>"$ERROR_LOG"
    if [ $? -eq 0 ]; then
        echo -e "$GREEN Completed! Saved: $CYAN$output (Size: $(du -sh "$output" | cut -f1))$RESET"
        log_operation "compress" "success" "level:$quality output:$output"
    else
        echo -e "$YELLOW Fallback to H.265...$RESET"
        output=$(get_output_file "$input" "compressed_fallback")
        ffmpeg -i "$temp_input" -c:v libx265 -crf "$crf" -preset "$preset" -c:a aac "$output" 2>>"$ERROR_LOG"
        if [ $? -eq 0 ]; then
            echo -e "$GREEN Fallback succeeded! Saved: $CYAN$output (Size: $(du -sh "$output" | cut -f1))$RESET"
            log_operation "compress" "success" "level:$quality output:$output"
        else
            echo -e "$RED Compression failed! Details in $CYAN$ERROR_LOG$RESET"
            tail -n 5 "$ERROR_LOG"
            log_operation "compress" "failed" "level:$quality input:$input"
        fi
    fi
    rm -f "$temp_input" 2>/dev/null
}