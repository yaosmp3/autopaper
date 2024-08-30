#!/bin/bash

# Define the server folder names
MINECRAFT_SERVER="minecraft_server"
FABRIC_SERVER="fabric_servers"
PAPER_JAR="paper.jar"
MEMORY="8G"

# Function to start the server
start_server() {
    local server_folder=$1
    echo "Starting server in $server_folder..."
    cd "$server_folder"
    java -Xmx$MEMORY -jar $PAPER_JAR
}

# Ask the user which server to start
while true; do
    echo "Do you want to start your Fabric or Paper server?"
    read -p "Type 'paper' or 'fabric': " server_choice

    case $server_choice in
        paper)
            if [ -d "$MINECRAFT_SERVER" ]; then
                start_server "$MINECRAFT_SERVER"
            else
                echo "Error: minecraft_server folder not found!"
            fi
            break
            ;;
        fabric)
            if [ -d "$FABRIC_SERVER" ]; then
                start_server "$FABRIC_SERVER"
            else
                echo "Error: fabric_servers folder not found!"
            fi
            break
            ;;
        *)
            echo "Invalid choice. Please type 'paper' or 'fabric'."
            ;;
    esac
done
