# Théorie Inception : En route vers le DevOps ! 🚀

Bienvenue dans ce document qui t'accompagnera tout au long de ton projet Inception. Puisque ton but est de devenir DevOps, nous allons décortiquer chaque concept pour que tu maîtrises non seulement le "comment", mais surtout le "pourquoi".

## 1. Introduction : Qu'est-ce que Docker et pourquoi l'utiliser ?

Avant l'arrivée de Docker, pour isoler des applications, on utilisait des **Machines Virtuelles (VMs)**. 
- **Le problème des VMs** : Chaque VM embarque son propre système d'exploitation (OS) complet (noyau + processus). C'est très lourd, ça consomme beaucoup de RAM, de CPU, et ça met du temps à démarrer.
- **La solution Docker (Les Conteneurs)** : Un conteneur ne virtualise pas l'OS entier, il partage le noyau (kernel) de la machine hôte. Il n'embarque que ce qui lui est strictement nécessaire : son code, ses bibliothèques, et ses dépendances.
  - Résultat : C'est ultra-léger, ça démarre en quelques millisecondes, et ça garantit que "ça marche sur ma machine, donc ça marchera partout".

## 2. L'Architecture Micro-services vs Monolithique

Dans Inception, on te demande de séparer NGINX, WordPress, et MariaDB dans des conteneurs différents.
- **Monolithe** : Mettre le serveur web, le code de l'app, et la base de données sur un même serveur. Si le serveur web crash, tout tombe.
- **Micro-services (Approche Docker)** : Séparer chaque composant. 
  - NGINX gère uniquement les requêtes HTTPS.
  - WordPress (PHP-FPM) génère uniquement les pages web.
  - MariaDB stocke uniquement les données.
Si le conteneur WordPress crash, MariaDB tourne toujours. Docker le redémarrera sans impacter le reste. C'est l'essence même de la philosophie DevOps : résilience, scalabilité, et modularité.

## 3. Le Processus PID 1 et pourquoi pas de boucle infinie (`tail -f`)

Le sujet insiste : pas de `tail -f` ou `sleep infinity`. Pourquoi ?
Dans un système Linux normal, le PID 1 (le premier processus démarré, souvent `systemd` ou `init`) gère tout le système.
Dans un conteneur Docker, **le conteneur ne vit que tant que son processus PID 1 est actif**. 
- Si tu lances `tail -f` comme PID 1 pour garder le conteneur ouvert en tâche de fond, Docker pense que le but de ce conteneur est de faire un `tail`. Si NGINX crash en arrière-plan, Docker ne s'en rendra pas compte et ne redémarrera pas le conteneur, car `tail` tourne toujours !
- **La bonne pratique** : Le PID 1 doit être le service lui-même. Pour NGINX, on lance `nginx -g "daemon off;"` pour qu'il tourne au premier plan. S'il crash, le PID 1 meurt, le conteneur s'arrête, et la directive `restart: always` de Docker le redémarre instantanément.

## 4. Comment Docker partage-t-il le Kernel avec des OS différents ?

C'est une excellente question ! Pour comprendre, il faut séparer le système d'exploitation en deux parties :
1. **Le Kernel (Noyau)** : C'est le cœur du système. Il parle directement au matériel (CPU, RAM, Disque). Sous Linux, toutes les distributions (Debian, Ubuntu, Alpine) utilisent *le même noyau Linux*.
2. **Le Userland (Espace utilisateur)** : Ce sont les programmes, l'interface, le gestionnaire de paquets (`apt` pour Debian, `apk` pour Alpine), et les bibliothèques C (comme `glibc` ou `musl`). C'est ça qui différencie vraiment Debian d'Alpine.

**La magie de Docker** :
Un conteneur Docker n'embarque **que le Userland**.
Quand tu lances un conteneur Debian sur ton PC Ubuntu (ou Mint), le conteneur a les dossiers et le gestionnaire de paquets de Debian, mais quand un programme dans le conteneur a besoin d'écrire sur le disque ou d'utiliser le réseau, il fait un "appel système" (syscall) directement au **Kernel de ton PC hôte**.
C'est pour cela qu'un conteneur est si léger : il n'a pas besoin de démarrer un noyau, il utilise celui qui tourne déjà sur ta machine ! Et c'est aussi pour cela qu'on ne peut pas faire tourner un conteneur purement Windows sur un noyau Linux sans passer par une Machine Virtuelle au milieu.

## 5. La sécurité : Le fichier `.env` vs Docker Secrets

Dans ce projet, tu dois configurer des mots de passe (pour la base de données, pour l'admin WordPress, etc.). **La règle d'or en DevOps, c'est de ne JAMAIS écrire de mots de passe en clair dans ton code ou tes fichiers Docker (hardcoding).**

### Le fichier `.env`
Le fichier `.env` sert à stocker des **Variables d'Environnement**.
Au lieu d'écrire `password=1234` dans ton script MariaDB, tu écris `password=$DB_PASSWORD`. 
Docker lira le fichier `.env`, récupérera la valeur de `DB_PASSWORD`, et la passera dynamiquement à ton conteneur.
- **Pourquoi faire ça ?** Parce que le fichier `.env` est toujours ignoré par `git` (via un fichier `.gitignore`). Ainsi, quand tu envoies ton code sur Github ou au correcteur, tes mots de passe restent sur ton ordinateur et ne sont pas publics.
- **Ce qu'on y met** : Le nom de domaine (`login.42.fr`), les noms d'utilisateurs, le nom de la base de données.

### Les Docker Secrets (Optionnel mais recommandé)
Le sujet mentionne que l'utilisation de Docker Secrets est fortement recommandée pour la sécurité.
Un "Secret" Docker, c'est un fichier texte (souvent dans un dossier `secrets/`) qui ne contient **que le mot de passe**.
- **La différence avec le `.env`** : Les variables d'environnement (du `.env`) sont visibles par n'importe quel processus tournant dans le conteneur, ou par un simple `docker inspect`. Un secret Docker est chiffré et monté comme un fichier temporaire en mémoire (`/run/secrets/...`) uniquement pour les conteneurs qui en ont besoin. C'est le standard de l'industrie pour les vrais mots de passe.
- **Pour ce projet** : Tu peux commencer par utiliser uniquement le `.env` pour tout (car le sujet l'autorise si le `.env` n'est pas uploadé sur git), ou utiliser les Docker Secrets pour les mots de passe de MariaDB si tu veux le faire de façon optimale.

## 6. L'Orchestrateur : Docker Compose (Réseaux et Volumes)

Quand tu as un seul conteneur à lancer, la commande `docker run` suffit. Mais dans Inception, on a 3 conteneurs qui doivent communiquer entre eux, démarrer dans un certain ordre, et sauvegarder des données. C'est là qu'intervient **Docker Compose**.
Le fichier `docker-compose.yml` est le "chef d'orchestre" de ton projet. Il décrit toute ton architecture dans un seul fichier.

Deux concepts fondamentaux s'y trouvent :

### 1. Le Réseau (Docker Network)
Par défaut, deux conteneurs Docker ne se connaissent pas.
- Dans le `docker-compose.yml`, on va créer un réseau commun (qu'on appellera souvent `inception`). 
- **La magie du réseau Docker** : Docker intègre un mini-serveur DNS. Dès que NGINX, WordPress et MariaDB sont sur le même réseau, NGINX peut contacter WordPress simplement en tapant `ping wordpress` (le nom du conteneur), sans même connaître son adresse IP !

### 2. Les Volumes (Docker Volumes)
Un conteneur est "éphémère". Si tu le supprimes, tout ce qui était à l'intérieur disparaît (tes articles WordPress, ta base de données...).
- Le sujet demande des **volumes nommés**. C'est un dossier sécurisé que Docker crée sur la machine hôte (dans `/home/sreffers/data/` comme demandé par 42).
- Docker monte ce dossier à l'intérieur du conteneur MariaDB (dans `/var/lib/mysql`).
- Si MariaDB crash ou est détruit, les données restent physiquement sur ton PC. Au redémarrage, Docker reconnecte le volume, et ta base de données est intacte. Résilience DevOps activée ! 🛡️

## 7. Comprendre les Volumes (driver_opts, o: bind, /var/lib/mysql)

Dans `docker-compose.yml`, la gestion des volumes peut sembler redondante, mais elle est très logique.

### Pourquoi déclarer les volumes deux fois (en haut et en bas) ?
- **En bas (DÉCLARATION)** : Tu expliques à Docker *comment* créer la clé USB virtuelle (le volume nommé). Tu lui donnes un nom (`mariadb`), tu lui dis d'utiliser le disque local (`driver: local`), et tu lui dis de l'attacher à un dossier physique de ton PC (`device: /home/sreffers/data/mariadb`).
- **En haut (UTILISATION)** : Dans le bloc du service `mariadb`, tu expliques à Docker *où brancher* cette clé USB à l'intérieur du conteneur. C'est la ligne `- mariadb:/var/lib/mysql` (qui veut dire : "Branche le volume nommé `mariadb` sur le dossier `/var/lib/mysql` du conteneur").

### C'est quoi `/var/lib/mysql` ?
Dans un système Linux classique, chaque logiciel a un endroit par défaut où il range ses données :
- MariaDB range **toujours** ses bases de données dans `/var/lib/mysql`.
- Les serveurs web (comme NGINX ou Apache) rangent **toujours** leurs sites web dans `/var/www/html`.
Donc, quand tu dis `- mariadb:/var/lib/mysql`, tu dis à Docker : "Prends tout ce que MariaDB écrit dans son dossier par défaut, et sauvegarde-le de façon permanente dans mon volume !".

### C'est quoi `driver_opts` et `o: bind` ?
Le sujet de 42 te dit : *"Vous devez utiliser des volumes nommés. Les bind mounts sont interdits."*
- Un **bind mount** classique, c'est écrire directement `- /home/sam/data:/var/lib/mysql` dans le service. C'est sale, ça gère mal les permissions.
- Un **volume nommé**, c'est ce qu'on fait dans le bloc du bas. Mais par défaut, Docker range les volumes nommés dans un coin caché de ton système (`/var/lib/docker/volumes`). 
- Le problème, c'est que le sujet exige que les données soient dans `/home/login/data`. La seule façon de dire à Docker "Crée un volume nommé, mais range-le à cet endroit précis", c'est d'utiliser les options avancées (`driver_opts`) avec `type: none` et `o: bind`. C'est une petite astuce technique tolérée (et même attendue) pour satisfaire toutes les exigences du sujet.

## 8. Alpine vs Debian : Lequel choisir en entreprise ?

C'est une excellente question de DevOps ! Dans le monde professionnel, tu vas croiser les deux, mais avec des philosophies différentes :

- **Alpine Linux** : C'est le chouchou du cloud moderne. Une image Alpine de base pèse à peine ~5 Mo ! 
  - *Avantages* : Images ultra-légères (donc téléchargement et démarrage hyper rapides) et sécurité accrue (surface d'attaque très réduite car très peu de programmes sont installés par défaut). Il utilise `apk` comme gestionnaire de paquets au lieu de `apt`.
  - *Inconvénients* : Il utilise une bibliothèque C minimaliste (`musl` au lieu de `glibc`). Certains programmes très complexes peuvent parfois avoir des bugs obscurs sous Alpine à cause de ça.
- **Debian** : C'est le standard robuste. Une image pèse environ ~120 Mo.
  - *Avantages* : Ultra-stable, utilise `apt` que tu connais déjà, compatibilité maximale avec 100% des logiciels Linux car il utilise `glibc`.
  - *Inconvénients* : Plus lourd.

**Conclusion** : En entreprise, la règle est souvent *"Utilise Alpine par défaut pour la légèreté, et passe sur Debian/Ubuntu uniquement si l'application plante sous Alpine"*. Pour ce projet 42, Debian est souvent plus facile pour les débutants car les configurations sont standards, mais Alpine impressionnera plus pour son aspect minimaliste DevOps !

## 9. Les commandes de base du Dockerfile
Pour construire ton image, ton Dockerfile va utiliser des instructions clés :
- `FROM debian:bullseye` : Définit l'OS de base (bullseye est l'avant-dernière version stable de Debian, comme demandé par le sujet).
- `RUN apt-get update && apt-get install -y ...` : Exécute des commandes dans le conteneur pendant la construction.
- `COPY fichier_source chemin_destination` : Copie un fichier de ton PC vers l'intérieur du conteneur.
- `ENTRYPOINT ["bash", "/mon_script.sh"]` : La commande qui tournera tout le temps (le PID 1).

## 10. Pourquoi des chemins absolus (`/usr/...`) et pas de `../` dans Docker ?

C'est une confusion très fréquente ! Il faut bien séparer deux mondes :
- **Ton PC (Le Host)** : Tu as tes dossiers organisés avec `srcs/requirements/mariadb/conf`.
- **Le Conteneur (Le Guest)** : Quand l'image est construite, elle ne connaît absolument rien de l'arborescence de ton PC. Elle commence avec un système de fichiers vide (la racine `/`).

Quand on fait `COPY tools/setup.sh /usr/local/bin/setup.sh` dans le Dockerfile :
1. Docker regarde sur **ton PC** dans le dossier local `tools/` et prend le script.
2. Docker le colle **dans le conteneur** au chemin absolu `/usr/local/bin/`.

Pourquoi `/usr/local/bin/` particulièrement ? Sous Linux, ce dossier est dans la variable d'environnement `$PATH`. Cela signifie que tout script qui y est placé devient une commande globale du système. Le conteneur pourra simplement lancer la commande `setup.sh` de n'importe où, sans avoir besoin de préciser le chemin !

## 11. Le nommage de la configuration MariaDB (`50-server.cnf`)
Sous Debian, la configuration de MariaDB est divisée en pleins de petits fichiers stockés dans `/etc/mysql/mariadb.conf.d/`. Ils sont lus dans l'ordre alphabétique.
Le fichier par défaut qui gère le réseau s'appelle `50-server.cnf`. En nommant notre fichier exactement pareil et en le copiant au même endroit, on **écrase** la configuration par défaut de Debian par la nôtre !

## 12. C'est quoi le dossier `/run/secrets` ?
Sous Linux, le dossier `/run` est très spécial : c'est un système de fichiers temporaire (tmpfs) qui **vit uniquement dans la mémoire RAM**, pas sur le disque dur. À chaque redémarrage, il est entièrement vidé.
Quand Docker gère des "Secrets", il ne copie pas le fichier texte sur le disque du conteneur (ce serait risqué si quelqu'un volait l'image). Il monte le fichier secret **directement dans la RAM** du conteneur via le dossier `/run/secrets/`. C'est le niveau maximal de sécurité !

## 13. La "Danse du PID 1" (Pourquoi allumer puis éteindre MariaDB ?)
Dans le script `setup.sh`, on fait quelque chose qui a l'air absurde : on allume MariaDB, on le configure, on l'éteint, puis on le rallume. Pourquoi ?
- **L'allumage en fond (`service mariadb start`)** : C'est obligatoire pour pouvoir envoyer nos requêtes SQL de configuration (`CREATE DATABASE...`). Mais le problème, c'est que la commande `service` lance MariaDB en arrière-plan (daemon).
- **L'extinction (`mysqladmin shutdown`)** : Si le script `setup.sh` se termine avec MariaDB en arrière-plan, Docker va se dire : "Le script a fini son travail, donc le conteneur a fini, je l'éteins !".
- **L'allumage final (`exec mysqld_safe`)** : La commande `exec` est magique. Elle dit à Linux : "Remplace le processus actuel (le script bash) par ce nouveau programme (MariaDB)". MariaDB devient alors le fameux **PID 1**, tournant au premier plan. Docker le surveillera en permanence et maintiendra le conteneur en vie !
## 14. Configuration dynamique (L'alternative "DevOps" au fichier statique)
Est-ce qu'on est obligé de mémoriser `50-server.cnf` et de copier un fichier physique ? Non !
Une technique extrêmement prisée en DevOps est de modifier le fichier de configuration par défaut *à la volée*, pendant la construction de l'image (dans le Dockerfile) ou au démarrage (dans `setup.sh`), en utilisant la commande `sed`.
Par exemple, dans le `Dockerfile` de MariaDB, au lieu de copier un fichier `conf/`, on peut juste faire :
```dockerfile
RUN sed -i 's/bind-address            = 127.0.0.1/bind-address            = 0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf
```
## 15. Que fait `docker compose build` exactement ?

C'est une excellente question. Quand tu tapes `docker compose build mariadb`, voici la séquence exacte de ce qui se passe "sous le capot" :

1. **Lecture de l'orchestrateur** : Docker lit `docker-compose.yml`, trouve le bloc `mariadb`, et voit `build: ./requirements/mariadb`. Il sait alors qu'il doit aller dans ce dossier et trouver le fichier `Dockerfile`.
2. **Exécution séquentielle (Couche par couche)** : Docker lit ton `Dockerfile` **de haut en bas, ligne par ligne**. Chaque ligne crée ce qu'on appelle une "Layer" (couche) de l'image :
   - Ligne 1 (`FROM`) : Docker télécharge le mini-OS de base depuis internet (le noyau Debian). C'est la couche 1.
   - Ligne 2 (`RUN apt-get...`) : Docker démarre un conteneur temporaire, lance l'installation, attend qu'elle se termine (il "check" s'il n'y a pas d'erreur), puis sauvegarde le résultat comme une nouvelle photo polaroid. C'est la couche 2.
   - Ligne 3 (`COPY`) : Docker prend le fichier sur ton PC et l'ajoute à la couche 3.
   - etc...
3. **Validation et Cache** : **OUI**, Docker vérifie chaque étape. Si une commande `RUN` plante (ex: faute de frappe), la construction s'arrête net avec un gros message d'erreur rouge. 
   - *Le pouvoir du Cache* : Si tu relances `build` demain, Docker ne va pas re-télécharger Debian. Il va utiliser le "cache" (les couches qu'il a déjà en mémoire). Il ne va reconstruire que les lignes modifiées depuis le dernier build. C'est pour ça qu'un build prend 30 secondes la première fois, et 1 seconde les fois suivantes !
## 16. L'Idempotence (Pourquoi mon script plante au deuxième lancement ?)
C'est un concept fondamental en DevOps : **Un script doit être "Idempotent"**. Ça veut dire que si on le lance 1 fois ou 100 fois de suite, le résultat final doit être le même, et il ne doit pas crasher.
Dans un conteneur Docker, le `ENTRYPOINT` (notre `setup.sh`) est exécuté **à chaque fois** que le conteneur démarre. 
- Au tout premier démarrage, le volume est vide. Le script allume MariaDB, crée la base, change le mot de passe root, et l'éteint. Tout se passe bien.
- Au deuxième démarrage (ex: on a redémarré le PC), le volume contient déjà les données. Le script s'exécute à nouveau. Il allume MariaDB en fond, puis tente de faire `mysql -e "CREATE DATABASE..."` **sans fournir de mot de passe root** (puisqu'il l'avait modifié au premier lancement !). Et là : `Access denied for user 'root' (using password: NO)`.

## 17. L'état d'esprit SysAdmin : Faut-il tout retenir par cœur ?
C'est la question la plus importante que tu as posée ! **NON, on ne retient rien par cœur en SysAdmin.**
- **Comment savoir quel paquet installer ?** On lit la documentation officielle. Si tu vas sur le site de WordPress, il est écrit : *"WordPress nécessite PHP et l'extension php-mysql"*. Tu fais alors une recherche "installer php-mysql sur Debian", et ça te donne le nom exact du paquet.
- **Comment trouver le nom des fichiers de configuration (`www.conf`, `50-server.cnf`...) ?** Le secret de pro, c'est de lancer un conteneur vierge (`docker run -it debian:bullseye bash`), d'installer le paquet (`apt install php-fpm`), puis de fouiller dans les dossiers `/etc/php/` pour lire les fichiers par défaut ! On regarde comment c'est fait, on copie la structure, et on l'adapte. Le métier de DevOps, c'est 80% de recherche et d'exploration !

## 18. Optimiser ses Dockerfiles : Stop au `apt-get update` multiple !
Chaque mot-clé `RUN`, `COPY`, ou `FROM` dans un Dockerfile crée une nouvelle "couche" (layer) sur le disque. 
Si tu mets 4 fois `RUN apt-get update`, Docker va créer 4 couches différentes, exécuter 4 fois la mise à jour, et alourdir ton image finale.
**La Règle d'or Docker** : On regroupe toujours l'installation des paquets sur **une seule ligne** (un seul `RUN`) pour ne créer qu'une seule couche optimisée.
```dockerfile
# MAUVAIS ❌
RUN apt-get update
RUN apt-get install -y php
RUN apt-get install -y wget

# PARFAIT (La méthode DevOps) ✅
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php-mysql \
    mariadb-client \
    wget
## 19. Pourquoi ne pas faire les `mkdir -p` des volumes dans le Dockerfile ?
C'est le piège classique de la séparation **Host** (ton PC) vs **Guest** (le conteneur).
Le fichier `Dockerfile` s'exécute **à l'intérieur** du conteneur pendant sa construction. Si tu y mets `RUN mkdir -p /home/sam/data`, Docker va créer un dossier `/home/sam/data` **à l'intérieur du conteneur**, et non sur ton vrai PC ! 
C'est pour cela que la création des dossiers locaux (Host) se fait toujours à l'extérieur, souvent automatisée par un script ou un `Makefile` avant de lancer `docker compose`.

## 20. Comment trouver les chemins de configuration tout seul ?
Google est ton ami, mais la vraie méthode d'ingénieur pour trouver `/etc/php/7.4/fpm/pool.d/www.conf` sans Google, c'est l'exploration !
1. Tu lances un conteneur Debian vierge et tu rentres dedans : `docker run -it debian:bullseye bash`
2. Tu installes PHP : `apt update && apt install php7.4-fpm`
3. Tu sais que les configurations sous Linux vont toujours dans `/etc`. Tu utilises donc la commande `find` pour chercher tous les fichiers `.conf` liés à PHP :
   ```bash
   find /etc/php -name "*.conf"
   ```
Et bingo ! La console te listera tous les fichiers, et tu verras apparaître le fameux `www.conf`. Tu peux ensuite l'ouvrir avec `cat` pour voir quelles lignes modifier.

## 21. C'est quoi `pm`, `max_children`, `start_servers` dans PHP-FPM ?
PHP-FPM (FastCGI Process Manager) est un "Manager" (le fameux `pm`). Son rôle est de créer des petits processus "ouvriers" (les `children`) pour répondre aux requêtes web (ex: un utilisateur charge la page d'accueil de WordPress).
- `pm = dynamic` : Le manager est "dynamique", il va créer ou tuer des ouvriers selon l'affluence du site web.
- `pm.max_children = 5` : Il y aura au maximum 5 ouvriers en même temps. (Si 6 personnes se connectent exactement en même temps, le 6ème devra patienter).
- `pm.start_servers = 2` : Quand le conteneur s'allume, le manager crée d'office 2 ouvriers prêts à travailler, pour ne pas perdre de temps à la première connexion.
- `min/max_spare_servers` : C'est le nombre minimum et maximum d'ouvriers inactifs qu'on garde "sous le coude" en cas de pic de trafic.
## 22. WP-CLI : L'automatisation de WordPress
Habituellement, pour installer WordPress, on télécharge un fichier `.zip`, on le décompresse, on va sur `http://localhost` avec son navigateur, et on clique sur "Suivant" en remplissant des formulaires.
En DevOps, **on ne clique jamais sur rien**. Tout doit être automatisé !
C'est là qu'intervient **WP-CLI** (WordPress Command Line Interface). C'est un petit programme qui permet de faire toutes les actions WordPress (télécharger, installer, créer un utilisateur, configurer la base de données) directement en tapant des lignes de commande bash. Notre script `setup.sh` va télécharger ce programme, puis s'en servir pour installer ton site de A à Z en une fraction de seconde, sans aucune intervention humaine !

## 23. Que fait `docker compose up -d` exactement ?
La commande `up` fait trois choses en même temps :
1. **Create** : Elle crée les réseaux virtuels et les volumes sur ton disque (s'ils n'existent pas encore).
2. **Build** : Elle cherche l'image locale. Si l'image n'existe pas du tout, elle lance un `build` automatique. *(Attention : si une vieille image existe, elle l'utilise sans la reconstruire, d'où l'importance de faire `build` manuellement quand tu modifies un fichier !).*
3. **Start** : Elle allume le conteneur.

**Et le fameux `-d` ?**
Il signifie **"Detached"** (Détaché). Sans le `-d`, ton terminal serait bloqué par les logs en direct du conteneur. Si tu fermais ton terminal (ou si tu faisais CTRL+C), le conteneur s'éteindrait avec lui !
En ajoutant `-d`, tu dis à Docker : "Lance le conteneur en tâche de fond et rends-moi la main sur mon terminal". C'est pour cela qu'on utilise ensuite `docker compose logs` pour aller lire ce qu'il se passe "dans les coulisses".

## 24. C'est quoi ce `-subj` dans OpenSSL ?
Quand on crée un certificat HTTPS, on crée une "carte d'identité" cryptographique pour le site web. Le `-subj` (Subject) contient les informations de cette carte :
- `C=FR` : **C**ountry (Pays, en 2 lettres)
- `ST=Paris` : **St**ate (État ou Région)
- `L=Paris` : **L**ocality (Ville)
- `O=42` : **O**rganization (Nom de l'entreprise ou l'école)
- `OU=Inception` : **O**rganizational **U**nit (Le département de l'entreprise)
- `CN=sreffers.42.fr` : **C**ommon **N**ame (C'est le plus important ! C'est le nom de domaine exact qui sera protégé par le certificat).

Tu peux modifier toutes ces valeurs comme tu le souhaites, mais le `CN` doit correspondre exactement à l'URL de ton site web !

## 25. Le silence de NGINX (Pourquoi je n'ai pas de logs ?)
C'est la règle d'or en informatique : **"Pas de nouvelles, bonnes nouvelles"** (No news is good news).
Quand NGINX démarre avec succès, il ne dit absolument rien. Il se met au premier plan et attend en silence. Il ne générera des logs que dans deux cas :
1. Une erreur critique survient.
2. Un utilisateur (toi) visite le site web (ce qu'on appelle les "access logs").
Si tu as fait `docker compose logs nginx` et que c'est vide, c'est que ton serveur web tourne parfaitement !

## 26. Le DNS Local : Le fichier `/etc/hosts`
Maintenant que le site web tourne, comment y accéder ? 
Si tu tapes `sreffers.42.fr` dans ton navigateur, ton PC va interroger les serveurs DNS d'Internet, qui ne connaissent pas ce site (car il n'existe que sur ton propre PC !).
Il faut donc trafiquer le "carnet d'adresses" interne de ton PC (Linux/Mac). Ce carnet s'appelle `/etc/hosts`.
En ajoutant la ligne `127.0.0.1 sreffers.42.fr` dans ce fichier (avec les droits `sudo`), tu forces ton ordinateur à envoyer les requêtes vers ton propre PC (localhost) au lieu de chercher sur Internet. Et là, NGINX interceptera la requête !

## 27. Bonus : Rendre WordPress beau en une seule ligne !
La force de WordPress, ce sont les "Thèmes". Par défaut, tu as le thème basique (très austère). 
Est-ce que c'est compliqué de le rendre beau ? Pas du tout grâce à notre outil magique WP-CLI ! 
Si tu veux installer un thème moderne comme "Astra" (l'un des plus populaires au monde), il suffit d'ajouter cette ligne à la fin de ton `setup.sh` (juste après la création de l'utilisateur) :
```bash
wp theme install astra --activate --allow-root
```
Tu reconstruis l'image, tu recrées le conteneur, et pouf, ton site aura une allure très professionnelle ! C'est 100% optionnel pour le projet 42, mais c'est un excellent "flex" pour ton correcteur !

## 28. Le rôle du `Makefile` et du `--build`
Dans la règle `up` de ton Makefile, la commande est : `docker compose -f srcs/docker-compose.yml up -d --build`.
Voici son autopsie :
1. `docker compose` : L'orchestrateur.
2. `-f srcs/docker-compose.yml` : Comme le Makefile est à la racine du projet, on doit dire à Docker où se trouve le fichier de configuration (car il n'est pas dans le même dossier !).
3. `up` : Lis le fichier, trouve tous les services (mariadb, wordpress, nginx) et allume-les tous ensemble.
4. `-d` : Fais ça en tâche de fond pour me laisser mon terminal.
5. `--build` : Le fameux drapeau magique ! Il force Docker à vérifier s'il y a eu des modifications dans tes fichiers avant d'allumer. S'il voit un changement, il re-construit l'image automatiquement. Ça t'évite de tomber dans le "piège de l'ancienne image" qu'on a vu à la Section 16 !

## 29. Bonus : La magie du Cache avec Redis
Dans une architecture web classique, quand un visiteur charge la page d'accueil de ton WordPress, le serveur PHP interroge la base de données MariaDB. MariaDB va alors chercher l'information sur le disque dur, fait ses calculs, et renvoie le résultat à PHP. C'est un processus qui est (informatiquement parlant) très lent. Si 1000 personnes visitent la page en même temps, MariaDB va faire 1000 fois exactement le même calcul, et ton serveur va s'effondrer.

C'est là que **Redis** intervient en sauveur. 
Redis est une base de données de type "clé-valeur" qui stocke ses données **exclusivement en RAM** (mémoire vive). La RAM est des centaines de fois plus rapide qu'un disque dur (SSD ou HDD).
Avec Redis, quand le premier visiteur arrive, PHP demande à MariaDB, puis sauvegarde le résultat final dans Redis. Pour les 999 visiteurs suivants, PHP ne va même plus déranger MariaDB : il va chercher le résultat directement dans la RAM de Redis. La page se charge quasi-instantanément !

### Le paramètre `--raw` dans WP-CLI
Dans le script de configuration, tu as peut-être remarqué ce paramètre : `wp config set WP_CACHE true --raw`.
Le fichier `wp-config.php` est écrit en langage PHP. En PHP, il y a une différence fondamentale entre :
- `define('WP_CACHE', 'true');` *(Une chaîne de texte, avec des guillemets)*
- `define('WP_CACHE', true);` *(Une valeur booléenne brute, sans guillemets)*

Par défaut, la commande `wp config set` entoure toujours les valeurs avec des guillemets. Le paramètre `--raw` (qui signifie "Brut" en anglais) demande à WP-CLI de ne pas mettre de guillemets. C'est indispensable pour les vrais/faux (`true`/`false`) ou les nombres entiers (comme le port `6379`).

## 30. Le problème de permissions `www-data` vs `root`
Quand on automatise WordPress avec WP-CLI, on utilise le flag `--allow-root` pour forcer le programme à s'exécuter avec les droits de super-administrateur Linux (`root`).
Conséquence : Tous les fichiers téléchargés (le cœur de WordPress, les thèmes, les plugins) vont appartenir à `root`.

Or, quand un visiteur navigue sur le site, c'est le programme PHP-FPM qui gère la requête. Et dans notre fichier `www.conf`, on a explicitement demandé à PHP de travailler avec l'utilisateur `www-data` (un utilisateur avec très peu de privilèges, pour des raisons de sécurité).
Si l'utilisateur `www-data` essaie d'écrire dans un fichier appartenant à `root` (par exemple pour uploader une image, ou pour que Redis crée son fichier de cache local), Linux lui refuse l'accès et affiche "Filesystem: Not writeable".

La solution classique en DevOps est donc de faire un grand transfert de propriété à la fin du script d'installation :
`chown -R www-data:www-data /var/www/html`
Cette ligne dit : "Donne la propriété (`CHange OWNer`) de manière Récursive (`-R`) à l'utilisateur et groupe `www-data` pour tout le dossier web". Ainsi, PHP retrouve ses droits légitimes sur le site !

## 31. Tester visuellement Redis
Pour s'assurer que le cache Redis intercepte bien les requêtes, on a deux méthodes :
1. **Le test Web** : Se connecter à `/wp-admin`, aller dans "Settings > Redis". Le statut "Connected" doit s'afficher, et les statistiques "Cache Hits" (Succès) vont augmenter à chaque fois qu'on clique sur le site.
2. **Le test Terminal (Monitoring)** : Dans le terminal, taper `docker compose exec redis redis-cli monitor`. Dès qu'on navigue sur le site WordPress, on voit les requêtes défiler en direct dans le terminal. C'est la preuve que Redis répond à la place de MariaDB.

## 32. Gérer son espace disque (Les commandes utiles)
Un bon DevOps doit surveiller la consommation de son infrastructure.
- `docker system df` : Affiche la vue globale (taille des images, des conteneurs, et du cache de build).
- `docker images` : Affiche le poids individuel de chaque image. (Il est normal qu'une image basée sur Debian pèse entre 150MB et 500MB selon ce qu'on installe).
- `sudo du -sh /home/sam/data/*` : Affiche le poids réel occupé par les dossiers de données (volumes) sur la machine physique.
