from sqlalchemy.orm import Session
from app.models.site_config import SiteConfig
from app.schemas.site_config import SiteConfigLoginPageOut

class SiteConfigCRUD:
    
    def get_site_config(self, db: Session) -> SiteConfigLoginPageOut | None:
        site_config = db.query(SiteConfig).first()
        if not site_config:
            return None
        return SiteConfigLoginPageOut(
            companyName=site_config.companyName,
            logoPath=site_config.logoPath
        )