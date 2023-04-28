
SELECT *
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


---- Total Cases Vs Total Deaths
---- Shows likelihood of dying if you contract covid in the Philippines

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location LIKE 'Philippines'
ORDER BY location,date



----- Looking at Total Cases Vs Population
----- shows what percentage of the population got Covid in the Philippines
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE location LIKE 'Philippines'
ORDER BY location,date


----- Looking at countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100
	AS PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


----- Showing countries with the highest death count per population


SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


----- Total Deaths per Continent

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



----- Global Numbers
----- Total cases Vs Total deaths
--Global
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From dbo.CovidDeaths
where continent IS NOT NULL
order by 1,2


SELECT *
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS Updated_Vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

----- total population vs full vaccinated population

SELECT dea.location,dea.population,MAX(vac.people_fully_vaccinated) AS VaccinatedPop
FROM dbo.CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.location,dea.population
ORDER BY VaccinatedPop DESC


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Updated_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS numeric)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Updated_Vaccinated
--, (Updated_Vaccinated/population)*100
FROM dbo.CovidDeaths dea
INNER JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
SELECT *, (Updated_Vaccinated/Population)*100
FROM PopvsVac