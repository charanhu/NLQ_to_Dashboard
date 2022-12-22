query = "Virat Kohli's highest score?, Which team does he play for?"

# convert string into list of strings split by comma
query = query.split(',')
print(query)


# django application create for same directory
django-admin startproject NLQ_to_Dashboard .


# to run the server
python manage.py runserver