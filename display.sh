#!/bin/bash

# Display functions for VideoMaster Pro

display_logo() {
    clear
    local color=$CYAN
    echo -e "$color"
    echo -e "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃ ██╗   ██╗██╗██████╗ ███████╗ ██████╗"
    echo -e "┃ ██║   ██║██║██╔══██╗██╔════╝██╔═══██╗"
    echo -e "┃ ██║   ██║██║██║  ██║█████╗  ██║   ██║"
    echo -e "┃ ╚██╗ ██╔╝██║██║  ██║██╔══╝  ██║   ██║"
    echo -e "┃  ╚████╔╝ ██║██████╔╝███████╗╚██████╔╝"
    echo -e "┃   ╚═══╝  ╚═╝╚═════╝ ╚══════╝ ╚═════╝ "
    echo -e "┠──────────────────────────────────────┨"
    echo -e "┃   $TOOL_NAME v$VERSION   "
    echo -e "┃   Crafted by : $AUTHOR   "
    echo -e "┃   Telegram : @MasumVaiBD   "
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    echo -e "$color┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "$color┃          Tool Loaded!          "
    echo -e "$color┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    echo -e "$RESET"
    local spinner=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    for i in {1..10}; do
        echo -en "\r$YELLOW Loading... ${spinner[$((i % 10))]}$RESET"
        sleep 0.1
    done
    echo -e "\r$GREEN Tool loaded successfully!$RESET"
    sleep 0.5
}

display_menu() {
    local title="$1"
    local color=$(get_random_color)
    echo -e "$color"
    echo -e "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃         $title         "
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    echo -e "$RESET"
}