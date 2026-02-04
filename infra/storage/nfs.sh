#!/usr/bin/env bash
set -euo pipefail

# Ensure main exports file exists (required by exportfs on Debian)
[ -f /etc/exports ] || touch /etc/exports

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

EXPORT_DIR="/home/elfenec/homelab/notebooks/page/access"
EXPORT_FILE="/etc/exports.d/fenics.exports"

echo -e "${YELLOW}🗄️  Setup NFS server (declarative)${NC}"

# 1. Install NFS server if missing
if ! dpkg -s nfs-kernel-server >/dev/null 2>&1; then
  echo -e "${YELLOW}📦 Installing nfs-kernel-server...${NC}"
  sudo apt update
  sudo apt install -y nfs-kernel-server
else
  echo -e "${GREEN}✅ nfs-kernel-server already installed${NC}"
fi

# 2. Ensure service is running
sudo systemctl enable nfs-kernel-server
sudo systemctl start nfs-kernel-server

# 3. Ensure export directory exists
if [ ! -d "$EXPORT_DIR" ]; then
  echo -e "${YELLOW}📁 Creating export directory${NC}"
  sudo mkdir -p "$EXPORT_DIR"
fi

sudo chown -R 1000:1000 "$EXPORT_DIR"
sudo chmod 755 "$EXPORT_DIR"

# 4. Ensure exports.d exists (Debian/RPi compatibility)
if [ ! -d /etc/exports.d ]; then
  echo -e "${YELLOW}📁 Creating /etc/exports.d${NC}"
  sudo mkdir -p /etc/exports.d
fi

# 5. Declare export (idempotent)
EXPORT_LINE="$EXPORT_DIR *(rw,sync,no_subtree_check,no_root_squash)"

if [ ! -f "$EXPORT_FILE" ] || ! grep -Fxq "$EXPORT_LINE" "$EXPORT_FILE"; then
  echo -e "${YELLOW}📜 Declaring NFS export${NC}"
  echo "$EXPORT_LINE" | sudo tee "$EXPORT_FILE" >/dev/null
else
  echo -e "${GREEN}✅ NFS export already declared${NC}"
fi

# 6. Sanity check
echo -e "${GREEN}📡 Active exports:${NC}"
sudo exportfs -v

echo -e "${GREEN}✅ NFS server ready${NC}"
