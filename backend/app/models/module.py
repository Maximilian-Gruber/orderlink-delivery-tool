from sqlalchemy import Column, String, Integer, DateTime, Enum, Text, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from app.models.enums import ModuleEnum
from app.database import Base

class Module(Base):
    __tablename__ = "modules"

    name = Column(Enum(ModuleEnum), primary_key=True)
    description = Column(Text, nullable=True)
    priceCents = Column(Integer, default=0)
    createdAt = Column(DateTime, default=datetime.utcnow)
    updatedAt = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    EnabledModule = relationship("EnabledModule", back_populates="module")

class EnabledModule(Base):
    __tablename__ = "enabled_modules"

    id = Column(String, primary_key=True)
    tenantId = Column(String, ForeignKey("tenant_data.tenantId"))
    moduleName = Column(Enum(ModuleEnum), ForeignKey("modules.name"))
    enabledAt = Column(DateTime, default=datetime.utcnow)

    tenantData = relationship("TenantData", back_populates="enabledModules")
    module = relationship("Module", back_populates="EnabledModule")

    __table_args__ = (
        # Prevent duplicate activations
        {"sqlite_autoincrement": True},
    )
