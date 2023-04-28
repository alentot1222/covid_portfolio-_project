--Cleaning - changing data types
-- since I encountered some errors during data exploration, I decided to change the data types of the following to numeric:
--- total_deaths
--- total_cases
--- people_fully_vaccinated


ALTER TABLE dbo.CovidDeaths
ADD total_deaths1 numeric

UPDATE dbo.CovidDeaths
SET total_deaths1 = CAST(total_deaths AS bigint)


ALTER TABLE dbo.CovidDeaths
ADD total_cases1 numeric

UPDATE dbo.CovidDeaths
SET total_cases1 = CAST(total_cases AS bigint)

ALTER TABLE dbo.CovidDeaths
DROP COLUMN total_deaths

ALTER TABLE dbo.CovidDeaths
DROP COLUMN total_cases

EXEC sp_rename 'CovidDeaths.total_deaths1', 'total_deaths', 'COLUMN';

EXEC sp_rename 'CovidDeaths.total_cases1', 'total_cases', 'COLUMN';


ALTER TABLE dbo.CovidVaccinations
ADD people_fully_vaccinated1 numeric

UPDATE dbo.CovidVaccinations
SET people_fully_vaccinated1 = people_fully_vaccinated

ALTER TABLE dbo.CovidVaccinations
DROP COLUMN people_fully_vaccinated

EXEC sp_rename 'CovidVaccinations.people_fully_vaccinated1', 'people_fully_vaccinated', 'COLUMN';

