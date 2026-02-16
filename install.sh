
#!/bin/bash

# Encerra o script se houver erro
set -e

# --- 1. DEFINIÇÃO DAS DEPENDÊNCIAS DE "SOFRIMENTO" (PLUMBING) ---
# [cite_start]Baseado na sua lista de pacotes instalados [cite: 1, 2, 3, 4]

# Áudio (Pipewire completo)
AUDIO_DEPS="pipewire pipewire-pulse wireplumber pipewire-alsa pipewire-jack"

# Sistema de Arquivos, Montagem e Lixeira (Para o Nemo funcionar 100%)
FS_DEPS="gvfs udisks2 nemo nemo-fileroller ffmpegthumbnailer ntfs-3g"

# Autenticação e Integração Wayland (Para pedir senha root e compartilhar tela)
# Você usa polkit-kde-agent e xdg-desktop-portal-gtk/gnome
CORE_DEPS="polkit-kde-agent xdg-desktop-portal-gtk xdg-desktop-portal-gnome gnome-keyring"

# Aparência e Fontes Essenciais
FONT_DEPS="ttf-jetbrains-mono-nerd noto-fonts-emoji noto-fonts-cjk ttf-liberation"

# --- 2. PREPARAÇÃO DO SISTEMA ---

echo "=== Dotfiles Auto-Setup ==="
echo "Qual gerenciador de pacotes usar?"
echo "1) Pacman + Yay (Arch/EndeavourOS) - Recomendado"
echo "2) Apenas Stow (Fallback/Outra distro)"

read -r -p "Opção: " choice

if [ "$choice" == "1" ]; then
    echo ">>> Atualizando sistema..."
    sudo pacman -Syu --noconfirm
    
    echo ">>> Garantindo ferramentas base (Git, Stow, Base-devel)..."
    sudo pacman -S --needed --noconfirm git stow base-devel

    # Instalação do Yay (se não existir)
    if ! command -v yay &> /dev/null; then
        echo ">>> Yay não encontrado. Instalando..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd -
        rm -rf /tmp/yay
    fi

    echo ">>> Instalando dependências de sistema (Áudio, FS, Polkit)..."
    yay -S --needed --noconfirm $AUDIO_DEPS $FS_DEPS $CORE_DEPS $FONT_DEPS

elif [ "$choice" == "2" ]; then
    echo ">>> Modo Fallback selecionado. Pulando instalação de dependências de sistema."
    # Verifica se stow está instalado
    if ! command -v stow &> /dev/null; then
        echo "ERRO: GNU Stow não está instalado. Instale-o manualmente e rode novamente."
        exit 1
    fi
else
    echo "Opção inválida."
    exit 1
fi

# --- 3. INSTALAÇÃO DE APPS E APLICAÇÃO DOS DOTFILES (STOW) ---

# Pega a lista de pastas dentro de ~/dotfiles (ignorando .git e scripts)
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DOTFILES_DIR"
FOLDERS=$(ls -d */ | cut -f1 -d'/' | grep -vE "^(\.git|scripts)$")

echo ""
echo ">>> Iniciando configuração dos pacotes..."

for app in $FOLDERS; do
    echo "--- Processando: $app ---"
    
    # Lógica Automática: Tenta instalar o pacote com o mesmo nome da pasta
    if [ "$choice" == "1" ]; then
        if ! pacman -Qi "$app" &> /dev/null && ! yay -Qi "$app" &> /dev/null; then
            read -r -p "O pacote '$app' não parece instalado. Deseja instalar via yay? [s/n] " install_yn
            if [[ "$install_yn" =~ ^[Ss]$ ]]; then
                # Tratamento especial para nomes diferentes (Ex: pasta 'niri' -> pacote 'niri-git')
                PKG_NAME="$app"
                case "$app" in
                    niri) PKG_NAME="niri-git" ;;  # [cite_start]Você usa a versão git [cite: 3]
                    zen)  PKG_NAME="zen-browser-bin" ;; # [cite_start]Você usa o bin do AUR [cite: 4]
                    # Adicione outras exceções aqui se criar pastas com nomes diferentes dos pacotes
                esac
                
                yay -S --needed --noconfirm "$PKG_NAME"
            fi
        else
            echo "✓ Pacote '$app' (ou similar) já detectado."
        fi
    fi

    # Aplicação do Stow
    echo "Aplicando configurações (stow)..."
    # -D = Delete (remove links antigos para evitar conflito), -R = Restow (refaz links)
    stow -D "$app" 2>/dev/null || true 
    stow -R -t "$HOME" "$app"
done

# --- 4. ATIVAÇÃO DE SERVIÇOS (SYSTEMD) ---

if [ "$choice" == "1" ]; then
    echo ""
    echo ">>> Ativando serviços do sistema..."

    # Áudio
    systemctl --user enable --now pipewire pipewire-pulse wireplumber
    
    # Serviços Específicos do Usuário (Noctalia, etc)
    # Verificando se o noctalia está instalado antes de tentar ativar
    if pacman -Qi noctalia-shell &> /dev/null || yay -Qi noctalia-shell &> /dev/null; then
        echo "Ativando Noctalia Shell..."
        # Nota: O nome do serviço pode variar. Geralmente é app.service.
        # Ajuste abaixo se o nome do serviço for diferente de 'noctalia-shell'
        systemctl --user enable --now noctalia-shell.service 2>/dev/null || echo "Aviso: Não foi possível ativar noctalia-shell via systemd automaticamente. Verifique o nome do serviço."
    fi

    # Exemplo: Ativar Syncthing ou MPD se tiver no futuro
    # systemctl --user enable --now syncthing
fi

echo ""
echo "✅ Instalação concluída! Recomendado reiniciar o sistema."
