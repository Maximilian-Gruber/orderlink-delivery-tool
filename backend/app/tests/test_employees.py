import pytest
from unittest.mock import MagicMock

def test_get_employee_profile_success(client, mock_crud):
    mock_employee = MagicMock()
    mock_employee.email = "test@orderlink.at"
    mock_employee.firstName = "Max"
    mock_employee.lastName = "Mustermann"
    mock_employee.role = "admin"
    mock_employee.employeeId = "00000000-0000-0000-0000-000000000000"

    mock_crud.return_value = mock_employee

    response = client.get("/employees/profile")

    assert response.status_code == 200
    assert response.json()["email"] == "test@orderlink.at"

def test_get_employee_profile_not_found(client, mock_crud):
    mock_crud.return_value = None
    
    response = client.get("/employees/profile")

    assert response.status_code == 404