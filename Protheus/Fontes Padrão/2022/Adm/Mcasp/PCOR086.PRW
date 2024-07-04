#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCOR086.CH"

#DEFINE 	TAM_VALOR 			30

STATIC _oTmpTable

/*/{Protheus.doc} PCOR086
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
Function PCOR086()

Local cPerg	   	:= "PCOR086" 
Local lRet      := .T.
Local bCodPPA   := {|| AK0->( dbSeek( xFilial("AK0")+MV_PAR01 ) ) }
Local bVerPPA   := {|| AK0->( dbSeek( xFilial("AK0")+MV_PAR01+MV_PAR02 ) ) }
Local bAnoI_PPA := {|| MV_PAR03 >= AK0->AK0_ANOINI .And. MV_PAR03 <= AK0->AK0_ANOFIM }
Local bAnoF_PPA := {|| MV_PAR04 >= AK0->AK0_ANOINI .And. MV_PAR04 <= AK0->AK0_ANOFIM }

/*PERGUNTE
MV_PAR01 - Codigo do PPA ?
MV_PAR02 - Versao do PPA ?
MV_PAR03 - Ano de  ?
MV_PAR04 - Anot Até ?	
*/

AKO->(dbSetOrder(1))
//MyAK5()
//myAK0_A21_A22()

SX1->(dbSetOrder(1))


If GetRpoRelease() < "12.1.023"
    Help(,, "Help",, OemToAnsi(STR0003), 1, 0) //"Relatorio Demonstrativo PPA - Receitas da Administração Direta e Indireta - Fontes de Financiamento disponível a partir da versao 12.1.23"
    lRet := .F.
ElseIf !SX1->(dbSeek(Padr(cPerg, Len(SX1->X1_GRUPO), " ")))
    Help(,, "Help",, OemToAnsi(STR0004), 1, 0) //"Para utilizaçao do relatorio Demonstrativo PPA - Receitas da Administração Direta e Indireta - Fontes de Financiamento é necessário aplicar o pacote acumulado da controladoria."
    lRet := .F.
Else 
    //Perguntas do Relatório
    lRet := Pergunte(cPerg, .T.) 
EndIf 

If lRet
	//valida se existe o codigo do ppa
	If 		Empty(MV_PAR01) .OR. Empty(MV_PAR02)
			lRet := .F.
			HELP(' ',1,"PPAEMPTY" ,,STR0005,1,0)//"O Código/Versão do PPA nao informado. Verifique!"
	ElseIf !Eval(bCodPPA)
			lRet := .F.
			HELP(' ',1,"PPANOEXIST" ,,STR0006,1,0)//"O Código/Versão do PPA nao existe. Verifique!"
	//valida se existe versao do ppa
	ElseIf !Eval(bVerPPA)
			lRet := .F.
			HELP(' ',1,"PPAVER" ,,STR0007,1,0) //"A Versão do PPA informada não Existe. Verifique!"
	//valida se ano inicial esta dentro do range do PPA
	ElseIf !Eval(bAnoI_PPA)
			lRet := .F.
			HELP(' ',1,"PPANOINI" ,,STR0008,1,0)//"O ano inicial deve estar no intervalo definido no PPA . Verifique"
	//valida se ano final esta dentro do range do PPA
	ElseIf !Eval(bAnoF_PPA) .And. MV_PAR04 >= MV_PAR03
			lRet := .F.
			HELP(' ',1,"PPANOFIM" ,,STR0009,1,0)//""O ano final deve estar no intervalo definido no PPA. Verifique"
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
Local cReport		:= "PCOR086"
Local cTitulo		:= STR0001 //"Demonstrativo PPA - Receitas da Administração Direta e Indireta - Fontes de Financiamento"
Local cDESC			:= STR0002 //"Este programa ira imprimir o Demonstrativo PPA - Receitas da Administração Direta e Indireta - Fontes de Financiamento, de acordo com os parâmetros informados pelo usuário."

Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""

Local cPerg	   	:= "PCOR086" 

Local oSection1
Local oCabec
Local oBorder
Local aAno      := {}
Local cAnoAux   := "9999"
Local nX 
Local cAnoDE    := MV_PAR03
Local cAnoATE   := MV_PAR04


Pergunte(cPerg,.F.) 

aCtbMoeda	:= CtbMoeda("01", )  //FIXADO QUE O RELATORIO SEMPRE MOSTRARA VALORES EM MOEDA 01

If Empty(aCtbMoeda[1])
	Help(" ",1,"NOMOEDA")
	Return .F.
EndIf	
        
cDescMoeda 	:= AllTrim(aCtbMoeda[3])

cAnoAux := MV_PAR03

While cAnoAux <= MV_PAR04

	//adiciona ano no array
	aAdd(aAno, cAnoAux)
	cAnoAux := Soma1(cAnoAux)

EndDo

oReport	:= TReport():New( cReport,cTitulo,cPerg,;
	{ |oReport| Pergunte(cPerg,.F.), Iif(ReportPrint(oReport,aAno), .T., oReport:CancelPrint())}, CDESC)

oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,ctitulo,,,,,oReport) } )                                        		

// Define o tamanho da fonte a ser impressa no relatorio
oReport:nFontBody   := 8 //Define o tamanho da fonte
oReport:nLineHeight	:= 40 //Define a altura da linha.

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

oSection1  := TRSection():New( oReport, STR0010, {"cArqTmp"},, .F., .F. ) //"Previsão de Receitas"

TRCell():New( oSection1, "CONTA"    , , STR0011					     				/*Titulo*/,/*Picture*/,       75,/*lPixel*/,{||DescCtGer()}/*CodeBlock*/,"LEFT",.T.,"CENTER")  //"Especificação"
For nX := 1 TO Len(aAno)
	cAnoAux := aAno[nX]
	TRCell():New( oSection1, "DIR"+cAnoAux  , , cAnoAux+CRLF+STR0012	  		/*Titulo*/,/*Picture*/, TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"DIRETA"
	TRCell():New( oSection1, "IND"+cAnoAux  , , cAnoAux+CRLF+STR0013     		/*Titulo*/,/*Picture*/, TAM_VALOR,/*lPixel*/,{||0.00}/*CodeBlock*/,"RIGHT",,"RIGHT")   //"INDIRETA" 
Next
oSection1:SetTotalInLine(.F.)        

oSection2  := TRSection():New( oReport, STR0014, {"cArqTmp"},, .F., .F. ) //"Total Geral"
TRCell():New( oSection2, "CONTA"    , , STR0011					     				/*Titulo*/,/*Picture*/,       75,/*lPixel*/,{||DescCtGer()}/*CodeBlock*/,"LEFT",.T.,"CENTER")  //"Especificação"
For nX := 1 TO Len(aAno)
	cAnoAux := aAno[nX]
	TRCell():New( oSection2, "ANO"+cAnoAux  , , cAnoAux				  		  		/*Titulo*/,/*Picture*/, TAM_VALOR*2,/*lPixel*/,{||0.00}/*CodeBlock*/,"CENTER",,"CENTER")   //2018/ANO
Next
oSection1:SetTotalInLine(.F.)        
oSection2:SetHeaderPage(.T.)

oBorder := TRBorder():New(oReport, 5,, 0)
//Criacao da Secao Cabecalho
oCabec := TRSection():New(oReport, STR0015, {}, /*aOrdem*/,.F.,.F.)  //"Exercício"
TRCell():New(oCabec, "EXERCICIO",, "",, 120, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder   //Remove a borda do cabecalho
oCabec:SetLinesBefore(0)

//Criacao da Secao Quadro II
oQuadro2 := TRSection():New(oReport, STR0016, {}, /*aOrdem*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , /*<lLineBreak>*/ , /*<nLeftMargin>*/ , .T./*<lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 0 /*<nLinesBefore>*/ , 1/*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ ) //"Título Compl.Relatório"
TRCell():New(oQuadro2, "TITREL1"		,, ""	,, 140, /*lPixel*/, {||STR0021+" - "+cAnoDE+"/"+cAnoATE+" - "+STR0022}/*CodeBlock*/,,,,,,,,, .T.)  //"Plano Plurianual"##"Receitas da Administração Direta e Indireta - Fontes de Financiamento"
TRCell():New(oQuadro2, "TITREL2"		,, ""	,, 180, /*lPixel*/, {||Space(125)+STR0010}/*CodeBlock*/,,,,,,,,, .T.)  //"Previsão de Receitas"

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

Static Function ReportPrint( oReport, aAno )
Local oSection1      := oReport:Section(1) 
Local oSection2      := oReport:Section(2) 
Local oCabec         := oReport:Section(3)
Local oQuadro2       := oReport:Section(4)
Local aCellRep       := {}

/*PERGUNTE
MV_PAR01 - Codigo do PPA ?
MV_PAR02 - Versao do PPA ?
MV_PAR03 - Ano de  ?
MV_PAR04 - Anot Até ?	
*/
Local cCodPPA  := MV_PAR01 //MV_PAR01 - Codigo do PPA ?
Local cVerPPA  := MV_PAR02 //MV_PAR02 - Versao do PPA ?
Local cAnoDE   := MV_PAR03 //MV_PAR03 - Ano de  ?
Local cAnoATE  := MV_PAR04 //MV_PAR04 - Anot Até ?

Local nDvPor    := 1 //Divide Por ?	1=Não se aplica
Local cMoeda    := '01' //Moeda eh fixa 
Local lPlanilha := .F.  //Imprime Excel
Local nDivide   := 1    //Divide por
Local aCtbMoeda := {}
Local b_Value   := {||0}

Local nX	:= 0 

Local cArqTmp := ""

Local cPicture	:= "@E 999,999,999,999"

Local aMoedas    := CtbMoeda(cMoeda) 

Local cAliasVlr  := GetNextAlias()
Local cTbValor   := ""  //nome real da tabela q possui valores

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

aCtbMoeda  	:= CtbMoeda(cMoeda,nDivide)
cDescMoeda 	:= Alltrim(aCtbMoeda[2])	
nDecimais := 2

oReport:OnPageBreak( {|| ImpCabec( oReport, oCabec, aMoedas, nDvPor /*divide por*/, cAnoDE, cAnoATE) } )

//-----------------------------------------------------------------------------------------------------------
//criar arquivo temporario para popular com os valores diretos / indiretos por PPA
cTbValor     := CriaTmp_Vlr( cAliasVlr, aAno )

//Atribui os blocos de codigos para as celulas dos anos - direta / indireta
aCellRep := {}
For nX := 1 TO Len(aAno)
    //armazena nome da celula do relatorio (posicao 1) e a posicao do campo na tabela de saida (posicao 2)
	aAdd(aCellRep, { "DIR"+aAno[nX], (cAliasVlr)->(FieldPos("DIR"+aAno[nX])) })
	aAdd(aCellRep, { "IND"+aAno[nX], (cAliasVlr)->(FieldPos("IND"+aAno[nX])) })
Next

Ler_Dado(cCodPPA, cVerPPA, aAno, cAliasVlr, cTbValor, aCellRep)

//atribue SetBlock / SetPicture nas celulas de valor
For nX := 1 TO Len(aCellRep)
	b_Value := MontaBlock('{ || ("cArqTmp")->(FieldGet( '+ Alltrim(Str(aCellRep[nX,2])) +' )) } ')
	oSection1:Cell(aCellRep[nX,1]):SetBlock ( b_Value )
	oSection1:Cell(aCellRep[nX,1]):SetPicture( cPicture ) 
Next

dbSelectArea(cAliasVlr)
dbSetOrder(1)           
dbGoTop()

If Select("cArqTmp") > 0
	("cArqTmp")->( dbCloseArea() )
EndIf

//-----------------------------------------------------------------------------------------------------------
//mudar o alias da tabela temporaria de saldo para "cArqTmp" 
dbChangeAlias(cAliasVlr,"cArqTmp")

dbSelectArea("cArqTmp")
dbGoTop()        
cArqTmp := Alias()

dbSelectArea("cArqTmp")

oQuadro2:Init()
oQuadro2:PrintLine()
oQuadro2:Finish()
oReport:ThinLine()

oSection1:Init()

While (cArqTmp)->( ! Eof() )

	If (cArqTmp)->CONTA == Repl("z",Len((cArqTmp)->CONTA))  //totalizadores
		oReport:ThinLine()
	EndIf

	oSection1:PrintLine()       //impressao linha detalhe

	If (cArqTmp)->CONTA == Repl("z",Len((cArqTmp)->CONTA))  //totalizadores
		oReport:ThinLine()
		oReport:SkipLine()
		nUltReg := (cArqTmp)->( Recno() )
	End

	//avanca registro
	(cArqTmp)->( dbSkip() )

Enddo
oSection1:Finish()

//reposiciona no ultimo registro
(cArqTmp)->( dbGoto( nUltReg ) )  //total das receitas e soma direto + indireto por ano
//Atribue TOTAL GERAL na descricao da conta
(cArqTmp)->( RecLock(cArqTmp, .F.) )
(cArqTmp)->DESCCTA := STR0023 //"TOTAL GERAL"
(cArqTmp)->( MsUnlock() )

//atribue SetBlock / SetPicture nas celulas de valor - somando valor direto e valor indireto
For nX := 1 TO Len(aCellRep) STEP 2
	b_Value := MontaBlock('{ || ("cArqTmp")->( FieldGet( '+ Alltrim(Str(aCellRep[nX,2])) +' )+FieldGet( '+ Alltrim(Str(aCellRep[nX+1,2])) +' )) } ')
	oSection2:Cell(Right(aCellRep[nX,1],4)):SetBlock ( b_Value )
	oSection2:Cell(Right(aCellRep[nX,1],4)):SetPicture( cPicture ) 
Next
oSection2:Init()

While (cArqTmp)->( ! Eof() )

	oSection2:PrintLine()       //impressao linha detalhe

	If (cArqTmp)->CONTA == Repl("z",Len((cArqTmp)->CONTA))  //totalizadores
		oReport:ThinLine()
	Endif

	//avanca registro
	(cArqTmp)->( dbSkip() )

Enddo
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

If ("cArqTmp")->CONTA == Repl("z",Len(("cArqTmp")->CONTA))  //totalizadores
	cDescConta += Space(10)+PADR(("cArqTmp")->DESCCTA,30)+ " = "
Else
	cDescConta += Alltrim(("cArqTmp")->CONTA)+"-"+Rtrim(("cArqTmp")->DESCCTA)
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
Static Function ImpCabec( oReport, oCabec, aMoedas, nDivPor, cAnoIni, cAnoFim )
Local cUnidMoed := ""

If     nDivPor == 2
    cUnidMoed := STR0017 //"Centena de "
ElseIf nDivPor == 3
    cUnidMoed := STR0018 //"Milhares de "
ElseIf nDivPor == 4
    cUnidMoed := STR0019 //"Milhoes de "
EndIf

//Imprime cabecalho
oCabec:Init()
oCabec:Cell("EXERCICIO"):SetBlock({|| STR0015+"-" + cAnoIni +" - "+ cAnoFim + "            (" + STR0020 +AllTrim(cUnidMoed)+": " + AllTrim(aMoedas[3]) +  ")          " })  //"Valores expressos em " //"Exercício: "
oCabec:PrintLine()
oCabec:Finish()

oReport:ThinLine()

Return

//---------------------------------------------------
/*/{Protheus.doc} CriaTmp_Vlr
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
Static Function CriaTmp_Vlr(cArqtmp, aAno)
Local cTbNameRea  := ""
Local aChave	:= {"TIPREC","CONTA"}
Local aCampos := {}
Local nX

DEFAULT cArqtmp := ""
//TIPO DA RECEITA - CORRENTE OU CAPITAL
aAdd( aCampos, { "TIPREC", "C", 1, 0  } )
//CONTA
aAdd( aCampos, { "CONTA", "C", Len(AK5->AK5_CODIGO), 0  } )
//DESCRICAO DA CONTA
aAdd( aCampos, { "DESCCTA", "C", Len(AK5->AK5_DESCRI), 0  } )

For nX:=1 to Len(aAno)
	//Valor por ano direto/indireto
	aAdd( aCampos, { "DIR"+aAno[nX], "N", 16, 2 } )
	aAdd( aCampos, { "IND"+aAno[nX], "N", 16, 2 } )
Next

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

//---------------------------------------------------
/*/{Protheus.doc} Ler_Dado
Carrega os dados da tabela A22 conforme parametros passados

@author TOTVS

@param cCodPPA      Codigo do PPA
@param cVerPPA      Versao do PPA
@param aAno         ARRAY contendo os anos a ser impresso PPA
@param cAliasVlr    Alias aberto da tabela temporaria criado com fwtemporarytable
@param cTbValor     Nome real da tabela criada com fwtemporarytable

@version P12
@since   31/03/2020
@return  cArqTmp
/*/
//---------------------------------------------------
Static Function Ler_Dado(cCodPPA, cVerPPA, aAno, cAliasVlr, cTbValor, aCellRep)

Local cQuery := ""
Local nX
Local cCampo := ""
Local nValorAnt := 0

(cAliasVlr)->( dbSetOrder(1) )

For nX := 1 TO Len(aAno)

	cQuery := ""
	cQuery += " SELECT A22_TIPREC TIPREC, A22_CONTA CONTA, AK5_DESCRI DESCCTA "
	cQuery += " ,A22_VLRDIR DIR" + aAno[nX] + " "
	cQuery += " ,A22_VLRIND IND" + aAno[nX] + " "
	cQuery += " FROM "
	cQuery += RetSqlName("A22")+" A22, "
	cQuery += RetSqlName("AK5")+" AK5 "
	cQuery += " WHERE A22_FILIAL = '" + xFilial("A22") + "' "
	cQuery += "  AND A22_CODPPA  = '" + cCodPPA + "' "
	cQuery += "  AND A22_VERPPA  = '" + cVerPPA + "' "
	cQuery += "  AND A22_ANOREF  = '" + aAno[nX] + "' "
	cQuery += "  AND A22.D_E_L_E_T_ =  ' ' "
	cQuery += "  AND AK5_FILIAL =  '" + xFilial("AK5") + "' "
	cQuery += "  AND AK5_CODIGO = A22_CONTA "
	cQuery += "  AND AK5.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY A22_TIPREC, A22_CONTA "

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAUX_1", .T., .T. )

	While TMPAUX_1->(! Eof() )

		//grava na tabela de saida criada com fwtemporarytable
		If ! (cAliasVlr)->( dbSeek( TMPAUX_1->TIPREC + TMPAUX_1->CONTA ) )
		    //Inclui a conta
			(cAliasVlr)->( RecLock(cAliasVlr, .T.) )

			(cAliasVlr)->TIPREC  := TMPAUX_1->TIPREC
			(cAliasVlr)->CONTA   := TMPAUX_1->CONTA
			(cAliasVlr)->DESCCTA := TMPAUX_1->DESCCTA 
		
		Else 
			//altera a conta ja existente
			(cAliasVlr)->( RecLock(cAliasVlr, .F.) )
		
		EndIf

		//grava valor direto
		cCampo := "DIR" + aAno[nX]
		nPosCpo := aScan(aCellRep, {|x| x[1] == cCampo })
		nValorAnt := (cAliasVlr)->( FieldGet( aCellRep[nPosCpo,2] ) )

		(cAliasVlr)->( FieldPut( aCellRep[nPosCpo,2], nValorAnt + TMPAUX_1->( FieldGet(4)) ) )  //4o. campo da query
		
		//grava valor indireto
		cCampo := "IND" + aAno[nX]
		nPosCpo := aScan(aCellRep, {|x| x[1] == cCampo })
		nValorAnt := (cAliasVlr)->( FieldGet( aCellRep[nPosCpo,2] ) )

		(cAliasVlr)->( FieldPut( aCellRep[nPosCpo,2], nValorAnt + TMPAUX_1->( FieldGet(5)) ) )  //5o. campo da queyr
		(cAliasVlr)->( MsUnlock() )

		TMPAUX_1->( dbSkip() )

	EndDo

	TMPAUX_1->( dbCloseArea() )

Next

//totalizador de Receitas Correntes
cQuery := ""
cQuery += " SELECT TIPREC, '"+Repl('z',Len( (cAliasVlr)->CONTA ))+"' CONTA, '"+STR0024+"' DESCCTA "   //"Receitas Correntes"

For nX := 1 TO Len(aAno)
	cQuery += " , SUM(DIR" + aAno[nX] + ") DIR"+ aAno[nX]
	cQuery += " , SUM(IND" + aAno[nX] + ") IND"+ aAno[nX]
Next

cQuery += " FROM " + cTbValor
cQuery += " WHERE TIPREC = '1' "
cQuery += " GROUP BY TIPREC "
cQuery += " ORDER BY TIPREC "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAUX_1", .T., .T. )

While TMPAUX_1->(! Eof() )

	//Inclui a conta
	(cAliasVlr)->( RecLock(cAliasVlr, .T.) )
	For nX := 1 TO (cAliasVlr)->( Fcount() )
		(cAliasVlr)->( FieldPut( nX, TMPAUX_1->( FieldGet(nX) ) ) ) 
	Next
	(cAliasVlr)->( MsUnlock() )

	TMPAUX_1->( dbSkip() )

EndDo
TMPAUX_1->( dbCloseArea() )

//totalizador de Receitas de Capital
cQuery := ""
cQuery += " SELECT TIPREC, '"+Repl('z',Len( (cAliasVlr)->CONTA ))+"' CONTA, '"+STR0025+"' DESCCTA "  //"Receitas de Capital"

For nX := 1 TO Len(aAno)
	cQuery += " , SUM(DIR" + aAno[nX] + ") DIR"+ aAno[nX]
	cQuery += " , SUM(IND" + aAno[nX] + ") IND"+ aAno[nX]
Next

cQuery += " FROM " + cTbValor
cQuery += " WHERE TIPREC = '2' "
cQuery += " GROUP BY TIPREC "
cQuery += " ORDER BY TIPREC "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAUX_1", .T., .T. )

While TMPAUX_1->(! Eof() )

	//Inclui a conta
	(cAliasVlr)->( RecLock(cAliasVlr, .T.) )
	For nX := 1 TO (cAliasVlr)->( Fcount() )
		(cAliasVlr)->( FieldPut( nX, TMPAUX_1->( FieldGet(nX) ) ) ) 
	Next
	(cAliasVlr)->( MsUnlock() )

	TMPAUX_1->( dbSkip() )

EndDo
TMPAUX_1->( dbCloseArea() )

//totalizador de Receitas geral
cQuery := ""
cQuery += " SELECT '9' TIPREC, '"+Repl('z',Len( (cAliasVlr)->CONTA ))+"' CONTA, '"+STR0026+"' DESCCTA "  //"Total da Receita"

For nX := 1 TO Len(aAno)
	cQuery += " , SUM(DIR" + aAno[nX] + ") DIR"+ aAno[nX]
	cQuery += " , SUM(IND" + aAno[nX] + ") IND"+ aAno[nX]
Next

cQuery += " FROM " + cTbValor
cQuery += " WHERE CONTA  != '"+Repl('z',Len( (cAliasVlr)->CONTA ))+"' "
//cQuery += " GROUP BY TIPREC "
//cQuery += " ORDER BY TIPREC "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAUX_1", .T., .T. )

While TMPAUX_1->(! Eof() )

	//Inclui a conta
	(cAliasVlr)->( RecLock(cAliasVlr, .T.) )
	For nX := 1 TO (cAliasVlr)->( Fcount() )
		(cAliasVlr)->( FieldPut( nX, TMPAUX_1->( FieldGet(nX) ) ) ) 
	Next
	(cAliasVlr)->( MsUnlock() )

	TMPAUX_1->( dbSkip() )

EndDo
TMPAUX_1->( dbCloseArea() )

//total geral utiliza o Total de Receitas e soma direto + indireto

Return

//-------------------------------------------------------------------------
//POPULA BASE PARA RELATORIO MODELO

/* 
Static Function MyAK5()
Local aArrayAK5 := {}
Local nX

aAdd(aArrayAK5, { "1.1.0.0.00.0.0", "Impostos, Taxas e Contribuições de Melhoria"} )
aAdd(aArrayAK5, { "1.2.0.0.00.0.0", "Contribuições"} )
aAdd(aArrayAK5, { "1.3.0.0.00.0.0", "Receita Patrimonial"} )
aAdd(aArrayAK5, { "1.6.0.0.00.0.0", "Receita de Serviço"} )
aAdd(aArrayAK5, { "1.7.0.0.00.0.0", "Transferências Correntes"} )
aAdd(aArrayAK5, { "1.9.0.0.00.0.0", "Outras Receitas Correntes"} )
aAdd(aArrayAK5, { "7.2.0.0.00.0.0", "Receitas Correntes Intraorçamentárias"} )
aAdd(aArrayAK5, { "2.1.0.0.00.0.0", "Operações de Crédito"} )
aAdd(aArrayAK5, { "2.2.0.0.00.0.0", "Alienação de Bens"} )
aAdd(aArrayAK5, { "2.3.0.0.00.0.0", "Amortização de Empréstimos"} )
aAdd(aArrayAK5, { "2.4.0.0.00.0.0", "Transferências de Capital"} )


dbSelectArea('AK5')
dbSetOrder(1)

For nX := 1 TO Len(aArrayAK5)

    If !dbSeek(XFILIAL("AK5")+aArrayAK5[nX,1])

        AK5->(Reclock("AK5",.T.))
        AK5->AK5_FILIAL := XFILIAL("AK5")
        AK5->AK5_CODIGO := aArrayAK5[nX,1]
        AK5_DESCRI :=aArrayAK5[nX,2]
        AK5_TIPO   := "1"
        AK5_DEBCRE := "1"
        AK5_DTINC := CTOD("01/01/20")
        AK5_DTINI := CTOD("01/01/80")
        AK5_COSUP := Left(aArrayAK5[nX,1],1)
        AK5_MSBLQL := "2"
        AK5->(MsUnLock())

    EndIf

Next

Return

Static Function myAK0_A21_A22()
Local aValues := {}
Local nX

If AK0->( !dbSeek( xFilial("AK0")+"PPA201") )
	AK0->(Reclock("AK0",.T.))
	AK0->AK0_FILIAL := XFILIAL("AK0")
	AK0->AK0_CODIGO := "PPA201"
	AK0->AK0_VERSAO := "001"
	AK0->AK0_DESCRI := "PPA - 2018 "
	AK0->AK0_ANOINI := "2018"
	AK0->AK0_ANOFIM := "2021"
	AK0->AK0_STATUS := "2"
	AK0->(MsUnLock())
EndIf

A21->(Reclock("A21",.T.))
A21->A21_FILIAL := XFILIAL("A21")
A21->A21_CODPPA := "PPA201"
A21->A21_VERPPA := "001"
A21->A21_ANOREF := "2018"
A21->A21_STATUS := "1"
A21->(MsUnLock())

A21->(Reclock("A21",.T.))
A21->A21_FILIAL := XFILIAL("A21")
A21->A21_CODPPA := "PPA201"
A21->A21_VERPPA := "001"
A21->A21_ANOREF := "2019"
A21->A21_STATUS := "1"
A21->(MsUnLock())

A21->(Reclock("A21",.T.))
A21->A21_FILIAL := XFILIAL("A21")
A21->A21_CODPPA := "PPA201"
A21->A21_VERPPA := "001"
A21->A21_ANOREF := "2020"
A21->A21_STATUS := "1"
A21->(MsUnLock())

A21->(Reclock("A21",.T.))
A21->A21_FILIAL := XFILIAL("A21")
A21->A21_CODPPA := "PPA201"
A21->A21_VERPPA := "001"
A21->A21_ANOREF := "2021"
A21->A21_STATUS := "1"
A21->(MsUnLock())


aValues := {}

aAdd(aValues, { '1.1.0.0.00.0.0', '2018', 2312715000 , 1636000 } ) 
aAdd(aValues, { '1.2.0.0.00.0.0', '2018', 50000000 , 131676100 } ) 					
aAdd(aValues, { '1.3.0.0.00.0.0', '2018', 89600000 , 45022420 } ) 					
aAdd(aValues, { '1.6.0.0.00.0.0', '2018', 0 , 39367752 } ) 					
aAdd(aValues, { '1.7.0.0.00.0.0', '2018', 2752040000 , 1210000 } ) 					
aAdd(aValues, { '1.9.0.0.00.0.0', '2018', 164891873 , 90213448 } ) 					
aAdd(aValues, { '7.2.0.0.00.0.0', '2018', 0 , 255383000 } ) 					
aAdd(aValues, { '2.1.0.0.00.0.0', '2018', 460240627 , 0 } ) 					
aAdd(aValues, { '2.2.0.0.00.0.0', '2018', 10000 , 21280 } ) 					
aAdd(aValues, { '2.3.0.0.00.0.0', '2018', 1628000 , 5000 } ) 					
aAdd(aValues, { '2.4.0.0.00.0.0', '2018', 82719978 , 0 } ) 					

For nX := 1 TO Len(aValues)
	A22->(Reclock("A22",.T.))
	A22->A22_FILIAL := XFILIAL("A22")
	A22->A22_CODPPA := "PPA201"
	A22->A22_VERPPA := "001"
	A22->A22_ANOREF := aValues[nX, 2]
	A22->A22_ITEM := StrZero(nX, 4)
	A22->A22_CONTA := aValues[nX, 1]
	A22->A22_TIPREC := IF(LEFT(aValues[nX,1],1)$"1|7", "1", "2")
	A22->A22_VLRDIR := aValues[nX, 3]
	A22->A22_VLRIND := aValues[nX, 4]
	A22->(MsUnLock())
Next

aValues := {}
aAdd(aValues, { '1.1.0.0.00.0.0', '2019', 2451478000 , 1740705 } ) 					
aAdd(aValues, { '1.2.0.0.00.0.0', '2019', 53000000 , 141689420 } ) 					
aAdd(aValues, { '1.3.0.0.00.0.0', '2019', 94976000 , 51306077 } ) 					
aAdd(aValues, { '1.6.0.0.00.0.0', '2019', 0 , 41524908 } ) 					
aAdd(aValues, { '1.7.0.0.00.0.0', '2019', 2954655344 , 1210000 } ) 					
aAdd(aValues, { '1.9.0.0.00.0.0', '2019', 193929000 , 95570968 } ) 					
aAdd(aValues, { '7.2.0.0.00.0.0', '2019', 0 , 276634580 } ) 					
aAdd(aValues, { '2.1.0.0.00.0.0', '2019', 303260746 , 0 } ) 					
aAdd(aValues, { '2.2.0.0.00.0.0', '2019', 10000 , 33842 } ) 					
aAdd(aValues, { '2.3.0.0.00.0.0', '2019', 1500000 , 0 } ) 					
aAdd(aValues, { '2.4.0.0.00.0.0', '2019', 41566048 , 0 } ) 					

For nX := 1 TO Len(aValues)
	A22->(Reclock("A22",.T.))
	A22->A22_FILIAL := XFILIAL("A22")
	A22->A22_CODPPA := "PPA201"
	A22->A22_VERPPA := "001"
	A22->A22_ANOREF := aValues[nX, 2]
	A22->A22_ITEM := StrZero(nX, 4)
	A22->A22_CONTA := aValues[nX, 1]
	A22->A22_TIPREC := IF(LEFT(aValues[nX,1],1)$"1|7", "1", "2")
	A22->A22_VLRDIR := aValues[nX, 3]
	A22->A22_VLRIND := aValues[nX, 4]
	A22->(MsUnLock())
Next

aValues := {}
aAdd(aValues, { '1.1.0.0.00.0.0', '2020', 2598566680 , 1852109 } ) 					
aAdd(aValues, { '1.2.0.0.00.0.0', '2020', 56180000 , 151221400 } ) 					
aAdd(aValues, { '1.3.0.0.00.0.0', '2020', 100674560 , 59002219 } ) 					
aAdd(aValues, { '1.6.0.0.00.0.0', '2020', 0 , 46407109 } ) 					
aAdd(aValues, { '1.7.0.0.00.0.0', '2020', 3066436120 , 1210000 } ) 					
aAdd(aValues, { '1.9.0.0.00.0.0', '2020', 202250707 , 111272772 } ) 					
aAdd(aValues, { '7.2.0.0.00.0.0', '2020', 0 , 287149200 } ) 					
aAdd(aValues, { '2.1.0.0.00.0.0', '2020', 136216004 , 0 } ) 					
aAdd(aValues, { '2.2.0.0.00.0.0', '2020', 10000 , 35991 } ) 					
aAdd(aValues, { '2.3.0.0.00.0.0', '2020', 1500000 , 0 } ) 					
aAdd(aValues, { '2.4.0.0.00.0.0', '2020', 19991372 , 0 } ) 					

For nX := 1 TO Len(aValues)
	A22->(Reclock("A22",.T.))
	A22->A22_FILIAL := XFILIAL("A22")
	A22->A22_CODPPA := "PPA201"
	A22->A22_VERPPA := "001"
	A22->A22_ANOREF := aValues[nX, 2]
	A22->A22_ITEM := StrZero(nX, 4)
	A22->A22_CONTA := aValues[nX, 1]
	A22->A22_TIPREC := IF(LEFT(aValues[nX,1],1)$"1|7", "1", "2")
	A22->A22_VLRDIR := aValues[nX, 3]
	A22->A22_VLRIND := aValues[nX, 4]
	A22->(MsUnLock())
Next

aValues := {}
aAdd(aValues, { '1.1.0.0.00.0.0', '2021', 2754480680 , 1970644 } ) 					
aAdd(aValues, { '1.2.0.0.00.0.0', '2021', 59550800 , 161723000 } ) 					
aAdd(aValues, { '1.3.0.0.00.0.0', '2021', 106715033 , 65410595 } ) 					
aAdd(aValues, { '1.6.0.0.00.0.0', '2021', 0 , 51848769 } ) 					
aAdd(aValues, { '1.7.0.0.00.0.0', '2021', 3067332074 , 1210000 } ) 					
aAdd(aValues, { '1.9.0.0.00.0.0', '2021', 212599926 , 118008809 } ) 					
aAdd(aValues, { '7.2.0.0.00.0.0', '2021', 0 , 306305700 } ) 					
aAdd(aValues, { '2.1.0.0.00.0.0', '2021', 176515462 , 0 } ) 					
aAdd(aValues, { '2.2.0.0.00.0.0', '2021', 10000 , 38233 } ) 					
aAdd(aValues, { '2.3.0.0.00.0.0', '2021', 1500000 , 0 } ) 					
aAdd(aValues, { '2.4.0.0.00.0.0', '2021', 20587778 , 0 } ) 					
		

For nX := 1 TO Len(aValues)
	A22->(Reclock("A22",.T.))
	A22->A22_FILIAL := XFILIAL("A22")
	A22->A22_CODPPA := "PPA201"
	A22->A22_VERPPA := "001"
	A22->A22_ANOREF := aValues[nX, 2]
	A22->A22_ITEM := StrZero(nX, 4)
	A22->A22_CONTA := aValues[nX, 1]
	A22->A22_TIPREC := IF(LEFT(aValues[nX,1],1)$"1|7", "1", "2")
	A22->A22_VLRDIR := aValues[nX, 3]
	A22->A22_VLRIND := aValues[nX, 4]
	A22->(MsUnLock())
Next

Return
*/
