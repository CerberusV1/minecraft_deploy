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
    options=("Start Server" "Connect to Server" "Set EULA" "Set RAM" "Install Mods" "Exit")                 # Lists all the Options available in the script
    echo "ServerManager"
    echo "----------------------------------------------"
    select opt in "${options[@]}"; do                                                                       # Selects an option from a list and then does this
        case $opt in
            "Start Server")
                # Add an interaction Do you want to start the server y/n, so he is not starting
                # right away.
                clear
                echo "Launch Menu"
                echo "------------------------------------------------------------"
                if [[ -e "${server}/eula.txt" ]]; then                                                      # Checks if the EULA file exists
                    condition=$(cat "${server}/eula.txt" | grep -c "eula=true")                             # Sets the condition, in this case counting how many lines with eula=true exist in the EULA file
                    if [[ ${condition} -eq 1 ]]; then                                                       # If EULA is accepted, start the server
                        echo "Starting Server...."
                        cd "${server}"                                                                      # Change directory to where the start script is to avoid a tmux exit
                        tmux new -d -s "${server_name}" "./start_server.sh"                                 # Starts the server detatched in a new session
                    elif [[ ${condition} -eq 0 ]]; then                                                     # If EULA is not accepted, start the server
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
                # Add a chck before connecting to the session if the session already exists
                # if not promt the user to start it manually 
                tmux a -t "${server_name}"                                                                  # Attaches to the running tmux session of the server if the session exists
                read -p "Press Enter to continue..."
                break
            ;;
            "Set EULA")
                current_date=$(date)
                clear
                echo "                   Setting EULA                             "
                echo "------------------------------------------------------------"
                echo "In order to start an minecraft Server you have to accept it."
                echo "You can find more information here:                         "
                echo "https://www.minecraft.net/en-us/eula                        "
                echo "------------------------------------------------------------"
                read -p "Do you accept the Minecraft EULA? [y/n]: " eula_answer
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
