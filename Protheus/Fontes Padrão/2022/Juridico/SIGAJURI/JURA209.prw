#INCLUDE "JURA209.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "FWMVCDEF.CH"
			
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA209
Anexos WorkSite

@author Antonio C Ferreira
@since 12/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA209()
Local oBrowse

J209Carga()

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 ) //"Anexos WorkSite" 
oBrowse:SetAlias( "NZH" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NZH" )
JurSetBSize( oBrowse )
	
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura

@author Antonio C Ferreira
@since 12/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA209", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA209", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA209", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA209", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA209", 0, 8, 0, NIL } ) // "Imprimir"
                                              	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de parâmetros que serão sincronizados

@author Antonio C Ferreira
@since 12/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel  := FWLoadModel( "JURA209" )
Local oStructNZH
Local oView

oStructNZH := FWFormStruct( 2, "NZH" )

JurSetAgrp( 'NZH',, oStructNZH )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "NZHMASTER", oStructNZH, "NZHMASTER"  )   
                                                   
oView:CreateHorizontalBox( "PRINCIPAL" , 100 )

oView:SetOwnerView( "NZHMASTER" , "PRINCIPAL" )

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da lista de parâmetros que serão sincronizados

@author Antonio C Ferreira
@since 06/03/14
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStructNZH := NIL
Local oModel     := NIL

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
oStructNZH := FWFormStruct(1,"NZH")

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA209", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

oModel:AddFields( "NZHMASTER", /*cOwner*/, oStructNZH,/*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:GetModel( "NZHMASTER" ):SetDescription( STR0007 ) //"Anexos WorkSite"

oModel:SetPrimaryKey( { "NZH_FILIAL", "NZH_CAMPO" } )

JurSetRules( oModel, "NZHMASTER",, 'NZH' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J209Carga
Carga Inicial dos parâmetros que devem ficar disponíveis para sincronização

@author Antonio C Ferreira
@since 20/03/14
@version 1.0

/*/
//-------------------------------------------------------------------
Function J209Carga()

Local oModelNZH  := Nil
Local aArea      := GetArea()
Local aAreaNZH   := NZH->( GetArea() )
Local aNZH       := {}
Local nCt        := 0

//Lista de parâmetros que devem ser incluídos por padrão
aAdd( aNZH, {"NRCOMMENT", "C", STR0008} ) //"Arquivo anexado via SmartClientHTML!"
aAdd( aNZH, {"NRCLASS"  , "C", "*"} )
aAdd( aNZH, {"NRCUSTOM5", "C", "*"} )

NZH->( dbSetOrder( 1 ) )

//Valida se os parâmetros já existem e inclui o restante
For nCt := 1 To Len(aNZH)
	
    If  !( NZH->(dbSeek(xFilial('NZH') + aNZH[nCt][1])) )   
		
        oModelNZH := FWLoadModel( 'JURA209' )
        oModelNZH:SetOperation( 3 )
        oModelNZH:Activate()
        oModelNZH:SetValue("NZHMASTER","NZH_CAMPO",aNZH[nCt][1])
        oModelNZH:SetValue("NZHMASTER","NZH_TIPO" ,aNZH[nCt][2])
        oModelNZH:SetValue("NZHMASTER","NZH_VALOR",aNZH[nCt][3])
		
        If  oModelNZH:VldData()
            oModelNZH:CommitData()
        EndIf
		
        oModelNZH:DeActivate()
    EndIf
Next nCt

RestArea( aAreaNZH )
RestArea(aArea)

Return Nil