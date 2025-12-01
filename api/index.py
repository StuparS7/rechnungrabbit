from fastapi import FastAPI, Request, Form, UploadFile, File
from fastapi.responses import HTMLResponse, Response
from fastapi.templating import Jinja2Templates
from weasyprint import HTML
import re
from typing import Annotated, Optional
import json
import base64
from pathlib import Path

app = FastAPI()

# Construiește o cale absolută către directorul de șabloane
# Path(__file__) -> api/index.py
# .parent -> api/
# .parent -> rădăcina proiectului (unde se află acum 'templates')
templates = Jinja2Templates(directory=Path(__file__).parent.parent / "templates")

@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.get("/preise", response_class=HTMLResponse)
async def preise(request: Request):
    return templates.TemplateResponse("preise.html", {"request": request})

@app.get("/rechnung-erstellen", response_class=HTMLResponse)
async def rechnung_erstellen_get(request: Request):
    return templates.TemplateResponse("rechnung_erstellen.html", {"request": request})

@app.post("/rechnung-erstellen")
async def rechnung_erstellen_post(
    request: Request, 
    logo: Annotated[Optional[UploadFile], File()] = None
):
    form_data = await request.form()

    # Procesarea logo-ului
    logo_data_url = None
    # Verificăm dacă este un fișier încărcat (are un nume de fișier)
    if logo and logo.filename:
        try:
            # Citim conținutul fișierului
            print(f"Processing logo: {logo.filename}, Content-Type: {logo.content_type}")
            image_bytes = await logo.read()
            # Codificăm în base64
            base64_encoded_image = base64.b64encode(image_bytes).decode("utf-8")
            # Creăm un Data URL pentru a-l embeda în HTML
            logo_data_url = f"data:{logo.content_type};base64,{base64_encoded_image}"
            print("Logo successfully converted to Data URL.")
        except Exception as e:
            print(f"Error processing logo: {e}")

    invoice_data = {
        "supplier": {},
        "customer": {},
        "invoice_details": {},
        "items": []
    }
 
    items_dict = {}
    for key, value in form_data.items():
        # Sarim peste câmpul 'logo' deoarece este un fișier, nu text, și a fost deja procesat
        if key == 'logo':
            continue

        # Ne asigurăm că aplicăm .strip() doar pe string-uri
        # Câmpurile goale pot fi interpretate diferit în formularele multipart
        clean_value = value.strip() if isinstance(value, str) else value

        match = re.match(r"items\[(\d+)\]\[(\w+)\]", key)
        if match:
            index, field = match.groups()
            index = int(index)

            if index not in items_dict:
                items_dict[index] = {}

            if field in ['quantity', 'unit_price'] and not clean_value:
                items_dict[index][field] = '0'
            else:
                items_dict[index][field] = clean_value if clean_value else ''

        elif key.startswith("sender_"):
            invoice_data["supplier"][key.replace("sender_", "")] = clean_value
        elif key.startswith("receiver_"):
            invoice_data["customer"][key.replace("receiver_", "")] = clean_value
        else:
            invoice_data["invoice_details"][key] = clean_value

    invoice_data["items"] = [items_dict[i] for i in sorted(items_dict.keys())]

    print("="*50)
    print("Structured invoice data:")
    print(json.dumps(invoice_data, indent=2))
    print(f"Logo URL available for template: {'Yes' if logo_data_url else 'No'}")
    
    # Calculează totalurile
    net_total = sum(float(item.get('quantity', 0)) * float(item.get('unit_price', 0)) for item in invoice_data['items'])
    vat_total = net_total * 0.19
    gross_total = net_total + vat_total
    print(f"Calculated Totals: Net={net_total}, VAT={vat_total}, Gross={gross_total}")
    print("="*50)

    # Combină toate datele pentru a le trimite șablonului
    template_data = {
        "request": request,
        **invoice_data,
        "logo_data_url": logo_data_url,
        "net_total": net_total,
        "vat_total": vat_total,
        "gross_total": gross_total
    }

    # Randează șablonul HTML cu datele facturii
    html_string = templates.get_template("invoice_template.html").render(template_data)

    # Generează PDF-ul din string-ul HTML
    pdf_bytes = HTML(string=html_string).write_pdf()

    # Returnează PDF-ul ca răspuns pentru descărcare
    # Verifică dacă a fost specificat un nume de fișier în formular
    custom_filename = invoice_data["invoice_details"].get("pdf_filename")
    if custom_filename:
        # Folosește numele specificat de utilizator, adăugând extensia .pdf dacă lipsește
        filename = f"{custom_filename}.pdf" if not custom_filename.lower().endswith('.pdf') else custom_filename
    else:
        # Folosește numele generat automat ca alternativă
        filename = f'rechnung-{invoice_data["invoice_details"].get("invoice_number", "neu")}.pdf'

    headers = {
        'Content-Disposition': f'attachment; filename="{filename}"'
    }
    return Response(content=pdf_bytes, media_type="application/pdf", headers=headers)
