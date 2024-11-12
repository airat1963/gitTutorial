import yfinance as yf
import pandas as pd
from sklearn.linear_model import LinearRegression
import numpy as np
import joblib

def prepare_data_and_train_model():
    # Загружаем данные S&P 500 за последний год
    data = yf.download('^GSPC', start='2023-01-01', end='2024-01-01')
    print("Загруженные данные:")
    print(data.head())

    data = data[['Close']]

    # Создаем признаки для модели - даты преобразуем в последовательные индексы
    data['Day'] = np.arange(len(data))

    X = data[['Day']]
    y = data['Close']

    # Обучаем простую линейную регрессию (можно заменить на более сложную модель)
    model = LinearRegression()
    model.fit(X, y)

    # Проверяем, что модель обучается корректно
    print("Коэффициенты модели:", model.coef_)
    print("Свободный член модели:", model.intercept_)

    # Сохраняем модель
    joblib.dump(model, 'sp500_model.joblib')
    print("Модель сохранена в файл sp500_model.joblib")

if __name__ == "__main__":
    prepare_data_and_train_model()