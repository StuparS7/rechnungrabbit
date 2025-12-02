# Folosește o imagine oficială Python ca bază
FROM python:3.12-slim

# Setează directorul de lucru în container
WORKDIR /app

# Instalează dependențele de sistem pentru weasyprint
# --no-install-recommends reduce dimensiunea imaginii
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copiază fișierele de dependențe și instalează pachetele Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiază tot restul codului aplicației în container
COPY . .

# Comanda pentru a porni serverul Uvicorn. Ascultă pe 0.0.0.0 pentru a fi accesibil din afara containerului
# Folosește variabila de mediu $PORT furnizată de Vercel
CMD uvicorn index:app --host 0.0.0.0 --port $PORT