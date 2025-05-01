# Build React
FROM node:18 AS react-build
WORKDIR /app
COPY react-app/ /app/
RUN npm install
RUN npm run build

# Laravel and Apache
FROM php:8.2-apache
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && apt-get install -y \
    git unzip curl libzip-dev zip \
    && docker-php-ext-install pdo pdo_mysql zip

# Enable Apache Rewrite
RUN a2enmod rewrite

# Copy Laravel app
COPY laravel-app/ /var/www/html/

# Copy React build to Laravel public/
COPY --from=react-build /app/build/ /var/www/html/public/

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Laravel deps
RUN composer install

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Apache Config (optional custom .htaccess)
COPY laravel-app/.htaccess /var/www/html/public/.htaccess

# Expose port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
