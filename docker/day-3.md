### Why Docker Networking?  
Docker networking allows containers to communicate with each other and with external networks. It ensures:  
1. Isolation – Containers have separate network namespaces.  
2. Interconnectivity – Containers can talk to each other securely.  
3. External Access – Containers can be exposed to the outside world.  
4. Service Discovery – Containers can find and connect to services dynamically.  

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

# Docker volumes
Containers are ephemeral, meaning they don’t persist data after termination or restart. To preserve data beyond the container lifecycle, we use volumes.
1. Named Volumes  
   - Created and managed by Docker.  
   - Persist beyond container removal.  
   - Used for sharing data between containers.  
   - Example:  
     ```
     docker volume create myvolume
     docker run -v myvolume:/data ubuntu
     ```  

2. Anonymous Volumes  
   - Temporary volumes without a name.  
   - Exist only as long as the container runs.  
   - Deleted when the container is removed.  
   - Example:  
     ```
     docker run -v /data ubuntu
     ```  

3. Bind Mounts  
   - Mounts a host file/folder into the container.  
   - Can expose host data to containers.  
   - Best practice is to use read-only mode to prevent security risks.  
   - Example:  
     ```
     docker run -v /host/path:/container/path:ro ubuntu
     ```  
   - `ro` (read-only) ensures the container cannot modify host files.  
   - If `rw` (read-write) is used, a vulnerable container can get full control over the host filesystem.

  ### 🚀 Key Takeaways  

| **Operation**    | **Read-Write (rw) Mount** | **Read-Only (ro) Mount** |
|-----------------|-------------------------|-------------------------|
| Read file      | ✅ Yes                    | ✅ Yes                   |
| Modify file    | ✅ Yes                    | ❌ No                    |
| Delete file    | ✅ Yes                    | ❌ No                    |

### 🚀 Key Takeaways  

| **Volume Type**     | **Syntax**             | **Persistence**                 | **Use Case**             |
|---------------------|-----------------------|--------------------------------|--------------------------|
| Anonymous Volume   | `-v /data`             | ❌ Removed with container      | Temporary storage       |
| Named Volume       | `-v myvolume:/data`    | ✅ Survives container removal  | Persistent data         |
| Bind Mount        | `-v /host/path:/data`  | ✅ Exists on host             | Direct file access      |


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

### Use Cases  
- Running **microservices**  
- **Local development** environments  
- Defining **test setups** with databases, message brokers, etc.

# docker best practices
- Official image
- Multi stage docker build to keep image size less
- Avoid containers run as root user
- Use .dockerignore to exclude unnecessary files.
- Combine multiple RUN instructions to reduce image layers.
- Use specific image versions instead of latest.
- Regularly update images to patch security vulnerabilities.
- Clean up unused images, containers, and volumes to free up space.
- Use environment variables for configuration instead of hardcoding.
- Prefer CMD over ENTRYPOINT unless strict execution control is needed.
