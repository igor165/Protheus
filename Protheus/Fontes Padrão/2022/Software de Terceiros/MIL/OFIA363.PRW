#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA363.CH"

/*/{Protheus.doc} OFIA363()
VN7 - Tempo Total Conferência Volume Entrada

@author Andre Luis Almeida
@since 11/11/2021
@version 1.0
@return NIL
/*/
Function OFIA363()

Private cCadastro := STR0001 // Tempo Total Conferência Volume Entrada

oBrwVN7 := FwMBrowse():New()
oBrwVN7:SetDescription(cCadastro)
oBrwVN7:SetAlias('VN7')
oBrwVN7:DisableLocate()
oBrwVN7:DisableDetails()
oBrwVN7:SetAmbiente(.F.)
oBrwVN7:SetWalkthru(.F.)
oBrwVN7:SetInsert(.f.)
oBrwVN7:SetUseFilter()
oBrwVN7:Activate()

Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 11/11/2021
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.OFIA363' OPERATION 2 ACCESS 0 // Visualizar

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 11/11/2021
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVN7 := FWFormStruct(1,"VN7")

oModel := MPFormModel():New("OFIA363", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VN7MASTER",/*cOwner*/ , oStrVN7)

oModel:SetDescription(STR0001) // Tempo Total Conferência Volume Entrada

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 11/11/2021
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVN7:= FWFormStruct(2,"VN7")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_VN7', oStrVN7, 'VN7MASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView('VIEW_VN7', 'CABEC' )

oView:SetCloseOnOk({||.T.})

Return oView

/*/
{Protheus.doc} OA3630011_Tempo_Total_Conferencia_Volume_Entrada
Iniciar/Finalizar o Tempo Total da Conferencia de Volume Entrada

@author Andre Luis Almeida
@since 11/11/2021
/*/
Function OA3630011_Tempo_Total_Conferencia_Volume_Entrada( nAcao , cVolume )
Local oModVN7 := FWLoadModel( 'OFIA363' )
Local lRetVN7 := .f.
Local cQuery  := ""
Local nRecVN7 := 0
Local aErro   := {}
Default nAcao := 1 // 1=Iniciar / 0=Finalizar
Default cVolume := ""
If !Empty(cVolume)
	cQuery := "SELECT VN7.R_E_C_N_O_ AS RECVN7 "
	cQuery += "  FROM " + RetSqlName("VN7") + " VN7 "
	cQuery += " WHERE VN7.VN7_FILIAL = '" + xFilial("VN7") + "'"
	cQuery += "   AND VN7.VN7_VOLUME = '" + cVolume + "'"
	cQuery += "   AND VN7.D_E_L_E_T_ = ' ' "
	nRecVN7 := FM_SQL(cQuery)
	If nAcao == 1 .and. nRecVN7 == 0 // 1=Iniciar
		oModVN7:SetOperation( MODEL_OPERATION_INSERT )
	ElseIf nAcao == 0 .and. nRecVN7 > 0 // 0=Finalizar
		VN7->(DbGoTo(nRecVN7))
		oModVN7:SetOperation( MODEL_OPERATION_UPDATE )
	Else // Se não atendeu as condicoes para Iniciar ou Finalizar o Tempo Total
		FreeObj(oModVN7)
		Return
	EndIf
	lRetVN7 := oModVN7:Activate()
	if lRetVN7
		If nAcao == 1 // Incluir
			oModVN7:LoadValue( "VN7MASTER" , "VN7_VOLUME" , cVolume )
			oModVN7:LoadValue( "VN7MASTER" , "VN7_DATINI" , dDataBase )
			oModVN7:LoadValue( "VN7MASTER" , "VN7_HORINI" , Time() )
		ElseIf nAcao == 0 // Finalizar
			oModVN7:LoadValue( "VN7MASTER" , "VN7_DATFIN" , dDataBase )
			oModVN7:LoadValue( "VN7MASTER" , "VN7_HORFIN" , Time() )
		EndIf
		If oModVN7:VldData()
			If oModVN7:CommitData()
			Else
				aErro := oModVN7:GetErrorMessage(.T.)
			EndIf
		Else
			aErro := oModVN7:GetErrorMessage(.T.)
		EndIf
		If len(aErro) > 0
			FMX_HELP("VALIDCOMMITVN7",;
				aErro[MODEL_MSGERR_IDFORMERR  ] + CRLF +;
				aErro[MODEL_MSGERR_IDFIELDERR ] + CRLF +;
				aErro[MODEL_MSGERR_ID         ] + CRLF +;
				aErro[MODEL_MSGERR_MESSAGE    ],;
				aErro[MODEL_MSGERR_SOLUCTION] )
		EndIf
		oModVN7:DeActivate()
	Else
		Help("",1,"ACTIVEVN7",,STR0003,1,0) // Não foi possivel ativar o modelo de alteração da tabela VN7
	EndIf
EndIf
FreeObj(oModVN7)
Return