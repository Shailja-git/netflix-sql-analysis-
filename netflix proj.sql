select * from netflix_titles
select count(*) from netflix_titles

--type of content
select distinct type from netflix_titles


--checked & deleted duplicates

with serial as (select *,ROW_NUMBER() over(partition by title order by release_year ) as s_num from netflix_titles
) select * from serial where s_num=2

begin transaction 

select  *  from netflix_titles
where title like'??? ?????'

select  *  from netflix_titles
where title like'????'

select  *  from netflix_titles
where title like'Death Note'

select  *  from netflix_titles
where title like'Esperando La Carroza'

delete from netflix_titles
where show_id='s6706'

select  *  from netflix_titles
where title like'FullMetal Alchemist'

select  *  from netflix_titles
where title like'Love in a Puff'

delete from netflix_titles
where show_id='s7346'

select  *  from netflix_titles
where title like'Sin senos sí hay paraíso'


delete from netflix_titles
where show_id='s8023'

commit

--checking and correcting  data anomalies

select distinct rating from netflix_titles --anomaly

---isolating show ids with error
select rating,duration,show_id from netflix_titles
where rating like'%min%'

begin transaction;
with swapped as (
				select rating as duration1,duration as rating1,show_id, release_year, duration,rating from netflix_titles
				where netflix_titles.show_id in ('s5542','s5795','s5814')
)
update netflix_titles set duration=swapped.duration1, rating = swapped.rating1 
from swapped join netflix_titles nt 
on nt.show_id = swapped.show_id

commit

select rating, duration,show_id from netflix_titles
where show_id in ('s5542','s5795','s5814')


select distinct duration  from netflix_titles

select distinct country from netflix_titles

select distinct listed_in from netflix_titles

select distinct description  from netflix_titles

/*1. Count the number of Movies vs TV Shows
--2. Find the most common rating for movies and TV shows
--3. List all movies released in a specific year (e.g., 2020)
--4. Find the top 5 countries with the most content on Netflix
--5. Identify the longest movie
--6. Find content added in the last 5 years
--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
--8. List all TV shows with more than 5 seasons
--9. Count the number of content items in each genre
10. List all movies that are documentaries
11. Find all content without a director
12. Find how many movies actor 'Salman Khan' appeared in last 10 years!
13. Find the top 10 actors who have appeared in the highest number of movies produced in India.
14.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'.
Count how many items fall into each category.*/


--1. Count the number of Movies vs TV Shows

select count(*),type from netflix_titles
group by type

--2. Find the most common rating for movies and TV shows

select * from netflix_titles

with rating as (select count(rating)as counts,type,rating from netflix_titles
group by type, rating),
ranks as (
	select *, rank() over(partition by type order by counts desc) as ranking from rating)
select ranking,type,rating,counts from ranks
where ranking=1

--3. List all movies released in a specific year (e.g., 2020)
 
 select * from netflix_titles
 
 where release_year=2020 and type='movie'


 --4. Find the top 5 countries with the most content on Netflix

create view countries as (
					SELECT title, release_year, value AS country_
					FROM netflix_titles
					CROSS APPLY STRING_SPLIT(country, ',')
					)
select top 5 count(distinct title) as content,  ltrim(rtrim(country_)) from countries
group by ltrim(rtrim(country_)) 
order by content desc

--5. Identify the longest movie

with leng as
		( select 
				*,
				cast(substring(duration, 0, charindex('min',duration)) as int)  as lengths  from netflix_titles)
select lengths , title, type from leng
 order by lengths desc

  --6. Find content added in the last 5 years
  select * from netflix_titles
  where year(date_added) between 2020 and year(getdate())

    select *,year(date_added) as year_added from netflix_titles

select year(getdate()) as dates

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

  select * from netflix_titles
  where director like '%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons

with seasons_ as(
				select *,cast(substring(duration, 0,CHARINDEX(' ',duration)) as int) as seasons from netflix_titles
				where duration like '%season%'
				)
	select * from seasons_
				where seasons>5

--9. Count the number of content items in each genre

with genre as (select *,ltrim(value) as genres from netflix_titles
cross apply string_split(listed_in,',') 
)
select count(title) as content, genres from genre
group by genres

--10. List all movies that are documentaries

select * from netflix_titles
where listed_in like '%documentaries%' and type='movie'


--11. Find all content without a director
select * from netflix_titles
where director is null


--12. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix_titles
where type='movie' and cast like '%salman khan%' and release_year between year(getdate())-10 and  year(getdate())



--13. Find the top 10 actors who have appeared in the highest number of movies produced in India.

with Indian_content as (select ltrim(value) as casts,* from netflix_titles
						cross apply string_split(cast,',')
						where country like '%india%'
						)
select top 10 casts,count(distinct title) appearance from Indian_content
group by casts
order by appearance desc

/*14.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'.
Count how many items fall into each category.*/

select count(title) as content, category from (select *,
		case 
			when description like '%kill%' or description like '%violence%' then 'bad'
			else 'good'
		end as category
		from netflix_titles) as gud
		group by category