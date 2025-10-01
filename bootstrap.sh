#!/usr/bin/env bash
# copied from https://github.com/JDevlieghere/dotfiles/blob/master/bootstrap.sh

DOTFILES=$(pwd -P)

info() {
    printf "\033[00;34m$@\033[0m\n"
}

doUpdate() {
    info "Updating"
    git pull origin master;
}

doGitConfig() {
    info "Configuring Git"

    # The .gitconfig will be overwritten; reconfigure it.
    echo "Configuring global .gitignore"
    git config --global core.excludesfile ~/.gitignore_global

    # Use Araxis Merge as diff and merge tool when available.
    if [ -d "/Applications/Araxis Merge.app/Contents/Utilities/" ]; then
        echo "Configuring Araxis Merge"
        git config --global diff.guitool araxis
        git config --global merge.guitool araxis
    fi
}

doSync() {
    info "Syncing"
    rsync --exclude ".git/" \
        --exclude ".gitignore" \
        --exclude "Preferences.sublime-settings" \
        --exclude "README.md" \
        --exclude "bootstrap.sh" \
        --exclude "installers/" \
        --exclude "os/" \
        --exclude "scripts/" \
        --exclude "tmux.terminfo" \
        --filter=':- .gitignore' \
        --filter='.exports' \
        --filter='.exports.local' \ # so variables are not overwritten if the script runs again
        -avh --no-perms . ~;

    cp -n .exports.local $HOME/.exports.local

    # Copy files that have different locations on macOS and Linux.
    if [ -d "$HOME/Library/Application Support/Code/User/" ]; then
        cp -f "$HOME/.config/Code/User/settings.json" \
            "$HOME/Library/Application Support/Code/User/settings.json"
    fi
}

doSymLink() {
    mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
    ln -sf $DOTFILES/.zshrc $HOME/.zshrc
    ln -sf $DOTFILES/.aerospace.toml $HOME/.aerospace.toml
    ln -sf $DOTFILES/.aliases $HOME/.aliases
    ln -sf $DOTFILES/.mise.toml $HOME/.mise.toml
    ln -sf $DOTFILES/.alacritty.toml $HOME/.alacritty.toml
    ln -sf $DOTFILES/.exports $HOME/.exports
}

doDirectories() {
    mkdir -p ~/.vim/undo
}

doInstall() {
    info "Installing Extras"

    # Oh-My-Zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # ZshAutoSuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    # plug.vim
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # tmux Plugin Manager
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ~/.tmux/plugins/tpm/scripts/install_plugins.sh

    # Install Neovim
    DEST="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    #Remove existing directory if it exists
    [ -d "$DEST" ] && rm -rf "$DEST"
    git clone https://github.com/paniko0/kickstart.nvim.git "$DEST"

    # Alacritty themes
    mkdir -p $HOME/.config/alacritty
    curl -LO --output-dir $HOME/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-macchiato.toml

    # Install programming languages
    mise install
}

doFonts() {
    info "Installing Fonts"

    if [ "$(uname)" == "Darwin" ]; then
        fonts=~/Library/Fonts
    elif [ "$(uname)" == "Linux" ]; then
        fonts=~/.fonts
        mkdir -p "$fonts"
    fi

    $DOTFILES/fonts/firacode.sh
    find "$DOTFILES/fonts/" -name "*.[o,t]tf" -type f | while read -r file
    do
        # Check if the file does not exist at the destination
        if [ ! -f "$fonts/$(basename "$file")" ]; then
            cp -v "$file" "$fonts"
        fi
    done
}

doConfig() {
    info "Configuring"

    if [ "$(uname)" == "Darwin" ]; then
        echo "Configuring macOS"
        ./os/macos.sh
    elif [ "$(uname)" == "Linux" ]; then
        echo "Configuring Linux"
        ./os/linux.sh
    fi
}

doBrew() {
    if ! command -v brew &> /dev/null
    then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    brew tap Homebrew/bundle
    brew bundle --file=Brewfile
}

doThemes() {
  info "ZSH - copying modified af-magic"

  cp $DOTFILES/themes/af-magic.zsh-theme $HOME/.oh-my-zsh/custom/themes/af-magic.zsh-theme
}

doAll() {
    doUpdate
    doBrew
    doSync
    doThemes
    doGitConfig
    doDirectories
    doSymLink
    doInstall
    doFonts
    doConfig
}

doHelp() {
    echo "Usage: $(basename "$0") [options]" >&2
    echo
    echo "   -s, --sync             Synchronizes dotfiles to home directory"
    echo "   -t, --themes           Synchronizes themes"
    echo "   -l, --link             Create symbolic links"
    echo "   -i, --install          Install (extra) software"
    echo "   -f, --fonts            Copies font files"
    echo "   -c, --config           Configures your system"
    echo "   -a, --all              Does all of the above"
    echo
    exit 1
}

if [ $# -eq 0 ]; then
    doAll
else
    for i in "$@"
    do
        case $i in
            -s|--sync)
                doSync
                doGitConfig
                doDirectories
                shift
                ;;
            -t|--themes)
                doThemes
                shift
                ;;
            -l|--link)
                doSymLink
                shift
                ;;
            -i|--install)
                doInstall
                doBrew
                shift
                ;;
            -f|--fonts)
                doFonts
                shift
                ;;
            -c|--config)
                doConfig
                shift
                ;;
            -a|--all)
                doAll
                shift
                ;;
            *)
                doHelp
                shift
                ;;
        esac
    done
fi
