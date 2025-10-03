#!/bin/bash
# Video Master - Created by Masum Vai

# Load configuration
if [ -f "./config.sh" ]; then
    source ./config.sh
else
    echo "Error: config.sh not found!"
    exit 1
fi

# Load modules
load_module() {
    local module="$1"
    if [ -f "./$module.sh" ]; then
        source "./$module.sh"
    else
        echo "Error: $module.sh not found!"
        return 1
    fi
}

# Load all modules
load_module "utils"
load_module "menus" 
load_module "compression"
load_module "conversion"
load_module "watermark"
load_module "noise"
load_module "display"

# Main function
main() {
    init_videomaster
    
    while true; do
        show_main_menu
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
    done
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
