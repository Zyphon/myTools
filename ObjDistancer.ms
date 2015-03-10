
try (destroydialog _objectSpacer) catch()
rollout _objectSpacer "Objects Spacer"
(
	pickButton _baseObject "Base Object"
	on _baseObject picked obj do
	(
		_baseObject.text = obj.name
	)
	spinner _moveSingle "Move Single" range:[-10000, 100000, 0] enabled:false pos: [43,30]
	checkbox _activateSingle pos:[16, 30]
	spinner _moveTotal "Move Total" range:[-10000, 100000, 0] enabled:false pos:[43,50]
	checkbox _activateTotal pos:[16, 50]
	on _activateTotal changed state do
	(
		if _moveTotal.enabled == true then
			_moveTotal.enabled = false
		else if _moveTotal.enabled == false then
			_moveTotal.enabled = true
		_activateSingle.checked = false
		_moveSingle.enabled = false
	)
	on _activateSingle changed state do
	(
		if _moveSingle.enabled == true then
			_moveSingle.enabled = false
		else if _moveSingle.enabled == false then
			_moveSingle.enabled = true
		_activateTotal.checked = false
		_moveTotal.enabled = false
	)
	radiobuttons _xyzAxis labels:#("xAxis", "yAxis", "zAxis")
	on _xyzAxis changed state do
	(
		if state == 1 then
		(
			xAxis = true
			yAxis = false
			zAxis = false
		)
		if state == 2 then
		(
			xAxis = false
			yAxis = true
			zAxis = false
		)
		if state == 3 then
		(
			xAxis = false
			yAxis = false
			zAxis = true
		)
	)
	button _go "Go!"
	on _go pressed do
	(
		if _baseObject.object != undefined then
		(
			-- Set up Variables
			totalDistance = _moveTotal.value
			selectedObj = for obj in selection collect obj
			baseObject = _baseObject.object
			objArray = #(baseObject)
			basePosition = baseObject.position
			distanceDeterminator = totalDistance / selectedObj.count -- Determinate the Seperation distance

			-- Append selected Objects to our objArray if obj doesn't already exist in the array
			for i = 1 to selectedObj.count do 
				appendIfUnique objArray selectedObj[i]

			-- Move objects along wished axis
			if xAxis == true then
			(
				if _moveTotal.enabled == true then
				(
					for i = 1 to objArray.count do
					(
						objArray[i].pos = [basePosition.x + (distanceDeterminator*(i-1)), basePosition.y, basePosition.z]
					)
				)
				else if _moveSingle.enabled == true then
				(
					for i = 1 to objArray.count do
					(
						objArray[i].pos = [basePosition.x + (_moveSingle.value*(i-1)), basePosition.y, basePosition.z]
					)
				)
			)

			if yAxis == true then
			(
				if _moveTotal.enabled == true then
				(
					for i = 1 to objArray.count do
					(
						objArray[i].pos = [basePosition.x, basePosition.y + (distanceDeterminator*(i-1)), basePosition.z]
					)
				)
				else if _moveSingle.enabled == true then
				(
					for i = 1 to objArray.count do
					(
						objArray[i].pos = [basePosition.x, basePosition.y + (_moveSingle.value*(i-1)), basePosition.z]
					)
				)
			)

			if zAxis == true then
			(
				if _moveTotal.enabled == true then
				(
					for i = 1 to objArray.count do
					(
						objArray[i].pos = [basePosition.x, basePosition.y, basePosition.z + (distanceDeterminator*(i-1))]
					)
				)
				else if _moveSingle.enabled == true then
				(
					for i = 1 to objArray.count do
					(
						objArray[i].pos = [basePosition.x, basePosition.y, basePosition.z + (_moveSingle.value*(i-1))]
					)
				)
			)
		)
		else
			messageBox("Please select Base Object!")
	)
)
createdialog _objectSpacer width:190