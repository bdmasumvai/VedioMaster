#!/bin/bash
# Video Master - Created by Masum Vai

# Load configuration first
source ./config.sh

# Load all modules
source ./utils.sh
source ./menus.sh
source ./compression.sh
source ./conversion.sh
source ./watermark.sh
source ./noise.sh
source ./display.sh

# Main function
main() {
    init_videomaster
    
    while true; do
        show_main_menu
        handle_main_choice
    done
}

# Handle main menu choices
handle_main_choice() {
    case $choice in
        1) run_compression ;;
        2) run_conversion ;;
        3) run_watermark ;;
        4) run_noise_removal ;;
        5) run_video_info ;;
        6) show_help ;;
        7) run_setup ;;
        0) exit_app ;;
        *) show_error "Invalid choice! Please select 0-7" ;;
    esac
}

# Initialize app
init_videomaster() {
    clear
    show_banner
    setup_directories
    check_dependencies
}

# Exit application
exit_app() {
    echo -e "\n${GREEN}Thank you for using Video Master!${NC}"
    echo -e "${YELLOW}Created by Masum Vai${NC}"
    echo -e "${CYAN}GitHub: https://github.com/bdmasumvai/VedioMaster${NC}"
    exit 0
}

# Run if this is main script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
