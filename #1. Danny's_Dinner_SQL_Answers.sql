---------------------------------------------------
---------------------------------------------------
CREATE SCHEMA dannys_diner_1;
SET search_path = dannys_diner_1;
---------------------------------------------------
CREATE TABLE dannys_diner_1.sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO dannys_diner_1.sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
---------------------------------------------------
CREATE TABLE dannys_diner_1.menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO dannys_diner_1.menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
---------------------------------------------------
CREATE TABLE dannys_diner_1.members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO dannys_diner_1.members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
---------------------------------------------------
---------------------------------------------------

/* --------------------
   Case Study Questions
   --------------------*/
   
-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.CUSTOMER_ID, SUM(mu.PRICE) AS total_spent
FROM MENU AS mu
RIGHT JOIN SALES AS s
ON mu.PRODUCT_ID= s.PRODUCT_ID
GROUP BY s.CUSTOMER_ID
ORDER BY s.CUSTOMER_ID

-- 2. How many days has each customer visited the restaurant?
SELECT CUSTOMER_ID, COUNT(DISTINCT ORDER_DATE) AS total_visits
FROM SALES
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID

-- 3. What was the first item from the menu purchased by each customer?
WITH CTE AS (SELECT CUSTOMER_ID,ORDER_DATE,PRODUCT_NAME,
			RANK() OVER(PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE ASC) AS RNK
			FROM SALES AS s
			JOIN MENU AS mu ON mu.PRODUCT_ID= s.PRODUCT_ID
			 )
SELECT CUSTOMER_ID, ORDER_DATE, PRODUCT_NAME FROM CTE
WHERE RNK=1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT mu.PRODUCT_NAME, COUNT(s.PRODUCT_ID) AS NUMBER_OF_ORDER
FROM SALES AS s
JOIN MENU AS mu ON mu.PRODUCT_ID= s.PRODUCT_ID
GROUP BY mu.PRODUCT_NAME
LIMIT 1

-- 5. Which item was the most popular for each customer?
WITH CTE AS (SELECT s.CUSTOMER_ID, MAX(s.PRODUCT_ID) AS MOST_POPULAR
			FROM SALES AS s
			JOIN MENU AS mu ON mu.PRODUCT_ID = s.PRODUCT_ID
			GROUP BY s.CUSTOMER_ID
			)

SELECT c.CUSTOMER_ID, c.MOST_POPULAR, me.PRODUCT_NAME
FROM CTE as c
JOIN MENU AS me ON c.most_popular = me.PRODUCT_ID
GROUP BY c.CUSTOMER_ID, c.MOST_POPULAR, me.PRODUCT_NAME
ORDER BY c.CUSTOMER_ID ASC

-- 6. Which item was purchased first by the customer after they became a member?
WITH CTE AS
(
SELECT S.CUSTOMER_ID, MIN(S.ORDER_DATE), MIN(S.PRODUCT_ID) AS first_order
FROM SALES AS S
JOIN MEMBERS AS M
USING(CUSTOMER_ID)
WHERE M.JOIN_DATE < S.ORDER_DATE
GROUP BY S.CUSTOMER_ID
)

SELECT CTE.CUSTOMER_ID, CTE.FIRST_ORDER, M.PRODUCT_NAME FROM CTE
JOIN MENU AS M
ON CTE.FIRST_ORDER = M.PRODUCT_ID
ORDER BY CTE.CUSTOMER_ID

-- 7. Which item was purchased just before the customer became a member?
WITH CTE AS
(
SELECT *,
EXTRACT (DAY FROM M.JOIN_DATE) - EXTRACT (DAY FROM S.ORDER_DATE) AS adoption_days,
RANK() OVER(PARTITION BY S.CUSTOMER_ID ORDER BY EXTRACT (DAY FROM M.JOIN_DATE) - EXTRACT (DAY FROM S.ORDER_DATE) ASC) AS RNK	
FROM SALES AS S
JOIN MEMBERS AS M
USING(CUSTOMER_ID)
WHERE M.JOIN_DATE > S.ORDER_DATE
)

SELECT CUSTOMER_ID, PRODUCT_ID FROM CTE
WHERE RNK = 1

-- 8. What is the total items and amount spent for each member before they became a member?
WITH CTE AS
(
SELECT * FROM SALES AS S
JOIN MEMBERS AS M
USING(CUSTOMER_ID)
JOIN MENU AS ME
USING(PRODUCT_ID)
WHERE S.ORDER_DATE < M.JOIN_DATE
)

SELECT CUSTOMER_ID, COUNT(PRODUCT_ID) AS total_items, SUM(PRICE) AS amount_spent
FROM CTE
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT CUSTOMER_ID,
SUM
(
CASE
	WHEN PRODUCT_ID = 1 THEN 20 * PRICE
	ELSE 10 * PRICE
END
) AS "multiplier"
FROM SALES AS S
JOIN MENU AS M
USING (PRODUCT_ID)
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT CUSTOMER_ID, SUM(2 * PRICE) AS total_points
FROM SALES AS S
JOIN MENU AS M
USING(PRODUCT_ID)
JOIN MEMBERS AS ME
USING(CUSTOMER_ID)
WHERE S.ORDER_DATE > ME.JOIN_DATE
AND EXTRACT (DAY FROM S.ORDER_DATE) - EXTRACT (DAY FROM ME.JOIN_DATE) <= 7
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID
  
 ---------------------------------------------------CASE STUDY SOLVED---------------------------------------------------
 