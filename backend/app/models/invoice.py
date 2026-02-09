from sqlalchemy import Column, String, Integer, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base

class Invoice(Base):
    __tablename__ = "invoices"

    invoiceId = Column(String, primary_key=True)
    orderId = Column(String, ForeignKey("orders.orderId"), unique=True)
    invoiceAmount = Column(Integer, nullable=False)
    paymentDate = Column(DateTime, default=datetime.utcnow)
    pdfUrl = Column(String(255), nullable=False)
    deleted = Column(Boolean, default=False)

    order = relationship("Order", back_populates="invoice")
