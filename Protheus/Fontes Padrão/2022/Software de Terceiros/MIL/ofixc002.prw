// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 5      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "tbiconn.ch"
#include "Protheus.ch"
#include "OFIXC002.ch"
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFIXC002   | Autor |  Luis Delorme         | Data | 14/02/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Consulta Pecas aguardando chegada (RoadMap 70 Sug.Auto)      |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXC002()
Local aSize      := FWGetDialogSize( oMainWnd )
Local lRet := .f.
Private oVerd   := LoadBitmap( GetResources() , "BR_VERDE" )	// Selecionado
Private oVerm   := LoadBitmap( GetResources() , "BR_VERMELHO" )	// Nao Selecionado
Private aIteRelP := {{.f.,"","","",stod("00000000"),""}}
Private cDescricao := ""
Private aNewBot := {}   
Private cVend := space(TamSx3("VS1_CODVEN")[1])
Private cCadastro := STR0001
//
cOrcamento:= space(TamSx3("VS1_NUMORC")[1])
cVendedor := space(TamSx3("VS1_CODVEN")[1])
//
// Monta os F3 conforme o SX3
cF3CODVEN := GetSX3Cache("VS1_CODVEN","X3_F3")

// ########################################################################
// # Montagem das informacoes de posicionamento da consulta               #
// ########################################################################

DEFINE MSDIALOG oDlgCP FROM aSize[1],aSize[2] TO aSize[3],aSize[4] TITLE cCadastro OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS

oWorkA := FWUIWorkArea():New( oDlgCP )		
oWorkA:CreateHorizontalBox( "LINE01", 15 )
oWorkA:SetBoxCols( "LINE01", { "OBJ1" } )
oWorkA:CreateHorizontalBox( "LINE02", 75 )
oWorkA:SetBoxCols( "LINE02", { "OBJ2" } )
oWorkA:Activate()

oScrollFilt := TScrollBox():New( oWorkA:GetPanel("OBJ1") , 0, 0, 25, 25, .t. /* lVertical */ , .f. /* lHorizontal */ , .f. /* lBorder */ )
oScrollFilt:Align := CONTROL_ALIGN_ALLCLIENT

oSay01 := TSay():New(002,004,{|| STR0002 },oScrollFilt,,,,,,.t.,CLR_BLACK,,40,8)
@ 012,004 MSGET cOrcamento F3 "VS1ORC" VALID FS_VERORC() SIZE 60,8 OF oScrollFilt PIXEL

oSay02 := TSay():New(002,074,{|| STR0003 },oScrollFilt,,,,,,.t.,CLR_BLACK,,40,8)
@ 012,074 MSGET cVendedor F3 cF3CODVEN VALID FS_VERVEN() SIZE 50,8 PIXEL OF oScrollFilt
@ 012,128 MSGET cDescricao SIZE 100,8 PIXEL OF oScrollFilt when .f.
@ 012,240  BUTTON oBtn1 PROMPT OemToAnsi(STR0004) OF oScrollFilt SIZE 40,10 PIXEL ACTION FS_FILTRA()

@ 012,300  BITMAP oxLara RESOURCE "BR_VERDE" OF oScrollFilt SIZE 10,10 PIXEL NOBORDER
oSay03 := TSay():New(012,310,{|| STR0008 },oScrollFilt,,,,,,.t.,CLR_BLACK,,90,8)	// "Orçamento Atendido"
@ 012,375 BITMAP oxLara RESOURCE "BR_VERMELHO" OF oScrollFilt SIZE 10,10 PIXEL NOBORDER
oSay04 := TSay():New(012,385,{|| STR0009 },oScrollFilt,,,,,,.t.,CLR_BLACK,,90,8)	// "Orçamento não Atendido"

/// ########################################################################
/// # Montagem da listbox contendo informacoes dos itens relacionados      #
/// ########################################################################

@ 039,004 LISTBOX oLbIteRelP FIELDS HEADER ;
(" "), ;
(STR0002), ;
(STR0005), ;
(STR0003), ;
(STR0006), ;
(STR0007)  ;
COLSIZES 10, 60, 150, 100, 100, 100 SIZE 100, 100 PIXEL OF oWorkA:GetPanel("OBJ2")
oLbIteRelP:Align:= CONTROL_ALIGN_ALLCLIENT
///
oLbIteRelP:SetArray(aIteRelP)
//
oLbIteRelP:bLine := { || { IIF(aIteRelP[oLbIteRelP:nAt,1],oVerd,oVerm),;
aIteRelP[oLbIteRelP:nAt,2],;
aIteRelP[oLbIteRelP:nAt,3],;
aIteRelP[oLbIteRelP:nAt,4],;
dtoc(aIteRelP[oLbIteRelP:nAt,5]),;
aIteRelP[oLbIteRelP:nAt,6] }}

ACTIVATE MSDIALOG oDlgCP CENTER ON INIT (EnchoiceBar(oDlgCP,{|| lRet := .t. ,oDlgCP:End()},{ || oDlgCP:End() },,aNewBot))

//
return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | FS_VERVEN  | Autor |  Luis Delorme         | Data | 13/02/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Valida vendedor digitado                                     |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_VERVEN()
Local lRet := .t.
cDescricao := ""
If !Empty(cVendedor)
	DBSelectArea("SA3")
	DBSetOrder(1)
	if DBSeek(xFilial("SA3")+Alltrim(cVendedor))
		cVend := Alltrim(cVendedor)+space(TamSx3("VS1_CODVEN")[1]-len(Alltrim(cVendedor)))
		cDescricao := Alltrim(SA3->A3_NOME)
	else
		lRet := .f.
	endif
EndIf
return lRet

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | FS_VERORC  | Autor |  Luis Delorme         | Data | 13/02/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Valida orçamento digitado                                    |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_VERORC()
Local lRet := .t.
if !Empty(cOrcamento)
	DBSelectArea("VS1")
	DBSetOrder(1)
	if !DBSeek(xFilial("VS1")+Alltrim(cOrcamento))
		lRet := .f.
	EndIf
endif
return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | FS_FILTRA  | Autor |  Luis Delorme         | Data | 13/02/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Filtra os orçamentos conforme vendedor e orcamento (params.) |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_FILTRA()

cQryAl001 := GetNextAlias()
cQuery := "SELECT VS1.VS1_NUMORC NORC,"
cQuery += "       SA1.A1_COD A1COD,"
cQuery += "       SA1.A1_TEL A1TEL,"
cQuery += "       SA1.A1_LOJA A1LOJA,"
cQuery += "       SA1.A1_NOME A1NOME,"
cQuery += "       SA3.A3_COD A3COD,"
cQuery += "       SA3.A3_NOME A3NOME,"
cQuery += "       VS1.VS1_DATORC DATORC,"
cQuery += "       SUM(VS3.VS3_QTDAGU) QAGU"
cQuery += " FROM "+RetSqlName("VS1")+ " VS1 INNER JOIN "+RetSqlName("SA1")+ " SA1 ON"
cQuery += "       ( A1_FILIAL ='" + xFilial("SA1") + "' AND VS1.VS1_CLIFAT = SA1.A1_COD AND VS1.VS1_LOJA = SA1.A1_LOJA AND SA1.D_E_L_E_T_=' ') LEFT OUTER JOIN "+RetSqlName("SA3")+ " SA3 ON"
cQuery += "       ( A3_FILIAL ='" + xFilial("SA3") + "' AND VS1.VS1_CODVEN = SA3.A3_COD AND SA3.D_E_L_E_T_=' ') INNER JOIN " + RetSqlName("VS3") + " VS3 ON"
cQuery += "       ( VS3_FILIAL ='" + xFilial("VS3") + "' AND VS1.VS1_NUMORC = VS3.VS3_NUMORC AND VS3.D_E_L_E_T_=' ')"
cQuery += " WHERE  VS1_STATUS = 'R' AND"
//
if !Empty(cOrcamento)
	cQuery += " VS1_NUMORC = '"+cOrcamento+"' AND"
endif
if !Empty(cVendedor)
	cQuery += " VS1_CODVEN = '"+cVend+"' AND"
endif
//
cQuery += "        VS1_FILIAL ='" + xFilial("VS1") + "' AND VS1.D_E_L_E_T_=' '"
cQuery += " GROUP BY VS1.VS1_NUMORC, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA3.A3_COD," 
cQuery += " SA3.A3_NOME, VS1.VS1_DATORC, SA1.A1_TEL"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )

aIteRelP := {}
while !(cQryAl001)->(eof())
	
	aAdd(aIteRelP, {;
	(cQryAl001)->(QAGU) == 0,;
	(cQryAl001)->(NORC),;
	(cQryAl001)->(A1COD)+"/"+(cQryAl001)->(A1LOJA)+"-"+(cQryAl001)->(A1NOME),;
	(cQryAl001)->(A3COD)+"-"+(cQryAl001)->(A3NOME),;
	stod( (cQryAl001)->(DATORC) ),;
	(cQryAl001)->(A1TEL) } )
	
	(cQryAl001)->(dbSkip())
enddo
if Len(aIteRelP) == 0
	aIteRelP := {{.f.,"","","",stod("00000000"),""}}
endif
(cQryAl001)->(dbCloseArea())

oLbIteRelP:SetArray(aIteRelP)
//
oLbIteRelP:bLine := { || { IIF(aIteRelP[oLbIteRelP:nAt,1],oVerd,oVerm),;
aIteRelP[oLbIteRelP:nAt,2],;
aIteRelP[oLbIteRelP:nAt,3],;
aIteRelP[oLbIteRelP:nAt,4],;
dtoc(aIteRelP[oLbIteRelP:nAt,5]),;
aIteRelP[oLbIteRelP:nAt,6] }}
oLbIteRelP:Refresh()

return .t.
