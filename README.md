# DockerEShard

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
