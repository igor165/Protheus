#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA320.CH"

/*/{Protheus.doc} OFIA320()
VCX - Volumes dos Itens NF Entrada

@author Andre Luis Almeida
@since 12/08/2021
@version 1.0
@return NIL
/*/
Function OFIA320()

Private cCadastro := STR0001 // Volumes dos Itens NF Entrada

oBrwVCX := FwMBrowse():New()
oBrwVCX:SetDescription(cCadastro)
oBrwVCX:SetAlias('VCX')
oBrwVCX:DisableLocate()
oBrwVCX:DisableDetails()
oBrwVCX:SetAmbiente(.F.)
oBrwVCX:SetWalkthru(.F.)
oBrwVCX:SetInsert(.f.)
oBrwVCX:SetUseFilter()
oBrwVCX:Activate()

Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 12/08/2021
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.OFIA320' OPERATION 2 ACCESS 0 // Visualizar

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 12/08/2021
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVCX := FWFormStruct(1,"VCX")

oModel := MPFormModel():New("OFIA320", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VCXMASTER",/*cOwner*/ , oStrVCX)

oModel:SetDescription(STR0001) // Volumes dos Itens NF Entrada

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 12/08/2021
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVCX:= FWFormStruct(2,"VCX")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_VCX', oStrVCX, 'VCXMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView('VIEW_VCX', 'CABEC' )

oView:SetCloseOnOk({||.T.})

Return oView

/*/
{Protheus.doc} OA3200011_Volumes_dos_Itens_da_NF_Entrada
Incluir o VCX com os Volumes dos Itens da NF de Entrada

@author Andre Luis Almeida
@since 12/08/2021
/*/
Function OA3200011_Volumes_dos_Itens_da_NF_Entrada( nRecVCX , aVetCpos )
Local oModVCX := FWLoadModel( 'OFIA320' )
Local lRetVCX := .f.
Local aErro   := {}
Local nCntFor := 0
Default nRecVCX  := 0
Default aVetCpos := {}
If len(aVetCpos) > 0
	If nRecVCX == 0 // Incluir
		oModVCX:SetOperation( MODEL_OPERATION_INSERT )
	Else // Alterar
		VCX->(DbGoTo(nRecVCX))
		oModVCX:SetOperation( MODEL_OPERATION_UPDATE )
	EndIf
	lRetVCX := oModVCX:Activate()
	if lRetVCX
		For nCntFor := 1 to len(aVetCpos)
			oModVCX:LoadValue( "VCXMASTER" , aVetCpos[nCntFor,1] , aVetCpos[nCntFor,2] )
		Next
		If oModVCX:VldData()
			If oModVCX:CommitData()
			Else
				aErro := oModVCX:GetErrorMessage(.T.)
			EndIf
		Else
			aErro := oModVCX:GetErrorMessage(.T.)
		EndIf
		If len(aErro) > 0
			FMX_HELP("VALIDCOMMITVCX",;
				aErro[MODEL_MSGERR_IDFORMERR  ] + CRLF +;
				aErro[MODEL_MSGERR_IDFIELDERR ] + CRLF +;
				aErro[MODEL_MSGERR_ID         ] + CRLF +;
				aErro[MODEL_MSGERR_MESSAGE    ],;
				aErro[MODEL_MSGERR_SOLUCTION] )
		EndIf
		oModVCX:DeActivate()
	Else
		Help("",1,"ACTIVEVCX",,STR0003,1,0) // Não foi possivel ativar o modelo de alteração da tabela VCX
	EndIf
EndIf
FreeObj(oModVCX)
Return