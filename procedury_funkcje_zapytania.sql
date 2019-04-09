-- 1. Usuwanie meczy starszych ni� podana ilo�� lat.
drop procedure procedura1

go
create procedure procedura1 @lata int = 2
as
begin
	delete from mistrzostwa..mecze
	where datediff(day,data_meczu,getdate()) > @lata*365
end

--Przyk�ad wywo�ania

Select data_meczu from mistrzostwa.dbo.mecze order by data_meczu

exec procedura1 1

Select data_meczu from mistrzostwa.dbo.mecze order by data_meczu

--2. Dodawanie nowego s�dziego
drop procedure procedura2

go
create procedure procedura2 @imie varchar(40) = null, 
							@nazwisko varchar(40) = null, 
							@data_ur DATE,
							@kraj varchar(40) = null
as 
begin
	if @imie is null or @nazwisko is null or @kraj is null
	begin
		print 'Wyst�pi� b��d. Nie podano imienia, nazwiska, kraju lub daty urodzenia.'
	end
	else
	begin
		insert into mistrzostwa..sedziowie values (@imie, @nazwisko, @data_ur,  @kraj)
		print 'Pomy�lnie dodano s�dziego (imi�: ' + @imie + ', nazwisko: ' + @nazwisko + 
			  + ', kraj: ' + @kraj + ', data urodzenia: ' + cast(@data_ur as varchar) + ')'
	end
end
go

Select imie, nazwisko, data_ur, kraj From mistrzostwa .dbo.sedziowie 

--Przyklad wywo�ania
exec procedura2 'Tom','Butcher','1980-01-01', 'Francja'

Select imie, nazwisko, data_ur, kraj From mistrzostwa .dbo.sedziowie 

delete from mistrzostwa.dbo.sedziowie where imie = 'Tom' and nazwisko = 'Butcher'

--3. Zmiana numeru pi�karza o podanym imieniu, nazwisku, reprezentacji i starym numerze na podany numer
drop procedure procedura3

go
create procedure procedura3	@imie varchar(20) = null,
						    @nazwisko varchar(20) = null, 
							@reprezentacja varchar(40) = null,
						    @snum int = 0, 
							@nnum int = 0
as 
begin
	if @imie is null or @nazwisko is null or @reprezentacja is null or @snum = 0 or @nnum = 0
	begin
		print 'Wyst�pi� b��d. Podano b��dne parametry.'
	end
	else
	begin
		declare @ile int
		set @ile =	(select count(*)
					from mistrzostwa..pilkarze 
					where imie = @imie and nazwisko = @nazwisko and numer = @snum 
					and id_reprezentacji = (select id from mistrzostwa..reprezentacje where nazwa = @reprezentacja))
		if @ile = 1
		begin
			update mistrzostwa..pilkarze
			set numer = @nnum
			where imie = @imie and nazwisko = @nazwisko and numer = @snum 
			and id_reprezentacji = (select id from mistrzostwa..reprezentacje where nazwa = @reprezentacja)
			print	'Pomy�lnie zmieniono numer pi�karza
			
			imi�: ' + @imie + ' nazwisko: ' + @nazwisko + ' reprezentacja: ' + @reprezentacja 
			+ ' stary numer: ' + cast(@snum as varchar(3)) + ' nowy numer: ' + cast(@nnum as varchar(3))
		end
		else
		begin
			print 'Wyst�pi� b��d. Nie znaleziono pi�karza.'
		end
		
	end
end

select * from mistrzostwa..pilkarze where nazwisko = 'Muller'
exec procedura3 'Thomas', 'Muller', 'Niemcy', 10, 17

select * from mistrzostwa..pilkarze

-- 4. Nazwa stadionu kt�ry znajduje si� w danym mie�cie lub informacja, �e nie ma �adnych stadion�w w podanym mie�cie
drop procedure procedura4

go
create procedure procedura4 @miasto varchar(20) = null
as 
begin
	declare @ile int
	set @ile = (select count(*) from mistrzostwa..stadiony where miasto = @miasto)
	if @ile > 0
	begin
		select m.nazwa
		from mistrzostwa..stadiony m
		where m.miasto = @miasto
	end
	else
	begin
		print 'Nie znaleziono �adnego stadionu w mie�cie '+ @miasto + '.'
	end
end
go
exec procedura4 'Moskwa'
exec procedura4 'Warszawa'

-- 5. Zwraca najwi�ksz� liczb� goli samob�jczych jaka pad�a w meczu
drop function funkcja

create function funkcja() returns int
begin
	declare @ile int = 0
	set @ile = (select top 1 gole_samobojcze
				from mistrzostwa.dbo.statystyki_meczy
				order by gole_samobojcze desc)
	return @ile
end

declare @a int
exec @a = funkcja
print 'Najwi�ksza liczba goli samob�jczych jaka pad�a w meczu to: ' +  cast(@a as varchar(3))

select MAX(gole_samobojcze) as najwiecej_goli_samobojczych from mistrzostwa.dbo.statystyki_meczy 

--ZAPYTANIA

--1. Podaj imi�, nazwisko, reprezentacj� oraz wiek najm�odszego pi�karza zawod�w

SELECT imie, nazwisko, nazwa, (YEAR(GETDATE()) - YEAR(data_ur)) AS wiek
FROM mistrzostwa.dbo.pilkarze AS p, mistrzostwa.dbo.reprezentacje AS r
WHERE data_ur = (SELECT MAX(data_ur)
	   			 FROM mistrzostwa.dbo.pilkarze)
AND p.id_reprezentacji = r.id

--2. Podaj �redni wiek dla pi�karzy z numerem 9

SELECT AVG(YEAR(GETDATE()) - YEAR(data_ur)) AS sredni_wiek
FROM mistrzostwa.dbo.pilkarze
WHERE mistrzostwa.dbo.pilkarze.numer = 9				

--3. Podaj imiona i nazwiska pi�karzy, graj�cych na pozycji napastnik; kt�rych reprezentacje zajmuj� miejsce wy�sze ni� 10 w rankingu FIFA

SELECT imie, nazwisko, rep.nazwa
FROM mistrzostwa.dbo.pilkarze AS pil, mistrzostwa.dbo.pilkarze_pozycje AS pilpoz, mistrzostwa.dbo.pozycje AS poz,
	 mistrzostwa.dbo.reprezentacje AS rep
WHERE pilpoz.id_pilkarza = pil.id AND pilpoz.id_pozycji = poz.id AND poz.nazwa = 'Napastnik' 
	  AND pil.id_reprezentacji = rep.id	AND rep.miejsce_w_rankingu_FIFA < 10 

--4. Podaj dat�/daty meczu/y i nazw� stadionu na kt�rym wtedy grano, gdy pad�o najwi�cej goli samob�jczych 

SELECT data_meczu, gole_samobojcze, nazwa     
FROM mistrzostwa.dbo.mecze AS m, mistrzostwa.dbo.statystyki_meczy AS sm, mistrzostwa.dbo.stadiony AS s
WHERE gole_samobojcze = (SELECT MAX(gole_samobojcze)
							FROM mistrzostwa.dbo.statystyki_meczy) 
AND m.id_stadionu = s.id AND m.id = sm.id_meczu

--5. Podaj pa�stwa z Ameryki Po�udniowej, kt�rych reprezentacje otrzyma�y w meczu wi�cej ni� 2 czerwone kartki 

SELECT nazwa
FROM mistrzostwa.dbo.reprezentacje AS r, mistrzostwa.dbo.statystyki_meczy AS sm, mistrzostwa.dbo.mecze AS m
WHERE r.kontynent = 'Ameryka Po�udniowa' AND (  r.id = m.id_reprezentacji_B or r.id = m.id_reprezentacji_A ) 
AND m.id = sm.id AND sm.czerwone_kartki > 2
GROUP BY nazwa 

--6. Podaj miasto oraz nazw� stadionu na kt�rym rozegrano najwi�cej meczy typu 'Grupowy' oraz liczb� tych meczy

SELECT TOP 1 miasto, nazwa, COUNT (id_stadionu) AS ile_meczy
FROM  mistrzostwa.dbo.mecze AS m, mistrzostwa.dbo.stadiony AS s
WHERE m.id_stadionu = s.id AND m.typ_meczu = 'Grupowy'
GROUP BY nazwa, miasto
ORDER BY ile_meczy DESC

--7. Podaj imi�, nazwisko, kraj pochodzenia oraz wiek najstarszego s�dziego, kt�ry s�dziowa� w meczu na stadionie, kt�rego nazwa zaczyna si� 
--na "S"

SELECT imie, nazwisko, (YEAR(GETDATE()) - YEAR(data_ur)) AS wiek, kraj, nazwa
FROM mistrzostwa.dbo.sedziowie as sd, mistrzostwa.dbo.mecze AS m, mistrzostwa.dbo.stadiony AS s
WHERE data_ur = (SELECT MIN(data_ur)
				 FROM mistrzostwa.dbo.sedziowie)
AND m.id_sedziego = sd.id AND m.id_stadionu = s.id AND s.nazwa LIKE 's%'
GROUP BY imie, nazwisko, data_ur, kraj, nazwa 

--8. Poda� terminy oraz nazwy stadion�w i wszystkich meczy w kt�rych bra�y udzia� reprezentacje z Europyo miejscu w rankingu FIFA nizszym niz 4

SELECT DISTINCT data_meczu, s.nazwa
FROM mistrzostwa.dbo.mecze AS m, mistrzostwa.dbo.stadiony AS s, mistrzostwa.dbo.reprezentacje AS r
WHERE r.kontynent = 'Europa' AND r.miejsce_w_rankingu_FIFA > 4 AND (r.id = m.id_reprezentacji_A 
OR r.id = m.id_reprezentacji_B) AND s.id = m.id_stadionu
GROUP BY data_meczu, s.nazwa

--9. Podaj daty oraz liczb� czerwonych kartek oraz imie i nazwisko s�dziego dla meczy, w kt�rych bra�y udzia� kraje o nieparzystym miejscu 
--w rankingu FIFA

SELECT data_meczu, zolte_kartki, imie, nazwisko, miejsce_w_rankingu_FIFA
FROM mistrzostwa.dbo.mecze AS m, mistrzostwa.dbo.statystyki_meczy AS st, mistrzostwa.dbo.sedziowie AS sd, 
mistrzostwa.dbo.reprezentacje AS r 
WHERE st.id_meczu = m.id AND m.id_sedziego = sd.id AND (m.id_reprezentacji_A = r.id OR m.id_reprezentacji_B = r.id)
AND r.miejsce_w_rankingu_FIFA %2 != 0 
GROUP BY data_meczu, imie, nazwisko, zolte_kartki, miejsce_w_rankingu_FIFA

--10. Podaj imiona i nazwiska wszystkich s�dzi�w i pi�karzy graj�cych meczach, kt�rych imi� ko�czy si� na liter� 'i' oraz liczb� tych meczy

SELECT p.imie, p.nazwisko, COUNT(m.id) AS ile_meczy
FROM mistrzostwa.dbo.pilkarze AS p, mistrzostwa.dbo.mecze AS m, mistrzostwa.DBO.reprezentacje AS r 
WHERE p.imie LIKE '%i' AND p.id_reprezentacji = r.id 
AND (r.id = m.id_reprezentacji_A OR r.id = m.id_reprezentacji_B)
GROUP BY p.imie, p.nazwisko
ORDER BY ile_meczy DESC

--11. Podaj imiona, nazwiska, wiek oraz reprezentacje obro�c�w kt�rzy brali udzia� w meczach, gdzie pad�y wi�cej ni� 3 gole samob�jcze

SELECT DISTINCT pil.imie, pil.nazwisko, (YEAR(GETDATE()) - YEAR(pil.data_ur)) AS wiekPilkarza, rep.nazwa
FROM mistrzostwa.dbo.pilkarze AS pil, mistrzostwa.dbo.reprezentacje AS rep, mistrzostwa.dbo.sedziowie AS sed,
mistrzostwa.dbo.mecze AS mecz, mistrzostwa.dbo.statystyki_meczy AS stat, mistrzostwa.dbo.pilkarze_pozycje as pilpoz,  
mistrzostwa.dbo.pozycje AS poz
WHERE stat.gole_samobojcze > 3 AND stat.id = mecz.id AND (mecz.id_reprezentacji_A = rep.id 
OR mecz.id_reprezentacji_B = rep.id) AND rep.id = pil.id_reprezentacji
AND pilpoz.id_pilkarza = pil.id AND pilpoz.id_pozycji = poz.id AND poz.nazwa = 'Obro�ca'
GROUP BY pil.imie, pil.nazwisko, pil.data_ur, sed.data_ur, rep.nazwa, sed.data_ur		

--12. Podaj terminy i stadiony meczy, kt�rych numer miesi�ca by� wi�kszy od numeru dnia oraz imi�, nazwisko oraz wiek s�dzi�w, kt�rzy 
--je s�dziowali 

SELECT data_meczu, nazwa, imie, nazwisko, (YEAR(GETDATE()) - YEAR(data_ur)) AS wiek
FROM mistrzostwa.dbo.mecze as mecz, mistrzostwa.dbo.sedziowie as sed, mistrzostwa.dbo.stadiony AS stad
WHERE sed.id = mecz.id_sedziego AND stad.id = mecz.id_stadionu AND MONTH(mecz.data_meczu) > DAY(mecz.data_meczu) 

--13. Podaj pozycje oraz kontynent pi�karzy dla meczy, kt�re odbywa�y si� na stadionie, kt�rego 4 liter� nazwy jest 'A'

SELECT DISTINCT poz.nazwa, kontynent, stad.nazwa 
FROM mistrzostwa.dbo.pilkarze AS pil, mistrzostwa.dbo.pilkarze_pozycje AS pilpoz, mistrzostwa.dbo.pozycje AS poz,
mistrzostwa.dbo.reprezentacje AS rep, mistrzostwa.dbo.mecze AS mecz, mistrzostwa.dbo.stadiony AS stad
WHERE poz.id = pilpoz.id_pozycji AND pil.id = pilpoz.id_pilkarza AND rep.id = pil.id_reprezentacji 
AND (rep.id = mecz.id_reprezentacji_A OR rep.id = mecz.id_reprezentacji_B) AND stad.id = mecz.id_stadionu 
AND SUBSTRING(stad.nazwa, 4, 1) = 'a'

--14. Podaj imiona i nazwiska pi�karzy i ich reprezentacje oraz kontynent, kt�rych ranking FIFA jest wi�kszy ni� suma ��tych i czerwonych 
--kartek dla poszczeg�lnych meczy, w kt�rych gra�y te reprezentacje

SELECT nazwa, imie, nazwisko
FROM mistrzostwa.dbo.pilkarze AS pil, mistrzostwa.dbo.reprezentacje AS rep, mistrzostwa.dbo.mecze AS mecz,
mistrzostwa.dbo.statystyki_meczy AS stat
WHERE pil.id_reprezentacji = rep.id AND (rep.id = mecz.id_reprezentacji_A OR rep.id = mecz.id_reprezentacji_B)
AND mecz.id = stat.id_meczu AND rep.miejsce_w_rankingu_FIFA > (stat.zolte_kartki + stat.czerwone_kartki) 
GROUP BY nazwa, imie, nazwisko

--15. Podaj daty meczy oraz reprezentacje, kt�re bra�y udzia� w tych meczach oraz nazwy stadion�w, gdzie pad�a parzysta ilo�� ��tych kartek 
--i posortuj wyniki rosn�co wed�ug liczby tych kartek

SELECT data_meczu, rep.nazwa, st.nazwa, zolte_kartki
FROM mistrzostwa.dbo.reprezentacje AS rep, mistrzostwa.dbo.mecze AS m, mistrzostwa.dbo.statystyki_meczy AS sm,
mistrzostwa.dbo.stadiony as st
WHERE (m.id_reprezentacji_A = rep.id OR m.id_reprezentacji_B = rep.id)
	  AND m.id_stadionu = st.id AND sm.id_meczu = m.id AND sm.zolte_kartki % 2 = 0
GROUP BY data_meczu, rep.nazwa, st.nazwa, zolte_kartki
ORDER BY zolte_kartki