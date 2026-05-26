# 🐳 Docker Compose — Complete Beginner Guide
### Run multiple containers with ONE command
---

## 1. What is Docker Compose?

```
Real apps are NOT just one container. They need:
  ● App Server     (Node.js, Python, etc.)
  ● Database       (MongoDB, PostgreSQL)
  ● Cache          (Redis)
  ● Web Server     (Nginx)

Without Docker Compose:
  docker run -d --name db    -p 27017:27017 mongo
  docker run -d --name cache -p 6379:6379   redis
  docker run -d --name app   -p 3000:3000   my-app
  → 3 separate commands
  → Must manually connect them to the same network
  → Must manually set environment variables
  → Very hard to manage in a team

With Docker Compose:
  docker compose up   ← ONE command starts EVERYTHING

Docker Compose reads a docker-compose.yml file
and handles all containers, networks, and volumes automatically.
```

---

## 2. docker-compose.yml Structure

```yaml
version: "3.9"   # compose file format version

services:        # each "service" = one container
  service1:
    # ... config for container 1

  service2:
    # ... config for container 2

volumes:         # declare named volumes here
  volume1:

networks:        # declare custom networks here (optional)
  network1:
```

---

## 3. All Configuration Options Explained

```yaml
version: "3.9"

services:

  app:                          # service name (you choose this)

    # ── HOW TO GET THE IMAGE ──
    image: node:18              # option 1: use an image from Docker Hub
    build: .                    # option 2: build from Dockerfile in current folder
    build:                      # option 3: detailed build config
      context: .                #   where to build from
      dockerfile: Dockerfile.dev #   which Dockerfile to use

    # ── CONTAINER NAME ──
    container_name: my-app      # name of the running container

    # ── PORTS ──
    ports:
      - "3000:3000"             # "host:container"
      - "9229:9229"             # can have multiple

    # ── ENVIRONMENT VARIABLES ──
    environment:
      - NODE_ENV=development    # option 1: inline
      - PORT=3000
    env_file:
      - .env                    # option 2: from a .env file

    # ── VOLUMES ──
    volumes:
      - .:/app                  # bind mount: current folder → /app in container
      - /app/node_modules       # anonymous volume: keep node_modules inside container
      - my-data:/app/data       # named volume

    # ── DEPENDENCY / START ORDER ──
    depends_on:
      - db                      # wait for "db" service to start before this one
      - cache

    # ── NETWORKING ──
    networks:
      - my-network              # join this network

    # ── RESTART POLICY ──
    restart: unless-stopped     # restart if it crashes, unless manually stopped
    # Options: no | always | on-failure | unless-stopped

    # ── OVERRIDE THE CMD in Dockerfile ──
    command: npm run dev        # override the default CMD

    # ── RESOURCE LIMITS ──
    deploy:
      resources:
        limits:
          cpus: "0.5"           # max 50% of one CPU
          memory: 512M          # max 512 MB RAM

  db:
    image: mongo:6.0
    container_name: my-database
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: secret
      MONGO_INITDB_DATABASE: myapp
    volumes:
      - mongo-data:/data/db     # persist database data
    networks:
      - my-network
    restart: always

  cache:
    image: redis:7-alpine
    container_name: my-redis
    ports:
      - "6379:6379"
    networks:
      - my-network
    restart: unless-stopped

volumes:
  mongo-data:                   # Docker manages this volume

networks:
  my-network:                   # all services share this network
    driver: bridge
```

---

## 4. Real Example — Full Stack App (Node + MongoDB + Redis)

### Project Structure:
```
my-fullstack-app/
├── docker-compose.yml
├── docker-compose.dev.yml     ← override for development
├── Dockerfile
├── .env
├── package.json
└── src/
     └── server.js
```

### .env file:
```env
NODE_ENV=development
PORT=3000
MONGO_URI=mongodb://admin:secret@db:27017/myapp?authSource=admin
REDIS_URL=redis://cache:6379
JWT_SECRET=mysupersecretkey
```

### docker-compose.yml (production):
```yaml
version: "3.9"

services:

  # ── Node.js Application ──
  app:
    build: .
    container_name: app
    ports:
      - "3000:3000"
    env_file:
      - .env
    depends_on:
      - db
      - cache
    networks:
      - app-network
    restart: unless-stopped

  # ── MongoDB Database ──
  db:
    image: mongo:6.0
    container_name: mongodb
    ports:
      - "27017:27017"                 # expose for local dev tools
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: secret
      MONGO_INITDB_DATABASE: myapp
    volumes:
      - mongo-data:/data/db           # data persists here
    networks:
      - app-network
    restart: always

  # ── Redis Cache ──
  cache:
    image: redis:7-alpine
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - app-network
    restart: unless-stopped

  # ── Nginx Reverse Proxy (optional) ──
  nginx:
    image: nginx:alpine
    container_name: nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app
    networks:
      - app-network
    restart: always

volumes:
  mongo-data:       # MongoDB data
  redis-data:       # Redis data

networks:
  app-network:
    driver: bridge
```

### How containers communicate:
```
INSIDE the docker network, containers talk to each other by SERVICE NAME:

app connects to MongoDB:   mongodb://admin:secret@db:27017
                                                    ↑
                                         service name "db"

app connects to Redis:     redis://cache:6379
                                    ↑
                            service name "cache"

From YOUR computer (host): localhost:27017  (via port mapping)
Inside containers:         db:27017         (by service name)
```

---

## 5. Docker Compose Commands

```bash
# ─── STARTING & STOPPING ───────────────────────────────

# Start all services (foreground — see logs in terminal)
docker compose up

# Start all services (background — detached)
docker compose up -d

# Start a specific service only
docker compose up -d db

# Rebuild images before starting
docker compose up -d --build

# Stop all containers (keeps data/volumes)
docker compose down

# Stop AND remove volumes (WARNING: DATA DELETED!)
docker compose down -v

# Restart all services
docker compose restart

# Restart one specific service
docker compose restart app

# ─── VIEWING STATUS ────────────────────────────────────

# Show running services
docker compose ps

# Output:
# NAME        IMAGE       COMMAND             STATUS        PORTS
# app         my-app      "node server.js"    Up 2 min.     0.0.0.0:3000->3000/tcp
# mongodb     mongo:6.0   "docker-entryp..."  Up 2 min.     0.0.0.0:27017->27017/tcp
# redis       redis:7     "docker-entryp..."  Up 2 min.     0.0.0.0:6379->6379/tcp

# ─── LOGS ──────────────────────────────────────────────

# See logs from ALL services
docker compose logs

# Follow logs in real-time from ALL services
docker compose logs -f

# Logs from ONE service only
docker compose logs app
docker compose logs -f db

# Last 100 lines from all
docker compose logs --tail=100

# ─── RUNNING COMMANDS ──────────────────────────────────

# Open a terminal inside a running service
docker compose exec app bash
docker compose exec app sh
docker compose exec db mongosh

# Run a one-off command (starts a NEW container, runs it, removes it)
docker compose run --rm app node scripts/seed.js

# ─── BUILDING ──────────────────────────────────────────

# Build images without starting
docker compose build

# Build a specific service
docker compose build app

# Rebuild without cache
docker compose build --no-cache

# ─── SCALING ───────────────────────────────────────────

# Run 3 instances of the app service
docker compose up -d --scale app=3
# NOTE: All 3 will try to use the same port — use a load balancer

# ─── CLEANUP ───────────────────────────────────────────

# Stop and remove containers, networks
docker compose down

# Stop and remove containers, networks, AND volumes
docker compose down -v

# Stop and remove everything including images
docker compose down --rmi all -v
```

---

## 6. Development vs Production Compose Files

```
Best practice: Have TWO compose files
  docker-compose.yml          → base / shared config
  docker-compose.dev.yml      → development overrides
  docker-compose.prod.yml     → production overrides

Run development:
  docker compose -f docker-compose.yml -f docker-compose.dev.yml up

Run production:
  docker compose -f docker-compose.yml -f docker-compose.prod.yml up
```

### docker-compose.dev.yml (development additions):
```yaml
# This file OVERRIDES / ADDS TO docker-compose.yml for development
version: "3.9"

services:
  app:
    build:
      target: development     # use dev stage of Dockerfile
    volumes:
      - .:/app                # live reload: mount source code
      - /app/node_modules     # keep container node_modules
    command: npm run dev      # use nodemon instead of node
    environment:
      - NODE_ENV=development
    ports:
      - "9229:9229"           # node debugger port
```

---

## 7. Health Checks

```yaml
services:
  db:
    image: mongo:6
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 30s       # check every 30 seconds
      timeout: 10s        # wait 10s for response
      retries: 3          # fail after 3 tries
      start_period: 30s   # give 30s to start before first check

  app:
    depends_on:
      db:
        condition: service_healthy  # wait until db is HEALTHY (not just started)
```

---

## 8. Common Patterns

### Pattern 1 — Live Code Reload in Development
```yaml
app:
  volumes:
    - .:/app              # your code is live inside container
    - /app/node_modules   # but keep container's node_modules
  command: npm run dev    # uses nodemon for auto-restart
```
> Any file you save on your laptop → instantly reflected in the container

### Pattern 2 — Only Build Once, Reuse
```yaml
# Use depends_on so db starts before app
app:
  depends_on:
    - db
  # app can reach db by hostname "db"
  environment:
    - MONGO_URI=mongodb://db:27017/mydb
```

### Pattern 3 — Adminer (Database GUI in browser)
```yaml
adminer:
  image: adminer
  ports:
    - "8080:8080"
  depends_on:
    - db
# Access: http://localhost:8080
# Connect to postgres using host "db", user "admin", pass "secret"
```

---

## 9. Complete Working Example — To Try Right Now

### Create these 3 files in a new folder, then run docker compose up:

#### docker-compose.yml
```yaml
version: "3.9"
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    restart: unless-stopped

  whoami:
    image: traefik/whoami
    ports:
      - "8081:80"
```

#### html/index.html
```html
<!DOCTYPE html>
<html>
<body style="font-family:Arial; text-align:center; padding:50px">
  <h1>Hello from Docker Compose!</h1>
  <p>This file is served by Nginx running in a container.</p>
  <p>Visit <a href="http://localhost:8081">localhost:8081</a> to see the whoami container.</p>
</body>
</html>
```

#### Commands:
```bash
docker compose up -d

# Visit:
# http://localhost:8080  → Your HTML page served by Nginx
# http://localhost:8081  → Shows container info (IP, hostname, headers)

docker compose ps       # see running services
docker compose logs     # see logs
docker compose down     # stop everything
```

---

## 10. Quick Reference

```
COMMAND                              WHAT IT DOES
───────────────────────────────────────────────────────────────────
docker compose up -d                 Start all services (background)
docker compose up -d --build         Rebuild images then start
docker compose down                  Stop and remove containers
docker compose down -v               Stop + remove containers + volumes
docker compose ps                    Show running services
docker compose logs -f               Follow all logs live
docker compose logs -f app           Follow one service's logs
docker compose exec app bash         Open terminal in a service
docker compose restart app           Restart one service
docker compose build                 Build images only (don't start)
docker compose run --rm app cmd      Run one-off command and remove
───────────────────────────────────────────────────────────────────
```
