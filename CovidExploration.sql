SELECT *
FROM PortfolioProject..Covid_Deaths
ORDER BY 3,4


--Posibility of dying if contract covid-19, percentage of population caught Covid

SELECT 
    Location, date, total_cases, total_deaths, population,
	(CONVERT(DECIMAL(15),total_deaths)/CONVERT(DECIMAL(15),total_cases))*100 AS DeathPercentage,
	(CONVERT(DECIMAL(15),total_cases)/CONVERT(DECIMAL(15),population))*100 AS CovidPercentage
FROM 
    PortfolioProject..Covid_Deaths
WHERE location = 'Japan'
ORDER BY 1,2



-- Infection Rate compared to population by location

SELECT 
      a.location, MAX(a.population) AS Latest_Population, 
	  MAX(a.case_count) AS Infection_Count,
	  MAX(a.death_count) AS Death_Count,
      MAX(a.case_count/a.population)*100 AS Infection_Rate ,
      MAX(a.death_count/a.population)*100 AS Death_Rate 
FROM (SELECT 
         Location, CONVERT(DECIMAL(15),total_cases) AS case_count, 
	     CONVERT(DECIMAL(15),total_deaths) AS death_count, population
	  FROM 
	     PortfolioProject..Covid_Deaths
	  WHERE continent IS NOT NULL) AS a
GROUP BY 
     a.location
ORDER BY Infection_Count Desc


-- Breaking down by continent

SELECT 
    continent, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM 
    PortfolioProject..Covid_Deaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY Total_Death_Count desc


-- Global Numbers

SELECT
    SUM(new_cases) AS total_number, SUM(new_deaths) AS total_death, 
    SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..Covid_Deaths
WHERE continent IS NOT NULL 
--GROUP BY date
--ORDER BY 1,2


-- Total Population vs Vaccinations

SELECT 
   d.continent, d.location, d.date, d.population, v.new_vaccinations,
   SUM(CAST(v.new_vaccinations AS Decimal)) 
      OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS vaccinated
FROM 
   PortfolioProject..Covid_Vaccinations V 
   FULL JOIN  PortfolioProject..Covid_Deaths D
       ON d.location = v.location AND 
	      d.date = v.date
WHERE d.continent IS NOT NULL 
ORDER BY 2,3


-- CTE practice

WITH Population_Vaccination (continent, location, date, population, new_vaccinations, vaccinated)
AS
(
SELECT 
   d.continent, d.location, d.date, d.population, v.new_vaccinations,
   SUM(CAST(v.new_vaccinations AS Decimal)) 
      OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS vaccinated
FROM 
   PortfolioProject..Covid_Vaccinations V 
   FULL JOIN  PortfolioProject..Covid_Deaths D
       ON d.location = v.location AND 
	      d.date = v.date
WHERE d.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (vaccinated/population)*100 AS vaccinated_percentage
FROM Population_Vaccination


-- Temp Table

DROP TABLE IF EXISTS #populationvaccinated
CREATE TABLE #populationvaccinated
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccinated numeric)

INSERT INTO #populationvaccinated
SELECT 
   d.continent, d.location, d.date, d.population, v.new_vaccinations,
   SUM(CAST(v.new_vaccinations AS Decimal)) 
      OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS vaccinated
FROM 
   PortfolioProject..Covid_Vaccinations V 
   FULL JOIN  PortfolioProject..Covid_Deaths D
       ON d.location = v.location AND 
	      d.date = v.date
WHERE d.continent IS NOT NULL 

SELECT *, (vaccinated/population)*100 AS vaccinated_percentage
FROM #populationvaccinated


-- For visualization later
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
   d.continent, d.location, d.date, d.population, v.new_vaccinations,
   SUM(CAST(v.new_vaccinations AS Decimal)) 
      OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS vaccinated
FROM 
   PortfolioProject..Covid_Vaccinations V 
   FULL JOIN  PortfolioProject..Covid_Deaths D
       ON d.location = v.location AND 
	      d.date = v.date
WHERE d.continent IS NOT NULL 