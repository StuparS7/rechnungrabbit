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

# Expune portul pe care va rula aplicația. Vercel va folosi variabila PORT.
# Setăm un default pentru rulare locală.
ENV PORT 8000
EXPOSE 8000

# Comanda pentru a porni serverul Uvicorn, folosind 'exec' pentru o gestionare corectă a procesului
CMD exec uvicorn index:app --host 0.0.0.0 --port ${PORT}
