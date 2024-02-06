FROM php:7.4-cli

ARG GIT_TOKEN
ARG GIT_REPOSITORY
ARG ZIP_REPOSITORY

ENV GIT_TOKEN ${GIT_TOKEN}
ENV GIT_REPOSITORY  ${GIT_REPOSITORY}
ENV ZIP_REPOSITORY  ${ZIP_REPOSITORY}

# Обновление и установка необходимых пакетов, включая unzip и git
# Добавление установки расширения zip для PHP
RUN apt-get update && \
    apt-get install -y unzip git libzip-dev && \
    docker-php-ext-install zip

WORKDIR /app

# Установка Composer
RUN curl -s https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Разрешение работы Composer от root и установка satis
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer create-project composer/satis satis dev-main

ENV PATH "$PATH:/app/satis/bin"

COPY ./entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh"]
