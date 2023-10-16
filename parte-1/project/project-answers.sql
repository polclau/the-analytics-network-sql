
-- General 
-- - Ventas brutas, netas y margen (USD)
WITH order_line_sale_dollars AS (
    SELECT
        os.order_number,
        os.product,
        date_trunc('month', os.date)::date AS month,
        CASE
            WHEN currency = 'EUR' THEN sale / fx_rate_usd_eur
            WHEN currency = 'ARS' THEN sale / fx_rate_usd_peso
            WHEN currency = 'URU' THEN sale / fx_rate_usd_uru
            ELSE sale
        END AS ventas_en_dolares,
        COALESCE(
            CASE
                WHEN os.promotion IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.promotion / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.promotion / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.promotion / fx_rate_usd_uru
                ELSE os.promotion
            END,
            0
        ) AS descuento_en_dolares,
        c.product_cost_usd * os.quantity AS costo_linea
    FROM
        stg.order_line_sale os
        LEFT JOIN stg.monthly_average_fx_rate mr ON date_trunc('month', mr.month)::date = date_trunc('month', os.date)::date
        LEFT JOIN stg.cost c ON c.product_code = os.product
)
SELECT
    EXTRACT(YEAR FROM month) AS year,
    EXTRACT(MONTH FROM month) AS month,
    SUM(ventas_en_dolares) AS sales_usd
FROM
    order_line_sale_dollars
GROUP BY
    year, month
ORDER BY
    year, month;WITH order_line_sale_dollars AS (
    SELECT
        os.order_number,
        os.product,
        date_trunc('month', os.date)::date AS month,
        CASE
            WHEN currency = 'EUR' THEN sale / fx_rate_usd_eur
            WHEN currency = 'ARS' THEN sale / fx_rate_usd_peso
            WHEN currency = 'URU' THEN sale / fx_rate_usd_uru
            ELSE sale
        END AS ventas_en_dolares,
        COALESCE(
            CASE
                WHEN os.promotion IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.promotion / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.promotion / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.promotion / fx_rate_usd_uru
                ELSE os.promotion
            END,
            0
        ) AS descuento_en_dolares,
        c.product_cost_usd * os.quantity AS costo_linea
    FROM
        stg.order_line_sale os
        LEFT JOIN stg.monthly_average_fx_rate mr ON date_trunc('month', mr.month)::date = date_trunc('month', os.date)::date
        LEFT JOIN stg.cost c ON c.product_code = os.product
)
SELECT
    EXTRACT(YEAR FROM month) AS year,
    EXTRACT(MONTH FROM month) AS month,
    SUM(ventas_en_dolares - descuento_en_dolares) AS net_sales_usd
FROM
    order_line_sale_dollars
GROUP BY
    year, month
ORDER BY
    year, month;


--ventas netas
WITH order_line_sale_dollars AS (
    SELECT
        os.order_number,
        os.product,
        date_trunc('month', os.date)::date AS month,
        CASE
            WHEN currency = 'EUR' THEN sale / fx_rate_usd_eur
            WHEN currency = 'ARS' THEN sale / fx_rate_usd_peso
            WHEN currency = 'URU' THEN sale / fx_rate_usd_uru
            ELSE sale
        END AS ventas_en_dolares,
        COALESCE(
            CASE
                WHEN os.promotion IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.promotion / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.promotion / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.promotion / fx_rate_usd_uru
                ELSE os.promotion
            END,
            0
        ) AS descuento_en_dolares,
        c.product_cost_usd * os.quantity AS costo_linea
    FROM
        stg.order_line_sale os
        LEFT JOIN stg.monthly_average_fx_rate mr ON date_trunc('month', mr.month)::date = date_trunc('month', os.date)::date
        LEFT JOIN stg.cost c ON c.product_code = os.product
)
SELECT
    EXTRACT(YEAR FROM month) AS year,
    EXTRACT(MONTH FROM month) AS month,
    SUM(ventas_en_dolares - descuento_en_dolares) AS net_sales_usd
FROM
    order_line_sale_dollars
GROUP BY
    year, month
ORDER BY
    year, month;

--margen
WITH order_line_sale_dollars AS (
    SELECT
        os.order_number,
        os.product,
        CAST(DATE_TRUNC('month', os.date) AS DATE) AS date,
        CASE
            WHEN currency = 'EUR' THEN sale / fx_rate_usd_eur
            WHEN currency = 'ARS' THEN sale / fx_rate_usd_peso
            WHEN currency = 'URU' THEN sale / fx_rate_usd_uru
            ELSE sale
        END AS ventas_en_dolares,
        COALESCE(
            CASE
                WHEN os.promotion IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.promotion / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.promotion / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.promotion / fx_rate_usd_uru
                ELSE os.promotion
            END,
            0
        ) AS descuento_en_dolares,
        c.product_cost_usd * os.quantity AS costo_linea
    FROM
        stg.order_line_sale os
        LEFT JOIN stg.monthly_average_fx_rate mr ON DATE_TRUNC('month', mr.month)::DATE = DATE_TRUNC('month', os.date)::DATE
        LEFT JOIN stg.cost c ON c.product_code = os.product
)
SELECT
    EXTRACT(YEAR FROM date) AS year,
    EXTRACT(MONTH FROM date) AS month,
    SUM(ventas_en_dolares - descuento_en_dolares - costo_linea) AS margin_usd
FROM
    order_line_sale_dollars
GROUP BY
    year, month
ORDER BY
    year, month;


-- - Margen por categoria de producto (USD)
WITH order_line_sale_dollars AS (
    SELECT
        os.order_number,
        os.product,
        pm.category,
        CAST(DATE_TRUNC('month', os.date) AS DATE) AS date,
        CASE
            WHEN currency = 'EUR' THEN sale / fx_rate_usd_eur
            WHEN currency = 'ARS' THEN sale / fx_rate_usd_peso
            WHEN currency = 'URU' THEN sale / fx_rate_usd_uru
            ELSE sale
        END AS ventas_en_dolares,
        COALESCE(
            CASE
                WHEN os.promotion IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.promotion / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.promotion / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.promotion / fx_rate_usd_uru
                ELSE os.promotion
            END,
            0
        ) AS descuento_en_dolares,
        c.product_cost_usd * os.quantity AS costo_linea
    FROM
        stg.order_line_sale os
        LEFT JOIN stg.monthly_average_fx_rate mr ON DATE_TRUNC('month', mr.month)::DATE = DATE_TRUNC('month', os.date)::DATE
        LEFT JOIN stg.cost c ON c.product_code = os.product
        LEFT JOIN stg.product_master pm ON pm.product_code = os.product
)
SELECT
    EXTRACT(YEAR FROM date) AS year,
    EXTRACT(MONTH FROM date) AS month,
    category,
    SUM(ventas_en_dolares - descuento_en_dolares - costo_linea) AS margin_usd
FROM
    order_line_sale_dollars
GROUP BY
    year, month, category
ORDER BY
    year, month, category;


-- - ROI por categoria de producto. ROI = ventas netas / Valor promedio de inventario (USD)
WITH inventory_dollars AS (
    SELECT
        DATE_TRUNC('month', i.date) AS año_mes,
        pm.category,
        SUM(c.product_cost_usd * (i.initial + i.final) / 2) AS costo_inv_prom
    FROM
        stg.inventory i
        LEFT JOIN stg.cost c ON c.product_code = i.item_id
        LEFT JOIN stg.product_master pm ON pm.product_code = c.product_code
    GROUP BY
        DATE_TRUNC('month', i.date),
        pm.category
    ORDER BY
        DATE_TRUNC('month', i.date)
),
order_line_sale_dollars AS (
    SELECT
        DATE_TRUNC('month', os.date) AS año_mes,
        category,
        SUM(
            CASE
                WHEN currency = 'EUR' THEN sale / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN sale / fx_rate_usd_peso
                WHEN currency = 'URU' THEN sale / fx_rate_usd_uru
                ELSE sale
            END
        ) AS ventas_en_dolares,
        SUM(
            CASE
                WHEN os.promotion IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.promotion / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.promotion / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.promotion / fx_rate_usd_uru
                ELSE os.promotion
            END
        ) AS descuento_en_dolares,
        SUM(c.product_cost_usd * os.quantity) AS costo_linea
    FROM
        stg.order_line_sale os
        LEFT JOIN stg.monthly_average_fx_rate mr ON DATE_TRUNC('month', mr.month)::DATE = DATE_TRUNC('month', os.date)::DATE
        LEFT JOIN stg.cost c ON c.product_code = os.product
        LEFT JOIN stg.product_master pm ON pm.product_code = os.product
    GROUP BY
        DATE_TRUNC('month', os.date),
        category
)
SELECT
    osd.año_mes,
    osd.category,
    (osd.ventas_en_dolares - osd.descuento_en_dolares) / id.costo_inv_prom AS roi
FROM
    order_line_sale_dollars osd
    LEFT JOIN inventory_dollars id ON osd.año_mes = id.año_mes AND osd.category = id.category
GROUP BY
    osd.año_mes,
    osd.category,
    roi;


-- - AOV (Average order value), valor promedio de la orden. (USD)
WITH order_line_sale_dollars AS (
    SELECT
        os.order_number,
        os.product,
        DATE_TRUNC('month', os.date)::DATE AS date,
        CASE
            WHEN currency = 'EUR' THEN sale / fx_rate_usd_eur
            WHEN currency = 'ARS' THEN sale / fx_rate_usd_peso
            WHEN currency = 'URU' THEN sale / fx_rate_usd_uru
            ELSE sale
        END AS ventas_en_dolares,
        CASE
            WHEN os.promotion IS NULL THEN 0
            WHEN currency = 'EUR' THEN os.promotion / fx_rate_usd_eur
            WHEN currency = 'ARS' THEN os.promotion / fx_rate_usd_peso
            WHEN currency = 'URU' THEN os.promotion / fx_rate_usd_uru
            ELSE os.promotion
        END AS descuento_en_dolares,
        c.product_cost_usd * os.quantity AS costo_linea
    FROM
        stg.order_line_sale os
        LEFT JOIN stg.monthly_average_fx_rate mr ON DATE_TRUNC('month', mr.month)::DATE = DATE_TRUNC('month', os.date)::DATE
        LEFT JOIN stg.cost c ON c.product_code = os.product
)
SELECT
    EXTRACT(year FROM date) AS Year,
    EXTRACT(month FROM date) AS Month,
    order_number,
    AVG(ventas_en_dolares - descuento_en_dolares) AS aov
FROM
    order_line_sale_dollars
GROUP BY
    Year,
    Month,
    order_number
ORDER BY
    Year,
    Month;


-- Contabilidad (USD)
-- - Impuestos pagados
WITH order_line_Sale_dollars AS (
    SELECT
        os.order_number,
        os.product,
        CAST(DATE_TRUNC('month', os.date) AS DATE) AS date,
        CASE
            WHEN currency = 'EUR' THEN sale / fx_rate_usd_eur
            WHEN currency = 'ARS' THEN sale / fx_rate_usd_peso
            WHEN currency = 'URU' THEN sale / fx_rate_usd_URU
            ELSE sale
        END AS Ventas_en_dolares,
        COALESCE(
            CASE
                WHEN os.promotion IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.promotion / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.promotion / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.promotion / fx_rate_usd_URU
                ELSE os.promotion
            END,
            0
        ) AS Descuento_en_dolares,
        COALESCE(
            CASE
                WHEN os.tax IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.tax / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.tax / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.tax / fx_rate_usd_URU
                ELSE os.tax
            END,
            0
        ) AS tax_usd,
        c.product_cost_usd * os.quantity AS costo_linea
    FROM
        stg.order_line_sale os
        LEFT JOIN stg.monthly_average_fx_rate mr ON DATE_TRUNC('month', mr.month)::DATE = DATE_TRUNC('month', os.date)::DATE
        LEFT JOIN stg.cost c ON c.product_code = os.product
)
SELECT
    EXTRACT(year FROM date) AS Year,
    EXTRACT(month FROM date) AS Month,
    SUM(tax_usd) AS tax_usd
FROM
    order_line_Sale_dollars
GROUP BY
    Year,
    Month
ORDER BY
    Year,
    Month;


-- - Tasa de impuesto. Impuestos / Ventas netas 
WITH order_line_Sale_dollars AS (
    SELECT
        os.order_number,
        os.product,
        CAST(DATE_TRUNC('month', os.date) AS DATE) AS date,
        CASE
            WHEN currency = 'EUR' THEN sale / fx_rate_usd_eur
            WHEN currency = 'ARS' THEN sale / fx_rate_usd_peso
            WHEN currency = 'URU' THEN sale / fx_rate_usd_URU
            ELSE sale
        END AS Ventas_en_dolares,
        COALESCE(
            CASE
                WHEN os.promotion IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.promotion / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.promotion / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.promotion / fx_rate_usd_URU
                ELSE os.promotion
            END,
            0
        ) AS Descuento_en_dolares,
        COALESCE(
            CASE
                WHEN os.tax IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.tax / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.tax / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.tax / fx_rate_usd_URU
                ELSE os.tax
            END,
            0
        ) AS tax_usd,
        (c.product_cost_usd * os.quantity) AS costo_linea
    FROM
        stg.order_line_sale os
        LEFT JOIN stg.monthly_average_fx_rate mr ON DATE_TRUNC('month', mr.month)::DATE = DATE_TRUNC('month', os.date)::DATE
        LEFT JOIN stg.cost c ON c.product_code = os.product
)
SELECT
    EXTRACT(year FROM date) AS Year,
    EXTRACT(month FROM date) AS Month,
    SUM(tax_usd) / NULLIF(SUM(Ventas_en_dolares - Descuento_en_dolares), 0) AS tax_rate
FROM
    order_line_Sale_dollars
GROUP BY
    Year,
    Month
ORDER BY
    Year,
    Month;


-- - Cantidad de creditos otorgados
WITH order_line_Sale_dollars AS (
    SELECT
        os.order_number,
        os.product,
        CAST(DATE_TRUNC('month', os.date) AS DATE) AS date,
        COALESCE(
            CASE
                WHEN currency = 'EUR' THEN os.sale / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.sale / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.sale / fx_rate_usd_URU
                ELSE os.sale
            END,
            0
        ) AS Ventas_en_dolares,
        COALESCE(
            CASE
                WHEN os.promotion IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.promotion / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.promotion / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.promotion / fx_rate_usd_URU
                ELSE os.promotion
            END,
            0
        ) AS Descuento_en_dolares,
        COALESCE(
            CASE
                WHEN os.tax IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.tax / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.tax / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.tax / fx_rate_usd_URU
                ELSE os.tax
            END,
            0
        ) AS tax_usd,
        COALESCE(
            CASE
                WHEN os.credit IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.credit / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.credit / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.credit / fx_rate_usd_URU
                ELSE os.credit
            END,
            0
        ) AS credit_usd,
        (c.product_cost_usd * os.quantity) AS costo_linea
    FROM
        stg.order_line_sale os
        LEFT JOIN stg.monthly_average_fx_rate mr ON DATE_TRUNC('month', mr.month)::DATE = DATE_TRUNC('month', os.date)::DATE
        LEFT JOIN stg.cost c ON c.product_code = os.product
)
SELECT
    EXTRACT(year FROM date) AS Year,
    EXTRACT(month FROM date) AS Month,
    SUM(credit_usd) AS credit_usd
FROM
    order_line_Sale_dollars
GROUP BY
    Year,
    Month
ORDER BY
    Year,
    Month;

-- - Valor pagado final por order de linea. Valor pagado: Venta - descuento + impuesto - credito
WITH order_line_Sale_dollars AS (
    SELECT
        os.order_number,
        os.product,
        CAST(DATE_TRUNC('month', os.date) AS DATE) AS date,
        COALESCE(
            CASE
                WHEN currency = 'EUR' THEN os.sale / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.sale / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.sale / fx_rate_usd_URU
                ELSE os.sale
            END,
            0
        ) AS Ventas_en_dolares,
        COALESCE(
            CASE
                WHEN os.promotion IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.promotion / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.promotion / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.promotion / fx_rate_usd_URU
                ELSE os.promotion
            END,
            0
        ) AS Descuento_en_dolares,
        COALESCE(
            CASE
                WHEN os.tax IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.tax / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.tax / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.tax / fx_rate_usd_URU
                ELSE os.tax
            END,
            0
        ) AS tax_usd,
        COALESCE(
            CASE
                WHEN os.credit IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.credit / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.credit / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.credit / fx_rate_usd_URU
                ELSE os.credit
            END,
            0
        ) AS credit_usd,
        (c.product_cost_usd * os.quantity) AS costo_linea
    FROM
        stg.order_line_sale os
        LEFT JOIN stg.monthly_average_fx_rate mr ON DATE_TRUNC('month', mr.month)::DATE = DATE_TRUNC('month', os.date)::DATE
        LEFT JOIN stg.cost c ON c.product_code = os.product
)
SELECT
    EXTRACT(year FROM date) AS Year,
    EXTRACT(month FROM date) AS Month,
    order_number,
    SUM(Ventas_en_dolares - Descuento_en_dolares + tax_usd - credit_usd) AS amount_paid_usd
FROM
    order_line_Sale_dollars
GROUP BY
    Year,
    Month,
    order_number
ORDER BY
    Year,
    Month;

-- Supply Chain (USD)
-- - Costo de inventario promedio por tienda
WITH inventory_dollars AS (
    SELECT
        i.date,
        i.store_id,
        i.item_id,
        pm.category,
        c.product_cost_usd * (i.initial + i.final) / 2 AS costo_inv_prom
    FROM
        stg.inventory i
        LEFT JOIN stg.cost c ON c.product_code = i.item_id
        LEFT JOIN stg.product_master pm ON pm.product_code = c.product_code
),
order_line_Sale_dollars AS (
    SELECT
        DATE_TRUNC('month', os.date)::DATE AS date,
        os.store,
        os.product,
        pm.category,
        COALESCE(
            CASE
                WHEN currency = 'EUR' THEN os.sale / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.sale / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.sale / fx_rate_usd_URU
                ELSE os.sale
            END,
            0
        ) AS Ventas_en_dolares,
        COALESCE(
            CASE
                WHEN os.promotion IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.promotion / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.promotion / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.promotion / fx_rate_usd_URU
                ELSE os.promotion
            END,
            0
        ) AS Descuento_en_dolares,
        c.product_cost_usd * os.quantity AS costo_linea
    FROM
        stg.order_line_sale os
        LEFT JOIN stg.monthly_average_fx_rate mr ON DATE_TRUNC('month', mr.month)::DATE = DATE_TRUNC('month', os.date)::DATE
        LEFT JOIN stg.cost c ON c.product_code = os.product
        LEFT JOIN stg.product_master pm ON pm.product_code = os.product
)
SELECT
    EXTRACT(YEAR FROM osd.date) AS Year,
    EXTRACT(MONTH FROM osd.date) AS Month,
    osd.store,
    SUM(id.costo_inv_prom) AS inventory_cost_usd
FROM
    order_line_Sale_dollars osd
    LEFT JOIN inventory_dollars id ON osd.date = id.date AND osd.store = id.store_id AND osd.product = id.item_id AND osd.category = id.category
GROUP BY
    Year,
    Month,
    osd.store;

-- - Costo del stock de productos que no se vendieron por tienda
WITH inventory_dollars AS (
    SELECT
        i.date,
        i.store_id,
        i.item_id,
        pm.category,
        c.product_cost_usd * (i.initial + i.final) / 2 AS costo_inv_prom
    FROM
        stg.inventory i
        LEFT JOIN stg.cost c ON c.product_code = i.item_id
        LEFT JOIN stg.product_master pm ON pm.product_code = c.product_code
),
order_line_Sale_dollars AS (
    SELECT
        DATE_TRUNC('month', os.date)::DATE AS date,
        os.store,
        os.product,
        pm.category,
        os.sale,
        COALESCE(
            CASE
                WHEN currency = 'EUR' THEN os.sale / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.sale / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.sale / fx_rate_usd_URU
                ELSE os.sale
            END,
            0
        ) AS Ventas_en_dolares,
        COALESCE(
            CASE
                WHEN os.promotion IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.promotion / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.promotion / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.promotion / fx_rate_usd_URU
                ELSE os.promotion
            END,
            0
        ) AS Descuento_en_dolares,
        c.product_cost_usd * os.quantity AS costo_linea
    FROM
        stg.order_line_sale os
        LEFT JOIN stg.monthly_average_fx_rate mr ON DATE_TRUNC('month', mr.month)::DATE = DATE_TRUNC('month', os.date)::DATE
        LEFT JOIN stg.cost c ON c.product_code = os.product
        LEFT JOIN stg.product_master pm ON pm.product_code = os.product
)
SELECT
    EXTRACT(YEAR FROM id.date) AS Year,
    EXTRACT(MONTH FROM id.date) AS Month,
    id.store_id,
    id.item_id,
    SUM(id.costo_inv_prom) AS inventory_cost_usd
FROM
    inventory_dollars id
    LEFT JOIN order_line_Sale_dollars osd ON osd.date = id.date AND osd.store = id.store_id AND osd.product = id.item_id AND osd.category = id.category
WHERE
    osd.sale IS NULL
GROUP BY
    Year,
    Month,
    id.store_id,
    osd.product,
    id.item_id;

-- - Cantidad y costo de devoluciones
WITH return_movements_customers AS (
    SELECT *
    FROM stg.return_movements
    WHERE from_location = 'Customer'
),
order_line_sale_dollars AS (
    SELECT
        DATE_TRUNC('month', os.date)::DATE AS date,
        os.order_number,
        os.product,
        os.quantity,
        os.sale,
        COALESCE(
            CASE
                WHEN currency = 'EUR' THEN os.sale / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.sale / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.sale / fx_rate_usd_URU
                ELSE os.sale
            END,
            0
        ) AS Ventas_en_dolares,
        COALESCE(
            CASE
                WHEN os.promotion IS NULL THEN 0
                WHEN currency = 'EUR' THEN os.promotion / fx_rate_usd_eur
                WHEN currency = 'ARS' THEN os.promotion / fx_rate_usd_peso
                WHEN currency = 'URU' THEN os.promotion / fx_rate_usd_URU
                ELSE os.promotion
            END,
            0
        ) AS Descuento_en_dolares,
        c.product_cost_usd * os.quantity AS costo_linea
    FROM
        stg.order_line_sale os
        LEFT JOIN stg.monthly_average_fx_rate mr ON DATE_TRUNC('month', mr.month)::DATE = DATE_TRUNC('month', os.date)::DATE
        LEFT JOIN stg.cost c ON c.product_code = os.product
        LEFT JOIN stg.product_master pm ON pm.product_code = os.product
)
SELECT
    EXTRACT(YEAR FROM os.date) AS Year,
    EXTRACT(MONTH FROM os.date) AS Month,
    SUM(rm.quantity) AS quantity,
    SUM(rm.quantity * (os.Ventas_en_dolares / os.quantity)) AS returned_sales_usd
FROM
    order_line_sale_dollars os
    LEFT JOIN return_movements_customers rm ON os.order_number = rm.order_id AND os.product = rm.item AND DATE_TRUNC('month', os.date)::DATE = DATE_TRUNC('month', rm.date)::DATE
GROUP BY
    Year,
    Month;


-- Tiendas
-- - Ratio de conversion. Cantidad de ordenes generadas / Cantidad de gente que entra
WITH super_store_and_market_count AS (
    SELECT
        store_id,
        TO_DATE(date, 'YYYY-MM-DD') AS date,
        traffic
    FROM
        stg.super_store_count

    UNION ALL

    SELECT
        store_id,
        TO_DATE(CAST(date AS VARCHAR), 'YYYYMMDD') AS date,
        traffic
    FROM
        stg.market_count
),
order_counts AS (
    SELECT
        DATE_TRUNC('MONTH', os.date) AS month,
        COUNT(DISTINCT os.order_number) AS order_count
    FROM
        stg.order_line_sale os
    GROUP BY
        DATE_TRUNC('MONTH', os.date)
),
traffic_counts AS (
    SELECT
        DATE_TRUNC('MONTH', smc.date) AS month,
        SUM(smc.traffic) AS traffic_count
    FROM
        super_store_and_market_count smc
    GROUP BY
        DATE_TRUNC('MONTH', smc.date)
)
SELECT
    tc.month AS año_mes,
    tc.traffic_count AS cantidad_de_gente_que_entra,
    oc.order_count AS cantidad_de_ordenes_generadas,
    CASE
        WHEN tc.traffic_count = 0 THEN 0
        ELSE CAST(oc.order_count AS NUMERIC) / CAST(tc.traffic_count AS NUMERIC)
    END AS cvr
FROM
    traffic_counts tc
LEFT JOIN
    order_counts oc ON tc.month = oc.month
ORDER BY
    tc.month DESC;

