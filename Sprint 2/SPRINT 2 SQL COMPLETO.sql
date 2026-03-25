USE transactions;

-- ####################
-- NIVEL 1
-- ####################

-- Exercici 2

-- Llistat dels països que estan generant vendes. 

SELECT DISTINCT c.country
FROM transaction AS t
JOIN company as c ON c.id = t.company_id;

-- Des de quants països es generen les vendes. 

SELECT COUNT(DISTINCT c.country)
from transaction as t
join company as c on c.id = t.company_id;

-- Identifica la companyia amb la mitjana més gran de vendes.

SELECT c.company_name, AVG(t.amount) AS ventas
FROM transaction AS t
JOIN company AS c ON c.id = t.company_id
GROUP BY c.company_name
ORDER BY c.company_name DESC
LIMIT 1;

-- Exercici 3

-- Utilitzant només subconsultes (sense utilitzar JOIN): 

-- Mostra totes les transaccions realitzades per empreses 
-- d'Alemanya. 

USE transactions;

SELECT t.id
FROM transaction as t
WHERE company_id IN (SELECT id 
					FROM company 
                    WHERE country = "Germany");

-- Llista les empreses que han realitzat transaccions 
-- per un amount superior a la mitjana de totes les transaccions. 

SELECT c.company_name
FROM company as c
WHERE id IN (SELECT t.company_id 
			FROM transaction as t
            WHERE amount > (SELECT AVG(t.amount) 
							FROM transaction AS t));
                            
                            
-- Eliminaran del sistema les empreses que no tenen transaccions registrades, 

DELETE FROM company
WHERE id NOT IN (SELECT t.company_id 
				FROM transaction as t);

-- entrega el llistat d'aquestes empreses.

SELECT DISTINCT c.company_name
FROM company AS c
WHERE id NOT IN (SELECT t.company_id 
				FROM transaction as t);

-- ####################
-- NIVEL 2
-- ####################

-- Exercici 1

-- Identifica els cinc dies que es va generar la quantitat més gran 
-- d'ingressos a l'empresa per vendes. Mostra la data de cada transacció 
-- juntament amb el total de les vendes.

USE transactions;

SELECT DATE(t.timestamp) AS dia, id, SUM(t.amount) AS ventas
FROM transaction as t
GROUP BY dia, id
ORDER BY ventas DESC
LIMIT 5;

-- Quina és la mitjana de vendes per país? 
-- Presenta els resultats ordenats de major a menor mitjà.

SELECT c.country, AVG(t.amount) AS media_de_ventas
FROM company AS c
JOIN transaction AS t ON t.company_id = c.id
GROUP BY country
ORDER BY country DESC;

-- Exercici 2

-- En la teva empresa, es planteja un nou projecte per a llançar algunes 
-- campanyes publicitàries per a fer competència a la companyia "Non Institute". 
-- Per a això, et demanen la llista de totes les transaccions realitzades per 
-- empreses que estan situades en el mateix país que aquesta companyia.

-- Mostra el llistat aplicant JOIN i subconsultes.

SELECT t.id
FROM transaction AS t
JOIN company AS c ON c.id = t.company_id
WHERE c.country = (SELECT DISTINCT c.country
							FROM company AS c
							JOIN transaction AS t ON t.company_id = c.id
							WHERE c.company_name = "Non Institute")
AND c.company_name <> "Non Institute";

-- Mostra el llistat aplicant solament subconsultes.

SELECT t.id
FROM transaction AS t
WHERE t.company_id IN (SELECT c.id 
						FROM company AS c 
                        WHERE c.country = (SELECT DISTINCT c.country 
											FROM company AS c 
                                            WHERE c.company_name = "Non Institute"))
AND company_id NOT IN (SELECT c.id 
						FROM company AS c 
                        WHERE c.company_name = "Non Institute");
                        
                        
-- ####################
-- NIVEL 3
-- ####################

USE transactions;

-- Exercici 1

-- Presenta el nom, telèfon, país, data i amount, 
-- d'aquelles empreses que van realitzar transaccions amb 
-- un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates: 
-- 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024.
-- Ordena els resultats de major a menor quantitat.

SELECT c.company_name, c.phone, c.country, DATE(t.timestamp) AS fecha, t.amount
FROM transaction AS t
JOIN company AS c ON c.id = t.company_id
WHERE (t.amount BETWEEN 350 AND 400)
AND (DATE(t.timestamp) = "2015-04-29" 
	OR DATE(t.timestamp) = "2018-07-13" 
    OR DATE(t.timestamp) = "2024-03-13");
    
    
-- Exercici 2

-- Necessitem optimitzar l'assignació dels recursos i dependrà 
-- de la capacitat operativa que es requereixi, per la qual cosa 
-- et demanen la informació sobre la quantitat de transaccions que 
-- realitzen les empreses, però el departament de recursos humans 
-- és exigent i vol un llistat de les empreses on especifiquis si 
-- tenen més de 400 transaccions o menys.

SELECT c.company_name, COUNT(t.id) AS transacciones,
	CASE
		WHEN COUNT(t.id) > 400 THEN "Si"	
        ELSE "No"
	END AS mas_de_400_transacciones
FROM transaction AS t
JOIN company AS c ON c.id = t.company_id
GROUP BY c.company_name;


                        



