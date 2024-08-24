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

# Function to install mods
install_mods() {
    local directory="fabric_server/mods"
    
    if [ ! -d "$directory" ]; then
        mkdir -p "$directory"
    fi

    local file_method_done=false

    # Ask if the user wants to provide a file with download links
    while true; do
        read -p "Do you have a file with mod download links? (y/n): " file_option
        case "$file_option" in
            [Yy]* )
                read -p "Enter the file name with mod download links: " file_name
                if [ -f "$file_name" ]; then
                    while IFS= read -r download_link; do
                        local file_name="$directory/$(basename "$download_link")"

                        # Check if file already exists
                        if [ ! -f "$file_name" ]; then
                            if download_file "$download_link" "$file_name"; then
                                echo "Mod downloaded successfully: $file_name"
                            else
                                echo "Failed to download mod. Please check the link and try again."
                            fi
                        else
                            echo "Mod $file_name already exists."
                        fi
                    done < "$file_name"
                    file_method_done=true
                else
                    echo "File not found. Proceeding with manual input."
                fi
                break
                ;;
            [Nn]* )
                break
                ;;
            * )
                echo "Please answer 'y' or 'n'."
                ;;
        esac
    done

    # Proceed with manual input if the file is not provided or invalid, only if the file method was not successful
    if ! $file_method_done; then
        while true; do
            read -p "Paste the mod download link: " download_link
            local file_name="$directory/$(basename "$download_link")"

            # Check if file already exists
            if [ ! -f "$file_name" ]; then
                if download_file "$download_link" "$file_name"; then
                    echo "Mod downloaded successfully: $file_name"
                else
                    echo "Failed to download mod. Please try again."
                    continue
                fi
            else
                echo "Mod $file_name already exists."
            fi

            # Ask if the user wants to add more mods
            if ! prompt_valid_input "Do you want to add another mod? (y/n): "; then
                break
            fi
        done
    fi
}

# Function to install plugins
install_plugins() {
    local directory="minecraft_server/plugins"

    if [ ! -d "$directory" ]; then
        mkdir -p "$directory"
    fi

    local file_method_done=false

    # Ask if the user wants to provide a file with download links
    while true; do
        read -p "Do you have a file with plugin download links? (y/n): " file_option
        case "$file_option" in
            [Yy]* )
                read -p "Enter the file name with plugin download links: " file_name
                if [ -f "$file_name" ]; then
                    while IFS= read -r download_link; do
                        local file_name="$directory/$(basename "$download_link")"

                        # Check if file already exists
                        if [ ! -f "$file_name" ]; then
                            if download_file "$download_link" "$file_name"; then
                                echo "Plugin downloaded successfully: $file_name"
                            else
                                echo "Failed to download plugin. Please check the link and try again."
                            fi
                        else
                            echo "Plugin $file_name already exists."
                        fi
                    done < "$file_name"
                    file_method_done=true
                else
                    echo "File not found. Proceeding with manual input."
                fi
                break
                ;;
            [Nn]* )
                break
                ;;
            * )
                echo "Please answer 'y' or 'n'."
                ;;
        esac
    done

    # Proceed with manual input if the file is not provided or invalid, only if the file method was not successful
    if ! $file_method_done; then
        while true; do
            read -p "Paste the plugin download link: " download_link
            local file_name="$directory/$(basename "$download_link")"

            # Check if file already exists
            if [ ! -f "$file_name" ]; then
                if download_file "$download_link" "$file_name"; then
                    echo "Plugin downloaded successfully: $file_name"
                else
                    echo "Failed to download plugin. Please try again."
                    continue
                fi
            else
                echo "Plugin $file_name already exists."
            fi

            # Ask if the user wants to add more plugins
            if ! prompt_valid_input "Do you want to add another plugin? (y/n): "; then
                break
            fi
        done
    fi
}

# Main script execution
echo "This script will help you install mods or plugins for your Minecraft server."

# Check if a directory for Paper or Fabric server exists and ask for the type
while true; do
    read -p "Is this for Paper or Fabric? (paper/fabric): " server_type
    case "$server_type" in
        [Pp]* )
            install_plugins
            break
            ;;
        [Ff]* )
            install_mods
            break
            ;;
        * )
            echo "Invalid choice. Please enter 'paper' or 'fabric'."
            ;;
    esac
done
