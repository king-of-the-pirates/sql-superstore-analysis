  -- ========================================
  --            PRODUCT ANALYSIS           --
  -- ======================================== 



 -- 1.     Top 5 Selling Products By Quantity 
          
           SELECT 
                  p.category AS Category,
                  p.productname AS Product,
                  SUM(o.Quantity) AS Quantity
           FROM products AS p
           JOIN orders AS o 
                  ON o.ProductID=p.ProductID
           GROUP BY 
				 p.category,
                 p.ProductName
           ORDER BY Quantity DESC
           LIMIT 5;
       
       
 -- 2.     Products With Highest Profit Margin
        
           SELECT 
                 p.category,
                 p.ProductName,
                -- o.sales,
                 SUM(o.profit)/SUM(o.sales) * 100 AS `ProfitMargin%`
           FROM orders o
           JOIN products p 
                 ON o.ProductID=p.ProductID
           GROUP BY 
			     p.category,
			     p.ProductName
               --  o.sales
           ORDER BY 
                 `ProfitMargin%` DESC
			   --  O.SALES DESC
                 LIMIT 100;
        
 
 -- 3.     Category Wise Profit 
 
           SELECT 
                 p.category AS Category,
                 ROUND(SUM(o.profit)) AS Profit
		   FROM orders o
           JOIN products p
                 ON o.ProductID=p.ProductID
           GROUP BY Category
           ORDER BY Profit DESC;
       
 
 -- 4.     Products Never Sold
 
	       SELECT 
                 p.ProductName
           FROM products AS p
           LEFT JOIN orders AS o
                 ON o.ProductID=p.ProductID
           WHERE o.ProductID IS NULL;
           
           
-- HERE I LEARNED THAT IF I USE LEFT JOIN ONLY THAT JOINS ALL PRODUCTS WITH ORDERS IT WILL STILL
-- SHOW PRODUCTS THAT WERE SOLD.
-- TO FIND PRODUCTS THAT WERE NEVER SOLD:
-- 1. USE LEFT JOIN
-- 2. KEEP ALL PRODUCTS
-- 3. CHECK WHERE THERE IS NO MATCHING ORDER
-- SO
-- LEFT JOIN KEEPS ALL PRODUCTS
-- IF A PRODUCT HAS NO MATCH IN ORDERS
-- ALL COLUMNS FROM ORDERS BECOME NULL
-- SO I FILTERED USING WHERE O.PRODUCTID IS NULL
           
 
 -- 5.     Average Discount By Product Category  
 
           SELECT 
                 p.Category AS Category,
                 AVG(o.Discount) AS AVG_discount
           FROM orders AS o
           JOIN products AS p
                 ON o.ProductID=p.ProductID
		   GROUP BY P.Category;
 
 
 -- 6.     Loss Making Products 
 
           SELECT 
                 p.Category,
                 p.ProductName,
				 SUM(o.Profit) AS Total_Loss
           FROM products AS p
           JOIN orders AS o
                 ON o.ProductID=p.ProductID
           GROUP BY 
                 p.category,
                 p.ProductName
           HAVING SUM(Profit) < 0      
           ORDER BY Total_Loss
           LIMIT 10;
 
--  HERE I LEARNED THAT IF I DO THIS QUERY WITHOUT SUM AND HAVING I'LL GET LOSSMAKING ORDERS 
--  BECAUSE A PRODUCT MAY LOSE MONEY IN ONE ORDER BUT
--          MAKE MONEY IN ANOTHER ORDER........
--          SO THE GOAL IS TO SHOW LOSS MAKING PRODUCTS OVERALL FOR THAT AGGREGATION AND HAVING IS 
--          NECESSARY TO USE
 
 
 -- 7.     Total Sales By Category
  
		   SELECT 
                 p.Category,
                 SUM(o.Sales) AS Total_Sales
		   FROM orders AS o	
           JOIN products AS p
                 ON o.ProductID=p.ProductID
           GROUP BY p.Category;
 
 
 -- 8.     Top 3 Products Per Category    
				
           WITH ProductRanking AS (
                SELECT p.Category,
                       p.ProductName,
                       SUM(o.Sales) AS Total_Sales,
                       DENSE_RANK() OVER (
                                           PARTITION BY p.Category
                                           ORDER BY SUM(o.Sales) DESC
                                                                      ) AS Sales_Rank
                FROM orders AS o
                JOIN products AS p
					   ON p.ProductID=o.ProductID
                GROUP BY 
                       p.Category,
                       p.ProductName
           )
                SELECT * FROM ProductRanking
                WHERE Sales_Rank <=3;
                
                
--      I CANNOT USE A WINDOW FUNCTION RESULT LIKE SALES RANK IN a where clause in the same
--      query.
--      SQL processes WHERE before it processe the window function. BY putting
--      the ranking aside a CTE (the with block),
--      i froze that calculation so i can filter it in 
--      the final SELECT
             
             
                
  -- ========================================
  --            REGIONAL ANALYSIS          --
  -- ========================================



-- 9.      Which Region Has Highest Profit

           SELECT c.Region,
			      ROUND(SUM(o.profit)) AS Profit
           FROM customers AS c
           JOIN orders AS o
                  ON c.CustomerID=o.CustomerID
           GROUP BY c.Region
           ORDER BY SUM(o.profit) DESC
           LIMIT 1;        


-- 10.      Lowest Revenue Region

            WITH Total_Revenue_Per_Region AS(
                 SELECT 
                       c.Region AS Lowest_REV_Region,
                       SUM(o.Sales) AS Total_Regional_Rev
				 FROM customers AS c
                 JOIN orders AS o
                       ON c.CustomerID=o.CustomerID
                 GROUP BY
                       c.Region
            )
                 SELECT 
                       Lowest_REV_Region,
                       Total_Regional_Rev
                 FROM  Total_Revenue_Per_Region
                 ORDER BY 
					   Total_Regional_Rev ASC
                 LIMIT 1;


-- 11.      Category Wise Sales By Region

			   SELECT 
					 c.Region,
				     p.Category,
					 SUM(o.Sales) AS Total_Sales
			   FROM orders AS o
			   JOIN products AS p
					 ON o.ProductID=p.ProductID
			   JOIN customers AS c 
					 ON c.CustomerID=o.CustomerID
			   GROUP BY  
					 c.Region,
					 p.Category;


-- 12.      Second Highest Revenue Customer  
            
	    -- 1 FASTER QUERY SPEED
	        SELECT 
                  c.CustomerID,
                  c.CustomerName,
                  SUM(o.Sales) AS Revenue
            FROM orders AS o
            JOIN Customers AS c
                  ON c.CustomerID=o.CustomerID
            GROUP BY  
				  c.CustomerID,
                  c.CustomerName
            ORDER BY SUM(o.Sales) DESC
            LIMIT 1
            OFFSET 1;
            
            
        -- 2 SLIGHTYLY SLOWER QUERY SPEED
            WITH CustomerRevenue AS (
				 SELECT 
                       c.CustomerID,
                       c.CustomerName,
                       SUM(o.Sales) AS Revenue,
                       DENSE_RANK() OVER ( ORDER BY SUM(o.Sales) DESC ) AS Revenue_Rank
                 FROM orders AS o
                 JOIN Customers AS c
                      ON o.CustomerID=c.CustomerID
                 GROUP BY 
                      c.CustomerID,
					  c.CustomerName
            )
                SELECT * FROM CustomerRevenue
                WHERE Revenue_Rank = 2;
                  
               
               
  -- ========================================
  --            CUSTOMER ANALYSIS          --
  -- ========================================


-- 13.      Total Customers Per Region 

           SELECT 
                 Region,
                 COUNT(DISTINCT CustomerID) AS Total_Customers
           FROM customers
           GROUP BY Region
           ORDER BY COUNT(DISTINCT CustomerID) DESC ;   
            
            
-- 14.      Customers With No Orders
           
            SELECT 
                  c.CustomerID,
                  c.CustomerName
            FROM customers AS c 
            LEFT JOIN orders AS o 
                  ON c.CustomerID=o.CustomerID
            WHERE o.OrderID IS NULL;
                 
-- 15.      Repeated Customers (More Than 1 Order)

            SELECT 
                  c.CustomerID,
                  c.CustomerName,
                  COUNT(o.orderID) AS OrderCount
            FROM orders AS o
            JOIN customers AS c
                  ON c.CustomerID=o.CustomerID
            GROUP BY  
                  c.CustomerID,
                  c.CustomerName
            HAVING COUNT(o.orderID) > 1;
                  
            
-- 16.      Average Revenue Per Customer

            SELECT 
				  c.CustomerID,
                  c.CustomerName,
                  AVG(o.Sales) AS Average_sales
            FROM orders AS o
            JOIN customers AS c
                  ON c.CustomerID=o.CustomerID
            GROUP BY  
                  c.CustomerID,
                  c.CustomerName  ;         
              

-- 17.      Top Customers Per Region

	   -- 1 MORE READABLE USING CTE
       
			WITH TopCustomers AS (
                 SELECT
                       c.Region,
                       c.CustomerId,
                       c.CustomerName,
                       SUM(o.Sales) AS Total_Sales,
                       DENSE_RANK() OVER (PARTITION BY c.Region
										  ORDER BY SUM(o.Sales) DESC) AS Customer_Rank
                 FROM orders AS o
                 JOIN customers AS c 
                       ON o.CustomerID=c.CustomerID
                 GROUP BY       
                       c.Region,
                       c.CustomerId,
                       c.CustomerName
            )
               SELECT * FROM TopCustomers 
               WHERE Customer_Rank = 1;
               
      -- 2 ALMOST THE SAME BUT CAN GET MESSY IF MULTIPLE SUBQUERIES ARE USED
      
            SELECT * FROM (
                    SELECT c.Region,
                           c.CustomerId,
                           c.CustomerName,
                           SUM(o.Sales) AS Total_Sales,
                           DENSE_RANK() OVER (PARTITION BY c.Region
                                               ORDER BY SUM(o.Sales) DESC) AS Customer_Rank
                    FROM orders AS o
                    JOIN customers AS c
                           ON o.CustomerID=C.CustomerID
                    GROUP BY 
                           c.Region,
                           c.CustomerId,
                           c.CustomerName
            ) AS RankedTable
            WHERE Customer_Rank = 1;
            

-- 18.      Customers Contributing To Top 20% Revenue   -- 

			WITH CustomerRevenue AS (
                 SELECT 
					   c.CustomerName,
                       SUM(o.Sales) AS Total_Revenue
                 FROM orders AS o
                 JOIN customers AS c 
                       ON o.CustomerID=c.CustomerID
                 GROUP BY c.CustomerName      
            ),
                 RUNNINGTOTALS AS (
                 SELECT
                       CustomerName,
                       total_revenue,
                       sum(Total_Revenue) over (order by Total_Revenue  desc) as Running_Total,
                       sum(Total_Revenue) over() as GrandTotal
                       from CustomerRevenue
            )
                select 
                       CustomerName,
                       Total_Revenue 
                       from RUNNINGTOTALS 
                       where Running_Total <=(GrandTotal * 0.20);


-- 19.      Top 5 Customers By Revenue

			SELECT 
                  c.CustomerName,
                  SUM(o.sales) AS Total_Revenue
            FROM orders AS o
            JOIN customers AS c
				 ON c.CustomerID=o.CustomerID
            GROUP BY 
                    c.CustomerName
            ORDER BY 
                    SUM(o.sales) DESC
            LIMIT 5 ; 
                   
            
            
-- 20.      Customers With Orders Above Average Order Value  
            
                   SELECT 
                         c.CustomerID,
                         c.CustomerName,
                         SUM(o.sales) AS Total_Customer_Sales
                   FROM  customers AS C
                   JOIn Orders AS o
                        ON c.CustomerID=o.CustomerID
                   GROUP BY
                          c.CustomerID,
                         c.CustomerName
                   HAVING SUM(o.Sales) > (SELECT AVG(Sales) FROM orders)      
				   ORDER BY SUM(o.sales) DESC ; 
                         
  -- ========================================
  --         TIME BASED ANALYSIS       --
  -- ========================================


-- 21.      Year_Wise Sales

            SELECT
                  YEAR(orderDate) AS SalesYear,
                  SUM(Sales) AS Total_Sales
            FROM orders
            GROUP BY YEAR(orderDate)
            ORDER BY YEAR(orderDate);
            
-- 22.      Month-Over-Month Sales Growth

            WITH Monthly_Sales AS (
				  SELECT 
				  YEAR(OrderDate) AS Sales_Year,
				  MONTHNAME(OrderDate) AS Sales_Month,
                       MONTH(OrderDate) AS MONTH_NUM,
                       SUM(Sales) AS Total_Sales
                 FROM orders
                 GROUP BY 
                      YEAR(OrderDate),
                       MONTHNAME(OrderDate),
                      MONTH(OrderDate)
)
                   SELECT 
                         Sales_Year,
                         Sales_Month,
                         Total_Sales,
                         LAG(Total_Sales) OVER (ORDER BY Sales_Year,MONTH_NUM) AS Previous_Month_Sales,
                         ((Total_Sales - LAG(Total_Sales) OVER (ORDER BY Sales_Year,MONTH_NUM))
                                                   *100     /
				        (LAG(Total_Sales) OVER (ORDER BY Sales_Year,MONTH_NUM)))  AS MoM_Growth_Percentage
				   FROM Monthly_Sales
				   ORDER BY  
					       Sales_Year,
						   MONTH_NUM;

-- 23.      Month With Highest Sales

            SELECT 
                  MONTHNAME(OrderDate) AS Month_Name,
                  SUM(Sales) AS Total_Sales
            FROM orders
            GROUP BY Month_Name
            ORDER BY SUM(Sales) DESC
            LIMIT 1;

-- 24.      Month With Lowest Profit

            SELECT 
                  MONTHNAME(OrderDate) AS Month_Name,
                  ROUND(SUM(Profit)) AS Lowest_Profit
            FROM orders
            GROUP BY Month_Name
            ORDER BY SUM(Profit)
            LIMIT 1;      

-- 25.      Quarterly Sales Trend

            SELECT 
                 YEAR(OrderDate) AS Sales_Year,
                 QUARTER(OrderDate) AS Sales_QUARTER,
                 SUM(Sales) AS Total_Sales
            FROM orders
            GROUP BY 
                 YEAR(OrderDate),
                 QUARTER(OrderDate)
            ORDER BY  
                 YEAR(OrderDate),
                 QUARTER(OrderDate);
            

-- 26.      Monthly Sales trend 


            SELECT 
                  YEAR(OrderDate) AS Sales_Year,
                  -- Month(OrderDate) AS Month_NUM,
                  MonthNAME(OrderDate) as Sales_Month,
                  SUM(Sales) AS Total_Sales
            FROM orders
            GROUP BY 
                  YEAR(OrderDate),
                  month(OrderDate),
				  MonthName(OrderDate)
            ORDER BY
				  YEAR(OrderDate),
                  month(OrderDate);