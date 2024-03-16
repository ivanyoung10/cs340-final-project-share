CREATE INDEX users_email ON users USING HASH (email);
CREATE INDEX users_name ON users USING HASH (first_name, last_name);
/* Email and name are the primary attributes that will be used when looking up
 * information in the users table. A hash is used because the only comparison 
 * made with these attributes is checking equality.
 */

CREATE INDEX company_name ON company USING HASH (name);
/* The company's name is the primary attributes that will be used when searching
 * in the company table. A hash is used because the only comparison made will be
 * checking equality.
 */

CREATE INDEX item_name ON item USING HASH (name);
/* The item's name is the primary attributes that will be used when searching
 * in the item table. A hash is used because the only comparison made will be
 * checking equality.
 */

CREATE INDEX discount_start ON discount (start_date);
CREATE INDEX discount_end ON discount (end_date);
/* The start and end dates of a discount will be frequently used in searching.
 * Using a B-Tree allows for comparison between values.
 */

CREATE INDEX review_ratings ON user_co_review (rating_score);
/* The rating score is the primary attributes that will be used when searching
 * in the user_co_review table. A B-Tree is used so that it can quickly compare 
 * values, ie., ratings between 4 and 5.
 */

CREATE INDEX user_checkin_date ON user_checkin (checkin_date);
/* This index allows for faster lookup when searching by checkin date. A B-Tree
 * is used so that you can search a range of values more easily.
 */

CREATE INDEX employee_name ON employee USING HASH (first_name, last_name);
/* The employee's name is the primary attributes that will be used when looking up
 * information in the employee table. A hash is used because the only comparison 
 * made with this attribute is checking equality.
 */

CREATE INDEX transaction_date ON company_transaction (trxn_date);
CREATE INDEX paid_date ON company_transaction (paid_date);
CREATE INDEX transaction_amt ON company_transaction (trxn_amt);
/* These indexes serve to improve lookup times from expected search terms. They
 * are using B-Trees because comparison is needed.
 */
