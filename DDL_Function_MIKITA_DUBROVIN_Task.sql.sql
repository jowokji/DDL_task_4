 1.

CREATE OR REPLACE VIEW public.sales_revenue_by_category_qtr AS
SELECT
    c.name AS category,
    extract(QUARTER FROM p.payment_date) AS QUARTER,
    coalesce(sum(p.amount), 0::NUMERIC) AS total_sales_revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE
   extract(QUARTER FROM p.payment_date) = extract(QUARTER FROM current_date)
  AND extract(YEAR FROM p.payment_date) = extract(YEAR FROM current_date)
GROUP BY c.name, extract(QUARTER FROM p.payment_date)
HAVING count(DISTINCT p.payment_id) > 0;



 2.

CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(current_qtr NUMERIC)
RETURNS TABLE(category_result TEXT, quarter_result NUMERIC, total_sales_revenue_result NUMERIC)
LANGUAGE 'plpgsql'
AS
$$
BEGIN
  RETURN query
  SELECT * FROM sales_revenue_by_category_qtr
  WHERE QUARTER = current_qtr;
END;
$$;


SELECT * FROM get_sales_revenue_by_category_qtr(extract(QUARTER FROM current_date));


 3. 

CREATE OR REPLACE PROCEDURE new_movie(movie_title VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    s_language_id INT;
    new_film_id INT;
BEGIN
    
    SELECT language_id INTO s_language_id
   FROM LANGUAGE
   WHERE NAME = 'DOCTOR MANN';

   IF s_language_id IS NULL THEN
        raise exception 'Language "DOCTOR MANN" does not exist in the language table.';
    END IF;

   SELECT coalesce(max(film_id), 0) + 1 INTO new_film_id
   FROM film;
  
    INSERT INTO film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
   VALUES(new_film_id, movie_title, 4.99, 3, 19.99, extract(YEAR FROM current_date), s_language_id);
END;
$$;

CALL new_movie('Interstellar 2');