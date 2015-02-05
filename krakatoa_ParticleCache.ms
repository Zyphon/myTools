studioLib()
drvLib()
prjLib()

pfsObj = $
CDGen "PRT"
makedir cacheDir

oldFile = (mfp + mfn)
saveMaxFile oldFile

newFile = (mfp + renOutputName + "_kcache.max")
saveMaxFile newFile

PRTOutDir = cacheDir + @"\" +pfsObj.name
makedir PRTOutDir
PRTOutFile = PRTOutDir + @"\" +pfsObj.name + "_.prt"

renderers.current = krakatoa()
renderscenedialog.close()
-- franticparticles.setproperty "ParticleMode" "Save Particles to File Sequence"
franticparticles.setproperty "ParticleFiles" PRTOutFile
rendtimetype = 2
rendsavefile = false


-- Deadline Submission
SMTD_FuncList = DLR + @"submission\3dsmax\Main\SubmitMaxToDeadline_Functions.ms"
FileIn SMTD_FuncList
DLTempDir = SMTDPaths.tempDir
SMTDSettings.JobName = mfn + "_[Krakatoa Cache Job]"
SMTDSettings.Priority = 90
SMTDSettings.comment = "Caching Krakatoa Particle Cache"
-- SMTDSettings.Department = _Department
MaxFileToSubmit = DLTempDir + mfn
SMTDFunctions.SaveMaxFileCopy MaxFileToSubmit --Saves a copy of the MaxFile at a temporary Directory
SubmitInfoFile = DLTempDir + @"Max_Submit_Info.job"
JobInfoFile = DLTempDir + @"Max_Job_Info.job"
SMTDFunctions.CreateSubmitInfoFile SubmitInfoFile
SMTDFunctions.CreateJobInfoFile JobInfoFile
SubmitString = "\"" + SubmitInfoFile + "\" \"" + JobInfoFile + "\" \"" + MaxFileToSubmit + "\""
SMTDFunctions.WaitForCommandToComplete SubmitString 200
SMTDFunctions.GetJobIdFromMessage(SMTDFunctions.GetRenderMessage())

loadmaxfile oldFile