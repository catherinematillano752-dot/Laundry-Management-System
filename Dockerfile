# Dockerfile - runs the Laundry Management System on Render (or any Docker host).
# PHP 8.2 + Apache with the mysqli extension. No application code is changed:
# the database login and SMS keys come from environment variables (see includes/db.php, includes/sms.php).
FROM php:8.2-apache

# mysqli is what includes/db.php uses to talk to MySQL.
RUN docker-php-ext-install mysqli

# includes/.htaccess needs AllowOverride, and mod_rewrite is handy for clean URLs.
RUN a2enmod rewrite \
 && sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

# Render tells the container which port to listen on through $PORT (default 10000).
# Apache listens on 80 out of the box, so switch it to $PORT when the container starts.
CMD ["sh", "-c", "PORT=${PORT:-10000}; sed -i \"s/Listen 80/Listen ${PORT}/\" /etc/apache2/ports.conf; sed -i \"s/<VirtualHost \\*:80>/<VirtualHost *:${PORT}>/\" /etc/apache2/sites-available/000-default.conf; exec apache2-foreground"]
