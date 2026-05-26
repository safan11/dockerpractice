# 🐳 Docker Commands Cheatsheet
### Every command you need — with real output examples
---

## ── SECTION 1: FIRST COMMANDS TO RUN (Verify Installation) ──

```bash
# Check Docker is installed
docker --version
# Output: Docker version 24.0.5, build ced0996

# Check Docker is running
docker info
# Output: lots of info about your Docker setup

# The "Hello World" of Docker — tests everything works
docker run hello-world
# Output:
# Hello from Docker!
# This message shows that your installation appears to be working correctly.
```

---

## ── SECTION 2: IMAGE COMMANDS ──

### Pull (Download) an Image
```bash
docker pull nginx
# Downloads the latest nginx image from Docker Hub
# Output:
# Using default tag: latest
# latest: Pulling from library/nginx
# 3.7 MB pulled ✓

docker pull node:18
# Download Node.js version 18 image

docker pull ubuntu:22.04
# Download Ubuntu 22.04 image (specific version)

docker pull mongo:6.0
# Download MongoDB version 6.0
```

### List Images
```bash
docker images
# or
docker image ls

# Output:
# REPOSITORY    TAG       IMAGE ID       CREATED        SIZE
# nginx         latest    a99a39d070bf   2 weeks ago    142MB
# node          18        7220a7b71f5e   3 weeks ago    994MB
# ubuntu        22.04     3b418d7b466a   4 weeks ago    77.8MB
# hello-world   latest    9c7a54a9a43c   2 months ago   13.3kB
```

### Search for Images
```bash
docker search nginx
# Shows list of nginx images on Docker Hub

docker search --filter is-official=true node
# Shows only OFFICIAL node images (safe to use)
```

### Remove an Image
```bash
docker rmi nginx
# Remove one image by name

docker rmi a99a39d070bf
# Remove by IMAGE ID

docker rmi nginx node:18
# Remove multiple images at once

docker image prune
# Remove all UNUSED (dangling) images

docker image prune -a
# Remove ALL unused images (not just dangling)
```

### Build an Image from Dockerfile
```bash
# Must be in the folder that has the Dockerfile
docker build -t my-app .
#             ↑         ↑
#          tag name  build context (current folder)

docker build -t my-app:1.0 .
# Tag with version number

docker build -t my-app:latest -f Dockerfile.prod .
# -f = use a specific Dockerfile name

# Output:
# [1/4] FROM node:18-alpine
# [2/4] COPY package.json .
# [3/4] RUN npm install
# [4/4] COPY . .
# Successfully built a1b2c3d4e5f6
# Successfully tagged my-app:latest
```

---

## ── SECTION 3: CONTAINER RUN COMMANDS ──

### Basic Run
```bash
docker run nginx
# Runs nginx — BUT blocks your terminal (foreground mode)
# Press Ctrl+C to stop
```

### Run in Background (Detached Mode) — most common
```bash
docker run -d nginx
# -d = detached (background)
# Output: f3a1b2c3d4e5 (container ID)
# Terminal is free to use again ✅
```

### Run with Port Mapping
```bash
docker run -d -p 8080:80 nginx
# Your browser: localhost:8080 → nginx port 80

docker run -d -p 3000:3000 node-app
# localhost:3000 → container port 3000

docker run -d -p 5432:5432 postgres
# localhost:5432 → postgres default port
```

### Run with a Name
```bash
docker run -d -p 8080:80 --name my-website nginx
# Now use "my-website" instead of container ID

docker run -d --name my-database mongo
```

### Run Interactively (get terminal inside)
```bash
docker run -it ubuntu bash
# -i = interactive   -t = terminal (tty)
# You are now INSIDE the ubuntu container!
# root@abc123:/# ls
# root@abc123:/# apt-get install curl
# root@abc123:/# exit   ← leave the container

docker run -it node:18 sh
# Open sh (shell) inside node container (alpine uses sh not bash)

docker run -it --rm ubuntu bash
# --rm = automatically REMOVE container when you exit
```

### Run with Environment Variables
```bash
docker run -d \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=mydb \
  --name my-postgres \
  postgres

docker run -d \
  -e NODE_ENV=production \
  -e PORT=3000 \
  my-app
```

### Run with Volume (Persistent Storage)
```bash
# Named volume (Docker manages the folder location)
docker run -d \
  -v my-mongo-data:/data/db \
  --name my-mongo \
  mongo

# Bind Mount (you choose the folder on your host)
docker run -d \
  -v /home/user/myapp:/app \
  --name my-app \
  node:18

# Read-only bind mount
docker run -d \
  -v /home/user/config:/app/config:ro \
  my-app
```

### Auto-Restart Policy
```bash
docker run -d --restart=always nginx
# Restarts automatically if it crashes or host reboots

# Options:
# --restart=no           → never restart (default)
# --restart=always       → always restart
# --restart=on-failure   → restart only if exit code != 0
# --restart=unless-stopped → restart unless manually stopped
```

---

## ── SECTION 4: MANAGING CONTAINERS ──

### List Containers
```bash
docker ps
# Lists RUNNING containers only
# Output:
# CONTAINER ID  IMAGE   COMMAND             STATUS          PORTS                  NAMES
# f3a1b2c3d4e5  nginx   "/docker-entrypo…"  Up 2 minutes    0.0.0.0:8080->80/tcp   my-website

docker ps -a
# Lists ALL containers (running + stopped)

docker ps -q
# Lists only container IDs (quiet mode — useful in scripts)

docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
# Custom formatted output
```

### Stop / Start / Restart
```bash
docker stop my-website
# Sends SIGTERM signal — graceful shutdown (waits up to 10 sec)

docker stop my-website --time 30
# Wait 30 seconds before force-killing

docker kill my-website
# Sends SIGKILL — immediate force stop

docker start my-website
# Start a STOPPED container (keeps its config)

docker restart my-website
# Stop + Start in one command
```

### Remove Containers
```bash
docker rm my-website
# Remove a STOPPED container

docker rm -f my-website
# Force remove a RUNNING container (stop + remove)

docker rm $(docker ps -aq)
# Remove ALL stopped containers (bash trick)

docker container prune
# Remove all stopped containers (with confirmation prompt)
docker container prune -f
# Remove all stopped containers (no confirmation)
```

---

## ── SECTION 5: INSPECT & DEBUG COMMANDS ──

### View Logs
```bash
docker logs my-website
# Show all logs so far

docker logs -f my-website
# FOLLOW logs in real-time (like tail -f)
# Press Ctrl+C to stop following

docker logs --tail 50 my-website
# Show last 50 lines only

docker logs --since 10m my-website
# Show logs from the last 10 minutes

docker logs -f --tail 100 my-website
# Follow last 100 lines
```

### Execute Commands Inside Container
```bash
docker exec my-website ls /etc/nginx
# Run a command inside a RUNNING container (non-interactive)

docker exec -it my-website bash
# Open interactive terminal INSIDE a running container
# Now you are inside! You can:
#   ls -la         → list files
#   cat app.js     → read a file
#   env            → see all environment variables
#   ps aux         → see running processes
#   curl localhost → test the app from inside
#   exit           → leave the container

docker exec -it my-website sh
# Use sh if bash is not available (alpine linux)
```

### Inspect (Full Details)
```bash
docker inspect my-website
# Returns a JSON with EVERYTHING about the container:
# IP address, mounts, network, config, etc.

docker inspect my-website | grep IPAddress
# Extract the container's IP address

docker inspect --format='{{.NetworkSettings.IPAddress}}' my-website
# Formatted output — just the IP
```

### Stats (Live Resource Usage)
```bash
docker stats
# Live dashboard: CPU%, Memory, Network I/O for ALL running containers
# Output:
# NAME         CPU%   MEM USAGE / LIMIT     MEM%   NET I/O
# my-website   0.0%   2.5MiB / 7.77GiB     0.03%  648B / 0B
# my-mongo     0.5%   64.5MiB / 7.77GiB    0.81%  1.1kB / 0B

docker stats my-website
# Stats for one container only

docker top my-website
# Show running processes INSIDE the container
```

### Copy Files
```bash
# Copy FROM host TO container
docker cp ./myfile.txt my-website:/app/myfile.txt

# Copy FROM container TO host
docker cp my-website:/app/logs/error.log ./error.log
```

---

## ── SECTION 6: VOLUME COMMANDS ──

```bash
docker volume create my-data
# Create a named volume

docker volume ls
# List all volumes
# Output:
# DRIVER    VOLUME NAME
# local     my-data
# local     mongo-data

docker volume inspect my-data
# See details (where data is stored on host, etc.)

docker volume rm my-data
# Delete a volume (WARNING: DATA IS DELETED!)

docker volume prune
# Remove all unused volumes
```

---

## ── SECTION 7: NETWORK COMMANDS ──

```bash
docker network ls
# List networks
# Output:
# NETWORK ID     NAME      DRIVER    SCOPE
# abc123456789   bridge    bridge    local   ← default
# def987654321   host      host      local
# 111222333444   none      null      local

docker network create my-network
# Create a custom bridge network

docker network inspect my-network
# See details (which containers are connected)

docker network rm my-network
# Remove a network

# Connect a RUNNING container to a network
docker network connect my-network my-website

# Disconnect a container from a network
docker network disconnect my-network my-website
```

---

## ── SECTION 8: DOCKER HUB COMMANDS ──

```bash
# Login to Docker Hub
docker login
# Prompts for username and password

# Tag your image before pushing
docker tag my-app yourusername/my-app:latest
docker tag my-app yourusername/my-app:1.0

# Push to Docker Hub
docker push yourusername/my-app:latest
# Now anyone can: docker pull yourusername/my-app

# Pull your own image
docker pull yourusername/my-app

# Logout
docker logout
```

---

## ── SECTION 9: SYSTEM COMMANDS ──

```bash
docker system df
# Show disk usage by Docker
# Output:
# TYPE            TOTAL    ACTIVE    SIZE      RECLAIMABLE
# Images          5        2         1.43GB    800MB
# Containers      3        1         10MB      8MB
# Volumes         2        1         100MB     50MB

docker system prune
# Remove ALL: stopped containers + unused images + unused networks
# WARNING: cannot be undone!

docker system prune -a
# Also remove unused images (not just dangling)

docker system prune -a --volumes
# Also remove unused volumes (DATA DELETED!)
```

---

## ── SECTION 10: COMMON WORKFLOW EXAMPLES ──

### Run a Static Website with Nginx
```bash
# Start nginx serving your HTML files
docker run -d \
  -p 8080:80 \
  --name my-site \
  -v $(pwd)/html:/usr/share/nginx/html \
  nginx

# Open browser: http://localhost:8080
```

### Run a MongoDB Database
```bash
docker run -d \
  -p 27017:27017 \
  --name my-mongo \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password \
  -v mongo-data:/data/db \
  mongo:6

# Connect with:  mongodb://admin:password@localhost:27017
```

### Run a PostgreSQL Database
```bash
docker run -d \
  -p 5432:5432 \
  --name my-postgres \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=myapp \
  -v pg-data:/var/lib/postgresql/data \
  postgres:15

# Connect: postgresql://admin:secret@localhost:5432/myapp
```

### Run a Redis Cache
```bash
docker run -d \
  -p 6379:6379 \
  --name my-redis \
  redis:7

# Connect: redis://localhost:6379
```

---

## ── QUICK REFERENCE TABLE ──

```
TASK                              COMMAND
──────────────────────────────────────────────────────────────────
Download an image                 docker pull IMAGE_NAME
List images                       docker images
Build image from Dockerfile       docker build -t NAME .
Run a container (background)      docker run -d -p 8080:80 IMAGE
Run with interactive terminal     docker run -it IMAGE bash
List running containers           docker ps
List all containers               docker ps -a
Stop a container                  docker stop NAME
Remove a container                docker rm NAME
View logs                         docker logs NAME
Live logs                         docker logs -f NAME
Terminal inside container         docker exec -it NAME bash
Container resource usage          docker stats
Full container details            docker inspect NAME
Remove all stopped containers     docker container prune
Clean up everything               docker system prune -a
──────────────────────────────────────────────────────────────────
```
