/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject1.coviddeaths
Where continent is not null
order by 3,4;

-- Select Data that we are going to be starting with

SELECT location, date, new_cases, total_cases, total_deaths, population
FROM PortfolioProject1.coviddeaths
order by 1,2;

-- Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, new_cases, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject1.coviddeaths
Where location like '%states%'
order by 1,2;

-- Looking at Total cases vs Population
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject1.coviddeaths
-- Where location like '%states%'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population

SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject1.coviddeaths
-- Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths as unsigned)) as TotalDeathCount
FROM PortfolioProject1.coviddeaths
-- Where location like '%states%'
Where continent IS NOT NULL 
group by location
order by TotalDeathCount desc;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as unsigned)) as TotalDeathCount
FROM PortfolioProject1.coviddeaths
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as unsigned)) as total_deaths, SUM(cast(new_deaths as unsigned))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject1.coviddeaths
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations,unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject1.coviddeaths dea
Join PortfolioProject1.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations,unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject1.coviddeaths dea
Join PortfolioProject1.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations,unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject1.coviddeaths dea
Join PortfolioProject1.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null 
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations,unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1.coviddeaths dea
Join PortfolioProject1.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;









