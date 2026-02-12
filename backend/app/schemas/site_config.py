from pydantic import BaseModel
import uuid

class SiteConfigLoginPageOut(BaseModel):
    companyName: str
    logoPath: str