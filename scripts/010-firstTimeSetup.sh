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
clone_and_update_repo "dotfiles"

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

echo
echo "########################################################################"
echo "Install brew packages"
echo "########################################################################"

cd ~/github/dotfiles-latest/brew/00-base
echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "Installing all 'base' brew packages"
brew bundle

cd ~/github/dotfiles-latest/brew/10-essentials
echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "Installing all 'essentials' brew packages"
brew bundle

cd ~/github/dotfiles-latest/brew/20-nice-to-have
echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "Installing all 'nice-to-have' brew packages"
brew bundle

cd ~/github/dotfiles-latest/brew/30-optional
echo "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "${boldGreen}Output of brew doctor command below${noColor}"
brew doctor

# Ask for confirmation to proceed
echo
read -p "Continue with installation? Type 'yes' to continue: " userInput
if [[ "$userInput" != "yes" ]]; then
  exit 1
fi

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------