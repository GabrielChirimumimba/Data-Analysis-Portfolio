Select *
From [Portfolio Project]..CovidDeaths
order by 3,4

--Select * 
--From [Portfolio Project]..[covid-vaccinations]
--order by 3,4

Select Location, date, total_cases_per_million, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Order by 1,2

--Looking at Total Deaths vs country
--shows Likely hood of death in each country
Select Location, total_deaths, (total_deaths/population)*100 as DeathPercentage 
From [Portfolio Project]..CovidDeaths
Order by 1,2

-- Ranking Countries by for Highest DeathCount
Select location, MAX(cast(total_deaths_per_million as float)) as HighestDeathCount
From [Portfolio Project]..CovidDeaths
Group By location
order by 2 desc

--Ranking by Continent

 Select location, MAX(cast(total_deaths_per_million as float)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is null
Group By location
order by 2 desc

--Global Numbers, Daily case and Death Count

 Select date, SUM(cast(new_deaths_smoothed_per_million as float)) as DailyDeathCount, SUM(cast(new_cases_smoothed_per_million as float)) as NewCases,
      (SUM(cast(new_deaths_smoothed_per_million as float))/ SUM(cast(new_cases_smoothed_per_million as float)))*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null
Group By date
order by 1, 2 desc

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT,vac.new_vaccinations_smoothed)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaccinations
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..[covid-vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 1, 2, 3

--USE CTE

with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT,vac.new_vaccinations_smoothed)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaccinations
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..[covid-vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)
Select*, (RollingPeopleVaccinated/Population)*100
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

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT,vac.new_vaccinations_smoothed)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaccinations
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..[covid-vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT,vac.new_vaccinations_smoothed)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaccinations
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..[covid-vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select*
From PercentPopulationVaccinated