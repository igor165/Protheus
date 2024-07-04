#INCLUDE "CTBR530P.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE 	TAM_VALOR 			30

STATIC _oTmpTable
Static _aNotaExplic   := {}
Static _nSpaces := 0
Static _cCodVisao := ""
Static _dRefIni   := ""
Static _dRefFim   := ""

/*/{Protheus.doc} CTBR530P
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
Function CTBR530P()

Local cPerg	   	:= "CTBR530P" 
Local lRet      := .T.

Private aSelFil	 	:= {}

/*PERGUNTE
MV_PAR01 - Ano-Exercício ?
MV_PAR02 - Considerar ?       Mov.Periodo / Saldo Acumulado
MV_PAR03 - Cod. Config. Livros ?
MV_PAR04 - Moeda ?	
MV_PAR05 - Tipo de Saldo ?
MV_PAR06 - Saldos Zerados ?
MV_PAR07 - Divide Por ?	
MV_PAR08 - Seleciona Filiais ?           
*/

SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.023"
    Help(,, "Help",, OemToAnsi(STR0001), 1, 0) //"Relatorio Demonstração das Mutações do Patrimônio Líquido disponível a partir da versao 12.1.23"
    lRet := .F.
ElseIf !SX1->(dbSeek(Padr(cPerg, Len(SX1->X1_GRUPO), " ")))
    Help(,, "Help",, OemToAnsi(STR0002), 1, 0) //"Para utilizaçao do relatorio Demonstração das Mutações do Patrimônio Líquido é necessário aplicar o pacote acumulado da controladoria."
    lRet := .F.
Else 
    //Perguntas do Relatório
    lRet := Pergunte(cPerg, .T.) 
EndIf  

// Faz a validacao das filiais
If lRet .And. mv_par08 == 1 
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
@since 26/10/2020
@version 12.1.30
@return oReport - Objeto da classe TReport
/*/
//---------------------------------------------------------------------------------------
Static Function ReportDef()  
local aArea	   		:= GetArea()   
Local cReport		:= "CTBR530P"
Local cTitulo		:= STR0003 //"Demonstração das Mutações do Patrimônio Líquido"
Local cDESC			:= STR0004 //"Este programa ira imprimir o relatório Demonstração das Mutações do Patrimônio Líquido, de acordo com os parâmetros informados pelo usuário."
Local aSetOfBook	:= {}
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""
Local cExercAnt     := Alltrim(Str(Val(MV_PAR01)-1))

Local cPerg	   	:= "CTBR530P" 

Local oSection1
Local oCabec
Local oBorder

If type("aSelFil")=="U"
	Private aSelFil := {}
EndIf

Pergunte(cPerg,.F.) 

//Filtra Filiais
If mv_par08 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
EndIf 

If Len( aSelFil ) <= 0
	aSelFil := { cFilAnt }
EndIf

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
oReport:nFontBody   := 8 //Define o tamanho da fonte
oReport:nLineHeight	:= 40 //Define a altura da linha.

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

oSection1  := TRSection():New( oReport, STR0008, {"cArqTmp"},, .F., .F. ) //"DMPL"

TRCell():New( oSection1, "CONTA"    , , STR0005					     				/*Titulo*/,/*Picture*/,       100,/*lPixel*/,{||DescCtGer()}/*CodeBlock*/,"LEFT",.T.,"CENTER")  //"DESCRIÇÃO"
TRCell():New( oSection1, "NOTEXP"   , , STR0006					     				/*Titulo*/,/*Picture*/,        10,/*lPixel*/,{||CodeNota()}/*CodeBlock*/,"LEFT",.T.,"CENTER")  //"NE"
TRCell():New( oSection1, "EXERCREF" , , STR0007+CRLF+Alltrim(MV_PAR01)    			/*Titulo*/,/*Picture*/, TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"  VALOR REALIZADO"##"No EXERCrimestre de"##" Referência "
TRCell():New( oSection1, "EXERCANT" , , STR0007+CRLF+Alltrim(cExercAnt)      		/*Titulo*/,/*Picture*/, TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"  VALOR REALIZADO"##"Até o EXERCrimestre de"##" Referência " 
TRCell():New( oSection1, "COL_FAKE" , , " ___ "										/*Titulo*/,/*Picture*/,         3,/*lPixel*/,{||"  "}/*CodeBlock*/,"RIGHT",,"RIGHT")

oSection1:SetTotalInLine(.F.)        

oBorder := TRBorder():New(oReport, 5,, 0)
//Criacao da Secao Cabecalho
oCabec := TRSection():New(oReport, STR0009, {}, /*aOrdem*/)  //"Exercício"
TRCell():New(oCabec, "EXERCICIO",, "",, 120, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder   //Remove a borda do cabecalho
oCabec:SetLinesBefore(0)

//Criacao da Secao Quadro I - TITULO DO RELATORIO
oQuadro1 := TRSection():New(oReport, STR0010, {}, /*aOrdem*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , /*<lLineBreak>*/ , /*<nLeftMargin>*/ , .T./*<lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 0 /*<nLinesBefore>*/ , 1/*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ ) //"Quadro I"
TRCell():New(oQuadro1, "TITREL1"		,, ""	,, 140, /*lPixel*/, {||Space(_nSpaces)+STR0003}/*CodeBlock*/,,,,,,,,, .T.)  //"Demonstração das Mutações do Patrimônio Líquido"
TRCell():New(oQuadro1, "TITREL2"		,, ""	,, 140, /*lPixel*/, {||Space(_nSpaces)+STR0015+MV_PAR01}/*CodeBlock*/,,,,,,,,, .T.)  //"Em 31 de Dezembro de "+MV_PAR01

//Criacao da Secao Nota Explicativa
oNotExplic := TRSection():New(oReport, STR0011, {}, /*aOrdem*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , /*<lLineBreak>*/ , /*<nLeftMargin>*/ , .T./*<lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 0 /*<nLinesBefore>*/ , 1/*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ ) //"Nota Explicativa"
TRCell():New(oNotExplic, "CODNOT"		,, STR0012	,,  10, /*lPixel*/, {|| Code_NE() }/*CodeBlock*/,,,,,,,,, .T.)  //"Código NE"
TRCell():New(oNotExplic, "DATNOT"		,, STR0013	,,  10, /*lPixel*/, {|| Data_NE() }/*CodeBlock*/,,,,,,,,,)  //"Data NE"
TRCell():New(oNotExplic, "OBSNOT"		,, STR0014	,, 140, /*lPixel*/, {|| Observ_NE() }/*CodeBlock*/,"LEFT",.T.,"CENTER",,,,,,)  //"Observ.NE"

RestArea(aArea)
           
Return(oReport)

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint( oReport )
Local oSection1      := oReport:Section(1) 
Local oCabec         := oReport:Section(2)
Local oQuadro1       := oReport:Section(3)
Local oNotExplic     := oReport:Section(4)

Local cAno      	:= MV_PAR01 //Ano ?
Local nConsSld  	:= MV_PAR02 //Considera ? Mov.Periodo / Saldo Acumulado
Local cLivro    	:= MV_PAR03 //Cod. Config. Livros ?
Local cMoeda    	:= MV_PAR04 //Moeda ?	
Local cTpSaldo  	:= MV_PAR05 //Tipo de Saldo ?
Local lSldZ     	:= ( MV_PAR06==1 ) //Saldos Zerados ?
Local nDvPor    	:= MV_PAR07 //Divide Por ?	

Local dDataIni  
Local dDataFim 
Local lPlanilha 	:= .F.  //Imprime Excel
Local nDivide   	:= 1    //Divide por
Local aCtbMoeda 	:= {}

Local nCont			:= 0 

// seta o livro
Local aSetOfBook 	:= CTBSetOf( cLivro )

Local cArqTmp 		:= ""
Local cFilter 		:= ""

Local nDecimais		:= 0
Local cPicture		:= ""
Local aExercicio   	:= {}
Local aMoedas    	:= CtbMoeda(cMoeda) 

Local cAliasSld  	:= GetNextAlias()
Local cTbSldRP   	:= ""  //nome real da tabela q possui saldos Restos a Pagar

Local nRefSdAnt := 0
Local nRefSdAtu := 0
Local nRefExerc := 0
Local nAntSdAnt := 0
Local nAntSdAtu := 0
Local nAntExerc := 0

Local lMovPeriodo   := ( nConsSld == 1 )
Local cExercAnt     := Alltrim(Str(Val(MV_PAR01)-1))

If oReport:GetOrientation() == 1 //PORTRAIT
	_nSpaces := 45
Else
	_nSpaces := 70
EndIf

aExercicio   := { 	{ CtoD("01/01/"+cAno)		, CtoD("31/12/"+cAno) 		}, ;
					{ CtoD("01/01/"+cExercAnt)	, CtoD("31/12/"+cExercAnt) 	} }

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

//Data inicio e data fim do exercicio corrente
dDataIni := aExercicio[ 1, 1]
dDataFim := aExercicio[ 1, 2]

//variaveis static utilizadas na busca da nota explicativa
_cCodVisao := aSetOfBook[5]
_dRefIni   := dDataIni
_dRefFim   := dDataFim

//Data inicio e data fim exercicio anterior 
dDtIniAnt := aExercicio[ 2, 1]
dDtFimAnt := aExercicio[ 2, 2]

//-----------------------------------------------------------------------------------------------------------
//EXERCICIO REFERENCIA 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd, @cArqTmp, dDataIni, dDataFim;
					  , "", "", "", Repl( "Z", Len( CT1->CT1_CONTA )), ""; 
					  , Repl( "Z", Len(CTT->CTT_CUSTO)), "", Repl("Z", Len(CTD->CTD_ITEM));
					  , "", Repl("Z", Len(CTH->CTH_CLVL)), cMoeda, cTpSaldo, aSetOfBook, Space(2);
					  , Space(20), Repl("Z", 20), Space(30),,,,, .F./*lPosAntLP*/, CTOD("  /  /  ")/*dDataLP*/;
					  ,nDivide,/*lSldZ*/,,,,,,,,,,,,,,,,,,,,,,,,,cMoeda,lMovPeriodo,aSelFil,,.T.,.F./*lConsSaldo*/,,,,,,,,,,,)};
			,STR0021, STR0022) //"Criando Arquivo Tempor rio..."##"Processando Valores do Exercicio"

dbSelectArea("cArqTmp")           

//criar arquivo temporario para busca dos restos a pagar e valor receita corrente liquida / transferencias legais da Uniao
cTbSldRP     := CriaTmp_Sld( cAliasSld, ("cArqTmp") ->( DBStruct() ) )

dbSelectArea(cAliasSld)
dbSetOrder(1)           
dbGoTop()

dbSelectArea("cArqTmp")           
dbGoTop()

While ("cArqTmp")->( ! Eof() )

    //copia do registro da ctgerplan para arq temporario table
	(cAliasSld)->( RecLock(cAliasSld, .T.) )
	For nCont := 1 to (cAliasSld)->( Fcount() )
		If ! ( (cAliasSld)->( FieldName(nCont) ) $ "EXREFSDATU|EXREFSDANT|EXERCREF|EXANTSDINI|EXANTSDATU|EXERCANT" )
			(cAliasSld)->( FieldPut( nCont, ("cArqTmp")->( FieldGet(nCont) ) ) )
		EndIf
	Next
	(cAliasSld)->EXERCREF := If(lMovPeriodo, ("cArqTmp")->MOVIMENTO, ("cArqTmp")->SALDOATU )
	(cAliasSld)->EXREFSDATU := ("cArqTmp")->SALDOATU 
	(cAliasSld)->EXREFSDANT := ("cArqTmp")->SALDOANT
	(cAliasSld)->( MsUnlock() ) 

	("cArqTmp")->( dbSkip() )

EndDo
//fecha alias da ctgerplan
("cArqTmp")->( dbCloseArea() )

//-----------------------------------------------------------------------------------------------------------
//EXERCICIO ANTERIOR ( REFERENCIA - 1 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd, @cArqTmp, dDtIniAnt, dDtFimAnt;
					, "", "", "", Repl( "Z", Len( CT1->CT1_CONTA )), ""; 
					, Repl( "Z", Len(CTT->CTT_CUSTO)), "", Repl("Z", Len(CTD->CTD_ITEM));
					, "", Repl("Z", Len(CTH->CTH_CLVL)), cMoeda, cTpSaldo, aSetOfBook, Space(2);
					, Space(20), Repl("Z", 20), Space(30),,,,, .F./*lPosAntLP*/, CTOD("  /  /  ")/*dDataLP*/;
					,nDivide,/*lSldZ*/,,,,,,,,,,,,,,,,,,,,,,,,,cMoeda,.T./*lMovPeriodo*/,aSelFil,,.T.,.F./*lConsSaldo*/,,,,,,,,,,,)};
			,STR0021, STR0023) //"Criando Arquivo Tempor rio..."##"Processando Valores Exercicio Anterior"

dbSelectArea("cArqTmp") 

If Select("cArqTmp") == 0
	Return
EndIf

While ("cArqTmp")->( ! Eof() )
	If (cAliasSld)->( dbSeek( ("cArqTmp")->CONTA ) )
		//copia do registro da ctgerplan para arq temporario table
		(cAliasSld)->( RecLock(cAliasSld, .F.) )
		(cAliasSld)->EXERCANT := If(lMovPeriodo, ("cArqTmp")->MOVIMENTO, ("cArqTmp")->SALDOATU )
		(cAliasSld)->EXANTSDATU := ("cArqTmp")->SALDOATU
		(cAliasSld)->EXANTSDINI := ("cArqTmp")->SALDOANT
		(cAliasSld)->( MsUnlock() ) 
	EndIf
	("cArqTmp")->( dbSkip() )

EndDo
//fecha alias da ctgerplan
("cArqTmp")->( dbCloseArea() )

//-----------------------------------------------------------------------------------------------------------
//mudar o alias da tabela temporaria de saldo para "cArqTmp" 
dbChangeAlias(cAliasSld,"cArqTmp")

dbSelectArea("cArqTmp")
dbGoTop()        
cArqTmp := Alias()

//FILTRAR ZERADAS NAO PODE SER POR PARAMETRO DA CTGERPLAN POIS TOTALIZADORA - POR ISSO ESTE FILTRO
cDifZero := ' ( ("cArqTmp")->EXERCREF  <> 0 .OR. ("cArqTmp")->EXERCANT  <> 0  )'
cDifZero += ' .OR. ( AllTrim( ("cArqTmp")->CONTA ) $ "1.1|1.4" )'     //SALDO ANTERIOR/SALDO ATUAL SEMPRE IMPRIME 

If !lSldZ
	If Empty(cFilter)
		cFilter := cDifZero
	Endif
EndIf

oSection1:SetFilter( cFilter )                                                

oSection1:Cell("EXERCREF"):SetBlock ( { || ValorCTB((cArqTmp)->EXERCREF ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("EXERCAnt"):SetBlock ( { || ValorCTB((cArqTmp)->EXERCANT ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )

dbSelectArea("cArqTmp")
oQuadro1:Init()
oQuadro1:PrintLine()
oQuadro1:Finish()
oReport:ThinLine()

oSection1:Init()

nRefSdAnt := 0
nRefSdAtu := 0
nRefExerc := 0

nAntSdAnt := 0
nAntSdAtu := 0
nAntExerc := 0

//antes de imprimir recupera saldos anteriores / atual e grava nos campos EXERCREF / EXERCANT
While (cArqTmp)->( ! Eof() )

	If (cArqTmp)->TIPOCONTA == "2"  //Se for analitica soma total

		//Exercicio referencia (pergunte)
		nRefExerc += (cArqTmp)->EXERCREF
		nRefSdAnt += (cArqTmp)->EXREFSDANT
		nRefSdAtu += (cArqTmp)->EXREFSDATU

		//Exercicio Anterior
		nAntExerc += (cArqTmp)->EXERCANT
		nAntSdAnt += (cArqTmp)->EXANTSDINI
		nAntSdAtu += (cArqTmp)->EXANTSDATU

	EndIf

	//avanca registro
	(cArqTmp)->( dbSkip() )

Enddo

//LACO PARA IMPRESSAO DO RELATORIO
dbSelectArea("cArqTmp")
dbGoTop()

While (cArqTmp)->( ! Eof() )

	If AllTrim( (cArqTmp)->CONTA ) == "1"  //Primeira conta nao apresenta valores
		(cArqTmp)->( dbSkip() )
		Loop

	ElseIf AllTrim( (cArqTmp)->CONTA ) == "1.1"  //Se for SINTETICA - Saldo Inicial do Exercicio
		(cArqTmp)->( RecLock(cArqTmp, .F.) )
		(cArqTmp)->EXERCREF := nRefSdAnt
		(cArqTmp)->EXERCAnt := nAntSdAnt
		(cArqTmp)->( MsUnlock() )

	ElseIf AllTrim( (cArqTmp)->CONTA ) == "1.4"  //Se for SINTETICA - Saldo Final do Exercicio
		(cArqTmp)->( RecLock(cArqTmp, .F.) )
		(cArqTmp)->EXERCREF := nRefSdAtu
		(cArqTmp)->EXERCAnt := nAntSdAtu
		(cArqTmp)->( MsUnlock() ) 

	EndIf

	oSection1:PrintLine()       //impressao linha detalhe

	//avanca registro
	(cArqTmp)->( dbSkip() )

Enddo
oSection1:Finish()

//impressao nota explicativa
If Len(_aNotaExplic) > 0
	oReport:EndPage()
	oQuadro1:Init()
	oQuadro1:PrintLine()
	oQuadro1:Finish()
	oReport:ThinLine()
	oReport:PrintText("** NOTAS EXPLICATIVAS **")
	oReport:ThinLine()

	oNotExplic:Init()
	For nCont := 1 TO Len(_aNotaExplic)
		QLQ->( dbGoto( _aNotaExplic[nCont] ) )
		oNotExplic:PrintLine()
	Next
	oNotExplic:Finish()
EndIf

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

//Atribui valores default para variaveis static
_aNotaExplic   := {}
_nSpaces := 0
_cCodVisao := ""
_dRefIni   := ""
_dRefFim   := ""

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} DescCtGer
Cabecalho do relatorio - imprimir em todas as paginas

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function DescCtGer()
Local cDescConta := ""

cDescConta += Rtrim(("cArqTmp")->DESCCTA)

Return( cDescConta )

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
Static Function CodeNota()
Local cContaGer := ""
Local cCodeNota := ""
Local nRegQLQ := 0
Local aArea     := GetArea()
Local aAreaQLQ  := QLQ->( GetArea() )

//tem que estar posicionado na tabela de saida da visao gerencial
cContaGer := ("cArqTmp")->CONTA

//busca pela codigo da conta gerencial + data
//indice 1 -> QLQ_FILIAL+QLQ_CODPLA+QLQ_CODIGO+QLQ_CONTAG
//indice 2 -> QLQ_FILIAL+QLQ_CODPLA+QLQ_CONTAG+DTOS(QLQ_DATA)
QLQ->( dbSetOrder(2) )

//primeiro busca na data
If QLQ->( dbSeek( xFilial("QLQ")+_cCodVisao+cContaGer+DtoS(_dRefFim) ) )
	cCodeNota := QLQ->QLQ_CODIGO
	aAdd( _aNotaExplic, QLQ->( Recno() ) )

ElseIf QLQ->( dbSeek( xFilial("QLQ")+_cCodVisao+cContaGer) )
	
	//laco para percorrer todas as notas explicativas para visao / conta gerencial
	While QLQ->( ! Eof() .And. QLQ_FILIAL+QLQ_CODPLA+QLQ_CONTAG == xFilial("QLQ")+_cCodVisao+cContaGer )

		If QLQ->QLQ_DATA >= _dRefIni .And. QLQ->QLQ_DATA <= _dRefFim
			cCodeNota := QLQ->QLQ_CODIGO
			nRegQLQ   := QLQ->( Recno() )
		EndIf

		QLQ->( dbSkip() )

	EndDo

	If ! Empty( cCodeNota )  //carrega o Recno no array
		aAdd( _aNotaExplic,  nRegQLQ )
	EndIf

EndIf

RestArea( aAreaQLQ )
RestArea( aArea )

Return( cCodeNota )

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCabec
Cabecalho do relatorio - imprimir em todas as paginas

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function ImpCabec( oReport, oCabec, aMoedas, nDivPor, dDataFim )
Local cUnidMoed := ""

If     nDivPor == 2
    cUnidMoed := STR0016 //"Centena de "
ElseIf nDivPor == 3
    cUnidMoed := STR0017 //"Milhares de "
ElseIf nDivPor == 4
    cUnidMoed := STR0018 //"Milhoes de "
EndIf

//Imprime cabecalho
oCabec:Init()
oCabec:Cell("EXERCICIO"):SetBlock({|| STR0019+ SubStr(DToS(dDataFim), 1, 4) + "            ("+STR0020+AllTrim(cUnidMoed)+": " + AllTrim(aMoedas[3]) +  ") "})  //"Valores expressos em " //"Exercício: "
oCabec:PrintLine()
oCabec:Finish()

oReport:ThinLine()

Return

//---------------------------------------------------
/*/{Protheus.doc} CriaTmp_Sld
Cria a tabela temporária para montagem da estrutura 
que será retornada para a função chamadora

@author TOTVS

@param cArqtmp      Alias aberto para montar a temprary table
@param aCampos      Estrutura de Campos 

@version P12
@since   26/10/2020
@return  cArqTmp
/*/
//---------------------------------------------------
Static Function CriaTmp_Sld(cArqtmp,aCampos)
Local cTbNameRea  := ""
Local aChave	:= {"CONTA"}

DEFAULT cArqtmp := ""
DEFAULT aCampos := {}
// Valor Exercicio Referencia
aAdd( aCampos, { "EXREFSDATU"	, "N", 16, 2  } )
aAdd( aCampos, { "EXREFSDANT"	, "N", 16, 2  } )
aAdd( aCampos, { "EXERCREF"		, "N", 16, 2  } )

//Valor Exercicio Anterior
aAdd( aCampos, { "EXANTSDINI"	, "N", 16, 2  } )
aAdd( aCampos, { "EXANTSDATU"	, "N", 16, 2  } )
aAdd( aCampos, { "EXERCANT"		, "N", 16, 2  } )

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
