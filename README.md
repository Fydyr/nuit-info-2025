# Nuit de l'Info 2025

Projet développé pour le concours national de la Nuit de l'Info 2025.

## Description

Application web interactive développée avec Nuxt 4, intégrant des fonctionnalités de santé, un chatbot IA basé sur Llama, et des mini-jeux interactifs.

## Technologies

- **Framework**: Nuxt 4 (Vue 3)
- **UI**: Nuxt UI
- **3D**: Three.js
- **IA**: node-llama-cpp (modèle Llama local)
- **Base de données**: Better-SQLite3
- **Image**: Nuxt Image
- **Utils**: VueUse

## Fonctionnalités

### Widget de Santé

- Formulaire de santé interactif
- Affichage des résultats avec analyse
- Système de recommandations personnalisées

### Chatbot IA

- Modèle Llama exécuté localement
- Réponses contextuelles sur la santé
- Interface conversationnelle

### Mini-jeux

- Jeu Snake classique
- Version Nokia 3310 du Snake
- Easter eggs cachés

### Autres

- Pages de mentions légales
- Footer personnalisé
- Composants réutilisables

## Installation

```bash
# Cloner le dépôt
git clone https://github.com/Fydyr/nuit-info-2025.git
cd nuit-info-2025

# Installer les dépendances
npm install

# Lancer le serveur de développement
npm run dev
```

## Scripts disponibles

```bash
npm run dev        # Démarre le serveur de développement
npm run build      # Build de production
npm run generate   # Génère un site statique
npm run preview    # Prévisualise le build de production
```

## Déploiement

### Docker

```bash
# Build de l'image
docker build -t nuit-info-2025 .

# Ou avec docker-compose
docker-compose up -d
```

### Script de déploiement

```bash
./deploy.sh
```

## Structure du projet

```text
nuit-info-2025/
├── app/
│   ├── components/        # Composants Vue réutilisables
│   │   ├── SanteFormulaire.vue
│   │   ├── SanteResultats.vue
│   │   ├── SanteWidget.vue
│   │   ├── chatbotComponent.vue
│   │   ├── snakeComponent.vue
│   │   └── ...
│   └── pages/            # Pages de l'application
│       ├── index.vue
│       └── mentions-legales.vue
├── server/
│   └── api/              # API endpoints
│       └── chat.post.ts  # Endpoint chatbot
├── public/               # Fichiers statiques
├── .data/               # Données locales (DB, modèles IA)
└── nuxt.config.ts       # Configuration Nuxt
```

## Configuration

Le projet utilise Nuxt 4 avec les modules suivants :

- `@nuxt/image` : Optimisation d'images
- `@nuxt/content` : Gestion de contenu
- `@nuxt/ui` : Composants UI
- `@vueuse/nuxt` : Utilitaires Vue

## Licence

ISC

## Auteurs

Équipe Nuit de l'Info 2025

## Liens

- [Dépôt GitHub](https://github.com/Fydyr/nuit-info-2025)
- [Issues](https://github.com/Fydyr/nuit-info-2025/issues)
