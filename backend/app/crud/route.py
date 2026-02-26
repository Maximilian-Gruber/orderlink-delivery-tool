from sqlalchemy.orm import Session, joinedload, contains_eager
from sqlalchemy import and_
from app.models.route import Route, RoutesOnOrders
from app.models.order import Order, OrderOnProducts
from app.models.customer import Customer
from app.models.enums import OrderState

class RouteCRUD:
    
    @staticmethod
    def get_active_routes_with_orders(db: Session):
        return db.query(Route).join(Route.orders).join(RoutesOnOrders.order).filter(
            and_(
                Order.deliveryDate.is_(None), 
                Order.selfCollect.is_(False), 
                Order.orderState != OrderState.DELIVERED, 
                Order.orderState != OrderState.ORDER_COLLECTED
            )
        ).options(
            contains_eager(Route.orders).contains_eager(RoutesOnOrders.order).options(
                joinedload(Order.customer).joinedload(Customer.address),
                joinedload(Order.products).joinedload(OrderOnProducts.product)
            )
        ).all()
    
    @staticmethod
    def get_orders_per_route(db: Session, routeId: str):
        result = db.query(Route).join(Route.orders).join(RoutesOnOrders.order).filter(
            and_(
                Route.routeId == routeId,
                Order.deliveryDate.is_(None), 
                Order.selfCollect.is_(False), 
                Order.orderState != OrderState.DELIVERED, 
                Order.orderState != OrderState.ORDER_COLLECTED
            )
        ).options(
            contains_eager(Route.orders).contains_eager(RoutesOnOrders.order).options(
                joinedload(Order.customer).joinedload(Customer.address),
                joinedload(Order.products).joinedload(OrderOnProducts.product)
            )
        ).all()

        return result[0] if result else None