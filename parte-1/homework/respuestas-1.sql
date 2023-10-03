-- ## Semana 1 - Parte A


-- 1. Mostrar todos los productos dentro de la categoria electro junto con todos los detalles.
select * from stg.product_master where categoria = 'Electro'

-- 2. Cuales son los producto producidos en China?
select product_code,name from stg.product_master where origin='China'

-- 3. Mostrar todos los productos de Electro ordenados por nombre.
select product_code, name
from stg.product_master
where category = 'Electro'
order by name

-- 4. Cuales son las TV que se encuentran activas para la venta?
select product_code,name
from stg.product_master
where subsubcategory = '4' AND is_active = TRUE;

-- 5. Mostrar todas las tiendas de Argentina ordenadas por fecha de apertura de las mas antigua a la mas nueva.
select *
from stg.store_master
where country = 'Argentina'
order by start_date;


-- 6. Cuales fueron las ultimas 5 ordenes de ventas?
select *
from stg.order_line_sale
order by date desc
limit 5;

-- 7. Mostrar los primeros 10 registros de el conteo de trafico por Super store ordenados por fecha.
select *
from stg.super_store_count
order by date
limit 10;

-- 8. Cuales son los producto de electro que no son Soporte de TV ni control remoto.
select *
from stg.product_master
where category = 'Electro'
and subsubcategory NOT IN ('Soporte', 'Control Remoto');


-- 9. Mostrar todas las lineas de venta donde el monto sea mayor a $100.000 solo para transacciones en pesos.
select *
from stg.order_line_sale
where sale > 100000 AND currency = 'ARS';

-- 10. Mostrar todas las lineas de ventas de Octubre 2022.
select *
from stg.order_line_sale
where date >= '2022-10-01' AND date <= '2022-10-31';

-- 11. Mostrar todos los productos que tengan EAN.
select *
from stg.product_master
where ean IS NOT NULL;


-- 12. Mostrar todas las lineas de venta que que hayan sido vendidas entre 1 de Octubre de 2022 y 10 de Noviembre de 2022.
select *
from stg.order_line_sale
where date >= '2022-10-01' AND date <= '2022-11-10';

-- ## Semana 1 - Parte B

-- 1. Cuales son los paises donde la empresa tiene tiendas?
select distinct country
from stg.store_master;


-- 2. Cuantos productos por subcategoria tiene disponible para la venta?
select subcategory, count(*) as cantidad_de_productos
from stg.product_master
group by subcategory;

-- 3. Cuales son las ordenes de venta de Argentina de mayor a $100.000?
select ols.*
from stg.order_line_sale ols
inner join stg.store_master sm on ols.store = sm.store_id
where sm.country = 'Argentina' and ols.sale > 100000;


-- 4. Obtener los decuentos otorgados durante Noviembre de 2022 en cada una de las monedas?
select urrency, SUM(promotion) as total_descuentos
from stg.order_line_sale
where date >= '2022-11-01' and date <= '2022-11-30'
group by currency;

-- 5. Obtener los impuestos pagados en Europa durante el 2022.
select  SUM(tax) as total_impuestos
from stg.order_line_sale
where date >= '2022-01-01' and date <= '2022-12-31' and currency = 'EUR';


-- 6. En cuantas ordenes se utilizaron creditos?
select count (distinct order_number) as cantidad_de_ordenes_con_creditos
from stg.order_line_sale
where credit > 0;

-- 7. Cual es el % de descuentos otorgados (sobre las ventas) por tienda?
select sm.name  as tienda,
       SUM(promotion) as total_descuentos,
       SUM(sale) as total_ventas,
       (SUM(promotion) / SUM(sale)) * 100 as porcentaje_descuento
from stg.order_line_sale ols
inner join stg.store_master sm ON ols.store = sm.store_id
group by sm.name;

-- 8. Cual es el inventario promedio por dia que tiene cada tienda?
select store_id,
       avg (final - initial) as inventario_promedio_por_dia
from stg.inventory
group by store_id;

-- 9. Obtener las ventas netas y el porcentaje de descuento otorgado por producto en Argentina.
select product,
       SUM(sale) as ventas_netas,
       SUM(promotion) as descuento_total,
       (SUM(promotion) / SUM(sale)) * 100 as porcentaje_descuento
from stg.order_line_sale ols
inner join stg.store_master sm on ols.store = sm.store_id
where sm.country = 'Argentina'
group by product;


-- 10. Las tablas "market_count" y "super_store_count" representan dos sistemas distintos que usa la empresa para contar la cantidad de gente que ingresa a tienda, uno para las tiendas de Latinoamerica y otro para Europa. Obtener en una unica tabla, las entradas a tienda de ambos sistemas.
-- Entradas a tienda de Latinoamérica (market_count)
select store_id, date::VARCHAR AS fecha, traffic
from stg.market_count

union all

-- Entradas a tienda de Europa (super_store_count)
select store_id, date, traffic
from stg.super_store_count;


-- 11. Cuales son los productos disponibles para la venta (activos) de la marca Phillips?
select *
from stg.product_master
where is_active = true and name like '%Phillips%';


-- 12. Obtener el monto vendido por tienda y moneda y ordenarlo de mayor a menor por valor nominal de las ventas (sin importar la moneda).
select sm.name as tienda,
       ols.currency as moneda,
       SUM(ols.sale) as monto_vendido
from stg.order_line_sale ols
inner join stg.store_master sm on ols.store = sm.store_id
group  by sm.name, ols.currency
order by  monto_vendido desc;

-- 13. Cual es el precio promedio de venta de cada producto en las distintas monedas? Recorda que los valores de venta, impuesto, descuentos y creditos es por el total de la linea.
select product,
       currency,
       AVG(sale / quantity) as precio_promedio
from stg.order_line_sale
group by product, currency;

-- 14. Cual es la tasa de impuestos que se pago por cada orden de venta?
select order_number,
       (SUM(tax) / SUM(sale)) * 100 as tasa_de_impuestos
from stg.order_line_sale
group by order_number;



-- ## Semana 2 - Parte A

-- 1. Mostrar nombre y codigo de producto, categoria y color para todos los productos de la marca Philips y Samsung, mostrando la leyenda "Unknown" cuando no hay un color disponible
SELECT
  name,
  product_code,
  category,
  COALESCE(color, 'Unknown') AS color
FROM stg.product_master
WHERE name LIKE '%PHILIPS%' OR name LIKE '%Samsung%'

-- 2. Calcular las ventas brutas y los impuestos pagados por pais y provincia en la moneda correspondiente.
WITH store_sale AS (
  SELECT
    store,
    SUM(sale) AS ventas_brutas,
    SUM(tax) AS impuestos,
    currency
  FROM stg.order_line_sale
  GROUP BY store, currency
)
SELECT
  sm.country,
  sm.province,
  SUM(ss.ventas_brutas) AS ventas_brutas_pais_provincia,
  SUM(ss.impuestos) AS impuestos_pais_provincia,
  ss.currency 
FROM stg.store_master sm
LEFT JOIN store_sale ss ON sm.store_id = ss.store
GROUP BY sm.country, sm.province, ss.currency;



-- 3. Calcular las ventas totales por subcategoria de producto para cada moneda ordenados por subcategoria y moneda.
SELECT
  pm.subcategory,
  os.currency,
  SUM(os.sale) AS ventas_totales
FROM stg.order_line_sale os
LEFT JOIN stg.product_master pm ON pm.product_code = os.product
GROUP BY pm.subcategory, os.currency
ORDER BY pm.subcategory, os.currency;

  
-- 4. Calcular las unidades vendidas por subcategoria de producto y la concatenacion de pais, provincia; usar guion como separador y usarla para ordernar el resultado.
SELECT
  pm.subcategory,
  CONCAT(sm.country, '-', sm.province) AS país_provincia,
  SUM(os.quantity) AS unidades_vendidas
FROM stg.order_line_sale os
LEFT JOIN stg.product_master pm ON os.product = pm.product_code
LEFT JOIN stg.store_master sm ON sm.store_id = os.store
GROUP BY pm.subcategory, CONCAT(sm.country, '-', sm.province)
ORDER BY CONCAT(sm.country, '-', sm.province);

  
-- 5. Mostrar una vista donde sea vea el nombre de tienda y la cantidad de entradas de personas que hubo desde la fecha de apertura para el sistema "super_store".
create view vista_tienda as 
select sm.name, sc.traffic, sc.date 
from stg.super_store_count sc
left join stg.store_master sm on sc.store_id= sm.store_id



 stg.super_store_count
(
    store_id smallint,
    date character varying(10) COLLATE pg_catalog."default",
    traffic smallint
)


 stg.store_master
(
    store_id smallint,
    country character varying(100) COLLATE pg_catalog."default",
    province character varying(100) COLLATE pg_catalog."default",
    city character varying(100) COLLATE pg_catalog."default",
    address character varying(255) COLLATE pg_catalog."default",
    name character varying(255) COLLATE pg_catalog."default",
    type character varying(100) COLLATE pg_catalog."default",
    start_date date
)

  
-- 6. Cual es el nivel de inventario promedio en cada mes a nivel de codigo de producto y tienda; mostrar el resultado con el nombre de la tienda.
SELECT
  sm.name,
  i.item_id,
  SUM((i.initial + i.final) / 2) / COUNT(DISTINCT DATE_TRUNC('month', i.date)) AS Inv_Prom_por_mes
FROM stg.inventory i
LEFT JOIN stg.store_master sm ON i.store_id = sm.store_id
GROUP BY sm.name, i.item_id

  
-- 7. Calcular la cantidad de unidades vendidas por material. Para los productos que no tengan material usar 'Unknown', homogeneizar los textos si es necesario.
WITH material_mapping AS (
  SELECT
    COALESCE(NULLIF(material, ''), 'Unknown') AS normalized_material,
    product_code
  FROM stg.product_master
)

SELECT
  mm.normalized_material,
  SUM(os.quantity) AS Cantidad_unidades_vendidas
FROM stg.order_line_sale os
LEFT JOIN material_mapping mm ON os.product = mm.product_code
GROUP BY mm.normalized_material

  
-- 8. Mostrar la tabla order_line_sales agregando una columna que represente el valor de venta bruta en cada linea convertido a dolares usando la tabla de tipo de cambio.
SELECT os.order_number, os.sale, os.currency, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS Ventas_en_dolares
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date

  
-- 9. Calcular cantidad de ventas totales de la empresa en dolares.
with ventas_totales_en_dolares as (SELECT os.order_number, os.sale, os.currency, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS Ventas_en_dolares
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on mr.month=date)
Select SUM(Ventas_en_dolares) as ventas_totales_de_la_empresa_en_dolares
from ventas_totales_en_dolares

  
-- 10. Mostrar en la tabla de ventas el margen de venta por cada linea. Siendo margen = (venta - descuento) - costo expresado en dolares.
WITH order_line_Sale_dollars as (SELECT os.order_number,os.product, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS Ventas_en_dolares,
	  CASE
	  WHEN os.promotion IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.promotion/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.promotion/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.promotion/fx_rate_usd_URU
	  ELSE os.promotion
	  END AS Descuento_en_dolares,
	  (c.product_cost_usd*os.quantity) as costo_linea
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product)
SELECT *, (ventas_en_dolares-descuento_en_dolares-costo_linea) as margen_de_venta 
FROM order_line_Sale_dollars

  
-- 11. Calcular la cantidad de items distintos de cada subsubcategoria que se llevan por numero de orden.
select os.order_number, pm.subcategory, count(distinct os.product) as Item_distinto
from stg.order_line_sale os
left join stg.product_master pm on os.product=pm.product_code
group by os.order_number, pm.subcategory

-- ## Semana 2 - Parte B

-- 1. Crear un backup de la tabla product_master. Utilizar un esquema llamada "bkp" y agregar un prefijo al nombre de la tabla con la fecha del backup en forma de numero entero.
DROP SCHEMA IF EXISTS bkp CASCADE;
CREATE SCHEMA IF NOT EXISTS bkp;
CREATE TABLE bkp.bkp_product_master_20231002 AS
SELECT *
FROM stg.product_master;

  
-- 2. Hacer un update a la nueva tabla (creada en el punto anterior) de product_master agregando la leyendo "N/A" para los valores null de material y color. Pueden utilizarse dos sentencias.
-- Actualizar material
UPDATE bkp.bkp_product_master_20231002
SET material = 'N/A'
WHERE material IS NULL;

-- Actualizar color
UPDATE bkp.bkp_product_master_20231002
SET color = 'N/A'
WHERE color IS NULL;


  
-- 3. Hacer un update a la tabla del punto anterior, actualizando la columa "is_active", desactivando todos los productos en la subsubcategoria "Control Remoto".
update bkp.bkp_product_master_20231002
set is_active=false
where subsubcategory = 'Control remoto' 
  
-- 4. Agregar una nueva columna a la tabla anterior llamada "is_local" indicando los productos producidos en Argentina y fuera de Argentina.
ALTER TABLE bkp.bkp_product_master_20231002
ADD COLUMN is_local boolean;
UPDATE bkp.bkp_product_master_20231002
SET is_local = CASE
		 WHEN origin = 'Argentina' then true
		 ELSE false
	    END  
-- 5. Agregar una nueva columna a la tabla de ventas llamada "line_key" que resulte ser la concatenacion de el numero de orden y el codigo de producto.
ALTER TABLE stg.order_line_sale
ADD COLUMN line_key VARCHAR
UPDATE stg.order_line_sale
SET line_key = order_number||'-'||product

  
-- 6. Crear una tabla llamada "employees" (por el momento vacia) que tenga un id (creado de forma incremental), name, surname, start_date, end_name, phone, country, province, store_id, position. Decidir cual es el tipo de dato mas acorde.
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    phone VARCHAR(20),
    country VARCHAR(50),
    province VARCHAR(50),
    store_id INT NOT NULL,
    position VARCHAR(50) NOT NULL,
    CHECK (start_date <= end_date OR end_date IS NULL) -- Verifica la regla de fecha
);

  
-- 7. Insertar nuevos valores a la tabla "employees" para los siguientes 4 empleados:
    -- Juan Perez, 2022-01-01, telefono +541113869867, Argentina, Santa Fe, tienda 2, Vendedor.
    -- Catalina Garcia, 2022-03-01, Argentina, Buenos Aires, tienda 2, Representante Comercial
    -- Ana Valdez, desde 2020-02-21 hasta 2022-03-01, España, Madrid, tienda 8, Jefe Logistica
    -- Fernando Moralez, 2022-04-04, España, Valencia, tienda 9, Vendedor.
-- Datos Juan
INSERT INTO employees (name, surname, start_date, phone, country, province, store_id, position)
VALUES('Juan', 'Perez', '2022-01-01','+541113869867', 'Argentina', 'Santa Fe', 2, 'Vendedor')
-- Datos Catalina
INSERT INTO employees (name, surname, start_date, phone, country, province, store_id, position)
VALUES('Catalina', 'Garcia', '2022-03-01','','Argentina', 'Buenos Aires', 2, 'Representante Comercial')
-- Datos Ana
INSERT INTO employees (name, surname, start_date,end_date, country, province, store_id, position)
VALUES('Ana', 'Valdez', '2020-02-21','2022-03-01', 'España', ' Madrid', 8, 'Jefe Logistica')
-- Datos Fernando
INSERT INTO employees (name, surname, start_date, country, province, store_id, position)
VALUES('Fernando', 'Moralez','2022-04-04', 'España', ' Valencia', 9, 'Vendedor')
  
-- 8. Crear un backup de la tabla "cost" agregandole una columna que se llame "last_updated_ts" que sea el momento exacto en el cual estemos realizando el backup en formato datetime.
CREATE TABLE cost_backup AS
SELECT *, NOW() AS last_updated_ts
FROM stg.cost  
  
-- 9. En caso de hacer un cambio que deba revertirse en la tabla "order_line_sale" y debemos volver la tabla a su estado original, como lo harias?
CREATE SCHEMA IF NOT EXISTS bkp;
CREATE TABLE bkp.bkp_order_line_sale_20231002 AS
SELECT *
FROM stg.order_line_sale

DROP TABLE IF EXISTS stg.order_line_sale

-- Restaura la tabla original desde la tabla de respaldo
CREATE TABLE stg.order_line_sale AS
SELECT *
FROM bkp.bkp_order_line_sale_20231002

