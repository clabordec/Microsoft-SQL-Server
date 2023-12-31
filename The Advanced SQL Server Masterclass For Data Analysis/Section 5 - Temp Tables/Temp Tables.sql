-- Compare the total amount of sales and purchases at the start of each month
with RankingSales as (
	select OrderDate,
	       TotalDue,
	       OrderMonth = datefromparts(year(OrderDate), month(OrderDate), 1),
	       OrderRank = row_number() over(partition by datefromparts(year(OrderDate), month(OrderDate), 1) order by TotalDue)
	from Sales.SalesOrderHeader
),
OrderMonthlySales as (
	select OrderMonth, 
	       TotalSales = sum(TotalDue) 
	from RankingSales
	where OrderRank <= 10
	group by OrderMonth
),
RankingPurchases as (
	select OrderDate,
	       TotalDue,
	       OrderMonth = datefromparts(year(OrderDate), month(OrderDate), 1),
	       OrderRank = row_number() over(partition by datefromparts(year(OrderDate), month(OrderDate), 1) order by TotalDue)
	from Purchasing.PurchaseOrderHeader
),
OrderMonthlyPurchases as (
	select OrderMonth,
	       TotalPurchases = sum(TotalDue)
	from RankingPurchases
	group by OrderMonth
),
TotalSalesAndPurchases as (
	select oms.OrderMonth,
	       oms.TotalSales,
	       omp.TotalPurchases
	from OrderMonthlySales oms
	left join OrderMonthlyPurchases omp
	on oms.OrderMonth = omp.OrderMonth
)
select * from TotalSalesAndPurchases order by 1 asc


-- Same code as the CTE above, but in a Temporary Tables
select OrderDate,
       TotalDue,
       OrderMonth = datefromparts(year(OrderDate), month(OrderDate), 1),
       OrderRank = row_number() over(partition by datefromparts(year(OrderDate), month(OrderDate), 1) order by TotalDue)
into #RankingSales
from Sales.SalesOrderHeader

select * from #RankingSales


-- Get the total sales for each order month
select OrderMonth, 
       TotalSales = sum(TotalDue) 
into #OrderMonthlySales
from #RankingSales
where OrderRank <= 10
group by OrderMonth

select * from #OrderMonthlySales


-- Get certain records with the start of the order month and rank each month by it's total due in descending order
select OrderDate,
       TotalDue,
       OrderMonth = datefromparts(year(OrderDate), month(OrderDate), 1),
       OrderRank = row_number() over(partition by datefromparts(year(OrderDate), month(OrderDate), 1) order by TotalDue)
into #RankingPurchases
from Purchasing.PurchaseOrderHeader

select * from #RankingPurchases

-- Get the total purchases for each order month
select OrderMonth,
       TotalPurchases = sum(TotalDue)
into #OrderMonthlyPurchases
from #RankingPurchases
group by OrderMonth

select * from #OrderMonthlyPurchases


-- Compare the total sales from the total purchases from the the orders months
select oms.OrderMonth,
       oms.TotalSales,
       omp.TotalPurchases
into #TotalSalesAndPurchases
from #OrderMonthlySales oms
left join #OrderMonthlyPurchases omp
on oms.OrderMonth = omp.OrderMonth

select * from #TotalSalesAndPurchases
