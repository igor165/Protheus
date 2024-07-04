#Include 'Protheus.ch'
#INCLUDE "MDTA165a.ch"
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA165A
Classe interna implementando o FWModelEvent
@author Julia Kondlatsch
@since 30/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class MDTA165A FROM FWModelEvent

	Method New() Constructor
	Method ModelPosVld() //Valida��o P�s-Valid do Modelo
	Method InTTS() //Method executado durante o Commit

End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA165A
M�todo construtor da classe
@author Julia Kondlatsch
@since 30/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class MDTA165A
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Valida��o do campo de data de validade inicial do model.
@author Julia Kondlatsch
@since 30/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld( oModel, cModelId ) Class MDTA165A

	Local lRet		:= .T.
	Local oModelTNE := oModel:GetModel( "TNEMASTER" )
	Local nOpc		:= oModel:GetOperation() // Opera��o de a��o sobre o Modelo
	Local aNao		:= { "TI7", "TOQ", "TOR", "TOS", "TOT", "TOU" }
	
	//Vari�veis de valida��o dos relacionamentos do ambiente
	Local cEntAmb	:= SuperGetMv( "MV_NG2EAMB", .F., "1" ) //Indica qual entidade ser� considerada no relacionamento com o ambiente
	Local lTOQ		:= AliasInDic( "TOQ" ) //Ambiente x Centro de Custo
	Local lTOR		:= AliasInDic( "TOR" ) //Ambiente x Departamento
	Local lTOS		:= AliasInDic( "TOS" ) //Ambiente x Fun��o
	Local lTOT		:= AliasInDic( "TOT" ) //Ambiente x Tarefa
	Local lTOU		:= AliasInDic( "TOU" ) //Ambiente x Funcion�rio
	Local nCont		:= 0
	Local aRegsVld	:= {}
	Local aCCSint	:= {}
	Local aCampos	:= {}
	Local aFunEnv	:= {}
	Local cStrAux	:= ""
	Local oModelAux

	Private aCHKSQL := {} // Vari�vel para consist�ncia na exclus�o (via SX9)
	Private aCHKDEL := {} // Vari�vel para consist�ncia na exclus�o (via Cadastro)

	//Recebe SX9
	aCHKSQL := NGRETSX9( "TNE", aNao )

	If nOpc == MODEL_OPERATION_DELETE .And. ( !NGCHKDEL( "TNE" ) .Or. !NGVALSX9( "TNE", aNao, .T., .T. ) )
		lRet := .F.
	EndIf

	//Caso as valida��es anteriores estejam Ok
	If lRet
		//Caso a op��o de relacionamento seja por Centro de Custo
		If cEntAmb == "1" .And. lTOQ

			//Pega o modelo da tabela TOQ
			oModelAux := oModel:GetModel( "TOQDETAIL" )

			//Define as informa��es utilizadas na valida��o
			aCampos := { "TOQ", 2, "TOQ_CC", "TOQ_CODAMB", "CTT", "CTT_DESC01", STR0010, STR0011, STR0013 } //"Os centros de custo abaixo j� est�o vinculados a outros ambientes" ## "Centro de Custo" ## "Favor selecionar outros centros de custo"

			//---------------------------------------------------------------
			// Valida se os centros de custo inputados s�o do tipo Anal�tico
			//---------------------------------------------------------------
			For nCont := 1 To oModelAux:Length()
				oModelAux:GoLine( nCont )
				If !( oModelAux:IsDeleted() )
					If fCCSint( oModelAux:GetValue( "TOQ_CC" ) ) //Verifica se o Centro de Custo inputado � do tipo sint�tico
						aAdd( aCCSint, { oModelAux:GetValue( "TOQ_CC" ) } )
					EndIf
				EndIf
			Next nCont

			If Len( aCCSint ) > 0
				cStrAux := STR0014 + ":" + CRLF //"Os Centros de Custo abaixo s�o do tipo 'Sint�tico', portanto n�o podem ser vinculados"
				For nCont := 1 To Len( aCCSint )
					cStrAux += CRLF + "- " + STR0011 + ": " + AllTrim( Posicione( "CTT", 1, xFilial( "CTT" ) + aCCSint[ nCont, 1 ], "CTT_DESC01" ) )
				Next nCont

				Help( ' ', 1, STR0001, , cStrAux, 2, 0, , , , , , { STR0013 } ) //"Aten��o" ## "Favor selecionar outros centros de custo"
				lRet := .F.
			EndIf

		//Caso a op��o de relacionamento seja por Departamento
		ElseIf cEntAmb == "2" .And. lTOR

			//Pega o modelo da tabela TOR
			oModelAux := oModel:GetModel( "TORDETAIL" )

			//Define as informa��es utilizadas na valida��o
			aCampos := { "TOR", 2, "TOR_DEPTO", "TOR_CODAMB", "SQB", "QB_DESCRIC", STR0015, STR0016, STR0017 } //"Os departamentos abaixo j� est�o vinculados a outros ambientes" ## "Departamento" ## "Favor selecionar outros departamentos"

		//Caso a op��o de relacionamento seja por Fun��o
		ElseIf cEntAmb == "3" .And. lTOS

			//Pega o modelo da tabela TOS
			oModelAux := oModel:GetModel( "TOSDETAIL" )

			//Define as informa��es utilizadas na valida��o
			aCampos := { "TOS", 2, "TOS_FUNCAO", "TOS_CODAMB", "SRJ", "RJ_DESC", STR0018, STR0019, STR0020 } //"As fun��es abaixo j� est�o vinculadas a outros ambientes" ## "Fun��o" ## "Favor selecionar outras fun��es"

		//Caso a op��o de relacionamento seja por Tarefa
		ElseIf cEntAmb == "4" .And. lTOT

			//Pega o modelo da tabela TOT
			oModelAux := oModel:GetModel( "TOTDETAIL" )

			//Define as informa��es utilizadas na valida��o
			aCampos := { "TOT", 2, "TOT_TAREFA", "TOT_CODAMB", "TN5", "TN5_NOMTAR", STR0021, STR0022, STR0023 } //"As tarefas abaixo j� est�o vinculadas a outros ambientes" ## "Tarefa" ## "Favor selecionar outras tarefas"

		//Caso a op��o de relacionamento seja por Funcion�rio
		ElseIf cEntAmb == "5" .And. lTOU

			//Pega o modelo da tabela TOU
			oModelAux := oModel:GetModel( "TOUDETAIL" )

			//Define as informa��es utilizadas na valida��o
			aCampos := { "TOU", 2, "TOU_MAT", "TOU_CODAMB", "SRA", "RA_NOME", STR0024, STR0025, STR0026 } //"Os funcion�rios abaixo j� est�o vinculados a outros ambientes" ## "Funcion�rio" ## "Favor selecionar outros funcion�rios"

		EndIf

		//-------------------------------------------------------------------
		// Valida a exist�ncia de outro relacionamento igual para cada op��o
		//-------------------------------------------------------------------
		If lRet
			For nCont := 1 To oModelAux:Length()
				oModelAux:GoLine( nCont )
				If !( oModelAux:IsDeleted() )
					dbSelectArea( aCampos[ 1 ] )
					dbSetOrder( aCampos[ 2 ] )
					If dbSeek( xFilial( aCampos[ 1 ] ) + oModelAux:GetValue( aCampos[ 3 ] ) )
						If &( aCampos[ 1 ] + "->" + aCampos[ 4 ] ) <> oModelTNE:GetValue( "TNE_CODAMB" )
							aAdd( aRegsVld, { &( aCampos[ 1 ] + "->" + aCampos[ 3 ] ), &( aCampos[ 1 ] + "->" + aCampos[ 4 ] ) } )
						EndIf
					EndIf
				EndIf
			Next nCont

			If Len( aRegsVld ) > 0
				cStrAux := aCampos[ 7 ] + ":" + CRLF
				For nCont := 1 To Len( aRegsVld )
					cStrAux += CRLF + "- " + aCampos[ 8 ] + ": " + AllTrim( Posicione( aCampos[ 5 ], 1, xFilial( aCampos[ 5 ] ) + aRegsVld[ nCont, 1 ], aCampos[ 6 ] ) ) + " / " + STR0012 + ": " + AllTrim( Posicione( "TNE", 1, xFilial( "TNE" ) + aRegsVld[ nCont, 2 ], "TNE_NOME" ) ) //"Ambiente"
				Next nCont

				Help( ' ', 1, STR0001, , cStrAux, 2, 0, , , , , , { aCampos[ 9 ] } ) //"Aten��o"
				lRet := .F.
			EndIf
		EndIf
	EndIf

	//Verifica campos obrigat�rios ao eSocial
	If lRet .And. nOpc != MODEL_OPERATION_DELETE
		lRet := MDTObriEsoc( "TNE", , oModelTNE )
	EndIf

	//---------------------------------------------------------------------------------
	// Caso a entidade de v�nculo com o ambiente seja por funcion�rio, valida o S-2240
	//---------------------------------------------------------------------------------
	If lRet .And. FindFunction( "MDTIntEsoc" ) .And. cEntAmb == "5" .And. lTOU

		//Busca os funcion�rios inclu�dos na grid
		aFunEnv := fGetFunc( oModel )

		//Caso existam funcion�rios a serem enviados
		If Len( aFunEnv ) > 0
			lRet := MDTIntEsoc( "S-2240", nOpc, , aFunEnv, .F. ) //Valida os funcion�rios a serem enviados
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Method para integra��o com TAF durante o Commit

@param	oModel, Objeto, Modelo utilizado
@param	cModelId, Caracter, Id do modelo utilizado

@class	MDTA165A - Classe origem.

@author	Luis Fellipy Bett
@since	10/11/2021
@type	Class
/*/
//-------------------------------------------------------------------------------------------------------------
Method InTTS( oModel, cModelId ) Class MDTA165A

	//Vari�ves de verifica��o
	Local cEntAmb := SuperGetMv( "MV_NG2EAMB", .F., "1" ) //Indica qual entidade ser� considerada no relacionamento com o ambiente
	Local lTOU	  := AliasInDic( "TOU" ) //Ambiente x Funcion�rio
	Local aFunEnv := {}
	
	//Vari�vel do tipo de opera��o
	Local nOpc := oModel:GetOperation()

	//--------------------------------------------------------------------------------
	// Caso a entidade de v�nculo com o ambiente seja por funcion�rio, envia o S-2240
	//--------------------------------------------------------------------------------
	If FindFunction( "MDTIntEsoc" ) .And. cEntAmb == "5" .And. lTOU

		//Busca os funcion�rios inclu�dos na grid
		aFunEnv := fGetFunc( oModel )

		//Caso existam funcion�rios a serem enviados
		If Len( aFunEnv ) > 0
			MDTIntEsoc( "S-2240", nOpc, , aFunEnv ) //Envia os funcion�rios
		EndIf

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCCSint
Verifica se o centro de custo passado por par�metro � do tipo sint�tico

@return	lSint, Boolean, .T. caso o CC seja do tipo sint�tico, sen�o .F.

@sample	fCCSint( "00000123" )

@author	Luis Fellipy Bett
@since	11/06/2021
/*/
//---------------------------------------------------------------------
Static Function fCCSint( cCCusto )

	Local lSint := .F.

	If Posicione( "CTT", 1, xFilial( "CTT" ) + cCCusto, "CTT_CLASSE" ) == "1"
		lSint := .T.
	EndIf

Return lSint

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetFunc
Busca os funcion�rios que foram inclu�dos na grid

@return	aFuncs, Array, Array contendo os funcion�rios inclu�dos

@sample	fGetFunc( oModel )

@param	oModel, Objeto, Objeto do modelo

@author	Luis Fellipy Bett
@since	10/11/2021
/*/
//---------------------------------------------------------------------
Static Function fGetFunc( oModel )

	Local oModelTOU	:= oModel:GetModel( "TOUDETAIL" ) //Pega o modelo da tabela TOU
	Local aFuncs	:= {}
	Local nCont		:= 0

	//Percorre toda a grid verificando os funcion�rio inclu�dos
	For nCont := 1 To oModelTOU:Length()
		
		//Posiciona na linha a ser validada
		oModelTOU:GoLine( nCont )

		//Caso a linha tenha sido inserida e a linha n�o esteja em branco
		If oModelTOU:IsInserted() .And. !Empty( oModelTOU:GetValue( "TOU_MAT" ) )
			aAdd( aFuncs, { oModelTOU:GetValue( "TOU_MAT" ) } ) //Salva a matr�cula do funcion�rio no array
		EndIf

	Next nCont

Return aFuncs
