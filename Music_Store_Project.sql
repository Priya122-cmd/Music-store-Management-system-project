-- Created Database
CREATE DATABASE IF NOT EXISTS music_store;
USE music_store;

-- Creating Tables
CREATE TABLE Genre (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(120)
);

SELECT * FROM Genre;

CREATE TABLE MediaType (
    media_type_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(120)
);

SELECT * FROM MediaType;

CREATE TABLE Employee (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    last_name VARCHAR(120),
    first_name VARCHAR(120),
    title VARCHAR(120),
    reports_to INT,
    levels VARCHAR(255),
    birthdate DATE,
    hire_date DATE,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(100)
);

SELECT * FROM Employee;

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(120),
    last_name VARCHAR(120),
    company VARCHAR(120),
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(100),
    support_rep_id INT,
    FOREIGN KEY (support_rep_id)
        REFERENCES Employee(employee_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

SELECT * FROM Customer;

CREATE TABLE Artist (
    artist_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(120)
);

SELECT * FROM Artist;

CREATE TABLE Album (
    album_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(160),
    artist_id INT,
    FOREIGN KEY (artist_id)
        REFERENCES Artist(artist_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

SELECT * FROM Album;

CREATE TABLE Track (
    track_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200),
    album_id INT,
    media_type_id INT,
    genre_id INT,
    composer VARCHAR(220),
    milliseconds INT,
    bytes INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (album_id)
        REFERENCES Album(album_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (media_type_id)
        REFERENCES MediaType(media_type_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (genre_id)
        REFERENCES Genre(genre_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


SELECT * FROM Track;

SELECT COUNT(*) FROM Track;

CREATE TABLE Invoice (
    invoice_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    invoice_date DATE,
    billing_address VARCHAR(255),
    billing_city VARCHAR(100),
    billing_state VARCHAR(100),
    billing_country VARCHAR(100),
    billing_postal_code VARCHAR(20),
    total DECIMAL(10,2),
    FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
SELECT * FROM Invoice;

CREATE TABLE InvoiceLine (
    invoice_line_id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_id INT,
    track_id INT,
    unit_price DECIMAL(10,2),
    quantity INT,
    FOREIGN KEY (invoice_id)
        REFERENCES Invoice(invoice_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (track_id)
        REFERENCES Track(track_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

SELECT * FROM InvoiceLine;

CREATE TABLE Playlist (
    playlist_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255)
);
SELECT * FROM Playlist;

CREATE TABLE PlaylistTrack (
    playlist_id INT,
    track_id INT,
    PRIMARY KEY (playlist_id, track_id),
    FOREIGN KEY (playlist_id)
        REFERENCES Playlist(playlist_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (track_id)
        REFERENCES Track(track_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
SELECT * FROM PlaylistTrack;

-- Q1. Who is the senior most employee based on job title?
SELECT *
FROM Employee
Order by levels DESC
LIMIT 1;

-- Q2.Which countries have the most Invoices?
SELECT billing_country, COUNT(invoice_id) as total_invoices 
FROM Invoice 
Group by billing_country 
order by total_invoices DESC; 

-- Q3. What are the top 3 values of total invoice?
SELECT total FROM Invoice
order by total DESC
LIMIT 3;

-- Q4. Which city has the best customers? -
-- We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.
SELECT billing_city, sum(total) AS total_revenue
FROM Invoice
Group by billing_city
Order by total_revenue DESC
limit 1;

-- Q5. Who is the best customer? 
-- The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       SUM(i.total) AS total_spent
FROM Customer c
JOIN Invoice i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;

-- Q6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A.
SELECT DISTINCT c.email,c.first_name,c.last_name,g.name AS genre
FROM Customer c
JOIN Invoice i ON c.customer_id = i.customer_id
JOIN InvoiceLine il ON i.invoice_id = il.invoice_id
JOIN Track t ON il.track_id = t.track_id
JOIN Genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;

-- Q7. Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.
SELECT ar.name AS artist_name,
       COUNT(t.track_id) AS rock_track_count
FROM Artist ar
JOIN Album al ON ar.artist_id = al.artist_id
JOIN Track t ON al.album_id = t.album_id
JOIN Genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY ar.artist_id, ar.name
ORDER BY rock_track_count DESC
LIMIT 10;

-- Q.8. Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length, with the longest songs listed first.
SELECT name, milliseconds FROM Track
WHERE milliseconds > (
    SELECT AVG(milliseconds)
    FROM Track
)
ORDER BY milliseconds DESC;

-- Q9. Find how much amount is spent by each customer on artists? Write a query to return customer name, artist name and total spent 
SELECT c.first_name,
       c.last_name,
       ar.name AS artist_name,
       SUM(il.unit_price * il.quantity) AS total_spent
FROM Customer c
JOIN Invoice i ON c.customer_id = i.customer_id
JOIN InvoiceLine il ON i.invoice_id = il.invoice_id
JOIN Track t ON il.track_id = t.track_id
JOIN Album al ON t.album_id = al.album_id
JOIN Artist ar ON al.artist_id = ar.artist_id
GROUP BY c.customer_id, ar.artist_id
ORDER BY total_spent DESC;

-- Q10. We want to find out the most popular music Genre for each country.
-- We determine the most popular genre as the genre with the highest amount of purchases.
-- Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared, return all Genres
WITH genre_sales AS (
    SELECT i.billing_country,
           g.name AS genre,
           COUNT(*) AS purchases
    FROM Invoice i
    JOIN InvoiceLine il USING (invoice_id)
    JOIN Track t USING (track_id)
    JOIN Genre g USING (genre_id)
    GROUP BY i.billing_country, g.name),
max_sales AS (
    SELECT billing_country,
           MAX(purchases) AS max_purchases
    FROM genre_sales
    GROUP BY billing_country)
SELECT billing_country, genre, purchases
FROM genre_sales
JOIN max_sales USING (billing_country)
WHERE purchases = max_purchases
ORDER BY billing_country;

-- Q11. Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent.
--  For countries where the top amount spent is shared, provide all customers who spent this amount.
WITH customer_spending AS (
    SELECT c.customer_id,
           c.first_name,
           c.last_name,
           i.billing_country,
           SUM(i.total) AS total_spent
    FROM Customer c
    JOIN Invoice i USING (customer_id)
    GROUP BY c.customer_id, i.billing_country),
max_spending AS (
    SELECT billing_country,
           MAX(total_spent) AS max_spent
    FROM customer_spending
    GROUP BY billing_country)
SELECT billing_country,
       first_name,
       last_name,
       total_spent
FROM customer_spending
JOIN max_spending USING (billing_country)
WHERE total_spent = max_spent
ORDER BY billing_country;
