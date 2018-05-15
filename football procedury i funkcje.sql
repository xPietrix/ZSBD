-- 1. Usuwanie meczy starszych ni¿ podana iloœæ lat.
if exists(select 1 from sys.objects where TYPE = 'P' and name = 'proc1')
drop procedure proc1

create procedure proc1 @lata int = 20
as
begin
	delete from football..mecze
	where datediff(day,data_meczu,getdate()) > @lata*365
end
select * from football..mecze
exec proc1 15
select * from football..mecze

-- 2. Dodawanie nowego sêdziego 
if exists(select 1 from sys.objects where TYPE = 'P' and name = 'proc2')
drop procedure proc2

create procedure proc2 @imie varchar(20) = null, @nazwisko varchar(20) = null
as 
begin
	if @imie is null or @nazwisko is null
	begin
		print 'Wyst¹pi³ b³¹d. Nie podano imienia lub nazwiska.'
	end
	else
	begin
		insert into football..sedziowie values (@imie,@nazwisko)
		print 'Pomyœlnie dodano sêdziego (imiê: ' + @imie + ', nazwisko: ' + @nazwisko + ')'
	end
end
go
exec proc2 'Howard','Webb'
exec proc2 'Robert'


-- 3. Zmiana numeru pi³karza o podanym imieniu, nazwisku, dru¿ynie, starym i nowym numerze
if exists(select 1 from sys.objects where TYPE = 'P' and name = 'proc3')
drop procedure proc3

create procedure proc3	@imie varchar(20) = null,
						@nazwisko varchar(20) = null,
						@druzyna varchar(40) = null,
						@snum int = 0,
						@nnum int = 0
as 
begin
	if @imie is null or @nazwisko is null or @druzyna is null or @snum = 0 or @nnum = 0
	begin
		print 'Wyst¹pi³ b³¹d. Podano b³êdne parametry.'
	end
	else
	begin
		declare @ile int
		set @ile =	(select count(*)
					from football..pilkarze 
					where imie = @imie and nazwisko = @nazwisko and numer = @snum 
					and id_druzyna = (select id from football..druzyny where nazwa = @druzyna))
		if @ile = 1
		begin
			update football..pilkarze
			set numer = @nnum
			where imie = @imie and nazwisko = @nazwisko and numer = @snum 
			and id_druzyna = (select id from football..druzyny where nazwa = @druzyna)
			print	'Pomyœlnie zmieniono numer pi³karza
imiê: ' + @imie + '
nazwisko: ' + @nazwisko + '
dru¿yna: ' + @druzyna + '
stary numer: ' + cast(@snum as varchar(3)) + '
nowy numer: ' + cast(@nnum as varchar(3))
		end
		else
		begin
			print 'Wyst¹pi³ b³¹d. Nie znaleziono pi³karza.'
		end
		
	end
end
go
select top 1 * from football..pilkarze
exec proc3 'Dusan', 'Kuciak', 'Legia Warszawa', 12, 1
select top 1 * from football..pilkarze
exec proc3 'Kusan', 'Duciak', 'Legia Warszawa', 12, 1
exec proc3 'Kusan'


-- 4. Nazwa i ulica miejsca z danego miasta lub informacja,
-- ¿e nie ma ¿adnych miejsc w podanym mieœcie
if exists(select 1 from sys.objects where TYPE = 'P' and name = 'proc4')
drop procedure proc4

create procedure proc4 @miasto varchar(20) = null
as 
begin
	declare @ile int
	set @ile = (select count(*) from football..miejsca where miasto = @miasto)
	if @ile > 0
	begin
		select m.nazwa, m.ulica
		from football..miejsca m
		where m.miasto = @miasto
	end
	else
	begin
		print 'Nie znaleziono ¿adnego miejsca w mieœcie '+ @miasto + '.'
	end
end
go
exec proc4 'Wroc³aw'
exec proc4 'Warszawa'

-- 5. Zwraca liczbê goli strzelonych przez najskuteczniejszego strzelca
drop function fun

create function fun() returns int
begin
	declare @ile int = 0
	set @ile = (select top 1 sum(s.gole) as gole
				from football..pilkarze as p
				join football..sklady as s on s.id_pilkarz = p.id
				group by p.id, p.imie, p.nazwisko
				order by sum(s.gole) desc)
	return @ile
end

declare @a int
exec @a = fun
print 'Liczba goli strzelonych przez najskuteczniejszego strzelca: ' +  cast(@a as varchar(3))


