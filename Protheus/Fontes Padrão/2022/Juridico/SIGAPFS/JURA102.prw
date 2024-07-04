#INCLUDE "JURA102.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA102
Descritivo da Parcela (Contrato Valor fixo)

@author Daniel Magalh�es
@since 26/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA102()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NXK" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NXK" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transa��o a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Altera��o sem inclus�o de registros
7 - C�pia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Daniel Magalh�es
@since 26/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA102", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA102", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA102", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA102", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA102", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados da Descri��o da Parcela

@author Daniel Magalh�es
@since 26/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  	 := FWLoadModel( "JURA102" )
Local oStructNXK := FWFormStruct( 2, "NXK" )
Local oStructNXL := FWFormStruct( 2, "NXL" )

oStructNXL:RemoveField( "NXL_CDEPAR" )
oStructNXL:RemoveField( "NXL_DESPAR" )

JurSetAgrp( 'NXK',, oStructNXK )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA102_NXK",  oStructNXK, "NXKMASTER"  )
oView:AddGrid(  "JURA102_NXL" , oStructNXL, "NXLIDIOMA"  )
oView:CreateHorizontalBox( "NXKFIELDS", 50 )
oView:CreateHorizontalBox( "NXLGRID"  , 50 )

oView:SetOwnerView( "JURA102_NXK", "NXKFIELDS" )
oView:SetOwnerView( "JURA102_NXL", "NXLGRID"   )

oView:SetDescription( STR0007 ) // "Descri��o da Parcela"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da Descri��o da Parcela

@author Daniel Magalh�es
@since 26/04/2011
@version 1.0

@obs NXKMASTER - Dados da Descri��o da Parcela

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNXK := FWFormStruct( 1, "NXK" )
Local oStructNXL := FWFormStruct( 1, "NXL" )

oStructNXL:RemoveField( "NXL_CDEPAR" )
oStructNXL:RemoveField( "NXL_DESPAR" )

//-----------------------------------------
//Monta o modelo do formul�rio
//-----------------------------------------
oModel := MPFormModel():New( "JURA102",/*Pre-Validacao*/,{ | oX | JA102TUDOK( oX ) } /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

oModel:AddFields( "NXKMASTER", Nil, oStructNXK, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid  ( "NXLIDIOMA", "NXKMASTER" /*cOwner*/, oStructNXL, /*bLinePre*/, /*bLinePost*/, /*bPre*/,  /*bPost*/ )

oModel:GetModel   ( "NXLIDIOMA" ):SetUniqueLine( { "NXL_CIDIOM" } )
oModel:SetRelation( "NXLIDIOMA", { { "NXL_FILIAL", "xFilial('NXL')" } , { "NXL_CDEPAR", "NXK_COD" } } , NXL->( IndexKey( 1 ) ) )

oModel:SetDescription( STR0008 )                         // "Modelo de Dados da Descri��o da Parcela"
oModel:GetModel( "NXKMASTER" ):SetDescription( STR0009 ) // "Dados da Descri��o da Parcela"
oModel:GetModel( "NXLIDIOMA" ):SetDescription( STR0010 ) // "Descri��o da Parcela por Idioma"

oModel:GetModel( "NXLIDIOMA" ):SetDelAllLine( .F. )

oModel:SetOptional( "NXLIDIOMA", .T.)

JurSetRules( oModel, 'NXKMASTER',, 'NXK' )
JurSetRules( oModel, "NXLIDIOMA",, 'NXL' )

oModel:SetActivate( { |oModel| JurAddIdio(oModel:GetModel("NXLIDIOMA"), "NXL") } )

Return oModel

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA102TUDOK
Executa as rotinas ao confirmar as alteracao no oModel.

@author Daniel Magalh�es
@since 26/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA102TUDOK ( oModel )
Local lRet := .T., nI
Local oModelNXL := oModel:GetModel( "NXLIDIOMA" )
Local nQtdLnNXL := oModelNXL:GetQtdLine()
Local nQtdLnNR1 := JurQtdReg('NR1')
Local nLineOld	:= oModelNXL:nLine

	if (oModel:GetOperation() == 3 .OR. oModel:GetOperation() == 4)
		
		For nI := 1 to nQtdLnNXL
			oModelNXL:GoLine(nI)
			If oModelNXL:IsDeleted() .OR. Empty(oModelNXL:GetValue("NXL_CIDIOM"))
				nQtdLnNXL--
			/*Else
				If Empty(FwFldGet("NXL_DESC"))
					lRet := .F.
					JurMsgErro(STR0012) // "� preciso incluir todas descri��es"
					Exit
				EndIf*/
			EndIf
		Next
		
		If nQtdLnNXL < nQtdLnNR1
			
			JurMsgErro( STR0011 )// � preciso incluir todos os idiomas
			lRet := .F.
			
		EndIF

	 	IIF(lRet, lRet := JurVldDesc(oModelNXL, { "NXL_DESC" } ), )

	EndIf
	oModelNXL:GoLine(nLineOld)

Return lRet