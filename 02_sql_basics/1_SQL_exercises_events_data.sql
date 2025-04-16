/* -------------------------------------------------------------------------------------------
William Sebastian Calderon Quintero
Base de Datos Empresa de Eventos
---------------------------------------------------------------------------------------------------*/
/* ------------------------------------------------------------------------------------------------
A continuación de presenta la creación de la base de datos y de las tablas
--------------------------------------------------------------------------------------------------*/
DROP DATABASE empresa_eventos;
CREATE DATABASE empresa_eventos;
USE empresa_eventos;

CREATE TABLE ACTIVIDADES (
    id_actividad INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    costo DECIMAL(20, 2) NOT NULL
);

CREATE TABLE UBICACION (
    id_ubicacion INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    direccion VARCHAR(100) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    caracteristicas TEXT,
    precio DECIMAL(20, 2),
    aforo INT
);

CREATE TABLE ARTISTAS (
    id_artista INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    biografia TEXT
);

CREATE TABLE EVENTO (
    id_evento INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    precio DECIMAL(20, 2),
    id_actividad INT,
    id_ubicacion INT,
    FOREIGN KEY (id_actividad) REFERENCES ACTIVIDADES(id_actividad),
    FOREIGN KEY (id_ubicacion) REFERENCES UBICACION(id_ubicacion)
);

CREATE TABLE PARTICIPAN (
    id_actividad INT,
    id_artista INT,
    cache DECIMAL(20, 2),
    PRIMARY KEY (id_actividad, id_artista),
    FOREIGN KEY (id_actividad) REFERENCES ACTIVIDADES(id_actividad),
    FOREIGN KEY (id_artista) REFERENCES ARTISTAS(id_artista)
);

CREATE TABLE ASISTENTES (
    id_asistente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    telefonos VARCHAR(50),
    email VARCHAR(100) NOT NULL
);

CREATE TABLE ASISTE (
    id_evento INT,
    id_asistente INT,
    calificacion DECIMAL(20, 1),
    PRIMARY KEY (id_evento, id_asistente),
    FOREIGN KEY (id_evento) REFERENCES EVENTO(id_evento),
    FOREIGN KEY (id_asistente) REFERENCES ASISTENTES(id_asistente)
);

/*------------------------------------------------------------------------------------------------------
Trigger para controlar el Aforo de cada evento
-------------------------------------------------------------------------------------------------------*/

DELIMITER $$

CREATE TRIGGER verificar_aforo
BEFORE INSERT ON ASISTE
FOR EACH ROW
BEGIN
    
    DECLARE aforo_maximo INT;
    DECLARE total_asistentes INT;

    -- 1. Determinar el aforo max de la ubicación
    
    SELECT U.aforo INTO aforo_maximo
    FROM EVENTO E
    JOIN UBICACION U ON E.id_ubicacion = U.id_ubicacion
    WHERE E.id_evento = NEW.id_evento;

    -- Obtener el numero de total de asistentes ya registrados para el evento
    
    SELECT COUNT(*) INTO total_asistentes
    FROM ASISTE
    WHERE id_evento = NEW.id_evento;

    -- Verificar si el numero de asistentes supera el aforo
    
    IF total_asistentes >= aforo_maximo THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Se ha superado el aforo maximo para este Evento';
    END IF;
    
END $$

DELIMITER ;

/*------------------------------------------------------------------------------------------------------
Insersión de Datos: Para ACTIVIDADES, ARTISTAS, ASISTENTES, Y UBICACION la insersión se hace mediante los archivos adjuntos csv y que tienen el mismo nombre, la carga debe hacerse en orden.
-------------------------------------------------------------------------------------------------------*/

SELECT @@GLOBAL.secure_file_priv;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ACTIVIDADES.csv'
INTO TABLE ACTIVIDADES
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 rows
(id_actividad,nombre,tipo,costo);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/UBICACION.csv'
INTO TABLE UBICACION
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 rows
(id_ubicacion,nombre,direccion,ciudad,caracteristicas,precio,aforo);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ARTISTAS.csv'
INTO TABLE ARTISTAS
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 rows
(id_artista,nombre,biografia);

INSERT INTO EVENTO (nombre, descripcion, fecha, hora, precio, id_actividad, id_ubicacion) VALUES
("Evento 1", "N.A", "2024-10-10", "08:00:00", 10.00, 2, 1),
("Evento 2", "N.A", "2024-10-11", "08:00:00", 20.00, 3, 4),
("Evento 3", "N.A", "2024-10-12", "08:00:00", 35.00, 5, 5),
("Evento 4", "N.A", "2024-10-13", "08:00:00", 46.00, 6, 3),
("Evento 5", "N.A", "2024-10-14", "08:00:00", 32.00, 4, 2),
("Evento 6", "N.A", "2024-10-15", "08:00:00", 12.00, 1, 5),
("Evento 7", "N.A", "2024-10-16", "08:00:00", 9.00, 7, 1);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ASISTENTES.csv'
INTO TABLE ASISTENTES
CHARACTER SET latin1
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 rows
(id_asistente,nombre,telefonos,email);

INSERT INTO PARTICIPAN VALUES 
(1,1,500),
(1,7,500),
(1,4,100),
(1,2,234),
(1,3,344),
(2,3,566),
(2,4,900),
(2,2,100),
(2,7,50),
(3,4,30),
(3,2,234),
(4,1,233),
(4,3,203),
(5,4,203),
(5,5,203),
(5,3,100),
(6,4,100),
(6,6,50),
(7,7,20),
(7,6,10),
(8,7,54);

INSERT INTO ASISTE VALUES 
(1,1,4.1),
(1,2,1.7),
(1,3,3.3),
(1,4,2.4),
(1,5,2.0),
(1,6,4.3),
(1,7,4.8),
(1,8,4.3),
(1,9,4.9),
(1,10,4.4),
(1,11,2.3),
(1,12,4.5),
(1,13,4.1),
(1,14,3.8),
(2,15,4.7),
(2,16,4.1),
(2,17,3.2),
(2,18,4.1),
(2,19,3.3),
(2,20,3.5),
(2,1,4.0),
(2,2,1.7),
(2,3,2.7),
(2,4,1.8),
(2,5,4.9),
(2,6,1.2),
(2,7,4.0),
(2,8,3.9),
(3,9,3.6),
(3,10,4.6),
(3,11,4.4),
(3,12,4.4),
(3,13,3.2),
(3,14,4.2),
(3,15,3.2),
(3,16,3.6),
(3,17,4.0),
(3,18,1.8),
(3,19,2.5),
(3,20,1.4),
(3,1,4.6),
(3,2,4.8),
(3,3,4.2),
(4,4,4.4),
(4,5,3.5),
(4,6,4.0),
(4,7,4.0),
(4,8,3.2),
(4,9,3.9),
(4,10,3.3),
(4,11,3.8),
(4,12,3.5),
(4,13,4.4),
(4,14,3.0),
(4,15,4.6),
(4,16,3.1),
(4,17,3.5),
(5,18,3.4),
(5,19,4.4),
(5,20,4.2),
(5,1,3.1),
(5,2,4.9),
(5,3,3.9),
(5,4,1.8),
(5,5,4.3),
(5,6,4.5),
(5,7,3.4),
(5,8,4.9),
(5,9,4.0),
(5,10,4.6),
(6,11,4.8),
(6,12,4.5),
(6,13,3.2),
(6,14,3.9),
(6,15,2.6),
(6,16,2.6),
(6,17,1.1),
(6,18,3.7),
(6,19,3.7),
(6,20,2.8),
(6,1,3.7),
(6,2,1.8),
(6,3,3.8),
(7,4,1.6),
(7,5,3.0),
(7,6,3.7),
(7,7,5.0),
(7,8,1.8),
(7,9,3.8),
(7,10,4.3),
(7,11,3.5),
(7,12,3.7),
(7,13,3.4),
(7,14,4.6),
(7,15,3.7),
(7,16,4.9),
(7,17,2.8),
(7,18,3.6),
(7,19,4.0),
(7,20,3.2);

/*------------------------------------------------------------------------------------------------------
Consultas
-------------------------------------------------------------------------------------------------------*/

-- 1. Lista de eventos con su ubicación ordenando los resultados primero por ciudad y luego por el precio del evento de mayor a menor, para ver que ciudades han generado mas ingresos.

SELECT E.nombre AS evento, U.nombre AS ubicacion, U.ciudad, E.precio 
FROM EVENTO E
JOIN UBICACION U ON E.id_ubicacion = U.id_ubicacion
ORDER BY U.ciudad, E.precio DESC;

-- 2. Cuenta las actividades por su tipo y da el costo total por cada grupo

SELECT tipo, COUNT(*) AS cantidad_actividades, SUM(costo) AS costo_total 
FROM ACTIVIDADES 
GROUP BY tipo;

-- 3. Numero total de asistentes por Evento y calificación promedio recibida en cada uno.

SELECT E.nombre AS evento, COUNT(A.id_asistente) AS total_asistentes, AVG(A.calificacion) AS promedio_calificacion
FROM EVENTO E
JOIN ASISTE A ON E.id_evento = A.id_evento
GROUP BY E.nombre;

-- 4. Artistas que participan en actividades que el costo es mayor al costo promedio de todas las actividades

SELECT AR.nombre AS artista, A.nombre AS actividad, A.costo 
FROM ARTISTAS AR
JOIN PARTICIPAN P ON AR.id_artista = P.id_artista
JOIN ACTIVIDADES A ON P.id_actividad = A.id_actividad
WHERE A.costo > (SELECT AVG(costo) FROM ACTIVIDADES);

-- 5. Lista de eventos en ciudades que tienen varias ubicaciones 

SELECT E.nombre AS evento, U.ciudad 
FROM EVENTO E
JOIN UBICACION U ON E.id_ubicacion = U.id_ubicacion
WHERE U.ciudad IN (
    SELECT ciudad 
    FROM UBICACION 
    GROUP BY ciudad 
    HAVING COUNT(*) > 1
);

-- 6. Eventos que se realizan en ubicaciones donde el aforo es mayor al aforo promedio de todas las ubicaciones, es decir, a los eventos que mas asisten personas.

SELECT E.nombre AS evento, U.nombre AS ubicacion, U.aforo 
FROM EVENTO E
JOIN UBICACION U ON E.id_ubicacion = U.id_ubicacion
WHERE U.aforo > (SELECT AVG(aforo) FROM UBICACION);

-- 7. Agrupa las actividades y suma el caché pagado a todos los artistas que participan en cada una para revisar el costo total de los artistas.

SELECT A.nombre AS actividad, SUM(P.cache) AS total_cache
FROM ACTIVIDADES A
JOIN PARTICIPAN P ON A.id_actividad = P.id_actividad
GROUP BY A.nombre;

-- 8.  Asistentes que han ido a eventos cuyo precio es superior al precio promedio de todos los eventos, es deicr, lo que mas han pagado

SELECT ASIS.nombre AS asistente, E.nombre AS evento, E.precio 
FROM ASISTENTES ASIS
JOIN ASISTE A ON ASIS.id_asistente = A.id_asistente
JOIN EVENTO E ON A.id_evento = E.id_evento
WHERE E.precio > (SELECT AVG(precio) FROM EVENTO);

-- 9. Numero de artistas involucrados en cada evento.

SELECT E.nombre AS evento, COUNT(DISTINCT P.id_artista) AS total_artistas
FROM EVENTO E
JOIN ACTIVIDADES A ON E.id_actividad = A.id_actividad
JOIN PARTICIPAN P ON A.id_actividad = P.id_actividad
GROUP BY E.nombre;

-- 10. Conocer las ubicaciones donde se han realizado mas de ciertos eventos, en este caso 2.

SELECT U.nombre AS ubicacion, COUNT(E.id_evento) AS total_eventos 
FROM UBICACION U
JOIN EVENTO E ON U.id_ubicacion = E.id_ubicacion
GROUP BY U.nombre
HAVING COUNT(E.id_evento) > 2;

/*------------------------------------------------------------------------------------------------------
Vista para Calcular las Ganancias Totales de la Empresa
-------------------------------------------------------------------------------------------------------*/

CREATE VIEW ganancias AS

SELECT 
    E.id_evento,
    E.nombre AS evento,
    E.precio AS precio_evento,
    U.precio AS precio_ubicacion,
    A.costo AS costo_actividad,
    (E.precio * COUNT(DISTINCT ASI.id_asistente)) AS ingresos_totales, -- Ingresos: Precio del evento * número de asistentes
    
    (U.precio + A.costo + 
        (SELECT SUM(P.cache)
         FROM PARTICIPAN P
         WHERE P.id_actividad = E.id_actividad)
    ) AS gastos_totales, -- Gastos: Precio de la ubicación + Caché total de artistas + Costo de la actividad
    
    ((E.precio * COUNT(DISTINCT ASI.id_asistente)) - 
     (U.precio + A.costo + 
        (SELECT SUM(P.cache)
         FROM PARTICIPAN P
         WHERE P.id_actividad = E.id_actividad)
    )) AS ganancia_total  -- Ganancia: Ingresos - Gastos
    
FROM EVENTO E
JOIN UBICACION U ON E.id_ubicacion = U.id_ubicacion
JOIN ACTIVIDADES A ON E.id_actividad = A.id_actividad
LEFT JOIN ASISTE ASI ON E.id_evento = ASI.id_evento

GROUP BY E.id_evento;
