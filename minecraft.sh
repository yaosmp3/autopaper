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

# Ask if the user wants to provide a custom Paper download link
read -p "Do you want to provide a custom Paper download link? (y/n): " choice

if [ "$choice" == "y" ]; then
    read -p "Paste the Paper download link: " PAPER_URL
    PAPER_JAR=$(basename "$PAPER_URL") # Extract filename from URL
    wget "$PAPER_URL"
else
    # Download specific Paper version from the provided URL 
    PAPER_URL="https://api.papermc.io/v2/projects/paper/versions/1.21.1/builds/40/downloads/paper-1.21.1-40.jar" 
    PAPER_JAR=$(basename "$PAPER_URL")
    wget "$PAPER_URL"
fi

# Rename the downloaded JAR file to "paper.jar"
mv "$PAPER_JAR" "paper.jar"

# Create plugins folder if it doesn't exist
if [ ! -d "plugins" ]; then
    mkdir "plugins"
fi

# Download Playit.gg plugin (updated URL)
PLAYIT_URL="https://github.com/playit-cloud/playit-minecraft-plugin/releases/latest/download/playit-minecraft-plugin.jar"
wget -P plugins "$PLAYIT_URL"

# Agree to EULA
echo "eula=true" > eula.txt

# Start server for the first time to generate necessary files
# Use the specified JVM arguments here as well
java -Xmx8G -jar "paper.jar" nogui

# Stop the server
echo "stop" > server.console

# Create start script (updated JVM arguments)
echo "#!/bin/bash
java -Xmx8G -jar paper.jar nogui
" > start.sh
chmod +x start.sh

echo "Minecraft Paper server installation complete!"

# Automatically start the server
echo "Starting the server..."
./start.sh
