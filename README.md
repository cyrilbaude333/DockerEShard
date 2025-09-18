# 📦 DockerEShard — Secure Test Environment

## Docker Secure Test Environment

### 📌 Description
Ce projet met en place un environnement de test Dockerisé avec :
- Un service web Nginx exposé sur le port **8080**.
- Des règles de sécurité de base (utilisateur non-root, capacités limitées, firewall restreint).
- Un monitoring simple de l’utilisation mémoire via un **cron job**.
- Une vulnérabilité volontaire pour simulation (un **admin panel exposé** + un **fichier world-writable**).

---

### 🚀 Déploiement

#### Prérequis
- Linux (Ubuntu conseillé).
- Docker et Docker Compose installés :
  ```bash
  sudo apt-get update
  sudo apt upgrade
  
  mkdir ~/assessment
  cd ~/assessment
  
  sudo apt-get install ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  sudo usermod -aG docker $USER
  newgrp docker

  sudo systemctl start docker
  sudo systemctl status docker #Vérification du bon fonctionnement de notre Docker

  # !! Lors du premier lancement Docker compose on peut retrouver une erreur lié à python pour corriger voici les étapes à suivres :
  sudo apt install python3-pip
  sudo apt install python3-setuptools

### 📂 Arborescence du projet

	'''pgsql

	DockerEShard/
	├── docker-compose.yml
	├── Dockerfile
	├── nginx/
	│   ├── nginx.conf
	│   ├── default.conf
	│   └── html/
	│       ├── index.html
	│       └── admin/index.html
	├── memory_check.sh
	└── README.md

### ▶️ Lancer le service

  '''bash
  git clone https://github.com/cyrilbaude333/DockerEShard.git
  cd DockerEShard

  docker compose build
  docker compose up -d

Le service est disponible sur :

🌍 http://localhost:8080
 → page principale

⚠️ http://localhost:8080/admin
 → vulnérabilité volontaire

### 🔐 Sécurité appliquée

✅ Conteneur exécuté en utilisateur non-root (USER 1000).

✅ Suppression de toutes les Linux capabilities (cap_drop: ALL).

✅ Protection no-new-privileges:true.

✅ Firewall UFW → autorise uniquement :
SSH (22/tcp)
HTTP (8080/tcp)
DNS (53/tcp, 53/udp)

✅ Persistance des logs via un volume Docker.

### 📊 Monitoring

Script memory_check.sh → vérifie la mémoire toutes les 5 minutes via cron.

Logs dans /var/log/memory_alert.log.

Exemple :
  '''yaml
  2025-09-18 12:20:01 - Memory usage check: 16%
  2025-09-18 12:25:01 - MEMORY ALERT - used 72% >= 70%

### ⚠️ Vulnérabilités volontaires

Admin Panel exposé : accessible sans authentification via /admin.
✅ Correction : ajouter une authentification ou restreindre par IP.

Fichier world-writable : vuln.txt monté avec permissions trop larges.
✅ Correction : restreindre les droits et éviter :rw non nécessaires.

### 🧑‍💻 Auteur

Projet réalisé par Cyril Baudé
GitHub : @cyrilbaude333
