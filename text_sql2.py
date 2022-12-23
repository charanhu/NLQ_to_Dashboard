import json
import numpy as np
import pandas as pd
from sklearn.preprocessing import LabelEncoder
from keras.preprocessing.text import Tokenizer
from keras.preprocessing.sequence import pad_sequences
from keras.models import Sequential
from keras.layers import Embedding, LSTM, Dense, Dropout
from keras.utils import to_categorical

# Load the WikiSQL dataset
with open('wikisql.json') as f:
    data = json.load(f)

# Extract the natural language queries and SQL queries
nl_queries = [entry['question'] for entry in data]
sql_queries = [entry['sql'] for entry in data]

# Preprocess the data
X = nl_queries
Y = sql_queries

# Tokenize and pad the queries
max_words = 1000
max_len = 100

tokenizer = Tokenizer(num_words=max_words)
X = tokenizer.fit_transform(X)
X = pad_sequences(X, maxlen=max_len)

# Encode the SQL queries
encoder = LabelEncoder()
Y = encoder.fit_transform(Y)
Y = to_categorical(Y)

# Build the model
model = Sequential()
model.add(Embedding(max_words, 50, input_length=max_len))
model.add(LSTM(100))
model.add(Dropout(0.5))
model.add(Dense(Y.shape[1], activation='softmax'))
model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

# Train the model
model.fit(X, Y, epochs=5, batch_size=64, validation_split=0.2)

# Test the model with a new natural language query
new_query = "List all the directors who directed a 'Comedy' movie in a leap year"
new_query = tokenizer.texts_to_sequences([new_query])
new_query = pad_sequences(new_query, maxlen=max_len)
prediction = model.predict(new_query)
prediction = np.argmax(prediction, axis=1)[0]
prediction = encoder.inverse_transform(prediction)

print(prediction)
