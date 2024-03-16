-- Copy data
\copy temp_users(first_name, last_name, password, email, street_address, city, state) FROM 'C:\Users\sethm\OneDrive\Documents\CS 340 Databases\files\users.csv' DELIMITER ',' CSV HEADER
\copy temp_products(pid, pname, cname, pcategory) FROM 'C:\Users\sethm\OneDrive\Documents\CS 340 Databases\files\products.csv' DELIMITER '|' CSV
\copy temp_services(sid, sname, cname, scategory) FROM 'C:\Users\sethm\OneDrive\Documents\CS 340 Databases\files\services.csv' DELIMITER ',' CSV HEADER

-- Data cleaning and inserting
-- User data insertion
INSERT INTO users (email, first_name, last_name, street_address, city, state) 
SELECT DISTINCT email, first_name, last_name, street_address, city, state FROM temp_users;
-- Item data insertion
-- Products
INSERT INTO item (id, type, name, description) SELECT DISTINCT pid, 'product', pname, pcategory FROM temp_products WHERE pid IS NOT NULL;
INSERT INTO company (name) SELECT DISTINCT cname from temp_products WHERE cname IS NOT NULL;
INSERT INTO company_item (co_id, item_id) SELECT DISTINCT c.id, t.pid  FROM temp_products as t INNER JOIN company as c on t.cname = c.name WHERE t.pid is NOT NULL;
-- Services
INSERT INTO item (id, type, name, description) SELECT DISTINCT sid, 'service', sname, scategory FROM temp_services WHERE sid IS NOT NULL;
INSERT INTO company (name) SELECT DISTINCT cname from temp_services WHERE cname IS NOT NULL;
INSERT INTO company_item(co_id, item_id) SELECT DISTINCT c.id, t.sid FROM temp_services as t INNER JOIN company as c on t.cname = c.name WHERE t.sid is NOT NULL;
