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
    echo "3) Instalación completa (enlaces + APT)"
    echo "4) Salir"
    echo ""
}

install_apt_packages() {
    # Paquetes clave esenciales de la configuración.
    # NOTA: packages/apt-manual.txt es solo un volcado de referencia de
    # `dpkg -l` (incluye la base del sistema y paquetes de terceros que no
    # existen sin sus repositorios), por eso NO se instala automáticamente.
    log_info "Instalando paquetes base recomendados desde APT..."
    sudo apt update
    local essential_pkgs=('zsh' 'zsh-autosuggestions' 'zsh-syntax-highlighting' 'starship' 'zoxide' 'eza' 'bat' 'ripgrep' 'fd-find' 'fzf' 'chafa' 'timg' 'tmux' 'neovim' 'git' 'curl' 'build-essential' 'xdotool' 'flatpak')
    sudo apt install -y "${essential_pkgs[@]}"
    log_success "Paquetes esenciales instalados."

    generate_locale

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

generate_locale() {
    local locale_name="es_ES.UTF-8"

    command -v locale-gen >/dev/null 2>&1 || return 0
    if locale -a 2>/dev/null | grep -qi '^es_ES\.utf-8$'; then
        return 0
    fi

    log_info "Generando la locale $locale_name (evita los avisos de LC_CTYPE)..."
    if [ -f /etc/locale.gen ]; then
        sudo sed -i "s/^# *${locale_name} UTF-8/${locale_name} UTF-8/" /etc/locale.gen 2>/dev/null \
            || printf '%s UTF-8\n' "$locale_name" | sudo tee -a /etc/locale.gen >/dev/null
    fi
    sudo locale-gen >/dev/null 2>&1 || log_warn "No se pudo generar la locale $locale_name."
}

install_opencode_deps() {
    local opencode_config="$DOTFILES_DIR/config/opencode"

    [ -f "$opencode_config/package.json" ] || return 0

    if ! command -v npm >/dev/null 2>&1; then
        log_warn "npm no disponible; se omite la instalación de dependencias de opencode."
        return 0
    fi

    log_info "Instalando dependencias de opencode (plugins)..."
    if npm install --prefix "$opencode_config" --no-audit --no-fund; then
        log_success "Dependencias de opencode listas en $opencode_config/node_modules."
    else
        log_warn "No se pudieron instalar las dependencias de opencode (¿sin red?)."
        log_warn "Si opencode se queda cargando: npm install --prefix ~/.config/opencode"
        log_warn "o ábrelo temporalmente con: opencode --pure"
    fi

    # Precachear el MCP de chrome-devtools para que el primer uso no tarde.
    if command -v npx >/dev/null 2>&1; then
        log_info "Precacheando chrome-devtools-mcp (solo la primera vez)..."
        npx -y chrome-devtools-mcp@1.10.1 --help >/dev/null 2>&1 \
            || log_warn "No se pudo precachear chrome-devtools-mcp (opcional)."
    fi
}

install_npm_globals() {
    local list_file="$DOTFILES_DIR/packages/npm-globals.txt"
    local pkg
    local to_install=()

    [ -f "$list_file" ] || return 0
    if ! command -v npm >/dev/null 2>&1; then
        log_warn "npm no disponible; se omite la instalación de paquetes globales."
        return 0
    fi

    while IFS= read -r pkg; do
        case "$pkg" in ''|'#'*) continue ;; esac
        to_install+=("$pkg")
    done < "$list_file"

    [ ${#to_install[@]} -eq 0 ] && return 0

    log_info "Instalando paquetes globales de npm en ~/.npm-global..."
    if npm install -g --no-audit --no-fund "${to_install[@]}"; then
        log_success "Paquetes globales de npm instalados."
    else
        log_warn "No se pudieron instalar todos los paquetes globales de npm."
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
            # Si ya es el enlace simbólico correcto, no tocar nada
            if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
                log_info "Ya vinculado: $dest -> $src"
                return
            fi
            mkdir -p "$BACKUP_DIR/$(dirname "${dest#$HOME/}")"
            mv "$dest" "$BACKUP_DIR/${dest#$HOME/}"
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
    if [ -d "$BACKUP_DIR" ]; then
        log_info "Los archivos reemplazados fueron respaldados en: $BACKUP_DIR"
    fi

    # Importante: el plugin de opencode ejecuta `npm install` al cargar.
    # Sin esto, el primer arranque se queda cargando mientras la red fría
    # tarda (o falla) en traer @opencode-ai/plugin.
    install_opencode_deps
}

# Procesamiento de argumentos o menú interactivo
if [ "$1" = "--links" ] || [ "$1" = "-l" ]; then
    create_symlinks
    exit 0
elif [ "$1" = "--packages" ] || [ "$1" = "-p" ]; then
    install_apt_packages
    install_npm_globals
    exit 0
elif [ "$1" = "--all" ] || [ "$1" = "-a" ]; then
    # Enlaces primero: si apt falla (p. ej. sin red), al menos la
    # configuración ya queda vinculada.
    create_symlinks
    install_apt_packages || log_warn "La instalación de APT falló; los enlaces ya quedaron creados."
    install_npm_globals
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
        install_npm_globals
        ;;
    3)
        create_symlinks
        install_apt_packages || log_warn "La instalación de APT falló; los enlaces ya quedaron creados."
        install_npm_globals
        ;;
    4)
        exit 0
        ;;
    *)
        log_error "Opción no válida."
        exit 1
        ;;
esac
