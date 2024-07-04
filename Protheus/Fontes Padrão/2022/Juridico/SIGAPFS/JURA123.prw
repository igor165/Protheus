#INCLUDE "JURA123.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA123
Localidade Esc p/ Cliente

@author David Gonçalves Fernandes
@since 05/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA123()
Local cLojaAuto  := SuperGetMv("MV_JLOJAUT" , .F. , "2" , ) // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local oBrowse    := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )  // "Localidade Esc p/ Cliente" 
oBrowse:SetAlias( "NTP" )
Iif(cLojaAuto == "1" .And. FindFunction("JurBrwRev"), JurBrwRev(oBrowse, "NTP", {"NTP_CLOJA"}),)
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NTP" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return Nil

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
@since 05/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA123", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA123", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA123", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA123", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Localidade Esc p/ Cliente

@author David Gonçalves Fernandes
@since 05/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA123" )
Local oStruct    := FWFormStruct( 2, "NTP" )
Local cLojaAuto  := SuperGetMv("MV_JLOJAUT" , .F. , "2" ,) // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

JurSetAgrp( 'NTP',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
If (cLojaAuto == "1")
	oStruct:RemoveField( "NTP_CLOJA" )
EndIf
oView:AddField( "JURA123_VIEW", oStruct, "NTPMASTER" )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA123_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Localidade Esc p/ Cliente"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Localidade Esc p/ Cliente

@author David Gonçalves Fernandes
@since 05/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NTP" )
Local oCommit    := JA123COMMIT():New()

oModel:= MPFormModel():New( "JURA123", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NTPMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Localidade Esc p/ Cliente"
oModel:GetModel( "NTPMASTER" ):SetDescription( STR0009 ) // "Dados de Localidade Esc p/ Cliente"

oModel:InstallEvent("JA123COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, "NTPMASTER",, "NTP",, "JURA123" )

Return oModel

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA123COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Jorge Luis Branco Martins Junior
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA123COMMIT FROM FWModelEvent
    Method New()
    Method InTTS()
End Class

Method New() Class JA123COMMIT
Return

Method InTTS(oModel, cModelId) Class JA123COMMIT
	JFILASINC(oModel:GetModel(), "NTP", "NTPMASTER", "NTP_COD")
Return 
