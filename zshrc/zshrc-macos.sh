# Filename: ~/github/dotfiles-latest/zshrc/zshrc-macos.sh

install_xterm_kitty_terminfo() {
  # Attempt to get terminfo for xterm-kitty
  if ! infocmp xterm-kitty &>/dev/null; then
    echo "xterm-kitty terminfo not found. Installing..."
    # Create a temp file
    tempfile=$(mktemp)
    # Download the kitty.terminfo file
    # https://github.com/kovidgoyal/kitty/blob/master/terminfo/kitty.terminfo
    if curl -o "$tempfile" https://raw.githubusercontent.com/kovidgoyal/kitty/master/terminfo/kitty.terminfo; then
      echo "Downloaded kitty.terminfo successfully."
      # Compile and install the terminfo entry for my current user
      if tic -x -o ~/.terminfo "$tempfile"; then
        echo "xterm-kitty terminfo installed successfully."
      else
        echo "Failed to compile and install xterm-kitty terminfo."
      fi
    else
      echo "Failed to download kitty.terminfo."
    fi
    # Remove the temporary file
    rm "$tempfile"
  fi
}
install_xterm_kitty_terminfo

#############################################################################
#                       Command line tools
#############################################################################

# Tool that I use the most and the #1 in my heart is tmux

# Initialize fzf if installed
# https://github.com/junegunn/fzf
# The following are custom fzf menus I configured
# hyper+e+n tmux-sshonizer-agen
# hyper+t+n prime's tmux-sessionizer
# hyper+c+n colorscheme selector
#
# Useful commands
# ctrl+r - command history
# ctrl+t - search for files
# ssh ::<tab><name> - shows you list of hosts in case don't remember exact name
# kill -9 ::<tab><name> - find and kill a process
# telnet ::<TAB>
#
if [ -f ~/.fzf.zsh ]; then

  # After installing fzf with brew, you have to run the install script
  # echo -e "y\ny\nn" | /opt/homebrew/opt/fzf/install

  source ~/.fzf.zsh

  # Preview file content using bat
  export FZF_CTRL_T_OPTS="
    --preview 'bat -n --color=always {}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"

  # Use :: as the trigger sequence instead of the default **
  export FZF_COMPLETION_TRIGGER='::'

  # Eldritch Colorscheme / theme
  # https://github.com/eldritch-theme/fzf
  export FZF_DEFAULT_OPTS='--color=fg:#ebfafa,bg:#09090d,hl:#37f499 --color=fg+:#ebfafa,bg+:#0D1116,hl+:#37f499 --color=info:#04d1f9,prompt:#04d1f9,pointer:#7081d0 --color=marker:#7081d0,spinner:#f7c67f,header:#323449'
fi

# # Starship
# # Not sure if counts a CLI tool, because it only makes my prompt more useful
# # https://starship.rs/config/#prompt
# # I was getting this error
# # starship_zle-keymap-select-wrapped:1: maximum nested function level reached; increase FUNCNEST?
# # Check that the function `starship_zle-keymap-select()` is defined
# # https://github.com/starship/starship/issues/3418
if command -v starship &>/dev/null; then
  type starship_zle-keymap-select >/dev/null ||
    {
      export STARSHIP_CONFIG=$HOME/github/dotfiles-latest/starship-config/active-config.toml
      eval "$(starship init zsh)" >/dev/null 2>&1
    }
fi

# eza
# ls replacement
# exa is unmaintained, so now using eza
# https://github.com/ogham/exa
# https://github.com/eza-community/eza
# uses colours to distinguish file types and metadata. It knows about
# symlinks, extended attributes, and Git.
if command -v eza &>/dev/null; then
  alias ls='eza'
  alias ll='eza -lhg'
  alias lla='eza -alhg'
  alias tree='eza --tree'
fi

# Bat -> Cat with wings
# https://github.com/sharkdp/bat
# Supports syntax highlighting for a large number of programming and markup languages
if command -v bat &>/dev/null; then
  # --style=plain - removes line numbers and git modifications
  # --paging=never - doesnt pipe it through less
  alias cat='bat --paging=never --style=plain'
  alias catt='bat'
  # alias cata='bat --show-all --paging=never'
  alias cata='bat --show-all --paging=never --style=plain'
fi

# Zsh Vi Mode
# vi(vim) mode plugin for ZSH
# https://github.com/jeffreytse/zsh-vi-mode
# Insert mode to type and edit text
# Normal mode to use vim commands
# test {really} long (command) using a { lot } of symbols {page} and {abc} and other ones [find] () "test page" {'command 2'}
if [ -f "$(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]; then
  source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
  # Following 4 lines modify the escape key to `kj`
  ZVM_VI_ESCAPE_BINDKEY=kj
  ZVM_VI_INSERT_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
  ZVM_VI_VISUAL_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
  ZVM_VI_OPPEND_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY

  # Function to switch to the left tmux pane and maximize it
  function tmux_left_pane() {
    # This defines if the tmux pane created by neovim is on the right or
    # bottom, make sure you also configure the neovi keymap to match
    export TMUX_PANE_DIRECTION="right"
    if [[ $TMUX_PANE_DIRECTION == "right" ]]; then
      tmux select-pane -L # Move to the left (opposite of right)
    elif [[ $TMUX_PANE_DIRECTION == "bottom" ]]; then
      tmux select-pane -U # Move to the top (opposite of bottom)
    fi
    tmux resize-pane -Z
    # zle reset-prompt # Refresh the prompt after switching panes
  }

  # Register the function as a ZLE widget
  # zle -N tmux_left_pane
  zvm_define_widget tmux_left_pane

  function zvm_after_lazy_keybindings() {
    # Remap to go to the beginning of the line
    zvm_bindkey vicmd 'gh' beginning-of-line
    # Remap to go to the end of the line
    zvm_bindkey vicmd 'gl' end-of-line
    # Moves me to my left pane in tmux and maximizes it
    # Bind Alt-t to the tmux_left_pane function in normal and insert mode
    # To know that alt-t is ^[t I used `/bin/cat -v` and then pressed alt-t
    zvm_bindkey vicmd '^[t' tmux_left_pane
    zvm_bindkey viins '^[t' tmux_left_pane
    # I used ',' to switch to left pane and maximize it  before switching to alt-t
    # zvm_bindkey vicmd ',' tmux_left_pane
    # Move to the left tmux pane with escape on normal and insert mode
    # zvm_bindkey vicmd '^[' tmux_left_pane
    # zvm_bindkey viins '^[' tmux_left_pane
  }

  # zvm_bindkey vicmd '\e' tmux_left_pane

  # Disable the cursor style feature
  # I my cursor above in the cursor section
  # https://github.com/jeffreytse/zsh-vi-mode?tab=readme-ov-file#custom-cursor-style
  #
  # NOTE: My cursor was not blinking when using wezterm with the "wezterm"
  # terminfo, setting it to a blinking cursor below fixed that
  # I also set my term to "xterm-kitty" for this to work
  #
  # This also specifies the blinking cursor
  # ZVM_CURSOR_STYLE_ENABLED=false
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE

  # Source .fzf.zsh so that the ctrl+r bindkey is given back fzf
  zvm_after_init_commands+=('[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh')
fi

# https://github.com/zsh-users/zsh-autosuggestions
# Right arrow to accept suggestion
if [ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Changed from z.lua to zoxide, as it's more maintaned
# smarter cd command, it remembers which directories you use most
# frequently, so you can "jump" to them in just a few keystrokes.
# https://github.com/ajeetdsouza/zoxide
# https://github.com/skywind3000/z.lua
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"

  alias cd='z'
  # Alias below is same as 'cd -', takes to the previous directory
  alias cdd='z -'

  #Since I migrated from z.lua, I can import my data
  # zoxide import --from=z "$HOME/.zlua" --merge

  # Useful commands
  # z foo<SPACE><TAB>  # show interactive completions
fi

#############################################################################