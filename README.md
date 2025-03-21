# Symfony Start

## Introduzione

Questo repository propone un tree per un progetto Symfony4.

Nella root `/` è presente ciò che serve per avviare i container Docker a supporto del progetto.

Nella cartella `/backend` invece verrà creato il progetto Symfony.

L'obiettivo è quello di fornire uno strumento di supporto a chi approccia Symfony (e magari Php)
per la prima volta, senza doversi preoccupare troppo di configurare l'ambiente.


## Getting started

Copiamo `.env.docker.dist` in `.env` e configuriamolo

```
cp .env.docker.dist .env
vim .env
```
Possiamo impostare per la variabile LOCALHOST un ip compreso tra `127.0.0.1` e `127.0.0.254`,
ad esempio `127.0.0.42`

Non è indispensabile ma non è una cattiva idea impostare questo ip nei propri host dando un nome all'host,
ad esempio `the-answer`:

```
sudo vim /etc/hosts
```

```
# /etc/hosts
...
127.0.0.42   the-answer
...
``` 


Fatto questo possiamo avviare i container con

```
./dc up -d --build
```

ed entrarci con

```
./dc enter
```

> ATTENZIONE: Lo script `dc` copia il contenuto della cartella `.ssh` dell'utente corrente nel container in modo che da dentro
al container ci si possa connettere via ssh con i server di stage e produzione identificandosi con le proprie chiavi.
Questo potrebbe non essere gradito se non se ne comprende le ragioni.

Ci troveremo dentro il container nella cartella `/var/www/project/backend`.

Usciamo da `backend` e lanciamo `bin/create-project.sh` che non fa altro che creare il projetto Symfony 4.4
nella cartella `backend`.
```
cd ..
bin/create-project.sh
```

Symfony ci da i consueti suggerimenti so cosa fare successivamente.

Entriamo nella cartella `backend` e proviamo ad eseguire `sf`, un alias di `bin/console`
definito in questo container
```
cd backend
sf
```

Vedremo la consueta lista dei comandi disponibili.

Proviamo ad accedere dal browser impostando l'indirizzo `http://127.0.0.42` oppure `http://the-answer`.

Dovremmo vedere la consueta Welcome page di Symfony.


Per la connessione al database è bene ricordare che stiamo utilizzando un container.
Questo container è stato chiamato `db` nel file `/docker-composer.yml`,
lo user name di default del container è `root`
e per la password scelta nel `/.env.dist` (che può essere cambiata nel `.env`) è `root`.
Il nome del db è discrezionale.

Quindi la variabile d'ambiente in `/backend/.env` va modificata così:
```
DATABASE_URL=mysql://root:root@db:3306/db_name?serverVersion=5.7
```




### Un nuovo repository

Ora dato che vogliamo dare vita ad un repository diverso da questo cancelliamo la cartella .git
e reinzializiamo il repository:
```
rm -Rf .git
git init
```


dovremmo inoltre rimuovere le seguenti righe da `/.gitignore` in modo da permettere a git di versionare il
contenuto della cartella `backend`:
 
```
...
/backend/**
!/backend/**/
...
```
