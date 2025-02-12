-- 1. What range of years for baseball games played does the provided database cover?

SELECT MIN(yearid), MAX(yearid)
FROM collegeplaying;  

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
SELECT DISTINCT playerid, SUM(salary)::INT::MONEY as total_salary
FROM salaries
INNER JOIN collegeplaying USING (playerid)
INNER JOIN vand_players USING (playerid)
GROUP BY DISTINCT playerid, namefirst, namelast, schoolname, salary 
ORDER BY total_salary DESC; 


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
--ISABELLE p

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
		WHEN pos = 'P' or pos = 'C' THEN 'Battery' 
	END AS position,
	SUM(po) AS putouts
FROM fielding
WHERE yearid = 2016 
GROUP BY position 

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT *
FROM batting; 


SELECT
    FLOOR(yearid / 10) * 10 AS decade,
    ROUND(SUM(so) * 1.0 / SUM(g), 2) AS strikeout_avg,
    ROUND(SUM(hr) * 1.0 / SUM(g), 2) AS home_run_avg
FROM batting
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;



-- 6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.


SELECT playerid, namegiven, ROUND(((sum(sb) * 1.0)/(sum(sb) + sum(cs))) * 100, 2) AS percent_stolen
FROM batting
INNER JOIN people USING (playerid)
WHERE yearid = 2016
GROUP BY playerid, namegiven
HAVING (sum(sb) + sum(cs)) >= 20
ORDER BY percent_stolen DESC;
--need to work on percentage ? or is it right ? -- after talking with everyone looks good, you want to include names


SELECT playerid, yearid, sb, cs 
FROM batting
WHERE sb >= 20 AND yearid = 2016; 
--this is just to see what the sb and cs are 

SELECT playerid, namegiven, ROUND(((sb * 1.0)/(sb + cs)) * 100, 2) AS percent_stolen
FROM batting
INNER JOIN people USING (playerid)
WHERE yearid = '2016' AND (sb+cs) >= 20
GROUP BY playerid, sb, cs, namegiven
ORDER BY percent_stolen DESC;
--Abi

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
where total_percent >= 20
	and batting.yearid = 2016
group by namelast, namefirst, batting.yearid
order by percent_stolen desc;
--Isabelle

-- 7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

select teamid, yearid, wswin, w,  
		MAX(w) OVER () AS max_wins_n_ws,
		MIN(w) OVER (PARTITION BY wswin = 'Y') AS min_wins_y_ws
from teams 
WHERE yearid between 1970 AND 2016
	AND wswin = 'N'
GROUP BY yearid, wswin, w, teamid
ORDER BY w DESC
--table with just N wins

select teamid, yearid, wswin, w,  
		MAX(w) OVER (PARTITION BY wswin = 'N') AS max_wins_n_ws,
		MIN(w) OVER (PARTITION BY wswin = 'Y') AS min_wins_y_ws
from teams 
WHERE yearid between 1970 AND 2016 AND yearid != 1981
GROUP BY yearid, wswin, w, teamid
ORDER BY w DESC;
--two tables Y and N combined 

select teamid, yearid, wswin, w
from teams
where yearid between 1970 and 2016
	and wswin = 'N'
group by teamid, yearid, wswin, w
order by w desc;

--1981 was a player strike year OMIT 1981

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
--Isabelle 


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT team, park, park_name,
		attendance / games  AS avg_attendance
FROM homegames
INNER JOIN parks USING (park)
WHERE year = 2016 AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;

SELECT team, park, park_name,
		attendance / games  AS avg_attendance
FROM homegames
INNER JOIN parks USING (park)
WHERE year = 2016 AND games >= 10
ORDER BY avg_attendance  
LIMIT 5; 

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
--Isabelle 

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

SELECT namefirst, namelast, teamid, name, managers.yearid, awardid, awardsmanagers.lgid  
FROM managers
INNER JOIN awardsmanagers USING (yearid)
INNER JOIN people USING (playerid)
INNER JOIN teams USING (teamid)
WHERE awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'NL'  
GROUP BY namefirst, namelast, teamid, name, managers.yearid, awardid, awardsmanagers.lgid  
--couldnt get the function to also recognize 'AL' 
--also if you take away the group by you get 860 lines, as opposed to 3 if you keep in the group by so i dunno whats up

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
--Isabelle used the INTERSECT function to cross join the NL and AL winners with the TSN 
--then used a CTE to define the player id by names and details 
--SOLID WORK! STUDY IT!!!

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


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
WHERE yearid = 2016 AND hr >= 1)
ORDER BY max DESC;
--players who scored at least one in 2016

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
--Isabella 

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
--Abi Taylor 

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

SELECT  DISTINCT teamid, salary 
FROM salaries
WHERE yearid >= 2000
GROUP BY  teamid, salary
--try 1
select yearid, teamid, w
from teams
where yearid >= 2000
order by w desc;
--try 2 

SELECT yearid,
       teamid,
       CAST(CAST(AVG(salary) AS numeric) AS money) AS avg_salary_money
FROM salaries
where yearid >= 2000
GROUP BY yearid, teamid
ORDER BY yearid;


WITH avg_salary_per_team AS 
(
select teamid, yearid, AVG(salary)::int::money as avg_salary, w
from salaries
join teams using(teamid, yearid)
where yearid >= 1999
group by teamid, yearid, w
order by yearid
)
SELECT teamid, yearid, w,
		avg_salary - LAG(avg_salary) OVER (PARTITION BY teamid ORDER BY yearid) AS salary_diff
FROM avg_salary_per_team
WHERE yearid >= 2000
ORDER BY salary_diff; 
--note no difference in 2000? nulls! 
--you changed sum to avg 
--when casting ::money ($2973180) the first row is put into () - means negative 

-- 12. In this question, you will explore the connection between number of wins and attendance.

-- i. Does there appear to be any correlation between attendance at home games and number of wins?

select yearid, teamid, w, attendance
from teams
group by yearid, teamid, w , attendance
order by w desc; 

select *
from teams; 

-- ii. Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.


WITH wswin_attendance AS 
(
SELECT name, wswin, homegames.attendance, year
FROM teams 
INNER JOIN homegames 
ON team = teamid AND year = yearid 
WHERE wswin is not null AND homegames.attendance > 0 
)
SELECT year, wswin, attendance, name,
	CASE 
		WHEN wswin = 'Y' then year + 1 
	END AS year_after_win
FROM wswin_attendance
-- tried year_after_win = year then attendance under another case statement 



WITH wswin_attendance AS 
(
SELECT name, wswin, homegames.attendance, year
FROM teams 
INNER JOIN homegames 
ON team = teamid AND year = yearid 
WHERE wswin is not null AND homegames.attendance > 0 
)
SELECT year, wswin, attendance, name,
	CASE 
		WHEN wswin = 'Y' then year + 1 
	END AS year_after_win
FROM wswin_attendance



-- -- Countries cold enough for snow year-round
-- SELECT country_code
--   , country
--   , COUNT (DISTINCT athlete_id) AS winter_athletes -- Athletes can compete in multiple events 
-- FROM athletes
-- WHERE country_code IN (SELECT olympic_cc FROM oclimate WHERE temp_annual < 0)
-- AND season = 'Winter'
-- GROUP BY country_code, country;



-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?




