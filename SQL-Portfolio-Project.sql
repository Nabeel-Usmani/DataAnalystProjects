--Select *
--From PortfolioProject..CovidDeaths$
--where continent is not null
--order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4 

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths 
Select location,date,(total_cases),(total_deaths),(cast (total_deaths as int)/cast (total_cases as int))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
--and continent is not null
order by 1,2

--Total Cases vs Population
Select location,date,total_cases,population, (total_cases/population)*100 as TotalCasesPopulation 
From PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2


-- Countries with Highest Infection Rate vs Population
Select location,MAX (total_cases) AS HIGHESTCASERATE,population, MAX ((total_cases/population))*100 as PopulationInfected 
From PortfolioProject..CovidDeaths$
where continent is not null
group by location,population
order by PopulationInfected desc

-- Countries with most death ratio
Select location,MAX (cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- Breaking things down with Continents
Select continent, MAX (cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

Select date,SUM(new_cases) as NewCasesPerDay, Sum (cast (new_deaths as int)) as NewDeathsPerDay,Sum (cast (new_deaths as int))/SUM(New_Cases)*100 as DeathPercentagePerDay --, total_deaths,(cast (total_deaths as int)/cast (total_cases as int))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
and new_cases != 0 
group by date
order by 1,2

-- Overall Cases and DeathRatio based on the current dataset
Select SUM(new_cases) as Cases, Sum (cast (new_deaths as int)) as Deaths,Sum (cast (new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
and new_cases != 0 
order by 1,2

-- Total Population & Vaccinated Population
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, Sum(Convert (int, CV.new_vaccinations)) OVER (Partition By CD.location, CD.date) as TotalVaccinated
From PortfolioProject..CovidDeaths$ CD
	join PortfolioProject..CovidVaccinations$ CV
	on CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null 
order by 1,2,3 

--Population vs Vaccinated People using CTEs
With PopvsVac (Continent,Location, Date, Population, New_Vaccinations, TotalVaccinated)
as
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, Sum(Convert(bigint, CV.new_vaccinations )) OVER (Partition By CD.location Order by CD.location,CD.date) as TotalVaccinated
From PortfolioProject..CovidDeaths$ CD
	join PortfolioProject..CovidVaccinations$ CV
	on CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null 
--order by 2,3
)
Select *, (TotalVaccinated/Population)*100 as VaccinatedPopulation
From PopvsVac

--Temp Table
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
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, Sum(Convert(bigint, CV.new_vaccinations )) OVER (Partition By CD.location Order by CD.location,CD.date) as TotalVaccinated
From PortfolioProject..CovidDeaths$ CD
	join PortfolioProject..CovidVaccinations$ CV
	on CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View For Data Visualization
Create View VaccinatedPopulation as
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, Sum(Convert(bigint, CV.new_vaccinations )) OVER (Partition By CD.location Order by CD.location,CD.date) as TotalVaccinated
From PortfolioProject..CovidDeaths$ CD
	join PortfolioProject..CovidVaccinations$ CV
	on CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null 