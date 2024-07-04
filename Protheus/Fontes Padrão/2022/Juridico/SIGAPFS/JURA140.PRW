#INCLUDE "JURA140.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA140
Cadastro de Motivo de W0

@author Luciano Pereira dos Santos
@since 25/09/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA140()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NXV" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NXV" )
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

@author Luciano Pereira dos Santos
@since 25/09/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA140", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA140", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA140", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA140", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA140", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Motivo de W0

@author Luciano Pereira dos Santos
@since 25/09/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA140" )
Local oStruct := FWFormStruct( 2, "NXV" )

JurSetAgrp( 'NXV',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA140_VIEW", oStruct, "NXVMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA140_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Motivo de WO"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Motivo de W0

@author Luciano Pereira dos Santos
@since 25/09/12
@version 1.0

@obs NVXMASTER - Dados do Motivo de WO

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NXV" )
Local oCommit    := JA140COMMIT():New()

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA140",  /*Pre-Validacao*/, {|oX| J140TUDOK(oX) }, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NXVMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Motivo de WO"
oModel:GetModel( "NXVMASTER" ):SetDescription( STR0009 ) // "Dados de Motivo de WO"

oModel:InstallEvent("JA140COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, 'NXVMASTER',, 'NXV' )

Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} J140TUDOK
Rotina de validação para o modelo de dados "NXVMASTER".

@author Luciano Pereira dos Santos
@since 26/09/12
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function J140TUDOK(oModel)
Local lRet 		  := .T.
Local oModelNXV := oModel:GetModel("NXVMASTER")
Local cCodigo 	:= oModelNXV:GetValue("NXV_COD")
Local cQry 		  := ""
Local aSQL		  := {}

	If oModel:GetOperation() == 5

		cQry += " SELECT COUNT(NUF.R_E_C_N_O_) QTD " + CRLF
		cQry += " FROM "+RetSqlName( "NUF" )+" NUF " + CRLF
		cQry +=   " WHERE NUF.NUF_FILIAL = '"+xFilial("NUF")+"' " + CRLF
		cQry +=    " AND (NUF.NUF_CMOTEM = '"+cCodigo+"' " + CRLF
		cQry +=          " OR NUF.NUF_CMOTCA = '"+cCodigo+"') " + CRLF
		cQry +=    " AND NUF.D_E_L_E_T_ = ' ' " + CRLF

		aSQL := JurSQL(cQry, "QTD")

		If !Empty(aSQL)
			If aSQL[1][1] > 0
				JurMsgErro(STR0011)	// "O Motivo de WO não pode ser excluído pois existem registros associados!"
				lRet := .F.
			EndIf
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA140COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Jorge Luis Branco Martins Junior
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA140COMMIT FROM FWModelEvent
    Method New()
    Method InTTS()
End Class

Method New() Class JA140COMMIT
Return

Method InTTS(oModel, cModelId) Class JA140COMMIT
	JFILASINC(oModel:GetModel(), "NXV", "NXVMASTER", "NXV_COD")
Return 