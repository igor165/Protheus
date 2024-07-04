#INCLUDE "CTBR512P.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE 	TAM_VALOR 			20

STATIC _oTmpTable


/*/{Protheus.doc} CTBR512P
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function CTBR512P()

Local cPerg	   	:= "CTBR512P" 
Local lRet      := .T.

Private aSelFil	 	:= {}

If !Pergunte(cPerg,.T.) 
	Return .F.
Endif    

/*PERGUNTE
MV_PAR01 - Ano ?
MV_PAR02 - Mês ?
MV_PAR03 - Cod. Config. Livros ?
MV_PAR04 - Limite Máximo RCL ?	
MV_PAR05 - Limite Prudencial RCL ?	
MV_PAR06 - Limite Alerta RCL ?	
MV_PAR07 - Moeda ?	
MV_PAR08 - Tipo de Saldo ?
MV_PAR09 - Saldos Zerados ?
MV_PAR10 - Divide Por ?	
MV_PAR11 - Seleciona Filiais ?           
*/

// Faz a validacao das filiais
If lRet .And. mv_par11 == 1 
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf                             
EndIf

// Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano
// Gerencial -> montagem especifica para impressao)
// faz a validação do livro
If lRet .And. !Empty( mv_par03 ) 
	If !VdSetOfBook( mv_par03 , .F. )
		lRet := .F.
	EndIf
EndIf

If lRet
 
	oReport := ReportDef() 

	oReport:PrintDialog()
	      
EndIf

Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Esta funcao tem como objetivo definir as secoes, celulas,
totalizadores do relatorio que poderao ser configurados pelo relatorio.

@author TOTVS
@since 12/06/2020
@version 12.1.30
@return oReport - Objeto da classe TReport
/*/
//---------------------------------------------------------------------------------------
Static Function ReportDef()  
local aArea	   		:= GetArea()   
Local cReport		:= "CTBR512P"
Local cTitulo		:= STR0001 //"Demonstrativo da Despesa com Pessoal (DCA)" //Demonstrativo da Despesa com Pessoal (DCA)
Local cDESC			:= STR0002 //"Este programa ira imprimir o Demonstrativo da Despesa com Pessoal (DCA), de acordo com os parâmetros informados pelo usuário."
Local aSetOfBook	:= {}
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""

Local cPerg	   	:= "CTBR512P" 
//Local nomeprog	:= "CTBR512P" 
Local oSection1
Local oCabec
Local oBorder

If type("aSelFil")=="U"
	Private aSelFil := {}
EndIf

Pergunte(cPerg,.F.) 

//Filtra Filiais
If mv_par11 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
EndIf 

If Len( aSelFil ) <= 0
	aSelFil := { cFilAnt }
EndIf

// seta o livro
aSetOfBook := CTBSetOf(mv_par03)
	
// seta a moeda
aCtbMoeda	:= CtbMoeda(MV_PAR07, aSetOfBook[9])

If Empty(aCtbMoeda[1])
	Help(" ",1,"NOMOEDA")
	Return .F.
EndIf	
        
cDescMoeda 	:= AllTrim(aCtbMoeda[3])

oReport	:= TReport():New( cReport,cTitulo,cPerg,;
	{ |oReport| Pergunte(cPerg,.F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, CDESC)

oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,ctitulo,,,,,oReport) } )                                        		

// Define o tamanho da fonte a ser impressa no relatorio
oReport:nFontBody := 5
oReport:SetLandScape(.T.)       //define q relatorio sera sempre em paisagem
oReport:DisableOrientation()
//somente leitura dos parametros do pergunte
oReport:ParamReadOnly()

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

oSection1  := TRSection():New( oReport, STR0046, {"CT1","cArqTmp"},, .F., .F. ) //"DESPESAS"

TRCell():New( oSection1, "CONTA"    , , STR0003					     				/*Titulo*/,/*Picture*/,       50,/*lPixel*/,{||DescCtGer()}/*CodeBlock*/,"LEFT",.T.,"CENTER")  //"DESPESAS COM PESSOAL" 
TRCell():New( oSection1, "COLUNA1"  , , "COLUNA1"     								/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA2"  , , "COLUNA2"     								/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA3"  , , "COLUNA3"     								/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA4"  , , "COLUNA4"      								/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA5"  , , "COLUNA5"      								/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA6"  , , "COLUNA6"      								/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA7"  , , "COLUNA7"      								/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA8"  , , "COLUNA8"      								/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA9"  , , "COLUNA9"      								/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA10" , , "COLUNA10"       							/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA11" , , "COLUNA11"       							/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA12" , , "COLUNA12"     								/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "TOTAL"    , , STR0005 									/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT") //"Total"
TRCell():New( oSection1, "INSCRITA" , , STR0006+CRLF+STR0007+CRLF+STR0008			/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")  //"Inscritas em "##" Restos a Pagar "##"não Processados"
TRCell():New( oSection1, "COL_FAKE" , , " ___ "										/*Titulo*/,/*Picture*/,        3,/*lPixel*/,{||"  "}/*CodeBlock*/,"RIGHT",,"RIGHT")

oSection1:SetTotalInLine(.F.)        

oBorder := TRBorder():New(oReport, 5,, 0)
//Criacao da Secao Cabecalho
oCabec := TRSection():New(oReport, STR0009, {}, /*aOrdem*/)  //"Exercício"
TRCell():New(oCabec, "EXERCICIO",, "",, 120, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder   //Remove a borda do cabecalho
oCabec:SetLinesBefore(0)

//Criacao da Secao Quadro Despesa com Pessoal
//Grupo: "Tabela 1.0 - Demonstrativo da Despesa com Pessoal" 
//Quadro: "Despesa com Pessoal" 
oQuadro1 := TRSection():New(oReport, STR0030, {}, /*aOrdem*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , /*<lLineBreak>*/ , /*<nLeftMargin>*/ , .T./*<lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 0 /*<nLinesBefore>*/ , 1/*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ ) //"Quadro I"
TRCell():New(oQuadro1, "GRUPO_I"	,, STR0031	,, 80, /*lPixel*/, {||STR0034 }/*CodeBlock*/,,,,,,,,, .T.)  //"Grupo"##"Tabela 1.0 - Demonstrativo da Despesa com Pessoal"
TRCell():New(oQuadro1, "QUADRO_I"	,, STR0032	,, 80, /*lPixel*/, {||STR0035}/*CodeBlock*/,,,,,,,,, .T.)  //"Quadro"##"Despesa com Pessoal"

//Criacao da Secao Quadro Despesa com Pessoal
//Grupo: Tabela 1.0 - Demonstrativo da Despesa com Pessoal 
//Quadro: DTP e Apuração do Cumprimento do Limite Legal 
//Rótulo: Padrão 
oQuadro2 := TRSection():New(oReport, STR0048, {}, /*aOrdem*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , /*<lLineBreak>*/ , /*<nLeftMargin>*/ , .T./*<lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 0 /*<nLinesBefore>*/ , 1/*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ ) //"Quadro II"
TRCell():New(oQuadro2, "GRUPO_II"	,, STR0031	,, 80, /*lPixel*/, {||STR0034 }/*CodeBlock*/,,,,,,,,, .T.)  //"Grupo"##"Tabela 1.0 - Demonstrativo da Despesa com Pessoal"
TRCell():New(oQuadro2, "QUADRO_II"	,, STR0032	,, 80, /*lPixel*/, {||STR0036}/*CodeBlock*/,,,,,,,,, .T.)  //"Quadro" ## "DTP e Apuração do Cumprimento do Limite Legal"
TRCell():New(oQuadro2, "ROTULO"		,, STR0033	,, 80, /*lPixel*/, {||STR0037}/*CodeBlock*/,,,,,,,,, .T.)  //"Rótulo" ##"Padrão"


//Criacao da Secao Quadro Despesa com Pessoal
//DTP e Apuração do Cumprimento do Limite Legal 	DTP e Apuração do Cumprimento do Limite Legal 		
//                                                      	Valor 	      % sobre a RCL Ajustada 	
oSection2  := TRSection():New( oReport, STR0047, {"CT1","cArqTmp"},, .F., .F. ) //"DTP_APURACAO"

TRCell():New( oSection2, "DESCRICAO"    , , STR0036						/*Titulo*/,/*Picture*/,       50,/*lPixel*/,{||DescCtGer()}/*CodeBlock*/,"LEFT",.T.,"CENTER") // "DTP e Apuração do Cumprimento do Limite Legal"
TRCell():New( oSection2, "VALOR"  		, , STR0038    					/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")  //"Valor" 
TRCell():New( oSection2, "PERCENT"  	, , STR0039+CRLF+STR0040		/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")  //"% sobre a" ## " RCL Ajustada"

RestArea(aArea)
           
Return(oReport)

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint( oReport )
Local oSection1      := oReport:Section(1) 
Local oCabec         := oReport:Section(2)
Local oQuadro1       := oReport:Section(3)
Local oQuadro2       := oReport:Section(4)
Local oSection2      := oReport:Section(5) 

Local cAno      := MV_PAR01 //Ano ?
Local cMes      := MV_PAR02 //Mês ?
Local cLivro    := MV_PAR03 //Cod. Config. Livros ?
Local nPLMax    := MV_PAR04 //Limite Máximo RCL ?	
Local nPLPru    := MV_PAR05 //Limite Prudencial RCL ?	
Local nPLAle    := MV_PAR06 //Limite Alerta RCL ?	
Local cMoeda    := MV_PAR07 //Moeda ?	
Local cTpSaldo  := MV_PAR08 //Tipo de Saldo ?
Local lSldZ     := Iif(MV_PAR09==1,.T.,.F.) //Saldos Zerados ?
Local nDvPor    := MV_PAR10 //Divide Por ?	

Local dDataIni  
Local dDataFim 
Local lPlanilha := .F.  //Imprime Excel
Local nDivide   := 1    //Divide por
Local aCtbMoeda := {}
Local cContaI	:= Replicate(' ',Len(CT1->CT1_CONTA))
Local cContaF	:= Replicate('z',Len(CT1->CT1_CONTA))
Local cString		:= "CT1"

Local aMeses := {}
Local nCont	:= 0 

// seta o livro
Local aSetOfBook := CTBSetOf( cLivro )

Local cArqTmp := ""
Local cHeader := "SLD"
Local cFilter := ""

Local nDecimais	:= 0
Local cPicture	:= ""
Local aTitMes   := {STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,STR0020,STR0021}  //"Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"
Local cTitMesAno:= ""

Local bColTotal := {|| cArqTmp->COLUNA1 +;
						cArqTmp->COLUNA2 +; 
						cArqTmp->COLUNA3 +; 
						cArqTmp->COLUNA4 +; 
						cArqTmp->COLUNA5 +; 
						cArqTmp->COLUNA6 +; 
						cArqTmp->COLUNA7 +; 
						cArqTmp->COLUNA8 +; 
						cArqTmp->COLUNA9 +; 
						cArqTmp->COLUNA10 +;
						cArqTmp->COLUNA11 +;
						cArqTmp->COLUNA12 }

Local bColInscr := {| cConta, cAliasSld | R512PValCta(cConta, cAliasSld) }

Local aMoedas    := CtbMoeda(cMoeda) 
Local nRecCorLiq := 0
Local nTrfUniao  := 0
Local nRecCorAj  := 0
Local nDespTot   := 0
Local nValQuadro := 0
Local aTotal_I_ := {}
Local aTotal_II_ := {}
Local dIniAux    := CTOD("  /  /  ")
Local cAliasSld  := GetNextAlias()
Local cTbSldRP   := ""  //nome real da tabela q possui saldos Restos a Pagar

If oReport:nDevice == 4
	lPlanilha := .T.
EndIf 

//Divide Por
If nDvPor == 2			// Divide por cem
	nDivide := 100
ElseIf nDvPor == 3		// Divide por mil
	nDivide := 1000
ElseIf nDvPor == 4		// Divide por milhao
	nDivide := 1000000
EndIf	
aSetOfBook[9] := nDivide  //tem que passar para posicao 9 do aSetOfBook - senao não funciona nDivide CTGERPLAN / CTGERCOMP

aCtbMoeda  	:= CtbMoeda(cMoeda,nDivide)

cDescMoeda 	:= Alltrim(aCtbMoeda[2])	

nDecimais := DecimalCTB(aSetOfBook,cMoeda)
cPicture  := AllTrim( aSetOfBook[4] )

oReport:OnPageBreak( {|| ImpCabec( oReport, oCabec, aMoedas, nDvPor /*divide por*/, dDataFim) } )

//Data inicio e data fim 
dDataIni := MonthSub(stod(cAno+cMes+'01'),11)  //diminui 11 meses
dDataFim := LastDay( STOD(cAno+cMes+'01') )

dIniAux := dDataIni
For nCont := 1 to 12
	aAdd(aMeses, { StrZero(nCont,2), FirstDay(dIniAux), LastDay(dIniAux) })
	dIniAux := LastDay(dIniAux) + 1
Next
//-----------------------------------------------------------------------------------------------------------
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd, @cArqTmp, aMeses[1,2], dDataFim;
					  , "", "", "", Repl( "Z", Len( CT1->CT1_CONTA )), ""; 
					  , Repl( "Z", Len(CTT->CTT_CUSTO)), "", Repl("Z", Len(CTD->CTD_ITEM));
					  , "", Repl("Z", Len(CTH->CTH_CLVL)), cMoeda, cTpSaldo, aSetOfBook, Space(2);
					  , Space(20), Repl("Z", 20), Space(30),,,,, .F./*lPosAntLP*/, CTOD("  /  /  ")/*dDataLP*/;
					  ,nDivide,lSldZ,,,,,,,,,,,,,,,,,,,,,,,,,cMoeda,.F./*lMovPeriodo*/,aSelFil,,.T.,.F./*lConsSaldo*/,,,,,,,,,,,)};
			,STR0022, STR0001) //"Criando Arquivo Tempor rio..."##"Demonstrativo da Despesa com Pessoal"

dbSelectArea("cArqTmp")           

//criar arquivo temporario para busca dos restos a pagar e valor receita corrente liquida / transferencias legais da Uniao
cTbSldRP     := CriaTmpSld( cAliasSld, ("cArqTmp") ->( DBStruct() ) )

dbSelectArea("cArqTmp")           
dbGoTop()

nRecCorLiq := 0
nTrfUniao := 0

While ("cArqTmp")->( ! Eof() )
	If Alltrim( ("cArqTmp")->CONTA ) == "1.4.1" 
		nRecCorLiq := ("cArqTmp")->SALDOATU
	ElseIf Alltrim( ("cArqTmp")->CONTA )  == "1.4.2" 
		nTrfUniao := ("cArqTmp")->SALDOATU
	EndIf
    //copia do registro da ctgerplan para arq temporario table
	(cAliasSld)->( RecLock(cAliasSld, .T.) )
	For nCont := 1 to (cAliasSld)->( Fcount() )
		(cAliasSld)->( FieldPut( nCont, ("cArqTmp")->( FieldGet(nCont) ) ) )
	Next
	(cAliasSld)->( MsUnlock() ) 

	("cArqTmp")->( dbSkip() )

EndDo
//fecha alias da ctgerplan
("cArqTmp")->( dbCloseArea() )
//-----------------------------------------------------------------------------------------------------------

MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerComp(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				dDataIni,dDataFim,"CT7","",cContaI,cContaF,,,,,,,cMoeda,;
				cTpSaldo,aSetOfBook,,,,,;
				.F.,.F.,,cHeader,,,nDivide,"M"/*Saldo*/,.F.,,.T.,aMeses,lSldZ,,,.T./*lImpSint*/,cString,/*cFilUser*/,;
				/*lImpTotS*/,/*lImp4Ent*/,/*c1aEnt*/,/*c2aEnt*/,/*c3aEnt*/,/*c4aEnt*/,/*lAtSlBase*/,/*lValMed*/,/*lSalAcum*/,aSelFil,/*lTodasFil*/,/*cNomeTab*/)},;
				STR0022, STR0001) //"Criando Arquivo Tempor rio..."##"Demonstrativo da Despesa com Pessoal"

TRPosition():New(oSection1,"CT1",1,{|| xFilial("CT1")+cArqTmp->CONTA })
If Select("cArqTmp") == 0
	Return
EndIf			
				
dbSelectArea("cArqTmp")
dbGoTop()        
cArqTmp := Alias()

cDifZero := " (cArqTmp->COLUNA1  <> 0 .OR. cArqTmp->COLUNA2  <> 0 .OR. cArqTmp->COLUNA3  <> 0 .OR. "
cDifZero += "  cArqTmp->COLUNA4  <> 0 .OR. cArqTmp->COLUNA5  <> 0 .OR. cArqTmp->COLUNA6  <> 0 .OR. "
cDifZero += "  cArqTmp->COLUNA7  <> 0 .OR. cArqTmp->COLUNA8  <> 0 .OR. cArqTmp->COLUNA9  <> 0 .OR. "
cDifZero += "  cArqTmp->COLUNA10 <> 0 .OR. cArqTmp->COLUNA11 <> 0 .OR. cArqTmp->COLUNA12 <> 0)"
							           
If !lSldZ
	If Empty(cFilter)
		cFilter := cDifZero
	Endif
EndIf

oSection1:SetFilter( cFilter )                                                

For nCont := 1 to Len(aMeses)     
	cColVal := "COLUNA"+Alltrim(Str(nCont))   //nao traduzir string "COLUNA", pois eh nome de campo/celula
	cTitMesAno:= STR0023+CRLF+aTitMes[Month(aMeses[nCont,2])]+"/"+Left(DTOS(aMeses[nCont,2]),4)  //" LIQUIDADAS "
	oSection1:Cell(cColVal):SetTitle(cTitMesAno)	
Next

oSection1:Cell("COLUNA1"):SetBlock ( { || ValorCTB(cArqTmp->COLUNA1 ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("COLUNA2"):SetBlock ( { || ValorCTB(cArqTmp->COLUNA2 ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("COLUNA3"):SetBlock ( { || ValorCTB(cArqTmp->COLUNA3 ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("COLUNA4"):SetBlock ( { || ValorCTB(cArqTmp->COLUNA4 ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("COLUNA5"):SetBlock ( { || ValorCTB(cArqTmp->COLUNA5 ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("COLUNA6"):SetBlock ( { || ValorCTB(cArqTmp->COLUNA6 ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("COLUNA7"):SetBlock ( { || ValorCTB(cArqTmp->COLUNA7 ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("COLUNA8"):SetBlock ( { || ValorCTB(cArqTmp->COLUNA8 ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("COLUNA9"):SetBlock ( { || ValorCTB(cArqTmp->COLUNA9 ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("COLUNA10"):SetBlock( { || ValorCTB(cArqTmp->COLUNA10,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("COLUNA11"):SetBlock( { || ValorCTB(cArqTmp->COLUNA11,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("COLUNA12"):SetBlock( { || ValorCTB(cArqTmp->COLUNA12,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("TOTAL"):SetBlock(    { || ValorCTB(Eval(bColTotal)  ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("INSCRITA"):SetBlock( { || ValorCTB(Eval(bColInscr,cArqTmp->CONTA,cAliasSld)  ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )

dbSelectArea("cArqTmp")
oQuadro1:Init()
oQuadro1:PrintLine()
oQuadro1:Finish()
oReport:ThinLine()

aTotal_I_ := Array(12)
aTotal_II_ := Array(12)

oSection1:Init()
While (cArqTmp)->( ! Eof() .And. CONTA < "1.4 " )

	If 		Alltrim( (cArqTmp)->CONTA ) == "1"  //nao exibe conteudo nesta conta sintetica - somente agrupamento 

		For nCont := 1 to 12     
			cColVal := "COLUNA"+Alltrim(Str(nCont))   //nao traduzir string "COLUNA", pois eh nome de campo/celula
			oSection1:Cell(cColVal):Hide()
		Next
		oSection1:Cell("TOTAL"):Hide()
		oSection1:Cell("INSCRITA"):Hide()

	ElseIf Alltrim( (cArqTmp)->CONTA ) == "1.1"  //armazenar em array totalizador (I) sintetica

			For nCont := 1 to 12     
				cColVal := "COLUNA"+Alltrim(Str(nCont))   //nao traduzir string "COLUNA", pois eh nome de campo/celula
				aTotal_I_[nCont] := (cArqTmp)->&(cColVal)
			Next

	ElseIf Alltrim( (cArqTmp)->CONTA ) == "1.2"	//armazenar em array totalizador (II) sintetica
	
			For nCont := 1 to 12     
				cColVal := "COLUNA"+Alltrim(Str(nCont))   //nao traduzir string "COLUNA", pois eh nome de campo/celula
				aTotal_II_[nCont] := (cArqTmp)->&(cColVal)
			Next

	ElseIf Alltrim( (cArqTmp)->CONTA ) == "1.3"	//grava total e salva despesas totais com pessoal na variavel para quadro II
	
			nDespTot := 0
			(cArqTmp)->( RecLock(cArqTmp, .F.) )
			For nCont := 1 to 12     
				cColVal := "COLUNA"+Alltrim(Str(nCont))   //nao traduzir string "COLUNA", pois eh nome de campo/celula
				(cArqTmp)->&(cColVal) := ( aTotal_I_[nCont] - aTotal_II_[nCont] )    //formula TOTAL ( I - ii )
				nDespTot += ( aTotal_I_[nCont] - aTotal_II_[nCont] )   //salva em variavel total despesas para quadro II
			Next
			(cArqTmp)->( MsUnlock() )

	EndIf

	oSection1:PrintLine()

	If Alltrim( (cArqTmp)->CONTA ) == "1"  //Volta a exibir as colunas 
		For nCont := 1 to 12     
			cColVal := "COLUNA"+Alltrim(Str(nCont))   //nao traduzir string "COLUNA", pois eh nome de campo/celula
			oSection1:Cell(cColVal):Show()
		Next
		oSection1:Cell("TOTAL"):Show()
		oSection1:Cell("INSCRITA"):Show()
	EndIf
	//avanca registro
	(cArqTmp)->( dbSkip() )

Enddo
oSection1:Finish()

//inicio do quadro II
oReport:ThinLine()
oQuadro2:Init()
oQuadro2:PrintLine()
oQuadro2:Finish()
oReport:ThinLine()

oSection2:Init()
oSection2:Cell("VALOR")  :SetBlock ( { || ValorCTB( nValQuadro ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection2:Cell("PERCENT"):SetBlock ( { || "" } )
//continua laco principal para quadro II
While (cArqTmp)->( ! Eof() )
	If Alltrim( (cArqTmp)->CONTA ) == "1.4" 
		nValQuadro := 0
	ElseIf Alltrim( (cArqTmp)->CONTA ) == "1.4.1" 
		nValQuadro := nRecCorLiq
	ElseIf Alltrim( (cArqTmp)->CONTA )  == "1.4.2" 
		nValQuadro := nTrfUniao
	EndIf
	oSection2:PrintLine()
	(cArqTmp)->( dbSkip() )
Enddo
/*
Linhas abaixo sao calculadas: 
  = RECEITA CORRENTE LÍQUIDA AJUSTADA (VI) 
  DESPESA TOTAL COM PESSOAL - DTP (VII) = (III) 
  LIMITE MÁXIMO (VIII) (incisos I, II e III, art. 20 da LRF) 
  LIMITE PRUDENCIAL (IX) = (0,95 x VIII) (parágrafo único do art. 22 da LRF) 
  LIMITE DE ALERTA (X) = (0,90 x VIII) (inciso II do §1º do art. 59 da LRF) 
*/
nRecCorAj := nRecCorLiq - nTrfUniao
oSection2:Cell("DESCRICAO"):SetBlock ( { || STR0041 } )  //"= RECEITA CORRENTE LÍQUIDA AJUSTADA (VI) "
oSection2:Cell("VALOR")    :SetBlock ( { || ValorCTB( nRecCorAj  ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection2:Cell("PERCENT")  :SetBlock ( { || "" } )
oSection2:PrintLine()

oSection2:Cell("DESCRICAO"):SetBlock ( { || STR0042 } )  //"DESPESA TOTAL COM PESSOAL - DTP (VII) = (III) "
oSection2:Cell("VALOR")    :SetBlock ( { || ValorCTB( nDespTot ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection2:Cell("PERCENT")  :SetBlock ( { || TRANSFORM( nDespTot/nRecCorAj*100, "@E 999.99") } )
oSection2:PrintLine()

oSection2:Cell("DESCRICAO"):SetBlock ( { || STR0043 } )  //"LIMITE MÁXIMO (VIII) (incisos I, II e III, art. 20 da LRF)"
oSection2:Cell("VALOR")    :SetBlock ( { || ValorCTB(nRecCorLiq*nPLMax/100 ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection2:Cell("PERCENT")  :SetBlock ( { || TRANSFORM(nPLMax, "@E 999.99") } )
oSection2:PrintLine()

oSection2:Cell("DESCRICAO"):SetBlock ( { || STR0044 } )  //"LIMITE PRUDENCIAL (IX) = (0,95 x VIII) (parágrafo único do art. 22 da LRF)  "
oSection2:Cell("VALOR")    :SetBlock ( { || ValorCTB(nRecCorLiq*nPLPru/100 ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection2:Cell("PERCENT")  :SetBlock ( { || TRANSFORM(nPLPru, "@E 999.99") } )
oSection2:PrintLine()

oSection2:Cell("DESCRICAO"):SetBlock ( { || STR0045 } )   //"LIMITE DE ALERTA (X) = (0,90 x VIII) (inciso II do §1º do art. 59 da LRF) "
oSection2:Cell("VALOR")    :SetBlock ( { || ValorCTB(nRecCorAj*nPLAle/100 ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection2:Cell("PERCENT")  :SetBlock ( { || TRANSFORM(nPLAle, "@E 999.99") } )
oSection2:PrintLine()

oSection2:Finish()

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea() 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF

If _oTmpTable <> Nil
	_oTmpTable:Delete()
    _oTmpTable := Nil
EndIf

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} DescCtGer
Cabecalho do relatorio - imprimir em todas as paginas

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function DescCtGer()
Local cDescConta := ""

cDescConta += Alltrim(("cArqTmp")->CONTA)+"-"+Alltrim(("cArqTmp")->DESCCTA)

Return( cDescConta )

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCabec
Cabecalho do relatorio - imprimir em todas as paginas

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function ImpCabec( oReport, oCabec, aMoedas, nDivPor, dDataFim )
Local cUnidMoed := ""

If     nDivPor == 2
    cUnidMoed := STR0024 //"Centena de "
ElseIf nDivPor == 3
    cUnidMoed := STR0025 //"Milhares de "
ElseIf nDivPor == 4
    cUnidMoed := STR0026 //"Milhoes de "
EndIf

//Imprime cabecalho
oCabec:Init()
oCabec:Cell("EXERCICIO"):SetBlock({|| STR0027+ SubStr(DToS(dDataFim), 1, 4) + "            ("+STR0028+AllTrim(cUnidMoed)+": " + AllTrim(aMoedas[3]) +  ")          "+STR0029})  //"Valores expressos em " //"Exercício: "##"Periodicidade: Mensal "
oCabec:PrintLine()
oCabec:Finish()

oReport:ThinLine()

Return

//---------------------------------------------------
/*/{Protheus.doc} R512PValCta
Retorna o saldo anterior da conta 

@author TOTVS

@param cConta      Conta Gerencial 


@version P12
@since   31/03/2020
@return  nValCta
/*/
//---------------------------------------------------
Static Function R512PValCta(cConta, cAliasSld)
Local aArea := GetArea()
Local nValCta := 0
If (cAliasSld)->( dbSeek(cConta) )
	nValCta := (cAliasSld)->( SALDOANT )
EndIf
RestArea(aArea)

Return nValCta

//---------------------------------------------------
/*/{Protheus.doc} CriaTmpSld
Cria a tabela temporária para montagem da estrutura 
que será retornada para a função chamadora

@author TOTVS

@param cArqtmp      Alias aberto para montar a temprary table
@param aCampos      Estrutura de Campos 

@version P12
@since   31/03/2020
@return  cArqTmp
/*/
//---------------------------------------------------
Static Function CriaTmpSld(cArqtmp,aCampos)
Local cTbNameRea  := ""
Local aChave	:= {"CONTA"}

DEFAULT cArqtmp := ""
DEFAULT aCampos := {}

If Select(cArqTmp) > 0
	(cArqTmp)->(dbCloseArea())
Endif

If _oTmpTable <> Nil .And. _oTmpTable:GetAlias() == cArqtmp
	_oTmpTable:Delete()
EndIf

_oTmpTable := FWTemporaryTable():New(cArqtmp)
_oTmpTable:SetFields( aCampos )
_oTmpTable:AddIndex("1", aChave)
_oTmpTable:Create()

cTbNameRea := _oTmpTable:GetRealName()

Return cTbNameRea

