#!/bin/bash

# Instalează dependențele de sistem necesare pentru weasyprint
# Lista a fost extinsă pentru a include pachete pentru grafică și imagini.
apt-get update && apt-get install -y \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0