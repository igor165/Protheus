#INCLUDE "JURA039.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA039
Tipo de Atividade Time Sheet

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA039()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 ) // "Tipo de Atividade Time Sheet"
oBrowse:SetAlias( "NRC" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NRC" )
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
aAdd( aRotina, { STR0002, "VIEWDEF.JURA039", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA039", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA039", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA039", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA039", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo de Atividade Time-sheet

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA039" )
Local oStructNRC := FWFormStruct( 2, "NRC" )
Local oStructNR5 := FWFormStruct( 2, "NR5" )
Local oStructOHQ := Nil
Local lOHQInDic  := FWAliasInDic("OHQ")

If lOHQInDic
	oStructOHQ := FWFormStruct( 2, "OHQ" )
	oStructOHQ:RemoveField( "OHQ_CTATV" )
	oStructOHQ:RemoveField( "OHQ_DTATV" )
EndIf

oStructNR5:RemoveField( "NR5_CTATV" )
oStructNR5:RemoveField( "NR5_DTATV" )

JurSetAgrp( 'NRC',, oStructNRC )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA039_NRC", oStructNRC, "NRCMASTER"  )
oView:AddGrid(  "JURA039_NR5", oStructNR5, "NR5IDIOMA"  )
If lOHQInDic
	oView:AddGrid( "JURA039_OHQ", oStructOHQ, "OHQAREA"  )
	oView:CreateHorizontalBox( "NRCFIELDS", 40 )
	oView:CreateHorizontalBox( "NR5GRID", 30 )
	oView:CreateHorizontalBox( "OHQAREA", 30 )
	oView:SetOwnerView( "JURA039_OHQ", "OHQAREA" )
Else
	oView:CreateHorizontalBox( "NRCFIELDS", 50 )
	oView:CreateHorizontalBox( "NR5GRID"  , 50 )
EndIf

oView:SetOwnerView( "JURA039_NRC", "NRCFIELDS" )
oView:SetOwnerView( "JURA039_NR5", "NR5GRID" )

oView:SetDescription( STR0007 ) // "Tipo de Atividade Time Sheet"
oView:EnableControlBar( .T. )

oView:EnableTitleView( "JURA039_NR5" )
If lOHQInDic
	oView:EnableTitleView( "JURA039_OHQ" )
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo de Atividade Time-sheet

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNRC := FWFormStruct( 1, "NRC" )
Local oStructNR5 := FWFormStruct( 1, "NR5" )
Local oCommit    := JA039Commit():New()
Local oStructOHQ := Nil
Local lOHQInDic  := FWAliasInDic("OHQ")

If lOHQInDic
	oStructOHQ := FWFormStruct( 1, "OHQ" )
	oStructOHQ:RemoveField( "OHQ_CTATV" )
	oStructOHQ:RemoveField( "OHQ_DTATV" )
EndIf

oStructNR5:RemoveField( "NR5_CTATV" )
oStructNR5:RemoveField( "NR5_DTATV" )

oModel:= MPFormModel():New( "JURA039", /*Pre-Validacao*/, { | oX | JA039TUDOK( oX ) } /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NRCMASTER", NIL, oStructNRC, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid  ( "NR5IDIOMA", "NRCMASTER" /*cOwner*/, oStructNR5, /*bLinePre*/, /*bLinePost*/, /*bPre*/,  /*bPost*/ )
If lOHQInDic
	oModel:AddGrid ( "OHQAREA", "NRCMASTER" /*cOwner*/, oStructOHQ, /*bLinePre*/, /*bLinePost*/, /*bPre*/,  /*bPost*/ )
EndIf

oModel:GetModel( "NR5IDIOMA" ):SetUniqueLine( { "NR5_CIDIOM" } )
oModel:SetRelation( "NR5IDIOMA", { { "NR5_FILIAL", "xFilial('NR5')" }, { "NR5_CTATV", "NRC_COD" } }, NR5->( IndexKey( 1 ) ) )

If lOHQInDic
	oModel:GetModel( "OHQAREA" ):SetUniqueLine( { "OHQ_CAREA" } )
	oModel:SetRelation( "OHQAREA", { { "OHQ_FILIAL", "xFilial('OHQ')" }, { "OHQ_CTATV", "NRC_COD" } }, OHQ->( IndexKey( 1 ) ) )
EndIf

oModel:SetDescription( STR0008 ) // "Modelo de Dados de Tipo de Atividade Time-sheet"
oModel:GetModel( "NRCMASTER" ):SetDescription( STR0009 ) // "Dados de Tipo de Atividade Time-sheet"
oModel:GetModel( "NR5IDIOMA" ):SetDescription( STR0010 ) // "Descrição do Serviço por Idioma"
If lOHQInDic
	oModel:GetModel( "OHQAREA" ):SetDescription( STR0014 ) // "Áreas Jurídicas x Tipo de Atividade"
	oModel:GetModel( "OHQAREA" ):SetDelAllLine( .F. )
	oModel:SetOptional( "OHQAREA", .T.)
EndIf

oModel:GetModel( "NR5IDIOMA" ):SetDelAllLine( .F. )

oModel:SetOptional( "NR5IDIOMA", .T.)

oModel:InstallEvent("JA039Commit", /*cOwner*/, oCommit)

JurSetRules( oModel, 'NRCMASTER',, 'NRC' )
JurSetRules( oModel, "NR5IDIOMA",, 'NR5' )

oModel:SetActivate( { |oModel| JURADDIDIO(oModel:GetModel("NR5IDIOMA"), "NR5") } )

Return oModel

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA039TUDOK
Executa as rotinas ao confirmar as alteração no Model.

@author Felipe Bonvicini Conti
@since 05/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA039TUDOK ( oModel )
Local lRet      := .T.
Local nI        := 0
Local oModelNRC := oModel:GetModel( "NRCMASTER" )
Local oModelNR5 := oModel:GetModel( "NR5IDIOMA" )
Local nQtdLnNR5 := oModelNR5:GetQtdLine()
Local nQtdLnNR1 := JurQtdReg('NR1')
Local nLineOld  := oModelNR5:nLine

If (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4)
	
	For nI := 1 To nQtdLnNR5
		oModelNR5:GoLine(nI)
		If oModelNR5:IsDeleted() .Or. Empty(oModelNR5:GetValue("NR5_CIDIOM"))
			nQtdLnNR5--
		EndIf
	Next
	
	If nQtdLnNR5 < nQtdLnNR1
		JurMsgErro( STR0011 )// É preciso incluir todos os idiomas
		lRet := .F.
	EndIf

 	IIF(lRet, lRet := JurVldDesc(oModelNR5, { "NR5_DESC" } ), )

ElseIf oModel:GetOperation() == 5

	If !( lRet := J039VerTS(oModelNRC:GetValue("NRC_COD")) )
		JurMsgErro( STR0013 ) //"Não foi possível excluir, existem Time Sheets relacionados a este código de atividade"
	EndIf

EndIf

oModelNR5:GoLine(nLineOld)

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J039VerTS
Verifica se existem TSs amarrados ao codigo de atividade

@author Daniel Magalhaes
@since 10/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J039VerTS(cCodAtv)
Local cQuery := ""
Local cAlias := GetNextAlias()
Local lRet   := .F.

cQuery := " select COUNT(*) QTD_TS "
cQuery += " from " + RetSqlName("NUE") + " NUE "
cQuery += " where NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
cQuery +=    " and NUE.NUE_CATIVI = '" + cCodAtv + "' "
cQuery +=    " and NUE.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery, .F.)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cAlias, .T., .F. )

lRet := ( (cAlias)->QTD_TS <= 0 )

(cAlias)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA039COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA039COMMIT FROM FWModelEvent
	Method New()
	Method InTTS()
End Class

Method New() Class JA039COMMIT
Return

Method InTTS(oSubModel, cModelId) Class JA039COMMIT
	JFILASINC(oSubModel:GetModel(), "NRC", "NRCMASTER", "NRC_COD")
Return  
