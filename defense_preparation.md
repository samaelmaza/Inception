# 🛡️ Préparation à la Soutenance Inception

Ce document regroupe **toutes** les questions de la grille d'évaluation officielle et te donne les réponses exactes pour que tu puisses valider ton projet haut la main !

## 1. Questions Théoriques (Le plus important)

### ❓ "Comment fonctionnent Docker et Docker Compose ?"
- **Docker** : C'est un outil qui permet d'isoler des applications dans des "conteneurs". Chaque conteneur embarque uniquement les dépendances nécessaires à l'application. Contrairement à une VM, Docker ne virtualise pas de système d'exploitation, il communique directement avec le noyau (Kernel) de la machine hôte.
- **Docker Compose** : C'est un orchestrateur. Il permet de gérer des infrastructures multi-conteneurs. Au lieu de taper 15 lignes de commande `docker run` à la main pour lier les conteneurs entre eux, Docker Compose lit un fichier `docker-compose.yml` et s'occupe de créer les réseaux, les volumes et de lancer les conteneurs dans le bon ordre en une seule commande (`up -d`).

### ❓ "Quelle est la différence entre une image Docker utilisée avec ou sans Docker Compose ?"
- **Fondamentalement : Aucune.** Une image Docker reste la même.
- **En pratique** : Lancer une image "sans compose" (via `docker run`) nécessite de préciser manuellement toutes les variables d'environnement, les ports, et les réseaux dans la ligne de commande. Avec Docker Compose, l'image s'intègre automatiquement dans un écosystème préconfiguré (elle rejoint le réseau local `inception`, accède aux `secrets`, et monte les bons volumes).

### ❓ "Quel est l'avantage de Docker par rapport aux VMs ?"
- **Légèreté et Rapidité** : Une VM (Machine Virtuelle) doit démarrer un OS entier (Windows, Ubuntu...), ce qui prend des gigaoctets de RAM et plusieurs minutes à démarrer. Un conteneur Docker ne démarre que le processus de l'application (ex: NGINX), ce qui prend quelques mégaoctets et démarre en quelques millisecondes.
- **Partage du Kernel** : Docker utilise les ressources du Kernel Linux de la machine hôte directement, sans couche d'émulation matérielle.

### ❓ "Pourquoi cette arborescence de fichiers ?"
- C'est la base de la modularité DevOps. On sépare `srcs` (le code source de l'infrastructure) de la racine (où se trouve le `Makefile` et potentiellement les données). Dans `srcs/requirements/`, chaque dossier (mariadb, nginx, wordpress) est **totalement indépendant** et contient son propre `Dockerfile`, sa configuration (`conf/`), et ses scripts d'initialisation (`tools/`). Ça permet de réutiliser ces blocs Lego sur d'autres projets sans tout mélanger.

### ❓ "Explique-moi ce qu'est un Docker Network"
- C'est un réseau virtuel isolé créé par Docker (de type `bridge`). Il permet aux conteneurs du projet Inception de communiquer entre eux de manière sécurisée sans passer par l'extérieur.
- *La magie de Docker Network* : Il intègre un résolveur DNS automatique. WordPress peut se connecter à la base de données simplement en l'appelant `mariadb` (le nom du conteneur), sans avoir besoin de connaître son adresse IP !

---

## 2. Les Vérifications Techniques du Correcteur

Pendant la correction, l'évaluateur va scruter ton code et lancer des commandes. Voici ce qu'il va faire, et comment tu peux le rassurer :

### Les Fichiers
- **Pas de `network: host` ni de `links:`** dans le `docker-compose.yml` (On utilise un réseau bridge `networks:`).
- **Pas de `tail -f` ou `sleep infinity`** dans les Dockerfiles/scripts (C'est la théorie du PID 1 : on lance les vrais services au premier plan avec `daemon off` ou `-F`).
- **L'avant-dernière version stable** : Tes Dockerfiles commencent bien par `FROM debian:bullseye`.

### Les Commandes qu'il va taper
1. `docker network ls` : Il veut voir ton réseau `srcs_inception` apparaître.
2. `docker volume ls` puis `docker volume inspect srcs_mariadb` : Il va vérifier que le champ `Device` pointe bien vers `/home/sam/data/mariadb` (ou le chemin de ta VM) sur ta vraie machine.
3. `docker compose ps` : Pour vérifier que les 3 conteneurs sont `Up`.

### Les Tests Pratiques
1. **NGINX** :
   - Aller sur `http://sreffers.42.fr` (Port 80) : Ça ne doit PAS marcher.
   - Aller sur `https://sreffers.42.fr` (Port 443) : Le site doit s'afficher.
   - Montrer le certificat SSL (Avertissement de sécurité accepté).
2. **WordPress** :
   - Ton site s'affiche à l'adresse `https://sreffers.42.fr` (pas de page d'installation).
   - Ton pseudo Admin **NE CONTIENT PAS** le mot `admin` (ex: `sreffers` est parfait).
   - **Se connecter en Admin pour commenter** :
     - Va sur 👉 `https://sreffers.42.fr/wp-admin`
     - Connecte-toi avec ton pseudo admin et le mot de passe du fichier `secrets/wp_admin_password.txt`.
     - Dans le menu de gauche, clique sur "Articles" -> Clique sur "Hello World" -> Modifie le texte ou ajoute un commentaire.
     - Retourne sur la page d'accueil pour montrer au correcteur que la modification est bien en ligne.
3. **MariaDB** :
   - Se connecter en tapant : `docker compose exec mariadb mysql -u root -p` ou avec ton `wp_user`.
   - Taper `SHOW DATABASES;` puis `USE wordpress;` puis `SHOW TABLES;` pour prouver que la base n'est pas vide.

### Le Test Ultime : La Persistance
Le correcteur va te demander de **redémarrer complètement la VM**.
Au redémarrage, tu lanceras `make up`. Le site doit revenir avec le commentaire que tu as rajouté à l'étape d'avant ! (C'est la preuve que tes volumes fonctionnent parfaitement).

---

## 3. L'Organisation des Bonus

Pour le bonus, tu n'as **pas besoin** de créer un dossier `bonus/`.
Le sujet stipule simplement : "Verify and test the proper functioning and implementation of each extra service."

Tu peux très bien créer un nouveau dossier `srcs/requirements/redis/` et rajouter le bloc `redis:` dans ton `docker-compose.yml` actuel.
*(Note : Certains étudiants aiment faire un fichier `docker-compose-bonus.yml` et une règle `make bonus` pour séparer les choses, mais ce n'est pas obligatoire. Le plus simple et rapide est de l'intégrer directement à l'infrastructure existante, c'est ce qui se fait de plus en plus souvent sur ce projet).*

---

## 4. Accéder aux Services Bonus

Pour tester rapidement tes 5 bonus le jour de la soutenance :
- **Portfolio Statique** (HTML/Python) : 👉 `http://sreffers.42.fr:3000`
- **Adminer** (Base de données) : 👉 `http://sreffers.42.fr:8080` (Connecte-toi avec `wp_user` et le mot de passe de `db_password.txt`).
- **Dashboard Monitoring** (RAM/CPU) : 👉 `http://sreffers.42.fr:8081`
- **Serveur FTP** : Depuis le terminal, tape `ftp 127.0.0.1`. Connecte-toi avec l'utilisateur FTP et ton `ftp_password.txt`.
- **Redis Cache** : Depuis le terminal de la VM, tape `docker compose -f srcs/docker-compose.yml exec redis redis-cli monitor` puis recharge ton site WordPress pour voir les requêtes être mises en cache en temps réel.

---

## 5. Checklist : Installation sur la VM d'Évaluation (Le Jour J)

Quand tu vas arriver en soutenance sur une machine de l'école (ou une VM vierge fournie), voici **exactement** l'ordre des choses à faire avant d'appeler ton correcteur :

1. **Cloner le repo** : 
   `git clone <ton_repo_git> Inception` puis `cd Inception`
2. **Modifier les chemins absolus (CRITIQUE !)** :
   - Dans ton `Makefile`, tu as sûrement écrit `DATA_PATH = /home/sam/data`. Sur la machine de l'école, ton utilisateur sera `sreffers`. Tu dois donc ouvrir le Makefile et modifier cette ligne en `/home/sreffers/data`. Fais de même dans ton `.env` si tu y avais écrit un chemin absolu.
3. **Restaurer les Secrets (CRITIQUE !)** : 
   - Puisque le dossier `secrets/` n'a pas été poussé sur Git (pour des raisons de sécurité évidentes), tes conteneurs vont planter si tu lances `make` maintenant. Tu dois impérativement les recréer :
     ```bash
     mkdir secrets
     echo "ton_mot_de_passe" > secrets/db_password.txt
     echo "ton_mot_de_passe_root" > secrets/db_root_password.txt
     echo "ton_mot_de_passe_wp" > secrets/wp_admin_password.txt
     echo "ton_mot_de_passe_ftp" > secrets/ftp_password.txt
     ```
4. **Restaurer le fichier `.env`** : 
   - Pareil, s'il a été ignoré par Git, recrée-le avec `nano srcs/.env` et remets dedans tes variables (`DOMAIN_NAME=sreffers.42.fr`, `MYSQL_DATABASE=wordpress`, etc.).
5. **Configurer le DNS local** : 
   - NGINX ne fonctionnera pas si le nom de domaine ne pointe pas vers la machine locale. Ouvre le fichier hosts :
     ```bash
     sudo nano /etc/hosts
     ```
   - Ajoute la ligne : `127.0.0.1 sreffers.42.fr`
6. **Lancer la magie** : 
   - Maintenant que l'environnement est restauré, tu peux taper `make`. Toute ton infrastructure va se construire sans la moindre erreur ! Tu es prêt à appeler le correcteur.
