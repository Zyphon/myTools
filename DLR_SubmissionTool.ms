fn DLRendSubmission _comment _jobName _Department _priority =
(
-- 	Load Libraries
-- 	drvLib()
-- 	studioLib()
-- 	prjLib()

	SMTD_FuncList = DLR + @"submission\3dsmax\Main\SubmitMaxToDeadline_Functions.ms"
	::FileIn SMTD_FuncList

--	Variables
	DLTempDir = SMTDPaths.tempDir

-- 	Define Job Properties
	SMTDSettings.comment = _comment
	SMTDSettings.JobName = _jobName
	SMTDSettings.Department = _Department
	SMTDSettings.Priority = _priority

--	Submit Job
	MaxFileToSubmit = DLTempDir + mfn
	SMTDFunctions.SaveMaxFileCopy MaxFileToSubmit --Saves a copy of the MaxFile at a temporary Directory

--	Create Render Job Files
	SubmitInfoFile = DLTempDir + @"Max_Submit_Info.job"
	JobInfoFile = DLTempDir + @"Max_Job_Info.job"

	SMTDFunctions.CreateSubmitInfoFile SubmitInfoFile
	SMTDFunctions.CreateJobInfoFile JobInfoFile

	SubmitString = "\"" + SubmitInfoFile + "\" \"" + JobInfoFile + "\" \"" + MaxFileToSubmit + "\""
	SMTDFunctions.WaitForCommandToComplete SubmitString 200
)