from pydantic import BaseModel, ConfigDict
from typing import List, Optional

class BaseSchema(BaseModel):
    model_config = ConfigDict(from_attributes=True)

class ProductSimple(BaseSchema):
    name: str
    productAmount: int

class OrderSimple(BaseSchema):
    orderId: str
    customerName: str
    orderState: str
    city: str
    postCode: str
    streetName: str
    streetNumber: str
    products: List[ProductSimple]

class RouteSimple(BaseSchema):
    routeId: str
    routeName: str
    orders: List[OrderSimple]