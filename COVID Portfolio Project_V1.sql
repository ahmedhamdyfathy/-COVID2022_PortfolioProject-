select * 
from CovidDeaths
order by 3,4;

--select * 
--from CovidVaccinations
--order by 3,4

--select data that we are going to be using
select Location , date , total_cases , new_cases , total_deaths , population
from CovidDeaths ;

--looking at total_deaths vs total_cases
-- shows likelihood of dying if you contract covid in your country
select Location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as DeathPresentage
from CovidDeaths
where Location like '%states%'
order by 1,2;

-- looking at Total Cases Vs Population
-- shows what presentage of population got covid
select Location , date , population , total_cases , (total_cases/population)*100 as DeathPresentage
from CovidDeaths
where Location like '%Egyp%'
order by 1,2;

-- looking at countries with highest infection rate compared to population 

select Location , population , max(total_cases) as highestInfection , max((total_cases/population))*100 as PrecentPopulationInfected
from CovidDeaths
--where Location like '%Egyp%'
group by location, population
order by PrecentPopulationInfected desc;

-- showing countries with highest death count per population 

select Location ,  max(convert(int,total_deaths)) as TotalDeathCount 
from CovidDeaths
--where Location like '%Egyp%'
where continent is not null
group by location
order by TotalDeathCount desc;

-- lets break things down by continent

select continent ,  max(convert(int,total_deaths)) as TotalDeathCount 
from CovidDeaths
--where Location like '%Egyp%'
where continent is not null
group by continent
order by TotalDeathCount desc;

-- showing continent with highest death count per population

select continent ,  max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths
--where Location like '%Egyp%'
where continent is not null
group by continent
order by TotalDeathCount desc;

-- global numbers

select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths ,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPrecentage 
from CovidDeaths
--where Location like '%states%'
where continent is not null 
--group by date
order by 1,2;

-- join two table CovidDeaths and CovidVaccinations

select * 
from CovidDeaths as dea
full join CovidVaccinations as vas
on dea.location = vas.location
and dea.date = vas.date;

-- looking total population vs vaccinations

select dea.continent, dea.location, dea.date , dea.population, vas.new_vaccinations 
, sum(convert(int, vas.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as par
from CovidDeaths as dea
full join CovidVaccinations as vas
on dea.location = vas.location
and dea.date = vas.date
where dea.continent is not null
order by 2,3;

-- using CTEs

with popVsvac (continent, location , date, population, new_vaccinations, par)
as (
select dea.continent, dea.location, dea.date , dea.population, vas.new_vaccinations 
, sum(convert(int, vas.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as par
from CovidDeaths as dea
full join CovidVaccinations as vas
on dea.location = vas.location
and dea.date = vas.date
where dea.continent is not null
)
select * from popVsvac;


--created temp table 
drop table if exists #prepopvac
Create Table #prepopvac(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
par numeric
)

insert into #prepopvac
select dea.continent, dea.location, dea.date , dea.population, vas.new_vaccinations 
, sum(convert(int, vas.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as par
from CovidDeaths as dea
full join CovidVaccinations as vas
on dea.location = vas.location
and dea.date = vas.date
--where dea.continent is not null

select * from #prepopvac

--create view table to store data for later visualizations

create view prepopvac as
select dea.continent, dea.location, dea.date , dea.population, vas.new_vaccinations 
, sum(convert(int, vas.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as par
from CovidDeaths as dea
full join CovidVaccinations as vas
on dea.location = vas.location
and dea.date = vas.date
where dea.continent is not null
--order by 2,3

select * from prepopvac;