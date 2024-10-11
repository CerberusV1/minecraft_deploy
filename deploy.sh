#!/bin/bash
#                                                   
# Script in strict mode
set -eou pipefail
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

read -p "Is java installed? (y/n): " answer
if [ "$answer" == "n" ]; then
    echo "apt blah"
    # sudo apt update && sudo apt upgrade
    # sudo apt install -y openjdk-17-jdk
    # sudo echo "#!/bin/bash" >> /etc/rc.local
    # sudo echo "exec 1>/tmp/rc.local.log 2>&1" >> /etc/rc.local
    # sudo echo "set -x " >> /etc/rc.local
    # sudo chmod a+x /etc/rc.local
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
            echo "Using Minecraft Version 1.21.1"
            break
            ;;
        "1.21")
            echo "Sie haben Option 2 gewählt"
            break
            ;;
        "1.20.6")
            echo "Sie haben Option 3 gewählt"
            break
            ;;
        "1.20.4")
            echo "Abbruch"
            break
            ;;
        "1.20.3")
            echo "Abbruch"
            break
            ;;
        "1.20.2")
            echo "Abbruch"
            break
            ;;
        "1.20.1")
            minecraft_version="1.20.1"
            forge_version="47.2.0"
            break
            ;;
        *)
            echo "Invalid selection"
            ;;
    esac
done


echo "link with part1: $minecraft_version and part2: $forge_version"
# echo How much RAM do you want to use?
# echo What mods do you want to use?
# echo Which mods do you want to add?

working_dir="$HOME/minecraft_server"
mkdir ${working_dir}
touch "${working_dir}/start_server.sh"

URL="https://maven.minecraftforge.net/net/minecraftforge/forge/${minecraft_version}/forge-${forge_version}-installer.jar"
mc_forge_version="${minecraft_version}-${forge_version}"

echo "Downloading installer"
# wget "$" "$URL"

echo "Installing Server"
sleep 5
# java -jar forge-${mc_forge_version}-installer.jar --installServer
echo "Removing Installer"
# rm "forge-${mc_forge_version}-installer.jar"

chmod +x "${working_dir}/start_server.sh"
echo "java -Djava.awt.headless=true @user_jvm_args.txt @libraries/net/minecraftforge/forge/"${mc_forge_version}"/unix_args.txt "$mc_forge_version"" >> "${working_dir}/start_server.sh"
# sh startServer.sh "${mc_forge_version}"



