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
        echo "$1 is not installed."
        return 1  # Program is not installed
    else
        echo "$1 is already installed."
        return 0  # Program is installed
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
        echo "The changes in rc.local are already present."
        return 0  # Changes are present
    else
        echo "The changes in rc.local are missing."
        return 1  # Changes are missing
    fi
}

# Check if the changes in rc.local are already applied
check_rc_local
rc_local_modified=$?

# Update package lists
echo "Updating package lists..."
sudo apt update && sudo apt upgrade -y

# Install Java if not installed
if [[ $java_installed -ne 0 ]]; then
    echo "Installing Java..."
    if sudo apt install -y openjdk-17-jdk openjdk-17-jre-headless; then
        echo "Java installed successfully."
    else
        echo "Failed to install Java." >&2
    fi
else
    echo "Java is already installed. Skipping installation."
fi

# Install Tmux if not installed
if [[ $tmux_installed -ne 0 ]]; then
    echo "Installing Tmux..."
    if sudo apt install -y tmux; then
        echo "Tmux installed successfully."
    else
        echo "Failed to install Tmux." >&2
    fi
else
    echo "Tmux is already installed. Skipping installation."
fi

# Append to /etc/rc.local if changes are missing
if [[ $rc_local_modified -ne 0 ]]; then
    echo "Adding necessary changes to /etc/rc.local..."
    if sudo tee -a /etc/rc.local > /dev/null <<EOL
#!/bin/bash
exec 1>/tmp/rc.local.log 2>&1
set -x
EOL
    then
        echo "/etc/rc.local updated successfully."
        # Make /etc/rc.local executable
        sudo chmod +x /etc/rc.local
    else
        echo "Failed to update /etc/rc.local." >&2
    fi
else
    echo "No changes needed in /etc/rc.local."
fi

# Final message
echo "All required programs are already installed and rc.local is configured. Proceeding with installation..."

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

echo "Downloading Installer..."
wget -P $server_dir "$URL" -o "$management_logs/wget.log" & # no output for wget
PID=$!
(
    while kill -0 $PID 2> /dev/null; do
        echo "Downloading....."
        sleep 1
    done
    echo "Download finished."
) &
wait $PID
sleep 2

# --------------------------------------------------------
# Installing Server
# --------------------------------------------------------
echo "Installing Server"
cd "${server_dir}"
sleep 1
java -jar forge-${version}-installer.jar --installServer > /dev/null 2>&1 &

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
rm "forge-${version}-installer.jar"
mv "forge-${version}-installer.jar.log" $management_logs

echo "You can now find the management script in /$HOME/$management_dir "
