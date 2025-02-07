--QUERY1: Calculate Quantity of items, Sales value & Order quantity by each Subcategory in last 12M
SELECT FORMAT_DATE('%b %Y', s.ModifiedDate) period
      ,ps.Name
      ,SUM(s.OrderQty) qty_item
      ,SUM(s.LineTotal) total_sales
      ,COUNT(DISTINCT s.SalesOrderID) order_cnt
FROM `adventureworks2019.Sales.SalesOrderDetail` s
LEFT JOIN `adventureworks2019.Production.Product` p
ON s.ProductID=p.ProductID
LEFT JOIN `adventureworks2019.Production.ProductSubcategory` ps
ON CAST(p.ProductSubcategoryID as INT) = ps.ProductSubcategoryID
WHERE DATE(s.ModifiedDate) >= (SELECT DATE_SUB(DATE(MAX(ModifiedDate)), INTERVAL 12 MONTH) 
                                       FROM `adventureworks2019.Sales.SalesOrderDetail`)
GROUP BY 1, 2 
ORDER BY 1 DESC, 2 

--QUERY2: Calculate % YoY growth rate by SubCategory & release top 3 category with highest grow rate.
SELECT FORMAT_DATE('%Y', s.ModifiedDate) period
      ,ps.Name Name
      ,SUM(s.OrderQty) qty_item
FROM `adventureworks2019.Sales.SalesOrderDetail` s
LEFT JOIN `adventureworks2019.Production.Product` p
ON s.ProductID=p.ProductID
LEFT JOIN `adventureworks2019.Production.ProductSubcategory` ps
ON CAST(p.ProductSubcategoryID as INT) = ps.ProductSubcategoryID
GROUP BY 1, 2)

,prv_by_year AS (
SELECT period
      ,Name
      ,qty_item 
      ,LAG(qty_item) OVER(PARTITION BY Name ORDER BY period) as prv_item
FROM qty_by_year)

,YoY AS (
SELECT Name 
      ,qty_item 
      ,prv_item
      ,((qty_item - prv_item)/prv_item) qty_diff
      ,DENSE_RANK() OVER(ORDER BY ((qty_item - prv_item)/prv_item) DESC) as rank
FROM prv_by_year)

SELECT Name 
      ,qty_item 
      ,prv_item
      ,ROUND(qty_diff,2) qty_diff
FROM YoY
WHERE rank in (1,2,3)
ORDER BY rank 

--QUERY3: Ranking Top 3 TeritoryID with biggest Order quantity of every year. If there's TerritoryID with same quantity in a year, do not skip the rank number
WITH territory_ordercnt AS (
SELECT FORMAT_DATE('%Y', s.ModifiedDate) yr
      ,h.TerritoryID TerritoryID
      ,SUM(s.OrderQty) order_cnt
FROM `adventureworks2019.Sales.SalesOrderDetail` s
LEFT JOIN `adventureworks2019.Sales.SalesOrderHeader` h 
ON s.SalesOrderID = h.SalesOrderID
GROUP BY 1, 2),

rank AS (
SELECT yr 
      ,TerritoryID
      ,order_cnt 
      ,DENSE_RANK() OVER(PARTITION BY yr ORDER BY order_cnt DESC) rk
FROM territory_ordercnt)

SELECT yr 
      ,TerritoryID
      ,order_cnt 
      ,rk
FROM rank
WHERE rk in (1,2,3)
ORDER BY yr DESC

--QUERY 4: Calculate Total Discount Cost belongs to Seasonal Discount for each SubCategory
SELECT 
    FORMAT_TIMESTAMP("%Y", ModifiedDate)
    , Name
    , sum(disc_cost) total_cost
FROM (
      SELECT DISTINCT a.*
      , c.Name
      , d.DiscountPct, d.Type
      , a.OrderQty * d.DiscountPct * UnitPrice as disc_cost 
      FROM `adventureworks2019.Sales.SalesOrderDetail` a
      LEFT JOIN `adventureworks2019.Production.Product` b 
            ON a.ProductID = b.ProductID
      LEFT JOIN `adventureworks2019.Production.ProductSubcategory` c 
            ON CAST(b.ProductSubcategoryID AS INT) = c.ProductSubcategoryID
      LEFT JOIN `adventureworks2019.Sales.SpecialOffer` d 
            ON a.SpecialOfferID = d.SpecialOfferID
      WHERE LOWER(d.Type) like '%seasonal discount%' 
)
GROUP BY 1,2;

--QUERY 5: Retention rate of Customer in 2014 with status of Successfully Shipped (Cohort Analysis)
WITH 
info AS (
  SELECT  
      EXTRACT(MONTH FROM ModifiedDate) month_no
      , EXTRACT(YEAR FROM ModifiedDate) year_no
      , CustomerID
      , COUNT(DISTINCT SalesOrderID) order_cnt
  FROM `adventureworks2019.Sales.SalesOrderHeader`
  WHERE FORMAT_TIMESTAMP("%Y", ModifiedDate) = '2014'
  and Status = 5
  GROUP BY 1,2,3
  ORDER BY 3,1 
),

row_num AS (--Number the order of the months they made purchases
  SELECT *
      , ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY month_no) row_numb
  FROM info 
), 

first_order AS (   --Extract the first month of purchase for each customer
  SELECT *
  FROM row_num
  WHERE row_numb = 1
), 

month_gap AS (
  SELECT 
      a.CustomerID
      , b.month_no AS month_join
      , a.month_no AS month_order
      , a.order_cnt
      , concat('M - ',a.month_no - b.month_no) AS month_diff
  FROM info a 
  LEFT JOIN first_order b 
  ON a.CustomerID = b.CustomerID
  ORDER BY 1,3
)

SELECT month_join
      , month_diff 
      , COUNT(DISTINCT CustomerID) AS customer_cnt
FROM month_gap
GROUP BY 1,2
ORDER BY 1,2;

-- QUERY 6: Trend of Stock level & MoM diff % by all product in 2011. If %gr rate is null then 0. Round to 1 decimal
WITH 
raw_data AS (
  SELECT
      EXTRACT(MONTH FROM a.ModifiedDate) AS mth 
      , EXTRACT(YEAR FROM a.ModifiedDate) AS yr 
      , b.Name
      , SUM(StockedQty) AS stock_qty

  FROM `adventureworks2019.Production.WorkOrder` a
  LEFT JOIN `adventureworks2019.Production.Product` b ON a.ProductID = b.ProductID
  WHERE FORMAT_TIMESTAMP("%Y", a.ModifiedDate) = '2011'
  GROUP BY 1,2,3
  ORDER BY 1 DESC
)

SELECT  Name
      , mth, yr 
      , stock_qty
      , stock_prv    
      , ROUND(COALESCE((stock_qty /stock_prv -1)*100 ,0) ,1) AS diff  
FROM (                                                                 
      SELECT *
      , LEAD (stock_qty) OVER (PARTITION BY Name ORDER BY mth DESC) AS stock_prv
      FROM raw_data
      )
 ORDER BY 1 ASC, 2 DESC;

-- QUERY 7:  Calculate Ratio of Stock / Sales in 2011 by product name, by month
-- Order results by month desc, ratio desc. Round Ratio to 1 decimal mom yoy
WITH 
sale_info AS (
  SELECT 
      EXTRACT(MONTH FROM a.ModifiedDate) AS mth 
     , EXTRACT(YEAR FROM a.ModifiedDate) AS yr 
     , a.ProductId
     , b.Name
     , SUM(a.OrderQty) AS sales
  FROM `adventureworks2019.Sales.SalesOrderDetail` a 
  LEFT JOIN `adventureworks2019.Production.Product` b 
    ON a.ProductID = b.ProductID
  WHERE EXTRACT(YEAR FROM A.ModifiedDate) = 2011
  GROUP BY 1,2,3,4
), 

stock_info AS (
  SELECT
      EXTRACT(MONTH FROM ModifiedDate) AS mth 
      , EXTRACT(YEAR FROM ModifiedDate) AS yr 
      , ProductId
      , SUM(StockedQty) AS stock_cnt
  FROM `adventureworks2019.Production.WorkOrder`
  WHERE EXTRACT(YEAR FROM ModifiedDate) = 2011
  GROUP BY 1,2,3
)

SELECT
      a.*
    , b.stock_cnt AS stock  --(*)
    , ROUND(COALESCE(b.stock_cnt,0) / sales,2) AS ratio
FROM sale_info a 
FULL JOIN stock_info b 
  ON a.ProductId = b.ProductId
AND a.mth = b.mth 
AND a.yr = b.yr
ORDER BY 1 DESC, 7 DESC;

--QUERY8: No of order and value at Pending status in 2014
SELECT  EXTRACT(YEAR FROM ModifiedDate) yr
      , Status
      , COUNT(DISTINCT PurchaseOrderID) order_cnt 
      , SUM(TotalDue) value
FROM `adventureworks2019.Purchasing.PurchaseOrderHeader`
WHERE EXTRACT(YEAR FROM ModifiedDate) = 2014
AND Status = 1
GROUP BY 1, 2