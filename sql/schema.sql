-- MySQL 8+ table definitions for the Automotive SQL Practice Pack
CREATE DATABASE IF NOT EXISTS auto_parts_practice;
USE auto_parts_practice;

CREATE TABLE categories (
  category_id INT PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL
);
CREATE TABLE suppliers (
  supplier_id INT PRIMARY KEY,
  supplier_name VARCHAR(150) NOT NULL,
  country VARCHAR(50),
  supplier_tier VARCHAR(30),
  active_flag CHAR(1),
  onboarded_date DATE
);
CREATE TABLE products (
  product_id INT PRIMARY KEY,
  part_number VARCHAR(30) NOT NULL,
  product_name VARCHAR(200),
  category_id INT,
  supplier_id INT,
  brand VARCHAR(80),
  part_type VARCHAR(80),
  oem_flag CHAR(1),
  unit_cost DECIMAL(10,2),
  list_price DECIMAL(10,2),
  active_flag CHAR(1),
  created_date DATE,
  INDEX idx_products_category (category_id),
  INDEX idx_products_supplier (supplier_id),
  INDEX idx_products_part_type (part_type)
);
CREATE TABLE inventory (
  inventory_id INT PRIMARY KEY,
  product_id INT,
  warehouse_id INT,
  on_hand_qty INT,
  reserved_qty INT,
  reorder_level INT,
  last_updated DATE,
  INDEX idx_inventory_product (product_id),
  INDEX idx_inventory_warehouse (warehouse_id)
);
CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(100),
  customer_type VARCHAR(30),
  city VARCHAR(80),
  state_region VARCHAR(30),
  signup_date DATE
);
CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  order_status VARCHAR(30),
  sales_channel VARCHAR(30),
  shipping_country VARCHAR(50),
  INDEX idx_orders_customer (customer_id),
  INDEX idx_orders_date (order_date)
);
CREATE TABLE order_lines (
  order_line_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  unit_sale_price DECIMAL(10,2),
  discount_pct DECIMAL(4,2),
  line_status VARCHAR(30),
  INDEX idx_order_lines_order (order_id),
  INDEX idx_order_lines_product (product_id)
);
