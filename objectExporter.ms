
dirInitOut = "Directory"
extList = #("OBJ", "3DS", "DWG", "FBX")

global BN_CLICKED = 0 -- clicky message ID
global BM_SETCHECK = 241 -- checkbutton toggle message ID
global WM_COMMAND = 273 -- windows command message
global theObjExportTimer -- a .NET timer to check whether obj export is complete or not.

fn seeIfObjExportIsDoneYet = 
(
	try 
	(
		-- get all of the popup dialogs
		local popupWindows_hwnds = UIAccessor.GetPopupDialogs()
		-- loop over all of these dialogs
		for child_hwnd in popupWindows_hwnds do 
		(
			-- and find the one titled "Exporting OBJ"
			if (UIAccessor.getWindowText child_hwnd == "Exporting OBJ") then 
			(
				-- now get all of its children UI elements
				local dlgChildren_hwnds = UIAccessor.getChildWindows child_hwnd
				-- loop over those UI elements
				for dlgChild_hwnd in dlgChildren_hwnds do 
				(
					-- see if the "-= DONE =-" button appears to exist
					-- ( the button always exists, but until the export is actually done, will be labeled "Cancel Export" )
					if (UIAccessor.getWindowText dlgChild_hwnd == "-= DONE =-") then 
					(
						-- and press it if it does
						UIAccessor.pressButton dlgChild_hwnd
						-- oh and let's not forget to stop that timer...
						print "Export to OBJ finished"
						theObjExportTimer.stop()
					)
				)
				exit
			)
		)
	)
	catch (
	theObjExportTimer.stop()
	)
)

dialogMonitorOPS.UnRegisterNotification id:#test -- remove any old instance

theObjExportTimer = dotNetObject "System.Windows.Forms.Timer"
dotNet.addEventHandler theObjExportTimer "tick" seeIfObjExportIsDoneYet
theObjExportTimer.interval = 500

fn exportAutomation = 
(
	hwnd = DialogMonitorOPS.GetWindowHandle() -- check the dialog that popped up
	hwnd_title = UIAccessor.GetWindowText hwnd
	if (hwnd_title == "OBJ Export Options") then  -- the obj export config dialog
	(
		local flipControl_hwnd = undefined
		local flipControl_parent_hwnd = undefined
		local controls = windows.getChildrenHWND hwnd -- get all controls for this dialog
		global myArray = controls
		for c in controls do 
		(
			if (c[5] == "Create mat-library") then
			(
				flipControl_hwnd = c[1]
				flipControl_parent_hwnd = c[2]
				local flipControl_id = UIAccessor.GetWindowResourceID flipControl_hwnd
				windows.sendMessage flipControl_hwnd BM_SETCHECK 0 0 -- uncheck the Flip YZ-axis option. Set to '1 0' to check it.
				windows.sendMessage flipControl_parent_hwnd WM_COMMAND ((bit.shift BN_CLICKED 16) + flipControl_id) flipControl_hwnd
-- 				exit
			)
			if (c[5] == "Export materials") then
			(
				newFlipControl_hwnd = c[1]
				newFlipControl_parent_hwnd = c[2]
				local flipControl_id = UIAccessor.GetWindowResourceID newFlipControl_hwnd
				windows.sendMessage newFlipControl_hwnd BM_SETCHECK 0 0 -- uncheck the Flip YZ-axis option. Set to '1 0' to check it.
				windows.sendMessage newFlipControl_parent_hwnd WM_COMMAND ((bit.shift BN_CLICKED 16) + flipControl_id) newFlipControl_hwnd
-- 				exit
			)
		)
		UIAccessor.PressButtonByName hwnd "Export" -- press the Export button
	)
	 -- hwnd_title == "OBJ Export Options"
	else if (hwnd_title == "Exporting OBJ") then 
	(
		-- oh nasty. This dialog pops up, and it's a 'progress' dialog. So we'll have to check it at an interval.. lovely!
		-- invoke the .NET timer
		theObjExportTimer.start()
	) -- hwnd_title == "Exporting OBJ"
	true
)

try(destroyDialog objectExporter) catch()
rollout objectExporter "Object Exporter"
(
	edittext _saveDir readOnly:true pos:[3, 5] width:135 height:20 text:dirInitOut
	button _setDirButton " ... " pos:[145, 5] width:20
	dropdownlist _extensionList items:extList
	button _exportSingle "Export Single Object" width:160
	button _exportMultiple "Export Multiple Objects" width:160
	button _exportBatch "Export As Batch" width:160
	
	on _setDirButton pressed do
	(
		savePath = getSavePath()
		if savePath != undefined then
		(
			_saveDir.text = savePath
		)
	)
	
	on _exportSingle pressed do
	(
		exportObj = for obj in selection collect obj
		if _saveDir.text != dirInitOut then
		(
			if exportObj.count == 1 then
			(
				-- [:: Single Object Export ::] --
				dialogMonitorOPS.RegisterNotification exportAutomation id:#test -- register the monitor
				dialogMonitorOps.enabled = true -- enable the monitor
				myObj = exportObj[1]
				objName = myObj.name
				folderPath = _saveDir.text
				fileOutName = folderPath + @"\" + objName + "." + _extensionList.selected
				exportFile fileOutName selectedOnly:true
				dialogMonitorOPS.UnRegisterNotification id:#test -- remove the monitor
				dialogMonitorOps.enabled = false -- disable the monitor
			)
			else(messageBox("Select (1) Object to Export"))
		)
		else(messageBox("Specify Directory"))
	)
	
	on _exportMultiple pressed do
	(
		exportObj = for obj in selection collect obj
		if _saveDir.text != dirInitOut then
		(
			if exportObj.count > 1 then
			(
				folderPath = _saveDir.text
				fileOutName = folderPath + @"\" + objName "." + _extensionList.selected
				exportFile fileOutName
			)
			else(messageBox("Select Objects to Export"))
		)
		else(messageBox("Specify Directory"))
	)
	
	on _exportBatch pressed do
	(
		exportObj = for obj in selection collect obj
		if _saveDir.text != dirInitOut then
		(
			if exportObj.count > 1 then
			(
				-- [:: Batch Object Export ::] --
				folderPath = _saveDir.text
				if _extensionList.selection == 1 then
				(
					for i = 1 to exportObj.count do
					(
						dialogMonitorOPS.RegisterNotification exportAutomation id:#test -- register the monitor
						dialogMonitorOps.enabled = true -- enable the monitor
						objName = exportObj[i].name
						select exportObj[i]
						fileOutName = folderPath + @"\" + objName + "." + _extensionList.selected
						exportFile fileOutName selectedOnly:true
						dialogMonitorOPS.UnRegisterNotification id:#test -- remove the monitor
						dialogMonitorOps.enabled = false -- disable the monitor
					)
				)
				else
				(
					for i = 1 to exportObj.count do
					(
						objName = exportObj[i].name
						select exportObj[i]
						fileOutName = folderPath + @"\" + objName + "." + _extensionList.selected
						exportFile fileOutName #noPrompt selectedOnly:true
					)
				)
			)
			else(messageBox("Select Objects to Export"))
		)
		else(messageBox("Specify Directory"))
	)
)
createDialog objectExporter width:170