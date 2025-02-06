-- 1. What range of years for baseball games played does the provided database cover?
-- (select distinct yearid::int
-- from collegeplaying)
-- union
-- (select distinct left(finalgame,4)::int
-- from people)
-- order by yearid desc nulls last;
--1864-2017

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
-- select namelast, namefirst, height, g_all, name
-- from people
-- join appearances
-- 	using(playerid)
-- join teams
-- 	using(teamid)
-- Where height = (select min(height)
-- 				from people)
-- group by namelast, namefirst, height, g_all, name;
-- Eddie Gaedel, 43 inches tall, 7975 games for St. Louis Browns.


--abbi's query
-- SELECT playerid, namegiven, g_all AS games_played, teamid, teams.name AS team
-- FROM appearances
-- INNER JOIN teams USING (teamid)
-- INNER JOIN people USING (playerid)
-- WHERE playerid = 'gaedeed01'
-- LIMIT 1;



-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
-- select schoolname, namelast, namefirst, sum(salary)::int::money as total_salary
-- from collegeplaying
-- join schools
-- 	using(schoolid)
-- join people
-- 	using(playerid)
-- join salaries
-- 	using(playerid)
-- where schoolname = 'Vanderbilt University'
-- group by schoolname, namelast, namefirst
-- order by total_salary desc;
-- David Price earned the most at $245,553,888.00


-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
-- select
-- 	case
-- 		when pos = 'OF' then 'Outfield'
-- 		when pos = 'SS' or pos = '1B' or pos = '2B' or pos = '3B' then 'Infield'
-- 		when pos = 'P' or pos = 'C' then 'Battery'
-- 	end as position,
-- 	sum(po) as total_putouts
-- from fielding
-- where yearid = 2016
-- group by position;
-- 41424 for Battery, 58934 for Infield, 29560 for Outfield

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
-- select g,
-- 	case
-- 		when yearid between 1920 and 1929 then avg(so)
-- 		when yearid between 1930 and 1939 then avg(so)
-- 		when yearid between 1940 and 1949 then avg(so)
-- 		when yearid between 1950 and 1959 then avg(so)
-- 		when yearid between 1960 and 1969 then avg(so)
-- 		when yearid between 1970 and 1979 then avg(so)
-- 		when yearid between 1980 and 1989 then avg(so)
-- 		when yearid between 1990 and 1999 then avg(so)
-- 		when yearid between 2000 and 2009 then avg(so)
-- 		when yearid between 2010 and 2019 then avg(so)
-- 	end as decade_avg
-- from batting
-- group by g, yearid;

-- select 
-- 		avg(case when yearid between 1920 and 1929 then so end) as twenties,
-- 		avg(case when yearid between 1930 and 1939 then so end) as thirties
-- 		-- when yearid between 1940 and 1949 then avg(so)
-- 		-- when yearid between 1950 and 1959 then avg(so)
-- 		-- when yearid between 1960 and 1969 then avg(so)
-- 		-- when yearid between 1970 and 1979 then avg(so)
-- 		-- when yearid between 1980 and 1989 then avg(so)
-- 		-- when yearid between 1990 and 1999 then avg(so)
-- 		-- when yearid between 2000 and 2009 then avg(so)
-- 		-- when yearid between 2010 and 2019 then avg(so)
-- from batting
-- group by yearid;

-- select avg(so) over(
-- 	partition by g
-- 	order by year
-- 	rows
-- )

-- Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

-- From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

-- Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

-- Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.