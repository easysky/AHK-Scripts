#SingleInstance Ignore
#NoTrayIcon

Gui,+OwnDialogs
errFlag:=0
If (A_Args.Length()<>2)
{
	MsgBox,262192,执行错误,该程序需配合 Total Commander 运行，且需同时满足以下要求：`n`n● TC 活动窗口选中行是目录，且只选中一行`n● TC 活动窗口没有选择行，但焦点所在行是目录`n● TC 非活动窗口所在磁盘为 NTFS 文件格式
	ExitApp
}
t_Des:=A_Args[1],t_Src:=A_Args[2]
If !InStr(FileExist(t_Src),"D")
{
	MsgBox,262192,参数错误,Total Commander 活动窗口中需满足以下要求：`n`n● 选中行是目录，且只选中一行`n● 没有选择行，但焦点所在行是目录
	ExitApp
}
SplitPath,t_Des,tempText,t_Des,,,tempStr	;tempText——目录名；tempStr——驱动器；t_Des——目录
DriveGet,errFlag,FS,%tempStr%
If (errFlag<>"NTFS"){
	MsgBox,262192,参数错误,Total Commander 非活动窗口中的磁盘“%tempStr%”必须为 NTFS 文件系统格式！
	ExitApp
}

WinGet,errFlag,Id,Ahk_Class TTOTAL_CMD
Gui,-MinimizeBox +Owner%errFlag%
Gui,Font,,Tahoma
Gui,Font,,微软雅黑
Gui,Add,Text,x10 y23,目录联接名(&T):
Gui,Font,Bold
Gui,Add,Edit,x100 y20 w300 c800000 r1 gTC_Name vTC_Name,%tempText%
Gui,Font,Norm
Gui,Add,Text,x10 y53,联接位置(&P):
Gui,Add,Edit,x100 y50 w300 r1 ReadOnly vTC_Des,%t_Des%\%tempText%
Gui,Add,Text,x10 y83,指向源目录(&S):
Gui,Add,Edit,x100 y80 w300 r1 ReadOnly,%t_Src%
Gui,Add,Button,x10 y125 w60 gTC_Info,关于(A)
Gui,Add,Button,x195 y125 w100 Default gTC_Creat,创建(C)
Gui,Add,Button,x300 y125 w100 gTC_Exit,退出(&X)
Gui,Show,,TCmklink - 创建目录联接
Return

TC_Name:
GuiControlGet,tempStr,,TC_Name
tempStr=%tempStr%
GuiControl,,TC_Des,%t_Des%\%tempStr%
tempStr=
Return

TC_Creat:
Gui,+OwnDialogs
GuiControlGet,tempStr,,TC_Name
tempStr=%tempStr%
If (tempStr=""){
	GuiControl,Focus,TC_Name
	Return
}
If RegexMatch(tempStr,"[\\/:\*\?""<>\|]")
{
	MsgBox,262192,错误,联接名称不得包含以下任意字符:`n%A_Space%\ / : * \ ? "" < > |
	GuiControl,Focus,TC_Name
	SendInput ^a
	Return
}
t_Des .= "\" . tempStr,errFlag:=0
Gui,Destroy
RunWait,%comspec% /c "mklink /j "%t_Des%" "%t_Src%" > "%A_Temp%\~TC_MKLINK_RESULT.TMP"",,Hide UseErrorLevel
If (ErrorLevel="ERROR")
	errFlag:=1
Else{
	FileReadLine,tempStr,%A_Temp%\~TC_MKLINK_RESULT.TMP,1
	If (ErrorLevel)
		errFlag:=1
	Else{
		tempStr=%tempStr%
		If (tempStr<>"为 " . t_Des . " <<===>> " . t_Src . " 创建的联接")
			errFlag:=1
	}
}
FileDelete,%A_Temp%\~TC_MKLINK_RESULT.TMP
If (errFlag=0)
	MsgBox,262208,创建目录联接成功,成功创建目录联接！,5
Else
	MsgBox,262192,错误,创建目录联接错误，请检查后重试！
ExitApp
Return

TC_Info:
Gui,+OwnDialogs
MsgBox,262208,关于,
(
TCmklink - TC目录联接菜单
版本: v0.0.3（2019/04/29）
`n用于 Total Commander（以下简称 TC）的“开始”菜单中，为当前活动窗口中的焦点目录或唯一选择的目录创建目录联接（即软链接），联接的路径位于 TC 的非活动窗口所在目录下。
`n在“目录联接名”输入框内输入新目录名，「创建」即可。
`nEasysky Studio, 2013-%A_yyyy%
[Email]%A_Tab%easysky@foxmail.com
[QQ]%A_Tab%3121356095#easysky
[主页]%A_Tab%https://easysky.top
`n我的追求 —— 新颖、便携、简洁、高效、人性化体验！
)
Return

GuiClose:
TC_Exit:
ExitApp