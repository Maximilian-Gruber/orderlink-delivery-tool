from sqlalchemy import Column, String, Integer, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base

class Otp(Base):
    __tablename__ = "otp"

    id = Column(String, primary_key=True)
    code = Column(String, nullable=False, unique=True)
    employeeId = Column(String, ForeignKey("employees.employeeId"))
    expiresAt = Column(String, nullable=False)
    used = Column(Boolean, default=False)

    employee = relationship("Employees", back_populates="otp")