#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "HSPAHM58.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                               
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ HSPAHM58 ³ Autor ³ Rogerio Tabosa		³ data ³ 04/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Configuração Odontograma para Clinica odontologica         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Gestao Hospitalar                            			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHM58()      

Private cCadastro := "Configuração e Mapeamento de Imagens" //"Configuração Odontograma"
Private aRotina := {	{OemtoAnsi(STR0002), "axPesqui"   , 0, 1}, ; //"Pesquisar"
						{OemtoAnsi(STR0003), "HS_M58"	  , 0, 2}, ; //"Visualizar"
						{OemtoAnsi(STR0004), "HS_M58"	  , 0, 3}, ; //"Incluir"
						{OemtoAnsi(STR0005), "HS_M58"	  , 0, 4}, ; //"Alterar"
						{OemtoAnsi(STR0006), "HS_M58"	  , 0, 5}} 	 //"Excluir"

mBrowse(06, 01, 22, 75, "GTE")
 
Return(Nil)                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_M58    º Autor ³ Saude              º Data ³  04/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tratamento das Funcoes                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestão Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HS_M58(cAlias, nReg, nOpc)
Local nOpcA := 0, nGDOpc := IIF(nOpc == 2 .Or. nOpc == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)

Private aHITE := {}, aCITE := {}, nUITE := 0
Private aTela  := {}, aGets := {}
Private aCpoGtf  	:= {"GTF_ITEM","GTF_CXSUP1","GTF_CYSUP1","GTF_CXSUP2","GTF_CYSUP2","GTF_CXINF1"}  
Private oGDITE
Private nGTFDENREG 	:= 0
Private nGTFFADENT 	:= 0
Private oDrawer 
Private aCposAlt 	:= {}
Private aCpIteAlt	:= {}
Private lSelectArq 	:= .T. // Variavel utilizada no M52 para selecionar arquivos
Private cAliasIte	:= "GTG"  


If nOpc == 3
	If Pergunte("HSPM58", .T.) 
		cTipCfg		:= IIf(MV_PAR01  == 1, "0", "1") // Geral/ Odontograma
		cAliasIte	:= IIf(cTipCfg  == "0", "GTG", "GTF")
	Else
		Return()		
	EndIf 
Else
	cTipCfg := GTE->GTE_TIPCFG
	cAliasIte	:= IIf(cTipCfg  == "0", "GTG", "GTF")
EndIf


If nOpc == 3
	aCposAlt := {"GTE_DESCRI","GTE_IMAGEM","GTE_ESPECI", "GTE_TELA"}
ElseIf nOpc == 4
	aCposAlt := {"GTE_DESCRI","GTE_ESPECI", "GTE_TELA"}
EndIf

//Inclui	:= (nOpc == 3)

aSize	:= MsAdvSize(.T.)
 
aObjects := {}
aAdd( aObjects, { 100, 015, .T., .T.} )     // MsGet
aAdd( aObjects, { 100, 060, .T., .T.,.T.} ) // Imagem
aAdd( aObjects, { 100, 025, .T., .T.,.T.} ) // Grid
 
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPPanel := MsObjSize( aInfo, aObjects, .T.)  // ObjSize da tela inteira
 
aObjects := {}	
aAdd( aObjects, { 100, 100, .T., .T., .T.} )
 
aInfo  := { aPPanel[1, 2], aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4], 0, 0 }
aPInfo := MsObjSize( aInfo, aObjects, .T., .T.) // Obj  MsGet

aObjects := {}	
aAdd( aObjects, { 100, 100, .T., .T.} )	
 
aInfo  := { aPPanel[2, 2], aPPanel[2, 2], aPPanel[2, 3], aPPanel[2, 4], 0, 0 }
aPImag := MsObjSize( aInfo, aObjects, .T., .T.,.T.) // Obj Grid de baixo

aObjects := {}	
aAdd( aObjects, { 100, 100, .T., .T.} )	
 
aInfo  := { aPPanel[3, 2], aPPanel[3, 2], aPPanel[3, 3], aPPanel[3, 4], 0, 0 }
aPGrid := MsObjSize( aInfo, aObjects, .T., .T.,.T.) // Obj Grid de baixo

DEFINE MSDIALOG oDlgM58 TITLE OemToAnsi(cCadastro) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd  //"Configuração Odontograma"

/* Panels para manipulação do tamanho da Tela */
oPanelTop	:=	tPanel():New(aPInfo[1, 1], aPInfo[1, 2],, oDlgM58,,,,,,	aPInfo[1, 3] ,	aPInfo[1, 4])
oPanelTop:Align := CONTROL_ALIGN_ALLCLIENT

oPanelImg	:=	tPanel():New(aPPanel[2, 1]+20, aPPanel[2, 2],, oDlgM58,,,,,,	aPPanel[2, 3],	aPPanel[2, 4]-22)
oPanelGD	:=	tPanel():New(aPPanel[3, 1], aPPanel[3, 2],, oDlgM58,,,,,,	aPPanel[3, 3],	aPPanel[3, 4])

RegToMemory("GTE",(nOpc == 3)) // Gera variavies de memoria para o GCS

HS_BDados(cAliasIte, @aHITE, @aCITE, @nUITE, 1, M->GTE_CODIGO, "'" + M->GTE_CODIGO + "' == " + cAliasIte + "->" + cAliasIte + "_CODCFG", .T.,,,,,,,,,,,,,, )

nITEItem 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == cAliasIte + "_ITEM"})
nITECXSUP1 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == cAliasIte + "_CXSUP1"})
nITECYSUP1 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == cAliasIte + "_CYSUP1"})
nITECXSUP2 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == cAliasIte + "_CXSUP2"})
nITECYSUP2 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == cAliasIte + "_CYSUP2"})
nITECXINF1 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == cAliasIte + "_CXINF1"})
nITECYINF1 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == cAliasIte + "_CYINF1"})
nITECXINF2 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == cAliasIte + "_CXINF2"})
nITECYINF2 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == cAliasIte + "_CYINF2"})
If cAliasIte == "GTF"
	aCpIteAlt := {"GTF_DENREG","GTF_FADENT"}
	nGTFDENREG 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == "GTF_DENREG"})
	nGTFDESREG 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == "GTF_DESREG"})
	nGTFFADENT 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == "GTF_FADENT"})
	nGTFFACDES 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == "GTF_FACDES"})
Else 
	aCpIteAlt := {"GTG_CODIGO"}
	nGTGCODIGO 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == "GTG_CODIGO"})
	nGTGDESCRI 	:= aScan(aHITE, {| aVet | AllTrim(aVet[2]) == "GTG_DESCRI"})
EndIf
	

If Empty(aCITE[1, nITEItem])
	aCITE[1, nITEItem] := StrZero(1, Len(GTF->GTF_ITEM))
EndIf 

oEncGTE := MsMget():New("GTE", nReg, nOpc,,,,, {aPInfo[1, 1], aPInfo[1, 2], ((aPInfo[1, 3]-10)), aPInfo[1, 4] },aCposAlt,,,,, oPanelTop,,,, )	
oEncGTE:oBox:Align := CONTROL_ALIGN_TOP	

//oEncGcy := MsMGet():New("GCY", nRegM24, nOpcM24,,,, aCposGcy, IIF(aRotina[nOpcM24, 3] <> 4, {aPObjs[1, 1], aPObjs[1, 2]-10, aPObjs[1, 3], aPObjs[1, 4]-04}, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}), aCposAlt, 2,,,, oFolAten:aDialogs[1]) 

oTScrollBox :=  TScrollBox():New(oPanelImg,aPImag[1,1],aPImag[1,2],aPImag[1,3],aPImag[1,4],.T.,.T.,.T.)
oTScrollBox:Align := CONTROL_ALIGN_ALLCLIENT 

oDrawer := tDrawer():New(aPImag[1, 1],aPImag[1, 2],oTScrollBox,aPImag[1, 3],aPImag[1, 4])
oDrawer:SetColors(-1, -1)
oDrawer:blClicked := {|o,x,y| FS_CONFIG(x,y,nOpc)}
If !Empty(M->GTE_IMAGEM) .AND. File(Alltrim(M->GTE_IMAGEM))
	oDrawer:OpenImage(Alltrim(M->GTE_IMAGEM))
EndIf

oGDITE:=   MsNewGetDados():New(aPGrid[1, 1], aPGrid[1, 2], aPGrid[1, 3], aPGrid[1, 4], nGDOpc,"HS_DuplAC(oGDITE:oBrowse:nAt, oGDITE:aCols, " + IIf(cAliasIte == "GTF","{nGTFDENREG,nGTFFADENT}","{nGTGCODIGO}") + ")",,"+" + cAliasIte + "_ITEM",aCpIteAlt,,,,,, oPanelGD, aHITE, aCITE)	


ACTIVATE MSDIALOG oDlgM58 ON INIT EnchoiceBar (	oDlgM58,	{|| nOpcA := 1,; 
												IIF(Obrigatorio(aGets, aTela) ;
												.And. oGDITE:TudoOk(),;
												oDlgM58:End(),  nOpcA := 0)},;
												{|| nOpcA := 0, oDlgM58:End() },,/*aButtons*/)

If nOpcA == 1 
	Begin Transaction
		FS_GRVM58(nOpc)
		While __lSx8
			ConfirmSx8()
		End	             
	End Transaction	
Else
	While __lSx8
		RollBackSxe()
	End 
EndIf

Return()

Function HS_M58EXIMG()
Local lRet	:= .T.
cArquivo := Alltrim(&(ReadVar()))

If !Empty(cArquivo)
	If File(cArquivo) 
		oDrawer:ClearImage()
		oDrawer:OpenImage(cArquivo)
		lRet	:= .T.
	Else
		HS_MSGINF(STR0007,STR0008,STR0009) //"Imagem não encontrada!","Atenção", "Cadastro Odontograma"
		lRet	:= .F.
	EndIf
Else
	HS_MSGINF(STR0007,STR0008,STR0009) //"Imagem não encontrada!","Atenção", "Cadastro Odontograma"
	lRet	:= .F.
EndIf
Return(.T.)    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ HS_VLDM58  ³ Autor ³ Rogério Tabosa    ³ Data ³ 05.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validações da Rotina  			     			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VLDM58()
Local lRet      := .T.
Local cCampo    := ReadVar()

If cCampo $ ("M->GTE_ESPECI")
	If !(lRet := HS_SeekRet("GFR", cCampo, 1, .F.))
		HS_MsgInf(STR0010, STR0008,STR0009) //"Especialidade não encontrada","Atenção", "Cadastro Odontograma"
	EndIf
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FS_CONFIG  ³ Autor ³ Rogério Tabosa    ³ Data ³ 05.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atribui as coordenadas ao Grid  			     			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_CONFIG(nX,nY, nOpc)
If nOpc <> 3 .AND. nOpc <> 4
	Return(.T.)
EndIf 
If oGDITE:nAt == 0
	Return(.T.)
EndIf
If Empty(M->GTE_IMAGEM)
	Return(.T.)
EndIf
If oGDITE:aCols[oGDITE:nAt, nITECXSUP1] == 0
	oGDITE:aCols[oGDITE:nAt, nITECXSUP1] := nX
	oGDITE:aCols[oGDITE:nAt, nITECYSUP1] := nY
ElseIf oGDITE:aCols[oGDITE:nAt, nITECXSUP2] == 0
	oGDITE:aCols[oGDITE:nAt, nITECXSUP2] := nX
	oGDITE:aCols[oGDITE:nAt, nITECYSUP2] := nY		
ElseIf oGDITE:aCols[oGDITE:nAt, nITECXINF1] == 0
	oGDITE:aCols[oGDITE:nAt, nITECXINF1] := nX
	oGDITE:aCols[oGDITE:nAt, nITECYINF1] := nY			
ElseIf oGDITE:aCols[oGDITE:nAt, nITECXINF2] == 0
	oGDITE:aCols[oGDITE:nAt, nITECXINF2] := nX
	oGDITE:aCols[oGDITE:nAt, nITECYINF2] := nY				
Else
	If MsgYesno(STR0011,STR0008) //"Deseja reconfigurar a linha selecionada?""Atenção"
		oGDITE:aCols[oGDITE:nAt, nITECXSUP1] := nX
		oGDITE:aCols[oGDITE:nAt, nITECYSUP1] := nY

		oGDITE:aCols[oGDITE:nAt, nITECXSUP2] := 0
		oGDITE:aCols[oGDITE:nAt, nITECYSUP2] := 0	
	
		oGDITE:aCols[oGDITE:nAt, nITECXINF1] := 0
		oGDITE:aCols[oGDITE:nAt, nITECYINF1] := 0	
			
		oGDITE:aCols[oGDITE:nAt, nITECXINF2] := 0
		oGDITE:aCols[oGDITE:nAt, nITECYINF2] := 0
	EndIf
EndIf
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FS_GRVM58  ³ Autor ³ Rogério Tabosa    ³ Data ³ 05.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravação dos dados do layout				     			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_GRVM58(nOpcG)   
Local aArea		:= getArea()
Local lAchou 	:= .T.        
Local nFor		:= 0

DbselectArea("GTE")
DbsetOrder(1) //GTE_FILIAL+GTE_CODIGO
lAchou := DbSeek(xFilial("GTE") + M->GTE_CODIGO)

If nOpcG == 3 .or. nOpcG == 4   // INCLUSAO ou ALTERACAO
	RecLock("GTE", !lAchou)
	HS_GRVCPO("GTE")
	GTE->GTE_FILIAL  := xFilial("GTE")
	GTE->GTE_TIPCFG  := cTipCfg	
	MsUnlock()   
	
	DbSelectArea(cAliasIte)
	DbSetOrder(1) //GTF_FILIAL+GTF_CODCFG+GTF_ITEM
	
	For nFor :=1 To Len(oGDITE:aCols)
		lAchou := DbSeek(xFilial(cAliasIte) + M->GTE_CODIGO + oGDITE:aCols[nFor, nITEItem])
		If oGDITE:aCols[nFor, Len(oGDITE:aHeader)+1 ] == .T.  // Se a linha esta deletada na get e achou o kra no banco
			If lAchou .And. nOpcG <> 3 
				RecLock(cAliasIte, .F., .F. )
				DbDelete()
				MsUnlock()
				WriteSx2(cAliasIte)
			EndIf
		Else
			RecLock(cAliasIte, !lAchou )
			HS_GRVCPO(cAliasIte, oGDITE:aCols, oGDITE:aHeader, nFor)
			&(cAliasIte+"->" + cAliasIte + "_FILIAL") := xFilial(cAliasIte)
			&(cAliasIte+"->" + cAliasIte + "_CODCFG") := M->GTE_CODIGO
			MsUnlock()
		EndIf
	Next		
ElseIf  nOpcG == 5// EXCLUSAO
	DbSelectArea(cAliasIte)
	DbSetOrder(1)
	If DbSeek(xFilial(cAliasIte) + M->GTE_CODIGO)
		While !Eof() .AND. &(cAliasIte + "->" + cAliasIte + "_FILIAL + " + cAliasIte + "->" + cAliasIte + "_CODCFG") == xFilial(cAliasIte) + M->GTE_CODIGO
			RecLock(cAliasIte, .F., .F. )
			DbDelete()
			MsUnlock()
			WriteSx2(cAliasIte)
		DbSkip()
		End 
	EndIf
	
	RecLock("GTE", .F., .T.)
	DbDelete()
	MsUnlock()
	WriteSx2("GTE")
EndIf  

RestArea(aArea)
Return()


