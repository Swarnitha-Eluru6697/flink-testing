CREATE TABLE employees (
    emp_id INTEGER,
    name STRING,
    department STRING,
    salary DECIMAL
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://host.docker.internal:5434/workspace',
    'table-name' = 'public.employees',
    'username' = 'workspace',
    'password' = 'workspace',
    'driver' = 'org.postgresql.Driver'
);

CREATE TABLE employee_sink (
    id INTEGER,
    name STRING,
    department STRING,
    salary DECIMAL
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://host.docker.internal:5434/workspace',
    'table-name' = 'public.employee_sink',
    'username' = 'workspace',
    'password' = 'workspace',
    'driver' = 'org.postgresql.Driver'
);

INSERT INTO employee_sink
SELECT emp_id, name, department, salary
FROM employees;