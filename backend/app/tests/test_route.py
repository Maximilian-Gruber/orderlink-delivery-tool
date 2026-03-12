import pytest
import uuid
from unittest.mock import MagicMock, patch, ANY
from fastapi import HTTPException


def test_get_logistics_overview_success(client):
    with patch("app.crud.route.RouteCRUD.get_active_routes_with_orders") as mocked_get:
        mock_customer = MagicMock()
        mock_customer.customerName = "Max Mustermann"
        mock_customer.city = "Wien"
        mock_customer.postCode = "1010"
        mock_customer.streetName = "Stephansplatz"
        mock_customer.streetNumber = "1"

        mock_route = MagicMock()
        mock_route.routeId = uuid.uuid4()
        mock_route.routeName = "Nord-Tour"
        mock_route.customers = [mock_customer]

        mocked_get.return_value = [mock_route]

        response = client.get("/routes/active-routes-with-orders-products")

        assert response.status_code == 200
        assert len(response.json()) == 1
        assert response.json()[0]["routeName"] == "Nord-Tour"


def test_get_logistics_overview_empty_filter(client):
    with patch("app.crud.route.RouteCRUD.get_active_routes_with_orders") as mocked_get:
        mocked_get.return_value = []

        response = client.get("/routes/active-routes-with-orders-products")

        assert response.status_code == 404
        assert response.json()["detail"] == "No active routes found"



def test_get_orders_per_route_full_data(client):
    with patch("app.crud.route.RouteCRUD.get_orders_per_route") as mocked_get:
        mock_product = MagicMock()
        mock_product.productName = "Bio-Apfel"
        mock_product.amount = 5
        mock_product.price = 2.50

        mock_order = MagicMock()
        mock_order.orderId = uuid.uuid4()
        mock_order.customerName = "Susi Sorglos"
        mock_order.city = "Graz"
        mock_order.postCode = "8010"
        mock_order.streetName = "Herrengasse"
        mock_order.streetNumber = "1"
        mock_order.products = [mock_product]

        mock_route = MagicMock()
        mock_route.routeId = uuid.uuid4()
        mock_route.routeName = "Süd-Express"
        mock_route.orders = [mock_order]

        mocked_get.return_value = mock_route

        response = client.get(f"/routes/{uuid.uuid4()}/orders")

        assert response.status_code == 200
        assert response.json()["orders"][0]["products"][0]["productName"] == "Bio-Apfel"


def test_get_orders_per_route_no_address(client):
    with patch("app.crud.route.RouteCRUD.get_orders_per_route") as mocked_get:
        mock_order = MagicMock()
        mock_order.orderId = uuid.uuid4()
        mock_order.customerName = "Keine Adresse"
        mock_order.city = "N/A"
        mock_order.postCode = "N/A"
        mock_order.streetName = "N/A"
        mock_order.streetNumber = "N/A"
        mock_order.products = []

        mock_route = MagicMock()
        mock_route.routeId = uuid.uuid4()
        mock_route.routeName = "Express"
        mock_route.orders = [mock_order]

        mocked_get.return_value = mock_route

        response = client.get(f"/routes/{uuid.uuid4()}/orders")

        assert response.status_code == 200
        data = response.json()
        assert data["orders"][0]["city"] == "N/A"
        assert data["orders"][0]["postCode"] == "N/A"


def test_get_orders_per_route_not_found(client):
    with patch("app.crud.route.RouteCRUD.get_orders_per_route") as mocked_get:
        mocked_get.return_value = None

        response = client.get(f"/routes/{uuid.uuid4()}/orders")

        assert response.status_code == 404
        assert "not found" in response.json()["detail"].lower()



def test_get_fastest_delivery_success(client):
    route_id = uuid.uuid4()
    with patch("app.crud.route.RouteCRUD.get_orders_per_route_fastest") as mocked_fastest:
        mock_route = MagicMock()
        mock_route.routeId = route_id
        mock_route.routeName = "Turbo-Tour"
        
        mock_order = MagicMock()
        mock_order.orderId = uuid.uuid4()
        mock_order.customerName = "Eiliger Kunde"
        mock_order.city = "Linz"
        mock_order.postCode = "4020"
        mock_order.streetName = "Landstraße"
        mock_order.streetNumber = "10"
        mock_order.products = []
        
        mock_route.orders = [mock_order]
        mocked_fastest.return_value = mock_route

        response = client.get(f"/routes/{route_id}/orders/fastest?lat=48.3069&lon=14.2858")

        assert response.status_code == 200
        data = response.json()
        assert data["routeName"] == "Turbo-Tour"
        assert data["orders"][0]["customerName"] == "Eiliger Kunde"
        
        mocked_fastest.assert_called_once_with(
            ANY, str(route_id), current_lat=48.3069, current_lon=14.2858
        )


def test_get_fastest_delivery_no_coords(client):
    route_id = uuid.uuid4()
    with patch("app.crud.route.RouteCRUD.get_orders_per_route_fastest") as mocked_fastest:
        mocked_fastest.return_value = MagicMock(routeId=route_id, routeName="Test", orders=[])

        response = client.get(f"/routes/{route_id}/orders/fastest")

        assert response.status_code == 200
        mocked_fastest.assert_called_once_with(
            ANY, str(route_id), current_lat=None, current_lon=None
        )


def test_get_fastest_delivery_not_found(client):
    route_id = uuid.uuid4()
    with patch("app.crud.route.RouteCRUD.get_orders_per_route_fastest") as mocked_fastest:
        mocked_fastest.return_value = None

        response = client.get(f"/routes/{route_id}/orders/fastest")

        assert response.status_code == 404
        assert "no active orders" in response.json()["detail"]


def test_get_fastest_delivery_http_exception_pass_through(client):
    route_id = uuid.uuid4()
    with patch("app.crud.route.RouteCRUD.get_orders_per_route_fastest") as mocked_fastest:
        mocked_fastest.side_effect = HTTPException(status_code=400, detail="Invalid GPS data")

        response = client.get(f"/routes/{route_id}/orders/fastest")

        assert response.status_code == 400
        assert response.json()["detail"] == "Invalid GPS data"


def test_get_fastest_delivery_server_error(client):
    route_id = uuid.uuid4()
    with patch("app.crud.route.RouteCRUD.get_orders_per_route_fastest") as mocked_fastest:
        mocked_fastest.side_effect = Exception("Unexpected DB Crash")

        response = client.get(f"/routes/{route_id}/orders/fastest")

        assert response.status_code == 500
        assert "error occurred while calculating" in response.json()["detail"]