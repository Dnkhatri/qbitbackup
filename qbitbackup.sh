#!/bin/bash

# Define the path to the directory where backup files are stored
BACKUP_DIR="$HOME/qbackup/"

# Function to create a backup
create_backup() {
    # Get the current date for the backup filename
    DATE=$(date +"%Y%m%d%H%M%S")

    # Define the backup filenames
    SETTINGS_BACKUP="$BACKUP_DIR"qBittorrentSettings_"$DATE".zip
    DATA_BACKUP="$BACKUP_DIR"qBittorrentData_"$DATE".zip

    # Create temporary directories to store the backup files
    SETTINGS_TMP_DIR=$(mktemp -d)
    DATA_TMP_DIR=$(mktemp -d)

    # Copy qBittorrent settings to the temporary directory
    cp -r "$HOME/.config/qBittorrent/" "$SETTINGS_TMP_DIR"

    # Copy qBittorrent data to the temporary directory
    cp -r "$HOME/.local/share/qBittorrent/" "$DATA_TMP_DIR"

    # Create zip archives of the backups with relative paths
    pushd "$SETTINGS_TMP_DIR" && zip -r "$SETTINGS_BACKUP" * && popd
    pushd "$DATA_TMP_DIR" && zip -r "$DATA_BACKUP" * && popd

    # Remove the temporary directories
    rm -rf "$SETTINGS_TMP_DIR"
    rm -rf "$DATA_TMP_DIR"

    # Print the success message
    echo "qBittorrent settings backup created: $SETTINGS_BACKUP"
    echo "qBittorrent data backup created: $DATA_BACKUP"
}

# Function to restore from a backup
restore_backup() {
    # List all backup files in the directory
    SETTINGS_BACKUP_FILES=("$BACKUP_DIR"qBittorrentSettings_*.zip)
    DATA_BACKUP_FILES=("$BACKUP_DIR"qBittorrentData_*.zip)

    # Check if there are any backup files
    if [ ${#SETTINGS_BACKUP_FILES[@]} -eq 0 ] || [ ${#DATA_BACKUP_FILES[@]} -eq 0 ]; then
        echo "No backup files found in $BACKUP_DIR"
        exit 1
    fi

    # Prompt the user to choose a backup file for settings
    echo "Choose a settings backup file to restore:"
    select SETTINGS_FILE in "${SETTINGS_BACKUP_FILES[@]}"; do
        if [ -n "$SETTINGS_FILE" ]; then
            # Extract the selected settings backup file to the home directory
            unzip -o "$SETTINGS_FILE" -d "$HOME"

            # Prompt the user to choose a backup file for data
            echo "Choose a data backup file to restore:"
            select DATA_FILE in "${DATA_BACKUP_FILES[@]}"; do
                if [ -n "$DATA_FILE" ]; then
                    # Extract the selected data backup file to the home directory
                    unzip -o "$DATA_FILE" -d "$HOME"

                    # Print the success message
                    echo "qBittorrent settings and data restored from:"
                    echo "Settings: $SETTINGS_FILE"
                    echo "Data: $DATA_FILE"
                    break
                else
                    echo "Invalid selection. Please choose a number from the list."
                fi
            done
            break
        else
            echo "Invalid selection. Please choose a number from the list."
        fi
    done
}

# Display menu for user choice
echo "1. Create Backup"
echo "2. Restore from Backup"
echo -n "Choose an option (1 or 2): "
read OPTION

case $OPTION in
    1)
        create_backup
        ;;
    2)
        restore_backup
        ;;
    *)
        echo "Invalid option. Please choose 1 or 2."
        ;;
esac

