create function generacion_turnos_disponibles(anio int, mes int) returns boolean as $$
declare
    fila_agenda agenda%rowtype;
    dia int;
    fecha_pasada timestamp;
    hora time;
    existe int;
    dia_actual date;
    dia_final date;
begin
    dia_actual := to_date(anio||'-'||mes||'-01', 'YYYY-MM-DD');
    dia_final := (dia_actual + interval '1 month') - interval '1 day';

    for fila_agenda in select * from agenda loop
       	 dia:= fila_agenda.dia;

		while dia_actual <= dia_final loop
            if EXTRACT(dow from dia_actual)::int = dia then
                hora := fila_agenda.hora_desde;   
                while hora < fila_agenda.hora_hasta loop
                    fecha_pasada := dia_actual + hora;
                    select 1 into existe from turno where turno.fecha = fecha_pasada and turno.dni_medique = fila_agenda.dni_medique;
                    if 1 = existe then
                        return false;
                    end if; 
                
                    INSERT INTO turno (
                        fecha, 
                        nro_consultorio, 
                        dni_medique, 
                        nro_paciente, 
                        nro_obra_social_consulta, 
                        nro_afiliade_consulta,     
                        monto_paciente, 
                        monto_obra_social, 
                        f_reserva, 
                        estado
                    )
                    VALUES(
                        fecha_pasada,
                        fila_agenda.nro_consultorio,
                        fila_agenda.dni_medique,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        'disponible'    
                    );
                    hora := hora + fila_agenda.duracion_turno;
                end loop;
            end if;
            dia_actual := dia_actual + interval '1 day';
        end loop;
		dia_actual := to_date(anio||'-'||mes||'-01', 'YYYY-MM-DD');
    end loop;
return true;
end;
$$ language plpgsql;


create or replace function reserva_turno(nro_historia_clinica_param int, dni_medique_param int, fecha_param date, hora_param time) 
returns boolean as $$
declare
	existe int;
	turno_reserva int;
	numero_obra int;
	fechayhora timestamp;
	numero_consultorio_dato int;
begin
	fechayhora := to_timestamp(fecha_param ||' '||hora_param, 'yyyy-mm-dd hh24:mi:ss')::timestamp without time zone ;

	
	select nro_consultorio into numero_consultorio_dato from turno where fecha = fechayhora and turno.dni_medique = dni_medique_param;
	--Verificamos que existe el medico
	select 1 into existe from medique where dni_medique = dni_medique_param;
	-- not found
	if existe is null then
		insert into error(f_turno, dni_medique, nro_paciente, operacion, f_error, motivo)
		values(
			fechayhora,
			dni_medique_param,
			nro_historia_clinica_param,
			'reserva',
			now(),
			'dni de médique no válido');
		return false;
	end if;

	--Verificamos el numero del paciente
	select 1 into existe from paciente where nro_paciente = nro_historia_clinica_param;
	if existe is null then
		insert into error(f_turno, dni_medique, nro_paciente, operacion, f_error, motivo)
		values(
			fechayhora,
			dni_medique_param,
			nro_historia_clinica_param,
			'reserva',
			now(), 
	    	'nro de historia clínica no válido');
		return false;
	end if;

	--Chequea la obra social

	select paciente.nro_obra_social into numero_obra from cobertura, paciente where dni_medique = dni_medique_param and paciente.nro_obra_social=cobertura.nro_obra_social and nro_paciente = nro_historia_clinica_param;
	
	if numero_obra is null then
		insert into error(f_turno,nro_consultorio, dni_medique, nro_paciente, operacion, f_error, motivo)
		values(
			fechayhora,
			numero_consultorio_dato,
			dni_medique_param,
			nro_historia_clinica_param,
			'reserva',
			now(),
			'obra social de paciente no atendida por le médique');
		return false;
	end if;

	-- select 1 into existe from turno where fecha = fechayhora; ???
	select 1 into existe from turno where fecha = fechayhora and dni_medique = dni_medique_param and estado ='disponible';
	if existe is null then
		insert into error(f_turno, dni_medique, nro_paciente, operacion, f_error, motivo)
		values(
		fechayhora,
		dni_medique_param, 
		nro_historia_clinica_param, 
		'reserva', 
		now(), 
		'turno inexistente ó no disponible');
		return false;
	end if;
--
	select count(*) into turno_reserva from turno where nro_paciente = nro_historia_clinica_param and estado='reservado';
	if turno_reserva >= 5 then
		insert into error(f_turno, nro_consultorio, dni_medique, nro_paciente, operacion, f_error, motivo)
		values(
		fechayhora, 
		numero_consultorio_dato,
		dni_medique_param, nro_historia_clinica_param, 
		'reserva', 
		now(), 
		'supera límite de reserva de turnos');
		return false;

	end if;
	--select nro_turno into existe from turno where fecha = fechayhora and dni_medique = dni_medique_param;
	
	update turno set 
		nro_paciente=nro_historia_clinica_param, 
		nro_obra_social_consulta = numero_obra, 
		nro_afiliade_consulta = (select nro_afiliade from paciente where nro_paciente = nro_historia_clinica_param),
		monto_paciente=(select monto_paciente from cobertura where dni_medique = dni_medique_param and nro_obra_social= numero_obra), 
		monto_obra_social=(select monto_obra_social from cobertura where dni_medique = dni_medique_param and nro_obra_social = numero_obra), 
		f_reserva=now(), 
		estado='reservado'
	where  fecha = fechayhora and dni_medique = dni_medique_param;
	
	return true;
	rollback;
	commit;
end;
$$ language plpgsql;

create function atender_turno(numero_turno_param int) 
returns boolean as $$
declare
  existe int;
  estado_reserva text;
  fecha_turno text;
  fecha_actual text;
  turno_parametros record;

begin
	-- Verificar si el numero de turno existe

	select * into turno_parametros from turno where nro_turno = numero_turno_param;
	select 1 into existe from turno where nro_turno = numero_turno_param;
	if existe is null then
		
		insert into error(f_turno, operacion, f_error, motivo)
		values (current_date,
				'atención', 
				now(), 
				'nro de turno no válido');
		return false;
	end if;
	
	-- Verificar si el turno se encuentra en estado reservado
	select estado into estado_reserva from turno where nro_turno = numero_turno_param;
	if estado_reserva is null or estado_reserva <> 'reservado' then
    
    insert into error(f_turno, nro_consultorio, dni_medique, nro_paciente, operacion, f_error, motivo)
    values (
		turno_parametros.fecha,
		turno_parametros.nro_consultorio,
		turno_parametros.dni_medique,
		turno_parametros.nro_paciente,
		'atención',
		now(), 
		'turno no reservado');
    return false;
  end if;

  -- Verificar si la fecha del turno corresponde a la fecha actual
	select fecha into fecha_turno from turno where nro_turno = numero_turno_param;
	fecha_turno:=to_date(fecha_turno, 'YYYY-MM-DD');
	SELECT CURRENT_DATE into fecha_actual;
  	
	
	if fecha_turno <> fecha_actual then 

    
    insert into error(f_turno, nro_consultorio, dni_medique, nro_paciente, operacion, f_error, motivo)
    values (
		turno_parametros.fecha,
		turno_parametros.nro_consultorio,
		turno_parametros.dni_medique,
		turno_parametros.nro_paciente,
		'atención',
		now(),
		'turno no corresponde a la fecha del día');
    return false;
  end if;

  -- Marcar el turno como atendido
  update turno set estado = 'atendido' where nro_turno = numero_turno_param;

  return true;
end;
$$ language plpgsql;

create function cancelacion_turno(dni_medique_entrada int, fecha_desde date, fecha_hasta date)  returns int as $$
declare
	existe int;
	estado_reserva text;
	--fecha_turno text;
	fila_turno turno%rowtype;
	contador_filas int;
	fila_paciente paciente%rowtype;
	fila_medique medique%rowtype;

begin 
	contador_filas:=0;


	for fila_turno in select * from turno where turno.dni_medique=dni_medique_entrada and (turno.estado = 'disponible' or turno.estado = 'reservado') and turno.fecha between fecha_desde and fecha_hasta   loop
			
			update turno set estado = 'cancelado' where turno.nro_turno = fila_turno.nro_turno;

			select * into fila_paciente from paciente where fila_turno.nro_paciente = paciente.nro_paciente;

			select * into fila_medique from medique where fila_turno.dni_medique = medique.dni_medique;

			contador_filas := contador_filas+1;
			INSERT INTO reprogramacion (
				nro_turno,
				nombre_paciente,
				apellido_paciente,
				telefono_paciente,
				email_paciente,
				nombre_medique,
				apellido_medique,
				estado --`pendiente', `reprogramado', `desistido'
			)
			VALUES(
				fila_turno.nro_turno,
				fila_paciente.nombre,
				fila_paciente.apellido,
				fila_paciente.telefono,
				fila_paciente.email,
				fila_medique.nombre,
				fila_medique.apellido,
				'reprogramado'
			);



	end loop;
	return contador_filas;

end;
$$ language plpgsql;



create function liquidacion_obra_social(desde_date date, hasta_date date) returns void as $$
declare 
    fila_obra_social obra_social%rowtype;
    fila_datos record;
    total_liquidacion int ;
    liquidacion_cabecera_id int;
	liquidacion_nro_linea int;
begin
	total_liquidacion := 0;
	liquidacion_nro_linea := 1;
    for fila_obra_social in select * from obra_social 
    loop
        -- Crear nueva entrada en liquidacion_cabecera y almacenar el id en la variable liquidacion_cabecera_id
        insert into liquidacion_cabecera (nro_obra_social, desde, hasta) 
        values (fila_obra_social.nro_obra_social, desde_date, hasta_date) 
        returning nro_liquidacion into liquidacion_cabecera_id;			
        
        for fila_datos in select turno.fecha turno_fecha,
			paciente.nro_afiliade paciente_nro_afiliade,
			paciente.dni_paciente paciente_dni,
			paciente.nombre paciente_nombre,
			paciente.apellido paciente_apellido,
			medique.dni_medique medique_dni,
			medique.nombre medique_nombre,
			medique.apellido medique_apellido,
			medique.especialidad medique_especialidad,
			turno.monto_obra_social turno_monto_obra_social,
			turno.nro_turno turno_nro_turno
		from turno,paciente,medique 
		where nro_obra_social_consulta = fila_obra_social.nro_obra_social and 
		estado = 'atendido' and paciente.nro_paciente=turno.nro_paciente 
		and medique.dni_medique=turno.dni_medique  
		and fecha between desde_date 
		and hasta_date  
		loop
            total_liquidacion := total_liquidacion + fila_datos.turno_monto_obra_social;
			insert into liquidacion_detalle (
				nro_liquidacion,
				nro_linea, 
				f_atencion,
				nro_afiliade,
				dni_paciente,
				nombre_paciente,
				apellido_paciente,
				dni_medique,
				nombre_medique,
				apellido_medique,
				especialidad,
				monto
				)				
			values(
				liquidacion_cabecera_id,
				liquidacion_nro_linea,
				fila_datos.turno_fecha,
				fila_datos.paciente_nro_afiliade,
				fila_datos.paciente_dni,
				fila_datos.paciente_nombre,
				fila_datos.paciente_apellido,
				fila_datos.medique_dni,
				fila_datos.medique_nombre,
				fila_datos.medique_apellido,
				fila_datos.medique_especialidad,
				fila_datos.turno_monto_obra_social
				);
            
            -- Cambiar estado a liquidado en turno
            update turno set estado = 'liquidado'
            where turno.nro_turno = fila_datos.turno_nro_turno;
			liquidacion_nro_linea := liquidacion_nro_linea+1;
        end loop;
        --Cambio el monto total de la liquidacion
        update liquidacion_cabecera set total = total_liquidacion
        where nro_liquidacion = liquidacion_cabecera_id;
        
        liquidacion_nro_linea=1;
        total_liquidacion := 0;
		
		
    end loop;

end; $$
language plpgsql;


create function envio_emails() returns trigger as $$
declare
	paciente_email TEXT;
	datos_medique record;
begin
	select dni_medique, nombre, apellido, telefono into datos_medique from medique where medique.dni_medique = NEW.dni_medique;
	if NEW.estado = 'reservado' then
		select email into paciente_email from paciente where paciente.nro_paciente = NEW.nro_paciente;
		insert into envio_email(
			f_generacion, 
			email_paciente, 
			asunto, 
			cuerpo, 
			f_envio, 
			estado)
		values(
			date_trunc('second',current_timestamp),
			paciente_email,
			'Reserva de Turno',
			'Dia del turno: ' || NEW.fecha::timestamp without time zone || ' | Nro. Consultorio: ' || NEW.nro_consultorio || ' | Datos del medique:' || datos_medique,
			null,
			'pendiente'
		);
	end if;
	if  NEW.estado = 'cancelado' and OLD.estado ='reservado' then
		select email into paciente_email from paciente where paciente.nro_paciente = NEW.nro_paciente;
		insert into envio_email(
			f_generacion, 
			email_paciente, 
			asunto, 
			cuerpo, 
			f_envio, 
			estado)
		values(
			date_trunc('second',current_timestamp),
			paciente_email,
			'Cancelacion de turno',
			'Dia del turno: ' || NEW.fecha::timestamp without time zone || ' | Nro. Consultorio: ' || NEW.nro_consultorio || ' | Datos del medique:' || datos_medique,
			null,
			'cancelado'
		);
	end if;
	return new;
end;
$$ language plpgsql;


create trigger trigger_envio_mail
after update on turno
for each row
execute procedure envio_emails();


create function envio_emails_recordatorio() returns void as $$
declare
	datos_medique record;
	turno_fila record;
begin
	for turno_fila in select * from turno,paciente where date_trunc('day',turno.fecha) <= date_trunc('day',CURRENT_DATE + interval '2 day') and date_trunc('day',turno.fecha)>date_trunc('day',CURRENT_DATE ) and turno.nro_paciente=paciente.nro_paciente and turno.estado='reservado' loop

		select dni_medique, nombre, apellido, telefono into datos_medique from medique where medique.dni_medique = turno_fila.dni_medique;
		insert into envio_email(
			f_generacion, 
			email_paciente, 
			asunto, 
			cuerpo, 
			f_envio, 
			estado)
		values(
			date_trunc('second',current_timestamp),
			turno_fila.email,
			'Recordatorio de turno',
			'Dia del turno: ' || turno_fila.fecha::timestamp without time zone || ' | Nro. Consultorio: ' || turno_fila.nro_consultorio || ' | Datos del medique:' || datos_medique, -- falta agregar,
			null,
			'pendiente'
		);
		


			
	end loop;

end;
$$ language plpgsql;


create function envio_emails_perdida_turno() returns void as $$
declare
	datos_medique record;
	turno_fila record;
begin
	for turno_fila in select * from turno,paciente where  date_trunc('day',turno.fecha)<date_trunc('day',CURRENT_DATE ) and turno.nro_paciente=paciente.nro_paciente and turno.estado='reservado'  loop

		select dni_medique, nombre, apellido, telefono into datos_medique from medique where medique.dni_medique = turno_fila.dni_medique;
		insert into envio_email(
			f_generacion, 
			email_paciente, 
			asunto, 
			cuerpo, 
			f_envio, 
			estado)
		values(
			date_trunc('second',current_timestamp),
			turno_fila.email,
			'Pérdida de turno reservado',
			'Dia del turno: ' || turno_fila.fecha::timestamp without time zone || ' | Nro. Consultorio: ' || turno_fila.nro_consultorio || ' | Datos del medique:' || datos_medique, -- falta agregar,
			null,
			'pendiente'
		);
		

		
	end loop;

end;
$$ language plpgsql;




