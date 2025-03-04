# Deploymemt on physical Machines
- All applications run on physical machines
- No boundaries b/w application resournce utilization
- One app consumes more system resournces another applications under perform
- The solutions is to run each application seperate machines if do that is costly solution to maintain seperate machine of each application

# Deployment on VM
- To address above indutry comes with afforable solution i.e Virtualization
- Virtualization S/W allows create multiple isolated machine on single H/W
- app in vm1 cannot be freely accessed by app in vm2
- It allows better utilization of resournce in a vm
- we can easliy add or remove vms it will reduce h/w costs
- since it is a full os which is not that much feasible way to deploy container in a vm
- slower boottime and less scalable
 
# Deployment in container
- container are light weight does not require any full os
- It share host os kernal 
- faster boot and less secure because it shares resources with other containers

### Virtualization and Containerization  

Both virtualization and containerization are technologies used to deploy applications by abstracting system resources.  

#### Virtualization  
Virtualization allows multiple operating systems to run on a single physical machine using a **hypervisor**. It creates **virtual machines (VMs)**, each with its own OS, kernel, and resources.  

How it works:  
- A **hypervisor** (like VMware, VirtualBox, KVM, or Hyper-V) runs on the physical hardware or host OS.  
- It allocates CPU, memory, and disk to multiple **virtual machines (VMs)**.  
- Each VM runs its own **guest OS**, making it fully isolated.  

Example:  
A Linux server can run multiple VMs:  
- One with Windows  
- One with Ubuntu  

Advantages:  
- Full isolation (each VM has its own OS and kernel).  
- Can run different OS types.  
- Suitable for monolithic applications.  

Disadvantages:  
- Heavyweight (each VM includes an OS, consuming more CPU, memory, and storage).  
- Slower boot time compared to containers.  

#### Containerization  
Containerization allows applications to run in isolated environments called **containers**, which share the same OS kernel but have separate libraries and dependencies.  

How it works:  
- Uses a **container runtime** (like Docker, Podman, or containerd) instead of a hypervisor.  
- Containers share the **host OS kernel** but have their own filesystem, libraries, and dependencies.  
- Containers are lightweight compared to VMs because they don’t include a separate OS.  

Example:  
A Linux server running Docker can have:  
- A **Node.js** app container  
- A **MySQL** database container  
- A **Redis** cache container  

Advantages:  
- Lightweight (no need for a full OS).  
- Faster startup and better performance.  
- Easy to scale and deploy (ideal for microservices).  

Disadvantages:  
- Less isolation than VMs (containers share the same kernel).  
- Requires a container runtime (Docker, Kubernetes, etc.).  

#### Key Differences  
| Feature         | Virtualization (VMs) | Containerization (Containers) |  
|---------------|-------------------|-----------------|  
| Isolation | Each VM has its own OS | Containers share the same OS kernel |  
| Size | Heavy (includes OS) | Lightweight (no OS) |  
| Startup Time | Slow | Fast |  
| Performance | Lower (full OS overhead) | Higher (less overhead) |  
| Use Case | Running multiple OS, monolithic apps | Microservices, cloud-native apps |  

#### When to Use What  
- Use **VMs** when strong isolation is needed or when running different OS types.  
- Use **containers** when applications need to be lightweight, fast, and scalable.  


### Docker  

Docker is a containerization platform that allows you to package applications and their dependencies into lightweight, portable containers. Containers ensure that applications run consistently across different environments, from development to production.  

#### How Docker Works  
1. Docker Engine: The core service that runs and manages containers.  
2. Docker Images: A pre-packaged template containing the application, libraries, and dependencies.  
3. Docker Containers: Running instances of Docker images.  
4. Dockerfile: A script defining how to build a Docker image.  
5. Docker Hub: A public registry where images are stored and shared.  

#### Key Docker Commands  
- `docker run nginx` → Runs an Nginx container.  
- `docker ps` → Lists running containers.  
- `docker images` → Lists available images.  
- `docker build -t myapp .` → Builds an image from a Dockerfile.  
- `docker pull ubuntu` → Pulls an Ubuntu image from Docker Hub.  
- `docker push myapp` → Pushes an image to a registry.  

#### Why Use Docker?  
- Portability: Works the same on any OS (Linux, Windows, Mac).  
- Lightweight: Uses fewer resources than virtual machines.  
- Scalability: Easily deploy multiple containers using Docker Compose or Kubernetes.  
- Faster Deployment: Start and stop applications in seconds.  

#### Docker vs Virtual Machines  
| Feature  | Docker (Containers) | Virtual Machines (VMs) |  
|---------|------------------|------------------|  
| OS | Shares host OS | Each VM has its own OS |  
| Size | MBs (lightweight) | GBs (heavy) |  
| Startup | Seconds | Minutes |  
| Isolation | Process-level isolation | Full OS isolation |  

Docker is widely used in DevOps, microservices, cloud applications, and CI/CD pipelines for efficient software deployment.

### Container and Its Life Cycle  

A container is a lightweight, portable unit that packages an application along with its dependencies, libraries, and configurations. It runs in an isolated environment on a shared operating system kernel, ensuring consistency across different environments. Containers are widely used in DevOps, cloud computing, and microservices architectures.  

### Container Life Cycle  

A container follows a specific life cycle from creation to termination. The main stages are:  

1. Created – The container is created but not yet running.  
   - Command: `docker create nginx`  

2. Running – The container is in an active state, executing the application.  
   - Command: `docker start <container_id>` or `docker run nginx`  

3. Paused – The container’s execution is temporarily stopped.  
   - Command: `docker pause <container_id>`  

4. Unpaused – The container resumes execution after being paused.  
   - Command: `docker unpause <container_id>`  

5. Stopped – The container is halted, but its state is preserved.  
   - Command: `docker stop <container_id>`  

6. Restarted – The container is stopped and then restarted.  
   - Command: `docker restart <container_id>`  

7. Exited – The container has stopped running, either manually or due to an error.  
   - Command: `docker ps -a` (to view exited containers)  

8. Deleted (Removed) – The container is permanently removed.  
   - Command: `docker rm <container_id>`  

### Additional States  
- OOMKilled – The container is terminated due to an Out of Memory (OOM) error.  
- Dead – The container is unresponsive and cannot be restarted.  

Containers help in achieving fast deployment, portability, resource efficiency, and scalability, making them a core component of modern application development.


### Namespaces and Cgroups  

Namespaces and Cgroups (Control Groups) are key Linux kernel features that provide isolation and resource management for containers. They ensure that containers run independently and efficiently without interfering with each other or the host system.  

#### Namespaces (Isolation)  
Namespaces create isolated environments for containers by separating system resources. Each container gets its own instance of these resources, preventing conflicts between containers or with the host system.  

Types of Namespaces:  
1. PID Namespace – Isolates process IDs, so each container has its own process tree.  
2. UTS Namespace – Allows a container to have its own hostname and domain name.  
3. Mount Namespace – Gives each container its own filesystem, preventing access to the host’s filesystem.  
4. Network Namespace – Provides each container with its own network interfaces, IP addresses, and routing tables.  
5. IPC Namespace – Isolates interprocess communication, preventing shared memory access across containers.  
6. User Namespace – Allows a container to have different user and group IDs than the host, enhancing security.  

#### Cgroups (Resource Management)  
Control Groups (Cgroups) manage and limit the resources that containers can use, preventing a single container from consuming all system resources.  

Key Features of Cgroups:  
1. CPU Limits – Restricts the amount of CPU a container can use.  
2. Memory Limits – Defines the maximum amount of RAM a container can consume.  
3. I/O Limits – Controls disk read/write speeds to avoid resource hogging.  
4. Network Bandwidth – Regulates network usage per container.  
5. Process Limits – Restricts the number of processes a container can create.  

Namespaces provide isolation, while Cgroups ensure efficient resource allocation, making containers lightweight, secure, and scalable.

### Basic Docker Commands  

Here are some essential Docker commands for managing containers and images.  

#### Container Management Commands  
1. `docker run nginx` – Runs an Nginx container.  
2. `docker stop <container_id>` – Stops a running container.  
3. `docker rm <container_id>` – Removes a stopped container.  
4. `docker pause <container_id>` – Pauses a running container.  
5. `docker unpause <container_id>` – Resumes a paused container.  

#### Image Management Commands  
6. `docker rmi <image_id>` – Removes a Docker image.  
7. `docker system prune -a` – Removes all unused containers, networks, images, and caches.  

#### Monitoring and Inspection Commands  
8. `docker logs <container_id>` – Shows logs of a container.  
9. `docker inspect <container_id>` – Displays detailed information about a container or image.  
10. `docker stats` – Shows real-time resource usage of running containers.  

These commands help in managing and troubleshooting Docker containers efficiently.