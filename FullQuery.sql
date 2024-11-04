-- REFORMATTING AFTER DATA IMPORT USING PYTHON
SET SQL_SAFE_UPDATES = 0;

UPDATE new_covidvaccinefull
SET date = STR_TO_DATE(CONCAT(
    SUBSTRING(date, 1, 2), '-', 
    SUBSTRING(date, 4, 2), '-', 
    SUBSTRING(date, 7, 4)
), '%d-%m-%Y');

SET SQL_SAFE_UPDATES = 1;

-- SHOWING CONTINENT WITH MAX DEATHS
SELECT Continent, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathsCount FROM coviddeaths
WHERE Continent is not null
GROUP BY Continent
ORDER BY TotalDeathsCount DESC;

-- DEATHS PERCENTAGE BASED ON DATE
SELECT Date, SUM(new_cases) AS TotalCase, SUM(new_deaths) AS TotalDeaths , (SUM(new_deaths)/SUM(new_cases))*100 AS deathPercentage
FROM coviddeaths
WHERE Continent is not null
GROUP BY Date
ORDER BY 1,4 ASC;

-- DEATHS PERCENTAGE BASED ON LOCATION
SELECT Location, SUM(new_cases) AS TotalCase, SUM(new_deaths) AS TotalDeaths , (SUM(new_deaths)/SUM(new_cases))*100 AS deathPercentage
FROM coviddeaths
WHERE Continent is not null
GROUP BY Location
ORDER BY 4 DESC;

-- TOTAL DEATHS PERCENTAGE
SELECT SUM(new_cases) AS TotalCase, SUM(new_deaths) AS TotalDeaths , (SUM(new_deaths)/SUM(new_cases))*100 AS deathPercentage
FROM coviddeaths
WHERE Continent is not null;

-- JOIN 2 TABLE
SELECT * FROM coviddeaths AS cd
JOIN covidvaccine AS cv
	ON cd.location = cv.location
    AND cd.date = cv.date;
    
-- HOW MANY PPL VACINATED? GROUP BY LOCATION
SELECT 	cd.continent, 
		cd.location, 
		cd.date, cd.population, 
        cv.new_vaccinations, 
        (SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)) AS totalVaccinations
FROM coviddeaths AS cd
JOIN covidvaccine AS cv
	ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.Continent is not null
ORDER BY cd.location, cd.date;

-- Using CTE COMMON TABLE EXPRESSION
WITH PopulationVSVaccination (Continent, Location, Date, Population, NewVaccinations, totalVaccinations)
AS
(
SELECT 	cd.continent, 
		cd.location, 
		cd.date, cd.population, 
        cv.new_vaccinations, 
        (SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)) AS totalVaccinations
FROM coviddeaths AS cd
JOIN covidvaccine AS cv
	ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.Continent is not null
-- ORDER BY cd.location, cd.date
) SELECT *, totalVaccinations/Population as VaccinationsPercentage FROM PopulationVSVaccination;

-- CREATE VIEW
CREATE VIEW PercentPopulationVaccinated AS
SELECT 	cd.continent, 
		cd.location, 
		cd.date, cd.population, 
        cv.new_vaccinations, 
        (SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)) AS totalVaccinations
FROM coviddeaths AS cd
JOIN covidvaccine AS cv
	ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.Continent is not null;

-- INTERACT WITH VIEW
SELECT * FROM PercentPopulationvaccinated;




