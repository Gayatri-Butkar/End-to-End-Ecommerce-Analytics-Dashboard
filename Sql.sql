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
product_name_length int,
product_description_length int,
product_photos_qty int ,
product_weight_g int ,
product_length_cm int,
product_height_cm int ,
product_width_cm int
);

Load Data 
 
 
 
