import pytest
from unittest.mock import MagicMock, patch


def test_get_logistics_overview_success(client):
    with patch("app.crud.route.RouteCRUD.get_active_routes_with_orders") as mocked_get:
        mock_route = MagicMock()
        mock_route.routeId = "route-1"
        mock_route.name = "Nord-Tour"
        
        mock_order = MagicMock()
        mock_order.deliveryDate = None
        mock_order.customer.firstName = "Max"
        mock_order.customer.lastName = "Mustermann"
        mock_order.customer.address.city = "Wien"
        mock_order.customer.address.postCode = "1010"
        mock_order.customer.address.streetName = "Stephansplatz"
        mock_order.customer.address.streetNumber = "1"
        
        mock_route_order = MagicMock()
        mock_route_order.order = mock_order
        mock_route.orders = [mock_route_order]
        
        mocked_get.return_value = [mock_route]

        response = client.get("/routes/active-routes-with-orders-products")
        assert response.status_code == 200
        assert len(response.json()) == 1

def test_get_logistics_overview_empty_filter(client):
    with patch("app.crud.route.RouteCRUD.get_active_routes_with_orders") as mocked_get:
        mock_route = MagicMock()
        mock_order = MagicMock()
        mock_order.deliveryDate = "2024-05-20" 
        
        mock_route_order = MagicMock()
        mock_route_order.order = mock_order
        mock_route.orders = [mock_route_order]
        
        mocked_get.return_value = [mock_route]

        response = client.get("/routes/active-routes-with-orders-products")
        
        assert response.status_code == 200
        assert response.json() == []


def test_get_orders_per_route_full_data(client):
    with patch("app.crud.route.RouteCRUD.get_orders_per_route") as mocked_get:
        mock_route = MagicMock()
        mock_route.routeId = "route-99"
        mock_route.name = "Süd-Express"
        
        mock_order = MagicMock()
        mock_order.orderId = "order-abc"
        mock_order.customer.firstName = "Susi"
        mock_order.customer.lastName = "Sorglos"
        mock_order.customer.address.city = "Graz"
        mock_order.customer.address.postCode = "8010"
        mock_order.customer.address.streetName = "Herrengasse"
        mock_order.customer.address.streetNumber = "1"
        
        mock_prod_link = MagicMock()
        mock_prod_link.product.name = "Bio-Apfel"
        mock_prod_link.product.price = 2.50
        mock_prod_link.productAmount = 5
        
        mock_order.products = [mock_prod_link]
        mock_route_order = MagicMock()
        mock_route_order.order = mock_order
        mock_route.orders = [mock_route_order]
        
        mocked_get.return_value = mock_route

        response = client.get("/routes/route-99/orders")
        assert response.status_code == 200
        assert response.json()["orders"][0]["products"][0]["productName"] == "Bio-Apfel"

def test_get_orders_per_route_no_address(client):
    with patch("app.crud.route.RouteCRUD.get_orders_per_route") as mocked_get:
        mock_route = MagicMock()
        mock_route.routeId = "route-99"
        mock_route.name = "Express"
        
        mock_order = MagicMock()
        mock_order.orderId = "order-123"
        mock_order.customer.firstName = "Keine"
        mock_order.customer.lastName = "Adresse"
        mock_order.customer.address = None 
        mock_order.products = []
        
        mock_route_order = MagicMock()
        mock_route_order.order = mock_order
        mock_route.orders = [mock_route_order]
        mocked_get.return_value = mock_route

        response = client.get("/routes/route-99/orders")
        
        assert response.status_code == 200
        data = response.json()
        assert data["orders"][0]["city"] == "N/A"
        assert data["orders"][0]["postCode"] == "N/A"