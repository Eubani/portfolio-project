select *
from Portfolioproject..Coviddeath
Where continent is not null
order by 3,4

--select *
--from Portfolioproject..Covidvacination
--order by 3,4

--select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population 
from Portfolioproject..Coviddeath
where continent is not null
order by 1,2


-- looking at Total Cases vs Total Death
-- show the likelihood of dying if you contact in your country 

select Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/ NULLIF( CONVERT(float,total_cases),0))* 100 as DeathPercentage
from Portfolioproject..Coviddeath
where location like '%states%'
and continent is not null
order by 1,2

-- looking at Total Cases vs Popuation
-- shows what percentage of population  got covid 

select Location, date, total_cases, population, (total_cases/population)* 100 as DeathPercentage
from Portfolioproject..Coviddeath
where location like '%states%'
and continent is not null
order by 1,2




--looking at countries with Highest Infection Rate Compared to Population

select Location, population, Max( total_cases) as HighestInfectionCount, Max (total_cases/population)*100 as PercentPopulationInfected
from Portfolioproject..Coviddeath
--where location like '%states%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolioproject..Coviddeath
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY COUNTINENT

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolioproject..Coviddeath
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Showing the Continents with Highest Death Count per Population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolioproject..Coviddeath
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



--Grobal Numbers

select Sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from Portfolioproject..Coviddeath
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2


--looking at Total Population vs Vaccination

select*
from Portfolioproject..Coviddeath dea
join Portfolioproject..Covidvacination vac
    on dea.location = vac.location
	and dea.date =vac.date


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolioproject..Coviddeath dea
join Portfolioproject..Covidvacination vac
    on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from Portfolioproject..Coviddeath dea
join Portfolioproject..Covidvacination vac
    on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac (continent, location, date, Population,New_Vaccinations, Rollingpeoplevaccinated)
as
 (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population)*100
from Portfolioproject..Coviddeath dea
join Portfolioproject..Covidvacination vac
    on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
 select *, (RollingPeopleVaccinated/Population)*100
 from PopvsVac



--TEMP TABlE


Drop Table #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population)*100
from Portfolioproject..Coviddeath dea
join Portfolioproject..Covidvacination vac
    on dea.location = vac.location
	and dea.date =vac.date
--where dea.continent is not null
--order by 2,3

 select *, (RollingPeopleVaccinated/Population)*100
 from #PercentPopulationVaccinated





 --Creating view to store Data for later visualiazation

 
 Create view PercentPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  --,(RollingPeopleVaccinated/population)*100
from Portfolioproject..Coviddeath dea
join Portfolioproject..Covidvacination vac
    on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentPopulationVaccinated