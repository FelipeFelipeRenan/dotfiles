#!/bin/bash

# 1. Atualizar e instalar ferramentas base
sudo apt update && sudo apt upgrade -y
sudo apt install -y git stow curl zsh

# 2. Ler a lista de pacotes e instalar tudo
# xargs pega cada linha do arquivo e joga pro apt install
xargs -a packages.txt sudo apt install -y

# 3. Instalar Oh My Zsh (se não tiver)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 4. Instalar Fontes e Temas (Aqui você coloca os comandos wget/unzip)
# ...

# 5. Aplicar as configs com Stow
stow zsh conky rofi git

# 6. Restaurar configs do Tilix
dconf load /com/gexperts/Tilix/ < tilix/tilix.dconf

echo "Tudo pronto! Reinicie a máquina."
