#!/bin/bash
# Script to install Homebrew then run a python program to do a jamf recon.
# Author: Mehraz Ahmed at jukelyn dot com
# Version: 2.0 - 22 Apr 2025
# Jamf Policy Script: Install Homebrew (Non-Interactive) with Path Persistence.
# Uncomment line 30 ("exec >> "$LOG" 2>&1") when using jamf to deploy this script.
set -e

# Variables
LOGFOLDER="/private/var/log/"
LOG="${LOGFOLDER}Homebrew.log"
ZIP_URL="https://github.com/Jukelyn/macOS-Enrollment-Program/archive/refs/heads/main.zip"
DEST_DIR="$HOME/Downloads"
PROJECT_DIR="$DEST_DIR/macOS-Enrollment-Program-main"

# Full paths for commands
CURL_BIN="/usr/bin/curl"
BASH_BIN="/bin/bash"
MKDIR_BIN="/bin/mkdir"
UNZIP_BIN="/usr/bin/unzip"

BREW_PREFIX="/opt/homebrew/"
BREW_BIN="/opt/homebrew/bin/brew"
WGET_BIN="/opt/homebrew/bin/wget"

# Create log folder if needed
[ -d "$LOGFOLDER" ] || "$MKDIR_BIN" -p "$LOGFOLDER"

# Redirect all output to log file
# exec >> "$LOG" 2>&1

echo "===== Script started at $(date) ====="

# Install Homebrew non-interactively if not present
if ! [ -x "$BREW_BIN" ]; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 "$CURL_BIN" -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | "$BASH_BIN"
  eval "$("$BREW_PREFIX/bin/brew" shellenv)"
else
  echo "Homebrew already installed."
fi

# Install wget if missing
if ! [ -x "$WGET_BIN" ]; then
  echo "Installing wget..."
  "$BREW_BIN" install wget
else
  echo "wget already installed."
fi

# Create destination dir
[ -d "$DEST_DIR" ] || "$MKDIR_BIN" -p "$DEST_DIR"

# Download ZIP
echo "Downloading ZIP..."
"$WGET_BIN" -O "$DEST_DIR/main.zip" "$ZIP_URL"

# Unzip the project
echo "Unzipping project..."
"$UNZIP_BIN" -o "$DEST_DIR/main.zip" -d "$DEST_DIR"

# Install python3 and python-tk
echo "Installing python3 and python-tk..."
"$BREW_BIN" install python3 python-tk

# Move into project directory
cd "$PROJECT_DIR"

# Set up Python venv and run the app
echo "Creating virtual environment..."
"$BREW_PREFIX/bin/python3" -m venv "$PROJECT_DIR/venv"

echo "Activating virtual environment..."
source "$PROJECT_DIR/venv/bin/activate"

pip install --upgrade pip
pip install -r requirements.txt

echo "Running main.py..."
python main.py  # May need sudo before this for the recon command in the program to work, I think... will need to test perhaps

deactivate

echo "===== Script finished at $(date) ====="
