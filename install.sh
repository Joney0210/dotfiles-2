#!/bin/bash

##安裝HomeBrew，如果已安裝則跳過。
install_brew() {
    if ! command -v "brew" &> /dev/null; then
        printf "Homebrew not found, installing."
        # install homebrew
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        # change owner 不知道為什麼
        sudo chown -R $(whoami) /usr/local/Cellar
        sudo chown -R $(whoami) /usr/local/Homebrew
    fi

    printf "Installing homebrew packages..."
    brew bundle
    sudo gem install colorls
}

create_dirs() {
    declare -a dirs=(
        "$HOME/Downloads/torrents"
        "$HOME/Desktop/screenshots"
        "$HOME/dev"
        "$HOME/dev/work"
    )

    for i in "${dirs[@]}"; do
        mkdir "$i"
    done
}

##安裝Xcodee Command linee tools
build_xcode() {
    if ! xcode-select --print-path &> /dev/null; then
        xcode-select --install &> /dev/null

        until xcode-select --print-path &> /dev/null; do
            sleep 5
        done

        sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer

        sudo xcodebuild -license
    fi
}

main() {
    ##建立需使用之目錄
    printf "🗄  Creating directories\n"
    create_dirs

    ##安裝Xcode Command Line Tools
    printf "🛠  Installing Xcode Command Line Tools\n"
    build_xcode

    ##安裝Homebrew 軟件
    printf "🍺  Installing Homebrew packages\n"
    install_brew

    ##調整 Macos 系統設定
    printf "💻  Set macOS preferences\n"
    ./macos/.macos 

    printf "🐍  Set Python to 3.7\n"
    # setup pyenv / global python to 3.7.x
    pyenv install 3.7.4 >/dev/null
    pyenv global 3.7.4 >/dev/null
    # dont set conda clutter in zshrc
    conda config --set auto_activate_base false

    printf "🌈  Installing colorls\n"
    sudo gem install colorls >/dev/null

    printf "👽  Installing vim-plug\n"
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    printf "🐗  Stow dotfiles\n"
    stow alacritty colorls fzf git nvim skhd starship tmux vim yabai z zsh

    printf "✨  Done!\n"
}

main
