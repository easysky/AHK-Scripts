;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;~ 文 件：	rToalCMD_Setup.ahk —— rToalCMD.ahk 的配置文件
;~ 作 者:	Cui @ easysky@foxmail.com
;~ 版 本：	v0.05 （2021年9月11日）
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance Ignore
#NoTrayIcon

If !A_IsAdmin
{
	Try
		Run *RunAs "%A_AhkPath%" /r "%A_ScriptFullPath%"
	Catch{
		Gui,+OwnDialogs
		MsgBox,262192,设置错误,无法已管理员模式运行，请重试！
		ExitApp
	}
}

_INI_:=A_ScriptDir . "\rTotalCMD.ini"

RegRead,b,HKLM\SOFTWARE\Classes\Folder\shell\open\command,DelegateExecute
Is_Installed:=(b="{11dbb47c-a525-400b-9e80-a54615a090c0}")?0:1

RegRead,b,HKCU\Software\Classes\Directory\shell\用 Total Commander 打开\command
Is_MenuAdded:=(b="")?0:1
IniRead,Is_OnTab,%_INI_%,Set,NewOnTab,1
If Is_OnTab Not In 0,1
	Is_OnTab:=1
IniRead,sL,%_INI_%,Set,Exception,%A_Space%
sL:=strReplace(Trim(sL,"`t `,"),A_Space)

Menu,Tray,Icon,Explorer.exe
Gui,-MinimizeBox +HwndInit_WinID
Gui,Font,,Tahoma
Gui,Font,,微软雅黑
Gui,Add,GroupBox,x10 y0 w275 h95,
Gui,Add,Text,x25 y28,1- 默认文件管理器：
Gui,Add,Text,x135 y28 w60 vrTC_Default,未设置
Gui,Add,Button,x210 y25 w60 h23 grTC_SetDefault vrTC_SetDefault,设置
Gui,Add,Text,x25 y60,2- 添加到右键菜单：
Gui,Add,Text,x135 y60 w60 vrTC_Menu,未添加
Gui,Add,Button,x210 y55 w60 h23 grTC_SetMenu vrTC_SetMenu,添加

Gui,Add,GroupBox,x10 y100 w275 h235,选项
Gui,Add,Text,x25 y125,1- 指定 Total Commander 路径：
Gui,Add,Edit,x25 y150 w210 r1 vrTC_Path,
Gui,Add,Button,x240 y150 w30 grTC_GetTC,...

Gui,Add,Text,x25 w250 y180,2- 从外部打开时，排除含有以下字符的路径，各字符间以半角逗号 [,] 分隔(&E):
Gui,Add,Edit,x25 y220 w245 vrTc_List,%sL%
Gui,Add,CheckBox,x25 y260 vrTC_Tab Checked%Is_OnTab%,3- 作为默认管理器时在新标签栏中打开(&N)

Gui,Add,Button,x190 y300 w80 h25 grTC_Setup,保存设置(&S)
Gui,Add,Link,x25 y305 grTC_About,<a>#关于</a>
Gui,Show,,% "rTotalCMD 设置" (A_IsAdmin?" -（管理员）":"")

_setFont(Is_Installed),_setFont(Is_MenuAdded,0)
If !FileExist(sTC){
	IniRead,sTC,%_INI_%,Set,TC,%A_Space%
	sTC=%sTC%
	If !_func_CheckTCPath(sTC)
		Gosub rTC_GetTC
	Else
		GuiControl,,rTC_Path,%sTC%
}
Return

rTC_SetDefault:
Gui,+OwnDialogs
MsgBox,262180,确认操作,% "确定要" (Is_Installed?"取消":"设置") " Total Commander 作为默认资源管理器？"
IfMsgBox,No
	Return
If !Is_Installed
{
	RegWrite,REG_EXPAND_SZ,HKLM\Software\Classes\Folder\shell\open\command,,%A_ScriptDir%\rTotalCMD.exe "`%1"
	If !ErrorLevel
	{
		RegDelete,HKLM\SOFTWARE\Classes\Folder\shell\open\command,DelegateExecute
		e:=ErrorLevel
		If e
			RegWrite,REG_EXPAND_SZ,HKLM\SOFTWARE\Classes\Folder\shell\open\command,,`%SystemRoot`%\Explorer.exe
	}Else
		e:=1
	errInfo:="设置默认文件管理器:" . A_Space . A_Space . A_Space . (e?"失败":"成功")
}Else{
	RegWrite,REG_EXPAND_SZ,HKLM\SOFTWARE\Classes\Folder\shell\open\command,,`%SystemRoot`%\Explorer.exe
	e:=ErrorLevel
	RegWrite,REG_SZ,HKLM\SOFTWARE\Classes\Folder\shell\open\command,DelegateExecute,{11dbb47c-a525-400b-9e80-a54615a090c0}
	errInfo:="恢复默认文件管理器:" . A_Space . A_Space . A_Space . ((e Or ErrorLevel)?"失败":"成功"),e |= ErrorLevel
}
If !e
	Is_Installed:=!Is_Installed,_setFont(Is_Installed)
_ShowInfo(errInfo,e)
Return

rTC_SetMenu:
Gui,+OwnDialogs
MsgBox,262180,确认操作,% "确定要" (Is_MenuAdded?"移除":"添加") " Total Commander 右键菜单？`n注意：仅对文件夹有效。"
IfMsgBox,No
	Return
If Is_MenuAdded
{
	RegDelete,HKCU\Software\Classes\Directory\shell\用 Total Commander 打开
	e |= ErrorLevel,errInfo:="移除文件夹右键菜单:" . A_Space . A_Space . A_Space .  (ErrorLevel?"失败":"成功")
}Else{
	t:=Is_OnTab?"/T":""
	RegWrite,REG_SZ,HKCU\Software\Classes\Directory\shell\用 Total Commander 打开\command,,%sTC% /O %t% `%1
	e |= ErrorLevel,errInfo:="添加文件夹右键菜单:" . A_Space . A_Space . A_Space .  (ErrorLevel?"失败":"成功")
}
If !e	;设置成功
	Is_MenuAdded:=!Is_MenuAdded,_setFont(Is_MenuAdded,0)
_ShowInfo(errInfo,e)
Return

rTC_GetTC:
Gui,+OwnDialogs
FileSelectFile,t,%sTC%,,选择 Total Commander 的程序路径,可执行程序文件 (*.exe)
If ErrorLevel
	Return
GuiControl,,rTC_Path,%t%
sTC:=t,t:=""
IniWrite,%sTc%,%_INI_%,Set,TC
Return

rTC_Setup:	;保存设置
GuiControlGet,t,,rTC_Path
t=%t%
If !_func_CheckTCPath(t)
	Return
If (t!=sTC){
	sTc:=t,t:=""
	IniWrite,%sTc%,%_INI_%,Set,TC
}
GuiControlGet,t,,rTc_List
t:=StrReplace(Trim(t,"`t `,"),A_Space)
If (t!=sL){
	sL:=t,t:=""
	IniWrite,%sL%,%_INI_%,Set,Exception
}
GuiControlGet,t,,rTC_Tab
If (t!=Is_OnTab){
	Is_OnTab:=t,t:=""
	IniWrite,%Is_OnTab%,%_INI_%,Set,NewOnTab
}
Gui,+OwnDialogs
Msgbox,262208,保存设置,设置已更新！
Return

GuiClose:
GuiEscape:
ExitApp
Return

rTC_About:
Gui,+OwnDialogs
Msgbox,262208,关于 rTotalCMD,
(
rTotalCMD - 将 TC 设置为默认文件管理器
版本: v0.0.5（2021/09/11）
`nCui @2013-%A_yyyy%
`n[Email]%A_Tab%easysky@foxmail.com
[QQ]%A_Tab%3121356095#easysky
[主页]%A_Tab%https://easysky.top
`n我的追求 — 新颖、便携、简洁、高效、人性化体验
)
Return

_setFont(b,i:=1){
	Gui,Font,% (b?"c0000ff":"cff0000") " Bold"
	GuiControl,Font,% i?"rTC_Default":"rTC_Menu"
	GuiControl,,% i?"rTC_Default":"rTC_Menu",% (b?"已":"未") (i?"设置":"添加")
	GuiControl,,% i?"rTC_SetDefault":"rTC_SetMenu",% i?((b?"取消":"设置") "(&S)"):((b?"移除":"添加") "(&M)")
}

_func_CheckTCPath(s){
	If (s="") || !FileExist(s)
	{
		Gui,+OwnDialogs
		Msgbox,262192,路径错误,当前路径未找到 Total Commander，请重新选择！
		GuiControl,Focus,rTC_Path
		SendInput ^a
		Return 0
	}
	Return 1
}

_ShowInfo(s,b){
	Gui,+OwnDialogs
	If b
		MsgBox,262192,设置失败,%s%`n`n请检查后重试！
	Else
		MsgBox,262208,设置成功,%s%
}