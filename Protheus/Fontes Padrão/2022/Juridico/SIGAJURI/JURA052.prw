#INCLUDE "JURA052.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA052
Cad Cargo p/ uso Cliente

@author Raphael Zei Cartaxo Silva
@since 04/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA052()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRP" )
oBrowse:SetLocate()
//oBrowse:DisableDetails()
JurSetLeg( oBrowse, "NRP" )
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
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Raphael Zei Cartaxo Silva
@since 04/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA052", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA052", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA052", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA052", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA052", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Cargo P/ Escr. Juridico

@author Raphael Zei Cartaxo Silva
@since 04/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA052" )
Local oStructMaster := FWFormStruct( 2, "NRP" )
Local oStructDetail := FWFormStruct( 2, "NU0" )
oStructDetail:RemoveField( "NU0_CCARGO" )

JurSetAgrp( 'NRP',, oStructMaster )

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( "JURA052_VIEW", oStructMaster, "NRPMASTER"  )
oView:AddGrid ( "JURA052_GRID", oStructDetail, "NU0DETAIL"  )

oView:CreateHorizontalBox( "FORMFIELD", 20 )
oView:CreateHorizontalBox( "FORMGRID", 80 )

oView:SetOwnerView( "JURA052_VIEW", "FORMFIELD" )
oView:SetOwnerView( "JURA052_GRID", "FORMGRID" )

oView:SetDescription( STR0007 ) // "Cargo P/ Escr. Juridico"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Cargo P/ Escr. Juridico

@author Raphael Zei Cartaxo Silva
@since 04/05/09
@version 1.0

@obs NRPMASTER - Dados do Cargo P/ Escr. Juridico

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructMaster    := FWFormStruct( 1, "NRP" )
Local oStructDetail    := FWFormStruct( 1, "NU0" )
oStructDetail:RemoveField( "NU0_CCARGO" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA052", /*Pre-Validacao*/, {|oX| JA052TOK(oX)}/*Pos-Validacao*/, { |oX| JA052Commit(oX) }/*Commit*/,/*Cancel*/)
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Cargo P/ Escr. Juridico"

oModel:AddFields( "NRPMASTER", NIL, oStructMaster, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:GetModel( "NRPMASTER" ):SetDescription( STR0009 ) // "Dados de Cargo P/ Escr. Juridico"

oModel:AddGrid( "NU0DETAIL", "NRPMASTER" /*cOwner*/, oStructDetail, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NU0DETAIL" ):SetUniqueLine( { "NU0_CCLIEN","NU0_CLOJA" } )
oModel:SetRelation( "NU0DETAIL", { { "NU0_FILIAL", "XFILIAL('NU0')" }, { "NU0_CCARGO", "NRP_COD" } }, NU0->( IndexKey( 1 ) ) )
oModel:GetModel( "NU0DETAIL" ):SetDescription( STR0010 ) //"Itens de Cad Funcao P/ Uso Cliente"

JurSetRules( oModel, 'NRPMASTER',, 'NRP' )
JurSetRules( oModel, 'NU0DETAIL',, 'NU0' )

Return oModel                    

//-------------------------------------------------------------------
/*/{Protheus.doc} JA052TOK
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 07/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA052TOK(oModel)
Local lRet     := .T.
Local aArea    := GetArea()
Local cCliente := AllTrim(oModel:GetValue("NU0DETAIL","NU0_CCLIEN")) 
Local nOpc     := oModel:GetOperation()     

If nOpc == 3 .Or. nOpc == 4

	If Empty(cCliente)
		JurMsgErro(STR0011)
		lRet := .F.
	EndIf	
	
EndIf 
                      
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA052Commit
Commit de dados de Cargo

@author Rafael Rezende Costa
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA052Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NRPMASTER","NRP_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NRP',cCod)
	EndIf

Return lRet