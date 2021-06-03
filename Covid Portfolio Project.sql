SELECT * FROM PortfolioProject..CovidDeath
where continent is not null
ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccination
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population 
from PortfolioProject..CovidDeath order by 1,2

--Looking at Total cases vs Total Deaths
--Show likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath 
where location like '%states%' and continent is not null
order by 1,2

--Looking at Total cases vs Population
--Show what percentage of population got covid

SELECT location,date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeath 
--where location like '%states%'
WHERE continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCountry, (MAX(total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC
 
-- Let's Break Things Down by Continent
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing Continents with the highest death count per population

SELECT continent, population, MAX(CAST(total_deaths as int))/population as TotalDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY continent, population
ORDER BY TotalDeathCount DESC

-- Global Number

SELECT SUM(new_cases) as Total_Cases,SUM(CAST(new_deaths as int)) as Total_Deaths,
SUM(CAST(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


--USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100

FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)             
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100

FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
          
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100

FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

select * from PercentPopulationVaccinated