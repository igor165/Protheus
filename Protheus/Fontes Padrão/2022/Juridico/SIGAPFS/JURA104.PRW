#INCLUDE "JURA104.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA104
Posição de faturamento por Caso.

@author Luciano Pereira dos Santos
@since 01/01/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA104()
Local oBrowse := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) // "Faturas por Caso"
oBrowse:SetAlias("NVE")
oBrowse:SetMenuDef('JURA104')
oBrowse:SetProfileID('1')
oBrowse:SetCacheView(.F.)
oBrowse:SetWalkThru(.F.)
oBrowse:SetAmbiente(.F.)
oBrowse := J104RemCpo(oBrowse)

JurSetLeg(@oBrowse, "NVE" )
JurSetBSize(@oBrowse)

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

@author Luciano Pereira dos Santos
@since 01/02/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA104", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA104", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Faturamento por Caso

@author Luciano Pereira dos Santos
@since 01/02/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel    := FWLoadModel( "JURA104" )
Local oStruct   := FWFormStruct( 2, "NVE" )
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

JurSetAgrp( 'NVE',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )

If (cLojaAuto == "1")
	oStruct:RemoveField( "NVE_LCLIEN" )
EndIf

oView:AddField( "JURA104_VIEW", oStruct, "NVEMASTER" )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA104_VIEW", "FORMFIELD" )
oView:SetDescription( STR0001 ) // "Faturas por Caso"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Faturamento por Caso.

@author Luciano Pereira dos Santos
@since 01/01/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NVE" )

oModel:= MPFormModel():New( "JURA104", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NVEMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0001 ) // "Faturas por Caso"
oModel:GetModel( "NVEMASTER" ):SetDescription( STR0001 ) // "Faturas por Caso"

JurSetRules( oModel, 'NVEMASTER',, 'NVE' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J104VFAT()
Rotina para calcular os lançamentos Faturados por Caso

@Param	cCampo	Campo de lançamento a ser calculado.

@Return	nValor	Valor calculado.

@author Luciano Pereira dos Santos
@since 03/02/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function J104VFAT(cCampo)
Local nValor    := 0
Local cQuery    := ""
Local aArea     := GetArea()
Local cClient   := NVE->NVE_CCLIEN
Local cLoja     := NVE->NVE_LCLIEN
Local cCaso     := NVE->NVE_NUMCAS
Local cQryRes   := GetNextAlias()
Local cMoedaNac := SuperGetMv('MV_JMOENAC',, '01')
Local dData     := Date()

Do Case
Case cCampo == "NVE_VTSFAT"
	cQuery := " SELECT SUM(NXC.NXC_VLTS) VALOR, NXA_CMOEDA CMOEDA, NXA_DTEMI DTMOED "
Case cCampo == "NVE_VLTFAT"
	cQuery := " SELECT SUM(NXC.NXC_VLTAB) VALOR, NXA_CMOEDA CMOEDA, NXA_DTEMI DTMOED "
Case cCampo == "NVE_VDPFAT"
	cQuery := " SELECT SUM(NXC.NXC_VLDFAT) VALOR, NXA_CMOEDA CMOEDA, NXA_DTEMI DTMOED "
Case cCampo == "NVE_VFXFAT"
	cQuery := " SELECT SUM(NXC.NXC_VFIXO) VALOR, NXA_CMOEDA CMOEDA, NXA_DTEMI DTMOED "
Case cCampo == "NVE_HONFAT"
	cQuery := " SELECT SUM(NXC.NXC_VLHFAT+NXC.NXC_ARATF) VALOR, NXA_CMOEDA CMOEDA, NXA_DTEMI DTMOED "
OtherWise
	cQuery := " SELECT 0 VALOR, '" + cMoedaNac + "' CMOEDA, '" + DtoS(dData) + "' DTMOED "
EndCase

cQuery +=    " FROM "+ RetSQLName("NXC") + "  NXC, "
cQuery +=         " "+ RetSQLName("NXA") + "  NXA "
cQuery +=    " WHERE NXC.NXC_FILIAL = '" + xFilial('NXC') + "' "
cQuery +=        " AND NXA.NXA_FILIAL = '" + xFilial('NXA') + "' "
cQuery +=        " AND NXC.NXC_CCLIEN = '" + cClient + "' "
cQuery +=        " AND NXC.NXC_CLOJA = '" + cLoja + "' "
cQuery +=        " AND NXC.NXC_CCASO = '" + cCaso + "' "
cQuery +=        " AND NXC.NXC_CFATUR = NXA.NXA_COD "
cQuery +=        " AND NXC.NXC_CESCR = NXA.NXA_CESCR "
cQuery +=        " AND NXA.NXA_SITUAC = '1' "

Do Case
Case cCampo == "NVE_VTSFAT"
	cQuery +=    " AND NXA.NXA_TS = '1' "
Case cCampo == "NVE_VLTFAT"
	cQuery +=    " AND NXA.NXA_TAB = '1' "
Case cCampo == "NVE_VDPFAT"
	cQuery +=    " AND NXA.NXA_DES = '1' "
Case cCampo == "NVE_VFXFAT"
	cQuery +=    " AND NXA.NXA_FIXO = '1' "
EndCase

cQuery +=       " AND NXC.D_E_L_E_T_ = ' ' "
cQuery +=       " AND NXA.D_E_L_E_T_ = ' ' "
cQuery +=    " GROUP BY NXA.NXA_CMOEDA, NXA.NXA_DTEMI "

dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

While !(cQryRes)->(EOF())

	If (cQryRes)->CMOEDA != cMoedaNac
		nValor := nValor + JA201FConv(cMoedaNac, (cQryRes)->CMOEDA, (cQryRes)->VALOR, "1", StoD((cQryRes)->DTMOED))[1]
	Else
		nValor := nValor + (cQryRes)->VALOR
	EndIf

	(cQryRes)->(DbSkip())
EndDo

(cQryRes)->(DbCloseArea())

RestArea(aArea)

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J104VAFT(cCampo)
Rotina para calcular os lançamentos à faturar por Caso

@Param	cCampo	Campo de lançamento a ser calculado.

@Return	nValor	Valor calculado.

@author Luciano Pereira dos Santos
@since 03/02/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function J104VAFT(cCampo)
Local nValor    := 0
Local cQuery    := ""
Local aArea     := GetArea()
Local cClient   := NVE->NVE_CCLIEN
Local cLoja     := NVE->NVE_LCLIEN
Local cCaso     := NVE->NVE_NUMCAS
Local cQryRes   := Nil
Local cMoedaNac := SuperGetMv('MV_JMOENAC',, '01')
Local dData     := Date()
Local cTpcnvl   := SuperGetMv('MV_JCONVLT',, '3')

If cCampo == "NVE_HONAFT"
	nValor := J104VAFT('NVE_VTSAFT') + J104VAFT('NVE_VLTAFT') + J104VAFT('NVE_VFXAFT')
Else
	Do Case
		Case cCampo == "NVE_VTSAFT"

			cQuery := " SELECT SUM(NUE.NUE_VALOR) VALOR, NUE.NUE_CMOEDA CMOEDA, NUE_DATATS DTMOED "
			cQuery +=      " FROM " + RetSqlName("NUE") + " NUE, "
			cQuery +=           " " + RetSqlName("NUT") + " NUT, "
			cQuery +=           " " + RetSqlName("NRA") + " NRA, "
			cQuery +=           " " + RetSqlName("NT0") + " NT0 "
			cQuery +=      " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
			cQuery +=        " AND NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
			cQuery +=        " AND NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
			cQuery +=        " AND NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
			cQuery +=        " AND NUE.NUE_CCLIEN = '" + cClient + "' "
			cQuery +=        " AND NUE.NUE_CLOJA = '" + cLoja + "' "
			cQuery +=        " AND NUE.NUE_CCASO = '" + cCaso + "' "
			cQuery +=        " AND NUE.NUE_SITUAC = '1' "
			cQuery +=        " AND NUE.NUE_CCLIEN = NUT.NUT_CCLIEN "
			cQuery +=        " AND NUE.NUE_CLOJA = NUT.NUT_CLOJA "
			cQuery +=        " AND NUE.NUE_CCASO = NUT.NUT_CCASO "
			cQuery +=        " AND NT0.NT0_COD = NUT.NUT_CCONTR "
			cQuery +=        " AND NT0.NT0_CTPHON = NRA.NRA_COD "
			cQuery +=        " AND NRA.NRA_COBRAH = '1' "
			cQuery +=        " AND NUE.D_E_L_E_T_ = ' ' "
			cQuery +=        " AND NT0.D_E_L_E_T_ = ' ' "
			cQuery +=        " AND NRA.D_E_L_E_T_ = ' ' "
			cQuery +=        " AND NUT.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY NUE.NUE_CMOEDA, NUE.NUE_DATATS "

		Case cCampo == "NVE_VLTAFT"

			cQuery := " SELECT SUM(NV4.NV4_VLHFAT) VALOR, NV4.NV4_CMOEH CMOEDA, "
			cQuery +=        " (CASE WHEN '" + cTpcnvl + "' = '1' THEN NV4.NV4_DTLANC ELSE "
			cQuery +=        " (CASE WHEN '" + cTpcnvl + "' = '2' THEN NV4.NV4_DTINC ELSE NV4.NV4_DTCONC END) "
			cQuery +=         " END) DTMOED "
			cQuery +=     " FROM "+ RetSqlName('NV4') + " NV4, "
			cQuery +=          " " + RetSqlName("NUT") + " NUT, "
			cQuery +=          " " + RetSqlName("NRA") + " NRA, "
			cQuery +=          " " + RetSqlName("NT0") + " NT0 "
			cQuery +=    " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") + "' "
			cQuery +=      " AND NT0.NT0_FILIAL  = '" + xFilial("NT0") +"' "
			cQuery +=      " AND NRA.NRA_FILIAL = '" + xFilial("NRA") +"' "
			cQuery +=      " AND NUT.NUT_FILIAL = '" + xFilial("NUT") +"' "
			cQuery +=      " AND NV4.NV4_CCLIEN = '" + cClient + "' "
			cQuery +=      " AND NV4.NV4_CLOJA  = '" + cLoja + "' "
			cQuery +=      " AND NV4.NV4_CCASO  = '" + cCaso + "' "
			cQuery +=      " AND NV4.NV4_SITUAC = '1' "
			cQuery +=      " AND NV4.NV4_COBRAR = '1' "
			cQuery +=      " AND NV4.NV4_CONC = '1' "
			cQuery +=      " AND NV4.NV4_CCLIEN = NUT.NUT_CCLIEN "
			cQuery +=      " AND NV4.NV4_CLOJA = NUT.NUT_CLOJA "
			cQuery +=      " AND NV4.NV4_CCASO = NUT.NUT_CCASO "
			cQuery +=      " AND NT0.NT0_COD = NUT.NUT_CCONTR "
			cQuery +=      " AND NT0.NT0_CTPHON = NRA.NRA_COD "
			cQuery +=      " AND NRA.NRA_COBRAH = '1' "
			cQuery +=      " AND NT0.D_E_L_E_T_ = ' ' "
			cQuery +=      " AND NRA.D_E_L_E_T_ = ' ' "
			cQuery +=      " AND NUT.D_E_L_E_T_ = ' ' "
			cQuery +=      " AND NV4.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY NV4.NV4_CMOEH, NV4.NV4_DTLANC, NV4.NV4_DTINC, NV4.NV4_DTCONC "

		Case cCampo == "NVE_VDPAFT"

			cQuery := " SELECT SUM(NVY.NVY_VALOR) VALOR, NVY.NVY_CMOEDA CMOEDA, NVY.NVY_DATA DTMOED "
			cQuery +=    " FROM " + RetSqlName("NVY") + " NVY "
			cQuery +=    " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") + "' "
			cQuery +=      " AND NVY.NVY_CCLIEN = '" + cClient + "' "
			cQuery +=      " AND NVY.NVY_CLOJA = '" + cLoja + "' "
			cQuery +=      " AND NVY.NVY_CCASO = '" + cCaso + "' "
			cQuery +=      " AND NVY.NVY_COBRAR = '1' "
			cQuery +=      " AND NVY.NVY_SITUAC = '1' "
			cQuery +=      " AND NVY.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY NVY.NVY_CMOEDA, NVY.NVY_DATA "

		Case cCampo == "NVE_VFXAFT"

			cQuery := " SELECT SUM(CASE WHEN NT1.NT1_VALORA = 0 THEN NT1.NT1_VALORB ELSE NT1.NT1_VALORA END) "
			cQuery += " /(SELECT COUNT(R_E_C_N_O_) FROM " + RetSqlName("NUT") + " NUT "
			cQuery +=                             " WHERE NUT.NUT_FILIAL = '" + xFilial("NUT") +"' "
			cQuery +=                               " AND NUT.NUT_CCONTR = NT0.NT0_COD "
			cQuery +=                               " AND NUT.D_E_L_E_T_ = ' ') VALOR, "
			cQuery += " (CASE WHEN NT1.NT1_CMOEDA = ' ' THEN  NT0.NT0_CMOE ELSE NT1.NT1_CMOEDA END) CMOEDA, "
			cQuery += " '" + DtoS(dData) + "' DTMOED "
			cQuery +=     " FROM " + RetSqlName( 'NT1' ) + " NT1, "
			cQuery +=          " " + RetSqlName("NUT") + " NUT, "
			cQuery +=          " " + RetSqlName("NRA") + " NRA, "
			cQuery +=          " " + RetSqlName("NT0") + " NT0 "
			cQuery +=     " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") +"' "
			cQuery +=       " AND NRA.NRA_FILIAL = '" + xFilial("NRA") +"' "
			cQuery +=       " AND NT1.NT1_FILIAL = '" + xFilial("NT1") +"' "
			cQuery +=       " AND NUT.NUT_CCLIEN = '" + cClient +"' "
			cQuery +=       " AND NUT.NUT_CLOJA = '" + cLoja +"' "
			cQuery +=       " AND NUT.NUT_CCASO = '" + cCaso +"' "
			cQuery +=       " AND NT0.NT0_COD = NUT.NUT_CCONTR "
			cQuery +=       " AND NT0.NT0_CTPHON = NRA.NRA_COD  "
			cQuery +=       " AND NRA.NRA_COBRAF = '1' "
			cQuery +=       " AND NT0.NT0_COD = NT1.NT1_CCONTR  "
			cQuery +=       " AND NT1.NT1_SITUAC = '1'  "
			cQuery +=       " AND NT0.D_E_L_E_T_ = ' ' "
			cQuery +=       " AND NRA.D_E_L_E_T_ = ' ' "
			cQuery +=       " AND NUT.D_E_L_E_T_ = ' ' "
			cQuery +=       " AND NT1.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY NT1.NT1_CMOEDA, NT0.NT0_CMOE, NT0.NT0_COD "

		OtherWise
			cQuery := " SELECT 0 VALOR, '" + cMoedaNac + "' CMOEDA, '" + DtoS(dData) + "' DTMOED "
			cQuery +=   " FROM " + RetSqlName( 'NVE' ) + " "
	EndCase

	cQryRes := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While !(cQryRes)->(EOF())

		If (cQryRes)->CMOEDA != cMoedaNac
			nValor := nValor + JA201FConv(cMoedaNac, (cQryRes)->CMOEDA, (cQryRes)->VALOR, "1", StoD((cQryRes)->DTMOED) )[1]
		Else
			nValor := nValor + (cQryRes)->VALOR
		EndIf

		(cQryRes)->(DbSkip())
	EndDo

	(cQryRes)->(DbCloseArea())

EndIf

RestArea(aArea)

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J104RemCpo(oBrowse)
Rotina para remover campos do browser de Caso

@Param   oBrowse  Browser da tabelas de caso

@Return  oBrowse  Browser somente com os campos que serão exibidos.

@author Luciano Pereira dos Santos
@since 01/06/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J104RemCpo(oBrowse)
Local aArea     := GetArea()
Local cLojaAuto := SuperGetMv("MV_JLOJAUT",.F., "2") //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local aRemove   := {}

aRemove := {'NVE_FILIAL','NVE_CIDIO','NVE_CSUBAR','NVE_DSPDIS','NVE_DETENC','NVE_DETREA','NVE_DTABS',;
			'NVE_DIDIO','NVE_DSUBAR','NVE_OBSCAD','NVE_OBSFAT','NVE_USUINC','NVE_REDFAT','NVE_SITUAC',;
			'NVE_VIRTUA','NVE_CPART2','NVE_DPART2','NVE_DTREAB','NVE_CPART3','NVE_DPART3','NVE_CPART4',;
			'NVE_DPART4','NVE_LITIS','NVE_CGRPCL','NVE_DGRPCL','NVE_OK','NVE_CCLINV','NVE_CLJNV',;
			'NVE_CCASNV','NVE_CCLIAN','NVE_CLOJAN','NVE_CCASAN','NVE_PESO','NVE_SIGLA2','NVE_SIGLA3','NVE_SIGLA4'}

If cLojaAuto == "1"
	Aadd(aRemove, 'NVE_LCLIEN')
EndIf

If FindFunction("JurBrwRev") //PROTEÇÃO
	JurBrwRev(@oBrowse, "NVE", aRemove)
EndIf

RestArea(aArea)

Return oBrowse
