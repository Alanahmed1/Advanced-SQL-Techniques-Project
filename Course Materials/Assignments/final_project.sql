-- PART I: SCHOOL ANALYSIS

-- 1. View the schools and school details tables
SELECT * FROM schools;
SELECT * FROM school_details;

-- 2. In each decade, how many schools were there that produced players?

SELECT 
         ROUND(floor(yearid /10) *10) AS decade, 
         count(DISTINCT schoolid) as num_schools

FROM schools
GROUP BY decade

-- 3. What are the names of the top 5 schools that produced the most players?

SELECT sd.name_full, COUNT(DISTINCT s.playerid) AS num_players

FROM schools AS s LEFT JOIN school_details AS sd
             ON s.schoolid = sd.schoolid

GROUP BY sd.name_full
ORDER BY num_players DESC
LIMIT 5;

-- 4. For each decade, what were the names of the top 3 schools that produced the most players?

WITH s_cte AS ( SELECT 
                        ROUND(floor(yearid /10) *10) AS decade, 
                        sd.name_full,
                        COUNT(DISTINCT s.playerid) AS num_players

                FROM schools AS s LEFT JOIN school_details AS sd
                            ON s.schoolid = sd.schoolid

                GROUP BY decade, sd.name_full),

    rank_cte AS (SELECT  
                        decade, name_full, num_players,
                        DENSE_RANK() OVER(PARTITION BY decade ORDER BY num_players DESC) AS producing_rank
                 FROM s_cte)

SELECT *       
FROM rank_cte

WHERE producing_rank <= 3
ORDER BY decade DESC, producing_rank;


-- PART II: SALARY ANALYSIS

-- 1. View the salaries table

SELECT * FROM salaries

-- 2. Return the top 20% of teams in terms of average annual spending

WITH total_spending_cte AS (SELECT  teamid, yearid,
                                    SUM(salary) as total_spending
                            FROM salaries
                            GROUP BY teamid, yearid
                            ),

     avg_spending_cte AS (SELECT teamid,
                                    AVG(total_spending) AS avg_spending,
                                    NTILE(5) OVER( ORDER BY AVG(total_spending) DESC) AS precent_spending

                            FROM total_spending_cte 
                            GROUP BY teamid)

SELECT teamid, 
        Round(avg_spending/ 1000000) AS avg_spending_millions
       
FROM avg_spending_cte
WHERE precent_spending = 1

-- 3. For each team, show the cumulative sum of spending over the years

WITH total_spending_cte1 AS (SELECT  teamid, yearid,
                                    SUM(salary) AS total_spending
                                    
                                FROM salaries
                                GROUP BY teamid, yearid)

SELECT teamid,
    ROUND(SUM(total_spending) OVER ( PARTITION BY teamid ORDER BY yearid )/ 1000000, 1) AS umulative_sum_millions                 
FROM total_spending_cte1

-- 4. Return the first year that each team's cumulative spending surpassed 1 billion

WITH total_spending_cte1 AS (SELECT  teamid, yearid,
                                    SUM(salary) AS total_spending
                                    
                                FROM salaries
                                GROUP BY teamid, yearid),
    cumulative_sum_cte AS( SELECT teamid,yearid,
                                SUM(total_spending) OVER ( PARTITION BY teamid ORDER BY yearid )AS cumulative_sum 

                            FROM total_spending_cte1),
    ranking_cte AS ( SELECT TEAMID, yearid, cumulative_sum,
                            DENSE_RANK() OVER(PARTITION BY teamid ORDER BY cumulative_sum) AS ranking

                        FROM cumulative_sum_cte
                        WHERE cumulative_sum >1000000000)

SELECT teamid, yearid,
       ROUND(cumulative_sum /1000000000,2)
FROM ranking_cte
WHERE ranking = 1


-- PART III: PLAYER CAREER ANALYSIS


-- 1. View the players table and find the number of players in the table

SELECT * FROM players;

SELECT COUNT(DISTINCT playerid)
FROM players

-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). Sort from longest career to shortest career.

WITH birthdate_cte AS ( SELECT
                        nameGiven,birthYear,birthMonth,birthDay,
                        debut,finalGame,
                                  
                        CASE 
                            WHEN birthYear IS NULL THEN NULL 
                            ELSE 
                                CAST(CONCAT(birthYear::text,'-', COALESCE(LPAD(birthMonth::text, 2, '0'), '01'),'-', 
                                     COALESCE(LPAD(birthDay::text, 2, '0'), '01')) AS DATE) 
                           END AS birthdate
                    FROM 
                        players),
    games_ctes AS (SELECT 
                        nameGiven, 
                        EXTRACT(YEAR FROM AGE(debut, birthdate)) AS starting_age, 
                        EXTRACT(YEAR FROM AGE(finalGame, birthdate)) AS ending_age, 
                        EXTRACT(YEAR FROM AGE(finalGame, debut)) AS career_length
                    FROM 
                        birthdate_cte
                    )

SELECT nameGiven, starting_age, 
       ending_age, career_length

FROM games_ctes 
WHERE starting_age IS NOT NULL
ORDER BY career_length DESC;


-- 3. What team did each player play on for their starting and ending years?

SELECT p.nameGiven,
        sd.yearid AS starting_year, sd.teamid AS starting_team, 
        sf.yearid AS ending_year, sf.teamid AS ending_team
FROM players AS p INNER join salaries AS sd 
     ON p.playerid = sd.playerid
     AND EXTRACT(YEAR FROM p.debut) = sd.yearid
     INNER JOIN salaries AS sf 
     ON p.playerid = sf.playerid
     AND EXTRACT (YEAR FROM p.finalGame) = sf.yearid

SELECT * 

FROM salaries


-- 4. How many players started and ended on the same team and also played for over a decade?

SELECT p.nameGiven,
        sd.yearid AS starting_year, sd.teamid AS starting_team, 
        sf.yearid AS ending_year, sf.teamid AS ending_team
FROM players AS p INNER join salaries AS sd 
     ON p.playerid = sd.playerid
     AND EXTRACT(YEAR FROM p.debut) = sd.yearid
     INNER JOIN salaries AS sf 
     ON p.playerid = sf.playerid
     AND EXTRACT (YEAR FROM p.finalGame) = sf.yearid

WHERE sd.teamid = sf.teamid AND sf.yearid - sd.yearid > 10


-- PART IV: PLAYER COMPARISON ANALYSIS

-- 1. View the players table

SELECT * FROM players;


-- 2. Which players have the same birthday?


WITH birthdate_cte AS ( SELECT nameGiven,
                        CAST( birthYear || '-' || birthMonth || '-' || birthDay AS DATE) AS birthdate

                        FROM players), 

Same_birthday_cte AS (SELECT birthdate, 
                            STRING_AGG(nameGiven, ', ' ORDER BY nameGiven) AS Same_birthday_players,
                            COUNT(nameGiven) AS  num_simlar_birthdate

                        FROM birthdate_cte
                        GROUP BY birthdate)

SELECT birthdate, Same_birthday_players

FROM Same_birthday_cte
WHERE num_simlar_birthdate >= 2 AND birthdate IS NOT NULL

-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both

SELECT  s.teamid,

      ROUND(SUM(CASE WHEN p.bats = 'R' THEN 1.0 ELSE 0.0 END) / NULLIF(COUNT(s.playerid),0) * 100, 1) AS right_bats,
     ROUND(SUM(CASE WHEN p.bats = 'L' THEN 1.0 ELSE 0.0 END) / NULLIF(COUNT(s.playerid),0) * 100,1) AS left_bats,
      ROUND(SUM(CASE WHEN p.bats = 'B' THEN 1.0 ELSE 0.0 END) / NULLIF(COUNT(s.playerid),0) * 100,1) AS Both_bats

 -- TIP-- NULLIF(COUNT(s.playerid), 0) returns NULL if the count is zero, preventing the division by zero error.

From players AS p LEFT JOIN salaries AS s
     ON p.playerid = s.playerid
WHERE s.teamid IS NOT NULL

GROUP BY teamid


-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?

WITH height_weight_cte AS (SELECT 
                                FLOOR(EXTRACT (YEAR FROM debut) / 10) * 10 AS decade,
                                AVG(height) AS avg_height,
                                    AVG(weight) AS avg_weight

                            FROM players
                            GROUP BY decade
                            ORDER BY decade)

SELECT decade,

       avg_height - LAG (avg_height) OVER(ORDER BY decade) AS avg_height_prior,
       avg_weight -  LAG (avg_weight) OVER(ORDER BY decade) AS avg_weight_prior
       
FROM height_weight_cte
WHERE decade IS NOT NULL 