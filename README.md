# 📝 IT Support Technician - Technical Assessment

---

## 🧩 Part 1 – Short Knowledge Questions 

### 1. What’s the difference between a bind mount and a volume in Docker ?

- **Bind mount** : je monte directement un dossier/fichier de mon hôte (PC/VM) dans le conteneur.  
  ❌ Si ce chemin n’existe plus (changement d’ordi ou crash), ça casse.  

- **Volume** : c’est Docker qui crée et gère son propre espace de stockage (indépendant du chemin hôte).   

---

### 2. How do you configure a static IP address in Linux (Ubuntu) ?

- **Anciennes versions (fichier `/etc/network/interfaces`) :**

```bash
auto <interface>
iface <interface> inet static
    address <IP>
    netmask <Masque>
    gateway <Passerelle>
    dns-nameservers <DNS>
```
Ensuite redémarrer le service réseau via la commande suivante : `sudo systemctl restart networking`

- **Nouvelles versions (avec Netplan, par défaut sur Ubuntu modernes) :**

On vient d’abord lister les fichiers via la commande : `ls /etc/netplan/`
On a le résultat qui s’affiche et on va venir modifier le fichier en question via la commande : `sudo nano /etc/netplan/<nomdufichier.yaml>`

```bash
network:
  version: 2
  renderer: networkd
  ethernets:
    <interface>:
      dhcp4: no (pour avoir du coup notre ip en statique)
      addresses:
        - <IP/CIDR>
      routes:
        - to: default
          via: <Passerelle>
      nameservers:
        addresses:
	- <DNS>
	- <DNS> (différent de la première)
```
Après avoir configuré le fichier, on vient appliquer les modifications via la commande : `sudo netplan apply`
Et pour les deux configurations précédentes, on peut venir vérifier que les modifications ont bien été prise en compte via la commande : `ip a`

---

### 3. What does iptables -A INPUT -p tcp --dport 22 -j DROP do ?

Ajoute une règle à la chaîne INPUT pour rejeter (DROP) tout le trafic TCP entrant sur le port 22 (SSH).

---

### 4. What’s the use of /etc/resolv.conf ?

Ce fichier contient la configuration DNS du système (par ex. nameserver 8.8.8.8).
Il sert à traduire les noms de domaine (google.com) en adresses IP (8.8.8.8).

---

### 5. In Docker, what’s the difference between the --network=host and bridge modes ?

- Host network : le conteneur utilise directement la pile réseau de l’hôte (même IP), ce qui donne de meilleures performances mais moins d’isolation et plus de risques de conflits de ports.

- Bridge network : mode par défaut, Docker crée un réseau virtuel (docker0) et attribue une IP privée aux conteneurs (ex: 172.17.x.x). Les conteneurs communiquent entre eux via ce réseau, et l’extérieur y accède via des ports mappés (-p).

---

### 6. What are common ways to harden SSH access ?

- Désactiver l’accès root (PermitRootLogin no).
- Autoriser uniquement les clés publiques (PasswordAuthentication no).
- Restreindre les utilisateurs autorisés (AllowUsers).
- (Optionnel mais recommandé) : Mettre en place Fail2ban pour bloquer les IP en cas de brute-force ou utilisation d’un MFA.

---

### 7. You find a file with 777 permissions in a production container. What would you do ?

Ne jamais laisser un fichier en 777.
Corriger les droits au strict nécessaire :

- chmod 644 → lecture pour tous, écriture seulement pour le propriétaire.

- chmod 640 → lecture/écriture pour le propriétaire, lecture groupe, rien pour les autres.

Vérifier également le propriétaire :

```bash
chown user:group fichier
```

---

### 8. Describe what a reverse proxy does and name one example.

Un reverse proxy agit comme un point d’entrée unique qui reçoit les requêtes des clients via un nom de domaine et les redirige intelligemment vers les serveurs backend internes. 

Exemple : **Nginx**.

---

## 🛠️ Part 2 - Practical Challenge

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

---

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

---

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

---

### 🔐 Sécurité appliquée

- ✅ Conteneur exécuté en **utilisateur non-root** (`USER 1000`).  
- ✅ Suppression de toutes les **Linux capabilities** (`cap_drop: ALL`).  
- ✅ Protection `no-new-privileges:true`.  
- ✅ Persistance des logs via un **volume Docker**.  

---

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

---

### 📊 Monitoring

Script memory_check.sh → vérifie la mémoire toutes les 5 minutes via cron.

Logs dans /var/log/memory_alert.log.

Exemple :

	2025-09-18 12:20:01 - Memory usage check: 16%
	2025-09-18 12:25:01 - MEMORY ALERT - used 72% >= 70%

---

### ⚠️ Vulnérabilités volontaires

Admin Panel exposé : accessible sans authentification via /admin.

- ✅ Correction : ajouter une authentification ou restreindre par IP.


Fichier world-writable : vuln.txt monté avec permissions trop larges.

- ✅ Correction : restreindre les droits et éviter :rw non nécessaires.

---

## 🔍 Part 3 – Security Perspective Challenge

*Si on me demande d'auditer un service conteneurisé avec Docker qui n'a pas de limite de débit (rate limiting) et qui enregistre des mots de passe en clair sur le disque, je l'aborderais en trois étapes : évaluation, correction et questions de clarification.*

---

### 1. Ce que je vérifierais

- **Couche applicative** : vérifier si les mots de passe sont manipulés ou enregistrés en clair, et si un hachage sécurisé est utilisé (Argon2 par exemple).

- **Pratiques de journalisation** : vérifier si des informations sensibles (mots de passe, tokens) apparaissent dans les logs du conteneur ou dans les volumes montés, et si les fichiers de logs sont protégés par des permissions correctes.

- **Configuration Docker et infrastructure** : contrôler que le conteneur ne tourne pas en root, qu’il n’a pas de privilèges inutiles, et que seuls les ports nécessaires sont exposés (ex. HTTP, SSH).

---

### 2. Comment je le corrigerais

- **Mots de passe** :
 	- Arrêter immédiatement toute écriture de mots de passe en clair dans les journaux.
 	- Utiliser un hachage sécurisé pour stocker les mots de passe (Argon2).
    
- **Rate limiting** :
 	- Mettre en place une limitation des tentatives de connexion (par ex. via la configuration Nginx ou directement dans l’application).
 	- Ajouter un verrouillage ou un délai après plusieurs échecs de connexion.
    
- **Journalisation** :
 	- Nettoyer les journaux en supprimant les champs sensibles.
 	- Mettre en place une rotation des logs et limiter les droits d’accès (ex. chmod 640).
    
- **Sécurité Docker** :
 	- Lancer le conteneur avec un utilisateur non-root.
 	- Supprimer les capacités Linux non nécessaires.
 	- Si possible, mettre le système de fichiers du conteneur en lecture seule.

---

### 3. Questions que je poserais

- **Portée** : est-ce que ce service est exposé au public ou réservé à un usage interne ?

- **Conformité** : l’entreprise est-elle soumise à des réglementations (RGPD, PCI, etc.) qui interdisent le stockage de mots de passe en clair ?

- **Logs** : qui a accès aux journaux et sont-ils envoyés vers une solution centralisée (type ELK *(Elasticsearch,Logstash et Kibana)*) ?

- **Authentification** : est-il prévu d’intégrer un système d’authentification centralisé (SSO) pour éviter de gérer directement les identifiants ?

- **Exploitation** : un temps d’arrêt est-il acceptable lors de la mise en place de ces correctifs ?

---

### 🧑‍💻 Auteur

Projet réalisé par Cyril Baudé

🐙 GitHub : @cyrilbaude333

📧 : cyril6840@hotmail.fr
