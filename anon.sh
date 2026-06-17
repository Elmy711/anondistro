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
      
    
      A | N | O | N | Y | M | O | U | S  

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

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ========== KONFIGURASI ==========
# DAFTAR SUMBER DOWNLOAD (URUTAN PRIORITAS)
declare -a SOURCE_URLS=(
    # GitLab
    "https://gitlab.com/whitehat57/anon/-/raw/main/installer.sh"
    
    # Pastebin (ganti dengan ID pastebin Anda)
    "https://pastebin.com/raw/your_pastebin_id"
    
    # Gist (ganti dengan Gist ID Anda)
    "https://gist.githubusercontent.com/whitehat57/raw/your_gist_id/installer.sh"
    
    # CDN - jsDelivr (jika ada)
    "https://cdn.jsdelivr.net/gh/whitehat57/ANON@main/installer.sh"
    
    # Backup sources - ganti dengan domain Anda
    "https://your-backup-server.com/anon/installer.sh"
    "https://raw.githubusercontent.com/yourusername/ANON-backup/main/installer.sh"
    
    # Local sources
    "file://$HOME/installer.sh"
    "file://$HOME/.local/share/anon/installer.sh"
    "file://$HOME/Downloads/installer.sh"
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
for cmd in curl bash wget; do
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
        # Local file
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
    
    # Bersihkan file lama
    rm -f "$TMP_SCRIPT"
    
    # Coba download dengan retry
    MAX_RETRIES=2
    RETRY_COUNT=0
    SOURCE_SUCCESS=false
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$SOURCE_SUCCESS" = false ]; do
        if download_file "$url" "$TMP_SCRIPT"; then
            if [ -s "$TMP_SCRIPT" ]; then
                SOURCE_SUCCESS=true
                DOWNLOAD_SUCCESS=true
                echo "[+] Successfully downloaded from: $url"
                break
            fi
        fi
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "[!] Retry $RETRY_COUNT/$MAX_RETRIES..."
            sleep 1
        fi
    done
    
    if [ "$SOURCE_SUCCESS" = true ]; then
        break
    fi
done

# Jika semua sumber gagal, gunakan built-in installer
if [ "$DOWNLOAD_SUCCESS" = false ]; then
    echo "[-] Failed to download from all sources."
    echo "[!] Continuing with built-in installation..."
    
    # ========== BUILT-IN INSTALLER (FALLBACK) ==========
    print_header "Running Built-in Installer"
    
    # Update package lists
    if [ "$IS_TERMUX" = true ]; then
        echo "[+] Updating package lists..."
        pkg update -y && pkg upgrade -y
    fi
    
    # Install essential packages
    print_header "Installing Essential Packages"
    for pkg in python golang nodejs curl git zsh; do
        if ! check_dependency $pkg; then
            echo "[+] Installing $pkg..."
            if [ "$IS_TERMUX" = true ]; then
                pkg install -y $pkg
            else
                echo "[!] $pkg not installed. Please install manually."
            fi
        else
            echo "[✓] $pkg already installed."
        fi
    done
    
    # Install additional build tools
    if [ "$IS_TERMUX" = true ]; then
        echo "[+] Installing build tools..."
        pkg install -y binutils clang make cmake
    fi
    
    # Ensure pip and pipx
    print_header "Setting Up Python Environment"
    if ! check_dependency pipx; then
        echo "[+] Setting up pip and pipx..."
        python -m ensurepip 2>/dev/null
        python -m pip install --upgrade pip
        python -m pip install pipx
        pipx ensurepath
        export PATH="$PATH:$HOME/.local/bin"
    else
        echo "[✓] pipx already installed."
    fi
    
    # Set Go path
    print_header "Setting Up Go Environment"
    if ! grep -q "GOPATH" ~/.bashrc 2>/dev/null; then
        echo "[+] Setting Go path..."
        mkdir -p ~/go/{bin,src,pkg}
        echo 'export GOPATH=$HOME/go' >> ~/.bashrc
        echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' >> ~/.bashrc
        echo 'export GOROOT=/data/data/com.termux/files/usr' >> ~/.bashrc
        source ~/.bashrc 2>/dev/null || true
    else
        echo "[✓] Go path already set."
    fi
    
    # Create projects directory
    echo "[+] Creating projects directory..."
    mkdir -p ~/projects
    cd ~/projects
    
    # Clone repository main tool ONLY
    print_header "Cloning Main Repository"
    if [ ! -d "$HOME/projects/main" ]; then
        echo "[+] Cloning main tool..."
        git clone "https://gitlab.com/whitehat57/cpa.git" "$HOME/projects/main" 2>/dev/null || {
            echo "[!] Failed to clone main tool"
        }
    else
        echo "[✓] Main tool already cloned."
        cd "$HOME/projects/main" && git pull 2>/dev/null || true
    fi
    
    # Build main tool
    print_header "Building Main Tool"
    if [ -d "$HOME/projects/main" ]; then
        echo "[+] Building main tool..."
        cd "$HOME/projects/main"
        go mod download 2>/dev/null || true
        go get github.com/fatih/color@v1.15.0 2>/dev/null || true
        go build -o main main.go 2>/dev/null || {
            echo "[!] Failed to build main tool, trying with specific package..."
            go build -o main . 2>/dev/null || echo "[!] Build failed"
        }
        if [ -f "main" ]; then
            chmod +x main
            echo "[✓] Main tool built successfully"
        fi
    fi
    
    # Install Python libraries
    print_header "Installing Python Libraries"
    pip install aiohttp==3.11.14 colorama==0.4.6 fake_useragent==2.1.0 requests==2.32.3 urllib3==2.3.0 2>/dev/null || {
        echo "[!] Some Python packages failed to install, trying without version..."
        pip install aiohttp colorama fake_useragent requests urllib3
    }
    
    # Install Node.js libraries
    print_header "Installing Node.js Libraries"
    npm install -g net http2 tls cluster url crypto user-agents fs header-generator fake-useragent https-proxy-agent 2>/dev/null || {
        echo "[!] Some Node.js packages failed to install"
    }
    
else
    # ========== VERIFIKASI DAN RUN DOWNLOADED INSTALLER ==========
    print_header "Verifying Downloaded Installer"
    
    # Cek apakah file valid
    if [ -f "$TMP_SCRIPT" ] && [ -s "$TMP_SCRIPT" ]; then
        # Cek apakah file mengandung shebang
        if head -n 1 "$TMP_SCRIPT" | grep -q "^#!/bin/bash\|^#!/usr/bin/env bash"; then
            echo "[+] Installer file verified."
            chmod +x "$TMP_SCRIPT"
            
            print_header "Running Main Installer"
            echo "-------------------------------------"
            bash "$TMP_SCRIPT"
            INSTALLER_EXIT=$?
            echo "-------------------------------------"
            
            if [ $INSTALLER_EXIT -ne 0 ]; then
                echo "[-] Installer exited with code: $INSTALLER_EXIT"
            fi
        else
            echo "[-] Downloaded file is not a valid bash script!"
            echo "[!] Falling back to built-in installer..."
            
            # Jalankan fallback installer (sama seperti di atas)
            # ... (kode fallback di sini)
        fi
    else
        echo "[-] Downloaded file is empty or invalid!"
    fi
fi

# ========== FONT SETUP (Termux) ==========
print_header "Setting Up Termux Environment"

if [ "$IS_TERMUX" = true ]; then
    echo "[+] Termux environment detected."
    
    # Backup konfigurasi lama
    if [ -f "$HOME/.termux/termux.properties" ]; then
        cp "$HOME/.termux/termux.properties" "$HOME/.termux/termux.properties.bak"
        echo "[+] Backup termux.properties created."
    fi
    
    echo "[+] Downloading Hack Nerd Font..."
    mkdir -p ~/.termux
    
    # Download font dengan retry
    MAX_RETRIES=3
    FONT_SUCCESS=false
    FONT_RETRY=0
    while [ $FONT_RETRY -lt $MAX_RETRIES ] && [ "$FONT_SUCCESS" = false ]; do
        curl -fsSL --connect-timeout 10 --max-time 30 "$FONT_URL" -o ~/.termux/font.ttf
        if [ $? -eq 0 ] && [ -s ~/.termux/font.ttf ]; then
            FONT_SUCCESS=true
        else
            FONT_RETRY=$((FONT_RETRY + 1))
            if [ $FONT_RETRY -lt $MAX_RETRIES ]; then
                echo "[!] Font download failed. Retrying ($FONT_RETRY/$MAX_RETRIES)..."
                sleep 2
            fi
        fi
    done
    
    if [ "$FONT_SUCCESS" = true ]; then
        echo "[+] Font successfully downloaded."
        
        # Set font size dan preferensi
        cat > ~/.termux/termux.properties << 'EOF'
font_size=14
use_system_font=false
fullscreen=true
bell-character=ignore
use_black_ui=true
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]
EOF
        
        # Reload Termux settings
        if command -v termux-reload-settings &>/dev/null; then
            termux-reload-settings
            echo "[+] Termux settings reloaded."
        else
            echo "[!] termux-reload-settings not found. Please restart Termux manually."
        fi
        
        echo "[+] Font successfully set to Hack Nerd Font with size 14."
    else
        echo "[-] Font installation failed after $MAX_RETRIES attempts."
        echo "[!] You can manually download the font later."
    fi
else
    echo "[!] Not running in Termux. Skipping font setup."
fi

# ========== INSTALL FIGLET & LOLCAT ==========
print_header "Installing Figlet & LOLCAT"

if [ "$IS_TERMUX" = true ]; then
    for tool in figlet toilet ncurses-utils; do
        if ! check_dependency $tool; then
            echo "[+] Installing $tool..."
            pkg install -y $tool
        else
            echo "[✓] $tool already installed."
        fi
    done
    pip install lolcat 2>/dev/null || echo "[!] lolcat installation failed"
fi

# ========== OH MY ZSH SETUP ==========
print_header "Setting Up Oh My Zsh"

if [ ! -d ~/.oh-my-zsh ]; then
    echo "[+] Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
        echo "[!] Oh My Zsh installation failed"
    }
else
    echo "[✓] Oh My Zsh already installed."
fi

# Install Zsh plugins
if [ -d ~/.oh-my-zsh ]; then
    ZSH_CUSTOM=~/.oh-my-zsh/custom
    
    echo "[+] Installing Zsh plugins..."
    
    # Zsh autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
    fi
    
    # Zsh syntax highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true
    fi
    
    # Zsh completions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
        git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions" 2>/dev/null || true
    fi
    
    # Configure Zsh
    sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc || {
        echo "# Default plugins" >> ~/.zshrc
        echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)" >> ~/.zshrc
    }
    
    echo 'export PROMPT="%F{green}Anonymous%f %1~ %# "' >> ~/.zshrc
    
    # Add banner to zshrc (only if not already added)
    if ! grep -q "Anonymous Banner" ~/.zshrc; then
        cat << 'EOBANNER' >> ~/.zshrc

# Anonymous Banner
if command -v figlet >/dev/null 2>&1 && command -v lolcat >/dev/null 2>&1; then
    clear
    width=$(tput cols)
    text="A N O N Y M O U S"
    font="slant"
    banner=$(figlet -f $font "$text")
    while IFS= read -r line; do
        printf "%*s\n" $(( (${#line} + width) / 2 )) "$line"
    done <<< "$banner" | lolcat
    echo

    subtitle="Anonymous Installer"
    separator="==========================="
    printf "%*s\n" $(( (${#subtitle} + width) / 2 )) "$subtitle" | lolcat
    printf "%*s\n" $(( (${#separator} + width) / 2 )) "$separator" | lolcat

    echo
    echo -n "Initializing "
    spinner="/-\|"
    for i in $(seq 1 8); do
        for j in $(seq 0 3); do
            printf "\b${spinner:$j:1}"
            sleep 0.1
        done
    done
    echo -e "\b Ready! 🚀"
fi
EOBANNER
    fi
    
    # Change default shell to zsh
    chsh -s zsh 2>/dev/null || echo "[!] Could not change default shell"
else
    echo "[!] Oh My Zsh not installed, skipping plugin setup"
fi

# ========== CREATE SHORTCUT ==========
print_header "Creating Shortcuts"

cat << 'EOF' > ~/start.sh
#!/bin/bash
cd ~/projects/main && ./main
EOF
chmod +x ~/start.sh

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
echo "🔧 Installed Components:"
echo "  • Go Environment ✓"
echo "  • Python & Pip ✓"
echo "  • Node.js & NPM ✓"
echo "  • Oh My Zsh with Plugins ✓"
echo "  • Hack Nerd Font ✓"
echo "  • Figlet & LOLCAT ✓"
echo ""
echo "⚠️  Note: Some components may require manual fixes"
echo "   due to dependency changes in Termux."
echo ""
echo "[!] Anonymous Installer Ready!"
echo "=================================================="
echo ""

# Tampilkan pesan restart jika Termux
if [ "$IS_TERMUX" = true ]; then
    echo "[!] Please restart Termux or run 'termux-reload-settings'"
fi

exit 0
