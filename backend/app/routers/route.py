from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.route import RouteSimple, RouteOrders
from app.crud.route import RouteCRUD
from app.dependencies.auth import get_current_user
from app.models.employee import Employees

router = APIRouter(prefix="/routes", tags=["routes"])

@router.get("/active-routes-with-orders-products", response_model=list[RouteSimple])
def get_logistics_overview(db: Session = Depends(get_db), current_user: Employees = Depends(get_current_user)):
    routes = RouteCRUD.get_active_routes_with_orders(db)
    
    result = []
    for r in routes:
        orders_list = []
        for roo in r.orders:
            o = roo.order
            if o.deliveryDate is None:
                addr = o.customer.address 
                orders_list.append({
                    "customerName": f"{o.customer.firstName} {o.customer.lastName}",
                    "city": addr.city if addr else "N/A",
                    "postCode": addr.postCode if addr else "N/A",
                    "streetName": addr.streetName if addr else "N/A",
                    "streetNumber": addr.streetNumber if addr else "N/A",
                })
        
        if orders_list:
            result.append({
                "routeId": r.routeId,
                "routeName": r.name,
                "customers": orders_list
            })
            
    return result


@router.get("/{routeId}/orders", response_model=RouteOrders)
def get_orders_per_route(routeId: str, db: Session = Depends(get_db), current_user: Employees = Depends(get_current_user)):
    # Achtung: Aufruf korrigieren, falls Methode statisch ist, oder Instanz nutzen
    # Im CRUD Code oben war es als statische Methode definiert (kein self), daher:
    route = RouteCRUD.get_orders_per_route(db, routeId)
    
    if not route:
        # HIER IST DIE ÄNDERUNG: Exception statt return None
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Route with id {routeId} not found"
        )
    
    orders_list = []
    for roo in route.orders:
        o = roo.order
        
        address = o.customer.address
        
        orders_list.append({
            "orderId": o.orderId,
            "customerName": f"{o.customer.firstName} {o.customer.lastName}",
            "city": address.city if address else "N/A",
            "postCode": address.postCode if address else "N/A",
            "streetName": address.streetName if address else "N/A",
            "streetNumber": address.streetNumber if address else "N/A",
            "products": [
                {
                    "productName": op.product.name, 
                    "amount": op.productAmount, 
                    "price": op.product.price
                } for op in o.products
            ]
        })
    
    return {
        "routeId": route.routeId,
        "routeName": route.name,
        "orders": orders_list
    }