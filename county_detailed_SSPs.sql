SET NOCOUNT ON;
DECLARE @CurrentSeniorCohort int;
SET @CurrentSeniorCohort = 2018;

SELECT DISTINCT
s.StudentID,
s.HSGradYear AS hs_grad_year,
s.HighSchoolID AS high_school_id,
s.MiddleSchoolID AS middle_school_id,
tfc.Approved,
tfc.IsExpelled,
tfc.PledgeViolation,
tfc.IsSubmitted,
tfc.SubmittedDateTime,
CASE WHEN s.UserID IS NOT NULL THEN 1 ELSE 0 END AS scholartrack_account,
ssp01.submit_date AS ssp_01,
ssp02.submit_date AS ssp_02,
ssp03.submit_date AS ssp_03,
ssp04.submit_date AS ssp_04,
ssp05.submit_date AS ssp_05,
ssp06.submit_date AS ssp_06,
ssp07.submit_date AS ssp_07,
ssp08.submit_date AS ssp_08,
ssp09.submit_date AS ssp_09,
ssp10.submit_date AS ssp_10,
ssp11.submit_date AS ssp_11,
ssp12.submit_date AS ssp_12,
iv.VersionID AS isir_version
FROM CHE_ScholarTrack.dbo.Students AS s WITH (NOLOCK)
INNER JOIN CHE_ScholarTrack.dbo.TFCApplications AS tfc WITH (NOLOCK) ON (s.StudentID = tfc.StudentID)
--LEFT JOIN #tmp_ssp_completion AS ssp WITH (NOLOCK) ON (s.StudentID = ssp.StudentID)
LEFT JOIN (SELECT DISTINCT StudentID, min(SubmitDate) AS submit_date FROM CHE_ScholarTrack.dbo.StudentSSP9GraduationPlans WITH (NOLOCK) GROUP BY StudentID) AS ssp01 ON (tfc.StudentID = ssp01.StudentID)
LEFT JOIN (SELECT DISTINCT StudentID, min(SubmitDate) AS submit_date FROM CHE_ScholarTrack.dbo.StudentSSP9Activities WITH (NOLOCK) GROUP BY StudentID) AS ssp02 ON (tfc.StudentID = ssp02.StudentID)
LEFT JOIN (SELECT DISTINCT StudentID, min(SubmitDate) AS submit_date FROM CHE_ScholarTrack.dbo.StudentSSP9PayingForColleges WITH (NOLOCK) GROUP BY StudentID) AS ssp03 ON (tfc.StudentID = ssp03.StudentID)
LEFT JOIN (SELECT DISTINCT StudentID, min(SubmitDate) AS submit_date FROM CHE_ScholarTrack.dbo.StudentSSP10CareerInterestAssessments WITH (NOLOCK) GROUP BY StudentID) AS ssp04 ON (tfc.StudentID = ssp04.StudentID)
LEFT JOIN (SELECT DISTINCT StudentID, min(SubmitDate) AS submit_date FROM CHE_ScholarTrack.dbo.StudentSSP10WorkplaceExperiences WITH (NOLOCK) GROUP BY StudentID) AS ssp05 ON (tfc.StudentID = ssp05.StudentID)
LEFT JOIN (SELECT DISTINCT StudentID, min(SubmitDate) AS submit_date FROM CHE_ScholarTrack.dbo.StudentSSP10EstimateCosts WITH (NOLOCK) GROUP BY StudentID) AS ssp06 ON (tfc.StudentID = ssp06.StudentID)
LEFT JOIN (SELECT DISTINCT StudentID, min(SubmitDate) AS submit_date FROM CHE_ScholarTrack.dbo.StudentSSP11VisitColleges WITH (NOLOCK) GROUP BY StudentID) AS ssp07 ON (tfc.StudentID = ssp07.StudentID)
LEFT JOIN (SELECT DISTINCT StudentID, min(SubmitDate) AS submit_date FROM CHE_ScholarTrack.dbo.StudentSSP11CollegeExams WITH (NOLOCK) GROUP BY StudentID) AS ssp08 ON (tfc.StudentID = ssp08.StudentID)
LEFT JOIN (SELECT DISTINCT StudentID, min(SubmitDate) AS submit_date FROM CHE_ScholarTrack.dbo.StudentSSP11Scholarships WITH (NOLOCK) GROUP BY StudentID) AS ssp09 ON (tfc.StudentID = ssp09.StudentID)
LEFT JOIN (SELECT DISTINCT StudentID, min(SubmitDate) AS submit_date FROM CHE_ScholarTrack.dbo.StudentSSP12CollegeApplications WITH (NOLOCK) GROUP BY StudentID) AS ssp10 ON (tfc.StudentID = ssp10.StudentID)
LEFT JOIN (SELECT DISTINCT StudentID, min(SubmitDate) AS submit_date FROM CHE_ScholarTrack.dbo.StudentSSP12CollegeSuccesses WITH (NOLOCK) GROUP BY StudentID) AS ssp11 ON (tfc.StudentID = ssp11.StudentID)
LEFT JOIN (SELECT DISTINCT StudentID, min(SubmitDate) AS submit_date FROM CHE_ScholarTrack.dbo.StudentSSP12FileFAFSAs WITH (NOLOCK) GROUP BY StudentID) AS ssp12 ON (tfc.StudentID = ssp12.StudentID)
/* begin latest version */ 
LEFT JOIN (
	SELECT
	allversions.*
	FROM CHE_ScholarTrack.dbo.ISIRVersions AS allversions WITH (NOLOCK)
	CROSS APPLY (
		SELECT TOP 1
		topversion.StudentID, topversion.VersionID, topversion.Year
		FROM CHE_ScholarTrack.dbo.ISIRVersions AS topversion WITH (NOLOCK)
		INNER JOIN CHE_ScholarTrack.dbo.ISIRIRSTransactionDetails AS irs2 WITH (NOLOCK) ON (topversion.VersionID = irs2.VersionID)
		WHERE allversions.StudentID = topversion.StudentID AND allversions.Year = topversion.Year
		ORDER BY irs2.TransactionReceiptDate DESC, topversion.TransactionNumber DESC
	) AS latestversion 
	WHERE allversions.VersionID = latestversion.VersionID
) AS iv ON (s.StudentID = iv.StudentID AND s.HSGradYear = iv.Year)
/* end latest version */
WHERE s.HSGradYear >= 2015