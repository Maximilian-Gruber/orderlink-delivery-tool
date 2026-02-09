from pydantic import BaseModel
import uuid

class EmployeeOut(BaseModel):
    id: uuid.UUID
    email: str
    first_name: str
    last_name: str

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
