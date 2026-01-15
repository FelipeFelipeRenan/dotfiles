#!/bin/bash

# Cores para logs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}>>> Iniciando Setup do Ambiente Cyberpunk...${NC}"

# 1. Atualizar sistema e instalar base
echo -e "${GREEN}[1/8] Atualizando repositórios e instalando base...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget unzip tar stow build-essential zsh

# 2. Ler e instalar pacotes da lista (packages.txt)
echo -e "${GREEN}[2/8] Instalando programas da lista...${NC}"
# Instala pacotes essenciais caso não estejam no txt
sudo apt install -y tilix rofi conky-all neofetch flameshot fzf bat
# Se o arquivo existir, instala o resto
if [ -f "packages.txt" ]; then
    xargs -a packages.txt sudo apt install -y
fi

# 3. Instalar Oh My Zsh (Sem interação)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN}[3/8] Instalando Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # Instalar plugin Spaceship (Opcional, se usar)
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt" --depth=1
    ln -s "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"
    # Instalar Autosuggestions e Syntax Highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# 4. Baixar Temas e Ícones (Sweet & Candy)
echo -e "${GREEN}[4/8] Baixando Temas Cyberpunk...${NC}"
mkdir -p ~/.themes ~/.icons

# Sweet Dark Theme (Clonando do repo oficial do EliverLara)
if [ ! -d "$HOME/.themes/Sweet-v40" ]; then
    git clone https://github.com/EliverLara/Sweet.git ~/.themes/Sweet-Dark
fi

# Candy Icons
if [ ! -d "$HOME/.icons/candy-icons" ]; then
    git clone https://github.com/EliverLara/candy-icons.git ~/.icons/candy-icons
fi

# 5. Instalar Fontes (JetBrains Mono Nerd Font)
echo -e "${GREEN}[5/8] Instalando Nerd Fonts...${NC}"
mkdir -p ~/.local/share/fonts
cd /tmp
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
unzip -o JetBrainsMono.zip -d ~/.local/share/fonts
rm JetBrainsMono.zip
fc-cache -fv
cd ~/dotfiles

# 6. Ferramentas Dev (Lazygit e Lazydocker)
echo -e "${GREEN}[6/8] Instalando Lazy Tools...${NC}"
# Lazydocker
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
# Lazygit (via Go se disponível, senão binário)
if command -v go &> /dev/null; then
    go install github.com/jesseduffield/lazygit@latest
else
    # Fallback para instalação manual se não tiver Go configurado ainda
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz
fi

# 7. Aplicar Configurações (Stow)
echo -e "${GREEN}[7/8] Linkando Dotfiles com Stow...${NC}"
# Remove arquivos padrões que podem conflitar
rm -rf ~/.zshrc ~/.config/conky ~/.config/rofi ~/.gitconfig
# Aplica os links
stow zsh conky rofi git

# 8. Restaurar Tilix e Gsettings
echo -e "${GREEN}[8/8] Ajustes Finais...${NC}"
if [ -f "tilix/tilix.dconf" ]; then
    dconf load /com/gexperts/Tilix/ < tilix/tilix.dconf
fi

# Tenta aplicar o tema no Cinnamon via linha de comando
gsettings set org.cinnamon.desktop.interface gtk-theme 'Sweet-Dark'
gsettings set org.cinnamon.desktop.interface icon-theme 'candy-icons'
# Nota: O tema do Desktop (Shell) às vezes precisa ser ativado manualmente no menu Temas

echo -e "${BLUE}>>> SETUP CONCLUÍDO! Reinicie a máquina para garantir tudo (especialmente o Zsh e Fontes).${NC}"
