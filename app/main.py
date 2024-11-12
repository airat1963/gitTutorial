from fastapi import FastAPI
from pydantic import BaseModel
from app.model import predict_price

app = FastAPI()

class PredictionRequest(BaseModel):
    day: int
    #data: list

@app.post("/predict")
def predict(request: PredictionRequest):
    day = request.day
    prediction = predict_price(day)
    return {"predicted_close": prediction}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)