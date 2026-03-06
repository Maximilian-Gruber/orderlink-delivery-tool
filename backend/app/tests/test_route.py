import pytest
import uuid
from unittest.mock import MagicMock, patch


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

        response = client.get("/routes/route-99/orders")

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

        response = client.get("/routes/route-99/orders")

        assert response.status_code == 200
        data = response.json()

        assert data["orders"][0]["city"] == "N/A"
        assert data["orders"][0]["postCode"] == "N/A"