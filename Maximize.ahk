; Window Control for Yoga Book 9i v1.2 by https://github.com/Pecacheu

#Requires AutoHotkey v2
#SingleInstance Force
CoordMode("Mouse", "Screen")
SendMode("Event")
DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")

; Media Controls
^F1::Send "{Media_Play_Pause}"	; Ctrl + F1 = Play/Pause
^F2::Send "{Media_Prev}"		; Ctrl + F2 = Prev
^F3::Send "{Media_Next}"		; Ctrl + F3 = Next

+#Up::Maximize	; Shift + Win + Up = Maximize
^#Up::WonderWin	; Ctrl + Win + Up = Wonderbar Window
#/::Norm		; Win + / = Landscape
#\::RevNorm		; Win + \ = Inverse Landscape

A_TrayMenu.Add()
A_TrayMenu.Add("Maximize", Maximize)
A_TrayMenu.Add("Wonderbar Window", WonderWin)
A_TrayMenu.Add()
A_TrayMenu.Add("Landscape", Norm)
A_TrayMenu.Add("Inverse Landscape", RevNorm)
A_TrayMenu.Add("Top Only", TopOnly)
A_TrayMenu.Add("Bottom Only", BtmOnly)
A_TrayMenu.Add()
A_TrayMenu.Add("-", Ignore)

; Constants
TPWinName	:= "TouchPadWindow"
MonName		:= "Lenovo HDR Display"
MonWidth	:= 2880
MonHeight	:= 1800

Norm(*) {
	Mon1 := getMon(1)
	Mon2 := getMon(2)
	ScrSetPos(Mon1[5]["DevName"], 0, 0, 0, 0)
	ScrSetPos(Mon2[5]["DevName"], 0, MonHeight, 0, 0)
	ScrApply(0)
}
RevNorm(*) {
	Mon1 := getMon(1)
	Mon2 := getMon(2)
	ScrSetPos(Mon1[5]["DevName"], 0, 0, 180, 0)
	ScrSetPos(Mon2[5]["DevName"], 0, -MonHeight, 180, 0)
	ScrApply(0)
}
TopOnly(*) {
	Mon1 := getMon(1)
	Mon2 := getMon(2)
	ScrSetPos(Mon1[5]["DevName"], 0, 0, 0, 0)
	ScrSetPos(Mon2[5]["DevName"], '', '', '', true)
	ScrApply(0)
}
BtmOnly(*) {
	Mon1 := getMon(1)
	Mon2 := getMon(2)
	ScrSetPos(Mon2[5]["DevName"], 0, 0, 0, 0)
	ScrSetPos(Mon1[5]["DevName"], '', '', '', true)
	ScrApply(0)
}

Ignore(*) {
}

; Inspired by https://stackoverflow.com/a/9830200/470749
Maximize(*) {
	; Display
	Mon1 := getMon(1)
	Mon2 := getMon(2)
	X := Min(Mon1[1],Mon2[1]), Y := Min(Mon1[2],Mon2[2])
	W := Max(Mon1[3],Mon2[3])-X, H := Max(Mon1[4],Mon2[4])-Y
	X -= 12, Y -= 12, W += 24, H += 24
	; Window
	WID := WinExist("A")
	if !WID || !WinGetTitle()
		Return ; Avoid System/Explorer Window
	BlockInput(True)
	WinMove(0,0)
	WinMaximize()
	StyMax := WinGetStyle()
	WinSetAlwaysOnTop(0)
	WinRestore()
	WinMove(X, Y, W, H)
	WinSetStyle(StyMax)
	WinGetPos(&WX, &WY, &WW, &WH)
	; Try again wo/ Maximize
	if WW != W || WH != H {
		WinRestore()
		WinMove(X, Y, W, H)
	}
	BlockInput(False)
}

WonderWin(*) {
	; Display
	Mon := getMon(2)
	X := Mon[1], Y := Mon[2], W := Mon[3]-X, H := Mon[4]-Y
	W += 24
	; Get Windows
	TID := WinExist(TPWinName)
	WID := WinExist("A")
	if !WID || !WinGetTitle()
		Return ; Avoid System/Explorer Window
	BlockInput(True)
	; Main Window
	WinMove(0,0)
	WinMaximize()
	StyMax := WinGetStyle()
	WinRestore()
	MW := W*(TID?2/3:1)
	WinMove(X-12, Y-12, MW, 800)
	WinSetStyle(StyMax)
	WinSetAlwaysOnTop(0)
	; Touchpad
	if TID {
		WinExist("ahk_id " TID)
		TPW := (W/3)+1
		WinMove(X+W-TPW, Y, TPW, 778)
		MX := X+W-TPW/2, MY := Y+25
		MouseMove(MX, MY, 0)
		Send("{Click Down}{Click " MX-50 " " MY " 0}{Click " MX " " MY " 0}{Click Up}")
		MouseMove(X+W/3, MY, 0)
	}
	BlockInput(False)
}

getMon(Num) {
	MCnt := MonitorGetCount()
	VCnt := 0
	while EnumDisplayDevices(A_Index-1, &Dev) {
		if Dev["DevString"]==MonName {
			DI := False
			Loop MCnt {
				DN := MonitorGetName(A_Index)
				if InStr(Dev["DevName"], DN) {
					DI := A_Index
					Break
				}
			}
			VCnt++
			if VCnt == Num {
				if DI
					MonitorGet(DI, &L, &T, &R, &B)
				else
					L := T := R := B := 0
				Dev["DevName"] := RegExReplace(Dev["DevName"], "\\\w+$", '')
				Return [L, T, R, B, Dev, A_Index]
			}
		}
	}
	Throw "Could not find display #" Num "!"
}

/*
EnumDisplayDevicesW function (winuser.h)
	https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enumdisplaydevicesw
DISPLAY_DEVICEA structure (wingdi.h)
	https://learn.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-display_devicea
Get display name that matches that found in display settings
	https://stackoverflow.com/questions/7486485/get-display-name-that-matches-that-found-in-display-settings
Secondary Monitor
	https://www.autohotkey.com/board/topic/20084-secondary-monitor
*/
EDD_GET_DEV_INTERFACE_NAME := 0x00000001
size_lpd		:= 4+4+((32+128+128+128)*2)
ofs_cb			:= 0
ofs_DevName		:= 4
len_DevName		:= 32
ofs_DevString	:= 4+(32*2)
len_DevString	:= 128
ofs_StateFlags	:= 4+((32+128)*2)
ofs_DevID		:= 4+4+((32+128)*2)
len_DevID		:= 128
ofs_DevKey		:= 4+4+((32+128+128)*2)
len_DevKey		:= 128

EnumDisplayDevices(iDevNum, &dev) {
	dev := ""
	if iDevNum~="\D"
		Return False
	lpDisDev := Buffer(size_lpd,0)
	NumPut("UInt",size_lpd,lpDisDev,ofs_cb)
	if !DllCall("EnumDisplayDevicesW","Ptr",0,"UInt",iDevNum,"Ptr",lpDisDev.Ptr,"UInt",0)
		Return False
	DevName := StrGet(lpDisDev.Ptr+ofs_DevName,len_DevName)
	lpDisDev.__New(size_lpd,0), NumPut("UInt",size_lpd,lpDisDev,ofs_cb)
	lpDev := Buffer(len_DevName*2,0), StrPut(DevName, lpDev, len_DevName)
	dwFlags := EDD_GET_DEV_INTERFACE_NAME
	res := DllCall("EnumDisplayDevicesW","Ptr",lpDev.Ptr,"UInt",0,"Ptr",lpDisDev.Ptr,"UInt",dwFlags)
	if(res) {
		For k in dev := Map("cb",0,"DevName","","DevString","","StateFlags",0,"DevID","","DevKey","") {
			Switch k {
				case "cb","StateFlags": dev[k] := NumGet(lpDisDev, ofs_%k%,"UInt")
				default: dev[k] := StrGet(lpDisDev.Ptr+ofs_%k%, len_%k%)
			}
		}
	}
	Return res
}

DM_POSITION			:= 0x00000020
DM_DISPORIENT		:= 0x00000080
DM_PELSWIDTH		:= 0x00080000
DM_PELSHEIGHT		:= 0x00100000
CDS_UPDATEREGISTRY	:= 0x00000001
CDS_SET_PRIMARY		:= 0x00000010
CDS_NORESET			:= 0x10000000
CDS_RESET			:= 0x20000000
size_dm		:= 220
ofs_dmSize	:= 68
ofs_dmFld	:= 72
ofs_x		:= 76
ofs_y		:= 80
ofs_r		:= 84
ofs_w		:= 172
ofs_h		:= 176

; Inspired by BoBo @ AutoHotKey Forums
ScrSetPos(devName, xPos, yPos, rDeg, disable) {
	switch rDeg {
		Case 90: mode := 1
		Case 180: mode := 2
		Case 270: mode := 3
		Default: mode := 0
	}
	DEVMODE := Buffer(size_dm,0)
	NumPut("Short", size_dm, DEVMODE, ofs_dmSize) ; dmSize
	dStr := Buffer(len_DevName*2,0)
	StrPut(devName, dStr, len_DevName, "UTF-16")
	DllCall("EnumDisplaySettingsW", "Ptr", dStr.Ptr, "Int", 0, "Ptr", DEVMODE.Ptr)
	dmFields := 0
	dwFlags := CDS_NORESET | CDS_UPDATEREGISTRY
	if disable == true {
		NumPut("UInt", 0, DEVMODE, ofs_w) ; dmPelsWidth
		NumPut("UInt", 0, DEVMODE, ofs_h) ; dmPelsHeight
		dmFields |= DM_POSITION | DM_PELSWIDTH | DM_PELSHEIGHT
	} else {
		if IsInteger(xPos) && IsInteger(yPos) {
			MsgBox("Set " devName " to " xPos " x " yPos)
			if xPos == 0 && yPos == 0
				dwFlags |= CDS_SET_PRIMARY
			NumPut("Int", xPos, DEVMODE, ofs_x) ; dmPosition X
			NumPut("Int", yPos, DEVMODE, ofs_y) ; dmPosition Y
			NumPut("UInt", MonWidth, DEVMODE, ofs_w) ; dmPelsWidth
			NumPut("UInt", MonHeight, DEVMODE, ofs_h) ; dmPelsHeight
			dmFields |= DM_POSITION | DM_PELSWIDTH | DM_PELSHEIGHT
		}
		if IsInteger(rDeg) {
			NumPut("UInt", mode, DEVMODE, ofs_r) ; dmDisplayOrientation
			dmFields |= DM_DISPORIENT
		}
	}
	NumPut("UInt", dmFields, DEVMODE, ofs_dmFld)
	DllCall("ChangeDisplaySettingsExW", "Ptr", dStr.Ptr, "Ptr",
		DEVMODE.Ptr, "Ptr", 0, "UInt", dwFlags, "Ptr", 0)
}
ScrApply(force) {
	dwFlags := force ? CDS_RESET : 0
	DllCall("ChangeDisplaySettingsExW", "Ptr", 0, "Ptr",
		0, "Ptr", 0, "UInt", dwFlags, "Ptr", 0)
}