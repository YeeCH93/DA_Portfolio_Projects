/* Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Select everything
SELECT *
FROM covid_deaths
ORDER BY 3, 4;

SELECT *
FROM covid_vaccinations
ORDER BY 3, 4;

-- Select Data that we are going to be using
SELECT
	location
	, date
	, total_cases
	, new_cases
	, total_deaths
	, population
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in United States
SELECT
	location
	, date
	, total_cases
	, total_deaths
	, (total_deaths / total_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE location ILIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1, 2;	

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT
	location
	, date
	, population
	, total_cases
	, (total_cases / population) * 100 AS percent_population_infected
FROM covid_deaths
--WHERE location ILIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Countries with Highest Infection Rate compared to Population
SELECT
	location
	, population
	, MAX(total_cases) AS highest_infection_count
	, MAX((total_cases / population)) * 100 AS percent_population_infected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1, 2
ORDER BY 4 DESC NULLS LAST;
	
-- Countries with Highest Death Count per Population
SELECT
	location
	, MAX(total_deaths::int) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC NULLS LAST;
	
-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population	
SELECT
	continent
	, MAX(total_deaths::int) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC NULLS LAST;

-- GLOBAL NUMBERS
SELECT
	SUM(new_cases) AS total_cases
	, SUM(new_deaths) AS total_deaths
	, (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT
	cd.continent
	, cd.location
	, cd.date
	, cd.population
	, cv.new_vaccinations
	, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
	--, (SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) / cd.population) * 100 AS vaccinated_percentage
FROM covid_deaths AS cd 
JOIN covid_vaccinations AS cv
		ON cd.location = cv.location
	   AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3;

-- Using CTE to perform Calculation on Partition By in previous query
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
	(
	SELECT
		cd.continent
		, cd.location
		, cd.date
		, cd.population
		, cv.new_vaccinations
		, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
		--, (SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) / cd.population) * 100 AS vaccinated_percentage
	FROM covid_deaths AS cd 
	JOIN covid_vaccinations AS cv
			ON cd.location = cv.location
	   	AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL
	--ORDER BY 2, 3	
	)
SELECT 
	*
	, (rolling_people_vaccinated / population) * 100 AS vaccinated_percentage
FROM pop_vs_vac;

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS percent_pop_vac ;
CREATE TEMPORARY TABLE percent_pop_vac (
	continent varchar
	, location varchar
	, date date
	, population numeric
	, new_vaccinations numeric
	, rolling_people_vaccinated numeric
);

INSERT INTO percent_pop_vac
SELECT
	cd.continent
	, cd.location
	, cd.date
	, cd.population
	, cv.new_vaccinations
	, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
	--, (SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) / cd.population) * 100 AS vaccinated_percentage
FROM covid_deaths AS cd 
JOIN covid_vaccinations AS cv
		ON cd.location = cv.location
	   AND cd.date = cv.date;
--WHERE cd.continent IS NOT NULL
--ORDER BY 2, 3

SELECT 
	*
	, (rolling_people_vaccinated / population) AS vaccinated_percentage
FROM percent_pop_vac;

-- Creating View to store data for later visualizations
CREATE VIEW percent_pop_vac AS
SELECT
	cd.continent
	, cd.location
	, cd.date
	, cd.population
	, cv.new_vaccinations
	, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
	--, (SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) / cd.population) * 100 AS vaccinated_percentage
FROM covid_deaths AS cd 
JOIN covid_vaccinations AS cv
		ON cd.location = cv.location
	   AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;

SELECT 
	*
	, (rolling_people_vaccinated / population) AS vaccinated_percentage
FROM percent_pop_vac;










	
	
	
	
	
	
	
	
	