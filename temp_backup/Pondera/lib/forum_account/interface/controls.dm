
// File:    controls.dm
// Library: Forum_account.Interface
// Author:  Forum_account
//
// Contents:
//   Contains the code for each type of interface control. The
//   code here was generated from the code in generate-controls.dm.

Control
	var
		Position/_Pos
		Size/_Size
		Position/_Anchor1
		Position/_Anchor2
		_IsVisible
		_IsTransparent
		_Border
		Color/_TextColor
		Color/_BackgroundColor
		_IsDefault
		_IsDisabled
		_DropZone
		_RightClick
		_FontFamily
		_FontSize
		_FontStyle
		_Focus
		_SavedParams
	proc
		Pos()
			if(args.len)
				return _set_position("pos", "", args)
			else
				return _get_position("pos", "")
		Size()
			if(args.len)
				return _set_size("size", "", args)
			else
				return _get_size("size", "")
		Anchor1()
			if(args.len)
				return _set_position("anchor1", "_Anchor1", args)
			else
				return _get_position("anchor1", "_Anchor1")
		Anchor2()
			if(args.len)
				return _set_position("anchor2", "_Anchor2", args)
			else
				return _get_position("anchor2", "_Anchor2")
		TextColor()
			if(args.len)
				return _set_color("text-color", "_TextColor", args[1])
			else
				return _get_color("text-color", "_TextColor")
		BackgroundColor()
			if(args.len)
				return _set_color("background-color", "_BackgroundColor", args[1])
			else
				return _get_color("background-color", "_BackgroundColor")
		IsVisible()
			if(args.len)
				return _set_boolean("is-visible", "_IsVisible", args[1])
			else
				return _get_boolean("is-visible", "_IsVisible")
		IsDisabled()
			if(args.len)
				return _set_boolean("is-disabled", "_IsDisabled", args[1])
			else
				return _get_boolean("is-disabled", "_IsDisabled")
		IsTransparent()
			if(args.len)
				return _set_boolean("is-transparent", "_IsTransparent", args[1])
			else
				return _get_boolean("is-transparent", "_IsTransparent")
		IsDefault()
			if(args.len)
				return _set_boolean("is-default", "_IsDefault", args[1])
			else
				return _get_boolean("is-default", "_IsDefault")
		Border()
			if(args.len)
				return _set_borderstyle("border", "_Border", args[1])
			else
				return _get_borderstyle("border", "_Border")
		DropZone()
			if(args.len)
				return _set_boolean("drop-zone", "_DropZone", args[1])
			else
				return _get_boolean("drop-zone", "_DropZone")
		RightClick()
			if(args.len)
				return _set_boolean("right-click", "_RightClick", args[1])
			else
				return _get_boolean("right-click", "_RightClick")
		FontFamily()
			if(args.len)
				return _set_text("font-family", "_FontFamily", args[1])
			else
				return _get_text("font-family", "_FontFamily")
		FontSize()
			if(args.len)
				return _set_number("font-size", "_FontSize", args[1])
			else
				return _get_number("font-size", "_FontSize")
		FontStyle()
			if(args.len)
				return _set_fontstyle("font-style", "_FontStyle", args[1])
			else
				return _get_fontstyle("font-style", "_FontStyle")
		Focus()
			if(args.len)
				return _set_boolean("focus", "_Focus", args[1])
			else
				return _get_boolean("focus", "_Focus")
Label
	parent_type = /Control
	var
		_Text
		_Image
		_ImageMode
		_KeepAspect
		_Align
		_TextWrap
	New()
		..()
	proc
		Text()
			if(args.len)
				return _set_text("text", "_Text", args[1])
			else
				return _get_text("text", "_Text")
		Image()
			if(args.len)
				return _set_text("image", "_Image", args[1])
			else
				return _get_text("image", "_Image")
		ImageMode()
			if(args.len)
				return _set_imagemode("image-mode", "_ImageMode", args[1])
			else
				return _get_imagemode("image-mode", "_ImageMode")
		KeepAspect()
			if(args.len)
				return _set_boolean("keep-aspect", "_KeepAspect", args[1])
			else
				return _get_boolean("keep-aspect", "_KeepAspect")
		Align()
			if(args.len)
				return _set_alignment("align", "_Align", args[1])
			else
				return _get_alignment("align", "_Align")
		TextWrap()
			if(args.len)
				return _set_boolean("text-wrap", "_TextWrap", args[1])
			else
				return _get_boolean("text-wrap", "_TextWrap")
Output
	parent_type = /Control
	var
		Color/_LinkColor
		Color/_VisitedColor
		_Style
		_EnableHttpImages
		_MaxLines
		_Image
	New()
		..()
	proc
		LinkColor()
			if(args.len)
				return _set_color("link-color", "_LinkColor", args[1])
			else
				return _get_color("link-color", "_LinkColor")
		VisitedColor()
			if(args.len)
				return _set_color("visited-color", "_VisitedColor", args[1])
			else
				return _get_color("visited-color", "_VisitedColor")
		EnableHttpImages()
			if(args.len)
				return _set_boolean("enable-http-images", "_EnableHttpImages", args[1])
			else
				return _get_boolean("enable-http-images", "_EnableHttpImages")
		MaxLines()
			if(args.len)
				return _set_number("max-lines", "_MaxLines", args[1])
			else
				return _get_number("max-lines", "_MaxLines")
		Image()
			if(args.len)
				return _set_text("image", "_Image", args[1])
			else
				return _get_text("image", "_Image")
Input
	parent_type = /Control
	var
		_MultiLine
		_IsPassword
		_NoCommand
	New()
		..()
		winset(owner,"[window_id].[control_id]","command=InterfaceEvent+\"[window_id]\"+\"[control_id]\"+\"command\"")
	proc
		Command()
			if(args.len)
				owner._InterfaceEvents["[window_id].[control_id].command"] = args[1]
			else
				return owner._InterfaceEvents["[window_id].[control_id].command"]
		MultiLine()
			if(args.len)
				return _set_boolean("multi-line", "_MultiLine", args[1])
			else
				return _get_boolean("multi-line", "_MultiLine")
		IsPassword()
			if(args.len)
				return _set_boolean("is-password", "_IsPassword", args[1])
			else
				return _get_boolean("is-password", "_IsPassword")
		NoCommand()
			if(args.len)
				return _set_boolean("no-command", "_NoCommand", args[1])
			else
				return _get_boolean("no-command", "_NoCommand")
Grid
	parent_type = /Control
	var
		Size/_Cells
		Position/_CurrentCell
		_ShowLines
		_SmallIcons
		_ShowNames
		_EnableHttpImages
		Color/_LinkColor
		Color/_VisitedColor
		Color/_LineColor
		_Style
		_IsList
	New()
		..()
	proc
		Cells()
			if(args.len)
				return _set_size("cells", "_Cells", args)
			else
				return _get_size("cells", "_Cells")
		CurrentCell()
			if(args.len)
				return _set_position("current-cell", "_CurrentCell", args)
			else
				return _get_position("current-cell", "_CurrentCell")
		SmallIcons()
			if(args.len)
				return _set_boolean("small-icons", "_SmallIcons", args[1])
			else
				return _get_boolean("small-icons", "_SmallIcons")
		ShowNames()
			if(args.len)
				return _set_boolean("show-names", "_ShowNames", args[1])
			else
				return _get_boolean("show-names", "_ShowNames")
		EnableHttpImages()
			if(args.len)
				return _set_boolean("enable-http-images", "_EnableHttpImages", args[1])
			else
				return _get_boolean("enable-http-images", "_EnableHttpImages")
		LinkColor()
			if(args.len)
				return _set_color("link-color", "_LinkColor", args[1])
			else
				return _get_color("link-color", "_LinkColor")
		VisitedColor()
			if(args.len)
				return _set_color("visited-color", "_VisitedColor", args[1])
			else
				return _get_color("visited-color", "_VisitedColor")
		LineColor()
			if(args.len)
				return _set_color("line-color", "_LineColor", args[1])
			else
				return _get_color("line-color", "_LineColor")
		IsList()
			if(args.len)
				return _set_boolean("is-list", "_IsList", args[1])
			else
				return _get_boolean("is-list", "_IsList")
Tab
	parent_type = /Control
	var
		_Tabs
		_CurrentTab
		_MultiLine
	New()
		..()
		winset(owner,"[window_id].[control_id]","on-tab=InterfaceEvent+\"[window_id]\"+\"[control_id]\"+\"tab\"")
	proc
		MultiLine()
			if(args.len)
				return _set_boolean("multi-line", "_MultiLine", args[1])
			else
				return _get_boolean("multi-line", "_MultiLine")
		OnTab()
			if(args.len)
				owner._InterfaceEvents["[window_id].[control_id].tab"] = args[1]
			else
				return owner._InterfaceEvents["[window_id].[control_id].tab"]
Bar
	parent_type = /Control
	var
		Color/_BarColor
		_IsSlider
		_Width
		_Dir
		_Angle1
		_Angle2
		_Value
	New()
		..()
		winset(owner,"[window_id].[control_id]","on-change=InterfaceEvent+\"[window_id]\"+\"[control_id]\"+\"change\"")
	proc
		BarColor()
			if(args.len)
				return _set_color("bar-color", "_BarColor", args[1])
			else
				return _get_color("bar-color", "_BarColor")
		IsSlider()
			if(args.len)
				return _set_boolean("is-slider", "_IsSlider", args[1])
			else
				return _get_boolean("is-slider", "_IsSlider")
		Width()
			if(args.len)
				return _set_number("width", "_Width", args[1])
			else
				return _get_number("width", "_Width")
		Angle1()
			if(args.len)
				return _set_number("angle1", "_Angle1", args[1])
			else
				return _get_number("angle1", "_Angle1")
		Angle2()
			if(args.len)
				return _set_number("angle2", "_Angle2", args[1])
			else
				return _get_number("angle2", "_Angle2")
		Value()
			if(args.len)
				return _set_number("value", "", args[1])
			else
				return _get_number("value", "")
		OnChange()
			if(args.len)
				owner._InterfaceEvents["[window_id].[control_id].change"] = args[1]
			else
				return owner._InterfaceEvents["[window_id].[control_id].change"]
Button
	parent_type = /Control
	var
		_Text
		_Image
		_IsFlat
		_Stretch
		_IsChecked
		_Group
		_ButtonType
	New()
		..()
		winset(owner,"[window_id].[control_id]","command=InterfaceEvent+\"[window_id]\"+\"[control_id]\"+\"command\"")
	proc
		Text()
			if(args.len)
				return _set_text("text", "_Text", args[1])
			else
				return _get_text("text", "_Text")
		Image()
			if(args.len)
				return _set_text("image", "_Image", args[1])
			else
				return _get_text("image", "_Image")
		Command()
			if(args.len)
				owner._InterfaceEvents["[window_id].[control_id].command"] = args[1]
			else
				return owner._InterfaceEvents["[window_id].[control_id].command"]
		IsFlat()
			if(args.len)
				return _set_boolean("is-flat", "_IsFlat", args[1])
			else
				return _get_boolean("is-flat", "_IsFlat")
		Stretch()
			if(args.len)
				return _set_boolean("stretch", "_Stretch", args[1])
			else
				return _get_boolean("stretch", "_Stretch")
		IsChecked()
			if(args.len)
				return _set_boolean("is-checked", "_IsChecked", args[1])
			else
				return _get_boolean("is-checked", "_IsChecked")
		ButtonType()
			if(args.len)
				return _set_buttontype("button-type", "_ButtonType", args[1])
			else
				return _get_buttontype("button-type", "_ButtonType")
Map
	parent_type = /Control
	var
		_IconSize
		_TextMode
	New()
		..()
		winset(owner,"[window_id].[control_id]","on-show=InterfaceEvent+\"[window_id]\"+\"[control_id]\"+\"show\"")
		winset(owner,"[window_id].[control_id]","on-hide=InterfaceEvent+\"[window_id]\"+\"[control_id]\"+\"hide\"")
	proc
		IconSize()
			if(args.len)
				return _set_number("icon-size", "_IconSize", args[1])
			else
				return _get_number("icon-size", "_IconSize")
		TextMode()
			if(args.len)
				return _set_boolean("text-mode", "", args[1])
			else
				return _get_boolean("text-mode", "")
		OnShow()
			if(args.len)
				owner._InterfaceEvents["[window_id].[control_id].show"] = args[1]
			else
				return owner._InterfaceEvents["[window_id].[control_id].show"]
		OnHide()
			if(args.len)
				owner._InterfaceEvents["[window_id].[control_id].hide"] = args[1]
			else
				return owner._InterfaceEvents["[window_id].[control_id].hide"]
Browser
	parent_type = /Control
	var
		_ShowHistory
		_ShowUrl
		_AutoFormat
		_UseTitle
	New()
		..()
		winset(owner,"[window_id].[control_id]","on-show=InterfaceEvent+\"[window_id]\"+\"[control_id]\"+\"show\"")
		winset(owner,"[window_id].[control_id]","on-hide=InterfaceEvent+\"[window_id]\"+\"[control_id]\"+\"hide\"")
	proc
		ShowHistory()
			if(args.len)
				return _set_boolean("show-history", "_ShowHistory", args[1])
			else
				return _get_boolean("show-history", "_ShowHistory")
		ShowUrl()
			if(args.len)
				return _set_boolean("show-url", "_ShowUrl", args[1])
			else
				return _get_boolean("show-url", "_ShowUrl")
		AutoFormat()
			if(args.len)
				return _set_boolean("auto-format", "_AutoFormat", args[1])
			else
				return _get_boolean("auto-format", "_AutoFormat")
		UseTitle()
			if(args.len)
				return _set_boolean("use-title", "_UseTitle", args[1])
			else
				return _get_boolean("use-title", "_UseTitle")
		OnShow()
			if(args.len)
				owner._InterfaceEvents["[window_id].[control_id].show"] = args[1]
			else
				return owner._InterfaceEvents["[window_id].[control_id].show"]
		OnHide()
			if(args.len)
				owner._InterfaceEvents["[window_id].[control_id].hide"] = args[1]
			else
				return owner._InterfaceEvents["[window_id].[control_id].hide"]
Info
	parent_type = /Control
	var
		Color/_HighlightColor
		Color/_TabTextColor
		Color/_TabBackgroundColor
		_TabFontFamily
		_TabFontSize
		_TabFontStyle
		_AllowHtml
		_MultiLine
	New()
		..()
		winset(owner,"[window_id].[control_id]","on-show=InterfaceEvent+\"[window_id]\"+\"[control_id]\"+\"show\"")
		winset(owner,"[window_id].[control_id]","on-hide=InterfaceEvent+\"[window_id]\"+\"[control_id]\"+\"hide\"")
		winset(owner,"[window_id].[control_id]","on-tab=InterfaceEvent+\"[window_id]\"+\"[control_id]\"+\"tab\"")
	proc
		HighlightColor()
			if(args.len)
				return _set_color("highlight-color", "_HighlightColor", args[1])
			else
				return _get_color("highlight-color", "_HighlightColor")
		TabTextColor()
			if(args.len)
				return _set_color("tab-text-color", "_TabTextColor", args[1])
			else
				return _get_color("tab-text-color", "_TabTextColor")
		TabBackgroundColor()
			if(args.len)
				return _set_color("tab-background-color", "_TabBackgroundColor", args[1])
			else
				return _get_color("tab-background-color", "_TabBackgroundColor")
		TabFontFamily()
			if(args.len)
				return _set_text("tab-font-family", "_TabFontFamily", args[1])
			else
				return _get_text("tab-font-family", "_TabFontFamily")
		TabFontSize()
			if(args.len)
				return _set_number("tab-font-size", "_TabFontSize", args[1])
			else
				return _get_number("tab-font-size", "_TabFontSize")
		TabFontStyle()
			if(args.len)
				return _set_fontstyle("tab-font-style", "_TabFontStyle", args[1])
			else
				return _get_fontstyle("tab-font-style", "_TabFontStyle")
		AllowHtml()
			if(args.len)
				return _set_boolean("allow-html", "_AllowHtml", args[1])
			else
				return _get_boolean("allow-html", "_AllowHtml")
		MultiLine()
			if(args.len)
				return _set_boolean("multi-line", "_MultiLine", args[1])
			else
				return _get_boolean("multi-line", "_MultiLine")
		OnShow()
			if(args.len)
				owner._InterfaceEvents["[window_id].[control_id].show"] = args[1]
			else
				return owner._InterfaceEvents["[window_id].[control_id].show"]
		OnHide()
			if(args.len)
				owner._InterfaceEvents["[window_id].[control_id].hide"] = args[1]
			else
				return owner._InterfaceEvents["[window_id].[control_id].hide"]
		OnTab()
			if(args.len)
				owner._InterfaceEvents["[window_id].[control_id].tab"] = args[1]
			else
				return owner._InterfaceEvents["[window_id].[control_id].tab"]
Window
	parent_type = /Control
	var
		_Type
		_Title
		_Titlebar
		_Statusbar
		_CanClose
		_CanMinimize
		_CanResize
		_IsPane
		_IsMinimized
		_IsMaximized
		_CanScroll
		_Icon
		_Image
		_ImageMode
		_KeepAspect
		Color/_TransparentColor
		_Alpha
		_Macro
		_Menu
	New()
		..()
		winset(owner,"[window_id]","on-close=InterfaceEvent+\"[window_id]\"+\"[control_id]\"+\"close\"")
	proc
		Type()
			if(args.len)
				return _set_text("type", "_Type", args[1])
			else
				return _get_text("type", "_Type")
		Title()
			if(args.len)
				return _set_text("title", "_Title", args[1])
			else
				return _get_text("title", "_Title")
		Titlebar()
			if(args.len)
				return _set_boolean("titlebar", "_Titlebar", args[1])
			else
				return _get_boolean("titlebar", "_Titlebar")
		Statusbar()
			if(args.len)
				return _set_boolean("statusbar", "_Statusbar", args[1])
			else
				return _get_boolean("statusbar", "_Statusbar")
		CanClose()
			if(args.len)
				return _set_boolean("can-close", "_CanClose", args[1])
			else
				return _get_boolean("can-close", "_CanClose")
		CanMinimize()
			if(args.len)
				return _set_boolean("can-minimize", "_CanMinimize", args[1])
			else
				return _get_boolean("can-minimize", "_CanMinimize")
		CanResize()
			if(args.len)
				return _set_boolean("can-resize", "_CanResize", args[1])
			else
				return _get_boolean("can-resize", "_CanResize")
		IsPane()
			if(args.len)
				return _set_boolean("is-pane", "_IsPane", args[1])
			else
				return _get_boolean("is-pane", "_IsPane")
		IsMinimized()
			if(args.len)
				return _set_boolean("is-minimized", "_IsMinimized", args[1])
			else
				return _get_boolean("is-minimized", "_IsMinimized")
		IsMaximized()
			if(args.len)
				return _set_boolean("is-maximized", "_IsMaximized", args[1])
			else
				return _get_boolean("is-maximized", "_IsMaximized")
		CanScroll()
			if(args.len)
				return _set_boolean("can-scroll", "_CanScroll", args[1])
			else
				return _get_boolean("can-scroll", "_CanScroll")
		Icon()
			if(args.len)
				return _set_text("icon", "_Icon", args[1])
			else
				return _get_text("icon", "_Icon")
		Image()
			if(args.len)
				return _set_text("image", "_Image", args[1])
			else
				return _get_text("image", "_Image")
		ImageMode()
			if(args.len)
				return _set_imagemode("image-mode", "_ImageMode", args[1])
			else
				return _get_imagemode("image-mode", "_ImageMode")
		KeepAspect()
			if(args.len)
				return _set_boolean("keep-aspect", "_KeepAspect", args[1])
			else
				return _get_boolean("keep-aspect", "_KeepAspect")
		TransparentColor()
			if(args.len)
				return _set_color("transparent-color", "_TransparentColor", args[1])
			else
				return _get_color("transparent-color", "_TransparentColor")
		Alpha()
			if(args.len)
				return _set_number("alpha", "_Alpha", args[1])
			else
				return _get_number("alpha", "_Alpha")
		Macro()
			if(args.len)
				return _set_text("macro", "_Macro", args[1])
			else
				return _get_text("macro", "_Macro")
		Menu()
			if(args.len)
				return _set_text("menu", "_Menu", args[1])
			else
				return _get_text("menu", "_Menu")
		OnClose()
			if(args.len)
				owner._InterfaceEvents["[window_id].[control_id].close"] = args[1]
			else
				return owner._InterfaceEvents["[window_id].[control_id].close"]
Child
	parent_type = /Control
	var
		_Left
		_Right
		_IsVert
		_Splitter
		_ShowSplitter
		_Lock
	New()
		..()
	proc
		Left()
			if(args.len)
				return _set_text("left", "_Left", args[1])
			else
				return _get_text("left", "_Left")
		Right()
			if(args.len)
				return _set_text("right", "_Right", args[1])
			else
				return _get_text("right", "_Right")
		IsVert()
			if(args.len)
				return _set_boolean("is-vert", "_IsVert", args[1])
			else
				return _get_boolean("is-vert", "_IsVert")
		Splitter()
			if(args.len)
				return _set_number("splitter", "", args[1])
			else
				return _get_number("splitter", "")
		ShowSplitter()
			if(args.len)
				return _set_boolean("show-splitter", "_ShowSplitter", args[1])
			else
				return _get_boolean("show-splitter", "_ShowSplitter")