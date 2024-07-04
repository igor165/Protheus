#INCLUDE "JURA040.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA040
Serviços tabelados

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA040()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRD" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NRD" )
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

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA040", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA040", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA040", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA040", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA040", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Servicos Tabelados

@author David Gonçalves Fernandes
@since 30/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA040" )
Local oStructNRD := FWFormStruct( 2, "NRD" )
Local oStructNR3 := FWFormStruct( 2, "NR3" )

oStructNR3:RemoveField( "NR3_CITABE" )
oStructNR3:RemoveField( "NR3_DITABE" )

JurSetAgrp( 'NRD',, oStructNRD )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA040_NRD", oStructNRD, "NRDMASTER" )
oView:AddGrid(  "JURA040_NR3", oStructNR3, "NR3DETAIL" )
oView:CreateHorizontalBox( "NRDFIELDS", 50 )
oView:CreateHorizontalBox( "NR3GRID" , 50 )

oView:SetOwnerView( "JURA040_NRD", "NRDFIELDS" )
oView:SetOwnerView( "JURA040_NR3", "NR3GRID" )

oView:SetDescription( STR0007 ) // "Servicos Tabelados"

oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Servicos Tabelados

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0

@obs NRDMASTER - Dados do Servicos Tabelados
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel        := NIL
Local oStructNRD    := FWFormStruct( 1, "NRD" )
Local oStructNR3    := FWFormStruct( 1, "NR3" )
Local oCommit       := JA040Commit():New()

oStructNR3:RemoveField( "NR3_CITABE" )
oStructNR3:RemoveField( "NR3_DITABE" )

oModel:= MPFormModel():New( "JURA040", /*Pre-Validacao*/,{ | oX | JA040TUDOK( oX ) } /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NRDMASTER", NIL         /*cOwner*/, oStructNRD, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid  ( "NR3DETAIL", "NRDMASTER" /*cOwner*/, oStructNR3, /*bLinePre*/, /*bLinePost*/, /*bPre*/,  /*bPost*/ )

oModel:GetModel( "NR3DETAIL" ):SetUniqueLine( { "NR3_CIDIOM" } )
oModel:SetRelation( "NR3DETAIL", { { "NR3_FILIAL", "xFilial('NR3')" }, { "NR3_CITABE", "NRD_COD" } } , NR3->( IndexKey( 1 ) ) )

oModel:SetDescription( STR0008 ) // "Modelo de Dados de Servicos Tabelados"
oModel:GetModel( "NRDMASTER" ):SetDescription( STR0009 ) // "Dados de Servicos Tabelados"
oModel:GetModel( "NR3DETAIL" ):SetDescription( STR0010 ) // "Descrição do Serviço por Idioma" 

oModel:GetModel( "NR3DETAIL" ):SetDelAllLine( .F. )
oModel:SetOptional( "NR3DETAIL", .T.)

oModel:InstallEvent("JA040Commit", /*cOwner*/, oCommit)

JurSetRules( oModel, 'NRDMASTER',, 'NRD' )
JurSetRules( oModel, "NR3DETAIL",, 'NR3' )

oModel:SetActivate( { |oModel| JURADDIDIO(oModel:GetModel("NR3DETAIL"), "NR3", 1) } )

Return oModel

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA040TUDOK
Executa as rotinas ao confirmar as alteração no Model.

@author David Gonçalves Fernandes
@since 29/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA040TUDOK ( oModel )
	Local lRet      := .T.
	Local oModelNR3 := oModel:GetModel( "NR3DETAIL" )
	Local cAlias040 := ""
	Local cQuery    := ""
	Local nDeleted  := 0
	Local nLinha    := 1
	Local nAtOldNR3 := oModelNR3:nLine

	If oModel:GetOperation() <> 5
		cQuery := " SELECT COUNT(NR1.NR1_COD) COUNT "
		cQuery +=   " FROM "+RetSqlName("NR1")+" NR1 "
		cQuery +=  " WHERE NR1.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND NR1.NR1_FILIAL = '" + xFilial( "NR1" ) + "' "
		cQuery := ChangeQuery(cQuery)

		cAlias040 := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias040, .T., .T.)
	
		For nLinha := 1 To oModelNR3:GetQtdLine()
			If oModelNR3:IsDeleted( nLinha ) .Or. Empty(oModelNR3:GetValue('NR3_CIDIOM') )
				nDeleted ++
			EndIf
		Next
		
		If oModelNR3:GetQtdLine()-nDeleted < (cAlias040)->COUNT .And. (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4)
			JurMsgErro( STR0011 ) // É preciso adicionar todos os idiomas para o serviço
			lRet := .F.
		EndIf

		(cAlias040)->(DbCloseArea())
	EndIf

	//Valida se todos os campos obrigatórios da grid foram preenchidos.
	If lRet
		lRet := JurVldDesc( oModelNR3, { "NR3_DESCHO", "NR3_DESCDE", "NR3_NARRAP" } )
	EndIf

	oModelNR3:GoLine( nAtOldNR3 )
Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA040COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA040COMMIT FROM FWModelEvent
	Method New()
	Method InTTS()
End Class

Method New() Class JA040COMMIT
Return

Method InTTS(oSubModel, cModelId) Class JA040COMMIT
	JFILASINC(oSubModel:GetModel(), "NRD", "NRDMASTER", "NRD_COD")
Return
