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
# Function to check if a program is installed
check_installed() {
    if ! which "$1" > /dev/null 2>&1; then
        echo "$1 is not installed."
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
        echo "The changes in rc.local are already present."
        return 0
    else
        echo "The changes in rc.local are missing."
        return 1
    fi
}

# Check if the changes in rc.local are already applied
check_rc_local
rc_local_modified=$?

# If Java or Tmux is not installed, or rc.local is not modified, install/modify
if [[ $java_installed -ne 0 || $tmux_installed -ne 0 || $rc_local_modified -ne 0 ]]; then
    read -p "Java, Tmux, or rc.local changes are missing. Do you want to install the required programs/make changes now? (y/n): " answer

    if [[ "$answer" = "y" ]]; then
        # Update and install the packages
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
        echo "Installation/changes aborted. Exiting script."
        exit 1
    fi

else
    echo "All required programs are already installed and rc.local is configured. Proceeding with installation..."
fi
