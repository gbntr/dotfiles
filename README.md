
# Dotfiles (Arch Linux + Niri)

[🇧🇷 Português] | [🇺🇸 English](#english)

---

## 🇧🇷 Português

Este repositório contém meus arquivos de configuração pessoais (dotfiles) para **Arch Linux / EndeavourOS**, focados no gerenciador de janelas **Niri**.

O gerenciamento é feito via **GNU Stow**, permitindo a criação de links simbólicos de forma modular e limpa.

### Destaques do Setup
* **WM:** Niri (Wayland)
* **Terminal:** Kitty + Zsh + Starship
* **Editor:** Helix
* **File Manager:** Yazi & Nemo
* **Browser:** Zen Browser / Firefox
* **Shell Theme:** Pokemon-colorscripts + Noctalia

### Instalação Automática

O script `install.sh` incluído realiza as seguintes tarefas:
1.  Detecta o sistema e instala dependências base (Áudio/Pipewire, Polkit, Filesystem).
2.  Instala os pacotes necessários (oficiais e AUR).
3.  Utiliza o `stow` para criar os links simbólicos automaticamente.
4.  Ativa serviços do systemd necessários.

#### Como usar (Instalação Limpa)

1.  Instale o Git (único pré-requisito):
    ```bash
    sudo pacman -S git
    ```

2.  Clone este repositório para sua home:
    ```bash
    git clone [https://github.com/gbntr/dotfiles.git](https://github.com/gbntr/dotfiles.git) ~/dotfiles
    ```

3.  Entre no diretório e execute o instalador:
    ```bash
    cd ~/dotfiles
    chmod +x install.sh
    ./install.sh
    ```

4.  Siga as instruções na tela. Reinicie o sistema ao finalizar.

### Estrutura

* Cada pasta raiz representa um pacote (ex: `kitty`, `niri`).
* Dentro de cada pasta, a estrutura espelha o diretório `$HOME` (ex: `niri/.config/niri/config.kdl`).
* Para adicionar uma nova configuração, basta criar a pasta e rodar `stow nome-da-pasta`.

---

## 🇺🇸 English

<a name="english"></a>

This repository contains my personal configuration files (dotfiles) for **Arch Linux / EndeavourOS**, focused on the **Niri** window manager.

Management is handled via **GNU Stow**, allowing for modular and clean symbolic linking.

### Setup Highlights
* **WM:** Niri (Wayland)
* **Terminal:** Kitty + Zsh + Starship
* **Editor:** Helix
* **File Manager:** Yazi & Nemo
* **Browser:** Zen Browser / Firefox
* **Shell Theme:** Pokemon-colorscripts + Noctalia

### Automated Installation

The included `install.sh` script performs the following tasks:
1.  Detects the system and installs base dependencies (Audio/Pipewire, Polkit, Filesystem).
2.  Installs necessary packages (Official and AUR).
3.  Uses `stow` to automatically create symbolic links.
4.  Enables necessary systemd services.

#### How to Use (Fresh Install)

1.  Install Git (only prerequisite):
    ```bash
    sudo pacman -S git
    ```

2.  Clone this repository to your home folder:
    ```bash
    git clone [https://github.com/gbntr/dotfiles.git](https://github.com/gbntr/dotfiles.git) ~/dotfiles
    ```

3.  Enter the directory and run the installer:
    ```bash
    cd ~/dotfiles
    chmod +x install.sh
    ./install.sh
    ```

4.  Follow the on-screen instructions. Reboot the system when finished.

### Structure

* Each root folder represents a package (e.g., `kitty`, `niri`).
* Inside each folder, the structure mirrors the `$HOME` directory (e.g., `niri/.config/niri/config.kdl`).
* To add a new configuration, simply create the folder and run `stow folder-name`.
