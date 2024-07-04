#INCLUDE "JURA056.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA056
Junção de Contratos.

@author Fabio Crespo Arruda
@since 16/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA056()
Local cLojaAuto :=  SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local oBrowse   := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NW2" )
Iif(cLojaAuto == "1" .And. FindFunction("JurBrwRev"), JurBrwRev(oBrowse, "NW2", {"NW2_CLOJA"}), ) //Proteção
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NW2" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
            [n,1] Nome a aparecer no cabecalho
            [[n,2] Nome da Rotina associada
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

@author Fabio Crespo Arruda
@since 16/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA056", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA056", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA056", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA056", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Juncao de Contratos

@author Fabio Crespo Arruda
@since 16/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA056" )
Local oStructNW2 := FWFormStruct( 2, "NW2" )
Local oStructNW3 := FWFormStruct( 2, "NW3" )
Local oStructNUT := FWFormStruct( 2, "NUT" )
Local oStructNXP := FWFormStruct( 2, "NXP" )
Local oStructNVN := FWFormStruct( 2, "NVN" )
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

If (cLojaAuto == "1")
	oStructNUT:RemoveField( "NUT_CLOJA" )
	oStructNW2:RemoveField( "NW2_CLOJA" )
EndIf
oStructNW2:RemoveField( "NW2_CPART" )
oStructNW3:RemoveField( "NW3_CJCONT" )

oStructNXP:RemoveField( "NXP_COD" )
oStructNXP:RemoveField( "NXP_CJCONT" )
oStructNXP:RemoveField( "NXP_CCONTR" )

oStructNVN:RemoveField( "NVN_CJCONT" )
oStructNVN:RemoveField( "NVN_CCONTR" )
oStructNVN:RemoveField( "NVN_CLIPG"  )
oStructNVN:RemoveField( "NVN_LOJPG"  )
oStructNVN:RemoveField( "NVN_CPREFT"  )
oStructNVN:RemoveField( "NVN_CFATAD"  )
oStructNVN:RemoveField( 'NVN_CFIXO' )
oStructNVN:RemoveField( 'NVN_CFILA' )
oStructNVN:RemoveField( 'NVN_CESCR' )
oStructNVN:RemoveField( 'NVN_CFATUR' )

JurSetAgrp( "NW2",, oStructNW2 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA056_NW2", oStructNW2, "NW2MASTER" )
oView:AddGrid(  "JURA056_NW3", oStructNW3, "NW3DETAIL" )
oView:AddGrid(  "JURA056_NUT", oStructNUT, "NUTDETAIL" )
oView:AddGrid(  "JURA056_NXP", oStructNXP, "NXPDETAIL" )
oView:AddGrid(  "JURA056_NVN", oStructNVN, "NVNDETAIL" )

oView:CreateFolder('FOLDER_01')
oView:AddSheet('FOLDER_01', 'ABA_01', STR0007 ) //"Junção contratos"
oView:AddSheet('FOLDER_01', 'ABA_02', STR0028 ) //"Pagadores"

oView:CreateHorizontalBox('BOX_NW2', 40,,, 'FOLDER_01', 'ABA_01')
oView:CreateHorizontalBox('BOX_NW3', 30,,, 'FOLDER_01', 'ABA_01')
oView:CreateHorizontalBox('BOX_NUT', 30,,, 'FOLDER_01', 'ABA_01')
oView:CreateHorizontalBox('BOX_NXP', 50,,, 'FOLDER_01', 'ABA_02')
oView:CreateHorizontalBox('BOX_NVN', 50,,, 'FOLDER_01', 'ABA_02')

oView:SetOwnerView( "JURA056_NW2", "BOX_NW2" )
oView:SetOwnerView( "JURA056_NW3", "BOX_NW3" )
oView:SetOwnerView( "JURA056_NUT", "BOX_NUT" )
oView:SetOwnerView( "JURA056_NXP", "BOX_NXP" )
oView:SetOwnerView( "JURA056_NVN", "BOX_NVN" )

oView:AddIncrementField( "NVNDETAIL", "NVN_COD" )

oView:SetDescription( STR0007 ) // "Juncao de Contratos"
oView:EnableControlBar( .T. )

oView:EnableTitleView( "JURA056_NW3" )
oView:EnableTitleView( "JURA056_NUT" )
oView:EnableTitleView( "JURA056_NVN" )

oView:SetCloseOnOk({|| .F.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Juncao de Contratos.

@author Fabio Crespo Arruda
@since 16/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNW2 := FWFormStruct( 1, "NW2" )
Local oStructNW3 := FWFormStruct( 1, "NW3" )
Local oStructNUT := FWFormStruct( 1, "NUT" )
Local oStructNXP := FWFormStruct( 1, "NXP" )
Local oStructNVN := FWFormStruct( 1, "NVN" )

oStructNUT:SetProperty( '*', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, '.T.' ) )

oModel:= MPFormModel():New( "JURA056", /*Pre-Validacao*/, { |oX| J056TUDOK(oX) }/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NW2MASTER", NIL, oStructNW2, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid( "NW3DETAIL", "NW2MASTER" /*cOwner*/, oStructNW3, /*bLinePre*/, {|oModel|JU056VG()}/*bLinePost*/, /*bPre*/,  /*bPost*/ )
oModel:AddGrid( "NUTDETAIL", "NW3DETAIL" /*cOwner*/, oStructNUT, /*bLinePre*/, /*bLinePost*/, /*bPre*/,  /*bPost*/ )
oModel:AddGrid( "NXPDETAIL", "NW2MASTER" /*cOwner*/, oStructNXP, /*bLinePre*/, /*bLinePost*/, /*bPre*/,  /*bPost*/ )
oModel:AddGrid( "NVNDETAIL", "NXPDETAIL" /*cOwner*/, oStructNVN, /*bLinePre*/, /*bLinePost*/, /*bPre*/,  /*bPost*/ )

oModel:GetModel( "NW3DETAIL" ):SetUniqueLine( { "NW3_CCONTR" } )
oModel:GetModel( "NXPDETAIL" ):SetUniqueLine( { "NXP_CLIPG", "NXP_LOJAPG" } )
oModel:GetModel( "NVNDETAIL" ):SetUniqueLine( { "NVN_CCONT"} )

oModel:SetRelation( "NW3DETAIL", {{ "NW3_FILIAL", "xFilial('NW3')" }, {"NW3_CJCONT","NW2_COD"}}   , NW3->( IndexKey( 1 ) ) )
oModel:SetRelation( "NUTDETAIL", {{ "NUT_FILIAL", "xFilial('NUT')" }, {"NUT_CCONTR","NW3_CCONTR"}}, NUT->( IndexKey( 1 ) ) )
oModel:SetRelation( "NXPDETAIL", {{ "NXP_FILIAL", "xFilial('NXP')" }, {"NXP_CJCONT","NW2_COD"}}   , NXP->( IndexKey( 1 ) ) )
oModel:SetRelation( "NVNDETAIL", {{ "NVN_FILIAL", "xFilial('NVN')" }, {"NVN_CJCONT","NW2_COD"}, { "NVN_CLIPG", "NXP_CLIPG" }, { "NVN_LOJPG", "NXP_LOJAPG" } }, NVN->( IndexKey( 4 ) ) )

oModel:SetDescription( STR0008 ) // "Modelo de Dados de Juncao Contratos"
oModel:GetModel( "NW2MASTER" ):SetDescription( STR0009 ) // "Dados de Juncao Contratos"
oModel:GetModel( "NW3DETAIL" ):SetDescription( STR0010 ) // "Dados de Contratos Vinculados"
oModel:GetModel( "NUTDETAIL" ):SetDescription( STR0022 ) // "Dados de Casos Contrato"
oModel:GetModel( "NXPDETAIL" ):SetDescription( STR0028 ) // "Pagadores"
oModel:GetModel( "NVNDETAIL" ):SetDescription( STR0034 ) // "Encaminhamento de fatura"

oModel:GetModel( "NW3DETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NVNDETAIL" ):SetDelAllLine( .T. )

oModel:GetModel( "NUTDETAIL" ):SetOnlyQuery( .T. )
oModel:GetModel( "NUTDETAIL" ):SetNoDeleteLine( .T. )
oModel:GetModel( "NUTDETAIL" ):SetNoUpdateLine( .T. )
oModel:GetModel( "NUTDETAIL" ):SetNoInsertLine( .T. )
oModel:GetModel( "NUTDETAIL" ):SetOptional( .T. )
oModel:GetModel( "NXPDETAIL" ):SetOptional( .T. )
oModel:GetModel( "NVNDETAIL" ):SetOptional( .T. )

JurSetRules( oModel, "NW2MASTER",, "NW2" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA056QRY
Monta a query de Contratos que podem ser exibidos pela consulta padrão ou
podem ser permitidos na digitação na Junção de Contratos

@Param cAliasF3   Tabela de pesquisa

@Return cQuery	 	Query montada

@author Jacques Alves Xavier
@since 19/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA056QRY(cAliasF3, lSugestao)
Local cQuery      := ''
Local oModel      := FWModelActive()

Default lSugestao := .F.

If cAliasF3 == 'NT0'
	cQuery := " SELECT NT0.NT0_COD, NT0.NT0_NOME, NT0.R_E_C_N_O_ NT0RECNO "
	cQuery +=    " FROM " + RetSqlName("NT0") + " NT0 "
	cQuery +=   " WHERE NT0.D_E_L_E_T_ = ' ' "
	cQuery +=     " AND NT0.NT0_FILIAL = '" + xFilial( "NT0" ) + "' "

	If lSugestao
		If !Empty(oModel:GetValue("NW2MASTER", "NW2_CGRUPO"))
			cQuery +=    " AND NT0.NT0_CGRPCL = '" + oModel:GetValue("NW2MASTER", "NW2_CGRUPO") + "' "
		ElseIf !Empty(oModel:GetValue("NW2MASTER", "NW2_CCLIEN")) .And. !Empty(oModel:GetValue("NW2MASTER", "NW2_CLOJA"))
			cQuery +=    " AND NT0.NT0_CCLIEN = '" + oModel:GetValue("NW2MASTER", "NW2_CCLIEN") + "' "
			cQuery +=    " AND NT0.NT0_CLOJA = '" + oModel:GetValue("NW2MASTER", "NW2_CLOJA") + "' "
		EndIf
	EndIf
EndIf

If cAliasF3 == 'NW3'
	cQuery := " SELECT NT0.NT0_COD, NT0.NT0_NOME, NT0.R_E_C_N_O_ NT0RECNO "
	cQuery +=    " FROM " + RetSqlName("NT0") + " NT0 "
	cQuery +=   " WHERE NT0.D_E_L_E_T_ = ' ' "
	cQuery +=     " AND NT0.NT0_FILIAL = '" + xFilial( "NT0" ) + "' "
	cQuery +=     " AND NOT EXISTS ( SELECT NW3a.R_E_C_N_O_ "
	cQuery +=                       " FROM " + RetSqlName("NW3") + " NW3a "
	cQuery +=                       " WHERE NW3a.D_E_L_E_T_ = ' ' "
	cQuery +=                         " AND NW3a.NW3_FILIAL = '" + xFilial( "NW3" ) + "' "
	cQuery +=                         " AND NW3a.NW3_CCONTR = NT0.NT0_COD )"
EndIf

If cAliasF3 == 'SA1'
	cQuery := " SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_GRPVEN, SA1.R_E_C_N_O_ SA1RECNO "
	cQuery +=   " FROM " + RetSqlName("SA1") + " SA1 "
	cQuery +=   " WHERE SA1.D_E_L_E_T_ = ' ' "
	cQuery +=     " AND SA1.A1_FILIAL = '" + xFilial( "SA1" ) + "' "
EndIf

If cAliasF3 == 'NXP'
	cQuery := " SELECT NXP_CLIPG, NXP_LOJAPG, NXP_CCONT, NXP_FPAGTO, NXP_CCDPGT, NXP_CBANCO, NXP_CAGENC, "
	cQuery +=        " NXP_CCONTA, NXP_DESPAD, NXP_CMOE, NXP_CRELAT, NXP_CIDIO, NXP_CIDIO2, NXP_PERCEN "
	cQuery +=   IIF(NXP->(ColumnPos("NXP_CNATPG")) > 0, ", NXP_CNATPG ", "") // Natureza do Pagador
	If NXP->(ColumnPos("NXP_GROSHN")) > 0 // @12.1.2310
		cQuery +=   ", NXP_GROSHN, NXP_PERCGH " // Tipo de Gross Up Honorários
	EndIf
	cQuery +=   " FROM " + RetSqlName("NXP") + " NXP "
	cQuery +=   " WHERE NXP.D_E_L_E_T_ = ' ' "
	cQuery +=     " AND NXP.NXP_FILIAL = '" + xFilial( "NXP" ) + "' "
	cQuery +=     " AND NXP.NXP_CCONTR = '" + oModel:GetValue("NW2MASTER", "NW2_CCONSU") + "' "
EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA056F3NT0
Monta a consulta padrão de Contratos ainda não vinculados a nenhuma Junção de contrato

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample Consulta padrão específica RD0ATV

@author Jacques Alves Xavier
@since 19/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA056F3NT0(cAlias, lSugestao)
Local lRet     := .F.
Local aAreaNW3 := NW3->( GetArea() )
Local aArea    := GetArea()
Local cQuery   := JA056QRY(cAlias, lSugestao)
Local aPesq    := {'NT0_COD'}

cQuery   := ChangeQuery(cQuery, .F.)
uRetorno := ''

RestArea( aAreaNW3 )
RestArea( aArea )

If JurF3Qry( cQuery, 'NT0NW3', 'NT0RECNO', @uRetorno,, aPesq )
	NT0->( dbGoto( uRetorno ) )
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JU056VG
Verifica se o valor digitado no campo de contrato é válido.

@Return lRet	 	  .T./.F. As informações são válidas ou não

@author Jacques Alves Xavier
@since 14/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JU056VG()
Local lRet       := .F.
Local aArea      := GetArea()
Local oModel     := FWModelActive()
Local oModelNW3  := oModel:getModel("NW3DETAIL")
Local cQuery     := ''
Local aResult    := {}
Local cDesc      := ''

cQuery := " SELECT NW3.NW3_CCONTR, NW3.NW3_CJCONT "
cQuery +=   " FROM " + RetSqlName("NW3") + " NW3 "
cQuery +=   " WHERE NW3.D_E_L_E_T_ = ' ' "
cQuery +=     " AND NW3.NW3_FILIAL = '" + xFilial( "NW3" ) + "' "
cQuery +=     " AND NW3.NW3_CCONTR = '" + oModelNW3:GetValue("NW3_CCONTR") + "' "
If oModel:GetOperation() == 4
	cQuery +=     " AND NOT EXISTS ( SELECT NW3a.R_E_C_N_O_ "
	cQuery +=                        " FROM " + RetSqlName("NW3") + " NW3a "
	cQuery +=                         " WHERE NW3a.D_E_L_E_T_ = ' ' "
	cQuery +=                           " AND NW3a.NW3_FILIAL = '" + xFilial( "NW3" ) + "' "
	cQuery +=                           " AND NW3a.NW3_CJCONT = '" + oModelNW3:GetValue("NW3_CJCONT") + "')"
EndIf

aResult := JurSQL(cQuery, {'NW3_CCONTR', 'NW3_CJCONT'} )

If !(lRet := Len(aResult) == 0)
	JurMsgErro(I18N(STR0015, aResult[1]))  //"O contrato '#1' pertence à junção '#2'."
EndIf

If lRet
	cDesc := FwFldGet("NW2_DESC")
	oModel:SetValue("NW2MASTER", "NW2_DESC", "(@#$%¨&*!?)")
	oModel:SetValue("NW2MASTER", "NW2_DESC", cDesc)
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA056F3SA1
Monta a consulta padrão de Clientes do mesmo Grupo.

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample Consulta padrão específica RD0ATV

@author Jacques Alves Xavier
@since 19/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA056F3SA1()
	Local lRet     := .F.
	Local aAreaNW2 := NW2->( GetArea() )
	Local aArea    := GetArea()
	Local cQuery   := JA056QRY('SA1')
	Local aPesq    := {"A1_COD"}

	cQuery   := ChangeQuery(cQuery, .F.)
	uRetorno := ''

	RestArea( aAreaNW2 )
	RestArea( aArea )

	If JurF3Qry( cQuery, 'SA1NW2', 'SA1RECNO', @uRetorno, , aPesq )
		SA1->( dbGoto( uRetorno ) )
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J56SA1NW2V
Valida o preenchimento dos campos Grupo, Cliente e Loja.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Jacques Alves Xavier
@since 19/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J56SA1NW2V()
Local lRet    := .T.
Local oModel  := FwModelActive()
Local cGrupo  := ''
Local cClien  := ''
Local cLoja   := ''
Local cCampo  := AllTrim( ReadVar() )

	If (oModel:cId == 'JURA056')
		cGrupo  := oModel:GetValue("NW2MASTER", "NW2_CGRUPO")
		cClien  := oModel:GetValue("NW2MASTER", "NW2_CCLIEN")
		cLoja   := oModel:GetValue("NW2MASTER", "NW2_CLOJA")

		// Para o código do grupo do cliente
		If cCampo == "M->NW2_CGRUPO"
			lRet := JurVldCli(cGrupo, cClien, cLoja,,, "GRP")

		ElseIf cCampo == "M->NW2_CCLIEN"
			lRet := JurVldCli(cGrupo, cClien, cLoja,,, "CLI")

		ElseIf cCampo == "M->NW2_CLOJA"
			lRet := JurVldCli(cGrupo, cClien, cLoja,,, "LOJ")

		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA056VLDVC
Valida se existe ontrato vinculado a junção, para bloquear a alteração de campos.

@author Jacques Alves Xavier
@since 20/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA056VLDVC(cCampo)
Local lRet       := .T.
Local oModel     := FwModelActive()
Local oModelNW3  := oModel:GetModel( "NW3DETAIL" )
Local nQtdLnNW3  := oModelNW3:GetQtdLine()
Local nQtdNW3    := 0
Local nI         := 0

	For nI := 1 To nQtdLnNW3
		If oModelNW3:Isempty()
			Exit
		Else
			If !oModelNW3:IsDeleted( nI )
				nQtdNW3 := nQtdNW3 + 1
			EndIf
		EndIf
	Next

	If nQtdNW3 > 0
		lRet := .F.
	EndIf

	If lRet .And. (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4)
		If cCampo = 'NW2_CCONSU' .And. (Empty(oModel:GetValue("NW2MASTER", "NW2_CCLIEN")) .Or. Empty(oModel:GetValue("NW2MASTER", "NW2_CLOJA")) )
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA056VERPRE
Rotina para validar se exite pré-fatura para a Junção de Contrato

@author Jacques Alves Xavier
@since 20/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA056VERPRE(oModel)
Local lRet     := .T.
Local cQuery   := ''
Local cResQRY  := GetNextAlias()
Local aArea    := GetArea()

cQuery := " SELECT NX0.NX0_COD, NX0.NX0_SITUAC, NX0.NX0_CJCONT "
cQuery +=   " FROM " + RetSqlName("NX0") + " NX0 INNER JOIN " + RetSqlName("NW2") + " NW2 ON NW2.D_E_L_E_T_ = ' ' "
cQuery +=                                          " AND NW2.NW2_FILIAL = NX0.NX0_FILIAL "
cQuery +=                                          " AND NW2.NW2_COD = NX0.NX0_CJCONT "
cQuery +=                                          " AND NW2.NW2_COD = '"  + M->NW2_COD + "' "
cQuery += " WHERE NX0.D_E_L_E_T_ = ' ' "
cQuery +=    " AND NX0.NX0_FILIAL = '" + xFilial( "NW2" ) + "' "
cQuery +=    " AND NX0_SITUAC IN ('2','4','5','6','C','F') "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

If !Empty((cResQRY)->NX0_COD)
	If ApMsgYesNo(STR0013) // Existe pré-fatura para esta Junção de Contrato. Deseja apagar a pré-fatura para efetuar a alteração?.
		JA202CANPF((cResQRY)->NX0_COD)
	Else
		lRet := JurMsgErro(STR0014) // Não foi possível realizar as alterações!
	EndIf
EndIf

dbSelectArea(cResQRY)
(cResQRY)->(DbCloseArea())

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J056TUDOK(oModel)
Rotinas executadas no pós-validação do model

@author Jacques Alves Xavier
@since 20/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J056TUDOK(oModel)
	Local lRet       := .T.
	Local oModelNXP  := oModel:GetModel('NXPDETAIL')
	Local nQtdNXP    := oModelNXP:GetQtdLine()
	Local nI         := 0
	Local nQtd       := 0
	Local nFor       := 0
	Local nLenCod    := 0
	Local aArea      := GetArea()
	Local aAreaNVE   := NVE->(GetArea())
	Local aNXP       := {}
	Local aCodPre    := {}
	Local cSQL       := ""
	Local cQuery     := ""
	Local cMsgErr    := ""
	Local cCodJun    := oModel:GetValue("NW2MASTER", "NW2_COD")
	Local lProtNatPg := NXP->(ColumnPos("NXP_CNATPG")) > 0 // Proteção
	Local lProtGrsHn := NXP->(ColumnPos("NXP_GROSHN")) > 0 // @12.1.2310

	If lRet .And. (FwFldGet("NW2_DISCAS") = "2" .And. Empty(FwFldGet("NW2_TITFAT")) )
		lRet := JurMsgErro(STR0035) // "É necessário preencher o Título de Faturamento quando este não discriminado na fatura"
	EndIf

	For nI := 1 To nQtdNXP
		oModelNXP:GoLine( nI )
		If !oModelNXP:IsDeleted( nI ) .And. !JMdlNewLine(oModelNXP)
			nQtd := nQtd + 1
		EndIf
	Next

	If lRet .And. nQtd == 0 .And. !Empty(FwFldGet("NW2_CCONSU"))
		If ApMsgYesNo(STR0033) // Não existe pagadores para a Junção, deseja utilizar os pagadores do Contrato Sugerido?
			cSQL := JA056QRY("NXP")

			aNXP := JurSQL(cSQL, "*")

			For nI := 1 To Len(aNXP)
				If !JMdlNewLine(oModelNXP)
					oModelNXP:AddLine()
				EndIf
				oModel:SetValue("NXPDETAIL", "NXP_CLIPG" , aNXP[nI][1])
				oModel:SetValue("NXPDETAIL", "NXP_LOJAPG", aNXP[nI][2])
				oModel:SetValue("NXPDETAIL", "NXP_PERCEN", aNXP[nI][14])
				oModel:SetValue("NXPDETAIL", "NXP_DESPAD", aNXP[nI][9])
				oModel:SetValue("NXPDETAIL", "NXP_CCONT" , aNXP[nI][3])
				oModel:SetValue("NXPDETAIL", "NXP_FPAGTO", aNXP[nI][4])
				oModel:SetValue("NXPDETAIL", "NXP_CCDPGT", aNXP[nI][5])
				oModel:SetValue("NXPDETAIL", "NXP_CBANCO", aNXP[nI][6])
				oModel:SetValue("NXPDETAIL", "NXP_CAGENC", aNXP[nI][7])
				oModel:SetValue("NXPDETAIL", "NXP_CCONTA", aNXP[nI][8])
				oModel:SetValue("NXPDETAIL", "NXP_CMOE"  , aNXP[nI][10])
				oModel:SetValue("NXPDETAIL", "NXP_CRELAT", aNXP[nI][11])
				oModel:SetValue("NXPDETAIL", "NXP_CIDIO" , aNXP[nI][12])
				oModel:SetValue("NXPDETAIL", "NXP_CIDIO2", aNXP[nI][13])
				If lProtNatPg
					oModel:SetValue("NXPDETAIL", "NXP_CNATPG", aNXP[nI][15])
				EndIf
				If lProtGrsHn
					oModel:SetValue("NXPDETAIL", "NXP_GROSHN", aNXP[nI][16])
					oModel:SetValue("NXPDETAIL", "NXP_PERCGH", aNXP[nI][17])
				EndIf
			Next

		EndIf
	EndIf

	If lRet
		lRet := JurVldPag(oModel) //Validação de pagadores
	EndIf

	If lRet .And. oModel:GetOperation() != 5 .And. Empty(oModel:GetValue("NW2MASTER","NW2_CPART"))
		lRet := JurMsgErro(I18N( STR0039, {RetTitle("NW2_SIGLA")} ) ) // "O campo '#1' não foi preenchido. Verifique!"
	EndIf

	If lRet .And. oModel:GetOperation() == OP_ALTERAR

		If J56AltJoin(oModel)

			cQuery := " select distinct "
			cQuery +=     " NX0.NX0_COD "
			cQuery += " from " + RetSqlName("NW3") + " NW3 "
			cQuery +=       " inner join " + RetSqlName("NX8") + " NX8 "
			cQuery +=         " on ( NX8.NX8_FILIAL = '" + xFilial("NX8") + "' "
			cQuery +=             " and NX8.NX8_CCONTR = NW3.NW3_CCONTR "
			cQuery +=             " and NX8.D_E_L_E_T_ = ' ') "
			cQuery +=       " inner join " + RetSqlName("NX0") + " NX0 "
			cQuery +=         " on( NX0.NX0_FILIAL     = '" + xFilial("NX0") + "' "
			cQuery +=             " and NX0.NX0_COD    = NX8.NX8_CPREFT "
			cQuery +=             " and NX0.NX0_SITUAC IN ('2','3','4','5','6','7','9','A','B') "
			cQuery +=             " and NX0.D_E_L_E_T_ = ' ') "
			cQuery += " where "
			cQuery +=     " NW3.NW3_FILIAL     = '" + xFilial("NW3") + "' "
			cQuery +=     " and NW3.NW3_CJCONT = '" + cCodJun + "' "
			cQuery +=     " and NW3.D_E_L_E_T_ = ' ' "
			cQuery += " order by "
			cQuery +=     " NX0.NX0_COD"

			aCodPre := JurSQL(cQuery, "*")
			nLenCod := Len(aCodPre)

			If nLenCod > 0
				cMsgErr := STR0037 //"Atenção: as alterações feitas não refletirão na(s) pré-fatura(s) em aberto: "
				For nFor := 1 To nLenCod
					cMsgErr += aCodPre[nFor][1] + IIf(nFor < nLenCod , ", ", ".")
				Next nFor
				MsgAlert(cMsgErr, STR0036) //"Atenção"
			EndIf

		EndIf
	EndIf

	RestArea(aAreaNVE)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J056LOACAS
Gatilho para preenchimento da grid de Casos dos contrato

@author Gilmar P. Santos
@since 28/09/2010
/*/
//-------------------------------------------------------------------
Function J056LOACAS()
Local aArea      := GetArea()
Local cContrato  := ""
Local cQuery     := ""
Local cTmp       := ""
Local nCont      := 0
Local nLinhas    := 0
Local oModel     := FwModelActive()
Local oModelNUT  := oModel:GetModel( 'NUTDETAIL' )
Local aSaveLines := FWSaveRows()

cContrato := oModel:GetValue( 'NW3DETAIL', 'NW3_CCONTR' )

cQuery += "SELECT NUT_CCLIEN, NUT_CLOJA, NUT_CCASO "
cQuery +=  " FROM " + RetSqlName( 'NUT' ) + " NUT "
cQuery += " WHERE NUT_FILIAL = '" + xFilial( 'NUT') + "' "
cQuery +=   " AND NUT_CCONTR = '" + cContrato + "' "
cQuery +=   " AND NUT.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery( cQuery )

cTmp := GetNextAlias()
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTmp, .T., .T.)

nLinhas := oModelNUT:GetQtdLine()
nCont   := 0

oModelNUT:SetNoDeleteLine( .F. )
oModelNUT:SetNoUpdateLine( .F. )
oModelNUT:SetNoInsertLine( .F. )

While !(cTmp)->(EOF())
	nCont++

	If nCont <= nLinhas
		oModelNUT:GoLine( nCont )
	Else
		oModelNUT:AddLine()
	EndIf

	oModelNUT:SetValue( 'NUT_CCONTR', cContrato)
	oModelNUT:SetValue( 'NUT_CCLIEN', (cTmp)->NUT_CCLIEN )
	oModelNUT:SetValue( 'NUT_CLOJA' , (cTmp)->NUT_CLOJA  )
	oModelNUT:SetValue( 'NUT_CCASO' , (cTmp)->NUT_CCASO  )

	(cTmp)->( dbSkip() )
EndDo

(cTmp)->( dbCloseArea() )

While nCont < nLinhas
	nCont++
	oModelNUT:GoLine( nCont )
	oModelNUT:DeleteLine( .T. )
EndDo

FWRestRows( aSaveLines )

oModelNUT:SetNoDeleteLine( .T. )
oModelNUT:SetNoUpdateLine( .T. )
oModelNUT:SetNoInsertLine( .T. )

RestArea( aArea )

Return cContrato

//-------------------------------------------------------------------
/*/ { Protheus.doc } J056LOACON
Gatilho para preenchimento da grid de contrato

@author Gilmar P. Santos
@since 28/09/2010
/*/
//-------------------------------------------------------------------
Function J056LOACON( nTipo )
Local aArea      := GetArea()
Local cContrato  := ""
Local oModel     := FwModelActive()
Local cDesc      := ""

Default nTipo    := 1

If nTipo == 1
	cContrato := oModel:GetValue( 'NW2MASTER', 'NW2_CCONSU' )
	If !Empty( cContrato )
		oModel:SetValue( 'NW3DETAIL', 'NW3_CCONTR', cContrato )
	EndIf

ElseIf nTipo == 2

	oModel:ClearField( 'NW2MASTER', 'NW2_CMOE'  )
	oModel:ClearField( 'NW2MASTER', 'NW2_CESCR' )
	oModel:ClearField( 'NW2MASTER', 'NW2_CIDIO' )
	oModel:ClearField( 'NW2MASTER', 'NW2_CCLIEN')
	oModel:ClearField( 'NW2MASTER', 'NW2_CLOJA' )

	oModel:ClearField( 'NW2MASTER', 'NW2_DMOE'  )
	oModel:ClearField( 'NW2MASTER', 'NW2_DESCR' )
	oModel:ClearField( 'NW2MASTER', 'NW2_DIDIO' )
	oModel:ClearField( 'NW2MASTER', 'NW2_DCLIEN')

EndIf

RestArea( aArea )

Return cDesc

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA56SGCONT
Gatilho para preenchimento das informações da sugestão do contrato

@param 	cContrato  	Código do contrato

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 23/12/2010
/*/
//-------------------------------------------------------------------
Function JA56SGCONT()
Local aArea    := GetArea()
Local aAreaNT0 := NT0->(GetArea())
Local oModel   := FWModelActive()
Local nOpc     := oModel:GetOperation()
Local aCampos  := {}
Local lRet     := .F.
Local nI       := 0
Local cContr   := oModel:GetValue("NW2MASTER", "NW2_CCONSU")
Local cError   := ""

If nOpc == 3 .Or. nOpc == 4
	If !Empty(cContr)
		NT0->(DbSetOrder(1))
		If NT0->(DbSeek(xFilial("NT0") + cContr))
			If nOpc == 3 .Or. (nOpc == 4 .And. oModel:GetModel("NW3DETAIL"):IsEmpty())

				aAdd( aCampos, { 'NW2_CMOE'  , NT0->NT0_CMOE   } )
				aAdd( aCampos, { 'NW2_CESCR' , NT0->NT0_CESCR  } )
				aAdd( aCampos, { 'NW2_CIDIO' , NT0->NT0_CIDIO  } )
				aAdd( aCampos, { 'NW2_DISCAS', NT0->NT0_DISCAS } )

				If NT0->NT0_DISCAS == "2"
					aAdd( aCampos, { 'NW2_TITFAT', NT0->NT0_TITFAT } )
				EndIf

				For nI := 1 To Len( aCampos )
					If !(lRet := oModel:SetValue("NW2MASTER", aCampos[nI][1], aCampos[nI][2]))

						cError := STR0024 + " (" + RetTitle(aCampos[nI][1]) + "): " + CRLF
						cError += JurShowErro( oModel:GetErrorMessage(), Nil, Nil, .F., .F.)
						JurMsgErro(cError)
						J056LOACON(2)

						Exit
					EndIf
				Next
				If lRet
					J056LOACON(1)
				EndIf
			EndIf
		EndIf

	EndIf

EndIf

RestArea(aAreaNT0)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J56AltJoin
Verifica alteracao dos campos que afetam a geracao das pre-faturas

@author Daniel Magalhaes
@since 27/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J56AltJoin(oModel)
Local aArea   := GetArea()
Local aAux    := {}
Local cCpos   := "NW2_CMOE,NW2_CESCR,NW2_CIDIO,NW2_SIGLA"
Local cGrids  := "NW3DETAIL,NXPDETAIL"
Local nFor    := 0
Local nForMdl := 0
Local nQtdMdl := 0
Local cCodJun := oModel:GetValue("NW2MASTER", "NW2_COD")
Local lRet    := .F.
Local oMdlAux

NW2->(DbSetOrder(1))
If NW2->(DbSeek( xFilial("NW2") + cCodJun ))

	aAux := StrTokArr(cCpos, ",")

	For nFor := 1 To Len(aAux)
		If lRet := oModel:IsFieldUpdated( "NW2MASTER", aAux[nFor] )
			Exit
		EndIf
	Next nFor

	If !lRet
		aAux := StrTokArr(cGrids, ",")

		For nFor := 1 To Len(aAux)
			oMdlAux := oModel:GetModel(aAux[nFor])

			nQtdMdl := oMdlAux:GetQtdLine()

			For nForMdl := 1 To nQtdMdl
				oMdlAux:goLine(nForMdl)

				If oMdlAux:IsDeleted() .Or. oMdlAux:IsUpdated() .Or. (oMdlAux:IsInserted() .And. !oMdlAux:IsEmpty())
					lRet := .T.
					Exit
				EndIf

			Next nForMdl

		Next nFor

	EndIf

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J056ClxGr()
Rotina para verificar se o cliente/loja pertence ao grupo.
Usado nos gatilhos de Grupo

@Return - lRet  .T. quando o cliente PERTENCE ao grupo informado OU
                .F. quando o cliente NÃO pertence ao grupo informado

@author Bruno Ritter
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J056ClxGr()
Local lRet    := .T.
Local oModel  := FwModelActive()
Local cGrupo  := ''
Local cClien  := ''
Local cLoja   := ''

If (oModel:cId == 'JURA056')

	cGrupo := oModel:GetValue("NW2MASTER", "NW2_CGRUPO")
	cClien := oModel:GetValue("NW2MASTER", "NW2_CCLIEN")
	cLoja  := oModel:GetValue("NW2MASTER", "NW2_CLOJA")

	lRet   := JurClxGr(cClien, cLoja, cGrupo)

EndIf

Return lRet
