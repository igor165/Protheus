#INCLUDE "VEIVA500.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'DBTREE.CH'   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA500  บAutor  ณRicardo Farinelli   บ Data ณ  30/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณManutencao do cadastro de grupos e itens genericos que      บฑฑ
ฑฑบ          ณcompoem um veiculo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA500()

Local aCores    := {{ 'Empty(VA0_CODPAI)', 'BR_AZUL' },;	// Codigo Pai
					 	 {  '!Empty(VA0_CODPAI)'	 , 'BR_CINZA'}} // Codigo Filho
PRIVATE aRotina := MenuDef()

If AMIIn(11,14,41) // veiculos, pecas, oficina
	dbSelectArea("VA0")
	dbSetOrder(1)
	mBrowse(6,1,22,75,"VA0",,,,,,aCores)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAVA500GET บAutor  ณRicardo Farinelli   บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra a Tela para inc,alt,exc,vis.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AVA500GET(cAlias,nReg,nOpc)
Local cLinOk  := "AV500LINOK()",;
cTudoOk := "AV500TUDOK()",;
cFieldOk:= "AV500FilOK()"
Local oItensGet
Local oDlgAva
Local nOpcG  := 0
Local nOpcao := 0
Local lJaPerg := .f.
Private cTitulo	:= OemToAnsi(STR0008) //"Grupos e Itens Genericos de composi็ใo de um veํculo"
Private aButtons := {{'DEPENDENTES',{|y,x|AV500GRVCAB(nOpc,.T.)},OemToAnsi(STR0009)}} //"Gravar Registro Pai"
Private oCodigo, oDescri, oCodPai
// a variavel ccodigo eh utilizada em filtros e dbseek's em outros programas, mais para poder
// criar help de campo,esta foi compatibilizada com a cCodva500
Private cCodigo, cCodva500,cDesVa500, cCPVa500
Private nUsado := 0
Private aCpoEnc := {} , aCols := {} , aHeader := {}
Private aTELA[0][0],aGETS[0]
Private lGets := .T.
Private nOpcx := nOpc

AV500TELA(nOpc) // Inicializa campos do cabecalho
AV500AHEAD() // Cria o aHeader e aCols
nOpcG := nOpc
If nOpc==4
	nOpcG := 3
Endif
If nOpc==5 .or. nOpc==4
	lGets := .F.
Endif
If !Empty(cCPVa500) // se for um sub-item nao altera a getdados
	nOpcG := 2
Endif

If Len(aCols)>0
	
	AV500ACOLS(nOpc) // Carrega o aCols
	
	DEFINE MSDIALOG oDlgAva TITLE cTitulo From 3,0 to 32,80 of oMainWnd
	
	@ 013,001 TO 073,317 LABEL '' OF oDlgAva PIXEL
	@ 018.5,010 SAY Oemtoansi(STR0010) Of oDlgAva Pixel Size 18,9 //"C๓digo:"
	@ 018,050 MSGET oCodigo Var cCodva500 Pict PesqPict("VA0","VA0_CODIGO") ;
	When (lGets .and. nOpc==3 .and. VisualSx3("VA0_CODIGO")) Valid CheckSx3("VA0_CODIGO") .and. (cCodigo := cCodva500,.T.) Of oDlgAva Pixel Size 15,9
	@ 038.5,010 SAY Oemtoansi(STR0016) Of oDlgAva Pixel Size 25,9    //Descri็ใo:
	@ 038,050 MSGET oDescri Var cDesVa500 Pict PesqPict("VA0","VA0_DESCRI") ;
	When ((lGets .and. nOpc==3 .or. nOpc==4) .and. VisualSx3("VA0_DESCRI")) Valid CheckSx3("VA0_DESCRI") Of oDlgAva Pixel Size 180,9
	@ 058.5,010 SAY Oemtoansi(STR0017) Of oDlgAva Pixel Size 30,9   //C๓digo Pai:
	@ 058,050 MSGET oCodPai Var cCPVa500 Pict PesqPict("VA0","VA0_CODPAI") When (.F.) Of oDlgAva Pixel Size 15,9
	
	oItensGet:= MsGetDados():New(75,1,oDlgAva:nClientHeight/2,oDlgAva:nClientWidth/2,nOpcG ,cLinOk,cTudoOk,"",Iif(nOpc==5 .or. nOpc==2,.F.,.T.),,,,,cFieldOK,,,,oDlgAva)
	oItensGet:oBrowse:bGotFocus 	:={|| AV500PERG(@lJaPerg,nOpc)}
	
Endif
ACTIVATE MSDIALOG oDlgAva CENTER ON INIT (EnchoiceBar(oDlgAva,{||nOpcao:=1,If(oItensGet:TudoOk(),If(!obrigatorio(aGets,aTela),nOpcao := 0,oDlgAva:End()),nOpcao := 0)},{||oDlgAva:End()},,aButtons))

If nOpcao == 1 .and. (nOpc == 3 .or. nOpc == 4 .or. nOpc == 5)
	If AV500VLEXC("C",nOpc) .and. AV500VLEXC("I",nOpc) // Verifica se pode excluir um filho existente ou um pai ja existente
		Begin Transaction
		If !AV500GRAVA(nOpc)
			DisarmTransaction()
			Break
		Endif
		End Transaction
	Endif
Endif
VA0->(DbsetOrder(1))
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV500ACOLSบAutor  ณRicardo Farinelli   บ Data ณ  30/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a Carga dos itens da Getdados                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AV500ACOLS(nOpc)
Local ny := 0

Dbselectarea("VA0")

If nOpc<> 3
	VA0->(DbSetOrder(2))
	VA0->(Dbseek(xFilial("VA0")+cCPVa500))
	Do While !VA0->(Eof())
		If !Empty(VA0->VA0_CODPAI)
			If VA0->(VA0_FILIAL+VA0_CODPAI)<>xFilial("VA0")+cCodigo
				VA0->(Dbskip())
				Loop
			Endif
		Endif
		
		// Nao carregar a ele mesmo no acols, pois este estara na enchoice como cabecalho.
		If (VA0->(VA0_FILIAL+VA0_CODIGO+VA0_CODPAI))==(xFilial("VA0")+cCodigo+cCPVa500)
			VA0->(Dbskip())
			Loop
		Endif
		
		If Empty(VA0->VA0_CODPAI)
			VA0->(Dbskip())
			Loop
		Endif
		
		If !Empty(aCols[Len(aCols),1])
			aadd(aCols,Array(Len(aCols[1])))
		Endif
		
		For ny := 1 to Len(aHeader)
			If ( aHeader[ny][10] != "V")
				aCols[Len(aCols)][ny] := FieldGet(FieldPos(aHeader[ny][2]))
			Else
				aCols[Len(aCols)][ny] := CriaVar(aHeader[ny][2])
			EndIf
			aCols[Len(aCols)][nUsado+1] := .F.
		Next ny
		VA0->(Dbskip())
	Enddo
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV500AHEADบAutor  ณRicardo Farinelli   บ Data ณ  30/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o aHeader da Getdados                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AV500AHEAD()

Local _ni := 0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VA0")
While !EOF() .And. (x3_arquivo == "VA0")
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
		nUsado++
		AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo,x3_context } )
	Endif
	dbSkip()
End

aCols:={Array(nUsado+1)}
aCols[1,nUsado+1]:=.F.
For _ni:=1 to nUsado
	aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV500LINOKบAutor  ณRicardo Farinelli   บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a Linha da Getdados                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AV500LINOK(nx)
Local lRet			:= .T.
Local nwk       := 0
Local cVar      := ""
Local nPos      := FG_POSVAR("VA0_CODIGO","aHeader")
Local nwnk		:= 0

If nOpcX==5
	Return (.t.)
Endif

If PCount() > 0
	n := nx
Endif

If (nwk := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VA0_CODIGO"})) > 0 .and. !aCols[n,Len(aCols[n])]
	If Empty(aCols[n,nwk])
		Help(" ",1,"AV500CAB")
		Return lRet := .F.
	Endif
Endif

If (nwk := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VA0_CODPAI"})) > 0 .and. !aCols[n,Len(aCols[n])]
	If Empty(aCols[n,nwk])
		Help(" ",1,"AV500CODVA")
		Return lRet := .F.
	Endif
Endif

If ((nwk := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VA0_CODPAI"})) > 0 .and. !aCols[n,Len(aCols[n])]) .or.;
	((nwk := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VA0_CODPAI"})) > 0 .and. !aCols[n,Len(aCols[n])] .and. aCols[n,nwk]<>cCodigo)
	If Empty(aCols[n,nwk])
		Help(" ",1,"AV500CODVA")
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
ฑฑบPrograma  ณAV500FILOKบAutor  ณRicardo Farinelli   บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o campo digitado                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AV500FILOK()
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
VA0->(Dbsetorder(1))
If (nwk := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VA0_CODIGO"})) > 0 .and. Readvar()=="M->VA0_CODIGO"
	If VA0->(Dbseek(xFilial("VA0")+M->VA0_CODIGO))
		Help(" ",1,"JAGRAVADO")
		Return lRet := .F.
	Endif
	For nPos := 1 To Len(aCols)
		cVar += IIf(!aCols[nPos,Len(aCols[nPos])],aCols[nPos,nwk]+" ","")
	Next
	
	If M->VA0_CODIGO $ cVar
		Help(" ",1,"JAGRAVADO")
		Return lRet := .F.
	Endif
Endif

Return  lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV500GRAVAบAutor  ณRicardo Farinelli   บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a Gravacao dos dados no arquivo VA0                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessinarias                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AV500GRAVA(nOpc)
Local ni := 0
Local ny := 0
Local nx := 0
Local lRet := .T.
Dbselectarea("VA0")
Dbsetorder(2)

ny := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VA0_CODIGO"})
nx := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VA0_CODPAI"})

Asort(aCols,,,{|x,y| x[len(x)] > y[len(y)] })
If nOpc == 3 .or. nOpc == 4
	If AV500GRVCAB(nOpc)  
		For ni := 1 To Len(aCols)
			
			If !(aCols[ni,Len(aCols[ni])]) .and. !Empty(aCols[ni,nx]) .and. !Empty(aCols[ni,ny])
				RecLock("VA0",!Dbseek(xFilial("VA0")+aCols[ni,nx]+aCols[ni,ny]))
				VA0_FILIAL  := xFilial("VA0")
				FG_GRAVAR("VA0",aCols,aHeader,ni)
				MsUnlock()
			Else  
				If Dbseek(xFilial("VA0")+aCols[ni,nx]+aCols[ni,ny])
					Reclock("VA0",.F.)
					Dbdelete()
					Msunlock()
				Endif
			Endif
		Next
	Else
		lRet := .F.
	Endif
Elseif nOpc == 5
	If AV500GRVCAB(nOpc)
		For ni := 1 To Len(aCols)
			If Dbseek(xFilial("VA0")+aCols[ni,ny]+aCols[ni,nx])
				RecLock("VA0",.F.)
				Dbdelete()
				MsUnlock()
			Endif
		Next
	Else
		lRet := .F.
	Endif
Endif

VA0->(DbsetOrder(1))
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV500GRAVAบAutor  ณRicardo Farinelli   บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a Gravacao dos dados no arquivo VA0                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessinarias                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AV500GRVCAB(nOpc,lPai)

Default nOpc := 3
Default lPai := .F.

If lPai .and. nOpc==4
	MsgAlert(OemToAnsi(STR0011)) //"Disponivel apenas na Inclusใo"
	Return .F.
Endif
If !lGets .and. nOpc==3
	Return .T.
Endif

Dbselectarea("VA0")
DbsetOrder(2)
RecLock("VA0",!Dbseek(xFilial("VA0")+cCPVa500+cCodigo))
If nOpc <> 5
	VA0_FILIAL := xFilial("VA0")
	VA0_CODIGO := cCodigo
	VA0_CODPAI := cCPVa500
	VA0_DESCRI := cDesVa500
	MsUnlock()
	lGets := .F.
Else
	Dbdelete()
	Msunlock()
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV500TELA บAutor  ณRicardo Farinelli   บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria os Gets do cabecalho                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessinarias                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AV500TELA(nOpc)
cCodigo   := If(nOpc==3,Criavar("VA0_CODIGO",.F.),VA0->VA0_CODIGO)
cCodva500 := If(nOpc==3,Criavar("VA0_CODIGO",.F.),VA0->VA0_CODIGO)
cDesVa500 := If(nOpc==3,Criavar("VA0_DESCRI",.F.),VA0->VA0_DESCRI)
cCPVa500  := If(nOpc==3,Criavar("VA0_CODPAI",.F.),VA0->VA0_CODPAI)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPesqF3    บAutor  ณRicardo Farinelli   บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTraz o Alias da Consulta do SX3 do campo em questao         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessinarias                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
Static Function PesqF3(cCampo)
Local nOrdem := Sx3->(IndexOrd()), nRecno := Sx3->(Recno()), cRet

Sx3->(Dbsetorder(2))
Dbseek(cCampo)
cRet := Sx3->X3_F3
Sx3->(Dbsetorder(nOrdem))
Sx3->(Dbgoto(nRecno))

Return  cRet
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAVA500EST บAutor  ณRicardo Farinelli   บ Data ณ  02/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza as partes em forma de estrutura                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AVA500EST()
Local oTree
Local oDlgEst
Local cCod
VA0->(DbsetOrder(1))
Dbseek(xFilial("VA0")+Iif(!Empty(VA0->VA0_CODPAI),VA0->VA0_CODPAI,VA0->VA0_CODIGO))
cCod := Iif(!Empty(VA0->VA0_CODPAI),VA0->VA0_CODPAI,VA0->VA0_CODIGO)
DEFINE MSDIALOG oDlgEst TITLE OemToAnsi(STR0012) From 3,0 to 32,80 of oMainWnd //"Grupos Genericos"
DEFINE DBTREE oTree FROM 015,0 TO (oDlgEst:nClientHeight)/2,(oDlgEst:nClientWidth)/2 OF oDlgEst CARGO
oTree:SetColor(CLR_BLUE,CLR_WHITE)
oTree:BeginUpDate()
DBADDTREE oTree PROMPT VA0->VA0_CODIGO +" - "+VA0->VA0_DESCRI RESOURCE 'FOLDER12','FOLDER12' CARGO '*Pai'
VA0->(Dbskip())
DBENDTREE oTree
VA0->(DbsetOrder(2))
VA0->(dbseek(xFilial("VA0")+cCod))
Do While xFilial("VA0")+cCod == VA0->(VA0_FILIAL+VA0_CODPAI) .and. !VA0->(Eof())
	oTree:TreeSeek('*Pai')
	oTree:AddItem(VA0->VA0_CODIGO +" - "+VA0->VA0_DESCRI,'*Pai','FOLDER14','FOLDER14',,,2)
	VA0->(Dbskip())
Enddo
oTree:EndUpDate()
ACTIVATE MSDIALOG oDlgEst CENTER ON INIT (EnchoiceBar(oDlgEst,{||oDlgEst:End()},{||oDlgEst:End()}))
VA0->(DbsetORder(1))
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV500VLEXCบAutor  ณRicardo Farinelli   บ Data ณ  08/02/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a Exclusao dos Dados                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AV500VLEXC(cTipo,nOpc)

Local aArquivos := {}
Local ni := 0
Local ny := 0
Local nx := 0
Local lRet := .T.

If cTipo=="C" .and. nOpc == 5
	Dbselectarea("VA0")
	DbsetOrder(1)
	If Empty(cCPVa500)
		Aadd(aArquivos, {"VA2" , "VA2_GRUPO" , cCodigo , NIL } )
		Aadd(aArquivos, {"VA5" , "VA5_ITEM" , cCodigo , NIL } )
		Aadd(aArquivos, {"VAA" , "VAA_CODGRU" , cCodigo , NIL } )
		Aadd(aArquivos, {"VAB" , "VAB_CODGRU" , cCodigo , NIL } )
	Else
		Aadd(aArquivos, {"VA2" , "VA2_GRUPO" , cCPVa500 , NIL } )
		Aadd(aArquivos, {"VA5" , "VA5_ITEM" , cCPVa500 , NIL } )
		Aadd(aArquivos, {"VAA" , "VAA_CODGRU+VAA_ITEM" , cCPVa500+cCodigo , NIL } )
		Aadd(aArquivos, {"VAB" , "VAB_CODGRU+VAB_CODITE" , cCPVa500+cCodigo , NIL } )
	Endif
	If !FG_DELETA( aArquivos )
		lRet := .F.
	EndIf
Elseif cTipo=="I"  .and. nOpc == 5
	Dbselectarea("VA0")
	Dbsetorder(1)
	ny := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VA0_CODIGO"})
	nx := Ascan(aHeader,{|x| Alltrim(Upper(x[2]))=="VA0_CODPAI"})
	For ni := 1 To Len(aCols)
		If (aCols[ni,Len(aCols[ni])] .and. nOpcX==3) .or. (aCols[ni,Len(aCols[ni])] .and. nOpcX==4) .or. (nOpcX==5)
			If Dbseek(xFilial("VA0")+aCols[ni,ny]+aCols[ni,nx])
				Aadd(aArquivos, {"VA2" , "VA2_GRUPO" , aCols[ni,nx] , NIL } )
				Aadd(aArquivos, {"VA5" , "VA5_ITEM" , aCols[ni,nx] , NIL } )
				Aadd(aArquivos, {"VAA" , "VAA_CODGRU+VAA_ITEM" , aCols[ni,ny]+aCols[ni,nx] , NIL } )
				Aadd(aArquivos, {"VAB" , "VAB_CODGRU+VAB_CODITE" , aCols[ni,ny]+aCols[ni,nx] , NIL } )
				If !FG_DELETA( aArquivos )
					lRet := .F.
					Exit
				Endif
			Endif
		Endif
	Next
Endif
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV500TUDOKบAutor  ณRicardo Farinelli   บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a Tela  da Getdados                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AV500TUDOK()
Local nx   := 0
Local lRet := .T.
For nx := 1 To Len(aCols)
	If !(AV500LINOK(nx))
		Return .F.
	Endif
Next

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV500LEG  บAutor  ณRicardo Farinelli   บ Data ณ  10/19/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLegenda de explicacao das cores da mbrowse                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AV500LEG()
Local aLegenda := { {"BR_AZUL",STR0013},; //"NF de Compl. IPI" //"Codigo de Grupo"
										 {"BR_CINZA",STR0014}} //"Item de um Grupo"

BrwLegenda(STR0015,STR0007,aLegenda) //"Grupos e Itens Genericos"###"Legenda"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAV500PERG บAutor  ณValdir F. Silva     บ Data ณ  26/10/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPergunta se deseja gravar o registro pai                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AV500PERG(lJaPerg,nOpc)
If nOpc == 3 .and. !lJaPerg .and. MsgYesNo(STR0018,STR0019)					//Deseja Gravar o Registro Pai #Atencao  
	AV500GRVCAB(nOpc,.T.)
	lJaPerg := .t.
EndIf
Return .t.

Static Function MenuDef()
Local aRotina := {{ OemToAnsi(STR0001),"AxPesqui"  , 0 , 1},; 			//"Pesquisar"
									{ OemToAnsi(STR0002),"AVA500GET" , 0 , 2},; 			//"Visualizar"
									{ OemToAnsi(STR0003),"AVA500GET" , 0 , 3},; 			//"Incluir"
									{ OemToAnsi(STR0004),"AVA500GET" , 0 , 4},; 			//"Alterar"
						   		{ OemToAnsi(STR0005),"AVA500GET" , 5 , 1},; 			//"Excluir"
									{ OemToAnsi(STR0006),"AVA500EST" , 0 , 2},; 			//"Ver Grupo"
									{ OemToAnsi(STR0007),"AV500LEG"  , 0 , 2,0,.f.} } //"Legenda"
Return aRotina
