from fastapi import FastAPI
from .database import engine, Base
from .routers import auth, site_config, route
import app.models

#Base.metadata.create_all(bind=engine)

app = FastAPI(title="FastAPI + Postgres (Docker Safe Setup)")

app.include_router(auth.router)
app.include_router(site_config.router)
app.include_router(route.router)

@app.get("/health", tags=["health check"])
def health():
    return {"status": "ok"}
