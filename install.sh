#!/usr/bin/env bash
set -e

# Directorios y rutas
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Colores para la interfaz
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_PURPLE='\033[0;35m'
C_CYAN='\033[0;36m'

log_info()    { echo -e "${C_CYAN}[INFO]${C_RESET} $1"; }
log_success() { echo -e "${C_GREEN}[OK]${C_RESET} $1"; }
log_warn()    { echo -e "${C_YELLOW}[AVISO]${C_RESET} $1"; }
log_error()   { echo -e "${C_RED}[ERROR]${C_RESET} $1"; }

show_menu() {
    echo -e "${C_PURPLE}==============================================${C_RESET}"
    echo -e "${C_PURPLE}    Instalador de Dotfiles - ChromeOS Linux    ${C_RESET}"
    echo -e "${C_PURPLE}==============================================${C_RESET}"
    echo "1) Crear enlaces simbólicos (dotfiles y scripts)"
    echo "2) Instalar paquetes esenciales vía APT"
    echo "3) Instalación completa (paquetes + enlaces)"
    echo "4) Salir"
    echo ""
}

install_apt_packages() {
    if [ ! -f "$DOTFILES_DIR/packages/apt-manual.txt" ]; then
        log_info "Instalando paquetes base recomendados desde APT..."
        sudo apt update
        local essential_pkgs=('zsh' 'zsh-autosuggestions' 'zsh-syntax-highlighting' 'starship' 'zoxide' 'eza' 'bat' 'ripgrep' 'fd-find' 'fzf' 'chafa' 'timg' 'tmux' 'neovim' 'git' 'curl' 'build-essential' 'xdotool' 'flatpak')
        sudo apt install -y "${essential_pkgs[@]}"
        log_success "Paquetes esenciales instalados."
    else
        log_info "Instalando paquetes desde apt-manual.txt..."
        sudo apt update
        sudo apt install -y $(cat "$DOTFILES_DIR/packages/apt-manual.txt")
        log_success "Paquetes de apt-manual.txt instalados."
    fi

    # Configurar Zsh como shell por defecto de forma no interactiva segura
    local zsh_path
    zsh_path="$(which zsh)"
    if [ "$SHELL" != "$zsh_path" ]; then
        log_info "Configurando Zsh como shell por defecto..."
        if grep -q "$zsh_path" /etc/shells; then
            sudo chsh -s "$zsh_path" "$USER" || chsh -s "$zsh_path" || log_warn "No se pudo cambiar automáticamente la shell con chsh."
        else
            echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
            sudo chsh -s "$zsh_path" "$USER" || chsh -s "$zsh_path" || log_warn "No se pudo cambiar automáticamente la shell con chsh."
        fi
        log_success "Shell predeterminada actualizada a Zsh."
    else
        log_info "Zsh ya está configurado como tu shell por defecto."
    fi
}

create_symlinks() {
    log_info "Configurando enlaces simbólicos..."
    log_info "Creando directorios necesarios..."
    mkdir -p "$HOME/.config/nvim"
    mkdir -p "$HOME/.config/fresh"
    mkdir -p "$HOME/.config/opencode"
    mkdir -p "$HOME/.config/godot"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.cargo"

    link_file() {
        local src="$1"
        local dest="$2"
        if [ -e "$dest" ] || [ -L "$dest" ]; then
            mkdir -p "$(dirname "$BACKUP_DIR/$(basename "$(dirname "$dest")")")"
            if [ -d "$dest" ] && [ ! -L "$dest" ]; then
                mkdir -p "$BACKUP_DIR/$(dirname "${dest#$HOME/}")"
                mv "$dest" "$BACKUP_DIR/${dest#$HOME/}"
            else
                mkdir -p "$BACKUP_DIR/$(dirname "${dest#$HOME/}")"
                mv "$dest" "$BACKUP_DIR/${dest#$HOME/}"
            fi
            log_warn "Copia de respaldo creada para: $dest"
        fi
        ln -sfn "$src" "$dest"
        log_success "Vinculado: $dest -> $src"
    }

    # Shell y configs principales
    link_file "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"
    link_file "$DOTFILES_DIR/shell/.zshenv" "$HOME/.zshenv"
    link_file "$DOTFILES_DIR/shell/.bashrc" "$HOME/.bashrc"
    link_file "$DOTFILES_DIR/shell/.profile" "$HOME/.profile"
    link_file "$DOTFILES_DIR/shell/.sommelierrc" "$HOME/.sommelierrc"
    link_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
    link_file "$DOTFILES_DIR/npm/.npmrc" "$HOME/.npmrc"

    # Configs de aplicaciones
    link_file "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
    link_file "$DOTFILES_DIR/config/cros-garcon.conf" "$HOME/.config/cros-garcon.conf"
    link_file "$DOTFILES_DIR/config/weston.ini" "$HOME/.config/weston.ini"
    link_file "$DOTFILES_DIR/config/xdg-terminals.list" "$HOME/.config/xdg-terminals.list"
    link_file "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
    link_file "$DOTFILES_DIR/config/fresh" "$HOME/.config/fresh"
    link_file "$DOTFILES_DIR/config/opencode" "$HOME/.config/opencode"
    link_file "$DOTFILES_DIR/config/godot/editor_settings-4.7.tres" "$HOME/.config/godot/editor_settings-4.7.tres"

    # Scripts locales
    link_file "$DOTFILES_DIR/scripts/cadesimu4_pcsimu" "$HOME/.local/bin/cadesimu4_pcsimu"
    link_file "$DOTFILES_DIR/scripts/fzf-preview.sh" "$HOME/.local/bin/fzf-preview.sh"
    link_file "$DOTFILES_DIR/scripts/julialsp" "$HOME/.local/bin/julialsp"

    log_success "Todos los enlaces se han configurado correctamente."
    log_info "Los archivos reemplazados fueron respaldados en: $BACKUP_DIR"
}

# Procesamiento de argumentos o menú interactivo
if [ "$1" = "--links" ] || [ "$1" = "-l" ]; then
    create_symlinks
    exit 0
elif [ "$1" = "--packages" ] || [ "$1" = "-p" ]; then
    install_apt_packages
    exit 0
elif [ "$1" = "--all" ] || [ "$1" = "-a" ]; then
    install_apt_packages
    create_symlinks
    exit 0
fi

show_menu
read -rp "Selecciona una opción [1-4]: " opt
case "$opt" in
    1)
        create_symlinks
        ;;
    2)
        install_apt_packages
        ;;
    3)
        install_apt_packages
        create_symlinks
        ;;
    4)
        exit 0
        ;;
    *)
        log_error "Opción no válida."
        exit 1
        ;;
esac
