#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA362.CH"

/*/{Protheus.doc} OFIA362()
VN6 - Tempo Total Conferência Oficina

@author Andre Luis Almeida
@since 10/11/2021
@version 1.0
@return NIL
/*/
Function OFIA362()

Private cCadastro := STR0001 // Tempo Total Conferência Oficina

oBrwVN6 := FwMBrowse():New()
oBrwVN6:SetDescription(cCadastro)
oBrwVN6:SetAlias('VN6')
oBrwVN6:DisableLocate()
oBrwVN6:DisableDetails()
oBrwVN6:SetAmbiente(.F.)
oBrwVN6:SetWalkthru(.F.)
oBrwVN6:SetInsert(.f.)
oBrwVN6:SetUseFilter()
oBrwVN6:Activate()

Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 10/11/2021
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.OFIA362' OPERATION 2 ACCESS 0 // Visualizar

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 10/11/2021
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVN6 := FWFormStruct(1,"VN6")

oModel := MPFormModel():New("OFIA362", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VN6MASTER",/*cOwner*/ , oStrVN6)

oModel:SetDescription(STR0001) // Tempo Total Conferência Oficina

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 10/11/2021
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVN6:= FWFormStruct(2,"VN6")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_VN6', oStrVN6, 'VN6MASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView('VIEW_VN6', 'CABEC' )

oView:SetCloseOnOk({||.T.})

Return oView

/*/
{Protheus.doc} OA3620011_Tempo_Total_Conferencia_Oficina
Iniciar/Finalizar o Tempo Total da Conferencia de Oficina

@author Andre Luis Almeida
@since 10/11/2021
/*/
Function OA3620011_Tempo_Total_Conferencia_Oficina( nAcao , cCodSol , cNroOS )
Local oModVN6  := FWLoadModel( 'OFIA362' )
Local lRetVN6  := .f.
Local cQuery   := ""
Local nRecVN6  := 0
Local aErro    := {}
Default nAcao  := 1 // 1=Iniciar / 0=Finalizar
Default cCodSol:= ""
Default cNroOS := ""
If !Empty(cCodSol+cNroOS)
	cQuery := "SELECT VN6.R_E_C_N_O_ AS RECVN6 "
	cQuery += "  FROM " + RetSqlName("VN6") + " VN6 "
	cQuery += " WHERE VN6.VN6_FILIAL = '" + xFilial("VN6") + "'"
	cQuery += "   AND VN6.VN6_CODSOL = '" + cCodSol + "'"
	cQuery += "   AND VN6.VN6_NUMOSV = '" + cNroOS + "'"
	cQuery += "   AND VN6.D_E_L_E_T_ = ' ' "
	nRecVN6 := FM_SQL(cQuery)
	If nAcao == 1 .and. nRecVN6 == 0 // 1=Iniciar
		oModVN6:SetOperation( MODEL_OPERATION_INSERT )
	ElseIf nAcao == 0 .and. nRecVN6 > 0 // 0=Finalizar
		VN6->(DbGoTo(nRecVN6))
		oModVN6:SetOperation( MODEL_OPERATION_UPDATE )
	Else // Se não atendeu as condicoes para Iniciar ou Finalizar o Tempo Total
		FreeObj(oModVN6)
		Return
	EndIf
	lRetVN6 := oModVN6:Activate()
	if lRetVN6
		If nAcao == 1 // Incluir
			oModVN6:LoadValue( "VN6MASTER" , "VN6_CODSOL" , cCodSol )
			oModVN6:LoadValue( "VN6MASTER" , "VN6_NUMOSV" , cNroOS )
			oModVN6:LoadValue( "VN6MASTER" , "VN6_DATINI" , dDataBase )
			oModVN6:LoadValue( "VN6MASTER" , "VN6_HORINI" , Time() )
		ElseIf nAcao == 0 // Finalizar
			oModVN6:LoadValue( "VN6MASTER" , "VN6_DATFIN" , dDataBase )
			oModVN6:LoadValue( "VN6MASTER" , "VN6_HORFIN" , Time() )
		EndIf
		If oModVN6:VldData()
			If oModVN6:CommitData()
			Else
				aErro := oModVN6:GetErrorMessage(.T.)
			EndIf
		Else
			aErro := oModVN6:GetErrorMessage(.T.)
		EndIf
		If len(aErro) > 0
			FMX_HELP("VALIDCOMMITVN6",;
				aErro[MODEL_MSGERR_IDFORMERR  ] + CRLF +;
				aErro[MODEL_MSGERR_IDFIELDERR ] + CRLF +;
				aErro[MODEL_MSGERR_ID         ] + CRLF +;
				aErro[MODEL_MSGERR_MESSAGE    ],;
				aErro[MODEL_MSGERR_SOLUCTION] )
		EndIf
		oModVN6:DeActivate()
	Else
		Help("",1,"ACTIVEVN6",,STR0003,1,0) // Não foi possivel ativar o modelo de alteração da tabela VN6
	EndIf
EndIf
FreeObj(oModVN6)
Return