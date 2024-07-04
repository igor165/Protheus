#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'JURA285.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} JURA285
Rotina responsavel pelo cadastros das rotinas customizadas
@since 18/11/2020
@version 1.0
/*/
//------------------------------------------------------------------------------
Function JURA285()
Local oBrowse       := FWMBrowse():New()

	oBrowse:SetAlias('O14')

	oBrowse:SetMenuDef('JURA285')
	oBrowse:SetDescription(STR0001)//Rotinas customizadas

	oBrowse:Activate()
	oBrowse:Destroy()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author 
@since 18/11/2020
@version 1.0
@return aRotina, retorna as opÃ§Ãµes do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.JURA285' OPERATION OP_VISUALIZAR   ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.JURA285' OPERATION OP_INCLUIR      ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.JURA285' OPERATION OP_ALTERAR      ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.JURA285' OPERATION OP_EXCLUIR      ACCESS 0 // Excluir

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@since 18/11/2020
@version 1.0
@return oModel, retorna o Objeto do modelo
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrO14	:= FWFormStruct(1,'O14')
Local oStrO15	:= FWFormStruct(1,'O15')
Local bPosValid := {|oMdl| ModelPosValid(oMdl)}

	SetModelStruct(oStrO14,oStrO15)

	oModel := MPFormModel():New('JURA285', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields('O14MASTER',/*cOwner*/ ,oStrO14,/*bPre*/,/*bPos*/,/*bLoad*/)
	oModel:AddGrid('O15DETAIL' ,'O14MASTER',oStrO15,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*bLoad*/)

	oModel:SetRelation('O15DETAIL' ,{{ 'O15_FILIAL', 'O14_FILIAL' },{ 'O15_CODIGO', 'O14_CODIGO' }},O15->(IndexKey(1)))

	oModel:GetModel('O15DETAIL'):SetUniqueLine({'O15_CAMPO'})

	oModel:SetDescription(STR0001) //'Rotinas Customizadas'

	oModel:GetModel('O14MASTER'):SetDescription(STR0006)    //'Rotina Customizada'
	oModel:GetModel('O15DETAIL'):SetDescription(STR0007)    //'Campos de Pesquisa'

	oModel:SetPrimaryKey({'O14_FILIAL','O14_CODIGO'})

Return oModel


//------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
Função responsavel pela definição da estrutura do modelo
@since 18/11/2020
@param oStrO14,object, estrutura da tabela O14
@param oStrO15,object, estrutura da tabela O15
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrO14,oStrO15)
Local bFldVld := {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bTrig   := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit   := {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}
Local bWhen   := {|oMdl,cField,uVal| FieldWhen(oMdl,cField,uVal)}

If ValType(oStrO14) == "O"

	oStrO14:SetProperty('O14_CHAVE', MODEL_FIELD_WHEN, bWhen)

	oStrO14:SetProperty('O14_ROTINA', MODEL_FIELD_VALID, bFldVld)

	oStrO14:SetProperty('O14_CHAVE' , MODEL_FIELD_VALID, bFldVld)

	oStrO14:AddTrigger('O14_DISPON', 'O14_DISPON', {||.T.}, bTrig)

Endif

If ValType(oStrO15) == "O"

	oStrO15:AddField(STR0008,STR0008,"O15_DESCRI","C",12)//"Descrição"

	oStrO15:SetProperty('O15_CAMPO', MODEL_FIELD_VALID, bFldVld)

	oStrO15:SetProperty('O15_DESCRI', MODEL_FIELD_INIT, bInit)
	
	oStrO15:SetProperty('O15_DESCRI', MODEL_FIELD_VIRTUAL, .T.)
	
	oStrO15:AddTrigger('O15_CAMPO', 'O15_CAMPO', {||.T.}, bTrig)

Endif

return

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função responsavel pelo gatilho dos campos
@since 18/11/2020
@version 1.0
@param oMdl, object, SubModelo posicionado
@param cField, character, Campo posicionado
@param uVal, character, Valor definido no campo
@return return, uVal
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)

Do Case
	Case cField == "O14_DISPON"
		oMdl:SetValue('O14_CHAVE','')

	Case cField == "O15_CAMPO"
		If !Empty(oMdl:GetValue('O15_CAMPO'))
			oMdl:SetValue('O15_DESCRI',GetSx3Cache(oMdl:GetValue('O15_CAMPO'),'X3_TITULO' ))
		Else
			oMdl:SetValue('O15_DESCRI','')
		Endif
		
EndCase

Return uVal

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid(oMdl,cField,uNewValue,uOldValue)
Função responsavel pela validação dos campos
@since  18/11/2020
@version 1.0
@param oMdl, character, SubModelo posicionado
@param cField, character, Campo posicionado
@param uNewValue, character, novo valor do campo
@param uOldValue, character, valor anterior do campo
@return lRet, retorno booleano, retorna se o campo está valido ou não
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""
Local oMdlAux   := nil

Do Case
	Case Empty(uNewValue)
		lRet := .T.
	Case cField == "O14_ROTINA"
		oMdlAux := FwLoadModel(uNewValue)
		If ValType(oMdlAux) == "U"
			lRet     := .F.
			cMsgErro := STR0009//"Rotina informada invalida."
			cMsgSol  := STR0010//"Selecione uma rotina MVC válida"
		Else 
			oMdlAux:Destroy()
			FwFreeObj(oMdlAux)
			oMdlAux := nil
		Endif

	Case cField == "O15_CAMPO"
		If GetSx3Cache(uNewValue,'X3_CAMPO') <> uNewValue
			lRet		:= .F.
			cMsgErro	:= STR0011//"Campo selecionado não encontrado."
			cMsgSol		:= STR0012//"Selecione um campo valido."
		Endif

EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Função responsavel pela inicialização dos campos
@since 08/07/2019
@version 1.0
@param oMdl, character, Submodelo posicionado
@param cField, character, Campo posicionado
@param uVal, character, valor do campo
@param nLine, character, numero da linha posicionada
@param uOldValue, character, valor anteorior
@return uRet, Retorna conforme o campo selecionado
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Local uRet      := uVal
Local lInsert   := oMdl:GetOperation() == MODEL_OPERATION_INSERT

Do Case 
	Case cField == "O15_DESCRI" 
		uRet := If(!lInsert .and. !Empty(O15->O15_CAMPO),GetSx3Cache(O15->O15_CAMPO,'X3_TITULO') ,'')
EndCase

Return uRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldWhen(oMdl,cField,uVal)
Função responsavel pela inicialização dos campos
@since 08/07/2019
@version 1.0
@param oMdl, character, SubModelo posicionado
@param cField, character, campo posicionado
@param uVal, character, valor do campo
@return lRet, retorna se pode ou não alterar
/*/
//------------------------------------------------------------------------------
Static Function FieldWhen(oMdl,cField,uVal)
Local lRet := .T.
Local lTrigger := FwIsInCallStack('FIELDTRIGGER')
Do Case
	Case lTrigger
		lRet := .T.
	Case cField == "O14_CHAVE"
		lRet := oMdl:GetValue('O14_DISPON') > '1' // Ativa o campo somente quando diferente de Cadastro básico
EndCase

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosValid
Função responsavel pela validação do modelo completa
@since 19/11/2020
@param oModel, object, (Descrição do parâmetro)
@return lRet, Retorno lógico
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelPosValid(oModel)
Local lRet        := .T.
Local oMdlO14     := oModel:GetModel('O14MASTER')
Local oMdlPesq    := oModel:GetModel('O15DETAIL')
Local oJsonStruct := JGetStrMdl(oMdlO14:GetValue('O14_ROTINA'))
Local aMainStruct := nil
Local nPos        := 0
Local cMdlId      := oModel:GetId()
Local cMsgErro    := ""
Local cMsgSol     := ""

If oMdlO14:GetValue('O14_DISPON') > '1' .and. Empty(oMdlO14:GetValue('O14_CHAVE'))
	lRet     := .F.
	cMsgErro := STR0013//"O campo chave de relacionamento não foi informado"
	cMsgSol  := STR0014//"Quando o cadastro for disponivel em processso, é obrigatório informar o campo chave"

ElseIf ValType(oJsonStruct) == "J"

	If (nPos := aScan(oJsonStruct['struct'],{|x| 'MASTER' $ x['id']})) > 0
		aMainStruct := oJsonStruct['struct'][nPos]['fields']

		If !Empty(oMdlO14:GetValue('O14_CHAVE')) ;
			.and. !VldChave(aMainStruct,Separa(oMdlO14:GetValue('O14_CHAVE'),'+'),@cMsgErro)
			lRet := .F.
		ElseIf !VldO15Fields(oMdlPesq,aMainStruct,@cMsgErro)
			lRet := .F.
		Endif

	Else 
		lRet     := .F.
		cMsgErro := STR0015//"Não foi possivel encontrar a estrutura da rotina"
		cMsgSol  := STR0016//"Informe uma rotina válida ou avalie a estrutura da rotina"
	Endif

Endif

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,'',cMdlId,'',"ModelPosValid",cMsgErro,cMsgSol)
Endif

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckFldStruct
Função responsavel pela validação dos campos
@since 19/11/2020
@param aStruct, array, Estrutura de campos da rotina
@param aFields, array, Campos a serem validados
@param cMsgErro, string, Passado por referencia para retorno da mensagem de erro
@return lRet, Retorno lógico
/*/
//------------------------------------------------------------------------------
Static Function VldChave(aStruct,aFields,cMsgErro)
Local lRet   := .T.
Local cField := ""
Local n1     := 0

	For n1 := 1 To Len(aFields)
		cField := aFields[n1]
		
		If Empty(cField)
			Loop
		Endif
		
		If !CheckFldStruct(aStruct,cField,@cMsgErro)
			lRet := .F.
			exit
		Endif

	Next

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckFldStruct
Função responsavel pela validação dos campos
@since 19/11/2020
@param aStruct, array, Estrutura de campos da rotina
@param cField, string, Campo a ser validado
@param cMsgErro, string, Passado por referencia para retorno da mensagem de erro
@return lRet, Retorno lógico
/*/
//------------------------------------------------------------------------------
Static Function CheckFldStruct(aStruct,cField,cMsgErro)
Local lRet := .T.
	
	cField := AllTrim(cField)

	If aScan(aStruct,{|x| AllTrim(x['field']) == cField}) == 0
		lRet     := .F.
		cMsgErro := I18N(STR0017,{cField})//"O campo #1 não foi encontrado na estrutura do modelo selecionado"
	Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosValid
Função responsavel pela validação do modelo completa
@since 19/11/2020
@param oMdlO15, object, submodelo da o15
@param aMainStruct, object, estrutura de campos da rotina
@param cMsgErro, object, string passada por referencia p
@return lRet, Retorno lógico
/*/
//------------------------------------------------------------------------------
Static Function VldO15Fields(oMdlO15,aMainStruct,cMsgErro)
Local lRet := .T.
Local n1   := 0

	For n1 := 1 To oMdlO15:Length()
		If !oMdlO15:IsDeleted(n1)
			If !CheckFldStruct(aMainStruct,oMdlO15:GetValue('O15_CAMPO',n1),@cMsgErro)
				lRet := .F.
				exit
			Endif
		Endif
	Next

Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author 
@since 18/11/2020
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('JURA285')
Local oStrO14	:= FWFormStruct(2, 'O14')
Local oStrO15	:= FWFormStruct(2, 'O15')

SetViewStruct(oStrO14,oStrO15)

oView:SetModel(oModel)

oView:AddField('VIEW_O14',oStrO14,'O14MASTER')
oView:AddGrid('VIEW_O15' ,oStrO15,'O15DETAIL')

oView:CreateHorizontalBox('BOX_O14', 50 )
oView:CreateHorizontalBox('BOX_O15', 50 )

oView:SetOwnerView('VIEW_O14' ,'BOX_O14' )
oView:SetOwnerView('VIEW_O15' ,'BOX_O15' )

oView:SetFieldAction('O14_DISPON', {|oView| oView:Refresh()} )

oView:SetDescription(STR0001) //'Rotinas Customizadas'

Return oView


//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
Função responsavel pela estrutura de dados da view
@since 26/11/2020
@version 1.0
@param oStrO14, object, estrutura de campos da tabela O14
@param oStrO15, object, estrutura de campos da tabela O15
@return nil, retorno nulo
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrO14,oStrO15)

If ValType(oStrO15) == "O"
	oStrO15:AddField("O15_DESCRI","04",STR0008,STR0008,{},"C","",Nil,Nil,.F.,"",Nil,Nil,Nil,Nil,.T.,Nil)
Endif

Return nil
