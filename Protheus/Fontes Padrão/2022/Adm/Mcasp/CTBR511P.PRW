// #Include "CTBR506P.ch"
#Include "CTBR511P.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} CTBR511P
Imprime o relatório Origem e Aplicação dos Recursos Obtidos com a Alienação de Ativos

@author TOTVS
@since 21/07/2020
@version 12.1.31
@return 
/*/
//---------------------------------------------------------------------------------------
Function CTBR511P()
	Local aSetOfBook	
	Local aCtbMoeda		:= {}
	Local lRet          := .T.
	Local nHandle       := 0

	PRIVATE cPerg	   	:= "CTR511P"//"CTR506P" //CTR511P
	Private nomeprog	:= "CTBR511P"       
	Private aSelFil		:={} 

	If !Pergunte(cPerg,.T.) 
		Return .F.
	Endif    
		
	// Faz a validacao das filiais
	If lRet .And. mv_par10 == 1 .And. Len( aSelFil ) <= 0 
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			lRet := .F.
		EndIf                             
	EndIf

	// Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano
	// Gerencial -> montagem especifica para impressao)
	// faz a validação do livro
	If lRet .And. !Empty( mv_par02 ) 
		If !VdSetOfBook( mv_par02, .F. )
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. (mv_par08==1)
		If Empty(mv_par09)
			MsgAlert(STR0001) //"O Arquivo com a nota explicativa não foi informado."
			lRet := .F.
		Else
			If (nHandle := FOpen(mv_par09, 3)) < 0
				MsgAlert(STR0015) //"O Arquivo de termo (.TRM) nao pode estar como somente leitura."
				lRet := .F.
			Else
				FClose(nHandle)
			EndIf
		EndIf
	EndIf

	If lRet
		// seta o livro
		aSetOfBook := CTBSetOf(mv_par02)

		// seta a moeda
		aCtbMoeda	:= CtbMoeda(mv_par03, aSetOfBook[9])

		If Empty(aCtbMoeda[1])
			Help(" ",1,"NOMOEDA")
			Return .F.
		EndIf	
				
		oReport := ReportDef() 

		oReport:PrintDialog()
			
	EndIf

Return
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Esta funcao tem como objetivo definir as secoes, celulas,
totalizadores do relatorio que poderao ser configurados pelo relatorio.

@author TOTVS
@since 21/07/2020
@version 12.1.31
@return oReport - Objeto da classe TReport
/*/
//---------------------------------------------------------------------------------------
Static Function ReportDef()  
local aArea	   		:= GetArea()   
Local cREPORT		:= "CTBR505P"
Local cTitulo		:= ""
Local cDESC			:= STR0002 //"Este programa ira imprimir o Relatório, de acordo com os parâmetros informados pelo usuário."
Local nTamDesc		:= TAMSX3("CTS_DESCCG")[1]  
Local nTamVal		:= TAMSX3("CT2_VALOR")[1]
Local cAnoRef  		:= mv_par01
Local aSetOfBook    := CTBSetOf(mv_par02)

//Filtra Filiais
If mv_par10 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
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

oReport	:= TReport():New( cReport,cTitulo,cPerg,;
	{ |oReport| Pergunte(cPerg,.F.), Iif(ReportPrint(oReport,@cTitulo,cAnoRef,aSetOfBook), .T., oReport:CancelPrint())}, CDESC)
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,ctitulo,,,,,oReport) } )                                        		
oReport:ParamReadOnly()

IF GetNewPar("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF	

// Define o tamanho da fonte a ser impressa no relatorio
oReport:nFontBody := 6

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

oSecTit := TRSection():New(oReport,"SECTIT")
TRCell():New( oSecTit, "TITULO",,""/*Titulo*/,/*Picture*/ ,250  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/ , "CENTER" /*cAlign*/, .T. /*lLineBreak*/,        ,,,.T.)

nTamDesc += 30
nTamVal  += 20
oSection1  := TRSection():New( oReport, "DETALHE", {"cArqTmp"},, .F., .F. ) 
TRCell():New(oSection1,"CONTA"  ,,""/*Titulo*/,/*Picture*/ ,nTamDesc  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/ ,      /*cAlign*/, .T. /*lLineBreak*/,        ,,,.T.)
TRCell():New(oSection1,"VALCTA1",,"" /*Titulo*/,/*Picture*/,nTamVal   /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT"/*cAlign*/,      /*lLineBreak*/,"RIGHT",,,.T.)
TRCell():New(oSection1,"PERC1",,"" /*Titulo*/,/*Picture*/,nTamVal   /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT"/*cAlign*/,      /*lLineBreak*/,"RIGHT",,,.T.)
TRCell():New(oSection1,"VALCTA2",,"" /*Titulo*/,/*Picture*/,nTamVal   /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT"/*cAlign*/,      /*lLineBreak*/,"RIGHT",,,.T.)
TRCell():New(oSection1,"PERC2",,"" /*Titulo*/,/*Picture*/,nTamVal   /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT"/*cAlign*/,      /*lLineBreak*/,"RIGHT",,,.T.)
TRCell():New(oSection1,"VALCTA3",,"" /*Titulo*/,/*Picture*/,nTamVal   /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT"/*cAlign*/,      /*lLineBreak*/,"RIGHT",,,.T.)
TRCell():New(oSection1,"PERC3",,"" /*Titulo*/,/*Picture*/,nTamVal   /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT"/*cAlign*/,      /*lLineBreak*/,"RIGHT",,,.T.)
oSection1:SetTotalInLine(.F.)

oSecFil := TRSection():New(oReport,"SECFIL")
TRCell():New(oSecFil,"CODFIL" ,,STR0003,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Código"
TRCell():New(oSecFil,"EMPRESA",,STR0004,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Empresa"
TRCell():New(oSecFil,"UNIDNEG",,STR0005,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Unidade de negócio"
TRCell():New(oSecFil,"NOMEFIL",,STR0006,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Filial"

oReport:DisableOrientation() 

RestArea(aArea)
           
Return(oReport)
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Imprime o relatorio definido pelo usuario de acordo com as
secoes/celulas criadas na funcao ReportDef definida acima.
Nesta funcao deve ser criada a query das secoes se SQL ou
definido o relacionamento e filtros das tabelas em CodeBase.

@author TOTVS
@since 21/07/2020
@version 12.1.31
@return .T.
/*/
//---------------------------------------------------------------------------------------
Static Function ReportPrint( oReport,Titulo,cAnoRef,aSetOfBook)  
Local oSecFil		:= oReport:Section("SECFIL") 
Local oSecTit       := oReport:Section("SECTIT")
Local oSection1 	:= oReport:Section("DETALHE")  
Local cArqTmp       
Local cPicture		:= ""
Local nLinha		:= 0
Local cTpValor		:= GetMV("MV_TPVALOR")
Local cArqTrm		:= ""                                       
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nTamEmp		:= 0
Local nTamUnNeg		:= 0
Local nTamTit		:= 0
Local cFiLSel		:= ""
Local cTitulo		:= ""
Local nI 
local nT
Local lCharSinal	:= .F.
Local cSuperior     := ""
Local cMoeda        := mv_par03
Local cTpSld        := mv_par04
Local dDataIni      := StoD("")
Local dDataFin      := StoD("")
Local oHashLin      := tHashMap():New()
Local aCtbMoeda		:= {}
Local aSM0			:= {}  
Local aLinhas		:= {}
Local aLinAux       := {}
Local aSaldoPer     := {}
Local aTotal        := {}
Local nNivelOld     := 0
Local cIdent		:= ""
Local nDivide		:= 1
Local cDescDiv      := ""
local lLoadTotal	:= .T.
Local nPerceTot1	:= 0
Local nPerceTot2	:= 0
Local nPerceTot3	:= 0
Local lPrintZero	:= iif(mv_par07 == 1,.T.,.F.)
local lColDbCr		:= .T.
Local lPlanilha		:= .F.
Local lProQuadro	:= .F.

Private lComNivel	:= .T. //Variável utilizada no CTBXSAL para retornar o campo NIVEL

DEFAULT cTitulo    := ""
DEFAULT cAnoRef    := Year(dDataBase)
DEFAULT aSetOfBook := CTBSetOf(mv_par02)

m_pag := mv_par05

If  Empty(aSetOfBook[5])
	MsgAlert(STR0007)  //"Os demonstrativos contabeis obrigatoriamente devem ter um plano gerencial associado ao livro. Verifique a configuracao de livros escolhida !"
	Return .F.
Endif

If mv_par06 == 2			// Divide por cem
	nDivide := 100	
ElseIf mv_par06 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par06 == 4		// Divide por milhao
	nDivide := 1000000
EndIf

If nDivide > 1
	cDescDiv := "("+"Div"+cValToChar(nDivide)+")" //"Div. "
EndIf

aSetOfBook[9] := nDivide

aCtbMoeda := CtbMoeda(cMoeda, nDivide)

nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)

// imprime a lista de filiais selecionadas para o relatorio
If Len(aSelFil) > 1	
	aSM0 := FWLoadSM0()
	nTamEmp := Len(FWSM0LayOut(,1))
	nTamUnNeg := Len(FWSM0LayOut(,2))
	cTitulo := oReport:Title()
	oReport:SetTitle(cTitulo + " ("+STR0008+")")  //"Filiais selecionadas para o relatorio"
	nTamTit := Len(oReport:Title())
	oSecFil:Init()  
	oSecFil:Cell("CODFIL"):SetBlock({||cFilSel})
	oSecFil:Cell("EMPRESA"):SetBlock({||aSM0[nLinha,SM0_DESCEMP]})
	oSecFil:Cell("UNIDNEG"):SetBlock({||aSM0[nLinha,SM0_DESCUN]})
	oSecFil:Cell("NOMEFIL"):SetBlock({||aSM0[nLinha,SM0_NOMRED]})

	For nI := 1 To Len(aSelFil)
		nLinha := Ascan(aSM0,{|sm0|,sm0[SM0_CODFIL] == aSelFil[nI]})
		If nLinha > 0
			cFilSel := Substr(aSM0[nLinha,SM0_CODFIL],1,nTamEmp)
			cFilSel += " "
			cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + 1,nTamUnNeg)
			cFilSel += " "
			cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + nTamUnNeg + 1)
			oSecFil:PrintLine()
		Endif
	Next
	oReport:SetTitle(cTitulo)
	oSecFil:Finish()
	oReport:EndPage()
Endif

#DEFINE C_CONTA			1
#DEFINE C_DESC			2
#DEFINE C_SITNORMAL		3
#DEFINE C_NIVEL    		4
#DEFINE C_IDENTIFI		5
#DEFINE C_SALDOATU		6
#DEFINE C_TIPOCONTA		7
#DEFINE C_SUPERIOR		8

aPerSld := CTbRtPer(cAnoRef)

For nI := 1 to Len(aPerSld)
    
    cArqTmp  := ""
    dDataIni := aPerSld[nI,1]
    dDataFin := aPerSld[nI,2]

    // Monta Arquivo Temporario para Impressao
    MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
                CTGerPlan(	oMeter, oText, oDlg, @lEnd,@cArqTmp,;
                            dDataIni,dDataFin,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
                            "",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
                            "",Repl("Z", Len(CTH->CTH_CLVL)),cMoeda,;
                            cTpSld,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30);
                            ,,,,,,,nDivide,,,,,,,,,,,,,,,,,,,,,,,,,,cMoeda,,aSelFil)},;
                STR0009+cValToChar(Year(dDataIni)), Titulo)  //"Carregando valores de "

    dbSelectArea("cArqTmp")
    dbGoTop()

    While !Eof()
        
        If !oHashLin:Get( CONTA, @aLinAux )            
            aSaldoPer := Array(3)
            aSaldoPer[nI] := SALDOATU
            HMSet(oHashLin, CONTA, { CONTA,;	 //[1]
                                     DESCCTA,;	 //[2]
                                     NORMAL,;	 //[3]
                                     NIVEL,;	 //[4]
                                     IDENTIFI,;	 //[5]
                                     aSaldoPer,; //[6]
                                     TIPOCONTA,; //[7]
                                     SUPERIOR} )
        Else            
            aLinAux[6,nI] := SALDOATU
            HMSet(oHashLin, CONTA, aLinAux)
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

Next nI

dbselectArea("CT2")

aTotal := Array(3)
aTotal[1] := 0
aTotal[2] := 0
aTotal[3] := 0			

HMList(oHashLin, @aLinhas)

aSort(aLinhas,,,{|x,y| x[1] < y[1]})

C506ImpTit(oSecTit,cAnoRef)

oSection1:Init()
oSection1:Cell("CONTA"):SetBlock({ || "AMF - Demonstrativo 4 (LRF, Art. 4°, § 2°, inciso III)"}) //"AMF - Demonstrativo 4 (LRF, Art. 4°, § 2°, inciso III)"
oSection1:Cell("VALCTA1"):SetBlock( { || "" } )		
oSection1:Cell("PERC1"):SetBlock( { || "" } )//EM BRANCO LINHA ANTES DOS TITULOS		
oSection1:Cell("VALCTA2"):SetBlock( { || "" } )		
oSection1:Cell("PERC2"):SetBlock( { || "" } )		
oSection1:Cell("VALCTA3"):SetBlock( { ||  } )	
oSection1:Cell("PERC3"):SetBlock( { || "R$"+cDescDiv } )		
oSection1:PrintLine()		
oReport:ThinLine()

For nI := 1 To Len(aLinhas)

	nLinha := nI
	cSuperior := AllTrim(aLinhas[nI,2,C_SUPERIOR])
	
	If nNivelOld > 0
		If aLinhas[nI,2,C_NIVEL] > nNivelOld
			cIdent += Space(3)
		ElseIf aLinhas[nI,2,C_NIVEL] < nNivelOld
			If Len(cIdent) > 2
				cIdent := SubStr(cIdent,1,Len(cIdent)-3)
			EndIf
		EndIf
	EndIf

	If aLinhas[nI,2,C_NIVEL] == 1		
		
		If nNivelOld > 0			
			ImpLinTot(oReport,aTotal,aLinhas,nLinha,aTamVal,nDecimais,cPicture,cTpValor,lColDbCr,lCharSinal,"TOTAL",lPlanilha,lPrintZero,nPerceTot1,nPerceTot2,nPerceTot3)		
			ImpQbrLin(oReport)
			aTotal[1] 	:= 0
			aTotal[2] 	:= 0
			aTotal[3] 	:= 0			
			cIdent    	:= ""
			nPerceTot1	:= 0
			nPerceTot2	:= 0
			nPerceTot3	:= 0
			lLoadTotal	:= .T. //ativado para a segunda coleta dos totais para o quadro de regime previdenciario
			lProQuadro	:= IIF(nI == 5,.T.,.F.) //Indica que é necessario a impressão do 2 quadro(Regime Previdenciario)
			
		EndIf	

		//TITULOS DAS CELULAS
		oSection1:Cell("CONTA"):SetBlock({ || aLinhas[nLinha,2,C_DESC] })
		oSection1:Cell("VALCTA1"):SetBlock( { || Year(aPerSld[1,1]) } )
		oSection1:Cell("PERC1"):SetBlock( { || "%" } )
        oSection1:Cell("VALCTA2"):SetBlock( { || Year(aPerSld[2,1]) } )		
		oSection1:Cell("PERC2"):SetBlock( { || "%" } )
        oSection1:Cell("VALCTA3"):SetBlock( { || Year(aPerSld[3,1]) } )		
		oSection1:Cell("PERC3"):SetBlock( { || "%" } )
		oSection1:PrintLine()		
		oReport:ThinLine()				
	ElseIf aLinhas[nI,2,C_NIVEL] > 1 .And. aLinhas[nI,2,C_TIPOCONTA] == "1"

		oSection1:Cell("CONTA"):SetBlock({ || cIdent+aLinhas[nLinha,2,C_DESC] })
		oSection1:Cell("VALCTA1"):SetBlock( { || "" } )
		oSection1:Cell("PERC1"):SetBlock( { || "" } )
        oSection1:Cell("VALCTA2"):SetBlock( { || "" } )
		oSection1:Cell("PERC2"):SetBlock( { || "" } )
        oSection1:Cell("VALCTA3"):SetBlock( { || "" } )	
		oSection1:Cell("PERC3"):SetBlock( { || "" } )
		oSection1:PrintLine()		        		
	Else	
		// Se Imprime Valor Zerado = Não
		If mv_par07 <> 1 .And.; 	
			aLinhas[nLinha,2,C_SALDOATU,1] == 0 .And.;
			aLinhas[nLinha,2,C_SALDOATU,2] == 0 .And.;
			aLinhas[nLinha,2,C_SALDOATU,3] == 0 
			Loop
		Endif

		cDescImp := cIdent + aLinhas[nLinha,2,C_DESC]
		
		If lLoadTotal //ja busca os totais de todas as linhas antes de atribuir.
			For nT := 1 To Len(aLinhas)
				If aLinhas[nT,2,C_TIPOCONTA] == "2" .And. nT < 5 
					If !lProQuadro //Se FALSE é o primeiro quadro	
						aTotal[1] += aLinhas[nT,2,C_SALDOATU,1]
						aTotal[2] += aLinhas[nT,2,C_SALDOATU,2]
						aTotal[3] += aLinhas[nT,2,C_SALDOATU,3]
					Endif
				ElseIf aLinhas[nT,2,C_TIPOCONTA] == "2" .And. lProQuadro //Se TRUE pega os valores do proximo quadro
					aTotal[1] += aLinhas[nT,2,C_SALDOATU,1]
					aTotal[2] += aLinhas[nT,2,C_SALDOATU,2]
					aTotal[3] += aLinhas[nT,2,C_SALDOATU,3]
				Endif
			Next nT
			lLoadTotal := .F.
		Endif

		//Formatacao dos valores nas linhas
		oSection1:Cell("CONTA"):SetBlock( { || cDescImp } )
		
		oSection1:Cell("VALCTA1"):SetBlock( { || ValorCTB(aLinhas[nLinha,2,C_SALDOATU,1], , ,aTamVal[1],nDecimais,.T., cPicture, , , , , cTpValor,,,.F.,,,lPlanilha) })
		oSection1:Cell("PERC1"):SetBlock( { || TransfPerc(aLinhas[nLinha,2,C_SALDOATU,1], aTotal[1]) })
		
		oSection1:Cell("VALCTA2"):SetBlock( { || ValorCTB(aLinhas[nLinha,2,C_SALDOATU,2], , ,aTamVal[1],nDecimais,.T., cPicture, , , , , cTpValor,,,.F.,,,lPlanilha) })
		oSection1:Cell("PERC2"):SetBlock( { || TransfPerc(aLinhas[nLinha,2,C_SALDOATU,2], aTotal[2]) })

		oSection1:Cell("VALCTA3"):SetBlock( { || ValorCTB(aLinhas[nLinha,2,C_SALDOATU,3], , ,aTamVal[1],nDecimais,.T., cPicture, , , , , cTpValor,,,.F.,,,lPlanilha) })
		oSection1:Cell("PERC3"):SetBlock( { || TransfPerc(aLinhas[nLinha,2,C_SALDOATU,3], aTotal[3]) })

		//Aglutina a % de cada linha dividido ao total
		nPerceTot1 += aLinhas[nLinha,2,C_SALDOATU,1]/aTotal[1]
		nPerceTot2 += aLinhas[nLinha,2,C_SALDOATU,2]/aTotal[2]
		nPerceTot3 += aLinhas[nLinha,2,C_SALDOATU,3]/aTotal[3]

		oSection1:PrintLine()

	EndIf
	nNivelOld := aLinhas[nI,2,C_NIVEL]
	
Next nI

ImpLinTot(oReport,aTotal,aLinhas,nLinha,aTamVal,nDecimais,cPicture,cTpValor,lColDbCr,lCharSinal,"TOTAL",lPlanilha,lPrintZero,nPerceTot1,nPerceTot2,nPerceTot3)

oSection1:Finish()

aSize(aTotal ,  0)
// aSize(aTotAux,  0)
aSize(aLinhas,  0)
aSize(aCtbMoeda,0)
aSize(aSM0,     0)
aSize(aSaldoPer,0) 

aTotal    := nil
aLinhas   := nil
aCtbMoeda := nil
aSM0      := nil
aSaldoPer := nil
nPerceTot1	:= 0
nPerceTot1	:= 0
nPerceTot1	:= 0

oSecTit:Init()
oSecTit:Cell("TITULO"):SetAlign("LEFT")
oSecTit:Cell("TITULO"):SetBlock({ || STR0010+FWEmpName(FWGrpCompany()) })//"Fonte: "
oSecTit:PrintLine()		
oSecTit:Finish()

If mv_par08==1	
	cArqTRM 	:= AllTrim(mv_par09)
	aVariaveis	:= {}

	For nI:=1 to 10
		cCodPar := "mv_par"+StrZero(nI,2)
		aAdd(aVariaveis,{cCodPar,&(cCodPar)})		
	Next

	If !File(cArqTRM)
		aSavSet:=__SetSets()
		cArqTRM := CFGX024(cArqTRM,STR0011) //"Nota Explicativa"
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqTRM#NIL
		ImpTerm2(cArqTRM,aVariaveis,,,,oReport)
	Endif	 
EndIf

oReport:EndPage()

Return .T.
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ImpLinTot

Imprime linha de total

@author TOTVS
@since 21/07/2020
@version 12.1.31
@return nil
/*/
//---------------------------------------------------------------------------------------
Static Function ImpLinTot(oReport,aTotal,aLinhas,nLinha,aTamVal,nDecimais,cPicture,cTpValor,lColDbCr,lCharSinal,cTextTot,lPlanilha,lPrintZero,nPerceTot1,nPerceTot2,nPerceTot3)
	Local oSection1 := oReport:Section("DETALHE")
	Local aTotPerc	:= array(3)

	DEFAULT aTotal     := {}
	DEFAULT aLinhas    := {}
	DEFAULT nLinha     := 0
	DEFAULT aTamVal    := {}
	DEFAULT nDecimais  := 0
	DEFAULT cPicture   := ""
	DEFAULT cTpValor   := GetMV("MV_TPVALOR")
	DEFAULT lCharSinal := .F.
	DEFAULT cTextTot   := ""
	DEFAULT lColDbCr   := .T.
	DEFAULT lPLanilha  := .F.
	DEFAULT lPrintZero := iif(mv_par07 == 1,.T.,.F.)
	DEFAULT nPerceTot1 := 0
	DEFAULT nPerceTot2 := 0
	DEFAULT nPerceTot3 := 0

	oReport:ThinLine()
	aTotPerc[1] := cValtoChar(Round(nPerceTot1, 0) * 100) + "%"
	aTotPerc[2] := cValtoChar(Round(nPerceTot2, 0) * 100) + "%"
	aTotPerc[3] := cValtoChar(Round(nPerceTot3, 0) * 100) + "%"

	oSection1:Cell("CONTA"):SetBlock({ || cTextTot})
	//Totalizadores de cada coluna na respectiva coluna final
	oSection1:Cell("VALCTA1"):SetBlock( { || ValorCTB(aTotal[1], , ,aTamVal[1],nDecimais,.T., cPicture, , , , , cTpValor,,lPrintZero,.F.,lColDbCr,lCharSinal,lPlanilha) } )
	oSection1:Cell("PERC1"):SetBlock( { || aTotPerc[1]} )
	oSection1:Cell("VALCTA2"):SetBlock( { || ValorCTB(aTotal[2], , ,aTamVal[1],nDecimais,.T., cPicture, , , , , cTpValor,,lPrintZero,.F.,lColDbCr,lCharSinal,lPlanilha) } )
	oSection1:Cell("PERC2"):SetBlock( { ||  aTotPerc[2] } )
	oSection1:Cell("VALCTA3"):SetBlock( { || ValorCTB(aTotal[3], , ,aTamVal[1],nDecimais,.T., cPicture, , , , , cTpValor,,lPrintZero,.F.,lColDbCr,lCharSinal,lPlanilha) } )
	oSection1:Cell("PERC3"):SetBlock( { ||  aTotPerc[3]} )
								
	oSection1:PrintLine()

Return 
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ImpQbrLin

Imprime quebra de linha

@author TOTVS
@since 21/07/2020
@version 12.1.31
@return nil
/*/
//---------------------------------------------------------------------------------------
Static Function ImpQbrLin(oReport)
	Local oSection1 := oReport:Section("DETALHE")

	oSection1:Cell("CONTA"):SetBlock({ || ""})
	oSection1:Cell("VALCTA1"):SetBlock( { || "" } )
	oSection1:Cell("PERC1"):SetBlock( { || "" } )
	oSection1:Cell("VALCTA2"):SetBlock( { || "" } )
	oSection1:Cell("PERC2"):SetBlock( { || "" } )
	oSection1:Cell("VALCTA3"):SetBlock( { || "" } )
	oSection1:Cell("PERC3"):SetBlock( { || "" } )
	oSection1:PrintLine()

Return 
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} CTbRtPer

Retorna o array com os períodos do demonstrativo

@author TOTVS
@since 21/07/2020
@version 12.1.31
@return aRetPer - Array com os períodos a serem processados
/*/
//---------------------------------------------------------------------------------------
Static Function CTbRtPer(cAnoRef)
	Local aRetPer := {}
	Local cAnoAux := ""
	Local nI      := 0

	DEFAULT cAnoRef := Year(dDataBase)

	For nI := 2 to 4
		cAnoAux := cValToChar(Val(cAnoRef)-nI)
		aAdd(aRetPer,{StoD(cAnoAux+"0101"),StoD(cAnoAux+"1231")})
	Next nI

Return aRetPer
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} C506ImpTit

Imprime o título do relatório

@author TOTVS
@since 23/07/2020
@version 12.1.31
@return nil
/*/
//---------------------------------------------------------------------------------------
Static Function C506ImpTit(oSecTit,cAnoRef)

	DEFAULT cAnoRef := ""

	oSecTit:Init()
	oSecTit:Cell("TITULO"):SetBlock({ || STR0012}) //"LEI DE DIRETRIZES ORÇAMENTÁRIAS"
	oSecTit:PrintLine()		
	oSecTit:Cell("TITULO"):SetBlock({ || STR0013}) //"ANEXO DE METAS FISCAIS"
	oSecTit:PrintLine()		
	oSecTit:Cell("TITULO"):SetBlock({ || STR0014}) //"ORIGEM E APLICAÇÃO DOS RECURSOS OBTIDOS COM A ALIENAÇÃO DE ATIVOS"
	oSecTit:PrintLine()		
	oSecTit:Cell("TITULO"):SetBlock({ || cAnoRef})
	oSecTit:PrintLine()		
	oSecTit:Finish()

Return 

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} TransfPerc

Exibe e transforma o porcentual das linhas em relação ao total do ano.
@author TOTVS
@since 12/08/2020
@version 12.1.31
@return nil
/*/
//---------------------------------------------------------------------------------------
Function TransfPerc(nValor,nTotal)
	
	cRetorno 	:= ""
	nVlrAux		:= 0
	nVlrAux		:= ROUND((nValor/nTotal),4) * 100
	cRetorno := cValtoChar(nVlrAux) + "%"

Return cRetorno
