from sqlalchemy import (
    Column,
    Integer,
    String,
    Float,
    Boolean,
    DateTime,
)

from database import Base

from datetime import datetime

class CashRequestModel(Base):

    __tablename__ = "cash_requests"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    user_id = Column(
        String,
        nullable=False,
    )

    request_type = Column(
        String,
    )

    amount = Column(
        Integer,
    )

    latitude = Column(
        Float,
    )

    longitude = Column(
        Float,
    )

    is_completed = Column(
        Boolean,
        default=False,
    )

    rating = Column(
        Float,
        default=5.0,
    )

    completed_exchanges = Column(
        Integer,
        default=0,
    )

    # NEW
    status = Column(
        String,
        default="OPEN",
    )

    # NEW
    matched_user_id = Column(
        String,
        nullable=True,
    )

    created_at = Column(
        DateTime,
        default=datetime.utcnow,
    )