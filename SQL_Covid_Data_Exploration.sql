
--SELECT * 
--FROM CovidDeaths
--ORDER BY 3,4


--SELECT * 
--FROM CovidVaccination


-- Select the data touse
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Death Percentage From Cases By Date and Location
SELECT location, date, total_cases, total_deaths,  LEFT(ROUND((total_deaths*1.0 / total_cases)*100,2),4)+'%'   DeathPercentage
FROM CovidDeaths
WHERE location='Canada'
ORDER BY 1,2;


--Shows what percentage of population got  Covid
SELECT location, date, total_cases, population,  LEFT(ROUND((total_cases*1.0 / population)*100,2),4)+'%'   CasePercentage
FROM CovidDeaths
ORDER BY 1,2;

--Let's look at the highest infection rate
SELECT location, 
	population, 
	MAX(total_cases) HighestInfectionCount,  
	LEFT(MAX((total_cases*1.0 / population)*100),4) +'%'  CasePercentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY MAX((total_cases*1.0 / population)*100) DESC;

--Let's look at the highest death rate for countries
SELECT location, 
	population, 
	MAX(total_deaths) HighestDeathCount,  
	LEFT(MAX((total_deaths*1.0 / population)*100),4) +'%'  DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY MAX((total_deaths*1.0 / population)*100) DESC;



--Let's look at the highest death count for countries
SELECT location, 
	ISNULL(MAX(total_deaths),0) HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MAX(total_deaths) DESC


--Showing the continents with the highest death count
SELECT continent, 
	ISNULL(MAX(total_deaths),0) HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MAX(total_deaths) DESC;


-- Global numbers 
SELECT date, SUM(new_cases) TotalCases,
	SUM(new_deaths) TotalDeaths,
	SUM(new_deaths) /  SUM(new_cases)*100 DeathPercentage
FROM CovidDeaths
where  continent IS NOT NULL AND new_cases IS NOT  NULL
GROUP BY date
HAVING SUM(new_cases) >0
ORDER BY 1,2;



-- Looking  at Total Population vs. Vaccinations

-- USE CTE
WITH PopvsVac AS(
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) RollingNewVacc
FROM CovidDeaths Dea
JOIN CovidVaccination Vac
	ON Dea.location=Vac.location AND
	Dea.date=Vac.date
WHERE dea.continent IS NOT NULL 


)

-- Let's view the Vaccination Rate Each day

SELECT * , LEFT((RollingNewVacc/population),4)+'%' VaccinationRate
FROM PopvsVac
ORDER BY 1,2,3;


--Create a Viewof the result set 
CREATE VIEW vw_PercentPopulationVaccinated AS
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) RollingNewVacc
FROM CovidDeaths Dea
JOIN CovidVaccination Vac
	ON Dea.location=Vac.location AND
	Dea.date=Vac.date
WHERE dea.continent IS NOT NULL 