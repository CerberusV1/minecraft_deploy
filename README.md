# Minecraft-Server Deployment and management script
This is an deployment script for minecraft servers. It gets developed to make it easier to setup a minecraft server. It consists of two scripts. The first script (`deploy.sh`) will never be on your computer.   "`server_manager.sh`" gets pulled on your computer in order for you to manage the server.

## Features
- Server management script:
    - Configuring the EULA
    - Configuring the RAM
    - Starting and reconnecting to the server (using tmux)
- Deployment
    - Setting the server name
    - Available for every minecraft and mod loader version 
 


# Requirements:
This script should run on all distribution which use the apt packet manager.

# How To Use
Copy the line below and paste it into your terminal and press `RETURN`. 

>[!NOTE]
>The script will check for dependencies for the server automatically once started. After checking and installing dependencies the script will prompt you to enter the name for your server. Until here `java` and `tmux`got installed and no other changes were made. As soon as you enter a server name and press RETURN, the folder structure gets created. If you exit the script after entering an name you need to remove it yourself.


```
bash -c "$(curl -sS https://raw.githubusercontent.com/CerberusV1/minecraft_deploy/refs/heads/main/deploy.sh)"
```

# ToDo´s
- Adding Fabric and Paper support
- Refactor `deploy.sh` to unify the installation process for all loaders
- Adding the option to set the RAM in `user_jvm_args.txt`
- Adding check for existing sessions before starting the server
- Add support for a non-headless session (might not happen)
- Adding mod installer from link
- Adding world import (ideas on how to do that would be appreciated)
- Adding option to import/export white/blacklist