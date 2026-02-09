from sqlalchemy import *
from sqlalchemy.orm import relationship
from app.database import Base

class Address(Base):
    __tablename__ = "addresses"

    addressId = Column(String, primary_key=True)
    city = Column(String)
    country = Column(String)
    postCode = Column(String, index=True)
    state = Column(String)
    streetName = Column(String)
    streetNumber = Column(String)
    modifiedAt = Column(DateTime, onupdate=func.now())
    deleted = Column(Boolean, default=False)

    customers = relationship("Customer", back_populates="address")
    siteConfig = relationship("SiteConfig", back_populates="address")
