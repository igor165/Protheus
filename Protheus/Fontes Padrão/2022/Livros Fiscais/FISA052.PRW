#Include "Protheus.ch"
#Include "FwMBrowse.ch"
#Include "FwMvcDef.ch"
#Include "FisA052.ch"

#Define C_CABEC "CE1_FILIAL|CE1_ESTISS|CE1_CMUISS|CE1_MUNISS|CE1_RETISS|CE1_FORISS|CE1_LOJISS"

/*/{Protheus.doc} FISA052
Cadastro de Aliquotas para o ISS

@author Vitor Felipe
@since 28/08/2012

@obs Função refeita. - Vitor Ribeiro (vitor.e@totvs.com.br) - 15/09/2017
/*/

Function FISA052()

	Local oBrowse := nil
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("CE1")
	oBrowse:SetDescription(STR0001)	// Validade das aliquotas
	oBrowse:Activate()
	
Return

/*/{Protheus.doc} MenuDef
Definicao do MenuDef para o MVC

@author Vitor Felipe
@since 28/08/2012

@return array, contém os botões do menu
/*/

Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.FISA052' OPERATION 2 ACCESS 0	// "Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA052' OPERATION 3 ACCESS 0	// "Incluir"
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA052' OPERATION 4 ACCESS 0	// "Alterar"
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA052' OPERATION 5 ACCESS 0	// "Excluir"
		
Return aRotina

/*/{Protheus.doc} ModelDef
Definicao do ModelDef para o MVC

@author Vitor Felipe
@since 28/08/2012

@return objeto, retorna o modelo difinido.
/*/

Static Function ModelDef()

	Local oModel := nil
	Local oStructCab := FWFormStruct(1,"CE1",{|cCampo| COMP11STRU("CAB",cCampo)})
	Local oStructIte := FWFormStruct(1,"CE1",{|cCampo| COMP11STRU("ITE",cCampo)})
	
	Local bLinePre := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| bLinePre(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
	
	oModel := MPFormModel():New("FISA052",,{|oModel|ValidForm(oModel)})
	
	oModel:AddFields("FISA052MOD",,oStructCab)
    
	oModel:AddGrid("FISA052ITE","FISA052MOD",oStructIte,bLinePre)
	
	oModel:GetModel("FISA052ITE"):SetUseOldGrid()
	
	oModel:SetRelation("FISA052ITE",RelatCE1(),CE1->(IndexKey(1)))
	
	oModel:SetPrimaryKey({"CE1_FILIAL"},{"CE1_CODISS"},{"CE1_ESTISS"},{"CE1_CMUISS"},{"CE1_PROISS"})
	
	oModel:SetDescription(STR0001) // "Alíquotas do ISS"
	
	oModel:GetModel("FISA052MOD"):SetDescription(STR0009) // "Cadastro do Município"
	
	oModel:GetModel("FISA052ITE"):SetDescription(STR0010) // "Itens Município"
	
	oModel:GetModel("FISA052ITE"):SetMaxLine(9999) // Maximo de linhas
	
	oModel:GetModel("FISA052ITE"):SetUniqueLine({"CE1_CODISS","CE1_PROISS"}) // Removido obrigatoriedade de preencher produto
	
Return oModel

/*/{Protheus.doc} ViewDef
Definicao da Visualizacao para o MVC

@author Vitor Felipe
@since 28/08/2012

@return objeto, retorna o view definido.
/*/

Static Function ViewDef()
	
	Local oView := FWFormView():New()
	Local oModel := FWLoadModel("FISA052")
	Local oStructCab := FWFormStruct(2,"CE1",{|cCampo| COMP11STRU("CAB",cCampo)})
	Local oStructIte := FWFormStruct(2,"CE1",{|cCampo| COMP11STRU("ITE",cCampo)})
    
	oView:SetModel(oModel)
    
	oView:AddField("VIEW_CAB",oStructCab,"FISA052MOD")
	
	oView:AddGrid("VIEW_ITE",oStructIte,"FISA052ITE")
			
	oView:CreateHorizontalBox("SUPERIOR",20)
	
	oView:CreateHorizontalBox("INFERIOR",80)

	oView:SetOwnerView("VIEW_CAB","SUPERIOR")
	
	oView:SetOwnerView("VIEW_ITE","INFERIOR")
	
Return oView

/*/{Protheus.doc} COMP11STRU
Função de controle dos campos de cabeçalho e itens

@author Vitor Felipe
@since 28/08/2012

@param cTipo, caracter, contem o tipo se é cabeçalho ou item
@param cCampo, caracter, contem o campo da tabela

@return logico, se o campo referencia deve ser usado ou não.
/*/

Static Function COMP11STRU(cTipo,cCampo)

	Local lRet := .T.
	
	Default cTipo := ""
	Default cCampo := ""
	
	If cTipo == "CAB"		// Se for a construcao do cabecalho
		// Se o campo não estiver informado nos campos do cabeçalho retorna falso
		lRet := IIf(!(AllTrim(cCampo) $ C_CABEC),.F.,.T.)
	ElseIf cTipo == "ITE"	// Se for a construcao do item
		// Se o campos estiver informado nos campos do cabeçalho retorna falso
		lRet := IIf((AllTrim(cCampo) $ C_CABEC),.F.,.T.)
	EndIf

Return lRet

/*/{Protheus.doc} ValidForm
Validação das informações digitadas no form

@author Vitor Felipe
@since 28/08/2012

@param oModel, objeto, contem o model

@return logico, se foi validado ou não.  
/*/

Static Function ValidForm(oModel)
	
	Local aAreaCE1 := CE1->(GetArea())
	
	Local lRet := .T.
	
	Local nOperation := oModel:GetOperation()
	
	Local cCodISS := oModel:GetValue("FISA052ITE","CE1_CODISS")
	Local cEstISS := oModel:GetValue("FISA052MOD","CE1_ESTISS")
	Local cCMuISS := oModel:GetValue("FISA052MOD","CE1_CMUISS")
	Local cCProd := oModel:GetValue("FISA052ITE","CE1_PROISS")	
	
	// Inclusão de informações.
	If nOperation == 3
		// Valores de exclusão de PIS e Cofins para sociedade cooperativa.
		DbSelectArea ("CE1")
		CE1->(DbSetOrder (1))
		If CE1->(DbSeek(FWxFilial("CE1")+cCodISS+cEstISS+cCMuISS+cCProd))
			lRet := .F.
			Help("",1,STR0006,STR0006,STR0007,1,0) //"Codigo do ISS, Estado,Codigo de Municipio e Produto já cadastrados!"
		EndIf
	EndIf
	
	RestArea(aAreaCE1)
	
Return lRet

/*/{Protheus.doc} bLinePre
Atribuição de valores do grid

@author João Paulo
@since 16/04/2014

@return logico, contém o tipo se é cabeçalho ou item
/*/

Static Function bLinePre(oModel,oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)

	Local lret := .T. // retorno obrigatório da função
	Local nOperation := oModel:GetOperation() // retorna número da linha da grade
		
	Static pCodISS := ""
	Static pProISS := ""
	Static nNmrLin := 0			
	
	If nOperation == 4
		pCodISS := oModel:GetValue("CE1_CODISS")
		pProISS := oModel:GetValue("CE1_PROISS")
		nNmrLin := oGridModel
	EndIF

Return lret

/*/{Protheus.doc} RelatCE1
Função para retornar o relacionamento da tabela CE1

@author Vitor Ribeiro - vitor.e@totvs.com.br
@since 15/09/2017

@return array, contem o relacionamento da tabela CE1
/*/

Static Function RelatCE1()

	Local aRelaCE1 := {}
	
	Aadd(aRelaCE1,{"CE1_FILIAL","FWxFilial('CE1')"})
	Aadd(aRelaCE1,{"CE1_ESTISS","CE1_ESTISS"})
	Aadd(aRelaCE1,{"CE1_CMUISS","CE1_CMUISS"})
	Aadd(aRelaCE1,{"CE1_MUNISS","CE1_MUNISS"})
	Aadd(aRelaCE1,{"CE1_RETISS","CE1_RETISS"})
	Aadd(aRelaCE1,{"CE1_FORISS","CE1_FORISS"})
	Aadd(aRelaCE1,{"CE1_LOJISS","CE1_LOJISS"})
	
Return aRelaCE1