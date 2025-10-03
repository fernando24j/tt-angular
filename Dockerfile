FROM node:20

WORKDIR /app

# Copiar todo el código fuente primero
COPY . .

# Instalar pnpm globalmente
RUN yarn global add pnpm

# Instalar todas las dependencias (incluyendo devDependencies)
RUN pnpm install --no-frozen-lockfile

# Build configuration parameters
ARG CONFIG=production
ENV CONFIG=$CONFIG

# Log the build configuration
RUN echo "Building Angular application with configuration: $CONFIG"

# Compilar la aplicación
RUN npm run build -- --configuration=$CONFIG

# Instalar nginx directamente en la misma imagen
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Copiar los archivos compilados a nginx
RUN cp -r /app/dist/my-conversation-trainer/browser/* /usr/share/nginx/html/

# Copiar configuraciones de nginx
COPY ./server2.conf /etc/nginx/conf.d/server2.conf
COPY ./http2.conf /etc/nginx/conf.d/http2.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]