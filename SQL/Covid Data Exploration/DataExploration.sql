-- Looking at all of the data from CovidDeaths.csv
Select *
From coviddeaths
Order by 3,4;

--Selecting Data that we are using
Select location, date, total_cases, new_cases, total_deaths, population
From coviddeaths
Where continent !=''
Order by 1,2;

-- Looking at total_cases vs total_deaths
-- This shows the likelihood of death from contracting COVID in Canada
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRatio
From coviddeaths
Where location = 'Canada'
and continent !=''
Order by 1,2;

-- Looking at toal cases vs population
-- Shows Percentage of population that got Covid in Canada
Select location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
From coviddeaths
Where location = 'Canada'
and continent !=''
Order by 1,2;

-- Looking at which countries have the highest infection rate
Select location, Max(total_cases) as MostInfected, population,  Max((total_cases)/population)*100 as InfectionPercentage
From coviddeaths
Where continent !=''
Group by location, population
Order by InfectionPercentage desc;

-- Showing countries with highest death count per country
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From coviddeaths
Where continent !=''
Group by location
Order by TotalDeathCount desc;

-- Now for continents
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From coviddeaths
Where continent =''
Group by location
Order by TotalDeathCount desc;

--Global Numbers
Select sum(new_cases) as TotalCases, Sum(Cast(new_deaths as int))as TotalDeaths, (Sum(Cast(new_deaths as int))/sum(new_cases))*100 as DeathRatio
From coviddeaths
Where continent !='';

Select date, sum(new_cases) as TotalCases, Sum(Cast(new_deaths as int))as TotalDeaths, (Sum(Cast(new_deaths as int))/sum(new_cases))*100 as DeathRatio
From coviddeaths
Where continent !=''
GROUP BY date
Order by 1,2;

--Now look at CovidVaccinations data
Select *
From covidvaccinations
Order by 3,4;

--Joining both tables together
Select *
From coviddeaths as deaths
join covidvaccinations as vac
    on deaths.location = vac.location
    and deaths.date = vac.date;

--Looking at total population vs vaccinations
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
From coviddeaths as deaths
join covidvaccinations as vac
    on deaths.location = vac.location
    and deaths.date = vac.date
Where deaths.continent != ''
order by 2,3;

-- Count of total vaccinations that have been completed each day
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
        sum(cast(vac.new_vaccinations as int)) Over 
        (PARTITION BY deaths.location order by deaths.location and deaths.date) as VaccinationsToDate
From coviddeaths as deaths
join covidvaccinations as vac
    on deaths.location = vac.location
    and deaths.date = vac.date
Where deaths.continent != ''
order by 2,3;

-- Count of total vaccinations that have been completed each day using CTE
With PopvsVac (continent, location, date, population, new_vaccinations, VaccinationsToDate)
as (
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
        sum(cast(vac.new_vaccinations as int)) Over 
        (PARTITION BY deaths.location order by deaths.location, deaths.date) as VaccinationsToDate
From coviddeaths as deaths
join covidvaccinations as vac
    on deaths.location = vac.location
    and deaths.date = vac.date
Where deaths.continent != '')

Select *, (VaccinationsToDate/population)*100
From PopvsVac;

-- Count of total vaccinations that have been completed each day using Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population INT,
    New_Vaccinations INT,
    VaccinationsToDate INT
)
INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT)) OVER 
        (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS VaccinationsToDate
FROM coviddeaths AS deaths
JOIN covidvaccinations AS vac
    ON deaths.location = vac.location
    AND deaths.date = vac.date
WHERE deaths.continent != ''
SELECT *, (VaccinationsToDate / population) * 100
FROM #PercentPopulationVaccinated;

-- Creating View to store data for other visualizations
Create view PercentPopVaccinated AS
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
        sum(cast(vac.new_vaccinations as int)) Over 
        (PARTITION BY deaths.location order by deaths.location and deaths.date) as VaccinationsToDate
From coviddeaths as deaths
join covidvaccinations as vac
    on deaths.location = vac.location
    and deaths.date = vac.date
Where deaths.continent != '';

--Seeing the view
Select *
From PercentPopVaccinated
