-- Select all columns and sort by specific indices
select * from Portfolio..CovidDeaths
order by 3,4


-- Select specific columns for analysis and sort by location and date
select location, date, total_cases, new_cases, total_deaths, population
from Portfolio..CovidDeaths
where continent is not null
order by 1,2


-- Show the likelihood of dying if you contract COVID-19 in Viet Nam
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio..CovidDeaths
where location = 'Vietnam'
and continent is not null
order by 2


-- Calculate the percentage of population infected with COVID-19
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from Portfolio..CovidDeaths
where location = 'Vietnam'
and continent is not null
order by 1,2


-- Find the country with the highest infection rate relative to its population
select location, population, max(total_cases) as HighesInfectionCount, max((total_cases/population)*100) as PercentPopulationInfected
from Portfolio..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- Identify the country with the highest number of total deaths
select location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- Summarize total deaths by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Calculate the death percentage by continent
select continent, sum(cast(total_deaths as int))/sum(population)*100 as PercentDeathContinent
from Portfolio..CovidDeaths
where continent is not null
group by continent
order by PercentDeathContinent desc


-- Summarize global cases, deaths, and death percentage
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Portfolio..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Calculate cumulative vaccinations by country
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location,
 cd.date) as RollingPeopleVaccinated
from Portfolio..CovidDeaths cd
join Portfolio..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null and cd.location = 'Albania'
order by 2,3


-- Use a CTE to calculate rolling vaccinations and vaccination percentage
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


-- Create a temporary table for vaccination data
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

-- Insert vaccination data into the temporary table
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

 -- Query the temporary table to calculate the vaccination percentage
select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Create a view for long-term use in data visualization
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
