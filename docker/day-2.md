# Dockerfile Instrctions
A **Dockerfile** is a script containing a set of instructions to automate the creation of Docker images. Below are the key Dockerfile instructions with explanations:

### 1.Basic Instructions
| Instruction | Description |
|-------------|-------------|
| `FROM` | Specifies the base image (e.g., `FROM ubuntu:20.04`) |
| `RUN` | Executes a command inside the image (e.g., `RUN apt-get update && apt-get install -y nginx`) |
| `CMD` | Default command to run when the container starts (e.g., `CMD ["nginx", "-g", "daemon off;"]`) |
| `ENTRYPOINT` | Defines the main command, allowing additional arguments (e.g., `ENTRYPOINT ["python", "app.py"]`) |
| `COPY` | Copies files from the host to the container (e.g., `COPY index.html /usr/share/nginx/html/`) |
| `ADD` | Similar to `COPY` but supports remote URLs and auto-extracts archives (e.g., `ADD myfile.tar.gz /app/`) |
| `WORKDIR` | Sets the working directory inside the container (e.g., `WORKDIR /app`) |
| `ENV` | Sets environment variables (e.g., `ENV APP_ENV=production`) |
| `ARG` | Defines build-time variables (e.g., `ARG VERSION=1.0`) |
| `EXPOSE` | Documents the port the container listens on (e.g., `EXPOSE 80`) |
| `USER` | Sets the user to run the container (e.g., `USER appuser`) |
| `LABEL` | Adds metadata to the image (e.g., `LABEL maintainer="Konka <email@example.com>"`) |

### 2.Best Practices
- Use **minimal base images** like `alpine` for smaller, faster builds.
- **Use multi-stage builds** to reduce the final image size.
- **Combine `RUN` instructions** to minimize layers (e.g., `RUN apt-get update && apt-get install -y curl`).
- Use **`.dockerignore`** to exclude unnecessary files.

### Difference between SHELL form and EXEC form
- Shell Mode (`CMD ["sh", "-c", "your_command"]`) runs inside a shell, which may block signals like SIGTERM from reaching the actual process.  
- Exec Mode (`CMD ["your_command"]`) runs the command directly, ensuring proper signal forwarding.  
- Signal Forwarding means when stopping a container (`docker stop`), Docker sends SIGTERM to the main process. In Shell Mode, the shell may not pass it properly, while in Exec Mode, the process receives it correctly.

Example:  
```
FROM ubuntu:latest
RUN useradd -m appuser
USER appuser
CMD ["bash"]
```
This ensures the container runs with limited permissions, reducing security risks. Avoid running containers as root unless absolutely necessary.

**When to Use ENTRYPOINT** 
- When the container must always run a specific application (e.g., nginx, mysqld, etc.).
- When you want to ensure the container runs a single, well-defined process.
**When to Use CMD**
- When you want a default command but allow users to override it.
---
# Docker Layers and Intermediate Images  

Docker uses a layered file system, meaning each instruction in a Dockerfile creates a new layer on top of the previous one. These layers are cached and reused to speed up builds and reduce image size.  

Types of Layers  
1. Base Layer – The first layer, created using `FROM`, which defines the base image (e.g., `ubuntu:20.04`).  
2. Intermediate Layers – Created from `RUN`, `COPY`, and `ADD` instructions. These layers are cached and reused when building images.  
3. Final Layer – The last layer that contains all modifications and forms the final Docker image.  

Example  
```dockerfile
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y nginx
COPY index.html /var/www/html/
CMD ["nginx", "-g", "daemon off;"]
```
Each instruction (`FROM`, `RUN`, `COPY`, `CMD`) creates a separate layer. If you modify `COPY index.html /var/www/html/`, Docker will reuse the previous layers and only rebuild the affected part.  

Intermediate Images  
Intermediate images are temporary layers created during the image build process. These images exist in the Docker cache and can be seen using:  
```sh
docker history <image_id>
```
or  
```sh
docker images --filter label=intermediate
```
They help Docker speed up builds but are not stored in the final image.  

Optimizing Layers  
1. Minimize Layers – Combine commands in a single `RUN` statement.  
   ```dockerfile
   RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*
   ```
2. Use .dockerignore – Exclude unnecessary files to avoid invalidating the cache.  
3. Leverage Layer Caching – Place frequently changing instructions (`COPY`, `ADD`) after stable ones (`RUN`).  


Best Practices for Docker Layers and Intermediate Images  

1. Minimize the Number of Layers  
Each RUN, COPY, and ADD instruction creates a new layer. To reduce image size and speed up builds, combine multiple commands into a single RUN instruction.  

Good Practice:  
```dockerfile
RUN apt-get update && apt-get install -y nginx \
    && rm -rf /var/lib/apt/lists/*
```
Bad Practice:  
```dockerfile
RUN apt-get update
RUN apt-get install -y nginx
RUN rm -rf /var/lib/apt/lists/*
```
Each RUN creates a separate layer, increasing image size.

---

2. Use a Minimal Base Image  
Smaller base images reduce the attack surface and improve security.  

Good Choices:  
- alpine (5 MB)  
- distroless (No package manager, minimal footprint)  

Bad Choices:  
- ubuntu or debian (Large, ~30 MB to 100 MB)  

Example:  
```dockerfile
FROM alpine:latest
RUN apk add --no-cache nginx
```

---

3. Optimize Layer Caching  
Docker builds layers in order. If an earlier layer changes, all subsequent layers must be rebuilt. Place frequently changing instructions (e.g., COPY, ADD) after stable layers.  

Good Order (Efficient Caching):  
```dockerfile
FROM node:18
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
CMD ["node", "server.js"]
```
Here, Docker caches the npm install step unless package.json changes.  

Bad Order (Inefficient Caching):  
```dockerfile
FROM node:18
WORKDIR /app
COPY . .  # Copies all files, invalidating cache every time
RUN npm install
CMD ["node", "server.js"]
```
If even a small file changes, npm install runs again.

---

4. Use Multi-Stage Builds  
Multi-stage builds help reduce final image size by keeping only the necessary files.  

Good Example (Multi-Stage Build):  
```dockerfile
# First stage (build)
FROM golang:1.20 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp

# Second stage (final image)
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/myapp .
CMD ["./myapp"]
```
This approach avoids keeping unnecessary files like source code and dependencies.

---

5. Use .dockerignore  
Avoid copying unnecessary files to the container. Create a .dockerignore file:  
```
node_modules
.git
Dockerfile
README.md
```
This prevents large or sensitive files from being added to the image.

---

6. Use Non-Root Users  
By default, containers run as root, which is a security risk. Switch to a non-root user.  

Good Practice:  
```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```
---
7. Clean Up Temporary Files  
Remove unnecessary files to keep images lightweight.  

Example:  
```dockerfile
RUN apt-get update && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*
```

---
8. Use Labels for Metadata  
Labels provide useful metadata like the maintainer or version.  

Example:  
```dockerfile
LABEL maintainer="Konka <email@example.com>"
LABEL version="1.0"
```

---

10. Keep Image Versions Up to Date  
Always use specific versions instead of latest to avoid unexpected changes.  

Good Practice:  
```dockerfile
FROM node:18.16.0  # Specify version
```
Bad Practice:  
```dockerfile
FROM node:latest  # May introduce breaking changes
```
---

### Running Container as Root - Problems  

- Running as root gives full control inside the container. If an attacker gains access, they can do anything.  
- If a root container is compromised, it can impact the host system, especially if running in privileged mode.  
- Avoid mounting the host filesystem in read-write mode; use read-only mode to prevent unauthorized changes.  
- Running as a non-root user reduces security risks and limits potential damage.  
- Use Docker security best practices like `USER` in Dockerfile and dropping unnecessary capabilities.

**Best Practices**  
- Use a non-root user in Dockerfile:  
  ```dockerfile
  RUN useradd -m appuser  
  USER appuser  
  ```  
- Set `runAsNonRoot: true` in Kubernetes.  
- Avoid `--privileged` mode.  
- Drop unnecessary capabilities.

### Why Docker Networking?  
Docker networking allows containers to communicate with each other and with external networks. It ensures:  
1. Isolation – Containers have separate network namespaces.  
2. Interconnectivity – Containers can talk to each other securely.  
3. External Access – Containers can be exposed to the outside world.  
4. Service Discovery – Containers can find and connect to services dynamically.  

---

### Types of Networking in Docker  

1. Bridge Network (Default for Standalone Containers)  
   - Containers can communicate within the same network but are isolated from external systems.  
   - Uses `docker0` virtual bridge.  
   - Ideal for single-host setups.  

   Example:  
   ```sh
   docker network create my_bridge
   docker run -d --name container1 --network my_bridge nginx
   docker run -d --name container2 --network my_bridge alpine
   ```

2. Host Network  
   - Container shares the same network namespace as the host.  
   - No isolation; the container uses the host’s IP address.  
   - Faster networking but less secure.  

   Example:  
   ```sh
   docker run --network host nginx
   ```

3. Overlay Network (For Swarm Mode)  
   - Enables multi-host communication for Docker Swarm clusters.  
   - Requires a key-value store like Consul or etcd.  
   - Useful for microservices across multiple nodes.  

   Example:  
   ```sh
   docker network create -d overlay my_overlay
   ```

4. Macvlan Network  
   - Assigns a physical MAC address to the container.  
   - Container appears as a separate device on the network.  
   - Used for direct integration with existing networks.  

   Example:  
   ```sh
   docker network create -d macvlan --subnet=192.168.1.0/24 my_macvlan
   ```

5. None Network  
   - No network access.  
   - Useful for security-sensitive containers that don’t require external communication.  

   Example:  
   ```sh
   docker run --network none nginx
   ```

---

### How to List and Inspect Networks  
```sh
docker network ls        # List all networks  
docker network inspect bridge  # Inspect a network  
docker network rm my_network  # Remove a network  
```

Docker networking helps manage container communication efficiently, whether within a single machine or across multiple nodes. 🚀

# Docker-Compose
Docker Compose is a tool that helps you define and manage multi-container Docker applications using a simple YAML file (docker-compose.yml). Instead of running multiple docker run commands manually, you can define your entire application stack in one file and start everything with a single command.

Why Use Docker Compose?
1. Easier management – Define all services (databases, backend, frontend, etc.) in one place.
2. Automatic networking – All services in a Compose file are in the same network by default.
3. Simplified commands – Instead of multiple docker run commands, just use docker-compose up.
4. Scalability – Easily scale services (docker-compose up --scale backend=3).
5. Environment configuration – Use .env files for variables.

Basic Example (docker-compose.yml):
```yaml
version: "3.9"

services:
  backend:
    image: my-backend-image
    ports:
      - "5000:5000"
    networks:
      - app_network

  database:
    image: mysql:latest
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: mydb
    networks:
      - app_network

networks:
  app_network:
```
This defines:
- A backend service running on port 5000.
- A MySQL database with credentials.
- A custom network app_network connecting both services.

How to Use Docker Compose:
1. Start services  
   ```sh
   docker-compose up -d
   ```
2. View running containers  
   ```sh
   docker-compose ps
   ```
3. Stop services  
   ```sh
   docker-compose down
   ```
### Key Commands  
- `docker-compose up -d` → Start all services in detached mode.  
- `docker-compose down` → Stop and remove containers.  
- `docker-compose ps` → List running services.  
- `docker-compose logs` → View logs.  
- `docker-compose exec app sh` → Access a running container.  


