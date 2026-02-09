from sqlalchemy.orm import Session
from app.models.employee import Employees
from app.schemas.employee import EmployeeOut
from app.security import hash_password, verify_password


class EmployeeCRUD:

    def authenticate_employee(self, db: Session, email: str, password: str) -> EmployeeOut | None:
        employee = db.query(Employees).filter(Employees.email == email).first()
        if not employee:
            return None
        if not verify_password(password, employee.password):
            return None
        return employee
    
    def get_by_id(self, db: Session, employee_id: str) -> EmployeeOut | None:
        return db.query(Employees).filter(Employees.employeeId == employee_id).first()
    
    def get_by_email(self, db: Session, email: str) -> EmployeeOut | None:
        return db.query(Employees).filter(Employees.email == email).first()