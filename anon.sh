#!/bin/bash

# ======================================================
#           ANONYMOUS INSTALLER v2026
#        All-in-One Installation Script
# ======================================================

# ========== FUNGSI UTILITY ==========
print_banner() {
    clear
    cat << 'EOF'
==================================================
              Anonymous Installer v2026
==================================================
      _   _   _   _   _   _   _   _   _   
     / \ / \ / \ / \ / \ / \ / \ / \ / \  
    ( A | N | O | N | Y | M | O | U | S ) 
     \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/  
==================================================
EOF
}

print_header() {
    echo ""
    echo "=================================================="
    echo "  $1"
    echo "=================================================="
}

check_dependency() {
    if ! command -v $1 &>/dev/null; then
        return 1
    fi
    return 0
}

# ========== FUNGSI SETUP KEYBOARD ==========
setup_keyboard() {
    print_header "Setting Up Custom Keyboard"
    
    echo "[+] Configuring Termux extra keys..."
    
    # Backup konfigurasi lama
    if [ -f "$HOME/.termux/termux.properties" ]; then
        cp "$HOME/.termux/termux.properties" "$HOME/.termux/termux.properties.bak"
        echo "[+] Backup created: termux.properties.bak"
    fi
    
    # Buat direktori .termux jika belum ada
    mkdir -p "$HOME/.termux"
    
    # Pilihan layout keyboard
    echo ""
    echo "Pilih layout keyboard yang diinginkan:"
    echo "=========================================="
    echo "1) Default - Basic keys (ESC, TAB, CTRL, ALT)"
    echo "2) Hacker - With special symbols (|, /, -, _, +, =)"
    echo "3) Coding - With brackets and symbols ({, }, [, ], ;, :)"
    echo "4) Full - Complete with arrow keys and function keys"
    echo "5) Minimal - Only essential keys"
    echo "6) Command - With exit, cd, ls commands"  # BARU
    echo "7) Custom - Enter your own layout"
    echo "=========================================="
    echo ""
    read -p "Pilih [1-7]: " KEYBOARD_CHOICE
    
    case $KEYBOARD_CHOICE in
        1)
            # Default layout
            EXTRA_KEYS="[['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]"
            echo "[+] Using Default layout"
            ;;
        2)
            # Hacker layout with special symbols
            EXTRA_KEYS="[['ESC','|','/','-','_','+','='],['TAB','CTRL','ALT','{','}','[',']'],['HOME','UP','END','PGUP','LEFT','DOWN','RIGHT','PGDN']]"
            echo "[+] Using Hacker layout"
            ;;
        3)
            # Coding layout
            EXTRA_KEYS="[['ESC','{','}','[',']',';',':'],['TAB','CTRL','ALT','<','>','|','\\'],['HOME','UP','END','PGUP','LEFT','DOWN','RIGHT','PGDN']]"
            echo "[+] Using Coding layout"
            ;;
        4)
            # Full layout
            EXTRA_KEYS="[['ESC','/','-','HOME','UP','END','PGUP','DEL'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN','INS'],['F1','F2','F3','F4','F5','F6','F7','F8']]"
            echo "[+] Using Full layout"
            ;;
        5)
            # Minimal layout
            EXTRA_KEYS="[['ESC','TAB','CTRL','ALT'],['UP','DOWN','LEFT','RIGHT']]"
            echo "[+] Using Minimal layout"
            ;;
        6)
            # Command layout with exit, cd, ls
            EXTRA_KEYS="[['ESC','exit','cd','ls','/','-','_'],['TAB','CTRL','ALT','HOME','UP','END','PGUP'],['LEFT','DOWN','RIGHT','PGDN','DEL','INS','CLR']]"
            echo "[+] Using Command layout (exit, cd, ls)"
            ;;
        7)
            # Custom layout
            echo ""
            echo "[+] Masukkan custom keyboard layout"
            echo "Contoh format: [['KEY1','KEY2','KEY3'],['KEY4','KEY5','KEY6']]"
            echo ""
            echo "Tips untuk command keys:"
            echo "  - Gunakan 'exit' untuk tombol exit"
            echo "  - Gunakan 'cd' untuk tombol cd"
            echo "  - Gunakan 'ls' untuk tombol ls"
            echo ""
            read -p "Masukkan layout: " EXTRA_KEYS
            echo "[+] Using Custom layout"
            ;;
        *)
            # Default jika pilihan salah
            EXTRA_KEYS="[['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]"
            echo "[!] Pilihan tidak valid. Menggunakan Default layout."
            ;;
    esac
    
    # Tulis konfigurasi ke termux.properties
    cat > "$HOME/.termux/termux.properties" << EOF
# Termux Configuration
font_size=14
use_system_font=false
fullscreen=true
bell-character=ignore
use_black_ui=true

# Extra Keyboard Keys
extra-keys = $EXTRA_KEYS

# Keyboard Options
back-key=back
volume-keys=volume
enforce-char-based-input=true

# Terminal Emulation
bell-character=ignore
use-builtin-libicu=true
terminal-transcript-rows=2000

# Mouse Support
allow-external-apps=true
use-ipv6=true
EOF
    
    # Reload Termux settings
    if command -v termux-reload-settings &>/dev/null; then
        termux-reload-settings
        echo "[+] Termux settings reloaded."
    else
        echo "[!] termux-reload-settings not found. Please restart Termux manually."
    fi
    
    # Tampilkan layout yang dipilih
    echo ""
    echo "[+] Keyboard layout applied:"
    echo "   $EXTRA_KEYS"
    echo ""
}

# ========== FUNGSI KEYBOARD PRESETS ==========
show_keyboard_presets() {
    print_header "Keyboard Layout Presets"
    
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                           KEYBOARD PRESETS                                   ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  DEFAULT:    [ESC, /, -, HOME, UP, END, PGUP]                               ║
║              [TAB, CTRL, ALT, LEFT, DOWN, RIGHT, PGDN]                      ║
║                                                                              ║
║  HACKER:     [ESC, |, /, -, _, +, =]                                       ║
║              [TAB, CTRL, ALT, {, }, [, ]]                                   ║
║              [HOME, UP, END, PGUP, LEFT, DOWN, RIGHT, PGDN]                 ║
║                                                                              ║
║  CODING:     [ESC, {, }, [, ], ;, :]                                       ║
║              [TAB, CTRL, ALT, <, >, |, \]                                   ║
║              [HOME, UP, END, PGUP, LEFT, DOWN, RIGHT, PGDN]                 ║
║                                                                              ║
║  FULL:       [ESC, /, -, HOME, UP, END, PGUP, DEL]                         ║
║              [TAB, CTRL, ALT, LEFT, DOWN, RIGHT, PGDN, INS]                 ║
║              [F1, F2, F3, F4, F5, F6, F7, F8]                              ║
║                                                                              ║
║  MINIMAL:    [ESC, TAB, CTRL, ALT]                                         ║
║              [UP, DOWN, LEFT, RIGHT]                                        ║
║                                                                              ║
║  COMMAND:    [ESC, exit, cd, ls, /, -, _]      ⬅️ NEW!                     ║
║              [TAB, CTRL, ALT, HOME, UP, END, PGUP]                          ║
║              [LEFT, DOWN, RIGHT, PGDN, DEL, INS, CLR]                       ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
}

# ========== KONFIGURASI ==========
declare -a SOURCE_URLS=(
    "https://gitlab.com/whitehat57/anon/-/raw/main/installer.sh"
    "https://raw.githubusercontent.com/whitehat57/anon-installer/main/installer.sh"
    "https://filebin.net/anon_installer/installer.sh"
    "file://$HOME/installer.sh"
    "file://$HOME/.local/share/anon/installer.sh"
    "file://$HOME/Downloads/installer.sh"
    "file://$HOME/storage/downloads/installer.sh"
)

FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf"
LOG_FILE="$HOME/.anon_install.log"
TMP_SCRIPT="$HOME/.anon_installer.sh"

# ========== MULAI INSTALLER ==========
print_banner
echo "[+] Starting Anonymous Installer..."
echo "[+] Log file: $LOG_FILE"
echo ""

# ========== CEK DEPENDENSI AWAL ==========
print_header "Checking Dependencies"
MISSING=()
for cmd in curl bash wget git; do
    if ! check_dependency $cmd; then
        MISSING+=("$cmd")
    fi
done

if [ ${#MISSING[@]} -ne 0 ]; then
    echo "[-] Missing dependencies: ${MISSING[*]}"
    echo "[!] Please install them first:"
    for cmd in "${MISSING[@]}"; do
        echo "    - $cmd"
    done
    exit 1
fi
echo "[+] All dependencies satisfied."
echo ""

# ========== CEK ENVIRONMENT ==========
print_header "Environment Check"
if [ -d "/data/data/com.termux" ] || [ -d "$HOME/.termux" ]; then
    echo "[+] Termux environment detected."
    IS_TERMUX=true
else
    echo "[!] Not running in Termux. Some features may not work."
    IS_TERMUX=false
fi

# ========== TAMPILKAN PRESETS KEYBOARD ==========
if [ "$IS_TERMUX" = true ]; then
    show_keyboard_presets
fi

# ========== FUNGSI DOWNLOAD ==========
download_file() {
    local url=$1
    local output=$2
    local timeout=30
    
    if [[ "$url" == file://* ]]; then
        local filepath="${url#file://}"
        if [ -f "$filepath" ]; then
            cp "$filepath" "$output"
            return 0
        else
            return 1
        fi
    elif command -v curl &>/dev/null; then
        curl -fsSL --connect-timeout 10 --max-time $timeout "$url" -o "$output" 2>/dev/null
        return $?
    elif command -v wget &>/dev/null; then
        wget -q --timeout=$timeout -O "$output" "$url" 2>/dev/null
        return $?
    else
        return 1
    fi
}

# ========== DOWNLOAD INSTALLER UTAMA ==========
print_header "Downloading Main Installer"
echo "[+] Trying to download installer from multiple sources..."

DOWNLOAD_SUCCESS=false
TOTAL_SOURCES=${#SOURCE_URLS[@]}
CURRENT_SOURCE=0

for url in "${SOURCE_URLS[@]}"; do
    CURRENT_SOURCE=$((CURRENT_SOURCE + 1))
    echo "[$CURRENT_SOURCE/$TOTAL_SOURCES] Trying: $url"
    
    rm -f "$TMP_SCRIPT"
    
    if download_file "$url" "$TMP_SCRIPT"; then
        if [ -s "$TMP_SCRIPT" ] && head -n 1 "$TMP_SCRIPT" | grep -q "^#!/bin/bash\|^#!/usr/bin/env bash"; then
            DOWNLOAD_SUCCESS=true
            echo "[+] Successfully downloaded from: $url"
            break
        fi
    fi
done

# Jika download gagal, buat installer dari built-in
if [ "$DOWNLOAD_SUCCESS" = false ]; then
    echo "[-] Failed to download from all sources."
    echo "[!] Creating built-in installer..."
    
    cat > "$TMP_SCRIPT" << 'EOFINSTALLER'
#!/bin/bash

# =============================================
#   ANONYMOUS INSTALLER - BUILT-IN VERSION
# =============================================

print_banner() {
    clear
    cat << 'EOF'
============================================
      Anonymous Installer (Built-in)
============================================
      _   _   _   _   _   _   _   _   _   
     / \ / \ / \ / \ / \ / \ / \ / \ / \  
    ( A | N | O | N | Y | M | O | U | S ) 
     \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/  
============================================
EOF
}

print_banner
echo "[+] Starting built-in installer..."
echo "[+] Installing essential packages..."

# Update dan install packages
pkg update -y && pkg upgrade -y
pkg install -y python golang nodejs curl git zsh binutils clang make cmake

# Setup Python environment
echo "[+] Setting up Python..."
python -m ensurepip
python -m pip install --upgrade pip
pip install aiohttp colorama fake_useragent requests urllib3

# Setup Node.js environment
echo "[+] Setting up Node.js..."
npm install -g net http2 tls cluster url crypto user-agents fs header-generator

# Setup Go environment
echo "[+] Setting up Go..."
mkdir -p ~/go/{bin,src,pkg}
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' >> ~/.bashrc
echo 'export GOROOT=/data/data/com.termux/files/usr' >> ~/.bashrc
source ~/.bashrc 2>/dev/null || true

# Setup Termux font
echo "[+] Setting up Termux font..."
mkdir -p ~/.termux
curl -fsSL -o ~/.termux/font.ttf "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf"

# Setup keyboard dengan exit, cd, ls
echo "[+] Setting up keyboard with exit, cd, ls..."
cat > ~/.termux/termux.properties << 'EOFKEYBOARD'
# Termux Configuration
font_size=14
use_system_font=false
fullscreen=true
bell-character=ignore
use_black_ui=true

# Extra Keyboard Keys with exit, cd, ls
extra-keys = [['ESC','exit','cd','ls','/','-','_'],['TAB','CTRL','ALT','HOME','UP','END','PGUP'],['LEFT','DOWN','RIGHT','PGDN','DEL','INS','CLR']]

# Keyboard Options
back-key=back
volume-keys=volume
enforce-char-based-input=true

# Terminal Emulation
bell-character=ignore
use-builtin-libicu=true
terminal-transcript-rows=2000

# Mouse Support
allow-external-apps=true
use-ipv6=true
EOFKEYBOARD

# Reload settings
termux-reload-settings 2>/dev/null || true

# Setup Oh My Zsh
echo "[+] Setting up Oh My Zsh..."
if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Setup Zsh plugins
if [ -d ~/.oh-my-zsh ]; then
    ZSH_CUSTOM=~/.oh-my-zsh/custom
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true
    sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc || true
    echo 'export PROMPT="%F{green}Anonymous%f %1~ %# "' >> ~/.zshrc
fi

# Install figlet dan lolcat
echo "[+] Installing figlet and lolcat..."
pkg install -y figlet toilet ncurses-utils
pip install lolcat

# Buat direktori projects
mkdir -p ~/projects

# Buat main tool
echo "[+] Creating main tool..."
cat > ~/projects/main.go << 'EOFGO'
package main

import (
    "bufio"
    "fmt"
    "os"
    "strings"
)

func main() {
    fmt.Println("=====================================")
    fmt.Println("  Anonymous Tool v1.0")
    fmt.Println("=====================================")
    fmt.Println()
    fmt.Println("Tips: Gunakan tombol exit, cd, ls di keyboard!")
    fmt.Println()
    
    reader := bufio.NewReader(os.Stdin)
    
    for {
        fmt.Print("anonymous> ")
        input, _ := reader.ReadString('\n')
        input = strings.TrimSpace(input)
        
        if input == "exit" || input == "quit" {
            fmt.Println("Goodbye!")
            break
        } else if input == "help" {
            fmt.Println("Available commands:")
            fmt.Println("  help  - Show this help")
            fmt.Println("  clear - Clear screen")
            fmt.Println("  exit  - Exit program")
            fmt.Println("  info  - Show system info")
            fmt.Println("  keys  - Show keyboard layout")
            fmt.Println("  ls    - List directory")
            fmt.Println("  cd    - Change directory")
        } else if input == "clear" {
            fmt.Print("\033[H\033[2J")
        } else if input == "info" {
            fmt.Println("Anonymous Tool v1.0")
            fmt.Println("Running on Termux")
        } else if input == "keys" {
            fmt.Println("Keyboard Layout:")
            fmt.Println("  Row 1: ESC, exit, cd, ls, /, -, _")
            fmt.Println("  Row 2: TAB, CTRL, ALT, HOME, UP, END, PGUP")
            fmt.Println("  Row 3: LEFT, DOWN, RIGHT, PGDN, DEL, INS, CLR")
        } else if input == "ls" {
            // List directory
            files, _ := os.ReadDir(".")
            for _, file := range files {
                if file.IsDir() {
                    fmt.Printf("📁 %s/\n", file.Name())
                } else {
                    fmt.Printf("📄 %s\n", file.Name())
                }
            }
        } else if strings.HasPrefix(input, "cd ") {
            // Change directory
            dir := strings.TrimPrefix(input, "cd ")
            err := os.Chdir(dir)
            if err != nil {
                fmt.Printf("Error: %s\n", err)
            } else {
                currentDir, _ := os.Getwd()
                fmt.Printf("Changed to: %s\n", currentDir)
            }
        } else if input != "" {
            fmt.Println("Command not found. Type 'help' for available commands.")
        }
    }
}
EOFGO

# Build main tool
echo "[+] Building main tool..."
cd ~/projects
go mod init anonymous-tool 2>/dev/null || true
go mod tidy 2>/dev/null || true
go build -o main main.go 2>/dev/null || {
    echo "[!] Go build failed, creating shell script instead..."
    cat > ~/projects/main << 'EOFSH'
#!/bin/bash
echo "====================================="
echo "  Anonymous Tool v1.0 (Shell)"
echo "====================================="
echo ""
echo "Tips: Gunakan tombol exit, cd, ls di keyboard!"
echo ""

while true; do
    echo -n "anonymous> "
    read cmd
    
    case $cmd in
        help)
            echo "Available commands:"
            echo "  help  - Show this help"
            echo "  clear - Clear screen"
            echo "  exit  - Exit program"
            echo "  info  - Show system info"
            echo "  keys  - Show keyboard layout"
            echo "  ls    - List directory"
            echo "  cd    - Change directory"
            ;;
        clear)
            clear
            ;;
        info)
            echo "Anonymous Tool v1.0"
            echo "Running on Termux"
            ;;
        keys)
            echo "Keyboard Layout:"
            echo "  Row 1: ESC, exit, cd, ls, /, -, _"
            echo "  Row 2: TAB, CTRL, ALT, HOME, UP, END, PGUP"
            echo "  Row 3: LEFT, DOWN, RIGHT, PGDN, DEL, INS, CLR"
            ;;
        ls)
            ls -la --color=auto
            ;;
        cd)
            cd ~
            echo "Changed to home directory"
            ;;
        cd\ *)
            dir="${cmd#cd }"
            cd "$dir" 2>/dev/null && echo "Changed to: $(pwd)" || echo "Directory not found"
            ;;
        exit|quit)
            echo "Goodbye!"
            break
            ;;
        *)
            [ -n "$cmd" ] && echo "Command not found. Type 'help' for available commands."
            ;;
    esac
done
EOFSH
    chmod +x ~/projects/main
}

# Buat shortcut
cat > ~/start.sh << 'EOFSTART'
#!/bin/bash
cd ~/projects && ./main
EOFSTART
chmod +x ~/start.sh

# Keyboard setup function
cat > ~/keyboard.sh << 'EOFKEYBOARD'
#!/bin/bash
# Keyboard layout changer for Termux
echo "========================================="
echo "  Termux Keyboard Layout Changer"
echo "========================================="
echo ""
echo "1) Default - Basic keys"
echo "2) Hacker - With special symbols"
echo "3) Coding - With brackets"
echo "4) Full - Complete layout"
echo "5) Minimal - Only essential"
echo "6) Command - With exit, cd, ls (RECOMMENDED)"
echo "7) Restore backup"
echo "========================================="
read -p "Pilih [1-7]: " choice

case $choice in
    1) LAYOUT="[['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]" ;;
    2) LAYOUT="[['ESC','|','/','-','_','+','='],['TAB','CTRL','ALT','{','}','[',']'],['HOME','UP','END','PGUP','LEFT','DOWN','RIGHT','PGDN']]" ;;
    3) LAYOUT="[['ESC','{','}','[',']',';',':'],['TAB','CTRL','ALT','<','>','|','\\'],['HOME','UP','END','PGUP','LEFT','DOWN','RIGHT','PGDN']]" ;;
    4) LAYOUT="[['ESC','/','-','HOME','UP','END','PGUP','DEL'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN','INS'],['F1','F2','F3','F4','F5','F6','F7','F8']]" ;;
    5) LAYOUT="[['ESC','TAB','CTRL','ALT'],['UP','DOWN','LEFT','RIGHT']]" ;;
    6) LAYOUT="[['ESC','exit','cd','ls','/','-','_'],['TAB','CTRL','ALT','HOME','UP','END','PGUP'],['LEFT','DOWN','RIGHT','PGDN','DEL','INS','CLR']]" ;;
    7) 
        if [ -f ~/.termux/termux.properties.bak ]; then
            cp ~/.termux/termux.properties.bak ~/.termux/termux.properties
            echo "[+] Backup restored"
        else
            echo "[-] No backup found"
        fi
        termux-reload-settings
        exit 0
        ;;
    *) echo "Invalid choice"; exit 1 ;;
esac

# Update keyboard
sed -i "s/extra-keys = .*/extra-keys = $LAYOUT/" ~/.termux/termux.properties
termux-reload-settings
echo "[+] Keyboard layout updated!"
echo "[+] New layout: $LAYOUT"
EOFKEYBOARD
chmod +x ~/keyboard.sh

echo ""
echo "============================================"
echo "[✓] Built-in installation complete!"
echo "============================================"
echo ""
echo "📝 Quick Start:"
echo "  • Main Tool: ~/start.sh"
echo "  • Change Keyboard: ~/keyboard.sh"
echo ""
echo "⌨️  Keyboard Layout (exit, cd, ls):"
echo "  Row 1: ESC, exit, cd, ls, /, -, _"
echo "  Row 2: TAB, CTRL, ALT, HOME, UP, END, PGUP"
echo "  Row 3: LEFT, DOWN, RIGHT, PGDN, DEL, INS, CLR"
echo ""
echo "[!] Anonymous Installer Ready!"
echo "============================================"
EOFINSTALLER

    chmod +x "$TMP_SCRIPT"
    echo "[+] Built-in installer created successfully."
fi

# ========== SETUP KEYBOARD ==========
if [ "$IS_TERMUX" = true ]; then
    echo ""
    read -p "[?] Do you want to setup custom keyboard now? (y/n): " SETUP_KEYBOARD
    if [[ "$SETUP_KEYBOARD" =~ ^[Yy]$ ]]; then
        setup_keyboard
    else
        echo "[!] Skipping keyboard setup. You can run ~/keyboard.sh later."
    fi
fi

# ========== RUN INSTALLER ==========
print_header "Running Installer"
echo "-------------------------------------"
bash "$TMP_SCRIPT"
INSTALLER_EXIT=$?
echo "-------------------------------------"

if [ $INSTALLER_EXIT -ne 0 ]; then
    echo "[-] Installer exited with code: $INSTALLER_EXIT"
fi

# ========== CLEANUP ==========
print_header "Cleaning Up"
rm -f "$TMP_SCRIPT" 2>/dev/null
echo "[+] Temporary files cleaned up."

# ========== FINAL MESSAGE ==========
print_banner
echo ""
echo "=================================================="
echo "[✓] Installation Complete!"
echo "=================================================="
echo ""
echo "📝 Quick Start:"
echo "  • Main Tool: ~/start.sh"
echo "  • Keyboard Setup: ~/keyboard.sh"
echo "  • Projects Directory: ~/projects/"
echo ""
echo "⌨️  Keyboard Layout (exit, cd, ls):"
echo "  Row 1: ESC, exit, cd, ls, /, -, _"
echo "  Row 2: TAB, CTRL, ALT, HOME, UP, END, PGUP"
echo "  Row 3: LEFT, DOWN, RIGHT, PGDN, DEL, INS, CLR"
echo ""
echo "💡 To activate Zsh, restart Termux or run:"
echo "   source ~/.zshrc"
echo ""
echo "[!] Anonymous Installer Ready!"
echo "=================================================="

if [ "$IS_TERMUX" = true ]; then
    echo "[!] Please restart Termux or run 'termux-reload-settings'"
fi

exit 0
