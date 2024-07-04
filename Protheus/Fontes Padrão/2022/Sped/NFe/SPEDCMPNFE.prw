#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'spedcmpnfe.ch'
#include 'fileio.ch'

#define AMBIENTE    1
#define HORAVERAO   2
#define HORARIO     3
#define EVENTO      4

#define TPAUTOR     1
#define UFAUTOR     2
#define DTENTREGA   3
#define TMENTREGA   4
#define DOCUMENTO   5
#define NOME        6
#define LATITUDE    7
#define LONGITUDE   8
#define COMPROVANTE 9
#define CHAVENFE    10
#define DOC         11
#define SERIE       12
#define CODCLIFOR   13
#define LOJA        14
#define EMISSAO     15

static _lUsaColab   := .F.
static _cIdEnt      := ""
static _cVersaoTSS  := ""

/*/{Protheus.doc} SPEDCMPNFE
    Chamada da rotina de Comprovante de Entrega da NFe

@version  P12
/*/
function SPEDCMPNFE(cIdEnt, cVersaoTSS)
	local aPerg      := {}
	local cTitleBkp  := cCadastro
	local lSdoc      := GetSX3Cache("F2_SERIE","X3_TAMANHO") == 14

	default cIdEnt      := RetIdEnti()
	default cVersaoTSS	:= getVersaoTSS()

	aAdd(aPerg, { 2 , STR0001 , PadR("",Len(STR0003))							    , {STR0002,STR0003}	 , 80	,				, .T.	,		}) // "Tipo de NFe"###"1-Saída"###"2-Entrada"
	aAdd(aPerg, { 1 , STR0004 , Space(GetSX3Cache('A1_COD','X3_TAMANHO'))			, ""				 , ".T."	, "SpedCnsCad( substr(MV_PAR01,1,1), @MV_PAR02, @MV_PAR03)", ".T."	, 50,.T.}) // "Cliente/Fornecedor"
	aAdd(aPerg, { 1 , STR0005 , Space(GetSX3Cache('A1_LOJA','X3_TAMANHO'))		    , ""				 , ".T."	, ""			, ".T."	, 30,.T.}) // "Loja"
	aAdd(aPerg, { 1 , STR0006 , PadR("",Len(if(lSdoc,SF2->F2_SDOC,SF2->F2_SERIE)))  , ""				 , ".T."	, ""			, ".T."	, 30,.T.}) // "Série da Nota Fiscal"
	aAdd(aPerg, { 1 , STR0007 , space(GetSX3Cache("F2_DOC",'X3_TAMANHO'))			, ""				 , ".T."	, ""			, ".T."	, 30,.F.}) // "Nota Fiscal Inicial"
	aAdd(aPerg, { 1 , STR0008 , space(GetSX3Cache("F2_DOC",'X3_TAMANHO'))			, ""				 , ".T."	, ""			, ".T."	, 30,.F.}) // "Nota Fiscal Final"
	aAdd(aPerg, { 1 , STR0009 , date()											    , ""				 , ".T."	, ""			, ".T."	, 80,.F.}) // "Dt. de emissão inicial"
	aAdd(aPerg, { 1 , STR0010 , date()											    , ""				 , ".T."	, ""			, ".T."	, 80,.F.}) // "Dt. de emissão final"

	cCadastro := STR0014 // "Comprovante de Entrega NF-e"
	if ParamBox(aPerg, cIdEnt + " - " + cVersaoTSS,, {|| filEvento() },,,,,,"SPEDNFE_COMPR"+alltrim(FWGrpCompany())+alltrim(FWCodFil()),.T.,.T.)
		SPDCOMPNFE( , , cIdEnt, cVersaoTSS)
	endif
	cCadastro := cTitleBkp

return

/*/{Protheus.doc} filEvento
    Validações para filtro inicial dos Evento

/*/
static function filEvento()
	local lRet := .T.
	local cMsg := ""

	if MV_PAR06 < MV_PAR05
		cMsg += STR0016 + CRLF // "Nota fiscal final menor que a inicial."
	endif

	if MV_PAR08 < MV_PAR07
		cMsg += STR0017 + CRLF // "Data de emissão final menor que a inicial."
	endif

	lRet := if( empty(cMsg), .T., (.F., Help(,,STR0018 ,, STR0019 ,1,0,,,,,, {cMsg}))) // "Atenção" ## "Revise as informações a seguir:"

return lRet


/*/{Protheus.doc} SPDCOMPNFE
    Chamada da rotina de Comprovante de Entrega da NFe

@version  P12
/*/
function SPDCOMPNFE(cTabDoc, cWhere, cIdEnt, cVersaoTSS)
	local aArea      := getArea()
	local aAreaTab   := {}
	local cAliasQry  := ""
	local aCampos    := {}
	local cQuery     := ""

	default cTabDoc     := getTab()
	default cWhere      := getWhere()
	default cIdEnt      := RetIdEnti()
	default cVersaoTSS	:= getVersaoTSS()

	private lSdoc := GetSX3Cache("F2_SERIE","X3_TAMANHO") == 14

	begin sequence

		if  (empty(cTabDoc) .or. !(alltrim(cTabDoc) $ "SF1||SF2")) .or.;
				(empty(cWhere))
			break
		endif

		if _lUsaColab == nil
			_lUsaColab := ColUsaColab("1")
		endif

		_cIdEnt := cIdEnt
		_cVersaoTSS := cVersaoTSS

		dbSelectArea(cTabDoc)
		aAreaTab := (cTabDoc)->(getArea())

		cAliasQry := getDocs( cWhere, cTabDoc, @aCampos, @cQuery)

		(cAliasQry)->(dbgotop())
		if (cAliasQry)->(!Eof())
			CompNfe(cAliasQry, cTabDoc, aCampos, cQuery)
		else
			Help(nil, nil, STR0014, nil, STR0020, 1, 0, nil, nil, nil, nil, nil, {STR0021}) // "Comprovante de Entrega NF-e" ### "Nenhum documento encontrado para o envio do evento Comprovante de Entrega." ### "Verifique os dados do filtro."
		endif

		(cAliasQry)->(dbCloseArea())
		restArea(aAreaTab)

	end sequence

	restArea(aArea)

return

/*/{Protheus.doc} getTab
    Retorna tabela de negocio SF1 ou SF2

/*/
static function getTab()
	local cTabDoc		:= ""

	cTabDoc := "SF2"
	if substr(MV_PAR01,1,1) == "2" // Entrada
		cTabDoc := "SF1"
	endif

return cTabDoc

/*/{Protheus.doc} getWhere
    Retorna Where da query

/*/
static function getWhere(cTipoNfe, cCliFor, cLoja, cSerie, cDocIni, cDocFim, dDtIni, dDtFim)
	local cTabDoc		:= ""
	local cCpCliFor		:= ""
	local cWhere		:= ""

	default cTipoNfe := substr(alltrim(MV_PAR01),1,1)
	default cCliFor  := MV_PAR02
	default cLoja    := MV_PAR03
	default cSerie   := MV_PAR04
	default cDocIni  := MV_PAR05
	default cDocFim  := MV_PAR06
	default dDtIni   := MV_PAR07
	default dDtFim   := MV_PAR08

	lSdoc := if(type("lSdoc") == "U", GetSX3Cache("F2_SERIE","X3_TAMANHO") == 14, lSdoc)
	cTabDoc := "F2"
	cCpCliFor := 'F2_CLIENTE'
	if cTipoNfe == "2" // Entrada
		cTabDoc := "F1"
		cCpCliFor := "F1_FORNECE"
		//cWhere += " AND F1_FORMUL = 'S' "
	endif

	cWhere := " " + cTabDoc + "_FILIAL = '" + xFilial("S" + cTabDoc) + "' "
	cWhere += " AND " + "S" + cTabDoc + ".D_E_L_E_T_ = ' ' "
	cWhere += " AND " + cTabDoc + "_CHVNFE <> ' ' "
	cWhere += " AND " + cTabDoc + "_ESPECIE = 'SPED' "

	//if cTipoNfe == "2" // Entrada
	//    cWhere += " AND F1_FORMUL = 'S' "
	//endif

	if !empty(cSerie)
		cWhere += " AND " + if( lSdoc, " " + cTabDoc + "_SDOC = '" + cSerie + "' " , " " + cTabDoc + "_SERIE = '" + cSerie + "' ")
	endif

	if !empty(cCliFor) .and. !empty(cLoja)
		cWhere += " AND " + cCpCliFor + " = '" + cCliFor + "' AND " + cTabDoc + "_LOJA = '" + cLoja + "' "
	endif

	if !empty(cDocIni) .or. !empty(cDocFim)
		cWhere += if( cDocIni == cDocFim, " AND " + cTabDoc + "_DOC = '" + cDocIni + "' "      , " AND " + cTabDoc + "_DOC BETWEEN '" + cDocIni + "' AND '" + cDocFim + "' ")
	endif

	if !empty(dDtIni) .or. !empty(dDtFim)
		cWhere += if( dDtIni == dDtFim, " AND " + cTabDoc + "_EMISSAO = '" + dtos(dDtIni) + "' ", " AND " + cTabDoc + "_EMISSAO BETWEEN '" + dtos(dDtIni) + "' AND '" + dtos(dDtFim) + "' ")
	endif

return cWhere

/*/{Protheus.doc} getDocs
    Retorna o alias resultante da query

/*/
static function getDocs( cWhere, cTabDoc, aCampos, cQuery)
	local cAliasQry := ""
	local cTbDoc    := ""
	local cCpCliFor := ""
	local cCampos   := ""

	default cWhere   := ""
	default cTabDoc  := ""
	default aCampos  := {}
	default cQuery   := ""

	cTbDoc := substr(cTabDoc, 2, 2)

	cWhere := if(at("%", cWhere) == 0 , '% ' + cWhere + ' %', cWhere)

	cAliasQry := getNextAlias()
	cCpCliFor := if( cTabDoc == "SF1","F1_FORNECE","F2_CLIENTE")

	aAdd( aCampos, { cTbDoc + "_DOC"    , STR0022, 0 }) // "Documento"
	aAdd( aCampos, { cTbDoc + "_SERIE"  , STR0023, 0 }) // "Serie"
	aAdd( aCampos, { cCpCliFor          , STR0024, 20 }) // "Cliente/Fornecedor"
	aAdd( aCampos, { cTbDoc + "_LOJA"   , STR0005, 0 }) // "Loja"
	aAdd( aCampos, { cTbDoc + "_CHVNFE" , STR0026, 0 }) // "Chave da Nfe"
	aAdd( aCampos, { cTbDoc + "_EMISSAO", STR0027, 0 }) // "Data de Emissão"

	cCampos := "% " + cTbDoc + "_DOC, " +  cTbDoc + "_SERIE, " + cCpCliFor + ", "  + cTbDoc + "_LOJA, " + cTbDoc + "_CHVNFE, " + cTbDoc + "_EMISSAO, " + cTabDoc + ".R_E_C_N_O_ RECNO %"

	if cTabDoc == "SF1"
		BeginSql Alias cAliasQry
            SELECT %Exp:cCampos%
            FROM %Table:SF1% SF1
            WHERE
                %Exp:cWhere%
            ORDER BY 1
		EndSql
	else
		BeginSql Alias cAliasQry
            SELECT %Exp:cCampos%
            FROM %Table:SF2% SF2
            WHERE
                %Exp:cWhere%
            ORDER BY 1
		EndSql
	endif

	cQuery := getLastQuery()[2]

return cAliasQry

/*/{Protheus.doc} CompNfe
    Apresenta a interface com as notas após o filtro

/*/
static function CompNfe( cAliasQry, cTabDoc, aCampos, cQuery)
	local cAliasBrw  := ""
	local cTbDoc     := ""
	local cTitle     := ""
	local aSeek      := {}
	local aIndex     := {}
	local aSize      := {}
	local aColumns   := {}
	local nCol       := 0
	local cTipo      := ""
	local oDlgComp   := nil
	local oBrwComp   := nil

	default cAliasQry    := ""
	default cTabDoc      := ""
	default aCampos      := {}
	default cQuery       := getLastQuery()[2]

	cTbDoc := substr(cTabDoc, 2, 2)
	cTitle := STR0014 + " - " + _cIdEnt + " - " + _cVersaoTSS // Comprovante de Entrega NF-e

	aAdd( aSeek, { STR0022 , {{"","C", GetSX3Cache( cTbDoc + "_DOC","X3_TAMANHO"), 0 , STR0022,,}}} ) // "Documento"
	aAdd( aSeek, { STR0026 , {{"","C", GetSX3Cache( cTbDoc + "_CHVNFE","X3_TAMANHO") , 0 , STR0026,,}}} ) // "Chave da Nfe"

	aAdd( aIndex, cTbDoc + "_DOC" )
	aAdd( aIndex, cTbDoc + "_CHVNFE" )

	aColumns := {}
	for nCol := 1 to len(aCampos)
		aAdd(aColumns,FWBrwColumn():New())
		cTipo := GetSX3Cache( aCampos[nCol][1], "X3_TIPO")
		if cTipo == "D"
			aColumns[len(aColumns)]:SetData( &("{|| DtoC(StoD(" + aCampos[nCol][1] + ")) }") )
		else
			aColumns[len(aColumns)]:SetData( &("{||" + aCampos[nCol][1] + "}") )
		endif
		aColumns[len(aColumns)]:SetTitle( aCampos[nCol][2] )
		aColumns[len(aColumns)]:SetPicture( GetSX3Cache( aCampos[nCol][1], "X3_PICTURE") )
		aColumns[len(aColumns)]:SetType( cTipo )
		aColumns[len(aColumns)]:SetSize( if( aCampos[nCol][3] == 0 , GetSX3Cache( aCampos[nCol][1], "X3_TAMANHO"), aCampos[nCol][3] ) )
		aColumns[len(aColumns)]:SetDecimal( GetSX3Cache( aCampos[nCol][1], "X3_DECIMAL") )
	next

	if (cAliasQry)->(!eof())
		aSize := MsAdvSize()
		cAliasBrw := getNextAlias()
		DEFINE MSDIALOG oDlgComp TITLE OemToAnsi(cTitle) FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL STYLE WS_DLGFRAME

		oBrwComp := FWFormBrowse():New()
		oBrwComp:SetOwner(oDlgComp)
		oBrwComp:SetDataQuery(.T.)
		oBrwComp:SetAlias(cAliasBrw)
		oBrwComp:SetQueryIndex(aIndex)
		oBrwComp:SetQuery(cQuery)
		oBrwComp:SetShowLimit( .T. )
		oBrwComp:SetSeek(,aSeek)
		oBrwComp:SetDescription(cTitle)
		oBrwComp:SetMenuDef("")
		oBrwComp:DisableDetails()

		oBrwComp:AddButton(STR0028,{||oDlgComp:End()},,,,.F.) // Sair
		if !_lUsaColab
			oBrwComp:AddButton(STR0029,{|| SpedNFeCfg()},,,,.F.) // "Wiz.Config."
		endif
		oBrwComp:AddButton(STR0011,{|| SpedCCePar()},,,,.F.) // "Parametros"

		oBrwComp:AddButton(STR0030,{|| Transmitir(cTabDoc, cAliasBrw) },,,,.F.) // "Transmissao"
		oBrwComp:AddButton(STR0031,{|| Monitorar(cTabDoc) },,,,.F.) // "Monitor"

		oBrwComp:AddButton(STR0032,{|| Exportar(cTabDoc) },,,,.F.) // "Exportar"
		oBrwComp:AddButton(STR0033,{|| VisualDoc(cTabDoc, cAliasBrw) },,,,.F.) // "Visualiza Doc."
		oBrwComp:AddButton(STR0034,{|| lBtnFiltro := .T., oDlgComp:End() },,,,.F.) // "Filtro"
		oBrwComp:SetColumns(aColumns)

		oBrwComp:Activate()

		ACTIVATE MSDIALOG oDlgComp CENTERED
	endif

	FwFreeObj( oBrwComp )
	FwFreeObj( oDlgComp )

return

/*/{Protheus.doc} Transmitir
    Função responsável por realizar o processo de envio do evento, chamada a partir do Menu

/*/
static function Transmitir(cTabDoc, cAliasBrw)
	local aArea      := {}
	local aAreaTab   := {}
	local nRecTab    := 0
	local aCoords    := {}
	local oStepWiz   := nil
	local oStep1     := nil
	local oStep2     := nil
	local oStep3     := nil
	local aConfig    := {}
	local aInfConf   := {"","","",0}
	local aDadosCom  := {"","",ctod(""),"","","","","","","","","","","",ctod("")}
	local cError     := ""

	default cTabDoc      := ""
	default cAliasBrw    := ""

	if (cAliasBrw)->(!eof())

		aArea := getArea()
		dbSelectArea(cTabDoc)
		aAreaTab := (cTabDoc)->(getArea())

		nRecTab := (cAliasBrw)->RECNO
		(cTabDoc)->(dbgoTo(nRecTab))
		if (cTabDoc)->(recno()) == nRecTab

			aCoords := FWGetDialogSize()

			oStepWiz := FWWizardControl():New(,{aCoords[3] * 0.9, aCoords[4] * 0.9})
			oStepWiz:ActiveUISteps()

			oStep1 := oStepWiz:AddStep("1",{|Panel| Monitor(Panel, cTabDoc, cAliasBrw, @cError, @aDadosCom) })
			oStep1:SetStepDescription(STR0015) // "Comprovante de Entrega"
			oStep1:SetNextTitle(STR0038) // "Avançar"
			oStep1:SetNextAction({|| GetConf(@cError, @aConfig) })
			oStep1:SetCancelAction({|| MsgYesNo(STR0039 , STR0014 ) }) // "Deseja cancelar o envio do evento?" ### "Comprovante de Entrega NF-e"

			oStep2 := oStepWiz:AddStep("2", {|Panel| IntEnvio(Panel, cAliasBrw, aConfig, @aInfConf, @aDadosCom)})
			oStep2:SetStepDescription(STR0040) // "Informações"
			oStep2:SetPrevTitle(STR0041) // "Voltar"
			oStep2:SetNextTitle(STR0042) // "Enviar"
			oStep2:SetNextAction({|| VldEnvio(@cError, aInfConf, aDadosCom) })
			oStep2:SetCancelAction({|| MsgYesNo(STR0039 , STR0014 ) }) // "Deseja cancelar o envio do evento?" ### "Comprovante de Entrega NF-e"

			oStep3 := oStepWiz:AddStep("3", {|Panel| ExecResult(Panel, cTabDoc, cAliasBrw, aInfConf, aDadosCom)})
			oStep3:SetStepDescription(STR0043) // "Monitor"
			oStep3:SetPrevTitle(STR0041) // "Voltar"
			oStep3:SetNextTitle(STR0044) // "Finalizar"
			oStep3:SetPrevWhen( {|| .F.} )
			oStep3:SetCancelWhen( {|| .F. } )

			oStepWiz:Activate()
			oStepWiz:Destroy()

		endif

		restArea(aAreaTab)
		restArea(aArea)

	endif

	FwFreeObj( oStepWiz )

return

/*/{Protheus.doc} Monitor
    Primeira tela do Wizard

/*/
static function Monitor(oPanel, cTabDoc, cAliasBrw, cError, aInfCom)
	local nRecTab    := (cAliasBrw)->RECNO
	local oTela      := nil
	local cIdUp      := ""
	local cIdMiddle  := ""
	local cIdDown    := ""
	local oPanelUp   := nil
	local oPnlUp     := nil
	local oPnlMiddle := nil
	local oPnlDown   := nil
	local nLin       := 0
	local nCol       := 0
	local cTbDoc     := ""
	local oFont      := nil
	local oList      := nil

	default cError   := ""
	default aInfCom  := {}

	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	FwFreeObj(oTela)
	oTela := FWFormContainer():New( oPanel )
	cIdUp := oTela:CreateHorizontalBox(45)
	cIdMiddle := oTela:CreateHorizontalBox(5)
	cIdDown := oTela:CreateHorizontalBox(50)

	oTela:Activate( oPanel, .T. )
	oPanelUp := oTela:GeTPanel( cIdUp )
	oPanelUp:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlMiddle := oTela:GeTPanel( cIdMiddle )
	oPnlMiddle:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlDown := oTela:GeTPanel( cIdDown )
	oPnlDown:Align := CONTROL_ALIGN_ALLCLIENT

	nLin := 5
	nCol := 5
	cTbDoc := substr(cTabDoc, 2, 2)
	oFont := TFont():New(,,-12,.T.,.T.,,,,,)
	oPnlUp := TScrollBox():New(oPanelUp,01,01,92,260,.T.,.T.,.F.)
	oPnlUp:Align := CONTROL_ALIGN_ALLCLIENT

	if !FwIsInCallStack("Monitorar")
		TSay():New(nLin,nCol, {|| STR0045 },oPnlUp,,oFont,,,,.T.,CLR_BLUE,) // "Dados da Nota"
		nLin += 15
	endif

	if len(aInfCom) > 0
		aInfCom[CHAVENFE] := (cAliasBrw)->&(cTbDoc + "_CHVNFE")
	endif

	TSay():New(nLin,nCol, {|| STR0046 + ": " },oPnlUp,,oFont,,,,.T.,,) // "Chave de acesso"
	TSay():New(nLin+1,nCol+70, {|| (cAliasBrw)->&(cTbDoc + "_CHVNFE") },oPnlUp,,,,,,.T.,,)

	nLin += 15
	TSay():New(nLin,nCol, {|| STR0022 + ": " },oPnlUp,,oFont,,,,.T.,,) // "Documento"
	TSay():New(nLin+1,nCol+70, {|| aInfCom[DOC] := (cAliasBrw)->&(cTbDoc + "_DOC") },oPnlUp,,,,,,.T.,,)
	TSay():New(nLin,nCol + 150, {|| STR0023 + ": " },oPnlUp,,oFont,,,,.T.,,) // "Serie
	TSay():New(nLin+1,nCol + 220, {|| aInfCom[SERIE] := (cAliasBrw)->&(cTbDoc + "_SERIE") },oPnlUp,,,,,,.T.,,)

	nLin += 15
	if cTabDoc == "SF1"
		TSay():New(nLin,nCol, {|| STR0047 + ": " },oPnlUp,,oFont,,,,.T.,,) // "Fornecedor"
		TSay():New(nLin+1,nCol+70, {|| aInfCom[CODCLIFOR] := (cAliasBrw)->&("F1_FORNECE") },oPnlUp,,,,,,.T.,,)
	else
		TSay():New(nLin,nCol, {|| STR0048 + ": " },oPnlUp,,oFont,,,,.T.,,) // "Cliente"
		TSay():New(nLin+1,nCol+70, {|| aInfCom[CODCLIFOR] := (cAliasBrw)->&("F2_CLIENTE") },oPnlUp,,,,,,.T.,,)
	endif
	TSay():New(nLin,nCol + 150, {|| STR0005 + ": " },oPnlUp,,oFont,,,,.T.,,) // "Loja"
	TSay():New(nLin+1,nCol + 220, {|| aInfCom[LOJA] := (cAliasBrw)->&(cTbDoc + "_LOJA") },oPnlUp,,,,,,.T.,,)

	nLin += 15
	TSay():New(nLin,nCol, {|| STR0027 + ": " },oPnlUp,,oFont,,,,.T.,,) // "Data de Emissão"
	TSay():New(nLin+1,nCol+70, {|| aInfCom[EMISSAO] := stod((cAliasBrw)->&(cTbDoc + "_EMISSAO")) },oPnlUp,,,,,,.T.,,)

	TSay():New(0.75,05,{|| STR0049 },oPnlMiddle,,oFont,,,,.T.,CLR_BLUE,) // "Eventos enviados"
	cError := ""
	createlist(@oPnlDown, @oList, @cError, cTabDoc, nRecTab, aInfCom[DOC], aInfCom[DOC], aInfCom[SERIE], aInfCom[CODCLIFOR], aInfCom[LOJA], aInfCom[EMISSAO], aInfCom[EMISSAO])

return

/*/{Protheus.doc} createlist
    Cria e atualiza o retorno do monitor

/*/
static function createlist(oPnlDown, oList, cError, cTabDoc, nRecTab, cDocIni, cDocFim, cSerie, cCliFor, cLoja, dDtIni, dDtFim, cTpEvento)
	local aMonitor := getListMon(@cError, cTabDoc, nRecTab,  cDocIni, cDocFim, cSerie, cCliFor, cLoja, dDtIni, dDtFim, cTpEvento)
	@030,010 LISTBOX oList 	FIELDS HEADER "", STR0050, STR0051, STR0022, STR0023, STR0052, STR0053, STR0054, STR0055, STR0056, STR0057 SIZE 480,150 PIXEL OF oPnlDown // "Tipo do Evento", "Ambiente", "Documento", "Serie", "ID Evento", "Protocolo", "Status", "Mensagem", "Status do Evento", "Descrição do Evento"
	oList:Align := CONTROL_ALIGN_ALLCLIENT
	oList:SetArray(aMonitor)
	oList:bLine:={|| {aMonitor[oList:nAt][01],;
		aMonitor[oList:nAt][02],;
		aMonitor[oList:nAt][03],;
		aMonitor[oList:nAt][04],;
		aMonitor[oList:nAt][05],;
		aMonitor[oList:nAt][06],;
		aMonitor[oList:nAt][07],;
		aMonitor[oList:nAt][08],;
		aMonitor[oList:nAt][09],;
		aMonitor[oList:nAt][10],;
		aMonitor[oList:nAt][11]}}

return

/*/{Protheus.doc} GetConf
    Valida após primeira etapa

/*/
static function GetConf(cError, aConfig)
	local lOk        := .F.
	local oWs        := nil

	default cError     := ""
	default aConfig    := {}

	cError := ""
	oWS := WsSpedCfgNfe():New()
	aConfig := aClone(getCfgCCe(@cError, _cIdEnt))
	FwFreeObj(oWS)

	lOk := empty(cError) .and. len(aConfig) > 0
	if !lOk
		Help(" ",1,STR0015,,cError,1,0) // "Comprovante de Entrega"
	endif

return lOk

/*/{Protheus.doc} IntEnvio
    Segunda tela do Wizard

/*/
static function IntEnvio(oPanel, cAliasBrw, aConfig, aInfConf, aInfCom)
	local oTela      := nil
	local cIdPanel   := ""
	local cIdLeft    := ""
	local cIdRight   := ""
	local oPnlLeft   := nil
	local oPnlRight  := nil
	local oPnlConf   := nil
	local oPnlInf    := nil
	local cAmbiente  := ""
	local cHoraVerao := ""
	local cHorario   := ""
	local aEvento    := {}
	local cTpEvento  := ""
	local bOpcEvento := {|| }
	local nLin       := 0
	local nCol       := 0
	local nColGet    := 0
	local oFont      := nil
	local oComboEven := nil

	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	oTela := FWFormContainer():New( oPanel )
	cIdPanel := oTela:CreateHorizontalBox(100)
	cIdLeft := oTela:CreateVerticalBox(20, cIdPanel, .F.)
	cIdRight := oTela:CreateVerticalBox(80, cIdPanel, .F.)

	oTela:Activate( oPanel, .T. )
	oPnlLeft := oTela:GeTPanel( cIdLeft )
	oPnlLeft:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlConf := TScrollBox():New(oPnlLeft,01,01,92,260,.T.,.T.,.T.)
	oPnlConf:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlRight := oTela:GeTPanel( cIdRight )
	oPnlRight:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlInf := TScrollBox():New(oPnlRight,01,01,92,260,.T.,.T.,.F.)
	oPnlInf:Align := CONTROL_ALIGN_ALLCLIENT

	// Ambiente
	cAmbiente := alltrim(if( valtype(aConfig[1]) <> "U" , aConfig[1], STR0057 )) // "2-Homologacao"
	aInfConf[AMBIENTE] := cAmbiente

	// Horario de verao
	cHoraVerao := alltrim(if( valtype(aConfig[3]) <> "U", aConfig[3], "2" ))
	aInfConf[HORAVERAO] := cHoraVerao

	// Horario
	cHorario := alltrim(if( valtype(aConfig[2]) <> "U", aConfig[2], "2" ))
	aInfConf[HORARIO] := cHorario

	nLin := 5
	nCol := 5
	nColGet := 75
	oFont := TFont():New(,,-12,.T.,.T.,,,,,)
	TSay():New(nLin,nCol, {|| STR0059 },oPnlConf,,oFont,,,,.T.,CLR_RED,,50) // "Configuração"

	nLin += 15
	TSay():New(nLin,nCol, {|| STR0051 + ": " },oPnlConf,,oFont,,,,.T.,,,50) // "Ambiente"
	TSay():New(nLin+1,nCol+60, {|| cAmbiente },oPnlConf,,,,,,.T.,,,50)

	nLin += 15
	TSay():New(nLin,nCol, {|| STR0060 + ": " },oPnlConf,,oFont,,,,.T.,,,60) // "Horário de Versão
	TSay():New(nLin+1,nCol+60, {|| cHoraVerao },oPnlConf,,,,,,.T.,,,50)

	nLin += 15
	TSay():New(nLin,nCol, {|| STR0061 + ": " },oPnlConf,,oFont,,,,.T.,,,50) // "Horário"
	TSay():New(nLin+1,nCol+60, {|| cHorario },oPnlConf,,,,,,.T.,,,50)

	nLin += 40
	TSay():New(nLin,nCol, {|| STR0062 + ": " },oPnlConf,,oFont,,,,.T.,,,50) // "Evento"
	aEvento := {STR0015, STR0063} // "Comprovante de Entrega" ### "Cancelamento do Comprovante"
	cTpEvento := ""
	bOpcEvento := {|| aInfConf[EVENTO] := oComboEven:nAt ,;
		FwFreeObj(oPnlInf), oPnlInf := TScrollBox():New(oPnlRight,01,01,92,260,.T.,.T.,.F.), oPnlInf:Align := CONTROL_ALIGN_ALLCLIENT,;
		InfEvento(oComboEven:nAt, @oPnlInf, @aInfCom),;
		oPnlInf:refresh(), oPnlRight:refresh() }
	nLin += 15
	oComboEven := TComboBox():New(nLin,nCol, { |u| if(PCount()>0,cTpEvento:=u,cTpEvento)}, aEvento, 100, 20, oPnlConf,,bOpcEvento,,,,.T.,,,,,,,,,'cTpEvento')
	aInfConf[EVENTO] := oComboEven:nAt
	InfEvento(oComboEven:nAt, @oPnlInf, @aInfCom)

return

/*/{Protheus.doc} InfEvento
    cria a interface dos dados do evento

/*/
static function InfEvento(nOpcEvento, oPnlInf, aInfCom)
	local nLin       := 0
	local nCol       := 0
	local nColGet    := 0
	local oFont      := nil
	local aTpAutor   := {STR0012, STR0013} // "1-Empresa Emitente" # "2-Empresa Destinatária"
	local cTpAutor   := ""
	local aUf        := getUf()
	local cUfAutor   := ""
	local nPosUf     := 0
	local dDtEntrega := ctod("")
	local cTimeEnt   := space(8)
	local cNumDoc    := space(20)
	local cNome      := space(60)
	local cLatitude  := space(60)
	local cLongitude := space(60)
	local cImagem    := space(100)
	local oTBitmap   := nil
	local oPnlImg    := nil
	local oImagem    := nil

	default nOpcEvento := 1

	oFont := TFont():New(,,-12,.T.,.T.,,,,,)
	nLin := 5
	nCol := 5
	nColGet := 75
	TSay():New(nLin,nCol, {|| STR0064 },oPnlInf,,oFont,,,,.T.,CLR_RED,) // "Informações do evento"

	nLin += 15
	TSay():New(nLin+2,nCol, {|| STR0065 + ": " },oPnlInf,,oFont,,,,.T.,CLR_BLUE,) // "Tipo Autor"
	TComboBox():New(nLin,nColGet, { |u| if(PCount()>0,cTpAutor:=u,cTpAutor) , aInfCom[TPAUTOR] := cTpAutor}, aTpAutor, 100, 20, oPnlInf,,,,,,.T.,,,,,,,,,'cTpAutor')

	nLin += 20
	TSay():New(nLin+2,nCol, {|| STR0066 + ": " },oPnlInf,,oFont,,,,.T.,CLR_BLUE,) // "UF Autor
	if !empty(SM0->M0_ESTENT) .and. (nPosUf := aScan(aUf, {|X| "(" + alltrim(upper(SM0->M0_ESTENT)) + ")" $ X })) > 0
		cUfAutor := aUf[nPosUf]
	endif
	TComboBox():New(nLin,nColGet, { |u| if(PCount()>0,cUfAutor:=u,cUfAutor), aInfCom[UFAUTOR] := cUfAutor }, aUf, 100, 20, oPnlInf,,,,,,.T.,,,,,,,,,'cUfAutor')

	if nOpcEvento == 1// "110130"

		nLin += 20
		TSay():New(nLin+2,nCol, {|| STR0067 + ": " },oPnlInf,,oFont,,,,.T.,CLR_BLUE,) // "Data da Entrega"
		TGet():New(nLin,nColGet, { |u| if(PCount()>0,dDtEntrega:=u,dDtEntrega), aInfCom[DTENTREGA] := dDtEntrega },oPnlInf, 060, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtEntrega",,,,.T. )

		nLin += 20
		TSay():New(nLin+2,nCol, {|| STR0068 + ": " },oPnlInf,,oFont,,,,.T.,,) // "Hora da Entrega"
		TGet():New(nLin,nColGet, { |u| if(PCount()>0,cTimeEnt:=u,cTimeEnt), aInfCom[TMENTREGA] := cTimeEnt },oPnlInf, 060, 010, "99:99:99",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cTimeEnt",,,,.T. )

		nLin += 20
		TSay():New(nLin+2,nCol, {|| STR0069 + ": " },oPnlInf,,oFont,,,,.T.,CLR_BLUE,) // "Nº documento"
		TGet():New(nLin,nColGet, { |u| if(PCount()>0,cNumDoc:=u,cNumDoc), aInfCom[DOCUMENTO] := cNumDoc},oPnlInf, 060, 010, ,, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cNumDoc")

		nLin += 20
		TSay():New(nLin+2,nCol, {|| STR0070 + ": " },oPnlInf,,oFont,,,,.T.,CLR_BLUE,) // "Nome"
		TGet():New(nLin,nColGet, { |u| if(PCount()>0,cNome:=u,cNome), aInfCom[NOME] := cNome },oPnlInf, 100, 010, ,, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cNome")

		nLin += 20
		TSay():New(nLin+2,nCol, {|| STR0071 + ": " },oPnlInf,,oFont,,,,.T.,,) // "Latitude"
		TGet():New(nLin,nColGet, { |u| if(PCount()>0,cLatitude:=u,cLatitude), aInfCom[LATITUDE] := cLatitude },oPnlInf, 100, 010, ,, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cLatitude")

		nLin += 20
		TSay():New(nLin+2,nCol, {|| STR0072 + ": " },oPnlInf,,oFont,,,,.T.,,) // "Longitude"
		TGet():New(nLin,nColGet, { |u| if(PCount()>0,cLongitude:=u,cLongitude), aInfCom[LONGITUDE] := cLongitude },oPnlInf, 100, 010, ,, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cLongitude")

		nLin := 5
		nCol := 230
		TSay():New(nLin+2,nCol, {|| STR0073 + ": " },oPnlInf,,oFont,,,,.T.,CLR_BLUE,) // "Comprovante"

		nLin += 15
		nColGet := 225
		TGet():New(nLin,nColGet + 60, { |u| if(PCount()>0,cImagem:=u,cImagem), aInfCom[COMPROVANTE] := cImagem },oPnlInf, 150, 010,,, 0, 16777215,,.F.,,.T.,,.F.,{ || .F.},.F.,.F.,,.F.,.F. ,,"cImagem")
		TButton():New(nLin, nColGet + 5, STR0073 , oPnlInf,{|| cImagem := cGetFile("*|*", STR0074 ,0,"",.T.,GETF_LOCALHARD), if(!empty(cImagem), oTBitmap:load(,cImagem), nil) },50,12,,oPnlInf:oFont,,.T.,.F.,,.T., ,, .F.) // "Comprovante" ###  "Selecione o comprovante"

		nLin += 15
		oPnlImg := tPanel():New(nLin,nCol,"",oPnlInf,,,,CLR_YELLOW,CLR_BLUE,nColGet,130)
		oImagem := TScrollBox():New(oPnlImg,nLin,nCol,oPnlInf:nHeight,oPnlInf:nWidth,.T.,.T.,.F.)
		oImagem:Align := CONTROL_ALIGN_ALLCLIENT
		oTBitmap := TBitmap():New(5,5,oImagem:nWidth,oImagem:nHeight,,cImagem,.T.,oImagem,,,.T.,.F.,,,,{||.F.},.T.)
		oTBitmap:lAutoSize := .T.
		oTBitmap:Align := CONTROL_ALIGN_ALLCLIENT

	endif

return

/*/{Protheus.doc} VldEnvio
    Valida após segunda etapa

/*/
static function VldEnvio(cError, aInfConf, aInfCom)
	local lRet       := .F.
	local aTpEvento  := {}
	local aUf        := {}

	begin sequence

		if aInfConf[EVENTO] <> 1 .and. aInfConf[EVENTO] <> 2
			cError := STR0075 // "Evento não informado."
			break
		endif

		if empty(aInfCom[TPAUTOR])
			cError := STR0076 // "Tipo do autor do evento não informado corretamente."
			break
		endif

		aUf := getUf()
		if empty(aInfCom[UFAUTOR]) .or. aScan( aUf, { |X| X == aInfCom[UFAUTOR]}) == 0
			cError := STR0077 // "UF do autor do evento não informado corretamente."
			break
		endif

		if aInfConf[EVENTO] == 1 // "110130"
			if empty(aInfCom[DTENTREGA])
				cError := STR0078 // "Data de entrega não informado."
				break
			endif

			if !empty(alltrim(strtran(aInfCom[TMENTREGA], ":",""))) .and. ( len(strtran(aInfCom[TMENTREGA], " ", "")) < 8 .or. !(aInfCom[TMENTREGA] >= "00:00:00" .and. aInfCom[TMENTREGA] < "23:59:59") )
				cError := STR0079 // "Informe o horario corretamente."
				break
			endif

			if empty(aInfCom[DOCUMENTO])
				cError := STR0080 // "Número de documento não informado."
				break
			endif

			if empty(aInfCom[NOME])
				cError := STR0081 // "Nome não informado."
				break
			endif

			if empty(aInfCom[COMPROVANTE])
				cError := STR0082 // "Comprovante de entrega não informado."
				break
			endif

			if !file(aInfCom[COMPROVANTE])
				cError := STR0083 + " - " + alltrim(aInfCom[COMPROVANTE]) + "." // "Arquivo não encontrado"
				break
			endif
		endif

		aTpEvento := {STR0084, STR0085} // "110130 - Comprovante de Entrega" ### "110131 - Cancelamento do Comprovante de Entrega"
		lRet := MsgYesNo(STR0086 + " '" + aTpEvento[aInfConf[EVENTO]]+ "'?", STR0014) // "Deseja enviar o evento" ### "Comprovante de Entrega NF-e"
		if lRet
			cError := ""
			lRet := EnvEvento(@cError, aInfConf, aInfCom )
		endif

	end sequence

	if !lRet
		Help(" ",1,STR0015,,cError,1,0) // "Comprovante de Entrega"
	endif

return lRet

/*/{Protheus.doc} EnvEvento
    Realiza o envio do evento do Comprovante de Entrega ou Cancelamento do Comprovante de Entrega

/*/
static function EnvEvento(cError, aInfConf, aInfCom )
	local lRet       := .F.
	local cXmlEvento := ""
	local aRet       := {}

	default cError     := ""
	default aInfConf := {}
	default aInfCom  := {}

	cXmlEvento := getXmlEvento(aInfConf, aInfCom)
	cError := ""
	aRet := TSSEnvEven(@cError,, _cIdEnt, cXmlEvento)

	lRet := len(aRet) > 0 .and. aScan( aRet, { |X| aInfCom[CHAVENFE] $ X }) > 0

return lRet

/*/{Protheus.doc} getXmlEvento
    Gera o xml do Evento para o método REMESSAEVENTO

/*/
static function getXmlEvento(aInfConf, aInfCom)
	local cXmlEvento := ""
	local cTpEvento  := ""
	local nTpEvento  := aInfConf[EVENTO]
	local cChaveNFe  := aInfCom[CHAVENFE]
	local cTpAutor   := substr(aInfCom[TPAUTOR],1,1)
	local cUfAutor   := substr(aInfCom[UFAUTOR],1,2)
	local cUF		 := ""
	local dDtEntrega := ctod("")
	local cTime      := ""
	local cNumDoc    := ""
	local cNome      := ""
	local cLatitude  := ""
	local cLongitude := ""
	local cImgComp   := ""
	local nHandle    := 0
	local cHash      := ""
	local nTam       := 0
	local cBase64    := ""
	local cFusoHr	 := ""
	local cHora		 := ""

	cTpEvento := (if(nTpEvento == 1, "110130", "110131"))
	cXmlEvento := '<envEvento>'
	cXmlEvento +=     '<eventos>'
	cXmlEvento +=	    '<detEvento>'
	cXmlEvento += 	    '<tpEvento>' + cTpEvento + '</tpEvento>'
	cXmlEvento +=         '<chNFe>' + cChaveNFe + '</chNFe>'
	cXmlEvento +=         '<cOrgaoAutor>' + cUfAutor + '</cOrgaoAutor>'
	cXmlEvento +=         '<tpAutor>' + cTpAutor + '</tpAutor>'
	if cTpEvento == "110130"
		dDtEntrega := aInfCom[DTENTREGA]
		cUF := SubStr(aInfCom[UFAUTOR], at("(",aInfCom[2])+1, 2)
		cHora := fwTimeUF(cUF,,SuperGetMV("MV_HVERAO",.F.,.F.))[2]
		cTime := if(empty(alltrim(strtran(aInfCom[TMENTREGA], ":",""))), cHora , aInfCom[TMENTREGA])
		cFusoHr := substr(FwGMTByUF(cUF,SuperGetMV("MV_HVERAO",.F.,.F.)),1,6)
		cNumDoc := alltrim(aInfCom[DOCUMENTO])
		cNome := alltrim(aInfCom[NOME])
		cLatitude := alltrim(aInfCom[LATITUDE])
		cLongitude := alltrim(aInfCom[LONGITUDE])
		cImgComp := aInfCom[COMPROVANTE]
		nHandle := FOpen(cImgComp)
		cHash := ""
		if nHandle > 0
			nTam := FSeek(nHandle,0,2)
			FSeek(nHandle,0)
			FRead(nHandle,@cBase64,nTam)
			FClose(nHandle)
			cBase64 := Encode64(cBase64)
			cHash := Encode64(Sha1(cChaveNFe + cBase64,1))
		endif
		cXmlEvento +=     '<dhEntrega>' + FWTimeStamp(3,dDtEntrega, cTime) + cFusoHr + '</dhEntrega>'
		cXmlEvento +=     '<nDoc>' + cNumDoc + '</nDoc>'
		cXmlEvento +=     '<xNome>' + cNome + '</xNome>'
		if !empty(cLatitude)
			cXmlEvento +=     '<latGPS>' + cLatitude + '</latGPS>'
		endif
		if !empty(cLongitude)
			cXmlEvento +=     '<longGPS>' + cLongitude + '</longGPS>'
		endif
		cXmlEvento +=     '<hashComprovante>' + cHash + '</hashComprovante>'
		cXmlEvento +=     '<dhHashComprovante>' + FWTimeStamp(3,date(), cHora ) + cFusoHr + '</dhHashComprovante>'
	endif
	cXmlEvento +=	        '</detEvento>'
	cXmlEvento +=     '</eventos>'
	cXmlEvento +='</envEvento>'

return cXmlEvento

/*/{Protheus.doc} ExecResult
    Apresenta a ultima etapa

/*/
static function ExecResult(oPanel, cTabDoc, cAliasBrw, aInfConf, aInfCom)
	local nRecTab    := (cAliasBrw)->RECNO
	local cTbDoc     := ""
	local oTela      := nil
	local cPnlUp     := ""
	local cPnlDown   := ""
	local oPnlUp     := nil
	local oPnlDown   := nil
	local oList      := nil
	local oBRefresh  := nil
	local cError     := ""
	local cTpEvento  := (if(aInfConf[EVENTO] == 1, "110130", "110131"))

	FWMsgRun(, {|| sleep(3000) }, STR0087, STR0088 ) //"Processamento" ### "Enviando e monitorando..."
	cTbDoc := substr(cTabDoc, 2, 2)

	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	oTela := FWFormContainer():New( oPanel )
	cPnlUp := oTela:CreateHorizontalBox(10)
	cPnlDown := oTela:CreateHorizontalBox(90)

	oTela:Activate( oPanel, .T. )
	oPnlUp := oTela:GeTPanel( cPnlUp )
	oPnlDown := oTela:GeTPanel( cPnlDown )

	oBRefresh := TButton():New(004,004, "Refresh", oPnlUp, { || (createlist(@oPnlDown, @oList, @cError, cTabDoc, nRecTab, aInfCom[DOC], aInfCom[DOC], aInfCom[SERIE], aInfCom[CODCLIFOR], aInfCom[LOJA], aInfCom[EMISSAO], aInfCom[EMISSAO], cTpEvento), oList:Refresh(.T.)) },30,10,,,,.T.)
	createlist(@oPnlDown, @oList, @cError, cTabDoc, nRecTab, aInfCom[DOC], aInfCom[DOC], aInfCom[SERIE], aInfCom[CODCLIFOR], aInfCom[LOJA], aInfCom[EMISSAO], aInfCom[EMISSAO], cTpEvento)

return


/*/{Protheus.doc} Monitorar
    Função responsável por realizar o processo de monitoramento do evento, chamada a partir do Menu

/*/
static function Monitorar(cTabDoc)
	local aArea      := {}
	local aAreaTab   := {}
	local cTipoNfe   := ""
	local aPerg   	 := {}
	local aParam  	 := {}
	local cError     := ""
	local aSizeAut   := FWGetDialogSize(oMainWnd)
	local nCoordX    := 0
	local nCoordY    := 0
	local nWidth     := 0
	local nHeight    := 0
	local oDlgMon    := nil
	local oList      := nil
	local oTela      := nil
	local cIdUp      := ""
	local cIdDown    := ""
	local oPnlUp     := nil
	local oPnlDown   := nil
	local oBSair     := nil
	local oBRefresh  := nil

	aArea := getArea()

	lSdoc := if(type("lSdoc") == "U", GetSX3Cache("F2_SERIE","X3_TAMANHO") == 14, lSdoc)
	aParam := { Space(If (lSdoc,Len(SF2->F2_SDOC),Len(SF2->F2_SERIE))),;
		Space(Len(SF2->F2_DOC)),;
		Space(Len(SF2->F2_DOC)),;
		Space(Len(SF2->F2_CLIENTE)),;
		Space(Len(SF2->F2_LOJA)),;
		CToD(""),;
		CToD(""),;
		"110130"}

	dbSelectArea(cTabDoc)
	aAreaTab := (cTabDoc)->(getArea())
	cTipoNfe := "1"
	if cTabDoc == "SF1" // Entrada
		cTipoNfe := "2"
	endif
	aadd(aPerg,{1,STR0006,aParam[01],"",".T.","",".T.",30,.T.}) //"Serie da Nota Fiscal"
	aadd(aPerg,{1,STR0007,aParam[02],"",".T.","",".T.",30,.F.}) //"Nota fiscal inicial"
	aadd(aPerg,{1,STR0008,aParam[03],"",".T.","",".T.",30,.F.}) //"Nota fiscal final"
	if cTipoNfe == "1"
		aadd(aPerg,{1,STR0004,aParam[04],"",".T.","SpedCnsCad( '1', @MV_PAR04, @MV_PAR05)",".T.",50,.T.}) //"Cliente/Fornecedor"
	else
		aadd(aPerg,{1,STR0004,aParam[04],"",".T.","SpedCnsCad( '2', @MV_PAR04, @MV_PAR05)",".T.",50,.T.}) //"Cliente/Fornecedor"
	endif
	aadd(aPerg,{1,STR0005,aParam[05],"",".T.","",".T.",50,.T.}) //"Loja"
	aadd(aPerg,{1,STR0089,aParam[06],"",".T.","",".T.",50,.F.}) //"Data Inicial"
	aadd(aPerg,{1,STR0090,aParam[07],"",".T.","",".T.",50,.F.}) //"Data Final"
	aadd(aPerg,{2,STR0062,aParam[08],{STR0084, STR0085},80,".T.",.T.,".T."}) //"Evento" ### "110130 - Comprovante de Entrega" ### "110131 - Cancelamento do Comprovante de Entrega"

	if ParamBox(aPerg,STR0091,@aParam,,,,,,,"SPEDNFE_MON_COMPR"+alltrim(FWGrpCompany())+alltrim(FWCodFil()),.T.,.T.) // "Monitorar"

		nCoordY	:= aSizeAut[1]
		nCoordX	:= aSizeAut[2]
		nWidth 	:= aSizeAut[4]/1.75
		nHeight := aSizeAut[3]/1.75

		DEFINE MSDIALOG oDlgMon TITLE STR0092 FROM nCoordX,nCoordY TO nCoordX+nHeight,nCoordY+nWidth PIXEL OF oMainWnd // "Monitor - Comprovante de Entrega"

		FwFreeObj(oTela)
		oTela := FWFormContainer():New( oDlgMon )
		cIdUp := oTela:CreateHorizontalBox(10)
		cIdDown := oTela:CreateHorizontalBox(90)

		oTela:Activate( oDlgMon, .T. )
		oPnlUp := oTela:GeTPanel( cIdUp )
		oPnlUp:Align := CONTROL_ALIGN_ALLCLIENT
		oPnlDown := oTela:GeTPanel( cIdDown )
		oPnlDown:Align := CONTROL_ALIGN_ALLCLIENT
		oBSair := TButton():New(004,004, STR0028, oPnlUp, { || oDlgMon:end() },30,10,,,,.T.) // "Sair"
		oBRefresh := TButton():New(004,040, "Refresh", oPnlUp, { || (Processa({|lEnd| createlist(oPnlDown, @oList, @cError, cTabDoc, , MV_PAR02, MV_PAR03, MV_PAR01, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, substr(MV_PAR08,1,6))},STR0093, STR0094,.F.), oList:Refresh(.T.)) },30,10,,,,.T.) // "Processando","Aguarde, monitorando eventos..."
		Processa({|lEnd| createlist(oPnlDown, @oList, @cError, cTabDoc, , MV_PAR02, MV_PAR03, MV_PAR01, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, substr(MV_PAR08,1,6))},STR0093, STR0094,.F.) // "Processando","Aguarde, monitorando eventos..."

		if empty(cError)
			ACTIVATE MSDIALOG oDlgMon CENTERED
		else
			Help(" ",1,STR0015,,cError,1,0) // "Comprovante de Entrega"
		endif

	endif

	restArea(aAreaTab)
	restArea(aArea)
return

/*/{Protheus.doc} getListMon
    Retorna o resultado do monitor para ListBox

/*/
static function getListMon(cError, cTabDoc, nRecTab, cDocIni, cDocFim, cSerie, cCliFor, cLoja, dDtIni, dDtFim, cTpEvento, cMsg)
	local aArea      := {}
	local aAreaTab   := {}
	local cAliasQry  := ""
	local cCampos    := ""
	local cTipoNfe   := ""
	local cWhere     := ""
	local cTbDoc     := ""
	local oOk        := LoadBitMap(GetResources(), "ENABLE")
	local oNo        := LoadBitMap(GetResources(), "DISABLE")
	local cChvIni    := ""
	local cChvFim    := ""
	local cDoc       := ""
	local nTotEven   := 1
	local nEven      := 0
	local aRetMon    := {}
	local nMon       := 0
	local aMonitor   := {}

	default cError     := ""
	default cTabDoc    := ""
	default nRecTab    := 0
	default cDocIni    := ""
	default cDocFim    := ""
	default cSerie     := ""
	default cCliFor    := ""
	default cLoja      := ""
	default dDtIni     := ctod("")
	default dDtFim     := ctod("")
	default cTpEvento  := ""
	default cMsg       := ""

	aArea := getArea()
	dbSelectArea(cTabDoc)
	aAreaTab := (cTabDoc)->(getArea())

	cTbDoc := substr(cTabDoc, 2, 2)
	if nRecTab == 0
		cAliasQry := getNextAlias()
		cCampos := "% MIN(" + cTbDoc + "_CHVNFE) CHVINI, MAX(" + cTbDoc + "_CHVNFE) CHVFIM %"
		cTipoNfe := "1"
		if cTabDoc == "SF1" // Entrada
			cTipoNfe := "2"
			SF1->(dbSetOrder(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		else
			SF2->(dbSetOrder(2)) // F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
		endif
		cWhere := getWhere(cTipoNfe, cCliFor, cLoja, cSerie, cDocIni, cDocFim, dDtIni, dDtFim)
		cWhere := '% ' + cWhere + ' %'

		if cTabDoc == "SF1"
			BeginSql Alias cAliasQry
                SELECT %Exp:cCampos%
                FROM %Table:SF1% SF1
                WHERE
                    %Exp:cWhere%
                ORDER BY 1
			EndSql
		else
			BeginSql Alias cAliasQry
                SELECT %Exp:cCampos%
                FROM %Table:SF2% SF2
                WHERE
                    %Exp:cWhere%
                ORDER BY 1
			EndSql
		endif

		(cAliasQry)->(dbGoTop())
		cChvIni := (cAliasQry)->CHVINI
		cChvFim := (cAliasQry)->CHVFIM
		(cAliasQry)->(dbCloseArea())
	else
		(cTabDoc)->(dbgoTo(nRecTab))
		if (cTabDoc)->(recno()) == nRecTab
			cChvIni := (cTabDoc)->&( cTbDoc + "_CHVNFE" )
			cChvFim := cChvIni
		endif
	endif

	nTotEven := if(empty(cTpEvento), 2, 1)
	for nEven := 1 to nTotEven

		cTpEvento := if( empty(cTpEvento) , "110130", cTpEvento)
		aRetMon := TSSMonEven(@cError,, _cIdEnt, cChvIni, cChvFim, cTpEvento, @cMsg )
		for nMon := 1 to len(aRetMon)
			cDoc := substr(aRetMon[nMon][03],34,9)
			aAdd( aMonitor, { if(aRetMon[nMon][01] <> 6 .and. aRetMon[nMon][01] <> 7 ,oNo,oOk),;
				if(cTpEvento == "110130", "110130 - " + STR0015, "110131 - " + STR0063),; // "Comprovante de Entrega" ### "Cancelamento do Comprovante"
				if(aRetMon[nMon][04] == 2, STR0058,STR0095),; // "2-Homologacao" ### "1-Producao"
					cDoc,;
						cSerie,;
						aRetMon[nMon][03],;
						aRetMon[nMon][02],;
						aRetMon[nMon][05],;
						alltrim(aRetMon[nMon][06]),;
						aRetMon[nMon][07],;
						alltrim(aRetMon[nMon][08])})
				next

				FwFreeObj(aRetMon)
				cTpEvento := "110131"

			next

			if len(aMonitor) == 0
				aAdd( aMonitor, { oNo, "", "", "", "", "", "", "", if( empty(cError), STR0096, STR0097 + " - " + cError), "", ""}) // "Nenhum evento encontrado", "Erro ao monitorar"
			endif

			restArea(aAreaTab)
			restArea(aArea)

			return aMonitor

/*/{Protheus.doc} Exportar
    Função responsável por realizar o processo de Exportar o xml do evento, chamada a partir do Menu

/*/
static function Exportar(cTabDoc)
	local aArea      := {}
	local aAreaTab   := {}
	local aPerg   	 := {}
	local aParam  	 := {}
	local cError     := ""
	local lOk        := .F.

	aArea := getArea()

	lSdoc := if(type("lSdoc") == "U", GetSX3Cache("F2_SERIE","X3_TAMANHO") == 14, lSdoc)
	aParam := { Space(If (lSdoc,Len(SF2->F2_SDOC),Len(SF2->F2_SERIE))),;
		Space(Len(SF2->F2_DOC)),;
		Space(Len(SF2->F2_DOC)),;
		Space(Len(SF2->F2_CLIENTE)),;
		Space(Len(SF2->F2_LOJA)),;
		CToD(""),;
		CToD(""),;
		"110130",;
		Space(60)}

	dbSelectArea(cTabDoc)
	aAreaTab := (cTabDoc)->(getArea())
	cTipoNfe := "1"
	if cTabDoc == "SF1" // Entrada
		cTipoNfe := "2"
	endif

	aadd(aPerg,{1,STR0006,aParam[01],"",".T.","",".T.",30,.T.}) //"Serie da Nota Fiscal"
	aadd(aPerg,{1,STR0007,aParam[02],"",".T.","",".T.",30,.F.}) //"Nota fiscal inicial"
	aadd(aPerg,{1,STR0008,aParam[03],"",".T.","",".T.",30,.F.}) //"Nota fiscal final"
	if cTipoNfe == "1"
		aadd(aPerg,{1,STR0004,aParam[04],"",".T.","SpedCnsCad( '1', @MV_PAR04, @MV_PAR05)",".T.",50,.T.}) //"Cliente/Fornecedor"
	else
		aadd(aPerg,{1,STR0004,aParam[04],"",".T.","SpedCnsCad( '2', @MV_PAR04, @MV_PAR05)",".T.",50,.T.}) //"Cliente/Fornecedor"
	endif
	aadd(aPerg,{1,STR0005,aParam[05],"",".T.","",".T.",50,.T.}) //"Loja"
	aadd(aPerg,{1,STR0089,aParam[06],"",".T.","",".T.",50,.F.}) //"Data Inicial"
	aadd(aPerg,{1,STR0090,aParam[07],"",".T.","",".T.",50,.F.}) //"Data Final"
	aadd(aPerg,{2,STR0062,aParam[08],{STR0084, STR0085},80,".T.",.T.,".T."}) //"Evento" ### "110130 - Comprovante de Entrega" ### "110131 - Cancelamento do Comprovante de Entrega"
	aadd(aPerg,{6,STR0098,aParam[09],"","SpedVldDir(,@mv_par09)","!empty(mv_par09)",80,.T.,"Arquivos XML |*.XML","",GETF_RETDIRECTORY+GETF_LOCALHARD,.T.}) //"Diretório de destino"

	if ParamBox(aPerg,STR0032,@aParam,,,,,,,"SPEDNFE_EXP_COMPR"+alltrim(FWGrpCompany())+alltrim(FWCodFil()),.T.,.T.) // "Exportar"
		Processa({|lEnd| lOk := ExecExp(@cError, cTabDoc, MV_PAR09, SubStr(MV_PAR08,1,6), MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07)},STR0093,STR0099,.F.) // "Processando" ### "Aguarde, exportando arquivos"
		if empty(cError) .and. lOk
			MsgInfo(STR0100,STR0018) // "Documentos exportados com sucesso." ### "Atenção"
		else
			Help(" ",1,STR0015,,cError,1,0) // "Comprovante de Entrega"
		endif
	endif

	restArea(aAreaTab)
	restArea(aArea)

return

/*/{Protheus.doc} ExecExp
    Executa a exportação do XML do evento

/*/
static function ExecExp(cError, cTabDoc, cDir, cTpEvento, cSerie, cDocIni, cDocFim, cCliFor, cLoja, dDtIni, dDtFim)
	local lRet       := .F.
	local cAliasQry  := ""
	local cTbDoc     := ""
	local cCampos    := ""
	local cTipoNfe   := ""
	local cWhere     := ""
	local cChvIni    := ""
	local cChvFim    := ""

	lSdoc := if(type("lSdoc") == "U", GetSX3Cache("F2_SERIE","X3_TAMANHO") == 14, lSdoc)
	cAliasQry := getNextAlias()
	cTbDoc := substr(cTabDoc, 2, 2)
	cCampos := "% MIN(" + cTbDoc + "_CHVNFE) CHVINI, MAX(" + cTbDoc + "_CHVNFE) CHVFIM %"
	cTipoNfe := "1"
	if cTabDoc == "SF1" // Entrada
		cTipoNfe := "2"
	endif

	cWhere := getWhere(cTipoNfe, cCliFor, cLoja, cSerie, cDocIni, cDocFim, dDtIni, dDtFim)
	cWhere := '% ' + cWhere + ' %'
	if cTabDoc == "SF1"
		BeginSql Alias cAliasQry
            SELECT %Exp:cCampos%
            FROM %Table:SF1% SF1
            WHERE
                %Exp:cWhere%
            ORDER BY 1
		EndSql
	else
		BeginSql Alias cAliasQry
            SELECT %Exp:cCampos%
            FROM %Table:SF2% SF2
            WHERE
                %Exp:cWhere%
            ORDER BY 1
		EndSql
	endif

	(cAliasQry)->(dbGoTop())
	cChvIni := (cAliasQry)->CHVINI
	cChvFim := (cAliasQry)->CHVFIM
	(cAliasQry)->(dbCloseArea())

	lRet := ExpXmlEvento(@cError, cDir, cTpEvento, cChvIni, cChvFim)

return lRet

/*/{Protheus.doc} ExpXmlEvento
    Executa a exportação do XML do evento

/*/
static function ExpXmlEvento(cError, cDir, cTpEvento, cChvIni, cChvFim)
	local lCriou     := .F.
	local aRetorno   := {}
	local nNotas     := 0
	local cXml       := ""
	local cErro      := ""
	local cAviso     := ""
	local cIdEven    := ""
	local nHandle    := 0

	default cError     := ""
	default cDir       := ""
	default cTpEvento  := ""
	default cChvIni    := ""
	default cChvFim    := ""

	private oXmlExp := nil

	aRetorno := TSSExpEvento(@cError,,_cIdEnt, cTpEvento, cChvIni, cChvFim)
	for nNotas := 1 to Len(aRetorno)
		cXml := aRetorno[nNotas]
		oXmlExp := XmlParser(cXml,"_",@cErro,@cAviso)
		if ValAtrib("oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID")<>"U"
			cIdEven	:= oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID:TEXT
		else
			if ValAtrib("oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID")<>"U"
				cIdEven  := oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT
			endif
		endif
		nHandle := FCreate( alltrim(cDir) + alltrim(SubStr(cIdEven,3)) + if(cTpEvento == "110130","-comprovante.xml", "-canc_comprovante.xml"))
		if nHandle > 0
			FWrite(nHandle,allTrim(cXml))
			FClose(nHandle)
			lCriou := .T.
		endif
	next

	if len(aRetorno) == 0 .and. !lCriou
		cError := STR0128 // "Nenhum evento vinculado aos documentos informados."
	endif

return lCriou

/*/{Protheus.doc} VisualDoc
    Visualiza o documento SF1 ou SF2

/*/
static function VisualDoc(cTabDoc, cAliasBrw)
	local aArea      := {}
	local aAreaTab   := {}
	local nRecTab    := 0
	local aRotbkp    := {}

	if (cAliasBrw)->(!eof())
		aArea := getArea()
		dbSelectArea(cTabDoc)
		aAreaTab := (cTabDoc)->(getArea())
		nRecTab := (cAliasBrw)->RECNO
		(cTabDoc)->(dbgoTo(nRecTab))
		if (cTabDoc)->(recno()) == nRecTab
			if cTabDoc == "SF2"
				Mc090Visual("SF2",SF2->(RecNo()),1)
			elseif cTabDoc == "SF1"
				aRotbkp := aClone(aRotina)
				aRotina[2][1] := OemToAnsi(SubStr(STR0024,2)) // "Visualizar"
				aRotina[2][2] := "A103NFiscal"
				aRotina[2][4] := 2
				A103NFiscal("SF1",SF1->(RecNo()),2)
				aRotina := aClone(aRotbkp)
			endif
		endif
		restArea(aAreaTab)
		restArea(aArea)
	endif

return

/*/{Protheus.doc} getUf
    Retorna os Estados do Brasil

/*/
static function getUf()
	local aUF := {}
	aadd(aUF,"11 - " + STR0101 + " (RO)") // "Rondônia"
	aadd(aUF,"12 - " + STR0102 + " (AC)") // "Acre"
	aadd(aUF,"13 - " + STR0103 + " (AM)") // "Amazonas"
	aadd(aUF,"14 - " + STR0104 + " (RR)") // "Roraima"
	aadd(aUF,"15 - " + STR0105 + " (PA)") // "Pará"
	aadd(aUF,"16 - " + STR0106 + " (AP)") // "Amapá"
	aadd(aUF,"17 - " + STR0107 + " (TO)") // "Tocantins"
	aadd(aUF,"21 - " + STR0108 + " (MA)") // "Maranhão"
	aadd(aUF,"22 - " + STR0109 + " (PI)") // "Piauí"
	aadd(aUF,"23 - " + STR0110 + " (CE)") // "Ceará"
	aadd(aUF,"24 - " + STR0111 + " (RN)") // "Rio Grande do Norte"
	aadd(aUF,"25 - " + STR0112 + " (PB)") // "Paraíba"
	aadd(aUF,"26 - " + STR0113 + " (PE)") // "Pernambuco"
	aadd(aUF,"27 - " + STR0114 + " (AL)") // "Alagoas"
	aadd(aUF,"28 - " + STR0115 + " (SE)") // "Sergipe"
	aadd(aUF,"29 - " + STR0116 + " (BA)") // "Bahia"
	aadd(aUF,"31 - " + STR0117 + " (MG)") // "Minas Gerais"
	aadd(aUF,"32 - " + STR0118 + " (ES)") // "Espírito Santo"
	aadd(aUF,"33 - " + STR0119 + " (RJ)") // "Rio de Janeiro"
	aadd(aUF,"35 - " + STR0120 + " (SP)") // "São Paulo"
	aadd(aUF,"41 - " + STR0121 + " (PR)") // "Paraná"
	aadd(aUF,"42 - " + STR0122 + " (SC)") // "Santa Catarina"
	aadd(aUF,"43 - " + STR0123 + " (RS)") // "Rio Grande do Sul"
	aadd(aUF,"50 - " + STR0124 + " (MS)") // "Mato Grosso do Sul"
	aadd(aUF,"51 - " + STR0125 + " (MT)") // "Mato Grosso"
	aadd(aUF,"52 - " + STR0126 + " (GO)") // "Goiás"
	aadd(aUF,"53 - " + STR0127 + " (DF)") // "Distrito Federal"
return aUF

static Function ValAtrib(atributo)
return (type(atributo) )
