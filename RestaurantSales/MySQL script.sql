# SET SQL_SAFE_UPDATES = 0;
# SET SQL_SAFE_UPDATES = 1;

# Join tables into one
CREATE TABLE indian_food AS
	SELECT * FROM orders
		LEFT JOIN orderdetails USING (`Order Number`)
		LEFT JOIN restaurants USING (RestID)
		LEFT JOIN products USING (ItemID)
		LEFT JOIN foodtype ON foodtype.ProdType = products.ProdTypeID;
        
SELECT * FROM indian_food;

# Create new column 'TotalPrice'
ALTER TABLE indian_food ADD
	TotalPrice FLOAT(5) AFTER ProductPrice;

UPDATE indian_food SET
	TotalPrice = (SELECT ProductPrice*Quantity)
WHERE
    	TotalPrice IS NULL;

# Split OrderDate
ALTER TABLE indian_food ADD Date INT(2) AFTER `Order Date`;
ALTER TABLE indian_food ADD Month INT(2) AFTER Date;
ALTER TABLE indian_food ADD Year INT(4) AFTER Month;

UPDATE indian_food SET
	Date = substring_index(`Order Date`, '/', 1),
	Month = substring_index(substring_index(`Order Date`, '/', 2), '/', -1),
	Year = substring_index(`Order Date`, '/', -1);

# Create new table
CREATE TABLE monthly_revenue AS
	SELECT RestaurantName, Month, Year,
		SUM(TotalPrice) AS Revenue,
		SUM(Quantity) AS Orders
	FROM
		indian_food
	GROUP BY 
		RestaurantName, Month, Year
	ORDER BY 
		RestaurantName, Year, Month;

ALTER TABLE monthly_revenue DROP AverageRevenue;

# Create new column 'AverageRevenue'
ALTER TABLE monthly_revenue ADD
	AverageRevenue FLOAT(5) AFTER Orders;

UPDATE monthly_revenue
SET
	AverageRevenue = (SELECT Revenue/Orders)
WHERE
	AverageRevenue IS NULL;
    
SELECT * FROM monthly_revenue;