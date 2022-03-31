/*

Data Cleaning in SQL Queries

*/

SELECT * 
FROM dbo.TreeCensus

------------------------------------------------------------------------------------------------------------

--Rename Columns wihtout Underscore

sp_rename 'dbo.TreeCensus.community board', 'community_board', 'COLUMN';

sp_rename 'dbo.TreeCensus.census tract', 'census_tract', 'COLUMN';

sp_rename 'dbo.TreeCensus.council district', 'council_district', 'COLUMN';

---------------------------------------------------------------------------------------------------

--Remove Columns Not Needed

SELECT * 
INTO BackupTreeCensus
FROM dbo.TreeCensus

SELECT * FROM BackupTreeCensus

ALTER TABLE dbo.TreeCensus
DROP COLUMN block_id, created_at, spc_common, guards, user_type, address, postcode,
			zip_city, community_board, borocode, borough, cncldist, st_assem, st_senate,
			nta, nta_name, boro_ct, state, latitude, longitude, x_sp, y_sp, council_district,
			census_tract, bin, bbl

--------------------------------------------------------------------------------------------------


--Replace NULL to 'Not Applicable' for Dead or Stump Trees ONLY

UPDATE dbo.TreeCensus
SET health = 'Not Applicable',
	spc_latin = 'Not Applicable',
	steward = 'Not Applicable',
	sidewalk = 'Not Applicable',
	problems = 'Not Applicable'
WHERE status like 'Dead' or status like 'Stump'
	and health is null or spc_latin is null or steward is null 
	or sidewalk is null or problems is null
	--null in (health, spc_latin, steward, sidewalk, problems)
	
SELECT * FROM dbo.TreeCensus

--Check for NULLS

SELECT status, health, spc_latin, steward, sidewalk, problems
FROM dbo.TreeCensus
WHERE health is null or spc_latin is null or steward is null 
	or sidewalk is null or problems is null

SELECT  health, count(*)
FROM dbo.TreeCensus
GROUP BY health

--Replace the 1 Health Null with the most common health condition
	--We do not want to delete it and have it effect the actual count of Alive trees

UPDATE dbo.TreeCensus
SET health = 'Good'	
WHERE health is null

------------------------------------------------------------------------------------------------------------------

--Checking for Duplicates

SELECT tree_id, count(*)
FROM dbo.TreeCensus
GROUP BY tree_id
HAVING count(*) > 1

------------------------------------------------------------------------------------------------------------------------------

--Seperate Dataset for Alive Trees and Dead and Stump trees
	--will remove 0's from stump_diam from DeadTrees and AliveTrees table, therefore not affecting StumpTrees stump_diam mean
	--will remove 0's from tree_dbh from AliveTrees table, therefore not affecting AliveTrees tree_dbh mean 

SELECT status, count(*)
FROM dbo.TreeCensus
WHERE status = 'Dead' or  status = 'Stump'
GROUP BY status
--dead = 17654 rows, stump = 13961 rows, total = 31,615 rows

SELECT *
FROM dbo.TreeCensus
WHERE status = 'Dead' or  status = 'Stump'
--Results : 31615 rows

SELECT *
INTO DeadTrees
FROM dbo.TreeCensus
WHERE status = 'Dead' 

SELECT *
FROM DeadTrees

SELECT *
INTO StumpTrees
FROM dbo.TreeCensus
WHERE status = 'Stump' 

SELECT *
FROM StumpTrees

SELECT *
INTO AliveTrees
FROM dbo.TreeCensus
WHERE status = 'Alive'

SELECT *
From AliveTrees

-----------------------------------------------------------------------------------------------------------------------------

--Removing More Columns

ALTER TABLE DeadTrees
DROP COLUMN stump_diam

ALTER TABLE StumpTrees
DROP COLUMN tree_dbh

ALTER TABLE AliveTrees
DROP COLUMN stump_diam
