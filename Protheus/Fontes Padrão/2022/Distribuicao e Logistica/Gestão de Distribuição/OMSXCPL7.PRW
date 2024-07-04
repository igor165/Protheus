#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "OMSXCPL7.CH"

Static lMarkAll  := .F. // Indicador de marca/desmarca todos...
Static oBrowse   := Nil
Static oTempTab  := Nil
Static cAliasTMP := Nil
Static lExistSX1 := OSExistSX1()
Static lIntCpl   := SuperGetMv("MV_CPLINT",.F.,"2") == "1" //Indica se o sistema integra com o Planejamento CPL
Static lIntMon   := SuperGetMv("MV_CPLMON",.F.,"2") == "1" //Indica se o sistema integra com o Monitoramento CPL
Static lIntGFE	 := SuperGetMv("MV_INTGFE",.F.,.F.)
Static cIntGFE2	 := SuperGetMv("MV_INTGFE2",.F.,"2")
Static cIntCarga  := SuperGetMv("MV_GFEI12",.F.,"2")
//Integração com o GFE na Classificação e Tipo de Operação
Static cClassGFE := AvKey(SuperGetMv("MV_CDCLFR",.F.,"")	,"DAK_CDCLFR") //Classificação de Frete no GFE
Static cOperaGFE := AvKey(SuperGetMv("MV_CDTPOP",.F.,"")	,"DAK_CDTPOP") //Tipo de Operação de Frete no GFE
Static lOMSCPL7H := ExistBlock("OMSCPL7H") //Ponto de entrada para adicionar novas opções no menu da tela de Monitor de Carga

/*/{Protheus.doc} OMSXCPL7
Monitor de Cargas OMS x CPL.
O monitor tem o objetivo de apresentar as viagens recebidas do Cokcpit Logístico, 
bem como as cargas aptas a serem integradas para o monitoramento
@author amanda.vieira
@since 12/09/2019
@version 1.0
@type function
/*/

Function OMSXCPL7(nOpcAuto)
Local aAreaAnt := GetArea()
Local bKeyF5   := SetKey(VK_F5)
Local aColsSX3 := {}
Local aBrwCols := {}
Local aFields  := {}
Local aIndex   := {}
Local aSeek    := {}
Local aArqTab  := {}
Local lIsBlind := IsBlind()
Local lRet     := .T.
Default nOpcAuto := 3

		//Validação para gravação da Data do fonte no LOGOMSCPL
	OsLogCpl("-----------------------------------------------------------------------------------------","DATA")
	OsLogCPL("Inspetor de Objetos CPL","DATA")
	OsLogCpl("-----------------------------------------------------------------------------------------","DATA")
	OmCPLIns()
	OsLogCpl("-----------------------------------------------------------------------------------------","DATA")

	PutGlbValue( "GLB_OMSLOG",GetSrvProfString("LOGCPLOMS", ".F.") )
	PutGlbValue( "GLB_OMSTIP",GetSrvProfString("LOGTIPOMS", "CONSOLE") )
	
	OsLogCPL("OMSXCPL7 -> OMSXCPL7 -> Inicio do metodo. Conteudo da variavel lIsBlind: " + Iif(lIsBlind,"TRUE","FALSE"),"INFO")
	OsLogCPL("OMSXCPL7 -> OMSXCPL7 -> Inicio do metodo. Conteudo da variavel lExistSX1: " + Iif(lExistSX1,"TRUE","FALSE"),"INFO")			

	If !lIsBlind .And. lExistSX1 .And. !Pergunte("OMSXCPL7",.T.)
		Return
	EndIf

	/*
	Array contendo o objeto FWBrwColumn ou um array com a seguinte estrutura:
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Parâmetro reservado
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Parâmetro reservado
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	//+--------------------------------------------------------------+
	//| IMPORTANTE - Não trocar a ordem dos campos no Array aArqTab, |
	//|              pois eles são na mesma ordem da query           |
	//+--------------------------------------------------------------+
	AAdd(aArqTab ,{"TMP_MARK","C",2,0})
	AAdd(aArqTab ,{"TMP_SITCAR","C",1,0})
	AAdd(aArqTab ,{"TMP_SITVIG","C",1,0})

	AAdd(aFields ,{"TMP_SITCAR",STR0031,"C",1,0,"@!"}) // Situação Carga
	AAdd(aFields ,{"TMP_SITVIG",STR0032,"C",1,0,"@!"}) // Situação Viagem
	
	BuscarSX3("DK0_VIAGID",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_VIAGID }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_VIAGID",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_VIAGID","C",aColsSX3[3],aColsSX3[4]})
	
	BuscarSX3("DK0_REGID",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_REGID }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_REGID",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_REGID","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("DAK_COD",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_CARGA }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_CARGA",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_CARGA","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("DAK_SEQCAR",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_SEQCAR }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_SEQCAR",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_SEQCAR","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("DK0_TRANSP",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_TRANSP }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_TRANSP",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_TRANSP","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("DK0_TIPVEI",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_TIPVEI }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_TIPVEI",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_TIPVEI","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("DK0_PLACA",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_PLACA }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_PLACA",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_PLACA","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("DK0_DATINT",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_DATINT }, "D", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_DATINT",aColsSX3[1],"D",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_DATINT","D",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("DK0_HORINT",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_HORINT }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_HORINT",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_HORINT","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("DAK_DATA",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_DATACG }, "D", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_DATACG",aColsSX3[1],"D",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_DATACG","D",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("DAK_HORA",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_DATACG }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_HORACG",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_HORACG","C",aColsSX3[3],aColsSX3[4]})

	AAdd(aArqTab ,{"TMP_RECDK0","N",10,0})
	AAdd(aArqTab ,{"TMP_RECDAK","N",10,0})

	AAdd(aSeek ,{ RTrim(aBrwCols[1,1]) + ' + ' + RTrim(aBrwCols[2,1]), {;
		{"",aBrwCols[1,3], aBrwCols[1,6], aBrwCols[1,7], aBrwCols[1,1], aBrwCols[1,4]},;
		{"",aBrwCols[2,3], aBrwCols[2,6], aBrwCols[2,7], aBrwCols[2,1], aBrwCols[2,4]}}})

	AAdd(aSeek ,{ RTrim(aBrwCols[3,1]) + ' + ' + RTrim(aBrwCols[4,1]), {;
		{"",aBrwCols[3,3], aBrwCols[3,6], aBrwCols[3,7], aBrwCols[3,1], aBrwCols[3,4]},;
		{"",aBrwCols[4,3], aBrwCols[4,6], aBrwCols[4,7], aBrwCols[4,1], aBrwCols[4,4]}}})

	aIndex := {"TMP_VIAGID+TMP_REGID","TMP_CARGA+TMP_SEQCAR"}

	OsLogCPL("OMSXCPL7 -> OMSXCPL7 -> Vai executar CriaTabTmp.","INFO")

	CriaTabTmp(aArqTab,aIndex,@cAliasTMP,@oTempTab)

	OsLogCPL("OMSXCPL7 -> OMSXCPL7 -> Vai executar LoadData.","INFO")

	LoadData()

	If lIsBlind

		Do Case
			Case nOpcAuto = 1 
				OMSXCPL7L()// Liberar Viagem
			Case nOpcAuto = 2
				OMSXCPL7G()// Gerar Carga
			Case nOpcAuto = 3
				BatchProcess("OMSXCPL6",STR0033,,{ || lRet := Cpl7EnvBat() }) //Envio de Cargas para o monitoramento
			Case nOpcAuto = 4
				lRet := OMSXCPLEM(.T.) // Cancelar Monitoramento Carga
			Case nOpcAuto = 5 // Visualizar Carga
				//OMSCPL7VC()
			Case nOpcAuto = 6  //Visualizar Viagem
				//OMSCPL7VV()
			Case nOpcAuto = 7  //Tipo Oper/ Class. Frete
				//OMSCPL7CL()
		EndCase

	Else
		oBrowse := FWMarkBrowse():New()
		oBrowse:SetDescription(STR0034) //Monitor de Cargas
		oBrowse:SetMenuDef("OMSXCPL7")
		oBrowse:SetTemporary(.T.)
		oBrowse:SetAlias(cAliasTMP)
		oBrowse:AddStatusColumns({||StatusCarg((cAliasTMP)->TMP_SITCAR)}, {||LegendCarg()})
		oBrowse:AddStatusColumns({||StatusViag((cAliasTMP)->TMP_SITVIG)}, {||LegendViag()})
		oBrowse:SetFieldMark("TMP_MARK")
		oBrowse:SetAllMark({||AllMark()})
		oBrowse:SetColumns(aBrwCols)
		oBrowse:SetOnlyFields({})
		oBrowse:oBrowse:SetFieldFilter( aFields )
		oBrowse:oBrowse:SetUseFilter()
		oBrowse:DisableDetails()
		oBrowse:SetSeek(/*bSeek*/,aSeek)
		oBrowse:SetParam({|| UpdSelecao() })

		SetKey(VK_F5, {|| RefreshBrw(.T.) })

		oBrowse:Activate()

		SetKey(VK_F5, bKeyF5)
		
		oBrowse := Nil
		RestArea(aAreaAnt)
	EndIf

	//Libera memória utilizada
	DelTabTmp(cAliasTMP,oTempTab)

Return lRet

/*/{Protheus.doc} MenuDef
Monta o menu da rotina para ser usado no Browse
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function MenuDef()
Local aRotina  := {}
Local aRotiPE  := {}	
Local nX	   := 0

	If lIntCpl
		ADD OPTION aRotina TITLE STR0005 ACTION "OMSXCPL7L" OPERATION 2 ACCESS 0 // Liberar Viagem
		ADD OPTION aRotina TITLE STR0007 ACTION "OMSXCPL7G" OPERATION 2 ACCESS 0 // Gerar Carga
	EndIf
	If TableInDic("DK5", .F.) .And. lIntMon
		ADD OPTION aRotina TITLE STR0035 ACTION "OMSXCPLMN" OPERATION 2 ACCESS 0 // Enviar Cargas p/ Monitoramento
		ADD OPTION aRotina TITLE STR0064 ACTION "OMSXCPLEM" OPERATION 2 ACCESS 0 // Cancelar Monitoramento Carga
	EndIf
	ADD OPTION aRotina TITLE STR0036 ACTION "OMSCPL7VC" OPERATION 2 ACCESS 0 // Visualizar Carga
	ADD OPTION aRotina TITLE STR0037 ACTION "OMSCPL7VV" OPERATION 2 ACCESS 0 // Visualizar Viagem
	
	ADD OPTION aRotina TITLE OemtoAnsi("Tipo Oper/ Class. Frete") ACTION "OMSCPL7CL" OPERATION 2 ACCESS 0 //Tipo Oper/ Class. Frete

	//Ponto de entrada para adicionar novas opções no menu da tela de Monitor de Viagem 
	If lOMSCPL7H
		aRotiPE := ExecBlock( "OMSCPL7H", .F., .F.)
		If ValType(aRotiPE)=="A" .And. Len(aRotiPE) > 0
			For nX := 1 To Len(aRotiPE)
                aadd(aRotina,aRotiPE[nX])
            Next nX
		EndIf
	EndIf	
		
Return aRotina
/*/{Protheus.doc} ModelDef
ModelDef com base na DK1 e DK0
@since 12/09/2019
@version 1.0
/*/
Static Function ModelDef()
Local oModel
Local oStDK0  := FWFormStruct(1, 'DK0')
Local oStDK1  := FWFormStruct(1, 'DK1')

oModel := MPFormModel():New("OMSXCPL7", /*bPre*/, /* bPost*/, /*bACommit*/, /*bCancel*/)

oModel:AddFields("FIELDS_DK0", Nil, oStDK0,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:AddGrid( "GRID_DK1"	, "FIELDS_DK0"	, oStDK1, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetRelation( 'GRID_DK1', ;
					{{'DK1_FILIAL', 'xFilial("DK1")'},;
					{'DK1_REGID',   'DK0_REGID'},;
 					{'DK1_VIAGID',  'DK0_VIAGID'}},;
 					DK1->(IndexKey(1))  )

oModel:SetPrimaryKey({"DK0_FILIAL","DK0_REGID", "DK0_VIAGID"})

Return oModel
/*/{Protheus.doc} ViewDef
ViewDef com base na DK1 e DK0
@since 12/09/2019
@version 1.0
/*/
Static Function ViewDef()
Local oModel    := FWLoadModel("OMSXCPL7")
Local oStDK0    := FWFormStruct(2, 'DK0')
Local oStDK1    := FWFormStruct(2, 'DK1')
Local oView     := FWFormView():New()

oStDK0:RemoveField("DK0_MARK")
oStDK1:RemoveField("DK1_VIAGID")
oView:SetModel(oModel)

oView:AddField('VIEW_DK0',oStDK0,'FIELDS_DK0')
oView:AddGrid('VIEW_DK1',oStDK1,'GRID_DK1')

oView:CreateHorizontalBox( "MASTER", 45)
oView:SetOwnerView("VIEW_DK0", "MASTER")

oView:CreateHorizontalBox( "DETAIL", 55)
oView:SetOwnerView("VIEW_DK1", "DETAIL")

oView:EnableTitleView( "VIEW_DK0", STR0016 ) //"Viagem CockPit Logístico"
oView:EnableTitleView( "VIEW_DK1", STR0017 ) //"Itens da Viagem"

Return oView
/*/{Protheus.doc} LoadData
Efetua a carga dos dados na tabela temporária criada com base nos parâmetros do pergunte
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function LoadData()
Local cQuery := ""
	//Monta temporária
	Pergunte("OMSXCPL7",.F.)
	cQuery := QryTemp()
	WmsQry2Tmp(cAliasTMP,oTempTab:oStruct:aFields,cQuery,oTempTab,,.T.)
Return
/*/{Protheus.doc} LegendViag
Legenda da Viagem
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function LegendViag()
Local oLegend  :=  FWLegend():New()
	oLegend:Add("","BR_BRANCO", STR0038 ) // Viagem Não Gerada
	oLegend:Add("","BR_LARANJA", STR0018 ) // Viagem Recebida
	oLegend:Add("","BR_VIOLETA", STR0019 ) // Viagem Aguardando Liberação
	oLegend:Add("","BR_VERDE", STR0039 ) // Viagem Liberada
	oLegend:Add("","BR_VERMELHO", STR0020 ) // Viagem Falha Liberação
	oLegend:Add("","BR_MARROM", STR0021 ) // Viagem Reprogramada
	oLegend:Add("","BR_CANCEL", STR0022 ) // Viagem Cancelada
	oLegend:Add("","BR_AMARELO", STR0023 ) // Viagem Rejeitada
	oLegend:Activate()
	oLegend:View()
	oLegend:DeActivate()
Return
/*/{Protheus.doc} LegendCarg
Legenda da Carga
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function LegendCarg()
Local oLegend  :=  FWLegend():New()
	oLegend:Add("","BR_BRANCO", STR0040 ) // Carga Não Gerada
	oLegend:Add("","BR_AZUL", STR0041 ) // Carga Gerada
	oLegend:Add("","BR_VERDE", STR0042 ) // Carga Faturada
	oLegend:Add("","BR_AMARELO", STR0043 ) // Carga Monitorada
	oLegend:Add("","BR_PRETO", STR0073 ) // Carga Finalizada
	oLegend:Activate()
	oLegend:View()
	oLegend:DeActivate()
Return
/*/{Protheus.doc} StatusViag
Status da viagem
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function StatusViag(cStatus)
Local cRetorno := ""
	If cStatus == "0" //Recebida
		cRetorno := "BR_LARANJA"
	ElseIf cStatus == "1" // Aguardando Liberação
		cRetorno := "BR_VIOLETA"
	ElseIf cStatus == "2" // Liberada
		cRetorno := "BR_VERDE"
	ElseIf cStatus == "3" // Falha Liberação
		cRetorno := "BR_VERMELHO"
	ElseIf cStatus = "4" // Reprogramada
		cRetorno := "BR_MARROM"
	ElseIf cStatus == "5" // Cancelada
		cRetorno := "BR_CANCEL"
	ElseIf cStatus == "6" // Rejeitada
		cRetorno := "BR_AMARELO"
	Else
		cRetorno := "BR_BRANCO" //Sem viagem
	EndIf
Return cRetorno
/*/{Protheus.doc} StatusCarg
Status da carga
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function StatusCarg(cStatus)
Local cRetorno := ""
	If cStatus == "2" // Carga Gerada
		cRetorno := "BR_AZUL"
	ElseIf cStatus == "3" // Carga Faturada
		cRetorno := "BR_VERDE"
	ElseIf cStatus == "4" // Carga Monitorada
		cRetorno := "BR_AMARELO"
	ElseIf cStatus == "5" // Carga Finalizada
		cRetorno := "BR_PRETO"
	Else
		cRetorno := "BR_BRANCO" //Sem carga
	EndIf
Return cRetorno
/*/{Protheus.doc} UpdSelecao
Permite informar novamente os perguntes da rotina
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function UpdSelecao()
	lMarkAll := .F.
	If Pergunte('OMSXCPL7', .T.)
		LoadData()
		oBrowse:Refresh(.T.)
	EndIf
Return
/*/{Protheus.doc} RefreshBrw
Realiza a atualização da tela
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function RefreshBrw(lPergunta)
Default lPergunta := .F.
	lMarkAll := .F.
	Pergunte('OMSXCPL7', .F.)
	LoadData()
	oBrowse:Refresh(.T.)
Return
/*/{Protheus.doc} AllMark
Marca todos os registros da seleção no Browse
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function AllMark()
Local aAreaTmp  := (cAliasTMP)->(GetArea())
Local cAliasBrw := ""
Local cMark     := ""

	lMarkAll := !lMarkAll
	cMark    := Iif(lMarkAll,oBrowse:Mark(),Space(2))
	// Busca alias do próprio browse, que neste caso é cAliasTMP
	cAliasBrw := oBrowse:Alias()
	// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
	// a regra de marcação será executada apenas para os registros que o usuário vê em tela
	(cAliasBrw)->(DbGoTop())
	While (cAliasBrw)->(!Eof())
		Reclock(cAliasTMP,.F.)
		(cAliasTMP)->TMP_MARK := cMark
		(cAliasTMP)->(MsUnlock())
		(cAliasBrw)->(DbSkip())
	EndDo

RestArea(aAreaTmp)
oBrowse:Refresh()
Return
/*/{Protheus.doc} Cpl7EnvBat
Responsável por enviar as cargas para o monitoramento no CPL em batch (schedule)
@author amanda.vieira
@since 12/09/2019
@version 1.0
@see (links_or_references)
/*/
Static Function Cpl7EnvBat()
	lRet := ProcEnvMon()
Return lRet
/*/{Protheus.doc} Scheddef
	Permite a execução agendada.
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function SchedDef()
	Local aParam
	aParam := { "P",;	//Tipo R para relatorio P para processo
				"OMSXCPL7",;	 // Pergunte do relatorio, caso nao use passar ParamDef
							,;  // Alias
							,;   //Array de ordens
				STR0033} //Envio de cargas para o monitoramento
Return aParam
/*/{Protheus.doc} QryTemp
Monta query com as viagens e cargas que serão apresentadas na grid
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function QryTemp()
Local cQuery    := ""
Local cStatusVg := ""
Local cCargaDe  := Iif(lExistSX1,MV_PAR01,Space(TamSx3('DAK_COD')[1]))
Local cCargaAte := Iif(lExistSX1,MV_PAR02,Replicate("Z",(TamSx3('DAK_COD')[1])))
Local cGerCarDe := Iif(lExistSX1,DtoS(MV_PAR03),Space(TamSx3('DAK_DATA')[1]))
Local cGerCarAte:= Iif(lExistSX1,DtoS(MV_PAR04),"")
Local cViagDe   := Iif(lExistSX1,MV_PAR05,Space(TamSx3('DK0_VIAGID')[1]))
Local cViagAte  := Iif(lExistSX1,MV_PAR06,Replicate("Z",(TamSx3('DK0_VIAGID')[1])))
Local cViadDtDe := Iif(lExistSX1,DtoS(MV_PAR07),Space(TamSx3('DK0_DATINT')[1]))
Local cViadDtAte:= Iif(lExistSX1,DtoS(MV_PAR08),"")
Local nSitCarga := Iif(lExistSX1,MV_PAR09,5) //1-Carga Não Gerada;2-Carga Gerada;3-Carga Faturada;4-Carga Monitorada;5-Todas as Situações
Local nSitViagem:= Iif(lExistSX1,MV_PAR10,5) //1-Viagem Não Gerada;2-Viagem Aguardando Liberação;3-Viagem Reprogramada ou Cancelada;5-Todas as Situações
Local lExistDK5 := TableInDic('DK5')

	OsLogCPL("OMSXCPL7 -> QryTemp -> Inicio do metodo. ","INFO")

	If nSitViagem != 5 .And. nSitViagem != 1
		If nSitViagem == 2
			cStatusVg := " AND DK0.DK0_SITINT IN ('1','0')"
		ElseIf nSitViagem == 3
			cStatusVg := " AND DK0.DK0_SITINT = '2'"
		ElseIf nSitViagem == 4
			cStatusVg := " AND DK0.DK0_SITINT IN ('4','5')"
		EndIf
	EndIf
	//Viagens sem carga
	If nSitViagem != 1 .And. (nSitCarga == 1 .Or. nSitCarga == 5)
		cQuery += " SELECT ' ' AS TMP_MARK,"
		cQuery +=        " '1' AS TMP_SITCAR,"
		cQuery +=        " DK0.DK0_SITINT AS TMP_SITVIG,"
		cQuery +=        " DK0.DK0_VIAGID AS TMP_VIAGID,"
		cQuery +=        " DK0.DK0_REGID AS TMP_REGID,"
		cQuery +=        " ' ' AS TMP_CARGA,"
		cQuery +=        " ' ' AS TMP_SEQCAR,"
		cQuery +=        " DK0.DK0_TRANSP AS TMP_TRANSP,"
		cQuery +=        " DK0.DK0_TIPVEI AS TMP_TIPVEI,"
		cQuery +=        " DK0.DK0_PLACA AS TMP_PLACA,"
		cQuery +=        " DK0.DK0_DATINT AS TMP_DATINT,"
		cQuery +=        " DK0.DK0_HORINT AS TMP_HORINT,"
		cQuery +=        " ' ' AS TMP_DATACG,"
		cQuery +=        " ' ' AS TMP_HORACG,"
		cQuery +=        " DK0.R_E_C_N_O_ TMP_RECDK0,"
		cQuery +=        " 0 TMP_RECDAK"
		cQuery +=   " FROM "+RetSqlName('DK0')+" DK0"
		cQuery +=  " WHERE DK0.DK0_FILIAL = '"+xFilial('DK0')+"'"
		cQuery +=    " AND DK0.DK0_VIAGID >= '"+cViagDe+"'"
		If !Empty(cViagAte)
			cQuery +=    " AND DK0.DK0_VIAGID <= '"+cViagAte+"'"
		EndIf
		cQuery +=    " AND DK0.DK0_DATINT >= '"+cViadDtDe+"'"
		If !Empty(cViadDtAte)
			cQuery +=    " AND DK0.DK0_DATINT <= '"+cViadDtAte+"'"
		EndIf
		cQuery +=    " AND DK0.DK0_CARGA = ' '"
		If !Empty(cStatusVg)
			cQuery += cStatusVg
		EndIf
		cQuery +=    " AND DK0.D_E_L_E_T_ = ' '"
	EndIf
	
	//Viagem com carga não faturada e não monitorada
	If nSitViagem != 1 .And. (nSitCarga == 2 .Or. nSitCarga == 5)
		If !Empty(cQuery)
			cQuery += " UNION"
		EndIf
		cQuery += " SELECT ' ' AS TMP_MARK,"
		cQuery +=        " '2' AS TMP_SITCAR,"
		cQuery +=        " DK0.DK0_SITINT AS TMP_SITVIG,"
		cQuery +=        " DK0.DK0_VIAGID AS TMP_VIAGID,"
		cQuery +=        " DK0.DK0_REGID AS TMP_REGID,"
		cQuery +=        " DAK.DAK_COD AS TMP_CARGA,"
		cQuery +=        " DAK.DAK_SEQCAR AS TMP_SEQCAR,"
		cQuery +=        " DK0.DK0_TRANSP AS TMP_TRANSP,"
		cQuery +=        " DK0.DK0_TIPVEI AS TMP_TIPVEI,"
		cQuery +=        " DK0.DK0_PLACA AS TMP_PLACA,"
		cQuery +=        " DK0.DK0_DATINT AS TMP_DATINT,"
		cQuery +=        " DK0.DK0_HORINT AS TMP_HORINT,"
		cQuery +=        " DAK.DAK_HORA AS TMP_DATACG,"
		cQuery +=        " DAK.DAK_HORA AS TMP_HORACG,"
		cQuery +=        " DK0.R_E_C_N_O_ TMP_RECDK0,"
		cQuery +=        " DAK.R_E_C_N_O_ TMP_RECDAK"
		cQuery +=   " FROM "+RetSqlName('DAK')+" DAK"
		cQuery +=  " INNER JOIN "+RetSqlName('DK0')+" DK0"
		cQuery +=     " ON DK0.DK0_FILIAL = '"+xFilial('DK0')+"'"
		cQuery +=    " AND DK0.DK0_CARGA = DAK.DAK_COD"
		cQuery +=    " AND DK0.DK0_VIAGID = DAK.DAK_VIAROT"
		cQuery +=    " AND DK0.DK0_DATINT >= '"+cViadDtDe+"'"
		If !Empty(cViadDtAte)
			cQuery +=    " AND DK0.DK0_DATINT <= '"+cViadDtAte+"'"
		EndIf
		If !Empty(cStatusVg)
			cQuery += cStatusVg
		EndIf
		cQuery +=    " AND DK0.D_E_L_E_T_ = ' '" 
		cQuery +=  " WHERE DAK.DAK_FILIAL = '"+xFilial('DAK')+"'"
		cQuery +=    " AND DAK.DAK_COD >= '"+cCargaDe+"'"
		If !Empty(cCargaAte)
			cQuery +=    " AND DAK.DAK_COD <= '"+cCargaAte+"'"
		EndIf
		cQuery +=    " AND DAK.DAK_COD <> ' '"
		cQuery +=    " AND DAK.DAK_DATA >= '"+cGerCarDe+"'"
		If !Empty(cGerCarAte)
			cQuery +=    " AND DAK.DAK_DATA <= '"+cGerCarAte+"'"
		EndIf
		cQuery +=    " AND DAK.DAK_VIAROT >= '"+cViagDe+"'"
		If !Empty(cViagAte)
			cQuery +=    " AND DAK.DAK_VIAROT <= '"+cViagAte+"'"
		EndIf
		cQuery +=    " AND DAK.D_E_L_E_T_ = ' '" 
		cQuery +=    " AND EXISTS ( SELECT 1" 
		cQuery +=                   " FROM "+RetSqlName('SC9')+" SC9"
		cQuery +=                  " WHERE SC9.C9_FILIAL = '"+xFilial('SC9')+"'"
		cQuery +=                    " AND SC9.C9_CARGA = DAK.DAK_COD"
		cQuery +=                    " AND SC9.C9_SEQCAR = DAK.DAK_SEQCAR"
		cQuery +=                    " AND SC9.C9_NFISCAL = ' '"
		cQuery +=                    " AND SC9.D_E_L_E_T_ = ' ')"
		If lExistDK5
			cQuery +=    " AND NOT EXISTS (SELECT 1"
			cQuery +=                      " FROM "+RetSqlName('DK5')+" DK5"
			cQuery +=                     " WHERE DK5.DK5_FILIAL = '"+xFilial('DK5')+"'"
			cQuery +=                       " AND DK5.DK5_CARGA = DAK.DAK_COD"
			cQuery +=                       " AND DK5.DK5_SEQCAR = DAK.DAK_SEQCAR"
			cQuery +=                       " AND DK5.DK5_STATUS IN ('1','3')"
			cQuery +=                       " AND DK5.D_E_L_E_T_ = ' ' )"
		EndIf
	EndIf

	//Cargas faturadas e não monitoradas
	If nSitCarga != 1 .And. (nSitCarga == 3 .Or. nSitCarga == 5)
		If !Empty(cQuery)
			cQuery += " UNION"
		EndIf
		cQuery += " SELECT  ' ' AS TMP_MARK,"
		cQuery +=         " '3' AS TMP_SITCAR,"
		If !lIntCpl .Or. nSitViagem == 1 //Viagem não gerada
			cQuery +=         " ' ' AS TMP_SITVIG,"
			cQuery +=         " ' ' AS TMP_VIAGID,"
			cQuery +=         " ' ' AS TMP_DK0_REGID,"
		Else
			cQuery +=         " CASE WHEN DK0.DK0_SITINT IS NULL THEN ' ' ELSE DK0.DK0_SITINT END TMP_SITVIG,"
			cQuery +=         " CASE WHEN DK0.DK0_VIAGID IS NULL THEN ' ' ELSE DK0.DK0_VIAGID END TMP_VIAGID,"
			cQuery +=         " CASE WHEN DK0.DK0_REGID IS NULL THEN ' ' ELSE DK0.DK0_REGID END TMP_DK0_REGID,"
		EndIf
		cQuery +=         " DAK.DAK_COD AS TMP_CARGA,"
		cQuery +=         " DAK.DAK_SEQCAR AS TMP_SEQCAR,"
		If !lIntCpl .Or. nSitViagem == 1 //Viagem não gerada
			cQuery +=         " ' ' AS TMP_TRANSP,"
			cQuery +=         " ' ' AS TMP_TIPVEI,"
			cQuery +=         " ' ' AS TMP_PLACA,"
			cQuery +=         " ' ' AS TMP_DATINT,"
			cQuery +=         " ' ' AS TMP_HORINT,"
		Else
			cQuery +=         " CASE WHEN DK0.DK0_TRANSP IS NULL THEN ' ' ELSE DK0.DK0_TRANSP END TMP_TRANSP,"
			cQuery +=         " CASE WHEN DK0.DK0_TIPVEI IS NULL THEN ' ' ELSE DK0.DK0_TIPVEI END TMP_TIPVEI,"
			cQuery +=         " CASE WHEN DK0.DK0_PLACA IS NULL THEN ' ' ELSE DK0.DK0_PLACA END TMP_PLACA,"
			cQuery +=         " CASE WHEN DK0.DK0_DATINT IS NULL THEN ' ' ELSE DK0.DK0_DATINT END TMP_DATINT,"
			cQuery +=         " CASE WHEN DK0.DK0_HORINT IS NULL THEN ' ' ELSE DK0.DK0_HORINT END TMP_HORINT,"		
		EndIf
		cQuery +=         " DAK.DAK_HORA AS TMP_DATACG,"
		cQuery +=         " DAK.DAK_HORA AS TMP_HORACG,"
		If !lIntCpl .Or. nSitViagem == 1
			cQuery +=         " 0 AS TMP_RECDK0,"
		Else
			cQuery +=         " CASE WHEN DK0.R_E_C_N_O_ IS NULL THEN 0 ELSE DK0.R_E_C_N_O_ END TMP_RECDK0,"
		EndIf
		cQuery +=         " DAK.R_E_C_N_O_ TMP_RECDAK"
		cQuery +=    " FROM "+RetSqlName('DAK')+" DAK"
		If lIntCpl .And. nSitViagem != 1 //Viagem não gerada
			cQuery +=    " INNER JOIN "+RetSqlName('DK0')+" DK0"
			cQuery +=      " ON DK0.DK0_FILIAL = '"+xFilial('DK0')+"'"
			cQuery +=     " AND DK0.DK0_CARGA = DAK.DAK_COD"
			cQuery +=     " AND DK0.DK0_VIAGID = DAK.DAK_VIAROT"
			cQuery +=     " AND DK0.DK0_DATINT >= '"+cViadDtDe+"'"
			If !Empty(cViadDtAte)
				cQuery +=     " AND DK0.DK0_DATINT <= '"+cViadDtAte+"'"
			EndIf
			If !Empty(cStatusVg)
				cQuery += cStatusVg
			EndIf
			cQuery +=     " AND DK0.D_E_L_E_T_ =  ' '"
		EndIf
		cQuery +=   " WHERE DAK.DAK_FILIAL = '"+xFilial('DAK')+"'"
		cQuery +=     " AND DAK.DAK_COD >= '"+cCargaDe+"'"
		If !Empty(cCargaAte)
			cQuery +=     " AND DAK.DAK_COD <= '"+cCargaAte+"'"
		EndIf
		cQuery +=     " AND DAK.DAK_DATA >= '"+cGerCarDe+"'"
		If !Empty(cGerCarAte)
			cQuery +=     " AND DAK.DAK_DATA <= '"+cGerCarAte+"'"
		EndIf
		If nSitViagem == 1 //Viagem não gerada
			cQuery +=     " AND DAK.DAK_VIAROT = ' '"
		Else
			cQuery +=     " AND DAK.DAK_VIAROT >= '"+cViagDe+"'"
			cQuery +=     " AND DAK.DAK_VIAROT <= '"+cViagAte+"'"
		EndIf
		cQuery +=     " AND DAK.D_E_L_E_T_ = ' '"
		cQuery +=     " AND NOT EXISTS (SELECT 1" 
		cQuery +=                       " FROM "+RetSqlName('SC9')+" SC9"
		cQuery +=                      " WHERE SC9.C9_FILIAL = '"+xFilial('SC9')+"'"
		cQuery +=                        " AND SC9.C9_CARGA = DAK.DAK_COD"
		cQuery +=                        " AND SC9.C9_SEQCAR = DAK.DAK_SEQCAR"
		cQuery +=                        " AND SC9.C9_NFISCAL = ' '"
		cQuery +=                        " AND SC9.D_E_L_E_T_ = ' ')"
		If lExistDK5
			cQuery +=     " AND NOT EXISTS ( SELECT 1"
			cQuery +=                       " FROM "+RetSqlName('DK5')+" DK5"
			cQuery +=                      " WHERE DK5.DK5_FILIAL = '"+xFilial('DK5')+"'"
			cQuery +=                        " AND DK5.DK5_CARGA = DAK.DAK_COD"
			cQuery +=                        " AND DK5.DK5_SEQCAR = DAK.DAK_SEQCAR"
			cQuery +=                        " AND DK5.DK5_STATUS IN ('1','3')"
			cQuery +=                        " AND DK5.D_E_L_E_T_ = ' ' )"
		EndIf
	EndIf
	
	//Cargas Monitoradas ou Finalizadas
	If lExistDK5 .And. nSitCarga != 1 .And. (nSitCarga == 4 .Or. nSitCarga == 5)
		If !Empty(cQuery)
			cQuery += " UNION"
		EndIf
		cQuery += " SELECT ' ' AS TMP_MARK,"
		cQuery += " CASE WHEN DAK.DAK_ACECAR = '1' THEN '5' ELSE '4' END TMP_SITCAR,"
		
		If !lIntCpl .Or. nSitViagem == 1 //Viagem não gerada
			cQuery +=        " ' ' AS TMP_SITVIG,"
			cQuery +=        " ' ' AS TMP_VIAGID,"
			cQuery +=        " ' ' AS TMP_DK0_REGID,"
		Else
			cQuery +=        " CASE WHEN DK0.DK0_SITINT IS NULL THEN ' ' ELSE DK0.DK0_SITINT END TMP_SITVIG,"
			cQuery +=        " CASE WHEN DK0.DK0_VIAGID IS NULL THEN ' ' ELSE DK0.DK0_VIAGID END TMP_VIAGID,"
			cQuery +=        " CASE WHEN DK0.DK0_REGID IS NULL THEN ' ' ELSE DK0.DK0_REGID END TMP_DK0_REGID,"
		EndIf
		cQuery +=        " DAK.DAK_COD AS TMP_CARGA,"
		cQuery +=        " DAK.DAK_SEQCAR AS TMP_SEQCAR,"
		If !lIntCpl .Or. nSitViagem == 1 //Viagem não gerada
			cQuery +=        " ' ' AS TMP_TRANSP,"
			cQuery +=        " ' ' AS TMP_TIPVEI,"
			cQuery +=        " ' ' AS TMP_PLACA,"
			cQuery +=        " ' ' AS TMP_DATINT,"
			cQuery +=        " ' ' AS TMP_HORINT,"
		Else
			cQuery +=        " CASE WHEN DK0.DK0_TRANSP IS NULL THEN ' ' ELSE DK0.DK0_TRANSP END TMP_TRANSP,"
			cQuery +=        " CASE WHEN DK0.DK0_TIPVEI IS NULL THEN ' ' ELSE DK0.DK0_TIPVEI END TMP_TIPVEI,"
			cQuery +=        " CASE WHEN DK0.DK0_PLACA IS NULL THEN ' ' ELSE DK0.DK0_PLACA END TMP_PLACA,"
			cQuery +=        " CASE WHEN DK0.DK0_DATINT IS NULL THEN ' ' ELSE DK0.DK0_DATINT END TMP_DATINT,"
			cQuery +=        " CASE WHEN DK0.DK0_HORINT IS NULL THEN ' ' ELSE DK0.DK0_HORINT END TMP_HORINT,"		
		EndIf
		cQuery +=        " DAK.DAK_HORA AS TMP_DATACG,"
		cQuery +=        " DAK.DAK_HORA AS TMP_HORACG,"
		If !lIntCpl .Or. nSitViagem == 1
			cQuery +=         " 0 AS TMP_RECDK0,"
		Else
			cQuery +=         " CASE WHEN DK0.R_E_C_N_O_ IS NULL THEN 0 ELSE DK0.R_E_C_N_O_ END TMP_RECDK0,"
		EndIf
		cQuery +=        " DAK.R_E_C_N_O_ TMP_RECDAK"
		cQuery +=   " FROM "+RetSqlName('DAK')+" DAK"
		If lIntCpl .And. nSitViagem != 1
			cQuery +=  " INNER JOIN "+RetSqlName('DK0')+" DK0"
			cQuery +=     " ON DK0.DK0_FILIAL = '"+xFilial('DK0')+"'"
			cQuery +=    " AND DK0.DK0_CARGA = DAK.DAK_COD"
			cQuery +=    " AND DK0.DK0_VIAGID = DAK.DAK_VIAROT"
			cQuery +=    " AND DK0.DK0_DATINT >= '"+cViadDtDe+"'"
			If !Empty(cViadDtAte)
				cQuery +=    " AND DK0.DK0_DATINT <= '"+cViadDtAte+"'"
			EndIf
			If !Empty(cStatusVg)
				cQuery += cStatusVg
			EndIf
			cQuery +=    " AND DK0.D_E_L_E_T_ =  ' '"
		EndIf
		cQuery +=  " WHERE DAK.DAK_FILIAL = '"+xFilial('DAK')+"'"
		cQuery +=    " AND DAK.DAK_COD  >= '"+cCargaDe+"'"
		If !Empty(cCargaAte)
			cQuery +=    " AND DAK.DAK_COD  <= '"+cCargaAte+"'"
		EndIf
		cQuery +=    " AND DAK.DAK_DATA >= '"+cGerCarDe+"'"
		If !Empty(cGerCarAte)
			cQuery +=    " AND DAK.DAK_DATA <= '"+cGerCarAte+"'"
		EndIf
		If nSitViagem == 1 //Viagem não gerada
			cQuery +=     " AND DAK.DAK_VIAROT = ' '"
		Else
			cQuery +=     " AND DAK.DAK_VIAROT >= '"+cViagDe+"'"
			cQuery +=     " AND DAK.DAK_VIAROT <= '"+cViagAte+"'"
		EndIf
		cQuery +=    " AND DAK.D_E_L_E_T_ = ' '"
		cQuery +=    " AND EXISTS ( SELECT 1"
		cQuery +=                   " FROM "+RetSqlName('DK5')+" DK5"
		cQuery +=                  " WHERE DK5.DK5_FILIAL = '"+xFilial('DK5')+"'"
		cQuery +=                    " AND DK5.DK5_CARGA = DAK.DAK_COD"
		cQuery +=                    " AND DK5.DK5_SEQCAR = DAK.DAK_SEQCAR"
		cQuery +=                    " AND DK5.DK5_STATUS IN ('1','3')"
		cQuery +=                    " AND DK5.D_E_L_E_T_ = ' ' )"
	EndIf
	If !Empty(cQuery)
		cQuery += " ORDER BY TMP_CARGA"
	EndIf
	
	OsLogCPL("OMSXCPL7 -> QryTemp -> Final do metodo. Conteudo da variavel cQuery: " + cValToChar(cQuery),"INFO")
Return cQuery


/*/{Protheus.doc} OMSXCPL7L
Esta rotina executa algumas validaçoes tais como OMSXDOCS que verifica se existe documento de saída
e se tudo tiver OK a função OMSXCPLENVIA é chamada para efetuar a liberação da viagem
@author Mohamed S B Djalo
@since 22/11/2016
@version version
@param cRegId, cViagId
@return return, return_description
/*/
Function OMSXCPL7L()
Local aAreaAnt  := DK0->(GetArea())
Local lRet      := .T.
	If IsBlind()
		OsLogCPL("OMSXCPL7 -> OMSXCPL7L -> "+Replicate("-", 100),"INFO")
		OsLogCPL("OMSXCPL7 -> OMSXCPL7L -> INICIO DE LIBERACAO DE VIAGEM - MODO AUTOMATICO.","INFO")
		
		If OMSXCPLENVIA("DK0",4)
			Reclock("DK0",.F.)
			DK0->DK0_SITINT  := "2"
			DK0->( MsUnLock() )
		Else
			RecLock("DK0",.F.)
			DK0->DK0_SITINT := "3"
			DK0->( MsUnLock() )
			lRet := .F.
		EndIf
	Else
		OsLogCPL("OMSXCPL7 -> OMSXCPL7L -> Inicio de liberacao de viagem - modo manual.","INFO")
		Processa({||lRet := ProcLibVg()}, STR0044, STR0045) // Liberando Viagens // Liberando viagens para o Cockpit Logístico. 
		RefreshBrw()
	EndIf
	RestArea(aAreaAnt)
Return lRet

/*/{Protheus.doc} ProcLibVg
Processa a liberação da viagem
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function ProcLibVg()
Local lRet      := .T.
Local lRegistros:= .F.
Local cQuery    := ""
Local cAliasDK0 := ""
Local cViagens  := ""
Local cSelect	:= ""
Local cSelectCnt:= "" 
Local nTot  	:= ""


	OsLogCPL("OMSXCPL7 -> ProcLibVg -> Entrada na funcao ProcLibVg.","INFO")
	cSelect := " SELECT TMP.TMP_RECDK0,"
	cSelect +=        " TMP_VIAGID"

	cSelectCnt := "SELECT COUNT(*) QTDTOTAL"

	cQuery +=   " FROM  "+oTempTab:GetRealName()+" TMP"
	cQuery +=  " WHERE TMP.TMP_MARK = '"+oBrowse:Mark()+"'"
	cQuery +=    " AND TMP_SITVIG IN ('1','3')"
	cQuery +=    " AND TMP.D_E_L_E_T_ = ' '"

	cSelectCnt := cSelectCnt + cQuery
	cAliasDK0 := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSelectCnt), cAliasDK0, .F., .T.)
	nTot := (cAliasDK0)->QTDTOTAL
	(cAliasDK0)->(dbCloseArea())

	cSelect := cSelect + cQuery
	OsLogCPL("OMSXCPL7 -> ProcLibVg -> Conteúdo de cSelect: " + AllTrim(cSelect),"INFO")

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSelect), cAliasDK0, .F., .T.)	

	ProcRegua(nTot)

	While (cAliasDK0)->(!EoF())
		OsLogCPL("OMSXCPL7 -> ProcLibVg -> Inicio do cursor cAliasDK0.","INFO")
		If !(cAliasDK0)->(TMP_RECDK0) == 0
			lRegistros := .T.
			DK0->(DbGoTo((cAliasDK0)->TMP_RECDK0))
			IncProc(STR0046+(cAliasDK0)->TMP_VIAGID) //Processando Viagem 
			
			OsLogCPL("OMSXCPL7 -> ProcLibVg ->  Tentativa de liberar a viagem: " + DK0->DK0_VIAGID,"INFO")

			If OMSXCPLENVIA("DK0",4)
				Reclock("DK0",.F.)
				DK0->DK0_SITINT := "2"
				DK0->DK0_MARK   := ""
				DK0->( MsUnLock() )
			Else
				cViagens += RTrim(DK0->DK0_VIAGID) + " " + CRLF
			EndIf

			OsLogCPL("OMSXCPL7 -> ProcLibVg -> Fim tentativa.","INFO") 
		EndIf
		(cAliasDK0)->(DbSkip())
	EndDo
	(cAliasDK0)->(DbCloseArea())
	
	If !Empty(cViagens)
		MsgAlert(STR0001 + CRLF + cViagens) // "Não foi possível liberar a(s) seguinte(s) viagen(s)! "
		OsLogCPL("OMSXCPL7 -> ProcLibVg -> Mensagem 1: " + cValToChar(STR0001 + cViagens),"WARN")
	ElseIf lRegistros .And. lRet
		OmsMessage(STR0047) // "Viagen(s) gerada(s) com sucesso!"
		OsLogCPL("OMSXCPL7 -> ProcLibVg -> Mensagem 2: " + cValToChar(STR0047),"INFO")
	Else
		MsgAlert(STR0010) // "Nenhum registro válido selecionado para a liberação de viagem!"
		OsLogCPL("OMSXCPL7 -> ProcLibVg -> Mensagem 3: " + cValToChar(STR0010),"WARN")
		lRet := .F.
	EndIf
Return lRet
/*/{Protheus.doc} OMSXCPL7G
Essa rotina tem como objetivo chamar a geração da carga
@author amanda.vieira
@since 06/04/2018
@version version 2.0
@obs Quando a função for chamada por meio do JOB, é necessário que a tabela DK0 esteja posicionada
/*/
Function OMSXCPL7G()
Local lRet      := .T.
Local aAreaAnt  := DK0->(GetArea())

	OsLogCPL("OMSXCPL7 -> OMSXCPL7G -> "+Replicate("-", 100),"INFO")
	OsLogCPL("OMSXCPL7 -> OMSXCPL7G -> INICIO GERAR CARGA. IsBlind(): " + cValToChar(IsBlind()),"INFO")

	If IsBlind() // Geração via JOB
		If Dk0->DK0_SITINT <> '5' .AND. Dk0->DK0_SITINT <> '4'
			GeraCarga()
		EndIf
	Else // Geração via tela	
		Processa({||lRet := ProcGerCar()}, STR0048, STR0049) // Gerando Cargas //Gerando cargas para as viagens.
		RefreshBrw()
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*/{Protheus.doc} ProcGerCar
Processa a geração da viagem
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function ProcGerCar()
Local aErros    := {}
Local aMsg      := {}
Local lRet      := .T.
Local lRegistros:= .F.
Local cQuery    := ""
Local cAliasDK0 := ""
Local nI        := 0
Local cSelect 	:= ""
Local cSelectCnt:= ""
Local nTot		:= 0

	OsLogCPL("OMSXCPL7 -> ProcGerCar -> Inicio do Metodo.","INFO")

	cSelect := " SELECT TMP.TMP_RECDK0,"
	cSelect +=        " TMP.TMP_VIAGID"

	cSelectCnt := "SELECT COUNT(*) QTDTOTAL"

	cQuery +=   " FROM  "+oTempTab:GetRealName()+" TMP"
	cQuery +=  " WHERE TMP.TMP_MARK = '"+oBrowse:Mark()+"'"
	cQuery +=    " AND TMP.TMP_CARGA = ' '"
	cQuery +=    " AND TMP.D_E_L_E_T_ = ' '"

	cSelectCnt := cSelectCnt + cQuery
	cAliasDK0 := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSelectCnt), cAliasDK0, .F., .T.)
	nTot := (cAliasDK0) -> QTDTOTAL
	(cAliasDK0)->(dbCloseArea())

	cSelect := cSelect + cQuery
	OsLogCPL("OMSXCPL7 -> ProcGerCar -> Conteudo da variavel cSelect: " + AllTrim(cSelect),"INFO")

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSelect), cAliasDK0, .F., .T.)

	ProcRegua(nTot)
	
	While (cAliasDK0)->(!EoF())
		If !((cAliasDK0)->TMP_RECDK0 == 0)
			lRegistros := .T.
			IncProc(STR0050+(cAliasDK0)->TMP_VIAGID) //Processando Carga Para a Viagem 
			DK0->(DbGoTo((cAliasDK0)->TMP_RECDK0))
			If Dk0->DK0_SITINT <> '5' .AND. Dk0->DK0_SITINT <> '4'
				GeraCarga(@aErros)
			Else	
				If Dk0->DK0_SITINT == '5' 
					Aadd(aErros,OmsFmtMsg(STR0074,{{"[VAR01]",DK0->DK0_VIAGID}})) //"Carga não gerada para a viagem [VAR01]. A mesma encontra-se Cancelada."
				Else 
					If Dk0->DK0_SITINT == '4'	
						Aadd(aErros,OmsFmtMsg(STR0075,{{"[VAR01]",DK0->DK0_VIAGID}})) //"Carga não gerada para a viagem  [VAR01]. A mesma encontra-se Reprogramada."
					EndIf
				EndIf 
			EndIf		
		EndIf
		(cAliasDK0)->(DbSkip())
	EndDo
	(cAliasDK0)->(DbCloseArea())
	
	If !Empty(aErros)
		Aadd(aMsg,STR0024) //Resumo das divergências ao gerar a carga para as viagens selecionadas:
		For nI := 1 To Len(aErros)
			Aadd(aMsg,aErros[nI])
		Next nI
		OmsShowWng(aMsg)
		OsLogCPL("OMSXCPL7 -> ProcGerCar -> Mensagem 1: " + VarInfo("Mensagens: ",aMsg),"WARN")
	ElseIf lRegistros .And. lRet
		OmsMessage(STR0028) // "Carga(s) gerada(s) com sucesso!"
		OsLogCPL("OMSXCPL7 -> ProcGerCar -> Mensagem 2: " + cValToChar(STR0028),"WARN")
	Else
		MSGAlert(STR0011) // "Nenhum registro válido selecionado para a geração de carga!"
		OsLogCPL("OMSXCPL7 -> ProcGerCar -> Mensagem 3: " + cValToChar(STR0011),"WARN")
		lRet := .F.
	EndIf
Return lRet
/*/{Protheus.doc} OMSXCPLMN
Realiza o envio das cargas para o monitoramento
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Function OMSXCPLMN()
Local lRet := .T.
	Processa({||lRet := ProcEnvMon()}, STR0051, STR0052) // Enviando Cargas //Enviando cargas para o monitoramento no Cockpit Logístico.
	RefreshBrw()
Return lRet
/*/{Protheus.doc} OMSXCPLMN
Processa o envio para o monitoramento
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function ProcEnvMon()
Local aCabecalho:= {}
Local aFalhas   := {}
Local aEnviados := {}
Local aResumo   := {}
Local lRet      := .T.
Local lIsBlind   := IsBlind()
Local cAliasDAK := GetNextAlias()
Local nTotalReg := 0
Local nQtdFalhas:= 0
Local oMonitoramento := OMSBCCMonitoramentoCPL():New()
Local cSelect	:= ""
Local cSelectCnt:= ""
Local nTot		:= ""
Local cQuery	:= ""

	OsLogCPL("OMSXCPL7 -> ProcEnvMon -> "+Replicate("-", 100),"INFO")
	OsLogCPL("OMSXCPL7 -> ProcEnvMon -> INICIO: PROCESSA O ENVIO PARA O MONITORAMENTO. lIsBlind: " + Iif(lIsBlind,"TRUE","FALSE"),"INFO")

	cSelect := " SELECT TMP.TMP_RECDAK,"
	cSelect +=        " TMP.TMP_CARGA,"
	cSelect +=        " TMP.TMP_SEQCAR,"
	cSelect +=        " TMP.TMP_VIAGID"

	cSelectCnt := "SELECT COUNT(*) QTDTOTAL"

	cQuery +=   " FROM  "+oTempTab:GetRealName()+" TMP"
	cQuery +=  " WHERE TMP.D_E_L_E_T_ = ' '"
	If !lIsBlind
		cQuery +=  " AND TMP.TMP_MARK = '"+oBrowse:Mark()+"'"
	EndIf
	cQuery +=    " AND TMP.D_E_L_E_T_ = ' '"

	cSelectCnt := cSelectCnt + cQuery
	cAliasDAK := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSelectCnt), cAliasDAK, .F., .T.)
	nTot := (cAliasDAK)->QTDTOTAL
	(cAliasDAK)->(dbCloseArea())

	cSelect := cSelect + cQuery
	OsLogCPL("OMSXCPL7 -> ProcEnvMon -> Conteudo da variavel cSelect: " + AllTrim(cSelect),"INFO")

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSelect), cAliasDAK, .F., .T.)	

	ProcRegua(nTot)
	
	While (cAliasDAK)->(!EoF())
		If !((cAliasDAK)->TMP_RECDAK == 0)
			nTotalReg += 1
			If !lIsBlind
				IncProc(STR0053+(cAliasDAK)->TMP_SEQCAR) //Processando Carga 
			EndIf
			oMonitoramento:setCarga((cAliasDAK)->TMP_CARGA)
			oMonitoramento:setSeqCarga((cAliasDAK)->TMP_SEQCAR)
			oMonitoramento:setIdViagem((cAliasDAK)->TMP_VIAGID)
			oMonitoramento:postAquisicaoMonitoravel()
			If !oMonitoramento:getSucesso()
				nQtdFalhas += 1
				If Empty(aFalhas)
					aAdd(aFalhas,STR0054) //Registros Não Enviados:
				EndIf
				aAdd(aFalhas,OmsFmtMsg(STR0055+CRLF+IIF(!Empty(oMonitoramento:getMensagemErro()),oMonitoramento:getMensagemErro(),""),{{"[VAR01]",(cAliasDAK)->TMP_CARGA},{"[VAR02]",(cAliasDAK)->TMP_SEQCAR}})) // Carga [VAR01] | Sequência [VAR02]. // Gravado registro de falha (DJW). Motivo:
				aAdd(aFalhas,Replicate("-",166))
			Else
				If Empty(aEnviados)
					aAdd(aEnviados,STR0056) //Registros Enviados:
				EndIf
				aAdd(aEnviados,OmsFmtMsg(STR0055,{{"[VAR01]",(cAliasDAK)->TMP_CARGA},{"[VAR02]",(cAliasDAK)->TMP_SEQCAR}})) //Carga [VAR01] | Sequência [VAR02]
			EndIf
		EndIf
		(cAliasDAK)->(DbSkip())
	EndDo
	(cAliasDAK)->(DbCloseArea())
	
	If nTotalReg == 0
		If !lIsBlind
			MSGAlert(STR0057) // Nenhum registro válido selecionado para envio para o monitoramento
			OsLogCPL("OMSXCPL7 -> ProcEnvMon -> Conteudo da Mensagem: " + cValToChar(STR0057),"INFO")
		EndIf
		lRet := .F.
	Else
		aAdd(aCabecalho,STR0058+CRLF) // Resumo do envio da(s) cargas para o monitoramento no Cockpit Logístico.
		
		If nQtdFalhas > 0
			aAdd(aCabecalho,STR0076 + cValToChar(nQtdFalhas)+CRLF) //"Registros que apresentaram falha no envio: "
		EndIf
		If (nTotalReg - nQtdFalhas) > 0
			aAdd(aCabecalho,STR0077 + cValToChar((nTotalReg - nQtdFalhas))+CRLF) //"Registros que apresentaram sucesso no envio: "
		EndIf
		aAdd(aCabecalho,STR0078 + cValToChar(nTotalReg)+CRLF) //"Total de registros processados: "
		
		//Monta array do resumo
		aEval(aCabecalho,{|x|Aadd(aResumo,x)})
		aEval(aFalhas,{|x|Aadd(aResumo,x)})
		aEval(aEnviados,{|x|Aadd(aResumo,x)})
		If !lIsBlind
			//Apresenta resumo do envio
			OmsShowWng(aResumo)
		EndIf
	Endif
Return lRet
/*/{Protheus.doc} OMSCPL7VC
Visualização da carga
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Function OMSCPL7VC()
Local lRet := .T.
	If !((cAliasTMP)->TMP_RECDAK == 0)
		Private bFiltraBrw := {|| Nil}
		Private cCadastro  := OemtoAnsi(STR0060) //Visualização Carga
		Private n          := 1
		Private aArrayCli  := {}
		Private nIndice    := 5
		Private aRotAuto   := {}
		Private aAutoItens := {}
		Private xArrCarga  := {}
		Private aVisErr    := {}
		Os200Visual("DAK",(cAliasTMP)->TMP_RECDAK) // Visualização Carga
	Else
		MsgAlert(STR0061) // O registro não possuí carga para ser visualizada!
	EndIf
Return lRet

/*/{Protheus.doc} OMSCPL7VC
Visualização da viagem
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Function OMSCPL7VV()
Local lRet := .T.
	If !((cAliasTMP)->TMP_RECDK0 == 0)
		DK0->(DbGoTo((cAliasTMP)->TMP_RECDK0))
		FWExecView(STR0062,"OMSXCPL7", MODEL_OPERATION_VIEW ,, { || .T. } ,, ) // Visualização Viagem
	Else
		MsgAlert(STR0063) // O registro não possuí viagem para ser visualizada!
	EndIf
Return lRet

/*/{Protheus.doc} OMSCPL7CL
Classificação e Tipo de Operação da viagem
@author amanda.vieira
@since 25/03/2020
@version 1.0
/*/
Function OMSCPL7CL()
	Local lRet 		:= .T.
	Local oDlg   	:= Nil
	Local oTpOp  	:= Nil
	Local oClFr  	:= Nil
	Local cDAKTpOp	:= cOperaGFE	//Tipo de Operação de Frete no GFE
	Local cDAKClFr	:= cClassGFE	//Classificação de Frete no GFE
	Local lDAKTpOp  := .F.

	dbSelectArea("DAK")
	DAK->(DbSetOrder(1))
	lDAKTpOp := (DAK->(FieldPos("DAK_CDTPOP")) > 0 .AND. DAK->(FieldPos("DAK_CDCLFR")) > 0)

	If lDAKTpOp
		DEFINE FONT oBold  NAME "Arial" SIZE 0, -12  BOLD

		DEFINE MSDIALOG oDlg TITLE OemtoAnsi("Tipo Oper/ Class. Frete") FROM C(221),C(250) TO C(370),C(620) PIXEL // "Tipo Oper/ Class. Frete"

		@ C(033),C(006) Say ("Tipo Operação") + ":"    Size C(055),C(008) COLOR CLR_BLUE  PIXEL OF oDlg FONT oBold //"Tipo Operação"
		@ C(031),C(045) MsGet oTpOp Var cDAKTpOp Valid ( Empty(cDAKTpOp) .Or. CPL7VdOp(cDAKTpOp) ) F3 "GV4" Size C(040),C(009) COLOR CLR_BLACK OF oDlg PIXEL HASBUTTON
		@ C(043),C(006) Say ("Class. Frete") +  ":"    Size C(055),C(008) COLOR CLR_BLUE  PIXEL OF oDlg FONT oBold // Class. Frete
		@ C(045),C(045) MsGet oClFr Var cDAKClFr Valid ( Empty(cDAKClFr) .Or. CPL7VdClF(cDAKClFr) ) F3 "GUB" Size C(040),C(009) COLOR CLR_BLACK OF oDlg PIXEL HASBUTTON

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||oDlg:End()}, {|| oDlg:End() })
		
		cClassGFE := AvKey(cDAKClFr	,"DAK_CDCLFR") //Classificação de Frete no GFE
		cOperaGFE := AvKey(cDAKTpOp	,"DAK_CDTPOP") //Tipo de Operação de Frete no GFE
	Else
		Help(NIL, NIL, "OMSCPL7CL", NIL, "Opção não disponivel" , 2, 0, NIL, NIL, NIL, NIL, NIL,{"Verifique o criação dos campos: DAK_CDTPOP e/ou DAK_CDCLFR"})
	EndIF

Return lRet

//-----------------------------------------------------
/*  Funcao CPL7VdOp - Valida se Tipo de Operação existe na tela de selecao
	@author amanda.vieira
	@since 25/03/2020
*/
//------------------------------------------------------
Static Function CPL7VdOp(cTmpTpOP)
	Local aAreaGV4 := GV4->(GetArea())
	Local lRet     := .T.
	
	GV4->(DbSetOrder(1))
	If !GV4->(MsSeek(xFilial("GV4")+cTmpTpOP))
		IF (!IsBlind())
			Help(" ",1,"REGNOIS")//Mensagem de registro nao relacionado
		EndIF
		lRet := .F.
	EndIf
	RestArea(aAreaGV4)
	
Return lRet
//-----------------------------------------------------
/*  Funcao CPL7VdClF - Valida se Classificação de Frete existe na tela de selecao
	@author amanda.vieira
	@since 25/03/2020
*/
//------------------------------------------------------
Static Function CPL7VdClF(cTmpClFr)
	Local aAreaGUB := GUB->(GetArea())
	Local lRet     := .T.

	GUB->(DbSetOrder(1))
	If !GUB->(MsSeek(xFilial("GUB")+cTmpClFr))
		IF (!IsBlind())
			Help(" ",1,"REGNOIS")//Mensagem de registro nao relacionado
		EndIF
		lRet := .F.
	EndIf
	RestArea(aAreaGUB)
	
Return lRet

/*/{Protheus.doc} GeraCarga
Essa rotina tem como objetivo gerar a carga via execução automática da rotina OMSA200
@author amanda.vieira
@since 06/04/2018
@version version 1.0
@obs Necessário que a tabela DK0 e DAI esteja posicionada
/*/
Static Function GeraCarga(aErros)
Local lRet       := .T.
Local lAvalLibPed:= .F.
Local lTransp    := DAK->( ColumnPos( "DAK_TRANSP" ) ) > 0
Local lCdTpOp    := DAK->( ColumnPos( "DAK_CDTPOP" ) ) > 0
Local lCdClFr    := DAK->( ColumnPos( "DAK_CDCLFR" ) ) > 0
Local lSeqEnt    := DK1->( ColumnPos( "DK1_SEQENT" ) ) > 0
Local cQuery     := ""
Local cAliasQry  := ""
Local cAliasPed  := ""
Local cAliasVeic := ""
Local cCliAnt    := ""
Local cLojaAnt   := ""
Local cFilCarga  := ""
Local cCodCarga  := ""
Local cTipOper   := ""
Local cClasFrete := ""
Local cCaminhao  := ""
Local cMotorist  := ""
Local cAjuda1    := ""
Local cAjuda2    := ""
Local cAjuda3    := ""
Local cAliasSC9  := ""
Local cAliasSld  := ""
Local cSeqEnt    := ""
Local cSeqEntAnt := ""
Local nSeqInc    := SuperGetMV("MV_OMSENTR" ,.F.,5)
Local nSequen    := 0
Local nDAIpeso   := 0
Local nDAIvolume := 0
Local nDAKpeso   := 0
Local nDAKvolume := 0
Local nDAKvalor  := 0
Local nPtEntrega := 0
Local nSaldoCarg := 0
Local cRegId     := DK0->DK0_REGID
Local cViagId    := DK0->DK0_VIAGID
Local cTransp    := Alltrim(DK0->DK0_TRANSP)
Local cPlaca     := DK0->DK0_PLACA
Local aTamSX3    := {}
Local aTime      := {}
Local lColPeso   := DK1->( ColumnPos( "DK1_PESO" ) ) > 0
Local lColTime   := DK1->( ColumnPos( "DK1_CHEGAD" ) ) > 0
Local lDK3QuebId := DK3->( ColumnPos( "DK3_QUEBID" ) ) > 0
Local lColQuebOr := DK1->( ColumnPos( "DK1_QUEORI" ) ) > 0
Local lColSequen := DK1->( ColumnPos( "DK1_SEQUEN" ) ) > 0
Local lLibPed    := SuperGetMv("MV_CPLPELB",.F.,"2") == "1" //Indica se permite quantidades não liberadas
Local nTipoOper  := OsVlEntCom()
Local cErro      := ""
Local lOMSCPL7D  := ExistBlock("OMSCPL7D") //Ponto de entrada para validar se a viagem pode gerar uma carga
Local lOMSCPL7E  := ExistBlock("OMSCPL7E") //Ponto de entrada para ajustar Tipo de Operação de Integração GFE
Local lOMSCPL7F  := ExistBlock("OMSCPL7F") //Ponto de entrada para ajustar Classificação de Operação de Integração GFE
Local cOMSGFETP	 := "" //Variavel para guardar o tipo de operação de integração do GFE no ponto de entrada
Local cOMSGFECL  := "" //Variavel para guardar o Classificação de operação de integração do GFE no ponto de entrada
Local lOMSCPL7G  := ExistBlock("OMSCPL7G") //Ponto de entrada para gravar/alterar campos complementares na carga/viagem antes de integrar GFE
Local lDK0Veic2  := DK0->( ColumnPos( "DK0_VEIC2" ) ) > 0
Local aRetornoPE := {}
Local lDaiRedesp := DAI->( ColumnPos( "DAI_REDESP" ) ) > 0
Local lColDisDK0 := DK0->( ColumnPos( "DK0_DISROT" ) ) > 0
Local lColDisDAK := DAK->( ColumnPos( "DAK_DISROT" ) ) > 0
Local nTotDist   := 0
Default aErros := {}

	OsLogCPL("OMSXCPL7 -> GeraCarga -> Inicio do Metodo.","INFO")

	//Define código da transportadora
	If lTransp .And. !Empty(cTransp)
		//Ajusta string da transportadora para remover a referência da empresa e filial
		cTransp := SubStr(cTransp,1,Len(cTransp)-Len(RTrim(OMSXGETFIL("SA4"))))
		//Valida se transportadora é valida, para então gravar na carga
		SA4->(DbSetOrder(1))
		If !SA4->(dbSeek(xFilial('SA4')+cTransp))
			cTransp := ""
		EndIf
	EndIf

	//Ponto de entrada para validar se a viagem pode gerar uma carga
	//Parametro de Entrada: Codigo da Viagem, Codigo da Transportadora, Placa e Regiao Viagem
	//Parametro de Saida: Logico (.T. ou .F.), .T. -> Gerar Carga, .F. -> Não Gera Carga  
	If lRet .And. lOMSCPL7D
		aRetornoPE := ExecBlock('OMSCPL7D',.F.,.F.,{cViagId,cTransp, cPlaca,cRegId })
		
		If Valtype(aRetornoPE) == "A"
			If Valtype(aRetornoPE[1]) == "L"
				lRet := aRetornoPE[1]
			EndIf
			If !lRet
				If Valtype(aRetornoPE[2]) == "C"
					Aadd(aErros,aRetornoPE[2])
				Else
					Aadd(aErros,STR0072) // Operação Cancelada pelo usuário a partir do P.E. OMSCPL7D
				EndIf
			EndIf
		EndIF
		
	EndIf

	If lRet
		Begin Transaction
			//Carrega informações da placa
			If !Empty(cPlaca)
				cQuery := " SELECT DA3.DA3_COD,"
				cQuery +=        " DA3.DA3_MOTORI,"
				cQuery +=        " DA4.DA4_AJUDA1,"
				cQuery +=        " DA4.DA4_AJUDA2,"
				cQuery +=        " DA4.DA4_AJUDA3"
				cQuery +=   " FROM "+RetSqlName('DA3')+" DA3"
				cQuery +=   " LEFT JOIN "+RetSqlName('DA4')+" DA4"
				cQuery +=     " ON DA4.DA4_FILIAL = '"+xFilial('DA4')+"'"
				cQuery +=    " AND DA4.DA4_COD = DA3.DA3_MOTORI"
				cQuery +=    " AND DA4.D_E_L_E_T_ = ' '"
				cQuery +=  " WHERE DA3.DA3_FILIAL = '"+xFilial('DA3')+"'"
				cQuery +=    " AND DA3.DA3_PLACA  = '"+PadR(cPlaca, TamSx3("DA3_PLACA")[1])+"'"
				cQuery +=    " AND DA3.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasVeic := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasVeic, .F., .T.)

				OsLogCPL("OMSXCPL7 -> GeraCarga -> Conteudo da variavel cQuery-1: " + cValToChar(cQuery),"INFO")

				If (cAliasVeic)->(!EoF())
					cCaminhao := (cAliasVeic)->DA3_COD
					cMotorist := (cAliasVeic)->DA3_MOTORI
					cAjuda1   := (cAliasVeic)->DA4_AJUDA1
					cAjuda2   := (cAliasVeic)->DA4_AJUDA2
					cAjuda3   := (cAliasVeic)->DA4_AJUDA3
				EndIf
				(cAliasVeic)->(DbCloseArea())
			EndIf
			//Carrega informações fora do reclock
			cFilCarga := xFilial('DAK')
			cCodCarga := OMSCodCarg()
			cTipOper  := cOperaGFE//Tipo de Operação de Frete no GFE
			cClasFrete:= cClassGFE//Classificação de Frete no GFE
			
			//Ponto de entrada para ajustar Tipo de Operação de Integração GFE
			//Parametro de Entrada: Codigo da Viagem, Codigo do Tipo de Operação e Regiao Viagem
			//Parametro de Saida: Codigo de Tipo de Operação do GFE 
			If lRet .And. lOMSCPL7E
				cOMSGFETP := ExecBlock('OMSCPL7E',.F.,.F.,{cViagId,cTipOper,cRegId })
				OsLogCPL("OMSXCPL7 -> GeraCarga -> Encontrado o Ponto de Entrada OMSCPL7E.","INFO")

				If ValType(cOMSGFETP) == "C" .AND. !Empty(cOMSGFETP) .AND. CPL7VdOp(cOMSGFETP)
					cTipOper := AvKey(cOMSGFETP	,"DAK_CDTPOP") //Tipo de Operação de Frete no GFE 
				Endif
				
			EndIf
			
			//Ponto de entrada para ajustar Classificação de Operação de Integração GFE
			//Parametro de Entrada: Codigo da Viagem, Codigo da Classificação de Operação e Regiao Viagem
			//Parametro de Saida: Codigo de Classificação de Operação do GFE 
			If lRet .And. lOMSCPL7F
				cOMSGFECL := ExecBlock('OMSCPL7F',.F.,.F.,{cViagId,cClasFrete,cRegId })
				OsLogCPL("OMSXCPL7 -> GeraCarga -> Encontrado o Ponto de Entrada OMSCPL7F.","INFO")

				If ValType(cOMSGFECL) == "C" .AND. !Empty(cOMSGFECL) .AND. CPL7VdClF(cOMSGFECL)
					cClasFrete := AvKey(cOMSGFECL	,"DAK_CDCLFR") //Classificação de Frete no GFE
				Endif
			EndIf
	
			//Grava carga
			OsLogCPL("OMSXCPL7 -> GeraCarga -> Inicio da Gravação da Carga DAK.","INFO")
			RecLock("DAK",.T.)
			DAK->DAK_FILIAL := cFilCarga
			DAK->DAK_COD    := cCodCarga
			DAK->DAK_SEQCAR := "01"
			DAK->DAK_ROTEIR := "999999"
			DAK->DAK_DATA   := dDataBase
			If lTransp .And. !Empty(cTransp)
				DAK->DAK_TRANSP := cTransp
			EndIf
			DAK->DAK_VIAROT := cViagId
			If lCdTpOp
				DAK->DAK_CDTPOP := cTipOper
			EndIf
			If lCdClFr
				DAK->DAK_CDCLFR := cClasFrete
			EndIf
			DAK->DAK_HORA   := Time()
			DAK->DAK_HRSTAR := Time()
			DAK->DAK_FEZNF  := "2"
			DAK->DAK_ACECAR := "2"
			DAK->DAK_ACEVAS := "2"
			DAK->DAK_ACEFIN := "2"
			DAK->DAK_FLGUNI := "2"
			DAK->DAK_JUNTOU := "MANUAL"
			If !Empty(cPlaca)
				DAK->DAK_CAMINH := cCaminhao
				DAK->DAK_MOTORI := cMotorist
				DAK->DAK_AJUDA1 := cAjuda1
				DAK->DAK_AJUDA2 := cAjuda2
				DAK->DAK_AJUDA3 := cAjuda3
			EndIf

			//Validação das informações existentes na tabela DK0. Caso não existam nos devidos cadastros, os dados armazenados na declaração das variáveis será anulado.
			//As informações existentes na tabela DK0 DEVEM sobrepor as informações relacionadas a Placa do veículo principal, como Motorista e Ajudantes.
			If lDK0Veic2
				OsLogCPL("OMSXCPL7 -> GeraCarga -> Valor da Variavel lDK0Veic2" + cValToChar(lDK0Veic2),"INFO")
				If !Empty(DK0->DK0_VEIC2) .And. DAK->( ColumnPos( "DAK_VEIC2" ) ) > 0
					DA3->(DbSetOrder(1))
					If (DA3->(MsSeek(xFilial("DA3")+DK0->DK0_VEIC2)))
						DAK->DAK_VEIC2  := DK0->DK0_VEIC2
					EndIf
				EndIf
				If !Empty(DK0->DK0_VEIC3) .And. DAK->( ColumnPos( "DAK_VEIC3" ) ) > 0
					DA3->(DbSetOrder(1))
					If (DA3->(MsSeek(xFilial("DA3")+DK0->DK0_VEIC3)))
						DAK->DAK_VEIC3  := DK0->DK0_VEIC3
					EndIf
				EndIf				

				If !Empty(DK0->DK0_MOTORI) .And. DAK->( ColumnPos( "DAK_MOTORI" ) ) > 0
					DA4->(DbSetOrder(1))
					If (DA4->(MsSeek(xFilial("DA4")+DK0->DK0_MOTORI)))
						DAK->DAK_MOTORI := DK0->DK0_MOTORI
					EndIf
				EndIf

				If !Empty(DK0->DK0_AJUDA1) .And. DAK->( ColumnPos( "DAK_AJUDA1" ) ) > 0
					DAU->(DbSetOrder(1))
					If (DAU->(MsSeek(xFilial("DAU")+DK0->DK0_AJUDA1)))
						DAK->DAK_AJUDA1 := DK0->DK0_AJUDA1
					EndIf
				EndIf
				If !Empty(DK0->DK0_AJUDA2) .And. DAK->( ColumnPos( "DAK_AJUDA2" ) ) > 0
					DAU->(DbSetOrder(1))
					If (DAU->(MsSeek(xFilial("DAU")+DK0->DK0_AJUDA2)))
						DAK->DAK_AJUDA2 := DK0->DK0_AJUDA2
					EndIf
				EndIf
				If !Empty(DK0->DK0_AJUDA3) .And. DAK->( ColumnPos( "DAK_AJUDA3" ) ) > 0
					DAU->(DbSetOrder(1))
					If (DAU->(MsSeek(xFilial("DAU")+DK0->DK0_AJUDA3)))
						DAK->DAK_AJUDA3 := DK0->DK0_AJUDA3
					EndIf
				EndIf								
			EndIf

			DAK->(MsUnlock())
			//Realiza gravação dos itens da carga
			OsLogCPL("OMSXCPL7 -> GeraCarga -> Fim RecLock DAK.","INFO")
		
			cQuery := "SELECT DK1_FILPED, DK1_PEDIDO "
			If lSeqEnt
				cQuery += ", DK1_SEQENT"
			EndIf			
			cQuery += ", RECNOSC5, C5_CLIENTE, C5_LOJACLI, C5_CLIENT, C5_LOJAENT,"
			cQuery += " C5_FILIAL, C5_GERAWMS, C5_REDESP, A1_FILIAL, A1_NOME, A1_BAIRRO , A1_MUN, A1_EST"
			If lColTime
				cQuery += ", DK1_CHEGAD, DK1_TSAIDA"
			EndIf			
			cQuery += " FROM ( "
			cQuery += " SELECT DK1.DK1_FILPED,"
			cQuery += " DK1.DK1_PEDIDO,"
			If lSeqEnt
				cQuery +=    " DK1.DK1_SEQENT,"
			EndIf
			If lColTime
				cQuery +=    " DK1.DK1_CHEGAD,"
				cQuery +=    " DK1.DK1_TSAIDA,"
			EndIf
			cQuery +=        " SC5.R_E_C_N_O_ RECNOSC5,"
			cQuery +=        " SC5.C5_CLIENTE,"
			cQuery +=        " SC5.C5_LOJACLI,"
			cQuery +=        " SC5.C5_CLIENT,"
			cQuery +=        " SC5.C5_LOJAENT,"
			cQuery +=        " SC5.C5_FILIAL,"
			cQuery +=        " SC5.C5_GERAWMS,"
			cQuery +=        " SC5.C5_REDESP,"
			
			cQuery +=        " CASE WHEN SC5.C5_TIPO = 'B' OR SC5.C5_TIPO = 'D' THEN SA2.A2_FILIAL ELSE SA1.A1_FILIAL END A1_FILIAL,"
			cQuery +=        " CASE WHEN SC5.C5_TIPO = 'B' OR SC5.C5_TIPO = 'D' THEN SA2.A2_NOME ELSE SA1.A1_NOME END A1_NOME,"
			cQuery +=        " CASE WHEN SC5.C5_TIPO = 'B' OR SC5.C5_TIPO = 'D' THEN SA2.A2_BAIRRO ELSE SA1.A1_BAIRRO END A1_BAIRRO,"
			cQuery +=        " CASE WHEN SC5.C5_TIPO = 'B' OR SC5.C5_TIPO = 'D' THEN SA2.A2_MUN ELSE SA1.A1_MUN END A1_MUN,"
			cQuery +=        " CASE WHEN SC5.C5_TIPO = 'B' OR SC5.C5_TIPO = 'D' THEN SA2.A2_EST ELSE SA1.A1_EST END A1_EST"

			cQuery += "   FROM "+RetSqlName("DK1")+" DK1"
			cQuery +=  " INNER JOIN "+RetSqlName("SC5")+" SC5"
			cQuery +=     " ON SC5.C5_FILIAL = DK1.DK1_FILPED"
			cQuery +=    " AND SC5.C5_NUM    = DK1.DK1_PEDIDO"
			cQuery +=    " AND SC5.D_E_L_E_T_= ' '"
			
			cQuery +=  " LEFT JOIN "+RetSqlName("SA1")+" SA1"
			// Se busca filial através do método padrão
			If nTipoOper == 1
				cQuery +=  " ON SA1.A1_FILIAL  = '"+xFilial('SA1')+"'"
			Else
				cQuery +=  " ON SA1.A1_FILIAL  = "+OsFilQry("SA1","SC5.C5_FILIAL")
			EndIf
			cQuery +=    " AND SA1.A1_COD     = SC5.C5_CLIENT"
			cQuery +=    " AND SA1.A1_LOJA    = SC5.C5_LOJAENT"
			cQuery +=    " AND SA1.D_E_L_E_T_ = ' '"
			
			cQuery +=  " LEFT JOIN "+RetSqlName("SA2")+" SA2"
			// Se busca filial através do método padrão
			If nTipoOper == 1
				cQuery +=  " ON SA2.A2_FILIAL  = '"+xFilial('SA2')+"'"
			Else
				cQuery +=  " ON SA2.A2_FILIAL  = "+OsFilQry("SA2","SC5.C5_FILIAL")
			EndIf
			cQuery +=    " AND SA2.A2_COD     = SC5.C5_CLIENT"
			cQuery +=    " AND SA2.A2_LOJA    = SC5.C5_LOJAENT"
			cQuery +=    " AND SA2.D_E_L_E_T_ = ' '"
			
			cQuery +=  " INNER JOIN "+RetSqlName('DK0')+" DK0"
			cQuery +=     " ON DK0.DK0_FILIAL = '"+xFilial('DK0')+"'"
			cQuery +=    " AND DK0.DK0_REGID  = DK1.DK1_REGID"
			cQuery +=    " AND DK0.DK0_VIAGID = DK1.DK1_VIAGID"
			cQuery +=    " AND DK0.D_E_L_E_T_ = ' '"
			cQuery += "  WHERE DK1.DK1_FILIAL = '"+xFilial("DK1")+"'"
			cQuery +=    " AND DK1.DK1_REGID  = '"+cRegId+"'"
			cQuery +=    " AND DK1.DK1_VIAGID = '"+cViagId+"'"
			cQuery += "    AND DK1.D_E_L_E_T_ = ' '"
			cQuery += " ) SUBSQL "
			cQuery += " GROUP BY DK1_FILPED,"
			cQuery +=       " DK1_PEDIDO,"
			If lSeqEnt
				cQuery +=   " DK1_SEQENT,"
			EndIf
			If lColTime
				cQuery +=    " DK1_CHEGAD,"
				cQuery +=    " DK1_TSAIDA,"
			EndIf
			cQuery +=       " C5_CLIENTE,"
			cQuery +=       " C5_LOJACLI,"
			cQuery +=       " C5_CLIENT,"
			cQuery +=       " C5_LOJAENT,"
			cQuery +=       " C5_FILIAL,"
			cQuery +=       " RECNOSC5,"
			cQuery +=       " C5_GERAWMS,"
			cQuery +=       " C5_REDESP,"
			cQuery +=       " A1_FILIAL,"
			cQuery +=       " A1_NOME,"
			cQuery +=       " A1_BAIRRO,"
			cQuery +=       " A1_MUN,"
			cQuery +=       " A1_EST"

			If lSeqEnt
				cQuery += " ORDER BY DK1_SEQENT,"
				cQuery +=          " DK1_PEDIDO"
			Else
				cQuery += " ORDER BY C5_CLIENT,"
				cQuery +=          " C5_LOJAENT"
			EndIf
			
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

			OsLogCPL("OMSXCPL7 -> GeraCarga -> Conteudo da variavel cQuery-2: " + cValToChar(cQuery),"INFO")

			While (cAliasQry)->(!EoF()) .And. lRet
				//Zera variáveis para contagem de um novo item DAI
				nDAIpeso   := 0
				nDAIvolume := 0
				lAvalLibPed:= .F.
				If lSeqEnt
					cSeqEnt := (cAliasQry)->DK1_SEQENT
				EndIf
				//Sequência de entrega
				If Empty(nSequen) .Or.!lSeqEnt .Or. !(cSeqEntAnt == cSeqEnt)
					nSequen +=  nSeqInc
					If lSeqEnt
						cSeqEntAnt := (cAliasQry)->DK1_SEQENT
					EndIf
				EndIf
				//Busca itens do pedido
				cQuery := " SELECT DK1.DK1_PRODUT,"
				cQuery +=        " DK1.DK1_FILPED,"
				cQuery +=        " DK1.DK1_PEDIDO,"
				cQuery +=        " DK1.DK1_ITEMPE,"
				If lColPeso
					cQuery +=     " DK1.DK1_PESO,"
					cQuery +=     " DK1.DK1_VOLUME,"
				EndIf
				cQuery +=        " DK1.DK1_QTD,"
				cQuery +=        " DK1.DK1_PRECO,"
				cQuery +=        " SF4.F4_ESTOQUE,"
				cQuery +=        " DK3.DK3_QTDINT,"
				cQuery +=        " SB5.B5_TIPUNIT,"
				cQuery +=        " SC6.R_E_C_N_O_ RECNOSC6,"
				cQuery +=        " SB1.R_E_C_N_O_ RECNOSB1"
				If lSeqEnt
					cQuery += ", DK1_SEQENT"
				EndIf	
				cQuery +=   " FROM "+RetSqlName('DK1')+" DK1"
				cQuery +=  " INNER JOIN "+RetSqlName('DK0')+" DK0"
				cQuery +=     " ON DK0.DK0_FILIAL = '"+xFilial('DK0')+"'"
				cQuery +=    " AND DK0.DK0_REGID  = DK1.DK1_REGID"
				cQuery +=    " AND DK0.DK0_VIAGID = DK1.DK1_VIAGID"
				cQuery +=    " AND DK0.D_E_L_E_T_ = ' '"
				cQuery +=  " INNER JOIN "+RetSqlName('SB1')+" SB1"
				// Se busca filial através do método padrão
				If nTipoOper == 1
					cQuery +=  " ON SB1.B1_FILIAL = '"+xFilial('SB1')+"'"
				Else
					cQuery +=  " ON SB1.B1_FILIAL = "+OsFilQry("SB1","DK1.DK1_FILPED")
				EndIf
				cQuery +=    " AND SB1.B1_COD    = DK1.DK1_PRODUT"
				cQuery +=    " AND SB1.D_E_L_E_T_= ' '"
				cQuery +=  " INNER JOIN "+RetSqlName('SC6')+" SC6"
				cQuery +=     " ON SC6.C6_FILIAL  = DK1.DK1_FILPED"
				cQuery +=    " AND SC6.C6_NUM     = DK1.DK1_PEDIDO"
				cQuery +=    " AND SC6.C6_ITEM    = DK1.DK1_ITEMPE"
				cQuery +=    " AND SC6.C6_PRODUTO = DK1.DK1_PRODUT"
				cQuery +=    " AND SC6.D_E_L_E_T_ = ' '"
				cQuery +=  " INNER JOIN "+RetSqlName('SF4')+" SF4"
				// Se busca filial através do método padrão
				If nTipoOper == 1
					cQuery +=  " ON SF4.F4_FILIAL  = '"+xFilial('SF4')+"'"
				Else
					cQuery +=  " ON SF4.F4_FILIAL = "+OsFilQry("SF4","DK1.DK1_FILPED")
				EndIf
				cQuery +=    " AND SF4.F4_CODIGO  = SC6.C6_TES"
				cQuery +=    " AND SF4.D_E_L_E_T_ = ' '"
				cQuery +=   " LEFT JOIN "+RetSqlName('SB5')+" SB5 "
				cQuery +=     " ON SB5.B5_FILIAL = '"+xFilial('SB5')+"'"
				cQuery +=    " AND SB5.B5_COD    = DK1.DK1_PRODUT"
				cQuery +=    " AND SB5.D_E_L_E_T_ = ' '"
				cQuery +=  " INNER JOIN "+RetSqlName('DK3')+" DK3"
				cQuery +=     " ON DK3.DK3_FILIAL = DK1.DK1_FILPED"
				cQuery +=    " AND DK3.DK3_PEDIDO = DK1.DK1_PEDIDO"
				cQuery +=    " AND DK3.DK3_ITEMPE = DK1.DK1_ITEMPE"
				cQuery +=    " AND DK3.DK3_PRODUT = DK1.DK1_PRODUT"
				cQuery +=    " AND DK3.DK3_VIAGID = DK1.DK1_VIAGID"
				cQuery +=    " AND DK3.D_E_L_E_T_ = ' '"
				If lDK3QuebId .And. lColQuebOr
					cQuery +=    " AND DK3.DK3_QUEBID = DK1.DK1_QUEORI"
				EndIf
				If lColSequen
					cQuery +=    " AND DK3.DK3_SEQUEN = DK1.DK1_SEQUEN"
				EndIf
				cQuery +=  " WHERE DK1_FILIAL     = '"+xFilial('DK1')+"'"
				cQuery +=    " AND DK1.DK1_REGID  = '"+cRegId+"'"
				cQuery +=    " AND DK1.DK1_VIAGID = '"+cViagId+"'"
				cQuery +=    " AND DK1.DK1_FILPED = '"+(cAliasQry)->DK1_FILPED+"'"
				cQuery +=    " AND DK1.DK1_PEDIDO = '"+(cAliasQry)->DK1_PEDIDO+"'"
				If lSeqEnt
					cQuery +=    " AND DK1.DK1_SEQENT = '"+(cAliasQry)->DK1_SEQENT+"'"
				EndIf
				cQuery +=    " AND DK1.D_E_L_E_T_ = ' '"

				cQuery := ChangeQuery(cQuery)
				cAliasPed := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasPed, .F., .T.)

				OsLogCPL("OMSXCPL7 -> GeraCarga -> Conteudo da variavel cQuery-3: " + cValToChar(cQuery),"INFO")

				aTamSX3 := TamSx3("DK1_QTD"); TCSetField(cAliasPed,'DK1_QTD', 'N',aTamSX3[1],aTamSX3[2])
				aTamSX3 := TamSx3("DK1_PRECO"); TCSetField(cAliasPed,'DK1_PRECO', 'N',aTamSX3[1],aTamSX3[2])
				If lColPeso
					aTamSX3 := TamSx3("DK1_PESO"); TCSetField(cAliasPed,'DK1_PESO', 'N',aTamSX3[1],aTamSX3[2])
					aTamSX3 := TamSx3("DK1_VOLUME"); TCSetField(cAliasPed,'DK1_VOLUME', 'N',aTamSX3[1],aTamSX3[2])
				EndIf
				While (cAliasPed)->(!EoF()) .And. lRet
					If (cAliasPed)->B5_TIPUNIT == "0"
						//Tratamento exclusivo para produto controlado a granel.
						//Neste cenário o produto é integrado com quantidade 1, portanto é necessário utilizar a quantidade "real" do produto com base na DK3.
						nSaldoCarg := (cAliasPed)->DK3_QTDINT
					Else
						nSaldoCarg := (cAliasPed)->DK1_QTD
					EndIf
					//Valida se existe saldo suficiente não faturado para atender a carga			
					cQuery := " SELECT (SC6.C6_QTDVEN - SUM(SD2.D2_QUANT)) SALDO"
					cQuery +=   " FROM "+RetSqlName('SC6')+" SC6"
					cQuery +=  " INNER JOIN "+RetSqlName('SD2')+" SD2"
					cQuery +=     " ON SD2.D2_FILIAL  = SC6.C6_FILIAL"
					cQuery +=    " AND SD2.D2_PEDIDO  = SC6.C6_NUM"
					cQuery +=    " AND SD2.D2_ITEMPV  = SC6.C6_ITEM"
					cQuery +=    " AND SD2.D_E_L_E_T_ = ' '"
					cQuery +=  " WHERE SC6.C6_FILIAL  = '"+(cAliasQry)->DK1_FILPED+"'"
					cQuery +=    " AND SC6.C6_NUM     = '"+(cAliasPed)->DK1_PEDIDO+"'"
					cQuery +=    " AND SC6.C6_ITEM    = '"+(cAliasPed)->DK1_ITEMPE+"'"
					cQuery +=    " AND SC6.C6_PRODUTO = '"+(cAliasPed)->DK1_PRODUT+"'"
					cQuery +=    " AND SC6.D_E_L_E_T_ = ' '"
					cQuery +=  " GROUP BY SC6.C6_QTDVEN"
					cQuery := ChangeQuery(cQuery)
					cAliasSld := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSld, .F., .T.)

					OsLogCPL("OMSXCPL7 -> GeraCarga -> Conteudo da variavel cQuery-4: " + cValToChar(cQuery),"INFO")

					If (cAliasSld)->(!EoF())
						If QtdComp(nSaldoCarg) > QtdComp((cAliasSld)->SALDO)
							Aadd(aErros,OmsFmtMsg(STR0030,{{"[VAR01]",cRegId},{"[VAR02]",cViagId},{"[VAR03]",(cAliasPed)->DK1_PEDIDO}})) //Regional: [VAR01] / Viagem: [VAR02] - Não foi possível encontrar saldo suficiente de itens não faturados para a geração da carga no pedido [VAR03].
							lRet := .F.
						EndIf
					EndIf
					(cAliasSld)->(DbCloseArea())
					If lRet
						//Busca SC9 para atender a carga
						cQuery := " SELECT SC9.R_E_C_N_O_ RECNOSC9,"
						cQuery +=        " SC9.C9_QTDLIB"
						cQuery +=   " FROM "+RetSqlName('SC9')+ " SC9"
						cQuery +=  " WHERE SC9.C9_FILIAL  = '"+(cAliasQry)->DK1_FILPED+"'"
						cQuery +=    " AND SC9.C9_CLIENTE = '"+(cAliasQry)->C5_CLIENTE+"'"
						cQuery +=    " AND SC9.C9_LOJA    = '"+(cAliasQry)->C5_LOJACLI+"'"
						cQuery +=    " AND SC9.C9_PEDIDO  = '"+(cAliasPed)->DK1_PEDIDO+"'"
						cQuery +=    " AND SC9.C9_ITEM    = '"+(cAliasPed)->DK1_ITEMPE+"'"
						cQuery +=    " AND SC9.C9_PRODUTO = '"+(cAliasPed)->DK1_PRODUT+"'"
						cQuery +=    " AND SC9.C9_CARGA   = '"+Space(TamSx3('C9_CARGA')[1])+"'"
						cQuery +=    " AND SC9.C9_NFISCAL = '"+Space(TamSx3('C9_NFISCAL')[1])+"'"
						cQuery +=    " AND SC9.C9_BLEST   = '"+Space(TamSx3('C9_BLEST')[1])+"'"
						cQuery +=    " AND SC9.C9_BLCRED  = '"+Space(TamSx3('C9_BLCRED')[1])+"'"
						cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
						cQuery := ChangeQuery(cQuery)
						cAliasSC9 := GetNextAlias()
						dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSC9, .F., .T.)

						OsLogCPL("OMSXCPL7 -> GeraCarga -> Conteudo da variavel cQuery-5: " + cValToChar(cQuery),"INFO")

						aTamSx3 := TamSx3("C9_QTDLIB")
						TCSetField(cAliasSC9,'C9_QTDLIB','N',aTamSx3[1],aTamSx3[2])
						While (cAliasSC9)->(!EoF()) .And. nSaldoCarg > 0 .And. lRet
							SC9->(DbGoto((cAliasSC9)->RECNOSC9))
							If (cAliasSC9)->C9_QTDLIB > nSaldoCarg
								//Quebra SC9 para atender a quantidade da carga
								If !OmsDivSC9(nSaldoCarg)
									Aadd(aErros,OmsFmtMsg(STR0025,{{"[VAR01]",cRegId},{"[VAR02]",cViagId}})) // Falha ao realizar divisão da SC9 para gravação da carga.
									lRet := .F.
								EndIf
								nSaldoCarg := 0
							Else
								//Registro quanto da quantidade da carga foi atendida pela SC9 posicionada
								nSaldoCarg -= (cAliasSC9)->C9_QTDLIB
							EndIf
							RecLock("SC9",.F.)
							SC9->C9_CARGA  := cCodCarga
							SC9->C9_SEQENT := StrZero(nSequen,6)
							SC9->C9_SEQCAR := "01"
							SC9->(MsUnLock())
							(cAliasSC9)->(DbSkip())
						EndDo
						(cAliasSC9)->(DbCloseArea())
					EndIf
					If lRet .And. nSaldoCarg > 0
						SC6->(DbGoTo((cAliasPed)->RECNOSC6))
						If lLibPed
							//Realizado liberação do pedido
							MaLibDoFat((cAliasPed)->RECNOSC6/*nRegSC6*/,nSaldoCarg /*nQtdaLib*/,/*lCredito*/,/*lEstoque*/,/*lAvCred*/,/*lAvEst*/,.T./*lLibPar*/,.F./*lTrfLocal*/,/*aEmpenho*/,/*bBlock*/,/*aEmpPronto*/,.F./*lTrocaLot*/,.T./*lGeraDCF*/,/*nVlrCred*/,/*nQtdalib2*/)
							lAvalLibPed := .T.
							//Busca SC9 para atender a carga
							cQuery := " SELECT SC9.R_E_C_N_O_ RECNOSC9,"
							cQuery +=        " SC9.C9_QTDLIB"
							cQuery +=   " FROM "+RetSqlName('SC9')+ " SC9"
							cQuery +=  " WHERE SC9.C9_FILIAL  = '"+(cAliasQry)->DK1_FILPED+"'"
							cQuery +=    " AND SC9.C9_CLIENTE = '"+(cAliasQry)->C5_CLIENTE+"'"
							cQuery +=    " AND SC9.C9_LOJA    = '"+(cAliasQry)->C5_LOJACLI+"'"
							cQuery +=    " AND SC9.C9_PEDIDO  = '"+(cAliasPed)->DK1_PEDIDO+"'"
							cQuery +=    " AND SC9.C9_ITEM    = '"+(cAliasPed)->DK1_ITEMPE+"'"
							cQuery +=    " AND SC9.C9_PRODUTO = '"+(cAliasPed)->DK1_PRODUT+"'"
							cQuery +=    " AND SC9.C9_CARGA   = '"+Space(TamSx3('C9_CARGA')[1])+"'"
							cQuery +=    " AND SC9.C9_NFISCAL = '"+Space(TamSx3('C9_NFISCAL')[1])+"'"
							cQuery +=    " AND SC9.C9_BLEST   = '"+Space(TamSx3('C9_BLEST')[1])+"'"
							cQuery +=    " AND SC9.C9_BLCRED  = '"+Space(TamSx3('C9_BLCRED')[1])+"'"
							cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
							cQuery := ChangeQuery(cQuery)
							cAliasSC9 := GetNextAlias()
							dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSC9, .F., .T.)

							OsLogCPL("OMSXCPL7 -> GeraCarga -> Conteudo da variavel cQuery-6: " + cValToChar(cQuery),"INFO")

							aTamSx3 := TamSx3("C9_QTDLIB")
							TCSetField(cAliasSC9,'C9_QTDLIB','N',aTamSx3[1],aTamSx3[2])
							While (cAliasSC9)->(!EoF()) .And. nSaldoCarg > 0
								SC9->(DbGoto((cAliasSC9)->RECNOSC9))
								nSaldoCarg -= (cAliasSC9)->C9_QTDLIB
								RecLock("SC9",.F.)
								SC9->C9_CARGA  := cCodCarga
								SC9->C9_SEQENT := StrZero(nSequen,6)
								SC9->C9_SEQCAR := "01"
								SC9->(MsUnLock())
								(cAliasSC9)->(DbSkip())
							EndDo
							(cAliasSC9)->(dbCloseArea())
						EndIf
					EndIf
					If lRet .And. nSaldoCarg > 0
						Aadd(aErros,OmsFmtMsg(STR0026,{{"[VAR01]",cRegId},{"[VAR02]",cViagId},{"[VAR03]",(cAliasPed)->DK1_ITEMPE},{"[VAR04]",(cAliasPed)->DK1_PEDIDO}})) //Regional: [VAR01] / Viagem: [VAR02] - Não foi possível liberar quantidade suficiente do pedido para a geração da carga. Efetue a liberação do item [VAR03] do pedido [VAR04] de forma manual.
						lRet := .F.
					EndIf
					If lRet
						//Totalizadores DAI/DAK
						SB1->(DbGoto((cAliasPed)->RECNOSB1))
						If lColPeso
							nDAIpeso   += (cAliasPed)->DK1_PESO
							nDAIvolume += (cAliasPed)->DK1_VOLUME
							nDAKvalor  += (cAliasPed)->DK1_PRECO
						Else
							nDAIpeso   += (OsPesoProd((cAliasPed)->DK1_PRODUT,(cAliasPed)->DK1_FILPED)) * (cAliasPed)->DK1_QTD
							nDAIvolume += OsPrCapArm((cAliasPed)->DK1_PRODUT,(cAliasPed)->DK1_FILPED) * (cAliasPed)->DK1_QTD
							nDAKvalor  += (cAliasPed)->DK1_QTD * SC9->C9_PRCVEN
						EndIf
						//Verifica se gera o Servico de WMS na montagem da Carga
						If IntWms((cAliasPed)->DK1_PRODUT) .And. !Empty(SC9->C9_SERVIC) .And. (cAliasPed)->F4_ESTOQUE == "S" .And. (cAliasQry)->C5_GERAWMS == "2"
							WmsIntPed(SC9->(Recno()))
						EndIf
						If lTransp .And. !Empty(cTransp) .OR. !Empty(cCaminhao)
							SC5->(DbGoto((cAliasQry)->RECNOSC5))
							RecLock('SC5',.F.)
							If lTransp .And. !Empty(cTransp)
								SC5->C5_TRANSP := cTransp
							Endif 
							If !Empty(cCaminhao)
								SC5->C5_VEICULO := cCaminhao
							EndIf
							SC5->(MsUnlock())
						EndIf
					EndIf
					(cAliasPed)->(DbSkip())
				EndDo
				(cAliasPed)->(DbCloseArea())
				If lRet .And. lAvalLibPed
					MaLiberOk({ SC6->C6_NUM }, .F.)
				EndIf
				If lRet
					OsLogCPL("OMSXCPL7 -> GeraCarga -> Inicio da Gravação DAI.","INFO")
					//Grava itens da carga DAI
					RecLock("DAI",.T.)
					DAI->DAI_FILIAL := cFilCarga
					DAI->DAI_COD    := cCodCarga
					DAI->DAI_PEDIDO := (cAliasQry)->DK1_PEDIDO
					DAI->DAI_CLIENT := (cAliasQry)->C5_CLIENT
					DAI->DAI_LOJA   := (cAliasQry)->C5_LOJAENT
					If DAI->(ColumnPos("DAI_FILPV")) > 0
						DAI->DAI_FILPV  := (cAliasQry)->C5_FILIAL
					EndIf
					DAI->DAI_SEQUEN := StrZero(nSequen,6)
					DAI->DAI_PESO   := nDAIpeso
					DAI->DAI_CAPVOL := nDAIvolume
					DAI->DAI_PERCUR := "999999"
					DAI->DAI_ROTA   := "999999"
					DAI->DAI_ROTEIR := "999999"
					DAI->DAI_DATA   := dDataBase
					DAI->DAI_HORA   := Time()
					DAI->DAI_CARORI := "CARGA"
					If lColTime
						aTime := FWDateTimeToLocal((cAliasQry)->DK1_CHEGAD)
						DAI->DAI_DTCHEG := aTime[1]
						DAI->DAI_CHEGAD := aTime[2]
						aTime := FWDateTimeToLocal((cAliasQry)->DK1_TSAIDA)
						DAI->DAI_DTSAID := aTime[1]
						DAI->DAI_HRSAID := aTime[2]
					Else
						DAI->DAI_DTCHEG := dDataBase
						DAI->DAI_CHEGAD := Time()
						DAI->DAI_DTSAID := dDataBase
					EndIf
					DAI->DAI_TMSERV := "0000000"
					DAI->DAI_SEQCAR := "01"
					// DAI->DAI_VALFRE := "" Rever por conta do GFE
					// DAI->DAI_FREAUT := "" Rever por conta do GFE
					If lDaiRedesp
						DAI->DAI_REDESP := (cAliasQry)->C5_REDESP
					EndIF
					DAI->(MsUnlock())
					//Totalizadores da carga
					nDAKpeso  += nDAIpeso
					nDAKvolume+= nDAIvolume
					//Cada novo cliente/loja conta como um novo ponto de entrega
					If !(cCliAnt == (cAliasQry)->C5_CLIENT) .Or. (cCliAnt == (cAliasQry)->C5_CLIENT .And. !(cLojaAnt == (cAliasQry)->C5_LOJAENT))
						cCliAnt := (cAliasQry)->C5_CLIENT
						cLojaAnt := (cAliasQry)->C5_LOJAENT
						nPtEntrega += 1
					EndIf
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
			OsLogCPL("OMSXCPL7 -> GeraCarga -> Fim da Gravação DAI.","INFO")
			//Grava informação da carga na viagem
			OsLogCPL("OMSXCPL7 -> GeraCarga -> Inicio da Gravação DK0.","INFO")
			
			If lRet
				If lColDisDK0
					nTotDist := DK0->DK0_DISROT
				EndIf
				RecLock("DK0",.F.)
				DK0->DK0_MARK   := ""
				DK0->DK0_CARGA  := cCodCarga
				DK0->DK0_CARGER := "1"
				DK0->(MsUnLock())
				//Grava totais
				RecLock("DAK",.F.)
				DAK->DAK_PESO   := nDAKpeso
				DAK->DAK_CAPVOL := nDAKvolume
				DAK->DAK_PTOENT := nPtEntrega
				DAK->DAK_VALOR  := A410Arred(nDAKvalor, "DAK_VALOR")
				If lColDisDAK
					DAK->DAK_DISROT  := nTotDist 
				EndIf
				DAK->(MsUnLock())
			EndIf

			//Ponto de entrada para complementar dados da Carga antes de integrar com o GFE.
			If lRet .And. lOMSCPL7G
				ExecBlock('OMSCPL7G',.F.,.F.,{cCodCarga, cRegId, cViagId})
				OsLogCPL("OMSXCPL7 -> GeraCarga -> Encontrado o Ponto de Entrada OMSCPL7G.","INFO")
			EndIf

			// Integração com o GFE - Geração de Romaneio
			If lRet
				If !OMSA200IPG(3,,,.T.,,,,DAK->DAK_TRANSP,DAK->DAK_CDTPOP,DAK->DAK_CDCLFR,,,nTotDist,@cErro)
					Aadd(aErros,OmsFmtMsg(STR0027,{{"[VAR01]",cRegId},{"[VAR02]",cViagId},{"[VAR03]",cErro}}))
					lRet := .F.
				EndIf
			EndIf
			If !lRet
				Disarmtransaction()
			EndIf
		End Transaction
		If lRet .And. ExistBlock('OMSCPL7C')
			ExecBlock('OMSCPL7C',.F.,.F.,{cCodCarga,cRegId,cViagId})
			OsLogCPL("OMSXCPL7 -> GeraCarga -> Encontrado o Ponto de Entrada OMSCPL7C.","INFO")
		EndIf
		//-- Executa as ordens de serviços geradas no WMS
		If lRet .And. IntWms()
			OsLogCPL("OMSXCPL7 -> GeraCarga -> Integração com WMS.","INFO")
			WmsAvalExe()
		EndIf
	
	EndIF
	
Return lRet

/*/{Protheus.doc} OmsDivSC9
Realiza a divisão da SC9 para gravar a carga
@author amanda.vieira
@since 30/10/2018
@version version 1.0
/*/
Function OmsDivSC9(nQtdNew)
Local lRet      := .T.
Local nX        := 0
Local nDif      := 0
Local nQuant    := 0
Local nBaixa    := 0
Local cAliasSDC := ""
Local cAliasSC9 := ""
Local cQuery    := ""
Local cSeqNew   := ""
Local cSequen   := SC9->C9_SEQUEN
Local aCopySC9  := {}
Local aCopySDC  := {}
	For nX := 1 To SC9->(FCount())
		Aadd(aCopySC9, SC9->(FieldGet(nX)))
	Next nX
	//-- Inclui uma nova Seq. no SC9 com DIFERENCA
	nDif := SC9->C9_QTDLIB - nQtdNew
	If Len(aCopySC9) > 0
		//-- registro do SC9 com DIFERENCA da quantidade
		RecLock('SC9',.F.)
		Replace C9_QTDLIB  With nDif
		Replace C9_QTDLIB2 With ConvUM(SC9->C9_PRODUTO, nDif, 0, 2)
		SC9->(MsUnlock())
		//-- Verifica a Sequencia de Liberacao do SC9
		cQuery := " SELECT MAX(SC9.C9_SEQUEN) SEQUEN"
		cQuery +=   " FROM "+RetSqlName("SC9")+" SC9"
		cQuery +=  " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
		cQuery +=    " AND SC9.C9_PEDIDO = '"+SC9->C9_PEDIDO+"'"
		cQuery +=    " AND SC9.C9_ITEM   = '"+SC9->C9_ITEM  +"'"
		cQuery +=    " AND SC9.D_E_L_E_T_= ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasSC9 := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)

		OsLogCPL("OMSXCPL7 -> OmsDivSC9 -> Conteudo da variavel cQuery-1: " + cValToChar(cQuery),"INFO")

		If (cAliasSC9)->(!Eof())
			cSeqNew := (cAliasSC9)->SEQUEN
		EndIf
		(cAliasSC9)->(dbCloseArea())
		//-- Novo registro do SC9 com nova quantidade e sequencia
		cSeqNew := Soma1(cSeqNew,Len(SC9->C9_SEQUEN))
		dbSelectArea("SC9")
		RecLock("SC9", .T.)
		For nX := 1 To Len(aCopySC9)
			FieldPut(nX, aCopySC9[nX])
		Next nX
		Replace C9_SEQUEN  With cSeqNew
		Replace C9_QTDLIB  With nQtdNew
		Replace C9_QTDLIB2 With ConvUM(SC9->C9_PRODUTO, nQtdNew, 0, 2)
		SC9->(MsUnlock())
		//-- registro do SDC com DIFERENCA da quantidade empenho
		nQuant := nQtdNew
		// Busca as SDC da sequencia do pedido que será alterada.
		cQuery :=  "SELECT SDC.R_E_C_N_O_ RECNOSDC"
		cQuery +=   " FROM "+RetSqlName("SDC")+" SDC"
		cQuery +=  " WHERE SDC.DC_FILIAL  = '"+xFilial("SDC")+"'"
		cQuery +=    " AND SDC.DC_PRODUTO = '"+SC9->C9_PRODUTO+"'"
		cQuery +=    " AND SDC.DC_LOCAL   = '"+SC9->C9_LOCAL+"'"
		cQuery +=    " AND SDC.DC_ORIGEM  = 'SC6'"
		cQuery +=    " AND SDC.DC_PEDIDO  = '"+SC9->C9_PEDIDO+"'"
		cQuery +=    " AND SDC.DC_ITEM    = '"+SC9->C9_ITEM+"'"
		cQuery +=    " AND SDC.DC_SEQ     = '"+cSequen+"'"
		cQuery +=    " AND SDC.DC_LOTECTL = '"+SC9->C9_LOTECTL+"'"
		cQuery +=    " AND SDC.DC_NUMLOTE = '"+SC9->C9_NUMLOTE+"'"
		cQuery +=    " AND SDC.D_E_L_E_T_ = ' '"
		cQuery +=   " ORDER BY SDC.DC_QUANT DESC"
		cQuery := ChangeQuery(cQuery)
		cAliasSDC := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSDC,.T.,.T.)

		OsLogCPL("OMSXCPL7 -> OmsDivSC9 -> Conteudo da variavel cQuery-2: " + cValToChar(cQuery),"INFO")

		Do While (cAliasSDC)->(!Eof()) .And. nQuant > 0
			aCopySDC := {}
			SDC->(dbGoTo((cAliasSDC)->RECNOSDC))
			For nX := 1 To SDC->(FCount())
				Aadd(aCopySDC, SDC->(FieldGet(nX)))
			Next nX
			// Ajusta empenho
			If QtdComp(SDC->DC_QUANT) <= QtdComp(nQuant)
				RecLock("SDC", .F.)
				Replace DC_SEQ     With cSeqNew
				SDC->(MsUnlock())
				nQuant -= SDC->DC_QUANT
			Else
				nBaixa := SDC->DC_QUANT - nQuant
				// Ajusta empenho da sequencia origem
				RecLock("SDC", .F.)
				Replace DC_QUANT   With nBaixa
				Replace DC_QTSEGUM With ConvUM(SDC->DC_PRODUTO, nBaixa, 0, 2)
				SDC->(MsUnlock())
				// Gera empenho para nova sequencia
				dbSelectArea("SDC")
				RecLock("SDC", .T.)
				For nX := 1 To Len(aCopySDC)
					FieldPut(nX, aCopySDC[nX])
				Next nX
				Replace DC_SEQ     With cSeqNew
				Replace DC_QUANT   With nQuant
				Replace DC_QTSEGUM With ConvUM(SDC->DC_PRODUTO, nQuant, 0, 2)
				SDC->(MsUnlock())
				nQuant -= SDC->DC_QUANT
			EndIf
			(cAliasSDC)->(dbSkip())
		EndDo
		(cAliasSDC)->(dbCloseArea())
	EndIf
Return lRet
/*/{Protheus.doc} OSExistSX1
Verifica se existe os perguntes da rotina OMSXCPL7
@author amanda.vieira
@since 12/09/2019
@version 1.0
/*/
Static Function OSExistSX1()
Local lRet := .F. 
	SX1->(DbSetOrder(1))
	If SX1->(MsSeek("OMSXCPL7"))
		lRet := .T.
	EndIf
Return lRet
/*/{Protheus.doc} OMSXCPLEM
Realiza o cancelamento do monitoramento das cargas
@author amanda.vieira
@since 03/10/2019
@version 1.0
/*/
Function OMSXCPLEM(lAutom)
Local lRet := .T.
Default lAutom := .F.
	Processa({||lRet := ProcCanMon()}, STR0065, STR0066) //Cancelando Monitoramento //Cancelando monitoramento das cargas no Cockpit Logístico.
	If !lAutom
		RefreshBrw()
	EndIf
Return lRet
/*/{Protheus.doc} ProcEnvMon
Processa o cancelamento do monitoramento das cargas
@author amanda.vieira
@since 03/10/2019
@version 1.0
/*/
Static Function ProcCanMon()
Local aCabecalho:= {}
Local aFalhas   := {}
Local aEnviados := {}
Local aResumo   := {}
Local lRet      := .T.
Local lIsBlind   := IsBlind()
Local cAliasDAK := GetNextAlias()
Local nTotalReg := 0
Local nQtdFalhas:= 0
Local oMonitoramento := OMSBCCMonitoramentoCPL():New()
Local cSelect 	:= ""
Local cSelectCnt:= ""
Local nTot		:= 0
Local cQuery	:= ""

	OsLogCPL("OMSXCPL7 -> ProcCanMon -> "+Replicate("-", 100),"INFO")
	OsLogCPL("OMSXCPL7 -> ProcCanMon -> INICIO DO PROCESSAMENTO DO CANCELAMENTO DO MONITORAMENTO DAS CARGAS.","INFO")

	cSelect := " SELECT TMP.TMP_RECDAK,"
	cSelect +=        " TMP.TMP_CARGA,"
	cSelect +=        " TMP.TMP_SEQCAR,"
	cSelect +=        " TMP.TMP_VIAGID"

	cSelectCnt := "SELECT COUNT(*) QTDTOTAL"

	cQuery +=   " FROM  "+oTempTab:GetRealName()+" TMP"
	cQuery +=  " WHERE TMP.D_E_L_E_T_ = ' '"
	If !lIsBlind
		cQuery +=  " AND TMP.TMP_MARK = '"+oBrowse:Mark()+"'"
	EndIf
	cQuery +=    " AND TMP.TMP_SITCAR = '4'"
	cQuery +=    " AND TMP.D_E_L_E_T_ = ' '"

	cSelectCnt := cSelectCnt + cQuery
	cAliasDAK :=GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSelectCnt), cAliasDAK, .F., .T.)
	nTot := (cAliasDAK)->QTDTOTAL
	(cAliasDAK)->(dbCloseArea())

	cSelect := cSelect + cQuery
	OsLogCPL("OMSXCPL7 -> ProcCanMon -> Conteudo da variavel cSelect-1: " + AllTrim(cSelect),"INFO")

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSelect), cAliasDAK, .F., .T.)		

	ProcRegua(nTot)
	
	While (cAliasDAK)->(!EoF())
		If !((cAliasDAK)->TMP_RECDAK == 0)
			nTotalReg += 1
			If !lIsBlind
				IncProc(STR0053+(cAliasDAK)->TMP_SEQCAR) //Processando Carga 
			EndIf
			oMonitoramento:setCarga((cAliasDAK)->TMP_CARGA)
			oMonitoramento:setSeqCarga((cAliasDAK)->TMP_SEQCAR)
			oMonitoramento:setIdViagem((cAliasDAK)->TMP_VIAGID)
			oMonitoramento:deleteMonitoravel()
			If !oMonitoramento:getSucesso()
				nQtdFalhas += 1
				If Empty(aFalhas)
					aAdd(aFalhas,STR0067) //Registros Não Cancelados
				EndIf
				aAdd(aFalhas,OmsFmtMsg(STR0055+CRLF+oMonitoramento:getMensagemErro(),{{"[VAR01]",(cAliasDAK)->TMP_CARGA},{"[VAR02]",(cAliasDAK)->TMP_SEQCAR}})) // Carga [VAR01] | Sequência [VAR02]. // Motivo:
				aAdd(aFalhas,Replicate("-",166))
			Else
				If Empty(aEnviados)
					aAdd(aEnviados,STR0071) //Registros Cancelados
				EndIf
				aAdd(aEnviados,OmsFmtMsg(STR0055,{{"[VAR01]",(cAliasDAK)->TMP_CARGA},{"[VAR02]",(cAliasDAK)->TMP_SEQCAR}})) //Carga [VAR01] | Sequência [VAR02]
			EndIf
		EndIf
		(cAliasDAK)->(DbSkip())
	EndDo
	(cAliasDAK)->(DbCloseArea())
	
	If nTotalReg == 0
		If !lIsBlind
			MSGAlert(STR0068) // Nenhum registro válido selecionado para cancelamento do monitoramento
		EndIf
		lRet := .F.
	Else
		aAdd(aCabecalho,STR0069+CRLF) // Resumo do cancelamento da(s) cargas do monitoramento no Cockpit Logístico.
		
		IF nQtdFalhas > 0
			aAdd(aCabecalho,STR0079 + cValToChar(nQtdFalhas)+CRLF) //"Registros que apresentaram falha no cancelamento: "
		EndIF
		IF (nTotalReg - nQtdFalhas) > 0
			aAdd(aCabecalho,STR0080 + cValToChar((nTotalReg - nQtdFalhas))+CRLF)
		EndIF
		aAdd(aCabecalho,STR0081 + cValToChar(nTotalReg)+CRLF) //"Total de registros processados: "
		
		//Monta array do resumo
		aEval(aCabecalho,{|x|Aadd(aResumo,x)})
		aEval(aFalhas,{|x|Aadd(aResumo,x)})
		aEval(aEnviados,{|x|Aadd(aResumo,x)})
		If !lIsBlind
			//Apresenta resumo do envio
			OmsShowWng(aResumo)
			OsLogCPL("OMSXCPL7 -> ProcCanMon -> Mensagem de resumo do envio: " + VarInfo("aResumo: ",aResumo),"INFO")
		EndIf
	Endif
Return lRet
