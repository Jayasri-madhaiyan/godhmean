use Flipkart;

CREATE TABLE goldusers
(
userid integer,
gold_signup_date date
); 


INSERT INTO goldusers(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

select* from goldusers;


------------------------------------------------------------------------------
CREATE TABLE users
(
userid integer,
signup_date date
); 

select* from users
INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');
-------------------------------------------------------------------------------
CREATE TABLE sales
(
userid integer,
created_date date, 
product_id integer
); 

select* from sales;

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);
------------------------------------------------------------------------------------------
CREATE TABLE product
(
product_id integer,
product_name text,
price integer
); 
select* from product;
INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);
-------------------------------------------------------------------
{delete column}

delete from goldusers where userid= 1;
delete from goldusers where userid=3;
------------------------------------------------------------------
select* from goldusers;
select* from users;
select* from sales;
select* from product;

-------------------------------------------------------------------	
1 what is total amount spend customer spent on flipkart?

select a.userid,sum(b.price) total_amount_spent from (sales a inner join product b ON a.product_id = b.product_id) 
group by a.userid; 

-------------------------------------------------------------------
2. how many days has each customer visited on flipkart? 

select userid, count(created_date) from sales group by userid;  

--------------------------------------------------------------------
3. what was the first prodcut purchased by each cumtomer?

select* from (select*, rank() over(partition by userid order by created_date) rank from sales) a where rank=1;

--------------------------------------------------------------------
4. what is the most purchased item on the menu and how many times was it purchased by all customer?

select top 1 product_id, count(product_id) from sales group by product_id order by count(product_id) desc;

---------------------------------------------------------------------
5. which item was the most popular for each customer?

select* from 
(select*,rank() over(partition by userid order by cnt desc)rnk from 
(select userid, product_id, count(product_id) cnt from sales group by userid,product_id)a)b where rnk=1;

--------------------------------------------------------------------- 
6. what item was purchased first by the customer after they became a member?

select* from 
(select c.*, rank() over(partition by userid order by created_date)rnk from 
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join goldusers b on a.userid=b.userid and created_date> gold_signup_date)c)d where rnk=1;

-----------------------------------------------------------------------------------
7. which item was purchased just before the customer became a member?

select* from 
(select c.*, rank() over(partition by userid order by created_date desc)rnk from 
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join goldusers b on a.userid=b.userid and created_date<= gold_signup_date)c)d where rnk=1;

-----------------------------------------------------------------------------------
8. what is the total order and total amount spent before they became a member?

select userid, count(created_date) total_order, sum(price)total_amount_spent from
(select c.*, d.price from 
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join goldusers b on a.userid=b.userid and created_date<= gold_signup_date)c inner join 
product d on c.product_id = d.product_id)e group by userid;

-----------------------------------------------------------------------------------

9. if buying each point genarates point for eg 5rs=2 Flipkart point and each product has different purchasing points for eg for p1 5rs=1 flipkart point, for  p2 10rs=5 flipkart point
and p3 5rs-1 flipkart point 2rs-1 flipkart point 
calculate points collected by each customer and for which product most points have been given till now.

select userid,sum(total_points) total_points_earned from 
(select e.*,amt/points total_points from 
(select d.*,case when product_id=1 then 5 when product_id =2 then 2 when product_id=3 then 5 else 0 end as points from 
(select c.userid,c.product_id,sum(price) amt from 
(select a.*, b.price from sales a inner join product b on a.product_id = b.product_id)c group by userid,product_id)d)e)f group by userid;

----------------------------------------------------------------------------
10. In the first one year after a customer joins the gold program( including their join date) irrespective of what the customer has purchased 
they earn 5 Flipkart points for every 10 rs spent who earned more 1 or 3 and what was their point earnings in thier first yr?

select c.*,d.price*0.5 total_points_earned from
(select a.userid,a.created_date,a.product_id, b.gold_signup_date from sales a inner join goldusers b on a.userid=b.userid and created_date>=gold_signup_date
and created_date<= DATEADD(year,1,gold_signup_date))c inner join product d on c.product_id=d.product_id;

--------------------------------------------------------------------------------
11. rank all the transaction of customers

select *,rank()over(partition by userid order by created_date)rnk from sales;

--------------------------------------------------------------------------------
12.rank all the transaction for each memeber whenever they are a Flipkart gold memebr for every non gold memebr transaction mark as na

select e.*, case when rnk=0 then 'na' else rnk end as rnkk from 
(select c.*,cast((case when gold_signup_date is null then 0 else rank() over ( partition by userid order by created_date desc) end) as varchar)as rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a left join goldusers b on a.userid=b.userid and created_date>= gold_signup_date)c)e;

---------------------------------------------------------------------------------













