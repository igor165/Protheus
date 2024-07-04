#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA251.CH"

/*/{Protheus.doc} VEIA251()
Opções do Cadastro de % de Markup e % de Desconto para formar o valor de Venda dos Pacotes. Utilizadas no VEIA250

@author Andre Luis Almeida
@since 05/07/2021
@version 1.0
@return NIL
/*/
Function VEIA251()
Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 05/07/2021
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.VEIA251' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.VEIA251' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0004 ACTION 'VA2510011_Desativar(0,.t.)' OPERATION 4 ACCESS 0 // Desativar
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 05/07/2021
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVN3 := FWFormStruct(1,"VN3")

oModel := MPFormModel():New("VEIA251", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VN3MASTER",/*cOwner*/ , oStrVN3)

oModel:SetDescription(STR0001) // Markups e Descontos

//oModel:InstallEvent("VEIA251LOG", /*cOwner*/, MVCLOGEV():New("VEIA251") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("VEIA251EVDEF", /*cOwner*/, VEIA251EVDEF():New() )

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 05/07/2021
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVN3:= FWFormStruct(2,"VN3")

oStrVN3:RemoveField('VN3_DATINC')
oStrVN3:RemoveField('VN3_DATALT')

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_VN3', oStrVN3, 'VN3MASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' ,100)
oView:SetOwnerView('VIEW_VN3', 'CABEC' )

oView:SetCloseOnOk({||.T.})

Return oView

/*/
{Protheus.doc} VA2510011_Desativar
Desativar o VN3 posicionado ou se passado o RECNO correspondente

@author Andre Luis Almeida
@since 05/07/2021
@type function
/*/
Function VA2510011_Desativar( nRecVN3 , lMsg )
Local cTitMsg := ""
Local oModVN3 := FWLoadModel( 'VEIA251' )
Local lRetVN3 := .f.
Local aErro   := {}
Default nRecVN3 := 0
Default lMsg    := .t.
If nRecVN3 > 0
	VN3->(DbGoTo(nRecVN3))
EndIf
If Empty(VN3->VN3_USRDES)
	If lMsg
		Do Case
			Case VN3->VN3_TIPO == "1" // Markup A VISTA
				cTitMsg := STR0005 // Deseja desativar o Markup A VISTA?
			Case VN3->VN3_TIPO == "2" // Markup A PRAZO
				cTitMsg := STR0006 // Deseja desativar o Markup A PRAZO?
			Case VN3->VN3_TIPO == "3" // Desconto
				cTitMsg := STR0007 // Deseja desativar o Desconto?
		EndCase
		cTitMsg += CHR(13)+CHR(10)+CHR(13)+CHR(10)
		cTitMsg += Transform(VN3->VN3_DATINI,"@D")+" - "+STR0008+": "+Transform(VN3->VN3_INDVLR,"@E 999.999")+" %" // Indice
	EndIf
	If !lMsg .or. MsgYesNo(cTitMsg,STR0009) // Atenção
		//
		oModVN3:SetOperation( MODEL_OPERATION_UPDATE )
		lRetVN3 := oModVN3:Activate()
		if lRetVN3
			oModVN3:LoadValue( "VN3MASTER" , "VN3_DATDES" , dDatabase )
			oModVN3:LoadValue( "VN3MASTER" , "VN3_USRDES" , __cUserID )
			oModVN3:LoadValue( "VN3MASTER" , "VN3_DATALT" , FGX_Timestamp() )
			If oModVN3:VldData()
				If oModVN3:CommitData()
				Else
					aErro := oModVN3:GetErrorMessage(.T.)
				EndIf
			Else
				aErro := oModVN3:GetErrorMessage(.T.)
			EndIf
			If len(aErro) > 0
				FMX_HELP("DESATIVAR_VALIDCOMMITVN3",;
					aErro[MODEL_MSGERR_IDFORMERR  ] + CRLF +;
					aErro[MODEL_MSGERR_IDFIELDERR ] + CRLF +;
					aErro[MODEL_MSGERR_ID         ] + CRLF +;
					aErro[MODEL_MSGERR_MESSAGE    ],;
					aErro[MODEL_MSGERR_SOLUCTION] )
			EndIf
			oModVN3:DeActivate()
		Else
			Help("",1,"ACTIVEVN3",,STR0010,1,0) // Não foi possivel ativar o modelo de alteração da tabela VN3
		EndIf
		FreeObj(oModVN3)
	EndIf
Else
	Help("",1,"DESATIVARVN3",,STR0011,1,0) // Registro já desativado.
EndIf
Return

/*/
{Protheus.doc} VA2510021_Incluir
Incluir o VN3

@author Andre Luis Almeida
@since 23/07/2021
/*/
Function VA2510021_Incluir( cMarVN3 , cModVN3 , cSegVN3 , cTipVN3 , dDatVN3 , nPerVN3 )
Local oModVN3 := FWLoadModel( 'VEIA251' )
Local lRetVN3 := .f.
Local aErro   := {}
oModVN3:SetOperation( MODEL_OPERATION_INSERT )
lRetVN3 := oModVN3:Activate()
if lRetVN3
	oModVN3:LoadValue( "VN3MASTER" , "VN3_CODMAR" , cMarVN3 )
	oModVN3:LoadValue( "VN3MASTER" , "VN3_MODVEI" , cModVN3 )
	oModVN3:LoadValue( "VN3MASTER" , "VN3_SEGMOD" , cSegVN3 )
	oModVN3:LoadValue( "VN3MASTER" , "VN3_TIPO"   , cTipVN3 )
	oModVN3:LoadValue( "VN3MASTER" , "VN3_DATINI" , dDatVN3 )
	oModVN3:LoadValue( "VN3MASTER" , "VN3_INDVLR" , nPerVN3 )
	If oModVN3:VldData()
		If oModVN3:CommitData()
		Else
			aErro := oModVN3:GetErrorMessage(.T.)
		EndIf
	Else
		aErro := oModVN3:GetErrorMessage(.T.)
	EndIf
	If len(aErro) > 0
		FMX_HELP("INCLUIR_VALIDCOMMITVN3",;
			aErro[MODEL_MSGERR_IDFORMERR  ] + CRLF +;
			aErro[MODEL_MSGERR_IDFIELDERR ] + CRLF +;
			aErro[MODEL_MSGERR_ID         ] + CRLF +;
			aErro[MODEL_MSGERR_MESSAGE    ],;
			aErro[MODEL_MSGERR_SOLUCTION] )
	EndIf
	oModVN3:DeActivate()
Else
	Help("",1,"ACTIVEVN3",,STR0010,1,0) // Não foi possivel ativar o modelo de alteração da tabela VN3
EndIf
FreeObj(oModVN3)
Return