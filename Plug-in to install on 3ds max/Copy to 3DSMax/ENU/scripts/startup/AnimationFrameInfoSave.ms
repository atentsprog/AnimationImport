function  SaveAnimationFrameInfo =
(
	persistent global tempOffAnimButton
	persistent global animationRangeMin
	persistent global animationRangeMax
	
	if clipFrames == null do return 0;
	if clipFrames.count == 0 do return 0;
	
	
	minFrame  = 100000
	maxFrame = -100000
	for item in clipFrames do
	(
		if minFrame > (item[2] as Integer ) do
			minFrame = (item[2] as Integer )
		if maxFrame < (item[3] as Integer ) do
			maxFrame = (item[3] as Integer )
	)
		
	animationRangeMin = animationRange.start
	animationRangeMax = animationRange.end
	
	animationRange=interval minFrame maxFrame
	
	
	
	if animButtonState  ==  false then
	(
		tempOffAnimButton = false
	)
	else
	(
		set animate off
		tempOffAnimButton = true
	)
	
	
		
	fileName = maxFilePath  + maxFileName + "AnimationInfo.txt"
	if doesFileExist fileName do deleteFile fileName

	textFile = (createFile fileName)
	
	for item in clipFrames do format "%,%,%\n" item[1]  item[2]   item[3]  to:textFile		
    close textFile
)

function RestoreAnimButton=
(
	if animationRangeMin == undefined do
		return 0;
	
	animationRange=interval animationRangeMin animationRangeMax
	
	if tempOffAnimButton == true do
	(
		tempOffAnimButton = false
		set animate on		
	)
)

function FnClearClipFramesInfoCallback=
(
	if clipFrames == null do return 0;
		
	clipFrames = #()
)


callbacks.removeScripts id:#SaveAnimationFrameInfoID
callbacks.addScript #filePreSave "SaveAnimationFrameInfo()" id:#SaveAnimationFrameInfoID


callbacks.removeScripts id:#RestoreAnimButtonID
callbacks.addScript #filePostSave "RestoreAnimButton()" id:#RestoreAnimButtonID


callbacks.removeScripts id:#FnClearClipFramesInfoCallbackID
callbacks.addScript #filePreOpen "FnClearClipFramesInfoCallback()" id:#FnClearClipFramesInfoCallbackID
