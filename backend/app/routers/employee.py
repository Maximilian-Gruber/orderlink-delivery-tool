from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.employee import EmployeeOut
from app.crud.employee import EmployeeCRUD
from app.dependencies.auth import get_current_user

router = APIRouter(prefix="/employee", tags=["employees"])

@router.get("/profile", response_model=EmployeeOut)
def get_employee_profile(db: Session = Depends(get_db), current_user: EmployeeOut = Depends(get_current_user)):
    employee = EmployeeCRUD().get_by_email(db, current_user.email)
    if not employee:
        raise HTTPException(status_code=404, detail="Employee not found")
    employee_out = EmployeeOut.from_orm(employee)
    return employee_out