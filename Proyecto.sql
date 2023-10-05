-- ################### PROYECTO FINAL ####################
-- Janice Katherine Escobedo Vasquez

-- Creacion base de datos OlistData
CREATE DATABASE OlishData
-- Cambiando base de datos a OlistData
USE OlishData

-- Pregunta 1:
-- Las ventas por internet han ido aumentando a lo largo de los a;os por el avance 
-- de la tecnologia y la facilidad de compra por paginas web. 
-- Será la tarjeta de credito el medio de pago mas comun? 

SELECT
payment_type AS TipoPago,
COUNT(payment_type) as Cantidad,
SUM(payment_value) as CifraAlcanzada,
AVG(payment_value) as PromedioPagoPorProducto
FROM
[dbo].[PaymentsDataset]
Group BY
payment_type
ORDER BY
CifraAlcanzada DESC

-- Pregunta 2:
-- La empresa con el fin de mejorar sus ventas desea saber la puntuacion de 
-- satisfaccion por categoria, para poder investigar a que se debe tal puntuacion
-- Se desea saber el puntaje de satisfaccion promedio por categoria de producto
-- para poder mejorar en el envio de algunos productos o para que los vendedores
-- consigan mejores provedores y puedan ofrecer productos de mejor calidad

CREATE VIEW PuntajePorCategoria
AS
SELECT
B.order_id,
A.category_name,
MAX(B.order_item_id) AS quantity,
B.price,
B.freight_value, -- costo por envio
SUM(B.price + B.freight_value) AS amount, -- monto total
C.review_score
FROM
(
	-- subconsulta
	SELECT
	product_id,
	CASE 
		-- Hacemos el cambio ya que hay categorias vacias (NULL)
		WHEN product_category_name IS NULL THEN 'unknown' 
		ELSE product_category_name
	END AS category_name
	FROM
	[dbo].[ProductDataset]
) A
INNER JOIN
[dbo].[OrderItemsDataset] B
ON A.product_id = B.product_id
INNER JOIN
[dbo].[OrderReviewsDataset] C
ON B.order_id = C.order_id
GROUP BY
B.order_id,
A.category_name,
B.price,
B.freight_value,
C.review_score

-- Sacando la categoria con el score promedio
SELECT
category_name ,
AVG(review_score) AS avg_score
FROM
[dbo].[PuntajePorCategoria] 
GROUP BY 
category_name
ORDER BY
avg_score ASC

-- Pregunta 3:
-- Queremos saber si hemos mejorado en la valoracion conforme avanzan los año.
-- Saquemos un promedio por año de la valoracion por producto y veamos el progreso
CREATE VIEW consulta3
AS
SELECT
A.order_id,
A.customer_id,
DATEPART(YEAR,A.order_purchase_timestamp) AS year_order, -- sacando el año de el campo mostrado
A.order_purchase_timestamp,
B.review_score
FROM
[dbo].[OrdersDataset] A
INNER JOIN
[dbo].[OrderReviewsDataset] B 
ON A.order_id = B.order_id
GROUP BY
A.order_id,
A.customer_id,
A.order_purchase_timestamp,
B.review_score

-- Hacemos un pivot para mostrar la variacion de review_score por año
SELECT 
'Valoracion' AS Reporte,
[2016],[2017],[2018]
FROM
(
	SELECT 
	review_score,
	year_order
	FROM
	[dbo].[consulta3] )AS A
PIVOT(AVG(review_score) FOR year_order -- -- promedio del score para cada uno de los añoa de venta
	IN([2016],[2017],[2018])) AS PVT

-- Pregunta 4:
-- Queremos saber en cuanto varia el costo por envio de el vendedor
-- a el cliente por estado
CREATE VIEW Stores -- creando vista Stores
AS
SELECT
B.order_id,
MAX(B.order_item_id) as quantity, -- cantidad de productos
A.seller_state,
D.customer_state,
CASE 
	-- Vemos si el transporte va a otro estado
	WHEN A.seller_state=D.customer_state THEN 'to the same state' 
	ELSE 'to different state'
END AS transportation,
B.freight_value
FROM
[dbo].[SellersDataset] A
INNER JOIN
[dbo].[OrderItemsDataset] B
ON A.seller_id = B.seller_id
INNER JOIN
[dbo].[OrdersDataset] C
ON B.order_id = C.order_id
INNER JOIN
[dbo].[CustomersDataset] D
ON C.customer_id= D.customer_id
GROUP BY
B.order_id,
A.seller_state,
D.customer_state,
B.freight_value

-- Sacando el cobro promedio por envio entre estados
SELECT customer_state, [PE],[PB],[PA],[RS],[AC],[BA],[SP],[SC],[SE],
[MA],[RO],[DF],[MT],[PR],[CE],[MG],[MS],[GO],[RN],[RJ],[ES],[AM],[PI]
FROM
(
	SELECT 
	customer_state,
	freight_value,
	seller_state
	FROM
	[dbo].[Stores] )AS B
PIVOT(AVG(freight_value) FOR seller_state -- -- promedio del score para cada uno de los añoa de venta
	IN([PE],[PB],[PA],[RS],[AC],[BA],[SP],[SC],[SE],
[MA],[RO],[DF],[MT],[PR],[CE],[MG],[MS],[GO],[RN],[RJ],[ES],[AM],[PI])) AS PVT2



