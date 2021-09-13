#SingleInstance Ignore
#NotrayIcon

f_File:=A_Args[1]
If (f_File=""){
	Gui,+OwnDialogs
	MsgBox,262208,%A_ThisMenuItem%,
(
F4Cmd For Total Commander
版本: 0.0.5（2020/06/11）
`nTotal Commander F4 键增强。
TC 主菜单：配置 -> 选项 -> 编辑/查看 -> “按 F4 调用的编辑器”中设置本程序/脚本的路径即可。
`nEasysky Studio, 2013-%A_yyyy%
)
	ExitApp
}

Global _iniF:=A_ScriptDir . "\F4Cmd.ini"
If !FileExist(_iniF)
{
	FileAppend,`; 请参照以下格式自定义打开方式`n`; 节名（Section）为定义的文件类型，多种文件类型以半角逗号分隔`n`; 参数（Key=Value）定义每种打开方式，每行定义一个，其中：`n`; %a_Tab%键（key）为打开程序名称，也即弹出菜单的名称`n`; %a_Tab%值（Value）为打开程序路径，支持参数`n`; 示例如下：`n`; ####################`n`; [rar`,zip`,7z]`n`; WinRAR压缩管理器=c:\Program Files\WinRAR\WinRAR.exe`n`; 记事本=C:\Windows\notepad.exe [参数]`n`; ####################`n`; 内置全局参数开关：`n`; %a_Tab%[General]`n`; %a_Tab%DirectOpen：如果只有一种自定义打开方式，则不弹出菜单直接打开`n`; %a_Tab%OpenWithTC：已指定打开方式时，添加 [# TotalCMD 默认] 菜单（即使用 TC 默认文件关联；未指定打开方式时，无条件显示该菜单项）`n`; %a_Tab%QuickEdit：添加 [配置 ...] 菜单用于编辑本配置文件`n`; %a_Tab%OpenAsText：当未指定打开方式时，添加 [# 作为文本打开] 菜单，默认以指定文本编辑器打开文件。值=0时，禁用此功能`n`n[General]`nDirectOpen=0`nOpenWithTC=1`nQuickEdit=1`nOpenAsText=notepad.exe`n`n,%_iniF%,UTF-16
	_Edit_Conf()
	ExitApp
}
arr_A:=[],nCount:=0,c_Note:="notepad.exe",c_TC:="# TotalCMD 默认",c_Text:="# 作为文本打开",c_Conf:="配置 ..."
SplitPath,f_File,,,f_Ext
IniRead,b_Text,%_iniF%,General,OpenAsText,0
If (b_Text=1)
	b_Text:=c_Note
Else If (b_Text<>0) And (b_Text<>c_Note) And !FileExist(b_Text)
	b_Text:=0
IniRead,tempStr,%_iniF%
tempStr:=Trim(tempStr)
If (tempStr="") Or (tempStr="General"){	;ini配置文件中没有指定任何文件类型
	Gosub Add_OtherMenu
}Else{
	str_Sec=
	Loop,Parse,tempStr,`n
	{
		If (A_LoopField="") Or (A_LoopField="General")
			Continue
		If InStr("," A_LoopField ",","," f_Ext ",")
		{
			str_Sec:=A_LoopField
			Break
		}
	}
	If (str_Sec<>""){	;当前文件类型已指定
		IniRead,tempStr,%_iniF%,%str_Sec%
		tempStr:=Trim(tempStr),nCount:=0
		Loop,Parse,tempStr,`n
		{
			If (A_LoopField="")
				Continue
			getStr1:=getStr2:=""
			Loop,Parse,A_LoopField,=
				getStr%A_Index%:=Trim(A_LoopField)
			arr_A[getStr1]:=getStr2,nCount+=1
			Menu,Menu_Main,Add,%getStr1%,cmd_Main
		}
		If (nCount=0)	;当前文件类型已指定，但没指定打开方式
			Gosub Add_OtherMenu
		If (nCount=1){
			IniRead,b_DirO,%_iniF%,General,DirectOpen,0
			If b_DirO Not In 0,1
				b_DirO:=0
			If b_DirO
			{
				_Open_File(getStr1)
				ExitApp
			}
		}
	}Else
		Gosub Add_OtherMenu
}
If (nCount>0){
	IniRead,b_OTC,%_iniF%,General,OpenWithTC,0
	If b_OTC Not In 0,1
		b_OTC:=0
	If b_OTC
	{
		Menu,Menu_Main,Add
		Menu,Menu_Main,Add,%c_TC%,cmd_Main
	}
}
IniRead,b_QE,%_iniF%,General,QuickEdit,0
If b_QE Not In 0,1
	b_QE:=0
If b_QE
{
	Menu,Menu_Main,Add
	Menu,Menu_Main,Add,%c_Conf%,cmd_Main	;Configuration
}
arr_Color:=["F1FAFA","E8FFE8","E8E8FF","F2F1D7","FBFBEA","D5F3F4","D7FFF0","F0DAD2","DDF3FF","CCFFFF","Default","99CCFF","DAAB99","C7EDCC"]
Random,tempStr,1,14
Menu,Menu_Main,Color,% arr_Color[tempStr]
Menu,Menu_Main,Show
ExitApp
Return

cmd_Main:
If (A_ThisMenuItem=c_Conf)
{
	_Edit_Conf()
	Return
}
If (A_ThisMenuItem=c_TC){
	SendInput {Enter}
	Return
}
If (A_ThisMenuItem=c_Text){
	Try Run, % b_Text A_Space """" f_File """"
	Catch
		Run,% c_Note """" f_File """"
	Return
}
_Open_File(A_ThisMenuItem)
Return

Add_OtherMenu:
Menu,Menu_Main,Add,%c_TC%,cmd_Main
If (b_Text<>0)
	Menu,Menu_Main,Add,%c_Text%,cmd_Main
Return

_Open_File(str){
	Global arr_A,f_File
	Try Run,% arr_A[str] A_Space """" f_File """"
	Catch {
		Gui,+OwnDialogs
		MsgBox,262192,F4Cmd,打开文件错误，请检查配置文件！
	}
}

_Edit_Conf(){
	Try Run, Edit%_iniF%
	Catch
		Run,notepad.exe%A_Space%%_iniF%
}