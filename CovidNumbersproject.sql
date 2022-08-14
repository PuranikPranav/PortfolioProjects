Select * 
from [Covid Deaths]
order by 3,4

--Select * 
--from [Covid Vaccinations]
--order by 3,4

 
Select Location, date, total_cases, new_cases, total_deaths, population
from [Covid Deaths]
order by 1,2

--Approximate Mortality Rate of Covid in India 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS MortalityRate
from [Covid Deaths]
where location = 'India'
order by 1,2	

--Total cases vs Population
--Percentage of people who got Covid
Select Location, date, Population, total_cases, (total_cases/population)*100 AS PercentAffected
from [Covid Deaths]
where location = 'India'
order by 1,2

--Countries with highest PercentAffected compared to population
Select Location, population, Max(total_cases) as total_infection_count, Max((total_cases/population))*100 as PercentAffected
from [Covid Deaths]
group by location,population
order by PercentAffected desc


--Countries with highest Death Count
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from [Covid Deaths]
where continent is not null
group by location
order by TotalDeathCount desc


--Continents with highest death count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from [Covid Deaths]
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Covid Deaths]
where continent is not null
group by date
order by 1,2	

--Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.Date) AS RollingPeopleVaccinated
From [Covid Deaths] dea
join [Covid Vaccinations] vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) 
as

(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.Date) AS RollingPeopleVaccinated
From [Covid Deaths] dea
join [Covid Vaccinations] vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.Date) AS RollingPeopleVaccinated
From [Covid Deaths] dea
join [Covid Vaccinations] vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated