							-- Table containing the countries Yearly totals and Yearly Averages
							
--SELECT zm.Year,
--Round(((zm.January+zm.February+zm.March+zm.April+zm.May+zm.June+zm.July+zm.August+zm.September+zm.October+zm.November+zm.December)/12), 2)AS "Zambia_YrlyAvg",
--(zm.January+zm.February+zm.March+zm.April+zm.May+zm.June+zm.July+zm.August+zm.September+zm.October+zm.November+zm.December)AS "Zambia_Yearly",
--Round(((ug.January+ug.February+ug.March+ug.April+ug.May+ug.June+ug.July+ug.August+ug.September+ug.October+ug.November+ug.December)/12), 2)AS "Uganda_YrlyAvg",
--(ug.January+ug.February+ug.March+ug.April+ug.May+ug.June+ug.July+ug.August+ug.September+ug.October+ug.November+ug.December)AS "Uganda_Yearly",
--Round(((tz.January+tz.February+tz.March+tz.April+tz.May+tz.June+tz.July+tz.August+tz.September+tz.October+tz.November+tz.December)/12), 2)AS "Tanzania_YrlyAvg",
--(tz.January+tz.February+tz.March+tz.April+tz.May+tz.June+tz.July+tz.August+tz.September+tz.October+tz.November+tz.December)AS "Tanzania_Yearly",
--Round(((mo.January+mo.February+mo.March+mo.April+mo.May+mo.June+mo.July+mo.August+mo.September+mo.October+mo.November+mo.December)/12), 2)AS "Mozambique_YrlyAvg",
--(mo.January+mo.February+mo.March+mo.April+mo.May+mo.June+mo.July+mo.August+mo.September+mo.October+mo.November+mo.December)AS "Mozambique_Yearly",
--Round(((ma.January+ma.February+ma.March+ma.April+ma.May+ma.June+ma.July+ma.August+ma.September+ma.October+ma.November+ma.December)/12), 2)AS "Malawi_YrlyAvg",
--(ma.January+ma.February+ma.March+ma.April+ma.May+ma.June+ma.July+ma.August+ma.September+ma.October+ma.November+ma.December)AS "Malawi_Yearly",
--Round(((ke.January+ke.February+ke.March+ke.April+ke.May+ke.June+ke.July+ke.August+ke.September+ke.October+ke.November+ke.December)/12), 2)AS "Kenya_YrlyAvg",
--(ke.January+ke.February+ke.March+ke.April+ke.May+ke.June+ke.July+ke.August+ke.September+ke.October+ke.November+ke.December)AS "Kenya_Yearly"
--FROM Zambia zm Join Uganda ug
--On zm.Year = ug.Year
--Join Tanzania tz
--On zm.Year = tz.Year
--Join Mozambique mo
--On zm.Year = mo.Year
--Join Malawi ma
--On zm.Year = ma.Year
--Join Kenya ke
--On zm.Year = ke.Year
--Where zm.Year BETWEEN 1998 AND 2018;
							


							--Seasons by country

--		Zambia		Uganda				Tanzania				Mozambique		Malawi		Kenya
--Hot	Aug-Nov		Dec-Feb, Jun-Aug	Feb						May-Oct						Dec-Mar, 
--Rain	Nov-Apr		Mar-May,Sep-Dec		Mar-May(H),Nov-Jan		Nov-Apr			Nov-Apr		Mar-May, Oct-Dec
--Cool	Apr-Aug							May-Oct									May-Oct		Jun-Oct

				--Procedure that takes  a pair of years to get data of that countrys rain season
				-- Malawi, Mozambique and Zambia share the same rain season and so share a procedure
				-- CTE holds the data and calculations performed on it

--Create Procedure ZamMozMal_seasons @yr1 float, @yr2 float
--AS
--WITH CTE_ZmMzMa AS(
--	Select 'Malawi' as Country, Year, Concat(zmb.Year-1,'-',Year) As Season,
--				(Select November 
--				 From Malawi 
--				 Where Year = zmb.Year-1) As November,
--				(Select December 
--				 From Malawi 
--				 Where Year = zmb.Year-1) As December, 
--		January,February,March,April
--	From Malawi zmb
--	Where Year Between @yr1+1 and @yr2
--	Union
--	Select 'Mozambique' as Country, Year, Concat(zmb.Year-1,'-',Year) As Season,
--				(Select November 
--				 From Mozambique 
--				 Where Year = zmb.Year-1) As November,
--				(Select December 
--				 From Mozambique 
--				 Where Year = zmb.Year-1) As December, 
--		January,February,March,April
--	From Mozambique zmb
--	Where Year Between @yr1+1 and @yr2
--	Union
--	Select 'Zambia' as Country, Year, Concat(zmb.Year-1,'-',Year) As Season,
--				(Select November 
--				 From Zambia 
--				 Where Year = zmb.Year-1) As November,
--				(Select December 
--				 From Zambia 
--				 Where Year = zmb.Year-1) As December, 
--		January,February,March,April
--	From Zambia zmb
--	Where Year Between @yr1+1 and @yr2
--)

--Select *,(November+December+January+February+March+April)AS "SeasonalRain/mm",
--	Round(((November+December+January+February+March+April)/6),2)AS "AvgSeasonalRain/mm"
--From CTE_ZmMzMa;



					-- Kenya rain season procedure
					-- Mar-May(LongRains), Oct-Dec(ShortRains)
--Create Procedure Kenya_seasons @yr1 float, @yr2 float
--AS
--Select (Year) AS Season, March, April, May,
--	  (March+April+May) AS 'LongRains', 
--	   October, November, December, 
--	  (October+November+December) AS 'ShortRains',
--	  (March+April+May+October+November+December) AS "SeasonalRain",
--	  (Round((March+April+May+October+November+December)/6, 2)) AS "AvgSeasonalRain"
--From Kenya
--Where Year Between @yr1 And @yr2;


				--Tanzania season procedure
				--Mar-May(HeavyRains),Nov-Jan(ShortRains)
--Create Procedure Tanzania_seasons @yr1 float, @yr2 float
--AS
---WITH CTE_Tanzania AS(
--	Select Year,Concat(tz.Year,'-',Year+1) AS Season, March, April, May, November, December,
--			(Select January 
--			From Tanzania
--			Where Year = tz.Year + 1) As January
--	From Tanzania tz
--	Where Year Between @yr1 And @yr2
--)

--Select *,(March+April+May) AS 'HeavyRains',
--	  (November+December+January) AS 'ShortRains',
--	  (March+April+May+November+December+January) AS "SeasonalRain",
--	  (Round((March+April+May+November+December+January)/6, 2)) AS "AvgSeasonalRain"
--From CTE_Tanzania;

						--Uganda Season procedure
						--Mar-May(LongRains),Sep-Dec(ShortRains)

--Create Procedure Uganda_seasons @yr1 float, @yr2 float
--AS
--Select Year AS Season, March, April, May,
--		(March+April+May) AS 'LongRains', 
--		September,October, November, December, 
--		(October+November+December) AS 'ShortRains',
--		(March+April+May+October+November+December) AS "SeasonalRain",
--		(Round((March+April+May+October+November+December)/6, 2)) AS "AvgSeasonalRain"
--From Uganda
--Where Year Between @yr1 And @yr2;


			-- Execute the above procedures


--Zambia
--Select *
--From Zambia
--Where Year Between 1998 And 2018;
--EXEC ZamMozMal_seasons @yr1= 1998, @yr2= 2018, @country = "Zambia"

--Mozambique
--Select *
--From Mozambique
--Where Year Between 1998 And 2018;
--EXEC ZamMozMal_seasons @yr1= 1998, @yr2= 2018, @country = "Mozambique"

--Malawi
--Select *
--From Malawi
--Where Year Between 1998 And 2018;
--EXEC ZamMozMal_seasons @yr1= 1998, @yr2= 2018, @country = "Malawi"

--Kenya
--Select *
--From Kenya
--Where Year Between 1998 And 2018
--EXEC Kenya_seasons @yr1= 1998, @yr2= 2017;

--Tanzania
--Select *
--From Tanzania
--Where Year Between 1998 And 2018
--EXEC Tanzania_seasons @yr1= 1998, @yr2= 2017;

-- Uganda
--Select *
--From Uganda
--Where Year Between 1998 And 2018
--EXEC Uganda_seasons @yr1= 1998, @yr2= 2017;

				--Temp Tables to hold seasonal data to be analysed and later visualised 
				
		---Zambia, Mozambique, Malawi---

--Create table #tempZaMzMa(
--	 Country nvarchar(30),
--	 Year float, 
--	 Seasons nvarchar(10),
--	 November float, 
--	 December Float, 
--	 January Float, 
--	 February Float, 
--	 March Float, 
--	 April Float,
--	 SeasonalRain Float,
--	 AvgSeasonalRain Float
-- )

--Insert #tempZaMzMa
--EXEC ZamMozMal_seasons @yr1= 1998, @yr2= 2018

--Select *
--From #tempZaMzMa

--Drop Table #tempZaMzMa

		--Tanzania---

--Create table #tempTz(
--	 Year float, 
--	 Seasons nvarchar(10),
--	 March float, 
--	 April Float, 
--	 May Float, 
--	 November Float, 
--	 December Float, 
--	 January Float,
--	 HeavyRains Float,
--	 ShortRains Float,
--	 SeasonalRain Float,
--	 AvgSeasonalRain Float
--)
--Insert #tempTz 
--EXEC Tanzania_seasons @yr1= 1998, @yr2= 2017;

--Select *
--From #tempTz

--Drop Table #tempTz

--		--Kenya---

--Create table #tempKy(
--	 Seasons float(10),
--	 March float, 
--	 April Float, 
--	 May Float,
--	 LongRains Float,
--	 October Float,
--	 November Float, 
--	 December Float, 
--	 ShortRains Float,
--	 SeasonalRain Float,
--	 AvgSeasonalRain Float
--)

--Insert #tempKy 
--EXEC Kenya_seasons @yr1= 1998, @yr2= 2017;

--Drop Table #tempKy

--Select *
--From #tempKy

--		--Uganda---

--Create table #tempUg(
--	 Year float, 
--	 March float, 
--	 April Float, 
--	 May Float,
--	 LongRains Float,
--	 September Float,
--	 October Float,
--	 November Float, 
--	 December Float, 
--	 ShortRains Float,
--	 SeasonalRain Float,
--	 AvgSeasonalRain Float
--)

--Insert #tempUg 
--EXEC Uganda_seasons @yr1= 1998, @yr2= 2017;

--Select *
--From #tempUg

--Drop Table #tempUg

			--- Gets the Seasonal totals from the Temp Tables


--Select Distinct(zmm.Year), zmm.Seasons,(Select SeasonalRain 
--							  From #tempZaMzMa 
--							  where Country = 'Malawi' 
--							  And Year = zmm.YEAR) As 'Malawi_Seasonal',
--							  (Select SeasonalRain 
--							  From #tempZaMzMa 
--							  where Country = 'Mozambique' 
--							  And Year = zmm.YEAR) As 'Mozambique_Seasonal', 
--							  (Select SeasonalRain 
--							  From #tempZaMzMa 
--							  where Country = 'Zambia' 
--							  And Year = zmm.YEAR) As 'Zambia_Seasonal'
--From #tempZaMzMa zmm

							--Create CTE's that hold the annual and average rainfall data
						--Joining the CTE's with above Temp tables to compare with seasonal data

		--Kenya

--WITH CTE_kenya AS
--(
--	SELECT *, Round(((January+February+March+April+May+June+July+August+September+October+November+December)/12), 2)AS "Yearly_Avg",
--	(January+February+March+April+May+June+July+August+September+October+November+December)AS "Yearly"
--	FROM Kenya
--	Where Year BETWEEN 1998 AND 2017
--)
	
----Select *
----From CTE_Kenya

--SELECT tmp.Seasons, tmp.SeasonalRain, ct.Yearly, ct.Yearly_Avg,tmp.AvgSeasonalRain
--From CTE_kenya ct
--Join #tempKy tmp
--ON ct.Year =  tmp.Seasons


--		Malawi

--WITH CTE_Malawi AS
--(
--SELECT *, Round(((January+February+March+April+May+June+July+August+September+October+November+December)/12), 2)AS "Yearly_Avg",
--(January+February+March+April+May+June+July+August+September+October+November+December)AS "Yearly"
--FROM Malawi
--Where Year BETWEEN 1998 AND 2018
--)

------Select *
------From CTE_Malawi

--SELECT tmp.Year, tmp.Seasons,SeasonalRain, ct.Yearly, ct.Yearly_Avg,tmp.AvgSeasonalRain
--From CTE_Malawi ct
--Join #tempZaMzMa tmp
--ON ct.Year =  tmp.Year
--Where tmp.Country = 'Malawi'

--		Mozambique

--WITH CTE_Mozambique AS
--(
--SELECT *, Round(((January+February+March+April+May+June+July+August+September+October+November+December)/12), 2)AS "Yearly_Avg",
--(January+February+March+April+May+June+July+August+September+October+November+December)AS "Yearly"
--FROM Mozambique
--Where Year BETWEEN 1998 AND 2018
--)

----Select *
----From CTE_Mozambique

--SELECT tmp.Year, tmp.Seasons,SeasonalRain, ct.Yearly, ct.Yearly_Avg,tmp.AvgSeasonalRain
--From CTE_Mozambique ct
--Join #tempZaMzMa tmp
--ON ct.Year =  tmp.Year
--Where tmp.Country = 'Mozambique'


--		Zambia

--WITH CTE_Zambia AS
--(
--SELECT *, Round(((January+February+March+April+May+June+July+August+September+October+November+December)/12), 2)AS "Yearly_Avg",
--(January+February+March+April+May+June+July+August+September+October+November+December)AS "Yearly"
--FROM Mozambique
--Where Year BETWEEN 1998 AND 2018
--)

----Select *
----From CTE_Zambia

--SELECT tmp.Year, tmp.Seasons,SeasonalRain, ct.Yearly, ct.Yearly_Avg,tmp.AvgSeasonalRain
--From CTE_Zambia ct
--Join #tempZaMzMa tmp
--ON ct.Year =  tmp.Year
--Where tmp.Country = 'Zambia'


--		Tanzania

--WITH CTE_Tanzania AS
--(
--SELECT *, Round(((January+February+March+April+May+June+July+August+September+October+November+December)/12), 2)AS "Yearly_Avg",
--(January+February+March+April+May+June+July+August+September+October+November+December)AS "Yearly"
--FROM Tanzania
--Where Year BETWEEN 1998 AND 2017
--)

----Select *
----From CTE_Tanzania

--SELECT tmp.Year, tmp.Seasons, tmp.SeasonalRain, ct.Yearly, ct.Yearly_Avg,tmp.AvgSeasonalRain
--From CTE_Tanzania ct
--Join #tempTz tmp
--ON ct.Year =  tmp.Year

--		Uganda

WITH CTE_Uganda AS
(
SELECT *, Round(((January+February+March+April+May+June+July+August+September+October+November+December)/12), 2)AS "Yearly_Avg",
(January+February+March+April+May+June+July+August+September+October+November+December)AS "Yearly"
FROM Uganda
Where Year BETWEEN 1998 AND 2017
)

----Select *
----From CTE_Uganda

SELECT tmp.Year, tmp.SeasonalRain, ct.Yearly, ct.Yearly_Avg,tmp.AvgSeasonalRain
From CTE_Uganda ct
Join #tempUg tmp
ON ct.Year =  tmp.Year


		--Disaster Data exploration
		--Get the type and number of disasters in a monthfor each year in each country

--Select * 
--From Disaster_Data
--Order By Country Asc,Start_Date Asc;

--Select Country, Count(DisNo)As "No_Of_Disasters" ,Disaster_Type, Year, Month(Start_date) As "Month", Origin
--From Disaster_Data
--Group By Disaster_Type,Year, Month(Start_date), Country, Origin
--Order By Country Asc, Year, Month(Start_date) Asc;

		--***Will be left out due to missing data once a complete dataset is found or missing data is found will be used in the 
		-- crop segment.. 
