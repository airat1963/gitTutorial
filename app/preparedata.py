#pip install yfinance
import yfinance as yf
import pandas as pd
from sklearn.linear_model import LinearRegression
import numpy as np
import joblib

# Загружаем данные S&P 500 за последний год
data = yf.download('^GSPC', start='2023-01-01', end='2024-01-01')
data = data[['Close']]

# Создаем признаки для модели - даты преобразуем в последовательные индексы
data['Day'] = np.arange(len(data))

X = data[['Day']]
y = data['Close']

# Обучаем простую линейную регрессию (можно заменить на более сложную модель)
model = LinearRegression()
model.fit(X, y)

# Сохраняем модель
joblib.dump(model, 'sp500_model.joblib')
