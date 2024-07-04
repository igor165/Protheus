#include 'PROTHEUS.CH'
#include 'TJURCASORESUMO.CH'
#INCLUDE "FWBROWSE.CH"

#DEFINE ERROR "TJurCasoResumo: ERROR - "

#DEFINE KEY    1
#DEFINE OBJECT 2
#DEFINE ACTION 3

#DEFINE HEADER  1
#DEFINE COL     2
#DEFINE DBCLICK 3
Static _lFwPDCanUse := FindFunction("FwPDCanUse")

Function __TJurCasoResumo() // Function Dummy
ApMsgInfo( 'TJurCasoResumo -> Utilizar Classe ao inves da funcao' )
Return NIL


CLASS TJurCasoResumo FROM JurBase

	Data lActivate
	Data nRecno
	Data aSize
	Data oDlg
	Data oPnlHeader
	Data oPnlBody
	Data oPnlFooter
	Data oFolder
	Data oGrpPendentes
	Data oGrpFaturados
	Data oGrpWO

	Data dIniTs
	Data dEndTs
	Data dIniDs
	Data dEndDs
	Data dIniTb
	Data dEndTb
	Data dIniFx
	Data dEndFx

	Data aHeader // Contém objetos do header
	Data aBody   // Contém objetos do body
	Data aBrowse // Contém objetos dos Browses

	Data oFilIniTs
	Data oFilEndTs
	Data oFilIniDs
	Data oFilEndDs
	Data oFilIniTb
	Data oFilEndTb
	Data oFilIniFx
	Data oFilEndFx

	Data oFldPnlCJ
	Data oFldPnlCJ_M
	Data oFldPnlCJ_D
	Data oFldPnlPR
	Data oFldPnlFT
	Data oFldPnlTS
	Data oFldPnlDS
	Data oFldPnlTB
	Data oFldPnlCT

	Data aHeaderAll

	Method New() CONSTRUCTOR
	Method Activate()
	Method DeActivate()
	Method Destroy()
	Method SetRecno()
	Method GetRecno()
	Method ShowFilter()
	Method Init()
	Method Draw()
	Method Fill()
	Method SetObject()
	Method GetValue()
	Method SetValue()
	Method FooterRefresh()

	Method GetDtIniTs()
	Method SetDtIniTs()
	Method GetDtEndTs()
	Method SetDtEndTs()

	Method GetDtIniDs()
	Method SetDtIniDs()
	Method GetDtEndDs()
	Method SetDtEndDs()

	Method GetDtIniTb()
	Method SetDtIniTb()
	Method GetDtEndTb()
	Method SetDtEndTb()

	Method GetDtIniFx()
	Method SetDtIniFx()
	Method GetDtEndFx()
	Method SetDtEndFx()

	Method DrawBrowses()

	Method SetHeaders()
	Method GetHeaders()

	Method EXPORTRES()
	Method EXPORTAUX()

ENDCLASS

Method New(nRecno) Class TJurCasoResumo

Default nRecno := 0

	SetVarNameLen(50)

	_Super:New()
	::lActivate := .F.
	::SetRecno(nRecno)

	If Type('oMainWnd') != 'U'
		::aSize := FWGetDialogSize(oMainWnd)
	Else
		::aSize := {0,0,800,1200}
	EndIf

	::Init()

Return Self

Method Activate() Class TJurCasoResumo

	If ::GetRecno() > 0

		If ::ShowFilter()

			::Draw()

			MsgRun(STR0033, STR0004,{|| ::Fill() }) //"Atualizando..." e "Resumo de Caso"

			::oDlg:lEscClose := .F. //Para desabilitar a tecla ESC.

			::oDlg:Activate(,,,.T.,{|| /*Validação*/ },,{|| /*Inicialização*/ } ) // Ativa centralizado

			::lActivate := .T.
		EndIf

	EndIf

Return ::lActivate

Method DeActivate() Class TJurCasoResumo
Local nI

	If ::lActivate

		For nI := 1 to Len(::aHeader)
			FreeObj(::aHeader[nI][OBJECT])
			::aHeader[nI][OBJECT] := Nil
			::aHeader[nI][ACTION] := {|| }
		Next

		For nI := 1 to Len(::aBody)
			FreeObj(::aBody[nI][OBJECT])
			::aBody[nI][OBJECT] := Nil
			::aBody[nI][ACTION] := {|| }
		Next

		//Para limpar as linhas e colunas
		For nI := 1 to Len(::aBrowse)
			::aBrowse[nI][OBJECT] := Nil
			::aBrowse[nI][ACTION] := Nil
		Next

		::lActivate := .F.

	EndIf

Return ::lActivate

Method Destroy() Class TJurCasoResumo

	::DeActivate()

	aSize(::aSize, 0)
	aSize(::aHeader, 0)
	aSize(::aBody, 0)
	aSize(::aBrowse, 0)
	aSize(::aHeaderAll, 0)

Return Nil

Method SetRecno(nRecno) Class TJurCasoResumo
Default nRecno := 0
	If ValType(nRecno) == "N" .And. nRecno > 0
		::nRecno := nRecno
	EndIf
Return nRecno == ::nRecno

Method GetRecno() Class TJurCasoResumo
Return ::nRecno

Method Init() Class TJurCasoResumo
Local lRet := .F.

	::aHeader := {}
	::aBody   := {}
	::aBrowse := {}

	::aHeaderAll := {}

	::dIniTs := StoD("19000101")
	::dEndTs := Date()
	::dIniDs := StoD("19000101")
	::dEndDs := Date()
	::dIniTb := StoD("19000101")
	::dEndTb := Date()
	::dIniFx := StoD("19000101")
	::dEndFx := Date()

	aAdd(::aHeader, {"CCLIEN", Nil, {|| } } )
	aAdd(::aHeader, {"LOJA",   Nil, {|| } } )
	aAdd(::aHeader, {"DCLIEN", Nil, {|| } } )
	aAdd(::aHeader, {"NUMCAS", Nil, {|| } } )
	aAdd(::aHeader, {"TITULO", Nil, {|| } } )
	aAdd(::aHeader, {"SIGLA1", Nil, {|| } } )
	aAdd(::aHeader, {"DTENTR", Nil, {|| } } )
	aAdd(::aHeader, {"CTABH",  Nil, {|| } } )
	aAdd(::aHeader, {"DTABH",  Nil, {|| } } )
	aAdd(::aHeader, {"MOETABH",Nil, {|| } } )
	aAdd(::aHeader, {"CTABS",  Nil, {|| } } )
	aAdd(::aHeader, {"DTABS",  Nil, {|| } } )
	aAdd(::aHeader, {"MOETABS",Nil, {|| } } )
	aAdd(::aHeader, {"CTABP",  Nil, {|| } } )
	aAdd(::aHeader, {"DTABP",  Nil, {|| } } )
	aAdd(::aHeader, {"MOETABP",Nil, {|| } } )
	aAdd(::aHeader, {"MOEOFIC",Nil, {|| } } )
	aAdd(::aHeader, {"ENCHON", Nil, {|| } } )
	aAdd(::aHeader, {"ENCDES", Nil, {|| } } )
	aAdd(::aHeader, {"ENCTAB", Nil, {|| } } )
	aAdd(::aHeader, {"EXITO",  Nil, {|| } } )
	aAdd(::aHeader, {"DESPAD", Nil, {|| } } )

	aAdd(::aBody, {"VP_TS_TC_VLR_T_L", Nil, {|| } } )
	aAdd(::aBody, {"VP_TS_TC_VLR_T_R", Nil, {|| } } )
	aAdd(::aBody, {"VP_TS_TP_VLR_T_L", Nil, {|| } } )
	aAdd(::aBody, {"VP_TS_TP_VLR_T_R", Nil, {|| } } )
	aAdd(::aBody, {"VP_DS_MO_VLR", Nil, {|| } } )
	aAdd(::aBody, {"VP_TB_MO_VLRT", Nil, {|| } } )
	aAdd(::aBody, {"VP_TB_MO_VLRF", Nil, {|| } } )
	aAdd(::aBody, {"VP_TB_TC_VLRT", Nil, {|| } } )
	aAdd(::aBody, {"VP_TB_TC_VLRF", Nil, {|| } } )
	aAdd(::aBody, {"VF_TS_MO_VLR", Nil, {|| } } )
	aAdd(::aBody, {"VF_DS_MO_VLR", Nil, {|| } } )
	aAdd(::aBody, {"VF_TB_MO_VLR", Nil, {|| } } )
	aAdd(::aBody, {"VF_FX_MO_VLR", Nil, {|| } } )
	//aAdd(::aBody, {"WO_TS_MO_VLR", Nil, {|| } } )
	aAdd(::aBody, {"WO_DS_MO_VLR", Nil, {|| } } )
	//aAdd(::aBody, {"WO_TB_MO_VLR", Nil, {|| } } )
	//aAdd(::aBody, {"WO_FX_MO_VLR", Nil, {|| } } )

	aAdd(::aBrowse, {"BROWSE_CJ_M", Nil, Nil } )
	aAdd(::aBrowse, {"BROWSE_CJ_D", Nil, Nil } )
	aAdd(::aBrowse, {"BROWSE_PR", Nil, Nil } )
	aAdd(::aBrowse, {"BROWSE_FT", Nil, Nil } )
	aAdd(::aBrowse, {"BROWSE_TS", Nil, Nil } )
	aAdd(::aBrowse, {"BROWSE_DS", Nil, Nil } )
	aAdd(::aBrowse, {"BROWSE_TB", Nil, Nil } )
	aAdd(::aBrowse, {"BROWSE_CT", Nil, Nil } )

Return lRet

Method ShowFilter() Class TJurCasoResumo
Local lRet    := .F.
Local oDlg, oPnl, cPnlDetail, cPnlBtns, oBtnOk, oBtnCancel, oGrpFiltroTS, oGrpFiltroDS, oGrpFiltroTB, oGrpFiltroFX
Local oPnlFiltroTS, oPnlFiltroDS, oPnlFiltroTB, oPnlFiltroFX
Local oDtIniTs, oDtEndTs
Local oDtIniDs, oDtEndDs
Local oDtIniTb, oDtEndTb
Local oDtIniFx, oDtEndFx

Local oPnlGroups, oPnlTs, oPnlDs, oPnlTb, oPnlFx

	oDlg := MSDialog():New(1, 1, 400, 265, STR0001,,,,, CLR_BLACK, CLR_WHITE,,,.T.) // "Filtro"

	oPnl := TJurPanel():New(0,0,0,0,oDlg,"",.F.,.F.,CONTROL_ALIGN_ALLCLIENT)
	cPnlDetail := oPnl:AddHorizontalPanel( 82 )
	cPnlBtns   := oPnl:AddHorizontalPanel( 15 )

	oPnlGroups := TJurPanel():New(0,0,0,0,oPnl:GetPanel(cPnlDetail),"",.F.,.F.,CONTROL_ALIGN_ALLCLIENT)
	oPnlTs := oPnlGroups:GetPanel(oPnlGroups:AddHorizontalPanel(25))
	oPnlDs := oPnlGroups:GetPanel(oPnlGroups:AddHorizontalPanel(25))
	oPnlTb := oPnlGroups:GetPanel(oPnlGroups:AddHorizontalPanel(25))
	oPnlFx := oPnlGroups:GetPanel(oPnlGroups:AddHorizontalPanel(25))

	//Período para TSs
	oGrpFiltroTS := TGroup():New( 0, 0, 40, 0, STR0009, oPnlTs, , , .T. )  //"Time Sheets"
	oGrpFiltroTS:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlFiltroTS := TPanel():New(9,3,'',oPnlTs,,,,,,125,30)

	oDtIniTs := TJurPnlCampo():New(0,0,65,0,oPnlFiltroTS,STR0035,'NX0_DINITS', {||}, {||::SetDtIniTS(oDtIniTs:GetValue())}, ::dIniTs) //"Data Inicial:"
	oDtIniTs:SetAlign(CONTROL_ALIGN_LEFT)
	oDtEndTs := TJurPnlCampo():New(0,0,65,0,oPnlFiltroTS,STR0036,'NX0_DFIMTS', {||}, {||::SetDtEndTS(oDtEndTs:GetValue())}, ::dEndTs) //"Data Final:"
	oDtEndTs:SetAlign(CONTROL_ALIGN_ALLCLIENT)

	//Período para Despesas
	oGrpFiltroDS := TGroup():New( 0, 0, 40, 0, STR0010, oPnlDs, , , .T. )  //"Despesas"
	oGrpFiltroDS:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlFiltroDS := TPanel():New(9,3,'',oPnlDs,,,,,,125,30)

	oDtIniDs := TJurPnlCampo():New(0,0,65,0,oPnlFiltroDS,STR0035,'NX0_DINITS', {|| }, {||::SetDtIniDs(oDtIniDs:GetValue())}, ::dIniDs) //"Data Inicial:"
	oDtIniDs:SetAlign(CONTROL_ALIGN_LEFT)
	oDtEndDs := TJurPnlCampo():New(0,0,65,0,oPnlFiltroDS,STR0036,'NX0_DFIMTS', {|| }, {||::SetDtEndDs(oDtEndDs:GetValue())}, ::dEndDs) //"Data Final:"
	oDtEndDs:SetAlign(CONTROL_ALIGN_ALLCLIENT)

	//Período para Tabelados
	oGrpFiltroTB := TGroup():New( 0, 0, 40, 0, STR0011, oPnlTb, , , .T. )  //"Tabelados"
	oGrpFiltroTB:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlFiltroTB := TPanel():New(9,3,'',oPnlTb,,,,,,125,30)

	oDtIniTb := TJurPnlCampo():New(0,0,65,0,oPnlFiltroTB,STR0035,'NX0_DINITS', {|| }, {||::SetDtIniTb(oDtIniTb:GetValue())}, ::dIniTb) //"Data Inicial:"
	oDtIniTb:SetAlign(CONTROL_ALIGN_LEFT)
	oDtEndTb := TJurPnlCampo():New(0,0,65,0,oPnlFiltroTB,STR0036,'NX0_DFIMTS', {|| }, {||::SetDtEndTb(oDtEndTb:GetValue())}, ::dEndTb) //"Data Final:"
	oDtEndTb:SetAlign(CONTROL_ALIGN_ALLCLIENT)

	//Período para Fixo
	oGrpFiltroFX := TGroup():New( 0, 0, 40, 0, STR0034, oPnlFx, , , .T. )  //"Fixo"
	oGrpFiltroFX:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlFiltroFX := TPanel():New(9,3,'',oPnlFx,,,,,,125,30)

	oDtIniFx := TJurPnlCampo():New(0,0,65,0,oPnlFiltroFX,STR0035,'NX0_DINITS', {|| }, {||::SetDtIniFx(oDtIniFx:GetValue())}, ::dIniFx) //"Data Inicial:"
	oDtIniFx:SetAlign(CONTROL_ALIGN_LEFT)
	oDtEndFx := TJurPnlCampo():New(0,0,65,0,oPnlFiltroFX,STR0036,'NX0_DFIMTS', {|| }, {||::SetDtEndFx(oDtEndFx:GetValue())}, ::dEndFx) //"Data Final:"
	oDtEndFx:SetAlign(CONTROL_ALIGN_ALLCLIENT)

	oBtnOk := tButton():New(7,13,STR0002,oPnl:GetPanel(cPnlBtns),{|| },50,15,,,,.T.) //"Ok"
	oBtnOk:bAction := {|| IIF( ValidaPeriodo(oDtIniTs, oDtEndTs, oDtIniDs, oDtEndDs, oDtIniTb, oDtEndTb, oDtIniFx, oDtEndFx),;
						(lRet := .T., oDlg:End()) , MsgStop(STR0038)) } //"Favor preencher todas as datas!"


	oBtnCancel := tButton():New(7,73,STR0003,oPnl:GetPanel(cPnlBtns),{|| oDlg:End() },50,15,,,,.T.) //"Cancelar"

	oDlg:Activate(,,,.T.,{|| /*Validação*/ },,{|| /*Inicialização*/ } ) // Ativa centralizado

Return lRet

Method Draw() Class TJurCasoResumo
Local lRet    := .F.
Local bTitulo := { |cCampo| SX3->(DbSetOrder(2)), SX3->(DbSeek(cCampo)), AllTrim(X3Titulo()) }
Local nI
Local nBodyWidth  := 70
Local nHeight     := 22
Local oBtnFiltrar, oBtnSair, oGrpFooterTS, oGrpFooterDS, oGrpFooterTB, oGrpFooterFX
Local aCposLGPD     := {}
Local aNoAccLGPD    := {}
Local aDisabLGPD    := {}

	::oDlg := MSDialog():New(::aSize[1], ::aSize[2], ::aSize[3], ::aSize[4], STR0004,,,,, CLR_BLACK, CLR_WHITE,,,.T.) // "Resumo de Caso"

	::oPnlHeader          := tPanel():New(0,0,'',::oDlg,,,,,,0,82)
	::oPnlBody            := tPanel():New(0,0,'',::oDlg,,,,,,0,0)
	::oPnlFooter          := tPanel():New(0,0,'',::oDlg,,,,,,0,39)
	::oPnlHeader:Align    := CONTROL_ALIGN_TOP
	::oPnlBody:Align      := CONTROL_ALIGN_ALLCLIENT
	::oPnlFooter:Align    := CONTROL_ALIGN_BOTTOM
	//::oPnlFooter:nCLRPANE := RGB(240,240,240)
	If _lFwPDCanUse .And. FwPDCanUse(.T.)
		aCposLGPD := {"NVE_DCLIEN", "NVE_TITULO","NVE_DTABH", "NVE_DTABS", "NVP_DTABH"}

		aDisabLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
		AEval(aDisabLGPD, {|x| AAdd( aNoAccLGPD, x:CFIELD)})

	EndIf

	::SetValue("CCLIEN", TJurPnlCampo():New(2,002,040,022,::oPnlHeader,Eval(bTitulo, "NVE_CCLIEN"),'NVE_CCLIEN'), OBJECT)
	::SetValue("LOJA",   TJurPnlCampo():New(2,047,030,022,::oPnlHeader,Eval(bTitulo, "NVE_CLOJA"),'NVE_CLOJA'), OBJECT)
	::SetValue("DCLIEN", TJurPnlCampo():New(2,082,150,022,::oPnlHeader,Eval(bTitulo, "NVE_DCLIEN"),'NVE_DCLIEN',,,,,,,,,,,aScan(aNoAccLGPD,"NVE_DCLIEN") > 0), OBJECT)
	::SetValue("NUMCAS", TJurPnlCampo():New(2,237,040,022,::oPnlHeader,Eval(bTitulo, "NVE_NUMCAS"),'NVE_NUMCAS'), OBJECT)
	::SetValue("TITULO", TJurPnlCampo():New(2,282,200,022,::oPnlHeader,Eval(bTitulo, "NVE_TITULO"),'NVE_TITULO',,,,,,,,,,,aScan(aNoAccLGPD,"NVE_TITULO") > 0), OBJECT)
	::SetValue("SIGLA1", TJurPnlCampo():New(2,487,040,022,::oPnlHeader,Eval(bTitulo, "NVE_SIGLA1"),'NVE_SIGLA1'), OBJECT)

	::SetValue("DTENTR", TJurPnlCampo():New(30,002,040,022,::oPnlHeader,Eval(bTitulo, "NVE_DTENTR"),'NVE_DTENTR'), OBJECT)
	::SetValue("CTABH",  TJurPnlCampo():New(30,047,035,022,::oPnlHeader,Eval(bTitulo, "NVE_CTABH"),'NVE_CTABH'), OBJECT) //Tabela de Honorários
	::SetValue("DTABH",  TJurPnlCampo():New(30,087,080,022,::oPnlHeader,Eval(bTitulo, "NVE_DTABH"),'NVE_DTABH',,,,,,,,,,,aScan(aNoAccLGPD,"NVE_DTABH") > 0), OBJECT)
	::SetValue("MOETABH",TJurPnlCampo():New(30,172,030,022,::oPnlHeader,STR0024,'CTO_SIMB'), OBJECT) //Moe TH
	::SetValue("CTABS",  TJurPnlCampo():New(30,207,035,022,::oPnlHeader,Eval(bTitulo, "NVE_CTABS"),'NVE_CTABS'), OBJECT) //Tabela de Serviços
	::SetValue("DTABS",  TJurPnlCampo():New(30,247,080,022,::oPnlHeader,Eval(bTitulo, "NVE_DTABS"),'NVE_DTABS',,,,,,,,,,,aScan(aNoAccLGPD,"NVE_DTABS") > 0), OBJECT)
	::SetValue("MOETABS",TJurPnlCampo():New(30,332,030,022,::oPnlHeader,STR0026 ,'CTO_SIMB'), OBJECT) //Moe Serv
	::SetValue("CTABP",  TJurPnlCampo():New(30,367,040,022,::oPnlHeader,STR0028,'NVP_CTABH'), OBJECT) //Tab. Padrão
	::SetValue("DTABP",  TJurPnlCampo():New(30,412,080,022,::oPnlHeader,STR0029,'NVP_DTABH',,,,,,,,,,,aScan(aNoAccLGPD,"NVP_DTABH") > 0), OBJECT) //Desc. Tab Pad
	::SetValue("MOETABP",TJurPnlCampo():New(30,497,030,022,::oPnlHeader,STR0027,'CTO_SIMB'), OBJECT) //Moe Pad

	::SetValue("MOEOFIC",TJurPnlCampo():New(58,002,030,022,::oPnlHeader,STR0030,'CTO_SIMB'), OBJECT) //Md Oficial
	::SetValue("ENCHON", TJurPnlCampo():New(58,040,050,022,::oPnlHeader,Eval(bTitulo, "NVE_ENCHON"),'NVE_ENCHON'), OBJECT)
	::SetValue("ENCDES", TJurPnlCampo():New(58,095,050,022,::oPnlHeader,Eval(bTitulo, "NVE_ENCDES"),'NVE_ENCDES'), OBJECT)
	::SetValue("ENCTAB", TJurPnlCampo():New(58,150,050,022,::oPnlHeader,Eval(bTitulo, "NVE_ENCTAB"),'NVE_ENCTAB'), OBJECT)
	::SetValue("EXITO",  TJurPnlCampo():New(58,205,050,022,::oPnlHeader,Eval(bTitulo, "NVE_EXITO"),'NVE_EXITO'), OBJECT)
	::SetValue("DESPAD", TJurPnlCampo():New(58,260,050,022,::oPnlHeader,Eval(bTitulo, "NVE_DESPAD"),'NVE_DESPAD'), OBJECT)

	::oFolder := TFolder():New(0,0,,,::oPnlBody,,,,.T.,,0,0)
	::oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	::oFolder:AddItem(STR0005) // "Resumo"
	::oFolder:AddItem(STR0006) //"Contratos/Junção"
	::oFolder:AddItem(STR0007) //"Pré-Faturas"
	::oFolder:AddItem(STR0008) //"Faturas"
	::oFolder:AddItem(STR0009) //"Time Sheets"
	::oFolder:AddItem(STR0010) //"Despesas"
	::oFolder:AddItem(STR0011) //"Tabelados"
	::oFolder:AddItem(STR0037) //"Cotações (Valores Pendentes)"

	::oFolder:bChange := { || ::DrawBrowses(::oFolder:nOption) }

	//"Contratos/Junção"
	::oFldPnlCJ   := TJurPanel():New(0,0,0,0,::oFolder:aDialogs[2],"",.F.,.F.,CONTROL_ALIGN_ALLCLIENT)
	::oFldPnlCJ_M := ::oFldPnlCJ:GetPanel(::oFldPnlCJ:AddHorizontalPanel( 50 ))
	::oFldPnlCJ_D := ::oFldPnlCJ:GetPanel(::oFldPnlCJ:AddHorizontalPanel( 50 ))
	//"Contratos/Junção"

	//Necessário criar os panels para as browses pois ao clicar em uma aba sai posicionando nas seguintes.
	//Com o panel, o foco vai para ele e não para a próxima aba.
	::oFldPnlPR   := TPanel():New(9,3,'',::oFolder:aDialogs[3],,,,,,125,30)
	::oFldPnlPR:Align := CONTROL_ALIGN_ALLCLIENT
	::oFldPnlFT   := TPanel():New(9,3,'',::oFolder:aDialogs[4],,,,,,125,30)
	::oFldPnlFT:Align := CONTROL_ALIGN_ALLCLIENT
	::oFldPnlTS   := TPanel():New(9,3,'',::oFolder:aDialogs[5],,,,,,125,30)
	::oFldPnlTS:Align := CONTROL_ALIGN_ALLCLIENT
	::oFldPnlDS   := TPanel():New(9,3,'',::oFolder:aDialogs[6],,,,,,125,30)
	::oFldPnlDS:Align := CONTROL_ALIGN_ALLCLIENT
	::oFldPnlTB   := TPanel():New(9,3,'',::oFolder:aDialogs[7],,,,,,125,30)
	::oFldPnlTB:Align := CONTROL_ALIGN_ALLCLIENT
	::oFldPnlCT   := TPanel():New(9,3,'',::oFolder:aDialogs[8],,,,,,125,30)
	::oFldPnlCT:Align := CONTROL_ALIGN_ALLCLIENT

	// Adicionar Scroll para o conteúdo da primeira folder (RESUMO)

	//PENDENTES
	::oGrpPendentes := TGroup():New( 0, 0, 90, 0, STR0012, ::oFolder:aDialogs[1], , , .T. )  //"Valores Pendentes"
	::oGrpPendentes:Align := CONTROL_ALIGN_TOP

	tSay():New(10,002,{|| STR0013},::oGrpPendentes,,/*TFont*/,,,,.T.,rgb(0,58,94),,100,22) // "Time Sheet - Tabela Caso"
	::SetValue("VP_TS_TC_VLR_T_L", TJurPnlCampo():New(20,002,nBodyWidth,22,::oGrpPendentes,STR0014,'NXA_VLFATH'), OBJECT) // "Vlr Tempo Lançado"
	::SetValue("VP_TS_TC_VLR_T_R", TJurPnlCampo():New(50,002,nBodyWidth,22,::oGrpPendentes,STR0015,'NXA_VLFATH'), OBJECT) // "Vlr Tempo Revisado"

	tSay():New(10,107,{|| STR0016},::oGrpPendentes,,/*TFont*/,,,,.T.,rgb(0,58,94),,100,22) // "Time Sheet - Tabela Padrão"
	::SetValue("VP_TS_TP_VLR_T_L", TJurPnlCampo():New(20,107,nBodyWidth,22,::oGrpPendentes,STR0014,'NXA_VLFATH'), OBJECT) // "Vlr Tempo Lançado"
	::SetValue("VP_TS_TP_VLR_T_R", TJurPnlCampo():New(50,107,nBodyWidth,22,::oGrpPendentes,STR0015,'NXA_VLFATH'), OBJECT) // "Vlr Tempo Revisado"

	tSay():New(10,212,{|| STR0017},::oGrpPendentes,,/*TFont*/,,,,.T.,rgb(0,58,94),,100,22) // "Despesas - Moeda Oficial"
	::SetValue("VP_DS_MO_VLR", TJurPnlCampo():New(20,212,nBodyWidth,22,::oGrpPendentes,STR0025,'NXA_VLFATH'), OBJECT) // "Valor"

	tSay():New(10,317,{|| STR0018},::oGrpPendentes,,/*TFont*/,,,,.T.,rgb(0,58,94),,100,22) // "Tabelados - Moeda Oficial"
	::SetValue("VP_TB_MO_VLRT", TJurPnlCampo():New(20,317,nBodyWidth,22,::oGrpPendentes,STR0040,'NXA_VLFATH'), OBJECT) // "Valor Tabela"
	::SetValue("VP_TB_MO_VLRF", TJurPnlCampo():New(50,317,nBodyWidth,22,::oGrpPendentes,STR0041,'NXA_VLFATH'), OBJECT) // "Valor Fatu”

	tSay():New(10,422,{|| STR0019},::oGrpPendentes,,/*TFont*/,,,,.T.,rgb(0,58,94),,100,22) // "Tabelados - Tabela Caso"
	::SetValue("VP_TB_TC_VLRT", TJurPnlCampo():New(20,422,nBodyWidth,22,::oGrpPendentes,STR0040,'NXA_VLFATH'), OBJECT) // "Valor Tabela"
	::SetValue("VP_TB_TC_VLRF", TJurPnlCampo():New(50,422,nBodyWidth,22,::oGrpPendentes,STR0041,'NXA_VLFATH'), OBJECT) // "Valor Fatu”

	//FATURADOS
	::oGrpFaturados := TGroup():New( 0, 0, 70, 0, STR0020, ::oFolder:aDialogs[1], , , .T. )  //"Valores Faturados"
	::oGrpFaturados:Align := CONTROL_ALIGN_TOP

	tSay():New(100,002,{|| STR0021},::oGrpFaturados,,/*TFont*/,,,,.T.,rgb(0,58,94),,100,22) // "Time Sheet - Moeda Oficial"
	::SetValue("VF_TS_MO_VLR", TJurPnlCampo():New(110,002,nBodyWidth,22,::oGrpFaturados,STR0025,'NXA_VLFATH'), OBJECT) // "Valor"

	tSay():New(100,107,{|| STR0017},::oGrpFaturados,,/*TFont*/,,,,.T.,rgb(0,58,94),,100,22) // "Despesas - Moeda Oficial"
	::SetValue("VF_DS_MO_VLR", TJurPnlCampo():New(110,107,nBodyWidth,22,::oGrpFaturados,STR0025,'NXA_VLFATH'), OBJECT) // "Valor"

	tSay():New(100,212,{|| STR0018},::oGrpFaturados,,/*TFont*/,,,,.T.,rgb(0,58,94),,100,22) // "Tabelados - Moeda Oficial"
	::SetValue("VF_TB_MO_VLR", TJurPnlCampo():New(110,212,nBodyWidth,22,::oGrpFaturados,STR0025,'NXA_VLFATH'), OBJECT) // "Valor"

	tSay():New(100,317,{|| STR0022},::oGrpFaturados,,/*TFont*/,,,,.T.,rgb(0,58,94),,100,22) // "Fixo - Moeda Oficial"
	::SetValue("VF_FX_MO_VLR", TJurPnlCampo():New(110,317,nBodyWidth,22,::oGrpFaturados,STR0025,'NXA_VLFATH'), OBJECT) // "Valor"

	//WO
	::oGrpWO := TGroup():New( 0, 0, 100, 0, STR0023, ::oFolder:aDialogs[1], , , .T. ) //"Valores em WO"
	::oGrpWO:Align := CONTROL_ALIGN_TOP

	//tSay():New(170,002,{|| STR0021},::oGrpWO,,/*TFont*/,,,,.T.,rgb(0,58,94),,100,22) // "Time Sheet - Moeda Oficial"
	//::SetValue("WO_TS_MO_VLR", TJurPnlCampo():New(180,002,nBodyWidth,22,::oGrpWO,STR0025,'NXA_VLFATH'), OBJECT) // "Valor"

	tSay():New(170,002,{|| STR0017},::oGrpWO,,/*TFont*/,,,,.T.,rgb(0,58,94),,100,22) // "Despesas - Moeda Oficial"
	::SetValue("WO_DS_MO_VLR", TJurPnlCampo():New(180,002,nBodyWidth,22,::oGrpWO,STR0025,'NXA_VLFATH'), OBJECT) // "Valor"

	//tSay():New(170,212,{|| STR0018},::oGrpWO,,/*TFont*/,,,,.T.,rgb(0,58,94),,100,22) // "Tabelados - Moeda Oficial"
	//::SetValue("WO_TB_MO_VLR", TJurPnlCampo():New(180,212,nBodyWidth,22,::oGrpWO,STR0025,'NXA_VLFATH'), OBJECT) // "Valor"

	//tSay():New(170,317,{|| STR0022},::oGrpWO,,/*TFont*/,,,,.T.,rgb(0,58,94),,100,22) // "Fixo - Moeda Oficial"
	//::SetValue("WO_FX_MO_VLR", TJurPnlCampo():New(180,317,nBodyWidth,22,::oGrpWO,STR0025,'NXA_VLFATH'), OBJECT) // "Valor"

	For nI := 1 to Len(::aHeader)
		::aHeader[nI][OBJECT]:Disable()
	Next

	For nI := 1 to Len(::aBody)
		::aBody[nI][OBJECT]:Disable()
	Next

	//FOOTER
	//Período TSs
	oGrpFooterTS := TGroup():New( 1, 1, 35, 141, STR0009, ::oPnlFooter, , , .T. )  //"Time Sheets"
	::oFilIniTs:= TJurPnlCampo():New(10,19,50,22,oGrpFooterTS,STR0035,'NX0_DINITS', {||}, {|| }, ::GetDtIniTs(),,.F.) //"Data Inicial:"
	::oFilEndTs:= TJurPnlCampo():New(10,74,50,22,oGrpFooterTS,STR0036,'NX0_DFIMTS', {||}, {|| }, ::GetDtEndTs(),,.F.) //"Data Final:"
	//Período Despesas
	oGrpFooterDS := TGroup():New( 1, 156, 35, 296, STR0010, ::oPnlFooter, , , .T. )  //"Despesas"
	::oFilIniDs:= TJurPnlCampo():New(10,174,50,22,oGrpFooterDS,STR0035,'NX0_DINITS', {|| }, {|| }, ::GetDtIniDs(),,.F.) //"Data Inicial:"
	::oFilEndDs:= TJurPnlCampo():New(10,229,50,22,oGrpFooterDS,STR0036,'NX0_DFIMTS', {|| }, {|| }, ::GetDtEndDs(),,.F.) //"Data Final:"
	//Período Tabelados
	oGrpFooterTB := TGroup():New( 1, 311, 35, 451, STR0011, ::oPnlFooter, , , .T. )  //"Tabelados"
	::oFilIniTb:= TJurPnlCampo():New(10,329,50,22,oGrpFooterTB,STR0035,'NX0_DINITS', {|| }, {|| }, ::GetDtIniTb(),,.F.) //"Data Inicial:"
	::oFilEndTb:= TJurPnlCampo():New(10,384,50,22,oGrpFooterTB,STR0036,'NX0_DFIMTS', {|| }, {|| }, ::GetDtEndTb(),,.F.) //"Data Final:"
	//Período Fixo
	oGrpFooterFX := TGroup():New( 1, 466, 35, 606, STR0034, ::oPnlFooter, , , .T. )  //"Fixo"
	::oFilIniFx:= TJurPnlCampo():New(10,484,50,22,oGrpFooterFX,STR0035,'NX0_DINITS', {|| }, {|| }, ::GetDtIniFx(),,.F.) //"Data Inicial:"
	::oFilEndFx:= TJurPnlCampo():New(10,539,50,22,oGrpFooterFX,STR0036,'NX0_DFIMTS', {|| }, {|| }, ::GetDtEndFx(),,.F.) //"Data Final:"

	//BOTÕES
	oBtnFiltrar  := TButton():New(10,560,STR0031,::oDlg,{|| IIF(::ShowFilter(), ::Fill(),) },50,15,,,,.T.)//"Filtrar"
	oBtnExportar := TButton():New(35,560,STR0039,::oDlg,{|| ::EXPORTRES(::aHeader, ::aBody, ::aBrowse) },50,15,,,,.T.)//"Exportar p/ Excel"
	oBtnSair     := TButton():New(60,560,STR0032,::oDlg,{|| ::oDlg:End()},50,15,,,,.T.) //"Sair"

	::oFolder:nOption := 1
	oBtnFiltrar:SetFocus() //Coloca o foco no botão Filtrar, pois quando pressionava o ESC, mesmo não fechando a tela, o foco era perdido.

Return lRet

Method Fill() Class TJurCasoResumo
Local lRet := .F.
Local nI

	::oFolder:nOption := 1

	For nI := 1 to Len(::aHeader)
		::aHeader[nI][OBJECT]:SetValue( Eval(::aHeader[nI][ACTION], Self, ::GetRecno()) )
	Next

	For nI := 1 to Len(::aBody)
		::aBody[nI][OBJECT]:SetValue( Eval(::aBody[nI][ACTION], Self, ::GetRecno()) )
	Next

	//As browses serão carregadas por demanda, ou seja, ao clicar na aba os dados serão carregados
	For nI := 1 to Len(::aBrowse)
		If ::aBrowse[nI][OBJECT] != Nil
			::aBrowse[nI][OBJECT]:oOwner:FreeChildren()
			::aBrowse[nI][OBJECT] := Nil
		EndIf
	Next

	::FooterRefresh()

	::oFolder:Refresh()

Return lRet

Method GetValue(cId, nType) Class TJurCasoResumo
Local xRet := Nil
Local nPos := 0

Default nType := Nil

	If ( nPos := aScan(::aBody, {|x| x[KEY] == cId} ) ) > 0
		If Empty(nType)
			xRet := ::aBody[nPos]
		Else
			xRet := ::aBody[nPos][nType]
		EndIf
	Else
		If ( nPos := aScan(::aHeader, {|x| x[KEY] == cId} ) ) > 0
			If Empty(nType)
				xRet := ::aHeader[nPos]
			Else
				xRet := ::aHeader[nPos][nType]
			EndIf
		Else
			If ( nPos := aScan(::aBrowse, {|x| x[KEY] == cId} ) ) > 0
				If Empty(nType)
					xRet := ::aBrowse[nPos]
				Else
					xRet := ::aBrowse[nPos][nType]
				EndIf
			EndIf
		EndIf
	EndIf

Return xRet

Method SetValue(cId, xValue, nType) Class TJurCasoResumo
Local lRet := .F.
Local nPos := 0

Default nType := ACTION

	If lRet := ( nPos := aScan(::aBody, {|x| x[KEY] == cId} ) ) > 0
		::aBody[nPos][nType] := xValue
	Else
		If lRet := ( nPos := aScan(::aHeader, {|x| x[KEY] == cId} ) ) > 0
			::aHeader[nPos][nType] := xValue
		Else
			If lRet := ( nPos := aScan(::aBrowse, {|x| x[KEY] == cId} ) ) > 0
				::aBrowse[nPos][nType] := xValue
			EndIf
		EndIf
	EndIf

Return lRet

Method GetDtIniTs(lSystem) Class TJurCasoResumo
Default lSystem := .F.
Return IIF(lSystem, DToS(::dIniTs), ::dIniTs)

Method SetDtIniTs(xValue) Class TJurCasoResumo
Return (::dIniTs := SetDate(xValue)) == xValue

Method GetDtEndTs(lSystem) Class TJurCasoResumo
Default lSystem := .F.
Return IIF(lSystem, DToS(::dEndTS), ::dEndTS)

Method SetDtEndTs(xValue) Class TJurCasoResumo
Return (::dEndTs := SetDate(xValue)) == xValue

Method GetDtIniDs(lSystem) Class TJurCasoResumo
Default lSystem := .F.
Return IIF(lSystem, DToS(::dIniDs), ::dIniDs)

Method SetDtIniDs(xValue) Class TJurCasoResumo
Return (::dIniDS := SetDate(xValue)) == xValue

Method GetDtEndDs(lSystem) Class TJurCasoResumo
Default lSystem := .F.
Return IIF(lSystem, DToS(::dEndDS), ::dEndDS)

Method SetDtEndDs(xValue) Class TJurCasoResumo
Return (::dEndDs := SetDate(xValue)) == xValue

Method GetDtIniTb(lSystem) Class TJurCasoResumo
Default lSystem := .F.
Return IIF(lSystem, DToS(::dIniTb), ::dIniTb)

Method SetDtIniTb(xValue) Class TJurCasoResumo
Return (::dIniTb := SetDate(xValue)) == xValue

Method GetDtEndTb(lSystem) Class TJurCasoResumo
Default lSystem := .F.
Return IIF(lSystem, DToS(::dEndTb), ::dEndTb)

Method SetDtEndTb(xValue) Class TJurCasoResumo
Return (::dEndTb := SetDate(xValue)) == xValue

Method GetDtIniFx(lSystem) Class TJurCasoResumo
Default lSystem := .F.
Return IIF(lSystem, DToS(::dIniFx), ::dIniFx)

Method SetDtIniFx(xValue) Class TJurCasoResumo
Return (::dIniFx := SetDate(xValue)) == xValue

Method GetDtEndFx(lSystem) Class TJurCasoResumo
Default lSystem := .F.
Return IIF(lSystem, DToS(::dEndFx), ::dEndFx)

Method SetDtEndFx(xValue) Class TJurCasoResumo
Return (::dEndFx := SetDate(xValue)) == xValue

Method FooterRefresh() Class TJurCasoResumo
	::oFilIniTs:SetValue(::GetDtIniTs())
	::oFilEndTs:SetValue(::GetDtEndTs())
	::oFilIniDs:SetValue(::GetDtIniDs())
	::oFilEndDs:SetValue(::GetDtEndDs())
	::oFilIniTb:SetValue(::GetDtIniTb())
	::oFilEndTb:SetValue(::GetDtEndTb())
	::oFilIniFx:SetValue(::GetDtIniFx())
	::oFilEndFx:SetValue(::GetDtEndFx())
Return Nil

Method DrawBrowses(nOption, cId) Class TJurCasoResumo
Local lRet   := .T.
Local aRec   := Nil
Local oBjo   := Nil
Local oOwner

Default nOption := 1
Default cId     := ""

	Do Case
	Case nOption == 2 // Contratos/Junção
		cId  := "BROWSE_CJ_D"
	Case nOption == 3 // Pré-Faturas
		cId := "BROWSE_PR"
	Case nOption == 4 // Faturas
		cId := "BROWSE_FT"
	Case nOption == 5 // TS
		cId := "BROWSE_TS"
	Case nOption == 6 // Despesas
		cId := "BROWSE_DS"
	Case nOption == 7 // Tabelado
		cId := "BROWSE_TB"
	Case nOption == 8 // Cotações
		cId := "BROWSE_CT"
	End Case

	If !Empty(cId) // Diferente de Resumo

		oBjo := ::GetValue(cId, OBJECT)
		If Empty(oBjo)

			Do Case
			Case cId == "BROWSE_CJ_D"
				::DrawBrowses(0, "BROWSE_CJ_M")
				oOwner := ::oFldPnlCJ_D

			Case cId == "BROWSE_CJ_M"
				oOwner := ::oFldPnlCJ_M

			Case cId == "BROWSE_PR"
				oOwner := ::oFldPnlPR

			Case cId == "BROWSE_FT"
				oOwner := ::oFldPnlFT

			Case cId == "BROWSE_TS"
				oOwner := ::oFldPnlTS

			Case cId == "BROWSE_DS"
				oOwner := ::oFldPnlDS

			Case cId == "BROWSE_TB"
				oOwner := ::oFldPnlTB

			Case cId == "BROWSE_CT"
				oOwner := ::oFldPnlCT

			OtherWise
				oOwner := ::oFolder:aDialogs[nOption]

			End Case

			::SetValue(cId, TJurBrowse():New(oOwner), OBJECT)
			aRec := ::GetValue(cId)

			If !Empty(aRec[ACTION])

				If(Self:GetLog(), Self:SetTimer(), )
				aRec[OBJECT]:SetDataArray()
				aRec[OBJECT]:SetHeader( Eval(aRec[ACTION][HEADER], Self, ::GetRecno(), aRec[OBJECT] ) )
				If(Self:GetLog(), JurLogMsg("Tempo gasto com Header("+cId+"): "+Self:GetTimer()+" segundos"), )

				If(Self:GetLog(), Self:SetTimer(), )
				aRec[OBJECT]:Activate()
				aRec[OBJECT]:SetArray( Eval(aRec[ACTION][COL], Self, ::GetRecno(), aRec[OBJECT] ) )
				If(Self:GetLog(), JurLogMsg("Tempo gasto com Acol("+cId+"): "+Self:GetTimer()+" segundos"), )

				If cId <> "BROWSE_CT"
					aRec[OBJECT]:SetDoubleClick( {|| Eval(aRec[ACTION][DBCLICK], aRec[OBJECT]) } )
				EndIf

				If cId == "BROWSE_CJ_M"
					aRec[OBJECT]:bChange := {|| ;
						::GetValue("BROWSE_CJ_D", OBJECT):Activate() , ;
						::GetValue("BROWSE_CJ_D", OBJECT):SetArray(Eval(::GetValue("BROWSE_CJ_D", ACTION)[COL], Self, ::GetRecno())) ;
						}
				EndIf

			EndIf

		EndIf

	EndIf

Return lRet

Method SetHeaders(aHeaders) Class TJurCasoResumo

	If !Empty(aHeaders)
		::aHeaderAll := JGetSx3Cpo(aHeaders)
	EndIf

Return !Empty(::aHeaderAll)

Method GetHeaders(cTable) Class TJurCasoResumo
Local aRet  := {}
Local aAux  := {}
Local aAux2 := {}
Local nI    := 0
Local nQtd  := 0

	If !Empty(::aHeaderAll) .And. !Empty(cTable)
		If cTable == "NX6"  //Necessário devido a aba de Cotações não poder ter os campos da tabela de referência e ser a única com esta característica
			aAux := JGetSx3Cpo({cTable}, {"NX6_FILIAL", "NX6_CMOEDA","NX6_COTAC1"})
			nQtd := Len(aAux)
			For nI := 1 to nQtd
				aAux2 := Array(Len(aAux[nI])-1)
				ACopy(aAux[nI], aAux2, 2, Len(aAux[nI])-1)
				aAdd(aRet, aClone(aAux2))
				aAux2 := {}
			Next
		Else
			nQtd := Len(::aHeaderAll)
			For nI := 1 to nQtd
				If ::aHeaderAll[nI][1] == cTable
					aAux := Array(Len(::aHeaderAll[nI])-1)
					ACopy(::aHeaderAll[nI], aAux, 2, Len(::aHeaderAll[nI])-1)
					aAdd(aRet, aClone(aAux))
					aAux := {}
				EndIf
			Next
		EndIf
	EndIf

Return aRet

Method EXPORTRES(aHeader, aBody, aBrowse) Class TJurCasoResumo
Local oExcel        := FWMSEXCEL():New()
Local cCabec        := ""
Local nPos          := 0
Local aTitle        := {}
Local bTitulo       := { |cCampo| SX3->(DbSetOrder(2)), SX3->(DbSeek(cCampo)), AllTrim(X3Titulo()) }
Local cExtens       := "Arquivo XML | *.xml"
Local cContratos    := ""
Local cJuncoes      := ""
Local cPreFat       := ""
Local cFaturas      := ""
Local aPendentes[9]
Local aFaturados[4]
Local aWO[1]
Local nI
Local nX
Local cArq

	cArq := cGetFile(cExtens,STR0047,,'C:\',.F.)//Escolha o local para salvar o arquivo

	If At(".xml",cArq) == 0
		cArq += ".xml"
	Endif

	//Cabeçalho da tela de Resumo - Ref ::aHeader
	oExcel:AddworkSheet(STR0042)      //Dados do Caso
	oExcel:AddTable (STR0042,STR0004) //"Dados do Caso" "Resumo de Caso"
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_CCLIEN"),1,1)
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_CLOJA"),1,1)
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_DCLIEN"),1,1)
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_NUMCAS"),1,1)
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_TITULO"),1,1)
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_SIGLA1"),1,1)
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_DTENTR"),1,4)
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_CTABH"),1,1)
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_DTABH"),1,1)
	oExcel:AddColumn(STR0042,STR0004,STR0024,1,1) //"Moe TH"
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_CTABS"),1,1)
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_DTABS"),1,1)
	oExcel:AddColumn(STR0042,STR0004,STR0026,1,1) //"Moe Serv"
	oExcel:AddColumn(STR0042,STR0004,STR0028,1,1) //"Tab. Padrão"
	oExcel:AddColumn(STR0042,STR0004,STR0029,1,1) //"Desc. Tab Pad"
	oExcel:AddColumn(STR0042,STR0004,STR0027,1,1) //"Moe Pad"
	oExcel:AddColumn(STR0042,STR0004,STR0030,1,1) //"Md Oficial"
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_ENCHON"),1,1)
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_ENCDES"),1,1)
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_ENCTAB"),1,1)
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_EXITO"),1,1)
	oExcel:AddColumn(STR0042,STR0004,Eval(bTitulo, "NVE_DESPAD"),1,1)

	For nI := 1 To Len(aHeader)
		Do Case
		Case ValType(aHeader[nI][OBJECT]:GetValue(aHeader[nI][KEY])) == "C"
			If aHeader[nI][OBJECT]:GetValue(aHeader[nI][KEY]) == "1"  //Para tratar os campos com lista (1=Sim e 2=Não)
				cCabec += STR0045 //"Sim"
			ElseIf aHeader[nI][OBJECT]:GetValue(aHeader[nI][KEY]) == "2"
				cCabec += STR0046 //"Não"
			Else
				cCabec += StrTran(Alltrim(aHeader[nI][OBJECT]:GetValue(aHeader[nI][KEY])),"|",",")
			EndIf
		Case ValType(aHeader[nI][OBJECT]:GetValue(aHeader[nI][KEY])) == "N"
			cCabec += Strtran(Alltrim(Str(aHeader[nI][OBJECT]:GetValue(aHeader[nI][KEY]))),"|",",")
		Case ValType(aHeader[nI][OBJECT]:GetValue(aHeader[nI][KEY])) == "D"
	   		cCabec += Strtran(Alltrim(DtoC(aHeader[nI][OBJECT]:GetValue(aHeader[nI][KEY]))),"|",",")
	 	OtherWise
	   		cCabec += " "
		End Case

		If nI <> Len(aHeader)
			cCabec += " |"
		EndIf

		//Necessário pois quando o último registro da tabela está em branco, ao montar o array ele não é considerado como uma posição, gerando
		//inconsistência com a quantidade de colunas
		If nI == Len(aHeader) .And. (RAT("|", cCabec) == Len(cCabec))
			cCabec += " - "
		EndIf
	Next
	oExcel:AddRow(STR0042,STR0004, StrToArray(cCabec, "|"))

	//Body da tela de Resumo - Ref ::aBody
	//VALORES PENDENTES
	oExcel:AddworkSheet(STR0043)      //"Dados de Valores Pendentes"
	oExcel:AddTable (STR0043,STR0012) //"Dados de Valores Pendentes"  "Valores Pendentes"

	oExcel:AddColumn(STR0043,STR0012,STR0013+" - "+STR0014,1,2) //"Time Sheet - Tabela Caso" - "Vlr Tempo Lançado"
	oExcel:AddColumn(STR0043,STR0012,STR0013+" - "+STR0015,1,2) //"Time Sheet - Tabela Caso" - "Vlr Tempo Revisado"
	oExcel:AddColumn(STR0043,STR0012,STR0016+" - "+STR0014,1,2) //"Time Sheet - Tabela Padrão" - "Vlr Tempo Lançado"
	oExcel:AddColumn(STR0043,STR0012,STR0016+" - "+STR0015,1,2) //"Time Sheet - Tabela Padrão" - "Vlr Tempo Revisado"
	oExcel:AddColumn(STR0043,STR0012,STR0017+" - "+STR0025,1,2) //"Despesas - Moeda Oficial" // "Valor"
	oExcel:AddColumn(STR0043,STR0012,STR0018+" - "+STR0040,1,2) //"Tabelados - Moeda Oficial" // "Valor Tabela"
	oExcel:AddColumn(STR0043,STR0012,STR0018+" - "+STR0041,1,2) //"Tabelados - Moeda Oficial" // "Valor Fatu”
	oExcel:AddColumn(STR0043,STR0012,STR0019+" - "+STR0040,1,2) //"Tabelados - Tabela Caso" // "Valor Tabela"
	oExcel:AddColumn(STR0043,STR0012,STR0019+" - "+STR0041,1,2) //"Tabelados - Tabela Caso" // "Valor Fatu”

	For nI := 1 To 9    //9 é a quantidade de itens em Valores Pendentes. Havendo alteração, mudar aqui tb!
		aPendentes[nI] := aBody[nI][OBJECT]:GetValue(aBody[nI][KEY])
	Next

	oExcel:AddRow(STR0043,STR0012, aPendentes)

	//VALORES FATURADOS
	oExcel:AddworkSheet(STR0044)      //"Dados de Valores Faturados"
	oExcel:AddTable (STR0044,STR0020) //"Dados de Valores Faturados"  "Valores Faturados"

	oExcel:AddColumn(STR0044,STR0020,STR0021,1,2) //"Time Sheet - Moeda Oficial"
	oExcel:AddColumn(STR0044,STR0020,STR0017,1,2) //"Despesas - Moeda Oficial"
	oExcel:AddColumn(STR0044,STR0020,STR0018,1,2) //"Tabelados - Moeda Oficial"
	oExcel:AddColumn(STR0044,STR0020,STR0022,1,2) //"Fixo - Moeda Oficial"

	For nI := 10 To 13
		nPos ++
		aFaturados[nPos] := aBody[nI][OBJECT]:GetValue(aBody[nI][KEY])
	Next

	oExcel:AddRow(STR0044,STR0020, aFaturados)

	//VALORES EM WO
	oExcel:AddworkSheet(STR0048)      //"Dados de Valores em WO"
	oExcel:AddTable (STR0048,STR0023) //"Dados de Valores Faturados"  "Valores em WO"

	//oExcel:AddColumn(STR0048,STR0023,STR0021,1,2) //"Time Sheet - Moeda Oficial"
	oExcel:AddColumn(STR0048,STR0023,STR0017,1,2) //"Despesas - Moeda Oficial"
	//oExcel:AddColumn(STR0048,STR0023,STR0018,1,2) //"Tabelados - Moeda Oficial"
	//oExcel:AddColumn(STR0048,STR0023,STR0022,1,2) //"Fixo - Moeda Oficial"

	nPos := 1
	//For nI := 14 To nI<15
		//nPos ++
		aWO[nPos] := aBody[nI][OBJECT]:GetValue(aBody[nI][KEY])
	//Next

	oExcel:AddRow(STR0048,STR0023, aWO)

	//Grids da tela de Resumo - Ref ::aBrowse

	//Executa o DrawBrowses pois, como as grids são geradas sob demanda, há a possibilidade de estarem como Nil.
	For nI := 1 To Len(aBrowse)
		If aBrowse[nI][OBJECT] == Nil
			::Drawbrowses(nI)
		EndIf
	Next

	//CONTRATOS

 	If Len(aBrowse[1][2]:aCols) > 0
		oExcel:AddworkSheet(STR0049)      //"Dados de Contratos"
		oExcel:AddTable (STR0049,STR0050) //"Dados de Contratos"  "Contratos"

		::EXPORTAUX(1,STR0049,STR0050, aBrowse, oExcel)
	EndIf

	//JUNÇÃO DE CONTRATOS

 	If Len(aBrowse[2][2]:aCols) > 0
		oExcel:AddworkSheet(STR0051)      //"Dados de Junção"
		oExcel:AddTable (STR0051,STR0052) //"Dados de Junção"  "Junções de Contratos"

		::EXPORTAUX(2,STR0051,STR0052, aBrowse, oExcel)
	EndIf

	//PRÉ-FATURAS

 	If Len(aBrowse[3][2]:aCols) > 0
		oExcel:AddworkSheet(STR0053)      //"Dados de Pré-faturas"
		oExcel:AddTable (STR0053,STR0007) //"Dados de Pré-faturas"  "Pré-Faturas"

		::EXPORTAUX(3,STR0053,STR0007, aBrowse, oExcel)
	EndIf

	//FATURAS

 	If Len(aBrowse[4][2]:aCols) > 0
		oExcel:AddworkSheet(STR0054)      //"Dados de Faturas"
		oExcel:AddTable (STR0054,STR0008) //"Dados de Faturas"  "Faturas"

		::EXPORTAUX(4,STR0054,STR0008, aBrowse, oExcel)
	EndIf

	//TIME SHEETS

 	If Len(aBrowse[5][2]:aCols) > 0
		oExcel:AddworkSheet(STR0055)      //"Dados de Time Sheets"
		oExcel:AddTable (STR0055,STR0009) //"Dados de Time Sheets"  "Time Sheets"

		::EXPORTAUX(5,STR0055,STR0009, aBrowse, oExcel)
	EndIf

	//DESPESAS

 	If Len(aBrowse[6][2]:aCols) > 0
		oExcel:AddworkSheet(STR0056)      //"Dados de Despesas"
		oExcel:AddTable (STR0056,STR0010) //"Dados de Despesas"  "Despesas"

		::EXPORTAUX(6,STR0056,STR0010, aBrowse, oExcel)
	EndIf

	//TABELADOS

 	If Len(aBrowse[7][2]:aCols) > 0
		oExcel:AddworkSheet(STR0057)      //"Dados de Tabelados"
		oExcel:AddTable (STR0057,STR0011) //"Dados de Tabelados"  "Tabelados"

		::EXPORTAUX(7,STR0057,STR0011, aBrowse, oExcel)
	EndIf

	//COTAÇÕES

 	If Len(aBrowse[8][2]:aCols) > 0
		oExcel:AddworkSheet(STR0058)      //"Dados de Cotações"
		oExcel:AddTable (STR0058,STR0037) //"Dados de Cotações"  "Cotações (Valores Pendentes)"

		::EXPORTAUX(8,STR0058,STR0037, aBrowse, oExcel)
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile(cArq)
Return

Method EXPORTAUX(nBrowse, cWorkSheet, cTable, aBrowse, oExcel) Class TJurCasoResumo
Local cBrowse  := ""
Local nPos     := 0
Local nPosAux  := 0
Local nI
Local nX

	For nI := 1 To Len(aBrowse[nBrowse][OBJECT]:aHeader)
		If aBrowse[nBrowse][OBJECT]:aHeader[nI][8] == "C"
			oExcel:AddColumn(cWorkSheet,cTable,aBrowse[nBrowse][OBJECT]:aHeader[nI][1],1,1)
		ElseIf aBrowse[nBrowse][OBJECT]:aHeader[nI][8] == "D"
			oExcel:AddColumn(cWorkSheet,cTable,aBrowse[nBrowse][OBJECT]:aHeader[nI][1],3,4)
		ElseIf aBrowse[nBrowse][OBJECT]:aHeader[nI][8] == "N"
			oExcel:AddColumn(cWorkSheet,cTable,aBrowse[nBrowse][OBJECT]:aHeader[nI][1],3,2)
		Else
			oExcel:AddColumn(cWorkSheet,cTable,aBrowse[nBrowse][OBJECT]:aHeader[nI][1],3,1)
		EndIf
	Next

	For nI := 1 To Len(aBrowse[nBrowse][2]:aCols)
		For nX := 1 To Len(aBrowse[nBrowse][OBJECT]:aCols[nI])
			Do Case
			Case ValType(aBrowse[nBrowse][OBJECT]:aCols[nI][nX]) == "C"
				If !Empty(aBrowse[nBrowse][OBJECT]:aHeader[nX][3])       //Picture
					cBrowse += Strtran(Alltrim(TRANSFORM(aBrowse[nBrowse][2]:aCols[nI][nX], aBrowse[nBrowse][OBJECT]:aHeader[nX][3])),"|",",")
				ElseIf !Empty(aBrowse[nBrowse][OBJECT]:aHeader[nX][16]) .And. !Empty(aBrowse[nBrowse][2]:aCols[nI][nX])  //Lista de Opções
					nPos := At((aBrowse[nBrowse][2]:aCols[nI][nX])+"=",aBrowse[nBrowse][OBJECT]:aHeader[nX][16])
					nPosAux := At(Alltrim(Str((Val(aBrowse[nBrowse][2]:aCols[nI][nX])+1))),aBrowse[nBrowse][OBJECT]:aHeader[nX][16])
					cBrowse+= Strtran(Alltrim(Substr(aBrowse[nBrowse][2]:aHeader[nX][16],nPos+2,Iif(nPosAux > 0, nPosAux-4,30))),"|",",")
				ElseIf aBrowse[nBrowse][OBJECT]:aHeader[nX][8] == "D"    //Para tratar as datas que vêem como caracter mas o tipo é data
					If !Empty(aBrowse[nBrowse][2]:aCols[nI][nX])
						cBrowse += Iif(!Empty(aBrowse[nBrowse][OBJECT]:aHeader[nX][3]), Alltrim(TRANSFORM(aBrowse[nBrowse][2]:aCols[nI][nX], aBrowse[nBrowse][OBJECT]:aHeader[nX][3])),DtoC(StoD(aBrowse[nBrowse][2]:aCols[nI][nX])))
					EndIf
				Else
					cBrowse += Strtran(Alltrim(aBrowse[nBrowse][OBJECT]:aCols[nI][nX]),"|",",")
				EndIf
			Case ValType(aBrowse[nBrowse][OBJECT]:aCols[nI][nX]) == "N"
				cBrowse += Strtran(Alltrim(TRANSFORM(aBrowse[nBrowse][OBJECT]:aCols[nI][nX], aBrowse[nBrowse][OBJECT]:aHeader[nX][3])),"|",",")
			Case ValType(aBrowse[nBrowse][OBJECT]:aCols[nI][nX]) == "D"
		   		cBrowse += Strtran(Alltrim(DtoC(aBrowse[nBrowse][OBJECT]:aCols[nI][nX])),"|",",")
			End Case

			If nX <> Len(aBrowse[nBrowse][OBJECT]:aCols[nI])
				cBrowse += " |"
			EndIf

			//Necessário pois quando o último registro da tabela está em branco, ao montar o array ele não é considerado como uma posição, gerando
			//inconsistência com a quantidade de colunas
			If nX == Len(aBrowse[nBrowse][OBJECT]:aCols[nI]) .And. (RAT("|", cBrowse) == Len(cBrowse))
				cBrowse += " - "
			EndIf
		Next
		oExcel:AddRow(cWorkSheet,cTable, StrToArray(cBrowse, "|"))
		cBrowse := ""
	Next

Return

// Functions

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDate
Efetua o set da data.

@author Felipe Bonvicini
@since 11/12/13
@version 1.0
/*/
//-------------------------------------------------------------------

Static function SetDate(xValue)
Local dDate

Default xValue := Date()

    Do Case
	Case ValType(xValue) == "D"
		dDate := xValue
	Case ValType(xValue) == "C"
		dDate := CToD(xValue)
	Case ValType(xValue) == "S"
		dDate := SToD(xValue)
	OtherWise
		//
	End Case

Return dDate

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaPeriodo
Efetua as validações de preenchimento dos períodos de filtro.

@author Cristina Cintra
@since 11/12/13
@version 1.0
/*/
//-------------------------------------------------------------------

Static function ValidaPeriodo(oDtIniTs, oDtEndTs, oDtIniDs, oDtEndDs, oDtIniTb, oDtEndTb, oDtIniFx, oDtEndFx)
Local lRet := .F.

	If ( !Empty(oDtIniTs:GetValue()) .And. !Empty(oDtEndTs:GetValue()) .And. !Empty(oDtIniDs:GetValue()) .And. !Empty(oDtEndDs:GetValue()) .And.;
	   !Empty(oDtIniTb:GetValue()) .And. !Empty(oDtEndTb:GetValue()) .And. !Empty(oDtIniFx:GetValue()) .And. !Empty(oDtEndFx:GetValue()) ) .And.;
	   ( (oDtIniTs:GetValue() <= oDtEndTs:GetValue()) .And. (oDtIniDs:GetValue() <= oDtEndDs:GetValue()) .And. (oDtIniTb:GetValue() <= oDtEndTb:GetValue());
	   .And. (oDtIniFx:GetValue() <= oDtEndFx:GetValue()) )
		lRet := .T.
	EndIf

Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} JGetSx3Cpo()
Função utilizada para retornar campos da SX3.

@param aTab   , Array com as tabelas para verificar a SX3
@param aCampos, Array com os campos para verificar na SX3 conforme o aTab

@author Bruno Ritter
@since 18/03/2019
-------------------------------------------------------------------*/
Static Function JGetSx3Cpo(aTab, aCampos)
	Local aRet      := {}
	Local cSX3Tmp   := GetNextAlias()
	Local aFilds    := {}
	Local cX3Campo  := ""
	Local nI        := 0
	Local lTodosCpo := .F.

	Default aCampos := {}

	OpenSxs(,,,, cEmpAnt, cSX3Tmp, "SX3", ,.F.)
	lTodosCpo := Empty(aCampos)
	aSort(aTab)

	For nI := 1 To Len(aTab)
		cAlias := aTab[nI]

		If (cSX3Tmp)->(DbSeek(cAlias))
			While (cSX3Tmp)->X3_ARQUIVO == cAlias .And. !(cSX3Tmp)->(EOF())

				cX3Campo := AllTrim((cSX3Tmp)->X3_CAMPO)

				If (lTodosCpo .Or. aScan(aCampos, cX3Campo) > 0) ;
				   .And. (cSX3Tmp)->X3_CONTEXT == "R" .And. (cSX3Tmp)->X3_BROWSE == "S";
				   .And. X3USO((cSX3Tmp)->X3_USADO) .And. cNivel >= (cSX3Tmp)->X3_NIVEL
					
					aFilds    := {}
					Aadd(aFilds, (cSX3Tmp)->X3_ARQUIVO)
					Aadd(aFilds, (cSX3Tmp)->X3_TITULO)
					Aadd(aFilds, (cSX3Tmp)->X3_CAMPO)
					Aadd(aFilds, (cSX3Tmp)->X3_PICTURE)
					Aadd(aFilds, (cSX3Tmp)->X3_TAMANHO)
					Aadd(aFilds, (cSX3Tmp)->X3_DECIMAL)
					Aadd(aFilds, (cSX3Tmp)->X3_VALID)
					Aadd(aFilds, (cSX3Tmp)->X3_USADO)
					Aadd(aFilds, (cSX3Tmp)->X3_TIPO)
					Aadd(aFilds, (cSX3Tmp)->X3_F3)
					Aadd(aFilds, (cSX3Tmp)->X3_CONTEXT)
					Aadd(aFilds, (cSX3Tmp)->X3_CBOX)
					Aadd(aFilds, (cSX3Tmp)->X3_RELACAO)
					Aadd(aFilds, (cSX3Tmp)->X3_WHEN)
					Aadd(aFilds, (cSX3Tmp)->X3_VISUAL)
					Aadd(aFilds, (cSX3Tmp)->X3_VLDUSER)
					Aadd(aFilds, (cSX3Tmp)->X3_CBOX)

					aAdd(aRet, aClone(aFilds))
				EndIf

				(cSX3Tmp)->(DbSkip())
			EndDo
		EndIf
	Next nI

	(cSX3Tmp)->(DbCloseArea())

Return aRet