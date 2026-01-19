✅ Installation K3s Worker (qui a fonctionné)

ansible-playbook -i hosts.ini setup-k3s-worker.yml --ask-pass --ask-become-pass

SSH password: → ***

BECOME password: → mot de passe sudo elfenec


# Sur le worker
sudo rm -f /var/lib/rancher/k3s/agent/etc/containerd/config.toml
sudo systemctl restart k3s-agent
