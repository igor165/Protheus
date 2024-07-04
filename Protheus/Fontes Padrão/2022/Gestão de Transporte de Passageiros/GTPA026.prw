#include "GTPA026.CH"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA026
Digitação POS.

@sample GTPA026
@author Flavio Martins
@since 14/11/2017
/*/
//-------------------------------------------------------------------
Function GTPA026()
Local oBrowse		:= Nil	

Private LLJ070AUTO := .F.

	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()
	// Definição da tabela do Browse
	oBrowse:SetAlias('GQL')
	// Titulo da Browse
	oBrowse:SetDescription(STR0003)//'Digitação de POS'
	// Ativação da Classe
	oBrowse:Activate()
	
Return(oBrowse)

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados para as vendas pos

@return aRotina. Array. Vetor multidimensional contendo as informações de menu do programa.
@sample aRotina := MenuDef()
@author Administrador
@since 14/11/2017
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function ModelDef()
	
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruGQL 	:= FWFormStruct( 1, 'GQL' )
Local oStruGQM 	:= FWFormStruct( 1, 'GQM' )	
Local oModel   	:= Nil 						
// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'GTPA026',,/*bPosVal*/, /*bCommit*/)

oModel:SetVldActivate({|oModel| GA026VldAct(oModel)})

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'GQLMASTER', /*cOwner*/  , oStruGQL   )

// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'GQMDETAIL', 'GQLMASTER', oStruGQM,, { || .T. })

//Calcula o valor total dos itens para validação.
oModel:AddCalc( 'CALVAL', 'GQLMASTER', 'GQMDETAIL' , 'GQM_VALOR', 'CALC_VALOR', 'SUM', { | | .T.},,STR0007)	//'Total'
oModel:SetRelation( 'GQMDETAIL' ,{{'GQM_FILIAL' , 'xFilial("GQM")'},{'GQM_CODGQL' , 'GQL_CODIGO'}},  GQM->(IndexKey( 1 )))
oModel:SetPrimaryKey( { "GQL_CODIGO" } )

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( STR0003 )//'Digitação de POS'

oModel:GetModel( 'GQLMASTER'      ):SetDescription( STR0003 )//'Digitação de POS'
oModel:GetModel( 'GQMDETAIL'      ):SetDescription( STR0010 )//'Digitação de Cartões'

oStruGQL:SetProperty('GQL_CODAGE', MODEL_FIELD_VALID, {|oMdl,cField,cNewValue,cOldValue| ValidUserAg(oMdl,cField,cNewValue,cOldValue) } )
oStruGQL:SetProperty('GQL_CODIGO', MODEL_FIELD_WHEN,{|| .F. } )


// Retorna o Modelo de dados
Return oModel

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@return aRotina. Array. Vetor multidimensional contendo as informações de menu do programa.
@sample aRotina := MenuDef()
@author Administrador
@since 14/11/2017
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function ViewDef()
	
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oModel    := FWLoadModel( 'GTPA026' ) 											// Cria a estrutura a ser usada na View
Local oStruGQL  := FWFormStruct( 2, 'GQL', {|cCpo|	!(AllTrim(cCpo))$ "GQL_CODLAN|" } )
Local oStruGQM  := FWFormStruct( 2, 'GQM', {|cCpo|	(AllTrim(cCpo))$ "GQM_CODNSU|GQM_CODAUT|GQM_DTVEND|GQM_QNTPAR|GQM_VALOR|GQM_ESTAB|" })	
Local oStruCalc := FWCalcStruct( oModel:GetModel('CALVAL') )
Local oView    := Nil

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado na View
oView:SetModel( oModel )

oStruGQL:SetProperty("GQL_CODIGO", MVC_VIEW_ORDEM, '01')
oStruGQL:SetProperty("GQL_CODAGE", MVC_VIEW_ORDEM, '02')
oStruGQL:SetProperty("GQL_DESCAG", MVC_VIEW_ORDEM, '03')
oStruGQL:SetProperty("GQL_TPDDOC", MVC_VIEW_ORDEM, '04')
oStruGQL:SetProperty("GQL_DESDOC", MVC_VIEW_ORDEM, '05')
oStruGQL:SetProperty("GQL_CODADM", MVC_VIEW_ORDEM, '06')
oStruGQL:SetProperty("GQL_DESCAD", MVC_VIEW_ORDEM, '07')
oStruGQL:SetProperty("GQL_TPVEND", MVC_VIEW_ORDEM, '08')
oStruGQL:SetProperty("GQL_DTMOVI", MVC_VIEW_ORDEM, '09')

oStruGQL:SetProperty("GQL_NUMFCH", MVC_VIEW_CANCHANGE, .F.)

// adiciona fields e grid
oView:AddField('VIEW_GQL' , oStruGQL,  'GQLMASTER')
oView:AddGrid('VIEW_GQM'  , oStruGQM,  'GQMDETAIL')
oView:AddField('VIEW_CALC', oStruCalc, 'CALVAL')

// cria telas
oView:CreateHorizontalBox('HEADER', 40)
oView:CreateHorizontalBox('DETAIL', 50)
oView:CreateHorizontalBox('RODAPE', 10)

oView:CreateVerticalBox("CALC1",50, "RODAPE")
oView:CreateVerticalBox("CALC2",50, "RODAPE")
	
// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_GQL' , 'HEADER')
oView:SetOwnerView('VIEW_GQM' , 'DETAIL')
oView:SetOwnerView('VIEW_CALC', 'CALC2')

// Relaciona o ID da View com o "box" para exibicao
oView:EnableTitleView('VIEW_GQL')
oView:EnableTitleView('VIEW_GQM')
oView:EnableTitleView("VIEW_CALC", "Total dos Lançamentos") // "Total dos Lançamentos"

// Retorna o objeto de View criado
Return oView

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu

@return aRotina. Array. Vetor multidimensional contendo as informações de menu do programa.
@sample aRotina := MenuDef()
@author Administrador
@since 14/11/2017
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function MenuDef()
	
Local aRotina := {}

ADD OPTION aRotina Title STR0011	Action 'VIEWDEF.GTPA026' 	OPERATION 2 ACCESS 0	//'Visualizar'
ADD OPTION aRotina Title STR0012   	Action 'VIEWDEF.GTPA026'   	OPERATION 3 ACCESS 0 	//'Incluir'
ADD OPTION aRotina Title STR0013   	Action 'VIEWDEF.GTPA026' 	OPERATION 4 ACCESS 0 	//'Alterar'
ADD OPTION aRotina Title STR0014   	Action 'VIEWDEF.GTPA026'	OPERATION 5 ACCESS 0 	//'Excluir'
	
Return(aRotina)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G026VldAdm()
Efetua a validação do campo GQM_CODNSU no grid.

@params	 Nil
@sample	 lRet := G026VldAdm()
@author	 Bruno Cremaschi -  Inovação
@since	 03/12/2015
@version P12
/*/
//------------------------------------------------------------------------------------------
Function G026VldAdm()

Local cCodNSU	:= ""
Local nI		:= 0
Local nLinPos	:= 0
Local lRet		:= .T.
Local aAreaGQL	:= GQL->(GetArea())
Local aAreaGQM	:= GQM->(GetArea())
Local oModel	:= FwModelActive()
Local oMdl	:= Nil
Local oMdlGQM	:= Nil

If ValType(oModel) == 'O' .And. oModel:GetId() == 'GTPA026'
	oMdl := oModel:GetModel('GQLMASTER')
	oMdlGQM := oModel:GetModel('GQMDETAIL')
	
	//Chama a função para validação da NSU digitada no campo com o banco de dados.
	
	cCodNSU := oMdlGQM:GetValue('GQM_CODNSU')
	nLinPos	:= oMdlGQM:GetLine()
	
	For nI:=1 To oMdlGQM:Length()
		oMdlGQM:GoLine(nI)
		If oMdlGQM:GetValue('GQM_CODNSU') == cCodNSU .And. nI <> nLinPos
			lRet := .F.
			Help(,,"Help", "GT026DADOS", STR0019, 1, 0)//"Código do NSU já digitado para esse administrador de cartões."
			Exit
		Endif
	Next nI
	
	oMdlGQM:GoLine(nLinPos)
EndIf

RestArea(aAreaGQM)
RestArea(aAreaGQL)

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G026VldAut()
Efetua a validação do campo GQM_CODAUT no grid.

@params	 Nil
@sample	 lRet := G026VldAut()
@author	 Bruno Cremaschi -  Inovação
@since	 17/12/2015
@version P12
/*/
//------------------------------------------------------------------------------------------
Function G026VldAut()

Local cCodAtu	:= ""
Local nI		:= 0
Local nLinPos	:= 0
Local lRet		:= .T.
Local aAreaGQL	:= GQL->(GetArea())
Local aAreaGQM	:= GQM->(GetArea())
Local oModel	:= FwModelActive()
Local oMdl	:= Nil
Local oMdlGQM	:= Nil

If ValType(oModel) == 'O' .And. oModel:GetId() == 'GTPA026'
	oMdl := oModel:GetModel('GQLMASTER')
	oMdlGQM := oModel:GetModel('GQMDETAIL')
	
	//Chama a função para validação do código de autorização digitado com o banco de dados.
	lRet := G26VldAtBd(oMdl:GetValue('GQL_CODADM'), oMdlGQM:GetValue('GQM_CODAUT'))
	
	If lRet
		cCodAtu := oMdlGQM:GetValue('GQM_CODAUT')
		nLinPos	:= oMdlGQM:GetLine()
		
		For nI:=1 To oMdlGQM:Length()
			oMdlGQM:GoLine(nI)
			If oMdlGQM:GetValue('GQM_CODAUT') == cCodAtu .And. nI <> nLinPos
				lRet := .F.
				Help(,,"Help", "GT026DADOS", STR0020, 1, 0)//"Código de Autorização já digitado para esse administrador de cartões."
				Exit
			Endif
		Next nI
		
		oMdlGQM:GoLine(nLinPos)
	Else
		Help(,,"Help", "GT026DADOS", STR0020, 1, 0)//"Código de Autorização já digitado para esse administrador de cartões."
	EndIf
EndIf

RestArea(aAreaGQM)
RestArea(aAreaGQL)

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G26VldAtBd()
Efetua a validação do campo GQM_CODAUT no banco de dados.

@params	 cCodAdm, cCodAtu
@sample	 lRet := G26VldAtBd()
@author	 Bruno Cremaschi -  Inovação
@since	 17/12/2015
@version P12
/*/
//------------------------------------------------------------------------------------------
Static Function G26VldAtBd(cCodAdm, cCodAtu)

Local lRet			:= .T.
Local cAliasGQM		:= getNextAlias()

//Verifica se o código de autorização digitado já foi utilizado.
BeginSql Alias cAliasGQM
	SELECT GQM_CODAUT 
	FROM %TABLE:GQM% GQM
	INNER JOIN %TABLE:GQL% GQL ON
		GQL_FILIAL = GQM_FILIAL AND
		GQL_CODIGO = GQM_CODGQL AND
		GQL.%NotDel%
	WHERE
		GQM_FILIAL = %xFilial:GQM% AND
		GQM.%NotDel% AND
		GQM_CODNSU = %Exp:cCodAtu% AND
		GQL_CODADM = %Exp:cCodAdm%
		
EndSql

If !(cAliasGQM)->(EOF())
	lRet := .F.
EndIf

(cAliasGQM)->(dbCloseArea())

return(lRet)

/*/{Protheus.doc} GA026VldAct
Validação da ativação do modelo
@type function
@author flavio.martins
@since 27/02/2020
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA026VldAct(oModel)
Local lRet		:= .T.
Local nOpc		:= oModel:GetOperation()
Local cFicha	:= GQL->GQL_NUMFCH

If !(FwIsInCallStack("GTPA421"))
	If (nOpc ==  MODEL_OPERATION_UPDATE .Or. nOpc ==  MODEL_OPERATION_DELETE ) .And. !Empty(cFicha)  
		lRet := .F.
		oModel:SetErrorMessage(oModel:GetId(), , oModel:GetId(), , "GA026VldAct", STR0035, STR0036) // "Registros já vinculados a ficha de remessa não podem ser alterados ou excluídos", "Exclua a ficha de remessa antes de realizar esta operação"
	Endif
Endif

Return lRet