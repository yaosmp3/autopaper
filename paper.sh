#!/bin/bash

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Java is not installed. Please install Java and try again."
    exit 1
fi

# Create server directory if it doesn't exist
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

    # Attempt to download the file, but only check the header 
    if wget --spider -S "$paper_url" 2>&1 | grep -q "HTTP/1.1 200 OK"; then
        wget "$paper_url" -O "paper.jar" || { echo "Download failed."; exit 1; }
    else
        echo "Invalid Paper download link. Please try again."
        read -p "Paste the Paper download link: " paper_url
        download_paper "$paper_url" # Retry the download with the new link
    fi
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

# Create plugins folder if it doesn't exist
if [ ! -d "plugins" ]; then
    mkdir "plugins"
fi

# Download Playit.gg plugin
PLAYIT_URL="https://github.com/playit-cloud/playit-minecraft-plugin/releases/latest/download/playit-minecraft-plugin.jar"
wget -P plugins "$PLAYIT_URL" || { echo "Failed to download Playit plugin."; exit 1; }

# Agree to EULA
echo "eula=true" > eula.txt

# Create server.properties file
cat <<EOL > server.properties
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
enforce-secure-profile=$ENFORCE_SECURE_PROFILE
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
online-mode=$ONLINE_MODE
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
