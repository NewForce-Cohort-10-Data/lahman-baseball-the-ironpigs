What range of years for baseball games played does the provided database cover?
SELECT 
    MAX(yearID) AS max_year,
    MIN(yearID) AS min_year
FROM teams;
1871-2016
Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT playerid, namegiven, g_all AS games_played, teamid, teams.name AS team
FROM appearances
INNER JOIN teams USING (teamid)
INNER JOIN people USING (playerid)
WHERE playerid = 'gaedeed01'
LIMIT 1;

select *
from appearances

Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
select namelast, namefirst, height, sum(g) as games_played, name
from people
join appearances
	using(playerid)
join teams
	using(teamid)
Where height = (select min(height)
				from people)
group by namelast, namefirst, height, name;
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
Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
Select 
case 
when pos ='OF'tHEN'OUTFIELD'
WHEN POS IN ('SS','1B','2B','3B') THEN 'INFEILD'
WHEN POS IN ('P','C') THEN 'BATTERY' 
END AS player_group,
sum (po) AS total_putouts
from fielding
where yearid =2016
Group by player_group;

select *
from fielding
Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT
    FLOOR(yearid / 10) * 10 AS decade,
    ROUND(SUM(so) * 1.0 / SUM(g), 2) AS strikeout_avg,
    ROUND(SUM(hr) * 1.0 / SUM(g), 2) AS home_run_avg
FROM batting
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;

SELECT
    CASE 
        WHEN yearid BETWEEN 1920 AND 1929 THEN 1920
        WHEN yearid BETWEEN 1930 AND 1939 THEN 1930
        WHEN yearid BETWEEN 1940 AND 1949 THEN 1940
        WHEN yearid BETWEEN 1950 AND 1959 THEN 1950
        WHEN yearid BETWEEN 1960 AND 1969 THEN 1960
        WHEN yearid BETWEEN 1970 AND 1979 THEN 1970
        WHEN yearid BETWEEN 1980 AND 1989 THEN 1980
        WHEN yearid BETWEEN 1990 AND 1999 THEN 1990
        WHEN yearid BETWEEN 2000 AND 2009 THEN 2000
        WHEN yearid BETWEEN 2010 AND 2019 THEN 2010
        ELSE 2020
    END AS decade,
    ROUND(SUM(so) * 1.0 / SUM(g), 2) AS strikeout_avg,
    ROUND(SUM(hr) * 1.0 / SUM(g), 2) AS home_run_avg
FROM batting
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;

Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
select *
from batting
select *
from people
SELECT 
    p.namefirst,
    p.namelast,
    b.playerid,
    b.SB,
    b.CS,
    (b.SB * 1.0 / (b.SB + b.CS)) * 100 AS SUCCESS_RATE
FROM batting AS b
INNER JOIN people AS p ON b.playerid = p.playerid
WHERE b.yearid = 2016 
AND (b.SB + b.CS) >= 20
ORDER BY SUCCESS_RATE DESC;


SELECT 
    CONCAT(p.namefirst, ' ', p.namelast) AS player_name,
    b.playerid,
    b.SB,
    b.CS,
    (b.SB * 1.0 / (b.SB + b.CS)) * 100 AS SUCCESS_RATE
FROM batting AS b
INNER JOIN people AS p ON b.playerid = p.playerid
WHERE b.yearid = 2016 
AND (b.SB + b.CS) >= 20
ORDER BY SUCCESS_RATE DESC;
From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
SELECT MIN(w) AS smallest_wins_world_series_winner
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
  AND wswin = 'Y'; 
 SELECT MIN(w) AS smallest_wins_world_series_winner
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
  AND teamid IN (SELECT teamid FROM teams WHERE yearid BETWEEN 1970 AND 2016);
SELECT MAX(w) AS smallest_wins_world_series_winner
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
  AND teamid IN (SELECT teamid FROM teams WHERE yearid BETWEEN 1970 AND 2016);
Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

select *
from  homegames

Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
SELECT namefirst, namelast, teamid, name, managershalf.yearid, awardid, awardsmanagers.lgid
FROM managershalf
INNER JOIN awardsmanagers USING (playerid)
INNER JOIN people USING (playerid)
INNER JOIN teams USING (teamid)
WHERE awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'NL'

SELECT 
    nameFirst, 
    nameLast, 
    teamID, 
    name, 
    managershalf.yearID, 
    awardID, 
    awardsmanagers.lgID
FROM managershalf
INNER JOIN awardsmanagers USING (playerID)
INNER JOIN people USING (playerID)
INNER JOIN teams USING (teamID)
WHERE awardID = 'TSN Manager of the Year' 
AND awardsmanagers.lgID IN ('NL', 'AL')  
GROUP BY nameFirst, nameLast, teamID, name, managershalf.yearID, awardID, awardsmanagers.lgID;


Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
WITH career_hr AS (SELECT playerid, MAX(hr) AS max_hr
    FROM batting
    GROUP BY playerid),
years_played AS (SELECT playerid, COUNT(DISTINCT yearid) AS years_played
    FROM batting
    GROUP BY playerid)
SELECT 
    p.namefirst, 
    p.namelast, 
    b.hr, 
    yp.years_played
FROM people AS p
JOIN batting AS b USING (playerid)
JOIN years_played AS yp USING (playerid)
WHERE b.yearid = 2016 
    AND b.hr > 0 
    AND yp.years_played >= 10
ORDER BY b.hr DESC;

Open-ended questions
Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

There dosn't seem to be a direct corrilation between wins and salery. Some teams just get paid more. I would asume that maybe due to views or attendence. ( SEE PIVIOT TABLE)

In this question, you will explore the connection between number of wins and attendance.
Does there appear to be any correlation between attendance at home games and number of wins?
How I would solve problem- I would total up my wind and looses per team per year, then go to my homgames table total up attendence for the diffent teams and years and compair that to my teams colloum. At this point I would have a general over look of attencednc per team per year( if i go back and keep the L coloum from my teams table I could also coalculate the persentage of homegames won and lost per year over , showing the teams performance.


Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.
This question stumped me at first because i had a hard time finding where the the names of these " awards" whereonce i realized I figured I could join my tables ( i was considering using three tables)
It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

SELECT 
    COUNT(*) FILTER (WHERE throws = 'R') AS R,
    COUNT(*) FILTER (WHERE throws = 'L') AS L     =about 25%
FROM people; 

SELECT 
    h.playerID, 
    p.throws
FROM HallOfFame AS h
JOIN People AS p USING (playerID);
SELECT 
    p.nameFirst, 
    p.nameLast, 
    p.throws, 
    h.* 
FROM People AS p
FULL JOIN HallOfFame AS h USING (playerID);

SELECT 
    COUNT(*) FILTER (WHERE p.throws = 'R') AS count_R,
    COUNT(*) FILTER (WHERE p.throws = 'L') AS count_L,                = about 25%
    COUNT(*) FILTER (WHERE p.throws IS NULL) AS count_NULL
FROM People AS p
FULL JOIN HallOfFame AS h USING (playerID);

Checking the percentage of over all ledt handed people in my peoples table to the percent in my hall of fames table and they are ablot the same. Leading to my conclusion that I 
dispute this claim that since left-handed pitchers are more rare, they cause the batters to face them less oftenmaking them more effective. Unless all the null values after combining my people and hall of fame chart are left handed. In that case I would then agree. Because the persentage of null values + l would equal about 30% of my hall of fames tabe being left handed compaired to the 25% of over all players. 




