from sqlalchemy import *
from sqlalchemy.orm import relationship
from app.models.enums import OrderState
from app.database import Base

class Order(Base):
    __tablename__ = "orders"

    orderId = Column(String, primary_key=True)
    customerReference = Column(Integer, ForeignKey("customers.customerReference"), index=True)
    orderDate = Column(DateTime, server_default=func.now(), index=True)
    deliveryDate = Column(DateTime, nullable=True)
    deleted = Column(Boolean, default=False)
    orderState = Column(Enum(OrderState), default=OrderState.ORDER_PLACED)
    selfCollect = Column(Boolean, default=False)

    customer = relationship("Customer", back_populates="orders")
    products = relationship("OrderOnProducts", back_populates="order")
    invoice = relationship("Invoice", uselist=False, back_populates="order")
    routes = relationship("RoutesOnOrders", back_populates="order")


class OrderOnProducts(Base):
    __tablename__ = "ordersProducts"

    orderId = Column(String, ForeignKey("orders.orderId"), primary_key=True)
    productId = Column(String, ForeignKey("products.productId"), primary_key=True)
    orderDate = Column(DateTime, server_default=func.now())
    productAmount = Column(Integer, default=1)

    order = relationship("Order", back_populates="products")
    product = relationship("Product", back_populates="orders")
