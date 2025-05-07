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

# Create log folder if needed
[ -d "$LOGFOLDER" ] || "$MKDIR_BIN" -p "$LOGFOLDER"

# Redirect all output to log file
exec >> "$LOG" 2>&1

echo "===== Script started at $(date) ====="

if [ ! -d "$LOGFOLDER" ]; then
    mkdir $LOGFOLDER
fi

# Set the prefix based on the machine type
if [[ "$UNAME_MACHINE" == "arm64" ]]; then
    # M1/arm64 machines
    BREW_PREFIX="/opt/homebrew"
else
    # Intel machines
    BREW_PREFIX="/usr/local"
fi

if [[ -e "${BREW_PREFIX}/bin/brew" ]]; then
    su -l "$consoleuser" -c "${BREW_PREFIX}/bin/brew update"
    exit 0
fi

# are we in the right group
check_grp=$(groups ${consoleuser} | grep -c '_developer')

if [[ $check_grp != 1 ]]; then
    /usr/sbin/dseditgroup -o edit -a "${consoleuser}" -t user _developer
fi

function logme()
{
# Check to see if function has been called correctly
    if [ -z "$1" ] ; then
        echo "$(date) - logme function call error: no text passed to function! Please recheck code!" | tee -a $LOG
        exit 1
    fi

# Log the passed details
    echo -e "$(date) - $1" | tee -a $LOG
}

# Check and start logging
logme "Homebrew Installation"
#############################
# debug - commented out     #
# remove comments if needed #
############################# 
# logme "user is $consoleuser"
# logme "is user in dev group? $check_grp"

# Have the xcode command line tools been installed?
logme "Checking for Xcode Command Line Tools installation"
check=$( pkgutil --pkgs | grep -c "CLTools_Executables" )

if [[ "$check" != 1 ]]; then
    logme "Installing Xcode Command Tools"
    # This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    clt=$(softwareupdate -l | grep -B 1 -E "Command Line (Developer|Tools)" | awk -F"*" '/^ +\\*/ {print $2}' | sed 's/^ *//' | tail -n1)
    # the above don't work in Catalina so ...
    if [[ -z $clt ]]; then
    	clt=$(softwareupdate -l | grep  "Label: Command" | tail -1 | sed 's#\* Label: \(.*\)#\1#')
    fi
    softwareupdate -i "$clt"
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    /usr/bin/xcode-select --switch /Library/Developer/CommandLineTools
fi

# Is homebrew already installed?
if [[ ! -e "${HOMEBREW_PREFIX}/bin/brew" ]]; then
    # Install Homebrew. This doesn't like being run as root so we must do this manually.
    logme "Installing Homebrew"

    mkdir -p "${HOMEBREW_PREFIX}/Homebrew"
    # Curl down the latest tarball and install to ${HOMEBREW_PREFIX}/Homebrew
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "${HOMEBREW_PREFIX}/Homebrew"

    # Manually make all the appropriate directories and set permissions
    mkdir -p "${HOMEBREW_PREFIX}/Cellar" "${HOMEBREW_PREFIX}/Homebrew"
    mkdir -p "${HOMEBREW_PREFIX}/Caskroom" "${HOMEBREW_PREFIX}/Frameworks" "${HOMEBREW_PREFIX}/bin"
    mkdir -p "${HOMEBREW_PREFIX}/include" "${HOMEBREW_PREFIX}/lib" "${HOMEBREW_PREFIX}/opt" "${HOMEBREW_PREFIX}/etc" "${HOMEBREW_PREFIX}/sbin"
    mkdir -p "${HOMEBREW_PREFIX}/share/zsh/site-functions" "${HOMEBREW_PREFIX}/var"
    mkdir -p "${HOMEBREW_PREFIX}/share/doc" "${HOMEBREW_PREFIX}/man/man1" "${HOMEBREW_PREFIX}/share/man/man1"
    #chown -R "${consoleuser}":_developer "${HOMEBREW_PREFIX}/*"
    ##################################################################
    ### M Lamont changed to not overwrite existing folders, e.g jamf # 
    ###  also took th ebrackets out as this was stopping it working  #
    ###  and No I don't know why                                     #
    ##################################################################
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/Cellar"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/Homebrew"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/Caskroom"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/Frameworks"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/bin"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/include"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/lib"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/opt"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/etc"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/sbin"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/share"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/var"
    chown -R "$consoleuser":_developer "${HOMEBREW_PREFIX}/man"

    chmod -R g+rwx "${HOMEBREW_PREFIX}/*"
    chmod 755 "${HOMEBREW_PREFIX}/share/zsh" "${HOMEBREW_PREFIX}/share/zsh/site-functions"

    # Create a system wide cache folder  
    mkdir -p /Library/Caches/Homebrew
    chmod g+rwx /Library/Caches/Homebrew
    chown "${consoleuser}:_developer" /Library/Caches/Homebrew

    # put brew where we can find it
    ln -s "${HOMEBREW_PREFIX}/Homebrew/bin/brew" "${HOMEBREW_PREFIX}/bin/brew"

    # Install the MD5 checker or the recipes will fail
    su -l "$consoleuser" -c "${HOMEBREW_PREFIX}/bin/brew install md5sha1sum"
    echo 'export PATH="${HOMEBREW_PREFIX}/opt/openssl/bin:$PATH"' | \
	tee -a /Users/${consoleuser}/.bash_profile /Users/${consoleuser}/.zshrc
    chown ${consoleuser} /Users/${consoleuser}/.bash_profile /Users/${consoleuser}/.zshrc
    
    # clean some directory stuff for Catalina
    chown -R root:wheel /private/tmp
    chmod 777 /private/tmp
    chmod +t /private/tmp

    ############################
    ## M Lamont Add to paths.d #
    ############################
    touch /etc/paths.d/brew
    echo "${HOMEBREW_PREFIX}/bin" > /etc/paths.d/brew
fi

# Make sure everything is up to date
logme "Updating Homebrew"
su -l "$consoleuser" -c "${HOMEBREW_PREFIX}/bin/brew update" 2>&1 | tee -a ${LOG}

# set shellenv for M1 users
if [[ "$UNAME_MACHINE" == "arm64" ]]; then
    echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/${consoleuser}/.profile
fi

# logme user that all is completed
logme "Homebrew installation complete"

BREW_BIN="${BREW_PREFIX}/bin/brew"
WGET_BIN="${BREW_PREFIX}/bin/wget"

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
python main.py

deactivate

echo "===== Script finished at $(date) ====="
