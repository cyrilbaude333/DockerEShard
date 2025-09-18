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
- Linux (Ubuntu).
- Docker et Docker Compose installation :

```bash
# Mettre à jour la liste des paquets
sudo apt-get update

# Mettre à jour les paquets déjà installés
sudo apt upgrade -y

# Créer le dossier de travail pour le projet
mkdir ~/assessment
cd ~/assessment

# Installer les dépendances nécessaires
sudo apt-get install -y ca-certificates curl gnupg

# Créer le dossier pour stocker la clé GPG de Docker
sudo install -m 0755 -d /etc/apt/keyrings

# Télécharger et ajouter la clé GPG officielle de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Donner les bons droits à la clé
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Ajouter le dépôt officiel Docker dans les sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Rafraîchir la liste des paquets (incluant Docker)
sudo apt-get update

# Installer Docker et ses plugins (Docker CLI, Compose, etc.)
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Ajouter ton utilisateur au groupe Docker (évite d’utiliser sudo à chaque commande)
sudo usermod -aG docker $USER

# Recharger la session pour appliquer l’ajout au groupe
newgrp docker

# Démarrer Docker
sudo systemctl start docker

# Vérifier que Docker tourne correctement
sudo systemctl status docker

# (Optionnel) Si problème avec Docker Compose → installer Python et Setuptools
sudo apt install -y python3-pip
sudo apt install -y python3-setuptools
```

### 📂 Arborescence du projet

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

```bash
# Cloner le dépôt GitHub contenant le projet
git clone https://github.com/cyrilbaude333/DockerEShard.git

# Entrer dans le dossier du projet
cd DockerEShard

# Construire l’image Docker
docker compose build

# Lancer les conteneurs en arrière-plan
docker compose up -d
```

Le service est disponible sur :

🌍 http://localhost:8080
 → page principale

⚠️ http://localhost:8080/admin
 → vulnérabilité volontaire

### 🔐 Sécurité appliquée

- ✅ Conteneur exécuté en **utilisateur non-root** (`USER 1000`).  
- ✅ Suppression de toutes les **Linux capabilities** (`cap_drop: ALL`).  
- ✅ Protection `no-new-privileges:true`.  
- ✅ Persistance des logs via un **volume Docker**.  

### 🔥 Configuration du pare-feu (UFW)

Pour sécuriser l’hôte Linux, j’ai utilisé **UFW** (Uncomplicated Firewall).  
Objectif : autoriser uniquement les services nécessaires (SSH, HTTP sur 8080, DNS, HTTP/HTTPS sortants), et bloquer tout le reste.

```bash
# Réinitialiser le pare-feu
sudo ufw --force reset

# Bloquer tout le trafic entrant par défaut
sudo ufw default deny incoming

# Autoriser SSH (port 22)
sudo ufw allow 22/tcp

# Autoriser HTTP sur port 8080 (notre service Docker)
sudo ufw allow 8080/tcp

# Bloquer tout le trafic sortant par défaut
sudo ufw default deny outgoing

# Autoriser DNS sortant (TCP et UDP, port 53)
sudo ufw allow out 53/tcp
sudo ufw allow out 53/udp

# Autoriser HTTP/HTTPS sortants (ports 80 et 443)
sudo ufw allow out 80/tcp
sudo ufw allow out 443/tcp

# Activer UFW
sudo ufw enable

# Vérifier les règles
sudo ufw status verbose

```

### 📊 Monitoring

Script memory_check.sh → vérifie la mémoire toutes les 5 minutes via cron.

Logs dans /var/log/memory_alert.log.

Exemple :

	2025-09-18 12:20:01 - Memory usage check: 16%
	2025-09-18 12:25:01 - MEMORY ALERT - used 72% >= 70%

### ⚠️ Vulnérabilités volontaires

Admin Panel exposé : accessible sans authentification via /admin.

- ✅ Correction : ajouter une authentification ou restreindre par IP.


Fichier world-writable : vuln.txt monté avec permissions trop larges.

- ✅ Correction : restreindre les droits et éviter :rw non nécessaires.

### 🧑‍💻 Auteur

Projet réalisé par Cyril Baudé
GitHub : @cyrilbaude333
