#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA550.CH"

#DEFINE MANUT_TIPO_FALTA		'01'	//Falta
#DEFINE MANUT_TIPO_ATRASO		'02'	//Atraso
#DEFINE MANUT_TIPO_SAIDAANT		'03'	//Saída Antecipada
#DEFINE MANUT_TIPO_HORAEXTRA	'04'	//Hora Extra
#DEFINE MANUT_TIPO_CANCEL		'05'	//Cancelamento
#DEFINE MANUT_TIPO_TRANSF		'06'	//Transferência
#DEFINE MANUT_TIPO_AUSENT		'07'	//Ausência
#DEFINE MANUT_TIPO_REALOC		'08'	//Realocação
#DEFINE MANUT_TIPO_COMPEN		'09'	//Compensação

Static cAliasTmp 	:= ''	//Alias temporário com os dados da Agenda do atendente selecinado para manutenção
Static aCarga		:= {}	//Array com dados para a tela de substituição
Static cConfCtr 	:= ''	//Configuração da OS selecionada na transferência
Static nTempoIni	:= 0	//Tempo de hora extra antes do horário
Static nTempoFim	:= 0	//Tempo de hora extra após o horário
Static cTipAlcSta	:= ""  //Define o tipo da movimentação da alocação
Static lGeraMemo         //Variavel que controla se Deseja realmente gerar o memorando?
Static lGravaUnic	:= .F.
Static aCompen		:= {}
Static lPergMemo	:= .T. //Variavel que define se a pergunta do Memorando será exibida. .T. exibe(Default), .F. não exibe
//------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA550
Cadastro de manutenções da agenda.
A função deve ser acionada apenas para alteração ou exclusão de uma agenda que teve manutenção.
Para inclusão utilize a função AT550ExecView()

@sample 	TECA550( cAgenda )

@param		cAgenda	Código da agenda (ABB_CODIGO) que está sendo
						alterada. Informado quando a tela for ser usada
						para alterar ou excluir uma manutenção.

@author 	Danilo Dias
@since		21/11/2012
@version	P11.8
/*/
//------------------------------------------------------------------------------------------------------
Function TECA550( cAgenda, cAlias )

Local oBrowse	:= nil
Local cFilxFi   := IIF(IsInCallStack('TECA540'),' .AND. ABR_FILIAL = "' + xFilial('ABR') + '"','')

Default cAgenda	:= ''
Default cAlias	:= ''

Private aRotina 	:= MenuDef()	// 'Monta menu da Browse'
Private cCadastro	:= STR0001		// 'Manutenção da Agenda'

cAliasTmp := cAlias

oBrowse := FWMBrowse():New()

oBrowse:SetAlias( "ABR" )
oBrowse:SetDescription( cCadastro )
oBrowse:SetFilterDefault( "ABR_AGENDA = '" + cAgenda + "'" + cFilxFi )	//Filtra manutenções da agenda informada
oBrowse:DisableDetails()
oBrowse:Activate()	//Ativa tela principal (Browse)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AT550ExecView
Função para executar a View, quando é necessário acioná-la através
de outra rotina.
Use essa função para incluir uma nova manutenção.

@sample 	AT550ExecView( cAlias, nOpc )

@param		cAlias		Alias temporário com os dados da ABB.
						Exemplo: AT540ABBQry (TECA540)
			nOpc		Opção indicando a operação realizada.
			aAgendas	Agendas que estão sofrendo manutenção, selecionadas no TECA540.

@return	nConf		Indica se o usuário confirmou ou não a operação.
@return						0-Confirmou, 1-Cancelou

@author	Danilo Dias
@since		21/02/2013
@version	P11.8
/*/
//-------------------------------------------------------------------
Function AT550ExecView( cAlias, nOpc, aAgendas )

Local aArea	:= GetArea()
Local nConf 	:= 1		//Indica se o usuário confirmou ou não a manutenção
Local aBts 		:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0052},{.T.,STR0053},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}  // "Confirmar" ### "Fechar"

Default cAlias	:= ''
Default nOpc		:= 0
Default aAgendas 	:= {}

Private cCadastro	:= STR0001		// 'Manutenção da Agenda'

If ( cAlias == '' )
	Help( ' ', 1, 'AT550ExecView', , STR0021, 1, 0 )	//"Falha no carregamento da rotina. Alias inválido."
Else
	cAliasTmp	:= cAlias
	aCarga 		:= aAgendas
	cConfCtr 	:= ''
	nConf 		:= FwExecView( '', "VIEWDEF.TECA550", nOpc, /*oOwner*/, {||.T.}, /*bOk*/, 30, aBts )
EndIf

RestArea( aArea )

Return ( nConf )


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para montar o menu principal da rotina.

@sample 	MenuDef()

@author	Danilo Dias
@since		21/11/2012
@version	P11.8
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action "VIEWDEF.TECA550" 	OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0	//"Alterar"
ADD OPTION aRotina Title STR0003 Action "VIEWDEF.TECA550" 	OPERATION MODEL_OPERATION_DELETE 	ACCESS 0	//"Excluir"
ADD OPTION aRotina Title STR0004 Action "VIEWDEF.TECA550" 	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0	//"Visualizar"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para definir o model da rotina.

@sample 	ModelDef()

@author	Danilo Dias
@since		21/11/2012
@version	P11.80
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= nil
Local oStruABR	:= nil
Local aTrigger	:= {}
Local bCommit		:= { |oModel| AT550Commit( oModel ) }
Local bValid		:= { |oModel| AT550VldModel( oModel ) }
Local bInic		:= { |oModel| AT550Inicia( oModel ) }
Local cValid 	:= ""
Local cVldUser 	:= ""
Local bVldMotivo 	:= Nil

oModel 	:= MPFormModel():New( 'TECA550',, bValid, bCommit)
oStruABR	:= FWFormStruct( 1, 'ABR' )

aTrigger := FwStruTrigger ( 'ABR_DTINI', 'ABR_TEMPO', 'AT550Tempo()', .F., Nil, Nil, Nil )
oStruABR:AddTrigger( aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4] )
aTrigger := FwStruTrigger ( 'ABR_HRINI', 'ABR_TEMPO', 'AT550Tempo()', .F., Nil, Nil, Nil )
oStruABR:AddTrigger( aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4] )
aTrigger := FwStruTrigger ( 'ABR_DTFIM', 'ABR_TEMPO', 'AT550Tempo()', .F., Nil, Nil, Nil )
oStruABR:AddTrigger( aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4] )
aTrigger := FwStruTrigger ( 'ABR_HRFIM', 'ABR_TEMPO', 'AT550Tempo()', .F., Nil, Nil, Nil )
oStruABR:AddTrigger( aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4] )

//Altera propriedades dos campos
oStruABR:SetProperty( 'ABR_DTMAN'	, MODEL_FIELD_WHEN, 	{ || .F. } )
oStruABR:SetProperty( 'ABR_MOTIVO'	, MODEL_FIELD_WHEN, 	{ || AT550When( oModel, 'ABR_MOTIVO' ) } )
oStruABR:SetProperty( 'ABR_DTINI'	, MODEL_FIELD_WHEN, 	{ || AT550When( oModel, 'ABR_DTINI'  ) } )
oStruABR:SetProperty( 'ABR_HRINI'	, MODEL_FIELD_WHEN, 	{ || AT550When( oModel, 'ABR_HRINI'  ) } )
oStruABR:SetProperty( 'ABR_DTFIM'	, MODEL_FIELD_WHEN, 	{ || AT550When( oModel, 'ABR_DTFIM'  ) } )
oStruABR:SetProperty( 'ABR_HRFIM'	, MODEL_FIELD_WHEN, 	{ || AT550When( oModel, 'ABR_HRFIM'  ) } )
oStruABR:SetProperty( 'ABR_CODSUB'	, MODEL_FIELD_WHEN, 	{ || AT550When( oModel, 'ABR_CODSUB' ) } )
oStruABR:SetProperty( 'ABR_ITEMOS'	, MODEL_FIELD_WHEN, 	{ || AT550When( oModel, 'ABR_ITEMOS' ) } )
oStruABR:SetProperty( 'ABR_TEMPO'	, MODEL_FIELD_WHEN, 	{ || AT550When( oModel, 'ABR_TEMPO'  ) } )
oStruABR:SetProperty( 'ABR_USASER'	, MODEL_FIELD_WHEN, 	{ || AT550When( oModel, 'ABR_USASER' ) } )
oStruABR:SetProperty( 'ABR_TIPDIA'	, MODEL_FIELD_WHEN, 	{ || AT550When( oModel, 'ABR_TIPDIA' ) } )  // campo criado no projeto piloto da FT

cValid := RTrim(GetSX3Cache( "ABR_MOTIVO", "X3_VALID" )) + " .And. AT550Valid( a, b, c, d ) "
If !Empty( cVldUser := RTrim(GetSX3Cache( "ABR_MOTIVO", "X3_VLDUSER" ) ) )
	cValid += ".And. " + cVldUser
EndIf
bVldMotivo := FwBuildFeature( STRUCT_FEATURE_VALID, cValid )

oStruABR:SetProperty( 'ABR_MOTIVO'	, MODEL_FIELD_VALID,	bVldMotivo )

oStruABR:SetProperty( 'ABR_ITEMOS'	, MODEL_FIELD_VALID,	{ | oMdlVld, cCampo, xValIns, xValAnt | AT550Valid( oModel, cCampo, xValIns, xValAnt ) } )


cValid := RTrim(GetSX3Cache( "ABR_CODSUB", "X3_VALID" )) + " .And. AT550Valid( a, b, c, d ) "
If !Empty( cVldUser := RTrim(GetSX3Cache( "ABR_CODSUB", "X3_VLDUSER" ) ) )
	cValid += ".And. " + cVldUser
EndIf
bVldMotivo := FwBuildFeature( STRUCT_FEATURE_VALID, cValid )

oStruABR:SetProperty( 'ABR_CODSUB'	, MODEL_FIELD_VALID,	bVldMotivo )

// validar a edição dos horários, permitindo somente a redução e/ou aumento conforme o tipo inserido
oStruABR:SetProperty( 'ABR_DTINI'	, MODEL_FIELD_VALID,	{ | oMdlVld, cCampo, xValIns, xValAnt | FWInitCpo(oMdlVld, cCampo, xValIns, xValAnt),lRet := ValidDtHr( oMdlVld, cCampo, xValIns, xValAnt ),FWCloseCpo(oMdlVld, cCampo, xValIns,lRet,.T.),lRet } )
oStruABR:SetProperty( 'ABR_HRINI'	, MODEL_FIELD_VALID,	{ | oMdlVld, cCampo, xValIns, xValAnt | FWInitCpo(oMdlVld, cCampo, xValIns, xValAnt),lRet := ValidDtHr( oMdlVld, cCampo, xValIns, xValAnt ),FWCloseCpo(oMdlVld, cCampo, xValIns,lRet,.T.),lRet } )
oStruABR:SetProperty( 'ABR_DTFIM'	, MODEL_FIELD_VALID,	{ | oMdlVld, cCampo, xValIns, xValAnt | FWInitCpo(oMdlVld, cCampo, xValIns, xValAnt),lRet := ValidDtHr( oMdlVld, cCampo, xValIns, xValAnt ),FWCloseCpo(oMdlVld, cCampo, xValIns,lRet,.T.),lRet } )
oStruABR:SetProperty( 'ABR_HRFIM'	, MODEL_FIELD_VALID,	{ | oMdlVld, cCampo, xValIns, xValAnt | FWInitCpo(oMdlVld, cCampo, xValIns, xValAnt),lRet := ValidDtHr( oMdlVld, cCampo, xValIns, xValAnt ),FWCloseCpo(oMdlVld, cCampo, xValIns,lRet,.T.),lRet } )

oStruABR:SetProperty( 'ABR_AGENDA'	, MODEL_FIELD_OBRIGAT, .F. )	//Remove obrigatoriedade pois preenchimento é feito em tempo de execução

//Adiciona um controle do tipo formulário
oModel:AddFields( 'ABRMASTER', , oStruABR )
oModel:GetModel( 'ABRMASTER' ):SetDescription( STR0001 )

oModel:SetActivate( bInic )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para criar a visualização da rotina.

@sample 	ViewDef()

@author	Danilo Dias
@since		21/11/2012
@version	P11.8
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	 	:= nil
Local oStruABR	:= nil
Local oView		:= nil
Local cCodAtdSub 	:= ''

oModel		:= FWLoadModel( "TECA550" )	//Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
oStruABR	:= FWFormStruct( 2, "ABR" )	//Cria as estruturas a serem usadas na View
oView 		:= FWFormView():New()		//Cria o objeto de View

oStruABR:RemoveField( 'ABR_AGENDA' )
oStruABR:SetProperty( 'ABR_TEMPO', MVC_VIEW_CANCHANGE, .F.)

If (At680Perm( Nil , __cUserID, "036"))
	oStruABR:SetProperty( 'ABR_CODSUB', MVC_VIEW_CANCHANGE, .T.)
EndIf

oView:SetModel( oModel )										//Define qual Modelo de dados será utilizado
oView:AddField( "VIEW_ABR", oStruABR, "ABRMASTER" )		//Adiciona um controle do tipo formulário
oView:CreateHorizontalBox( "MASTER", 100 )				//Cria um box superior para exibir a Master
oView:SetOwnerView( "VIEW_ABR", "MASTER" )				//Relaciona o identificador (ID) da View com o "box" para exibição

oView:AddUserButton( STR0027 /*<cTitle >*/,;	//'Limpa Substituto'
                     '' /*<cResource >*/,;
                     {|oView| oModel:SetValue('ABRMASTER', 'ABR_CODSUB', ''),;
                              oModel:SetValue('ABRMASTER', 'ABR_NOMSUB', '')} /*<bBloco>*/,;
                     /*[cToolTip]*/,;
                     /*[nShortCut]*/,;
                     {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE} /*[aOptions]*/ )

Return oView


//----------------------------------------------------------------------------------
/*/{Protheus.doc} AT550Inicia
Função para inicializar campos da View.

@sample 	AT550Inicia( oModel )
@param		oModel		Objeto com modelo de dados.

@author	Danilo Dias
@since		22/01/2013
@version	P11.8
/*/
//----------------------------------------------------------------------------------
Function AT550Inicia( oModel )

Local aArea	:= GetArea()

If ( oModel:GetOperation() == MODEL_OPERATION_INSERT )
	If VALTYPE((cAliasTmp)->ABB_DTINI ) == 'C'
		oModel:LoadValue( 'ABRMASTER', 'ABR_DTINI', SToD( (cAliasTmp)->ABB_DTINI ) )
	ElseIf VALTYPE((cAliasTmp)->ABB_DTINI ) == 'D'
		oModel:LoadValue( 'ABRMASTER', 'ABR_DTINI', (cAliasTmp)->ABB_DTINI )
	EndIf
	oModel:LoadValue( 'ABRMASTER', 'ABR_HRINI', (cAliasTmp)->ABB_HRINI )
	If VALTYPE((cAliasTmp)->ABB_DTFIM ) == 'C'
		oModel:LoadValue( 'ABRMASTER', 'ABR_DTFIM', SToD( (cAliasTmp)->ABB_DTFIM ) )
	ElseIf VALTYPE((cAliasTmp)->ABB_DTFIM ) == 'D'
		oModel:LoadValue( 'ABRMASTER', 'ABR_DTFIM', (cAliasTmp)->ABB_DTFIM )
	EndIf
	oModel:LoadValue( 'ABRMASTER', 'ABR_HRFIM', (cAliasTmp)->ABB_HRFIM )
	oModel:LoadValue( 'ABRMASTER', 'ABR_TEMPO', '00:00' )
	oModel:LoadValue( 'ABRMASTER', 'ABR_CODSUB', '' )
	oModel:LoadValue( 'ABRMASTER', 'ABR_ITEMOS', '' )
	oModel:LoadValue( 'ABRMASTER', 'ABR_USASER', '2' )
EndIf



RestArea( aArea )

Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} AT550Tempo()
Função para calcular o tempo decorrido entre a data e hora da
agenda (ABB) e a data e hora informada na tela de manutenção (ABR).

@sample 	AT550Tempo()
@return	xHoras		Total de horas extras no formato 'HH:MM'

@author	Danilo Dias
@since		22/01/2013
@version	P11.8
/*/
//----------------------------------------------------------------------------------
Function AT550Tempo()

Local aArea			:= GetArea()
Local aAreaABN		:= ABN->(GetArea())
Local aAreaABB      := ''
Local oModel		:= FwModelActive()
Local oModelABR		:= oModel:GetModel("ABRMASTER")
Local xHoras		:= 0
Local cTipo			:= ''
Local cMotivo		:= oModelABR:GetValue( 'ABR_MOTIVO' )
Local dDtIniABB 	:= IIF( VALTYPE((cAliasTmp)->ABB_DTINI) == 'D' , (cAliasTmp)->ABB_DTINI ,SToD( (cAliasTmp)->ABB_DTINI ))
Local dDtIniABR 	:= oModelABR:GetValue( 'ABR_DTINI' )
Local cHrIniABB 	:= (cAliasTmp)->ABB_HRINI
Local cHrIniABR 	:= oModelABR:GetValue( 'ABR_HRINI' )
Local dDtFimABB 	:= IIF( VALTYPE((cAliasTmp)->ABB_DTFIM) == 'D' , (cAliasTmp)->ABB_DTFIM ,SToD( (cAliasTmp)->ABB_DTFIM ))
Local dDtFimABR 	:= oModelABR:GetValue( 'ABR_DTFIM' )
Local cHrFimABB 	:= (cAliasTmp)->ABB_HRFIM
Local cHrFimABR 	:= oModelABR:GetValue( 'ABR_HRFIM' )

DbSelectArea('ABN')		//Cadastro de motivos de manutenção da agenda
ABN->( DbSetOrder(1) )	//ABN_FILIAL + ABN_MOTIVO

If ( ABN->( DbSeek( xFilial('ABN') + cMotivo ) ) )
	cTipo := ABN->ABN_TIPO
EndIf

If (isInCallStack("TECA550") .OR. IsInCallStack("at190d550") .OR. IsInCallStack("AT190dIMn2")) .AND. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	cHrIniABB := ABR->ABR_HRINIA
	cHrFimABB := ABR->ABR_HRFIMA
	dDtIniABB := ABR->ABR_DTINIA
	dDtFimABB := ABR->ABR_DTFIMA
Endif

Do Case
	Case cTipo == MANUT_TIPO_ATRASO	//Atraso
		xHoras := SubtHoras( dDtIniABB, cHrIniABB, dDtIniABR, cHrIniABR )

	Case cTipo == MANUT_TIPO_SAIDAANT	//Saída antecipada
		xHoras := SubtHoras( dDtFimABR, cHrFimABR, dDtFimABB, cHrFimABB )

	Case cTipo == MANUT_TIPO_HORAEXTRA	//Hora Extra
		aAreaABB := ABB->(GetArea())
		dbSelectArea("ABB")
		ABB->(dbSetOrder(8)) 
		If ABB->(DbSeek(xFilial("ABB")+(cAliasTmp)->ABB_CODIGO))
			If EMPTY(ABB->ABB_HRCHIN) .AND. EMPTY(ABB->ABB_HRCOUT)
				xHoras := SubtHoras( dDtIniABR, cHrIniABR, dDtIniABB, cHrIniABB )
			EndIf
		EndIf	
		RestArea(aAreaABB)	
		xHoras += SubtHoras( dDtFimABB, cHrFimABB, dDtFimABR, cHrFimABR )
	Case cTipo == MANUT_TIPO_AUSENT	//Ausência
		xHoras := SubtHoras(dDtIniABR, cHrIniABR, dDtFimABR, cHrFimABR )
End Case

If ( ValType( xHoras ) == 'N' )
	xHoras	:= IIf( xHoras > 0, IntToHora( xHoras ), '00:00' )
EndIf

RestArea( aAreaABN )
RestArea( aArea )

Return xHoras


//-------------------------------------------------------------------
/*/{Protheus.doc} AT550Valid
Função para validação de campos.

@sample 	AT550Valid( oModel, cCampo )

@param		oModel		Objeto com o Model para efetuar a validação.
			cCampo		Nome do campo que acionou o Valid.
@return	lRet		Indica se é válido.

@author	Danilo Dias
@since		11/01/2013
@version	P11.8
/*/
//-------------------------------------------------------------------
Function AT550Valid( oModelVld, cCampo, xValInserido, xValAnterior )

Local aArea 	:= GetArea()
Local lRet		:= .T.
Local cTpMovHora 	:= MANUT_TIPO_ATRASO+','+MANUT_TIPO_SAIDAANT+','+MANUT_TIPO_HORAEXTRA+','+MANUT_TIPO_AUSENT'
Local lDifHoras 	:= At540DifHr()
Local lMonitChk   := IsInCallStack( 'AT920Falta' )
Local lAfast      := IsInCallStack( 'AT643Falta' )
Local oModel 		:= oModelVld:GetModel()
Local cTipoAfas   := MANUT_TIPO_FALTA+','+MANUT_TIPO_CANCEL'
Do Case
	Case cCampo == 'ABR_MOTIVO'

		If AT550Tipo() $ cTpMovHora .And. lDifHoras
			lRet := .F.
			Help( " ", 1, "AT550Valid", , STR0048, 1, 0 ) // "Não é permitida alteração em massa para agendas com horários de entrada e saída diferentes"
		ElseIf lAfast .AND. !(AT550Tipo() $ cTipoAfas)
			lRet := .F.
			Help( " ", 1, "AT550AFS", , STR0091, 1, 0 ) // "O afastamento integrado com a aplicação de disciplina é inserido em todos os períodos da agenda do atendente para o dia. Assim, é permitido somente atribuição de manutenção de falta ou cancelamento"
		ElseIf lMonitChk .And. !( AT550Tipo() == MANUT_TIPO_FALTA )
			lRet := .F.
			Help( " ", 1, "AT550MONIT", , STR0049, 1, 0 ) // "Somente é permite atribuição de faltas"
		Else
			AT550Inicia( oModel )
			lRet := .T.
		EndIf

	Case cCampo == 'ABR_ITEMOS'
		lRet := AT550SelCt( oModel:GetValue( 'ABRMASTER', 'ABR_ITEMOS' ), oModel:GetValue( 'ABRMASTER', 'ABR_MOTIVO' ) )	//Abre TWBrowse para seleção da config. do contrato
		If ( !lRet )
			Help( " ", 1, "AT550Valid", , STR0022, 1, 0 )	//"Item selecionado não possui configuração de Ordem de Serviço."
		EndIf
	Case cCampo == 'ABR_CODSUB'
		lRet := GetAdvFVal("AA1","AA1_ALOCA",xFilial("AA1")+ oModel:GetValue( 'ABRMASTER', 'ABR_CODSUB' ),1,"")	<> "2"
		If ( !lRet )
			Help( " ", 1, "AT550Valid", , STR0066, 1, 0 )	//"Atendente substituto cadastrado como indisponível para alocação."
		EndIf

End Case

RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AT550When
Função para avaliar a condição de When do campo.

@sample 	AT550When( oModel, cCampo )

@param		oModel		Objeto com o Model para efetuar a validação.
			cCampo		Nome do campo que acionou o When.
@return	lRet		Indica a condição de When.

@author	Danilo Dias
@since		11/01/2013
@version	P11.8
/*/
//-------------------------------------------------------------------
Function AT550When( oModel, cCampo )

Local aArea		:= GetArea()
Local lRet			:= .T.
Local cTipo		:= ''
Local nOperation := oModel:GetOperation()
Local lInclui		:= (nOperation == MODEL_OPERATION_INSERT)
Local lAltera		:= (nOperation == MODEL_OPERATION_UPDATE)
If ( lAltera ) .Or. ( lInclui )
	cTipo := AT550Tipo()	//Busca tipo do motivo da manutenção
EndIf

Do Case
	Case cCampo == 'ABR_MOTIVO'
		If ( lInclui )
			lRet := .T.
		Else
			lRet := .F.
		EndIf

	Case cCampo == 'ABR_DTINI' .Or. cCampo == 'ABR_HRINI'
		If ( cTipo $( MANUT_TIPO_ATRASO + "|" + MANUT_TIPO_HORAEXTRA ) ) .Or. ( cTipo $( MANUT_TIPO_AUSENT ) .And. cCampo == 'ABR_HRINI')
			lRet := .T.
		Else
			lRet := .F.
		EndIf

	Case cCampo == 'ABR_DTFIM' .Or. cCampo == 'ABR_HRFIM'
		If ( cTipo $( MANUT_TIPO_SAIDAANT+"|"+MANUT_TIPO_HORAEXTRA ) ) .Or. ( cTipo $( MANUT_TIPO_AUSENT ) .And. cCampo == 'ABR_HRFIM')
			lRet := .T.
		Else
			lRet := .F.
		EndIf

	Case cCampo == 'ABR_CODSUB'
		If( ( cTipo == MANUT_TIPO_HORAEXTRA ) .Or. ( Empty( cTipo ) ))
			lRet := .F.
		Else
			lRet := .T.
		EndIf

	Case cCampo == 'ABR_ITEMOS'
		If ( cTipo == MANUT_TIPO_TRANSF )
			lRet := .T.
		Else
			lRet := .F.
		EndIf

	Case cCampo == 'ABR_TEMPO'
		If ( cTipo $( MANUT_TIPO_ATRASO+"|"+MANUT_TIPO_SAIDAANT+"|"+MANUT_TIPO_HORAEXTRA+"|"+MANUT_TIPO_AUSENT+"|"+MANUT_TIPO_REALOC+"|"+MANUT_TIPO_COMPEN ) )
			lRet := .T.
		Else
			lRet := .F.
		EndIf

	Case cCampo == 'ABR_USASER'
		If ( cTipo == MANUT_TIPO_HORAEXTRA )
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	Case cCampo == 'ABR_TIPDIA'
		If ( cTipo $ (MANUT_TIPO_FALTA+"|"+MANUT_TIPO_ATRASO+"|"+MANUT_TIPO_SAIDAANT+"|"+MANUT_TIPO_CANCEL+"|"+MANUT_TIPO_REALOC+"|"+MANUT_TIPO_COMPEN) ) .And. AliasInDic('TDV')
			If At550VldTDV( (cAliasTmp)->ABB_CODIGO )  // verifica se a agenda tem víncula com a alocação por escala
				lRet := .T.
			EndIf
		Else
			lRet := .F.
		EndIf
End Case

RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AT550Commit
Função para gravar os dados do formulário no banco de dados.

@sample 	AT550Commit( oModel )

@param		oModel		Objeto com o Model para efetuar o commit.

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function AT550Commit( oModel )

Local aArea		:= GetArea()
Local aAreaABB	:= ABB->(GetArea())
Local aAreaTMP	:= IIf( oModel:nOperation != 5, (cAliasTmp)->(GetArea()), {} )
Local lRet 		:= .T.
Local nOpc			:= 0
Local lIncluiABB	:= .T.		//Indica se é uma inclusão ou alteração para gravação da ABB
Local cAgenda		:= ''		//Código da agenda
Local cCodSub		:= ''		//Código do atendente substituo
Local cChave		:= ''		//Chave da agenda
Local cNumOS		:= ''		//Número da OS da agenda
Local cItemOS		:= ''		//Item da OS da agenda ABB_ITEMOS
Local cConfig		:= ''		//Código da configuração da agenda	ABB_IDCFAL
Local cMotivo		:= ''		//Motivo informado para a manutenção
Local cTipo		:= ''		//Tipo do motivo selecionado para manutenção
Local cHrIni		:= ''		//Hora inicial da agenda original
Local dDtIni		:= ''		//Data inicial da agenda original
Local cHrFim		:= ''		//Hora final da agenda original
Local dDtFim		:= ''		//Data final da agenda original
Local cHrIniABR	:= ''		//Hora inicial informada para a manutenção
Local dDtIniABR	:= ''		//Data inicial informada para a manutenção
Local cHrFimABR	:= ''		//Hora final informada para a manutenção
Local dDtFimABR	:= ''		//Data final informada para a manutenção
Local cHrIniSub	:= ''		//Hora inicial para a agenda do substituto
Local dDtIniSub	:= ''		//Data inicial para a agenda do substituto
Local cHrFimSub	:= ''		//Hora final para a agenda do substituto
Local dDtFimSub	:= ''		//Data final para a agenda do substituto
Local cTempo		:= ''		//Tempo calculado de acordo com o início e fim informados para a manutenção
Local cAtivo		:= '1'		//Informa o conteúdo do campo ABB_ATIVO
Local cManut		:= '1'		//Informa o conteúdo do campo ABB_MANUT
Local aManut		:= {}		//Array com manutenções realizadas na agenda
Local nTamOSAB6	:= TAMSX3('AB6_NUMOS')[1]		//Tamanho do campo AB6_NUMOS
Local cNumManut	:= ''		//Número da manutenção
Local nI			:= 1
Local cTipoAloc	:= ""
Local lAltDtHrIni 	:= .F.
Local lAltDtHrFim 	:= .F.
Local cMvHorario 	:= MANUT_TIPO_ATRASO+','+MANUT_TIPO_SAIDAANT+','+MANUT_TIPO_HORAEXTRA
Local cLocal := ""//Local de Atendimento (Posto)
Local cTipDia 	:= ''
Local aAtend		:= {}
Local lCustoTWZ	:= ExistBlock("TecXNcusto")
Local cFilAbb	:= ''
Local bFilAbb 	:= Nil
Local lUpCusto 		:= .F.
Local cCodTWZ 		:= ""
Local cDescErro 	:= ""
Local cHrTot		:= ""
Local cCodTec		:= ""
Local cFilAbbCom := ""
Local cCodAbbCom := ""
Local lAltAus		:= .F.
Local cHrFim		:= ""
Local dDtIni
Local dDtFim
Local cHrTotAnt	:= ""
Local cAbbAlias := GetNextAlias()
Local lABBSub	:= .F.
Local lPermConfl:= AT680Perm(NIL, __cUserID, "017")
Local lConf		:= .F.
Local cCdABB	:= SPACE(TamSX3("ABB_CODIGO")[1])
Local d190dDtIni
Local c190dHrIni	:= ""
Local c190dHrFim	:= ""
Local d190dDtFim
Local lMesaOP		:= .F.
Local c190CodTec	:= ""
Local cABB_OBSERV := ""
Local lAt550Grv := ExistBlock("At550Grv")
Local lMdtGS 	:= SuperGetMv("MV_NG2GS",.F.,.F.) .And. TableInDic("TN5") .And. TableInDic("TN6")//Parâmetro de integração entre o SIGAMDT x SIGATEC 
Local cQueryTN5	:= ""
Local cCDFUNC 	:= ""
Local cFilSRA	:= ""
Local cBkpFil	:= ""
Local dDtIniMdt	:= sTod("")
Local dDtFimMdt	:= sTod("")
Local cIdcFalMdt:= ""
Local lAlocMtFil := .F.
Local lPrHora 	:= TecABBPRHR()
Local lCompensa	:= TecABRComp()
Local lGrvCus	:= SuperGetMv("MV_GRVTWZ",,.T.)

If At550SetGrvU() .AND. At550SetAlias() == "ABB"
	cCdABB := ABB->ABB_CODIGO
EndIf

If ( ValType( oModel ) <> 'O' )
	Return .F.
EndIf

If (isInCallStack("at190dimn2") .OR. isInCallStack("SubstLote") .OR. isInCallStack("AT570Subst")) .AND. !EMPTY(cTipAlcSta)
	cTipoALoc := cTipAlcSta
ElseIf !IsInCallStack('AT570Subst')
	cTipoAloc	:= ""
EndIf

DbSelectArea('ABB')	//Agenda de Alocação
ABB->(DbSetOrder(8))	//ABB_FILIAL + ABB_CODIGO

DbSelectArea('ABN')	//Motivos de Manutenção da Agenda
ABN->(DbSetOrder(1))	//ABN_FILIAL + ABN_CODIGO

DbSelectArea('ABQ')	//Configurações do contrato
ABQ->(DbSetOrder(1))	//ABQ_FILIAL+ABQ_CONTRT+ABQ_ITEM

cCodSub	:= oModel:GetValue( 'ABRMASTER', 'ABR_CODSUB' )
cMotivo	:= oModel:GetValue( 'ABRMASTER', 'ABR_MOTIVO' )
cTempo		:= oModel:GetValue( 'ABRMASTER', 'ABR_TEMPO' )
cItemOS	:= oModel:GetValue( 'ABRMASTER', 'ABR_ITEMOS' )
nOpc		:= oModel:GetOperation()

If ( ABN->( DbSeek( xFilial('ABN') + cMotivo ) ) )
	cTipo := ABN->ABN_TIPO
	If cTipo == MANUT_TIPO_FALTA
		cABB_OBSERV := STR0075 //"Falta"
	ElseIf cTipo == MANUT_TIPO_ATRASO
		cABB_OBSERV := STR0076 //"Atraso"
	ElseIf cTipo == MANUT_TIPO_SAIDAANT
		cABB_OBSERV := STR0077 //"Saída antecipada"
	ElseIf cTipo == MANUT_TIPO_HORAEXTRA
		If IsInCallStack("At58gGera")
			cABB_OBSERV := STR0078 //"H.E. planejada"
		Else
			cABB_OBSERV := STR0079 //"Hora extra"
		EndIf
	ElseIf cTipo == MANUT_TIPO_CANCEL
		cABB_OBSERV := STR0080 //"Cancelado"
	ElseIf cTipo == MANUT_TIPO_TRANSF
		cABB_OBSERV := STR0081 //"Transferido"
	ElseIf cTipo == MANUT_TIPO_AUSENT
		cABB_OBSERV := STR0082 //"Ausência"
	ElseIf cTipo == MANUT_TIPO_REALOC
		cABB_OBSERV := STR0083 //"Realocação"
	ElseIf cTipo == MANUT_TIPO_COMPEN
		cABB_OBSERV := "Compensado"
	EndIf
EndIf

If isInCallStack("TECA550") .AND. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	cHrIniABB := ABR->ABR_HRINIA
	cHrFimABB := ABR->ABR_HRFIMA
	dDtIniABB := ABR->ABR_DTINIA
	dDtFimABB := ABR->ABR_DTFIMA
Endif

Begin Transaction

	Do Case

		//----------------------------------------------------------------------------
		// Exclusão
		//----------------------------------------------------------------------------
		Case ( nOpc == MODEL_OPERATION_DELETE )

			cAgenda	:= oModel:GetValue( 'ABRMASTER', 'ABR_AGENDA' )

			aManut		:= AT550QryMan( cAgenda )

			// Verifica se existe mais de uma manutenção para a agenda
			// atualizando o status da agenda após a exclusão
			If ( Len( aManut ) > 1 )
				cManut := '1'		//Sim
				cAtivo := '1'		//Sim
				For nI := 1 To Len(aManut)
					If ( aManut[nI][1] != oModel:GetValue( 'ABRMASTER', 'ABR_MOTIVO' ) )
						If ( aManut[nI][2] $(MANUT_TIPO_FALTA+"|"+MANUT_TIPO_CANCEL+"|"+MANUT_TIPO_TRANSF+"|"+MANUT_TIPO_REALOC+"|"+MANUT_TIPO_COMPEN) )	//Motivos que desativam a agenda
							cAtivo := '2'	//Não
							Exit
						EndIf
					EndIf
				Next nI
			Else
				cManut := '2'	//Não
				cAtivo	:= '1'	//Sim
			EndIf

			cHrFim := ABR->ABR_HRFIMA
			dDtIni := ABR->ABR_DTINIA
			dDtFim := ABR->ABR_DTFIMA

			//Atualiza status da agenda
			DbSelectArea('ABB')		//Agenda de Atendentes
			ABB->(DbSetOrder(8))	//ABB_FILIAL + ABB_CODIGO

			AA1->( DbSetOrder( 1 ) ) // AA1_FILIAL + AA1_CODTEC

			If ( ABB->( DbSeek( xFilial('ABB') + cAgenda ) ) )
				// posiciona no atendente
				AA1->( DbSeek(xFilial("AA1")+ ABB->ABB_CODTEC))
				cCodTec := ABB->ABB_CODTEC
				// Verificação de conflito de horários ao excluir manutenção de agenda
				BeginSQL Alias cAbbAlias
				SELECT  ABB_HRINI,
						ABB_HRFIM
				FROM %Table:ABB% ABB
					WHERE ABB.ABB_FILIAL = %xFilial:ABB%
					  AND ABB.ABB_CODTEC = %Exp:ABB->ABB_CODTEC%
					  AND ABB.ABB_DTINI = %Exp:DToS( dDtIni )%
					  AND ABB.ABB_DTFIM = %Exp:DToS( dDtFim )%
					  AND ABB.ABB_ATIVO = '1'
					  AND ABB.%NotDel%
					  AND ABB.ABB_CODIGO <> %Exp:cCdABB%
				EndSQL

				If (cAbbAlias)->(!Eof()) .AND. cTipo <> MANUT_TIPO_HORAEXTRA
				 	While (cAbbAlias)->(!Eof())
					 	If ABB->ABB_HRINI < (cAbbAlias)->ABB_HRINI .OR. ABB->ABB_HRINI > (cAbbAlias)->ABB_HRFIM
					 		If !lConf
						 		If ABB->ABB_HRINI < (cAbbAlias)->ABB_HRINI
						 			If ABB->ABB_HRFIM <= (cAbbAlias)->ABB_HRINI
						 				lConf := .F.
						 			Else
						 				lConf := .T.
						 			EndIf
						 		Else
						 			lConf := .F.
						 		EndIf
					 		EndIf
					 	Else
					 		lConf := .T.
						EndIf
					(cAbbAlias)->(dbSkip())
				 	EndDo
				Else
					lConf := .F.
				EndIf
				(cAbbAlias)->(DbCloseArea())

				If lConf
					If lPermConfl
						lRet := msgYesNo(STR0068+DToC( dDtIni )+STR0069+; // Atendente com conflito de horários. Data inicial: ## Horário inicial:
										ABB->ABB_HRINI+STR0070+DToC( dDtFim )+STR0072+ABB->ABB_HRFIM,STR0071) // Horário final:  ## Data final:  ## Deseja continuar?
					Else
						lRet := .F.
					EndIf
				EndIf

				If lRet
					lUpCusto := ( cAtivo == '1' ) // Agenda ativa?
					cConfig := ABB->ABB_IDCFAL
					cCodTWZ := ABB->ABB_CODTWZ

					If lUpCusto
						//Busca o custo do atendente pelo PE ou pelo campo do atendente
						If lCustoTWZ
							// posicina ABQ
							DbSelectArea("ABQ")
							ABQ->( DbSetOrder( 1 ) ) // ABQ_FILIAL + ABQ_CONTRT + ABQ_ITEM + ABQ_ORIGEM
							ABQ->( DbSeek( xFilial("ABQ") + cConfig ) )

							// posicina TFF
							DbSelectArea("TFF")
							TFF->( DbSetOrder( 1 ) ) // TFF_FILIAL + TFF_COD
							TFF->( DbSeek( ABQ->( ABQ_FILTFF + ABQ_CODTFF ) ) )
							nCusto := ExecBlock("TecXNcusto",.F.,.F.,;
												{ 2, A, AA1->AA1_FUNFIL, AA1->AA1_CDFUNC,;
													TFF->TFF_CONTRT, TFF->TFF_LOCAL, TFF->TFF_CODPAI, TFF->TFF_COD, cConfig } )
						Else
							nCusto := AA1->AA1_CUSTO
						EndIf
					EndIf

					cHrTotAnt := ATTotHora(ABR->ABR_DTINIA, ABR->ABR_HRINIA, ABR->ABR_DTFIMA, ABR->ABR_HRFIMA)
					RecLock('ABB',.F.)
						Replace ABB_MANUT With cManut
						If cTipo == MANUT_TIPO_HORAEXTRA .AND. !EMPTY(ABB->ABB_OBSERV) .AND. Upper(STR0078) $ Upper(ABB->ABB_OBSERV)
							cABB_OBSERV := STR0078
						EndIf
						If Upper(cABB_OBSERV) $ Upper(ABB->ABB_OBSERV)
							If ("/"+Upper(cABB_OBSERV)) $ Upper(ABB->ABB_OBSERV)
								Replace ABB_OBSERV With STRTRAN(ALLTRIM(ABB->ABB_OBSERV), "/"+cABB_OBSERV)
							ElseIf (Upper(cABB_OBSERV)+"/") $ Upper(ABB->ABB_OBSERV)
								Replace ABB_OBSERV With STRTRAN(ALLTRIM(ABB->ABB_OBSERV), cABB_OBSERV+"/")
							Else
								Replace ABB_OBSERV With ''
							EndIf
						Endif
						
						Replace ABB_ATIVO With cAtivo
						Replace ABB_DTINI With ABR->ABR_DTINIA
						Replace ABB_DTFIM With ABR->ABR_DTFIMA

						If cTipo == MANUT_TIPO_AUSENT .AND. ABR->ABR_HRFIM != ABB->ABB_HRFIM .AND. ABR->ABR_HRINI != ABB->ABB_HRINI
							lAltAus := .T.
							Replace ABB_HRFIM With ABR->ABR_HRFIM
						Else
							Replace ABB_HRINI With ABR->ABR_HRINIA
							Replace ABB_HRFIM With ABR->ABR_HRFIMA
							If !EMPTY(ABB->ABB_HRCOUT)
								Replace ABB_HRCOUT With ABR->ABR_HRFIMA
							EndIf
						EndIf

						If lUpCusto
							Replace ABB->ABB_CUSTO With (SubtHoras(ABB->ABB_DTINI,ABB->ABB_HRINI,ABB->ABB_DTFIM,ABB->ABB_HRFIM,.T.)*nCusto)
						Else
							Replace ABB->ABB_CUSTO With 0
							Replace ABB->ABB_CODTWZ With ""
						EndIf

						If isInCallStack("TECA550") .OR. isInCallStack("TECA190D")
							ABB->ABB_HRTOT := cHrTotAnt
						EndIf

					ABB->(MsUnlock())
					
					If lPrHora
						DbSelectArea("ABQ")
						ABQ->( DbSetOrder( 1 ) ) // ABQ_FILIAL + ABQ_CONTRT + ABQ_ITEM + ABQ_ORIGEM
						ABQ->( DbSeek( xFilial("ABQ") + cConfig ) )
	
						TFF->( DbSetOrder( 1 ) )
						If TFF->(DbSeek( ABQ->( ABQ_FILTFF + ABQ_CODTFF )))
							If !Empty(TFF->TFF_QTDHRS)
								TFF->(RecLock("TFF", .F.))
									If TecConvHr(oModel:GetValue( 'ABRMASTER', 'ABR_TEMPO' )) > 0
										TFF->TFF_HRSSAL := TecConvHr(SubHoras(TecConvHr(TFF->TFF_HRSSAL), oModel:GetValue( 'ABRMASTER', 'ABR_TEMPO' )))
									Else
										TFF->TFF_HRSSAL := TecConvHr(SubHoras(TecConvHr(TFF->TFF_HRSSAL), TecConvHr(Left(ElapTime(ABB->ABB_HRINI+":00", ABB->ABB_HRFIM+":00"), 5)))) 
									EndIf
								TFF->( MsUnlock() )
							EndIf
						EndIf
					EndIf

					If lAltAus
						AUpdABBAus(cConfig,cCodTec,ABR->ABR_DTINIA,ABR->ABR_DTFIMA,ABR->ABR_HRFIMA)
					EndIf
					If lCompensa .AND. cTipo == MANUT_TIPO_COMPEN
						If ABB->( DbSeek( xFilial('ABB') + oModel:GetValue( 'ABRMASTER', 'ABR_COMPEN' ) ) ) .AND. ASCAN( aCompen, {|a| a[1] == ABB->ABB_CODIGO }) == 0
							cFilAbbCom := ABB->ABB_FILIAL
							cCodAbbCom := ABB->ABB_CODIGO
							AADD(aCompen, {ABB->ABB_CODIGO,;
										ABB->ABB_DTINI,;
										ABB->ABB_HRINI,;
										ABB->ABB_DTFIM,;
										ABB->ABB_HRFIM,;
										ABB->ABB_ATENDE,;
										ABB->ABB_CHEGOU,;
										ABB->ABB_IDCFAL,;
										TDV->TDV_DTREF,;
										.F.,;
										"",;
										ABB->ABB_FILIAL})
							At190DDlt2(,,cCodTec,,,,,,,,,aCompen )
							ABB->(DbSetOrder(8)) //ABB_FILIAL+ABB_CODIGO
							If ABB->(MsSeek(cFilAbbCom+cCodAbbCom)) //não conseguiu excluir
								lRet := .F.
								cDescErro := STR0086 + DTOC(ABB->ABB_DTINI) +; //"Não foi possível excluir a agenda do dia "
								" (" + ABB->ABB_HRINI + "-" + ABB->ABB_HRFIM + ") " +;
								 " - " + STR0087 //"agenda gerada apartir de uma manutenção de Compensação."
							EndIf
							ABB->( DbSeek( xFilial('ABB') + cAgenda ) )
						EndIf
					EndIf
					//Exclui a agenda de substituição
					If ( !Empty( cCodSub ) )

						//Pega dados da agenda original
						cHrIni 	:= ABB->ABB_HRINI
						dDtIni 	:= ABB->ABB_DTINI
						cHrFim 	:= ABB->ABB_HRFIM
						dDtFim 	:= ABB->ABB_DTFIM

						//Atraso
						If ( cTipo == MANUT_TIPO_ATRASO )
							//Pega data e hora da substituição
							cHrIni 	:= ABB->ABB_HRINI
							dDtIni 	:= ABB->ABB_DTINI
							cHrFim 	:= TecConvHr( SubHoras( ABR->ABR_HRINI, "00:01" ) )
							dDtFim 	:= ABR->ABR_DTINI
						//Saída antecipada
						ElseIf ( cTipo == MANUT_TIPO_SAIDAANT )
							//Pega data e hora da substituição
							cHrIni 	:= TecConvHr( SomaHoras( ABR->ABR_HRFIM, "00:01" ) )
							dDtIni 	:= ABR->ABR_DTFIM
							cHrFim 	:= ABB->ABB_HRFIM
							dDtFim 	:= ABB->ABB_DTFIM
						ElseIf ( cTipo == MANUT_TIPO_AUSENT )
							//Pega data e hora da ausência
							cHrIni 	:= ABR->ABR_HRINI
							dDtIni 	:= ABR->ABR_DTFIM
							cHrFim 	:= ABR->ABR_HRFIM
							dDtFim 	:= ABR->ABR_DTFIM
						EndIf

						cFilAbb	:= ABB->(DbFilter())
						bFilAbb	:= &("{||" + cFilAbb + "}")

						ABB->( DBClearFilter())
						ABB->( DbSetOrder(1) )	//ABB_FILIAL + ABB_CODTEC + DTOS(ABB_DTINI) + ABB_HRINI + DTOS(ABB_DTFIM) + ABB_HRFIM

						// Query para posicionar na ABB correta da agenda de substituto, para fins de atualização na operação DELETE
						cAbbAlias := getNextAlias()
						BeginSQL Alias cAbbAlias
							Select R_E_C_N_O_ FROM %Table:ABB% ABB
								WHERE ABB.ABB_FILIAL = %xFilial:ABB%
									AND ABB.ABB_CODTEC = %Exp:ABR->ABR_CODSUB%
									AND ABB.ABB_DTINI = %Exp:DToS( dDtIni )%
									AND ABB.ABB_HRINI = %Exp:cHrIni%
									AND ABB.ABB_DTFIM = %Exp:DToS( dDtFim )%
									AND ABB.ABB_HRFIM = %Exp:cHrFim%
									AND ABB.ABB_ATIVO = '1'
									AND ABB.ABB_TIPOMV <> '001'
									AND ABB.%NotDel%
						EndSQL

						If (cAbbAlias)->(!Eof())
							ABB->(dbGoto((cAbbAlias)->R_E_C_N_O_))
							lABBSub := .T.
						EndIf
						(cAbbAlias)->(DbCloseArea())

						//Apaga agenda do substituto e alocação por escala quando existir
						If lABBSub .OR.;
								( ABB->( DbSeek( xFilial('ABB') + ABR->ABR_CODSUB + DToS( dDtIni ) + TecConvHr( SubHoras( cHrIni, "00:01" ) ) + DToS( dDtFim ) + cHrFim ) ) ) .OR.;
									( ABB->( DbSeek( xFilial('ABB') + ABR->ABR_CODSUB + DToS( dDtIni ) + TecConvHr( SomaHoras( cHrIni, "00:01" ) ) + DToS( dDtFim ) + cHrFim ) ) )
							// remove vínculo com a tabela de agenda por escala
							If At550VldTDV( ABB->ABB_CODIGO )
								At550UpdTdv(.T.,ABB->ABB_CODIGO)
							EndIf
							
							dDtIniMdt := ABB->ABB_DTINI
							dDtFimMdt := ABB->ABB_DTFIM
							cIdcFalMdt:= ABB->ABB_IDCFAL

							Reclock('ABB',.F.)
								If Empty( cCodTWZ )
									cCodTWZ  := ABB->ABB_CODTWZ
								EndIf								
								ABB->( DbDelete() )
							ABB->(MsUnlock())

							If lMdtGS //Integração entre o SIGAMDT x SIGATEC
								// posicina TFF
								DbSelectArea("TFF")
								TFF->( DbSetOrder(1)) //TFF_FILIAL+TFF_COD
							
								//posicina TN5
								dbSelectArea("TN5")
								TN5->(dbSetOrder(1)) //TN5_FILIAL+TN5_CODTAR
								
								If TFF->( ColumnPos("TFF_RISCO")) > 0 .And. TN5->(ColumnPos("TN5_LOCAL")) > 0 .And. TN5->(ColumnPos("TN5_POSTO")) > 0
							
									//posicina ABQ
									DbSelectArea("ABQ")
									ABQ->( DbSetOrder(1)) //ABQ_FILIAL+ABQ_CONTRT+ABQ_ITEM+ABQ_ORIGEM
								
									//posicina TN6
									dbSelectArea("TN6")
									TN6->(dbSetOrder(1)) //TN6_FILIAL+TN6_CODTAR+TN6_MAT+DTOS(TN6_DTINIC)
									
									cCDFUNC := Posicione("AA1",1,xFilial("AA1")+ABB->ABB_CODTEC, "AA1_CDFUNC")
									
									If ABQ->(DbSeek(xFilial("ABQ")+cIdcFalMdt)) .And.; //Integração entre o SIGAMDT x SIGATEC
									   TFF->(DbSeek(ABQ->(ABQ_FILTFF+ABQ_CODTFF))) .And.;
									   TFF->TFF_RISCO == "1" .And. !Empty(cCDFUNC)
										
										//Query para verificar se não existe mais ABB para realizar a exclusão da TN6
										cAbbAlias := getNextAlias()
										BeginSQL Alias cAbbAlias
											Select ABB.R_E_C_N_O_ FROM %Table:ABB% ABB
												WHERE ABB.ABB_FILIAL = %xFilial:ABB%
													AND ABB.ABB_CODTEC = %Exp:ABR->ABR_CODSUB%
													AND ABB.ABB_DTINI = %Exp:DToS( dDtIniMdt )%
													AND ABB.ABB_DTFIM = %Exp:DToS( dDtFimMdt )%
													AND ABB.ABB_IDCFAL = %Exp:cIdcFalMdt%
													AND ABB.ABB_ATIVO = '1'
													AND ABB.ABB_TIPOMV <> '001'
													AND ABB.%NotDel%
										EndSQL

										If (cAbbAlias)->(Eof())
							   
											cQueryTN5	:= GetNextAlias()
									
											BeginSql Alias cQueryTN5
											
												SELECT TN5.R_E_C_N_O_ TN5RECNO
												FROM %Table:TN5% TN5
												WHERE TN5.TN5_FILIAL	= %exp:xFilial('TN5')%
													AND TN5.TN5_LOCAL	= %exp:TFF->TFF_LOCAL%
													AND TN5.TN5_POSTO	= %exp:TFF->TFF_FUNCAO% 
													AND TN5.%NotDel%
											EndSql

											cFilSRA := Posicione("AA1",1,xFilial("AA1")+ABR->ABR_CODSUB, "AA1_FUNFIL") 

											If cFilSRA != cFilAnt
												lAlocMtFil := .T.
												cBkpFil	:= cFilAnt
												cFilAnt := cFilSRA
											Else
												lAlocMtFil := .F.
											EndIf

											If (cQueryTN5)->(!EOF())
												TN5->(DbGoTo((cQueryTN5)->TN5RECNO))
												If TN6->(dbSeek(xFilial("TN6")+TN5->TN5_CODTAR+cCDFUNC+Dtos(dDtIniMdt))) .And. dDtFimMdt == TN6->TN6_DTTERM
													RecLock("TN6",.F.)
														TN6->( DbDelete() )
													TN6->(MsUnLock())
												Endif
											Endif

											If lAlocMtFil
												cFilAnt	:= cBkpFil
											EndIf
											(cQueryTN5)->(DbCloseArea())
										EndIf
										
										(cAbbAlias)->(DbCloseArea())

									Endif	
								Endif
							Endif								
						EndIf

						If !Empty(cFilAbb)
							ABB->( DBSetFilter( bFilAbb, cFilAbb ) )
						EndIf
					EndIf
					If lRet .AND. (lGrvCus .AND. Posicione("AA1",1,xFilial("AA1")+cCodTec,"AA1_CUSTO") > 0)
						// Atualiza as informações do aglutinador de custo do item, recalculando conforme o IDCFAL informado
						At330HasTWZ( cConfig, @cCodTWZ  )
						lRet := At330GrvCus( cConfig, cCodTWZ )
						If !lRet .And. Empty( cDescErro )
							cDescErro := STR0055 // "Não foi possível associar o custo da alocação."
						EndIf
					EndIf
					lRet := lRet .And. FwFormCommit( oModel )
					If !lRet .And. Empty( cDescErro )
						cDescErro := STR0056 // "Problemas na gravação nativa do MVC."
					EndIf
				Else
					cDescErro := STR0067 // "Não é possível excluir essa manutenção. Verifique que o atendente possui agenda ativa para esse período."
				EndIf
			EndIf
		//----------------------------------------------------------------------------
		// Inclusão
		//----------------------------------------------------------------------------
		Case ( nOpc == MODEL_OPERATION_INSERT )

			cNumManut := GetSXENum( 'ABR', 'ABR_MANUT' )

			If !(At550SetGrvU())
				(cAliasTmp)->(DbGoTop())
			EndIf

			While lRet .And. (cAliasTmp)->(!Eof())

				//Grava apenas para as agendas selecionadas
				If At550SetGrvU() .OR. ( (cAliasTmp)->ABB_OK == 1 )

					cAgenda 	:= (cAliasTmp)->ABB_CODIGO
					cHrIni  	:= (cAliasTmp)->ABB_HRINI
					dDtIni  	:= IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))
					cHrFim  	:= (cAliasTmp)->ABB_HRFIM
					dDtFim  	:= IIF(VALTYPE((cAliasTmp)->ABB_DTFIM) == 'D', (cAliasTmp)->ABB_DTFIM , SToD( (cAliasTmp)->ABB_DTFIM ))
					cHrIniABR 	:= oModel:GetValue( 'ABRMASTER', 'ABR_HRINI' )
					dDtIniABR 	:= oModel:GetValue( 'ABRMASTER', 'ABR_DTINI' )
					cHrFimABR 	:= oModel:GetValue( 'ABRMASTER', 'ABR_HRFIM' )
					dDtFimABR 	:= oModel:GetValue( 'ABRMASTER', 'ABR_DTFIM' )
					cLocal		:= (cAliasTmp)->ABB_LOCAL
					cTipDia     := oModel:GetValue( 'ABRMASTER', 'ABR_TIPDIA' )

					If ( cTipo == MANUT_TIPO_ATRASO )
						//Atualiza data e hora inicial em caso de atraso, conforme o tempo de atraso.
						SomaDiaHor( @dDtIni, @cHrIni, HoraToInt( cTempo, 2 ) )
						//Calcula o total de horas a partir da manutenção
						cHrTotAnt := ATTotHora(dDtIni, cHrIniABR, dDtFim, cHrFimABR )	//Calcula o tempo total da agenda

					ElseIf ( cTipo $ MANUT_TIPO_SAIDAANT )
						//Atualiza data e hora final em caso de saída antecipada, conforme o tempo de saída.
						SubtDiaHor( @dDtFim, @cHrFim, HoraToInt( cTempo, 2 ) )
						//Calcula o total de horas a partir da manutenção
						cHrTotAnt := ATTotHora(dDtIni, cHrIniABR, dDtFim, cHrFimABR )	//Calcula o tempo total da agenda

					ElseIf ( cTipo == MANUT_TIPO_HORAEXTRA )
						//Atualiza a data e hora de início e fim do atendimento, conforme o tempo de hora extra.
						SubtDiaHor( @dDtIni, @cHrIni, nTempoIni )
						SomaDiaHor( @dDtFim, @cHrFim, nTempoFim )
						//Calcula o total de horas a partir da manutenção
						cHrTotAnt := ATTotHora(dDtIni, cHrIniABR, dDtFim, cHrFimABR )	//Calcula o tempo total da agenda

					ElseIf ( cTipo == MANUT_TIPO_AUSENT )
						//Para ausência a hora inicio e fim será do periodo ausente
						cHrIni := cHrIniABR
						cHrFim := cHrFimABR
					EndIf

					//Grava dados da manutenção
					RecLock( 'ABR', .T. )
							ABR->ABR_FILIAL	:= xFilial('ABR')
							ABR->ABR_AGENDA	:= cAgenda
							ABR->ABR_DTMAN	:= Date()
							ABR->ABR_MOTIVO	:= cMotivo
							ABR->ABR_DTINI	:= dDtIni
							ABR->ABR_HRINI	:= TecConvHr(SomaHoras(cHrIni,IIF(cTipo $ (MANUT_TIPO_SAIDAANT+"|"+MANUT_TIPO_HORAEXTRA), "00:00", "00:01")))
							ABR->ABR_DTFIM	:= dDtFim
							ABR->ABR_HRFIM	:= cHrFim
							ABR->ABR_TEMPO	:= cTempo
							ABR->ABR_CODSUB	:= cCodSub
							ABR->ABR_ITEMOS	:= cItemOS
							ABR->ABR_USASER	:= oModel:GetValue( 'ABRMASTER', 'ABR_USASER' )
							ABR->ABR_OBSERV	:= oModel:GetValue( 'ABRMASTER', 'ABR_OBSERV' )
							ABR->ABR_MANUT	:= cNumManut
							ABR->ABR_USER 	:= __cUserId
							ABR->ABR_DTINIA := IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))
							ABR->ABR_HRINIA := (cAliasTmp)->ABB_HRINI
							ABR->ABR_DTFIMA := IIF(VALTYPE((cAliasTmp)->ABB_DTFIM) == 'D', (cAliasTmp)->ABB_DTFIM , SToD( (cAliasTmp)->ABB_DTFIM ))
							ABR->ABR_HRFIMA := (cAliasTmp)->ABB_HRFIM
							ABR->ABR_TIPDIA	:= cTipDia
					ABR->(MsUnlock())

					If lAt550Grv
						ExecBlock("At550Grv",.F.,.F.,{oModel,nOpc} )
					EndIf

					AA1->( DbSetOrder( 1 ) ) // AA1_FILIAL + AA1_CODTEC
					AA1->( MsSeek(xFilial("AA1")+ ABB->ABB_CODTEC))
					// Caso seja Falta, Cancelamento ou Transferência, desativa a agenda
					cAtivo := If( cTipo $ (MANUT_TIPO_FALTA+"/"+MANUT_TIPO_CANCEL+"/"+MANUT_TIPO_TRANSF+"/"+MANUT_TIPO_REALOC+"/"+MANUT_TIPO_COMPEN), "2", "1" )
					lUpCusto := ( cAtivo == '1' ) // Agenda ativa?
					cConfig := ABB->ABB_IDCFAL
					cCodTWZ := ABB->ABB_CODTWZ

					If lUpCusto
						//Busca o custo do atendente pelo PE ou pelo campo do atendente
						If lCustoTWZ
							// posicina ABQ
							DbSelectArea("ABQ")
							ABQ->( DbSetOrder( 1 ) ) // ABQ_FILIAL + ABQ_CONTRT + ABQ_ITEM + ABQ_ORIGEM
							ABQ->( DbSeek( xFilial("ABQ") + cConfig ) )

							// posicina TFF
							DbSelectArea("TFF")
							TFF->( DbSetOrder( 1 ) ) // TFF_FILIAL + TFF_COD
							TFF->( DbSeek( ABQ->( ABQ_FILTFF + ABQ_CODTFF ) ) )
							nCusto := ExecBlock("TecXNcusto",.F.,.F.,;
												{ 2, A, AA1->AA1_FUNFIL, AA1->AA1_CDFUNC,;
													TFF->TFF_CONTRT, TFF->TFF_LOCAL, TFF->TFF_CODPAI, TFF->TFF_COD, cConfig } )
						Else
							nCusto := AA1->AA1_CUSTO
						EndIf
					EndIf

					If ( ABB->( DbSeek( xFilial('ABB') + cAgenda ) ) )

						cChave 	:= ABB->ABB_CHAVE
						cNumOS 	:= ABB->ABB_NUMOS
						cConfig	:= ABB->ABB_IDCFAL

						If cTipo == MANUT_TIPO_AUSENT
							If IsInCallStack("AT190DIMN2")
								lMesaOP	:= .T.
								c190dHrFim	:= (cAliasTmp)->ABB_HRFIM
								c190CodTec	:= (cAliasTmp)->ABB_CODTEC
							EndIf
							//Quando a hora Inicio e final continuam iguais
							If (cHrIni == ABB->ABB_HRINI)  .AND.  (ABR->ABR_HRFIM == ABB->ABB_HRFIM)

								// Atualiza agenda com a hora fim igual a hora fim da ABR
								RecLock( 'ABB', .F. )
									ABB->ABB_HRINI	:= cHrIni
									ABB->ABB_ATENDE	:= '2'
									ABB->ABB_MANUT	:= '1'
									ABB->ABB_ATIVO	:= '1'
								ABB->(MsUnlock())

							//Quando a hora inicial continua igual
							ElseIf cHrIni == ABB->ABB_HRINI

								//Calcula o total de horas a partir da manutenção
								cHrTotAnt := ATTotHora(dDtIni, cHrFim, dDtFim, ABB->ABB_HRFIM)

								// Atualiza agenda com a hora fim igual a hora fim da ABR
								RecLock( 'ABB', .F. )
									ABB->ABB_HRINI	:= cHrFim
									ABB->ABB_ATENDE	:= '2'
									ABB->ABB_MANUT	:= '1'
									ABB->ABB_ATIVO	:= '1'
									ABB->ABB_HRTOT	:= cHrTotAnt
								ABB->(MsUnlock())

							//Quando a hora final continua igual
							ElseIf ABR->ABR_HRFIM == ABB->ABB_HRFIM

								//Calcula o total de horas a partir da manutenção
								cHrTotAnt := ATTotHora(dDtIni, ABB->ABB_HRINI, dDtFim, cHrIni )

								// Atualiza agenda com a hora fim igual a hora inicio da ABR
								RecLock( 'ABB', .F. )
									ABB->ABB_HRFIM	:= cHrIni
									ABB->ABB_ATENDE	:= '2'
									ABB->ABB_MANUT	:= '1'
									ABB->ABB_ATIVO	:= '1'
									ABB->ABB_HRTOT	:= cHrTotAnt
								ABB->(MsUnlock())

							//Quando a hora está no meio do periodo
							Else

								//Calcula o total de horas a partir da manutenção
								cHrTotAnt := ATTotHora(dDtIni, ABB->ABB_HRINI, dDtFim, cHrIni )

								// Atualiza agenda com a hora fim igual a hora inicio da ABR
								RecLock( 'ABB', .F. )
									ABB->ABB_HRFIM	:= cHrIni
									ABB->ABB_ATENDE	:= '2'
									ABB->ABB_MANUT	:= '1'
									ABB->ABB_ATIVO	:= '1'
									ABB->ABB_HRTOT	:= cHrTotAnt
								ABB->(MsUnlock())

								If ( ValType( cHrTot ) == 'N' )
									cHrTot	:= IIf( cHrTot > 0, IntToHora( cHrTot ), '00:00' )
								EndIf

								cHrTot := ATTotHora(dDtIni, ABR->ABR_HRFIM, dDtFim, IIF(lMesaOP, c190dHrFim, (cAliasTmp)->ABB_HRFIM) )	//Tempo total da agenda
								//Cria uma nova ABB com os dados do segundo periodo
								RecLock( 'ABB', .T. )
									ABB->ABB_FILIAL	:= xFilial( 'ABB' )
									ABB->ABB_CODIGO	:= GetSXENum( 'ABB', 'ABB_CODIGO' )
									ABB->ABB_CODTEC	:= IIF(lMesaOP, c190CodTec, (cAliasTmp)->ABB_CODTEC)

									If !Empty(cNumOS)
										ABB->ABB_ENTIDA	:= 'AB7'
										ABB->ABB_NUMOS	:= cNumOS
									EndIf

									ABB->ABB_CHAVE	:= cChave
									ABB->ABB_DTINI	:= dDtIni
									ABB->ABB_HRINI	:= TecConvHr( SomaHoras( ABR->ABR_HRFIM, "00:01" ) )
									ABB->ABB_DTFIM	:= dDtFim
									ABB->ABB_HRFIM	:= IIF(lMesaOP, c190dHrFim, (cAliasTmp)->ABB_HRFIM)
									ABB->ABB_HRTOT	:= cHrTot
									ABB->ABB_SACRA 	:= 'S'
									ABB->ABB_CHEGOU	:= 'N'
									ABB->ABB_ATENDE	:= '2'
									ABB->ABB_MANUT	:= '1'
									ABB->ABB_ATIVO	:= '1'
									ABB->ABB_IDCFAL	:= IIF(lMesaOP, cConfig, (cAliasTmp)->ABB_IDCFAL)
									ABB->ABB_LOCAL	:= cLocal
									ABB->ABB_TIPOMV := '001'

									//Grava o custo da alocação
									Replace ABB->ABB_CUSTO With (SubtHoras(ABB->ABB_DTINI,ABB->ABB_HRINI,ABB->ABB_DTFIM,ABB->ABB_HRFIM,.T.)*nCusto)
								ABB->(MsUnlock())
								ConfirmSX8()
								
								//Atualizar a TDV com o novo registro
								If At550VldTDV(cAgenda)
									At550UpdTdv(.F.,cAgenda, ABB->ABB_CODIGO, cTipDia )
								EndIf

							EndIf
						Else
							//---------------------------------------------------
							// Atualiza status da agenda
							//---------------------------------------------------
							If IsInCallStack("at190dimn2")
								d190dDtIni := ABB->ABB_DTINI
								c190dHrIni := ABB->ABB_HRINI
								c190dHrFim := ABB->ABB_HRFIM
								d190dDtFim := ABB->ABB_DTFIM
							EndIf
							RecLock( 'ABB', .F. )
								Replace ABB->ABB_MANUT With '1'
								Replace ABB->ABB_ATIVO With cAtivo

								ABB->ABB_DTINI	:= dDtIni
								ABB->ABB_HRINI	:= cHrIni
								ABB->ABB_DTFIM	:= dDtFim
								ABB->ABB_HRFIM	:= cHrFim

								If !EMPTY(ABB->ABB_HRCOUT)
									ABB_HRCOUT := cHrFim
								EndIf

								If !EMPTY(ABB->ABB_OBSERV)
									ABB->ABB_OBSERV := Alltrim(ABB->ABB_OBSERV) + "/"
								Endif
								
								ABB->ABB_OBSERV := Alltrim(ABB->ABB_OBSERV) + cABB_OBSERV
								
								If !(cTipo $ (MANUT_TIPO_FALTA+"/"+MANUT_TIPO_CANCEL+"/"+MANUT_TIPO_TRANSF+"/"+MANUT_TIPO_REALOC+"/"+MANUT_TIPO_COMPEN)) //Falta, Cancelamento ou Transferência
									ABB->ABB_HRTOT	:= cHrTotAnt
								EndIf

								If lUpCusto
									Replace ABB->ABB_CUSTO With (SubtHoras(ABB->ABB_DTINI,ABB->ABB_HRINI,ABB->ABB_DTFIM,ABB->ABB_HRFIM,.T.)*nCusto)
								Else
									Replace ABB->ABB_CUSTO With 0
									Replace ABB->ABB_CODTWZ With ""
								EndIf
							ABB->(MsUnlock())

							//---------------------------------------------------
							// Grava agenda nova, em caso de transferência
							//---------------------------------------------------
							If ( !Empty( cItemOS ) )
								//Grava agenda nova
								AT550GrvABB( (cAliasTmp)->ABB_CODTEC, cItemOS, SubStr( cItemOS, 1, nTamOSAB6 ),;
											 cConfCtr, dDtIni,	cHrIni, dDtFim, cHrFim, /*lInclui*/,;
											 cLocal, cTipoAloc, cAgenda, cTipDia, lCustoTWZ )
							EndIf
						EndIf

						If Empty( cCodSub ) .AND. lPrHora
							DbSelectArea("ABQ")
							ABQ->( DbSetOrder( 1 ) ) // ABQ_FILIAL + ABQ_CONTRT + ABQ_ITEM + ABQ_ORIGEM
							ABQ->( DbSeek( xFilial("ABQ") + cConfig ) )

							TFF->( DbSetOrder( 1 ) )
							If TFF->(DbSeek( ABQ->( ABQ_FILTFF + ABQ_CODTFF )))
								If !Empty(TFF->TFF_QTDHRS)
									TFF->(RecLock("TFF", .F.))
										If TecConvHr(oModel:GetValue( 'ABRMASTER', 'ABR_TEMPO' )) > 0
											TFF->TFF_HRSSAL := TecConvHr(SomaHoras(TecConvHr(TFF->TFF_HRSSAL), oModel:GetValue( 'ABRMASTER', 'ABR_TEMPO' )))
										Else
											TFF->TFF_HRSSAL := TecConvHr(SomaHoras(TecConvHr(TFF->TFF_HRSSAL), TecConvHr(Left(ElapTime(ABB->ABB_HRINI+":00", ABB->ABB_HRFIM+":00"), 5)))) 
										EndIf
									TFF->( MsUnlock() )
								EndIf
							EndIf
						EndIf
						//---------------------------------------------------
						// Grava agenda do substituto
						//---------------------------------------------------
						If ( !Empty( cCodSub ) )
							// Define o tipo da movimentação da alocação
							If Empty(cTipoAloc)
								cTipoAloc := At330TipAlo(.F.)
								If isInCallStack("at190dimn2") .OR. isInCallStack("AT570Subst")
									cTipAlcSta := cTipoAloc
								EndIf
							EndIf

							//Monta horários para a genda do substituto
							If ( cTipo $( MANUT_TIPO_FALTA+"|"+MANUT_TIPO_CANCEL+"|"+MANUT_TIPO_TRANSF+"|"+MANUT_TIPO_AUSENT+"|"+MANUT_TIPO_REALOC+"|"+MANUT_TIPO_COMPEN ) )	//Substituição por falta, cancelamento ou transferência
								dDtIniSub 	:= dDtIni
								cHrIniSub	:= cHrIni
								dDtFimSub	:= dDtFim
								cHrFimSub	:= cHrFim
							ElseIf ( cTipo == MANUT_TIPO_ATRASO ) 		//Substituição do atraso
								If IsInCallStack("at190dimn2")
									dDtIniSub := d190dDtIni
									cHrIniSub := c190dHrIni
								Else
									dDtIniSub 	:= IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))
									cHrIniSub	:= (cAliasTmp)->ABB_HRINI
								EndIf
								dDtFimSub	:= dDtIni
								cHrFimSub	:= cHrIni
							ElseIf ( cTipo == MANUT_TIPO_SAIDAANT )			//Substituição da saída antecipada
								dDtIniSub 	:= dDtFim
								cHrIniSub	:= cHrFim
								If IsInCallStack("at190dimn2")
									dDtFimSub := d190dDtFim
									cHrFimSub := c190dHrFim
								Else
									dDtFimSub	:= IIF(VALTYPE((cAliasTmp)->ABB_DTFIM) == 'D', (cAliasTmp)->ABB_DTFIM , SToD( (cAliasTmp)->ABB_DTFIM ))
									cHrFimSub	:= (cAliasTmp)->ABB_HRFIM
								EndIf
							EndIf

							// Caso substituicao armazena os dados para o memorando
							IF aScan(aAtend,{|x| x[1] == cCodSub}) = 0
								Aadd(aAtend,{cCodSub,cConfig,dDtIniSub,cHrIniSub,dDtFimSub,cHrFimSub,cLocal,cTipoAloc,cAgenda})
							ELSE
								// Grava a ultima data/hora do atendente
								aAtend[aScan(aAtend,{|x| x[1] == cCodSub})][5] := dDtFimSub
								aAtend[aScan(aAtend,{|x| x[1] == cCodSub})][6] := cHrFimSub
							ENDIF

							AT550GrvABB( cCodSub, cChave, cNumOS, cConfig, dDtIniSub,;
							             cHrIniSub, dDtFimSub, cHrFimSub,/*lInclui*/ ,;
							             cLocal, cTipoAloc, cAgenda, cTipDia, lCustoTWZ )
						EndIf

						If lGrvCus .AND. Posicione("AA1",1,xFilial("AA1")+cCodTec,"AA1_CUSTO") > 0
							// Atualiza as informações do aglutinador de custo do item, recalculando conforme o IDCFAL informado
							lRet := At330GrvCus( cConfig, cCodTWZ )
							If !lRet .And. Empty( cDescErro )
								cDescErro := STR0055 // "Não foi possível associar o custo da alocação."
							EndIf
						EndIf
					Else
						lRet := .F.
						cDescErro := STR0057 // "Agenda para manutenção não encontrada."
						Exit
					EndIf
				EndIf

				If At550SetGrvU()
					Exit
				EndIf
				(cAliasTmp)->(DbSkip())
			EndDo

		//----------------------------------------------------------------------------
		// Alteração
		//----------------------------------------------------------------------------
		Case ( nOpc == MODEL_OPERATION_UPDATE )

			cAgenda := oModel:GetValue( 'ABRMASTER', 'ABR_AGENDA' )
			cHrIni  := oModel:GetValue( 'ABRMASTER', 'ABR_HRINI' )
			dDtIni  := oModel:GetValue( 'ABRMASTER', 'ABR_DTINI' )
			cHrFim  := oModel:GetValue( 'ABRMASTER', 'ABR_HRFIM' )
			dDtFim  := oModel:GetValue( 'ABRMASTER', 'ABR_DTFIM' )
			cTipDia := oModel:GetValue( 'ABRMASTER', 'ABR_TIPDIA' )

			lAltDtHrIni := ( cHrIni <> ABR->ABR_HRINI .Or. dDtIni <> ABR->ABR_DTINI )
			lAltDtHrFim := ( cHrFim <> ABR->ABR_HRFIM .Or. dDtFim <> ABR->ABR_DTFIM )

			//Busca agenda original
			ABB->(DbSetOrder(8))	//ABB_FILIAL + ABB_CODIGO

			If ( ABB->( DbSeek( xFilial('ABB') + cAgenda ) ) )

				AA1->( DbSetOrder( 1 ) ) // AA1_FILIAL + AA1_CODTEC
				AA1->( MsSeek(xFilial("AA1")+ ABB->ABB_CODTEC))
				// Não tem como ser Falta, Cancelamento ou Transferência, pois só atualiza quando há alteração de data e horário
				cAtivo := ABB->ABB_ATIVO
				lUpCusto := ( cAtivo == '1' ) // Agenda ativa?
				cConfig := ABB->ABB_IDCFAL
				cCodTWZ := ABB->ABB_CODTWZ

				If cTipo $ cMvHorario

					If ( cTipo == MANUT_TIPO_ATRASO .And. lAltDtHrIni )
						//Atualiza data e hora inicial em caso de atraso, conforme o tempo de atraso.
						If isInCallStack("TECA550")
							cHrIni := TecConvHr( SubHoras( ABR->ABR_HRINIA, "00:01" ) )
						EndIf
						If !IsInCallStack("at190d550")
							SomaDiaHor( @dDtIni, @cHrIni, HoraToInt( cTempo, 2 ) )
						EndIf
					ElseIf ( cTipo == MANUT_TIPO_SAIDAANT .And. lAltDtHrFim )
						//Atualiza data e hora final em caso de saída antecipada, conforme o tempo de saída.
						If isInCallStack("TECA550")
							cHrFim := ABR->ABR_HRFIMA
						EndIf
						
						If !IsInCallStack("at190d550")
							SubtDiaHor( @dDtFim, @cHrFim, HoraToInt( cTempo, 2 ) )
						EndIf
					ElseIf ( cTipo == MANUT_TIPO_HORAEXTRA .And. ( lAltDtHrIni .Or. lAltDtHrFim ) )
						//Atualiza a data e hora de início e fim do atendimento, conforme o tempo de hora extra.

						If isInCallStack("TECA550")
							cHrFim := ABR->ABR_HRFIMA
							cHrIni := TecConvHr( SubHoras( ABR->ABR_HRINIA, "00:01" ) )
						EndIf
						
						If !IsInCallStack("at190d550") .AND. !IsInCallStack("AT190dIMn2")
							SubtDiaHor( @dDtIni, @cHrIni, nTempoIni )
							SomaDiaHor( @dDtFim, @cHrFim, nTempoFim )
						EndIf   

					EndIf

					If lUpCusto
						//Busca o custo do atendente pelo PE ou pelo campo do atendente
						If lCustoTWZ
							// posicina ABQ
							DbSelectArea("ABQ")
							ABQ->( DbSetOrder( 1 ) ) // ABQ_FILIAL + ABQ_CONTRT + ABQ_ITEM + ABQ_ORIGEM
							ABQ->( DbSeek( cConfig ) )

							// posicina TFF
							DbSelectArea("TFF")
							TFF->( DbSetOrder( 1 ) ) // TFF_FILIAL + TFF_COD
							TFF->( DbSeek( ABQ->( ABQ_FILTFF + ABQ_CODTFF ) ) )
							nCusto := ExecBlock("TecXNcusto",.F.,.F.,;
												{ 2, A, AA1->AA1_FUNFIL, AA1->AA1_CDFUNC,;
													TFF->TFF_CONTRT, TFF->TFF_LOCAL, TFF->TFF_CODPAI, TFF->TFF_COD, cConfig } )
						Else
							nCusto := AA1->AA1_CUSTO
						EndIf
					EndIf
					cHrTotAnt := ATTotHora(oModel:GetValue( 'ABRMASTER', 'ABR_DTINI' ),;
				 						oModel:GetValue( 'ABRMASTER', 'ABR_HRINI' ),;
				 						oModel:GetValue( 'ABRMASTER', 'ABR_DTFIM' ),;
				 						oModel:GetValue( 'ABRMASTER', 'ABR_HRFIM' ))

					Reclock( 'ABB', .F. )
						ABB->ABB_DTINI	:= dDtIni
						ABB->ABB_HRINI	:= cHrIni
						ABB->ABB_DTFIM	:= dDtFim
						ABB->ABB_HRFIM	:= cHrFim
						If lUpCusto
							ABB->ABB_CUSTO := (SubtHoras(ABB->ABB_DTINI,ABB->ABB_HRINI,ABB->ABB_DTFIM,ABB->ABB_HRFIM,.T.)*nCusto)
						Else
							ABB->ABB_CUSTO := 0
							ABB->ABB_CODTWZ := ""
						EndIf

						If isInCallStack("TECA550")
							ABB->ABB_HRTOT := cHrTotAnt
						EndIf

					ABB->( MsUnlock() )
				EndIf

				If lPrHora
					DbSelectArea("ABQ")
					ABQ->( DbSetOrder( 1 ) ) // ABQ_FILIAL + ABQ_CONTRT + ABQ_ITEM + ABQ_ORIGEM
					ABQ->( DbSeek( xFilial("ABQ") + cConfig ) )

					TFF->( DbSetOrder( 1 ) )
					If TFF->(DbSeek( ABQ->( ABQ_FILTFF + ABQ_CODTFF )))
						If !Empty(TFF->TFF_QTDHRS)
							TFF->(RecLock("TFF", .F.))
								If !Empty(ABR->ABR_CODSUB) .AND. Empty( cCodSub )
									If TecConvHr(oModel:GetValue( 'ABRMASTER', 'ABR_TEMPO' )) > 0
										TFF->TFF_HRSSAL := TecConvHr(SomaHoras(TecConvHr(TFF->TFF_HRSSAL), oModel:GetValue( 'ABRMASTER', 'ABR_TEMPO' )))
									Else
										TFF->TFF_HRSSAL := TecConvHr(SomaHoras(TecConvHr(TFF->TFF_HRSSAL), TecConvHr(Left(ElapTime(ABB->ABB_HRINI+":00", ABB->ABB_HRFIM+":00"), 5)))) 
									EndIf
								ElseIf !Empty( cCodSub ) .AND. Empty(ABR->ABR_CODSUB)
									If TecConvHr(oModel:GetValue( 'ABRMASTER', 'ABR_TEMPO' )) > 0
										TFF->TFF_HRSSAL := TecConvHr(SubHoras(TecConvHr(TFF->TFF_HRSSAL), oModel:GetValue( 'ABRMASTER', 'ABR_TEMPO' )))
									Else
										TFF->TFF_HRSSAL := TecConvHr(SubHoras(TecConvHr(TFF->TFF_HRSSAL), TecConvHr(Left(ElapTime(ABB->ABB_HRINI+":00", ABB->ABB_HRFIM+":00"), 5)))) 
									EndIf
								EndIf
							TFF->( MsUnlock() )
						EndIf
					EndIf
				EndIf

				//Pega dados da agenda original
				cHrIni 	:= ABB->ABB_HRINI
				dDtIni 	:= ABB->ABB_DTINI
				cHrFim 	:= ABB->ABB_HRFIM
				dDtFim 	:= ABB->ABB_DTFIM
				cChave 	:= ABB->ABB_CHAVE
				cNumOS 	:= ABB->ABB_NUMOS
				cConfig := ABB->ABB_IDCFAL
				cLocal	:= ABB->ABB_LOCAL

				//Atraso
				If ( cTipo == MANUT_TIPO_ATRASO )
					//Pega data e hora da substituição antiga
					cHrIni 	:= ABR->ABR_HRINIA  // pega o valor antes da manutenção de atraso
					dDtIni 	:= ABR->ABR_DTINIA  // pega o valor antes da manutenção de atraso
					cHrFim 	:= ABR->ABR_HRINI
					dDtFim 	:= ABR->ABR_DTINI
				EndIf

				//Saída antecipada
				If ( cTipo == MANUT_TIPO_SAIDAANT )
					//Pega data e hora da substituição antiga
					cHrIni 	:= ABR->ABR_HRFIM
					dDtIni 	:= ABR->ABR_DTFIM
					cHrFim 	:= ABR->ABR_HRFIMA  // pega o valor antes da manutenção de saída antecipada
					dDtFim 	:= ABR->ABR_DTFIMA  // pega o valor antes da manutenção de saída antecipada
				EndIf

				ABB->( DbSetOrder(1) )	//ABB_FILIAL + ABB_CODTEC + DTOS(ABB_DTINI) + ABB_HRINI + DTOS(ABB_DTFIM) + ABB_HRFIM

				If ( ABB->( DbSeek( xFilial('ABB') + ABR->ABR_CODSUB + DToS( dDtIni ) + cHrIni + DToS( dDtFim ) + cHrFim ) ) )
					If (cTipo == MANUT_TIPO_CANCEL .OR. cTipo == MANUT_TIPO_FALTA .OR. cTipo == MANUT_TIPO_REALOC .OR. cTipo == MANUT_TIPO_COMPEN) .AND. !EMPTY(ABR->ABR_AGENDA)
						While xFilial('ABB') == ABB->ABB_FILIAL .AND.;
								ABR->ABR_CODSUB == ABB->ABB_CODTEC .AND.;
								DToS( dDtIni ) == DTOS(ABB->ABB_DTINI) .AND.;
								cHrIni == ABB->ABB_HRINI .AND.;
								DToS( dDtFim ) == DTOS(ABB->ABB_DTFIM) .AND.;
								cHrFim == ABB->ABB_HRFIM .AND. !EOF()
						
							If ABB->ABB_IDCFAL == GetIdcFAL(ABR->ABR_AGENDA)
								Exit
							Else
								ABB->(DbSkip())
							EndIf
						End
					EndIf
					
					//Alteração do substituto
					If ( ABR->ABR_CODSUB != cCodSub )
						// remove vínculo com a tabela de agenda por escala
						If At550VldTDV(ABB->ABB_CODIGO)
							At550UpdTdv(.T., ABB->ABB_CODIGO)
						EndIf

						dDtIniMdt := ABB->ABB_DTINI
						dDtFimMdt := ABB->ABB_DTFIM
						cIdcFalMdt:= ABB->ABB_IDCFAL

						//Apaga agenda do substituto anterior
						Reclock( 'ABB', .F. )
							ABB->( DbDelete() )
						ABB->(MsUnlock())

						If lMdtGS //Integração entre o SIGAMDT x SIGATEC
							// posicina TFF
							DbSelectArea("TFF")
							TFF->( DbSetOrder(1)) //TFF_FILIAL+TFF_COD
						
							//posicina TN5
							dbSelectArea("TN5")
							TN5->(dbSetOrder(1)) //TN5_FILIAL+TN5_CODTAR
							
							If TFF->( ColumnPos("TFF_RISCO")) > 0 .And. TN5->(ColumnPos("TN5_LOCAL")) > 0 .And. TN5->(ColumnPos("TN5_POSTO")) > 0
						
								//posicina ABQ
								DbSelectArea("ABQ")
								ABQ->( DbSetOrder(1)) //ABQ_FILIAL+ABQ_CONTRT+ABQ_ITEM+ABQ_ORIGEM
							
								//posicina TN6
								dbSelectArea("TN6")
								TN6->(dbSetOrder(1)) //TN6_FILIAL+TN6_CODTAR+TN6_MAT+DTOS(TN6_DTINIC)
								
								cCDFUNC := Posicione("AA1",1,xFilial("AA1")+ABB->ABB_CODTEC, "AA1_CDFUNC")
								
								If ABQ->(DbSeek(xFilial("ABQ")+cIdcFalMdt)) .And.; //Integração entre o SIGAMDT x SIGATEC
									TFF->(DbSeek(ABQ->(ABQ_FILTFF+ABQ_CODTFF))) .And.;
									TFF->TFF_RISCO == "1" .And. !Empty(cCDFUNC)
									
									//Query para verificar se não existe mais ABB para realizar a exclusão da TN6
									cAbbAlias := getNextAlias()
									BeginSQL Alias cAbbAlias
										Select ABB.R_E_C_N_O_ FROM %Table:ABB% ABB
											WHERE ABB.ABB_FILIAL = %xFilial:ABB%
												AND ABB.ABB_CODTEC = %Exp:ABR->ABR_CODSUB%
												AND ABB.ABB_DTINI = %Exp:DToS( dDtIniMdt )%
												AND ABB.ABB_DTFIM = %Exp:DToS( dDtFimMdt )%
												AND ABB.ABB_IDCFAL = %Exp:cIdcFalMdt%
												AND ABB.ABB_ATIVO = '1'
												AND ABB.ABB_TIPOMV <> '001'
												AND ABB.%NotDel%
									EndSQL

									If (cAbbAlias)->(Eof())
							
										cQueryTN5	:= GetNextAlias()
								
										BeginSql Alias cQueryTN5
										
											SELECT TN5.R_E_C_N_O_ TN5RECNO
											FROM %Table:TN5% TN5
											WHERE TN5.TN5_FILIAL	= %exp:xFilial('TN5')%
												AND TN5.TN5_LOCAL	= %exp:TFF->TFF_LOCAL%
												AND TN5.TN5_POSTO	= %exp:TFF->TFF_FUNCAO% 
												AND TN5.%NotDel%
										EndSql

										cFilSRA := Posicione("AA1",1,xFilial("AA1")+ABR->ABR_CODSUB, "AA1_FUNFIL") 

										If cFilSRA != cFilAnt
											lAlocMtFil := .T.
											cBkpFil	:= cFilAnt
											cFilAnt := cFilSRA
										Else
											lAlocMtFil := .F.
										EndIf
										If (cQueryTN5)->(!EOF())
											TN5->(DbGoTo((cQueryTN5)->TN5RECNO))
											If TN6->(dbSeek(xFilial("TN6")+TN5->TN5_CODTAR+cCDFUNC+Dtos(dDtIniMdt))) .And. dDtFimMdt == TN6->TN6_DTTERM
												RecLock("TN6",.F.)
													TN6->( DbDelete() )
												TN6->(MsUnLock())
											Endif
										Endif

										If lAlocMtFil
											cFilAnt	:= cBkpFil
										EndIf
										(cQueryTN5)->(DbCloseArea())
									EndIf
									
									(cAbbAlias)->(DbCloseArea())

								Endif	
							Endif
						Endif	
					Else
						lIncluiABB := .F.
					EndIf
				EndIf

				If ( !Empty( cCodSub ) )
					//Atraso
					If ( cTipo == MANUT_TIPO_ATRASO )
						//Pega data e hora para a nova substituição
						cHrIni 	:= ABB->ABB_HRINI
						dDtIni 	:= ABB->ABB_DTINI
						cHrFim 	:= TecConvHr( SubHoras( oModel:GetValue( 'ABRMASTER', 'ABR_HRINI' ), "00:01" ) )
						dDtFim 	:= oModel:GetValue( 'ABRMASTER', 'ABR_DTINI' )
						If EMPTY(cHrIni)
							cHrIni := ABR->ABR_HRINIA
						EndIf
						If Empty(dDtIni)
							dDtIni := ABR->ABR_DTINIA
						EndIf
					EndIf

					//Atraso
					If ( cTipo == MANUT_TIPO_SAIDAANT )
						//Pega data e hora para a nova substituição
						cHrIni 	:= TecConvHr( SomaHoras( oModel:GetValue( 'ABRMASTER', 'ABR_HRFIM' ), "00:01" ) )
						dDtIni 	:= oModel:GetValue( 'ABRMASTER', 'ABR_DTFIM' )
						cHrFim 	:= ABB->ABB_HRFIM
						dDtFim 	:= ABB->ABB_DTFIM
						If EMPTY(cHrFim)
							cHrFim := ABR->ABR_HRFIMA
						EndIf
						If Empty(dDtFim)
							dDtFim := ABR->ABR_DTFIMA
						EndIf
					EndIf

					// Define o tipo da movimentação da alocação
					If Empty(cTipoAloc)
						cTipoAloc := At330TipAlo(.F.)
						If isInCallStack("SubstLote")
							cTipAlcSta := cTipoAloc
						EndIf
					EndIf

					//Grava agenda do substituto atual
					AT550GrvABB( cCodSub, cChave, cNumOS, cConfig, dDtIni,;
							     cHrIni, dDtFim, cHrFim, lIncluiABB, cLocal, ;
							     cTipoAloc, cAgenda, cTipDia, lCustoTWZ )
				EndIf

				If lGrvCus .AND. Posicione("AA1",1,xFilial("AA1")+cCodTec,"AA1_CUSTO") > 0
					// Atualiza as informações do aglutinador de custo do item, recalculando conforme o IDCFAL informado
					lRet := At330GrvCus( cConfig, cCodTWZ )
					If !lRet .And. Empty( cDescErro )
						cDescErro := STR0055 // "Não foi possível associar o custo da alocação."
					EndIf
				EndIf
				lRet := lRet .And. FwFormCommit( oModel )
				If !lRet .And. Empty( cDescErro )
					cDescErro := STR0056 // "Problemas na gravação nativa do MVC."
				EndIf
			Else
				lRet := .F.
				cDescErro := STR0057 // "Agenda para manutenção não encontrada."
			EndIf

	End Case

If ( !lRet )

	If Empty(cDescErro)
		cDescErro := STR0058 // "Manutenção da agenda não pode acontecer."
	EndIf

	oModel:GetModel():SetErrorMessage( oModel:GetId() ,"TFL_DTFIM" ,"ABRMASTER", "ABR_CODSUB" ,'',;
			cDescErro, STR0059 )  // "Corrija as informações e tente novamente"

	RollbackSX8()
	DisarmTransaction()
	Break
Else
	ConfirmSX8()

	// Apos gravacao chama rotina de geracao do memorando caso houver substituicao do atendente
	If Len( aAtend ) > 0
		At550FilCt(aAtend)
	EndIf
EndIf

End Transaction

IIf( oModel:nOperation != 5, RestArea( aAreaTMP ), Nil )
RestArea( aAreaABB)
RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AT550VldModel
Valida os dados do model.

@sample 	AT550VldModel( oModel )

@param		oModel		Objeto com o Model para efetuar a validação.
@return	lRet		Indica se os dados são válidos.

@author	Danilo Dias
@since		21/02/2013
@version	P11.8
/*/
//-------------------------------------------------------------------
Function AT550VldModel( oModel )

Local aArea		:= GetArea()
Local aAreaABR	:= ABR->(GetArea())
Local aAreaABB  := '' 
Local lRet			:= .T.
Local cAgenda		:= oModel:GetValue( 'ABRMASTER', 'ABR_AGENDA' )
Local cMotivo		:= oModel:GetValue( 'ABRMASTER', 'ABR_MOTIVO' )
Local dDtIni		:= oModel:GetValue( 'ABRMASTER', 'ABR_DTINI' )
Local cHrIni		:= oModel:GetValue( 'ABRMASTER', 'ABR_HRINI' )
Local dDtFim		:= oModel:GetValue( 'ABRMASTER', 'ABR_DTFIM' )
Local cHrFim		:= oModel:GetValue( 'ABRMASTER', 'ABR_HRFIM' )
Local cItemOS		:= oModel:GetValue( 'ABRMASTER', 'ABR_ITEMOS' )
Local cTempo		:= oModel:GetValue( 'ABRMASTER', 'ABR_TEMPO' )
Local cAtendSub		:= oModel:GetValue( 'ABRMASTER', 'ABR_CODSUB' )
Local cTipo  		:= AT550Tipo()
Local nOpc			:= 0
Local aManut		:= {}
Local lAtraso		:= .F.
Local lSaidaAnt 	:= .F.
Local lHrExtraIni	:= .F.
Local lHrExtraFim	:= .F.
Local nExtra		:= 0
Local lPodeRepl 	:= cTipo $ MANUT_TIPO_FALTA + "," + MANUT_TIPO_CANCEL + "," + MANUT_TIPO_TRANSF + "," + MANUT_TIPO_REALOC + "," + MANUT_TIPO_COMPEN
Local aRecnosMk 	:= At540GetMk()
Local nX 			:= 0
Local aSaveTmp 		:= {}
Local aAux			:= {}
Local nValorMark 	:= 0
Local cHrIniDel
Local dDtIniDel
Local cHrFimDel
Local dDtFimDel
Local cAbbAlias
Local cAgend        := ""
Local dDtRef      
Local lConfirm      := cTipo $ MANUT_TIPO_SAIDAANT + "," + MANUT_TIPO_HORAEXTRA
Local lPonto := .F.
Local lIncHE	:= .F.

nOpc := oModel:GetOperation()

DbSelectArea('ABR')	//Manutenções da Agenda
ABR->(DbSetOrder(1))	//ABR_FILIAL + ABR_AGENDA + ABR_MOTIVO

aAreaABB := ABB->(GetArea())
dbSelectArea("ABB")
ABB->(dbSetOrder(8)) 
If ABB->(DbSeek(xFilial("ABB")+(cAliasTmp)->ABB_CODIGO))
	If EMPTY(ABB->ABB_HRCHIN) .AND. EMPTY(ABB->ABB_HRCOUT) .AND. cTipo == MANUT_TIPO_HORAEXTRA
		nTempoIni	:= SubtHoras( dDtIni, cHrIni, IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI )),  (cAliasTmp)->ABB_HRINI)
	Endif
EndIf	
RestArea(aAreaABB)

nTempoFim	:= SubtHoras( IIF(VALTYPE((cAliasTmp)->ABB_DTFIM) == 'D', (cAliasTmp)->ABB_DTFIM , SToD( (cAliasTmp)->ABB_DTFIM )), (cAliasTmp)->ABB_HRFIM, dDtFim, cHrFim )

//-------------------------------------------------
//  Passa no array os registros selecionados
// validando se houve a seleção de fato
// e se pode realizar a replicação da manutenção
If nOpc == MODEL_OPERATION_INSERT .And. lPodeRepl .And. Len( aRecnosMk ) > 0

	For nX := 1 To Len( aRecnosMk )
		//-------------------------------------------------------
		//  Identifica se há necessidade de indicação para a replicação
		If ( aScan( aRecnosMk, { |pos| !aRecnosMk[nX,2] ; // item não marcado no browse anterior
									.And. aRecnosMk[nX,1] <> pos[1] ; // Recnos diferentes (ou seja item diferente)
									.And. aRecnosMk[nX,4] == pos[4] ; // mesma data de referência
									.And. aRecnosMk[nX,5] ;  // agenda ativa
									.And. pos[2]  } ) > 0 ) // item da mesma data de referência está marcado

			aRecnosMk[nX,3] := .T.
		EndIf

	Next nX

	lPodeRepl := aScan( aRecnosMk, {|x| x[3] } ) > 0

	lPodeRepl := ( lPodeRepl .And. ;
		AVISO( STR0042, STR0040 + CHR(13)+CHR(10) + ; // "Atenção" ### "As manutenções podem ser replicadas para outros período no mesmo dia."
						  STR0041, {STR0043, STR0044 } ) == 1 )// "Deseja replicar?" ### "Sim" ### "Não"

	aSaveTmp := (cAliasTmp)->( GetArea() )

	nValorMark := If ( lPodeRepl, 1, 0)

	//-------------------------------------------------------------------
	// Atualiza a tabela temporária com a indicação de marcação ou não
	If !(At550SetGrvU())
		For nX := 1 To Len( aRecnosMk )

			If aRecnosMk[nX, 3]

				(cAliasTmp)->( DbGoTo( aRecnosMk[nX, 1] ) )
				Reclock( (cAliasTmp), .F. )
					REPLACE	ABB_OK 	WITH 	nValorMark
				(cAliasTmp)->( MsUnlock() )

			EndIf
		Next
	EndIf
	RestArea( aSaveTmp )
	RestArea( aArea )

Else
	lPodeRepl := .F.
EndIf

//----------------------------------------------------------------------
// Valida preenchimento dos campos
//----------------------------------------------------------------------
If ( lRet ) .And. ( ( nOpc == MODEL_OPERATION_INSERT ) .Or. ( nOpc == MODEL_OPERATION_UPDATE ) )
	Do Case
		//Falta
		Case cTipo == MANUT_TIPO_FALTA
			lRet := .T.
		//Realocação
		Case cTipo == MANUT_TIPO_REALOC
			lRet := .T.
		//Compensação
		Case cTipo == MANUT_TIPO_COMPEN
			lRet := .T.
		//Atraso
		Case cTipo == MANUT_TIPO_ATRASO
			If ( ( Empty( cHrIni ) ) .Or. ( Empty( dDtIni ) ) ) .And. ( Empty( cTempo ) )
				Help( " ", 1, "AT550VldModel", , STR0007, 1, 0 )	//'Informe a data e hora de início do atendimento ou o tempo de atraso.'
				lRet := .F.
			EndIf
		//Saída Antecipada
		Case cTipo == MANUT_TIPO_SAIDAANT
			If ( ( Empty( cHrFim ) ) .Or. ( Empty( dDtFim ) ) ) .And. ( Empty( cTempo ) )
				Help( " ", 1, "AT550VldModel", , STR0008, 1, 0 )	//'Informe a data e hora de fim do atendimento ou o tempo da saída antecipada.'
				lRet := .F.
			EndIf
		//Hora Extra
		Case cTipo == MANUT_TIPO_HORAEXTRA
			If ( Empty( cHrIni ) .And. Empty( dDtIni ) ) .And. ( Empty( cHrFim ) .And. Empty( dDtFim ) )
				Help( " ", 1, "AT550VldModel", , STR0009, 1, 0 )	//'Informe a data e hora de início ou a data e hora de fim do atendimento para registrar a hora extra.'
				lRet := .F.
			EndIf
		//Cancelamento
		Case cTipo == MANUT_TIPO_CANCEL
			lRet := .T.
		//Transferência
		Case cTipo == MANUT_TIPO_TRANSF
			If ( Empty( cItemOS ) )
				Help( " ", 1, "AT550VldModel", , STR0010, 1, 0 )	//'Informe o item da OS para onde o atendente será transferido.'
				lRet := .F.
			EndIf

			If ( Empty( cConfCtr ) )
				Help( " ", 1, "AT550VldModel", , STR0024, 1, 0 )	//"Nenhuma configuração de contrato foi selecionada. Acione a consulta do Item da OS, selecione um item e confirme para mostrar as configurações do contrato e selecionar uma para a transferência."
				lRet := .F.
			EndIf
		OtherWise
			lRet := .T.
	EndCase
Else
	If lRet
		// nOpc == MODEL_OPERATION_DELETE
		If ABR->( DbSeek( xFilial('ABR')+cAgenda+cMotivo ) )
			If !( lRet := IsLastManut( cAgenda, ABR->ABR_MANUT ) )
				Help( " ", 1, "AT550VldModel", , STR0045, 1, 0 ) // "Para excluir esta manutenção exclua a última manutenção antes."
			EndIf
		Else
			 lRet := .F.
			 Help( " ", 1, "AT550VldModel", , STR0046, 1, 0 ) // "Registro não encontrado para exclusão."
		EndIf
		//Verifica se agenda foi atendida
		If ( (cAliasTmp)->ABB_ATENDE == '1' .And. (cAliasTmp)->ABB_CHEGOU == 'S')
			aAreaABB := ABB->(GetArea())
			DbSelectArea("ABB")
			ABB->(DbSetOrder(8))//ABB_FILIAL+ABB_CODIGO
			ABB->(DbSeek(xFilial("ABB")+(cAliasTmp)->ABB_CODIGO))
			lPonto := At550VerChe((cAliasTmp)->ABB_CODIGO)
			If (ABB->ABB_SAIU <> 'S' .AND. EMPTY(ABB->ABB_HRCHIN)  .AND. EMPTY(ABB->ABB_HRCOUT)) .OR. lPonto
				lRet := .F.
				Help( " ", 1, "AT550VldModel", , STR0011 + DToC(IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))) + STR0026 , 1, 0 )	//"A Agenda do dia " | " já foi atendida e não pode sofer manutenção."
			Else 
				If !lConfirm
					lRet := .F.
					Help( " ", 1, "AT550VldModel", , STR0092 , 1, 0 )	//"O horário de chegada já foi confirmado. Para modificar o horário de saída, utilize uma manutenção de Saída Antecipada ou Hora Extra."
				EndIf
			EndIf
			RestArea(aAreaABB)	
		EndIf
	EndIf
EndIf

//----------------------------------------------------------------------
// Valida regras de negócio para cada agenda que sofrerá alterações
//----------------------------------------------------------------------
If ( lRet ) .And. ( nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE )
	//--------------------------------------------------
	//  Reposiciona no início da tabela para a validação
	// ocorrer sem problemas, só na inclusão ocorre manutenção em massa
	If nOpc == MODEL_OPERATION_INSERT .AND. !(At550SetGrvU())
		(cAliasTmp)->( DbGoTop() )
	EndIf

	While lRet .And. (cAliasTmp)->(!Eof())

		cAgend  := (cAliasTmp)->ABB_CODIGO
		dDtIni	:= IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))
		cHrIni	:= (cAliasTmp)->ABB_HRINI
		dDtFim	:= IIF(VALTYPE((cAliasTmp)->ABB_DTFIM) == 'D', (cAliasTmp)->ABB_DTFIM , SToD( (cAliasTmp)->ABB_DTFIM ))
		cHrFim	:= (cAliasTmp)->ABB_HRFIM

		If At550SetGrvU() .OR. ( (cAliasTmp)->ABB_OK == 1 )	//Verifica apenas se a linha estivar marcada

			If ( cTipo == MANUT_TIPO_ATRASO )
				//Atualiza data e hora inicial em caso de atraso, conforme o tempo de atraso.
				SomaDiaHor( @dDtIni, @cHrIni, HoraToInt( cTempo, 2 ) )
			ElseIf ( cTipo == MANUT_TIPO_SAIDAANT )
				//Atualiza data e hora final em caso de saída antecipada, conforme o tempo de saída.
				SubtDiaHor( @dDtFim, @cHrFim, HoraToInt( cTempo, 2 ) )
			ElseIf ( cTipo == MANUT_TIPO_HORAEXTRA )
				//Atualiza a data e hora de início e fim do atendimento, conforme o tempo de hora extra.
				SubtDiaHor( @dDtIni, @cHrIni, nTempoIni )
				SomaDiaHor( @dDtFim, @cHrFim, nTempoFim )
			EndIf

			//Verifica se agenda foi atendida
			If ( (cAliasTmp)->ABB_ATENDE == '1' .And. (cAliasTmp)->ABB_CHEGOU == 'S' )
				aAreaABB := ABB->(GetArea())
				DbSelectArea("ABB")
				ABB->(DbSetOrder(8))//ABB_FILIAL+ABB_CODIGO
				ABB->(DbSeek(xFilial("ABB")+(cAliasTmp)->ABB_CODIGO))
				lPonto := At550VerChe((cAliasTmp)->ABB_CODIGO)
				If (ABB->ABB_SAIU <> 'S' .AND. EMPTY(ABB->ABB_HRCHIN)  .AND. EMPTY(ABB->ABB_HRCOUT)) .OR. lPonto
					lRet := .F.
					Help( " ", 1, "AT550VldModel", , STR0011 + DToC(IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))) + STR0026 , 1, 0 )	//"A Agenda do dia " | " já foi atendida e não pode sofer manutenção."
					Exit
				Else 
					If !lConfirm 
						lRet := .F.
						Help( " ", 1, "AT550VldModel", , STR0092 , 1, 0 )	//"O horário de chegada já foi confirmado. Para modificar o horário de saída, utilize uma manutenção de Saída Antecipada ou Hora Extra."
						Exit
					EndIf
				EndIf
				RestArea(aAreaABB)
			EndIf
			
			If nOpc == MODEL_OPERATION_INSERT
				//Monta array com manutenções realizadas anteriormente na agenda
				aManut := AT550QryMan( (cAliasTmp)->ABB_CODIGO )

				//Verifica se pode incluir mais de uma hora extra
				If len(aManut) > 0 .And. cTipo == "04"
					lIncHE := At550ChkTp(aManut,cTipo,cMotivo)
				EndIf

				//Não permite mais de uma manutenção do mesmo tipo
				If ( AScan( aManut, { |x| x[2] == cTipo } ) > 0 ) .And. !lIncHE
					lRet := .F.
					Help( " ", 1, "AT550VldModel", , STR0011 + DToC(IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))) + STR0012 , 1, 0 )	//'A agenda do dia ' | " já possui manutenção por motivo do mesmo tipo. Utilize a opção Detalhes para alterar essa manutenção."
					Exit
				EndIf

				//Verifica se tem atraso registrado
				If ( AScan( aManut, { |x| x[2] == MANUT_TIPO_ATRASO } ) > 0 )
					lAtraso := .T.
				EndIf

				//Verifica se tem saída antecipada registrada
				If ( AScan( aManut, { |x| x[2] == MANUT_TIPO_SAIDAANT } ) > 0 )
					lSaidaAnt := .T.
				EndIf

				//Verifica se tem hora extra registrada
				nExtra := AScan( aManut, { |x| x[2] == MANUT_TIPO_HORAEXTRA } )
				If ( nExtra > 0 )
					//Hora extra antes do horário
					If ( SubtHoras( SToD( aManut[nExtra][3] ), aManut[nExtra][4], IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI )), (cAliasTmp)->ABB_HRINI ) > 0 )
						lHrExtraIni := .T.
					EndIf
					//Hora extra depois do horário
					If ( SubtHoras( IIF(VALTYPE((cAliasTmp)->ABB_DTFIM) == 'D', (cAliasTmp)->ABB_DTFIM , SToD( (cAliasTmp)->ABB_DTFIM )), (cAliasTmp)->ABB_HRFIM, SToD( aManut[nExtra][5] ), aManut[nExtra][6] ) > 0 )
						lHrExtraFim := .T.
					EndIf
				EndIf

				//Verifica se agenda está ativa
				If ( (cAliasTmp)->ABB_ATIVO == '2' )
					lRet := .F.
					Help( " ", 1, "AT550VldModel", , STR0011 + DToC(IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))) + STR0025 , 1, 0 )	//"A Agenda do dia " | " foi desativada e não pode sofer manutenção."
					Exit
				EndIf
			EndIf

			//--------------------------------------------------------------
			//  Valida por tipo do motivo de manutenção
			//--------------------------------------------------------------
			//Atraso
			If ( cTipo == MANUT_TIPO_ATRASO )

				//Tempo de atraso anterior ao início do atendimento
				If ( Empty( cTempo ) ) .Or. ( cTempo == '00:00' )
					If 	Empty( StrTran( StrTran( cTempo, ':', '' ), '0', '' ) ) .Or. ( ( dDtIni < IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI )) ) .Or.;
						( ( dDtIni == IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI )) ) .And. ( cHrIni <= StrTran( (cAliasTmp)->ABB_HRINI, ':', '' ) ) ) )
						lRet := .F.
						Help( " ", 1, "AT550VldModel", , STR0013 , 1, 0 )	//'A data e hora inicial deve ser superior à original.'
						Exit
					EndIf
				EndIf

				//Tempo de atraso superior ao final do atendimento
				If ( Empty( cTempo ) ) .Or. ( cTempo == '00:00' )
					If 	( dDtIni > IIF(VALTYPE((cAliasTmp)->ABB_DTFIM) == 'D', (cAliasTmp)->ABB_DTFIM , SToD( (cAliasTmp)->ABB_DTFIM )) ) .Or.;
						( ( dDtIni == IIF(VALTYPE((cAliasTmp)->ABB_DTFIM) == 'D', (cAliasTmp)->ABB_DTFIM , SToD( (cAliasTmp)->ABB_DTFIM )) ) .And. ( cHrIni >= StrTran( (cAliasTmp)->ABB_HRFIM, ':', '' ) ) )
						lRet := .F.
						Help( " ", 1, "AT550VldModel", , STR0014 , 1, 0 )	//'A data e hora inicial deve ser inferior à hora final da agenda.'
						Exit
					EndIf
				Else
					If ( HoraToInt( cTempo ) > SubtHoras( IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI )), (cAliasTmp)->ABB_HRINI, IIF(VALTYPE((cAliasTmp)->ABB_DTFIM) == 'D', (cAliasTmp)->ABB_DTFIM , SToD( (cAliasTmp)->ABB_DTFIM )), (cAliasTmp)->ABB_HRFIM ) )
						lRet := .F.
						Help( " ", 1, "AT550VldModel", , STR0015 , 1, 0 )	//'O tempo de atraso não pode ser maior que o tempo de atendimento.'
						Exit
					EndIf
				EndIf

				If ( lHrExtraIni )
					lRet := .F.
					Help( " ", 1, "AT550VldModel", , STR0028 + STR0011 + DToC(IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))) + STR0029 , 1, 0 )	//'Não é possível registrar o atraso. ' | "A agenda do dia " | ' possui hora extra antes do horário inicial.'
					Exit
				EndIf

			//Saída Antecipada
			ElseIf ( cTipo == MANUT_TIPO_SAIDAANT )

				//Saída antecipada fora do horário de atendimento
				If ( Empty( StrTran( StrTran( cTempo, ':', '' ), '0', '' ) ) ) .Or. ;
						( dDtFim == IIF(VALTYPE((cAliasTmp)->ABB_DTFIM) == 'D', (cAliasTmp)->ABB_DTFIM , SToD( (cAliasTmp)->ABB_DTFIM )) .And. ;
				 		( cHrFim >= (cAliasTmp)->ABB_HRFIM ) .Or. ( cHrFim <= (cAliasTmp)->ABB_HRINI ) )
					//Verifica se a data de saida é maior e o horario, para casos de virada de dia
					If (IIF(VALTYPE((cAliasTmp)->ABB_DTFIM) == 'D', (cAliasTmp)->ABB_DTFIM , SToD( (cAliasTmp)->ABB_DTFIM )) > dDtIni .And. cHrFim >= (cAliasTmp)->ABB_HRFIM)
						lRet := .F.
						Help( " ", 1, "AT550VldModel", , STR0016 , 1, 0 )	//'A hora final deve ser inferior à hora final da agenda e superior à hora inicial.'
						Exit
					EndIf
				EndIf

				//Já possui hora extra após o horário
				If ( lHrExtraFim )
					lRet := .F.
					Help( " ", 1, "AT550VldModel", , STR0030 + STR0011 + DToC(IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))) + STR0031 , 1, 0 )	//'Não é possível registrar a saída antecipada. ' | "A agenda do dia " | ' possui hora extra antes do horário inicial.'
					Exit
				EndIf

			//Hora extra
			ElseIf ( cTipo == MANUT_TIPO_HORAEXTRA )

				//Tempo de hora extra maior que zero
				If ( ( nTempoIni + nTempoFim ) <= 0 )
					lRet := .F.
					Help( " ", 1, "AT550VldModel", , STR0032, 1, 0 )	//'O tempo total de hora extra deve ser maior que Zero'
					Exit
				EndIf

				//Já possui atraso e saída antecipada registrada
				If ( lAtraso .And. lSaidaAnt )
					lRet := .F.
					Help( " ", 1, "AT550VldModel", , STR0011 + DToC(IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))) + STR0033 + STR0034 , 1, 0 )	//"A agenda do dia " | " possui atraso e saída antecipada registrada." | "Para incluir a hora extra exclua o atraso ou a saída antecipada."
					Exit
				EndIf

				//Já possui atraso e a hora extra é anterior ao início da agenda
				If ( lAtraso .And. nTempoIni > 0 )
					lRet := .F.
					Help( " ", 1, "AT550VldModel", , STR0011 + DToC(IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))) + STR0035 + STR0036 , 1, 0 )	//"A agenda do dia " | " possui atraso registrado." | "Não é possível incluir hora extra anterior ao horário inicial e atraso ao mesmo tempo."
					Exit
				EndIf

				//Já possui saída antecipada e a hora extra é superior ao final da agenda
				If ( lSaidaAnt .And. nTempoFim > 0 )
					lRet := .F.
					Help( " ", 1, "AT550VldModel", , STR0011 + DToC(IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))) + STR0037 + STR0038 , 1, 0 )	//"A agenda do dia " | " possui saída antecipada registrada." | "Não é possível incluir hora extra superior ao horário final e saída antecipada ao mesmo tempo."
					Exit
				EndIf

			EndIf

			If lRet
				If !Empty(cAgend)
					DbSelectArea("TDV")
					TDV->(DbSetOrder(1))
					If TDV->(dbseek(xFilial("TDV")+cAgend))
						dDtRef := TDV->TDV_DTREF
						lRet := TxExitCon(cAtendSub, dDtRef, dDtRef)
					Else
						lRet := TxExitCon(cAtendSub, dDtIni, dDtFim)
					EndIf
				Else
					lRet := TxExitCon(cAtendSub, dDtIni, dDtFim)
				EndIf	
				//Verifica se o atendente substituto possui convocação para os períodos selecionados
				If !lRet
					Help( " ", 1, "AT550VldModel", , STR0073 +Dtoc(dDtIni) +"-" + DtoC(dDtFim)+STR0074, 1, 0 )	//"Não existe convocação para o período de substituição ["##"]  para o atendente intermitente."
					Exit
				EndIf
			EndIf
		EndIf

		// -------------------------------------------------------------------
		//  Somente a inserção permite manutenção em mais de um registro
		// por isso quando for inclusão usa Skip e alteração o Exit
		If nOpc == MODEL_OPERATION_INSERT
			If At550SetGrvU()
				Exit
			EndIf
			(cAliasTmp)->( DbSkip() )
		Else
			Exit
		EndIf

	EndDo
EndIf

If nOpc == MODEL_OPERATION_DELETE
	If ( !Empty( cAtendSub ) )

		//Pega dados da agenda original
		cHrIniDel 	:= (cAliasTmp)->ABB_HRINI
		dDtIniDel 	:= IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))
		cHrFimDel 	:= (cAliasTmp)->ABB_HRFIM
		dDtFimDel 	:= IIF(VALTYPE((cAliasTmp)->ABB_DTFIM) == 'D', (cAliasTmp)->ABB_DTFIM , SToD( (cAliasTmp)->ABB_DTFIM ))

		//Atraso
		If ( cTipo == MANUT_TIPO_ATRASO )
			//Pega data e hora da substituição
			cHrIniDel 	:= (cAliasTmp)->ABB_HRINI
			dDtIniDel 	:= IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D', (cAliasTmp)->ABB_DTINI , SToD( (cAliasTmp)->ABB_DTINI ))
			cHrFimDel 	:= TecConvHr( SubHoras( cHrIni, "00:01" ) )
			dDtFimDel 	:= dDtIni
		//Saída antecipada
		ElseIf ( cTipo == MANUT_TIPO_SAIDAANT )
			//Pega data e hora da substituição
			cHrIniDel 	:= TecConvHr( SomaHoras( cHrFim, "00:01" ) )
			dDtIniDel 	:= dDtFim
			cHrFimDel 	:= (cAliasTmp)->ABB_HRFIM
			dDtFimDel 	:= IIF(VALTYPE((cAliasTmp)->ABB_DTFIM) == 'D', (cAliasTmp)->ABB_DTFIM , SToD( (cAliasTmp)->ABB_DTFIM ))
		ElseIf ( cTipo == MANUT_TIPO_AUSENT )
			//Pega data e hora da ausência
			cHrIniDel 	:= cHrIni
			dDtIniDel 	:= dDtFim
			cHrFimDel 	:= cHrFim
			dDtFimDel 	:= dDtFim
		EndIf

		// Query para posicionar na ABB correta da agenda de substituto, para fins de atualização na operação DELETE
		cAbbAlias := getNextAlias()
		BeginSQL Alias cAbbAlias
			Select R_E_C_N_O_ FROM %Table:ABB% ABB
				WHERE ABB.ABB_FILIAL = %xFilial:ABB%
					AND ABB.ABB_CODTEC = %Exp:cAtendSub%
					AND ABB.ABB_DTINI = %Exp:DToS( dDtIniDel )%
					AND ABB.ABB_HRINI = %Exp:cHrIniDel%
					AND ABB.ABB_DTFIM = %Exp:DToS( dDtFimDel )%
					AND ABB.ABB_HRFIM = %Exp:cHrFimDel%
					AND ABB.ABB_ATIVO = '1'
					AND ABB.ABB_TIPOMV <> '001'
					AND (ABB.ABB_ATENDE = '1' AND ABB.ABB_CHEGOU = 'S')
					AND ABB.%NotDel%
		EndSQL

		If (cAbbAlias)->(!Eof())
			lRet := .F.
			Help( " ", 1, "AT550VldModel", , STR0084, 1, 0 ) //"Não é possível excluir esta manutenção pois a agenda do atendente substituto já foi confirmada."
		EndIf
		(cAbbAlias)->(DbCloseArea())
	EndIf
	If isInCallStack("at190dV550") .AND. cTipo == MANUT_TIPO_COMPEN
		aAux := TecBRelABB(cAgenda)
		For nX := 1 To LEN(aAux)
			If aAux[nX] != cAgenda
				cAbbAlias := getNextAlias()
				
				BeginSQL Alias cAbbAlias
					SELECT 1 REC 
					FROM %Table:ABR% ABR
					INNER JOIN %Table:ABN% ABN ON
						ABN.ABN_FILIAL = %xFilial:ABN%
						AND ABN.%NotDel%
						AND ABN.ABN_CODIGO = ABR.ABR_MOTIVO
					WHERE ABR.ABR_AGENDA = %Exp:aAux[nX]%
						AND ABR.%NotDel%
						AND ABR.ABR_FILIAL = %xFilial:ABR%
						AND ABN.ABN_TIPO = %Exp:cTipo%
				EndSQL
				If !(cAbbAlias)->(EOF())
					lRet := .F.
				EndIf
				(cAbbAlias)->(DbCloseArea())
				If !lRet
					Help( " ", 1, "AT550VldModel", , STR0089, 1, 0 ) //"Não é possível apagar apenas uma manutenção de Compensação. Utilize a opção Apagar Todas."
					Exit
				EndIf
			EndIf
		Next nX
	EndIf
EndIf


RestArea( aAreaABR )
RestArea( aArea )
RestArea( aAreaABB )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AT550Tipo
Retorna o tipo de manutenção do motivo selecionado.

@sample 	AT550Tipo()
@return	cTipo		Tipo de manutenção do motivo selecionado.

@author	Danilo Dias
@since		14/02/2013
@version	P11.8
/*/
//-------------------------------------------------------------------
Function AT550Tipo()

Local aArea 	:= GetArea()
Local oModel	:= FwModelActive()
Local cTipo	:= ''

DbSelectArea('ABN')
ABN->(DbSetOrder(1))

If ( oModel:GetId() == "TECA550" .And. ABN->( DbSeek( xFilial('ABN') + oModel:GetValue( 'ABRMASTER', 'ABR_MOTIVO' ) ) ) )
	cTipo := ABN->ABN_TIPO
EndIf

RestArea( aArea )

Return cTipo


//-------------------------------------------------------------------
/*/{Protheus.doc} AT550QryMan
Monta array com motivos de manutenções realizadas na agenda informada.

@sample 	AT550QryMan( cAgenda )

@param		cAgenda	Código da agenda para consultar manutenções.
@return	aDados		Array com motivos das manutenções realizadas
@return						na agenda.

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function AT550QryMan( cAgenda )

Local aDados	:= {}
Local cAlias	:= GetNextAlias()

Default cAgenda := ''

BeginSQL Alias cAlias
	SELECT ABR.ABR_MOTIVO, ABN.ABN_TIPO, ABR.ABR_DTINI, ABR.ABR_HRINI, ABR.ABR_DTFIM, ABR.ABR_HRFIM
	  FROM %Table:ABR% ABR
	       JOIN %Table:ABN% ABN ON ABN.ABN_FILIAL = %xFilial:ABN%
	                           AND ABN.%NotDel%
	                           AND ABN.ABN_CODIGO = ABR.ABR_MOTIVO
	 WHERE ABR.ABR_FILIAL = %xFilial:ABR%
	   AND ABR.%NotDel%
	   AND ABR.ABR_AGENDA = %Exp:cAgenda%
EndSQL

While (cAlias)->(!Eof())

	AAdd( aDados, { 	(cAlias)->ABR_MOTIVO,;
						(cAlias)->ABN_TIPO,;
						(cAlias)->ABR_DTINI,;
						(cAlias)->ABR_HRINI,;
						(cAlias)->ABR_DTFIM,;
						(cAlias)->ABR_HRFIM } )

	(cAlias)->(DbSkip())

EndDo

(cAlias)->(DbCloseArea())

Return aDados


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT550GrvABB
Grava a agenda para o atendente informado.

@sample 	AT550GrvABB( cCodTec, cChave, cNumOS, cIdcFal, dDtIni, cHrIni, dDtFim, cHrFim )

@param		cCodTec	Código do técnico.
@param		cChave		Chave da agenda.
@param		cNumOS		Número da OS.
@param		cIdcFal		Chave da configuração da OS.
@param		dDtIni		Data de início da agenda.
@param		cHrIni		Hora de início da agenda.
@param		dDtFim		Data de fim da agenda.
@param		cHrFim		Hora de fim da agenda.
@param		lInclui		Indica se é uma inclusão ou alteração.
@param		cLocal		Local de atendimento da agenda
@param 		cTipo 		Tipo da Agenda
@param		cAgendAnt	Código da agenda que recebeu a manutenção
@param		cTipDia		Tipo do dia da agenda, dia de trabalho (S) ou dia não trabalhado (N)

@author	Danilo Dias
@since		16/02/2013
@version	P11.8
/*/
//-------------------------------------------------------------------------------------------
Function AT550GrvABB( cCodTec, cChave, cNumOS, cIdcFal, dDtIni,;
                      cHrIni, dDtFim, cHrFim, lInclui, cLocal,;
                      cTipo, cAgendAnt, cTipDia, lCustoTWZ )

Local aArea		:= GetArea()
Local aAreaABB	:= ABB->(GetArea())
Local aTN5		:= {}
Local aTN6		:= {}
Local cHrTot	:= ATTotHora(	dDtIni, cHrIni, dDtFim, cHrFim )	//Tempo total da agenda
Local cFilSRA	:= ""
Local cCodABB	:= ""
Local lPEAt550Gr := ExistBlock("At550GrF")
Local lMdtGS 	:= SuperGetMv("MV_NG2GS",.F.,.F.) .And. TableInDic("TN5") .And. TableInDic("TN6")//Parâmetro de integração entre o SIGAMDT x SIGATEC 
Local lAlocMtFil := .F.
Local cQueryTN5	:= ""
Local cCDFUNC 	:= ""
Local cObserv	:= Left(STR0085 + Posicione("ABB", 8,xFilial("ABB") + cAgendAnt, "ABB_CODTEC") + " - " + Posicione("AA1", 1,xFilial("AA1") + Posicione("ABB", 8,xFilial("ABB") + cAgendAnt, "ABB_CODTEC"), "AA1_NOMTEC"), TamSx3("ABB_OBSERV")[1])  //"SUBSTUIÇÃO DO ATENDENTE: "
Local lGsMDTFil := ExistBlock("GsMDTFil")

Default lInclui := .T.
Default cLocal := ""
Default cTipo  := ""
Default cTipDia := ""
Default lCustoTWZ	:= ExistBlock("TecXNcusto")

If !lInclui
	RestArea(aAreaABB)
EndIf
AA1->( DbSetOrder( 1 ) ) // AA1_FILIAL + AA1_CODTEC
AA1->( MsSeek( xFilial("AA1") + cCodTec ) )

cCDFUNC := AA1->AA1_CDFUNC
//Busca o custo do atendente pelo PE ou pelo campo do atendente
If lCustoTWZ
	// posicina ABQ
	DbSelectArea("ABQ")
	ABQ->( DbSetOrder( 1 ) ) // ABQ_FILIAL + ABQ_CONTRT + ABQ_ITEM + ABQ_ORIGEM
	ABQ->( DbSeek( cConfig ) )

	// posicina TFF
	DbSelectArea("TFF")
	TFF->( DbSetOrder( 1 ) ) // TFF_FILIAL + TFF_COD
	TFF->( DbSeek( ABQ->( ABQ_FILTFF + ABQ_CODTFF ) ) )
	nCusto := ExecBlock("TecXNcusto",.F.,.F.,;
						{ 3, A, AA1->AA1_FUNFIL, AA1->AA1_CDFUNC,;
							TFF->TFF_CONTRT, TFF->TFF_LOCAL, TFF->TFF_CODPAI, TFF->TFF_COD, cConfig } )
Else
	nCusto := AA1->AA1_CUSTO
EndIf

If ABN->ABN_TIPO == "07" .AND. ABR->ABR_HRINI != ABB->ABB_HRINI .AND. ABR->ABR_HRFIM != ABB->ABB_HRFIM
	cHrIni := TecConvHr( SomaHoras( cHrIni, "00:01" ) )
EndIf

If lInclui
	cCodABB := AtABBNumCd()//GetSXENum( 'ABB', 'ABB_CODIGO' )
EndIf

RecLock('ABB',lInclui)

	If ( lInclui )
		ABB->ABB_FILIAL	:= xFilial( 'ABB' )
		ABB->ABB_CODIGO	:= cCodABB
	EndIf
	ABB->ABB_CODTEC	:= cCodTec
	If !Empty(cNumOS)
		ABB->ABB_ENTIDA	:= 'AB7'
		ABB->ABB_NUMOS	:= cNumOS
	EndIf
	ABB->ABB_CHAVE	:= cChave
	ABB->ABB_DTINI	:= dDtIni
	ABB->ABB_HRINI	:= cHrIni
	ABB->ABB_DTFIM	:= dDtFim
	ABB->ABB_HRFIM	:= cHrFim
	ABB->ABB_HRTOT	:= cHrTot
	ABB->ABB_SACRA 	:= 'S'
	ABB->ABB_CHEGOU	:= 'N'
	ABB->ABB_ATENDE	:= '2'
	ABB->ABB_MANUT	:= '2'
	ABB->ABB_ATIVO	:= '1'
	ABB->ABB_IDCFAL	:= cIdcFal
	ABB->ABB_LOCAL	:= cLocal

	If !Empty(cTipo)
		ABB->ABB_TIPOMV := cTipo
	EndIf

	//Grava o custo da alocação
	Replace ABB->ABB_CUSTO With (SubtHoras(ABB->ABB_DTINI,ABB->ABB_HRINI,ABB->ABB_DTFIM,ABB->ABB_HRFIM,.T.)*nCusto)

	If ( lInclui )
		Replace ABB->ABB_OBSERV With cObserv
	EndIf

ABB->(MsUnLock())

If At550VldTDV(cAgendAnt)
	At550UpdTdv(.F.,cAgendAnt, ABB->ABB_CODIGO, cTipDia, lInclui )
EndIf

If ( lInclui )
	ConfirmSX8()

	If lMdtGS //Integração entre o SIGAMDT x SIGATEC
		// posicina TFF
		DbSelectArea("TFF")
		TFF->( DbSetOrder(1)) //TFF_FILIAL+TFF_COD
	
		//posicina TN5
		dbSelectArea("TN5")
		TN5->(dbSetOrder(1)) //TN5_FILIAL+TN5_CODTAR
		
		If TFF->( ColumnPos("TFF_RISCO")) > 0 .And. TN5->(ColumnPos("TN5_LOCAL")) > 0 .And. TN5->(ColumnPos("TN5_POSTO")) > 0
	
			//posicina ABQ
			DbSelectArea("ABQ")
			ABQ->( DbSetOrder(1)) //ABQ_FILIAL+ABQ_CONTRT+ABQ_ITEM+ABQ_ORIGEM
		
			//posicina TN6
			dbSelectArea("TN6")
			TN6->(dbSetOrder(1)) //TN6_FILIAL+TN6_CODTAR+TN6_MAT+DTOS(TN6_DTINIC)
			
			If ABQ->(DbSeek(xFilial("ABQ")+ABB->ABB_IDCFAL)) .And.; //Integração entre o SIGAMDT x SIGATEC
			   TFF->(DbSeek(ABQ->(ABQ_FILTFF+ABQ_CODTFF))) .And.;
			   TFF->TFF_RISCO == "1" .And. !Empty(cCDFUNC)
			   
			   cQueryTN5	:= GetNextAlias()
		
				BeginSql Alias cQueryTN5
				
					SELECT TN5.R_E_C_N_O_ TN5RECNO
					FROM %Table:TN5% TN5
					WHERE TN5.TN5_FILIAL	= %exp:xFilial('TN5')%
						AND TN5.TN5_LOCAL	= %exp:TFF->TFF_LOCAL%
						AND TN5.TN5_POSTO	= %exp:TFF->TFF_FUNCAO% 
						AND TN5.%NotDel%
				EndSql

				cFilSRA := AA1->AA1_FUNFIL
				If cFilSRA != cFilAnt
					lAlocMtFil := .T.
				EndIf

				If (cQueryTN5)->(!EOF())
					TN5->(DbGoTo((cQueryTN5)->TN5RECNO))
					If lAlocMtFil .And. lGsMDTFil
						aAdd(aTN5,{"TN5_FILIAL",cFilSRA})
						aAdd(aTN5,{"TN5_NOMTAR",TFF->TFF_LOCAL + " - " + TFF->TFF_FUNCAO})
						aAdd(aTN5,{"TN5_LOCAL",TFF->TFF_LOCAL})
						aAdd(aTN5,{"TN5_POSTO",TFF->TFF_FUNCAO})	

						aAdd(aTN6,{"TN6_FILIAL",cFilSRA})
						aAdd(aTN6,{"TN6_MAT",cCDFUNC})
						aAdd(aTN6,{"TN6_DTINIC",ABB->ABB_DTINI})
						aAdd(aTN6,{"TN6_DTTERM",ABB->ABB_DTFIM})

						ExecBlock("GsMDTFil",.F.,.F.,{aTN5, aTN6} )
					ElseIf !lAlocMtFil
						If !TN6->(dbSeek(xFilial("TN6")+TN5->TN5_CODTAR+cCDFUNC+Dtos(ABB->ABB_DTINI)))
							RecLock("TN6",.T.)
								TN6->TN6_FILIAL	:= xFilial("TN6")
								TN6->TN6_CODTAR	:= TN5->TN5_CODTAR
								TN6->TN6_MAT	:= cCDFUNC
								TN6->TN6_DTINIC	:= ABB->ABB_DTINI
								TN6->TN6_DTTERM	:= ABB->ABB_DTFIM
							TN6->(MsUnLock())
						Endif
					EndIf
				Endif
				(cQueryTN5)->(DbCloseArea())
			Endif
		Endif
	Endif
EndIf

If lPEAt550Gr
	ExecBlock("At550GrF", .F., .F., {cCodTec, lInclui,ABB->ABB_CODIGO, cAgendAnt})
EndIf

RestArea( aAreaABB )
RestArea( aArea )

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT550SelCt
Tela para seleção da configuração do contrato para atendimento da OS.

@sample 	AT550SelCt( cItemOS )

@param		cItemOS	Item da OS para busca do contrato.

@author	Danilo Dias
@since		20/02/2013
@version	P11.8
/*/
//-------------------------------------------------------------------------------------------
Function AT550SelCt( cItemOS, cMotManut )

Local aArea		:= GetArea()
Local aAreaAB6	:= AB6->(GetArea())
Local aAreaABQ	:= ABQ->(GetArea())
Local aAreaABN 	:= ABN->(GetArea())
Local oDlg			:= Nil
Local oBrowse		:= Nil
Local lRet			:= .T.
Local aHeader		:= {}		//Cabeçalho com a descrição dos campos da grid
Local aItens		:= {}		//Conteúdo dos campos da grid
Local cContrato	:= ''		//Contrato da OS
Local lTecXRh		:= SuperGetMV( 'MV_TECXRH',, .F. )	//Indica se há integração com o RH
Local nPosCont	:= 0

Default cItemOS := ''

DbSelectArea('AB6')	//Ordens de Serviço
AB6->(DbSetOrder(1))	//AB6_FILIAL+AB6_NUMOS

DbSelectArea('AB7')	//Ordens de Serviço Item
AB7->(DbSetOrder(1))	//AB7_FILIAL+AB7_NUMOS+AB7_ITEM

DbSelectArea('ABQ')	//Configuração de Alocação de Recursos
ABQ->(DbSetOrder(1))	//ABQ_FILIAL+ABQ_CONTRT+ABQ_ITEM

DbSelectArea('ABN')	// Motivos de Manutenção
ABN->(DbSetOrder(1))	//ABN_FILIAL+ABN_CODIGO

// ---------------------------------------------
// Verifica se a manutenção é uma transferência
// e se está ocorrendo para a mesma OS
If !( cItemOs == ABB->ABB_CHAVE .And. ABN->( DbSeek( xFilial('ABN')+cMotManut ) ) .And. ABN->ABN_TIPO=='06' )
	If ( AB7->( DbSeek( xFilial("AB7")+cItemOS ) ) )
		If AB6->(DbSeek(AB7->AB7_FILIAL+AB7->AB7_NUMOS))
			If ( ABQ->( DbSeek( xFilial('ABQ') + AB6->AB6_CONTRT ) ) )
				cContrato := ABQ->ABQ_CONTRT
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf
Else
	lRet := .F.
	Help(,,'AT550ITOS',, STR0047,1,0) // "A transferência não pode ocorrer para a mesma Ordem de Serviço e Item"
EndIf

If ( lRet )

	AT550GtABQ( cContrato, @aHeader, @aItens )

	DEFINE DIALOG oDlg TITLE STR0023 FROM 180,180 TO 400,800 PIXEL	//"Configuração do Contrato"

	oBrowse := TWBrowse():New( 0, 0, 313, 111,, aHeader,, oDlg,,,,,{||},,,,,,,.F.,,.F.,,.F.,,, )
	oBrowse:SetArray( aItens )

	If ( lTecXRh )
		oBrowse:bLine := { || { 	aItens[oBrowse:nAt, 01], aItens[oBrowse:nAt, 02], aItens[oBrowse:nAt, 03],;
									aItens[oBrowse:nAt, 04], aItens[oBrowse:nAt, 05], aItens[oBrowse:nAt, 06],;
									aItens[oBrowse:nAt, 07], aItens[oBrowse:nAt, 08], aItens[oBrowse:nAt, 09],;
									aItens[oBrowse:nAt, 10], aItens[oBrowse:nAt, 11], aItens[oBrowse:nAt, 12],;
									aItens[oBrowse:nAt, 13], aItens[oBrowse:nAt, 14] } }
	nPosCont := 15
	Else
		oBrowse:bLine := { || { 	aItens[oBrowse:nAt, 01], aItens[oBrowse:nAt, 02], aItens[oBrowse:nAt, 03],;
									aItens[oBrowse:nAt, 04], aItens[oBrowse:nAt, 05], aItens[oBrowse:nAt, 06],;
									aItens[oBrowse:nAt, 07], aItens[oBrowse:nAt, 08], aItens[oBrowse:nAt, 09],;
									aItens[oBrowse:nAt, 10], aItens[oBrowse:nAt, 11], aItens[oBrowse:nAt, 12] } }
	nPosCont := 13
	EndIf

	oBrowse:bLDblClick := { || cConfCtr := aItens[oBrowse:nAt,nPosCont], oDlg:End() }
	oBrowse:Align	:= CONTROL_ALIGN_ALLCLIENT
	oBrowse:DrawSelect()
	oBrowse:Refresh()

	ACTIVATE DIALOG oDlg CENTERED

EndIf

RestArea( aAreaABN )
RestArea( aAreaAB6 )
RestArea( aAreaABQ )
RestArea( aArea )

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT550GtABQ
Monta dados da tabela ABQ para exibir na tela de seleção da configuração do contrato.

@sample 	AT550GtABQ( cContrato, aHeader, aItens )

@param		cContrato	Número do contrato para buscar configurações.
			aHeader	Array com dados do cabeçalho. (Referência)
			aItens		Array com dados dos registros da tabela. (Referência)

@author	Danilo Dias
@since		20/02/2013
@version	P11.8
/*/
//-------------------------------------------------------------------------------------------
Static Function AT550GtABQ( cContrato, aHeader, aItens )

Local aArea    	:= GetArea()
Local aAreaABQ 	:= ABQ->(GetArea())
Local lTecXRh		:= SuperGetMV( 'MV_TECXRH',, .F. )	//Indica se há integração com o RH
Local nI			:= 0
Local nJ			:= 0

//Monta o cabeçalho com os campos da tabela ABQ
AAdd( aHeader, TxSX3Campo('ABQ_PRODUT')[1] )		// "Produto"
AAdd( aHeader, TxSX3Campo('B1_DESC')[1] )			// "Descrição"
AAdd( aHeader, TxSX3Campo('ABQ_TPPROD')[1] )		// "Tipo de Produto"
If lTecXRh
	AAdd( aHeader, TxSX3Campo('ABQ_CARGO')[1] )	// "Cargo"
	AAdd( aHeader, TxSX3Campo('Q3_DESCSUM')[1] )	// "Descrição"
EndIf
AAdd( aHeader, TxSX3Campo('ABQ_FUNCAO')[1] )		// "Função"
AAdd( aHeader, TxSX3Campo('RJ_DESC')[1] )     	// "Descrição"
AAdd( aHeader, TxSX3Campo('ABQ_PERINI')[1] )   	// "Periodo Inicial"
AAdd( aHeader, TxSX3Campo('ABQ_PERFIM')[1] )    	// "Periodo Final"
AAdd( aHeader, TxSX3Campo('ABQ_TURNO')[1] )		// "Turno"
AAdd( aHeader, TxSX3Campo('R6_DESC')[1] )      	// "Descrição"
AAdd( aHeader, STR0018 )   							// "Horas Contratadas"
AAdd( aHeader, STR0019 )      						// "Horas Alocadas"
AAdd( aHeader, STR0020 )								// "Saldo de Horas"

DbSelectArea("ABQ")
ABQ->(DbSetOrder(1))

aItens := {}
nI		:= 1

//Monta os itens com os dados da ABQ
If ABQ->( DbSeek( xFilial("ABQ") + cContrato ) )

	While ( ABQ->(!Eof()) .AND. ABQ->ABQ_FILIAL + ABQ_CONTRT == xFilial("ABQ") + cContrato )

		AAdd( aItens, {} )

		Aadd( aItens[nI], Alltrim( ABQ->ABQ_PRODUT ) )
		Aadd( aItens[nI], Alltrim( Posicione( "SB1", 1, xFilial("SB1") + ABQ->ABQ_PRODUT, "B1_DESC" ) ) )
		Aadd( aItens[nI], X3Combo( "ABQ_TPPROD", ABQ->ABQ_TPPROD ) )
		If ( lTecXRh )
			Aadd( aItens[nI], Alltrim(ABQ->ABQ_CARGO))
			Aadd( aItens[nI], Alltrim(FDESC("SQ3",ABQ->ABQ_CARGO,"Q3_DESCSUM",,ABQ->ABQ_FILIAL)))
		EndIf
		Aadd( aItens[nI], Alltrim(ABQ->ABQ_FUNCAO))
		Aadd( aItens[nI], Alltrim(FDESC("SRJ",ABQ->ABQ_FUNCAO,"RJ_DESC",,ABQ->ABQ_FILIAL)))
		Aadd( aItens[nI], ABQ->ABQ_PERINI)
		Aadd( aItens[nI], ABQ->ABQ_PERFIM)
		Aadd( aItens[nI], ABQ->ABQ_TURNO)
		Aadd( aItens[nI], Alltrim(FDESC("SR6",ABQ->ABQ_TURNO,"R6_DESC")))
		Aadd( aItens[nI], Transform(ABQ->ABQ_TOTAL,PesqPict("ABQ","ABQ_TOTAL")))
		Aadd( aItens[nI], Transform((ABQ->ABQ_TOTAL-ABQ->ABQ_SALDO),PesqPict("ABQ","ABQ_TOTAL")))
		Aadd( aItens[nI], Transform(ABQ->ABQ_SALDO,PesqPict("ABQ","ABQ_SALDO")))
		Aadd( aItens[nI], Alltrim( ABQ->ABQ_CONTRT + ABQ->ABQ_ITEM ) )

		nI++
		ABQ->(DbSkip())
	EndDo
EndIf

If ( Len(aItens) == 0 )
	If ( lTecXRh )
		nJ := 15
	Else
		nJ := 13
	EndIf
	AAdd( aItens, {} )

	For nI := 1 To nJ
		AAdd( aItens[1], '' )
	Next nI
EndIf

RestArea( aAreaABQ )
RestArea( aArea )

Return Nil


//------------------------------------------------------------------------------------------
/* /{Protheus.doc} IsLastManut
	Valida se o código de manutenção informado é da última manutenção realizada na agenda

@sample 	IsLastManut( cCodAgenda, cCodManut )

@param 	cCodAgenda	Código da Agenda para referência à agenda
@param 	cCodManut	Código Sequencial de Manutenção na tabela ABR

@author 	Josimar Junior
@since 	07/05/2013
@version 	P11.8
/*/
//-------------------------------------------------------------------------------------------
Static Function IsLastManut( cCodAgenda, cCodManut )

Local lRet 	:= .T.
Local cAreaTmp 	:= GetNextAlias()
Local aSave 	:= GetArea()
Local aSaveABB 	:= ABB->( GetArea() )
Local aSaveABR 	:= ABR->( GetArea() )

BeginSql Alias cAreaTmp

	SELECT ABR.ABR_AGENDA, ABR.ABR_MANUT
	  FROM %table:ABR% ABR
	 WHERE ABR.%NotDel%
	   AND ABR.ABR_FILIAL = %xFilial:ABR%
	   AND ABR_AGENDA = %exp:cCodAgenda%

EndSql

While lRet .And. (cAreaTmp)->( !EOF() )
	If cCodManut < (cAreaTmp)->ABR_MANUT
		lRet := .F.
	EndIf

	(cAreaTmp)->( DbSkip() )
End
(cAreaTmp)->(DbCloseArea())
RestArea( aSaveABR )
RestArea( aSaveABB )
RestArea( aSave )

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidDtHr
	Valida Data e Hora conforme o tipo do motivo de manutenção selecionado, chamado na
validação dos campos de Data e Hora Inicial e Final

@sample 	ValidDtHr( oModel, cCampo, xValAnt, xValIns )

@param 	oModel	objeto com o modelo de dados
@param 	cCampo	campo em validação
@param 	xValAnt	valor anterior do campo
@param 	xValIns	valor inserido pelo usuário no campo

@author 	Josimar Junior
@since 	07/05/2013
@version 	P11.8
/*/
//-------------------------------------------------------------------------------------------
Static Function ValidDtHr( oModel, cCampo, xValIns, xValAnt )

Local lRet 		:= .T.
Local cTipo 	:= AT550Tipo()
Local lHora 	:= cCampo $ "ABR_HRINI*ABR_HRFIM"
Local lBloqDt  := .F.
Local nOper := oModel:GetOperation()
Local xDtAuxIni
Local xDtAuxFim
Local lIntraJorn

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	xDtAuxFim := IIF(VALTYPE((cAliasTmp)->ABB_DTFIM ) == 'D',(cAliasTmp)->ABB_DTFIM ,StoD( (cAliasTmp)->ABB_DTFIM ))
	xDtAuxIni := IIF(VALTYPE((cAliasTmp)->ABB_DTINI) == 'D' ,(cAliasTmp)->ABB_DTINI ,SToD( (cAliasTmp)->ABB_DTINI ))
	lIntraJorn := xDtAuxFim > xDtAuxIni
Else
	lIntraJorn := ABR->ABR_DTFIMA > ABR->ABR_DTINIA
EndIf
//------------------------------------------------------------------------------------
//  Sobrescreve o conteúdo do valor anterior para validar conforme o primeiro
// registro selecionado na tabela de agenda temporária 
xValAnt := (cAliasTmp)->&(StrTran(cCampo, "ABR", "ABB") ) 

If ValType(xValIns)=='D' .And. ValType(xValAnt) <> 'D'
	xValAnt := STOD( xValAnt )

	If cTipo == MANUT_TIPO_ATRASO
		lBloqDt := ( xValIns > oModel:GetValue("ABR_DTFIM") )
	ElseIf cTipo == MANUT_TIPO_SAIDAANT
		lBloqDt := ( xValIns < oModel:GetValue("ABR_DTINI") )
	EndIf

EndIf

If cTipo == MANUT_TIPO_ATRASO .And. Alltrim(cCampo) $ "ABR_DTINI*ABR_HRINI"

	If nOper == MODEL_OPERATION_UPDATE .And. isInCallStack("TECA550")
	 	If cCampo == "ABR_DTINI" .AND. lIntraJorn
			Help(,,'ValidDtHrAtr',, STR0064,4,0) //"Operação não permitida. Para alterar a data de início da agenda, por favor exclua essa manutenção e inclua uma nova"
			lRet := .F.
	 	ElseIf "ABR_HRINI" == cCampo
	 		xValAnt := ABR->ABR_HRINIA
		EndIf
	EndIf

	If lRet .AND. !lIntraJorn //Static alimentada no InitDados e zerada no Commit/Cancel
		lRet := ( xValAnt <= xValIns .And. !lBloqDt ) .Or. ( lHora .And. oModel:GetValue("ABR_DTINI") < oModel:GetValue("ABR_DTFIM") )
	EndIf

	//Valida se a hora incluida na saida antecipada é maior que a hora inicial
	If lRet .AND. cCampo == 'ABR_HRINI'
		If lIntraJorn .AND. oModel:GetValue("ABR_DTFIM") > oModel:GetValue("ABR_DTINI")
			lRet := oModel:GetValue("ABR_HRFIM") <= xValIns
		Else
			lRet := oModel:GetValue("ABR_HRFIM") >= xValIns
		EndIf
	EndIf

	If lRet .AND. cCampo == 'ABR_DTINI'
		lRet := oModel:GetValue("ABR_DTFIM") >= xValIns
	EndIf


ElseIf cTipo == MANUT_TIPO_SAIDAANT .And. Alltrim(cCampo) $ "ABR_DTFIM*ABR_HRFIM"

	If nOper == MODEL_OPERATION_UPDATE .And. (isInCallStack("TECA550") .OR. IsInCallStack("at190d550") .OR. IsInCallStack("AT190dIMn2"))
		If cCampo == "ABR_DTFIM" .AND. lIntraJorn
			Help(,,'ValidDtHrSat',,STR0065,4,0) //"Operação não permitida. Para alterar a data de término da agenda, por favor exclua essa manutenção e inclua uma nova"
			lRet := .F.
		ElseIf "ABR_HRFIM" == cCampo
			xValAnt := ABR->ABR_HRFIMA
		EndIf
	EndIf

	If lRet .AND. !lIntraJorn //Static alimentada no InitDados e zerada no Commit/Cancel
		lRet := ( xValAnt >= xValIns .And. !lBloqDt ) .Or. ( lHora .And. oModel:GetValue("ABR_DTINI") < oModel:GetValue("ABR_DTFIM") )
	EndIf

	//Valida se a hora incluida na saida antecipada é maior que a hora inicial
	If lRet .AND. cCampo == 'ABR_HRFIM'
		If lIntraJorn .AND. oModel:GetValue("ABR_DTFIM") > oModel:GetValue("ABR_DTINI")
			lRet := oModel:GetValue("ABR_HRINI") >= xValIns
		Else
			lRet := oModel:GetValue("ABR_HRINI") <= xValIns
		EndIf
	EndIf

	If lRet .AND. cCampo == 'ABR_DTFIM'
		lRet := oModel:GetValue("ABR_DTINI") <= xValIns
	EndIf

ElseIf cTipo == MANUT_TIPO_HORAEXTRA

	If nOper == MODEL_OPERATION_UPDATE .And. isInCallStack("TECA550")
		If	"ABR_HRFIM" == cCampo
			xValAnt := ABR->ABR_HRFIMA
		ElseIf "ABR_HRINI" == cCampo
			xValAnt := ABR->ABR_HRINIA
		EndIf
	EndIf

	If Alltrim(cCampo) $ "ABR_DTINI*ABR_HRINI"
		If EMPTY(ABB->ABB_HRCHIN) .AND. EMPTY(ABB->ABB_HRCOUT)
			lRet := ( xValAnt >= xValIns ) .Or. ( lHora .And. oModel:GetValue("ABR_DTINI") < oModel:GetValue("ABR_DTFIM") )
		EndIf	
	Else
		lRet := ( xValAnt <= xValIns ) .Or. ( lHora .And. oModel:GetValue("ABR_DTINI") < oModel:GetValue("ABR_DTFIM") )
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At550GtAls
Retorna Alias utilizado pelo Model

@sample 	At550GtAls( )

@return	cAliasTmp	Alias Temporario utilizado pelo Model

@author	Rogério Francisco de Souza
@since		23/05/2013
@version	P11.8
/*/
//-------------------------------------------------------------------
Function At550GtAls()

Return cAliasTmp

//-------------------------------------------------------------------
/*/{Protheus.doc} At550StAls
RetSeta Alias a ser utiulizado pelo Model

@sample 	At550StAls(cAlias)

@param		cAlias	Alias a ser utilizado

@author	Rogério Francisco de Souza
@since		23/05/2013
@version	P11.8
/*/
//-------------------------------------------------------------------
Function At550StAls(cAlias)
cAliasTmp := cAlias
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At550VldTDV
	Verifica se há víncula da agenda com a geração de escalas

@sample 	At550VldTDV('0000001')

@param		cAgdAbb, Char, código da agenda na tabela ABB

@since		14/07/2014
@version	P11.9
/*/
//-------------------------------------------------------------------
Function At550VldTDV( cAgdAbb )

Local aSave     := GetArea()
Local aSaveTDV  := TDV->(GetArea())
Local lRet      := .F.
DEFAULT cAgdAbb := ''

DbSelectArea('TDV')
TDV->(DbSetOrder(1))  //TDV_FILIAL+TDV_CODABB

If !Empty(cAgdAbb) .And. TDV->(DbSeek(xFilial('TDV')+cAgdAbb))
	lRet := .T.
EndIf

RestArea(aSaveTDV)
RestArea(aSave)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At550UpdTdv
	Copia as informações da escala de uma agenda para outra agenda

@sample 	At550UpdTdv('0000001')

@param		cAgCopia, Char, código da agenda a ter o conteúdo da escala copiado
@param		cAgNova, Char, código da nova agenda que terá a escala criada

@since		14/07/2014
@version	P11.9
/*/
//-------------------------------------------------------------------
Static Function At550UpdTdv(lDeleta,cAgCopia,cAgNova,cTipGrav,lInclui)

Local aCpos    := TDV->(DbStruct())
Local nMaxCpos := Len(aCpos)
Local aValores := Array(nMaxCpos)
Local nX       := 1
Local aSave    := GetArea()
Local aSaveTDV := TDV->(GetArea())

DEFAULT lDeleta := .F.
DEFAULT lInclui	:= .T.

DbSelectArea('TDV')
TDV->(DbSetOrder(1)) //TDV_FILIAL+TDV_CODABB

If TDV->(DbSeek(xFilial('TDV')+cAgCopia))

	If !lDeleta
		// copia os dados da escala
		For nX := 1 To nMaxCpos
			aValores[nX] := TDV->&(aCpos[nX,1])
		Next nX

		If !lInclui .And. TDV->(DbSeek(xFilial('TDV')+cAgNova))
			// altera os dados da escala copiada
			Reclock('TDV', .F.)
		Else
			// grava os dados da escala copiada
			Reclock('TDV', .T.)
		Endif
		For nX := 1 To nMaxCpos
			TDV->&(aCpos[nX,1]) := aValores[nX]
		Next nX

		TDV->TDV_CODABB := cAgNova // substitui o código da agenda anterior do campo
		If !Empty(cTipGrav)  // grava o tipo informado pelo usuário
			TDV->TDV_TPDIA  := cTipGrav
		EndIf

		TDV->(MsUnlock())
	Else
		Reclock('TDV',.F.)
			TDV->(DbDelete())
		TDV->(MsUnlock())
	EndIf

EndIf
RestArea(aSaveTDV)
RestArea(aSave)

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} At550FilCt
Filtra as informações.

@sample 	At550FilCt(_aAtend)

@param		_aAtend	Vetor: cCodSub,cConfig,dDtIniSub,cHrIniSub,dDtFimSub,cHrFimSub,cLocal,cTipoAloc,cAgenda

@author	Elcio
@since		10/02/2015
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Static Function At550FilCt(_aAtend)

Local aAreaABB  := GetArea()
Local cAliasABB := ''
Local _cConfig  := ''
Local cNumContr := ''
Local cRevContr := ''
Local nX        := 0

If IsInCallStack('AT570Subst') .OR. isInCallStack("at190dimn2")
	If ValType(lGeraMemo)=="U"
		lGeraMemo := !(isBlind()) .AND. ( PerguntMemo(lPergMemo) .AND. MSGYESNO( STR0050, STR0051 ) ) //"Deseja realmente gerar o memorando?" # "Memorando"
	EndIf
Else
	lGeraMemo := !(isBlind()) .AND. ( PerguntMemo(lPergMemo) .AND. MSGYESNO( STR0050, STR0051 ) ) //"Deseja realmente gerar o memorando?" # "Memorando"
EndIf

IF lGeraMemo

	FOR nX := 1 TO Len(_aAtend)

		cAliasABB := GetNextAlias()

		_cConfig  := _aAtend[nX][2]
		cNumContr := Substr(_aAtend[nX][2],1,TAMSX3("TFF_CONTRT")[1])

		BeginSql Alias cAliasABB

			SELECT DISTINCT TFF_CONTRT, TFF_CONREV
			  FROM %table:ABB% ABB
			       JOIN %table:ABQ% ABQ ON ABQ_FILIAL = %xFilial:ABQ%
			                           AND ABQ.%notDel%
			                           AND ABQ_CONTRT || ABQ_ITEM || ABQ_ORIGEM = ABB_IDCFAL
			       JOIN %table:TFF% TFF ON TFF_FILIAL = %xFilial:TFF%
			                           AND TFF_COD = ABQ_CODTFF
			                           AND TFF.%notDel%
			 WHERE ABB_FILIAL = %xFilial:ABB%
			   AND ABB_IDCFAL = %Exp:_cConfig%
			   AND ABB.%notDel%

		EndSql

		DbSelectArea(cAliasABB)

		DO WHILE (cAliasABB)->(!Eof())
			cRevContr := (cAliasABB)->TFF_CONREV
			(cAliasABB)->(DbSkip())
		END

		DbSelectArea(cAliasABB)
		(cAliasABB)->(DbCloseArea())

		// Chama rotina de geracao do memorando
		At330GerMem(cNumContr, cRevContr, _aAtend[nX] )

	NEXT nX
ENDIF

RestArea(aAreaABB)

Return

/*
{Protheus.doc} At550Reset

@simple At550Reset()
@since  20/08/2015
@return Null
*/
Function At550Reset()

cTipAlcSta	:= ""
lGeraMemo	:= Nil
Return

/*/{Protheus.doc} At550VlMt
@description 		validação do motivo sendo escolhido para a manutenção da agenda
@author				josimar.assuncao
@since				06.03.2017
@version			P12
/*/
Function At550VlMt()
Local lRet := .T.
Local cTipo := AT550Tipo()

If cTipo == '06' .And. ; // tipo igual a transferência
	 Right( (cAliasTmp)->ABB_IDCFAL, 3) == "CN9"  // origem do contrato como CN9

	 lRet := .F.
	 Help(,,'AT550NOTRCN9',, STR0054,1,0) // "Não pode ser realizada transferência em contratos integrados com o GCT."
EndIf

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AUpdABBAus
Atualiza a ABB criada pela ausência

@author	Matheus Lando Raimundo
@since		07/03/2018
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Function AUpdABBAus(cConfig,cCodTec,dDtIni,dDtFim,cHrFim)
Local cAliasTemp := GetNextAlias()
Local lRet := .F.

BeginSQL Alias cAliasTemp
	SELECT R_E_C_N_O_ IDRECNO FROM %Table:ABB% ABB
		WHERE ABB_FILIAL = %xFilial:ABB%
		AND ABB_IDCFAL = %Exp:cConfig%
		AND ABB_CODTEC = %Exp:cCodTec%
		AND ABB_DTINI  = %Exp:dDtIni%
		AND ABB_DTFIM  = %Exp:dDtFim%
		AND ABB_HRFIM  = %Exp:cHrFim%
		AND ABB.%NotDel%
EndSQL

If (cAliasTemp)->(!Eof())
	lRet := .T.
	ABB->(dbGoto((cAliasTemp)->IDRECNO))
	RecLock('ABB',.F.)
	ABB->ABB_MANUT = '2'
	ABB->(MsUnlock())
EndIf
(cAliasTemp)->(dbCloseArea())

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AUpdABBAus
Valid para o campo ABR_CODSUB

@author	Diego de Andrade Bezerra
@since		22/05/2018
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Function At550VaSub()


Local oMdlVld := FwModelActive()
Local cDateIn	:=	oMdlVld:GetModel("ABRMASTER"):GetValue('ABR_DTINI')
Local cDateFim	:= oMdlVld:GetModel("ABRMASTER"):GetValue('ABR_DTFIM')
Local cCodSub	:= oMdlVld:GetModel("ABRMASTER"):GetValue('ABR_CODSUB')
Local cHrIni	:= oMdlVld:GetModel("ABRMASTER"):GetValue('ABR_HRINI')
Local cHrFim	:= oMdlVld:GetModel("ABRMASTER"):GetValue('ABR_HRFIM')
Local cAgenda   := ""

Local aRet	:= {}
Local lRet	:= .T.
Local lTxVald	:= isInCallStack("AT190dIMn2") .OR. isInCallStack("SubstLote") .OR. isInCallStack("at190dV550")
Local cRet	:= 0
Local nI	:= 0
Local lAchou	:= .F.
Local cCodTFF	:= TFF->TFF_COD
Local cLocalAloc := POSICIONE("TFL", 1,xFilial("TFF") + TFF->TFF_CODPAI, "TFL_LOCAL")
Local dDtRef     := SToD("")
Local cIdcFal    := ""
Local cFilABB	 := ""

If (cAliasTmp) <> Nil  .AND.  SELECT(cAliasTmp) > 0 
	cAgenda := (cAliasTmp)->ABB_CODIGO
	cIdcFal := (cAliasTmp)->ABB_IDCFAL
	If lTxVald
		cFilABB := (cAliasTmp)->ABB_FILIAL
	EndIf
EndIf	

If !Empty(cAgenda)
	DbSelectArea("TDV")
	TDV->(DbSetOrder(1))
	If TDV->(dbseek(xFilial("TDV")+cAgenda))
		dDtRef := TDV->TDV_DTREF
	EndIf	
EndIf

//Se o codigo do substituto estiver preenchido
If !(Empty(cCodSub)) .And. At680Perm( Nil , __cUserID, "036") //Verificar se o usuário logado tem permissão para inserir substituto manualmente

	//Quando for o TECA190D
	If lTxVald
		
		//Verificar se o substituto pode fazer cobertura.
		lRet := TxVldAtend(cCodSub,cDateIn,cDateFim,cLocalAloc,.T.,cHrIni,cHrFim, cIdcFal, cFilABB, dDtRef)

		If isInCallStack("at190dV550")
			TecxVldMsg(.F.,.T.)
		Endif
	Endif

	If lRet .AND. !lTxVald

		// Carrega array com o código do atendente e código da função, caso seja funcionário, se o mesmo estiver disponível para o período escolhido
		aRet	:= ListarApoio( cDateIn, cDateFim	, /*aCargos*/	, /*aFuncoes*/	, /*aHabil*/	, /*cDisponib*/	,;
										/*cContIni*/, /*cContFim*/	, /*xCCusto*/	, /*cLista*/	, /*nLegenda*/	, /*cItemOS*/,;
										/*aTurnos*/	, /*aRegiao*/	, /*lEstrut*/	, /*aPeriodos*/	, cIdcFal	, /*cLocOrc*/,;
										/*aSeqTrn*/	, /*aPeriodRes*/, cLocalAloc	, /*aCarac*/	, /*aCursos*/, cCodSub, dDtRef  )
		
		lRet := ASCAN(aRet ,{|x| x[1] == cCodSub}) > 0
		
		// Se o atendente não for encontrado, ele não está disponível para a substituição no período selecionado
		If !lRet
			Help(,,"At550VaSub",,STR0090,1,0) // "Atendente não disponível para substituição"     
		EndIf
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} At550SetAlias
Função utilizada para manipular a var Static cAliasTmp

@author		boiani
@since		12/06/2019
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Function At550SetAlias(cVal)
If VALTYPE(cVal) == "C"
	cAliasTmp := cVal
	If EMPTY(cVal)
		aCompen := {}
	EndIf
EndIf
Return cAliasTmp

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} At550SetGrvU
Função utilizada para manipular a var Static lGravaUnic

@author		boiani
@since		12/06/2019
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Function At550SetGrvU(lVal)

If VALTYPE(lVal) == "L"
	lGravaUnic := lVal
EndIf

Return lGravaUnic


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} At550VerChe
Função utilizada para verificar se as informações da ABB foram levadas para o ponto ao utilizar a confirmação de chegada

@author		Junior Santos
@since		21/10/2020
@version	P12
/*/
//-------------------------------------------------------------------------------------------

Function At550VerChe(cAgenda)
Local cAliasABB := GetNextAlias()
Local lRet := .F.
Local lGsGerOs := SuperGetMV("MV_GSGEROS",.F.,"1") == "1" 
Local lMponto   := ( ABB->(ColumnPos('ABB_MPONTO')) > 0 )
Local cQuery := ""

If !lGsGerOs .AND. lMponto

	cQuery += "SELECT ABB.ABB_MPONTO 
	cQuery += "FROM "  + RetSqlName( "ABB" ) + " ABB "
	cQuery += "WHERE "
	cQuery += "ABB.ABB_CODIGO ='" + cAgenda + "' 
	cQuery += " AND ABB.ABB_FILIAL = '" + xFilial( "ABB" ) + "' 
	cQuery += " AND ABB.D_E_L_E_T_  = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasABB , .T., .T.)

	If (cAliasABB)->(!Eof())
		If (cAliasABB)->ABB_MPONTO == "T"
			lRet := .T.
		EndIf
	EndIf

	(cAliasABB)->(DbCloseArea())
Else
	lRet := .T.
Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} At550ChkTp
Função utilizada para verificar o tipo de manutenção e verificar a quantidade, necessario
para não deixar colocar mais de 2 horas extras para uma unica agenda.

@author		Luiz Gabriel
@since		21/10/2020
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Static Function At550ChkTp(aManut,cTipo,cMotivo)
Local lRet 		:= .F.
Local nNumHE	:= 0
Local nX		:= 0
Local nPosHE	:= 0

//Conta se há mais de 1 H.E criada
For nX := 1 To Len(aManut)
	If aManut[nX][2] == cTipo
		nNumHE ++
	EndIf
Next nX

//Se há somente 1 H.E lançada verifica se motivo é diferente
If nNumHe <= 1 
	If nNumHe > 0
		nPosHE := AScan( aManut, { |x| x[2] == cTipo } )
		If nPosHE > 0
			If aManut[nPosHE][1] != cMotivo
				lRet := .T.
			EndIf
		Else
			lRet := .T.
		EndIf 	
	Else
		lRet := .T.
	EndIf		
EndIf

Return lRet

/*/{Protheus.doc} PergMemo550
@description 	Seta a variavel lPergMemo para indicar se vai apresentar o pergunte do Memorando
@author		Luiz Gabriel
@since			25/06/2021
/*/
Function PergMemo550(lSetValue)

If VALTYPE(lSetValue) == 'L'
	lPergMemo := lSetValue
EndIf

Return lPergMemo
