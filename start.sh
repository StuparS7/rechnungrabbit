#!/bin/bash
exec uvicorn index:app --host 0.0.0.0 --port ${PORT:-8000}
