--CREATE EXTENSION IF NOT EXISTS aws_commons CASCADE;
--CREATE EXTENSION IF NOT EXISTS aws_s3 CASCADE;

--SELECT * FROM pg_extension WHERE extname IN ('aws_commons', 'aws_s3');

-- Load country table
SELECT aws_s3.table_import_from_s3(
    'country', 
    '', 
    '(FORMAT csv, HEADER true, DELIMITER '','')',
    'nubank-s3-bucket', 
    'Tables/country/part-00000-tid-5054581782199228501-41100236-b09c-46a7-8442-8d968c697e9a-11286346-1-c000.csv', 
    'us-east-2'
);


-- Load state table
SELECT aws_s3.table_import_from_s3(
    'state', 
    '', 
    '(FORMAT csv, HEADER true, DELIMITER '','')',
    'nubank-s3-bucket', 
    'Tables/state/part-00000-tid-2467726635302089596-e4fdd6ee-8624-4658-af6a-6098bc1c0825-11243350-1-c000.csv', 
    'us-east-2'
);

-- Load city table
SELECT aws_s3.table_import_from_s3(
    'city', 
    '', 
    '(FORMAT csv, HEADER true, DELIMITER '','')',
    'nubank-s3-bucket', 
    'Tables/city/part-00000-tid-7257851286237664629-906ff0c6-51c7-4cdd-97cd-dc0aa92a92f1-11185485-1-c000.csv', 
    'us-east-2'
);

-- Load customers table
SELECT aws_s3.table_import_from_s3(
    'customers', 
    '', 
    '(FORMAT csv, HEADER true, DELIMITER '','')',
    'nubank-s3-bucket', 
    'Tables/customers/part-00000-tid-2581180368179082894-038c4dab-1615-444a-994f-5a2107c4d9a8-11135734-1-c000.csv', 
    'us-east-2'
);

-- Load accounts table
SELECT aws_s3.table_import_from_s3(
    'accounts', 
    '', 
    '(FORMAT csv, HEADER true, DELIMITER '','')',
    'nubank-s3-bucket', 
    'Tables/accounts/part-00000-tid-2834924781296170616-a9b7a53c-b8f1-417c-876b-22ce8ab4c825-11024507-1-c000.csv', 
    'us-east-2'
);

-- Load d_year table
SELECT aws_s3.table_import_from_s3(
    'd_year', 
    '', 
    '(FORMAT csv, HEADER true, DELIMITER '','')',
    'nubank-s3-bucket', 
    'Tables/d_year/part-00000-tid-5440254676189819830-69d9a28f-dbd2-48ca-9eca-66f1ddb276df-10961064-1-c000.csv', 
    'us-east-2'
);

-- Load d_month table
SELECT aws_s3.table_import_from_s3(
    'd_month', 
    '', 
    '(FORMAT csv, HEADER true, DELIMITER '','')',
    'nubank-s3-bucket', 
    'Tables/d_month/part-00000-tid-1411108534556725179-0fbf435f-dd8b-411e-ae97-11e74b345b4f-10859988-1-c000.csv', 
    'us-east-2'
);

-- Load d_week table
SELECT aws_s3.table_import_from_s3(
    'd_week', 
    '', 
    '(FORMAT csv, HEADER true, DELIMITER '','')',
    'nubank-s3-bucket', 
    'Tables/d_week/part-00000-tid-8944900144231406848-ea4ff673-508c-46e0-ac10-e488037f37c5-10733320-1-c000.csv', 
    'us-east-2'
);

-- Load d_weekday table
SELECT aws_s3.table_import_from_s3(
    'd_weekday', 
    '', 
    '(FORMAT csv, HEADER true, DELIMITER '','')',
    'nubank-s3-bucket', 
    'Tables/d_weekday/part-00000-tid-1198883628307677355-d7f0c6f5-b5f5-40c6-9537-2951b88849eb-10926413-1-c000.csv', 
    'us-east-2'
);

-- Load d_time table
SELECT aws_s3.table_import_from_s3(
    'd_time', 
    '', 
    '(FORMAT csv, HEADER true, DELIMITER '','')',
    'nubank-s3-bucket', 
    'Tables/d_time/part-00000-tid-2902183611695287462-3111e3e9-023d-4533-a7e5-d0b87fb1a808-10662337-1-c000.csv', 
    'us-east-2'
);


-- Transform
-- Handle None Values in Txn tables
--- Insert Dummy Rows in All Referenced Dimension Tables
-- Insert a dummy year (e.g., 0 for "No Year Assigned")
INSERT INTO d_year (year_id, action_year)
VALUES (-1, -1)
ON CONFLICT (year_id) DO NOTHING;

-- Insert a dummy month
INSERT INTO d_month (month_id, action_month)
VALUES (-1, -1)
ON CONFLICT (month_id) DO NOTHING;

-- Insert a dummy week
INSERT INTO d_week (week_id, action_week)
VALUES (-1, -1)
ON CONFLICT (week_id) DO NOTHING;

-- Insert a dummy weekday
INSERT INTO d_weekday (weekday_id, action_weekday)
VALUES (-1, -1)
ON CONFLICT (weekday_id) DO NOTHING;

-- Insert a dummy for d_time
INSERT INTO d_time (time_id, action_timestamp, week_id, month_id, year_id, weekday_id)
VALUES (0, '1900-01-01T00:00:00.000Z', -1, -1, -1, -1)
ON CONFLICT (time_id) DO NOTHING;

select * from d_year;
select * from d_month;
select * from d_week;
select * from d_weekday;
select * from d_time where time_id <= 0 limit 10;


-- Load transfer_ins table
SELECT aws_s3.table_import_from_s3(
    'transfer_ins', 
    '', 
    '(FORMAT csv, HEADER true, DELIMITER '','')',
    'nubank-s3-bucket', 
    'Tables/transfer_ins/part-00000-tid-3939740088886661710-b68a1bdc-ca76-4934-b2fd-756b973d041f-10414417-1-c000.csv', 
    'us-east-2'
);

-- Load transfer_outs table
SELECT aws_s3.table_import_from_s3(
    'transfer_outs', 
    '', 
    '(FORMAT csv, HEADER true, DELIMITER '','')',
    'nubank-s3-bucket', 
    'Tables/transfer_outs/part-00000-tid-3880462020784336524-8a5c83e1-e1e4-471e-9dbf-1b37babaff47-10468383-1-c000.csv', 
    'us-east-2'
);

-- Load pix_movements table
SELECT aws_s3.table_import_from_s3(
    'pix_movements', 
    '', 
    '(FORMAT csv, HEADER true, DELIMITER '','')',
    'nubank-s3-bucket', 
    'Tables/pix_movements/part-00000-tid-8322739320471544484-12382b61-f87b-4388-931d-ec1681d2aad1-10545794-1-c000.csv', 
    'us-east-2'
);

