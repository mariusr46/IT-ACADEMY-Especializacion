



DROP DATABASE sprint4;
CREATE DATABASE sprint4;
USE SPRINT4;

/* ################
NIVEL 1 ###########
###################
Exercici 0 ########
###################

escàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema 
d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les 
següents consultes: */


CREATE TABLE IF NOT EXISTS company(
	id VARCHAR(20) PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS users (
	id INT NOT NULL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(100),
    birth_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255)
);


CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(20) NOT NULL PRIMARY KEY,
    user_id INT NOT NULL,
    iban VARCHAR(50) NOT NULL,
    pan VARCHAR(30),
    pin CHAR(4),
    cvv CHAR(3),
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date DATE
);


CREATE TABLE IF NOT EXISTS product (
	id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    colour CHAR(7),
    weight DECIMAL(5,2),
    warehouse_id VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS transactions (
	id VARCHAR(255) NOT NULL PRIMARY KEY,
    card_id VARCHAR(20) NOT NULL,
    company_id VARCHAR(20) NOT NULL,
    timestamp DATETIME NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    declined TINYINT(1) NOT NULL,
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
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA LOCAL INFILE 'Users/mariuslungu/IT ACADEMY/especializacion/archivos/sql/Sprint 4/american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET
    birth_date = STR_TO_DATE(@birth_date, '%b %e, %Y');


LOAD DATA LOCAL INFILE 'Users/mariuslungu/IT ACADEMY/especializacion/archivos/sql/Sprint 4/european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET
    birth_date = STR_TO_DATE(@birth_date, '%b %e, %Y');


LOAD DATA LOCAL INFILE 'Users/mariuslungu/IT ACADEMY/especializacion/archivos/sql/Sprint 4/credit_cards.csv'
INTO TABLE credit_card
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, user_id, iban, pan, pin, cvv, track1, track2, @expiring_date)
SET
    expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');

LOAD DATA LOCAL INFILE 'Users/mariuslungu/IT ACADEMY/especializacion/archivos/sql/Sprint 4/products.csv'
INTO TABLE product
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, product_name, @price, colour, weight, warehouse_id)
SET price = REPLACE(@price, '$', '');

LOAD DATA LOCAL INFILE 'Users/mariuslungu/IT ACADEMY/especializacion/archivos/sql/Sprint 4/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

	ALTER TABLE transactions
    ADD CONSTRAINT fk_transaction_credit_card_id
		FOREIGN KEY (card_id)
        REFERENCES credit_card(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE;
    
    ALTER TABLE transactions
	ADD CONSTRAINT fk_transaction_company_id
		FOREIGN KEY (company_id)
        REFERENCES company(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE;
    
    ALTER TABLE transactions
	ADD CONSTRAINT fk_transaction_user_id
		FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE;

SELECT * FROM company;
DESCRIBE table company;
SELECT * FROM users;
DESCRIBE table users;
SELECT * FROM credit_card;
DESCRIBE table credit_card;
SELECT * FROM product;
DESCRIBE table product;
SELECT * FROM transactions;
DESCRIBE table transactions;


-- ####################
-- NIVEL 1 ############
-- ####################
-- Exercici 1 #########
-- ####################

-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.

SELECT u.*
FROM users u
WHERE EXISTS (
		SELECT u.id, count(t.id) as transaccions
        FROM transactions t
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
		ROUND(AVG(t.amount),2) AS media_gasto
FROM credit_card cc
JOIN transactions t 
	ON t.card_id = cc.id
JOIN company c 
	ON c.id = t.company_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban
ORDER BY media_gasto DESC;

/* ####################
NIVEL 2 ############
####################
Exercici 1 #########
####################

Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les tres últimes transaccions 
han estat declinades aleshores és inactiu, si almenys una no és rebutjada aleshores és actiu. */

CREATE TABLE active_credit_card (
	card_id VARCHAR(20) NOT NULL PRIMARY KEY,
    active ENUM('Activa', 'Inactiva') NOT NULL
);
INSERT INTO active_credit_card
WITH transacciones_detalle AS (
		SELECT card_id,
		declined,
        ROW_NUMBER() OVER(
        PARTITION BY card_id ORDER BY timestamp DESC
        ) AS numero
FROM transactions t
)  
SELECT td.card_id,
	CASE
		WHEN COUNT(*) = 3 AND SUM(td.declined) = 3 THEN 'Inactiva'
        ELSE 'Activa'
	END AS estado_actividad
FROM transacciones_detalle td
WHERE td.numero <= 3
GROUP BY td.card_id;


SELECT * 
FROM active_credit_card;

ALTER TABLE active_credit_card
ADD CONSTRAINT fk_active_credit_card_credit_card
FOREIGN KEY (card_id) REFERENCES credit_card (id);



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
    product_id INT NOT NULL,
    PRIMARY KEY(transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions (id),
    FOREIGN KEY (product_id) REFERENCES product(id)
);

INSERT INTO product_transaction (transaction_id, product_id)
SELECT t.id,
	js.product_id
FROM transactions t
JOIN JSON_TABLE(
	CONCAT('[', REPLACE(t.products_id, ' ', ''), ']'),
    '$[*]' COLUMNS (
		product_id INT PATH '$'
    )
) AS js;

SELECT * FROM product_transaction;
DESCRIBE product_transaction;

/* Necessitem conèixer el nombre de vegades que s'ha venut cada producte. */

SELECT pt.product_id,
		COUNT(pt.product_id) AS numero_ventas
FROM product_transaction pt
GROUP BY pt.product_id;









