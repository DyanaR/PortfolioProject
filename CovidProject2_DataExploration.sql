--UNITED STATES

--Total Cases vs Total Deaths Per Day
	--Shows likelihood of dying if you contract covid in the United States
SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as Death_Percentage 
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--GLOBAL NUMBERS

--Total Amount of Cases vs Death vs Population
	--shows global count of cases and deaths, and death percentage
SELECT sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, 
	round(max(new_deaths/population)*100,2) as Death_Percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null

--Cases vs Population Per Day
	--Shows what percentage of population got Covid
SELECT location, date, population, total_cases, round((total_cases/population)*100,2) as Percentage_of_Pop_Infected
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Cases vs Deaths Per Day
	--Shows likelihood of dying if you contract covid
SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as Death_Percentage 
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Total Vaccinations 
SELECT sum(cast(new_vaccinations as bigint)) as Total_Vaccinations 
FROM PortfolioProject.dbo.CovidVac
WHERE continent is not null

--Vaccinations vs Population Per Day 
	--Shows Rolled Count of Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidVac vac
join PortfolioProject.dbo.CovidDeaths dea 
ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Total Deaths per Continent 
SELECT continent, sum(cast(new_deaths as bigint)) as Total_Death
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY sum(cast(new_deaths as bigint)) desc

--Infection Count per Continent 
SELECT continent, max(population) as Population, sum(new_cases) as HighestInfectionCount, 
	round(max(new_cases/population)*100,2) as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY PercentPopulationInfected desc

--Top 10 Countries with High Infection Rate per Population
SELECT location, population, max(total_cases) as HighestInfectionCount, 
	round(max(total_cases/population)*100,2) as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestInfectionCount desc
offset 0 rows
FETCH next 10 rows only

--Every Countries Highest Infection Count and Percentage of Population Infected
SELECT location, population, max(total_cases) as HighestInfectionCount, 
	round(max(total_cases/population)*100,2) as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
GROUP BY location, population

--Every Countries Death Count and Percentage in 2021- DONE
SELECT location, population,date, sum(cast(new_deaths as bigint)) as DeathCount
	--round(sum(new_deaths/population)*100,2) as PercentPopulationDeath
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
and date between '2021-01-01' and '2021-12-31'
GROUP BY date, location, population


--Percantge of People Vaccinated per Location - Using CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidVac dea
join PortfolioProject..CovidVac vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentageRollingPeopleVaccinated
FROM PopvsVac


