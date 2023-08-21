# Required packages  
apt-get update \
  && apt-get install -y apt-transport-https ca-certificates curl gnupg \
  lsb-release jq curl git gh cosign

sudo apt --fix-broken install -y


# Docker
sudo apt remove docker-desktop
rm -r $HOME/.docker/desktop
sudo rm /usr/local/bin/com.docker.cli
sudo apt purge docker-desktop
sudo apt install gnome-terminal

# Docker package repo
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


rm -rf docker-desktop-4.17.0-amd.deb
curl -LO "https://desktop.docker.com/linux/main/amd64/docker-desktop-4.17.0-amd64.deb"
sudo dpkg -i docker-desktop-4.17.0-amd64.deb
sudo apt-get clean
sudo apt-get update
sudo apt-get install ./docker-desktop-4.17.0-amd64.deb
sudo apt --fix-broken install -y


# Kubernetes
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" && \
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check && \
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl || exit 1 \
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null && \
sudo grep -qxF 'complete -o default -F __start_kubectl k' ~/.bashrc || echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc

# Knative
curl -LO "https://github.com/sigstore/cosign/releases/download/v1.6.0/cosign-linux-amd64" && \
    mv cosign-linux-amd64 /usr/local/bin/cosign && \
    chmod +x /usr/local/bin/cosign

curl -fsSLO https://github.com/knative/serving/releases/download/knative-v1.9.0/serving-core.yaml && \
    cat serving-core.yaml | grep 'gcr.io/' | awk '{print $2}' > images.txt && \
    input=images.txt && \
    while IFS= read -r image; do COSIGN_EXPERIMENTAL=1 cosign verify -o text "$image" | jq; done < "$input"

# Kind
curl -LO https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64 && \
    echo "a8c045856db33f839908b6acb90dc8ec397253ffdaef7baf058f5a542e009b9c kind-linux-amd64" | sha256sum -c && \
    chmod +x kind-linux-amd64 && \
    mv kind-linux-amd64 /usr/local/bin/kind

# Install Bazel
curl -Lo /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.10.1/bazelisk-linux-amd64
chmod +x /usr/local/bin/bazel

# Install Node and NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source ~/.bashrc

# Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update -y
sudo apt-get install -y yarn

# Install Go
sudo curl -O https://storage.googleapis.com/golang/go1.21.0.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
sudo grep -qxF 'export PATH=$PATH:/usr/local/go/bin' ~/.profile || echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
source ~/.profile


# gcloud CLI
sudo apt-get install -y apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.gpg
sudo apt-get update -y && sudo apt-get install -y google-cloud-cli


# Install Rust
yes 1 | curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustup install stable

# Install Pandoc
sudo apt install -y pandoc

# Install LaTeX
sudo apt install texlive-full -y
# sudo apt-get update && apt-get install -y --no-install-recommends \
#     texlive-latex-base \
#     texlive-latex-extra \
#     texlive-fonts-recommended \
#     texlive-fonts-extra \
#     texlive-lang-english \
#     texlive-xetex && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*


# i3
sudo apt update
sudo apt -y install i3
sudo apt --fix-broken install

# Install Tmux
sudo apt update
sudo apt install -y git automake build-essential pkg-config libevent-dev libncurses5-dev bison
git clone https://github.com/tmux/tmux.git
cd tmux
sh autogen.sh
./configure
make && sudo make install


# FUSE
apt-get update && \
    apt-get install -y fuse && \
    rm -rf /var/lib/apt/lists/*

# Nvim
sudo curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage && \
    sudo chmod u+x nvim.appimage && \
    sudo mv nvim.appimage /usr/local/bin/nvim && \
    sudo ln -s /usr/local/bin/nvim /usr/bin/nvim

sudo chmod +x /usr/local/bin/nvim

sudo apt install -y python3-pip

sudo pip3 install -y neovim

sudo apt install -y ripgrep
sudo apt-get install -y fd-find

# FZF
sudo apt install -y fzf

# xfce4-terminal
sudo apt install -y xfce4-terminal

# Gruvbox terminal theme
# for a global installation the theme files need to be put into
# /usr/share/xfce4/terminal/colorschemes

mkdir -p ~/.local/share/xfce4/terminal/colorschemes
cp ~/.dotfiles/.config/xfce4/terminal/*.theme ~/.local/share/xfce4/terminal/colorschemes/

# Compton (for terminal transaprency)
sudo apt install -y compton

# Multiple monitors
# sudo apt-get -y install xrandr

# Feh (wallpaper)
sudo apt-get -y install feh

# Fuser
sudo apt-get install -y psmisc

# Github desktop
sudo wget https://github.com/shiftkey/desktop/releases/download/release-3.1.1-linux1/GitHubDesktop-linux-3.1.1-linux1.deb
sudo dpkg -i GitHubDesktop-linux-3.1.1-linux1.deb

# Chrome
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt-get update -y
sudo apt-get install -y google-chrome-stable

# LazyGit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin


# # Nvidia drivers
sudo apt-add-repository -y contrib

sudo apt-add-repository -y non-free

sudo apt update -y

sudo apt install -y nvidia-driver

# OBS-studio
sudo apt install -y obs-studio

# Snap
sudo apt update
sudo apt install -y snapd
sudo snap install -y core

# Whatsapp
sudo snap install -y whatsapp-for-linux

# Bluetooth
sudo apt-get install -y bluez
sudo apt-get install -y blueman

# Scrot
sudo apt-get install -y scrot

# Zathura
sudo apt-get install -y zathura

# GIMP
sudo snap install -y gimp

# Kdenlive
sudo apt install -y kdenlive

# XFCE4-terminal
sudo apt install xfce4-terminal

# Stow
sudo apt install stow

# htop
sudo apt-get install -y htop
