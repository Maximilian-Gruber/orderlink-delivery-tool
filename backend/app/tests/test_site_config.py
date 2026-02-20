import pytest
from unittest.mock import patch, MagicMock

def test_get_login_page_config_success(client):
    with patch("app.crud.site_config.SiteConfigCRUD.get_site_config") as mocked_get:
        mocked_get.return_value = {
            "companyName": "OrderLink Delivery",
            "logoPath": "/static/images/logo.png"
        }

        response = client.get("/site-config/login-page")

        assert response.status_code == 200
        data = response.json()
        assert data["companyName"] == "OrderLink Delivery"
        assert data["logoPath"] == "/static/images/logo.png"

def test_get_login_page_config_not_found(client):
    with patch("app.crud.site_config.SiteConfigCRUD.get_site_config") as mocked_get:
        mocked_get.return_value = None

        response = client.get("/site-config/login-page")

        assert response.status_code == 404
        assert response.json()["detail"] == "Site configuration not found"