#INCLUDE "VEIVA520.ch"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA520  บAutor  ณRicardo Farinelli   บ Data ณ  03/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTabela de Precos de veiculos (avaliacao) e valores dos      บฑฑ
ฑฑบ          ณgrupos que compoem o veiculo (avaliacao)                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA520()

PRIVATE aRotina 	:= MenuDef()

If AMIIn(11,14,41) // veiculos, pecas, oficina
	dbSelectArea("VA1")
	dbSetOrder(1)
	mBrowse(6,1,22,75,"VA1")
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAVA520GET บAutor  ณRicardo Farinelli   บ Data ณ  03/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra a Tela para inc,alt,exc,vis.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AVA520GET(cAlias,nReg,nOpc)
Local cLinOk  := "AV520LINOK()",;
      cTudoOk := "AV520TUDOK()",;
      cFieldOk:= "AV520FilOK()"
Local oDlgPre
Local oEncGru 
Local oGetPre
Local nOpcG  := 0
Local nOpcE  := 0
Local nOpcao := 0
Local aAltEnc:= {}
Private cTitulo	:= OemToAnsi(STR0006) //"Tabela de Pre็o de Veํculos (Avalia็ใo)"
Private cMarVeiF3 := "" // utilizado no campo va1_marca e consulta no sxb -> MCF 
Private nUsado := 0
Private aCols := {} , aHeader := {}
Private aTELA[0][0],aGETS[0]
Private nOpcX := nOpc
RegToMemory("VA1",nOpc==3)
nUsado:=0

AV520AHEAD() // Cria aHeader
AV520ACOLS(nOpc) // Cria aCOls e Carrega seu Conteudo

nOpcG := Iif(nOpc==4,3,nOpc)
nOpcE := Iif(nOpc==4,3,nOpc)

If Len(aCols)>0
	
	DEFINE MSDIALOG oDlgPre TITLE cTitulo From 9,0 TO 28,80 of oMainWnd
	
   oEncGru:= MsMget():New("VA1",nReg,nOpcE,,,,,{15,1,oDlgPre:nClientHeight/4,oDlgPre:nClientWidth/2},,3,,,,,,.T.)
 	oGetPre:= MsGetDados():New(75,1,oDlgPre:nClientHeight/2,oDlgPre:nClientWidth/2,nOpcG ,cLinOk,cTudoOk,"",Iif(nOpc==5 .or. nOpc==2,.F.,.T.),,,,,cFieldOK,,,,oDlgPre)
	
   ACTIVATE MSDIALOG oDlgPre CENTER ON INIT (EnchoiceBar(oDlgPre,{||nOpcao:=1,If(oGetPre:TudoOk(),If(!obrigatorio(aGets,aTela),nOpcao := 0,oDlgPre:End()),nOpcao := 0)},{||oDlgPre:End()}))

Endif

If nOpcao == 1 .and. nOpc == 5
	If AV520VLEXC("C") .and. AV520VLEXC("I") // Verifica se pode excluir algum dos dados
		Begin Transaction
		If !AV520GRAVA(nOpc)
			DisarmTransaction()
			Break
		Endif
		End Transaction
	Endif
Elseif nOpcao == 1 .and. (nOpc == 3 .or. nOpc == 4)
	Begin Transaction
	If !AV520GRAVA(nOpc)
		DisarmTransaction()
		Break
	Endif
	End Transaction
	If __lSX8
		ConfirmSX8()
	EndIf
Else
	If __lSX8
		RollbackSX8()
	EndIf
Endif
VA1->(DbsetOrder(1))
VA2->(DbSetOrder(1))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV520AHEADบAutor  ณRicardo Farinelli   บ Data ณ  03/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o aHeader da Getdados                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGestao de Concessionarias                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AV520AHEAD()

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VA2")
While !EOF() .And. (x3_arquivo == "VA2")
   If Alltrim(x3_CAMPO)$"VA2_MARCA,VA2_MODVEI,VA2_ANOMOD"
     DBSKIP()
     LOOP
   Endif
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
		nUsado++
		AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo,x3_context } )
	Endif
	dbSkip()
End

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV520ACOLSบAutor  ณRicardo Farinelli   บ Data ณ  03/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria aCols e faz a carga dos dados                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AV520ACOLS(nOpc)
Local ny := 0

Dbselectarea("VA2")

If nOpc == 3
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For ny:=1 to nUsado
		aCols[1,ny]:=CriaVar(aHeader[ny,2])
	Next
Else
	aCols:={}
	dbSelectArea("VA2")
	dbSetOrder(1)
	dbSeek(xFilial("VA2")+M->VA1_MARCA+M->VA1_MODVEI+M->VA1_ANOMOD)
	Do While VA2->(VA2_FILIAL+VA2_MARCA+VA2_MODVEI+VA2_ANOMOD)== xFilial("VA2")+M->VA1_MARCA+M->VA1_MODVEI+M->VA1_ANOMOD .and. !VA2->(eof())
		AADD(aCols,Array(nUsado+1))
		For ny:=1 to nUsado
			If ( aHeader[ny][10] != "V")
				aCols[Len(aCols)][ny] := FieldGet(FieldPos(aHeader[ny][2]))
			Else
				aCols[Len(aCols)][ny] := CriaVar(aHeader[ny][2])
			EndIf
			aCols[Len(aCols)][nUsado+1] := .F.
		Next 
		VA2->(dbSkip())
	Enddo
Endif
If Len(aCols)==0
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For ny:=1 to nUsado
		aCols[1,ny]:=CriaVar(aHeader[ny,2])
	Next
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV520VLEXCบAutor  ณRicardo Farinelli   บ Data ณ  03/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a Exclusao dos Dados                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AV520VLEXC(cTipo)

Local aArquivos := {}
Local lRet := .T.

If cTipo=="C"
   Aadd(aArquivos, {"VA7" , "VA7_MARCA+VA7_MODVEI+VA7_ANOMOD+VA7_COMBUS" ,M->VA1_MARCA+M->VA1_MODVEI+M->VA1_ANOMOD+M->VA1_COMBUS  , NIL } )
	If !FG_DELETA( aArquivos )
		lRet := .F.
	Endif
Endif
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV520GRAVAบAutor  ณRicardo Farinelli   บ Data ณ  03/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a Gravacao dos dados no arquivo VA1 e VA2            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessinarias                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AV520GRAVA(nOpc)
Local ni := 0
Local ny := 0
Local lRet := .T.
Local lAchou 
ny := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VA2_GRUPO"})

If nOpc == 3 .or. nOpc == 4
	If AV520GRVCAB(nOpc)
    Dbselectarea("VA2")
		Dbsetorder(1)
	  Asort(aCols,,,{|x,y| x[len(aCols)] > y[len(aCols)] })
		For ni := 1 To Len(aCols)
			If !(aCols[ni,Len(aCols[ni])]) .and. !Empty(aCols[ni,ny])
				lAchou := !(VA2->(Dbseek(xFilial("VA2")+M->VA1_MARCA+M->VA1_MODVEI+M->VA1_ANOMOD+aCols[ni,ny])))
				RecLock("VA2",lAchou)  
				FG_GRAVAR("VA2",aCols,aHeader,ni)
				VA2_FILIAL  := xFilial("VA2")
  				VA2_MARCA   := M->VA1_MARCA
  				VA2_MODVEI  := M->VA1_MODVEI
  				VA2_ANOMOD  := M->VA1_ANOMOD
				MsUnlock()
			Else
				If Dbseek(xFilial("VA2")+M->VA1_MARCA+M->VA1_MODVEI+M->VA1_ANOMOD+aCols[ni,ny])
					Reclock("VA2",.F.)
					Dbdelete()
					Msunlock()
				Endif
			Endif
		Next
	Else
		lRet := .F.
	Endif
Elseif nOpc == 5
	If AV520GRVCAB(nOpc)
		For ni := 1 To Len(aCols)
			If Dbseek(xFilial("VA2")+M->VA1_MARCA+M->VA1_MODVEI+M->VA1_ANOMOD+aCols[ni,ny])
				RecLock("VA2",.F.)
				Dbdelete()
				MsUnlock()
			Endif
		Next
	Else
		lRet := .F.
	Endif
Endif
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV520GRVCAบAutor  ณRicardo Farinelli   บ Data ณ  03/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a Gravacao dos dados no arquivo VA1                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessinarias                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AV520GRVCAB(nOpc)
Local ny     := 0
Local bCampo := { |nCPO| FieldName(nCPO) }

Dbselectarea("VA1")
DbsetOrder(1)
RecLock("VA1",!Dbseek(xFilial("VA1")+M->VA1_MARCA+M->VA1_MODVEI+M->VA1_ANOMOD+M->VA1_COMBUS))
If nOpc <> 5
	For ny := 1 TO FCount()
		If "_FILIAL"$Field(ny)
			FieldPut(ny,cFilial)
		Else
			FieldPut(ny,M->&(EVAL(bCampo,ny)))
		EndIf
	Next 
	MsUnlock()
Else
	Dbdelete()
	Msunlock()
Endif

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV520LINOKบAutor  ณRicardo Farinelli   บ Data ณ  03/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a Linha da Getdados                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AV520LINOK(nx)
Local lRet			:= .T.
Local nwk       := 0
Local nwnk      := 0
Local cVar      := ""
Local nPos := FG_POSVAR("VA2_GRUPO","aHeader")

If nOpcX==5
	Return (.t.)
Endif

If PCount() > 0
	n := nx
Endif

If (nwk := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VA2_GRUPO"})) > 0 .and. !aCols[n,Len(aCols[n])]
	If Empty(aCols[n,nwk])
		Help(" ",1,"AV520GRU")
		Return lRet := .F.
	Endif
Endif

If (nwk := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VA2_VLRGRU"})) > 0 .and. !aCols[n,Len(aCols[n])]
	If Empty(aCols[n,nwk])
		Help(" ",1,"AV520VGRU")
		Return lRet := .F.
	Endif
Endif

For nwnk := 1 To Len(aCols)
	If aCols[nwnk,nPos]==aCols[n,nPos] .and. nwnk<>n .and. ;
		!aCols[n,Len(aCols[n])] .and. !aCols[nwnk,Len(aCols[nwnk])]
		 Help(" ",1,"EXISTCHAV")
		 Return lRet := .F.
	Endif	 
Next

Return  lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV520FILOKบAutor  ณRicardo Farinelli   บ Data ณ  03/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o campo digitado                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AV520FILOK()
Local lRet			:= .T.
Local nwk       := 0
Local cVar      := ""
Local nPos      := 0

If nOpcX==5
	Return (.t.)
Endif

If aCols[n,Len(aCols[n])]
	Return lRet := .T.
Endif

VA2->(Dbsetorder(1))
If (nwk := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VA2_GRUPO"})) > 0 .and. Readvar()=="M->VA2_GRUPO"
	If VA2->(Dbseek(xFilial("VA2")+M->VA1_MARCA+M->VA1_MODVEI+M->VA1_ANOMOD+aCols[n,nwk]))
		Help(" ",1,"JAGRAVADO")
		Return lRet := .F.
	Endif
	For nPos := 1 To Len(aCols)
		cVar += IIf(!aCols[nPos,Len(aCols[nPos])],aCols[nPos,nwk]+" ","")
	Next
	
	If M->VA2_GRUPO $ cVar
		Help(" ",1,"JAGRAVADO")
		Return lRet := .F.
	Endif
Endif

Return  lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV520TUDOKบAutor  ณRicardo Farinelli   บ Data ณ  03/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a Tela  da Getdados                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AV520TUDOK()
Local nx   := 0
Local lRet := .T.
For nx := 1 To Len(aCols)
	If !(AV520LINOK(nx))
		Return .F.
	Endif
Next

Return lRet

Static Function MenuDef()
Local aRotina := {{ OemToAnsi(STR0001),"AxPesqui"    , 0 , 1},; //"Pesquisar"
					 	{ OemToAnsi(STR0002),"AVA520GET" , 0 , 2},; //"Visualizar"
 						{ OemToAnsi(STR0003),"AVA520GET"    , 0 , 3},;	 //"Incluir"
 						{ OemToAnsi(STR0004),"AVA520GET"    , 0 , 4},;	 //"Alterar"
						{ OemToAnsi(STR0005),"AVA520GET"    , 5,  1}} //"Excluir"
Return aRotina
