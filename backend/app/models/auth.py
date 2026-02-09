from sqlalchemy import *
from sqlalchemy.orm import relationship
from app.models.enums import ActionEnum, ResourceEnum
from app.database import Base

class Action(Base):
    __tablename__ = "actions"

    name = Column(Enum(ActionEnum), primary_key=True)
    description = Column(String, nullable=True)
    deleted = Column(Boolean, default=False)


class Resource(Base):
    __tablename__ = "resources"

    name = Column(Enum(ResourceEnum), primary_key=True)
    description = Column(String, nullable=True)
    deleted = Column(Boolean, default=False)


class ResourceAction(Base):
    __tablename__ = "resourceActions"

    action = Column(Enum(ActionEnum), ForeignKey("actions.name"), primary_key=True)
    resource = Column(Enum(ResourceEnum), ForeignKey("resources.name"), primary_key=True)


class Permission(Base):
    __tablename__ = "permissions"

    permissionId = Column(String, primary_key=True)
    role = Column(String, ForeignKey("roles.name"))
    action = Column(Enum(ActionEnum))
    resource = Column(Enum(ResourceEnum))
    allowed = Column(Boolean, default=False)
    createdAt = Column(DateTime, server_default=func.now())

    role_rel = relationship("Role", back_populates="permissions")

