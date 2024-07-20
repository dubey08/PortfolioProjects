Select *
From ProjectPortfolio..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From ProjectPortfolio..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio..CovidDeaths
order by 1,2


--Looking at total cases vs total deaths

Select Location, date, total_cases, total_deaths, (CAST(total_cases AS FLOAT)/CAST(total_deaths AS FLOAT)) as DeathPercentage
From ProjectPortfolio..CovidDeaths
where continent is not null 
order by 1,2


--Looking at total cases vs population

Select Location, date, total_cases, Population, CAST(total_cases AS FLOAT)/population as DeathPercentage
From ProjectPortfolio..CovidDeaths
order by 1,2


--Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HoghestInfectionCount, MAX(CAST(total_cases AS FLOAT)/population) as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--showing countries with highest death count per population 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
where continent is not null 
Group by Location
order by TotalDeathCount desc


--LETS BREAK THINGS DOWN BY CONTINENT 


--showing continent with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
where continent is not null 
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/nullif(SUM(new_cases),0)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
where continent is not null 
Group by date
order by 1,2

--Looking at total population vs vaccination

Select dea.continent ,dea.location , dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
     On dea.location = vac.location 
	 and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent ,dea.location , dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
     On dea.location = vac.location 
	 and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac 


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent ,dea.location , dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
     On dea.location = vac.location 
	 and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated 




--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent ,dea.location , dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
     On dea.location = vac.location 
	 and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated