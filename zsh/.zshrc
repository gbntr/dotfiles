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
# Rice (Desativados)
#pokemon-colorscripts --no-title -s -r
#pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -
#fastfetch -c $HOME/.config/fastfetch/config.jsonc
#neofetch

# Inicialização de ferramentas (Devem ficar no final)
source <(fzf --zsh)
eval "$(zoxide init zsh)"
