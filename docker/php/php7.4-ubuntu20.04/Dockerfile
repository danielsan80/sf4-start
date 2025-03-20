FROM ubuntu:20.04

LABEL mantainer="danilo.sanchi@gmail.com"
# https://hub.docker.com/r/khanhicetea/php7-fpm-docker/dockerfile

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
    php7.4-fpm \
    php7.4-cli \
    php7.4-common \
    php7.4-json \
    php7.4-opcache \
    php7.4-mysql \
    php7.4-sqlite \
    php7.4-phpdbg \
    php7.4-mbstring \
    php7.4-gd \
    php7.4-imap \
    php7.4-ldap \
    php7.4-pgsql \
    php7.4-pspell \
    php7.4-snmp \
    php7.4-tidy \
    php7.4-dev \
    php7.4-intl \
    php7.4-curl \
    php7.4-zip \
    php7.4-xml \
    php7.4-dom \
    php7.4-bcmath \
    php7.4-xdebug \
    vim \
    git \
    curl \
    zip unzip \
    iproute2 \
    mcrypt \
    rsync \
    wget \
    telnet \
    netcat \
    && \
    apt-get remove --purge -y software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# creiamo la directory in cui fpm mette il suo pid (?)
RUN mkdir -p /run/php && \
# Sostituiamo www-data:www-data con user:user per fpm (?)
    sed -i "s/user = www-data/user = user/" /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i "s/group = www-data/group = user/" /etc/php/7.4/fpm/pool.d/www.conf && \
# Facciamo in modo che l'output emesso dai worker fpm sia intercettato (?)
    sed -i "s/;catch_workers_output = .*/catch_workers_output = yes/" /etc/php/7.4/fpm/pool.d/www.conf && \
#    sed -i -e "s/pid =.*/pid = \/var\/run\/php7.4-fpm.pid/" /etc/php/7.4/fpm/php-fpm.conf && \
#    sed -i -e "s/error_log =.*/error_log = \/proc\/self\/fd\/2/" /etc/php/7.4/fpm/php-fpm.conf && \
# Mettiamo fpm in ascoto sulla porta 9000 anziché su una socket (?)
    sed -i "s/listen = .*/listen = 9000/" /etc/php/7.4/fpm/pool.d/www.conf && \
# Disabilitando l'opzione `daemonize` facciamo si che l'output di fpm venga sparato sullo stdout del container (?)
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.4/fpm/php-fpm.conf && \
# Impostiamo a 2 minuti il timeout delle connessioni ssh (?)
    echo "ServerAliveInterval 120" >> /etc/ssh/ssh_config

# Configuriamo il php.ini aggiungendo un'estensione custom
COPY conf/custom.ini /etc/php/7.4/mods-available/custom.ini
RUN phpenmod custom

# Configuro Xdebug
COPY conf/xdebug.ini /etc/php/7.4/mods-available/xdebug.ini
# Chiedo il l'ip del gateway con `ip route|awk '/default/ { print $3 }'` e lo imposto nell'xdebug.ini
RUN sed -i "s/xdebug\.client_host=.*/xdebug\.client_host="$(ip route|awk '/default/ { print $3 }')"/" /etc/php/7.4/mods-available/xdebug.ini && \
# individio la posizione esatta di xdebug.so e la imposto nell'xdebug.ini
    sed -i "s|zend_extension=xdebug.so|zend_extension="/usr/lib/php/20190902/xdebug.so"|" /etc/php/7.4/mods-available/xdebug.ini
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
    php-fpm7.4

