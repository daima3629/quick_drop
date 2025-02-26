from pydantic import BaseModel
from typing import Optional

class Publickey(BaseModel):
    x: str
    y: str


class Session(BaseModel):
    session_key: str
    sender_public_key: Publickey
    receiver_public_key: Optional[Publickey] = None
