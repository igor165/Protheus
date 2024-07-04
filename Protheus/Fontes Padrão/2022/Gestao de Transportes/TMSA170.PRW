#INCLUDE "TmsA170.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

Static lPainel := IsInCallStack("TMSAF76")
Static lTemDMQ := AliasInDic("DMQ")

Static oBrowseDTC := Nil
Static oBrowseDT5 := Nil
Static oBrowseDT4 := Nil
Static oBrowseDT6 := Nil
Static oBrowseSE1 := Nil
Static oBrowseDL5 := Nil
Static oRelacDTC := Nil
Static oRelacDT5 := Nil
Static oRelacDT4 := Nil
Static oRelacDT6 := Nil
Static oRelacSE1 := Nil
Static oRelacDL5 := Nil
Static oFolders	:= Nil
Static cFilCodCli := Space(TamSX3("DT6_CLIREM")[1])
Static cFilLojCli := Space(TamSX3("DT6_LOJREM")[1])
Static cFilNumNFc := Space(TamSX3("DTC_NUMNFC")[1])
Static cFilSerNFc := Space(TamSX3("DTC_SERNFC")[1])
Static cFilFilOri := Space(TamSX3("DT5_FILORI")[1])
Static cFilNumSol := Space(TamSX3("DT5_NUMSOL")[1])
Static cFilNumCot := Space(TamSX3("DT4_NUMCOT")[1])
Static cFilFilDoc := Space(TamSX3("DT6_FILDOC")[1])
Static cFilDoc    := Space(TamSX3("DT6_DOC")[1])
Static cFilSerie  := Space(TamSX3("DT6_SERIE")[1])
Static cFilPrefix := Space(TamSX3("DT6_PREFIX")[1])
Static cFilNum    := Space(TamSX3("DT6_NUM")[1])
Static cFilTipo   := Space(TamSX3("DT6_TIPO")[1])
Static lPrimeiro  := .T.
Static lFilCliRem := .F. 
Static lFilCliDes := .F.
Static lFilCliCon := .F.
Static lFilCliDpc := .F.
Static lFilCliDev := .F.
Static lFilCliExp := .F.
Static lFilCliRec := .F.
Static lConfere   := .F.
Static cSrvConf   := ""

/*{Protheus.doc} TMSA170
    Lote de Entrada de Notas Fiscais
    @type Function
    @author Valdemar Roberto Mognon
    @since 02/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA170()
    (examples)
    @see (links_or_references)
*/
Function TMSA170(aAutoCab,nOpcAuto,aAutoItens)
Local aCoors	:= FWGetDialogSize( oMainWnd )   
Local aFolders	:= {}
Local aVetAuto	:= {}
Local aRotAnt	:= {}
Local oFWLayerUp:= Nil
Local oFWLayerDw:= Nil
Local oInferior	:= Nil
Local oPanelUp	:= Nil
Local oPnlCol1	:= Nil
Local oPnlCol2	:= Nil
Local oPnlCol3	:= Nil
Local oPnlCol4	:= Nil
Local oPnlCol5	:= Nil
Local oButton1	:= Nil
Local oButton2	:= Nil
Local lStaCTE	:= FindFunction("TF68StaCTE")
Local lAvbCTE	:= FindFunction("TF68AvbCTE")
Local cRet		:= ""
Local lAuto		:= !Empty(aAutoCab)
Local cPerg		:= "TMSA170"
Local aSetKey	:= {}
Local oTMSSX1	:= Nil
Local aPergunte	:= {}
Local lPerg		:= .F.

Private oDlgPrinc
Private oBrowseUp

Default aAutoCab   := {}
Default nOpcAuto   := 3
Default aAutoItens := {}

lConfere := .F.//TMSA170Cnf()

If !lAuto

	oTMSSX1	:= FWSX1Util():New()
	oTMSSX1:AddGroup(cPerg)
	oTMSSX1:SearchGroup()
	aPergunte := oTMSSX1:GetGroup(cPerg)

	If Len(aPergunte) > 0 .AND. Len(aPergunte[2]) > 0
		lPerg := .T.
		Aadd( aSetKey, { VK_F12, { || Pergunte( cPerg, .T. ) } } )
		TmsKeyOn(aSetKey)
	EndIf

	DEFINE MSDIALOG oDlgPrinc TITLE STR0001 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL	//-- "Lote de Entrada de Notas Fiscais."
	
		//-- Cria novo Layer
		oFWLayerUp := FWLayer():New()
		oFWLayerUp:Init(oDlgPrinc,.F.,.T.)
	
		//-- Cria as linhas do Layer
		oFWLayerUp:AddLine("UP",20,.F.)	//-- Adiciona linha superior (campos de filtros)
		oFWLayerUp:AddLine("MIDDLE",35,.F.)		//-- Adiciona linha mediana (browse dos lotes)
		oFWLayerUp:AddLine("DOWN",45,.F.)	//-- Adiciona linha inferior (browses inferiores)
	
		//-- Cria as janelas de filtro
		oFWLayerUp:AddCollumn("COLUMN1",27,.T.,"UP")
		oFWLayerUp:AddCollumn("COLUMN2",23,.T.,"UP")
		oFWLayerUp:AddCollumn("COLUMN3",23,.T.,"UP")
		oFWLayerUp:AddCollumn("COLUMN4",19,.T.,"UP")
		oFWLayerUp:AddCollumn("COLUMN5",08,.T.,"UP")
		oFWLayerUp:AddWindow("COLUMN1","WINDOW1",STR0103,100,.F.,.T.,,"UP",{||})	//-- "Nota Fiscal"
		oFWLayerUp:AddWindow("COLUMN2","WINDOW2",STR0100,100,.F.,.T.,,"UP",{||})	//-- "Coleta / Cotação"
		oFWLayerUp:AddWindow("COLUMN3","WINDOW3",STR0102,100,.F.,.T.,,"UP",{||})	//-- "Documento"
		oFWLayerUp:AddWindow("COLUMN4","WINDOW4",STR0101,100,.F.,.T.,,"UP",{||})	//-- "Fatura"
		oFWLayerUp:AddWindow("COLUMN5","WINDOW5",STR0099,100,.F.,.T.,,"UP",{||})	//-- "Ações"
		oFWLayerUp:SetLinSplit("UP",CONTROL_ALIGN_BOTTOM,{||UpdFolder(oFolders,oInferior)})
		oFWLayerUp:ClickLineSplit("UP")// Simula o Click para esconder o LayerUp

		oPnlCol1 := oFWLayerUp:GetWinPanel("COLUMN1","WINDOW1","UP")
		oPnlCol2 := oFWLayerUp:GetWinPanel("COLUMN2","WINDOW2","UP")
		oPnlCol3 := oFWLayerUp:GetWinPanel("COLUMN3","WINDOW3","UP")
		oPnlCol4 := oFWLayerUp:GetWinPanel("COLUMN4","WINDOW4","UP")
		oPnlCol5 := oFWLayerUp:GetWinPanel("COLUMN5","WINDOW5","UP")
	
		//-- Filtros da Nota Fiscal do Cliente
		TSay():New(011,001,{||STR0084},oPnlCol1,,,.F.,.F.,.F.,.T.,,,050,007)	//-- "Cliente : "
		TSay():New(011,080,{||STR0085},oPnlCol1,,,.F.,.F.,.F.,.T.,,,050,007)	//-- "Loja : "
		TSay():New(023,001,{||STR0086},oPnlCol1,,,.F.,.F.,.F.,.T.,,,050,007)	//-- "Nota Fiscal : "
		TSay():New(023,077,{||STR0087},oPnlCol1,,,.F.,.F.,.F.,.T.,,,050,007)	//-- "Série : "
	
		TGet():New(010,022,{|u| Iif(PCount() > 0,cFilCodCli := u,cFilCodCli)},oPnlCol1,042,007,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SA1","cFilCodCli")
		TGet():New(010,098,{|u| Iif(PCount() > 0,cFilLojCli := u,cFilLojCli)},oPnlCol1,025,007,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""   ,"cFilLojCli")
		TGet():New(022,032,{|u| Iif(PCount() > 0,cFilNumNFc := u,cFilNumNFc)},oPnlCol1,039,007,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,     ,"cFilNumNFc")
		TGet():New(022,094,{|u| Iif(PCount() > 0,cFilSerNFc := u,cFilSerNFc)},oPnlCol1,015,007,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,     ,"cFilSerNFc")
	
		TCheckBox():New(000,001,"Rem."  ,{|u| If(PCount()>0,lFilCliRem:=u,lFilCliRem)},oPnlCol1,090,008,,,,,,,,.T.,"Remetente",,)
		TCheckBox():New(000,026,"Dest." ,{|u| If(PCount()>0,lFilCliDes:=u,lFilCliDes)},oPnlCol1,090,008,,,,,,,,.T.,"Destinatario",,)    
		TCheckBox():New(000,051,"Cons." ,{|u| If(PCount()>0,lFilCliCon:=u,lFilCliCon)},oPnlCol1,090,008,,,,,,,,.T.,"Consignatario",,)    
		TCheckBox():New(000,076,"Desp." ,{|u| If(PCount()>0,lFilCliDpc:=u,lFilCliDpc)},oPnlCol1,090,008,,,,,,,,.T.,"Despachante",,)
		TCheckBox():New(000,101,"Dev."  ,{|u| If(PCount()>0,lFilCliDev:=u,lFilCliDev)},oPnlCol1,090,008,,,,,,,,.T.,"Devedor",,)
		TCheckBox():New(000,126,"Exp."  ,{|u| If(PCount()>0,lFilCliExp:=u,lFilCliExp)},oPnlCol1,090,008,,,,,,,,.T.,"Expedidor",,) 
		TCheckBox():New(000,151,"Rec."  ,{|u| If(PCount()>0,lFilCliRec:=u,lFilCliRec)},oPnlCol1,090,008,,,,,,,,.T.,"Recebedor",,) 
	
		//-- Filtros da Solicitação de Coleta e Cotação
		TSay():New(003,001,{||STR0088},oPnlCol2,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "FilOrigem : "
		TSay():New(003,073,{||STR0089},oPnlCol2,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Coleta : "
		TSay():New(018,001,{||STR0090},oPnlCol2,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Cotação : "
		TGet():New(003,030,{|u| Iif(PCount() > 0,cFilFilOri := u,cFilFilOri)},oPnlCol2,015,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SM0","cFilFilOri")
		TGet():New(003,093,{|u| Iif(PCount() > 0,cFilNumSol := u,cFilNumSol)},oPnlCol2,048,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,     ,"cFilNumSol")
		TGet():New(018,027,{|u| Iif(PCount() > 0,cFilNumCot := u,cFilNumCot)},oPnlCol2,048,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,     ,"cFilNumCot")
	
		//-- Filtros do CTe
		TSay():New(003,001,{||STR0091},oPnlCol3,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Fil Docto : "
		TSay():New(003,076,{||STR0092},oPnlCol3,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Docto : "
		TSay():New(018,001,{||STR0087},oPnlCol3,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Série : "
		TGet():New(003,027,{|u| Iif(PCount() > 0,cFilFilDoc := u,cFilFilDoc)},oPnlCol3,015,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SM0","cFilFilDoc")
		TGet():New(003,096,{|u| Iif(PCount() > 0,cFilDoc    := u,cFilDoc)}   ,oPnlCol3,048,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,     ,"cFilDoc")
		TGet():New(018,019,{|u| Iif(PCount() > 0,cFilSerie  := u,cFilSerie)} ,oPnlCol3,020,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,     ,"cFilSerie")
	
		//-- Filtros da Fatura
		TSay():New(003,001,{||STR0093},oPnlCol4,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Prefixo : "
		TSay():New(003,053,{||STR0094},oPnlCol4,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Número : "
		TSay():New(018,001,{||STR0095},oPnlCol4,,,.F.,.F.,.F.,.T.,,,050,008)	//-- "Tipo : "
		TGet():New(003,024,{|u| Iif(PCount() > 0,cFilPrefix :=u,cFilPrefix)},oPnlCol4,015,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cFilPrefix")
		TGet():New(003,076,{|u| iif(PCount() > 0,cFilNum    :=u,cFilNum)}   ,oPnlCol4,040,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","_Num")
		TGet():New(018,017,{|u| Iif(PCount() > 0,cFilTipo   :=u,cFilTipo)}  ,oPnlCol4,015,008,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"05","cFilTipo")
	
		//-- Botões de Filtro e Limpeza
		oButton1 := TButton():New(003,002,STR0096,oPnlCol5,{|| TMSA170Fil()},040,013,,,,.T.,,"",,,,.F.)	//-- "&Filtrar"
		oButton2 := TButton():New(018,002,STR0097,oPnlCol5,{|| TMSA170Cle()},040,013,,,,.T.,,"",,,,.F.)	//-- "&Limpar"
	
		//-- Browse superior dos lotes
		oFWLayerUp:AddCollumn("ALL",100,.T.,"MIDDLE")	//-- Adiciona coluna do Lote
		oPanelUp := oFWLayerUP:GetColPanel("ALL","MIDDLE")  
		oBrowseUp:= FWmBrowse():New()
		oBrowseUp:SetOwner(oPanelUp)
		oBrowseUp:SetAlias("DTP")
		oBrowseUp:SetMenuDef("TMSA170")
		oBrowseUp:DisableDetails() 
		oBrowseUp:SetProfileID("1") 
		oBrowseUp:ForceQuitButton()
		oBrowseUp:SetMainProc("TMSA170")
		oBrowseUp:AddLegend("DTP_STATUS=='1'","YELLOW",STR0009)	//-- Em Aberto
		oBrowseUp:AddLegend("DTP_STATUS=='2'","GREEN" ,STR0010)	//-- Digitado
		oBrowseUp:AddLegend("DTP_STATUS=='3'","BLUE"  ,STR0011)	//-- Calculado
		oBrowseUp:AddLegend("DTP_STATUS=='4'","RED"   ,STR0012)	//-- Bloqueado
		oBrowseUp:AddLegend("DTP_STATUS=='5'","ORANGE",STR0013)	//-- Erro de Gravação
		oBrowseUp:SetFilterDefault("@" + MontaSQL())
		
		//-- Cria os Folders da linha inferior
		aFolders  := {STR0112, STR0023,STR0024,STR0046,STR0025,STR0050,STR0065}	//-- Paineis Indicadores # Notas Fiscais # Solicitações de Coleta # Cotações # CTe-s # Faturas # Averbação CTe
		oInferior := oFWLayerUp:GetLinePanel("DOWN")
		oFolders  := TFolder():New(0,0,aFolders,aFolders,oInferior,,,,.T.,,oInferior:nClientWidth / 2,oInferior:nClientHeight / 2)
		oFolders:bChange := { |nFolder|  lCria := Nil, CriaBrow(nFolder, @lCria), Atualiza( nFolder, lCria ) }

		//-- Cria novo Layer para as pastas
		oFWLayerDw := FWLayer():New()
		oFWLayerDw:Init( oFolders:aDialogs[1], .F., .T. )
	
		//-- Cria linha do Layer inferior
		oFWLayerDw:AddLine("DETALHE",100,.F.)
	
		//-- Cria coluna das notas
		oFWLayerDw:AddCollumn("COLNOTAS",100,.T.,"DETALHE")
	
		//-- Cria coluna das coletas
		oFWLayerDw:AddCollumn("COLCOLS",100,.T.,"DETALHE")
	
		//-- Cria coluna das cotações
		oFWLayerDw:AddCollumn("COLCOTS",100,.T.,"DETALHE")
	
		//-- Cria coluna dos CTes
		oFWLayerDw:AddCollumn("COLCTES",100,.T.,"DETALHE")
	
		//-- Cria coluna das Faturas
		oFWLayerDw:AddCollumn("COLFATS",100,.T.,"DETALHE")
	
		//-- Cria coluna da Averbação do CTe
		oFWLayerDw:AddCollumn("COLAVBS",100,.T.,"DETALHE")

		//--  Browse Paineis
		If FindFunction('TMSPnlT170')
			cRet := TMSPnlT170("1")
			oPnlInd1 := TMSPainel():New(oFolders:aDialogs[1], STR0106, cRet,  {228, 3, 3},, 5,5) //Lotes pendentes de Calc.
			cRet := TMSPnlT170("2")
			oPnlInd2 := TMSPainel():New(oFolders:aDialogs[1], STR0107, cRet,  {50, 50, 205},, 120, 5) //"Lotes Bloqueados"
			cRet := TMSPnlT170("3")
			oPnlInd3 :=TMSPainel():New(oFolders:aDialogs[1], STR0108, cRet,  {255, 165, 0},, 235, 5) //"Documentos Pend. Trans"
			cRet := TMSPnlT170("4")
			oPnlInd4 := TMSPainel():New(oFolders:aDialogs[1], STR0109, cRet,  {117, 7, 135},, 350, 5) //"Documentos Rejeitados"
			cRet := TMSPnlT170("5")
			oPnlInd5 :=TMSPainel():New(oFolders:aDialogs[1], STR0110, cRet,  {50, 205, 50},, 465, 5) //"Coletas em aberto"
			cRet := TMSPnlT170("6")
			oPnlInd6 := TMSPainel():New(oFolders:aDialogs[1], STR0111 , cRet,  {35, 107, 142},, 580, 5) //"Cotações em aberto"
			cRet := TMSPnlT170("7")
			oPnlInd7 := TMSPainel():New(oFolders:aDialogs[1], STR0113 , cRet,  {204, 119, 34},, 695, 5) //"Documentos bloqueados"
		EndIf 

		 
		//-- Browse inferior das notas
		oBrowseDTC:= FWMBrowse():New()
		oBrowseDTC:SetOwner(oFolders:aDialogs[2])
		oBrowseDTC:SetDescription(STR0023)	//-- Notas Fiscais
		oBrowseDTC:SetMenuDef("TMSA050")
		oBrowseDTC:DisableDetails()
		oBrowseDTC:SetAlias("DTC") 	
		oBrowseDTC:SetProfileID("2")
		oBrowseDTC:SetMainProc("TMSA050")
		oBrowseDTC:AddLegend("TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='1'","YELLOW",STR0009)	//-- Em Aberto
		oBrowseDTC:AddLegend("TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='2'","GREEN" ,STR0010)	//-- Digitado
		oBrowseDTC:AddLegend("TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='3'","BLUE"  ,STR0011)	//-- Calculado
		oBrowseDTC:AddLegend("TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='4'","RED"   ,STR0012)	//-- Bloqueado
		oBrowseDTC:AddLegend("TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)=='5'","ORANGE",STR0013)	//-- Erro de Gravação
		oBrowseDTC:Activate()
	
		//-- Realiza relacionamento da nota com o lote
		oRelacDTC:= FWBrwRelation():New()
		oRelacDTC:AddRelation(oBrowseUp,oBrowseDTC,{{"DTC_FILIAL","xFilial('DTC')"},{"DTC_FILORI","DTP_FILORI"},{"DTC_LOTNFC","DTP_LOTNFC"}})
		oRelacDTC:Activate()
	
		oBrowseDT6:= FWMBrowse():New()
		oBrowseDT6:SetOwner(oFolders:aDialogs[5])
		oBrowseDT6:SetDescription(STR0025)	//-- CTe-s
		oBrowseDT6:SetMenuDef("TMSA200")
		oBrowseDT6:DisableDetails()
		oBrowseDT6:SetAlias("DT6") 	
		oBrowseDT6:SetProfileID("5")
		oBrowseDT6:SetMainProc("TMSA200")
		oBrowseDT6:AddLegend( "DT6_STATUS == '1' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'1')","BR_VERDE",STR0009)		//-- Em aberto
		oBrowseDT6:AddLegend( "DT6_STATUS == '2' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'2')","BR_VERMELHO",STR0033)	//-- Carregado / Indicado para Coleta
		oBrowseDT6:AddLegend( "DT6_STATUS == '3' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'3')","BR_AMARELO",STR0034)	//-- Em Trânsito / Coleta em Processo
		oBrowseDT6:AddLegend("(DT6_STATUS == '4' .And. DT6_SERIE <> 'COL' ) .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'5')","BR_LARANJA",STR0035)	//-- Chegada Parcial / Documento Informado
		oBrowseDT6:AddLegend("(DT6_STATUS == '5' .And. DT6_SERIE <> 'COL' ) .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'4')","BR_AZUL",STR0036)		//-- Chegada Final / Coleta Encerrada
		oBrowseDT6:AddLegend( "DT6_STATUS == '6'","BR_CINZA",STR0037)	//-- Indicado para Entrega
		oBrowseDT6:AddLegend( "DT6_STATUS == '7'","BR_MARROM",STR0038)	//-- Entregue
		oBrowseDT6:AddLegend( "DT6_STATUS == '8'","BR_PINK",STR0040)	//-- Entrega Parcial
		oBrowseDT6:AddLegend( "TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'9')","BR_PRETO",STR0039)	//-- Ordem de Coleta Cancelada
		oBrowseDT6:AddLegend( "DT6_STATUS == '9'","BR_CANCEL",STR0041)	//-- Anulado
		oBrowseDT6:AddLegend( "DT6_STATUS == 'A'","BR_BRANCO",STR0042)	//-- Retorno Total
		oBrowseDT6:AddLegend( "DT6_STATUS == 'B'","PMSEDT4",STR0043)		//-- Cancelamento SEFAZ Aguardando
		oBrowseDT6:AddLegend( "DT6_STATUS == 'C'","PMSEDT3",STR0044)		//-- Cancelamento SEFAZ Autorizado
		oBrowseDT6:AddLegend( "DT6_STATUS == 'D'","PMSEDT1",STR0045)		//-- Cancelamento SEFAZ Não Autorizado
		If lStaCTE
			oBrowseDT6:AddStatusColumns({||TF68StaCTE(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)},{||TF68LegCTE()})
		EndIf
		If lAvbCTE
			oBrowseDT6:AddStatusColumns({||TF68AvbCTE(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)},{||TF68LegAVB()})
		EndIf
		oBrowseDT6:Activate()
	
		//-- Realiza relacionamento do Cte com a nota
		oRelacDT6:= FWBrwRelation():New()
		oRelacDT6:AddRelation(oBrowseUp,oBrowseDT6,{{"DT6_FILIAL","xFilial('DT6')"},{"DT6_FILORI","DTP_FILORI"},{"DT6_LOTNFC","DTP_LOTNFC"}})
		oRelacDT6:Activate()	
	
		DTP->(DbSetOrder(1))   //Caso altere o indice, ajustar tambem na função TMSA170Ref()
		oBrowseUp:Activate()
	
	ACTIVATE MSDIALOG oDlgPrinc CENTER 
	If lPerg
		TmsKeyOff(aSetKey)
	EndIf
Else
	
	Aadd(aVetAuto,{"MdFieldDTP",aAutoCab})

	If lTemDMQ .And. !Empty(aAutoItens)
		Aadd(aVetAuto,{"MdGridDMQ",aAutoItens})
	EndIf
	
	If Type("aRotina") == "A"
		aRotAnt := aRotina
	EndIf

	aRotina := Menudef()
	
	FwMvcRotAuto(ModelDef(),"DTP",nOpcAuto,aVetAuto)
	
	If nOpcAuto == 3 .Or. nOpcAuto == 4
		Posicione("DTP",2,xFilial("DTP")+M->(DTP_FILORI+DTP_LOTNFC),"DTP_LOTNFC")
	EndIf
		
	cRet := DTP->DTP_LOTNFC
	
	If Len(aRotAnt) > 0
		aRotina := aRotAnt
	EndIf
EndIf

cFilCodCli := Space(TamSX3("DT6_CLIREM")[1])
cFilLojCli := Space(TamSX3("DT6_LOJREM")[1])
cFilNumNFc := Space(TamSX3("DTC_NUMNFC")[1])
cFilSerNFc := Space(TamSX3("DTC_SERNFC")[1])
cFilFilOri := Space(TamSX3("DT5_FILORI")[1])
cFilNumSol := Space(TamSX3("DT5_NUMSOL")[1])
cFilNumCot := Space(TamSX3("DT4_NUMCOT")[1])
cFilFilDoc := Space(TamSX3("DT6_FILDOC")[1])
cFilDoc    := Space(TamSX3("DT6_DOC")[1])
cFilSerie  := Space(TamSX3("DT6_SERIE")[1])
cFilPrefix := Space(TamSX3("DT6_PREFIX")[1])
cFilNum    := Space(TamSX3("DT6_NUM")[1])
cFilTipo   := Space(TamSX3("DT6_TIPO")[1])
lPrimeiro  := .T.
lFilCliRem := .F. 
lFilCliDes:= .F.
lFilCliCon := .F.
lFilCliDpc:= .F.
lFilCliDev := .F.
lFilCliExp := .F.
lFilCliRec := .F.

RetIndex("DTP")

Return cRet

/*{Protheus.doc} MenuDef
    Definição do aRotina (Menu funcional)
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 02/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example MenuDef()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()
Local aRotina  := {}
Local aOpcImp  := {}
Local aOpcCalc := {}
Local lTemImp  := ExistBlock("RTMSR35")
Local lTMSCTe  := SuperGetMv("MV_TMSCTE",.F.,.F.)	//-- Indica o CT-e ativo
Local aRet := {}

aRotina:= {{STR0002,"AxPesqui"       ,0,1,,.F.},; 	//"Pesquisar"
		   {STR0003,"VIEWDEF.TMSA170",0,2},;  		//"Visualizar"
		   {STR0004,"VIEWDEF.TMSA170",0,3},;  		//"Incluir"
		   {STR0005,"VIEWDEF.TMSA170",0,4},;  		//"Alterar"
		   {STR0006,"VIEWDEF.TMSA170",0,5}}  		//"Excluir"

//-- Define opções de impressão
If lTemImp
	Aadd(aOpcImp,{STR0072,"TMSA200Imp",0,2})	//-- CTR
	If FindFunction("TmsVerCTe")
		Aadd(aOpcImp,{STR0073,"TmsVerCTe",0,2})	//-- DACTE
	Else
		Aadd(aOpcImp,{STR0073,"U_RTMSR35",0,2})	//-- DACTE
	EndIf
	Aadd(aOpcImp,{STR0074,"TMSR625",0,2})		//-- Log Rejeição
EndIf

//-- Define opções de cálculo
If lTMSCTe
	aOpcCalc := {{STR0075,"TMSA050Sub(6)",0,2},;	//-- Fechar Lote
				 {STR0076,"TMSA050Sub(1)",0,2},;	//-- Calcular
				 {STR0077,"TMSA050Sub(2)",0,2},;	//-- Estornar
				 {STR0078,"TMSA050Sub(3)",0,2},;	//-- Recalculo
				 {STR0079,"TMSA050Sub(4)",0,2},;	//-- Consulta Documento
				 {STR0080,"TMSA050Sub(5)",0,2},;	//-- Refaturar
				 {STR0081,"TMSAE70(1)"   ,0,2}}		//-- CT-e
EndIf

If !Empty(aOpcImp)
	Aadd(aRotina,{STR0082,aOpcImp,0,6,0,NIL})	//-- Impressão
EndIf

If !Empty(aOpcCalc)
	Aadd(aRotina,{STR0083,aOpcCalc,0,6,0,NIL})	//-- Calculo Frete
EndIf

If ExistBlock("TMA170MNU")
	aRet := ExecBlock("TMA170MNU",.F.,.F.,{aRotina})
	If (ValType(aRet)=="A")
		aRotina := AClone(aRet)
	EndIf
EndIf

Return aRotina

/*{Protheus.doc} ModelDef
    Definição do Modelo
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 02/08/2021
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function ModelDef()
Local oModel     := Nil
Local oStruDTP   := FwFormStruct(1,"DTP")
Local oStruDUK   := Nil
Local oStruDMQ   := Nil
Local bLinPosDUK := {|oModel,nLine| PosVldDUK(oModel,nLine)}
Local bLdGridDUK := {|oModel| LdGridDUK(oModel)}
Local bPosVldDTP := {|oModel| PosVldMdl(oModel)}
Local bPreVldDTP := {|oModel| PreVldMdl(oModel)}
Local bCommitDTP := {|oModel| CommitMdl(oModel)}

//-- Cria a Model             
oModel := MpFormModel():New("TMSA170",bPreVldDTP,bPosVldDTP,bCommitDTP,/*bCancel*/)
oModel:SetDescription(STR0001)	//-- "Lote de Entrada de Notas Fiscais."

//-- Cabeçalho do Lote
oModel:AddFields("MdFieldDTP",,oStruDTP,,,)
oModel:SetPrimaryKey({"DTP_FILORI","DTP_LOTNFC"})
oModel:GetModel("MdFieldDTP"):SetDescription(STR0002)	//-- "Lote de Entrada de Notas Fiscais."

If lConfere
	//-- Grid das Conferências do Lote
	oStruDUK := FwFormStruct(1,"DUK")
	oModel:AddGrid("MdGridDUK","MdFieldDTP",oStruDUK,/*bPreValid*/,bLinPosDUK,/*bPre*/,/*bPost*/,bLdGridDUK)
	oModel:SetRelation("MdGridDUK",{{"DUK_FILIAL","xFilial('DUK')"},;
									{"DUK_FILORI","DTP_FILORI"},;
									{"DUK_LOTNFC","DTP_LOTNFC"}},;
									 DUK->(IndexKey(1)))
	oModel:GetModel("MdGridDUK"):SetOptional(.T.)
	oModel:GetModel("MdGridDUK"):SetForceLoad(.T.)
	oModel:GetModel("MdGridDUK"):SetDescription(STR0104)	//-- "Conferência do Lote"
	oModel:GetModel("MdGridDUK"):SetUniqueLine({"DUK_SERVIC","DUK_TAREFA","DUK_ATIVID"})
	oModel:GetModel("MdGridDUK"):SetNoInsertLine(.T.)
	oModel:GetModel("MdGridDUK"):SetNoDeleteLine(.T.)
EndIf

If lTemDMQ
	//-- Grid das Conferências do Lote
	oStruDMQ := FwFormStruct(1,"DMQ")
	oModel:AddGrid("MdGridDMQ","MdFieldDTP",oStruDMQ,/*bPreValid*/,/*bPos Valid*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("MdGridDMQ",{{"DMQ_FILIAL","xFilial('DMQ')"},;
									{"DMQ_FILORI","DTP_FILORI"},;
									{"DMQ_LOTNFC","DTP_LOTNFC"}},;
									 DMQ->(IndexKey(1)))
	oModel:GetModel("MdGridDMQ"):SetOptional(.T.)
	oModel:GetModel("MdGridDMQ"):SetDescription(STR0105)	//-- "Veículos do Lote"
	oModel:GetModel("MdGridDMQ"):SetUniqueLine({"DMQ_CODVEI"})
EndIf

Return oModel

/*{Protheus.doc} ViewDef
    Definição da View
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 02/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ViewDef()
    (examples)
    @see (links_or_references)
*/
Static Function ViewDef()
Local oModel   := FwLoadModel("TMSA170")
Local oView    := Nil
Local oStruDTP := FwFormStruct(2,"DTP")
Local oStruDUK := Nil
Local oStruDMQ := Nil
Local nTamDTP  := Iif(lConfere .And. lTemDMQ,40,Iif(lConfere .Or. lTemDMQ,50,100))
Local nTamDUK  := Iif(lTemDMQ,30,50)
Local nTamDMQ  := Iif(lConfere,30,50)

//-- Cria a View
oView := FwFormView():New()
oView:SetModel(oModel)

//-- Adiciona o Field
oView:AddField("VwFieldDTP",oStruDTP,"MdFieldDTP") 
oView:EnableTitleView("VwFieldDTP",STR0001)	//-- "Lote de Entrada de Notas Fiscais."

oView:CreateHorizontalBox("Lotes",nTamDTP)
oView:SetOwnerView("VwFieldDTP","Lotes")

If lConfere
	oStruDUK := FwFormStruct(2,"DUK")
	oView:CreateHorizontalBox("Atividades",nTamDUK)
	oView:AddGrid("VwGridDUK",oStruDUK,"MdGridDUK")
	oView:AddIncrementField("VwGridDUK","DUK_SEQUEN")
	oView:SetOwnerView("VwGridDUK","Atividades")
EndIf

If lTemDMQ
	oStruDMQ := FwFormStruct(2,"DMQ")
	oView:CreateHorizontalBox("Veiculos",nTamDMQ)
	oView:AddGrid("VwGridDMQ",oStruDMQ,"MdGridDMQ")
	oView:AddIncrementField("VwGridDMQ","DMQ_SEQUEN")
	oView:SetOwnerView("VwGridDMQ","Veiculos")
EndIf

Return oView

/*{Protheus.doc} TmsA170Vld
    Validação dos Campos
    @type Function
    @author Valdemar Roberto Mognon
    @since 05/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ViewDef()
    (examples)
    @see (links_or_references)
*/
Function TmsA170Vld()
Local cCampo     := ReadVar()
Local lRet       := .T.
Local nCntFor1   := 0
Local lTmsCFec   := TmsCFec()
Local aAreas     := {DA8->(GetArea()),DA3->(GetArea()),DUT->(GetArea()),DTQ->(GetArea()),DUD->(GetArea()),DF1->(GetArea()),DT5->(GetArea()),DT4->(GetArea()),GetArea()}
Local aMsgErr    := {}
Local cAliasQry  := ""
Local cQuery     := ""
Local cProGen    := Padr(SuperGetMV("MV_PROGEN",,""),Len(SB1->B1_COD))
Local lTMSCTe    := SuperGetMv("MV_TMSCTE",.F.,.F.)
Local cCliLojRem := ""
Local aAgends    := {}
Local aItensAg   := {}

If "DTP_QTDDIG" $ cCampo
	If FwFldGet("DTP_QTDDIG") > FwFldGet("DTP_QTDLOT")
		Help("",1,"TMSA17002")	//-- "A quantidade de notas digitadas nao pode ser maior que a quantidade de notas por lote."
		lRet := .F.
	EndIf
ElseIf "DTP_QTDLOT" $ cCampo
	If !Empty(FwFldGet("DTP_QTDDIG")) .And. FwFldGet("DTP_QTDLOT") < FwFldGet("DTP_QTDDIG")
		lRet := .F.
	EndIf

	If lRet .And. M->DTP_TIPLOT == StrZero(4,Len(DTP->DTP_TIPLOT)) .And. M->DTP_QTDLOT < 5
		Help(" " ,1, "TMSA17016") // "Quando o Tipo do Lote for CTe Único, a quantidade do lote de ser igual ou maior que 5!!"}
		lRet := .F.
	EndIf
ElseIf "DUK_DATINI" $ cCampo
	If !Empty(FwFldGet("DUK_DATFIM")) .And. FwFldGet("DUK_DATINI") > FwFldGet("DUK_DATFIM")
		lRet := .F.
	EndIf
ElseIf "DUK_DATFIM" $ cCampo
	If FwFldGet("DUK_DATFIM") < FwFldGet("DUK_DATINI")
		lRet := .F.
	EndIf
ElseIf cCampo $ "M->DTP_NUMSOL"
	If lPainel
		aAgends  := StrTokArr(aPanAgeTMS[4],",")
		aItensAg := StrTokArr(aPanAgeTMS[5],",")
		aMsgErr  := {}
		DF1->(DbSetOrder(1))
		For nCntFor1 := 1 To Len(aAgends)
			If DF1->(DbSeek(xFilial("DF1") + aAgends[nCntFor1] + aItensAg[nCntFor1]))
				If (DF1->DF1_FILDOC + DF1->DF1_DOC) != (FwFldGet("DTP_FILORI") + FwFldGet("DTP_NUMSOL"))
					Aadd(aMsgErr,{STR0020 + " " + aAgends[nCntFor1] + "-" + aItensAg[nCntFor1] + " " + STR0021,"00",""})	//-- "Agendamento:" ### "Coleta informada não confere com nenhum agendamento selecionado."
				EndIf
			Else
				Aadd(aMsgErr,{STR0020 + " " + aAgends[nCntFor1] + "-" + aItensAg[nCntFor1] + " " + STR0022,"00",""})	//-- "Agendamento:" ### "Não localizado para vínculo da coleta com o lote da viagem."
			EndIf
		Next nCntFor1
		If !Empty(aMsgErr)
			TmsMsgErr(aMsgErr)
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		DT5->(dbSetOrder(1))
		If DT5->(MsSeek(xFilial("DT5") + FwFldGet("DTP_FILORI") + FwFldGet("DTP_NUMSOL")))
			If !lTmsCFec
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Nao permite Solicitacao de Coleta com Status diferente de "Encerrada" ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If DT5->DT5_STATUS <> StrZero(4,Len(DT5->DT5_STATUS))	//-- Encerrada
			 		Help("",1,"TMSA05045")	//-- Só serão aceitas Solicitaçõees de Coletas Encerradas !!!
					lRet := .F.
				EndIf         
			Else
				If DT5->DT5_STATUS == StrZero(1,Len(DT5->DT5_STATUS)) .Or. ;	//-- Em Aberto
				   DT5->DT5_STATUS == StrZero(5,Len(DT5->DT5_STATUS)) .Or. ;	//-- Documento Informado
				   DT5->DT5_STATUS == StrZero(6,Len(DT5->DT5_STATUS)) .Or. ;	//-- Bloqueada
				   DT5->DT5_STATUS == StrZero(9,Len(DT5->DT5_STATUS))			//-- Cancelada
			 		Help("",1,"TMSA05060")	// Só serão aceitas Solicitações de Coletas com status diferente de 'Em Aberto', 'Documento informado' e 'Cancelado' !!!
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
ElseIf "DTP_VIAGEM" $ cCampo
	If !IsInCallStack("TMSF79LOT")
		lRet := TMSChkViag(FwFldGet("DTP_FILORI"),FwFldGet("DTP_VIAGEM"),.T.,.F.,.T.,,,,,.T.,.T.)   
	Else
		lRet := TMSChkViag(FwFldGet("DTP_FILORI"),FwFldGet("DTP_VIAGEM"),.T.,.F.,.F.,,,,,.T.,.T.)
	EndIf
	
	If lRet .And. !IsInCallStack("TMSA310GRV") .And. !IsInCallStack("TmsA144Grv")	//-- Fechamento De Viagem e ou Alteração da Viagem
		DTQ->(dbSetOrder(2))
		If ((DTQ->(DbSeek(xFilial("DTP") + FwFldGet("DTP_FILORI") + FwFldGet("DTP_VIAGEM")))) .And. DTQ->DTQ_SERTMS == "1")
		   	Help("",1,"TMSA17014")	//-- Não Permitido Gerar Lote De Coleta
			lRet := .F.
		EndIf
	EndIf
	
	If lRet 
		If !(AllTrim(FwFldGet("DTP_STATUS")) $ "1,2")
			Help("",1,"TMSA17006")	//-- Permitido alterar a Viagem somente de Lote com Status em aberto ou digitado!
			lRet := .F.
		Else
			DTQ->(dbSetOrder(2))
			If DTQ->(MsSeek(xFilial("DTQ") + FwFldGet("DTP_FILORI") + FwFldGet("DTP_VIAGEM"))) .And. DTQ->DTQ_STATUS == "2"	//-- Em Trânsito
				If ExistFunc("TMSLoteCli") 
					lRet := TMSLoteCli(FwFldGet("DTP_FILORI"),FwFldGet("DTP_LOTNFC"),@cCliLojRem)
					If lRet .And. ExistFunc("TMSLoteOpe")
						lRet := TMSLoteOpe(FwFldGet("DTP_FILORI"),FwFldGet("DTP_VIAGEM"),cCliLojRem)
					EndIf
				EndIf
				If lRet .And. ExistFunc("Tm350Apoio")
					lRet:= Tm350Apoio(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
				EndIf
			EndIf 	
		EndIf
	EndIf
	
	If lRet
		If IsInCallStack("A540RetMER") .And. DUU->(ColumnPos("DUU_FILORI")) > 0 .And. DUU->(ColumnPos("DUU_VIAGEM")) > 0
			If FwFldGet("DTP_VIAGEM") <> FwFldGet("DUU_VIAGEM")
				lRet := .F. 
				Help("",1,"TMSA17022")	//-- Não é permitido informar um número de viagem diferente do informado no registro de pendências.                                        
			EndIf
		EndIf
	EndIf
ElseIf "DTP_LOTNFC" $ cCampo
	If TmsExp() .And. IsInCallStack("TMSA144")
		If !Empty(FwFldGet("DTP_QTDDIG"))
			Help("",1,"TMSA17004")	//-- Existem Notas Fiscais utilizando este ,Lote.
			lRet := .F.
		EndIf
	EndIF
ElseIf "DTP_NUMCOT" $ cCampo
	If FwFldGet("DTP_STATUS") <> StrZero(1,Len(DTP->DTP_STATUS))	//-- Em Aberto
		Help("",1,"TMSA17009")	//-- Somente será permitido selecionar cotação de frete para lote em aberto.
		lRet := .F.
	ElseIf !Vazio() .And. (lRet := ExistCpo("DT4",FwFldGet("DTP_FILORI") + FwFldGet("DTP_NUMCOT")))
		DT4->(DbSetOrder(1))
		If DT4->(DbSeek(xFilial("DT4") + FwFldGet("DTP_FILORI") + FwFldGet("DTP_NUMCOT")))
			If DT4->DT4_STATUS <> StrZero(4,Len(DT4->DT4_STATUS)) .And. DT4->DT4_STATUS <> StrZero(9,Len(DT4->DT4_STATUS))
				If Posicione("DC5",1,xFilial("DC5") + DT4->DT4_SERVIC,"DC5_TIPRAT") == StrZero(0,Len(DC5->DC5_TIPRAT)) .Or. ;	//-- Não Tem
					DC5->DC5_TIPRAT == StrZero(4,Len(DC5->DC5_TIPRAT))	//-- Qtde Doctos
					Help("",1,"TMSA17007")	//-- Escolha uma cotação que possua serviço de transporte configurado para rateio de frete (DC5_TIPRAT) e que não utilize rateio por documento.
					lRet := .F.
				EndIf
			Else
				Help("",1,"TMSA17008")	//-- Nao será permitido selecionar cotação de frete encerrada ou cancelada.
				lRet := .F.
			EndIf
		EndIf
		//-- Verifica se foi informado o produto diferente do generico na cotacao
		If lRet
			cAliasQry := GetNextAlias()
			cQuery := " SELECT COUNT(DVF_CODPRO) CNT "
			cQuery += "   FROM " + RetSqlName("DVF")
			cQuery += "  WHERE DVF_FILIAL = '" + xFilial("DVF") + "' "
			cQuery += "    AND DVF_FILORI = '" + FwFldGet("DTP_FILORI") + "' "
			cQuery += "    AND DVF_NUMCOT = '" + FwFldGet("DTP_NUMCOT") + "' "
			cQuery += "    AND DVF_CODPRO <> '" + cProGen + "' "
			cQuery += "    AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
			If (cAliasQry)->CNT > 0
				Help("",1,"TMSA17010")	//-- Somente será permitido selecionar cotação de frete com produto generico informado.
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf
ElseIf "DTP_TIPLOT" $ cCampo
	If FwFldGet("DTP_TIPLOT") == StrZero(3,Len(DTP->DTP_TIPLOT)) .And. !lTMSCTe
		Help("",1,"TMSA17013")	//-- "Lote Eletrônico aceito apenas quando o parâmetro MV_TMSCTE estiver ativo"}
		lRet := .F.
	ElseIf FwFLdGet("DTP_TIPLOT") == StrZero(4,Len(DTP->DTP_TIPLOT)) .And. M->DTP_QTDLOT < 5 .And. !IsInCallStack("TMSA500")
		Help("",1,"TMSA17016")	//-- "Quando o Tipo do Lote for CTe Único, a quantidade do lote de ser igual ou maior que 5!!"}
		lRet := .F.
	ElseIf FwFldGet("DTP_TIPLOT") == StrZero(5,Len(DTP->DTP_TIPLOT))
		If !IsInCallStack("TMSA310GRV") .And. (IsInCallStack("TMSA144GRV") .And. M->DTQ_SERADI != "1")	//-- Fechamento De Viagem ou gravação de viagem de entrega com serviço adicional de coleta
			Help("",1,"TMSA17019")	//-- "Função disponínel somente para custeio de coletas nas rotinas automáticas","Selecione um tipo válido."
			lRet := .F.
		EndIf
	EndIf
ElseIf "DMQ_CODVEI" $ cCampo
	DA3->(DbSetOrder(1))
	If DA3->(DbSeek(xFilial("DA3") + FwFldGet("DMQ_CODVEI")))
		DUT->(DbSetOrder(1))
		If DUT->(DbSeek(xFilial("DUT") + DA3->DA3_TIPVEI))
			If DUT->DUT_CATVEI == StrZero(3,Len(DUT->DUT_CATVEI))
				Help("",1,"TMSA17023")	//-- Não é permitido carreta como veículo tracionador.
				lRet := .F.
			EndIf
		EndIf
	EndIf
ElseIf "DMQ_CODRB1" $ cCampo
	DA3->(DbSetOrder(1))
	If DA3->(DbSeek(xFilial("DA3") + FwFldGet("DMQ_CODRB1")))
		DUT->(DbSetOrder(1))
		If DUT->(DbSeek(xFilial("DUT") + DA3->DA3_TIPVEI))
			If DUT->DUT_CATVEI != StrZero(3,Len(DUT->DUT_CATVEI))
				Help("",1,"TMSA17024")	//-- Somente é permitido veículos do tipo carreta.
				lRet := .F.
			EndIf
		EndIf
	EndIf
ElseIf "DMQ_CODRB2" $ cCampo
	DA3->(DbSetOrder(1))
	If DA3->(DbSeek(xFilial("DA3") + FwFldGet("DMQ_CODRB2")))
		DUT->(DbSetOrder(1))
		If DUT->(DbSeek(xFilial("DUT") + DA3->DA3_TIPVEI))
			If DUT->DUT_CATVEI != StrZero(3,Len(DUT->DUT_CATVEI))
				Help("",1,"TMSA17024")	//-- Somente é permitido veículos do tipo carreta.
				lRet := .F.
			EndIf
		EndIf
	EndIf
ElseIf "DMQ_CODRB3" $ cCampo
	DA3->(DbSetOrder(1))
	If DA3->(DbSeek(xFilial("DA3") + FwFldGet("DMQ_CODRB3")))
		DUT->(DbSetOrder(1))
		If DUT->(DbSeek(xFilial("DUT") + DA3->DA3_TIPVEI))
			If DUT->DUT_CATVEI != StrZero(3,Len(DUT->DUT_CATVEI))
				Help("",1,"TMSA17024")	//-- Somente é permitido veículos do tipo carreta.
				lRet := .F.
			EndIf
		EndIf
	EndIf
ElseIf "DTP_ROTA" $ cCampo
	lRet := ExistCpo("DA8",M->DTP_ROTA,1)

	If lRet
		DA8->(DbSetOrder(1))
		DA8->(MsSeek(xFilial("DA8") + FwFldGet("DTP_ROTA")))
		If DA8->DA8_SERTMS != FwFldGet("DTP_SERTMS") .Or. DA8->DA8_TIPTRA != StrZero(1,Len(DTQ->DTQ_TIPTRA))
			Help("",1,"TMSA14403")	//-- "Rota não pertence ao Serviço de Transporte e ou Tipo de Transporte da viagem"
			lRet := .F.
		ElseIf DA8->DA8_ATIVO == StrZero(2,Len(DA8->DA8_ATIVO))
			Help("",1,"TMSA14405",,DA8->DA8_COD,3,1)	//-- "Rota não está ativa no Cadastro de Rotas: "
			lRet := .F.
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} PosVldDUK
    Validação das linhas do Grid
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 05/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ViewDef()
    (examples)
    @see (links_or_references)
*/
Static Function PosVldDUK(oModel,nLine)
Local lRet   := .T.
Local cModel := ""

Default oModel := FWModelActive()

cModel:= Upper(oModel:cId)

If cModel == Upper("MdGridDUK")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida a data e hora digitada.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !oModel:IsDeleted()
		lRet := ValDatHor(FwFldGet("DUK_DATFIM"),FwFldGet("DUK_HORFIM"),FwFldGet("DUK_DATINI"),FwFldGet("DUK_HORINI"))
	EndIf
EndIf

Return lRet

/*{Protheus.doc} PosVldMdl
    Validação antes da gravação
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 09/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ViewDef()
    (examples)
    @see (links_or_references)
*/
Static Function PosVldMdl(oModel)
Local lRet      := .T.
Local oModelDMQ	:= oModel:GetModel("MdGridDMQ")
Local aAreas    := {DA3->(GetArea()),DUT->(GetArea()),GetArea()}
Local nOperation:= oModel:GetOperation()
Local cAliasDE5	:= ""

Default oModel := FWModelActive()

If !Empty(FwFldGet("DMQ_CODRB1"))
	If Empty(FwFldGet("DMQ_CODVEI"))
		Help("",1,"TMSA17027")	//-- Para informar o reboque 1 é necessário que exista o veículo
		lRet := .F.
	EndIf
EndIf

If !Empty(FwFldGet("DMQ_CODRB2"))
	If Empty(FwFldGet("DMQ_CODRB1"))
		Help("",1,"TMSA17025")	//-- Para informar o reboque 2 é necessário que exista o reboque 1
		lRet := .F.
	EndIf
EndIf

If lRet .And. !Empty(FwFldGet("DMQ_CODRB3"))
	If Empty(FwFldGet("DMQ_CODRB2"))
		Help("",1,"TMSA17026")	//-- Para informar o reboque 3 é necessário que exista o reboque 2
		lRet := .F.
	EndIf
EndIf

If lRet .And. lTemDMQ
	If !oModelDMQ:IsEmpty() .And. Empty(FwFldGet("DTP_VIAGEM")) .And. Empty(FwFldGet("DTP_ROTA"))
		Help("",1,"TMSA17028")	//-- Lotes com veículo informado devem possuir rota
		lRet := .F.
	EndIf
EndIf

//Valida tabela DE5
If lRet .And. nOperation == MODEL_OPERATION_DELETE
	cAliasDE5 := GetNextAlias()
	cQuery := " SELECT COUNT(DE5_DOC) CONT "
	cQuery += "   FROM " + RetSqlName("DE5") + " DE5 "
	cQuery += "  WHERE DE5.DE5_FILIAL = '" + xFilial("DE5") + "' "
	cQuery += "    AND DE5.DE5_FILORI = '" + FwFldGet("DTP_FILORI") + "' "
	cQuery += "    AND DE5.DE5_LOTNFC = '" + FwFldGet("DTP_LOTNFC") + "' "
	cQuery += "    AND DE5.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDE5,.F.,.T.)
	If !(cAliasDE5)->(Eof()) .And. (cAliasDE5)->CONT > 0
		Help("",1,"TMSA17004")	//-- Existem Notas Fiscais utilizando este Lote.
		lRet := .F.
	EndIf
	(cAliasDE5)->(DbCloseArea())
EndIf

If lRet .And. !Empty(FwFldGet("DMQ_CODVEI")) .And. Empty(FwFldGet("DMQ_CODRB1"))
	DA3->(DbSetOrder(1))
	If DA3->(DbSeek(xFilial("DA3") + FwFldGet("DMQ_CODVEI")))
		DUT->(DbSetOrder(1))
		If DUT->(DbSeek(xFilial("DUT") + DA3->DA3_TIPVEI))
			If DUT->DUT_CATVEI == StrZero(2,Len(DUT->DUT_CATVEI))
				Help("",1,"TMSA17029")	//-- Quando o veículo tracionador for cavalo, é obrigatória a informção de ao menos uma carreta.
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} CommitMdl
    Gravação
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 05/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ViewDef()
    (examples)
    @see (links_or_references)
*/
Static Function CommitMdl(oModel)
Local aAreas     := {DT4->(GetArea())}
Local nOperation := 0
Local lRet       := .T.
Local cQuery     := ""
Local cAliasDTC  := ""
Local oMdFldDTP
Local oMdGridDUK

Default oModel := FWModelActive()

oMdFldDTP  := oModel:GetModel("MdFieldDTP")
oMdGridDUK := oModel:GetModel("MdGridDUK")
nOperation := oMdFldDTP:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_DELETE
		If FwFldGet("DTP_QTDDIG") == 0
			//-- Atualiza Status da Cotacao de Frete
			If !Empty(FwFldGet("DTP_NUMCOT"))
				DT4->(DbSetOrder(1))
				If DbSeek(xFilial("DT4") + FwFldGet("DTP_FILORI") + FwFldGet("DTP_NUMCOT"))
					RecLock("DT4",.F.)
					DT4->DT4_STATUS := "1"	//-- Cotacao de Frete Pendente
					DT4->(MsUnLock())
				EndIf             
			EndIf
		Else
			Help("",1,"TMSA17004")	//-- Existem Notas Fiscais utilizando este Lote.
		EndIf		
	Else
		//-- Atualiza Status da Cotacao de Frete
		If !Empty(FwFldGet("DTP_NUMCOT"))
			DT4->(DbSetOrder(1))
			If DbSeek(xFilial("DT4") + FwFldGet("DTP_FILORI") + FwFldGet("DTP_NUMCOT"))
				RecLock("DT4",.F.)
				DT4->DT4_STATUS := "4"	//-- Cotacao de Frete Encerrada
				DT4->(MsUnLock())
			EndIf             
		EndIf

		If nOperation == MODEL_OPERATION_UPDATE
			cAliasDTC := GetNextAlias()
			cQuery := " SELECT * "
			cQuery += "   FROM " + RetSqlName("DTC") + " DTC "
			cQuery += "  WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
			cQuery += "    AND DTC.DTC_FILORI = '" + FwFldGet("DTP_FILORI") + "' "
			cQuery += "    AND DTC.DTC_LOTNFC = '" + FwFldGet("DTP_LOTNFC") + "' "
			cQuery += "    AND DTC.DTC_DOC    = ' ' "
			cQuery += "    AND DTC.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC,.F.,.T.)
			If (cAliasDTC)->(Eof())
				If FwFldGet("DTP_QTDLOT") > 0 .And. FwFldGet("DTP_QTDLOT") == FwFldGet("DTP_QTDDIG")
					oMdFldDTP:LoadValue("DTP_STATUS",StrZero(3,Len(DTP->DTP_STATUS)))
				Else
					oMdFldDTP:LoadValue("DTP_STATUS",StrZero(1,Len(DTP->DTP_STATUS)))
				EndIf
			Else
				If FwFldGet("DTP_QTDLOT") > 0 .And. FwFldGet("DTP_QTDLOT") == FwFldGet("DTP_QTDDIG")
					oMdFldDTP:LoadValue("DTP_STATUS",StrZero(2,Len(DTP->DTP_STATUS)))
				Else
					oMdFldDTP:LoadValue("DTP_STATUS",StrZero(1,Len(DTP->DTP_STATUS)))
				EndIf
			EndIf	
			(cAliasDTC)->(DbCloseArea())
		EndIf
	EndIf

	lRet := FwFormCommit(oModel)

	If !lRet
		DisarmTransaction()
		Break
	EndIf

End Transaction

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMSA170Whe
    Muda edição dos campos
    @type Function
    @author Valdemar Roberto Mognon
    @since 05/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ViewDef()
    (examples)
    @see (links_or_references)
*/
Function TMSA170Whe(cCampo)
Local lRet       := .T.
Local aAreas     := {DTQ->(GetArea()),GetArea()}
Local oModel     := FWModelActive()
Local oMdFldDTP  := oModel:GetModel("MdFieldDTP")
Local nOperation := oMdFldDTP:GetOperation()

Default cCampo   := ReadVar()

If "DTP_RATEIO" $ cCampo
	If !IsBlind()
		If nOperation == MODEL_OPERATION_UPDATE
			lRet := .T.
		ElseIf FwFldGet("DTP_QTDDIG") > 0
			lRet := .F.
		ElseIf FwFldGet("DTP_QTDDIG") == 0
			lRet := .T.
		EndIf
	EndIf
ElseIf "DTP_VIAGEM" $ cCampo
	If nOperation == MODEL_OPERATION_UPDATE
		DTQ->(DbSetOrder(2))
		If DTQ->(DbSeek(xFilial("DTP") + FwFldGet("DTP_FILORI") + FwFldGet("DTP_VIAGEM"))) .And. DTQ->DTQ_STATUS == "2"
			lRet := .F.
		EndIf
	EndIf
EndIf	

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} Atualiza
Atualiza os browses inferiores
@type Static Function
@author Valdemar Roberto Mognon
@since 19/04/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Static Function Atualiza(nFolder, lCria)

Default nFolder := 1

Do Case
	Case nFolder == 2
		oBrowseDTC:Refresh(lCria)
	Case nFolder == 3
		oBrowseDT5:Refresh(lCria)
	Case nFolder == 4
		oBrowseDT4:Refresh(lCria)
	Case nFolder == 5
		oBrowseDT6:Refresh(.T.)
	Case nFolder == 6
		oBrowseSE1:Refresh(lCria)
	Case nFolder == 7
		oBrowseDL5:Refresh(lCria)
EndCase

Return .T.

/*{Protheus.doc} TMSA170Fil
Filtra os lotes
@type Static Function
@author Valdemar Roberto Mognon
@since 10/05/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Function TMSA170Fil( lExbHlp, nMVPAR01 )

Local nDias		:= 0

Default lExbHlp := .T.
Default nMVPAR01:= 0

If lExbHlp .And. Empty(cFilCodCli + cFilLojCli + cFilNumNFc + cFilSerNFc + cFilFilOri + cFilNumSol + cFilNumCot + ;
					   cFilFilDoc + cFilDoc + cFilSerie + cFilPrefix + cFilNum + cFilTipo)
	Help("",1,"TMSAF6001")
Else
	oBrowseUp:SetFilterDefault("@" + MontaSQL())
EndIf

If FindFunction("TMSPnlT170")
	
	If nMVPAR01 > 0
		nDias := nMVPAR01
	EndIf

	cRet := TMSPnlT170("1", cFilFilOri, nDias )
	oPnlInd1:AtuValor(cRet)
	cRet := TMSPnlT170("2", cFilFilOri, nDias )
	oPnlInd2:AtuValor(cRet)
	cRet := TMSPnlT170("3", cFilFilOri, nDias )
	oPnlInd3:AtuValor(cRet)
	cRet := TMSPnlT170("4", cFilFilOri, nDias )
	oPnlInd4:AtuValor(cRet)
	cRet := TMSPnlT170("5", cFilFilOri, nDias )
	oPnlInd5:AtuValor(cRet)
	cRet := TMSPnlT170("6", cFilFilOri, nDias )
	oPnlInd6:AtuValor(cRet)
	cRet := TMSPnlT170("7", cFilFilOri, nDias )
	oPnlInd7:AtuValor(cRet)
EndIf

Return .T.

/*{Protheus.doc} TMSA170Cle
Limpa os filtros
@type Static Function
@author Valdemar Roberto Mognon
@since 10/05/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Static Function TMSA170Cle()

cFilCodCli := Space(TamSX3("DT6_CLIREM")[1])
cFilLojCli := Space(TamSX3("DT6_LOJREM")[1])
cFilNumNFc := Space(TamSX3("DTC_NUMNFC")[1])
cFilSerNFc := Space(TamSX3("DTC_SERNFC")[1])
cFilFilOri := Space(TamSX3("DT5_FILORI")[1])
cFilNumSol := Space(TamSX3("DT5_NUMSOL")[1])
cFilNumCot := Space(TamSX3("DT4_NUMCOT")[1])
cFilFilDoc := Space(TamSX3("DT6_FILDOC")[1])
cFilDoc    := Space(TamSX3("DT6_DOC")[1])
cFilSerie  := Space(TamSX3("DT6_SERIE")[1])
cFilPrefix := Space(TamSX3("DT6_PREFIX")[1])
cFilNum    := Space(TamSX3("DT6_NUM")[1])
cFilTipo   := Space(TamSX3("DT6_TIPO")[1])
lFilCliRem := .F. 
lFilCliDes := .F.
lFilCliCon := .F.
lFilCliDpc := .F.
lFilCliDev := .F.
lFilCliExp := .F.
lFilCliRec := .F.
lPrimeiro  := .T.

TMSA170Fil(.F.)

Return

/*{Protheus.doc} MontaSQL
Monta instrução de filtros
@type Static Function
@author Valdemar Roberto Mognon
@since 10/05/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Static Function MontaSQL()
Local nCntFor1   := 0
//-- Variaveis de controle do loop de clientes
Local aCheckBox  := {lFilCliRem,lFilCliDes,lFilCliCon,lFilCliDpc,lFilCliDev,lFilCliExp,lFilCliRec}
Local aCposCli   := {"REM","DES","CON","DPC","DEV","EXP","REC"}
Local lTemCliAnt := .F.
//-- Variaveis de controle dos filtros que foram preenchidos
Local lTemCodCli := !Empty(cFilCodCli)
Local lTemLojCli := !Empty(cFilLojCli)
Local lTemNumNFc := !Empty(cFilNumNFc)
Local lTemSerNFc := !Empty(cFilSerNFc)
Local lTemFilOri := !Empty(cFilFilOri)
Local lTemNumSol := !Empty(cFilNumSol)
Local lTemNumCot := !Empty(cFilNumCot)
Local lTemFilDoc := !Empty(cFilFilDoc)
Local lTemDoc    := !Empty(cFilDoc)
Local lTemSerie  := !Empty(cFilSerie)
Local lTemPrefix := !Empty(cFilPrefix)
Local lTemNum    := !Empty(cFilNum)
Local lTemTipo   := !Empty(cFilTipo)
//-- Variaveis para montagem do filtro
Local cQuery     := ""
Local cFiltro    := ""
//-- Variaveis das tabelas possiveis na query
Local cFromDTC   := RetSqlName("DTC") + " DTC "
Local cFromDT6   := RetSqlName("DT6") + " DT6 "
//-- Variaveis de controle para montagem das clausulas where
Local cWhereCli  := ""
Local cWhereNFc  := ""
Local cWhereCol  := ""
Local cWhereDoc  := ""
Local cWhereFat  := ""
//-- Variaveis das clausulas where que sao fixas
Local cWhereDTC  := "WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "' " + ;
					"  AND DTC.DTC_FILORI = DTP_FILORI " + ;
					"  AND DTC.DTC_LOTNFC = DTP_LOTNFC " + ;
					"  AND DTC.D_E_L_E_T_ = ' ' "
Local cWhereDT6  := "  AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "' " + ;
					"  AND DT6.DT6_FILORI = DTP_FILORI " + ;
					"  AND DT6.DT6_LOTNFC = DTP_LOTNFC " + ;
					"  AND DT6.D_E_L_E_T_ = ' ' "

If !lPrimeiro
	cQuery += " (EXISTS (SELECT 1"
	cQuery += "            FROM " + cFromDTC
	If (lTemFilDoc .And. lTemDoc .And. lTemSerie) .Or. (lTemPrefix .And. lTemNum .And. lTemTipo)
		cQuery += "            ," + cFromDT6
	EndIf
	
	If lTemCodCli .Or. lTemNumNFc

		For nCntFor1 := 1 To Len(aCheckBox)
			If aCheckBox[nCntFor1]
				cWhereCli += Iif(lTemCodCli,Iif(lTemCliAnt," OR "," AND ("),"")
				cWhereCli += Iif(lTemCodCli," (DTC_CLI" + aCposCli[nCntFor1] + " = '" + cFilCodCli + "' ","")
				cWhereCli += Iif(lTemCodCli .And. lTemLojCli," AND DTC_LOJ" + aCposCli[nCntFor1] + " = '" + cFilLojCli + "' ","")
				cWhereCli += ") "
				lTemCliAnt := .T.
			EndIf
		Next nCntFor1
		cWhereCli += Iif(!Empty(cWhereCli),")","")
		
		cWhereNFc += Iif(lTemNumNFc," AND (DTC.DTC_NUMNFC = '" + cFilNumNFc + "'","")
		cWhereNFc += Iif(lTemNumNFc .And. lTemSerNFc," AND DTC.DTC_SERNFC = '" + cFilSerNFc + "'","")
		cWhereNFc += Iif(!Empty(cWhereNFc),") ","")
	EndIf
	
	If lTemFilOri .And. (lTemNumSol .Or. lTemNumCot)
		cWhereCol += " AND DTC.DTC_FILCFS = '" + cFilFilOri + "' "
		cWhereCol += Iif(lTemNumSol," AND DTC.DTC_NUMSOL = '" + cFilNumSol + "' ","")
		cWhereCol += Iif(lTemNumCot," AND DTC.DTC_NUMCOT = '" + cFilNumCot + "' ","")
	EndIf
	
	If (lTemFilDoc .And. lTemDoc .And. lTemSerie) .Or. (lTemPrefix .And. lTemNum .And. lTemTipo)
		cWhereDoc += cWhereDT6
		If (lTemFilDoc .And. lTemDoc .And. lTemSerie)
			cWhereDoc += "  AND DT6.DT6_FILDOC = '" + cFilFilDoc + "' "
			cWhereDoc += "  AND DT6.DT6_DOC    = '" + cFilDoc + "' "
			cWhereDoc += "  AND DT6.DT6_SERIE  = '" + cFilSerie + "' "
		EndIf
		If lTemPrefix .And. lTemNum .And. lTemTipo
			cWhereFat += "  AND DT6.DT6_PREFIX = '" + cFilPrefix + "' "
			cWhereFat += "  AND DT6.DT6_NUM    = '" + cFilNum + "' "
			cWhereFat += "  AND DT6.DT6_TIPO   = '" + cFilTipo + "' "
		EndIf
	EndIf

	If !Empty(cWhereDTC + cWhereCli + cWhereNFc + cWhereCol + cWhereDoc + cWhereFat)
	    cFiltro := cQuery + cWhereDTC + cWhereCli + cWhereNFc + cWhereCol + cWhereDoc + cWhereFat + ")) "
	EndIf
Else
	lPrimeiro := .F.
EndIf

FwFreeArray(aCheckBox)
FwFreeArray(aCposCli)

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

Static Function CriaBrow( nFolder, lCria)
Local lAvbCTE := FindFunction("TF68AvbCTE")

Default nFolder := 1

Do Case
	//Paineis indicadores
	Case nFolder == 1 .And. FindFunction('TMSPnlT170') 
		cRet := TMSPnlT170("1")
		oPnlInd1:AtuValor(cRet)
		cRet := TMSPnlT170("2")
		oPnlInd2:AtuValor(cRet)
		cRet := TMSPnlT170("3")
		oPnlInd3:AtuValor(cRet)
		cRet := TMSPnlT170("4")
		oPnlInd4:AtuValor(cRet)
		cRet := TMSPnlT170("5")
		oPnlInd5:AtuValor(cRet)
		cRet := TMSPnlT170("6")
		oPnlInd6:AtuValor(cRet)
		cRet := TMSPnlT170("7")
		oPnlInd7:AtuValor(cRet)

	Case nFolder == 3 .AND. Valtype(oBrowseDT5) == "U"
		aRotina := {}
		oBrowseDT5:= FWMBrowse():New()
		oBrowseDT5:SetOwner(oFolders:aDialogs[3])
		oBrowseDT5:SetDescription(STR0024)	//-- Solicitações de Coleta
		oBrowseDT5:SetMenuDef("TMSA460")
		oBrowseDT5:DisableDetails()
		oBrowseDT5:SetAlias("DT5") 	
		oBrowseDT5:SetProfileID("3")
		oBrowseDT5:SetMainProc("TMSA460")
		oBrowseDT5:AddLegend("DT5_STATUS=='1'","GREEN" ,STR0009)	//-- Em Aberto
		oBrowseDT5:AddLegend("DT5_STATUS=='2'","RED"   ,STR0026)	//-- Indicada para Coleta
		oBrowseDT5:AddLegend("DT5_STATUS=='3'","YELLOW",STR0027)	//-- Em Trânsito
		oBrowseDT5:AddLegend("DT5_STATUS=='4'","BLUE"  ,STR0028)	//-- Encerrada
		oBrowseDT5:AddLegend("DT5_STATUS=='5'","ORANGE",STR0029)	//-- Documento Informado
		oBrowseDT5:AddLegend("DT5_STATUS=='6'","GRAY"  ,STR0030)	//-- Bloqueada
		oBrowseDT5:AddLegend("DT5_STATUS=='7'","BROWN" ,STR0031)	//-- Em Conferência
		oBrowseDT5:AddLegend("DT5_STATUS=='9'","BLACK" ,STR0032)	//-- Cancelada
		oBrowseDT5:Activate()

		//-- Realiza relacionamento da coleta com a nota
		oRelacDT5:= FWBrwRelation():New()
		oRelacDT5:AddRelation( oBrowseDTC, oBrowseDT5, { {"DT5_FILIAL","xFilial('DT5')" }, {"DT5_FILORI","DTC_FILORI"}, {"DT5_NUMSOL","DTC_NUMSOL"} } )
		oRelacDT5:Activate()
		lCria:= .T.
		
	Case nFolder == 4 .AND. Valtype(oBrowseDT4) == "U"
		aRotina := {}
		oBrowseDT4:= FWMBrowse():New()
		oBrowseDT4:SetOwner(oFolders:aDialogs[4])
		oBrowseDT4:SetDescription("Cotações")	//-- aqui
		oBrowseDT4:SetMenuDef("TMSA040")
		oBrowseDT4:DisableDetails()
		oBrowseDT4:SetAlias("DT4") 	
		oBrowseDT4:SetProfileID("4")
		oBrowseDT4:SetMainProc("TMSA040")
		oBrowseDT4:AddLegend("DT4_STATUS=='1'","BR_AMARELO" ,STR0047)	//-- Pendente
		oBrowseDT4:AddLegend("DT4_STATUS=='2'","BR_VERMELHO",STR0030)	//-- Bloqueada
		oBrowseDT4:AddLegend("DT4_STATUS=='3'","BR_VERDE"   ,STR0048)	//-- Aprovada
		oBrowseDT4:AddLegend("DT4_STATUS=='4'","BR_AZUL"    ,STR0028)	//-- Encerrada
		oBrowseDT4:AddLegend("DT4_STATUS=='5'","BR_BRANCO"  ,STR0049)	//-- Bloqueada Div. Produtos/RRE
		oBrowseDT4:AddLegend("DT4_STATUS=='9'","BR_PRETO"   ,STR0032)	//-- Cancelada
		oBrowseDT4:Activate()

		//-- Realiza relacionamento da cotação com a nota
		oRelacDT4:= FWBrwRelation():New()
		oRelacDT4:AddRelation(oBrowseDTC,oBrowseDT4,{{"DT4_FILIAL","xFilial('DT4')"},{"DT4_FILORI","DTC_FILORI"},{"DT4_NUMCOT","DTC_NUMCOT"}})
		oRelacDT4:Activate()
		lCria:= .T.	

	Case nFolder == 6 .AND. Valtype(oBrowseSE1) == "U"
		aRotina := {}
		oBrowseSE1:= FWMBrowse():New()
		oBrowseSE1:SetOwner(oFolders:aDialogs[6])
		oBrowseSE1:SetDescription(STR0050)	//-- Faturas
		oBrowseSE1:SetMenuDef("TMSA850")
		oBrowseSE1:DisableDetails()
		oBrowseSE1:SetAlias("SE1")
		oBrowseSE1:SetProfileID("6")
		oBrowseSE1:SetMainProc("TMSA850")
		oBrowseSE1:AddLegend("E1_SITFAT == '3'","BR_PRETO",STR0051)				//-- Fatura Cancelada
		oBrowseSE1:AddLegend("ROUND(E1_SALDO,2) == ROUND(E1_VALOR,2) .And. E1_SITUACA $ 'F6'","BR_AMARELO",STR0052)	//-- Fatura Protestada
		oBrowseSE1:AddLegend("ROUND(E1_SALDO,2) == 0","BR_VERMELHO",STR0053)	//-- Fatura Baixada
		oBrowseSE1:AddLegend("E1_SITFAT == '2'","BR_AZUL",STR0054)				//-- Fatura Impressa
		oBrowseSE1:AddLegend(".T.","BR_VERDE",STR0055)							//-- Fatura em Aberto
		oBrowseSE1:Activate()

		//-- Realiza relacionamento da Fatura com o CTe
		oRelacSE1:= FWBrwRelation():New()
		oRelacSE1:AddRelation(oBrowseDT6,oBrowseSE1,{{"E1_FILIAL","xFilial('SE1')"},{"E1_PREFIXO","DT6_PREFIX"},{"E1_NUM","DT6_NUM"},{"E1_TIPO","DT6_TIPO"}})
		oRelacSE1:Activate()
		lCria:= .T.

	Case nFolder == 7 .AND. Valtype(oBrowseDL5) == "U"
		aRotina := {}
		oBrowseDL5:= FWMBrowse():New()
		oBrowseDL5:SetOwner(oFolders:aDialogs[7])
		oBrowseDL5:SetDescription(STR0065)	//-- Averbação CTe
		oBrowseDL5:SetMenuDef("TMSA296")
		oBrowseDL5:DisableDetails()
		oBrowseDL5:SetAlias("DL5")
		oBrowseDL5:SetProfileID("7")
		oBrowseDL5:SetMainProc("TMSA296")
		If lAvbCTE
			oBrowseDL5:AddStatusColumns({||TF68AvbCTE(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)},{||TF68LegAVB()})
		EndIf
		oBrowseDL5:Activate()
		
		//-- Realiza relacionamento da Averbação com o Cte
		oRelacDL5:= FWBrwRelation():New()
		oRelacDL5:AddRelation(oBrowseDT6,oBrowseDL5,{{"DL5_FILIAL","xFilial('DL5')"},{"DL5_FILDOC","DT6_FILDOC"},{"DL5_DOC","DT6_DOC"},{"DL5_SERIE","DT6_SERIE"}})
		oRelacDL5:Activate()
		lCria:= .T.
EndCase

Return .T.

/*{Protheus.doc} TMSA170Cnf
    Define o uso da conferência do lote de notas fiscais
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 02/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA170()
    (examples)
    @see (links_or_references)
s*/
Static Function TMSA170Cnf()
Local lRet     := .T.
Local aAreas   := {DC5->(GetArea()),GetArea()}
Local cServico := SuperGetMV("MV_SVCLOT")	//-- Servico para Conferência de lote das notas fiscais

DC5->(DbSetOrder(1))

If (cServico == Nil) .Or. ValType(cServico) != "C" .Or. Empty(cServico)
	cSrvConf := ""
	lRet     := .F.
ElseIf DC5->(!DbSeek(xFilial("DC5") + cServico))
	Help("",1,"TMSA17003")	//-- Parametro MV_SVCLOT com o Codigo de Servico invalido!
	cSrvConf := ""
	lRet     := .F.
Else
	cSrvConf := cServico
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
	
Return lRet

/*{Protheus.doc} LdGridDUK
    Carrega as tarefas do serviço de conferência do lote
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 04/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA170()
    (examples)
    @see (links_or_references)
*/
Static Function LdGridDUK(oMdlGrdDUK)
Local aAreas     := {DUK->(GetArea()),DC5->(GetArea()),DC6->(GetArea()),GetArea()}
Local aRet       := {}
Local nOperation := oMdlGrdDUK:GetOperation()
Local nLinha     := 0
Local cSeekDC5   := ""
Local cSeekDC6   := ""
Local cSeekDUK   := ""

If !Empty(cSrvConf)
	If nOperation == 3
		DC5->(DbSetOrder(1))
		DC6->(DbSetOrder(1))
		If DC5->(DbSeek(cSeekDC5 := xFilial("DC5") + cSrvConf))
			While DC5->(!Eof()) .And. DC5->(DC5_FILIAL + DC5_SERVIC) == cSeekDC5
				If DC6->(DbSeek(cSeekDC6 := xFilial("DC6") + DC5->DC5_TAREFA))
					While DC6->(!Eof()) .And. DC6->(DC6_FILIAL + DC6_TAREFA) == cSeekDC6
						nLinha ++
						Aadd(aRet,{0,{xFilial("DUK"),;
									  StrZero(nLinha,Len(DUK->DUK_SEQUEN)),;
									  cSrvConf,;
									  Tabela("L4",cSrvConf,.F.),;
									  DC5->DC5_TAREFA,;
									  Tabela("L2",DC5->DC5_TAREFA,.F.),;
									  DC6->DC6_ATIVID,;
									  Tabela("L3",DC6->DC6_ATIVID,.F.),;
									  CToD(""),;
									  "0000",;
									  CToD(""),;
									  "0000",;
									  Space(Len(DUK->DUK_CODFUN)),;
									  Space(TamSX3("DUK_NOMFUN")[1])}})
						DC6->(DbSkip())
					EndDo
				EndIf
				DC5->(DbSkip())
			EndDo
		Endif
	Else
		DUK->(DbSetOrder(1))
		If DUK->(DbSeek(cSeekDUK := xFilial("DUK") + FwFldGet("DTP_FILORI") + FwFldGet("DTP_LOTNFC")))
			While DUK->(!Eof()) .And. DUK->(DUK_FILIAL + DUK_FILORI + DUK_LOTNFC) == cSeekDUK
				Aadd(aRet,{0,{xFilial("DUK"),;
							  DUK->DUK_SEQUEN,;
							  DUK->DUK_SERVIC,;
							  Tabela("L4",DUK->DUK_SERVIC,.F.),;
							  DUK->DUK_TAREFA,;
							  Tabela("L2",DUK->DUK_TAREFA,.F.),;
							  DUK->DUK_ATIVID,;
							  Tabela("L3",DUK->DUK_ATIVID,.F.),;
							  DUK->DUK_DATINI,;
							  DUK->DUK_HORINI,;
							  DUK->DUK_DATFIM,;
							  DUK->DUK_HORFIM,;
							  DUK->DUK_CODFUN,;
							  Posicione("DCD",1,xFilial("DCD") + DUK->DUK_CODFUN,"DCD_NOMFUN")}})
				DUK->(DbSkip())
			EndDo
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return aRet

/*{Protheus.doc} PreVldMdl
    Pré valida a entrada na tela
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 05/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA170()
    (examples)
    @see (links_or_references)
*/
Static Function PreVldMdl(oModel)
Local lRet       := .T.
Local dDataTMS   := GetMv("MV_DATATMS",.F.,CToD(""))  
Local lDataVld   := dDataBase <= dDataTMS
Local lViaCol    := DTP->(ColumnPos("DTP_VIACOL")) > 0                                                                              
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_UPDATE .And. !AllTrim(DTP->DTP_STATUS) $ "1/2"
	Help("",1,"TmsA17001")	//-- O Lote de Entrada ja foi Calculado ou Encerrado, nao e possivel manipular o mesmo.
	lRet := .F. 
ElseIf lDataVld
	Help("",1,"FECHATMS")  
	lRet := .F. 			
ElseIf DTP->DTP_FILORI <> cFilAnt
	If nOperation == MODEL_OPERATION_UPDATE
		Help("",1,"TMSA17011",,STR0015 + DTP->DTP_FILORI + " / " + STR0016 + DTP->DTP_LOTNFC,4,0)	//-- Nao e permitido alterar um Lote de outra Filial ### "Filial Origem" ### "Lote"
		lRet := .F. 
	ElseIf nOperation == MODEL_OPERATION_DELETE
		Help("",1,"TMSA17012",,STR0015 + DTP->DTP_FILORI + " / " + STR0016 + DTP->DTP_LOTNFC,4,0)	//-- Nao e permitido excluir um Lote de outra Filial ### "Filial Origem" ### "Lote"
		lRet := .F. 
	EndIf
ElseIf nOperation == MODEL_OPERATION_UPDATE .And. lViaCol .And. !Empty(DTP->DTP_VIACOL) .And. !IsInCallStack("TMSAF76") 
	Help("",1,"TMSA17018")	//-- Não é permitido alterar um lote gerado pelo painel de agendamentos, por esta rotina. 
	lRet := .F.  
EndIf

Return lRet

/*{Protheus.doc} TMSA170Mnt
    Função criada somente para compatibilizar a chamada da inclusão e validação no F3 do lote na entrada de NF
    @type Function
    @author Valdemar Roberto Mognon
    @since 11/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA170()
    (examples)
    @see (links_or_references)
*/
Function TMSA170Mnt(cAlias,nRecno,nOpcx)

Default cAlias := "DTP"
Default nRecno := 1
Default nOpcx  := 2

If nOpcx == 3
	FwExecView(,"TMSA170",3)
ElseIf nOpcx ==2
	FwExecView(STR0003,"TMSA170")
EndIf

Return

/*{Protheus.doc} TMSA170Leg
    Exibe Legenda
    @type Function
    @author Valdemar Roberto Mognon
    @since 17/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA170()
    (examples)
    @see (links_or_references)
*/
Function TMSA170Leg()
Local aLegenda := {}

aLegenda := {{"BR_AMARELO" ,STR0009},;	//-- "Em Aberto"
			 {"BR_VERDE"   ,STR0010},;	//-- "Digitado"
			 {"BR_AZUL"    ,STR0011},;	//-- "Calculado"
			 {"BR_VERMELHO",STR0012},;	//-- "Bloqueado"
			 {"BR_LARANJA" ,STR0013}}	//-- "Cancelado"

BrwLegenda(STR0014,STR0008,aLegenda)	//-- "Status do Lote" ### "Status"

Return NIL

/*{Protheus.doc} TMSA170Ref
    Refresh do Browse quando executado por outras rotinas
    @type Function
    @author Katia
    @since 29/10/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA170()
    (examples)
    @see (links_or_references)
*/
Function TMSA170Ref()
Local npos:=oBrowseUp:At()

	DTP->(DbSetOrder(1))
	//-- Quando a inclusão do Lote é realizada diretamente no TMSA050
	If IsInCallStack('TMSA050Mnt') 
		oBrowseUp:GoTop()     
	EndIf
	oBrowseUp:Refresh()	
	oBrowseUp:GoTo(nPos)
Return
