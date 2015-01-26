
dirInitOut = "Directory"
extList = #("OBJ", "3DS", "DWG", "FBX")

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
		_saveDir.text = savePath
	)
	
	on _exportSingle pressed do
	(
		exportObj = for obj in selection collect obj
		if _saveDir.text != dirInitOut then
		(
			if exportObj.count == 1 then
			(
				-- [:: Single Object Export ::] --
				myObj = exportObj[1]
				objName = myObj.name
				folderPath = _saveDir.text
				fileOutName = folderPath + @"\" + objName + "." + _extensionList.selected
				exportFile fileOutName selectedOnly:true
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

				for i = 1 to exportObj.count do
				(
					objName = exportObj[i].name
					select exportObj[i]
					fileOutName = folderPath + @"\" + objName + "." + _extensionList.selected
					exportFile fileOutName #noPrompt selectedOnly:true
				)
			)
			else(messageBox("Select Objects to Export"))
		)
		else(messageBox("Specify Directory"))
	)
)
createDialog objectExporter width:170