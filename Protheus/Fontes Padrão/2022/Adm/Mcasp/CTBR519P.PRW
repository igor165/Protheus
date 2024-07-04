#INCLUDE "TOTVS.CH"
#INCLUDE "CTBR519P.CH"

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} CTBR519P
	Projeção Atuarial do RPPS
    @author     TOTVS
    @since      25/11/2020
    @version    P12
/*/

Function CTBR519P()
Local aArea		:= GetArea()
Local cPerg	   	:= "CTBR519P" 

Private dData		:= Date()
Private oReport, oSection1, oSection2
Private nRegistro	:= 0
Private nTmpMedMov	:= 0
Private nContMed	:= 0
Private nTmpEspera	:= 0
Private nQtdReprov	:= 0
Private nQtdCanc	:= 0
Private cCdOper 	:= ""
Private cSeqOper 	:= ""
Private cDsConf 	:= ""
Private cFilMov		:= ""
Private cNrMov		:= ""
Private lTabTemp	:= .F.
Private cTabRel		:= "TMP"
Private oTempTable

/*PERGUNTE
MV_PAR01 - Ano-Exercício ?
MV_PAR02 - Periodo-Bimestre ?
*/
SX1->(dbSetOrder(1))

If !SX1->(dbSeek(Padr(cPerg, Len(SX1->X1_GRUPO), " ")))
    Help(,, "Help",, OemToAnsi(STR0004), 1, 0) //"Para utilizaçao do relatorio de Projeção Atuarial do RPPS é necessário aplicar o pacote acumulado da controladoria."
    lRet := .F.
Else 
    //Perguntas do Relatório
    lRet := Pergunte(cPerg, .T.) 
EndIf  

If FindFunction("TRepInUse") .And. TRepInUse()
	oReport:= ReportDef()
	oReport:PrintDialog()			
EndIf

RestArea( aArea )

//---------------------------------
// Exclui a tabela  
//---------------------------------

If lTabTemp
	(cTabRel )->( DbCloseArea() )
Endif

Return

Static Function ReportDef()     

Local aOrdem        := {}
Local cTitulo       := DecodeUTF8(STR0013, "cp1252")       //"Projeção Atuarial do RPPS"
Local cTitulo1      := DecodeUTF8(STR0013, "cp1252")       //"Projeção Atuarial do RPPS"
Local cNomeRel      := "CTBR519P"

oReport:= TReport():New(cNomeRel,cTitulo , , {|oReport| ReportPrint(oReport)},cTitulo1)
oReport:SetLandscape(.T.)   // Define a orientação de página do relatório como paisagem  ou retrato. .F.=Retrato; .T.=Paisagem
oReport:SetTotalInLine(.T.) // Define se os totalizadores serão impressos em linha ou coluna
oReport:HideParamPage()   	// Desabilita a impressao da pagina de parametros

oReport:nFontBody := 7

Aadd( aOrdem, cTitulo ) 
/*
	Seção "Oculta" necessária pois o botão "Gestão de Empresas" somente aparece se houver uma tabela padrão do dicionário.
*/
oSection1:= TRSection():New(oReport,"-",{"(cTabRel)"},{"-"}) 
oSection1:Hide()
oSection1:Disable()
oSection1:lReadOnly 	:= .T.
oSection1:lUserVisible	:= .F.

oSection2:= TRSection():New(oReport,cTitulo,{"(cTabRel)"},aOrdem, , , , , , .T.) 
oSection2:SetTotalInLine(.T.)
oSection2:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção
oSection2:SetHeaderBreak(.T.)

TRCell():New(oSection2,"(cTabRel)->QL8_ANOREF"							,"(cTabRel)"	,STR0016    ,"9999"/*Picture*/						,TamSX3("QL8_ANOREF")[1]/*Tamanho*/	,/*lPixel*/	,/*{|| code-block de impressao }*/,,,,,30)
TRCell():New(oSection2,"(cTabRel)->QL8_VALREC"							,"(cTabRel)"    ,STR0017    ,"@E 9,999,999,999,999.99"/*Picture*/	,TamSX3("QL8_VALREC")[1]/*Tamanho*/	,/*lPixel*/	,/*{|| code-block de impressao }*/,,,,,12)
TRCell():New(oSection2,"(cTabRel)->QL8_VALDES"							,"(cTabRel)"    ,STR0018    ,"@E 9,999,999,999,999.99"/*Picture*/	,TamSX3("QL8_VALDES")[1]/*Tamanho*/	,/*lPixel*/	,/*{|| code-block de impressao }*/,,,,,12)
TRCell():New(oSection2,"(cTabRel)->QL8_VALREC-(cTabRel)->QL8_VALDES"	,"(cTabRel)"	,STR0019    ,"@E 9,999,999,999,999.99"/*Picture*/	,TamSX3("QL8_VALREC")[1]/*Tamanho*/	,/*lPixel*/	,/*{|| code-block de impressao }*/,,,,,12)

/*
    Exercício: 2019
    Periodicidade: BIMESTRAL
    Período: 6º bimestre

    "Grupo: Tabela 10 - Demonstrativo da Projeção Atuarial do Regime Próprio de 
    Previdência dos Servidores "
    Quadro: Projeção Atuarial do RPPS - Plano Previdenciário 
    Rótulo: Padrão 
*/

oQuadro1 := TRSection():New(oReport, STR0005, {}, /*aOrdem*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ ,/*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , /*<lLineBreak>*/ , /*<nLeftMargin>*/ , .T./*<lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 0 /*<nLinesBefore>*/ , 1/*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ ) //"Quadro I"
TRCell():New(oQuadro1, "EXERCICIO"    ,, STR0005,, 80, /*lPixel*/, {||Alltrim(MV_PAR01)}           ,,,,,,,,, .T.)   // "Exercicio"" ####""
TRCell():New(oQuadro1, "PERIODICIDADE",, STR0006,, 80, /*lPixel*/, {||STR0007 }					   ,,,,,,,,, .T.)   // "Periodicidade "Bimestral"
TRCell():New(oQuadro1, "PERIODO"      ,, STR0008,, 80, /*lPixel*/, {||Alltrim(MV_PAR02)+STR0009}   ,,,,,,,,, .T.)   // "Período"" ##"o. Quadrimestre"
//TRCell():New(oQuadro1, "BRANCO"       ,, ""     ,, 80, /*lPixel*/, {||""}                          ,,,,,,,,, .T.)
TRCell():New(oQuadro1, "GRUPO"        ,, STR0010,, 80, /*lPixel*/, {||STR0011}                     ,,,,,,,,, .T.)   // "Grupo"  + "Tabela 10 - Demonstrativo da Projeção Atuarial do Regime Próprio de Previdência dos Servidores"
TRCell():New(oQuadro1, "QUADRO"       ,, STR0012,, 80, /*lPixel*/, {||STR0013}					   ,,,,,,,,, .T.)   // "Quadro" + "Projeção Atuarial do RPPS - Plano Previdenciário"
TRCell():New(oQuadro1, "ROTULO"       ,, STR0014,, 80, /*lPixel*/, {||STR0015}                     ,,,,,,,,, .T.)   // "Rótulo" + "Padrão"

Return(oReport)
 
Static Function ReportPrint(oReport)
Local oSection2 := oReport:Section(2) 
Local oQuadro1  := oReport:Section(3)

Local aGCList   := {}
Local cTabRel	:= "TMP"
Local cSelect   := ""
Local cQuery    := ""
Local xFilial	:= FwxFilial("QL8") 

If Empty(MV_PAR01)
    cAno := cValToChar(Year(dDataBase))
EndIf

If Empty(MV_PAR02)

EndIf

aGCList := oReport:GetGCList()	// Função retorna array com filiais que o usuário tem acesso

cQuery := "SELECT	QL8_FILIAL," 						+ ENTER
cQuery += "			QL8_ANOREF," 						+ ENTER
cQuery += "			QL8_CODBIM ," 						+ ENTER
cQuery += "			SUM(QL8_VALREC) QL8_VALREC ,"		+ ENTER
cQuery += "			SUM(QL8_VALDES) QL8_VALDES " 		+ ENTER
cQuery += "	FROM "+RETSQLNAME("QL8")+ " QL8"			+ ENTER
cQuery += "	WHERE	D_E_L_E_T_ =' '" 					+ ENTER
cQuery += "		AND	QL8_FILIAL = '" + xFilial + "'" 	+ ENTER
cQuery += "	AND	( ( QL8_ANOREF = '"  + MV_PAR01	+ "' AND QL8_CODBIM = '" + MV_PAR02 + "' ) OR " 	+ ENTER
cQuery += "	( QL8_ANOREF > '"  + MV_PAR01	+ "' AND QL8_CODBIM = '6' ) ) "	+ ENTER
cQuery += "	GROUP BY QL8_FILIAL,QL8_ANOREF,QL8_CODBIM"	+ ENTER

// Seta regua de processamento
cSelect := 	ChangeQuery(cQuery)

Memowrite('CTBR519P.SQL',cSelect)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSelect),cTabRel,.F.,.T.)

IF SELECT(cTabRel)==0
	MsgStop("Nao conseguiu abrir a tabela")
	return
ENDIF

oQuadro1:Init()
oQuadro1:PrintLine()
oQuadro1:Finish()
oReport:ThinLine()

//----------------------------------------------------------
// Seta regua de processamento
//----------------------------------------------------------
DbSelectArea(cTabRel)
oReport:SetMeter((cTabRel)->(LastRec()))
oSection2:Init()
(cTabRel)->(dbGoTop())
While !oReport:Cancel() .And. (cTabRel)->(!Eof())
	oSection2:PrintLine()
	(cTabRel)->(dbSkip())
EndDo
oSection2:Finish()
(cTabRel)->( DbCloseArea() )
Return

