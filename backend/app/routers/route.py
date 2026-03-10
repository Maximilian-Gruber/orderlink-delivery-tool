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
    result = RouteCRUD.get_active_routes_with_orders(db)

    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No active routes found"
        )

    return result


@router.get("/{routeId}/orders", response_model=RouteOrders)
def get_orders_per_route(routeId: str, db: Session = Depends(get_db), current_user: Employees = Depends(get_current_user)):
    result = RouteCRUD.get_orders_per_route(db, routeId)

    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Route with id {routeId} not found"
        )

    return result


@router.get("/{routeId}/orders/fastest", response_model=RouteOrders)
def get_fastest_delivery_per_route(routeId: str, db: Session = Depends(get_db), current_user: Employees = Depends(get_current_user), lat: float = None, lon: float = None
):
    try:
        result = RouteCRUD.get_orders_per_route_fastest(db, routeId, current_lat=lat, current_lon=lon)
        
        if result is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Route {routeId} not found or has no active orders"
            )
        return result

    except HTTPException as he:
        raise he
    except Exception as e:
        print(f"Server Error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while calculating the fastest route."
        )