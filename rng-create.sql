/* This script is used to construct the RNG database. */

/* drop the database if it already exists */
DROP SCHEMA IF EXISTS rng;

/* create the database (schema) */
CREATE SCHEMA rng;

/* create department table */
CREATE TABLE rng.department (
	department_name VARCHAR(32) NOT NULL PRIMARY KEY,
	description VARCHAR(64) 
);

/* create category table */
CREATE TABLE rng.category (
	category_name VARCHAR(64) NOT NULL PRIMARY KEY,
	description VARCHAR(64) NOT NULL,
	department_fk VARCHAR(32) NOT NULL,
	CONSTRAINT CATEGORY_DEPT_FK
		FOREIGN KEY (department_fk) REFERENCES rng.department(department_name)
		ON DELETE CASCADE ON UPDATE CASCADE
);

/* create aisle_number table */
CREATE TABLE rng.aisle_number (
	category_fk VARCHAR(64) NOT NULL,
	aisle_number INT UNSIGNED NOT NULL,
	PRIMARY KEY (category_fk, aisle_number),
	CONSTRAINT AISLE_CATEGORY_FK
		FOREIGN KEY (category_fk) REFERENCES rng.category(category_name)
		ON DELETE CASCADE ON UPDATE CASCADE
);

/* create customer table */
CREATE TABLE rng.customer (
	customer_id INT UNSIGNED NOT NULL PRIMARY KEY,
	customer_name VARCHAR(64) NOT NULL,
	address VARCHAR(128) NOT NULL,
	phone_number CHAR(10) NOT NULL,
	email VARCHAR(64) NOT NULL,
	date_of_birth DATE NOT NULL,
	membership_start_date DATE NOT NULL CHECK (date_of_birth <= membership_start_date)
);

/* create product table */
CREATE TABLE rng.product (
	product_id INT UNSIGNED NOT NULL PRIMARY KEY,
	product_name VARCHAR(32) NOT NULL,
	number_of_items INT UNSIGNED NOT NULL DEFAULT 1,
	quantity INT UNSIGNED NOT NULL DEFAULT 0,
	shelf_life INT UNSIGNED,
	price FLOAT UNSIGNED NOT NULL,
	description VARCHAR(64) NOT NULL,
	category_fk VARCHAR(64) NOT NULL,
	CONSTRAINT PRODUCT_CATEGORY_FK
		FOREIGN KEY (category_fk) REFERENCES rng.category(category_name)
		ON DELETE CASCADE ON UPDATE CASCADE
);

/* create buys table */
CREATE TABLE rng.buys (
	customer_id_fk INT UNSIGNED NOT NULL,
	product_id_fk INT UNSIGNED NOT NULL,
	PRIMARY KEY (customer_id_fk, product_id_fk),
	CONSTRAINT BUYS_CUSTOMER_FK
		FOREIGN KEY (customer_id_fk) REFERENCES rng.customer(customer_id)
		ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT BUYS_PRODUCT_FK
		FOREIGN KEY (product_id_fk) REFERENCES rng.product(product_id)
		ON DELETE CASCADE ON UPDATE CASCADE
);

/* create supplier table */
CREATE TABLE rng.supplier (
	supplier_id INT UNSIGNED NOT NULL PRIMARY KEY,
	supplier_name VARCHAR(32) NOT NULL,
	phone_number CHAR(10) NOT NULL,
	email VARCHAR(64) NOT NULL,
	address VARCHAR(128) NOT NULL
);


/* create shipment table */
CREATE TABLE rng.shipment (
	shipment_id INT UNSIGNED NOT NULL PRIMARY KEY,
	weight FLOAT UNSIGNED NOT NULL,
	arrival_date_time DATETIME NOT NULL,
	departure_date_time DATETIME NOT NULL,
	supplier_id_fk INT UNSIGNED NOT NULL,
	CONSTRAINT SHIPMENT_SUPPLIER_FK
		FOREIGN KEY (supplier_id_fk) REFERENCES rng.supplier(supplier_id)
		ON DELETE CASCADE ON UPDATE CASCADE,
	CHECK (arrival_date_time > departure_date_time)
);

/* create contains table */
CREATE TABLE rng.contains (
	shipment_id_fk INT UNSIGNED NOT NULL,
	product_id_fk INT UNSIGNED NOT NULL,
	amount INT UNSIGNED NOT NULL,
	PRIMARY KEY (shipment_id_fk, product_id_fk),
	CONSTRAINT CONTAINS_SHIPMENT_FK
		FOREIGN KEY (shipment_id_fk) REFERENCES rng.shipment(shipment_id)
		ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT CONTAINS_PRODUCT_FK
		FOREIGN KEY (product_id_fk) REFERENCES rng.product(product_id)
		ON DELETE CASCADE ON UPDATE CASCADE
);

/* create position table */
CREATE TABLE rng.position (
	position_name VARCHAR(32) NOT NULL PRIMARY KEY,
	description VARCHAR(64) NOT NULL
);

/* create employee table */
CREATE TABLE rng.employee (
	employee_id INT UNSIGNED NOT NULL PRIMARY KEY,
	employee_name VARCHAR(32) NOT NULL,
	address VARCHAR(128) NOT NULL,
	date_of_birth DATE NOT NULL,
	email VARCHAR(32),
	phone_number CHAR(10) NOT NULL,
	start_date DATE NOT NULL,
	position_fk VARCHAR(32) NOT NULL,
	CONSTRAINT POSITION_FK
		FOREIGN KEY (position_fk) REFERENCES rng.position(position_name)
		ON DELETE CASCADE ON UPDATE CASCADE,
	CHECK (start_date > date_of_birth)
);

/* create involves table */
CREATE TABLE rng.involves (
	position_fk VARCHAR(32) NOT NULL,
	department_fk VARCHAR(32) NOT NULL,
	PRIMARY KEY (position_fk, department_fk),
	CONSTRAINT INVOLVES_POSITION_FK
		FOREIGN KEY (position_fk) REFERENCES rng.position(position_name)
		ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT INVOLVES_DEPT_FK
		FOREIGN KEY (department_fk) REFERENCES rng.department(department_name)
		ON DELETE CASCADE ON UPDATE CASCADE
);

/* create manager table */
CREATE TABLE rng.manager (
	employee_id_fk INT UNSIGNED NOT NULL PRIMARY KEY,
	manager_type VARCHAR(16) NOT NULL,
	CONSTRAINT MANAGER_EMPLOYEE_FK
		FOREIGN KEY (employee_id_fk) REFERENCES rng.employee(employee_id)
		ON DELETE CASCADE ON UPDATE CASCADE
);

/* create manages table */
CREATE TABLE rng.manages (
	employee_id_fk INT UNSIGNED NOT NULL,
	position_fk VARCHAR(32) NOT NULL,
	PRIMARY KEY (employee_id_fk, position_fk),
	CONSTRAINT MANAGES_EMPLOYEE_FK
		FOREIGN KEY (employee_id_fk) REFERENCES rng.employee(employee_id)
		ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT MANAGES_POSITION_FK
		FOREIGN KEY (position_fk) REFERENCES rng.position(position_name)
		ON DELETE CASCADE ON UPDATE CASCADE
);

/* create expiration_date view */
CREATE VIEW rng.expiration_date (product_id, shipment_id, expiration_date) AS
	SELECT c.product_id_fk, c.shipment_id_fk, DATE_ADD(s.departure_date_time, INTERVAL p.shelf_life DAY)
	FROM rng.contains AS c, rng.shipment AS s, rng.product AS p
	WHERE c.product_id_fk = p.product_id AND c.shipment_id_fk = s.shipment_id;

/* create total_items view */
CREATE VIEW rng.total_items (product_id, total) AS
	SELECT product_id, quantity * number_of_items
	FROM rng.product;

