FROM ubuntu:22.04

# Si possono passare lo uid e lo gid dell'utente dell'host...
ARG HOST_UID=1000
ARG HOST_GID=1000

# L'installazione di git richiede interazione per inserire la timezone. La evitiamo preimpostandola
ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# installiamo quello che serve
RUN apt-get update && apt-get install -y \
    software-properties-common && \
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && \
    apt-get update && apt-get install -y \
    software-properties-common \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    curl \
    zip unzip \
    git \
    vim \
    iproute2 \
    wget \
    telnet \
    netcat \
    php8.2-fpm \
    php8.2-cli \
    php8.2-common \
    php8.2-mbstring \
    php8.2-gd \
    php8.2-intl \
    php8.2-ldap \
    php8.2-pgsql \
    php8.2-mysql \
    php8.2-sqlite3 \
    php8.2-opcache \
    php8.2-pspell \
    php8.2-snmp \
    php8.2-tidy \
    php8.2-zip \
    php8.2-xml \
    php8.2-bcmath \
    php8.2-xdebug \
    php8.2-curl \
    php8.2-amqp \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# creiamo la directory in cui fpm mette il suo pid (?)
RUN mkdir -p /run/php && \
# Sostituiamo www-data:www-data con user:user per fpm (?)
    sed -i "s/user = www-data/user = user/" /etc/php/8.2/fpm/pool.d/www.conf && \
    sed -i "s/group = www-data/group = user/" /etc/php/8.2/fpm/pool.d/www.conf && \
# Facciamo in modo che l'output emesso dai worker fpm sia intercettato (?)
    sed -i "s/;catch_workers_output = .*/catch_workers_output = yes/" /etc/php/8.2/fpm/pool.d/www.conf && \
# Mettiamo fpm in ascoto sulla porta 9000 anziché su una socket (?)
    sed -i "s/listen = .*/listen = 9000/" /etc/php/8.2/fpm/pool.d/www.conf && \
# Disabilitando l'opzione `daemonize` facciamo si che l'output di fpm venga sparato sullo stdout del container (?)
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/8.2/fpm/php-fpm.conf && \
# Impostiamo a 2 minuti il timeout delle connessioni ssh (?)
    echo "ServerAliveInterval 120" >> /etc/ssh/ssh_config

# Configuriamo il php.ini aggiungendo un'estensione custom
COPY conf/custom.ini /etc/php/8.2/mods-available/custom.ini
RUN phpenmod custom

# Configuro Xdebug
COPY conf/xdebug.ini /etc/php/8.2/mods-available/xdebug.ini
# Chiedo il l'ip del gateway con `ip route|awk '/default/ { print $3 }'` e lo imposto nell'xdebug.ini
RUN sed -i "s/xdebug\.client_host=.*/xdebug\.client_host=$(ip route|awk '/default/ { print $3 }')/" /etc/php/8.2/mods-available/xdebug.ini && \
    sed -i "s|zend_extension=xdebug.so|zend_extension=$(find /usr/lib/php/ -name xdebug.so)|" /etc/php/8.2/mods-available/xdebug.ini && \
# individio la posizione esatta di xdebug.so e la imposto nell'xdebug.ini
    sed -i "s|zend_extension=xdebug.so|zend_extension="/usr/lib/php/20220829/xdebug.so"|" /etc/php/8.2/mods-available/xdebug.ini
# `application` è l'aggregatore che insieme a `_` compare quando xdebug è attivo (?)
ENV PHP_IDE_CONFIG="serverName=application"

RUN phpenmod xdebug

# Installiamo composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Creiamo l'utente `user:user`
RUN mkdir /home/user && \
    groupadd -g $HOST_GID user && \
    useradd -u $HOST_UID --gid $HOST_GID -d /home/user -s /bin/bash user && \
#    usermod -a -G www-data user && \
    chown user /home/user

COPY --chown=user:user git/.gitconfig /home/user/

ENV HISTFILE=/home/user/history/.bash_history
RUN mkdir /home/user/history && touch /home/user/history/.bash_history

COPY --chown=user:user bash/.bash_aliases /home/user/.bash_aliases
RUN echo '. ~/.bash_aliases' >> /home/user/.bashrc

RUN chown -R user:user /home/user

WORKDIR /var/www/project/backend

# Nel command impostiamo alcune variabili d'ambiente contenute in .env che prima non erano disponibili,
# aggiorniamo composer ed infine lanciamo php-fpm
CMD sed -i "s/{{email}}/${GIT_USER_EMAIL}/" /home/user/.gitconfig && \
    sed -i "s/{{name}}/${GIT_USER_NAME}/" /home/user/.gitconfig && \
    /usr/local/bin/composer self-update && \
    php-fpm8.2

