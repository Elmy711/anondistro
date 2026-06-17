#!/bin/bash

# ======================================================
#         ANONYMOUS UNINSTALLER v2026
#        Complete Removal Script
# ======================================================

# ========== FUNGSI UTILITY ==========
print_banner() {
    clear
    cat << 'EOF'
==================================================
    ( U | N | I | N | S | T | A | L | L ) 
==================================================
EOF
}

print_header() {
    echo ""
    echo "=================================================="
    echo "  $1"
    echo "=================================================="
}

print_warning() {
    echo ""
    echo "⚠️  $1"
    echo ""
}

confirm_action() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        read -p "$prompt [Y/n]: " response
        response=${response:-y}
    else
        read -p "$prompt [y/N]: " response
        response=${response:-n}
    fi
    
    case $response in
        [Yy]* ) return 0 ;;
        * ) return 1 ;;
    esac
}

# ========== MULAI UNINSTALLER ==========
print_banner

echo "[!] WARNING: This script will remove all Anonymous Installer components!"
echo "[!] This includes:"
echo "    - All projects in ~/projects"
echo "    - Main tool binary and source"
echo "    - Termux font and keyboard settings"
echo "    - Oh My Zsh and plugins"
echo "    - Python and Node.js packages"
echo "    - All shortcuts and scripts"
echo ""

if ! confirm_action "Are you sure you want to continue?" "n"; then
    echo "[+] Uninstall cancelled."
    exit 0
fi

# ========== CEK ENVIRONMENT ==========
print_header "Environment Check"

if [ -d "/data/data/com.termux" ] || [ -d "$HOME/.termux" ]; then
    echo "[+] Termux environment detected."
    IS_TERMUX=true
else
    echo "[!] Not running in Termux."
    IS_TERMUX=false
fi

# ========== REMOVE PROJECTS ==========
print_header "Removing Projects"

if [ -d "$HOME/projects" ]; then
    echo "[+] Removing projects directory..."
    rm -rf "$HOME/projects"
    echo "[✓] Projects directory removed."
else
    echo "[!] Projects directory not found."
fi

# ========== REMOVE MAIN TOOL ==========
print_header "Removing Main Tool"

# Hapus binary
if [ -f "$HOME/start.sh" ]; then
    rm -f "$HOME/start.sh"
    echo "[✓] start.sh removed."
fi

if [ -f "$HOME/main" ]; then
    rm -f "$HOME/main"
    echo "[✓] main binary removed."
fi

# Hapus file sementara
if [ -f "$HOME/.anon_installer.sh" ]; then
    rm -f "$HOME/.anon_installer.sh"
    echo "[✓] Temporary installer removed."
fi

if [ -f "$HOME/.anon_install.log" ]; then
    rm -f "$HOME/.anon_install.log"
    echo "[✓] Log file removed."
fi

# ========== REMOVE KEYBOARD SETTINGS ==========
print_header "Removing Keyboard Settings"

if [ -f "$HOME/.termux/termux.properties" ]; then
    # Backup existing keyboard settings
    if [ -f "$HOME/.termux/termux.properties.bak" ]; then
        echo "[+] Restoring keyboard backup..."
        cp "$HOME/.termux/termux.properties.bak" "$HOME/.termux/termux.properties"
        rm -f "$HOME/.termux/termux.properties.bak"
        echo "[✓] Keyboard settings restored from backup."
    else
        # Hapus konfigurasi keyboard
        echo "[+] Removing keyboard settings..."
        rm -f "$HOME/.termux/termux.properties"
        echo "[✓] Keyboard settings removed."
    fi
fi

# ========== REMOVE FONT ==========
print_header "Removing Termux Font"

if [ -f "$HOME/.termux/font.ttf" ]; then
    rm -f "$HOME/.termux/font.ttf"
    echo "[✓] Font file removed."
else
    echo "[!] Font file not found."
fi

# ========== REMOVE OH MY ZSH ==========
print_header "Removing Oh My Zsh"

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "[+] Removing Oh My Zsh..."
    rm -rf "$HOME/.oh-my-zsh"
    echo "[✓] Oh My Zsh removed."
else
    echo "[!] Oh My Zsh not found."
fi

# ========== REMOVE ZSH PLUGINS ==========
print_header "Removing Zsh Plugins"

# Hapus Zsh plugins
if [ -d "$HOME/.zsh" ]; then
    rm -rf "$HOME/.zsh"
    echo "[✓] Zsh plugins removed."
fi

# Hapus custom plugins
if [ -d "$HOME/.oh-my-zsh/custom/plugins" ]; then
    rm -rf "$HOME/.oh-my-zsh/custom/plugins"
    echo "[✓] Custom plugins removed."
fi

# ========== RESTORE BASHRC / ZSHRC ==========
print_header "Restoring Shell Configurations"

# Restore .bashrc
if [ -f "$HOME/.bashrc" ]; then
    # Buat backup sebelum restore
    cp "$HOME/.bashrc" "$HOME/.bashrc.anon_backup"
    
    # Hapus baris yang ditambahkan oleh installer
    sed -i '/GOPATH/d' "$HOME/.bashrc"
    sed -i '/GOROOT/d' "$HOME/.bashrc"
    sed -i '/Anonymous/d' "$HOME/.bashrc"
    sed -i '/go\/bin/d' "$HOME/.bashrc"
    
    echo "[✓] .bashrc cleaned."
fi

# Restore .zshrc
if [ -f "$HOME/.zshrc" ]; then
    # Buat backup sebelum restore
    cp "$HOME/.zshrc" "$HOME/.zshrc.anon_backup"
    
    # Hapus baris yang ditambahkan oleh installer
    sed -i '/GOPATH/d' "$HOME/.zshrc"
    sed -i '/GOROOT/d' "$HOME/.zshrc"
    sed -i '/Anonymous/d' "$HOME/.zshrc"
    sed -i '/go\/bin/d' "$HOME/.zshrc"
    sed -i '/zsh-autosuggestions/d' "$HOME/.zshrc"
    sed -i '/zsh-syntax-highlighting/d' "$HOME/.zshrc"
    sed -i '/Anonymous Banner/,/EOF/d' "$HOME/.zshrc"
    
    echo "[✓] .zshrc cleaned."
fi

# ========== UNINSTALL PACKAGES ==========
print_header "Uninstalling Optional Packages"

echo ""
echo "Do you want to uninstall packages installed by this script?"
echo "This will remove: python, golang, nodejs, git, zsh, etc."
echo ""

if confirm_action "Uninstall packages?" "n"; then
    if [ "$IS_TERMUX" = true ]; then
        echo "[+] Uninstalling packages..."
        pkg uninstall -y python golang nodejs git zsh binutils clang make cmake figlet toilet ncurses-utils 2>/dev/null
        echo "[✓] Packages uninstalled."
    else
        echo "[!] Not in Termux. Please uninstall packages manually."
    fi
else
    echo "[!] Skipping package uninstallation."
fi

# ========== UNINSTALL PYTHON PACKAGES ==========
print_header "Uninstalling Python Packages"

echo ""
if confirm_action "Uninstall Python packages?" "n"; then
    echo "[+] Uninstalling Python packages..."
    pip uninstall -y aiohttp colorama fake_useragent requests urllib3 lolcat 2>/dev/null
    echo "[✓] Python packages uninstalled."
else
    echo "[!] Skipping Python packages uninstallation."
fi

# ========== UNINSTALL NODE PACKAGES ==========
print_header "Uninstalling Node.js Packages"

echo ""
if confirm_action "Uninstall Node.js packages?" "n"; then
    echo "[+] Uninstalling Node.js packages..."
    npm uninstall -g net http2 tls cluster url crypto user-agents fs header-generator 2>/dev/null
    echo "[✓] Node.js packages uninstalled."
else
    echo "[!] Skipping Node.js packages uninstallation."
fi

# ========== REMOVE GO ENVIRONMENT ==========
print_header "Removing Go Environment"

if [ -d "$HOME/go" ]; then
    echo ""
    if confirm_action "Remove Go directory (~/go)?" "n"; then
        rm -rf "$HOME/go"
        echo "[✓] Go directory removed."
    else
        echo "[!] Skipping Go directory removal."
    fi
fi

# ========== REMOVE SCRIPTS ==========
print_header "Removing Scripts"

SCRIPTS=("$HOME/keyboard.sh" "$HOME/start.sh" "$HOME/installer.sh")
for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        rm -f "$script"
        echo "[✓] $(basename $script) removed."
    fi
done

# ========== RELOAD TERMUX ==========
print_header "Reloading Termux"

if [ "$IS_TERMUX" = true ]; then
    if command -v termux-reload-settings &>/dev/null; then
        termux-reload-settings
        echo "[✓] Termux settings reloaded."
    fi
fi

# ========== FINAL CLEANUP ==========
print_header "Final Cleanup"

# Hapus file backup yang dibuat oleh script
if [ -f "$HOME/.bashrc.anon_backup" ]; then
    rm -f "$HOME/.bashrc.anon_backup"
fi

if [ -f "$HOME/.zshrc.anon_backup" ]; then
    rm -f "$HOME/.zshrc.anon_backup"
fi

echo "[✓] Temporary files cleaned up."

# ========== SUMMARY ==========
print_banner
echo ""
echo "=================================================="
echo "[✓] Uninstall Complete!"
echo "=================================================="
echo ""
echo "✅ Removed:"
echo "  • All projects in ~/projects"
echo "  • Main tool and shortcuts"
echo "  • Termux font settings"
echo "  • Keyboard settings (restored backup if available)"
echo "  • Oh My Zsh and plugins"
echo "  • Shell configurations (cleaned)"
echo "  • Installed packages (if selected)"
echo "  • Python packages (if selected)"
echo "  • Node.js packages (if selected)"
echo ""
echo "📁 Remaining items (not removed):"
echo "  • ~/.termux (if you have other settings)"
echo "  • ~/.oh-my-zsh (if selected to keep)"
echo "  • ~/go (if selected to keep)"
echo "  • Installed packages (if selected to keep)"
echo ""
echo "⚠️  Note: Some files may remain if you chose to keep them."
echo "    You can remove them manually if needed."
echo ""
echo "💡 To restore shell, restart Termux or run:"
echo "   source ~/.bashrc"
echo "   source ~/.zshrc"
echo ""
echo "=================================================="
echo ""

exit 0
