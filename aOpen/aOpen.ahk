;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;~ 文 件：	aOpen.ahk —— 使用不同程序打开文件
;~ 作 者:	Cui @ easysky@foxmail.com
;~ 版 本：	v0.0.2 （2021年9月9日）
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#NoTrayIcon

sPath:=a_Args[1]
If (sPath="")
{
	Gui,+OwnDialogs
	MsgBox,262208,关于 aOpen,
(
aOpen
版本: 0.0.2（2021/09/09）
`n本程序用于在特定的目录下使用不同的程序打开文件。
特别适用于垃圾公司打开/保存文件自动加密的场合。
将本程序设置为指定文件类型的关联程序即可。
尽量使用附带设置脚本“aOpen-Set”进行设置。
`nCui @2013-%A_yyyy%
)
	ExitApp
}

f:=A_ScriptDir . "\" . SubStr(A_ScriptName,1,-3) . "ini",err:=0
If !FileExist(f)
	err:=1	;没找到配置文件
If (err=0){
	IniRead,m,%f%,General,Dir,%A_Space%
	m=%m%
	If (m="")
		err:=2	;没有指定特殊目录
}
If (err=0){
	IniRead,s,%f%,Files
	s:=Trim(s,"`t`r `n")
	If (s="")
		err:=3	;未指定打开方式
}
If (err=0){
	IniRead,sTC,%f%,General,TC,%A_Space%
	sTC=%sTC%
}

If (err=0){
	;分析待打开文件的目录dir和类型ext，并指定目录标识b
	If sPath Contains %m%
		b:=1
	Else
		b:=2
	SplitPath,sPath,,,ext
	;读取配置文件，分析指定文件类型所存定义
	j:=0
	Loop,Parse,s,`n,`r
	{
		r:=Trim(A_LoopField),t1:=t2:=""
		If !RegexMatch(r,"(.+?)=(.+)",t)
			Continue
		If InStr(t1,ext)
		{
			j:=1
			Break
		}
	}

	If j	;已找到类型定义，开始分析
	{
		r1:=r2:=""
		Loop,Parse,t2,|
			r%A_Index%:=Trim(A_LoopField)

		;配置中已定义类型的文件打开
		e:=r%b%

		If (e="TC"){
			If (sTC="") || !FileExist(sTC)
			{
				MsgBox,262196,指定 Total Commander,当前文件定义为调用 TC Lister 插件进行查看，但尚未指定 TC 程序！`n是否指定？
				IfMsgBox,Yes
				{
					FileSelectFile,sTC,,,指定 Total Commander 程序,可执行程序(*.exe)
					sTC=%sTC%
					If ErrorLevel || (sTC="") || !FileExist(sTC)
					{
						MsgBox,262192,Error,Total Commander 路径错误！
						ExitApp
					}Else{
						_RunApp(sTC A_Space "/s=L" A_Space """" sPath """")
						IniWrite,%sTC%,%f%,General,TC
					}
				}
			}Else
				_RunApp(sTC A_Space "/s=L" A_Space """" sPath """")
		}Else
			_RunApp(((e="") || (e="def") || (e="default"))?sPath:(e A_Space """" sPath """"))
	}Else	;如配置中未定义此类型，则使用默认关联打开
		_RunApp(sPath)
}Else{
	Gui,+OwnDialogs
	If err In 1,3
	{
		If FileExist(A_ScriptDir "\aOpen-Set.ahk")
			_RunApp(A_ScriptDir "\aOpen-Set.ahk")
		Else{
			If (err=1)
				FileAppend,`;参考格式：`n`;[Files]（区段名）`n`;[类型名1`, 类型名2`, ……`, 类型名n]=[指定目录内的执行程序|其他目录内的执行程序]`n`;特殊执行程序：“TC”表示用 Total Commander 内部查看器打开（必须指定 TC 路径），“Def”或留空表示使用默认关联程序打开`n[Files]`n,%f%
			MsgBox,262192,Error,% ((err=1)?"未找到配置文件":"未定义文件打开方式") . "！`n随后将打开配置文件，请在 [Files] 区段中按格式添加文件关联定义，`n每行定义一个。"
			_RunApp(f)
		}
	}Else{
		MsgBox,262192,Error,请设置指定目录！
		InputBox,m,设置指定目录，以逗号分隔,,,,100
		m=%m%
		If ErrorLevel || (m="")
			ExitApp
		IniWrite,%m%,%f%,General,Dir
	}
}
ExitApp
Return

_RunApp(s){
	Try
		Run,%s%
	Catch{
		Gui,+OwnDialogs
		MsgBox,262192,Error,打开文件错误！
	}
}