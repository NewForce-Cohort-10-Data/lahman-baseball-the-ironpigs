select *
from allstarfull
select *
from people
select *
from teams

SELECT MIN(yearid) AS earliest_year, MAX(yearid) AS latest_year
FROM teams;

Select p.namefirst,p.namelast,p.height, count (a.gameid) as games_played,teamid as team_name
from people
left join all_star on p.playerid= a.playerid

where p.playerid= (select playerid
from people
full outer join allstarfull on allstarfull.playerid = people.playerid
order by height ASC
limit 1)
Group by p.namefirst,p.namelast,p.height,t.name



