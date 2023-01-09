/*
Code written by Sebastian Tampu
Dataset from https://www.kaggle.com/datasets/htagholdings/property-sales

The dataset includes information such as property type, year sold,
postal code, price, and number of bedrooms.
This was used to compare change (typically growth) in prices and sales over the years.
*/


USE first_housing; --name of database

/*
First, we'll find the date on which the most sales occured.
This can be done by counting all sales in a day and returing one date,
or showing dates with respect to descdending sales.
*/

SELECT datesold, count(datesold)
FROM raw_sales --name of table of interest
GROUP BY datesold
ORDER BY count(datesold) DESC;



/*
Next, we'll find the average selling price for each postal code.
Average the price when the postalcode is the same. 
Then present the data as before.
*/

SELECT postcode, ROUND(AVG(price),2) AS average_price
FROM raw_sales
GROUP BY postcode
ORDER BY AVG(price) DESC;



/*
Next, we'll sort the sales by year.
We can select the year from the date and count how many times
it occurs. Then we'll simply group by it and order in descending fashion.
*/

SELECT EXTRACT(YEAR FROM datesold) AS year, --setting up new year column
       COUNT(EXTRACT(YEAR FROM datesold)) AS num_of_sales
FROM raw_sales
GROUP BY EXTRACT(YEAR FROM datesold)
ORDER BY COUNT(EXTRACT(YEAR FROM datesold)) DESC;



/*
Next, we will see which postal codes had the highest numbers
throughout the years. This can be done through window functions.
1. Add the prices for a certain postal code, during a certain year.
2. Order by year, followed by top 6 postal codes within each year.
*/

CREATE TABLE new_sales AS
SELECT YEAR(datesold) AS year,
       postcode,
       price,
       DENSE_RANK() OVER (PARTITION BY YEAR(datesold), postcode ORDER BY price) ranking
       -- Here we partitioned twice, by year and then by postalcode
       -- Within that we then ordered by price and saved to a new table
FROM raw_sales;

SELECT r.year, r.postcode, r.price
FROM(
    SELECT *, ROW_NUMBER() OVER (PARTITION BY year ORDER BY price DESC) rank_num
    FROM new_sales
    WHERE ranking < 2) r
WHERE r.rank_num BETWEEN 1 AND 6; 
--only allowed for the top 6 postal codes to be returned