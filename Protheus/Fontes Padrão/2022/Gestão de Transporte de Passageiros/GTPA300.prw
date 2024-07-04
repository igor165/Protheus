#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'GTPA300.ch'

Static cContrato := ''

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA300
Cadastro Viagens Normais e Extraordinárias. 
@sample		GTPA300()
@return		Objeto oBrowse  
@author		Lucas.Brustolin
@since			25/03/2015
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GTPA300(cCont900,cStatus)
Local oBrowse := Nil
cContrato:= cCont900

//-- Instanciamento da Classe de Browse
oBrowse:= FWMBrowse():New()


If !Empty(cContrato) .And. (cStatus == '2') .And. GYN->(FIELDPOS("GYN_EXTCMP")) > 0
	oBrowse:SetFilterDefault('GYN_FILIAL == "'+ XFilial('GY0') +;
							'".AND. GYN_CODGY0 == "' +;
							 cContrato + '".AND. GYN_EXTCMP == .T.')
	oBrowse:SetChgAll(.F.) 
	oBrowse:SetAlias("GYN")
	oBrowse:SetDescription(STR0079) //-- 'Viagens'
	oBrowse:SetMenuDef('GTPA300')
ElseIf !Empty(cContrato) .And. (cStatus <> '2') .And. GYN->(FIELDPOS("GYN_EXTCMP")) > 0
	MsgAlert(STR0080,STR0079)
	Return() 
Else	
	oBrowse:SetAlias("GYN")
	oBrowse:SetDescription(STR0001) //-- 'Viagens'
	oBrowse:SetMenuDef('GTPA300')
EndIf

// Status Viagens
If GYN->(ColumnPos("GYN_STSOCR")) > 0
	oBrowse:AddLegend('EMPTY(GYN->GYN_STSOCR)',"WHITE",  STR0067, 'GYN_STSOCR')//"Sem Ocorrências")
	oBrowse:AddLegend('GYN->GYN_STSOCR=="1"',  "GREEN",  STR0068, 'GYN_STSOCR')//"Ocorrências Finalizada")
	oBrowse:AddLegend('GYN->GYN_STSOCR=="2"',  "RED",    STR0069, 'GYN_STSOCR')//"Ocorrências Em andamento")
	oBrowse:AddLegend('GYN->GYN_STSOCR=="3"',  "YELLOW", STR0070, 'GYN_STSOCR')//"Ocorrências sem operacional")
Endif

// Status Divergências de viagens x horários
oBrowse:AddLegend('GT300DIV()==.F.',"GREEN",  STR0074)// 'Sem Divergências'
oBrowse:AddLegend('GT300DIV()==.T.',  "RED",  STR0075)// 'Com Divergências'

oBrowse:Activate()

Return (oBrowse)

//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Tipo de Recurso
@Return 	aRotina - Vetor com os menus
@author 	Lucas.Brustolin
@since 		25/03/2015
@version	P12
/*/
//----------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

If !Empty(cContrato) .And. GYN->(FIELDPOS("GYN_EXTCMP")) > 0
	ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.GTPA300" 	OPERATION 3	ACCESS 0 	// STR0004//"Incluir"
Else
	ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw" 			OPERATION 1	ACCESS 0 	// STR0002//"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.GTPA300"	OPERATION 2 ACCESS 0 	// STR0003//"Visualizar"
	ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.GTPA300" 	OPERATION 3	ACCESS 0 	// STR0004//"Incluir"
	ADD OPTION aRotina TITLE STR0006	ACTION "GTPA3EXEC(3)"	    OPERATION 5	ACCESS 0 	// STR0006//"Excluir"
	ADD OPTION aRotina TITLE STR0005	ACTION "GTPA3EXEC(1)"		OPERATION 4	ACCESS 0 	// STR0005//"Alterar"
	ADD OPTION aRotina TITLE STR0065	ACTION "GTPA3EXEC(2)"		OPERATION 3	ACCESS 0   // Gera Viagem 
	ADD OPTION aRotina TITLE STR0072	ACTION "G900GerVia(1)"		OPERATION 3	ACCESS 0   // 'Gerar Viagem Contrato'
	ADD OPTION aRotina TITLE STR0073	ACTION "G900GerVia(2)"		OPERATION 3	ACCESS 0   // Visualizar Viagem Contrat
	ADD OPTION aRotina TITLE STR0066	ACTION "GTPA318()"			OPERATION 4	ACCESS 0 	// Ocorrências
	ADD OPTION aRotina TITLE STR0036	ACTION "GTPA3EXEC(4)"		OPERATION 7	ACCESS 0 	// STR0008//"Conflito" 
	ADD OPTION aRotina TITLE "divergências de viagens x horários"	ACTION "GTPC300T()"		    OPERATION 7	ACCESS 0 	// divergências de viagens x horários
EndIf

Return(aRotina)


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados 
@sample	ModelDef() 
@return	oModel - Objeto do Model
@author 	Lucas.Brustolin
@since 		25/03/2015
@version	P12
/*/ 
//--------------------------------------------------------------------------------------------------------

Static Function ModelDef()

// Cria as estruturas a serem usadas no Modelo de Dados
Local oModel 	:= nil 
Local oStruGYN	:= FWFormStruct( 1, 'GYN' )
Local oStruG55	:= FWFormStruct( 1, 'G55' ) 
Local oStruGQE	:= FWFormStruct( 1, 'GQE' )
Local oStruG56	:= FWFormStruct( 1, 'G56' )
Local bLinePre	:= {|oMdlG55,nLine,cAcao,cCampo|GTPA300PreLin(oMdlG55,nLine,cAcao,cCampo)}
Local bLinePost	:= {|oModel|GcVldLine(oModel)}

SetModelStruct(oStruGYN,oStruG55,oStruGQE,oStruG56)

oModel:= MPFormModel():New('GTPA300',/*PreValidMdl*/,{|oModel|TP300TudOK(oModel)},/*bCommit*/)

oModel:AddFields('GYNMASTER', /*cOwner*/, oStruGYN, /*bPreVld*/) 
oModel:AddGrid('G55DETAIL', 'GYNMASTER', oStruG55, bLinePre, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/  ) 
oModel:AddGrid('GQEDETAIL', 'G55DETAIL', oStruGQE, /*bLinePre*/, bLinePost/*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )

oModel:SetRelation( 'G55DETAIL', { { 'G55_FILIAL', 'xFilial( "GYN" )' }, { 'G55_CODVIA', 'GYN_CODIGO' }, { 'G55_CODGID', 'GYN_CODGID' } }, G55->(IndexKey(4))) 
oModel:SetRelation( 'GQEDETAIL', { { 'GQE_FILIAL', 'xFilial( "G55" )' }, { 'GQE_VIACOD', 'GYN_CODIGO' }, { 'GQE_SEQ', 'G55_SEQ' }}, GQE->(IndexKey(3)) )//GQE_FILIAL+GQE_VIACOD+GQE_SEQ+GQE_ITEM 

oModel:GetModel('GQEDETAIL'):SetUniqueLine({'GQE_TCOLAB','GQE_RECURS'})
oModel:GetModel('G55DETAIL'):SetUniqueLine({'G55_LOCORI','G55_LOCDES'})

oModel:SetDescription( STR0001 ) //-- 'Viagens'
oModel:GetModel('G55DETAIL'):SetDescription(STR0037)	// "Trecho Viage"
oModel:GetModel('GQEDETAIL'):SetDescription(STR0038)	// "Recursos por trecho"

If VldStruG56()
	oModel:AddGrid('G56DETAIL', 'GYNMASTER', oStruG56, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ ) 
	oModel:SetRelation( 'G56DETAIL', { { 'G56_FILIAL', 'xFilial( "GYN" )' }, { 'G56_VIAGEM', 'GYN_CODIGO' } }, G56->(IndexKey(3)))
	oModel:GetModel('G56DETAIL'):SetDescription(STR0066)	// "Ocorrências"
	oModel:GetModel('G56DETAIL'):SetOptional(.T.)
	oModel:GetModel('G56DETAIL'):SetUniqueLine({'G56_FILIAL','G56_CODIGO'})
Endif

oModel:GetModel('GQEDETAIL'):SetOptional(.T.)

oModel:SetPrimaryKey({"GYN_FILIAL","GYN_CODIGO"})

Return (oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct

@type function
@author jacomo.fernandes
@since 10/06/2019
@version 1.0
@param oStr, character, (Descrição do parâmetro)
@return nul, nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStruGYN,oStruG55,oStruGQE,oStruG56)
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue)}
Local bWhen		:= {|oMdl,cField,uVal| FieldWhen(oMdl,cField,uVal)}
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit		:= {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}

If ValType(oStruGYN) == "O"
	//Remove os Gatilhos de dicionarios
	oStruGYN:aTriggers:= {}
	oStruGYN:AddTrigger('GYN_LINCOD'	,'GYN_LINCOD'	,{||.T.}, bTrig)
	oStruGYN:AddTrigger('GYN_LINSEN'	,'GYN_LINSEN'	,{||.T.}, bTrig)
	oStruGYN:AddTrigger('GYN_CODGID'	,'GYN_CODGID'	,{||.T.}, bTrig)
	oStruGYN:AddTrigger('GYN_DTINI'		,'GYN_DTINI'	,{||.T.}, bTrig)
	oStruGYN:AddTrigger('GYN_TIPO'		,'GYN_TIPO'		,{||.T.}, bTrig)
	oStruGYN:AddTrigger('GYN_CONF'		,'GYN_CONF'		,{||.T.}, bTrig)
	oStruGYN:AddTrigger('GYN_LOCORI'	,'GYN_LOCORI'	,{||.T.}, bTrig)
	oStruGYN:AddTrigger('GYN_LOCDES'	,'GYN_LOCDES'	,{||.T.}, bTrig)
	oStruGYN:AddTrigger('GYN_SRVEXT'	,'GYN_SRVEXT'	,{||.T.}, bTrig)

	oStruGYN:SetProperty('*'			, MODEL_FIELD_WHEN	, bWhen)
	oStruGYN:SetProperty('GYN_SRVEXT'	, MODEL_FIELD_WHEN	, bWhen)
	oStruGYN:SetProperty('GYN_LINCOD'	, MODEL_FIELD_WHEN	, bWhen)
	oStruGYN:SetProperty('GYN_LINSEN'	, MODEL_FIELD_WHEN	, bWhen)
	oStruGYN:SetProperty('GYN_CODGID'	, MODEL_FIELD_WHEN	, bWhen)
	oStruGYN:SetProperty('GYN_DTINI'	, MODEL_FIELD_WHEN	, bWhen)
	oStruGYN:SetProperty('GYN_DTFIM'	, MODEL_FIELD_WHEN	, bWhen)
	oStruGYN:SetProperty('GYN_LOCORI'	, MODEL_FIELD_WHEN	, bWhen)
	oStruGYN:SetProperty('GYN_LOCDES'	, MODEL_FIELD_WHEN	, bWhen)
	oStruGYN:SetProperty('GYN_HRINI'	, MODEL_FIELD_WHEN	, bWhen)
	oStruGYN:SetProperty('GYN_HRFIM'	, MODEL_FIELD_WHEN	, bWhen)
	oStruGYN:SetProperty('GYN_TIPO'		, MODEL_FIELD_WHEN	, bWhen)
	oStruGYN:SetProperty('GYN_IDENT'	, MODEL_FIELD_WHEN	, bWhen)

	oStruGYN:SetProperty('GYN_DTINI'	, MODEL_FIELD_VALID	, bFldVld)
	oStruGYN:SetProperty('GYN_HRINI'	, MODEL_FIELD_VALID , bFldVld)
	oStruGYN:SetProperty('GYN_DTFIM'	, MODEL_FIELD_VALID , bFldVld)
	oStruGYN:SetProperty('GYN_HRFIM'	, MODEL_FIELD_VALID , bFldVld)
	oStruGYN:SetProperty('GYN_CODGID'	, MODEL_FIELD_VALID , bFldVld)

	oStruGYN:SetProperty('GYN_LOCORI'	,MODEL_FIELD_OBRIGAT, .T. )
	oStruGYN:SetProperty('GYN_LOCDES'	,MODEL_FIELD_OBRIGAT, .T. )

	oStruGYN:SetProperty('GYN_CONF'		, MODEL_FIELD_INIT	, bInit )
Endif

If ValType(oStruG55) == "O"
	oStruG55:AddTrigger('G55_HRINI'		,'G55_HRINI'	,{||.T.}, bTrig)
	oStruG55:AddTrigger('G55_HRFIM'		,'G55_HRFIM'	,{||.T.}, bTrig)
	oStruG55:AddTrigger('G55_DTPART'	,'G55_DTPART'	,{||.T.}, bTrig)
	oStruG55:AddTrigger('G55_DTCHEG'	,'G55_DTCHEG'	,{||.T.}, bTrig)
	oStruG55:AddTrigger('G55_CONF'		,'G55_CONF'		,{||.T.}, bTrig)
	oStruG55:AddTrigger('G55_LOCORI'	,'G55_LOCORI'	,{||.T.}, bTrig)
	oStruG55:AddTrigger('G55_LOCDES'	,'G55_LOCDES'	,{||.T.}, bTrig)

	oStruG55:SetProperty('G55_CONF'		, MODEL_FIELD_INIT	, bInit )
	oStruG55:SetProperty('G55_CANCEL'	, MODEL_FIELD_INIT	, bInit )

Endif

If ValType(oStruGQE) == "O"
	oStruGQE:AddTrigger('GQE_RECURS'	,'GQE_RECURS'	,{||.T.}, bTrig)
	oStruGQE:AddTrigger('GQE_TRECUR'	,'GQE_TRECUR'	,{||.T.}, bTrig)
	oStruGQE:AddTrigger('GQE_STATUS'	,'GQE_STATUS'	,{||.T.}, bTrig)
	oStruGQE:AddTrigger('GQE_TERC'		,'GQE_TERC'		,{||.T.}, bTrig)

	oStruGQE:SetProperty("GQE_TCOLAB"	, MODEL_FIELD_WHEN	,bWhen)
	
	oStruGQE:SetProperty('GQE_DRECUR'	, MODEL_FIELD_INIT	, bInit) 
	
	oStruGQE:SetProperty('GQE_RECURS'	,MODEL_FIELD_OBRIGAT, .F.)

	oStruGQE:SetProperty('GQE_RECURS'	, MODEL_FIELD_VALID , bFldVld)
	
Endif

If ValType(oStruG56) == "O" .And. VldStruG56()
	oStruG56:SetProperty('G56_VIAGEM'	, MODEL_FIELD_INIT	, bInit ) 
	oStruG56:SetProperty('G56_DTVIAG'	, MODEL_FIELD_INIT	, bInit )
	oStruG56:SetProperty('G56_USRPRT'	, MODEL_FIELD_INIT	, bInit )
	oStruG56:SetProperty('G56_STSOCR'	, MODEL_FIELD_INIT	, bInit ) 
	oStruG56:SetProperty('G56_NMTPOC'	, MODEL_FIELD_INIT	, bInit )
	oStruG56:SetProperty('G56_NMLOCA'	, MODEL_FIELD_INIT	, bInit )
	oStruG56:SetProperty('G56_NMDEST'	, MODEL_FIELD_INIT	, bInit )

	oStruG56:AddTrigger('G56_VIAGEM'	,'G56_VIAGEM'	,{||.T.}, bTrig)
	oStruG56:AddTrigger('G56_TPOCOR'	,'G56_TPOCOR'	,{||.T.}, bTrig)
	oStruG56:AddTrigger('G56_LOCORI'	,'G56_LOCORI'	,{||.T.}, bTrig)
	oStruG56:AddTrigger('G56_LOCDES'	,'G56_LOCDES'	,{||.T.}, bTrig)
EndIf


// Tratativa para Viagens Extras sem Linha ( GTPA900 - Orçamento Contrato )
If !Empty(cContrato) .And. GYN->(FIELDPOS("GYN_EXTCMP")) > 0
	oStruGYN:SetProperty('GYN_TIPO'	  	, MODEL_FIELD_INIT	, bInit ) 	
	oStruGYN:SetProperty('GYN_CODGY0' 	, MODEL_FIELD_INIT	, bInit ) 
	oStruGYN:SetProperty('GYN_EXTCMP' 	, MODEL_FIELD_INIT	, bInit ) 

	oStruGYN:SetProperty('GYN_TIPO'		, MODEL_FIELD_WHEN	,bWhen)
	oStruGYN:SetProperty('GYN_CODGY0'	, MODEL_FIELD_WHEN	,bWhen)	
EndIf
// Fim da Tratativa para Viagens Extras sem Linha ( GTPA900 - Orçamento Contrato )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid
Função responsavel pela validação dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param oMdl, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uNewValue, character, (Descrição do parâmetro)
@param uOldValue, character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local oModel	:= oMdl:GetModel()
Local oMdlGYN	:= oModel:GetModel("GYNMASTER")
Local oMdlGQE   := oModel:GetModel("GQEDETAIL")
Local oMdlG55   := oModel:GetModel("G55DETAIL")
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""
Local cCodRecur	:= oMdlGQE:GetValue("GQE_RECURS")
Local cTipo		:= oMdlGQE:GetValue("GQE_TRECUR")  
Local cHrIni    := oMdlG55:GetValue("G55_HRINI" )     
Local cHrFim    := oMdlG55:GetValue("G55_HRFIM" ) 
Local cLinha	:= oMdlGYN:GetValue("GYN_LINCOD")
Local dDtIni	:= oMdlG55:GetValue("G55_DTPART")     
Local dDtFim    := oMdlG55:GetValue("G55_DTCHEG")    
Local dDtRef    := iIF(!Empty(oMdlGQE:GetValue("GQE_DTREF")), oMdlGQE:GetValue("GQE_DTREF" ), oMdlG55:GetValue("G55_DTPART"))
Local nRecGQK   := oMdlGQE:GetDataId()
Local lTerceiro	:= Iif(oMdlGQE:GetValue("GQE_TERC") == '1', .T., .F.)
Local lRet		:= .T.

Do Case
	Case Empty(uNewValue)
		lRet := .T.
	Case cMdlId == "GYNMASTER"
		If Alltrim(cField)+"|" $ "GYN_DTINI|GYN_HRINI|GYN_DTFIM|GYN_HRFIM|"
			If !FwIsInCallStack('GI300Receb') .And. !VldDataHora(oMdl)
				lRet		:= .F.
				cMsgErro	:= "Data e Hora Inicial maior que a Data e Hora Final"
				cMsgSol		:= "Informe uma Data/Hora menor que a Data/Hora Final"
			Endif
			IF !IsBlind()
				If lRet .and. cField = "GYN_DTINI" .and. !CheckFreq(oMdl)
					lRet 		:= .F.
					cMsgErro	:= "Data selecionada é incompativel com a frequencia do serviço"
					cMsgSol		:= "Selecione uma data compatível a frequência de serviço"
				Endif
			Endif
		ElseIf cField == "GYN_CODGID"
			If !GTPExistCpo("GID",uNewValue+'2',4,.F.)
				lRet		:= .F.
				cMsgErro	:= "Registro não existe ou se encontra bloqueado"
				cMsgSol		:= "Verifique se o mesmo se encontra cadastrado e ativo para uso"
			Endif
		Endif

	Case cField == "GQE_RECURS"
		//Alterado por Fernando Radu em 01/08/2022 
		//- Ajuste efetuado para passar parâmetro cLinha e @cMsgSol
		If !Gc300VldAloc(cCodRecur,cTipo,dDtRef,dDtIni,cHrIni,dDtFim,cHrFim,@cMsgErro,!lTerceiro,nRecGQK,,cLinha,@cMsgSol)
			lRet := .F.
		EndIf

EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldWhen
Função responsavel pelo When dos Campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param uVal, character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldWhen(oMdl,cField,uVal)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetID()
Local nOpc		:= oModel:GetOperation()
Local lTrig		:= FwIsInCallStack('FIELDTRIGGER')
Local lInsert	:= nOpc == MODEL_OPERATION_INSERT

Do Case
	Case lTrig
		lRet := .T.
	Case cMdlId == "GYNMASTER"

		If cField == 'GYN_TIPO'	.And. !Empty(cContrato) .And. GYN->(FIELDPOS("GYN_EXTCMP")) > 0	// Tratativa para Viagens Extras sem Linha ( GTPA900 - Orçamento Contrato )
			lRet := .F.
		
		ElseIf cField == 'GYN_CODGY0' .And. !Empty(cContrato)  .And. GYN->(FIELDPOS("GYN_EXTCMP")) > 0	// Tratativa para Viagens Extras sem Linha ( GTPA900 - Orçamento Contrato )

			lRet := .F.
		ElseIf cField == "GYN_TIPO"
			lRet := lInsert
		ElseIf cField == "GYN_SRVEXT"
			lRet := lInsert .And. oMdl:GetValue("GYN_TIPO") == "2" 
		ElseIf cField == "GYN_LINCOD"
			lRet :=  lInsert 

		ElseIf cField == "GYN_LINSEN"
			lRet :=  lInsert .AND. oMdl:GetValue("GYN_TIPO") $ "1|3"

		ElseIf cField == "GYN_CODGID"
			lRet := lInsert .AND. oMdl:GetValue("GYN_TIPO") $ "1|3"

		ElseIf cField == "GYN_DTINI"
			lRet := oMdl:GetValue("GYN_TIPO") == '2';
					.OR.  (oMdl:GetValue("GYN_TIPO") $ '1|3' .and. !Empty(oMdl:GetValue("GYN_CODGID")) .AND. lInsert);
					.OR. isinCallStack("GerVgExtr")

		ElseIf cField == "GYN_DTFIM"
			lRet := Empty(oMdl:GetValue("GYN_CODGID"))

		ElseIf cField == "GYN_LOCORI"
			lRet := Empty(oMdl:GetValue("GYN_CODGID")) 

		ElseIf cField == "GYN_LOCDES"
			lRet := Empty(oMdl:GetValue("GYN_CODGID"))

		ElseIf cField == "GYN_HRINI"
			lRet := Empty(oMdl:GetValue("GYN_CODGID"))

		ElseIf cField == "GYN_HRFIM"
			lRet := Empty(oMdl:GetValue("GYN_CODGID"))

		ElseIf cField == "GYN_TIPO"	
			lRet := lInsert

		ElseIf cField == "GYN_IDENT"
			lRet := lInsert

		Endif
	Case cMdlId == "G55DETAIL"
		If cField == ""
			lRet := .T.
		Endif
	
	Case cMdlId == "GQEDETAIL"
		If cField == "GQE_TCOLAB"
			lRet := oMdl:GetValue("GQE_TRECUR") == "1"
		Endif
		
EndCase

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função responsavel pelo gatilho dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)
Local cMdlId	:= oMdl:GetID()
Local oModel	:= oMdl:GetModel()
Local oMdlGYN	:= oModel:GetModel('GYNMASTER')
Local oMdlG55	:= oModel:GetModel('G55DETAIL')
Local oMdlG56	:= oModel:GetModel('G56DETAIL')
Local oView		:= FwViewActive()
Local n1			:= 1
Local lG55InsLine	:= !oMdlG55:CanInsertLine()	
Local lG55UpdLine	:= !oMdlG55:CanUpdateLine()	
Local lG55DelLine	:= !oMdlG55:CanDeleteLine()	

oMdlG55:SetNoUpdateLine(.F.)// NÃO Bloquea atualização da grid
oMdlG55:SetNoInsertLine(.F.)// NÃO Bloquea inserção de nova linha no grid
oMdlG55:SetNoDeleteLine(.F.)// NÃO Bloquea deleção da linha

Do Case
	Case cMdlId == "GYNMASTER"
		If cField == "GYN_TIPO"
			oMdl:SetValue('GYN_LINCOD','')
			oMdl:SetValue('GYN_SRVEXT','')

		ElseIf cField == "GYN_SRVEXT"
			oMdl:SetValue('GYN_DSVEXT', Posicione("GYW",1,FwxFilial("GYW")+uVal,"GYW_DESC") )

		ElseIf  cField == "GYN_LINCOD"
			oMdl:SetValue('GYN_LINSEN','')

		ElseIf cField == "GYN_LINSEN"
			oMdl:SetValue('GYN_CODGID','')

		ElseIf cField == "GYN_CODGID"
			oMdl:SetValue('GYN_DTINI'	,StoD(''))
			oMdl:SetValue('GYN_HRINI'	,'')
			oMdl:SetValue('GYN_LOCORI'	,'')
			oMdl:SetValue('GYN_DTFIM'	,StoD(''))
			oMdl:SetValue('GYN_HRFIM'	,'')
			oMdl:SetValue('GYN_LOCDES'	,'')

			
			oMdl:SetValue('GYN_LOTACA'	,Posicione("GID",4,FwxFilial("GID")+uVal+'2',"GID_LOTACA"))
			
			SetTrechosServico(oModel,uVal)

		ElseIf cField == "GYN_DTINI"
			UpdDiasTrechos(oModel)

		ElseIf cField == "GYN_CONF"
			IF !FwIsInCallStack("GC300TRGG55")
				uVal := If(uVal=='1',uVal,'2')
				For n1	:= 1 to oMdlG55:Length()
					If !oMdlG55:IsDeleted(n1)
						oMdlG55:GoLine(n1)
						oMdlG55:SetValue('G55_CONF',uVal)
					Endif
				Next
				Gc300TrgG55(oModel,2,uVal)
			Endif

		ElseIf cField == "GYN_LOCORI"
			oMdl:SetValue('GYN_DSCORI', Posicione("GI1",1,FwxFilial("GI1")+uVal,"GI1_DESCRI") )
			oMdl:SetValue('GYN_KMPROV', GetKmProvavel(oMdl) )

		ElseIf cField == "GYN_LOCDES"
			oMdl:SetValue('GYN_DSCDES', Posicione("GI1",1,FwxFilial("GI1")+uVal,"GI1_DESCRI") )
			oMdl:SetValue('GYN_KMPROV', GetKmProvavel(oMdl) )
		Endif

	Case cMdlId == "G55DETAIL"
		If cField == 'G55_DTPART'
			If oMdlGYN:GetValue('GYN_TIPO') == '2' .AND. oMdl:GetLine() == aScan(oMdl:GetData(),{|x| !x[3] }) //Primeiro registro não deletado
				oMdlGYN:SetValue('GYN_DTINI',uVal)
			Endif
		ElseIf cField == 'G55_HRINI'
			If oMdl:GetLine() == aScan(oMdl:GetData(),{|x| !x[3] }) //Primeiro registro não deletado
				oMdlGYN:SetValue('GYN_HRINI',uVal)
			Endif

		ElseIf cField == 'G55_LOCORI'
			
			oMdl:SetValue('G55_DESORI', Posicione("GI1",1,FwxFilial("GI1")+uVal,"GI1_DESCRI") )
			
			If oMdl:GetLine() == aScan(oMdl:GetData(),{|x| !x[3] }) //Primeiro registro não deletado
				oMdlGYN:SetValue('GYN_LOCORI',uVal)
			Endif

		ElseIf cField == 'G55_DTCHEG'
			If oMdl:Length() == oMdl:GetLine()
				oMdlGYN:SetValue('GYN_DTFIM',uVal)
			Endif

		ElseIf cField == 'G55_LOCDES'
			oMdl:SetValue('G55_DESDES', Posicione("GI1",1,FwxFilial("GI1")+uVal,"GI1_DESCRI") )
			
			If oMdl:Length() == oMdl:GetLine()
				oMdlGYN:SetValue('GYN_LOCDES',uVal)
			Endif

		ElseIf cField == 'G55_HRFIM'
			If oMdl:Length() == oMdl:GetLine()
				oMdlGYN:SetValue('GYN_HRFIM',uVal)
			Endif
		ElseIf cField == "G55_CONF"
			IF !FwIsInCallStack("GC300TRGGQE")
				Gc300TrgG55(oModel,1,uVal)
			Else
				Gc300TrgG55(oModel,2,uVal)
			Endif
		Endif
		
	Case cMdlId == "GQEDETAIL"
		If cField == "GQE_STATUS"
			If !FwIsInCallStack("GC300TRGG55")
				Gc300TrgGQE(oModel)
			Endif
		ElseIf cField == "GQE_RECURS"
			oMdl:SetValue('GQE_DRECUR',GetDescRec(uVal,oMdl:GetValue('GQE_TRECUR'),oMdl:GetValue('GQE_TERC') ))

		ElseIf cField == "GQE_TRECUR" .or. cField == "GQE_TERC"
			oMdl:LoadValue("GQE_RECURS","")
			oMdl:LoadValue("GQE_DRECUR","")
			oMdl:LoadValue("GQE_TCOLAB","")
			oMdl:LoadValue("GQE_DCOLAB","")
		Endif

	Case cMdlid == "G56DETAIL" 
		If cField == 'G56_TPOCOR'
			uRet := POSICIONE("G6Q",1,XFILIAL("G6Q") + oMdlG56:GetValue("G56_TPOCOR"),"G6Q_DESCRI")
			oMdl:SetValue('G56_NMTPOC',uRet)
			If oMdlGYN:GetValue('GYN_FINAL') != '1'
				If POSICIONE("G6Q",1,XFILIAL("G6Q") + oMdlG56:GetValue("G56_TPOCOR"),"G6Q_OPERAC")
					oMdl:SetValue('G56_STSOCR','2')
					oMdlGYN:SetValue('GYN_STSOCR','2')
				Else
					oMdl:SetValue('G56_STSOCR','3')
					oMdlGYN:SetValue('GYN_STSOCR','3')
				EndIf
			Else
				oMdl:SetValue('G56_STSOCR','1')
				oMdlGYN:SetValue('GYN_STSOCR','1')
			EndIf
		ElseIf cField == 'G56_LOCORI'
			uRet := POSICIONE("GI1",1,XFILIAL("GI1") + oMdlG56:GetValue("G56_LOCORI"),"GI1_DESCRI")
			oMdl:SetValue('G56_NMLOCA',uRet)
		ElseIf cField == 'G56_LOCDES'
			uRet := POSICIONE("GI1",1,XFILIAL("GI1") + oMdlG56:GetValue("G56_LOCDES"),"GI1_DESCRI")
			oMdl:SetValue('G56_NMDEST',uRet)
		ElseIf cField == 'G56_VIAGEM'
			uRet := POSICIONE("GYN",1,XFILIAL("GYN") + oMdlG56:GetValue("G56_VIAGEM"),"GYN_DTINI")
			oMdl:SetValue('G56_DTVIAG',uRet)
			If POSICIONE("GYN",1,XFILIAL("GYN") + oMdlG56:GetValue("G56_VIAGEM"),"GYN_FINAL") == '1'
				oMdl:SetValue('G56_STSOCR','1')
			EndIf
		EndIf
EndCase

oMdlG55:SetNoUpdateLine(lG55InsLine)// Bloquea atualização da grid
oMdlG55:SetNoInsertLine(lG55UpdLine)// Bloquea inserção de nova linha no grid
oMdlG55:SetNoDeleteLine(lG55DelLine)// Bloquea deleção da linha

If !IsBlind() .and. ValType(oView) == "O" .AND. oView:IsActive()
	oView:Refresh()
Endif

Return uVal

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldInit
Função responsavel pelo inicializador dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Local uRet		:= uVal
Local oModel	:= oMdl:GetModel()
Local lInsert	:= oModel:GetOperation() == MODEL_OPERATION_INSERT

Do Case 
	//Inicializadores da tabela GYN
	Case cField == "GYN_CONF"
		uRet := '2'
	
	//Inicializadores da tabela G55
	Case cField == "G55_CONF"
		uRet := '2'
	Case cField == "G55_CANCEL"
		uRet := '1'
	
	//Inicializadores da tabela GQE
	Case cField == "GQE_DRECUR"
		uRet := IIF(!lInsert, GetDescRec(GQE->GQE_RECURS,GQE->GQE_TRECUR,GQE->GQE_TERC),"")
	//Inicializadores da tabela G56
	Case cField == "G56_VIAGEM"
		uRet := oModel:GetModel("GYNMASTER"):GetValue("GYN_CODIGO")
	Case cField == "G56_DTVIAG"
		uRet := oModel:GetModel("GYNMASTER"):GetValue("GYN_DTINI")
	Case cField == "G56_USRPRT"
		uRet := LogUserName()
	Case cField == 'G56_NMTPOC'
		If !lInsert
			uRet := POSICIONE("G6Q",1,XFILIAL("G6Q") + G56->G56_TPOCOR,"G6Q_DESCRI")
		EndIf
	Case cField == 'G56_NMLOCA'
		If !lInsert
			uRet := POSICIONE("GI1",1,XFILIAL("GI1") + G56->G56_LOCORI,"GI1_DESCRI")
		EndIf
	Case cField == 'G56_NMDEST'
		If !lInsert
			uRet := POSICIONE("GI1",1,XFILIAL("GI1") + G56->G56_LOCDES,"GI1_DESCRI")
		EndIf
	// Tratativa para Viagens Extras sem Linha ( GTPA900 - Orçamento Contrato )

	Case cField == 'GYN_TIPO' .And. !Empty(cContrato) .And. GYN->(FieldPos("GYN_EXTCMP")) > 0	
		uRet:= '2'		

	Case cField == 'GYN_CODGY0' .And. !Empty(cContrato) .And. GYN->(FieldPos("GYN_EXTCMP")) > 0	
		uRet:= cContrato	

	Case cField == 'GYN_EXTCMP' .And. !Empty(cContrato) .And. GYN->(FieldPos("GYN_EXTCMP")) > 0	
		uRet:= .T. 		
	
	// Fim da Tratativa para Viagens Extras sem Linha ( GTPA900 - Orçamento Contrato )
EndCase

Return uRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da  View Interface 

@sample  	ViewDef()

@return  	oView - Objeto do View

@author 	Lucas.Brustolin
@since 		25/03/2015
@version	P12
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView		:= FWFormView():New()
Local oModel 	:= FWLoadModel( 'GTPA300' )
Local oStruGYN	:= FWFormStruct( 2, 'GYN' ) 
Local oStruG55	:= FWFormStruct( 2, 'G55' ) 
Local oStruGQE	:= FWFormStruct( 2, 'GQE' )
Local oStruG56	:= FWFormStruct( 2, 'G56' ) 	

SetViewStruct(oStruGYN,oStruG55,oStruGQE,oStruG56)

// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona componentes a serem visualiados na tela
oView:AddField('VIEW_GYN1', oStruGYN,'GYNMASTER') 
oView:AddGrid('VIEW_G55', oStruG55,'G55DETAIL')
oView:AddGrid('VIEW_GQE', oStruGQE,'GQEDETAIL')

// Cria Folder na view
oView:CreateFolder("FOLDER")

// Define as pastas nas folders Viagens Normais/Extraordinarias   
oView:AddSheet( "FOLDER", "ABA01", STR0047) // "Definição Viagem" 
oView:CreateHorizontalBox( 'GYN1', 100, /*owner*/,/*lUsePixel*/, 'FOLDER', 'ABA01' ) 

oView:AddSheet( "FOLDER", "ABA02", STR0048) // "Trechos/Recursos"
oView:CreateHorizontalBox( 'G55' , 50, /*owner*/,/*lUsePixel*/, 'FOLDER', 'ABA02' ) 
oView:CreateHorizontalBox( 'GQE' , 50, /*owner*/,/*lUsePixel*/, 'FOLDER', 'ABA02' ) 

oView:SetOwnerView('VIEW_GYN1','GYN1')
oView:SetOwnerView('VIEW_G55','G55')
oView:SetOwnerView('VIEW_GQE','GQE')

oView:EnableTitleView('VIEW_G55',STR0049)	//'Trecho Viagem'
oView:EnableTitleView('VIEW_GQE',STR0050)	//"Recursos por viagem"

oView:AddIncrementField('VIEW_G55','G55_SEQ')
oView:AddIncrementField('VIEW_GQE','GQE_ITEM')

If VldStruG56()
	oView:AddSheet( "FOLDER", "ABA03", "Ocorrências")
	oView:AddGrid('VIEW_G56', oStruG56,'G56DETAIL')
	oView:CreateHorizontalBox( 'G56' , 100, /*owner*/,/*lUsePixel*/, 'FOLDER', 'ABA03' ) 
	oView:SetOwnerView('VIEW_G56','G56')
	oView:EnableTitleView('VIEW_G56',STR0066)	//"Ocorrências"
Endif

Return(oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct(oStruGYN,oStruG55,oStruGQE)

@type function
@author jacomo.fernandes
@since 10/06/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return nil, nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function SetViewStruct(oStruGYN,oStruG55,oStruGQE,oStruG56)

If ValType(oStruGYN) == "O"
	oStruGYN:RemoveField("GYN_SETOR"	)
	oStruGYN:RemoveField("GYN_IDENT"	)
	oStruGYN:RemoveField("GYN_LOCTER"	)
	oStruGYN:RemoveField("GYN_DSCTER"	)
	oStruGYN:RemoveField("GYN_EXEC"		)
	oStruGYN:RemoveField("GYN_ALTER"	)
	oStruGYN:RemoveField("GYN_MONIT"	)
	oStruGYN:RemoveField("GYN_DTGER"	)
	oStruGYN:RemoveField("GYN_HRGER"	)

	//AGRUPA OS CAMPOS DA PASTA VIAGEM NORMAL               |
	oStruGYN:AddGroup('SERVICO'			, STR0039	, '', 2 )//'Serviço/Viagem'

	If GYN->(FieldPos("GYN_EXTCMP")) > 0 .AND. Empty(cContrato)
		oStruGYN:AddGroup('LINHA'			, "Linha"	, '', 2 )//'Linha'
	EndIf
	oStruGYN:AddGroup('ITINERARIO'		, STR0040	, '', 2 )//'Itinerário'
	oStruGYN:AddGroup('EXTRAORDINARIO'	, STR0041	, '', 2 )//'EXTRAORDINARIO'
	oStruGYN:AddGroup('INTERRUPCAO'		, STR0042	, '', 2 )//'Interrupção da viagem'
	oStruGYN:AddGroup('DEMAIS'			, STR0043	, '', 5 )//'Demais Informações'
	
	//Agrupa todos os campos em 'DEMAIS'
	oStruGYN:SetProperty("*", MVC_VIEW_GROUP_NUMBER, "DEMAIS" )
    
	//Agrupa os campos abaixo em 'SERVICO'
    oStruGYN:SetProperty("GYN_CODIGO"	, MVC_VIEW_GROUP_NUMBER, "SERVICO" )
    oStruGYN:SetProperty("GYN_TIPO"		, MVC_VIEW_GROUP_NUMBER, "SERVICO" )
    oStruGYN:SetProperty("GYN_SRVEXT"	, MVC_VIEW_GROUP_NUMBER, "SERVICO" )
    oStruGYN:SetProperty("GYN_DSVEXT"	, MVC_VIEW_GROUP_NUMBER, "SERVICO" )
    oStruGYN:SetProperty("GYN_EXTRA"	, MVC_VIEW_GROUP_NUMBER, "SERVICO" )
	If GYN->(FieldPos("GYN_EXTCMP")) > 0 .AND. Empty(cContrato)
    	oStruGYN:SetProperty("GYN_EXTCMP"	, MVC_VIEW_GROUP_NUMBER, "SERVICO" )
	EndIf
	//Agrupa os campos abaixo em 'LINHA'
	oStruGYN:SetProperty("GYN_LINCOD"	, MVC_VIEW_GROUP_NUMBER, "LINHA" )
    oStruGYN:SetProperty("GYN_LINSEN"	, MVC_VIEW_GROUP_NUMBER, "LINHA" )
    oStruGYN:SetProperty("GYN_CODGID"	, MVC_VIEW_GROUP_NUMBER, "LINHA" )    
    oStruGYN:SetProperty("GYN_NUMSRV"	, MVC_VIEW_GROUP_NUMBER, "LINHA" )
	oStruGYN:SetProperty("GYN_LOTACA"	, MVC_VIEW_GROUP_NUMBER, IIF(Empty(cContrato).And. GYN->(FieldPos("GYN_EXTCMP")) > 0,"LINHA","EXTRAORDINARIO" ) )
	
    //Agrupa os campos abaixo em 'ITINERARIO'
    oStruGYN:SetProperty("GYN_DTINI"	, MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )
    oStruGYN:SetProperty("GYN_HRINI"	, MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )
    oStruGYN:SetProperty("GYN_LOCORI"	, MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )
    oStruGYN:SetProperty("GYN_DSCORI"	, MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )
    oStruGYN:SetProperty("GYN_DTFIM"	, MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )
    oStruGYN:SetProperty("GYN_HRFIM"	, MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )
    oStruGYN:SetProperty("GYN_LOCDES"	, MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )
    oStruGYN:SetProperty("GYN_DSCDES"	, MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )    
    oStruGYN:SetProperty("GYN_KMPROV"	, MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )
	oStruGYN:SetProperty("GYN_KMREAL"	, MVC_VIEW_GROUP_NUMBER, "ITINERARIO" )
	
	//Agrupa os Campos abaixo em 'EXTRAORDINARIO'
	oStruGYN:SetProperty("GYN_FILPRO"	, MVC_VIEW_GROUP_NUMBER, "EXTRAORDINARIO" )
	oStruGYN:SetProperty("GYN_PROPOS"	, MVC_VIEW_GROUP_NUMBER, "EXTRAORDINARIO" )
	oStruGYN:SetProperty("GYN_OPORTU"	, MVC_VIEW_GROUP_NUMBER, "EXTRAORDINARIO" )
	oStruGYN:SetProperty("GYN_ITINI"	, MVC_VIEW_GROUP_NUMBER, "EXTRAORDINARIO" )
	oStruGYN:SetProperty("GYN_ITFIM"	, MVC_VIEW_GROUP_NUMBER, "EXTRAORDINARIO" )
	
	//Agrupa os Campos abaixo em 'INTERRUPCAO'
	oStruGYN:SetProperty('GYN_HRITR'	, MVC_VIEW_GROUP_NUMBER, 'INTERRUPCAO' )
	oStruGYN:SetProperty('GYN_ENDITR'	, MVC_VIEW_GROUP_NUMBER, 'INTERRUPCAO' )

	oStruGYN:SetProperty("GYN_CODIGO"	, MVC_VIEW_ORDEM		, '01' )
	oStruGYN:SetProperty("GYN_TIPO"	 	, MVC_VIEW_ORDEM		, '02' )
	oStruGYN:SetProperty("GYN_SRVEXT"	, MVC_VIEW_ORDEM		, '03' )
	oStruGYN:SetProperty("GYN_DSVEXT"	, MVC_VIEW_ORDEM		, '04' )
	oStruGYN:SetProperty("GYN_EXTRA" 	, MVC_VIEW_ORDEM		, '05' )
	If GYN->(FieldPos("GYN_EXTCMP")) > 0 .AND. Empty(cContrato)
		oStruGYN:SetProperty("GYN_EXTCMP" 	, MVC_VIEW_ORDEM	, '06' )
	EndIf
	oStruGYN:SetProperty("GYN_LINCOD"	, MVC_VIEW_ORDEM		, '07' )
	oStruGYN:SetProperty("GYN_LINSEN"	, MVC_VIEW_ORDEM		, '08' )
	oStruGYN:SetProperty("GYN_CODGID"	, MVC_VIEW_ORDEM		, '09' )
	oStruGYN:SetProperty("GYN_NUMSRV"	, MVC_VIEW_ORDEM		, '10' )
	oStruGYN:SetProperty("GYN_LOTACA"	, MVC_VIEW_ORDEM		, '11' )
	oStruGYN:SetProperty("GYN_DTINI" 	, MVC_VIEW_ORDEM		, '12' )
	oStruGYN:SetProperty("GYN_HRINI" 	, MVC_VIEW_ORDEM		, '13' )
	oStruGYN:SetProperty("GYN_LOCORI"	, MVC_VIEW_ORDEM		, '14' )
	oStruGYN:SetProperty("GYN_DSCORI"	, MVC_VIEW_ORDEM		, '15' )
	oStruGYN:SetProperty("GYN_DTFIM" 	, MVC_VIEW_ORDEM		, '16' )
	oStruGYN:SetProperty("GYN_HRFIM" 	, MVC_VIEW_ORDEM		, '17' )
	oStruGYN:SetProperty("GYN_LOCDES"	, MVC_VIEW_ORDEM		, '18' )
	oStruGYN:SetProperty("GYN_DSCDES"	, MVC_VIEW_ORDEM		, '19' )
	oStruGYN:SetProperty("GYN_KMPROV"	, MVC_VIEW_ORDEM		, '20' )
	oStruGYN:SetProperty("GYN_KMREAL"	, MVC_VIEW_ORDEM		, '21' )
	oStruGYN:SetProperty("GYN_FILPRO"	, MVC_VIEW_ORDEM		, '22' )
	oStruGYN:SetProperty("GYN_PROPOS"	, MVC_VIEW_ORDEM		, '23' )
	oStruGYN:SetProperty("GYN_OPORTU"	, MVC_VIEW_ORDEM		, '24' )
	oStruGYN:SetProperty("GYN_ITINI" 	, MVC_VIEW_ORDEM		, '25' )
	oStruGYN:SetProperty("GYN_ITFIM" 	, MVC_VIEW_ORDEM		, '26' )
	oStruGYN:SetProperty("GYN_HRITR" 	, MVC_VIEW_ORDEM		, '27' )
	oStruGYN:SetProperty("GYN_ENDITR"	, MVC_VIEW_ORDEM		, '28' )
	// Tratativa para Viagens Extras sem Linha ( GTPA900 - Orçamento Contrato )

	If !Empty(cContrato) .And. GYN->(FieldPos("GYN_EXTCMP")) > 0	
		oStruGYN:RemoveField('GYN_EXTRA')
		oStruGYN:RemoveField("GYN_LINCOD")
		oStruGYN:RemoveField("GYN_LINSEN")
		oStruGYN:RemoveField("GYN_CODGID")
		oStruGYN:RemoveField("GYN_NUMSRV")
		//oStruGYN:RemoveField("GYN_LOTACA")
	ElseIf Empty(cContrato) .And. GYN->(FieldPos("GYN_EXTCMP")) > 0	
		oStruGYN:RemoveField('GYN_EXTCMP')
	EndIf

	// Fim da Tratativa para Viagens Extras sem Linha	
		
	If GYN->(FieldPos('GYN_SEMFRQ')) > 0
		oStruGYN:SetProperty('GYN_SEMFRQ', MVC_VIEW_CANCHANGE, .F. )
	Endif
Endif

If ValType(oStruG55) == "O"
	oStruG55:RemoveField('G55_CODIGO')
	oStruG55:RemoveField('G55_CODVIA')
	oStruG55:RemoveField('G55_CODGID')
	oStruG55:RemoveField('G55_CANCEL')
	oStruG55:RemoveField('G55_CONF')
	oStruG55:RemoveField('G55_ESCALA')
	oStruG55:RemoveField('G55_NUMSRV')
	
	oStruG55:SetProperty('*'			, MVC_VIEW_CANCHANGE, .F. )
	oStruG55:SetProperty('G55_DTPART'	, MVC_VIEW_CANCHANGE, .T. )
	oStruG55:SetProperty('G55_DTCHEG'	, MVC_VIEW_CANCHANGE, .T. )
	oStruG55:SetProperty('G55_HRINI'	, MVC_VIEW_CANCHANGE, .T. )
	oStruG55:SetProperty('G55_HRFIM'	, MVC_VIEW_CANCHANGE, .T. )
	oStruG55:SetProperty('G55_LOCORI'	, MVC_VIEW_CANCHANGE, .T. )
	oStruG55:SetProperty('G55_LOCDES'	, MVC_VIEW_CANCHANGE, .T. )

	oStruG55:SetProperty("G55_SEQ"		, MVC_VIEW_ORDEM		, '01' )
	oStruG55:SetProperty("G55_DTPART"	, MVC_VIEW_ORDEM		, '02' )
	oStruG55:SetProperty("G55_HRINI"	, MVC_VIEW_ORDEM		, '03' )
	oStruG55:SetProperty("G55_LOCORI"	, MVC_VIEW_ORDEM		, '04' )
	oStruG55:SetProperty("G55_DESORI"	, MVC_VIEW_ORDEM		, '05' )
	oStruG55:SetProperty("G55_DTCHEG"	, MVC_VIEW_ORDEM		, '06' )
	oStruG55:SetProperty("G55_HRFIM"	, MVC_VIEW_ORDEM		, '07' )
	oStruG55:SetProperty("G55_LOCDES"	, MVC_VIEW_ORDEM		, '08' )
	oStruG55:SetProperty("G55_DESDES"	, MVC_VIEW_ORDEM		, '09' )
Endif

If ValType(oStruGQE) == "O"
	oStruGQE:RemoveField('GQE_CODIGO'	)
	oStruGQE:RemoveField('GQE_VIACOD'	)
	oStruGQE:RemoveField('GQE_ALOCOD'	)
	oStruGQE:RemoveField('GQE_STATUS'	)
	oStruGQE:RemoveField('GQE_CANCEL'	)
	oStruGQE:RemoveField('GQE_CODGYM'	)
	oStruGQE:RemoveField('GQE_SEQ'		)
	oStruGQE:RemoveField('GQE_JUSTIF'	)
	oStruGQE:RemoveField('GQE_ESPHIN'	)
	oStruGQE:RemoveField('GQE_ESPHFM'	)
	oStruGQE:RemoveField('GQE_OCOVIA'	)
	oStruGQE:RemoveField('GQE_DSCOCO'	)
	oStruGQE:RemoveField('GQE_NUMSRV'	)
	oStruGQE:RemoveField("GQE_ESCALA"	)
	oStruGQE:RemoveField("GQE_ESCITE"	)
	oStruGQE:RemoveField("GQE_CONF"		)
	oStruGQE:RemoveField("GQE_TPCONF"	)
	oStruGQE:RemoveField("GQE_USRCON"	)
	oStruGQE:RemoveField("GQE_MARCAD"	)

	oStruGQE:SetProperty("GQE_ITEM"		, MVC_VIEW_ORDEM		, '01' )
	oStruGQE:SetProperty("GQE_DTREF"	, MVC_VIEW_ORDEM		, '02' )
	oStruGQE:SetProperty("GQE_TRECUR"	, MVC_VIEW_ORDEM		, '03' )
	oStruGQE:SetProperty("GQE_TERC"		, MVC_VIEW_ORDEM		, '04' )
	oStruGQE:SetProperty("GQE_RECURS"	, MVC_VIEW_ORDEM		, '05' )
	oStruGQE:SetProperty("GQE_DRECUR"	, MVC_VIEW_ORDEM		, '06' )
	oStruGQE:SetProperty("GQE_TCOLAB"	, MVC_VIEW_ORDEM		, '07' )
	oStruGQE:SetProperty("GQE_DCOLAB"	, MVC_VIEW_ORDEM		, '08' )
	oStruGQE:SetProperty("GQE_HRINTR"	, MVC_VIEW_ORDEM		, '09' )
	oStruGQE:SetProperty("GQE_HRFNTR"	, MVC_VIEW_ORDEM		, '10' )
Endif

If ValType(oStruG56) == "O" .And.  VldStruG56()
	oStruG56:RemoveField("G56_CODIGO")
	oStruG56:RemoveField("G56_USRPRT")
	oStruG56:RemoveField("G56_STSOCR")
EndIf

Return 
//------------------------------------------------------------------------------
/*/{Protheus.doc} SetTrechosServico(oModel)

@type function
@author jacomo.fernandes
@since 10/06/2019
@version 1.0
@param oModel, character, (Descrição do parâmetro)
@return Nil, nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetTrechosServico(oModel,cCodGID)
Local oMdlG55	:= oModel:GetModel('G55DETAIL')
Local cTmpAlias	:= GetNextAlias()

GTPxClearData(oMdlG55)

BeginSql Alias cTmpAlias
	SELECT
		GIE.GIE_CODGID,
		GIE.GIE_SEQ,
		GIE.GIE_IDLOCP,
		GIE.GIE_HORLOC,
		GIE.GIE_IDLOCD,
		GIE.GIE_HORDES
		
	FROM %Table:GIE% GIE
	WHERE
		GIE.GIE_FILIAL = %xFilial:GIE%
		AND GIE.GIE_CODGID = %Exp:cCodGID%
		AND GIE.GIE_HIST = '2'	
		AND GIE.%NotDel%
	Order By GIE.GIE_SEQ
EndSql

While (cTmpAlias)->(!Eof())
			
	If !oMdlG55:IsEmpty()
		oMdlG55:addLine()
	Endif

	oMdlG55:SetValue("G55_CODGID"	, (cTmpAlias)->GIE_CODGID	)	
	oMdlG55:SetValue("G55_SEQ"		, (cTmpAlias)->GIE_SEQ		)
	oMdlG55:SetValue("G55_LOCORI"	, (cTmpAlias)->GIE_IDLOCP	)
	oMdlG55:SetValue("G55_HRINI"	, (cTmpAlias)->GIE_HORLOC 	)
	oMdlG55:SetValue("G55_LOCDES"	, (cTmpAlias)->GIE_IDLOCD	)
	oMdlG55:SetValue("G55_HRFIM"	, (cTmpAlias)->GIE_HORDES	)
	oMdlG55:SetValue("G55_CONF"		, '2'	)
	oMdlG55:SetValue("G55_CANCEL"	, '1'	)

	(cTmpAlias)->( DbSkip() )
EndDo


(cTmpAlias)->(DbCloseArea())

oMdlG55:GoLine(1)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} UpdDiasTrechos

@type function
@author jacomo.fernandes
@since 10/06/2019
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return nil, Nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function UpdDiasTrechos(oModel)
Local oMdlGYN	:= oModel:GetModel("GYNMASTER")
Local oMdlG55	:= oModel:GetModel("G55DETAIL")
Local cCodGID	:= oMdlGYN:GetValue("GYN_CODGID")
Local dDtIni	:= oMdlGYN:GetValue("GYN_DTINI")
Local dDtAux	:= oMdlGYN:GetValue("GYN_DTINI")
Local ndia		:= 0
Local cTmpAlias	:= GetNextAlias()

If oMdlGYN:GetValue('GYN_TIPO') $ "1|3"

	BeginSql Alias cTmpAlias
		SELECT
			GIE.GIE_SEQ,
			GIE.GIE_IDLOCP,
			GIE.GIE_HORLOC,
			GIE.GIE_IDLOCD,
			GIE.GIE_HORDES,
			GIE.GIE_DIA
		FROM %Table:GIE% GIE
		WHERE
			GIE.GIE_FILIAL = %xFilial:GIE%
			AND GIE.GIE_CODGID = %Exp:cCodGID%
			AND GIE.GIE_HIST = '2'	
			AND GIE.%NotDel%
		Order By GIE.GIE_SEQ
	EndSql

	While (cTmpAlias)->(!EoF())
		If oMdlG55:SeekLine({{"G55_SEQ",(cTmpAlias)->GIE_SEQ} })
			ndia := MAX(ndia,(cTmpAlias)->GIE_DIA)
			//Soma dias decorrido para G55
			oMdlG55:LoadValue("G55_DTPART"	, dDtAux)
			oMdlG55:LoadValue("G55_DTCHEG"	, dDtIni + ndia )
			dDtAux	:= oMdlG55:GetValue("G55_DTCHEG")
		Endif
		(cTmpAlias)->(DbSkip())
	End

	(cTmpAlias)->(DbCloseArea())
	
	oMdlGYN:LoadValue("GYN_DTFIM",dDtAux)

Endif

oMdlG55:GoLine(1)

Return nil

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP300TudOK()
Rotina executada no PosValid do modelo de dados (TudOK). Realiza
validações no modelo de dados para que o mesmo seja salvo.
 
@sample	ModelDef()
 
@return	oModel - Objeto do Model
 
@author 	Lucas.Brustolin
@since 		06/07/2015
@version	P12
/*/ 
//--------------------------------------------------------------------------------------------------------
Static Function TP300TudOK(oModel)

Local oField		:= oModel:GetModel('GYNMASTER')
Local nOperation 	:= oModel:GetOperation()
Local nI			:= 0
Local cTipo			:= oField:GetValue("GYN_TIPO")
Local cSrvExt		:= oField:GetValue("GYN_SRVEXT")
Local cLinCod		:= oField:GetValue("GYN_LINCOD")
Local cSentid		:= oField:GetValue("GYN_LINSEN")
Local cCodGID		:= oField:GetValue("GYN_CODGID")
Local cHrIni 		:= oField:GetValue("GYN_HRINI")
Local cHrFim 		:= oField:GetValue("GYN_HRFIM") 

Local dDtIni 		:= oField:GetValue("GYN_DTINI")
Local dDtFim 		:= oField:GetValue("GYN_DTFIM") 
Local lExtra		:= oField:GetValue("GYN_EXTRA")
Local lRet   		:= .T.
Local cValExt		:= ''

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
	//--------------------------------------------------------------+
	// Valida a Data/Hora inicio com Data/Hora Final                |
	///-------------------------------------------------------------+
	If !VldDataHora(oField)
		Help(,,'GTPA300',,STR0025,1,0) //'Data/hora Início não podem ser maior ou igual Data/hora Fim.'
		lRet := .F.
	EndIf

	//--------------------------------------------------------------+
	// Valida se o serviço extraordinario foi preenchido.           |
	///-------------------------------------------------------------+
	If lRet .And. cTipo == "2" .And. Empty(cSrvExt)
		Help(,,'GTPA300',,STR0031,1,0)//'O tipo de serviço extraordinario deve ser preenchido.'
		lRet := .F.
	EndIf 
	
	//--------------------------------------------------------------+
	// Valida o preenchimento dos campos do tipo viagem Normal      |
	///-------------------------------------------------------------+		
	If lRet .And. cTipo == "1" .And. ( Empty(cLinCod) .Or. Empty(cSentid)  /*.Or. Empty(cCodGID) */)
		Help(,,'GTPA300',,STR0032,1,0) //O Preenchimento dos campos Cód. Linha, Sentido e Cód. Horário são obrigatorios para viagens do tipo Normal.
		lRet := .F.
	EndIf

	
	If nOperation == MODEL_OPERATION_INSERT 
		DbSelectArea("GYN")
		DbSetOrder(2) //GYN_FILIAL+GYN_LINCOD+GYN_CODGID+GYN_LINSEN+ GYN_DTINI+GYN_HRINI+GYN_DTFIM+GYN_HRFIM

		//-----------------------------------------------------------------------------+
		// Valida se a viagem do tipo normal que está sendo incluída já existe no BD   |
		///----------------------------------------------------------------------------+		
		If lRet .and. !lExtra .And. cTipo == "1" 
			If GYN->(DbSeek(xFilial("GYN") + cLinCod + cCodGID + cSentid + DTOS(dDtIni) + cHrIni + DTOS(dDtFim) + cHrFim  )) .and. !GYN->GYN_EXTRA
				Help(,,'GTPA300',,STR0018,1,0) //"Viagem já cadastrada para data informada."
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	If ( lRet .And. !FwIsInCallStack("F300CMTMDL") )
		
		For nI := 1 to oModel:GetModel("G55DETAIL"):Length()
			
			If ( !oModel:GetModel("G55DETAIL"):IsDeleted() )
				
				If ( Empty(oModel:GetModel("G55DETAIL"):GetValue("G55_DTPART")) .Or.;
						Empty(oModel:GetModel("G55DETAIL"):GetValue("G55_DTCHEG")) .Or.;
						Empty(oModel:GetModel("G55DETAIL"):GetValue("G55_HRINI")) .Or.;
						Empty(oModel:GetModel("G55DETAIL"):GetValue("G55_HRFIM"));
					)
					
					lRet := .F.
					oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"TP300TUDOK","Campos não preenchidos","Na aba de Itinirário, o conteúdo das datas e horários devem ser preenchidos.")
					
					Exit
						
				EndIf
					
			EndIf
			
		Next nI
		
	EndIf
	
	
	
ElseIf nOperation == MODEL_OPERATION_DELETE
	
	IF GYN->GYN_FINAL == "1"
		Help(,,'GTPA300DELFINAL',, STR0058 ,1,0)  //"Viagens Finalizadas não podem ser Excluídas!"
		lRet := .F.
	EndIf

	If lRet
		cValExt := GTPxExcInt("GYN", "GYN_CODIGO", GYN->GYN_CODIGO)
		If !Empty(cValExt)
			Help(,,'GTPA300DELINTEGR',, STR0071 ,1,0)  //"Viagens de integração não podem ser Excluídas!"
			lRet := .F.
		EndIf
	EndIf


EndIf


Return(lRet)

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecProcViag
Executa determinada rotina de processamento da viagem 
conforme a definicao do parametro.

@sample	GTPA3EXEC()
@return		
@author	Lucas.brustolin
@since		19/05/2015
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GTPA3EXEC(nOpc)

If (nOpc == 1  .Or. nOpc == 3) .And. (GYN->GYN_TIPO = '3' .And. !Empty(GYN->GYN_APUCON))
	MsgAlert(STR0077, STR0076) //'Esta viagem não pode ser alterada ou deletada.','Viagem Apurada'
	Return
EndIf

If nOpc == 1  
	IF !(GYN->GYN_FINAL == "1")
		FWExecView(STR0005,"GTPA300",MODEL_OPERATION_UPDATE,,{|| .T.})
	Else
		Help(,,'GTPA300FINALIZADA',, STR0059 ,1,0)  //"Viagens Finalizadas não podem ser Alteradas!"
	EndIF
ElseIf nOpc == 3
	IF !(GYN->GYN_FINAL == "1")
		FWExecView(STR0006,"GTPA300",MODEL_OPERATION_DELETE,,{|| .T.})
	Else
		Help(,,'GTPA300FINALIZADA',,STR0078,1,0) //"Viagens Finalizadas não podem ser deletada!"
	EndIF
ElseIf nOpc == 2 
	Processa( {|| GTPA3GER() }, STR0021,STR0022)//"Aguarde"#"Gerando viagens..." 
ElseIf nOpc == 4
	Processa( {|| GTPA3CON() }, STR0021,STR0024 )//"Aguarde"#'Avaliando conflitos...'
EndIf

Return Nil
	
//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP300SetXB
Rotina chamada atraves de uma consulta padrão. Tem como objetivo chamar uma segunda
cosulta com base no tipo de recurso da (Linha do Grid Selecionada). (Recursos ou Veiculos)

@sample	GTP300SetXB()
@Return 	lRet - .T. Se executou a SXB
@author	Lucas.brustolin
@since		14/10/2015
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GTP300SetXB()

Local aArea 	:= GetArea()
Local cF3		:= ""
Local lRet  	:= .F.
Local lTerceiro := (GQE->(FieldPos("GQE_TERC")) > 0) .AND. FwFldGet("GQE_TERC") == '1'


If FwFldGet("GQE_TRECUR") == "1"
	If lTerceiro
		cF3 := "GTPTEC" // Colaboradores Terceiro
	Else
		cF3 := "GYGFIL" // Colaboradores
	EndIf
Else
	If lTerceiro
		cF3	:= "GTPTEV" // Veiculos Terceiro
	Else
		cF3 := "ST9" // Veiculos ST9
	EndIf
EndIf 

lRet := Conpad1( , , , cF3 )

RestArea(aArea)

Return( lRet )

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP300RetXB
Rotina chamada atraves de uma consulta padrão. Tem como objetivo Retornar (Gatilhar) o valor 
da consulta padrão executada pela Função: GTP300SetXB

@sample		GTP300RetXB()
@Return        cCod - Valor do retorno da consulta padrão chamada pela rotina GTP300SetXB
@author	Lucas.brustolin
@since		14/10/2015
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GTP300RetXB()

Local cCod		:= ""
Local lTerceiro := (GQE->(FieldPos("GQE_TERC")) > 0) .AND. FwFldGet("GQE_TERC") == '1'

If lTerceiro
	&(Readvar()) := G6Z->G6Z_CODIGO
	cCod := G6Z->G6Z_CODIGO
Else

	If FwFldGet("GQE_TRECUR") == "1"
		&(Readvar()) := GYG->GYG_CODIGO
		cCod := GYG->GYG_CODIGO
	Else	
		&(Readvar()) := ST9->T9_CODBEM   
		cCod := ST9->T9_CODBEM     
	EndIf

EndIf

Return(cCod)

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TPExistGQE
Rotina de validação de campo, faz o uso do ExistCpo passando os parametros de acordo do Tipo de Recurso
definido na Linha do Grid (Recursos por Viagem) GQE.

@sample	TPExistGQE()
@author	Lucas.brustolin
@since		14/10/2015
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Function TPExistGQE(cConteudo)
Local lRet 		:= .T.
Local lTerceiro := (GQE->(FieldPos("GQE_TERC")) > 0) .AND. FwFldGet("GQE_TERC") == '1'

If lTerceiro
	lRet := ExistCpo("G6Z", cConteudo )
ElseIf FwFldGet("GQE_TRECUR") == '1'	//Colaborador
	lRet := ExistCpo("GYG", cConteudo )
Else
	lRet := ExistCpo("ST9", cConteudo )
EndIf

Return (lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPGetRecDesc()
Função responsavel para buscar a descrição do recurso
@type Function
@author jacomo.fernandes
@since 10/07/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPGetRecDesc(cCodRec,cTpRec,cTerceiro)
Return GetDescRec(cCodRec,cTpRec,cTerceiro)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetDescRec

@type function
@author jacomo.fernandes
@since 10/06/2019
@version 1.0
@param cCodRec, character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GetDescRec(cCodRec,cTpRec,cTerceiro)
Local cDescri		:= ""
Default cTerceiro	:= "2"

If cTerceiro == "1"
	cDescri :=  Posicione("G6Z",1,xFilial("G6Z")+ cCodRec,"G6Z_NOME"  )
ElseIf cTpRec == "1"
	cDescri :=  Posicione("GYG",1,xFilial("GYG")+ cCodRec,"GYG_NOME"  )
Else
	cDescri :=  Posicione("ST9",1,xFilial("ST9")+ cCodRec,"T9_NOME"  )
EndIf

Return(cDescri)


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA3GER
Realizar a geração das viagens conforme informado
nos Parametros.

@sample	GTPA3GER()
@return		
@author	Mick William da Silva
@since		27/07/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GTPA3GER(lBlind)
	
Local aArea			:= GetArea()
Local cAliasQry		:= GetNextAlias()
Local dDtIni			:= CTOD("  /  /    ")
Local dDtFim			:= CTOD("  /  /    ")
Local cLinIni			:= ""
Local cLinFim			:= ""
Local lErro				:= .F. 
Local lRet				:= .T.
Local n1			:= 0
Local nCont			:= 0 
Local dDtRef		:= CTOD("  /  /    ")
Local cWhere		:= ""
Default lBlind			:= .f.
		
	If lBlind .Or. Pergunte("GTPA300A",!lBlind) 
	
		dDtIni		:= MV_PAR01
		dDtFim		:= MV_PAR02
		cLinIni		:= MV_PAR03
		cLinFim 	:= MV_PAR04
		
		If !(Vazio(MV_PAR01) .And. Vazio(MV_PAR02))
		 	
			nCont := (MV_PAR02-MV_PAR01)+1
			
			ProcRegua(nCont)
			dDtRef := MV_PAR01
			For n1 := 1 To nCont	
				IncProc()
				cAliasQry		:= GetNextAlias()
				cWhere := "% GID.GID_"+UPPER(substr(DIASEMANA(dDtRef),1,3))+ " = 'T'  AND "
				cWhere += "  '"+DtoS(dDtRef)+"' BETWEEN GID.GID_INIVIG AND GID.GID_FINVIG  %"
			
				// ----------------------------------------------------------------------+
				// QUERY BUSCA OS HORARIOS/SERVICOS COM BASE NAS INFORMACOES DO PERGUNTE |
				// ----------------------------------------------------------------------+		
				BeginSql Alias cAliasQry		
					SELECT 	GID.GID_COD, 
							GID.GID_LINHA, 
							GID.GID_SENTID,
							GID.GID_FINVIG 
					FROM %TABLE:GID% GID
					WHERE  GID.GID_FILIAL =  %xfilial:GID%
						AND GID.GID_HIST = '2'
						AND GID.GID_LINHA BETWEEN  %Exp:cLinIni% AND %Exp:cLinFim%
						AND GID.%NotDel%
						AND %Exp:cWhere% 
						AND GID.GID_COD NOT IN 
							( 
								SELECT GYN_CODGID 
								FROM %TABLE:GYN% GYN
								WHERE 
									GYN.GYN_FILIAL = %xfilial:GYN% AND
									GYN.GYN_DTINI = %Exp:DtoS(dDtRef)% AND 
									GYN.GYN_LINCOD BETWEEN  %Exp:cLinIni% AND %Exp:cLinFim% AND
									GYN.%NotDel%
							)	
						
				EndSql
				// --------------------------------------------------------+
				// INCLUI UMA VIAGEM PARA CADA HORARIO ENCONTRADO NA QUERY |
				// --------------------------------------------------------+
				(cAliasQry)->(DbGoTop())				
				If (cAliasQry)->( !Eof() ) 		
					
					//-- Varre os trechos do cad. de horarios.
					While (cAliasQry)->( !Eof()  ) 		
						lRet := GTPXGerViag((cAliasQry)->GID_LINHA,(cAliasQry)->GID_SENTID,(cAliasQry)->GID_COD,DtoS(dDtRef),DtoS(dDtRef) )

						If !lRet
							lErro := .T.
						EndIf  

					//-- Pula para o proximo trecho					
					(cAliasQry)->(DbSkip())
					EndDo
					
				EndIf
				dDtRef:= dDtRef+1
				(cAliasQry)->(DbCloseArea())
			Next
		Else
			FwAlertHelp('Não foram informados os dados de data inicial e final')	
		ENDIF
	EndIf

RestArea(aArea)
		
Return (lRet)

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA300PreLin
Validação para nao poder deletar linha ja deleta relacionada a outra registro

@param 		oMdlG55 modelo da alias G55
			nLine Linha da grid
			cAcao Ação realizada na linha
			cCampo nome do campo posicionado 
			
@sample		GTPA300PreLin()
@return		Gerar Serviços
@author		Inovação 
@since		17/08/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Static Function GTPA300PreLin(oMdlG55,nLine,cAcao,cCampo)

Local oModel	:= FwModelActive()
Local lRet		:= .T.

If !FwIsInCallStack('GTPI300')
	If cAcao == "UNDELETE" .AND. !Empty(oMdlG55:GetValue("G55_CODGID"))
		If oModel:GetModel("GYNMASTER"):GetValue("GYN_TIPO") == '2'  
			Help(,,'GTPA300',,STR0035,1,0) //"Não é possivel desdeletar o trecho selecionado"                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
			lRet	:= .F.
		EndIf
		
	ElseIf ( cAcao == "CANSETVALUE" )
	
		If ( cCampo $ "G55_DTPART|G55_DTCHEG|G55_HRINI|G55_HRFIM" )
			
			If ( !Empty(oMdlG55:GetValue(cCampo,nLine)) .And. oMdlG55:GetModel():GetModel("GYNMASTER"):GetValue("GYN_TIPO") $"1|3")
				lRet := .f.
			EndIf
			
		EndIf
	
	ElseIf ( cAcao == "SETVALUE" )	
		
		If ( cCampo $ "G55_DTPART|G55_DTCHEG|G55_HRINI|G55_HRFIM" )
			
			If ( !Empty(oMdlG55:GetValue(cCampo,nLine)) )
					
				If ( oMdlG55:GetModel():GetOperation() == MODEL_OPERATION_UPDATE .And.;
						GA300ExistAloc(oMdlG55:GetModel():GetModel("GYNMASTER"):GetValue("GYN_CODIGO")) )
					
					lRet := .f.
					oModel:SetErrorMessage(oMdlG55:GetID(),cCampo,oMdlG55:GetID(),cCampo,"GTPA300PRELIN","Há alocações","Quando se há alocações, seja veículo ou colaborador, não podem ser ajustados os valores de data e hora. Desaloque veículo e/ou colaborador, primeiro.") 
				
				EndIf		
				
			EndIf
			
		EndIf
		
	EndIf
Endif
Return lRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckFreq
Rotina responsavel rotina responsavel para verificar se data de inicio está de acordo com 
a frenquência cadastrada em horario caso contrario não será possivel inserir data .
@param 		oModel - Modelo do submodelo

@sample		CheckFreq()
@return		lRet
@author		Inovação 
@since		17/08/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function CheckFreq(oMdl)
Local lRet		:= .T.
Local cAliasTmp	:= GetNextAlias()
Local cCodGid	:= oMdl:GetValue("GYN_CODGID")
Local dDtIni	:= oMdl:GetValue("GYN_DTINI")
Local lExtra	:= oMdl:GetValue("GYN_EXTRA")
Local cDiaSemana:= "%GID_" + UPPER(SubStr(DIASEMANA(dDtIni),1,3) ) + "%"

If !lExtra .and. !Empty(dDtIni) .and. oMdl:GetValue("GYN_TIPO") $ "1|3"
	BeginSql Alias cAliasTmp
		Select COUNT(GID.GID_COD) AS TOTAL
		From %Table:GID% GID
		Where
			GID.GID_FILIAL = %xFilial:GID%
			AND GID.GID_COD = %Exp:cCodGid%
			AND GID.%Exp:cDiaSemana% = 'T'
			AND GID.GID_HIST = '2'
			AND GID.%NotDel%
	EndSql
	
	If (cAliasTmp)->TOTAL == 0

		If FwIsInCallStack('GI300Receb') .And. GYN->(FieldPos('GYN_SEMFRQ')) > 0
			oMdl:SetValue('GYN_EXTRA', .T.)
			oMdl:SetValue('GYN_SEMFRQ', '1')
		Else		
			lRet	:= .F.
		Endif

	Else
		If GYN->(FieldPos('GYN_SEMFRQ')) > 0
			oMdl:SetValue('GYN_SEMFRQ', '2')
		Endif
	Endif	

	(cAliasTmp)->(DbCloseArea())

EndIf

Return (lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldDataHora

@type function
@author 
@since 10/06/2019
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return lRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldDataHora(oMdl)
Local lRet		:= .T.
Local dDtIni	:= oMdl:GetValue("GYN_DTINI")
Local cHrIni	:= oMdl:GetValue("GYN_HRINI")
Local dDtFim	:= oMdl:GetValue("GYN_DTFIM")
Local cHrFim	:= oMdl:GetValue("GYN_HRFIM")

If !Empty(dDtIni) .and. !Empty(cHrIni) .and. !Empty(dDtFim) .and. !Empty(cHrFim) 
	If DtoS(dDtIni)+cHrIni > DtoS(dDtFim)+cHrFim
		lRet := .F.
	Endif
Endif

Return lRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA3CON
Rotina responsavel por avaliar os conflitos entre Os Horarios X viagens, será trazido em formato de log
todos conflitos encontrado entre eles 

@sample		GTPA3CON()
@return		
@author		Inovação
@since		10/08/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GTPA3CON()
Local lShowErro := .T.
// Chama a tela de pergunta, se cancelar, sai da rotina.
If Pergunte("GTPA300C",.T.)
	GTPX3CON(mv_par01,mv_par02,mv_par03,mv_par04,,lShowErro)
EndIf

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Funcao para chamar o Adapter para integracao via Mensagem Unica 

@sample 	IntegDef( cXML, nTypeTrans, cTypeMessage )
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				'0'- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				'1'- para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				'20' - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				'21' - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				'22' - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				'23' - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
			cVersão - Versão da mensagem
@return  	aRet[1] - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.)
			aRet[2] - String contendo informacoes sobre o processamento
			aRet[3] - String com o nome da mensagem Unica deste cadastro                        
@author  	Jacomo Lisa
@since   	15/02/2017
@version  	P12.1.8
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage,cVersao )
Return GTPI300( cXml, nTypeTrans, cTypeMessage,cVersao )


/*/{Protheus.doc} Gc300TrgGQE
(long_description)
@type function
@author jacom
@since 14/04/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Gc300TrgGQE(oModel)
Local oMdlG55	:= oModel:GetModel('G55DETAIL')
Local oMdlGQE	:= oModel:GetModel('GQEDETAIL')
Local nLine		:= oMdlGQE:GetLine() 
Local lConf		:= .F.
Local lNaoConf	:= .F.
Local lColab	:= .F.
Local lVeic		:= .F.
Local lVldPerf	:= .F.
				
	lConf		:= oMdlGQE:SeekLine({{"GQE_STATUS",'1'}})
	lNaoConf	:= oMdlGQE:SeekLine({{"GQE_STATUS",'2'}})
	lColab		:= oMdlGQE:SeekLine({{"GQE_TRECUR",'1'}})
	lVeic		:= oMdlGQE:SeekLine({{"GQE_TRECUR",'2'}})
	lVldPerf	:= GC300VldPrf(oModel)
	
	If lConf .and. !lNaoConf
		If lColab .and. lVeic .and. lVldPerf
			oMdlG55:SetValue('G55_CONF','1') //Confirmado
		Else
			oMdlG55:SetValue('G55_CONF','3') //Confirmado Parcialment
		Endif
	Elseif lConf .and. lNaoConf
		oMdlG55:SetValue('G55_CONF','3') //Confirmado Parcialment
	Else
		oMdlG55:SetValue('G55_CONF','2') //Não Confirmado
	Endif
	oMdlGQE:GoLine(nLine)
	
Return

/*/{Protheus.doc} Gc300TrgG55
(long_description)
@type function
@author jacom
@since 14/04/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param nTipo, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Gc300TrgG55(oModel,nTipo,xVal)
Local oMdlGYN	:= oModel:GetModel('GYNMASTER')
Local oMdlG55	:= oModel:GetModel('G55DETAIL')
Local oMdlGQE	:= oModel:GetModel('GQEDETAIL')
Local nLine		:= oMdlG55:GetLine() 
Local n1		:= 0
Local lConf		:= .F.
Local lNaoConf	:= .F.
Local lConfParc	:= .T.
Local lVldPerf	:= .F.

	IF nTipo == 1
		For n1	:= 1 to oMdlGQE:Length()
			If !oMdlGQE:IsDeleted(n1)
				oMdlGQE:GoLine(n1)
				oMdlGQE:SetValue('GQE_STATUS',If(xVal=='1',xVal,'2'))
				
			Endif
		Next
		Gc300TrgGQE(oModel)
		
	Endif
	
	lConf		:= oMdlG55:SeekLine({{"G55_CONF",'1'} })
	lNaoConf	:= oMdlG55:SeekLine({{"G55_CONF",'2'},{"G55_CANCEL",'1'}  })
	lConfParc	:= oMdlG55:SeekLine({{"G55_CONF",'3'} })
	lVldPerf	:= GC300VldPrf(oModel)
	
	
	If lConfParc //Confirmado Parcialmente
		oMdlGYN:SetValue('GYN_CONF','3')
	ElseIf lConf .and. !lNaoConf .and. lVldPerf
		oMdlGYN:SetValue('GYN_CONF','1') //Confirmado
	Elseif lConf .and. lNaoConf
		oMdlGYN:SetValue('GYN_CONF','3') //Confirmado Parcialmente
	Else
		oMdlGYN:SetValue('GYN_CONF','2') //Não Confirmado
	Endif
	

oMdlG55:GoLine(nLine)
oMdlGQE:GoLine(1)
Return

/*/{Protheus.doc} GA300ExistAloc
(long_description)
@type function
@author jacomo.fernandes
@since 31/07/2018
@version 1.0
@param cViagem, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA300ExistAloc(cViagem)

Local cNxtAlias	:= GetNextAlias()

Local lRet		:= .f.

BeginSQL Alias cNxtAlias

	SELECT
		1 TEM_ALOC
	FROM
		%Table:GQE% GQE
	WHERE
		GQE_FILIAL = %XFILIAL:GQE%
		AND GQE_VIACOD = %Exp:cViagem%
		AND GQE.%NOTDEL%		

EndSQL

lRet := (cNxtAlias)->TEM_ALOC == 1

(cNxtAlias)->(DbCloseArea())

Return(lRet)


Static Function GcVldLine(oGrid)
Local lRet   		:= .T.
Local nI			:= 0
Local oModel		:= oGrid:GetModel()
Local oMdlGQE		:= oModel:GetModel('GQEDETAIL')
Local cTpColab		:= oMdlGQE:GetValue("GQE_TCOLAB")
Local cTipo         := oMdlGQE:GetValue("GQE_TRECUR")
Local nLinhAtu      := oMdlGQE:GetLine()
Local cLimTip		:= Posicione("GYK",1,XFilial("GYK") + cTpColab, "GYK_LIMTIP")

For nI := 1 To oMdlGQE:Length()
	//Valida colaborador
	If !oMdlGQE:IsDeleted(nI) .AND. cTpColab == oMdlGQE:GetValue("GQE_TCOLAB",nI) ;
		.AND. cTipo == oMdlGQE:GetValue("GQE_TRECUR",nI) .AND. cTipo == '1' .AND. nI != nLinhAtu
		If lRet .And. cLimTip == '1'  //
			oGrid:GetModel():SetErrorMessage(oGrid:GetId(),"CHECKVIA",oGrid:GetId(),"CHECKVIA",'Check',STR0060,STR0061 )//"Permitido apenas um colaborador deste tipo por viagem"#"Selecione outro tipo"				
			lRet	:= .F.
		Endif
		
		If lRet .And. cLimTip == '2' 
			If !(FwAlertYesNo(STR0062 )) // Já existe um colaborador deste tipo na seção selecionada. Deseja continuar ?
				oGrid:GetModel():SetErrorMessage(oGrid:GetId(),"CHECKVIA",oGrid:GetId(),"CHECKVIA",'Check',STR0063	,"" ) // "Seleção cancelada"				
				lRet	:= .F.
			Endif
		Endif
	EndIf
	//Valida veiculo
	If !oMdlGQE:IsDeleted(nI) .AND. cTipo == '2';
		.AND. cTipo == oMdlGQE:GetValue("GQE_TRECUR",nI) .AND. nI != nLinhAtu 
		
		oGrid:GetModel():SetErrorMessage(oGrid:GetId(),"CHECKVIA",oGrid:GetId(),"CHECKVIA",'Check',STR0064,STR0061 )			
		lRet	:= .F.
	EndIf
Next
return lRet



//------------------------------------------------------------------------------
/*/{Protheus.doc} GetKmProvavel

@type function
@author 
@since 10/06/2019
@version 1.0
@param oMdl, Object, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GetKmProvavel(oMdl)
Local cTmpAlias	:= GetNextAlias()
Local cLinha	:= oMdl:GetValue('GYN_LINCOD')
Local cLocOri	:= oMdl:GetValue('GYN_LOCORI')
Local cLocDes	:= oMdl:GetValue('GYN_LOCDES')
Local nKM		:= 0

If !Empty(cLinha) .and. !Empty(cLocOri)  .and. !Empty(cLocDes)
	BeginSQL Alias cTmpAlias
		Select
			GI4_KM
		From %Table:GI4% GI4
		Where
			GI4_FILIAL = %xFilial:GI4%
			AND GI4_LINHA = %Exp:cLinha%
			AND GI4_LOCORI = %Exp:cLocOri%
			AND GI4_LOCDES = %Exp:cLocDes%		
			AND GI4_HIST = '2'
			AND GI4.%NotDel%		
	EndSQL

	nKM := (cTmpAlias)->GI4_KM

	(cTmpAlias)->(DbCloseArea())
Endif

Return nKM

/*/{Protheus.doc} VldStruG56
(long_description)
@type function
@author flavio.martins
@since 30/11/2020
@version 1.0
@param 
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldStruG56()
Local lRet 		:= .T.
Local aFields 	:= {'G56_CODIGO','G56_TPOCOR','G56_VIAGEM','G56_DTVIAG','G56_LOCORI',;
				    'G56_LOCDES','G56_HORA','G56_MEMO','G56_USRPRT','G56_STSOCR'}
Local nX 		:= 0 				  

For nX := 1 To Len(aFields)

	If G56->(FieldPos(aFields[nX])) == 0
		lRet := .F.
		Exit
	Endif

Next
				
Return lRet


/*/{Protheus.doc} GT300DIV
	(long_description)
	@type  Function
	@author user
	@since 23/12/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function GT300DIV()
Local cAliasTmp := GetNextAlias()
Local lRet		:= .F.
Local cDataVig  := DtoS(dDataBase) 

BeginSql Alias cAliasTmp

    SELECT
        GYN_CODIGO,
        GYN_TIPO  ,
        GYN_LINCOD,
        GYN_LINSEN,
        GYN_CODGID,
        GYN_LOCORI,
        GYN_LOCDES,
        GYN_DTINI ,
        GYN_HRINI ,
        GYN_DTFIM ,
        GYN_HRFIM,
        GIE_HORCAB,
        GIE_HORDES,
        CASE
            WHEN GID.GID_HORCAB <> GYN.GYN_HRINI THEN  '1' //'Divergência no hora inicial'
            WHEN GID.GID_HORFIM <> GYN.GYN_HRFIM THEN '2' //'Divergência no hora final'
            WHEN GIE.GIE_SEQ IS NULL THEN     '3' //'Trechos não encontrato nos horarios
            ELSE ''
        END DIVERGENCI
    FROM 
    	%Table:GYN% GYN
    	INNER JOIN %Table:G55% G55 ON G55.G55_FILIAL = GYN.GYN_FILIAL
    	AND G55.G55_CODVIA = GYN.GYN_CODIGO
    	AND G55.%NotDel%
    	INNER JOIN %Table:GID% GID ON GID.GID_FILIAL = G55_FILIAL
    	AND GID.GID_COD = GYN.GYN_CODGID
    	AND GID.GID_HIST = '2'
    	AND GID.%NotDel%
    	LEFT JOIN %Table:GIE% GIE ON GIE.GIE_CODGID = GID.GID_COD
    	AND GIE.GIE_SEQ = G55.G55_SEQ
    	AND GIE.%NotDel%
    WHERE
    	GYN.GYN_FILIAL = %Exp:GYN->GYN_FILIAL%
    	AND %Exp:cDataVig% BETWEEN GYN.GYN_DTINI AND GYN.GYN_DTFIM
    	AND GYN.%NotDel%
		AND GYN.GYN_CODIGO = %Exp:GYN->GYN_CODIGO%
    	AND GYN.GYN_CANCEL = '1'
        AND GYN_FINAL = '2'
    	AND (GYN.GYN_HRINI <> GIE.GIE_HORCAB OR
    		GIE.GIE_SEQ IS NULL OR GID.GID_MSBLQL = '1')

EndSql

If (cAliasTmp)->(!Eof())
    lRet := .T.
Endif

Return lRet
