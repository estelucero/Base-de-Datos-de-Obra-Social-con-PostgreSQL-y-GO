CREATE TABLE paciente (
		nro_paciente INT,
		nombre TEXT,
		apellido TEXT,
		dni_paciente INT,
		f_nac DATE,
		nro_obra_social INT,
		nro_afiliade INT,
		domicilio TEXT,
		telefono CHAR(12),
		email TEXT
	  );

CREATE TABLE medique (
		dni_medique INT,
		nombre TEXT,
		apellido TEXT,
		especialidad VARCHAR(64),
		monto_consulta_privada DECIMAL(12,2),
		telefono CHAR(12)
	  );

CREATE TABLE consultorio(
		nro_consultorio INT,
		nombre TEXT,
		domicilio TEXT,
		codigo_postal CHAR(8),
		telefono CHAR(12)
		);



CREATE TABLE agenda(
		dni_medique int,
		dia int,
		nro_consultorio int,
		hora_desde time,
		hora_hasta time,
		duracion_turno interval
		);

CREATE TABLE turno(
		nro_turno SERIAL,
		fecha timestamp,
		nro_consultorio int,
		dni_medique int,
		nro_paciente int,
		nro_obra_social_consulta int,
		nro_afiliade_consulta int,
		monto_paciente decimal(12,2),
		monto_obra_social decimal(12,2),
		f_reserva timestamp,
		estado char(10) 
		);

CREATE TABLE reprogramacion(
		nro_turno int,
		nombre_paciente text,
		apellido_paciente text,
		telefono_paciente char(12),
		email_paciente text,
		nombre_medique text,
		apellido_medique text,
		estado char(12) 
		);     

CREATE TABLE error(
		nro_error SERIAL,
		f_turno timestamp,
		nro_consultorio int,
		dni_medique int,
		nro_paciente int,
		operacion char(12), --reserva,cancelación, atención, liquidación 
		f_error timestamp,
		motivo varchar(64)
		);

CREATE TABLE cobertura(
		dni_medique int,
		nro_obra_social int,
		monto_paciente decimal(12,2), --monto a abonar por el paciente
		monto_obra_social decimal(12,2) --monto a liquidar a la obra social
		);


CREATE TABLE obra_social (
		nro_obra_social int,
		nombre text,
		contacto_nombre text,
		contacto_apellido text,
		contacto_telefono char(12),
		contacto_email text
	);

CREATE TABLE liquidacion_cabecera(
			nro_liquidacion SERIAL,
			nro_obra_social int,
			desde date,
			hasta date,
			total decimal(15,2)
			);

CREATE TABLE liquidacion_detalle(
			nro_liquidacion int,
			nro_linea int,
			f_atencion date,
			nro_afiliade int,
			dni_paciente int,
			nombre_paciente text,
			apellido_paciente text,
			dni_medique int,
			nombre_medique text,
			apellido_medique text,
			especialidad varchar(64),
			monto decimal(12,2)
			);

CREATE TABLE envio_email(
			nro_email SERIAL,
			f_generacion timestamp,
			email_paciente text,
			asunto text,
			cuerpo text,
			f_envio timestamp,
			estado char(10) --pendiente, enviado
			);

CREATE TABLE solicitud_reservas(
			nro_orden SERIAL, --en qué orden se ejecutarán las reservas
			nro_paciente int,
			dni_medique int,
			fecha date,
			hora time
			);



--Creacion de clave primaria  para paciente
ALTER TABLE paciente ADD CONSTRAINT paciente_pk PRIMARY KEY (nro_paciente);

--Creacion de clave primaria para medique
ALTER TABLE medique ADD CONSTRAINT medique_pk PRIMARY KEY (dni_medique);

--Creacion de clave primaria para consultorio
ALTER TABLE consultorio ADD CONSTRAINT consultorio_pk PRIMARY KEY (nro_consultorio);

--Creacion de clave primaria para agenda
ALTER TABLE agenda ADD CONSTRAINT agenda_pk PRIMARY KEY (dni_medique,dia);

--Creacion de clave primaria para turno
ALTER TABLE turno ADD CONSTRAINT turno_pk PRIMARY KEY (nro_turno);

--Creacion de clave primaria para error
ALTER TABLE error ADD CONSTRAINT error_pk PRIMARY KEY (nro_error);

--Creacion de clave primaria para cobertura
ALTER TABLE cobertura ADD CONSTRAINT cobertura_pk PRIMARY KEY (dni_medique,nro_obra_social);

--Creacion de clave primaria para obra_social
ALTER TABLE obra_social ADD CONSTRAINT obra_social_pk PRIMARY KEY (nro_obra_social);

--Creacion de clave primaria para liquidacion_cabecera
ALTER TABLE liquidacion_cabecera ADD CONSTRAINT liquidacion_cabecera_pk PRIMARY KEY (nro_liquidacion);

--Creacion de clave primaria para liquidacion_detalle
ALTER TABLE liquidacion_detalle ADD CONSTRAINT liquidacion_detalle_pk PRIMARY KEY (nro_liquidacion,nro_linea);

--Creacion de clave primaria para envio_email
ALTER TABLE envio_email ADD CONSTRAINT envio_email_pk PRIMARY KEY (nro_email);


--Creacion de claves Foraneas(FK)

-- --Creacion clave foranea paciente
ALTER TABLE paciente ADD CONSTRAINT paciente_nro_obra_social_fk FOREIGN KEY (nro_obra_social) REFERENCES obra_social (nro_obra_social);

--Creacion clave foranea agenda
ALTER TABLE agenda ADD CONSTRAINT agenda_dni_medique_fk FOREIGN KEY (dni_medique) REFERENCES medique (dni_medique);

-- --Creacion clave foranea turno
-- --Agrego la de nro_consultorio
ALTER TABLE turno ADD CONSTRAINT turno_nro_consultorio_fk FOREIGN KEY (nro_consultorio) REFERENCES consultorio (nro_consultorio);

-- --Agrego la de dni_medique
ALTER TABLE turno ADD CONSTRAINT turno_dni_medique_fk FOREIGN KEY (dni_medique) REFERENCES medique (dni_medique);

-- --Agrego la de paciente
ALTER TABLE turno ADD CONSTRAINT turno_nro_paciente_fk FOREIGN KEY (nro_paciente) REFERENCES paciente (nro_paciente);

-- --Creacion clave foranea error
-- --Creo la de nro_consultorio
ALTER TABLE error ADD CONSTRAINT error_nro_consultorio_fk FOREIGN KEY (nro_consultorio) REFERENCES consultorio (nro_consultorio);

--Agrego la de dni_medique
ALTER TABLE error ADD CONSTRAINT error_dni_medique_fk FOREIGN KEY (dni_medique) REFERENCES medique (dni_medique);

--Agrego la de paciente
ALTER TABLE error ADD CONSTRAINT error_nro_paciente_fk FOREIGN KEY (nro_paciente) REFERENCES paciente (nro_paciente);

-- --Creacion clave foranea cobertura
-- --Agrego la de dni_medique
ALTER TABLE cobertura ADD CONSTRAINT cobertura_dni_medique_fk FOREIGN KEY (dni_medique) REFERENCES medique (dni_medique);

-- --Agrego la de nro_obra_social
ALTER TABLE cobertura ADD CONSTRAINT cobertura_nro_obra_social_fk FOREIGN KEY (nro_obra_social) REFERENCES obra_social (nro_obra_social);

-- --Creacion de clave foranea liquidacion_cabecera
ALTER TABLE liquidacion_cabecera ADD CONSTRAINT  liquidacion_cabecera_nro_obra_social_fk FOREIGN KEY (nro_obra_social) REFERENCES obra_social (nro_obra_social);

-- --Creacion de clave foranea liquidacion_detalle
-- --Agrego la de dni_medique
ALTER TABLE liquidacion_detalle ADD CONSTRAINT liquidacion_detalle_dni_medique_fk FOREIGN KEY (dni_medique) REFERENCES medique (dni_medique);

-- --Creacion de clave foranea solicitud_reservas
-- --Agrego la de dni_medique
-- ALTER TABLE solicitud_reservas ADD CONSTRAINT solicitud_reservas_dni_medique_fk FOREIGN KEY (dni_medique) REFERENCES medique (dni_medique);

-- -- --Agrego la de paciente
-- ALTER TABLE solicitud_reservas ADD CONSTRAINT solicitud_reservas_paciente_fk FOREIGN KEY (nro_paciente) REFERENCES paciente (nro_paciente);