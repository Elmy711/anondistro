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

# ========== KONFIGURASI ==========
# DAFTAR SUMBER DOWNLOAD
declare -a SOURCE_URLS=(
    # Backup di GitLab
    "https://gitlab.com/whitehat57/anon/-/raw/main/installer.sh"
    
    # Backup di GitHub
    "https://raw.githubusercontent.com/whitehat57/anon-installer/main/installer.sh"
    
    # File hosting services
    "https://filebin.net/anon_installer/installer.sh"
    
    # Local file sources
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
    
    # Buat installer script langsung di sini (TANPA CLONING)
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
echo "font_size=14" > ~/.termux/termux.properties
echo "use_black_ui=true" >> ~/.termux/termux.properties

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

# Buat file main.go sederhana (tanpa cloning)
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
        } else if input == "clear" {
            fmt.Print("\033[H\033[2J")
        } else if input == "info" {
            fmt.Println("Anonymous Tool v1.0")
            fmt.Println("Running on Termux")
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
echo "Type 'help' for commands, 'exit' to quit"
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
            ;;
        clear)
            clear
            ;;
        info)
            echo "Anonymous Tool v1.0"
            echo "Running on Termux"
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

echo ""
echo "============================================"
echo "[✓] Built-in installation complete!"
echo "============================================"
echo ""
echo "📝 Quick Start:"
echo "  • Main Tool: ~/start.sh"
echo ""
echo "[!] Anonymous Installer Ready!"
echo "============================================"
EOFINSTALLER

    chmod +x "$TMP_SCRIPT"
    echo "[+] Built-in installer created successfully."
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
echo "  • Projects Directory: ~/projects/"
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
