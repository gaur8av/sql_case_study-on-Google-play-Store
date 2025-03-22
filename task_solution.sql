SELECT * FROM campusx.playstore;
truncate campusx.playstore;


load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/playstore.csv"
into table campusx.playstore
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

use campusx;

/*   Task 1 : You're working as a market analyst for a mobile app development company.
	 Your task is to identify the most promising categories (TOP 5) for launching new free apps based on their average ratings. 
 */
 
 select Category , avg(rating) as 'avg_rateing' from playstore where type = 'Free'
 group by Category
 order by 'avg_rating' desc limit 5;
 
 /*
	 Task 2	: As a business strategist for a mobile app company, your objective is to pinpoint the three categories that
	 generate the most revenue from paid apps. This calculation is based on the product of the app price and its number
	 of installations.
 */
 
select * from playstore;
select Category , avg(Revenue) as 'avg_cat_rev' from(
	select * , (Price * Installs) as 'Revenue' from playstore where Price != 0
) t
group by Category
order by avg_cat_rev desc limit 3;

/*
	Task 3 : As a data analyst for  company, you're tasked with calculating the percentage of app within each category.
	 This information will help the company understand the distribution of gaming apps across different categories.
*/

select * , (cnt / (select count(*) from playstore)) * 100 as 'percentage' from ( 
    select Category , count(App) as 'cnt' from playstore group by Category
) t order by percentage desc limit 3;

/*
	 Task 4 : As a data analyst at a mobile app-focused market research firm you’ll recommend whether the company should
	 develop paid or free apps for each category based on the ratings of that category.
*/

with t1 as
(
	select Category , Round(avg(Rating),2) as 'free_avg_rating' from playstore where Type = 'Free' group by Category
),
t2 as
(
    select Category , Round(avg(Rating),2) as 'paid_avg_rating' from playstore where Type = 'Paid' group by Category
)

select *, if (paid_avg_rating > free_avg_rating , 'Develop Paid App' , 'Develop Unpaid App') as 'Decision' from (
select a.Category , free_avg_rating , paid_avg_rating from t1 as a inner join t2 as b on a.Category = b.Category
) p;

/*
	  Task 5 : Suppose you're a database administrator your databases have been hacked and hackers are changing price of
	 certain apps on the database, it is taking long for IT team to neutralize the hack, however you as a 
	 responsible manager don’t want your data to be changed, do some measure where the changes in price can be
	 recorded as you can’t stop hackers from making changes.
*/
-- concept of trigger

-- create a backup table which trach the changes in play table
drop table if exists pricechangelog;
create table pricechangelog
(
  app varchar(255),
  old_price decimal(10,2),
  new_price decimal(10,2),
  operation_type varchar(255),
  operation_date timestamp
)

select * from pricechangelog;

-- copy of playstore table so changes does not reflect to original one
drop table if exists play;
create table play as
select * from playstore;

select * from play;

-- create a trigger , it will automatically work after update in price table

DELIMITER //

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


/*
	Task 6 : Your IT team have neutralized the threat; however, hackers have made some changes in the prices,
	 but because of your measure you have noted the changes, now you want correct data to be inserted into the database again.
*/
-- reverse trigger
-- new concept -> (update + join)

select * from play as a inner join pricechangelog as b on a.app = b.app;   -- step - 1.

drop trigger price_change_log;

update play as a 
inner join pricechangelog as b on a.app = b.app
set a.price = b.old_price;

select * from play where app='Sketch - Draw & Paint';

/*
	 Task 7 : As a data person you are assigned the task of investigating the correlation between two numeric factors:
	 app ratings and the quantity of reviews.
*/ 
/* things need for finding correlation
   1. x - x'    2. y - y'    3. (x - x')^2    4.(y - y')^2
*/

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
 
 /*
	 Task 8	: Your boss noticed  that some rows in genres columns have multiple genres in them, which was creating issue
	 when developing the  recommender system from the data he/she assigned you the task to clean the genres 
	 column and make two genres out of it, rows that have only one genre will have other column as blank.
 */
 
 select * from playstore;
 
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
 
 /*
	 Task 9	: Your senior manager wants to know which apps are not performing as par in their particular category,
	 however he is not interested in handling too many files or list for every  category and he/she assigned
	 you with a task of creating a dynamic tool where he/she  can input a category of apps he/she  interested 
	 in  and your tool then provides real-time feedback by displaying apps within that category that have ratings
	 lower than the average rating for that specific category.
 */
 
SELECT App, Category, Rating
FROM playstore
WHERE Category = 'GAME'
  AND Rating < (
    SELECT AVG(Rating)
    FROM playstore
    WHERE Category = 'GAME'
  )
ORDER BY Rating ASC;
 
 /*
 Task 10 : What is the difference between “Duration Time” and “Fetch Time.”
 */
 
 /*
     1. Duration Time (Execution Time):
		This is the total time taken by the database engine to execute the query — from parsing and planning,
		to running the SQL logic (e.g., filtering, joining, aggregating).

    2. Fetch Time:
        The time taken to retrieve all the rows from the result set — often seen when your query returns a lot of rows.

🧠 Simple Analogy:
	Let’s say your query is like placing an online pizza order:

	Duration Time: Time taken to prepare the pizza in the kitchen.
	Fetch Time: Time taken to deliver the pizza to your home and put it on your plate.

💡 Why It Matters:
		If Duration Time is high → your query logic or indexes might need optimization.
		If Fetch Time is high → maybe you're selecting too many rows/columns, or the client UI is slow in
 */
