📦 DockerEShard — Secure Test Environment
📌 Description

Ce projet met en place un environnement de test sécurisé basé sur Docker.
Il déploie un service web simple (Nginx) avec des mécanismes de sécurité, un monitoring basique et une vulnérabilité volontaire pour l’apprentissage.

Objectifs :

Démontrer la mise en place d’un service web conteneurisé.

Appliquer des bonnes pratiques de sécurité sur Docker et l’hôte.

Configurer un monitoring simple des ressources.

Simuler des vulnérabilités pour entraînement à l’audit.

🚀 Déploiement
🔧 Prérequis

Système : Linux Ubuntu (VM ou serveur).

Docker + Docker Compose.

📥 Installation de Docker
sudo apt-get update
sudo apt upgrade -y

# Installer les dépendances
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Ajouter la clé GPG officielle Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Ajouter le dépôt Docker officiel
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installer Docker et plugins
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Ajouter l’utilisateur courant au groupe docker
sudo usermod -aG docker $USER
newgrp docker

# Vérification
sudo systemctl start docker
sudo systemctl status docker


⚠️ Si vous rencontrez des erreurs liées à Python avec Docker Compose :

sudo apt install -y python3-pip python3-setuptools

📂 Arborescence du projet
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

▶️ Lancer le service
git clone https://github.com/cyrilbaude333/DockerEShard.git
cd DockerEShard

docker compose build
docker compose up -d


Le service est disponible sur :

🌍 http://localhost:8080
 (page principale)

⚠️ http://localhost:8080/admin
 (vulnérabilité volontaire)

🔐 Sécurité appliquée

✅ Conteneur exécuté en utilisateur non-root (USER 1000).

✅ Suppression de toutes les Linux capabilities (cap_drop: ALL).

✅ Protection no-new-privileges:true activée.

✅ Firewall UFW configuré pour autoriser uniquement :

SSH (22/tcp)

HTTP (8080/tcp)

DNS (53/tcp, 53/udp)

✅ Persistance des logs avec un volume Docker.

📊 Monitoring

Script memory_check.sh vérifie la mémoire toutes les 5 minutes (cron).

Les alertes sont stockées dans /var/log/memory_alert.log.

Exemple :

2025-09-18 12:20:01 - Memory usage check: 16%
2025-09-18 12:25:01 - MEMORY ALERT - used 72% >= 70%

⚠️ Vulnérabilités volontaires

Admin Panel exposé : accessible sans authentification via /admin.

Correction possible : mettre une authentification basique ou restreindre par IP.

Fichier world-writable :

vuln.txt monté avec permissions trop larges.

Correction possible : restreindre les droits et éviter :rw non nécessaires.

🧑‍💻 Auteur

Projet réalisé par Cyril Baudé (@cyrilbaude333
)
