# Day-1
- deployment in pyhiscal,vm and containers
- docker
- docker architecture
- containers
- namespaces & cgroups
- contaienr life cycle
- basic commands[logs,inspect,stats,run,rmi,rm,stop,pause,unpause,prune,system]

Dockerfile
```bash
FROM ubuntu:latest
RUN apt update && apt install -y nginx && rm -rf /var/lib/apt/lists/*
RUN rm -rf /var/www/html/* /usr/share/nginx/html/*
COPY index.html /usr/share/nginx/html/index.html
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN echo 'server { \
    listen 80; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ =404; \
    } \
    access_log /dev/stdout; \
    error_log /dev/stderr; \
}' > /etc/nginx/sites-available/default
EXPOSE 80
CMD ["/bin/bash", "-c", "/entrypoint.sh && nginx -g 'daemon off;'"]
```

entrypoint.sh
```bash
#!/bin/sh
hostname -i > /usr/share/nginx/html/ip.txt
exec "$@"
```

index.html
```bash
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Container IP</title>
    <style>
        body { text-align: center; font-family: Arial, sans-serif; margin-top: 50px; }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>Container IP: <span id="ip">Loading...</span></h1>
    <script>
        fetch('/ip.txt')
            .then(response => response.text())
            .then(data => document.getElementById('ip').textContent = data)
            .catch(error => console.error('Error fetching IP:', error));
    </script>
</body>
</html>
```



































**InterviewQuestions**
- What are the challenges that are there applications are deployed in Physical Machines
- How VM machines addressses the challenges in Physical Machines
- Why VM are not suitable for micro services deployments and what are the challenges in VM deployment
- What is virtulization 
- What is containerization
- What is docker
- Can you please explain docker architecture
- What is Container and it's benefits
- What is namepsaces and cGroups and role in containers
- What are the Dangling images
- How can you inspect the container|network|volumes|image|containers
- How to check the logs of container
- Can you Please Explain Container lifeCycle
 