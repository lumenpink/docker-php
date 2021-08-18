FROM php:7-apache
# hadolint ignore=DL3008
RUN     apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libmagickwand-dev \
        libmagick++-dev \
        libpq-dev \
        locales \
        libicu-dev \
        git \
        libc-client-dev \
        libkrb5-dev \        
        libzip-dev \
        zip \
        unzip \
        gnupg \
        wget && \
        apt-get clean \
        && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen && \
        dpkg-reconfigure --frontend=noninteractive locales && \
        update-locale LANG=pt_BR.UTF-8
		
RUN wget http://pear.php.net/go-pear.phar && \
         php go-pear.phar && \
         rm go-pear.phar
		 
ENV LANG "pt_BR.UTF-8"

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install "-j$(nproc)" gd 
RUN docker-php-ext-configure imap --with-imap-ssl -with-kerberos
RUN docker-php-ext-install "-j$(nproc)" imap
RUN docker-php-ext-install "-j$(nproc)" iconv 
RUN docker-php-ext-install "-j$(nproc)" intl 
RUN docker-php-ext-install "-j$(nproc)" zip 
RUN docker-php-ext-install "-j$(nproc)" bcmath 
RUN docker-php-ext-install "-j$(nproc)" pdo 
RUN docker-php-ext-install "-j$(nproc)" pdo_mysql 
RUN docker-php-ext-install "-j$(nproc)" mysqli
RUN docker-php-ext-install "-j$(nproc)" opcache


RUN pecl install mailparse \
        && docker-php-ext-enable mailparse
RUN pecl install imagick-3.4.4 \
        && docker-php-ext-enable imagick
		
RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/ \
        && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

RUN a2enmod rewrite && a2enmod headers
SHELL ["/bin/bash", "-o", "pipefail", "-c"]   
