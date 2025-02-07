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

-- 4.Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016
SELECT *
FROM fielding

SELECT
    CASE 
        WHEN pos = 'OF' THEN 'Outfield'
        WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
        WHEN pos IN ('P', 'C') THEN 'Battery'
    END AS position_group,
    SUM(po) AS total_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY position_group;

-- 5.Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT *
FROM batting

-- SELECT 
--     FLOOR(yearid / 10) * 10 AS decade,
--     ROUND(SUM(so) / SUM(g), 2) AS strikeout_avg,
--     ROUND(SUM(hr) / SUM(g), 2) AS home_run_avg
-- FROM batting
-- WHERE yearid >= 1920
-- GROUP BY decade
-- ORDER BY decade;
-- realized I need to *1.0 for it to not bring up all 0
SELECT 
    FLOOR(yearid / 10) * 10 AS decade,
    ROUND(SUM(so) * 1.0 / SUM(g), 2) AS strikeout_avg,
    ROUND(SUM(hr) * 1.0 / SUM(g), 2) AS home_run_avg
FROM batting
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;
-- Home runs per decade had an increase in 1950. Strikeout avg had an increase in 1960.

-- 6.Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
SELECT 
    p.namefirst || ' ' || p.namelast AS player,
    b.playerid,
    ROUND(1.0 * SUM(b.sb) / (SUM(b.sb) + SUM(b.cs)), 3) AS steal_rate,
    SUM(b.sb) + SUM(b.cs) AS total_attempts
FROM batting b
JOIN people p ON b.playerid = p.playerid
WHERE b.yearid = 2016
GROUP BY b.playerid, p.namefirst, p.namelast
HAVING SUM(b.sb) + SUM(b.cs) >= 20
ORDER BY steal_rate DESC
LIMIT 1;

-- ALL ON SAME TABLE
SELECT 
    playerid,
    ROUND(1.0 * SUM(sb) / (SUM(sb) + SUM(cs)), 3) AS steal_rate,
    SUM(sb) + SUM(cs) AS total_attempts
FROM batting
WHERE yearid = 2016
GROUP BY playerid
HAVING SUM(sb) + SUM(cs) >= 20
ORDER BY steal_rate DESC
LIMIT 1;

--7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
select teamid, yearid, wswin, sum(w) as wins
from teams
where yearid between 1970 and 2016
	and wswin = 'Y'
group by teamid, yearid, wswin
order by wins;

-- Smallest
SELECT MIN(w) AS smallest_wins_world_series_winner
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	and wswin = 'Y'

SELECT teamid, w AS smallest_wins
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND wswin = 'Y'
ORDER BY w ASC
LIMIT 1;


-- Largest  
SELECT MAX(w) AS largest_wins_world_series_winner
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	and wswin = 'N';

SELECT teamid, w AS smallest_wins
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND wswin = 'N'
ORDER BY w DESC
LIMIT 1;	

-- Isabelle
with max_wins as (
	select yearid,  max(w) as w
	from teams
	where yearid between 1970 and 2016
		and yearid != 1981
	group by yearid
)
select
	round(count(case when wswin = 'Y' then 'Keep' end)::numeric /
	count(distinct yearid)::numeric, 2) as percent_max_wins_ws
from teams
join max_wins as mw
	using(yearid, w);

SELECT 
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM teams WHERE yearid BETWEEN 1970 AND 2016)) AS win_percentage
FROM teams t
WHERE yearid BETWEEN 1970 AND 2016
AND EXISTS (
    SELECT 1
    FROM world_series ws
    WHERE ws.yearid = t.yearid
    AND ws.teamid = t.teamid
)
AND t.w = (
    SELECT MAX(w)
    FROM teams
    WHERE yearid = t.yearid
);

-- 8.Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
-- part 1
SELECT 
    park, 
    team, 
    ROUND(SUM(attendance) / SUM(games), 2) AS avg_attd
FROM homegames
WHERE year = 2016
GROUP BY park, team
HAVING SUM(games) >= 10
ORDER BY avg_attd DESC
LIMIT 5;

-- part 2
SELECT 
    park, 
    team, 
    ROUND(SUM(attendance) / SUM(games), 2) AS avg_attd
FROM homegames
WHERE year = 2016
GROUP BY park, team
HAVING SUM(games) >= 10
ORDER BY avg_attd ASC
LIMIT 5;

-- 9.Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
