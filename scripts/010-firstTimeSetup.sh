###############################################################################
# Colors definition
###############################################################################
boldGreen="\033[1;32m"
boldYellow="\033[1;33m"
boldRed="\033[1;31m"
boldPurple="\033[1;35m"
boldBlue="\033[1;34m"
noColor="\033[0m"

###############################################################################
# Script details
###############################################################################

# This Script also provides access to my github repository, at some point
# you'll be asked to paste the github ssh key.

###############################################################################
# Variables section
###############################################################################

# User and email that will be used in github for commits
GIT_USERNAME="marcbernardoni"
EMAIL_FILE="$HOME/.git_user_email"

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

clear

# Check if an email is already stored
echo
if [[ -f "$EMAIL_FILE" ]]; then
  stored_email=$(cat "$EMAIL_FILE")
  read -p "Do you want to use '${stored_email}' as Git email? Enter 'yes' to use it, or 'no' to enter a new one: " use_stored
else
  use_stored="no"
fi

if [[ "$use_stored" == "yes" ]]; then
  GIT_USEREMAIL="$stored_email"
else
  while true; do
    echo
    echo "Enter your Git email: "
    # stty -echo
    read GIT_USEREMAIL
    # stty echo
    echo
    echo "Re-enter your Git email for confirmation: "
    # stty -echo
    read GIT_USEREMAIL_CONFIRM
    # stty echo
    echo
    if [[ "$GIT_USEREMAIL" == "$GIT_USEREMAIL_CONFIRM" ]]; then
      echo "Emails match."
      break
    else
      echo "${boldRed}Emails do not match. Please try again.${noColor}"
    fi
  done
  # Save the new email for future use
  echo "$GIT_USEREMAIL" >"$EMAIL_FILE"
fi

echo
echo "###############################################################################"
echo "Installing xcode" 
echo "###############################################################################"

if ! xcode-select -p &>/dev/null; then
  # In the brew documentation (https:docs.brex.sh/Installation)
  # you can see the macOS Requirements

  echo
  echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
  echo "Installing xcode-select, this will take so;e time, please wait"
  echo "${boldYellow}A popup will show up, make sure you accept it${noColor}"
  xcode-select --install

  # Wait for xcode-select to be installed
  echo
  echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
  echo "Waiting for xcode-select installation to complete..."
  while ! xcode-select -p &>/dev/null; do
    sleep 20
  done
  echo
  echo "${boldGreen}xcode-select Installed! Proceeding with Homebrew installation.${noColor}"
else
  echo
  echo "${boldGreen}xcode-select is already installed! Proceeding with Homebrew installation.${noColor}"
fi

# Source this in case brew was installed but script needs to re-run
if [ -f ~/.zprofile ]; then
  source ~/.zprofile
fi

echo
echo "########################################################################"
echo "Installing homebrew"
echo "########################################################################"

if ! xcode-select -p &>/dev/null; then
  # In the [brew documentation](https://docs.brew.sh/Installation)
  # you can see the macOS Requirements
  echo
  echo -e "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
  echo "Installing xcode-select, this will take some time, please wait"
  echo -e "${boldYellow}A popup will show up, make sure you accept it${noColor}"
  xcode-select --install

  # Wait for xcode-select to be installed
  echo
  echo -e "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
  echo "Waiting for xcode-select installation to complete..."
  while ! xcode-select -p &>/dev/null; do
    sleep 20
  done
  echo
  echo "${boldGreen}xcode-select Installed! Proceeding with Homebrew installation.${noColor}"
else
  echo
  echo "${boldGreen}xcode-select is already installed! Proceeding with Homebrew installation.${noColor}"
fi

# Source this in case brew was installed but script needs to re-run
if [ -f ~/.zprofile ]; then
  source ~/.zprofile
fi

# Then go to the main page `https://brew.sh` to find the installation command
if ! command -v brew &>/dev/null; then
  echo
  echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
  echo "Installing brew"
  echo "Enter your password below (if required)"
  
  # Only install brew if not installed yet
  echo
  echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
  # Install Homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo
  echo "${boldGreen}Homebrew installed successfully.${noColor}"
else
  echo
  echo "${boldGreen}Homebrew is already installed.${noColor}"
fi

# After brew is installed, notice that you need to configure your shell for
# homebrew, you can see this in your terminal output in the **Next steps** section
echo
echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "Modifying .zprofile file"
CHECK_LINE='eval "$(/opt/homebrew/bin/brew shellenv)"'

# File to be checked and modified
FILE="$HOME/.zprofile"

# Check if the specific line exists in the file
if grep -Fq "$CHECK_LINE" "$FILE"; then
  echo "Content already exists in $FILE"
else
  # Append the content if it does not exist
  echo '\n# Configure shell for brew\n'"$CHECK_LINE" >>"$FILE"
  echo "Content added to $FILE"
fi

# After adding it to the .zprofile file, make sure to run the command
source $FILE

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

echo
echo "########################################################################"
echo "Installing git"
echo "########################################################################"

echo
echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
brew install git

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

echo
echo "########################################################################"
echo "Configure git access to my private repos"
echo "########################################################################"

echo
# Define the SSH config file path
SSH_CONFIG_FILE="$HOME/.ssh/config"
GITHUB_SSH_KEY_FILE="$HOME/.ssh/key-github-pers"
GITHUB_SSH_KEY_NAME=$(basename "$GITHUB_SSH_KEY_FILE")
PERS_SSH_KEY_FILE="$HOME/.ssh/keykrishna"
PERS_SSH_KEY_NAME=$(basename "$PERS_SSH_KEY_FILE")

# Check if the .ssh directory exists, if not create it
if [ ! -d "$HOME/.ssh" ]; then
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
fi

# Check if the github SSH key file exists, if not, create it
if [ ! -f "$GITHUB_SSH_KEY_FILE" ]; then
  echo "# Paste your '$GITHUB_SSH_KEY_NAME' PRIVATE key below and save" >"$GITHUB_SSH_KEY_FILE"
  echo "# Also, delete these 3 comments on the top or the key will be invalid" >>"$GITHUB_SSH_KEY_FILE"
  echo "# Once done modifying this file, save with :wq" >>"$GITHUB_SSH_KEY_FILE"
  vim "$GITHUB_SSH_KEY_FILE"
  chmod 600 "$GITHUB_SSH_KEY_FILE"
fi

# Create the SSH config with a heredoc
cat >"$SSH_CONFIG_FILE" <<SSHCONFIG
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/key-github-pers
SSHCONFIG

echo
echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "${boldGreen}The SSH config has been created:${noColor}"
cat "$SSH_CONFIG_FILE"
echo

# Set the correct permissions for the config file
chmod 600 "$SSH_CONFIG_FILE"

echo
echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "Configuring git user.name to $GIT_USERNAME and user.email to $GIT_USEREMAIL"
git config --global user.name "$GIT_USERNAME"
git config --global user.email $GIT_USEREMAIL

echo
echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "Git access configured, will clone dotfiles repo below to make sure it works"

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

mkdir -p ~/github

# Function to clone or update repositories
clone_and_update_repo() {
  local repo_name=$1
  local git_repo="git@github.com:marcbernardoni/$repo_name.git"
  local repo_path="$HOME/github/$repo_name"

  echo
  echo "########################################################################"
  echo "Configuring '$repo_name' repo"
  echo "########################################################################"

  # Check if the directory exists
  if [ -d "$repo_path" ]; then
    # Check if directory is empty or contains only .obsidian.vimrc
    if [ "$(ls -A "$repo_path")" ] && [ ! "$(ls -A "$repo_path" | grep -v '.obsidian.vimrc')" ]; then
      # Directory exists but is effectively empty, remove it and then clone the repository
      echo
      echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
      echo "Repository directory exists but is effectively empty. Removing and cloning '$repo_name'..."
      rm -rf "$repo_path"
      git clone "$git_repo" "$repo_path" >/dev/null 2>&1
    elif [ "$(ls -A "$repo_path")" ]; then
      # Directory exists and is not empty, so pull to update the repository
      echo
      echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
      echo "Repository '$repo_name' already exists. Pulling latest changes..."
      cd "$repo_path" && git pull
    fi
  else
    # Directory does not exist or is empty without the .obsidian.vimrc file, so clone the repository
    echo
    echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
    echo "Cloning repository '$repo_name'..."
    git clone "$git_repo" "$repo_path" >/dev/null 2>&1
  fi

  # Verify if the repo was cloned successfully
  if [ ! -d "$repo_path" ]; then
    echo
    echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
    echo "${boldRed}Warning: Failed to clone the '$repo_name' repo. Check this manually.${noColor}"
    exit 1
  fi

  echo
  echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
  echo "Successfully configured the '$repo_name' repo."
}

# Clone and update multiple repositories
clone_and_update_repo "dotfiles-latest"

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

echo
echo "########################################################################"
echo "Install brew packages"
echo "########################################################################"

cd ~/github/dotfiles-latest/brew/00-base
echo
echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "Installing all 'base' brew packages"
brew bundle || true

cd ~/github/dotfiles-latest/brew/10-essential
echo
echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "Installing all 'essentials' brew packages"
brew bundle || true

cd ~/github/dotfiles-latest/brew/20-nice-to-have
echo
echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "Installing all 'nice-to-have' brew packages"
brew bundle || true

echo
echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "${boldGreen}Output of brew doctor command below${noColor}"
brew doctor || true

# Ask for confirmation to proceed
echo
read -p "Continue with installation? Type 'yes' to continue: " userInput
if [[ "$userInput" != "yes" ]]; then
  exit 1
fi

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

echo
echo "########################################################################"
echo "Configure neovim"
echo "########################################################################"

# -- TODO --

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

echo
echo "########################################################################"
echo "Configure tmux"
echo "########################################################################"

# -- TODO --

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

echo
echo "########################################################################"
echo "Source ~/.zshrc file"
echo "########################################################################"

echo
echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "This section will:"
echo "- Fix all the brew caveats"
echo "- Create all the symlinks that point to my dotfiles"

# -- TODO --

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

echo
echo "########################################################################"
echo "Setting access to my ssh config"
echo "########################################################################"

# -- TODO --

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

echo
echo "########################################################################"
echo "Config macos system settings"
echo "########################################################################"

# Configure apps that start after booting up (login items)
# https://apple.stackexchange.com/questions/310495/can-login-items-be-added-via-the-command-line-in-high-sierra
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/kitty.app", hidden:false}'
# osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Ghostty.app", hidden:false}'

# MacOS stores the current session info in a file while your logged on and
# stores info on what Apps are currently open, window size and position.
# By disabling system access to this file we can permanently stop MacOS from
# re-opening apps after rebooting
# https://www.tonymacx86.com/threads/guide-permanently-disable-macos-from-re-opening-apps-on-restart-boot.296200/
#
# flag the file as owned by root (otherwise MacOS will replace it)
sudo chown root ~/Library/Preferences/ByHost/com.apple.loginwindow.*
# remove all permissions (so that it can not be read or written to)
sudo chmod 000 ~/Library/Preferences/ByHost/com.apple.loginwindow.*
#
# If you need to re-enable the feature you can simply delete the existing file
# sudo rm -f ~/Library/Preferences/ByHost/com.apple.loginwindow.*


# https://macos-defaults.com
#
# HACK: How to view stuff that changes after you change them manually in system
# settings
# Before making the change
# defaults read > ~/macos-before-change.txt
# Then go and make the change in system settings
# defaults read > ~/macos-after-change.txt
# diff ~/macos-before-change.txt ~/macos-after-change.txt
# NOTE: There are some settings, like the trackpad ones that only work on the
# laptop with a trackpad

# Move a window by clicking on any part of it when pressing cmd+ctrl
# To disable:
# defaults delete -g NSWindowShouldDragOnGesture
defaults write -g NSWindowShouldDragOnGesture -bool true

# Set 'Prefer tabs when opening documents' to 'Always'
# To get CURRENT VALUE
# defaults read -g AppleWindowTabbingMode
defaults write -g AppleWindowTabbingMode -string "always"

# Through GUI KeyRepeat rate min is 2 (30 ms)
# Through GUI InitialKeyRepeat rate min is 15 (225 ms)
# To see what the CURRENT VALUE for each the **Key repeat rate** and the **Delay until repeat** are
# defaults read -g KeyRepeat
# defaults read -g InitialKeyRepeat
defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 50

# Set mouse to secondary click on the right side
# It doesn't work, so trying to set it to OneTwoButton first to see if it works
# To get CURRENT VALUE
# defaults read com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode -string "TwoButton"

# Dragging with three finger drag on trackpad
# READ current value
# defaults read com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag"
defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool "true"

# Mouse cursor speed
# Max value via system settings is 3, but notice I set it to 4 via the command
# To get CURRENT VALUE
# defaults read NSGlobalDomain com.apple.mouse.scaling
defaults write NSGlobalDomain com.apple.mouse.scaling -float "4"

# Enable Reduce Motion
# To get CURRENT VALUE
# defaults read com.apple.universalaccess reduceMotion
# "Settings - accessibility - display"
defaults write com.apple.universalaccess reduceMotion -bool true
defaults write com.apple.Accessibility ReduceMotionEnabled -bool true

# Enable reduce Transparency so it doesnt look brown instead of dark gray
# To get CURRENT VALUE
# defaults read com.apple.universalaccess reduceTransparency
defaults write com.apple.universalaccess reduceTransparency -bool true

defaults write com.apple.Accessibility DifferentiateWithoutColor -bool true

############################################

# Set menu bar clock to analog style (default is digital)
# To get CURRENT VALUE
# defaults read com.apple.menuextra.clock IsAnalog
defaults write com.apple.menuextra.clock IsAnalog -bool true

# Automatically hide the dock
defaults write com.apple.dock autohide -bool true

# How fast the dock shows when you hover over it
# If you want it to show **instantly**, set it to 0
# To set it to show at 0.7 seconds, set it to 0.7
# To reset back to default:
# defaults delete com.apple.dock "autohide-delay" && killall Dock
# To see what the CURRENT VALUE is
# defaults read com.apple.dock autohide-delay
defaults write com.apple.Dock autohide-delay -float "0.7"

# Automatically hide and show the menu bar
# To get CURRENT VALUE
# defaults read NSGlobalDomain _HIHideMenuBar
# To hide the menu bar
defaults write NSGlobalDomain _HIHideMenuBar -bool true
# To show the menu bar
# defaults write NSGlobalDomain _HIHideMenuBar -bool false

# Disable Automatically Rearrange Spaces Based on Most Recent Use
# To get CURRENT VALUE
# defaults read com.apple.dock mru-spaces
defaults write com.apple.dock mru-spaces -bool false

# Disable Show Recent Applications in Dock
# To get CURRENT VALUE
# defaults read com.apple.dock show-recents
defaults write com.apple.dock show-recents -bool false

# Set the icon size of Dock items in pixels
# defaults read com.apple.dock "tilesize"
defaults write com.apple.dock "tilesize" -int "36"

# Trackpad cursor speed
# Max value via system settings is 3, but notice I set it to 4 via the command
# To get CURRENT VALUE
# defaults read NSGlobalDomain com.apple.trackpad.scaling
defaults write NSGlobalDomain com.apple.trackpad.scaling -float "4"

# Set hot corners
# Bottom-left corner: Notification center with modifier 1048576
# defaults read com.apple.dock wvous-bl-corner
# defaults read com.apple.dock wvous-bl-modifier
defaults write com.apple.dock wvous-bl-corner -int 11
defaults write com.apple.dock wvous-bl-modifier -int 1048576

# Top-left corner: Mission Control with modifier 1048576
# defaults read com.apple.dock wvous-tl-corner
# defaults read com.apple.dock wvous-tl-modifier
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 1048576

# Top-right corner: Notification center with modifier 1048576
# defaults read com.apple.dock wvous-tr-corner
# defaults read com.apple.dock wvous-tr-modifier
defaults write com.apple.dock wvous-tr-corner -int 12
defaults write com.apple.dock wvous-tr-modifier -int 1048576

# Bottom-right corner: Quick Note with modifier 1048576
# defaults read com.apple.dock wvous-br-corner
# defaults read com.apple.dock wvous-br-modifier
defaults write com.apple.dock wvous-br-corner -int 14
defaults write com.apple.dock wvous-br-modifier -int 1048576

# Restart the Dock to apply changes
# If you have 'System Settings' open and don't see the changes, close
# 'System Settings' and open it again
killall Dock

############################################

# Safari show full URL
# defaults read com.apple.Safari "ShowFullURLInSmartSearchField"
defaults write com.apple.Safari "ShowFullURLInSmartSearchField" -bool "true"

killall Safari

############################################

# Keep folders on top
# defaults read com.apple.finder "_FXSortFoldersFirst"
defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"

# Set the default view style for folders without custom setting
# Icon (icnv), list (Nlsv), column (clmv), gallery (glyv)
# defaults read com.apple.finder "FXPreferredViewStyle"
defaults write com.apple.finder "FXPreferredViewStyle" -string "clmv"

# defaults read com.apple.finder "_FXSortFoldersFirstOnDesktop"
defaults write com.apple.finder "_FXSortFoldersFirstOnDesktop" -bool "true"

# Show path bar
# defaults read com.apple.finder "ShowPathbar"
defaults write com.apple.finder "ShowPathbar" -bool "true"

# Disable UI sound effects
# To get CURRENT VALUE
# defaults read -g com.apple.sound.uiaudio.enabled
defaults write -g com.apple.sound.uiaudio.enabled -int 0

# Disable the startup chime
# To get CURRENT VALUE
# nvram -p | grep StartupMute
sudo nvram StartupMute=%01

killall Finder

echo
echo -e "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo -e "${boldYellow}Some changes, like 'KeyRepeat' require a reboot${noColor}"
