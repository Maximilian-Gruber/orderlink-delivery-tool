from sqlalchemy.orm import Session
from app.models.route import Route, RoutesOnOrders
from app.models.order import Order, OrderOnProducts
from app.models.customer import Customer
from sqlalchemy.orm import Session, joinedload, selectinload
from sqlalchemy import and_
from app.models.enums import OrderState

class RouteCRUD:
    
    def get_active_routes_with_orders(db: Session):
        return db.query(Route).join(Route.orders).join(RoutesOnOrders.order).filter(
            and_(Order.deliveryDate.is_(None), Order.selfCollect.is_(False), Order.orderState != OrderState.DELIVERED, Order.orderState != OrderState.ORDER_COLLECTED)
        ).options(
            joinedload(Route.orders).joinedload(RoutesOnOrders.order).options(
                joinedload(Order.customer).joinedload(Customer.address),
                joinedload(Order.products).joinedload(OrderOnProducts.product)
            )
        ).all()