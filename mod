#!/bin/bash

menu() {
    echo "========================================="
    echo "Select an option:"
    echo "1. Download Yaoland Season 3 Requirements (Mods + Fabric)"
    echo "2. Download OpenJDK 22 (if you don't have the latest Java)"
    echo "3. Download SKlauncher"
    echo "4. Exit"
    echo "========================================="
    read -p "Enter your choice (1-4): " choice

    case $choice in
        1) download_mods ;;
        2) download_openjdk ;;
        3) download_sklauncher ;;
        4) exit_script ;;
        *) echo "Invalid choice" && menu ;;
    esac
}

download_mods() {
    echo "Downloading Yaoland Season 3 Requirements..."
    curl -o ~/updatemod "https://raw.githubusercontent.com/JoshBeCute/letssee/main/updatemod"
    chmod +x ~/updatemod
    bash ~/updatemod

    curl -o ~/fabric-installer.jar "https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar"
    java -jar ~/fabric-installer.jar client -mcversion 1.21.1 -loader 0.16.5
    rm ~/fabric-installer.jar
    menu
}

download_openjdk() {
    echo "Downloading OpenJDK 22..."
    curl -o ~/Downloads/openjdk-22_osx-x64_bin.tar.gz "https://download.oracle.com/java/22/latest/jdk-22_osx-x64_bin.tar.gz"
    tar -xzf ~/Downloads/openjdk-22_osx-x64_bin.tar.gz -C /Library/Java/JavaVirtualMachines/
    echo "OpenJDK 22 installed."
    menu
}

download_sklauncher() {
    echo "Downloading SKlauncher..."
    curl -o ~/Downloads/SKlauncher-3.2.dmg "https://skmedix.pl/binaries/skl/3.2.10/x64/SKlauncher-3.2.dmg"
    echo "Please install SKlauncher by opening the .dmg file."
    open ~/Downloads/SKlauncher-3.2.dmg
    menu
}

exit_script() {
    echo "Exiting..."
    exit 0
}

menu
