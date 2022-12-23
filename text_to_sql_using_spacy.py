import spacy
import pymysql

# Load the spaCy model and create a parser
nlp = spacy.load("en_core_web_sm")
parser = nlp.create_pipe("parser")

# Define the SQL column names and table name
columns = ["timestamp", "sales", "product"]
table_name = "sales_data"

# Process the text input using spaCy
text = "Show me sales data for the last month"
doc = nlp(text)

# Extract the relevant information from the parsed text
filters = []
for token in doc:
    if token.dep_ == "advmod":
        # This token is modifying the verb "show", so it should be a time period
        filters.append(("timestamp", ">=", f"DATE_SUB(NOW(), INTERVAL 1 {token.text})"))
    elif token.dep_ == "dobj":
        # This token is the direct object of the verb "show", so it should be the column to display
        columns = [token.text]

# Generate the SQL query using the extracted information
query = f"SELECT {', '.join(columns)} FROM {table_name}"
if filters:
    query += " WHERE " + " AND ".join(f"{key} {op} {value}" for key, op, value in filters)

# Connect to the database and execute the query
connection = pymysql.connect(host="localhost", user="user", password="password", db="database")
with connection.cursor() as cursor:
    cursor.execute(query)
    results = cursor.fetchall()
