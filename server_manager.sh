#!/bin/bash

# Script in strict mode
set -eu
# --------------------------------------------------------------------------
# Imports:
# --------------------------------------------------------------------------

# Sourcing the .env file which contains the server information
source .env

# --------------------------------------------------------------------------
# Beginning Of the Script by cerberus
# --------------------------------------------------------------------------

# Set empty promt
PS3=""

while true; do
    clear
    # Lists all the Options available in the script
    options=("Start Server" "Connect to Server" "Set EULA" "Set RAM" "Install Mods" "Exit")
    echo "               ServerManager"
    echo "----------------------------------------------"
    # Selects an option from a list and executes it
    select opt in "${options[@]}"; do
        case $opt in
            "Start Server")
                clear
                echo "                     Launch Menu"
                echo "------------------------------------------------------------"
                # Promting before actually starting the server
                read -p "Do you want to start the server? [y/n] " start_answer
                # Checks if the EULA file exists
                if [[ ${start_answer} == "y" ]]; then
                    if [[ -e "${server}/eula.txt" ]]; then
                        # Sets the condition, in this case counting how many lines with eula=true exist in the EULA file
                        condition=$(cat "${server}/eula.txt" | grep -c "eula=true")
                        # If EULA is accepted, start the server
                        if [[ ${condition} -eq 1 ]]; then
                            echo "Starting Server...."
                            # Change directory to where the start script is to avoid a tmux error [exited]
                            # without any other error message
                            cd "${server}"
                            # Starts the server detatched in a new session
                            # To check for sessions tmux ls and to reconnect to an existing one tmux a -t session_name
                            tmux new -d -s "${server_name}" "./start_server.sh"
                            # If EULA is not accepted, tells the user to accept the EULA before
                            elif [[ ${condition} -eq 0 ]]; then
                            echo "Before starting the server, please accept the EULA"
                            # An case that should only appear if more than just one EULA entry was made.
                            # Either commented or not. This should be easily fixed by accepting the EULA again
                            # since every action in this menu doesn´t matter if agreed or not, the file gets
                            # overwritten
                            # Using "Set EULA" should fix that
                        else
                            echo "Something went wrong, please recreate the EULA"
                        fi
                        # Error massage if the EULA file does not exist. Using "Set EULA" should fix that
                    else
                        echo "Before starting the server, please accept the EULA"
                        echo "error - missing file "eula.txt""
                    fi
                    # If the user prompts n in the server start menu, he returns back to the main menu
                    elif [[ ${start_answer} == "n" ]]; then
                    break
                    # If the user prompts something else than y or n in the server start menu, he returns back to the main menu
                else
                    echo "Invalid input"
                    break
                fi
                read -p "Press Enter to return to the menu"
                break
            ;;
            "Connect to Server")
                clear
                echo "                   Connecting to Server"
                echo "------------------------------------------------------------"
                if tmux has-session -t ${server_name} 2>/dev/null; then
                    # Attaches to the running tmux session of the server if the session exists
                    tmux a -t "${server_name}"
                else
                    echo "You need to start the server before trying to connect to it."
                    read -p "Press Enter to continue..."
                fi
                break
            ;;
            "Set EULA")
                current_date=$(date)
                clear
                echo "                      Setting EULA                          "
                echo "------------------------------------------------------------"
                echo "In order to start an minecraft Server you have to accept it."
                echo "You can find more information here:                         "
                echo "https://www.minecraft.net/en-us/eula                        "
                echo "------------------------------------------------------------"
                # Promts the user if he wants to accept or not accept the minecraft EULA
                read -p "Do you accept the Minecraft EULA? [y/n]: " eula_answer
                # If the user promts yes, the EULA gets created/ overwritten and sets it to true
                if [[ ${eula_answer} == "y" ]]; then
                    echo "# ${current_date}" > "${server}/eula.txt"
                    echo "eula=true" >> "${server}/eula.txt"
                    # If the user promts no, the EULA gets created/ overwritten and sets it to false.
                    # User also gets a reminder that he will not be able to start the server without accepting
                    # to it
                    elif [[ ${eula_answer} == "n" ]]; then
                    echo "# ${current_date}" > "${server}/eula.txt"
                    echo "eula=false" >> "${server}/eula.txt"
                    echo "Caution: You will not be able to start the serverwithout accepting to the EULA."
                else
                    echo "Invalid input!"
                fi
                read -p "Press Enter to continue..."
                break
            ;;
            "Set RAM")
                while true; do
                    clear
                    echo "                       Allocate RAM                         "
                    echo "------------------------------------------------------------"
                    presets=("1 GB" "2 GB" "4 GB" "8 GB" "16 GB" "Check Args" "Back to Main Menu")
                    select opt in "${presets[@]}"; do
                        case $opt in
                            "1 GB")
                                clear
                                echo "------------------------"
                                echo "Allocated 1GB of RAM"
                                echo "-Xms512M" > "${server}/user_jvm_args.txt"
                                echo "-Xmx1G" >> "${server}/user_jvm_args.txt"
                                read -p "Press [ENTER] to continue"
                                break
                            ;;
                            "2 GB")
                                echo "------------------------"
                                echo "Allocated 2GB of RAM"
                                echo "-Xms1G" > "${server}/user_jvm_args.txt"
                                echo "-Xmx2G" >> "${server}/user_jvm_args.txt"
                                read -p "Press [ENTER] to continue"
                                break
                            ;;
                            "4 GB")
                                echo "------------------------"
                                echo "Allocated 4GB of RAM"
                                echo "-Xms2G" > "${server}/user_jvm_args.txt"
                                echo "-Xmx4G" >> "${server}/user_jvm_args.txt"
                                read -p "Press [ENTER] to continue"
                                break
                            ;;
                            "8 GB")
                                echo "------------------------"
                                echo "Allocated 8GB of RAM"
                                echo "-Xms4G" > "${server}/user_jvm_args.txt"
                                echo "-Xmx8G" >> "${server}/user_jvm_args.txt"
                                read -p "Press [ENTER] to continue"
                                break
                            ;;
                            "16 GB")
                                echo "------------------------"
                                echo "Allocated 16GB of RAM"
                                echo "-Xms8G" > "${server}/user_jvm_args.txt"
                                echo "-Xmx16G" >> "${server}/user_jvm_args.txt"
                                read -p "Press [ENTER] to continue"
                                break 
                            ;;
                            "Check Args")
                                echo "------------------------"
                                echo "User Args: "
                                echo " "
                                cat "${server}/user_jvm_args.txt"
                                echo " "
                                read -p "Press [ENTER] to continue"
                                break
                            ;;
                            "Back to Main Menu")
                                break 2
                            ;;
                            *)
                                echo "invalid input"
                                break
                            ;;
                        esac
                    done
                done
                read -p "Press Enter to return to main menu"
                break
            ;;
            "Install Mods")
                clear
                echo "Installing mods is not supported yet"
                read -p "Press Enter to continue..."
                break
            ;;
            "Exit")
                exit 0
            ;;
            *)
                echo "Invalid selection. Please try again."
            ;;
        esac
    done
done
