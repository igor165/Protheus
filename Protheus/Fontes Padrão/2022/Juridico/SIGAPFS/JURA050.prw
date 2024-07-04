#INCLUDE "JURA050.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA050
Categoria dos participantes

@author David Gonçalves Fernandes
@since 29/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA050()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRN" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NRN" )
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
@since 29/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA050", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA050", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA050", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA050", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA050", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Categoria dos Participantes

@author David Gonçalves Fernandes
@since 30/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA050" )
Local oStructNRN := FWFormStruct( 2, "NRN" )
Local oStructNR2 := FWFormStruct( 2, "NR2" )

oStructNR2:RemoveField( "NR2_CATPAR" )
oStructNR2:RemoveField( "NR2_CATPAD" )

JurSetAgrp( 'NRN',, oStructNRN )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA050_NRN", oStructNRN, "NRNMASTER"  )
oView:AddGrid ( "JURA050_NR2", oStructNR2, "NR2DETAIL"  )
oView:CreateHorizontalBox( "NRNFIELDS", 50 )
oView:CreateHorizontalBox( "NR2GRID"  , 50 )

oView:SetOwnerView( "JURA050_NRN", "NRNFIELDS" )
oView:SetOwnerView( "JURA050_NR2", "NR2GRID" )

oView:SetDescription( STR0007 ) // "Categoria dos Participantes"

oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Categoria dos Participantes

@author David Gonçalves Fernandes
@since 29/04/09
@version 1.0

@obs NRNMASTER - Dados do Categoria dos Participantes
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNRN := FWFormStruct( 1, "NRN" )
Local oStructNR2 := FWFormStruct( 1, "NR2" )
Local oCommit    := JA050COMMIT():New()

oStructNR2:RemoveField( "NR2_CATPAR" )
oStructNR2:RemoveField( "NR2_CATPAD" )

oModel:= MPFormModel():New( "JURA050", /*Pre-Validacao*/,{ | oX | JA050TUDOK( oX ) } /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NRNMASTER", NIL         /*cOwner*/, oStructNRN, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid  ( "NR2DETAIL", "NRNMASTER" /*cOwner*/, oStructNR2, /*bLinePre*/, /*bLinePost*/, /*bPre*/,  /*bPost*/ )

oModel:GetModel( "NR2DETAIL" ):SetUniqueLine( { "NR2_CIDIOM" } )
oModel:SetRelation( "NR2DETAIL", { { "NR2_FILIAL", "xFilial('NR2')" } , { "NR2_CATPAR", "NRN_COD" } } , NR2->( IndexKey( 1 ) ) )

oModel:SetDescription( STR0008 ) // "Modelo de Dados de Categoria dos Participantes"
oModel:GetModel( "NRNMASTER" ):SetDescription( STR0009 ) // "Dados de Categoria dos Participantes"
oModel:GetModel( "NRNMASTER" ):SetDescription( STR0010 ) // "Descrição dos Serviços por Idioma"

oModel:GetModel( "NR2DETAIL" ):SetDelAllLine( .F. )

oModel:SetOptional( "NR2DETAIL", .T.)

oModel:InstallEvent("JA050COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, "NRNMASTER",, "NRN" )
JurSetRules( oModel, "NR2DETAIL",, "NR2" )

oModel:SetActivate( { |oModel| JURADDIDIO(oModel:GetModel("NR2DETAIL"), "NR2") } )

Return oModel

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA050TUDOK
Executa as rotinas ao confirmar as alteração no Model.

@author David Gonçalves Fernandes
@since 30/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA050TUDOK ( oModel )
Local lRet      := .T.
Local oModelNR2 := oModel:GetModel( "NR2DETAIL" )
Local cAlias050 := ""
Local cQuery    := ""
Local nDeleted  := 0
Local nLinha    := 1
Local nAtOldNR2 := oModelNR2:nLine

If oModel:GetOperation() <> 5
	cQuery := " SELECT COUNT(NR1.NR1_COD) COUNT "
	cQuery +=   " FROM " + RetSqlName("NR1") + " NR1 "
	cQuery +=  " WHERE NR1.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NR1.NR1_FILIAL = '" + xFilial( "NR1" ) + "' "

	cQuery := ChangeQuery(cQuery)

	cAlias050 := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias050, .T., .T.)

	For nLinha := 1 To oModelNR2:GetQtdLine()
		If oModelNR2:IsDeleted( nLinha ) .Or. Empty(oModelNR2:GetValue('NR2_CIDIOM') )
			nDeleted ++
		EndIf
	Next

	If oModelNR2:GetQtdLine()-nDeleted < (cAlias050)->COUNT .And. (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4)
		JurMsgErro( STR0011 ) // É preciso adicionar todos os idiomas para a categoria
		lRet := .F.
	EndIf

	//Verifica preenchimento de todas as descrições
	If lRet
		lRet := JurVldDesc(oModelNR2, { "NR2_DESC" } )
	EndIf

	// Valida participantes ativos antes de inativar
	If lRet .And. FWFldGet("NRN_ATIVO") == "2"
		lRet := JurVPartAtiv(FwFldGet("NRN_COD"))
	EndIf

	(cAlias050)->(dbCloseArea())
EndIf

oModelNR2:GoLine( nAtOldNR2 )
Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JurVPartAtiv
Valida a existencia de participantes ativos para a categoria

@author TOTVS
@since 30/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurVPartAtiv(cCodCateg)
Local lRet      := .T.
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()

BeginSql Alias cAliasQry
	SELECT COUNT(*) QTD
	FROM
		%Table:NUR% NUR 
		INNER JOIN %Table:RD0% RD0 
			ON RD0.RD0_FILIAL  = %xFilial:RD0%
			AND RD0.RD0_CODIGO = NUR.NUR_CPART 
			AND RD0.RD0_MSBLQL = '2'
			AND RD0.%NotDEL%
	WHERE
		NUR.NUR_FILIAL   = %xFilial:NUR%
		AND NUR.NUR_CCAT = %Exp:cCodCateg%
		AND NUR.%NotDEL% 

EndSql
dbSelectArea(cAliasQry)

cRet := (cAliasQry)->QTD

(cAliasQry)->(dbCloseArea())
RestArea(aArea)

If cRet > 0
	lRet := .F.
	JurMsgErro( STR0012 ) // "Não é possível desativar essa categoria, pois existe participante(s) vinculado(s)!"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA050COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Cristina Cintra Santos
@since 18/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA050COMMIT FROM FWModelEvent
	Method New()
	Method InTTS()
End Class

Method New() Class JA050COMMIT
Return

Method InTTS(oSubModel, cModelId) Class JA050COMMIT
	JFILASINC(oSubModel:GetModel(), "NRN", "NRNMASTER", "NRN_COD")
Return

//-------------------------------------------------------------------
/*/ { Protheus.doc } J050ValNat
Função que valida a Natureza
@param cCodCpo - Código do Campo
@return lRet  - Retund do campo
@author fabiana.silva
@since 28/10/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function J050ValNat(cCodCpo)
Local lRet := .T.
Local cCpo := ""

cCpo := &("M->"+ cCodCpo)

lRet := ExistCpo( "SED", cCpo , 01 )

Return lRet
