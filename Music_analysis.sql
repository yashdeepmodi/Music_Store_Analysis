Use music_database;

/* Q1: Who is the senior most employee based on job title? */
select concat(first_name," ",last_name) as Employee_name,
title
from employee 
order by title desc
limit 1;

-- Which countries have the most Invoices?
select
 billing_country as country, 
count(*) as no_of_invoices
from invoice
group by country
order by country desc
limit 1;
		
-- What are top 3 values of total invoice?
Select 
invoice_id,customer_id,
round(total,2) as total_amount
from invoice
order by total_amount desc
limit 3;

/*  Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
 Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
SELECT billing_city,
round(SUM(total),2) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, 
concat(first_name," ", last_name) as customer_name,
round(SUM(total),2) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, customer_name
ORDER BY total_spending DESC
LIMIT 1;

/* Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
 Return your list ordered alphabetically by email starting with A */ 
SELECT DISTINCT email,
concat(first_name," ",last_name) as customer_name,
 genre.name AS genre
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id,
 artist.name as artist_name,
count(artist.artist_id) AS number_of_songs
FROM track
JOIN album2 on album2.album_id = track.album_id
JOIN artist on artist.artist_id = album2.artist_id
JOIN genre on genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
group by  artist.artist_id,artist_name
order by  number_of_songs desc, artist_name ASC
LIMIT 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name as track_name,
milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;

/*  Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id,
    artist.name AS artist_name, 
    SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album2 ON album2.album_id = track.album_id
	JOIN artist ON artist.artist_id = album2.artist_id
	GROUP BY 1,2
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT c.customer_id,
concat(c.first_name, " ",c.last_name) as customer_name,
 bsa.artist_name,
 round(SUM(il.unit_price*il.quantity),2) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3
ORDER BY 4 DESC, 2 asc, 1 ASC;

/*  We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS no_of_purchases,
    customer.country as country, genre.name as genre_name,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3
	ORDER BY 2 ASC, 1 DESC
)
SELECT no_of_purchases,
country, genre_name
 FROM popular_genre WHERE RowNo <= 1
 order by 2 asc, 1 desc;
 
 /*  Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


WITH Customter_with_country AS (
		SELECT customer.customer_id,concat(first_name," ",last_name) as customer_name,
        billing_country as country,
        round(SUM(total),2) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3
		ORDER BY 3 ASC,4 DESC)
SELECT country, customer_name, total_spending FROM Customter_with_country WHERE RowNo <= 1
order by 1, 3 desc

