#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA740E.CH"

//Definição das Posições retornadas pela função At740EGTP()
#Define tpbABA				1
#Define tpbIDENTIFICACAO		2
#Define tpbTITULO				3
#Define tpbDESCRICAO			4
#Define tpbMODO				5
#DEFINE tpbTAMANHO			6
#DEFINE tpbDECIMAL			7
#Define tpbEDICAO				8
#Define tpbFORMULA			9
#Define tpbVALIDACAO			10
#Define tpbINICIALIZADOR		11
#Define tpbCONTEUDO			12

//Definição das Posições retornadas para suporte ao Array retornado pela função At740ELTP()
#Define xmlCOLFIELD			01	//Coluna
#Define xmlCOLDATA			02	//Coluna
#Define xmlCOLTOTAL			02	//Coluna
#Define xmlLINNAME			01	//Linha
#Define xmlLINNICKNAME		02	//Linha
#Define xmlLINFORMULA		03	//Linha
#Define xmlLINVALUE			04	//Linha
#Define xmlLINPICTURE		05	//Linha
#Define xmlLINTOTAL			05	//Linha

Static oFWSheet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA740E
	Tabelas de Precificação

@sample 	TECA740E()

@return	Nil

@author	Serviços
@since		21/01/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function TECA740E()
Local oBrowse

oBrowse := FwMBrowse():New()

oBrowse:SetAlias("TV6")
oBrowse:SetDescription( STR0001 ) //"Tabelas de precificação"
oBrowse:DisableDetails()

//Legendas para o browse
oBrowse:Addlegend( "TV6_STATUS=='1'", "GREEN", STR0002 ) // "Tabela Ativa"
oBrowse:Addlegend( "TV6_STATUS=='2'", "RED"	 , STR0003 ) // "Tabela Inativa"

//Pre validações da Classe
At740EPreV()

// Ativação da Classe
oBrowse:Activate()



Return(Nil)


//----------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef - Tabelas de precificação

@Return 	array	Estrutura de menu com as opções.
@author 	Serviços
@since 		28/01/2015
/*/
//----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0004 ACTION "AxPesqui" 			OPERATION 1	ACCESS 0 	// "Pesquisar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TECA740E"	OPERATION 2 ACCESS 0 	// "Visualizar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TECA740E" 	OPERATION 3	ACCESS 0 	// "Incluir"
ADD OPTION aRotina TITLE STR0007 ACTION "At740EVld()"		OPERATION 4	ACCESS 0 	// "Alterar"
ADD OPTION aRotina TITLE STR0008 ACTION "At740ECpy()"		OPERATION 4	ACCESS 0 	// "Copiar Tabela"

Return(aRotina)


//----------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model - Tabelas de precificação

@Return 	objeto	Objeto modelo de dados.
@author 	Serviços
@since 		28/01/2015
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel

Local oStruTV6		:= FWFormStruct(1,"TV6")
Local oStrRTV7		:= FWFormStruct(1,"TV7")
Local oStrITV7		:= FWFormStruct(1,"TV7")
Local bCommit			:= { |oModel| At740ECmt(oModel) }
Local bPosValidacao	:= { |oModel| At740EPos(oModel) }
Local bLinePre		:= {|oMdlG,nLine,cAcao,cCampo| At740EPreL(oMdlG, nLine, cAcao, cCampo) }
Local aLoadFilter		:= {}

oStrRTV7:SetProperty( "TV7_CODTAB", MODEL_FIELD_OBRIGAT, .F. )
oStrRTV7:SetProperty( "TV7_GRUPO", MODEL_FIELD_OBRIGAT, .F. )
oStrRTV7:SetProperty( "TV7_ABA", MODEL_FIELD_OBRIGAT, .T. )
oStrITV7:SetProperty( "TV7_CODTAB", MODEL_FIELD_OBRIGAT, .F. )
oStrITV7:SetProperty( "TV7_GRUPO", MODEL_FIELD_OBRIGAT, .F. )

oModel := MPFormModel():New( "TECA740E", /*bPreValidacao*/, bPosValidacao, bCommit, /*bCancel*/ )

// Campos da tabela de precificação
oModel:AddFields("TV6MASTER",/*cOwner*/,oStruTV6, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Grid de Recursos Humanos
oModel:AddGrid("TV7RDETAIL","TV6MASTER",oStrRTV7,bLinePre, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/ )
oModel:SetRelation("TV7RDETAIL",{{"TV7_FILIAL","xFilial('TV7')"},{"TV7_CODTAB","TV6_CODIGO"}},TV7->(IndexKey(2)))

// Grid de Impostos
oModel:AddGrid("TV7IDETAIL","TV6MASTER",oStrITV7,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/ )
oModel:SetRelation("TV7IDETAIL",{{"TV7_FILIAL","xFilial('TV7')"},{"TV7_CODTAB","TV6_CODIGO"}},TV7->(IndexKey(2)))

oModel:SetDescription( STR0001 ) // "Tabelas de precificação"

/* --------------- FILTROS -------------------- */
// Grid somente dos impostos
aLoadFilter := { { "TV7_GRUPO", "'2'", MVC_LOADFILTER_EQUAL } }
oModel:GetModel("TV7IDETAIL"):SetLoadFilter( aLoadFilter, /*cLoadFilter*/ )

// Grid somente dos recursos humanos
aLoadFilter := { { "TV7_GRUPO", "'1'", MVC_LOADFILTER_EQUAL } }
oModel:GetModel("TV7RDETAIL"):SetLoadFilter( aLoadFilter, /*cLoadFilter*/ )


oModel:GetModel("TV7IDETAIL"):SetOptional(.T.) // (.T.) Preenchimento Opcional

// Para não repetir linhas nos grids de exceção
oModel:GetModel("TV7RDETAIL"):SetUniqueLine( { "TV7_IDENT" } )
oModel:GetModel("TV7IDETAIL"):SetUniqueLine( { "TV7_IDENT" } )

Return(oModel)


//----------------------------------------------------------
/*/{Protheus.doc} ViewDef
View - Tabelas de precificação

@Return 	objeto	Atribuido das regras de exibição de Formulario e Dados
@author 	Serviços
@since 		28/01/2015
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel("TECA740E")
Local oStruTV6 := FWFormStruct( 2, "TV6", {|cCpo| !cCpo $ "TV6_CODIGO" } )
Local oStrRTV7 := FWFormStruct( 2, "TV7", {|cCpo| !cCpo $ "TV7_CODIGO#TV7_CODTAB#TV7_GRUPO" } )
Local oStrITV7 := FWFormStruct( 2, "TV7", {|cCpo| !cCpo $ "TV7_CODIGO#TV7_CODTAB#TV7_GRUPO" } )

oStruTV6:RemoveField("TV6_IMP")
oStrITV7:RemoveField("TV7_ABA")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( "VIEW_TV6", oStruTV6, "TV6MASTER" )
oView:AddGrid( "VIEW_TV7R", oStrRTV7, "TV7RDETAIL" )
oView:AddGrid( "VIEW_TV7I", oStrITV7, "TV7IDETAIL" )

oView:CreateHorizontalBox( "TOP" , 10 )
oView:CreateHorizontalBox( "MIDDLE" , 45 )
oView:CreateHorizontalBox( "DOWN" , 45 )

oView:SetOwnerView( "VIEW_TV6", "TOP" )
oView:SetOwnerView( "VIEW_TV7R", "MIDDLE" )
oView:SetOwnerView( "VIEW_TV7I", "DOWN" )

oView:EnableTitleView( "VIEW_TV7R", STR0009 ) 	// "Recursos Humanos"
oView:EnableTitleView( "VIEW_TV7I", STR0010 )		// "Impostos"

oView:SetCloseOnOK( {|| .T. } )

Return(oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740EPreL
	 Realiza pré validações na linha do Grid.

@sample	At740EPreL(oMdlG, nLine, cAcao, cCampo)
@param 		[oMdlG],objeto,Modelo de Dados a ser utilizado para a gravação dos dados.
@param		[nLine],numerico,Linha que está sendo editada.
@param		[cAcao],caractere,Eventos executados: DELETE;UNDELETE;CANSETVALUE,SETVALUE,ETC.
@param		[cCampo],caractere,Nome do campo sendo editado.
@Return	logico	Resultado da Valição
@since		09/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Static Function At740EPreL(oMdlG, nLine, cAcao, cCampo)
Local lRet := .T.

If !IsInCallStack("AT740ETPB") .AND.;
	cAcao == "SETVALUE" .AND.;
	cCampo $ 'TV7_TAM;TV7_DEC' .AND.;
	(oMdlG:GetValue("TV7_MODO") == '2')
	lRet := .F.
	Help(,,STR0011,, STR0012, 1, 0) // 'Restrição de acesso'#'Modo tipo COMBO não utiliza propriedades: Tamanho e/ou Decimal'
EndIf

Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740EPos
	 Realiza a Pós validação do formulário pela a ação Confirma/Gravar.

@sample	At740EPos(oModel)
@param 		[oModel],objeto,Modelo de Dados a ser utilizado para a gravação dos dados.
@Return	logico	Resultado da Valição
@since		09/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740EPos(oModel)
Local lRet			:= .T.
Local lModoAlt	:= (oModel:GetOperation() == MODEL_OPERATION_UPDATE)
Local lModoInc	:= (oModel:GetOperation() == MODEL_OPERATION_INSERT)
Local nRecNoTV6	:= TV6->(RECNO())
Local lPlanAtiva	:= (oModel:GetModel("TV6MASTER"):GetValue("TV6_STATUS") == "1")
Local oMdlRH		:= oModel:GetModel("TV7RDETAIL")
Local oMdlImp		:= oModel:GetModel("TV7IDETAIL")
Local cMsg			:= ''

// Verifica a existência obrigatória dos Campos: TOTAL_RH e TOT_VIMP
If lRet .and. (lModoAlt .or. lModoInc)

	If lRet .and. lModoAlt .and. At740ECTB(oModel)
		cMsg := STR0028 + STR0029					// 'ATENÇÃO: '###'Alerta de Vínculo Encontrado. '
		cMsg += CRLF + CRLF + STR0030				// 'A tabela que deseja alterar possui vínculo com o arquivo de orçamentos (TFJ).'
		cMsg += CRLF + STR0031						// 'Esta alteração não será repassada para estes casos mesmo que não seja criada nova revisão.'
		cMsg += CRLF + ' . . . ' + CRLF + STR0032	// 'Deseja continuar com esta operação?'
		lRet := MsgYesNo(cMsg)
	EndIf

	If lRet .and. !oMdlRH:SeekLine( {{'TV7_IDENT','TOTAL_RH'}} )
		Help(,,STR0013,, STR0033, 1, 0) // 'Modelo Inválido'#'É obrigatória a criação do campo TOTAL_RH na estrutura de Recursos Humanos para atender os totalizadores, verifique.'
		lRet := .F.
	EndIf

	If lRet .and. (oMdlImp:LengTh(.T.) > 1 .or. (oMdlImp:LengTh(.T.) == 1 .AND. !Empty(oMdlImp:GetValue('TV7_IDENT'))))
		If !oMdlImp:SeekLine( {{'TV7_IDENT','TOT_VIMP'}} )
			Help(,,STR0013,, STR0015, 1, 0) // 'Modelo Inválido'#'É obrigatória a criação do campo TOT_IMP na estrutura de Impostos, verifique.'
			lRet := .F.
		EndIf
	EndIf

EndIf

// Verifica se a operação é de Alteração e se a Tabela está ativa.
If lRet .and. lModoAlt .and. lPlanAtiva
	// Verifica se a revisão atual é a última revisão
	lValNumRev := oModel:GetModel("TV6MASTER"):GetValue("TV6_REVISA") == At740EGNR(oModel,.T.)

	cMsg := STR0016 // "Deseja salvar como nova revisão a alteração na Tabela de Precificação?"

	If lValNumRev .and. MsgYesNo(cMsg)
		MsgRun( STR0017, STR0018,{|| lRet := At740ERev( oModel )} ) //"Criando Revisão da Tabela de Precificação."#"Processando"
		If lRet
			oModel:Deactivate()
			TV6->(dbGoTo(nRecNoTV6))
			oModel:Activate()
			oModel:GetModel("TV6MASTER"):SetValue("TV6_STATUS","2")
		EndIf
	EndIf
EndIf

Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ECmt
	 Realiza a gravação do dados

@sample	At740ECmt(oModel,[.T.])
@param 		[oModel],objeto,Modelo de Dados a ser utilizado para a gravação dos dados.
@Return	logico	Resultado do comando Commit
@since		30/01/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740ECmt(oModel)

Local lRet			:= .T.
Local oMdlTV7R	:= oModel:GetModel("TV7RDETAIL")
Local oMdlTV7I	:= oModel:GetModel("TV7IDETAIL")
Local nI			:= 0
Local nOperation	:= oModel:GetOperation()
Local cMsg			:= ""
Local lCommit		:= .T.
Local lValNumRev	:= .T.

//Atualização do Grid de Recursos Humanos
For nI:=1 To oMdlTV7R:Length()

	oMdlTV7R:GoLine(nI)

	If !oMdlTV7R:IsDeleted() .and. !Empty(oMdlTV7R:GetValue('TV7_IDENT'))
		oMdlTV7R:SetValue( "TV7_GRUPO", "1" )
	EndIf

Next nI

//Atualização do Grid de Impostos
For nI:=1 To oMdlTV7I:Length()

	oMdlTV7I:GoLine(nI)

	If !oMdlTV7I:IsDeleted() .and. !Empty(oMdlTV7I:GetValue('TV7_IDENT'))
		oMdlTV7I:SetValue( "TV7_GRUPO", "2" )
	EndIf

Next nI

// Efetua a gravação do model
If lRet .and. lCommit
	lRet := FwFormCommit( oModel )
EndIf


Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ECpy
	 Realiza a chamada para copia do registro posicionado no oBrowse.
@Return	logico	Resultado da chamada para copia de Tabela de Precificação.
@sample	At740ECpy()
@since		02/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740ECpy()
Local lRet		:= .F.
Local cNoTab	:= TV6->TV6_NUMERO
Local cNoRev	:= TV6->TV6_REVISA
Local cMsg		:= STR0019 + " [" + cNoTab + "/" + cNoRev + "]?" // "Confirma a geração de uma cópia da [Tabela/Revisão]"

If MsgYesNo(cMsg)
	MsgRun( STR0020, STR0018, {|| lRet := At740ECTP()} ) // "Efetuando Cópia de Tabela de Precificação."#"Processando"
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ECTP
	 Realiza uma copia do registro posicionado no oBrowse.
@Return	logico	Resultado da copia de Tabela de Precificação.
@sample	At740ECTP()
@since		02/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740ECTP()
Local lRet			:= .T.
Local aArea		:= GetArea()
Local oSourceMdl	:= nil
Local oTargetMdl	:= nil

DbSelectArea('TV6')
TV6->(DbSetOrder(1)) // TV6_FILIAL+TV6_NUMERO

If TV6->( DbSeek( xFilial('TV6') + TV6->TV6_NUMERO + TV6->TV6_REVISA ) )
	// Origem dos Dados
	oSourceMdl := FwLoadModel('TECA740E')
	oSourceMdl:SetOperation( MODEL_OPERATION_UPDATE )
	// Destino dos Dados
	oTargetMdl := FwLoadModel('TECA740E')
	oTargetMdl:SetOperation( MODEL_OPERATION_INSERT )

	If oSourceMdl:Activate() .And. oTargetMdl:Activate()
		// Cabeçalho da Tabela de Precificação
		lRet := At740ECDM(oSourceMdl,oTargetMdl,"TV6MASTER",{"TV6_CODIGO","TV6_NUMERO","TV6_REVISA"},{{"TV6_STATUS","1"}})

		// Detalhe - Recursos Humanos
		If lRet
			lRet := At740ECDM(oSourceMdl,oTargetMdl,"TV7RDETAIL",{"TV7_CODIGO","TV7_CODTAB"})
		EndIf

		// Detalhe - Impostos
		If lRet
			lRet := At740ECDM(oSourceMdl,oTargetMdl,"TV7IDETAIL",{"TV7_CODIGO","TV7_CODTAB"})
		EndIf

		// Valida todas as informações
		If (lRet := oTargetMdl:VldData())
			// Grava as informações
			lRet := At740eCmt(oTargetMdl)
		Endif

		If !lRet
			// Rollback das informações do objeto
			oTargetMdl:CancelData()
		EndIf

		oSourceMdl:DeActivate() ; oSourceMdl:Destroy()
		oTargetMdl:DeActivate() ; oTargetMdl:Destroy()
	EndIf
EndIf

RestArea(aArea)
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ERev
	 Efetua uma cópia de revisão.

@sample	At740ERev(oModel)
@param		[oModel],objeto,Objeto representando o registro atual na Tabela de Precificação.
@Return	logico	Resultado da Criação da Revisão de Tabela de Precificação
@since		04/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740ERev(oModel)
Local lRet			:= .T.
Local oTargetMdl	:= nil
Local cNewRev		:= ""

// Destino dos Dados
oTargetMdl := FwLoadModel('TECA740E')
oTargetMdl:SetOperation( MODEL_OPERATION_INSERT )

If oTargetMdl:Activate()

	// Pesquisa por um novo numero de revisão
	lRet := !Empty(cNewRev := At740EGNR(oModel))

	// Cabeçalho da Tabela de Precificação
	If lRet
		lRet := At740ECDM(oModel,oTargetMdl,"TV6MASTER",{"TV6_CODIGO","TV6_REVISA"},{{"TV6_REVISA",cNewRev}})
	EndIf

	// Detalhe - Recursos Humanos
	If lRet
		lRet := At740ECDM(oModel,oTargetMdl,"TV7RDETAIL",{"TV7_CODIGO","TV7_CODTAB"})
	EndIf

	// Detalhe - Impostos
	If lRet
		lRet := At740ECDM(oModel,oTargetMdl,"TV7IDETAIL",{"TV7_CODIGO","TV7_CODTAB"})
	EndIf

	// Valida todas as informações
	If (lRet := oTargetMdl:VldData())
		// Grava as informações
		lRet := At740ECmt(oTargetMdl)
	Endif

	If !lRet
		// Rollback das informações do objeto
		oTargetMdl:CancelData()
	EndIf

	oTargetMdl:DeActivate()
	oTargetMdl:Destroy()

EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ECDM
	 Efetua uma cópia entre objetos oModel (Origem -> Destino).

@sample	At740ECDM(oSourceMdl,oTargetMdl,cIDDataSet,aFieldsExc,aFieldsAlt)
@param		[oSourceMDL],objeto,Identificador da origem dos dados.
@param		[oTargetNDL],objeto,Identificador do destino dos dados.
@param		[cIDDataSet],caracter,Identificador do Modelo de dados.
@param		[aFieldsExc],array,Array simples com a Lista de Campos que não serão copiados.
@param		[aFieldsAlt],array,Array multidimencional com a Lista de Campos e valores que serão alterados.
@Return	logico	Resultado da Cópia entre objetos oModel.
@since		04/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Static Function At740ECDM(oSourceMdl,oTargetMdl,cIDDataSet,aFieldsExc,aFieldsAlt)
Local lRet			:= .T.
Local nI			:= 0
Local nJ			:= 0
Local oDataSetS	:= nil
Local oDataSetT	:= nil

Default oSourceMdl	:= nil
Default oTargetMdl	:= nil
Default cIDDataSet	:= ""
Default aFieldsExc	:= {}
Default aFieldsAlt	:= {}

If !Empty(cIDDataSet) .and. !Empty(oSourceMdl) .and. !Empty(oTargetMdl)
	oDataSetS	:= oSourceMdl:GetModel(cIDDataSet)	// Origem
	oDataSetT	:= oTargetMdl:GetModel(cIDDataSet)	// Destino

	If "MASTER" $ cIDDataSet		// FIELD
		lRet := AtCpyData(oDataSetS, oDataSetT, aFieldsExc)
		For nJ := 1 To Len(aFieldsAlt)
			oDataSetT:SetValue(aFieldsAlt[nJ][1],aFieldsAlt[nJ][2])
		Next
	Else							// GRID
		For nI := 1 To oDataSetS:Length()
			oDataSetS:GoLine(nI)
			// Não considera registros deletados.
			If oDataSetS:IsDeleted() .or. Empty(oDataSetS:GetValue('TV7_GRUPO'))
				Loop
			EndIf

			If oDataSetT:Length() < nI
				 oDataSetT:AddLine()
			EndIf

			If !(lRet := AtCpyData(oDataSetS, oDataSetT, aFieldsExc))
				Exit
			EndIf

			// Aplica a Lista de campos e seus valores.
			For nJ := 1 To Len(aFieldsAlt)
				oDataSetT:SetValue(aFieldsAlt[nJ][1],aFieldsAlt[nJ][2])
			Next
		Next nI
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740EGNR
	 Executa uma consulta (SQL) da última revisão de uma tabela de precificação.

@sample	At740EGNR(oModel,lNoSum)
@param		[oModel],objeto,Modelo de Dados
@param		[lNoSum],logico,Se verdadeiro não executa SOMA1() ao resultado.
@Return	caracter	Código representando a revisão, atual ou próximo, de uma especifica Tabela de Precificação.
@since		04/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Static Function At740EGNR(oModel,lNoSum)
Local cRet			:= Space( TamSX3("TV6_REVISA")[1] )
Local cAliasQRY	:= GetNextAlias()
Local cFil			:= oModel:GetModel("TV6MASTER"):GetValue("TV6_FILIAL")
Local cNumero		:= oModel:GetModel("TV6MASTER"):GetValue("TV6_NUMERO")

Default lNoSum	:= .F.

BeginSql alias cAliasQRY
		SELECT MAX(TV6_REVISA) AS TV6_REVISA
		FROM %table:TV6% TV6
		WHERE
			    TV6.TV6_FILIAL = %exp:cfil%
			AND TV6.TV6_NUMERO = %exp:cNumero%
			AND TV6.%notDel%
EndSql

If lNoSum
	cRet := (cAliasQRY)->TV6_REVISA
Else
	cRet := Soma1((cAliasQRY)->TV6_REVISA)
EndIf

(cAliasQRY)->(dbCloseArea())
Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ECTB
	 Executa uma consulta (SQL) pela existência de algum vínculo da tabela de precificação com os Orçamentos.

@sample	At740ECTB(oModel)
@param		[oModel],objeto,Modelo de Dados
@Return	logico	Representando ou não a existência de vínculo da tabela com um ou mais orçamentos.
@since		06/03/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Static Function At740ECTB(oModel)
Local lRet			:= .F.
Local cAliasQRY	:= GetNextAlias()
Local cCodTab		:= oModel:GetModel("TV6MASTER"):GetValue("TV6_NUMERO")
Local cRevisa		:= oModel:GetModel("TV6MASTER"):GetValue("TV6_REVISA")
Local cFilTFJ		:= xFilial('TFJ')

BeginSql alias cAliasQRY
		SELECT Count(TFJ_FILIAL) AS CONT
		FROM %table:TFJ% TFJ
		WHERE
			    TFJ.TFJ_FILIAL = %exp:cFilTFJ%
			AND TFJ.TFJ_CODTAB = %exp:cCodTab%
			AND TFJ.TFJ_TABREV = %exp:cRevisa%
			AND TFJ.%notDel%
EndSql

lRet := ((cAliasQRY)->CONT > 0)

(cAliasQRY)->(dbCloseArea())
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740EVld
	 Efetua pré validações para permitir a ação de alteração da Tabela de Precificação atual.

@sample	At740EVld()
@Return	logico	Pré validação da ação de Alteração do Modelo de Dados (Tabela de Precificação).
@since		04/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740EVld( )
Local lRet		:= .T.
Local cCDTPB	:= StrZero(0,TamSX3("TV6_NUMERO")[1])	// Código da Tabela de Precificação Padrão

// Status 1 - Ativo ; 2 - Inativo
lRet := (TV6->TV6_STATUS == "1") .AND. (TV6->TV6_NUMERO <> cCDTPB)

If lRet
	FWExecView("ALTERAR","VIEWDEF.TECA740E",MODEL_OPERATION_UPDATE,;
		/*oDlg*/,{||.T.} /*bCloseOk*/,{||.T.} /*bOk*/,/*nPercRed*/,/*aButtons*/,{||.T.} /*bCancel*/)
Else
	Help(,,STR0021,, STR0022 + ' [' + cCDTPB + '] ' + STR0023, 1, 0) // 'Operação Inválida'#'Tabela Inativa não pode ser alterada.'
EndIf

Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740EPreV
	 Verifica a existência do registro referente a Tabela de Precificação Padrão.
	 Se não existir faz a chamada para a criação do registro.

@sample	At740EPreV()
@Return	nil Nehum Retorno
@since		04/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Static Function At740EPreV()

Local cAliasQry	:= GetNextAlias()
Local aArea		:= GetArea()
Local cNoTabPad	:= StrZero(0,TamSX3("TV6_NUMERO")[1])

BeginSql alias cAliasQRY
		SELECT COUNT(TV6_NUMERO) AS CONT
		FROM %table:TV6% TV6
		WHERE
			    TV6.TV6_FILIAL = %xFilial:TV6%
			AND TV6.TV6_NUMERO = %exp:cNoTabPad%
			AND TV6.%notDel%
EndSql
If	! (cAliasQRY)->(Eof()) .AND. ((cAliasQRY)->CONT == 0)
	MsgRun(STR0024, STR0018,{|| At740ETPB()} )	//"Gerando Tabela de Precificação Padrão"#"Processando"
EndIf
(cAliasQry)->(dbCloseArea())
RestArea(aArea)
Return( nil )


//------------------------------------------------------------------------------
/*/{Protheus.doc} At740ETPB()
	 Inclui a Tabela Padrão de Precificação.
	 Se não existir cria o registro.

@sample	At740ETPB()
@Return	nil Nenhum retorno
@since		04/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Static Function At740ETPB()
Local oModelTPB	:= nil
Local oDSMaster	:= nil
Local oDSGridRH	:= nil
Local oDSGridImp	:= nil
Local aRecTPB		:= At740EGTP()	// Retorna a Estrutura de Dados para a Tabela de Precificação Padrão
Local nI			:= 0
Local nLinesI		:= 0
Local nLinesR		:= 0
Local nOrdImp		:= 0
Local nOrdRH		:= 0
Local cAba			:= ""

// Destino dos Dados
oModelTPB := FwLoadModel('TECA740E')
oModelTPB:SetOperation( MODEL_OPERATION_INSERT )

If oModelTPB:Activate()

	// Cabeçalho da Tabela de Precificação
	oDSMaster	:= oModelTPB:GetModel("TV6MASTER")
	oDSMaster:SetValue("TV6_NUMERO",StrZero(0,TamSX3("TV6_NUMERO")[1]))
	oDSMaster:SetValue("TV6_DESC","TABELA PADRÃO")
	oDSMaster:SetValue("TV6_STATUS","1")

	// Detalhes da Tabela de Precificação
	oDSGridRH	:= oModelTPB:GetModel("TV7RDETAIL")
	oDSGridImp	:= oModelTPB:GetModel("TV7IDETAIL")

	cAba := aRecTPB[1][tpbABA]
	For nI := 1 To Len(aRecTPB)
		If AllTrim(Upper(aRecTPB[nI][tpbABA])) == "IMPOSTOS"

			If oDSGridImp:Length() < ++nLinesI
				 oDSGridImp:AddLine()
			EndIf
			oDSGridImp:GoLine(nLinesI)

			oDSGridImp:SetValue("TV7_FILIAL",XFilial("TV7"))
			oDSGridImp:SetValue("TV7_GRUPO","2")	// Informação é gravada na função At740ECmt()
			oDSGridImp:SetValue("TV7_ORDEM",StrZero(++nOrdImp,TamSX3("TV7_ORDEM")[1]))
			oDSGridImp:SetValue("TV7_IDENT",aRecTPB[nI][tpbIDENTIFICACAO])
			oDSGridImp:SetValue("TV7_TITULO",aRecTPB[nI][tpbTITULO])
			oDSGridImp:SetValue("TV7_DESC",aRecTPB[nI][tpbDESCRICAO])
			oDSGridImp:SetValue("TV7_MODO",aRecTPB[nI][tpbMODO])
			oDSGridImp:SetValue("TV7_TAM",aRecTPB[nI][tpbTAMANHO])
			oDSGridImp:SetValue("TV7_DEC",aRecTPB[nI][tpbDECIMAL])
			oDSGridImp:SetValue("TV7_EDICAO",aRecTPB[nI][tpbEDICAO])
			oDSGridImp:SetValue("TV7_VALID",aRecTPB[nI][tpbVALIDACAO])
			oDSGridImp:SetValue("TV7_INIT",aRecTPB[nI][tpbINICIALIZADOR])
			oDSGridImp:SetValue("TV7_FORM",aRecTPB[nI][tpbFORMULA])

		Else

			If oDSGridRH:Length() < ++nLinesR
				 oDSGridRH:AddLine()
			EndIf
			oDSGridRH:GoLine(nLinesR)

			nOrdRH := If( cAba <> aRecTPB[nI][tpbABA], 1, ++nOrdRH )
			cAba := aRecTPB[nI][tpbABA]

			oDSGridRH:SetValue("TV7_FILIAL",XFilial("TV7"))
			oDSGridRH:SetValue("TV7_GRUPO","1")	// Informação é gravada na função At740ECmt()
			oDSGridRH:SetValue("TV7_ORDEM",StrZero(nOrdRH,TamSX3("TV7_ORDEM")[1]))
			oDSGridRH:SetValue("TV7_ABA",aRecTPB[nI][tpbABA])
			oDSGridRH:SetValue("TV7_IDENT",aRecTPB[nI][tpbIDENTIFICACAO])
			oDSGridRH:SetValue("TV7_TITULO",aRecTPB[nI][tpbTITULO])
			oDSGridRH:SetValue("TV7_DESC",aRecTPB[nI][tpbDESCRICAO])
			oDSGridRH:SetValue("TV7_MODO",aRecTPB[nI][tpbMODO])
			oDSGridRH:SetValue("TV7_TAM",aRecTPB[nI][tpbTAMANHO])
			oDSGridRH:SetValue("TV7_DEC",aRecTPB[nI][tpbDECIMAL])
			oDSGridRH:SetValue("TV7_EDICAO",aRecTPB[nI][tpbEDICAO])
			oDSGridRH:SetValue("TV7_VALID",aRecTPB[nI][tpbVALIDACAO])
			oDSGridRH:SetValue("TV7_INIT",aRecTPB[nI][tpbINICIALIZADOR])
			oDSGridRH:SetValue("TV7_FORM",aRecTPB[nI][tpbFORMULA])

		EndIf
	Next nI

	// Valida todas as informações
	If (lRet := oModelTPB:VldData())
		// Grava as informações
		lRet := At740ECmt(oModelTPB)
	Endif

	If !lRet
		// Rollback das informações do objeto
		oModelTPB:CancelData()
	EndIf

	oModelTPB:DeActivate() ; oModelTPB:Destroy()
EndIf

Return( nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740EGTP
	 Estrutura da tabela de precificação Padrão
@sample	At740EGTP()
			//Definição das Posições retornadas pela função At740EGTP()
			#Define tpbABA					1
			#Define tpbIDENTIFICACAO		2
			#Define tpbTITULO				3
			#Define tpbDESCRICAO			4
			#Define tpbMODO				5
			#DEFINE tpbTAMANHO			6
			#DEFINE tpbDECIMAL			7
			#Define tpbEDICAO				8
			#Define tpbFORMULA			9
			#Define tpbVALIDACAO			10
			#Define tpbINICIALIZADOR		11
			#Define tpbCONTEUDO			12
@Return	array	Estrutura de Dados da tabela Padrão.
@since		04/02/2015
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function At740EGTP()
Local aTabPrcf	:= {}

AAdd( aTabPrcf, {'Remuneração     ','VLR_SAL    ','SALARIO     ','SALÁRIO                                                           ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','SAL_FUNCAO                                  ','Salário do funcionário                                                                                       '})
AAdd( aTabPrcf, {'Remuneração     ','DET_SLB    ','% INSALUBR  ','INSALUBRIDADE (MÍNIMA, MÉDIA E MÁXIMA)                            ','2','','','1','                                                                                                                                                              ','                                                              ','1=10%;2=20%;3=40%                           ','Escolher a partir de uma tabela os % de insalubridade                                                        '})
AAdd( aTabPrcf, {'Remuneração     ','VLR_SLB    ','$ INSALUBR  ','VLR INSALUBRIDADE                                                 ','1',12, 2,'2','=(VLR_SAL * (IF(DET_SLB=1;0,1;IF(DET_SLB=2;0,2;IF(DET_SLB=3;0,4;0)))))                                                                                        ','                                                              ','                                            ','Cálculo da insalubridade baseado no percentual sobre o salário                                               '})
AAdd( aTabPrcf, {'Remuneração     ','DET_PER    ','%PERICULOSID','PERICULOSIDADE                                                    ','2','','','1','                                                                                                                                                              ','                                                              ','S=Sim;N=Não                                 ','Escolher sim ou não (Se sim aplica 30%)                                                                      '})
AAdd( aTabPrcf, {'Remuneração     ','VLR_PER    ','$PERICULOSID','VLR PERICULOSIDADE                                                ','1',12, 2,'2','=IF(DET_PER="N";0; (VLR_SAL * 0,3))                                                                                                                           ','                                                              ','                                            ','Cálculo da periculosidade baseado no percentual sobre o salário                                              '})
AAdd( aTabPrcf, {'Remuneração     ','QTD_HME    ','CARGA HORA  ','CARGA HORÁRIA                                                     ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Carga horária mensal do funcionário                                                                          '})
AAdd( aTabPrcf, {'Remuneração     ','CRG_HDIA   ','CARGA HR DIA','CARGA HORÁRIA DIÁRIA                                              ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','8                                           ','Carga horária diária do atendente                                                                            '})
AAdd( aTabPrcf, {'Remuneração     ','VLR_HME    ','VALOR HORA  ','VALOR HORA                                                        ','1',12, 2,'2','=(VLR_SAL/IF(QTD_HME=0;1;QTD_HME))                                                                                                                            ','                                                              ','                                            ','Valor hora da carga horária                                                                                  '})
AAdd( aTabPrcf, {'Remuneração     ','PER_HRE1   ','% HR EXTRA 1','% HORA EXTRA 1                                                    ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','50                                          ','Percentual de cobrança na hora extra 1 do atendente                                                          '})
AAdd( aTabPrcf, {'Remuneração     ','QTD_HRE1   ','QT HR EXT 1 ','QTD HORA EXTRA 1                                                  ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Quantidade de horas extras 1                                                                                 '})
AAdd( aTabPrcf, {'Remuneração     ','VLR_HRE1   ','VL HR EXT 1 ','VALOR HORA EXTRA 1                                                ','1',12, 2,'2','=(VLR_HME + ( VLR_HME * (PER_HRE1/100) )) * QTD_HRE1                                                                                                          ','                                                              ','                                            ','Cálculo do valor das horas extras 1                                                                          '})
AAdd( aTabPrcf, {'Remuneração     ','PER_HRE2   ','% HR EXTRA 2','% HORA EXTRA 2                                                    ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','100                                         ','Percentual de cobrança na hora extra 2 do atendente                                                          '})
AAdd( aTabPrcf, {'Remuneração     ','QTD_HRE2   ','QT HR EXT 2 ','QTD HORA EXTRA 2                                                  ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Quantidade de horas extras 2                                                                                 '})
AAdd( aTabPrcf, {'Remuneração     ','VLR_HRE2   ','VL HR EXT 2 ','VALOR HORA EXTRA 2                                                ','1',12, 2,'2','=(VLR_HME + ( VLR_HME * (PER_HRE2/100) )) * QTD_HRE2                                                                                                          ','                                                              ','                                            ','Cálculo do valor das horas extras 2                                                                          '})
AAdd( aTabPrcf, {'Remuneração     ','PER_ADN    ','% ADIC NOTUR','% ADICIONAL NOTURNO                                               ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','20                                          ','Percentual do adicional noturno                                                                              '})
AAdd( aTabPrcf, {'Remuneração     ','HOR_ADN    ','HR ADIC NOT ','HORAS ADIC. NOTURNO                                               ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Quantidade de horas de adicional noturno                                                                     '})
AAdd( aTabPrcf, {'Remuneração     ','VLR_ADN    ','VL ADIC NOT ','ADICIONAL NOTURNO                                                 ','1',12, 2,'2','=( VLR_HME * PER_ADN ) * HOR_ADN                                                                                                                              ','                                                              ','                                            ','Cálculo do valor das horas de adicional noturno                                                              '})
AAdd( aTabPrcf, {'Remuneração     ','VLR_DSR    ','DSR         ','DSR                                                               ','1',12, 2,'2','=(((VLR_HRE1 + VLR_HRE2 + VLR_ADN ) / 22) * 8)                                                                                                                ','                                                              ','                                            ','Cálculo DSR sobre as horas extras e adicionais                                                               '})
AAdd( aTabPrcf, {'Remuneração     ','VLR_IAJ    ','INTRAJORNADA','INTRAJORNADA                                                      ','1',12, 2,'2','=(VLR_HME * 1,5)                                                                                                                                              ','                                                              ','                                            ','Cálculo do valor intrajornada                                                                                '})
AAdd( aTabPrcf, {'Remuneração     ','PER_GRT    ','% GRATIFIC  ','% GRATIFICAÇÃO                                                    ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Percentual de gratificação para o atendente                                                                  '})
AAdd( aTabPrcf, {'Remuneração     ','VLR_GRT    ','GRATIFICAÇÃO','GRATIFICAÇÃO                                                      ','1',12, 2,'2','=(VLR_SAL * (PER_GRT/100))                                                                                                                                    ','                                                              ','                                            ','Cálculo da gratificação baseado no percentual sobre o salário                                                '})
AAdd( aTabPrcf, {'Remuneração     ','QTD_D444   ','QT DIAS S444','QTDE DE DIAS SÚMULA 444 TST                                       ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Quantidade de dias para a SÚMULA 444 TST                                                                     '})
AAdd( aTabPrcf, {'Remuneração     ','VLR_444    ','VL S444 TST ','VALOR SÚMULA 444 TST                                              ','1',12, 2,'2','=(VLR_HME * CRG_HDIA) * QTD_D444                                                                                                                              ','                                                              ','                                            ','Cálculo do valor a ser aplicado pela SÚMULA 444 TST                                                          '})
AAdd( aTabPrcf, {'Remuneração     ','QTD_IEJ    ','HR INTERJON ','HORAS INTERJONADA                                                 ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Quantidade de horas a serem cobradas na interjornada                                                         '})
AAdd( aTabPrcf, {'Remuneração     ','VLR_IEJ    ','VL INTERJON ','VALOR INTERJONADA                                                 ','1',12, 2,'2','=(VLR_HME * 1,5) * QTD_IEJ                                                                                                                                    ','                                                              ','                                            ','Cálculo do valor de interjornada a ser cobrado                                                               '})
AAdd( aTabPrcf, {'Remuneração     ','QTD_HMS    ','QT HR S/AVIS','QTDE HORAS SOBRE-AVISO MENSAL                                     ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Quantidade de horas de sobre-aviso no mês                                                                    '})
AAdd( aTabPrcf, {'Remuneração     ','VLR_HMS    ','VL S/AVISO  ','VALOR SOBRE-AVISO                                                 ','1',12, 2,'2','=(VLR_HME / 3) * QTD_HMS                                                                                                                                      ','                                                              ','                                            ','Cálculo para o valor do sobre-aviso                                                                          '})
AAdd( aTabPrcf, {'Remuneração     ','PER_RES    ','%RESERVA TEC','%RESERVA TÉCNICA                                                  ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','0,05                                        ','Percentual de reserva técnica                                                                                '})
AAdd( aTabPrcf, {'Remuneração     ','VLR_RES    ','$RESERVA TEC','RESERVA TÉCNICA                                                   ','1',12, 2,'2','=(VLR_SAL * (PER_RES/100))                                                                                                                                    ','                                                              ','                                            ','Cálculo da reserva técnica baseado no percentual sobre o salário                                             '})
AAdd( aTabPrcf, {'Remuneração     ','TOT_REM    ','TOT REMUNER ','TOTAL REMUNERAÇÃO                                                 ','1',12, 2,'2','=(VLR_SAL + VLR_SLB + VLR_PER + VLR_HRE1 + VLR_HRE2 + VLR_ADN + VLR_DSR + VLR_IAJ + VLR_GRT + VLR_444 + VLR_IEJ + VLR_RES)                                    ','                                                              ','                                            ','Fórmula de cálculo de todos os campos relevantes para a remuneração                                          '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_INSS   ','% INSS      ','% INSS                                                            ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','20                                          ','Percentual de INSS a ser aplicado                                                                            '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_INSS   ','$ INSS      ','INSS                                                              ','1',12, 2,'2','=(TOT_REM * (PER_INSS /100))                                                                                                                                  ','                                                              ','                                            ','Cálculo do percentual de INSS sobre a remuneração                                                            '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_SESI   ','% SESI/SESC ','% SESI OU SESC                                                    ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','1,5                                         ','Percentual de SESI ou SESC a ser aplicado                                                                    '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_SESI   ','$ SESI/SESC ','SESI OU SESC                                                      ','1',12, 2,'2','=(TOT_REM * (PER_SESI / 100))                                                                                                                                 ','                                                              ','                                            ','Cálculo do percentual de SESI ou SESC sobre a remuneração                                                    '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_SENAI  ','%SENAI/SENAC','% SENAI OU SENAC                                                  ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','1                                           ','Percentual de SENAI ou SENAC a ser aplicado                                                                  '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_SENAI  ','$SENAI/SENAC','SENAI OU SENAC                                                    ','1',12, 2,'2','=(TOT_REM * (PER_SENAI / 100))                                                                                                                                ','                                                              ','                                            ','Cálculo do percentual de SENAI ou SENAC sobre a remuneração                                                  '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_INCRA  ','% INCRA     ','% INCRA                                                           ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','0,2                                         ','Percentual de INCRA a ser aplicado                                                                           '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_INCRA  ','$ INCRA     ','INCRA                                                             ','1',12, 2,'2','=(TOT_REM * (PER_INCRA / 100))                                                                                                                                ','                                                              ','                                            ','Cálculo do percentual do INCRA sobre a remuneração                                                           '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_SLE    ','% SAL EDUC  ','% SALÁRIO-EDUCAÇÃO                                                ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','2,5                                         ','Percentual de salário-educação a ser aplicado                                                                '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_SLE    ','$ SAL EDUC  ','SALÁRIO-EDUCAÇÃO                                                  ','1',12, 2,'2','=(TOT_REM * ( PER_SLE / 100 ) )                                                                                                                               ','                                                              ','                                            ','Cálculo do percentual de salário-educação sobre a remuneração                                                '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_FGTS   ','% FGTS      ','% FGTS                                                            ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','8                                           ','Percentual de FGTS a ser aplicado                                                                            '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_FGTS   ','$ FGTS      ','FGTS                                                              ','1',12, 2,'2','=(TOT_REM * ( PER_FGTS / 100 ) )                                                                                                                              ','                                                              ','                                            ','Cálculo do percentual de FGTS sobre a remuneração                                                            '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_SAT    ','% SAT/INSS  ','% SEGURO ACIDENTE DE TRABALHO/SAT/INSS                            ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','3                                           ','Percentual de seguro acidente de trabalho/SAT/INSS a ser aplicado                                            '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_SAT    ','$ SAT/INSS  ','SEGURO ACIDENTE DE TRABALHO/SAT/INSS                              ','1',12, 2,'2','=(TOT_REM * ( PER_SAT / 100 ) )                                                                                                                               ','                                                              ','                                            ','Cálculo do percentual de seguro acidente de trabalho/SAT/INSS sobre a remuneração                            '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_SBR    ','% SEBRAE    ','% SEBRAE                                                          ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','0,6                                         ','Percentual de SEBRAE a ser aplicado                                                                          '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_SBR    ','$ SEBRAE    ','SEBRAE                                                            ','1',12, 2,'2','=(TOT_REM * ( PER_SBR / 100 ) )                                                                                                                               ','                                                              ','                                            ','Cálculo do percentual de SEBRAE sobre a remuneração                                                          '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_CSD    ','% CONTR SIND','% CONTRIBUIÇÃO SINDICAL                                           ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','0                                           ','Percentual de contribuição sindical a ser aplicado                                                           '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_CSD    ','$ CONTR SIND','CONTRIBUIÇÃO SINDICAL                                             ','1',12, 2,'2','=(TOT_REM * ( PER_CSD / 100 ) )                                                                                                                               ','                                                              ','                                            ','Cálculo do percentual de contribuição sindical sobre a remuneração                                           '})
AAdd( aTabPrcf, {'Encargos Sociais','TPE_GRA    ','% T GRUPO A ','% TOTAL GRUPO A                                                   ','1',12, 2,'2','=(PER_INSS + PER_SESI + PER_SENAI + PER_INCRA + PER_SLE + PER_FGTS + PER_SAT + PER_SBR + PER_CSD)                                                             ','                                                              ','                                            ','Fórmula de cálculo de todos os campos de percentual relevantes para o Grupo A                                '})
AAdd( aTabPrcf, {'Encargos Sociais','TOT_GRA    ','$ T GRUPO A ','TOTAL GRUPO A                                                     ','1',12, 2,'2','=(VLR_INSS + VLR_SESI + VLR_SENAI + VLR_INCRA + VLR_SLE + VLR_FGTS + VLR_SAT + VLR_SBR + VLR_CSD)                                                             ','                                                              ','                                            ','Fórmula de cálculo de todos os campos relevantes para o Grupo A                                              '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_FER    ','% FÉRIAS    ','% FÉRIAS                                                          ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','12,52                                       ','Percentual de férias a ser aplicado                                                                          '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_FER    ','$ FÉRIAS    ','FÉRIAS                                                            ','1',12, 2,'2','=(TOT_REM * ( PER_FER / 100 ) )                                                                                                                               ','                                                              ','                                            ','Cálculo do percentual de férias sobre a remuneração                                                          '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_FTL    ','% FALTAS LEG','% FALTAS LEGAIS                                                   ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','0,28                                        ','Percentual de faltas legais a ser aplicado                                                                   '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_FTL    ','$ FALTAS LEG','FALTAS LEGAIS                                                     ','1',12, 2,'2','=(TOT_REM * ( PER_FTL / 100 ) )                                                                                                                               ','                                                              ','                                            ','Cálculo do percentual de faltas legais sobre a remuneração                                                   '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_ASD    ','% AUS DOENÇA','% AUSÊNCIA POR DOENÇA                                             ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','2,25                                        ','Percentual de ausência por doença a ser aplicado                                                             '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_ASD    ','$ AUS DOENÇA','AUSÊNCIA POR DOENÇA                                               ','1',12, 2,'2','=(TOT_REM * ( PER_ASD / 100 ) )                                                                                                                               ','                                                              ','                                            ','Cálculo do percentual de ausência por doença sobre a remuneração                                             '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_LPM    ','% LC PAT/MAT','% LICENÇA PATERNIDADE / MATERNIDADE                               ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','0,02                                        ','Percentual de licença paternidade / maternidade a ser aplicado                                               '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_LPM    ','$ LC PAT/MAT','LICENÇA PATERNIDADE / MATERNIDADE                                 ','1',12, 2,'2','=(TOT_REM * ( PER_LPM / 100 ) )                                                                                                                               ','                                                              ','                                            ','Cálculo do percentual de licença paternidade / maternidade sobre a remuneração                               '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_ACT    ','% ACID TRAB ','% ACIDENTE DE TRABALHO                                            ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','0,33                                        ','Percentual de acidente de trabalho a ser aplicado                                                            '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_ACT    ','$ ACID TRAB ','ACIDENTE DE TRABALHO                                              ','1',12, 2,'2','=(TOT_REM * ( PER_ACT / 100 ) )                                                                                                                               ','                                                              ','                                            ','Cálculo do percentual de acidente de trabalho sobre a remuneração                                            '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_AVP    ','% AV PR TRAB','% AVISO PRÉVIO TRABALHADO                                         ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','0,15                                        ','Percentual de aviso prévio trabalhado a ser aplicado                                                         '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_AVP    ','$ AV PR TRAB','AVISO PRÉVIO TRABALHADO                                           ','1',12, 2,'2','=(TOT_REM * ( PER_AVP / 100 ) )                                                                                                                               ','                                                              ','                                            ','Cálculo do percentual de aviso prévio trabalhado sobre a remuneração                                         '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_AXD    ','% AUX DOENÇA','% AUXÍLIO-DOENÇA                                                  ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','2,55                                        ','Percentual de auxílio-doença a ser aplicado                                                                  '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_AXD    ','$ AUX DOENÇA','AUXÍLIO-DOENÇA                                                    ','1',12, 2,'2','=(TOT_REM * ( PER_AXD / 100 ) )                                                                                                                               ','                                                              ','                                            ','Cálculo do percentual de auxílio-doença sobre a remuneração                                                  '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_TRE    ','% TREINAMEN ','% TREINAMENTO                                                     ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','0                                           ','Percentual de treinamento a ser aplicado                                                                     '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_TRE    ','$ TREINAMEN ','TREINAMENTO                                                       ','1',12, 2,'2','=(TOT_REM * ( PER_TRE / 100 ) )                                                                                                                               ','                                                              ','                                            ','Cálculo do percentual de treinamento sobre a remuneração                                                     '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_SIND   ','% REPR SIND ','% REPRES. SINDICAL                                                ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','0                                           ','Percentual de repres. sindical a ser aplicado                                                                '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_SIND   ','$ REPR SIND ','REPRES. SINDICAL                                                  ','1',12, 2,'2','=(TOT_REM * ( PER_SIND / 100 ) )                                                                                                                              ','                                                              ','                                            ','Cálculo do percentual de repres. sindical sobre a remuneração                                                '})
AAdd( aTabPrcf, {'Encargos Sociais','TPE_GRB    ','% T GRUPO B ','% TOTAL GRUPO B                                                   ','1',12, 2,'2','=(PER_FER + PER_FTL + PER_ASD + PER_LPM + PER_ACT + PER_AVP + PER_AXD + PER_TRE + PER_SIND)                                                                   ','                                                              ','                                            ','Fórmula de cálculo de todos os campos de percentual relevantes para o Grupo B                                '})
AAdd( aTabPrcf, {'Encargos Sociais','TOT_GRB    ','$ T GRUPO B ','TOTAL GRUPO B                                                     ','1',12, 2,'2','=(VLR_FER + VLR_FTL + VLR_ASD + VLR_LPM + VLR_ACT + VLR_AVP + VLR_AXD + VLR_TRE + VLR_SIND)                                                                   ','                                                              ','                                            ','Fórmula de cálculo de todos os campos relevantes para o Grupo B                                              '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_A13F   ','% AD 1/3 FÉR','% ADICIONAL DE 1/3 DE FÉRIAS                                      ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','3,01                                        ','Percentual de adicional de 1/3 de férias a ser aplicado                                                      '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_A13F   ','$ AD 1/3 FÉR','ADICIONAL DE 1/3 DE FÉRIAS                                        ','1',12, 2,'2','=( TOT_REM * ( PER_A13F / 100 ) )                                                                                                                             ','                                                              ','                                            ','Cálculo do percentual de adicional de 1/3 de férias sobre a remuneração                                      '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_S13    ','% 13 SALARIO','% 13 SALÁRIO                                                      ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','9,17                                        ','Percentual de 13 salário a ser aplicado                                                                      '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_S13    ','$ 13 SALARIO','13 SALÁRIO                                                        ','1',12, 2,'2','=( TOT_REM * ( PER_S13 / 100 ) )                                                                                                                              ','                                                              ','                                            ','Cálculo do percentual de 13 salário sobre a remuneração                                                      '})
AAdd( aTabPrcf, {'Encargos Sociais','TPE_GRC    ','% T GRUPO C ','% TOTAL GRUPO C                                                   ','1',12, 2,'2','=( PER_A13F + PER_S13 )                                                                                                                                       ','                                                              ','                                            ','Fórmula de cálculo de todos os campos de percentual relevantes para o Grupo C                                '})
AAdd( aTabPrcf, {'Encargos Sociais','TOT_GRC    ','$ T GRUPO C ','TOTAL GRUPO C                                                     ','1',12, 2,'2','=( VLR_A13F + VLR_S13 )                                                                                                                                       ','                                                              ','                                            ','Fórmula de cálculo de todos os campos relevantes para o Grupo C                                              '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_API    ','% AV PRV IND','% AVISO PRÉVIO INDENIZADO                                         ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','5,75                                        ','Percentual de aviso prévio indenizado a ser aplicado                                                         '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_API    ','$ AV PRV IND','AVISO PRÉVIO INDENIZADO                                           ','1',12, 2,'2','=(TOT_REM * ( PER_API / 100 ) )                                                                                                                               ','                                                              ','                                            ','Cálculo do percentual de aviso prévio indenizado sobre a remuneração                                         '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_IDA    ','% INDEN ADIC','% INDENIZAÇÃO ADICIONAL                                           ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','0,15                                        ','Percentual de indenização adicional a ser aplicado                                                           '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_IDA    ','$ INDEN ADIC','INDENIZAÇÃO ADICIONAL                                             ','1',12, 2,'2','=(TOT_REM * ( PER_IDA / 100 ) )                                                                                                                               ','                                                              ','                                            ','Cálculo do percentual de indenização adicional sobre a remuneração                                           '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_IFGTS  ','%FGTx(AP+IA)','% FGTS x (AVISO PRÉVIO + INDENIZAÇÃO ADICIONAL)                   ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','0,58                                        ','Percentual de FGTS x (aviso prévio + indenização adicional) a ser aplicado                                   '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_IFGTS  ','$FGTx(AP+IA)','FGTS x (AVISO PRÉVIO + INDENIZAÇÃO ADICIONAL)                     ','1',12, 2,'2','=(TOT_REM * ( PER_IFGTS / 100 ) )                                                                                                                             ','                                                              ','                                            ','Cálculo do percentual de FGTS x (aviso prévio + indenização adicional) sobre a remuneração                   '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_RSJC   ','% RESC S/JC ','% RESCISÃO SEM JUSTA CAUSA                                        ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','4                                           ','Percentual de rescisão sem justa causa a ser aplicado                                                        '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_RSJC   ','$ RESC S/JC ','RESCISÃO SEM JUSTA CAUSA                                          ','1',12, 2,'2','=(TOT_REM * ( PER_RSJC / 100 ) )                                                                                                                              ','                                                              ','                                            ','Cálculo do percentual de rescisão sem justa causa sobre a remuneração                                        '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_MFGTS  ','% MULTA FGTS','% MULTA DO FGTS                                                   ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','0                                           ','Percentual de multa do FGTS a ser aplicado                                                                   '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_MFGTS  ','$ MULTA FGTS','MULTA DO FGTS                                                     ','1',12, 2,'2','=(TOT_REM * ( PER_MFGTS / 100 ) )                                                                                                                             ','                                                              ','                                            ','Cálculo do percentual de multa do FGTS sobre a remuneração                                                   '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_ICSD   ','% CONTRB SOC','% CONTRIBUIÇÃO SOCIAL                                             ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','0                                           ','Percentual de contribuição social a ser aplicado                                                             '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_ICSD   ','$ CONTRB SOC','CONTRIBUIÇÃO SOCIAL                                               ','1',12, 2,'2','=(TOT_REM * ( PER_ICSD / 100 ) )                                                                                                                              ','                                                              ','                                            ','Cálculo do percentual de contribuição social sobre a remuneração                                             '})
AAdd( aTabPrcf, {'Encargos Sociais','TPE_GRD    ','% T GRUPO D ','% TOTAL GRUPO D                                                   ','1',12, 2,'2','=( PER_API + PER_IDA + PER_IFGTS + PER_RSJC + PER_MFGTS + PER_ICSD )                                                                                          ','                                                              ','10,48                                       ','Fórmula de cálculo de todos os campos de percentual relevantes para o Grupo D                                '})
AAdd( aTabPrcf, {'Encargos Sociais','TOT_GRD    ','$ T GRUPO D ','TOTAL GRUPO D                                                     ','1',12, 2,'2','=( VLR_API + VLR_IDA + VLR_IFGTS + VLR_RSJC + VLR_MFGTS + VLR_ICSD)                                                                                           ','                                                              ','                                            ','Fórmula de cálculo de todos os campos relevantes para o Grupo D                                              '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_FSLM   ','% PRV F S/LM','% APROVISIONAMENTO DE FÉRIAS SOBRE LICENÇA MATERNIDADE            ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','0,02                                        ','Percentual de aprovisionamento de férias sobre licença maternidade a ser aplicado                            '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_FSLM   ','$ PRV F S/LM','APROVISIONAMENTO DE FÉRIAS SOBRE LICENÇA MATERNIDADE              ','1',12, 2,'2','=(TOT_REM * ( PER_FSLM / 100 ) )                                                                                                                              ','                                                              ','                                            ','Cálculo do percentual de aprovisionamento de férias sobre licença maternidade sobre a remuneração            '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_13FSLM ','% 1/3 F S/LM','% APROVISIONAMENTO 1/3 CONSTITUCIONAL FÉRIAS S/LICENÇA MATERNIDADE','1',12, 2,'2','                                                                                                                                                              ','                                                              ','0,01                                        ','Percentual de aprovisionamento 1/3 constitucional férias s/licença maternidade a ser aplicado                '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_13FSLM ','$ 1/3 F S/LM','APROVISIONAMENTO 1/3 CONSTITUCIONAL FÉRIAS S/LICENÇA MATERNIDADE  ','1',12, 2,'2','=(TOT_REM * ( PER_13FSLM / 100 ) )                                                                                                                            ','                                                              ','                                            ','Cálculo do percentual de aprovisionamento 1/3 constitucional férias s/licença maternidade sobre a remuneração'})
AAdd( aTabPrcf, {'Encargos Sociais','PER_INAXLC ','% INC A S/LM','% INCIDÊNCIA DO GRUPO ""A"" SOBRE GRUPO LICENÇA MATERNIDADE       ','1',12, 2,'2','=((TPE_GRA / 100) * 0,23) + ((TPE_GRA / 100) * (PER_FSLM/100)) + ((TPE_GRA / 100) * (PER_13FSLM / 100))                                                       ','                                                              ','                                            ','Percentual de incidência do Grupo ""A"" sobre o Grupo LICENÇA MATERNIDADE a ser aplicado                     '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_INAXLC ','$ INC A S/LM','INCIDÊNCIA DO GRUPO ""A"" SOBRE GRUPO LICENÇA MATERNIDADE         ','1',12, 2,'2','=(TOT_REM * ( PER_INAXLC / 100 ))                                                                                                                             ','                                                              ','                                            ','Cálculo do percentual de incidência do Grupo ""A"" sobre o Grupo LICENÇA MATERNIDADE sobre a remuneração     '})
AAdd( aTabPrcf, {'Encargos Sociais','TPE_GRE    ','% T GRUPO E ','% TOTAL GRUPO E                                                   ','1',12, 2,'2','=( PER_FSLM + PER_13FSLM + PER_INAXLC )                                                                                                                       ','                                                              ','                                            ','Fórmula de cálculo de todos os campos de percentual relevantes para o Grupo E                                '})
AAdd( aTabPrcf, {'Encargos Sociais','TOT_GRE    ','$ T GRUPO E ','TOTAL GRUPO E                                                     ','1',12, 2,'2','=( VLR_FSLM + VLR_13FSLM + VLR_INAXLC )                                                                                                                       ','                                                              ','                                            ','Fórmula de cálculo de todos os campos relevantes para o Grupo E                                              '})
AAdd( aTabPrcf, {'Encargos Sociais','VLR_INAXBC ','$A X (B + C)','INCIDÊNCIA DO GRUPO ""A"" X (GRUPO ""B"" + ""C"")                 ','1',12, 2,'2','=((TOT_GRB + TOT_GRC) * (TPE_GRA/100))                                                                                                                        ','                                                              ','                                            ','Fórmula de cálculo para conseguir definir o valor da soma dos campos relevantes dos Grupos A sobre (B+C)     '})
AAdd( aTabPrcf, {'Encargos Sociais','PER_INAXBC ','%A X (B + C)','% INCIDÊNCIA DO GRUPO ""A"" X (GRUPO ""B"" + ""C"")               ','1',12, 2,'2','=((VLR_INAXBC * 100) / IF(TOT_REM=0;1;TOT_REM))                                                                                                               ','                                                              ','                                            ','Fórmula de cálculo para conseguir definir o percentual dos campos relevantes dos Grupos A sobre (B+C)        '})
AAdd( aTabPrcf, {'Encargos Sociais','TPE_GRF    ','% T GRUPO F ','% TOTAL GRUPO F                                                   ','1',12, 2,'2','=PER_INAXBC                                                                                                                                                   ','                                                              ','                                            ','Fórmula de cálculo de todos os campos de percentual relevantes para o Grupo F                                '})
AAdd( aTabPrcf, {'Encargos Sociais','TOT_GRF    ','$ T GRUPO F ','TOTAL GRUPO F                                                     ','1',12, 2,'2','=VLR_INAXBC                                                                                                                                                   ','                                                              ','                                            ','Fórmula de cálculo de todos os campos relevantes para o Grupo F                                              '})
AAdd( aTabPrcf, {'Encargos Sociais','TOT_SOC    ','T ENCARG SOC','TOTAL DOS ENCARGOS SOCIAIS                                        ','1',12, 2,'2','=( TOT_GRA + TOT_GRB + TOT_GRC + TOT_GRD + TOT_GRE + TOT_GRF )                                                                                                ','                                                              ','                                            ','Fórmula de cálculo para considerar campos relevantes para o valor total dos encargos sociais                 '})
AAdd( aTabPrcf, {'Encargos Sociais','TOT_RRES   ','REM+RT+ENCSO','TOTAL DO MONTANTE (REMUNERAÇÃO + RES. TEC.+ VLR ENCARGOS SOCIAIS) ','1',12, 2,'2','=( TOT_GRA + TOT_GRB + TOT_GRC + TOT_GRD + TOT_GRE + TOT_GRF + TOT_REM )                                                                                      ','                                                              ','                                            ','Fórmula de cálculo para considerar campos relevantes para o valor total da remuneração somando os encargos   '})
AAdd( aTabPrcf, {'Beneficios      ','VLU_VT     ','$ UNIT VL TR','VALOR UNITÁRIO VALE TRANSPORTE                                    ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor unitário do vale transporte a ser definido                                                             '})
AAdd( aTabPrcf, {'Beneficios      ','QTD_VT     ','QT VL TRANSP','QUANTIDADE VALE TRANSPORTE                                        ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Quantidade de vale transporte a ser definido                                                                 '})
AAdd( aTabPrcf, {'Beneficios      ','PER_VT     ','% D VL TRANS','% DESCONTO VALE TRANSPORTE                                        ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','6                                           ','Percentual de desconto do vale transporte na folha de pagamento                                              '})
AAdd( aTabPrcf, {'Beneficios      ','DSC_VT     ','$ D VL TRANS','DESCONTO VALE TRANSPORTE                                          ','1',12, 2,'2','=((TOT_REM)*((PER_VT)/100))                                                                                                                                   ','                                                              ','                                            ','Fórmula para cálculo do valor de desconto do vale tranporte na folha de pagamento                            '})
AAdd( aTabPrcf, {'Beneficios      ','TOT_VT     ','TT VL TRANSP','TOTAL VALE TRANSPORTE                                             ','1',12, 2,'2','=IF( ( VLU_VT * QTD_VT ) <= DSC_VT ; 0 ; ( VLU_VT * QTD_VT ) - DSC_VT )                                                                                       ','                                                              ','                                            ','Fórmula para cálculo do valor total do vale transporte a ser cobrado no contrato                             '})
AAdd( aTabPrcf, {'Beneficios      ','VLR_REF    ','$ UNIT REF  ','VALOR UNITÁRIO REFEIÇÃO                                           ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor unitário do vale refeição a ser definido                                                               '})
AAdd( aTabPrcf, {'Beneficios      ','QTD_REF    ','QT REFEIÇÕES','QUANTIDADE REFEIÇÕES                                              ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Quantidade de refeições a ser definido                                                                       '})
AAdd( aTabPrcf, {'Beneficios      ','PER_REF    ','% DESC REF  ','% DESCONTO REFEIÇÃO                                               ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','20                                          ','Percentual de desconto do vale refeição na folha de pagamento                                                '})
AAdd( aTabPrcf, {'Beneficios      ','DSC_REF    ','$ DESC REF  ','DESCONTO REFEIÇÃO                                                 ','1',12, 2,'2','=((TOT_REM)*((PER_REF)/100))                                                                                                                                  ','                                                              ','                                            ','Fórmula para cálculo do valor de desconto do vale refeição na folha de pagamento                             '})
AAdd( aTabPrcf, {'Beneficios      ','TOT_REF    ','TOT REFEIÇÃO','TOTAL REFEIÇÃO                                                    ','1',12, 2,'2','=IF( (VLR_REF * QTD_REF) <= DSC_REF ; 0 ; (VLR_REF * QTD_REF) - DSC_REF )                                                                                     ','                                                              ','                                            ','Fórmula para cálculo do valor total da refeição a ser cobrado no contrato                                    '})
AAdd( aTabPrcf, {'Beneficios      ','VLR_ALIM   ','VLR ALIMENT ','VALOR ALIMENTAÇÃO                                                 ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor do vale alimentação a ser definido                                                                     '})
AAdd( aTabPrcf, {'Beneficios      ','PER_ALIM   ','% DESC ALIM ','% DESCONTO ALIMENTAÇÃO                                            ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','20                                          ','Percentual de desconto do vale alimentação na folha de pagamento                                             '})
AAdd( aTabPrcf, {'Beneficios      ','DSC_ALIM   ','DESC ALIMENT','DESCONTO ALIMENTAÇÃO                                              ','1',12, 2,'2','=((TOT_REM)*((PER_ALIM)/100))                                                                                                                                 ','                                                              ','                                            ','Fórmula para cálculo do valor de desconto do vale alimentação na folha de pagamento                          '})
AAdd( aTabPrcf, {'Beneficios      ','TOT_ALIM   ','TT ALIMENT  ','TOTAL ALIMENTAÇÃO                                                 ','1',12, 2,'2','=IF( VLR_ALIM <= DSC_ALIM ; 0 ; VLR_ALIM - DSC_ALIM )                                                                                                         ','                                                              ','                                            ','Fórmula para cálculo do valor total da alimentação a ser cobrado no contrato                                 '})
AAdd( aTabPrcf, {'Beneficios      ','VLR_BCSD   ','$ CONTR SIND','VALOR CONTRIBUIÇÃO SINDICAL                                       ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor da contribuição sindical a ser cobrada no contrato                                                     '})
AAdd( aTabPrcf, {'Beneficios      ','VLR_PLS    ','$ PLN SAUDE ','VALOR PLANO SAÚDE                                                 ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor do plano de saúde a ser definido                                                                       '})
AAdd( aTabPrcf, {'Beneficios      ','PER_PLS    ','% DSC PL SD ','% DESCONTO PLANO SAÚDE                                            ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','10                                          ','Percentual de desconto do plano de saúde na folha de pagamento                                               '})
AAdd( aTabPrcf, {'Beneficios      ','TOT_PLS    ','TT PLN SAUDE','TOTAL PLANO SAÚDE                                                 ','1',12, 2,'2','=IF( VLR_PLS <= (VLR_PLS*((PER_PLS)/100)) ; 0 ; VLR_PLS - (VLR_PLS*((PER_PLS)/100)) )                                                                         ','                                                              ','                                            ','Fórmula para cálculo do valor total do plano de saúde a ser cobrado no contrato                              '})
AAdd( aTabPrcf, {'Beneficios      ','VLR_ODN    ','$ PLANO ODON','VALOR PLANO ODONTOLÓGICO                                          ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor do plano de saúde a ser definido                                                                       '})
AAdd( aTabPrcf, {'Beneficios      ','PER_ODN    ','% DSC PL ODN','% DESCONTO PLANO ODONTOLOGIA                                      ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','10                                          ','Percentual de desconto do plano de saúde na folha de pagamento                                               '})
AAdd( aTabPrcf, {'Beneficios      ','TOT_ODN    ','$ PLANO ODON','TOTAL PLANO ODONTOLOGIA                                           ','1',12, 2,'2','=IF( VLR_ODN <= ( VLR_ODN * ( PER_ODN / 100 ) ) ; 0 ; VLR_ODN - ( VLR_ODN * ( PER_ODN / 100 ) ) )                                                             ','                                                              ','                                            ','Fórmula para cálculo do valor total do plano de saúde a ser cobrado no contrato                              '})
AAdd( aTabPrcf, {'Beneficios      ','VLR_PPR    ','$ PPR / PLR ','VALOR PPR / PLR                                                   ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor do PPR a ser definido                                                                                  '})
AAdd( aTabPrcf, {'Beneficios      ','VLR_SGV    ','$ SEG VIDA  ','VALOR SEGURO DE VIDA                                              ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor do seguro de vida a ser definido                                                                       '})
AAdd( aTabPrcf, {'Beneficios      ','VLR_CEB    ','$ CESTA BAS ','VALOR CESTA BÁSICA                                                ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor do cesta básica a ser definido                                                                         '})
AAdd( aTabPrcf, {'Beneficios      ','VLR_FISC   ','FISC/TREIN  ','FISCALIZAÇÃO / TREINAMENTO                                        ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor do fiscalização / treinamento a ser definido                                                           '})
AAdd( aTabPrcf, {'Beneficios      ','VLR_BASS   ','BENEF ASSIST','BENEFÍCIO ASSISTENCIAL                                            ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor do benefício assistencial a ser definido                                                               '})
AAdd( aTabPrcf, {'Beneficios      ','VLR_AFUN   ','AUX FUNERAL ','AUXÍLIO-FUNERAL                                                   ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor do auxílio-funeral a ser definido                                                                      '})
AAdd( aTabPrcf, {'Beneficios      ','VLR_ACRE   ','AUX CRECHE  ','AUXÍLIO-CRECHE                                                    ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor do auxílio-creche a ser definido                                                                       '})
AAdd( aTabPrcf, {'Beneficios      ','VLR_ALEITE ','AUX LENTE   ','AUXÍLIO-LENTE                                                     ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor do auxílio-lente a ser definido                                                                        '})
AAdd( aTabPrcf, {'Beneficios      ','VLR_CFM    ','CAFÉ MANHÃ  ','CAFÉ DA MANHÃ                                                     ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','                                            ','Valor do café da manhã a ser definido                                                                        '})
AAdd( aTabPrcf, {'Beneficios      ','TOT_BENEF  ','TOT  BENEFIC','TOTAL DE BENEFÍCIOS                                               ','1',12, 2,'2','=(TOT_VT + TOT_REF + TOT_ALIM + VLR_BCSD + TOT_PLS + TOT_ODN + VLR_PPR + VLR_SGV + VLR_CEB + VLR_FISC + VLR_BASS + VLR_AFUN + VLR_ACRE + VLR_ALEITE + VLR_CFM)','                                                              ','                                            ','Fórmula de cálculo de todos os campos relevantes para a totalização de todos os benefícios                   '})
AAdd( aTabPrcf, {'Beneficios      ','TOTAL_RH   ','TOTAL RH    ','TOTAL RH.(CAMPO OBRIGATÓRIO, SEU VALOR CORRESPONDE AO TOTAL GERAL)','1',12, 2,'2','=(TOT_RRES + TOT_BENEF)                                                                                                                                       ','                                                              ','                                            ','Fórmula de cálculo de todos os campos relevantes para a totalização de todos os benefícios                   '})
AAdd( aTabPrcf, {'Impostos        ','IMP_TIP    ','TP LUCRO CLC','TIPO DO LICRO A SER CALCULADO                                     ','2','','','1','                                                                                                                                                              ','                                                              ','1=Presumido;2=Real                          ','Tipo do imposto a ser calculado (Presumido ou Real)                                                          '})

// BASE DE CÁLCULO LUCRO REAL
AAdd( aTabPrcf, {'Impostos        ','IMP_BLUCREA','BAS LCR REAL','BASE PARA CALCULO DE IMPOSTOS - LUCRO REAL                        ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','BLR_FUNCAO                                  ','Valor de base do cálculo do imposto - Lucro Real                                                             '})
// BASE DE CÁLCULO LUCRO PRESUMIDO
AAdd( aTabPrcf, {'Impostos        ','IMP_BLUCPRS','BAS LCR PRSM','BASE PARA CALCULO DE IMPOSTOS - LUCRO PRESUMIDO                   ','1',12, 2,'2','                                                                                                                                                              ','                                                              ','BLP_FUNCAO                                  ','Valor de base do cálculo do imposto - Lucro Presumido                                                        '})

// Porcentagens ISS - PIS - BASES LUCRO REAL e LUCRO PRESUMIDO
AAdd( aTabPrcf, {'Impostos        ','IMP_PISS   ','% ISS       ','% ISS                                                             ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','5                                           ','Percentual de imposto de ISS                                                                                 '})
AAdd( aTabPrcf, {'Impostos        ','IMP_PPIS   ','% PIS       ','% PIS                                                             ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','1,65                                        ','Percentual de imposto de PIS                                                                                 '})

// Porcentagens IR - COFINS - CSLL - BASE LUCRO REAL
AAdd( aTabPrcf, {'Impostos        ','IMP_PIRPJLR','% IRPJ    LR','% IRPJ - LUCRO REAL                                               ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','15                                          ','Percentual de imposto de IRPJ                                                                                '})
AAdd( aTabPrcf, {'Impostos        ','IMP_PCOFLR ','% COFINS  LR','% COFINS - LUCRO REAL                                             ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','7,60                                        ','Percentual de imposto de COFINS                                                                              '})
AAdd( aTabPrcf, {'Impostos        ','IMP_PCSLLLR','% CSLL    LR','% CSLL - LUCRO REAL                                               ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','9                                           ','Percentual de imposto de CSLL                                                                                '})

// Valores IR - COFINS - CSLL - BASE LUCRO REAL
AAdd( aTabPrcf, {'Impostos        ','IMP_VIRPJLR','VLR IRPJ  LR','VALOR IRPJ - LUCRO REAL                                           ','1',12, 2,'2','=(IMP_BLUCREA * (IMP_PIRPJLR / 100 ) )                                                                                                                        ','                                                              ','                                            ','Cálculo de imposto de IRPJ                                                                                   '})
AAdd( aTabPrcf, {'Impostos        ','IMP_VCOFLR ','VLR COF   LR','VALOR COFINS - LUCRO REAL                                         ','1',12, 2,'2','=(IMP_BLUCREA * (IMP_PCOFLR / 100 ) )                                                                                                                         ','                                                              ','                                            ','Cálculo de imposto de COFINS                                                                                 '})
AAdd( aTabPrcf, {'Impostos        ','IMP_VCSLLLR','VLR CSLL  LR','VALOR CSLL - LUCRO REAL                                           ','1',12, 2,'2','=(IMP_BLUCREA * (IMP_PCSLLLR / 100 ) )                                                                                                                        ','                                                              ','                                            ','Cálculo de imposto de CSLL                                                                                   '})

// Valores ISS - PIS - BASE LUCRO REAL
AAdd( aTabPrcf, {'Impostos        ','IMP_VISSLR ','VLR ISS   LR','VALOR ISS - LUCRO REAL                                            ','1',12, 2,'2','=(IMP_BLUCREA * (IMP_PISS / 100 ) )                                                                                                                           ','                                                              ','                                            ','Cálculo de imposto de ISS                                                                                    '})
AAdd( aTabPrcf, {'Impostos        ','IMP_VPISLR ','VLR PIS   LR','VALOR PIS - LUCRO REAL                                            ','1',12, 2,'2','=(IMP_BLUCREA * (IMP_PPIS / 100 ) )                                                                                                                           ','                                                              ','                                            ','Cálculo de imposto de PIS                                                                                    '})

// Porcentagens IR - COFINS - CSLL - BASE LUCRO PRESUMIDO
AAdd( aTabPrcf, {'Impostos        ','IMP_PIRPJLP','% IRPJ    LP','% IRPJ - LUCRO PRESUMIDO                                          ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','4,80                                        ','Percentual de imposto de IRPJ                                                                                '})
AAdd( aTabPrcf, {'Impostos        ','IMP_PCOFLP ','% COFINS  LP','% COFINS - LUCRO PRESUMIDO                                        ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','3                                           ','Percentual de imposto de COFINS                                                                              '})
AAdd( aTabPrcf, {'Impostos        ','IMP_PCSLLLP','% CSLL    LP','% CSLL - LUCRO PRESUMIDO                                          ','1',12, 2,'1','                                                                                                                                                              ','                                                              ','2,88                                        ','Percentual de imposto de CSLL                                                                                '})

// Valores IR - COFINS - CSLL - BASE LUCRO PRESUMIDO
AAdd( aTabPrcf, {'Impostos        ','IMP_VIRPJLP','VLR IRPJ  LP','VALOR IRPJ - LUCRO PRESUMIDO                                      ','1',12, 2,'2','=(IMP_BLUCPRS * (IMP_PIRPJLP / 100 ) )                                                                                                                        ','                                                              ','                                            ','Cálculo de imposto de IRPJ                                                                                   '})
AAdd( aTabPrcf, {'Impostos        ','IMP_VCOFLP ','VLR COF   LP','VALOR COFINS - LUCRO PRESUMIDO                                    ','1',12, 2,'2','=(IMP_BLUCPRS * (IMP_PCOFLP / 100 ) )                                                                                                                         ','                                                              ','                                            ','Cálculo de imposto de COFINS                                                                                 '})
AAdd( aTabPrcf, {'Impostos        ','IMP_VCSLLLP','VLR CSLL  LP','VALOR CSLL - LUCRO PRESUMIDO                                      ','1',12, 2,'2','=(IMP_BLUCPRS * (IMP_PCSLLLP / 100 ) )                                                                                                                        ','                                                              ','                                            ','Cálculo de imposto de CSLL                                                                                   '})

// Valores ISS - PIS - BASE LUCRO PRESUMIDO
AAdd( aTabPrcf, {'Impostos        ','IMP_VISSLP ','VLR ISS   LP','VALOR ISS - LUCRO PRESUMIDO                                       ','1',12, 2,'2','=(IMP_BLUCPRS * (IMP_PISS / 100 ) )                                                                                                                           ','                                                              ','                                            ','Cálculo de imposto de ISS                                                                                    '})
AAdd( aTabPrcf, {'Impostos        ','IMP_VPISLP ','VLR PIS   LP','VALOR PIS - LUCRO PRESUMIDO                                       ','1',12, 2,'2','=(IMP_BLUCPRS * (IMP_PPIS / 100 ) )                                                                                                                           ','                                                              ','                                            ','Cálculo de imposto de PIS                                                                                    '})

// Porcentagens totais - BASE LUCRO REAL
AAdd( aTabPrcf, {'Impostos        ','TOT_PIMPLR ','% TOT IMP LR','% TOTAL DE IMPOSTOS - LUCRO REAL                                  ','1',12, 2,'2','=(IMP_PISS   + IMP_PIRPJLR + IMP_PCOFLR + IMP_PCSLLLR + IMP_PPIS  )                                                                                           ','                                                              ','                                            ','Total de percentual de impostos                                                                              '})
AAdd( aTabPrcf, {'Impostos        ','TOT_VIMPLR ','$ TOT IMP LR','TOTAL DE IMPOSTOS - LUCRO REAL                                    ','1',12, 2,'2','=(IMP_VISSLR + IMP_VIRPJLR + IMP_VCOFLR + IMP_VCSLLLR + IMP_VPISLR)                                                                                           ','                                                              ','                                            ','Total de valor dos impostos                                                                                  '})

// Porcentagens totais - BASE LUCRO PRESUMIDO
AAdd( aTabPrcf, {'Impostos        ','TOT_PIMPLP ','% TOT IMP LP','% TOTAL DE IMPOSTOS - LUCRO PRESUMIDO                             ','1',12, 2,'2','=(IMP_PISS   + IMP_PIRPJLP + IMP_PCOFLP + IMP_PCSLLLP + IMP_PPIS  )                                                                                           ','                                                              ','                                            ','Total de percentual de impostos                                                                              '})
AAdd( aTabPrcf, {'Impostos        ','TOT_VIMPLP ','$ TOT IMP LP','TOTAL DE IMPOSTOS - LUCRO PRESUMIDO                               ','1',12, 2,'2','=(IMP_VISSLP + IMP_VIRPJLP + IMP_VCOFLP + IMP_VCSLLLP + IMP_VPISLP)                                                                                           ','                                                              ','                                            ','Total de valor dos impostos                                                                                  '})

AAdd( aTabPrcf, {'Impostos        ','TOT_PIMP   ','% TOT IMP   ','% TOTAL DE IMPOSTOS                                               ','1',12, 2,'2','=IF(IMP_TIP=1;TOT_PIMPLP;TOT_PIMPLR)                                                                                                                          ','                                                              ','                                            ','Total de percentual de impostos                                                                              '})
AAdd( aTabPrcf, {'Impostos        ','TOT_VIMP   ','$ TOT IMP   ','TOTAL DE IMPOSTOS                                                 ','1',12, 2,'2','=IF(IMP_TIP=1;TOT_VIMPLP;TOT_VIMPLR)                                                                                                                          ','                                                              ','                                            ','Total de valor dos impostos                                                                                  '})


Return AClone(aTabPrcf)


//-------------------------------------------------------------------
 /*{Protheus.doc} At740ELTP
	 Constroi um array com a estrutura de campos de uma tabela de precificação especifica.

@sample	At740ELTP(cNumTab,cRevisao)
@param		[cNumTab],caractere,Número da Tabela de Precificação
@param		[cRevisao],caractere,Código da Revisão da Tabela de Precificação
@Return	array	Estrutura representando os itens da tabela de precificação
@since		11/02/2015
@version	P12

/*/
//------------------------------------------------------------------------------
Function At740ELTP(cNumTab,cRevisao)
Local aAux			:= {}
Local aArea		:= GetArea()
Local oSourceMdl	:= nil
Local oDataSetS	:= nil
Local nI			:= 0
Local nJ			:= 0
Local nId			:= 0// Numerador Único para os dois grupos: RH e Impostos
Local nId2			:= 0// Numerador Único para os dois grupos: RH e Impostos
Local nTam			:= 0
Local nDec			:= 0
Local uInit		:= ''
Local cRet			:= ''
Local uValue		:= NIl
Local cPicture	:= ""
Local cXml			:= ""
Local aSaveRows := {}
Local nLinTOTRH := 0
Local nLinTOTIMP := 0
Local lCalcTot := .F.
Private aTabPrec	:= {}


Default cNumTab	:= TV6->TV6_NUMERO
Default cRevisao	:= TV6->TV6_REVISA

If !Empty(cNumTab)
	DbSelectArea('TV6')
	TV6->(DbSetOrder(1)) // TV6_FILIAL+TV6_NUMERO+TV6_REVISA

	If TV6->( DbSeek( xFilial('TV6') + cNumTab + cRevisao ) )
		// Origem dos Dados
		oSourceMdl := FwLoadModel('TECA740E')
		oSourceMdl:SetOperation( MODEL_OPERATION_UPDATE )

		If oSourceMdl:Activate()

			For nJ := 1 To 2	// Duas interações: Grid Recursos Humanos e Grid Impostos

				If nJ == 1
					oDataSetS	:= oSourceMdl:GetModel('TV7RDETAIL')	// Recursos Humanos

					cXml += '<?xml version="1.0" encoding="UTF-8"?>'
					cXml += '<FWMODELSHEET Operation="4" version="1.01">'
					cXml += '<MODEL_SHEET modeltype="FIELDS" >'

					cXml += '<TOTLINES order="1">'
					cXml += '<value>' + AllTrim(Str(oDataSetS:Length(.T.) + oSourceMdl:GetModel('TV7IDETAIL'):Length(.T.))) + '</value>'
					cXml += '</TOTLINES>'
					cXml += '<TOTCOLUMNS order="2">'
					cXml += '<value>' + AllTrim(Str(xmlCOLTOTAL)) + '</value>'
					cXml += '</TOTCOLUMNS>'

					cXml += '<MODEL_CELLS modeltype="GRID" optional="1">'

					// Seção Struct
					cXml += '<struct>'
					cXml += '<NAME order="1"/>'
					cXml += '<NICKNAME order="2"/>'
					cXml += '<FORMULA order="3"/>'
					cXml += '<VALUE order="4"/>'
					cXml += '<PICTURE order="5"/>'
					cXml += '<BLOCKCELL order="6"/>'
					cXml += '<BLOCKNAME order="7"/>'
					cXml += '</struct>'

					cXml += '<items>'
				Else
					oDataSetS	:= oSourceMdl:GetModel('TV7IDETAIL')	// Impostos
				EndIf

				For nI := 1 To oDataSetS:Length(.T.)
					oDataSetS:GoLine(nI)
					aAux := Array(xmlCOLTOTAL,xmlLINTOTAL)

					If AllTrim(oDataSetS:GetValue('TV7_IDENT')) == 'TOTAL_RH' .And. oDataSetS:GetId() == "TV7RDETAIL"
					    nLinTOTRH := oDataSetS:GetLine()
					ElseIf AllTrim(oDataSetS:GetValue('TV7_IDENT')) == 'TOT_VIMP' .And. oDataSetS:GetId() == "TV7IDETAIL"
					    nLinTOTIMP := oDataSetS:GetLine()
					Else
						nId2 := nId2 + 1
						nId := nId + 1	// Numerador Único para os dois grupos: RH e Impostos
						cXml += '<item id="' + AllTrim(Str(nId2)) + '" deleted="0" >'
						cXml += '<NAME>' + 'A' + AllTrim(Str(nId)) + '</NAME>'
						cXml += '<VALUE>' + AllTrim(oDataSetS:GetValue('TV7_DESC')) + '</VALUE>'
						cXml += '</item>'

						// Coluna Dados - Valores
						nId2 := nId2 + 1	// Numerador Único para os dois grupos: RH e Impostos
						cXml += '<item id="' + AllTrim(Str(nId2)) + '" deleted="0" >'
						cXml += '<NAME>' + 'B' + AllTrim(Str(nId)) + '</NAME>'

						If !Empty(AllTrim(oDataSetS:GetValue('TV7_IDENT')))
							cXml += '<NICKNAME>' + AllTrim(oDataSetS:GetValue('TV7_IDENT')) + '</NICKNAME>'
						EndIf

						If !Empty(AllTrim(oDataSetS:GetValue('TV7_FORM')))
							cAux := AT740ENTAG(AllTrim(oDataSetS:GetValue('TV7_FORM')))
							cXml += '<FORMULA>' + cAux + '</FORMULA>'
						EndIf

						uInit := AllTrim(oDataSetS:GetValue('TV7_INIT'))
						If !Empty(uInit)
							If At('=',uInit) > 1
								uValue	:= SubStr(uInit,1,At('=',uInit)-1)
							ElseIf At('=',uInit) == 1
								uValue	:= 1
							Else
								uValue	:= Val(StrTran(StrTran(uInit,'.',''),',','.'))
						 	EndIf
						Else
							uValue	:= '0'
						EndIf

						uValue := If(ValType(uValue)=='N',cValToChar(uValue),uValue)

						cXml += '<VALUE>' + uValue + '</VALUE>'

						If (oDataSetS:GetValue('TV7_MODO') == '1' )
							nTam := oDataSetS:GetValue('TV7_TAM')
							nDec := oDataSetS:GetValue('TV7_DEC')

							cPicture := TRANSFORM(Val(REPLICATE('9',nTam-(nDec+1)) + '.' + REPLICATE('9',nDec)),'999,999,999,999.'+REPLICATE('9',nDec))
							cPicture := '@E ' + ALLTRIM(cPicTure)

						Else
							cPicture		:= '@!'
						EndIf

						If !Empty(cPicture)
							cXml += '<PICTURE>' + cPicture + '</PICTURE>'
						EndIf

						cXml += '</item>'
					EndIf

				Next nI

				lCalcTot := .F.
				aSaveRows := FwSaveRows()
				If  nLinTOTRH > 0 .Or. nLinTOTIMP > 0
					If oDataSetS:GetId() == 'TV7RDETAIL' .And. nLinTOTRH > 0
						oDataSetS:GoLine(nLinTOTRH)
						lCalcTot := .T.
						nId2 := nId2 + 1
						nId := nId + 1	// Numerador Único para os dois grupos: RH e Impostos
					ElseIf oDataSetS:GetId() == 'TV7IDETAIL' .And. nLinTOTIMP > 0
						oDataSetS:GoLine(nLinTOTIMP)
						lCalcTot := .T.
						nId2 := nId2 + 1
						nId := nId + 1	// Numerador Único para os dois grupos: RH e Impostos
					EndIf
				EndIf

				If lCalcTot
					cXml += '<item id="' + AllTrim(Str(nId2)) + '" deleted="0" >'
					cXml += '<NAME>' + 'A' + AllTrim(Str(nId)) + '</NAME>'
					cXml += '<VALUE>' + AllTrim(oDataSetS:GetValue('TV7_DESC')) + '</VALUE>'
					cXml += '</item>'

					// Coluna Dados - Valores
					nId2 := nId2 + 1	// Numerador Único para os dois grupos: RH e Impostos
					cXml += '<item id="' + AllTrim(Str(nId2)) + '" deleted="0" >'
					cXml += '<NAME>' + 'B' + AllTrim(Str(nId)) + '</NAME>'

					If !Empty(AllTrim(oDataSetS:GetValue('TV7_IDENT')))
						cXml += '<NICKNAME>' + AllTrim(oDataSetS:GetValue('TV7_IDENT')) + '</NICKNAME>'
					EndIf

					If !Empty(AllTrim(oDataSetS:GetValue('TV7_FORM')))
						cAux := AT740ENTAG(AllTrim(oDataSetS:GetValue('TV7_FORM')))
						cXml += '<FORMULA>' + cAux + '</FORMULA>'
					EndIf

					uInit := AllTrim(oDataSetS:GetValue('TV7_INIT'))
					If !Empty(uInit)
						If At('=',uInit) > 1
							uValue	:= SubStr(uInit,1,At('=',uInit)-1)
						ElseIf At('=',uInit) == 1
							uValue	:= 1
						Else
							uValue	:= Val(StrTran(StrTran(uInit,'.',''),',','.'))
				 		EndIf
					Else
						uValue	:= '0'
					EndIf

					uValue := If(ValType(uValue)=='N',cValToChar(uValue),uValue)

					cXml += '<VALUE>' + uValue + '</VALUE>'

					If (oDataSetS:GetValue('TV7_MODO') == '1' )
						nTam := oDataSetS:GetValue('TV7_TAM')
						nDec := oDataSetS:GetValue('TV7_DEC')

						cPicture := TRANSFORM(Val(REPLICATE('9',nTam-(nDec+1)) + '.' + REPLICATE('9',nDec)),'999,999,999,999.'+REPLICATE('9',nDec))
						cPicture := '@E ' + ALLTRIM(cPicTure)

					Else
						cPicture		:= '@!'
					EndIf

					If !Empty(cPicture)
						cXml += '<PICTURE>' + cPicture + '</PICTURE>'
					EndIf

					cXml += '</item>'
				EndIf

				FwRestRows(aSaveRows)
				oDataSetS:GoLine(oDataSetS:Length())
			Next nJ


		EndIf

		oSourceMdl:DeActivate()
		oSourceMdl:Destroy()

	EndIf
	cXml += '</items>'

	cXml += '</MODEL_CELLS>'
	cXml += '</MODEL_SHEET>'
	cXml += '</FWMODELSHEET>'
EndIf

RestArea(aArea)
Return(cxml)

//-------------------------------------------------------------------
/*/{Protheus.doc} At740EGXML
	 Retorna uma string XML representando uma tabela de precificação e seus valores

@sample	At740EGXML(cNumTab,cRevisao,aValues)
@param		[cNumTab],caractere,Número da tabela de precificação referenciada.
@param		[cRevisao],caractere,Código da revisão da tabela de precificação referenciada.
@Return	caractere	String contendo a estrutura no padrão XML
@since		11/02/2015
@version	P12
/*/
//------------------------------------------------------------------------------

Function At740EGXML(cNumTab,cRevisao)
Local cRet		:= ''

Default cNumTab	:= nil
Default cRevisao	:= nil

// Adquire a estrutura de campos da tabela especificada.
cRet := At740ELTP(cNumTab,cRevisao)

Return( cRet )
//------------------------------------------------------------------------------
/*/{Protheus.doc} At740EEPC()

Executa o cálculo do modelo da planilha sem visualizar a mesma.

@sample 	At740EEPC(oFWSheet,aPrcTab,oMdlPrc,aCampos)
@param		[oFWSheet],object,Planilha de cálculo para estruturas XML.
@param		[aPrcTab],array,Variável estática com informações de todos os models instanciados.
@param		[oMdlPrc],object,Modelo de dados atual.
@param		[aCampos],array,Lista de Campos [identificadores] para atualização. Quando vazio, todos serão processados.
@since		25/02/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At740EEPC(oFWSheet,aPrcTab,oMdlPrc,aCampos, nOrigem)
Local cRet			:= ''
Local nI			:= 0
Local nJ			:= 0
Local oDataSrc		:= nil
Local cCampo		:= ""
Local cMensagem		:= ''
Local lOperation	:= (oMdlPrc:GetOperation() == MODEL_OPERATION_UPDATE) .or. (oMdlPrc:GetOperation() == MODEL_OPERATION_INSERT)
Local oModel		:= oMdlPrc:GetModel()
Local oModRH		:= oModel:GetModel('TFF_RH')
Local lNProces		:= .T.
Local lCpoProc 		:= oModRH:HasField('TFF_PROCES')
Local nVal 			:= 0
Local nPosAbaImposto := 0
Local lOFwSheet 	:= .F.
Local lAbtInss		:= TFF->( ColumnPos('TFF_ABTINS') ) > 0 .AND. SuperGetMv("MV_GSDSGCN",,"2") == "1"
Local nAbtInss		:= 0

Default aCampos		:= {}
Default nOrigem 	:= 1

If lCpoProc
	lNProces := !oModRH:GetValue('TFF_PROCES')
Else
	lNProces :=  .T.
EndIf

If !Empty(oFWSheet)
	lOFwSheet := .T.
	
	nVal := oFWSheet:GetCellValue("TOTAL_RH")
	If ValType(nVal) == "C"
		nVal := Val(nVal)
	EndIf
	
	// Obter o valor da cálcula TOTAL_ABATE_INS apenas se o campo TFF_ABTINS existir e o contrato for desagrupado
	If lAbtInss .AND. oFWSheet:CellExists("TOTAL_ABATE_INS")
		nAbtInss := oFWSheet:GetCellValue("TOTAL_ABATE_INS")
		If ValType(nAbtInss) == "C"
			nAbtInss := Val(nAbtInss)
		EndIf
	EndIf
	//Verifica tabela de preço e se ela desativou a verificação circular
	If TV6->(DbSeek(xFilial('TV6')+oModel:GetValue('TFJ_REFER','TFJ_CODTAB')+oModel:GetValue('TFJ_REFER','TFJ_TABREV') ))
		If (TV6->(ColumnPos('TV6_NCIRC')) > 0) .and. TV6->TV6_NCIRC == '1' .And. ASCAN(ClassMethArr(oFWSheet), {|x| UPPER(x[1]) == "SETEVALREFERENCE"}) > 0
			oFWSheet:SetEvalReference(.F.)
		EndIf
	EndIf
EndIf

//   Executa caso tenha ocorrido alteração na formação do preço da planilha
// ou esteja na gravação da Proposta Comercial com o modelo escondido
If lOperation .And. lOFwSheet .And. At740GSC() .And. ;
	!Empty(oMdlPrc) .And. !Empty(aPrcTab) .And. ;
	( lNProces .Or. nOrigem == 2 .Or. nVal == 0 .OR.;
		(((oModRH:GetValue('TFF_COBCTR') <> '2' .AND. !(isInCallStack("At870GerOrc"))) .OR.;
		(oModRH:GetValue('TFF_COBCTR') == '2' .AND. isInCallStack("At870GerOrc"))) .AND. oModRH:GetValue("TFF_PRCVEN") <> nVal))

	ProcRegua(0)

	// Pega o valor dos campos de todas em Abas do Modelo
	For nI := 1 To Len(aPrcTab)
		IncProc()

		// O objeto Model da Aba correspondente
		oDataSrc := oMdlPrc:GetModel(aPrcTab[nI][3][2])
		// identifica a aba de imposto para executar depois
		If !Empty( AllTrim( aPrcTab[nI][1] ) )
			// Atribui o valor de cada campo da aba atual ao objeto de calculo
			For nJ := 1 To Len(aPrcTab[nI][2])
				IncProc()
				At740eProc( aPrcTab, nI, nJ, oFWSheet, oMdlPrc, oModRH, oDataSrc, aCampos )
			Next nJ
		Else
			nPosAbaImposto := nI
		EndIf

		If lCpoProc
			oModRH:LoadValue('TFF_PROCES',.T.)
		EndIf
	Next

	nVal := oFWSheet:GetCellValue("TOTAL_RH")
	If ValType(nVal) <> "N"
		nVal := Val( nVal )
	EndIf
	nVal := Round( nVal, TamSX3("TFF_PRCVEN")[2])
 	If !(oModRH:SetValue('TFF_PRCVEN', nVal))
		If oModel:HasErrorMessage()
			AtErroMvc( oModel )
			If !(isBlind())
				MostraErro()
			EndIf
		EndIf
	EndIf
	
	// Validação para incluir o valor de abatimento do INSS apenas se o campo TFF_ABTINS existir e o contrato for desagrupado
	If lAbtInss .AND. oFWSheet:CellExists("TOTAL_ABATE_INS")
		nAbtInss := oFWSheet:GetCellValue("TOTAL_ABATE_INS")
		If ValType(nAbtInss) <> "N"
			nAbtInss := Val( nAbtInss )
		EndIf
		If !(oModRH:SetValue('TFF_ABTINS', nAbtInss))
			If oModel:HasErrorMessage()
				AtErroMvc( oModel )
				If !(isBlind())
					MostraErro()
				EndIf
			EndIf
		EndIf
	EndIf
	// Executa o preenchimento dos campos da aba de imposto
	If nPosAbaImposto > 0
		nI := nPosAbaImposto
		// O objeto Model da Aba correspondente
		oDataSrc := oMdlPrc:GetModel(aPrcTab[nI][3][2])
		For nJ := 1 To Len(aPrcTab[nI][2])
			At740eProc( aPrcTab, nI, nJ, oFWSheet, oMdlPrc, oModRH, oDataSrc, aCampos )
		Next
	EndIf
	oFWSheet:Refresh()

	// atualiza os itens com fórmulas
	For nI := 1 To Len(aPrcTab)
		IncProc()
		// O objeto Model da Aba correspondente
		oDataSrc := oMdlPrc:GetModel(aPrcTab[nI][3][2])

		For nJ := 1 To Len(aPrcTab[nI][6])
			cCampo := AllTrim(aPrcTab[nI][6][nJ][1])
			If cCampo == "TOT_VIMP"
				oDataSrc:SetValue(cCampo, oFWSheet:GetCellValue(cCampo))
			Else
				oDataSrc:LoadValue(cCampo, oFWSheet:GetCellValue(cCampo))
			EndIf
		Next
	Next

	// Extrai a estrutura no formato XML para retorno desta função.
	cRet := oFWSheet:GetXMLModel(,,,,.F.,.T.,.F.)

EndIf
Return(cRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At740EEPC()

Converte partes do texto para tags e vice e versa.

@sample 	At740EEPC(oFWSheet,aPrcTab,oMdlPrc,aCampos)
@param		[cText],caractere,Texto onde as ocorrências &><'" serão trocadas.
@since		11/03/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT740ENTAG(cTexto)
Default cTexto  := ''

If ValType(cTexto)=='C'
	cTexto := StrTran(cTexto, "&", "&amp;")
	cTexto := StrTran(cTexto, "<", "&lt;")
	cTexto := StrTran(cTexto, ">", "&gt;")
	cTexto := StrTran(cTexto, '"', "&quot;")
	cTexto := StrTran(cTexto, "'", "&#39;")
EndIf

Return cTexto


Static Function At740eProc( aPrcTab, nI, nJ, oFWSheet, oMdlPrc, oModRH, oDataSrc, aCampos )
Local cCampo := ""
Local nVal := 0
Local lContinua := .T.

cCampo := AllTrim(aPrcTab[nI][2][nJ][2])
// Filtro para trabalhar Campos especificos
If !Empty(aCampos) .and. (AScan(aCampos,{|e| AllTrim(e) == cCampo}) == 0)
	lContinua := .F.
EndIf

If lContinua
	// Se for um campo com fórmula o seu valor será calculado, portanto, não informar valor algum.
	If !Empty(aPrcTab[nI][2][nJ][9])

		If At( 'U_', aPrcTab[nI][2][nJ][9] ) > 0 .Or. (TV6->(ColumnPos('TV6_NCIRC')) > 0 .And.;
					(ASCAN(ClassDataArr(oFWSheet), {|x| UPPER(x[1]) == "LEVALREFERENCE"}) > 0 .AND. !(oFWSheet:lEvalReference)))
			// quando a fórmula possuir função de usuário realiza a reatribuição na planilha
			oFWSheet:SetCellValue(cCampo, aPrcTab[nI][2][nJ][9])
		EndIf
	// caso tenha inicializador e seja com id
	ElseIf !Empty(aPrcTab[nI][2][nJ][8]) .And. ;
		AtIsCalcId( Alltrim( aPrcTab[nI][2][nJ][8] ) )
		// busca o valor conforme o id de somatória
		nVal := AtCalcIdent( Alltrim( aPrcTab[nI][2][nJ][8] ), oMdlPrc )
		oFWSheet:SetCellValue(cCampo, nVal)
		// atualiza a interface/modelo exibido
		oDataSrc:LoadValue(cCampo, nVal)
	Else
		// Deixa a atribuição somente em caso de alteração pela estrutura interna do framework
		oFWSheet:SetCellValue(cCampo, oDataSrc:GetValue(cCampo))
	EndIf

EndIf

Return