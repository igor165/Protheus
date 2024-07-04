// ษออออออออหออออออออป
// บ Versao บ 05     บ
// ศออออออออสออออออออผ

#Include "PROTHEUS.CH"
#include "MSGRAPHI.CH"
#Include "OFIOC500.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OFIOC500 บ Autor ณ Andre Luis Almeida บ Data ณ  09/12/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Consulta de Motivos ( % / Grafico )                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOC500()
Local aObjects   := {} , aInfo := {} , aPos := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private aPosGraf := {}
Private aParamet := {"",space(FWSizeFilial()),(dDataBase-day(dDataBase))+1,dDataBase,space(6)}
Private aTpAssun := {}
Private aMotivos := {}
Private aOrigem  := {}
Private oNADA    := LoadBitmap( GetResources()  , "NADA" )
Private oBR_AZUL := LoadBitmap( GetResources()  , "BR_AZUL" )
Private oBR_VERM := LoadBitmap( GetResources()  , "BR_VERMELHO" )
Private oBR_VERD := LoadBitmap( GetResources()  , "BR_VERDE" )
Private oBR_AMAR := LoadBitmap( GetResources()  , "BR_AMARELO" )
Private oBR_BRAN := LoadBitmap( GetResources()  , "BR_BRANCO" )
Private oBR_CINZ := LoadBitmap( GetResources()  , "BR_CINZA" )
Private oBR_PINK := LoadBitmap( GetResources()  , "BR_PINK" )
Private oBR_MARR := LoadBitmap( GetResources()  , "BR_MARROM" )
//
Private aNewBot  := {{"FORM",	{|| OR500ChmImp()},	"Imprimir"}}
Private lDetImp

If (ExistBlock("OFC500ABT")) // Ponto de Entrada para adicionar op็๕es no Menu
	aNewBot := ExecBlock("OFC500ABT", .f., .f., {aNewBot})
EndIf
//
FS_MOTIVOS( 0 , .f. ) // Assuntos
FS_MOTIVOS( 1 , .f. ) // Motivos
//
DEFINE MSDIALOG oOFC500 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta de Motivos
	oOFC500:lEscClose := .F.
	//
	oPan1 := tPanel():Create( oOFC500 ,01,01,,,.F.,,,,210,10)
	oPan1:Align := CONTROL_ALIGN_LEFT

	oOFC500Scroll := TScrollBox():New( oPan1 , 01 , 01 , 80 , 80 , .t. , , .t. )
	oOFC500Scroll:Align := CONTROL_ALIGN_TOP

	oPan2 := tPanel():Create( oOFC500 ,01,01,,,.F.,,,,100,90)
	oPan2:Align := CONTROL_ALIGN_ALLCLIENT
	oPan2:ReadClientCoors()

	oPan2_1 := tPanel():Create( oPan2,01,01,,,.F.,,,,100, ( ( oPan2:nClientHeight / 2 ) * .45 ) )
	oPan2_1:Align := CONTROL_ALIGN_TOP

	oPan2_2 := tPanel():Create( oPan2,01,01,,,.F.,,,, 020 ,100)
	oPan2_2:Align := CONTROL_ALIGN_ALLCLIENT

	@ 009 , 005 SAY (STR0007+":") SIZE 55,8 OF oOFC500Scroll PIXEL COLOR CLR_BLUE // Motivos
	@ 008 , 030 MSCOMBOBOX oTpAssun VAR aParamet[1] SIZE 170,10 ITEMS aTpAssun OF oOFC500Scroll PIXEL COLOR CLR_BLUE
	//
	@ 022 , 005 SAY (STR0002+":") SIZE 55,8 OF oOFC500Scroll PIXEL COLOR CLR_BLUE // Filial
	@ 021 , 030 MSGET oFilOri VAR aParamet[2] PICTURE "@!" SIZE 60,08 F3 "SM0_01" OF oOFC500Scroll PIXEL COLOR CLR_BLACK
	//
	@ 034 , 005 SAY (STR0003+":") SIZE 58,8 OF oOFC500Scroll PIXEL COLOR CLR_BLUE // Periodo
	@ 033 , 030 MSGET oDatIni VAR aParamet[3] PICTURE "@D" SIZE 46,08 OF oOFC500Scroll PIXEL HASBUTTON COLOR CLR_BLACK
	@ 034 , 080 SAY (STR0004) SIZE 15,8 OF oOFC500Scroll PIXEL COLOR CLR_BLUE // ate
	@ 033 , 092 MSGET oDatFin VAR aParamet[4] PICTURE "@D" SIZE 46,08 OF oOFC500Scroll PIXEL HASBUTTON COLOR CLR_BLACK
	//
	@ 046 , 005 SAY (STR0005+":") SIZE 55,8 OF oOFC500Scroll PIXEL COLOR CLR_BLUE // Filial
	@ 045 , 030 MSGET oUsuMov VAR aParamet[5] PICTURE "@!" F3 "USR" SIZE 50,08 OF oOFC500Scroll PIXEL COLOR CLR_BLACK
	//
	@ 060 , 065 BUTTON oFiltro PROMPT STR0006 OF oOFC500Scroll SIZE 65,09 PIXEL ACTION FS_MOTIVOS( 1 , .t. ) // Filtrar
	//
	@ 080 , 000 LISTBOX oMotivos ;
		FIELDS ;
		HEADER "",STR0007,STR0008,"%" ;
		COLSIZES 10,110,40,25 ;
		SIZE 10,10 ;
		OF oPan1 ;
		PIXEL ON DBLCLICK FS_DBLCLICK(oMotivos:nAt)
	oMotivos:Align := CONTROL_ALIGN_ALLCLIENT
	oMotivos:SetArray(aMotivos)
	oMotivos:bLine := { || { ;
		&("o"+aMotivos[oMotivos:nAt,4]) ,;
		IIf(oMotivos:nAt<>1,aMotivos[oMotivos:nAt,1]+" - ","")+aMotivos[oMotivos:nAt,2] , ;
		FG_AlinVlrs(Transform(aMotivos[oMotivos:nAt,3],"@E 999,999")) , ;
		FG_AlinVlrs(Transform((aMotivos[oMotivos:nAt,3]/aMotivos[1,3])*100,"@E 999.9")+" %") }}
	//
	//aPosGraf := {0,208,aPos[1,4]-205,aPos[1,3]-aPos[1,1]}
	//
	oGrafic1 := TMSGraphic():New( 010,010,oPan2_1,,,RGB(239,239,239),010,010)
	oGrafic1:Align := CONTROL_ALIGN_ALLCLIENT
	oGrafic1:SetMargins(0,0,0,0)
	oGrafic1:SetLegenProp(3,CLR_LIGHTGRAY,1,.f.)
	//
	oGrafic2 := TMSGraphic():New( 010,010,oPan2_2,,,RGB(239,239,239),010,010)
	oGrafic2:Align := CONTROL_ALIGN_ALLCLIENT
	oGrafic2:SetMargins(0,0,0,0)
	oGrafic2:SetLegenProp(3,CLR_LIGHTGRAY,1,.f.)
	//
ACTIVATE MSDIALOG oOFC500 ON INIT EnchoiceBar(oOFC500,{ || oOFC500:End() }, { || oOFC500:End() },, aNewBot)
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MOTIVOSบ Autor ณ Andre Luis Almeida บ Data ณ  09/12/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Levanta Motivos                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MOTIVOS(nTp,lRefresh)
Local cQuery  := ""
Local cQAlSQL := "SQLQUERY"
Local ni      := 0
Local aColors := { CLR_HGREEN , CLR_YELLOW , CLR_WHITE , CLR_GRAY  , CLR_HBLUE , CLR_HRED  , CLR_HMAGENTA , CLR_BROWN }
Local aLegend := { 'BR_VERD'  , 'BR_AMAR'  , 'BR_BRAN' , 'BR_CINZ' , 'BR_AZUL' , 'BR_VERM' , 'BR_PINK'    , 'BR_MARR' }
Local nColors := 0
Local nDemais := 0
If nTp == 0 // Tipo de Assunto
	aTpAssun := {}
	aAdd(aTpAssun,"")
	cQuery := "SELECT DISTINCT X5_CHAVE , X5_DESCRI "
	cQuery += "FROM "+RetSqlName("SX5")+" "
	cQuery += "WHERE X5_FILIAL='"+xFilial("SX5")+"' AND X5_TABELA='VM' AND D_E_L_E_T_=' ' "
	cQuery += "ORDER BY X5_DESCRI"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
		aAdd(aTpAssun,( cQAlSQL )->( X5_CHAVE )+"="+( cQAlSQL )->( X5_DESCRI ))
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	If len(aTpAssun) <= 0
		aAdd(aTpAssun,"")
	EndIf
ElseIf nTp == 1 // Motivos por Tipo de Assunto
	aMotivos := {}
	aAdd(aMotivos,{"ZZZ","TOTAL GERAL",0,"NADA"})
	If !Empty(aParamet[1])
		cQuery := "SELECT VDT.VDT_CODMOT , VS0.VS0_DESMOT , COUNT(DISTINCT(VDT.VDT_TIPORI+VDT.VDT_FILORI+VDT.VDT_CODORI+VDT.VDT_DATMOV+VDT.VDT_HORMOV+VDT.VDT_USUMOV)) QTDE "
		cQuery += "FROM "+RetSqlName("VDT")+" VDT "
		cQuery += "JOIN "+RetSqlName("VS0")+" VS0 ON ( VS0.VS0_FILIAL='"+xFilial("VS0")+"' AND VS0.VS0_TIPASS=VDT.VDT_TIPASS AND VS0.VS0_CODMOT=VDT.VDT_CODMOT AND VS0.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VDT.VDT_FILIAL='"+xFilial("VDT")+"' AND "
		cQuery += "VDT.VDT_TIPASS='"+aParamet[1]+"' AND "
		If !Empty(aParamet[2])
			cQuery += "VDT.VDT_FILORI='"+aParamet[2]+"' AND "
		EndIf
		cQuery += "VDT.VDT_DATMOV>='"+dtos(aParamet[3])+"' AND VDT.VDT_DATMOV<='"+dtos(aParamet[4])+"' AND "
		If !Empty(aParamet[5])
			cQuery += "VDT.VDT_USUMOV='"+aParamet[5]+"' AND "
		EndIf
		cQuery += "VDT.D_E_L_E_T_=' ' GROUP BY VDT.VDT_CODMOT , VS0.VS0_DESMOT"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		nColors := 0
		While !( cQAlSQL )->( Eof() )
			aAdd(aMotivos,{( cQAlSQL )->( VDT_CODMOT ),( cQAlSQL )->( VS0_DESMOT ),( cQAlSQL )->( QTDE ),"NADA"})
			aMotivos[1,3] += ( cQAlSQL )->( QTDE )
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		aSort(aMotivos,1,,{|x,y| strzero(x[3],15)+x[1] > strzero(y[3],15)+y[1] }) // Ordem decrescente
		For ni := 2 to len(aMotivos)
			nColors++
			If nColors > len(aLegend)
				nColors := len(aLegend)
			EndIf
			aMotivos[ni,4] := aLegend[nColors]
		Next
	EndIf
	If lRefresh
		oMotivos:nAt := 1
		oMotivos:SetArray(aMotivos)
		oMotivos:bLine := { || { &("o"+aMotivos[oMotivos:nAt,4]) , IIf(oMotivos:nAt<>1,aMotivos[oMotivos:nAt,1]+" - ","")+aMotivos[oMotivos:nAt,2] , FG_AlinVlrs(Transform(aMotivos[oMotivos:nAt,3],"@E 999,999")) , FG_AlinVlrs(Transform((aMotivos[oMotivos:nAt,3]/aMotivos[1,3])*100,"@E 999.9")+" %") }}
		oMotivos:Refresh()
		//
		nColors := 0
		FreeObj(oGrafic1)
		//oGrafic1 := TMSGraphic():New( aPosGraf[1],aPosGraf[2],oOFC500,,,RGB(239,239,239),aPosGraf[3],aPosGraf[4]-100)
		oGrafic1 := TMSGraphic():New( 010,010,oPan2_1,,,RGB(239,239,239),010,010)
		oGrafic1:Align := CONTROL_ALIGN_ALLCLIENT
		If len(aMotivos) > 1
			oGrafic1:SetTitle('% por Motivo', , CLR_BLACK, A_LEFTJUST, GRP_TITLE )
		EndIf
		oGrafic1:SetMargins(0,0,0,0)
		oGrafic1:SetLegenProp(3,CLR_LIGHTGRAY,1,.f.)
		nSerGraf := oGrafic1:CreateSerie( 10 ) // GRP_PIE=10 // PIZZA
		nDemais := 0
		For ni := 2 to len(aMotivos)
			nColors++
			If nColors >= len(aColors)
				nDemais += aMotivos[ni,3]
			Else
				oGrafic1:Add(nSerGraf, round((aMotivos[ni,3]/aMotivos[1,3])*100,1) , "" , aColors[nColors] )
			EndIf
		Next
		If nDemais > 0
			oGrafic1:Add(nSerGraf, round((nDemais/aMotivos[1,3])*100,1) , "" , aColors[len(aColors)] )
		EndIf
		//
		nColors := 0
		FreeObj(oGrafic2)
		//oGrafic2 := TMSGraphic():New( aPosGraf[3]-102,aPosGraf[2],oOFC500,,,RGB(239,239,239),aPosGraf[3],103)
		oGrafic2 := TMSGraphic():New( 010,010,oPan2_2,,,RGB(239,239,239),010,010)
		oGrafic2:Align := CONTROL_ALIGN_ALLCLIENT
		oGrafic2:SetMargins(0,0,0,0)
		oGrafic2:SetLegenProp(3,CLR_LIGHTGRAY,1,.f.)
		nDemais := 0
		For ni := 2 to len(aMotivos)
			nColors++
			If nColors >= len(aColors)
				nDemais += aMotivos[ni,3]
			Else
				nSerGraf := oGrafic2:CreateSerie( 4 ) // GRP_BAR=4 // BARRAS
				oGrafic2:Add(nSerGraf, aMotivos[ni,3] , "Qtde por Motivo" , aColors[nColors] )
			EndIf
		Next
		If nDemais > 0
			nSerGraf := oGrafic2:CreateSerie( 4 ) // GRP_BAR=4 // BARRAS
			oGrafic2:Add(nSerGraf, nDemais , "Qtde por Motivo" , aColors[len(aColors)] )
		EndIf
		//
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DBLCLICKบ Autor ณ Andre Luis Almeida บ Data ณ  09/12/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Duplo Clique no listbox dos Motivos (trazer analitico)     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DBLCLICK(nLinha,lMostraTel)
Local aObjects   := {} , aInfo := {} , aPos := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor    := 0
Local cQuery     := ""
Local cQAlSQL    := "SQLQUERY"
Local aQuest     := {}
//
Default lMostraTel   := .t. // 
//
If aMotivos[nLinha,3] <= 0
	Return()
EndIf
//
aOrigem    := {}
//
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // Origem
aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // Questionario
aPos := MsObjSize( aInfo, aObjects )
//
cQuery := "SELECT DISTINCT VDT.VDT_TIPASS , VDT.VDT_TIPORI , VDT.VDT_FILORI , VDT.VDT_CODORI , VDT.VDT_DATMOV , VDT.VDT_HORMOV , VDT.VDT_USUMOV , VDT.VDT_CODMOT , VS0.VS0_DESMOT "
cQuery += "FROM "+RetSqlName("VDT")+" VDT "
cQuery += "JOIN "+RetSqlName("VS0")+" VS0 ON ( VS0.VS0_FILIAL='"+xFilial("VS0")+"' AND VS0.VS0_TIPASS=VDT.VDT_TIPASS AND VS0.VS0_CODMOT=VDT.VDT_CODMOT AND VS0.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VDT.VDT_FILIAL='"+xFilial("VDT")+"' AND "
cQuery += "VDT.VDT_TIPASS='"+aParamet[1]+"' AND "
If nLinha > 1
	cQuery += "VDT.VDT_CODMOT='"+aMotivos[nLinha,1]+"' AND "
EndIf
If !Empty(aParamet[2])
	cQuery += "VDT.VDT_FILORI='"+aParamet[2]+"' AND "
EndIf
cQuery += "VDT.VDT_DATMOV>='"+dtos(aParamet[3])+"' AND VDT.VDT_DATMOV<='"+dtos(aParamet[4])+"' AND "
If !Empty(aParamet[5])
	cQuery += "VDT.VDT_USUMOV='"+aParamet[5]+"' AND "
EndIf
cQuery += "VDT.D_E_L_E_T_=' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	aAdd(aOrigem,{	( cQAlSQL )->( VDT_TIPORI ) ,;
					( cQAlSQL )->( VDT_FILORI ) ,;
					( cQAlSQL )->( VDT_CODORI ) ,;
					stod(( cQAlSQL )->( VDT_DATMOV )) ,;
					( cQAlSQL )->(  VDT_HORMOV ) ,;
					( cQAlSQL )->( VDT_USUMOV ) ,;
					( cQAlSQL )->( VDT_CODMOT )+" - "+( cQAlSQL )->( VS0_DESMOT ) ,;
					( cQAlSQL )->( VDT_TIPASS ) })
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
//
If lMostraTel 
	DEFINE MSDIALOG oOFC500Mot FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE substr(aTpAssun[Ascan(aTpAssun,aParamet[1])],8) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
		@ aPos[1,1],aPos[1,2] LISTBOX oOrigem FIELDS HEADER STR0009,STR0002,STR0010,STR0011,STR0012,STR0005,STR0007 COLSIZES 70,65,40,35,23,65,120 SIZE aPos[1,4]-2,aPos[1,3]-aPos[1,1] OF oOFC500Mot PIXEL ON DBLCLICK FS_VERORIG(aOrigem,oOrigem:nAt) ON CHANGE FS_LEVQUEST(IIf(nLinha>1,aMotivos[nLinha,1],""),aOrigem,oOrigem:nAt,@aQuest)
		oOrigem:SetArray(aOrigem)
		oOrigem:bLine := { || { X3CBOXDESC("VDT_TIPORI",aOrigem[oOrigem:nAt,1]) , aOrigem[oOrigem:nAt,2] , aOrigem[oOrigem:nAt,3] , Transform(aOrigem[oOrigem:nAt,4],"@D") , Transform(aOrigem[oOrigem:nAt,5],"@R 99:99") , UPPER(left(UsrRetName(aOrigem[oOrigem:nAt,6]),15)) , aOrigem[oOrigem:nAt,7] }}

		@ aPos[2,1],aPos[2,2] LISTBOX oQuest FIELDS HEADER STR0013,STR0014 COLSIZES 150,300 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1] OF oOFC500Mot PIXEL
		oQuest:SetArray(aQuest)
		oQuest:bLine := { || { aQuest[oQuest:nAt,1] , aQuest[oQuest:nAt,2] }}
		//
	ACTIVATE MSDIALOG oOFC500Mot CENTER ON INIT EnchoiceBar(oOFC500Mot,{ || oOFC500Mot:End() }, { || oOFC500Mot:End() },,)
Endif
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_LEVQUESTบ Autor ณ Andre Luis Almeida บ Data ณ  09/12/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Levanta Questionario ( Perguntas e Respostas )             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LEVQUEST(cCodMot,aOrigem,nLinha,aQuest)
Local cQuery  := ""
Local cQAlSQL := "SQLQUERY"
//
aQuest := {} // Questionario do Motivo
//
cQuery := "SELECT VDS.VDS_CPOTIT , VDT.VDT_RESPOS "
cQuery += "FROM "+RetSqlName("VDT")+" VDT , "+RetSqlName("VDS")+" VDS "
cQuery += "WHERE VDT.VDT_FILIAL='"+xFilial("VDT")+"' AND "
cQuery += "VDT.VDT_TIPASS='"+aParamet[1]+"' AND "
If !Empty(cCodMot)
	cQuery += "VDT.VDT_CODMOT='"+cCodMot+"' AND "
EndIf
cQuery += "VDT.VDT_DATMOV>='"+dtos(aParamet[3])+"' AND VDT.VDT_DATMOV<='"+dtos(aParamet[4])+"' AND "
If !Empty(aParamet[5])
	cQuery += "VDT.VDT_USUMOV='"+aParamet[5]+"' AND "
EndIf
cQuery += "VDT.VDT_TIPORI='"+aOrigem[nLinha,1]+"' AND "
cQuery += "VDT.VDT_FILORI='"+aOrigem[nLinha,2]+"' AND "
CQuery += "VDT.VDT_CODORI='"+aOrigem[nLinha,3]+"' AND "
cQuery += "VDT.D_E_L_E_T_=' ' AND "
cQuery += "VDS.VDS_FILIAL='"+xFilial("VDS")+"' AND VDS.VDS_TIPASS=VDT.VDT_TIPASS AND VDS.VDS_CODMOT=VDT.VDT_CODMOT AND VDS.VDS_CPOCOD=VDT.VDT_CPOCOD AND VDS.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	aAdd(aQuest,{ ( cQAlSQL )->( VDS_CPOTIT ) , ( cQAlSQL )->( VDT_RESPOS ) })
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
//
If len(aQuest) <= 0
	aAdd(aQuest,{ "" , "" })
EndIf
oQuest:nAt := 1
oQuest:SetArray(aQuest)
oQuest:bLine := { || { aQuest[oQuest:nAt,1] , aQuest[oQuest:nAt,2] }}
oQuest:Refresh()
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_VERORIGบ Autor ณ Andre Luis Almeida บ Data ณ  09/12/13  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Duplo Clique para ver Origem ( VISUALIZA )                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VERORIG(aOrigem,nLinha)
Private aCampos   := {}
Private cCadastro := X3CBOXDESC("VDT_TIPORI",aOrigem[nLinha,1]) 
If Empty(aOrigem[nLinha,3])
	Return()
EndIf
//
Inclui := .f.
Altera := .f.
//
Do Case 

	Case aOrigem[nLinha,1] == "1" // 1=Atendimento 
		DbSelectArea("VV9")
		DbSetOrder(1)
		If DbSeek( aOrigem[nLinha,2] + left(aOrigem[nLinha,3],TamSX3("VV9_NUMATE")[1]) )
			If !FM_PILHA("VEIXX002") .and. !FM_PILHA("VEIXX030")
				VEIXX002(NIL,NIL,NIL,2,)
			EndIf
		EndIf
		
	Case aOrigem[nLinha,1] == "2" // 2=OS 
		DbSelectArea("VO1")
		DbSetOrder(1)
		If DbSeek( aOrigem[nLinha,2] + left(aOrigem[nLinha,3],TamSX3("VO1_NUMOSV")[1]) )
			OC060("VO1",VO1->(Recno()),2)
		EndIf
	
	Case aOrigem[nLinha,1] == "3" // 3=Agendamento
		DbSelectArea("VSO")
		DbSetOrder(1)
		If DbSeek( aOrigem[nLinha,2] + left(aOrigem[nLinha,3],TamSX3("VSO_NUMIDE")[1]) )
			OM350V("VSO",VSO->(recno()),2)	
		Endif
			
	Case aOrigem[nLinha,1] == "4" // 4=Orcamento
		DbSelectArea("VS1")
		DbSetOrder(1)
		If DbSeek( aOrigem[nLinha,2] + left(aOrigem[nLinha,3],TamSX3("VS1_NUMORC")[1]) )
			OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
		EndIf
	
	Case aOrigem[nLinha,1] == "5" // 5=CEV
		DbSelectArea("VC1")
		DbSetOrder(1)
		DbGoto(val(aOrigem[nLinha,3]))
		ML500V("VC1",VC1->(RecNo()),2)
	
	Case aOrigem[nLinha,1] == "6" // 6=Oportunidade
		If aOrigem[nLinha,8] == "000011" // Veiculos/Maquinas
			DbSelectArea("VDM")
			DbSetOrder(2)
			If DbSeek( aOrigem[nLinha,2] + left(aOrigem[nLinha,3],TamSX3("VDM_CODINT")[1]) )
				DbSelectArea("VDL")
				DbSetOrder(1)
				If DbSeek( VDM->VDM_FILIAL + VDM->VDM_CODOPO )
					VCM680("VDL",VDL->(RecNo()),2,)
				EndIf
			EndIf
		ElseIf aOrigem[nLinha,8] == "000021" // Pecas Balcao
			DbSelectArea("VDQ")
			DbSetOrder(1)
			If DbSeek( aOrigem[nLinha,2] + left(aOrigem[nLinha,3],TamSX3("VDQ_CODOPO")[1]+TamSX3("VDQ_CODINT")[1]) )
				DbSelectArea("VDL")
				DbSetOrder(1)
				If DbSeek( VDQ->VDQ_FILIAL + VDQ->VDQ_CODOPO )
					OA1000011_Executar(2,.f.)
				EndIf
			EndIf
		ElseIf aOrigem[nLinha,8] == "000022" // Pecas/Servicos Oficina
			DbSelectArea("VDI")
			DbSetOrder(1)
			If DbSeek( aOrigem[nLinha,2] + left(aOrigem[nLinha,3],TamSX3("VDI_CODOPO")[1]+TamSX3("VDI_CODINT")[1]) ) // PECAS
				DbSelectArea("VDL")
				DbSetOrder(1)
				If DbSeek( VDI->VDI_FILIAL + VDI->VDI_CODOPO )
					OA1100011_Executar(2,.f.)
				EndIf
			Else
				DbSelectArea("VDJ")
				DbSetOrder(1)
				If DbSeek( aOrigem[nLinha,2] + left(aOrigem[nLinha,3],TamSX3("VDJ_CODOPO")[1]+TamSX3("VDJ_CODINT")[1]) ) // SERVICOS
					DbSelectArea("VDL")
					DbSetOrder(1)
					If DbSeek( VDJ->VDJ_FILIAL + VDJ->VDJ_CODOPO )
						OA1100011_Executar(2,.f.)
					EndIf
				EndIf
			EndIf
		EndIf
	Case aOrigem[nLinha,1] == "7" // 7=Comissao Fat.Direto
		DbSelectArea("VQ2")
		DbSetOrder(1)
		If DbSeek( aOrigem[nLinha,2] + left(aOrigem[nLinha,3],TamSX3("VQ2_CODIGO")[1]) )  
			OC500VQ2()
		    AxVisual("VQ2",VQ2->(RecNo()),2,aCampos)
		EndIf
	Case aOrigem[nLinha,1] == "8" // 8=Bonus de Veiculos
		DbSelectArea("VQ1")
		DbSetOrder(1)
		If DbSeek( aOrigem[nLinha,2] + left(aOrigem[nLinha,3],TamSX3("VQ1_CODIGO")[1]) )  
			OC500VQ1()
		    AxVisual("VQ1",VQ1->(RecNo()),2,aCampos)
		EndIf

EndCase 
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOC500VQ2  บAutor  ณ Thiago             บ Data ณ  16/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OC500VQ2()

DbSelectArea("SX3")
DbSetOrder(1)
dbseek("VQ2")
aCampos := {}

do While !Eof() .and. x3_arquivo == "VQ2"

   If X3USO(x3_usado).And.cNivel>=x3_nivel
      aadd(aCampos,x3_campo)
   EndIf   
      
   DbSkip()
   
EndDo

DbSelectArea("VQ2")
                                                                             
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOC500VQ1  บAutor  ณ Thiago             บ Data ณ  16/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OC500VQ1()

DbSelectArea("SX3")
DbSetOrder(1)
dbseek("VQ1")
aCampos := {}

do While !Eof() .and. x3_arquivo == "VQ1"

   If X3USO(x3_usado).And.cNivel>=x3_nivel
      aadd(aCampos,x3_campo)
   EndIf   
      
   DbSkip()
   
EndDo

DbSelectArea("VQ1")

Return

//
Static Function OR500ChmImp() 

Local oReport

oReport:= ReportDef() // Nesta fun็ใo nos definimos a estrutura do relat๓rio, por exemplo as se็๕es, campos, totalizadores e etc.
oReport:SetPortrait() // Define orienta็ใo de pแgina do relat๓rio como retrato.
oReport:PrintDialog() // Essa fun็ใo serve para disparar a impressใo do TReport,  ela que faz com que seja exibida a tela de configura็ใo de impressora e os bot๕es de parโmetros.
 
Return

Static Function ReportDef()
Local oSection1
Local oSection2
Local cPerg  := "OFC500"

cMotivo := ""
cQtdade := ""
cPercen := ""
cTipMot := ""
cfilMot := ""
cCodOri := ""
cDataMt := ""
cHoraMt := ""
cUsuari := ""
cMotiv2 := ""
//
Pergunte(cPerg,.t.)
lDetImp := (MV_PAR01==1)

//
oReport := TReport():New("OC500R","Consulta Motivos",,{|oReport| OC500Impr(oReport)})
// Motivos (Sint้tico)
oSection1 := TRSection():New(oReport,"Motivos",{"VDT"}) 
TRCell():New(oSection1,"MOTIVO","","Motivo"    ,"@!" ,40,,{|| cMotivo },,,,.t.)
TRCell():New(oSection1,"QTDADE","","Quantidade","@!" , 6,,{|| cQtdade },,,,.t.)
TRCell():New(oSection1,"PERCEN",""," % "       ,"@!" , 6,,{|| cPercen },,,,.t.)

// Detalhes
oSection2 := TRSection():New(oReport,"Origem")  
TRCell():New(oSection2,"TIPMOT","","Tipo"      ,"@!" ,20,,{|| cTipMot },,,,.t.)
TRCell():New(oSection2,"FILMOT","","Filial"    ,"@!" ,09,,{|| cFilMot },,,,.t.)
TRCell():New(oSection2,"CODORI","","C๓digo"    ,"@!" ,10,,{|| cCodOri },,,,.t.)
TRCell():New(oSection2,"DATAMT","","Data"      ,"@!" ,10,,{|| cDataMt },,,,.t.)
TRCell():New(oSection2,"HORAMT","","Hora"      ,"@!" ,08,,{|| cHoraMt },,,,.t.)
TRCell():New(oSection2,"USUARI","","Usuแrio"   ,"@!" ,15,,{|| cUsuari },,,,.t.)
TRCell():New(oSection2,"MOTIV2","","Motivo"    ,"@!" ,30,,{|| cMotiv2 },,,,.t.)

Return oReport

//
Static Function OC500Impr(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local nImp      := 0
Local nImpDet := 0

For nImp := 2 to Len(aMotivos)
	oSection1:Init()
	FS_DBLCLICK(nImp,.f.)
	cMotivo := aMotivos[nImp,2]
	cQtdade := Transform((aMotivos[nImp,3]),"@E 99999")
	cPercen	:= Transform((aMotivos[nImp,3]/aMotivos[1,3])*100,"@E 9999.99")
	oSection1:PrintLine()
	If lDetImp
		oSection2:Init()
		For nImpDet := 1 to Len(aOrigem)
			cTipMot	:= aOrigem[nImpDet,1]
			cfilMot	:= aOrigem[nImpDet,2]
			cCodOri	:= aOrigem[nImpDet,3]
			cDataMt	:= aOrigem[nImpDet,4]
			cHoraMt	:= Transform(aOrigem[nImpDet,5],"@R 99:99")
			cUsuari	:= aOrigem[nImpDet,6]
			cMotiv2	:= aOrigem[nImpDet,7]
			oSection2:PrintLine()
		Next
		oSection2:Finish()
	Endif
	oSection1:Finish()
Next
  	
Return


