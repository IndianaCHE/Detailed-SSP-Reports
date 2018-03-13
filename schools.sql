SET NOCOUNT ON;
SELECT DISTINCT
sch.SchoolID,
REPLACE(sch.Name, ',', '') AS School,
REPLACE(sch.Address, ',', '') AS Address,
REPLACE(sch.City, ',', '') AS City,
REPLACE(sch.State, ',', '') AS State,
sch.ZipCode AS Zip,
REPLACE(sch.SchoolType, ',', '') AS [School Type],
REPLACE(sch.Corporation, ',', '') AS Corporation,
REPLACE(region.ch_Region, ',', '') AS [CHE Region],
REPLACE(cnty.ch_county, ',', '') AS County
FROM CHE_ScholarTrack.dbo.Schools AS sch WITH (NOLOCK)
LEFT JOIN SEAS..NewRegionCountyMatch AS cnty  WITH (NOLOCK) ON cnty.in_CountyId=sch.County
LEFT JOIN SEAS..NewRegionCountyMatch AS region  WITH (NOLOCK) ON region.in_RegionId=sch.Region
WHERE sch.SchoolID IN (SELECT DISTINCT HighSchoolID FROM CHE_ScholarTrack.dbo.Students)