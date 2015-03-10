try (destroydialog _matSelector) catch()
rollout _matSelector "Mat Selector"
(
	checkbox _selectVray "Select Obj w. VRayMtl"
	checkbox _selectNoVRMat "Select Obj w/o VRayMtl"
	checkbox _selectNoMat "Select Obj w/o Materials"
	button _go "Select!"
	on _go pressed do
	(
		myArray = #()
		if _selectVray.checked == true then
		(
			myObjects = for obj in geometry where classof obj.material == VRayMtl collect obj
			for i = 1 to myObjects.count do
			(
				append myArray myObjects[i]
			)
		)
		if _selectNoVRMat.checked == true then
		(
			myObjects = for obj in geometry where classof obj.material != VRayMtl collect obj
			for i = 1 to myObjects.count do
			(
				append myArray myObjects[i]
			)
		)
		if _selectNoMat.checked == true then
		(
			myObjects = for obj in geometry where obj.material == undefined collect obj
			for i = 1 to myObjects.count do
			(
				append myArray myObjects[i]
			)
		)
		select myArray
	)
)
createdialog _matSelector
