#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA245.CH"

/*/{Protheus.doc} VEIA245()
Opções do Cadastro de Custo dos Pacotes. Utilizadas no VEIA244

@author Andre Luis Almeida
@since 26/07/2021
@version 1.0
@return NIL
/*/
Function VEIA245()
Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 26/07/2021
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}

aRotina := FWMVCMenu('VEIA245')

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 26/07/2021
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVN2 := FWFormStruct(1,"VN2")

oModel := MPFormModel():New("VEIA245", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VN2MASTER",/*cOwner*/ , oStrVN2)

oModel:SetDescription(STR0001) // Markups e Descontos

//oModel:InstallEvent("VEIA245LOG", /*cOwner*/, MVCLOGEV():New("VEIA245") ) // CONSOLE.LOG para verificar as chamadas dos eventos

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 26/07/2021
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVN2:= FWFormStruct(2,"VN2")

oStrVN2:RemoveField('VN2_DATINC')
oStrVN2:RemoveField('VN2_DATALT')

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_VN2', oStrVN2, 'VN2MASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView('VIEW_VN2', 'CABEC' )

oView:SetCloseOnOk({||.T.})

Return oView

/*/
{Protheus.doc} VA2450011_Desativar
Desativar o VN2 posicionado ou se passado o RECNO correspondente

@author Andre Luis Almeida
@since 26/07/2021
@type function
/*/
Function VA2450011_Desativar( nRecVN2 )
Local oModVN2 := FWLoadModel( 'VEIA245' )
Local lRetVN2 := .f.
Local aErro   := {}
Default nRecVN2 := 0
If nRecVN2 > 0
	VN2->(DbGoTo(nRecVN2))
EndIf
If VN2->VN2_STATUS == "1"
	oModVN2:SetOperation( MODEL_OPERATION_UPDATE )
	lRetVN2 := oModVN2:Activate()
	if lRetVN2
		oModVN2:LoadValue( "VN2MASTER" , "VN2_STATUS" , "0" )
		oModVN2:LoadValue( "VN2MASTER" , "VN2_DATALT" , FGX_Timestamp() )
		If oModVN2:VldData()
			If oModVN2:CommitData()
			Else
				aErro := oModVN2:GetErrorMessage(.T.)
			EndIf
		Else
			aErro := oModVN2:GetErrorMessage(.T.)
		EndIf
		If len(aErro) > 0
			FMX_HELP("DESATIVAR_VALIDCOMMITVN2",;
				aErro[MODEL_MSGERR_IDFORMERR  ] + CRLF +;
				aErro[MODEL_MSGERR_IDFIELDERR ] + CRLF +;
				aErro[MODEL_MSGERR_ID         ] + CRLF +;
				aErro[MODEL_MSGERR_MESSAGE    ],;
				aErro[MODEL_MSGERR_SOLUCTION] )
		EndIf
		oModVN2:DeActivate()
	Else
		Help("",1,"ACTIVEVN2",,STR0002,1,0) // Não foi possivel ativar o modelo de alteração da tabela VN2
	EndIf
	FreeObj(oModVN2)
EndIf
Return

/*/
{Protheus.doc} VA2450021_Incluir
Incluir o VN2

@author Andre Luis Almeida
@since 26/07/2021
/*/
Function VA2450021_Incluir( cCodVN0 , dDatVN2 , nCusVN2 , nFreVN2 )
Local oModVN2 := FWLoadModel( 'VEIA245' )
Local lRetVN2 := .f.
Local aErro   := {}
oModVN2:SetOperation( MODEL_OPERATION_INSERT )
lRetVN2 := oModVN2:Activate()
if lRetVN2
	oModVN2:LoadValue( "VN2MASTER" , "VN2_CODVN0" , cCodVN0 )
	oModVN2:LoadValue( "VN2MASTER" , "VN2_DATINI" , dDatVN2 )
	oModVN2:LoadValue( "VN2MASTER" , "VN2_VALPAC" , nCusVN2 )
	oModVN2:LoadValue( "VN2MASTER" , "VN2_FREPAC" , nFreVN2 )
	If oModVN2:VldData()
		If oModVN2:CommitData()
		Else
			aErro := oModVN2:GetErrorMessage(.T.)
		EndIf
	Else
		aErro := oModVN2:GetErrorMessage(.T.)
	EndIf
	If len(aErro) > 0
		FMX_HELP("INCLUIR_VALIDCOMMITVN2",;
			aErro[MODEL_MSGERR_IDFORMERR  ] + CRLF +;
			aErro[MODEL_MSGERR_IDFIELDERR ] + CRLF +;
			aErro[MODEL_MSGERR_ID         ] + CRLF +;
			aErro[MODEL_MSGERR_MESSAGE    ],;
			aErro[MODEL_MSGERR_SOLUCTION] )
	EndIf
	oModVN2:DeActivate()
Else
	Help("",1,"ACTIVEVN2",,STR0002,1,0) // Não foi possivel ativar o modelo de alteração da tabela VN2
EndIf
FreeObj(oModVN2)
Return