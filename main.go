package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"

	// "github.com/jmoiron/sqlx"
	"github.com/boltdb/bolt"
	_ "github.com/lib/pq"
)

func deleteDatabase(db *sql.DB) {
	_, err := db.Exec("DROP DATABASE IF EXISTS tp")
	if err != nil {
		log.Fatal(err)
	}
}

func createDatabase(db *sql.DB) {
	_, err := db.Exec("CREATE DATABASE tp")
	if err != nil {
		log.Fatal(err)
	}
}

func deleteFK(db *sql.DB) {
	_, err := db.Exec(`ALTER TABLE paciente DROP CONSTRAINT paciente_nro_obra_social_fk;
	ALTER TABLE agenda DROP CONSTRAINT agenda_dni_medique_fk;
	ALTER TABLE turno DROP CONSTRAINT turno_nro_consultorio_fk;
	ALTER TABLE turno DROP CONSTRAINT turno_dni_medique_fk;
	ALTER TABLE turno DROP CONSTRAINT turno_nro_paciente_fk;
	ALTER TABLE error DROP CONSTRAINT error_nro_consultorio_fk;
	ALTER TABLE error DROP CONSTRAINT error_dni_medique_fk;
	ALTER TABLE error DROP CONSTRAINT error_nro_paciente_fk;
	ALTER TABLE cobertura DROP CONSTRAINT cobertura_dni_medique_fk;
	ALTER TABLE cobertura DROP CONSTRAINT cobertura_nro_obra_social_fk;
	ALTER TABLE liquidacion_cabecera DROP CONSTRAINT liquidacion_cabecera_nro_obra_social_fk;
	ALTER TABLE liquidacion_detalle DROP CONSTRAINT liquidacion_detalle_dni_medique_fk;
	--ALTER TABLE solicitud_reservas DROP CONSTRAINT solicitud_reservas_dni_medique_fk;
	--ALTER TABLE solicitud_reservas DROP CONSTRAINT solicitud_reservas_paciente_fk;
	`)
	if err != nil {
		log.Fatal(err)
	}
}

func deletePK(db *sql.DB) {
	_, err := db.Exec(`ALTER TABLE paciente DROP CONSTRAINT paciente_pk;
	ALTER TABLE medique DROP CONSTRAINT medique_pk;
	ALTER TABLE consultorio DROP CONSTRAINT consultorio_pk;
	ALTER TABLE agenda DROP CONSTRAINT agenda_pk;
	ALTER TABLE turno DROP CONSTRAINT turno_pk;
	ALTER TABLE error DROP CONSTRAINT error_pk;
	ALTER TABLE cobertura DROP CONSTRAINT cobertura_pk;
	ALTER TABLE obra_social DROP CONSTRAINT obra_social_pk;
	ALTER TABLE liquidacion_cabecera DROP CONSTRAINT liquidacion_cabecera_pk;
	ALTER TABLE liquidacion_detalle DROP CONSTRAINT liquidacion_detalle_pk;
	ALTER TABLE envio_email DROP CONSTRAINT envio_email_pk;
	--ALTER TABLE solicitud_reservas DROP CONSTRAINT solicitud_reservas_pk;
`)

	if err != nil {
		log.Fatal(err)
	}
}

func executeSQLFile(db *sql.DB, filename string) error {
	file, err := os.ReadFile(filename)
	if err != nil {
		return err
	}
	sql := string(file)

	_, err = db.Exec(sql)
	if err != nil {
		return err
	}

	return nil
}

func generarTurnos(db *sql.DB) {
	var result bool
	var anio int
	var mes int

	anio = 2023
	mes = 06

	row := db.QueryRow("SELECT generacion_turnos_disponibles($1, $2)", anio, mes)
	err := row.Scan(&result)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("El resultado es:", result)
}

func reservarTurno(db *sql.DB) {
	row, err := db.Query(`SELECT nro_paciente, dni_medique, fecha, hora FROM solicitud_reservas`)
	if err != nil {
		log.Fatal(err)
	}
	defer row.Close()

	for row.Next() {
		var nroHistoriaClinica int
		var dniMedique int
		var fecha time.Time
		var hora time.Time

		if err := row.Scan(&nroHistoriaClinica, &dniMedique, &fecha, &hora); err != nil {
			log.Fatal(err)
		}
		var result bool
		row := db.QueryRow(`SELECT reserva_turno($1, $2, $3, $4)`, nroHistoriaClinica, dniMedique, fecha, hora)
		err = row.Scan(&result)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("El resultado para %d es: %v\n", nroHistoriaClinica, result)
	}
}

func atenderTurno(db *sql.DB) {
	var result bool

	query := "SELECT atender_turno($1)"

	turnos := []int{1, 1068, 472, 911, 1065, 1071, 329, 34}
	for _, turno := range turnos {
		row := db.QueryRow(query, turno)
		err := row.Scan(&result)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println("El resultado es:", result)
	}

}

type Paciente struct {
	NroPaciente     int    `json:"nro_paciente"`
	Nombre          string `json:"nombre"`
	Apellido        string `json:"apellido"`
	DniPaciente     int    `json:"dni_paciente"`
	FechaNacimiento string `json:"f_nac"`
	NroObraSocial   int    `json:"nro_obra_social"`
	NroAfiliado     int    `json:"nro_afiliade"`
	Domicilio       string `json:"domicilio"`
	Telefono        string `json:"telefono"`
	Email           string `json:"email"`
}

type Medique struct {
	DniMedique           int     `json:"dni_medique"`
	Nombre               string  `json:"nombre"`
	Apellido             string  `json:"apellido"`
	Especialidad         string  `json:"especialidad"`
	MontoConsultaPrivada float64 `json:"monto_consulta_privada"`
	Telefono             string  `json:"telefono"`
}

type Consultorio struct {
	NroConsultorio int    `json:"nro_consultorio"`
	Nombre         string `json:"nombre"`
	Domicilio      string `json:"domicilio"`
	CodigoPostal   string `json:"codigo_postal"`
	Telefono       string `json:"telefono"`
}

type ObraSocial struct {
	NroObraSocial    int    `json:"nro_obra_social"`
	Nombre           string `json:"nombre"`
	ContactoNombre   string `json:"contacto_nombre"`
	ContactoApellido string `json:"contacto_apellido"`
	ContactoTelefono string `json:"contacto_telefono"`
	ContactoEmail    string `json:"contacto_email"`
}

type Turno struct {
	NroTurno              int       `json:"nro_turno"`
	Fecha                 time.Time `json:"fecha"`
	NroConsultorio        int       `json:"nro_consultorio"`
	DNIMedique            int       `json:"dni_medique"`
	NroPaciente           int       `json:"nro_paciente"`
	NroObraSocialConsulta int       `json:"nro_obra_social_consulta"`
	NroAfiliadeConsulta   int       `json:"nro_afiliade_consulta"`
	MontoPaciente         float64   `json:"monto_paciente"`
	MontoObraSocial       float64   `json:"monto_obra_social"`
	FReserva              time.Time `json:"f_reserva"`
	Estado                string    `json:"estado"`
}

func guardarDatos() {

	dbPath := "bdd.db"

	// Verificar si el archivo de la base de datos existe
	_, err := os.Stat(dbPath)
	if err == nil {
		// El archivo existe, así que lo eliminamos
		err := os.Remove(dbPath)
		if err != nil {
			log.Fatal(err)
		}
	} else if !os.IsNotExist(err) {
		// Ocurrió un error al verificar la existencia del archivo
		log.Fatal(err)
	}

	db, err := bolt.Open("bdd.db", 0600, nil)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	//Generamos busckets para cada tabla
	err = db.Update(func(tx *bolt.Tx) error {

		pacientesBucket, err := tx.CreateBucketIfNotExists([]byte("pacientes"))
		if err != nil {
			return err
		}

		medicoBucket, err := tx.CreateBucketIfNotExists([]byte("medicos"))
		if err != nil {
			return err
		}

		consultoriosBucket, err := tx.CreateBucketIfNotExists([]byte("consultorios"))
		if err != nil {
			return err
		}

		obrassocialBucket, err := tx.CreateBucketIfNotExists([]byte("obra_social"))
		if err != nil {
			return err
		}

		turnosBucket, err := tx.CreateBucketIfNotExists([]byte("turnos"))
		if err != nil {
			return err
		}

		// Lista de pacientes a guardar
		pacientes := []Paciente{
			{
				NroPaciente:     1,
				Nombre:          "Juan",
				Apellido:        "Pérez",
				DniPaciente:     30234567,
				FechaNacimiento: "1990-01-01",
				NroObraSocial:   1234,
				NroAfiliado:     5678,
				Domicilio:       "Av. Corrientes 1234, Buenos Aires",
				Telefono:        "541134567890",
				Email:           "juan.perez@gmail.com",
			},
			{
				NroPaciente:     2,
				Nombre:          "Maria",
				Apellido:        "Gómez",
				DniPaciente:     30804567,
				FechaNacimiento: "1992-02-02",
				NroObraSocial:   5678,
				NroAfiliado:     4321,
				Domicilio:       "Calle Florida 567, Cordoba",
				Telefono:        "541145678901",
				Email:           "maria.gomez@gmail.com",
			},
		}
		// Lista de doctores a guardar
		medicos := []Medique{
			{
				DniMedique:           31284541,
				Nombre:               "Mariana",
				Apellido:             "Lopez",
				Especialidad:         "Pediatría",
				MontoConsultaPrivada: 200.0,
				Telefono:             "541134567890",
			},
			{
				DniMedique:           28672143,
				Nombre:               "Carlos",
				Apellido:             "Gonzalez",
				Especialidad:         "Cardiología",
				MontoConsultaPrivada: 300.0,
				Telefono:             "541145678901",
			},
		}
		// Lista de consultorios a guardar
		consultorios := []Consultorio{

			{
				NroConsultorio: 1,
				Nombre:         "Consultorio Médico Argentino",
				Domicilio:      "Av. Corrientes 123, Buenos Aires",
				CodigoPostal:   "12345678",
				Telefono:       "541123456789",
			},

			{
				NroConsultorio: 2,
				Nombre:         "Consultorio Odontológico del Sur",
				Domicilio:      "Calle Mitre 456, Córdoba",
				CodigoPostal:   "54321098",
				Telefono:       "541123456791",
			},
		}
		// Lista de obras sociales a guardar
		obras_sociales := []ObraSocial{

			{
				NroObraSocial:    1234,
				Nombre:           "Osde",
				ContactoNombre:   "Hector",
				ContactoApellido: "Bracamonte",
				ContactoTelefono: "541134567890",
				ContactoEmail:    "hec.bra@gmail.com",
			},

			{
				NroObraSocial:    5678,
				Nombre:           "Omint",
				ContactoNombre:   "Nicolas",
				ContactoApellido: "Burdisso",
				ContactoTelefono: "541145678901",
				ContactoEmail:    "nico.burdisso@gmail.com",
			},
		}
		// Lista de turnos a guardar
		turnos := []Turno{
			{
				NroTurno:              1,
				Fecha:                 time.Date(2023, time.June, 15, 10, 0, 0, 0, time.UTC),
				NroConsultorio:        1,
				DNIMedique:            31284541,
				NroPaciente:           1,
				NroObraSocialConsulta: 1234,
				NroAfiliadeConsulta:   5678,
				MontoPaciente:         50.0,
				MontoObraSocial:       100.0,
				FReserva:              time.Date(2023, time.June, 14, 15, 0, 0, 0, time.UTC),
				Estado:                "Reservado",
			},
			{
				NroTurno:              2,
				Fecha:                 time.Date(2023, time.June, 16, 11, 30, 0, 0, time.UTC),
				NroConsultorio:        2,
				DNIMedique:            31284541,
				NroPaciente:           2,
				NroObraSocialConsulta: 5678,
				NroAfiliadeConsulta:   1234,
				MontoPaciente:         60.0,
				MontoObraSocial:       90.0,
				FReserva:              time.Date(2023, time.June, 15, 9, 0, 0, 0, time.UTC),
				Estado:                "Reservado",
			},
			{
				NroTurno:              3,
				Fecha:                 time.Date(2023, time.June, 17, 14, 0, 0, 0, time.UTC),
				NroConsultorio:        3,
				DNIMedique:            31284541,
				NroPaciente:           3,
				NroObraSocialConsulta: 1234,
				NroAfiliadeConsulta:   5678,
				MontoPaciente:         75.0,
				MontoObraSocial:       125.0,
				FReserva:              time.Date(2023, time.June, 16, 10, 30, 0, 0, time.UTC),
				Estado:                "Reservado",
			},
			{
				NroTurno:              4,
				Fecha:                 time.Date(2023, time.June, 18, 9, 30, 0, 0, time.UTC),
				NroConsultorio:        1,
				DNIMedique:            28672143,
				NroPaciente:           4,
				NroObraSocialConsulta: 5678,
				NroAfiliadeConsulta:   1234,
				MontoPaciente:         80.0,
				MontoObraSocial:       120.0,
				FReserva:              time.Date(2023, time.June, 17, 8, 0, 0, 0, time.UTC),
				Estado:                "Reservado",
			},
			{
				NroTurno:              5,
				Fecha:                 time.Date(2023, time.June, 19, 16, 0, 0, 0, time.UTC),
				NroConsultorio:        2,
				DNIMedique:            28672143,
				NroPaciente:           5,
				NroObraSocialConsulta: 1234,
				NroAfiliadeConsulta:   5678,
				MontoPaciente:         65.0,
				MontoObraSocial:       135.0,
				FReserva:              time.Date(2023, time.June, 18, 13, 30, 0, 0, time.UTC),
				Estado:                "Reservado",
			},
			{
				NroTurno:              6,
				Fecha:                 time.Date(2023, time.June, 20, 13, 0, 0, 0, time.UTC),
				NroConsultorio:        3,
				DNIMedique:            28672143,
				NroPaciente:           6,
				NroObraSocialConsulta: 5678,
				NroAfiliadeConsulta:   1234,
				MontoPaciente:         70.0,
				MontoObraSocial:       110.0,
				FReserva:              time.Date(2023, time.June, 19, 11, 30, 0, 0, time.UTC),
				Estado:                "Reservado",
			},
			{
				NroTurno:              7,
				Fecha:                 time.Date(2023, time.June, 21, 8, 30, 0, 0, time.UTC),
				NroConsultorio:        1,
				DNIMedique:            27565033,
				NroPaciente:           7,
				NroObraSocialConsulta: 1234,
				NroAfiliadeConsulta:   5678,
				MontoPaciente:         55.0,
				MontoObraSocial:       95.0,
				FReserva:              time.Date(2023, time.June, 20, 7, 0, 0, 0, time.UTC),
				Estado:                "Reservado",
			},
			{
				NroTurno:              8,
				Fecha:                 time.Date(2023, time.June, 22, 11, 0, 0, 0, time.UTC),
				NroConsultorio:        2,
				DNIMedique:            27565033,
				NroPaciente:           8,
				NroObraSocialConsulta: 5678,
				NroAfiliadeConsulta:   1234,
				MontoPaciente:         90.0,
				MontoObraSocial:       110.0,
				FReserva:              time.Date(2023, time.June, 21, 9, 30, 0, 0, time.UTC),
				Estado:                "Reservado",
			},
			{
				NroTurno:              9,
				Fecha:                 time.Date(2023, time.June, 23, 15, 30, 0, 0, time.UTC),
				NroConsultorio:        3,
				DNIMedique:            27565033,
				NroPaciente:           9,
				NroObraSocialConsulta: 1234,
				NroAfiliadeConsulta:   5678,
			},
		}

		for _, turno := range turnos {
			// Convertir los turnos a formato JSON
			turnolJSON, err := json.Marshal(turno)
			if err != nil {
				return err
			}

			// Generar una clave única para cada turno
			key := []byte(fmt.Sprintf("turno-%d", turno.NroTurno))

			// Guardar el turno particular JSON en el bucket para turnos
			err = turnosBucket.Put(key, turnolJSON)
			if err != nil {
				return err
			}
		}

		for _, obra_social := range obras_sociales {
			// Convertir las obras sociales a formato JSON
			obra_socialJSON, err := json.Marshal(obra_social)
			if err != nil {
				return err
			}

			// Generar una clave única para cada obra social
			key := []byte(fmt.Sprintf("obra_social-%d", obra_social.NroObraSocial))

			// Guardar el objeto JSON en el bucket para obras sociales
			err = obrassocialBucket.Put(key, obra_socialJSON)
			if err != nil {
				return err
			}
		}

		for _, consultorio := range consultorios {
			// Convertir los consultorios a formato JSON
			consultorioJSON, err := json.Marshal(consultorio)
			if err != nil {
				return err
			}

			// Generar una clave única para cada consultorio
			key := []byte(fmt.Sprintf("consultorio-%d", consultorio.NroConsultorio))

			// Guardar el objeto JSON en el bucket de los consultorios
			err = consultoriosBucket.Put(key, consultorioJSON)
			if err != nil {
				return err
			}
		}

		// Iterar sobre cada paciente y guardarlos en el bucket "pacientes"
		for _, paciente := range pacientes {
			// Convertir el Paciente a formato JSON
			pacienteJSON, err := json.Marshal(paciente)
			if err != nil {
				return err
			}

			// Generar una clave única para cada paciente (puedes usar un generador de IDs único)
			key := []byte(fmt.Sprintf("paciente-%d", paciente.NroPaciente))

			// Guardar el objeto JSON en el bucket "pacientes"
			err = pacientesBucket.Put(key, pacienteJSON)
			if err != nil {
				return err
			}
		}

		for _, medico := range medicos {
			// Convertir el objeto medico a formato JSON
			medicoJSON, err := json.Marshal(medico)
			if err != nil {
				return err
			}

			// Generar una clave única para cada doctor
			key := []byte(fmt.Sprintf("medico-%d", medico.DniMedique))

			// Guardar el objeto JSON en el bucket "doctores"
			err = medicoBucket.Put(key, medicoJSON)
			if err != nil {
				return err
			}
		}

		return nil
	})

	if err != nil {
		log.Fatal(err)
	}

}

func cancelarTurno(db *sql.DB) {

	var contadorFilasDevuelve int
	var dniMedique int
	var fechaDesde string
	var fechaHasta string

	dniMedique = 31284541

	fechaDesde = "2023-06-13"
	fechaHasta = "2023-06-18"

	// Ejecutar la consulta y obtener el resultado

	row := db.QueryRow("SELECT cancelacion_turno($1,$2,$3)", dniMedique, fechaDesde, fechaHasta)
	err := row.Scan(&contadorFilasDevuelve)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("La cantidad de turnos cancelados son:", contadorFilasDevuelve)
	return

}

func liquidacion_entrar(db *sql.DB) {
	var fechaDesde string
	var fechaHasta string

	fechaDesde = "2023-06-01"
	fechaHasta = "2023-07-01"

	_, err := db.Exec("SELECT liquidacion_obra_social($1, $2)", fechaDesde, fechaHasta)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Turnos liquidados")
}

func envioMailRecordatorio(db *sql.DB) {
	query := "SELECT envio_emails_recordatorio()"

	_, err := db.Exec(query)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Se guardaron mail de Recordatorio")
}
func envioMailPerdidaTurno(db *sql.DB) {
	query := "SELECT envio_emails_perdida_turno()"

	_, err := db.Exec(query)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Se guardaron mail de Perdida de Turno")

}

func menu(db *sql.DB) {
	var input int
	var dia time.Time

	dia = time.Now()
	for input != 8 {
		fmt.Println(`Presione el numero con la opcion que desee
		1. Eliminar PK's / FK's
		2. Generar un turno disponible
		3. Reservar un turno
		4. Cancelar un turno
		5. Atender un turno
		6. Liquidacion para obras sociales
		7. Salir`)
		fmt.Scanln(&input)
		if input == 1 {
			deleteFK(db)
			deletePK(db)
			fmt.Println("PK's y FK's eliminadas correctamente")
		}
		if input == 2 {
			fmt.Println("Generando turnos")
			generarTurnos(db)
		}
		if input == 3 {
			fmt.Println("Reservando turnos")
			reservarTurno(db)
		}
		if input == 4 {
			fmt.Println("Cancelando el turno")
			cancelarTurno(db)
		}
		if input == 5 {
			fmt.Println("Atendiendo los turnos")
			atenderTurno(db)
		}
		if input == 6 {
			fmt.Println("Liquidando obras sociales")
			liquidacion_entrar(db)
		}
		if input == 7 {
			fmt.Println("Terminando el programa.")
			os.Exit(0)
		}
		input = 0

		if dia.Format("2006-01-02") != time.Now().Format("2006-01-02") {
			dia = time.Now()
			envioMailPerdidaTurno(db)
			envioMailRecordatorio(db)

		}
	}

}

func main() {

	// Abrir la conexión a la base de datos predeterminada
	db, err := sql.Open("postgres", "user=postgres dbname=postgres sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}

	// Comprobar la conexión
	err = db.Ping()
	if err != nil {
		log.Fatal(err)
	}

	// Eliminar base de datos si existe
	deleteDatabase(db)

	// Crear base de datos si no existe
	createDatabase(db)
	guardarDatos()
	db.Close()
	//Seleccionar la base de datos recién creada
	db, err = sql.Open("postgres", "user=postgres dbname=tp sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// Comprobar la conexión
	err = db.Ping()
	if err != nil {
		log.Fatal(err)
	}

	// Leer archivos SQL
	err = executeSQLFile(db, "sql/tables.sql")
	if err != nil {
		log.Fatal(err)
	}

	err = executeSQLFile(db, "sql/data.sql")
	if err != nil {
		log.Fatal(err)
	}

	err = executeSQLFile(db, "sql/functions.sql")
	if err != nil {
		log.Fatal(err)
	}
	//envioMailDia(db)
	menu(db)

}

/*
	type paciente struct {
		nro_paciente                  int
		nombre, apellido              string
		dni_paciente                  int
		f_nac                         time.Time
		nro_obra_social, nro_afiliade int
		domicilio                     string
		telefono                      int
		email                         string
	}
*/
//Tengo un problema para imprimir con la fecha, porque solo quiero dia mes y año
/*
	rows, err := db.Query(`select * from paciente`)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	var a paciente
	for rows.Next() {
		if err := rows.Scan(&a.nro_paciente, &a.nombre, &a.apellido, &a.dni_paciente, &a.f_nac, &a.nro_obra_social, &a.nro_afiliade, &a.domicilio, &a.telefono, &a.email); err != nil {
			log.Fatal(err)
		}
		year, month, day := a.f_nac.Date()
		fmt.Printf("%v %v %v %v %v %v %v %v %v %d-%02d-%02d\n", a.nro_paciente, a.nombre, a.apellido, a.dni_paciente, a.f_nac, a.nro_obra_social, a.nro_afiliade, a.domicilio, a.telefono, a.email,year, month, day)
	}
	if err = rows.Err(); err != nil {
		log.Fatal(err)
	}

	fmt.Println(time.Now())
*/

/*
func main() {
	switch {
	}
	for {
	}
		fmt.Printf("1. Para crear la base de datos.")
		fmt.Printf("2. Para crear las tablas.")
		fmt.Printf("3. Agregar PK's y FK's.")
		fmt.Printf("4. Agregar datos en las tablas.")
		fmt.Printf("3. Para crear la base de datos.")
		fmt.Scanf("%d", &opcion)
}
*/

/*
		paciente := Paciente{
			NroPaciente:     1,
			Nombre:          "Juan",
			Apellido:        "Pérez",
			DniPaciente:     12345678,
			FechaNacimiento: "1990-01-01",
			NroObraSocial:   1234,
			NroAfiliado:     5678,
			Domicilio:       "Calle 123",
			Telefono:        "123456789",
			Email:           "juan@example.com",
		}

		// Convertir el objeto Paciente a formato JSON
		pacienteJSON, err := json.Marshal(paciente)
		if err != nil {
			return err
		}

		// Guardar el objeto JSON en el bucket "pacientes"
		err = pacientesBucket.Put([]byte("1"), pacienteJSON)
		if err != nil {
			return err
		}

		// Guardar otros pacientes...

		return nil
	})

	if err != nil {
		log.Fatal(err)
	}
}

func mostrarDatos() {
	db, err := bolt.Open("bdd.db", 0600, nil)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	err = db.View(func(tx *bolt.Tx) error {
		pacientesBucket := tx.Bucket([]byte("pacientes"))
		if pacientesBucket == nil {
			return fmt.Errorf("pacientes no encontrado")
		}

		// recorremos los datos sobre el bucket pacientes y printeamos
		err := pacientesBucket.ForEach(func(key, value []byte) error {
			var paciente Paciente

			//Hacemos el proceso de unmarshal sobre los valores
			err := json.Unmarshal(value, &paciente)
			if err != nil {
				return err
			}

			fmt.Printf("ID: %s, Nombre: %s, Apellido: %s\n", key, paciente.Nombre, paciente.Apellido)
			return nil
		})

		if err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		log.Fatal(err)
	}
}

		// Iterar sobre los datos en el bucket "pacientes" y mostrarlos
		err := pacientesBucket.ForEach(func(key, value []byte) error {
			var paciente Paciente
			err := json.Unmarshal(value, &paciente)
			if err != nil {
				return err
			}

			fmt.Printf("ID: %s, Nombre: %s, Apellido: %s\n", key, paciente.Nombre, paciente.Apellido)
			return nil
		})

		if err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		log.Fatal(err)
	}
}
*/
