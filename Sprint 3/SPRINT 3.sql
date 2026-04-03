-- ####################
-- NIVEL 1 ############
-- ####################
-- Exercici 1 #########
-- ####################

-- La teva tasca és dissenyar i crear una taula anomenada 
-- "credit_card" que emmagatzemi detalls crucials sobre 
-- les targetes de crèdit. La nova taula ha de ser capaç 
-- d'identificar de manera única cada targeta i establir 
-- una relació adequada amb les altres dues taules 
-- ("transaction" i "company"). Després de crear la taula serà 
-- necessari que ingressis la informació del document denominat 
-- "dades_introduir_credit".

USE ml94;

-- CREAMOS TABLA ### USER
CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);

-- CREAMOS TABLA ### CREDIT_CARD
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15), 
    iban CHAR(100), 
    pan CHAR(100), 
    pin CHAR(4), 
    cvv CHAR(3), 
    expiring_date CHAR(8)
);

-- NO HABÍA ESTABLECIDO PRIMARY KEY
ALTER TABLE credit_card
ADD PRIMARY KEY(id);

-- CONECTAMOS USER CON TRANSACTION
-- PRIMERO HACEMOS COINCIDIR EL TIPO DE COLUMNA
ALTER TABLE user
MODIFY id INT;

-- CREAMOS FOREIGN KEY. Transaction.user_id apunta a user.id
ALTER TABLE transaction
ADD CONSTRAINT fk_user_id
FOREIGN KEY (user_id)
REFERENCES user(id);

-- CREAMOS FOREIGN KEY. Transaction.credit_card_id apunta a credit_card.id
ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card_id
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

-- COMPROBAMOS
SHOW CREATE TABLE transaction;

-- ####################
-- NIVEL 1 ############
-- ####################
-- Exercici 2 #########
-- ####################

-- El departament de Recursos Humans ha identificat un error en el número de compte 
-- associat a la targeta de crèdit amb ID CcU-2938. La informació que ha de mostrar-se 
-- per a aquest registre és: TR323456312213576817699999. Recorda mostrar que el canvi 
-- es va realitzar.



UPDATE credit_card
SET credit_card.iban = "TR323456312213576817699999"
WHERE credit_card.id = "CcU-2938";

-- ####################
-- NIVEL 1 ############
-- ####################
-- Exercici 3 #########
-- ####################

-- En la taula "transaction" ingressa una nova transacció

ALTER TABLE transaction
DROP FOREIGN KEY fk_credit_card_id;

ALTER TABLE transaction
DROP FOREIGN KEY fk_user_id;

ALTER TABLE transaction
DROP FOREIGN KEY transaction_ibfk_1;

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card_id
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE transaction
ADD CONSTRAINT fk_user_id
FOREIGN KEY (user_id)
REFERENCES user(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE transaction
ADD CONSTRAINT transaction_ibfk_1
FOREIGN KEY (company_id)
REFERENCES company(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

INSERT INTO credit_card (id)
VALUES ('CcU-9999');

INSERT INTO user (id)
VALUES (9999);

INSERT INTO company (id)
VALUES ('b-9999');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

-- ####################
-- NIVEL 1 ############
-- ####################
-- Exercici 4 #########
-- ####################

-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. 
-- Recorda mostrar el canvi realitzat.

ALTER TABLE credit_card
DROP COLUMN pan;

-- ####################
-- NIVEL 2 ############
-- ####################
-- Exercici 1 #########
-- ####################

-- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.

DELETE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- ####################
-- NIVEL 2 ############
-- ####################
-- Exercici 2 #########
-- ####################

-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. Serà 
-- necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. 
-- Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, 
-- ordenant les dades de major a menor mitjana de compra.

CREATE VIEW `VistaMarketing` AS
SELECT c.company_name, c.phone, AVG(t.amount) AS media_de_compra
FROM company c
JOIN transaction t ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.company_name, c.phone;

-- ####################
-- NIVEL 2 ############
-- ####################
-- Exercici 3 #########
-- ####################

-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"

CREATE OR REPLACE VIEW `VistaMarketing` AS
SELECT c.company_name, c.phone, AVG(t.amount) AS media_de_compra
FROM company c
JOIN transaction t ON t.company_id = c.id
WHERE t.declined = 0 AND c.country = "Germany"
GROUP BY c.company_name, c.phone;

-- ####################
-- NIVEL 3 ############
-- ####################
-- Exercici 1 #########
-- ####################

-- PRIMERO DROPEO FK PARA EVITAR ERRORES

ALTER TABLE transaction
DROP FOREIGN KEY fk_credit_card_id;

ALTER TABLE transaction
DROP FOREIGN KEY fk_user_id;

ALTER TABLE transaction
DROP FOREIGN KEY transaction_ibfk_1;

-- SEGUNDO, ESTABLEZCO COMPATIBILIDAD ENTRE COLUMNAS

ALTER TABLE transaction
MODIFY id VARCHAR(255),
MODIFY credit_card_id VARCHAR(20);

ALTER TABLE company
MODIFY id VARCHAR(15);

ALTER TABLE user
MODIFY id INT;

ALTER TABLE credit_card
MODIFY id VARCHAR(20),
MODIFY iban VARCHAR(50),
MODIFY cvv INT,
MODIFY expiring_date VARCHAR(20);

-- POR ÚLTIMO, INTRODUZCO LAS FOREIGN KEYS Y LAS ÓRDENES DELETE Y UPDATE

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card_id
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE transaction
ADD CONSTRAINT fk_user_id
FOREIGN KEY (user_id)
REFERENCES user(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE transaction
ADD CONSTRAINT transaction_ibfk_1
FOREIGN KEY (company_id)
REFERENCES company(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- ####################
-- NIVEL 3 ############
-- ####################
-- Exercici 2 #########
-- ####################

-- L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació: 

-- ID de la transacció 
-- Nom de l'usuari/ària 
-- Cognom de l'usuari/ària
-- IBAN de la targeta de crèdit usada. 
-- Nom de la companyia de la transacció realitzada. 

-- Assegureu-vos d'incloure informació rellevant de les taules que coneixereu i utilitzeu àlies per canviar de 
-- nom columnes segons calgui. Mostra els resultats de la vista, ordena els resultats de forma descendent en 
-- funció de la variable ID de transacció.


CREATE VIEW `InformeTecnico` AS
SELECT
	t.id AS id_transaccio,
	u.name AS nom_usuario,
	u.surname AS apellido_usuario,
	C.iban,
	Cp.company_name AS nombre_compania
FROM transaction t
JOIN user u ON u.id = t.user_id
JOIN credit_card c ON C.id = t.credit_card_id
JOIN company cp ON cp.id = t.company_id
ORDER BY id_transaccio DESC;

explain transaction;
describe transaction;










