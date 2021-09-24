FROM composer:latest as composer

WORKDIR /app
COPY . .
RUN composer install


FROM php:7.4-apache

WORKDIR /var/www/html/
RUN docker-php-ext-install mysqli
COPY --from=composer /app .
RUN cp config/apache/wordpress.conf /etc/apache2/sites-available/wordpress.conf && \
    a2dissite 000-default && a2ensite wordpress && \
    chown -R www-data:www-data /var/www/html/web

CMD ["apache2-foreground"]