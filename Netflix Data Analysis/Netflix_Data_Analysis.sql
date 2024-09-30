create database netflix_project_analysis;

use netflix_project_analysis;


CREATE TABLE titles (
    id VARCHAR(10) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    type VARCHAR(10) NOT NULL,
    description TEXT,
    release_year INTEGER,
    age_certification VARCHAR(10),
    runtime INTEGER,
    genres TEXT,
    production_countries TEXT,
    seasons INTEGER,
    imdb_id VARCHAR(15),
    imdb_score DECIMAL(3,1),
    imdb_votes INTEGER,
    tmdb_popularity DECIMAL(6,3),
    tmdb_score DECIMAL(4,3)
);


CREATE TABLE credits (
    person_id INTEGER,
    id VARCHAR(10),
    name VARCHAR(255) NOT NULL,
    characters VARCHAR(255),
    role VARCHAR(50),
    PRIMARY KEY (person_id, id)
);


SET GLOBAL local_infile=1;


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\titles.csv'
INTO TABLE titles
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\credits.csv'
INTO TABLE credits
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

select * from titles;

select * from credits;

-- Which movies and shows on Netflix ranked in the top 10 and bottom 10 based on their IMDB scores?

-- Top 10 Movies

SELECT title, 
type, 
imdb_score
FROM titles
WHERE imdb_score >= 8.0
AND type = 'MOVIE'
ORDER BY imdb_score DESC
LIMIT 10;


-- Top 10 Shows

SELECT title, 
type, 
imdb_score
FROM titles
WHERE imdb_score >= 8.0
AND type = 'SHOW'
ORDER BY imdb_score DESC
LIMIT 10;


-- Bottom 10 Movies

SELECT title, 
type, 
imdb_score
FROM titles
WHERE type = 'MOVIE'
ORDER BY imdb_score ASC
LIMIT 10;


-- Bottom 10 Shows

SELECT title, 
type, 
imdb_score
FROM titles
WHERE type = 'SHOW'
ORDER BY imdb_score ASC
LIMIT 10;


-- How many movies and shows fall in each decade in Netflix's library?

SELECT CONCAT(FLOOR(release_year / 10) * 10, 's') AS decade,
	COUNT(*) AS movies_shows_count
FROM titles
WHERE release_year >= 1940
GROUP BY CONCAT(FLOOR(release_year / 10) * 10, 's')
ORDER BY decade;


-- How did age-certifications impact the dataset?

SELECT DISTINCT age_certification, 
ROUND(AVG(imdb_score),2) AS avg_imdb_score,
ROUND(AVG(tmdb_score),2) AS avg_tmdb_score
FROM titles
GROUP BY age_certification
ORDER BY avg_imdb_score DESC;


SELECT age_certification, 
COUNT(*) AS certification_count
FROM titles
WHERE type = 'Movie' 
AND age_certification != 'N/A' and age_certification != ""
GROUP BY age_certification
ORDER BY certification_count DESC
LIMIT 5;


-- Which genres are the most common?

SELECT genres, 
COUNT(*) AS title_count
FROM titles 
WHERE type = 'Movie'
GROUP BY genres
ORDER BY title_count DESC
LIMIT 10;


-- Top 10 most common genres for SHOWS

SELECT genres, 
COUNT(*) AS title_count
FROM titles 
WHERE type = 'Show'
GROUP BY genres
ORDER BY title_count DESC
LIMIT 10;


-- Top 3 most common genres OVERALL

SELECT t.genres, 
COUNT(*) AS genre_count
FROM titles AS t
WHERE t.type = 'Movie' or t.type = 'Show'
GROUP BY t.genres
ORDER BY genre_count DESC
LIMIT 3;


-- What were the average IMDB and TMDB scores for shows and movies? 

SELECT DISTINCT `type`, 
ROUND(AVG(imdb_score),2) AS avg_imdb_score,
ROUND(AVG(tmdb_score),2) as avg_tmdb_score
FROM titles
GROUP BY `type`;


-- What were the average IMDB and TMDB scores for each production country?

SELECT DISTINCT production_countries, 
ROUND(AVG(imdb_score),2) AS avg_imdb_score,
ROUND(AVG(tmdb_score),2) AS avg_tmdb_score
FROM titles
GROUP BY production_countries
ORDER BY avg_imdb_score DESC;


-- What were the average IMDB and TMDB scores for each age certification for shows and movies?

SELECT DISTINCT age_certification, 
ROUND(AVG(imdb_score),2) AS avg_imdb_score,
ROUND(AVG(tmdb_score),2) AS avg_tmdb_score
FROM titles
GROUP BY age_certification
ORDER BY avg_imdb_score DESC;


-- Who were the top 20 actors that appeared the most in movies/shows? 

SELECT DISTINCT name as actor, 
COUNT(*) AS number_of_appearences 
FROM credits
GROUP BY actor
ORDER BY number_of_appearences DESC
LIMIT 20;


-- Who were the top 20 directors that directed the most movies/shows? 

SELECT DISTINCT name as director, 
COUNT(*) AS number_of_appearences 
FROM credits
WHERE role = 'director'
GROUP BY name
ORDER BY number_of_appearences DESC
LIMIT 20;


-- Calculating the average runtime of movies and TV shows separately

SELECT 
'Movies' AS content_type,
ROUND(AVG(runtime),2) AS avg_runtime_min
FROM titles
WHERE type = 'Movie'
UNION ALL
SELECT 
'Show' AS content_type,
ROUND(AVG(runtime),2) AS avg_runtime_min
FROM titles
WHERE type = 'Show';


-- Finding the titles and  directors of movies released on or after 2010

SELECT DISTINCT t.title, c.name AS director, 
release_year
FROM titles AS t
JOIN credits AS c 
ON t.id = c.id
WHERE t.type = 'Movie' 
AND t.release_year >= 2010 
AND c.role = 'director'
ORDER BY release_year DESC;


-- Which shows on Netflix have the most seasons?

SELECT title, 
SUM(seasons) AS total_seasons
FROM titles 
WHERE type = 'Show'
GROUP BY title
ORDER BY total_seasons DESC
LIMIT 10;



-- Which genres had the most movies? 

SELECT genres, 
COUNT(*) AS title_count
FROM titles 
WHERE type = 'Movie'
GROUP BY genres
ORDER BY title_count DESC
LIMIT 10;


-- Which genres had the most shows? 

SELECT genres, 
COUNT(*) AS title_count
FROM titles 
WHERE type = 'Show'
GROUP BY genres
ORDER BY title_count DESC
LIMIT 10;


-- Which genres had the most shows?
 
SELECT genres, 
COUNT(*) AS title_count
FROM titles 
WHERE type = 'Show'
GROUP BY genres
ORDER BY title_count DESC
LIMIT 10;


-- Titles and Directors of movies with high IMDB scores (>7.5) and high TMDB popularity scores (>80) 

SELECT t.title, 
c.name AS director
FROM titles AS t
JOIN credits AS c 
ON t.id = c.id
WHERE t.type = 'Movie' 
AND t.imdb_score > 7.5 
AND t.tmdb_popularity > 80 
AND c.role = 'director';


-- What were the total number of titles for each year? 

SELECT release_year, 
COUNT(*) AS title_count
FROM titles 
GROUP BY release_year
ORDER BY release_year DESC;


-- Actors who have starred in the most highly rated movies or shows

SELECT c.name AS actor, 
COUNT(*) AS num_highly_rated_titles
FROM credits AS c
JOIN titles AS t 
ON c.id = t.id
WHERE c.role = 'actor'
AND (t.type = 'Movie' OR t.type = 'Show')
AND t.imdb_score > 8.0
AND t.tmdb_score > 8.0
GROUP BY c.name
ORDER BY num_highly_rated_titles DESC;


-- Which actors/actresses played the same character in multiple movies or TV shows? 

SELECT c.name AS actor_actress, 
c.character_name, 
COUNT(DISTINCT t.title) AS num_titles
FROM credits AS c
JOIN titles AS t 
ON c.id = t.id
WHERE c.role = 'actor' OR c.role = 'actress'
GROUP BY c.name, c.character_name
HAVING COUNT(DISTINCT t.title) > 1;


-- What were the top 3 most common genres?

SELECT t.genres, 
COUNT(*) AS genre_count
FROM titles AS t
WHERE t.type = 'Movie'
GROUP BY t.genres
ORDER BY genre_count DESC
LIMIT 3;


-- Average IMDB score for leading actors/actresses in movies or shows 

SELECT c.name AS actor_actress, 
ROUND(AVG(t.imdb_score),2) AS average_imdb_score
FROM credits AS c
JOIN titles AS t 
ON c.id = t.id
WHERE c.role = 'actor' OR c.role = 'actress'
AND c.character_name = 'leading role'
GROUP BY c.name
ORDER BY average_imdb_score DESC;
