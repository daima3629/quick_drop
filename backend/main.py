from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse, Response
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import secrets
from models.session import Publickey, Session
from models.request_models import *

app = FastAPI(root_path="/api")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.exception_handler(RequestValidationError)
async def handler(request:Request, exc:RequestValidationError):
    print(exc)
    return JSONResponse(content={}, status_code=status.HTTP_422_UNPROCESSABLE_ENTITY)


session_dict: dict[str, Session] = {}


@app.post("/session_key")
async def get_session_key(req: GetSessionKeyRequest):
    session_key = secrets.token_urlsafe(32)
    sender_pubkey = Publickey(x=req.pubkey_x, y=req.pubkey_y)

    session = Session(session_key=session_key, sender_public_key=sender_pubkey)
    session_dict[session_key] = session

    return {"session_key": session_key}


@app.get("/receiver_pubkey")
async def get_receiver_pubkey(session_key: str):
    session = session_dict.get(session_key)
    if session is None:
        return JSONResponse({"detail": "Session not found"}, status_code=404)

    if session.receiver_public_key is None:
        return Response(status_code=204)

    return {
        "pubkey_x": session.receiver_public_key.x,
        "pubkey_y": session.receiver_public_key.y
    }


@app.post("/sender_pubkey")
async def get_sender_pubkey(req: GetSenderPubkeyRequest):
    session = session_dict.get(req.session_key)
    if session is None:
        return JSONResponse({"detail": "Session not found"}, status_code=404)

    session.receiver_public_key = Publickey(x=req.pubkey_x, y=req.pubkey_y)
    return {
        "pubkey_x": session.sender_public_key.x,
        "pubkey_y": session.sender_public_key.y
    }


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
