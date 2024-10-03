--Q1: who is the senior most employee based on  job title?

select * from employee
order by levels desc
limit 1;


--Q2: which countries have the most invoices?

select count(*) as c, billing_country
from invoice 
group by billing_country
order by c desc;




--Q3: what are the top 3 values of total invoivce?

select total from invoice
order by total desc
limit 1;

--Q4: which city has the best cutomers? we would like to through the festival


select sum(total) as invoice_total,billing_city
from invoice
group by billing_city
order by invoice_total  desc;


--Q5: who is the best customer? The cusotmer who has spent the most money will be declared as best custromer?

select customer. customer_id,customer.first_name,customer.last_name, sum(invoice.total)as total
from customer
join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;

-- Q6 write query to return the email,lastname,& genre of all rock music.return your list ordered alphabatically by email starting with A?

select distinct email,first_name,last_name
from customer
join invoice on customer.customer_id= invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in(
select track_id from track
join genre on track.genre_id= genre.genre_id
where genre.name like 'Rock'
)
order by email;

--Q7 lets invite the artist who have written the most rock muiscin our data set
-- write a query that returns the artist name and total track count of the top  10 rock bands 

select artist.artist_id , artist.name,count(artist.artist_id) as no_of_songs
from track
join album on album.album_id= track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id= track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by no_of_songs desc
limit 10;

--Q8 Retrun all the track names that have a song length longer than the avg
-- song length.return the name and milliseconds for each track.order by the song length 
-- with the longst songs listened first


select name,milliseconds
from track
where milliseconds>(
select avg(milliseconds) as avg_tarck_length
from track)
order by milliseconds desc;

-- Q9 find ow much amount spent by each customer on arists ? write a query to return customer name, artist name and total spent?

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--Q10 We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
--with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
--the maximum number of purchases is shared return all Genres. */


WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

--Q3:-- Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount. */




WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;

