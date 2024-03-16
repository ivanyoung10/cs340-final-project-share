DROP TABLE users CASCADE; DROP TABLE company CASCADE; DROP TABLE item CASCADE; DROP TABLE discount CASCADE; DROP TABLE user_interests; DROP TABLE user_co_preference; DROP TABLE user_item_preference; DROP TABLE user_loc_preference; DROP TABLE company_loc; DROP TABLE company_item; DROP TABLE user_co_review; DROP TABLE user_checkin CASCADE; DROP TABLE employee; DROP TABLE company_transaction CASCADE; DROP TABLE company_transaction_checkin; DROP TABLE item_archive;

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
    id VARCHAR PRIMARY KEY,
    type VARCHAR(7),
    name VARCHAR,
    description TEXT,
    price MONEY,
    picture TEXT,
    CHECK(price >= 0::money)
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
    item_id VARCHAR REFERENCES item(id),
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
    item_id VARCHAR REFERENCES item(id),
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
    item_id VARCHAR REFERENCES item(id),
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

CREATE TABLE company_transaction_checkin (
    trxn_id INT REFERENCES company_transaction,
    checkin_id INT REFERENCES user_checkin,
    checkin_charge MONEY,
    PRIMARY KEY (trxn_id, checkin_id)
);

-- Archive item data
CREATE TABLE item_archive (
    id VARCHAR,
    attribute_name VARCHAR,
    old_value VARCHAR,
    new_value VARCHAR,
    archive_time TIMESTAMP,
    PRIMARY KEY(id, archive_time)
);

-- Temp tables for data insertion
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
CREATE TABLE temp_products (
    id serial PRIMARY KEY,
    pid VARCHAR DEFAULT NULL,
    pname VARCHAR DEFAULT NULL,
    cname VARCHAR DEFAULT NULL,
    pcategory VARCHAR DEFAULT NULL
);
CREATE TABLE temp_services (
    id serial PRIMARY KEY,
    sid VARCHAR DEFAULT NULL,
    sname VARCHAR DEFAULT NULL,
    cname VARCHAR DEFAULT NULL,
    scategory VARCHAR DEFAULT NULL
);