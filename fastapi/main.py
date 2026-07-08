from fastapi import FastAPI, Depends, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy.orm import Session
from datetime import datetime, timedelta

from database import SessionLocal, engine
from models import CashRequestModel, Base

Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------------
# REQUEST MODEL
# -------------------------

class CashRequest(BaseModel):
    user_id: str
    request_type: str
    amount: int
    latitude: float
    longitude: float

# -------------------------
# DATABASE
# -------------------------

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# -------------------------
# CREATE REQUEST
# -------------------------

@app.post("/create-request")
def create_request(
    request: CashRequest,
    db: Session = Depends(get_db)
):

    new_request = CashRequestModel(
        user_id=request.user_id,
        request_type=request.request_type,
        amount=request.amount,
        latitude=request.latitude,
        longitude=request.longitude,
        rating=5.0,
        completed_exchanges=0,
    )

    db.add(new_request)
    db.commit()
    db.refresh(new_request)

    return {
        "message": "Request Created Successfully"
    }

# -------------------------
# GET ALL REQUESTS
# -------------------------

@app.get("/requests")
def get_requests(
    db: Session = Depends(get_db)
):

    expiry_time = (
        datetime.utcnow() -
        timedelta(minutes=15)
    )

    requests = db.query(
        CashRequestModel
    ).filter(

        CashRequestModel.created_at >= expiry_time,
        CashRequestModel.is_completed == False

    ).all()

    return requests

# -------------------------
# MY REQUESTS
# -------------------------

@app.get("/my-requests/{user_id}")
def my_requests(
    user_id: str,
    db: Session = Depends(get_db)
):

    requests = db.query(
        CashRequestModel
    ).filter(
        CashRequestModel.user_id == user_id,
        CashRequestModel.is_completed == False
    ).all()

    return requests

# -------------------------
# MAP REQUESTS
# -------------------------

@app.get("/map-requests/{request_type}/{user_id}")
def map_requests(
    request_type: str,
    user_id: str,
    db: Session = Depends(get_db)
):

    if "Physical" in request_type:
        opposite_type = "Need Digital Cash"
    else:
        opposite_type = "Need Physical Cash"

    requests = db.query(
        CashRequestModel
    ).filter(

        CashRequestModel.request_type == opposite_type,
        CashRequestModel.is_completed == False,
CashRequestModel.status == "OPEN",
        CashRequestModel.user_id != user_id

    ).all()
print("MAP REQUESTS:")
print(len(requests))
    return [

        {
            "id": r.id,
            "user_id": r.user_id,
            "request_type": r.request_type,
            "amount": r.amount,
            "latitude": r.latitude,
            "longitude": r.longitude,
            "rating": r.rating,
            "completed_exchanges": r.completed_exchanges,
        }

        for r in requests
    ]

# -------------------------
# COMPLETE REQUEST
# -------------------------

@app.put("/complete-request/{request_id}")
def complete_request(
    request_id: int,
    db: Session = Depends(get_db)
):

    request = db.query(
        CashRequestModel
    ).filter(
        CashRequestModel.id == request_id
    ).first()

    if not request:

        return {
            "message": "Request not found"
        }

    request.is_completed = True
    request.completed_exchanges += 1

    db.commit()

    return {
        "message": "Exchange Completed"
    }
# -------------------------
# CANCEL REQUEST
# -------------------------

@app.put("/cancel-request/{request_id}")
def cancel_request(
    request_id: int,
    db: Session = Depends(get_db)
):

    request = db.query(
        CashRequestModel
    ).filter(
        CashRequestModel.id == request_id
    ).first()

    if not request:
        return {
            "message": "Request not found"
        }

    db.delete(request)
    db.commit()

    return {
        "message": "Request Cancelled"
    }


# ADD HERE 👇

@app.put("/accept-request/{request_id}/{user_id}")
def accept_request(
    request_id: int,
    user_id: str,
    db: Session = Depends(get_db)
):

    request = db.query(
        CashRequestModel
    ).filter(
        CashRequestModel.id == request_id
    ).first()

    if not request:
        return {
            "message": "Request not found"
        }

    if request.status != "OPEN":
        return {
            "message": "Already matched"
        }

    request.status = "MATCHED"
    request.matched_user_id = user_id

    db.commit()

    return {
        "message": "Request Accepted"
    }


# -------------------------
# WEBSOCKET CHAT
# -------------------------

rooms = {}

@app.websocket("/ws/{room_id}")
async def websocket_endpoint(
    websocket: WebSocket,
    room_id: str
):

    await websocket.accept()

    if room_id not in rooms:
        rooms[room_id] = []

    rooms[room_id].append(websocket)

    print(f"Client joined room {room_id}")

    try:

        while True:

            data = await websocket.receive_text()

            print(f"{room_id}: {data}")

            for connection in rooms[room_id]:
                await connection.send_text(data)

    except WebSocketDisconnect:

        rooms[room_id].remove(websocket)

        print(f"Client left room {room_id}")