#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Setup & Restore Script (ChromeOS / Crostini Linux)
# Usuario: aster
# ==============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Colores para mensajes
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_PURPLE='\033[0;35m'
C_CYAN='\033[0;36m'

log_info() { echo -e "${C_CYAN}[INFO]${C_RESET} $1"; }
log_success() { echo -e "${C_GREEN}[OK]${C_RESET} $1"; }
log_warn() { echo -e "${C_YELLOW}[AVISO]${C_RESET} $1"; }
log_error() { echo -e "${C_RED}[ERROR]${C_RESET} $1"; }

backup_and_link() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        # Si ya es el enlace simbólico correcto, omitir
        if [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
            log_info "Ya vinculado: $dest -> $src"
            return
        fi

        mkdir -p "$BACKUP_DIR"
        local rel_path="${dest#$HOME/}"
        mkdir -p "$BACKUP_DIR/$(dirname "$rel_path")"
        mv "$dest" "$BACKUP_DIR/$rel_path"
        log_warn "Copia de respaldo creada: $dest -> $BACKUP_DIR/$rel_path"
    fi

    ln -s "$src" "$dest"
    log_success "Vinculado: $dest -> $src"
}

setup_directories() {
    log_info "Creando directorios necesarios..."
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.npm-global/bin"
}

link_dotfiles() {
    log_info "Configurando enlaces simbólicos..."
    setup_directories

    # Shell
    backup_and_link "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"
    backup_and_link "$DOTFILES_DIR/shell/.zshenv" "$HOME/.zshenv"
    backup_and_link "$DOTFILES_DIR/shell/.bashrc" "$HOME/.bashrc"
    backup_and_link "$DOTFILES_DIR/shell/.profile" "$HOME/.profile"
    [ -f "$DOTFILES_DIR/shell/.sommelierrc" ] && backup_and_link "$DOTFILES_DIR/shell/.sommelierrc" "$HOME/.sommelierrc"

    # Tmux & Git & NPM
    backup_and_link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    backup_and_link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
    [ -f "$DOTFILES_DIR/npm/.npmrc" ] && backup_and_link "$DOTFILES_DIR/npm/.npmrc" "$HOME/.npmrc"

    # Configs
    [ -f "$DOTFILES_DIR/config/starship.toml" ] && backup_and_link "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
    [ -f "$DOTFILES_DIR/config/cros-garcon.conf" ] && backup_and_link "$DOTFILES_DIR/config/cros-garcon.conf" "$HOME/.config/cros-garcon.conf"
    [ -f "$DOTFILES_DIR/config/weston.ini" ] && backup_and_link "$DOTFILES_DIR/config/weston.ini" "$HOME/.config/weston.ini"
    [ -f "$DOTFILES_DIR/config/xdg-terminals.list" ] && backup_and_link "$DOTFILES_DIR/config/xdg-terminals.list" "$HOME/.config/xdg-terminals.list"

    # Neovim
    if [ -d "$DOTFILES_DIR/config/nvim" ]; then
        backup_and_link "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
    fi

    # Fresh
    if [ -d "$DOTFILES_DIR/config/fresh" ]; then
        backup_and_link "$DOTFILES_DIR/config/fresh" "$HOME/.config/fresh"
    fi

    # Opencode
    if [ -d "$DOTFILES_DIR/config/opencode" ]; then
        backup_and_link "$DOTFILES_DIR/config/opencode" "$HOME/.config/opencode"
    fi

    # Godot
    if [ -f "$DOTFILES_DIR/config/godot/editor_settings-4.7.tres" ]; then
        mkdir -p "$HOME/.config/godot"
        backup_and_link "$DOTFILES_DIR/config/godot/editor_settings-4.7.tres" "$HOME/.config/godot/editor_settings-4.7.tres"
    fi

    # Scripts personales en ~/.local/bin
    for script in "$DOTFILES_DIR/scripts"/*; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            backup_and_link "$script" "$HOME/.local/bin/$(basename "$script")"
        fi
    done

    log_success "Todos los enlaces se han configurado correctamente."
    if [ -d "$BACKUP_DIR" ]; then
        log_info "Los archivos reemplazados fueron respaldados en: $BACKUP_DIR"
    fi
}

install_apt_packages() {
    if [ ! -f "$DOTFILES_DIR/packages/apt-manual.txt" ]; then
        log_warn "No se encontró packages/apt-manual.txt"
        return
    fi
    log_info "Instalando paquetes base recomendados desde APT..."
    sudo apt update
    # Paquetes clave esenciales de la configuración
    local essential_pkgs=(
        zsh zsh-autosuggestions zsh-syntax-highlighting
        starship zoxide eza bat ripgrep fd-find fzf chafa timg tmux
        neovim git curl build-essential xdotool flatpak
    )
    sudo apt install -y "${essential_pkgs[@]}"
    log_success "Paquetes esenciales instalados."
}

show_menu() {
    echo -e "${C_PURPLE}==============================================${C_RESET}"
    echo -e "${C_PURPLE}   Instalador de Dotfiles - ChromeOS Linux    ${C_RESET}"
    echo -e "${C_PURPLE}==============================================${C_RESET}"
    echo "1) Crear enlaces simbólicos (dotfiles y scripts)"
    echo "2) Instalar paquetes esenciales vía APT"
    echo "3) Instalación completa (paquetes + enlaces)"
    echo "4) Salir"
    echo ""
    read -rp "Selecciona una opción [1-4]: " opt
    case "$opt" in
        1) link_dotfiles ;;
        2) install_apt_packages ;;
        3) install_apt_packages && link_dotfiles ;;
        4) exit 0 ;;
        *) log_error "Opción no válida"; exit 1 ;;
    esac
}

# Si se pasan parámetros por línea de comandos
if [ "$1" = "--links" ] || [ "$1" = "-l" ]; then
    link_dotfiles
elif [ "$1" = "--packages" ] || [ "$1" = "-p" ]; then
    install_apt_packages
elif [ "$1" = "--all" ] || [ "$1" = "-a" ]; then
    install_apt_packages
    link_dotfiles
else
    show_menu
fi
