#!/bin/bash

# Menu functions for VideoMaster Pro

open_telegram() {
    echo -e "$YELLOW Opening Telegram...$RESET"
    termux-open-url "$TELEGRAM_LINK" 2>>"$ERROR_LOG"
    if [ $? -eq 0 ]; then
        echo -e "$GREEN Successfully opened Telegram: $CYAN$TELEGRAM_LINK$RESET"
        log_operation "open_telegram" "success" "link:$TELEGRAM_LINK"
    else
        echo -e "$RED Failed to open Telegram. Visit manually: $CYAN$TELEGRAM_LINK$RESET"
        log_operation "open_telegram" "failed" "link:$TELEGRAM_LINK"
    fi
}

compression_menu() {
    while true; do
        clear
        display_logo
        display_menu "Compress Video"
        echo -e "$GREEN┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
        echo -e "$CYAN┃ Select quality level:             "
        echo -e "$GREEN┃ [1] Ultra Low (Smallest size)    "
        echo -e "$GREEN┃ [2] Low (Good quality, smaller)  "
        echo -e "$GREEN┃ [3] Medium (Balanced)            "
        echo -e "$GREEN┃ [4] High (Better quality)        "
        echo -e "$GREEN┃ [5] Ultra High (Best quality)    "
        echo -e "$GREEN┃ [0] Return to main menu          "
        echo -e "$GREEN┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
        echo -e "$RESET"
        echo -ne "$CYAN Select [0-5]: $RESET"
        read choice
        case $choice in
            1|2|3|4|5)
                echo -ne "$CYAN Video path: $RESET"
                read path
                path=$(echo "$path" | tr -d "'")
                compress_video "$path" "$choice"
                echo -ne "$CYAN Press ENTER to continue...$RESET"
                read
                ;;
            0) return ;;
            *) echo -e "$RED Invalid choice!$RESET"; sleep 1 ;;
        esac
    done
}

watermark_menu() {
    while true; do
        clear
        display_logo
        display_menu "Add Watermark"
        echo -e "$YELLOW┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
        echo -e "$YELLOW┃ Select option:                    "
        echo -e "$YELLOW┃ [1] Add text watermark            "
        echo -e "$YELLOW┃ [2] Add image watermark           "
        echo -e "$YELLOW┃ [3] Add logo watermark            "
        echo -e "$YELLOW┃ [4] Custom position watermark     "
        echo -e "$YELLOW┃ [5] Add timestamp watermark       "
        echo -e "$YELLOW┃ [0] Return to main menu           "
        echo -e "$YELLOW┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
        echo -e "$RESET"
        echo -ne "$CYAN Select [0-5]: $RESET"
        read choice
        case $choice in
            1)
                echo -ne "$CYAN Video path: $RESET"
                read path
                path=$(echo "$path" | tr -d "'")
                echo -ne "$CYAN Watermark text: $RESET"
                read text
                add_watermark "$path" "$choice" "$text"
                echo -ne "$CYAN Press ENTER to continue...$RESET"
                read
                ;;
            2)
                echo -ne "$CYAN Video path: $RESET"
                read path
                path=$(echo "$path" | tr -d "'")
                echo -ne "$CYAN Image path: $RESET"
                read image
                image=$(echo "$image" | tr -d "'")
                add_watermark "$path" "$choice" "" "$image"
                echo -ne "$CYAN Press ENTER to continue...$RESET"
                read
                ;;
            3)
                echo -ne "$CYAN Video path: $RESET"
                read path
                path=$(echo "$path" | tr -d "'")
                echo -ne "$CYAN Logo path: $RESET"
                read image
                image=$(echo "$image" | tr -d "'")
                add_watermark "$path" "$choice" "" "$image"
                echo -ne "$CYAN Press ENTER to continue...$RESET"
                read
                ;;
            4)
                echo -ne "$CYAN Video path: $RESET"
                read path
                path=$(echo "$path" | tr -d "'")
                echo -ne "$CYAN Watermark text: $RESET"
                read text
                echo -ne "$CYAN X position: $RESET"
                read x_pos
                echo -ne "$CYAN Y position: $RESET"
                read y_pos
                add_watermark "$path" "$choice" "$text" "" "$x_pos" "$y_pos"
                echo -ne "$CYAN Press ENTER to continue...$RESET"
                read
                ;;
            5)
                echo -ne "$CYAN Video path: $RESET"
                read path
                path=$(echo "$path" | tr -d "'")
                add_watermark "$path" "$choice"
                echo -ne "$CYAN Press ENTER to continue...$RESET"
                read
                ;;
            0) return ;;
            *) echo -e "$RED Invalid choice!$RESET"; sleep 1 ;;
        esac
    done
}

conversion_menu() {
    while true; do
        clear
        display_logo
        display_menu "Convert Format"
        echo -e "$MAGENTA┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
        echo -e "$MAGENTA┃ Select format:                    "
        echo -e "$MAGENTA┃ [1] MP4 (Widely compatible)       "
        echo -e "$MAGENTA┃ [2] MKV (High quality)            "
        echo -e "$MAGENTA┃ [3] MOV (Apple devices)           "
        echo -e "$MAGENTA┃ [4] WEBM (Web optimized)          "
        echo -e "$MAGENTA┃ [5] AVI (Legacy)                  "
        echo -e "$MAGENTA┃ [0] Return to main menu           "
        echo -e "$MAGENTA┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
        echo -e "$RESET"
        echo -ne "$CYAN Select [0-5]: $RESET"
        read choice
        case $choice in
            1|2|3|4|5)
                echo -ne "$CYAN Video path: $RESET"
                read path
                path=$(echo "$path" | tr -d "'")
                convert_video "$path" "$choice"
                echo -ne "$CYAN Press ENTER to continue...$RESET"
                read
                ;;
            0) return ;;
            *) echo -e "$RED Invalid choice!$RESET"; sleep 1 ;;
        esac
    done
}

noise_menu() {
    while true; do
        clear
        display_logo
        display_menu "Remove Noise"
        echo -e "$CYAN┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
        echo -e "$CYAN┃ Select noise reduction level:     "
        echo -e "$CYAN┃ [1] Light (Minimal reduction)     "
        echo -e "$CYAN┃ [2] Medium (Balanced)             "
        echo -e "$CYAN┃ [3] Aggressive (Strong reduction) "
        echo -e "$CYAN┃ [0] Return to main menu           "
        echo -e "$CYAN┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
        echo -e "$RESET"
        echo -ne "$CYAN Select [0-3]: $RESET"
        read choice
        case $choice in
            1|2|3)
                echo -ne "$CYAN Video path: $RESET"
                read path
                path=$(echo "$path" | tr -d "'")
                remove_noise "$path" "$choice"
                echo -ne "$CYAN Press ENTER to continue...$RESET"
                read
                ;;
            0) return ;;
            *) echo -e "$RED Invalid choice!$RESET"; sleep 1 ;;
        esac
    done
}

main_menu() {
    while true; do
        display_logo
        display_menu "Main Menu"
        echo -e "$BLUE┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
        echo -e "$GREEN┃ [1] $GREEN Compress Video$RESET                "
        echo -e "$MAGENTA┃ [2] $MAGENTA Convert Format$RESET            "
        echo -e "$YELLOW┃ [3] $YELLOW Add Watermark$RESET               "
        echo -e "$CYAN┃ [4] $CYAN Remove Noise$RESET                 "
        echo -e "$BLUE┃ [5] $BLUE Join Telegram$RESET                "
        echo -e "$RED┃ [0] $RED Exit$RESET                           "
        echo -e "$BLUE┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
        echo -e "$RESET"
        echo -ne "$CYAN Select [0-5]: $RESET"
        read choice
        case $choice in
            1) compression_menu ;;
            2) conversion_menu ;;
            3) watermark_menu ;;
            4) noise_menu ;;
            5) 
                open_telegram
                echo -ne "$CYAN Press ENTER to continue...$RESET"
                read
                ;;
            0)
                echo -e "$GREEN Thank you for using $TOOL_NAME!$RESET"
                echo -e "$YELLOW Crafted by $AUTHOR | Join: $CYAN@MasumVaiBD$RESET"
                exit 0
                ;;
            *) echo -e "$RED Invalid choice!$RESET"; sleep 1 ;;
        esac
    done
}
