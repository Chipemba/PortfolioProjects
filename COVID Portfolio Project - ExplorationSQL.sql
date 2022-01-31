/*
Covid 19 Data Exploration
*/

-----------------------------------------------------------------------------------

Select *
From PortfolioProjects.dbo.covid_deaths
where continent is not null
Order By 3,4;


-----------------------------------------------------------------------------------

--Select data that will be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects.dbo.covid_deaths
Order By 1,2;

-----------------------------------------------------------------------------------
-- Total cases vs Total deaths
-- Shows likelihood of death 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProjects.dbo.covid_deaths
Where location like 'CANADA'
AND continent is not null
Order By 1,2;


-----------------------------------------------------------------------------------

-- Total cases vs Population
-- Shows percentage of population infected

Select location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
From PortfolioProjects.dbo.covid_deaths
Where location like 'Zambia'
AND continent is not null
Order By 1,2;

-- ***Found discrepancy in the data for the first 9 rolls of the above query . Data cleaning required.


-----------------------------------------------------------------------------------

-- Countries with high infection rate compared to population

Select location, population, MAX(total_cases) AS HighestInfectCount, MAX((total_cases/population))*100 AS InfectedPopulationPercentage
From PortfolioProjects.dbo.covid_deaths
Group By location, population
Order By InfectedPopulationPercentage desc;


-----------------------------------------------------------------------------------

-- Countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProjects.dbo.covid_deaths
WHERE continent is not null
Group By location
Order By TotalDeathCount desc;

-----------------------------------------------------------------------------------

-- Death count by Continent the right way 

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProjects.dbo.covid_deaths
WHERE continent is null
AND location not like '%income%'
Group By location
Order By TotalDeathCount desc;


-----------------------------------------------------------------------------------

--Death count by continent the uniform way

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProjects.dbo.covid_deaths
WHERE continent is not null
AND location not like '%income%'
Group By continent
Order By TotalDeathCount desc;

-----------------------------------------------------------------------------------

--Global numbers

Select SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProjects.dbo.covid_deaths
Where continent is not null
--Group By date
Order By 1,2;


-----------------------------------------------------------------------------------

-- Total population of vaccinated.

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by death.location Order By death.location, death.date) AS CountingVacs--, (CountingVacs/population)*100
From PortfolioProjects.dbo.covid_deaths death
join PortfolioProjects.dbo.covid_vaccinations vac
On death.location = vac.location
And death.date = vac.date
Where death.continent is not null
Order By 2,3;

-----------------------------------------------------------------------------------

--Using CTE to save temp result

With popvsVac (continent, location, date, population, new_vaccinations, countingVacs) As(
	Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by death.location Order By death.location, death.date) AS CountingVacs
	From PortfolioProjects.dbo.covid_deaths death
	join PortfolioProjects.dbo.covid_vaccinations vac
	On death.location = vac.location
	And death.date = vac.date
	Where death.continent is not null
)
Select *,(CountingVacs/population)*100
From popvsVac