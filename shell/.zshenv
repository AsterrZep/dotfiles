[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Flatpak: hacer visibles las apps exportadas (si no se pierde en zsh
# porque .bashrc hace `exec zsh` antes de llegar a su línea XDG_DATA_DIRS)
if [ -d /var/lib/flatpak/exports/share ]; then
    case ":${XDG_DATA_DIRS:-/usr/local/share:/usr/share}:" in
        *:/var/lib/flatpak/exports/share:*) ;;
        *) export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}:/var/lib/flatpak/exports/share" ;;
    esac
fi
