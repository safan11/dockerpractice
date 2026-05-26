# 🐳 Docker — Complete Beginner Notes
### "Learn Docker from Scratch — Simple & Easy"
---

## 1. What is Docker? (The Real Problem It Solves)

### The Classic Problem — "It works on my machine!"
```
Developer's laptop:         Test Server:           Production Server:
Node v18                    Node v14               Node v16
MongoDB v6                  MongoDB v4             MongoDB v5
Windows OS                  Ubuntu OS              CentOS OS

App works ✅                App crashes ❌          App crashes ❌
```

> Every machine has different versions of software, OS, libraries.
> The app behaves differently on different machines.
> This is a nightmare for teams.

### The Docker Solution
```
Developer's laptop:         Test Server:           Production Server:
┌─────────────────┐         ┌─────────────────┐   ┌─────────────────┐
│   CONTAINER     │         │   CONTAINER     │   │   CONTAINER     │
│  Node v18       │  =====  │  Node v18       │ = │  Node v18       │
│  MongoDB v6     │  Same!  │  MongoDB v6     │   │  MongoDB v6     │
│  Ubuntu         │         │  Ubuntu         │   │  Ubuntu         │
└─────────────────┘         └─────────────────┘   └─────────────────┘

App works ✅                  App works ✅            App works ✅
```

> Docker packages your app + ALL its dependencies into a single box (container).
> That box runs the same way EVERYWHERE.

---

## 2. Simple Analogies to Understand Docker

### Analogy 1 — Shipping Container 🚢
```
Before containers (shipping):
- Each item (sofa, TV, bike) loaded separately
- Different ships need different loading methods
- Items get damaged or lost

After containers (shipping):
- Everything packed in a standard steel box
- Every ship, truck, crane handles the same box
- Consistent, reliable transport

Docker is exactly the same — but for software.
Your app is packed in a standard box (container).
Every computer (server, cloud, laptop) runs it the same way.
```

### Analogy 2 — Recipe vs Cooked Meal 🍕
```
Docker IMAGE   = Recipe (instructions, ingredients list)
               → Doesn't change, can be shared, stored, copied

Docker CONTAINER = Cooked Meal (running, alive)
               → Made FROM the recipe, you can eat it, modify it

One recipe (Image) → Many meals (Containers)
```

### Analogy 3 — Class vs Object (for developers)
```
Image     = Class      (blueprint, template, inactive)
Container = Object     (instance, running, alive)

new Container(Image)  →  creates a running container from an image
```

---

## 3. Docker Architecture (How It Works Inside)

```
┌───────────────────────────────────────────────────────────────┐
│                    YOUR COMPUTER (Host OS)                     │
│                                                               │
│   ┌─────────────────────────────────────────────────────┐    │
│   │              DOCKER ENGINE (the brain)              │    │
│   │                                                     │    │
│   │  ┌────────────────┐    ┌────────────────────────┐   │    │
│   │  │  Docker Daemon │    │   Docker CLI           │   │    │
│   │  │  (background   │◄───│   (you type commands   │   │    │
│   │  │   service)     │    │    in terminal)        │   │    │
│   │  └────────────────┘    └────────────────────────┘   │    │
│   │          │                                          │    │
│   │          ▼                                          │    │
│   │  ┌───────────────────────────────────────────┐      │    │
│   │  │          CONTAINERS (running apps)        │      │    │
│   │  │                                           │      │    │
│   │  │  ┌──────────────┐  ┌──────────────┐      │      │    │
│   │  │  │ Container 1  │  │ Container 2  │      │      │    │
│   │  │  │  My App      │  │  Database    │      │      │    │
│   │  │  │  Node.js     │  │  MongoDB     │      │      │    │
│   │  │  └──────────────┘  └──────────────┘      │      │    │
│   │  └───────────────────────────────────────────┘      │    │
│   └─────────────────────────────────────────────────────┘    │
│                                                               │
│   ┌────────────────────────────────────────────────────┐     │
│   │              DOCKER HUB (Internet)                 │     │
│   │  Free registry — stores & shares images            │     │
│   │  hub.docker.com  →  like GitHub but for images     │     │
│   └────────────────────────────────────────────────────┘     │
└───────────────────────────────────────────────────────────────┘
```

### 4 Main Components:

| Component | What It Is | Real World |
|-----------|-----------|------------|
| **Docker Engine** | The software that runs Docker | Like a car engine |
| **Image** | Blueprint/template (read-only) | Recipe |
| **Container** | Running instance of an image | Cooked meal |
| **Docker Hub** | Online store for images | App Store / GitHub |

---

## 4. Key Concepts Explained Simply

### 4.1 Docker Image
```
- A Docker Image is a READ-ONLY template
- Contains: OS layer + app code + dependencies + config
- Like a ZIP file of everything your app needs
- Stored locally or on Docker Hub
- You don't "run" an image — you CREATE a container from it

Example images (free on Docker Hub):
  ubuntu        → Ubuntu Linux OS
  node:18       → Node.js v18
  nginx         → Web server
  mongo         → MongoDB database
  postgres      → PostgreSQL database
  redis         → Redis cache
```

### 4.2 Docker Container
```
- A Container is a RUNNING instance of an image
- It is isolated from your computer
- Has its own: filesystem, network, process space
- Lightweight — shares the HOST OS kernel (not a full VM)
- You can RUN, STOP, START, DELETE containers
- Multiple containers can run from the same image

One Image → Many Containers:
  node:18 image → Container A (my-app)
               → Container B (test-app)
               → Container C (staging-app)
```

### 4.3 Dockerfile
```
- A plain text file named "Dockerfile" (no extension)
- Contains step-by-step instructions to BUILD an image
- Like a recipe card — Docker reads it top to bottom
- Once built, the image is reusable

Example Dockerfile:
  FROM node:18          ← start from this base image
  WORKDIR /app          ← set the working folder
  COPY . .              ← copy your code into the image
  RUN npm install       ← install dependencies
  EXPOSE 3000           ← declare the port
  CMD ["node","app.js"] ← command to start the app
```

### 4.4 Docker Hub / Registry
```
- Docker Hub = the "App Store" for Docker images
- Website: https://hub.docker.com
- Pull (download) ready-made images: nginx, node, postgres
- Push (upload) your own images to share

Types of registries:
  Docker Hub (hub.docker.com)  → public, free
  AWS ECR                       → private, on AWS
  Google GCR                    → private, on Google Cloud
  GitHub Container Registry     → private, on GitHub
```

### 4.5 Volume
```
- Containers are STATELESS by default
- When a container stops → ALL data inside is LOST
- Volume = a folder on your HOST machine linked to the container
- Data in the volume PERSISTS even when the container stops

Container without volume:        Container WITH volume:
  Stop container → data lost ❌     Stop container → data saved ✅

Use case:
  Database container (MongoDB) MUST use a volume
  so your data doesn't disappear when the container restarts.
```

### 4.6 Port Mapping
```
- Container runs on its OWN internal network
- By default, you CANNOT access it from your browser
- Port mapping connects a HOST port to a CONTAINER port

Syntax: -p HOST_PORT:CONTAINER_PORT

Example:
  docker run -p 8080:3000 my-app

  Your browser → localhost:8080
                     ↓ (port mapping)
                 Container → port 3000

Think of it like:
  Your house (host) has door number 8080
  The room inside (container) has door number 3000
  The mapping connects them
```

### 4.7 Docker Compose
```
- Real apps need MULTIPLE containers working together
  (App + Database + Cache + Message Queue)
- Starting them one by one is painful
- Docker Compose lets you define ALL containers in ONE file
  (docker-compose.yml)
- One command starts / stops them all together

Without Compose:
  docker run ... my-app
  docker run ... mongodb
  docker run ... redis
  (manage 3 commands, 3 networks, 3 configs)

With Compose:
  docker compose up   ← ONE command starts everything!
  docker compose down ← ONE command stops everything!
```

---

## 5. Container vs Virtual Machine

```
VIRTUAL MACHINE (VM):                DOCKER CONTAINER:
┌──────────────────────┐             ┌──────────────────────┐
│  App                 │             │  App                 │
│  Libraries           │             │  Libraries           │
│  Guest OS (full!)    │             │  NO Guest OS ✓       │
│  (Ubuntu, Windows..) │             │  (uses Host OS)      │
│  Hypervisor          │             │  Docker Engine       │
│  Host OS             │             │  Host OS             │
└──────────────────────┘             └──────────────────────┘

Size:    GBs (includes full OS)       MBs (no full OS)
Boot:    Minutes                      Seconds
Speed:   Slower                       Fast
Isolation: Full (hardware level)      Process level
```

| Feature | Virtual Machine | Docker Container |
|---------|----------------|-----------------|
| Size | 1–20 GB | 50–500 MB |
| Startup | 1–5 minutes | 1–5 seconds |
| OS | Full guest OS | Shares host OS kernel |
| Performance | Slower | Near-native speed |
| Isolation | Strong | Good |
| Best for | Full OS isolation | App packaging & deployment |

> Rule of thumb: Use Docker for most cases. Use VMs when you need a completely separate OS.

---

## 6. Docker Installation

### Windows:
```
1. Download Docker Desktop from https://www.docker.com/products/docker-desktop
2. Run the installer
3. Restart your computer
4. Open terminal and type: docker --version
```

### Mac:
```
1. Download Docker Desktop for Mac (Apple Silicon or Intel)
2. Drag to Applications
3. Open Docker Desktop
4. Verify: docker --version
```

### Ubuntu/Linux:
```bash
sudo apt-get update
sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER   # run docker without sudo
docker --version                # verify
```

### Verify Installation:
```bash
docker --version
# Output: Docker version 24.0.5, build ced0996

docker run hello-world
# This pulls and runs a test container — if it prints "Hello from Docker!" it works!
```

---

## 7. Most Important Docker Commands

### 7.1 Image Commands
```bash
# Pull an image from Docker Hub (download)
docker pull nginx
docker pull node:18
docker pull ubuntu:22.04

# List all images on your computer
docker images
# or
docker image ls

# Remove an image
docker rmi nginx
docker image rm nginx

# Search for images on Docker Hub
docker search nginx

# Build an image from a Dockerfile
# -t = tag (give it a name)   . = build from current folder
docker build -t my-app .
docker build -t my-app:v1.0 .
```

### 7.2 Container Commands
```bash
# Run a container from an image
docker run nginx

# Run in DETACHED mode (background, doesn't block terminal)
docker run -d nginx

# Run with PORT MAPPING
docker run -d -p 8080:80 nginx
#                 ↑   ↑
#            host port  container port

# Run with a NAME (easier to manage)
docker run -d -p 8080:80 --name my-web nginx

# Run interactively (get a terminal inside)
docker run -it ubuntu bash
#           ↑↑
#         interactive + terminal

# Run and auto-remove when stopped
docker run --rm nginx

# List RUNNING containers
docker ps

# List ALL containers (including stopped)
docker ps -a
docker ps --all

# Stop a container
docker stop my-web
docker stop <container-id>

# Start a stopped container
docker start my-web

# Restart a container
docker restart my-web

# Delete a container (must be stopped first)
docker rm my-web

# Force delete a running container
docker rm -f my-web

# Delete ALL stopped containers
docker container prune
```

### 7.3 Logs & Inspect Commands
```bash
# See logs of a container (what it printed)
docker logs my-web

# Follow logs in real-time (like tail -f)
docker logs -f my-web

# Get details about a container (IP, config, mounts, etc.)
docker inspect my-web

# See resource usage (CPU, memory, network)
docker stats

# See running processes inside a container
docker top my-web
```

### 7.4 Execute Commands Inside Container
```bash
# Run a command inside a RUNNING container
docker exec my-web ls /etc/nginx

# Open an interactive terminal INSIDE a running container
docker exec -it my-web bash
docker exec -it my-web sh    # use sh if bash is not available

# Once inside, you can:
ls           # list files
cat app.js   # read a file
env          # see environment variables
exit         # leave the container
```

### 7.5 Volume Commands
```bash
# Create a named volume
docker volume create my-data

# List volumes
docker volume ls

# Run container WITH a volume attached
docker run -d \
  -v my-data:/data/db \   # volume_name:container_path
  --name my-mongo \
  mongo

# Mount a HOST FOLDER into a container (bind mount)
docker run -d \
  -v /home/user/myapp:/app \   # host_path:container_path
  node:18

# Remove a volume
docker volume rm my-data

# Remove unused volumes
docker volume prune
```

### 7.6 Network Commands
```bash
# List networks
docker network ls

# Create a custom network (containers on the same network can talk)
docker network create my-network

# Run container ON a network
docker run -d --network my-network --name app node:18
docker run -d --network my-network --name db  mongo

# Now "app" container can reach "db" container by name "db"
# No need for IP addresses!

# Inspect a network
docker network inspect my-network
```

### 7.7 System Cleanup Commands
```bash
# Remove ALL stopped containers, unused images, networks, cache
# (The big cleanup — use carefully)
docker system prune

# See disk usage
docker system df

# Remove all unused images
docker image prune -a

# Remove all stopped containers
docker container prune
```

---

## 8. Dockerfile Instructions Explained

```dockerfile
# Every Dockerfile starts with FROM — the base image
FROM node:18-alpine
# node:18     = Node.js version 18
# alpine      = super small Linux (alpine Linux ~5MB vs ubuntu ~72MB)

# LABEL adds metadata (optional, good practice)
LABEL author="YourName" version="1.0"

# Set environment variables inside the container
ENV NODE_ENV=production
ENV PORT=3000

# WORKDIR sets the working directory inside the container
# All following commands run FROM this directory
WORKDIR /app

# COPY source destination
# Copy package.json FIRST (optimization — Docker caches this layer)
COPY package*.json ./

# RUN executes a command DURING BUILD (not at runtime)
# Use for installing dependencies, building, compiling
RUN npm install --only=production

# Copy the rest of your application code
COPY . .

# EXPOSE documents which port the app uses
# (Does NOT actually open the port — that's done with -p flag)
EXPOSE 3000

# The default command to run when the container STARTS
# Only ONE CMD allowed per Dockerfile
CMD ["node", "server.js"]

# Difference between RUN and CMD:
# RUN   → executes during IMAGE BUILD
# CMD   → executes when CONTAINER STARTS
```

---

## 9. The .dockerignore File

```
# .dockerignore (works exactly like .gitignore)
# Tells Docker what NOT to copy into the image

node_modules    ← don't copy — reinstall inside container
.git            ← git history not needed
.env            ← don't copy secrets!
*.log           ← log files not needed
README.md       ← docs not needed
Dockerfile      ← don't copy the Dockerfile itself

Why this matters:
- Smaller image size
- Faster build time
- Don't accidentally expose .env secrets
```

---

## 10. docker-compose.yml Explained

```yaml
# docker-compose.yml
version: "3.9"          # compose file version

services:               # define each container as a "service"

  # SERVICE 1: Your Node.js app
  app:
    build: .            # build from the Dockerfile in current folder
    ports:
      - "3000:3000"     # host:container port
    environment:
      - NODE_ENV=development
      - MONGO_URL=mongodb://db:27017/myapp
    depends_on:
      - db              # wait for db to start first
    volumes:
      - .:/app          # live reload: mount current folder

  # SERVICE 2: MongoDB database
  db:
    image: mongo:6      # use official mongo image (no Dockerfile needed)
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db   # persist database data

  # SERVICE 3: Redis cache
  cache:
    image: redis:7
    ports:
      - "6379:6379"

volumes:               # declare named volumes
  mongo-data:          # Docker will manage this volume
```

### docker-compose Commands:
```bash
docker compose up          # start all services (foreground)
docker compose up -d       # start all services (background)
docker compose down        # stop and remove all containers
docker compose down -v     # also delete volumes (DATA DELETED!)
docker compose logs        # see logs from all services
docker compose logs app    # logs from one service
docker compose ps          # list running services
docker compose build       # rebuild images
docker compose restart app # restart one service
docker compose exec app sh # open terminal in a service
```

---

## 11. Image Layers — How Docker Builds Efficiently

```
A Docker Image is made of LAYERS (like an onion)

FROM ubuntu:22.04     ← Layer 1: base OS
RUN apt-get update    ← Layer 2: packages updated
RUN apt-get install   ← Layer 3: packages installed
COPY . /app           ← Layer 4: your code
RUN npm install       ← Layer 5: node_modules

Each layer is CACHED.
If Layer 1-4 didn't change → Docker REUSES the cached layers
Only the changed layer (and layers after it) are rebuilt.

SLOW (no caching):
  COPY . .              ← copies everything (code changes often)
  RUN npm install       ← package install runs EVERY time code changes!

FAST (optimized order):
  COPY package.json .   ← copy package.json FIRST
  RUN npm install       ← install (cached — only reruns if package.json changes)
  COPY . .              ← copy rest of code (doesn't break the install cache)
```

---

## 12. Real-World Docker Workflow

```
DEVELOPER WORKFLOW:
═══════════════════════════════════════════════════════════════
Step 1: Write your app (Node.js, React, Python, etc.)
Step 2: Write a Dockerfile
Step 3: Write .dockerignore
Step 4: docker build -t my-app .   ← build the image
Step 5: docker run -p 3000:3000 my-app  ← test locally
Step 6: docker push my-app         ← push to Docker Hub / registry
Step 7: On the server: docker pull my-app  ← download
Step 8: On the server: docker run my-app   ← run!
═══════════════════════════════════════════════════════════════

TEAM WORKFLOW WITH COMPOSE:
═══════════════════════════════════════════════════════════════
Step 1: Clone the project
Step 2: docker compose up
Step 3: App + Database + Cache all run immediately ✅
        No "install mongo" or "install node" needed
═══════════════════════════════════════════════════════════════
```

---

## 13. Useful Flags Quick Reference

```
docker run FLAGS:
─────────────────────────────────────────────────────────
Flag              Meaning                Example
─────────────────────────────────────────────────────────
-d                Run in background      docker run -d nginx
-p HOST:CONT      Port mapping           docker run -p 8080:80 nginx
--name NAME       Give a name            docker run --name web nginx
-it               Interactive terminal   docker run -it ubuntu bash
-e KEY=VALUE      Set env variable       docker run -e NODE_ENV=prod node
-v HOST:CONT      Mount volume           docker run -v /data:/app/data node
--rm              Auto-remove on stop    docker run --rm ubuntu echo hi
--network NAME    Join a network         docker run --network mynet node
--restart=always  Auto-restart           docker run --restart=always nginx
─────────────────────────────────────────────────────────
```

---

## 14. Docker Networking — How Containers Talk to Each Other

```
By default, containers are ISOLATED (can't talk to each other)
To let containers talk, put them on the SAME NETWORK

TYPES OF NETWORKS:
──────────────────────────────────────────────────────────
bridge  → Default. Containers on same bridge can talk by name
host    → Container uses the HOST's network directly
none    → No network (fully isolated)
overlay → Multi-host networking (for Docker Swarm/Kubernetes)
──────────────────────────────────────────────────────────

EXAMPLE: App container talking to DB container
  docker network create mynet
  docker run -d --network mynet --name db     mongo
  docker run -d --network mynet --name app    my-node-app

  Inside app container:
  MONGO_URL = "mongodb://db:27017"
                         ↑
              Use container NAME, not IP address!
              Docker automatically resolves the name to the right IP.
```

---

## 15. Common Mistakes & Fixes

| Mistake | Fix |
|---------|-----|
| Container won't start — port already in use | Change host port: `-p 8081:80` instead of `-p 8080:80` |
| Data disappears after container restart | Use a Volume: `-v my-data:/data` |
| Image is huge (500MB+) | Use Alpine base: `FROM node:18-alpine` |
| Slow rebuilds | Optimize Dockerfile: copy `package.json` BEFORE source code |
| `.env` file exposed | Add `.env` to `.dockerignore` |
| Can't connect to container | Check port mapping: `-p host:container` |
| Container exits immediately | Check logs: `docker logs <name>` |
| "Permission denied" on Linux | Add user to docker group: `sudo usermod -aG docker $USER` |
| Container can't reach DB | Both must be on the same Docker network |
| Build fails on `npm install` | Check you `COPY package.json` BEFORE `RUN npm install` |

---

## 16. Summary — The Big Picture

```
╔══════════════════════════════════════════════════════════════╗
║                    DOCKER IN ONE PAGE                        ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  Dockerfile    → Instructions to build an Image             ║
║  Image         → Snapshot / Blueprint (inactive)            ║
║  Container     → Running instance of Image (active)         ║
║  Docker Hub    → Online store for Images                     ║
║  Volume        → Persistent storage for containers          ║
║  Network       → How containers communicate                  ║
║  Compose       → Run multiple containers with one command   ║
║                                                              ║
║  KEY COMMANDS:                                               ║
║  docker build -t name .    → Create image from Dockerfile   ║
║  docker run -d -p 8080:80  → Start a container              ║
║  docker ps                 → List running containers         ║
║  docker stop name          → Stop a container                ║
║  docker logs name          → See container output           ║
║  docker exec -it name sh   → Open terminal in container     ║
║  docker compose up -d      → Start all services             ║
║  docker compose down       → Stop all services              ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```
