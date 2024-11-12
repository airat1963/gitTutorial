# main.py

from fastapi import FastAPI
from pydantic import BaseModel
from model import predict_price  # Импортируем функцию предсказания из другого файла

# Создаем экземпляр FastAPI
app = FastAPI()

# Определяем Pydantic модель для входных данных
class PredictionRequest(BaseModel):
    day: int  # Прогнозируемая дата в днях от последней даты

# Создаем маршрут для предсказания цены
@app.post("/predict")
def predict(request: PredictionRequest):
    day = request.day
    prediction = predict_price(day)
    return {"predicted_close": prediction}

# Запуск сервера
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)