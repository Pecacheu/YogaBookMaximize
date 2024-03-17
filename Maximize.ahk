; Window Control for Yoga Book 9i by https://github.com/Pecacheu

#Requires AutoHotkey v2
#SingleInstance Force
CoordMode("Mouse", "Screen")
SendMode("Event")
DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")

; Media Controls
^F1::Send "{Media_Play_Pause}"	; Ctrl + F1 = Play/Pause
^F2::Send "{Media_Prev}"		; Ctrl + F2 = Prev
^F3::Send "{Media_Next}"		; Ctrl + F3 = Next

; Inspired by https://stackoverflow.com/a/9830200/470749
; Shift + Win + Up = Maximize
+#Up:: {
	; Display
	Mon1 := getMon(True)
	Mon2 := getMon(False)
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

; Ctrl + Win + Up = Wonderbar Window
^#Up:: wonderWin()

wonderWin() {
	; Display
	Mon := getMon(False)
	X := Mon[1], Y := Mon[2], W := Mon[3]-X, H := Mon[4]-Y
	W += 24
	; Get Windows
	TID := WinExist("TouchPadWindow")
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

validMon(Num) {
	Return EnumDisplayDevices(Num-1, &Dev) && Dev["DevString"]=="Lenovo HDR Display"
}
getMon(Top) {
	if Top {
		MonitorGet(1, &L, &T, &R, &B)
		if validMon(1)
			Return [L, T, R, B]
	} else {
		MCnt := MonitorGetCount()
		Loop MCnt {
			MonitorGet(A_Index, &L, &T, &R, &B)
			if A_Index > 1 && validMon(A_Index)
				Return [L, T, R, B]
		}
	}
	Throw "Could not find " (Top?"top":"bottom") " display!"
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
EDD_GET_DEVICE_INTERFACE_NAME := 0x00000001,
	byteCount		:= 4+4+((32+128+128+128)*2),
	ofs_cb			:= 0,
	ofs_DevName		:= 4,
	len_DevName		:= 32,
	ofs_DevString	:= 4+(32*2),
	len_DevString	:= 128,
	ofs_StateFlags	:= 4+((32+128)*2),
	ofs_DevID		:= 4+4+((32+128)*2),
	len_DevID		:= 128,
	ofs_DevKey		:= 4+4+((32+128+128)*2),
	len_DevKey		:= 128

EnumDisplayDevices(iDevNum, &dev) {
	dev := ""
	if iDevNum~="\D"
		Return False
	lpDisDev := Buffer(byteCount,0)
	Numput("UInt",byteCount,lpDisDev,ofs_cb)
	if !DllCall("EnumDisplayDevices","Ptr",0,"UInt",iDevNum,"Ptr",lpDisDev.Ptr,"UInt",0)
		Return False
	DevName := StrGet(lpDisDev.Ptr+ofs_DevName,len_DevName)
	lpDisDev.__New(byteCount,0), Numput("UInt",byteCount,lpDisDev,ofs_cb)
	lpDev := Buffer(len_DevName*2,0), StrPut(DevName, lpDev, len_DevName)
	dwFlags := EDD_GET_DEVICE_INTERFACE_NAME
	DllCall("EnumDisplayDevices","Ptr",lpDev.Ptr,"UInt",0,"Ptr",lpDisDev.Ptr,"UInt",dwFlags)
	For k in dev := Map("cb",0,"DevName","","DevString","","StateFlags",0,"DevID","","DevKey","") {
		Switch k {
			case "cb","StateFlags": dev[k] := NumGet(lpDisDev, ofs_%k%,"UInt")
			default: dev[k] := StrGet(lpDisDev.Ptr+ofs_%k%, len_%k%)
		}
	}
	Return !!dev["StateFlags"]
}