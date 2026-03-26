USE transactions;
DESCRIBE transaction;
DESCRIBE company;
SELECT * FROM transaction ORDER BY RAND() LIMIT 100;
SELECT * FROM company ORDER BY RAND() LIMIT 100;
-- ####################
-- NIVEL 1 ############
-- ####################
-- Exercici 2 #########
-- ####################

-- Llistat dels països que estan generant vendes. 

SELECT DISTINCT c.country
FROM transaction t
JOIN company c ON c.id = t.company_id
WHERE t.declined = 0;

-- Des de quants països es generen les vendes. 

SELECT COUNT(DISTINCT c.country)
FROM transaction t
join company c on c.id = t.company_id;

-- Identifica la companyia amb la mitjana més gran de vendes.

SELECT c.company_name, 
		ROUND(AVG(t.amount),2) AS ventas
FROM transaction t
JOIN company c ON c.id = t.company_id
GROUP BY c.company_name
ORDER BY ROUND(AVG(t.amount),2) DESC
LIMIT 1;

-- ####################
-- NIVEL 1 ############
-- ####################
-- Exercici 3 #########
-- ####################

-- Utilitzant només subconsultes (sense utilitzar JOIN): 

-- Mostra totes les transaccions realitzades per empreses 
-- d'Alemanya. 

SELECT t.id
FROM transaction t
WHERE EXISTS (
					SELECT c.id 
					FROM company c
                    WHERE t.company_id = c.id
                    AND c.country = "Germany"
				);

-- Llista les empreses que han realitzat transaccions 
-- per un amount superior a la mitjana de totes les transaccions. 

SELECT DISTINCT c.company_name
FROM company c
WHERE EXISTS (
			SELECT t.company_id 
			FROM transaction t
            WHERE t.company_id = c.id 
            AND t.amount > (
							SELECT AVG(t.amount) 
							FROM transaction t
                            WHERE t.declined = 0 
                            )
			AND t.declined = 0
            );
                            
                            
-- Eliminaran del sistema les empreses que no tenen transaccions registrades, 
-- entrega el llistat d'aquestes empreses.

SELECT DISTINCT c.company_name
FROM company c
WHERE NOT EXISTS (
				SELECT t.company_id
				FROM transaction t
                WHERE t.company_id = c.id
                );
                

-- ####################
-- NIVEL 2 ############
-- ####################
-- Exercici 1 #########
-- ####################

-- Identifica els cinc dies que es va generar la quantitat més gran 
-- d'ingressos a l'empresa per vendes. Mostra la data de cada transacció 
-- juntament amb el total de les vendes.


SELECT CAST(t.timestamp AS DATE) AS dia, 
		c.company_name, 
        ROUND(SUM(t.amount),2) AS ventas
FROM transaction t
JOIN company c on c.id = t.company_id
WHERE t.declined = 0
GROUP BY dia, c.company_name
ORDER BY ventas DESC
LIMIT 5;

-- Quina és la mitjana de vendes per país? 
-- Presenta els resultats ordenats de major a menor mitjà.

SELECT c.country, ROUND(AVG(t.amount),2) AS media_de_ventas
FROM company c
JOIN transaction t ON t.company_id = c.id
GROUP BY country
ORDER BY media_de_ventas DESC;

-- ####################
-- NIVEL 2 ############
-- ####################
-- Exercici 2 #########
-- ####################

-- En la teva empresa, es planteja un nou projecte per a llançar algunes 
-- campanyes publicitàries per a fer competència a la companyia "Non Institute". 
-- Per a això, et demanen la llista de totes les transaccions realitzades per 
-- empreses que estan situades en el mateix país que aquesta companyia.

-- Mostra el llistat aplicant JOIN i subconsultes.

SELECT t.id
FROM transaction t
JOIN company c ON c.id = t.company_id
WHERE t.declined = 0
AND c.country = (
					SELECT DISTINCT c.country
					FROM company c
					JOIN transaction t ON t.company_id = c.id
					WHERE c.company_name = "Non Institute"
                    )
AND c.company_name <> "Non Institute";

-- Mostra el llistat aplicant solament subconsultes.

SELECT t.id
FROM transaction t
WHERE t.declined = 0
AND EXISTS (
					SELECT 1 
					FROM company c 
					WHERE c.id = t.company_id
                    AND c.country = (
									SELECT DISTINCT c.country 
									FROM company c 
									WHERE c.company_name = "Non Institute")
                                            )
AND NOT EXISTS (
						SELECT 1 
						FROM company c 
                        WHERE c.id = t.company_id
                        AND c.company_name = "Non Institute"
                        );
                        
                        
-- ####################
-- NIVEL 3 ############
-- ####################
-- Exercici 1 #########
-- ####################

-- Presenta el nom, telèfon, país, data i amount, 
-- d'aquelles empreses que van realitzar transaccions amb 
-- un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates: 
-- 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024.
-- Ordena els resultats de major a menor quantitat.

SELECT c.company_name, 
		c.phone, 
        c.country,
        CAST(t.timestamp AS DATE) AS fecha, 
        ROUND(t.amount,2) AS cantidad
FROM transaction t
JOIN company c ON c.id = t.company_id
WHERE (t.amount BETWEEN 350 AND 400)
AND CAST(t.timestamp AS DATE)= "2015-04-29" 
	OR CAST(t.timestamp AS DATE) = "2018-07-13" 
    OR CAST(t.timestamp AS DATE) = "2024-03-13"
ORDER BY cantidad DESC;
    
    
-- ####################
-- NIVEL 3 ############
-- ####################
-- Exercici 2 #########
-- ####################

-- Necessitem optimitzar l'assignació dels recursos i dependrà 
-- de la capacitat operativa que es requereixi, per la qual cosa 
-- et demanen la informació sobre la quantitat de transaccions que 
-- realitzen les empreses, però el departament de recursos humans 
-- és exigent i vol un llistat de les empreses on especifiquis si 
-- tenen més de 400 transaccions o menys.

SELECT c.company_name, 
		COUNT(t.id) AS transacciones,
	CASE
		WHEN COUNT(t.id) > 400 THEN "Si"	
        ELSE "No"
	END AS mas_de_400_transacciones
FROM transaction t
JOIN company c ON c.id = t.company_id
GROUP BY c.company_name
ORDER BY transacciones DESC;


                        



