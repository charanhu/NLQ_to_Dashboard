-- Active: 1671684586543@@127.0.0.1@3306

-- List all the directors who directed a 'Comedy' movie in a leap year. (You need to check that the genre is 'Comedy’ and year is a leap year) Your query should return director name, the movie name, and the year.

SELECT
    DISTINCT TRIM(Name),
    TRIM(title),
    TRIM(year)
FROM Movie M
    JOIN M_Director D ON M.MID = D.MID
    JOIN Person P ON P.PID = D.PID
    JOIN (
        SELECT MID, GID
        FROM M_Genre
        WHERE GID IN (
                SELECT GID
                FROM Genre
                WHERE
                    Name LIKE '%Comedy%'
            )
    ) AS G ON G.MID = M.MID
WHERE (CAST(year AS int) % 400)
    OR (
        CAST(year AS int) % 4
        AND NOT CAST(year AS int) % 100
    );

--List the names of all the actors who played in the movie 'Anand' (1971)

SELECT DISTINCT TRIM(Name)
FROM Person
WHERE PID IN (
        SELECT
            DISTINCT TRIM(PID)
        FROM M_Cast
        WHERE MID = (
                SELECT
                    TRIM(MID)
                FROM Movie M
                WHERE
                    TRIM(M.title) = 'Anand'
            )
    );

-- List all the actors who acted in a film before 1970 and in a film after 1990. (That is: < 1970 and > 1990.)

SELECT DISTINCT TRIM(Name)
FROM Person
WHERE PID IN (
        SELECT
            DISTINCT TRIM(PID)
        FROM M_Cast
        WHERE MID IN (
                SELECT
                    TRIM(MID)
                FROM Movie
                WHERE
                    year < 1970
            )
        INTERSECT
        SELECT
            DISTINCT TRIM(PID)
        FROM M_Cast
        WHERE MID IN (
                SELECT
                    TRIM(MID)
                FROM Movie
                WHERE
                    year > 1990
            )
    );

-- List all directors who directed 10 movies or more, in descending order of the number of movies they directed. Return the directors' names and the number of movies each of them directed.

SELECT
    DISTINCT TRIM(P.Name),
    MC.M_Count
FROM Person P
    JOIN (
        SELECT
            TRIM(PID) As PID,
            COUNT(MID) AS M_Count
        FROM M_Director
        GROUP BY PID
        HAVING
            COUNT(MID) >= 10
    ) AS MC ON MC.PID = P.PID
ORDER BY MC.M_Count DESC;

--For each year, count the number of movies in that year that had only female actors.

SELECT year, COUNT(MID)
FROM Movie
WHERE TRIM(MID) NOT IN (
        SELECT
            DISTINCT TRIM(C.MID)
        FROM M_Cast C
            JOIN Person P ON TRIM(C.PID) = TRIM(P.PID)
        WHERE
            TRIM(P.Gender) = 'Male'
    )
GROUP BY year;

--Now include a small change: report for each year the percentage of movies in that year with only female actors, and the total number of movies made that year. For example, one answer will be: 1990 31.81 13522 meaning that in 1990 there were 13,522 movies, and 31.81% had only female actors. You do not need to round your answer

SELECT
    FMovies.year,
    FMovies.Count, (FMovies.Count * 100.0) / COUNT(TRIM(MID))
FROM Movie M
    JOIN (
        SELECT
            year,
            COUNT(TRIM(MID)) as Count
        FROM Movie
        WHERE TRIM(MID) NOT IN (
                SELECT
                    DISTINCT TRIM(C.MID)
                FROM M_Cast C
                    JOIN Person P ON TRIM(C.PID) = TRIM(P.PID)
                WHERE
                    TRIM(P.Gender) = 'Male'
            )
        GROUP BY
            year
    ) AS FMovies ON M.year = FMovies.year
GROUP BY FMovies.year;

-- Find the film(s) with the largest cast. Return the movie title and the size of the cast. By "cast size" we mean the number of distinct actors that played in that movie: if an actor played multiple roles, or if it simply occurs multiple times in casts, we still count her/him only once.

SELECT
    title,
    COUNT(DISTINCT PID) AS Ncast
FROM Movie M
    JOIN M_Cast C ON TRIM(M.MID) = TRIM(C.MID)
GROUP BY M.MID
HAVING Ncast = (
        SELECT MAX(NC.PCount)
        FROM (
                SELECT
                    COUNT(DISTINCT PID) AS PCount
                FROM M_Cast
                GROUP BY
                    MID
            ) NC
    );

-- A decade is a sequence of 10 consecutive years. For example, say in your database you have movie information starting from 1965. Then the first decade is 1965, 1966, ..., 1974; the second one is 1967, 1968, ..., 1976 and so on. Find the decade D with the largest number of films and the total number of films in D.

SELECT
    year - year % 10 As Decade,
    COUNT(DISTINCT MID) as NumM
FROM Movie
WHERE LENGTH(year) = 4
GROUP BY Decade
ORDER BY NumM DESC
LIMIT 1;

-- Find the actors that were never unemployed for more than 3 years at a stretch. (Assume that the actors remain unemployed between two consecutive movies).

WITH Movie_Year AS (
        SELECT
            DISTINCT TRIM(MC.PID) AS PID,
            TRIM(M.Year) AS YEAR,
            ROW_NUMBER() OVER (
                PARTITION BY TRIM(MC.PID)
                ORDER BY
                    Year
            ) Row_Num
        FROM Movie M
            JOIN M_Cast MC ON TRIM(M.MID) = TRIM(MC.MID)
    )
SELECT DISTINCT Name
FROM Person
WHERE PID NOT IN (
        SELECT DISTINCT M1.PID
        FROM Movie_Year M1
            JOIN Movie_Year M2 ON M1.PID = M2.PID AND M1.Row_Num + 1 = M2.Row_Num
        WHERE
            M2.Year - M1.Year >= 3
    );

-- Find all the actors that made more movies with Yash Chopra than any other director.

WITH Cast_Fav_Dir AS (
        SELECT
            CID,
            DID,
            Num_Movies,
            ROW_NUMBER() OVER(
                PARTITION BY CID
                ORDER BY
                    Num_Movies DESC
            ) Row_Num
        FROM (
                SELECT
                    TRIM(C.PID) AS CID,
                    TRIM(D.PID) AS DID,
                    COUNT(DISTINCT TRIM(C.MID)) AS Num_Movies
                FROM M_Cast C
                    JOIN M_Director D ON TRIM(C.MID) = TRIM(D.MID)
                GROUP BY
                    TRIM(C.PID),
                    TRIM(D.PID)
            ) AS TEMP
    )
SELECT DISTINCT TRIM(Name)
FROM Person
WHERE PID IN (
        SELECT DISTINCT CID
        FROM Cast_Fav_Dir AS FD
        WHERE
            Row_Num = 1
            AND DID IN (
                SELECT
                    DISTINCT TRIM(PID)
                FROM Person
                WHERE
                    NAME LIKE '%YASH%CHOPRA%'
            )
    );

-- The Shahrukh number of an actor is the length of the shortest path between the actor and Shahrukh Khan in the "co-acting" graph. That is, Shahrukh Khan has Shahrukh number 0; all actors who acted in the same film as Shahrukh have Shahrukh number 1; all actors who acted in the same film as some actor with Shahrukh number 1 have Shahrukh number 2, etc. Return all actors whose Shahrukh number is 2

SELECT DISTINCT TRIM(Name)
FROM Person
WHERE PID IN (
        SELECT
            DISTINCT TRIM(PID) AS PID
        FROM M_Cast
        WHERE TRIM(MID) IN (
                SELECT
                    DISTINCT TRIM(MID)
                FROM M_Cast
                WHERE
                    TRIM(PID) IN (
                        SELECT
                            DISTINCT TRIM(PID)
                        FROM
                            M_Cast
                        WHERE
                            TRIM(MID) IN (
                                SELECT
                                    DISTINCT TRIM(MID)
                                FROM
                                    M_Cast
                                WHERE
                                    TRIM(PID) = (
                                        SELECT
                                            TRIM(PID)
                                        FROM
                                            Person
                                        WHERE
                                            Name LIKE '%Shah Rukh Khan%'
                                    )
                            )
                    )
            )
        EXCEPT
        SELECT
            DISTINCT TRIM(PID)
        FROM M_Cast
        WHERE TRIM(MID) IN (
                SELECT
                    DISTINCT TRIM(MID)
                FROM M_Cast
                WHERE
                    TRIM(PID) = (
                        SELECT
                            TRIM(PID)
                        FROM
                            Person
                        WHERE
                            Name LIKE '%Shah Rukh Khan%'
                    )
            )
    );

-- List all the actors who acted in a film before 1960 and in a film after 2000. (That is: < 1960and > 2000.)

SELECT DISTINCT TRIM(Name)
FROM Person
WHERE PID IN (
        SELECT
            DISTINCT TRIM(PID)
        FROM M_Cast
        WHERE MID IN (
                SELECT
                    TRIM(MID)
                FROM Movie
                WHERE
                    year < 1960
            )
        INTERSECT
        SELECT
            DISTINCT TRIM(PID)
        FROM M_Cast
        WHERE MID IN (
                SELECT
                    TRIM(MID)
                FROM Movie
                WHERE
                    year > 2000
            )
    );

-- frind average action movies per year

SELECT
    AVG(
        CASE
            WHEN A.Num_Action IS NULL THEN 0
            ELSE A.Num_Action
        END
    )
FROM (
        SELECT
            Year,
            COUNT(TRIM(MID)) AS Num_Action
        FROM Movie
        WHERE TRIM(MID) IN (
                SELECT
                    DISTINCT TRIM(MID)
                FROM Movie
                WHERE
                    TRIM(MID) IN (
                        SELECT
                            DISTINCT TRIM(MID)
                        FROM
                            M_Genre
                        WHERE
                            TRIM(GID) IN (
                                SELECT
                                    TRIM(GID)
                                FROM
                                    Genre
                                WHERE
                                    LOWER(TRIM(Name)) LIKE '%action%'
                            )
                    )
            )
        GROUP BY Year
    ) A;

-- All tables Names:

-- 1. Country

-- 2. Genre

-- 3. Language

-- 4. Location

-- 5. M_Cast

-- 6. M_Country

-- 7. M_Director

-- 8. M_Genre

-- 9. M_Language

-- 10. M_Location

-- 11. M_Producer

-- 12. Movie

-- 13. Person

-- Country has columns: CID, Name

-- Genre has columns: GID, Name

-- Language has columns: LAID, Name

-- Location has columns: LID, Name

-- M_Cast has columns: ID, MID, PID

-- M_Country has columns: ID, MID, CID

-- M_Director has columns: ID, MID, PID

-- M_Genre has columns: ID, MID, GID

-- M_Language has columns: ID, MID, LAID

-- M_Location has columns: ID, MID, LID

-- M_Producer has columns: ID, MID, PID

-- Movie has columns: MID, title, year, rating, num_votes

-- Person has columns: PID, Name, Gender

-- find all the action movies of 1990

SELECT title, year
FROM Movie
WHERE TRIM(MID) IN (
        SELECT
            DISTINCT TRIM(MID)
        FROM Movie
        WHERE TRIM(MID) IN (
                SELECT
                    DISTINCT TRIM(MID)
                FROM M_Genre
                WHERE
                    TRIM(GID) IN (
                        SELECT
                            TRIM(GID)
                        FROM
                            Genre
                        WHERE
                            LOWER(TRIM(Name)) LIKE '%action%'
                    )
            )
            AND year = 1990
    );

-- total female actors acted between 1970 to 1980

SELECT
    COUNT(DISTINCT PID) AS Num_Female_Actors
FROM M_Cast
WHERE TRIM(PID) IN (
        SELECT TRIM(PID)
        FROM Person
        WHERE
            Gender = 'Female'
            AND PID IN (
                SELECT
                    DISTINCT TRIM(PID)
                FROM M_Cast
                WHERE MID IN (
                        SELECT
                            TRIM(MID)
                        FROM
                            Movie
                        WHERE
                            year BETWEEN 1970 AND 1980
                    )
            )
    );

-- list the actors who are acted in 1978 for action movies.

SELECT DISTINCT TRIM(P.Name)
FROM Person P
    JOIN M_Cast C ON TRIM(P.PID) = TRIM(C.PID)
WHERE TRIM(C.MID) IN (
        SELECT TRIM(M.MID)
        FROM Movie M
            JOIN M_Genre MG ON TRIM(M.MID) = TRIM(MG.MID)
            JOIN Genre G ON TRIM(MG.GID) = TRIM(G.GID)
        WHERE
            year = 1978
            AND trim(G.Name) LIKE '%Action%'
    );