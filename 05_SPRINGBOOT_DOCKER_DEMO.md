# Spring Boot REST API — Docker Demo (via GitHub Codespaces)

> **No Docker on your laptop?** No problem.  
> GitHub Codespaces gives you a full Linux environment with Docker pre-installed — runs entirely in your browser.

---

## Folder Structure You Will Create

```
docker-demo/
├── src/
│   └── main/
│       └── java/
│           └── com/demo/
│               ├── DemoApplication.java
│               └── HelloController.java
├── pom.xml
└── Dockerfile
```

---

## STEP 1 — Create a GitHub Repository

1. Go to [github.com](https://github.com) → click **New repository**
2. Repository name: `docker-demo`
3. ✅ Check **Add a README file**
4. Click **Create repository**

---

## STEP 2 — Open GitHub Codespaces

1. In your new repo, click the green **`< > Code`** button
2. Click the **Codespaces** tab
3. Click **Create codespace on main**
4. Wait ~30 seconds — a full VS Code editor opens in your browser
5. Open a terminal: **Terminal → New Terminal**

Verify tools are available:

```bash
docker --version
java --version
```

> Docker and Java are pre-installed in Codespaces — no setup needed.

---

## STEP 3 — Create the Project Folder

```bash
mkdir -p docker-demo/src/main/java/com/demo
cd docker-demo
```

---

## STEP 4 — Create All Project Files

### 4a. `pom.xml` — Maven Build File

```bash
cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.2.0</version>
  </parent>

  <groupId>com.demo</groupId>
  <artifactId>docker-demo</artifactId>
  <version>1.0.0</version>
  <packaging>jar</packaging>

  <properties>
    <java.version>17</java.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
EOF
```

---

### 4b. `DemoApplication.java` — Main Class

```bash
cat > src/main/java/com/demo/DemoApplication.java << 'EOF'
package com.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
EOF
```

---

### 4c. `HelloController.java` — REST Controller with 4 Endpoints

```bash
cat > src/main/java/com/demo/HelloController.java << 'EOF'
package com.demo;

import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api")
public class HelloController {

    // GET /api/hello
    @GetMapping("/hello")
    public Map<String, String> hello() {
        return Map.of(
            "message", "Hello from Docker!",
            "status",  "running"
        );
    }

    // GET /api/greet/{name}
    @GetMapping("/greet/{name}")
    public Map<String, String> greet(@PathVariable String name) {
        return Map.of(
            "message", "Hello, " + name + "!",
            "from",    "Spring Boot in Docker"
        );
    }

    // POST /api/echo
    @PostMapping("/echo")
    public Map<String, Object> echo(@RequestBody Map<String, Object> body) {
        return Map.of(
            "received",  body,
            "timestamp", System.currentTimeMillis()
        );
    }

    // GET /api/health
    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of(
            "status", "UP",
            "app",    "docker-demo"
        );
    }
}
EOF
```

---

### 4d. `Dockerfile` — Multi-Stage Build

```bash
cat > Dockerfile << 'EOF'
# ── Stage 1: Build the JAR ───────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# ── Stage 2: Run the JAR ─────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF
```

**Why multi-stage?**

| Stage | Image Used | Purpose |
|-------|-----------|---------|
| Stage 1 (`build`) | `maven:3.9` (~500 MB) | Compiles code, creates JAR |
| Stage 2 (final) | `eclipse-temurin:17-jre` (~200 MB) | Runs only the JAR — small & clean |

The final image only contains the JRE + JAR. Maven and source code are NOT included.

---

## STEP 5 — Build the Docker Image

```bash
docker build -t spring-demo .
```

What happens inside:
1. Docker downloads the Maven image (Stage 1)
2. Copies your source files into the container
3. Runs `mvn clean package` — compiles and creates the JAR
4. Downloads the JRE image (Stage 2)
5. Copies only the JAR into the final image
6. Tags the final image as `spring-demo`

> First build takes ~2–3 minutes. Subsequent builds are faster due to layer caching.

Success message to look for:
```
Successfully built xxxxxx
Successfully tagged spring-demo:latest
```

---

## STEP 6 — Run the Container

```bash
docker run -d -p 8080:8080 --name my-spring-app spring-demo
```

| Flag | What it does |
|------|-------------|
| `-d` | Detached mode — runs in background |
| `-p 8080:8080` | Maps port 8080 on host → port 8080 in container |
| `--name my-spring-app` | Gives the container a friendly name |
| `spring-demo` | The image to run |

---

## STEP 7 — Verify It Is Running

```bash
# List running containers
docker ps

# View application logs
docker logs my-spring-app
```

Look for this line in the logs:
```
Started DemoApplication in 2.345 seconds (process running for 2.789)
```

---

## STEP 8 — Test the REST Endpoints

### Using curl in the terminal:

```bash
# 1. Hello endpoint
curl http://localhost:8080/api/hello

# 2. Greet with a name
curl http://localhost:8080/api/greet/Rahul

# 3. Health check
curl http://localhost:8080/api/health

# 4. POST echo
curl -X POST http://localhost:8080/api/echo \
  -H "Content-Type: application/json" \
  -d '{"message":"test","value":42}'
```

### Expected Responses:

```json
// GET /api/hello
{ "message": "Hello from Docker!", "status": "running" }

// GET /api/greet/Rahul
{ "message": "Hello, Rahul!", "from": "Spring Boot in Docker" }

// GET /api/health
{ "status": "UP", "app": "docker-demo" }

// POST /api/echo
{ "received": { "message": "test", "value": 42 }, "timestamp": 1716700000000 }
```

### Using browser (Codespaces port forwarding):

1. Look at the **Ports** tab at the bottom of Codespaces
2. Port `8080` will be listed automatically
3. Click the 🌐 **globe icon** → opens in your browser
4. Add `/api/hello` to the URL and press Enter

---

## STEP 9 — Useful Docker Commands

```bash
# ── Container Management ─────────────────────────────────────────────────────

# See all running containers
docker ps

# See all containers (including stopped)
docker ps -a

# Stop the container
docker stop my-spring-app

# Start it again (without recreating)
docker start my-spring-app

# Remove the container
docker rm my-spring-app

# Stop and remove in one line
docker rm -f my-spring-app

# ── Image Management ─────────────────────────────────────────────────────────

# List all images
docker images

# Remove the image
docker rmi spring-demo

# ── Logs & Debugging ─────────────────────────────────────────────────────────

# View logs
docker logs my-spring-app

# Follow logs in real-time (like tail -f)
docker logs -f my-spring-app

# Open a shell inside the running container
docker exec -it my-spring-app /bin/sh

# ── Rebuild After Code Changes ───────────────────────────────────────────────
docker rm -f my-spring-app
docker build -t spring-demo .
docker run -d -p 8080:8080 --name my-spring-app spring-demo
```

---

## STEP 10 — How the Dockerfile Works (Explained)

```dockerfile
# ── Stage 1: Build ───────────────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-17 AS build
#   ^ Uses the official Maven image which includes JDK 17

WORKDIR /app
#   ^ Sets working directory inside the container to /app

COPY pom.xml .
#   ^ Copies pom.xml first (Docker layer caching — Maven deps cached separately)

COPY src ./src
#   ^ Copies all source code

RUN mvn clean package -DskipTests
#   ^ Builds the project, creates target/docker-demo-1.0.0.jar
#   ^ -DskipTests skips unit tests to speed up build

# ── Stage 2: Run ─────────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre
#   ^ Smaller JRE-only image (no Maven, no JDK, no source code)

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar
#   ^ Copies ONLY the JAR from Stage 1 into this clean image

EXPOSE 8080
#   ^ Documents that the app listens on port 8080 (informational)

ENTRYPOINT ["java", "-jar", "app.jar"]
#   ^ Command that runs when the container starts
```

---

## Annotations Used in the Controller

| Annotation | Purpose |
|-----------|---------|
| `@RestController` | Marks class as REST controller — combines `@Controller` + `@ResponseBody` |
| `@RequestMapping("/api")` | Base URL prefix for all endpoints in this class |
| `@GetMapping("/hello")` | Maps HTTP GET requests to `/api/hello` |
| `@PostMapping("/echo")` | Maps HTTP POST requests to `/api/echo` |
| `@PathVariable` | Extracts value from the URL path (e.g., `{name}`) |
| `@RequestBody` | Reads the JSON body of a POST request and maps it to a Java object |

---

## Quick Reference — All Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/api/hello` | Returns a hello message |
| GET | `/api/greet/{name}` | Returns personalised greeting |
| GET | `/api/health` | Health check — returns UP status |
| POST | `/api/echo` | Echoes back whatever JSON you send |

---

## Summary of What You Learned

```
GitHub Codespaces
      |
      |-- Docker pre-installed (no laptop install needed)
      |
Spring Boot App
      |
      |-- pom.xml          → defines dependencies (spring-boot-starter-web)
      |-- DemoApplication  → entry point (@SpringBootApplication)
      |-- HelloController  → REST endpoints (@RestController)
      |
Dockerfile (Multi-Stage)
      |
      |-- Stage 1: maven image → mvn package → produces JAR
      |-- Stage 2: jre image   → runs JAR only (small final image)
      |
docker build -t spring-demo .      → creates image
docker run -d -p 8080:8080 ...     → starts container
curl http://localhost:8080/api/... → test endpoints
```
