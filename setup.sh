#!/bin/bash

# ==========================================
# ULTIMATE GNOME SETUP SCRIPT V2.0
# Tác giả: Tran Nguyen Tien Dung
# ==========================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}[INFO] Bắt đầu quá trình tự động hóa toàn diện...${NC}"

# 1. Cài đặt các gói hệ thống và Python (Cần cho Extension Manager)
echo -e "${GREEN}[1/7] Cài đặt dependencies...${NC}"
# Tự động phát hiện Package Manager (hỗ trợ Debian/Ubuntu/Fedora/Arch)
if command -v apt &> /dev/null; then
    sudo apt update && sudo apt install -y zsh git curl python3-pip gnome-tweaks
elif command -v dnf &> /dev/null; then
    sudo dnf install -y zsh git curl python3-pip gnome-tweaks
elif command -v pacman &> /dev/null; then
    sudo pacman -S --noconfirm zsh git curl python-pip gnome-tweaks
fi

# 2. Cài đặt công cụ quản lý Extension qua dòng lệnh (CLI)
echo -e "${GREEN}[2/7] Cài đặt Gnome Extensions CLI...${NC}"
# Sử dụng pip để cài tool giúp cài extension không cần trình duyệt
pip3 install --user gnome-extensions-cli --break-system-packages
# Thêm đường dẫn pip vào PATH tạm thời để chạy lệnh ngay lập tức
export PATH="$HOME/.local/bin:$PATH"

# 3. Cài đặt Zsh & Oh-My-Zsh (Unattended - Không hỏi nhiều)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN}[3/7] Cài đặt Oh-My-Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 4. Cài đặt Powerlevel10k & Plugins
echo -e "${GREEN}[4/7] Cài đặt Theme Terminal & Plugins...${NC}"
# P10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k 2>/dev/null
# Plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null

# 5. Liên kết Dotfiles (Symlink)
echo -e "${GREEN}[5/7] Đồng bộ cấu hình (Symlinking)...${NC}"
rm -rf ~/.zshrc ~/.p10k.zsh
ln -sf $(pwd)/.zshrc ~/.zshrc
ln -sf $(pwd)/.p10k.zsh ~/.p10k.zsh

# Copy Themes/Icons (Dùng Copy thay vì Symlink để tránh lỗi quyền hạn với thư mục hệ thống)
mkdir -p ~/.themes ~/.icons
cp -r themes/* ~/.themes/ 2>/dev/null
cp -r icons/* ~/.icons/ 2>/dev/null

# 6. TỰ ĐỘNG CÀI ĐẶT EXTENSIONS (Phần quan trọng nhất)
echo -e "${GREEN}[6/7] Đang cài đặt GNOME Extensions từ file danh sách...${NC}"
if [ -f "extensions.txt" ]; then
    # Đọc file extensions.txt và cài từng cái
    while IFS= read -r ext_id; do
        if [ ! -z "$ext_id" ]; then
            echo -e "  -> Đang cài: $ext_id"
            # Lệnh này tự tải, tự cài và tự enable extension
            ~/.local/bin/gnome-extensions-cli install "$ext_id"
            ~/.local/bin/gnome-extensions-cli enable "$ext_id"
        fi
    done < extensions.txt
else
    echo -e "${RED}[WARNING] Không tìm thấy file extensions.txt! Bỏ qua bước này.${NC}"
fi

# 7. Nạp lại cấu hình Dconf (Settings)
# Phải làm bước này SAU khi cài Extensions để áp dụng settings cho chúng
echo -e "${GREEN}[7/7] Apply cấu hình GNOME Dconf...${NC}"
dconf load /org/gnome/ < gnome-settings.dconf

# Kết thúc
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}   CÀI ĐẶT HOÀN TẤT! (ZERO-TOUCH SUCCESS)      ${NC}"
echo -e "${GREEN}=================================================${NC}"
echo -e "Vui lòng:"
echo -e "1. Đổi Shell mặc định: chsh -s $(which zsh)"
echo -e "2. Log out và Log in lại để Extension hoạt động mượt mà."
