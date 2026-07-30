-- FlinkSQL streaming job
--
-- A job is three parts:
--   1. CREATE TABLE for each source  — Kafka topic, CDC stream, …
--   2. CREATE TABLE for each sink    — lakehouse table, Kafka topic, …
--   3. INSERT INTO <sink> SELECT … FROM <source>
--
-- Connector settings go in each table's WITH ( … ) clause.
--
-- ⌘↵          syntax-check this file against the FlinkSQL runner
-- ⌘K          ask the AI chat to generate the pipeline for you
-- Deploy      commit and push, then register the repo under FlinkSQL → Jobs

-- ==========================================================
-- SOURCE TABLE
-- ==========================================================

CREATE TABLE employees_source (
    emp_id INT,
    first_name STRING,
    last_name STRING,
    department STRING,
    salary DECIMAL(10,2),
    joining_date DATE,
    city STRING
)
WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://host.docker.internal:5434/workspace',
    'table-name' = 'public.employees',
    'username' = 'workspace',
    'password' = 'workspace',
    'driver' = 'org.postgresql.Driver'
);

-- ==========================================================
-- SINK TABLE
-- ==========================================================

CREATE TABLE high_salary_sink (
    emp_id INT,
    first_name STRING,
    last_name STRING,
    department STRING,
    salary DECIMAL(10,2),
    joining_date DATE,
    city STRING
)
WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://host.docker.internal:5434/workspace',
    'table-name' = 'public.high_salary_employees',
    'username' = 'workspace',
    'password' = 'workspace',
    'driver' = 'org.postgresql.Driver'
);

-- ==========================================================
-- START THE JOB
-- ==========================================================

INSERT INTO high_salary_sink
SELECT
    emp_id,
    first_name,
    last_name,
    department,
    salary,
    joining_date,
    city
FROM employees_source
WHERE salary > 60000;