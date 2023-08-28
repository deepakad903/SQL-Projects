

----------------------------------------------------------------------------------------------------------------------------------------------
--1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 
----------------------------------------------------------------------------------------------------------------------------------------------
WITH cte1 AS
(SELECT city, SUM(amount) AS city_wise_spend 
FROM credit_card_transactions 
GROUP BY city),
cte2 AS (SELECT SUM(CAST(amount as bigint)) AS total_spend FROM credit_card_transactions)

SELECT TOP 5 *, ROUND(city_wise_spend*100.0/cte2.total_spend,2) AS precentage_contribution FROM cte1 
INNER JOIN cte2 ON 1=1
ORDER BY city_wise_spend DESC 
;

----------------------------------------------------------------------------------------------------------------------------------------------
--2- write a query to print "highest spend month and amount spent in that month" for each card type
----------------------------------------------------------------------------------------------------------------------------------------------
Select * FROM credit_card_transactions;
WITH cte1 AS
(SELECT card_type, DATEPART(year, transaction_date) AS year , DATEPART(MONTH, transaction_date) AS month, SUM(amount) AS total_spent
FROM credit_card_transactions 
GROUP BY card_type,DATEPART(year, transaction_date),DATEPART(MONTH, transaction_date))


SELECT * FROM (SELECT *,RANK() OVER(PARTITION BY card_type ORDER BY total_spent DESC) AS rnk FROM cte1 ) a
WHERE rnk =1 ;
-----------------------------------------------------------------------------------------------------------------------------------------
--Extra Question : write a query to print total_spent of each card, for the month which has maximum total spent in each year 

-----------------------------------------------------------------------------------------------------------------------------------------
WITH cte1 AS
(SELECT  DATEPART(year, transaction_date) AS year , DATEPART(MONTH, transaction_date) AS month, SUM(amount) AS total_spent
FROM credit_card_transactions 
GROUP BY DATEPART(year, transaction_date),DATEPART(MONTH, transaction_date)),
cte2 AS
(SELECT *,RANK() OVER(PARTITION BY year ORDER BY total_spent DESC) AS month_wise_rank FROM cte1),
cte3 AS
(SELECT * FROM cte2 where month_wise_rank = 1),
cte4 AS
(SELECT card_type, DATEPART(year, transaction_date) AS year , DATEPART(MONTH, transaction_date) AS month, SUM(amount) AS total_spent
FROM credit_card_transactions 
GROUP BY card_type, DATEPART(year, transaction_date),DATEPART(MONTH, transaction_date))

SELECT cte4.* FROM cte4 INNER JOIN cte3 ON cte4.year = cte3.year and cte4.month = cte3.month
ORDER BY year,total_spent;

/*-----------------------------------------------------------------------------------------------------------------------------------------
3- write a query to print the transaction details(all columns from the table) for each card type when
it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
-----------------------------------------------------------------------------------------------------------------------------------------*/

SELECT * FROM credit_card_transactions;
WITH cte1 AS
(SELECT *,SUM(CAST(amount AS bigint)) OVER(PARTITION BY  card_type ORDER BY transaction_date,transaction_id ) AS running_sum_card_wise  
FROM credit_card_transactions)

SELECT * FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY card_type ORDER BY transaction_date,transaction_id) AS row_num FROM cte1 
WHERE running_sum_card_wise > 1000000) cte2 
WHERE row_num = 1;

/*-----------------------------------------------------------------------------------------------------------------------------------------
Extra Question - write a query to print the transaction details(contribution of each card) when
total sum of all the cards reaches 10000000 total spends(We should have 4 rows in the o/p one for each card type)
-----------------------------------------------------------------------------------------------------------------------------------------*/

WITH cte1 AS 
(SELECT *,
SUM(CAST(amount AS bigint)) OVER(ORDER BY transaction_date,transaction_id) AS running_sum
FROM credit_card_transactions ),
cte2 AS 
(SELECT * FROM (SELECT *, ROW_NUMBER() OVER(ORDER BY running_sum ASC) AS row_num FROM cte1 ) a )

SELECT card_type, SUM(CAST(amount AS bigint)) 
FROM cte2 
WHERE row_num <= (SELECT TOP 1 row_num FROM cte2 WHERE running_sum > 10000000)
GROUP BY card_type ;


/*-----------------------------------------------------------------------------------------------------------------------------------------
4- write a query to find city which had lowest percentage spend for gold card type
-----------------------------------------------------------------------------------------------------------------------------------------*/
SELECT * FROM credit_card_transactions;
WITH cte1 AS
(SELECT city, SUM(amount) AS total_spent, SUM(CASE WHEN card_type = 'Gold' THEN amount ELSE 0 END) AS gold_spent FROM credit_card_transactions 
GROUP BY city)
SELECT city, (gold_spent*100.0/total_spent) AS gold_percentage FROM cte1
GROUP BY city,gold_spent,total_spent
HAVING COUNT(gold_spent) > 0 AND SUM(gold_spent) > 0 
ORDER BY gold_percentage;
/*-----------------------------------------------------------------------------------------------------------------------------------------
5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
-----------------------------------------------------------------------------------------------------------------------------------------*/
 SELECT * FROM credit_card_transactions;
 WITH cte1 AS
( SELECT city,exp_type,SUM(amount) AS total_exp FROM credit_card_transactions
 GROUP BY city,exp_type),
 cte2 AS
 (SELECT *, RANK() OVER(PARTITION BY city ORDER BY total_exp DESC) AS rnk_desc, 
 RANK() OVER(PARTITION BY city ORDER BY total_exp ASC) AS rnk_asc
 FROM cte1)

 SELECT city, MAX(CASE WHEN rnk_desc = 1 THEN exp_type END) AS highest_expense_type, MIN(CASE WHEN rnk_asc = 1 THEN exp_type END) AS lowest_exp_type
 FROM cte2 
 GROUP BY city;
/*-----------------------------------------------------------------------------------------------------------------------------------------
6- write a query to find percentage contribution of spends by females for each expense type
-----------------------------------------------------------------------------------------------------------------------------------------*/

WITH cte1 AS 
(SELECT exp_type,SUM(amount) AS total_spent,SUM(CASE WHEN gender = 'F' THEN amount ELSE 0 END) AS female_spent FROM credit_card_transactions
GROUP BY exp_type)

SELECT exp_type, ROUND(female_spent*100.0/total_spent,2) AS female_precentage_contribution FROM cte1
ORDER BY female_precentage_contribution DESC;
/*-----------------------------------------------------------------------------------------------------------------------------------------
7- which card and expense type combination saw highest month over month growth in Jan-2014
-----------------------------------------------------------------------------------------------------------------------------------------*/
SELECT * FROM credit_card_transactions;
WITH cte1 AS 
(SELECT card_type,exp_type,DATEPART(year,transaction_date) AS year,DATEPART(month, transaction_date) AS month,
SUM(amount) AS total_spent 
FROM credit_card_transactions
GROUP BY card_type,exp_type,DATEPART(year,transaction_date),DATEPART(month, transaction_date)),
cte2 AS
(SELECT *, LAG(total_spent,1) OVER(PARTITION BY card_type,exp_type ORDER BY year,month) AS lag_salary FROM cte1)

SELECT TOP 1 *, (total_spent - lag_salary) AS growth 
--RANK() OVER(ORDER BY (total_spent - lag_salary)DESC) AS rnk 
FROM cte2
WHERE year = 2014 and month = 1
ORDER BY growth DESC;
/*-----------------------------------------------------------------------------------------------------------------------------------------
8- during weekends which city has highest total spend to total no of transcations ratio
-----------------------------------------------------------------------------------------------------------------------------------------*/
SELECT * FROM credit_card_transactions;

SELECT tOP 1 city, SUM(amount)*1.0/COUNT(1) AS ratio
FROM credit_card_transactions
--WHERE DATENAME(WEEKDAY, transaction_date) IN ('saturday', 'sunday')
WHERE datepart(weekday,transaction_date) in (1,7)
GROUP BY city
ORDER BY ratio DESC;

/*-----------------------------------------------------------------------------------------------------------------------------------------
9- which city took least number of days to reach its 500th transaction after the first transaction in that city;
-----------------------------------------------------------------------------------------------------------------------------------------*/
SELECT * FROM credit_card_transactions;
WITH cte1 AS
(SELECT *, ROW_NUMBER() OVER(PARTITION BY city ORDER BY transaction_date) AS row_num
FROM credit_card_transactions)

SELECT TOP 1 city, DATEDIFF(day,MIN(transaction_date), MAX(transaction_date)) AS num_of_days FROM  cte1
WHERE row_num = 1 or row_num = 500
GROUP BY city
HAVING COUNT(1) = 2
ORDER BY num_of_days
