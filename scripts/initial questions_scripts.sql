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
-- where total_percent > 20
-- 	and batting.yearid = 2016
-- group by namelast, namefirst, batting.yearid
-- order by percent_stolen desc;

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
-- order by wins desc;
-- 116 wins for SEA for non winners

-- select teamid, yearid, wswin, w 
-- from teams
-- where yearid between 1970 and 2016
-- 	and wswin = 'Y'
-- group by teamid, yearid, wswin,  w
-- order by wins;
-- 63 wins for LAN for winners

--Madi's query
-- SELECT MIN(w) AS smallest_wins_world_series_winner
-- FROM teams
-- WHERE yearid BETWEEN 1970 AND 2016
-- 	and wswin = 'Y';

-- select teamid, yearid, wswin, sum(w) as wins
-- from teams
-- where yearid = 1983
-- group by teamid, yearid, wswin;

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
-- 		from homegames) > 10
-- group by teams.name, park_name
-- order by avg_attn desc
-- limit 5;

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

-- 10 Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
select playerid, max(hr), yearid
from batting
where yearid = 2016
	and hr >= 1
group by playerid, yearid;