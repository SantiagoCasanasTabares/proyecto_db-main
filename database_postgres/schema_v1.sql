-- Database: mande_db

-- DROP DATABASE mande_db;

CREATE EXTENSION postgis;

CREATE DATABASE mande_db
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    TEMPLATE template0;

\c mande_db


CREATE TABLE Labor(
    labor_id INT PRIMARY KEY,
    labor_nombre VARCHAR(30) NOT NULL,
);

CREATE TABLE Ubicacion(
	ubica_latitud 			DECIMAL(8, 6),
	ubica_longitud 		    DECIMAL(8,6),
	ubica_ubicacion 		GEOGRAPHY(POINT,4686) 	NOT NULL,
	ubica_ciudad 			VARCHAR(45) 			NOT NULL,
    ubica_departamento      VARCHAR (45)            NOT NULL,
	ubica_direccion 		VARCHAR (45) 			NOT NULL,
	CONSTRAINT pk_punto_geografico PRIMARY KEY (ubica_latitud,ubica_longitud)
);

CREATE TABLE Persona(
    persona_id INT PRIMARY KEY,
    persona_nombre VARCHAR(45),
    persona_apellido VARCHAR(45),
    persona_email VARCHAR(45),
    persona_password VARCHAR(45),
    persona_celular VARCHAR(15),
    ubica_longitud DECIMAL(8,6),
    ubica_latitud DECIMAL(8,6),
    CONSTRAINT fk_ubicacion_persona
      FOREIGN KEY(ubica_longitud, ubica_latitud)
        REFERENCES Ubicacion(ubica_longitud, ubica_latitud) ON UPDATE CASCADE ON DELETE RESTRICT
);
   
CREATE TABLE Cliente(
    cliente_celular VARCHAR(15),
    cliente_recibo VARBINARY(5),
    CONSTRAINT pk_cliente PRIMARY KEY(cliente_celular),
    CONSTRAINT fk_cliente FOREIGN KEY(cliente_celular) 
      REFERENCES Persona(persona_celular)   
);

CREATE TABLE Trabajador(
	trabajador_id		     INT,
	trabajador_estado        BOOLEAN,
    trabajador_foto_id       VARBINARY(5),
    trabajador_foto_perfil   VARBINARY(5),
	CONSTRAINT pk_trabajador PRIMARY KEY (trabajador_id),
    CONSTRAINT fk_trabajador FOREIGN KEY(trabajador_id) 
      REFERENCES Persona(persona_id)
);
CREATE INDEX idx_trab_ocup ON Trabajador USING HASH (trabajador_ocupado);

CREATE TABLE Trabajador_Has_Labor(
	trabajador_id	VARCHAR(20),
	labor_id 				INT,
	t_h_l_precio 			INT 		 	NOT NULL,
	t_h_l_prom 				VARCHAR(20) 	DEFAULT 'Horas',
	CONSTRAINT pk_t_r_l PRIMARY KEY (trabajador_id, labor_id),
	CONSTRAINT fk_t_r_l1 FOREIGN KEY (trabajador_id) 
		REFERENCES Trabajador(trabajador_id) ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT fk_t_r_l2 FOREIGN KEY (labor_id) 
		REFERENCES Labor(labor_id) ON UPDATE CASCADE ON DELETE RESTRICT
);


CREATE TABLE Servicio(
	servicio_id 			INT PRIMARY KEY,
	servicio_costo 			INT,
	servicio_calificacion 	SMALLINT,
	servicio_descripcion 	VARCHAR(200) 	NOT NULL,
	servicio_fecha_inicio 	VARCHAR(25),
	servicio_fecha_fin 		VARCHAR(25),
    usuario_celular 		VARCHAR(20) 	NOT NULL,
	trabajador_documento 	VARCHAR(20) 	NOT NULL,
	labor_id 				INT 			NOT NULL,
	CONSTRAINT fk_servicio1 FOREIGN KEY (trabajador_documento,labor_id) 
		REFERENCES Trabajador_Has_Labor(trabajador_documento,labor_id) ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT fk_servicio2 FOREIGN KEY (usuario_celular) 
		REFERENCES Cliente(usuario_celular) ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE INDEX idx_trab_doc ON Servicio USING HASH (trabajador_documento);
CREATE INDEX idx_usu_cel ON Servicio USING HASH (usuario_celular);

CREATE TABLE Pago(
    id_servicio INT,
    id_usuario VARCHAR(15),
    id_trabajador INT,
    num_tarjeta_usuario VARCHAR(45),
    cvc VARCHAR(3),
    CONSTRAINT fk_pago1 FOREIGN KEY (id_servicio)
      REFERENCES Servicio(servicio_id),
    CONSTRAINT fk_pago2 FOREIGN KEY (id_usuario)
      REFERENCES Cliente(cliente_celular),
    CONSTRAINT fk_pago3 FOREIGN KEY (id_trabajador)
      REFERENCES Trabajador(trabajador_id),
);
-- ************************LABORES DEFINIDAS**********************************

INSERT INTO Labor (labor_nombre, labor_descripcion) VALUES
('Plomero/a'),
('Cerrajero/a'),
('Pintor/a'),
('Profesor de ingles'),
('Mesero/a'),
('Chef'),
('Niñero/a'),
('Paseador/a de mascotas'),
('Empleado/a doméstico/a'),
('Conductor/a');

-- Procedimientos 

CREATE FUNCTION nuevo_trabajador(documento INT,  foto_doc VARBINARY, nombre VARCHAR, apellido VARCHAR, fotoperfil VARBINARY, pass VARCHAR) RETURNS void AS $$
BEGIN
INSERT INTO Persona(persona_id,persona_nombre, persona_apellido, persona_password)
VALUES (documento, nombre,apellido,pass);
INSERT INTO Trabajador( trabajador_foto_id,trabajador_foto_perfil)
VALUES (foto_doc,fotoperfil);
END;
$$
LANGUAGE plpgsql;
