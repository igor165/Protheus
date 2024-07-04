#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF60.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"

Static cTMSOPdg := SuperGetMV( 'MV_TMSOPDG',, '0' )
Static lTMS3GFE := TmsIntGFE('02')
Static lIncMot  := .F.
Static lTmsRdpU	:= SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho
Static lTmsRRE  := SuperGetMv("MV_TMSRRE",.F.,"") == "3"	//-- 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
Static aVeiVia  := {}
Static aMotVia  := {}

Static cFilFilDoc := Space(TamSX3("DT6_FILDOC")[1])
Static cFilDoc    := Space(TamSX3("DT6_DOC")[1])
Static cFilSerie  := Space(TamSX3("DT6_SERIE")[1])
Static cFilFilMan := Space(TamSX3("DTX_FILMAN")[1])
Static cFilManife := Space(TamSX3("DTX_MANIFE")[1])
Static cFilFilOri := Space(TamSX3("DTY_FILORI")[1])
Static cFilNumCTC := Space(TamSX3("DTY_NUMCTC")[1])
Static cFilPlaca  := Space(TamSX3("DA3_PLACA")[1])
Static cFilCodMot := Space(TamSX3("DA4_COD")[1])
Static lPrimeiro  := .T.
Static oBrowseUp	:= Nil
Static oBrowseDM3	:= Nil
Static oBrowseDTX	:= Nil
Static oBrowseDTW	:= Nil
Static oBrowseDUA	:= Nil
Static oBrowseDTY	:= Nil
Static oBrowseDFV	:= Nil
Static oRelacDM3	:= Nil
Static oRelacDTX	:= Nil
Static oRelacDTW	:= Nil
Static oRelacDUA	:= Nil
Static oRelacDTY	:= Nil
Static oRelacDFV	:= Nil
Static lIntTPR      := SuperGetMV("MV_ROTAINT",,.F.) .And. AliasInDic("DMR")
Static lTmf60Doc  := ExistBlock("TMF60Doc")				//-- Ponto de entrada para inclusão de itens no submenu documentos embarcados

/*{Protheus.doc} TMSAF60
    Viagem Modelo 3
    @type Function
    @author Valdemar Roberto Mognon
    @since 23/05/2020
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAF60()
    (examples)
    @see (links_or_references)
*/
Function TMSAF60()
Local cPerg     := "TMSAF60"
Local aCoors    := FWGetDialogSize( oMainWnd )   
Local aSetKey   := {}
Local oPanelUp,oPanelDwn,oPnlCol1,oPnlCol2,oPnlCol3,oPnlCol4,oPnlCol5:= Nil
Local oFWLayerUp,oFWLayerDwn:= Nil
Local oButton1,oButton2:= Nil
Local aFolders  := {}
Local aSelVeic	:= {}
Local cRoteiri  := ""
Local nCntFor1	:= 0

Private oDlgPrinc  := Nil 
Private oFolder    := Nil

If lIntTPR .And. FindFunction('TMSROTEIRI') .And. FindFunction('T146VgeTPR')
	cRoteiri:= TMSROTEIRI() 
	lIntTPR:= cRoteiri == '2'   //1-Maplink, 2-TPR
EndIf

Aadd( aSetKey, { VK_F12, { || Pergunte( cPerg, .T. ) } } )

TmsKeyOn(aSetKey)

	// Trata a altura da janela de acordo com a resolução
	DEFINE MSDIALOG oDlgPrinc TITLE STR0001 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL
	
	// Cria conteiner para os browses
	oFWLayerUp:= FWLayer():New()
	oFWLayerUp:Init( oDlgPrinc, .F., .T.)

	// Define painel Master
	oFWLayerUp:AddLine("UP",20,.F.)	//-- Adiciona linha superior (campos de filtros)
	oFWLayerUp:AddLine("MIDDLE",35,.F.)		//-- Adiciona linha mediana (browse dos lotes)
	oFWLayerUp:AddLine("DOWN",45,.F.)	//-- Adiciona linha inferior (browses inferiores)

	//-- Cria as janelas de filtro
	oFWLayerUp:AddCollumn("COLUMN1",23,.T.,"UP")
	oFWLayerUp:AddCollumn("COLUMN2",23,.T.,"UP")
	oFWLayerUp:AddCollumn("COLUMN3",23,.T.,"UP")
	oFWLayerUp:AddCollumn("COLUMN4",23,.T.,"UP")
	oFWLayerUp:AddCollumn("COLUMN5",08,.T.,"UP")
	
	oFWLayerUp:AddWindow("COLUMN1","WINDOW1","Documento",100,.F.,.T.,,"UP",{||})	//-- "Documento"
	oFWLayerUp:AddWindow("COLUMN2","WINDOW2","Manifesto",100,.F.,.T.,,"UP",{||})	//-- "Manifesto"
	oFWLayerUp:AddWindow("COLUMN3","WINDOW3","Contrato" ,100,.F.,.T.,,"UP",{||})	//-- "Contrato"
	oFWLayerUp:AddWindow("COLUMN4","WINDOW4","Recursos" ,100,.F.,.T.,,"UP",{||})	//-- "Recursos"
	oFWLayerUp:AddWindow("COLUMN5","WINDOW5","Ações"    ,100,.F.,.T.,,"UP",{||})	//-- "Ações"
	
	oFWLayerUp:SetLinSplit("UP",CONTROL_ALIGN_BOTTOM,{||UpdFolder(oFolder,oPanelDwn)})
	
	oFWLayerUp:ClickLineSplit("UP")// Simula o Click para esconder o LayerUp

	oPnlCol1 := oFWLayerUp:GetWinPanel("COLUMN1","WINDOW1","UP")
	oPnlCol2 := oFWLayerUp:GetWinPanel("COLUMN2","WINDOW2","UP")
	oPnlCol3 := oFWLayerUp:GetWinPanel("COLUMN3","WINDOW3","UP")
	oPnlCol4 := oFWLayerUp:GetWinPanel("COLUMN4","WINDOW4","UP")
	oPnlCol5 := oFWLayerUp:GetWinPanel("COLUMN5","WINDOW5","UP")

	//-- Filtros do CTe
	TSay():New(003,001,{||"Fil Docto : "},oPnlCol1,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Fil Docto : "
	TSay():New(003,073,{||"Docto : "}    ,oPnlCol1,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Docto : "
	TSay():New(018,001,{||"Série : "}    ,oPnlCol1,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Série : "
	TGet():New(003,027,{|u| Iif(PCount() > 0,cFilFilDoc := u,cFilFilDoc)},oPnlCol1,015,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SM0","cFilFilDoc")
	TGet():New(003,093,{|u| Iif(PCount() > 0,cFilDoc    := u,cFilDoc)}   ,oPnlCol1,048,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,     ,"cFilDoc")
	TGet():New(018,019,{|u| Iif(PCount() > 0,cFilSerie  := u,cFilSerie)} ,oPnlCol1,020,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,     ,"cFilSerie")

	//-- Filtros do Manifesto
	TSay():New(003,001,{||"Fil Origem : "},oPnlCol2,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Fil Origem : "
	TSay():New(018,001,{||"Manifesto : "} ,oPnlCol2,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Manifesto : "
	TGet():New(003,030,{|u| Iif(PCount() > 0,cFilFilMan := u,cFilFilMan)},oPnlCol2,015,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SM0","cFilFilMan")
	TGet():New(018,030,{|u| Iif(PCount() > 0,cFilManife := u,cFilManife)},oPnlCol2,048,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,     ,"cFilManife")

	//-- Filtros do Contrato
	TSay():New(003,001,{||"Fil Origem : "},oPnlCol3,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Fil Origem : "
	TSay():New(018,001,{||"Contrato : "}  ,oPnlCol3,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Contrato : "
	TGet():New(003,030,{|u| Iif(PCount() > 0,cFilFilOri := u,cFilFilOri)},oPnlCol3,015,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SM0","cFilFilOri")
	TGet():New(018,028,{|u| Iif(PCount() > 0,cFilNumCTC := u,cFilNumCTC)},oPnlCol3,048,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,     ,"cFilNumCTC")

	//-- Filtros dos Recursos
	TSay():New(003,001,{||"Placa : "}    ,oPnlCol4,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Placa : "
	TSay():New(018,001,{||"Motorista : "},oPnlCol4,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Motorista : "
	TGet():New(003,020,{|u| Iif(PCount() > 0,cFilPlaca := u,cFilPlaca)}  ,oPnlCol4,015,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"DTU","cFilPlaca")
	TGet():New(018,028,{|u| Iif(PCount() > 0,cFilCodMot := u,cFilCodMot)},oPnlCol4,048,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"DTO","cFilCodMot")

	nSelVeic := 1
	aSelVeic := {"Tracionador","Reboques"} //'Tracionador'###'Reboques'
	
	oRadio := TRadMenu():New(000,085,aSelVeic,,oPnlCol4,,,,,,,,080,008,,,,.F.)
	oRadio:bSetGet := {|u|Iif (PCount()==0,nSelVeic,nSelVeic:=u)}

	//-- Botões de Filtro e Limpeza
	oButton1 := TButton():New(003,002,"&Filtrar",oPnlCol5,{|| TMSAF60Fil()},040,013,,,,.T.,,"",,,,.F.)	//-- "&Filtrar"
	oButton2 := TButton():New(018,002,"&Limpar" ,oPnlCol5,{|| TMSAF60Cle()},040,013,,,,.T.,,"",,,,.F.)	//-- "&Limpar"

	//-- Browse superior vinculado com estrutura oPanelUp criada
	oPanelUp  := oFWLayerUp:GetLinePanel("MIDDLE")	//-- Acidiona o browse das viagens
	oBrowseUp := FWMBrowse():New()
	oBrowseUp:SetOwner(oPanelUp)
	oBrowseUp:SetDescription( STR0002 )  //Viagem
	oBrowseUp:SetAlias('DTQ')
	oBrowseUp:SetMenuDef( 'TMSAF60' )
	oBrowseUp:DisableDetails() 
	oBrowseUp:SetProfileID('DTQ')
	oBrowseUp:ForceQuitButton()
	oBrowseUp:SetFixedBrowse(.T.)
	oBrowseUp:AddLegend( "DTQ_STATUS=='1'", "GREEN"	 , STR0011 	) //-- Em Aberto
	oBrowseUp:AddLegend( "DTQ_STATUS=='5'", "RED"	 , STR0012  ) //-- Fechada
	oBrowseUp:AddLegend( "DTQ_STATUS=='2'", "YELLOW" , STR0013  ) //-- Em Transito
	oBrowseUp:AddLegend( "DTQ_STATUS=='4'", "ORANGE" , STR0014  ) //-- Chegada em Filial.
	oBrowseUp:AddLegend( "DTQ_STATUS=='3'", "BLUE"	 , STR0015 	) //-- Encerrada
	oBrowseUp:AddLegend( "DTQ_STATUS=='9'", "BLACK"	 , STR0016 	) //-- Cancelada
	oBrowseUp:AddStatusColumns( {|| TF60BmpSrv()}, {|| TF60LegSrv()} )
	If FindFunction( "TMSAFretBr") .And. FindFunction("TMSAC13St") .AND. AliasIndic('DM1') .AND. AliasIndic('DM2')
		oBrowseUp:AddStatusColumns( {||TMSAC13St( DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM )}, {||TMSAC13Leg()} )
	EndIf
	If lIntTPR 
		oBrowseUp:AddStatusColumns( {||T146VgeTPR( DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM)}, {||TMSAC19Leg()} )
	EndIf
	oBrowseUp:SetFilterDefault("@" + MontaSQL())

	// Folders - Paineis Indicadores, Doctos Embarcados, Manifestos, Operacoes, Ocorrencias, Contrato Carreteiro
	aFolders  := {STR0046, STR0004, STR0038, STR0039, STR0017, STR0041, STR0044}    
	oPanelDwn := oFWLayerUp:GetLinePanel("DOWN")
	oFolder   := TFolder():New( 0, 0, aFolders,aFolders, oPanelDwn,,,, .T.,,oPanelDwn:NCLIENTWIDTH/2,oPanelDwn:NCLIENTHEIGHT/2)
	oFolder:bChange := {|nFolder| lCria := Nil, CriaBrow( nFolder, @lCria ), TF60AtuBrw(nFolder, lCria) }  //Atualiza Browse

	//-- Cria novo Layer para as pastas
	oFWLayerDwn := FWLayer():New()
	oFWLayerDwn:Init(oFolder:aDialogs[1], .F., .T.)

	//--  Browse Paineis
	If FindFunction('TMSPnlF60')
		cRet := TMSPnlF60("1")
		oPnlInd1 := TMSPainel():New(oFolder:aDialogs[1], STR0047, cRet,  {228, 3, 3},, 5,5) //"Viagens Entrega em trânsito"
		cRet := TMSPnlF60("2")
		oPnlInd2 := TMSPainel():New(oFolder:aDialogs[1], STR0048, cRet,  {50, 50, 205},, 120, 5) //"Viagens Transf. em trânsito"
		cRet := TMSPnlF60("3")
		oPnlInd3 :=TMSPainel():New(oFolder:aDialogs[1], STR0049, cRet,  {255, 165, 0},, 235, 5) //"Docs Embarcados" 
		cRet := TMSPnlF60("4")
		oPnlInd4 := TMSPainel():New(oFolder:aDialogs[1], STR0050, cRet,  {117, 7, 135},, 350, 5) //"Docs Entregues"
		cRet := TMSPnlF60("5")
		oPnlInd5 :=TMSPainel():New(oFolder:aDialogs[1], STR0051, cRet,  {50, 205, 50},, 465, 5) //"Coletas Embarcadas"
		cRet := TMSPnlF60("6")
		oPnlInd6 := TMSPainel():New(oFolder:aDialogs[1], STR0052 , cRet,  {35, 107, 142},, 580, 5) //"Coletas Efetuadas"
		cRet := TMSPnlF60("7")
		oPnlInd7 := TMSPainel():New(oFolder:aDialogs[1], STR0053 , cRet,  {255, 99, 71},, 695, 5) //"Coletas Canceladas" 
	EndIf 

	//--- Documentos Embarcados
	oBrowseDM3:= FWMBrowse():New()
	oBrowseDM3:SetAlias('DM3')
	oBrowseDM3:SetOwner(oFolder:aDialogs[2])
	oBrowseDM3:SetMenuDef('')

	If TmsExp()
		oBrowseDM3:AddButton(STR0027, {|| TMSAF64NFC(oBrowseDM3),oBrowseUp:Refresh(),oBrowseDM3:Refresh(),oBrowseDM3:GoTop(.T.)},,3,,.F. ) //NF Cliente 
	EndIf
	
	oBrowseDM3:AddButton(STR0040,{|| TMSA460() },,3,,.F.) //Sol.Coleta
	oBrowseDM3:AddButton(STR0042,{|| TMSAF60Vis() },,3,,.F.) //Vis.Docto.
	//-- Executa ponto de entrada para inclusão de itens no submenu "Documentos Embarcados" da viagem modelo 3
	If lTmf60Doc
		aRotUsu := ExecBlock("TMF60Doc",.F.,.F., { } )
		If ValType(aRotUsu) == "A"
			For nCntFor1 := 1 To Len(aRotUsu)
				&("oBrowseDM3:AddButton('" + aRotUsu[nCntFor1,1] + "',{|| " + aRotUsu[nCntFor1,2] + " },,3,,.F.)")
			Next nCntFor1
		EndIf
	EndIf

	oBrowseDM3:SetProfileID('DM3')
	oBrowseDM3:DisableDetails()
	oBrowseDM3:SetFixedBrowse(.T.)
	oBrowseDM3:AddLegend( "TF60DudStat(DM3_FILDOC,DM3_DOC,DM3_SERIE,DM3_FILORI,DM3_VIAGEM)=='1'", "GREEN",	STR0011	) //-- Em Aberto
	oBrowseDM3:AddLegend( "TF60DudStat(DM3_FILDOC,DM3_DOC,DM3_SERIE,DM3_FILORI,DM3_VIAGEM)=='2'", "YELLOW",	STR0013	) //-- Em Transito
	oBrowseDM3:AddLegend( "TF60DudStat(DM3_FILDOC,DM3_DOC,DM3_SERIE,DM3_FILORI,DM3_VIAGEM)=='3'", "RED",	STR0028	) //-- Carregado
	oBrowseDM3:AddLegend( "TF60DudStat(DM3_FILDOC,DM3_DOC,DM3_SERIE,DM3_FILORI,DM3_VIAGEM)=='4'", "BLUE",	STR0015	) //-- Encerrada
	oBrowseDM3:AddLegend( "TF60DudStat(DM3_FILDOC,DM3_DOC,DM3_SERIE,DM3_FILORI,DM3_VIAGEM)=='9'", "BLACK",	STR0016	) //-- Cancelada

	If FindFunction("TF68StaCTE")
		oBrowseDM3:AddStatusColumns({||TF68StaCTE(DM3->DM3_FILDOC,DM3->DM3_DOC,DM3->DM3_SERIE)},{||TF68LegCTE()})
		oBrowseDM3:AddStatusColumns({||TF68AvbCTE(DM3->DM3_FILDOC,DM3->DM3_DOC,DM3->DM3_SERIE)},{||TF68LegAVB()})
	EndIf
	
	oBrowseDM3:SetDescription(STR0004) // Documentos Embarcados
	oBrowseDM3:Activate()

	oRelacDM3 := FWBrwRelation():New()
	oRelacDM3 :AddRelation(oBrowseUp,oBrowseDM3,{{"DM3_FILIAL","xFilial('DM3')" },{"DM3_FILORI","DTQ_FILORI"},{"DM3_VIAGEM","DTQ_VIAGEM"}} )
	oRelacDM3 :Activate()

	DTQ->(DbSetOrder(1))
	oBrowseUp:Activate()

ACTIVATE MSDIALOG oDlgPrinc CENTER 

lPrimeiro := .F.

TmsKeyOff(aSetKey)

Zera()

Return

/*{Protheus.doc} ModelDef
    Definição do Modelo
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 23/05/2020
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function ModelDef()
Local oModel
Local oStruDTQ  := FwFormStruct(1,"DTQ")
Local oStruDMB  := Nil
Local oStruDM3  := FwFormStruct(1,"DM3")
Local oStruDM4  := FwFormStruct(1,"DM4")
Local oStruDM5  := FwFormStruct(1,"DM5")
Local oStruDTR  := FwFormStruct(1,"DTR")
Local oStruDUP  := FwFormStruct(1,"DUP")
Local oStruDUQ  := FwFormStruct(1,"DUQ")
Local oStruDVB  := FwFormStruct(1,"DVB")
Local oStruSDG  := Nil
Local oStruDVW  := FwFormStruct(1,"DVW")
Local oStruDLD  := FwFormStruct(1,"DLD")
Local oStruDM8  := FwFormStruct(1,"DM8")
Local oStruDJN  := FwFormStruct(1,"DJN")
Local oStruDYD  := FwFormStruct(1,"DYD")
Local oStruDJA  := FwFormStruct(1,"DJA")
Local bLinPreDM3 := {|oModel,nLine,cAction,cIDField,xValue,xCurrentValue| TMSAF63(oModel,nLine,cAction,cIDField,xValue,xCurrentValue,"PRE")}
Local bLinPreDTR := {|oModel,nLine,cAction,cIDField,xValue,xCurrentValue| TMSAF63(oModel,nLine,cAction,cIDField,xValue,xCurrentValue,"PRE")}
Local bLinPreDUP := {|oModel,nLine,cAction,cIDField,xValue,xCurrentValue| TMSAF63(oModel,nLine,cAction,cIDField,xValue,xCurrentValue,"PRE")}
Local bLinPreDVW := {|oModel,nLine,cAction,cIDField,xValue,xCurrentValue| TMSAF63(oModel,nLine,cAction,cIDField,xValue,xCurrentValue,"PRE")}
Local bLinPreDLD := {|oModel,nLine,cAction,cIDField,xValue,xCurrentValue| TMSAF63(oModel,nLine,cAction,cIDField,xValue,xCurrentValue,"PRE")}
Local bLinPreSDG := {|oModel,nLine,cAction,cIDField,xValue,xCurrentValue| TMSAF63(oModel,nLine,cAction,cIDField,xValue,xCurrentValue,"PRE")}
Local bLinPreGFE := {|oModel,nLine,cAction,cIDField,xValue,xCurrentValue| TMSAF63G(oModel,nLine,cAction,cIDField,xValue,xCurrentValue,"PRE")}
Local bLinPosDM3 := {|oModel,nLine,cAction,cIDField| TMSAF63(oModel,nLine,cAction,cIDField,,,"POS")} 
Local bLinPosDTR := {|oModel,nLine,cAction,cIDField| TMSAF63(oModel,nLine,cAction,cIDField,,,"POS")} 
Local bLinPosDUP := {|oModel,nLine,cAction,cIDField| TMSAF63(oModel,nLine,cAction,cIDField,,,"POS")}
Local bLinPosDVW := {|oModel,nLine,cAction,cIDField| TMSAF63(oModel,nLine,cAction,cIDField,,,"POS")}
Local bLinPosDUQ := {|oModel,nLine,cAction,cIDField| TMSAF63(oModel,nLine,cAction,cIDField,,,"POS")}
Local bLinPosDLD := {|oModel,nLine,cAction,cIDField| TMSAF63(oModel,nLine,cAction,cIDField,,,"POS")}
Local bPosVldSDG := {|oModel,nLine,cAction,cIDField| TMSAF63(oModel,nLine,cAction,cIDField,,,"POS")}
Local bLinPosGFE := {|oModel,nLine,cAction,cIDField| TMSAF63G(oModel,nLine,cAction,cIDField,,,"POS")}
Local bPosVldDTQ := {|oModel| TMSAF64(oModel,"POS")}
Local bCommitDTQ := {|oModel| TMSAF67(oModel,.T.)}
Local bCancel    := {|oModel| TMSAF67(oModel,.F.)}
Local cNoFldSDG	 := NoFieldsSDG(1)
Local cPerg      := "TMSAF60"
             
If AliasInDic("DMB")
	oStruDMB := FwFormStruct(1,"DMB")
EndIf

Pergunte(cPerg,.F.)

//-- Estrutura SDG 
oStruSDG	:= FWFormStruct(1,"SDG",{|cCampo| !(AllTrim(cCampo) + "|" $ cNoFldSDG ) } )

//-- Remove campos das Model
RemoveFld(oStruDTQ,{"DTQ_DATFEC","DTQ_HORFEC","DTQ_DATENC","DTQ_HORENC","DTQ_CODCAN","DTQ_OBSCAN","DTQ_CUSTO1",;
					 "DTQ_CUSTO2","DTQ_CUSTO3","DTQ_CUSTO4","DTQ_CUSTO5","DTQ_QTDPER","DTQ_OK",;
					 "DTQ_IDENT" ,"DTQ_RTAORI","DTQ_RTOORI","DTQ_IDPG","DTQ_IDPDG",;
					 "DTQ_TIPMON","DTQ_STROTE"})

If cTMSOPdg == '0'
	RemoveFld(oStruDTQ,{"DTQ_IDOPE" ,"DTQ_IDCLI" })
EndIf					 

If !AliasInDic("DMB")
	RemoveFld(oStruDTQ,{"DTQ_CODAUT"})
EndIf

If !lTMS3GFE .And. !lTmsRdpU
	RemoveFld(oStruDTQ,{"DTQ_PAGGFE","DTQ_TIPVEI","DTQ_DESTIP","DTQ_CDTPOP","DTQ_DSTPOP","DTQ_CDCLFR","DTQ_DSCLFR",;
						"DTQ_UFORI" ,"DTQ_CDMUNO","DTQ_MUNORI","DTQ_CEPORI","DTQ_UFDES" ,"DTQ_CDMUND","DTQ_MUNDES",;
						"DTQ_CEPDES","DTQ_CHVEXT"})
Else
	RemoveFld(oStruDM8,{"DM8_FILORI","DM8_VIAGEM","DM8_FILDOC","DM8_DOC","DM8_SERIE"})
	RemoveFld(oStruDJN,{"DJN_FILORI","DJN_VIAGEM","DJN_FILDOC","DJN_DOC","DJN_SERIE"})
EndIf
RemoveFld(oStruDYD,{"DYD_NUMAGD","DYD_ITEAGD","DYD_MOTAGD","DYD_DTCAGD","DYD_USUAGD","DYD_NOMUSR","DYD_FILDOC","DYD_DOC",;   
"DYD_SERIE" ,"DYD_CLIREM","DYD_LOJREM","DYD_NOMREM","DYD_CLIDES","DYD_LOJDES","DYD_NOMDES","DYD_CDRORI",;
"DYD_CDRDES","DYD_FILORI","DYD_DATEMI","DYD_FILDES","DYD_DIAATR","DYD_DATREF"})

RemoveFld(oStruDTR,{"DTR_FILVGE","DTR_NUMVGE","DTR_DATINI","DTR_HORINI","DTR_DATFIM","DTR_HORFIM",;
                     "DTR_CODCPO","DTR_CODOPE","DTR_DESCPO","DTR_NOMOPE","DTR_OBS","DTR_OPERPC","DTR_QTDSAQ","DTR_QTDTRA",;
                     "DTR_TPSPDG" })

RemoveFld(oStruDUP,{"DUP_FILORI","DUP_VIAGEM","DUP_CODVEI","DUP_CODOPE","DUP_NOMOPE","DUP_EMVIAG","DUP_PAGDIA",;
                    "DUP_TPSPDG","DUP_QTDSAQ","DUP_QTDTRA"})

//-- Liberação RRE
If !lTmsRRE
	RemoveFld(oStruDTR,{"DTR_LIBRRE","DTR_INIRRE","DTR_FIMRRE"})
	RemoveFld(oStruDUP,{"DUP_LIBRRE","DUP_INIRRE","DUP_FIMRRE"})
EndIf

RemoveFld(oStruDVB,{"DVB_FILORI","DVB_VIAGEM","DVB_CODVEI"})

RemoveFld(oStruDVW,{"DVW_FILORI","DVW_VIAGEM"})

RemoveFld(oStruDLD,{"DLD_FILORI","DLD_VIAGEM","DLD_ITEDTR","DLD_CODVEI"})

//-- Fixa os Whens dos campos
FixWhen(oStruDVW,"TMSAF61('DVW')","DVW")
FixWhen(oStruDUP,"TMSAF61('DUP')","DUP")
FixWhen(oStruDTR,"TMSAF61('DTR')","DTR")
FixWhen(oStruDTQ,"TMSAF61('DTQ')","DTQ")

//-- Fixa os Valids dos campos
FixValid(oStruDVW,"TMSAF62('DVW')","DVW")
FixValid(oStruDUP,"TMSAF62('DUP')","DUP")
FixValid(oStruDTR,"TMSAF62('DTR')","DTR")
FixValid(oStruDTQ,"TMSAF62('DTQ')","DTQ")
FixValid(oStruDLD,"TMSAF62('DLD')","DLD")
FixValid(oStruSDG,"TMSAF62('SDG')","SDG")
FixValid(oStruDJN,"TMSAF62G('DJN')","DJN") 

//-- Altera estrutura dos campos
AltStruc(oStruDTQ,{{"DTQ_SERADI",{{3,"1"}}},;
                    {"DTQ_VIAGEM",{{3,RetX3()}}}})

AltStruc(oStruDVW,{{"DVW_VALOR" ,{{5,.T.}}},;
  					{"DVW_ORIGEM",{{3,"'TMSA240'"}}}   })

AltStruc(oStruSDG,{{"DG_DOC"		,{{5,.F.}}},;
					{"DG_BANCO"		,{{2,".T."}}},;
					{"DG_AGENCIA"	,{{2,".T."}}},;
					{"DG_NUMCON"	,{{2,".T."}}},;
					{"DG_NUMCHEQ"	,{{2,".T."}}},;
					{"DG_ORIGEM"	,{{3,"'DTR'"}}},;
					{"DG_CLVL"		,{{2,".F."}}},;
					{"DG_ITEMCTA"	,{{2,".F."}}},;
					{"DG_CONTA"		,{{2,".F."}}},;
					{"DG_CC"		,{{2,".F."}}},;
					{"DG_CLVL"		,{{2,".F."}}}})

//-- Monta gatilhos
MntTrigger(oStruDTQ,{{{"DTQ_TIPVIA"},{"DTQ_TIPVIA"}}})
MntTrigger(oStruDTQ,{{{"DTQ_SERTMS"},{"DTQ_DESSVT"}}})
MntTrigger(oStruDTQ,{{{"DTQ_ROTA"},{"DTQ_ROTA"}}})
MntTrigger(oStruDTQ,{{{"DTQ_TPOPVG"},{"DTQ_TPOPVG"}}})
MntTrigger(oStruDTQ,{{{"DTQ_PAGGFE"},{"DTQ_PAGGFE"}}})
If AliasInDic("DMB")
	MntTrigger(oStruDTQ,{{{"DTQ_CODAUT"},{"DTQ_CODAUT"}}})
EndIf

MntTrigger(oStruDM3,{{{"DM3_SEQUEN"},{"DM3_SEQUEN"}}})
MntTrigger(oStruDM3,{{{"DM3_FILDOC","DM3_DOC","DM3_SERIE"},{"DM3_SERIE"}}})

MntTrigger(oStruDTR,{{{"DTR_CODVEI"},{"DTR_CODVEI","DTR_QTDEIX","DTR_QTEIXV","DTR_VALFRE","DTR_LIBRRE","DTR_INIRRE","DTR_FIMRRE"}}})  
MntTrigger(oStruDTR,{{{"DTR_CODRB1"},{"DTR_QTDEIX","DTR_QTEIXV","DTR_VALFRE" }}})
MntTrigger(oStruDTR,{{{"DTR_CODRB2"},{"DTR_QTDEIX","DTR_QTEIXV","DTR_VALFRE" }}})
MntTrigger(oStruDTR,{{{"DTR_CODRB3"},{"DTR_QTDEIX","DTR_QTEIXV","DTR_VALFRE" }}})
MntTrigger(oStruDTR,{{{"DTR_QTDEIX"},{"DTR_VALFRE" }}})
MntTrigger(oStruDTR,{{{"DTR_QTEIXV"},{"DTR_VALFRE" }}})
MntTrigger(oStruDTR,{{{"DTR_FOROPE","DTR_LOJOPE"},{"DTR_CNPJOP"}}})
MntTrigger(oStruDTR,{{{"DTR_FORPDG","DTR_LOJPDG"},{"DTR_CNPJPG"}}})

MntTrigger(oStruDUP,{{{"DUP_CODMOT"},{"DUP_CODMOT","DUP_IDOPE","DUP_CONDUT","DUP_LIBRRE","DUP_INIRRE","DUP_FIMRRE"}}})

MntTrigger(oStruDM4,{{{"DM4_NUMVGE"},{"DM4_NUMVGE"}}})

MntTrigger(oStruSDG,{{{"DG_TOTAL"},{"DG_VALCOB","DG_CUSTO1","DG_CUSTO2","DG_CUSTO3","DG_CUSTO4","DG_CUSTO5","DG_VALBAI","DG_TOTAL"}}})
MntTrigger(oStruSDG,{{{"DG_CODDES"},{"DG_CLVL","DG_ITEMCTA","DG_CONTA","DG_CC","DG_BANCO","DG_AGENCIA","DG_NUMCON","DG_TOTAL","DG_VALBAI","DG_VALCOB","DG_SALDO"}}})
MntTrigger(oStruSDG,{{{"DG_VALCOB"},{"DG_VALBAI","DG_SALDO"}}})

oModel := MpFormModel():New("TMSAF60", /*bPreValidacao*/, bPosVldDTQ , bCommitDTQ , bCancel )

oModel:SetDescription(STR0002)	//-- Viagem

//-- Cabeçalho da Viagem
oModel:AddFields("MdFieldDTQ",,oStruDTQ,,,)
oModel:SetPrimaryKey({"DTQ_FILORI","DTQ_VIAGEM"})
oModel:GetModel("MdFieldDTQ"):SetDescription(STR0002)	//-- Viagem
oStruDTQ:SetProperty("DTQ_ROTA",MODEL_FIELD_OBRIGAT,.T.)
oStruDTQ:SetProperty("DTQ_DATGER",MODEL_FIELD_INIT,{||dDataBase})
oStruDTQ:SetProperty("DTQ_HORGER",MODEL_FIELD_INIT,{|| TMSAF66("DTQ_HORGER")})					
oStruDM3:SetProperty( "DM3_ORIGEM", MODEL_FIELD_INIT, { | | TMSAFIniD( "DM3_ORIGEM" ) } )
oStruDUP:SetProperty("DUP_ITEDTR",MODEL_FIELD_INIT,{|| TMSAF66("DUP_ITEDTR")})

If lIncMot	//-- Inclusão de condutor
	oModel:GetModel("MdFieldDTQ"):SetOnlyView(.T.)
EndIf

//-- Grid das Configurações de Automatização da Viagem
If AliasInDic("DMB")
	oModel:AddGrid("MdGridDMB","MdFieldDTQ",oStruDMB, /*bLinPre*/ , /*bLinPos*/ , /*bPre*/ ,  /*bPost*/, /*bLoad*/)
	oModel:SetRelation("MdGridDMB",{{"DMB_FILIAL","xFilial('DMB')"},;
									 {"DMB_FILORI","DTQ_FILORI"},;
									 {"DMB_VIAGEM","DTQ_VIAGEM"},;
									 {"DMB_CODAUT","DTQ_CODAUT"}},;
									 DMB->(IndexKey(1)))
	oModel:GetModel("MdGridDMB"):SetOptional(.T.)
	oModel:GetModel("MdGridDMB"):SetDescription(STR0037)	//-- Automatização
	oModel:GetModel("MdGridDMB"):SetUniqueLine({"DMB_ROTINA"})
	oModel:GetModel("MdGridDMB"):SetNoInsertLine(.T.)
	oModel:GetModel("MdGridDMB"):SetNoDeleteLine(.T.)
	If lIncMot	//-- Inclusão de condutor
		oModel:GetModel("MdGridDMB"):SetOnlyView(.T.)
	EndIf
EndIf

//-- Grid dos Documentos
oModel:AddGrid("MdGridDM3","MdFieldDTQ",oStruDM3, bLinPreDM3 , bLinPosDM3 , /*bPre*/ ,  /*bPost*/, /*bLoad*/)
oModel:SetRelation("MdGridDM3",{{"DM3_FILIAL","xFilial('DM3')"},;
								 {"DM3_FILORI","DTQ_FILORI"},;
								 {"DM3_VIAGEM","DTQ_VIAGEM"}},;
								 DM3->(IndexKey(2)))
oModel:GetModel("MdGridDM3"):SetOptional(.T.)
oModel:GetModel("MdGridDM3"):SetDescription(STR0003)	//-- Documentos
oModel:GetModel("MdGridDM3"):SetUniqueLine( { "DM3_FILDOC", "DM3_DOC",  "DM3_SERIE"} )
If lIncMot	//-- Inclusão de condutor
	oModel:GetModel("MdGridDM3"):SetOnlyView(.T.)
EndIf

//Agendamento de Entrada
oModel:AddGrid("MdGridDYD","MdGridDM3",oStruDYD,,,,,)
oModel:SetRelation("MdGridDYD",{{"DYD_FILIAL","xFilial('DYD')"},;
								{"DYD_FILDOC","DM3_FILDOC"},;
								{"DYD_DOC","DM3_DOC"},;
								{"DYD_SERIE","DM3_SERIE"}},;
								DYD->(IndexKey(2)))

oModel:GetModel('MdGridDYD'):SetOnlyView( .T. )
oModel:GetModel('MdGridDYD'):SetOnlyQuery ( .T. ) 
oModel:GetModel('MdGridDYD'):SetOptional(.T.)

//-- Cabeçalho dos Veículos
oModel:AddFields("MdFieldDM4","MdFieldDTQ",oStruDM4,,,)
oModel:SetRelation("MdFieldDM4",{{"DM4_FILIAL","xFilial('DM4')"},;
								  {"DM4_FILORI","DTQ_FILORI"},;
								  {"DM4_VIAGEM","DTQ_VIAGEM"}},;
								  DM4->(IndexKey(1)))
oModel:GetModel("MdFieldDM4"):SetDescription(STR0018)	//-- Veículos
If lIncMot	//-- Inclusão de condutor
	oModel:GetModel("MdFieldDM4"):SetOnlyView(.T.)
EndIf

//-- Cabeçalho das Operadoras de Frota
oModel:AddFields("MdFieldDM5","MdFieldDTQ",oStruDM5,,,)
oModel:SetRelation("MdFieldDM5",{{"DM5_FILIAL","xFilial('DM5')"},;
								  {"DM5_FILORI","DTQ_FILORI"},;
								  {"DM5_VIAGEM","DTQ_VIAGEM"}},;
								  DM5->(IndexKey(1)))
oModel:GetModel("MdFieldDM5"):SetOptional(.T.)
oModel:GetModel("MdFieldDM5"):SetDescription(STR0019)	//-- Operadoras de Frota
If lIncMot	//-- Inclusão de condutor
	oModel:GetModel("MdFieldDM5"):SetOnlyView(.T.)
EndIf

//-- Grid dos Veículos
oModel:AddGrid("MdGridDTR","MdFieldDM4",oStruDTR, bLinPreDTR /*bLinePre*/, bLinPosDTR , /*bPre*/ , /*bPost*/, /*bLoad*/)

oModel:SetRelation("MdGridDTR",{{"DTR_FILIAL","xFilial('DTR')"},;
								 {"DTR_FILORI","DTQ_FILORI"},;
								 {"DTR_VIAGEM","DTQ_VIAGEM"}},;
								 DTR->(IndexKey(1)))

oStruDTR:SetProperty('*', MODEL_FIELD_OBRIGAT,.F.)
oModel:GetModel( 'MdGridDTR' ):SetOptional( .T. )
oModel:GetModel( 'MdGridDTR' ):SetUniqueLine( { "DTR_CODVEI" } )
If lIncMot	//-- Inclusão de condutor
	oModel:GetModel("MdGridDTR"):SetOnlyView(.T.)
EndIf

//-- Grid dos Motoristas
oModel:AddGrid("MdGridDUP","MdGridDTR",oStruDUP,bLinPreDUP,bLinPosDUP,,,)
oModel:SetRelation("MdGridDUP",{{"DUP_FILIAL","xFilial('DUP')"},;
  								 {"DUP_FILORI","DTQ_FILORI"},;
								 {"DUP_VIAGEM","DTQ_VIAGEM"},;
	  							 {"DUP_ITEDTR","DTR_ITEM"},;
	  							 {"DUP_CODVEI","DTR_CODVEI"}},;
								 DUP->(IndexKey(1)))

oModel:GetModel( 'MdGridDUP' ):SetOptional( .T. )
oModel:GetModel( "MdGridDUP" ):SetUniqueLine({"DUP_CODMOT"})

//-- Grid dos Ajudantes
oModel:AddGrid("MdGridDUQ","MdGridDTR",oStruDUQ,,bLinPosDUQ,,,)
oModel:SetRelation("MdGridDUQ",{{"DUQ_FILIAL","xFilial('DUQ')"},;
  								 {"DUQ_FILORI","DTQ_FILORI"},;
								 {"DUQ_VIAGEM","DTQ_VIAGEM"},;
	  							 {"DUQ_CODVEI","DTR_CODVEI"},;
	  							 {"DUQ_ITEDTR","DTR_ITEM"}},;
								 DUQ->(IndexKey(1)))
oModel:GetModel("MdGridDUQ"):SetUniqueLine( { "DUQ_CODAJU" } )
oModel:GetModel("MdGridDUQ"):SetOptional( .T. )
If lIncMot	//-- Inclusão de condutor
	oModel:GetModel("MdGridDUQ"):SetOnlyView(.T.)
EndIf

//-- Grid dos Lacres
oModel:AddGrid("MdGridDVB","MdGridDTR",oStruDVB,,,,,)
oModel:SetRelation("MdGridDVB",{{"DVB_FILIAL","xFilial('DVB')"},;
  								 {"DVB_FILORI","DTQ_FILORI"},;
								 {"DVB_VIAGEM","DTQ_VIAGEM"},;
	  							 {"DVB_CODVEI","DTR_CODVEI"}},;
								 DVB->(IndexKey(1)))

oModel:GetModel( 'MdGridDVB' ):SetOptional( .T. )					
oModel:GetModel( "MdGridDVB" ):SetUniqueLine({"DVB_LACRE"})
If lIncMot	//-- Inclusão de condutor
	oModel:GetModel("MdGridDVB"):SetOnlyView(.T.)
EndIf

//-- Grid das Despesas da Viagem
oModel:AddGrid("MdGridSDG","MdGridDTR",oStruSDG,bLinPreSDG,bPosVldSDG,,,)
oModel:SetRelation("MdGridSDG",{{"DG_FILIAL","xFilial('SDG')"},;
  								 {"DG_FILORI","DTQ_FILORI"},;
								 {"DG_VIAGEM","DTQ_VIAGEM"},;
								 {"DG_CODVEI","DTR_CODVEI"}},;
								 SDG->(IndexKey(5)))

oModel:GetModel( 'MdGridSDG' ):SetOptional( .T. )
oModel:GetModel( "MdGridSDG" ):SetUniqueLine({"DG_CODDES"})
If lIncMot	//-- Inclusão de condutor
	oModel:GetModel("MdGridSDG"):SetOnlyView(.T.)
EndIf

//-- Grid do Valor Informado
oModel:AddGrid("MdGridDVW","MdFieldDTQ",oStruDVW,bLinPreDVW,bLinPosDVW,,,)
oModel:SetRelation("MdGridDVW",{{"DVW_FILIAL","xFilial('DVW')"},;
  								 {"DVW_FILORI","DTQ_FILORI"},;
								 {"DVW_VIAGEM","DTQ_VIAGEM"}},;
								 DVW->(IndexKey(1)))

oModel:GetModel( 'MdGridDVW' ):SetOptional( .T. )
oModel:GetModel( "MdGridDVW" ):SetUniqueLine({"DVW_CODPAS"})
If lIncMot	//-- Inclusão de condutor
	oModel:GetModel("MdGridDVW"):SetOnlyView(.T.)
EndIf

//-- Grid das Formas de Pagamento
If cTMSOPdg <> "0"
	oModel:AddGrid("MdGridDLD","MdGridDTR",oStruDLD,bLinPreDLD,bLinPosDLD,,,)
	oModel:SetRelation("MdGridDLD",{{"DLD_FILIAL","xFilial('DLD')"},;
									{"DLD_FILORI","DTQ_FILORI"},;
									{"DLD_VIAGEM","DTQ_VIAGEM"},;
									{"DLD_ITEDTR","DTR_ITEM"},;
								    {"DLD_CODVEI","DTR_CODVEI"}},;
									DLD->(IndexKey(1)))

	oModel:GetModel( 'MdGridDLD' ):SetOptional( .T. )
	oModel:GetModel( 'MdGridDLD' ):SetUniqueLine({"DLD_TIPPAR"} )
	
	If lIncMot	//-- Inclusão de condutor
		oModel:GetModel("MdGridDLD"):SetOnlyView(.T.)
	EndIf
EndIf

//Integração TMS x GFE
If lTMS3GFE .Or. lTmsRdpU
	//--- Continuação Documentos	
	oModel:AddGrid("MdGridDM8","MdGridDM3",oStruDM8,bLinPreGFE,bLinPosGFE,,,)
	oModel:SetRelation("MdGridDM8",{{"DM8_FILIAL","xFilial('DM8')"},;
									{"DM8_FILDOC","DM3_FILDOC"},;
									{"DM8_DOC","DM3_DOC"},;
									{"DM8_SERIE","DM3_SERIE"},;
									{"DM8_FILORI","DTQ_FILORI"},;
									{"DM8_VIAGEM","DTQ_VIAGEM"}},;
									DM8->(IndexKey(1)))

	oModel:GetModel( 'MdGridDM8' ):SetOptional( .T. )
	oModel:GetModel( 'MdGridDM8' ):SetNoInsertLine(.T.)

	//--- Redespacho Adicional
	oModel:AddGrid("MdGridDJN","MdGridDM3",oStruDJN,bLinPreGFE,bLinPosGFE,,,)
	oModel:SetRelation("MdGridDJN",{{"DJN_FILIAL","xFilial('DJN')"},;
									{"DJN_FILORI","DTQ_FILORI"},;
									{"DJN_VIAGEM","DTQ_VIAGEM"},;
									{"DJN_FILDOC","DM3_FILDOC"},;
									{"DJN_DOC","DM3_DOC"},;
									{"DJN_SERIE","DM3_SERIE"}},;
									DJN->(IndexKey(1)))
									

	oModel:GetModel( 'MdGridDJN' ):SetOptional( .T. )
	oModel:GetModel( 'MdGridDJN' ):SetUniqueLine( { "DJN_CODFOR", "DJN_LOJFOR" } )	

EndIf

//-- Liberação RRE
oModel:AddGrid("MdGridDJA","MdFieldDTQ",oStruDJA,,,,,)
oModel:SetRelation("MdGridDJA",{{"DJA_FILIAL","xFilial('DJA')"},;
  								 {"DJA_FILORI","DTQ_FILORI"},;
								 {"DJA_VIAGEM","DTQ_VIAGEM"}},;
								 DJA->(IndexKey(1)))
oModel:GetModel("MdGridDJA"):SetOptional(.T.)

oModel:AddCalc( "AF60CAL1", "MdFieldDTQ", "MdGridDM3", "DM3_QTDVOL"   , "DM3_QTDVOL"	, 'SUM',,, RetTitle("DM3_QTDVOL") )  // "Volume"
oModel:AddCalc( "AF60CAL1", "MdFieldDTQ", "MdGridDM3", "DM3_VOLORI"   , "DM3_VOLORI"	, 'SUM',,, RetTitle("DM3_VOLORI")  )// "Volume"
oModel:AddCalc( "AF60CAL1", "MdFieldDTQ", "MdGridDM3", "DM3_PESO"     , "DM3_PESO"	    , 'SUM',,, RetTitle("DM3_PESO")  ) // "Volume"
oModel:AddCalc( "AF60CAL1", "MdFieldDTQ", "MdGridDM3", "DM3_PESOM3"   , "DM3_PESOM3"	, 'SUM',,, RetTitle("DM3_PESOM3")  ) // "Volume"
oModel:AddCalc( "AF60CAL1", "MdFieldDTQ", "MdGridDM3", "DM3_VALMER"   , "DM3_VALMER"	, 'SUM',,, RetTitle("DM3_VALMER")  ) // "Volume"

oModel:SetVldActivate({|oModel| TMSAF64(oModel,'VLD')})

oModel:SetActivate({|oModel| TMSAF64(oModel,"ACT")})

Return oModel

/*{Protheus.doc} ViewDef
    Definição da View
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 23/05/2020
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ViewDef()
    (examples)
    @see (links_or_references)
*/
Static Function ViewDef()
Local oModel    := FwLoadModel("TMSAF60")
Local oView
Local oStruDTQ  := FwFormStruct(2,"DTQ")
Local oStruDMB  := Nil
Local oStruDM3  := FwFormStruct(2,"DM3")
Local oStruDM4  := FwFormStruct(2,"DM4")
Local oStruDM5  := FwFormStruct(2,"DM5")
Local oStruDTR  := FwFormStruct(2,"DTR")
Local oStruDUP  := FwFormStruct(2,"DUP")
Local oStruDUQ  := FwFormStruct(2,"DUQ")
Local oStruDVB  := FwFormStruct(2,"DVB")
Local oStruSDG  := Nil 
Local oStruDVW  := FwFormStruct(2,"DVW")
Local oStruDLD  := FwFormStruct(2,"DLD")
Local oStruDM8  := FwFormStruct(2,"DM8")
Local oStruDJN  := FwFormStruct(2,"DJN")
Local oStruDYD  := FwFormStruct(2,"DYD")
Local oCalc1	:= FWCalcStruct( oModel:GetModel( "AF60CAL1" ) )
Local cNoFldSDG	:= ""

If AliasInDic("DMB")
	oStruDMB := FwFormStruct(2,"DMB")
EndIf

//-- Remove campos das Views
RemoveFld(oStruDTQ,{"DTQ_DATFEC","DTQ_HORFEC","DTQ_DATENC","DTQ_HORENC","DTQ_CODCAN","DTQ_OBSCAN","DTQ_FILATU","DTQ_FILDES","DTQ_CUSTO1",;
					 "DTQ_CUSTO2","DTQ_CUSTO3","DTQ_CUSTO4","DTQ_CUSTO5","DTQ_QTDPER","DTQ_DATINI","DTQ_HORINI","DTQ_DATFIM","DTQ_HORFIM","DTQ_OK",;
					 "DTQ_IDENT" ,"DTQ_STATUS","DTQ_RTAORI","DTQ_RTOORI","DTQ_IDPG","DTQ_IDPDG","DTQ_TIPMON","DTQ_STROTE",;
					 "DTQ_CODOBS"})

If cTMSOPdg == '0'
	RemoveFld(oStruDTQ,{"DTQ_IDOPE" ,"DTQ_IDCLI" })
EndIf					 

If !AliasInDic("DMB")
	RemoveFld(oStruDTQ,{"DTQ_CODAUT"})
EndIf

If !lTMS3GFE .And. !lTmsRdpU
	RemoveFld(oStruDTQ,{"DTQ_PAGGFE","DTQ_TIPVEI","DTQ_DESTIP","DTQ_CDTPOP","DTQ_DSTPOP","DTQ_CDCLFR","DTQ_DSCLFR",;
						"DTQ_UFORI" ,"DTQ_CDMUNO","DTQ_MUNORI","DTQ_CEPORI","DTQ_UFDES" ,"DTQ_CDMUND","DTQ_MUNDES",;
						"DTQ_CEPDES","DTQ_CHVEXT"})
Else
	RemoveFld(oStruDM8,{"DM8_FILORI","DM8_VIAGEM","DM8_FILDOC","DM8_DOC","DM8_SERIE"})
	RemoveFld(oStruDJN,{"DJN_FILORI","DJN_VIAGEM","DJN_FILDOC","DJN_DOC","DJN_SERIE"})
EndIf

RemoveFld(oStruDYD,{"DYD_NUMAGD","DYD_ITEAGD","DYD_MOTAGD","DYD_DTCAGD","DYD_USUAGD","DYD_NOMUSR","DYD_FILDOC","DYD_DOC",;   
"DYD_SERIE" ,"DYD_CLIREM","DYD_LOJREM","DYD_NOMREM","DYD_CLIDES","DYD_LOJDES","DYD_NOMDES","DYD_CDRORI",;
"DYD_CDRDES","DYD_FILORI","DYD_DATEMI","DYD_FILDES","DYD_DIAATR","DYD_DATREF"})

oStruDYD:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)

RemoveFld(oStruDUP,{"DUP_FILORI","DUP_VIAGEM","DUP_CODVEI","DUP_CODOPE","DUP_NOMOPE","DUP_EMVIAG","DUP_PAGDIA",;
                    "DUP_TPSPDG","DUP_QTDSAQ","DUP_QTDTRA"})

RemoveFld(oStruDUQ,{"DUQ_FILORI","DUQ_VIAGEM","DUQ_ITEDTR","DUQ_CODVEI"})

RemoveFld(oStruDVB,{"DVB_FILORI","DVB_VIAGEM","DVB_CODVEI"})

RemoveFld(oStruDVW,{"DVW_FILORI","DVW_VIAGEM","DVW_TIPUSO","DVW_IDENT","DVW_ORIGEM"})
RemoveFld(oStruDLD,{"DLD_FILORI","DLD_VIAGEM","DLD_ITEDTR","DLD_CODVEI"})

RemoveFld(oStruDM4,{"DM4_FILORI","DM4_VIAGEM" })

RemoveFld(oStruDTR,{"DTR_FILORI","DTR_VIAGEM","DTR_FILVGE","DTR_NUMVGE","DTR_DATINI","DTR_HORINI","DTR_DATFIM","DTR_HORFIM",;
                     "DTR_CODCPO","DTR_CODOPE","DTR_DESCPO","DTR_NOMOPE","DTR_OBS","DTR_OPERPC","DTR_QTDSAQ","DTR_QTDTRA","DTR_REBTRF",;
                     "DTR_TPSPDG","DTR_TMPVGE" })
//-- Liberação RRE
If !lTmsRRE
	RemoveFld(oStruDTR,{"DTR_LIBRRE","DTR_INIRRE","DTR_FIMRRE"})
	RemoveFld(oStruDUP,{"DUP_LIBRRE","DUP_INIRRE","DUP_FIMRRE"})
EndIf

//---------------------------
//-- Estrutura SDG 
//----------------------------
cNoFldSDG	:= NoFieldsSDG(2)
oStruSDG	:= FWFormStruct(2,"SDG",{|cCampo| !(AllTrim(cCampo) + "|" $ cNoFldSDG ) } )
oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define a tela principal
oView:CreateHorizontalBox("Tela",100)

//-- Cria os Folders da tela principal
oView:CreateFolder("Folder1","Tela")

oView:AddSheet("Folder1","Sheet1_Folder1",STR0002)	//-- Viagem
oView:AddSheet("Folder1","Sheet2_Folder1",STR0036)	//-- Recursos
If AliasInDic("DMB")
	oView:AddSheet("Folder1","Sheet3_Folder1",STR0037)	//-- Automatização
EndIf

//-- Define os Boxes da tela principal
If lTMS3GFE .Or. lTmsRdpU
	oView:CreateHorizontalBox("BoxViagemSup",030,,,"Folder1","Sheet1_Folder1")
	oView:CreateHorizontalBox("BoxViagemInf",037,,,"Folder1","Sheet1_Folder1")
	oView:CreateHorizontalBox("BoxViagemGFE",025,,,"Folder1","Sheet1_Folder1")
	oView:CreateHorizontalBox( "TOTAIS"	, 8 ,,,"Folder1","Sheet1_Folder1"  )
Else
	oView:CreateHorizontalBox("BoxViagemSup",040,,,"Folder1","Sheet1_Folder1")
	oView:CreateHorizontalBox("BoxViagemInf",050,,,"Folder1","Sheet1_Folder1")
	oView:CreateHorizontalBox( "TOTAIS"	, 10 ,,,"Folder1","Sheet1_Folder1"  )
EndIf


oView:CreateFolder("Folder6","BoxViagemInf")
oView:AddSheet("Folder6","Sheet1_Folder6",STR0004) //Documentos Embarcados
oView:CreateHorizontalBox("BoxDoctos",100,,,"Folder6","Sheet1_Folder6")
oView:CreateVerticalBox("VERTICAL1",3,"BoxDoctos",.F.,"Folder6","Sheet1_Folder6")
oView:CreateVerticalBox("VERTICAL2",97,"BoxDoctos",.F.,"Folder6","Sheet1_Folder6")

oView:AddSheet("Folder6","Sheet2_Folder6",STR0032)  //Agendamento de Entrega
oView:CreateHorizontalBox("BoxViagemDYD",100,,,"Folder6","Sheet2_Folder6")

//-- Define os Boxes da tela de recursos
oView:CreateHorizontalBox("BoxRecursosSup",035,,,"Folder1","Sheet2_Folder1")
oView:CreateHorizontalBox("BoxRecursosMid",030,,,"Folder1","Sheet2_Folder1")
oView:CreateHorizontalBox("BoxRecursosInf",035,,,"Folder1","Sheet2_Folder1")

//-- Define o Box da tela de automatizações
If AliasInDic("DMB")
	oView:CreateHorizontalBox("BoxAutomatiza",100,,,"Folder1","Sheet3_Folder1")
EndIf

//-- Cria os Folders da tela superior dos recursos
oView:CreateFolder("Folder3","BoxRecursosSup")

oView:AddSheet("Folder3","Sheet1_Folder3","Planejamento")
oView:AddSheet("Folder3","Sheet2_Folder3","Operadoras")

//-- Define os Boxes da tela superior dos recursos
oView:CreateHorizontalBox("BoxRecursosDM4",100,,,"Folder3","Sheet1_Folder3")
oView:CreateHorizontalBox("BoxRecursosDM5",100,,,"Folder3","Sheet2_Folder3")

//-- Cria os Folders da tela inferior dos recursos
oView:CreateFolder("Folder2","BoxRecursosInf")

oView:AddSheet("Folder2","Sheet1_Folder2","Motoristas")
oView:AddSheet("Folder2","Sheet2_Folder2","Ajudantes")
oView:AddSheet("Folder2","Sheet3_Folder2","Lacres")
oView:AddSheet("Folder2","Sheet4_Folder2","Despesas")
oView:AddSheet("Folder2","Sheet5_Folder2","Valor Inf.")
If cTMSOPdg <> "0"
	oView:AddSheet("Folder2","Sheet6_Folder2","Formas Pagto.")
EndIf

//-- Define os Boxes da tela inferior dos recursos
oView:CreateHorizontalBox("BoxRecursosDUP",100,,,"Folder2","Sheet1_Folder2")
oView:CreateHorizontalBox("BoxRecursosDUQ",100,,,"Folder2","Sheet2_Folder2")
oView:CreateHorizontalBox("BoxRecursosDVB",100,,,"Folder2","Sheet3_Folder2")
oView:CreateHorizontalBox("BoxRecursosSDG",100,,,"Folder2","Sheet4_Folder2")
oView:CreateHorizontalBox("BoxRecursosDVW",100,,,"Folder2","Sheet5_Folder2")
If cTMSOPdg <> "0"
	oView:CreateHorizontalBox("BoxRecursosDLD",100,,,"Folder2","Sheet6_Folder2")
	oView:SetVldFolder({|cID,nOldSheet, nSelSheet| TF64Folder(cID,nOldSheet,nSelSheet)})
EndIf

oView:AddField("VwFieldCDTQ",oStruDTQ,"MdFieldDTQ")
oView:SetOwnerView("VwFieldCDTQ","BoxViagemSup")

If AliasInDic("DMB")
	oView:AddGrid("VwGridDMB",oStruDMB,"MdGridDMB")
	oView:SetOwnerView("VwGridDMB","BoxAutomatiza")
EndIf

oView:AddGrid("VwGridDM3",oStruDM3,"MdGridDM3")
oView:SetOwnerView("VwGridDM3","VERTICAL2")
oView:AddIncrementField("VwGridDM3","DM3_SEQUEN")

If lTMS3GFE .Or. lTmsRdpU
	oView:CreateFolder("Folder4","BoxViagemGFE")
	oView:AddSheet("Folder4","Sheet1_Folder4",STR0020)  //Trecho do Documento
	oView:AddSheet("Folder4","Sheet2_Folder4",STR0021)  //Redespacho Adicional
	oView:CreateHorizontalBox("BoxViagemDM8",100,,,"Folder4","Sheet1_Folder4")
	oView:CreateHorizontalBox("BoxViagemDJN",100,,,"Folder4","Sheet2_Folder4")
	
	oView:AddGrid("VwGridDM8",oStruDM8,"MdGridDM8") //Trecho do Documento
	oView:SetOwnerView("VwGridDM8","BoxViagemDM8")

	oView:AddGrid("VwGridDJN",oStruDJN,"MdGridDJN")  //Redespacho Adicional
	oView:SetOwnerView("VwGridDJN","BoxViagemDJN")
	oView:AddIncrementField("VwGridDJN","DJN_SEQRDP")
	
	oView:AddUserButton(STR0022,'', {|| TMSVDCGFE(FwFldGet('DM3_FILDOC'),FwFldGet('DM3_DOC'),FwFldGet('DM3_SERIE'))} ) //Docto de Carga
	oView:AddUserButton(STR0021,'', {|oModel| TMF60RdVge(oModel)} ) //Redespacho Adicional
	oView:AddUserButton(STR0029,'', {|oModel| TF65RecFrt(oModel)} ) //Recalculo Frete
EndIf

oView:AddField("VwFieldDM4",oStruDM4,"MdFieldDM4")
oView:SetOwnerView("VwFieldDM4","BoxRecursosDM4")
oView:EnableTitleView("VwFieldDM4",STR0018)	//-- Planejamento da Viagem

oView:AddField("VwFieldDM5",oStruDM5,"MdFieldDM5")
oView:SetOwnerView("VwFieldDM5","BoxRecursosDM5")
oView:EnableTitleView("VwFieldDM5",STR0019)	//-- Operadoras de Frota

oView:AddGrid("VwGridDTR",oStruDTR,"MdGridDTR")
oView:SetOwnerView("VwGridDTR","BoxRecursosMid")
oView:EnableTitleView("VwGridDTR",STR0005)	//-- Veículos da Viagem
oView:AddIncrementField("VwGridDTR","DTR_ITEM")

oView:AddGrid("VwGridDUP",oStruDUP,"MdGridDUP")
oView:SetOwnerView("VwGridDUP","BoxRecursosDUP")

oView:AddGrid("VwGridDUQ",oStruDUQ,"MdGridDUQ")
oView:SetOwnerView("VwGridDUQ","BoxRecursosDUQ")

oView:AddGrid("VwGridDVB",oStruDVB,"MdGridDVB")
oView:SetOwnerView("VwGridDVB","BoxRecursosDVB")
oView:AddIncrementField("VwGridDVB","DVB_ITEM")

oView:AddGrid("VwGridISDG",oStruSDG,"MdGridSDG")
oView:SetOwnerView("VwGridISDG","BoxRecursosSDG")
oView:AddIncrementField("VwGridISDG","DG_ITEM")

oView:AddGrid("VwGridDVW",oStruDVW,"MdGridDVW")
oView:SetOwnerView("VwGridDVW","BoxRecursosDVW")

If cTMSOPdg <> "0"
	oView:AddGrid("VwGridDLD",oStruDLD,"MdGridDLD")
	oView:SetOwnerView("VwGridDLD","BoxRecursosDLD")
EndIf

oView:AddGrid("VwGridDYD",oStruDYD,"MdGridDYD")  //Agendamento de Entrega
oView:SetOwnerView("VwGridDYD","BoxViagemDYD")

oView:AddOtherObject( "VwButton", { |oPanel| TF60Button( oPanel ) } )
oView:AddOtherObject( "VwBtCdBr", { |oPanel| TF60BtCdBr( oPanel ) } )
oView:AddOtherObject( "VwBtRdp" , { |oPanel| TF60BtRdp( oPanel ) } )
oView:AddOtherObject( "VwBtDoc" , { |oPanel,oModel| TF60BtDoc( oPanel ) } )
oView:SetOwnerView( "VwButton" , "VERTICAL1"  )
oView:SetOwnerView( "VwBtCdBr" , "VERTICAL1"  )
oView:SetOwnerView( "VwBtRdp"  , "VERTICAL1"  )
oView:SetOwnerView( "VwBtDoc"  , "VERTICAL1"  )

oView:AddField( 'VIEW_CALC1', oCalc1  , "AF60CAL1" )
oView:SetOwnerView( "VIEW_CALC1" , "TOTAIS"  )

Return oView

/*{Protheus.doc} MenuDef
    Definição do aRotina (Menu funcional)
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 23/05/2020
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example MenuDef()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0006 ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.TMSAF60" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.TMSAF60" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.TMSAF60" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE STR0010 ACTION "VIEWDEF.TMSAF60" OPERATION 5 ACCESS 0

//-- Adiciona rotinas do sub-menu de manutenção
aRotina := TMSAF68(Aclone(aRotina))

Return (aRotina)

/*{Protheus.doc} MntTrigger
    Monta a estrutura da Trigger
    @type Static Function
    @author Katia
    @since 19/06/2020
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example MntTrigger()
    (examples)
    @see (links_or_references)
*/
Static Function MntTrigger(oStruct,aTrigger)
Local cDominio  := ""
Local cContra   := ""
Local nCntFor1  := 0
Local nCntFor2  := 0
Local nCntFor3  := 0
Local aAux      := {}

For nCntFor1 := 1 To Len(aTrigger)
	For nCntFor2 := 1 To Len(aTrigger[nCntFor1,1])
		cDominio := aTrigger[nCntFor1,1,nCntFor2]
		For nCntFor3 := 1 To Len(aTrigger[nCntFor1,2])
			cContra := aTrigger[nCntFor1,2,nCntFor3]

			aAux :=(FwStruTrigger(cDominio	,; // Campo de Dominio
								  cContra	,; // Campo de ContraDominio
								  "TMSAF65GAT('" + cDominio + "', '" + cContra + "')"	,; // Regra de Preenchimento
								  ,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
								  ,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
								  ,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
								  ,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
								  )) // Condição para execução do gatilho (Opcional)

			oStruct:AddTrigger(aAux[1],;	//-- [01] Id do campo de origem
							   aAux[2],;	//-- [02] Id do campo de destino
							   aAux[3],;	//-- [03] Bloco de codigo de validação da execução do gatilho
							   aAux[4])		//-- [04] Bloco de codigo de execução do gatilho
		Next nCntFor3
	Next nCntFor2
Next nCntFor1

FwFreeArray(aAux)

Return

/*{Protheus.doc} RemoveFld
    Remove fieldes de uma View
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 01/07/2020
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example RemoveFld(oStruct,aFields)
    (examples)
    @see (links_or_references)
*/
Static Function RemoveFld(oStruct,aCampos)
Local nCntFor1 := 0

Default oStruct := Nil
Default aCampos := {}

For nCntFor1 := 1 To Len(aCampos)
	&("oStruct:RemoveField('" + aCampos[nCntFor1] + "')")
Next nCntFor1

Return

/*{Protheus.doc} AltStruc
    Altera estrutura dos campos
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 01/07/2020
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example AltStruc(oStruct,aCampos (cCampo,(1=Valid / 2=When / 3=IniPad / 4=PictVar / 5=Obrigat),cExpressao))
    (examples)
    @see (links_or_references)
*/
Static Function AltStruc(oStruct,aCampos)
Local bCodigo  := Nil
Local nCntFor1 := 0
Local nCntFor2 := 0

Default oStruc  := Nil
Default aCampos := {}

For nCntFor1 := 1 To Len(aCampos)
	For nCntFor2 := 1 To Len(aCampos[nCntFor1,2])
		If aCampos[nCntFor1,2,nCntFor2,1] == 5
			bCodigo := aCampos[nCntFor1,2,nCntFor2,2]
		Else
			bCodigo := FWBuildFeature(Iif(aCampos[nCntFor1,2,nCntFor2,1] == 1,STRUCT_FEATURE_VALID,;
									  Iif(aCampos[nCntFor1,2,nCntFor2,1] == 2,STRUCT_FEATURE_WHEN,;
									  Iif(aCampos[nCntFor1,2,nCntFor2,1] == 3,STRUCT_FEATURE_INIPAD,;
									  Iif(aCampos[nCntFor1,2,nCntFor2,1] == 4,STRUCT_FEATURE_PICTVAR,Nil)))),aCampos[nCntFor1,2,nCntFor2,2])
		EndIf
				
		oStruct:SetProperty(aCampos[nCntFor1,1],Iif(aCampos[nCntFor1,2,nCntFor2,1] == 1,MODEL_FIELD_VALID,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 2,MODEL_FIELD_WHEN,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 3,MODEL_FIELD_INIT,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 4,MODEL_FIELD_PICTVAR,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 5,MODEL_FIELD_OBRIGAT,Nil))))),bCodigo)
	Next nCntFor2
Next nCntFor1

Return

/*{Protheus.doc} FixWhen
    Altera estrutura dos campos
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 07/07/2020
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example FixWhen(oStruct,cFuncao)
    (examples)
    @see (links_or_references)
*/
Static Function FixWhen(oStruct,cFuncao,cTabela)
Local nCntFor1 := 0
Local aCampos  := {}
Local bCodigo
Local lFixWhen := .T.

Default oStruct := Nil
Default cFuncao := ""
Default cTabela := ""

aCampos := oStruct:GetFields()
bCodigo := FWBuildFeature(STRUCT_FEATURE_WHEN,cFuncao)

For nCntFor1 := 1 To Len(aCampos)
	If GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_PROPRI") <> "U"
		If cTabela == "DTR"
			lFixWhen:= !Empty(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_WHEN"))		
		ElseIf cTabela == "DTQ"
			lFixWhen := "TMSA144WHE()" $ UPPER(AllTrim(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_WHEN")))
			If !lFixWhen
				lFixWhen := Iif(!lFixWhen,aCampos[nCntFor1,MODEL_FIELD_IDFIELD] $ "DTQ_SERTMS|DTQ_TIPTRA",.F.)
			EndIf			
		EndIf
		If lFixWhen
			oStruct:SetProperty(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],MODEL_FIELD_WHEN,bCodigo)
		EndIf
	EndIf
Next nCntFor1

Return

/*{Protheus.doc} FixValid
    Altera estrutura dos campos
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 07/07/2020
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example FixValid(oStruct,cFuncao)
    (examples)
    @see (links_or_references)
*/
Static Function FixValid(oStruct,cFuncao,cTabela)
Local nCntFor1 := 0
Local aCampos  := {}
Local bCodigo
Local lFixValid := .T.

Default oStruct := Nil
Default cFuncao := ""
Default cTabela := ""

aCampos := oStruct:GetFields()
bCodigo := FWBuildFeature(STRUCT_FEATURE_VALID,cFuncao)

For nCntFor1 := 1 To Len(aCampos)
	If GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_PROPRI") <> "U"
		If cTabela $ "DTR"
			lFixValid := "TMSA240VLD()" $ UPPER(AllTrim(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_VALID")))
			If !lFixValid //Validação dos campos DTR_FORPDG e DTR_LOJPDG
				lFixValid := "DTR_FORPDG" $ UPPER(AllTrim(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_VALID")))
			EndIf
			If !lFixValid //Validação dos campos DTR_FOROPE e DTR_LOJOPE
				lFixValid := "DTR_FOROPE" $ UPPER(AllTrim(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_VALID")))
			EndIf
		ELseIf cTabela $ "DUP"
			lFixValid := "TA240VLMOT()" $ UPPER(AllTrim(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_VALID")))
		ELseIf cTabela $ "DTQ"
			lFixValid := "TMSA144VAL()" $ UPPER(AllTrim(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_VALID")))
			If !lFixValid
				lFixValid := Iif(!lFixValid,aCampos[nCntFor1,MODEL_FIELD_IDFIELD] $ "DTQ_SERTMS|DTQ_TIPTRA",.F.)
			EndIf
		ELseIf cTabela $ "DVW|DLD"
			lFixValid := "TMSA240VLD()" $ UPPER(AllTrim(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_VALID")))
		ELseIf cTabela $ "DJN"
			lFixValid := "TMSA144VAL()" $ UPPER(AllTrim(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_VALID")))
		EndIf

		If lFixValid
			oStruct:SetProperty(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],MODEL_FIELD_VALID,bCodigo)
		EndIf
	EndIf

Next nCntFor1

Return
//-----------------------------------------------
/* {Protheus.doc} TmsVgeMod3
Indica se é viagem modelo 3 
@author Caio Murakami
@since 13/07/2020
@version P12 R12.1.29
@return Nil
*///--------------------------------------------- 
Function TmsVgeMod3()
Local lRet		:= .F. 
Local oModel	:= Nil

If Left(FunName(),7) == 'TMSAF60' .Or. IsInCallStack("TMSAF60") .Or. IsInCallStack("A67BlqViag")
	lRet	:= .T. 
Else
	oModel	:= FwModelActive()
	If oModel <> Nil .And. AllTrim(Upper(oModel:cID)) == 'TMSAF60' .And. oModel:IsActive() //--- Viagem Modelo 3
		lRet	:= .T. 
	EndIf
EndIf

Return lRet 
/*/{Protheus.doc} TF60F3Doc
	Realiza chamada do filtro de documentos TMSC080
	@type  Function
	@author Caio Murakami
	@since 23/07/2020
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function TF60F3Doc( lSelDoc )
Local cFiltraDUD	:= ""
Local lTMSDCol 		:= SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.
Local nOpcSel		:= 0 
Local lVgeMod3      := TmsVgeMod3()	//-- Viagem Modelo 3
Local lCarMod3      := TmsCarMod3()	//-- Carregamento Modelo 3
Local cViagem       := Iif(lVgeMod3 .And. !lCarMod3 .And. !IsInCallStack("TMSA360MNT"),FWFldGet("DTQ_VIAGEM"),DTQ->DTQ_VIAGEM)
Local cSerAdi       := "1"
Local cSerTMS       := Iif(lVgeMod3 .And. !lCarMod3 .And. !IsInCallStack("TMSA360MNT"),FwFldGet("DTQ_SERTMS"),DTQ->DTQ_SERTMS)
Local cTipTra       := Iif(lVgeMod3 .And. !lCarMod3 .And. !IsInCallStack("TMSA360MNT"),FwFldGet("DTQ_TIPTRA"),DTQ->DTQ_TIPTRA)
Local cRota         := Iif(lVgeMod3 .And. !lCarMod3 .And. !IsInCallStack("TMSA360MNT"),FwFldGet("DTQ_ROTA")  ,DTQ->DTQ_ROTA)
Local cTipVia       := Iif(lVgeMod3 .And. !lCarMod3 .And. !IsInCallStack("TMSA360MNT"),FwFldGet("DTQ_TIPVIA"),DTQ->DTQ_TIPVIA)

Default lSelDoc		:= .F. 

cFiltraDUD := "DUD.DUD_FILIAL = '" + xFilial("DUD") + "'" + Iif(lTMSDCol,""," AND DUD.DUD_FILORI = '" + cFilAnt + "'") + " AND DUD.DUD_TIPTRA = '" + cTipTra + "'"

If cSerTms ==  "3"  .And. cTipTra $ "1|2"   //Entrega sempre com serviço adicional
	cFiltraDUD += " AND DUD.DUD_SERTMS IN ('1','3') "
Else
	cFiltraDUD += " AND DUD.DUD_SERTMS = '" + cSerTms + "'"			
EndIf

If cTipVia == "5"
	cFiltraDUD += " AND DUD.DUD_NUMRED <> ' ' "
Else
	cFiltraDUD += " AND DUD.DUD_NUMRED = ' ' "
EndIf

If !IsInCallStack("TMSA360MNT")
	If !lCarMod3
		cFiltraDUD += " AND DUD.DUD_STATUS IN ('1','2') "
	Else
		cFiltraDUD += " AND DUD.DUD_STATUS IN ('1','3') "
	EndIf
EndIf

If lCarMod3 .Or. IsInCallStack("TMSA360MNT")
	cFiltraDUD += " AND DUD.DUD_FILORI = '" + cFilAnt + "' AND DUD.DUD_VIAGEM = '" + cViagem + "' "
	If lCarMod3
		cFiltraDUD += " AND DUD.DUD_SERIE <> 'COL' "
	EndIf
ElseIf lVgeMod3 .And. !lCarMod3
	cFiltraDUD += " AND DUD.DUD_VIAGEM = ' ' "
EndIf

nOpcSel   := TMSC080(cFiltraDUD,lSelDoc,,cRota , , cSerTms , cTipTra , cSerAdi )

Return nOpcSel


//--------------------------------------------------
/*/{Protheus.doc} NoFieldsSDG
Retorna os campos da SDG que não irão entrar no ModelDef e ViewDef
@type  Static Function
@author Caio Murakami
@since 22/07/2020
@version 1.00
@param nType, numeric , 1=Model;2=View
@return cCampos, char , Campos que não participam da estrutura
/*/
//--------------------------------------------------
Static Function NoFieldsSDG( nType )
Local cCampos	:= ""

Default nType	:= 1

cCampos	:= '|DG_FILIAL|DG_BAIXA|DG_ESTDOC|DG_CODVEI|DG_DESVEI|DG_FILORI|DG_VIAGEM|DG_PERC'
cCampos	+= '|DG_TES|DG_COND|DG_NUMPARC|DG_PERVENC|DG_HISTOR' 
cCampos	+= '|DG_SEQMOV|DG_DTLANC|DG_DTLAEMI|DG_CODCAR'
cCampos	+= '|DG_SEQCAR|DG_TIPUSO|DG_IDENT|DG_NUMCTC|DG_INTMOV|DG_IDCTMS'
cCampos	+= '|DG_NOMFOR|DG_FILFRT|DG_DOCFRT|DG_SERFRT'

If nType == 1 

ElseIf nType == 2
	cCampos	+= '|DG_DOC|DG_EMISSAO|DG_NUMSEQ|DG_ORIGEM|DG_STATUS'
	cCampos	+= '|DG_SEQORI|DG_DATBAI|DG_MOTBAI|DG_TITGER|DG_ORITIT'
	cCampos += '|DG_CODFOR|DG_LOJFOR|'
EndIf

Return cCampos

/*{Protheus.doc} TMFSetStat
Seta variáveis estaticas
@type Function
@author Valdemar Roberto Mognon
@since 17/08/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAF60()
(examples)
@see (links_or_references)
*/
Function TMFSetStat(cVar,xCont)

&(cVar) := xCont

Return

/*{Protheus.doc} TMFGetStat
Seta variáveis estaticas
@type Function
@author Valdemar Roberto Mognon
@since 17/08/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAF60()
(examples)
@see (links_or_references)
*/
Function TMFGetStat(cVar)

Return &(cVar)

/*{Protheus.doc} TF60DudStat
Retorna status DUD
@type Function
@author Caio Murakami
@since 03/09/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAF60()
(examples)
@see (links_or_references)
*/
Function TF60DudStat( cFilDoc , cDoc , cSerie, cFilOri , cViagem , nAcao )
Local cStatus   := ""
Local cQuery    := ""
Local cAliasDUD := ""
Local aAreas    := {DUD->(GetArea()),GetArea()}

Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""
Default cFilOri		:= ""
Default cViagem		:= ""
Default nAcao       := 1

cAliasDUD := GetNextAlias()
cQuery += "SELECT DUD_STATUS,DUD_STROTA "
cQuery += "  FROM " + RetSQLName("DUD") + " DUD "
cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "   AND DUD_FILDOC = '" + cFilDoc + "' "
cQuery += "   AND DUD_DOC    = '" + cDoc + "' "
cQuery += "   AND DUD_SERIE  = '" + cSerie + "' "
cQuery += "   AND DUD_VIAGEM = '" + cViagem + "' "
cQuery += "   AND DUD_STATUS <> '9' "
cQuery += "   AND D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDUD,.F.,.T.)

If (cAliasDUD)->(!Eof())
	If nAcao == 1	//-- Status do documentos
		cStatus := (cAliasDUD)->DUD_STATUS
	ElseIf nAcao == 2	//-- Status da rota
		cStatus := (cAliasDUD)->DUD_STROTA
	EndIf
EndIf

(cAliasDUD)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return cStatus 

//-------------------------------------------------------------------
/* {Protheus.doc} TF60Button

Cria botão para adicionar multiplos documentos na Grid

@author  Caio Murakami
@since   10/09/2020
@version 1.0
*/
//-------------------------------------------------------------------
Static Function TF60Button( oPanel )
Local oTBitmap1	:= Nil 

oTBitmap1 := TBitmap():New(05,03,260,184,,"BMPVISUAL",.T.,oPanel,;
        {||TF60BmpDoc()},,.F.,.F.,,,.F.,,.T.,,.F.)
oTBitmap1:lAutoSize := .T.

Return NIL

//----------------------------------------
/* {Protheus.doc} TF60BtCdBr

Cria botão para o Codigo de Barras do CTe

@author  Katia
@since   21/09/2020
@version 1.0
*/
//------------------------------------------
Static Function TF60BtCdBr( oPanel )
Local oTBitmap1	:= Nil 

oTBitmap1 := TBitmap():New(20,03,260,184,,"MDIRUN" /*"SDUIMPORT"*/,.T.,oPanel,{||TMF60CodBr()},,.F.,.F.,,,.F.,,.T.,,.F.)
oTBitmap1:lAutoSize := .T.

Return Nil


//-----------------------------------------------------------
/* {Protheus.doc} TF60BtRdp

Cria botão para listar os Lotes de Redespacho
gatilhando os Doctos selecionados na viagem do tipo Redespacho.  
@author  Katia
@since   23/09/2020
@version 1.0
*/
//-----------------------------------------------------------
Static Function TF60BtRdp( oPanel )
Local oTBitmap1	:= Nil 

oTBitmap1 := TBitmap():New(35,03,260,184,,"CTBREPLA" /*"CARGA"*/,.T.,oPanel,{||TMSAF60Rdp()},,.F.,.F.,,,.F.,,.T.,,.F.)
oTBitmap1:lAutoSize := .T.

Return Nil

//-----------------------------------------------------------
/* {Protheus.doc} TF60BtDoc

Cria botão para visualizar o documento da GRID
gatilhando os Doctos selecionados na viagem do tipo Redespacho.  
@author  Valdemar Roberto Mognon
@since   14/10/2020
@version 1.0
*/
//-----------------------------------------------------------
Static Function TF60BtDoc( oPanel )
Local oTBitmap1	:= Nil 

oTBitmap1 := TBitmap():New(50,03,260,184,,"DEVOLNF" /*"CARGA"*/,.T.,oPanel,{||TMSAF60Doc()},,.F.,.F.,,,.F.,,.T.,,.F.)
oTBitmap1:lAutoSize := .T.

Return Nil

//-----------------------------------------------------------
/* {Protheus.doc} TF60BmpSrv
BitMap para o Serviço de Transporte da Viagem 
@author  Katia
@since   17/12/2020
@version 1.0
*/
//-----------------------------------------------------------
Function TF60BmpSrv()
Local cRet	:= ""

If DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS))	
	cRet	:= "LOJIMG32.PNG"
ElseIf DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS))	
	cRet	:= "ARMAZEM.PNG"
ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS))	
	cRet	:= "CARGA.PNG"
EndIf

Return cRet

//-----------------------------------------------------------
/* {Protheus.doc} TF60LegSrv
Legenda para o Serviço de Transporte da Viagem
@author  Katia
@since   17/12/2020
@version 1.0
*/
//-----------------------------------------------------------
Function TF60LegSrv()
Local aLegenda  := {}
Local cTitulo   := GetSx3Cache("DTQ_SERTMS","X3_DESCRIC")   

Aadd(aLegenda,{"LOJIMG32.PNG", STR0033 })     //Coleta
Aadd(aLegenda,{"ARMAZEM.PNG" , STR0034 })     //Transporte
Aadd(aLegenda,{"CARGA.PNG"	 , STR0035 })     //Entrega

BrwLegenda( cTitulo , cTitulo , aLegenda )  
			
Return .T.

//-----------------------------------------------------------
/* {Protheus.doc} TF60LegSrv
Ajusta o inicializador padrão do campo DM3_ORIGEM
@author  Rodrigo.Pirolo
@since   27/01/2021
@version 1.0
*/
//-----------------------------------------------------------

Function TMSAFIniD( cCampo )
Local aArea		:= GetArea()
Local cRet		:= ""
Local oModel	:= FwModelActive()
Local lCarAut   := .T.
Local cPerg     := "TMSAF60"

Default cCampo  := ReadVar()

If cCampo == "DM3_ORIGEM"
            
	Pergunte(cPerg,.F.)

	//-- Analisa o carregamento automático
	If ExistFunc("TmsAutViag") .And. DTQ->(ColumnPos("DTQ_CODAUT")) > 0
		If TmsAutViag(FwFldGet("DTQ_FILORI"),FwFldGet("DTQ_VIAGEM"),FwFldGet("DTQ_CODAUT"),"TMSAF90")
			lCarAut := .T.
		Else
			lCarAut := (MV_PAR01 != 1)
		EndIf
	Else
		lCarAut := (MV_PAR01 != 1)
	EndIf

	If lCarAut
		If oModel:GetOperation() == 3
			cRet := "1"
		Else
			cRet := If( !Empty( DTQ->DTQ_STATUS ) .And. DTQ->DTQ_STATUS != "1" , "2", "1" )
		EndIf
	EndIf
EndIf

RestArea( aArea )
FwFreeArray(aArea)

Return cRet

//-----------------------------------------------------------
/*/{Protheus.doc} TF60AtuBrw
//Atualização do browser na troca de folder
@author Katia
@since 19/04/2021
@version 12.1.33
/*/
//-----------------------------------------------------------

Function TF60AtuBrw(nFolder,lCria)


	Do Case
		Case nFolder == 1
			oBrowseUp:Refresh(lCria)
		Case nFolder == 2			
			oBrowseDM3:Refresh(lCria)			
			oBrowseDM3:GoBottom()
			oBrowseDM3:GoTop()
		Case nFolder == 3			
			oBrowseDTX:Refresh(lCria)
			oBrowseDTX:GoBottom()
			oBrowseDTX:GoTop()
		Case nFolder == 4			
			oBrowseDTW:Refresh(lCria)	
			oBrowseDTW:GoBottom()
			oBrowseDTW:GoTop()
		Case nFolder == 5
			oBrowseDUA:Refresh(lCria)
			oBrowseDUA:GoBottom()
			oBrowseDUA:GoTop()
		Case nFolder == 6
			oBrowseDTY:Refresh(lCria)
			oBrowseDTY:GoBottom()
			oBrowseDTY:GoTop()
		Case nFolder == 7
			oBrowseDFV:Refresh(lCria)
			oBrowseDFV:GoBottom()
			oBrowseDFV:GoTop()
	EndCase

Return .T.

//-----------------------------------------------------------
/*/{Protheus.doc} MontaBtn
//Monta os Botões do Browse das Rotinas
@author Katia
@since 22/04/2021
@version 12.1.33
/*/
//-----------------------------------------------------------
Static Function MontaBtn(oBrowse,cAlias)

If cAlias == 'DUA'
	If TmsAcesso(,"TMSA360",,2,.F.)
		oBrowse:AddButton('Visualizar',{|| SetFunName('TMSA360'),TMSA360Mnt('DUA', DUA->(Recno()), 2, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,oBrowse:Refresh() )  },,2,,.F.) //Visualizar
	EndIf

	If TmsAcesso(,"TMSA360",,3,.F.)
		oBrowse:AddButton('Apontar',{|| TMA360Ini(), TMSA360Mnt('DUA', 0, 3, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM), oBrowse:Refresh(),oBrowse:GoTop(.T.)   },,3,,.F.) //Apontar	
	EndIf
			
	If TmsAcesso(,"TMSA360",,4,.F.)
		oBrowse:AddButton('Estornar',{|| TMSA360Mnt('DUA', DUA->(Recno()), 4, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM ), oBrowse:Refresh(),oBrowse:GoTop(.T.)    },,4,,.F.) //Estornar
	EndIf
			
	If TmsAcesso(,"TMSA360",,7,.F.)
		oBrowse:AddButton('Ajustar',{|| TMSA360Mnt('DUA', DUA->(Recno()), 5, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM ), oBrowse:Refresh(),oBrowse:GoTop(.T.) },,4,,.F.) //Ajustar
	EndIf
EndIf

Return

/*{Protheus.doc} TMSAF60Vis
Seta variáveis estaticas
@type Static Function
@author Valdemar Roberto Mognon
@since 12/05/2021
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAF60()
(examples)
@see (links_or_references)
*/
Static Function TMSAF60Vis()
Local aAreas := {DT6->(GetArea()),GetArea()}

Private cCadastro := STR0043	//-- "Manutenção de Documentos"
Private INCLUI    := .F.

aRotina := {{"","",0,1},;
			{"","",0,2}}

DT6->(DbSetOrder(1))
DT6->(DbSeek(xFilial("DT6") + DM3->(DM3_FILDOC + DM3_DOC + DM3_SERIE)))

TMSA500Mnt("DT6",DT6->(Recno()),2)

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} TMSAF60Fil
Filtra as viagens
@type Static Function
@author Valdemar Roberto Mognon
@since 13/05/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Function TMSAF60Fil( lExbHlp, nMVPAR03 )

Local nDias		:= 0

Default lExbHlp := .T.
Default nMVPAR03:= 0

If lExbHlp .And. Empty(cFilFilDoc + cFilDoc + cFilSerie + cFilFilMan + cFilManife + cFilFilOri + cFilNumCTC + cFilPlaca + cFilCodMot)
	Help("",1,"TMSAF6001")
Else
	oBrowseUp:SetFilterDefault("@" + MontaSQL())
EndIf

If FindFunction("TMSPnlF60")
	
	If nMVPAR03 > 0
		nDias := nMVPAR03
	EndIf

	cRet := TMSPnlF60("1", cFilFilMan, nDias )
	oPnlInd1:AtuValor(cRet)
	cRet := TMSPnlF60("2", cFilFilMan, nDias )
	oPnlInd2:AtuValor(cRet)
	cRet := TMSPnlF60("3", cFilFilMan, nDias )
	oPnlInd3:AtuValor(cRet)
	cRet := TMSPnlF60("4", cFilFilMan, nDias )
	oPnlInd4:AtuValor(cRet)
	cRet := TMSPnlF60("5", cFilFilMan, nDias )
	oPnlInd5:AtuValor(cRet)
	cRet := TMSPnlF60("6", cFilFilMan, nDias )
	oPnlInd6:AtuValor(cRet)
	cRet := TMSPnlF60("7", cFilFilMan, nDias )
	oPnlInd6:AtuValor(cRet)
EndIf

Return .T.

/*{Protheus.doc} TMSAF60Cle
Limpa os filtros
@type Static Function
@author Valdemar Roberto Mognon
@since 13/05/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Static Function TMSAF60Cle()

cFilFilDoc := Space(TamSX3("DT6_FILDOC")[1])
cFilDoc    := Space(TamSX3("DT6_DOC")[1])
cFilSerie  := Space(TamSX3("DT6_SERIE")[1])
cFilFilMan := Space(TamSX3("DTX_FILMAN")[1])
cFilManife := Space(TamSX3("DTX_MANIFE")[1])
cFilFilOri := Space(TamSX3("DTY_FILORI")[1])
cFilNumCTC := Space(TamSX3("DTY_NUMCTC")[1])
cFilPlaca  := Space(TamSX3("DA3_PLACA")[1])
cFilCodMot := Space(TamSX3("DA4_COD")[1])
nSelVeic   := 1

lPrimeiro := .T.

TMSAF60Fil(.F.)

Return

/*{Protheus.doc} MontaSQL
Monta a instrução SQL para os filtros
@type Static Function
@author Valdemar Roberto Mognon
@since 13/05/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Static Function MontaSQL()
Local cFiltro := ""
Local cSelect := ""
Local cFrom := ""
Local cWhere := ""
Local cFilTab := ""
Local aAreas  := {DA3->(GetArea()),GetArea()}

If !lPrimeiro
	cSelect := " (EXISTS (SELECT 1 FROM " 
	
	cWhere := "Where DTQ_FILIAL = '" + xFilial("DTQ") + "' "
		
	If !Empty(cFilFilDoc) .And. !Empty(cFilDoc) .And. !Empty(cFilSerie)
		cFrom	:= cFrom + RetSqlName("DUD") + " DUD "
		cFilTAB := cFilTAB
		cFilTAB += " AND DTQ_FILORI = DUD_FILORI "
		cFilTAB += " AND DTQ_VIAGEM = DUD_VIAGEM "
		cFilTAB += " AND DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
		cFilTAB += " AND DUD.DUD_FILDOC = '" + cFilFilDoc + "' "
		cFilTAB += " AND DUD.DUD_DOC    = '" + cFilDoc + "' "
		cFilTAB += " AND DUD.DUD_SERIE  = '" + cFilSerie + "' "
		cFilTAB += " AND DUD.D_E_L_E_T_ = ' ' "
	EndIf
	
	If !Empty(cFilFilMan) .And. !Empty(cFilManife)
		cFrom	:= cFrom + Iif(!Empty(cFrom), ",", " " ) + RetSqlName("DTX") + " DTX "
		cFilTAB := cFilTAB 
		cFilTAB += " AND DTQ_FILORI = DTX.DTX_FILORI "
		cFilTAB += " AND DTQ_VIAGEM = DTX.DTX_VIAGEM "
		cFilTAB += " AND DTX.DTX_FILIAL = '" + xFilial("DTX") + "' "
		cFilTAB += " AND DTX.DTX_FILMAN = '" + cFilFilMan + "' "
		cFilTAB += " AND DTX.DTX_MANIFE = '" + cFilManife + "' "
		cFilTAB += " AND DTX.D_E_L_E_T_ = ' ' "
	EndIf
	
	If !Empty(cFilFilOri) .And. !Empty(cFilNumCTC)
		cFrom	:= cFrom + Iif(!Empty(cFrom), ",", " " ) + RetSqlName("DTY") + " DTY "
		cFilTAB := cFilTAB 
		cFilTAB += " AND DTQ_FILORI = DTY_FILORI "
		cFilTAB += " AND DTQ_VIAGEM = DTY_VIAGEM "	
		cFilTAB += " AND DTY.DTY_FILIAL = '" + xFilial("DTY") + "' "
		cFilTAB += " AND DTY.DTY_FILORI = '" + cFilFilOri + "' "
		cFilTAB += " AND DTY.DTY_NUMCTC = '" + cFilNumCTC + "' "
		cFilTAB += " AND DTY.D_E_L_E_T_ = ' ' "
	EndIf
	
	If !Empty(cFilPlaca)
		DA3->(DbSetOrder(3))
		If DA3->(DbSeek(xFilial("DA3") + cFilPlaca))
			cFrom	:= cFrom + Iif(!Empty(cFrom), ",", " " ) + RetSqlName("DTR") + " DTR "
			cFilTAB := cFilTAB
			cFilTAB += " AND DTQ_FILORI = DTR.DTR_FILORI "
			cFilTAB += " AND DTQ_VIAGEM = DTR.DTR_VIAGEM "
			cFilTAB += " AND DTR.DTR_FILIAL = '" + xFilial("DTR") + "' "
			If nSelVeic == 1
				cFilTAB += " AND DTR.DTR_CODVEI = '" + DA3->DA3_COD + "' "
			Else
				cFilTAB += " AND (DTR.DTR_CODRB1 = '" + DA3->DA3_COD + "' "
				cFilTAB += " OR  DTR.DTR_CODRB2 = '" + DA3->DA3_COD + "' "
				cFilTAB += " OR  DTR.DTR_CODRB3 = '" + DA3->DA3_COD + "') "
			EndIf			
			cFilTAB += " AND DTR.D_E_L_E_T_ = ' ' "
		EndIf
	EndIf

	If !Empty(cFilCodMot)
		cFrom	:= cFrom + Iif(!Empty(cFrom), ",", " " ) + RetSqlName("DUP") + " DUP "
		cFilTAB := cFilTAB
		cFilTAB += " AND DTQ_FILORI = DUP.DUP_FILORI "
		cFilTAB += " AND DTQ_VIAGEM = DUP.DUP_VIAGEM "
		cFilTAB += " AND DUP.DUP_FILIAL = '" + xFilial("DUP") + "' "
		cFilTAB += " AND DUP.DUP_CODMOT = '" + cFilCodMot + "' "
		cFilTAB += " AND DUP.D_E_L_E_T_ = ' ' "
	EndIf
	
	If !Empty(cFiltab)
		cFiltro := cSelect + cFrom + cWhere + cFilTab + " ))"
	EndIf
Else
	lPrimeiro := .F.
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return cFiltro

/*{Protheus.doc} UpdFolder
Redimensiona a tela
@type Static Function
@author Valdemar Roberto Mognon
@since 20/05/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Static Function UpdFolder(oFolders,oInferior)

oFolders:Move(oFolders:nTop,oFolders:nLeft,oFolders:nWidth,oInferior:nClientHeight)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CriaBrow
Cria o Browse ao clicar no folder
@type Static Function
@author Rodrigo Pirolo
@since 15/06/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
//-------------------------------------------------------------------

Static Function CriaBrow( nFolder, lCria )

Local aLegBrw	:= {}
Local aColsDFV  := {}
Local nI		:= 0

Default nFolder := 1

Do Case
	Case nFolder == 1 .And. FindFunction('TMSPnlF60')
		cRet := TMSPnlF60("1")
		oPnlInd1:AtuValor(cRet)
		cRet := TMSPnlF60("2")
		oPnlInd2:AtuValor(cRet)
		cRet := TMSPnlF60("3")
		oPnlInd3:AtuValor(cRet)
		cRet := TMSPnlF60("4")
		oPnlInd4:AtuValor(cRet)
		cRet := TMSPnlF60("5")
		oPnlInd5:AtuValor(cRet)
		cRet := TMSPnlF60("6")
		oPnlInd6:AtuValor(cRet)
		cRet := TMSPnlF60("7")
		oPnlInd7:AtuValor(cRet)

	Case nFolder == 3 .AND. Valtype(oBrowseDTX) == "U"
		
		//--- Manifestos
		oBrowseDTX := FWMBrowse():New()
		oBrowseDTX:SetAlias('DTX')
		oBrowseDTX:SetOwner(oFolder:aDialogs[3])
		oBrowseDTX:SetMenuDef('TMSA190')
		oBrowseDTX:SetProfileID('DTX')
		oBrowseDTX:DisableDetails()
		oBrowseDTX:SetFixedBrowse(.T.)
		oBrowseDTX:SetMainProc("TMSA190")
		oBrowseDTX:SetDescription(STR0038) // Manifestos
		If FindFunction("TF68LegBrw")
			TF68LegBrw(oBrowseDTX,'DTX')
		EndIf
		oBrowseDTX:AddStatusColumns({||TF68StaMDFE(DTX->DTX_FILMAN,DTX->DTX_MANIFE,DTX->DTX_SERMAN)},{||TF68LegManif()})
		oBrowseDTX:Activate()

		oRelacDTX := FWBrwRelation():New()
		oRelacDTX:AddRelation(oBrowseUp,oBrowseDTX,{ {"DTX_FILIAL","xFilial('DTX')" },{"DTX_FILORI","DTQ_FILORI"},{"DTX_VIAGEM","DTQ_VIAGEM"}} )
		oRelacDTX:Activate()

		lCria := .T.
		
	Case nFolder == 4 .AND. Valtype(oBrowseDTW) == "U"
		
		//--- Operações
		oBrowseDTW := FWMBrowse():New()
		oBrowseDTW:SetAlias('DTW')
		oBrowseDTW:SetOwner(oFolder:aDialogs[4])
		oBrowseDTW:SetMenuDef('TMSA350')
		oBrowseDTW:SetProfileID('DTW')
		oBrowseDTW:DisableDetails()
		oBrowseDTW:SetFixedBrowse(.T.)
		oBrowseDTW:SetMainProc("TMSA350")
		oBrowseDTW:SetDescription(STR0039) // Operações da viagem
		If FindFunction("TF68LegBrw")
			TF68LegBrw(oBrowseDTW,'DTW') // Operações da viagem
		EndIf
		oBrowseDTW:Activate()

		oRelacDTW := FWBrwRelation():New()
		oRelacDTW:AddRelation(oBrowseUp,oBrowseDTW,{ {"DTW_FILIAL","xFilial('DTW')" },{"DTW_FILORI","DTQ_FILORI"},{"DTW_VIAGEM","DTQ_VIAGEM"}} )
		oRelacDTW:Activate()

		lCria := .T.

	Case nFolder == 5 .AND. Valtype(oBrowseDUA) == "U"

		//--- Ocorrencias
		oBrowseDUA := FWMBrowse():New()
		oBrowseDUA:SetAlias('DUA')
		oBrowseDUA:SetOwner(oFolder:aDialogs[5])
		oBrowseDUA:SetMenuDef('')
		MontaBtn(oBrowseDUA,'DUA') //Botão
		oBrowseDUA:SetProfileID('DUA')
		oBrowseDUA:DisableDetails()
		oBrowseDUA:SetFixedBrowse(.T.)
		oBrowseDUA:SetMainProc("TMSA360")
		oBrowseDUA:SetDescription(STR0017) // Ocorrencias da Viagem	
		oBrowseDUA:Activate()

		oRelacDUA := FWBrwRelation():New()
		oRelacDUA:AddRelation(oBrowseUp,oBrowseDUA,{ {"DUA_FILIAL","xFilial('DUA')" },{"DUA_FILORI","DTQ_FILORI"},{"DUA_VIAGEM","DTQ_VIAGEM"}} )
		oRelacDUA:Activate()
		
		lCria := .T.

	Case nFolder == 6 .AND. Valtype(oBrowseDTY) == "U"
		
		//--- Contrato de Carreteiro
		oBrowseDTY := FWMBrowse():New()
		oBrowseDTY:SetAlias('DTY')
		oBrowseDTY:SetOwner(oFolder:aDialogs[6])
		oBrowseDTY:SetMenuDef('TMSA250')
		oBrowseDTY:SetProfileID('DTY')
		oBrowseDTY:DisableDetails()
		oBrowseDTY:SetFixedBrowse(.T.)
		oBrowseDTY:SetMainProc("TMSA250")
		oBrowseDTY:SetDescription(STR0041) // Contrato de Carreteiro
		If FindFunction("T250AddLeg")
			T250AddLeg(oBrowseDTY)   //Legenda TMSA250
		EndIf
		oBrowseDTY:Activate()

		oRelacDTY := FWBrwRelation():New()
		oRelacDTY:AddRelation(oBrowseUp,oBrowseDTY,{ {"DTY_FILIAL","xFilial('DTY')" },{"DTY_FILORI","DTQ_FILORI"},{"DTY_VIAGEM","DTQ_VIAGEM"}} )
		oRelacDTY:Activate()
		
		lCria := .T.

	Case nFolder == 7 .AND. Valtype(oBrowseDFV) == "U"
		aColsDFV  := { { AllTrim( FWX3Titulo('DFV_NUMRED') ), { || DFV->DFV_NUMRED}, "C", "@!", 1, TamSX3("DFV_FILORI")[1], 0, .F., , , , , , , , 1 } }
		//--- Redespacho
		oBrowseDFV := FWMBrowse():New()
		oBrowseDFV:SetAlias('DFV')
		oBrowseDFV:SetFields(aColsDFV) 
		oBrowseDFV:SetOwner(oFolder:aDialogs[7])
		oBrowseDFV:SetMenuDef('')
		oBrowseDFV:SetProfileID('DFV')
		oBrowseDFV:DisableDetails()
		oBrowseDFV:SetFixedBrowse(.T.)
		oBrowseDFV:AddButton(STR0007,{|| Iif(FindFunction("TF60VisRed"),TF60VisRed(), .T. ) },,2,,.F.) //Visualizar 
		oBrowseDFV:SetIgnoreARotina(.T.) // Ignora aRotina na construção das opções de menu

		If FindFunction("TMSAR05Leg")
			aLegBrw:= TMSAR05Leg() // Legenda
			For nI:= 1 To Len(aLegBrw)
				oBrowseDFV:AddLegend( aLegBrw[nI][1], aLegBrw[nI][2], aLegBrw[nI][3] )
			Next nI
		EndIf

		oBrowseDFV:SetMainProc("TMSAR05")
		oBrowseDFV:Activate()

		oRelacDFV := FWBrwRelation():New()
		oRelacDFV:AddRelation(oBrowseDM3,oBrowseDFV,{ {"DFV_FILIAL","xFilial('DFV')" },{"DFV_FILDOC","DM3_FILDOC"},{"DFV_DOC","DM3_DOC"},{"DFV_SERIE","DM3_SERIE"}} )
		oRelacDFV:Activate()

		lCria := .T.
EndCase

Return .T.

/*{Protheus.doc} Zera
Zera variáveis estáticas
@type Static Function
@author Valdemar Roberto Mognon
@since 16/07/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Static Function Zera()

FwFreeArray(aVeiVia)
FwFreeArray(aMotVia)

FwFreeObj(oBrowseUp)
FwFreeObj(oBrowseDM3)
FwFreeObj(oBrowseDTX)
FwFreeObj(oBrowseDTW)
FwFreeObj(oBrowseDUA)
FwFreeObj(oBrowseDTY)
FwFreeObj(oBrowseDFV)
FwFreeObj(oRelacDM3)
FwFreeObj(oRelacDTX)
FwFreeObj(oRelacDTW)
FwFreeObj(oRelacDUA)
FwFreeObj(oRelacDTY)
FwFreeObj(oRelacDFV)

Return 

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 13/06/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function RetX3()

Local cRet  := getsx3cache("DTQ_VIAGEM","X3_RELACAO")

If IsInCallStack('TMSA146')
	cRet := ''
EndIf

Return cRet
