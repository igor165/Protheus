#Include "VEIVR140.CH"
#Include "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVR140 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 29/09/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Estatistica de Registro de Visitantes/Midias               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VEIVR140()

Private aReturn:= {STR0002,1,STR0003,2,2,1, ,1}  
Private cAlias  := "VV9"
Private cNomRel := "VEIVR140"
Private cPerg   := "VVR140"
Private cTitulo := STR0001
Private cDesc1  := STR0001
Private cDesc2  := ""
Private cDesc3  := ""
Private cTamanho:= "P"
Private cLimite := 80 
Private m_Pag   := 1
Private nCaracter:=15
// MV_PAR01 - D 8 G - Data Inicial
// MV_PAR02 - D 8 G - Data Final
// MV_PAR03 - N 1 C - Tipo de Relatorio (Resumido/Sintetico/Analitico)
cNomRel := SetPrint(cAlias,cNomRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,,cTamanho)
If nlastkey == 27
   Return
EndIf
PERGUNTE(cPerg,.F.)
RptStatus({|lEnd| FS_VEIVR140()},cTitulo)

Return

Static Function FS_VEIVR140()
Local nLin   := 0
Local cabec1 := ""
Local cabec2 := ""
Local aVisit := {}
Local cBox   := ""
Local	ni     := 0
Local nj     := 0
Local cDescri:= ""

Set Console On
Set Printer to &cNomRel
Set Printer On
Set device to Printer
SetDefault(aReturn,cAlias)
          
cabec1 := STR0004
If MV_PAR03 == 2
	cabec2 := STR0005
ElseIf MV_PAR03 == 3
	cabec1 := STR0005
	cabec2 := STR0006
EndIf

Aadd(aVisit,{" 1",STR0007+" ( "+Transform(MV_PAR01,"@D")+STR0008+Transform(MV_PAR02,"@D")+" )",0,dDataBase,""})
DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("VV9_TIPMID")
cBox := X3CBOX()
While len(cBox) > 1
	nTam := If(at(";",cBox)==0,len(cBox)+1,at(";",cBox))
	aAdd(aVisit,{substr(cBox,1,1)+"1",substr(cBox,3,nTam-3),0,dDataBase,""})
	cBox := Alltrim(substr(cBox,nTam+1,len(cBox)))
EndDo

DbSelectArea("VV9")
DbSetOrder(3)
DbSeek( xFilial("VV9") + DTOS(MV_PAR01) , .t. )
SetRegua((RecCount()/50))
While !Eof() .and. xFilial("VV9")==VV9->VV9_FILIAL .and. VV9->VV9_DATVIS <= MV_PAR02
	nj++
	If nj == 50
		nj := 0
		IncRegua()
	EndIf
   If !Empty(VV9->VV9_TIPMID)
		aVisit[1,3]++
		ni := 0
		ni := aScan(aVisit,{|x| x[1] == Alltrim(VV9->VV9_TIPMID)+"1" })
		If ni > 0
			aVisit[ni,3]++
		EndIf
		If MV_PAR03 >= 2
			If MV_PAR03 == 3
				cDescri := VV9->VV9_NUMATE+"  "
				If !Empty(VV9->VV9_DATCAN)
					cDescri += "->  "+STR0009+Transform(VV9->VV9_DATCAN,"@D")
				Else
					DbSelectArea("VV0")
					DbSetOrder(1)
					If DbSeek( xFilial("VV0") + VV9->VV9_NUMATE )
						cDescri += VV0->VV0_CODMAR+" "+VV0->VV0_MODVEI
					EndIf
				EndIf
			EndIf
			aAdd(aVisit,{Alltrim(VV9->VV9_TIPMID)+"2",left(If(!Empty(VV9->VV9_CODCLI),VV9->VV9_CODCLI+"-"+VV9->VV9_LOJA+" ","")+VV9->VV9_NOMVIS+space(31),31)+" "+VV9->VV9_TELVIS+" "+VV9->VV9_MOTVIS,1,VV9->VV9_DATVIS,cDescri})
		EndIf
	EndIf
	DbSelectArea("VV9")
	DbSkip()
EndDo
aSort(aVisit,1,,{|x,y| x[1]+DTOS(x[4])+left(x[2],10) < y[1]+DTOS(y[4])+left(y[2],10) })
nLin := cabec(cTitulo,cabec1,cabec2,cNomRel,cTamanho,nCaracter) + 1
For ni := 1 to len(aVisit)
	If nLin >= 60
		nLin := 1
		nLin := cabec(cTitulo,cabec1,cabec2,cNomRel,cTamanho,nCaracter) + 1
	EndIf
	If substr(aVisit[ni,1],2,1) == "1"
	   If left(aVisit[ni,1],1) == " "
			@ nLin++, 000 pSay repl("-",80)
		Else
			nLin++
		EndIf
		@ nLin++, 000 pSay left(If(left(aVisit[ni,1],1)#" ",left(aVisit[ni,1],1)+" - ","")+aVisit[ni,2]+space(66),66)+Transform(aVisit[ni,3],"@E 9999999")+Transform(((aVisit[ni,3]/aVisit[1,3])*100),"@E 9999.9")+"%"
	   If left(aVisit[ni,1],1) == " "
			@ nLin++, 000 pSay repl("-",80)
		EndIf
	Else
	   @ nLin++, 03 pSay Transform(aVisit[ni,4],"@D")+" "+left(aVisit[ni,2]+space(68),68)
		If MV_PAR03 == 3
		   @ nLin++, 006 pSay left(aVisit[ni,5]+space(74),74)
		EndIf
	EndIf
Next

Eject        
Set Printer to
Set device to Screen 
IF aReturn[5] == 1 
   ourspool(cNomRel)
Endif
MS_FLUSH()

Return
