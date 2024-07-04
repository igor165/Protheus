#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA010.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} VEIA010()
Cadastro de Envio automatico de Emails

@author Andre Luis Almeida
@since 19/10/2018
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function VEIA010()
Local oBrowse
Private oModel

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("VEU")
oBrowse:SetDescription(STR0001) // Envio de E-mails automaticos
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 19/10/2018
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.VEIA010' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.VEIA010' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.VEIA010' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.VEIA010' OPERATION 5 ACCESS 0 // Excluir
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.VEIA010' OPERATION 8 ACCESS 0 // Imprimir

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 19/10/2018
@version 1.0
@Return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStrVEU:= FWFormStruct(1,"VEU")

oModel := MPFormModel():New("VEIA010", /* bPre */, {|| VA0100021_TudoOK() }/* bPost */ , /* bCommit */ )
oModel:AddFields("VEUMASTER",/*cOwner*/ , oStrVEU)
oModel:GetModel("VEUMASTER"):SetDescription(STR0007) // E-mail
oModel:SetDescription(STR0001) // Envio de E-mails automaticos

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 19/10/2018
@version 1.0
@Return oView
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVEU:= FWFormStruct(2, "VEU")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_VEU" , oStrVEU, "VEUMASTER" )
oView:CreateHorizontalBox( "VEU", 100)
oView:SetOwnerView("VIEW_VEU","VEU")

Return oView

/*/{Protheus.doc} VA0100011_LevantaEmails
	Retorna todos os E-mails de um determinado Evento
	
	@author Andre Luis Almeida
	@since 19/10/2018
/*/
Function VA0100011_LevantaEmails( cEvento )
Local cEmails := ""
Local cQAlSQL := "SQLVEU"
Local cQuery  := ""

If FWAliasInDic("VEU")

	cQuery := "SELECT VEU_EMAIL , VEU_FUNCAO "
	cQuery += "  FROM "+RetSqlName("VEU")
	cQuery += " WHERE VEU_FILIAL='"+xFilial("VEU")+"'"
	cQuery += "   AND VEU_EVENTO='"+cEvento+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )
		If !Empty(( cQAlSQL )->( VEU_EMAIL ))
			cEmails += Alltrim(( cQAlSQL )->( VEU_EMAIL ))+";"
		Else
			cEmails += &(Alltrim(( cQAlSQL )->( VEU_FUNCAO )))+";"
		EndIf
		( cQAlSQL )->( DbSkip() )
	EndDo
	( cQAlSQL )->( DbCloseArea() )
	DbSelectArea("VEU")
	If !Empty(cEmails)
		cEmails := left(cEmails,len(cEmails)-1) // Retirar ultimo ;
	EndIf

EndIf

Return cEmails

/*/{Protheus.doc} VA0100021_TudoOK
	Tudo OK da Tela de Cadastro
	
	@author Andre Luis Almeida
	@since 31/10/2018
/*/
Function VA0100021_TudoOK()
Local lRet := .t.
If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	If Empty(oModel:GetValue("VEUMASTER", "VEU_EMAIL")) .and. Empty(oModel:GetValue("VEUMASTER", "VEU_FUNCAO")) 
		Help(" ",1,"OBRIGAT2",,"'"+RetTitle("VEU_EMAIL")+"' "+STR0009+" '"+RetTitle("VEU_FUNCAO")+"'",4,1) // ou
		lRet := .f.
	EndIf
EndIf
Return lRet