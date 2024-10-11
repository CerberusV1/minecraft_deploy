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
read -p "Is java installed? (y/n): " answer
if [ "$answer" == "n" ]; then
    # echo "apt blah"
    sudo apt update && sudo apt upgrade
    sudo apt install -y openjdk-17-jdk
    sudo apt install -y openjdk-17-jre-headless tmux
    sudo echo "#!/bin/bash" >> /etc/rc.local
    sudo echo "exec 1>/tmp/rc.local.log 2>&1" >> /etc/rc.local
    sudo echo "set -x " >> /etc/rc.local
    sudo chmod a+x /etc/rc.local
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
# Installation Misc
# --------------------------------------------------------

# Set Working Directory
working_dir="$HOME/minecraft_server"

# Connecting Versions
mc_forge_version="${minecraft_version}-${forge_version}"

# Creating Installer-URL Template
URL="https://maven.minecraftforge.net/net/minecraftforge/forge/${mc_forge_version}/forge-${mc_forge_version}-installer.jar"


# --------------------------------------------------------
# Downloading Installer
# --------------------------------------------------------

echo "Downloading installer...."
mkdir ${working_dir}
cd ${working_dir}
wget "$working_dir" "$URL" > /dev/null 2>&1 & # no output for wget

# Waiting for download to finish
PID=$!
(
    while kill -0 $PID 2> /dev/null; do
        echo "Downloading....."
        sleep 2
    done
    echo "Download finished."
) &&


echo "Installing Server"
sleep 2
java -jar forge-${mc_forge_version}-installer.jar --installServer
echo "Removing Installer"
rm "forge-${mc_forge_version}-installer.jar"

touch "${working_dir}/start_server.sh"
chmod +x "${working_dir}/start_server.sh"

echo "Creating Start Script"

#!/bin/bash
echo "#!/bin/bash" > "${working_dir}/start_server.sh"
echo "tmux new -s minecraft_server "java @user_jvm_args.txt @libraries/net/minecraftforge/forge/${mc_forge_version}/unix_args.txt '$@'"" >> "${working_dir}/start_server.sh"

