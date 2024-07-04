#Include "GTPA501.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA501
Função responsavel pela browse das contas correntes
@type Function
@author henrique.toyada
@since 17/06/2020
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Function GTPA501(cAgencia)
Local oBrowse

Default cAgencia := ''

If GTPxVldDic('GQN')
    oBrowse       := FWLoadBrw('GTPA501')

	If cAgencia <> ''
		oBrowse:SetFilterDefault ("GQN_AGENCI = '" + cAgencia + "'")
	Endif

    oBrowse:Activate()
    oBrowse:Destroy()

    GTPDestroy(oBrowse)
Else
    FwAlertHelp(STR0002, STR0001) //"Atenção" //"Dicionário desatualizado."
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Função responsavel pela definição do browse de tipos de Vendas
@type Static Function
@author henrique.toyada
@since 09/07/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return oBrowse, retorna o objeto de browse
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse       := FWMBrowse():New()
If GTPxVldDic('GQN')
	oBrowse:SetAlias('GQN')

	oBrowse:SetMenuDef('GTPA501')

	oBrowse:SetDescription(STR0003) //"Conta corrente da agência"

    oBrowse:AddLegend("!(EMPTY(GQN_FCHDES))"   ,"RED"      ,STR0004) //"Já vinculado"
	oBrowse:AddLegend("EMPTY(GQN_FCHDES)"   ,"GREEN"    ,STR0005) //"Sem vinculo"
Else
    FwAlertHelp(STR0002, STR0001) //"Atenção" //"Dicionário desatualizado."
EndIf

Return oBrowse

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author henrique.toyada
@since 11/02/2020
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.GTPA501' OPERATION OP_VISUALIZAR	ACCESS 0 //"Visualizar"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author henrique.toyada
@since 11/02/2020
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStruGQN  := nil
Local oStruGZ3  := nil
If GTPxVldDic('GQN') .AND. GTPxVldDic('GZ3')
	oStruGQN	:= FWFormStruct(1,'GQN')
	oStruGZ3    := FWFormStruct(1,'GZ3') 

	oModel := MPFormModel():New('GTPA501', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields('GQNMASTER',/*cOwner*/,oStruGQN,/*bPre*/,/*bPos*/,/*bLoad*/)
	oModel:AddGrid("GRIDGZ3"    , "GQNMASTER", oStruGZ3,/*bLinePre*/,/* bLinePost */ ,/*bPreVld*/,/*bPost*/,/*bLoadGIC*/ )
	oModel:SetDescription(STR0003) //"Conta corrente da agência"

	oModel:SetRelation( 'GRIDGZ3', { { 'GZ3_FILIAL', 'xFilial( "GQN" )' }, { 'GZ3_CODIGO', 'GQN_CODIGO' } })

	oModel:GetModel('GQNMASTER'):SetDescription(STR0003) //"Conta corrente da agência"

	oModel:GetModel("GRIDGZ3"):SetMaxLine(9990)

	oModel:GetModel("GRIDGZ3"):SetUniqueLine({"GZ3_SEQITM"})

	oModel:SetPrimaryKey({'GQN_FILIAL','GQN_CODIGO'})

	oModel:GetModel('GRIDGZ3'):SetOptional(.T.)
Else
    FwAlertHelp(STR0002, STR0001) //"Atenção" //"Dicionário desatualizado."
EndIf
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author jacomo.fernandes
@since 11/02/2020
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		
Local oModel	
Local oStruGQN	
Local oStruGZ3	
If GTPxVldDic('GQN') .AND. GTPxVldDic('GZ3')
	oView	 := FWFormView():New()
	oModel	 := FwLoadModel('GTPA501')
	oStruGQN := FWFormStruct(2, 'GQN')
	oStruGZ3 := FWFormStruct(2, 'GZ3')

	oView:SetModel(oModel)

	oView:AddField('VIEW_GQN' ,oStruGQN,'GQNMASTER')
	oView:AddGrid("VIEW_GZ3"  ,oStruGZ3, 'GRIDGZ3') 

	oView:CreateHorizontalBox( "BOX_GQN", 40)
	oView:CreateHorizontalBox( "BOX_GZ3", 60)

	oView:SetOwnerView("VIEW_GQN", "BOX_GQN")
	oView:SetOwnerView("VIEW_GZ3", "BOX_GZ3")

	oView:SetDescription(STR0003) //"Conta corrente da agência"
Else
    FwAlertHelp(STR0002, STR0001)//"Atenção" //"Dicionário desatualizado."
EndIf
Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} GT501GERACONTA
Função para cadastro de conta corrente da agencia
@type Function
@author henrique.toyada
@since 18/06/2020
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GT501GERACONTA(aCab,aItens,cMsgErro)

Local lRet      := .T.
Local nCnt      := 0
Local aErro     := {}
Local oModel    := FwLoadModel("GTPA501")
Local oMdlGQN   := oModel:GetModel("GQNMASTER")
Local oMdlGZ3   := oModel:GetModel("GRIDGZ3")

Default aCab   := {}
Default aItens := {}

If Len(aCab) > 0

	oModel:SetOperation(MODEL_OPERATION_INSERT)

	IF oModel:Activate()

		oMdlGQN:SetValue("GQN_DATA  ",aCab[1]) //data                                 
		oMdlGQN:SetValue("GQN_NUMFCH",aCab[2]) //ficha                                
		oMdlGQN:SetValue("GQN_FCHDES",aCab[3]) //ficha destino                        
		oMdlGQN:SetValue("GQN_TPDIFE",aCab[4]) //tipo diferença (1-receita, 2-despesa)
		oMdlGQN:SetValue("GQN_VLDIFE",aCab[5]) //valor diferença                      
		oMdlGQN:SetValue("GQN_ORIGEM",aCab[6]) //operações que involvem o valor       
		oMdlGQN:SetValue("GQN_ORIGEM",aCab[7]) //Código do caixa
		oMdlGQN:SetValue("GQN_AGENCI",aCab[8]) //Agência referente
		For nCnt := 1 To Len(aItens)
			If (!Empty(FwFldget('GZ3_CODIGO')))   
				A501AddLine(oMdlGZ3)
			EndIf
			oMdlGZ3:SetValue("GZ3_CODIGO",oMdlGQN:GetModel("GQN_CODIGO"))
			oMdlGZ3:SetValue("GZ3_SEQITM",STRZERO(nCnt,3))
			oMdlGZ3:SetValue("GZ3_VALOR" ,aItens[nCnt,1])//Valor do item
			oMdlGZ3:SetValue("GZ3_TPITEM",aItens[nCnt,2])//item representando o valor
		Next nCnt 

		If oModel:VldData()
			oModel:CommitData()
		Else
			lRet := .F.
			aErro := oModel:GetErrorMessage()
            cMsgErro := Alltrim(aErro[6]) + ". " + Alltrim(aErro[7])
		EndIf
	EndIf
	oModel:DeActivate()
EndIf
Return lRet

Static Function A501AddLine(oModel,lBloq)

Local lRet := .F.

Default lBloq := .T.

oModel:SetNoInsertLine(.F.)
lRet := oModel:AddLine()
oModel:SetNoInsertLine(lBloq)

Return lRet
