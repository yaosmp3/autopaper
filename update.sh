#!/bin/bash

# Function to handle invalid download link
download_file() {
    local file_url="$1"
    local file_name="$2"

    # Attempt to download the file, but only check the header
    if wget --spider -S "$file_url" 2>&1 | grep -q "HTTP/1.1 200 OK"; then
        wget "$file_url" -O "$file_name" || { echo "Download failed."; return 1; }
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
    local playit_url

    # Create plugins directory if it does not exist
    if [ ! -d "$playit_dir" ]; then
        mkdir -p "$playit_dir"
    fi

    while true; do
        read -p "Enter the download link for the Playit plugin: " playit_url
        local playit_file="$playit_dir/$(basename "$playit_url")"

        if download_file "$playit_url" "$playit_file"; then
            echo "Playit plugin downloaded successfully: $playit_file"
            break
        else
            echo "Failed to download Playit plugin. Please try again."
        fi
    done
}

# Function to update Paper JAR file
update_paper_jar() {
    local server_dir="minecraft_server"
    local paper_url

    # Ensure the server directory exists
    if [ ! -d "$server_dir" ]; then
        mkdir -p "$server_dir"
    fi

    while true; do
        read -p "Enter the download link for the Paper JAR file: " paper_url
        local paper_file="$server_dir/paper.jar"

        if download_file "$paper_url" "$paper_file"; then
            echo "Paper JAR file downloaded successfully: $paper_file"
            break
        else
            echo "Failed to download Paper JAR file. Please try again."
        fi
    done
}

# Function to update Fabric JAR file
update_fabric_jar() {
    local server_dir="fabric_server"
    local fabric_url

    # Ensure the server directory exists
    if [ ! -d "$server_dir" ]; then
        mkdir -p "$server_dir"
    fi

    while true; do
        read -p "Enter the download link for the Fabric JAR file: " fabric_url
        local fabric_file="$server_dir/$(basename "$fabric_url")"

        if download_file "$fabric_url" "$fabric_file"; then
            echo "Fabric JAR file downloaded successfully: $fabric_file"
            break
        else
            echo "Failed to download Fabric JAR file. Please try again."
        fi
    done
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
