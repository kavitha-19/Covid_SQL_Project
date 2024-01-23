select * 
from ProjectDB..CovidDeaths 
where continent is not NULL
order by 3,4


--select * from ProjectDB..CovidVaccinations order by 3,4


-- selecting data which is needed
select location,date,total_cases,new_cases,total_deaths,population
from ProjectDB..CovidDeaths 
where continent is not NULL
order by 1,2


-- Looking at total_cases vs total_deaths
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
FROM ProjectDB..CovidDeaths
where continent is not NULL
and  location like '%states%'
ORDER BY 1, 2;


-- Looking at total_cases vs Population
-- shows the % of population got covid

SELECT location, date, population, total_cases, (NULLIF(CONVERT(float, total_cases), 0)/population) * 100 AS PercentageofPopulationInfected
FROM ProjectDB..CovidDeaths
where continent is not NULL
ORDER BY 1, 2;

-- Looking at countries with Highest infection rate compared to Population

SELECT
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    (MAX(NULLIF(CONVERT(float, total_cases), 0)) / MAX(population)) * 100 AS PercentageofPopulationInfected
FROM ProjectDB..CovidDeaths
where continent is not NULL
GROUP BY location, population
ORDER BY PercentageofPopulationInfected desc


-- Showing the countries with Highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectDB..CovidDeaths
where continent is not NULL
Group by location
order by TotalDeathCount desc

--  By continent
-- Showing the continents with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectDB..CovidDeaths
where continent is not NULL
Group by continent
order by TotalDeathCount desc


-- Global Numbers

SELECT  date,sum(new_cases) as total_newcases , sum(new_deaths) as total_newdeaths , (sum(new_deaths)/sum(new_cases)) * 100 as DeathPercentage
FROM ProjectDB..CovidDeaths
where continent is not NULL
Group by date
ORDER BY 1, 2;


SELECT  sum(new_cases) as total_newcases , sum(new_deaths) as total_newdeaths , (sum(new_deaths)/sum(new_cases)) * 100 as DeathPercentage
FROM ProjectDB..CovidDeaths
where continent is not NULL
ORDER BY 1, 2;


select * from ProjectDB..CovidVaccinations

-- Joining Two tables

select * from ProjectDB..CovidDeaths dea
Join  ProjectDB..CovidVaccinations  vac
on dea.location = vac.location 
and dea.date = vac.date

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectDB..CovidDeaths dea
Join  ProjectDB..CovidVaccinations  vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null	
order by 2,3

-- Using CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)

as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectDB..CovidDeaths dea
Join  ProjectDB..CovidVaccinations  vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null	

)
select * , (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Temp Table

drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectDB..CovidDeaths dea
Join  ProjectDB..CovidVaccinations  vac
on dea.location = vac.location 
and dea.date = vac.date

select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectDB..CovidDeaths dea
Join  ProjectDB..CovidVaccinations  vac
on dea.location = vac.location 
and dea.date = vac.date

select * from PercentPopulationVaccinated