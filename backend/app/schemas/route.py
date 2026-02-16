from pydantic import BaseModel, ConfigDict
from typing import List, Optional

class BaseSchema(BaseModel):
    model_config = ConfigDict(from_attributes=True)

class CustomerAddress(BaseSchema):
    customerName: str
    city: str
    postCode: str
    streetName: str
    streetNumber: str

class RouteSimple(BaseSchema):
    routeId: str
    routeName: str
    customers: List[CustomerAddress]

class ProductSimple(BaseSchema):
    productName: str
    amount: int
    price: float

class RouteOrder(BaseSchema):
    orderId: str
    customerName: str
    city: str
    postCode: str
    streetName: str
    streetNumber: str
    products: List[ProductSimple]

class RouteOrders(BaseSchema):
    routeId: str
    routeName: str
    orders: List[RouteOrder]