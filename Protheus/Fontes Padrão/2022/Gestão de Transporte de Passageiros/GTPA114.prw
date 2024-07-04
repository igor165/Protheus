#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA114.CH'


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA114()
Cadastro de Tipos de Vales
 
@sample	GTPA114()
 
@return	oBrowse  Retorna o Cadastro de Tipos de Vales
 
@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA114()

Local oBrowse	:= Nil		

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("G9A")
oBrowse:SetDescription(STR0001)	// Tipos de Vales
oBrowse:AddLegend( "G9A_BLOQ=='1'", "RED", STR0006) // Bloqueado
oBrowse:AddLegend( "G9A_BLOQ=='2'", "GREEN" , STR0007 ) // Ativo
oBrowse:DisableDetails()
oBrowse:Activate()

Return (oBrowse)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Defini��o do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com op��es do menu
 
@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function MenuDef()

Local aRotina	:= {}
Local oModel	:= FwModelActive()

ADD OPTION aRotina TITLE STR0002 	ACTION "VIEWDEF.GTPA114"	OPERATION 2 ACCESS 0 	// STR0002//"Visualizar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.GTPA114" 	OPERATION 3	ACCESS 0 	// STR0003//"Incluir"
ADD OPTION aRotina TITLE STR0005	ACTION "VIEWDEF.GTPA114"	OPERATION 5	ACCESS 0 	// STR0005//"Excluir"
ADD OPTION aRotina TITLE STR0004	ACTION "VIEWDEF.GTPA114"	OPERATION 4	ACCESS 0 	// STR0004//"Alterar"

Return ( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados

@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oStruG9A  := FWFormStruct(1,'G9A')
Local bPosVld   := {|oModel| GA114ExistTpVal(oModel)}
Local oModel	:= MPFormModel():New('GTPA114',/*bPreValidMdl*/, bPosVld,/*bCommit*/, /*bCancel*/ )

oModel:SetDescription(STR0001) // Tipos de Vales
 
oModel:AddFields('FIELDG9A',,oStruG9A)
oModel:GetModel('FIELDG9A'):SetDescription(STR0001)  // Tipos de Vales

oModel:SetPrimaryKey({'G9A_FILIAL', 'G9A_CODIGO'}) // Primary key pode ser definida no X2_�nica tamb�m 

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface

@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView
Local oModel   := ModelDef()
Local oStruG9A := FWFormStruct(2, 'G9A')

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEWG9A', oStruG9A, 'FIELDG9A') 

oView:CreateHorizontalBox( 'SUPERIOR', 100)
oView:SetOwnerView('VIEWG9A','SUPERIOR')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GA114ExistTpVal
Fun��o que busca a exist�ncia de um vale de funcion�rio associado ao
tipo do vale que ser� deletado

@sample GA114ExistTpVal(oModel)
@param oModel - Modelo de Dados
@return lRet - Existe algum vale associado ao tipo

@author	    Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function GA114ExistTpVal(oModel)
Local cAliasGQP := GetNextAlias() // Pega o pr�ximo alias dispon�vel para a tabela GQP
Local oModelG9A := oModel:GetModel("FIELDG9A")
Local cTipoVale := oModelG9A:GetValue("G9A_CODIGO") // Guarda o c�digo do tipo de vale a ser verificado
Local lRet      := .T.

If (oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
    // Se j� existir a chave no banco de dados no momento do commit, a rotina 
    If (!ExistChav("G9A", cTipoVale))
        lRet := .F.
    EndIf
ElseIf (oModel:GetOperation() == MODEL_OPERATION_DELETE)
    // Come�a consulta SQL na tabela tempor�ria criada
    BeginSQL Alias cAliasGQP
        SELECT 
            TOP 1 GQP.GQP_TIPO 
        FROM 
            %table:GQP% GQP
        WHERE 
            GQP.GQP_FILIAL = %xFilial:GQP%
            AND GQP.GQP_TIPO = %Exp:cTipoVale% 
            AND GQP.%NotDel% 
    EndSQL
    // Caso o tipo de vale esteja associado � algum vale n�o poder� ser deletado
    If (!Empty((cAliasGQP)->GQP_TIPO))
        lRet := .F.
        Help( ,, STR0008,, STR0009, 1, 0) // Ate��o, Tipo de vale est� associado com algum vale de funcion�rio.
    EndIf

    (cAliasGQP)->(DbCloseArea())

EndIf


Return lRet