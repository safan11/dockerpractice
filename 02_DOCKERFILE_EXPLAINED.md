# 🐳 Dockerfile — Complete Guide with Examples
### Line by line explanation for beginners
---

## What is a Dockerfile?

```
A Dockerfile is a plain text file (no extension, named exactly "Dockerfile")
that contains step-by-step instructions to build a Docker Image.

Think of it as:
  ● A recipe → Docker follows the steps to cook the image
  ● A script → Each line is an instruction Docker executes

Location: Put it in the ROOT of your project folder
  my-project/
    ├── Dockerfile        ← here
    ├── .dockerignore     ← here too
    ├── package.json
    └── src/
         └── app.js
```

---

## Every Dockerfile Instruction Explained

```dockerfile
# ── Comments start with #
# Docker ignores comment lines

# ──────────────────────────────────────────────────
# FROM  — REQUIRED, must be first instruction
# Sets the BASE IMAGE your image starts from
# ──────────────────────────────────────────────────
FROM node:18-alpine
# node:18-alpine means:
#   node      = Node.js runtime
#   18        = version 18
#   alpine    = based on Alpine Linux (very small, ~5MB)
#
# Other examples:
# FROM ubuntu:22.04       → Ubuntu OS
# FROM python:3.11-slim   → Python (slim = smaller version)
# FROM nginx:latest       → Nginx web server
# FROM scratch            → Completely empty (for tiny apps)

# ──────────────────────────────────────────────────
# LABEL  — Add metadata (optional but good practice)
# ──────────────────────────────────────────────────
LABEL maintainer="yourname@email.com"
LABEL version="1.0"
LABEL description="My Node.js Application"

# ──────────────────────────────────────────────────
# ARG  — Build-time variables (only during docker build)
# ──────────────────────────────────────────────────
ARG APP_VERSION=1.0
# Usage: docker build --build-arg APP_VERSION=2.0 .
# NOT available when container runs (use ENV for that)

# ──────────────────────────────────────────────────
# ENV  — Environment variables (available when container RUNS)
# ──────────────────────────────────────────────────
ENV NODE_ENV=production
ENV PORT=3000
ENV APP_NAME=MyApp
# Access in your code: process.env.NODE_ENV → "production"
# Can be overridden at runtime: docker run -e NODE_ENV=dev

# ──────────────────────────────────────────────────
# WORKDIR  — Set the working directory inside the container
# ──────────────────────────────────────────────────
WORKDIR /app
# All following commands (RUN, COPY, CMD) use this directory
# If the folder doesn't exist, Docker CREATES it automatically
# Best practice: use /app for applications

# ──────────────────────────────────────────────────
# COPY  — Copy files FROM host TO the image
# COPY <source-on-host> <destination-in-image>
# ──────────────────────────────────────────────────
COPY package.json ./
# Copy just package.json first (caching optimization)
# . means current WORKDIR (/app)

COPY package-lock.json ./
# Also copy the lockfile

# ──────────────────────────────────────────────────
# RUN  — Execute a command DURING BUILD
# Creates a new image layer
# Use for: install, compile, setup
# ──────────────────────────────────────────────────
RUN npm install --only=production
# Installs only production dependencies
# Runs ONCE during image build
# Result is SAVED in the image layer

# Chaining commands with && (creates one layer instead of many)
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ──────────────────────────────────────────────────
# COPY the rest of the code (AFTER npm install for caching!)
# ──────────────────────────────────────────────────
COPY . .
# Copy everything from current folder on host → /app in image
# .dockerignore controls what gets copied

# ──────────────────────────────────────────────────
# EXPOSE  — Document which port the app listens on
# NOTE: Does NOT actually open the port! Just documentation.
# Port is opened when you use: docker run -p 8080:3000
# ──────────────────────────────────────────────────
EXPOSE 3000

# ──────────────────────────────────────────────────
# USER  — Run the app as a non-root user (security!)
# ──────────────────────────────────────────────────
USER node
# Alpine node image has a built-in "node" user
# Running as root is a security risk in production

# ──────────────────────────────────────────────────
# CMD  — Default command to run when container STARTS
# Only ONE CMD per Dockerfile (last one wins)
# ──────────────────────────────────────────────────
CMD ["node", "src/app.js"]
# Array format (PREFERRED): ["executable", "arg1", "arg2"]
# Shell format: CMD node src/app.js  (also works)

# Difference: RUN vs CMD
# RUN → runs during IMAGE BUILD  (e.g., npm install)
# CMD → runs when CONTAINER STARTS (e.g., node app.js)

# ──────────────────────────────────────────────────
# ENTRYPOINT  — Like CMD but harder to override
# ──────────────────────────────────────────────────
# ENTRYPOINT ["node"]
# CMD ["app.js"]
# Together they run: node app.js
# ENTRYPOINT is the "fixed" part, CMD is the "default arguments"
```

---

## Example 1 — Simple Node.js App

### Project Structure:
```
my-node-app/
├── Dockerfile
├── .dockerignore
├── package.json
└── app.js
```

### app.js:
```javascript
const express = require('express')
const app = express()
const PORT = process.env.PORT || 3000

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Docker!',
    environment: process.env.NODE_ENV,
    port: PORT
  })
})

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`)
})
```

### package.json:
```json
{
  "name": "my-node-app",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

### Dockerfile:
```dockerfile
# Step 1: Choose base image
FROM node:18-alpine

# Step 2: Set working directory
WORKDIR /app

# Step 3: Copy package files FIRST (for Docker cache)
COPY package*.json ./

# Step 4: Install dependencies
RUN npm install

# Step 5: Copy the rest of the application
COPY . .

# Step 6: Expose the port
EXPOSE 3000

# Step 7: Start the app
CMD ["node", "app.js"]
```

### .dockerignore:
```
node_modules
npm-debug.log
.env
.git
*.md
```

### Commands to Build and Run:
```bash
# Build the image
docker build -t my-node-app .
# Output:
# [1/5] FROM node:18-alpine
# [2/5] WORKDIR /app
# [3/5] COPY package*.json ./
# [4/5] RUN npm install
# [5/5] COPY . .
# Successfully built abc123def456
# Successfully tagged my-node-app:latest

# Run the container
docker run -d -p 3000:3000 --name my-app my-node-app

# Test it
curl http://localhost:3000
# or open browser: http://localhost:3000

# See logs
docker logs my-app

# Output: Server running on port 3000
```

---

## Example 2 — React App (Production Build)

### Project Structure:
```
my-react-app/
├── Dockerfile
├── .dockerignore
├── nginx.conf
├── package.json
└── src/
     └── App.jsx
```

### Dockerfile (Multi-stage build):
```dockerfile
# ══════════════════════════════════════════
# STAGE 1: Build the React app
# This stage only runs during build — not in final image
# ══════════════════════════════════════════
FROM node:18-alpine AS builder
# "AS builder" gives this stage a name

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy source and build
COPY . .
RUN npm run build
# Creates /app/dist folder with the built React files

# ══════════════════════════════════════════
# STAGE 2: Serve with Nginx (production)
# Only THIS stage ends up in the final image
# ══════════════════════════════════════════
FROM nginx:alpine
# Start fresh with a tiny nginx image

# Copy the BUILT files from Stage 1 into nginx
COPY --from=builder /app/dist /usr/share/nginx/html
#          ↑
#     "from the builder stage"

# Optional: custom nginx config
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### Why Multi-Stage Builds?
```
Without multi-stage:
  Final image contains: node_modules + source code + build tools
  Size: ~900MB  ← huge!

With multi-stage:
  Stage 1 (builder): installs node, builds app, creates /dist
  Stage 2 (serve):   only copies the /dist files into nginx
  Final image contains: just nginx + built files
  Size: ~25MB  ← tiny!

Multi-stage = Smaller, Faster, More Secure images
```

### Build and Run:
```bash
docker build -t my-react-app .
docker run -d -p 8080:80 --name react-web my-react-app
# Open: http://localhost:8080
```

---

## Example 3 — Python Flask App

```dockerfile
FROM python:3.11-slim
# "slim" = smaller version of the image (no extra tools)

WORKDIR /app

# Install Python dependencies first (cache optimization)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# --no-cache-dir = don't cache pip downloads (smaller image)

# Copy application code
COPY . .

EXPOSE 5000

# Use gunicorn for production (not flask dev server)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```

---

## Understanding Docker Layer Caching

```
IMPORTANT CONCEPT — Docker builds layer by layer.
If a layer hasn't changed → Docker REUSES the cached layer (very fast!)
If a layer changes → that layer AND ALL LAYERS BELOW rebuild

❌ WRONG ORDER (slow rebuilds):
  COPY . .             ← any code change invalidates cache HERE
  RUN npm install      ← runs every time any file changes! Slow!

✅ CORRECT ORDER (fast rebuilds):
  COPY package.json .  ← only changes when deps change
  RUN npm install      ← CACHED unless package.json changed!
  COPY . .             ← code changes here, but npm install stays cached

VISUAL EXAMPLE:
  You change app.js:

  WRONG:                          CORRECT:
  FROM node:18      ✅ cached     FROM node:18          ✅ cached
  COPY . .          ❌ REBUILD    COPY package.json .   ✅ cached
  RUN npm install   ❌ REBUILD    RUN npm install       ✅ cached ← BIG WIN
                                  COPY . .              ❌ rebuild
                                  (only last layer runs!)
```

---

## Dockerfile Best Practices Summary

```
✅ DO:
  ✔ Use specific tags: FROM node:18-alpine  (not FROM node:latest)
  ✔ Use alpine images: smaller and more secure
  ✔ Copy package.json BEFORE source code (caching)
  ✔ Use .dockerignore to exclude node_modules, .git, .env
  ✔ Use multi-stage builds for production
  ✔ Run as non-root user (USER node)
  ✔ Chain RUN commands with && (fewer layers)

❌ DON'T:
  ✗ Use FROM ubuntu if FROM node:18-alpine is enough
  ✗ Copy .env files into the image (use -e flag or secrets)
  ✗ Install tools you don't need (keep image small)
  ✗ Run as root in production
  ✗ Use latest tag in production (breaks when new version releases)
  ✗ Put secrets/passwords in ENV in Dockerfile (visible in image!)
```

---

## Quick Comparison — Base Image Sizes

```
Image              Size        Use When
──────────────────────────────────────────────────────────
ubuntu:22.04       77 MB       Full Linux needed
debian:12          117 MB      Debian compatibility
node:18            994 MB      Full node install
node:18-slim       241 MB      Smaller, most tools available
node:18-alpine     134 MB      ✅ Smallest — use for most projects
python:3.11        1.01 GB     Full Python
python:3.11-slim   130 MB      ✅ Good for Python apps
python:3.11-alpine 51 MB       Smallest (sometimes incompatible)
nginx:latest       187 MB      Web server
nginx:alpine       42 MB       ✅ Best for static site serving
```
