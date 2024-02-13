

--SELECT *
--FROM CovidVaccinations
--ORDER by 3,4

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER by 1,2

EXEC sp_help '[dbo].[CovidDeaths]'

ALTER TABLE [dbo].[CovidVaccinations]
ALTER COLUMN new_vaccinations float


-- Total Cases vs Total Deaths

SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%Bangladesh%'
ORDER by 1,2


-- Total Case vs Population
-- Percentage of Population infected to COVID

SELECT location,date,population, total_cases, (total_cases/population)*100 as CovidRate
FROM CovidDeaths
--WHERE location like '%Bangladesh%'
ORDER by 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestCovidRate
FROM CovidDeaths
--WHERE location like '%Bangladesh%'
GROUP by location, population
ORDER by HighestCovidRate DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%Bangladesh%'
WHERE continent is not null
GROUP by location, population
ORDER by TotalDeathCount DESC

-- Continents with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%Bangladesh%'
WHERE location = 'Asia' OR location = 'Europe'OR location = 'Africa' OR location = 'South America' OR location = 'North America' OR location = 'Oceania'
GROUP by location
ORDER by TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT SUM(new_cases) as CasesNumber, SUM (cast(new_deaths as int)) as DeathsNumber, SUM (new_deaths)/SUM(cast(new_cases as int))*100 as DeathPercentage
FROM CovidDeaths
--WHERE location like '%Bangladesh%'
WHERE continent is NOT NULL
--GROUP by date
ORDER by 1,2


-- Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (vac.new_vaccinations)
OVER(Partition by dea.location Order by dea.location, dea.date) as rolling_new_vaccinations

FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is NOT NULL
	ORDER BY 2,3


	-- USE CTE

	WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_new_vaccinations)
	As
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (vac.new_vaccinations)
OVER(Partition by dea.location Order by dea.location, dea.date) as rolling_new_vaccinations

FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is NOT NULL
	--ORDER BY 2,3
	)
	SELECT*, (rolling_new_vaccinations/population)*100
	FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulatioVaccinated
CREATE TABLE #PercentPopulatioVaccinated

(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_New_Vaccinations numeric
)

INSERT INTO #PercentPopulatioVaccinated


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (vac.new_vaccinations)
OVER(Partition by dea.location Order by dea.location, dea.date) as rolling_new_vaccinations

FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	--WHERE dea.continent is NOT NULL
	ORDER BY 1,3

SELECT*, (rolling_new_vaccinations/population)*100 as VaccinationRate
FROM #PercentPopulatioVaccinated




-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (vac.new_vaccinations)
OVER(Partition by dea.location Order by dea.location, dea.date) as rolling_new_vaccinations

FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is NOT NULL
	--ORDER BY 1,3
