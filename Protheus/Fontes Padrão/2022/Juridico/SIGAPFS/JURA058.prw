#INCLUDE "JURA058.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA058
Empresas de E-billing

@author David Gonçalves Fernandes
@since 07/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA058()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRX" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NRX" )
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
@since 07/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA058", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA058", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA058", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA058", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA058", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Empresas de E-billing

@author David Gonçalves Fernandes
@since 07/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA058" )
Local oStructNRX := FWFormStruct( 2, "NRX" )
Local oStructNTQ := FWFormStruct( 2, "NTQ" )

oStructNTQ:RemoveField("NTQ_CEMP")

JurSetAgrp( 'NRX',, oStructNRX )
JurSetAgrp( 'NTQ',, oStructNTQ )

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( "JURA058_VIEW", oStructNRX, "NRXMASTER"  )
oView:AddGrid(  "JURA058_GRID", oStructNTQ, "NTQDETAIL"  )

oView:CreateHorizontalBox( "FORMFIELD", 50 )
oView:CreateHorizontalBox( "FORMGRID", 50 )

oView:SetOwnerView( "JURA058_VIEW", "FORMFIELD" )
oView:SetOwnerView( "JURA058_GRID", "FORMGRID" )

oView:SetDescription( STR0007 ) // "Empresas de E-billing"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Empresas de E-billing

@author David Gonçalves Fernandes
@since 07/05/09
@version 1.0

@obs NRXMASTER - Dados do Empresas de E-billing

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel        := NIL
Local oStructNRX    := FWFormStruct( 1, "NRX" )
Local oStructNTQ    := FWFormStruct( 1, "NTQ" )
Local oCommit       := JA058COMMIT():New()

oStructNTQ:RemoveField("NTQ_CEMP")
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA058", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NRXMASTER", NIL,         oStructNRX, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid(   "NTQDETAIL", "NRXMASTER", oStructNTQ, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Empresas de E-billing"

oModel:SetRelation( "NTQDETAIL", { { "NTQ_FILIAL", "xFilial('NTQ')" } , { "NTQ_CEMP"   , "NRX_COD" } } , NTQ->( IndexKey( 1 ) ) )

oModel:GetModel( "NRXMASTER" ):SetDescription( STR0010 ) // "Dados de Empresas de E-billing"
oModel:GetModel( "NTQDETAIL" ):SetDescription( STR0009 ) // "Dados de Escritório de E-billing"

oModel:GetModel( "NTQDETAIL" ):SetUniqueLine( { "NTQ_CESCR" } )
oModel:GetModel( "NTQDETAIL" ):SetDelAllLine( .T. )

oModel:SetOptional( "NTQDETAIL", .T.)

oModel:InstallEvent("JA058COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, 'NRXMASTER',, 'NRX' )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} J058ValdCl()
Validação para alteração do código de Empresa de E-billing já utilizada
em um cadastro de cliente.

@author Luciano Pereira dos Santos
@since 14/06/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J058ValdCl()
Local lRet    := .T.
Local aArea   := GetArea()
Local cCodEmp := NRX->NRX_COD
Local cResQRY := ""
Local cQuery  := ""

If ALTERA
	cQuery := " SELECT COUNT(NUH.R_E_C_N_O_) RECNO "
	cQuery +=   " FROM "+RetSqlName("NUH")+" NUH "
	cQuery +=  " WHERE NUH.NUH_FILIAL = '" + xFilial('NUH') +"' "
	cQuery +=    " AND NUH.NUH_CEMP = '" + cCodEmp +"' "
	cQuery +=    " AND NUH.D_E_L_E_T_ = ' '"

	cQuery  := ChangeQuery(cQuery ,.F.)
	cResQRY := GetNextAlias()

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cResQRY,.T.,.T.)

	If (cResQRY)->RECNO > 0
		JurMsgErro(STR0011,, STR0012) //#"O código de empresa e-billing esta em uso no cadastro de cliente e não pode ser alterado." ##// "Antes de alterar o código, remova o seu vínculo no cadastro de cliente."
		lRet := .F.
	EndIf

	(cResQRY)->(DbCloseArea())
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA058COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Jorge Luis Branco Martins Junior
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA058COMMIT FROM FWModelEvent
    Method New()
    Method InTTS()
End Class

Method New() Class JA058COMMIT
Return

Method InTTS(oModel, cModelId) Class JA058COMMIT
	JFILASINC(oModel:GetModel(), "NRX", "NRXMASTER", "NRX_COD")
Return 
