import os
from unittest.mock import MagicMock, patch

os.environ["POSTGRES_USER"] = "mock"
os.environ["POSTGRES_PASSWORD"] = "mock"
os.environ["POSTGRES_DB"] = "mock"
os.environ["POSTGRES_HOST"] = "localhost"
os.environ["POSTGRES_PORT"] = "5432"
os.environ["DB_INIT"] = "false"

import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.database import get_db
from app.dependencies.auth import get_current_user
from app.schemas.employee import EmployeeOut

@pytest.fixture
def client():
    mock_user_data = EmployeeOut(
        employeeId="00000000-0000-0000-0000-000000000000",
        email="test@orderlink.at",
        firstName="Max",
        lastName="Mustermann",
        role="admin"
    )
    
    app.dependency_overrides[get_current_user] = lambda: mock_user_data
    app.dependency_overrides[get_db] = lambda: MagicMock()
    
    with TestClient(app) as c:
        yield c
    
    app.dependency_overrides.clear()

@pytest.fixture
def mock_crud():
    with patch("app.crud.employee.EmployeeCRUD.get_by_email") as m:
        yield m