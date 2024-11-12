
import joblib
import numpy as np

model = joblib.load("./sp500_model.joblib")

def predict_price(day: int) -> float:
    # timestamp = pd.to_datetime(day).timestamp()
    # # Предположим, что у вас есть модель, которая принимает метку времени
    # prediction = model.predict([[timestamp]])
    # return float(prediction[0])
    
    input_data = np.array([[day]], dtype=float)
    prediction = model.predict(input_data)
    #prediction = model.predict([[day]])
    return float(prediction[0])