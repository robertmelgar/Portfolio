/* Queries used for Tableau Covid Project 

NOTE: Queries were run in Google's BigQuery in order to filter the data*/

-- 1
-- Total Cases, Total deaths and death percentage (World) 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM `sandbox-projects-367614.portfolioproject.coviddeaths`
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- 2
-- Getting total deaths by location:
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM `sandbox-projects-367614.portfolioproject.coviddeaths`
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 3.
-- Showing Highest Infection Count, Percentage Infection vs Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM `sandbox-projects-367614.portfolioproject.coviddeaths`
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 4.
-- Showing Highest Infection Count, Percentage Infection vs Population Grouped by date
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM `sandbox-projects-367614.portfolioproject.coviddeaths`
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc






-- ADDITIONAL QUERIES USED TO EXPLORE THE DATA:

-- Generating a count of all people vaccinated as date increases in order to show Graphs (RollingPeopleVaccinated)
Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM `sandbox-projects-367614.portfolioproject.coviddeaths` as dea
JOIN `sandbox-projects-367614.portfolioproject.covidvaccinations` as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3



-- USING CTEs
With PopvsVac
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM `sandbox-projects-367614.portfolioproject.coviddeaths` as dea
JOIN `sandbox-projects-367614.portfolioproject.covidvaccinations` as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac
