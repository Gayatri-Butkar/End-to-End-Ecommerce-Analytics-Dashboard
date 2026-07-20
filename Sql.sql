create database  if not exists  olist_ecommerce;

use olist_ecommerce;

create table dim_customers
( customer_id varchar(32) NOT Null,
 customer_unique_id varchar(32) not null,
 customer_zip_code_prefix varchar(10),
 customer_city varchar(100),
 customer_state varchar(2),
 
 primary key(customer_id)
 
 );
 
 show tables;
 
 desc dim_customers;
 
 
 
 SHOW VARIABLES LIKE 'secure_file_priv'; 
 
 Load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv"
 into table dim_customers 
 fields terminated by ','
 enclosed by '"'
 lines terminated by "\n"
 ignore 1 rows ;
 
 SELECT @@GLOBAL.secure_file_priv;
 
 
 select COUNT(*) from dim_customers;
 
 select * from dim_customers Limit 5;
 
Create table dim_products(
product_id varchar(32) not null,
product_category_name varchar(50),
product_category_name_english varchar(50),
product_name_length int,
product_description_length int,
product_photos_qty int ,
product_weight_g int ,
product_length_cm int,
product_height_cm int ,
product_width_cm int,
primary key(product_id)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv'
INTO TABLE dim_products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_category_name, @name_len, @desc_len, @photos_qty, @weight, @length, @height, @width)
SET
    product_name_length        = NULLIF(@name_len, ''),  /*@name_len is a user-defined variable that temporarily holds the value of product_name_length from the CSV file. The NULLIF function is used to convert empty strings to NULL values in the database. This ensures that if the CSV file has missing values for product_name_length, they will be stored as NULL in the dim_products table. */
    product_description_length = NULLIF(@desc_len, ''),
    product_photos_qty         = NULLIF(@photos_qty, ''),
    product_weight_g           = NULLIF(@weight, ''),
    product_length_cm          = NULLIF(@length, ''),
    product_height_cm          = NULLIF(@height, ''),
    product_width_cm           = NULLIF(@width, '');
 
select count(*) from dim_products;

select * from dim_products limit 5;

SELECT COUNT(*) FROM dim_products WHERE product_category_name IS NULL OR product_category_name = '';

SET SQL_SAFE_UPDATES = 0;

update dim_products 
set product_category_name = 'unknown'
where product_category_name = '' or product_category_name is null;
 
 create table category_translation 
 (product_category_name varchar(50) not null,
 product_category_name_english varchar(50),
 primary key(product_category_name));
 
 Load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv'
 into table category_translation 
 fields terminated by ','
 enclosed by '"'
 lines terminated by '\n'
 Ignore 1 rows;
 
 select count(*) from category_translation ;
 
 SELECT COUNT(*) FROM dim_products WHERE product_category_name = '' OR product_category_name IS NULL;
 
 SELECT * FROM category_translation LIMIT 3;
 
 set sql_safe_updates = 0;
 
 update dim_products p 
 Join category_translation t on p.product_category_name = t.product_category_name 
 set p.product_category_name_english = t.product_category_name_english;
 
 SELECT COUNT(*) FROM dim_products WHERE product_category_name_english IS NULL;
 
 select * from dim_products limit 3;
 
 SELECT DISTINCT product_category_name
FROM dim_products
WHERE product_category_name_english IS NULL
  AND product_category_name != 'unknown';
  
update dim_products 
set product_category_name_english = "pc_gamer"  
where product_category_name = "pc_gamer" ;

update dim_products  
set product_category_name_english = "ktichen_portable_food_preparers"
where product_category_name = "portateis_cozinha_e_preparadores_de_alimentos";

update dim_products 
set product_category_name_english = "unknown"
where product_category_name = "unknown";

create table dim_seller 
(seller_id varchar(50) not null , 
seller_zip_prefix_code varchar (10), 
seller_city varchar(50) , 
seller_state varchar(50), 
primary key(seller_id));


load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv'
into table dim_seller 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
Ignore 1 rows ;

select count(*) from dim_seller;

select * from dim_seller limit 5;


/* Staging table */
create table stg_order_items (
order_id varchar(50) not null,
order_item_id int,
product_id varchar(50),
seller_id varchar(50),
shipping_limit_date datetime ,
price decimal(10,2)  ,
freight_value decimal(10,2),
primary key (order_id , order_item_id)
);

create table stg_orders (
order_id varchar(50) not null,
customer_id varchar(50),
order_status varchar(50),
order_purchase_timestamp datetime ,
order_approved_at datetime,
order_delivered_carrier_date datetime,
order_delivered_customer_date datetime,
order_estimated_delivery_date datetime);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
into table stg_order_items 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows ;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv'
INTO TABLE stg_orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status, @purchase_ts, @approved_ts, @carrier_ts, @delivered_ts, @estimated_ts)
SET
    order_purchase_timestamp      = NULLIF(@purchase_ts, ''),
    order_approved_at             = NULLIF(@approved_ts, ''),
    order_delivered_carrier_date  = NULLIF(@carrier_ts, ''),
    order_delivered_customer_date = NULLIF(@delivered_ts, ''),
    order_estimated_delivery_date = NULLIF(@estimated_ts, '');

TRUNCATE TABLE stg_orders;

SELECT COUNT(*) FROM stg_orders;

SELECT COUNT(*) FROM stg_order_items;

/* FACT TABLE */

create table fact_order_items 
(order_id varchar(50) not null,
order_item_id int not null,
customer_id varchar(50),
product_id varchar(50),
seller_id varchar(50),
order_status varchar(50),
order_date datetime,
quantity int,
price Decimal(10,2),
freight_value decimal(10,2),
total_sales Decimal(10,2),
month TINYINT ,
year smallint,
primary key(order_id,order_item_id),
foreign key(customer_id) references dim_customers(customer_id),
foreign key(seller_id) references dim_seller(seller_id)
);


INSERT INTO fact_order_items
(order_id, order_item_id, customer_id, product_id, seller_id, order_status,
 order_date, quantity, price, freight_value, total_sales, month, year)
SELECT
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    o.order_status,
    o.order_purchase_timestamp,
    1                                        AS quantity,
    oi.price,
    oi.freight_value,
    oi.price * 1                             AS total_sales,
    MONTH(o.order_purchase_timestamp)        AS month,
    YEAR(o.order_purchase_timestamp)         AS year
FROM stg_order_items oi
JOIN stg_orders o ON oi.order_id = o.order_id;


SELECT COUNT(*) FROM fact_order_items;

SELECT MIN(order_date), MAX(order_date) FROM fact_order_items;

SELECT SUM(total_sales) FROM fact_order_items;

SELECT
    product_id,
    SUM(total_sales) AS revenue,
    COUNT(*) AS units_sold
FROM fact_order_items
GROUP BY product_id
ORDER BY revenue DESC
LIMIT 10;

SELECT
    customer_id,
    SUM(total_sales) AS revenue,
    COUNT(*) AS units_sold
FROM fact_order_items
GROUP BY customer_id
ORDER BY revenue DESC
limit 10;



 
 
