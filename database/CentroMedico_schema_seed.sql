/* ============================================================
   Sistema de Gestión - Clínica Limatambo Cajamarca
   Base de datos: CentroMedicoDB
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
    FechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    Activo BIT NOT NULL DEFAULT 1,
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
    Email VARCHAR(100) NULL,
    FechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    Activo BIT NOT NULL DEFAULT 1
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
    UnidadMedida VARCHAR(20) NOT NULL,
    FechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    Activo BIT NOT NULL DEFAULT 1
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

-- Kardex de insumos: registra cada entrada/salida de stock con su referencia de origen
CREATE TABLE MovimientosInsumo (
    MovimientoID INT IDENTITY(1,1) PRIMARY KEY,
    InsumoID INT NOT NULL,
    TipoMovimiento VARCHAR(10) NOT NULL CHECK (TipoMovimiento IN ('Entrada','Salida')),
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    StockAnterior INT NOT NULL,
    StockNuevo INT NOT NULL,
    Motivo VARCHAR(150) NOT NULL,
    ReferenciaDetalleRecetaID INT NULL,
    FechaMovimiento DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Movimientos_Insumo FOREIGN KEY (InsumoID) REFERENCES Insumos(InsumoID),
    CONSTRAINT FK_Movimientos_DetalleReceta FOREIGN KEY (ReferenciaDetalleRecetaID) REFERENCES DetalleReceta(DetalleRecetaID)
);
GO

CREATE TABLE Facturas (
    FacturaID INT IDENTITY(1,1) PRIMARY KEY,
    CitaID INT NOT NULL,
    Serie CHAR(4) NOT NULL,
    Correlativo VARCHAR(8) NOT NULL,
    FechaEmision DATETIME NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    IGV DECIMAL(10,2) NOT NULL,
    Total DECIMAL(10,2) NOT NULL,
    MetodoPago VARCHAR(20) NOT NULL CHECK (MetodoPago IN ('Efectivo','Tarjeta','Yape/Plin','Transferencia')),
    Estado VARCHAR(20) NOT NULL DEFAULT 'Pagada' CHECK (Estado IN ('Pagada','Anulada')),
    CONSTRAINT FK_Facturas_Cita FOREIGN KEY (CitaID) REFERENCES Citas(CitaID),
    CONSTRAINT UQ_Facturas_Serie_Correlativo UNIQUE (Serie, Correlativo)
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
   
CREATE TABLE Usuarios (
    UsuarioID INT IDENTITY(1,1) PRIMARY KEY,
    NombreUsuario VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash CHAR(64) NOT NULL,
    Salt VARCHAR(32) NOT NULL,
    NombreCompleto VARCHAR(100) NOT NULL,
    Rol VARCHAR(30) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME NOT NULL DEFAULT GETDATE()
);
GO

INSERT INTO Usuarios (NombreUsuario, PasswordHash, Salt, NombreCompleto, Rol) VALUES
('admin', 'ccc9a3b080075a0f71dffc782492e7fce998fceb152635a445a35d4d2c8bb6ec', 'b4365c6436dd2f0c', 'Administrador del Sistema', 'Administrador'),
('doctor', 'ba978a7345aca5733f847cf26aee1b3bae8be76e1e6d933f764b915ae01d3a57', 'abcbaf2ec22f2822', 'Dr. Antony Vera', 'Medico');
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
INSERT INTO Medicos (CMP, Nombres, Apellidos, EspecialidadID, Telefono, Email, FechaIngreso, FechaCreacion, Activo) VALUES
('39256', 'Carlos Gustavo', 'Marín Guevara', 5, '918196001', 'carlos.marín0@centromedico.pe', '2018-04-17', DATEADD(DAY, -57, GETDATE()), 1),
('38893', 'Iván Hugo', 'Ocas Bringas', 15, '994026542', 'iván.ocas1@centromedico.pe', '2018-06-04', DATEADD(DAY, -124, GETDATE()), 1),
('15695', 'Ana Yolanda', 'Salazar Silva', 24, '978161849', 'ana.salazar2@centromedico.pe', '2020-10-07', DATEADD(DAY, -101, GETDATE()), 1),
('40512', 'Marco Fernando', 'Cotrina Vásquez', 28, '916475255', 'marco.cotrina3@centromedico.pe', '2018-11-09', DATEADD(DAY, -103, GETDATE()), 1),
('70589', 'Edgar Gustavo', 'Guevara Bardales', 13, '948350305', 'edgar.guevara4@centromedico.pe', '2021-05-03', DATEADD(DAY, -246, GETDATE()), 1),
('70142', 'Elena Norma', 'Rabanal Chilón', 5, '942388496', 'elena.rabanal5@centromedico.pe', '2024-07-12', DATEADD(DAY, -254, GETDATE()), 1),
('24371', 'Wilson Segundo', 'Vásquez Cabanillas', 5, '926916697', 'wilson.vásquez6@centromedico.pe', '2023-05-18', DATEADD(DAY, -41, GETDATE()), 1),
('54587', 'Marco Julio', 'Ocas Marín', 4, '946270482', 'marco.ocas7@centromedico.pe', '2023-02-28', DATEADD(DAY, -335, GETDATE()), 1),
('79514', 'Jorge Jaime', 'Bardales Ocas', 30, '909570154', 'jorge.bardales8@centromedico.pe', '2018-01-08', DATEADD(DAY, -110, GETDATE()), 1),
('26483', 'Gustavo Segundo', 'Cueva Ocas', 5, '978248963', 'gustavo.cueva9@centromedico.pe', '2023-12-23', DATEADD(DAY, -235, GETDATE()), 1),
('77839', 'Susana Karina', 'Bazán Saldaña', 15, '913315098', 'susana.bazán10@centromedico.pe', '2018-10-08', DATEADD(DAY, -37, GETDATE()), 1),
('18834', 'Iván Hugo', 'Cabanillas Díaz', 29, '905183473', 'iván.cabanillas11@centromedico.pe', '2023-03-24', DATEADD(DAY, -514, GETDATE()), 1),
('22363', 'César Segundo', 'Bringas Zorrilla', 4, '965667010', 'césar.bringas12@centromedico.pe', '2021-12-11', DATEADD(DAY, -141, GETDATE()), 1),
('28373', 'Manuel Manuel', 'Ocas Saldaña', 14, '924731781', 'manuel.ocas13@centromedico.pe', '2015-11-18', DATEADD(DAY, -45, GETDATE()), 1),
('63269', 'Oscar Rubén', 'Guevara Bardales', 16, '973602606', 'oscar.guevara14@centromedico.pe', '2019-08-10', DATEADD(DAY, -463, GETDATE()), 1),
('17665', 'Juana Elena', 'Cotrina Quispe', 19, '980500978', 'juana.cotrina15@centromedico.pe', '2023-03-02', DATEADD(DAY, -550, GETDATE()), 1),
('40828', 'Walter Pedro', 'Cueva Cueva', 13, '919399091', 'walter.cueva16@centromedico.pe', '2021-11-19', DATEADD(DAY, -565, GETDATE()), 1),
('41285', 'Vilma Silvia', 'Quispe Benavides', 9, '962475107', 'vilma.quispe17@centromedico.pe', '2024-10-04', DATEADD(DAY, -105, GETDATE()), 1),
('19016', 'Wilson Ricardo', 'Huamán Salazar', 29, '935427849', 'wilson.huamán18@centromedico.pe', '2025-09-01', DATEADD(DAY, -597, GETDATE()), 1),
('44664', 'Vilma Karina', 'Rojas Huamán', 4, '918244935', 'vilma.rojas19@centromedico.pe', '2018-11-21', DATEADD(DAY, -300, GETDATE()), 1),
('65518', 'Silvia Judith', 'Cabanillas Vásquez', 27, '940052427', 'silvia.cabanillas20@centromedico.pe', '2023-12-14', DATEADD(DAY, -39, GETDATE()), 1),
('14722', 'José Julio', 'Terán Ocas', 27, '959826204', 'josé.terán21@centromedico.pe', '2020-01-12', DATEADD(DAY, -245, GETDATE()), 1),
('63264', 'Marco Miguel', 'Salazar Yopla', 20, '923226025', 'marco.salazar22@centromedico.pe', '2021-11-28', DATEADD(DAY, -284, GETDATE()), 1),
('15075', 'Luz Edith', 'Rojas Malca', 28, '973375433', 'luz.rojas23@centromedico.pe', '2015-11-07', DATEADD(DAY, -438, GETDATE()), 1),
('56025', 'Silvia Marisol', 'Cueva Marín', 21, '986850142', 'silvia.cueva24@centromedico.pe', '2024-05-02', DATEADD(DAY, -141, GETDATE()), 1),
('89457', 'Yolanda Lucía', 'Benavides Horna', 17, '916934060', 'yolanda.benavides25@centromedico.pe', '2023-09-22', DATEADD(DAY, -231, GETDATE()), 1),
('26334', 'Doris Carmen', 'Villanueva Benavides', 24, '948465648', 'doris.villanueva26@centromedico.pe', '2017-04-14', DATEADD(DAY, -418, GETDATE()), 1),
('81819', 'Rolando Elmer', 'Tello Chilón', 27, '904436995', 'rolando.tello27@centromedico.pe', '2022-08-15', DATEADD(DAY, -248, GETDATE()), 1),
('47196', 'Edith Judith', 'Bardales Vásquez', 17, '995134332', 'edith.bardales28@centromedico.pe', '2015-01-08', DATEADD(DAY, -516, GETDATE()), 1),
('74799', 'Mario Eduardo', 'Zorrilla Malca', 13, '932016328', 'mario.zorrilla29@centromedico.pe', '2022-01-18', DATEADD(DAY, -285, GETDATE()), 0);
GO

-- 2.3 Pacientes (30)
INSERT INTO Pacientes (DNI, Nombres, Apellidos, FechaNacimiento, Sexo, Telefono, Direccion, Email, FechaCreacion, Activo) VALUES
('52587010', 'Mario Jorge', 'León Plasencia', '1998-08-20', 'M', '986872774', 'Jr. Del Comercio 960, Cajamarca', 'mario0@gmail.com', DATEADD(DAY, -313, GETDATE()), 1),
('20399639', 'Norma Patricia', 'Marín Saldaña', '1995-05-08', 'F', '945581223', 'Jr. San Martín 810, Cajamarca', 'norma1@gmail.com', DATEADD(DAY, -186, GETDATE()), 1),
('72535301', 'José Eduardo', 'Bringas Villanueva', '1976-01-07', 'M', '966909670', 'Jr. Apurímac 405, Cajamarca', 'josé2@gmail.com', DATEADD(DAY, -429, GETDATE()), 1),
('75529051', 'Cecilia Lucía', 'Ocas Díaz', '1964-05-14', 'F', '970656272', 'Psje. Los Pinos 646, Cajamarca', 'cecilia3@gmail.com', DATEADD(DAY, -57, GETDATE()), 1),
('67527432', 'Isabel Isabel', 'Sánchez Vásquez', '1958-08-06', 'F', '904653755', 'Jr. San Martín 384, Cajamarca', 'isabel4@gmail.com', DATEADD(DAY, -461, GETDATE()), 1),
('16990811', 'Consuelo Carmen', 'Cabrera Sánchez', '1972-04-21', 'F', '910033092', 'Jr. Del Comercio 229, Cajamarca', 'consuelo5@gmail.com', DATEADD(DAY, -514, GETDATE()), 1),
('59512272', 'Elmer Manuel', 'León Silva', '1960-10-20', 'M', '912419049', 'Jr. San Martín 506, Cajamarca', 'elmer6@gmail.com', DATEADD(DAY, -233, GETDATE()), 1),
('50477742', 'Elmer Iván', 'Guevara Rojas', '1993-10-26', 'M', '919058651', 'Jr. Junín 763, Cajamarca', 'elmer7@gmail.com', DATEADD(DAY, -379, GETDATE()), 1),
('68186525', 'Walter Eduardo', 'Rabanal Rojas', '1973-11-27', 'M', '972628498', 'Av. Independencia 576, Cajamarca', 'walter8@gmail.com', DATEADD(DAY, -476, GETDATE()), 1),
('47437115', 'Flor Marisol', 'Guevara Vásquez', '1978-04-25', 'F', '979965075', 'Av. Hoyos Rubio 599, Cajamarca', 'flor9@gmail.com', DATEADD(DAY, -247, GETDATE()), 1),
('47080140', 'Edith Silvia', 'Villanueva Marín', '1985-01-17', 'F', '931367837', 'Av. Independencia 558, Cajamarca', 'edith10@gmail.com', DATEADD(DAY, -47, GETDATE()), 1),
('51098277', 'Alberto Fernando', 'Chilón Guevara', '1992-10-12', 'M', '978856855', 'Av. Independencia 377, Cajamarca', 'alberto11@gmail.com', DATEADD(DAY, -343, GETDATE()), 1),
('26046365', 'Patricia Ana', 'Zorrilla Benavides', '1997-09-25', 'F', '923374989', 'Av. Atahualpa 202, Cajamarca', 'patricia12@gmail.com', DATEADD(DAY, -228, GETDATE()), 1),
('11898961', 'Patricia Yolanda', 'Alcántara Tello', '1995-09-05', 'F', '940084271', 'Jr. Amazonas 687, Cajamarca', 'patricia13@gmail.com', DATEADD(DAY, -321, GETDATE()), 1),
('16895666', 'Mercedes Nélida', 'Villanueva Alcántara', '1966-08-04', 'F', '916719022', 'Psje. Los Pinos 411, Cajamarca', 'mercedes14@gmail.com', DATEADD(DAY, -117, GETDATE()), 1),
('61053474', 'Miguel Edgar', 'Bringas Díaz', '1978-08-10', 'M', '996499091', 'Jr. Del Comercio 740, Cajamarca', 'miguel15@gmail.com', DATEADD(DAY, -246, GETDATE()), 1),
('33328859', 'Karina Carmen', 'Bardales Guevara', '1985-02-06', 'F', '906797403', 'Av. Atahualpa 823, Cajamarca', 'karina16@gmail.com', DATEADD(DAY, -319, GETDATE()), 1),
('36550845', 'Carmen Karina', 'Díaz Silva', '1977-02-18', 'F', '932421024', 'Psje. Los Pinos 866, Cajamarca', 'carmen17@gmail.com', DATEADD(DAY, -325, GETDATE()), 1),
('46540265', 'Ana Nélida', 'Tello Chilón', '1982-09-16', 'F', '971906594', 'Jr. Amazonas 193, Cajamarca', 'ana18@gmail.com', DATEADD(DAY, -264, GETDATE()), 1),
('33513701', 'Rubén Marco', 'Marín Chávez', '1980-09-21', 'M', '974296717', 'Jr. Apurímac 518, Cajamarca', 'rubén19@gmail.com', DATEADD(DAY, -371, GETDATE()), 1),
('65250068', 'Karina Ana', 'Bardales Villanueva', '1994-08-10', 'F', '968071545', 'Jr. Cruz de Piedra 891, Cajamarca', 'karina20@gmail.com', DATEADD(DAY, -443, GETDATE()), 1),
('65465150', 'Marco Walter', 'Ocas León', '1953-04-17', 'M', '959770348', 'Av. Hoyos Rubio 394, Cajamarca', 'marco21@gmail.com', DATEADD(DAY, -478, GETDATE()), 1),
('51708177', 'Ana María', 'Guevara Bardales', '1985-01-18', 'F', '961317127', 'Av. Atahualpa 621, Cajamarca', 'ana22@gmail.com', DATEADD(DAY, -309, GETDATE()), 1),
('71308842', 'Consuelo Mercedes', 'Cabrera Guevara', '1985-03-13', 'F', '939821465', 'Jr. Junín 373, Cajamarca', 'consuelo23@gmail.com', DATEADD(DAY, -32, GETDATE()), 1),
('69934576', 'Lucía Gladys', 'Rabanal Terán', '1984-08-12', 'F', '958867533', 'Psje. Los Pinos 492, Cajamarca', 'lucía24@gmail.com', DATEADD(DAY, -269, GETDATE()), 1),
('61818612', 'Rosa Flor', 'Cabrera Malca', '1992-11-05', 'F', '970289517', 'Jr. Cruz de Piedra 638, Cajamarca', 'rosa25@gmail.com', DATEADD(DAY, -497, GETDATE()), 1),
('20043277', 'Gustavo Jorge', 'Bringas Terán', '1980-05-11', 'M', '996158657', 'Jr. Junín 136, Cajamarca', 'gustavo26@gmail.com', DATEADD(DAY, -100, GETDATE()), 1),
('22130508', 'Hugo Marco', 'Cotrina Díaz', '1977-02-25', 'M', '917240050', 'Av. Atahualpa 467, Cajamarca', 'hugo27@gmail.com', DATEADD(DAY, -413, GETDATE()), 1),
('34166826', 'Juana Patricia', 'Plasencia Bringas', '1960-03-03', 'F', '996937923', 'Av. Independencia 753, Cajamarca', 'juana28@gmail.com', DATEADD(DAY, -290, GETDATE()), 1),
('48605268', 'Silvia Karina', 'Vera León', '1993-09-06', 'F', '917594647', 'Av. Atahualpa 303, Cajamarca', 'silvia29@gmail.com', DATEADD(DAY, -423, GETDATE()), 0);
GO

-- 2.4 Citas (30) - todas cerradas como 'Atendida' para generar el flujo completo
INSERT INTO Citas (PacienteID, MedicoID, FechaHora, Estado, Motivo) VALUES
(1, 28, '2026-08-04 11:45:00', 'Atendida', 'Control por dolor abdominal'),
(2, 19, '2026-06-19 12:30:00', 'Atendida', 'Chequeo general'),
(3, 1, '2026-07-09 08:00:00', 'Atendida', 'Control de embarazo'),
(4, 20, '2026-08-27 12:15:00', 'Atendida', 'Fiebre y malestar general'),
(5, 20, '2026-06-08 11:30:00', 'Atendida', 'Dolor de cabeza persistente'),
(6, 22, '2026-03-21 09:00:00', 'Atendida', 'Control de hipertensión'),
(7, 10, '2026-08-02 17:30:00', 'Atendida', 'Consulta por alergia cutánea'),
(8, 24, '2026-03-03 12:30:00', 'Atendida', 'Dolor lumbar'),
(9, 24, '2026-07-06 11:15:00', 'Atendida', 'Control post-operatorio'),
(10, 26, '2026-09-12 16:30:00', 'Atendida', 'Consulta pediátrica de rutina'),
(11, 27, '2026-03-09 15:30:00', 'Atendida', 'Dolor de garganta'),
(12, 24, '2026-06-26 09:45:00', 'Atendida', 'Control de diabetes'),
(13, 3, '2026-03-25 11:45:00', 'Atendida', 'Consulta dermatológica'),
(14, 28, '2026-09-12 09:45:00', 'Atendida', 'Evaluación cardiológica'),
(15, 1, '2026-05-18 09:45:00', 'Atendida', 'Consulta por ansiedad'),
(16, 12, '2026-05-19 14:30:00', 'Atendida', 'Control ginecológico'),
(17, 4, '2026-04-16 08:30:00', 'Atendida', 'Consulta traumatológica por caída'),
(18, 20, '2026-04-21 09:45:00', 'Atendida', 'Revisión odontológica'),
(19, 23, '2026-05-21 14:00:00', 'Atendida', 'Consulta nutricional'),
(20, 5, '2026-01-02 12:45:00', 'Atendida', 'Dolor articular'),
(21, 4, '2026-02-08 16:15:00', 'Atendida', 'Consulta oftalmológica'),
(22, 13, '2026-08-12 16:45:00', 'Atendida', 'Control de otitis'),
(23, 19, '2026-03-14 09:45:00', 'Atendida', 'Consulta por gastritis'),
(24, 20, '2026-07-09 08:30:00', 'Atendida', 'Evaluación neurológica'),
(25, 7, '2026-08-15 11:30:00', 'Atendida', 'Consulta por infección urinaria'),
(26, 4, '2026-06-18 13:00:00', 'Atendida', 'Control de asma'),
(27, 13, '2026-05-07 09:45:00', 'Atendida', 'Consulta por vértigo'),
(28, 3, '2026-04-21 17:00:00', 'Atendida', 'Evaluación geriátrica'),
(29, 2, '2026-06-08 10:15:00', 'Atendida', 'Consulta pre-quirúrgica'),
(30, 3, '2026-09-07 17:15:00', 'Atendida', 'Control de anemia');
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
INSERT INTO Insumos (Nombre, Descripcion, Stock, PrecioUnitario, UnidadMedida, FechaCreacion, Activo) VALUES
('Paracetamol 500mg', 'Analgésico/antipirético', 500, 0.2, 'tableta', DATEADD(DAY, -268, GETDATE()), 1),
('Ibuprofeno 400mg', 'Antiinflamatorio', 400, 0.3, 'tableta', DATEADD(DAY, -366, GETDATE()), 1),
('Amoxicilina 500mg', 'Antibiótico', 300, 0.5, 'cápsula', DATEADD(DAY, -181, GETDATE()), 1),
('Omeprazol 20mg', 'Antiulceroso', 350, 0.25, 'cápsula', DATEADD(DAY, -32, GETDATE()), 1),
('Loratadina 10mg', 'Antihistamínico', 250, 0.2, 'tableta', DATEADD(DAY, -313, GETDATE()), 1),
('Suero fisiológico 500ml', 'Solución IV', 150, 3.5, 'frasco', DATEADD(DAY, -178, GETDATE()), 1),
('Jeringa 5ml', 'Material descartable', 1000, 0.3, 'unidad', DATEADD(DAY, -163, GETDATE()), 1),
('Guantes de látex', 'Material de bioseguridad', 2000, 0.15, 'unidad', DATEADD(DAY, -583, GETDATE()), 1),
('Alcohol en gel 500ml', 'Antiséptico', 200, 6.0, 'frasco', DATEADD(DAY, -286, GETDATE()), 1),
('Gasas estériles', 'Material de curación', 800, 0.1, 'unidad', DATEADD(DAY, -208, GETDATE()), 1),
('Esparadrapo', 'Material de curación', 300, 2.5, 'rollo', DATEADD(DAY, -142, GETDATE()), 1),
('Vacuna antitetánica', 'Inmunización', 100, 8.0, 'dosis', DATEADD(DAY, -56, GETDATE()), 1),
('Insulina NPH', 'Antidiabético', 80, 25.0, 'frasco', DATEADD(DAY, -164, GETDATE()), 1),
('Metformina 850mg', 'Antidiabético', 300, 0.2, 'tableta', DATEADD(DAY, -45, GETDATE()), 1),
('Losartán 50mg', 'Antihipertensivo', 300, 0.25, 'tableta', DATEADD(DAY, -396, GETDATE()), 1),
('Salbutamol inhalador', 'Broncodilatador', 120, 15.0, 'unidad', DATEADD(DAY, -273, GETDATE()), 1),
('Diclofenaco 75mg inyectable', 'Antiinflamatorio', 200, 1.5, 'ampolla', DATEADD(DAY, -361, GETDATE()), 1),
('Dexametasona inyectable', 'Corticoide', 150, 2.0, 'ampolla', DATEADD(DAY, -46, GETDATE()), 1),
('Vendas elásticas', 'Material de curación', 300, 3.0, 'unidad', DATEADD(DAY, -208, GETDATE()), 1),
('Termómetro digital', 'Equipo médico', 50, 12.0, 'unidad', DATEADD(DAY, -301, GETDATE()), 1),
('Tensiómetro digital', 'Equipo médico', 20, 80.0, 'unidad', DATEADD(DAY, -83, GETDATE()), 1),
('Mascarillas quirúrgicas', 'Material de bioseguridad', 3000, 0.2, 'unidad', DATEADD(DAY, -159, GETDATE()), 1),
('Algodón hidrófilo', 'Material de curación', 400, 1.0, 'paquete', DATEADD(DAY, -461, GETDATE()), 1),
('Yodopovidona', 'Antiséptico', 180, 4.5, 'frasco', DATEADD(DAY, -568, GETDATE()), 1),
('Ranitidina 150mg', 'Antiulceroso', 250, 0.2, 'tableta', DATEADD(DAY, -146, GETDATE()), 1),
('Cetirizina 10mg', 'Antihistamínico', 250, 0.2, 'tableta', DATEADD(DAY, -95, GETDATE()), 1),
('Ácido fólico 5mg', 'Suplemento', 300, 0.15, 'tableta', DATEADD(DAY, -517, GETDATE()), 1),
('Sulfato ferroso', 'Suplemento', 300, 0.2, 'tableta', DATEADD(DAY, -489, GETDATE()), 1),
('Naproxeno 500mg', 'Antiinflamatorio', 280, 0.3, 'tableta', DATEADD(DAY, -400, GETDATE()), 1),
('Azitromicina 500mg', 'Antibiótico', 200, 1.2, 'tableta', DATEADD(DAY, -555, GETDATE()), 1);
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
(1, 19, 1, 'Aplicar 2 veces al día'),
(1, 17, 2, '1 ampolla cada 24h'),
(2, 2, 5, '1 cápsula cada 24h'),
(2, 15, 1, '1 tableta cada 8h'),
(3, 16, 4, 'Aplicar 2 veces al día'),
(3, 22, 1, 'Aplicar 2 veces al día'),
(4, 23, 4, '1 tableta cada 8h'),
(4, 29, 1, '1 cápsula cada 24h'),
(5, 20, 2, '1 tableta cada 8h'),
(5, 5, 3, '1 ampolla cada 24h'),
(6, 21, 5, '1 ampolla cada 24h'),
(6, 23, 3, 'Aplicar 2 veces al día'),
(7, 20, 5, '1 cápsula cada 24h'),
(7, 15, 5, '1 ampolla cada 24h'),
(8, 14, 1, '1 tableta cada 8h'),
(8, 28, 5, '1 tableta cada 12h'),
(9, 14, 4, '1 tableta cada 12h'),
(9, 14, 3, 'Aplicar 2 veces al día'),
(10, 13, 4, '1 tableta cada 8h'),
(10, 11, 4, '1 cápsula cada 24h'),
(11, 22, 3, '1 cápsula cada 24h'),
(11, 5, 4, '1 tableta cada 8h'),
(12, 3, 1, '1 tableta cada 8h'),
(12, 14, 1, '1 cápsula cada 24h'),
(13, 26, 2, '1 ampolla cada 24h'),
(13, 2, 5, '1 ampolla cada 24h'),
(14, 18, 3, '1 tableta cada 8h'),
(14, 14, 3, 'Aplicar 2 veces al día'),
(15, 28, 1, '1 cápsula cada 24h'),
(15, 20, 3, '1 cápsula cada 24h'),
(16, 4, 5, '1 ampolla cada 24h'),
(16, 7, 2, 'Aplicar 2 veces al día'),
(17, 8, 1, '1 cápsula cada 24h'),
(17, 28, 5, '1 cápsula cada 24h'),
(18, 4, 3, '1 ampolla cada 24h'),
(18, 8, 4, '1 ampolla cada 24h'),
(19, 25, 5, '1 ampolla cada 24h'),
(19, 22, 5, '1 tableta cada 8h'),
(20, 20, 3, '1 tableta cada 8h'),
(20, 6, 3, '1 cápsula cada 24h'),
(21, 30, 3, '1 cápsula cada 24h'),
(21, 1, 2, '1 tableta cada 12h'),
(22, 19, 4, '1 tableta cada 8h'),
(22, 5, 1, '1 tableta cada 8h'),
(23, 24, 5, '1 tableta cada 12h'),
(23, 13, 4, 'Aplicar 2 veces al día'),
(24, 11, 2, '1 cápsula cada 24h'),
(24, 10, 3, '1 ampolla cada 24h'),
(25, 20, 1, '1 tableta cada 8h'),
(25, 5, 2, '1 ampolla cada 24h'),
(26, 2, 1, '1 cápsula cada 24h'),
(26, 15, 4, 'Aplicar 2 veces al día'),
(27, 20, 4, 'Aplicar 2 veces al día'),
(27, 9, 2, '1 ampolla cada 24h'),
(28, 4, 3, 'Aplicar 2 veces al día'),
(28, 4, 3, '1 ampolla cada 24h'),
(29, 16, 5, '1 cápsula cada 24h'),
(29, 2, 2, 'Aplicar 2 veces al día'),
(30, 20, 1, '1 tableta cada 8h'),
(30, 7, 3, '1 tableta cada 12h');
GO

-- 2.9 MovimientosInsumo (60) - kardex de salida por cada línea de receta
INSERT INTO MovimientosInsumo (InsumoID, TipoMovimiento, Cantidad, StockAnterior, StockNuevo, Motivo, ReferenciaDetalleRecetaID, FechaMovimiento) VALUES
(19, 'Salida', 1, 300, 299, 'Consumo por receta médica - Detalle #1', 1, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 1))),
(17, 'Salida', 2, 200, 198, 'Consumo por receta médica - Detalle #2', 2, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 1))),
(2, 'Salida', 5, 400, 395, 'Consumo por receta médica - Detalle #3', 3, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 2))),
(15, 'Salida', 1, 300, 299, 'Consumo por receta médica - Detalle #4', 4, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 2))),
(16, 'Salida', 4, 120, 116, 'Consumo por receta médica - Detalle #5', 5, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 3))),
(22, 'Salida', 1, 3000, 2999, 'Consumo por receta médica - Detalle #6', 6, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 3))),
(23, 'Salida', 4, 400, 396, 'Consumo por receta médica - Detalle #7', 7, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 4))),
(29, 'Salida', 1, 280, 279, 'Consumo por receta médica - Detalle #8', 8, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 4))),
(20, 'Salida', 2, 50, 48, 'Consumo por receta médica - Detalle #9', 9, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 5))),
(5, 'Salida', 3, 250, 247, 'Consumo por receta médica - Detalle #10', 10, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 5))),
(21, 'Salida', 5, 20, 15, 'Consumo por receta médica - Detalle #11', 11, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 6))),
(23, 'Salida', 3, 396, 393, 'Consumo por receta médica - Detalle #12', 12, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 6))),
(20, 'Salida', 5, 48, 43, 'Consumo por receta médica - Detalle #13', 13, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 7))),
(15, 'Salida', 5, 299, 294, 'Consumo por receta médica - Detalle #14', 14, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 7))),
(14, 'Salida', 1, 300, 299, 'Consumo por receta médica - Detalle #15', 15, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 8))),
(28, 'Salida', 5, 300, 295, 'Consumo por receta médica - Detalle #16', 16, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 8))),
(14, 'Salida', 4, 299, 295, 'Consumo por receta médica - Detalle #17', 17, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 9))),
(14, 'Salida', 3, 295, 292, 'Consumo por receta médica - Detalle #18', 18, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 9))),
(13, 'Salida', 4, 80, 76, 'Consumo por receta médica - Detalle #19', 19, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 10))),
(11, 'Salida', 4, 300, 296, 'Consumo por receta médica - Detalle #20', 20, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 10))),
(22, 'Salida', 3, 2999, 2996, 'Consumo por receta médica - Detalle #21', 21, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 11))),
(5, 'Salida', 4, 247, 243, 'Consumo por receta médica - Detalle #22', 22, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 11))),
(3, 'Salida', 1, 300, 299, 'Consumo por receta médica - Detalle #23', 23, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 12))),
(14, 'Salida', 1, 292, 291, 'Consumo por receta médica - Detalle #24', 24, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 12))),
(26, 'Salida', 2, 250, 248, 'Consumo por receta médica - Detalle #25', 25, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 13))),
(2, 'Salida', 5, 395, 390, 'Consumo por receta médica - Detalle #26', 26, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 13))),
(18, 'Salida', 3, 150, 147, 'Consumo por receta médica - Detalle #27', 27, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 14))),
(14, 'Salida', 3, 291, 288, 'Consumo por receta médica - Detalle #28', 28, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 14))),
(28, 'Salida', 1, 295, 294, 'Consumo por receta médica - Detalle #29', 29, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 15))),
(20, 'Salida', 3, 43, 40, 'Consumo por receta médica - Detalle #30', 30, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 15))),
(4, 'Salida', 5, 350, 345, 'Consumo por receta médica - Detalle #31', 31, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 16))),
(7, 'Salida', 2, 1000, 998, 'Consumo por receta médica - Detalle #32', 32, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 16))),
(8, 'Salida', 1, 2000, 1999, 'Consumo por receta médica - Detalle #33', 33, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 17))),
(28, 'Salida', 5, 294, 289, 'Consumo por receta médica - Detalle #34', 34, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 17))),
(4, 'Salida', 3, 345, 342, 'Consumo por receta médica - Detalle #35', 35, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 18))),
(8, 'Salida', 4, 1999, 1995, 'Consumo por receta médica - Detalle #36', 36, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 18))),
(25, 'Salida', 5, 250, 245, 'Consumo por receta médica - Detalle #37', 37, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 19))),
(22, 'Salida', 5, 2996, 2991, 'Consumo por receta médica - Detalle #38', 38, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 19))),
(20, 'Salida', 3, 40, 37, 'Consumo por receta médica - Detalle #39', 39, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 20))),
(6, 'Salida', 3, 150, 147, 'Consumo por receta médica - Detalle #40', 40, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 20))),
(30, 'Salida', 3, 200, 197, 'Consumo por receta médica - Detalle #41', 41, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 21))),
(1, 'Salida', 2, 500, 498, 'Consumo por receta médica - Detalle #42', 42, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 21))),
(19, 'Salida', 4, 299, 295, 'Consumo por receta médica - Detalle #43', 43, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 22))),
(5, 'Salida', 1, 243, 242, 'Consumo por receta médica - Detalle #44', 44, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 22))),
(24, 'Salida', 5, 180, 175, 'Consumo por receta médica - Detalle #45', 45, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 23))),
(13, 'Salida', 4, 76, 72, 'Consumo por receta médica - Detalle #46', 46, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 23))),
(11, 'Salida', 2, 296, 294, 'Consumo por receta médica - Detalle #47', 47, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 24))),
(10, 'Salida', 3, 800, 797, 'Consumo por receta médica - Detalle #48', 48, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 24))),
(20, 'Salida', 1, 37, 36, 'Consumo por receta médica - Detalle #49', 49, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 25))),
(5, 'Salida', 2, 242, 240, 'Consumo por receta médica - Detalle #50', 50, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 25))),
(2, 'Salida', 1, 390, 389, 'Consumo por receta médica - Detalle #51', 51, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 26))),
(15, 'Salida', 4, 294, 290, 'Consumo por receta médica - Detalle #52', 52, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 26))),
(20, 'Salida', 4, 36, 32, 'Consumo por receta médica - Detalle #53', 53, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 27))),
(9, 'Salida', 2, 200, 198, 'Consumo por receta médica - Detalle #54', 54, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 27))),
(4, 'Salida', 3, 342, 339, 'Consumo por receta médica - Detalle #55', 55, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 28))),
(4, 'Salida', 3, 339, 336, 'Consumo por receta médica - Detalle #56', 56, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 28))),
(16, 'Salida', 5, 116, 111, 'Consumo por receta médica - Detalle #57', 57, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 29))),
(2, 'Salida', 2, 389, 387, 'Consumo por receta médica - Detalle #58', 58, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 29))),
(20, 'Salida', 1, 32, 31, 'Consumo por receta médica - Detalle #59', 59, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 30))),
(7, 'Salida', 3, 998, 995, 'Consumo por receta médica - Detalle #60', 60, DATEADD(MINUTE, 35, (SELECT FechaRegistro FROM HistorialClinico WHERE HistorialID = 30)));
GO

-- Sincroniza Insumos.Stock con el resultado final del kardex
UPDATE Insumos SET Stock = 498 WHERE InsumoID = 1;
UPDATE Insumos SET Stock = 387 WHERE InsumoID = 2;
UPDATE Insumos SET Stock = 299 WHERE InsumoID = 3;
UPDATE Insumos SET Stock = 336 WHERE InsumoID = 4;
UPDATE Insumos SET Stock = 240 WHERE InsumoID = 5;
UPDATE Insumos SET Stock = 147 WHERE InsumoID = 6;
UPDATE Insumos SET Stock = 995 WHERE InsumoID = 7;
UPDATE Insumos SET Stock = 1995 WHERE InsumoID = 8;
UPDATE Insumos SET Stock = 198 WHERE InsumoID = 9;
UPDATE Insumos SET Stock = 797 WHERE InsumoID = 10;
UPDATE Insumos SET Stock = 294 WHERE InsumoID = 11;
UPDATE Insumos SET Stock = 100 WHERE InsumoID = 12;
UPDATE Insumos SET Stock = 72 WHERE InsumoID = 13;
UPDATE Insumos SET Stock = 288 WHERE InsumoID = 14;
UPDATE Insumos SET Stock = 290 WHERE InsumoID = 15;
UPDATE Insumos SET Stock = 111 WHERE InsumoID = 16;
UPDATE Insumos SET Stock = 198 WHERE InsumoID = 17;
UPDATE Insumos SET Stock = 147 WHERE InsumoID = 18;
UPDATE Insumos SET Stock = 295 WHERE InsumoID = 19;
UPDATE Insumos SET Stock = 31 WHERE InsumoID = 20;
UPDATE Insumos SET Stock = 15 WHERE InsumoID = 21;
UPDATE Insumos SET Stock = 2991 WHERE InsumoID = 22;
UPDATE Insumos SET Stock = 393 WHERE InsumoID = 23;
UPDATE Insumos SET Stock = 175 WHERE InsumoID = 24;
UPDATE Insumos SET Stock = 245 WHERE InsumoID = 25;
UPDATE Insumos SET Stock = 248 WHERE InsumoID = 26;
UPDATE Insumos SET Stock = 300 WHERE InsumoID = 27;
UPDATE Insumos SET Stock = 289 WHERE InsumoID = 28;
UPDATE Insumos SET Stock = 279 WHERE InsumoID = 29;
UPDATE Insumos SET Stock = 197 WHERE InsumoID = 30;
GO

-- 2.10 Facturas (30) - una por Cita, Serie tipo boleta electrónica
INSERT INTO Facturas (CitaID, Serie, Correlativo, FechaEmision, Subtotal, IGV, Total, MetodoPago, Estado) VALUES
(1, 'B001', '00000001', '2026-05-10 13:30:00', 147.43, 26.54, 173.97, 'Efectivo', 'Pagada'),
(2, 'B001', '00000002', '2026-07-06 10:30:00', 41.08, 7.39, 48.47, 'Transferencia', 'Pagada'),
(3, 'B001', '00000003', '2026-04-17 16:30:00', 114.56, 20.62, 135.18, 'Yape/Plin', 'Pagada'),
(4, 'B001', '00000004', '2026-01-14 08:30:00', 50.09, 9.02, 59.11, 'Transferencia', 'Pagada'),
(5, 'B001', '00000005', '2026-06-19 14:30:00', 168.96, 30.41, 199.37, 'Transferencia', 'Pagada'),
(6, 'B001', '00000006', '2026-07-10 09:30:00', 139.33, 25.08, 164.41, 'Transferencia', 'Pagada'),
(7, 'B001', '00000007', '2026-06-06 17:30:00', 42.92, 7.73, 50.65, 'Transferencia', 'Pagada'),
(8, 'B001', '00000008', '2026-06-03 14:30:00', 156.48, 28.17, 184.65, 'Efectivo', 'Pagada'),
(9, 'B001', '00000009', '2026-07-17 09:30:00', 74.06, 13.33, 87.39, 'Transferencia', 'Pagada'),
(10, 'B001', '00000010', '2026-06-08 13:30:00', 161.87, 29.14, 191.01, 'Tarjeta', 'Pagada'),
(11, 'B001', '00000011', '2026-02-17 16:30:00', 50.69, 9.12, 59.81, 'Tarjeta', 'Pagada'),
(12, 'B001', '00000012', '2026-06-12 10:30:00', 166.83, 30.03, 196.86, 'Tarjeta', 'Pagada'),
(13, 'B001', '00000013', '2026-05-07 10:30:00', 54.39, 9.79, 64.18, 'Tarjeta', 'Pagada'),
(14, 'B001', '00000014', '2026-02-06 15:30:00', 146.43, 26.36, 172.79, 'Transferencia', 'Pagada'),
(15, 'B001', '00000015', '2026-08-22 17:30:00', 145.62, 26.21, 171.83, 'Yape/Plin', 'Pagada'),
(16, 'B001', '00000016', '2026-06-05 15:30:00', 160.99, 28.98, 189.97, 'Efectivo', 'Pagada'),
(17, 'B001', '00000017', '2026-05-26 12:30:00', 105.65, 19.02, 124.67, 'Efectivo', 'Pagada'),
(18, 'B001', '00000018', '2026-02-10 15:30:00', 89.27, 16.07, 105.34, 'Transferencia', 'Pagada'),
(19, 'B001', '00000019', '2026-06-27 12:30:00', 45.27, 8.15, 53.42, 'Efectivo', 'Pagada'),
(20, 'B001', '00000020', '2026-02-20 17:30:00', 130.25, 23.45, 153.7, 'Transferencia', 'Pagada'),
(21, 'B001', '00000021', '2026-09-26 08:30:00', 104.78, 18.86, 123.64, 'Transferencia', 'Pagada'),
(22, 'B001', '00000022', '2026-04-11 17:30:00', 167.27, 30.11, 197.38, 'Transferencia', 'Pagada'),
(23, 'B001', '00000023', '2026-01-15 09:30:00', 110.19, 19.83, 130.02, 'Yape/Plin', 'Pagada'),
(24, 'B001', '00000024', '2026-02-17 10:30:00', 177.53, 31.96, 209.49, 'Efectivo', 'Pagada'),
(25, 'B001', '00000025', '2026-08-15 16:30:00', 74.68, 13.44, 88.12, 'Tarjeta', 'Pagada'),
(26, 'B001', '00000026', '2026-05-13 14:30:00', 90.95, 16.37, 107.32, 'Yape/Plin', 'Pagada'),
(27, 'B001', '00000027', '2026-01-26 13:30:00', 135.05, 24.31, 159.36, 'Efectivo', 'Pagada'),
(28, 'B001', '00000028', '2026-09-22 14:30:00', 86.16, 15.51, 101.67, 'Yape/Plin', 'Pagada'),
(29, 'B001', '00000029', '2026-03-11 09:30:00', 75.28, 13.55, 88.83, 'Tarjeta', 'Pagada'),
(30, 'B001', '00000030', '2026-05-21 14:30:00', 168.34, 30.3, 198.64, 'Tarjeta', 'Pagada');
GO

-- 2.11 DetalleFactura (60 - línea de consulta + línea de insumos por factura)
INSERT INTO DetalleFactura (FacturaID, Descripcion, Cantidad, PrecioUnitario, Subtotal) VALUES
(1, 'Consulta médica especializada', 1, 103.2, 103.2),
(1, 'Insumos y medicamentos recetados', 1, 44.23, 44.23),
(2, 'Consulta médica especializada', 1, 28.76, 28.76),
(2, 'Insumos y medicamentos recetados', 1, 12.32, 12.32),
(3, 'Consulta médica especializada', 1, 80.19, 80.19),
(3, 'Insumos y medicamentos recetados', 1, 34.37, 34.37),
(4, 'Consulta médica especializada', 1, 35.06, 35.06),
(4, 'Insumos y medicamentos recetados', 1, 15.03, 15.03),
(5, 'Consulta médica especializada', 1, 118.27, 118.27),
(5, 'Insumos y medicamentos recetados', 1, 50.69, 50.69),
(6, 'Consulta médica especializada', 1, 97.53, 97.53),
(6, 'Insumos y medicamentos recetados', 1, 41.8, 41.8),
(7, 'Consulta médica especializada', 1, 30.04, 30.04),
(7, 'Insumos y medicamentos recetados', 1, 12.88, 12.88),
(8, 'Consulta médica especializada', 1, 109.54, 109.54),
(8, 'Insumos y medicamentos recetados', 1, 46.94, 46.94),
(9, 'Consulta médica especializada', 1, 51.84, 51.84),
(9, 'Insumos y medicamentos recetados', 1, 22.22, 22.22),
(10, 'Consulta médica especializada', 1, 113.31, 113.31),
(10, 'Insumos y medicamentos recetados', 1, 48.56, 48.56),
(11, 'Consulta médica especializada', 1, 35.48, 35.48),
(11, 'Insumos y medicamentos recetados', 1, 15.21, 15.21),
(12, 'Consulta médica especializada', 1, 116.78, 116.78),
(12, 'Insumos y medicamentos recetados', 1, 50.05, 50.05),
(13, 'Consulta médica especializada', 1, 38.07, 38.07),
(13, 'Insumos y medicamentos recetados', 1, 16.32, 16.32),
(14, 'Consulta médica especializada', 1, 102.5, 102.5),
(14, 'Insumos y medicamentos recetados', 1, 43.93, 43.93),
(15, 'Consulta médica especializada', 1, 101.93, 101.93),
(15, 'Insumos y medicamentos recetados', 1, 43.69, 43.69),
(16, 'Consulta médica especializada', 1, 112.69, 112.69),
(16, 'Insumos y medicamentos recetados', 1, 48.3, 48.3),
(17, 'Consulta médica especializada', 1, 73.95, 73.95),
(17, 'Insumos y medicamentos recetados', 1, 31.7, 31.7),
(18, 'Consulta médica especializada', 1, 62.49, 62.49),
(18, 'Insumos y medicamentos recetados', 1, 26.78, 26.78),
(19, 'Consulta médica especializada', 1, 31.69, 31.69),
(19, 'Insumos y medicamentos recetados', 1, 13.58, 13.58),
(20, 'Consulta médica especializada', 1, 91.17, 91.17),
(20, 'Insumos y medicamentos recetados', 1, 39.08, 39.08),
(21, 'Consulta médica especializada', 1, 73.35, 73.35),
(21, 'Insumos y medicamentos recetados', 1, 31.43, 31.43),
(22, 'Consulta médica especializada', 1, 117.09, 117.09),
(22, 'Insumos y medicamentos recetados', 1, 50.18, 50.18),
(23, 'Consulta médica especializada', 1, 77.13, 77.13),
(23, 'Insumos y medicamentos recetados', 1, 33.06, 33.06),
(24, 'Consulta médica especializada', 1, 124.27, 124.27),
(24, 'Insumos y medicamentos recetados', 1, 53.26, 53.26),
(25, 'Consulta médica especializada', 1, 52.28, 52.28),
(25, 'Insumos y medicamentos recetados', 1, 22.4, 22.4),
(26, 'Consulta médica especializada', 1, 63.66, 63.66),
(26, 'Insumos y medicamentos recetados', 1, 27.29, 27.29),
(27, 'Consulta médica especializada', 1, 94.53, 94.53),
(27, 'Insumos y medicamentos recetados', 1, 40.52, 40.52),
(28, 'Consulta médica especializada', 1, 60.31, 60.31),
(28, 'Insumos y medicamentos recetados', 1, 25.85, 25.85),
(29, 'Consulta médica especializada', 1, 52.7, 52.7),
(29, 'Insumos y medicamentos recetados', 1, 22.58, 22.58),
(30, 'Consulta médica especializada', 1, 117.84, 117.84),
(30, 'Insumos y medicamentos recetados', 1, 50.5, 50.5);
GO

-- ============================================================
-- 3. PROCEDIMIENTO: IMPRESIÓN ASCII DE BOLETA (para captura de pantalla)
-- ============================================================

CREATE PROCEDURE sp_ImprimirFacturaASCII
    @FacturaID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Serie CHAR(4), @Correlativo VARCHAR(8), @Fecha DATETIME,
            @Subtotal DECIMAL(10,2), @IGV DECIMAL(10,2), @Total DECIMAL(10,2),
            @MetodoPago VARCHAR(20), @PacienteNombre VARCHAR(130), @PacienteDNI CHAR(8),
            @MedicoNombre VARCHAR(130), @Especialidad VARCHAR(100);

    SELECT
        @Serie = f.Serie, @Correlativo = f.Correlativo, @Fecha = f.FechaEmision,
        @Subtotal = f.Subtotal, @IGV = f.IGV, @Total = f.Total, @MetodoPago = f.MetodoPago,
        @PacienteNombre = p.Nombres + ' ' + p.Apellidos, @PacienteDNI = p.DNI,
        @MedicoNombre = m.Nombres + ' ' + m.Apellidos, @Especialidad = e.Nombre
    FROM Facturas f
    JOIN Citas c ON c.CitaID = f.CitaID
    JOIN Pacientes p ON p.PacienteID = c.PacienteID
    JOIN Medicos m ON m.MedicoID = c.MedicoID
    JOIN Especialidades e ON e.EspecialidadID = m.EspecialidadID
    WHERE f.FacturaID = @FacturaID;

    IF @Serie IS NULL
    BEGIN
        PRINT 'Factura no encontrada.';
        RETURN;
    END

    PRINT REPLICATE('=', 42);
    PRINT '      CLINICA LIMATAMBO CAJAMARCA';
    PRINT '      RUC: 20609876541';
    PRINT '      Jr. Amazonas 450, Cajamarca';
    PRINT REPLICATE('=', 42);
    PRINT 'BOLETA DE VENTA ELECTRONICA';
    PRINT 'Serie: ' + @Serie + '   N°: ' + @Correlativo;
    PRINT 'Fecha: ' + CONVERT(VARCHAR(20), @Fecha, 103) + ' ' + CONVERT(VARCHAR(8), @Fecha, 108);
    PRINT REPLICATE('-', 42);
    PRINT 'Paciente : ' + @PacienteNombre;
    PRINT 'DNI      : ' + @PacienteDNI;
    PRINT 'Medico   : ' + @MedicoNombre;
    PRINT 'Espec.   : ' + @Especialidad;
    PRINT REPLICATE('-', 42);
    PRINT LEFT('DESCRIPCION' + SPACE(30), 26) + RIGHT(SPACE(6) + 'CANT', 6) + RIGHT(SPACE(9) + 'IMPORTE', 9);

    DECLARE @Desc VARCHAR(150), @Cant INT, @Precio DECIMAL(10,2), @Sub DECIMAL(10,2);
    DECLARE detalle_cursor CURSOR FOR
        SELECT Descripcion, Cantidad, PrecioUnitario, Subtotal
        FROM DetalleFactura WHERE FacturaID = @FacturaID;
    OPEN detalle_cursor;
    FETCH NEXT FROM detalle_cursor INTO @Desc, @Cant, @Precio, @Sub;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT LEFT(@Desc + SPACE(30), 26)
            + RIGHT(SPACE(6) + CONVERT(VARCHAR, @Cant), 6)
            + RIGHT(SPACE(9) + CONVERT(VARCHAR, @Sub), 9);
        FETCH NEXT FROM detalle_cursor INTO @Desc, @Cant, @Precio, @Sub;
    END
    CLOSE detalle_cursor;
    DEALLOCATE detalle_cursor;

    PRINT REPLICATE('-', 42);
    PRINT RIGHT(SPACE(30) + 'Subtotal: S/ ' + CONVERT(VARCHAR, @Subtotal), 42);
    PRINT RIGHT(SPACE(30) + 'IGV(18%): S/ ' + CONVERT(VARCHAR, @IGV), 42);
    PRINT RIGHT(SPACE(30) + 'TOTAL:    S/ ' + CONVERT(VARCHAR, @Total), 42);
    PRINT REPLICATE('=', 42);
    PRINT 'Forma de pago: ' + @MetodoPago;
    PRINT REPLICATE('=', 42);
    PRINT '     ¡Gracias por su preferencia!';
    PRINT REPLICATE('=', 42);
END
GO

-- Ejemplo de uso (ejecutar y revisar la pestaña "Messages" en SSMS):
-- EXEC sp_ImprimirFacturaASCII @FacturaID = 1;
