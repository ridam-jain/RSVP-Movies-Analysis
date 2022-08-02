USE imdb;


SELECT	* FROM movie;

SELECT * FROM ratings;

SELECT * FROM genre;

SELECT * FROM director_mapping;

SELECT * FROM role_mapping;

SELECT * FROM names;



-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?


SELECT 
    COUNT(*) AS movie_row_count
FROM
    movie;
    
SELECT 
    COUNT(*) AS ratings_row_count
FROM
    ratings;
    
SELECT 
    COUNT(*) AS genre_row_count
FROM
    genre;
    
SELECT 
    COUNT(*) AS directors_row_count
FROM
    director_mapping;
    
SELECT 
    COUNT(*) AS roles_row_count
FROM
    role_mapping;
    
SELECT 
    COUNT(*) AS names_row_count
FROM
    names;


-- Q2. Which columns in the 'movie' table have null values?

SELECT 
    COUNT(*) AS title_nulls
FROM
    movie
WHERE title IS NULL;

SELECT 
    COUNT(*) AS year_nulls
FROM
    movie
WHERE year IS NULL;

SELECT 
    COUNT(*) AS date_published_nulls
FROM
    movie
WHERE date_published IS NULL;

SELECT 
    COUNT(*) AS duration_nulls
FROM
    movie
WHERE duration IS NULL;

SELECT 
    COUNT(*) AS country_nulls
FROM
    movie
WHERE country IS NULL;

SELECT 
    COUNT(*) AS worlwide_gross_income_nulls
FROM
    movie
WHERE worlwide_gross_income IS NULL;

SELECT 
    COUNT(*) AS languages_nulls
FROM
    movie
WHERE languages IS NULL;

SELECT 
    COUNT(*) AS production_company_nulls
FROM
    movie
WHERE production_company IS NULL;


SELECT 
    COUNT(CASE
        WHEN title IS NULL THEN id
    END) AS title_nulls,
    COUNT(CASE
        WHEN year IS NULL THEN id
    END) AS year_nulls,
    COUNT(CASE
        WHEN date_published IS NULL THEN id
    END) AS date_published_nulls,
    COUNT(CASE
        WHEN duration IS NULL THEN id
    END) AS duration_nulls,
    COUNT(CASE
        WHEN country IS NULL THEN id
    END) AS country_nulls,
    COUNT(CASE
        WHEN worlwide_gross_income IS NULL THEN id
    END) AS worlwide_gross_income_nulls,
    COUNT(CASE
        WHEN languages IS NULL THEN id
    END) AS languages_nulls,
    COUNT(CASE
        WHEN production_company IS NULL THEN id
    END) AS production_company_nulls
FROM
    movie;
    

-- Q3. Find the total number of movies released in each year. How does the trend look month-wise? 


-- Part one
SELECT 
    year, COUNT(*) AS number_of_movies
FROM
    movie
GROUP BY year;

-- Part two
SELECT 
    MONTH(date_published) as month_num, COUNT(*) AS number_of_movies
FROM
    movie
GROUP BY month_num
ORDER BY month_num;

-- Part two
SELECT 
    EXTRACT( month from date_published) as month_num, COUNT(*) AS number_of_movies
FROM
    movie
GROUP BY month_num
ORDER BY month_num;



-- Q4. How many movies were produced in the USA or India in the year 2019?

SELECT 
    COUNT(*) AS number_of_movies
FROM
    movie
WHERE year=2019 AND (country LIKE '%USA%' OR country LIKE '%India%');

-- Another way
SELECT 
    COUNT(*) AS number_of_movies
FROM
    movie
WHERE year=2019 AND (LOWER(country) LIKE '%usa%' OR LOWER(country) LIKE '%india%');






-- Q5. Find the unique list of the genres present in the data set?

SELECT DISTINCT
    genre
FROM
    genre;



-- Q6.Which genre had the highest number of movies produced overall?

SELECT 
    genre,
    COUNT(movie_id) as movie_count
FROM
    genre
GROUP BY genre
ORDER BY movie_count DESC
LIMIT 1;

-- Alternate way
WITH summary AS
(
	SELECT 
		genre,
		COUNT(movie_id) AS movie_count,
		RANK () OVER (ORDER BY COUNT(movie_id) DESC) AS genre_rank
	FROM
		genre
	GROUP BY genre
)
SELECT 
    genre
FROM
    summary
WHERE
    genre_rank = 1;



-- Q7. How many movies belong to only one genre?

WITH movie_genre_summary AS
(
SELECT 
	movie_id,
	COUNT(genre) AS genre_count
FROM
	genre
GROUP BY movie_id
)
SELECT 
    COUNT(DISTINCT movie_id) AS single_genre_movie_count
FROM
    movie_genre_summary
WHERE
    genre_count=1;




-- Q8.What is the average duration of movies in each genre? 



SELECT 
    genre,
    AVG(duration) AS avg_duration
FROM
    genre AS g
        LEFT JOIN
    movie AS m 
		ON g.movie_id = m.id
GROUP BY genre;

/


-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? )




WITH summary AS
(
	SELECT 
		genre,
		COUNT(movie_id) AS movie_count,
		RANK () OVER (ORDER BY COUNT(movie_id) DESC) AS genre_rank
	FROM
		genre
	GROUP BY genre
)
SELECT 
    *
FROM
    summary
WHERE
    lower(genre) = 'thriller';


-- Segment 2:

-- Q10.  Find the minimum and maximum values for each column of the 'ratings' table except the movie_id column.



SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM
    ratings;
    


-- Q11. What are the top 10 movies based on average rating?


WITH top_movies AS
(
SELECT 
    m.title,
    avg_rating,
    ROW_NUMBER() OVER (ORDER BY avg_rating DESC) AS movie_rank
FROM
    movie AS m
        LEFT JOIN
    ratings AS r ON m.id = r.movie_id
)
SELECT 
    *
FROM
    top_movies
WHERE
    movie_rank <= 10;
    

-- Q12. Summarise the ratings table based on the movie counts by median ratings.



SELECT 
    median_rating, COUNT(movie_id) AS movie_count
FROM
    ratings
GROUP BY median_rating
ORDER BY median_rating;


-- Q13. Which production house has produced the most number of hit movies (average rating > 8)?


WITH top_prod AS
(
SELECT 
    m.production_company,
    COUNT(m.id) AS movie_count,
    ROW_NUMBER() OVER (ORDER BY COUNT(m.id) DESC) AS prod_company_rank
FROM
    movie AS m
        LEFT JOIN
    ratings AS r
		ON m.id = r.movie_id
WHERE avg_rating>8 AND m.production_company IS NOT NULL
GROUP BY m.production_company
)
SELECT 
    *
FROM
    top_prod
WHERE
    prod_company_rank = 1;



-- Q14. How many movies released in each genre in March 2017 in the USA had more than 1,000 votes?


SELECT 
    genre, 
    COUNT(g.movie_id) AS movie_count
FROM
    genre AS g
        INNER JOIN
    movie AS m 
		ON g.movie_id = m.id
			INNER JOIN
		ratings AS r 
			ON m.id = r.movie_id
WHERE
    year = 2017
        AND MONTH(date_published) = 3
        AND LOWER(country) LIKE '%usa%'
        AND total_votes > 1000
GROUP BY genre
ORDER BY movie_count DESC;



-- Q15. Find the movies in each genre that start with the characters ‘The’ and have an average rating > 8.


SELECT 
    title, 
    avg_rating,
    genre
FROM
    movie AS m 
	    INNER JOIN
    genre AS g
    	ON m.id =g.movie_id 
			INNER JOIN
		ratings AS r 
			ON m.id = r.movie_id
WHERE
    title like 'The%' AND avg_rating>8
ORDER BY genre, avg_rating DESC;


-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

SELECT 
    COUNT(m.id) AS movie_count
FROM
    movie AS m 
	    INNER JOIN
	ratings AS r 
		ON m.id = r.movie_id
WHERE
    median_rating=8 AND 
    date_published BETWEEN '2018-04-01' AND '2019-04-01';



-- Q17. Do German movies get more votes than Italian movies? 


WITH votes_summary AS
(
SELECT 
	COUNT(CASE WHEN LOWER(m.languages) LIKE '%german%' THEN m.id END) AS german_movie_count,
	COUNT(CASE WHEN LOWER(m.languages) LIKE '%italian%' THEN m.id END) AS italian_movie_count,
	SUM(CASE WHEN LOWER(m.languages) LIKE '%german%' THEN r.total_votes END) AS german_movie_votes,
	SUM(CASE WHEN LOWER(m.languages) LIKE '%italian%' THEN r.total_votes END) AS italian_movie_votes
FROM
    movie AS m 
	    INNER JOIN
	ratings AS r 
		ON m.id = r.movie_id
)
SELECT 
    ROUND(german_movie_votes / german_movie_count, 2) AS german_votes_per_movie,
    ROUND(italian_movie_votes / italian_movie_count, 2) AS italian_votes_per_movie
FROM
    votes_summary;

-- Segment 3:

-- Q18. Find the number of null values in each column of the 'names' table, except for the 'id' column.

SELECT 
    COUNT(*) AS name_nulls
FROM
    names
WHERE name IS NULL;

SELECT 
    COUNT(*) AS height_nulls
FROM
    names
WHERE height IS NULL;

SELECT 
    COUNT(*) AS date_of_birth_nulls
FROM
    names
WHERE date_of_birth IS NULL;

SELECT 
    COUNT(*) AS known_for_movies_nulls
FROM
    names
WHERE known_for_movies IS NULL;


-- Alternate way
SELECT 
    COUNT(CASE
        WHEN name IS NULL THEN id
    END) AS name_nulls,
    COUNT(CASE
        WHEN height IS NULL THEN id
    END) AS height_nulls,
    COUNT(CASE
        WHEN date_of_birth IS NULL THEN id
    END) AS date_of_birth_nulls,
    COUNT(CASE
        WHEN known_for_movies IS NULL THEN id
    END) AS known_for_movies_nulls
FROM
    names;
    

-- Q19. Who are the top three directors in each of the top three genres whose movies have an average rating > 8?


WITH top_rated_genres AS
(
SELECT 
    genre,
    COUNT(m.id) AS movie_count,
	RANK () OVER (ORDER BY COUNT(m.id) DESC) AS genre_rank
FROM
    genre AS g
        LEFT JOIN
    movie AS m 
		ON g.movie_id = m.id
			INNER JOIN
		ratings AS r
			ON m.id=r.movie_id
WHERE avg_rating>8
GROUP BY genre
)
SELECT 
	n.name as director_name,
	COUNT(m.id) AS movie_count
FROM
	names AS n
		INNER JOIN
	director_mapping AS d
		ON n.id=d.name_id
			INNER JOIN
        movie AS m
			ON d.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
					INNER JOIN
						genre AS g
					ON g.movie_id = m.id
WHERE g.genre IN (SELECT DISTINCT genre FROM top_rated_genres WHERE genre_rank<=3)
		AND avg_rating>8
GROUP BY name
ORDER BY movie_count DESC
LIMIT 3;


-- Q20. Who are the top two actors whose movies have a median rating >= 8?


SELECT 
	n.name as actor_name,
	COUNT(m.id) AS movie_count
FROM
	names AS n
		INNER JOIN
	role_mapping AS a
		ON n.id=a.name_id
			INNER JOIN
        movie AS m
			ON a.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
WHERE median_rating>=8 AND category = 'actor'
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 2;



-- Q21. Which are the top three production houses based on the number of votes received by their movies?


WITH top_prod AS
(
SELECT 
    m.production_company,
    SUM(r.total_votes) AS vote_count,
    ROW_NUMBER() OVER (ORDER BY SUM(r.total_votes) DESC) AS prod_company_rank
FROM
    movie AS m
        LEFT JOIN
    ratings AS r
		ON m.id = r.movie_id
WHERE m.production_company IS NOT NULL
GROUP BY m.production_company
)
SELECT 
    *
FROM
    top_prod
WHERE
    prod_company_rank <= 3;



-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the

WITH actor_ratings AS
(
SELECT 
	n.name as actor_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(m.id) as movie_count,
	ROUND(
		SUM(r.avg_rating*r.total_votes)
        /
		SUM(r.total_votes)
			,2) AS actor_avg_rating
FROM
	names AS n
		INNER JOIN
	role_mapping AS a
		ON n.id=a.name_id
			INNER JOIN
        movie AS m
			ON a.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
WHERE category = 'actor' AND LOWER(country) like '%india%'
GROUP BY actor_name
)
SELECT *,
	RANK() OVER (ORDER BY actor_avg_rating DESC, total_votes DESC) AS actor_rank
FROM
	actor_ratings
WHERE movie_count>=5;



-- Q23.Find the top five actresses in Hindi movies released in India based on their average ratings.

WITH actress_ratings AS
(
SELECT 
	n.name as actress_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(m.id) as movie_count,
	ROUND(
		SUM(r.avg_rating*r.total_votes)
        /
		SUM(r.total_votes)
			,2) AS actress_avg_rating
FROM
	names AS n
		INNER JOIN
	role_mapping AS a
		ON n.id=a.name_id
			INNER JOIN
        movie AS m
			ON a.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
WHERE category = 'actress' AND LOWER(languages) like '%hindi%'
GROUP BY actress_name
)
SELECT *,
	ROW_NUMBER() OVER (ORDER BY actress_avg_rating DESC, total_votes DESC) AS actress_rank
FROM
	actress_ratings
WHERE movie_count>=3
LIMIT 5;



/* Q24. Consider thriller movies having at least 25,000 votes. Classify them according to their average ratings in
   the following categories: 

			Rating > 8: Superhit
			Rating between 7 and 8: Hit
			Rating between 5 and 7: One-time-watch
			Rating < 5: Flop
--------------------------------------------------------------------------------------------*/


SELECT 
    m.title AS movie_name,
    CASE
        WHEN r.avg_rating > 8 THEN 'Superhit'
        WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit'
        WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One time watch'
        ELSE 'Flop'
    END AS movie_category
FROM
    movie AS m
        LEFT JOIN
    ratings AS r ON m.id = r.movie_id
        LEFT JOIN
    genre AS g ON m.id = g.movie_id
WHERE
    LOWER(genre) = 'thriller'
        AND total_votes > 25000;


-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 

WITH genre_summary AS
(
SELECT 
    genre,
    ROUND(AVG(duration),2) AS avg_duration
FROM
    genre AS g
        LEFT JOIN
    movie AS m 
		ON g.movie_id = m.id
GROUP BY genre
)
SELECT *,
	SUM(avg_duration) OVER (ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
    AVG(avg_duration) OVER (ORDER BY genre ROWS UNBOUNDED PRECEDING) AS moving_avg_duration
FROM
	genre_summary;
    



-- Q26. Which are the five highest-grossing movies in each year for each of the top three genres?

WITH top_genres AS
(
SELECT 
    genre,
    COUNT(m.id) AS movie_count,
	RANK () OVER (ORDER BY COUNT(m.id) DESC) AS genre_rank
FROM
    genre AS g
        LEFT JOIN
    movie AS m 
		ON g.movie_id = m.id
GROUP BY genre
)
,
top_grossing AS
(
SELECT 
    g.genre,
	year,
	m.title as movie_name,
    worlwide_gross_income,
    RANK() OVER (PARTITION BY g.genre, year
					ORDER BY CONVERT(REPLACE(TRIM(worlwide_gross_income), "$ ",""), UNSIGNED INT) DESC) AS movie_rank
FROM
movie AS m
	INNER JOIN
genre AS g
	ON g.movie_id = m.id
WHERE g.genre IN (SELECT DISTINCT genre FROM top_genres WHERE genre_rank<=3)
)
SELECT * 
FROM
	top_grossing
WHERE movie_rank<=5;

   
/*Q27. What are the top two production houses that have produced the highest number of hits (median rating >= 8) among
multilingual movies? */


WITH top_prod AS
(
SELECT 
    m.production_company,
    COUNT(m.id) AS movie_count,
    ROW_NUMBER() OVER (ORDER BY COUNT(m.id) DESC) AS prod_company_rank
FROM
    movie AS m
        LEFT JOIN
    ratings AS r
		ON m.id = r.movie_id
WHERE median_rating>=8 AND m.production_company IS NOT NULL AND POSITION(',' IN languages)>0
GROUP BY m.production_company
)
SELECT 
    *
FROM
    top_prod
WHERE
    prod_company_rank <= 2;



-- Q28. Who are the top 3 actresses based on the number of Super Hit movies (average rating > 8) in 'drama' genre?


WITH actress_ratings AS
(
SELECT 
	n.name as actress_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(m.id) as movie_count,
	ROUND(
		SUM(r.avg_rating*r.total_votes)
        /
		SUM(r.total_votes)
			,2) AS actress_avg_rating
FROM
	names AS n
		INNER JOIN
	role_mapping AS a
		ON n.id=a.name_id
			INNER JOIN
        movie AS m
			ON a.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
					INNER JOIN
				genre AS g
				ON m.id=g.movie_id
WHERE category = 'actress' AND lower(g.genre) ='drama'
GROUP BY actress_name
)
SELECT *,
	ROW_NUMBER() OVER (ORDER BY actress_avg_rating DESC, total_votes DESC) AS actress_rank
FROM
	actress_ratings
LIMIT 3;

SELECT 
	n.name as actress_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(m.id) as movie_count,
	ROUND(
		SUM(r.avg_rating*r.total_votes)
        /
		SUM(r.total_votes)
			,2) AS actress_avg_rating
FROM
	names AS n
		INNER JOIN
	role_mapping AS a
		ON n.id=a.name_id
			INNER JOIN
        movie AS m
			ON a.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
					INNER JOIN
				genre AS g
				ON m.id=g.movie_id
WHERE category = 'actress' AND lower(g.genre) ='drama'
GROUP BY actress_name;


/* Q29. Get the following details for top 9 directors (based on number of movies):

Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
Total movie duration*/


WITH top_directors AS
(
SELECT 
	n.id as director_id,
    n.name as director_name,
	COUNT(m.id) AS movie_count,
    RANK() OVER (ORDER BY COUNT(m.id) DESC) as director_rank
FROM
	names AS n
		INNER JOIN
	director_mapping AS d
		ON n.id=d.name_id
			INNER JOIN
        movie AS m
			ON d.movie_id = m.id
GROUP BY n.id
),
movie_summary AS
(
SELECT
	n.id as director_id,
    n.name as director_name,
    m.id AS movie_id,
    m.date_published,
	r.avg_rating,
    r.total_votes,
    m.duration,
    LEAD(date_published) OVER (PARTITION BY n.id ORDER BY m.date_published) AS next_date_published,
    DATEDIFF(LEAD(date_published) OVER (PARTITION BY n.id ORDER BY m.date_published),date_published) AS inter_movie_days
FROM
	names AS n
		INNER JOIN
	director_mapping AS d
		ON n.id=d.name_id
			INNER JOIN
        movie AS m
			ON d.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
WHERE n.id IN (SELECT director_id FROM top_directors WHERE director_rank<=9)
)
SELECT 
	director_id,
	director_name,
	COUNT(DISTINCT movie_id) as number_of_movies,
	ROUND(AVG(inter_movie_days),0) AS avg_inter_movie_days,
	ROUND(
	SUM(avg_rating*total_votes)
	/
	SUM(total_votes)
		,2) AS avg_rating,
    SUM(total_votes) AS total_votes,
    MIN(avg_rating) AS min_rating,
    MAX(avg_rating) AS max_rating,
    SUM(duration) AS total_duration
FROM 
movie_summary
GROUP BY director_id
ORDER BY number_of_movies DESC, avg_rating DESC;

