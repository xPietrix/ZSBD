DECLARE @DatabaseName nvarchar(50)
SET @DatabaseName = N'football'

DECLARE @SQL varchar(max)

SELECT @SQL = COALESCE(@SQL,'') + 'Kill ' + Convert(varchar, SPId) + ';'
FROM MASTER..SysProcesses
WHERE DBId = DB_ID(@DatabaseName) AND SPId <> @@SPId

--SELECT @SQL 
EXEC(@SQL)

if exists(select 1 from master.dbo.sysdatabases where name = 'football') drop database football
GO
CREATE DATABASE football
GO

CREATE TABLE football.dbo.pozycje (
id 	INT IDENTITY(1,1) CONSTRAINT pozycje_PK PRIMARY KEY,
nazwa 	VARCHAR(40) NOT NULL
); 
GO

CREATE TABLE football.dbo.miejsca (
id 	INT IDENTITY(1,1) CONSTRAINT miejsca_PK PRIMARY KEY,
nazwa 	VARCHAR(100) NOT NULL,
miasto VARCHAR(20) NOT NULL,
ulica VARCHAR(40) NOT NULL
); 
GO

CREATE TABLE football.dbo.ligi (
id 	INT IDENTITY(1,1) CONSTRAINT ligi_PK PRIMARY KEY,
nazwa 	VARCHAR(30) NOT NULL
); 
GO

CREATE TABLE football.dbo.druzyny (
id INT IDENTITY(1,1) CONSTRAINT druzyny_PK PRIMARY KEY,
id_liga	INT NOT NULL,
id_miejsce	INT NOT NULL,
nazwa 	VARCHAR(40) NOT NULL,
CONSTRAINT dru_ligi_FK FOREIGN KEY(id_liga) REFERENCES football.dbo.ligi(id),
CONSTRAINT dru_miejsca_FK FOREIGN KEY(id_miejsce) REFERENCES football.dbo.miejsca(id)
);
GO

CREATE TABLE football.dbo.pilkarze (
id INT IDENTITY(1,1) CONSTRAINT pilkarze_PK PRIMARY KEY,
imie 	VARCHAR(20) NOT NULL,
nazwisko 	VARCHAR(20) NOT NULL,
data_ur DATE NOT NULL,
id_druzyna INT,
numer INT,
CONSTRAINT pil_druzyny_FK FOREIGN KEY(id_druzyna) REFERENCES football.dbo.druzyny(id),
CONSTRAINT pil_numer_check CHECK(numer >= 1 and numer <= 99)
);
GO

CREATE TABLE football.dbo.pilkarze_pozycje (
id INT IDENTITY(1,1) CONSTRAINT pilkarze_pozycje_PK PRIMARY KEY,
id_pilkarz	INT NOT NULL,
id_pozycja	INT NOT NULL,
CONSTRAINT pilpoz_pilkarze_FK FOREIGN KEY(id_pilkarz) REFERENCES football.dbo.pilkarze(id),
CONSTRAINT pilpoz_pozycje_FK FOREIGN KEY(id_pozycja) REFERENCES football.dbo.pozycje(id)
);
GO

CREATE TABLE football.dbo.sedziowie (
id 	INT IDENTITY(1,1) CONSTRAINT sedziowie_PK PRIMARY KEY,
imie 	VARCHAR(20) NOT NULL,
nazwisko 	VARCHAR(20) NOT NULL
); 
GO

CREATE TABLE football.dbo.rodzaje_meczow (
id 	INT IDENTITY(1,1) CONSTRAINT rodzaje_meczow_PK PRIMARY KEY,
nazwa 	VARCHAR(40) NOT NULL
); 
GO

CREATE TABLE football.dbo.mecze (
id INT IDENTITY(1,1) CONSTRAINT mecze_PK PRIMARY KEY,
id_rodzaj_meczu INT NOT NULL,
id_sedzia INT NOT NULL,
id_miejsce INT NOT NULL,
id_gospodarz INT NOT NULL,
id_gosc INT NOT NULL,
data_meczu SMALLDATETIME NOT NULL,
CONSTRAINT mec_rodzaje_meczow_FK FOREIGN KEY(id_rodzaj_meczu) REFERENCES football.dbo.rodzaje_meczow(id),
CONSTRAINT mec_sedziowie_FK FOREIGN KEY(id_sedzia) REFERENCES football.dbo.sedziowie(id),
CONSTRAINT mec_miejsca_FK FOREIGN KEY(id_miejsce) REFERENCES football.dbo.miejsca(id),
CONSTRAINT mec_gospodarz_FK FOREIGN KEY(id_gospodarz) REFERENCES football.dbo.druzyny(id),
CONSTRAINT mec_gosc_FK FOREIGN KEY(id_gosc) REFERENCES football.dbo.druzyny(id)
);
GO

CREATE TABLE football.dbo.sklady (
id INT IDENTITY(1,1) CONSTRAINT sklady_PK PRIMARY KEY,
id_mecz	INT NOT NULL,
id_pilkarz INT NOT NULL,
gole INT NOT NULL,
gole_samobojcze INT NOT NULL,
zolte_kartki INT NOT NULL,
czerwone_kartki INT NOT NULL,
CONSTRAINT skl_mecze_FK FOREIGN KEY(id_mecz) REFERENCES football.dbo.mecze(id),
CONSTRAINT skl_pilkarze_FK FOREIGN KEY(id_pilkarz) REFERENCES football.dbo.pilkarze(id),
CONSTRAINT skl_gole_check CHECK(gole >= 0 and gole_samobojcze >= 0),
CONSTRAINT skl_zolte_kartki_check CHECK(zolte_kartki >= 0 and zolte_kartki <= 2),
CONSTRAINT skl_czerwone_kartki_check CHECK(czerwone_kartki=0 or czerwone_kartki=1)
);
GO