import pytest
from unittest.mock import MagicMock, patch

def test_login_success(client):
    with patch("app.crud.employee.EmployeeCRUD.authenticate_employee") as mocked_auth, \
         patch("app.routers.auth.create_access_token") as mocked_token:
        
        mock_user = MagicMock()
        mock_user.email = "test@example.com"
        mocked_auth.return_value = mock_user
        
        mocked_token.return_value = "fake-jwt-token"

        response = client.post(
            "/auth/login",
            data={"username": "test@example.com", "password": "securepassword"}
        )

        assert response.status_code == 200
        data = response.json()
        assert data["access_token"] == "fake-jwt-token"
        assert data["token_type"] == "bearer"

def test_login_invalid_credentials(client):
    with patch("app.crud.employee.EmployeeCRUD.authenticate_employee") as mocked_auth:
        mocked_auth.return_value = None

        response = client.post(
            "/auth/login",
            data={"username": "wrong@example.com", "password": "wrongpassword"}
        )

        assert response.status_code == 401
        assert response.json()["detail"] == "Incorrect email or password"