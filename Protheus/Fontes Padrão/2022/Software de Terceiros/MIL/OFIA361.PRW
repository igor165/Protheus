#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA361.CH"

/*/{Protheus.doc} OFIA361()
VN5 - Tempo Total Conferência Saida - Orçamento

@author Andre Luis Almeida
@since 09/11/2021
@version 1.0
@return NIL
/*/
Function OFIA361()

Private cCadastro := STR0001 // Tempo Total Conferência Saida - Orçamento

oBrwVN5 := FwMBrowse():New()
oBrwVN5:SetDescription(cCadastro)
oBrwVN5:SetAlias('VN5')
oBrwVN5:DisableLocate()
oBrwVN5:DisableDetails()
oBrwVN5:SetAmbiente(.F.)
oBrwVN5:SetWalkthru(.F.)
oBrwVN5:SetInsert(.f.)
oBrwVN5:SetUseFilter()
oBrwVN5:Activate()

Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 09/11/2021
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.OFIA361' OPERATION 2 ACCESS 0 // Visualizar

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 09/11/2021
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVN5 := FWFormStruct(1,"VN5")

oModel := MPFormModel():New("OFIA361", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VN5MASTER",/*cOwner*/ , oStrVN5)

oModel:SetDescription(STR0001) // Tempo Total Conferência Saida - Orçamento

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 09/11/2021
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVN5:= FWFormStruct(2,"VN5")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_VN5', oStrVN5, 'VN5MASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView('VIEW_VN5', 'CABEC' )

oView:SetCloseOnOk({||.T.})

Return oView

/*/
{Protheus.doc} OA3610011_Tempo_Total_Conferencia_Saida_Orcamento
Iniciar/Finalizar o Tempo Total da Conferencia de Saida Orcamento

@author Andre Luis Almeida
@since 09/11/2021
/*/
Function OA3610011_Tempo_Total_Conferencia_Saida_Orcamento( nAcao , cNroOrc )
Local oModVN5 := FWLoadModel( 'OFIA361' )
Local lRetVN5 := .f.
Local cQuery  := ""
Local nRecVN5 := 0
Local aErro   := {}
Default nAcao := 1 // 1=Iniciar / 0=Finalizar
Default cNroOrc := ""
If !Empty(cNroOrc)
	cQuery := "SELECT VN5.R_E_C_N_O_ AS RECVN5 "
	cQuery += "  FROM " + RetSqlName("VN5") + " VN5 "
	cQuery += " WHERE VN5.VN5_FILIAL = '" + xFilial("VN5") + "'"
	cQuery += "   AND VN5.VN5_NUMORC = '" + cNroOrc + "'"
	cQuery += "   AND VN5.D_E_L_E_T_ = ' ' "
	nRecVN5 := FM_SQL(cQuery)
	If nAcao == 1 .and. nRecVN5 == 0 // 1=Iniciar
		oModVN5:SetOperation( MODEL_OPERATION_INSERT )
	ElseIf nAcao == 0 .and. nRecVN5 > 0 // 0=Finalizar
		VN5->(DbGoTo(nRecVN5))
		oModVN5:SetOperation( MODEL_OPERATION_UPDATE )
	Else // Se não atendeu as condicoes para Iniciar ou Finalizar o Tempo Total
		FreeObj(oModVN5)
		Return
	EndIf
	lRetVN5 := oModVN5:Activate()
	if lRetVN5
		If nAcao == 1 // Incluir
			oModVN5:LoadValue( "VN5MASTER" , "VN5_NUMORC" , cNroOrc )
			oModVN5:LoadValue( "VN5MASTER" , "VN5_DATINI" , dDataBase )
			oModVN5:LoadValue( "VN5MASTER" , "VN5_HORINI" , Time() )
		ElseIf nAcao == 0 // Finalizar
			oModVN5:LoadValue( "VN5MASTER" , "VN5_DATFIN" , dDataBase )
			oModVN5:LoadValue( "VN5MASTER" , "VN5_HORFIN" , Time() )
		EndIf
		If oModVN5:VldData()
			If oModVN5:CommitData()
			Else
				aErro := oModVN5:GetErrorMessage(.T.)
			EndIf
		Else
			aErro := oModVN5:GetErrorMessage(.T.)
		EndIf
		If len(aErro) > 0
			FMX_HELP("VALIDCOMMITVN5",;
				aErro[MODEL_MSGERR_IDFORMERR  ] + CRLF +;
				aErro[MODEL_MSGERR_IDFIELDERR ] + CRLF +;
				aErro[MODEL_MSGERR_ID         ] + CRLF +;
				aErro[MODEL_MSGERR_MESSAGE    ],;
				aErro[MODEL_MSGERR_SOLUCTION] )
		EndIf
		oModVN5:DeActivate()
	Else
		Help("",1,"ACTIVEVN5",,STR0003,1,0) // Não foi possivel ativar o modelo de alteração da tabela VN5
	EndIf
EndIf
FreeObj(oModVN5)
Return