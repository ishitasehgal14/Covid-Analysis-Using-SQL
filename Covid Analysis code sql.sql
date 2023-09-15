SELECT
 location,
 date,
 total_cases,
 new_cases,
 total_deaths
 population
FROM
 CovidDeaths
ORDER BY
 location, 
 date

-- Total Cases vs Total Deaths
SELECT
 location,
 date,
 total_cases,
 total_deaths,
 ROUND((total_deaths / total_cases) * 100,2) as death_percentage
FROM
 CovidDeaths
ORDER BY
 location,
 date

 -- Total Cases vs Total deaths in India
 SELECT
 location,
 date,
 total_cases,
 total_deaths,
 ROUND((total_deaths / total_cases) * 100,2) as death_percentage
FROM
 CovidDeaths
WHERE
 location LIKE '%india%'
ORDER BY
 location,
 date

-- Total Cases vs the Population
SELECT
 location,
 date,
 total_cases,
 population,
 ROUND((total_cases / population) * 100,2) as case_percentage
FROM
 CovidDeaths
ORDER BY
 location,
 date

-- Total Cases vs Population in India
SELECT
 location,
 date,
 total_cases,
 population,
 ROUND((total_cases / population) * 100,2) as case_percentage
FROM
 CovidDeaths
WHERE
 location LIKE '%india%'
ORDER BY
 location,
 date

-- Country with highest infection rate pre population
SELECT
 location,
 MAX(total_cases) as highest_count,
 population,
 MAX(ROUND((total_cases / population) * 100,2)) as infection_percentage
FROM
 CovidDeaths
GROUP BY
 population,
 location
ORDER BY
 infection_percentage DESC

-- Highest death count per population
SELECT
 location,
 MAX(total_deaths) as total,
 population,
 MAX(ROUND((total_deaths / population) * 100, 2)) as death_count
FROM 
 CovidDeaths
GROUP BY 
 location,
 population
ORDER BY 
 death_count DESC

-- Highest death count by country
SELECT
 location,
 MAX(CAST(total_deaths as int)) as death_total
FROM
 CovidDeaths
WHERE 
 continent IS NOT NULL
GROUP BY 
 location
ORDER BY
 death_total DESC

-- Highest death count by continent
SELECT
 location,
 MAX(CAST(total_deaths as int)) as death_total
FROM
 CovidDeaths
WHERE 
 continent IS NULL
GROUP BY 
 location
ORDER BY
 death_total DESC

 -- Highest death count per population by continent
 SELECT
 continent,
 MAX(ROUND((total_deaths / population) * 100, 2)) as death_per_population
FROM
 CovidDeaths
WHERE 
 continent IS NOT NULL
GROUP BY 
 continent
ORDER BY
 death_per_population DESC

-- New cases by day
SELECT
 date, SUM(new_cases) as cases_total
FROM
 CovidDeaths
GROUP BY 
 date
ORDER BY
 date, 
 cases_total

-- Global numbers
SELECT
 date,
 SUM(new_cases) as cases_total,
 SUM(CAST(new_deaths as INT)) as death_total 
FROM
 CovidDeaths
WHERE 
 continent IS NOT NULL 
GROUP BY 
 date

 -- New Death Percentage
SELECT
 date,
 SUM(new_cases) as case_total,
 SUM(CAST(new_deaths as INT)) as death_total,
 SUM(CAST(new_deaths as INT)) / SUM(new_cases) as death_percentage
FROM
 CovidDeaths 
WHERE
 continent IS NOT NULL
GROUP BY
 date

-- Exploring the Covid vaccinations table
SELECT
 *
FROM 
 CovidVaccinations

-- Joining the two tables
SELECT
 *
FROM
 CovidDeaths as dea
INNER JOIN CovidVaccinations as vac ON 
dea.location = vac.location AND
dea.date = vac.date

-- Total population vs total vaccinations
SELECT
 dea.continent, 
 dea.location, 
 dea.date, 
 dea.population, 
 SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as roll_vaccinations
FROM
 CovidDeaths as dea
INNER JOIN CovidVaccinations as vac ON 
dea.location = vac.location AND
dea.date = vac.date
WHERE
 dea.continent IS NOT NULL
ORDER BY
 dea.location,
 dea.date

-- Using CTE
WITH PopVsVac(continent, location, date, population,roll_vaccinations) AS (
SELECT
 dea.continent, 
 dea.location, 
 dea.date, 
 dea.population, 
 SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as roll_vaccinations
FROM
 CovidDeaths as dea
INNER JOIN CovidVaccinations as vac ON 
dea.location = vac.location AND
dea.date = vac.date
WHERE
 dea.continent IS NOT NULL
 )

SELECT
 *,
 (roll_vaccinations / population) * 100 as vac_percent
FROM
 PopVsVac

-- Create View
CREATE VIEW vaccination_central AS (
SELECT
 dea.continent, 
 dea.location, 
 dea.date, 
 dea.population, 
 SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as roll_vaccinations
FROM
 CovidDeaths as dea
INNER JOIN CovidVaccinations as vac ON 
dea.location = vac.location AND
dea.date = vac.date
WHERE
 dea.continent IS NOT NULL
 )