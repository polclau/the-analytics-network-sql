/*
Desafio Entrevista Tecnica Parte 1 
*/


create schema test;

drop table if exists test.test_table_1;
create table test.test_table_1 (id int);
insert into test.test_table_1 values (1);
insert into test.test_table_1 values (1);
insert into test.test_table_1 values (1);
insert into test.test_table_1 values (2);
insert into test.test_table_1 values (null);
insert into test.test_table_1 values (3);
insert into test.test_table_1 values (3);


drop table if exists test.test_table_2;
create table test.test_table_2 (id int);
insert into test.test_table_2 values (1);
insert into test.test_table_2 values (1);
insert into test.test_table_2 values (null);
insert into test.test_table_2 values (4);
insert into test.test_table_2 values (4);


select * from test.test_table_1;
select * from test.test_table_2;

--1. Como encuentro duplicados en una tabla. Dar un ejemplo mostrando duplicados de la columna orden en la tabla de ventas. (responder teoricamente)
Para encontrar duplicados en una tabla, utilizo 
la cláusula GROUP BY junto con la función COUNT().
SELECT id, COUNT(*) as cantidad_duplicados
FROM test.test_table_1
GROUP BY id
HAVING COUNT(*) > 1;


--2. Como elimino duplicados? (responder teoricamente)
Para eliminar duplicados, uso  DELETE con una 
subconsulta que seleccione los duplicados basados 
en la condición.

DELETE FROM test.test_table_1
WHERE id IN (
    SELECT id
    FROM test.test_table_1
    GROUP BY id
    HAVING COUNT(*) > 1
);

--3. Cual es la diferencia entre UNION y UNION ALL. (responder teoricamente)
  UNION: Devuelve resultados distintos, eliminando duplicados.
    UNION ALL: Devuelve todos los resultados, incluyendo duplicados.

-- UNION
SELECT id FROM test.test_table_1
UNION
SELECT id FROM test.test_table_2;

-- UNION ALL
SELECT id FROM test.test_table_1
UNION ALL
SELECT id FROM test.test_table_2;


--4. Como encuentro registros en una tabla que no estan en otra tabla. (responder teoricamente y usando la table_1 y table_2 como ejemplo)
Puedo usar la cláusula NOT EXISTS o LEFT JOIN.

-- NOT EXISTS
SELECT *
FROM test.test_table_1 t1
WHERE NOT EXISTS (
    SELECT 1
    FROM test.test_table_2 t2
    WHERE t2.id = t1.id
);

-- LEFT JOIN
SELECT t1.*
FROM test.test_table_1 t1
LEFT JOIN test.test_table_2 t2 ON t1.id = t2.id
WHERE t2.id IS NULL;

--5. Cual es la diferencia entre INNER JOIN y LEFT JOIN.  (responder teoricamente y usando la table_1 y table_2 como ejemplo)
INNER JOIN: Devuelve solo los registros que tienen coincidencias en ambas tablas.
LEFT JOIN: Devuelve todos los registros de la tabla izquierda 
y los registros coincidentes de la tabla derecha.
-- INNER JOIN
SELECT *
FROM test.test_table_1 t1
INNER JOIN test.test_table_2 t2 ON t1.id = t2.id;

-- LEFT JOIN
SELECT *
FROM test.test_table_1 t1
LEFT JOIN test.test_table_2 t2 ON t1.id = t2.id;

