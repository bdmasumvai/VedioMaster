#!/bin/bash

# Watermark functions for VideoMaster Pro

add_watermark() {
    local input="$1"
    local option="$2"
    local text="$3"
    local image="$4"
    local x_pos="$5"
    local y_pos="$6"
    if ! validate_file "$input"; then return 1; fi
    if ! check_output_dir; then return 1; fi

    local output=$(get_output_file "$input" "watermarked")
    echo -e "$YELLOW Adding watermark...$RESET"
    case $option in
        1) # Text watermark
            if [ -z "$text" ]; then
                echo -e "$RED Error: Watermark text required!$RESET"
                return 1
            fi
            ffmpeg -i "$input" -vf "drawtext=text='$text':x=10:y=10:fontsize=24:fontcolor=white" -codec:a copy "$output" 2>>"$ERROR_LOG"
            ;;
        2) # Image watermark
            if [ -z "$image" ] || [ ! -f "$image" ]; then
                echo -e "$RED Error: Invalid image path!$RESET"
                return 1
            fi
            ffmpeg -i "$input" -i "$image" -filter_complex "overlay=10:10" -codec:a copy "$output" 2>>"$ERROR_LOG"
            ;;
        3) # Logo watermark
            if [ -z "$image" ] || [ ! -f "$image" ]; then
                echo -e "$RED Error: Invalid logo path!$RESET"
                return 1
            fi
            ffmpeg -i "$input" -i "$image" -filter_complex "overlay=main_w-overlay_w-10:main_h-overlay_h-10" -codec:a copy "$output" 2>>"$ERROR_LOG"
            ;;
        4) # Custom position watermark
            if [ -z "$text" ] || [ -z "$x_pos" ] || [ -z "$y_pos" ]; then
                echo -e "$RED Error: Text and position (x, y) required!$RESET"
                return 1
            fi
            ffmpeg -i "$input" -vf "drawtext=text='$text':x=$x_pos:y=$y_pos:fontsize=24:fontcolor=white" -codec:a copy "$output" 2>>"$ERROR_LOG"
            ;;
        5) # Timestamp watermark
            ffmpeg -i "$input" -vf "drawtext=text='%{localtime}:%Y-%m-%d %H:%M:%S':x=10:y=10:fontsize=20:fontcolor=white" -codec:a copy "$output" 2>>"$ERROR_LOG"
            ;;
        *)
            echo -e "$RED Invalid watermark option!$RESET"
            return 1
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo -e "$GREEN Completed! Saved: $CYAN$output$RESET"
        log_operation "watermark" "success" "option:$option output:$output"
    else
        echo -e "$RED Watermark failed! Details in $CYAN$ERROR_LOG$RESET"
        tail -n 5 "$ERROR_LOG"
        log_operation "watermark" "failed" "option:$option input:$input"
        return 1
    fi
}