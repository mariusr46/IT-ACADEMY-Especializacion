/* Creamos un database de 0 para hacer el Sprint 3*/

CREATE DATABASE sprint3;
USE sprint3;

/* APLICAMOS LOS MOLDES YA FACILITADOS PARA LAS TABLAS company Y transaction */
    -- Creamos la tabla company
    CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );

    -- Creamos la tabla transaction
    CREATE TABLE IF NOT EXISTS `transaction` (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(15) REFERENCES credit_card(id),
        company_id VARCHAR(20), 
        user_id INT REFERENCES user(id),
        lat FLOAT,
        longitude FLOAT,
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        FOREIGN KEY (company_id) REFERENCES company(id) 
    );
    
-- CARGAMOS LOS DATOS EN LAS TABLAS ANTES DE EMPEZAR CON EL EJERCICIO 1 DEL NIVEL 1

/* #################
NIVEL 1 ############
####################
Exercici 1 #########
####################

La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi 
detalls crucials sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar 
de manera única cada targeta i establir una relació adequada amb les altres dues taules 
("transaction" i "company"). Després de crear la taula serà necessari que ingressis la 
informació del document denominat "dades_introduir_credit". Recorda mostrar el diagrama 
i realitzar una breu descripció d'aquest. */

CREATE TABLE credit_card (
	id VARCHAR(20) PRIMARY KEY, 
    iban VARCHAR(50),
    pan VARCHAR(20),
    pin VARCHAR(4),
    cvv INT,
    expiring_date VARCHAR(20),
    fecha_actual DATE
);

/* Cargo los datos de credit_card */

/* Establecemos relación entre transaction y credit_card. En este caso conectamos
transaction.credit_card_id con credit_card.id a través de un CONSTRAINT*/

ALTER TABLE `transaction`
ADD CONSTRAINT fk_transaction_credit_card FOREIGN KEY (credit_card_id)
REFERENCES credit_card (id);


/* #################
NIVEL 1 ############
####################
Exercici 2 #########
####################

El departament de Recursos Humans ha identificat un error en el número de compte associat 
a la targeta de crèdit amb ID CcU-2938. La informació que ha de mostrar-se per a aquest 
registre és: TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar. */

UPDATE credit_card
SET credit_card.iban = 'TR323456312213576817699999'
WHERE credit_card.id = 'CcU-2938';

SELECT *
FROM credit_card c
WHERE c.id = 'CcU-2938';

/* #################
NIVEL 1 ############
####################
Exercici 3 #########
####################

En la taula "transaction" ingressa una nova transacció amb la següent informació:

Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id	CcU-9999
company_id	b-9999
user_id	9999
lat	829.999
longitude	-117.999
amount	111.11
declined	0 */

INSERT INTO credit_card (id)
VALUES ('CcU-9999');

INSERT INTO company (id)
VALUES ('b-9999');

INSERT INTO `transaction` (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

/* COMPROBAMOS INSERCIÓN */

SELECT *
FROM `transaction` t
WHERE t.credit_card_id = 'CcU-9999';

/* #################
NIVEL 1 ############
####################
Exercici 4 #########
####################

Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. 
Recorda mostrar el canvi realitzat. */

ALTER TABLE credit_card
DROP COLUMN pan;

/* COMPROBAMOS LA ELIMINACIÓN DE LA TABLA */

SELECT *
FROM credit_card;

/* #################
NIVEL 2 ############
####################
Exercici 1 #########
####################

Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD 
de la base de dades. */

DELETE FROM `transaction`
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- COMPROBACIÓN

SELECT *
FROM `transaction` t
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

/* #################
NIVEL 2 ############
####################
Exercici 2 #########
####################

La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi 
i estratègies efectives. S'ha sol·licitat crear una vista que proporcioni detalls clau sobre 
les companyies i les seves transaccions. Serà necessària que creïs una vista anomenada VistaMarketing 
que contingui la següent informació: Nom de la companyia. Telèfon de contacte. País de residència. 
Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de 
major a menor mitjana de compra. */

CREATE OR REPLACE VIEW `VistaMarketing` AS
SELECT c.company_name, 
		c.phone, 
        c.country, 
        AVG(t.amount) AS media_de_compra
FROM company c
JOIN `transaction` t 
	ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.id, c.phone, c.country
ORDER BY media_de_compra DESC;

/* #################
NIVEL 2 ############
####################
Exercici 3 #########
####################

Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu 
país de residència en "Germany" */

SELECT *
FROM VistaMarketing
WHERE  country = "Germany";

/* #################
NIVEL 3 ############
####################
Exercici 1 #########
####################

La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. 
Un company del teu equip va realitzar modificacions en la base de dades, però 
no recorda com les va realitzar. Et demana que l'ajudis a deixar els comandos 
executats per a obtenir el següent diagrama: */

/* PASO 1 - CREAMOS DATA_USER*/
CREATE TABLE IF NOT EXISTS data_user (
	id INT PRIMARY KEY,
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

/* PASO 2 - INSERTAMOS USUARIOS EN DATA_USER */

INSERT INTO data_user (id)
SELECT DISTINCT user_id
FROM `transaction`;

/* PASO 3 - AÑADIMOS CONSTRAINT */

ALTER TABLE `transaction`
ADD CONSTRAINT fk_transaction_data_user FOREIGN KEY (user_id)
REFERENCES data_user (id);

/* PASO 4 - DROPEAMOS WEBSITE DE COMPANY */

ALTER TABLE company
DROP COLUMN website;

/* PASO 5 - ACTUALIZAMOS credit_card_id a VARCHAR(20)*/

ALTER TABLE `transaction`
MODIFY COLUMN credit_card_id VARCHAR(20);

/* PASO 6 - ACTUALIZAMOS NOMBRE DE COLUMNA personal_email en DATA_USER*/

ALTER TABLE data_user
RENAME COLUMN email TO personal_email;

/* #################
NIVEL 3 ############
####################
Exercici 2 #########
####################

L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui 
la següent informació:

ID de la transacció
Nom de l'usuari/ària
Cognom de l'usuari/ària
IBAN de la targeta de crèdit usada.
Nom de la companyia de la transacció realitzada.
Assegureu-vos d'incloure informació rellevant de les taules que coneixereu i utilitzeu àlies 
per canviar de nom columnes segons calgui.
Mostra els resultats de la vista, ordena els resultats de forma descendent en funció de la 
variable ID de transacció. */

CREATE VIEW `InformeTecnico` AS
SELECT
	t.id AS id_transaccio,
	u.name AS nom_usuario,
	u.surname AS apellido_usuario,
	C.iban,
	Cp.company_name AS nombre_compania
FROM `transaction` t
JOIN data_user u ON u.id = t.user_id
JOIN credit_card c ON C.id = t.credit_card_id
JOIN company cp ON cp.id = t.company_id
ORDER BY id_transaccio DESC;

SELECT *
FROM InformeTecnico;


















    
    