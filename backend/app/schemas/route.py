from pydantic import BaseModel, ConfigDict
from typing import List, Optional
import uuid

class BaseSchema(BaseModel):
    model_config = ConfigDict(from_attributes=True)

class CustomerAddress(BaseSchema):
    customerName: str
    city: str
    postCode: str
    streetName: str
    streetNumber: str

class RouteSimple(BaseSchema):
    routeId: uuid.UUID
    routeName: str
    customers: List[CustomerAddress]

class ProductSimple(BaseSchema):
    productName: str
    amount: int
    price: float

class RouteOrder(BaseSchema):
    orderId: uuid.UUID
    customerName: str
    city: str
    postCode: str
    streetName: str
    streetNumber: str
    products: List[ProductSimple]

class RouteOrders(BaseSchema):
    routeId: uuid.UUID
    routeName: str
    orders: List[RouteOrder]