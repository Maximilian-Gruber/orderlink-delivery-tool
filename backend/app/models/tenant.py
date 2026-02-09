from sqlalchemy import Column, String, DateTime, Integer, Enum
from sqlalchemy.orm import relationship
from app.models.module import EnabledModule
from datetime import datetime
import enum
from app.models.enums import TenantStatus
from app.database import Base

class TenantData(Base):
    __tablename__ = "tenant_data"

    tenantId = Column(String, primary_key=True)
    status = Column(Enum(TenantStatus), default=TenantStatus.TRIAL)
    trialStartedAt = Column(DateTime, default=datetime.utcnow)
    trialEndsAt = Column(DateTime)
    billingCustomerId = Column(String, nullable=True)
    maxEmployees = Column(Integer, default=3)

    enabledModules = relationship("EnabledModule", back_populates="tenantData")
    siteConfig = relationship("SiteConfig", uselist=False, back_populates="tenant")
