# 🚀 Théorie et Tests des Bonus Inception

Ce document rassemble toute l'expertise acquise sur les services Bonus du projet Inception. Il te servira de référence pour expliquer tes choix au correcteur et lui prouver que tes bonus fonctionnent.

---

## ⚡ Bonus 1 : Redis Cache

### 🧠 Comment ça fonctionne ?
Dans une architecture WordPress classique, chaque visiteur déclenche une requête de PHP vers la base de données MariaDB. MariaDB doit lire son disque dur, faire ses calculs et renvoyer la réponse. C'est très lent.
**Redis** est une base de données "clé-valeur" qui vit **entièrement dans la RAM** (mémoire vive).
Grâce à Redis, le résultat de la première requête est sauvegardé en RAM. Pour tous les visiteurs suivants, PHP ne dérange plus MariaDB : il lit directement dans la RAM de Redis. La page se charge quasi-instantanément.

### ❓ Les questions pièges
- **Que fait le paramètre `--raw` dans WP-CLI ?**
  Par défaut, `wp config set` écrit des chaînes de caractères (avec des guillemets) dans `wp-config.php` (ex: `define('WP_CACHE', 'true');`). Le paramètre `--raw` force l'écriture d'une valeur brute sans guillemets, ce qui est indispensable pour les booléens PHP (`true`/`false`) ou les entiers (le port `6379`).
- **Le problème de permissions (`chown www-data`)**
  Lorsqu'on installe WordPress ou des plugins via WP-CLI avec le flag `--allow-root`, les fichiers sont créés par l'utilisateur `root`. Or, quand le visiteur navigue sur le site, c'est le processus PHP-FPM (qui tourne sous l'utilisateur restreint `www-data`) qui tente d'écrire le cache. Sans le `chown -R www-data:www-data`, le site affichera une erreur "Filesystem Not Writeable".

### 🧪 Les commandes pour tester
1. **Test Visuel Web** : Aller sur `https://sreffers.42.fr/wp-admin` > Réglages > Redis. Le statut doit être "Connected" et les statistiques (Hits/Misses) augmentent en naviguant sur le site.
2. **Le Flex DevOps (Terminal)** :
   ```bash
   docker compose exec redis redis-cli monitorTA.1TA.1TA.1TA.1VTA.1
   ```
   *Prouve que Redis intercepte les requêtes : un torrent de texte défile quand on rafraîchit la page WordPress.*

---

## 📂 Bonus 2 : Serveur FTP (vsftpd)

### 🧠 Comment ça fonctionne ?
FTP (File Transfer Protocol) permet de transférer des fichiers à distance. Dans notre infrastructure, on connecte le conteneur FTP au même volume (`srcs_wordpress`) que notre serveur Web.
Ainsi, on crée une "porte dérobée" pour modifier le code source du site web (HTML, PHP, CSS) sans avoir à se connecter au serveur web directement. C'est très utile en cas de crash de WordPress.

### ❓ Les questions pièges
- **Pourquoi exposer les ports `21100-21110` (Mode Passif) ?**
  Le FTP classique (Mode Actif, port 20) implique que le *serveur* initie une connexion vers le *client* pour envoyer les données. À cause des box internet modernes et du NAT de Docker, cette connexion retour est bloquée par les pare-feux.
  En **Mode Passif**, c'est le *serveur* qui ouvre une plage de ports aléatoires (ex: 21100 à 21110) et attend que le *client* vienne s'y connecter pour récupérer ses fichiers.
- **Pourquoi créer le dossier `/var/run/vsftpd/empty` ?**
  Sur Debian, le paquet `vsftpd` exige un dossier vide et protégé appelé `secure_chroot_dir` pour des raisons de sécurité interne (pour isoler les processus sans privilèges). S'il manque, le serveur renvoie l'erreur `500 OOPS`.

### 🧪 Les commandes pour tester
1. **Test rapide en ligne de commande** :
   ```bash
   curl ftp://sam_ftp:sam123@127.0.0.1
   ```
   *Affiche la liste complète des fichiers WordPress (wp-config.php, wp-admin, etc.).*
2. **Test avec interface graphique (FileZilla)** :
   - Hôte : `127.0.0.1` (ou `sreffers.42.fr`)
   - Identifiant : `sam_ftp`
   - Mot de passe : `sam123`
   - *Permet de naviguer visuellement dans les fichiers du site.*

---

## 📊 Extra : Poids des conteneurs
Si l'évaluateur demande si la taille de nos images est normale : **OUI !**
- `mariadb` (480MB), `wordpress` (300MB), `nginx` (213MB), `redis` (150MB).
- Nos images sont basées sur `debian:bullseye` (qui pèse déjà ~114MB vide).
- Elles sont optimisées car nous avons chaîné nos commandes `RUN apt-get` avec des `&&`, ce qui réduit le nombre de "layers" Docker et économise 20% d'espace disque.

*Commandes utiles :*
- `docker images` (taille individuelle)
- `docker system df` (vue globale)
- `sudo du -sh /home/sam/data/*` (poids réel sur le disque dur)
