--SELECT*
--FROM [Portfolio Project]..covid_deaths
--ORDER BY 3,4;

--SELECT*
--FROM [Portfolio Project]..covid_vaccinations
--ORDER BY 3,4;

--SELECT data we would like to use--
--SELECT location,date,total_cases,new_cases,total_deaths,population
--FROM [portfolio project]..covid_deaths
--ORDER BY 1,2;

--Looking at total cases vs total deaths--
--this will query the death percentage for southafrica--
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM [portfolio project]..covid_deaths
WHERE location = 'South africa'
ORDER BY 1,2;
--Looking at the total cases vs population--
--this will query the infection percentage for south africa--
SELECT location,total_cases,population,(total_cases/population)*100 AS percentage_infected
FROM [portfolio project]..covid_deaths
WHERE location ='South africa'
ORDER BY 1,2;
-- Looking at the max total cases by population--
SELECT location,population,MAX(total_cases) AS highest_infection_cases,MAX((total_cases/population))*100 AS percentage_infected
FROM [portfolio project]..covid_deaths
--WHERE location ='South africa'--
GROUP BY location,population
ORDER BY percentage_infected DESC;
--Looking at countries with highest death per population
SELECT location,MAX(CAST (total_deaths AS int)) AS population_death_count
FROM [portfolio project]..covid_deaths
--WHERE location ='South africa'--
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY population_death_count DESC;
-- Showing continent with the highest death counts
SELECT continent,MAX(CAST (total_deaths AS int)) AS population_death_count
FROM [portfolio project]..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY population_death_count DESC;

--Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST (new_deaths AS INT)) AS total_deaths,
(SUM(CAST (new_deaths AS INT))/SUM(new_cases)*100) AS death_percentage
FROM [portfolio project]..covid_deaths
--WHERE location ='South africa'--
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 DESC;

WITH popvsvac (continent,location,date,population,new_vaccinations,rolling_vaccinations)
AS(
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS rolling_vaccinations
FROM [Portfolio Project]..covid_deaths d
JOIN [Portfolio Project]..covid_vaccinations v
	ON d.location=v.location 
	AND d.date=v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT*,(rolling_vaccinations/population) *100 AS rolling_percentage
FROM popvsvac


--Create TEMP Table

DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(continent NVARCHAR(255),location NVARCHAR(255),date DATETIME,population NUMERIC,new_vaccinations NUMERIC,rolling_vaccinations NUMERIC)

INSERT INTO #percent_population_vaccinated
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS rolling_vaccinations
FROM [Portfolio Project]..covid_deaths d
JOIN [Portfolio Project]..covid_vaccinations v
	ON d.location=v.location 
	AND d.date=v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3

SELECT*,(rolling_vaccinations/population) *100 AS rolling_percentage
FROM #percent_population_vaccinated



--CFEATE VIEW for futher visual analysis

CREATE VIEW percent_population_vaccinations AS
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS rolling_vaccinations
FROM [Portfolio Project]..covid_deaths d
JOIN [Portfolio Project]..covid_vaccinations v
	ON d.location=v.location 
	AND d.date=v.date
WHERE d.continent IS NOT NULL;

SELECT*
FROM percent_population_vaccinations ;