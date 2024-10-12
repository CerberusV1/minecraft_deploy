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

echo "Checking dependencies..."
sleep 2
# Function to check if a program is installed
check_installed() {
    if ! which "$1" > /dev/null 2>&1; then
        echo "$1 will be installed..."
        return 1
    else
        echo "$1 is already installed."
        return 0
    fi
}

# Check if Java is installed
check_installed java
java_installed=$?

# Check if Tmux is installed
check_installed tmux
tmux_installed=$?

# Function to check if /etc/rc.local already contains the required lines
check_rc_local() {
    if grep -q "exec 1>/tmp/rc.local.log 2>&1" /etc/rc.local && grep -q "set -x" /etc/rc.local; then
        echo "rc.local is already configured"
        return 0
    else
        echo "rc.local not configured"
        return 1
    fi
}

# Check if the changes in rc.local are already applied
check_rc_local
rc_local_modified=$?

# If Java or Tmux is not installed, or rc.local is not modified, install/modify
if [[ $java_installed -ne 0 || $tmux_installed -ne 0 || $rc_local_modified -ne 0 ]]; then
    echo "Some required programs or rc.local modifications are missing. Installing..."

    # Update and install the necessary packages
    sudo apt update && sudo apt upgrade -y

    if [[ $java_installed -ne 0 ]]; then
        sudo apt install -y openjdk-17-jdk openjdk-17-jre-headless
    fi

    if [[ $tmux_installed -ne 0 ]]; then
        sudo apt install -y tmux
    fi

    # Only append to rc.local if changes are missing
    if [[ $rc_local_modified -ne 0 ]]; then
        sudo tee -a /etc/rc.local > /dev/null <<EOL
#!/bin/bash
exec 1>/tmp/rc.local.log 2>&1
set -x
EOL
        # Make /etc/rc.local executable
        sudo chmod +x /etc/rc.local
    fi

else
    echo "All required programs are already installed and rc.local is configured. Proceeding with installation..."
fi
sleep 2


# --------------------------------------------------------
# Installation Directories
# --------------------------------------------------------
echo "Give your server a name. Under the ~/servername you can later"
echo "find all server files and the management script."
echo 'Use "-" or "_" as name seperator!'
read -p "Servername: " name

working_dir="$HOME/$name"
management_dir="$HOME/$name/management"
management_logs="$HOME/$name/management/installation_logs"
server_dir="$HOME/$name/server"

echo "Creating directories"
mkdir $working_dir
mkdir $management_dir
mkdir $management_logs
mkdir $server_dir


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

echo "Give the minecraft and forge version in following format:"
echo "mc.version-forge.version    e.g.: 1.20.1-47.3.0"
read -p "Version: " version

# echo $version       # Logging output
# sleep 1

# Building installer download URL
URL="https://maven.minecraftforge.net/net/minecraftforge/forge/${version}/forge-${version}-installer.jar"
# echo $URL       # Logging output


# --------------------------------------------------------
# Downloading Installer
# --------------------------------------------------------

echo "Downloading Installer"
wget "$server_dir" "$URL" > /dev/null 2>&1 & # no output for wget
PID=$!
(
    while kill -0 $PID 2> /dev/null; do
        echo "Downloading....."
        sleep 1
    done
    echo "Download finished."
) &&