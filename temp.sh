#!/bin/bash

# Script in strict mode
set -eu 
# --------------------------------------------------------------------------
# Imports

# --------------------------------------------------------------------------
# Beginning Of the Script by cerberus

cat <<EOF
 __  __ ____  ____  ____
|  \/  / ___||  _ \/ ___|
| |\/| \___ \| | | \___ \\
| |  | |___) | |_| |___) |
|_|  |_|____/|____/|____/ 

EOF

# --------------------------------------------------------
# Checking Dependencies
# --------------------------------------------------------

# Ask the user if Java is installed
read -p "Is Java installed? (y/n): " answer

# If the user answers "n", Java and other packages will be installed
if [[ "$answer" = "n" ]]; then
    # Update and install necessary packages
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y openjdk-17-jdk openjdk-17-jre-headless tmux

    # Add necessary commands to /etc/rc.local with proper permissions
    sudo tee -a /etc/rc.local > /dev/null <<EOL
#!/bin/bash
exec 1>/tmp/rc.local.log 2>&1
set -x
EOL

    # Make /etc/rc.local executable
    sudo chmod +x /etc/rc.local

# If the user answers "y", proceed with the script without installing Java
elif [[ "$answer" = "y" ]]; then
    echo "Java is already installed, proceeding..."
else
    # If user inputs anything else, show an error message
    echo "Invalid input. Please enter 'y' or 'n'."
    exit 1
fi

# --------------------------------------------------------
# Modloader Selection
# --------------------------------------------------------

echo What Modloader should be used?

modloader=("Forge" "Fabric")

select opt in "${modloader[@]}"
do
    case $opt in
        "Forge")
            break
            ;;
        "Fabric")
            echo "Fabric is not supported yet"
            exit 1
            break
            ;;
        *)
            echo "Invalid selection"
            ;;
    esac
done


# --------------------------------------------------------
# Select MC-Version
# --------------------------------------------------------

echo What MC-Version do you want to deploy?

versions=("1.21.1" "1.21" "1.20.6" "1.20.4" "1.20.3" "1.20.2" "1.20.1")

select opt in "${versions[@]}"
do
    case $opt in
        "1.21.1")
            echo "Not Supported yet"
            break
            ;;
        "1.21")
            echo "Not Supported yet"
            break
            ;;
        "1.20.6")
            echo "Not Supported yet"
            break
            ;;
        "1.20.4")
            echo "Not Supported yet"
            break
            ;;
        "1.20.3")
            echo "Not Supported yet"
            break
            ;;
        "1.20.2")
            echo "Not Supported yet"
            break
            ;;
        "1.20.1")
            minecraft_version="1.20.1"
            forge_version="47.3.0"
            break
            ;;
        *)
            echo "Invalid selection"
            ;;
    esac
done


# echo How much RAM do you want to use?
# echo What mods do you want to use?
# echo Which mods do you want to add?


# --------------------------------------------------------
# Installation Variables
# --------------------------------------------------------

# Set Working Directory
working_dir="$HOME/minecraft_server"
management_dir="$HOME/minecraft_server/management"
server_dir="$HOME/minecraft_server/server"


# Connecting Versions
mc_forge_version="${minecraft_version}-${forge_version}"

# Creating Installer-URL Template
URL="https://maven.minecraftforge.net/net/minecraftforge/forge/${mc_forge_version}/forge-${mc_forge_version}-installer.jar"


# --------------------------------------------------------
# Downloading Installer
# --------------------------------------------------------

echo "Downloading Installer"
mkdir ${working_dir}
mkdir ${server_dir}
wget "$server_dir" "$URL" > /dev/null 2>&1 & # no output for wget
PID=$!
(
    while kill -0 $PID 2> /dev/null; do
        echo "Downloading....."
        sleep 1
    done
    echo "Download finished."
) &&


# --------------------------------------------------------
# Installing Server
# --------------------------------------------------------
echo "Installing Server"
cd ${server_dir}
sleep 2
java -jar forge-${mc_forge_version}-installer.jar --installServer > /dev/null 2>&1 &

# Store the PID of the installer process
PID=$!

# Progress monitoring while the server is installing
(
    while kill -0 $PID 2> /dev/null; do
        echo "Installing server....."
        sleep 5
    done
    echo "Server installation finished."
)

echo "Removing Installer"
rm "forge-${mc_forge_version}-installer.jar"


# --------------------------------------------------------
# Installing Server
# --------------------------------------------------------
# Will be reworked soon. Aim is to create an stattic 
# script, server_manager.sh. Version and important information
# from the install script will be passed in a seperate file
# which needs to be sourced by the manager.
mkdir ${management_dir}
echo "Creating Start Script"
touch "${management_dir}/start_server.sh"
echo "#!/bin/bash" > "${management_dir}/start_server.sh"
echo 'tmux new -s minecraft_server 'java -Djava.awt.headless=true @user_jvm_args.txt @libraries/net/minecraftforge/forge/${mc_forge_version}/unix_args.txt "$@"'' >> "${working_dir}/start_server.sh"
chmod +x "${management_dir}/start_server.sh"
