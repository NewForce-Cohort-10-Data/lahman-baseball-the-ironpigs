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

-- To show height
SELECT pe.namefirst, pe.namelast, pe.height, a.g_all AS games_played, t.name AS team
FROM people pe
INNER JOIN appearances a ON pe.playerid = a.playerid
INNER JOIN teams t ON a.teamid = t.teamid
WHERE pe.height = (SELECT MIN(height) FROM people)
LIMIT 1;


-- 3.Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT schoolname, namelast, namefirst, SUM(salary)::int::money as total_salary
FROM collegeplaying
JOIN schools
	USING(schoolid)
JOIN people
	USING(playerid)
JOIN salaries
	USING(playerid)
WHERE schoolname = 'Vanderbilt University'
GROUP BY schoolname, namelast, namefirst
ORDER BY total_salary DESC;

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

-- only returning 47 rows when it should be 50. It was missing having
SELECT playerid, yearid, sb, cs,
    sb * 1.0 / (sb + cs) AS attempts
FROM batting
WHERE (sb + cs) >= 20 
    AND yearid = 2016
GROUP BY playerid, yearid, sb, cs
ORDER BY attempts DESC;


SELECT 
    playerid,
    ROUND(1.0 * SUM(sb) / (SUM(sb) + SUM(cs)), 3) AS steal_rate,
    SUM(sb) + SUM(cs) 
FROM batting
WHERE yearid = 2016
GROUP BY playerid
HAVING SUM(sb) + SUM(cs) >= 20
ORDER BY steal_rate DESC


--7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
select teamid, yearid, wswin, sum(w) as wins
from teams
where yearid between 1970 and 2016
	and wswin = 'Y'
group by teamid, yearid, wswin
order by wins;

-- Isabelle
-- SELECT teamid, w AS smallest_wins
-- FROM teams
-- WHERE yearid BETWEEN 1970 AND 2016
-- AND wswin = 'Y'
-- ORDER BY w ASC
-- LIMIT 1;

-- Smallest
SELECT teamid, MIN(w) AS smallest
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
  AND wswin = 'Y'
GROUP BY teamid
ORDER BY smallest ASC;

-- Largest  
SELECT teamid, MAX(w) AS largest
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
  AND wswin = 'N'
GROUP BY teamid
ORDER BY largest DESC;

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


-- 8.Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
-- part 1
SELECT 
    park, 
    team, 
    SUM(attendance) / SUM(games) AS avg_attd
FROM homegames
WHERE year = 2016
GROUP BY team, park
HAVING SUM(games) >= 10
ORDER BY avg_attd DESC
LIMIT 5;

-- part 2
SELECT 
    park, 
    team, 
    SUM(attendance) / SUM(games) AS avg_attd
FROM homegames
WHERE year = 2016
GROUP BY park, team
HAVING SUM(games) >= 10
ORDER BY avg_attd ASC
LIMIT 5;

-- ISABELLE
select team, park, sum(hg.attendance) / sum(hg.games)  as avg_attn
from homegames as hg
where year = 2016
	and (select sum(games)
		from homegames) >= 10
group by team, park
order by avg_attn desc;


-- 9.Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
-- Isabelle
with nl_al_managers as (
	(select distinct playerid, awardid
	from awardsmanagers
	where awardid = 'TSN Manager of the Year'
		and lgid = 'NL')
	intersect
	(select distinct playerid, awardid
	from awardsmanagers
	where awardid = 'TSN Manager of the Year'
		and lgid = 'AL'))
select namelast, namefirst, teams.name, am.yearid, awardid, am.lgid
from awardsmanagers as am
join nl_al_managers as na
	using(playerid, awardid)
join people
	using(playerid)
join managers
	using(playerid, yearid)
join teams
	using(teamid, yearid);

-- 10.Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
WITH career_hr AS
(SELECT playerid, MAX(hr)
FROM batting
		GROUP BY playerid),
players2016 AS
(SELECT playerid, hr
FROM batting
		WHERE yearid = 2016 AND HR > 0),
years_played AS
(SELECT playerid, COUNT(DISTINCT yearid) AS years_played
FROM batting
GROUP BY playerid)
SELECT people.namefirst, people.namelast, batting.hr, years_played.years_played
FROM people
		JOIN batting USING (playerid)
		JOIN years_played USING (playerid)
		WHERE yearid = 2016 AND hr > 0 AND years_played >= 10
GROUP BY batting.playerid, people.namefirst, people.namelast, batting.hr, years_played.years_played
ORDER BY hr DESC;

-- 11.Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- Isabelle
-- select teamid, yearid, sum(salary)::numeric ::money as total_salary, w
-- from salaries
-- join teams
-- 	using(teamid, yearid)
-- where yearid >= 2000
-- group by teamid, yearid, w
-- having teamid = 'SFN'
-- order by yearid;

SELECT yearid, 
       teamid, 
       CAST(CAST(AVG(salary) AS numeric) AS money) AS avg_salary
FROM salaries
GROUP BY yearid, teamid
ORDER BY yearid;


SELECT sa.yearid, 
       sa.teamid, 
       CAST(CAST(AVG(sa.salary) AS numeric) AS money) AS avg_salary,
       te.w
FROM salaries sa
JOIN teams te ON sa.yearid = te.yearid AND sa.teamid = te.teamid
WHERE sa.yearid >= 2000
GROUP BY sa.yearid, sa.teamid, te.w
ORDER BY sa.yearid DESC; 