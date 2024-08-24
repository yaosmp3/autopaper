#!/bin/bash

# Function to handle invalid download link
download_file() {
    local file_url="$1"
    local file_name="$2"

    # Attempt to download the file, but only check the header 
    if wget --spider -S "$file_url" 2>&1 | grep -q "HTTP/1.1 200 OK"; then
        wget "$file_url" -O "$file_name" || { echo "Download failed."; exit 1; }
    else
        echo "Invalid download link. Please try again."
        read -p "Paste the download link: " file_url
        download_file "$file_url" "$file_name" # Retry the download with the new link
    fi
}

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Java is not installed. Please install Java and try again."
    exit 1
fi

# Function to create server.properties
create_server_properties() {
    local file_path="$1"
    local online_mode="$2"
    local enforce_secure_profile="$3"

    cat <<EOL > "$file_path"
#Minecraft server properties
#Sat Aug 24 05:45:45 UTC 2024
accepts-transfers=false
allow-flight=false
allow-nether=true
broadcast-console-to-ops=true
broadcast-rcon-to-ops=true
bug-report-link=
debug=false
difficulty=hard
enable-command-block=false
enable-jmx-monitoring=false
enable-query=false
enable-rcon=false
enable-status=true
enforce-secure-profile=$enforce_secure_profile
enforce-whitelist=false
entity-broadcast-range-percentage=100
force-gamemode=false
function-permission-level=2
gamemode=survival
generate-structures=true
generator-settings={}
hardcore=false
hide-online-players=false
initial-disabled-packs=
initial-enabled-packs=vanilla
level-name=world
level-seed=
level-type=minecraft\:normal
log-ips=true
max-chained-neighbor-updates=1000000
max-players=20
max-tick-time=60000
max-world-size=29999984
motd=A Minecraft Server
network-compression-threshold=256
online-mode=$online_mode
op-permission-level=4
player-idle-timeout=0
prevent-proxy-connections=false
pvp=true
query.port=25565
rate-limit=0
rcon.password=
rcon.port=25575
region-file-compression=deflate
require-resource-pack=false
resource-pack=
resource-pack-id=
resource-pack-prompt=
resource-pack-sha1=
server-ip=
server-port=25565
simulation-distance=10
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
spawn-protection=16
sync-chunk-writes=true
text-filtering-config=
use-native-transport=true
view-distance=20
white-list=false
EOL
}

# Ask user to select between Paper or Fabric
while true; do
    read -p "Do you want to install 'paper' or 'fabric'? " server_type
    case "$server_type" in
        [Pp]* )
            SERVER_DIR="minecraft_server"
            if [ ! -d "$SERVER_DIR" ]; then
                mkdir "$SERVER_DIR"
            fi

            # Change to server directory
            cd "$SERVER_DIR"

            # Function to download Paper JAR and handle invalid links
            download_paper() {
                local paper_url="$1"
                local paper_jar=$(basename "$paper_url")

                download_file "$paper_url" "paper.jar"
            }

            # Ask if the user wants to provide a custom Paper download link
            while true; do
                read -p "Do you want to provide a custom Paper download link? (y/n): " choice
                case "$choice" in
                    [Yy]* ) 
                        read -p "Paste the Paper download link: " PAPER_URL
                        download_paper "$PAPER_URL"
                        break;;
                    [Nn]* ) 
                        while true; do
                            read -p "Are you sure you want to install Paper version 1.21.1? (y/n): " confirm
                            case "$confirm" in
                                [Yy]* ) 
                                    PAPER_URL="https://api.papermc.io/v2/projects/paper/versions/1.21.1/builds/40/downloads/paper-1.21.1-40.jar"
                                    download_paper "$PAPER_URL"
                                    break 2;; # Break out of both loops
                                [Nn]* ) 
                                    break;; # Go back to the initial custom link question
                                * ) echo "Please answer 'y' or 'n'.";;
                            esac
                        done
                        ;;
                    * ) echo "Please answer 'y' or 'n'.";;
                esac
            done

            # Ask if the user wants to add a plugin
            if [ ! -d "plugins" ]; then
                mkdir "plugins"
            fi

            while true; do
                read -p "Do you want to add a plugin? (y/n): " add_plugin
                case "$add_plugin" in
                    [Yy]* ) 
                        while true; do
                            read -p "Paste the plugin download link: " PLUGIN_URL
                            # Attempt to download the plugin
                            PLUGIN_NAME="plugins/$(basename "$PLUGIN_URL")"
                            download_file "$PLUGIN_URL" "$PLUGIN_NAME"
                            if [ $? -eq 0 ]; then
                                echo "Plugin downloaded successfully: $PLUGIN_NAME"
                            else
                                echo "Failed to download plugin. Please try again."
                                continue
                            fi

                            # Ask if the user wants to add another plugin
                            read -p "Do you want to add another plugin? (y/n): " more_plugins
                            case "$more_plugins" in
                                [Nn]* ) break 2;; # Break out of both loops
                                * ) echo "Please answer 'y' or 'n'.";;
                            esac
                        done
                        ;;
                    [Nn]* ) 
                        break;;
                    * ) echo "Please answer 'y' or 'n'.";;
                esac
            done

            # Ask if the server should be cracked
            while true; do
                read -p "Do you want your Minecraft server to be a cracked server? (y/n): " cracked_choice
                case "$cracked_choice" in
                    [Yy]* ) 
                        ONLINE_MODE="false"
                        ENFORCE_SECURE_PROFILE="false"
                        break;;
                    [Nn]* ) 
                        ONLINE_MODE="true"
                        ENFORCE_SECURE_PROFILE="true"
                        break;;
                    * ) echo "Please answer 'y' or 'n'.";;
                esac
            done

            # Download Playit plugin
            PLAYIT_URL="https://github.com/playit-cloud/playit-minecraft-plugin/releases/latest/download/playit-minecraft-plugin.jar"
            wget -P plugins "$PLAYIT_URL" || { echo "Failed to download Playit plugin."; exit 1; }

            # Agree to EULA
            echo "eula=true" > eula.txt

            # Create server.properties file
            create_server_properties "server.properties" "$ONLINE_MODE" "$ENFORCE_SECURE_PROFILE"

            # Start server for the first time to generate necessary files
            java -Xmx8G -jar "paper.jar" nogui

            # Stop the server gracefully (manual intervention needed here)
            echo "Please stop the server manually before continuing."

            # Create start script
            echo "#!/bin/bash
            java -Xmx8G -jar paper.jar nogui
            " > start.sh
            chmod +x start.sh

            echo "Minecraft Paper server installation complete!"

            # Automatically start the server
            echo "Starting the server..."
            ./start.sh
            break;;
        [Ff]* )
            SERVER_DIR="fabric_server"
            if [ ! -d "$SERVER_DIR" ]; then
                mkdir "$SERVER_DIR"
            fi

            # Change to server directory
            cd "$SERVER_DIR"

            # Function to download Fabric JAR and handle invalid links
            download_fabric() {
                local fabric_url="$1"
                local fabric_jar=$(basename "$fabric_url")

                download_file "$fabric_url" "$fabric_jar"
            }

            # Ask for Fabric download link
            while true; do
                read -p "Paste the Fabric download link: " FABRIC_URL
                download_fabric "$FABRIC_URL"
                break
            done

            # Ask if the server should be cracked
            while true; do
                read -p "Do you want your Minecraft server to be a cracked server? (y/n): " cracked_choice
                case "$cracked_choice" in
                    [Yy]* ) 
                        ONLINE_MODE="false"
                        ENFORCE_SECURE_PROFILE="false"
                        break;;
                    [Nn]* ) 
                        ONLINE_MODE="true"
                        ENFORCE_SECURE_PROFILE="true"
                        break;;
                    * ) echo "Please answer 'y' or 'n'.";;
                esac
            done

            # Create eula.txt
            echo "eula=true" > eula.txt

            # Install Playit
            curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
            echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list
            sudo apt update
            sudo apt install playit

            # Ask if the user wants to add a mod
            if [ ! -d "mods" ]; then
                mkdir "mods"
            fi

            while true; do
                read -p "Do you want to add a mod? (y/n): " add_mod
                case "$add_mod" in
                    [Yy]* ) 
                        while true; do
                            read -p "Paste the mod download link: " MOD_URL
                            MOD_NAME="mods/$(basename "$MOD_URL")"
                            download_file "$MOD_URL" "$MOD_NAME"
                            if [ $? -eq 0 ]; then
                                echo "Mod downloaded successfully: $MOD_NAME"
                            else
                                echo "Failed to download mod. Please try again."
                                continue
                            fi

                            # Ask if the user wants to add another mod
                            read -p "Do you want to add another mod? (y/n): " more_mods
                            case "$more_mods" in
                                [Nn]* ) break 2;; # Break out of both loops
                                * ) echo "Please answer 'y' or 'n'.";;
                            esac
                        done
                        ;;
                    [Nn]* ) 
                        break;;
                    * ) echo "Please answer 'y' or 'n'.";;
                esac
            done

            # Create start script for Fabric
            echo "#!/bin/bash
            java -Xmx8G -jar $(basename "$FABRIC_URL") nogui
            " > start.sh
            chmod +x start.sh

            echo "Minecraft Fabric server installation complete!"

            # Automatically start the server
            echo "Starting the server..."
            ./start.sh
            break;;
        * ) echo "Please answer 'paper' or 'fabric'.";;
    esac
done
