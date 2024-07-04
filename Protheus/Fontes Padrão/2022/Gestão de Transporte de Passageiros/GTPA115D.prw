#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

Static __RecGIC := 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Fun��o responsavel pela defini��o do modelo para cancelamento
@type Static Function
@author jacomo.fernandes
@since 20/02/2020
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := FwLoadModel('GTPA115')
Local oStruGIC  := oModel:GetModel('GICMASTER'):GetStruct()
Local bVldActiv := {|oModel| VldActivate(oModel) }
Local bMdlActiv := {|oModel| MdlActivate(oModel) }

SetModelStruct(oStruGIC)

oModel:SetVldActivate( bVldActiv )
oModel:SetActivate( bMdlActiv )

Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetModelStruct

@type Static Function
@author jacomo.fernandes
@since 20/02/2020
@version 1.0
@param oStruGIC, object, (Descri��o do par�metro)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStruGIC)

If ValType(oStruGIC) == "O"

    oStruGIC:SetProperty('*'            ,MODEL_FIELD_WHEN,{||.T.})

    oStruGIC:SetProperty('*'            ,MODEL_FIELD_OBRIGAT,.F.)
    oStruGIC:SetProperty('GIC_MOTCAN'   ,MODEL_FIELD_OBRIGAT,.T.)
    oStruGIC:SetProperty('GIC_DTVEND'   ,MODEL_FIELD_OBRIGAT,.T.)
    
    oStruGIC:SetProperty('GIC_STATUS'   ,MODEL_FIELD_INIT,{||"D"})

Endif

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldActivate
Fun��o Respons�vel para valida��o do modelo de dados
@type function
@author jacomo.fernandes
@since 04/09/2018
@version 1.0
@param oModel, objeto, (Descri��o do par�metro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldActivate(oModel)
Local lRet      := .T.
Local cMdlId    := oModel:GetId()
Local cMsgErro  := ""
Local cMsgSol   := ""

__RecGIC := GIC->(Recno())

If GIC->GIC_STATUS <> 'C' .and. GIC->GIC_STATUS <> 'D' // Bilhetes diferente de cancelado e devolvido  

	If GIC->GIC_ORIGEM == '2' .and. !(GIC->GIC_ORIGEM == '2' .and. GIC->GIC_TIPO == 'E' ) 
		lRet        := .F.
        cMsgErro    := "N�o � possivel cancelar ou devolver uma passagem de origem eletr�nica."	
	Endif
	
	If lRet .and. !VldBilRef(GIC->GIC_CODIGO)
        lRet := .F.
        cMsgErro    := "N�o � possivel cancelar ou devolver esse bilhete pois o mesmo ja se encontra cancelado/devolvido"
	Endif
Else
    lRet        := .F.
    cMsgErro    := "N�o � possivel cancelar ou devolver esse bilhete pois o mesmo ja � um bilhete cancelado/devolvido"
Endif

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,,cMdlId,,"VldActivate",cMsgErro,cMsgSol)
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} VldBilRef
Fun��o responsavel pela valida��o do bilhete de Referencia
@type Static Function
@author jacomo.fernandes
@since 20/02/2020
@version 1.0
@param cCodGIC, character, (Descri��o do par�metro)
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function VldBilRef(cCodGIC)
Local lRet      := .T.
Local cTmpAlias := GetNextAlias()

BeginSql Alias cTmpAlias
    Select
        Count(R_E_C_N_O_) AS TOTBILREF
    FROM %Table:GIC% GIC
    WHERE
        GIC.GIC_FILIAL = %xFilial:GIC%
        AND GIC.GIC_BILREF = %Exp:cCodGIC%
        AND GIC.GIC_STATUS In ('C','D')
        AND GIC.%NotDel%
EndSql

lRet := (cTmpAlias)->TOTBILREF == 0

(cTmpAlias)->(DbCloseArea())

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} MdlActivate
Fun��o responsavel para realiza��o da c�pia do bilhete original e setando como cancelamento ou devolu��o
@type function
@author jacomo.fernandes
@since 04/09/2018
@version 1.0
@param oModel, objeto, (Descri��o do par�metro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function MdlActivate(oModel)
Local oMdlGIC   := oModel:GetModel('GICMASTER')
Local oMdlGZP   := oModel:GetModel('GZPPAGTO')
Local aFields   := GIC->(DbStruct())
Local nI            := 0
Local cFldNoCopy    :=	'GIC_CODIGO|GIC_DTVEND|GIC_NUMFCH|GIC_CODGY3|GIC_VLACER|GIC_CODREQ|GIC_REQDSC|GIC_REQTOT|GIC_CARGA|GIC_CONFER|'+;
						'GIC_TITCAN|GIC_CODGQ6|GIC_PERCOM|GIC_PERIMP|GIC_VALCOM|GIC_CALIMP|GIC_NOTA|GIC_CLIENT|GIC_LOJA|GIC_STAPRO|'+;
						'GIC_FILNF|GIC_SERINF|GIC_BILREF|GIC_STATUS|'

GIC->(DBGOTO(__RecGIC))
For nI := 1 to Len(aFields)
	If !(Alltrim(aFields[nI][1])+"|" $ cFldNoCopy )
		oMdlGIC:LoadValue(aFields[nI][1], GIC->&(aFields[nI][1]))
	Endif
Next

oMdlGIC:LoadValue("GIC_STATUS","D")
oMdlGIC:LoadValue("GIC_BILREF",GIC->GIC_CODIGO)

oMdlGZP:ClearData()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o responsavel para montagem do objeto de visualiza��o da rotina
@type function
@author jacomo.fernandes
@since 04/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView     := FwLoadView('GTPA115')
Local oModel    := FwLoadModel('GTPA115D')
Local oStruGIC  := oView:GetViewStruct('VIEW_GIC')

SetViewStruct(oStruGIC)

oView:SetModel(oModel)

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
Fun��o respons�vel para manipula��o da estrutura das tabelas
@type function
@author jacomo.fernandes
@since 04/09/2018
@version 1.0
@param oStruGIC, objeto, (Descri��o do par�metro)
@param oStrMdGIC, objeto, (Descri��o do par�metro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStruGIC)

oStruGIC:SetProperty('*'            ,MVC_VIEW_CANCHANGE,.F.)
oStruGIC:SetProperty('GIC_MOTCAN'   ,MVC_VIEW_CANCHANGE,.T.)
oStruGIC:SetProperty('GIC_DTVEND'   ,MVC_VIEW_CANCHANGE,.T.)

oStruGIC:AddGroup('GRP000', "Dados de Devolu��o",'', 2)//'Dados de Devolu��o'
aSort(oStruGIC:aGroups, , , {|x, y| x:cID < y:cID})

oStruGIC:SetProperty( 'GIC_DTVEND', MVC_VIEW_GROUP_NUMBER, 'GRP000')
oStruGIC:SetProperty( 'GIC_MOTCAN', MVC_VIEW_GROUP_NUMBER, 'GRP000')

oStruGIC:SetProperty( 'GIC_DTVEND', MVC_VIEW_TITULO, "Dt. Devolu��o")//"Dt. Devolu��o"
oStruGIC:SetProperty( 'GIC_MOTCAN', MVC_VIEW_TITULO, "Mot. Devolu��o")//"Mot. Devolu��o"

Return