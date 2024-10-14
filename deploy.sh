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

# Check if Java is installed by checking the output of 'java -version'
if ! java -version &>/dev/null; then
    echo "Java is not installed. Installing Java and necessary packages..."

    # Update and install necessary packages
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y openjdk-17-jdk openjdk-17-jre-headless tmux

    # Add necessary commands to /etc/rc.local if not already present
    if ! grep -q "exec 1>/tmp/rc.local.log" /etc/rc.local; then
        sudo tee -a /etc/rc.local > /dev/null <<EOL
#!/bin/bash
exec 1>/tmp/rc.local.log 2>&1
set -x
EOL
    fi

    # Make /etc/rc.local executable
    sudo chmod +x /etc/rc.local
else
    echo "Java is already installed, proceeding..."
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
        sleep 5
    done
    echo "Download finished."
) &
wait $PID
sleep 6

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
rm run.sh

# --------------------------------------------------------
# Creating Launch Script
# --------------------------------------------------------
# Will be reworked soon. Aim is to create an stattic 
# script, server_manager.sh. Version and important information
# from the install script will be passed in a seperate file
# which needs to be sourced by the manager.
echo "Creating Launch Hook"
echo "There is for now only a headles version available!"
sleep 5
touch $server_dir/start_server.sh
echo "#!/bin/bash" > "${server_dir}/start_server.sh"
echo 'tmux new -s minecraft_server '"java -Djava.awt.headless=true @user_jvm_args.txt @libraries/net/minecraftforge/forge/${version}/unix_args.txt"'' >> "${server_dir}/start_server.sh"
chmod +x $server_dir/start_server.sh


# --------------------------------------------------------
# Creating .env for server_manager
# --------------------------------------------------------

touch $management_dir/.env
chmod 600 $management_dir/.env
echo "# General Information" >> $management_dir/.env
echo "server_name=${version}" >> $management_dir/.env
echo "version=${name}" >> $management_dir/.env
echo " " >> $management_dir/.env
echo "# Paths" >> $management_dir/.env
echo "main=${working_dir}" >> $management_dir/.env
echo "server=${server_dir}" >> $management_dir/.env
echo "management=${management_dir}" >> $management_dir/.env
echo "logs=${management_logs}" >> $management_dir/.env
echo " " >> $management_dir/.env
echo "# Start Script" >> $management_dir/.env
echo "s_start=${server_dir}/start_server.sh" >> $management_dir/.env


# --------------------------------------------------------
# Downloading Start Script
# --------------------------------------------------------
echo "Downloading Start Script"
curl -sS "https://raw.githubusercontent.com/CerberusV1/minecraft_deploy/refs/heads/main/server_manager.sh" >> "${management_dir}/server_manager.sh"
chmod +x $management_dir/server_manager.sh
echo "You can now find the management script in $management_dir "
