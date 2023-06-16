INSERT INTO obra_social (nro_obra_social, nombre, contacto_nombre, contacto_apellido, contacto_telefono, contacto_email)
VALUES
  (1234, 'Osde', 'Hector', 'Bracamonte', '541134567890', 'hec.bra@gmail.com'),
  (5678, 'Omint', 'Nicolas', 'Burdisso', '541145678901', 'nico.burdisso@gmail.com'),
  (9012, 'MEDICUS', 'Joel', 'Barbosa', '541156789012', 'joel.barbossa@gmail.com'),
  (3456, 'Prevención Salud', 'Jose', 'Calvo', '541167890123', 'jose.c@gmail.com'),
  (7890, 'GALENO', 'Clemente', 'Rodriguez', '541178901234', 'clemente.rodriguez@gmail.com');



INSERT INTO paciente (nro_paciente, nombre, apellido, dni_paciente, f_nac, nro_obra_social, nro_afiliade, domicilio, telefono, email)
VALUES
  (1, 'Juan', 'Perez', 30234567, '1990-01-01', 1234, 9230, 'Av. Corrientes 1234, Buenos Aires', '541134567890', 'juan.perez@gmail.com'),
  (2, 'Maria', 'Gomez', 30804567, '1992-02-02', 5678, 9525, 'Calle Florida 567, Cordoba', '541145678901', 'maria.gomez@gmail.com'),
  (3, 'Carlos', 'Lopez', 28345678, '1985-03-03', 9012, 1654, 'Av. Rivadavia 789, Rosario', '541156789012', 'carlos.lopez@gmail.com'),
  (4, 'Laura', 'Rodriguez', 29456789, '1988-04-04', 3456, 1843, 'Calle San Martin 123, Mendoza', '541167890123', 'laura.rodriguez@gmail.com'),
  (5, 'Ana', 'Torres', 33567890, '1994-05-05', 7890, 4325, 'Av. Pueyrredon 5678, Mar del Plata', '541178901234', 'ana.torres@gmail.com'),
  (6, 'Pedro', 'Hernandez', 37678901, '1996-06-06', 1234, 7829, 'Calle Lavalle 901, La Plata', '541189012345', 'pedro.hernandez@gmail.com'),
  (7, 'Sofia', 'Garcia', 31789012, '1991-07-07', 5678, 7819, 'Av. Callao 2345, Salta', '541190123456', 'sofia.garcia@gmail.com'),
  (8, 'Luis', 'Martinez', 29345678, '1987-08-08', 9012, 9813, 'Calle Alem 6789, Tucuman', '541101234567', 'luis.martinez@gmail.com'),
  (9, 'Carolina', 'Vargas', 31356789, '1993-09-09', 3456, 1823, 'Av. Santa Fe 9012, Bahia Blanca', '541190123456', 'carolina.vargas@gmail.com'),
  (10, 'Miguel', 'Fernandez', 29945678, '1989-10-10', 7890, 8912, 'Calle Cordoba 3456, Neuquen', '541112345678', 'miguel.fernandez@gmail.com'),
  (11, 'Paola', 'Suarez', 38456789, '1997-11-11', 1234, 2011, 'Av. Mayo 7890, San Juan', '541123456789', 'paola.suarez@gmail.com'),
  (12, 'Roberto', 'Lopez', 30345678, '1990-12-12', 5678, 2291, 'Calle Belgrano 123, Santa Fe', '541134567890', 'roberto.lopez@gmail.com'),
  (13, 'Florencia', 'Gomez', 28845678, '1986-01-13', 9012, 4413, 'Av. San Martin 567, Resistencia', '541145678901', 'florencia.gomez@gmail.com'),
  (14, 'Javier', 'Perez', 26307890, '1983-02-14', 3456, 9210, 'Calle Sarmiento 789, Posadas', '541156789012', 'javier.perez@gmail.com'),
  (15, 'Andrea', 'Rodriguez', 36278901, '1995-03-15', 7890, 9316, 'Av. Entre Rios 5678, Jujuy', '541167890123', 'andrea.rodriguez@gmail.com'),
  (16, 'Lucas', 'Torres', 27345678, '1984-04-16', 1234, 0915, 'Calle Uruguay 901, Santiago del Estero', '541178901234', 'lucas.torres@gmail.com'),
  (17, 'Valentina', 'Hernandez', 38906789, '1998-05-17', 5678, 7239, 'Av. Cerrito 2345, Corrientes', '541189012345', 'valentina.hernandez@gmail.com'),
  (18, 'Gustavo', 'Garcia', 26189012, '1982-06-18', 9012, 3385, 'Calle Lavalleja 6789, San Salvador de Jujuy', '541190123456', 'gustavo.garcia@gmail.com'),
  (19, 'Marcela', 'Martinez', 39956789, '1999-07-19', 3456, 8140, 'Av. Scalabrini Ortiz 9012, La Rioja', '541101234567', 'marcela.martinez@gmail.com'),
  (20, 'Rocio', 'Vargas', 25907890, '1981-08-20', 7890, 8154, 'Calle Thames 3456, San Miguel de Tucuman', '541112345678', 'rocio.vargas@gmail.com');


	  


INSERT INTO medique (dni_medique, nombre, apellido, especialidad, monto_consulta_privada, telefono)
VALUES
  (31284541, 'Mariana', 'Lopez', 'Pediatria', 200.00, '541134567890'),
  (28672143, 'Carlos', 'Gonzalez', 'Cardiologia', 300.00, '541145678901'),
  (27565033, 'Laura', 'Martinez', 'Dermatologia', 250.00, '541156789012'),
  (29723628, 'Pedro', 'Fernandez', 'Oftalmologia', 280.00, '541167890123'),
  (31562721, 'Ana', 'Rodriguez', 'Ginecologia', 320.00, '541178901234'),
  (26921011, 'Javier', 'Gomez', 'Neurologia', 270.00, '541189012345'),
  (27361821, 'Sofia', 'Perez', 'Psicologia', 230.00, '541190123456'),
  (30173812, 'Luis', 'Torres', 'Traumatologia', 290.00, '541101234567'),
  (31008123, 'Maria', 'Hernandez', 'Otorrinolaringologia', 260.00, '541112345678'),
  (32639129, 'Carlos', 'Lopez', 'Endocrinologia', 310.00, '541123456789'),
  (27983210, 'Gabriela', 'Lopez', 'Dermatologia', 250.00, '541134567891'),
  (30187100, 'Andres', 'Gonzalez', 'Oftalmologia', 280.00, '541145678902'),
  (31028012, 'Carolina', 'Martinez', 'Pediatria', 200.00, '541156789013'),
  (25829101, 'Juan', 'Fernandez', 'Cardiologia', 300.00, '541167890124'),
  (29840133, 'Marcelo', 'Rodriguez', 'Neurologia', 270.00, '541178901235'),
  (32872012, 'Valeria', 'Gomez', 'Ginecologia', 320.00, '541189012346'),
  (30571234, 'Pablo', 'Perez', 'Psicologia', 230.00, '541190123457'),
  (28001321, 'Lucia', 'Torres', 'Traumatologia', 290.00, '541101234568'),
  (32483291, 'Federico', 'Hernandez', 'Endocrinologia', 310.00, '541112345679'),
  (27991021, 'Carla', 'Lopez', 'Otorrinolaringologia', 260.00, '541123456780');


INSERT INTO cobertura(dni_medique, nro_obra_social, monto_paciente, monto_obra_social) 
VALUES 
  (31284541, 1234, 90.00, 110.00),
  (28672143, 5678, 170.00, 130.00),
  (27565033, 9012, 50.00, 200.00), 
  (29723628, 3456, 200.00, 80.00),
  (31562721, 7890, 00.00, 320.00),
  (26921011, 1234, 100.00, 170.00),
  (27361821, 5678, 230.00, 00.00),
  (30173812, 9012, 200.00, 90.00),
  (31008123, 3456, 150.00, 110.00),
  (32639129, 7890, 210.00, 100.00),
  (27983210, 1234, 250.00, 00.00),
  (30187100, 5678, 00.00, 280.00),
  (31028012, 9012, 190.00, 10.00),
  (25829101, 3456, 300.00, 00.00),
  (29840133, 7890, 225.00, 45.00),
  (32872012, 1234, 20.00, 300.00),
  (30571234, 5678, 230.00, 00.00), 
  (28001321, 9012, 185.00, 105.00),
  (32483291, 3456, 230.00, 80.00),
  (27991021, 7890, 160.00, 100.00);

INSERT INTO agenda (dni_medique, dia, nro_consultorio, hora_desde, hora_hasta, duracion_turno)
	VALUES
	(31284541, 4, 1, '09:00:00', '13:00:00', '00:20:00'),
	(31284541, 3, 1, '14:00:00', '18:00:00', '00:15:00'), 
	(28672143, 3, 2, '10:00:00', '14:00:00', '00:20:00'),
	(28672143, 5, 2, '10:00:00', '14:00:00', '00:30:00'), 
	(27565033, 3, 3, '08:00:00', '12:00:00', '00:30:00'),
	(27565033, 4, 3, '08:00:00', '12:00:00', '00:20:00'), 
	(29723628, 4, 4, '10:00:00', '14:00:00', '00:20:00'),
	(31562721, 3, 5, '11:00:00', '15:00:00', '00:15:00'),
	(26921011, 1, 6, '14:00:00', '18:00:00', '00:30:00'),
	(27361821, 4, 7, '10:00:00', '14:00:00', '01:00:00'),
	(30173812, 2, 8, '11:00:00', '15:00:00', '00:15:00'),
	(31008123, 5, 9, '14:00:00', '18:00:00', '00:20:00'),
	(32639129, 1, 4, '09:00:00', '13:00:00', '00:30:00'),
	(27983210, 3, 1, '10:00:00', '14:00:00', '00:30:00'),
	(30187100, 6, 2, '14:00:00', '18:00:00', '00:20:00'),
	(31028012, 2, 3, '09:00:00', '13:00:00', '00:20:00'),
	(25829101, 5, 4, '10:00:00', '14:00:00', '00:15:00'),
	(29840133, 1, 5, '11:00:00', '15:00:00', '00:20:00'),
	(32872012, 4, 6, '14:00:00', '18:00:00', '00:30:00'),
	(30571234, 6, 7, '09:00:00', '13:00:00', '01:00:00'),
	(28001321, 5, 8, '11:00:00', '15:00:00', '00:20:00'),
	(32483291, 1, 9, '14:00:00', '18:00:00', '00:30:00'),
	(27991021, 4, 10, '09:00:00', '13:00:00','00:20:00');


INSERT INTO consultorio (nro_consultorio, nombre, domicilio, codigo_postal, telefono) 
VALUES
(1, 'Consultorio Médico Argentino', 'Av. Corrientes 123, Buenos Aires', '12345678', '541123456789'),
(2, 'Consultorio Odontológico del Sur', 'Calle Mitre 456, Córdoba', '54321098', '541123456791'),
(3, 'Clínica Salud Integral', 'Av. Belgrano 789, Rosario', '98765432', '541123456792'),
(4, 'Consultorio Cardiológico Norte', 'Av. San Martín 789, Mendoza', '56789012', '541123456793'),
(5, 'Consultorio Ginecológico Este', 'Calle Rivadavia 321, Mar del Plata', '21098765', '541123456794'),
(6, 'Clínica Oftalmológica Oeste', 'Av. Sarmiento 456, Salta', '87654321', '541123456795'),
(7, 'Consultorio Psicológico Central', 'Calle Pellegrini 654, La Plata', '10987654', '541123456796'),
(8, 'Consultorio Dermatológico Sur', 'Av. Colón 987, Bahía Blanca', '43210987', '541123456797'),
(9, 'Clínica Ortopédica Noroeste', 'Calle Alvear 654, Tucumán', '76543210', '541123456798'),
(10, 'Consultorio Pediatría Este', 'Av. Independencia 321, Neuquén', '21098765', '541123456799');


 INSERT INTO solicitud_reservas(nro_paciente, dni_medique, fecha, hora)
 VALUES
  (1, 31284541, '2023-06-01', '09:00:00'), --reserva el turno
  (1, 31284541, '2023-06-15', '09:00:00'), --reservo y despues cancelo de turno
  (2, 28672143, '2023-06-14', '10:00:00'), --trigger 2 dias despues
  (2, 28672143, '2023-06-16', '10:00:00'), --trigger 2 dias despues
  (1, 31284541, '2023-06-01', '14:00:00'), --error turno inexistente hora no atiende
  (1, 31284541, '2023-06-02', '14:00:00'), --error turno inexistente dia no atiende
  (1, 31284541, '2023-07-06', '14:00:00'), --error turno no existe
  (2, 31284541, '2023-06-15', '09:00:00'), --error obra social no atendida por medico
  (130, 31284541, '2023-06-15', '09:00:00'), --error numero historia clinica no valido
  (3, 27565033, '2023-06-21', '08:00:00'),
  (3, 27565033, '2023-06-21', '09:00:00'),
  (3, 27565033, '2023-06-21', '10:00:00'),
  (3, 27565033, '2023-06-21', '11:00:00'),
  (3, 27565033, '2023-06-22', '08:00:00'),
  (3, 27565033, '2023-06-22', '09:00:00'), --supera cantidad de turnos
  (1, 31284541, '2023-06-15', '09:00:00'), --reservado y atendido

  (12, 27361821, '2023-06-15', '13:00:00'), --atendidos para liquidacion
  (11, 32872012, '2023-06-15', '15:00:00'),
  (16, 31284541, '2023-06-15', '12:00:00'),
  (5, 27991021, '2023-06-15', '09:00:00'),
  (15, 27991021, '2023-06-15', '10:00:00'),
  (20, 27991021, '2023-06-15', '11:00:00'),
  (4, 29723628, '2023-06-15', '10:00:00');