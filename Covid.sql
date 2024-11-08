select * from Portfolio..CovidDeaths
order by 3,4


-- Select * from Portfolio..CovidDeaths
--order by 3,4


-- Select data that we are going to using
select location, date, total_cases, new_cases, total_deaths, population
from Portfolio..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract Covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio..CovidDeaths
where location = 'Vietnam'
and continent is not null
order by 2


-- Looking at the Total Cases vs Population
-- Show what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from Portfolio..CovidDeaths
where location = 'Vietnam'
and continent is not null
order by 1,2


-- Looking at country with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighesInfectionCount, max((total_cases/population)*100) as PercentPopulationInfected
from Portfolio..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- Showing Country with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- Break things down by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Showing continents with the highes death count per population
select continent, sum(cast(total_deaths as int))/sum(population)*100 as PercentDeathContinent
from Portfolio..CovidDeaths
where continent is not null
group by continent
order by PercentDeathContinent desc


-- Global number
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Portfolio..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location,
 cd.date) as RollingPeopleVaccinated
from Portfolio..CovidDeaths cd
join Portfolio..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null and cd.location = 'Albania'
order by 2,3


-- CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as 
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location,
 cd.date) as RollingPeopleVaccinated
from Portfolio..CovidDeaths cd
join Portfolio..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- temp table
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)


insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location,
 cd.date) as RollingPeopleVaccinated
from Portfolio..CovidDeaths cd
join Portfolio..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
--where cd.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualizations
create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location,
 cd.date) as RollingPeopleVaccinated
from Portfolio..CovidDeaths cd
join Portfolio..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null 
--order by 2,3


select * 
from PercentPopulationVaccinated