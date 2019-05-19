FROM wordpress:php7.1-apache

MAINTAINER "KarimFadl" <kareemfadl10@gmail.com>

COPY code/ /var/www/html

RUN chown -R www-data:www-data /var/www/html
