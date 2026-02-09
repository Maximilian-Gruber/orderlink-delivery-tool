from sqlalchemy import Column, String, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class Role(Base):
    __tablename__ = "roles"

    name = Column(String, primary_key=True)
    description = Column(String, nullable=True)
    deleted = Column(Boolean, default=False)

    employees = relationship("Employees", back_populates="role_rel", cascade="all, delete-orphan")
    permissions = relationship("Permission", back_populates="role_rel", cascade="all, delete-orphan")


class Employees(Base):
    __tablename__ = "employees"

    employeeId = Column(String, primary_key=True)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    firstName = Column(String)
    lastName = Column(String, index=True)
    deleted = Column(Boolean, default=False)
    superAdmin = Column(Boolean, default=False)

    role = Column(String, ForeignKey("roles.name"))
    role_rel = relationship("Role", back_populates="employees")
    otp = relationship("Otp", back_populates="employee", cascade="all, delete-orphan")
