#INCLUDE "Protheus.ch"
#INCLUDE "totvs.ch"
//#INCLUDE "frameworkng.ch"
#INCLUDE "NGGenerico.ch"

//TODO: NGFWSTRUCT.PRW(410) warning W0012 Function ExUserException is deprecated.
//TODO: Help( " ",1,"NAO CONFORMIDADE",,oTPN:getErrorList()[1],3,1 ) vira oTPN:ShowHelp() ou algo do tipo.

//redefined in frameworkng.ch **************
#DEFINE __VALID_OBRIGAT__  'O'
#DEFINE __VALID_UNIQUE__  'U'
#DEFINE __VALID_FIELDS__   'F'
#DEFINE __VALID_BUSINESS__ 'B'
#DEFINE __VALID_ALL__      'OUFB'
#DEFINE __VALID_NONE__     ''
//******************************************

#DEFINE ARQUIVO_STRUCT 1
#DEFINE   CAMPO_STRUCT 2
#DEFINE    TIPO_STRUCT 3
#DEFINE TAMANHO_STRUCT 4
#DEFINE DECIMAL_STRUCT 5
#DEFINE  TITULO_STRUCT 6
#DEFINE DESCRIC_STRUCT 7
#DEFINE PICTURE_STRUCT 8
#DEFINE CONTEXT_STRUCT 9
#DEFINE OBRIGAT_STRUCT 10
#DEFINE   VALID_STRUCT 11
#DEFINE VLDUSER_STRUCT 12
#DEFINE    CBOX_STRUCT 13

#DEFINE  TITULO_HEADER 1
#DEFINE   CAMPO_HEADER 2
#DEFINE PICTURE_HEADER 3
#DEFINE TAMANHO_HEADER 4
#DEFINE DECIMAL_HEADER 5
#DEFINE   VALID_HEADER 6
#DEFINE   USADO_HEADER 7
#DEFINE    TIPO_HEADER 8
#DEFINE      F3_HEADER 9
#DEFINE CONTEXT_HEADER 10
#DEFINE    CBOX_HEADER 11
#DEFINE RELACAO_HEADER 12
#DEFINE    WHEN_HEADER 13

#DEFINE TABLE_MEMORY 1
#DEFINE FIELD_MEMORY 2
#DEFINE VALUE_MEMORY 3
#DEFINE TOTAL_MEMORY 3

#DEFINE INTEG_MVNGINTMU 1
#DEFINE INTEG_MVPIMSINT 2
//------------------------------
// For�a a publica��o do fonte
//------------------------------
Function _NGGenerico()
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} NGGenerico
Esta classe tem por objetivo centralizar m�todos e atributos de forma a
permitir a cria��o e utiliza��o de classes espec�ficas, com forte regra
de neg�cio.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@protected
@since 11/06/2012
@version P12
/*/
//---------------------------------------------------------------------
CLASS NGGenerico

	Method New() CONSTRUCTOR

	//--------------------------------------------------------------------------
	// Publico: Defini��es da classe
	//--------------------------------------------------------------------------
	Method SetOperation()
	Method SetValue()
	Method AbleInteg()

	//--------------------------------------------------------------------------
	// Publico: Retornos da classe
	//--------------------------------------------------------------------------
	Method GetOperation()
	Method GetValue()
	Method GetRecNo()

	//--------------------------------------------------------------------------
	// Publico: Opera��es com o objeto
	//--------------------------------------------------------------------------
	Method Upsert()
	Method Delete()
	Method Load()
	Method Valid()
	Method Free()

	//--------------------------------------------------------------------------
	// Publico: Erros
	//--------------------------------------------------------------------------
	Method IsValid()
	Method SetValid()
	Method AddError()
	Method AddAsk()
	Method addInfo()
	Method GetErrorList()
	Method GetAskList()
	Method getInfoList()
	Method ShowHelp()
	Method MsgRequired()
	Method clearErrorList()

	Method GetParent()

	//--------------------------------------------------------------------------
	// P�blico: Exibi��o de mensagens de confirma��o
	//--------------------------------------------------------------------------
	Method setAsk()
	Method getAsk()


	Method setInfo()
	Method getInfo()

	//METODOS PRIVADOS
	Method SetAlias()
	Method InitFields()
	Method SetUniqueField()
	Method SetNoDelete()
	Method MemoryToClass()
	Method ModelToClass()
	Method SubModel()
	Method SetOptional()
	Method IsOptional()
	Method IsFilled()
	Method RemoveField()

	Method ClassToMemory()
	Method GetUnique()

	Method SetParam()
	Method GetParam()
	Method SetRelMemos()

	//--------------------------------------------------------------------------
	// Privado: Valida��es
	//--------------------------------------------------------------------------
	Method ValidFields()
	Method ValidUnique()
	Method ValidObrigat()
	Method ValidBusiness()
	Method SetValidationType()

	//--------------------------------------------------------------------------
	// Privado: Grid
	//--------------------------------------------------------------------------
	Method SetAliasGrid()
	Method GridToClass()
	Method GetHeader()
	Method GetRelation()
	Method SetRelation()
	Method GetCols()
	Method SetCols()
	Method EmptyLine()
	Method CommitGrid()

	//--------------------------------------------------------------------------
	// Privado: Opera��es
	//--------------------------------------------------------------------------
	Method IsInsert()
	Method IsUpdate()
	Method IsDelete()
	Method IsUpsert()

	//--------------------------------------------------------------------------
	// Privado: Atributos gerais
	//--------------------------------------------------------------------------
	Data cProduct	As String
	Data cBranch	As String
	Data cClassName As String
	Data oError		As Object
	Data oStruct	As Object
	Data oParent	As Object
	Data nOperation As Integer
	Data lIsValid	As Boolean
	Data cValidType As String
	Data aInteg		As Array
	Data lAsk		As Bool		INIT .T.
	Data lInfo      As Bool		INIT .F.

EndClass

//---------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo inicializador da classe NGGenerico.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@protected
@since 22/06/2012
@version P12
@return Nil Sem retorno.
/*/
//---------------------------------------------------------------------
METHOD New() CLASS NGGenerico

	::cProduct := ''
	::cBranch  := '01'
	::cClassName := ''
	::oStruct  := NGFWStruct():New()
	::oError   := NGFWError():New()
	::lIsValid   := .F.
	::lAsk       := .F.
	::lInfo      := .F.
	::setValidationType(__VALID_ALL__)

	//---------------------
	//integracoes
	//---------------------
	::aInteg := {}

	aAdd( ::aInteg,{ INTEG_MVNGINTMU, .T. } )
	aAdd( ::aInteg,{ INTEG_MVPIMSINT, .F. } )

	If SuperGetMV( "MV_PIMSINT",.F.,.F. ) .And. FindFunction( "NGIntPIMS" )
		nPos := asCan(::aInteg, {|x| x[1] == INTEG_MVPIMSINT})
		::aInteg[nPos][2] := .T.
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} upsert
M�todo para inclus�o e altera��o dos alias definidos para a classe.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@see delete, load
@return lUpsert Confirma��o da opera��o.
@sample If oObj:valid()
oObj:upsert()
Else
Help(,,'HELP',, oTPN:getErrorList()[1],1,0)
EndIf
/*/
//---------------------------------------------------------------------
Method Upsert() Class NGGenerico

	Local nAlias    := 0
	Local nMemory   := 0
	Local nInd      := 0
	Local nTot      := 0
	Local cKey      := ""
	Local cTable    := ""
	Local cFieldCod := ""
	Local cFieldDes := ""
	Local cValueCod := ""
	Local cValueDes := ""
	Local lInsert   := .F.
	Local aAlias    := ::oStruct:GetAlias()
	Local aMemory   := ::oStruct:GetMemory()
	Local aStruct   := ::oStruct:GetStruct()

	If !::IsValid()
		::addError(STR0001) //'Objeto n�o est� validado!'
	EndIf

	//------------------------------------------------------
	// Executa inclusao para todas as Alias pre-definidas
	//------------------------------------------------------
	For nAlias := 1 To Len(aAlias)

		// Verifica se as tabelas opicionais n�o foram preenchidas
		If ::IsOptional( aAlias[nAlias] ) .And. !::IsFilled( aAlias[nAlias] )
			Loop
		EndIf

		If !::IsValid()
			Exit
		EndIf

		cKey := fGetPK(aAlias[nAlias],Self)

		//verifica se o registro ja existe (update) ou nao (insert)
		dbSelectArea(aAlias[nAlias])
		dbSetOrder(01)
		lInsert := !dbSeek(cKey)

		//------------------------------------------------------
		RecLock(aAlias[nAlias],lInsert)
		//------------------------------------------------------
		// Grava na tabela todos os campos carregados na memoria
		//------------------------------------------------------
		For nMemory := aScan(aMemory,{|a| a[TABLE_MEMORY] == aAlias[nAlias]}) to Len(aMemory)

			//--------------------------------------------------
			// Garante que ira gravar campo da respectiva Alias
			//--------------------------------------------------
			If aMemory[nMemory][TABLE_MEMORY] <> aAlias[nAlias]
				Exit
			EndIf

			//------------------------------------------------------------
			// Garante que campo da memoria existe da estrutura da tabela
			//------------------------------------------------------------
			nStruct := aScan(aStruct,{|a| a[CAMPO_STRUCT] == aMemory[nMemory][FIELD_MEMORY]})

			//-------------------------------------------
			// Grava campos que existam no banco (Reais)
			//-------------------------------------------
			If !Empty(nStruct) .And. aStruct[nStruct][CONTEXT_STRUCT] <> "V"
				cField  := aMemory[nMemory][TABLE_MEMORY] + "->" + aMemory[nMemory][FIELD_MEMORY]
				//N�o deve preencher campos de log de inclus�o e altera��o
				//Estes campos s�o preenchidos automaticamente pelo framework da TOTVS
				If !('_USERLGI' $ cField .Or. '_USERLGA' $ cField .Or. ;
					'_USERGI'   $ cField .Or. '_USERGA'  $ cField .Or. ;
					fFieldMemo(aMemory[nMemory, FIELD_MEMORY], Self) )
					// Verifica se o campo faz parte de algum relacionamento de campo memo.

					&(cField) := aMemory[nMemory][VALUE_MEMORY]
				Endif
			EndIf

		Next nMemory

		MsUnLock()

		// Valida��o dos campos memos que s�o relacionados com C�digo e Descri��o
		nTot := Len(::oStruct:aRelMemos)
		For nInd := 1 To nTot

			cTable    := aAlias[nAlias]
			cFieldCod := ::oStruct:aRelMemos[nInd, 1] // Campo que representa o c�digo na tabela SYP
			cFieldDes := ::oStruct:aRelMemos[nInd, 2] // Campo memo que representa a descri��o
			cValueCod := ::oStruct:aRelMemos[nInd, 3] // C�digo que est� gravado no campo C�digo tanto da SYP quanto cTable

			If FWTabPref(cFieldCod) == cTable .And. FWTabPref(cFieldDes) == cTable // Garante que os campos s�o da mesma tabela

				cValueDes := ::GetValue(cFieldDes)                                      // Busca o texto que est� no camp memo
				nMemory   := aScan(aMemory,{|a| a[FIELD_MEMORY] == AllTrim(cFieldCod)}) // Verifica a posi��o do campo de descri��o
				If nMemory > 0 .And. Empty(cValueCod)                                   // Caso encontou o campo e a decri��o esteja vazia.

					MSMM(,,,cValueDes,1,,,cTable,cFieldCod) // Grava o c�digo e descri��o na SYP

				ElseIf nMemory > 0
					// Caso o campo de c�digo n�o esteja vazio, passa o c�digo e altera a decri��o para o valor atual
					MsMM(cValueCod,80,,cValueDes,1,,,cTable,cFieldCod)
				EndIf				

			EndIf

		Next nInd	

		::oStruct:setRecNo()

	Next nAlias

	If ::IsValid()
		::CommitGrid()
	EndIf

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} delete
M�todo para exclus�o dos alias definidos para a classe.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@see upsert, load
@return lDeleted Confirma��o da opera��o.
@sample If oObj:valid()
oObj:delete()
Else
Help(,,'HELP',, oTPN:getErrorList()[1],1,0)
EndIf
/*/
//------------------------------------------------------------------------------
METHOD delete() CLASS NGGenerico

	Local nAlias
	Local lOk        := .T.
	Local aAreaSX9	 := SX9->( GetArea() )
	Local aAlias	 := ::oStruct:GetAlias()
	Local aNoDelete	 := ::oStruct:GetNoDelete()

	Local nFields, nCaracter, cCampo, aCampos, cQryAlias, cQuery,;
	cX9_EXPDOM, cX9_EXPCDOM, cX9_CONDSQL, cBDDOM, x, cAPDOM

	If !::isValid()
		::addError(STR0001) //'Objeto n�o est� validado!'
		lOk := .F.
	EndIf

	//--------------------------------------------------------------------------
	// Exclui os registros relacionados a Alias pre-definida
	//--------------------------------------------------------------------------
	For nAlias := 1 To Len(aAlias)

		cAlias := aAlias[nAlias]

		If !lOk
			Exit
		EndIf

		dbSelectArea( 'SX9' )
		dbSetOrder(1)
		dbSeek( cAlias )
		While SX9->( !Eof() ) .And. SX9->X9_DOM == cAlias

			// Filtra tabelas a serem pesquisadas
			If Len( aNoDelete ) > 0 .And. aScan( aNoDelete , {|x| Upper(AllTrim(x)) == SX9->X9_CDOM} ) <> 0
				SX9->( dbSkip() )
				Loop
			EndIf

			// Impede de excluir registros de tabelas pr�-definidas e relacionadas
			If Len( aAlias ) > 1 .And. aScan( aAlias , {|x| Upper(AllTrim(x)) == SX9->X9_CDOM} ) <> 0
				SX9->( dbSkip() )
				Loop
			EndIf

			// Dominio n�o pode ser igual o contra-dominio
			If SX9->X9_CDOM == SX9->X9_DOM
				SX9->( dbSkip() )
				Loop
			Endif

			//Iniciliza variaveis para o relacionamento
			cX9_EXPDOM		:= AllTrim( SX9->X9_EXPDOM )
			cX9_EXPCDOM	:= AllTrim( SX9->X9_EXPCDOM )
			cX9_CONDSQL	:= AllTrim( StrTran( SX9->X9_CONDSQL , "#" , "" ) )
			aCampos		:= {}
			cCampo			:= ""
			lOk				:= .T.

			//Separa os campos para fazer checagem se existem no banco antes de validar
			For nCaracter := 1 To Len( cX9_EXPCDOM )
				If Substr( cX9_EXPCDOM , nCaracter , 1 ) == "+"
					aAdd( aCampos,{ cCampo } )
					cCampo := ""
				ElseIf Substr( cX9_EXPCDOM , nCaracter , 2 ) == "||"
					aAdd( aCampos,{ cCampo } )
					cCampo := ""
					nCaracter++
				Else
					cCampo += Substr( cX9_EXPCDOM , nCaracter , 1 )
				Endif
			Next nCaracter

			If !Empty( cCampo )
				aAdd( aCampos , { cCampo } )
			Endif

			//Checa se os campos existem na base
			For nFields:= 1 To Len( aCampos )
				If !NGCADICBASE(aCampos[nFields][1],"A",SX9->X9_CDOM,.F.)
					lOk := .F.
					Exit
				Endif
			Next nFields

			// Caso n�o exista o campo, pula o proximo SX9
			If !lOk
				SX9->( dbSkip() )
				Loop
			EndIf

			//Adiciona Alias da Query para o dominio
			cBDDOM := StrTran( cX9_EXPDOM , "||", "+" )
			x := AT("+",cBDDOM)
			While x > 0
				cBDDOM := Substr(cBDDOM,1,x) + SX9->X9_DOM + "." + Substr(cBDDOM,x+1)
				If AT("+",Substr(cBDDOM,x+1)) == 0
					Exit
				Endif
				x += AT("+",Substr(cBDDOM,x+1))
			End
			cBDDOM := StrTran( cBDDOM , "+", "||" )

			//Adiciona Alias da Query para o contra-dominio
			cBDCDOM := StrTran( cX9_EXPCDOM , "||", "+" )
			x := AT("+",cBDCDOM)
			While x > 0
				cBDCDOM := Substr(cBDCDOM,1,x) + SX9->X9_CDOM + "." + Substr(cBDCDOM,x+1)
				If AT("+",Substr(cBDCDOM,x+1)) == 0
					Exit
				Endif
				x += AT("+",Substr(cBDCDOM,x+1))
			End
			cBDCDOM := StrTran( cBDCDOM , "+", "||" )

			aCampos := StrTokArr(StrTran( cX9_EXPDOM , "||", "+" ),"+")

			//------------------------------------------------------------
			// Analisa campos do formato Data para preencher com o DTOS()
			//------------------------------------------------------------
			cAPDOM := ""
			For nFields := 1 to Len(aCampos)
				If TAMSX3(aCampos[nFields])[3] == "D"
					cAPDOM += "DTOS(" + aCampos[nFields] + ")"
				Else
					cAPDOM += aCampos[nFields]
				Endif
				If Len(aCampos) > nFields
					cAPDOM += "+"
				EndIf
			Next nFields

			cAPDOM := SX9->X9_DOM + "->(" + Alltrim(cAPDOM) + ")"

			cQryAlias := GetNextAlias()
			cQuery := "SELECT " + SX9->X9_CDOM	+ ".R_E_C_N_O_ "
			cQuery += " FROM " + RetSqlName( SX9->X9_CDOM	) + " " + SX9->X9_CDOM
			cQuery += " JOIN " + RetSqlName( SX9->X9_DOM	) + " " + SX9->X9_DOM
			cQuery += " ON " + SX9->X9_DOM + "." + cBDDOM + " = '" + &( cAPDOM ) + "'"
			cQuery += " WHERE "
			cQuery += " " + SX9->X9_CDOM	+ ".D_E_L_E_T_ <> '*' AND "
			cQuery += " " + SX9->X9_DOM	+ ".D_E_L_E_T_ <> '*' AND "
			cQuery += SX9->X9_CDOM + "." + cBDCDOM + " = '" + &(cAPDOM) + "'"

			//Considera filial na pesquisa de relacionamentos
			If SX9->X9_USEFIL == 'S' .And. !Empty( xFilial( SX9->X9_DOM ) )
				cQuery += "AND "+SX9->X9_DOM+"." + PrefixoCpo( SX9->X9_DOM ) + "_FILIAL = '"+ xFilial( SX9->X9_DOM ) +"' "
				cQuery += "AND "+SX9->X9_CDOM+"." + PrefixoCpo(SX9->X9_CDOM) + "_FILIAL = '"+ xFilial( SX9->X9_CDOM )+"' "
			EndIf

			// Filtro de relacionamento pelo SX9
			If !Empty( AllTrim( StrTran( SX9->X9_CONDSQL , "#" , "" ) ) )
				cQuery += "AND (" + cX9_CONDSQL + ")"
			EndIf

			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cQryAlias, .F., .T.)

			( cQryAlias )->( dbGoTop() )
			While !Eof()

				If ( cQryAlias )->R_E_C_N_O_  == 0
					Exit
				Else
					DbSelectArea( SX9->X9_CDOM )
					DbGoTo( ( cQryAlias )->R_E_C_N_O_ )
					If ( SX9->X9_CDOM )->( Recno() ) > 0
						RecLock( SX9->X9_CDOM , .F. )
						dbDelete()
						MsUnLock(SX9->X9_CDOM)
					EndIf
				EndIf
				( cQryAlias )->( dbSkip() )
			End
			(cQryAlias)->(dbCloseArea())

			// Proximo relacionamento
			SX9->( dbSkip() )
		End
	Next nAlias

	//--------------------------------------------------------------------------
	// Exclui todas as tabelas pre-definidas
	//--------------------------------------------------------------------------
	For nAlias := 1 To Len(aAlias)

		cAlias := aAlias[nAlias]

		If !lOk
			Exit
		EndIf

		// Filtra tabelas a serem excluidas
		If Len( aNoDelete ) > 0 .And. aScan( aNoDelete , {|x| Upper(AllTrim(x)) == cAlias} ) <> 0
			Loop
		EndIf

		//----------------------------------------------------------------------
		// Exclui tabela pr�-definida
		//----------------------------------------------------------------------
		DbSelectArea( cAlias )
		DbGoTo( ::GetRecno( cAlias ) )
		If .Not. ( cAlias )->( Eof() )
			RecLock(cAlias,.F.)
			DBDelete()
			MsUnLock(cAlias)
		EndIf
	Next

	RestArea( aAreaSX9 )

Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} Load
M�todo para carregar registros da base para os alias definidos.

@param aKey Array que cont�m a chave para carregar o registro de um alias
determinado conforme os Alias do objeto.
@author Felipe Nathan Welter
@since 18/02/2013
@version P12
@see upsert, delete
@return lLoaded Confirma��o do carregamento.
@sample oObj:Load( { xFilial("TBL") + cCod } }
/*/
//---------------------------------------------------------------------
METHOD Load(aKey) CLASS NGGenerico
	Local nAlias, lRet := .T.
	Local aAlias := ::oStruct:GetAlias()

	For nAlias := 1 To Len(aAlias)

		If ::IsOptional( aAlias[nAlias] ) .And. Empty( aKey[nAlias] )
			PutFileInEof(aAlias[nAlias])
			Loop
		EndIf

		dbSelectArea(aAlias[nAlias])
		dbSetOrder(01)
		If !dbSeek(aKey[nAlias])
			lRet := .F.
			::addError( STR0005 + Space(1) + aAlias[nAlias]+'->('+aKey[nAlias]+')') //'Problema ao carregar registro'
		EndIf
	Next nAlias

	If lRet
		::InitFields(.F.)
	EndIf

Return lRet

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} setOperation
Prepara a classe para trabalhar em determinada opera��o.
@type method

@author Felipe Nathan Welter
@since 18/02/2013

@sample oObj:setOperation( 3 )

@param  nOp         , N�merico, Opera��o sendo (3-insert/4-update/5-delete).
@param  [lIniFields], L�gico  , Define se deve inicializar os campos conforme o dicion�rio.
@return Nil
/*/
//-----------------------------------------------------------------------------------------------
METHOD setOperation( nOp, lIniFields ) CLASS NGGenerico

	Default lIniFields := .T.

	::nOperation := nOp

	If lIniFields
		::InitFields( ::nOperation == 3 )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} getOperation
Retorna a opera��o para qual o objeto est� sendo usado.

@author Felipe Nathan Welter
@since 18/02/2013
@version P12
@see setOperation
@return nInteger Opera��o da classe (3(insert)/4(update)=upsert; 5=delete).
/*/
//---------------------------------------------------------------------
METHOD getOperation() CLASS NGGenerico
Return ::nOperation

//---------------------------------------------------------------------
/*/{Protheus.doc} initFields
M�todo que carrega os campos da estrutura.

@param lInclui Indica se prepara os campos para inclusao (.T.) ou para
altera��o (.F.).
@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@protected
@since 22/06/2012
@version P12
@return Nil Sem retorno.
/*/
//---------------------------------------------------------------------
METHOD initFields(lInclui) CLASS NGGenerico
Return ::oStruct:initFields(lInclui)

//---------------------------------------------------------------------
/*/{Protheus.doc} memoryToClass
M�todo para carregar conte�do da mem�ria de trabalho para a estrutura
da classe.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@protected
@since 22/06/2012
@version P12
@see classToMemory
@return Nil Sem retorno.
/*/
//---------------------------------------------------------------------
Method memoryToClass() Class NGGenerico
Return ::oStruct:MemoryToClass()

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelToClass
Metodo para carregar conteudo de todo model para a estrutura da classe.
@type method

@author NG Inform�tica Ltda.
@since 10/11/2014

@sample mntBem:ModelToClass( oModel )

@param  oModel, Objecto, Modelo que ser� carregado na classe.
@return Nil
/*/
//---------------------------------------------------------------------
Method ModelToClass( oModel ) Class NGGenerico

	Local nModel    := 0
	Local cModelId  := ''
	Local oAuxModel := Nil
	Local aAuxModel := {}

	::SetOperation( oModel:GetOperation(), .F. )

	For nModel := 1 to Len(oModel:aDependency)

		cModelId 	:= oModel:aDependency[nModel][1]

		If ValType( cModelId ) <> 'C'
			Loop
		EndIf

		oAuxModel	:= oModel:GetModel( cModelId )
		aAuxModel	:= ClassDataArr( oAuxModel )

		If aScan( aAuxModel , { |x| Trim(Upper(x[1])) == 'ACOLS' }) > 0
			::GridToClass( oAuxModel )
		Else
			::SubModel( oAuxModel )
		EndIf
	Next

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} SubModel
M�todo para carregar conte�do do sub model para a estrutura nda classe.

@author NG Inform�tica Ltda.
@protected
@since 22/06/2012
@version P12
@see modelToMemory
@return Nil Sem retorno.
/*/
//---------------------------------------------------------------------
Method SubModel( oAuxModel ) Class NGGenerico
Return ::oStruct:SubModel( oAuxModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} gridToClass
M�todo para carregar conte�do da grid para a estrutura nda classe.

@author NG Inform�tica Ltda.
@protected
@since 22/06/2012
@version P12
@see gridToMemory
@return Nil Sem retorno.
/*/
//---------------------------------------------------------------------
Method gridToClass( oAuxModel ) Class NGGenerico
Return ::oStruct:gridToClass( oAuxModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} classToMemory
Carrega as informa��es da estrutura para a mem�ria de trabalho.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@protected
@since 13/02/2013
@version P12
@see memoryToClass
@return Nil Sem retorno.
/*/
//---------------------------------------------------------------------
Method classToMemory() Class NGGenerico
Return ::oStruct:ClassToMemory()

//---------------------------------------------------------------------
/*/{Protheus.doc} getValue
Retorna o conte�do de um campo da estrutura de dados.

@param cField campo da estrutura de dados
@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@return xValue Conte�do do campo.
@sample cValue := oObj:getValue("CAMPO")
/*/
//---------------------------------------------------------------------
Method getValue(cField) Class NGGenerico
Return ::oStruct:GetValue(cField)

//---------------------------------------------------------------------
/*/{Protheus.doc} getErrorList
Retorna lista com erros gerados durante opera��es com a classe.

@author Felipe Nathan Welter
@since 14/02/2012
@version P12
@return aArray Lista de erros.
@sample aList := oObj:getErrorList()
If !Empty(aList)
MsgInfo(aList[1])
EndIf
/*/
//---------------------------------------------------------------------
Method getErrorList() Class NGGenerico
Return ::oError:getErrorList()

//---------------------------------------------------------------------
/*/{Protheus.doc} getInfoList
Retorna lista com mensagens informativas geradas durante opera��es com a classe.

@author Maicon Andr� Pinheiro
@since  11/06/2018
@return Self:oError:getInfoList(), array, aArray Lista de mensagens informativas
/*/
//---------------------------------------------------------------------
Method getInfoList() Class NGGenerico
Return ::oError:getInfoList()

//---------------------------------------------------------------------
/*/{Protheus.doc} getAskList
Retorna lista com mensagens yes/no geradas durante opera��es com a classe.

@author Felipe Nathan Welter
@since 26/09/2017
@version P12
@return aArray Lista de mensagens yes/no
@sample aList := oObj:getAskList()
If !Empty(aList)
lRet := MsgYesNo(aList[1])
EndIf
/*/
//---------------------------------------------------------------------
Method getAskList() Class NGGenerico
Return ::oError:getAskList()

//---------------------------------------------------------------------
/*/{Protheus.doc} getRecNo
Retorna o RecNo() de um alias especificado.

@param cAlias [opcional, default=Alias()] Alias especificado para retornar o RecNo().
@author Felipe Nathan Welter
@since 19/02/2013
@version P12
@return nRecNo N�mero do registro.
@sample nRecNo := oObj:getRecNo()
/*/
//---------------------------------------------------------------------
Method getRecNo(cAlias) Class NGGenerico
Return ::oStruct:getRecNo(cAlias)

//---------------------------------------------------------------------
/*/{Protheus.doc} valid
M�todo que realiza a valida��o completa da classe (obrigat�rio, campos
e regra de neg�cio).

@author Felipe Nathan Welter
@since 14/02/2012
@version P12
@return lBool Retorno da valida��o.
@see isValid
@sample lValid := oObj:valid()
/*/
//---------------------------------------------------------------------
METHOD valid() CLASS NGGenerico

	Local nField, nMemory
	Local lOk        := .T.
	Local cError     := ''
	Local aMemory    := ::oStruct:GetMemory()
	Local aStruct    := ::oStruct:GetStruct()
	Local aAlias	 := ::oStruct:GetAlias()
	Local aAliasGrid := ::oStruct:GetAliasGrid()
	Local aNoDelete	 := ::oStruct:GetNoDelete()
	Local aAreaSX9	 := SX9->( GetArea() )
	Local nInd       := 0
	Local nTotArr    := 0
	Local aNoValid   := {}
	Local cAliasIntR := ""
	Local nPos       := 0
	Local cTableErro := ""

	//limpa lista de erros
	::oError:clearList()

	If ::getOperation() == Nil
		::addError(STR0006) //'Opera��o n�o definida para o objeto.'

	Else
		::ClassToMemory()

		//Inicia Realiza valida��es de Integridade referencial //
		//L�gica retirada do Delete pois a mesma faz valida��es//
		//e caso retorne false n�o deve continuar para as alte-//
		//ra��es de base.                                      //

		//Define exce��es para valida��o de integridade de relacionamento
		If ::IsDelete()

			aNoValid := aClone(aNoDelete)
			nTotArr  := Len(aAliasGrid)
			For nInd := 1 To nTotArr
				aAdd(aNoValid,aAliasGrid[nInd])
			Next

			//Verifica integridade relacional
			nTotArr := Len(aAlias)
			For nInd := 1 To nTotArr

				//aNoDelete s� verifica um lado do Delete por isso foi validado o outro lado.
				If aScan(aNoDelete,aAlias[nInd]) > 0
					Loop
				EndIf

				cAliasIntR := aAlias[nInd]

				dbSelectArea(cAliasIntR)
				dbGoTo(::GetRecno(cAliasIntR))
				lOk := NGVALSX9(cAliasIntR,aNoValid,.T.,,.T.,@cTableErro)

				If !lOk
					cError := STR0002 + Space(1) //'Integridade referencial para alias'
					cError += aAlias[nInd] + Space(1)
					cError += STR0003 //'n�o permite exclus�o.'
					cError += STR0004 //'Foram localizados registros relacionados ao registro que se est� tentando excluir.'
					If !Empty(cTableErro)
						cError += Chr(10) + Chr(13) + STR0015 + cTableErro //"Registro(s) em: "
					EndIf
					::addError(cError)
					Exit
				EndIf
			Next nInd
		EndIf

		For nField := 1 To Len(aStruct)

			If aStruct[nField][TIPO_STRUCT] != "C"
				Loop
			EndIf

			cFieldName := aStruct[nField][CAMPO_STRUCT]
			nMemory := aScan(aMemory,{|a| a[FIELD_MEMORY] == cFieldName })

			If .Not. Empty( nMemory ) .And. "'" $ aMemory[nMemory][VALUE_MEMORY]
				lOk := .F.
				cError := STR0007 + Space(1) //'O caracter'
				cError += " ' " + Space(1)
				cError += STR0008 + Space(1) //'n�o pode ser informado no campo '
				cError += cFieldName
				::AddError(cError)
			EndIf
		Next

		If __VALID_OBRIGAT__ $ ::cValidType
			lOk := If(lOk,::validObrigat(),.F.)
		EndIf

		If __VALID_UNIQUE__ $ ::cValidType
			If ::getOperation() == 4
				lOk := If(lOk,::validUnique(),.F.)
			EndIf
		EndIf

		If __VALID_FIELDS__ $ ::cValidType
			lOk := If(lOk,::validFields(),.F.)
		EndIf

		If __VALID_BUSINESS__ $ ::cValidType
			::SetValid( .T. )
			lOk := If(lOk,::validBusiness(::nOperation),.F.)
		EndIf

		::lIsValid := lOk
	EndIf

	RestArea(aAreaSX9)

Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} isValid
Verifica se a classe est� validada para a opera��o em quest�o.

@author Felipe Nathan Welter
@since 14/02/2012
@version P12
@return lBool Identifica se a classe est� validada.
@sample lIsValid := oObj:isValid()
/*/
//---------------------------------------------------------------------
METHOD isValid() CLASS NGGenerico
Return ::lIsValid

//---------------------------------------------------------------------
/*/{Protheus.doc} SetValid
Verifica se a classe est� validada para a opera��o em quest�o.

@author NG Inform�tica Ltda.
@since 01/01/2015
@sample  Obj:SetValid( .F. )
/*/
//---------------------------------------------------------------------
METHOD SetValid( lValid ) CLASS NGGenerico
	::lIsValid := lValid
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} addError
M�todo que adiciona um erro no objeto de erro da classe.

@param cError Descri��o do erro.
@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@return aArray Array com os erros.
@sample oObj:addErro("Erro 041.")
/*/
//---------------------------------------------------------------------
METHOD addError(cError) CLASS NGGenerico
	::SetValid( .F. )
Return ::oError:addError(cError)


//---------------------------------------------------------------------
/*/{Protheus.doc} addInfo
M�todo que adiciona uma mensagem informativa no objeto de erro da classe.

@param  cInfo, caracter, Descri��o da mensagem informativa.
@author Maicon Andr� Pinheiro
@since  11/06/2018
@obs    Conceitualmente o ideal � chamar essa fun��o apenas a partir do Delete ou Upsert.
@sample oObj:addInfo("Criado O.S. para o bem 001")
/*/
//---------------------------------------------------------------------
METHOD addInfo(cInfo) CLASS NGGenerico
Return ::oError:addInfo(cInfo)

//---------------------------------------------------------------------
/*/{Protheus.doc} addAsk
M�todo que adiciona uma mensagem yes/no no objeto de erro da classe.

@param cAsk Descri��o da mensagem yes/no.
@author Felipe Nathan Welter
@since 26/09/2017
@version P12
@return aArray Array com mensagens yes/no.
@obs � importante considerar que a mensagem de pergunta seja sempre
     no sentido de confirmar a opera��o, ex: deseja prosseguir? confirma?
@sample oObj:addAsk("Deseja continuar?")
/*/
//---------------------------------------------------------------------
METHOD addAsk(cAsk) CLASS NGGenerico
Return ::oError:addAsk(cAsk)

//---------------------------------------------------------------------
/*/{Protheus.doc} validFields
M�todo que realiza a valida��o dos campos em mem�ria conforme as
valida��es do dicion�rio.

@author Felipe Nathan Welter
@protected
@since 14/02/2012
@version P12
@return lOk Valida��o ok.
/*/
//---------------------------------------------------------------------
METHOD validFields() CLASS NGGenerico

	Local nX, lOk := .T.
	Local cError := ''
	Local aStruct := ::oStruct:getStruct()

	For nX := 1 To Len(aStruct)

		If !lOk
			Exit
		EndIf

		cValidS := aStruct[nX][VALID_STRUCT]
		cValidU := aStruct[nX][VLDUSER_STRUCT]

		If !Empty(cValidS) .And. !(&(cValidS))
			cError := STR0009 //'Problema na valida��o (X3_VALID) do campo'
			cError += Space(1) + aStruct[nX][CAMPO_STRUCT]
			::addError( cError )
			lOk := .F.
		Else
			If !Empty(cValidU) .And. !(&(cValidU))
				cError := STR0010 //'Problema na valida��o (X3_VLDUSER) do campo'
				cError += Space(1) + aStruct[nX][CAMPO_STRUCT]
				::addError( cError )
				lOk := .F.
			EndIf
		EndIf

	Next nX

Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} validUnique
M�todo que realiza a valida��o de alteracao da chave �nica.

@author Felipe Nathan Welter
@protected
@since	 24/04/2013
@version P12
@return  lOk, L�gico, Valida��o ok.
/*/
//---------------------------------------------------------------------
METHOD validUnique() CLASS NGGenerico

	Local lOk         := .T.
	Local aArea       := GetArea()
	Local aAlias      := ::oStruct:GetAlias()
	Local aAliasGrid  := ::oStruct:GetAliasGrid()
	Local aHeaderAux  := {}
	Local aColsAux    := {}
	Local aUniqueAux  := {}
	Local aUniqueGrid := {}
	Local nX          := 0
	Local nY          := 0
	Local nLastLine   := 0
	Local nFields     := 0
	Local nLine       := 0
	Local nLine2      := 0
	Local nPosField   := 0
	Local nAliasGrid  := 0
	Local cUniqueKey  := ""
	Local cOtherKey   := ""
	Local cField      := ""
	Local cAlias      := ""
	Local cUniqueKey  := ""
	Local aUniqueFld  := ""

	If ::IsUpdate()
		For nX := 1 To Len(aAlias)

			If !lOk
				Exit
			EndIf

			cAlias := aAlias[nX]

			// Verifica se as tabelas opicionais n�o foram preenchidas
			If ::IsOptional( cAlias )
				Loop
			EndIf

			// Busca por chave unica dessa entidade
			cUniqueKey := ::oStruct:getUnique( cAlias , .T.)
			aUniqueFld := ::oStruct:getUnique( cAlias )

			aArea := ( cAlias )->( GetArea() )
			dbSelectArea( cAlias )
			dbSetOrder(01)
			dbGoTo( ::getRecNo( cAlias ) )

			//valida se a chave nica for alterada
			cDBa := cAlias + '->(' + cUniqueKey + ')'
			cMem := 'M->(' + cUniqueKey + ')'

			If &( cDBa ) <> &( cMem )
				::addError( STR0011 + cAlias + ')' ) // 'Tentativa de altera��o da chave �nica na tabela ('
				lOk := .F.
			EndIf

			//valida se algum campo nao-alteravel foi alterado.
			For nY := 1 To Len(aUniqueFld)
				cDBa := cAlias +'->' + ( aUniqueFld[nY] )
				cMem := 'M->' + aUniqueFld[nY]

				If &( cDBa ) <> &( cMem )
					::addError( STR0012 + aUniqueFld[nY] + ')' ) // 'Tentativa de altera��o de campo n�o-alter�vel ('
					lOk := .F.
				EndIf
			Next nY

			( cAlias )->( RestArea(aArea) )

		Next nX
	EndIf
	//-------------------------------
	// Verifica linha unica da grid
	//-------------------------------
	For nAliasGrid := 1 To Len( aAliasGrid )

		If !lOk
			Exit
		EndIf

		cAlias      := aAliasGrid[nAliasGrid] //Armazena Alias corrente
		aUniqueGrid := {}
		aUniqueAux  := ::oStruct:GetUnique(cAlias)
		aHeaderAux  := ::oStruct:GetHeader(cAlias)
		aColsAux    := ::oStruct:GetCols(cAlias)

		//Indica se a ultima linha � verificada
		nLastLine := 1

		If Len(aColsAux) > 0

			//Verifica se existe algum campo preenchido na ultima linha
			For nFields := 1 To Len( aHeaderAux )
				If !Empty( aTail(aColsAux)[nFields])
					nLastLine := 0
					Exit
				EndIf
			Next nFields

			//Busca somente campos da chave unica que est�o na grid
			For nFields := 1 To Len( aUniqueAux )

				//Campo da chave a ser verificado
				cField := aUniqueAux[nFields]

				If '_FILIAL' $ cField
					Loop
				EndIf

				nPosField := aScan( aHeaderAux , {|x| Trim(x[2]) == cField })
				If nPosField > 0
					aAdd( aUniqueGrid , nPosField )
				EndIf

			Next nFields

			//Percorre registros(linhas) do aCols
			For nLine := 1 To Len( aColsAux ) - nLastLine

				//Somente linhas incluida e alteradas
				If aTail( aColsAux[nLine] )
					Loop
				EndIf

				cUniqueKey := ''

				//Concatena chave unica atual
				For nFields := 1 To Len( aUniqueGrid )

					nPosField := aUniqueGrid[nFields]

					cUniqueKey += RTrim( aColsAux[nLine][nPosField] )
				Next

				//Busca na grid por uma chave unica igual
				For nLine2 := nLine + 1 To Len( aColsAux ) - nLastLine

					//Somente linhas incluida e alteradas
					If aTail( aColsAux[nLine2] )
						Loop
					EndIf

					cOtherKey := ''

					//Concatena chave unica a ser comparada
					For nFields := 1 To Len( aUniqueGrid )

						nPosField := aUniqueGrid[nFields]

						cOtherKey += RTrim( aColsAux[nLine2][nPosField] )
					Next

					//Verifica se a chave � duplicada
					If cUniqueKey == cOtherKey
						::addError('Linha ' + cValToChar(nLine) + ' duplicada com a linha ' + cValToChar(nLine2) + '. Em ' + AllTrim(FWX2Nome(cAlias)) + ' ('+cAlias+')' )
						lOk := .F.
						Exit
					EndIf
				Next

				If !lOk
					Exit
				EndIf

			Next nLine

		EndIf
	Next nAliasGrid

	RestArea(aArea)

Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} validObrigat
M�todo que realiza a valida��o de obrigatoriedade dos campos na classe.

@author Felipe Nathan Welter
@protected
@since 14/02/2012
@version P12
@return lOk Valida��o ok.
/*/
//---------------------------------------------------------------------
METHOD validObrigat() CLASS NGGenerico

	Local nAliasGrid, cAlias, aHeaderAux, aColsAux, nFields, nLine, nX, cField
	Local nLastLine := 1
	Local lOk := .T.
	Local aStruct := ::oStruct:GetStruct()
	Local aMemory := ::oStruct:GetMemory()
	Local aAliasGrid := ::oStruct:GetAliasGrid()

	//-------------------------------------------
	// Verifica campos de Memoria
	//-------------------------------------------
	For nX := 1 To Len(aStruct)

		If !lOk
			Exit
		EndIf

		// Verifica se as tabelas opicionais n�o foram preenchidas
		If ::IsOptional( aStruct[nX,ARQUIVO_STRUCT], aStruct[nX,CAMPO_STRUCT] ) .And. .Not. ::IsFilled( aStruct[nX,ARQUIVO_STRUCT] )
			Loop
		EndIf

		If aStruct[nX][OBRIGAT_STRUCT] == "S"
			nMemory := aSCan(aMemory,{|x| x[FIELD_MEMORY] == aStruct[nX][CAMPO_STRUCT] })
			//Condi��o para que n�o ocorra inconsist�ncia se o campo n�o estiver preenchido
			If nMemory == 0 .Or. Empty(aMemory[nMemory][VALUE_MEMORY])
				::addError(STR0013+aStruct[nX][CAMPO_STRUCT]+')') //'Campo obrigat�rio n�o preenchido ('
				lOk := .F.
			EndIf
		EndIf

	Next nX

	//-------------------------------------------
	// Verifica campos de Grid
	//-------------------------------------------
	/*For nAliasGrid := 1 To Len( aAliasGrid )

		If !lOk
			Exit
		EndIf

		//Indica se a ultima linha � verificada
		nLastLine := 1

		//Armazena Alias corrente
		cAlias := aAliasGrid[nAliasGrid]

		aHeaderAux := ::oStruct:GetHeader( cAlias )
		aColsAux := ::oStruct:GetCols( cAlias )

		//Verifica se existe algum campo preenchido na ultima linha
		For nFields := 1 To Len( aHeaderAux )
			If !Empty( aTail(aColsAux)[nFields] )
				nLastLine := 0
				Exit
			EndIf
		Next nFields

		//Percorre campos do Header
		For nFields := 1 To Len( aHeaderAux )

			If !lOk
				Exit
			EndIf

			cField := Trim( aHeaderAux[nFields][CAMPO_HEADER] )

			If !X3OBRIGAT( cField )
				Loop
			EndIf

			//Percorre registros(linhas) do aCols
			For nLine := 1 To Len( aColsAux ) - nLastLine
				If Empty( aColsAux[nLine][nFields] ) .And. !aTail( aColsAux[nLine] )

					::addError('Linha(' + cValToChar( nLine ) + '): Campo obrigat�rio n�o preenchido (' + cField + ')')

					lOk := .F.
					Exit
				EndIf
			Next nLine
		Next nFields
	Next nAliasGrid*/

Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} validBusiness
M�todo que valida a regra de neg�cio. Deve ser implementado na classe
filha.

@author Felipe Nathan Welter
@protected
@since 14/02/2012
@version P12
@return .T. Fixo.
@obs Metodo deve ser implementado na classe filha.
/*/
//---------------------------------------------------------------------
METHOD validBusiness() CLASS NGGenerico
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} setValidationType
M�todo que permite definir os tipos de valida��o a ser realizada pela
classe filha.

@author Felipe Nathan Welter
@protected
@param cValidType soma dos tipos de valida��o (__VALID_OBRIGAT__,
__VALID_UNIQUE__, __VALID_FIELDS__, __VALID_BUSINESS__) ou apenas
a op��o __VALID_ALL__ (default) ou __VALID_NONE__.
@since 15/05/2013
@version P12
@return .T. Fixo.
@obs N�o se recomenda o uso desse m�todo pela possibilidade de abrir
falhas em validacoes e inconsistencia na base de dados. Seu uso � restrito
a classes n�o-cadastrais.
/*/
//---------------------------------------------------------------------
METHOD setValidationType(cValidType) CLASS NGGenerico
	::cValidType := cValidType
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Free
M�todo que elimina o objeto da mem�ria.

@author Felipe Nathan Welter
@since 14/02/2012
@version P12
@return Nil Sem retorno.
@sample oObj:Free()
/*/
//---------------------------------------------------------------------
METHOD Free() CLASS NGGenerico
	Self := Nil
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} setAlias
M�todo que identifica a alias que ser� utilizada, carregando estrutura
inteira da tabela.

@param cAlias Alias a ser carregado na estrutura.
@param aUseFields [opcional, default={}] Campos a considerar no carregamento.
@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@protected
@since 22/06/2012
@version P12
@return Nil Sem retorno.
/*/
//---------------------------------------------------------------------
METHOD setAlias(cAlias,aUseFields) CLASS NGGenerico
Return ::oStruct:SetAlias(cAlias,aUseFields)

//---------------------------------------------------------------------
/*/{Protheus.doc} setAliasGrid
M�todo que identifica a alias da grid que ser� utilizada,
carregando estrutura inteira da tabela.

@param cAlias Alias a ser carregado na estrutura.
@param aUseFields [opcional, default={}] Campos a considerar no carregamento.
@author NG Inform�tica Ltda.
@protected
@since 26/11/2014
@version P12
@return Nil Sem retorno.
/*/
//---------------------------------------------------------------------
METHOD setAliasGrid(cAlias,aUseFields,oClass) CLASS NGGenerico
Return ::oStruct:SetAliasGrid(cAlias,aUseFields,oClass)

//---------------------------------------------------------------------
/*/{Protheus.doc} setValue
Carrega conte�do para um campo na classe.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@return Nil Sem retorno.
@sample oObj:setValue("CAMPO",xConteudo)
@sample oObj:setValue("CAMPO",xConteudo,{{'CHAVE_CAMPO','CHAVE_CONTEUDO'},..})
/*/
//---------------------------------------------------------------------
METHOD setValue(cField,xValue,aKey) CLASS NGGenerico

	// Condi��o aplicada para que caso seja utilizado este metodo dentro de um Upsert()
	// de uma classe, n�o seja necessario alterar o conteudo da variavel lIsValid.
	// Alterado pois na classe de Ordem de Servi�o, ap�s realizar as valida��es, � neces-
	// sario passar todos os dados validados para o aMemory do objeto utilizando esta fun��o, onde
	// n�o deveria setar o valor de falso.
	If ProcName(1) != "UPSERT"
		::lIsValid := .F.
	EndIf

	::oStruct:setValue(cField,xValue,aKey)
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} setUniqueField
Referencia um campo como "n�o-alter�vel" na estrutura do objeto.

@param cField Nome do campo na estrutura.
@author Felipe Nathan Welter
@since 25/04/2013
@version P12
@return lAdded Indica se o campo foi adicionado ou n�o.
@sample oObj:setUniqueField("CAMPO")
@obs Sempre manter compat�veis as regras de campos n�o-alter�veis com
as regras de neg�cio definidas em validBusiness. Ex: aplicar regras
de valida��o de contador na 'altera��o' de um registro de hist�rico
de movimenta��o de bens (TPN) sendo que n�o � poss�vel alter�-lo.
/*/
//---------------------------------------------------------------------
METHOD setUniqueField(cField) CLASS NGGenerico
Return ::oStruct:setUniqueField(cField)

//---------------------------------------------------------------------
/*/{Protheus.doc} ableInteg
Configura array de integra��es da classe (::aInteg) que servir� pra informar
quais tipos de integra��es que o objeto dever� executar no processo
de persist�ncia de dados na base.

Integer ::aInteg[x][1]: Define id da integra��o
Boolean ::aInteg[x][2]: Liga/Desliga processo de Integra��o

@param Integer nIdInt: id integra��o ( 1 = Mensagem �nica,2 = Pims )
@param Boolean lAble: liga/desliga integra��o relacionado ao id
@author Andr� Felipe Joriatti
@since 19/07/2013
@version P11
@return Nil
@sample oObj:ableContador( 1,.T. )
/*/
//---------------------------------------------------------------------
Method ableInteg( nIdInt, lAble ) Class NGGenerico

	Local nPos := 0

	nPos := aScan( ::aInteg,{ |x| x[1] == nIdInt } )
	If nPos > 0
		::aInteg[nPos][2] := lAble
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} getUnique


@param
@author NG Inform�tica Ltda.
@since 25/04/2013
@version P12
@return

/*/
//---------------------------------------------------------------------
METHOD getUnique(cAlias) CLASS NGGenerico
Return ::oStruct:getUnique(cAlias)

//---------------------------------------------------------------------
/*/{Protheus.doc} getHeader


@param
@author NG Inform�tica Ltda.
@since 25/04/2013
@version P12
@return

/*/
//---------------------------------------------------------------------
METHOD getHeader(cAlias) CLASS NGGenerico
Return ::oStruct:getHeader(cAlias)

//---------------------------------------------------------------------
/*/{Protheus.doc} getCols


@param
@author NG Inform�tica Ltda.
@since 25/04/2013
@version P12
@return

/*/
//---------------------------------------------------------------------
METHOD getCols(cAlias) CLASS NGGenerico
Return ::oStruct:getCols(cAlias)

//---------------------------------------------------------------------
/*/{Protheus.doc} getRelation


@param
@author NG Inform�tica Ltda.
@since 25/04/2013
@version P12
@return

/*/
//---------------------------------------------------------------------
METHOD getRelation(cAlias) CLASS NGGenerico
Return ::oStruct:getRelation(cAlias)

//---------------------------------------------------------------------
/*/{Protheus.doc} setNoDelete


@param
@author NG Inform�tica Ltda.
@since 25/04/2013
@version P12
@return

/*/
//---------------------------------------------------------------------
METHOD setNoDelete(cAlias) CLASS NGGenerico
Return ::oStruct:setNoDelete(cAlias)

//---------------------------------------------------------------------
/*/{Protheus.doc} CommitGrid
M�todo para inclus�o, altera��o e exclus�o das grids definidas na classe

@author NG Inform�tica Ltda.
@since 28/10/2014
@version P12
@return

/*/
//---------------------------------------------------------------------
METHOD CommitGrid() CLASS NGGenerico

	//Numerico
	Local nAlias, nMemory, nRelation, nFields, nLine, nAliasGrid,;
	nFieldPK, nX, nHeader, nFieldHdr, nUnique, nTamField

	//Caracter
	Local cUniqueKey, cAlias, cValueKey, cDBKey, cWhile, cRelation,;
	cField, cGridKey, cContent, cFilterFld, cFilterCnd, cFieldName,;
	cFieldCont

	//Logico
	Local lExiste

	//Array
	Local aHeaderAux, aRelatAux, aColsAux, aUniqueAux, aUniqueGrid, aValues
	Local aAliasGrid := ::oStruct:GetAliasGrid()

	If !::IsValid()
		::addError(STR0001) //'Objeto n�o est� validado!'
	Else

		//----------------------------------------------------------------------
		// Commit - Atualiza base de dados com as opera��es efetuadas
		//----------------------------------------------------------------------
		For nAliasGrid := 1 To Len( aAliasGrid )

			//Armazena Alias corrente
			cAlias := aAliasGrid[nAliasGrid]

			//Carrega informacoes referente ao Alias
			aUniqueAux	:= ::oStruct:GetUnique( cAlias )
			aHeaderAux	:= ::oStruct:GetHeader( cAlias )
			aRelatAux	:= ::oStruct:GetRelation( cAlias )
			aColsAux	:= ::oStruct:GetCols( cAlias )

			//Restaura variaveis
			aUniqueGrid := {}
			cDBKey := cAlias + '->('
			cWhile := ''
			cRelation := ''
			cFilterFld := ''
			cFilterCnd := ''

			//------------------------------------------------------------------
			// Unico - Busca SOMENTE por campos da chave unica na grid
			//------------------------------------------------------------------
			For nFields := 1 To Len( aUniqueAux )

				//Campo da chave a ser verificado
				cField := Trim( aUniqueAux[nFields] )

				nPosField := aScan( aRelatAux , {|x| Trim(x[1]) == cField })

				//--------------------------------------------------------------
				// Relacionamento - Campos unicos do relacionameto
				//--------------------------------------------------------------
				If nPosField > 0

					//Conteudo do relacionamento
					cContent := fContent( aRelatAux[nPosField][2] , Self )

					If ValType( cContent ) == "D"
						cContent := DToS( cContent )
					EndIf

					//Somente concatena se a chave unica n�o for mista
					If Len( aUniqueGrid ) == 0

						//Inicia a montagem da condi��o
						If Empty( cWhile )
							cWhile := cAlias + '->('
						EndIf

						//Havendo mais de um campo unico no relacionamento atribui '+'
						If At( '(' , cWhile ) <> Len( cWhile )
							cWhile += '+'
						EndIf

						//Concatena campos do relacionamento
						cWhile += 	cField

						//Concatena conteudo do relacionamento
						cRelation += PadR( cContent , TamSx3( cField )[1] )

						//Caso contrario, monta filtro para la�o de repeti��o
					Else

						//Inicia a montagem do filtro
						If Empty( cFilterFld )
							cFilterFld := cAlias + '->('
						EndIf

						//Havendo mais de um campo unico no filtro atribui '+'
						If At( '(' , cFilterFld ) <> Len( cFilterFld )
							cFilterFld += '+'
						EndIf

						//Concatena campos do relacionamento
						cFilterFld += cField

						//Concatena conteudo do filtro
						cFilterCnd += PadR( cContent , TamSx3( cField )[1] )

					EndIf
				//--------------------------------------------------------------
				// Grid - Campos unicos da grid
				//--------------------------------------------------------------
				Else

					//Procura campo unico na grid
					nPosField := aScan( aHeaderAux , {|x| Trim(x[2]) == cField })

					//Reserva posicao e tamanho desse campo
					aAdd( aUniqueGrid , { nPosField , TamSx3( cField )[1] } )

					//Havendo mais de um campo unico na grid atribui '+'
					If Len( aUniqueGrid ) > 1
						cDBKey += '+'
					EndIf

					//Concatena chave utlizada para comparacao com a base
					cDBKey += cField

				EndIf

				//Termina de concatenar condicao
				If nFields == Len( aUniqueAux )
					cDBKey += ')'

					If !Empty( cWhile )
						cWhile += ')'
					EndIf

					If !Empty( cFilterFld )
						cFilterFld += ')'
					EndIf
				EndIf

			Next nFields

			//------------------------------------------------------------------
			// Posicionamento - Registros relacionados ao cadastro
			//------------------------------------------------------------------
			dbSelectArea( cAlias )
			dbSetOrder( 1 )
			dbSeek( cRelation )

			//------------------------------------------------------------------
			// Diferen�a - Verifica diferen�a entre base e grid
			//------------------------------------------------------------------
			While !Eof() .And. &( cWhile ) == cRelation

				//Em caso de chave unica mista, executa o filtro
				If !Empty( cFilterFld ) .And. &( cFilterFld ) == cFilterCnd
					( cAlias )->( dbSkip() )
					Loop
				EndIf

				//Indica que ainda n�o existe registro encontrado na grid
				lExiste := .F.

				//Guarda chave do registro poscionado
				cValueKey := &( cDBKey )

				For nLine := 1 To Len( aColsAux )

					//Somente linhas incluidas ou alteradas
					If aTail( aColsAux[nLine] )
						Loop
					EndIf

					If ::EmptyLine( cAlias , nLine )
						Loop
					EndIf

					//Limpa chave para o proximo registro
					cGridKey := ''

					//Concatena chave unica a ser comparada
					For nFields := 1 To Len( aUniqueGrid )

						//Posicao do campo (Grid)
						nPosField := aUniqueGrid[nFields][1]

						//Tamanho do campo (Grid)
						nTamField := aUniqueGrid[nFields][2]


						cContent := aColsAux[nLine][nPosField]

						If ValType( cContent ) == "D"
							cContent := DToS( cContent )
						EndIf

						//Concatena conteudo dos campos
						cGridKey += PadR( cContent , nTamField )
					Next

					//Verifica se existe o registro na grid
					If cValueKey == cGridKey
						lExiste := .T.
						Exit
					EndIf
				Next nLine

				//Exclui registro se n�o existir na grid
				If !lExiste
					RecLock( cAlias , .F. )
					dbDelete()
					MsUnLock()
				EndIf

				DBSelectArea( cAlias )
				DBSetOrder( 1 )
				( cAlias )->( dbSkip() )
			End

			//------------------------------------------------------------------
			// Atualiza��o - Upsert dos registros grid na base
			//------------------------------------------------------------------
			For nLine := 1 To Len( aColsAux )

				//Somente linhas incluida e alteradas
				If aTail( aColsAux[nLine] )
					Loop
				EndIf

				If ::EmptyLine( cAlias , nLine )
					Loop
				EndIf

				//Concatena chave unica do registro
				cUniqueKey := fGetPKGrid( cAlias , Self , nLine )

				//Encerra processo caso n�o exista chave unica completa
				If Empty( cUniqueKey )
					Loop
				EndIf

				//Verifica se o registro existe na base
				DBSelectArea( cAlias )
				DBSetOrder( 1 )
				lExiste := dbSeek( cUniqueKey )
				aValues := {}

				//Armazena campos do aCols
				For nFields := 1 To Len( aHeaderAux )

					//Somente campos reais s�o gravados
					If aHeaderAux[nFields][CONTEXT_HEADER] == 'V'
						Loop
					EndIf

					cFieldName := Trim( aHeaderAux[nFields][CAMPO_HEADER] )
					cFieldCont := aColsAux[nLine][nFields]
					aAdd( aValues , { cFieldName , cFieldCont } )
				Next nFields

				//Armazena campos do relacionamento
				For nFields := 1 To Len( aRelatAux )

					cFieldName := Trim( aRelatAux[nFields][1] )
					cFieldCont := fContent( aRelatAux[nFields][2] , Self )
					nPosField := aScan( aValues , { |x| x[1] ==  cFieldName})
					If nPosField > 0
						aValues[nPosField][2] := cFieldCont
					Else
						aAdd( aValues , { cFieldName , cFieldCont } )
					EndIf
				Next

				//Por garantia campo de filial � preenchido automaticamente
				cFieldName := PrefixoCpo( cAlias ) + '_FILIAL'
				cFieldCont := xFilial( cAlias )
				nPosField := aScan( aValues , { |x| x[1] ==  cFieldName} )
				If nPosField > 0
					aValues[nPosField][2] := cFieldCont
				Else
					aAdd( aValues , { cFieldName , cFieldCont } )
				EndIf

				//Grava��o o registro
				For nFields := 1 To Len( aValues )

					cFieldName := Trim( aValues[nFields][1] )
					cFieldCont := aValues[nFields][2]


					//Define opera��o Inclui ou Alterar conforme registro
					If nFields == 1
						RecLock( cAlias , !lExiste )
					EndIf

					cField := cAlias + '->' + cFieldName
					&( cField ) := cFieldCont

					If nFields == Len( aValues )
						MsUnLock()
					EndIf
				Next
			Next nLine
		Next nAliasGrid
	EndIf

Return ::IsValid()

//--------------------------------------------------------------------
/*/{Protheus.doc} EmptyLine
Verifica se a linha da grid est� vazia

@param
@author NG Inform�tica Ltda.
@since 25/04/2013
@version P12
@return
/*/
//--------------------------------------------------------------------
METHOD EmptyLine( cAlias , nLine ) CLASS NGGenerico

	Local nFields
	Local lEmpty := .T.
	Local aAreaSX3 := SX3->( GetArea() )
	Local aHeaderAux := ::oStruct:GetHeader( cAlias )
	Local aRelatAux := ::oStruct:GetRelation( cAlias )
	Local aColsAux := ::oStruct:GetCols( cAlias )

	Default nLine := Len( aColsAux )

	dbSelectArea('SX3')
	dbSetOrder(02)
	For nFields := 1 To Len( aHeaderAux )

		If aScan( aRelatAux , {|x| Trim(x[1]) == aHeaderAux[nFields][CAMPO_HEADER] }) > 0
			Loop
		EndIf

		dbseek( aHeaderAux[nFields][CAMPO_HEADER] )
		If !Empty( X3CBox() )
			Loop
		EndIf

		If !Empty( aColsAux[nLine][nFields] )
			lEmpty := .F.
			Exit
		EndIf

	Next nFields

	RestArea( aAreaSX3 )

Return lEmpty

//------------------------------------------------------------------------------
/*/{Protheus.doc} ShowHelp
Apresenta mensagem de erro

@author NG Inform�tica Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Method ShowHelp() CLASS NGGenerico

	If .Not. ::IsValid()
		Help( " ",1,STR0014,,::GetErrorList()[1],3,1 ) //"NAO CONFORMIDADE"
	EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetUpperObj
Indica se a opera��o definida na classe � uma inclus�o

@author NG Inform�tica Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Method IsInsert() Class NGGenerico
Return ::GetOperation() == 3

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetUpperObj
Indica se a opera��o definida na classe � uma aletra��o

@author NG Inform�tica Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Method IsUpdate() CLASS NGGenerico
Return ::GetOperation() == 4

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetUpperObj
Indica se a opera��o definida na classe � uma exclus�o

@author NG Inform�tica Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Method IsDelete() CLASS NGGenerico
Return ::GetOperation() == 5

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsUpsert
Indica se a opera��o definida na classe � uma inclus�o ou altera��o

@author NG Inform�tica Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Method IsUpsert() CLASS NGGenerico
Return ::GetOperation() == 3 .Or. ::GetOperation() == 4

//---------------------------------------------------------------------
/*/{Protheus.doc} MsgRequired
Metodo que concatena mensagem de campo obrigat�rio.

@author NG Inform�tica Ltda.
@since 01/01/2015
/*/
//---------------------------------------------------------------------
Method MsgRequired( cFieldReq , nLine ) Class NGGenerico
Return ::oError:MsgRequired( cFieldReq , nLine )

//---------------------------------------------------------------------
/*/{Protheus.doc} clearErrorList
M�todo que limpa a lista de erros.

@author Guilherme Freudenburg
@since 10/07/2019

@return Executa a limpeza das variaveis ::aError,::aAsk e ::aInfo.
/*/
//---------------------------------------------------------------------
Method clearErrorList() Class NGGenerico
Return ::oError:clearList()

//---------------------------------------------------------------------
/*/{Protheus.doc} SetOptional
Indica se o preenchimento do Alias � opcional

@author NG Inform�tica Ltda.
@since 01/01/2015
/*/
//---------------------------------------------------------------------
Method SetOptional( cAlias ) Class NGGenerico
Return ::oStruct:SetOptional( cAlias )

//---------------------------------------------------------------------
/*/{Protheus.doc} IsOptional
Retorna se o preenchimento do Alias � opcional

@author NG Inform�tica Ltda.
@since 01/01/2015
/*/
//---------------------------------------------------------------------
Method IsOptional( cAlias, cField ) Class NGGenerico
Return ::oStruct:IsOptional( cAlias, cField )

//---------------------------------------------------------------------
/*/{Protheus.doc} IsFilled
Indica se o cadastro foi preenchido

@author NG Inform�tica Ltda.
@since 01/01/2015
/*/
//---------------------------------------------------------------------
Method IsFilled( cAlias ) Class NGGenerico
Return ::oStruct:IsFilled( cAlias )

//---------------------------------------------------------------------
/*/{Protheus.doc} RemoveField
Retira o campo da estrutura do Dicion�rio para n�o ser validado.

@author Diego de Oliveira
@param  cField, caracter, Campo que ser� retirado.

@since  07/08/2019
/*/
//---------------------------------------------------------------------
Method RemoveField( cField ) Class NGGenerico

	// Alterado conte�do da vari�vel para garantir que, quando for campo chave de tabela,
	// sejam mantidas suas valida��es e regras de neg�cio.
	If ProcName(1) != "UPSERT"
		::lIsValid := .F.
	EndIf

Return ::oStruct:RemoveField( cField )

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam
Define os par�metros que ser�o utilizados nas classes

@author Maicon Andr� Pinheiro
@param  cParam, caracter, C�digo do par�metro a ser utilizado
@param  xDefault, undefined, Valor Default caso o par�metro n�o exista
@since  30/05/2018
@return Nil
/*/
//-------------------------------------------------------------------
Method SetParam(cParam, xDefault) Class NGGenerico
Return ::oStruct:SetParam(cParam, xDefault)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetParam
Retorna o par�metro solicitado.

@author Maicon Andr� Pinheiro
@param  cParam, caracter, C�digo do par�metro a ser utilizado
@param  xDefault, undefined, Valor Default caso o par�metro n�o exista
@since  30/05/2018
@return xContent
/*/
//-------------------------------------------------------------------
Method GetParam(cParam) Class NGGenerico
Return ::oStruct:GetParam(cParam)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetRelMemos
Seta quais campos que tem relacionamento de memo para utilizar a tabela
SYP. Os campos devem pertencer a mesma tabela, bem como estarem relacionados a
alguma tabela pai setada no New do objeto.

@author Maicon Andr� Pinheiro
@param  aRelMemos, array, Matriz onde cada array possui duas posi��es, sendo:
1. Campo c�digo que ir� gravar na SYP;
2. Campo memo virtual que ir� mostrar em tela a descri��o da SYP.

@since  07/06/2018
@return Nil
/*/
//-------------------------------------------------------------------
Method SetRelMemos(aRelMemos) Class NGGenerico
Return ::oStruct:SetRelMemos(aRelMemos)

//---------------------------------------------------------------------
/*/{Protheus.doc} setAsk
Define se exibe mensagens de confirma��o.

@author Wexlei Silveira
@since 26/02/2018
@return bool -	.T. - Para exibir mensagens de confirma��o.
                .F. - Para n�o mensagens de confirma��o.
/*/
//---------------------------------------------------------------------
Method setAsk(lAsk) Class NGGenerico

	::lAsk := lAsk

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} getAsk
Indica se exibe mensagens de confirma��o.

@author Wexlei Silveira
@since 26/02/2018
@return bool -	.T. - Se ir� exibir mensagens de confirma��o.
                .F. - Se n�o ir� exibir mensagens de confirma��o.
/*/
//---------------------------------------------------------------------
Method getAsk() Class NGGenerico
Return ::lAsk
//---------------------------------------------------------------------
/*/{Protheus.doc} setInfo
Define se exibe mensagens informativas.

@author Maicon Andr� Pinheiro
@since  11/06/2018
@sample Self:setInfo(.T.) Para exibir mensagens informativas.
        Self:setInfo(.F.) Para n�o exibir mensagens informativas.
/*/
//---------------------------------------------------------------------
Method setInfo(lInfo) Class NGGenerico

	::lInfo := lInfo

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} getInfo
Indica se exibe mensagens informativa

@author Maicon Andr� Pinheiro
@since  11/06/2018
@return Self:lInfo, bool, .T. - Se ir� exibir mensagens de confirma��o;
                	      .F. - Se n�o ir� exibir mensagens de confirma��o.
/*/
//---------------------------------------------------------------------
Method getInfo() Class NGGenerico
Return ::lInfo
//---------------------------------------------------------------------
/*/{Protheus.doc} setRelation
@param
@author NG Inform�tica Ltda.
@since 21/02/2018
@version P12
@return
/*/
//---------------------------------------------------------------------
METHOD setRelation(cAlias,aRelation) CLASS NGGenerico
Return ::oStruct:setRelation(cAlias,aRelation)
//--------------------------------------------------------------------
/*/{Protheus.doc} setCols
Metodo para carregar conteudo do aCols da grid para a estrutura
da classe.

@author NG Inform�tica Ltda.
@since 28/10/2014
@version P12
@return Nil
/*/
//--------------------------------------------------------------------
Method setCols( cAlias , aGrid ) Class NGGenerico
Return ::oStruct:setCols( cAlias, aGrid )
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetParent
Retorna objeto vigente em outra classe

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return Object or Nil
@sample oObj:GetParent()
@obs O retorno ser� um objeto quando tal for definido pelo SetParent
/*/
//------------------------------------------------------------------------------
Method GetParent() Class NGGenerico
Return Self:oParent

/*********************************************************************/
/*///////////////////////////////////////////////////////////////////*/
/*                         FUNCOES AUXILIARES                        */
/*///////////////////////////////////////////////////////////////////*/
/*********************************************************************/

Static Function fGetPK(cAlias,oObj)

	Local nX, nIndex, aPK, cKey := ''
	Local aAlias  := oObj:oStruct:GetAlias()
	Local aMemory := oObj:oStruct:GetMemory()
	Local aStruct := oObj:oStruct:GetStruct()
	Local aIndex  := oObj:oStruct:GetIndex()

	//localiza chave primaria da tabela
	nAlias := aSCan(aAlias,{|x| x == cAlias})
	nIndex := aScan(aIndex,{|x| x[1] == aAlias[nAlias]})
	aPK := StrTokArr(aIndex[nIndex,2][1],'+')

	//monta o indice do registro em memoria para pesquisa
	cKey := ''
	For nX := 1 To Len(aPK)
		//deixa apenas o campo, remove as funcoes DTOS() e outras do indice
		nMemory := aScan(aMemory,{|x| x[FIELD_MEMORY] == AllTrim(StrTran(SubStr(aPK[nX], At('(',aPK[nX])+1) ,')','')) })
		cValue := If(ValType(aMemory[nMemory,VALUE_MEMORY]) == "D",DTOS(aMemory[nMemory,VALUE_MEMORY]),aMemory[nMemory,VALUE_MEMORY])
		cKey += cValue
	Next nX

Return cKey

//------------------------------------------------------------------------------
/*/{Protheus.doc} fGetPKGrid
Retorna array com a chave unica da grid

@author NG Inform�tica Ltda.
@since 28/10/2014
@version P12
@return array
/*/
//------------------------------------------------------------------------------
Static Function fGetPKGrid( cAlias , oObj , nLine )

	Local nFields, nPosField, xRelation, cField
	Local cUniqueKey := ''
	Local lWriteLine := .F.
	Local lOk := .T.

	Local aUniqueAux := oObj:GetUnique( cAlias )
	Local aHeaderAux := oObj:GetHeader( cAlias )
	Local aRelatAux := oObj:GetRelation( cAlias )
	Local aColsAux := oObj:GetCols( cAlias )

	For nFields := 1 To Len( aUniqueAux )

		//Campo da chave a ser verificado
		cField := aUniqueAux[nFields]

		//---------------------------------
		// Busca conteudo no Relacionamento
		//---------------------------------
		nPosField := aScan( aRelatAux , {|x| Trim(x[1]) == cField })
		If nPosField > 0

			cContent := fContent( aRelatAux[nPosField][2] , oObj:Self )

		//---------------------------------
		// Busca conteudo na Grid
		//---------------------------------
		Else
			nPosField := aScan( aHeaderAux , {|x| Trim(x[2]) == cField })
			If nPosField > 0
				cContent := aColsAux[nLine][nPosField]

				If !Empty( aColsAux[nLine][nPosField] )
					lWriteLine := .T.
				EndIf
			Else
				lOk := .F.
			EndIf
		EndIf

		//---------------------------------
		// Concatena Chave Unica
		//---------------------------------
		If lOk
			If ValType( cContent ) == 'D'
				cContent := DToS( cContent )
			EndIf

			cUniqueKey += PadR( cContent , TamSx3( cField )[1] )

		//-----------------------------------
		// Existe problema, encerra processo
		//-----------------------------------
		Else
			cUniqueKey := ''
			Exit
		EndIf

	Next nFields

	//Considera chave unica somente com algum campo da grid preenchido
	If !lWriteLine
		cUniqueKey := ''
	EndIf

Return cUniqueKey

//------------------------------------------------------------------------------
/*/{Protheus.doc} fGetPKBase
Retorna array com o relacionamento da base.

@author NG Inform�tica Ltda.
@since 28/10/2014
@version P12
@return array
/*/
//------------------------------------------------------------------------------
Static Function fGetPKBase( cAlias , oObj , nRecno )

	Local nFields, cField
	Local cUniqueKey := ''
	Local aUniqueAux := oObj:GetUnique( cAlias )

	DBSelectArea( cAlias )
	DBGoTo( nRecno )
	For nFields := 1 To Len( aUniqueAux )

		If Eof()
			Exit
		EndIf

		//Campo da chave a ser verificado
		cField := Trim( aUniqueAux[nFields] )
		cUniqueKey += &( cAlias + '->' + cField )
	Next
Return cUniqueKey

//------------------------------------------------------------------------------
/*/{Protheus.doc} fContent


@param
@author NG Inform�tica Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Static Function fContent( cContent , oObj )

	Local xContent
	Local aStruct := oObj:oStruct:GetStruct()

	If aScan( aStruct , { |x| x[CAMPO_STRUCT] == cContent} ) > 0
		xContent := oObj:GetValue( cContent )
	Else
		xContent := &( cContent )
	EndIf

Return xContent

//------------------------------------------------------------------------------
/*/{Protheus.doc} fFieldMemo
Verifica se o campo faz parte de um relacionamento de campos memos

@param cField, caracter, Campos a ser pesquisado para saber se possui relacionamento de memo
@param oObj, object, Estrutura do objeto pai
@return .T. - Possui relacionamento; .F. n�o possui relacionamento.
@author Maicon Andr� Pinheiro
@since 07/06/2018
/*/
//------------------------------------------------------------------------------
Static Function fFieldMemo(cField, oObj)
Return aScan(oObj:oStruct:aRelMemos,{|x| x[1] == cField .Or. x[2] == cField }) > 0
