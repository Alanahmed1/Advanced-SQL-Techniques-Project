test

# Advanced SQL Queries - Learning & Project Repository

Welcome to the **Advanced SQL Queries** repository! 🚀 This repository is designed to document my learning journey through the [SQL Advanced Queries](https://www.udemy.com/course/sql-advanced-queries/learn/lecture/47029789?start=1#overview) course and apply the acquired skills to a real-world project.

## 📌 Repository Structure  

This repository is divided into two main parts:  

1. **Learning Advanced SQL Queries** 📖  
   - Covers key concepts and techniques from the course, including complex joins, subqueries, window functions, common table expressions (CTEs), and performance optimization.  
   - Includes practice queries and examples for each topic.  

2. **Final Project - Real-Life Application** 🏗️  
   - A hands-on project applying the learned SQL techniques to solve real-world data challenges.  
   - Demonstrates query optimization, data analysis, and advanced reporting techniques.  

## 🚀 Why This Repository?  
- To serve as a reference for advanced SQL queries.  
- To provide practical examples that reinforce SQL skills.  
- To showcase the application of SQL in a real-world scenario.  

Feel free to explore, learn, and contribute! 🎯  

🔍 SQL queries? Check them out here: [Course Materials](/Course%20Materials/)
## 🔍 Background  

This is a **hands-on, project-based** course designed to take your SQL skills beyond the "Big 6" clauses and into advanced querying techniques. The course covers:  

- Multi-table analyses using joins, self-joins, cross-joins, and unions.  
- Writing and optimizing **nested queries** using subqueries and Common Table Expressions (CTEs).  
- Exploring **window functions** like `ROW_NUMBER`, `RANK`, `FIRST_VALUE`, `LEAD`, and `LAG`.  
- Working with **SQL functions** for numeric, datetime, string, and NULL handling.  
- Applying advanced SQL techniques to real-world data analysis problems.  
- **Data Analysis Applications**: Handling duplicate values, special value filters, rolling calculations, and more.  


> ⚠️ **Note:** This repository does not explain these concepts in detail. Instead, you will find **PDF materials and SQL queries** for practice. The focus here is on **hands-on implementation** and applying the concepts learned in the course.  



## 🏗️ The Final Project  

The final project is where all the learned techniques come together! In this project, we take on the role of a **Data Analyst Intern for Major League Baseball (MLB)**. Using **advanced SQL querying techniques**, we’ll analyze player statistics, track how factors like salary, height, and weight have changed over time, and explore trends across different teams. This project is designed to simulate a real-world data analysis scenario, allowing us to apply the concepts learned throughout the course in a practical and meaningful way.

The project is divided into **four parts**, each focusing on a specific aspect of the data. Each part contains **four tasks** that challenge us to use advanced SQL techniques to extract insights and solve problems. Let’s dive into the tasks below!

---

## PART I: SCHOOL ANALYSIS  
This section focuses on analyzing the schools that produced MLB players. We’ll explore trends over decades, identify top-performing schools, and use advanced SQL functions to answer key questions.

### Insights from the Query: **Number of Schools Producing Players by Decade**
```sql
SELECT 
         ROUND(FLOOR(yearid /10) *10) AS decade, 
         count(DISTINCT schoolid) as num_schools

FROM schools
GROUP BY decade;

```
This query calculates the number of unique schools that produced MLB players in each decade.

#### Key Takeaways:
- The data shows the **evolution of player development**, with growth in the 20th century and a decline in recent decades.  
- The sharp drop in the **2010s** suggests changes in scouting and development strategies.  
- Further analysis could explore factors like international talent, college sports changes, or private academies.


#### Number of Schools Producing Players by Decade

![ Number of Schools Producing Players by Decade](/readm.pic/num_school_decade.png)


### Insights from the Query: **Top 5 Schools Producing the Most Players**
```sql
SELECT 
        sd.name_full, 
        COUNT(DISTINCT s.playerid) AS num_players

FROM schools AS s LEFT JOIN school_details AS sd
             ON s.schoolid = sd.schoolid

GROUP BY sd.name_full
ORDER BY num_players DESC
LIMIT 5;

```
The query identifies the top 5 schools that produced the most MLB players. Here are the key insights:

1. **Top Schools**:  
   - **University of Texas at Austin** leads with **107 players**, followed closely by **University of Southern California (105)** and **Arizona State University (101)**.  
   - **Stanford University (86)** and **University of Michigan (76)** round out the top 5.

---

### Summary Table

| School Name                     | Number of Players |
|---------------------------------|-------------------|
| University of Texas at Austin   | 107               |
| University of Southern California | 105             |
| Arizona State University        | 101               |
| Stanford University             | 86                |
| University of Michigan          | 76                |

---

### Key Takeaway:
The data underscores the importance of **major universities** in developing MLB talent, with the top 5 schools producing a significant number of players. This reflects their strong athletic programs and resources dedicated to baseball.

### Insights from the Query: **Top 3 Schools Producing the Most Players by Decade**
```sql
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

```
This query identifies the top 3 schools that produced the most MLB players in each decade. Here are the key insights:

1. **Historical Trends**:  
   - In the **early decades (1870s–1900s)**, Ivy League schools like **Yale University**, **Brown University**, and **College of the Holy Cross** dominated.  
   - By the **mid-20th century**, large public universities like **University of Southern California**, **Arizona State University**, and **University of Texas at Austin** became the primary producers of MLB talent.  

   - In the **2010s**, **University of Florida** emerged as the top school, reflecting shifting trends in player development.

  2. **Regional Influence**:  
   - Schools from baseball-rich regions like **California**, **Texas**, and **Arizona** dominate the rankings, underscoring the importance of regional talent pools.

   ### Key Takeaways:
- The data reveals the **evolution of player development** in MLB, with a shift from Ivy League schools to large public universities.  
- The decline in player production in recent decades suggests changes in recruitment strategies, such as the rise of international talent or private academies.  
- Schools with strong baseball programs and resources continue to play a critical role in developing MLB talent.

## PART II:  SALARY ANALYSIS 
In this section, we’ll analyze team spending patterns, calculate cumulative spending, and identify key milestones in team budgets.

### Insights from the Query: **Top 20% of Teams by Average Annual Spending**
```sql
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
WHERE precent_spending = 1;

```

This query identifies the top 20% of MLB teams with the highest average annual spending on player salaries. Here are the key insights:

1. **Top Spenders**:  
   - **San Francisco Giants (SFG)** lead with an average annual spending of **$144 million**, followed by **Los Angeles Angels (LAA)** at **$118 million** and **New York Yankees (NYA)** at **$109 million**.  
   - Other top spenders include **Boston Red Sox (BOS)**, **Los Angeles Dodgers (LAN)**, **Washington Nationals (WAS)**, **Arizona Diamondbacks (ARI)**, and **Philadelphia Phillies (PHI)**.
   ---

### Summary Table

| Team ID | Average Annual Spending (Millions) |
|---------|------------------------------------|
| SFG     | 144                                |
| LAA     | 118                                |
| NYA     | 109                                |
| BOS     | 81                                 |
| LAN     | 75                                 |
| WAS     | 72                                 |
| ARI     | 71                                 |
| PHI     | 66                                 |

---
### Key Takeaway:
The data underscores the **financial dominance** of top MLB teams, with the **Giants**, **Angels**, and **Yankees** leading in average annual spending. This reflects their commitment to maintaining competitive rosters and their ability to attract high-profile players

### Insights from the Query: **Cumulative Spending Over the Years by Team**
```sql

WITH total_spending_cte1 AS (SELECT  teamid, yearid,
                                    SUM(salary) AS total_spending
                                    
                                FROM salaries
                                GROUP BY teamid, yearid)

SELECT 
    teamid,
    ROUND(SUM(total_spending) OVER ( PARTITION BY teamid ORDER BY yearid )/ 1000000, 1) AS umulative_sum_millions  
                   
FROM total_spending_cte1;

```
This query calculates the cumulative sum of spending (in millions) for each MLB team over the years. Here are the key insights:

1. **Top Spenders**:  
   - The **New York Yankees (NYA)** have the highest cumulative spending at **$3.28 billion**, reflecting their long history of high payrolls and consistent investment in player salaries.  
   - Other top spenders include the **Los Angeles Dodgers (LAN)** at **$2.24 billion** and the **Boston Red Sox (BOS)** at **$2.14 billion**.

 2. **Growth Over Time**:  
   - Cumulative spending has grown exponentially for most teams, especially in the last two decades, as player salaries and team revenues have increased.  
   - Teams like the **Arizona Diamondbacks (ARI)** and **Colorado Rockies (COL)**, which joined the league in the 1990s, show rapid growth in cumulative spending as they established themselves.

### Key Takeaways:
- The data highlights the **financial dominance** of large-market teams like the Yankees, Dodgers, and Red Sox, which have consistently invested heavily in player salaries.  
- Smaller-market teams face budget constraints but have found ways to remain competitive through strategic spending and player development.  
- Cumulative spending trends reflect the broader financial dynamics of MLB, with significant growth in player salaries and team revenues over the years.

### Insights from the Query: **First Year Each Team's Cumulative Spending Surpassed $1 Billion**
```sql
WITH total_spending_cte1 AS (SELECT  teamid,
                                     yearid,
                                    SUM(salary) AS total_spending   
                              FROM salaries
                               GROUP BY teamid, yearid),

    cumulative_sum_cte AS( SELECT teamid,
                                  yearid,
                                  SUM(total_spending) OVER ( PARTITION BY teamid ORDER BY yearid )AS cumulative_sum 

                            FROM total_spending_cte1),

    ranking_cte AS ( SELECT TEAMID, yearid, cumulative_sum,
                            DENSE_RANK() OVER(PARTITION BY teamid ORDER BY cumulative_sum) AS ranking

                        FROM cumulative_sum_cte
                        WHERE cumulative_sum >1000000000)

SELECT teamid, yearid,
       ROUND(cumulative_sum /1000000000,2)
FROM ranking_cte
WHERE ranking = 1;
```
This query identifies the first year each MLB team's cumulative spending exceeded **$1 billion**. Here are the key insights:

1. **Early Spenders**:  
   - The **New York Yankees (NYA)** were the first team to surpass $1 billion in cumulative spending, achieving this milestone in **2003**. This reflects their long-standing commitment to high payrolls and competitive rosters.  
   - The **Boston Red Sox (BOS)** followed closely, reaching $1 billion in **2004**.

2. **Mid-2000s Surge**:  
   - Many teams crossed the $1 billion threshold in the **mid-2000s**, including the **Los Angeles Dodgers (LAN)** and **New York Mets (NYN)** in **2005**, and the **Atlanta Braves (ATL)** in **2005**.  
   - This period coincides with significant growth in MLB revenues and player salaries.

3. **Recent Milestones**:  
   - The **Milwaukee Brewers (MIL)** were among the last teams to surpass $1 billion, reaching this milestone in **2014**.  
   - The **Los Angeles Angels (LAA)** crossed $1 billion in **2013**, reflecting their increased spending in recent years.

![Top Paying Roles](/readm.pic/Screenshot%202025-02-03%20001035.png)

### Key Takeaway:
The data highlights the **financial evolution** of MLB teams, with large-market teams like the Yankees and Red Sox leading the way in cumulative spending. Smaller-market teams and expansion franchises reached the $1 billion milestone later, reflecting differences in revenue streams and spending strategies.

## PART III:  PLAYER CAREER ANALYSIS

Here, we’ll dive into player careers, calculating career lengths, identifying teams played for, and analyzing player loyalty.

### Insights from the Query: **calculating the starting age, ending age, and career length for each player.

```sql
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
```

This project analyzes player career statistics by calculating the starting age, ending age, and career length for each player. The dataset has been sorted from the longest to the shortest career span.

## Key Insights
- **Longest Career**: The player with the longest career is **Nicholas**, with a career spanning **35 years** (starting at age **21** and ending at age **57**).
- **Top 3 Longest Careers**:
  1. **Nicholas** - 35 years (21 to 57)
  2. **James Henry** - 32 years (21 to 54)
  3. **Saturnino Orestes Armas** - 31 years (23 to 54)
- **Notable Career Trends**:
  - Several players had careers spanning **20+ years**.
  - The shortest careers in the dataset lasted **17 years**.
  - The average starting age is **around 20-25 years**.

### Insights from the Query: ** Player's Starting and Ending Teams.

```sql
SELECT p.nameGiven,
        sd.yearid AS starting_year, sd.teamid AS starting_team, 
        sf.yearid AS ending_year, sf.teamid AS ending_team

FROM players AS p INNER join salaries AS sd 
     ON p.playerid = sd.playerid
     AND EXTRACT(YEAR FROM p.debut) = sd.yearid
     
     INNER JOIN salaries AS sf 
     ON p.playerid = sf.playerid
     AND EXTRACT (YEAR FROM p.finalGame) = sf.yearid;
```

- **Most Players Stayed with the Same Team** – A significant number of players started and ended their careers with the same team.
- **Frequent Team Switches** – Some players, like *Jeffrey Joseph*, started with *TOR* and ended with *NYN*, showing career mobility.
- **Popular Teams for Longevity** – Teams like *ATL*, *BOS*, and *NYN* had multiple players finishing their careers there.
- **Shortest Careers** – Players like *Robert Clifford* and *Joseph Michael* had careers lasting only one year (1986).
- **Longest Careers** – Players such as *James Cory* (1986–1994) and *Mariano* (1985–1997) had long tenures, often spanning different teams.

## PART IV: PLAYER COMPARISON ANALYSIS

This section focuses on comparing players, analyzing trends in height and weight, and creating summary tables for team statistics.

### Insights from the Query: ** Percentage of Players Batting Right, Left, and Both by Team.

```sql
SELECT  s.teamid,

      ROUND(SUM(CASE WHEN p.bats = 'R' THEN 1.0 ELSE 0.0 END) / NULLIF(COUNT(s.playerid),0) * 100, 1) AS right_bats,
     ROUND(SUM(CASE WHEN p.bats = 'L' THEN 1.0 ELSE 0.0 END) / NULLIF(COUNT(s.playerid),0) * 100,1) AS left_bats,
      ROUND(SUM(CASE WHEN p.bats = 'B' THEN 1.0 ELSE 0.0 END) / NULLIF(COUNT(s.playerid),0) * 100,1) AS Both_bats

From players AS p LEFT JOIN salaries AS s
     ON p.playerid = s.playerid
WHERE s.teamid IS NOT NULL

GROUP BY teamid
```
This query calculates the percentage of players on each team who bat right-handed (R), left-handed (L), or switch-hit (B).

### Key Takeaways:
- **Right-handed batters dominate** across all teams, reflecting the natural distribution  of handedness in the population.

- Teams with higher percentages of **left-handed batters** (e.g., CHA, PHI) may have a strategic advantage against right-handed pitchers.

- **Switch-hitters** are less common but provide valuable versatility, with the San Francisco Giants (SFG) leading in this category.

- The **Los Angeles Angels (LAA)** stand out with the highest percentage of right-handed batters and the lowest percentage of left-handed batters.



### Insights from the Query: **  Analysis of Average Height and Weight at Debut Game Over the Years.

```sql
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
```

This analysis examines how the average height and weight of players at their debut game have changed over the decades. 

**Key Findings:**

* Consistent increase in average player height over time.
* Significant increase in average weight in recent decades, with notable jumps in the 1990s-2000s and 2000s-2010s.
* Decade-over-decade differences in height and weight vary significantly.



### Baseball Player Height and Weight Decade Trends
![HEIGHT AND WEIGHT OVER decade](/readm.pic/baseball_height_weight.png)

**Possible Explanations:**

* Improved nutrition and healthcare.
* Advancements in training and sports science.
* Evolution of playing styles.

## What I Learned

Throughout this project, I have deepened my understanding of advanced SQL techniques, including:

- **Complex Joins**: Mastered the use of various join types to combine data from multiple tables effectively.

- **Subqueries**: Gained proficiency in writing subqueries to perform nested queries and enhance data retrieval processes.

- **Window Functions**: Learned to utilize window functions for performing calculations across sets of table rows related to the current row.

- **Common Table Expressions (CTEs)**: Developed skills in using CTEs to write more readable and maintainable queries.

- **Performance Optimization**: Acquired techniques to optimize query performance, ensuring efficient data retrieval and manipulation.

These skills were applied in a hands-on project, allowing me to solve real-world data challenges and demonstrate advanced data analysis and reporting capabilities.


