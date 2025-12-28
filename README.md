Markdown

# 🚀 Elfenec Dotfiles : Le Cockpit DevOps Nomade

Ce dépôt contient ma configuration système **Stateless** et **Agnostique**. L'objectif est de transformer n'importe quelle machine (Linux ou macOS) en une station de travail Kubernetes complète en moins de 2 minutes.

## 🧠 Philosophie du Projet

## 🧠 Philosophie du Projet

- **Stateless & Nomade** : Aucune dépendance locale. Mon environnement me suit partout.
- **Idempotent** : Le script `install.sh` peut être exécuté plusieurs fois sans risque. Il vérifie l'existence des composants (Nix, Devbox, Oh My Zsh) avant d'agir et répare les conflits de configuration.
- **Immuable** : L'OS reste propre. Aucun outil n'est installé via `apt`. Tout passe par **Nix** et **Devbox**.
- **Agnostique** : Fonctionne indépendamment de la distribution Linux ou de l'architecture (x86/ARM).

---

## 📦 L'Arsenal (Le contenu)

| Fichier | Rôle |
| :--- | :--- |
| **`devbox.json`** | **L'Arsenal** : Gestionnaire de paquets (k9s, kubectl, helm, argocd, mc, sops, skopeo, kubecolor, kubectx, task, iftop, btop, tree, etc.). |
| **`.zshrc`** | **L'Intelligence** : Mes alias (`k`, `ns`, `ctx`), la gestion des plugins et l'auto-chargement de l'environnement Devbox. |
| **`.p10k.zsh`** | **Le Cockpit** : Design du terminal avec monitoring en temps réel du contexte Kubernetes, de la branche Git et de la charge système. |
| **`install.sh`** | **Le Déploiement** : Script d'automatisation qui prépare Nix, installe Devbox, configure Oh My Zsh et déploie les fichiers. |

---

## ⚡ Installation Rapide

Pour déployer cet environnement sur une nouvelle machine, exécutez simplement :

```bash
git clone [https://github.com/TON_USER/dotfiles.git](https://github.com/TON_USER/dotfiles.git) && cd dotfiles && bash install.sh
```

Une fois terminé, redémarrez votre shell :
```bash
zsh
```

(si modif. faite un git pull puis un bash install.sh ou ./installsh directement)

🛠️ Utilisation au quotidien
Mise à jour des outils : Modifiez devbox.json et lancez devbox update.

Changement de contexte K8s : Utilisez l'alias ctx pour changer de cluster ou ns pour changer de namespace.

Monitoring : Tapez top (btop) ou network (iftop) pour surveiller la machine et k9s pour kubernetes

Synchronisation : git pull pour récupérer vos dernières optimisations d'alias ou d'outils.

Fait par Elfenec pour un monde plus Stateless.

Crédibilité : Si quelqu'un tombe sur ton repo, il comprend tout de suite que tu maîtrises les concepts modernes (Nix, Stateless).

Mémoire : Tu n'auras plus jamais à chercher la commande d'installation.

Évolutivité : Tu peux maintenant ajouter une section "Secrets" si tu décides un jour d'utiliser chezmoi ou un gestionnaire de mots de passe.
