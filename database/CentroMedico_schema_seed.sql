/* ============================================================
   Sistema Transaccional - Clínica Limatambo Cajamarca (referencial)
   Curso: Desarrollo de Software con C#, ADO.NET y WPF
   Motor: SQL Server 2019+
   Nota: nombre de la clínica es referencial, cámbialo si usas otro.
   ============================================================ */

IF DB_ID('CentroMedicoDB') IS NULL
BEGIN
    CREATE DATABASE CentroMedicoDB;
END
GO

USE CentroMedicoDB;
GO

-- ============================================================
-- 1. TABLAS
-- ============================================================

CREATE TABLE Especialidades (
    EspecialidadID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL UNIQUE
);
GO

CREATE TABLE Medicos (
    MedicoID INT IDENTITY(1,1) PRIMARY KEY,
    CMP VARCHAR(10) NOT NULL UNIQUE,
    Nombres VARCHAR(60) NOT NULL,
    Apellidos VARCHAR(60) NOT NULL,
    EspecialidadID INT NOT NULL,
    Telefono VARCHAR(9) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    FechaIngreso DATE NOT NULL,
    CONSTRAINT FK_Medicos_Especialidad FOREIGN KEY (EspecialidadID) REFERENCES Especialidades(EspecialidadID)
);
GO

CREATE TABLE Pacientes (
    PacienteID INT IDENTITY(1,1) PRIMARY KEY,
    DNI CHAR(8) NOT NULL UNIQUE,
    Nombres VARCHAR(60) NOT NULL,
    Apellidos VARCHAR(60) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Sexo CHAR(1) NOT NULL CHECK (Sexo IN ('M','F')),
    Telefono VARCHAR(9) NOT NULL,
    Direccion VARCHAR(150) NOT NULL,
    Email VARCHAR(100) NULL
);
GO

CREATE TABLE Citas (
    CitaID INT IDENTITY(1,1) PRIMARY KEY,
    PacienteID INT NOT NULL,
    MedicoID INT NOT NULL,
    FechaHora DATETIME NOT NULL,
    Estado VARCHAR(20) NOT NULL CHECK (Estado IN ('Programada','Atendida','Cancelada')),
    Motivo VARCHAR(200) NOT NULL,
    CONSTRAINT FK_Citas_Paciente FOREIGN KEY (PacienteID) REFERENCES Pacientes(PacienteID),
    CONSTRAINT FK_Citas_Medico FOREIGN KEY (MedicoID) REFERENCES Medicos(MedicoID)
);
GO

CREATE TABLE HistorialClinico (
    HistorialID INT IDENTITY(1,1) PRIMARY KEY,
    CitaID INT NOT NULL UNIQUE,
    Diagnostico VARCHAR(300) NOT NULL,
    Observaciones VARCHAR(300) NULL,
    FechaRegistro DATETIME NOT NULL,
    CONSTRAINT FK_Historial_Cita FOREIGN KEY (CitaID) REFERENCES Citas(CitaID)
);
GO

CREATE TABLE Insumos (
    InsumoID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(200) NULL,
    Stock INT NOT NULL CHECK (Stock >= 0),
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    UnidadMedida VARCHAR(20) NOT NULL
);
GO

CREATE TABLE Recetas (
    RecetaID INT IDENTITY(1,1) PRIMARY KEY,
    HistorialID INT NOT NULL UNIQUE,
    FechaEmision DATETIME NOT NULL,
    Indicaciones VARCHAR(300) NOT NULL,
    CONSTRAINT FK_Recetas_Historial FOREIGN KEY (HistorialID) REFERENCES HistorialClinico(HistorialID)
);
GO

CREATE TABLE DetalleReceta (
    DetalleRecetaID INT IDENTITY(1,1) PRIMARY KEY,
    RecetaID INT NOT NULL,
    InsumoID INT NOT NULL,
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    Dosis VARCHAR(100) NOT NULL,
    CONSTRAINT FK_DetalleReceta_Receta FOREIGN KEY (RecetaID) REFERENCES Recetas(RecetaID),
    CONSTRAINT FK_DetalleReceta_Insumo FOREIGN KEY (InsumoID) REFERENCES Insumos(InsumoID)
);
GO

CREATE TABLE Facturas (
    FacturaID INT IDENTITY(1,1) PRIMARY KEY,
    CitaID INT NOT NULL UNIQUE,
    Serie CHAR(4) NOT NULL,
    Correlativo VARCHAR(8) NOT NULL,
    FechaEmision DATETIME NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    IGV DECIMAL(10,2) NOT NULL,
    Total DECIMAL(10,2) NOT NULL,
    MetodoPago VARCHAR(20) NOT NULL CHECK (MetodoPago IN ('Efectivo','Tarjeta','Yape/Plin','Transferencia')),
    Estado VARCHAR(20) NOT NULL DEFAULT 'Pagada' CHECK (Estado IN ('Pagada','Anulada')),
    CONSTRAINT FK_Facturas_Cita FOREIGN KEY (CitaID) REFERENCES Citas(CitaID)
);
GO

CREATE TABLE DetalleFactura (
    DetalleFacturaID INT IDENTITY(1,1) PRIMARY KEY,
    FacturaID INT NOT NULL,
    Descripcion VARCHAR(150) NOT NULL,
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_DetalleFactura_Factura FOREIGN KEY (FacturaID) REFERENCES Facturas(FacturaID)
);
GO

-- ============================================================
-- 2. DATOS DE PRUEBA (SEED DATA) - mínimo 30 filas por tabla
-- ============================================================

-- 2.1 Especialidades (30)
INSERT INTO Especialidades (Nombre) VALUES
('Medicina General'),
('Pediatría'),
('Ginecología'),
('Cardiología'),
('Dermatología'),
('Neurología'),
('Traumatología'),
('Oftalmología'),
('Otorrinolaringología'),
('Endocrinología'),
('Gastroenterología'),
('Urología'),
('Psiquiatría'),
('Psicología'),
('Odontología'),
('Nutrición'),
('Terapia Física y Rehabilitación'),
('Reumatología'),
('Nefrología'),
('Neumología'),
('Alergología e Inmunología'),
('Hematología'),
('Oncología'),
('Infectología'),
('Geriatría'),
('Medicina Familiar'),
('Anestesiología'),
('Radiología'),
('Cirugía General'),
('Medicina Interna');
GO

-- 2.2 Medicos (30)
INSERT INTO Medicos (CMP, Nombres, Apellidos, EspecialidadID, Telefono, Email, FechaIngreso) VALUES
('39256', 'Carlos Gustavo', 'Marín Guevara', 5, '918196001', 'carlos.marín0@centromedico.pe', '2018-04-17'),
('38893', 'Edgar Manuel', 'Ocas Bringas', 15, '994026542', 'edgar.ocas1@centromedico.pe', '2018-06-04'),
('89131', 'Víctor Miguel', 'Salazar Salazar', 9, '907816184', 'víctor.salazar2@centromedico.pe', '2025-10-28'),
('39871', 'Isabel Elena', 'Cueva Chávez', 25, '941316475', 'isabel.cueva3@centromedico.pe', '2017-06-12'),
('80010', 'Marco Ricardo', 'Cueva Bardales', 24, '932764835', 'marco.cueva4@centromedico.pe', '2015-04-27'),
('18675', 'César Raúl', 'Chilón Marín', 7, '995376724', 'césar.chilón5@centromedico.pe', '2017-04-24'),
('57447', 'Lucía Isabel', 'Horna Chilón', 8, '928710122', 'lucía.horna6@centromedico.pe', '2025-07-20'),
('42953', 'Víctor Víctor', 'León Plasencia', 18, '901845146', 'víctor.león7@centromedico.pe', '2017-08-01'),
('23947', 'Beatriz Deysi', 'Alcántara Rimarachín', 28, '948932528', 'beatriz.alcántara8@centromedico.pe', '2023-01-20'),
('50306', 'Mercedes María', 'Mendoza Bazán', 8, '903911718', 'mercedes.mendoza9@centromedico.pe', '2017-03-22'),
('89507', 'Cecilia Luz', 'Silva Plasencia', 14, '938346578', 'cecilia.silva10@centromedico.pe', '2022-02-08'),
('40161', 'José Raúl', 'Sánchez Yopla', 19, '930103105', 'josé.sánchez11@centromedico.pe', '2016-09-08'),
('27342', 'Karina Mercedes', 'Quispe Ocas', 24, '999737631', 'karina.quispe12@centromedico.pe', '2016-11-14'),
('22899', 'Doris Doris', 'León Cabanillas', 2, '965133387', 'doris.león13@centromedico.pe', '2017-07-06'),
('82132', 'Nélida Patricia', 'Cueva Saldaña', 4, '908013267', 'nélida.cueva14@centromedico.pe', '2022-04-28'),
('10282', 'Judith Rosa', 'Bardales Malca', 13, '947468723', 'judith.bardales15@centromedico.pe', '2019-04-02'),
('86569', 'Gustavo Raúl', 'Cabanillas Cabanillas', 16, '988208121', 'gustavo.cabanillas16@centromedico.pe', '2024-02-22'),
('20745', 'Víctor Miguel', 'Guevara Chávez', 14, '999854353', 'víctor.guevara17@centromedico.pe', '2019-07-05'),
('70068', 'Nélida Flor', 'Cueva Vera', 20, '991183842', 'nélida.cueva18@centromedico.pe', '2020-02-08'),
('49651', 'Gladys Luz', 'Saldaña Ocas', 20, '980841241', 'gladys.saldaña19@centromedico.pe', '2016-12-18'),
('36685', 'Ricardo Alberto', 'Quispe Villanueva', 22, '948740164', 'ricardo.quispe20@centromedico.pe', '2015-01-11'),
('82309', 'Hugo Ricardo', 'Bardales Saldaña', 23, '968011280', 'hugo.bardales21@centromedico.pe', '2020-10-18'),
('57795', 'Eduardo Jorge', 'Chávez Tello', 29, '905331586', 'eduardo.chávez22@centromedico.pe', '2024-12-05'),
('13248', 'Walter Pedro', 'Alcántara Bringas', 6, '956342160', 'walter.alcántara23@centromedico.pe', '2022-04-07'),
('13101', 'Yolanda Gladys', 'Díaz Díaz', 22, '936541458', 'yolanda.díaz24@centromedico.pe', '2021-11-27'),
('86099', 'María Ana', 'Silva Alcántara', 9, '901965569', 'maría.silva25@centromedico.pe', '2023-02-13'),
('78146', 'Ricardo Luis', 'Horna Vera', 30, '983561595', 'ricardo.horna26@centromedico.pe', '2025-02-24'),
('62743', 'Beatriz Gladys', 'Bringas Benavides', 23, '948236629', 'beatriz.bringas27@centromedico.pe', '2024-05-13'),
('86019', 'Alberto Alberto', 'Quispe Horna', 20, '957773872', 'alberto.quispe28@centromedico.pe', '2025-02-10'),
('39444', 'Carmen Consuelo', 'Guevara Tello', 26, '932003791', 'carmen.guevara29@centromedico.pe', '2022-07-21');
GO

-- 2.3 Pacientes (30)
INSERT INTO Pacientes (DNI, Nombres, Apellidos, FechaNacimiento, Sexo, Telefono, Direccion, Email) VALUES
('63640499', 'Iván Iván', 'Malca Rabanal', '1965-03-21', 'M', '901632870', 'Jr. Junín 355, Cajamarca', 'iván0@gmail.com'),
('52587010', 'Mario Jorge', 'León Plasencia', '1998-08-20', 'M', '986872774', 'Jr. Del Comercio 960, Cajamarca', 'mario1@gmail.com'),
('42111036', 'Deysi Deysi', 'Plasencia Rabanal', '1967-08-03', 'F', '943455812', 'Av. Hoyos Rubio 336, Cajamarca', 'deysi2@gmail.com'),
('65682626', 'Milagros Juana', 'Quispe Cueva', '1976-06-18', 'F', '976036690', 'Psje. Los Pinos 489, Cajamarca', 'milagros3@gmail.com'),
('66240084', 'María Yolanda', 'Tello Malca', '1984-12-24', 'F', '989373467', 'Jr. Amazonas 498, Cajamarca', 'maría4@gmail.com'),
('72732043', 'Karina Karina', 'Chilón Bardales', '1958-10-18', 'F', '906990162', 'Av. Independencia 286, Cajamarca', 'karina5@gmail.com'),
('71028710', 'Ricardo Víctor', 'Benavides Quispe', '1970-06-25', 'M', '964641708', 'Jr. Amazonas 458, Cajamarca', 'ricardo6@gmail.com'),
('43189803', 'Hugo José', 'Chávez Sánchez', '1962-01-20', 'M', '923271937', 'Av. Atahualpa 885, Cajamarca', 'hugo7@gmail.com'),
('51746937', 'Luz Teresa', 'Mendoza Bardales', '1956-10-01', 'F', '949663193', 'Jr. Cruz de Piedra 813, Cajamarca', 'luz8@gmail.com'),
('56600900', 'Marisol Karina', 'Mendoza Chávez', '1984-07-22', 'F', '951850671', 'Jr. San Martín 470, Cajamarca', 'marisol9@gmail.com'),
('46249845', 'Milagros Juana', 'Horna Alcántara', '1989-09-25', 'F', '977694531', 'Av. Atahualpa 561, Cajamarca', 'milagros10@gmail.com'),
('13852048', 'Rubén Mario', 'Malca Villanueva', '1981-06-06', 'M', '973545494', 'Jr. Junín 110, Cajamarca', 'rubén11@gmail.com'),
('42255732', 'José Fernando', 'Bringas Rabanal', '1994-08-21', 'M', '977014363', 'Av. Atahualpa 779, Cajamarca', 'josé12@gmail.com'),
('67110154', 'Mercedes Cecilia', 'Plasencia Salazar', '1997-09-11', 'F', '957444313', 'Jr. Apurímac 222, Cajamarca', 'mercedes13@gmail.com'),
('47983442', 'Manuel Manuel', 'Cabrera Marín', '1956-04-10', 'M', '935240824', 'Jr. Amazonas 155, Cajamarca', 'manuel14@gmail.com'),
('11646234', 'Milagros Juana', 'Rabanal Rojas', '1986-05-16', 'F', '977520471', 'Jr. Cruz de Piedra 510, Cajamarca', 'milagros15@gmail.com'),
('30024960', 'Carmen Isabel', 'Cabanillas Terán', '1986-05-03', 'F', '931869993', 'Jr. Junín 489, Cajamarca', 'carmen16@gmail.com'),
('50987442', 'Vilma Nélida', 'Tello Horna', '1986-10-02', 'F', '991334123', 'Av. Hoyos Rubio 665, Cajamarca', 'vilma17@gmail.com'),
('73070585', 'Pedro Carlos', 'Bringas Saldaña', '1968-01-08', 'M', '944713493', 'Jr. San Martín 217, Cajamarca', 'pedro18@gmail.com'),
('19584466', 'Hugo Jorge', 'Marín Terán', '1953-03-26', 'M', '949947174', 'Jr. San Martín 378, Cajamarca', 'hugo19@gmail.com'),
('53261270', 'Nélida Carmen', 'Chávez Horna', '1988-05-01', 'F', '913990490', 'Av. Hoyos Rubio 581, Cajamarca', 'nélida20@gmail.com'),
('75998319', 'Vilma Silvia', 'Alcántara Horna', '1955-08-12', 'F', '965512567', 'Av. Atahualpa 778, Cajamarca', 'vilma21@gmail.com'),
('71045700', 'Consuelo Deysi', 'Yopla Chávez', '1955-06-09', 'F', '951680876', 'Jr. Amazonas 292, Cajamarca', 'consuelo22@gmail.com'),
('16927215', 'Teresa Deysi', 'Rabanal Saldaña', '1963-05-18', 'F', '924771093', 'Av. Hoyos Rubio 418, Cajamarca', 'teresa23@gmail.com'),
('25228493', 'Edgar Eduardo', 'Vásquez Díaz', '1979-02-21', 'M', '927484677', 'Jr. Del Comercio 567, Cajamarca', 'edgar24@gmail.com'),
('19369750', 'Víctor Manuel', 'Rimarachín Huamán', '1967-07-11', 'M', '984044997', 'Av. Hoyos Rubio 557, Cajamarca', 'víctor25@gmail.com'),
('60628276', 'Yolanda Flor', 'Yopla Ocas', '1979-06-28', 'F', '933963605', 'Av. Independencia 822, Cajamarca', 'yolanda26@gmail.com'),
('14968688', 'Susana Karina', 'Terán Rabanal', '1958-09-19', 'F', '951718702', 'Jr. San Martín 991, Cajamarca', 'susana27@gmail.com'),
('63349308', 'José Segundo', 'Silva Villanueva', '1991-02-28', 'M', '958657809', 'Jr. Cruz de Piedra 340, Cajamarca', 'josé28@gmail.com'),
('23212812', 'Patricia Lucía', 'Vásquez Horna', '1998-11-23', 'F', '917240050', 'Av. Atahualpa 467, Cajamarca', 'patricia29@gmail.com');
GO

-- 2.4 Citas (30) - todas cerradas como 'Atendida' para generar el flujo completo
INSERT INTO Citas (PacienteID, MedicoID, FechaHora, Estado, Motivo) VALUES
(1, 12, '2026-07-05 11:45:00', 'Atendida', 'Control por dolor abdominal'),
(2, 19, '2026-03-06 10:00:00', 'Atendida', 'Chequeo general'),
(3, 20, '2026-07-20 11:45:00', 'Atendida', 'Control de embarazo'),
(4, 30, '2026-03-08 15:30:00', 'Atendida', 'Fiebre y malestar general'),
(5, 15, '2026-05-22 08:45:00', 'Atendida', 'Dolor de cabeza persistente'),
(6, 29, '2026-05-22 16:15:00', 'Atendida', 'Control de hipertensión'),
(7, 3, '2026-08-12 17:30:00', 'Atendida', 'Consulta por alergia cutánea'),
(8, 21, '2026-07-23 12:45:00', 'Atendida', 'Dolor lumbar'),
(9, 28, '2026-05-07 14:45:00', 'Atendida', 'Control post-operatorio'),
(10, 4, '2026-04-13 17:30:00', 'Atendida', 'Consulta pediátrica de rutina'),
(11, 19, '2026-05-23 12:00:00', 'Atendida', 'Dolor de garganta'),
(12, 27, '2026-07-09 08:00:00', 'Atendida', 'Control de diabetes'),
(13, 30, '2026-08-27 12:15:00', 'Atendida', 'Consulta dermatológica'),
(14, 20, '2026-06-08 11:30:00', 'Atendida', 'Evaluación cardiológica'),
(15, 22, '2026-03-21 09:00:00', 'Atendida', 'Consulta por ansiedad'),
(16, 10, '2026-08-02 17:30:00', 'Atendida', 'Control ginecológico'),
(17, 24, '2026-03-03 12:30:00', 'Atendida', 'Consulta traumatológica por caída'),
(18, 24, '2026-07-06 11:15:00', 'Atendida', 'Revisión odontológica'),
(19, 26, '2026-09-12 16:30:00', 'Atendida', 'Consulta nutricional'),
(20, 27, '2026-03-09 15:30:00', 'Atendida', 'Dolor articular'),
(21, 24, '2026-06-26 09:45:00', 'Atendida', 'Consulta oftalmológica'),
(22, 3, '2026-03-25 11:45:00', 'Atendida', 'Control de otitis'),
(23, 28, '2026-09-12 09:45:00', 'Atendida', 'Consulta por gastritis'),
(24, 1, '2026-05-18 09:45:00', 'Atendida', 'Evaluación neurológica'),
(25, 12, '2026-05-19 14:30:00', 'Atendida', 'Consulta por infección urinaria'),
(26, 4, '2026-04-16 08:30:00', 'Atendida', 'Control de asma'),
(27, 30, '2026-04-21 09:45:00', 'Atendida', 'Consulta por vértigo'),
(28, 30, '2026-05-21 14:00:00', 'Atendida', 'Evaluación geriátrica'),
(29, 5, '2026-01-02 12:45:00', 'Atendida', 'Consulta pre-quirúrgica'),
(30, 4, '2026-02-08 16:15:00', 'Atendida', 'Control de anemia');
GO

-- 2.5 HistorialClinico (30) - uno por cada Cita
INSERT INTO HistorialClinico (CitaID, Diagnostico, Observaciones, FechaRegistro) VALUES
(1, 'Gastritis crónica leve', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 1))),
(2, 'Hipertensión arterial controlada', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 2))),
(3, 'Faringoamigdalitis aguda', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 3))),
(4, 'Lumbalgia mecánica', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 4))),
(5, 'Dermatitis de contacto', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 5))),
(6, 'Migraña episódica', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 6))),
(7, 'Control prenatal sin complicaciones', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 7))),
(8, 'Diabetes mellitus tipo 2 compensada', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 8))),
(9, 'Otitis media aguda', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 9))),
(10, 'Ansiedad generalizada leve', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 10))),
(11, 'Infección de vías urinarias no complicada', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 11))),
(12, 'Asma bronquial leve intermitente', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 12))),
(13, 'Anemia ferropénica leve', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 13))),
(14, 'Conjuntivitis alérgica', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 14))),
(15, 'Esguince de tobillo grado I', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 15))),
(16, 'Rinitis alérgica estacional', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 16))),
(17, 'Cefalea tensional', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 17))),
(18, 'Gastroenteritis viral', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 18))),
(19, 'Contusión lumbar leve', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 19))),
(20, 'Vértigo posicional benigno', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 20))),
(21, 'Caries dental múltiple', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 21))),
(22, 'Sobrepeso, plan nutricional indicado', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 22))),
(23, 'Artralgia de rodilla', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 23))),
(24, 'Hipotiroidismo subclínico', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 24))),
(25, 'Bronquitis aguda', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 25))),
(26, 'Cervicalgia mecánica', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 26))),
(27, 'Cistitis aguda', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 27))),
(28, 'Dermatitis atópica leve', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 28))),
(29, 'Reflujo gastroesofágico', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 29))),
(30, 'Evaluación pre-quirúrgica sin hallazgos', 'Paciente estable, se indica tratamiento y control en 15 días.', DATEADD(MINUTE, 30, (SELECT FechaHora FROM Citas WHERE CitaID = 30)));
GO

-- 2.6 Insumos (30)
INSERT INTO Insumos (Nombre, Descripcion, Stock, PrecioUnitario, UnidadMedida) VALUES
('Paracetamol 500mg', 'Analgésico/antipirético', 500, 0.2, 'tableta'),
('Ibuprofeno 400mg', 'Antiinflamatorio', 400, 0.3, 'tableta'),
('Amoxicilina 500mg', 'Antibiótico', 300, 0.5, 'cápsula'),
('Omeprazol 20mg', 'Antiulceroso', 350, 0.25, 'cápsula'),
('Loratadina 10mg', 'Antihistamínico', 250, 0.2, 'tableta'),
('Suero fisiológico 500ml', 'Solución IV', 150, 3.5, 'frasco'),
('Jeringa 5ml', 'Material descartable', 1000, 0.3, 'unidad'),
('Guantes de látex', 'Material de bioseguridad', 2000, 0.15, 'unidad'),
('Alcohol en gel 500ml', 'Antiséptico', 200, 6.0, 'frasco'),
('Gasas estériles', 'Material de curación', 800, 0.1, 'unidad'),
('Esparadrapo', 'Material de curación', 300, 2.5, 'rollo'),
('Vacuna antitetánica', 'Inmunización', 100, 8.0, 'dosis'),
('Insulina NPH', 'Antidiabético', 80, 25.0, 'frasco'),
('Metformina 850mg', 'Antidiabético', 300, 0.2, 'tableta'),
('Losartán 50mg', 'Antihipertensivo', 300, 0.25, 'tableta'),
('Salbutamol inhalador', 'Broncodilatador', 120, 15.0, 'unidad'),
('Diclofenaco 75mg inyectable', 'Antiinflamatorio', 200, 1.5, 'ampolla'),
('Dexametasona inyectable', 'Corticoide', 150, 2.0, 'ampolla'),
('Vendas elásticas', 'Material de curación', 300, 3.0, 'unidad'),
('Termómetro digital', 'Equipo médico', 50, 12.0, 'unidad'),
('Tensiómetro digital', 'Equipo médico', 20, 80.0, 'unidad'),
('Mascarillas quirúrgicas', 'Material de bioseguridad', 3000, 0.2, 'unidad'),
('Algodón hidrófilo', 'Material de curación', 400, 1.0, 'paquete'),
('Yodopovidona', 'Antiséptico', 180, 4.5, 'frasco'),
('Ranitidina 150mg', 'Antiulceroso', 250, 0.2, 'tableta'),
('Cetirizina 10mg', 'Antihistamínico', 250, 0.2, 'tableta'),
('Ácido fólico 5mg', 'Suplemento', 300, 0.15, 'tableta'),
('Sulfato ferroso', 'Suplemento', 300, 0.2, 'tableta'),
('Naproxeno 500mg', 'Antiinflamatorio', 280, 0.3, 'tableta'),
('Azitromicina 500mg', 'Antibiótico', 200, 1.2, 'tableta');
GO

-- 2.7 Recetas (30) - una por cada HistorialClinico
INSERT INTO Recetas (HistorialID, FechaEmision, Indicaciones) VALUES
(1, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 1), 'Tomar cada 8 horas por 5 días, con alimentos.'),
(2, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 2), 'Aplicar según indicación médica, control en 1 semana.'),
(3, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 3), 'Tomar cada 12 horas por 7 días.'),
(4, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 4), 'Uso tópico 2 veces al día por 10 días.'),
(5, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 5), 'Tomar en ayunas por 30 días.'),
(6, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 6), 'Reposo relativo y tomar según indicación.'),
(7, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 7), 'Continuar tratamiento habitual, control mensual.'),
(8, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 8), 'Tomar cada 24 horas por 5 días.'),
(9, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 9), 'Aplicar frío local y tomar analgésico si hay dolor.'),
(10, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 10), 'Tomar 1 tableta antes de dormir por 15 días.'),
(11, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 11), 'Tomar cada 8 horas por 5 días, con alimentos.'),
(12, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 12), 'Aplicar según indicación médica, control en 1 semana.'),
(13, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 13), 'Tomar cada 12 horas por 7 días.'),
(14, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 14), 'Uso tópico 2 veces al día por 10 días.'),
(15, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 15), 'Tomar en ayunas por 30 días.'),
(16, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 16), 'Reposo relativo y tomar según indicación.'),
(17, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 17), 'Continuar tratamiento habitual, control mensual.'),
(18, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 18), 'Tomar cada 24 horas por 5 días.'),
(19, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 19), 'Aplicar frío local y tomar analgésico si hay dolor.'),
(20, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 20), 'Tomar 1 tableta antes de dormir por 15 días.'),
(21, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 21), 'Tomar cada 8 horas por 5 días, con alimentos.'),
(22, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 22), 'Aplicar según indicación médica, control en 1 semana.'),
(23, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 23), 'Tomar cada 12 horas por 7 días.'),
(24, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 24), 'Uso tópico 2 veces al día por 10 días.'),
(25, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 25), 'Tomar en ayunas por 30 días.'),
(26, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 26), 'Reposo relativo y tomar según indicación.'),
(27, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 27), 'Continuar tratamiento habitual, control mensual.'),
(28, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 28), 'Tomar cada 24 horas por 5 días.'),
(29, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 29), 'Aplicar frío local y tomar analgésico si hay dolor.'),
(30, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 30), 'Tomar 1 tableta antes de dormir por 15 días.');
GO

-- 2.8 DetalleReceta (60 - 2 insumos por receta)
INSERT INTO DetalleReceta (RecetaID, InsumoID, Cantidad, Dosis) VALUES
(1, 13, 12, '1 ampolla cada 24h'),
(1, 15, 14, '1 ampolla cada 24h'),
(2, 24, 14, '1 tableta cada 8h'),
(2, 5, 16, '1 ampolla cada 24h'),
(3, 14, 2, '1 cápsula cada 24h'),
(3, 9, 7, 'Aplicar 2 veces al día'),
(4, 15, 12, '1 tableta cada 8h'),
(4, 8, 12, '1 ampolla cada 24h'),
(5, 29, 12, '1 tableta cada 8h'),
(5, 21, 13, '1 cápsula cada 24h'),
(6, 7, 15, '1 tableta cada 8h'),
(6, 4, 7, '1 ampolla cada 24h'),
(7, 1, 11, '1 tableta cada 12h'),
(7, 2, 5, '1 ampolla cada 24h'),
(8, 7, 18, '1 tableta cada 12h'),
(8, 3, 19, '1 tableta cada 12h'),
(9, 27, 8, '1 cápsula cada 24h'),
(9, 28, 5, '1 ampolla cada 24h'),
(10, 1, 5, '1 tableta cada 12h'),
(10, 9, 18, '1 cápsula cada 24h'),
(11, 26, 4, '1 tableta cada 8h'),
(11, 6, 5, '1 tableta cada 8h'),
(12, 12, 8, '1 ampolla cada 24h'),
(12, 26, 11, '1 tableta cada 8h'),
(13, 6, 2, '1 tableta cada 12h'),
(13, 9, 14, '1 ampolla cada 24h'),
(14, 4, 3, 'Aplicar 2 veces al día'),
(14, 24, 15, '1 cápsula cada 24h'),
(15, 17, 4, 'Aplicar 2 veces al día'),
(15, 19, 17, '1 tableta cada 12h'),
(16, 20, 17, '1 cápsula cada 24h'),
(16, 2, 15, '1 tableta cada 8h'),
(17, 2, 13, 'Aplicar 2 veces al día'),
(17, 16, 4, 'Aplicar 2 veces al día'),
(18, 23, 15, '1 tableta cada 8h'),
(18, 30, 3, '1 cápsula cada 24h'),
(19, 20, 3, '1 tableta cada 12h'),
(19, 5, 9, '1 ampolla cada 24h'),
(20, 21, 18, '1 cápsula cada 24h'),
(20, 19, 13, '1 ampolla cada 24h'),
(21, 17, 15, '1 ampolla cada 24h'),
(21, 10, 20, 'Aplicar 2 veces al día'),
(22, 4, 4, '1 ampolla cada 24h'),
(22, 26, 7, 'Aplicar 2 veces al día'),
(23, 15, 8, 'Aplicar 2 veces al día'),
(23, 29, 11, 'Aplicar 2 veces al día'),
(24, 13, 4, '1 cápsula cada 24h'),
(24, 14, 14, '1 cápsula cada 24h'),
(25, 22, 12, '1 tableta cada 12h'),
(25, 9, 16, '1 tableta cada 8h'),
(26, 3, 3, '1 tableta cada 8h'),
(26, 27, 14, '1 tableta cada 8h'),
(27, 24, 5, '1 ampolla cada 24h'),
(27, 12, 2, '1 ampolla cada 24h'),
(28, 18, 4, 'Aplicar 2 veces al día'),
(28, 11, 12, 'Aplicar 2 veces al día'),
(29, 28, 2, '1 cápsula cada 24h'),
(29, 30, 20, '1 cápsula cada 24h'),
(30, 12, 19, '1 ampolla cada 24h'),
(30, 4, 7, '1 tableta cada 12h');
GO

-- 2.9 Facturas (30) - una por Cita, Serie tipo boleta electrónica
INSERT INTO Facturas (CitaID, Serie, Correlativo, FechaEmision, Subtotal, IGV, Total, MetodoPago, Estado) VALUES
(1, 'B001', '00000001', '2026-04-28 09:30:00', 131.94, 23.75, 155.69, 'Yape/Plin', 'Pagada'),
(2, 'B001', '00000002', '2026-06-04 12:30:00', 158.35, 28.5, 186.85, 'Tarjeta', 'Pagada'),
(3, 'B001', '00000003', '2026-09-25 17:30:00', 153.01, 27.54, 180.55, 'Efectivo', 'Pagada'),
(4, 'B001', '00000004', '2026-05-01 10:30:00', 125.26, 22.55, 147.81, 'Yape/Plin', 'Pagada'),
(5, 'B001', '00000005', '2026-05-11 13:30:00', 138.38, 24.91, 163.29, 'Efectivo', 'Pagada'),
(6, 'B001', '00000006', '2026-03-19 14:30:00', 65.4, 11.77, 77.17, 'Efectivo', 'Pagada'),
(7, 'B001', '00000007', '2026-01-03 16:30:00', 59.86, 10.77, 70.63, 'Tarjeta', 'Pagada'),
(8, 'B001', '00000008', '2026-08-11 10:30:00', 92.67, 16.68, 109.35, 'Yape/Plin', 'Pagada'),
(9, 'B001', '00000009', '2026-06-25 17:30:00', 83.63, 15.05, 98.68, 'Efectivo', 'Pagada'),
(10, 'B001', '00000010', '2026-03-06 17:30:00', 163.67, 29.46, 193.13, 'Efectivo', 'Pagada'),
(11, 'B001', '00000011', '2026-05-15 14:30:00', 134.36, 24.18, 158.54, 'Transferencia', 'Pagada'),
(12, 'B001', '00000012', '2026-07-09 11:30:00', 124.99, 22.5, 147.49, 'Efectivo', 'Pagada'),
(13, 'B001', '00000013', '2026-02-10 17:30:00', 88.32, 15.9, 104.22, 'Transferencia', 'Pagada'),
(14, 'B001', '00000014', '2026-05-02 11:30:00', 113.77, 20.48, 134.25, 'Transferencia', 'Pagada'),
(15, 'B001', '00000015', '2026-01-01 11:30:00', 177.82, 32.01, 209.83, 'Yape/Plin', 'Pagada'),
(16, 'B001', '00000016', '2026-03-25 12:30:00', 172.35, 31.02, 203.37, 'Yape/Plin', 'Pagada'),
(17, 'B001', '00000017', '2026-01-16 14:30:00', 85.94, 15.47, 101.41, 'Tarjeta', 'Pagada'),
(18, 'B001', '00000018', '2026-09-23 11:30:00', 58.09, 10.46, 68.55, 'Yape/Plin', 'Pagada'),
(19, 'B001', '00000019', '2026-01-14 08:30:00', 50.09, 9.02, 59.11, 'Transferencia', 'Pagada'),
(20, 'B001', '00000020', '2026-06-19 14:30:00', 168.96, 30.41, 199.37, 'Transferencia', 'Pagada'),
(21, 'B001', '00000021', '2026-07-10 09:30:00', 139.33, 25.08, 164.41, 'Transferencia', 'Pagada'),
(22, 'B001', '00000022', '2026-06-06 17:30:00', 42.92, 7.73, 50.65, 'Transferencia', 'Pagada'),
(23, 'B001', '00000023', '2026-06-03 14:30:00', 156.48, 28.17, 184.65, 'Efectivo', 'Pagada'),
(24, 'B001', '00000024', '2026-07-17 09:30:00', 74.06, 13.33, 87.39, 'Transferencia', 'Pagada'),
(25, 'B001', '00000025', '2026-06-08 13:30:00', 161.87, 29.14, 191.01, 'Tarjeta', 'Pagada'),
(26, 'B001', '00000026', '2026-02-17 16:30:00', 50.69, 9.12, 59.81, 'Tarjeta', 'Pagada'),
(27, 'B001', '00000027', '2026-06-12 10:30:00', 166.83, 30.03, 196.86, 'Tarjeta', 'Pagada'),
(28, 'B001', '00000028', '2026-05-07 10:30:00', 54.39, 9.79, 64.18, 'Tarjeta', 'Pagada'),
(29, 'B001', '00000029', '2026-02-06 15:30:00', 146.43, 26.36, 172.79, 'Transferencia', 'Pagada'),
(30, 'B001', '00000030', '2026-08-22 17:30:00', 145.62, 26.21, 171.83, 'Yape/Plin', 'Pagada');
GO

-- 2.10 DetalleFactura (60 - línea de consulta + línea de insumos por factura)
INSERT INTO DetalleFactura (FacturaID, Descripcion, Cantidad, PrecioUnitario, Subtotal) VALUES
(1, 'Consulta médica especializada', 1, 92.36, 92.36),
(1, 'Insumos y medicamentos recetados', 1, 39.58, 39.58),
(2, 'Consulta médica especializada', 1, 110.84, 110.84),
(2, 'Insumos y medicamentos recetados', 1, 47.51, 47.51),
(3, 'Consulta médica especializada', 1, 107.11, 107.11),
(3, 'Insumos y medicamentos recetados', 1, 45.9, 45.9),
(4, 'Consulta médica especializada', 1, 87.68, 87.68),
(4, 'Insumos y medicamentos recetados', 1, 37.58, 37.58),
(5, 'Consulta médica especializada', 1, 96.87, 96.87),
(5, 'Insumos y medicamentos recetados', 1, 41.51, 41.51),
(6, 'Consulta médica especializada', 1, 45.78, 45.78),
(6, 'Insumos y medicamentos recetados', 1, 19.62, 19.62),
(7, 'Consulta médica especializada', 1, 41.9, 41.9),
(7, 'Insumos y medicamentos recetados', 1, 17.96, 17.96),
(8, 'Consulta médica especializada', 1, 64.87, 64.87),
(8, 'Insumos y medicamentos recetados', 1, 27.8, 27.8),
(9, 'Consulta médica especializada', 1, 58.54, 58.54),
(9, 'Insumos y medicamentos recetados', 1, 25.09, 25.09),
(10, 'Consulta médica especializada', 1, 114.57, 114.57),
(10, 'Insumos y medicamentos recetados', 1, 49.1, 49.1),
(11, 'Consulta médica especializada', 1, 94.05, 94.05),
(11, 'Insumos y medicamentos recetados', 1, 40.31, 40.31),
(12, 'Consulta médica especializada', 1, 87.49, 87.49),
(12, 'Insumos y medicamentos recetados', 1, 37.5, 37.5),
(13, 'Consulta médica especializada', 1, 61.82, 61.82),
(13, 'Insumos y medicamentos recetados', 1, 26.5, 26.5),
(14, 'Consulta médica especializada', 1, 79.64, 79.64),
(14, 'Insumos y medicamentos recetados', 1, 34.13, 34.13),
(15, 'Consulta médica especializada', 1, 124.47, 124.47),
(15, 'Insumos y medicamentos recetados', 1, 53.35, 53.35),
(16, 'Consulta médica especializada', 1, 120.64, 120.64),
(16, 'Insumos y medicamentos recetados', 1, 51.71, 51.71),
(17, 'Consulta médica especializada', 1, 60.16, 60.16),
(17, 'Insumos y medicamentos recetados', 1, 25.78, 25.78),
(18, 'Consulta médica especializada', 1, 40.66, 40.66),
(18, 'Insumos y medicamentos recetados', 1, 17.43, 17.43),
(19, 'Consulta médica especializada', 1, 35.06, 35.06),
(19, 'Insumos y medicamentos recetados', 1, 15.03, 15.03),
(20, 'Consulta médica especializada', 1, 118.27, 118.27),
(20, 'Insumos y medicamentos recetados', 1, 50.69, 50.69),
(21, 'Consulta médica especializada', 1, 97.53, 97.53),
(21, 'Insumos y medicamentos recetados', 1, 41.8, 41.8),
(22, 'Consulta médica especializada', 1, 30.04, 30.04),
(22, 'Insumos y medicamentos recetados', 1, 12.88, 12.88),
(23, 'Consulta médica especializada', 1, 109.54, 109.54),
(23, 'Insumos y medicamentos recetados', 1, 46.94, 46.94),
(24, 'Consulta médica especializada', 1, 51.84, 51.84),
(24, 'Insumos y medicamentos recetados', 1, 22.22, 22.22),
(25, 'Consulta médica especializada', 1, 113.31, 113.31),
(25, 'Insumos y medicamentos recetados', 1, 48.56, 48.56),
(26, 'Consulta médica especializada', 1, 35.48, 35.48),
(26, 'Insumos y medicamentos recetados', 1, 15.21, 15.21),
(27, 'Consulta médica especializada', 1, 116.78, 116.78),
(27, 'Insumos y medicamentos recetados', 1, 50.05, 50.05),
(28, 'Consulta médica especializada', 1, 38.07, 38.07),
(28, 'Insumos y medicamentos recetados', 1, 16.32, 16.32),
(29, 'Consulta médica especializada', 1, 102.5, 102.5),
(29, 'Insumos y medicamentos recetados', 1, 43.93, 43.93),
(30, 'Consulta médica especializada', 1, 101.93, 101.93),
(30, 'Insumos y medicamentos recetados', 1, 43.69, 43.69);
GO
