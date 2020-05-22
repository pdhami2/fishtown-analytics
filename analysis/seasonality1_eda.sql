--Looking at revenue by month, would you say that there is seasonality for this business? 

--Part 1 : EDA to see how total months & revenue per month 
--Assumption: Analyzing Gross amount

select distinct date_trunc(date(created_at), month) as created_month, round(sum(gross_total_amount_cents),2) as month_gross_amount
from `dbt-analytics-00`.`dbt_pdhamija`.`core__orders`
group by 1
order by 1;

--Conclusion : Only three months of data with increasing gross amounts each month
