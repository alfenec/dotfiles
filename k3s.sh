#!/bin/bash

# --- Couleurs pour la visibilité ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🛠️ Préparation de l'infrastructure K3s & Helm...${NC}"

# 1. Activation des CGROUPS (Indispensable sur Raspberry Pi)
CMDLINE="/boot/firmware/cmdline.txt"
[ ! -f "$CMDLINE" ] && CMDLINE="/boot/cmdline.txt"

if ! grep -q "cgroup_enable=cpuset" "$CMDLINE"; then
    echo -e "${YELLOW}📝 Activation des cgroups dans $CMDLINE...${NC}"
    sudo sed -i '$ s/$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory/' "$CMDLINE"
    echo -e "${GREEN}✅ Configuration terminée. Redémarrage nécessaire !${NC}"
    echo "Le script s'arrêtera ici. Relance-le après le reboot."
    sudo reboot
    exit 0
fi

# 2. Installation de K3s (Le Moteur)
if ! command -v k3s &> /dev/null; then
    echo -e "${YELLOW}🚀 Installation de K3s...${NC}"
    curl -sfL https://get.k3s.io | sh -s - \
      --disable traefik \
      --disable servicelb \
      --write-kubeconfig-mode 644 \
      --node-taint CriticalAddonsOnly=true:NoExecute
    echo -e "${GREEN}✅ K3s installé.${NC}"
else
    echo -e "${GREEN}✅ K3s est déjà présent.${NC}"
fi

# 3. Désactivation du Swap (Kubernetes recommande Swap: 0B)
echo -e "${YELLOW}🛑 Désactivation du swap...${NC}"
sudo dphys-swapfile swapoff
sudo dphys-swapfile swappartitions
sudo systemctl disable dphys-swapfile
# On vérifie si c'est bien à 0
FREE_SWAP=$(free | grep Swap | awk '{print $2}')
if [ "$FREE_SWAP" -eq "0" ]; then
    echo -e "${GREEN}✅ Swap désactivé (0B).${NC}"
else
    echo -e "${YELLOW}⚠️ Le swap n'est pas totalement à 0. Pense à vérifier.${NC}"
fi

# 4. Liaison de la configuration pour l'utilisateur courant
echo -e "${YELLOW}🔗 Liaison du Kubeconfig pour $(whoami)...${NC}"
mkdir -p "$HOME/.kube"
sudo cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
sudo chown $(whoami):$(whoami) "$HOME/.kube/config"
chmod 600 "$HOME/.kube/config"

echo -e "${GREEN}🏁 Infrastructure cluster prête !${NC}"
