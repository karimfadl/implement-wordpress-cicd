FROM centos:latest

MAINTAINER "KarimFadl" <kareemfadl10@gmail.com>

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
 && rpm -Uvh https://rpms.remirepo.net/enterprise/remi-release-7.rpm

# normal updates
RUN yum -y update

# tools
RUN yum -y install epel-release iproute at curl crontabs git vim net-tools python-pip

# Install Nginx
RUN yum -y install nginx

# Install PHP 7
RUN yum --enablerepo=remi,remi-php70 install php-opcache php-pecl-apcu php-cli php-pear php-pdo php-mysqlnd php-pgsql php-pecl-mongodb php-pecl-redis php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml php-fpm -y

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Config standard error to be the error log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
RUN ln -sf /dev/stderr /var/log/php-fpm/error.log

# Install supervisor
RUN yum -y install supervisor
RUN pip install supervisor-stdout
COPY ./config/supervisord.conf /etc/supervisord.conf

#RUN sed -i 's/^listen.allowed_clients/;listen.allowed_clients/' /etc/php-fpm.d/www.conf && \
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php-fpm.conf

RUN mkdir -p /var/www/html && \
    mkdir -p /var/run/php-fpm && \
    chown -R nginx:nginx /var/www/html && \
    chown -R nginx:nginx /var/run/php-fpm

#RUN Nginx and PHP-FPM
COPY ./config/v-host.conf /etc/nginx/conf.d/default.conf
COPY ./config/nginx.conf /etc/nginx/
COPY ./config/www.conf /etc/php-fpm.d/www.conf

#Copy Source Code To Root Dir
COPY wordpress/ /var/www/html/

EXPOSE 80

# Nginx worker_processes equal to number of cores
CMD ['sed -i "s/worker_processes.*/worker_processes `cat /proc/cpuinfo |grep processor|wc -l`;/" /etc/nginx/nginx.conf']

# try to run nginx
CMD ["/usr/bin/supervisord", "-n"]
