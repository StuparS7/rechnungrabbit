# Imagine super simplă
FROM busybox:latest

# Setează directorul de lucru
WORKDIR /app

# Creează un fișier de test
RUN echo "Testul functioneaza!" > index.html

# Pornește un server web simplu care servește fișierele din directorul curent
# pe portul 8000
CMD ["httpd", "-f", "-p", "8000", "-h", "/app"]
