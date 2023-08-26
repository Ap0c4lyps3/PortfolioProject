-- Select data that I'm going to use
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeath
ORDER BY 1, 2

-- Looking at total cases vs total deaths 
SELECT Location, date, total_cases, total_deaths, 
(cast(total_deaths as float))/cast(total_cases as float)*100 AS DeathPercentage
FROM CovidDeath
WHERE location like 'Japan' -- (looking at specific country)
ORDER BY 1, 2

-- What percentage of population gets Covid?
SELECT Location, date, total_cases, population, 
(total_cases/population)*100 AS DeathPercentage
FROM CovidDeath
ORDER BY 1, 2

-- Looking at countries with highest infection rate comapred to population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeath
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Showing countries with highest death count per population
SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeath
Where continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Sort by continent 
SELECT continent, MAX(cast(Total_Deaths AS INT)) AS TotalDeathCount
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount ASC

-- Global numbers
SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths AS INT)) AS New_Deaths,
SUM(cast(new_deaths as FLOAT))/SUM(cast(new_cases AS FLOAT))* 100 AS DeathPercentage
FROM CovidDeath
WHERE continent IS NOT NULL
AND new_cases <> 0
GROUP BY date
ORDER BY 1, 2 


-- use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) 
AS
(
-- total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeath dea
JOIN CovidVac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac

-- Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeath dea
JOIN CovidVac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated

-- create view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeath dea
JOIN CovidVac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

 
