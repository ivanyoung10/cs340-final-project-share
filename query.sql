
CREATE Table USER_TABLE(
    user_id char UNIQUE,
    user_email char,
    password char,
    first_name char,
    last_name char,
    street_address char,
    city char,
    state char,
    zip_code int,
    PRIMARY KEY(user_id)
);

INSERT INTO USER_TABLE
VALUES (1010, 'john@gmail.com', 'password', 'john', 'smith', '123 Jefferson St', 'Bend', 'Oregon', '97701');

INSERT INTO USER_TABLE
VALUES (1011, 'kate@gmail.com', 'password', 'kate', 'smith', '123 Jefferson St', 'Bend', 'Oregon', '97701');

INSERT INTO USER_TABLE
VALUES (6, 'travis@gmail.com', 'password', 'travis', 'scott', '903 Aubrey Ln', 'Los Angeles', 'California', '90210');

CREATE TABLE USER_INTERESTS(
    user_id int,
    interest VARCHAR(255),
    PRIMARY KEY(interest),
    FOREIGN KEY(user_id) REFERENCES USER_TABLE(user_id)
);

CREATE TABLE USER_COMPANY_PREFERENCE(
    user_id int,
    preference_company_id int,
    FOREIGN KEY(user_id) REFERENCES user_table(user_id),
    FOREIGN KEY(preference_company_id) REFERENCES USER_TABLE(user_id)
);

CREATE TABLE USER_ITEM_PREFERENCE(
    user_id int,
    preference_location_city VARCHAR(255),
    preference_location_state VARCHAR(255),
    FOREIGN KEY(user_id) REFERENCES USER_TABLE(user_id)
);

CREATE TABLE COMPANY(
    company_id int, 
    company_name VARCHAR(255), 
    company_contact VARCHAR(255), 
    company_contact_phone_nbr int,
    company_contact_email VARCHAR(255), 
    url VARCHAR(255),
    PRIMARY KEY(company_id)
);

CREATE TABLE COMPANY_LOCATION(
    company_id int, 
    location_id int, 
    street_address VARCHAR(255), 
    city VARCHAR(255), 
    state VARCHAR(255), 
    zip_code int, 
    phone_nbr int,
    FOREIGN KEY(company_id) REFERENCES COMPANY(company_id)
);

CREATE TABLE COMPANY_ITEM(
company_id int, 
item_id int, 
is_discounted VARCHAR(5), 
discount_id int,
FOREIGN KEY(company_id) REFERENCES COMPANY(company_id),
FOREIGN KEY(item_id) REFERENCES ITEM(item_id),
FOREIGN KEY(discount_id) REFERENCES DISCOUNT(discount_id)
);

CREATE TABLE User_Company_Review
(company_id int, 
user_id int, 
rating_score int, 
comments VARCHAR(255),
FOREIGN KEY(company_id) REFERENCES COMPANY(company_id),
FOREIGN KEY(user_id) REFERENCES USER_TABLE(user_id)
);

CREATE TABLE Item(item_id int, 
item_type VARCHAR(255), 
item_name VARCHAR(255), 
item_description VARCHAR(255), 
item_price float, 
item_picture int,
PRIMARY KEY(item_id)
);

CREATE TABLE Discount(discount_id int, 
discount_type VARCHAR(255), 
discount_amount float, 
discount_description VARCHAR(255),
discount_start_date date, 
discount_end_date date,
PRIMARY KEY(discount_id)
);

CREATE TABLE User_Checkin (checkin_id int, 
checkin_date date, 
user_id int, 
company_id int, 
item_id int, 
discount_id int,
PRIMARY KEY(checkin_id),
FOREIGN KEY(user_id) REFERENCES USER_TABLE(user_id),
FOREIGN KEY(company_id) REFERENCES COMPANY(company_id),
FOREIGN KEY(item_id) REFERENCES ITEM(item_id),
FOREIGN KEY(discount_id) REFERENCES Discount(discount_id)
);

CREATE TABLE Employee(employee_id int, 
email VARCHAR(255), 
first_name VARCHAR(255), 
last_name VARCHAR(255), 
job_category VARCHAR(255), 
salary int, 
start_date date, 
street_address VARCHAR(255), 
city VARCHAR(255), 
state VARCHAR(255), 
zip_code int,
PRIMARY KEY(employee_id)
);

CREATE TABLE Company_Transaction (transaction_id int, 
transaction_date date, 
charge_type VARCHAR(255), 
transaction_amount float,
surcharge float, 
total_charge float, 
is_paid VARCHAR(5), 
paid_date date, 
company_id int,
PRIMARY KEY(transaction_id),
FOREIGN KEY(company_id) REFERENCES COMPANY(company_id)
);

CREATE TABLE Company_Transaction_Checkin (transaction_id int, 
checkin_id int, 
checkin_charge float, 
FOREIGN KEY(transaction_id) REFERENCES Company_Transaction(transaction_id),
FOREIGN KEY(checkin_id) REFERENCES User_Checkin(checkin_id)
);


--Data insertion
CREATE TEMP TABLE temp_table(item_id VARCHAR(1000));
\COPY temp_table FROM 'C:\Users\ivany\Downloads\files\files\products.csv' DELIMITER '|'

CREATE TEMP TABLE temp_table_2(column_1 VARCHAR(1000));
\COPY temp_table_2 FROM 'C:\Users\ivany\Downloads\files\files\services.csv'

CREATE TEMP TABLE temp_table_3(
    first_name VARCHAR(1000), 
    last_name VARCHAR(1000), 
    user_name VARCHAR(1000), 
    email VARCHAR(1000), 
    street VARCHAR(1000), 
    city VARCHAR(1000), 
    state VARCHAR(1000)) ;
\COPY temp_table_3 FROM 'C:\Users\ivany\Downloads\files\files\users.csv' DELIMITER ',' CSV

INSERT INTO user_table(user_email, first_name, last_name, street_address, city, state)
SELECT email, first_name, last_name, street, city, state FROM temp_table_3;






