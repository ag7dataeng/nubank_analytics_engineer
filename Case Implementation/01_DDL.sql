-- DROP IF EXISTS
/*
-- Drop pix_movements table
DROP TABLE IF EXISTS pix_movements CASCADE;

-- Drop transfer_outs table
DROP TABLE IF EXISTS transfer_outs CASCADE;

-- Drop transfer_ins table
DROP TABLE IF EXISTS transfer_ins CASCADE;

-- Drop d_time table
DROP TABLE IF EXISTS d_time CASCADE;

-- Drop d_weekday table
DROP TABLE IF EXISTS d_weekday CASCADE;

-- Drop d_week table
DROP TABLE IF EXISTS d_week CASCADE;

-- Drop d_month table
DROP TABLE IF EXISTS d_month CASCADE;

-- Drop d_year table
DROP TABLE IF EXISTS d_year CASCADE;

-- Drop accounts table
DROP TABLE IF EXISTS accounts CASCADE;

-- Drop customers table
DROP TABLE IF EXISTS customers CASCADE;

-- Drop city table
DROP TABLE IF EXISTS city CASCADE;

-- Drop state table
DROP TABLE IF EXISTS state CASCADE;

-- Drop country table
DROP TABLE IF EXISTS country CASCADE;

*/
---- DIM Tables
-- Create country table
-- The value for country field in the source file 
-- is not compatible with uuid data type referenced in the diagram
-- VARCHAR(128) used instead (same for the following tables).
CREATE TABLE country (
	country VARCHAR(128) NOT NULL,
    country_id BIGINT PRIMARY KEY
);

-- Create state table
CREATE TABLE state (
	state VARCHAR(128) NOT NULL,
	country_id BIGINT REFERENCES country(country_id),
    state_id BIGINT PRIMARY KEY   
);

-- Create city table
CREATE TABLE city (
	city VARCHAR(256) NOT NULL,
	state_id BIGINT REFERENCES state(state_id),
    city_id BIGINT PRIMARY KEY
);

-- Create customers table
CREATE TABLE customers (
    customer_id BIGINT PRIMARY KEY,
    first_name VARCHAR(128) NOT NULL,
    last_name VARCHAR(128) NOT NULL,
    customer_city BIGINT REFERENCES city(city_id),
	cpf BIGINT UNIQUE NOT NULL,
    country_name VARCHAR(128) 
);

-- Create accounts table
CREATE TABLE accounts (
    account_id BIGINT PRIMARY KEY,
    customer_id BIGINT REFERENCES customers(customer_id),
    created_at TIMESTAMP NOT NULL,
    status VARCHAR(128) NOT NULL,
    account_branch VARCHAR(128),
    account_check_digit VARCHAR(128),
    account_number VARCHAR(128)
);



-- Create d_month table
CREATE TABLE d_month (
    month_id INT PRIMARY KEY,
    action_month INT NOT NULL
);

-- Create d_year table
CREATE TABLE d_year (
    year_id INT PRIMARY KEY,
    action_year INT NOT NULL
);

-- Create d_week table
CREATE TABLE d_week (
    week_id INT PRIMARY KEY,
    action_week INT NOT NULL
);

-- Create d_weekday table
CREATE TABLE d_weekday (
    weekday_id INT PRIMARY KEY,
    action_weekday VARCHAR(128) NOT NULL
);

-- Create d_time table
CREATE TABLE d_time (
    time_id INT PRIMARY KEY,
    action_timestamp TIMESTAMP NOT NULL,
    week_id INT REFERENCES d_week(week_id),
    month_id INT REFERENCES d_month(month_id),
    year_id INT REFERENCES d_year(year_id),
    weekday_id INT REFERENCES d_weekday(weekday_id)
);




----- TXN Tables
-- Create transfer_ins table
CREATE TABLE transfer_ins (
    id BIGINT PRIMARY KEY,
    account_id BIGINT REFERENCES accounts(account_id),
    amount FLOAT NOT NULL,
    transaction_requested_at INT REFERENCES d_time(time_id),
    transaction_completed_at INT REFERENCES d_time(time_id),
    status VARCHAR(128)
);

-- Create transfer_outs table
CREATE TABLE transfer_outs (
    id BIGINT PRIMARY KEY,
    account_id BIGINT REFERENCES accounts(account_id),
    amount FLOAT NOT NULL,
    transaction_requested_at INT REFERENCES d_time(time_id),
    transaction_completed_at INT REFERENCES d_time(time_id),
    status VARCHAR(128)
);

-- Create pix_movements table
CREATE TABLE pix_movements (
    id BIGINT PRIMARY KEY,
    account_id BIGINT REFERENCES accounts(account_id),
	pix_amount FLOAT NOT NULL,
	pix_requested_at INT REFERENCES d_time(time_id),
    pix_completed_at INT REFERENCES d_time(time_id),
	status VARCHAR(128),
    in_or_out VARCHAR(128) CHECK (in_or_out IN ('pix_in', 'pix_out'))
);
