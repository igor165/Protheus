#INCLUDE "JURA126.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA126
Cad Gênero X Usuário

@author Clovis Eduardo Teixeira
@since 29/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA126()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NWV" )
oBrowse:SetLocate()
//oBrowse:DisableDetails()
JurSetLeg( oBrowse, "NWV" )
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

@author Clovis Eduardo Teixeira
@since 29/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA126", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA126", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA126", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA126", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA126", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Gênero X Usuário

@author Clovis Eduardo Teixeira
@since 29/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA126" )
Local oStructMaster := FWFormStruct( 2, "NWV" )
Local oStructDetail := FWFormStruct( 2, "NWW" )
oStructDetail:RemoveField( "NWW_CGENER" )

JurSetAgrp( 'NWV',, oStructMaster )

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( "JURA126_VIEW", oStructMaster, "NWVMASTER"  )
oView:AddGrid ( "JURA126_GRID", oStructDetail, "NWWDETAIL"  )

oView:CreateHorizontalBox( "FORMFIELD", 20 )
oView:CreateHorizontalBox( "FORMGRID", 80 )

oView:SetOwnerView( "JURA126_VIEW", "FORMFIELD" )
oView:SetOwnerView( "JURA126_GRID", "FORMGRID" )

oView:SetDescription( STR0007 ) // "Cargo P/ Escr. Juridico"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Gênero X Usuário

@author Clovis Eduardo Teixeira
@since 29/08/12
@version 1.0

@obs NWVMASTER - Dados do Cargo P/ Escr. Juridico

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructMaster    := FWFormStruct( 1, "NWV" )
Local oStructDetail    := FWFormStruct( 1, "NWW" )
oStructDetail:RemoveField( "NWW_CGENER" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA126", /*Pre-Validacao*/, {|oX| JA126TOK(oX)}/*Pos-Validacao*/, { |oM| JA126Commit(oM)  }/*Commit*/,/*Cancel*/)
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Cargo P/ Escr. Juridico"

oModel:AddFields( "NWVMASTER", NIL, oStructMaster, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:GetModel( "NWVMASTER" ):SetDescription( STR0009 ) // "Dados de Cargo P/ Escr. Juridico"

oModel:AddGrid( "NWWDETAIL", "NWVMASTER" /*cOwner*/, oStructDetail, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NWWDETAIL" ):SetUniqueLine( { "NWW_CUSUAR" } )
oModel:SetRelation( "NWWDETAIL", { { "NWW_FILIAL", "XFILIAL('NWW')" }, { "NWW_CGENER", "NWV_COD" } }, NWW->( IndexKey( 1 ) ) )
oModel:GetModel( "NWWDETAIL" ):SetDescription( STR0010 ) //"Itens de Cad Funcao P/ Uso Cliente"

JurSetRules( oModel, 'NWVMASTER',, 'NWV' )
JurSetRules( oModel, 'NWWDETAIL',, 'NWW' )

Return oModel                    

//-------------------------------------------------------------------
/*/{Protheus.doc} JA126TOK
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Clovis Eduardo Teixeira
@since 07/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA126TOK(oModel)
Local lRet     	:= .T.
Local aArea    	:= GetArea()
Local cCliente 	:= AllTrim(oModel:GetValue("NWWDETAIL","NWW_CUSUAR")) 
Local nOpc       	:= oModel:GetOperation()   
Local lTrConc		:= SuperGetMv("MV_JTVCONC",,"2") == "1"   

If nOpc == 3 .Or. nOpc == 4

	If Empty(cCliente)
		JurMsgErro(STR0011)
		lRet := .F.
	EndIf
	
	If lRet
		If lTrConc .and. Empty( oModel:GetValue("NWVMASTER", "NWV_TIPOG") )
			JurMsgErro(STR0012)
			lRet := .F.
		Endif
	Endif	
EndIf 
                      
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA126Commit
Commit de dados de Genero

@author Rafael Rezende Costa
@since 18/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA126Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NWVMASTER","NWV_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NWV',cCod)
	EndIf

Return lRet