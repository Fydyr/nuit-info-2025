FROM node:20-alpine

# 1. Install system dependencies
# Added 'build-base', 'cmake', and 'python3' which are REQUIRED for node-llama-cpp
RUN apk add --no-cache \
    git \
    openssh-client \
    git-lfs \
    bash \
    build-base \
    cmake \
    python3

# 2. Set Working Directory (Removed the duplicate /usr/src/app)
WORKDIR /app

# 3. Install Node dependencies
# We do this before copying the full code to leverage Docker caching
COPY package*.json ./
RUN npm install

# 4. Copy the rest of the application code
COPY . .

# 5. Build the application
RUN npm run build

# 6. Setup environment and start
ENV NODE_ENV=production
EXPOSE 3000

CMD [ "node", ".output/server/index.mjs" ]