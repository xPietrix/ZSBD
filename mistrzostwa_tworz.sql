
CREATE DATABASE mistrzostwa;

GO
CREATE TABLE mistrzostwa.dbo.reprezentacje
(
	id INT IDENTITY(1,1) CONSTRAINT reprezentacje_PK PRIMARY KEY,
	nazwa VARCHAR(50) NOT NULL,
	miejsce_w_rankingu_FIFA int NOT NULL,
	--id_grupy INT NOT NULL,
	--CONSTRAINT reprezentacja_grupa_FK FOREIGN KEY(id_grupy) REFERENCES mistrzostwa.dbo.reprezentacje(id),
	CONSTRAINT reprezentacja_miejsce_FK CHECK(miejsce_w_rankingu_FIFA >= 1 and miejsce_w_rankingu_FIFA <= 206),
);

CREATE TABLE mistrzostwa.dbo.pilkarze 
(
	id INT IDENTITY(1,1) CONSTRAINT pilkarze_PK PRIMARY KEY,
	imie VARCHAR(30) NOT NULL,
	nazwisko VARCHAR(30) NOT NULL,
	data_ur DATE NOT NULL,
	id_reprezentacji INT,
	numer INT,
	CONSTRAINT pilkarz_reprezentacja_FK FOREIGN KEY(id_reprezentacji) REFERENCES mistrzostwa.dbo.reprezentacje(id),
	CONSTRAINT pilkarz_numer_check CHECK(numer >= 1 and numer <= 99)
);

GO
CREATE TABLE mistrzostwa.dbo.pozycje
(
	id INT IDENTITY(1,1) CONSTRAINT pozycje_PK PRIMARY KEY,
	nazwa VARCHAR(30) NOT NULL
);

GO
CREATE TABLE mistrzostwa.dbo.pilkarze_pozycje
(
	id INT IDENTITY(1,1) CONSTRAINT pilkarze_pozycje_PK PRIMARY KEY,
	id_pilkarza INT NOT NULL,
	id_pozycji INT NOT NULL,
	CONSTRAINT pilpoz_pilkarze_FK FOREIGN KEY(id_pilkarza) REFERENCES mistrzostwa.dbo.pilkarze(id),
	CONSTRAINT pilpoz_pozycje_FK FOREIGN KEY(id_pozycji) REFERENCES mistrzostwa.dbo.pozycje(id)
);

GO 
CREATE TABLE mistrzostwa.dbo.stadiony
(
	id INT IDENTITY(1,1) CONSTRAINT stadiony_PK PRIMARY KEY,
	nazwa VARCHAR(50) NOT NULL,
	kraj VARCHAR(50) NOT NULL
);

GO
CREATE TABLE mistrzostwa.dbo.sedziowie
(
	id INT IDENTITY(1,1) CONSTRAINT statystyki_PK PRIMARY KEY,
	imie VARCHAR(40) NOT NULL,
	nazwisko VARCHAR(40) NOT NULL,
	data_ur DATE NOT NULL,
);

GO
CREATE TABLE mistrzostwa.dbo.mecze
(
	id INT IDENTITY(1,1) CONSTRAINT mecze_PK PRIMARY KEY,
	id_reprezentacji_A INT NOT NULL,
	id_reprezentacji_B INT NOT NULL,
	id_stadionu INT NOT NULL,
	id_sedziego INT NOT NULL,
	data_meczu DATE NOT NULL,
	typ_meczu VARCHAR(30),
	CONSTRAINT mecze_reprezentacja_A_FK FOREIGN KEY(id_reprezentacji_A) REFERENCES mistrzostwa.dbo.reprezentacje(id),
	CONSTRAINT mecze_reprezentacje_B_FK FOREIGN KEY(id_reprezentacji_B) REFERENCES mistrzostwa.dbo.reprezentacje(id),
	CONSTRAINT mecze_stadiony_FK FOREIGN KEY(id_stadionu) REFERENCES mistrzostwa.dbo.stadiony(id),
	CONSTRAINT mecze_sedziowie_FK FOREIGN KEY(id_sedziego) REFERENCES mistrzostwa.dbo.sedziowie(id)
);

GO
CREATE TABLE mistrzostwa.dbo.statystyki_meczy
(
	id INT IDENTITY(1,1) CONSTRAINT statystyki_meczy_PK PRIMARY KEY,
	id_meczu INT NOT NULL,
	wynik VARCHAR(10) NOT NULL,
	gole_samobojcze INT NOT NULL,
	zolte_kartki INT NOT NULL,
	czerwone_kartki INT NOT NULL,
	CONSTRAINT mecze_FK FOREIGN KEY(id_meczu) REFERENCES mistrzostwa.dbo.mecze(id)
);

