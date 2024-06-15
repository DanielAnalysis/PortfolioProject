

Select *
From PortfolioProject..[CovidDeaths  ]
Order By 3,4


--Select *
--From PortfolioProject..[CovidVaccinations]  
--Order By 3,4


--total_case VS total_deaths
Select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..[CovidDeaths  ]
Where location like '%states%'
Order By 1,2


--total_cases VS population
Select location, date,population,total_cases,(total_cases/population)*100 as PercentofPopulationInfected
From PortfolioProject..[CovidDeaths  ]
Where location like '%states%'
Order By 1,2



--coutries with highest infection rate compared to population
Select location,population,Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentofPopulationInfected
From PortfolioProject..[CovidDeaths  ]
Where location like '%oceania%'
Group by location,population 
Order By PercentofPopulationInfected desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--Highest death counts by continent

Select continent,Max(cast(total_deaths as int)) as TotalDeathsCount 
From PortfolioProject..[CovidDeaths  ]
--Where location like '%nigeria%'
where continent is not null
Group by continent  
Order By TotalDeathsCount desc


--Global Numbers

Select sum(new_cases)as total_cases ,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases)  *100 as DeathPercentage
From PortfolioProject..[CovidDeaths  ]
--Where location like '%states%'
where continent is not null
--group by date
Order By 1,2



--Total Population VS Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.Date)  RollingPeopleVaccinated
From PortfolioProject..[CovidDeaths  ] dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3



--Using CTE

With PopvsVac  (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.Date)  RollingPeopleVaccinated
From PortfolioProject..[CovidDeaths  ] dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100  PerentageofRPVacvsPop
From PopvsVac


--Using Temp

Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.Date)  RollingPeopleVaccinated
From PortfolioProject..[CovidDeaths  ] dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated



--CREATING VIEW To Store Data For Later Presentation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.Date)  RollingPeopleVaccinated
From PortfolioProject..[CovidDeaths  ] dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated