from pydantic import BaseModel
import uuid

class EmployeeOut(BaseModel):
    employeeId: uuid.UUID
    email: str
    firstName: str
    lastName: str
    role: str

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
