from pydantic import BaseModel

class GetSessionKeyRequest(BaseModel):
    pubkey_x: str
    pubkey_y: str


class GetSenderPubkeyRequest(BaseModel):
    session_key: str
    pubkey_x: str
    pubkey_y: str
