from sqlalchemy import *
from sqlalchemy.orm import relationship
from app.models.enums import BusinessSector
from app.database import Base

class Customer(Base):
    __tablename__ = "customers"

    customerId = Column(String, primary_key=True)
    customerReference = Column(Integer, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    phoneNumber = Column(String)
    password = Column(String)
    firstName = Column(String, nullable=True)
    lastName = Column(String, index=True)
    companyNumber = Column(String, nullable=True)
    modifiedAt = Column(DateTime, onupdate=func.now())
    deleted = Column(Boolean, default=False)
    signedUp = Column(DateTime, server_default=func.now())
    avatarPath = Column(String, nullable=True)
    addressId = Column(String, ForeignKey("addresses.addressId"))
    businessSector = Column(Enum(BusinessSector), nullable=True)

    address = relationship("Address", back_populates="customers")
    cart = relationship("Cart", uselist=False, back_populates="customer")
    orders = relationship("Order", back_populates="customer")
    history = relationship("CustomerHistory", back_populates="customer")


class CustomerHistory(Base):
    __tablename__ = "customerHistory"

    historyId = Column(String, primary_key=True)
    customerReference = Column(Integer, ForeignKey("customers.customerReference"))
    email = Column(String)
    phoneNumber = Column(String)
    password = Column(String)
    firstName = Column(String, nullable=True)
    lastName = Column(String)
    companyNumber = Column(String, nullable=True)
    modifiedAt = Column(DateTime, onupdate=func.now())
    deleted = Column(Boolean, default=False)
    signedUp = Column(DateTime, server_default=func.now())
    avatarPath = Column(String, nullable=True)
    addressId = Column(String)
    businessSector = Column(Enum(BusinessSector), nullable=True)

    customer = relationship("Customer", back_populates="history")
