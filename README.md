# arch-dev-setup

Instalación reproducible de una estación de desarrollo full stack sobre **Arch Linux + Hyprland**, con agentes de IA en la nube (Claude Code, Codex, Gemini, OpenCode, Grok) y **Claude Code como asistente del sistema**.

Pensado para: Ryzen 5 5600X · 48 GB RAM · **RTX 5050** (Blackwell) · ASRock B550 Phantom Gaming 4/ac · arranque dual con Windows en otro disco.

## Qué instala

| Paso | Script | Contenido |
|---|---|---|
| 00 | `00-base.sh` | Ajustes de pacman, mirrors con reflector, herramientas base, **paru** (AUR) |
| 10 | `10-nvidia.sh` | `nvidia-open-dkms`, KMS temprano, VA-API, suspensión |
| 20 | `20-snapshots-boot.sh` | **snapper + snap-pac** (snapshot automático en cada `pacman`), snapshots en el menú GRUB, detección de Windows |
| 30 | `30-desktop.sh` | **Hyprland** vía uwsm, greetd/tuigreet, waybar, fuzzel, mako, kitty, PipeWire, Bluetooth |
| 40 | `40-dev.sh` | Docker, **mise** (Node LTS, Python), CLIs: fzf, ripgrep, eza, bat, zoxide, lazygit, gh, starship |
| 50 | `50-apps.sh` | VS Code y Google Chrome (AUR) en Wayland nativo |
| 60 | `60-ai-clis.sh` | Claude Code, Codex, Gemini CLI, OpenCode, Grok Build |
| 70 | `70-dotfiles.sh` | Enlaza `dotfiles/` en `$HOME` con stow (respalda lo que exista) |

Las listas de paquetes están en `packages/*.txt`: edítalas para añadir o quitar cosas.

---

## 1. Antes de empezar (en Windows)

1. **Respaldo** de lo importante.
2. Confirma en *Administración de discos* qué disco será para Linux. **Usa un disco completo distinto al de Windows.**
3. Desactiva **Inicio rápido** (Panel de control → Opciones de energía → Elegir el comportamiento de los botones).
4. Opcional, para que la hora no se desfase entre sistemas (PowerShell como admin):
   ```powershell
   reg add "HKLM\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d 1 /f
   ```
5. Crea el USB con la ISO de [archlinux.org/download](https://archlinux.org/download/) (Rufus en modo GPT/UEFI, o Ventoy).

### BIOS (ASRock B550)
- **Secure Boot: desactivado** (evita tener que firmar el módulo de NVIDIA).
- **SVM Mode: activado** (virtualización; útil para Docker/VMs).
- Modo de arranque **UEFI**.

> Consejo: desconecta físicamente el disco de Windows durante la instalación. Así es imposible formatearlo por error. Vuélvelo a conectar después; el paso 20 lo añade al menú GRUB.

## 2. Instalar Arch con archinstall

Arranca desde el USB y conéctate a internet (cable, o `iwctl` para Wi-Fi). Después:

```bash
curl -LO https://raw.githubusercontent.com/joseariasrd/arch-dev-setup/main/archinstall/user_configuration.json
archinstall --config user_configuration.json
```

La configuración precarga idioma, teclado `us`, zona horaria, GRUB, perfil mínimo, driver NVIDIA open, PipeWire y NetworkManager. **En el menú revisa y completa a mano:**

| Opción | Qué elegir |
|---|---|
| **Disk configuration** | *Use a best-effort default partition layout* → **el disco de Linux** → **btrfs** → **sí** a subvolúmenes por defecto → compresión **zstd** |
| **Bootloader** | Confirma que diga **Grub** |
| **Profile** | Minimal (sin escritorio: Hyprland lo instala el paso 30) |
| **Graphics driver** | Nvidia (open kernel module) |
| **Root password / User account** | Crea tu usuario con **sudo** |

> Si tu versión de archinstall ignora alguna clave del JSON, simplemente elígela en el menú: el JSON es solo un atajo.

Al terminar, reinicia y entra con tu usuario (pantalla de texto).

## 3. Ejecutar el bootstrap

```bash
nmtui                       # si usas Wi-Fi
git clone https://github.com/joseariasrd/arch-dev-setup.git ~/dotfiles
cd ~/dotfiles
./install.sh
sudo reboot
```

- Tarda ~20–40 min. Todo queda en un log `~/arch-dev-setup-*.log`.
- Para que no te pregunte nada al construir paquetes AUR: `PARU_SKIPREVIEW=1 ./install.sh`.
- Para repetir un paso: `./install.sh --only 30-desktop` (lista: `./install.sh --list`).
- Todos los pasos se pueden volver a ejecutar sin romper nada.

Tras el reinicio aparece la pantalla de login (tuigreet) y entra a Hyprland.

## 4. Primeros pasos en Hyprland

1. `Super + Enter` → terminal. Comprueba la GPU: `nvidia-smi`.
2. Inicia sesión en cada CLI de IA: `claude`, `codex`, `gemini`, `opencode auth login`, `grok login`.
3. Configura git: `git config --global user.name "..."` y `user.email`.
4. Fija tu monitor en `~/.config/hypr/local.conf`, por ejemplo:
   ```
   monitor = DP-1, 2560x1440@165, 0x0, 1
   ```
   (nombres con `hyprctl monitors`).

### Atajos principales

| Atajo | Acción |
|---|---|
| `Super + Enter` | Terminal (kitty) |
| `Super + D` | Lanzador de apps (fuzzel) |
| **`Super + A`** | **Asistente del sistema: Claude Code flotante en `~/dotfiles`** |
| `Super + B` / `C` / `E` | Chrome / VS Code / Archivos |
| `Super + Q` | Cerrar ventana |
| `Super + V` / `F` / `T` | Flotante / Pantalla completa / Cambiar división |
| `Super + 1…9` | Ir a escritorio · `+ Shift` mover ventana |
| `Super + flechas` o `H J K L` | Mover foco |
| `Super + S` | Escritorio "scratch" oculto |
| `Super + Shift + V` | Historial del portapapeles |
| `Impr Pant` / `Shift + Impr Pant` | Captura de región / pantalla completa al portapapeles |
| `Super + Esc` / `Super + Shift + Esc` | Bloquear / cerrar sesión |

## 5. Usar la IA para administrar el sistema

`Super + A` (o el alias `ai`) abre Claude Code dentro de este repositorio. Al arrancar lee **`CLAUDE.md`**, que le explica tu hardware, dónde vive cada configuración y las reglas (editar aquí y no en `~/.config`, hacer snapshot antes de cambios delicados, registrar paquetes nuevos en `packages/*.txt`, commitear cada cambio).

Ejemplos:
- "Instala Postgres 16 con Docker Compose para desarrollo y añádelo al repo."
- "Pon el volumen y el Bluetooth en waybar con iconos."
- "Configura mi monitor a 165 Hz."

`AGENTS.md` y `GEMINI.md` apuntan al mismo archivo, así Codex, OpenCode y Gemini reciben el mismo contexto.

## 6. Si algo se rompe

- **Una actualización rompió algo:** reinicia → menú GRUB → *Arch Linux snapshots* → elige el snapshot anterior → arranca → `sudo snapper rollback` → reinicia.
- **Hyprland no arranca:** en tuigreet, `Ctrl+Alt+F2` abre una consola; revisa `journalctl --user -b` y `hyprctl configerrors`.
- **Pantalla negra con NVIDIA:** en GRUB pulsa `e` y añade `nvidia_drm.modeset=0` a la línea `linux` para entrar y diagnosticar.
- **Antes de actualizar:** revisa [archlinux.org/news](https://archlinux.org/news/) si la actualización es grande.

## Notas

- Los instaladores de los CLIs de IA cambian a menudo. Si alguno falla, el paso 60 sigue con los demás y te dice cuál instalar a mano. La URL de Grok Build (`x.ai/cli`) está pendiente de verificar.
- La sintaxis de reglas de Hyprland cambia entre versiones. Si `Super + A` no abre la ventana flotante, revisa `hyprctl configerrors` y ajusta la línea en `hyprland.conf`.
- Claude Desktop/Cowork no se instala aquí: no tiene soporte oficial en Arch. Úsalo desde Windows.
