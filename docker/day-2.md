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

### CMD vs ENTRYPOINT in Docker  

Both `CMD` and `ENTRYPOINT` define the default behavior of a container when it starts, but they serve different purposes.  

---

### CMD (Command)  
- Specifies a default command to execute when the container runs.  
- Can be overridden by passing a command when running the container.  
- If multiple `CMD` instructions exist, only the last one takes effect.  

Example:  
```dockerfile
FROM ubuntu  
CMD ["echo", "Hello from CMD"]
```
Run container:  
```sh
docker run myimage
# Output: Hello from CMD
```
Override CMD:  
```sh
docker run myimage echo "Overridden CMD"
# Output: Overridden CMD
```

---

### ENTRYPOINT  
- Defines a fixed command that always runs when the container starts.  
- Cannot be overridden using command-line arguments unless `--entrypoint` is specified.  
- Best for containers that should always run a specific process, like nginx or mysqld.  

Example:  
```dockerfile
FROM ubuntu  
ENTRYPOINT ["echo", "Hello from ENTRYPOINT"]
```
Run container:  
```sh
docker run myimage
# Output: Hello from ENTRYPOINT
```
Override ENTRYPOINT:  
```sh
docker run myimage "Overridden ENTRYPOINT"
# Output: Hello from ENTRYPOINT Overridden ENTRYPOINT
```
Force override:  
```sh
docker run --entrypoint /bin/bash myimage
```

---

### Combining ENTRYPOINT and CMD  
A best practice is to use `ENTRYPOINT` for the main command and `CMD` to pass default arguments.  

Example:  
```dockerfile
FROM ubuntu  
ENTRYPOINT ["echo"]  
CMD ["Hello from CMD"]
```
Run container:  
```sh
docker run myimage
# Output: Hello from CMD
```
Override CMD:  
```sh
docker run myimage "Overridden CMD"
# Output: Overridden CMD
```
Override ENTRYPOINT:  
```sh
docker run --entrypoint /bin/bash myimage
```

---

### When to Use CMD vs ENTRYPOINT  

| Scenario | Use `CMD` | Use `ENTRYPOINT` |
|----------|----------|-----------------|
| Default command, but user can override | Yes | No |
| Enforcing a fixed application execution | No | Yes |
| Running scripts, utilities with flexible arguments | Yes | No |
| Running a single application as the main process | No | Yes |

### Best Practice  
- Use `ENTRYPOINT` for defining the main process.  
- Use `CMD` for default arguments that can be overridden.
---
# Docker Layers and Intermediate Images  

Docker uses a layered file system, meaning each instruction in a Dockerfile creates a new layer on top of the previous one. These layers are cached and reused to speed up builds and reduce image size.  

**Types of Layers**  
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

**Intermediate Images**  
Intermediate images are temporary layers created during the image build process. These images exist in the Docker cache and can be seen using:  
```sh
docker history <image_id>
```
or  
```sh
docker images --filter label=intermediate
```
They help Docker speed up builds but are not stored in the final image.  

**Optimizing Layers** 
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

