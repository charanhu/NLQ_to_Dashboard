# Natural Language to SQL

# Abstract: In the age of information explosion, there is a huge data that is stored in the form of database and accessed using various querying languages. The major challenges faced by a user accessing this data is to learn the querying language and understand the various syntax associated with it. Query given in the form of Natural Language helps any naïve user to access database without learning the query languages. The current process of conversion of Natural Language to SQL Query using a rule-based algorithm is riddled with challenges -- identification of partial or implied data values and identification of descriptive values being the predominant ones. This paper discusses the use of a synchronous combination of a hybrid Machine Learning model, Elastic Search and WordNet to overcome the above-mentioned challenges. An embedding layer followed by a Long Short-Term Memory model is used to identify partial or implied data values, while Elastic Search has been used to identify descriptive data values (values which have lengthy data values and may contain descriptions). This architecture enables conversion systems to achieve robustness and high accuracies, by extracting meta data from the natural language query. The system gives an accuracy of 91.7% when tested on the IMDb database and 94.0% accuracy when tested on Company Sales database.

# Import libraries
import pandas as pd
import numpy as np

# Input data files are available in the read-only "../input/" directory
# For example, running this (by clicking run or pressing Shift+Enter) will list all files under the input directory

import os
for dirname, _, filenames in os.walk('/kaggle/input'):
    for filename in filenames:
        print(os.path.join(dirname, filename))

# You can write up to 20GB to the current directory (/kaggle/working/) that gets preserved as output when you create a version using "Save & Run All" 
# You can also write temporary files to /kaggle/temp/, but they won't be saved outside of the current session

# read train and test data
train = pd.read_csv('/kaggle/input/wikisql/train.csv')
test = pd.read_csv('/kaggle/input/wikisql/test.csv')
val = pd.read_csv('/kaggle/input/wikisql/validation.csv')

data = pd.concat([train, test, val], ignore_index=True)

# split the data into train and test
from sklearn.model_selection import train_test_split
x_train, x_test, y_train, y_test = train_test_split(data['question'], data['sql'], test_size=0.2, random_state=42)

# import libraries
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from nltk.stem import WordNetLemmatizer
from nltk.stem import PorterStemmer
from nltk.tokenize import sent_tokenize, word_tokenize
from nltk.corpus import wordnet

# import tokenizer
from nltk.tokenize import word_tokenize

# import libraries


