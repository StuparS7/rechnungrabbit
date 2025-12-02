# Imagine super simplă
FROM busybox:latest

# Setează directorul de lucru
WORKDIR /app

# Copiază fișierele aplicației (HTML, CSS, JS, etc.) în directorul de lucru din container
COPY . .

# Pornește un server web simplu care servește fișierele din directorul curent
# pe portul 8000
CMD ["httpd", "-f", "-p", "8000", "-h", "/app"]
