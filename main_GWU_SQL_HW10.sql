/* GWU Data Analytics Boot Camp 
Homework 10: SQL
1/15/18
Requirement: Sakila MySQL sample database. Download: https://dev.mysql.com/doc/index-other.html
	Then install through running the sql scripts. 
*/ 

USE sakila;

/* 1a. Display the first and last names of all actors from the table `actor`. */
SELECT first_name, last_name
	FROM actor;

/* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. */
SELECT concat(first_name, " ", last_name) AS "Actor Name"
	FROM actor;

/* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information? */
SELECT actor_id, first_name, last_name 
	FROM actor
	WHERE first_name = "Joe";
  	
/* 2b. Find all actors whose last name contain the letters `GEN`: */
SELECT * 
	FROM actor
	WHERE last_name LIKE "%GEN%";

/* 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order: */
SELECT * 
	FROM actor
	WHERE last_name LIKE "%LI%"
	ORDER BY last_name, first_name;

/* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China: */
SELECT country_id, country
FROM country 
WHERE country IN 
	(
    SELECT country
		FROM country
        WHERE country = "Afghanistan" OR country = "Bangladesh" OR country = "China"
    );

/* 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. 
Hint: you will need to specify the data type. */
ALTER TABLE actor
	ADD COLUMN middle_name VARCHAR (50) 
		AFTER first_name; 

	-- checking 3a answer:
SELECT * FROM actor LIMIT 5;

/* 3b. You realize that some of these actors have tremendously long last names. 
Change the data type of the `middle_name` column to `blobs`. */
-- *** Review section to make sure it's `middle_name` and not `last_name` that's to be changed ***
 ALTER TABLE actor
	MODIFY COLUMN middle_name blob;

/* 3c. Now delete the `middle_name` column. */
ALTER TABLE actor
	DROP COLUMN middle_name;

	-- checking 3c answer:
SELECT * FROM actor LIMIT 5;

/* 4a. List the last names of actors, as well as how many actors have that last name. */
	-- to ensure changes to last_name_ct are refreshed, I drop it then rerun it
DROP VIEW IF EXISTS last_name_ct ;

CREATE VIEW last_name_ct AS
SELECT last_name, COUNT(last_name) AS name_count
	FROM actor
    GROUP BY last_name;

SELECT  * FROM last_name_ct;
  	
/* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors */
SELECT * 
	FROM last_name_ct 
	WHERE name_count > 1;

	-- Sanity check: count the total rows in the previous query to see if number is correct.
SELECT COUNT(*)
	FROM LAST_NAME_CT
	WHERE name_count > 1;

/* 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`,
the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record. */
UPDATE actor
	SET first_name = "HARPO"
    WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";
    
	-- Check to see if it updated correctly and get actor id
SELECT first_name, last_name, actor_id
	FROM actor
    WHERE first_name = "Harpo" AND last_name = "WILLIAMS";
  	
/* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all!
In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. 
Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. 
BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.) */
UPDATE actor
	SET first_name = 
		CASE WHEN first_name = "HARPO" 
			THEN "GROUCHO" 
            ELSE "MUCHO GROUCHO" 
            END
    WHERE actor_id = 172; 

	-- Check if the actor name is updated back to "GROUCHO"
SELECT * FROM actor WHERE actor_id = 172;
	-- Check if all the other actors names were changed
SELECT * FROM actor;

/* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it? */
DROP TABLE IF EXISTS address_1;

	-- Clone of address table, w/matching data types, indexes, default values, nullable condition, and extra characteristics 
CREATE TABLE address_1
(
	address_id SMALLINT(5) UNSIGNED NOT NULL AUTO_INCREMENT,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50),
    district VARCHAR(20) NOT NULL,
    city_id SMALLINT(5) UNSIGNED NOT NULL,
	postal_code VARCHAR(10),
    phone VARCHAR(20) NOT NULL,
    location GEOMETRY NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (address_id),
    FOREIGN KEY (city_id) REFERENCES city(city_id) ON UPDATE CASCADE,
    SPATIAL INDEX (location)
);

	-- check if table address_test is created with right columns
SELECT * FROM address_1 LIMIT 5;

/* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`: */
SELECT staff.first_name, staff.last_name, address
	FROM staff
	LEFT JOIN address ON address.address_id = staff.address_id;

/* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. */
SELECT payment.staff_id, staff.first_name, staff.last_name, SUM(payment.amount)
    FROM payment
    LEFT JOIN staff ON staff.staff_id = payment.staff_id
    WHERE YEAR(payment.payment_date) = 2005 AND MONTH(payment.payment_date) = 8
	GROUP BY payment.staff_id;
    
/* 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join. */
SELECT film.title AS Title, COUNT(film_actor.actor_id) AS "Number of Actors" 
	FROM film
    INNER JOIN film_actor ON film.film_id = film_actor.film_id
    GROUP BY Title;

/* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?  */
SELECT film.film_id, film.title AS Title, COUNT(inventory.film_id) AS Copies
	FROM film
    INNER JOIN inventory ON film.film_id = inventory.film_id
    WHERE film.title = "Hunchback Impossible";

	-- Confirming that there are 6 copies of "Hunchback Impossible" in the inventory (film_id = 439). 
SELECT * FROM INVENTORY WHERE film_id = 439;

/* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name: */
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS "Total Amount Paid"
	FROM customer
    INNER JOIN payment ON customer.customer_id = payment.customer_id
    GROUP BY last_name, first_name; 
	-- Seems to match example .jpg

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies 
starting with the letters `K` and `Q` whose language is English. */

	-- Find english language id
SELECT * FROM language; -- English: language_id = 1

-- note: right now (1/14/18) there are no films in the database not in English. I'll still include subquery for only English language films. 
SELECT * FROM film WHERE language_id <> 1;

SELECT title 
	FROM film
	WHERE (title LIKE "K%" OR title LIKE "Q%") AND 
    language_id IN        
	(
		SELECT language_id
			FROM language
			WHERE name = "English"
	);

/* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`. */
SELECT first_name, last_name
	FROM actor
    WHERE actor_id IN
    (
		SELECT actor_id
			FROM film_actor
			WHERE film_id IN 
			(
				SELECT film_id
					FROM film
					WHERE title = "Alone Trip"
			) 
	);

/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
Use joins to retrieve this information. */
SELECT first_name, last_name, email, city.city, country.country
	FROM customer
    INNER JOIN address ON customer.address_id = address.address_id
    INNER JOIN city ON address.city_id = city.city_id
    INNER JOIN country ON city.country_id = country.country_id
    WHERE country.country = "Canada";


/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as famiy films. */
SELECT film.film_id, title, description
	FROM film
    INNER JOIN film_category ON film.film_id = film_category.film_id
    INNER JOIN category ON film_category.category_id = category.category_id
    WHERE category.name = "Family";

/* 7e. Display the most frequently rented movies in descending order. */
SELECT film.film_id, title, description, COUNT(rental.rental_id) AS "Rental Count"
	FROM film
	INNER JOIN inventory ON film.film_id = inventory.film_id
    INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
    GROUP BY title
    ORDER BY COUNT(rental.rental_id) DESC, title ASC;

/* 7f. Write a query to display how much business, in dollars, each store brought in. */
SELECT store.store_id, SUM(payment.amount)
	FROM store
    INNER JOIN staff ON store.store_id = staff.store_id
    INNER JOIN payment ON staff.staff_id = payment.staff_id
	GROUP BY store.store_id;
    
/* 7g. Write a query to display for each store its store ID, city, and country. */
SELECT store_id, city, country
	FROM address
    INNER JOIN store ON address.address_id = store.address_id
    INNER JOIN city ON address.city_id = city.city_id
    INNER JOIN country ON city.country_id = country.country_id;

/* 7h. List the top five genres in gross revenue in descending order. 
(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.) */
/* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view. */
CREATE VIEW Rev_Top_Genres AS
	SELECT category.name AS "Category Name", SUM(amount) AS "Gross Revenue"
		FROM category
		INNER JOIN film_category ON category.category_id = film_category.category_id
		INNER JOIN inventory ON film_category.film_id = inventory.film_id
		INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
		INNER JOIN payment ON rental.rental_id = payment.rental_id
		GROUP BY category.name 
		ORDER BY SUM(amount) DESC
		LIMIT 5;
        -- Note: this answers both questions 7h & 8a

/* 8b. How would you display the view that you created in 8a? */
SELECT * FROM Rev_Top_Genres;

/* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it. */
DROP VIEW Rev_Top_Genres;