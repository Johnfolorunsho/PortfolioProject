select *
from coviddeaths
where continent is not null
order by 3, 4

--select *
--from covidvaccinations
--order by 3, 4

--select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1, 2

-- Looking at The Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country
select location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as Deathpercentage
from coviddeaths
where location = 'nigeria' and continent is not null
order by 1, 2

-- Looking at the total cases vs population
-- Shows what percentage of population get covid
select location, date, population, total_cases,  (total_cases/population)*100 as percentofPopulationInfected
from coviddeaths
--where location = 'nigeria' and continent is not null
order by 1, 2

--Looking at Country with highest infection rate compared to population
select location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 as 
		percentofPopulationInfected
from coviddeaths
--where location = 'nigeria'
group by location, population
order by percentofPopulationInfected DESC

--Showing countries with highest deaths count per population
select location, MAX(cast(total_deaths as int)) as Totaldeathscount
from coviddeaths
--where location = 'nigeria'
where continent is not null
group by location
order by Totaldeathscount DESC


--let's break things down by continent
-- Showing the continent with the highest deathcount
select continent, MAX(cast(total_deaths as int)) as Totaldeathscount
from coviddeaths
--where location = 'nigeria'
where continent is not null
group by continent
order by Totaldeathscount DESC

-- Global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from coviddeaths
--where location = 'nigeria' and continent is not null
where continent is not null
--group by date
order by 1, 2


-- Looking at The total Population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
		dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from coviddeaths as dea
 join covidvaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


-- use CTE
with PopvsVac (continent, location, date, population, New_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
		dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from coviddeaths as dea
 join covidvaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)

select *, (Rollingpeoplevaccinated/population)*100
from PopvsVac

--temp table
drop table if exixts #percentpopulatedVaccinated
create table #percentpopulatedVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
		dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from coviddeaths as dea
 join covidvaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

select *, (Rollingpeoplevaccinated/population)*100
from #percentpopulatedVaccinated

--creating view to store data for latter visualization

create view percentpopulatedVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, 
		dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from coviddeaths as dea
 join covidvaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated