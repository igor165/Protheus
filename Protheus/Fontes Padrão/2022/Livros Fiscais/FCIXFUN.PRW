#INCLUDE "PROTHEUS.CH"
#INCLUDE "FCIXFUN.CH"
#INCLUDE "FILEIO.CH"
#DEFINE PULALINHA CHR(13)+CHR(10)
#define F_SD1  1
#define F_SD2  2
#define F_SD3  3
#define F_SA8  4
#define F_CFD  5
#define F_SF4  6
#define F_SB1  7
#define F_SWN  8

Static cArqFb := ""
Static cAliasFb := NewAlias()
Static lFabBefore := .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} xFciIniEnv

Inicializacao do ambiente da rotina

@param	aWizard		-> Array com conteudo dos campos preenchidos na wizard
					   da Rotina (Referencia)
		lMultFil	-> Indica se o processamento sera feito utilizando selecao
					   de filiais (Referencia)
		aLisFil		-> Array com as filiais que serao processadas (Referencia)
		cFilDe		-> Filial Inicial (Referencia)
		cFilAte		-> Filial Final (Referencia)
		aError		-> Verificacao de possiveis erros na inicializacao da rotina

@return	lRet	->	Continua processamento da rotina

@owner	SIGAFIS - Livros Fiscais

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function xFciIniEnv( aWizard , lMultFil , aLisFil , cFilDe , cFilAte , aError , lJob )
Local	lRet	:=	.F.
Local	nX		:=	0
Local	cMsgErro:=	""

Default lJob := .F.

If aScan( aError, {|x| x[1] } ) == 0

	If !lJob
		aWizard := xFciWizard()
	EndIf

	If Len( aWizard ) > 0

		lRet	:=	.T.

		//------------------------------------------------------
		// Abertua de tabelas utilizadas no processamento
		//------------------------------------------------------
		DbSelectArea("SD3")
		SD3->(DbSetOrder(1))	//D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
		DbSelectArea("SD1")
		SD1->(DbSetOrder(7))	//D1_FILIAL+D1_COD+D1_LOCAL+DTOS(D1_DTDIGIT)+D1_NUMSEQ
		DbSelectArea("CFD")
		CFD->(DbSetOrder(2))	//CFD_FILIAL+CFD_COD+CFD_PERCAL+CFD_PERVEN
		DbSelectArea("SF2")
		SF2->(DbSetOrder(1))	//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		DbSelectArea("SD2")
		SD2->(DbSetOrder(3))	//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))	//B1_FILIAL+B1_COD
		DbSelectArea("SA8")
		SA8->(DbSetOrder(1))	//A8_FILIAL+A8_COD+A8_PERIOD

		//------------------------------------------------------
		// Selecao de filiais
		//------------------------------------------------------
		lMultFil	:=	Substr( aWizard[1][5] , 1 , 1 ) $ "1"

		//------------------------------------------------------------------------------------------------------------
		//
		//
		//								Selecao de filiais que serao processadas na rotina
		//
		//
		//------------------------------------------------------------------------------------------------------------
		If lMultFil
			If Empty(aLisFil)
				aLisFil	:=	MatFilCalc(.T.)
			EndIf
			If !Empty(aLisFil)
				cFilDe	:=	PadR("",FWGETTAMFILIAL)
				cFilAte	:=	Repl("Z",FWGETTAMFILIAL)
			Else
				If lJob
					QOut( OemToAnsi( STR0001 ) ) //"Nenhuma filial foi selecionada para o processamento. Sera considerada a filial corrente"
				Else
					MsgAlert( OemToAnsi( STR0001 ) ) //"Nenhuma filial foi selecionada para o processamento. Sera considerada a filial corrente"
				EndIf
				//Para considerar a filial corrente, preciso alem de atribuir o cFilAnt, preciso forcar a
				//opcao .F. na variavel que indica opcao de Multi Filiais
				lMultFil	:=	.F.
				cFilDe		:=	cFilAnt
				cFilAte		:=	cFilAnt
			EndIf
		Else
			cFilDe	:=	cFilAnt
			cFilAte	:=	cFilAnt
		EndIf
	Endif

Else

	cMsgErro	:=	STR0002 + CRLF + CRLF	//"Para correta execução da rotina, verificar ocorrências abaixo:"

	// -----------------------------------------------------------
	// Listo todos os erros encontrados na pre-validacao da rotina
	// -----------------------------------------------------------
	For nX := 1 To Len( aError )
		If aError[nX][1]
			cMsgErro	+=	aError[nX][2] + CRLF
		Endif
	Next nX

	If lJob
		QOut( cMsgErro )
	Else
		MsgInfo( cMsgErro , STR0003 )	//"Aviso!"
	EndIf

Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CIxOrigem

Retorna o codigo da origem conforme Conteudo de Importacao informado
como parametro

@param	nCI		->	Percentual do Conteudo de Importacao

@return cOrigem	->	Codigo da Origem

@owner	SIGAFIS - Livros Fiscais

@author Luccas Curcio
@since 04/09/2013
@version 11.0

/*/
//-------------------------------------------------------------------
Function CIxOrigem( nCI )
Local cOrigem := ""

Do Case
	// 0 - Nacional, exceto as indicadas nos códigos 3, 4, 5 e 8
	Case nCI == 0
		cOrigem := "0"

	// 1 - Estr.(Importacao Direta)
	Case nCI == 100
		cOrigem := "1"

	// 3 - Nacional-Mer/bem Cont de Import sup 40% e inf/igual 70%
	Case nCI > 40 .And. nCI <= 70
		cOrigem := "3"

	// 5 - Nacional-Merc/bem com Cont de Import inf ou igual a 40%
	Case nCI > 0 .And. nCI <= 40
		cOrigem := "5"

	// 8 - Nacional-Merc/bem com Cont de Import superior a 70%
	Case nCI > 70
		cOrigem := "8"
End Case

Return cOrigem

//-------------------------------------------------------------------
/*/{Protheus.doc} XFciX6ToQry

Valida conteudo dos parametros da rotina

@param	cContent->	Conteudo do parametro

@return cRet	->	Conteudo que sera utilizado nos processamentos

@owner	SIGAFIS - Livros Fiscais

@author Luccas Curcio
@since 02/09/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Function XFciX6ToQry( cContent )
Local cRet	:=	""
Local nX	:=	0

If Len( cContent ) > 0

	//Inserindo aspas e virgulas para a query
	cRet := "'"

	For nX := 1 To Len( cContent )
		If SubStr( cContent , nX , 1 ) $ ";,-_|./"
  	   		cRet += "','"
		Else
  	   		cRet += SubStr( cContent , nX , 1 )
		Endif
  	Next

	cRet += "'"
Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XFciFileName

Retorna nome do arquivo do relatorio

@return cFileName	->	Nome do arquivo

@owner	SIGAFIS - Livros Fiscais

@author Luccas Curcio
@since 19/08/2013
@version 11.0

/*/

//-------------------------------------------------------------------
Function XFciFileName()
Local	cFileName	:=	Nil
Local	cAux		:=	Nil

cFileName	:=	"TOTVSFCI_"
cFileName	+=	DToS( Date() ) + "_"

cAux	:=	Time()
cAux	:=	StrTran( cAux , ":" , "" )

cFileName	:=	cFileName + cAux

Return cFileName

//-------------------------------------------------------------------
/*/{Protheus.doc} xFciWizard

Wizard principal da rotina

Funcao que monta wizard para preenchimento das informacoes que serao
utilizadas no processamento do arquivo da FCI

@param	Nil

@return	aWizard	->	Array com conteudo preenchido na wizard

@owner	SIGAFIS - Livros Fiscais

@author Luccas Curcio
@since 26/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function xFciWizard()
Local	aFirstTxt	:=	{}
Local	aGetParam	:=	{}
Local	aWizard		:=	{}
Local	cNameWiz	:=	"FSA061NW"+FWGETCODFILIAL


aAdd (aFirstTxt, "Rotina de Processamento do Arquivo Magnético da FCI.")
aAdd (aFirstTxt, "")
aAdd (aFirstTxt, "Preencha corretamente as perguntas para processamento da rotina.")
aAdd (aFirstTxt, "Informações necessárias para o processamento do Arquivo Magnético da FCI.")

aAdd (aGetParam, {})
aAdd (aGetParam[1], "Preencha corretamente as informações solicitadas.")
aAdd (aGetParam[1], "Parâmetros para Processamento")
aAdd (aGetParam[1], {})

aAdd (aGetParam[1][3], {1,"Data de",,,,,,})
aAdd (aGetParam[1][3], {2,,,3,,,,,,,,{"xMagGetCon",1}})

aAdd (aGetParam[1][3], {0,"",,,,,,}); aAdd (aGetParam[1][3], {0,"",,,,,,})

aAdd (aGetParam[1][3], {1,"Data Até",,,,,,})
aAdd (aGetParam[1][3], {2,,,3,,,,,,,,{"xMagGetCon",1}})

aAdd (aGetParam[1][3], {0,"",,,,,,}); aAdd (aGetParam[1][3], {0,"",,,,,,})

aAdd (aGetParam[1][3], {1,"Produto De",,,,,,})
aAdd (aGetParam[1][3], {2,,Replicate("X",TamSX3("B1_COD")[1]),1,,,,TamSX3("B1_COD")[1],,,"SB1"})

aAdd (aGetParam[1][3], {0,"",,,,,,}); aAdd (aGetParam[1][3], {0,"",,,,,,})

aAdd (aGetParam[1][3], {1,"Produto Até",,,,,,})
aAdd (aGetParam[1][3], {2,,Replicate("X",TamSX3("B1_COD")[1]),1,,,,TamSX3("B1_COD")[1],,,"SB1"})

aAdd (aGetParam[1][3], {0,"",,,,,,}); aAdd (aGetParam[1][3], {0,"",,,,,,})

aAdd (aGetParam[1][3], {1,"Seleciona Filiais?",,,,,,})
aAdd (aGetParam[1][3], {3,,,,,{"1 - Sim" , "2 - Não"},,})

aAdd (aGetParam[1][3], {0,"",,,,,,}); aAdd (aGetParam[1][3], {0,"",,,,,,})

aAdd (aGetParam[1][3], {1,"Versão",,,,,,})
aAdd (aGetParam[1][3], {2,,Replicate("X",4),1,,,,4})

aAdd (aGetParam[1][3], {0,"",,,,,,}); aAdd (aGetParam[1][3], {0,"",,,,,,})

aAdd (aGetParam[1][3], {1,"Considera Produtos Bloqueados?",,,,,,})
aAdd (aGetParam[1][3], {3,,,,,{"1 - Sim" , "2 - Não"},,})

aAdd (aGetParam[1][3], {0,"",,,,,,}); aAdd (aGetParam[1][3], {0,"",,,,,,})

aAdd (aGetParam[1][3], {1, "Se num momento futuro o bem ou mercadoria",,,,,,})
aAdd (aGetParam[1][3], {1, " o contribuinte industrializador poderá",,,,,,,})

aAdd (aGetParam[1][3], {1, "voltar a ter a mesma faixa de Conteúdo de",,,,,,})
aAdd (aGetParam[1][3], {1, "utilizar o número de controle da mesma pois",,,,,,})

aAdd (aGetParam[1][3], {1, "Importação de uma FCI anteriormente trans-",,,,,,})
aAdd (aGetParam[1][3], {1, "a entrega de nova FCI para um mesmo produto",,,,,,})

aAdd (aGetParam[1][3], {1, "mitida",,,,,,,,})
aAdd (aGetParam[1][3], {1, "não substitui a anteriormente apresentada.",,,,,,})

aAdd (aGetParam[1][3], {1,"Usar cod.FCI anterior para mesma faixa?",,,,,,})
aAdd (aGetParam[1][3], {3,,,,,{"1 - Sim" , "2 - Não"},,})

aAdd (aGetParam[1][3], {0,"",,,,,,}); aAdd (aGetParam[1][3], {0,"",,,,,,})

If xMagWizard (aFirstTxt, aGetParam, cNameWiz)
	xMagLeWiz(cNameWiz,@aWizard,.T.)
Endif

Return aWizard

//-------------------------------------------------------------------
/*/{Protheus.doc} XFciGetOrigem

Retorna codigo de origem e codigo da fci conforme produto e periodo
enviados como parametro

@param	cCodProd	->	Codigo do Produto
		dDtEmissao	->	Data de Emissao do movimento

@return Array	->	1 - Codigo da Origem
					2 - Codigo da FCI

@owner	SIGAFIS - Livros Fiscais

@author Luccas Curcio
@since 09/09/2013
@version 11.0

/*/
//-------------------------------------------------------------------
Function XFciGetOrigem( cCodProd , dDtEmissao )
Local cPeriod := Alltrim( StrZero( Month( dDtEmissao ) , 2 ) ) + Alltrim( Str( Year( dDtEmissao ) ) )
Local cOrigem := ""
Local cFciCod := ""
Local cEstado  := SuperGetMv("MV_ESTADO")
Local cUfNwPrd := SuperGetMv("MV_FCINWPR", .F., "")
Local nCont := 0
Local dDataCalc := CToD("")
Local cFilialCFD := xFilial("CFD")
CFD->(DbSetOrder(2)) //PRODUTO + PERIODO
If CFD->(MsSeek(cFilialCFD + cCodProd + cPeriod))
	cOrigem := CFD->CFD_ORIGEM
	cFciCod	:= CFD->CFD_FCICOD
ElseIf cEstado $ cUfNwPrd

	/*
		Conforme parecer da consultoria tributária, chamado TIFG58, deve ser permitida a utilizacao
		de periodos de apuracao diferentes do penultimo para produtos novos. Portanto, Se não encontrar
		registro na CFD e a UF possui tratamento para produtos novos (MV_FCINWPR), tentar localizar
		nos 2 meses anteriores o codigo FCI e a origem para retornar.
	*/

	cOrigem := Space( TamSX3( "CFD_ORIGEM" )[1] )
	cFciCod := Space( TamSX3( "CFD_FCICOD" )[1] )

	dDataCalc := dDtEmissao

	For nCont := 1 to 2
		// Obtendo mes anterior
		dDataCalc := MonthSub( dDataCalc, 1 )

		// Montando novamente o periodo com o mes/ano calculados.
		cPeriod := Alltrim( StrZero( Month( dDataCalc ) , 2 ) ) + Alltrim( Str( Year( dDataCalc ) ) )

		// Se encontrar, retornar a origem e cod. FCI.
			If CFD->( MsSeek( cFilialCFD + cCodProd + cPeriod ) ) .And. CFD->CFD_PERCAL == CFD->CFD_PERVEN
			cOrigem := CFD->CFD_ORIGEM
			cFciCod := CFD->CFD_FCICOD
			Exit
		Endif
	Next nCont
Else
	cOrigem := Space( TamSX3( "CFD_ORIGEM" )[1] )
	cFciCod := Space( TamSX3( "CFD_FCICOD" )[1] )
Endif

Return { cOrigem , cFciCod }

//-------------------------------------------------------------------
/*/{Protheus.doc} XFciVIEnt

Retorna a formula a ser utilizada para calculo da Parcela Importada de
acordo com a configuracao do campo F4_AGREG

@param	cTpAgreg	->	Configuracao utilizada no campo F4_AGREG

@return cRet	->	String com formula a ser aplicada

@owner	SIGAFIS - Livros Fiscais

@author Luccas Curcio
@since 09/09/2013
@version 11.0

/*/
//-------------------------------------------------------------------
Function XFciVIEnt( cTpAgreg )
Local	cRet	:=	''

// --------------------------------------------------------------------------------------------
// S - O valor da mercadoria será agregado ao total do documento.
// --------------------------------------------------------------------------------------------
If cTpAgreg == 'S'
	cRet	:=	'( ( ( D1_TOTAL+D1_VALFRE+D1_SEGURO ) - (D1_VALICM + D1_II) ) / D1_QUANT )'

// --------------------------------------------------------------------------------------------
// I - O valor da mercadoria não contém o valor do ICMS, portanto, o valor do ICMS e da
// mercadoria será agregado ao total do documento.
// --------------------------------------------------------------------------------------------
Elseif cTpAgreg == 'I'
	cRet	:=	'( ( ( D1_TOTAL+D1_VALFRE+D1_SEGURO ) - ( D1_II ) ) / D1_QUANT )'

// --------------------------------------------------------------------------------------------
// A - O valor da mercadoria não contém o valor do ICMS, mas somente o valor da mercadoria
// será agregado ao total do documento. Note que a base de cálculo do ICMS sofrerá
// a incorporação do valor do ICMS.
// --------------------------------------------------------------------------------------------
Elseif cTpAgreg == 'A'
	cRet	:=	'( ( D1_TOTAL+D1_VALFRE+D1_SEGURO ) / D1_QUANT )'

// --------------------------------------------------------------------------------------------
// N - O valor da mercadoria não será agregado ao total do documento. Esse valor poderá
// ser escriturado, ou não, conforme a parametrização do sistema.
// --------------------------------------------------------------------------------------------
Elseif cTpAgreg == 'N'
	cRet	:=	'( ( D1_TOTAL+D1_VALFRE+D1_SEGURO ) / D1_QUANT )'

// --------------------------------------------------------------------------------------------
// B - O valor da mercadoria não contém o valor do ICMS, portanto, o valor do ICMS e da
// mercadoria será agregado ao total do documento. Este agregador de valor não calcula
// nenhum imposto, mantendo-se o que for informado pelo usuário ou transmitido por outro sistema
// --------------------------------------------------------------------------------------------
Elseif cTpAgreg == 'B'
	cRet	:=	'( ( ( D1_TOTAL+D1_VALFRE+D1_SEGURO ) - ( D1_II ) ) / D1_QUANT )'

// --------------------------------------------------------------------------------------------
// C - O valor da mercadoria não contém o valor do ICMS, mas somente o valor da mercadoria será
// agregado ao total do documento. Note que a base de cálcu do ICMS sofrerá a incorporação do valor
// do ICMS. Este agregador de valor não calcula nenhum imposto, mantendo-se o q for informado
// pelo usuário ou transmitid por outro sistema.
// --------------------------------------------------------------------------------------------
Elseif cTpAgreg == 'C'
	cRet	:=	'( ( ( D1_TOTAL+D1_VALFRE+D1_SEGURO ) - ( D1_II ) ) / D1_QUANT )'

// --------------------------------------------------------------------------------------------
// H - Somente o valor do ICMS Retido será agregado ao total do documento fiscal.
// --------------------------------------------------------------------------------------------
Elseif cTpAgreg == 'H'
	cRet	:=	'( ( ( D1_TOTAL+D1_VALFRE+D1_SEGURO ) - ( D1_ICMSRET ) ) / D1_QUANT )'

// --------------------------------------------------------------------------------------------
// R - Deduz o valor do ICMS do valor unitario da mercadoria nos casos de redução de base de cálculo.
// --------------------------------------------------------------------------------------------
Elseif cTpAgreg == 'R'
	cRet	:=	'( ( D1_TOTAL+D1_VALFRE+D1_SEGURO ) / D1_QUANT )'

// -- Formula Generica
Else
	cRet	:=	'( ( ( D1_TOTAL+D1_VALFRE+D1_SEGURO ) - ( D1_VALICM+D1_II ) ) / D1_QUANT )'

Endif

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FciUltPr   ºAutor  ³Anieli Rodrigues   º Data ³  29/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Verifica qual o ultimo periodo no qual houve entrada        º±±
±±º          ³do produto antes do periodo informado                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1: cProduto - Produto a ser avaiado                     º±±
±±º          ³ExpA2: cMes	  - Mes a ser avaliado                        º±±
±±º          ³ExpA3: cAno	  - Ano a ser avaliado                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³cPeriodo: Mes e Ano. String 000000 caso nenhuma entrada     º±±
±±º          ³seja localizada                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FISA061 - Materiais                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FciUltPr(cProduto,cMes,cAno)

Local aAreaSD1	:= SD1->(GetArea())
Local cDbType	:= TCGetDB()
Local cAlias 	:= ""
Local cFuncNull	:= ""
Local cQuery 	:= ""
Local cData   	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nome da funcao do banco de dados que substitui NULL por 0 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case cDbType $ "ORACLE/INFORMIX"
  		cFuncNull	:= "NVL"
 	Otherwise
 		cFuncNull	:= "ISNULL"
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua query para retornar o periodo no qual houve a ultima entrada de nota para o produto ³
//³ Caso nao localize, o retorno sera a string 000000                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias := NewAlias()
cQuery	:= "SELECT " + cFuncNull + " (MAX(SD1.D1_DTDIGIT),'00000000') AS PERIODO"
cQuery += " FROM "+aTabelas[F_SD1]+" SD1 "
cQuery += " WHERE (SD1.D1_FILIAL = '"+aFiliais[F_SD1]+"')"
cQuery += " AND (SD1.D1_COD = '"+cProduto+"' AND SD1.D1_DTDIGIT <= '"+cAno+cMes+"31' "
cQuery += " AND D1_TIPO = 'N' "
If !Empty(cFCICF)
	cQuery += "AND SD1.D1_CF NOT IN ("+cFCICF+") "
EndIf
cQuery += "AND D_E_L_E_T_ = ' ')"
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

cData:= Substr((cAlias)->(PERIODO),1,6)
cMes := Substr(cData,5,2)
cAno := Substr(cData,1,4)

(cAlias)->(DbCloseArea())

RestArea(aAreaSD1)

Return cMes+cAno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FciMedEnt  ºAutor  ³Anieli Rodrigues   º Data ³  03/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Grava a media do valor importado para os produtos comprados º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1: cMes     - Mes a ser calculado                       º±±
±±º          ³ExpA2: cAno	  - Ano a ser calculado                       º±±
±±º          ³ExpA3: cProdDe  - Range de produtos                         º±±
±±º          ³ExpA4: cProdAte - Range de produtos                         º±±
±±º          ³ExpA5: nQtdMes  - Indica o quantidade de meses que deve ser º±±
±±º          ³                  subtraida do mes base para busca da nota  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       |FISA061 - Materiais                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FciMedEnt(cMes,cAno,cProdDe,cProdAte, nQtdMes)

Local aAreaSD1   := SD1->(GetArea())
Local cQuery     := ""
Local cFuncNull  := ""
Local cAlias     := NewAlias()
Local cAliasTb   := NewAlias()
Local cArqTRB    := ""
Local aTam       := {}
Local aCampos    := {}
Local lSigaEIC   := (GetNewPar("MV_EASY",.F.) == "S")
Local lPercom    := SA8->(ColumnPos("A8_PERCOM")) > 0
Local cFuncSubst := "SUBSTRING"
Local cMV_FCIPERI:= SuperGetMV("MV_FCIPERI",.F.,"U")

/*	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Tabela A - Origem da Mercadoria ou Servico                                                                               ³
	³                                                                                                                          ³
	³0 - Nacional - exceto as indicadas nos códigos 3, 4, 5 e 8                                                                ³
	³1 - Estrangeira - Importação direta, exceto a indicada no código 6                                                        ³
	³2 - Estrangeira - Adquirida no mercado interno, exceto a indicada no código 7                                             ³
	³3 - Nacional - mercadoria ou bem com Conteúdo de Importação superior a 40% e inferior ou igual a 70%                      ³
	³4 - Nacional - cuja produção tenha sido feita em conformidade com os processos produtivos básicos de que tratam o         ³
	³    Decreto-Lei nº 288/67, e as Leis nº 8.248/91, 8.387/91, 10.176/01 e 11.484/07                                         ³
	³5 - Nacional - mercadoria ou bem com Conteúdo de Importação inferior ou igual a 40% (quarenta por cento)                  ³
	³6 - Estrangeira - Importação direta, sem similar nacional, constante em lista de Resolução CAMEX e gás natural            ³
	³7 - Estrangeira - Adquirida no mercado interno, sem similar nacional, constante em lista de Resolução CAMEX e gás natural ³
	³8 - Nacional - mercadoria ou bem com Conteúdo de Importação superior a 70% (setenta por cento)                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ATENCAO: Ao realizar a manutencao do as Querys dessa funcao, obrigatoriamente deve-se ³
//³ revisar as querys do relatorio FCIR002.PRW. Ambos utilizam a mesma logica nas Querys. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Arquivo de Trabalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:= TamSX3("D1_COD")
Aadd(aCampos,{"D1_COD","C",aTam[1],aTam[2]})

aTam:= TamSX3("D1_QUANT")
Aadd(aCampos,{"QUANTIDADE","N",aTam[1],aTam[2]})

aTam:= TamSX3("D1_VUNIT")
Aadd(aCampos,{"VI","N",aTam[1],aTam[2]})

If lPercom
	aTam:= TamSX3("A8_PERCOM")
	Aadd(aCampos,{"PERIODO","C",aTam[1],aTam[2]})
EndIf

cArqTRB := CriaTrab(,.F.)
DbCreate(cArqTRB,aCampos,'SQLITE_TMP')
DbUseArea(.T.,'SQLITE_TMP',cArqTRB,cAliasTb,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria indice para Arquivo de Trabalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasTb)
IndRegua( cAliasTb, cArqTRB+"1", "D1_COD",,,"Codigo do Produto" )
dbClearIndex()
dbSetIndex( cArqTRB+"1" + OrdBagExt() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para ISNULL em diferentes BD's ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case cDbType $ "ORACLE/INFORMIX"
  		cFuncNull	:= "NVL"
 	Otherwise
 		cFuncNull	:= "ISNULL"
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para SUBSTRING em diferentes BD's ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cDbType $ "ORACLE/POSTGRES/DB2"
	cFuncSubst  := "SUBSTR"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query para retornar todos as entradas de MP do periodo, agrupadas por Codigo de Produto ³
//³ --------------------------------------------------------------------------------------- ³
//³ ATENCAO: Caso seja necessario alterar esta QUERY, replicar as alteracoes para a QUERY   ³
//³ que realiza o tratamento para NF's de Complemento de Preco (MV_FCICOMP), na sequencia   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT "

cQuery += "SUM( CASE WHEN "
cQuery += " "+cFuncSubst+"(SD1.D1_DTDIGIT, 1, 6) = "+cFuncSubst+"(S.D1_DTDIGIT, 1, 6) "
cQuery += " THEN "
cQuery +=   " SD1.D1_QUANT "
cQuery += " ELSE "
cQuery +=   " 0 "
cQuery += "END ) QUANTIDADE, "

cQuery += "SUM( "
cQuery += "CASE WHEN "
cQuery += " "+cFuncSubst+"(SD1.D1_DTDIGIT, 1, 6) = "+cFuncSubst+"(S.D1_DTDIGIT, 1, 6) "
cQuery += " THEN "
cQuery += "  CASE "
// Fator Agrega Valor (VL)
cQuery += "WHEN SF4.F4_AGREG IN ('I','S') AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO)-(SD1.D1_II)) "
If lSigaEIC
	cQuery += "WHEN SF4.F4_AGREG IN ('C','B') AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO)- " + cFuncNull + " (SWN.WN_IIVAL+SWN.WN_DESPADU,SD1.D1_II)) "
EndIf
cQuery += "WHEN SF4.F4_AGREG IN ('A','N','R') AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO)) "
cQuery += "WHEN SF4.F4_AGREG = 'H' AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO)-(SD1.D1_ICMSRET)) "
cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) IN ('2','3','8') THEN ((SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO)-(SD1.D1_VALICM)) "
cQuery += "ELSE ((SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO)-(SD1.D1_VALICM+SD1.D1_II)) END "
// Fator Situacao Tributaria (FST)
cQuery += "*(CASE "
cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '3' THEN 0.5 "
cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '8' THEN 1 "
cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '2' THEN 1 "
cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '1' THEN 1 ELSE 0 END) "

cQuery += " ELSE "
cQuery += " 0 "
cQuery += "END) VI, "
// Fim (VL)+(FST)

cQuery += "SD1.D1_COD "
If lPercom
	cQuery += ","+cFuncSubst+"(MAX("

	If cMV_FCIPERI == "U"
		cQuery +=  "SD1.D1_DTDIGIT"
	Else
		cQuery += "S.D1_DTDIGIT"
	EndIf

	cQuery += "), 1, 6) PERCOM "

Else
	cQuery += ",' ' PERCOM "
EndIf
cQuery += "FROM "+aTabelas[F_SD1]+" SD1 "

cQuery += " INNER JOIN ( select D1_COD, MAX(D1_DTDIGIT) D1_DTDIGIT "
cQuery +=          " from "+aTabelas[F_SD1]+" "
cQuery +=          " where D1_FILIAL = '"+aFiliais[F_SD1]+"' "
cQuery +=          " and D1_COD >= '"+cProdDe+"' "
cQuery +=          " and D1_COD <= '"+cProdAte+"' "
cQuery +=          " and D1_DTDIGIT <= '"+cAno+cMes+"31' "
cQuery +=          " and D1_TIPO = 'N' "
If cMV_FCIPERI =="U"
	cQuery +=       " and "+cFuncSubst+"(D1_CLASFIS,1,1) IN ('1','2','3','8') "
EndIf
If !Empty(cFCICF)
	cQuery +=      " and D1_CF NOT IN ("+cFCICF+") "
EndIf
cQuery +=         " and D_E_L_E_T_ = ' ' "
cQuery +=         " group by D1_COD "
cQuery +=      " ) S on "
cQuery += "	S.D1_COD = SD1.D1_COD "

cQuery += "JOIN "+aTabelas[F_SF4]+" SF4 ON SF4.F4_FILIAL = '"+aFiliais[F_SF4]+"' "
cQuery += "AND SF4.F4_CODIGO = SD1.D1_TES "
cQuery += "AND SF4.D_E_L_E_T_ = ' ' "
If lSigaEIC
	cQuery += "LEFT JOIN " + aTabelas[F_SWN] + " SWN ON SWN.WN_FILIAL = SD1.D1_FILIAL "
	cQuery += "AND SWN.WN_DOC = SD1.D1_DOC AND SWN.WN_SERIE = SD1.D1_SERIE AND (SWN.WN_TEC||SWN.WN_EX_NCM||SWN.WN_EX_NBM) = SD1.D1_TEC "
	cQuery += "AND SWN.WN_FORNECE = SD1.D1_FORNECE AND SWN.WN_LOJA = SD1.D1_LOJA AND SWN.WN_PRODUTO = SD1.D1_COD AND SWN.WN_LINHA = CAST(SD1.D1_ITEM AS DECIMAL(20)) "
	cQuery += " AND SWN.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " WHERE SD1.D1_FILIAL = '"+aFiliais[F_SD1]+"' "
cQuery += " AND SD1.D1_DTDIGIT <= '"+cAno+cMes+"31' "
cQuery += " AND SD1.D_E_L_E_T_ = ' ' "
cQuery += " AND SD1.D1_COD >= '"+cProdDe+"' "
cQuery += " AND SD1.D1_COD <= '"+cProdAte+"' "
cQuery += " AND SD1.D1_TIPO = 'N' "
cQuery += " AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) IN ('1','2','3','8') "
If !Empty(cFCICF)
	cQuery += "AND SD1.D1_CF NOT IN ("+cFCICF+") "
EndIf
cQuery += " GROUP BY SD1.D1_COD "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o cliente habilite o parametro MV_FCICOMP, sera realizado calculo e atualizacao da SA8 ³
//³ com base nos complementos de preco (Tipo C) existentes para as NF's do Tipo N do periodo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFCIComp

	cQuery += " UNION "
	cQuery += "SELECT 0 QUANTIDADE, "
	cQuery += " SUM("
	cQuery += "CASE WHEN "
	cQuery += " "+cFuncSubst+"(SD1.D1_DTDIGIT, 1, 6) = "+cFuncSubst+"(S.D1_DTDIGIT, 1, 6) "
	cQuery += " THEN "
	cQuery += "	CASE "
	// Fator Agrega Valor (VL)
	cQuery += "WHEN SF4.F4_AGREG IN ('I','S') AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1C.D1_TOTAL+SD1C.D1_VALFRE+SD1C.D1_SEGURO)-(SD1C.D1_II)) "
	If lSigaEIC
		cQuery += "WHEN SF4.F4_AGREG IN ('C','B') AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1C.D1_TOTAL+SD1C.D1_VALFRE+SD1C.D1_SEGURO)- "+cFuncNull+" (SWN.WN_IIVAL+SWN.WN_DESPADU,SD1C.D1_II)) "
	EndIf
	cQuery += "WHEN SF4.F4_AGREG IN ('A','N','R') AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1C.D1_TOTAL+SD1C.D1_VALFRE+SD1C.D1_SEGURO)) "
	cQuery += "WHEN SF4.F4_AGREG = 'H' AND "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) NOT IN ('2','3','8') THEN ((SD1C.D1_TOTAL+SD1C.D1_VALFRE+SD1C.D1_SEGURO)-(SD1C.D1_ICMSRET)) "
	cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) IN ('2','3','8') THEN ((SD1C.D1_TOTAL+SD1C.D1_VALFRE+SD1C.D1_SEGURO)-(SD1C.D1_VALICM)) "
	cQuery += "ELSE ((SD1C.D1_TOTAL+SD1C.D1_VALFRE+SD1C.D1_SEGURO)-(SD1C.D1_VALICM+SD1.D1_II)) END*"
	// Fator Situacao Tributaria (FST)
	cQuery += "(CASE "
	cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '3' THEN 0.5 "
	cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '8' THEN 1 "
	cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '2' THEN 1 "
	cQuery += "WHEN "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) = '1' THEN 1 ELSE 0 END) "
	cQuery += " ELSE 0 END ) AS VI, "
	// Fim (VL)+(FST)
	cQuery += "SD1C.D1_COD "
	cQuery += ",' ' PERCOM "
	cQuery += "FROM "+aTabelas[F_SD1]+" SD1 JOIN "+aTabelas[F_SF4]+" SF4 ON "
	cQuery += "SF4.F4_FILIAL = '"+aFiliais[F_SF4]+"' AND "
	cQuery += "SF4.F4_CODIGO = SD1.D1_TES AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN ( select D1_COD, MAX(D1_DTDIGIT) D1_DTDIGIT "
	cQuery +=          " from "+aTabelas[F_SD1]+" "
	cQuery +=          " where D1_FILIAL = '"+aFiliais[F_SD1]+"' "
	cQuery +=          " and D1_COD >= '"+cProdDe+"' "
	cQuery +=          " and D1_COD <= '"+cProdAte+"' "
	cQuery +=          " and D1_DTDIGIT <= '"+cAno+cMes+"31' "
	cQuery +=          " and D1_TIPO = 'N' "
	If cMV_FCIPERI =="U"
		cQuery +=       " and "+cFuncSubst+"(D1_CLASFIS,1,1) IN ('1','2','3','8') "
	EndIf
	If !Empty(cFCICF)
		cQuery +=      " and D1_CF NOT IN ("+cFCICF+") "
	EndIf
	cQuery +=         " and D_E_L_E_T_ = ' ' "
	cQuery +=         " group by D1_COD "
	cQuery +=      " ) S on "
	cQuery += "	S.D1_COD = SD1.D1_COD "
	cQuery += "INNER JOIN "+aTabelas[F_SD1]+" SD1C ON "
	cQuery += "SD1.D1_DOC = SD1C.D1_NFORI AND "
	cQuery += "SD1.D1_ITEM = SD1C.D1_ITEMORI AND "
	cQuery += "SD1.D1_SERIE = SD1C.D1_SERIORI AND "
	cQuery += "SD1.D1_COD = SD1C.D1_COD AND "
	cQuery += "SD1.D1_FORNECE = SD1C.D1_FORNECE AND "
	cQuery += "SD1.D1_LOJA = SD1C.D1_LOJA "
	If lSigaEIC
		cQuery += "LEFT JOIN "+aTabelas[F_SWN]+" SWN ON SWN.WN_FILIAL = SD1C.D1_FILIAL "
		cQuery += "AND SWN.WN_DOC = SD1C.D1_DOC AND SWN.WN_SERIE = SD1C.D1_SERIE AND (SWN.WN_TEC||SWN.WN_EX_NCM||SWN.WN_EX_NBM) = SD1C.D1_TEC "
		cQuery += "AND SWN.WN_FORNECE = SD1C.D1_FORNECE AND SWN.WN_LOJA = SD1C.D1_LOJA AND SWN.WN_PRODUTO = "
		cQuery += "SD1C.D1_COD AND SWN.WN_LINHA = CAST(SD1C.D1_ITEM AS DECIMAL(20)) AND SWN.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "WHERE SD1.D1_FILIAL = '"+aFiliais[F_SD1]+"' AND "
	cQuery += "SD1.D1_DTDIGIT <= '"+cAno+cMes+"31' AND "
	cQuery += "SD1.D_E_L_E_T_ = ' ' AND "
	cQuery += "SD1C.D_E_L_E_T_ = ' ' AND "
	cQuery += "SD1.D1_TIPO = 'N' AND "
	cQuery += " "+cFuncSubst+"(SD1.D1_CLASFIS,1,1) IN ('1','2','3','8') AND "
	If !Empty(cFCICF)
		cQuery += "SD1.D1_CF NOT IN ("+cFCICF+") AND SD1C.D1_CF NOT IN ("+cFCICF+") AND "
	EndIf
	cQuery += " SD1C.D1_TIPO = 'C' "
	cQuery += " GROUP BY SD1C.D1_COD"

	cQuery := "SELECT SUM(QUANTIDADE) QUANTIDADE, sum(VI) VI, D1_COD, MAX(PERCOM) PERCOM FROM ("+cQuery+") ENTRADAS "
	cQuery += " GROUP BY ENTRADAS.D1_COD "
	cQuery += " ORDER BY ENTRADAS.D1_COD "

EndIf
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o Arquivo de Trabalho com os dados da Query ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !(cAlias)->(Eof())
    RecLock(cAliasTb,.T.)
    (cAliasTb)->D1_COD		:= (cAlias)->D1_COD
    (cAliasTb)->QUANTIDADE	:= (cAlias)->QUANTIDADE
    (cAliasTb)->VI			:= (cAlias)->VI
    If lPercom
    	(cAliasTb)->PERIODO		:= (cAlias)->PERCOM
    EndIf
    (cAliasTb)->(MsUnLock())
	(cAlias)->(DbSkip())
EndDo

(cAlias)->(DbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava todos os VI's, encontrados para o periodo, na tabela SA8.               ³
//³ Formula do VI:  (D1_TOTAL+D1_VALFRE+D1_SEGURO)-(D1_VALICM+D1_VALIPI)/D1_QUANT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
(cAliasTb)->(dbGoTop())
While !(cAliasTb)->(Eof())
   DbSelectArea('SA8')
	SA8->(DbSetOrder(1))
	If !DbSeek(aFiliais[F_SA8]+(cAliasTb)->D1_COD+cMes+cAno)
		RecLock('SA8',.T.)
		Replace A8_FILIAL 	With aFiliais[F_SA8]
		Replace A8_COD    	With (cAliasTb)->D1_COD
		Replace A8_PERIOD	With cMes+cAno
		Replace A8_VLRVI 	With (cAliasTb)->(VI)/(cAliasTb)->(QUANTIDADE)
		Replace A8_PROCOM	With "C"
		If lPercom
			Replace  	A8_PERCOM	With (cAliasTb)->(PERIODO)
		EndIf
		SA8->(MsUnlock())
	Else
		RecLock('SA8',.F.)
		Replace   A8_VLRVI 	With (cAliasTb)->VI/(cAliasTb)->QUANTIDADE
		Replace	 A8_PROCOM	With "C"
		SA8->(MsUnlock())
	EndIf
	(cAliasTb)->(DbSkip())
EndDo

(cAliasTb)->(DbCloseArea())
DBSqlExec(cAliasTb, 'DROP TABLE ' + cArqTRB , 'SQLITE_TMP')
RestArea(aAreaSD1)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FciMedPr   ºAutor  ³Anieli Rodrigues   º Data ³  03/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Grava a media do valor importado para os produtos fabricadosº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1: cMes     - Mes a ser calculado                       º±±
±±º          ³ExpA2: cAno     - Ano a ser calculado                       º±±
±±º          ³ExpA3: cProdDe  - Range de produtos                         º±±
±±º          ³ExpA4: cProdAte - Range de produtos                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       |FISA061 - Materiais                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FciMedPr(cMes,cAno,cProdDe,cProdAte)

Local aAreaSD3  := SD3->(GetArea())
Local cAliasSB1 := NewAlias()
Local cQuery    := ""
Local cData     := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua query para obter a producao de todos os produtos acabados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT MAX(SD3.D3_EMISSAO) AS PERIODO, D3_COD AS PRODUTO "
cQuery += "FROM "+aTabelas[F_SD3]+" SD3 LEFT JOIN "+aTabelas[F_SB1]+" SB1 "
cQuery += "ON B1_FILIAL = '"+aFiliais[F_SB1]+"' AND D3_FILIAL = '"+aFiliais[F_SD3]+"' AND SB1.B1_COD = SD3.D3_COD "
//Join na SA8 para trazer o que nao tem na tabela.
cQuery += "LEFT JOIN "+aTabelas[F_SA8]+" SA8 "
cQuery += "ON A8_FILIAL = '"+aFiliais[F_SA8]+"' AND SA8.A8_COD = SD3.D3_COD AND A8_PERIOD = '"+cMes+cAno+"' "
cQuery += "AND A8_FILIAL IS NULL "
//////////////////
cQuery += "WHERE SD3.D3_CF IN ('PR0','PR1') "
cQuery += "AND SD3.D3_COD >= '"+cProdDe+"' AND SD3.D3_COD <= '"+cProdAte+"' "
cQuery += "AND SD3.D3_EMISSAO BETWEEN '"+cAno+cMes+"01' AND '"+cAno+cMes+"31' "
cQuery += "AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO = ' ' "
cQuery += "AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY SD3.D3_COD "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1,.T.,.T.)

While !(cAliasSB1)->(Eof())

	cData := SubStr((cAliasSB1)->PERIODO,1,6)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao localizado na SA8, sera necessario apurar sua media ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FciMedPer((cAliasSB1)->PRODUTO,Substr(cData,5,2),Substr(cData,1,4))
	(cAliasSB1)->(DbSkip())
	Loop
EndDo

(cAliasSB1)->(dbclosearea())
RestArea(aAreaSD3)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FciExplReq ºAutor  ³Anieli Rodrigues   º Data ³  04/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Explode as requisicoes e devolve o somatorio do VI de cada  º±±
±±º          ³materia prima utilizada na requisicao. (Recursiva)          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1: cOp  - Op a ter as requisicoes explodidas            º± ±
±±º          ³ExpA2: cMes - Mes a ser avaliado                            º±±
±±º          ³ExpA3: cAno - Ano a ser avaliado                            º±±
±±º          ³ExpA4: cProd - Produto pai da ordem de producao             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³nVi : Valor da parcela importada do produto acabado         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       |FISA061 - Materiais                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FciExplReq(cOp,cMes,cAno,cProd)

Local cAliasReq := NewAlias()
Local cTempTable := "FCITEMPFAB"
Local cAliasTemp	:= ""
Local cAliasPi  := ""
Local cAliasSD3 := SD3->(GetArea())
Local cCccusto  := Criavar("B1_CCCUSTO",.F.)
Local cPeriodo  := ""
Local cQuery    := ""
Local cData     := ""
Local cFuncSubst:= "SUBSTRING"
Local nVi       := 0
Default cProd   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para SUBSTRING em diferentes BD's ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cDbType $ "ORACLE/POSTGRES/DB2"
	cFuncSubst  := "SUBSTR"
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua query para localizar todas as requisicoes realizadas para a OP ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) "
cQuery += "WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) ELSE 0 END) AS QUANTIDADE, SD3.D3_COD "
cQuery += "FROM "+aTabelas[F_SD3]+" SD3 JOIN "+aTabelas[F_SB1]+" SB1 "
cQuery += "ON SB1.B1_FILIAL = '"+aFiliais[F_SB1]+"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "WHERE SD3.D3_FILIAL = '"+aFiliais[F_SD3]+"' "
cQuery += "AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO = ' ' "
cQuery += "AND SD3.D3_OP = '"+cOP+"' AND (SD3.D3_CF LIKE ('RE%') OR SD3.D3_CF LIKE ('DE%')) "
cQuery += "AND "+cFuncSubst+" (SB1.B1_COD,1,3) <> 'MOD' "
cQuery += "AND SB1.B1_CCCUSTO = '"+cCccusto+"' AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY D3_COD ORDER BY SD3.D3_COD"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasReq,.T.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua query para avaliar se o produto requisitado foi produzido ou fabricado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !(cAliasReq)->(Eof())
	If lFabBefore
		cAliasTemp	:= NewAlias()
		cQuery := "SELECT PERIODO "
		cQuery += " FROM "+cTempTable+" "
		cQuery += "WHERE FILIAL = '"+aFiliais[F_SD3]+"' "
		cQuery += "AND COD = '"+(cAliasReq)->D3_COD+"' "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTemp,.T.,.T.)

		cData := SubStr((cAliasTemp)->PERIODO,1,6)

		(cAliasTemp)->(DbCloseArea())
	Else
		If !((cAliasFb)->(DbSeek(aFiliais[F_SD3]+(cAliasReq)->D3_COD)))
			cAliasPi  := NewAlias()
			cProd := (cAliasReq)->D3_COD
			cQuery := "SELECT MAX(SD3.D3_EMISSAO) AS PERIODO "
			cQuery += " FROM "+aTabelas[F_SD3]+" SD3 "
			cQuery += "WHERE SD3.D3_FILIAL = '"+aFiliais[F_SD3]+"' "
			cQuery += "AND SD3.D3_COD = '" +cProd+"' "
			cQuery += "AND SD3.D3_LOCAL <> ' ' "
			cQuery += "AND SD3.D3_EMISSAO <= '"+cAno+cMes+"31' "
			cQuery += "AND (SD3.D3_CF = 'PR0' OR SD3.D3_CF = 'PR1') "
			cQuery += "AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO = ' ' "

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPi,.T.,.T.)

			cData := SubStr((cAliasPi)->PERIODO,1,6)

			RecLock(cAliasFb,.T.)
				(cAliasFb)->FILIAL := aFiliais[F_SD3]
				(cAliasFb)->COD := (cAliasReq)->D3_COD
				(cAliasFb)->PERIODO := cData
			(cAliasFb)->(MsUnlock())

			(cAliasPi)->(DbCloseArea())
		Else

			cData := (cAliasFb)->PERIODO
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o produto requisitado tenha sido produzido, calcula a media de suas producoes no periodo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cData)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apos calcular a media, recupera o valor gravado na SA8 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SA8->(MsSeek(aFiliais[F_SA8]+(cAliasReq)->D3_COD+Substr(cData,5,2)+Substr(cData,1,4)))
			nVi += SA8->A8_VLRVI*(cAliasReq)->QUANTIDADE
		Else
		    FciMedPr(Substr(cData,5,2),Substr(cData,1,4),(cAliasReq)->D3_COD,(cAliasReq)->D3_COD)
		    SA8->(MsSeek(aFiliais[F_SA8]+(cAliasReq)->D3_COD+Substr(cData,5,2)+Substr(cData,1,4)))
		    nVi += SA8->A8_VLRVI*(cAliasReq)->QUANTIDADE
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o produto requisitado tenha sido comprado, localiza se existe SA8 para o periodo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SA8->(DbSetOrder(1))
		If SA8->(MsSeek(aFiliais[F_SA8]+(cAliasReq)->D3_COD+cMes+cAno))
			nVi += SA8->A8_VLRVI*(cAliasReq)->QUANTIDADE
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao houver SA8, verifica quando foi a ultimo aquisicao do produto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cPeriodo := FciUltPr((cAliasReq)->D3_COD,cMes,cAno)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao houve compra para o produto, pode ser utilizado o ponto de entrada 'FCIINFVI' para ³
			//³ informacao do valor. Caso contrario, sera assumido que a parcela de importacao eh zero    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPeriodo == "000000"
				If lFCIINFVI
					nVi += ExecBlock('FCIINFVI',.F.,.F.,{(cAliasReq)->D3_COD,cMes,cAno,(cAliasReq)->QUANTIDADE,cOp})
				Else
					nVi += 0
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se houve compra em mes anterior, verifica que se o VI deste mes ja esta apurado na SA8 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SA8->(MsSeek(aFiliais[F_SA8]+(cAliasReq)->D3_COD+cPeriodo))
					nVi += SA8->A8_VLRVI*(cAliasReq)->QUANTIDADE
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se nao ha SA8 processa sua gravacao e obtencao do VI do mes correspondente ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FciMedEnt(Substr(cPeriodo,1,2),Substr(cPeriodo,3,4),(cAliasReq)->D3_COD,(cAliasReq)->D3_COD, 0)
					If SA8->(MsSeek(aFiliais[F_SA8]+(cAliasReq)->D3_COD+cPeriodo))
						nVi += SA8->A8_VLRVI*(cAliasReq)->QUANTIDADE
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	(cAliasReq)->(DbSkip())
End
(cAliasReq)->(DbCloseArea())
RestArea(cAliasSD3)

Return nVi

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FciMatCalc ºAutor  ³Anieli Rodrigues   º Data ³  06/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Processamento principal do FCI                              º±±
±±º          ³ A tabela SA8 sera alimentada para produtos comprados e     º±±
±±º          ³produzidos para ser utiliza na apuracao da FCI              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: cMes     - Mes a processar                           º±±
±±º          ³ExpC2: cAno     - Ano a processar                           º±±
±±º          ³ExpC3: cProdDe  - Do Produto                                º±±
±±º          ³ExpC4: cProdAte - Ate o produto                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FISA061 - Materiais                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FciMatCalc(cMes,cAno,cProdDe,cProdAte)

Private aProc   := {}
Private cFCICF	:= AllTrim(SuperGetMV("MV_FCICF",.F.,"")) // Parametro para filtrar CFOP's que nao serao processadas
Private lFCIComp	:= SuperGetMV("MV_FCICOMP",.F.,.F.)       // Indica se considera NF's de Complemento de Preco
Private lFCIINFVI := ExistBlock('FCIINFVI')
Private cDbType	:= TCGetDB()
Private aFiliais 	:= { xFilial("SD1"),;
						 xFilial("SD2"),;
						 xFilial("SD3"),;
						 xFilial("SA8"),;
						 xFilial("CFD"),;
						 xFilial("SF4"),;
						 xFilial("SB1")}

Private aTabelas := { RetSQLName("SD1"),;
						 RetSQLName("SD2"),;
						 RetSQLName("SD3"),;
						 RetSQLName("SA8"),;
						 RetSQLName("CFD"),;
						 RetSQLName("SF4"),;
						 RetSQLName("SB1"),;
						 RetSQLName("SWN")}

Static cTexto   := STR0005+PULALINHA //"Existem produtos com recursividade na estrutura obtida através da movimentacao. Abaixo serao listadas as ordens de producao cujo calculo da parcela importada foi comprometido por este motivo: "+PULALINHA //"Existem produtos com recursividade na estrutura obtida através da movimentacao. Abaixo serao listadas as ordens de producao cujo calculo da parcela importada foi comprometido por este motivo: "
Static lErro    := .F.

cProdDe  := PadR(cProdDe,tamsx3('D3_COD')[1])
cProdAte := PadR(cProdAte,tamsx3('D3_COD')[1])

//Cria arquivo temporario
FCITempTab(cMes,cAno)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta registros jah existentes na SA8 para o periodo processado              			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FCIDelRec(cMes,cAno)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera campo D3_VLRVI para o periodo processado                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FCIZeraD3(cMes,cAno)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa todas as entradas de materia prima para o periodo correspondente                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FciMedEnt(cMes,cAno,PadR('',tamsx3('D3_COD')[1]),Replicate('Z',tamsx3('D3_COD')[1]), 2)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa as ordens de producao do periodo de acordo com o range de produtso informado     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FciMedPr(cMes,cAno,cProdDe,cProdAte)

aProc := {}

If lErro
	FCIGravaLog(cTexto)
EndIf

//Fecha Arquivo temporario
FCITempFim()
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FCIMediaP ³ Autor ³ Robson Sales           ³ Data ³03.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao responsavel pelo calculo da media ponderada do perc. ³±±
±±³          ³ de componentes importados de um produto (FCI).              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial para pesquisa                                ³±±
±±³          ³ ExpC2 = Codigo do produto acabado                           ³±±
±±³          ³ ExpD1 = Data inicial do periodo da pesquisa                 ³±±
±±³          ³ ExpD2 = Data final do periodo da pesquisa                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FCIMediaP(cFil,cProduto,dDtIni,dDtFim)

Local aArea  	:= GetArea()
Local cAlias 	:= NewAlias()
Local cPeriodo	:= ""
Local cQry		:= ""
Local cFuncSubst:= "SUBSTRING"
Local nRet		:= 0

Local cDbType	:= TCGetDB()

Private aTabelas := { RetSQLName("SD1"),;
						 RetSQLName("SD2"),;
						 RetSQLName("SD3"),;
						 RetSQLName("SA8"),;
						 RetSQLName("CFD"),;
						 RetSQLName("SF4"),;
						 RetSQLName("SB1"),;
						 RetSQLName("SWN")}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para SUBSTRING em diferentes BD's ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cDbType $ "ORACLE/POSTGRES/DB2"
	cFuncSubst  := "SUBSTR"
EndIf

cPeriodo := FciUltProd(cFil,cProduto,dDtIni,dDtFim)

If cPeriodo != "000000"
	cQry := "SELECT SUM(D3_QUANT*D3_PERIMP)/SUM(D3_QUANT) AS MEDIA"
	cQry += " FROM "+aTabelas[F_SD3]
	cQry += " WHERE D3_FILIAL = '"+xFilial("SD3",cFil)+"'"
	cQry += " AND D3_COD = '"+cProduto+"'"
	cQry += " AND "+cFuncSubst+"(D3_EMISSAO,1,6) = '"+Substr(cPeriodo,3)+Substr(cPeriodo,1,2)+"'"
	cQry += " AND D3_ESTORNO = ' ' "
	cQry += " AND D3_CF IN ('DE4','DE7','PR0') "
	cQry += " AND D3_QUANT > 0 "
	cQry += " AND D_E_L_E_T_ = ' '"

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlias,.T.,.T.)
	nRet := (cAlias)->MEDIA
	(cAlias)->(dbCloseArea())
EndIf
RestArea(aArea)

Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FCIDelRec ³ Autor ³ Anieli Rodrigues       ³ Data ³28.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao responsavel pela delecao dos registros gerados na SA8³±±
±±³          ³ caso a apuracao ja tenha sido realizada anteriormente       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: cMes     - Mes a processar                           ³±±
±±³          ³ ExpC2: cAno     - Ano a processar                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FCIDelRec(cMes,cAno)

Local aArea  	:= GetArea()
Local aAreaSA8 	:= SA8->(GetArea())

SA8->(DbSetOrder(2))
If SA8->(MsSeek(aFiliais[F_SA8]+cMes+cAno))
	While SA8->A8_FILIAL == aFiliais[F_SA8] .And. SA8->A8_PERIOD == cMes+cAno
		RecLock('SA8',.F.)
		SA8->(DbDelete())
		SA8->(MsUnLock())
		SA8->(DbSkip())
	EndDo
EndIf

RestArea(aArea)
RestArea(aAreaSA8)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FCIZeraD3 ³ Autor ³ Anieli Rodrigues       ³ Data ³28.09.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao responsavel pela delecao dos valores registrados na  ³±±
±±³          ³ SD3 caso a apuracao ja tenha sido realizada anteriormente   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: cMes     - Mes a processar                           ³±±
±±³          ³ ExpC2: cAno     - Ano a processar                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FCIZeraD3(cMes,cAno)

Local aArea  	:= GetArea()
Local aAreaSD3 	:= SD3->(GetArea())
Local cQuery    := ""

cQuery := "UPDATE "
cQuery += aTabelas[F_SD3]+" "
cQuery += "SET D3_VLRVI = 0 "
cQuery += "WHERE D3_FILIAL='"+aFiliais[F_SD3]+"' AND "
cQuery += "D_E_L_E_T_= ' ' AND "
cQuery += "D3_ESTORNO = ' ' AND "
cQuery += "D3_CF IN ('PR0','PR1') AND D3_EMISSAO BETWEEN '"+cAno+cMes+"01' AND '"+cAno+cMes+"31'"

TcSqlExec(cQuery)

RestArea(aAreaSD3)
RestArea(aArea)

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FciUltProd³ Autor ³ Anieli Rodrigues       ³ Data ³23.10.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao responsavel por obter o ultimo período para o qual   ³±±
±±³          ³ houve movimentacao de entrada do produto (producao,         ³±±
±±³          ³ transferencia ou desmontagem.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial para pesquisa                                ³±±
±±³          ³ ExpC2 = Codigo do produto acabado                           ³±±
±±³          ³ ExpD1 = Data inicial do periodo da pesquisa                 ³±±
±±³          ³ ExpD2 = Data final do periodo da pesquisa                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FciUltProd(cFil,cProduto,dDtIni,dDtFim)
Local aAreaAnt   	:= GetArea()
Local aAreaSD3	:= SD3->(GetArea())
Local cAlias 	:= ""
Local cFuncNull	:= ""
Local cQuery 	:= ""
Local cData   	:= ""

Local cDbType	:= TCGetDB()

Private aFiliais 	:= { xFilial("SD1"),;
						 xFilial("SD2"),;
						 xFilial("SD3"),;
						 xFilial("SA8"),;
						 xFilial("CFD"),;
						 xFilial("SF4"),;
						 xFilial("SB1")}

Private aTabelas := { RetSQLName("SD1"),;
						 RetSQLName("SD2"),;
						 RetSQLName("SD3"),;
						 RetSQLName("SA8"),;
						 RetSQLName("CFD"),;
						 RetSQLName("SF4"),;
						 RetSQLName("SB1"),;
						 RetSQLName("SWN")}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nome da funcao do banco de dados que substitui NULL por 0³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case cDbType $ "ORACLE/INFORMIX"
  		cFuncNull	:= "NVL"
 	Otherwise
 		cFuncNull	:= "ISNULL"
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua query para retornar o periodo no qual houve a ultima entrada de producacao, transferencia ou desmontagem|									  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAlias := NewAlias()
cQuery	:= "SELECT " + cFuncNull + " (MAX(SD3.D3_EMISSAO),'00000000') AS PERIODO "
cQuery += "FROM "+aTabelas[F_SD3]+" SD3 "
cQuery += " WHERE SD3.D3_FILIAL = '"+aFiliais[F_SD3]+"'"
cQuery += " AND SD3.D3_COD = '"+cProduto+"'"
cQuery += " AND SD3.D3_EMISSAO <= '"+dtos(dDtFim)+"'"
cQuery += " AND D3_ESTORNO = ' ' "
cQuery += " AND D3_CF IN ('DE4','DE7','PR0') "
cQuery += " AND D_E_L_E_T_ = ' '"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

cData:= Substr((cAlias)->(PERIODO),1,6)
cMes := Substr(cData,5,2)
cAno := Substr(cData,1,4)

(cAlias)->(DbCloseArea())

RestArea(aAreaSD3)
RestArea(aAreaAnt)
Return cMes+cAno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FciMedPer ³ Autor ³ Anieli Rodrigues       ³ Data ³23.10.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao responsavel por calcular a media do VI para o produto³±±
±±³          ³ produzido no periodo.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto acabado                           ³±±
±±³          ³ ExpC2 = Mes para calculo da media                           ³±±
±±³          ³ ExpC3 = Ano para calculo da media                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FciMedPer(cProduto,cMes,cAno)
Local aAreaAnt  := GetArea()
Local aAreaSD3  := SD3->(GetArea())
Local aAreaSA8  := SA8->(GetArea())
Local cAlias    := NewAlias()
Local cSA8Alias := NewAlias()
Local cOp       := ""
Local lRecursiv := .F.
Local nQuantTot := 0
Local nVi       := 0
Local nViTotal  := 0
Local nRecSA8	:= 0
Local cQuery2	:= ""
Local cLinha	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua query para obter todas as ordens de producao do periodo para o produto |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SUM(D3_QUANT) AS QUANTIDADE, D3_OP,D3_COD "
cQuery += "FROM "+aTabelas[F_SD3]+" SD3 "
cQuery += "WHERE SD3.D3_FILIAL = '"+aFiliais[F_SD3]+"' AND SD3.D3_COD = '"+cProduto+"' "
cQuery += "AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO = ' ' "
cQuery += "AND SD3.D3_OP <> ' ' AND (SD3.D3_CF = 'PR0' OR D3_CF = 'PR1') "
cQuery += "AND SD3.D3_OP IN( "
cQuery += "SELECT D3_OP "
cQuery += "FROM "+aTabelas[F_SD3]+" SD3OP "
cQuery += "WHERE SD3OP.D3_FILIAL = '"+aFiliais[F_SD3]+"' AND SD3OP.D3_COD = '"+cProduto+"' "
cQuery += "AND SD3OP.D_E_L_E_T_ = ' ' AND SD3OP.D3_ESTORNO = ' ' "
cQuery += "AND SD3OP.D3_OP <> ' ' AND SD3OP.D3_CF IN ('PR0','PR1') "
cQuery += "AND SD3OP.D3_EMISSAO BETWEEN '"+cAno+cMes+"01' AND '"+cAno+cMes+"31' "
cQuery += " ) "
cQuery += "GROUP BY D3_OP,D3_COD ORDER BY SD3.D3_COD"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

While !(cAlias)->(Eof())
	cOp := (cAlias)->D3_OP
	cProduto := (cAlias)->D3_COD
	lRecursiv := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona produto pai no array aProc (controle de recursividade na estrutura)				  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Ascan(aProc,{|x| x[1] == cProduto})>0
		lErro := .T.
		cLinha:= STR0006 + aProc[Len(aProc)][2] + STR0007 + aProc[Len(aProc)][1] + STR0008 + cMes + cAno //"Ordem de Producao: - Produto - Periodo:
		If Len(cTexto+cLinha) > 1048576 // 1 GB = 1048576 Kb <string size overflow>
			FCIGravaLog(cTexto,.F.)
			cTexto := STR0005+PULALINHA //"Existem produtos com recursividade na estrutura obtida através da movimentacao. Abaixo serao listadas as ordens de producao cujo calculo da parcela importada foi comprometido por este motivo: "+PULALINHA //"Existem produtos com recursividade na estrutura obtida através da movimentacao. Abaixo serao listadas as ordens de producao cujo calculo da parcela importada foi comprometido por este motivo: "
		EndIf
		cTexto += cLinha+PULALINHA
		lRecursiv := .T.
	Else
		AADD(aProc,{cProduto,cOP})
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obtem o VI atraves da composicao dos VIs dos produtos requisitados para a OP. 			  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRecursiv
		nVi 		:= FciExplReq(cOp,cMes,cAno,cProduto)
	EndIf

	nViTotal 	+= nVi
	nVi    		:= nVi/(cAlias)->QUANTIDADE
	nQuantTot 	+= (cAlias)->QUANTIDADE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o VI no registro de producao da SD3.									 			  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cUpdate := "UPDATE "+ RetSqlName("SD3") +" SET D3_VLRVI = "+ cValToChar(nVi) +" * D3_QUANT "
	cUpdate += "WHERE D3_FILIAL = '"+ aFiliais[F_SD3] + "' "
	cUpdate += "AND D3_OP = '"+ cOP + "' "
	cUpdate += "AND (D3_CF = 'PR0' OR D3_CF = 'PR1') "
	cUpdate += "AND D3_ESTORNO = ' ' "
	cUpdate += "AND D_E_L_E_T_ = ' ' "
	If TCSQLExec(cUpdate) < 0 // Se der erro no update fazemos por reclock
		dbSelectArea('SD3')
		SD3->(DbSetOrder(1))
		If SD3->(MsSeek(aFiliais[F_SD3]+cOp))
			While SD3->D3_FILIAL = aFiliais[F_SD3] .And. SD3->D3_OP = cOP
				If SD3->D3_CF $ 'PR0|PR1' .And. SD3->D3_ESTORNO != "S"
					RecLock('SD3',.F.)
					Replace D3_VLRVI with nVi*D3_QUANT
					SD3->(MsUnlock())
				EndIf
				SD3->(DbSkip())
			End
		EndIf
	Else
		TcRefresh(RetSqlName("SD3"))
	EndIf

	//Verifica se o registro ja foi inserido
	cQuery2 := "SELECT  R_E_C_N_O_ AS RECNOSA8 "
	cQuery2 += "FROM  " + aTabelas[F_SA8] + " SA8 "
	cQuery2 += "WHERE A8_FILIAL = '" + aFiliais[F_SA8] + "'"
	cQuery2 += "AND SA8.A8_COD = '" + cProduto + "'"
	cQuery2 += "AND A8_PERIOD = '" + cMes + cAno + "' "
	cQuery2 += "AND SA8.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),cSA8Alias,.T.,.T.)

	nRecSA8 := (cSA8Alias)->RECNOSA8

	If Select(cSA8Alias) > 0
		(cSA8Alias)->(dbCloseArea())
	EndIf

	(cAlias)->(DbSkip())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ao processar todas as Ops, registra o VI do produto acabado na tabela SA8   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAlias)->(Eof())
	   If Empty(nRecSA8)
			RecLock('SA8',.T.)
			Replace A8_FILIAL 	With aFiliais[F_SA8],;
		    	    A8_COD 		With cProduto,;
		        	A8_PERIOD	With cMes+cAno,;
			        A8_VLRVI 	With nViTotal/nQuantTot,;
			        A8_PROCOM	With "P"
			SA8->(MsUnlock())
		Else
			SA8->(DbGoTo(nRecSA8))
			RecLock('SA8',.F.)
			Replace   A8_VLRVI 	With nViTotal/nQuantTot,;
					  A8_PROCOM	With "P"
			SA8->(MsUnlock())
		EndIf
		nVi      := 0
		nViTotal := 0
		nQuantTot:= 0
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Retira produto pai no array aProc (controle de recursividade na estrutura)				  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRecursiv
		ADel(aProc,len(aProc))
		ASize(aProc,len(aProc)-1)
	EndIf
End

(cAlias)->(DbCloseArea())
RestArea(aAreaSA8)
RestArea(aAreaSD3)
RestArea(aAreaAnt)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FCIGravaLog³ Autor ³Anieli Rodrigues      ³ Data ³10/12/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para gravacao do Log                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FCIXFUN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FCIGravaLog(cTexto, lMostra)
Local cFile := ""

Default lMostra := .T.

cFile := "RECFCI"+StrTran(DtoC(dDataBase),"/","")+"_"+StrTran(Time(),":","")+'.LOG'
lRet  := MemoWrite(cFile, cTexto)
If lMostra
	If lRet
		Aviso(STR0009, cTexto+PULALINHA+STR0010+cFile+STR0011, {'Ok'},3) //Recursividade###Atenção: Este LOG foi salvo automaticamente como ### em seu StartPath.
	Else
		Aviso(STR0009, cTexto+PULALINHA+STR0012+cFile+STR0011, {'Ok'},3) //Recursividade###Não foi possível salvar o arquivo ### em seu StartPath.
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} XFciAtuOrigem

Retorna codigo de origem e codigo da fci conforme produto e periodo
enviados como parametro

@param	cCodProd	->	Codigo do Produto
		dDtEmissao	->	Data de Emissao do movimento

@return Array	->	1 - Codigo da Origem
					2 - Codigo da FCI

@owner	SIGAFIS - Livros Fiscais

@author Telso Carneiro
@since 06/01/2014
@version 11.8

/*/
Function XFciAtuOrigem(aCols,aHeader)
Local nPosCodPro	:= GDFieldPos("C6_PRODUTO")
Local nPosOrigem	:= GDFieldPos("C6_CLASFIS")
Local nPosCodFCI	:= GDFieldPos("C6_FCICOD")
Local nLenAcols	:= 0
Local nI			:= 0
Local aRet		:= {}
Local dDatPesq	:= dDatabase

If MsgYesNo( STR0013 ) //"Serão gatilhados a origem que compõem a Sit.Tribut. eo código da FCI de todos os itens, conforme a DataBase sistema e possua apuração da FCI. Deseja prosseguir?"
	CursorWait()
	nLenAcols := Len(aCols)
	For nI:= 1 To nLenAcols
		If !GdDeleted(nI) .And. !Empty(aCols[nI][nPosCodPro])
			aRet := XFciGetOrigem( aCols[nI][nPosCodPro], dDatPesq )

			If !Empty(aRet[1])
				aCols[nI][nPosOrigem] := aRet[1]+Substr(aCols[nI][nPosOrigem],2)
			EndIf
			If cPaisloc <> "RUS" .AND. nPosCodFCI > 0				//This field is used only in Brazil
				aCols[nI][nPosCodFCI] := Upper(aRet[2])
			EndIf
		EndIf
	Next
	CursorArrow()
EndIf

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} xFCILogName

Retorna o caminho e o nome do arquivo de LOG conforme o JOB
passado como parametro.

** Para utilizacao em execucao MULTITHREAD **

@param cJob -> Nome do job (thread).

@owner	SIGAFIS - Livros Fiscais

@author Joao Pellegrini
@since 14/07/2015
@version 11.0

/*/

//-------------------------------------------------------------------
Function xFCILogName(cJob)

Local nRemType := GetRemoteType()
Local cDirLog := GetSrvProfString("StartPath","")

//Tratamento para Linux onde a barra e invertida
If nRemType == 2 // REMOTE_LINUX
	If (SubStr(cDirLog, Len(cDirLog), 1) <> "/")
		cDirLog += "/"
	EndIf
Else
	If (SubStr(cDirLog, Len(cDirLog), 1) <> "\")
		cDirLog += "\"
	EndIf
EndIf

cDirLog += + "log_fci\"

// Cria o diretorio no qual serao gravados os arquivos de LOG.
If Len(Directory(cDirLog + "*.*", "D")) == 0
	MakeDir(cDirLog)
EndIf

Return cDirLog + cJob + "_" + cEmpAnt + cFilAnt + "_" + DtoS(Date()) + ".txt"

//-------------------------------------------------------------------
/*/{Protheus.doc} xFCIProcLog

Realiza a escrita do conteudo de cText no arquivo de LOG do
multithread (cFile)

** Para utilizacao em execucao MULTITHREAD **

@param cJob -> Nome do job (thread).

@owner	SIGAFIS - Livros Fiscais

@author Joao Pellegrini
@since 14/07/2015
@version 11.0

/*/

//-------------------------------------------------------------------
Function xFCIProcLog(cFile, cText)

Local nHandle := 0

If !File(cFile)
	nHandle := fCreate(cFile)
Else
	nHandle := fOpen(cFile,FO_READWRITE)
	fSeek(nHandle, 0, FS_END)
EndIF

If nHandle <> -1
	fWrite(nHandle, cText + PULALINHA)
	fClose(nHandle)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FCITempTab

Funcao para criacao e abertura de tabela temporaria utilizada na query
de produtos produzidos

@author Alexandre.Gimenez
@since 22/03/2017
@version 11.0

/*/
//-------------------------------------------------------------------

Static Function FCITempTab(cMes,cAno)
Local aTam		 := {}
Local aCampos	 := {}
Local aStruct	 := {}
Local cTempTable := "FCITEMPFAB"
Local cDelete	 := "Delete From FCITEMPFAB"
Local cIndex	 := "FILIAL+COD"
Local cInsert  := ""
Local lRet 	 := .T.

If !MsFile(cTempTable,,"TOPCONN")
	//Definicao de Campos
	aTam := TamSX3("D3_FILIAL"	);	aAdd( aStruct,{"FILIAL"	,aTam[03],aTam[01],aTam[02]} )
	aTam := TamSX3("D3_COD"	);	aAdd( aStruct,{"COD"	,aTam[03],aTam[01],aTam[02]} )
	aTam := TamSX3("D3_EMISSAO"	);	aAdd( aStruct,{"PERIODO"	,aTam[03],aTam[01],aTam[02]} )

	FWDBCreate(cTempTable,aStruct,"TOPCONN", .T. )

	dbUseArea(.T., "TOPCONN", cTempTable , cTempTable, .T., .F.)
	DBCreateIndex(cTempTable+"1",cIndex)
	Set Index To (cTempTable+"1")
	DBClearIndex()
	dbCloseArea()
Else

EndIf

If lFabBefore
	If select(cTempTable) > 0
		(cTempTable)->(DbCloseArea())
	EndIf
	If TCSQLExec(cDelete) < 0 // Se der erro ao limpar tabela
		Aviso("Não foi possível inicar a carga de produtos Fabricados previamente o processo seguirá com a verificação por demanda. Veja ConsoleLog", {'Ok'})
		lFabBefore:= .F.
		FCITempTab(cMes,cAno)
		lRet := .F.
	Else
		TcRefresh(cTempTable)
	EndIf
	If lRet

		//Efetua a carga na tabela
		cInsert := "INSERT INTO "+cTempTable
		cInsert +=	" (FILIAL,COD,PERIODO) "
		cInsert += "SELECT D3_FILIAL,D3_COD, MAX(D3_EMISSAO) "
		cInsert += "FROM "+RetSqlName("SD3")+" SD3 "
		cInsert += "WHERE SD3.D3_FILIAL = '"+aFiliais[F_SD3]+"' "
		cInsert += "AND SD3.D3_EMISSAO <= '"+cAno+cMes+"31' "
		cInsert += "AND (SD3.D3_CF = 'PR0' OR SD3.D3_CF = 'PR1') "
		cInsert += "AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO = ' ' "
		cInsert += "GROUP BY D3_FILIAL,D3_COD"

		If ( TCSqlExec( cInsert ) < 0)
			Aviso("Não foi possível inicar a carga de produtos Fabricados previamente o processo seguirá com a verificação por demanda. Veja ConsoleLog", {'Ok'})
			lFabBefore:= .F.
			FCITempTab(cMes,cAno)
			lRet := .F.
		Else
			TcRefresh(cTempTable)
		EndIf
	EndIf
Else
	//Definicao de Campos
	AADD(aCampos,{"FILIAL","C",TamSx3("D3_FILIAL")[1],0})
	AADD(aCampos,{"COD","C",TamSx3("D3_COD")[1],0})
	AADD(aCampos,{"PERIODO","C",TamSx3("D3_EMISSAO")[1],0})

	cArqFb := CriaTrab(,.F.)
	DbCreate(cArqFb,aCampos,'SQLITE_TMP')
	DbUseArea(.T.,'SQLITE_TMP',cArqFb,cAliasFb,.T.)

	dbSelectArea(cAliasFb)
	IndRegua( cAliasFb, cArqFb+"1",cIndex,,,"Codigo do Produto" )
	dbClearIndex()
	dbSetIndex( cArqFb+"1" + OrdBagExt() )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FCITempFim

Funcao para criacao e abertura de tabela temporaria utilizada na query
de produtos produzidos

@author Alexandre.Gimenez
@since 22/03/2017
@version 11.0

/*/
//-------------------------------------------------------------------
Static Function FCITempFim()

If !lFabBefore
	(cAliasFb)->(DbCloseArea())
	DBSqlExec(cAliasFb, 'DROP TABLE ' + cArqFb , 'SQLITE_TMP')
EndIf

Return

Static Function NewAlias()

Local cAliasN := GetNextAlias()

While select(cAliasN) > 0
	cAliasN := GetNextAlias()
End

Return cAliasN
