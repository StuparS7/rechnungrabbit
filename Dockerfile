# Folosește o imagine oficială Python ca bază
FROM python:3.12-slim

# Setează directorul de lucru în interiorul containerului.
# Acesta poate fi orice nume, de ex. /app. Nu are legătură cu folderul tău 'api'.
WORKDIR /app

# Instalează dependențele de sistem pentru weasyprint
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copiază fișierul de dependențe din rădăcina proiectului tău în container
COPY requirements.txt .

# Instalează pachetele Python
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Comanda pentru a porni serverul Uvicorn.
# Acum, 'index.py' se află în /app, deci comanda va funcționa.
# Folosește variabila de mediu $PORT furnizată de Vercel
CMD uvicorn index:app --host 0.0.0.0 --port $PORT
