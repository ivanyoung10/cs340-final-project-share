

CREATE DATABASE final_project;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(254) UNIQUE,
    password VARCHAR(32),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    street_address VARCHAR(95),
    city VARCHAR(35),
    state VARCHAR(15),
    zip_code NUMERIC(9)
);

CREATE TABLE company (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(100),
    contact_tel NUMERIC(15),
    contact_email VARCHAR(255),
    url VARCHAR(255) UNIQUE
);

CREATE TABLE item (
    id VARCHAR(255),
    type VARCHAR(7),
    name VARCHAR,
    description TEXT,
    price MONEY,
    picture TEXT,
    CHECK(price >= 0::money),
    PRIMARY KEY(id)
);

CREATE TABLE discount (
    id SERIAL PRIMARY KEY,
    type VARCHAR(25),
    amt INT,
    description TEXT,
    start_date DATE,
    end_date DATE,
    CHECK(amt >= 0),
    CONSTRAINT valid_dates CHECK(start_date < end_date)
);

CREATE TABLE user_interests (
    id INT REFERENCES users(id),
    interest VARCHAR(255),
    PRIMARY KEY (id, interest)
);

CREATE TABLE user_co_preference (
    user_id INT REFERENCES users(id),
    preference_co_id INT REFERENCES company(id),
    PRIMARY KEY (user_id, preference_co_id)
);

CREATE TABLE user_item_preference (
    user_id INT REFERENCES users(id),
    item_id VARCHAR(255) REFERENCES item(id),
    PRIMARY KEY (user_id, item_id)
);

CREATE TABLE user_loc_preference (
    id INT REFERENCES users(id),
    city VARCHAR(35),
    state VARCHAR(15),
    PRIMARY KEY (id, city, state)
);

CREATE TABLE company_loc (
    co_id INT REFERENCES company(id),
    loc_id SERIAL PRIMARY KEY,
    street_address VARCHAR(95),
    city VARCHAR(35),
    state VARCHAR(15),
    zip_code NUMERIC(9),
    tel NUMERIC(16)
);

CREATE TABLE company_item (
    co_id INT REFERENCES company(id),
    item_id VARCHAR(255) REFERENCES item(id),
    is_discounted BOOLEAN DEFAULT FALSE,
    discount_id INT REFERENCES discount(id),
    PRIMARY KEY (co_id, item_id)
);

CREATE TABLE user_co_review (
    co_id INT REFERENCES company(id),
    user_id INT REFERENCES users(id),
    rating_score NUMERIC(2,1),
    comments TEXT,
    PRIMARY KEY (co_id, user_id),
    CONSTRAINT valid_rating CHECK (rating_score BETWEEN 1 AND 5)
);

CREATE TABLE user_checkin (
    checkin_id SERIAL PRIMARY KEY,
    checkin_date DATE,
    user_id INT REFERENCES users(id),
    co_id INT REFERENCES company(id),
    item_id VARCHAR(255) REFERENCES item(id),
    discount_id INT REFERENCES discount(id),
    UNIQUE (user_id, co_id, item_id, checkin_date)
);

CREATE TABLE employee (
    id SERIAL PRIMARY KEY,
    email VARCHAR(254) UNIQUE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    job_category VARCHAR(20),
    salary MONEY,
    start_date DATE,
    street_address VARCHAR(95),
    city VARCHAR(35),
    state VARCHAR(15),
    zip_code NUMERIC(9)
);

CREATE TABLE company_transaction (
    trxn_id SERIAL PRIMARY KEY,
    trxn_date DATE,
    charge_type VARCHAR(30),
    trxn_amt MONEY,
    surcharge MONEY,
    is_paid BOOLEAN DEFAULT FALSE,
    paid_date DATE,
    co_id INT REFERENCES company(id),
    CONSTRAINT valid_dates CHECK (trxn_date <= paid_date)
);
    -- CONSTRAINT CHECK (paid_date IS NOT NULL AND is_paid IS TRUE)

CREATE TABLE company_transaction_checkin (
    trxn_id INT REFERENCES company_transaction,
    checkin_id INT REFERENCES user_checkin,
    checkin_charge MONEY,
    PRIMARY KEY (trxn_id, checkin_id)
);
-- END CREATE TABLES

-- Copy data
drop table temp_users; drop table temp_products; drop table temp_services;
CREATE TABLE temp_users (
    id serial PRIMARY KEY,
    email VARCHAR DEFAULT NULL,
    password VARCHAR DEFAULT NULL,
    first_name VARCHAR DEFAULT NULL,
    last_name VARCHAR DEFAULT NULL,
    street_address VARCHAR DEFAULT NULL,
    city VARCHAR DEFAULT NULL,
    state VARCHAR DEFAULT NULL
);
\copy temp_users(first_name, last_name, password, email, street_address, city, state) FROM 'C:\Users\ivany\Downloads\files\files\users.csv'  DELIMITER ',' CSV HEADER

CREATE TABLE temp_products (
    id serial PRIMARY KEY,
    pid VARCHAR DEFAULT NULL,
    pname VARCHAR DEFAULT NULL,
    cname VARCHAR DEFAULT NULL,
    pcategory VARCHAR DEFAULT NULL
);
\copy temp_products(pid, pname, cname, pcategory) FROM 'C:\Users\ivany\Downloads\files\files\products.csv' DELIMITER '|' CSV

CREATE TABLE temp_services (
    id serial PRIMARY KEY,
    sid VARCHAR DEFAULT NULL,
    sname VARCHAR DEFAULT NULL,
    cname VARCHAR DEFAULT NULL,
    scategory VARCHAR DEFAULT NULL
);
\copy temp_services(sid, sname, cname, scategory) FROM 'C:\Users\ivany\Downloads\files\files\services.csv' DELIMITER ',' CSV HEADER

--data cleaning

---user data insertion
INSERT INTO users (email, first_name, last_name, street_address, city, state) 
SELECT DISTINCT email, first_name, last_name, street_address, city, state FROM temp_users;

--item data insertion
INSERT INTO company (name)
SELECT DISTINCT cname from temp_products
WHERE cname IS NOT NULL;

INSERT INTO item(id, type, name, description)
SELECT DISTINCT pid, 'product', pname, pcategory FROM temp_products
WHERE pid is NOT NULL;

INSERT INTO company_item(co_id, item_id)
SELECT DISTINCT c.id, t.pid  FROM temp_products as t 
INNER JOIN company as c on t.cname = c.name
WHERE t.pid is NOT NULL;

INSERT INTO item(id, type, name, description)
SELECT DISTINCT sid, 'service', sname, scategory FROM temp_services
WHERE sid is NOT NULL;

INSERT INTO company_item(co_id, item_id)
SELECT DISTINCT c.id, t.sid  FROM temp_services as t 
INNER JOIN company as c on t.cname = c.name
WHERE t.sid is NOT NULL;




-- Generate random discount data
CREATE OR REPLACE PROCEDURE gen_discount() AS $$
BEGIN
    WHILE (SELECT count(id) FROM discount) < 20 LOOP
        WITH choice AS (
            SELECT '{free, percentage, fixed, other}'::VARCHAR[] a
        )
        INSERT INTO discount (type, amt, start_date, end_date)
        VALUES (
            (SELECT a[1 + floor((random() * array_length(a, 1)))::int] FROM choice),
            (SELECT floor(random() * 99)),
            (SELECT now() - (random() * (interval '3 months'))),
            (SELECT now() + (random() * (interval '3 months')))
        );
    END LOOP;
END;
$$ LANGUAGE PLPGSQL;

-- Triggers
CREATE OR REPLACE FUNCTION fix_discount_amt() RETURNS trigger AS $$
BEGIN
    NEW.amt = 0;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;
CREATE TRIGGER discount_amt_correction
BEFORE INSERT OR UPDATE OF type ON discount
FOR EACH ROW
WHEN (NEW.type = 'free')
EXECUTE FUNCTION fix_discount_amt();

CREATE OR REPLACE FUNCTION add_company_contact() RETURNS trigger as $$
DECLARE
    users int;
BEGIN
    users = SELECT count(id) FROM users;
    NEW.contact = 
    NEW.contact_email = SELECT email FROM users WHERE id = (random())
END;
$$ LANGUAGE PLPGSQL;
CREATE TRIGGER new_company
BEFORE INSERT OF name ON company
FOR EACH ROW
EXECUTE FUNCTION add_company_contact();




-- Discount Viewer
CREATE VIEW discounts_used
AS SELECT t.day::date, COUNT(id)
FROM generate_series(
    timestamp '2023-12-18',
    timestamp '2024-6-10',
    interval '1 day'
) AS t(day)
INNER JOIN discount as d on t.day BETWEEN d.start_date AND d.end_date
GROUP by t.day::date
ORDER by t.day::date ASC;


--product list Viewer
CREATE VIEW products_list
AS SELECT name, type, price, description, picture
    FROM item
    ORDER BY name;






-- Select random choice from list
/* WITH choice AS (
    SELECT '{free, percentage, fixed, other}'::VARCHAR[] a
)
SELECT a[1 + floor((random() * array_length(a, 1)))::int] FROM choice; */


-- Helper Functions
-- Get columns
SELECT column_name FROM information_schema.columns where table_name = 'table_name' order by ordinal_position;
SELECT column_name, data_type FROM information_schema.columns where table_name = 'users' order by ordinal_position;
-- Get functions
SELECT routines.routine_name, parameters.data_type
FROM information_schema.routines
    LEFT JOIN information_schema.parameters ON routines.specific_name=parameters.specific_name
WHERE routines.specific_schema='public'
ORDER BY routines.routine_name, parameters.ordinal_position;






