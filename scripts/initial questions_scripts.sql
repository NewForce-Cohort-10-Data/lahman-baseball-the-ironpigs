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

--Madi's query
-- SELECT
--     FLOOR(yearid / 10) * 10 AS decade,
--     ROUND(SUM(so) * 1.0 / SUM(g), 2) AS strikeout_avg,
--     ROUND(SUM(hr) * 1.0 / SUM(g), 2) AS home_run_avg
-- FROM batting
-- WHERE yearid >= 1920
-- GROUP BY decade
-- ORDER BY decade;

--check
-- select 
-- 	case
-- 		when yearid between 2000 and 2009 then 2000
-- 	end as decade, 
-- 	round((sum(so) * 1.0 / sum(g)),2)
-- from batting
-- where yearid between 2000 and 2009
-- group by decade;

-- select floor(yearid / 10)
-- from batting
-- group by yearid;

--long route
-- select 
-- 	case
-- 		when yearid between 1920 and 1929 then 1920
-- 		when yearid between 1930 and 1939 then 1930
-- 		when yearid between 1940 and 1949 then 1940
-- 		when yearid between 1950 and 1959 then 1950
-- 		when yearid between 1960 and 1969 then 1960
-- 		when yearid between 1970 and 1979 then 1970
-- 		when yearid between 1980 and 1989 then 1980
-- 		when yearid between 1990 and 1999 then 1990
-- 		when yearid between 2000 and 2009 then 2000
-- 		when yearid between 2010 and 2019 then 2010
-- 		end as decade,
-- 		round(sum(so) * 1.0 / sum(g),2)
-- from batting
-- where yearid >= 1920
-- group by decade;


-- 6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
-- with total as(
-- 	select playerid, yearid, (sum(sb) + sum(cs)) as total_percent
-- 	from batting
-- 	where yearid = 2016
-- 	group by playerid, yearid
-- 	order by playerid)
-- select namelast, namefirst, batting.yearid, round((sum(sb) / sum(total_percent)),2) as percent_stolen
-- from batting
-- join total
-- 	using(playerid)
-- join people
-- 	using(playerid)
-- where total_percent >= 20
-- 	and batting.yearid = 2016
-- group by namelast, namefirst, batting.yearid
-- order by percent_stolen desc;


--Abi's query
-- SELECT playerid, namegiven, ROUND(((sum(sb) * 1.0)/(sum(sb) + sum(cs))) * 100, 2) AS percent_stolen
-- FROM batting
-- INNER JOIN people USING (playerid)
-- WHERE yearid = 2016
-- GROUP BY playerid, namegiven
-- having (sum(sb) + sum(cs)) >= 20
-- ORDER BY percent_stolen DESC;

--Tarik's query
-- SELECT playerid, yearid, sb, cs,
-- 	   ROUND( sb * 1.0 / (sb + cs), 2) AS attempts
-- FROM batting
-- WHERE (sb + cs) >= 20 AND yearid = 2016
-- ORDER BY attempts DESC;

-- select namelast, namefirst, sb, cs
-- from people
-- join batting
-- 	using(playerid)
-- where namelast = 'Owings'
-- 	and namefirst = 'Chris'
-- 	and yearid = 2016;

-- select namelast, namefirst, yearid, (sum(sb)/nullif((sum(sb) + sum(cs)),0)) * 1.0 as percent_stolen
-- from batting
-- join people
-- 	using(playerid)
-- where yearid = 2016
-- 	and (select (sum(sb) + sum(cs))
-- 		from batting) >= 20
-- group by namelast, namefirst, yearid
-- order by percent_stolen desc nulls last;

-- 7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
-- select teamid, yearid, wswin, w
-- from teams
-- where yearid between 1970 and 2016
-- 	and wswin = 'N'
-- group by teamid, yearid, wswin, w
-- order by w desc;
-- 116 wins for SEA for non winners

-- select teamid, yearid, wswin, w 
-- from teams
-- where yearid between 1970 and 2016
-- 	and wswin = 'Y'
-- group by teamid, yearid, wswin,  w
-- order by w;
-- 63 wins for LAN for winners

--Madi's query
-- SELECT MIN(w) AS smallest_wins_world_series_winner
-- FROM teams
-- WHERE yearid BETWEEN 1970 AND 2016
-- 	and wswin = 'Y';

--Tarik's query
-- select teamid, yearid, wswin, w,
-- 		MAX(w) OVER (PARTITION BY wswin = 'N') AS max_wins_n_ws,
-- 		MIN(w) OVER (PARTITION BY wswin = 'Y') AS min_wins_y_ws
-- from teams
-- WHERE yearid between 1970 AND 2016
-- GROUP BY yearid, wswin, w, teamid
-- ORDER BY w DESC;

-- select teamid, yearid, wswin, sum(w) as wins
-- from teams
-- where yearid = 1983
-- group by teamid, yearid, wswin;


--player strike 1981

-- 7b. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
-- with max_wins as (
-- 	select yearid, max(w) as w
-- 	from teams
-- 	where yearid between 1970 and 2016
-- 		and yearid != 1981
-- 	group by yearid
-- )
-- select 
-- 	round(count(case when wswin = 'Y' then 'Keep' end)::numeric /
-- 	count(distinct yearid)::numeric, 2) as percent_max_wins_ws
-- from teams
-- join max_wins as mw
-- 	using(yearid, w);


-- select yearid, wswin, w
-- from teams
-- where yearid = 2013
-- group by yearid, wswin, w;

-- select yearid, max(w)
-- from teams
-- where yearid between 1970 and 2016
-- 	and yearid != 1981
-- group by yearid
-- order by yearid;
	

-- with max_wins as (
-- 	select yearid, max(w) as wins
-- 	from teams
-- 	where yearid between 1970 and 2016
-- 		and yearid != 1981
-- 	group by yearid
-- 	order by yearid)
-- select teamid, mw.yearid, wins
-- from teams
-- join max_wins as mw
-- 	on w = wins
-- group by teamid, mw.yearid, wins;

-- select teamid, yearid, wswin, max(w) as wins
-- from teams
-- where yearid between 1970 and 2016
-- 	and yearid != 1981
-- group by teamid, yearid, wswin
-- order by wins;

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
-- select teams.name, park_name, sum(hg.attendance) / sum(hg.games)  as avg_attn
-- from homegames as hg
-- join teams
-- 	on hg.team = teams.teamid
-- join parks
-- 	on hg.park = parks.park
-- where year = 2016
-- 	and (select sum(games)
-- 		from homegames) >= 10
-- group by teams.name, park_name
-- order by avg_attn desc
-- limit 5;

-- select team, park, sum(hg.attendance) / sum(hg.games)  as avg_attn
-- from homegames as hg
-- where year = 2016
-- 	and (select sum(games)
-- 		from homegames) >= 10
-- group by team, park
-- order by avg_attn desc;

--Tarik's query
-- SELECT team, park, park_name,
-- 		attendance / games  AS avg_attendance
-- FROM homegames
-- INNER JOIN parks USING (park)
-- WHERE year = 2016 AND games >= 10
-- ORDER BY avg_attendance DESC
-- LIMIT 5;

-- select teams.name, park_name, sum(hg.attendance) / sum(hg.games)  as avg_attn
-- from homegames as hg
-- join teams
-- 	on hg.team = teams.teamid
-- join parks
-- 	on hg.park = parks.park
-- where year = 2016
-- 	and (select sum(games)
-- 		from homegames) > 10
-- group by teams.name, park_name
-- order by avg_attn
-- limit 5;



--extra
-- select team, hg.park, sum(hg.attendance) / sum(hg.games)  as avg_attn
-- from homegames as hg
-- where year = 2016
-- 	and (select sum(games)
-- 		from homegames) > 10
-- group by team, hg.park
-- order by avg_attn desc;

-- select teams.name, park_name, sum(hg.attendance)/sum(total_games) as avg_attn
-- from homegames as hg
-- join park_games as pg
-- 	on hg.park = pg.park and hg.games = pg.total_games
-- join parks as p
-- 	on hg.park = p.park
-- join teams
-- 	on team = teamid
-- where year = 2016
-- 	and total_games >= 10
-- group by teams.name, park_name
-- order by avg_attn desc
-- limit 5;

-- select park, sum(games) as total_games
-- from homegames
-- group by park

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
-- with nl_al_managers as (
-- 	(select distinct playerid, awardid
-- 	from awardsmanagers
-- 	where awardid = 'TSN Manager of the Year'
-- 		and lgid = 'NL')
-- 	intersect
-- 	(select distinct playerid, awardid
-- 	from awardsmanagers
-- 	where awardid = 'TSN Manager of the Year'
-- 		and lgid = 'AL'))
-- select namelast, namefirst, teams.name, am.yearid, awardid, am.lgid
-- from awardsmanagers as am
-- join nl_al_managers as na
-- 	using(playerid, awardid)
-- join people
-- 	using(playerid)
-- join managers
-- 	using(playerid, yearid)
-- join teams
-- 	using(teamid, yearid);

--test
-- select playerid, yearid, awardid
-- from awardsmanagers
-- where awardid = 'TSN Manager of the Year'
-- 	and playerid = 'leylaji99';

--Tarik's query (unfinished)
-- SELECT namefirst, namelast, teamid, name, managershalf.yearid, awardid, awardsmanagers.lgid
-- FROM managershalf
-- INNER JOIN awardsmanagers USING (playerid)
-- INNER JOIN people USING (playerid)
-- INNER JOIN teams USING (teamid)
-- WHERE awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'NL'
-- GROUP BY namefirst, namelast, teamid, name, managershalf.yearid, awardid, awardsmanagers.lgid

-- 10 Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
-- with homeruns as (
-- 	select playerid, max(hr) as hr, yearid
-- 	from batting
-- 	where hr >= 1
-- 	group by playerid, yearid)
-- select namefirst, namelast, hrs.hr
-- from batting as b
-- join homeruns as hrs
-- 	using(hr, playerid)
-- join people
-- 	using(playerid)
-- where b.yearid = 2016
-- 	and (left(coalesce(finalgame,2016::text),4)::numeric - left(debut,4)::numeric) >=10
-- group by namefirst, namelast, hrs.hr
-- order by hr desc;


--Tarik's query
-- (SELECT playerid, namefirst, namelast, appearances.yearid, MAX(hr)
-- FROM batting
-- INNER JOIN people USING(playerid)
-- INNER JOIN appearances USING (playerid)
-- WHERE (left(coalesce(finalgame,2016::text),4)::numeric - left(debut,4)::numeric) >=10
-- GROUP BY playerid, namefirst, namelast, appearances.yearid, hr
-- ORDER BY hr DESC)
-- --most homeruns where year is greater than or = 2006
-- INTERSECT  --?
-- (SELECT playerid, namefirst, namelast, yearid, hr
-- FROM batting
-- INNER JOIN people USING(playerid)
-- WHERE yearid = 2016 AND hr >= 1
-- group by playerid, namefirst, namelast, yearid, hr)
-- order by max desc;
-- --players who scored at least one in 2016


--Abi's query
-- WITH career_hr AS
-- (SELECT playerid, MAX(hr)
-- FROM batting
-- GROUP BY playerid),
-- players2016 AS
-- (SELECT playerid, hr
-- FROM batting
-- WHERE yearid = 2016 AND HR >= 1),
-- years_played AS
-- (SELECT playerid, COUNT(DISTINCT yearid) AS years_played
-- FROM batting
-- GROUP BY playerid)
-- SELECT people.namefirst, people.namelast, batting.hr, years_played.years_played
-- FROM people
-- JOIN batting USING (playerid)
-- JOIN years_played USING (playerid)
-- WHERE yearid = 2016 AND hr >= 1 AND years_played >= 10
-- GROUP BY batting.playerid, people.namefirst, people.namelast, batting.hr, years_played.years_played
-- ORDER BY hr DESC;

--test
-- select playerid, debut, finalgame, hr, yearid
-- from people
-- join batting using(playerid)
-- where playerid = 'cruzne02';





-- 11 Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- Definitely some correlation between wins and salary, but not a dramatic 1-1 association. The greatest jumps in data seem to be either due to standard league salary increases or other factors, but even still, wins do seem to have a minor impact on salary, increasing as winning or losing streaks continue.

-- select teamid, yearid, sum(salary)::numeric::money as total_salary, w
-- from salaries
-- join teams
-- 	using(teamid, yearid)
-- where yearid >= 2000
-- group by teamid, yearid, w
-- having teamid = 'SFN'
-- order by yearid;


-- select teamid, yearid, sum(salary)::numeric::money as total_salary, w
-- from salaries
-- join teams
-- 	using(teamid, yearid)
-- where yearid >= 2000
-- group by teamid, yearid, w
-- having teamid = 'PHI'
-- order by yearid;

-- select teamid, yearid, sum(salary)::numeric::money as total_salary, w
-- from salaries
-- join teams
-- 	using(teamid, yearid)
-- where yearid >= 2000
-- group by teamid, yearid, w
-- having teamid = 'PHI' or teamid = 'SFN' or teamid = 'COL'
-- order by yearid;

-- select teamid, yearid, sum(w) as wins
-- from teams
-- where yearid = 2000
-- group by teamid, yearid
-- order by wins desc;

-- select distinct teamid, w
-- from teams
-- where yearid = 2000

-- select teamid, sum(salary)
-- from salaries
-- where yearid = 2000
-- 	and teamid = 'SFN'
-- group by teamid

-- SELECT yearid,
--        teamid,
--        CAST(CAST(AVG(salary) AS numeric) AS money) AS avg_salary_money
-- FROM salaries
-- GROUP BY yearid, teamid
-- ORDER BY yearid;


-- 12 In this question, you will explore the connection between number of wins and attendance.

-- 12a Does there appear to be any correlation between attendance at home games and number of wins?

--Definitely correlation between wins and attendance. Typically if a team starts doing good or bad, the year after will start to reflect as much in attendance, though if they start to tred or even out, then so will the attendance rates.

-- select teamid, yearid, w, attendance
-- from teams
-- where teamid = 'PHI' or teamid = 'SFN' or teamid = 'COL'
-- 	and yearid >= 1950
-- order by yearid desc;

-- select distinct teamid, min(attendance), max(attendance)
-- from teams
-- where teamid = 'NYA'
-- group by teamid;

-- select teamid, yearid, w, sum(-attendance) over(
-- 	partition by teamid
-- 	order by yearid desc
-- 	rows between 1 preceding and current row
-- ) as diff
-- from teams;

-- 12b Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

--Playoffs or WS doesn't seem to make as much of an impact as simple winning streaks to attendance. The only time attendance seemed to move significally alongside WS or PO wins was when that team was also having a winning streak over the last few years.

-- select teamid, yearid, w, wswin,
-- 	case
-- 		when DivWin = 'Y' or WCWin = 'Y' then 'Y'
-- 		else 'N'
-- 	end as playoffs,
-- 	attendance
-- from teams
-- where teamid = 'PHI' or teamid = 'SFN' or teamid = 'COL'
-- order by yearid desc;


-- 13 It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

-- No, it doesn't seem as though being left handed or ambidexterous are decidedly more effective. About 34% of league players are left or both handed which is nearly equivalent to the number of Cy Young award winners. Comparatively, there is a slightly higher population in the Hall of fame at 40%, but that isn't an out of reach number. Overall, comparing these results to the population in the league, left handed or ambidexteriousness doesn't seem to result in unfair advantage or effectiveness.


-- select 
-- 	round(sum(case when bats = 'L' or bats = 'B' then 1 else 0 end) * 1.0 / count(bats),2)
-- from people;
-- -- 34% of batters are left handed or both


-- select 
-- 	round(sum(case when bats = 'L' or bats = 'B' then 1 else 0 end) * 1.0 / count(bats),2)
-- from people
-- join awardsplayers
-- 	using(playerid)
-- where awardid = 'Cy Young Award';
-- -- 31% of Cy Young Awards have gone to left handed or both handed batters


-- select 
-- 	round(sum(case when bats = 'L' or bats = 'B' then 1 else 0 end) * 1.0 / count(bats),2)
-- from people
-- join halloffame
-- 	using(playerid)
-- where inducted = 'Y';
-- -- 40% of hall of fame inductees have been left or both handed.


-- select 
-- 	case 
-- 		when bats = 'L' then 1
-- 		else 0
-- 	end as batting
-- from people


-- select bats
-- from people;

-- select playerid, awardid, bats
-- from awardsplayers
-- join people
-- 	using(playerid)
-- where awardid = 'Cy Young Award';

-- select distinct playerid, bats
-- from halloffame
-- join people
-- 	using(playerid)
-- where bats is not null;

-- select *
-- from halloffame
-- where playerid = 'sislege01';