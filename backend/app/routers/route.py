from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.route import RouteSimple
from app.crud.route import RouteCRUD

router = APIRouter(prefix="/routes", tags=["routes"])

@router.get("/active-routes-with-orders-products", response_model=list[RouteSimple])
def get_logistics_overview(db: Session = Depends(get_db)):
    routes = RouteCRUD.get_active_routes_with_orders(db)
    
    result = []
    for r in routes:
        orders_list = []
        for roo in r.orders:
            o = roo.order
            if o.deliveryDate is None:
                addr = o.customer.address 
                
                orders_list.append({
                    "orderId": o.orderId,
                    "customerName": f"{o.customer.firstName} {o.customer.lastName}",
                    "orderState": o.orderState.value if hasattr(o.orderState, 'value') else str(o.orderState),
                    "city": addr.city if addr else "N/A",
                    "postCode": addr.postCode if addr else "N/A",
                    "streetName": addr.streetName if addr else "N/A",
                    "streetNumber": addr.streetNumber if addr else "N/A",
                    "products": [
                        {
                            "name": op.product.name, 
                            "productAmount": op.productAmount
                        } for op in o.products
                    ]
                })
        
        if orders_list:
            result.append({
                "routeId": r.routeId,
                "routeName": r.name,
                "orders": orders_list
            })
            
    return result