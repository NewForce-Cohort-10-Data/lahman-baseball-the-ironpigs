-- 1. What range of years for baseball games played does the provided database cover?

SELECT MIN(yearid), MAX(yearid)
FROM appearances;  

(select distinct yearid::int
from collegeplaying)
union
(select distinct left(finalgame,4)::int
from people)
order by yearid desc nulls last;
--isabelle pethtel

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT namefirst, namelast, G_all, name, 
	   MIN(height)
FROM people
INNER JOIN appearances USING (playerid)
INNER JOIN teams USING (teamid)
GROUP BY namefirst, namelast, G_all, name
ORDER BY MIN(height)
LIMIT 1;

SELECT playerid, namegiven, g_all AS games_played, teamid, teams.name AS team
FROM appearances
INNER JOIN teams USING (teamid)
INNER JOIN people USING (playerid)
WHERE playerid = 'gaedeed01'
LIMIT 1;
--abi taylor
--ask about why it took no time at all to find the answer 
 
-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

WITH vand_players AS (
SELECT playerid, namefirst, namelast, schoolname
FROM people
INNER JOIN collegeplaying USING (playerid)
INNER JOIN schools USING (schoolid)
WHERE schoolname = 'Vanderbilt University'
GROUP BY playerid, namefirst, namelast, schoolname
)
SELECT DISTINCT playerid, salary::INT::MONEY
FROM salaries
INNER JOIN collegeplaying USING (playerid)
INNER JOIN vand_players USING (playerid)
GROUP BY playerid, namefirst, namelast, schoolname, salary 
ORDER BY salary DESC; 


select schoolname, namelast, namefirst, sum(salary)::int::money as total_salary
from collegeplaying
join schools
	using(schoolid)
join people
	using(playerid)
join salaries
	using(playerid)
where schoolname = 'Vanderbilt University'
group by schoolname, namelast, namefirst
order by total_salary desc;
--ISABELLE 

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.






-- Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?