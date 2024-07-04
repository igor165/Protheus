#INCLUDE "JURA264.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA264
Projetos/Finalidades

@author Abner Fogaça de Oliveira
@since 13/06/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA264()
Private oBrowse  := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetMenuDef('JURA264')
oBrowse:SetDescription( STR0001 ) // "Projetos/Finalidades"
oBrowse:SetAlias( "OHL" )

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

@author Abner Fogaça de Oliveira
@since 13/06/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina   := {}
Local lContOrc  := SuperGetMv( "MV_JCONORC" , .F. , .F. ,  ) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)

aAdd( aRotina, { STR0002, "VIEWDEF.JURA264", 0, 2, 0, NIL } ) // "Visualizar"
If !lContOrc
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA264", 0, 3, 0, NIL } ) // "Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA264", 0, 4, 0, NIL } ) // "Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA264", 0, 5, 0, NIL } ) // "Excluir"
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados Projetos/Finalidades

@author Abner Fogaça de Oliveira
@since 13/06/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructOHL := FWFormStruct( 1, "OHL" )
Local oStructOHM := FWFormStruct( 1, "OHM" )
Local oCommit    := JA264COMMIT():New()

oModel:= MPFormModel():New( "JURA264", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "OHLMASTER", NIL, oStructOHL, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid( "OHMDETAIL", "OHLMASTER" /*cOwner*/, oStructOHM,  /*bLinePre*/, {|oX| J264VldCdLD(oX)} /*bLinePost*/, /*bPre*/, /*bPost*/ )

oModel:GetModel( "OHMDETAIL" ):SetUniqueLine( { "OHM_CPROJE", "OHM_ITEM" } )
oModel:SetRelation( "OHMDETAIL", { { "OHM_FILIAL", "XFILIAL('OHM')" }, { "OHM_CPROJE", "OHL_CPROJE" } }, OHM->( IndexKey( 1 ) ) )

oModel:SetDescription( STR0006 ) // "Modelo de Dados Projetos/Finalidades"
oModel:GetModel( "OHLMASTER" ):SetDescription( STR0007 ) // "Dados Projetos/Finalidades"

oModel:InstallEvent("JA264COMMIT", /*cOwner*/, oCommit)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados Projetos/Finalidades

@author Abner Fogaça de Oliveira
@since 13/06/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView        := Nil
Local oModel       := FWLoadModel( "JURA264" )
Local oStructOHL   := FWFormStruct( 2, "OHL" )
Local oStructOHM   := FWFormStruct( 2, "OHM" )

oStructOHM:RemoveField("OHM_CPROJE")

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA264_OHL", oStructOHL, "OHLMASTER" )
oView:AddGrid(  "JURA264_OHM", oStructOHM, "OHMDETAIL" )

If OHL->(FieldPos("OHL_CODLD")) > 0
	oStructOHL:RemoveField('OHL_CODLD')
	oStructOHM:RemoveField('OHM_CODLD')
EndIf

oView:CreateHorizontalBox( "OHL_MASTER", 30,,,, )
oView:CreateHorizontalBox( "OHM_DETAIL", 70,,,, )

oView:SetOwnerView( "JURA264_OHL", "OHL_MASTER" )
oView:SetOwnerView( "JURA264_OHM", "OHM_DETAIL" )

oView:SetDescription( STR0001 ) // "Projetos/Finalidades"
oView:EnableTitleView("JURA264_OHM") // "Itens do Projeto"

Return oView

//-------------------------------------------------------------------
/*/ { Protheus.doc } J246InTTS
Execução após a gravação dos registros no processo de commit do modelo.

@author Abner Fogaça de Oliveira
@since 13/06/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J264InTTS(oModel)
Local cProjeto := oModel:GetValue("OHLMASTER", "OHL_CPROJE")

	J170GRAVA(oModel, xFilial('OHM') + cProjeto)

Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA264COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Abner Fogaça de Oliveira
@since 13/06/18
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA264COMMIT FROM FWModelEvent
	Method New()
	Method InTTS()
	Method ModelPosVld()
End Class

Method New() Class JA264COMMIT
Return

Method InTTS(oSubModel, cModelId) Class JA264COMMIT
	J264InTTS(oSubModel:GetModel())
Return

Method ModelPosVld(oModel, cModelId) Class JA264COMMIT
Local lRet       := .T.
Local lIsRest    := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))
Local nOperation := oModel:GetOperation()

If lIsRest .And. nOperation == 3 .And. OHL->(FieldPos( "OHL_CODLD" )) > 0 .And. FindFunction("JurMsgCdLD")
	lRet := JurMsgCdLD(oModel:GetValue("OHLMASTER", "OHL_CODLD"))
EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J264VldCdLD
Valida o preenchimento do Código LD quando a linha estiver sendo
inserida e for chamada REST.

@param  oGrid  Objeto com os dados dos Itens do Projeto

@return lRet   .T./.F. As informações são válidas ou não

@author Cristina Cintra
@since 11/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J264VldCdLD(oGrid)
Local lRet       := .T.
Local lIsRest    := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))

If lIsRest .And. OHM->(FieldPos( "OHM_CODLD" )) > 0 .And. FindFunction("JurMsgCdLD") .And. oGrid:IsInserted()
	lRet := JurMsgCdLD(oGrid:GetValue("OHM_CODLD"))
EndIf

Return lRet
