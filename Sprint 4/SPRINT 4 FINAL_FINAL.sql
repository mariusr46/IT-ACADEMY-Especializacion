



DROP DATABASE sprint4final;
CREATE DATABASE sprint4final;
USE SPRINT4final;

/* ################
NIVEL 1 ###########
###################
Exercici 0 ########
###################

escàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema 
d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les 
següents consultes: */


CREATE TABLE IF NOT EXISTS company(
	id INT NOT NULL PRIMARY KEY,
    company_name VARCHAR(255),
    phone VARCHAR(15),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS user(
	id INT NOT NULL PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    birth_date VARCHAR(100),
    country VARCHAR(150),
    city VARCHAR(150),
    postal_code VARCHAR(100),
    address VARCHAR(255)
);


CREATE TABLE IF NOT EXISTS credit_card(
	id INT NOT NULL PRIMARY KEY,
    user_id INT NOT NULL,
    iban VARCHAR(50),
    pan VARCHAR(255),
    pin VARCHAR(4),
    cvv INT,
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date DATE
);


CREATE TABLE IF NOT EXISTS product(
	id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(5,2),
    colour VARCHAR(7),
    weight DECIMAL(3,1),
    warehouse_id VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS `transaction` (
	id VARCHAR(255) NOT NULL PRIMARY KEY,
    card_id INT NOT NULL,
    company_id INT NOT NULL,
    timestamp DATETIME,
    amount DECIMAL(10,2),
    declined TINYINT(1),
    products_id VARCHAR(255) NOT NULL,
    user_id INT NOT NULL,
    lat FLOAT,
    longitude FLOAT
);


/* SHOW VARIABLES LIKE 'secure_file_priv' */
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'Users/mariuslungu/IT ACADEMY/especializacion/archivos/sql/Sprint 4/companies.csv'
INTO TABLE company
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(@id, company_name, @phone, email, country, website)
SET 
	id = REPLACE(@id, 'b-', ''),
    phone = REPLACE(@phone, ' ', '');


LOAD DATA LOCAL INFILE 'Users/mariuslungu/IT ACADEMY/especializacion/archivos/sql/Sprint 4/american_users.csv'
INTO TABLE user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;


LOAD DATA LOCAL INFILE 'Users/mariuslungu/IT ACADEMY/especializacion/archivos/sql/Sprint 4/european_users.csv'
INTO TABLE user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;


LOAD DATA LOCAL INFILE 'Users/mariuslungu/IT ACADEMY/especializacion/archivos/sql/Sprint 4/credit_cards.csv'
INTO TABLE credit_card
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(@id, user_id, iban, pan, pin, cvv, @track1, @track2, @expiring_date)
SET 
	id = REPLACE(REPLACE(@id, 'CcS-',''), 'CcU-',''),
	track1 = REPLACE(@track1, '%', ''),
    track2 = REPLACE(@track2, '%', ''),
    expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');


LOAD DATA LOCAL INFILE 'Users/mariuslungu/IT ACADEMY/especializacion/archivos/sql/Sprint 4/products.csv'
INTO TABLE product
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(id, product_name, @price, @colour, weight, @warehouse_id)
SET 
	price = REPLACE(@price, '$', ''),
    colour = REPLACE(@colour, '#', ''),
    warehouse_id = REPLACE(@warehouse_id, '-', '');
    
UPDATE product
SET warehouse_id = REPLACE(warehouse_id, 'WH', '');

LOAD DATA LOCAL INFILE 'Users/mariuslungu/IT ACADEMY/especializacion/archivos/sql/Sprint 4/transactions.csv'
INTO TABLE `transaction`
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
IGNORE 1 ROWS
(id, @card_id, @company_id, @timestamp, amount, declined, products_id, user_id, lat, longitude)
SET 
	card_id = REPLACE(REPLACE(@card_id, 'CcS-',''), 'CcU-',''),
    company_id = REPLACE(@company_id, 'b-', ''),
    timestamp = STR_TO_DATE(@timestamp, 'Y%/%m/%d %H:%i:%s');

	ALTER TABLE `transaction`
    ADD CONSTRAINT fk_transaction_credit_card_id
		FOREIGN KEY (card_id)
        REFERENCES credit_card(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE;
    
    ALTER TABLE `transaction`
	ADD CONSTRAINT fk_transaction_company_id
		FOREIGN KEY (company_id)
        REFERENCES company(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE;
    
    ALTER TABLE `transaction`
	ADD CONSTRAINT fk_transaction_user_id
		FOREIGN KEY (user_id)
        REFERENCES user(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE;

SELECT * FROM company;
DESCRIBE table company;
SELECT * FROM user;
DESCRIBE table user;
SELECT * FROM credit_card;
DESCRIBE table credit_card;
SELECT * FROM product;
DESCRIBE table product;
SELECT * FROM `transaction`;
DESCRIBE table `transaction`;


-- ####################
-- NIVEL 1 ############
-- ####################
-- Exercici 1 #########
-- ####################

-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.

SELECT u.*
FROM user u
WHERE EXISTS (
		SELECT u.id, count(t.id) as transaccions
        FROM `transaction` t
        WHERE t.user_id = u.id
        GROUP BY u.id
        HAVING count(t.id) > 80
);

-- ####################
-- NIVEL 1 ############
-- ####################
-- Exercici 2 #########
-- ####################
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT cc.iban, 
		AVG(t.amount) AS media_gasto
FROM credit_card cc
JOIN `transaction` t 
	ON t.card_id = cc.id
JOIN company c 
	ON c.id = t.company_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban;

/* ####################
NIVEL 2 ############
####################
Exercici 1 #########
#################### */

/* Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les tres últimes transaccions 
han estat declinades aleshores és inactiu, si almenys una no és rebutjada aleshores és actiu. */

CREATE TABLE active_credit_card (
	id INT NOT NULL PRIMARY KEY,
    active ENUM('Activa', 'Inactiva')
);
INSERT INTO active_credit_card
WITH transacciones_detalle AS (
		SELECT card_id,
		declined,
        ROW_NUMBER() OVER(
        PARTITION BY card_id ORDER BY timestamp DESC
        ) AS numero
FROM `transaction` t
),
filtro_actividad AS (
	SELECT 
		card_id,
        COUNT(*) AS lista_total,
        SUM(declined) AS num_cancelados
	FROM transacciones_detalle
    WHERE numero <= 3
    GROUP BY card_id)
SELECT card_id,
	CASE
		WHEN num_cancelados = 3 THEN 'Inactiva'
        ELSE 'Activa'
	END AS estado_actividad
FROM filtro_actividad;

SELECT * 
FROM active_credit_card;

ALTER TABLE active_credit_card
ADD CONSTRAINT fk_active_credit_card_credit_card
FOREIGN KEY (id) REFERENCES credit_card (id);



/* #################
NIVEL 3 ############
####################
Exercici 1 #########
####################

Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv 
amb la base de dades creada, tenint en compte que des de transaction tens 
product_ids. Genera la següent consulta: 

Necessitem conèixer el nombre de vegades que s'ha venut cada producte.*/

CREATE TABLE IF NOT EXISTS product_transaction (
	transaction_id VARCHAR(255) NOT NULL,
    declined TINYINT(1),
    product_id INT NOT NULL,
    PRIMARY KEY(transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES `transaction`(id),
    FOREIGN KEY (product_id) REFERENCES product(id)
);

INSERT INTO product_transaction
SELECT t.id, 
	t.declined, 
	js.product_id
FROM `transaction` t
JOIN JSON_TABLE(
	CONCAT('[', REPLACE(t.products_id, ' ', ''), ']'),
    '$[*]' COLUMNS (
		product_id INT PATH '$'
    )
) AS js;

SELECT * FROM product_transaction;
DESCRIBE product_transaction;

/* Necessitem conèixer el nombre de vegades que s'ha venut cada producte. */

/* FORMA RÁPIDA*/

SELECT pt.product_id,
		COUNT(pt.product_id) AS numero_ventas
FROM product_transaction pt
WHERE pt.declined = 0
GROUP BY pt.product_id;

/* FORMA DETALLADA */

SELECT p.*, 
		count(pt.product_id) AS numero_ventas
FROM product_transaction pt
JOIN product p
	ON p.id = pt.product_id
WHERE pt.declined = 0
GROUP BY pt.product_id
ORDER BY numero_ventas DESC;

/* FORMA DETALLADA CON TOTAL*/

SELECT p.*, 
		count(pt.product_id) AS numero_ventas,
        sum(p.price) AS total
FROM product_transaction pt
JOIN product p
	ON p.id = pt.product_id
JOIN `transaction` t
	ON t.id = pt.transaction_id
GROUP BY pt.product_id
ORDER BY numero_ventas DESC;








