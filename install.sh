#!/bin/bash

# Encerra o script se houver erro crítico
set -e

# --- 0. TRAVA DE SEGURANÇA ---
if [ "$EUID" -eq 0 ]; then
    echo "ERRO: Por favor, não rode este script como root (sudo ./install.sh)."
    echo "O makepkg e o yay bloqueiam compilações como root por segurança."
    echo "Rode apenas: ./install.sh"
    exit 1
fi

# --- 1. DEFINIÇÃO DAS DEPENDÊNCIAS ---

# Áudio (Pipewire completo + EasyEffects da sua config)
AUDIO_DEPS="pipewire pipewire-pulse wireplumber pipewire-alsa pipewire-jack easyeffects"

# Sistema de Arquivos, Montagem e Lixeira (Para o Nemo que está no seu bind Mod+E)
FS_DEPS="gvfs udisks2 nemo nemo-fileroller ffmpegthumbnailer ntfs-3g"

# Autenticação e Integração Wayland
CORE_DEPS="polkit-gnome xdg-desktop-portal-gtk xdg-desktop-portal-gnome gnome-keyring"

# Aparência e Fontes Essenciais
FONT_DEPS="ttf-jetbrains-mono-nerd noto-fonts-emoji noto-fonts-cjk ttf-liberation"

# Kit Wayland + Niri + Ferramentas do seu config.kdl
# Inclui Kitty, utilitários de print (grim, slurp, satty), lockscreen, brilho, clipboard e fallback
WAYLAND_DEPS="niri-git xorg-xwayland xwayland-satellite wl-clipboard mako kitty jq brightnessctl grim slurp satty swaylock-effects-git rofi-wayland"

# --- 2. PREPARAÇÃO DO SISTEMA ---

echo "=== Dotfiles Auto-Setup ==="
echo "Qual gerenciador de pacotes usar?"
echo "1) Pacman + Yay (Arch/EndeavourOS) - Recomendado"
echo "2) Apenas Stow (Fallback/Outra distro)"

read -r -p "Opção: " choice

if [ "$choice" == "1" ]; then
    echo ">>> Solicitando privilégios sudo para instalação base..."
    sudo -v # Pede a senha do sudo agora e mantém ativa

    echo ">>> Atualizando sistema..."
    sudo pacman -Syu --noconfirm
    
    echo ">>> Garantindo ferramentas base (Git, Stow, Base-devel)..."
    sudo pacman -S --needed --noconfirm git stow base-devel

    # Instalação do Yay (se não existir)
    if ! command -v yay &> /dev/null; then
        echo ">>> Yay não encontrado. Compilando do AUR..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd -
        rm -rf /tmp/yay
    fi

    echo ">>> Instalando dependências de sistema (Áudio, FS, Polkit, Wayland e Fontes)..."
    yay -S --needed --noconfirm $AUDIO_DEPS $FS_DEPS $CORE_DEPS $FONT_DEPS $WAYLAND_DEPS

    echo ">>> Tentando instalar Noctalia (Launcher Principal)..."
    if yay -S --needed --noconfirm noctalia-shell; then
        echo "✓ Noctalia instalado com sucesso."
    else
        echo "⚠️ Aviso: Falha ao instalar noctalia-shell. O sistema utilizará o rofi-wayland como fallback."
    fi

elif [ "$choice" == "2" ]; then
    echo ">>> Modo Fallback selecionado. Pulando instalação de dependências de sistema."
    if ! command -v stow &> /dev/null; then
        echo "ERRO: GNU Stow não está instalado. Instale-o manualmente e rode novamente."
        exit 1
    fi
else
    echo "Opção inválida."
    exit 1
fi

# --- 3. INSTALAÇÃO DE APPS E APLICAÇÃO DOS DOTFILES (STOW) ---

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DOTFILES_DIR"
FOLDERS=$(ls -d */ | cut -f1 -d'/' | grep -vE "^(\.git|scripts)$")

echo ""
echo ">>> Iniciando configuração dos pacotes e links (Stow)..."

for app in $FOLDERS; do
    echo "--- Processando: $app ---"
    
    if [ "$choice" == "1" ]; then
        if ! pacman -Qi "$app" &> /dev/null && ! yay -Qi "$app" &> /dev/null; then
            read -r -p "O pacote '$app' não parece instalado. Deseja instalar via yay? [s/n] " install_yn
            if [[ "$install_yn" =~ ^[Ss]$ ]]; then
                PKG_NAME="$app"
                case "$app" in
                    niri) PKG_NAME="niri-git" ;;
                    zen)  PKG_NAME="zen-browser-bin" ;;
                esac
                
                yay -S --needed --noconfirm "$PKG_NAME" || echo "⚠️ Aviso: Falha ao compilar/instalar $PKG_NAME. Pulando a instalação, mas mantendo o link dos dotfiles."
            fi
        else
            echo "✓ Pacote '$app' (ou similar) já detectado no sistema."
        fi
    fi

    echo "Aplicando configurações do Stow para: $app..."
    stow -D "$app" 2>/dev/null || true 
    stow -R -t "$HOME" "$app"
done

# --- 4. ATIVAÇÃO DE SERVIÇOS (SYSTEMD) ---

if [ "$choice" == "1" ]; then
    echo ""
    echo ">>> Ativando serviços do sistema..."

    systemctl --user enable --now pipewire pipewire-pulse wireplumber
    
    if pacman -Qi noctalia-shell &> /dev/null || yay -Qi noctalia-shell &> /dev/null; then
        echo "Ativando Noctalia Shell via systemd..."
        systemctl --user enable --now noctalia-shell.service 2>/dev/null || echo "Aviso: Não foi possível ativar noctalia-shell via systemd automaticamente."
    fi
fi

echo ""
echo "✅ Setup concluído! O seu ambiente Niri + Wayland está pronto. É altamente recomendado reiniciar o sistema agora."
