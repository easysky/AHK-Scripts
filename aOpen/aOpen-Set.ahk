#SingleInstance Ignore
#NoTrayIcon

f:=A_ScriptDir . "\aOpen.ini"
IniRead,sTC,%f%,General,TC,%A_Space%
sTC=%sTC%
If !FileExist(sTC)
	sTC=
IniRead,sDir,%f%,General,Dir,%A_Space%
sDir=%sDir%

Menu,Tray,Icon,% (sTC="")?"shell32.dll":sTC,% (sTC="")?-273:1
Gui,Font,,Tahoma
Gui,Font,,Microsoft Yahei
Gui,Add,GroupBox,x5 y5 w425 h135,选项
Gui,Add,Button,x25 y35 w80 h25 go_Get vbtn_P1,TC 路径(&T)
Gui,Add,Edit,x110 y35 w305 vo_P1,%sTC%
Gui,Add,Button,x25 y72 w80 h25 gbtn_Dir,特定目录(&D)
Gui,Add,Edit,x110 y70 w305 vo_Dir,%sDir%
Gui,Add,Text,x25 y110 c0066cc,# 多个目录间以半角逗号 [,] 分隔。
Gui,Font,Bold
Gui,Add,Button,x345 y105 w70 h25 go_Save vo_s1,保存(&S)
Gui,Font,Norm
Gui,Add,GroupBox,x5 y145 w425 h220,列表
Gui,Add,Text,x30 y175,文件类型(&C)
Gui,Add,ComboBox,x110 y170 w150 go_List vo_List,
Gui,Font,Bold
Gui,Add,Button,x270 y170 w70 h25 Disabled go_Save vo_s2,删除(&X)
Gui,Add,Button,x345 y170 w70 h25 Disabled go_Save vo_s3,应用(&A)
Gui,Font,Norm
Gui,Add,Button,x25 y205 w80 h25 go_Get vbtn_P2,特定程序(&F)
Gui,Add,Edit,x110 y205 w305 vo_P2,
Gui,Add,Button,x25 y240 w80 h25 go_Get vbtn_P3,一般程序(&N)
Gui,Add,Edit,x110 y240 w305 vo_P3,
Gui,Add,GroupBox,x10 y270 w410 h85,
Gui,Add,Text,x15 y290 c0066cc,“文件类型”：多个文件类型间以半角逗号 [,] 分隔；`n“特定程序”：可指定“def”、“Default”或留空， 使用默认关联程序；`n“一般程序”：可指定“TC”，用 TotalCMD 预览（需指定 TC 路径）
Gui,Show,,aOpen 设置

IniRead,s,%f%,Files
s:=Trim(s,"`t`r `n")
If (s="")
	Return
arr_F:=[]
Loop,Parse,s,`n,`r
{
	r:=Trim(A_LoopField),t1:=t2:=""
	If !RegexMatch(r,"(.+?)=(.+)",t)
		Continue
	r1:=r2:=""
	Loop,Parse,t2,|
		r%A_Index%:=Trim(A_LoopField)
	arr_F[t1]:=[r1,r2]
	GuiControl,,o_List,%t1%
}
last_T=
Return

o_List:
GuiControlGet,str_Type,,o_List
GuiControl,% (str_Type="")?"Disable":"Enable",o_s3
If !arr_F[str_Type] || (str_Type="")
{
	GuiControl,,o_P2,
	GuiControl,,o_P3,
	GuiControl,Disable,o_s2
	Return
}
GuiControl,Enable,o_s2
If (str_Type<>last_T){
	GuiControl,,o_P2,% arr_F[str_Type][1]
	GuiControl,,o_P3,% arr_F[str_Type][2]
	last_T:=str_Type
}
Return

o_Get:
Gui,+OwnDialogs
FileSelectFile,tt,,,选择程序,可执行程序 (*.exe)
tt=%tt%
If ErrorLevel || (tt="")
	Return
r:=strreplace(A_GuiControl,"btn","o")
GuiControl,,%r%,%tt%
r:=tt:=""
Return

btn_Dir:
Gui,+OwnDialogs
FileSelectFolder,tt,,,指定特殊目录
If ErrorLevel
	Return
GuiControlGet,r,,o_Dir
r=%r%
GuiControl,,o_Dir,% ((r="")?"":(r ((SubStr(r,0)=",")?"":","))) tt
r:=StrLen(tt)
GuiControl,Focus,o_Dir
SendInput {End}+{Left %r%}
r:=tt:=""
Return

o_Save:
Gui,+OwnDialogs
If (A_GuiControl="o_s1"){
	GuiControlGet,sTC,,o_P1
	sTC=%sTC%
	If (sTC!="") && !FileExist(sTC)
	{
		MsgBox,262192,路径错误,Total Commander 路径设置错误，请重试！
		GuiControl,Focus,o_P1
		SendInput ^a
		Return
	}
	IniWrite,%sTC%,%f%,General,TC
	GuiControlGet,sDir,,o_Dir
	sDir=%sDir%
	IniWrite,%sDir%,%f%,General,Dir
	tt:="已保存设置"
}Else If (A_GuiControl="o_s2"){
	MsgBox,262196,确认操作,确定删除“%str_Type%”的定义？`n注意：本操作无法恢复！
	IfMsgBox,No
		Return
	IniDelete,%f%,Files,%str_Type%
	GuiControl,Text,o_List,
	GuiControl,,o_P2,
	GuiControl,,o_P3,
	ControlGet,tt,List,,ComboBox1,A
	tt:=strreplace(tt,"`n","|"),tt:=Trim(strreplace("|" tt "|","|" str_Type "|","|"),"|")
	GuiControl,,o_List,|%tt%
	arr_F.Delete(str_Type),tt:="已删除“" str_Type "”的定义",str_Type:=""
}Else{
	GuiControlGet,s1,,o_List
	s1=%s1%
	If (s1="")
		Return
	GuiControlGet,s2,,o_P2
	s2=%s2%
	If (s2!="") && (s2!="def") && (s2!="default") && !FileExist(s2)
	{
		MsgBox,262192,错误,指定的【特定程序】路径错误！`n可指定“def”、“Default”或留空以使用默认管理程序打开。
		GuiControl,Focus,o_P2
		SendInput ^a
		Return
	}
	GuiControlGet,s3,,o_P3
	s3=%s3%
	If (s3="") || ((s3!="TC") && !FileExist(s3))
	{
		MsgBox,262192,错误,未指定【一般程序】，或指定的程序路径错误！
		GuiControl,Focus,o_P3
		SendInput ^a
		Return
	}
	IniWrite,%s2%|%s3%,%f%,Files,%s1%
	GuiControl,,o_List,%s1%
	arr_F[s1]:=[s2,s3],tt:="已更新文件关联"
}
MsgBox,262208,操作提示,%tt%
tt=
Return

^1::Reload

GuiClose:
ExitApp