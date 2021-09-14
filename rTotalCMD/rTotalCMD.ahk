;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;~ 文 件：	rToalCMD.ahk —— 将 Total Commander 设置为默认资源管理器，或添加文件夹右键菜单
;~ 作 者:	Cui @ easysky@foxmail.com
;~ 版 本：	v0.05 （2021年9月11日）
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance Ignore
#NoTrayIcon

If (A_Args.Length()!=1) || ((f:=A_Args[1])="")
	ExitApp

_INI_:=A_ScriptDir . "\rTotalCMD.ini",sTC:=A_ScriptDir . "\TOTALCMD64.EXE"
If !FileExist(sTC)
{
	IniRead,sTC,%_INI_%,Set,TC,%A_Space%
	sTC=%sTC%
	If (sTC="") || !FileExist(sTC)
	{
		Gui,+OwnDialogs
		Msgbox,262164,未找到 Total Commander 主程序！,是否要手动指定 TC 主程序路径？
		IfMsgBox,No
			ExitApp
		FileSelectFile,sTC,,,选择 Total Commander 的程序路径,可执行程序文件 (*.exe)
		If ErrorLevel || (sTC="") || !FileExist(sTC)
			ExitApp
		IniWrite,%sTC%,%_INI_%,Set,TC
	}
}

IniRead,Is_OnTab,%_INI_%,Set,NewOnTab,1
If Is_OnTab Not In 0,1
	Is_OnTab:=1
sT:=Is_OnTab?"/T":""
IniRead,t,%_INI_%,Set,Exception,
t:=strReplace(Trim(t,"`t `,"),A_Space),sL:=t . ((t="")?"":"`,") . "::{`,`.tib"
If f Contains %sL%
	Run Explorer.exe %f%
Else
	Run,%sTC% /O %sT% "%f%"
ExitApp