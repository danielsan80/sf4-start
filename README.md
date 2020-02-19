# Symfony4 bootstrap

## Introduzione

Questo repository propone un tree per un progetto Symfony4.

Nella root `/` è presente ciò che serve per avviare i container Docker a supporto del progetto.

Nella cartella `/backend` invece verrà creato il progetto Symfony.

L'obiettivo è quello di fornire uno strumento di supporto chi approccia Symfony (e magari Php)
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

> ATTENZIONE: Lo script `dc` copia il contenuto della cartalla `.ssh` dell'utente corrente nel container in modo che da dentro
al container ci si possa connettere via ssh con i server di stage e produzione identificandosi con le proprie chiavi.
Questo potrebbe non essere gradito se non se ne comprende le ragioni.

Ci troveremo dento il container nella cartella `/var/www/project/backend`.

Usciamo da `backend` e lanciamo `bin/create-project.sh` che non fa altro che creare il projetto Symfony 4.4
nella cartella `backend`.
```
cd ..
bin/create-project.sh
```

Symfony ci da da i consueti suggerimente so cosa fare successivamente.

Entriamo nella cartella `backend` e proviamo ad eseguire `sf`, un alias di `bin/console`
definito in questo container
```
cd backend
sf
```

Vedremo la consueta lista dei comandi disponibili.

Proviamo ad accedere dal browser impostando l'indirizzo `http://127.0.0.42` oppure `http://the-answer`.

Dovremmo vedere la consueta Welcome page di Symfony. 


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
