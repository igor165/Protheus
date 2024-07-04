#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBR516P.CH"

#DEFINE 	TAM_VALOR 			20

STATIC _oTmpTable


/*/{Protheus.doc} CTBR516P
    ITEM 20 LRF | Desens. Rel.Anexo 3  - Demonstrativo da Receita Corrente Líquida
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
Function CTBR516P()

Local cPerg	   	:= "CTBR516P" 
Local lRet      := .T.

If !Pergunte(cPerg,.T.) 
	Return .F.
Endif    

/*PERGUNTE
MV_PAR01 - Ano ?
MV_PAR02 - Mês ?
MV_PAR03 - Cod. Config. Livros ?	
MV_PAR04 - Moeda ?	
MV_PAR05 - Tipo de Saldo ?
MV_PAR06 - Saldos Zerados ?
MV_PAR07 - Divide Por ?	        
*/

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
Local cReport		:= "CTBR516P"
Local cTitulo		:= STR0001 //"Demonstrativo da Receita Corrente Líquida" 
Local cDESC			:= STR0002 //"Este programa ira imprimir o Demonstrativo da Receita Corrente Líquida, de acordo com os parâmetros informados pelo usuário."
Local aSetOfBook	:= {}
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""

Local cPerg	   	:= "CTBR516P" 
Local oSection1
Local oCabec
Local oBorder

Pergunte(cPerg,.F.) 

// seta o livro
aSetOfBook := CTBSetOf(mv_par03)
	
// seta a moeda
aCtbMoeda	:= CtbMoeda(MV_PAR04, aSetOfBook[9])

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

oSection1  := TRSection():New( oReport, STR0003, {"CT1","cArqTmp"},, .F., .F. ) //"RECEITA"

TRCell():New( oSection1, "CONTA"    , , STR0004					     				/*Titulo*/,/*Picture*/,       70,/*lPixel*/,{||DescCtGer()}/*CodeBlock*/,"LEFT",.T.,"CENTER")  //"Especificação" 
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
TRCell():New( oSection1, "COL_FAKE" , , " ___ "										/*Titulo*/,/*Picture*/,        3,/*lPixel*/,{||"  "}/*CodeBlock*/,"RIGHT",,"RIGHT")

oSection1:SetTotalInLine(.F.)        

oBorder := TRBorder():New(oReport, 5,, 0)
//Criacao da Secao Cabecalho
oCabec := TRSection():New(oReport, STR0006 , {}, /*aOrdem*/)  //"Exercício"
TRCell():New(oCabec, "EXERCICIO",, "",, 120, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder   //Remove a borda do cabecalho
oCabec:SetLinesBefore(0)

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

Local cAno      := MV_PAR01 //Ano ?
Local cMes      := MV_PAR02 //Mês ?
Local cLivro    := MV_PAR03 //Cod. Config. Livros ?
Local cMoeda    := MV_PAR04 //Moeda ?	
Local cTpSaldo  := MV_PAR05 //Tipo de Saldo ?
Local lSldZ     := Iif(MV_PAR06==1,.T.,.F.) //Saldos Zerados ?
Local nDvPor    := MV_PAR07 //Divide Por ?	

Local dDataIni  
Local dDataFim 
Local lPlanilha := .F.  //Imprime Excel
Local nDivide   := 1    //Divide por
Local aCtbMoeda := {}
Local cContaI	:= Replicate(' ',Len(CT1->CT1_CONTA))
Local cContaF	:= Replicate('z',Len(CT1->CT1_CONTA))
Local cString	:= "CT1"

Local aMeses := {}
Local nCont	:= 0 

// seta o livro
Local aSetOfBook := CTBSetOf( cLivro )

Local cArqTmp := ""
Local cHeader := "SLD"
Local cFilter := ""

Local nDecimais	:= 0
Local cPicture	:= ""
Local aTitMes   := {STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018}  //"Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"
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


Local aMoedas    := CtbMoeda(cMoeda) 
Local aTotal := {}
Local dIniAux    := CTOD("  /  /  ")

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

MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerComp(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				dDataIni,dDataFim,"CT7","",cContaI,cContaF,,,,,,,cMoeda,;
				cTpSaldo,aSetOfBook,,,,,;
				.F.,.F.,,cHeader,,,nDivide,"M"/*Saldo*/,.F.,,.T.,aMeses,lSldZ,,,.T./*lImpSint*/,cString,/*cFilUser*/,;
				/*lImpTotS*/,/*lImp4Ent*/,/*c1aEnt*/,/*c2aEnt*/,/*c3aEnt*/,/*c4aEnt*/,/*lAtSlBase*/,/*lValMed*/,/*lSalAcum*/,,/*lTodasFil*/,/*cNomeTab*/)},;
				STR0019, STR0001) //"Criando Arquivo Tempor rio..."##"Demonstrativo da Receita Corrente Líquida" 

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
	cTitMesAno:= aTitMes[Month(aMeses[nCont,2])]+"/"+Left(DTOS(aMeses[nCont,2]),4)  
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

dbSelectArea("cArqTmp")
oReport:ThinLine()

aTotal := Array(12)

oSection1:Init()
While (cArqTmp)->( ! Eof())

	If Alltrim( (cArqTmp)->CONTA ) == "1"  //nao exibe conteudo nesta conta sintetica
		(cArqTmp)->( RecLock(cArqTmp, .F.) )
		For nCont := 1 to 12     
			cColVal := "COLUNA"+Alltrim(Str(nCont))   //nao traduzir string "COLUNA", pois eh nome de campo/celula
			(cArqTmp)->&(cColVal):= 0   //Deixa a linha 1 zerada
		Next
		(cArqTmp)->( MsUnlock() )
	ElseIf Alltrim( (cArqTmp)->CONTA ) == "1.1"  //armazenar em array totalizador (I) sintetica
		For nCont := 1 to 12     
			cColVal := "COLUNA"+Alltrim(Str(nCont))   //nao traduzir string "COLUNA", pois eh nome de campo/celula
			aTotal[nCont] := (cArqTmp)->&(cColVal)
		Next
	ElseIf Alltrim( (cArqTmp)->CONTA ) == "1.2"
		(cArqTmp)->( RecLock(cArqTmp, .F.) )
		For nCont := 1 to 12     
			cColVal := "COLUNA"+Alltrim(Str(nCont))   //nao traduzir string "COLUNA", pois eh nome de campo/celula
			(cArqTmp)->&(cColVal):= aTotal[nCont]     //formula TOTAL ( I - ii )
		Next
		(cArqTmp)->( MsUnlock() )
	EndIf
	oSection1:PrintLine()
	(cArqTmp)->( dbSkip() )
Enddo

oSection1:Finish()

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

If    nDivPor == 2
    cUnidMoed := STR0020 //"Centena de "
ElseIf nDivPor == 3
    cUnidMoed := STR0021 //"Milhares de "
ElseIf nDivPor == 4
    cUnidMoed := STR0022 //"Milhoes de "
EndIf

//Imprime cabecalho
oCabec:Init()
oCabec:Cell("EXERCICIO"):SetBlock({|| STR0006+ SubStr(DToS(dDataFim), 1, 4) + "            ("+STR0023+AllTrim(cUnidMoed)+": " + AllTrim(aMoedas[3]) +  ")          "+STR0024})  //"Valores expressos em " //"Exercício: "##"Periodicidade: Mensal "
oCabec:PrintLine()
oCabec:Finish()

oReport:ThinLine()

Return