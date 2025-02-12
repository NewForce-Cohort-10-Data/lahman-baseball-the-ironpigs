SELECT *
FROM people;

SELECT *
FROM schools;

SELECT *
FROM fielding;

SELECT *
FROM homegames;

SELECT *
FROM teams;

SELECT *
FROM parks;

SELECT *
FROM battingpost

-- 1. What range of years for baseball games played does the provided database cover?

SELECT MAX(yearid), MIN(yearid)
FROM appearances;

-- 2. Find the name and height of the shortest player in the database. How many games did he play in?
-- What is the name of the team for which he played?

SELECT *
FROM people
ORDER BY height ASC NULLS LAST
LIMIT 1;

SELECT *
FROM appearances
WHERE playerid = 'gaedeed01';

SELECT playerid, namegiven, g_all AS games_played, teamid, teams.name AS team
FROM appearances
INNER JOIN teams USING (teamid)
INNER JOIN people USING (playerid)
WHERE playerid = 'gaedeed01'
LIMIT 1;

-- 3. Find all players in the database who played at Vanderbilt University. 
-- Create a list showing each player’s first and last names as well as the total salary they earned 
-- in the major leagues. Sort this list in descending order by the total salary earned. 
-- Which Vanderbilt player earned the most money in the majors?

SELECT *
FROM schools
WHERE schoolname = 'Vanderbilt University';

SELECT DISTINCT namefirst, namelast
FROM collegeplaying
INNER JOIN people USING (playerid)
WHERE schoolid = 'vandy';

SELECT DISTINCT namefirst, namelast, SUM(salary)::INT::MONEY AS total_salary
FROM collegeplaying
INNER JOIN people USING (playerid)
INNER JOIN salaries USING (playerid)
WHERE schoolid = 'vandy'
GROUP BY namefirst, namelast
ORDER BY SUM(salary)::INT::MONEY DESC;

-- 4. Using the fielding table, group players into three groups based on their position: 
-- label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield",
-- and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of 
-- these three groups in 2016.

SELECT SUM(po) AS total_po_2016,
	CASE
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
		END AS position
FROM fielding
WHERE yearid = '2016'
GROUP BY position;

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report
-- to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT
    FLOOR(yearid / 10) * 10 AS decade,
    ROUND(SUM(so) * 1.0 / SUM(g), 2) AS strikeout_avg,
    ROUND(SUM(hr) * 1.0 / SUM(g), 2) AS home_run_avg
FROM batting
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;

--strikeouts and homerun averages overall increased through the decades 


-- 6. Find the player who had the most success stealing bases in 2016, where success is measured as the
-- percentage of stolen base attempts which are successful. (A stolen base attempt results either in a 
-- stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

SELECT playerid, namegiven, ROUND(((SUM(sb) * 1.0)/(SUM(sb) + SUM(cs))) * 100, 2) AS percent_stolen
FROM batting
INNER JOIN people USING (playerid)
WHERE yearid = 2016  
GROUP BY playerid, namegiven
HAVING (sum(sb) + sum(cs)) >= 20
ORDER BY percent_stolen DESC;

--Tarik
SELECT playerid, yearid, sb, cs,
	   ROUND( sb * 1.0 / (sb + cs), 2) AS attempts
FROM batting
WHERE sb >= 20 AND yearid = 2016
ORDER BY attempts DESC;

--isabelle
with total as(
	select playerid, yearid, (sum(sb) + sum(cs)) as total_percent
	from batting
	where yearid = 2016
	group by playerid, yearid
	order by playerid)
select namelast, namefirst, batting.yearid, round((sum(sb) / sum(total_percent)),2) as percent_stolen
from batting
join total
	using(playerid)
join people
	using(playerid)
where total_percent > 20
	and batting.yearid = 2016
group by namelast, namefirst, batting.yearid
order by percent_stolen desc;

-- 7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
-- What is the smallest number of wins for a team that did win the world series? Doing this will probably 
-- result in an unusually small number of wins for a world series champion – determine why this is the case.
-- Then redo your query, excluding the problem year. 

SELECT name, yearid, w, wswin
FROM teams
WHERE yearid BETWEEN '1970' AND '2016' AND wswin = 'N'
GROUP BY name, yearid, w, wswin
ORDER BY w DESC;

SELECT name, yearid, w
FROM teams
WHERE yearid BETWEEN '1970' AND '2016' AND wswin = 'Y'
ORDER BY w ASC;

-- 1981 season was split in half due to a players strike resulting in the low number
-- of wins for the dodgers yet winning the world series

-- How often from 1970 – 2016 was it the case that a team with
-- the most wins also won the world series? What percentage of the time?

WITH max_wins AS 
(SELECT yearid, MAX(w) AS max_wins
FROM teams
WHERE yearid BETWEEN '1970' AND '2016' AND yearid <> '1981'
GROUP BY yearid)
SELECT teams.yearid, teams.name, teams.w, teams.wswin
FROM teams
JOIN max_wins
ON teams.yearid = max_wins.yearid AND teams.w = max_wins.max_wins
ORDER BY yearid DESC


WITH most_wins AS 
(SELECT name, yearid, w
FROM teams
WHERE yearid BETWEEN '1970' AND '2016' AND wswin = 'Y' AND yearid <> '1981'
ORDER BY w ASC)
SELECT 

--isabelle
with max_wins as (
	select yearid, max(w) as w
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

--isabelle
select teamid, yearid, wswin, w
from teams
where yearid between 1970 and 2016
	and wswin = 'N'
group by teamid, yearid, wswin, w
order by w desc;

-- tarik
select teamid, yearid, wswin, w,
		MAX(w) OVER () AS max_wins_n_ws,
		MIN(w) OVER (PARTITION BY wswin = 'Y') AS min_wins_y_ws
from teams
WHERE yearid between 1970 AND 2016
	AND wswin = 'N'
GROUP BY yearid, wswin, w, teamid
ORDER BY w DESC

select teamid, yearid, wswin, w,
		MAX(w) OVER (PARTITION BY wswin = 'N') AS max_wins_n_ws,
		MIN(w) OVER (PARTITION BY wswin = 'Y') AS min_wins_y_ws
from teams
WHERE yearid between 1970 AND 2016
GROUP BY yearid, wswin, w, teamid
ORDER BY w DESC

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 
-- average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games).
-- Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance.
-- Repeat for the lowest 5 average attendance.

SELECT homegames.team, teams.name, parks.park_name, SUM(homegames.attendance)/ SUM(homegames.games) AS avg_attendance
FROM homegames
INNER JOIN teams
ON homegames.team = teams.teamid
INNER JOIN parks ON homegames.park = parks.park
WHERE year = '2016' AND games >=10
GROUP BY parks.park, homegames.team, teams.name
ORDER BY avg_attendance DESC
LIMIT 5; 

SELECT homegames.team, teams.name, parks.park_name, SUM(homegames.attendance)/ SUM(homegames.games) AS avg_attendance
FROM homegames
INNER JOIN teams
ON homegames.team = teams.teamid
INNER JOIN parks ON homegames.park = parks.park
WHERE year = '2016' AND games >=10
GROUP BY parks.park, homegames.team, teams.name
ORDER BY avg_attendance ASC
LIMIT 5;

--isabelle
select teams.name, park_name, sum(hg.attendance) / sum(hg.games)  as avg_attn
from homegames as hg
join teams
	on hg.team = teams.teamid
join parks
	on hg.park = parks.park
where year = 2016
	and (select sum(games)
		from homegames) > 10
group by teams.name, park_name
order by avg_attn desc
limit 5;

--tarik
SELECT team, park, park_name,
		attendance / games  AS avg_attendance
FROM homegames
INNER JOIN parks USING (park)
WHERE year = 2016 AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the 
-- American League (AL)? Give their full name and the teams that they were managing when they won the award.

WITH managers_al_nl AS ((
SELECT playerid, awardid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year' AND lgid = 'AL')
INTERSECT
(SELECT playerid, awardid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'NL'))
SELECT namefirst, namelast, teamid, yearid, awardid, lgid
FROM people
JOIN managers_al_nl USING (playerid)
JOIN managers USING (playerid)

--isabelle
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

-- 10. Find all players who hit their career highest number of home runs in 2016.
-- Consider only players who have played in the league for at least 10 years, and who hit at least 
-- one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

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

--isabelle
with homeruns as (
	select playerid, max(hr) as hr, yearid
	from batting
	where hr >= 1
	group by playerid, yearid)
select namefirst, namelast, hrs.hr
from batting as b
join homeruns as hrs
	using(hr, playerid)
join people
	using(playerid)
where b.yearid = 2016
	and (left(coalesce(finalgame,2016::text),4)::numeric - left(debut,4)::numeric) >=10
group by namefirst, namelast, hrs.hr
order by hr desc;

--tarik
(SELECT playerid, namefirst, namelast, appearances.yearid, MAX(hr)
FROM batting
INNER JOIN people USING(playerid)
INNER JOIN appearances USING (playerid)
WHERE (left(coalesce(finalgame,2016::text),4)::numeric - left(debut,4)::numeric) >=10
GROUP BY playerid, namefirst, namelast, appearances.yearid, hr
ORDER BY hr DESC)
--most homeruns where year is greater than or = 2006
INTERSECT  --?
(SELECT playerid, namefirst, namelast, yearid, hr
FROM batting
INNER JOIN people USING(playerid)
WHERE yearid = 2016 AND hr >= 1);


-- Is there any correlation between number of wins and team salary? 
-- Use data from 2000 and later to answer this question. As you do this analysis, 
-- keep in mind that salaries across the whole league tend to increase together, 
-- so you may want to look on a year-by-year basis.

SELECT *
FROM salaries

SELECT teams.yearid, teams.teamid, teams.name, SUM(salaries.salary), teams.w
FROM salaries
JOIN teams ON salaries.teamid = teams.teamid AND salaries.yearid = teams.yearid
WHERE teams.yearid >= 2000
GROUP BY teams.yearid, teams.teamid, teams.name, teams.w

-- In this question, you will explore the connection between number of wins and attendance.

-- Does there appear to be any correlation between attendance at home games and number of wins?
-- Do teams that win the world series see a boost in attendance the following year?
-- What about teams that made the playoffs? Making the playoffs means either being a division
-- winner or a wild card winner.

SELECT name, teamid, attendance, w, wswin, yearid
FROM teams
WHERE attendance IS NOT NULL AND name = 'Philadelphia Phillies'

SELECT name, teamid, attendance, w, wswin, yearid
FROM teams
WHERE attendance IS NOT NULL AND teamid = 'NYA'

SELECT name, teamid, attendance, w, wswin,  divwin, wcwin, yearid
FROM teams
WHERE attendance IS NOT NULL AND teamid = 'CIN'

-- It is thought that since left-handed pitchers are 
-- more rare, causing batters to face them less often, that they are more effective. 
-- Investigate this claim and present evidence to either support or dispute this claim. 
-- First, determine just how rare left-handed pitchers are compared with right-handed pitchers.
-- Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to
-- make it into the hall of fame?

SELECT throws,
	COUNT(CASE WHEN throws = 'L' THEN 1 END) AS left_players,
	COUNT(CASE WHEN throws = 'R' THEN 1 END) AS right_players
FROM people
GROUP BY throws

-- 20% left handed throws
-- 80% right handed

SELECT playerid, namegiven, throws
FROM people
WHERE throws = 'L'