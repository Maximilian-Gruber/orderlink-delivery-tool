from sqlalchemy import *
from sqlalchemy.orm import relationship
from app.database import Base

class Cart(Base):
    __tablename__ = "carts"

    cartId = Column(String, primary_key=True)
    customerReference = Column(Integer, ForeignKey("customers.customerReference"), unique=True)

    customer = relationship("Customer", back_populates="cart")
    products = relationship("CartOnProducts", back_populates="cart")


class CartOnProducts(Base):
    __tablename__ = "cartsProducts"

    cartId = Column(String, ForeignKey("carts.cartId"), primary_key=True)
    productId = Column(String, ForeignKey("products.productId"), primary_key=True)
    quantity = Column(Integer, default=1)

    cart = relationship("Cart", back_populates="products")
    product = relationship("Product", back_populates="carts")
