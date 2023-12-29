---------------------------------------------------
---------------------------------------------------
CREATE SCHEMA pizza_runner_2;
SET search_path = pizza_runner_2;
---------------------------------------------------
DROP TABLE IF EXISTS pizza_runner_2.runners;
CREATE TABLE pizza_runner_2.runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO pizza_runner_2.runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS pizza_runner_2.customer_orders;
CREATE TABLE pizza_runner_2.customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO pizza_runner_2.customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS pizza_runner_2.runner_orders;
CREATE TABLE pizza_runner_2.runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO pizza_runner_2.runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_runner_2.pizza_names;
CREATE TABLE pizza_runner_2.pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_runner_2.pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_runner_2.pizza_recipes;
CREATE TABLE pizza_runner_2.pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_runner_2.pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_runner_2.pizza_toppings;
CREATE TABLE pizza_runner_2.pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_runner_2.pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
---------------------------------------------------
---------------------------------------------------

/* --------------------
   Case Study Questions
   --------------------*/

/* A. Pizza Metrics */
-- 1. How many pizzas were ordered?
SELECT COUNT(ORDER_ID) AS ordered_pizzas
FROM CUSTOMER_ORDERS

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT(ORDER_ID)) AS unique_customer
FROM CUSTOMER_ORDERS

-- 3. How many successful orders were delivered by each runner?
SELECT R.RUNNER_ID, COUNT(DISTINCT C.ORDER_ID) AS successful_orders
FROM RUNNER_ORDERS AS R
JOIN CUSTOMER_ORDERS AS C
USING(ORDER_ID)
WHERE PICKUP_TIME <> 'null'
GROUP BY R.RUNNER_ID
ORDER BY R.RUNNER_ID

-- 4. How many of each type of pizza was delivered?
SELECT P.PIZZA_NAME, COUNT(P.PIZZA_NAME) AS pizza_delivered
FROM CUSTOMER_ORDERS AS C
JOIN PIZZA_NAMES AS P
USING (PIZZA_ID)
JOIN RUNNER_ORDERS AS R
USING(ORDER_ID)
WHERE R.PICKUP_TIME <> 'null'
GROUP BY P.PIZZA_NAME

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT C.CUSTOMER_ID, P.PIZZA_NAME, COUNT(P.PIZZA_NAME) AS number
FROM CUSTOMER_ORDERS AS C
JOIN PIZZA_NAMES AS P
USING (PIZZA_ID)
GROUP BY C.CUSTOMER_ID, P.PIZZA_NAME
ORDER BY C.CUSTOMER_ID

-- 6. What was the maximum number of pizzas delivered in a single order?
WITH CTE AS
(
SELECT C.ORDER_ID, COUNT(C.PIZZA_ID) AS number_of_pizza
FROM CUSTOMER_ORDERS AS C
LEFT JOIN RUNNER_ORDERS AS R
ON C.ORDER_ID = R.ORDER_ID
WHERE R.PICKUP_TIME <> 'null'
GROUP BY C.ORDER_ID
ORDER BY number_of_pizza DESC
)

SELECT MAX(number_of_pizza) AS max_pizza_delivered FROM CTE

---- C H E C K 7----
-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT C.CUSTOMER_ID,
SUM(
CASE
	WHEN C.EXCLUSIONS <> ' ' OR C.EXTRAS <> ' ' THEN 1
	ELSE 0
END) AS at_least_1_change,
SUM(
CASE
	WHEN C.EXCLUSIONS = ' ' AND C.EXTRAS = ' ' THEN 1
	ELSE 0
END) AS no_change
FROM CUSTOMER_ORDERS AS C
LEFT JOIN RUNNER_ORDERS AS R
ON C.ORDER_ID = R.ORDER_ID
WHERE R.PICKUP_TIME <> 'null'
GROUP BY C.CUSTOMER_ID
ORDER BY C.CUSTOMER_ID

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT
SUM(
CASE
	WHEN C.EXCLUSIONS IS NOT NULL AND C.EXTRAS IS NOT NULL THEN 1
	ELSE 0
END) AS total_pizza_with_exclusions_extras
FROM CUSTOMER_ORDERS AS C
LEFT JOIN RUNNER_ORDERS AS R
ON C.ORDER_ID = R.ORDER_ID
WHERE R.PICKUP_TIME <> 'null'

SELECT COUNT(*)											/* ANOTHER APPROACH */
FROM CUSTOMER_ORDERS AS C
LEFT JOIN RUNNER_ORDERS AS R
ON C.ORDER_ID = R.ORDER_ID
WHERE R.PICKUP_TIME <> 'null'
AND C.EXCLUSIONS <> ' ' AND C.EXTRAS <> ' '

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT EXTRACT(HOUR FROM ORDER_TIME) AS hour_of_day, COUNT(ORDER_ID) AS pizza_count
FROM CUSTOMER_ORDERS
GROUP BY EXTRACT(HOUR FROM ORDER_TIME)
ORDER BY COUNT(ORDER_ID) DESC

-- 10. What was the volume of orders for each day of the week?
SELECT DATE_PART('dow', ORDER_TIME) AS dow, COUNT(ORDER_ID) AS order_volume
FROM CUSTOMER_ORDERS
GROUP BY dow
ORDER BY dow ASC


/* B. Runner and Customer Experience */
-- 11. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT *,
TIMESTAMP '2021-01-01' + INTERVAL '1 WEEKS' AS max_date
FROM RUNNERS
WHERE REGISTRATION_DATE <= TIMESTAMP '2021-01-01' + INTERVAL '1 WEEKS'

-- 12. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT R.RUNNER_ID,
AVG(
DATE_PART('day', R.PICKUP_TIME:: TIMESTAMP - C.ORDER_TIME:: TIMESTAMP) * 24 * 60 + 
DATE_PART('hour', R.PICKUP_TIME:: TIMESTAMP - C.ORDER_TIME:: TIMESTAMP) * 60 +
DATE_PART('minute', R.PICKUP_TIME:: TIMESTAMP - C.ORDER_TIME:: TIMESTAMP) +
DATE_PART('second', R.PICKUP_TIME:: TIMESTAMP - C.ORDER_TIME:: TIMESTAMP) / 60
	) AS pickup_minutes
FROM CUSTOMER_ORDERS AS C
LEFT JOIN RUNNER_ORDERS AS R
ON C.ORDER_ID = R.ORDER_ID
WHERE PICKUP_TIME <> 'null'
GROUP BY R.RUNNER_ID
ORDER BY R.RUNNER_ID

-- 13. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH CTE AS (
SELECT C.ORDER_ID, C.ORDER_TIME, R.PICKUP_TIME, COUNT(C.ORDER_ID) AS order_numbers,
AVG(
DATE_PART('day', R.PICKUP_TIME:: TIMESTAMP - C.ORDER_TIME:: TIMESTAMP) * 24 * 60 + 
DATE_PART('hour', R.PICKUP_TIME:: TIMESTAMP - C.ORDER_TIME:: TIMESTAMP) * 60 +
DATE_PART('minute', R.PICKUP_TIME:: TIMESTAMP - C.ORDER_TIME:: TIMESTAMP) +
DATE_PART('second', R.PICKUP_TIME:: TIMESTAMP - C.ORDER_TIME:: TIMESTAMP) / 60
	) AS pickup_minutes
FROM CUSTOMER_ORDERS AS C
LEFT JOIN RUNNER_ORDERS AS R
ON C.ORDER_ID = R.ORDER_ID
WHERE PICKUP_TIME <> 'null'
GROUP BY C.ORDER_ID, C.ORDER_TIME, R.PICKUP_TIME
ORDER BY order_numbers DESC
)

SELECT ORDER_NUMBERS, AVG(PICKUP_MINUTES) AS avg_time
FROM CTE
GROUP BY order_numbers

-- 14. What was the average distance travelled for each customer?
SELECT C.CUSTOMER_ID,
ROUND(AVG(CAST(REGEXP_REPLACE(DISTANCE, 'km', '') AS NUMERIC)),2) AS distance_travelled
FROM CUSTOMER_ORDERS AS C
LEFT JOIN RUNNER_ORDERS AS R
ON C.ORDER_ID = R.ORDER_ID
WHERE PICKUP_TIME <> 'null'
GROUP BY C.CUSTOMER_ID
ORDER BY C.CUSTOMER_ID

-- 15. What was the difference between the longest and shortest delivery times for all orders?
WITH CTE AS
(
SELECT ORDER_ID, DURATION,
REGEXP_REPLACE(DURATION, 'minute|minutes|mins', '')::FLOAT as numeric_duration
FROM RUNNER_ORDERS
WHERE PICKUP_TIME <> 'null'
)

SELECT MAX(numeric_duration) - MIN(numeric_duration) AS minutes_difference
FROM CTE

-- 16. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT R.RUNNER_ID, C.CUSTOMER_ID, C.ORDER_ID,
AVG(REGEXP_REPLACE(DURATION, 'minute|minutes|mins', '')::FLOAT/60) as numeric_duration,
AVG(REGEXP_REPLACE(DISTANCE, 'KM|Km|km', '')::FLOAT) as numeric_distance,
AVG(REGEXP_REPLACE(DISTANCE, 'KM|Km|km', '')::FLOAT/REGEXP_REPLACE(DURATION, 'minute|minutes|mins', '')::FLOAT*60) as numeric_speed
FROM CUSTOMER_ORDERS AS C
LEFT JOIN RUNNER_ORDERS AS R
ON C.ORDER_ID = R.ORDER_ID
WHERE PICKUP_TIME <> 'null'
GROUP BY R.RUNNER_ID, C.CUSTOMER_ID, C.ORDER_ID
ORDER BY R.RUNNER_ID, C.CUSTOMER_ID, C.ORDER_ID

-- 17. What is the successful delivery percentage for each runner?
SELECT RUNNER_ID,
SUM(
CASE
	WHEN DISTANCE = 'null' THEN 0
	ELSE 1
END) * 100/COUNT(*) AS successful_orders
FROM RUNNER_ORDERS
GROUP BY RUNNER_ID
ORDER BY RUNNER_ID

/* C. Ingredient Optimisation */
-- 18. What are the standard ingredients for each pizza?
WITH CTE1 AS
(
SELECT PIZZA_ID, UNNEST(STRING_TO_ARRAY(TOPPINGS, ', '))::INTEGER AS TOPPING_ID
FROM PIZZA_RECIPES
), 
CTE2 AS
(
SELECT CTE1.PIZZA_ID, CTE1.TOPPING_ID, P.TOPPING_NAME
FROM CTE1
LEFT JOIN PIZZA_TOPPINGS AS P
ON CTE1.TOPPING_ID = P.TOPPING_ID
)

SELECT CTE2.PIZZA_ID,
STRING_AGG(CTE2.TOPPING_NAME::TEXT, ', ') AS std_ingredients
FROM CTE2
GROUP BY CTE2.PIZZA_ID
ORDER BY CTE2.PIZZA_ID

-- 19. What was the most commonly added extra?
WITH CTE1 AS
(
SELECT PIZZA_ID, UNNEST(STRING_TO_ARRAY(TOPPINGS, ', '))::INTEGER AS TOPPING_ID
FROM PIZZA_RECIPES
)

SELECT P.TOPPING_ID, P.TOPPING_NAME,
COUNT(C.PIZZA_ID) AS used_in_pizza
FROM CTE1 AS C
JOIN PIZZA_TOPPINGS AS P
ON C.TOPPING_ID = P.TOPPING_ID
GROUP BY P.TOPPING_ID, P.TOPPING_NAME
ORDER BY used_in_pizza DESC, P.TOPPING_ID ASC

-- 20. What was the most common exclusion?
SELECT * FROM CUSTOMER_ORDERS
SELECT * FROM PIZZA_NAMES
SELECT * FROM PIZZA_RECIPES
SELECT * FROM PIZZA_TOPPINGS
SELECT * FROM RUNNER_ORDERS
SELECT * FROM RUNNERS



-- 21. Generate an order item for each record in the customers_orders table in the format of one of the following:
----- * Meat Lovers
----- * Meat Lovers - Exclude Beef
----- * Meat Lovers - Extra Bacon
----- * Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- 22. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
----- * For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- 23. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?



/* D. Pricing and Ratings */
-- 24. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
-- 25. What if there was an additional $1 charge for any pizza extras?
----- * Add cheese is $1 extra
-- 26. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
-- 27. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
----- * customer_id
----- * order_id
----- * runner_id
----- * rating
----- * order_time
----- * pickup_time
----- * Time between order and pickup
----- * Delivery duration
----- * Average speed
----- * Total number of pizzas
-- 28. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?



/* E. Bonus Questions */
-- 29. If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?



















































