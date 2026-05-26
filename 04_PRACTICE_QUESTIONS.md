# 🐳 Docker — Practice Questions & Answers
### Session Revision — Test Your Understanding
---

## 🟢 LEVEL 1 — Basic Concepts (Warm Up)

---

**Q1. What is Docker and why do we use it?**

> ✅ Answer:
> Docker is a platform that packages an application and ALL its dependencies
> (code, runtime, libraries, config) into a single unit called a **container**.
> We use it because:
> - Solves "it works on my machine" problem
> - The same container runs identically on any computer
> - Lightweight (faster than VMs)
> - Easy to share, deploy, and scale

---

**Q2. What is the difference between a Docker Image and a Docker Container?**

> ✅ Answer:
> | | Image | Container |
> |--|-------|-----------|
> | What it is | Blueprint / Template | Running instance |
> | State | Read-only, inactive | Active, running |
> | Analogy | Recipe | Cooked meal |
> | Analogy 2 | Class | Object |
> | Created by | `docker build` | `docker run` |
>
> One Image → Many Containers

---

**Q3. What is Docker Hub?**

> ✅ Answer:
> Docker Hub (hub.docker.com) is an online **registry** — a store for Docker images.
> - You can PULL (download) official images: nginx, node, mongo, postgres
> - You can PUSH (upload) your own images to share with your team
> - Think of it like GitHub, but for Docker images instead of code

---

**Q4. What command do you use to:**
- a) Download an image
- b) List all running containers
- c) Stop a container
- d) See logs of a container

> ✅ Answer:
> ```bash
> a) docker pull nginx
> b) docker ps
> c) docker stop my-container
> d) docker logs my-container
> ```

---

**Q5. What does the -d flag do in `docker run -d nginx`?**

> ✅ Answer:
> `-d` stands for **detached mode** — it runs the container in the **background**.
> Without `-d`, the container runs in the foreground and blocks your terminal.
> With `-d`, your terminal is free to use, and the container runs behind the scenes.

---

**Q6. What is the difference between `docker ps` and `docker ps -a`?**

> ✅ Answer:
> - `docker ps`    → Shows only **RUNNING** containers
> - `docker ps -a` → Shows **ALL** containers (running + stopped + exited)
>
> If you ran a container and it stopped, it won't appear in `docker ps` but WILL
> appear in `docker ps -a`

---

**Q7. Explain this command: `docker run -d -p 8080:80 --name my-web nginx`**

> ✅ Answer:
> - `docker run`     → Create and start a new container
> - `-d`             → Run in background (detached)
> - `-p 8080:80`     → Map host port 8080 → container port 80
>                      (access via http://localhost:8080)
> - `--name my-web`  → Give the container the name "my-web"
> - `nginx`          → Use the nginx image

---

## 🟡 LEVEL 2 — Intermediate (Main Questions)

---

**Q8. What is a Dockerfile? What is the difference between `RUN` and `CMD`?**

> ✅ Answer:
> A **Dockerfile** is a text file with step-by-step instructions to BUILD a Docker image.
>
> | | RUN | CMD |
> |--|-----|-----|
> | When does it run? | During `docker build` | When container STARTS |
> | Purpose | Install, setup, compile | Start the application |
> | Can have many? | Yes, multiple RUN | Only ONE CMD (last wins) |
> | Example | `RUN npm install` | `CMD ["node", "app.js"]` |
>
> Example:
> ```dockerfile
> RUN npm install        ← runs once, during image build
> CMD ["node", "app.js"] ← runs every time a container starts
> ```

---

**Q9. What is the purpose of `.dockerignore`? Give 3 examples of what to put in it.**

> ✅ Answer:
> `.dockerignore` tells Docker what NOT to copy into the image (like `.gitignore` for git).
> Purpose: smaller images, faster builds, don't expose secrets.
>
> 3 important things to always include:
> ```
> node_modules   → don't copy (reinstall inside container)
> .env           → NEVER copy (contains secrets!)
> .git           → not needed (saves space)
> ```

---

**Q10. What is Port Mapping? Why is it needed?**

> ✅ Answer:
> Containers run in an **isolated network** — you can't access them from your browser by default.
> Port mapping connects a port on your **host computer** to a port **inside the container**.
>
> Syntax: `-p HOST_PORT:CONTAINER_PORT`
>
> Example:
> ```bash
> docker run -p 8080:3000 my-app
> ```
> - Container listens on port **3000** (internally)
> - You access it on port **8080** on your laptop
> - Browser: `http://localhost:8080` → reaches the app inside the container
>
> Without port mapping → you cannot reach the container at all.

---

**Q11. What is a Docker Volume? Why is it important for databases?**

> ✅ Answer:
> A **Volume** is a way to store data OUTSIDE the container so it persists.
>
> By default, containers are **stateless** — all data is lost when the container stops.
> For a database, this means all your records would be deleted every restart!
>
> A volume links a folder on the HOST to a path inside the container:
> ```bash
> docker run -v mongo-data:/data/db mongo
> #            ↑                ↑
> #       volume name      inside container
> ```
> Now even if the container is deleted, the data stays safe in `mongo-data`.

---

**Q12. What does `docker exec -it my-container bash` do? When would you use it?**

> ✅ Answer:
> It opens an **interactive terminal (bash shell) INSIDE** a running container.
> - `exec` → run a command in an already-running container
> - `-it`  → interactive + terminal (so you can type)
> - `bash` → the shell to open
>
> When to use it:
> - Debug why the app isn't working
> - Check what files are in the container
> - View environment variables (`env`)
> - Check if the app process is running (`ps aux`)
> - Test internal connections (`curl localhost:3000`)

---

**Q13. How is a Docker Container different from a Virtual Machine?**

> ✅ Answer:
> | Feature | Virtual Machine | Docker Container |
> |---------|-----------------|------------------|
> | Has its own OS? | YES (full guest OS) | No (shares host OS kernel) |
> | Size | 1–20 GB | 50–500 MB |
> | Startup time | 1–5 minutes | 1–5 seconds |
> | Performance | Slower (overhead) | Near-native |
> | Isolation level | Hardware level | Process level |
>
> **Containers are lighter and faster because they don't include a full OS.**
> They share the host OS kernel.

---

**Q14. What does `depends_on` do in docker-compose.yml?**

> ✅ Answer:
> `depends_on` tells Docker Compose the **start order** of services.
> It ensures one service starts before another.
>
> ```yaml
> app:
>   depends_on:
>     - db         # db container starts before app container
> db:
>   image: mongo
> ```
>
> ⚠️ Important limitation: `depends_on` only waits for the container to **start**,
> NOT for the service inside to be **ready**.
> For example, MongoDB might take 5 seconds to initialize after the container starts.
> For production use `healthcheck` + `condition: service_healthy`.

---

## 🔴 LEVEL 3 — Advanced / Scenario Questions

---

**Q15. A developer says "my database data disappears every time I restart the container." What is the problem and solution?**

> ✅ Answer:
> **Problem:** They are not using a Volume. Containers are stateless by default —
> all data written inside a container is deleted when the container stops.
>
> **Solution:** Add a named volume to the database service:
> ```yaml
> db:
>   image: mongo
>   volumes:
>     - mongo-data:/data/db   ← add this
>
> volumes:
>   mongo-data:               ← declare it
> ```
> Or with `docker run`:
> ```bash
> docker run -v mongo-data:/data/db mongo
> ```
> Now data persists across restarts and even container deletion.

---

**Q16. Look at this Dockerfile. What is the problem and how do you fix it?**
```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
CMD ["node", "app.js"]
```

> ✅ Answer:
> **Problem:** Bad layer caching order.
> `COPY . .` copies ALL files first (including app code that changes often).
> Every time you change even one line of code, `RUN npm install` runs again — very slow!
>
> **Fix:** Copy `package.json` FIRST, install, THEN copy the rest:
> ```dockerfile
> FROM node:18
> WORKDIR /app
> COPY package*.json ./      ← copy deps manifest first
> RUN npm install            ← cached unless package.json changes
> COPY . .                   ← code changes don't affect the install cache
> CMD ["node", "app.js"]
> ```
> Now `npm install` only re-runs when `package.json` changes — much faster builds!

---

**Q17. What is the difference between `docker compose down` and `docker compose down -v`?**

> ✅ Answer:
> - `docker compose down`    → Stops and **removes containers and networks** only
>                              ✅ **Volumes and data are KEPT safe**
>
> - `docker compose down -v` → Stops and removes containers, networks, AND **volumes**
>                              ⚠️ **ALL DATA IN VOLUMES IS DELETED PERMANENTLY**
>
> When to use:
> - Daily stop/start → use `docker compose down` (keeps your db data)
> - Reset everything from scratch → use `docker compose down -v`

---

**Q18. You have a React app and a Node.js API. How do you set up Docker Compose so the React app can talk to the API?**

> ✅ Answer:
> Put both on the **same Docker network**. They can then reach each other by service name.
>
> ```yaml
> version: "3.9"
> services:
>   frontend:
>     build: ./frontend
>     ports: ["3000:3000"]
>     networks: [app-net]
>
>   backend:
>     build: ./backend
>     ports: ["5000:5000"]
>     networks: [app-net]
>
> networks:
>   app-net:
>     driver: bridge
> ```
>
> Inside the `frontend` container, the API URL would be:
> `http://backend:5000`   ← use the SERVICE NAME as the hostname
>
> From your browser (outside containers):
> `http://localhost:5000` ← use localhost with the mapped port

---

**Q19. What is a multi-stage build in Docker? Why is it useful?**

> ✅ Answer:
> A multi-stage build uses **multiple `FROM` statements** in one Dockerfile.
> Each stage can copy files FROM previous stages.
> The **final image only contains what the last stage has** — everything else is discarded.
>
> Example for React:
> ```dockerfile
> # Stage 1: Build (big, has node, node_modules, source code)
> FROM node:18-alpine AS builder
> WORKDIR /app
> COPY . .
> RUN npm install && npm run build
> # Creates: /app/dist
>
> # Stage 2: Serve (small, just nginx + built files)
> FROM nginx:alpine
> COPY --from=builder /app/dist /usr/share/nginx/html
> ```
>
> Why useful:
> - Without multi-stage → image is ~900MB (has all of Node.js)
> - With multi-stage → image is ~25MB (just nginx + HTML files)
> - Smaller = faster downloads, less disk, better security

---

**Q20. True or False — Explain why:**

| Statement | True/False |
|-----------|-----------|
| a) An image can run by itself without creating a container | |
| b) Multiple containers can be created from the same image | |
| c) Data inside a container is lost when the container stops (without volumes) | |
| d) `EXPOSE 3000` in Dockerfile automatically opens port 3000 on your laptop | |
| e) Docker containers include a full copy of an OS (like a VM) | |
| f) You can change a container's config by editing the Dockerfile and rebuilding | |

> ✅ Answers:
> a) **FALSE** — An image is just a blueprint. You must `docker run` to create a container from it.
>
> b) **TRUE** — One image can spawn many containers. `docker run my-app` can be run many times.
>
> c) **TRUE** — Containers are stateless. Without a volume, ALL data disappears on stop.
>
> d) **FALSE** — `EXPOSE` is just documentation. To actually open the port, you need `-p 8080:3000` in `docker run`.
>
> e) **FALSE** — Containers share the HOST OS kernel. They don't have their own full OS like a VM.
>
> f) **TRUE** — Edit the Dockerfile → `docker build` to create a new image → `docker run` the new image.

---

## 📝 BONUS — Fill in the Blank

**Complete the commands:**

```bash
# 1. Start nginx in the background, map host port 8080 to container port 80, name it "web"
docker run ___ ___ _______ _______ nginx

# 2. Show logs of a container called "my-app" and follow in real time
docker logs ___ _______

# 3. Open an interactive terminal inside a running container "my-app"
docker exec ___ _______ bash

# 4. Build a Docker image from current folder and tag it "shop:1.0"
docker build ___ _______ .

# 5. Start all services in docker-compose.yml in the background
docker compose ___ ___

# 6. Stop and remove all containers AND their volumes
docker compose down ___
```

> ✅ Answers:
> ```bash
> 1. docker run -d -p 8080:80 --name web nginx
> 2. docker logs -f my-app
> 3. docker exec -it my-app bash
> 4. docker build -t shop:1.0 .
> 5. docker compose up -d
> 6. docker compose down -v
> ```

---

## 🧠 Quick Recap — Key Things to Remember

```
┌────────────────────────────────────────────────────────────────────┐
│  1. Image  = Blueprint (inactive)  |  Container = Running (active)│
│  2. docker build → creates image                                   │
│     docker run   → creates container from image                    │
│  3. -d = background  |  -p host:container = port map              │
│  4. docker ps      = running containers                            │
│     docker ps -a   = all containers                                │
│  5. docker logs -f = follow logs live                              │
│  6. docker exec -it = terminal inside container                    │
│  7. Volumes  = persist data beyond container lifecycle             │
│  8. Network  = how containers talk to each other                   │
│  9. Compose  = run multiple containers with one command            │
│  10. .dockerignore = don't copy node_modules, .env, .git          │
└────────────────────────────────────────────────────────────────────┘
```
