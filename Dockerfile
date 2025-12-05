FROM node:20-alpine AS base

# Installer git et openssh-client pour pouvoir cloner des repos privés si nécessaire
RUN apk add --no-cache git openssh-client git-lfs bash

WORKDIR /app

# Étape 1 : Installation des dépendances
FROM base AS deps
COPY package*.json ./
RUN npm install

# Étape 2 : Build de l'application Nuxt
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Variable d'environnement pour la production
ENV NODE_ENV=production

# Build de l'application Nuxt
RUN npm run build

# Étape 3 : Image de production
FROM base AS runner
ENV NODE_ENV=production

# Copier uniquement les fichiers nécessaires pour la production
COPY --from=builder /app/.output /app/.output
COPY --from=builder /app/package*.json ./

# Exposer le port
EXPOSE 3000

# Lancer l'application Nuxt en mode production
CMD ["node", ".output/server/index.mjs"]