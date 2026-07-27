-- =============================================================
-- FlinkSQL Job: Postgres → Flink → Postgres (JDBC connector)
-- DB / User / Password : workspace
-- Source table        : employees        (read)
-- Sink table          : employees_sink   (write / transformed copy)
--
-- ⚠️  Prerequisite – run this DDL in Postgres BEFORE deploying:
--
--   CREATE TABLE employees_sink (
--       id           INT           PRIMARY KEY,
--       full_name    VARCHAR(255),
--       email        VARCHAR(255),             
--       department   VARCHAR(255),
--       salary       NUMERIC(15,2),
--       salary_grade VARCHAR(10),
--       hire_date    DATE
--   );
--
-- ⚠️  JAR prerequisites (place in $FLINK_HOME/lib/ before starting):
--     • flink-connector-jdbc-<version>.jar
--     • postgresql-<version>.jar
-- =============================================================


-- ─────────────────────────────────────────────────────────────
-- 1. SOURCE  –  read from Postgres  →  employees
-- ─────────────────────────────────────────────────────────────
CREATE TABLE employees_source (
    emp_id INT,
    first_name STRING,
    last_name STRING,
    department STRING,
    salary DECIMAL(15,2),
    joining_date DATE,
    city STRING
)
WITH (
    'connector'='jdbc',
    'url'='jdbc:postgresql://host.docker.internal:5434/workspace',
    'table-name'='public.employees',
    'username'='workspace',
    'password'='workspace',
    'driver'='org.postgresql.Driver'
);


-- ─────────────────────────────────────────────────────────────
-- 2. SINK  –  write to Postgres  →  employees_sink
-- ─────────────────────────────────────────────────────────────
CREATE TABLE employees_sink (
    emp_id INT,
    first_name STRING,
    last_name STRING,
    department STRING,
    salary DECIMAL(15,2),
    joining_date DATE,
    city STRING
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://host.docker.internal:5434/workspace',
    'table-name' = 'public.employees_sink',
    'username' = 'workspace',
    'password' = 'workspace',
    'driver' = 'org.postgresql.Driver'
);


-- ─────────────────────────────────────────────────────────────
-- 3. PIPELINE  –  transform & load
--    • Merges first_name + last_name  →  full_name
--    • Derives a salary grade band    →  salary_grade
-- ─────────────────────────────────────────────────────────────
INSERT INTO employees_sink
SELECT
    emp_id,
    CONCAT(first_name, ' ', last_name)          AS full_name,
    email,
    department,
    salary,
    CASE
        WHEN salary <  30000                    THEN 'Grade-A'
        WHEN salary >= 30000 AND salary < 60000 THEN 'Grade-B'
        WHEN salary >= 60000 AND salary < 90000 THEN 'Grade-C'
        ELSE                                         'Grade-D'
    END                                         AS salary_grade,
    joining_date
FROM employees_source;