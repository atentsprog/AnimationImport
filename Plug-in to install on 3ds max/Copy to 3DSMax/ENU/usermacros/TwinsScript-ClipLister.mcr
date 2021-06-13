macroScript ClipLister category:"TwinsScript"
(
		
	persistent global clipFrames = #()
	persistent global clipListerWidth
	persistent global clipListerHeight
	
	rollout ClipLister "ClipLister" width:260 height:380
	(
		
		listbox listClipList "Clip Frames" pos:[14,96] width:208 height:15

		checkbutton ckb1 "CheckButton" pos:[146,131] width:0 height:0
		
		edittext edtClipName "" pos:[8,8] width:112 height:16 text:"clipName"
		edittext edtStartFrame "" pos:[8,32] width:48 height:16
		edittext edtEndFrame "" pos:[58,32] width:48 height:16

		button btnDeleteSelectedClip "Delete" pos:[84,89] width:56 height:16 toolTip:"Delete selected clip"
		button btnAddFrame "Add frame" pos:[128,8] width:80 height:16
		button btnRefreshFrame "Get Current Frame" pos:[109,33] width:110 height:16	
		button btnEdit "Save modified frame" pos:[109,51] width:110 height:16 toolTip:"Save selected clip"

		
		button btnUp "Up" pos:[148,89] width:30 height:16
		button btnDown "Down" pos:[188,89] width:36 height:16	
	
		fn fn_SaveAnimationInfo = 
		(		
			fileName = maxFilePath  + maxFileName + "AnimationInfo.txt"
			if doesFileExist fileName do deleteFile fileName

			textFile = (createFile fileName)
			
			for item in clipFrames do format "%,%,%\n" item[1]  item[2]   item[3]  to:textFile		
			close textFile
			print "Save Complete :" + fileName
		)
	
		fn fn_RefreshFrame =
		(			
			local startFrame = (animationRange.start  as integer)/TicksPerFrame
			local endFrame = (animationRange.end as integer)/TicksPerFrame
			
			edtStartFrame.text = startFrame as string			
			edtEndFrame.text = endFrame as string
		)
		
		fn fn_RefreshList =
		(
			listClipList.items = (for o in clipFrames collect o[1] + "  ::  " + o[2] as string + " ~ " + o[3] as string)			
		)

		
		fn fn_SaveList =
		(
			persistent global clipFrames
			fn_SaveAnimationInfo()
		)
		
		
		
		fn fn_LoadClipFrameInfos = 
		(
			fileName = maxFilePath  + maxFileName + "AnimationInfo.txt"
			if doesFileExist fileName do 
			(
				textFile = (openFile fileName)
				if textFile != undefined then
				(
					clipFrames = #()
					count = 1
					 while not eof textFile do
					 (
						clipName = readDelimitedString textFile ","
						startFrame = readValue textFile
						endFrame = readValue textFile
						 
						append clipFrames #(clipName, startFrame, endFrame)							 
					 )
					 close textFile
				)
			)
		)

			
		on ClipLister close do
		(			
			fn_SaveAnimationInfo()
		)
		
				
		on ClipLister open do
		(			
			fn_LoadClipFrameInfos()
			
			fn_RefreshFrame()			
			fn_RefreshList()
			
				
			width = 216
			height = 328
			if clipListerWidth != undefined do
			(
				width = clipListerWidth
				height = clipListerHeight
			)
			
			listClipList.width = width - 20
			listClipList.height =height - 100
		)
		on ClipLister resized size do
		(
			listClipList.width = size.x - 20
			listClipList.height = size.y - 100
			
			clipListerWidth = size.x 
			clipListerHeight = size.y
			print clipListerWidth
		)
		on listClipList selected nameIndex do
		(
			print "listClipList selected"
			tokens = filterString listClipList.items[nameIndex] "  ::  " splitEmptyTokens:false
			edtClipName.text = tokens[1]		
			--tokens[2] : "~"
			edtStartFrame.text = tokens[2]
			edtEndFrame.text = tokens[4]
		)
		on listClipList doubleClicked itm do
		(
			print "listClipList doubleClicked"
			--무브 프레임. 
			animationRange = interval (clipFrames[itm][2] as time) (clipFrames[itm][3] as time)
			
		)
		on btnDeleteSelectedClip pressed do
		(
			print "btnDeleteSelectedClip"
			listClipList.selection		
			deleteItem clipFrames listClipList.selection			
			fn_RefreshList()			
		)
		on btnAddFrame pressed do
		(
			print "btnAddFrame"
			
			local startFrame = edtStartFrame.text as integer
			local endFrame = edtEndFrame.text as integer
			
			append clipFrames #(edtClipName.text, startFrame, endFrame)	
			fn_RefreshList()	
			fn_SaveList()
		)
		on btnRefreshFrame pressed do
		(
			print "btnRefreshFrame"
			fn_RefreshFrame()
		)
		on btnUp pressed do
		(
			print "up" + listClipList.selection as string
			if  listClipList.selection > 1 do
			(
				local temp = clipFrames[listClipList.selection - 1]
				clipFrames[listClipList.selection - 1] = clipFrames[listClipList.selection]
				clipFrames[listClipList.selection] = temp
				listClipList.selection -= 1
				print clipFrames[listClipList.selection]
			)
			fn_RefreshList()
		)
		on btnDown pressed do
		(
			print "down" + clipFrames.count as string + ";" + listClipList.selection as string
			print listClipList.selection
			print clipFrames.count 
			if listClipList.selection < clipFrames.count do
			(
				local temp = clipFrames[listClipList.selection + 1]
				clipFrames[listClipList.selection + 1] = clipFrames[listClipList.selection]
				clipFrames[listClipList.selection] = temp
				print clipFrames[listClipList.selection]
				listClipList.selection += 1
				print clipFrames[listClipList.selection]
			)
			
			fn_RefreshList()
			
		)
		on btnEdit pressed do
		(
			if listClipList.selection <= 0 do
			(
				return 0;
			)
			
			clipFrames[listClipList.selection][1] = edtClipName.text 
			clipFrames[listClipList.selection][2] = edtStartFrame.text 
			clipFrames[listClipList.selection][3] = edtEndFrame.text 
			fn_RefreshList()
			
		)
	)


	on execute do
	(
		width = 230
		height = 340
		if clipListerWidth != undefined do
		(
			width = clipListerWidth
			height = clipListerHeight
		)
		
		createDialog ClipLister  style:#(#style_titlebar, #style_sysmenu, #style_minimizebox, #style_resizing) width:width height:height
	)
)