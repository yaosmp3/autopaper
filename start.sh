#!/bin/bash

# Define the server folder names
MINECRAFT_SERVER="minecraft_server"
FABRIC_SERVER="fabric_server"
PAPER_JAR="paper"
FABRIC_JAR="fabric-server.jar"

# Function to start the server
start_server() {
    local server_folder=$1
    local server_jar=$2
    local memory=$3
    echo "Starting server in $server_folder with $memory GB of RAM..."
    cd "$server_folder" || { echo "Error: Failed to cd into $server_folder"; exit 1; } # cd and handle error
    java -Xmx"${memory}G" -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar "$server_jar" nogui

}

# Ask the user for RAM amount
read -p "Enter the amount of RAM to allocate (in GB): " MEMORY

# Ask the user which server to start
while true; do
    echo "Do you want to start your Fabric or Paper server?"
    read -p "Type 'paper' or 'fabric': " server_choice

    case $server_choice in
        paper)
            if [ -d "$MINECRAFT_SERVER" ]; then
                start_server "$MINECRAFT_SERVER" "$PAPER_JAR" "$MEMORY"
            else
                echo "Error: minecraft_server folder not found!"
            fi
            break
            ;;
        fabric)
            if [ -d "$FABRIC_SERVER" ]; then
                start_server "$FABRIC_SERVER" "$FABRIC_JAR" "$MEMORY"
            else
                echo "Error: fabric_server folder not found!"
            fi
            break
            ;;
        *)
            echo "Invalid choice. Please type 'paper' or 'fabric'."
            ;;
    esac
done
