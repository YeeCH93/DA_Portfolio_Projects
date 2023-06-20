-- Create table 'covid_deaths'
CREATE TABLE public.covid_deaths
(
    iso_code character varying,
    continent character varying,
    location character varying,
    date date,
    population bigint,
    total_cases numeric,
    new_cases numeric,
    new_cases_smoothed numeric,
    total_deaths numeric,
    new_deaths numeric,
    new_deaths_smoothed numeric,
    total_cases_per_million numeric,
    new_cases_per_million numeric,
    new_cases_smoothed_per_million numeric,
    total_deaths_per_million numeric,
    new_deaths_per_million numeric,
    new_deaths_smoothed_per_million numeric,
    reproduction_rate numeric,
    icu_patients numeric,
    icu_patients_per_million numeric,
    hosp_patients numeric,
    hosp_patients_per_million numeric,
    weekly_icu_admissions numeric,
    weekly_icu_admissions_per_million numeric,
    weekly_hosp_admissions numeric,
    weekly_hosp_admissions_per_million numeric
);

ALTER TABLE IF EXISTS public.covid_deaths
    OWNER to postgres;

-- Create table 'covid_vaccinations'
CREATE TABLE public.covid_vaccinations
(
    iso_code character varying,
    continent character varying,
    location character varying,
    date date,
    total_tests bigint,
    new_tests bigint,
    total_tests_per_thousand numeric,
    new_tests_per_thousand numeric,
    new_tests_smoothed numeric,
    new_tests_smoothed_per_thousand numeric,
    positive_rate numeric,
    tests_per_case numeric,
    tests_units character varying,
    total_vaccinations bigint,
    people_vaccinated bigint,
    people_fully_vaccinated bigint,
    total_boosters bigint,
    new_vaccinations numeric,
    new_vaccinations_smoothed numeric,
    total_vaccinations_per_hundred numeric,
    people_vaccinated_per_hundred numeric,
    people_fully_vaccinated_per_hundred numeric,
    new_vaccinations_smoothed_per_million integer,
    new_people_vaccinated_smoothed integer,
    new_people_vaccinated_smoothed_per_hundred numeric,
    stringency_index numeric,
    population_density numeric,
    median_age numeric,
    aged_65_older numeric,
    aged_70_older numeric,
    gdp_per_capita numeric,
    extreme_poverty numeric,
    cardiovasc_death_rate numeric,
    diabetes_prevalence numeric,
    female_smokers numeric,
    male_smokers numeric,
    handwashing_facilities numeric,
    hospital_beds_per_thousand numeric,
    life_expectancy numeric,
    human_development_index numeric
);

ALTER TABLE IF EXISTS public.covid_vaccinations
    OWNER to postgres;

-- Import data to 'covid_deaths' table
COPY covid_deaths
FROM '...\covid_deaths.csv'
WITH (FORMAT CSV, HEADER);

-- Import data to 'covid_vaccinations' table

COPY covid_vaccinations
FROM '...\covid_vaccinations.csv'
WITH (FORMAT CSV, HEADER);