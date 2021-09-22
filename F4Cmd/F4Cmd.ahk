;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;~ 文 件：	F4CMD.ahk —— Total Commander 文件打开方式菜单
;~ 作 者:	Cui @ easysky@foxmail.com
;~ 版 本：	v0.0.4 （2021年9月18日）
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance Ignore
#NotrayIcon
CoordMode,Mouse,Screen
SysGet,W,MonitorWorkArea

Global f=
If (A_Args.Length()!=1) || ((f:=A_Args[1])="")
{
	Gui,+OwnDialogs
	MsgBox,262208,说明,
(
F4Cmd - 文件打开方式菜单
版本: v0.0.4（2021/09/18）
`n本程序用于在 TotalCMD 中定义各种文件类型的打开方式。
执行后将弹出自定义菜单用于选择打开方式。
也可用于除 TC 外的其他场合。
`n注意：程序运行需要且仅需一个参数，即将要打开的文件路径。
`nCui, 2013-%A_yyyy%
[Email]%A_Tab%easysky@foxmail.com
[QQ]%A_Tab%3121356095#easysky
[主页]%A_Tab%https://easysky.top
`n我的追求 —— 新颖、便携、简洁、高效、人性化体验！
)
	ExitApp
}

WinGetClass,t,A
b_IsFrTC:=(t="TTOTAL_CMD")?1:0,t:="",_iniF:=A_ScriptDir . "\F4Cmd.ini",arr_A:=[],err:=0,b_IsEdit:=0
Menu,Tray,Icon,shell32.dll,69,1

If !FileExist(_iniF)
	err:=1

If !err
{
	SplitPath,f,,,f_Ext
	;开始读取文件关联
	IniRead,s,%_iniF%
	s:=Trim(s)
	If (s="") Or (s="General")
		err:=1	;ini配置文件中没有指定任何文件类型
}
If !err
{
	str_Ext=
	Loop,Parse,s,`n
	{
		If (A_LoopField="") Or (A_LoopField="General")
			Continue
		If InStr("," A_LoopField ",","," f_Ext ",")
		{
			str_Ext:=A_LoopField
			Break
		}
	}
	If (str_Ext="")
		err:=1
}

If !err
{
	IniRead,s,%_iniF%,%str_Ext%
	s:=Trim(s),n:=0
	Loop,Parse,s,`n
	{
		y1:=y2:=""
		If RegexMatch(A_LoopField,"(.+?)=(.+)",y)
		{
			arr_A[y1]:=y2,n+=1
			Menu,Menu_Main,Add,%y1%,cmd_Main
		}
	}
	If (n=0)
		err:=1
}

IniRead,b_SkipMenu,%_iniF%,General,SkipMenu,0
If b_SkipMenu Not In 0,1
	b_SkipMenu:=0

If !err && (n=1) && b_SkipMenu
{
	_Open_File(y2)
		ExitApp
}

Gosub Add_DefMenu
If !err
{
	Menu,Menu_Main,Add,
	Menu,Menu_Main,Add,打开方式与设置,:Menu_Sys
	Menu,Menu_Main,Show
}Else
	Menu,Menu_Sys,Show
If !b_IsEdit
	ExitApp
Return

Add_DefMenu:
Menu,Menu_Sys,Add,1- 系统默认关联,cmd_Sys		;1
Menu,Menu_Sys,Add,2- TotalCMD 内部关联,cmd_Sys		;2
Menu,Menu_Sys,Add,3- TotalCMD 预览,cmd_Sys			;3
Menu,Menu_Sys,Add,4- 以文本模式打开,cmd_Sys			;4
Menu,Menu_Sys,Add,
Menu,Menu_Sys,Add,编辑本组文件关联(&E),cmd_Sys				;6
Menu,Menu_Sys,Add,解除本组文件关联(&X),cmd_Sys				;7
Menu,Menu_Sys,Add,仅一个关联时跳过菜单(&K),cmd_Sys,+Radio			;8
Menu,Menu_Sys,% b_IsFrTC?"Enable":"Disable",2&
Menu,Menu_Sys,% err?"Disable":"Enable",7&
Menu,Menu_Sys,% b_SkipMenu?"check":"uncheck",8&
Return

cmd_Main:
_Open_File(arr_A[A_ThisMenuItem])
Return

cmd_Sys:
If (A_ThisMenuItemPos=1)
	_Open_File()
Else If (A_ThisMenuItemPos=2)
	SendInput {Enter}
Else If (A_ThisMenuItemPos=3)
{
	If b_IsFrTC
		SendInput {F3}
	Else{
		If !b_IsFrTC
		{
			IniRead,sTC,%_iniF%,General,TC,%A_Space%
			sTC=%sTC%
			If (sTC="") || !FileExist(sTC)
			{
				Gui,+OwnDialogs
				MsgBox,262196,指定 Total Commander,当前文件定义为调用 TC Lister 插件进行查看，但尚未指定 TC 程序！`n是否立即指定？
				IfMsgBox,Yes
				{
					FileSelectFile,sTC,,,指定 Total Commander 程序,可执行程序(*.exe)
					sTC=%sTC%
					If ErrorLevel || (sTC="") || !FileExist(sTC)
					{
						MsgBox,262192,Error,Total Commander 路径错误！
						ExitApp
					}Else{
						_Open_File(sTC A_Space "/s=L")
						IniWrite,%sTC%,%f%,General,TC
					}
				}
			}Else
				_Open_File(sTC A_Space "/s=L")
		}
	}
}Else If (A_ThisMenuItemPos=4)
	_Open_File("notepad.exe")
Else If (A_ThisMenuItemPos=6){
	b_IsEdit:=1
	Gosub _Config_Edit
}Else If (A_ThisMenuItemPos=7){
	Gui,+OwnDialogs
	MsgBox,262196,解除文件关联,确定解除本组文件关联？`n注意：该操作将删除本组所有已定义的文件类型，且不可恢复！
	IfMsgBox,Yes
	{
		b_IsEdit:=1
		IniDelete,%_iniF%,%str_Ext%
		ToolTip,已解除文件关联！
		SetTimer,NoTip,-1500
	}
}Else If (A_ThisMenuItemPos=8)
	IniWrite,% !b_SkipMenu,%_iniF%,General,SkipMenu
Return

_Open_File(s:=""){
	If (s!="")
		s.=A_Space
	Try Run,% s """" f """"
	Catch{
		Gui,+OwnDialogs
		MsgBox,262192,F4Cmd,打开文件错误，请检查配置文件！
	}
}

;----

_Config_Edit:
Gui,CE:New
Gui,CE:+Resize +MinSize -MinimizeBox +HwndCEWin
Gui,CE:Font,,Tahoma
Gui,CE:Font,,Microsoft Yahei
Gui,CE:Add,Edit,x5 y5 -Wrap vff_exts,% (str_Ext="")?f_Ext:str_Ext
Gui,CE:Add,Edit,x5 y35 HScroll -Wrap Multi vff_cmd,
MouseGetPos,dx,dy
If (dy+250>=WBottom)
	dy:=WBottom-250
If (dx+420>=WRight)
	dx:=WRight-420
Gui,CE:Show,x%dx% y%dy% h210 w500,# 菜单编辑 # — [Ctrl+S] 保存，[ESC] 退出，[F1] 查看格式
s=
For s1,s2 In arr_A
	s.=((A_Index=1)?"":"`n") s1 "=" s2
GuiControl,CE:,ff_cmd,%s%
Return

CEGuiSize:
GuiControl,CE:MoveDraw,ff_exts,% "w" A_GuiWidth-10
GuiControl,CE:MoveDraw,ff_cmd,% "w" A_GuiWidth-10 "h" A_GuiHeight-40
Return

#if WinActive("ahk_id " CEWin)
^s::
GuiControlGet,s1,CE:,ff_exts
GuiControlGet,s2,CE:,ff_cmd
Gui,CE:Cancel
s1:=Trim(s1,"`t `,"),s2:=Trim(RegexReplace(s2,"`n{2,}","`n"),"`r`n `t")
If (s1="") || (s2="")
	Return
If (str_Ext!="") && (s1!=str_Ext)
	IniDelete,%_iniF%,%str_Ext%
IniWrite,%s2%,%_iniF%,%s1%
ToolTip,已保存文件关联！
SetTimer,NoTip,-1500
Return

F1::
Gui,CE:+OwnDialogs
MsgBox,262208,书写格式,上栏为文件类型分组，以半角逗号（`,）分隔，如：`n%A_Space%%A_Space%%A_Space%%A_Space%rar,zip,7z`n`n下栏为定义菜单，每行定义一个，格式为：`n%A_Space%%A_Space%%A_Space%%A_Space%[菜单名]=[执行程序路径]
Return
#if

NoTip:
CEGuiClose:
CEGuiEscape:
ExitApp
Return