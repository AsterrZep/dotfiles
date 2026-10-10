# 🐧 Mis Dotfiles y Configuraciones de Linux en ChromeOS (Crostini)

> Repositorio personal de configuraciones, entornos de desarrollo, scripts y herramientas para Debian GNU/Linux en el contenedor Crostini de ChromeOS.

---

## 📋 Resumen del Entorno

- **Sistema Base:** Debian GNU/Linux en contenedor Crostini (ChromeOS).
- **Shell Principal:** `zsh` con `zsh-autosuggestions` y `zsh-syntax-highlighting` (inicializado por defecto desde `.bashrc`).
- **Prompt:** [Starship](https://starship.rs/) personalizado con indicadores de lenguajes (`Python`, `Node.js`, `Go`, `Rust`, etc.) y estado Git.
- **Navegación y Búsqueda:** `zoxide` (`zi`), `fzf` con preview interactivo con soporte de imágenes y directorios, `fd-find` y `ripgrep`.
- **Multiplexor:** `tmux` con tema estilo Catppuccin Mocha y atajos de teclado tipo Vim.
- **Editor Principal:** `Neovim` configurado sobre NvChad (tema `onedark`, formateo automático con `conform.nvim`, LSPs configurados para Python, TS/JS, Julia, HTML/CSS y Treesitter completo).
- **Editores Secundarios / Herramientas:** Fresh Editor (`~/.config/fresh`), Opencode (`~/.config/opencode`), Godot 4.7.
- **Lenguajes y Runtimes:** Node.js (`pnpm`, `bun`, `npm-global`), Python (`uv`, `pip`), Rust (`cargo`, `rustup`), Julia (`juliaup`).
- **Integración ChromeOS:** Escalado en Sommelier, control de Garcon, servidor XWayland con Weston y lanzador automatizado de Wine (`xdotool`).

---

## 📂 Estructura del Repositorio

```text
dotfiles/
├── .gitignore               # Filtro estricto contra secretos, caches e historiales
├── README.md                # Documentación completa del sistema
├── install.sh               # Script automatizado de instalación y respaldos
├── shell/
│   ├── .zshrc               # Configuración principal interactiva de Zsh
│   ├── .zshenv              # Carga de variables de entorno (Rust Cargo, etc.)
│   ├── .bashrc              # Lanzador a Zsh y variables de fallback
│   ├── .profile             # Variables globales de inicio de sesión
│   └── .sommelierrc         # Opciones de Sommelier para escalado en ChromeOS
├── tmux/
│   └── .tmux.conf           # Estilos Catppuccin, división de paneles y navegación Vim
├── git/
│   └── .gitconfig           # Configuración global de Git
├── npm/
│   └── .npmrc               # Prefijo global ~/.npm-global + allow-scripts de npm
├── config/
│   ├── starship.toml        # Tema del prompt Starship
│   ├── cros-garcon.conf     # Ajustes del servicio Garcon de ChromeOS
│   ├── weston.ini           # Configuración del compositor XWayland
│   ├── xdg-terminals.list   # Terminal predeterminada de ChromeOS
│   ├── nvim/                # Configuración completa de Neovim (NvChad + LSPs)
│   ├── fresh/               # Configuración de Fresh Editor (tema Dracula)
│   ├── opencode/            # Configuración de Opencode y agentes
│   └── godot/               # Preferencias de interfaz de Godot 4.7
├── scripts/
│   ├── fzf-preview.sh       # Visor con chafa (imágenes), eza (carpetas) y batcat (código)
│   ├── julialsp             # Wrapper para el servidor de lenguaje de Julia
│   └── cadesimu4_pcsimu     # Script de arranque y automatización con xdotool para Wine
└── packages/
    ├── apt-manual.txt       # Volcado de referencia de `dpkg -l` (NO instalar tal cual)
    ├── flatpak-list.txt     # Aplicaciones y runtimes Flatpak
    ├── npm-globals.txt      # Paquetes globales de Node.js (una línea por paquete)
    └── cargo-binaries.txt   # Binarios instalados con Cargo (Rust)
```

---

## ⚡ Aliases y Atajos Destacados

### Comandos Modernos (Coreutils mejorados)
| Alias / Comando | Reemplazo real | Descripción |
|---|---|---|
| `ls` | `eza --group-directories-first` | Listado rápido de archivos |
| `ll` | `eza -la --icons=auto` | Listado detallado con permisos e íconos |
| `lt` / `tree` | `eza --tree --icons=auto` | Vista en árbol |
| `cat` / `bat` | `batcat` | Visualizador de archivos con resaltado de sintaxis |
| `grep` | `rg` | Búsqueda ultrarrápida con Ripgrep |
| `rg` | `rg --hidden --no-ignore` | Ripgrep incluyendo archivos ocultos |
| `fd` | `fdfind` | Búsqueda rápida de archivos por nombre |
| `showimg` | `chafa` | Muestra imágenes directamente en la terminal en caracteres ANSI/sixel |
| `viewimg` / `timg`| `timg` | Visor de imágenes en terminal |

### Productividad y Flujo de Trabajo
| Comando | Acción |
|---|---|
| `take <carpeta>` | Crea el directorio y entra en él (`mkdir -p "$1" && cd "$1"`) |
| `...` | Sube 2 niveles (`cd ../..`) |
| `....` | Sube 3 niveles (`cd ../../..`) |
| `zi` | Navegación interactiva de directorios con `zoxide` y `fzf` |
| `Ctrl + R` | Búsqueda histórica interactiva difusa con `fzf` |
| `Ctrl + T` | Búsqueda interactiva de archivos con preview en vivo |
| `update` | Actualiza el sistema (`sudo apt update && sudo apt upgrade -y`) |
| `reload` | Recarga la shell actual (`exec zsh`) |
| `zshconfig` | Abre `.zshrc` en Neovim |

### Atajos Git
- `gs` ➔ `git status`
- `ga` ➔ `git add`
- `gaa` ➔ `git add -A`
- `gc` / `gcm` ➔ `git commit -m`
- `gp` ➔ `git push`
- `gpl` ➔ `git pull`
- `gd` ➔ `git diff`
- `gl` ➔ `git log --oneline --graph --decorate`

### Atajos Tmux
- Prefix: `Ctrl + b`
- `tm` ➔ Conectar o crear sesión `main` (`tmux new -A -s main`)
- `tls` ➔ Listar sesiones activas
- `tkill` ➔ Terminar servidor de tmux
- `Prefix` + `|` ➔ División horizontal conservando la ruta actual
- `Prefix` + `-` ➔ División vertical conservando la ruta actual
- `Prefix` + `h/j/k/l` ➔ Moverse entre paneles estilo Vim
- `Prefix` + `r` ➔ Recargar configuración de tmux al vuelo

---

## 🛠️ Instalación y Restauración

### 1. Clonar el repositorio
```bash
git clone git@github.com:AsterrZep/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Ejecutar el asistente de instalación
El script `install.sh` se encarga de crear los enlaces simbólicos de forma segura (respaldando cualquier archivo existente en `~/.dotfiles_backup/`):

```bash
chmod +x install.sh
./install.sh
```

O usando argumentos directos:
- Solo enlazar archivos de configuración y scripts:
  ```bash
  ./install.sh --links
  ```
- Instalar paquetes esenciales de APT:
  ```bash
  ./install.sh --packages
  ```
- Instalación completa:
  ```bash
  ./install.sh --all
  ```

### 3. Orden recomendado en un contenedor nuevo

`install.sh` cubre enlaces, los paquetes apt esenciales, la locale `es_ES.UTF-8`
y las dependencias de `~/.config/opencode` (evita que opencode se quede cargando
mientras hace un `npm install` en frío). El resto es manual:

```bash
./install.sh --all
# Node.js (nvm): el bloque final de .zshrc lo carga desde ~/.config/nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
# Rust / Julia / Flatpak: instalar desde su web o con apt
```

Advertencias:

- **`packages/apt-manual.txt` es un volcado de `dpkg -l`** (incluye la base del
  sistema y paquetes de terceros que no existen sin sus repositorios). Sirve de
  referencia, no se instala automáticamente. Lo único que instala `install.sh`
  es la lista `essential_pkgs` del propio script.
- **`packages/cargo-binaries.txt` mezcla componentes de `rustup`**
  (`rustfmt`, `clippy`, `rust-analyzer`…) con herramientas de `cargo install`.
  Los componentes se instalan con `rustup component add`.
- **Un solo npm global**: `prefix=~/.npm-global` en `npm/.npmrc` manda los
  paquetes globales fuera del árbol de nvm (sobreviven a los cambios de
  versión de Node). El `npm`/`npx` que se ejecutan son los de nvm: no hay que
  instalar el paquete `npm` con `npm i -g`, porque un `~/.npm-global/bin/npm`
  taparía al de nvm y las actualizaciones globales dejarían de verse.
  nvm avisa en cada arranque por ese `prefix` (es cosmético; `.zshrc` filtra
  el aviso). **No ejecutes** `nvm use --delete-prefix` si no quieres que
  borre esa línea de este archivo.

---

## 🔒 Seguridad y Privacidad

Por motivos de seguridad, los siguientes datos **nunca** forman parte de este repositorio:
- Claves privadas SSH (`~/.ssh/id_*`).
- Credenciales y tokens de acceso (como tokens de GitHub CLI, Azure, Supabase o IA).
- Historiales de terminal (`~/.zsh_history`, `~/.bash_history`).
- Perfiles de navegadores y certificados locales (`~/.pki`, `~/.cache`, datos de Chrome).
- Archivos `.env` con variables de entorno de producción.
