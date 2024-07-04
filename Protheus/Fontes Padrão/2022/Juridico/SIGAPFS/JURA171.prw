#INCLUDE "JURA171.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "FWMVCDEF.CH"
			
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA171
Parâmetros para sincronização

@author André Spirigoni Pinto
@since 12/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA171()
Local oBrowse
Local lRet := (SuperGetMV("MV_JFSINC",.F.,'2') == '2')

//Valida se a integração com o Legal Desk está ativada antes de abrir a tela
If lRet
	JurMsgErro(STR0008) //"O parâmetro MV_JFSINC deve ser configurado para abrir a fila de integração."
Else

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 )
	oBrowse:SetAlias( "NYR" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "NYR" )
	JurSetBSize( oBrowse )
	
	oBrowse:Activate()
	
	J171Carga()
Endif

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura

@author André Spirigoni Pinto
@since 12/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA171", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA171", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA171", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA171", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA171", 0, 8, 0, NIL } ) // "Imprimir"
                                              	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de parâmetros que serão sincronizados

@author André Spirigoni Pinto
@since 12/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel  := FWLoadModel( "JURA171" )
Local oStructNYR
Local oView

oStructNYR := FWFormStruct( 2, "NYR" )

JurSetAgrp( 'NYR',, oStructNYR )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "NYRMASTER", oStructNYR, "NYRMASTER"  )   
                                                   
oView:CreateHorizontalBox( "PRINCIPAL" , 100 )

oView:SetOwnerView( "NYRMASTER" , "PRINCIPAL" )

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da lista de parâmetros que serão sincronizados

@author André Spirigoni Pinto
@since 06/03/14
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStructNYR := NIL
Local oModel     := NIL

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
oStructNYR := FWFormStruct(1,"NYR")

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA171", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

oModel:AddFields( "NYRMASTER", /*cOwner*/, oStructNYR,/*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:GetModel( "NYRMASTER" ):SetDescription( STR0007 ) //"Parâmetros para sincronização"

JurSetRules( oModel, "NYRMASTER",, 'NYR' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J171PConte
Retorna o conteúdo do parâmetro

@author André Spirigoni Pinto
@since 10/03/14
@version 1.0

/*/
//-------------------------------------------------------------------
Function J171PConte(cParam)
Local cRet := ''

cRet := SuperGetMv(cParam,.F.,'-')

If valtype(cRet) != 'C'
	cRet := AllTrim(cValToChar(cRet))
Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J171PDesc
Retorna a descrição do parâmetro

@author André Spirigoni Pinto
@since 12/03/14
@version 1.0

/*/
//-------------------------------------------------------------------
Function J171PDesc(cParam)
Local cRet := ''
Local aArea := GetArea()

dbSelectArea("SX6")
dbSetOrder(1)

If dbSeek( xFilial("SX6")+cParam )
	cRet := AllTrim(X6Descric()) + AllTrim(X6Desc1()) + AllTrim(X6Desc2())
EndIf

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J171PTipo
Retorna o tipo do parâmetro

@author André Spirigoni Pinto
@since 12/03/14
@version 1.0

/*/
//-------------------------------------------------------------------
Function J171PTipo(cParam)
Local cRet      := ''

	If GetMv(cParam, .T.)
		cRet :=  ValType(GetMv(cParam))
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J171Carga
Carga Inicial dos parâmetros que devem ficar disponíveis para sincronização

@author André Spirigoni Pinto
@since 20/03/14
@version 1.0

/*/
//-------------------------------------------------------------------
Function J171Carga()
Local lRet := .T.
Local oModelNYR
Local aArea := GetArea()
Local aAreaNYR := NYR->( GetArea() )
Local aNYR := {}
Local nCt := 0

//Lista de parâmetros que devem ser incluídos por padrão
aAdd( aNYR, "MV_JURTS1" )
aAdd( aNYR, "MV_JURTS2" )
aAdd( aNYR, "MV_JURTS3" )
aAdd( aNYR, "MV_JURTS4" )
aAdd( aNYR, "MV_JURTS5" )
aAdd( aNYR, "MV_JURTS6" )
aAdd( aNYR, "MV_JLANC1" )
aAdd( aNYR, "MV_JCOBDSP" )
aAdd( aNYR, "MV_JDESCMX" )
aAdd( aNYR, "MV_JCPGINT" )
aAdd( aNYR, "MV_JCPGNAC" )
aAdd( aNYR, "MV_JTSNCOB" )

//Valida se os parâmetros já existem e inclui o restante
For nCt := 1 To Len(aNYR)
	NYR->( dbSetOrder( 1 ) )
	
	If !NYR->( dbSeek( xFilial( 'NYR' ) + aNYR[nCt] ) )   
		
		oModelNYR := FWLoadModel( 'JURA171' )
		oModelNYR:SetOperation( 3 )
		oModelNYR:Activate()
		oModelNYR:SetValue("NYRMASTER","NYR_PARAM",aNYR[nCt])
		
		If oModelNYR:VldData()
			oModelNYR:CommitData()
		Else
			lRet := .F.	
		Endif
		
		oModelNYR:DeActivate()
	EndIf
Next

RestArea( aAreaNYR )
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J171PVld
Valida se o parâmetro existe

@author André Spirigoni Pinto
@since 06/06/14
@version 1.0

/*/
//-------------------------------------------------------------------
Function J171PVld(cParam)
Local lRet := .F.
Local aArea := GetArea()

dbSelectArea("SX6")
dbSetOrder(1)

If dbSeek( xFilial("SX6")+cParam )   
	lRet := .T.
EndIf

RestArea(aArea)

Return lRet