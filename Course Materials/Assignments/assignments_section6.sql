-- Connect to database


-- ASSIGNMENT 1: Duplicate values

-- View the students data

SELECT * 
FROM students

-- Create a column that counts the number of times a student appears in the table

SELECT  student_name, COUNT(*) 
FROM students
GROUP BY  student_name

-- Return student ids, names and emails, excluding duplicates students

WITH clean_cte AS (SELECT  students.id, student_name,students.email,
                            ROW_NUMBER() OVER(PARTITION BY student_name ORDER BY id DESC) AS number_1
                    FROM students)

SELECT id, student_name, email
FROM clean_cte
WHERE number_1 = 1
ORDER by id



-- ASSIGNMENT 2: Min / max value filtering

-- View the students and student grades tables
 SELECT * from students
 SELECT * from student_grades

-- For each student, return the classes they took and their final grades

 SELECT S.id, student_name, sg.class_name, sg.final_grade
 
 from students AS s LEFT JOIN student_grades AS sg
               ON S.id = sg.student_id 

-- Return each student's top grade and corresponding class

 WITH st_cte AS (SELECT S.id, student_name, sg.class_name, sg.final_grade
                    
                    from students AS s LEFT JOIN student_grades AS sg
                                ON S.id = sg.student_id),
      sf_cte AS(SELECT *,
           Dense_rank() OVER(PARTITION BY id ORDER BY final_grade DESC) AS num

                    FROM st_cte
                    WHERE final_grade IS NOT NULL)

SELECT * 

FROM sf_cte 

WHERE num = 1 
                    
-- ASSIGNMENT 3: Pivoting

-- Combine the students and student grades tables
 SELECT S.grade_level,sg.department, sg.final_grade
 
 from students AS s LEFT JOIN student_grades AS sg
               ON S.id = sg.student_id 
        
-- View only the columns of interest

 SELECT S.grade_level,sg.department, sg.final_grade
 
 from students AS s LEFT JOIN student_grades AS sg
               ON S.id = sg.student_id 
        
-- Pivot the grade_level column

 SELECT S.grade_level, sg.department, sg.final_grade,

    CASE WHEN S.grade_level = 9 THEN sg.final_grade END AS freshman, 
    CASE WHEN S.grade_level = 10 THEN sg.final_grade END AS sophomore, 
    CASE WHEN S.grade_level = 11 THEN sg.final_grade END AS junior, 
    CASE WHEN S.grade_level = 12 THEN sg.final_grade END AS senior 

 from students AS s LEFT JOIN student_grades AS sg
               ON S.id = sg.student_id 
    
-- Update the values to be final grades

 SELECT sg.department,

   ROUND(AVG(CASE WHEN S.grade_level = 9 THEN sg.final_grade END)) AS freshman, 
   ROUND(AVG(CASE WHEN S.grade_level = 10 THEN sg.final_grade END)) AS sophomore, 
   ROUND(AVG(CASE WHEN S.grade_level = 11 THEN sg.final_grade END)) AS junior, 
   ROUND(AVG(CASE WHEN S.grade_level = 12 THEN sg.final_grade END)) AS senior 

FROM students AS s LEFT JOIN student_grades AS sg
               ON S.id = sg.student_id 

    WHERE sg.department IS NOT NULL
    GROUP BY sg.department
    ORDER BY sg.department

-- Create the final summary table


-- ASSIGNMENT 4: Rolling calculations



-- Calculate the total sales each month

SELECT 

    DATE_PART('year', o.order_date) AS year,
    DATE_PART('month', o.order_date) as month,
    SUM(o.units * p.unit_price) AS total_sale

FROM orders AS o LEFT JOIN products AS p 
    ON o.product_id = p.product_id

GROUP BY year, month
ORDER BY year, month


-- Add on the cumulative sum and 6 month moving average

WITH ts_cte AS (SELECT 

                    DATE_PART('year', o.order_date) AS year,
                    DATE_PART('month', o.order_date) as month,
                    SUM(o.units * p.unit_price) AS total_sale

                FROM orders AS o LEFT JOIN products AS p 
                    ON o.product_id = p.product_id
                    
                GROUP BY year, month
                ORDER BY year, month)

SELECT *,

        SUM(total_sale) OVER (ORDER BY year, month) AS cumulative_sales,
        (AVG(total_sale) OVER (ORDER BY year, month ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)) AS six_avg_sales
FROM ts_cte


