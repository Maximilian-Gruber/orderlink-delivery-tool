from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base

class SiteConfig(Base):
    __tablename__ = "siteConfigs"

    siteConfigId = Column(String, primary_key=True)
    #tenantId = Column(String, ForeignKey("tenant_data.tenantId"), unique=True, nullable=True)

    companyName = Column(String, nullable=False)
    logoPath = Column(String, nullable=True)
    email = Column(String, unique=True, nullable=False)
    phoneNumber = Column(String, nullable=False)
    iban = Column(String, nullable=True)
    companyNumber = Column(String, nullable=True)
    addressId = Column(String, ForeignKey("addresses.addressId"))
    modifiedAt = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    #tenant = relationship("TenantData", back_populates="siteConfig")
    address = relationship("Address")
