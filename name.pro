from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse
import hashlib, random

app = FastAPI()

# -------------------- Core Logic --------------------

def generate_smart_key(seed: str, iterations: int = 10000) -> str:
    key = seed.encode('utf-8')
    for i in range(iterations):
        key = hashlib.sha512(key + str(i).encode()).digest()
    return key.hex()

def validate_boost_key(input_key: str, expected_hash: str) -> bool:
    return hashlib.sha256(input_key.encode()).hexdigest() == expected_hash

def distribute_smart_smileys(owners: list, comment_value: float, boost_key: str, valid_hash: str) -> dict:
    if not validate_boost_key(boost_key, valid_hash):
        raise HTTPException(status_code=403, detail="Boost key rejected")
    
    boosted_value = round(comment_value * 1.12, 6)
    smileys_per_owner = min(100, len(owners))
    distributed = {}

    for i in range(smileys_per_owner):
        user = random.choice(owners)
        distributed[user] = round(boosted_value / smileys_per_owner, 6)

    return distributed

# -------------------- API Route --------------------

@app.get("/distribute", response_class=HTMLResponse)
def api_distribute(seed: str = "ultra_secure_salt+emoji_factor",
                   input_key: str = "supersecretkey",
                   comment_value: float = 0.25):

    owners = [f"user_{i}" for i in range(1, 101)]
    valid_hash = hashlib.sha256("supersecretkey".encode()).hexdigest()

    distributed = distribute_smart_smileys(
        owners=owners,
        comment_value=comment_value,
        boost_key=input_key,
        valid_hash=valid_hash
    )

    html = "<h1>🚀 Distribution des Smiley-Tokens</h1><ul>"
    for user, value in distributed.items():
        html += f"<li>{user} reçoit {value} tokens</li>"
    html += "</ul>"
    return HTMLResponse(content=html)
