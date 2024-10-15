#!/bin/bash

# Script in strict mode
set -eu
# --------------------------------------------------------------------------
# Imports

# --------------------------------------------------------------------------
# Beginning Of the Script by cerberus

#cat <<EOF
# __  __                                                   _
#|  \/  | __ _ _ __   __ _  __ _  ___ _ __ ___   ___ _ __ | |_
#| |\/| |/ _` | '_ \ / _` |/ _` |/ _ \ '_ ` _ \ / _ \ '_ \| __|
#| |  | | (_| | | | | (_| | (_| |  __/ | | | | |  __/ | | | |_
#|_|  |_|\__,_|_| |_|\__,_|\__, |\___|_| |_| |_|\___|_| |_|\__|
#                          |___/
#EOF
source .env

# cat .env

# Set empty promt
PS3=""

while true; do
    clear
    # Optionen definieren
    options=("Start Server" "Connect to Server" "Set EULA" "Set RAM" "Install Mods" "Exit")
    echo "ServerManager"
    echo "----------------------------------------------"
    select opt in "${options[@]}"; do
        case $opt in
            "Start Server")
                clear
                echo "Launch Menu"
                echo "------------------------------------------------------------"
                if [[ -e "${server}/eula.txt" ]]; then
                    condition=$(cat "${server}/eula.txt" | grep -c "eula=true")
                    if [[ ${condition} -eq 1 ]]; then
                        echo "Starting Server...."
                        .${s_start}
                        elif [[ ${condition} -eq 0 ]]; then
                        echo "Before starting the server, please accept the EULA"
                    else
                        echo "Something went wrong, please recreate the EULA"
                    fi
                else
                    echo "Before starting the server, please accept the EULA"
                fi
                read -p "Press Enter to continue..."
                break
            ;;
            "Connect to Server")
                clear
                echo "Launch Menu"
                echo "------------------------------------------------------------"
                tmux a -t ${server_name}
                read -p "Press Enter to continue..."
                break
            ;;
            "Set EULA")
                current_date=$(date)
                clear
                echo "                   Setting EULA                             "
                echo "------------------------------------------------------------"
                read -p "Do you accept the Minecraft EULA? y/n" eula_answer
                if [[ ${eula_answer} == "y" ]]; then
                    echo "# ${current_date}" > "${server}/eula.txt"
                    echo "eula=true" >> "${server}/eula.txt"
                    elif [[ ${eula_answer} == "n" ]]; then
                    echo "# ${current_date}" > "${server}/eula.txt"
                    echo "eula=false" >> "${server}/eula.txt"
                    echo "You will not be able to start the server!"
                else
                    echo "Invalid input"
                fi
                read -p "Press Enter to continue..."
                break
            ;;
            "Set RAM")
                echo "Setting RAM..."
                read -p "Press Enter to continue..."
                break
            ;;
            "Install Mods")
                echo "Installing mods..."
                read -p "Press Enter to continue..."
                break
            ;;
            "Exit")
                echo "Exiting script. Goodbye!"
                exit 0
            ;;
            *)
                echo "Invalid selection. Please try again."
            ;;
        esac
    done
done
