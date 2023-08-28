select * from athlete_events;
select * from athletes;
/*`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
EXTRA - which sport has won the maximum gold medals in each year.
`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````*/
WITH cte1 AS
(SELECT sport,year, SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS no_of_gold_medals FROM athlete_events
GROUP BY year,sport),
cte2 AS
(SELECT *, Rank() OVER(PARTITION BY year ORDER BY no_of_gold_medals DESC) AS rnk FROM cte1)

SELECT sport,year,no_of_gold_medals FROM cte2 WHERE rnk = 1 ;

/*`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
--1 which team has won the maximum gold medals over the years.
`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````*/

SELECT TOP 1 a.team,COUNT(DISTINCT event) AS cnt FROM athlete_events ae
INNER JOIN athletes a ON ae.athlete_id=a.id
WHERE medal = 'Gold'
GROUP BY a.team
ORDER BY cnt DESC ;

/*`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns => 
team,total_silver_medals, year_of_max_silver
`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````*/
WITH cte1 AS 
(SELECT a.team,ae.year, COUNT(DISTINCT event) AS silver_medals FROM athlete_events ae
INNER JOIN athletes a ON ae.athlete_id=a.id
WHERE medal = 'Silver'
GROUP BY a.team, ae.year),
cte2 AS
(SELECT *, RANK() OVER(PARTITION BY team ORDER BY silver_medals DESC) as rnk FROM cte1)

SELECT team,SUM(silver_medals) AS total_silver_medals,MAX(CASE WHEN rnk = 1 THEN year END) AS year FROM cte2
GROUP BY team;
/*`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
--3 which player has won maximum gold medals  amongst the players 
    which have won only gold medal (never won silver or bronze) over the years
`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````*/

select * from athlete_events;
select * from athletes;


WITH cte AS
(SELECT name, medal 
FROM athlete_events ae 
INNER JOIN athletes a ON a.id = ae.athlete_id)

SELECT TOP 1  name, COUNT(1) AS gold_medals 
FROM cte
WHERE medal = 'Gold' and name NOT IN (SELECT name FROM cte WHERE medal IN ('Silver','Bronze'))
GROUP BY name
ORDER BY gold_medals DESC;
/*`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
    and no of golds won in that year . In case of a tie print comma separated player names.
`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````*/

select * from athlete_events;
select * from athletes;

WITH cte1 AS
(SELECT name,year, medal 
FROM athlete_events ae 
INNER JOIN athletes a ON a.id = ae.athlete_id),

cte2 AS 
(SELECT name,year, COUNT(1) AS gold_medals 
FROM cte1
where medal = 'Gold'
GROUP BY name,year), 
cte3 AS
(SELECT * , RANK() OVER(PARTITION BY year ORDER BY gold_medals DESC) as rnk FROM cte2)

SELECT STRING_AGG(name, ',') AS players ,year,gold_medals FROM cte3 WHERE rnk = 1
GROUP BY gold_medals, year;

/*`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
    print 3 columns medal,year,sport
`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````*/
select * from athlete_events;
select * from athletes;
WITH cte1 AS
(SELECT ae.*, a.* 
FROM athlete_events ae 
INNER JOIN athletes a ON a.id = ae.athlete_id),
cte2 AS
(SELECT medal,year,event,RANK() OVER(partition by medal ORDER BY year)  AS rnk FROM cte1 
WHERE team = 'India' and medal != 'NA')
SELECT DISTINCT *  from CTE2 
WHERE rnk = 1;

/*`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
--6 find players who won gold medal in summer and winter olympics both.
`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````*/

select * from athlete_events;
select * from athletes;
--Solution-1 => ---------------------------------------------------------
WITH cte1 AS
(SELECT ae.*, a.* 
FROM athlete_events ae 
INNER JOIN athletes a ON a.id = ae.athlete_id),
cte2 AS
(SELECT name, season FROM cte1 
WHERE medal = 'Gold' AND season ='Summer'),
cte3 AS
(SELECT name, season FROM cte1 
WHERE medal = 'Gold' AND season ='Winter')

SELECT DISTINCT cte2.name 
FROM cte2 
INNER JOIN cte3 ON cte2.name = cte3.name ;

--Solution-2 => ---------------------------------------------------------

SELECT a.name 
FROM athlete_events ae 
INNER JOIN athletes a on a.id = ae.athlete_id
WHERE MEDAL = 'Gold'
GROUP BY a.name
HAVING COUNT(DISTINCT season) = 2
/*`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````*/
SELECT a.name, ae.year
FROM athlete_events ae 
INNER JOIN athletes a on a.id = ae.athlete_id 
WHERE medal != 'NA'
GROUP BY name,year
HAVING COUNT(DISTINCT medal) = 3;
/*`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
    Assume summer olympics happens every 4 year starting 2000. print player name and event name.
`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````*/
WITH cte1 AS
(SELECT a.name,ae.event,ae.year
FROM athlete_events ae 
INNER JOIN athletes a on a.id = ae.athlete_id 
WHERE medal = 'Gold' AND year >= 2000 AND season = 'Summer'
GROUP BY a.name,ae.event,ae.year)
SELECT * FROM
(select *, lag(year,1) over(partition by name,event order by year ) as prev_year
, lead(year,1) over(partition by name,event order by year ) as next_year
from cte1) a
WHERE year=prev_year+4 and year=next_year-4
