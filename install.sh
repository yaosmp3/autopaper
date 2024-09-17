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
simulation-distance=7
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
spawn-protection=16
sync-chunk-writes=true
text-filtering-config=
use-native-transport=true
view-distance=7
white-list=false
EOL
}

# Function to handle valid input
prompt_valid_input() {
    local prompt_message="$1"
    local response
    while true; do
        read -p "$prompt_message" response
        case "$response" in
            [Yy]* ) return 0;;  # Success
            [Nn]* ) return 1;;  # Failure
            * ) echo "Please answer 'y' or 'n'.";;
        esac
    done
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
        
            # Function to download Paper JAR
            download_paper() {
                # Ask for the Minecraft version
                read -p "Enter the Minecraft version you want (e.g., 1.21.1): " mc_version

                # Define the base URL for PaperMC API
                base_url="https://api.papermc.io/v2/projects/paper/versions/${mc_version}/builds/"

                # Fetch the build information from the API silently
                response=$(curl -s "${base_url}")

                # Extract the latest build number from the response
                build_number=$(echo "$response" | grep -oP '"build":\K\d+' | head -n 1)

                if [ -z "$build_number" ]; then
                    echo "Failed to find the latest build number. Please check the version or try again later."
                    exit 1
                fi

                # Construct the download URL
                download_url="https://api.papermc.io/v2/projects/paper/versions/${mc_version}/builds/${build_number}/downloads/paper-${mc_version}-${build_number}.jar"

                # Download the file using curl silently and rename it to paper.jar
                curl -s -o "paper.jar" "$download_url"

                echo "Downloaded from: $download_url"
            }

            download_paper

            # Ask if the user wants to add a plugin
            if [ ! -d "plugins" ]; then
                mkdir "plugins"
            fi

            while true; do
                prompt_valid_input "Do you want to add a plugin? (y/n): " && {
                    while true; do
                        read -p "Paste the plugin download link: " PLUGIN_URL
                        PLUGIN_NAME="plugins/$(basename "$PLUGIN_URL")"
                        download_file "$PLUGIN_URL" "$PLUGIN_NAME"
                        if [ $? -eq 0 ]; then
                            echo "Plugin downloaded successfully: $PLUGIN_NAME"
                        else
                            echo "Failed to download plugin. Please try again."
                            continue
                        fi

                        # Ask if the user wants to add another plugin
                        prompt_valid_input "Do you want to add another plugin? (y/n): " || break 2
                    done
                } || break
            done

            # Ask if the server should be cracked
            while true; do
                prompt_valid_input "Do you want your Minecraft server to be a cracked server? (y/n): " && {
                    ONLINE_MODE="false"
                    ENFORCE_SECURE_PROFILE="false"
                    break
                } || {
                    ONLINE_MODE="true"
                    ENFORCE_SECURE_PROFILE="true"
                    break
                }
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

            # Ask for the Minecraft version
            read -p "Enter the Minecraft version you want (e.g., 1.21.1): " mc_version

            # Fetch the first 10 lines from the loader versions JSON
            json_data=$(curl -s "https://meta.fabricmc.net/v2/versions/loader" | head -n 10)

            # Extract the latest maven version (e.g., 0.16.3)
            maven_version=$(echo $json_data | grep -oP '"maven":\s*".*?:\K\d+\.\d+\.\d+' | head -n 1)

            # Construct the final download URL
            final_url="https://meta.fabricmc.net/v2/versions/loader/${mc_version}/${maven_version}/1.0.1/server/jar"

            # Download the file using curl and rename it to fabric-server.jar
            curl -s -o "fabric-server.jar" "$final_url"

            echo "Downloaded from: $final_url"

            # Ask if the server should be cracked
            while true; do
                prompt_valid_input "Do you want your Minecraft server to be a cracked server? (y/n): " && {
                    ONLINE_MODE="false"
                    ENFORCE_SECURE_PROFILE="false"
                    break
                } || {
                    ONLINE_MODE="true"
                    ENFORCE_SECURE_PROFILE="true"
                    break
                }
            done

            # Create eula.txt
            echo "eula=true" > eula.txt

            # Create server.properties file in Fabric server directory
            create_server_properties "server.properties" "$ONLINE_MODE" "$ENFORCE_SECURE_PROFILE"

            # Install Playit
            curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor > /usr/share/keyrings/playit-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/playit-archive-keyring.gpg] https://playit-cloud.github.io/ppa/ stable main" | tee /etc/apt/sources.list.d/playit.list
            apt-get update
            apt-get install -y playit

            # Create start script for Fabric server
            echo "#!/bin/bash
            java -Xmx8G -jar fabric-server.jar nogui
            " > start.sh
            chmod +x start.sh

            echo "Minecraft Fabric server installation complete!"

            # Automatically start the server
            echo "Starting the server..."
            ./start.sh
            break;;
        * ) echo "Invalid option. Please enter 'paper' or 'fabric'.";;
    esac
done
