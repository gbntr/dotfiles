# Caminhos do sistema e ferramentas locais
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.juliaup/bin:$HOME/.spicetify:$PATH"

# Oh My Zsh e tema
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="superjarin"

plugins=(
    git
    archlinux
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Configuração de histórico
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Atalhos básicos e editor
alias hx="/usr/bin/helix"
alias shx="sudo -E helix"

# Substituindo ls pelo lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# Scripts pessoais
alias fixpad='echo "Reiniciando touchpad Dell I2C..." && sudo modprobe -r i2c_hid_acpi && sleep 1 && sudo modprobe i2c_hid_acpi && echo "Touchpad reiniciado!"'
alias dotsync='cd ~/dotfiles && git add . && git commit -m "Sync: $(date +%Y-%m-%d\ %H:%M)" && git push'
alias wifi='nm-connection-editor && disown'
alias sdn='shutdown now'
alias felipe='echo hmmmmm, esse libera o butico'
alias upkey='sudo pacman -Sy archlinux-keyring cachyos-keyring'
# Alias para troca rápida de Timezone
alias tzbr="sudo timedatectl set-timezone America/Sao_Paulo && echo 'Timezone: Brasil (SP)'"
alias tzus="sudo timedatectl set-timezone America/New_York && echo 'Timezone: US (Eastern/Washington)'"
alias tzchi="sudo timedatectl set-timezone America/Chicago && echo 'Timezone: US (Central/Chicago)'"
alias jose='echo "o tal do mc lobisomen"'
# Rice (Desativados)
#pokemon-colorscripts --no-title -s -r
#pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -
#fastfetch -c $HOME/.config/fastfetch/config.jsonc
#neofetch

# Inicialização de ferramentas (Devem ficar no final)
source <(fzf --zsh)
eval "$(zoxide init zsh)"

# Configuração GPG Agent para SSH
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1

# Garante que o SSH_AUTH_SOCK aponte para o gpg-agent (essencial para o i3wm + greetd)
if [ -z "$SSH_AUTH_SOCK" ]; then
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
fi
