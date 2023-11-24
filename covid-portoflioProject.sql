
----1
select location ,date ,total_cases ,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths 

where continent is not null

order by 1,2

 
--2

-- looking at total cases vs total deaths
--show likehood of dying if you contract covid in your country

select location ,date ,total_cases ,new_cases, total_deaths,(total_deaths /  total_cases) *100 as DeathPresntage , population
from PortfolioProject..CovidDeaths 

where location like '%states%' and continent is not null

order by 1,2


-- looking at total cases vs Population

--show likehood of dying if you contract covid in your country

select location ,date , population, total_cases,(  total_cases /population) *100 as PrecentPupulationInfaction
from PortfolioProject..CovidDeaths 

where location like '%states%' and continent is not null

order by 1,2


--looking at countries with highest infecation Rate  compare to Population 



 
select location  , population , MAX( total_cases) as HighestInfactionCount, MAX((  total_cases /population)) *100 as PrecentPupulationInfaction
from PortfolioProject..CovidDeaths 

--where location like '%states%' and continent is not null

group by location,population 

order by PrecentPupulationInfaction desc




 
 --showing countries with highest Death Count per Population


select location  , population , MAX( cast (total_deaths as int)) as HighestInfactionCount, MAX(( cast( total_deaths  as int )/population)) *100 as PrecentPupulationDeath
from PortfolioProject..CovidDeaths 

--where location like '%states%' and continent is not null

group by location,population 


order by HighestInfactionCount desc


-- let`s brack things  down by continent

--showing continents with the highest death count per population  


select continent   , MAX( cast (total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths 

where  continent is not null

group by continent 
order by HighestDeathCount desc



-- Global Numbers max

select date   , MAX( cast (total_deaths as int)) as HighestDeathCount  
from PortfolioProject..CovidDeaths 

where  continent is not null

group by date 
order by HighestDeathCount desc 




-- Global Numbers sum

select date   , sum(new_cases), sum( cast (new_deaths as int)) as HighestDeathCount  
from PortfolioProject..CovidDeaths 

where  continent is not null

group by date 
order by 1,2


-- Global Numbers sum

select date   , sum(new_cases) as total_cases, sum( cast (new_deaths as int)) as total_death  , sum (cast( new_deaths as int)) / SUM(new_cases) *100  as DeathPresentage  
from PortfolioProject..CovidDeaths 
where  continent is not null
group by date 
order by 1,2


-- Global Numbers sum / total over all

select     sum(new_cases) as total_cases, sum( cast (new_deaths as int)) as total_death  , sum (cast( new_deaths as int)) / SUM(new_cases) *100  as DeathPresentage  
from PortfolioProject..CovidDeaths 
where  continent is not null
--group by date 
order by 1,2


select *

from PortfolioProject..CovidVaccinations$




-- looking at total population vs vaccinations




select dea.location,dea.continent,dea.date, population , vac.new_vaccinations ,
SUM ( convert(int, vac.new_vaccinations)) over (partition by  dea.location ) as RoolingPeapleVaccined

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations$ vac
   on dea.date = vac.date
   and dea.location =vac.location
where dea.continent is not null

--order by 2,3


select dea.location,dea.continent,dea.date, population , vac.new_vaccinations ,
SUM ( convert(int, vac.new_vaccinations)) over (partition by  dea.location order by dea.location , dea.date ) as RoolingPeapleVaccined
--, (RoolingPeapleVaccined/Population)*100

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations$ vac
   on dea.date = vac.date
   and dea.location =vac.location
where dea.continent is not null

order by 2,3


--using CTE 


with PopvsVac (Continent,Location,Date ,Population,New_Vaccinations,RoolingPeapleVaccined)
as 
(
select  dea.continent ,dea.location,dea.date, population , vac.new_vaccinations ,
SUM ( convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date  ) as RoolingPeapleVaccined

--, (RoolingPeapleVaccined/Population)*100


from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations$ vac
   on dea.date = vac.date
   and dea.location =vac.location
where dea.continent is not null
order by 2,3
)
select * , (RoolingPeapleVaccined/Population)*100
from PopvsVac



--Temp table


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


insert into #PercentPopulationVaccinated

select  dea.continent ,dea.location,dea.date, population , vac.new_vaccinations ,
SUM ( convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date  ) as RoolingPeapleVaccined

--, (RoolingPeapleVaccined/Population)*100


from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations$ vac
   on dea.date = vac.date
   and dea.location =vac.location
where dea.continent is not null
--order by 2,3


select * ,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--creating view to store data for later visualizations

create view PercentPopulationVaccinated‎ as 

select  dea.continent ,dea.location,dea.date, population , vac.new_vaccinations ,
SUM ( convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date  ) as RoolingPeapleVaccined

--, (RoolingPeapleVaccined/Population)*100


from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations$ vac
   on dea.date = vac.date
   and dea.location =vac.location
where dea.continent is not null


