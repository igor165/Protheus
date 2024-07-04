#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA789.ch'

//-------------------------------------------------------------------
/* {Protheus.doc} FINA789

Tela para Cadastro de Mensagens Padronizadas

@Author		rodrigo.pirolo

@Since		11/06/2015
@Sample		FINA789()
@Version	V12.1.6
@Project 	P12
@menu		SIGAFIN>Atualizações>Cadastros>Mensagem Padronizada
@Return		Nil
@history
*/
//-------------------------------------------------------------------

Function FINA789()

Local oBrws
Local aArea		:= GetArea()
Local aRotina	:= MenuDef()

oBrws := FWMBrowse():New()

oBrws:SetAlias( 'FWE' )
oBrws:SetDescription( STR0001 )//STR0001 'Mensagem Padronizada'

oBrws:Activate()

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/* {Protheus.doc} MenuDef

MenuDef da Tela de Mensagens Padronizadas

@author		rodrigo.pirolo

@since		15/06/2015
@Sample		Local aRotina	:= MenuDef()
@Version	V12.1.6
@Project 	P12
@Return		aRotina
*/
//-------------------------------------------------------------------

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0002	Action "VIEWDEF.FINA789" OPERATION 2 ACCESS 0//STR0002 'Visualizar'
ADD OPTION aRotina Title STR0003	Action "VIEWDEF.FINA789" OPERATION 3 ACCESS 0//STR0003 'Incluir'
ADD OPTION aRotina Title STR0004	Action "VIEWDEF.FINA789" OPERATION 4 ACCESS 0//STR0004 'Alterar'
ADD OPTION aRotina TITLE STR0005	Action "VIEWDEF.FINA789" OPERATION 5 ACCESS 0//STR0005 'Excluir'

Return(aRotina)

//-------------------------------------------------------------------
/* {Protheus.doc} ModelDef
Definição do modelo de Dados

@author		rodrigo.pirolo

@since		15/06/2015
@Sample		Local oModel:= ModelDef()
@Version	V12.1.6
@Project 	P12
@Return		oView
*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oStrFWE	:= FWFormStruct(1,'FWE')

oModel := MPFormModel():New('FINA789',,{ |oModel| FA789Vld( oModel ) },)

oModel:addFields('FIELDFWE',,oStrFWE,,)

oModel:SetPrimaryKey({ 'FWE_FILIAL', 'FWE_PREFIX', 'FWE_TIPO', 'FWE_NATURE' })

oModel:getModel('FIELDFWE'):SetDescription(STR0001) //STR0001'Mensagem Padronizada'

oModel:SetDescription(STR0001) //STR0001'Mensagem Padronizada'

Return oModel

//-------------------------------------------------------------------
/* {Protheus.doc} ViewDef
Definição do interface

@author		rodrigo.pirolo

@since		15/06/2015
@Version	V12.1.6
@Project 	P12
@Return		oView
*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView
Local oModel	:= ModelDef()
Local oStrFWE	:= FWFormStruct(2, 'FWE')

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('FORMFWE' , oStrFWE,'FIELDFWE' ) 

oView:CreateHorizontalBox( 'BOXFORMFWE', 100)

oView:SetOwnerView('FORMFWE','BOXFORMFWE')

oView:EnableTitleView('FORMFWE' , STR0001) //STR0001'Mensagem Padronizada'

Return oView

//-------------------------------------------------------------------
/* {Protheus.doc} FA789Vld
Validação pré gravação

@author rodrigo.pirolo

@Since		15/06/2015
@Sample		oModel := MPFormModel():New('FINA789',,{ |oModel| FA789Vld( oModel ) },)
@Version	V12.1.6
@Project 	P12
@Return		lRet - .T. Permite gravação
@Return		lRet - .F. Não Permite gravação
@history
*/
//-------------------------------------------------------------------

Static Function FA789Vld( oModel )

Local oModelFWE	:= oModel:getModel('FIELDFWE')
Local cPrefixo	:= oModelFWE:GetValue("FWE_PREFIX")
Local cTipo		:= oModelFWE:GetValue("FWE_TIPO")
Local cNatureza	:= oModelFWE:GetValue("FWE_NATURE")
Local cPreAnt	:= FWE->FWE_PREFIX
Local cTipoAnt	:= FWE->FWE_TIPO
Local cNatuAnt	:= FWE->FWE_NATURE
Local aArea		:= GetArea()

Local nOpc		:= oModel:GetOperation()
Local nQtd		:= 0

Local lRet		:= .F.

If !Empty(cPrefixo) .OR. !Empty(cTipo) .OR. !Empty(cNatureza)
	FWE->(DbSetOrder(1))
	If nOpc == 3
		
		If !( FWE->(DbSeek( xFilial("FWE") + cPrefixo + cTipo + cNatureza ) ) )
			lRet := .T.
		Else
			lRet := .F.
			Help('',1,'FA789GRV',,STR0006,1,0)
		EndIf
		
	ElseIf nOpc == 4
		
		If cPrefixo <> cPreAnt .OR. cTipo <> cTipoAnt .OR. cNatureza <> cNatuAnt

			If !( FWE->(DbSeek( xFilial("FWE") + cPrefixo + cTipo + cNatureza ) ) )
				lRet := .T.
			Else
				FWE->(DbSeek( xFilial("FWE") + cPreAnt + cTipoAnt + cNatuAnt ) )
				lRet := .F.
				Help('',1,'FA789GRV',,STR0006,1,0)
			EndIf
			
		Else
			lRet := .T.
		EndIf
		
	ElseIf nOpc == 5
		lRet := .T.
	EndIf
	
Else
	lRet := .F.
	Help('',1,'FA789GRV',,STR0007,1,0)
EndIf

RestArea(aArea)

Return lRet