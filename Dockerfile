# Folosește o imagine oficială Python ca bază
FROM python:3.12-slim

# Setează directorul de lucru în interiorul containerului
WORKDIR /app

# Instalează dependențele de sistem necesare pentru WeasyPrint și curăță cache-ul apt
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copiază doar fișierul de dependențe pentru a beneficia de caching-ul Docker
COPY requirements.txt .

# Instalează pachetele Python specificate în requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copiază restul codului sursă al aplicației
COPY . .

# Copiază scriptul de pornire și îl face executabil
COPY start.sh .
RUN chmod +x ./start.sh

# Expune portul pe care va rula aplicația
EXPOSE 8000

# Comanda pentru a porni aplicația folosind scriptul
CMD ["./start.sh"]
