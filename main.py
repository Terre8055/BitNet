from fastapi import FastAPI, Form, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware

import subprocess

app = FastAPI()

app.mount("/static", StaticFiles(directory="static"), name="static")

templates = Jinja2Templates(directory="static")

@app.get("/", response_class=HTMLResponse)
async def read_index(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.post("/predict", response_class=HTMLResponse)
async def predict(
    request: Request,
    model: str = Form(...),
    prompt: str = Form(...),
    tokens: int = Form(...),
    temperature: float = Form(...)
):
    try:
        model_file = f'models/{model}/ggml-model-i2_s.gguf' if model != 'Llama3-8B-1.58-100B-tokens' else 'models/Llama3-8B-1.58-100B-tokens/ggml-model-tl2.gguf'
        command = [
            'python', 'run_inference.py',
            '-m', model_file,
            '-p', prompt,
            '-n', str(tokens),
            '-temp', str(temperature)
        ]
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        output = result.stdout
    except subprocess.CalledProcessError as e:
        output = f"Error: {e.stderr}"

    return templates.TemplateResponse("index.html", {
        "request": request,
        "prompt": prompt,
        "output": output
    })


@app.get("/health", response_class=HTMLResponse)  # Health check endpoint
async def health_check():
    return {"status": "healthy"} 

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

