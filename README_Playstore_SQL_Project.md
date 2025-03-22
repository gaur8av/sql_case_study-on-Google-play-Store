
# 📱 Play Store Data Analysis using SQL

## Project Overview

This project presents a detailed SQL-based analysis of Google Play Store data. It involves data cleaning, business analysis through SQL queries, implementation of triggers, and drawing insights that assist in product and market decisions.

![PlayStore](https://cdn-icons-png.flaticon.com/512/888/888857.png)

---

## Objectives

1. Clean and preprocess raw Play Store data.
2. Analyze business problems using SQL queries.
3. Implement SQL triggers and recovery solutions.
4. Build dynamic SQL tools for real-time analysis.
5. Deliver actionable insights for strategic decisions.

---

## Business Tasks & SQL Solutions

---

### 🧠 Task 1: Identify Top 5 Categories for Launching Free Apps

**Objective:** Based on average ratings, find the top categories for launching new free apps.

```sql
SELECT Category, AVG(Rating) AS avg_rating 
FROM playstore 
WHERE Type = 'Free' 
GROUP BY Category 
ORDER BY avg_rating DESC 
LIMIT 5;
```

---

### 💰 Task 2: Top 3 Revenue-Generating Categories from Paid Apps

**Objective:** Identify categories with the highest total revenue (Price × Installs).

```sql
select * from playstore;
select Category , avg(Revenue) as 'avg_cat_rev' from
(
	select * , (Price * Installs) as 'Revenue' from playstore where Price != 0
) t
group by Category
order by avg_cat_rev desc limit 3;
```

---

### 📊 Task 3: Calculate Percentage of Apps in Each Category

**Objective:** Understand category distribution for business decisions.

```sql
SELECT *, (cnt / (SELECT COUNT(*) FROM playstore)) * 100 AS percentage 
FROM (
    SELECT Category, COUNT(App) AS cnt 
    FROM playstore 
    GROUP BY Category
) t 
ORDER BY percentage DESC 
LIMIT 3;
```

---

### 📱 Task 4: Recommend Free or Paid App by Category Based on Ratings

**Objective:** Should the company launch free or paid apps per category?

```sql
WITH t1 AS (
    SELECT Category, ROUND(AVG(Rating), 2) AS free_avg_rating 
    FROM playstore 
    WHERE Type = 'Free' 
    GROUP BY Category
),
t2 AS (
    SELECT Category, ROUND(AVG(Rating), 2) AS paid_avg_rating 
    FROM playstore 
    WHERE Type = 'Paid' 
    GROUP BY Category
)
SELECT *, 
       IF(paid_avg_rating > free_avg_rating, 'Develop Paid App', 'Develop Unpaid App') AS Decision 
FROM (
    SELECT a.Category, free_avg_rating, paid_avg_rating 
    FROM t1 a 
    INNER JOIN t2 b 
    ON a.Category = b.Category
) p;
```

---

### 🔐 Task 5: Track Unauthorized Price Changes Using Triggers

**Objective:** Implement a trigger to monitor and log price changes.

```sql
CREATE TABLE pricechangelog (
  app VARCHAR(255),
  old_price DECIMAL(10,2),
  new_price DECIMAL(10,2),
  operation_type VARCHAR(255),
  operation_date TIMESTAMP
);

CREATE TRIGGER price_change_log
AFTER UPDATE
ON play
FOR EACH ROW
BEGIN
    INSERT INTO pricechangelog(app, old_price, new_price, operation_type, operation_date)
    VALUES (NEW.app, OLD.price, NEW.price, 'update', CURRENT_TIMESTAMP);
END;
//

DELIMITER ;


-- now we change in play table than see how trigger work
set sql_safe_updates = 0

UPDATE play
SET price = 4
WHERE app = 'Infinite Painter';

update play
set price = 5
where app = 'Sketch - Draw & Paint';

select * from pricechangelog;

```

---

### 🔁 Task 6: Restore Price After Hack from Logged Data

**Objective:** Use backup log table to restore original prices.
#### -- reverse trigger
#### -- new concept -> (update + join)


```sql
select * from play as a inner join pricechangelog as b on a.app = b.app;   -- step - 1.

drop trigger price_change_log;

update play as a 
inner join pricechangelog as b on a.app = b.app
set a.price = b.old_price;

select * from play where app='Sketch - Draw & Paint';
```

---

### 📈 Task 7: Correlation Between Ratings and Reviews

**Objective:** Explore if highly rated apps also have more reviews.

```sql
set @x = (select Round(avg(rating),2)  from playstore);
set @y = (select Round(avg(reviews),2)  from playstore);


WITH m AS (
	SELECT *, 
	       (rat * rat) AS 'sqrt_x',
	       (rev * rev) AS 'sqrt_y'
	FROM (
		SELECT rating, @x, ROUND((rating - @x), 2) AS 'rat',
		       reviews, @y, ROUND((reviews - @y), 2) AS 'rev' 
		FROM playstore
	) k
)

-- select * from m;

select @numerator := Round(sum((rat * rev)),2),
@deno_1 := Round(sum(sqrt_x),2) , @deno_2 := Round(sum(sqrt_y),2) from m;
select @numerator , @deno_1 , @deno_2;
 
 select Round(((@numerator) / (sqrt(@deno_1 * @deno_2))),2) as 'correlation_cofficient';
```

---

### 🧹 Task 8: Clean Genres Column (Split Multi-Genre)

**Objective:** Split genres like "Action;Adventure" into two separate columns.

```sql
DELIMITER //
 create function f_name(a varchar(200))
 returns varchar(200)
 deterministic
 begin
     set @l = locate(';' , a);
     set @s = if(@l > 0 , left(a , @l - 1) , a);
     
     return @s;
 
 end; //
 DELIMITER ;
 
DELIMITER //
 create function l_name(a varchar(200))
 returns varchar(200)
 deterministic
 begin
     set @l = locate(';' , a);
     set @s = if(@l = 0 ,' ', substr(a , @l + 1 , length(a)));
     
     return @s;
 
 end; //
 DELIMITER ;
 
 select genres , f_name(genres) as 'first_name' , l_name(genres) as 'last_name' from playstore;
```

---

### 🔎 Task 9: Dynamic Tool to Find Underperforming Apps by Category

**Objective:** Create a query to fetch apps with ratings below average for a given category.

```sql
SELECT App, Category, Rating
FROM playstore
WHERE Category = 'GAME'
  AND Rating < (
    SELECT AVG(Rating)
    FROM playstore
    WHERE Category = 'GAME'
  )
ORDER BY Rating ASC;
```

---

### 🧠 Task 10: Explain Duration Time vs Fetch Time

**Duration Time:** Total time taken to complete the SQL query execution.

**Fetch Time:** Time taken to return data from buffer/cache to the client.

---

## 📁 Files in the Repository

| File Name | Description |
|-----------|-------------|
| `playstore.csv` | Cleaned dataset of Play Store apps |
| `task_solution.sql` | SQL queries and triggers |
| `Questions.docx` | Business problem statements |
| `README.md` | Project documentation |

---

## 🚀 How to Use

1. Clone the repository:
   ```bash
   git clone https://github.com/gaur8av/playstore-sql-analysis.git
   ```

2. Load `playstore.csv` into MySQL/PostgreSQL DB.

3. Run `task_solution.sql` queries to explore data and solve business problems.

---

## 📬 Contact

- [LinkedIn](https://www.linkedin.com/in/gauravjangid07/)
- [GitHub](https://github.com/gaur8av)

---

⭐ Star this repo if you found it useful!
