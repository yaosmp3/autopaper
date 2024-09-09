#!/bin/bash

# Function to handle invalid download link
download_file() {
    local file_url="$1"
    local file_name="$2"

    # Attempt to download the file, but only check the header first
    if wget --spider -S "$file_url" 2>&1 | grep -q "HTTP/1.1 200 OK"; then
        # Download the file using curl silently and save it with the specified name
        curl -s -o "$file_name" "$file_url" || { echo "Download failed."; return 1; }
    else
        echo "Invalid download link: $file_url"
        return 1
    fi
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

# Function to update Playit plugin
update_playit_plugin() {
    local playit_dir="minecraft_server/plugins"
    local playit_url="https://github.com/playit-cloud/playit-minecraft-plugin/releases/latest/download/playit-minecraft-plugin.jar"
    local playit_file="$playit_dir/playit-minecraft-plugin.jar"

    # Create plugins directory if it does not exist
    if [ ! -d "$playit_dir" ]; then
        mkdir -p "$playit_dir"
    fi

    if download_file "$playit_url" "$playit_file"; then
        echo "Playit plugin downloaded successfully: $playit_file"
    else
        echo "Failed to download Playit plugin."
    fi
}

# Function to update Paper JAR file with version selection
update_paper_jar() {
    local server_dir="minecraft_server"

    # Ensure the server directory exists
    if [ ! -d "$server_dir" ]; then
        mkdir -p "$server_dir"
    fi

    # Ask for the Minecraft version
    read -p "Enter the Minecraft version you want (e.g., 1.21.1): " mc_version

    # Define the base URL for PaperMC API
    local base_url="https://api.papermc.io/v2/projects/paper/versions/${mc_version}/builds/"

    # Fetch the build information from the API silently
    local response=$(curl -s "${base_url}")

    # Extract the latest build number from the response
    local build_number=$(echo "$response" | grep -oP '"build":\K\d+' | head -n 1)

    if [ -z "$build_number" ]; then
        echo "Failed to find the latest build number. Please check the version or try again later."
        exit 1
    fi

    # Construct the download URL
    local download_url="https://api.papermc.io/v2/projects/paper/versions/${mc_version}/builds/${build_number}/downloads/paper-${mc_version}-${build_number}.jar"
    local paper_file="$server_dir/paper.jar"

    # Download the file and rename it to paper.jar
    if download_file "$download_url" "$paper_file"; then
        echo "Paper JAR file downloaded successfully: $paper_file"
    else
        echo "Failed to download Paper JAR file."
    fi
}

# Function to update Fabric JAR file with version selection
update_fabric_jar() {
    local server_dir="fabric_server"

    # Ensure the server directory exists
    if [ ! -d "$server_dir" ]; then
        mkdir -p "$server_dir"
    fi

    # Ask for the Minecraft version
    read -p "Enter the Minecraft version you want (e.g., 1.21.1): " mc_version

    # Fetch the first 10 lines from the loader versions JSON
    local json_data=$(curl -s "https://meta.fabricmc.net/v2/versions/loader" | head -n 10)

    # Extract the latest maven version (e.g., 0.16.3)
    local maven_version=$(echo $json_data | grep -oP '"maven":\s*".*?:\K\d+\.\d+\.\d+' | head -n 1)

    # Construct the final download URL
    local final_url="https://meta.fabricmc.net/v2/versions/loader/${mc_version}/${maven_version}/1.0.1/server/jar"
    local fabric_file="$server_dir/fabric-server.jar"

    # Download the file and rename it to fabric-server.jar
    if download_file "$final_url" "$fabric_file"; then
        echo "Fabric JAR file downloaded successfully: $fabric_file"
    else
        echo "Failed to download Fabric JAR file."
    fi
}

# Main script execution
echo "Choose what you want to update:"
echo "1. Playit plugin"
echo "2. Paper JAR file"
echo "3. Fabric JAR file"

while true; do
    read -p "Enter your choice (1/2/3): " choice
    case "$choice" in
        1)
            update_playit_plugin
            break
            ;;
        2)
            update_paper_jar
            break
            ;;
        3)
            update_fabric_jar
            break
            ;;
        *)
            echo "Invalid choice. Please enter '1', '2', or '3'."
            ;;
    esac
done
