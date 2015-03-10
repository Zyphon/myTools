macroScript LockAllTransforms category: "HowTo"
(
	if (getTransformLockFlags $).isEmpty == true then
	(
		print("I am locked")
		setTransformLockFlags selection #all
	)
	else
	(
		print("I am not locked")
		setTransformLockFlags selection #none
	)
)