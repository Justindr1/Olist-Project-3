CREATE DATABASE olist_project;
USE olist_project;

/* 
First issue I ran into is  this was originally 

CREATE TABLE olist_orders_raw (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

The DATETIME data was throwing issues with the NULL values in the CSV causing an error later when I wanted to import data, needed to change the date values to VARCHAR
*/

/*
Creating initial tables
*/

CREATE TABLE olist_orders_raw (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp VARCHAR(50),
    order_approved_at VARCHAR(50),
    order_delivered_carrier_date VARCHAR(50),
    order_delivered_customer_date VARCHAR(50),
    order_estimated_delivery_date VARCHAR(50)
);


CREATE TABLE olist_order_items_raw(
	order_id varchar(50),
    order_item_id INT,
    product_id varchar(50),
    seller_id varchar(50),
    shipping_limit_date datetime,
    price decimal(10,2),
    freight_value decimal(10,2),
    PRIMARY KEY (order_id, Order_item_id)
    );
    
CREATE TABLE olist_customer_raw (
	customer_id varchar(50) PRIMARY KEY,
    customer_unique_id varchar(50),
    customer_zip_code INT,
    customer_city varchar(100),
    customer_state varchar(2)
    );
    
CREATE TABLE olist_seller_raw (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(2)
);
    
    
CREATE TABLE olist_reviews_raw (
	review_id varchar(50),
    order_id varchar(50),
    review_score INT,
    review_commnet_title TEXT,
    review_comment_message TEXT,
    review_creation_date varchar(50),
    review_answer_timestamp varchar(50)
    );

/* 
Used this to find the file path for loading in data:
	SHOW VARIABLES LIKE 'secure_file_priv';
*/
/*
Useful if new items are needed to be incorporated

drop table if exists olist_orders_raw ;
drop table if exists olist_order_items_raw ;
drop table if exists olist_customer_raw ;
drop table if exists olist_seller_raw ;
drop table if exists olist_reviews_raw ;
*/

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
INTO TABLE olist_order_items_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv'
INTO TABLE olist_orders_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv'
INTO TABLE olist_customer_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv'
INTO TABLE olist_seller_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_dataset.csv'
INTO TABLE olist_reviews_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
/* 
Creating cleaned tables where I needed to change date time from varchar to datetime data types
*/

CREATE OR REPLACE VIEW vw_orders AS
SELECT
    order_id,
    customer_id,
    order_status,
    CAST(order_purchase_timestamp AS DATETIME) AS order_purchase_timestamp,
    CAST(order_approved_at AS DATETIME) AS order_approved_at,
    CAST(order_delivered_carrier_date AS DATETIME) AS order_delivered_carrier_date,
    CAST(order_delivered_customer_date AS DATETIME) AS order_delivered_customer_date,
    CAST(order_estimated_delivery_date AS DATETIME) AS order_estimated_delivery_date,
    DATEDIFF(
        CAST(order_delivered_customer_date AS DATETIME),
        CAST(order_estimated_delivery_date AS DATETIME)
    ) AS delivery_delay_days,
    CASE 
        WHEN DATEDIFF(
            CAST(order_delivered_customer_date AS DATETIME),
            CAST(order_estimated_delivery_date AS DATETIME)
        ) > 0 THEN 1
        ELSE 0
    END AS late_delivery_flag
FROM olist_orders_raw;

describe vw_orders;

CREATE OR REPLACE VIEW vw_order_items AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    CAST(shipping_limit_date AS DATETIME) AS shipping_limit_date,
    price,
    freight_value
FROM olist_order_items_raw;

describe vw_order_items;

CREATE OR REPLACE VIEW vw_sellers AS
SELECT
    seller_id,
    seller_zip_code,
    seller_city,
    seller_state
FROM olist_seller_raw;

CREATE OR REPLACE VIEW vw_reviews AS
SELECT
    review_id,
    order_id,
    review_score,
    review_commnet_title AS review_comment_title,
    review_comment_message,
    CAST(review_creation_date AS DATETIME) AS review_creation_date,
    CAST(review_answer_timestamp AS DATETIME) AS review_answer_timestamp
FROM olist_reviews_raw;

/*
Creating Master File
*/

CREATE OR REPLACE VIEW vw_full_orders AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    c.customer_zip_code,

    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    o.delivery_delay_days,
    o.late_delivery_flag,

    i.order_item_id,
    i.product_id,
    i.seller_id,
    i.shipping_limit_date,
    i.price,
    i.freight_value,

    r.review_id,
    r.review_score,
    r.review_comment_title,
    r.review_comment_message,
    r.review_creation_date,
    r.review_answer_timestamp

FROM vw_orders o
LEFT JOIN vw_order_items i ON o.order_id = i.order_id
LEFT JOIN olist_customer_raw c ON o.customer_id = c.customer_id
LEFT JOIN vw_reviews r ON o.order_id = r.order_id;

describe vw_full_orders;


SELECT *
FROM vw_full_orders
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/vw_full_orders.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';


SELECT COUNT(*) FROM olist_orders_raw;