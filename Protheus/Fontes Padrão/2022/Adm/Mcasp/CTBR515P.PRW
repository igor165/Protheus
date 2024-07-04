#INCLUDE "CTBR515P.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE 	TAM_VALOR 			30

STATIC _oTmpTable


/*/{Protheus.doc} CTBR515P
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
Function CTBR515P()

Local cPerg	   	:= "CTBR515P" 
Local lRet      := .T.

Private aSelFil	 	:= {}

/*PERGUNTE
MV_PAR01 - Ano-Exercício ?
MV_PAR02 - Periodo-Quadrimestre ?
MV_PAR03 - Cod. Config. Livros ?
MV_PAR04 - Moeda ?	
MV_PAR05 - Tipo de Saldo ?
MV_PAR06 - Saldos Zerados ?
MV_PAR07 - Divide Por ?	
MV_PAR08 - Seleciona Filiais ?           
*/

SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.023"
    Help(,, "Help",, OemToAnsi(STR0003), 1, 0) //"Relatorio Demonstrativo das Operações de Crédito - Estados, DF e Municípios disponível a partir da versao 12.1.23"
    lRet := .F.
ElseIf !SX1->(dbSeek(Padr(cPerg, Len(SX1->X1_GRUPO), " ")))
    Help(,, "Help",, OemToAnsi(STR0004), 1, 0) //"Para utilizaçao do relatorio Demonstrativo das Operações de Crédito - Estados, DF e Municípios é necessário aplicar o pacote acumulado da controladoria."
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
@since 20/10/2020
@version 12.1.30
@return oReport - Objeto da classe TReport
/*/
//---------------------------------------------------------------------------------------
Static Function ReportDef()  
local aArea	   		:= GetArea()   
Local cReport		:= "CTBR515P"
Local cTitulo		:= STR0001 //"Demonstrativo das Operações de Crédito - Estados, DF e Municípios"
Local cDESC			:= STR0002 //"Este programa ira imprimir o Demonstrativo das Operações de Crédito - Estados, DF e Municípios, de acordo com os parâmetros informados pelo usuário."
Local aSetOfBook	:= {}
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""

Local cPerg	   	:= "CTBR515P" 

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

oSection1  := TRSection():New( oReport, STR0010, {"cArqTmp"},, .F., .F. ) //"Operacao Credito"

TRCell():New( oSection1, "CONTA"    , , STR0005					     				/*Titulo*/,/*Picture*/,       100,/*lPixel*/,{||DescCtGer()}/*CodeBlock*/,"LEFT",.T.,"CENTER")  //"Operações de Crédito "
TRCell():New( oSection1, "QUADREF"  , , STR0006+CRLF+STR0007+CRLF+STR0008    		/*Titulo*/,/*Picture*/, TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"  VALOR REALIZADO"##"No Quadrimestre de"##" Referência "
TRCell():New( oSection1, "QUADACU"  , , STR0006+CRLF+STR0009+CRLF+STR0008     		/*Titulo*/,/*Picture*/, TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"  VALOR REALIZADO"##"Até o Quadrimestre de"##" Referência " 
TRCell():New( oSection1, "COL_FAKE" , , " ___ "										/*Titulo*/,/*Picture*/,         3,/*lPixel*/,{||"  "}/*CodeBlock*/,"RIGHT",,"RIGHT")

oSection1:SetTotalInLine(.F.)        

oBorder := TRBorder():New(oReport, 5,, 0)
//Criacao da Secao Cabecalho
oCabec := TRSection():New(oReport, STR0011, {}, /*aOrdem*/)  //"Exercício"
TRCell():New(oCabec, "EXERCICIO",, "",, 120, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder   //Remove a borda do cabecalho
oCabec:SetLinesBefore(0)

//Criacao da Secao Quadro I
//Grupo: Tabela 4.0 - Demonstrativo das Operações de Crédito - Estados, DF e Municípios
//Quadro: Operações de Crédito 
//Período: 3º quadrimestre
oQuadro1 := TRSection():New(oReport, STR0012, {}, /*aOrdem*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , /*<lLineBreak>*/ , /*<nLeftMargin>*/ , .T./*<lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 0 /*<nLinesBefore>*/ , 1/*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ ) //"Quadro I"
TRCell():New(oQuadro1, "GRUPO_I"	,, STR0013	,, 80, /*lPixel*/, {||STR0014 }							/*CodeBlock*/,,,,,,,,, .T.)  //"Grupo"##"Tabela 4.0 - Demonstrativo das Operações de Crédito - Estados, DF e Municípios"
TRCell():New(oQuadro1, "QUADRO_I"	,, STR0015	,, 80, /*lPixel*/, {||STR0016}							/*CodeBlock*/,,,,,,,,, .T.)  //"Quadro"##"Operações de Crédito"  
TRCell():New(oQuadro1, "PERIODO"	,, STR0017	,, 80, /*lPixel*/, {||Alltrim(Str(MV_PAR02))+STR0018}	/*CodeBlock*/,,,,,,,,, .T.)  //""Período"" ##"o. Quadrimestre"

oQuadro2 := TRSection():New(oReport, STR0019, {}, /*aOrdem*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , /*<lLineBreak>*/ , /*<nLeftMargin>*/ , .T./*<lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 0 /*<nLinesBefore>*/ , 1/*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ ) //"Quadro II"
TRCell():New(oQuadro2, "TITREL"		,, ""	,, 140, /*lPixel*/, {||Space(110)+STR0020}/*CodeBlock*/,,,,,,,,, .T.)  //"Valor Realizado no Período "

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

Local cAno      := MV_PAR01 //Ano ?
Local nQuadRef  := MV_PAR02 //Quadrimestre Referencia
Local cLivro    := MV_PAR03 //Cod. Config. Livros ?
Local cMoeda    := MV_PAR04 //Moeda ?	
Local cTpSaldo  := MV_PAR05 //Tipo de Saldo ?
Local lSldZ     := ( MV_PAR06==1 ) //Saldos Zerados ?
Local nDvPor    := MV_PAR07 //Divide Por ?	

Local dDataIni  
Local dDataFim 
Local lPlanilha := .F.  //Imprime Excel
Local nDivide   := 1    //Divide por
Local aCtbMoeda := {}


Local nCont	:= 0 

// seta o livro
Local aSetOfBook := CTBSetOf( cLivro )

Local cArqTmp := ""
Local cFilter := ""

Local nDecimais	:= 0
Local cPicture	:= ""
Local aQuadrDt   := { 	{ CtoD("01/01/"+cAno), CtoD("30/04/"+cAno) }, ;
						{ CtoD("01/05/"+cAno), CtoD("31/08/"+cAno) }, ;
						{ CtoD("01/09/"+cAno), CtoD("31/12/"+cAno) } }
Local aMoedas    := CtbMoeda(cMoeda) 

Local cAliasSld  := GetNextAlias()
Local cTbSldRP   := ""  //nome real da tabela q possui saldos Restos a Pagar
Local nTotQuadRef := 0
Local nTotQuadAcu := 0

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

//Data inicio e data fim do Quadrimestre de Referencia
dDataIni := aQuadrDt[ nQuadRef, 1]
dDataFim := aQuadrDt[ nQuadRef, 2]

//Data inicio e data fim do Quadrimestre de Referencia
dDtIniAcu := aQuadrDt[ 1, 1]                    //"01/01/"+cAno
dDtFimAcu := aQuadrDt[ nQuadRef, 2]             //Data Fim Quadr.Referencia

//-----------------------------------------------------------------------------------------------------------
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd, @cArqTmp, dDataIni, dDataFim;
					  , "", "", "", Repl( "Z", Len( CT1->CT1_CONTA )), ""; 
					  , Repl( "Z", Len(CTT->CTT_CUSTO)), "", Repl("Z", Len(CTD->CTD_ITEM));
					  , "", Repl("Z", Len(CTH->CTH_CLVL)), cMoeda, cTpSaldo, aSetOfBook, Space(2);
					  , Space(20), Repl("Z", 20), Space(30),,,,, .F./*lPosAntLP*/, CTOD("  /  /  ")/*dDataLP*/;
					  ,nDivide,/*lSldZ*/,,,,,,,,,,,,,,,,,,,,,,,,,cMoeda,.T./*lMovPeriodo*/,aSelFil,,.T.,.F./*lConsSaldo*/,,,,,,,,,,,)};
			,STR0021, STR0022) //"Criando Arquivo Tempor rio..."##"Processando Valores Movimentos no Quadrimestre Referencia"

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
		If ! ( (cAliasSld)->( FieldName(nCont) ) $ "QUADREF|QUADACU" )
			(cAliasSld)->( FieldPut( nCont, ("cArqTmp")->( FieldGet(nCont) ) ) )
		EndIf
	Next
	(cAliasSld)->QUADREF := ("cArqTmp")->MOVIMENTO 
	(cAliasSld)->QUADACU := ("cArqTmp")->MOVIMENTO
	(cAliasSld)->( MsUnlock() ) 

	("cArqTmp")->( dbSkip() )

EndDo
//fecha alias da ctgerplan
("cArqTmp")->( dbCloseArea() )

//-----------------------------------------------------------------------------------------------------------

If dDataIni != dDtIniAcu  //pq se for igual eh o primeiro quadrimestre e nao eh necessario rodar gerplan novamente
	//-----------------------------------------------------------------------------------------------------------
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Arquivo Temporario para Impressao					     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerPlan(	oMeter, oText, oDlg, @lEnd, @cArqTmp, dDtIniAcu, dDtFimAcu;
						, "", "", "", Repl( "Z", Len( CT1->CT1_CONTA )), ""; 
						, Repl( "Z", Len(CTT->CTT_CUSTO)), "", Repl("Z", Len(CTD->CTD_ITEM));
						, "", Repl("Z", Len(CTH->CTH_CLVL)), cMoeda, cTpSaldo, aSetOfBook, Space(2);
						, Space(20), Repl("Z", 20), Space(30),,,,, .F./*lPosAntLP*/, CTOD("  /  /  ")/*dDataLP*/;
						,nDivide,/*lSldZ*/,,,,,,,,,,,,,,,,,,,,,,,,,cMoeda,.T./*lMovPeriodo*/,aSelFil,,.T.,.F./*lConsSaldo*/,,,,,,,,,,,)};
				,STR0022, STR0023) //"Criando Arquivo Tempor rio..."##"Processando Valores Acmulados ate o Quadrimestre Referencia"

	dbSelectArea("cArqTmp") 

	If Select("cArqTmp") == 0
		Return
	EndIf

	While ("cArqTmp")->( ! Eof() )
		If (cAliasSld)->( dbSeek( ("cArqTmp")->CONTA ) )
			//copia do registro da ctgerplan para arq temporario table
			(cAliasSld)->( RecLock(cAliasSld, .F.) )
			(cAliasSld)->QUADACU := ("cArqTmp")->MOVIMENTO
			(cAliasSld)->( MsUnlock() ) 
		EndIf
		("cArqTmp")->( dbSkip() )

	EndDo
	//fecha alias da ctgerplan
	("cArqTmp")->( dbCloseArea() )
EndIf

//-----------------------------------------------------------------------------------------------------------

//mudar o alias da tabela temporaria de saldo para "cArqTmp" 
dbChangeAlias(cAliasSld,"cArqTmp")

dbSelectArea("cArqTmp")
dbGoTop()        
cArqTmp := Alias()

//FILTRAR ZERADAS NAO PODE SER POR PARAMETRO DA CTGERPLAN POIS TOTALIZADORA - POR ISSO ESTE FILTRO
cDifZero := ' ( ("cArqTmp")->QUADREF  <> 0 .OR. ("cArqTmp")->QUADACU  <> 0  )'
cDifZero += ' .OR. ( AllTrim( ("cArqTmp")->CONTA ) == "1.3" )'     //TOTAL SEMPRE IMPRIME CONTA 1.3

If !lSldZ
	If Empty(cFilter)
		cFilter := cDifZero
	Endif
EndIf

oSection1:SetFilter( cFilter )                                                

oSection1:Cell("QUADREF"):SetBlock ( { || ValorCTB((cArqTmp)->QUADREF ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )
oSection1:Cell("QUADACU"):SetBlock ( { || ValorCTB((cArqTmp)->QUADACU ,,,TAM_VALOR-4,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lSldZ,.F.,,,lPlanilha) } )

dbSelectArea("cArqTmp")
oQuadro1:Init()
oQuadro1:PrintLine()
oQuadro1:Finish()
oReport:ThinLine()

oQuadro2:Init()
oQuadro2:PrintLine()
oQuadro2:Finish()
oReport:ThinLine()

oSection1:Init()

nTotQuadRef := 0
nTotQuadAcu := 0

While (cArqTmp)->( ! Eof() )

	If AllTrim( (cArqTmp)->CONTA ) == "1"  //Primeira conta nao apresenta valores
		oSection1:Cell("QUADREF"):Hide()
		oSection1:Cell("QUADACU"):Hide()
	
	ElseIf AllTrim( (cArqTmp)->CONTA ) == "1.3"  //Se for SINTETICA total
		(cArqTmp)->( RecLock(cArqTmp, .F.) )
		(cArqTmp)->QUADREF := nTotQuadRef
		(cArqTmp)->QUADACU := nTotQuadAcu
		(cArqTmp)->( MsUnlock() ) 
	Else
		If (cArqTmp)->TIPOCONTA == "2"  //Se for analitica soma total
			nTotQuadRef += (cArqTmp)->QUADREF
			nTotQuadAcu += (cArqTmp)->QUADACU
		EndIf
	EndIf

	oSection1:PrintLine()       //impressao linha detalhe

	If AllTrim( (cArqTmp)->CONTA ) == "1"  //Primeira conta nao apresenta valores
		oSection1:Cell("QUADREF"):Show()
		oSection1:Cell("QUADACU"):Show()
	EndIf

	//avanca registro
	(cArqTmp)->( dbSkip() )

	If Alltrim((cArqTmp)->CONTA) $ "1.1|1.2|1.3"
		oReport:SkipLine()
	EndIf 

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
If Empty( Alltrim(("cArqTmp")->DESCCONT) )
	cDescConta += Alltrim(("cArqTmp")->CONTA)+"-"+Rtrim(("cArqTmp")->DESCCTA)
Else
	cDescConta += Alltrim(("cArqTmp")->CONTA)+"-"+Rtrim(("cArqTmp")->DESCCONT)
EndIf
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
oCabec:Cell("EXERCICIO"):SetBlock({|| STR0027+ SubStr(DToS(dDataFim), 1, 4) + "            ("+STR0028+AllTrim(cUnidMoed)+": " + AllTrim(aMoedas[3]) +  ")          "+STR0029})  //"Valores expressos em " //"Exercício: "##"Periodicidade: QUADRIMESTRAL "
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
@since   31/03/2020
@return  cArqTmp
/*/
//---------------------------------------------------
Static Function CriaTmp_Sld(cArqtmp,aCampos)
Local cTbNameRea  := ""
Local aChave	:= {"CONTA"}

DEFAULT cArqtmp := ""
DEFAULT aCampos := {}
// Valor Quadrimestre Referencia
aAdd( aCampos, { "QUADREF", "N", 16, 2  } )
//Valor Acumuladao ate Quadrimestre de Referencia
aAdd( aCampos, { "QUADACU", "N", 16, 2 } )

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

