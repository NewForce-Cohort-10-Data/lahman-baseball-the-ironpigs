-- 1.What range of years for baseball games played does the provided database cover?
SELECT MIN (yearid), MAX(yearid)
FROM appearances;

Isabelle
(select distinct yearid::int
from collegeplaying)
union
(select distinct left(finalgame,4)::int
from people)
order by yearid desc nulls last;

-- 2.Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT playerid, namegiven, g_all AS games_played, teamid, teams.name AS team
FROM appearances
INNER JOIN teams USING (teamid)
INNER JOIN people USING (playerid)
WHERE playerid = 'gaedeed01'
LIMIT 1;

-- 3.Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
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

