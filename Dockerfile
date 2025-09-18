FROM nginx:stable-alpine

# Créer un utilisateur non-root
RUN addgroup -g 1000 appgroup && adduser -D -u 1000 -G appgroup appuser

# Préparer les répertoires nécessaires et donner les droits
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx /tmp \
    && chown -R 1000:1000 /var/cache/nginx /var/run /var/log/nginx /tmp

# Copier la configuration Nginx et donner les droits
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
RUN chown 1000:1000 /etc/nginx/conf.d/default.conf

# Copier les fichiers du site
COPY nginx/html /usr/share/nginx/html
RUN chown -R 1000:1000 /usr/share/nginx/html

# Exposer le port HTTP
EXPOSE 80

# Utiliser l’utilisateur non-root
USER 1000

CMD ["nginx", "-g", "daemon off;"]
