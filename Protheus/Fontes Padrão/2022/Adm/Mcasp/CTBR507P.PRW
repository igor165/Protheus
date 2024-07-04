#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBR507P.CH"

#DEFINE C_DESC			1
#DEFINE C_SALDOATU		2
#DEFINE C_NIVEL    		3
#DEFINE C_TIPOCONTA		4
#DEFINE CCODFIL			2

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} CTBR507P
Imprime o relatório Margem de Expansao das Despesas Obrigatorias de Carater Continuado

@author TOTVS
@since 27/07/2020
@version 12.1.31
@return 
/*/
//---------------------------------------------------------------------------------------

Function CTBR507P()

Local cPerg	   		:= "CTR507P"
Local cFindSX1 		:= Padr(cPerg, Len(SX1->X1_GRUPO), " ")
Local aSetOfBook	:= {}
Local aCtbMoeda		:= {}
Local aSelFil		:= {}
Local lContinua     := .T.     

//Valida perguntas
If !SX1->(dbSeek(cFindSX1))
    Help(,, "Help",, OemToAnsi(STR0001), 1, 0) //"Para utilizacao do relatório Margem de Expansao das Despesas Obrigatórias de Caráter Continuado é necessário aplicar o pacote acumulado da controladoria."
	lContinua := .F.
Else
	lContinua := Pergunte(cPerg,.T.) 
Endif

//Faz a validacao das filiais
If lContinua .And. MV_PAR06 == 1 .And. Len(aSelFil) <= 0 
	aSelFil := AdmGetFil()
	
	If Len(aSelFil) <= 0
		lContinua := .F.
	EndIf                     
EndIf

//Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano
//Gerencial -> montagem especifica para impressao) faz a validação do livro
If lContinua .And. !Empty(MV_PAR02) 
	If !VdSetOfBook(MV_PAR02, .F.)
		lContinua := .F.
	EndIf
EndIf

If lContinua
	//Seta o livro
	aSetOfBook := CTBSetOf(MV_PAR02)

	//Seta a moeda
	aCtbMoeda := CtbMoeda(MV_PAR03, aSetOfBook[9])

	If Empty(aCtbMoeda[1])
		Help(" ", 1, "NOMOEDA")
		lContinua := .F.
	EndIf	

	If lContinua        
		oReport := ReportDef(cPerg, aSelFil) 
		oReport:PrintDialog()
	EndIf	      
EndIf

Return Nil

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Esta funcao tem como objetivo definir as secoes, celulas,
totalizadores do relatorio que poderao ser configurados pelo relatorio.

@author TOTVS
@since 27/07/2020
@version 12.1.31
@return oReport - Objeto da classe TReport
/*/
//---------------------------------------------------------------------------------------

Static Function ReportDef(cPerg, aSelFil)  

Local aArea	   		:= GetArea()   
Local cReport		:= "CTBR507P"
Local cTitulo		:= ""
Local cDesc			:= STR0002 //"Este programa ira imprimir o Relatório, de acordo com os parâmetros informados pelo usuário."
Local nTamDesc		:= TAMSX3("CTS_DESCCG")[1]  
Local nTamVal		:= TAMSX3("CT2_VALOR")[1]
Local cAnoRef  		:= ""
Local aSetOfBook	:= CTBSetOf(MV_PAR02) 

//Ano de Referencia
CTG->(dbSetOrder(1)) //CTG_FILIAL+CTG_CALEND+CTG_EXERC+CTG_PERIOD
If CTG->(dbSeek(xFilial("CTG") + mv_par01))
	cAnoRef := CTG->CTG_EXERC
EndIf

//__________________________________________________________________________
// Criacao do componente de impressao                                       |
//                                                                          |
// TReport():New                                                            |
// ExpC1 : Nome do relatorio                                                |
// ExpC2 : Titulo                                                           |
// ExpC3 : Pergunte                                                         |
// ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao   |
// ExpC5 : Descricao                                                        |
//__________________________________________________________________________|

oReport	:= TReport():New(cReport, cTitulo, cPerg,;
	{|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport, @cTitulo, cAnoRef, aSetOfBook, aSelFil), .T., oReport:CancelPrint())}, CDesc)
oReport:SetCustomText({|| CtCGCCabTR(,,,,, dDataBase, ctitulo,,,,, oReport)})                                        		
oReport:ParamReadOnly()

If GetNewPar("MV_CTBPOFF", .T.)
	oReport:SetEdit(.F.)
EndIf	

//Configuracoes de impressao
oReport:nFontBody   := 9 //Define o tamanho da fonte
oReport:nLineHeight	:= 45 //Define a altura da linha.

//_________________________________________________________________________
// Criacao da secao utilizada pelo relatorio                               |
//                                                                         |
// TRSection():New                                                         |
// ExpO1 : Objeto TReport que a secao pertence                             |
// ExpC2 : Descricao da seçao                                              |
// ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   |
//         sera considerada como principal para a seção.                   |
// ExpA4 : Array com as Ordens do relatório                                |
// ExpL5 : Carrega campos do SX3 como celulas                              |
//         Default : False                                                 |
// ExpL6 : Carrega ordens do Sindex                                        |
//         Default : False                                                 |
//_________________________________________________________________________|

oSecTit := TRSection():New(oReport, "SECTIT")
TRCell():New(oSecTit, "TITULO",, "" /*Titulo*/, /*Picture*/, 100 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "CENTER" /*cAlign*/, /*lLineBreak*/,,,, .T.)

oSection1 := TRSection():New(oReport, "DETALHE", {"cArqTmp"},, .F., .F.) 
TRCell():New(oSection1, "EVENTOS"    ,, "" /*Titulo*/, /*Picture*/, nTamDesc /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "LEFT"/*cAlign*/ , .T. /*lLineBreak*/, "LEFT" ,,, .T.)
TRCell():New(oSection1, "VALPREVISTO",, "" /*Titulo*/, /*Picture*/, nTamVal  /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT"/*cAlign*/, /*lLineBreak*/    , "RIGHT",,, .T.)
oSection1:SetTotalInLine(.F.)

RestArea(aArea)
           
Return oReport

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Imprime o relatorio definido pelo usuario de acordo com as secoes/celulas criadas na 
funcao ReportDef definida acima.
Nesta funcao deve ser criada a query das secoes se SQL ou definido o relacionamento e 
filtros das tabelas em CodeBase.

@author TOTVS
@since 27/07/2020
@version 12.1.31
@return .T.
/*/
//---------------------------------------------------------------------------------------

Static Function ReportPrint(oReport, cTitulo, cAnoRef, aSetOfBook, aSelFil)  

Local oSecTit       := oReport:Section("SECTIT")
Local oSection1 	:= oReport:Section("DETALHE")  
Local cArqTmp      	:= "" 
Local cPicture		:= ""
Local nLinha		:= 0                                     
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nI 			:= 0
Local cMoeda        := MV_PAR03
Local cTpSld        := "2"
Local dDataIni      := StoD("")
Local dDataFin      := StoD("")
Local oHashLin      := tHashMap():New()
Local aCtbMoeda		:= {}
Local aLinhas		:= {}
Local aLinAux       := {}
Local aTotNvel1     := {}
Local aTotNvel2     := {}
Local aMargLiq		:= {}
Local nNivelOld     := 0
Local nDivide		:= 1
Local lRet			:= .T.

Private lComNivel	:= .T. //Variável utilizada no CTBXSAL para retornar o campo NIVEL

If Empty(aSetOfBook[5])
	MsgAlert(STR0003)  //"Os demonstrativos contabeis obrigatoriamente devem ter um plano gerencial associado ao livro. Verifique a configuracao de livros escolhida !"
	lRet := .F.
Else
	If MV_PAR04 == 2		//Divide por cem
		nDivide := 100	
	ElseIf MV_PAR04 == 3	//Divide por mil
		nDivide := 1000
	ElseIf MV_PAR04 == 4	//Divide por milhao
		nDivide := 1000000
	EndIf	

	aSetOfBook[9] := nDivide
	aCtbMoeda := CtbMoeda(cMoeda, nDivide)
	nDecimais := DecimalCTB(aSetOfBook, cMoeda)
	cPicture := aSetOfBook[4]

	If Empty(cPicture)
		cPicture := "@E " + TmContab(0, aTamVal[1], nDecimais)
	EndIf

	cArqTmp  := ""
	dDataIni := SToD(cAnoRef + "0101")
	dDataFin := SToD(cAnoRef + "1231") 

	//Monta Arquivo Temporario para Impressao
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerPlan(	oMeter, oText, oDlg, @lEnd, @cArqTmp,;
							dDataIni, dDataFin, "", "", "", Repl("Z", Len(CT1->CT1_CONTA)),;
							"", Repl("Z", Len(CTT->CTT_CUSTO)), "", Repl("Z", Len(CTD->CTD_ITEM)),;
							"", Repl("Z", Len(CTH->CTH_CLVL)), cMoeda,;
							cTpSld, aSetOfBook, Space(2), Space(20), Repl("Z", 20), Space(30);
							,,,,,,, nDivide,,,,,,,,,,,,,,,,,,,,,,,,,, cMoeda,, aSelFil)},;
							STR0004 + cValToChar(Year(dDataIni)), cTitulo)  //"Carregando valores de "

	dbSelectArea("cArqTmp")
	dbGoTop()

	While !Eof()
		If !oHashLin:Get(CONTA, @aLinAux)            
			HMSet(oHashLin, CONTA, { DESCCTA,;	  //[1]
									 SALDOATU,;   //[2]
									 NIVEL,;	  //[3]
									 TIPOCONTA }) //[4]
		EndIf

		DbSkip()
	EndDo
		
	DbSelectArea("cArqTmp")
	Set Filter To
	dbCloseArea() 

	If Select("cArqTmp") == 0
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIF	

	aTamVal[1] += 8

	HMList(oHashLin, @aLinhas)

	aSort(aLinhas,,, {|x,y| x[1] < y[1]})

	C507ImpTit(oSecTit, cAnoRef, aCtbMoeda, nDivide)

	oSection1:Init()
	oSection1:Cell("EVENTOS"):SetBlock({|| STR0006}) //"EVENTOS"
	oSection1:Cell("VALPREVISTO"):SetBlock({|| STR0007}) //"VALOR PREVISTO"			
	oSection1:PrintLine()		
	oReport:ThinLine()
	
	aAdd(aMargLiq, {STR0005, 0}) //MARGEM LÍQUIDA DE EXPANSAO DE DOCC

	For nI := 1 To Len(aLinhas)
		nLinha := nI
	
		If aLinhas[nI, 2, C_NIVEL] == 1		
			aAdd(aTotNvel1, {aLinhas[nLinha, 2, C_DESC], aLinhas[nI, 2, C_SALDOATU]})
			
			//MARGEM LÍQUIDA DE EXPANSAO DE DOCC
			If AllTrim(aLinhas[nI][1]) == "1"
				aMargLiq[1][C_SALDOATU] += aLinhas[nI, 2, C_SALDOATU]
			Else
				aMargLiq[1][C_SALDOATU] -= aLinhas[nI, 2, C_SALDOATU]
			EndIf			
		ElseIf aLinhas[nI, 2, C_NIVEL] > 1 .And. aLinhas[nI, 2, C_TIPOCONTA] == "1"
			aAdd(aTotNvel2, {aLinhas[nLinha, 2, C_DESC], aLinhas[nI, 2, C_SALDOATU]})
		Else	
			oSection1:Cell("EVENTOS"):SetBlock({|| aLinhas[nLinha, 2, C_DESC]})
			oSection1:Cell("VALPREVISTO"):SetBlock({|| Transform(aLinhas[nI, 2, C_SALDOATU], PesqPict("CT2", "CT2_VALOR"))})
			oSection1:PrintLine()
		EndIf		

		nNivelOld := aLinhas[nI, 2, C_NIVEL]	
	Next nI

	If Len(aLinhas) > 0
		oReport:ThinLine()

		//Imprime Total Sintetica Nivel maior que 1
		C507ImpTot(oSection1, aTotNvel2)

		//Imprime Total Sintetica Nivel 1
		C507ImpTot(oSection1, aTotNvel1)

		//Imprime Total Margem Liquida
		C507ImpTot(oSection1, aMargLiq)
		
		oSection1:Finish()
	EndIf

	aSize(aTotNvel1, 0)
	aSize(aTotNvel2, 0)
	aSize(aMargLiq , 0)
	aSize(aLinhas  , 0)
	aSize(aCtbMoeda, 0)
		
	aTotNvel1 := Nil
	aTotNvel2 := Nil
	aMargLiq  := Nil
	aLinhas   := Nil
	aCtbMoeda := Nil
		
	oReport:EndPage()
EndIf

Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} C507ImpTit

Imprime o título do relatório

@author TOTVS
@since 27/07/2020
@version 12.1.31
@return nil
/*/
//---------------------------------------------------------------------------------------

Static Function C507ImpTit(oSecTit, cAnoRef, aCtbMoeda, nDivide)

Local cDescDiv := ""
Local cEnteUF  := IIF(!Empty(MV_PAR05), FWGetSX5("12", MV_PAR05)[1][4], "")

If nDivide > 1
	cDescDiv := " (" + STR0013 + cValToChar(nDivide) + ")" //"DIV. "
EndIf

oSecTit:Init()
oSecTit:Cell("TITULO"):SetBlock({|| STR0008 + cEnteUF}) //"GOVERNO DO ESTADO DE "
oSecTit:PrintLine()		
oSecTit:Cell("TITULO"):SetBlock({|| STR0009}) //"ANEXO DE METAS FISCAIS - DEMONSTRATIVO VIII"
oSecTit:PrintLine()		
oSecTit:Cell("TITULO"):SetBlock({|| STR0010}) //"MARGEM DE EXPANS?O DAS DESPESAS OBRIGATÓRIAS DE CARÁTER CONTINUADO"
oSecTit:PrintLine()			
oSecTit:Cell("TITULO"):SetBlock({|| STR0011 + cAnoRef + STR0012 + AllTrim(aCtbMoeda[2]) + cDescDiv}) //"MARGEM DE EXPANSAO DAS DESPESAS OBRIGATÓRIAS DE CARÁTER CONTINUADO"
oSecTit:PrintLine()	
oSecTit:Finish()

Return Nil

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} C507ImpTot

Imprime totais do relatório

@author TOTVS
@since 28/07/2020
@version 12.1.31
@return nil
/*/
//---------------------------------------------------------------------------------------

Static Function C507ImpTot(oSection1, aTotais)

Local nI := 0

For nI := 1 To Len(aTotais)
	oSection1:Cell("EVENTOS"):SetBlock({|| aTotais[nI, C_DESC]})
	oSection1:Cell("VALPREVISTO"):SetBlock( {|| Transform(aTotais[nI, C_SALDOATU], PesqPict("CT2", "CT2_VALOR"))})
	oSection1:PrintLine()	
Next nI

Return Nil