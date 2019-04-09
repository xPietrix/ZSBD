-- 1. Usuwanie meczy starszych ni¿ podana iloœæ lat.
drop procedure procedura1

go
create procedure procedura1 @lata int = 2
as
begin
	delete from mistrzostwa..mecze
	where datediff(day,data_meczu,getdate()) > @lata*365
end

--Przyk³ad wywo³ania

Select data_meczu from mistrzostwa.dbo.mecze order by data_meczu

exec procedura1 1

Select data_meczu from mistrzostwa.dbo.mecze order by data_meczu

--2. Dodawanie nowego sêdziego
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
		print 'Wyst¹pi³ b³¹d. Nie podano imienia, nazwiska, kraju lub daty urodzenia.'
	end
	else
	begin
		insert into mistrzostwa..sedziowie values (@imie, @nazwisko, @data_ur,  @kraj)
		print 'Pomyœlnie dodano sêdziego (imiê: ' + @imie + ', nazwisko: ' + @nazwisko + 
			  + ', kraj: ' + @kraj + ', data urodzenia: ' + cast(@data_ur as varchar) + ')'
	end
end
go

Select imie, nazwisko, data_ur, kraj From mistrzostwa .dbo.sedziowie 

--Przyklad wywo³ania
exec procedura2 'Tom','Butcher','1980-01-01', 'Francja'

Select imie, nazwisko, data_ur, kraj From mistrzostwa .dbo.sedziowie 

delete from mistrzostwa.dbo.sedziowie where imie = 'Tom' and nazwisko = 'Butcher'

--3. Zmiana numeru pi³karza o podanym imieniu, nazwisku, reprezentacji i starym numerze na podany numer
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
		print 'Wyst¹pi³ b³¹d. Podano b³êdne parametry.'
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
			print	'Pomyœlnie zmieniono numer pi³karza
			
			imiê: ' + @imie + ' nazwisko: ' + @nazwisko + ' reprezentacja: ' + @reprezentacja 
			+ ' stary numer: ' + cast(@snum as varchar(3)) + ' nowy numer: ' + cast(@nnum as varchar(3))
		end
		else
		begin
			print 'Wyst¹pi³ b³¹d. Nie znaleziono pi³karza.'
		end
		
	end
end

select * from mistrzostwa..pilkarze where nazwisko = 'Muller'
exec procedura3 'Thomas', 'Muller', 'Niemcy', 10, 17

select * from mistrzostwa..pilkarze

-- 4. Nazwa stadionu który znajduje siê w danym mieœcie lub informacja, ¿e nie ma ¿adnych stadionów w podanym mieœcie
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
		print 'Nie znaleziono ¿adnego stadionu w mieœcie '+ @miasto + '.'
	end
end
go
exec procedura4 'Moskwa'
exec procedura4 'Warszawa'

-- 5. Zwraca najwiêksz¹ liczbê goli samobójczych jaka pad³a w meczu
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
print 'Najwiêksza liczba goli samobójczych jaka pad³a w meczu to: ' +  cast(@a as varchar(3))

select MAX(gole_samobojcze) as najwiecej_goli_samobojczych from mistrzostwa.dbo.statystyki_meczy 

--ZAPYTANIA

--1. Podaj imiê, nazwisko, reprezentacjê oraz wiek najm³odszego pi³karza zawodów

SELECT imie, nazwisko, nazwa, (YEAR(GETDATE()) - YEAR(data_ur)) AS wiek
FROM mistrzostwa.dbo.pilkarze AS p, mistrzostwa.dbo.reprezentacje AS r
WHERE data_ur = (SELECT MAX(data_ur)
	   			 FROM mistrzostwa.dbo.pilkarze)
AND p.id_reprezentacji = r.id

--2. Podaj œredni wiek dla pi³karzy z numerem 9

SELECT AVG(YEAR(GETDATE()) - YEAR(data_ur)) AS sredni_wiek
FROM mistrzostwa.dbo.pilkarze
WHERE mistrzostwa.dbo.pilkarze.numer = 9				

--3. Podaj imiona i nazwiska pi³karzy, graj¹cych na pozycji napastnik; których reprezentacje zajmuj¹ miejsce wy¿sze ni¿ 10 w rankingu FIFA

SELECT imie, nazwisko, rep.nazwa
FROM mistrzostwa.dbo.pilkarze AS pil, mistrzostwa.dbo.pilkarze_pozycje AS pilpoz, mistrzostwa.dbo.pozycje AS poz,
	 mistrzostwa.dbo.reprezentacje AS rep
WHERE pilpoz.id_pilkarza = pil.id AND pilpoz.id_pozycji = poz.id AND poz.nazwa = 'Napastnik' 
	  AND pil.id_reprezentacji = rep.id	AND rep.miejsce_w_rankingu_FIFA < 10 

--4. Podaj datê/daty meczu/y i nazwê stadionu na którym wtedy grano, gdy pad³o najwiêcej goli samobójczych 

SELECT data_meczu, gole_samobojcze, nazwa     
FROM mistrzostwa.dbo.mecze AS m, mistrzostwa.dbo.statystyki_meczy AS sm, mistrzostwa.dbo.stadiony AS s
WHERE gole_samobojcze = (SELECT MAX(gole_samobojcze)
							FROM mistrzostwa.dbo.statystyki_meczy) 
AND m.id_stadionu = s.id AND m.id = sm.id_meczu

--5. Podaj pañstwa z Ameryki Po³udniowej, których reprezentacje otrzyma³y w meczu wiêcej ni¿ 2 czerwone kartki 

SELECT nazwa
FROM mistrzostwa.dbo.reprezentacje AS r, mistrzostwa.dbo.statystyki_meczy AS sm, mistrzostwa.dbo.mecze AS m
WHERE r.kontynent = 'Ameryka Po³udniowa' AND (  r.id = m.id_reprezentacji_B or r.id = m.id_reprezentacji_A ) 
AND m.id = sm.id AND sm.czerwone_kartki > 2
GROUP BY nazwa 

--6. Podaj miasto oraz nazwê stadionu na którym rozegrano najwiêcej meczy typu 'Grupowy' oraz liczbê tych meczy

SELECT TOP 1 miasto, nazwa, COUNT (id_stadionu) AS ile_meczy
FROM  mistrzostwa.dbo.mecze AS m, mistrzostwa.dbo.stadiony AS s
WHERE m.id_stadionu = s.id AND m.typ_meczu = 'Grupowy'
GROUP BY nazwa, miasto
ORDER BY ile_meczy DESC

--7. Podaj imiê, nazwisko, kraj pochodzenia oraz wiek najstarszego sêdziego, który sêdziowa³ w meczu na stadionie, którego nazwa zaczyna siê 
--na "S"

SELECT imie, nazwisko, (YEAR(GETDATE()) - YEAR(data_ur)) AS wiek, kraj, nazwa
FROM mistrzostwa.dbo.sedziowie as sd, mistrzostwa.dbo.mecze AS m, mistrzostwa.dbo.stadiony AS s
WHERE data_ur = (SELECT MIN(data_ur)
				 FROM mistrzostwa.dbo.sedziowie)
AND m.id_sedziego = sd.id AND m.id_stadionu = s.id AND s.nazwa LIKE 's%'
GROUP BY imie, nazwisko, data_ur, kraj, nazwa 

--8. Podaæ terminy oraz nazwy stadionów i wszystkich meczy w których bra³y udzia³ reprezentacje z Europyo miejscu w rankingu FIFA nizszym niz 4

SELECT DISTINCT data_meczu, s.nazwa
FROM mistrzostwa.dbo.mecze AS m, mistrzostwa.dbo.stadiony AS s, mistrzostwa.dbo.reprezentacje AS r
WHERE r.kontynent = 'Europa' AND r.miejsce_w_rankingu_FIFA > 4 AND (r.id = m.id_reprezentacji_A 
OR r.id = m.id_reprezentacji_B) AND s.id = m.id_stadionu
GROUP BY data_meczu, s.nazwa

--9. Podaj daty oraz liczbê czerwonych kartek oraz imie i nazwisko sêdziego dla meczy, w których bra³y udzia³ kraje o nieparzystym miejscu 
--w rankingu FIFA

SELECT data_meczu, zolte_kartki, imie, nazwisko, miejsce_w_rankingu_FIFA
FROM mistrzostwa.dbo.mecze AS m, mistrzostwa.dbo.statystyki_meczy AS st, mistrzostwa.dbo.sedziowie AS sd, 
mistrzostwa.dbo.reprezentacje AS r 
WHERE st.id_meczu = m.id AND m.id_sedziego = sd.id AND (m.id_reprezentacji_A = r.id OR m.id_reprezentacji_B = r.id)
AND r.miejsce_w_rankingu_FIFA %2 != 0 
GROUP BY data_meczu, imie, nazwisko, zolte_kartki, miejsce_w_rankingu_FIFA

--10. Podaj imiona i nazwiska wszystkich sêdziów i pi³karzy graj¹cych meczach, których imiê koñczy siê na literê 'i' oraz liczbê tych meczy

SELECT p.imie, p.nazwisko, COUNT(m.id) AS ile_meczy
FROM mistrzostwa.dbo.pilkarze AS p, mistrzostwa.dbo.mecze AS m, mistrzostwa.DBO.reprezentacje AS r 
WHERE p.imie LIKE '%i' AND p.id_reprezentacji = r.id 
AND (r.id = m.id_reprezentacji_A OR r.id = m.id_reprezentacji_B)
GROUP BY p.imie, p.nazwisko
ORDER BY ile_meczy DESC

--11. Podaj imiona, nazwiska, wiek oraz reprezentacje obroñców którzy brali udzia³ w meczach, gdzie pad³y wiêcej ni¿ 3 gole samobójcze

SELECT DISTINCT pil.imie, pil.nazwisko, (YEAR(GETDATE()) - YEAR(pil.data_ur)) AS wiekPilkarza, rep.nazwa
FROM mistrzostwa.dbo.pilkarze AS pil, mistrzostwa.dbo.reprezentacje AS rep, mistrzostwa.dbo.sedziowie AS sed,
mistrzostwa.dbo.mecze AS mecz, mistrzostwa.dbo.statystyki_meczy AS stat, mistrzostwa.dbo.pilkarze_pozycje as pilpoz,  
mistrzostwa.dbo.pozycje AS poz
WHERE stat.gole_samobojcze > 3 AND stat.id = mecz.id AND (mecz.id_reprezentacji_A = rep.id 
OR mecz.id_reprezentacji_B = rep.id) AND rep.id = pil.id_reprezentacji
AND pilpoz.id_pilkarza = pil.id AND pilpoz.id_pozycji = poz.id AND poz.nazwa = 'Obroñca'
GROUP BY pil.imie, pil.nazwisko, pil.data_ur, sed.data_ur, rep.nazwa, sed.data_ur		

--12. Podaj terminy i stadiony meczy, których numer miesi¹ca by³ wiêkszy od numeru dnia oraz imiê, nazwisko oraz wiek sêdziów, którzy 
--je sêdziowali 

SELECT data_meczu, nazwa, imie, nazwisko, (YEAR(GETDATE()) - YEAR(data_ur)) AS wiek
FROM mistrzostwa.dbo.mecze as mecz, mistrzostwa.dbo.sedziowie as sed, mistrzostwa.dbo.stadiony AS stad
WHERE sed.id = mecz.id_sedziego AND stad.id = mecz.id_stadionu AND MONTH(mecz.data_meczu) > DAY(mecz.data_meczu) 

--13. Podaj pozycje oraz kontynent pi³karzy dla meczy, które odbywa³y siê na stadionie, którego 4 liter¹ nazwy jest 'A'

SELECT DISTINCT poz.nazwa, kontynent, stad.nazwa 
FROM mistrzostwa.dbo.pilkarze AS pil, mistrzostwa.dbo.pilkarze_pozycje AS pilpoz, mistrzostwa.dbo.pozycje AS poz,
mistrzostwa.dbo.reprezentacje AS rep, mistrzostwa.dbo.mecze AS mecz, mistrzostwa.dbo.stadiony AS stad
WHERE poz.id = pilpoz.id_pozycji AND pil.id = pilpoz.id_pilkarza AND rep.id = pil.id_reprezentacji 
AND (rep.id = mecz.id_reprezentacji_A OR rep.id = mecz.id_reprezentacji_B) AND stad.id = mecz.id_stadionu 
AND SUBSTRING(stad.nazwa, 4, 1) = 'a'

--14. Podaj imiona i nazwiska pi³karzy i ich reprezentacje oraz kontynent, których ranking FIFA jest wiêkszy ni¿ suma ¿ó³tych i czerwonych 
--kartek dla poszczególnych meczy, w których gra³y te reprezentacje

SELECT nazwa, imie, nazwisko
FROM mistrzostwa.dbo.pilkarze AS pil, mistrzostwa.dbo.reprezentacje AS rep, mistrzostwa.dbo.mecze AS mecz,
mistrzostwa.dbo.statystyki_meczy AS stat
WHERE pil.id_reprezentacji = rep.id AND (rep.id = mecz.id_reprezentacji_A OR rep.id = mecz.id_reprezentacji_B)
AND mecz.id = stat.id_meczu AND rep.miejsce_w_rankingu_FIFA > (stat.zolte_kartki + stat.czerwone_kartki) 
GROUP BY nazwa, imie, nazwisko

--15. Podaj daty meczy oraz reprezentacje, które bra³y udzia³ w tych meczach oraz nazwy stadionów, gdzie pad³a parzysta iloœæ ¿ó³tych kartek 
--i posortuj wyniki rosn¹co wed³ug liczby tych kartek

SELECT data_meczu, rep.nazwa, st.nazwa, zolte_kartki
FROM mistrzostwa.dbo.reprezentacje AS rep, mistrzostwa.dbo.mecze AS m, mistrzostwa.dbo.statystyki_meczy AS sm,
mistrzostwa.dbo.stadiony as st
WHERE (m.id_reprezentacji_A = rep.id OR m.id_reprezentacji_B = rep.id)
	  AND m.id_stadionu = st.id AND sm.id_meczu = m.id AND sm.zolte_kartki % 2 = 0
GROUP BY data_meczu, rep.nazwa, st.nazwa, zolte_kartki
ORDER BY zolte_kartki