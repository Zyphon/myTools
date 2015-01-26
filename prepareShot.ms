/*
	--TODO--
	-- Be able to gather all .EXR files in 1 EXR if EXR is selected
*/

-- Loading in Classes
studioLib()
drvLib()
prjLib()
renderSceneDialog.close()

-- Variables and Arrays
vr=renderers.current
resWidth = renderWidth
resHeight = renderHeight
rendMFN = substring mfn 1 (mfn.count - 9)
renderList = #("Single Frame", "Active Time Segment", "Range")
extensionList = #("PNG", "EXR", "TGA", "JPG")
DLSubIn = DLSub + @"FXTD\Modules\Module02\DLR_SubmissionTool.ms"
::FileIn DLSubIn

try(destroydialog _shotPreparation) catch()

rollout _shotPreparation "Render Submit"
(
	dropdownlist _extList "File Type" items:extensionList
	dropdownlist _rendTimeList "Render Type" items:renderList
	spinner _fStart "Start Frame" range:[-200, 1000, fStart] type:#integer enabled:false
	spinner _fEnd "End Frame" range:[0, 5000, fEnd] type:#integer enabled:false
	edittext _resWidth "Frame Width: " text:(resWidth as string)
	edittext _resHeight "Frame Height: " text:(resHeight as string)
	checkbox _submitToDL "Submit to Deadline" checked:false
	edittext _DLcomment "DL Comment: " text:"" enabled:false
	spinner _DLpriority "DL Priority: " range:[0,100,50] type:#integer enabled:false align:#left
	button _go "Go"
	
	on _rendTimeList selected  timeCheck do
	(
		if timeCheck != 3 then
		(
			_fStart.enabled = false
			_fEnd.enabled = false
		)
		else
		(
			_fStart.enabled = true
			_fEnd.enabled = true
		)
	)
	
	on _submitToDL changed stateCheck do
	(
		if(stateCheck != false) then
		(
			_DLcomment.enabled = true
			_DLpriority.enabled = true
		)
		else
		(
			_DLcomment.enabled = false
			_DLpriority.enabled = false
		)
	)

	on _go pressed do
	(
		if _rendTimeList.selection == 3 then
		(
			print("cake")
			fStart = _fStart.value
			fEnd = _fEnd.value
		)
		
		renderOutFileName = RO + @"\" + rendMFN + ".." + _extList.selected
		nonMatObj = for obj in geometry where obj.material == undefined collect obj
		userInput = true
		if nonMatObj.count != 0 then
		(
			userInput = queryBox("Some Objects in the Scene doesn't have materials assigned.\nContinue?")
		)
		if userInput then
		(
		-- Adjusting the settings
			rendTimeType = _rendTimeList.selection
			rendStart = fStart
			rendEnd = fEnd
			rendSaveFile = false

			renderWidth = (_resWidth.text as integer)
			renderHeight = (_resHeight.text as integer)
			
			makeDir RO
			
			if _extList.selection != 2 then
			(
				vr.output_saveRawFile = false
				vr.output_on = true
				vr.output_splitgbuffer = true
				vr.output_splitRGB = true
				vr.output_splitfilename = renderOutFileName
			)
			else
			(
				vr.output_saveRawFile = true
				vr.output_rawFileName = renderOutFileName
				vr.output_splitgbuffer = false
			)
			
			tempFileName = sysInfo.tempdir + "tmp." + _extList.selected
			tempFile = Bitmap 5 5 filename:tempFileName
			save tempFile
			close tempFile
			vr.output_splitbitmap = tempFile
			deleteFile tempFileName
			vrayVFBSetRegionEnabled(false)
			
			if _submitToDL.checked == true then
			(
				print(_DLpriority.value)
				print(_comment.text)
				DLRendSubmission _DLcomment.text mfn ((filterstring mfn "_")[4]) _DLpriority.value
			)
			
			messageBox("Render Setup Completed")
		)
		else
		(
			messageBox("Aborted - selecting Objects without Material")
			select nonMatObj
		)
	)
)
createdialog _shotPreparation 200