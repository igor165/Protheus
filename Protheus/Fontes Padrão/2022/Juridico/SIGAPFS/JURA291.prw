#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA291.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA291
Cadastro de Rotinas Customizadas

@author willian.kazahaya
@since 27/04/2021
/*/
//-------------------------------------------------------------------
Function JURA291()
Local oBrowse := Nil

	JCargaOHZ()

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0001) //"Cadastro de Rotinas Customizaveis"
	oBrowse:SetAlias("OHX")
	oBrowse:SetLocate()
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author willian.kazahaya
@since 27/04/2021
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } )  //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA291", 0, 2, 0, NIL } )  //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA291", 0, 3, 0, NIL } )  //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA291", 0, 4, 0, NIL } )  //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA291", 0, 5, 0, NIL } )  //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados do Cadastro de Rotinas Customizadas

@author willian.kazahaya
@since 27/04/2021
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel("JURA291")
Local oStructOHX := FWFormStruct(2, "OHX")
Local oStructOHY := FWFormStruct(2, "OHY")
Local oView      := Nil
	
	oStructOHY:RemoveField("OHY_CODROT")
	SetViewStruct(oStructOHX,oStructOHY)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:SetDescription(STR0001) //"Cadastro de Rotinas Customizaveis"

	oView:AddField("JURA291_OHX", oStructOHX, "OHXMASTER")
	oView:AddGrid("JURA291_OHY", oStructOHY, "OHYDETAIL")

	oView:CreateHorizontalBox( "FORMOHX", 30,,,, )
	oView:CreateHorizontalBox( "FORMOHY", 70,,,, )

	oView:SetOwnerView( "OHXMASTER", "FORMOHX" )
	oView:SetOwnerView( "OHYDETAIL", "FORMOHY" )
	
	oView:SetUseCursor( .T. )
	oView:EnableControlBar( .T. )
	oView:EnableTitleView("OHYDETAIL")
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados do Cadastro de Rotinas Customizadas

@author willian.kazahaya
@since 27/04/2021
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := Nil
Local oStructOHX := FWFormStruct(1, "OHX")
Local oStructOHY := FWFormStruct(1, "OHY")

	JCargaOHZ()
	SetModelStruct(oStructOHX, oStructOHY)

	oModel:= MPFormModel():New("JURA291", /*Pre-Validacao*/, {|oModel| J291TOk(oModel)}/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	oModel:AddFields("OHXMASTER", Nil, oStructOHX, /*Pre-Validacao*/, /*Pos-Validacao*/)
	oModel:GetModel("OHXMASTER"):SetDescription(STR0001) // "Cadastro de Rotinas Customizaveis"
	
	oModel:AddGrid('OHYDETAIL', 'OHXMASTER' /*cOwner*/, oStructOHY, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/)
	oModel:GetModel("OHYDETAIL"):SetDescription(STR0007) // "Campos de filtro da Rotina Customizavel"
	
	oModel:SetRelation('OHYDETAIL', {{'OHY_FILIAL', "xFilial('OHY')"}, {'OHY_CODROT', 'OHX_CODIGO'}}, OHY->(IndexKey(1)))
	
	JurSetRules( oModel, "OHXMASTER",, "OHX",, )
	JurSetRules( oModel, "OHYDETAIL",, "OHY",, )
	oModel:SetOptional("OHYDETAIL", .T.)
	
	oModel:SetPrimaryKey({"OHX_FILIAL", "OHX_CODIGO"})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
Função responsavel pela estrutura de dados da view

@param oStructOHX - Estrutura de campos da tabela OHX,
@param oStructOHY - Estrutura de campos da tabela OHY
@return nil, retorno nulo

@author willian.kazahaya
@since 27/04/2021
/*/
//-------------------------------------------------------------------
Static Function SetViewStruct(oStructOHX, oStructOHY)
	If ValType(oStructOHY) == "O"
		oStructOHY:AddField("OHY_DESCRI","04",STR0008,STR0008,{},"C","",Nil,Nil,.F.,"",Nil,Nil,Nil,Nil,.T.,Nil) //"Descrição"
	Endif
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
Função responsavel pela definição da estrutura do modelo

@param oStructOHX - Estrutura da tabela OHX
@param oStructOHY - Estrutura da tabela OHY

@author willian.kazahaya
@since 27/04/2021
/*/
//-------------------------------------------------------------------
Static Function SetModelStruct(oStructOHX, oStructOHY)
Local bTrig   := {|oMdl,cField,uVal| J291FldTrg(oMdl,cField,uVal)}
Local bInit   := {|oMdl,cField,uVal,nLine,uOldValue| J291FldIni(oMdl,cField,uVal,nLine,uOldValue)}

	If ValType(oStructOHY) == "O"
		oStructOHY:AddField(STR0008,STR0008,"OHY_DESCRI","C",12)//"Descrição"
		oStructOHY:SetProperty('OHY_DESCRI', MODEL_FIELD_INIT, bInit)
		oStructOHY:SetProperty('OHY_DESCRI', MODEL_FIELD_VIRTUAL, .T.)
		oStructOHY:AddTrigger('OHY_CAMPO', 'OHY_CAMPO', {||.T.}, bTrig) 
	Endif
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} J291FldVld()
Função responsavel pela validação dos campos
@return lRet, retorno booleano, retorna se o campo está valido ou não

@author willian.kazahaya
@since 27/04/2021

/*/
//-----------------------------------------------------------------------
Function J291FldVld()
Local lRet		:= .T.
Local cCampo    := StrTran(ReadVar(), "M->", "")
Local oMdl      := FWModelActive()
Local oModel	:= oMdl:GetModel()
Local cMsgErro	:= ""
Local cMsgSol	:= ""
Local cValueAtu := ""
Local oMdlAux   := Nil

	Do Case
		Case cCampo == "OHX_ROTINA"
			cValueAtu := oModel:GetValue("OHXMASTER",cCampo)

			oMdlAux := FwLoadModel(cValueAtu)
			If ValType(oMdlAux) == "U"
				cMsgErro := STR0009 //"Rotina informada invalida."
				cMsgSol  := STR0010 //"Selecione uma rotina MVC válida"
			Else 
				oMdlAux:Destroy()
				FwFreeObj(oMdlAux)
				oMdlAux := nil
			Endif
		Case cCampo == "OHY_CAMPO"
			cValueAtu := oModel:GetValue("OHYDETAIL", "OHY_CAMPO")
			If GetSx3Cache(cValueAtu,'X3_CAMPO') <> cValueAtu
				cMsgErro	:= STR0011 //"Campo selecionado não encontrado."
				cMsgSol		:= STR0012 //"Selecione um campo valido."
			Endif
		Otherwise
			lRet := .T.
	EndCase

	If !Empty(cMsgErro)
		lRet := JurMsgErro(cMsgErro, cMsgSol)
	Endif

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} J291FldIni(oMdl,cField,uVal,nLine,uOldValue)
Função responsavel pela inicialização dos campos

@param oMdl      - Submodelo posicionado
@param cField    - Campo posicionado
@param uVal      - valor do campo
@param nLine     - numero da linha posicionada
@param uOldValue - valor anteorior
@return uRet, Retorna conforme o campo selecionado

@author willian.kazahaya
@since 27/04/2021
/*/
//-----------------------------------------------------------------------
Function J291FldIni(oMdl,cField,uVal,nLine,uOldValue)
Local uRet      := uVal
Local lInsert   := oMdl:GetOperation() == MODEL_OPERATION_INSERT

	Do Case 
		Case cField == "OHY_DESCRI" 
			uRet := If(!lInsert .and. !Empty(OHY->OHY_CAMPO),GetSx3Cache(OHY->OHY_CAMPO,'X3_TITULO') ,'')
	EndCase

Return uRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} J291FldTrg(oMdl,cField,uVal)
Função responsavel pelo gatilho dos campos

@param oMdl, object, SubModelo posicionado
@param cField -  Campo posicionado
@param uVal -  Valor definido no campo
@return return, uVal

@author willian.kazahaya
@since 27/04/2021
/*/
//-----------------------------------------------------------------------
Function J291FldTrg(oMdl,cField,uVal)
	Do Case
		Case cField == "OHY_CAMPO"
			If !Empty(oMdl:GetValue('OHY_CAMPO'))
				oMdl:SetValue('OHY_DESCRI',GetSx3Cache(oMdl:GetValue('OHY_CAMPO'),'X3_TITULO' ))
			Else
				oMdl:SetValue('OHY_DESCRI','')
			Endif
	EndCase
Return uVal

//-------------------------------------------------------------------
/*/{Protheus.doc} J291TOk(oModel)
Validação do Modelo

@param oModel - Modelo atual

@author willian.kazahaya
@since 27/04/2021
/*/
//-------------------------------------------------------------------
Static Function J291TOk(oModel)
Local lRet        := .T.
Local cMsgErro    := ""
Local nOpc        := oModel:GetOperation()
Local oModelOHX	  := oModel:GetModel("OHXMASTER")
Local oModelOHY   := oModel:GetModel("OHYDETAIL")
Local oJsonStruct := JW77StrMdl(oModelOHX:GetValue('OHX_ROTINA'))
Local aMainStruct := nil

	If nOpc < 5
		If oModelOHX:GetValue("OHX_TIPCAD") == "2"
			If Empty(oModelOHX:GetValue("OHX_TELROT"))
				lRet := JurMsgErro(I18N(STR0013, {GetSx3Cache("OHX_TELROT", "X3_TITULO")})) //"O campo '#1' precisa ser preenchido quando o Tipo de Cadastro for 2-Rotinas."
			EndIf
			If Empty(oModelOHX:GetValue("OHX_CHAVE"))
				lRet := JurMsgErro(I18N(STR0013, {GetSx3Cache("OHX_CHAVE", "X3_TITULO")})) // "O campo '#1' precisa ser preenchido quando o Tipo de Cadastro for 2-Rotinas."
			EndIf
		EndIf

		If ValType(oJsonStruct) == "J"
			
			If (nPos := aScan(oJsonStruct['struct'],{|x| 'MASTER' $ x['id']})) > 0
				aMainStruct := oJsonStruct['struct'][nPos]['fields']
				If !Empty(oModelOHX:GetValue('OHX_CHAVE')) ;
					.And. !J291OHXChv(aMainStruct,Separa(oModelOHX:GetValue('OHX_CHAVE'),'+'),@cMsgErro)
					lRet := JurMsgErro(cMsgErro) // "O campo #1 não foi encontrado na estrutura do modelo selecionado"
				ElseIf !J291OHYCmp(oModelOHY,aMainStruct,@cMsgErro)
					lRet := JurMsgErro(cMsgErro) // "O campo #1 não foi encontrado na estrutura do modelo selecionado"
				Endif

			Else 
				lRet     := JurMsgErro(STR0014) //"Não foi possivel encontrar a estrutura da rotina"
			Endif
		Endif
	Endif
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} J291OHYCmp
Função responsavel pela validação do modelo completa

@param oMdlOHY, object, submodelo da o15
@param aMainStruct, object, estrutura de campos da rotina
@param cMsgErro, object, string passada por referencia p
@return lRet, Retorno lógico

@author Willian.Kazahaya
@since 25/05/2021
/*/
//------------------------------------------------------------------------------
Static Function J291OHYCmp(oMdlOHY,aMainStruct,cMsgErro)
Local lRet := .T.
Local n1   := 0
	If (!oMdlOHY:IsEmpty())
		For n1 := 1 To oMdlOHY:Length()
			If !oMdlOHY:IsDeleted(n1)
				If !J291CkFlSt(aMainStruct,oMdlOHY:GetValue('OHY_CAMPO',n1),@cMsgErro)
					lRet := .F.
					exit
				Endif
			Endif
		Next
	EndIf
Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} J291OHXChv
Função que valida a Chave da Rotina

@param aStruct  - Estrutura de campos da rotina
@param aFields  - Campos a serem validados
@param cMsgErro - Passado por referencia para retorno da mensagem de erro
@return lRet    - Retorno lógico

@author Willian.Kazahaya
@since 25/05/2021
/*/
//------------------------------------------------------------------------------
Static Function J291OHXChv(aStruct,aFields,cMsgErro)
Local lRet   := .T.
Local cField := ""
Local n1     := 0

	For n1 := 1 To Len(aFields)
		cField := aFields[n1]
		
		If Empty(cField)
			Loop
		Endif
		
		If !J291CkFlSt(aStruct,cField,@cMsgErro)
			lRet := .F.
			exit
		Endif

	Next

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} J291CkFlSt
Função responsavel pela validação dos campos

@param  aStruct  - Estrutura de campos da rotina
@param  cField   - Campo a ser validado
@param  cMsgErro - Passado por referencia para retorno da mensagem de erro
@return lRet     - Retorna se o campo foi encontrado

@author Willian.Kazahaya
@since 25/05/2021
/*/
//------------------------------------------------------------------------------
Static Function J291CkFlSt(aStruct,cField,cMsgErro)
Local lRet := .T.
	
	cField := AllTrim(cField)

	If aScan(aStruct,{|x| AllTrim(x['field']) == cField}) == 0
		lRet     := .F.
		cMsgErro := I18N(STR0015,{cField}) // "O campo #1 não foi encontrado na estrutura do modelo selecionado"
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J291WTipCad
Habilita os campos somente quando o Tipo de Cadastro for igual
a 2- Rotinas

@author willian.kazahaya
@since 27/04/2021
/*/
//-------------------------------------------------------------------
Function J291WTipCad()
Local lRet := .T.
	lRet := M->OHX_TIPCAD == '2'
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J291ConOHZ
Modelo de Dados do Cadastro de Rotinas Customizadas

@author willian.kazahaya
@since 27/04/2021
/*/
//-------------------------------------------------------------------
Function J291ConOHZ()
Local cQuery     := ""
Local lRet       := .F.
Local nResult    := 0
Local aPesq      := {"OHZ_CODIGO","OHZ_NOME"}

	cQuery += " SELECT OHZ_CODIGO, OHZ_NOME, OHZ.R_E_C_N_O_ OHZRECNO "
	cQuery += " FROM "+RetSqlName("OHZ")+" OHZ"
	cQuery += " WHERE OHZ_FILIAL = '"+xFilial("OHZ")+"'"
	cQuery += " AND OHZ.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery, .F.)

	nResult := JurF3SXB("OHZ", aPesq,, .F., .F.,, cQuery)
	lRet := nResult > 0

	If lRet
		DbSelectArea("OHZ")
		OHZ->(dbgoTo(nResult))
	EndIf
Return lRet

