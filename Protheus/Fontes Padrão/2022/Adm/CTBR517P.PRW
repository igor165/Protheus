#Include "CTBR517P.ch"
#INCLUDE "PROTHEUS.CH"

Static _aNotaExplic := {}
Static _cCodVisao   := ""
Static _lImpZerado  := .F.
//-------------------------------------------------------------------
/*/{Protheus.doc} CtbR517P
Balanço financeiro padrão CRC

@author TOTVS
@since 29/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function CtbR517P()                      
Local aSetOfBook	
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""
Local lRet          := .T.

PRIVATE CPERG	   	:= "CTBR517P" 
PRIVATE nomeprog	:= "CTBR517P"       
PRIVATE aSelFil		:={} 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
If !CtrVld517p(cPerg)
	Return
Endif

// Faz a validacao das filiais
If lRet .And. mv_par11 == 1 .And. Len( aSelFil ) <= 0 
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf                             
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// faz a validação do livro
if ! Empty( mv_par03 ) 
	if ! VdSetOfBook( mv_par03 , .F. )
		lRet := .F.
	endif
Endif

If Empty(mv_par01) .Or. Empty(mv_par02)
	MsgInfo(STR0023,STR0022) //"O parâmetro de data deve ser preenchido."
	lRet := .F.
EndIf

If lRet .And. mv_par01 > mv_par02
	MsgInfo(STR0024,STR0022)//"A data inicial é maior do que a data final."
	lRet := .F.
EndIf

If lRet .And. (mv_par02-mv_par01) > 365
	MsgInfo(STR0025,STR0022)//"O período máximo para este relatório é de 1 ano."
	lRet := .F.
EndIf

If lRet
	// seta o livro
	aSetOfBook := CTBSetOf(mv_par03)
	
	// seta a moeda
	aCtbMoeda	:= CtbMoeda(mv_par05, aSetOfBook[9])
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		Return .F.
	EndIf	
        
	cDescMoeda 	:= AllTrim(aCtbMoeda[3])
	        
	oReport := ReportDef(aSetOfBook, aCtbMoeda, cDescMoeda)      
	oReport :PrintDialog()
	      
EndIf
//Limpa os arquivos temporários 
CTBGerClean()

Return                                
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definição do relatório

@author TOTVS
@since 29/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(aSetOfBook, aCtbMoeda, cDescMoeda)  
Local cREPORT		:= "CTBR517P"
Local cTITULO		:= Capital(STR0001)//"Balanço Financeiro"
Local cDESC			:= STR0002 //"Este programa irá imprimir o Balanço Financeiro."
Local aTamDesc		:= TAMSX3("CTS_DESCCG")  
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nTamAux		:= 20
Local dFinal 		:= CTOD(SPACE(8))

If (mv_par02-mv_par01) < 32 //Relatório Mensal	
	cTitulo := STR0028 //"Balancete Financeiro"	
EndIf

If mv_par11 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
EndIf 

dFinal:= mv_par02

//_________________________________________________________________________
// Criacao do componente de impressao                                      
//                                                                        
// TReport():New                                                           
// ExpC1 : Nome do relatorio                                               
// ExpC2 : Titulo                                                          
// ExpC3 : Pergunte                                                        
// ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  
// ExpC5 : Descricao                                                       
//__________________________________________________________________________

oReport	:= TReport():New( cReport,cTitulo,cPerg,;
	{ |oReport| Pergunte(cPerg,.F.), Iif(ReportPrint(oReport,@cTitulo,dFinal), .T., oReport:CancelPrint())}, CDESC)
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,ctitulo,,,,,oReport) } )                                        		
oReport:SetLandScape(.T.)
oReport:ParamReadOnly()
oReport:SetEdit(.F.)

// Define o tamanho da fonte a ser impressa no relatorio
oReport:nFontBody := 6

//_________________________________________________________________________
//
// Criacao da secao utilizada pelo relatorio                               
//                                                                         
// TRSection():New                                                         
// ExpO1 : Objeto TReport que a secao pertence                             
// ExpC2 : Descricao da seçao                                              
// ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   
//         sera considerada como principal para a seção.                   
// ExpA4 : Array com as Ordens do relatório                                
// ExpL5 : Carrega campos do SX3 como celulas                              
//         Default : False                                                 
// ExpL6 : Carrega ordens do Sindex                                        
//         Default : False                                                 
//_________________________________________________________________________

oSection1  := TRSection():New( oReport, STR0003, {"cArqTmp"},, .F., .F. )      // "Detalhe" //"Detalhe "
  
// Colunas referentes ao Ativo
TRCell():New( oSection1, STR0005     , ,STR0004  	/*Titulo*/,/*Picture*/,aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,.T.,,,,.T.) //"INGRESSOS" //"ATIVO"
TRCell():New( oSection1, "ANE"       , ,STR0006 	/*Titulo*/,/*Picture*/,10  		    /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,.T.,,,,.T.) //"N.E"
TRCell():New( oSection1, "AEXERCICIO", ,""          /*Titulo*/,/*Picture*/,aTamVal[1]+nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)
TRCell():New( oSection1, "AEXERANT"  , ,""			/*Titulo*/,/*Picture*/,aTamVal[1]+nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)

// Colunas referentes ao Passivo
TRCell():New( oSection1, STR0008   	 , ,STR0007  	/*Titulo*/,/*Picture*/,aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,.T.,,,5,.T.) //"DISPÊNDIOS" //"PASSIVO"
TRCell():New( oSection1, "PNE"       , ,STR0006 	/*Titulo*/,/*Picture*/,10 		    /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,.T.,,,,.T.) //"N.E"
TRCell():New( oSection1, "PEXERCICIO", ,""          /*Titulo*/,/*Picture*/,aTamVal[1]+nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)
TRCell():New( oSection1, "PEXERANT"  , ,""			/*Titulo*/,/*Picture*/,aTamVal[1]+nTamAux/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"CENTER",,,.T.)

If mv_par08 == 2
	oSection1:Cell("AEXERANT"):Disable()
	oSection1:Cell("PEXERANT"):Disable()
EndIf

If (mv_par09 == 2)
	oSection1:Cell("ANE"):Disable()
	oSection1:Cell("PNE"):Disable()
EndIf

oSection1:SetTotalInLine(.F.)
oSection1:SetLineStyle(.F.)

/* Relacao das filiais selecionadas para compor o relatorio */
oSecFil := TRSection():New(oReport,"SECFIL")

TRCell():New(oSecFil,"CODFIL",,STR0009,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/) //"Código"
TRCell():New(oSecFil,"EMPRESA",,STR0010,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Empresa"
TRCell():New(oSecFil,"UNIDNEG",,STR0011,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Unidade de negócio"
TRCell():New(oSecFil,"NOMEFIL",,STR0012,/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //"Filial"

//Criacao da Secao Nota Explicativa
oNotExplic := TRSection():New(oReport,STR0026, {}, /*aOrdem*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , /*<lLineBreak>*/ , /*<nLeftMargin>*/ , .T./*<lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 0 /*<nLinesBefore>*/ , 1/*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ ) //"Nota Explicativa"
TRCell():New(oNotExplic, "CODNOT"		,, "Código NE"	,,  10, /*lPixel*/, {|| Code_NE() }/*CodeBlock*/,,,,,,,,, .T.) 
TRCell():New(oNotExplic, "DATNOT"		,, "Data NE"	,,  10, /*lPixel*/, {|| Data_NE() }/*CodeBlock*/,,,,,,,,,) 
TRCell():New(oNotExplic, "OBSNOT"		,, "Observ.NE"	,, 140, /*lPixel*/, {|| Observ_NE() }/*CodeBlock*/,"LEFT",.T.,"CENTER",,,,,,) 

oReport:DisableOrientation() 

aSize(aTamDesc,0)
aTamDesc := Nil

Return(oReport)
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do relatório 

@author TOTVS
@since 29/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint( oReport, Titulo, dFinal )  
Local oSection1 	:= oReport:Section(1)  
Local aSetOfBook	:= CTBSetOf(mv_par03)
LOCAL oNotExplic	:= oReport:Section(3)  
Local aCtbMoeda		:= {}
Local cArqTmp
Local nI
Local cPicture
Local aRecOrc		:= { {}, {} }
Local aTotOrc		:= { {}, {} }
Local aRecExt		:= { {}, {} }
Local aTotExt		:= { {}, {} }
Local aRecDisp		:= { {}, {} }
Local aTotGer		:= { {}, {} }
Local lColuna		:= .F.
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nPeriodos     := 1
Local cMoedaDesc	:= mv_par05
Local nTamEmp		:= 0
Local nTamUnNeg		:= 0
Local nTamTit		:= 0
Local cFiLSel		:= ""
Local cTitulo		:= ""
Local oSecFil		:= oReport:Section("SECFIL") 
Local aSM0			:= {}  
Local nX 
Local cAnoAnt 		:= ""
Local cAnoAtu 		:= ""
Local cQuadro 		:= ""
Local nDivide		:= mv_par10
Local aMeses 		:= {"Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"} // A função cMonth está retornando em Inglês
Local nLin			:= 0
Local _lImpZerado   := (mv_par07 == 1)

Private lPeriodoAnt	:= (mv_par08 == 1)
Private lNotaExp	:= (mv_par09 == 1)

oReport:SetPageNumber( Val(mv_par04) )

If Empty(CTBSetOf(mv_par03)[5])
	ApMsgAlert(STR0013)  //"Os demonstrativos contabeis obrigatoriamente devem ter um plano gerencial associado ao livro. Verifique a configuracao de livros escolhida !"
	Return .F.
Endif

_cCodVisao := aSetOfBook[5]

/* imprime a lista de filiais selecionadas para o relatorio */
If Len(aSelFil) > 1
	aSM0 := FWLoadSM0()
	nTamEmp := Len(FWSM0LayOut(,1))
	nTamUnNeg := Len(FWSM0LayOut(,2))
	cTitulo := oReport:Title()
	oReport:SetTitle(cTitulo + " (" + STR0014 + ")") //"Filiais selecionadas para o relatorio"
	nTamTit := Len(oReport:Title())
	oSecFil:Init()  
	oSecFil:Cell("CODFIL"):SetBlock({||cFilSel})
	oSecFil:Cell("EMPRESA"):SetBlock({||aSM0[nLinha,SM0_DESCEMP]})
	oSecFil:Cell("UNIDNEG"):SetBlock({||aSM0[nLinha,SM0_DESCUN]})
	oSecFil:Cell("NOMEFIL"):SetBlock({||aSM0[nLinha,SM0_NOMRED]})

	For nX := 1 To Len(aSelFil)
		nLinha := Ascan(aSM0,{|sm0|,sm0[SM0_GRPEMP] = cEmpant .And. sm0[SM0_CODFIL] == aSelFil[nX]})
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

If lPeriodoAnt
	nPeriodos := 2
EndIf

dDataIni := mv_par01
dDataFim := mv_par02

If (dDataFim-dDataIni) < 32 //Relatório Mensal	
	dDtIniAnt := MonthSub(mv_par01,1)
	dDtFimAnt := MonthSub(mv_par02,1)		
	cAnoAnt := aMeses[Month(dDtFimAnt)]+"/"+cValToChar(Year(dDtFimAnt))
	cAnoAtu := aMeses[Month(dDataFim)]+"/"+cValToChar(Year(dDataFim))
Else
	dDtIniAnt := YearSub(mv_par01,1)
	dDtFimAnt := YearSub(mv_par02,1)		
	cAnoAnt := cValToChar(Year(dDtFimAnt))
	cAnoAtu := cValToChar(Year(dDataFim))
EndIf

//para verificar por quanto sera dividido e adicionar ao o titulo da moeda.
If nDivide == 2			// Divide por cem
	nDivide := 100
ElseIf nDivide == 3		// Divide por mil
	nDivide := 1000
ElseIf nDivide == 4		// Divide por milhao
	nDivide := 1000000
EndIf

aSetOfBook[9] := nDivide

aCtbMoeda := CtbMoeda(mv_par05, aSetOfBook[9])
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

nDecimais 	:= DecimalCTB(aSetOfBook,mv_par05)
cPicture 	:= aSetOfBook[4]
                                            
lComNivel	:= .T.

m_pag := mv_par04

For nI:=1 to nPeriodos
	dDataIni := mv_par01
	dDataFim := mv_par02

	If nI==1 .And. nPeriodos > 1
		dDataIni := dDtIniAnt
		dDataFim := dDtFimAnt		
	EndIf

	//________________________________________________________________
	//
	// Monta Arquivo Temporario para Impressao						
	//________________________________________________________________

	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerPlan(	oMeter, oText, oDlg, @lEnd,@cArqTmp,;
							dDataIni,dDataFim,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
							"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
							"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par05,;
							MV_PAR06,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30);
							,,,,,,,,_lImpZerado,,,,,,,,,,,,,,,,,,,,,,,,,cMoedaDesc,,aSelFil)},;
				STR0015+cValToChar(Year(dDataFim)), Titulo)  //"Filtrando dados de "

	dbSelectArea("cArqTmp")
	dbGoTop()
	lColuna	:= FieldPos("COLUNA") > 0

	#DEFINE C_CONTA			1
	#DEFINE C_DESC			2
	#DEFINE C_NORMAL		3
	#DEFINE C_VALANT		4
	#DEFINE C_VALATU		5
	
	While !Eof()
		
		If Empty(SUPERIOR)
			cQuadro := AllTrim(CONTA)
			dbSkip()
			Loop
		EndIf
		
		If cQuadro == "1"
			If AllTrim(CONTA)=="62" .Or. AllTrim(CONTA)=="63"
				Quadro1(aTotOrc,CONTA,DESCCTA,SUPERIOR,NORMAL,nI,MOVIMENTO)
			EndIf
			If AllTrim(SUPERIOR)=="62" .Or. AllTrim(SUPERIOR)=="63"
				Quadro1(aRecOrc,CONTA,DESCCTA,SUPERIOR,NORMAL,nI,MOVIMENTO)
			EndIf
		EndIf

		If TIPOCONTA == "1"
			dbSkip()
			Loop
		EndIf
		
		If cQuadro == "2" 
			Quadro2(aRecExt,CONTA,DESCCTA,NORMAL,nI,MOVIMENTO,aTotExt)
		EndIf		

		If cQuadro == "3"
			Quadro3(aRecDisp,CONTA,DESCCTA,NORMAL,nI,SALDOATU,SALDOANT)
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

QuadroTot(aTotOrc,aTotExt,aRecDisp,aTotGer)

dbselectArea("CT2")

oSection1:Init()

aTamVal[1] += 8

if lPeriodoAnt
	oSection1:Cell("AEXERANT"):SetTitle(Space(30)+cAnoAnt)
	oSection1:Cell("PEXERANT"):SetTitle(Space(30)+cAnoAnt)
EndIf

oSection1:Cell("AEXERCICIO"):SetTitle(Space(30)+cAnoAtu)
oSection1:Cell("PEXERCICIO"):SetTitle(Space(30)+cAnoAtu)

PulaLinha(oSection1)
oReport:ThinLine()

ImpQuadro1(oSection1,aTotOrc,aRecOrc,aTamVal,nDecimais,cPicture)

ImpQuadro2(oSection1,aTotExt,aRecExt,aTamVal,nDecimais,cPicture)

ImpQuadro3(oSection1,aRecDisp,aTamVal,nDecimais,cPicture,nPeriodos)

ImpQuadTot(oSection1,aTotGer,aTamVal,nDecimais,cPicture,nPeriodos)

oSection1:Finish()

//impressao nota explicativa
If Len(_aNotaExplic) > 0
	oReport:EndPage()

	aSort(_aNotaExplic,,,{|x,y| x < y})

	oReport:ThinLine()
	oReport:PrintText("** "+STR0027+" **")//"NOTAS EXPLICATIVAS"
	oReport:ThinLine()

	oNotExplic:Init()
	For nLin := 1 TO Len(_aNotaExplic)
		QLQ->( dbGoto( _aNotaExplic[nLin] ) )
		oNotExplic:PrintLine()
	Next
	oNotExplic:Finish()
EndIf

oReport:EndPage()

aSize(aCtbMoeda,0)
aCtbMoeda := Nil

aSize(aSetOfBook,0)
aSetOfBook := Nil

aSize(aTamVal,0)
aTamVal := Nil

aSize(aRecOrc,0)
aRecOrc := Nil

aSize(aTotOrc,0)
aTotOrc := Nil

aSize(aRecExt,0)
aRecExt := Nil

aSize(aTotExt,0)
aTotExt := Nil

aSize(aRecDisp,0)
aRecDisp := Nil

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} CtrVld517p
Valida as perguntas do relatório

@author TOTVS
@since 29/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function CtrVld517p(cPerg)

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return .F.
EndIf

If ! Pergunte(cPerg,.T.) 
	Return .F.
Endif                    

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} Quadro1
Imprime o quadro 1 do relatório

@author TOTVS
@since 29/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Quadro1(aArrAux,cConta,cDescri,cSuperior,cNormal,nPeriodo,nMovimento)

cSuperior := AllTrim(cSuperior)

If AllTrim(cConta) == "62" .Or. cSuperior == "62"
	GrvArray(aArrAux[1],cConta,cDescri,cNormal,nMovimento,nPeriodo)	
ElseIf AllTrim(cConta) == "63" .Or. cSuperior == "63"
	GrvArray(aArrAux[2],cConta,cDescri,cNormal,nMovimento,nPeriodo)
EndIf

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} Quadro2
Imprime o quadro 2 do relatório

@author TOTVS
@since 29/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Quadro2(aArrAux,cConta,cDescri,cNormal,nPeriodo,nMovimento,aArrTot)

If cNormal == "1" 
	If nMovimento <=0
		GrvArray(aArrAux[1],cConta,cDescri,cNormal,nMovimento,nPeriodo)
		GrvArray(aArrTot[1],"TOT",cDescri,cNormal,nMovimento,nPeriodo)
	Else
		GrvArray(aArrAux[2],cConta,cDescri,cNormal,nMovimento,nPeriodo)
		GrvArray(aArrTot[2],"TOT",cDescri,cNormal,nMovimento,nPeriodo)
	EndIf
ElseIf cNormal == "2" 
	If nMovimento >= 0
		GrvArray(aArrAux[1],cConta,cDescri,cNormal,nMovimento,nPeriodo)
		GrvArray(aArrTot[1],"TOT",cDescri,cNormal,nMovimento,nPeriodo)
	Else
		GrvArray(aArrAux[2],cConta,cDescri,cNormal,nMovimento,nPeriodo)
		GrvArray(aArrTot[2],"TOT",cDescri,cNormal,nMovimento,nPeriodo)
	EndIf
EndIf

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} Quadro3
Imprime o quadro 3 do relatório

@author TOTVS
@since 29/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Quadro3(aArrAux,cConta,cDescri,cNormal,nPeriodo,nSaldo,nSaldoAnt)

If lPeriodoAnt
	If nPeriodo == 1
		GrvArray(aArrAux[1],cConta,cDescri,cNormal,nSaldoAnt,nPeriodo)
		GrvArray(aArrAux[2],cConta,cDescri,cNormal,nSaldo,nPeriodo)
	Else
		GrvArray(aArrAux[1],cConta,cDescri,cNormal,nSaldoAnt,nPeriodo)
		GrvArray(aArrAux[2],cConta,cDescri,cNormal,nSaldo,nPeriodo)
	EndIf
Else
	GrvArray(aArrAux[1],cConta,cDescri,cNormal,nSaldoAnt,nPeriodo)
	GrvArray(aArrAux[2],cConta,cDescri,cNormal,nSaldo,nPeriodo)
EndIf

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} GrvArray
Função para gravar o array de dados do relatório

@author TOTVS
@since 29/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function GrvArray(aArrAux,cConta,cDescri,cNormal,nMovimento,nPeriodo)
Local nPos :=0
DEFAULT aArrAux		:= {}
DEFAULT cConta		:= ""
DEFAULT cDescri		:= ""
DEFAULT cNormal		:= ""
DEFAULT nMovimento 	:= 0
DEFAULT nPeriodo 	:= 0

If (nPos:=aScan(aArrAux, {|x| x[1]==cConta}))>0
	If nPeriodo == 1 .And. lPeriodoAnt
		aArrAux[nPos,4] += nMovimento
	Else
		aArrAux[nPos,5] += nMovimento
	EndIf
Else	
	If nPeriodo == 1 .And. lPeriodoAnt
		aAdd(aArrAux,{cConta,cDescri,cNormal,nMovimento,0})		
	Else
		aAdd(aArrAux,{cConta,cDescri,cNormal,0,nMovimento})
	EndIf
EndIf

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} PulaLinha
Função para saltar uma linha

@author TOTVS
@since 29/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PulaLinha(oSection)

oSection:Cell("ATIVO"     ):SetBlock( {|| ""} )
oSection:Cell("ANE"       ):SetBlock( {|| ""} )
oSection:Cell("AEXERCICIO"):SetBlock( {|| ""} )
oSection:Cell("AEXERANT"  ):SetBlock( {|| ""} )

oSection:Cell("PASSIVO"   ):SetBlock( {|| ""} )
oSection:Cell("PNE"       ):SetBlock( {|| ""} )
oSection:Cell("PEXERCICIO"):SetBlock( {|| ""} )
oSection:Cell("PEXERANT"  ):SetBlock( {|| ""} )

oSection:PrintLine()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ImpQuadro1
Imprime quadro 1

@author TOTVS
@since 29/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ImpQuadro1(oSection1,aTotOrc,aRecOrc,aTamVal,nDecimais,cPicture)
Local nLin  := 0
Local cNotaA := ""
Local cNotaP := ""
Local lPrintLine := .F.

oSection1:Cell("ATIVO"):SetBlock( { || STR0016} ) //"RECEITA ORÇAMENTÁRIA" //
oSection1:Cell("PASSIVO"):SetBlock( { || STR0017} ) //"DESPESA ORÇAMENTÁRIA" //

If lNotaExp
	oSection1:Cell("ANE"):SetBlock( {|| ""} )
	oSection1:Cell("PNE"):SetBlock( {|| ""} )
EndIf

If lPeriodoAnt
	If Len(aTotOrc[1])>0
		oSection1:Cell("AEXERANT"):SetBlock( { || ValorCTB( aTotOrc[1][1][C_VALANT],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )					
	Else
		oSection1:Cell("AEXERANT"):SetBlock( {|| ""} )		
	EndIf
	If Len(aTotOrc[2])>0
		oSection1:Cell("PEXERANT"):SetBlock( { || ValorCTB( aTotOrc[2][1][C_VALANT],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )		
	Else
		oSection1:Cell("PEXERANT"):SetBlock( {|| ""} )
	EndIf
EndIf

If Len(aTotOrc[1])>0
	oSection1:Cell("AEXERCICIO"):SetBlock( { || ValorCTB( aTotOrc[1][1][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
Else
	oSection1:Cell("AEXERCICIO"):SetBlock( {|| ""} )	
EndIf

If Len(aTotOrc[2])>0
	oSection1:Cell("PEXERCICIO"):SetBlock( { || ValorCTB( aTotOrc[2][1][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )		
Else
	oSection1:Cell("PEXERCICIO"):SetBlock( {|| ""} )	
EndIf

oSection1:PrintLine()
oReport:ThinLine()

For nLin := 1 to 2

	lPrintLine := .F.	

	If Len(aRecOrc[1]) >= nLin		
		oSection1:Cell("ATIVO"):SetBlock( { || aRecOrc[1][nLin][C_DESC] } )
		
		If lNotaExp
			cNotaA := CodeNota(aRecOrc[1][nLin][C_CONTA])
			If !Empty(cNotaA)
				oSection1:Cell("ANE"):SetBlock( { || cNotaA } )
			EndIf	
		EndIf

		If lPeriodoAnt
			oSection1:Cell("AEXERANT"):SetBlock( { || ValorCTB( aRecOrc[1][nLin][C_VALANT],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )					
		EndIf
		
		oSection1:Cell("AEXERCICIO"):SetBlock( { || ValorCTB( aRecOrc[1][nLin][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
	Else
		oSection1:Cell("ATIVO"   ):SetBlock( {|| ""} )
		oSection1:Cell("AEXERCICIO"):SetBlock( {|| ""} )
		
		If lNotaExp
			oSection1:Cell("ANE"):SetBlock( {|| ""} )
		EndIf
		
		If lPeriodoAnt
			oSection1:Cell("AEXERANT"  ):SetBlock( {|| ""} )	
		EndIf

	EndIf

	If Len(aRecOrc[2]) >= nLin		
		oSection1:Cell("PASSIVO"):SetBlock( { || aRecOrc[2][nLin][C_DESC] } )
		
		If lNotaExp
			cNotaP := CodeNota(aRecOrc[2][nLin][C_CONTA])
			If !Empty(cNotaP)
				oSection1:Cell("PNE"):SetBlock( { || cNotaP } )
			EndIf	
		EndIf

		If lPeriodoAnt	
			oSection1:Cell("PEXERANT"):SetBlock( { || ValorCTB( aRecOrc[2][nLin][C_VALANT],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )		
		EndIf	

		oSection1:Cell("PEXERCICIO"):SetBlock( { || ValorCTB( aRecOrc[2][nLin][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )		
	Else
		oSection1:Cell("PASSIVO"   ):SetBlock( {|| ""} )
		oSection1:Cell("PEXERCICIO"):SetBlock( {|| ""} )
		
		If lNotaExp 
			oSection1:Cell("PNE"):SetBlock( {|| ""} )
		EndIf
		
		If lPeriodoAnt
			oSection1:Cell("PEXERANT"  ):SetBlock( {|| ""} )	
		EndIf
	EndIf

	oSection1:PrintLine()
Next nLin

PulaLinha(oSection1)
oReport:ThinLine()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ImpQuadro2
Imprime quadro 2

@author TOTVS
@since 29/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ImpQuadro2(oSection1,aTotExt,aRecExt,aTamVal,nDecimais,cPicture)
Local nLin	  := 0
Local nMaxLin := 0
Local cNotaA  := ""
Local cNotaP  := ""

//Coluna 1
oSection1:Cell("ATIVO"):SetBlock( { || STR0018} ) //"RECEBIMENTOS EXTRA-ORÇAMENTÁRIOS" //

If Len(aTotExt[1]) > 0
	If lPeriodoAnt
		oSection1:Cell("AEXERANT"):SetBlock( { || ValorCTB( aTotExt[1][1][C_VALANT],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )					
	EndIf
	oSection1:Cell("AEXERCICIO"):SetBlock( { || ValorCTB( aTotExt[1][1][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
Else
	If lPeriodoAnt
		oSection1:Cell("AEXERCICIO"):SetBlock( {|| ""} )
	EndIf
	oSection1:Cell("AEXERANT"  ):SetBlock( {|| ""} )
EndIf
//Coluna 2
oSection1:Cell("PASSIVO"):SetBlock( { || STR0019} ) //"PAGAMENTOS EXTRA-ORÇAMENTÁRIOS" //

If Len(aTotExt[2]) > 0
	If lPeriodoAnt
		oSection1:Cell("PEXERANT"):SetBlock( { || ValorCTB( aTotExt[2][1][C_VALANT],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )		
	EndIf
	oSection1:Cell("PEXERCICIO"):SetBlock( { || ValorCTB( aTotExt[2][1][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )		
Else
	If lPeriodoAnt
		oSection1:Cell("PEXERCICIO"):SetBlock( {|| ""} )
	EndIf
	oSection1:Cell("PEXERANT"  ):SetBlock( {|| ""} )	
EndIf

If lNotaExp
	oSection1:Cell("ANE"):SetBlock( {|| ""} )
	oSection1:Cell("PNE"):SetBlock( {|| ""} )
EndIf

oSection1:PrintLine()
oReport:ThinLine()

aSort(aRecExt[1],,,{|x,y| x[1] < y[1]})
aSort(aRecExt[2],,,{|x,y| x[1] < y[1]})

If Len(aRecExt[1]) > Len(aRecExt[2])
	nMaxLin := Len(aRecExt[1])
Else
	nMaxLin := Len(aRecExt[2])
EndIf

For nLin:=1 to nMaxLin
	
	//Coluna 1
	If Len(aRecExt[1])>=nLin
		oSection1:Cell("ATIVO"):SetBlock( { || aRecExt[1][nLin][C_DESC] } ) //
		
		If lNotaExp
			cNotaA := CodeNota(aRecExt[1][nLin][C_CONTA])
			If !Empty(cNotaA)
				oSection1:Cell("ANE"):SetBlock( { || cNotaA } )
			EndIf
		EndIf

		If lPeriodoAnt
			oSection1:Cell("AEXERANT"):SetBlock( { || ValorCTB( aRecExt[1][nLin][C_VALANT],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )					
		EndIf
		
		oSection1:Cell("AEXERCICIO"):SetBlock( { || ValorCTB( aRecExt[1][nLin][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )

	Else
		oSection1:Cell("ATIVO"	   ):SetBlock( {|| ""} )
		oSection1:Cell("AEXERCICIO"):SetBlock( {|| ""} )
		If lNotaExp
			oSection1:Cell("ANE"  ):SetBlock( {|| ""} )
		EndIf

		If lPeriodoAnt
			oSection1:Cell("AEXERANT"  ):SetBlock( {|| ""} )
		EndIf
	EndIf

	//Coluna 2
	If Len(aRecExt[2])>=nLin
		oSection1:Cell("PASSIVO"):SetBlock( { || aRecExt[2][nLin][C_DESC] } ) 
		
		If lNotaExp
			cNotaP := CodeNota(aRecExt[2][nLin][C_CONTA])
			If !Empty(cNotaP)
				oSection1:Cell("PNE"):SetBlock( { || cNotaP } )
			EndIf
		EndIf

		If lPeriodoAnt
			oSection1:Cell("PEXERANT"):SetBlock( { || ValorCTB( aRecExt[2][nLin][C_VALANT],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )		
		EndIf

		oSection1:Cell("PEXERCICIO"):SetBlock( { || ValorCTB( aRecExt[2][nLin][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )		
		
	Else
		oSection1:Cell("PASSIVO"   ):SetBlock( {|| ""} )
		oSection1:Cell("PEXERCICIO"):SetBlock( {|| ""} )
		
		If lNotaExp
			oSection1:Cell("PNE"  ):SetBlock( {|| ""} )
		EndIf
		
		If lPeriodoAnt
			oSection1:Cell("PEXERANT"  ):SetBlock( {|| ""} )	
		EndIf
	EndIf	
	
	oSection1:PrintLine()

Next nLin

PulaLinha(oSection1)
oReport:ThinLine()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ImpQuadro3
Imprime quadro 3

@author TOTVS
@since 29/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ImpQuadro3(oSection1,aRecDisp,aTamVal,nDecimais,cPicture,nPeriodos)
Local cNotaA := ""
Local cNotaP := ""

oSection1:Cell("ATIVO"):SetBlock( { || STR0020} ) //"DISPONÍVEL DO EXERCÍCIO ANTERIOR"
oSection1:Cell("PASSIVO"):SetBlock( { || STR0021} ) //"DISPONÍVVEL PARA EXERCÍCIO SEGUINTE"

If lPeriodoAnt
	//Coluna 1
	if Len(aRecDisp[1])>0
		oSection1:Cell("AEXERANT"):SetBlock( { || ValorCTB( aRecDisp[1][1][C_VALANT],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )					
		oSection1:Cell("AEXERCICIO"):SetBlock( { || ValorCTB( aRecDisp[1][1][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
	Else
		oSection1:Cell("AEXERANT"):SetBlock( { || "" })
		oSection1:Cell("AEXERCICIO"):SetBlock( { || "" })
	EndIf

	If lNotaExp
		cNotaA := CodeNota(aRecDisp[1][1][C_CONTA])
		If !Empty(cNotaA)
			oSection1:Cell("ANE"):SetBlock( { || cNotaA } )
		EndIf
	EndIf

	//Coluna 2
	If Len(aRecDisp[2])> 0
		oSection1:Cell("PEXERANT"):SetBlock( { || ValorCTB( aRecDisp[2][1][C_VALANT],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )		
		oSection1:Cell("PEXERCICIO"):SetBlock( { || ValorCTB( aRecDisp[2][1][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
	Else
		oSection1:Cell("PEXERANT"):SetBlock( { || "" })
		oSection1:Cell("PEXERCICIO"):SetBlock( { || "" })
	EndIf

	If lNotaExp
		cNotaP := CodeNota(aRecDisp[2][1][C_CONTA])
		If !Empty(cNotaP)
			oSection1:Cell("PNE"):SetBlock( { || cNotaP } )
		EndIf
	EndIf

Else
	//Coluna 1
	oSection1:Cell("AEXERCICIO"):SetBlock( { || ValorCTB( aRecDisp[1][1][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )

	//Coluna 2
	oSection1:Cell("PEXERCICIO"):SetBlock( { || ValorCTB( aRecDisp[2][1][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
EndIf
oSection1:PrintLine()
oReport:ThinLine()

PulaLinha(oSection1)
oReport:ThinLine()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} QuadroTot
Grava array do quadro de Total

@author TOTVS
@since 24/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function QuadroTot(aTotOrc,aTotExt,aRecDisp,aTotGer)
Local nI := 0

aTotGer := { {{nil,nil,nil,0,0}}, {{nil,nil,nil,0,0}} }

For nI := 1 to Len(aTotOrc)
	If Len(aTotOrc[nI]) > 0
		aTotGer[nI,1,C_VALANT] += Abs(aTotOrc[nI,1,C_VALANT])
		aTotGer[nI,1,C_VALATU] += Abs(aTotOrc[nI,1,C_VALATU])
	EndIf
Next nI

For nI := 1 to Len(aTotExt)
	If Len(aTotExt[nI]) > 0
		aTotGer[nI,1,C_VALANT] += Abs(aTotExt[nI,1,C_VALANT])
		aTotGer[nI,1,C_VALATU] += Abs(aTotExt[nI,1,C_VALATU])
	EndIf
Next nI

For nI := 1 to Len(aRecDisp)
	If Len(aRecDisp[nI]) > 0
		aTotGer[nI,1,C_VALANT] += Abs(aRecDisp[nI,1,C_VALANT])
		aTotGer[nI,1,C_VALATU] += Abs(aRecDisp[nI,1,C_VALATU])
	EndIf	
Next nI

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} ImpQuadTot
Imprime quadro total

@author TOTVS
@since 24/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ImpQuadTot(oSection1,atotGer,aTamVal,nDecimais,cPicture,lCharSinal,nPeriodos)

oSection1:Cell("ATIVO"):SetBlock( { || STR0029 } ) //"TOTAL"
oSection1:Cell("PASSIVO"):SetBlock( { || STR0029 } ) //"TOTAL"

If lPeriodoAnt
	//Coluna 1
	if Len(atotGer[1])>0
		oSection1:Cell("AEXERANT"):SetBlock( { || ValorCTB( atotGer[1][1][C_VALANT],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
		oSection1:Cell("AEXERCICIO"):SetBlock( { || ValorCTB( atotGer[1][1][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
	Else
		oSection1:Cell("AEXERANT"):SetBlock( { || "" })
		oSection1:Cell("AEXERCICIO"):SetBlock( { || "" })
	EndIf

	If lNotaExp		
		oSection1:Cell("ANE"):SetBlock( { || "" } )		
	EndIf

	//Coluna 2
	If Len(atotGer[2])> 0
		oSection1:Cell("PEXERANT"):SetBlock( { || ValorCTB( atotGer[2][1][C_VALANT],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
		oSection1:Cell("PEXERCICIO"):SetBlock( { || ValorCTB( atotGer[2][1][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
	Else
		oSection1:Cell("PEXERANT"):SetBlock( { || "" })
		oSection1:Cell("PEXERCICIO"):SetBlock( { || "" })
	EndIf

	If lNotaExp
		oSection1:Cell("PNE"):SetBlock( { || "" } )		
	EndIf

Else
	//Coluna 1
	oSection1:Cell("AEXERCICIO"):SetBlock( { || ValorCTB( atotGer[1][1][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )

	//Coluna 2
	oSection1:Cell("PEXERCICIO"):SetBlock( { || ValorCTB( atotGer[2][1][C_VALATU],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
EndIf
oSection1:PrintLine()
oReport:ThinLine()
Return
//-------------------------------------------------------------------
/*{Protheus.doc} Code_NE()
Retorna o codigo da nota explicativa - tabela QLQ

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function Code_NE()
Return( QLQ->QLQ_CODIGO )

//-------------------------------------------------------------------
/*{Protheus.doc} Data_NE()
Retorna a data da nota explicativa - tabela QLQ

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function Data_NE()
Return( DtoC( QLQ->QLQ_DATA ) )
//-------------------------------------------------------------------
/*{Protheus.doc} Observ_NE()
Retorna as observações da nota explicativa - tabela QLQ

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function Observ_NE()
Return( QLQ->QLQ_DESCNE )
//-------------------------------------------------------------------
/*{Protheus.doc} Code_NE()
Retorna o codigo da nota explicativa - tabela QLQ

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function CodeNota(cContaGer)
Local cCodeNota := ""
Local nRegQLQ := 0
Local aArea     := GetArea()
Local aAreaQLQ  := QLQ->( GetArea() )
Local dDataIni	:= mv_par01
Local dDataFim	:= mv_par02

DEFAULT cContaGer := ""

//busca pela codigo da conta gerencial + data
//indice 1 -> QLQ_FILIAL+QLQ_CODPLA+QLQ_CODIGO+QLQ_CONTAG
//indice 2 -> QLQ_FILIAL+QLQ_CODPLA+QLQ_CONTAG+DTOS(QLQ_DATA)
QLQ->( dbSetOrder(2) )

//primeiro busca na data
If QLQ->( dbSeek( xFilial("QLQ")+_cCodVisao+cContaGer+DtoS(dDataFim) ) )
	cCodeNota := QLQ->QLQ_CODIGO
	
	If !(aScan(_aNotaExplic,{|x| x == QLQ->(Recno()) }) > 0)
		aAdd( _aNotaExplic, QLQ->( Recno() ) )
	EndIf

ElseIf QLQ->( dbSeek( xFilial("QLQ")+_cCodVisao+cContaGer) )
	
	//laco para percorrer todas as notas explicativas para visao / conta gerencial
	While QLQ->( ! Eof() .And. QLQ_FILIAL+QLQ_CODPLA+QLQ_CONTAG == xFilial("QLQ")+_cCodVisao+cContaGer )

		If QLQ->QLQ_DATA >= dDataIni .And. QLQ->QLQ_DATA <= dDataFim
			cCodeNota := QLQ->QLQ_CODIGO
			nRegQLQ   := QLQ->( Recno() )
		EndIf

		QLQ->( dbSkip() )

	EndDo

	If ! Empty( cCodeNota ) .And. !(aScan(_aNotaExplic,{|x| x == QLQ->(Recno()) }) > 0)		
		aAdd( _aNotaExplic,  nRegQLQ )
	EndIf

EndIf

RestArea( aAreaQLQ )
RestArea( aArea )

Return( cCodeNota )
