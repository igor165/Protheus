#Include "GTPA120.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA120()
Cadastro de Pedágio

@sample	GTPA120()

@return	oBrowse	Retorna o Cadastro de Pedágio

@author	Gustavo Silva -  Inovação
@since		02/01/2019
@version 1.0
/*/
//------------------------------------------------------------------------------------------

Function GTPA120()

Local oBrowse	

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('G9T')
oBrowse:SetDescription(STR0001) //'Cadastro de Pedágio'
oBrowse:Activate()
Return Nil

Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.GTPA120' OPERATION 2 ACCESS 0 // Visualizar //'Visualizar'
ADD OPTION aRotina TITLE STR0003   ACTION 'VIEWDEF.GTPA120' OPERATION 3 ACCESS 0 // Incluir //'Incluir'
ADD OPTION aRotina TITLE STR0004   ACTION 'VIEWDEF.GTPA120' OPERATION 4 ACCESS 0 // Alterar //'Alterar'
ADD OPTION aRotina TITLE STR0005   ACTION 'VIEWDEF.GTPA120' OPERATION 5 ACCESS 0 // Excluir //'Excluir'

Return ( aRotina )

Static Function ModelDef()

Local bPosValid := {|oModelF|PosValid(oModelF)}
Local oStruG9T := FWFormStruct( 1, 'G9T' )
Local oModel	:= nil
oModel := MPFormModel():New('GTPA120')

oModel:AddFields( 'G9TMASTER', /*cOwner*/, oStruG9T,,bPosValid )
oModel:SetDescription( STR0006 ) //'Modelo de Dados de Usuário'
oModel:GetModel( 'G9TMASTER' ):SetDescription( STR0001 ) //'Cadastro de Pedágio'
oModel:SetPrimaryKey({"G9T_FILIAL","G9T_CODIGO"})

Return oModel

Static Function ViewDef()

Local oModel   := FWLoadModel( 'GTPA120' )
Local oStruG9T := FWFormStruct( 2, 'G9T' )
Local oView := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_G9T', oStruG9T, 'G9TMASTER' )
oView:SetDescription(STR0001)  //'Cadastro de Pedágio'
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_G9T', 'TELA' )

Return oView

/*/{Protheus.doc} PosValid(oModelF)
Função responsável por validar se o registro já existe e não permitir que o
local de origem e destino sejam os mesmos.
@type function
@author gustavo.silva2
@since 05/01/2019
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function PosValid(oModelF)
Local oModel    := oModelF:GetModel()
Local oModelG9T	:= oModel:GetModel('G9TMASTER')
Local lRet		:= .T.
Local aArea     := GetArea()
Local aAreaG9T  := G9T->( GetArea() )
Local cCodOrig 	:= oModelG9T:GetValue('G9T_CODORI')
Local cCodDes 	:= oModelG9T:GetValue('G9T_CODDES')
Local nTotal 	:= oModelG9T:GetValue('G9T_VALTOT')
Local nOpc		:= oModel:GetOperation()
Local nEixos	:= Iif(G9T->(FieldPos("G9T_EIXOS")) > 0,oModelG9T:GetValue('G9T_EIXOS'),0)

If nOpc <> MODEL_OPERATION_DELETE
	If cCodOrig == cCodDes
		lRet := .F.
		Help( ,, 'Help',, STR0007, 1, 0 ) //'O local de Origem não pode ser o mesmo de Destino'
	EndIf
	
	If Empty(cCodOrig) .OR. Empty(cCodDes)
		lRet:= .F.
		Help( ,, 'Help',, STR0008, 1, 0 ) //'O campo Cód.Origem/ Cód.Destino está vazio. Preencha com um número válido'
	EndIf
EndIf

If nOpc == MODEL_OPERATION_INSERT	
	If RecnoPedag(cCodOrig,cCodDes,nEixos) > 0
		lRet:= .F.
		Help( ,, 'Help',, STR0009, 1, 0 ) //'Esse registro já existe'
	Endif
EndIf
	
RestArea( aAreaG9T)
RestArea( aArea )

Return lRet


/*/{Protheus.doc} VlrPedagio
//TODO Descrição auto-gerada.
@author GTP
@since 28/12/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function RecnoPedag(cCodOrig,cCodDes,nEixos)
Local nRet := 0
Local cAliasTmp	:= GetNextAlias()
Local lEixos	:= G9T->(FieldPos("G9T_EIXOS")) > 0 .AND. G6R->(FieldPos("G6R_EIXOS")) > 0
Local cSeekG9T	:= Iif( lEixos, '% AND G9T_EIXOS = '+ALLTRIM(STR(nEixos))+'%', '%%' )

BeginSql Alias cAliasTmp

	Select R_E_C_N_O_
	From %Table:G9T%
	WHERE
		G9T_FILIAL = %xFilial:G9T%
		AND G9T_CODORI = %Exp:cCodOrig%
		AND G9T_CODDES = %Exp:cCodDes%		
		AND %NotDel%
		%Exp:cSeekG9T%		
EndSql
 
If (cAliasTmp)->R_E_C_N_O_ > 0
	nRet	:= (cAliasTmp)->G9T_VALTOT
Endif

(cAliasTmp)->(DbCloseArea())

Return nRet
