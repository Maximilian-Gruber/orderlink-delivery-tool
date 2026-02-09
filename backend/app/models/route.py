from sqlalchemy import *
from sqlalchemy.orm import relationship
from app.database import Base

class Route(Base):
    __tablename__ = "routes"

    routeId = Column(String, primary_key=True)
    name = Column(String)
    deleted = Column(Boolean, default=False)

    orders = relationship("RoutesOnOrders", back_populates="route")


class RoutesOnOrders(Base):
    __tablename__ = "routesOrders"

    routeId = Column(String, ForeignKey("routes.routeId"), primary_key=True)
    orderId = Column(String, ForeignKey("orders.orderId"), primary_key=True)

    route = relationship("Route", back_populates="orders")
    order = relationship("Order", back_populates="routes")
