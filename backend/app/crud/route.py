from sqlalchemy.orm import Session, joinedload, contains_eager
from sqlalchemy import and_

from app.models.route import Route, RoutesOnOrders
from app.models.order import Order, OrderOnProducts
from app.models.customer import Customer
from app.models.enums import OrderState


class RouteCRUD:

    @staticmethod
    def _base_query(db: Session):
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
        )

    @staticmethod
    def get_active_routes_with_orders(db: Session):

        routes = RouteCRUD._base_query(db).all()

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

    @staticmethod
    def get_orders_per_route(db: Session, routeId: str):

        routes = RouteCRUD._base_query(db).filter(Route.routeId == routeId).all()

        if not routes:
            return None

        route = routes[0]

        orders_list = []

        for roo in route.orders:
            o = roo.order
            addr = o.customer.address

            orders_list.append({
                "orderId": o.orderId,
                "customerName": f"{o.customer.firstName} {o.customer.lastName}",
                "city": addr.city if addr else "N/A",
                "postCode": addr.postCode if addr else "N/A",
                "streetName": addr.streetName if addr else "N/A",
                "streetNumber": addr.streetNumber if addr else "N/A",
                "products": [
                    {
                        "productName": op.product.name,
                        "amount": op.productAmount,
                        "price": op.product.price
                    }
                    for op in o.products
                ]
            })

        return {
            "routeId": route.routeId,
            "routeName": route.name,
            "orders": orders_list
        }
