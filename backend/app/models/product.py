from sqlalchemy import *
from sqlalchemy.orm import relationship
from app.database import Base

class Category(Base):
    __tablename__ = "categories"

    categoryId = Column(String, primary_key=True)
    name = Column(String, unique=True)
    imagePath = Column(String, nullable=True)
    deleted = Column(Boolean, default=False)

    products = relationship("Product", back_populates="category")
    history = relationship("ProductHistory", back_populates="category")


class Product(Base):
    __tablename__ = "products"

    productId = Column(String, primary_key=True)
    name = Column(String, index=True)
    price = Column(Integer)
    description = Column(String)
    stock = Column(Integer)
    imagePath = Column(String, nullable=True)
    createdAt = Column(DateTime, server_default=func.now())
    modifiedAt = Column(DateTime, onupdate=func.now())
    deleted = Column(Boolean, default=False)
    categoryId = Column(String, ForeignKey("categories.categoryId"))

    category = relationship("Category", back_populates="products")
    carts = relationship("CartOnProducts", back_populates="product")
    orders = relationship("OrderOnProducts", back_populates="product")
    history = relationship("ProductHistory", back_populates="product")


class ProductHistory(Base):
    __tablename__ = "productHistory"

    historyId = Column(String, primary_key=True)
    productId = Column(String, ForeignKey("products.productId"))
    name = Column(String)
    price = Column(Integer)
    description = Column(String)
    stock = Column(Integer)
    imagePath = Column(String, nullable=True)
    createdAt = Column(DateTime, server_default=func.now())
    modifiedAt = Column(DateTime, onupdate=func.now())
    deleted = Column(Boolean, default=False)
    categoryId = Column(String, ForeignKey("categories.categoryId"))
    version = Column(Integer)

    product = relationship("Product", back_populates="history")
    category = relationship("Category", back_populates="history")
