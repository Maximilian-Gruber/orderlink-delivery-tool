from sqlalchemy.orm import Session, joinedload, contains_eager
from sqlalchemy import and_
import requests
from app.models.route import Route, RoutesOnOrders
from app.models.order import Order, OrderOnProducts
from app.models.customer import Customer
from app.models.enums import OrderState
import os

GEOAPIFY_KEY = os.getenv("GEOAPIFY_KEY")

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
    def _geocode_address(street, number, city, postcode):
        if not GEOAPIFY_KEY:
            return None, None
        text = f"{street} {number}, {postcode} {city}, Austria"
        url = "https://api.geoapify.com/v1/geocode/search"
        params = {'text': text, 'apiKey': GEOAPIFY_KEY, 'limit': 1}
        try:
            response = requests.get(url, params=params, timeout=5)
            data = response.json()
            if data and data.get('features'):
                coords = data['features'][0]['geometry']['coordinates']
                return float(coords[1]), float(coords[0])
        except Exception as e:
            print(f"Geoapify Geocoding Error: {e}")
        return None, None

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
                    {"productName": op.product.name, "amount": op.productAmount, "price": op.product.price}
                    for op in o.products
                ]
            })

        return {"routeId": route.routeId, "routeName": route.name, "orders": orders_list}
    
    @staticmethod
    def get_orders_per_route_fastest(db: Session, routeId: str, current_lat: float = None, current_lon: float = None):
        routes = RouteCRUD._base_query(db).filter(Route.routeId == routeId).all()
        if not routes: return None
        route = routes[0]

        orders_data = []
        shipments = []

        for roo in route.orders:
            o = roo.order
            addr = o.customer.address
            
            order_entry = {
                "orderId": o.orderId,
                "customerName": f"{o.customer.firstName} {o.customer.lastName}",
                "city": addr.city if addr else "N/A",
                "postCode": addr.postCode if addr else "N/A",
                "streetName": addr.streetName if addr else "N/A",
                "streetNumber": addr.streetNumber if addr else "N/A",
                "products": [{"productName": op.product.name, "amount": op.productAmount, "price": op.product.price} for op in o.products]
            }

            lat, lon = RouteCRUD._geocode_address(addr.streetName, addr.streetNumber, addr.city, addr.postCode)
            
            if lat and lon:
                order_entry["_lat"] = lat
                order_entry["_lon"] = lon
                shipments.append({
                    "id": str(len(orders_data)), 
                    "location": [lon, lat]
                })
            
            orders_data.append(order_entry)

        if len(shipments) > 1:
            url = f"https://api.geoapify.com/v1/routeplanner?apiKey={GEOAPIFY_KEY}"
            
            start_location = [current_lon, current_lat] if (current_lat and current_lon) else shipments[0]["location"]
            
            payload = {
                "mode": "drive",
                "agents": [{"start_location": start_location}],
                "shipments": shipments,
                "type": "balanced"
            }

            try:
                response = requests.post(url, json=payload, timeout=15)
                res_data = response.json()

                if "features" in res_data and res_data["features"]:
                    actions = res_data["features"][0]["properties"]["actions"]
                    optimized_orders = []
                    seen_ids = set()

                    for action in actions:
                        if "shipment_id" in action:
                            idx = int(action["shipment_id"])
                            optimized_orders.append(orders_data[idx])
                            seen_ids.add(idx)
                    
                    for i, o in enumerate(orders_data):
                        if i not in seen_ids:
                            optimized_orders.append(o)
                    
                    orders_data = optimized_orders
            except Exception as e:
                print(f"Geoapify Route Error: {e}")

        for o in orders_data:
            o.pop("_lat", None); o.pop("_lon", None)

        return {"routeId": route.routeId, "routeName": route.name, "orders": orders_data}