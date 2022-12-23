query = "Virat Kohli's highest score?, Which team does he play for?"

# convert string into list of strings split by comma
query = query.split(',')
print(query)


# django application create for same directory
django-admin startproject NLQ_to_Dashboard .


# to run the server
python manage.py runserver




IMDB Database

All tables Names:

1. Country

2. Genre

3. Language

4. Location

5. M_Cast

6. M_Country

7. M_Director

8. M_Genre

9. M_Language

10. M_Location

11. M_Producer

12. Movie

13. Person

Country has columns: CID, Name

Genre has columns: GID, Name

Language has columns: LAID, Name

Location has columns: LID, Name

M_Cast has columns: ID, MID, PID

M_Country has columns: ID, MID, CID

M_Director has columns: ID, MID, PID

M_Genre has columns: ID, MID, GID

M_Language has columns: ID, MID, LAID

M_Location has columns: ID, MID, LID

M_Producer has columns: ID, MID, PID

Movie has columns: MID, title, year, rating, num_votes

Person has columns: PID, Name, Gender