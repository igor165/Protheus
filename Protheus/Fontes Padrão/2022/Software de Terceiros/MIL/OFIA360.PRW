#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA360.CH"

/*/{Protheus.doc} OFIA360()
VN4 - Tempo Total Conferência NF Entrada

@author Andre Luis Almeida
@since 08/11/2021
@version 1.0
@return NIL
/*/
Function OFIA360()

Private cCadastro := STR0001 // Tempo Total Conferência NF Entrada

oBrwVN4 := FwMBrowse():New()
oBrwVN4:SetDescription(cCadastro)
oBrwVN4:SetAlias('VN4')
oBrwVN4:DisableLocate()
oBrwVN4:DisableDetails()
oBrwVN4:SetAmbiente(.F.)
oBrwVN4:SetWalkthru(.F.)
oBrwVN4:SetInsert(.f.)
oBrwVN4:SetUseFilter()
oBrwVN4:Activate()

Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 08/11/2021
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.OFIA360' OPERATION 2 ACCESS 0 // Visualizar

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 08/11/2021
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVN4 := FWFormStruct(1,"VN4")

oModel := MPFormModel():New("OFIA360", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VN4MASTER",/*cOwner*/ , oStrVN4)

oModel:SetDescription(STR0001) // Tempo Total Conferência NF Entrada

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 08/11/2021
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVN4:= FWFormStruct(2,"VN4")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_VN4', oStrVN4, 'VN4MASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView('VIEW_VN4', 'CABEC' )

oView:SetCloseOnOk({||.T.})

Return oView

/*/
{Protheus.doc} OA3600011_Tempo_Total_Conferencia_NF_Entrada
Iniciar/Finalizar o Tempo Total da Conferencia de NF de Entrada

@author Andre Luis Almeida
@since 08/11/2021
/*/
Function OA3600011_Tempo_Total_Conferencia_NF_Entrada( nAcao , cDoc , cSer , cFor , cLoj )
Local oModVN4 := FWLoadModel( 'OFIA360' )
Local lRetVN4 := .f.
Local cQuery  := ""
Local nRecVN4 := 0
Local aErro   := {}
Default nAcao := 1 // 1=Iniciar / 0=Finalizar
Default cDoc  := ""
Default cSer  := ""
Default cFor  := ""
Default cLoj  := ""
If !Empty(cDoc+cSer+cFor+cLoj)
	cQuery := "SELECT VN4.R_E_C_N_O_ AS RECVN4 "
	cQuery += "  FROM " + RetSqlName("VN4") + " VN4 "
	cQuery += " WHERE VN4.VN4_FILIAL = '" + xFilial("VN4") + "'"
	cQuery += "   AND VN4.VN4_DOC    = '" + cDoc + "'"
	cQuery += "   AND VN4.VN4_SERIE  = '" + cSer + "'"
	cQuery += "   AND VN4.VN4_FORNEC = '" + cFor + "'"
	cQuery += "   AND VN4.VN4_LOJA   = '" + cLoj + "'"
	cQuery += "   AND VN4.D_E_L_E_T_ = ' ' "
	nRecVN4 := FM_SQL(cQuery)
	If nAcao == 1 .and. nRecVN4 == 0 // 1=Iniciar
		oModVN4:SetOperation( MODEL_OPERATION_INSERT )
	ElseIf nAcao == 0 .and. nRecVN4 > 0 // 0=Finalizar
		VN4->(DbGoTo(nRecVN4))
		oModVN4:SetOperation( MODEL_OPERATION_UPDATE )
	Else // Se não atendeu as condicoes para Iniciar ou Finalizar o Tempo Total
		FreeObj(oModVN4)
		Return
	EndIf
	lRetVN4 := oModVN4:Activate()
	if lRetVN4
		If nAcao == 1 // Incluir
			oModVN4:LoadValue( "VN4MASTER" , "VN4_DOC"    , cDoc )
			oModVN4:LoadValue( "VN4MASTER" , "VN4_SERIE"  , cSer )
			oModVN4:LoadValue( "VN4MASTER" , "VN4_FORNEC" , cFor )
			oModVN4:LoadValue( "VN4MASTER" , "VN4_LOJA"   , cLoj )
			oModVN4:LoadValue( "VN4MASTER" , "VN4_DATINI" , dDataBase )
			oModVN4:LoadValue( "VN4MASTER" , "VN4_HORINI" , Time() )
		ElseIf nAcao == 0 // Finalizar
			oModVN4:LoadValue( "VN4MASTER" , "VN4_DATFIN" , dDataBase )
			oModVN4:LoadValue( "VN4MASTER" , "VN4_HORFIN" , Time() )
		EndIf
		If oModVN4:VldData()
			If oModVN4:CommitData()
			Else
				aErro := oModVN4:GetErrorMessage(.T.)
			EndIf
		Else
			aErro := oModVN4:GetErrorMessage(.T.)
		EndIf
		If len(aErro) > 0
			FMX_HELP("VALIDCOMMITVN4",;
				aErro[MODEL_MSGERR_IDFORMERR  ] + CRLF +;
				aErro[MODEL_MSGERR_IDFIELDERR ] + CRLF +;
				aErro[MODEL_MSGERR_ID         ] + CRLF +;
				aErro[MODEL_MSGERR_MESSAGE    ],;
				aErro[MODEL_MSGERR_SOLUCTION] )
		EndIf
		oModVN4:DeActivate()
	Else
		Help("",1,"ACTIVEVN4",,STR0003,1,0) // Não foi possivel ativar o modelo de alteração da tabela VN4
	EndIf
EndIf
FreeObj(oModVN4)
Return