#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

#DEFINE OBR_SIP   "1"
#DEFINE OBR_SIB   "2"
#DEFINE OBR_DIOPS "3"

#DEFINE PB3MITEM	01
#DEFINE PB3MDESCRI	02
#DEFINE PB3MEVENTOS	03
#DEFINE PB3MANTEVE	04
#DEFINE PB3MDIFEVE	05
#DEFINE PB3MEXPOSTOS 06
#DEFINE PB3MANTEXP  07
#DEFINE PB3MDIFEXP  08
#DEFINE PB3MCUSTO	09
#DEFINE PB3MANTCUSTO 10
#DEFINE PB3MDIFCUSTO 11
#DEFINE CAMPO   01
#DEFINE TIPO    02
#DEFINE TAMANHO 03
#DEFINE DECIMAL 04
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definição das opções do menu

@author everton.mateus
@since 26/01/2016

/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina Title 'Detalhar'  Action 'CenDetResSip(.F.)'	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Guias' ACTION 'cenResSipG(.f., GRPB3M->ITEM)' OPERATION 2 ACCESS 0

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenResSIP

Exibe um browse com as Resumo Proc. SIP por código e descrição

@author everton.mateus
@since 22/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Function CenResSIP(lAuto)

	Local oBrw    := FWmBrowse():New()
	Local aCampos := RetornaCampos()
	Local oTmpTab := CriaTabTemp(aCampos)
	Local cAliasTmp := GetNextAlias()
	Default lAuto := .F.

	If BscItens(cAliasTmp)
		CarregaArqTmp(cAliasTmp)
	EndIf
	oBrw:SetDescription( "Resumo do XML SIP" )
	oBrw:SetAlias( oTmpTab:getAlias() )
	oBrw:SetMenuDef( '' )
	oBrw:SetFields(montaFields(aCampos))
	oBrw:SetProfileID( 'CenResSIP' )
	oBrw:SetMenuDef('CenResSIP')
	oBrw:DisableDetails()
	oBrw:SetWalkthru(.F.)
	oBrw:SetAmbiente(.F.)
	oBrw:forcequitbutton()

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Resumo do XML", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrw:Activate()
	EndIf

	oTmpTab:delete()

Return oBrw

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenDetResSip

Exibe um browse com as o detalhes da crítica selecionada

@author everton.mateus
@since 22/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Function CenDetResSip(lAuto)

	Local oBrw := Nil
	Local cFiltro := ""
	Default lAuto := .F.
	// Passei o filtro para baixo pois o caso de teste CENRESSIP quebra devido a tabela temporária GRPB3M
	If(!lAuto)
		cFiltro := " B3M_FILIAL = '" + xFilial( 'B3M' ) + "' .AND. B3M_CODOPE = '" + B3D->B3D_CODOPE + "' .AND. B3M_ITEM = '" + GRPB3M->ITEM + "' .AND. B3M_TRIREC = '" + B3D->B3D_ANO + SubStr(B3D->B3D_CODIGO,2,2) + "' "
		oBrw := PLSMVCB3M(lAuto,cFiltro)
	EndIf

Return oBrw

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaCampos

Retorna os campos para criar o arquivo temporario

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaCampos()

	Local aCampos := {}

	aAdd(aCampos,{"ITEM"		,"C",010,0})
	aAdd(aCampos,{"DESCRI"		,"C",050,0})
	aAdd(aCampos,{"EVENTOS"		,"N",016,0})
	aAdd(aCampos,{"ANTEVEN"		,"N",016,0})
	aAdd(aCampos,{"DIFEVE"		,"C",010,0})
	aAdd(aCampos,{"EXPOSTOS"	,"N",016,0})
	aAdd(aCampos,{"ANTEXP"		,"N",016,0})
	aAdd(aCampos,{"DIFEXP"		,"C",010,0})
	aAdd(aCampos,{"CUSTO"		,"N",016,2})
	aAdd(aCampos,{"ANTCUSTO"	,"N",016,2})
	aAdd(aCampos,{"DIFCST"		,"C",010,0})

Return aCampos

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTabTemp

Cria o arquivo temporario de vencimentos

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaTabTemp(aCampos)

	Local oTmpTab   := Nil
	Default aCampos := {}

	oTmpTab := FWTemporaryTable():New( 'GRPB3M' )
	oTmpTab:SetFields( aCampos )
	oTmpTab:AddIndex("01",{"ITEM"})
	oTmpTab:Create()

Return oTmpTab

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BscItens

Busca os compromissos a vencer

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function BscItens(cAliasTmp,cItem,cTriRec)

	Local cSql 		:= ""
	Local lFound	:= .F.
	Default cAliasTmp := GetNextAlias()
	Default cItem 	:= ""
	Default cTriRec := B3D->B3D_ANO + SubStr(B3D->B3D_CODIGO,2,2)

	cSql += " SELECT TB.ITEM ITEM, SUM(TB.EVENTOS) EVENTOS, SUM(TB.EXPOSTOS) EXPOSTOS, SUM(TB.CUSTO) CUSTO FROM ( "
	cSql += " SELECT B3M_ITEM ITEM "
	cSql += " 	,ROUND(SUM(B3M_QTDEVE),0) EVENTOS "
	cSql += " 	,ROUND(MAX(B3M_QTDBEN),0) EXPOSTOS "
	cSql += " 	,ROUND(SUM(B3M_VLRTOT),2) CUSTO,B3M_FORCON "
	cSql += " FROM " + RetSqlName("B3M") + " "
	cSql += " WHERE 1 = 1 "
	cSql += " 	AND B3M_FILIAL = '" + xFilial("B3M") + "' "
	cSql += " 	AND B3M_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " 	AND B3M_TRIREC = '" + cTriRec + "' "
	If !Empty(cItem)
		cSql += " 	AND B3M_ITEM = '" + cItem + "' "
	EndIf
	cSql += " 	AND D_E_L_E_T_ = ' ' "
	cSql += " GROUP BY B3M_ITEM,B3M_FORCON "

	cSql += " )TB GROUP BY TB.ITEM "
	cSql += " ORDER BY 1 "

	If (Select(cAliasTmp) <> 0)
		dbSelectArea(cAliasTmp)
		(cAliasTmp)->(dbCloseArea())
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasTmp,.F.,.T.)

	lFound := !(cAliasTmp)->(Eof())
	If !lFound
		(cAliasTmp)->(dbCloseArea())
	EndIf

Return lFound

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaArqTmp

Preenche o arquivo temporario com os registros criticados

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaArqTmp(cAliasTmp)

	Local lRet := .F.
	Local cTriAnt := getTriAnt()
	Local cDifEve := "0%"
	Local cDifExp := "0%"
	Local cDifCusto := "0%"
	Local nAntEve := 0
	Local nAntExp := 0
	Local nAntCusto := 0
	Local cAliasAnt := GetNextAlias()

	While !(cAliasTmp)->(Eof())

		If BscItens(cAliasAnt, (cAliasTmp)->ITEM,cTriAnt)
			cDifEve := AllTrim(Str(Round ( ( (cAliasTmp)->EVENTOS/(cAliasAnt)->EVENTOS * 100 ) - 100, 2)) + "%")
			cDifExp := AllTrim(Str(Round ( ( (cAliasTmp)->EXPOSTOS/(cAliasAnt)->EXPOSTOS * 100 ) - 100, 2)) + "%")
			cDifCusto := AllTrim(Str(Round ( ( (cAliasTmp)->CUSTO/(cAliasAnt)->CUSTO * 100 ) - 100, 2)) + "%")
			nAntEve := (cAliasAnt)->EVENTOS
			nAntExp := (cAliasAnt)->EXPOSTOS
			nAntCusto := (cAliasAnt)->CUSTO

		Else
			cDifEve := "0%"
			cDifExp := "0%"
			cDifCusto := "0%"
			nAntEve := 0
			nAntExp := 0
			nAntCusto := 0
		EndIf

		RecLock('GRPB3M',.T.)
		GRPB3M->ITEM 		:= (cAliasTmp)->ITEM
		GRPB3M->DESCRI 		:= getDescItem(AllTrim((cAliasTmp)->ITEM))
		GRPB3M->EVENTOS 	:= (cAliasTmp)->EVENTOS
		GRPB3M->ANTEVEN 	:= nAntEve
		GRPB3M->DIFEVE 		:= cDifEve
		GRPB3M->EXPOSTOS 	:= (cAliasTmp)->EXPOSTOS
		GRPB3M->ANTEXP 		:= nAntExp
		GRPB3M->DIFEXP 		:= cDifExp
		GRPB3M->CUSTO 		:= (cAliasTmp)->CUSTO
		GRPB3M->ANTCUSTO 	:= nAntCusto
		GRPB3M->DIFCST 		:= cDifCusto
		GRPB3M->(MsUnlock())
		(cAliasTmp)->(DbSkip())

	EndDo

	If Select(cAliasTmp) <> 0
		(cAliasTmp)->(dbCloseArea())
	EndIf
	If Select(cAliasAnt) <> 0
		(cAliasAnt)->(dbCloseArea())
	EndIf
	lRet := .T.

Return lRet

Static Function getTriAnt()
	Local cTriAnt := ""
	Local cAno := B3D->B3D_ANO
	Local cTrim := StrZero(Val(B3D->B3D_CODIGO)-1,2)
	If B3D->B3D_CODIGO = "001"
		cTrim := "04"
		cAno := StrZero(Val(B3D->B3D_ANO)-1,4)
	EndIf
	cTriAnt := cAno+cTrim
Return cTriAnt

Static Function getDescItem(cItem)
	Local aItens := {;
		{"A","CONSULTAS MÉDICAS"},{"A1","CONSULTAS MÉDICAS AMBULATORIAIS"},;
		{"A11","ALERGIA E IMUNOLOGIA"},{"A12","ANGIOLOGIA"},;
		{"A13","CARDIOLOGIA"},{"A14","CIRURGIA GERAL"},;
		{"A15","CLÍNICA MÉDICA"},{"A16","DERMATOLOGIA"},;
		{"A17","ENDOCRINOLOGIA"},{"A18","GASTROENTEROLOGIA"},;
		{"A19","GERIATRIA"},{"A110","GINECOLOGIA E OBSTETRÍCIA"},;
		{"A111","HEMATOLOGIA"},{"A112","MASTOLOGIA"},;
		{"A113","NEFROLOGIA"},{"A114","NEUROCIRURGIA"},;
		{"A115","NEUROLOGIA"},{"A116","OFTALMOLOGIA"},{"A117","ONCOLOGIA"},;
		{"A118","OTORRINOLARINGOLOGIA"},{"A119","PEDIATRIA"},;
		{"A120","PROCTOLOGIA"},{"A121","PSIQUIATRIA"},;
		{"A122","REUMATOLOGIA"},{"A123","TISIOPNEUMOLOGIA"},;
		{"A124","TRAUMATOLOGIA-ORTOPEDIA"},{"A125","UROLOGIA"},;
		{"A2","CONSULTAS MÉDICAS EM PRONTO-SOCORRO"},;
		{"B","OUTROS ATENDIMENTOS AMBULATORIAIS"},{"B1","CONSULTAS/SESSÕES COM FISIOTERAPEUTA"},;
		{"B2","CONSULTAS/SESSÕES COM FONOAUDIÓLOGO"},{"B3","CONSULTAS/SESSÕES COM NUTRICIONISTA"},;
		{"B4","CONSULTAS/SESSÕES COM TERAPEUTA OCUPACIONAL"},{"B5","CONSULTAS/SESSÕES COM PSICÓLOGO"},;
		{"C","EXAMES"},{"C1","RESSONÂNCIA MAGNÉTICA"},;
		{"C2","TOMOGRAFIA COMPUTADORIZADA"},{"C3","PROCEDIMENTO DIAGNÓSTICO EM CITOPATOLOGIA CÉRVICO-VAGINAL ONCÓTICA EM MULHERES DE 25 A 59 ANOS"},;
		{"C4","DENSITOMETRIA ÓSSEA – QUALQUER SEGMENTO"},{"C5","ECODOPPLERCARDIOGRAMA TRANSTORÁCICO"},;
		{"C6","BRONCOSCOPIA COM OU SEM BIÓPSIA"},{"C7","ENDOSCOPIA DIGESTIVA ALTA"},;
		{"C8","COLONOSCOPIA"},{"C9","HOLTER DE 24 HORAS"},;
		{"C10","MAMOGRAFIA CONVENCIONAL E DIGITAL"},{"C101","MAMOGRAFIA EM MULHERES DE 50 A 69 ANOS"},;
		{"C11","CINTILOGRAFIA MIOCÁRDICA"},{"C12","CINTILOGRAFIA RENAL DINÂMICA"},;
		{"C13","HEMOGLOBINA GLICADA"},{"C14","PESQUISA DE SANGUE OCULTO NAS FEZES (50 A 69 ANOS)"},;
		{"C15","RADIOGRAFIA"},{"C16","TESTE ERGOMÉTRICO"},;
		{"C17","ULTRASSONOGRAFIA DIAGNÓSTICA DE ABDOME TOTAL"},{"C18","ULTRASSONOGRAFIA DIAGNÓSTICA DE ABDOME INFERIOR"},;
		{"C19","ULTRASSONOGRAFIA DIAGNÓSTICA DE ABDOME SUPERIOR"},{"C20","ULTRASSONOGRAFIA OBSTÉTRICA MORFOLÓGICA"},;
		{"D","TERAPIAS"},{"D1","TRANSFUSÃO AMBULATORIAL"},;
		{"D2","QUIMIOTERAPIA SISTÊMICA"},{"D3","RADIOTERAPIA MEGAVOLTAGEM"},;
		{"D4","HEMODIÁLISE AGUDA"},{"D5","HEMODIÁLISE CRÔNICA"},;
		{"D6","IMPLANTE DE DISPOSITIVO INTRAUTERINO – DIU"},;
		{"E","INTERNAÇÕES"},{"E1","TIPO DE INTERNAÇÃO"},;
		{"E11","CLÍNICA"},{"E12","CIRÚRGICA"},;
		{"E121","CIRURGIA BARIÁTRICA"},{"E122","LAQUEADURA TUBÁRIA"},;
		{"E123","VASECTOMIA"},{"E124","FRATURA DE FÊMUR (60 ANOS OU MAIS)"},;
		{"E125","REVISÃO DE ARTROPLASTIA"},{"E126","IMPLANTE DE CDI (CARDIODESFIBRILADOR IMPLANTÁVEL)"},;
		{"E127","IMPLANTAÇÃO DE MARCAPASSO"},{"E13","OBSTÉTRICIA"},;
		{"E131","PARTO NORMAL"},{"E132","PARTO CESÁREO"},;
		{"E14","PEDIÁTRICA"},{"E141","INTERNAÇÃO DE 0 A 5 ANOS DE IDADE POR DOENÇA RESPIRATÓRIAS"},;
		{"E142","INTERNAÇÃO EM UTI NO PERÍODO NEONATAL"},{"E1421","INTERNAÇÕES EM UTI NO PERÍODO NEONATAL POR ATÉ 48 HORAS"},;
		{"E15","PSIQUIATRIA"},{"E2","REGIME DE INTERNAÇÃO"},;
		{"E21","HOSPITALAR"},{"E22","HOSPITAL-DIA"},;
		{"E221","HOSPITAL - DIA PARA SAÚDE MENTAL"},{"E23","DOMICILIAR"},;
		{"G","NASCIDOS VIVOS"},;
		{"H","DEMAIS DESPESAS HOSPITALARES"},;
		{"F","CAUSAS SELECIONADAS DE INTERNAÇÃO"},{"F1","NEOPLASIAS"},;
		{"F11","CÂNCER DE MAMA FEMININO"},{"F111","TRATAMENTO CIRÚRGICO DE CÂNCER DE MAMA FEMININO"},;
		{"F12","CÂNCER DE COLO DE ÚTERO"},{"F121","TRATAMENTO CIRÚRGICO DE CÂNCER DE COLO DE ÚTERO"},;
		{"F13","CÂNCER DE CÓLON E RETO"},{"F131","TRATAMENTO CIRÚRGICO DE CÂNCER DE CÓLON E RETO"},;
		{"F14","CÂNCER DE PRÓSTATA"},{"F141","TRATAMENTO CIRÚRGICO DE CÂNCER DE PRÓSTATA"},;
		{"F2","DIABETES MELLITUS"},{"F3","DOENÇAS DO APARELHO CIRCULATÓRIO"},;
		{"F31","INFARTO AGUDO DO MIOCÁRDIO"},{"F32","DOENÇAS HIPERTENSIVAS"},;
		{"F33","INSUFICIÊNCIA CARDÍACA CONGESTIVA"},{"F34","DOENÇAS CEREBROVASCULARES"},;
		{"F341","ACIDENTE VASCULAR CEREBRAL"},{"F4","DOENÇAS DO APARELHO RESPIRATÓRIO"},;
		{"F41","DOENÇA PULMONAR OBSTRUTIVA CRÔNICA"},{"F5","CAUSAS EXTERNAS"},;
		{"I","PROCEDIMENTOS ODONTOLÓGICOS"},{"I1","CONSULTAS ODONTOLÓGICAS INICIAIS"},;
		{"I2","EXAMES RADIOGRÁFICOS"},{"I3","PROCEDIMENTOS PREVENTIVOS"},;
		{"I31","ATIVIDADE EDUCATIVA INDIVIDUAL"},{"I32","APLICAÇÃO TÓPICA PROFISSIONAL DE FLÚOR POR HEMI-ARCADA"},;
		{"I33","SELANTE POR ELEMENTO DENTÁRIO (MENORES DE 12 ANOS)"},{"I4","RASPAGEM SUPRA-GENGIVAL POR HEMI-ARCADA (12 ANOS OU MAIS)"},;
		{"I5","RESTAURAÇÃO EM DENTES DECÍDUOS POR ELEMENTO (MENORES DE 12 ANOS)"},{"I6","RESTAURAÇÃO EM DENTES PERMANENTES POR ELEMENTO (12 ANOS OU MAIS)"},;
		{"I7","EXODONTIAS SIMPLES DE PERMANENTES (12 ANOS OU MAIS)"},{"I8","TRATAMENTO ENDODÔNTICO CONCLUÍDO EM DENTES DECÍDUOS POR ELEMENTO (MENORES DE 12 ANOS)"},;
		{"I9","TRATAMENTO ENDODÔNTICO CONCLUÍDO EM DENTES PERMANENTES POR ELEMENTO (12 ANOS OU MAIS)"},{"I10","PRÓTESES ODONTOLÓGICAS"},;
		{"I11","PRÓTESES ODONTOLÓGICAS UNITÁRIAS (COROA TOTAL E RESTAURAÇÃO METÁLICA FUNDIDA)"};
		}
	Local nPos := aScan(aItens,{|item| item[1] == cItem })
	Local cDescri := ""

	If nPos > 0
		cDescri := aItens[nPos][2]
	EndIf
Return cDescri

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} montaFields

Carrega os campos do browse de vencimentos

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function montaFields(aCampos)

	Local cPicture := "@!"
	Local nAlign   := 1
	Local aFields  := {}
	Local cTriAtu	:= B3D->B3D_ANO + SubStr(B3D->B3D_CODIGO,2,2)
	Local cTriAnt	:= getTriAnt()

	aAdd(aFields,GetColuna(aCampos[PB3MITEM,CAMPO]		,"Item"  									,aCampos[PB3MITEM,TIPO] 	,cPicture,nAlign,aCampos[PB3MITEM,TAMANHO] 		,aCampos[PB3MITEM,DECIMAL]		))
	aAdd(aFields,GetColuna(aCampos[PB3MDESCRI,CAMPO]	,"Descrição"    							,aCampos[PB3MDESCRI,TIPO]	,cPicture,nAlign,aCampos[PB3MDESCRI,TAMANHO]	,aCampos[PB3MDESCRI,DECIMAL]	))
	aAdd(aFields,GetColuna(aCampos[PB3MEVENTOS,CAMPO]	,"Qtd. Eventos " + cTriAtu					,aCampos[PB3MEVENTOS,TIPO]	,cPicture,nAlign,aCampos[PB3MEVENTOS,TAMANHO]	,aCampos[PB3MEVENTOS,DECIMAL]	))
	aAdd(aFields,GetColuna(aCampos[PB3MANTEVE,CAMPO]	,"Qtd. Eventos " + cTriAnt 					,aCampos[PB3MANTEVE,TIPO]	,cPicture,nAlign,aCampos[PB3MANTEVE,TAMANHO]	,aCampos[PB3MANTEVE,DECIMAL]	))
	aAdd(aFields,GetColuna(aCampos[PB3MDIFEVE,CAMPO]	,"Var Eventos " + cTriAtu + "/" + cTriAnt 	,aCampos[PB3MDIFEVE,TIPO]	,cPicture,nAlign,aCampos[PB3MDIFEVE,TAMANHO]	,aCampos[PB3MDIFEVE,DECIMAL]	))
	aAdd(aFields,GetColuna(aCampos[PB3MEXPOSTOS,CAMPO]	,"Qtd. Expostos " + cTriAtu					,aCampos[PB3MEXPOSTOS,TIPO]	,cPicture,nAlign,aCampos[PB3MEXPOSTOS,TAMANHO]	,aCampos[PB3MEXPOSTOS,DECIMAL]	))
	aAdd(aFields,GetColuna(aCampos[PB3MANTEXP,CAMPO]	,"Qtd. Expostos " + cTriAnt 				,aCampos[PB3MANTEXP,TIPO]	,cPicture,nAlign,aCampos[PB3MANTEXP,TAMANHO]	,aCampos[PB3MANTEXP,DECIMAL]	))
	aAdd(aFields,GetColuna(aCampos[PB3MDIFEXP,CAMPO]	,"Var Expostos " + cTriAtu + "/" + cTriAnt  ,aCampos[PB3MDIFEXP,TIPO]	,cPicture,nAlign,aCampos[PB3MDIFEXP,TAMANHO]	,aCampos[PB3MDIFEXP,DECIMAL]	))
	aAdd(aFields,GetColuna(aCampos[PB3MCUSTO,CAMPO]		,"Custo Total " + cTriAtu					,aCampos[PB3MCUSTO,TIPO]	,"@E 999,999,999.99",nAlign,aCampos[PB3MCUSTO,TAMANHO]		,aCampos[PB3MCUSTO,DECIMAL]		))
	aAdd(aFields,GetColuna(aCampos[PB3MANTCUSTO,CAMPO]	,"Custo Total " + cTriAnt 					,aCampos[PB3MANTCUSTO,TIPO]	,"@E 999,999,999.99",nAlign,aCampos[PB3MANTCUSTO,TAMANHO]	,aCampos[PB3MANTCUSTO,DECIMAL]	))
	aAdd(aFields,GetColuna(aCampos[PB3MDIFCUSTO,CAMPO]	,"Var Custo " + cTriAtu + "/" + cTriAnt 	,aCampos[PB3MDIFCUSTO,TIPO]	,cPicture,nAlign,aCampos[PB3MDIFCUSTO,TAMANHO]	,aCampos[PB3MDIFCUSTO,DECIMAL]	))

Return aFields

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetColuna

Retorna uma coluna para o markbrowse

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function GetColuna(cCampo,cTitulo,cTipo,cPicture,nAlign,nSize,nDecimal)

	Local   aColuna  := {}
	Local   bData    := &("{||" + cCampo +"}")
	Default nAlign   := 1
	Default nSize    := 20
	Default nDecimal := 0
	Default cTipo    := "C"

	aColuna := {cTitulo,bData,cTipo,cPicture,nAlign,nSize,nDecimal,.T.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return aColuna
