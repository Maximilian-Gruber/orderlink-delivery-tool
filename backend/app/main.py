from fastapi import FastAPI
from .database import engine, Base
from .routers import auth, site_config, route, employee
import app.models
from fastapi.middleware.cors import CORSMiddleware
import os

if os.getenv("DB_INIT", "false").lower() == "true":
    Base.metadata.create_all(bind=engine)

app = FastAPI(title="FastAPI + Postgres (Docker Safe Setup)")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(auth.router)
app.include_router(site_config.router)
app.include_router(route.router)
app.include_router(employee.router)

@app.get("/health", tags=["health check"])
def health():
    return {"status": "ok"}
