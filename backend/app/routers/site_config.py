from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.site_config import SiteConfigLoginPageOut
from app.crud.site_config import SiteConfigCRUD

router = APIRouter(prefix="/site-config", tags=["site-config"])

@router.get("/login-page", response_model=SiteConfigLoginPageOut)
def get_site_config(db: Session = Depends(get_db)):
    crud = SiteConfigCRUD()
    site_config = crud.get_site_config(db)
    if not site_config:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Site configuration not found",
        )
    return site_config