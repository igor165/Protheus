// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 16    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEIXC007.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXC007 ³ Autor ³ Thiago Aprile         ³ Data ³25/08/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Relatorio de parcelas pendentes                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXC007()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}//
Local aSizeAut := MsAdvSize(.F.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0 //
Local nTam :=0 //controla posicao da legenda na tela

Local aTitulos := {STR0001,STR0002}
Local aReceb   := IIf(SE1->(FieldPos("E1_DFISICO"))>0,{STR0003,STR0004},{STR0003})
Local aPeriodo := {STR0005,STR0006,STR0007}
Local aLisPar  := {STR0008,STR0009}
Local aOrdem   := {STR0010,STR0011,STR0012}
Local cAliasSE1a  := "SQLSE1"
Private cOrdem := STR0010
Private cTpPagto := space(50)
Private cFiliais := (xFilial("SD2")+"/")
Private cTitulos := STR0001
Private cReceb   := STR0003
Private cNroProp := space(10)
Private cPeriodo := STR0005
Private cLisPar  := STR0008
Private dDtInicial := ctod("  /  /  ")
Private cTipFat := ""
Private dDtFinal   := ctod("  /  /  ")
Private aTit := {{"","",ctod("  /  /  "),"","","","","","",ctod("  /  /  "),0,"",0}}
Private nValor := 0
Private nQtd := 0

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 000, 045 , .T. , .F. } )//cabecalho
AAdd( aObjects, { 000, 000 , .T. , .T. } )//listbox
//AAdd( aObjects, { 000, 022 , .T. , .F. } )//rodape
//AAdd( aObjects, { 1, 10, .T. , .T. } )
//AAdd( aObjects, { 10, 10, .T. , .F. } )
//tamanho para resolucao 1024*768
/*aSizeAut[1]:= 0
aSizeAut[2]:= 0  //se usa toolbar = 12 se nao 0
aSizeAut[3]:= 508
aSizeAut[4]:= 279
aSizeAut[5]:= 1016
aSizeAut[6]:= 572
aSizeAut[7]:= 17 */

If SE1->(FieldPos("E1_DFISICO")) > 0
	cQuery := "SELECT SE1.E1_BAIXA,SE1.R_E_C_N_O_ RECNO "
	cQuery += "FROM "+RetSqlName("SE1")+" SE1 WHERE "
	cQuery += "SE1.E1_FILIAL='"+xFilial("SE1")+"' AND SE1.E1_DFISICO = '        ' AND SE1.E1_SALDO = 0 AND "
	cQuery += "SE1.D_E_L_E_T_=' ' ORDER BY SE1.E1_NUM "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSE1a, .T., .T. )
	Do While !( cAliasSE1a )->( Eof() )
		SE1->(dbGoTo( (cAliasSE1a)->RECNO ))
		RecLock("SE1",.F.)
		SE1->E1_DFISICO := stod((cAliasSE1a)->E1_BAIXA)
		MsUnlock()
		(cAliasSE1a)->(dbSkip())
	End
	(cAliasSE1a)->(DbCloseArea())
EndIf

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlg FROM aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] TITLE STR0013 OF oMainWnd PIXEL

nTam := ( aPos[1,4] / 5 ) //varaivel que armazena o resutlado da divisao da tela.

@  aPos[1,1]+000,aPos[1,2] TO aPos[1,3]+000,aPos[1,2]+(nTam*3) LABEL STR0014 OF oDlg PIXEL

@ aPos[1,1]+010,aPos[1,2]+(nTam*0)+005 SAY STR0015 SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE
@ aPos[1,1]+009,aPos[1,2]+(nTam*0)+040 MSCOMBOBOX oPeriodo VAR cPeriodo SIZE 55,08 COLOR CLR_BLACK ITEMS aPeriodo OF oDlg PIXEL
@ aPos[1,1]+010,aPos[1,2]+(nTam*1)+005 SAY STR0016  SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE
@ aPos[1,1]+009,aPos[1,2]+(nTam*1)+040 MSGET oDtInicial  VAR dDtInicial  PICTURE "@D" SIZE 55,08 OF oDlg PIXEL
@ aPos[1,1]+010,aPos[1,2]+(nTam*2)+005 SAY STR0017  SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE
@ aPos[1,1]+009,aPos[1,2]+(nTam*2)+040 MSGET oDtFinal  VAR dDtFinal  PICTURE "@D" SIZE 55,08 OF oDlg PIXEL

@ aPos[1,1]+021,aPos[1,2]+(nTam*0)+005 SAY STR0018  SIZE 70,08 OF oDlg PIXEL COLOR CLR_BLUE
@ aPos[1,1]+020,aPos[1,2]+(nTam*0)+040 MSCOMBOBOX oTitulos VAR cTitulos SIZE 55,08 COLOR CLR_BLACK ITEMS aTitulos OF oDlg PIXEL
IF SE1->(FieldPos("E1_DFISICO")) > 0
	@ aPos[1,1]+020,aPos[1,2]+(nTam*1)+005 MSCOMBOBOX oReceb VAR cReceb SIZE 90,08  COLOR CLR_BLACK ITEMS aReceb OF oDlg PIXEL
Endif
@ aPos[1,1]+021,aPos[1,2]+(nTam*2)+005 SAY STR0019 SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE
@ aPos[1,1]+020,aPos[1,2]+(nTam*2)+040 MSCOMBOBOX oLisPar VAR cLisPar SIZE 55,08 COLOR CLR_BLACK ITEMS aLisPar OF oDlg PIXEL

@ aPos[1,1]+033,aPos[1,2]+(nTam*2)+040 BUTTON oPesquisar PROMPT STR0022 OF oDlg SIZE 55,10 PIXEL  ACTION Processa( {|| FS_PESQUISAR(1) } )

@ aPos[1,1]+033,aPos[1,2]+(nTam*0)+005 SAY STR0020 SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE
@ aPos[1,1]+032,aPos[1,2]+(nTam*0)+040 MSGET oTpPagto VAR cTpPagto PICTURE "@!" SIZE 45,08 OF oDlg PIXEL WHEN .f.
@ aPos[1,1]+032,aPos[1,2]+(nTam*0)+085 BUTTON oF3TpPagto PROMPT "..." OF oDlg SIZE 10,10 PIXEL ACTION (FS_TIPPAG(),oPesquisar:SetFocus())

@ aPos[1,1]+033,aPos[1,2]+(nTam*1)+005 SAY STR0021 SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE
@ aPos[1,1]+032,aPos[1,2]+(nTam*1)+040 MSGET oFiliais VAR cFiliais PICTURE "@!" SIZE 45,08 OF oDlg PIXEL WHEN .f.
@ aPos[1,1]+032,aPos[1,2]+(nTam*1)+085 BUTTON oF3Filiais PROMPT "..." OF oDlg SIZE 10,10 PIXEL ACTION (FS_EMPRESAS(),oPesquisar:SetFocus())

@ aPos[1,1]+022,aPos[1,2]+(nTam*4)+002 TO aPos[1,3],aPos[1,2]+(nTam*4)+(2*(nTam/5))+002 LABEL STR0023 OF oDlg PIXEL
@ aPos[1,1]+022,aPos[1,2]+((nTam*4)+(2*(nTam/5)))+002 TO aPos[1,3],aPos[1,2]+(nTam*4)+(5*(nTam/5)) LABEL STR0024 OF oDlg PIXEL
@ aPos[1,1]+032,aPos[1,2]+(nTam*4)+((2*(nTam/5))-35)/2+002 MSGET oQtd   VAR nQtd   PICTURE "@E 9999999" SIZE 35,08 OF oDlg PIXEL WHEN .f.
@ aPos[1,1]+032,aPos[1,2]+(nTam*4)+(2*(nTam/5))+((3*(nTam/5))-53)/2+001 MSGET oValor VAR nValor PICTURE "@E 999,999,999.99" SIZE 53,08 OF oDlg PIXEL WHEN .f.

@ aPos[2,1]+002,aPos[2,2]+001 LISTBOX oLbx1 FIELDS HEADER  STR0025,STR0012,STR0026,STR0027,STR0028,STR0029,STR0030,STR0031,STR0032,STR0033,STR0034,STR0035,STR0036 COLSIZES 90,40,30,20,30,45,60,40,20,60,30,40,40 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1]-2 OF oDlg PIXEL
oLbx1:SetArray(aTit)
oLbx1:bLine := { || {  aTit[oLbx1:nAt,1],;
aTit[oLbx1:nAt,2],;
transform(aTit[oLbx1:nAt,3],"@D"),;
aTit[oLbx1:nAt,4],;
aTit[oLbx1:nAt,5],;
aTit[oLbx1:nAt,6],;
aTit[oLbx1:nAt,7],;
aTit[oLbx1:nAt,8],;
aTit[oLbx1:nAt,9],;
aTit[oLbx1:nAt,12],;
transform(aTit[oLbx1:nAt,10],"@D"),;
FG_AlinVlrs(transform(aTit[oLbx1:nAt,11],"@E 999,999.99")),;
FG_AlinVlrs(transform(aTit[oLbx1:nAt,13],"@E 999,999.99"))}}

@ aPos[1,1]+004,aPos[1,2]+(nTam*3)+001 TO ((aPos[1,3]-aPos[1,1])/2)+003,aPos[1,2]+(nTam*4) LABEL "" OF oDlg PIXEL
@ aPos[1,1]+010,aPos[1,2]+(nTam*3)+010 SAY STR0037  SIZE 70,08 OF oDlg PIXEL COLOR CLR_BLUE
@ aPos[1,1]+009,aPos[1,2]+(nTam*4)-065 MSCOMBOBOX oOrdem VAR cOrdem VALID (FS_ORDENA(),oLbx1:SetFocus()) SIZE 55,08 COLOR CLR_BLACK ITEMS aOrdem OF oDlg PIXEL

@ ((aPos[1,3]-aPos[1,1])/2)+005,aPos[1,2]+(nTam*3)+001 TO aPos[1,3],aPos[1,2]+(nTam*4) LABEL "" OF oDlg PIXEL
@ ((aPos[1,3]-aPos[1,1])/2)+011,aPos[1,2]+(nTam*3)+005 SAY STR0038 SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE
@ ((aPos[1,3]-aPos[1,1])/2)+010,aPos[1,2]+(nTam*4)-065 MSGET oNroProp  VAR cNroProp F3 "VV0ATE" VALID (!Empty(cNroProp) .and. (cNroProp:=strzero(val(cNroProp),10)) ,Processa( {|| FS_PESQUISAR(2) } ),oLbx1:SetFocus()) PICTURE "@!" SIZE 55,08 OF oDlg PIXEL

@ aPos[1,1]+007,aPos[1,2]+(nTam*4)+((nTam/2)-43)/2 BUTTON oImprimir  PROMPT STR0039 OF oDlg SIZE 43,10 PIXEL  ACTION Processa( {|| FS_IMPRIMIR() } )
@ aPos[1,1]+007,aPos[1,2]+(nTam*4)+(nTam/2)+((nTam/2)-43)/2 BUTTON oSair PROMPT STR0040 OF oDlg SIZE 43,10 PIXEL  ACTION (oDlg:End())

ACTIVATE MSDIALOG oDlg

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PESQUISAR ³ Autor ³ Thiago Aprile      ³ Data ³25/08/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Botao pesquisar.				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_PESQUISAR(nTp)
Local nTamVV0    := VV0->(TamSx3("VV0_NUMTRA")[1])
Local nTamSE1    := SE1->(TamSx3("E1_NUM")[1])
Local lVetBranco := .f.
Local cPulaAtend := ""
Local cAliasSE1  := "SQLSE1"
Local cQuery     := ""
Local cNroNF     := ""
Local cFilVV0    := xFilial("VV0")
Local cFilSE1    := xFilial("SE1")
If nTp == 1
	cNroProp := space(10)
EndIf
If !Empty(cNroProp)
	DbSelectArea("VV0")
	DbSetOrder(1)
	If DbSeek(xFilial("VV0")+cNroProp)
		cNroNF := VV0->VV0_NUMNFI
	EndIf
EndIf
aTit   := {}
nQtd   := 0
nValor := 0
cQuery := "SELECT SE1.E1_FILIAL , SE1.E1_NUM , SE1.E1_CLIENTE , SE1.E1_LOJA , SE1.E1_EMISSAO , SE1.E1_VENCREA , SE1.E1_TIPO , SE1.E1_VALOR , SE1.E1_SALDO "
cQuery += "FROM "+RetSqlName("SE1")+" SE1 WHERE "
If !Empty(cNroProp)
	cQuery += "SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
	cQuery += "( SE1.E1_NUM='V"+right(cNroProp,nTamSE1-1)+"' "
	If !Empty(cNroNF)
		cQuery += " OR SE1.E1_NUM='"+left(cNroNF,nTamSE1)+"' "
	EndIf
	cQuery += ") AND "
Else
	If !Empty(cFiliais)
		If Empty(cFilSE1)
			cQuery += "SE1.E1_FILIAL='"+cFilSE1+"' AND " // Levanta SE1 compartilhado
		Else
			cQuery += "SE1.E1_FILIAL IN "+ FormatIN(cFiliais,"/")+" AND " // Levanta SE1 das filiais selecionadas
		EndIf
	Else
		cQuery += "SE1.E1_FILIAL='______' AND " // Nao fazer SQL quando nao foi selecionada nenhuma filial
	EndIf
	If cReceb == STR0003
		If cTitulos == STR0002
			cQuery += "SE1.E1_BAIXA<>'        ' AND "
		Else
			cQuery += "(SE1.E1_BAIXA='        ' OR SE1.E1_SALDO <> 0 ) AND "
		EndIf
	Else
		If cTitulos == STR0002
			cQuery += "SE1.E1_DFISICO<>'        ' AND "
		Else
			cQuery += "SE1.E1_DFISICO='        ' AND "
		EndIf
	EndIf
	If cPeriodo == STR0005
		cQuery += "SE1.E1_VENCREA>='"+dtos(dDtInicial)+"' AND SE1.E1_VENCREA<='"+dtos(dDtFinal)+"' AND "
	EndIf
	If cLisPar == STR0009
		cQuery += "SE1.E1_SALDO>0 AND SE1.E1_VENCREA<'"+dtos(dDataBase)+"' AND "
	EndIf
EndIf
cQuery += "SE1.E1_PREFORI='"+GetNewPar("MV_PREFVEI","VEI")+"' AND SE1.D_E_L_E_T_=' ' ORDER BY SE1.E1_NUM "
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSE1, .T., .T. )
Do While !( cAliasSE1 )->( Eof() )
	If !Empty(cPulaAtend) // Pula todos os Titulos do Atendimento
		If cPulaAtend == ( cAliasSE1 )->( E1_NUM )
			( cAliasSE1 )->(dbSkip())
			Loop
		EndIf
	EndIf
	If Empty(cNroProp)
		If !Empty(cTpPagto)
			If !( ( cAliasSE1 )->( E1_TIPO ) $ cTpPagto )
				( cAliasSE1 )->(dbSkip())
				Loop
			EndIf
		EndIf
	EndIf
	If "V" $ ( cAliasSE1 )->( E1_NUM ) // Gerou Titulo na Aprovacao do Atendimento
		DbSelectArea("VV0")
		DbSetOrder(1)
		If Empty(cFilVV0)
			DbSeek( cFilVV0 + strzero(val(substr(( cAliasSE1 )->( E1_NUM ),2)),nTamVV0) )
		Else
			DbSeek( ( cAliasSE1 )->( E1_FILIAL ) + strzero(val(substr(( cAliasSE1 )->( E1_NUM ),2)),nTamVV0) )
		EndIf
	Else // Gerou Titulo na Finalizacao do Atendimento
		DbSelectArea("VV0")
		DbSetOrder(4)
		If Empty(cFilVV0)
			DbSeek( cFilVV0 + ( cAliasSE1 )->( E1_NUM ) )
		Else
			DbSeek( ( cAliasSE1 )->( E1_FILIAL ) + ( cAliasSE1 )->( E1_NUM ) )
		EndIf
	EndIf
	If Empty(cNroProp)
		If cPeriodo <> STR0005
			If cPeriodo == STR0006
				If VV0->VV0_DATAPR < dDtInicial .or. VV0->VV0_DATAPR > dDtFinal
					cPulaAtend := ( cAliasSE1 )->( E1_NUM )
					( cAliasSE1 )->(dbSkip())
					Loop
				EndIf
			ElseIf cPeriodo == STR0007
				DbSelectArea("VV9")
				DbSetOrder(1)
				DbSeek( xFilial("VV9") + VV0->VV0_NUMTRA )
				If VV9->VV9_STATUS <> "F" .or. VV0->VV0_DATMOV < dDtInicial .or. VV0->VV0_DATMOV > dDtFinal
					cPulaAtend := ( cAliasSE1 )->( E1_NUM )
					( cAliasSE1 )->(dbSkip())
					Loop
				EndIf
			EndIf
		EndIf
	EndIf
	
	dbSelectArea("VVA")
	dbSetOrder(1)
	dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+( cAliasSE1 )->E1_CLIENTE+( cAliasSE1 )->E1_LOJA)
	
	dbSelectArea("SA3")
	dbSetOrder(1)
	dbSeek(xFilial("SA3")+VV0->VV0_CODVEN)
	if VV0->VV0_TIPFAT == "0"
		cTipFat := STR0041
	Elseif VV0->VV0_TIPFAT == "1"
		cTipFat := STR0042
	Else
		cTipFat := STR0043
	Endif
	
	if (Len(aTit) == 0) .or. (Len(aTit) == 1 .and. Empty(aTit[1,1]))
		aTit := {}
	Endif
	
	SX5->(DbSetOrder(1))
	SX5->(DbSeek(xFilial("SX5")+"05"+( cAliasSE1 )->E1_TIPO))
	aAdd(aTit,{SA1->A1_COD+"-"+SA1->A1_LOJA+" "+substr(SA1->A1_NOME,1,20),VV0->VV0_NUMTRA,stod(( cAliasSE1 )->E1_EMISSAO),;
	( cAliasSE1 )->E1_FILIAL,SA3->A3_COD+"-"+Left(SA3->A3_NOME+space(20),20),cTipFat,VVA->VVA_CHASSI,VV0->VV0_NUMNFI+"-"+VV0->VV0_SERNFI,;
	( cAliasSE1 )->E1_TIPO,stod(( cAliasSE1 )->E1_VENCREA),( cAliasSE1 )->E1_VALOR,left(SX5->X5_DESCRI,25),( cAliasSE1 )->E1_SALDO})
	
	nQtd++
	nValor += ( cAliasSE1 )->E1_SALDO
	( cAliasSE1 )->(dbSkip())
Enddo
(cAliasSE1)->(DbCloseArea())
if (Len(aTit) == 0) .or. (Len(aTit) == 1 .and. Empty(aTit[1,1]))
	aAdd(aTit,{"","",ctod(""),"","","","","","",ctod(""),0,"",0})
	lVetBranco := .t.
Endif
FS_ORDENA()
if lVetBranco
	MsgStop(STR0044,STR0045)
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_ORDENA    ³ Autor ³ Thiago Aprile      ³ Data ³25/08/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Ordena vetor.  				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ORDENA()
If cOrdem == STR0010 // Ordena por vencimento
	aSort(aTit,1,,{|x,y| dtos(x[10]) < dtos(y[10]) })
Elseif cOrdem == STR0011 // Tipo Pagto
	aSort(aTit,1,,{|x,y| x[9] < y[9] })
Else  // Proposta
	aSort(aTit,1,,{|x,y| x[2] < y[2] })
Endif
oLbx1:SetArray(aTit)
oLbx1:bLine := { || {  aTit[oLbx1:nAt,1],;
aTit[oLbx1:nAt,2],;
transform(aTit[oLbx1:nAt,3],"@D"),;
aTit[oLbx1:nAt,4],;
aTit[oLbx1:nAt,5],;
aTit[oLbx1:nAt,6],;
aTit[oLbx1:nAt,7],;
aTit[oLbx1:nAt,8],;
aTit[oLbx1:nAt,9],;
aTit[oLbx1:nAt,12],;
transform(aTit[oLbx1:nAt,10],"@D"),;
FG_AlinVlrs(transform(aTit[oLbx1:nAt,11],"@E 999,999.99")),;
FG_AlinVlrs(transform(aTit[oLbx1:nAt,13],"@E 999,999.99"))}}
oLbx1:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_TIPPAG    ³ Autor ³ Thiago Aprile      ³ Data ³25/08/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Levantamento dos Tipos de Pagamento VSA.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIPPAG()
Local lMarcar  := .f.
Local ni       := 0
Local nTamTipo := SE1->(TamSX3("E1_TIPO")[1])
Private aVetTpP := {}
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
DbSelectArea("VSA")
DbSetOrder(1)
DbSeek(xFilial("VSA"))
Do While !Eof() .and. xFilial("VSA") == VSA->VSA_FILIAL
	aAdd( aVetTpP , { ( left(VSA->VSA_TIPPAG+space(nTamTipo),nTamTipo) $ cTpPagto ) , left(VSA->VSA_TIPPAG+space(nTamTipo),nTamTipo) , VSA->VSA_DESPAG })
	DbSelectArea("VSA")
	DbSkip()
EndDo
If Len(aVetTpP) > 1
	DEFINE MSDIALOG oDlgTpP FROM 05,01 TO 250,400 TITLE STR0046 PIXEL  // Empresas
	@ 001,001 LISTBOX oLbTpP FIELDS HEADER "",STR0032,STR0047;//Tipo / Descricao
	COLSIZES 10,20,100;
	SIZE 165,120 OF oDlgTpP ON DBLCLICK ( aVetTpP[oLbTpP:nAt,1] := !aVetTpP[oLbTpP:nAt,1] ) PIXEL
	oLbTpP:SetArray(aVetTpP)
	oLbTpP:bLine := { || {  If(aVetTpP[oLbTpP:nAt,1],oOk,oNo) ,;
	aVetTpP[oLbTpP:nAt,2],;
	aVetTpP[oLbTpP:nAt,3] }}
	DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgTpP:End()) ENABLE OF oDlgTpP
	@ 002, 002 CHECKBOX oMacTod VAR lMarcar PROMPT "" OF oDlgTpP ON CLICK If( FS_TIK(lMarcar,"TIP") , .t. , ( lMarcar:=!lMarcar , oDlgTpP:Refresh() ) ) 	SIZE 70,08 PIXEL COLOR CLR_BLUE
	ACTIVATE MSDIALOG oDlgTpP CENTER
EndIf
cTpPagto := ""
For ni := 1 to len(aVetTpP)
	If aVetTpP[ni,1]
		cTpPagto += aVetTpP[ni,2]+"/"
	EndIf
Next
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_EMPRESAS  ³ Autor ³ Thiago Aprile      ³ Data ³25/08/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levantamento das Empresas SX2.		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_EMPRESAS()
Local lMarcar := .f.
Local ni      := 0
Local aFilAtu      := FWArrFilAtu()
Local cBkpFilAnt  := cFilAnt
Local aSM0         := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local nCont := 0
Private aVetEmp  := {}
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
cEmpLibs := FG_FilLib(2) // retorna empresas filiais que o usuario pode acessar
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	If AllTrim(cEmpAnt+cFilAnt) $ cEmpLibs
		aAdd( aVetEmp, { ( cFilAnt $ cFiliais ) ,cEmpAnt, cFilAnt, FWFilialName(), FWGrpName() })
	EndIf
Next
If Len(aVetEmp) > 1
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 345,500 TITLE STR0046 PIXEL  // Empresas
	If FindFunction( "FWLoadSM0" )
		@ 001,001 LISTBOX oLbEmp FIELDS HEADER "",STR0048,STR0049,STR0027,STR0050;//Emp #Filial # Empresa # Nome
		COLSIZES 10,15,15,50,50;
		SIZE 220,165 OF oDlgEmp ON DBLCLICK ( aVetEmp[oLbEmp:nAt,1] := !aVetEmp[oLbEmp:nAt,1] ) PIXEL
		oLbEmp:SetArray(aVetEmp)
		oLbEmp:bLine := { || {  If(aVetEmp[oLbEmp:nAt,1],oOk,oNo) ,;
		aVetEmp[oLbEmp:nAt,2],;
		aVetEmp[oLbEmp:nAt,5],;
		aVetEmp[oLbEmp:nAt,3],;
		aVetEmp[oLbEmp:nAt,4] }}
		
		DEFINE SBUTTON FROM 001,225 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp
	Else
		@ 001,001 LISTBOX oLbEmp FIELDS HEADER "",STR0051,STR0027,STR0052,STR0053;//Emp #Filial # Empresa # Nome
		COLSIZES 10,15,15,50,50;
		SIZE 165,120 OF oDlgEmp ON DBLCLICK ( aVetEmp[oLbEmp:nAt,1] := !aVetEmp[oLbEmp:nAt,1] ) PIXEL
		oLbEmp:SetArray(aVetEmp)
		oLbEmp:bLine := { || {  If(aVetEmp[oLbEmp:nAt,1],oOk,oNo) ,;
		aVetEmp[oLbEmp:nAt,2],;
		aVetEmp[oLbEmp:nAt,3],;
		aVetEmp[oLbEmp:nAt,4],;
		aVetEmp[oLbEmp:nAt,5] }}
		
		DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp
	EndIf
	
	@ 002, 002 CHECKBOX oMacTod VAR lMarcar PROMPT "" OF oDlgEmp ON CLICK If( FS_TIK(lMarcar,"EMP") , .t. , ( lMarcar:=!lMarcar , oDlgEmp:Refresh() ) ) 	SIZE 70,08 PIXEL COLOR CLR_BLUE
	ACTIVATE MSDIALOG oDlgEmp CENTER
EndIf
cFilAnt := cBkpFilAnt
cFiliais := ""
For ni := 1 to len(aVetEmp)
	If aVetEmp[ni,1]
		cFiliais += aVetEmp[ni,3]+"/"
	EndIf
Next
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_TIK	 ³ Autor ³ Thiago Aprile        ³ Data ³25/08/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marcar Tudo.							                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(lMarcar,cTipo)
Local ni := 0
Default lMarcar := .f.
If cTipo == "EMP" // Empresas
	For ni := 1 to Len(aVetEmp)
		If lMarcar
			aVetEmp[ni,1] := .t.
		Else
			aVetEmp[ni,1] := .f.
		EndIf
	Next
	oLbEmp:SetFocus()
	oLbEmp:Refresh()
Else // Tipo de Pagamento
	For ni := 1 to Len(aVetTpP)
		If lMarcar
			aVetTpP[ni,1] := .t.
		Else
			aVetTpP[ni,1] := .f.
		EndIf
	Next
	oLbTpP:SetFocus()
	oLbTpP:Refresh()
EndIf
Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMPRIMIR³ Autor ³ Thiago Aprile        ³ Data ³25/08/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimir.							                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR()
Local nTotal	:= 0
Local i         := 0
Local cDesc1	:= ""
Local cDesc2	:= ""
Local cDesc3	:= ""
Local cAlias	:= ""
Private nLin    := 1
Private aReturn := { "" , 1 , "" , 1 , 2 , 1 , "" , 1 }
Private aVetor := {}
Private cTamanho:= "G"           // P/M/G
Private Limite  := 220           // 80/132/220
Private cTitulo := STR0054
Private cNomProg:= "VEIXC007"
Private cNomeRel:= "VEIXC007"
Private nLastKey:= 0
Private cabec1  := ""
Private cabec2  := ""
Private nCaracter:=15
Private m_Pag   := 1
cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cAlias)
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1

@nLin++, 000 pSay STR0055
For i := 1 to Len(aTit)
	@nLin++,000 pSay aTit[i,1]+" "+aTit[i,2]+" "+transform(aTit[i,3],"@D")+" "+aTit[i,4]+space(5)+aTit[i,5]+"   "+aTit[i,6]+space(5)+substr(aTit[i,7],1,25)+" "+aTit[i,8]+" "+aTit[i,9]+" "+Left(aTit[i,12],30)+" "+transform(aTit[i,10],"@D")+transform(aTit[i,11],"@E 9,999,999.99")+transform(aTit[i,13],"@E 9,999,999.99")
	if nLin > 60
		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		@nLin++, 000 pSay STR0055
	Endif
	nTotal += aTit[i,13]
Next

@nLin++, 194 pSay "___________"
@nLin++, 185 pSay STR0056+transform(nTotal,"@E 9,999,999.99")

Ms_Flush()
Set Printer to
Set Device  to Screen
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf

Return(.t.)
