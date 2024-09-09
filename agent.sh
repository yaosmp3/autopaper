#!/bin/bash

# Ask the user for the agent key
read -p "Enter the agent key: " AGENTKEY

# Define the target directory and file
CONFIG_DIR="fabric_server/config"
TARGET_FILE="$CONFIG_DIR/playit-fabric-config.cfg"

# Check if the directory exists, if not, create it
if [[ ! -d "$CONFIG_DIR" ]]; then
    echo "Directory $CONFIG_DIR does not exist. Creating it now..."
    mkdir -p "$CONFIG_DIR"
    echo "Directory $CONFIG_DIR created."
fi

# Create the configuration file with the provided agent key and other settings
cat <<EOL > "$TARGET_FILE"
agent-secret=$AGENTKEY
autostart=true
mc-timeout-seconds=90000
EOL

echo "Configuration file created at $TARGET_FILE with the provided agent key."
