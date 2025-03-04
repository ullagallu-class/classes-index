# dockerfile instructions
- `FROM` - Sets the base image  
- `WORKDIR` - Sets the working directory inside the container  
- `RUN` - Executes commands during the image build  
- `COPY` - Copies files from host to container  
- `ADD` - Like COPY but supports remote URLs and auto-extracts archives  
- `CMD` - Default command to run when the container starts (can be overridden)  
- `ENTRYPOINT` - Sets a fixed command that runs inside the container  
- `EXPOSE` - Informs which port the container listens on
- `USER` - instruction in Docker sets the user for running the container. By default, containers run as root, which is a security risk. To run as a non-root user, create a user and switch to it using USER. 

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

Docker images are made up of multiple layers. Each layer represents a change made during the build process.  

Base layer is the starting point, usually an OS image.  
Intermediate layers are created by instructions like RUN, COPY, ADD.  
Read-only layers are stacked above the base to form the final image.  
Writable layer is added when a container runs, allowing changes.  

Layers help with caching, efficiency, and reusability.
---
You can combine multiple `RUN` instructions in a Dockerfile using `&&` and `\` to reduce the number of layers and optimize the image.  

Example:  

```dockerfile
RUN apt update && \
    apt install -y curl unzip && \
    rm -rf /var/lib/apt/lists/*
```

This reduces image size by minimizing intermediate layers.
---
Multi-stage builds help reduce the final image size by using multiple stages in a Dockerfile.  

1. The first stage compiles or builds the application.  
2. The final stage copies only the necessary files, leaving behind unnecessary dependencies.  

Example:  

```dockerfile
FROM golang:latest AS builder  
WORKDIR /app  
COPY . .  
RUN go build -o myapp  

FROM alpine:latest  
WORKDIR /app  
COPY --from=builder /app/myapp .  
CMD ["./myapp"]  
```

This approach keeps the final image lightweight.
---
- instana project containerization

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
# Docker networking

Docker networking allows containers to communicate with each other and external systems while maintaining isolation and flexibility. It enables efficient service discovery, scaling, and secure communication between containers across single or multiple hosts.

- Bridge: Default network, allows containers to communicate on the same host. Custom bridge networks provide better control.  
- Overlay: Used for multi-host communication in Swarm mode.  
- Host: Removes network isolation, directly using the host’s network.  
- None: No networking, fully isolated container.  

For single-host communication, use a bridge network. For multi-host communication, use an overlay network.

docker netowrk create rb
docker network delete rb
docker network inspect rb

