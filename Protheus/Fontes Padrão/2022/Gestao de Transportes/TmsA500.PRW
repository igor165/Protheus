#Include "TMSA500.ch" 
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

Static _cObsComp	:= ''
Static lTm500BUT	:= ExistBlock("TM500BUT")	//-- Permite adicionar botoes.
Static lTm500TR1	:= ExistBlock("TM500TR1")	//-- Troca a descricao das atividades de operacao do tracking
Static lTm500TR3	:= ExistBlock("TM500TR3")	//-- Ponto para Troca a descricao das atividades de Operacoes / Ocorrencias
Static lTm500CON	:= ExistBlock("TM500CON")	//-- Altera tratamnento para cliente contribuinte / não contribuinte
Static lTM500OK		:= ExistBlock("TM500OK")    //-- Ponto de entrada para validar se o processo deverá ser executado
Static lTM500DES	:= ExistBlock("TM500DES")    //-- Ponto de Entrada para Desabilitar o pergunte  da Reentrega e Devolução (calculado ou digitado).
Static lTm500V01	:= ExistBlock("TM500V01")	//-- Utilizado para demais validações no documento complementar
Static lTm500V02	:= ExistBlock("TM500V02")	//-- Utilizado para validações no documento de reentrega / devolução. 

Static l500Proc		:= .F.
Static cCdrOriPE	:= ""

//--- Variaveis de filtro 
Static cFilFilOri := Space(TamSX3("DT6_FILORI")[1])
Static cFilFilDes := Space(TamSX3("DT6_FILDES")[1])
Static dFilDataAte:= CtoD('')
Static dFilDataDe := CtoD('')
Static cFilCodCli := Space(TamSX3("DT6_CLIREM")[1])
Static cFilLojCli := Space(TamSX3("DT6_LOJREM")[1])
Static lFilCliRem := .F. 
Static lFilCliDes := .F.
Static lFilCliCon := .F.
Static lFilCliDpc := .F.
Static cFilNumNFC := Space(TamSX3("DTC_NUMNFC")[1])
Static cFilSerNFC := Space(TamSX3("DTC_SERNFC")[1])
Static cFilPfxFat := Space(TamSX3("DT6_PREFIX")[1])
Static cFilNroFat := Space(TamSX3("DT6_NUM")[1])
Static cFilTipFat := Space(TamSX3("DT6_TIPO")[1])
Static cFilNroVge := Space(TamSX3("DTQ_VIAGEM")[1])
Static cFaturado  := Space(5)
Static aIteFat    := {}

Static cTabDT6:= GetNextAlias()
Static oBrowseDT6, oBrowseDUA, oBrowseDTW, oBrowseDUD:= Nil
Static oBrowseSE1, oBrowseDTC, oBrowseDUB,oBrowseDUU := Nil
Static aRelacto   := {}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TMSA500  ³ Autor ³ Alex Egydio           ³ Data ³22.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao de documentos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - .T. Utilizado pelo TMSC030 p/consulta de documentos³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsA500( lVisual, cLoteAux, nOpc500, xAutoCab, xAutoItens, xAutoNfs, cFilParam)

Local aCores      := {}
Local lAlianca    := TMSAlianca() //-- Indica se utiliza Alianca
Local cFiltro     := ''
Local lRet        := .T.
Local aSetKey     := {}
Local cFilMbrPE   := ""
Local lPainel     := .F.
Local cFunNamOld  := FunName()

Local oPnlCol1, oPnlCol2 := Nil
Local oPnlCol3, oPnlCol4 := Nil
Local oInferior  := Nil
Local oFWLayerUp, oFWLayerDwn := Nil
Local aFolders  := {}
Local aCoors    := FWGetDialogSize( oMainWnd ) 
Local aLegBrw   := {}
Local nI        := 0
Local cFilBrw   := ""
Local lStaCTE   := FWAliasInDic("DL5",.F.) .And. FindFunction("TF68StaCTE")
Local lAvbCTE	:= FWAliasInDic("DL5",.F.) .And. FindFunction("TF68AvbCTE")
Local lStaFAT	:= FWAliasInDic("DL5",.F.) .And. FindFunction("TF68StaFat")
					
Private oDlgPrinc  := Nil 
Private oFolders   := Nil

Private cCadastro := STR0001 //'Manutencao de Documentos'
Private aRotina   := {}
Private cLoteAut  := ""
Private lTmsCFec  := .F.	//-- Desabilita nas funcoes do tmsa200 o tratamento de carga fechada
Private nDiaArm   := 0
Private lPenArm   := Iif(Type("lPenArm") == "U", .F., lPenArm)
Private cLoteCte  := ''
Private lUsaColab := .F.
Private cMarca	 := ""
Private oMark		 //Variavel sera utilizada na MarkBrowse
Private lTM500Auto := .F.

DEFAULT lVisual   := .F.
DEFAULT cLoteAux  := ""
DEFAULT nOpc500   := 0
DEFAULT cFilParam  := ""
DEFAULT xAutoCab   := {}
DEFAULT xAutoItens := {}
DEFAULT xAutoNfs   := {}

lTM500Auto := !Empty(nOpc500) .And. !Empty(xAutoCab) .And. !Empty(xAutoItens)
aIteFat    := {STR0302,STR0300,STR0301} //STR0302 "1=Todos",STR0300 "2=Sim",STR0301 "3=Não"

If lTM500Auto
	If ValType(xAutoCab) == "A" //-- Este tratamento deve-se ao fato que o TMSA200 até 24/05/2016 chamava o TMSA500 com um 4º argumento inexistente
		Private aAutoCab   := aClone(xAutoCab)
		Private aAutoItens := aClone(xAutoItens)
		Private aAutoNfs   := aClone(xAutoNfs)

		//-- Se a chamada for como MsExecAuto, limpa as variáveis da chamada antiga 
		lVisual    := .F.
		cLoteAux   := ""
	Else
		lTM500Auto := .F.
	EndIf
EndIf
lUsaColab := UsaColaboracao("2")

If Type("aPanAgeTMS") == "U"
	aPanAgeTMS := Array(6)
EndIf

lPainel := IsInCallStack("TMSAF76") .And. !Empty(aPanAgeTMS)

AAdd(aSetKey, { VK_F12 , { || TMS500Perg(.t.) } } )

If !Empty(cLoteAux)
	cLoteAut := cLoteAux
	cLoteCte := cLoteAux
EndIf

aCores := Tmsa500Cor()

SaveInter()

aRotina := MenuDef(lVisual,lAlianca)

DbSelectArea('DT6')
DbSetOrder(1)

If lTM500Auto
	lMsHelpAuto := .T.
	cFunNamOld := FunName()
	SetFunName("TMSA500")
	MBrowseAuto(nOpc500,Aclone(aAutoCab),"DT6")
	SetFunName(cFunNamOld)
Else
	If !Empty(cLoteAut)
		lRet := Iif(Tmsa500Mnt("DT6",DT6->(Recno()),nOpc500) == 0,.F.,.T.)
	Else
		//-- Inicializa Teclas de Atalhos
		TmsKeyOn(aSetKey)
	
		If ExistBlock("TM500FBR") //-- PE - Permite ao usuario filtrar a mbrowse
			cFilMbrPE := ExecBlock("TM500FBR",.F.,.F.)
			If ValType(cFilMbrPE) == "C" .And. !Empty(cFilMbrPE)
				cFiltro += cFilMbrPE
			EndIf
		EndIf

		If !Empty(cFilParam)
			cFiltro += Iif(!Empty(cFiltro)," AND ","") + "("+cFilParam+")"
		EndIf
	
		//-- Endereca a funcao de BROWSE
		If lPainel .and. !IsInCallStack("TMSA200Vis")
			If (at("(",aPanAgeTMS[6])>0)
				&(aPanAgeTMS[6])
			Else
				&(aPanAgeTMS[6] + "('" + aPanAgeTMS[1] + "'," + StrZero(aPanAgeTMS[2],10) + "," + StrZero(aPanAgeTMS[3],2) + ")")
			Endif
		Else			
			If FindFunction("T500MntSql") .And. FindFunction("TF68LegDT6") 	//--Novo Browse com ABAS
				// Trata a altura da janela de acordo com a resolução
				Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors [2] To aCoors[3], aCoors[4] Pixel

				// Cria conteiner para os browses
				oFWLayerUp:= FWLayer():New()
				oFWLayerUp:Init( oDlgPrinc, .F., .T.)

				// Define painel 
				oFWLayerUp:AddLine( 'UP'    , 20, .F.)
				oFWLayerUp:AddLine( 'MIDDLE', 40, .F.)
				oFWLayerUp:AddLine( 'DOWN'  , 40, .F.)

				// Define painel dos Filtros
				oFWLayerUp:AddCollumn('COL1', 25, .T., 'UP')
				oFWLayerUp:AddCollumn('COL2', 38, .T., 'UP')
				oFWLayerUp:AddCollumn('COL3', 28, .T., 'UP')
				oFWLayerUp:AddCollumn('COL4', 09, .T., 'UP')

				oFWLayerUp:AddWindow('COL1',"WIN1",STR0019,100,.F.,.T.,,'UP',{ || })   //Documento
				oFWLayerUp:AddWindow('COL2',"WIN2",STR0294,100,.F.,.T.,,'UP',{ || })   //Notas Fiscais
				oFWLayerUp:AddWindow('COL3',"WIN3",STR0293,100,.F.,.T.,,'UP',{ || })   //Faturas
				oFWLayerUp:AddWindow('COL4',"WIN4",STR0297,100,.F.,.T.,,'UP',{ || })   //Ações

				//oFWLayerUp:SetColSplit('COL1' , CONTROL_ALIGN_LEFT , 'UP')
				oFWLayerUp:SetLinSplit("UP" /*cIDLin*/, CONTROL_ALIGN_BOTTOM /*nAlign*/, {||UpdFolder(oFolders, oInferior)} /*bActionClose*/,/*bActionOpen*/, /*cSplitClose*/, /*cSplitOpen*/ )

				oFWLayerUp:ClickLineSplit("UP")// Simula o Click para esconder o LayerUp

				oPnlCol1 := oFWLayerUp:GetWinPanel('COL1',"WIN1",'UP')
				oPnlCol2 := oFWLayerUp:GetWinPanel('COL2',"WIN2",'UP')
				oPnlCol3 := oFWLayerUp:GetWinPanel('COL3',"WIN3",'UP')
				oPnlCol4 := oFWLayerUp:GetWinPanel('COL4',"WIN4",'UP')

				TSay():New(000,004,{||AllTrim(FWX3Titulo('DT6_FILORI')) }	,oPnlCol1,,,.F.,.F.,.F.,.T., , ,050,008) //"Fil.Origem: FWX3Titulo('DT6_FILORI')
				TGet():New(000,030,{|u| If(PCount()>0,cFilFilOri:=u,cFilFilOri)}	,oPnlCol1,015,008,"",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SM0","cFilFilOri",,,,.T.) 

				TSay():New(000,080,{||AllTrim(FWX3Titulo('DT6_FILDES'))}	,oPnlCol1,,,.F.,.F.,.F.,.T., , ,050,008)  //Fil.Destino
				TGet():New(000,108,{|u| If(PCount()>0,cFilFilDes:=u,cFilFilDes)}	,oPnlCol1,015,008,""	,{||}						,,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SM0","cFilFilDes",,,,.T.) 

				TSay():New(012,004,{||AllTrim(FWX3Titulo('DT6_DATEMI'))}     ,oPnlCol1,,,.F.,.F.,.F.,.T., , ,050,008)   //Periodo de/ate
				TGet():New(011,038,{|u| If(PCount()>0,dFilDataDe:=u,dFilDataDe)}	,oPnlCol1,048,008,''	,{|| },,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""		 ,"dFilDataDe",,,,.T.) 
				TGet():New(011,091,{|u| If(PCount()>0,dFilDataAte:=u,dFilDataAte)}	,oPnlCol1,048,008,''	,{|| },,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""		 ,"dFilDataAte",,,,.T.) 
				                
				TSay():New(024,004,{||AllTrim(FWX3Titulo('DTQ_VIAGEM'))} ,oPnlCol1,,,.F.,.F.,.F.,.T., , ,050,008)  //Viagem
				TGet():New(023,038,{|u| If(PCount()>0,cFilNroVge:=u,cFilNroVge)}	,oPnlCol1,015,008,"",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,'DTQ',"cFilNroVge",,)

				TSay():New(002,004,{|| AllTrim(FWX3Titulo('A1_COD'))}        ,oPnlCol2,,,.F.,.F.,.F.,.T., , ,050,008)  //Cod.Cliente
				TGet():New(002,027,{|u| If(PCount()>0,cFilCodCli:=u,cFilCodCli)}		,oPnlCol2,059,008,"@!"	,{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SA1","cFilCodCli",,,,.T.) 
		
				TSay():New(002,085,{||AllTrim(FWX3Titulo('A1_LOJA'))}        ,oPnlCol2,,,.F.,.F.,.F.,.T., , ,050,008)  //Loja Cliente
				TGet():New(002,100,{|u| If(PCount()>0,cFilLojCli:=u,cFilLojCli)}		,oPnlCol2,029,008,""	,{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SA1","cFilLojCli",,,,.T.) 

				TCheckBox():New(002,140,"Rem."  ,{|u| If(PCount()>0,lFilCliRem:=u,lFilCliRem)},oPnlCol2,104,008,,,,,,,,.T.,"Remetente",,)
				TCheckBox():New(002,168,"Dest." ,{|u| If(PCount()>0,lFilCliDes:=u,lFilCliDes)},oPnlCol2,104,008,,,,,,,,.T.,"Destinatario",,)    
				TCheckBox():New(002,196,"Cons." ,{|u| If(PCount()>0,lFilCliCon:=u,lFilCliCon)},oPnlCol2,104,008,,,,,,,,.T.,"Consignatario",,)    
				TCheckBox():New(002,224,"Desp." ,{|u| If(PCount()>0,lFilCliDpc:=u,lFilCliDpc)},oPnlCol2,104,008,,,,,,,,.T.,"Despachante",,) 

        		TSay():New(016,004,{||AllTrim(FWX3Titulo('DTC_NUMNFC'))} 	,oPnlCol2,,,.F.,.F.,.F.,.T., , ,050,008)  //Nota Fiscal
				TGet():New(016,035,{|u| If(PCount()>0,cFilNumNFC:=u,cFilNumNFC)}	,oPnlCol2,048,008,"",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,	,"cFilNumNFC",,)

				TSay():New(016,088,{||AllTrim(FWX3Titulo('DTC_SERNFC'))} ,oPnlCol2,,,.F.,.F.,.F.,.T., , ,050,008)  //Serie NF
				TGet():New(016,120,{|u| If(PCount()>0,cFilSerNFC:=u,cFilSerNFC)}	,oPnlCol2,015,008,"",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,	,"cFilSerNFC",,)

                TSay():New(002,004,{||AllTrim(FWX3Titulo('DT6_PREFIX'))} 	,oPnlCol3,,,.F.,.F.,.F.,.T., , ,050,008)    //Prefixo Fatura
				TGet():New(002,023,{|u| If(PCount()>0,cFilPfxFat:=u,cFilPfxFat)}	,oPnlCol3,015,008,"@!"	,{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cFilPfxFat",,,,.T.) 

				TSay():New(002,050,{||AllTrim(FWX3Titulo('DT6_NUM'))}		,oPnlCol3,,,.F.,.F.,.F.,.T., , ,050,008)   //Nro Fatura
				TGet():New(002,073,{|u| if(PCount()>0,cFilNroFat:=u,cFilNroFat)}	,oPnlCol3,040,008,"" 	,{||},,,,,,.T.,,,,,,,,,,"_NroFat")
				
				TSay():New(002,116,{||AllTrim(FWX3Titulo('DT6_TIPO'))}	 	,oPnlCol3,,,.F.,.F.,.F.,.T., , ,050,008)			  //Tp.Fatura
				TGet():New(002,141,{|u| If(PCount()>0,cFilTipFat:=u,cFilTipFat)}	,oPnlCol3,015,008,"@!"	,{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"05","cFilTipFat",,,,.T.)

                TSay():New(016,004,{||STR0299}        ,oPnlCol3,,,.F.,.F.,.F.,.T., , ,050,008)  //Faturado?
				TComboBox():New(016,032, {|u| If(PCount()>0,cFaturado:=u,cFaturado)} ,aIteFat,050,008,oPnlCol3,,,,,,.T.,,,,,,,,,'cFaturado') 

				oButton1 := TButton():New(002,002, STR0295 ,oPnlCol4,{|| T500Filter(cFiltro), oBrowseDT6:Refresh(.T.) },040,013,,,,.T.,,"",,,,.F.)    //Filtrar
				oButton1 := TButton():New(016,002, STR0296 ,oPnlCol4,{|| T500Clear(cFiltro)},040,013,,,,.T.,,"",,,,.F.)    //Limpar

				oFWLayerUp:AddCollumn("ALL",100,.T.,"MIDDLE")	
				oPanelUp := oFWLayerUP:GetColPanel("ALL","MIDDLE")  

				oBrowseDT6 := FWMBrowse():New()
				oBrowseDT6:SetOwner(oPanelUp) 
				oBrowseDT6:SetDescription( STR0001 )   //Manutenção de Documentos
				oBrowseDT6:SetAlias('DT6')
				oBrowseDT6:SetMenuDef( '' )
				oBrowseDT6:DisableDetails() 
				oBrowseDT6:SetProfileID('DT6')
				oBrowseDT6:ForceQuitButton()
				oBrowseDT6:SetFixedBrowse(.T.)		
				If !Empty(cFiltro)  //Executa o Filtro
					T500Filter(cFiltro)
				EndIf

				aLegBrw:= TF68LegDT6()   //Legenda do DT6
				For nI:= 1 to Len(aLegBrw)
					oBrowseDT6:AddLegend(aLegBrw[nI][1], aLegBrw[nI][2], aLegBrw[nI][3])
				Next nI

				If lStaCTE
					oBrowseDT6:AddStatusColumns({||TF68StaCTE(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)},{||TF68LegCTE()})
				EndIf
				If lAvbCTE
					oBrowseDT6:AddStatusColumns({||TF68AvbCTE(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)},{||TF68LegAVB()})		
				EndIf
				If lStaFAT
					oBrowseDT6:AddStatusColumns({||TF68StaFat(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6_SERIE)},{||TF68LegFat()})	
				EndIf
				
				//-- Cria os Folders da linha inferior
				//---Viagem, Operações, Ocorrencias, Pendencias/Indenizações, Faturas, Notas Fiscais
				aFolders := {STR0045,STR0292,STR0046,AllTrim(STR0150)+ '/ ' + AllTrim(STR0149),STR0293,STR0294}  
				oInferior := oFWLayerUp:GetLinePanel("DOWN")
				oFolders  := TFolder():New(0,0,aFolders,aFolders,oInferior,,,,.T.,,oInferior:nClientWidth / 2,oInferior:nClientHeight / 2)
				oFolders:bChange := {|nFolder| CriaBrow(nFolder), T500AtuBrw(nFolder) }  //Atualiza Browse

				//-- Cria novo Layer para as pastas
				oFWLayerDwn := FWLayer():New()
				oFWLayerDwn:Init(oFolders:aDialogs[1], .F., .T.)			
				
				//-- Cria linha do Layer inferior
				oFWLayerDw:AddLine("DETALHE",100,.F.)

				//---- Viagem
				aRelacto:= {{"DUD_FILIAL","xFilial('DUD')" },{"DUD_FILDOC","DT6_FILDOC"},{"DUD_DOC","DT6_DOC"},{"DUD_SERIE","DT6_SERIE"}}
				aLegBrw:= TF68LegDTQ()
				cFilBrw:= " DUD->DUD_VIAGEM <> ' ' "
				
				//-- Cria Colunas do Layer inferior
				oFWLayerDw:AddCollumn( "COLVGE",	100, .T., "DETALHE" )
				oFWLayerDw:AddCollumn( "COLOPE",	100, .T., "DETALHE" )
				oFWLayerDw:AddCollumn( "COLOCO",	100, .T., "DETALHE" )
				oFWLayerDw:AddCollumn( "COLPEN",	100, .T., "DETALHE" )
				oFWLayerDw:AddCollumn( "COLFAT",	100, .T., "DETALHE" )
				oFWLayerDw:AddCollumn( "COLNF",		100, .T., "DETALHE" )

				oBrowseDUD:= FWMBrowse():New()			
				oBrowseDUD:AddButton(STR0003,{|| T500VisVge() },,2,,.F.) //Visualizar 		
				T500MntBrw(oBrowseDUD,oBrowseDT6,'DUD','TMSA144',STR0045, aRelacto,aLegBrw,1,cFilBrw)	  //Viagem

				oBrowseDT6:Activate()   //Posicionar por ultimo para atualização correta dos Browses - FWS

				ACTIVATE MSDIALOG oDlgPrinc CENTER 

			Else
				mBrowse( 6,1,22,75,'DT6',,,,,,aCores,,,,,,,.T.,cFiltro)
			EndIf

		EndIf
	
		//-- Finaliza Teclas de Atalhos
		TmsKeyOff(aSetKey)
	EndIf
EndIf

RestInter()

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Mnt³ Autor ³ Alex Egydio           ³ Data ³22.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao de documentos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA200Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500Mnt( cAlias, nReg, nOpcx )

Local aAreaAnt      := GetArea()
Local aAreaDTQ      := DTQ->(GetArea())
Local aAreaDUD      := DUD->(GetArea())
Local aAreaDT6      := DT6->(GetArea())
Local aAreaSM0      := SM0->(GetArea())
Local aAreaDY4		:= DY4->(GetArea())
Local aButtons      := {}
Local aDocExcMot	:= {}
Local cFilOri		:= ''
Local cFilDes		:= ''
Local cCliRem 		:= ''
Local cLojRem		:= ''
Local cCliDes		:= ''
Local cLojDes		:= ''
Local cCdrDes		:= ''

Local cCliExp 		:= ''
Local cLojExp  		:= ''
Local cCliRec 		:= ''
Local cLojRec  		:= ''

Local cSeek         := ""
Local lHelp         := .F.
//-- Controle de dimensoes de objetos
Local aSize			:= {}
Local aObjects		:= {}
Local aInfo			:= {}
Local aPosObj		:= {}
Local cCmpEnt		:= ""
Local cCmpImp		:= ""
//-- MSDialog
Local oDlgEsp
//-- EnchoiceBar
Local nOpca			:= 0
//-- Folder
Local aPages		:= {'HEADER'}
Local aTitles		:= {	OemToAnsi(STR0007)} //'Composicao do frete'
Local oFolder
//-- Listbox da composicao de frete
Local cLbx        := ''
//-- Indica que o complemento(nOpcX == 6) esta sendo efetuado pela 1o vez
Local lPrimComp   := .T. 
Local lCancela    := .F.
Local lProcessa   := .T.
//-- Variaveis para estorno do documento
Local cLotNfc     := ''
Local lDocto      := .F.
Local lRet        := .T.
Local lDocDisp    := .F.
Local dDatFech    := MVUlmes()
Local dDatFTMS    := GetMv("MV_DATATMS",.F.,CtoD(''))
Local cAliasQry   := ""
Local cQuery      := ""
Local cFilDco     := ""
Local cDocDco     := ""
Local cSerDco     := ""
Local cDocOri     := SuperGetMv('MV_TPDCREE',,'')
Local cDocArm     := SuperGetMv('MV_TPDCARM',,'')
Local cOcoArm     := SuperGetMv('MV_OCORARM',,'')
Local lUsaNfs     := SuperGetMv('MV_TMSUNFS',,.F.)
Local cCdrOri     := SuperGetMv('MV_CDRORI',,'')
Local lRetV02	  := .F. 
//Backup cFilAnt
Local cFilbkp		:= cFilAnt

//-- Teclas de Atalhos
Local bVK_F4  := {|| TmsA500Dig() }
Local bVK_F5  := {|| }
Local bVK_F6  := {|| }
Local bVK_F7  := {|| TmsA500Tr1() }
Local bVK_F8  := {|| TmsA500Tr2() }
Local bVK_F9  := {|| TmsA500Tr3() }
Local bVK_F10 := {|| TmsA500Viag()}
Local bVK_F11 := {|| TmsA500Man() }
Local bVK_F12 := {|| TmsA500Tab() }
Local nCntFor   := 0
Local lTM500ORI := ExistBlock("TM500ORI")
Local cSerArm   := SuperGetMv('MV_SERARM',,'')	//-- Qual servico para armazenagem ?
Local cOcoRee   := SuperGetMv('MV_OCORREE',,'') //-- Quais ocorrencias geram reentrega
Local lAlianca  := TMSAlianca() //-- Indica se utiliza Alianca
Local lIndexDvl := .T.
Local aButTmp   := {}
Local nButton
Local oBtnLat
Local aDelButtons
Local nButMax   := 20 //Maximo de botoes para a MDI
Local oPanelLat
Local oPanelEsp
Local aRetPE    :={}
Local dDatEnc   := dDataBase
Local aAreaDUA  := ""
Local aAreaDT2  := ""
Local cFilVld   := ""
Local cCdrCal   := ""
Local cTipFre	:= ""
Local cCliDev	:= ""
Local cLojDev	:= ""
Local cInscr  	:= ""
Local cContrib	:= ""
Local cTESAnula	:= SuperGetMv('MV_TESANUL',,'')
Local cTESAnula2	:= SuperGetMv('MV_TESANU2',,'')
Local dDatFFIN	:= GetMV("MV_DATAFIN",.F.,CtoD(''))
Local lTMSCTe	:= SuperGetMv( "MV_TMSCTE", .F., .F. )
Local lDocAut	:= .T.
Local lAgdEntr  := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)   //-- Agendamento de Entrega.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis que sao utilizadas para exibir as abas Impostos e Livros Fiscais.	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aObj      := Array(1)
Local bWhile    := {||}
Local lContinua := .T.
Local aPedidos  := {}
Local aRecSE1   := {}
Local aRecSE2   := {}
Local aRecSF3   := {}
Local a920Var	:= {0,0,0,0,0,0,0,0,0}
Local lDelDoc	:= ExistBlock("TM500DEL")
Local nPrazo	:= 0
Local nCteExc	:= GetNewPar("MV_CTEEXC",0)   //Prazo em dias para cancelamento do CT-e
Local uReturn	:= Nil
Local lSubst	:= .F.
Local lAnul		:= .F.
Local lDocRee	:= SuperGetMV('MV_DOCREE',,.F.) .And. TMSChkVer('11','R7')
Local nCteExcH	:= GetNewPar("MV_CTEEXCH",0)   //Prazo em horas para cancelamento do CT-e
Local lCanCTE   := .T.
Local lTMSGFE   := SuperGetMv("MV_TMSGFE",,.F.) 
Local lExibImp  := SuperGetMv("MV_TMSCFIS",,.T.)
Local lCamposRat:= DT8->(ColumnPos("DT8_PERRAT")) > 0
Local lmvPar03	:= VldExistX1('TMA500'/*Grupo do pergunte*/,'03'/*Ordem Parametro*/)

Local lOriCal		:= DT6->(ColumnPos('DT6_ORICAL')) > 0
Local lExpedidor	:= DTC->(ColumnPos("DTC_CLIEXP")) > 0 
Local lRecebedor    := DTC->(ColumnPos("DTC_CLIREC")) > 0
Local lAlianca		:= TMSAlianca() //-- Indica se utiliza Alianca
Local aErrEst       := {}
Local nRecDUD       := 0

Private bFolderRefresh := {|| (A920FRefresh(aObj))}
Private bGDRefresh     := {|| (oGetDados:oBrowse:Refresh()) }
Private bRefresh       := {|| (A920Refresh(@a920Var,.F.)),(Eval(bFolderRefresh))}
Private bListRefresh   := {|| (A920FisToaCols()),Eval(bRefresh),Eval(bGdRefresh)}
Private aRemito        := {}	//Array com os remitos de cada item do acols		
Private aItensAgd      := {}                                   //-- Matriz para Agendamento de Entrega.
Private aItensGfe      := {}   //-- Matriz para GFE

If Type("cCadastro") == "U"
	Private cCadastro := STR0001 //'Manutencao de Documentos'
EndIf

cFilAnt := IIF(!Empty(cFilBkp),cFilBkp,cFilAnt)
dbSelectArea("SF2")
dbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
MsSeek(DT6->(DT6_FILORI+DT6_DOC+DT6_SERIE))

Private	cTipo  	:= SF2->F2_TIPO		,;
	c920Nota 	:= SF2->F2_DOC		,;
	c920Serie	:= SF2->F2_SERIE	,;
	d920Emis	:= SF2->F2_EMISSAO	,;
	c920Client	:= SF2->F2_CLIENTE	,;
	c920Loja	:= SF2->F2_LOJA		,;
	c920Especi	:= SF2->F2_ESPECIE	,;
	c920NFIni	:= SF2->F2_DOC		,;
	c920Vend	:= SF2->F2_VEND1	,;
	c920DecExp	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Final de declaracao das variaveis que sao utilizadas para exibir as abas Impostos e Livros Fiscais.	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aDelDocto	:= {}
Private cMark
//-- Enchoice
Private aAltera		:= {}
Private aTela[0][0]
Private aGets[0]
Private oEnch
//-- Listbox
Private oLbx
Private aFrete		:= {}
//-- Controle geral
Private aPedido	:= {}
Private aFrtOri	:= {}
Private aValInf	:= {}
Private cOpcao	:= ''
Private cDocTms	:= ''
Private cSerie	:= ''
Private cPrdImp	:= ''
Private cSerTms	:= ''
Private cTipTra	:= ''
Private nPerOri	:= 0
Private aMsgErr	:= {}
Private aSetKey	:= {}
Private lRecalc	:= .F.
Private aPerfil   := {}
Private cTipMan   := "0"
Private aColsDWT  := {}
Private aHeaderDWT := {}
Private dDatEmi	   := ""
Private lContrib   := .F.

If FwIsInCallStack('TMSC080') .AND. Type("aRotina") == "U"
	Private aRotina := MenuDef(.F.,lAlianca)
EndIf

lCancela    := (aRotina[nOpcx][4] == 7)
cOpcao	:= AllTrim( Subs(aRotina[ nOpcx, 1 ],1) )

If Type("lMsErroAuto") == "U"
	Private lMsErroAuto:= .F.
EndIf
If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf
//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If nOpcx <> 2 .And. !lTM500Auto
	If !TMSAVerAge("1",DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,,,,,,,,"2",.T.,.T.)
		Return .F.
	EndIf
EndIf

// Verifica se só mostrará a aba de composição do frete quando vindo da consulta de Tracking
If IsInCallStack("TMSC020")	
	lExibImp := SuperGetMv("MV_TMSCTRA",,.T.)
EndIf
//--Tratamento dos folders
If lExibImp
	Aadd( aTitles, OemToAnsi(STR0176) )  //"Impostos"
	Aadd( aTitles, OemToAnsi(STR0177) )  //"Livros Fiscai"
EndIf

If lAgdEntr
	Aadd( aTitles, OemToAnsi(STR0182) )  //"Agendamento de Entrega"
EndIf

If lTMSGFE
	Aadd( aTitles, OemToAnsi(STR0197) )  //"GFE"
EndIf
aObj := Array(Len(aTitles)) 

//-- ExecBlock TM500OCO
//-- Ponto               : Apos obter as ocorrencias dos parametros MV_OCORREE e MV_OCORARM
//-- Parametros Enviados : Array com a seguinte informacao:
//--                       PARAMIXB[01] = Codigo das ocorrencias que geram armazenagem.
//--                       PARAMIXB[02] = Codigo das ocorrencias que geram reentrega.
//--
//-- Retorno Esperado    : Array no seguinte formato:
//--                       aRetPE[01] = Codigo das ocorrencias que geram armazenagem.
//--                       aRetPE[02] = Codigo das ocorrencias que geram reentrega.
If ExistBlock('TM500OCO')
	aRetPE:= ExecBlock("TM500OCO",.F.,.F., {cOcoarm,cOcoRee})
	If !Empty(aRetPE) .And. len(aRetPE) > 1
		If !Empty(aRetPE[1])
			cOcoarm:=aRetPE[1]
		EndIf
		If !Empty(aRetPE[2])
			cOcoRee:=aRetPE[2]
		EndIf
	EndIf
EndIf

//verifica se existe o indice DVL 2
If lAlianca .And. nOpcx == 7
	dbSelectArea("SIX")
	If SIX->( MsSeek("DVL2") )
		If SIX->CHAVE <> "DVL_FILIAL+DVL_FILPAR"
			lIndexDvl := .F.
		EndIf
	Else
		lIndexDvl := .F.
	EndIf
	If !lIndexDvl
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA50089")	// "Para utilizar esta opcao, favor criar o indice DVL_FILIAL+DVL_FILPAR, no arquivo DVL, como ordem 2 !!!"
		Return( .F. )
	EndIf
EndIf

If lTMSCTe .And. DT6->DT6_IDRCTE <> '100' .And. ( Alltrim(DT6->DT6_DOCTMS) != StrZero( 5, Len( DT6->DT6_DOCTMS ) ) .And.;    //--Nota Fiscal de Serv. de Transp.
                                                  Alltrim(DT6->DT6_DOCTMS) != Replicate('D', Len( DT6->DT6_DOCTMS ) ) .And.; //--Nota Fiscal de Reentrega
                                                  Alltrim(DT6->DT6_DOCTMS) != Replicate('F', Len( DT6->DT6_DOCTMS ) ) .And.; //--Nota Fiscal de Armazenagem
                                                  Alltrim(DT6->DT6_DOCTMS) != Replicate('G', Len( DT6->DT6_DOCTMS ) ) )      //--Nota Fiscal de Complemento
	DTP->(DbSetOrder(2)) //DTP_FILIAL+DTP_FILORI+DTP_LOTNFC
	If	DTP->(MsSeek(xFilial('DTP')+DT6->DT6_FILORI+DT6->DT6_LOTNFC))
		If DTP->DTP_TIPLOT == '3' .Or. DTP->DTP_TIPLOT == '4'
			lDocAut := .F.
		EndIf
	EndIf
EndIf


If Type("cLoteAut") <> "C"
	cLoteAut := ""
Else
	If	cLoteAut == Nil .Or. ValType(cLoteAut) <> 'C'
		cLoteAut  := ""
	EndIf
EndIf

If Upper(AllTrim(FunName())) == "TMSA500" .Or. lTM500Auto .Or.;
   Upper(AllTrim(FunName())) == "TMSA853"
	nOpcx := aRotina[ nOpcx, 4 ]
ElseIf Upper(AllTrim(FunName())) == "TMSA540"
	If nOpcx = 4 
		cOpcao := "Devoluc"
	ElseIf nOpcx = 5 
		cOpcao := "Reentr"
	EndIf
EndIf


//-- Inicializa as Teclas de Atalhos F5 ou F6
If nOpcx != 2 .And. nOpcx != 7 .And. nOpcx != 12 .And. nOpcx != 8
	bVK_F5  := {|| TmsA500Dsc(nOpcx, @lPrimComp) }
Else
	bVK_F6  := {|| TmsA500Fin() }
EndIf

If Empty(cLoteAut) .And. !lTM500Auto
	AAdd( aSetKey, { VK_F4 , bVK_F4  } )
	AAdd( aSetKey, { VK_F5 , bVK_F5  } )
	AAdd( aSetKey, { VK_F6 , bVK_F6  } )
	AAdd( aSetKey, { VK_F7 , bVK_F7  } )
	AAdd( aSetKey, { VK_F8 , bVK_F8  } )
	AAdd( aSetKey, { VK_F9 , bVK_F9  } )
	If !IsInCallStack("TMSA144")
		AAdd( aSetKey, { VK_F10, bVK_F10 } )
	EndIf
	AAdd( aSetKey, { VK_F11, bVK_F11 } )
	AAdd( aSetKey, { VK_F12, bVK_F12 } )
EndIf

//-- PE utilizado para validar a execucao da rotina.
If lTM500OK
	lRet := ExecBlock("TM500OK",.F.,.F.,{nOpcx})
	If ValType(lRet) # "L"
		lRet := .T.
	EndIf
	If !lRet
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( .F. )
	EndIf
EndIf

//-- Nao permite a emissao/estorno de documentos com data menor que o fechamento do estoque
If nOpcx <> 2 .And. nOpcx <> 8 .And. nOpcx <> 9
	//-- Verifica a data de execucao
	If !lTM500Auto .And. GetNewPar("MV_NFCHGDT",.F.) //-- Informa se a data base do sistema deve ser alterada, se a data do sistema operacional for alterada, na preparacao do documento de saida.
		If MsDate()==dDataBase+1
			If MsgYesNo(STR0181,OemToAnsi(STR0067)) //"O sistema identificou a troca da data do sistema operacional, deseja atualizar a data base do sistema?"###"Atencao !"
				dDataBase := MsDate()
			EndIf
		EndIf
	EndIf
	If dDataBase <= dDatFech .Or. ( lCancela .And. DT6->DT6_DATEMI <= dDatFech )
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help ( " ", 1, "FECHTO" ) //"Nao pode ser digitado movimento com data anterior a ultima data de fechamento (virada de saldos)"
		Return( .F. )
	EndIf
	If !Empty(dDatFTMS)
		If dDataBase <= dDatFTMS .Or. ( lCancela .And. DT6->DT6_DATEMI <= dDatFTMS )
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help ( " ", 1, "FECHATMS" )
			Return( .F. )
		EndIf
	EndIf
	If !Empty(dDatFFIN)
		If dDataBase < dDatFFIN
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help ( " ", 1, "DTMOVFIN" )
			Return( .F. )
		EndIf
	EndIf
	If !Empty(GetMV("MV_DATAFIS",,""))
		If !FisChkDt(dDataBase)
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return( .F. )
		EndIf
	EndIf
EndIf

If nOpcx = 13 //Substituicao
	If (Date()-DT6->DT6_DATEMI) > 60
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA500B6") //"Ct-e não pode ser substituído, pois ultrapassou o prazo de substituição de 60 dias"		
		Return( .F. )
	EndIf
EndIf

If nOpcx <> 2 .And. DT6->DT6_BLQDOC == StrZero( 1, Len( DT6->DT6_BLQDOC ) ) .And. (nOpcx == 5 .And.  DT6->DT6_STATUS <> 'C')
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help(' ', 1, 'TMSA500A1',,'O Documento ' + DT6->DT6_DOC + "/" + DT6->DT6_SERIE +' está bloqueado',5,11) //"Documento esta bloqueado !"###"Documento No : "
	Return( nOpcA )
EndIf

//-- Visualizar
If	nOpcx == 2
	// se Filial atual nao for a mesma do documento
	If DT6->DT6_FILORI <> cFilAnt
		cFilBkp := cFilAnt
		cFilAnt := DT6->DT6_FILORI
	EndIf

	//-- Configura variaveis da Enchoice.
	RegToMemory(cAlias,.F.)
	//-- Se documento de coleta vai direto para visualizacao de solicitacao de coleta
	If	M->DT6_DOCTMS == StrZero( 1, Len( DT6->DT6_DOCTMS ) )				//-- Coleta
		TmsA500Dig()

		RestArea(aAreaDTQ)
		RestArea(aAreaDUD)
		RestArea(aAreaAnt)

		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		uReturn := nOpcA
	EndIf

	If Empty( uReturn )
		cDocTms	:= M->DT6_DOCTMS
	Endif

	If !Empty( uReturn )
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( uReturn )
	Endif

//-- Devolucao
ElseIf	nOpcx == 4
	cDocTms := StrZero(6, Len(DC5->DC5_DOCTMS)) // CTRC Devolucao

	If DT6->DT6_DOCTMS == '5'
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA500B4")	// "Nao é permitido efetuar devolução para o tipo de documento Nota Fiscal.
		Return( nOpcA )
	EndIf
	//-- QUANDO DOCUMENTO DO TIPO APOIO C=Docto Apoio 2,H=Docto Apoio 3,I=Docto Apoio 4;N=Docto Apoio 5 ou O=Docto Apoio 6
	//-- e na tabela de DUI-Configurações do Documento o campo Doc.Fat DUI_DOCFAT estiver preenchido não permitirá gerar documento
	//-- de devolução, pois será gerado pela rotina de faturamento.
	If DT6->DT6_DOCTMS $ "C|H|I|N|O"
		DUI->(DbSetOrder(1))
		If DUI->(MsSeek(xFilial("DUI")+DT6->DT6_DOCTMS))
			If !Empty(DUI->DUI_DOCFAT)
				Help(" ", 1, "TMSA500C2",,STR0278 + " " + TMSValField("DUI->DUI_DOCFAT",.F.,"DUI_DESFAT") + " " + STR0279 ,2,1) // "O documento selecionado está configurado para gerar um documento do tipo: "" ????? " pela rotina de faturamento. E por isso não é permitido efetuar devolução para documentos do tipo apoio."
				Return nOpcA			  
			EndIf
		EndIf
	ENDIF

	If !lDocAut
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA50100")	// "Doc Original ainda nao esta autorizado.
		Return( nOpcA )
	EndIf
	If DT6->DT6_SERTMS == StrZero(3,Len(DT6->DT6_SERTMS))
		nRecDUD:= TMSRECDUD(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
		lRet:= TMSDOCFIL(nRecDUD)

		If !lRet
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help( " ", 1, "TMSA50015")	// "Devolucao permitida somente na filial de destino."
			Return( nOpcA )
		EndIf
	Else
		If DT6->DT6_FILDES != cFilAnt
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help( " ", 1, "TMSA50015")	// "Devolucao permitida somente na filial de destino."
			Return( nOpcA )
		EndIf
	EndIf

	If	DT6->DT6_STATUS <> StrZero(1,   Len(DC5->DC5_DOCTMS) ) .And.;
		DT6->DT6_STATUS <> StrZero(4,   Len(DC5->DC5_DOCTMS) ) .And.;
		DT6->DT6_STATUS <> StrZero(5,   Len(DC5->DC5_DOCTMS) ) .And.;
		DT6->DT6_STATUS <> StrZero(8,   Len(DC5->DC5_DOCTMS) ) .And.;
		DT6->DT6_STATUS <>    PadR("A", Len(DC5->DC5_DOCTMS) ) .And.;
		DT6->DT6_SERTMS <> StrZero(3,   Len(DT6->DT6_SERTMS) ) .And.;
		!( TMSA500RDP() )
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, 'TMSA50018') //"A devolução e permitida somente para documentos com Chegada Final ou Em Aberto e que exista uma ocorrencia de retorno de documento."
		Return( nOpcA )

	Else

		//--Verifica a situacao atual do documento da viagem
		cAliasQry := GetNextAlias()

		cQuery := " SELECT MAX(R_E_C_N_O_) DUDRecNo"
		cQuery += " FROM " + RetSqlTab("DUD")
		cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"
		cQuery += "   AND DUD.DUD_FILDOC = '" + DT6->DT6_FILDOC + "'"
		cQuery += "   AND DUD.DUD_DOC    = '" + DT6->DT6_DOC + "'"
		cQuery += "   AND DUD.DUD_SERIE  = '" + DT6->DT6_SERIE + "'"
		cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

		DUD->( DbGoTo( (cAliasQry)->DUDRecNo ) )

		(cAliasQry)->( DbCloseArea() )

		If !Empty( DUD->DUD_VIAGEM ) .And. DUD->DUD_SERTMS == StrZero( 3, Len( DUD->DUD_SERTMS ) ) .And. !( TMSA500RDP() )
			If !__lPyme		
				If !TMSA500Oco( DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, DT6->DT6_FILVGA, DT6->DT6_NUMVGA )
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Help( " ", 1, 'TMSA50018') //"A devolução e permitida somente para documentos com Chegada Final ou Em Aberto e que exista uma ocorrencia de retorno de documento."
					Return( nOpcA )
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Se escolheu documento do primeiro percurso, sempre o documento FOB( ou 2o percurso ) sera devolvido
	If	DT6->DT6_PRIPER == StrZero(1,Len(DT6->DT6_PRIPER))
		DTC->(DbSetOrder(4)) // DTC_FILDOC+DTC_PRIPER+DTC_SERIE
		DTC->(MsSeek(xFilial('DTC') + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE))
		DT6->(MsSeek(xFilial('DT6') + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE))
	EndIf

	aAreaDT6 := DT6->(GetArea())
	DT6->(dbSetOrder(8))
	If DT6->(MsSeek(cSeek := xFilial("DT6") + DT6_FILDOC + DT6_DOC + DT6_SERIE))
		While DT6->(!Eof() .And. DT6_FILIAL + DT6_FILDCO + DT6_DOCDCO + DT6_SERDCO == cSeek)
			If DT6->DT6_DOCTMS == cDocTMS .And. !IsIncallStack("TMSA152")
				lHelp := .T.
				Exit
			ElseIf DT6->DT6_DOCTMS == cDocTMS
				//--Não encontrou DY4, significa devolução do CT-e inteiro
				If !TmsPsqDY4(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
					lHelp := .T.
					Exit
				Else
					aAreaDY4 := DY4->(GetArea())
					DY4->(DbSetOrder(1)) //-- DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE+DY4_NUMNFC+DY4_SERNFC+DY4_CODPRO
					DY4->(MsSeek(xFilial("DY4")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE), .F.) )
					Do While !lHelp .And. DY4->(!Eof()) .And. xFilial("DY4")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE) == DY4->(DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE)
						//-- Pesquisa se a(s) nf(s) do documento estão selecionadas na Ocorrência.
						If DY4->(Get500NfAu(DY4_NUMNFC,DY4_SERNFC,DY4_CLIREM,DY4_LOJREM,DY4_CODPRO,DY4_FILORI,DY4_LOTNFC)) > 0
							lHelp := .T.
						EndIf
						
						DY4->(DbSkip())
					EndDo 
					RestArea(aAreaDY4)
				EndIf
			EndIf
			DT6->(dbSkip())
		EndDo
	EndIf
	RestArea(aAreaDT6)
	If lHelp
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help(' ',1,'TMSA50019') // 'Ja existe uma devolucao para esse documento'
		Return( nOpcA )
	EndIf

	//-- Nao permite devolucao de um documento que ja foi encerrado (Apenas cobrança, pelo TMSA152)
	If	DT6->DT6_STATUS == StrZero(7,Len(DT6->DT6_STATUS)) .And. !IsInCallStack("TMSA152")
		Help( ' ', 1, 'TMSA50001',,STR0008 + DT6->DT6_DOC + ' / ' + DT6->DT6_SERIE,4,1)	//-- Encerramento de processo ja executado para este documento. (DUA) //'Docto: '
		RestArea(aAreaDTQ)
		RestArea(aAreaDUD)
		RestArea(aAreaAnt)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( nOpca )
	EndIf
	//-- Define os campos que poderao ser alterados na devolucao
	AAdd(aAltera,'DT6_SERVIC')					//-- Servico de devolucao
	AAdd(aAltera,'DT6_LOJDES')					//-- Na devolucao edita somente a loja do cliente destinatario
	if DDC->(ColumnPos("DDC_DEVTRE")) > 0 .Or. DDA->(ColumnPos("DDA_DEVTRE")) > 0
		If lOriCal .And. TmsSobServ('DEVTRE',.T.,.T.,DT6->DT6_NCONTR,DT6->DT6_CODNEG,DT6_SERVIC,"0", Nil ) == '2'
			AAdd(aAltera, "DT6_ORICAL")
			AAdd(aAltera, "DT6_DESCAL")
		EndIf
		If DT6->(ColumnPos('DT6_SQEDES')) > 0 .And. TmsSobServ('DEVTRE',.T.,.T.,DT6->DT6_NCONTR,DT6->DT6_CODNEG,DT6_SERVIC,"0", Nil ) == '2'
			AAdd(aAltera,'DT6_SQEDES')
		EndIf
	Endif	 	
	If ExistBlock('TM500CPO')
		ExecBlock('TM500CPO',.F.,.F.,{nOpcx})
	EndIf
//-- Reentrega
ElseIf	nOpcx == 5

	If !lDocAut
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA50100")	// "Doc Original ainda nao esta autorizado.
		Return( nOpcA )
	EndIf
	
	If lDocRee //-- Se já existir doc reentrega 
		If (DT6->DT6_DOCTMS == StrZero(7,Len(DT6->DT6_DOCTMS)) .Or. DT6->DT6_DOCTMS == Replicate('D', Len( DT6->DT6_DOCTMS ) ))  //-- Para documentos de reentrega
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help('',1,"TMSA500A7") //-- A Reentrega deve ser lançada sobre o documento original
			Return( nOpcA )
		Else
			cFilDco  := DT6->DT6_FILDOC
			cDocDco  := DT6->DT6_DOC
			cSerDco  := DT6->DT6_SERIE
		EndIf
		TMS500Perg(.f.)
		
		If lmvPar03 .AND. MV_PAR03 == 2  //Geracao por Docto		
			cAliasQry := GetNextAlias()
			cQuery := " SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_DATEMI, DT6_STATUS"
			cQuery += "   FROM  " + RetSqlName("DT6") + " DT6 "
			cQuery += "  WHERE DT6_FILIAL =  '" + xFilial("DT6") + "' "
			cQuery += "    AND DT6_FILDCO =  '" + cFilDco + "' "
			cQuery += "    AND DT6_DOCDCO =  '" + cDocDco + "' "
			cQuery += "    AND DT6_SERDCO =  '" + cSerDco + "' "
			cQuery += "    AND DT6_DOCTMS =  '" + StrZero(7,Len(DT6->DT6_DOCTMS)) + "' "  //-- Documento de Reentrega   
			cQuery += "    AND DT6_STATUS <> '" + StrZero(7,Len(DT6->DT6_STATUS)) + "' "  //-- Diferente de Entregue
			cQuery += "	   AND DT6_STATUS <> '" + StrZero(8,Len(DT6->DT6_STATUS)) + "' "  //-- Diferente de Entregue Parcialmente
			cQuery += "    AND DT6_STATUS <> 'A'       "  								  //-- Diferente de Retorno Total
			cQuery += "    AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			TCSetField(cAliasQry,"DT6_DATEMI","D",8,0)
			If (cAliasQry)->(!Eof())
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help('',1,"TMSA500A8") //-- Já existe um documento de reentrega.
				Return( nOpcA )
			EndIf
			(cAliasQry)->(DbCloseArea())
		Endif	
		DbSelectArea("DT6")
	EndIf

	cFilVld := TMSA500FIL()
	If cFilVld = DT6->DT6_FILDES
	//-- Permite reentrega somente para filial de destino do documento
		If DT6->DT6_FILDES != cFilAnt
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help( " ", 1, "TMSA50057",, DT6->DT6_FILDES, 5, 1 ) //-- Reentrega permitida somente para filial :
			Return( nOpcA )
		EndIf
	Else //-- Permite reentrega somente para filial de origem do documento 
		If DT6->DT6_FILORI != cFilAnt
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help( " ", 1, "TMSA50057",, DT6->DT6_FILORI, 5, 1 ) //-- Reentrega permitida somente para filial :
			Return( nOpcA )
		EndIf
	EndIf
	aPerfil := TmsPerfil(DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,,,DT6->DT6_CLIREM,DT6->DT6_LOJREM,DT6->DT6_CLIDES,DT6->DT6_LOJDES)
	If Len(aPerfil) > 0 .And. aPerfil[25] == "2" // Cliente nao paga reentrega?
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA50058",, DT6->DT6_CLIDEV + "/" + DT6->DT6_LOJDEV, 5, 1 ) //-- Cliente não paga reentrega. Verifique o perfil do cliente :
		Return( nOpcA )
	EndIf
	If Len(aPerfil) > 0 .And. DT6->DT6_VALTOT < aPerfil[33] // Valor do documento original menor que o valor minimo?
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA50059",, , 5, 1 ) //-- Valor do documento original menor que o minimo cadastrado no perfil.
		Return( nOpcA )
	EndIf
	If !Empty(cDocOri) .And. !(DT6->DT6_DOCTMS $ cDocOri)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA50060",, , 5, 1 ) //-- Documento não gera reentrega. Verifique o parametro MV_TPDCREE.
		Return( nOpcA )
	EndIf
	cDocTms := "7"	//-- CTRC Reentrega
	If lUsaNfs .And. cCdrOri == AllTrim(DT6->DT6_CDRDES)
		cDocTms := "D" //-- Nota Fiscal Reentrega
	EndIf
	If Empty(cOcoRee)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help(' ',1,'TMSA50088')	//"Preencha o parametro MV_OCORREE"
		Return( nOpca )
	EndIf
	//-- Verifica se o componente de entrega existe e eh valido
	cCmpEnt := GetMV("MV_COMPENT")
	If Empty(cCmpEnt)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, 'TMSA50020',,"MV_COMPENT",4,1) // "Componente de entrega nao definido no parametro."
		Return( nOpcA )
	Else
		DT3->(dbSetOrder(1))
		If !(DT3->(MsSeek(xFilial("DT3") + cCmpEnt)))
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help( " ", 1, 'TMSA50021',,"MV_COMPENT",4,1) // "Componente de entrega definido no parametro nao esta cadastrado."
			Return( nOpcA )
		EndIf
	EndIf
	If Empty(cLoteAut)
		If !IsInCallStack("TMSA152") .And. !( ( 	DT6->DT6_STATUS == StrZero(5, Len(DC5->DC5_DOCTMS)) .Or.;
					DT6->DT6_STATUS == StrZero(1, Len(DC5->DC5_DOCTMS))	.Or.;
					DT6->DT6_STATUS == StrZero(4, Len(DC5->DC5_DOCTMS))	.Or.;
					DT6->DT6_STATUS == PadR('A',len(DT6->DT6_STATUS))  	.Or.;  //-- Retorno Total
					DT6->DT6_STATUS == StrZero(8, Len(DC5->DC5_DOCTMS))    .Or.;  //-- 
					DT6->DT6_STATUS == StrZero(6, Len(DT6->DT6_STATUS)) )	.And. ; //--Indicado para entrega
					TmsA500Oco(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,DT6->DT6_FILVGA,DT6->DT6_NUMVGA) ) 
			If !__lPyme
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help( " ", 1, 'TMSA50023') 	//-- "A reentrega é permitida somente para documentos com CHEGADA FINAL
				Return( nOpcA )				//-- ou EM ABERTO e com uma ocorrencia de RETORNA DOCUMENTO lançada."
			EndIf
		EndIf
	EndIf
	
	TMS500Perg(.f.)
	If lmvPar03 .And. !IsInCallStack("TMSA152")		
		If !lDocRee .And. MV_PAR03 == 1 //Parâmetro MV_DOCREE desabilitado .AND. F12 = Geração por NF
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help( " ", 1, "TMSA500C1")	//Com o parâmetro MV_DOCREE desabilitado o sistema gera documentos de reentrega/devolução apenas para cobrança. Dessa forma, apenas é permitido gerar Reent/Dev por documento, não sendo possível gerar por NF
			Return( nOpca ) 
		EndIf
	EndIf
	
	//-- Define os campos que poderao ser alterados na Reentrega
	AAdd(aAltera, "DT6_DOCTMS")
	AAdd(aAltera, "DT6_DEVFRE")
	AAdd(aAltera, "DT6_RECISS")
	If lOriCal
		AAdd(aAltera, "DT6_DESCAL")
	EndIf
	
	If DT6->(ColumnPos('DT6_SQEDES')) > 0 
		AAdd(aAltera, "DT6_SQEDES")
	EndIf 

	If ExistBlock('TM500CPO')
		ExecBlock('TM500CPO',.F.,.F.,{nOpcx})
	EndIf

//-- Complemento
ElseIf	nOpcx == 6
	//-- Pondo de entrada criado para efetuar diversar validações validações
	If lTm500V01
		lRetV01 := ExecBlock('TM500V01',.F.,.F.,{nOpcx})
		If !lRetV01
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return( nOpcA )
		EndIf
	EndIf
	If !lDocAut
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA50100")	// "Doc Original ainda nao esta autorizado.
		Return( nOpcA )
	EndIf

	//-- Permite complemento somente para filial de origem do documento
	If DT6->DT6_FILDOC != cFilAnt
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA50017",, DT6->DT6_FILDOC, 5, 1 )	//-- Complemento permitido somente para filial :
		Return( nOpcA )
	EndIf
	//-- Verifica se está tentando complementar um CRT de complemento
	If DT6->DT6_DOCTMS == Replicate('L', Len( DT6->DT6_DOCTMS ) ) //--'CRT Complemento'
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA500D6") // "Não e permitido a geração de CRT complementar para o tipo de documento L - CRT Complementar."
		Return( nOpcA )
	EndIf
	//-- Verifica se o complemento eh de nota fiscal ou ctrc.
	If DT6->DT6_DOCTMS == StrZero(5,Len(DT6->DT6_DOCTMS)) //-- CTRC
		cDocTms	:= Replicate('G', Len( DT6->DT6_DOCTMS ) ) //-- Nota Fiscal Complemento
	ElseIf DT6->DT6_DOCTMS == Replicate('J',Len(DT6->DT6_DOCTMS)) //--'CRT'
		cDocTms	:= Replicate('L', Len( DT6->DT6_DOCTMS ) ) //--'CRT Complemento'
	Else
		cDocTms	:= StrZero( 8, Len( DC5->DC5_DOCTMS ) )	//-- CTRC Complemento
	EndIf

	//-- Define os campos que poderao ser alterados no complemento
	AAdd(aAltera,'DT6_VALMER')		//-- Valor da mercadoria
	AAdd(aAltera,'DT6_PESO')		//-- Peso real
	AAdd(aAltera,'DT6_QTDVOL')		//-- Quantidade de volumes
	AAdd(aAltera,'DT6_PESOM3')		//-- Peso cubado
	AAdd(aAltera,'DT6_TIPTRA')		//-- Tipo de Transporte
	AAdd(aAltera,'DT6_METRO3')		//-- Metro cubico
	AAdd(aAltera,'DT6_QTDUNI')		//-- Quantidade Unitizador
	AAdd(aAltera,'DT6_BASSEG')		//-- Base Seguro RR

	If ExistBlock('TM500CPO')
		ExecBlock('TM500CPO',.F.,.F.,{nOpcx})
	EndIf
	_cObsComp      := ''

//-- Cancelamento
ElseIf nOpcx == 7

	If DT6->DT6_DOCTMS == "M"
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ",1,"TMSA50051",,TmsValField('DT6->DT6_DOCTMS',.F.) + STR0103,2,1) //"Nao e permitido o cancelamento de "###", atraves desta rotina"
		Return( nOpcA )
	EndIf
     
	If DT6->DT6_DOCTMS == "P" .And. (SubStr(DT6->DT6_RETCTE,1,3)= "100" .Or. SubStr(DT6->DT6_RETCTE,1,3)= "004" )
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ",1,"TMSA500B3",,) //"Não e permitido o cancelamento do CT-e de substituição."
		Return( nOpcA )
	EndIf

	//-- Tratamento semelhante ao TMSA200 para que seja considerado o parâmetro MV_CTEEXC ou MV_CTEEXCH
	If GetNewPar("MV_TMSCTE",.F.) .And. DT6->DT6_SITCTE == '2' .And. DT6->DT6_STATUS <> 'C' 
		lCanCTE:= .T.
		
		If nCteExcH > 0 
			nPrazo := Round(SubtHoras( DT6->DT6_DATEMI, SubStr(DT6->DT6_HOREMI,1,2) + ":" + SubStr(DT6->DT6_HOREMI,3,2) , ;
									   Date(), 		  	 SubStr(Time(),1,2)		      + ":" + SubStr(Time(),4,2) ),2) //Prazo em Horas
			If nPrazo > nCteExcH
				lCanCTE:= .F.
			EndIf
		ElseIf nCteExc > 0 
			nPrazo := SubtHoras(DT6->DT6_DATEMI,	SubStr(DT6->DT6_HOREMI,1,2)	+ ":" + SubStr(DT6->DT6_HOREMI,3,2) , ;
								Date(),				SubStr(Time(),1,2)			+ ":" + SubStr(Time(),4,2) ) / 24 // Prazo em dias
			If nPrazo > nCteExc
				lCanCTE:= .F.
			EndIf
		EndIf
								
		If !lCanCTE
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(' ', 1, 'TMSA50120', ,"Prazo "+Iif(nCteExcH > 0,Alltrim(STR(nCteExcH))+" horas",Alltrim(STR(nCteExc))+" dias"),5,1 )//--  Não foi possivel excluir. Prazo para cancelamento do CT-e ultrapassado
			Return( nOpcA )
		EndIf
	EndIf

	If (DT6->DT6_DOCTMS == StrZero(7,Len(DT6->DT6_DOCTMS)) .Or. DT6->DT6_DOCTMS == Replicate('D', Len( DT6->DT6_DOCTMS ) ))
		cFilDco  := DT6->DT6_FILDCO
		cDocDco  := DT6->DT6_DOCDCO
		cSerDco  := DT6->DT6_SERDCO
		cDatEmi  := DT6->DT6_DATEMI
		cHorEmi  := DT6->DT6_HOREMI
		cAliasQry := GetNextAlias()
		cQuery := " SELECT MAX(DT6_FILDOC) DT6_FILDOC, MAX(DT6_DOC) DT6_DOC, MAX(DT6_SERIE) DT6_SERIE, MAX(DT6_DATEMI) DT6_DATEMI, MAX(DT6_HOREMI) DT6_HOREMI "  //-- busca outros documentos de reentrega com o mesmo docOri
		cQuery += "   FROM  " + RetSqlName("DT6") + " DT6 "
		If lDocRee
			cQuery += "  WHERE DT6_FILIAL   = '" + xFilial("DT6") + "' "
			cQuery += "    AND DT6_FILDCO   = '" + cFilDco + "' "
			cQuery += "    AND DT6_DOCDCO   = '" + cDocDco + "' "
			cQuery += "    AND DT6_SERDCO   = '" + cSerDco + "' "
			cQuery += "    AND DT6_DOCTMS IN ('" + StrZero(7,Len(DT6->DT6_DOCTMS)) + "','" + Replicate('D', Len( DT6->DT6_DOCTMS ) )  + "' )"  
			cQuery += "    AND ( DT6_FILDOC <> '" + DT6->DT6_FILDOC + "' "
			cQuery += "    OR DT6_DOC       <> '" + DT6->DT6_DOC    + "' "
			cQuery += "    OR DT6_SERIE     <> '" + DT6->DT6_SERIE  + "' )"
			cQuery += "    AND D_E_L_E_T_   = ' '"
		Else
			cQuery += "  WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
			cQuery += "    AND DT6_FILDCO = '" + cFilDco + "' "
			cQuery += "    AND DT6_DOCDCO = '" + cDocDco + "' "
			cQuery += "    AND DT6_SERDCO = '" + cSerDco + "' "
			cQuery += "    AND D_E_L_E_T_ = ' '"
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		TCSetField(cAliasQry,"DT6_DATEMI","D",8,0)
		If lDocRee
			While (cAliasQry)->(!Eof())
				//-- valida existencia de reentrega mais recente
				If ((cAliasQry)->DT6_DATEMI > cDatEmi ) .Or. ( (cAliasQry)->DT6_DATEMI == cDatEmi .And. (cAliasQry)->DT6_HOREMI > cHorEmi )
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Help('',1,"TMSA500A9") //-- Documento ### com data de emissao mais recente
					Return( nOpcA )
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
		ElseIf (cAliasQry)->(Eof())
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help( " ", 1, "TMSA50061",, , 5, 1 ) //-- Erro ao localicar documentos de reentrega.
			Return( nOpcA )
		EndIf

		(cAliasQry)->(DbCloseArea())
		DbSelectArea("DT6")
	EndIf

	cDocTms	:= DT6->DT6_DOCTMS

//-- Manutencao Alianca
ElseIf nOpcx == 8

	cDocTms := DT6->DT6_DOCTMS

ElseIf nOpcx == 9
	//-- Permite a Manutencao somente para filial descarga atual e sem viagens informadas
	DUD->(DbSetOrder(1))
	If DUD->(MsSeek(xFilial("DUD")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
		While DUD->(!Eof()) .And. DUD->DUD_FILIAL + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE == ;
			xFilial("DUD") + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE
			//-- Verifica a Filial para manutencao
			If DUD->DUD_STATUS == StrZero(1, Len(DUD->DUD_STATUS))
				lDocDisp   := .T.
				If DUD->DUD_FILORI <> cFilant
					Help( " ", 1,"TMSA50042",,DUD->DUD_FILORI,2,30) //-- A manutencao de transporte do documento e permitida somente na filial :
					RestArea(aAreaDTQ)
					RestArea(aAreaDUD)
					RestArea(aAreaAnt)
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Return( nOpcA )
				EndIf
				//-- Verifica se foi informada a viagem
				If !Empty(DUD->DUD_FILORI) .And. !Empty(DUD->DUD_VIAGEM)
					Help( " ", 1, "TMSA50041",,DUD->DUD_FILORI + " - " + DUD->DUD_VIAGEM,2,30) //-- A manutencao de transporte do documento e permitida somente para documentos que nao estejam informados em viagem :
					RestArea(aAreaDTQ)
					RestArea(aAreaDUD)
					RestArea(aAreaAnt)
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Return( nOpcA )
				EndIf
			EndIf
			DUD->(DbSkip())
		EndDo
		If !lDocDisp
			Help( " ",1,"TMSA50040") //-- O Documento nao esta disponivel para manutencao de transporte.
			RestArea(aAreaDTQ)
			RestArea(aAreaDUD)
			RestArea(aAreaAnt)
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return( nOpcA )
		EndIf
		//-- Atualiza Manutencao de Transporte
		TmsA500Trp()
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( nOpcA )
	EndIf
ElseIf	nOpcx == 10 // Complemento de Impostos
	//-- Permite complemento somente para filial de origem do documento
	If DT6->DT6_FILDOC != cFilAnt
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA50017",, DT6->DT6_FILDOC, 5, 1 )	//-- Complemento permitido somente para filial :
		Return( nOpcA )
	EndIf
	//-- Verifica se o componente de impostos existe e eh valido
	cCmpImp := GetMV("MV_COMPIMP")
	If Empty(cCmpImp)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ",1,"TMSA50049") //"Componente de Imposto nao definido no parametro MV_COMPIMP"
		Return( nOpcA )
	Else
		DT3->(dbSetOrder(1))
		If !(DT3->(MsSeek(xFilial("DT3") + cCmpImp)))
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help( " ",1,"TMSA50050") //"Componente de Imposto definido no parametro MV_COMPIMP nao esta cadastrado."
			Return( nOpcA )
		EndIf
	EndIf
	If DT6->DT6_DOCTMS <> StrZero( 5, Len(DT6->DT6_DOCTMS) )
		//-- CTRC Complemento
		cDocTms	:= StrZero( 8, Len( DC5->DC5_DOCTMS ) )
	Else
		cDocTms  := Replicate( 'G', Len( DC5->DC5_DOCTMS) )
	EndIf
//-- Armazenagem
ElseIf nOpcx == 11
	aPerfil := TmsPerfil(DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,,,DT6->DT6_CLIREM,DT6->DT6_LOJREM,DT6->DT6_CLIDES,DT6->DT6_LOJDES)
	If Len(aPerfil) < 38
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help(' ',1,'TMSA50074',,,4,1)	//-- "Atualize o TMSXFUNB.PRW"
		Return( nOpcA )
	EndIf
	If Empty(cLoteAut)
		If !DT6->DT6_STATUS == StrZero(5,Len(DC5->DC5_DOCTMS)) .And. !DT6->DT6_STATUS == StrZero(1,Len(DC5->DC5_DOCTMS))
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(' ',1,'TMSA50075',,,4,1)	//-- "Documento nao esta com chegada final."
			Return( nOpcA )
		EndIf
		If DT6->DT6_FILDES != cFilAnt //-- Eh filial de destino?
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(' ',1,'TMSA50076',,DT6->DT6_FILDES,4,1)	//-- "Armazenagem permitida somente para filial : "
			Return( nOpcA )
		EndIf
		If aPerfil[38] == "2" // Cliente nao paga armazenagem?
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help( ' ', 1, 'TMSA50077',,DT6->DT6_CLIDEV+'/'+DT6->DT6_LOJDEV,4,1)	//-- "Cliente nao paga armazenagem. Verifique o perfil do cliente : "
			Return( nOpcA )
		EndIf
		If DT6->DT6_VALTOT < aPerfil[43] // Valor do documento original menor que o valor minimo?
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(' ',1,'TMSA50078',,,4,1)	//-- "Valor do documento original menor que o minimo cadastrado no perfil."
			Return( nOpcA )
		EndIf
		If !Empty(cDocArm) .And. !(DT6->DT6_DOCTMS $ '2;5') .And. !(cDocArm $ 'E;F') //-- Documento gera armazenagem?
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(' ',1,'TMSA50079',,,4,1)	//-- "Documento nao gera armazenagem. Verifique o parametro MV_TPDCARM."
			Return( nOpcA )
		EndIf
		If Empty(cOcoArm)
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(' ',1,'TMSA50085')	//"Preencha o parâmetro MV_OCORARM"
			Return( nOpcA )
		EndIf
		If Empty(cSerArm)
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(' ',1,'TMSA50086')	//"Preencha o parâmetro MV_SERARM"
			Return( nOpcA )
		EndIf
		If !lPenArm
			aAreaDT6 := DT6->(GetArea())
			cFilDco  := DT6->DT6_FILDOC
			cDocDco  := DT6->DT6_DOC
			cSerDco  := DT6->DT6_SERIE
			DT6->(DbSetOrder(8))
			If DT6->(MsSeek(xFilial('DT6')+cFilDco+cDocDco+cSerDco)) .And. DT6->DT6_DOCTMS = 'E' //Verifica se existe documento de armazenagem.
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Help(' ',1,'TMSA50080',,DT6->DT6_FILDOC+"-"+DT6->DT6_DOC+"-"+DT6->DT6_SERIE,4,1)	//-- "Documento de armazenagem ja gerado : "
				RestArea(aAreaDT6)
				Return( nOpcA )
			EndIf
			RestArea(aAreaDT6)
		EndIf
	EndIf
	dDatOco := Tmsa360Qry(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
	If Empty(dDatOco) // Existe ocorrencia que gera armazenagem?
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help(' ',1,'TMSA50081',,,4,1)	//-- "Nenhuma ocorrencia que gera armazenagem, foi encontradao para o documento."
		Return( nOpcA )
	EndIf

	If Upper(AllTrim(FunName())) == "TMSA360"
		aAreaDUA := DUA->(GetArea())
		aAreaDT2 := DT2->(GetArea())
		DUA->(dbSetOrder(4))
		If DUA->(DbSeek(cSeek:= xFilial("DUA")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
			While DUA->(!Eof()) .And. DUA->DUA_FILIAL + DUA->DUA_FILDOC + DUA->DUA_DOC + DUA->DUA_SERIE== cSeek				
				If Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_TIPOCO") == StrZero(1,Len(DT2->DT2_TIPOCO)) //-- Encerra Processo
					dDatEnc:= DUA->DUA_DATOCO
					Exit
				EndIf
				DUA->(dbSkip())
			EndDo
		EndIf
		RestArea(aAreaDUA)
		RestArea(aAreaDT2)
	EndIf

	nDiaArm := (dDatEnc - dDatOco)

	If nDiaArm < aPerfil[39]
		Help(' ',1,'TMSA50082',,,4,1)	//-- "Quantidade de dias no armazem inferior ao perfil do cliente."
		Return( nOpcA )
	EndIf

	cDocTms := "E"	//-- CTRC Armazenagem
	If lUsaNfs .And. cCdrOri == AllTrim(DT6->DT6_CDRDES)
		cDocTms := "F" //-- Nota Fiscal Armazenagem
	EndIf

//Anulacao
ElseIf	nOpcx == 12
	cDocTms := Replicate('M', Len( DT6->DT6_DOCTMS ) ) //-- CTRC Anulacao  

	If	DT6->DT6_STATUS <> StrZero(7, Len(DT6->DT6_STATUS) )
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, 'TMSA50094') //-- A anulação é permitida somente para documentos entregues.
		Return( nOpcA )
	Else
		//--Verifica a situacao atual do documento da viagem
		cAliasQry := GetNextAlias()
		cQuery := " SELECT MAX(R_E_C_N_O_) DUDRecNo"
		cQuery += " FROM " + RetSqlTab("DUD")
		cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD")  + "'"
		cQuery += "   AND DUD.DUD_FILDOC = '" + DT6->DT6_FILDOC + "'"
		cQuery += "   AND DUD.DUD_DOC    = '" + DT6->DT6_DOC    + "'"
		cQuery += "   AND DUD.DUD_SERIE  = '" + DT6->DT6_SERIE  + "'"
		cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )
		DUD->( DbGoTo( (cAliasQry)->DUDRecNo ) )
		(cAliasQry)->( DbCloseArea() )
	EndIf

	If DT6->DT6_DOCTMS == Replicate('M', Len( DT6->DT6_DOCTMS ) ) // CTRC Anulacao
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA50097")	// "Este documento é de anulação, portanto não é possível gerar outro documento de anulação."
		Return( nOpcA )
	EndIf

	If DT6->DT6_FILDOC != cFilAnt
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA50095")	// "Anulacao permitida somente na filial de origem."
		Return( nOpcA )
	EndIf

	If Empty(cTESAnula) .Or. Empty(cTESAnula2)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA50098") // "O Parametro MV_TESANUL nao esta preenchido.
		Return( nOpcA )
	Else
		DbSelectArea("SF4")
		DbSetOrder(1)
		If !SF4->(DbSeek(xFilial("SF4")+cTESAnula)) .Or. SF4->F4_TIPO != "E"
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help( " ", 1, "TMSA50099") // "Não existe este código na tabela de TES ou a TES informada no parametro MV_TESANUL, não é do tipo Entrada"
			Return( nOpcA )
		EndIf
	EndIf

	//-- Se escolheu documento do primeiro percurso, sempre o documento FOB( ou 2o percurso ) sera devolvido
	If	DT6->DT6_PRIPER == StrZero(1,Len(DT6->DT6_PRIPER))
		DTC->(DbSetOrder(4)) // DTC_FILDOC+DTC_PRIPER+DTC_SERIE
		DTC->(MsSeek(xFilial('DTC') + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE))
		DT6->(MsSeek(xFilial('DT6') + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE))
	EndIf

	aAreaDT6 := DT6->(GetArea())
	DT6->(dbSetOrder(8))
	If DT6->(MsSeek(cSeek := xFilial("DT6") + DT6_FILDOC + DT6_DOC + DT6_SERIE))
		While DT6->(!Eof() .And. DT6_FILIAL + DT6_FILDCO + DT6_DOCDCO + DT6_SERDCO == cSeek)
			If DT6->DT6_DOCTMS == cDocTMS
				lHelp := .T.
				Exit
			EndIf
			DT6->(dbSkip())
		EndDo
	EndIf
	RestArea(aAreaDT6)
	If lHelp
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help(' ',1,'TMSA50019') // 'Ja existe uma devolucao OU UMA ANULACAO para esse documento'
		Return( nOpcA )
	EndIf

	//-- Define os campos que poderao ser alterados na devolucao
	Aadd(aAltera,'DT6_SERVIC')					//-- Servico de devolucao

	_cObsComp      := ''     
	              
//Substituicao
ElseIf nOpcx == 13 
	cDocTms := Replicate('P', Len( DT6->DT6_DOCTMS ) ) //-- CTRC Substituicao  
	lAnul   := DT6->DT6_STATUS == StrZero(9,Len(DT6->DT6_STATUS))	
	If	DT6->DT6_STATUS <> StrZero(7,Len(DT6->DT6_STATUS)) .And. DT6->DT6_STATUS <> StrZero(9,Len(DT6->DT6_STATUS))
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help('',1,"TMSA500A5") //-- A substituicao é permitida somente para documento entregue.
		Return( nOpcA )
  	ElseIf DT6->DT6_STATUS <> StrZero(9,Len(DT6->DT6_STATUS))
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help('',1,"TMSA500B2") //-- A substituicao é permitida somente para documento anulado.
 		Return( nOpcA )
	Else
		cAliasQry := GetNextAlias()
		//-- Procura pelos tipos de documentos
		cQuery := " SELECT  DT6_FILIAL, DT6_FILDCO, DT6_DOCDCO, DT6_SERDCO, DT6_DOCTMS  "
		cQuery += " FROM " + RetSqlTab("DT6")
		cQuery += " WHERE DT6.DT6_FILIAL = '" + xFilial("DT6")  + "'"
		cQuery += "   AND DT6.DT6_FILDCO = '" + DT6->DT6_FILDOC + "'"
		cQuery += "   AND DT6.DT6_DOCDCO = '" + DT6->DT6_DOC    + "'"
		cQuery += "   AND DT6.DT6_SERDCO = '" + DT6->DT6_SERIE  + "'"
		cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )
		Do While (cAliasQry)->(!EoF())
			If (cAliasQry)->DT6_DOCTMS == 'P' //-- Ja possui nota de substituicao
				lSubst := .T.
				Help('',1,"TMSA500A2") //-- O Documento já possui uma nota de substituicao gerada
				Exit
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->( DbCloseArea() )

		If lSubst
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return( nOpcA )
		ElseIf !lAnul .And. Posicione('SA1', 1, xFilial('SA1')+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV,'A1_CONTRIB') == '2' //-- necessaria nota de anulacao
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help('',1,"TMSA500A3") //-- A substituicao necessita de documento de anulacao prévio, quando o cliente não for contribuinte
			Return( nOpcA )
		EndIf
	EndIf

	//-- Define os campos que poderao ser alterados no complemento
	Aadd(aAltera,'DT6_VALMER')		//-- Valor da mercadoria
	Aadd(aAltera,'DT6_PESO')		//-- Peso real
	Aadd(aAltera,'DT6_QTDVOL')		//-- Quantidade de volumes
	Aadd(aAltera,'DT6_PESOM3')		//-- Peso cubado
	Aadd(aAltera,'DT6_TIPTRA')		//-- Tipo de Transporte
	Aadd(aAltera,'DT6_QTDUNI')		//-- Quantidade Unitizador

	//-- Campos para alteração do tomador de serviço
	Aadd(aAltera,'DT6_CLIDEV')	 	//-- Devedor	
	Aadd(aAltera,'DT6_LOJDEV')		//-- Loja Devedor
	
	Aadd(aAltera,'DT6_DEVFRE')	 	//-- Seleção do Devedor	do Frete


	If ExistBlock('TM500CPO')
		ExecBlock('TM500CPO',.F.,.F.,{nOpcx})
	EndIf
	
	_cObsComp      := ''

EndIf

//Observacao do Complemento
If nOpcx == 2 .Or. nOpcx == 7
	If DT6->(FieldPos("DT6_CODOBS")) > 0
		If !Empty(DT6->DT6_CODOBS)
			_cObsComp := MSMM(DT6->DT6_CODOBS,80)
		Else
			_cObsComp := ''
		EndIf
	Else
		_cObsComp := ''
	EndIf
Else
	_cObsComp := ''
EndIf

If Empty(cLoteAut) .And. !lTM500Auto
	//-- Teclas de atalho
	TmsKeyOn(aSetKey)

	//-- Botoes da EnchoiceBar
	AAdd(aButtons,	{'DESTINOS'	,{|| TmsA500Dig() } , STR0009, STR0086 }) //'Mais detalhes - <F4>'

	If	nOpcx != 2 .And. nOpcx != 7 .And. nOpcx != 12 .And. nOpcx != 8
		AAdd(aButtons,	{'BUDGET'	,{|| TmsA500Dsc(nOpcx, @lPrimComp, , , , , , , , , , cDocTms) } , cOpcao + ' - <F5> ' , Padr(cOpcao,7) + '.' })
	Else
		AAdd(aButtons,	{'PRECO' ,{|| TmsA500Fin() } , STR0010, STR0087 }) //"Visualiza Titulos - <F6>"
	EndIf

	AAdd(aButtons,	{'DEVOLNF'    , {|| TmsA500Tr1() } , STR0011, STR0088 }) //'Tracking de Operacoes - <F7>'
	AAdd(aButtons,	{'PEDIDO'	  , {|| TmsA500Tr2() } , STR0012, STR0089 }) //'Tracking de Ocorrencias - <F8>'
	AAdd(aButtons,	{'RELATORIO'  , {|| TmsA500Tr3() } , STR0013, STR0090 }) //'Tracking de Operacoes/Ocorrencias - <F9>'
	If !IsInCallStack("TMSA144")
		AAdd(aButtons,	{'CARGA'	  , {|| TmsA500Viag()} , STR0091, STR0092 }) //'Viagem - <F10>'
	EndIf
	AAdd(aButtons,	{'BMPINCLUIR' , {|| TmsA500Man() } , STR0093, STR0094 }) //'Manifesto - <F11>'
	//-- Chamada da tela de histórico do MDF-e
	If TableIndic("DLH",.F.) .And. ExistFunc("TMSA190A(2)")
		Aadd(aButtons,  {"BMPINCLUIR" , {|| TMSA190A(2)  } , STR0286, STR0286  }) //"Histórico MDF-e"
	EndIf 		
	AAdd(aButtons,	{'BMPORD'     , {|| TmsA500Tab() } , STR0095, STR0096 }) //'Tabela de Frete - <F12>'
	AAdd(aButtons,	{'RELATORIO'  , {|| TmsA500AWB() } , STR0097, STR0097 }) //'Awb'
	AAdd(aButtons,	{'EDIT'  	  , {|| TmsA500Seg() } , STR0148, STR0148 }) //'Indenizacoes'
	AAdd(aButtons,	{'NOCHECKED'  , {|| TmsA500Pen() } , STR0150, STR0150 }) //'Pendencia

EndIf

//-- Valor informado x documento de complemento
If	( cDocTms==StrZero(8,Len(DT6->DT6_DOCTMS)) .Or. cDocTms==Replicate('G',Len(DT6->DT6_DOCTMS)))
	AAdd(aButtons, {'COMPTITL', {|| TmsValInf(aValInf,'6',,,,,,,,,,,,nOpcx,,M->DT6_TABFRE,M->DT6_TIPTAB,,M->DT6_CODNEG) }, STR0098, STR0099 }) //'Valor Informado'
	//-- Na visualizacao inicializa o vetor aValInf
	If	nOpcx==2
		TmsValInf(aValInf,'7',M->DT6_FILDOC,,,,,,,,M->DT6_DOC,M->DT6_SERIE,,nOpcx,,,,,M->DT6_CODNEG)
	EndIf
EndIf

AAdd(aButtons,	{'PMSDOC'     , {|| TmsA500Comp(M->DT6_FILDOC,M->DT6_DOC,M->DT6_SERIE) }, STR0102, STR0074 }) //'Documentos Complementares'

//-- Tipos de Veiculos
If ( nOpcx == 2  .Or. nOpcx == 5 .Or. nOpcx == 6 .Or. nOpcx == 4)
	AAdd(aButtons, {'RPMNEW', {|| A500TipVei(nOpcx,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE) } , STR0140 , STR0141 }) //'Tipos de Veiculo'
EndIf

If nOpcx == 2 .Or. nOpcx == 6 .Or. nOpcx == 10 .Or. (nOpcx == 7 .And. DT6->DT6_DOCTMS == StrZero( 8, Len( DT6->DT6_DOCTMS ))) .Or. nOpcx == 12 .Or. nOpcx == 13 .Or. (nOpcx == 7 .And. DT6->DT6_DOCTMS == Replicate('M', Len( DT6->DT6_DOCTMS ) )) .Or. nOpcx == 4 .Or. nOpcx == 5
	AAdd(aButtons,	{'SDUPROP' , {|| TmsA500OBS(nOpcx) } , STR0146, STR0147 }) //'Observacao'
EndIf

If nOpcx == 2 .And. DT6->DT6_TIPTRA == StrZero(4,Len(DT6->DT6_TIPTRA)) //-- Rodoviario Internacional
	AAdd(aButtons,{'WEB'       ,{|| TmA500FPais(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)}, STR0152,  STR0153 }) //"Frete por País"###"Fr.País"
	AAdd(aButtons,{'EDITABLE'  ,{|| TmA500FDAF(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)} , STR0154 , STR0155 }) //"Frete CIF/FOB"###"Fr.Cif/Fob"
	AAdd(aButtons,{'INSTRUME'  ,{|| TmA500MIC()  } , 'MIC/DTA', 'MIC/DTA' }) 
	AAdd(aButtons,{'HISTORIC'  ,{|| TmsCAltCRT() } , STR0156, STR0157 })  //'Alterações CRT'###'Alt. CRT'
EndIf

//Ponto de Entrada para adicionar botoes
If lTm500BUT
	aButTmp := ExecBlock('TM500BUT',.F.,.F.,{nOpcx,aButtons})
	If ValType(aButTmp) == "A" .And. Len(aButTmp) > 0
		aButtons := aClone(aButTmp)
	EndIf
EndIf

If nOpcx == 2
	AAdd(aButtons,{'SIMULACA'  ,{|| TM500CDoc(oDlgEsp) } , 'Custo Docto' , 'Custo Docto' }) 
EndIf

If lAgdEntr
	AAdd(aButtons,{'LEGAGD'    ,{|| Tms500LAgd() }       , 'Legenda Age.Entrega', 'Legenda Age.Entrega' }) 
EndIf

AAdd(aButtons,{'RELATORIO' ,{|| FWExecView(,"TMSA254",1,,{|| .T.},,50,,,,,) } , 'Hist Rat Pagar' , 'Hist Rat Pagar' }) 

If TableIndic("DLR")
	AAdd(aButtons,{'CHAVE CTE SUB' ,{|| FWExecView(,"TMSA037",1,,{|| .T.},,50,,,,,) } , 'Chv.Cte Sub' , 'Chv.Cte Sub' }) 
EndIf 

//-- Se o documento nao eh de cobrança de servico adicional entao mostra o botao 'Docs. Serviço Adicional' em
//-- Outras Acoes para visualizacao dos documentos de servico adicional vinculados a alguma nota do documento de frete
If FindFunction("TMSA853Doc") .And. FindFunction("TMSA853DSa") .And.;
   ! TMSA853DSa(M->DT6_FILDOC, M->DT6_DOC, M->DT6_SERIE, M->DT6_DOCTMS)
	AAdd(aButtons,{'DOCSERADD' ,{|| TMSA853Doc(M->DT6_FILDOC, M->DT6_DOC, M->DT6_SERIE)} , STR0260, STR0260}) //STR0260 'Docs. Serviço Adicional'
EndIf

If nOpcx != 2
	//-- Configura variaveis da Enchoice
	RegToMemory(cAlias,.F.)
EndIf

nPerOri := M->DT6_PERDCO

If	nOpcx != 2

	If lCancela 
		If Empty(M->DT6_DOCDCO)
		
			//-- Verifica se o documento eh de Cobrança de Servico Adicional
			If ! FindFunction("TMSA853DSa") .Or.;
		        (FindFunction("TMSA853DSa") .And. ! TMSA853DSa(M->DT6_FILDOC, M->DT6_DOC, M->DT6_SERIE, M->DT6_DOCTMS))

				Help( " ",1,"TMSA50051",,TmsValField('M->DT6_DOCTMS',.F.) + STR0103,2,1) //"Nao e permitido o cancelamento de "###", atraves desta rotina"
				RestArea(aAreaDTQ)
				RestArea(aAreaDUD)
				RestArea(aAreaAnt)
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Return( nOpcA )
			EndIf
		EndIf
	Else
		//-- Validações do Documento Devolução / Reentrega 
		If lTm500V02
			lRetV02 := ExecBlock('TM500V02',.F.,.F.,{nOpcx})
			If ValType(lRetV02) <> "L"
				lRetV02 := .F.
			EndIf
		EndIf
 
		//-- Devolucao
		If nOpcx == 4 .And. !lRetV02
			If (M->DT6_DOCTMS != "2" .And. M->DT6_DOCTMS != "5" .And. ;
				M->DT6_DOCTMS != "B" .And. M->DT6_DOCTMS != "C" .And. M->DT6_DOCTMS != "H" .And. ;
				M->DT6_DOCTMS != "I" .And. M->DT6_DOCTMS != "N" .And. M->DT6_DOCTMS != "O" .And. M->DT6_DOCTMS != "A")
				Help( ' ', 1, 'TMSA50014',,STR0008 + M->DT6_DOC + STR0014 + M->DT6_SERIE,4,1)	//-- Manutencao permitida somente em conhecimento ou nota fiscal. //'Docto: '###' Serie: '
				RestArea(aAreaDTQ)
				RestArea(aAreaDUD)
				RestArea(aAreaAnt)
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Return( nOpcA )
			EndIf
		//Se for Documento de Substituição
		ElseIf nOpcx == 13
			If ( M->DT6_DOCTMS != "2" .And. M->DT6_DOCTMS != "7" .And. ;
				M->DT6_DOCTMS != "9" .And. M->DT6_DOCTMS != "6" .And. ;
				M->DT6_DOCTMS != "E" .And. M->DT6_DOCTMS != "A" .And. M->DT6_DOCTMS != "P")
				Help( ' ', 1, 'TMSA50014',,STR0008 + M->DT6_DOC + STR0014 + M->DT6_SERIE,4,1)	//-- Manutencao permitida somente em conhecimento //'Docto: '###' Serie: '
				RestArea(aAreaDTQ)
				RestArea(aAreaDUD)
				RestArea(aAreaAnt)
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Return( nOpcA )
			EndIf
		//-- Se for Complemento de Imposto, so' validar se o CTRC estiver bloqueado (DT6_SERIE='PED')
		ElseIf !lRetV02 
			If M->DT6_DOCTMS == "1" .Or. ((nOpcx == 6 .Or. nOpcx == 10) .And. M->DT6_SERIE == 'PED' ) .Or. ;
				(nOpcx <> 6 .And. nOpcx <> 10 .And. ((M->DT6_DOCTMS != "2" .And. M->DT6_DOCTMS != "5" .And. M->DT6_DOCTMS != "6") .Or. M->DT6_SERIE == 'PED'))
				Help( ' ', 1, 'TMSA50014',,STR0008 + M->DT6_DOC + STR0014 + M->DT6_SERIE,4,1)	//-- Manutencao permitida somente em conhecimento ou nota fiscal. //'Docto: '###' Serie: '
				RestArea(aAreaDTQ)
				RestArea(aAreaDUD)
				RestArea(aAreaAnt)
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Return( nOpcA )
			EndIf 	 
		EndIf
	EndIf

	M->DT6_DESDOC := TmsValField('cDocTms',.F.)
	//-- Devolucao ou Anulacao
	If	nOpcx == 4 .Or. nOpcx == 12
		cFilOri := M->DT6_FILORI
		cFilDes := M->DT6_FILDES
		cCliRem := M->DT6_CLIREM
		cLojRem := M->DT6_LOJREM
		cCliDes := M->DT6_CLIDES
		cLojDes := M->DT6_LOJDES
		cCdrOri := M->DT6_CDRORI
		cCdrDes := M->DT6_CDRDES
		cCdrCal := M->DT6_CDRCAL
		cTipFre := M->DT6_TIPFRE
		cCliDev := M->DT6_CLIDEV
		cLojDev	:= M->DT6_LOJDEV
		dDatEmi	:= M->DT6_DATEMI

		cCliExp := If(lExpedidor,M->DT6_CLIEXP,"")
		cLojExp := If(lExpedidor,M->DT6_LOJEXP,"")
		cCliRec := If(lRecebedor,M->DT6_CLIREC,"")
		cLojRec := If(lRecebedor,M->DT6_LOJREC,"")
		If nOpcx == 4 //-- Devolução
			M->DT6_FILORI := cFilDes
			M->DT6_FILDES := cFilOri

			//-- Inverte Remetente x Destinatário na Devolução, e Recebedor com Expedidor caso tenha
			
			M->DT6_CLIREM := cCliDes
			M->DT6_LOJREM := cLojDes
			M->DT6_NOMREM := Posicione('SA1', 1, xFilial('SA1') + M->DT6_CLIREM + M->DT6_LOJREM,'A1_NOME')
			M->DT6_CLIDES := cCliRem
			M->DT6_LOJDES := cLojRem
			M->DT6_NOMDES := Posicione('SA1', 1, xFilial('SA1') + M->DT6_CLIDES + M->DT6_LOJDES,'A1_NOME')

			If !Empty(M->DT6_CLIREC) .And. !Empty(M->DT6_LOJREC)
				M->DT6_CDRORI := cCdrCal
			Else
				M->DT6_CDRORI := cCdrDes
			EndIf
			
			M->DT6_CDRDES := cCdrOri
			M->DT6_CDRCAL := cCdrOri

			M->DT6_CLIEXP := cCliRec
			M->DT6_LOJEXP := cLojRec
			M->DT6_CLIREC := cCliExp
			M->DT6_LOJREC := cLojExp
				
			M->DT6_NOMEXP := Posicione('SA1', 1, xFilial('SA1') + M->DT6_CLIEXP + M->DT6_LOJEXP,'A1_NOME')
			M->DT6_NOMREC := Posicione('SA1', 1, xFilial('SA1') + M->DT6_CLIREC + M->DT6_LOJREC,'A1_NOME')

			M->DT6_TIPFRE := Iif( M->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)), StrZero(2,Len(DT6->DT6_TIPFRE)), StrZero(1,Len(DT6->DT6_TIPFRE)) )

			//-- Caso o Devedor do frete seja o remetente, passara agora a ser o destinatario.
			//-- troca valida tambem para caso de destinatario devedor.
			//-- 1=Remetente;2=Destinatario;3=Consignatario;4=Despachante;6=Expedidor;7=Recebedor
			If lExpedidor .And. (M->DT6_CLIDEV + M->DT6_LOJDEV) == (M->DT6_CLIEXP + M->DT6_LOJEXP)
				M->DT6_DEVFRE := StrZero(6,Len(DT6->DT6_DEVFRE))
			ElseIf lRecebedor .And. (M->DT6_CLIDEV + M->DT6_LOJDEV) == (M->DT6_CLIREC + M->DT6_LOJREC)
				M->DT6_DEVFRE := StrZero(7,Len(DT6->DT6_DEVFRE))
			ElseIf (M->DT6_CLIDEV + M->DT6_LOJDEV) == (M->DT6_CLIREM + M->DT6_LOJREM)
				M->DT6_DEVFRE := StrZero(1,Len(DT6->DT6_DEVFRE))
			ElseIf (M->DT6_CLIDEV + M->DT6_LOJDEV) == (M->DT6_CLIDES + M->DT6_LOJDES)
				M->DT6_DEVFRE := StrZero(2,Len(DT6->DT6_DEVFRE))
			ElseIf (M->DT6_CLIDEV + M->DT6_LOJDEV) == (M->DT6_CLICON + M->DT6_LOJCON)
				M->DT6_DEVFRE := StrZero(3,Len(DT6->DT6_DEVFRE))
			ElseIf (M->DT6_CLIDEV + M->DT6_LOJDEV) == (M->DT6_CLIDPC + M->DT6_LOJDPC)
				M->DT6_DEVFRE := StrZero(4,Len(DT6->DT6_DEVFRE))
			EndIf

			If (!lExpedidor .Or. !lRecebedor .Or. ( Empty(M->DT6_CLIEXP) .And. Empty(M->DT6_CLIREC) ) ) .And. lOriCal 
				If  Empty(M->DT6_ORICAL) 
					M->DT6_ORICAL := StrZero(2,Len(DT6->DT6_ORICAL))   //Cliente
					RunTrigger(1,Nil,Nil,,"DT6_ORICAL")
				EndIf
				If Empty(M->DT6_DESCAL)
					M->DT6_DESCAL:= StrZero(2,Len(DT6->DT6_DESCAL))   //Cliente
					If lTM500Auto			
						RunTrigger(1,Nil,Nil,,"DT6_DESCAL")
					EndIf	
				EndIf
			//-- tratamento com os campos Expedidor,Recebedor ou ambos preenchidos
			//-- Gatilha os campos DT6_ORICAL e DT6_DESCAL com base no expedidor e recebedor
			Else
				M->DT6_ORICAL := Iif(!Empty(M->DT6_CLIEXP),StrZero(0,Len(DT6->DT6_ORICAL)),StrZero(2,Len(DT6->DT6_ORICAL)))
				M->DT6_DESCAL := Iif(!Empty(M->DT6_CLIREC),StrZero(4,Len(DT6->DT6_DESCAL)),StrZero(2,Len(DT6->DT6_DESCAL)))
				If lTM500Auto
					RunTrigger(1,Nil,Nil,,"DT6_ORICAL")
					RunTrigger(1,Nil,Nil,,"DT6_DESCAL")
				EndIf
			EndIf

		Else
			M->DT6_FILORI := cFilOri
			M->DT6_FILDES := cFilDes
			M->DT6_CLIREM := cCliRem
			M->DT6_LOJREM := cLojRem
			M->DT6_NOMREM := Posicione('SA1', 1, xFilial('SA1') + M->DT6_CLIREM + M->DT6_LOJREM,'A1_NOME')
			M->DT6_CLIDES := cCliDes
			M->DT6_LOJDES := cLojDes
			M->DT6_NOMDES := Posicione('SA1', 1, xFilial('SA1') + M->DT6_CLIDES + M->DT6_LOJDES,'A1_NOME')
			M->DT6_CDRORI := cCdrOri
			M->DT6_CDRDES := cCdrDes
			M->DT6_CDRCAL := cCdrCal
			M->DT6_TIPFRE := cTipFre

			//-- Se foi informado Consignatario ou Despachante mantem o cliente devedor especificado na digitacao
			//-- da entrada da nota fiscal do cliente.
			If	Empty( M->DT6_CLICON ) .And. Empty( M->DT6_CLIDPC )
				M->DT6_CLIDEV := cCliDev
				M->DT6_LOJDEV := cLojDev
				M->DT6_NOMDEV := Posicione('SA1', 1, xFilial('SA1') + M->DT6_CLIDEV + M->DT6_LOJDEV,'A1_NOME')
			EndIf

			//Verifica se cliente e contribuinte do ICMS
			cInscr   := Posicione('SA1', 1, xFilial('SA1') + M->DT6_CLIDEV + M->DT6_LOJDEV,'A1_INSCR')
			cContrib := Posicione('SA1', 1, xFilial('SA1') + M->DT6_CLIDEV + M->DT6_LOJDEV,'A1_CONTRIB')
			If	Alltrim(cContrib) == "2" .Or. Empty(cInscr) .Or. Alltrim(Upper(cInscr)) $ "ISENT" .Or. ;
				Alltrim(Upper(cInscr)) $ "RG"
				lContrib := .F.
			Else
				lContrib := .T.
			EndIf
			// ------------------------------------------------------------------------------------------------ //
			// Ponto de entrada: TM500CON - Alterar tratamento para Cliente contribuinte / não contribuinte.    //
			// Criado ponto de entrada TM500CON na rotina de Manutenção de Documentos / Anulação (TMSA500) para // 
			// definir geração documento de devolução para clientes contribuintes do ICMS com formulário próprio//
			// similar ao gerado para clientes não contribuinte do ICMS.                                        //
			// Este ponto de entrada altera funcionalidade definida através do convenio SINIEF 02/08.           //
			// Lógico (default .F.), onde.F. para geração de documento de devolução com formulário próprio.     //
			// ------------------------------------------------------------------------------------------------ //
			If lTm500CON
				lContrib := ExecBlock("TM500CON",.F.,.F.)
				If ValType(lContrib) <> "L"
					lContrib := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	cCdrOriPE:= ""
	
	
	//-- Se for devolucao ou reentrega ou armazenagem ou anulacao 
	If	nOpcx == 4 .Or. nOpcx == 5 .Or. nOpcx == 11 .Or. nOpcx == 12 
		//-- Define a regiao origem do documento de devolucao ou reentrega.
		If lTM500ORI
			cCdrOri := ExecBlock("TM500ORI",.F.,.F.)
			If ValType(cCdrOri) <> "C"
				cCdrOri := PadR(GetMV('MV_CDRORI',,''),Len(DUY->DUY_GRPVEN))
			Else
				If lOriCal
					cCdrOriPE:= cCdrOri
				EndIf	
			EndIf
		Else
			cCdrOri := PadR(GetMV('MV_CDRORI',,''),Len(DUY->DUY_GRPVEN))
		EndIf
		If	!Empty(cCdrOri)
			//-- Se Devolucao, e houver Ponto de Entrada deve-se considerar o conteudo do PE. 
			//-- Caso contrario considerar a Origem que foi gatilhada pelo campo DT6_ORICAL 
			If nOpcx == 4   
				If lTM500ORI .And. !Empty(cCdrOriPE)  
					M->DT6_ORICAL := StrZero(3,(Len(DT6->DT6_ORICAL)))  //Outros
					M->DT6_CDRORI := cCdrOri
				EndIf	
			Else
				M->DT6_CDRORI := cCdrOri
			EndIf	
		EndIf
		If nOpcx == 11
			M->DT6_SERVIC := cSerArm
		EndIf
	EndIf
	//-- Se for complemento apresenta os campos zerados
	If nOpcx == 6 .Or. nOpcx == 10
		M->DT6_VALMER	:= 0		//-- Valor da mercadoria
		M->DT6_PESO		:= 0		//-- Peso real
		M->DT6_QTDVOL	:= 0		//-- Quantidade de volumes
		M->DT6_PESOM3	:= 0		//-- Peso cubado
		M->DT6_METRO3	:= 0		//-- Metro cubico
		M->DT6_QTDUNI	:= 0		//-- Quantidade Unitizador
		M->DT6_BASSEG	:= 0		//-- Base Seguro RR
	EndIf
EndIf

//-- Este Ponto de Entrada tem por objetivo permitir a manipulacao das variaveis 
If ExistBlock('TM500MNT')
	ExecBlock('TM500MNT',.F.,.F.,{nOpcx})
EndIf

TmsViewFrt('7',M->DT6_FILDOC,M->DT6_DOC,M->DT6_SERIE,,,nOpcx)

//--Inicializa Tipos de Veículo
A500TipVei(nOpcx,M->DT6_FILDOC,M->DT6_DOC,M->DT6_SERIE,.F.)

If nOpcx == 11 .And. Empty(cLoteAut)
	For nCntFor := 1 to Len(aFrete)
		aFrete[ nCntFor, 2 ] := 0
		aFrete[ nCntFor, 5 ] := 0
		aFrete[ nCntFor, 6 ] := 0
	Next nCntFor
EndIf

//-- Complemento
If	nOpcx == 6 .Or. nOpcx == 10
	//-- Adicionar no vetor afrete todos os componentes da cofiguracao da tabela de frete
	TmsA500Cmp(M->DT6_TABFRE,M->DT6_TIPTAB)
EndIf

aFrtOri	:= AClone( aFrete )

//-- Calcula as dimensoes dos objetos.
aSize  := MsAdvSize( .T. )

AAdd( aObjects, { 100,50,.T.,.T. } )
AAdd( aObjects, { 100,50,.T.,.T. } )

aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
aPosObj:= MsObjSize( aInfo, aObjects, .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for cancelamento faz validacoes de permissao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCancela
	lProcessa := Tms500Can(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,cFilAnt)
EndIf

If lProcessa

	If !Empty(cDocTms)
		M->DT6_DOCTMS := cDocTms
		If ExistTrigger("DT6_DOCTMS")
			RunTrigger(1,Nil,Nil,,"DT6_DOCTMS")
		EndIf
	EndIf

	If Empty(cLoteAut) .And. !lTM500Auto
		DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

			If Len(aButtons) > nButMax //Maximo de botoes para a MDI

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Criacao paineis com coordenadas Zero e alinhamento no topo da tela³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				@0,0 MSPANEL oPanelLat SIZE 020,050 OF oDlgEsp
				oPanelLat:Align := CONTROL_ALIGN_LEFT

				For nButton := nButMax To Len(aButtons)

					oBtnLat := TBtnBmp2():New( 10, 10, 25,25,;
											aButtons[nButton,1], Nil, Nil,Nil,;
											aButtons[nButton,2], oPanelLat, aButtons[nButton,3], Nil, Nil,Nil )
											oBtnLat:Align := CONTROL_ALIGN_TOP

				Next nButton
				aDelButtons := {}
				nButMax--
				For nButton := 1 To nButMax
					AAdd(aDelButtons,Aclone(aButtons[nButton]))
				Next
				aButtons := aClone(aDelButtons)

			EndIf

			@0,0 MSPANEL oPanelEsp SIZE 020,050 OF oDlgEsp
			oPanelEsp:ALIGN := CONTROL_ALIGN_ALLCLIENT

			//-- Monta a Enchoice.
			oEnch := MsMGet():New( cAlias, nReg, Iif(nOpcX==4 .Or. nOpcX==5 .Or. nOpcX==6 .Or. nOpcX==13, 3, 2),,,,, aPosObj[1],aAltera, 3, , , ,oPanelEsp , ,.T. )
			oEnch:oBox:Align := CONTROL_ALIGN_TOP

			//-- Carregar o Redespachante do Documento
			TMSA500RED()
			
			//-- Monta o Objeto Folder
			oFolder:=TFolder():New( aPosObj[2,1], aPosObj[2,2], aTitles, aPages, oPanelEsp,,,,.T.,.T.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
			oFolder:Align := CONTROL_ALIGN_TOP

			For nCntFor := 1 To Len( oFolder:aDialogs )
				oFolder:aDialogs[ nCntFor ]:oFont := oDlgEsp:oFont
			Next

			//-- Folder Totalizador Composicao do Frete
			If lCamposRat
				@ 5,3 LISTBOX oLbx VAR cLbx FIELDS HEADER STR0015,STR0016,STR0017,STR0018, STR0223						SIZE	aPosObj[2,4]-aPosObj[2,2]-5,aPosObj[2,3]-aPosObj[2,1]-20	OF oFolder:aDialogs[1] ON DBLCLICK ( .T. ) PIXEL //'Composicao'###'Valor'###'Imposto'###'Valor + Imposto'###'% Rateio'
			Else
				@ 5,3 LISTBOX oLbx VAR cLbx FIELDS HEADER STR0015,STR0016,STR0017,STR0018, STR0283, STR0070, STR0284	SIZE	aPosObj[2,4]-aPosObj[2,2]-5,aPosObj[2,3]-aPosObj[2,1]-20	OF oFolder:aDialogs[1] ON DBLCLICK ( .T. ) PIXEL //'Composicao'###'Valor'###'Imposto'###'Valor + Imposto'###'TES'###'Descricao'###'CFOP'
			EndIf
			//-- Apresenta a composicao do frete
			TmsViewFrt('9')

			SaveInter()
			
			If lExibImp
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem do aHeader e aCols da tabela SD2  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cSeek := xFilial("SD2")+DT6->(DT6_DOC+DT6_SERIE+DT6_CLIDEV+DT6_LOJDEV)
				bWhile := {|| SD2->(!Eof()) .And. cSeek == SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) }
	
				aHeader := {}
				aCols   := {}
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Sintaxe da FillGetDados(nOpcx,cAlias,nOrder,cSeekKey,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry,bCriaVar,lUserFields) |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FillGetDados(nOpcx,"SD2",1,cSeek,bWhile,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,{|| MaCols920(.F.,.F.,.F.,@lContinua,@aPedidos,@aRecSE1,@aRecSE2,@aRecSF3,@a920Var,@aTitles) },.F.,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bbeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/,.T.)	
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aba de Impostos		³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[2]:oFont := oDlgEsp:oFont
				aObj[1] := MaFisRodape(1,oFolder:aDialogs[2],,{5,3, aPosObj[2,4]-aPosObj[2,2]-5, aPosObj[2,3]-aPosObj[2,1]-20},bListRefresh,.T.)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aba de Livros Fiscais ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[3]:oFont := oDlgEsp:oFont
				aObj[2] := MaFisBrwLivro(oFolder:aDialogs[3],{5,3, aPosObj[2,4]-aPosObj[2,2]-5, aPosObj[2,3]-aPosObj[2,1]-20},.T.,aRecSF3,.T.)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aba de Agd.de Entrega ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lExibImp .And. lAgdEntr 
				oFolder:aDialogs[4]:oFont := oDlgEsp:oFont
				aObj[3] := Tmsa500AGD(oFolder:aDialogs[4],{5,3, aPosObj[2,4]-aPosObj[2,2]-5, aPosObj[2,3]-aPosObj[2,1]-20})

				aObj[3]:bLine := {|| { aItensAgd[aObj[3]:nAt, 1] ,;
											  aItensAgd[aObj[3]:nAt, 2] ,;
											  aItensAgd[aObj[3]:nAt, 3] ,;
											  aItensAgd[aObj[3]:nAt, 4] ,;
											  aItensAgd[aObj[3]:nAt, 5] ,;
											  aItensAgd[aObj[3]:nAt, 6] ,;
											  aItensAgd[aObj[3]:nAt, 7] ,;
											  aItensAgd[aObj[3]:nAt, 8] ,;
											  aItensAgd[aObj[3]:nAt, 9] ,;
											  aItensAgd[aObj[3]:nAt,10] }}
			ElseIf !lExibImp .And. lAgdEntr
				oFolder:aDialogs[2]:oFont := oDlgEsp:oFont
				aObj[2] := Tmsa500AGD(oFolder:aDialogs[2],{5,3, aPosObj[2,4]-aPosObj[2,2]-5, aPosObj[2,3]-aPosObj[2,1]-20})

				aObj[2]:bLine := {|| { aItensAgd[aObj[2]:nAt, 1] ,;
											  aItensAgd[aObj[2]:nAt, 2] ,;
											  aItensAgd[aObj[2]:nAt, 3] ,;
											  aItensAgd[aObj[2]:nAt, 4] ,;
											  aItensAgd[aObj[2]:nAt, 5] ,;
											  aItensAgd[aObj[2]:nAt, 6] ,;
											  aItensAgd[aObj[2]:nAt, 7] ,;
											  aItensAgd[aObj[2]:nAt, 8] ,;
											  aItensAgd[aObj[2]:nAt, 9] ,;
											  aItensAgd[aObj[2]:nAt,10] }}
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ GFE                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lExibImp .And. !lAgdEntr .And. lTMSGFE 
				oFolder:aDialogs[3]:oFont := oDlgEsp:oFont
				aObj[3] := Tms500GFE(oFolder:aDialogs[4],{5,3, aPosObj[2,4]-aPosObj[2,2]-5, aPosObj[2,3]-aPosObj[2,1]-20})    
				If Len(aItensGfe) > 0				
					aObj[3]:bLine := {|| { aItensGfe[aObj[3]:nAt, 10] ,;
	       	  								  	aItensGfe[aObj[3]:nAt, 2],;
												aItensGfe[aObj[3]:nAt, 3] ,;
												TransForm(aItensGfe[aObj[3]:nAt, 4],PesqPict('DT6','DT6_PESO')) ,;
												TransForm(aItensGfe[aObj[3]:nAt, 5],PesqPict('DT6','DT6_VALMER')) ,;
												TransForm(aItensGfe[aObj[3]:nAt, 6],PesqPict('GWM','GWM_VLFRET')) ,;
												TransForm(aItensGfe[aObj[3]:nAt, 7],PesqPict('GWM','GWM_VLICMS')) ,;
												TransForm(aItensGfe[aObj[3]:nAt, 8],PesqPict('GWM','GWM_VLFRET')) ,;
												aItensGfe[aObj[3]:nAt, 9] }}
				EndIf
			ElseIf	!lExibImp .And. !lAgdEntr .And. lTMSGFE 
				oFolder:aDialogs[2]:oFont := oDlgEsp:oFont
				aObj[2] := Tms500GFE(oFolder:aDialogs[2],{5,3, aPosObj[2,4]-aPosObj[2,2]-5, aPosObj[2,3]-aPosObj[2,1]-20})    
				If Len(aItensGfe) > 0				
					aObj[2]:bLine := {|| { aItensGfe[aObj[2]:nAt, 10] ,;
	       	  								  	aItensGfe[aObj[2]:nAt, 2],;
												aItensGfe[aObj[2]:nAt, 3] ,;
												TransForm(aItensGfe[aObj[2]:nAt, 4],PesqPict('DT6','DT6_PESO')) ,;
												TransForm(aItensGfe[aObj[2]:nAt, 5],PesqPict('DT6','DT6_VALMER')) ,;
												TransForm(aItensGfe[aObj[2]:nAt, 6],PesqPict('GWM','GWM_VLFRET')) ,;
												TransForm(aItensGfe[aObj[2]:nAt, 7],PesqPict('GWM','GWM_VLICMS')) ,;
												TransForm(aItensGfe[aObj[2]:nAt, 8],PesqPict('GWM','GWM_VLFRET')) ,;
												aItensGfe[aObj[2]:nAt, 9] }}
			
           	EndIf
          EndIf
			If lExibImp .And. lAgdEntr .And. lTMSGFE
				oFolder:aDialogs[5]:oFont := oDlgEsp:oFont
				aObj[4] := Tms500GFE(oFolder:aDialogs[5],{5,3, aPosObj[2,4]-aPosObj[2,2]-5, aPosObj[2,3]-aPosObj[2,1]-20})
			ElseIf !lExibImp .And. lAgdEntr .And. lTMSGFE
				oFolder:aDialogs[3]:oFont := oDlgEsp:oFont
				aObj[3] := Tms500GFE(oFolder:aDialogs[3],{5,3, aPosObj[2,4]-aPosObj[2,2]-5, aPosObj[2,3]-aPosObj[2,1]-20})				    				
			EndIf

			RestInter()	

		ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| Iif( TmsA500TOk(lCancela,nOpcx,cOpcao,,@aDocExcMot),( nOpcA := 1, oDlgEsp:End() ), nOpcA := 0 ) }, {|| oDlgEsp:End() },, aButtons )
	Else
		If lTM500Auto
		 	//-- Substituicao ou Complemento ou Compl Imposto ou Devolução ou Reentrega ou Armazenagem
			If nOpcx == 13 .Or. nOpcx == 6 .Or. nOpcx == 10 .Or. nOpcx == 4 .Or. nOpcx == 5 .Or. nOpcx == 11 
				nOpca := IIf( TmsA500Dsc(nOpcx, @lPrimComp), 1, 0)
			Else 
				nOpca := 1 
			EndIf
			If nOpca == 1 .And. !TmsA500TOk(lCancela,nOpcx,cOpcao,)
				nOpca := 0
			EndIf
		Else
			nOpca := 1
		EndIf
	EndIf

	If nOpcA == 1 .And. nOpcx != 2 .And. Iif(!Empty(cLoteAut), TmsA500TOk(lCancela,nOpcx,cOpcao,),.T.)

		If !lCancela
			If nOpcx == 8 //-- Manutencao Documentos Alianca
				TmsA500Ali()
			Else
				If !Empty(cLoteAut)
					cTipMan := "1"
					If !TmsA500Dsc(nOpcx, @lPrimComp,,,)
						lRet  := .F.
						nOpca := 0
					EndIf
				EndIf
				If lRet
					//--Na Devolucao ou anulacao e necessario encerrar o DUD Original para nao ser mais utilizado em viagens
					If nOpcx == 4
						DUD->(DbSetOrder(1))
						If DUD->(MsSeek(xFilial('DUD') + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE + cFilAnt + Space(Len(DUD->DUD_VIAGEM))) )
							RecLock("DUD",.F.)
							DUD->DUD_STATUS := StrZero(4,Len(DUD->DUD_STATUS)) //--Encerrado
							DUD->(MsUnLock())
						EndIf
					//-- Reentrega 
					ElseIf nOpcx == 5 .And. lDocRee .And. !IsInCallStack("TMSA152")
						DbSelectArea("DUD")        //-- Encerra Mov Viagem do Documento original
						DbSetOrder(1)	
						If DUD->(MsSeek(xFilial("DUD")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE))) .And. DT6->DT6_DOCTMS == StrZero(2,Len(DT6->DT6_DOCTMS))
							RecLock("DUD",.F.)
							DUD->DUD_STATUS := StrZero(4,Len(DUD->DUD_STATUS)) //--Encerrado
							DUD->(MsUnLock())
						EndIf
					EndIf
					
					TmsA500Prc(nOpcX) //-- Gera Documentos   
					
				EndIf
			EndIf
		Else
			cFilOri	:= DT6->DT6_FILORI
			cLotNfc	:= DT6->DT6_LOTNFC
			cMark		:= GetMark()
			TmsA200Cmp(, aDelDocto, .T., .T., , , , , , , , , @aErrEst )
			Processa( {|lEnd| lRet := TMSA200Exc( aDelDocto, cLotNfc, @lEnd, @lDocto,, .T.,,aDocExcMot ) }, cCadastro,STR0107, .F. ) //Estornando conhecimento de frete...
			If DT6->DT6_DOCTMS == Replicate('M', Len( DT6->DT6_DOCTMS ) ) // CTRC Anulacao  
				//Estorna a observacao
				If !Empty(DT6->DT6_CODOBS)
					MSMM(DT6->DT6_CODOBS,,,,2,,,"DT6","DT6_CODOBS")
				EndIf
			EndIf

			//--Ao Estornar um documento de devolucao e necessario retornar o status do
			//DUD do documento original para Em Aberto
			If DT6->DT6_DOCTMS == StrZero(6,Len(DT6->DT6_DOCTMS))  //--Devolucao
				DUD->(DbSetOrder(1))
				If DUD->(MsSeek(xFilial('DUD') + DT6->DT6_FILDCO + DT6->DT6_DOCDCO + DT6->DT6_SERDCO + cFilAnt + Space(Len(DUD->DUD_VIAGEM))) )
					RecLock("DUD",.F.)
					DUD->DUD_STATUS := StrZero(1,Len(DUD->DUD_STATUS)) //--Em Aberto
					DUD->(MsUnLock())
				EndIf
			EndIf

			//-- Se todos os documentos contidos em cfilori e clotnfc foram excluidos, exclui o lote do DTP
			DT6->(DbSetOrder(2))
			If	! DT6->(MsSeek(xFilial('DT6') + cFilOri + cLotNfc))
				TmsA500Lot(cLotNfc,.T.)
			EndIf
			//-- Se for reentrega diminui 1 na quantidade de reentregas do documento original
			RestArea(aAreaDT6)
			If (DT6->DT6_DOCTMS == StrZero(7,Len(DT6->DT6_DOCTMS)) .Or. DT6->DT6_DOCTMS == Replicate('D', Len( DT6->DT6_DOCTMS ))).And. !DT6->DT6_STATUS $ "B/C/D"	//-- B- Cancelamento SEFAZ Aguardando, C- Cancelamento SEFAZ Autorizado, D- Cancelamento SEFAZ nao autorizado
				cFilDco := M->DT6_FILDCO
				cDocDco := M->DT6_DOCDCO
				cSerDco := M->DT6_SERDCO
				
				//--- Desmarca a Nota Fiscal para uso em uma próxima Reentrega DTC_DOCREE 
				TMSA500DREE(cFilDco,cDocDco,cSerDco)
							
				aAreaDT6 := DT6->(GetArea())
				DT6->(dbSetOrder(1))
				If MsSeek(xFilial('DT6') + cFilDco + cDocDco + cSerDco) .And. DT6->DT6_REENTR > 0
					RecLock("DT6",.F.)
					DT6->DT6_REENTR := DT6->DT6_REENTR - 1
					MsUnLock()
				EndIf			
				RestArea(aAreaDT6)												
			EndIf
			//-- Exclusao dos tipos de veiculos
			If DWT->(MsSeek(xFilial("DWT")+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE))
				RecLock("DWT",.F.)
				dbDelete()
				DWT->(MsUnLock())
			EndIf

			//-- Tratamento Receitas/Despesas -> Limpa Referencias Na Tabela DUA
			For nCntFor := 1 To Len(aDelDocto) 

				//-- Atualiza Tabela De Ocorrencias DUA
				cQuery := ""
				cQuery += " UPDATE	" + RetSqlName("DUA") + " "
				cQuery += " SET		DUA_FLOCTE =  '" + Space(Len(DT6->DT6_FILDOC)) + "', "
				cQuery += "         DUA_NUMCTE =  '" + Space(Len(DT6->DT6_DOC   )) + "', "
				cQuery += "         DUA_SERCTE =  '" + Space(Len(DT6->DT6_SERIE )) + "', "
				cQuery += "         DUA_RECDEP =  '1' "
				cQuery += " WHERE   DUA_FILIAL =  '" + FWxFilial("DUA")            + "'  "
				cQuery += " AND		DUA_FLOCTE =  '" + aDelDocto[nCntFor,1]        + "'  "
				cQuery += " AND		DUA_NUMCTE =  '" + aDelDocto[nCntFor,2]        + "'  "
				cQuery += " AND		DUA_SERCTE =  '" + aDelDocto[nCntFor,3]        + "'  "
				cQuery += " AND     DUA_NUMCTC =  ' ' "
				cQuery += " AND		D_E_L_E_T_ =  ' ' "

				//-- Executa Script
				nCodRet:= TcSqlExec(cQuery)

				//-- Inclui Log De Erro
				If nCodRet < 0
					Help( ,, ProcName(),, TcSqlError() , 1, 0)
				Else
					
					//-- Atualiza Tabela De Ocorrencias DUA
					cQuery := ""
					cQuery += " UPDATE	" + RetSqlName("DUA") + " "
					cQuery += " SET		DUA_FLOCTE =  '" + Space(Len(DT6->DT6_FILDOC)) + "', "
					cQuery += "         DUA_NUMCTE =  '" + Space(Len(DT6->DT6_DOC   )) + "', "
					cQuery += "         DUA_SERCTE =  '" + Space(Len(DT6->DT6_SERIE )) + "', "
					cQuery += "         DUA_RECDEP =  '1' "
					cQuery += " WHERE   DUA_FILIAL =  '" + FWxFilial("DUA")            + "'  "
					cQuery += " AND		DUA_FLOCTE =  '" + aDelDocto[nCntFor,1]        + "'  "
					cQuery += " AND		DUA_NUMCTE =  '" + aDelDocto[nCntFor,2]        + "'  "
					cQuery += " AND		DUA_SERCTE =  '" + aDelDocto[nCntFor,3]        + "'  "
					cQuery += " AND     DUA_NUMCTC <>  ' ' "
					cQuery += " AND		D_E_L_E_T_ =  ' ' "
	
					//-- Executa Script
					nCodRet	:= TcSqlExec(cQuery)
	
					//-- Inclui Log De Erro
					If nCodRet < 0
						Help( ,, ProcName(),, TcSqlError() , 1, 0)
					EndIf
										
				EndIf
			
			Next nCntFor
			
			//-- Se o documento eh de Cobrança de Servico Adicional, elimina relacionamento DY4
			If FindFunction("TMSA853DSa") .And. TMSA853DSa(M->DT6_FILDOC, M->DT6_DOC, M->DT6_SERIE, M->DT6_DOCTMS)
				TMSA853ESa(M->DT6_FILDOC, M->DT6_DOC, M->DT6_SERIE)
			EndIf

			If lDelDoc .And. lCancela
				ExecBlock("TM500DEL",.F.,.F.,aDelDocto)
			EndIf
		EndIf

		//-- Se encontrou algum erro
		If	!Empty( aMsgErr )
			TmsMsgErr( aMsgErr,,lTM500Auto )
		EndIf
	EndIf
EndIf

If FwIsInCallStack('TMSC080')
	aRotina := {}
	FwFreeArray(aRotina)
EndIf

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

//-- Restaura Filial se atual nao for a mesma do documento
If	cFilAnt <> cFilBkp
	cFilAnt := cFilBkp
EndIf

If (IsInCallStack(AllTrim('TMSA500'))) .Or. (IsInCallStack(AllTrim('TMSC020')))
	//-- Inicio da Tecla de Atalho  
	aSetKey:= {}
	Aadd(aSetKey, { VK_F12 , { || TMS500Perg(.t.) } } )
	TmsKeyOn(aSetKey)
EndIf

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

RestArea(aAreaDTQ)
RestArea(aAreaDUD)
//-- RestArea(aAreaAnt) //-- EAlberti -- Removido Para DT6 Voltar Posicionado No Documento Gerado Pelo ExecAuto
RestArea(aAreaSM0)

Return( nOpcA )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500TOk³ Autor ³ Alex Egydio           ³ Data ³24.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao geral do sistema                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - .T. Indica que esta na opcao de cancelamento       ³±±
±±³          ³ ExpN1 - Opcao de manutencao                                ³±±
±±³          ³ ExpC1 - Descricao da opcao de manutencao                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500TOk(lCancela,nOpcx,cOpcao,cServic,aDocExcMot)

Static lCHGSX5FIL := ExistBlock("CHGX5FIL")
Local cFilSX5     := xFilial("SX5")
Local nPos        := 0
Local cMv_Estado  := SuperGetMV("MV_ESTADO",.F.,"")
Local cTipDocMot  := SuperGetMv("MV_DMOTEST",.F.," ") //Tipos de documentos que pede motivo
Local lTM200SER   := ExistBlock("TM200SER")//-- Pto no calculo do frete que permite alterar o numero de serie da nota fiscal
Local lTM500TOK   := ExistBlock("TM500TOK")
Local lRetPE      := .F.
Local lMultSerie  := FindFunction("TmsSerie")

Default cServic   := M->DT6_SERVIC
Default aDocExcMot:= {}

If !lCancela .And. nOpcx != 2

	If	nOpcx != 6 .And. nOpcx != 8 .And. nOpcx != 9 .And. nOpcx != 11 .And. nOpcx != 12 .And. M->DT6_PERDCO <= 0 .And. Empty(cLoteAut)
		Help( " ",1,"TMSA50052",,FWX3TITULO('DT6_PERDCO') + STR0081 + cOpcao,2,1) //"Informe o "### "teclando no botao"
		Return( .F. )
	EndIf

	//-- Posiciona no servico
	If  nOpcx != 13
		If	! TmsA500DC5(cServic)
			Return( .F. )
		EndIf
	EndIf
	cSerTms := DC5->DC5_SERTMS
	cTipTra := DC5->DC5_TIPTRA

	//-- Posiciona configuracao de documentos para obter a Serie do Documento.
	DUI->(DbSetOrder(1))
	If	DUI->(!MsSeek(xFilial('DUI') + cDocTms, .F.))
		Help( ' ', 1, 'TMSA50006',,STR0019 + cDocTms,4,1) //-- Documento nao encontrado na configuracao de documentos. (DUI) //'Documento: '
		Return( .F. )
	EndIf
	cSerie := DUI->DUI_SERIE
	cPrdImp:= DUI->DUI_CODPRO
	//-- Verifica se informou serie para origem em outra filial.
	If !Empty(DUI->DUI_SEROUT)
		If DUY->(MsSeek(xFilial("DUY")+Iif(nOpcx == 4,DT6->DT6_CDRDES,DT6->DT6_CDRORI))) //-- Para devolucao pesquisa UF destino!
			If	cMv_Estado <> DUY->DUY_EST
				cSerie := DUI->DUI_SEROUT
			EndIf
		EndIf
	EndIf

	//-- Localiza serie do documento original caso o servico esteja configurado
	If DC5->DC5_UTISDC == '1'
		cSerie := DT6->DT6_SERIE 
	EndIf

	If lMultSerie  
		cSerie := TmsSerie(cSerie, DT6->DT6_NCONTR, DT6->DT6_CODNEG, DT6->DT6_SERVIC)
	EndIf

	//--Se existir o ponto de entrada no Calculo do Frete que altera a serie, considerar
	//--a serie do documento original
	If lTM200SER
		cSerie := ExecBlock("TM200SER", .F. , .F. , {DT6->DT6_CLIDEV,DT6->DT6_LOJDEV})
		If ValType(cSerie) != "C" .Or. Empty(cSerie)
			cSerie := DT6->DT6_SERIE
		EndIf
	EndIf

	If lCHGSX5FIL
		cFilSX5 := ExecBlock("CHGX5FIL",.F.,.F.)
	EndIf

	//-- Verifica se a serie esta cadastrada na tabela 01 - Series de notas fiscais.
	SX5->( DbSetOrder( 1 ) )
	If	SX5->( ! MsSeek( cFilSX5 + '01' + cSerie, .F. ) )
		Help( ' ', 1, 'TMSA50007',,STR0020 + cSerie,5,1)						//-- Serie nao encontrada na tabela 01 - Serie de N. Fiscais. (SX5) //'Serie: '
		Return( .F. )
	EndIf
	//-- Este produto sera gravado no SD2 para calculo de impostos de transporte
	If Empty( cPrdImp )
		Help(' ', 1, 'TMSA50008',,STR0019 + cDocTms,4,1)						//-- Produto para calculo de impostos nao informado na configuracao de documentos. (DUI) //'Documento: '
		Return( .F. )
	EndIf
	//-- Posiciona o produto.
	SB1->(DbSetOrder(1))
	If	SB1->(!MsSeek(xFilial('SB1') + cPrdImp, .F.))
		Help(' ', 1, 'TMSA50009',,STR0021 + cPrdImp,4,1)						//-- Produto nao encontrado. (SB1) //'Produto: '
		Return( .F. )
	EndIf

	If !Empty(cOpcao) //Somente valida o valor do frete zerado na confirmacao do botao OK
		nPos := AScan(aFrete,{|x| x[3]=='TF' })
		If	Empty( nPos ) .Or. Empty( aFrete[ nPos, 2 ] )
			Help(' ',1,'TMSA50087')	//"Valor do frete zerado"
			Return( .F. )
		EndIf
	EndIf

	//-- ExecBlock TM500VLD
	//-- Ponto               : Permiter Verificar se o Numero do documento foi confirmado.
	//-- Parametros Enviados : Array com a seguinte informacao:
	//--                       PARAMIXB[01] = Opcao de chamada do Menu.
	//--                       PARAMIXB[02] = Retorno da Funcao SX5NumNota().
	//--
	//-- Retorno Esperado    : Variavel logica .T. or .F.

	If ExistBlock('TM500VLD')
		lRetPE:= ExecBlock("TM500VLD",.F.,.F., {nOpcx,.F.})
		If !lRetPE
			Return( .F. )
		EndIf
	EndIf
	
	If nOpcx == 12 .And. Empty(_cObsComp) // Caso seja Anulacao e Observacao nao estiver preenchida
		Help( " ", 1, 'TMSA50096') // Obrigatorio informar no campo observacao, o motivo da anulacao do CTRC.
		Return( .F. )
	EndIf

EndIf

If nOpcx == 7  
	If FindFunction("TMSA200C") .AND. FindFunction("TM200TipDo")  .AND. FWAliasInDic("DLX",.F.)
		If !Empty(cTipDocMot) .AND. TM200TipDo( {{ .T.,,,DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE }} ,cTipDocMot)
			If !(TMSA200C({{ .T.,,,DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE }},@aDocExcMot,cTipDocMot)) //Chama tela de motivo de cancelamento de documentos
				Return( .F. )
			Endif
		EndIf
	Endif
EndIf

If lTM500TOK
	lRetPE:= ExecBlock("TM500TOK",.F.,.F., {nOpcx})
	If ValType(lRetPE) == 'L' .And. !lRetPE
		Return( .F. )
	EndIf
EndIf
Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Dig³ Autor ³ Alex Egydio           ³ Data ³22.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza entrada de dados conforme o tipo de documento.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500Dig()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Dig()

Local aAreaDT6 := DT6->( GetArea() )
Local aFrtAnt  := AClone( aFrete )
// Variaveis utilizadas pelo programa TMSA050 ... NAO RETIRAR
Private aRatPesM3   := {}  // aCols Peso Cubado
Private aEndProd    := {}  // aCols de Enderecamento

//-- Zera Teclas de Atalhos
SaveInter()
TmsKeyOff(aSetKey)

If	M->DT6_DOCTMS == StrZero( 1, Len( DT6->DT6_DOCTMS ) )				//-- Coleta
	//-- Posiciona na solicitacao de coleta.
	DT5->( DbSetOrder( 4 ) )
	If	DT5->( MsSeek( xFilial('DT5') + M->DT6_FILDOC + M->DT6_DOC + M->DT6_SERIE, .F. ) )
		TmsA460Mnt( 'DT5', DT5->( Recno() ), 2 )
	EndIf
Else	
	If !Empty(M->DT6_DOCDCO) .And. !TmsPsqDY4(M->DT6_FILDOC,M->DT6_DOC,M->DT6_SERIE)
		TMSDocXNf(M->DT6_FILDCO,M->DT6_DOCDCO,M->DT6_SERDCO)
	Else
		TMSDocXNf(M->DT6_FILDOC,M->DT6_DOC,M->DT6_SERIE)
	EndIf	
EndIf 

RestInter()
aFrete := AClone( aFrtAnt )
RestArea( aAreaDT6 )

//-- Retorna Teclas de Atalhos
If !(IsInCallStack(AllTrim('TMSA145')))
	TmsKeyOn(aSetKey)
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Prc³ Autor ³ Alex Egydio           ³ Data ³24.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa o processamento da rotinas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500Prc(nOpcX)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 -> Opcao para o processamento da rotina.             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Prc(nOpcX)

Processa( {|lEnd| TmsA500Doc( @lEnd, nOpcX ) }, cCadastro,STR0025, .T. ) //'Gerando documentos...'

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Doc³ Autor ³ Alex Egydio           ³ Data ³24.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera documentos                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500Doc( lEnd, nOpcX, lRefatur )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Doc( lEnd, nOpcX, lRefatur )

Local aAreaDT6	  := DT6->(GetArea())
Local aAreaSF3	  := SF3->(GetArea())
Local aContrt	  := {}
Local aTmsA500    := {}
Local cFilDco	  := ''
Local cDocDco	  := ''
Local cLotNfc	  := ''
Local cSerDco	  := ''
Local cStatus     := ''
Local nCntFor	  := 0
Local cObsDoc     := ""
Local nPosTipVei  := 0
Local nCnt1       := 0
Local cTipNFC     := ''
Local lTM500DOC  := ExistBlock('TM500DOC')
Local lOriCal     := DT6->(ColumnPos('DT6_ORICAL')) > 0
Local lExpedidor	:= DTC->(ColumnPos("DTC_CLIEXP")) > 0 
Local lRecebedor    := DTC->(ColumnPos("DTC_CLIREC")) > 0

Private aNfs      := {}
Private aDocto    := {}
Private aLote     := {}

Default lRefatur  := .F.

If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

//--Observacoes dos Documentos
cObsDoc += If(!Empty(_cObsComp), _cObsComp+chr(10)+chr(13), "")
If nOpcx == 6 .Or. nOpcx == 10
	//-- Complemento de Frete/Imposto
	If	DT6->DT6_DOCTMS == StrZero( 5, Len( DT6->DT6_DOCTMS ) ) .Or.;		//--Nota Fiscal de Serv. de Transp.
		DT6->DT6_DOCTMS == Replicate('D', Len( DT6->DT6_DOCTMS ) ) .Or.;	//--Nota Fiscal de Reentrega
		DT6->DT6_DOCTMS == Replicate('F', Len( DT6->DT6_DOCTMS ) ) .Or.;	//--Nota Fiscal de Armazenagem
		DT6->DT6_DOCTMS == Replicate('G', Len( DT6->DT6_DOCTMS ) ) 		//--Nota Fiscal de Complemento
		cObsDoc += STR0173 + ": " + DT6->(AllTrim(DT6_DOC) + " / " + STR0035 + ": " + DT6_SERIE + " / " + STR0039 + ": " +  DtoC(DT6_DATEMI)) //--"Nota Fiscal complementar referente a nota fiscal No. / Série / Emissão"
	Else	
		cObsDoc += STR0174 + ": " + DT6->(AllTrim(DT6_DOC) + " / " + STR0035 + ": " + DT6_SERIE + " / " + STR0039 + ": " +  DtoC(DT6_DATEMI)) //--"CTRC complementar referente ao CTRC No. / Série / Emissão"
	EndIf

ElseIf nOpcx == 5
	//-- Reentrega
	cObsDoc := Alltrim(GetMv('MV_OBSREEN',,'')) + " " +Alltrim(_cObsComp)
ElseIf nOpcx == 11
	//-- Armazenagem
	cObsDoc := Alltrim(GetMv('MV_OBSARMA',,''))
ElseIf nOpcX == 12
	//-- Anulacao
	cObsDoc := STR0165 + DT6->DT6_DOC + "/" + DT6->DT6_SERIE + STR0166 + DToC(dDatEmi) + STR0167 + _cObsComp
ElseIf nOpcX == 4
	//-- Devolucao
	cObsDoc := AllTrim(_cObsComp)
ElseIf nOpcX == 13
	//-- Substituicao
	cObsDoc := STR0210 + DT6->DT6_DOC + " " + STR0035 + " "  + DT6->DT6_SERIE + " " + STR0211 + DToC(DT6->DT6_DATEMI) + " " + STR0209 + " : " + DT6->DT6_CHVCTE   
	
	//-- Alteração do tomador
	If M->DT6_CLIDEV + M->DT6_LOJDEV <> DT6->(DT6_CLIDEV+DT6_LOJDEV)
		cObsDoc	+= " " + STR0276 + " "	 //-- em virtude de tomador informado erroneamente
	EndIf
	
	cObsDoc	+=  STR0212 + Alltrim (TRANSFORM(DT6->DT6_VALTOT,PesqPict('DT6','DT6_VALTOT'))) + " " + _cObsComp
EndIf

If nOpcX == 4 .Or. cDocTms == StrZero(5,Len(DT6->DT6_DOCTMS))
	cStatus := StrZero(1,Len(DT6->DT6_STATUS))
Else
	cStatus := StrZero(7,Len(DT6->DT6_STATUS))
EndIf

If nOpcX == 12 .Or. nOpcX == 13
	cStatus := StrZero(7,Len(DT6->DT6_STATUS))
EndIf

aMsgErr := {}

//-- Obtem dados do contrato
If ! TmsA500Ctr(@aContrt,M->DT6_CLICAL,M->DT6_LOJCAL,M->DT6_SERVIC,M->DT6_TIPFRE,nOpcX)
	Return( Nil )
EndIf

//-- Utilizado na funcao TmsA200Atz
AAdd(aTmsA500,cStatus )																		//-- [01] = Status do documento DT6_STATUS
Aadd(aTmsA500,Iif(nOpcx==5 .Or. nOpcX==6 .Or. nOpcx==10 .Or. nOpcx==11 .Or. nOpcx==13,dDataBase,CtoD('')))	//-- [02] = Data de entrega
AAdd(aTmsA500,M->DT6_PERDCO)																//-- [03] = % do documento original
AAdd(aTmsA500,M->DT6_FILDOC)																//-- [04] = Filial do documento original
AAdd(aTmsA500,M->DT6_DOC)																	//-- [05] = Documento original
AAdd(aTmsA500,M->DT6_SERIE)																	//-- [06] = Serie do documento original
AAdd(aTmsA500,AClone(aValInf))																//-- [07] = Valor informado x documento de complemento
AAdd(aTmsA500,aContrt[1,9])																	//-- [08] = Condicao de Pagamento
AAdd(aTmsA500, If(nOpcx==10,'I',If(nOpcx==6,'C','N')))														//-- [09] = Tipo da Nota (F2_TIPO] / Tipo do Pedido [C5_TIPO] : 'I'
AAdd(aTmsA500,cTipMan)																		//-- [10] = Tipo de Manutencao
AAdd(aTmsA500,cObsDoc)																		//-- [11] = Observacao do Documento
AAdd(aTmsA500,M->DT6_FILDEB)																//-- [12] = Filial de Debito
If lOriCal
	AAdd(aTmsA500,M->DT6_ORICAL)																//-- [13] = Seleção de Origem Calculo
	AAdd(aTmsA500,M->DT6_DESCAL)																//-- [14] = Seleção de Destino Calculo
EndIf

If DT6->(ColumnPos('DT6_SQEDES')) > 0 
	AAdd(aTmsA500,M->DT6_SQEDES)															//--[15] == Seq. End. Destinatário na Devolução
EndIf	
AAdd(aTmsA500,M->DT6_PRZENT)															    //--[16] == Prazo de Entrega


If !Empty(M->DT6_FILDCO + M->DT6_DOCDCO + M->DT6_SERDCO)
	cFilDco	:= M->DT6_FILDCO
	cDocDco	:= M->DT6_DOCDCO
	cSerDco	:= M->DT6_SERDCO
Else
	cFilDco	:= M->DT6_FILDOC
	cDocDco	:= M->DT6_DOC
	cSerDco	:= M->DT6_SERIE
EndIf
//-- Posiciona na entrada de notas fiscais do cliente
If	M->DT6_PRIPER == StrZero(1,Len(DT6->DT6_PRIPER))
	DTC->(DbSetOrder(4)) // DTC_FILDOC+DTC_PRIPER+DTC_SERIE
Else
	DTC->(DbSetOrder(3))
EndIf
If DTC->(dbSeek(xFilial('DTC') + cFilDco + cDocDco + cSerDco))
	If M->DT6_DOCTMS == StrZero( 6, Len( DT6->DT6_DOCTMS ) )	 //-- Devolucao
		cTipNFC := '1'
	Else
		cTipNFC := DTC->DTC_TIPNFC
	EndIf
Else
	cTipNFC := '0' //-- Normal
EndIf

//--No Internacional precisamos pegar a serie de acordo com o documento original, devido ao permisso
//--ser pesquisado anteriormente na tabela DI0
If cTipTra == "4" .And. nOpcx == 6 //--Transporte Internacional - CRT de Complemento
	cSerie := M->DT6_SERIE
EndIf

//-- Define o vetor aLote
TmsA200Lot(aContrt,,M->DT6_CLICAL,M->DT6_LOJCAL,'','',cDocTms,cSerie,cSerTms,cTipTra,'',cPrdImp,'2',,aContrt[ 1, 8 ])
//-- Consulte as diretivas definidas para o vetor alote no programa tmsa200
nCntFor := Len(aLote)
aLote[nCntFor,001] := M->DT6_CLIREM		//-- LTCLIREM
aLote[nCntFor,002] := M->DT6_LOJREM		//-- LTLOJREM
aLote[nCntFor,003] := M->DT6_CLIDES		//-- LTCLIDES
aLote[nCntFor,004] := M->DT6_LOJDES		//-- LTLOJDES
aLote[nCntFor,005] := M->DT6_CLIDEV		//-- LTCLIDEV
aLote[nCntFor,006] := M->DT6_LOJDEV		//-- LTLOJDEV
aLote[nCntFor,009] := M->DT6_CLIREM		//-- LTCLIAGR
aLote[nCntFor,010] := M->DT6_LOJREM		//-- LTLOJAGR
aLote[nCntFor,033] := M->DT6_TIPTRA		//-- LTTIPTRA

If lExpedidor
	aLote[nCntFor,094] := M->DT6_CLIEXP		//-- LTCLIEXP   	94     		//-- Codigo Cliente Expedidor
	aLote[nCntFor,095] := M->DT6_LOJEXP		//-- LTLOJEXP   	95     		//-- Loja Cliente Expedidor
EndIf
If lRecebedor
	aLote[nCntFor,100] := M->DT6_CLIREC		//-- LTCLIREC   100			//-- Codigo Cliente Recebedor
	aLote[nCntFor,101] := M->DT6_LOJREC		//-- LTLOJREC   101			//-- Loja Cliente Recebedor
EndIf
//-- Na manutencao de documentos nao ha uma composicao de frete por produto, e sim por documento( Devolucao, Reentrega, Complemento )
aLote[nCntFor,012] := DTC->DTC_CODPRO
aLote[nCntFor,020] := M->DT6_QTDVOL
aLote[nCntFor,021] := M->DT6_VALMER
aLote[nCntFor,022] := M->DT6_PESO
aLote[nCntFor,023] := M->DT6_PESOM3
aLote[nCntFor,024] := M->DT6_BASSEG
aLote[nCntFor,025] := M->DT6_CDRORI
aLote[nCntFor,026] := M->DT6_CDRDES
aLote[nCntFor,027] := M->DT6_CDRCAL
aLote[nCntFor,028] := M->DT6_TIPFRE
aLote[nCntFor,029] := M->DT6_SERVIC
aLote[nCntFor,035] := 0						//-- LTPESCTR
aLote[nCntFor,036] := IIF(Len(aContrt) > 0, aContrt[ 1, 9 ], '')   //-- Condicao de Pagamento
aLote[nCntFor,044] := Space(Len(DTC->DTC_CDRPER))
aLote[nCntFor,054] := M->DT6_DEVFRE		//-- LTDEVFRE //alteracao do devedor durante a rotina TMSA500Mnt
aLote[nCntFor,055] := M->DT6_METRO3
aLote[nCntFor,056] := M->DT6_QTDUNI
aLote[nCntFor,058] := M->DT6_CLICON
aLote[nCntFor,059] := M->DT6_LOJCON
aLote[nCntFor,060] := M->DT6_CLIDPC
aLote[nCntFor,061] := M->DT6_LOJDPC
aLote[nCntFor,070] := Iif(nOpcx == 4,'1',cTipNFC) //-- Troca o tipo da nota para devolucao
aLote[nCntFor,085] := M->DT6_RECISS


//-- Se o numero do lote do documento original nao estiver cadastrado no DTP, um novo numero de lote sera gerado
If Empty(cLoteAut) 
	cLotNfc := TmsA500Lot(M->DT6_LOTNFC,,nOpcX)
Else
	cLotNfc := cLoteAut
EndIf
//-- Prepara vetor aDocto para geracao do documento
//-- Nao deve passar as notas fiscais do cliente
TmsA200Doc(aFrete, ,aTmsA500,cLotNfc,M->DT6_TABFRE,M->DT6_TIPTAB,M->DT6_SEQTAB,.F.,M->DT6_QTDVOL,M->DT6_VALMER,M->DT6_PESO,M->DT6_PESOM3,M->DT6_METRO3,M->DT6_BASSEG,M->DT6_QTDUNI,M->DT6_PESCOB,nCntFor)
//-- Gera documentos
TmsA200Grv(@aMsgErr,,@aNfs,lRefatur,,,,,,,,,,,nOpcx)
aAreaDT6 := DT6->(GetArea()) //-- EAlberti Carrega Posicionamento Do Novo Dovumento Gerado Para Retornar Ao Final

If (nOpcx == 4 .Or. nOpcx == 5)
	TMSA500NFC(M->DT6_FILDOC, M->DT6_DOC, M->DT6_SERIE, DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE )
EndIf

If !Empty(aMsgErr)
	TmsMsgErr(aMsgErr,,lTM500Auto)
	lMsErroAuto := .T.
Else
	//Observacao do Documento
	If !Empty(cObsDoc)
		MSMM(,,,cObsDoc,1,,,"DT6","DT6_CODOBS")
	EndIf

	If nOpcx == 5 //Reentrega 
		DT6->(DbSetOrder(1))
		If DT6->(DbSeek(xFilial('DT6') + M->DT6_FILDOC + M->DT6_DOC + M->DT6_SERIE))
			RecLock("DT6",.F.)
			DT6->DT6_REENTR := DT6->DT6_REENTR + 1
			MsUnLock()
		EndIf
	EndIf

	//Precisa zerar a observacao digitada por ser static
	_cObsComp := ''

	//Observacao do Complemento - Livros Fiscais
	If nOpcX == 6 .And. DT6->DT6_DOCTMS=='8'
		dbSelectArea("SF3")
		SF3->(DbSetOrder(4))
		If SF3->(DbSeek(xFilial("SF3")+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV+DT6->DT6_DOC+DT6->DT6_SERIE)) .And. (Substr(SF3->F3_CFO,1,1) >= "5")
			RecLock("SF3",.F.)
			SF3->F3_OBSERV:=AllTrim(SF3->F3_OBSERV)+"COMPL. DO CTRC:" + DT6->DT6_DOCDCO + "/" + DT6->DT6_SERDCO
			MsUnlock()
		EndIf
	EndIf

	//-- Obtem o tipo de veiculo
	nPosTipVei := Ascan( aHeaderDWT, { |x| AllTrim(x[2]) == 'DWT_TIPVEI' } )
	For nCntFor := 1 To Len(aColsDWT)
		If !aColsDWT[nCntFor][Len(aColsDWT[nCntFor])] .And. !Empty(aColsDWT[nCntFor][nPosTipVei])
			If DWT->(MsSeek(xFilial("DWT")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE+aColsDWT[nCntFor][nPosTipVei]))
				RecLock("DWT",.F.)
			Else
				RecLock("DWT",.T.)
			EndIf
			For nCnt1 := 1 To Len(aHeaderDWT)
				If aHeaderDWT[nCnt1,10] != 'V'
					DWT->(FieldPut(FieldPos(Trim(aHeaderDWT[nCnt1][2])),aColsDWT[nCntFor][nCnt1]))
				EndIf
			Next
			DWT->DWT_FILIAL := xFilial("DWT")
			DWT->DWT_FILDOC := DT6->DT6_FILDOC
			DWT->DWT_DOC    := DT6->DT6_DOC
			DWT->DWT_SERIE  := DT6->DT6_SERIE
			DWT->(MsUnLock())
		EndIf
	Next

	//-- Ponto de entrada após a gravação do documento no DT6
    If lTM500DOC
        ExecBlock('TM500DOC',.F.,.F.,{DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE})
    EndIf

	If DTP->DTP_TIPLOT == '3' .Or. DTP->DTP_TIPLOT == '4' //-- Eletronico

		TMS500Perg(.f.)
		If mv_par02 == 1 //-- Transmite Ct-e apos calculo

			TMSAE70(2,DTP->DTP_FILORI,DTP->DTP_LOTNFC,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)

			//-- Tratamento Apontamento Receitas/Despesa
    		If Tmsa152Use() .And. Type('lMsErroAuto') == 'L' .And. lMsErroAuto
    			lMsErroAuto := .f.
			EndIf	
		EndIf
	EndIf

EndIf
RestArea(aAreaDT6) 		//-- EAlberti -- Devolve Posicionamento Do Novo Documento Gerado
RestArea(aAreaSF3)

Return( aNfs )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Lib³ Autor ³ Alex Egydio           ³ Data ³24.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera liberacao de pedidos sem avaliar credito.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Numero do pedido                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Lib( cNumPed )

Local aAreaAnt	:= GetArea()
Local cSeek		:= ''

SC6->( DbSetOrder( 1 ) )
If	SC6->( MsSeek( cSeek := xFilial('SC6') + cNumPed, .F. ) )
	While SC6->( ! Eof() .And. SC6->C6_FILIAL + SC6->C6_NUM == cSeek )

		MaLibDoFat( SC6->( RecNo() ), 1, , , .F., .F., .F., .F. )

		SC6->( DbSkip() )
	EndDo
EndIf

RestArea( aAreaAnt )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Dsc³ Autor ³ Alex Egydio           ³ Data ³24.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Indica o valor de devolucao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao de manutencao                                ³±±
±±³          ³ ExpL1 - .T. indica que a digitacao do complemento / AWB    ³±±
±±³          ³             esta sendo digitado pela primeira vez          ³±±
±±³          ³ ExpC1 - Codigo do fornecedor                       ( AWB ) ³±±
±±³          ³ ExpC2 - Loja   do fornecedor                       ( AWB ) ³±±
±±³          ³ ExpC3 - Filial de destino da ultima regiao da rota ( AWB ) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Dsc(nOpcx, lPrimComp, cCodCia, cLojCia, cFilDes, lEdita, lFretInf, nVlrInf,nOpcAnt,lTela, cCodPro, cDocTms)
Local lRet		  := .T.
Local aBtn        := {}
Local cLbx        := ''
Local nCntFor     := 0
Local nOpcA       := 0
Local nSeek       := 0
Local nTotFre     := 0
Local lAWB        := (Type("M->DTV_CODCIA") == "C")
Local lEntOco     := IsInCallStack("TMSA360")
Local lRetPE      := .F.
Local lmvPar03		:= VldExistX1('TMA500'/*Grupo do pergunte*/,'03'/*Ordem Parametro*/)
Local cCliDev		:= DT6->DT6_CLIDEV
Local cLojDev		:= DT6->DT6_LOJDEV
Local cCliRem		:= DT6->DT6_CLIREM
Local cLojRem		:= DT6->DT6_LOJREM
Local cCliDes		:= DT6->DT6_CLIDES
Local cLojDes		:= DT6->DT6_LOJDES 
Local lRetEnd 		:= .F.
Local lExistPerf	:= DUO->(ColumnPos("DUO_TPCALC")) > 0                     
Local nPosDsc       := 0
Local aListHead     := {}
Local aCompTes      := {}  //--Guarda as TES por componentes de frete
Local aAreaDTC      := NIL
Local cTitCST       := FWX3TITULO('F4_SITTRIB') // Titulo do Codigo da Situacao tributária

Local lRecebedor    := DTC->(ColumnPos("DTC_CLIREC")) > 0
Local cTipNFC       := TMATIPNFC() //Posicione("DTC",1,xFilial("DTC")+DT6->(DT6_FILORI+DT6_LOTNFC),"DTC_TIPNFC")

Private aDesconto := {}
Private aFrtAux   := AClone( aFrete )
Private nDescon   := 0	//-- Percentual de desconto
Private nValDig   := 0
Private oDlgDsc
Private oLbxEsp
Private oValDco
Private oPerDco
Private oTotFre
Private lTabela   := .F.
Private cServic	  := M->DT6_SERVIC
Private lRetVld	  := .T.
//-- as variaveis ccodcia,clojcia e cfildes sao enviadas pela geracao de AWB
DEFAULT cCodCia   := ''
DEFAULT cLojCia   := ''
DEFAULT cFilDes   := ''
DEFAULT lEdita    := .T.
DEFAULT lFretInf  := .F.
DEFAULT nVlrInf   := 0
DEFAULT nOpcAnt   := 0
DEFAULT lTela     := .T.
DEFAULT cCodPro   := ""
DEFAULT cDocTms   := DT6->DT6_DOCTMS

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

If Type("cLoteAut") <> "C"
	cLoteAut := ""
Else
	If	cLoteAut == Nil .Or. ValType(cLoteAut) <> 'C'
		cLoteAut := ""
	EndIf
EndIf
If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

If	(lAWB .And. lPrimComp) .Or. lFretInf
	aFrtOri:=AClone( aFrete )
EndIf

//-- Formato do vetor aDesconto
//-- aDesconto[01] = Descricao do componente
//-- aDesconto[02] = Valor original do componente com imposto
//-- aDesconto[03] = Valor do complemento/reentrega
//-- aDesconto[04] = Valor do imposto
//-- aDesconto[05] = Valor + Imposto
//-- aDesconto[06] = Codigo do componente
For nCntFor := 1 To Len(aFrete)
	If nOpcX == 5 .Or. nOpcX == 11 			//-- Reentrega ou Armazenagem
		AAdd(aDesconto,{aFrete[nCntFor,1],aFrete[nCntFor,2],0,0,0,aFrete[nCntFor,3],,,0,0 })
	ElseIf nOpcX == 6  .Or. nOpcX == 10	  //-- Complemento
		//-- O Vetor afrtori contem a composicao original do documento
		nSeek := AScan(aFrtOri,{|x|x[3]==aFrete[nCntFor,3]})
		If	lPrimComp
			AAdd(aDesconto,{aFrete[nCntFor,1],Iif(nSeek>0,aFrtOri[nSeek,6],0),0,0,0,aFrete[nCntFor,3],,,0,0})
		Else
			AAdd(aDesconto,{aFrete[nCntFor,1],Iif(nSeek>0,aFrtOri[nSeek,6],0),aFrete[nCntFor,2],aFrete[nCntFor,5],aFrete[nCntFor,6],aFrete[nCntFor,3],,,0,0})
		EndIf
	ElseIf lFretInf
		If lEdita
			AAdd(aDesconto,{aFrete[nCntFor,1],aFrete[nCntFor,2],0,0,0,aFrete[nCntFor,3],,,aFrete[nCntFor,13],aFrete[nCntFor,14]})
		Else
			AAdd(aDesconto,{aFrete[nCntFor,1],aFrete[nCntFor,2],0,aFrete[nCntFor,5],aFrete[nCntFor,6],aFrete[nCntFor,3],,,aFrete[nCntFor,13],aFrete[nCntFor,14]})
		EndIf
	Else
		AAdd(aDesconto, {aFrete[nCntFor, 1], aFrete[nCntFor, 6], 0, 0, 0,aFrete[nCntFor,3],,,aFrete[nCntFor,13],aFrete[nCntFor,14]})
	EndIf
Next

If lTM500DES
	lRetPE := ExecBlock("TM500DES",.F.,.F.,{nOpcx})
	If ValType(lRetPE) # "L"
		lRetPE := .F.
	EndIf
EndIf 

If nOpcX == 4 //-- Devolucao
	If M->DT6_DOCTMS == StrZero( 6, Len( DT6->DT6_DOCTMS ) )	 //-- Devolucao
		cTipNFC := '1'
	EndIf
EndIf

If nOpcX == 4 //-- Devolucao
	If DT6->(ColumnPos('DT6_SQEDES')) > 0 .And. M->DT6_DESCAL == "4" .And. Empty(M->DT6_SQEDES) ;
	   .And. (!lRecebedor .Or. Empty(M->DT6_CLIREC))
		Help(" ",1,"TMSA500C7") //-- Quando campo Sel.Des.Cal for igual a opção 4 - Outros é obrigatório informar uma seq. de endereço para o destinatário ou recebedor.
		lRet := .F. 
	Else
		If lmvPar03
					
			aPerfil := TmsPerfil(cCliDev,cLojDev,,,cCliRem,cLojRem,cCliDes,cLojDes)
			
			TMS500Perg(.f.)
			If MV_PAR03 == 1 .AND. Len(aPerfil) > 0 .AND. lExistPerf .AND. aPerfil[54] != "" .AND. aPerfil[54] != NIL //geracao por NF
				lRetEnd := Tms500SLNF(nOpcX)					
			Endif
			
		EndIf	
		If !lPenArm .AND. !lRetEnd 	
			If lRetPE
				If lmvPar03
													
					aPerfil := TmsPerfil(cCliDev,cLojDev,,,cCliRem,cLojRem,cCliDes,cLojDes)
					
					TMS500Perg(.f.)
					If MV_PAR03 == 1 .AND. Len(aPerfil) > 0 .AND. lExistPerf .AND. aPerfil[54] != "" .AND. aPerfil[54] != NIL //geracao por NF
						lRetEnd := Tms500SLNF(nOpcX)					
					EndIf												
				EndIf		
				If Len(aFrete) != 0 .AND. !lRetEnd	
					TmsA500Frt(nOpcX)				
					lEdita := .F.				
				Endif
			ElseIf	!lRetEnd .AND. ; 
				(( lTM500Auto .And. Empty(Get500Aut("NVLRDOC")) .And. Empty(Get500Aut("NPERCDOC")) ) ;
				 .Or. ;
				 ( !lTM500Auto .And. Aviso(STR0108,STR0109 + cServic + ' - ' +Tabela('L4',cServic,.F.)+CHR(13)+CHR(10)+; //"ATENCAO"###Servico atual: 
				   CHR(13)+CHR(10)+ STR0110,{STR0111,STR0112}, 2, '' )==1)) //"O valor da devolucao sera ?"###"Calculado"###"Digitado"
				
				If Len(aFrete) != 0	
					TmsA500Frt(nOpcX)				
					lEdita := .F.				
				Endif
			EndIf
		Else
			If Len(aFrete) != 0 .AND. !lRetEnd
				TmsA500Frt(nOpcX)			
				lEdita := .F.
			Endif	
		EndIf
	EndIf 	
ElseIf nOpcX == 5					//-- Reentrega
	If Empty(cLoteAut)
	
		If DT6->(ColumnPos('DT6_REENTR'))>0 .AND. !lRetEnd
			If lmvPar03
								
				aPerfil := TmsPerfil(cCliDev,cLojDev,,,cCliRem,cLojRem,cCliDes,cLojDes)
				
				TMS500Perg(.f.)
				If MV_PAR03 == 1 .AND. Len(aPerfil) > 0 .AND. lExistPerf .AND. aPerfil[54] != "" .AND. aPerfil[54] != NIL //geracao por NF
					lRetEnd := Tms500SLNF(nOpcX)					
				EndIf												
			EndIf							
			If Len(aPerfil) > 0
				If (DT6->DT6_REENTR + 1) >= aPerfil[32] //-- Primeira tentativa de reentrega
					If lRetPE .AND. lRetVld .AND. !lRetEnd 
						cTipMan := "2"					
						TmsA500Frt(nOpcX)										
						lEdita := .F.				
					ElseIf	lRetVld .AND. !lRetEnd .AND. ;
					       ( ( lTM500Auto .And. Empty(Get500Aut("NVLRDOC")) .And. Empty(Get500Aut("NPERCDOC")) );
					         .Or. ( !lTM500Auto .And. Aviso(STR0067,STR0133,{STR0111,STR0112}, 2, '' )==1) ) //"O valor da reentrega sera ?"###"Calculado"###"Digitado"
						cTipMan := "2"
						TmsA500Frt(nOpcX)											
						lEdita := .F.
					Else
						cTipMan := "3"
					EndIf
				Else
					cTipMan := "3"
				EndIf
			Else
				Help( " ", 1, "TMSA50063",, , 5, 1 ) //-- O cliente não paga reentrega nesta tentativa. A quantidade de tentativas de reentrega será incrementada.
				RecLock("DT6",.F.)
				DT6->DT6_REENTR := DT6->DT6_REENTR + 1
				MsUnLock()
					Return( lRet )
			EndIf
		EndIf
	Else
		If !TmsA500Frt(nOpcX) .AND. !lRetEnd
			lRet := .F.
			//-- Retorna Teclas de Atalhos
			TmsKeyOn(aSetKey)
			Return( lRet )
		EndIf
	EndIf
ElseIf nOpcX == 6	 .Or. nOpcX == 10	//-- Complemento ou AWB
	//-- Obtem o total do frete
	nTotFre := aDesconto[Len(aDesconto), 2]
	If	!lAWB .And. nOpcX <> 10	
		AAdd(aBtn,{'PRECO',{||TmsA500Frt(nOpcX)}, STR0113 , STR0114 }) //'Atualiza a composicao de frete...'
	EndIf
ElseIf lFretInf
	If lEdita 
		nValDig:=nVlrInf		
	Else
		//-- Obtem o total do frete
		nTotFre := aDesconto[Len(aDesconto), 2]
		If IsInCallStack('A050FRTINF') .And. nVlrInf > 0
			nTotFre := nVlrInf
			nValDig := nVlrInf
			TmsA500Vld(nOpcx,.T., .T.)
		EndIf 
	EndIf
EndIf
If Empty(cLoteAut) .AND. !lRetEnd .AND. lRetVld .And. !lTM500Auto .And. lRet .And. lTela
	If nOpcx == 11 .And. Type("nDiaArm") == "N"
		nQtdDia := nDiaArm
	EndIf
	DEFINE MSDIALOG oDlgDsc TITLE cOpcao FROM 00,00 TO 350,769 PIXEL
		If nOpcx == 6 //-- Complemento
			@ 35, 05 SAY STR0029 SIZE 43, 10 OF oDlgDsc PIXEL COLOR CLR_BLUE //"Total do Frete :"
			@ 35, 48 MSGET oTotFre VAR nTotFre PICTURE PesqPict('DT6','DT6_VALMER') When .F. SIZE 60, 10 OF oDlgDsc PIXEL
		ElseIf nOpcx == 11 //-- Armazenagem
			@ 35, 05 SAY STR0134 SIZE 43, 10 OF oDlgDsc PIXEL //'Qtde Dias :'
			@ 35, 48 MSGET oQtdDia VAR nQtdDia  PICTURE PesqPict('DT6','DT6_QTDVOL')	VALID TmsA500Vld(nOpcx)	WHEN lEdita SIZE 45, 10 OF oDlgDsc PIXEL
		ElseIf lFretInf
			@ 35, 05 SAY STR0029 SIZE 43, 10 OF oDlgDsc PIXEL COLOR CLR_BLUE //"Total do Frete :"
			If lEdita
				@ 35, 48 MSGET oValDco VAR nValDig	PICTURE PesqPict('DT6','DT6_VALMER') VALID TmsA500Vld(nOpcx,.T.)	WHEN lEdita SIZE 60, 10 OF oDlgDsc PIXEL
			Else
				@ 35, 48 MSGET oTotFre VAR nTotFre  PICTURE PesqPict('DT6','DT6_VALMER') When .F. SIZE 45, 10 OF oDlgDsc PIXEL				
			EndIf
		Else
			@ 35, 05 SAY STR0030				SIZE 43, 10 OF oDlgDsc PIXEL //'Valor :'
			@ 35,120 SAY '% ' + cOpcao + ' :'	SIZE 43, 10 OF oDlgDsc PIXEL
			@ 35, 48 MSGET oValDco VAR nValDig	PICTURE PesqPict('DT6','DT6_VALMER')	VALID TmsA500Vld(nOpcx)	WHEN lEdita SIZE 60, 10 OF oDlgDsc PIXEL
			@ 35,170 MSGET oPerDco VAR nDescon	PICTURE PesqPict('DT6','DT6_PERDCO')	VALID TmsA500Vld(nOpcx)	WHEN lEdita SIZE 45, 10 OF oDlgDsc PIXEL
		EndIf
		If (nOpcAnt == 2 .Or. !lEdita) .And. nOpcX <> 4 .and. nOpcX <> 5
			// @ 50, 01 LISTBOX oLbxEsp VAR cLbx FIELDS HEADER STR0015,STR0016, STR0017, STR0018, STR0283, STR0070, STR0284 SIZE 385,124 ON DBLCLICK(aDesconto:=TMSA500ShowGet(nTotFre, oLbxEsp:nAT, nOpcX, cCodCia, cLojCia, cFilDes,lFretInf,lEdita),oLbxEsp:Refresh()) NOSCROLL OF oDlgDsc PIXEL //'Composicao'###'Valor'###'Imposto'###'Valor + Imposto'###'TES'###'DESCRICAO'###'CFOP'
			aListHead     := {STR0015,STR0016, STR0017, STR0018, STR0283, STR0070, STR0284,cTitCST,STR0070} //'Composicao'###'Valor'###'Imposto'###'Valor + Imposto'###'TES'###'DESCRICAO'###'CFOP'###'CST'
		Else
			// @ 50, 01 LISTBOX oLbxEsp VAR cLbx FIELDS HEADER STR0015,STR0016, Iif(lFretInf,STR0196,STR0031 + cOpcao), STR0017, STR0018, STR0283, STR0070, STR0284	SIZE 385,124 ON DBLCLICK(aDesconto:=TMSA500ShowGet(nTotFre, oLbxEsp:nAT, nOpcX, cCodCia, cLojCia, cFilDes,lFretInf,lEdita),oLbxEsp:Refresh()) NOSCROLL OF oDlgDsc PIXEL //'Composicao'###'Valor'###'Valor '###'Imposto'###'Valor + Imposto'###'TES'###'DESCRICAO'###'CFOP'
			//STR0196 -> Valor Digitado
			aListHead     := {STR0015,STR0016, Iif(lFretInf,STR0196,STR0031 + cOpcao), STR0017, STR0018, STR0283, STR0070, STR0284,cTitCST,STR0070} //'Composicao'###'Valor'###'Valor '###'Imposto'###'Valor + Imposto'###'TES'###'DESCRICAO'###'CFOP'######'CST'
		EndIf
		
		@ 50, 01 LISTBOX oLbxEsp VAR cLbx FIELDS HEADER "INIT" SIZE 385,124 ON DBLCLICK(aDesconto:=TMSA500ShowGet(nTotFre, oLbxEsp:nAT, nOpcX, cCodCia, cLojCia, cFilDes,lFretInf,lEdita),oLbxEsp:Refresh()) NOSCROLL OF oDlgDsc PIXEL
		oLbxEsp:aHeaders := aClone(aListHead)

		//-- Verifica se existe TES para algum componente do frete configurado
		If IsInCallStack("TMSA050") .Or. IsIncallStack("TMSA050MNT")
			aCompTes := A500TESCmp(M->DTC_DOCTMS,M->DTC_TIPFRE,M->DTC_CLIDEV,M->DTC_LOJDEV,M->DTC_CDRORI,M->DTC_CDRCAL,cCodPro,Iif(M->DTC_DEVFRE=="3",.T.,.F.),M->DTC_TIPNFC,aDesconto, M->DTC_CLIDES, M->DTC_LOJDES)
		Else
		    aAreaDTC := DTC->(GetArea())
			cCodPro  := Posicione("DTC",1,xFilial("DTC")+DT6->(DT6_FILORI+DT6_LOTNFC),"DTC_CODPRO")
			aCompTes :=  A500TESCmp(cDocTms,DT6->DT6_TIPFRE,DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,DT6->DT6_CDRORI,DT6->DT6_CDRCAL,cCodPro,Iif(DT6->DT6_DEVFRE=="3",.T.,.F.),cTipNFC,aDesconto,DT6->DT6_CLIDES, DT6->DT6_LOJDES)
			RestArea(aAreaDTC)
		EndIf

		oLbxEsp:SetArray( aDesconto )
		If (nOpcAnt == 2 .Or. !lEdita) .And. nOpcX <> 4 .and. nOpcX <> 5
			oLbxEsp:bLine	:= { || {	AllTrim(aDesconto[oLbxEsp:nAT,1]),;
									TransForm(aDesconto[oLbxEsp:nAT,2],PesqPict('DT6','DT6_VALMER')),;
									TransForm(aDesconto[oLbxEsp:nAT,4],PesqPict('DT6','DT6_VALMER')),;
									TransForm(aDesconto[oLbxEsp:nAT,5],PesqPict('DT6','DT6_VALMER')),;
									AllTrim(aCompTes[oLbxEsp:nAT,1]),;     //| Codigo da TES
									AllTrim(aCompTes[oLbxEsp:nAT,2]),;     //| Descricao da TES
									AllTrim(aCompTes[oLbxEsp:nAT,3]),;     //| Codigo do CFOP
									AllTrim(aCompTes[oLbxEsp:nAT,4]),;     //| Codigo da Situacao Tributaria
									AllTrim(aCompTes[oLbxEsp:nAt,5]) } }   //| Descricao do Situacao Tributaria
			ACTIVATE MSDIALOG oDlgDsc CENTERED ON INIT EnchoiceBar(oDlgDsc,{||T500ConfVl(@nOpca), oDlgDsc:End()},{||oDlgDsc:End()},,aBtn)
		Else
			If nOpcX == 6 .Or. nOpcX == 5 
				oLbxEsp:bLine	:= { || {	AllTrim(aDesconto[oLbxEsp:nAT,1]),;
									TransForm(aDesconto[oLbxEsp:nAT,2],PesqPict('DT6','DT6_VALMER')),;
									TransForm(aDesconto[oLbxEsp:nAT,3],PesqPict('DT6','DT6_VALMER')),;
									TransForm(aDesconto[oLbxEsp:nAT,4],PesqPict('DT6','DT6_VALMER')),;
									TransForm(aDesconto[oLbxEsp:nAT,5],PesqPict('DT6','DT6_VALMER')),;
									AllTrim(aCompTes[oLbxEsp:nAT,1]),;     //| Codigo da TES
									AllTrim(aCompTes[oLbxEsp:nAT,2]),;     //| Descricao da TES
									AllTrim(aCompTes[oLbxEsp:nAT,3]),;     //| Codigo do CFOP
									AllTrim(aCompTes[oLbxEsp:nAT,4]),;     //| Codigo da Situacao Tributaria
									AllTrim(aCompTes[oLbxEsp:nAt,5]) } }   //| Descricao do Situacao Tributaria
			Else
				oLbxEsp:bLine	:= { || {	AllTrim(aDesconto[oLbxEsp:nAT,1])						 ,; //| Descrição do Componente de Frete
									TransForm(aDesconto[oLbxEsp:nAT, 2],PesqPict('DT6','DT6_VALMER')),; //| Valor
									TransForm(aDesconto[oLbxEsp:nAT, 3],PesqPict('DT6','DT6_VALMER')),; //| Valor da calculado/digitado
									TransForm(aDesconto[oLbxEsp:nAT, 4],PesqPict('DT6','DT6_VALMER')),; //| Impostos
									TransForm(aDesconto[oLbxEsp:nAT, 5],PesqPict('DT6','DT6_VALMER')),; //| Valor + Imposto
									AllTrim(aCompTes[oLbxEsp:nAT,1])								 ,; //| Codigo da TES
									AllTrim(aCompTes[oLbxEsp:nAT,2])								 ,; //| Descricao da TES
									AllTrim(aCompTes[oLbxEsp:nAT,3]),;   							    //| Codigo do CFOP
									AllTrim(aCompTes[oLbxEsp:nAT,4]),; 							        //| Codigo da Situacao Tributaria
									AllTrim(aCompTes[oLbxEsp:nAt,5]),; 									//| Descricao do Situacao Tributaria
									TransForm(aDesconto[oLbxEsp:nAT, 8],PesqPict('DT6','DT6_VALMER')),; //| 
									TransForm(aDesconto[oLbxEsp:nAT, 9],PesqPict('DT4','DT4_DESC'  )),;
									TransForm(aDesconto[oLbxEsp:nAT,10],PesqPict('DT4','DT4_ACRESC')) } }

			EndIf
			ACTIVATE MSDIALOG oDlgDsc CENTERED ON INIT EnchoiceBar(oDlgDsc,{||T500ConfVl(@nOpca), oDlgDsc:End()},{||oDlgDsc:End()},,aBtn)
		EndIf
Else
	If lTM500Auto
		nOpca := 0
		//-- Complemento
		If nOpcx == 6 
			For nCntFor := 1 To Len(aAutoItens)
				If !Empty(Get500Aut("DT8_CODPAS",nCntFor)) .And. AllTrim(Get500Aut("DT8_CODPAS",nCntFor)) != "TF" .And. (nPosDsc := aScan(aDesconto,{|x| x[6] == Get500Aut("DT8_CODPAS",nCntFor) }) ) > 0
					aDesconto := TMSA500ShowGet(nTotFre, nPosDsc, nOpcX, cCodCia, cLojCia, cFilDes, lFretInf, lEdita, Get500Aut("DT8_VALTOT",nCntFor))
					nOpca := 1
				ElseIf !Empty(Get500Aut("DT8_CODPAS",nCntFor)) .And. AllTrim(Get500Aut("DT8_CODPAS",nCntFor)) != "TF"
					//-- A Mensagem será incluída manualmente no Log pois não pode-se tratar com  a MSGetDAuto e a validação é manual.
					AutoGrLog('[' + STR0248 +" " + StrZero(nCntFor,3) + ']' + STR0249 + Chr(13)+ Chr(10) +;
					          STR0250 + " " + Get500Aut("DT8_CODPAS",nCntFor) + ' ' + STR0251 ) //--"Item"##"=> Inválido:"##"O componente"##"não foi encontrado no documento original para ser complementado"
					nOpca := 0
					Exit
				EndIf
			Next nCntFor
		//-- Substituição ou Complemento de Impostos ou devolução ou reentrega
		ElseIf nOpcx == 13 .Or. nOpcx == 10 .Or. nOpcx == 4 .Or. nOpcx == 5 
			//-- Caso seja devolução ou Reentrega , pode ser calculada ou informada. Se informar percentual ou valor, considera informada
			If (nOpcx <> 4 .And. nOpcx <> 5 ) .Or. !Empty(Get500Aut("NVLRDOC")) .Or. !Empty(Get500Aut("NPERCDOC")) 
				nValDig := Iif( ValType(Get500Aut("NVLRDOC")) == "N",Get500Aut("NVLRDOC"),0)
				If !Empty(nValDig)  
					__ReadVar := "nValDig"
					nOpca := Iif( TmsA500Vld(nOpcx), 1, 0)
				Else
					nDescon := Iif( ValType(Get500Aut("NPERCDOC")) == "N",Get500Aut("NPERCDOC"),0)
					__ReadVar := "nDescon"
					nOpca := Iif( TmsA500Vld(nOpcx), 1, 0)
				EndIf
			//-- No caso da Devolução ou reentrega, caso seja calculada, valida se o 
			ElseIf (nOpcx == 4 .Or. nOpcx == 5) .And. Empty(Get500Aut("NVLRDOC")) .And. Empty(Get500Aut("NPERCDOC")) 
				nOpcA := Iif(!Empty(nValDig).Or.!Empty(nDescon),1,0)
			EndIf
		//-- Armazenagem
		ElseIf nOpcx == 11
			nQtdDia  =  Iif( ValType(Get500Aut("NDIASDOC")) == "N",Get500Aut("NDIASDOC"),0)
			If !Empty(nQtdDia)  
				__ReadVar := "nQtdDia"
				nOpca := Iif( TmsA500Vld(nOpcx), 1, 0)
			EndIf
		Else
			AutoGrLog(STR0252+' ['+cOpcao +']' ) //--"Opção não prevista para execução automática"
		EndIf
		If nOpca == 0
			AutoGrLog(STR0253+' ['+cOpcao+'] '+ STR0254 ) //--"Inconsistência nos itens"##"ou nenhum item preenchido"
			Help( " ", 1, "TMSA500D2")	//-- "Operação incompleta. " ## "A operação não foi bem-sucedida."
		EndIf
	Else
		nOpca := 1
	EndIf
EndIf

If	nOpca == 1 .AND. !lRetEnd
	If !lFretInf
		If nOpcx == 11
			If !lPenArm .And. !lEntOco
				If Type('oLbx') == 'O'
					//-- Apresenta a composicao do frete
					TmsViewFrt('9')
					oLbx:Refresh()
				EndIf
			Else
				lPenArm := .T.
				nQtdDia := nDiaArm
				If !TmsA500Vld(nOpcx)
					lRet := .F.
					Return( lRet )
				EndIf
			EndIf
		Else
			If Empty(cLoteAut)
				M->DT6_PERDCO := nDescon
			EndIf
			//-- Indica que o complemento ja foi efetuado
			If	aDesconto[Len(aDesconto),3]>0
				lPrimComp := .F.
			EndIf
		EndIf
	ElseIf lFretInf .And. !lTela
		__ReadVar := "nValDig"
		If !TmsA500Vld(nOpcx,lFretInf,,cCodPro)
			lRet := .F.
		EndIf
	EndIf
Else
	lRet := .F.
	If !lFretInf .AND. !lRetEnd
		M->DT6_PERDCO := nPerOri
	EndIf
	If Type('oLbx') == 'O' .AND. !lRetEnd
		aFrete := AClone(aFrtAux)
		TmsViewFrt('9')
		oLbx:Refresh()
	EndIf
EndIf
//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Vld³ Autor ³ Alex Egydio           ³ Data ³24.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacoes                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500Vld(nOpcx)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 -> Opcao                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Vld(nOpcx, lFretInf, lVisCot, cCodProd)
Local aAreaDT3   := DT3->(GetArea())
Local cCampo     := ReadVar()
Local nCntFor    := 0
Local nSeek      := 0
Local nTFrete    := 0
Local cSeqTab    := ""
Local cTipNFC    := "0"
Local nPesoCob   := 0
Local cCdrOri    := PadR(GetMV("MV_CDRORI"),6)
Local cSerArm    := SuperGetMv('MV_SERARM',,'')	//-- Qual servico para armazenagem ?
Local cCliGen    := SuperGetMV('MV_CLIGEN',,'')	//-- Cliente Generico
Local lUsaNfs    := SuperGetMv('MV_TMSUNFS',,.F.)	//-- Filial utiliza nota fiscal ?
Local cSeqIns    := ''
Local cCodPro    := Space(Len(SB1->B1_COD))
Local cCodCli    := ""
Local cLojCli    := ""
Local lMV_TMSFOB := SuperGetMv("MV_TMSFOB",.F.,.T.) //-- Define se o frete devera ser FOB para consignatario ou despachante
Local lAlianca   := TMSAlianca() //-- Indica se utiliza Alianca
Local lOk        := .T.
Local lRetPE     := .T.           
Local cRet       := ""   
Local cSeqRem    := Space(TamSx3("DT5_SQEREM")[1])
Local cSeqDes    := Space(TamSx3("DT5_SQEDES")[1])
Local lInvOri    := DTC->(ColumnPos("DTP_INVORI")) > 0
Local nPerMax    := Val( Transform( Replicate( '9', TamSx3("DT6_PERDCO")[1]), StrTran( X3Picture("DT6_PERDCO"), ",", "" ) ) )

Default lVisCot  := .F.
Default lFretInf := .F.
Default cCodProd := ""

If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

If cCampo == 'NVALDIG' .Or. cCampo == 'NDESCON' .Or. lVisCot
	If	lTabela
		Return( .T. )
	EndIf

	//-- Limpa vetores usados no listbox p/apresentar a composicao do frete
	aFrete    := {}
	aFrete    := AClone( aFrtAux )

	//-- Localiza o total do frete
	nSeek := Ascan(aFrete,{|x| x[3]=='TF' })
	If nSeek <= 0
		Return( .T. )
	EndIf

	//-- Identifica o total do frete
	nTFrete := aFrete[ nSeek, 6 ]
	//-- Valida digitacao do valor
	If cCampo == 'NDESCON'
		If nDescon < 0
			Help( ' ', 1, 'TMSA50013') //-- Percentual invalido.
			Return( .F. )
		EndIf
		//-- Calcula o percentual.
		nDescon := nDescon / 100
	Else
		//-- Calcula o percentual.
		nDescon := nValDig / nTFrete
	EndIf

	TmsA500Tot('2',,,nTFrete,nOpcx,,,,lFretInf,cCodProd)
	//-- Calcula impostos e obtem o valor do frete sem imposto
	TmsA500Tot('3',,,,nOpcx,,,,lFretInf,cCodProd)
	//-- Transfere os valores de aFrete para aDesconto
	TmsA500Tot('4',,,,nOpcx,,,,lFretInf,cCodProd)

	//-- Atualiza o get de percentual
	nDescon := nDescon * 100
	nDescon := round(nDescon,TamSX3("DT6_PERDCO")[2])

	If nDescon > nPerMax
		Help(" ",1,"TMSA500F6",,FWX3Titulo('DT6_PERDCO'),2,1) //"O Resultado ultrapassou o valor limite do campo:"
		Return( .F. )
	EndIf

	If !lFretInf .And. !lTM500Auto
		oPerDco:Refresh()       
	EndIf	
	
	If cCampo == 'NDESCON'
		nSeek	:= AScan(aFrete,{|x| x[3]=='TF' })
		If	nSeek > 0
			nValDig := aFrete[nSeek,6]
		EndIf
		If !lTM500Auto
			oValDco:Refresh()
		EndIf
	EndIf

	If	!lTM500Auto .And. ValType(oLbxEsp) == 'O'
		oLbxEsp:Refresh()
	EndIf
ElseIf cCampo == "M->DT6_DEVFRE"
	/* Se o devedor for 3=Consignatario verifica se o codigo do mesmo esta preenchido. */
	If &cCampo == StrZero(3, Len(DT6->DT6_TIPFRE)) .And. Empty(M->DT6_CLICON) .And. Empty(M->DT6_LOJCON)
		Help( " ", 1, 'TMSA50025') // "Consignatario nao esta preenchido."
		Return( .F. )
	EndIf

	/* Se o devedor for 4=Despachante verifica se o codigo do mesmo esta preenchido. */
	If &cCampo == StrZero(4, Len(DT6->DT6_TIPFRE)) .And. Empty(M->DT6_CLIDPC) .And. Empty(M->DT6_LOJDPC)
		Help( " ", 1, 'TMSA50026') // "Despachante nao esta preenchido."
		Return( .F. )
	EndIf
	/* Gatilha o tipo do frete. */
	If &cCampo == StrZero(1, Len(DT6->DT6_TIPFRE)) .Or. &cCampo == StrZero(2, Len(DT6->DT6_TIPFRE))
		/* Se o devedor for 1=Remetente o tipo do frete eh CIF, caso contrario FOB. */
		M->DT6_TIPFRE := Iif(&cCampo == StrZero(1, Len(DT6->DT6_TIPFRE)),;
		StrZero(1, Len(DT6->DT6_TIPFRE)), StrZero(2, Len(DT6->DT6_TIPFRE)))
	Else
		/* Se o devedor for 3=Consignatario ou 4=Despachante mantem o tipo do frete original. */
		DT6->(dbSetOrder(1))
		If DT6->(MsSeek(xFilial("DT6") + M->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))
			M->DT6_TIPFRE := DT6->DT6_TIPFRE
		EndIf
	EndIf

	If M->DT6_DEVFRE == '1'  //Remetente
		cCodCli := M->DT6_CLIREM
		cLojCli := M->DT6_LOJREM
	ElseIf M->DT6_DEVFRE == '2' //Destinatario
		cCodCli := M->DT6_CLIDES
		cLojCli := M->DT6_LOJDES
	ElseIf M->DT6_DEVFRE == '3' //Consignatario
		cCodCli := M->DT6_CLICON
		cLojCli := M->DT6_LOJCON
	ElseIf M->DT6_DEVFRE == '4' //Despachante
		cCodCli := M->DT6_CLIDPC
		cLojCli := M->DT6_LOJDPC
	ElseIf M->DT6_DEVFRE == '6' //Expedidor
		cCodCli := M->DT6_CLIEXP
		cLojCli := M->DT6_LOJEXP
	ElseIf M->DT6_DEVFRE == '7' //Recebedor
		cCodCli := M->DT6_CLIREC
		cLojCli := M->DT6_LOJREC
	EndIf

	If !Empty( cCodCli + cLojCli )
		SA1->(DbSetOrder(1))
		If SA1->( MsSeek( xFilial('SA1') + cCodCli + cLojCli) )
			M->DT6_CLIDEV  :=  SA1->A1_COD
			M->DT6_LOJDEV  :=  SA1->A1_LOJA
			
			If A500VldCli()
				M->DT6_NOMDEV  :=  SA1->A1_NOME
				If M->DT6_DEVFRE $ "1,2,3,4,6,7" .Or. lMV_TMSFOB
					M->DT6_TIPFRE := Iif(M->DT6_DEVFRE=='1','1','2')
				EndIf

				M->DT6_CDRCAL := TMSDestCal( M->DT6_CLIDEV, M->DT6_LOJDEV, M->DT6_CDRDES )
				If Empty(M->DT6_CDRCAL)
					M->DT6_CDRCAL := M->DT6_CDRDES
				EndIf
			Else
				M->DT6_CLIDEV  :=  DT6->DT6_CLIDEV
				M->DT6_LOJDEV  :=  DT6->DT6_LOJDEV 
			EndIf
		Else
			Help("",1,"TMSA50102") //-- Cliente Devedor nao encontrado ...
			Return ( .F. )
		EndIf
	Else
		Help("",1,"TMSA50102") //-- Cliente Devedor nao encontrado ...
		Return ( .F. )
	EndIf

	//-- Preenche os campos Cliente de Calculo e Loja do cliente de calculo.
	DC5->(dbSetOrder(1))
	DC5->(MsSeek(xFilial("DC5")+M->DT6_SERVIC))
	If DC5->DC5_SEGPER == '1' // Servico tem 2o. Percurso
		//--Para segundo percurso, o Cliente de Calculo sera' o Remetente.
		M->DT6_CLICAL := M->DT6_CLIREM
		M->DT6_LOJCAL := M->DT6_LOJREM
		M->DT6_NOMCAL := M->DT6_NOMREM
	Else
		//-- Analisa a tabela de consignatarios.
		cCodCli	 := ''
		cLojCli	 := ''
		aCliCalc := {}
		//-- Se for 2o. Percurso, nao verificar a tabela de consignatarios
		If !lAlianca
			aCliCalc := TmsCliCalc( M->DT6_CLIREM, M->DT6_LOJREM, M->DT6_CLIDES, M->DT6_LOJDES )
		EndIf

		If Empty( aCliCalc )
			cCodCli := M->DT6_CLIDEV
			cLojCli := M->DT6_LOJDEV
		Else
			cCodCli := aCliCalc[ 1 ]
			cLojCli := aCliCalc[ 2 ]
		EndIf

		//-- Quando o tipo do frete for FOB ( DT6_TIPFRE == 2 ) e o remetente for FOB dirigido ( DUO_FOBDIR == 1 ), a
		//-- tabela de frete do cliente remetente sera utilizada para o calculo.
		If	M->DT6_TIPFRE == StrZero( 2, Len( DT6->DT6_TIPFRE ) )
			aPerfil := TmsPerfil(M->DT6_CLIREM,M->DT6_LOJREM,.F.,.F.)

			If	Len(aPerfil) > 0 .And. aPerfil[4] == StrZero( 1, Len( DUO->DUO_FOBDIR ) )
				lOk		 := .T.
				aContrat := {}
				If lOk
					//-- Considera o cliente remetente somente se nao houver contrato para o cliente destinatario
					aContrat := TMSContrat(M->DT6_CLIDES,M->DT6_LOJDES,,M->DT6_SERVIC,.F.,M->DT6_TIPFRE, .F.,,,,,,,,,,,,,,,M->DT6_CODNEG)
				EndIf
				If	Empty(aContrat)
					cCodCli := M->DT6_CLIREM
					cLojCli := M->DT6_LOJREM
				EndIf
			EndIf
		EndIf

		//-- Verifica a Abragencia do Contrato quando nao e cliente generico
		If !Empty(M->DT6_TIPFRE) .And. !Empty(M->DT6_SERVIC)
			aContrat := TMSContrat(cCodCli,cLojCli,,M->DT6_SERVIC,.F.,M->DT6_TIPFRE, .F.,,,,,,,,,,,,,,,M->DT6_CODNEG)

			If	!Empty( aContrat ) .And. !aContrat[ 1,17 ] 
				If Posicione("AAM",1,xFilial("AAM")+aContrat[ 1, 1 ],"AAM_ABRANG") == "2"
					cLojCli:=AAM->AAM_LOJA
				EndIf
			EndIf
		EndIf

		SA1->( DbSetOrder( 1 ) )
		If	Empty( cCodCli + cLojCli ) .Or. SA1->( ! MsSeek( xFilial('SA1') + cCodCli + cLojCli, .F. ) )
			Help('',1,'TMSA50103')	//-- Cliente para calculo nao encontrado.
			Return ( .F. )
		Else
			M->DT6_CLICAL := SA1->A1_COD
			M->DT6_LOJCAL := SA1->A1_LOJA
			M->DT6_NOMCAL := SA1->A1_NOME
		EndIf
	EndIf


//-- Permite informar o documento de transporte na reentrega
ElseIf cCampo == 'M->DT6_DOCTMS'
	If !( M->DT6_DOCTMS $ '7;5' )
		Help( " ", 1, 'TMSA50046' ) //-- O Documento de Transporte para o conhecimento de reentrega devera ser 7-Ctrc Reentrega ou 5-Nota Fiscal.
		Return( .F. )
	EndIf
	cDocTms := M->DT6_DOCTMS
	M->DT6_STATUS := ""
	If cDocTms <> StrZero(5,Len(DT6->DT6_DOCTMS))
		M->DT6_STATUS := StrZero(7,Len(DT6->DT6_STATUS))
	EndIf

//-- DVS - Digitacao valor informado x documento de complemento
ElseIf cCampo == 'M->DVS_CODPAS'
	aAreaDT3:=DT3->(GetArea())
	DT3->(DbSetOrder(1))
	If	DT3->(MsSeek(xFilial('DT3')+M->DVS_CODPAS))
		If	DT3->DT3_TIPFAI != StrZero(7,Len(DT3->DT3_TIPFAI))
			Help('',1,'TMSA04045')		//-- O campo 'Calcula Sobre' deste componente esta diferente de 'Valor Informado'
			RestArea(aAreaDT3)
			Return( .F. )
		EndIf
	Else
		Help('',1,'REGNOIS') //Nao existe registro relacionado a este codigo"
		RestArea(aAreaDT3)
		Return( .F. )
	EndIf
	RestArea(aAreaDT3)
ElseIf cCampo == 'M->DT6_SERVIC'
	If	! TmsA500DC5(M->DT6_SERVIC)
		Return( .F. )
	EndIf
	M->DT6_DESSER := Tabela('L4',M->DT6_SERVIC,.F.)

	DUX->(DbSetOrder(2))
	If	DUX->(MsSeek(xFilial('DUX') + M->DT6_NCONTR + M->DT6_SERVIC))	
		M->DT6_TABFRE := DUX->DUX_TABFRE
		M->DT6_TIPTAB := DUX->DUX_TIPTAB
		aFrete := {}
		TmsA500Cmp(M->DT6_TABFRE,M->DT6_TIPTAB)
		If Type('oLbx') == 'O'
			//-- Apresenta a composicao do frete
			TmsViewFrt('9')
			oLbx:Refresh()
		EndIf
	EndIf

ElseIf cCampo == 'M->DT6_LOJDES'
	SA1->(DbSetOrder(1))
	If	SA1->(MsSeek(xFilial('SA1') + M->DT6_CLIDES + M->DT6_LOJDES))
		M->DT6_NOMDES := SA1->A1_NOME
	Else
		Help("",1,"REGNOIS") //Nao existe registro relacionado a este codigo"
		Return( .F. )
	EndIf
ElseIf cCampo == 'NQTDDIA' .Or. lPenArm
	If Len(aPerfil) > 0 .And. nQtdDia < aPerfil[39]
		Help(" ",1,'TMSA50082') //-- "Quantidade de dias no armazem inferior ao perfil do cliente."
		Return( .F. )
	EndIf
	cLojGen := Right(cCliGen,Len(DT6->DT6_LOJDEV))
	cCliGen := Left(cCliGen,Len(DT6->DT6_CLIDEV))
	aContrt := TMSContrat(DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,,cSerArm,.F.,DT6->DT6_TIPFRE,,,DT6->DT6_CLIREM,DT6->DT6_LOJREM,DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,,,,,,,,,,DT6->DT6_CODNEG)
	If Len(aContrt) == 0
		aContrt := TMSContrat(cCliGen,cLojGen,,cSerArm,.F.,DT6->DT6_TIPFRE,,,,,,,,,,,,,,,,DT6->DT6_CODNEG)
	EndIf
	aFrete := {}
	If Len(aContrt) <> 0
		If lUsaNfs .And. cCdrOri == DTC->DTC_CDRDES
			cDocTms := "F"
		Else
			cDocTms := "E"
		EndIf
		TmsA500TOk(.F.,8,"",cSerArm)
		aFrete := TMSCalFret(aContrt[1,3],aContrt[1,4],@cSeqTab,cCdrOri,cCdrOri,DT6->DT6_CLICAL,DT6->DT6_LOJCAL,DTC->DTC_CODPRO,cSerArm,;
					DT6->DT6_SERTMS,DT6->DT6_TIPTRA,,@aMsgErr,{},DT6->DT6_VALMER,DT6->DT6_PESO,DT6->DT6_PESOM3,@nPesoCob,DT6->DT6_QTDVOL,;
					0,0,0,0,0,0,0,,aContrt[1,17],aContrt[1,18]==StrZero(1,Len(DUO->DUO_AJUOBR)),0,0,0,0,0,{},Nil,,,,,,,nQtdDia,;
					,,,,,,,,,,,,,,,,,,,,DT6->DT6_CODNEG,,,,,(lInvOri .And. DTC->DTC_INVORI == '1'))
					 
		M->DT6_TABFRE := aContrt[1,3]
		M->DT6_TIPTAB := aContrt[1,4]
		M->DT6_SEQTAB := cSeqTab

		//-- Compatibiliza os vetores aFrete e aDesconto
		TmsA500Tot('5')
	EndIf
	//-- Localiza o total do frete e verifica os limites do perfil
	nSeek := Ascan(aFrete,{|x| x[3]=='TF' })
	If nSeek <= 0
		AAdd(aMsgErr,{STR0138,'00',''}) //"Valor do frete para documento de armazenagem está zerado"
		Return( .F. )
	EndIf
	If aFrete[nSeek,2] < aPerfil[41]
		nDifer  := (aPerfil[41] - aFrete[nSeek,2])
		If nDifer <> 0
			aFrete[nSeek,2] := (aFrete[nSeek,2] + nDifer)
			For nCntFor := 1 To Len(aFrete)
				If nCntFor <> nSeek
					aFrete[nCntFor,2] := (aFrete[nCntFor,2] + nDifer)
					Exit
				EndIf
			Next nCntFor
		EndIf
	ElseIf aFrete[nSeek,2] > aPerfil[42] .And. aPerfil[42] > 0
		nDifer  := (aFrete[nSeek,2] - aPerfil[42])
		If nDifer <> 0
			aFrete[nSeek,2] := (aFrete[nSeek,2] - nDifer)
			For nCntFor := 1 To Len(aFrete)
				If nCntFor <> nSeek
					If aFrete[nCntFor,2] >= nDifer
						aFrete[nCntFor,2] := (aFrete[nCntFor,2] - nDifer)
						nDifer := 0
						Exit
					Else
						nDifer := (nDifer - aFrete[nCntFor,2])
						aFrete[nCntFor,2] := 0
					EndIf
				EndIf
			Next nCntFor
		EndIf
	EndIf
		//-- Calcula impostos e obtem o valor do frete sem imposto
	cTipNFC := Posicione('DTC',3,xFilial('DTC')+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE,'DTC_TIPNFC')
	cCodPro := DTC->DTC_CODPRO
	If M->DT6_DOCTMS == StrZero( 6, Len( DT6->DT6_DOCTMS ) )	 //-- Devolucao
		cTipNFC := '1'
	EndIf
	cSeqIns := TMSSeqIns(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)

	TmsA040Imp(aFrete,DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,cDocTms,DT6->DT6_TIPFRE,cCdrOri,.T.,,,Posicione("SA1",1,xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES,"A1_TIPO"),,,,,DT6->DT6_CLIREM,DT6->DT6_LOJREM,DT6->DT6_CLIDES,DT6->DT6_LOJDES,,,cTipNFC,cCodPro,cSeqIns)
	//-- Transfere os valores de aFrete para aDesconto
	TmsA500Tot('4')
	If	ValType(oLbxEsp) == 'O'
		oLbxEsp:Refresh()
	EndIf
ElseIf cCampo == "M->DT6_CODNEG"
	If Empty(M->DT6_CODNEG)
		Help('',1,'TMSA500B9') //-- Não é permitido que o código da negociação fique em branco.
		lRet := .F.
	EndIf
ElseIf cCampo == "M->DT6_ORICAL"
	If M->DT6_ORICAL == '0'  .And. Empty(cCdrOriPE)
		M->DT6_CDRORI:= Space(Len(DT6->DT6_CDRORI))
		Help('',1,'TMSA500C5') //-- Opção inválida.
		Return .F.
	EndIf
	
	If M->DT6_DOCTMS == StrZero( 6, Len( DT6->DT6_DOCTMS ) ) .And. !Pertence('012')   //Devolução
		Return .F.
	EndIf
	
ElseIf cCampo == "M->DT6_DESCAL"
	If M->DT6_DOCTMS == StrZero( 6, Len( DT6->DT6_DOCTMS ) ) .And. !Pertence('01234')   //Devolução
		Return .F.
	EndIf
	
	If M->DT6_DESCAL == '3'  //Coleta
		cRet:= TMSA500SOL(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,@cSeqRem,@cSeqDes)

		If Empty(cRet)
			Help('',1,'TMSA500C4') //-- Região de Destino de Calculo inválido para este Documento de Transporte.
			Return .F.
		EndIf
	EndIf
	
	If M->DT6_DOCTMS == StrZero( 7, Len( DT6->DT6_DOCTMS ) ) .And. M->DT6_DESCAL != '4'
		Help('',1,'TMSA500C6') //-- Região de Destino de Calculo inválido para este Documento de Transporte. Para este tipo de documento utilize a opção 4-Outros
		Return .F. 	
	EndIf
	
	If M->DT6_DESCAL != '4' .And. !Empty(M->DT6_SQEDES)
		If M->DT6_DESCAL == "3"
			M->DT6_SQEDES := cSeqDes
		Else
			M->DT6_SQEDES := CriaVar("DT6_SQEDES")
		EndIf
	EndIf	
//-- Sequencia Destinatario
ElseIf cCampo $ "M->DT6_SQEDES"

	If !Empty(M->DT6_SQEDES)
		aArea := DUL->(GetArea())
		DUL->(DbSetOrder(2))
		If !DUL->(MsSeek(xFilial("DUL")+M->DT6_CLIDES+M->DT6_LOJDES+M->DT6_SQEDES))
			Help(" ",1,"TMSAF0504") //-- Sequencia de endereco nao encontrada para o Cliente.
			lRet := .F.
		Else
			M->DT6_CDRCAL := DUL->DUL_CDRDES
		EndIf
		RestArea( aArea )
	Else
		//-- Executa Gatilho do campo DTC_CLIDES (Destinatario)
		RunTrigger(1,Nil,Nil,,"DT6_CLIDES")
	EndIf
EndIf

//-- Usado para validar a digitacao dos campos do CTRC de devolucao.
If ExistBlock("TM500DEV")
	If Type("nDescon") == "U" 
		nDescon := 0
	EndIf	
	If Type("nValDig") == "U" 
		nValDig := 0
	EndIf
	lRetPE := ExecBlock("TM500DEV",.F.,.F.,{nDescon,nValDig,cCampo})
	If ValType(lRetPE) == "L" .And. !lRetPE
		Return ( .F. )
	EndIf
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Fin³ Autor ³Patricia A. Salomao    ³ Data ³16.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Visualiza todos os Titulos a Receber gerados pelo CTRC      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA500Fin()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500Fin()
Local aAreaAnt	:= GetArea()
Local aAreaSF2	:= SF2->(GetArea())
Local aAreaSA1	:= SA1->(GetArea())
Local aArraySE1	:= {}
Local cPrefixo	:= ''
Local cDoc		:= M->DT6_DOC
Local cFilSE1	:= Iif(Empty(FwFilial('SE1')), xFilial('SE1'), DT6->DT6_FILDOC)
Local cFilSF2	:= Iif(Empty(FwFilial('SF2')), xFilial('SF2'), DT6->DT6_FILDOC)
Local cCadOld	:= cCadastro
Local nOpca		:= 0
Local oDlg
Local oBtn03
Local lSe1Fat	:= AllTrim(GetMV("MV_TMSMFAT",,"")) == "1" //-- Modo de Faturamento:1-Faturamento a partir do SE1;2=Faturamento a partir do DT6
Local cQuery	:= ''
Local cAliasQry	:= GetNextAlias()
Local cAliasFat	:= GetNextAlias()
Local aPerfil	:= {}
Local cDocFat	:= ''
Local cTmsERP := SuperGetMV("MV_TMSERP",,'0') //-- Integracao com ERP
Local cFilDRT	:= Iif(Empty(FwFilial('DRT')), xFilial('DRT'), DT6->DT6_FILDOC)

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

If cTmsERP == '1' //-- ERP Datasul

	If ! Empty(M->DT6_NUM)
		cDoc := M->DT6_NUM //-- Numero da Fatura.
	EndIf

	DRT->(DbSetOrder(1))
	If DRT->(MsSeek(cFilDRT + cDoc))
		Tmsa851His()
	Else
		Help('',1,'TMSA50016') // Nao foi Encontrado nenhum Titulo a Receber gerado por este CTRC ...
	EndIf
Else
	If !Empty(M->DT6_NUM) .And. !Empty(M->DT6_PREFIX)
		cPrefixo := M->DT6_PREFIX //-- Prefixo da Fatura.
		cDoc     := M->DT6_NUM    //-- Numero da Fatura.
	Else
		SF2->(DbSetOrder(1))
		SF2->(MsSeek( cFilSF2 + DT6->DT6_DOC + DT6->DT6_SERIE ))
		cPrefixo := Padr( If(Empty(SF2->F2_PREFIXO),&(GETMV("MV_1DUPREF")),SF2->F2_PREFIXO),  Len( SE1->E1_PREFIXO ) )
	EndIf
	
	cQuery := " SELECT E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,E1_VALOR,E1_VENCTO, "
	cQuery += " E1_BAIXA,E1_FATPREF,E1_FATURA "
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += " WHERE E1_FILIAL = '" + cFilSe1 + "' "
	cQuery += " AND E1_NUM     = '" + cDoc + "' "
	cQuery += " AND E1_PREFIXO = '" + cPrefixo + "' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	TCSetField(cAliasQry,"E1_EMISSAO","D",8,0)
	TCSetField(cAliasQry,"E1_BAIXA","D",8,0)
	TCSetField(cAliasQry,"E1_VENCTO","D",8,0)
	Do While !(cAliasQry)->(Eof())
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona no Array os Dados do Titulo Gerado pelo CTRC             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aArraySE1,{(cAliasQry)->E1_PREFIXO,(cAliasQry)->E1_NUM,(cAliasQry)->E1_PARCELA,(cAliasQry)->E1_TIPO,DTOC((cAliasQry)->E1_EMISSAO),;
		   TRANSFORM((cAliasQry)->E1_VALOR, PesqPict("SE1","E1_VALOR")),DTOC((cAliasQry)->E1_VENCTO),DTOC((cAliasQry)->E1_BAIXA),;
		   (cAliasQry)->E1_CLIENTE,(cAliasQry)->E1_LOJA })
	
		If !lSE1Fat //-- MV_TMSMFAT igual a 2 (pelo DT6)
			//-- Obtem o perfil do cliente para verificar quais documentos possuem tratamento diferenciado no 
			//-- faturamento:
			aPerfil := TmsPerfil(M->DT6_CLICAL,M->DT6_LOJCAL,,,M->DT6_CLIREM,M->DT6_LOJREM,M->DT6_CLIDES,M->DT6_LOJDES)
			cDocFat := aPerfil[47]
			If AllTrim(cDocFat) == '*'
				lSE1Fat := .T.
			Else
				lSE1Fat := M->DT6_DOCTMS $ cDocFat
			EndIf
		EndIf
	
		If lSE1Fat .And. !Empty( (cAliasQry)->( E1_FATPREF + E1_FATURA ) )
			cQuery := " SELECT E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,E1_VALOR,E1_VENCTO, "
			cQuery += " E1_BAIXA,E1_FATPREF,E1_FATURA "
			cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
			cQuery += " WHERE E1_FILIAL = '" + cFilSe1 + "' "
			cQuery += " AND E1_NUM     = '" + (cAliasQry)->E1_FATURA  + "' "
			cQuery += " AND E1_PREFIXO = '" + (cAliasQry)->E1_FATPREF + "' "
			cQuery += " AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasFat, .F., .T.)
			TCSetField(cAliasFat,"E1_EMISSAO","D",8,0)
			TCSetField(cAliasFat,"E1_BAIXA","D",8,0)
			TCSetField(cAliasFat,"E1_VENCTO","D",8,0)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Adiciona no Array os Dados da Fatura Gerada para o Titulo         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While (cAliasFat)->( !Eof() )
				AAdd(aArraySE1,{(cAliasFat)->E1_PREFIXO,(cAliasFat)->E1_NUM,(cAliasFat)->E1_PARCELA,(cAliasFat)->E1_TIPO,DTOC((cAliasFat)->E1_EMISSAO),;
				TRANSFORM((cAliasFat)->E1_VALOR, PesqPict("SE1","E1_VALOR")),DTOC((cAliasFat)->E1_VENCTO),DTOC((cAliasFat)->E1_BAIXA),;
				(cAliasFat)->E1_CLIENTE,(cAliasFat)->E1_LOJA })
	
				(cAliasFat)->(dbSkip())
			EndDo
			(cAliasFat)->( dbCloseArea() )
	
		EndIf
	
		(cAliasQry)->(dbSkip())
	
	EndDo
	(cAliasQry)->( dbCloseArea() )
	If Len( aArraySE1 ) > 0
		nOpca := 0
		cCadastro := STR0033  //"Consulta de Titulos a Receber"
		DEFINE MSDIALOG oDlg TITLE cCadastro From 11,0 To 35,085 OF oMainWnd
			@ 0.6,.7  Say STR0034  //"Documento : "
			@ 0.4, 5  MSGet M->DT6_DOC When .F.
			@ 0.6, 15 Say STR0035  //"Serie : "
			@ 0.4, 17 MSGet M->DT6_SERIE When .F.
	
			@ 1.8,.7 LISTBOX oQual VAR cVar Fields HEADER STR0036, STR0037, STR0038,STR0115,STR0039,STR0016,; //"Prefixo"###"Numero"###"Parcela"###"Tipo"###"Emissao"###"Valor"
					 STR0116,STR0117 SIZE 275,152 ON DBLCLICK (nOpca := 1,oDlg:End()) //"Vencto."###"Baixa"
			oQual:SetArray(aArraySE1)
			oQual:bLine := { || aArraySE1[oQual:nAT] }
			DEFINE SBUTTON FROM 23  ,295  TYPE 1  ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM 36.5,295  TYPE 15 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON oBtn03 FROM 50 ,295 TYPE 5 ACTION TmsA500VTit(aArraySE1[oQual:nAT]) ENABLE OF oDlg
			oBtn03:cToolTip := STR0118 //'Titulos da Fatura'
	
		ACTIVATE MSDIALOG oDlg VALID (nOAT := oQual:nAT,.T.) CENTERED
	
		If nOpca == 2  // Visualiza os Dados do Titulo Posicionado
			TMSA500Det(aArraySE1[nOAT,1], aArraySE1[nOAT,2], aArraySE1[nOAT,3], cFilSE1, aArraySE1[nOAT,4],aArraySE1[nOAT,9],aArraySE1[nOAT,10] )
		EndIf
	
	Else
		Help('',1,'TMSA50016') // Nao foi Encontrado nenhum Titulo a Receber gerado por este CTRC ...
		//-- Retorna Teclas de Atalhos
		TmsKeyOn(aSetKey)
		Return( .F. )
	EndIf
EndIf

cCadastro := cCadOld
RestArea(aAreaSA1)
RestArea(aAreaSF2)
RestArea(aAreaAnt)

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Det³ Autor ³Patricia A. Salomao    ³ Data ³16.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Exibe todos os Dados do Titulo Posicionado                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA500Det()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Prefixo do Titulo                                  ³±±
±±³          ³ ExpC2 - Numero  do Titulo                                  ³±±
±±³          ³ ExpC3 - Parcela do Titulo                                  ³±±
±±³          ³ ExpC4 - Filial do documento                                ³±±
±±³          ³ ExpC5 - Tipo do Titulo                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA500Det(cPrefixo, cNum, cParcela, cFilDoc,cTipo,cCliDev,cLojDev)

Local aArea      := GetArea()
Default cPrefixo := ''
Default cParcela := ''
Default cTipo    := ''

SE1->(dbSetOrder(2))
If SE1->(MsSeek(cFilDoc+cCliDev+cLojDev+cPrefixo+cNum+cParcela+cTipo))
	FA280Visua("SE1",SE1->(Recno()),2)
EndIf

RestArea(aArea)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Sho³ Autor ³ Robson Alves          ³ Data ³04.10.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe get para digitacao do valor do complemento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Total do frete original                            ³±±
±±³          ³ ExpN2 = Item do complemento                                ³±±
±±³          ³ ExpN3 = Opcao de manutencao                                ³±±
±±³          ³ ExpC1 - Codigo do fornecedor                       ( AWB ) ³±±
±±³          ³ ExpC2 - Loja   do fornecedor                       ( AWB ) ³±±
±±³          ³ ExpC3 - Filial de destino da ultima regiao da rota ( AWB ) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA500ShowGet(nTotFre, nItem, nOpcX, cCodCia, cLojCia, cFilDes, lFretInf, lEdita, nValor)

Local cSay		:= ''
//--Local nValor	:= 0 //-- Remover
Local nOpcA		:= 0
Local oDlgGet
Local oPanel
Local oValor      
Local lTM500CP1	:= ExistBlock('TM500CP1')
Local xPEValor	:= Nil                                               
Local cTitle    := Iif(lFretInf,STR0195,STR0040) //STR0195 ->Informe o valor digitado para:
Local nSeekDesc := 0
Local nTFrete   := 0
Local lFechado  := GetMv("MV_COTVFEC",,.F.)  //-- Permite a digitacao de Valor Fechado por componente
               
//--- Utilizado pela rotina Frete Informado do TMSA050
Default lFretInf:= .F.                                                                          
Default lEdita  := .F.                               
//-- Utilizado pela chamada MSExecAuto do TMSA500
Default nValor	:= 0

If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

//-- Nao exibe o Get para o ultimo elemento do array que refere-se ao total do frete
If nItem == Len(aDesconto) .Or. (nOpcX != 6 .And. nOpcX != 13 .And. !lFretInf)  .Or. (lFretInf .And. !lEdita)
	Return( aDesconto )
EndIf
If	!Empty(nItem) .And. nItem <= Len(aDesconto)
	cSay := AllTrim(aDesconto[nItem, 1]) + ": "
EndIf

//PE: Permite definir o valor do complemento, se result nao numerico(Nil) chama tela padrao 
If lTM500CP1 .And. !lFretInf
	xPEValor := ExecBlock('TM500CP1',.F.,.F.,{nItem})

	If ValType(xPEValor) == 'N'
		nValor 	:= xPEValor
		nOpca	:= 1
	EndIf
EndIf
                     

IF nOpca == 0
	If !lTM500Auto
		DEFINE MSDIALOG oDlgGet FROM 00,00 TO 100,290 PIXEL TITLE cTitle 
			oPanel := tPanel():New(03,03,"",oDlgGet,,,,,CLR_WHITE,140, 30, .T.)
		
			@ 013, 005 SAY cSay SIZE 100,009 OF oPanel PIXEL COLOR CLR_BLUE
			@ 013, 085 MSGET oValor VAR nValor PICTURE PesqPict("DT6", "DT6_VALMER") VALID TMSA500PER(nValor, nOpcx) SIZE 50, 010 OF oDlgGet PIXEL
		
			DEFINE SBUTTON FROM 37,115 TYPE 1 OF oDlgGet ENABLE ACTION (nOpcA := 1, oDlgGet:End())
		ACTIVATE MSDIALOG oDlgGet CENTERED
	Else 
		nOpca := 1
	EndIf
EndIf

nSeekDesc := Ascan(aFrete,{|x| x[3]=='TF' })
If nSeekDesc > 0
	nTFrete := aFrete[ nSeekDesc, 6 ]	
	nSeekDesc := 0	
EndIf

If nOpcA == 1	
	
	If lFechado
		TMSA500COTFEC(aFrete,nItem, nValor,aDesconto)		
	EndIf
	
	TmsA500Tot('1',nValor,nItem,,nOpcx,,,,lFretInf)
	//-- Calcula impostos e obtem o valor do frete sem imposto
	TmsA500Tot('3',,,,nOpcx,cCodCia,cLojCia,cFilDes,lFretInf)
	//-- Transfere os valores de aFrete para aDesconto
	TmsA500Tot('4',,,,nOpcx,,,,lFretInf)
EndIf

If (nOpcx == 13 .Or. nOpcx == 15) .And. nTFrete > 0
	nSeekDesc := Ascan(aDesconto,{|x| x[6]=='TF' })
	
	If nOpcx == 15
		nValDig := aDesconto[ nSeekDesc , 3 ]
	Else
		nValDig := aDesconto[ nSeekDesc , 5 ]
	EndIf
	nDescon := nValDig / nTFrete

	

	If	Type('oValDco') == 'O'
		oValDco:Refresh()
	EndIf
	If	Type('oPerDco') == 'O'
		oPerDco:Refresh()
	EndIf
EndIf
	
Return( aDesconto )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    TMSA500PER Autor ³ Felipe Barbiere         ³ Data ³09/08/2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Analisa o percentual digitado para não estourar o campo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA500PER(nValor, nOpcx)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA500PER(nValor, nOpcx)
Local lRet 	:= .T.
Local nPerMax   := Val( Transform( Replicate( '9', TamSx3("DT6_PERDCO")[1]), StrTran( X3Picture("DT6_PERDCO"), ",", "" ) ) )

Default nValor  := 0
Default nOpcx   := 0

If nValor > 0

	nSeekDesc := Ascan(aDesconto,{|x| x[6]=='TF' })
	If nSeekDesc > 0
		nTFrete := aDesconto[ nSeekDesc, 2 ]	
	EndIf
		
	If nOpcx == 15
		nValDig := aDesconto[ nSeekDesc , 3 ]
	Else
		nValDig := aDesconto[ nSeekDesc , 5 ]
	EndIf

	nDescon := nValor / nTFrete * 100

	If nDescon > nPerMax
		Help(" ",1,"TMSA500F6",,FWX3Titulo('DT6_PERDCO'),2,1) //"O Resultado ultrapassou o valor limite do campo:"
		lRet := .F.
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Tr1³ Autor ³ Henry Fila            ³ Data ³19.11.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tracking de operacoes                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA500Tr1()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa500Tr1()

Local aOpera     := {}
Local aArea      := GetArea()
Local aAreaDT6   := DT6->(GetArea())
Local aAreaDUD   := DUD->(GetArea())
Local aAreaDTW   := DTW->(GetArea())
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}
Local aHeadOp    := {}
Local oListBox
Local aSize      := MsAdvSize(.T.)
Local aButtons   := {{'PEDIDO'	,{|| Tmsa500VTr("DTW",aOpera[oListBox:nAt,Len(aOpera[1])-1]) } , STR0051, STR0100 } } //'Tracking de Ocorrencias' //"Visualiza Operacao"
Local cNomeFil   := ""
Local cSequen    := ""
Local cServico   := ""
Local cSeekDT5   := ""
Local nRecSM0    := SM0->(Recno())

Local oDlgViagem

Local cFilDT5    := xFilial("DT5")
Local cRota      := ""
Local aFilDca    := {}
Local nPosFilDes := 0
Local cAtivSai   := GetMV('MV_ATIVSAI',,'')
Local dDatPre    := Ctod("")
Local cHorPre    := ""
Local aOpeUsr    := {}
Local aPosici		:= {} 
Local cPosici		:= ""
Local cDatPos		:= ""
Local cHorPos		:= "" 
Local nTamAltu		:= 100

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca DUD pelo DT5                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DT5->(dbSetOrder(1))
DTC->(dbSetOrder(3))
DTC->(MsSeek(xFilial("DTC")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
While DTC->(!Eof()) .And. DTC->DTC_FILIAL == xFilial("DTC")  .And. ;
									DTC->DTC_FILDOC == DT6->DT6_FILDOC .And. ;
									DTC->DTC_DOC    == DT6->DT6_DOC    .And. ;
									DTC->DTC_SERIE  == DT6->DT6_SERIE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a solicitacao esta preenchida            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(DTC->DTC_NUMSOL)

		If !Empty(xFilial("DT5"))
			cFilDT5 := DTC->DTC_FILORI
		EndIf

		If !Empty(DTC->DTC_FILCFS)
			cFilDT5  := IIf(Empty(cFilDT5), cFilDT5, DTC->DTC_FILCFS)
			cSeekDT5 := cFilDT5+DTC->DTC_FILCFS+DTC->DTC_NUMSOL
		Else
			cSeekDT5 := cFilDT5+DTC->DTC_FILORI+DTC->DTC_NUMSOL
		EndIf

		If DT5->(MsSeek(cSeekDT5))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca DUD pelo DT5                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DUD->(dbSetOrder(1))
			DUD->(MsSeek(xFilial("DUD")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
			While DUD->(!Eof()) .And. DUD->DUD_FILIAL == xFilial("DT6")  .And.;
												DUD->DUD_FILDOC == DT5->DT5_FILDOC .And.;
												DUD->DUD_DOC    == DT5->DT5_DOC    .And.;
												DUD->DUD_SERIE  == DT5->DT5_SERIE

				If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) //-- Transporte
					cRota      := Posicione("DTQ",2,xFilial("DTQ")+DUD->DUD_FILORI+DUD->DUD_VIAGEM,"DTQ_ROTA")
					aFilDca    := TmsRegDCA(cRota)
					nPosFilDes := Ascan( aFilDca, { |x| x[3] == DUD->DUD_FILDCA } )
				EndIf

				//-- Caso a filial de descarga do documento nao seja a filial de destino, somente mostrar
				//-- o tracking ate a filial de descarga do documento
				DTW->(dbSetOrder(6))
				DTW->(dbSeek(xFilial("DTW")+DUD->DUD_FILORI+DUD->DUD_VIAGEM+DUD->DUD_FILDCA+"zz",.T.))
				DTW->(dbSkip(-1))
				If DTW->(!Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_FILATI) == DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_FILDCA)
					cSequen := DTW->DTW_SEQUEN
				Else
					cSequen := "zz"
				EndIf

				DTW->(dbSetOrder(1))
				DTW->(MsSeek(xFilial("DTW")+DUD->DUD_FILORI+DUD->DUD_VIAGEM))
				While DTW->(!Eof()) .And. DTW->DTW_FILIAL == xFilial("DTW") .And.;
													DTW->DTW_FILORI == DUD->DUD_FILORI .And.;
													DTW->DTW_VIAGEM == DUD->DUD_VIAGEM
					cNomeFil := ""

					If	DTW->DTW_STATUS != StrZero(9,Len(DTW->DTW_STATUS)) .And. DTW->DTW_SEQUEN <= cSequen

						//-- Verifica se a saida da viagem ocorreu na filial de destino.
						If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) .And. ; //-- Transporte
							DTW->DTW_ATIVID == cAtivSai .And. ; //-- Saida de Viagem
							nPosFilDes == Ascan( aFilDca, { |x| x[3] == DTW->DTW_FILATI } ) //-- Filial de Atividade
							DTW->(DbSkip())
							Loop
						EndIf

						If SM0->(MsSeek(SM0->M0_CODIGO+DTW->DTW_FILATI))
							cNomeFil := SM0->M0_FILIAL
						EndIf

						cServico := DTW->DTW_SERTMS+"-"+TmsValField("DTW->DTW_SERTMS",.F.)

						dDatPre := DTW->DTW_DATPRE
						cHorPre := DTW->DTW_HORPRE
						If !Empty(DTW->DTW_DATAJU) .And. !Empty(DTW->DTW_HORAJU)
							dDatPre := DTW->DTW_DATAJU
							cHorPre := DTW->DTW_HORAJU
						EndIf

						//--Array (aOpera) com os conteudos das tabelas a serem exibidos
						AAdd(aOpera, {dDatPre,;
								Transform(cHorPre,PesqPict('DTW','DTW_HORPRE')),;
								DTW->DTW_DATREA,;
								Transform(DTW->DTW_HORREA,PesqPict('DTW','DTW_HORREA')),;
								DTW->DTW_ATIVID+"-"+Tabela("L3",DTW->DTW_ATIVID,.F.),;
								DTW->DTW_FILATI+"-"+cNomeFil,;
								DTW->DTW_FILORI+" "+DTW->DTW_VIAGEM,;
								cServico })

						AAdd( aOpera[Len(aOpera)], DTW->DTW_DATAJU ) //--"Prev.Ajust."
						AAdd( aOpera[Len(aOpera)], Transform(DTW->DTW_HORAJU,PesqPict('DTW','DTW_HORAJU'))) //--"Hora Ajust."
						AAdd( aOpera[Len(aOpera)], DTW->DTW_OBSERV ) //--Observacao
					EndIf

					AAdd( aOpera[Len(aOpera)], DTW->(Recno()) ) //--Recno para visualizacao das operacoes
					AAdd( aOpera[Len(aOpera)], Iif(DTW->DTW_STATUS == StrZero(1,Len(DTW->DTW_STATUS)),'z','0') ) //--Status da Operacao, Operacoes em Aberto aparecem por ultimo na visualizacao

					SM0->(MsGoto(nRecSM0))

					DTW->(dbSkip())

				EndDo

				DUD->(dbSkip())

			EndDo

			Exit

		EndIf
	EndIf

	DTC->(dbSkip())

EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca DUD pelo DT6                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DUD->(dbSetOrder(1))
If DUD->(MsSeek(xFilial("DUD")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
	While DUD->(!Eof()) .And. DUD->DUD_FILIAL == xFilial("DT6") .And. ;
										DUD->DUD_FILDOC == DT6->DT6_FILDOC .And.;
										DUD->DUD_DOC    == DT6->DT6_DOC    .And.;
										DUD->DUD_SERIE  == DT6->DT6_SERIE

		If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) //-- Transporte
			cRota      := Posicione("DTQ",2,xFilial("DTQ")+DUD->DUD_FILORI+DUD->DUD_VIAGEM,"DTQ_ROTA")
			aFilDca    := TmsRegDCA(cRota)
			nPosFilDes := Ascan( aFilDca, { |x| x[3] == DUD->DUD_FILDCA } )
		EndIf

		DTW->(dbSetOrder(6))
		DTW->(dbSeek(xFilial("DTW")+DUD->DUD_FILORI+DUD->DUD_VIAGEM+DUD->DUD_FILDCA+"zz",.T.))
		DTW->(dbSkip(-1))
		If DTW->(!Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_FILATI) == DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_FILDCA)
			cSequen := DTW->DTW_SEQUEN
		Else
			cSequen := "zz"
		EndIf

		DTW->(dbSetOrder(1))
		If DTW->(MsSeek(xFilial("DTW")+DUD->DUD_FILORI+DUD->DUD_VIAGEM))
			While DTW->(!Eof()) .And. DTW->DTW_FILIAL == xFilial("DTW")  .And.;
												DTW->DTW_FILORI == DUD->DUD_FILORI .And.;
												DTW->DTW_VIAGEM == DUD->DUD_VIAGEM

				cNomeFil := ""

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o status esta encerrado                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If DTW->DTW_STATUS != StrZero(9,Len(DTW->DTW_STATUS)) .And. DTW->DTW_SEQUEN <= cSequen

					//-- Verifica se a saida da viagem ocorreu na filial de destino.
					If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) .And. ; //-- Transporte
						DTW->DTW_ATIVID == cAtivSai .And. ; //-- Saida de Viagem
						nPosFilDes == Ascan( aFilDca, { |x| x[3] == DTW->DTW_FILATI } ) //-- Filial de Atividade
						DTW->(DbSkip())
						Loop
					EndIf

					If SM0->(MsSeek(SM0->M0_CODIGO+DTW->DTW_FILATI))
						cNomeFil := SM0->M0_FILIAL
					EndIf

					cServico := DTW->DTW_SERTMS+"-"+TmsValField("DTW->DTW_SERTMS",.F.)

					dDatPre := DTW->DTW_DATPRE
					cHorPre := DTW->DTW_HORPRE
					If !Empty(DTW->DTW_DATAJU) .And. !Empty(DTW->DTW_HORAJU)
						dDatPre := DTW->DTW_DATAJU
						cHorPre := DTW->DTW_HORAJU
					EndIf

					//--Array (aOpera) com os conteudos das tabelas a serem exibidos
					AAdd(aOpera,{ dDatPre,;
							Transform(cHorPre,PesqPict('DTW','DTW_HORPRE')),;
							DTW->DTW_DATREA,;
							Transform(DTW->DTW_HORREA,PesqPict('DTW','DTW_HORREA')),;
							DTW->DTW_ATIVID+"-"+Tabela("L3",DTW->DTW_ATIVID,.F.),;
							DTW->DTW_FILATI+"-"+cNomeFil,;
							DTW->DTW_FILORI+" "+DTW->DTW_VIAGEM,;
							cServico })

					AAdd( aOpera[Len(aOpera)], DTW->DTW_DATAJU ) //--"Prev.Ajust."
					AAdd( aOpera[Len(aOpera)], Transform(DTW->DTW_HORAJU,PesqPict('DTW','DTW_HORAJU'))) //--"Hora Ajust."
					AAdd( aOpera[Len(aOpera)], DTW->DTW_OBSERV ) //--"Observacao"

					AAdd( aOpera[Len(aOpera)], DTW->(Recno()) ) //--Recno para visualizacao das operacoes
					AAdd( aOpera[Len(aOpera)], Iif(DTW->DTW_STATUS == StrZero(1,Len(DTW->DTW_STATUS)),'z','0') ) //--Status da Operacao, Operacoes em Aberto aparecem por ultimo na visualizacao

				EndIf

				SM0->(MsGoto(nRecSM0))

				DTW->(dbSkip())

			EndDo

		EndIf

		DUD->(dbSkip())

	EndDo
EndIf

//-- Retorna um array contendo a data, hora e ultimo posicionamento da ultima viagem
aPosici := TmsPosAtu( /*cCodVei*/ ,  DT6->DT6_FILVGA , DT6->DT6_NUMVGA, DT6->DT6_FILDOC  , DT6->DT6_DOC , DT6->DT6_SERIE  )	

cDatPos 	:= aPosici[1] //-- Data do ultimo posicionamento
cHorPos	:= aPosici[2] //-- Hora do ultimo posicionamento 
cPosici	:= aPosici[3] //-- Ultimo posicionamento	

CursorArrow()

//-- Ponto para Troca a descricao das atividades de operacao do tracking
If lTm500TR1
	aOpeUsr := ExecBlock("TM500TR1",.F.,.F.,{aOpera})
	If ValType(aOpeUsr) == 'A' .And. Len(aOpeUsr) > 0
		aOpera := AClone(aOpeUsr)
	EndIf
EndIf

If Len(aOpera) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Formato do vetor aOpera                                               ³
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³ aOpera[01] = Dt.Prevista                                              ³
	//³ aOpera[02] = Hr.Prevista                                              ³
	//³ aOpera[03] = Dt.Realizado                                             ³
	//³ aOpera[04] = Hr.Realizado                                             ³
	//³ aOpera[05] = Atividade + Descricao da atividade                       ³
	//³ aOpera[06] = Filial da Atividade + Nome da filial                     ³
	//³ aOpera[07] = Filial de Origem + Viagem                                ³
	//³ aOpera[08] = Servico                                                  ³
	//³ aOpera[09] = Data Ajuste                                              ³
	//³ aOpera[10] = Hora Ajuste                                              ³
	//³ aOpera[11] = Observacoes da Operacao                                  ³
	//³ aOpera[12] = Numero do registro(RECNO)                                ³
	//³ aOpera[13] = Utilizado para apresentar as operacoes em aberto no final³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aOpera   := aSort(aOpera,,,{|x,y| x[Len(aOpera[1])]+Dtos(x[3])+x[4]+Dtos(x[1])+x[2] < y[Len(aOpera[1])]+Dtos(y[3])+y[4]+Dtos(y[1])+y[2] })

	aObjects := {}  
	
	If !Empty(cPosici)
		nTamAltu := 85
	EndIf
	AAdd( aObjects, { 100, nTamAltu , .T., .T. , .T. } )
	AAdd( aObjects, { 100, 15 , .T., .T. , .T. } )

	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects , .T.  )

	//--Array(aHeadOp) contendo os campos a serem exibidos
	AAdd( aHeadOp, RetTitle("DTW_DATPRE") 	) //--Data Prevista
	AAdd( aHeadOp, RetTitle("DTW_HORPRE") 	) //--Hora Prevista
	AAdd( aHeadOp, RetTitle("DTW_DATREA") 	) //--Data Realizado
	AAdd( aHeadOp, RetTitle("DTW_HORREA") 	) //--Hora Realizado
	AAdd( aHeadOp, STR0043 + Space(20)		) //--Operacao
	AAdd( aHeadOp, STR0044                	) //--Filial - Descricao
	AAdd( aHeadOp, STR0045                	) //--Filial - Viagem
	AAdd( aHeadOp, STR0052                	) //--Servico Transporte
	AAdd( aHeadOp, RetTitle("DTW_DATAJU")	) //-- Data Previsao Ajuste
	AAdd( aHeadOp, RetTitle("DTW_HORAJU") 	) //-- Hora Previsao Ajuste
	AAdd( aHeadOp, RetTitle("DTW_OBSERV")	) //--Observacao

	DEFINE MSDIALOG oDlgViagem FROM aSize[7], 000 TO aSize[6],aSize[5]	 TITLE STR0042 OF oMainWnd PIXEL   //"Operacoes"

	oListBox := TWBrowse():New( aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], Nil, ;
                                 aHeadOp, Nil, oDlgViagem, Nil, Nil, Nil,,,,,,,,,, "ARRAY", .T. )

	oListBox:SetArray( aOpera )

	oListBox:bLine:= &('{ || Tm500BLin(oListBox:nAT,aOpera) }')

   If !Empty(cPosici) 
  		oPanel :=  TPanel():New( aPosObj[2,1], aPosObj[2,2],, oDlgViagem , Nil,.T.,,,,aPosObj[2,3], aPosObj[2,4],,)  
  		
  		tSay():New(003,005,{||STR0184} , oPanel,,,,,,.T.,,,100,9) //-- Ultimo posicionamento
		
		tSay():New(015,005,{||DAV->( RetTitle("DAV_DATPOS"))},oPanel,,,,,,.T.,,,50,9) //"Dt. Posici."
		tGet():New(013,055,{|u| cDatPos },oPanel,50,9,PesqPict("DAV","DAV_DATPOS"),,,,,,,.T.,,,,,,,.T.,,,'cDatPos')    
		
		tSay():New(030,005,{||DAV->( RetTitle("DAV_HORPOS"))},oPanel,,,,,,.T.,,,50,9) //"Hr. Posici."
		tGet():New(028,055,{|u| cHorPos },oPanel,30,9,PesqPict("DAV","DAV_HORPOS"),,,,,,,.T.,,,,,,,.T.,,,'cHorPos') 
		
		tSay():New(045,005,{||DAV->( RetTitle("DAV_POSICI"))},oPanel,,,,,,.T.,,,50,9) //"Localização"
		tGet():New(041,055,{|u| cPosici },oPanel,  aPosObj[2,3] - 55 ,9,"@!",,,,,,,.T.,,,,,,,.T.,,,'cPosici') 	
	EndIf

	ACTIVATE MSDIALOG  oDlgViagem ON INIT EnchoiceBar( oDlgViagem, { || nOpca := 1,oDlgViagem:End()}, {||oDlgViagem:End()},,aButtons)

EndIf

RestArea(aAreaDTW)
RestArea(aAreaDT6)
RestArea(aAreaDUD)
RestArea(aArea)

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Tr2³ Autor ³ Henry Fila            ³ Data ³19.11.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tracking de ocorrencias                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA500Tr2()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa500Tr2()

Local aOcor    := {}
Local aArea    := GetArea()
Local aAreaDT6 := DT6->(GetArea())
Local aAreaDUA := DUA->(GetArea())
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local aSize    := MsAdvSize(.T.)
Local aButtons := {{'PEDIDO'	,{|| Tmsa500VTr("DUA",aOcor[oOcor:nAt,8]) } , STR0053, STR0101 } } //'Tracking de Ocorrencias' //"Visualiza Ocorrencia"
Local cNomeFil := ""
Local cFilDT5  := xFilial("DT5")
Local nRecSM0  := SM0->(Recno())
Local cKeyDUA  := ""
Local oDlgOcor
Local oOcor
Local cRota      := ""
Local cSeekDT5   := ""
Local aFilDca    := {}
Local nPosFilDes := 0
Local lAllOcor   := .T.
Local aPosici		:= {}	
Local oPanel		:= Nil
Local nTamAltu		:= 100 
Local cDatPos		:= "" 
Local cHorPos		:= ""
Local cPosici		:= "" 

TMS500Perg(.f.)
lAllOcor:= Iif(mv_par01 == 1,.T.,.F.)

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca DUD pelo DT5                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DTC->(dbSetOrder(3))
If DTC->(MsSeek(xFilial("DTC")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
	While DTC->(!Eof()) .And. DTC->DTC_FILIAL == xFilial("DTC")  .And. ;
										DTC->DTC_FILDOC == DT6->DT6_FILDOC .And. ;
										DTC->DTC_DOC    == DT6->DT6_DOC    .And. ;
										DTC->DTC_SERIE  == DT6->DT6_SERIE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a solicitacao esta preenchida            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(DTC->DTC_NUMSOL)

			If !Empty(xFilial("DT5"))
				cFilDT5 := DTC->DTC_FILORI
			EndIf

			If !Empty(DTC->DTC_FILCFS)
				cFilDT5  := IIf(Empty(cFilDT5), cFilDT5, DTC->DTC_FILCFS)
				cSeekDT5 := cFilDT5+DTC->DTC_FILCFS+DTC->DTC_NUMSOL
			Else
				cSeekDT5 := cFilDT5+DTC->DTC_FILORI+DTC->DTC_NUMSOL
			EndIf

			DT5->(dbSetOrder(1))
			If DT5->(MsSeek(cSeekDT5))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busca DUD pelo DT5                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DUD->(dbSetOrder(1))
				If DUD->(MsSeek(xFilial("DUD")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
					While DUD->(!Eof()) .And. DUD->DUD_FILIAL == xFilial("DT6") .And. ;
														DUD->DUD_FILDOC == DT5->DT5_FILDOC .And.;
														DUD->DUD_DOC    == DT5->DT5_DOC    .And.;
														DUD->DUD_SERIE  == DT5->DT5_SERIE

						If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) //-- Transporte
							cRota      := Posicione("DTQ",2,xFilial("DTQ")+DUD->DUD_FILORI+DUD->DUD_VIAGEM,"DTQ_ROTA")
							aFilDca    := TmsRegDCA(cRota)
							nPosFilDes := Ascan( aFilDca, { |x| x[3] == DUD->DUD_FILDCA } )
						EndIf

						DUA->(dbSetOrder(4))
						If DUA->(MsSeek(xFilial("DUA")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE+DUD->DUD_FILORI+DUD->DUD_VIAGEM))
							While DUA->(!Eof()) .And. DUA->DUA_FILIAL == xFilial("DUA") .And.;
																DUA->DUA_FILDOC == DT6->DT6_FILDOC .And.;
																DUA->DUA_DOC    == DT6->DT6_DOC    .And.;
																DUA->DUA_SERIE  == DT6->DT6_SERIE  .And.;
																DUA->DUA_FILORI == DUD->DUD_FILORI .And.;
																DUA->DUA_VIAGEM == DUD->DUD_VIAGEM

								cNomeFil := ""

								//-- Verifica se a ocorrencia foi efetuada ate a filial destino do documento.
								If DUD->DUD_SERTMS <> StrZero(2,Len(DUD->DUD_SERTMS)) .Or. ; //-- Transporte
									nPosFilDes >= Ascan( aFilDca, { |x| x[3] == DUA->DUA_FILOCO } )

									If SM0->(MsSeek(SM0->M0_CODIGO+DUA->DUA_FILOCO))
										cNomeFil := SM0->M0_FILIAL
									EndIf

									If (Ascan(aOcor, {|x| x[4]+x[9]+x[3] == DUA->DUA_FILOCO+"-"+cNomeFil+DUA->DUA_NUMOCO+DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI")})== 0)		
										AAdd(aOcor,{DUA->DUA_DATOCO,;
													Transform(DUA->DUA_HOROCO,PesqPict('DUA','DUA_HOROCO')),;
													DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI"),;
													DUA->DUA_FILOCO+"-"+cNomeFil,;
													DUA->DUA_FILORI+" "+DUA->DUA_VIAGEM,;
													DUA->DUA_SERTMS+"-"+TmsValField("DUA->DUA_SERTMS",.F.),;
													"DUA",;
													DUA->(Recno()),;
													DUA->DUA_NUMOCO})
									EndIf

									SM0->(MsGoto(nRecSM0))
								EndIf
								DUA->(dbSkip())

							EndDo

						EndIf

						If Empty(DUD->DUD_FILORI) .Or. Empty(DUD->DUD_VIAGEM)
							cKeyDUA := xFilial("DUA")+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE+Space(Len(DUD_FILORI))+Space(Len(DUD_VIAGEM)))
						Else
							cKeyDUA := xFilial("DUA")+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM)
						EndIf

						DUA->(dbSetOrder(4))
						If DUA->(MsSeek(cKeyDUA))
							While DUA->(!Eof()) .And. DUA->(DUA_FILIAL + DUA_FILDOC + DUA_DOC + DUA_SERIE + DUA_FILORI + DUA_VIAGEM) == cKeyDUA
								cNomeFil := ""

								//-- Verifica se a ocorrencia foi efetuada ate a filial destino do documento.
								If DUD->DUD_SERTMS <> StrZero(2,Len(DUD->DUD_SERTMS)) .Or. ; //-- Transporte
									nPosFilDes >= Ascan( aFilDca, { |x| x[3] == DUA->DUA_FILOCO } )

									If SM0->(MsSeek(SM0->M0_CODIGO+DUA->DUA_FILOCO))
										cNomeFil := SM0->M0_FILIAL
									EndIf

									If (Ascan(aOcor, {|x| x[4]+x[9]+x[3] == DUA->DUA_FILOCO+"-"+cNomeFil+DUA->DUA_NUMOCO+	DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI")})== 0)
										AAdd(aOcor,{DUA->DUA_DATOCO,;
														Transform(DUA->DUA_HOROCO,PesqPict('DUA','DUA_HOROCO')),;
														DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI"),;
														DUA->DUA_FILOCO+"-"+cNomeFil,;
														DUA->DUA_FILORI+" "+DUA->DUA_VIAGEM,;
														DUA->DUA_SERTMS+"-"+TmsValField("DUA->DUA_SERTMS",.F.),;
														"DUA",;
														DUA->(Recno()),;
														DUA->DUA_NUMOCO})
									EndIf

									SM0->(MsGoto(nRecSM0))
								EndIf
								DUA->(dbSkip())

							EndDo

						EndIf

						DUD->(dbSkip())

					EndDo

				EndIf

			EndIf

			Exit

		EndIf

		DTC->(dbSkip())

	EndDo

EndIf

DUD->(dbSetOrder(1))
If DUD->(MsSeek(xFilial("DUD")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
	While DUD->(!Eof()) .And. DUD->DUD_FILIAL == xFilial("DT6") .And. ;
										DUD->DUD_FILDOC == DT6->DT6_FILDOC .And.;
										DUD->DUD_DOC    == DT6->DT6_DOC    .And.;
										DUD->DUD_SERIE  == DT6->DT6_SERIE

		If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) //-- Transporte
			cRota      := Posicione("DTQ",2,xFilial("DTQ")+DUD->DUD_FILORI+DUD->DUD_VIAGEM,"DTQ_ROTA")
			aFilDca    := TmsRegDCA(cRota)
			nPosFilDes := Ascan( aFilDca, { |x| x[3] == DUD->DUD_FILDCA } )
		EndIf

		DUA->(dbSetOrder(4))
		If DUA->(MsSeek(xFilial("DUA")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE+Space(Len(DUD->DUD_FILORI))+Space(Len(DUD->DUD_VIAGEM)) ))
			While DUA->(!Eof()) .And. DUA->DUA_FILIAL == xFilial("DUA")  							.And.;
												DUA->DUA_FILDOC == DT6->DT6_FILDOC 					.And.;
												DUA->DUA_DOC    == DT6->DT6_DOC   					.And.;
												DUA->DUA_SERIE  == DT6->DT6_SERIE  					.And.;
												DUA->DUA_FILORI == Space(Len(DUD->DUD_FILORI))		.And.;
												DUA->DUA_VIAGEM == Space(Len(DUD->DUD_VIAGEM))

				cNomeFil := ""

				//-- Verifica se a ocorrencia foi efetuada ate a filial destino do documento.
				If DUD->DUD_SERTMS <> StrZero(2,Len(DUD->DUD_SERTMS)) .Or. ; //-- Transporte
					nPosFilDes >= Ascan( aFilDca, { |x| x[3] == DUA->DUA_FILOCO } ) .Or. Empty(DUD->DUD_VIAGEM)

					If SM0->(MsSeek(SM0->M0_CODIGO+DUA->DUA_FILOCO))
						cNomeFil := SM0->M0_FILIAL
					EndIf

					If (Ascan(aOcor, {|x| x[4]+x[9]+x[3] == DUA->DUA_FILOCO+"-"+cNomeFil+DUA->DUA_NUMOCO+DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI")})== 0)
						AAdd(aOcor,{DUA->DUA_DATOCO,;
										Transform(DUA->DUA_HOROCO,PesqPict('DUA','DUA_HOROCO')),;
										DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI"),;
										DUA->DUA_FILOCO+"-"+cNomeFil,;
										DUA->DUA_FILORI+" "+DUA->DUA_VIAGEM,;
										DUA->DUA_SERTMS+"-"+TmsValField("DUA->DUA_SERTMS",.F.),;
										"DUA",;
										DUA->(Recno()),;
										DUA->DUA_NUMOCO})
					EndIf

					SM0->(MsGoto(nRecSM0))
				EndIf
				DUA->(dbSkip())

			EndDo
		EndIf
		If !Empty( DUD->DUD_VIAGEM )
			DUA->(dbSetOrder(4))
			If DUA->(MsSeek(xFilial("DUA")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE+DUD->DUD_FILORI+DUD->DUD_VIAGEM))
				While DUA->(!Eof()) .And. DUA->DUA_FILIAL == xFilial("DUA")  .And.;
													DUA->DUA_FILDOC == DT6->DT6_FILDOC .And.;
													DUA->DUA_DOC    == DT6->DT6_DOC    .And.;
													DUA->DUA_SERIE  == DT6->DT6_SERIE  .And.;
													DUA->DUA_FILORI == DUD->DUD_FILORI .And.;
													DUA->DUA_VIAGEM == DUD->DUD_VIAGEM

					cNomeFil := ""

					//-- Verifica se a ocorrencia foi efetuada ate a filial destino do documento.
					If DUD->DUD_SERTMS <> StrZero(2,Len(DUD->DUD_SERTMS)) .Or. ; //-- Transporte
						nPosFilDes >= Ascan( aFilDca, { |x| x[3] == DUA->DUA_FILOCO } )

						If SM0->(MsSeek(SM0->M0_CODIGO+DUA->DUA_FILOCO))
							cNomeFil := SM0->M0_FILIAL
						EndIf

						If (Ascan(aOcor, {|x| x[4]+x[9]+x[3] == DUA->DUA_FILOCO+"-"+cNomeFil+DUA->DUA_NUMOCO+DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI")})== 0)
							AAdd(aOcor,{DUA->DUA_DATOCO,;
											Transform(DUA->DUA_HOROCO,PesqPict('DUA','DUA_HOROCO')),;
											DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI"),;
											DUA->DUA_FILOCO+"-"+cNomeFil,;
											DUA->DUA_FILORI+" "+DUA->DUA_VIAGEM,;
											DUA->DUA_SERTMS+"-"+TmsValField("DUA->DUA_SERTMS",.F.),;
											"DUA",;
											DUA->(Recno()),;
											DUA->DUA_NUMOCO})
						EndIf

						SM0->(MsGoto(nRecSM0))
					EndIf
					DUA->(dbSkip())

				EndDo
			EndIf

			If lAllOcor
				cKeyDUA := xFilial("DUA")+Space(Len(DUA->DUA_FILDOC))+Space(Len(DUA->DUA_DOC))+Space(Len(DUA->DUA_SERIE))+DUD->DUD_FILORI+DUD->DUD_VIAGEM
				DUA->(dbSetOrder(4))
				If DUA->(MsSeek(cKeyDUA))
					While DUA->(!Eof()) .And. DUA->(DUA_FILIAL + DUA_FILDOC + DUA_DOC + DUA_SERIE + DUA_FILORI + DUA_VIAGEM) == cKeyDUA
						cNomeFil := ""

						//-- Verifica se a ocorrencia foi efetuada ate a filial destino do documento.
						If DUD->DUD_SERTMS <> StrZero(2,Len(DUD->DUD_SERTMS)) .Or. ; //-- Transporte
							nPosFilDes >= Ascan( aFilDca, { |x| x[3] == DUA->DUA_FILOCO } )
							If SM0->(MsSeek(SM0->M0_CODIGO+DUA->DUA_FILOCO))
								cNomeFil := SM0->M0_FILIAL
							EndIf

							If (Ascan(aOcor, {|x| x[4]+x[9]+x[3] == DUA->DUA_FILOCO+"-"+cNomeFil+DUA->DUA_NUMOCO+DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI")})== 0)
								AAdd(aOcor,{DUA->DUA_DATOCO,;
											Transform(DUA->DUA_HOROCO,PesqPict('DUA','DUA_HOROCO')),;
											DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI"),;
											DUA->DUA_FILOCO+"-"+cNomeFil,;
											DUA->DUA_FILORI+" "+DUA->DUA_VIAGEM,;
											DUA->DUA_SERTMS+"-"+TmsValField("DUA->DUA_SERTMS",.F.),;
											"DUA",;
											DUA->(Recno()),;
											DUA->DUA_NUMOCO})
							EndIf

							SM0->(MsGoto(nRecSM0))
						EndIf
						DUA->(dbSkip())

					EndDo
				EndIf
			EndIf
		EndIf

		DUD->(dbSkip())

	EndDo
EndIf

//-- Retorna um array contendo a data, hora e ultimo posicionamento da ultima viagem
aPosici := TmsPosAtu( /*cCodVei*/ ,  DT6->DT6_FILVGA , DT6->DT6_NUMVGA, DT6->DT6_FILDOC  , DT6->DT6_DOC , DT6->DT6_SERIE  )	

cDatPos 	:= aPosici[1] //-- Data do ultimo posicionamento
cHorPos	:= aPosici[2] //-- Hora do ultimo posicionamento 
cPosici	:= aPosici[3] //-- Ultimo posicionamento	
									
CursorArrow()

If Len(aOcor) > 0

	aOcor := aSort(aOcor,,,{|x,y| Dtos(x[1])+x[2] < Dtos(y[1])+y[2] })
   
	If !Empty(cPosici)
		nTamAltu := 85
	EndIf
	aObjects := {}
	AAdd( aObjects, { 100, nTamAltu , .T., .T. , .T. } )
	AAdd( aObjects, { 100, 15 , .T., .T. , .T. } )

	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 } 
	aPosObj := MsObjSize( aInfo, aObjects , .T. ) 

	DEFINE MSDIALOG oDlgOcor FROM aSize[7], 000 TO aSize[6],aSize[5] TITLE STR0046 OF oMainWnd PIXEL   //"Ocorrencias"

		@ aPosObj[1,1], aPosObj[1,2] LISTBOX oOcor VAR cVar Fields HEADER STR0047,;  //"Data"
																			STR0048,;  	//"Hora"
																			STR0043,; 	//"Operacao"
																			STR0044,;  	//"Filial"
																			STR0045,;  	//"Viagem"
																			STR0052 ;  	//"Viagem"	 //"Serv. Transporte"
																			SIZE  aPosObj[1,3], aPosObj[1,4] OF oDlgOcor PIXEL
		oOcor:SetArray(aOcor)
		oOcor:bLine:={ ||{aOcor[oOcor:nAT,1],;
									aOcor[oOcor:nAT,2],;
									aOcor[oOcor:nAT,3],;
									aOcor[oOcor:nAT,4],;
									aOcor[oOcor:nAT,5],;
									aOcor[oOcor:nAT,6]}}

		oOcor:Refresh()

	   If !Empty(cPosici) 
			oPanel :=  TPanel():New( aPosObj[2,1], aPosObj[2,2],, oDlgOcor , Nil,.T.,,,,aPosObj[2,3], aPosObj[2,4],,)  //-- Ultimo posicionamento
			
			tSay():New(003,005,{||STR0184} , oPanel,,,,,,.T.,,,100,9)
			
			tSay():New(015,005,{||DAV->( RetTitle("DAV_DATPOS"))},oPanel,,,,,,.T.,,,50,9) //"Dt. Posici."
			tGet():New(013,055,{|u| cDatPos },oPanel,50,9,PesqPict("DAV","DAV_DATPOS"),,,,,,,.T.,,,,,,,.T.,,,'cDatPos')    
			
			tSay():New(030,005,{||DAV->( RetTitle("DAV_HORPOS"))},oPanel,,,,,,.T.,,,50,9) //"Hr. Posici."
			tGet():New(028,055,{|u| cHorPos },oPanel,30,9,PesqPict("DAV","DAV_HORPOS"),,,,,,,.T.,,,,,,,.T.,,,'cHorPos') 
			
			tSay():New(045,005,{||DAV->( RetTitle("DAV_POSICI"))},oPanel,,,,,,.T.,,,50,9) //"Localização"
			tGet():New(041,055,{|u| cPosici },oPanel,  aPosObj[2,3] - 55 ,9,"@!",,,,,,,.T.,,,,,,,.T.,,,'cPosici') 	 
		EndIf


	ACTIVATE MSDIALOG  oDlgOcor ON INIT EnchoiceBar( oDlgOcor, { || nOpca := 1,oDlgOcor:End()}, {||oDlgOcor:End()},,aButtons)

EndIf

RestArea(aAreaDT6)
RestArea(aAreaDUA)
RestArea(aArea)

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Tr3³ Autor ³ Henry Fila            ³ Data ³19.11.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tracking de operacoes + ocorrencias                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA500Tr3()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - .F. Retornar array com o Tracking.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function Tmsa500Tr3(lArray)

Local aOcor      := {}
Local aArea      := GetArea()
Local aAreaDT6   := DT6->(GetArea())
Local aAreaDUA   := DUA->(GetArea())
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}
Local aSize      := MsAdvSize(.T.)
Local aButtons   := {{'PEDIDO',{|| Tmsa500VTr(aOcor[oOcor:nAt,7],aOcor[oOcor:nAt,8]) } , STR0053, STR0101 } } //'Tracking de Ocorrencias' //"Visualiza Ocorrencia"
Local cNomeFil   := ""
Local nRecSM0    := SM0->(Recno())
Local cKeyDUA    := ""
Local cFilDoc    := DT6->DT6_FILDOC
Local cDoc       := DT6->DT6_DOC
Local cSerie     := DT6->DT6_SERIE
Local lPriPer    := ( DT6->DT6_PRIPER == StrZero(1, Len(DT6->DT6_PRIPER)) )
Local oDlgOcor
Local oOcor
Local cFilDT5    := xFilial("DT5")
Local cRota      := ""
Local cSeekDT5   := ""
Local aFilDca    := {}
Local nPosFilDes := 0
Local cAtivSai   := GetMV('MV_ATIVSAI',,'')
Local aOcoUsr    := {}
Local xRet       := .T.
Local aPosici		:= {}	
Local oPanel		:= Nil
Local nTamAltu		:= 100 
Local cDatPos		:= ""
Local cHorPos		:= ""
Local cPosici		:= ""

DEFAULT lArray   := .F.

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o Documento for de 1o. Percurso                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPriPer
	DTC->(dbSetOrder(4)) // DTC_FILDOC+DTC_PRIPER+DTC_SERIE
Else
	DTC->(dbSetOrder(3)) // DTC_FILDOC+DTC_DOC+DTC_SERIE
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca DUD pelo DT5                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If DTC->(MsSeek(xFilial("DTC")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))

	cFilDoc := DTC->DTC_FILDOC
	cDoc    := DTC->DTC_DOC
	cSerie  := DTC->DTC_SERIE

	While DTC->(!Eof()) .And. DTC->DTC_FILIAL == xFilial("DTC") .And. ;
										DTC->DTC_FILDOC == DT6->DT6_FILDOC .And. ;
										Iif(lPriPer,DTC->DTC_DOCPER, DTC->DTC_DOC) == DT6->DT6_DOC  .And. ;
										DTC->DTC_SERIE == DT6->DT6_SERIE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a solicitacao esta preenchida            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(DTC->DTC_NUMSOL)

			If !Empty(xFilial("DT5"))
				cFilDT5 := DTC->DTC_FILORI
			EndIf

			If !Empty(DTC->DTC_FILCFS)
				cFilDT5  := IIf(Empty(cFilDT5), cFilDT5, DTC->DTC_FILCFS)
				cSeekDT5 := cFilDT5+DTC->DTC_FILCFS+DTC->DTC_NUMSOL
			Else
				cSeekDT5 := cFilDT5+DTC->DTC_FILORI+DTC->DTC_NUMSOL
			EndIf

			DT5->(dbSetOrder(1))
			If DT5->(MsSeek(cSeekDT5))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busca DUD pelo DT5                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DUD->(dbSetOrder(1))
				If DUD->(MsSeek(xFilial("DUD")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE))
					While DUD->(!Eof()) .And. DUD->DUD_FILIAL == xFilial("DT6") .And. ;
														DUD->DUD_FILDOC == DT5->DT5_FILDOC .And.;
														DUD->DUD_DOC    == DT5->DT5_DOC    .And.;
														DUD->DUD_SERIE  == DT5->DT5_SERIE

						If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) //-- Transporte
							cRota      := Posicione("DTQ",2,xFilial("DTQ")+DUD->DUD_FILORI+DUD->DUD_VIAGEM,"DTQ_ROTA")
							aFilDca    := TmsRegDCA(cRota)
							nPosFilDes := Ascan( aFilDca, { |x| x[3] == DUD->DUD_FILDCA } )
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Pesquisa com documento em branco, para verificar ocorrencias por viagem³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DUA->(dbSetOrder(4))
						If DUA->(MsSeek(xFilial("DUA")+DT5->DT5_FILDOC+DT5->DT5_DOC+DT5->DT5_SERIE+DUD->DUD_FILORI+DUD->DUD_VIAGEM))
							While DUA->(!Eof()) .And. DUA->DUA_FILIAL == xFilial("DUA") .And.;
																DUA->DUA_FILDOC == Space(Len(DT5->DT5_FILDOC)) .And.;
																DUA->DUA_DOC    == Space(Len(DT5->DT5_DOC))    .And.;
																DUA->DUA_SERIE  == Space(Len(DT5->DT5_SERIE))  .And.;
																DUA->DUA_FILORI == DUD->DUD_FILORI .And.;
																DUA->DUA_VIAGEM == DUD->DUD_VIAGEM

								cNomeFil := ""

								//-- Verifica se a ocorrencia foi efetuada ate a filial destino do documento.
								If DUD->DUD_SERTMS <> StrZero(2,Len(DUD->DUD_SERTMS)) .Or. ; //-- Transporte
									nPosFilDes >= Ascan( aFilDca, { |x| x[3] == DUA->DUA_FILOCO } )
									If SM0->(MsSeek(SM0->M0_CODIGO+DUA->DUA_FILOCO))
										cNomeFil := SM0->M0_FILIAL
									EndIf
									AAdd(aOcor,{DUA->DUA_DATOCO,;
													Transform(DUA->DUA_HOROCO,PesqPict('DUA','DUA_HOROCO')),;
													DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI"),;
													DUA->DUA_FILOCO+"-"+cNomeFil,;
													DUA->DUA_FILORI+" "+DUA->DUA_VIAGEM,;
													DUA->DUA_SERTMS+"-"+TmsValField("DUA->DUA_SERTMS",.F.),;
													"DUA",;
													DUA->(Recno()),;
													DUA->DUA_NUMOCO })
													
									SM0->(MsGoto(nRecSM0))
								EndIf
								DUA->(dbSkip())
							EndDo
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Pesquisa com campos de documento preenchidos³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty(DUD->DUD_FILORI) .Or. Empty(DUD->DUD_VIAGEM)
							cKeyDUA := xFilial("DUA")+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE+Space(Len(DUD_FILORI))+Space(Len(DUD_VIAGEM)))
						Else
							cKeyDUA := xFilial("DUA")+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM)
						EndIf

						DUA->(dbSetOrder(4))
						If DUA->(MsSeek(cKeyDUA))
							While DUA->(!Eof()) .And. DUA->(DUA_FILIAL + DUA_FILDOC + DUA_DOC + DUA_SERIE + DUA_FILORI + DUA_VIAGEM) == cKeyDUA
								cNomeFil := ""
								//-- Verifica se a ocorrencia foi efetuada ate a filial destino do documento.
								If DUD->DUD_SERTMS <> StrZero(2,Len(DUD->DUD_SERTMS)) .Or. ; //-- Transporte
									nPosFilDes >= Ascan( aFilDca, { |x| x[3] == DUA->DUA_FILOCO } )
									If SM0->(MsSeek(SM0->M0_CODIGO+DUA->DUA_FILOCO))
										cNomeFil := SM0->M0_FILIAL
									EndIf
									AAdd(aOcor,{DUA->DUA_DATOCO,;
													Transform(DUA->DUA_HOROCO,PesqPict('DUA','DUA_HOROCO')),;
													DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI"),;
													DUA->DUA_FILOCO+"-"+cNomeFil,;
													DUA->DUA_FILORI+" "+DUA->DUA_VIAGEM,;
													DUA->DUA_SERTMS+"-"+TmsValField("DUA->DUA_SERTMS",.F.),;
													"DUA",;
													DUA->(Recno()),;
													DUA->DUA_NUMOCO })
									SM0->(MsGoto(nRecSM0))
								EndIf
								DUA->(dbSkip())
							EndDo
						EndIf

						DTW->(dbSetOrder(6))
						DTW->(dbSeek(xFilial("DTW")+DUD->DUD_FILORI+DUD->DUD_VIAGEM+DUD->DUD_FILDCA+"zz",.T.))
						DTW->(dbSkip(-1))
						If DTW->(!Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_FILATI) == DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_FILDCA)
							cSequen := DTW->DTW_SEQUEN
						Else
							cSequen := "zz"
						EndIf

						DTW->(dbSetOrder(1))
						If DTW->(MsSeek(xFilial("DTW")+DUD->DUD_FILORI+DUD->DUD_VIAGEM))
							While DTW->(!Eof()) .And. DTW->DTW_FILIAL == xFilial("DTW") .And.;
																DTW->DTW_FILORI == DUD->DUD_FILORI .And.;
																DTW->DTW_VIAGEM == DUD->DUD_VIAGEM

								cNomeFil := ""

								If DTW->DTW_STATUS == "2" .And. DTW->DTW_SEQUEN <= cSequen

									//-- Verifica se a saida da viagem ocorreu na filial de destino.
									If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) .And. ; //-- Transporte
										DTW->DTW_ATIVID == cAtivSai .And. ; //-- Saida de Viagem
										nPosFilDes == Ascan( aFilDca, { |x| x[3] == DTW->DTW_FILATI } ) //-- Filial de Atividade
										DTW->(DbSkip())
										Loop
									EndIf

									If SM0->(MsSeek(SM0->M0_CODIGO+DTW->DTW_FILATI))
										cNomeFil := SM0->M0_FILIAL
									EndIf

									AAdd(aOcor,{DTW->DTW_DATREA,;
														Transform(DTW->DTW_HORREA,PesqPict('DTW','DTW_HORREA')),;
														DTW->DTW_ATIVID+"-"+Tabela("L3",DTW->DTW_ATIVID,.F.),;
														DTW->DTW_FILATI+"-"+cNomeFil,;
														DTW->DTW_FILORI+" "+DTW->DTW_VIAGEM,;
														DTW->DTW_SERTMS+"-"+TmsValField("DTW->DTW_SERTMS",.F.),;
														"DTW",;
														DTW->(Recno()),;
														""})
								EndIf

								SM0->(MsGoto(nRecSM0))

								DTW->(dbSkip())

							EndDo

						EndIf

						DUD->(dbSkip())

					EndDo

				EndIf

			EndIf

			Exit

		EndIf

		DTC->(dbSkip())

	EndDo

EndIf

DUD->(dbSetOrder(1))
If DUD->(MsSeek(xFilial("DUD")+cFilDoc+cDoc+cSerie))
	While DUD->(!Eof()) .And. DUD->DUD_FILIAL == xFilial("DT6") .And. ;
										DUD->DUD_FILDOC == cFilDoc .And. ;
										DUD->DUD_DOC    == cDoc    .And. ;
										DUD->DUD_SERIE  == cSerie

		If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) //-- Transporte
			cRota      := Posicione("DTQ",2,xFilial("DTQ")+DUD->DUD_FILORI+DUD->DUD_VIAGEM,"DTQ_ROTA")
			aFilDca    := TmsRegDCA(cRota)
			nPosFilDes := Ascan( aFilDca, { |x| x[3] == DUD->DUD_FILDCA } )
		EndIf

		DUA->(dbSetOrder(4))
		If DUA->(MsSeek(xFilial("DUA")+cFilDoc+cDoc+cSerie))
			While DUA->(!Eof()) .And.	DUA->DUA_FILIAL == xFilial("DUA") .And.;
										DUA->DUA_FILDOC == cFilDoc .And.;
										DUA->DUA_DOC    == cDoc    .And.;
										DUA->DUA_SERIE  == cSerie

				cNomeFil := ""

				//-- Verifica se a ocorrencia foi efetuada ate a filial destino do documento.
				If DUD->DUD_SERTMS <> StrZero(2,Len(DUD->DUD_SERTMS)) .Or. ; //-- Transporte
					nPosFilDes >= Ascan( aFilDca, { |x| x[3] == DUA->DUA_FILOCO } ) .Or. Empty(DUD->DUD_VIAGEM)

					If SM0->(MsSeek(SM0->M0_CODIGO+DUA->DUA_FILOCO))
						cNomeFil := SM0->M0_FILIAL
					EndIf

					If (Ascan(aOcor, {|x| x[4]+x[9]+x[3] == DUA->DUA_FILOCO+"-"+cNomeFil+DUA->DUA_NUMOCO+DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI")})== 0)
						AAdd(aOcor,{DUA->DUA_DATOCO,;
								Transform(DUA->DUA_HOROCO,PesqPict('DUA','DUA_HOROCO')),;
								DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI"),;
								DUA->DUA_FILOCO+"-"+cNomeFil,;
								DUA->DUA_FILORI+" "+DUA->DUA_VIAGEM,;
								DUA->DUA_SERTMS+"-"+TmsValField("DUA->DUA_SERTMS",.F.),;
								"DUA",;
								DUA->(Recno()),;
								DUA->DUA_NUMOCO })
					EndIf
					SM0->(MsGoto(nRecSM0))
				EndIf
				DUA->(dbSkip())
			EndDo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pesquisa com campos de documento preenchidos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(DUD->DUD_FILORI) .And. !Empty(DUD->DUD_VIAGEM)
			cKeyDUA := xFilial("DUA")+Space(Len(DUA->DUA_FILDOC))+Space(Len(DUA->DUA_DOC))+Space(Len(DUA->DUA_SERIE))+DUD->DUD_FILORI+DUD->DUD_VIAGEM

			DUA->(dbSetOrder(4))
			If DUA->(MsSeek(cKeyDUA))
				While DUA->(!Eof()) .And. DUA->(DUA_FILIAL + DUA_FILDOC + DUA_DOC + DUA_SERIE + DUA_FILORI + DUA_VIAGEM) == cKeyDUA
					cNomeFil := ""  
					//-- Verifica se a ocorrencia foi efetuada ate a filial destino do documento.
					If DUD->DUD_SERTMS <> StrZero(2,Len(DUD->DUD_SERTMS)) .Or. ; //-- Transporte
						nPosFilDes >= Ascan( aFilDca, { |x| x[3] == DUA->DUA_FILOCO } )
						If SM0->(MsSeek(SM0->M0_CODIGO+DUA->DUA_FILOCO))
							cNomeFil := SM0->M0_FILIAL
						EndIf

						If (Ascan(aOcor, {|x| x[4]+x[9]+x[3] == DUA->DUA_FILOCO+"-"+cNomeFil+DUA->DUA_NUMOCO+DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI")})== 0)
							AAdd(aOcor,{DUA->DUA_DATOCO,;
									Transform(DUA->DUA_HOROCO,PesqPict('DUA','DUA_HOROCO')),;
									DUA->DUA_CODOCO+"-"+Posicione("DT2",1,xFilial("DT2")+DUA->DUA_CODOCO,"DT2_DESCRI"),;
									DUA->DUA_FILOCO+"-"+cNomeFil,;
									DUA->DUA_FILORI+" "+DUA->DUA_VIAGEM,;
									DUA->DUA_SERTMS+"-"+TmsValField("DUA->DUA_SERTMS",.F.),;
									"DUA",;
									DUA->(Recno()),;
									DUA->DUA_NUMOCO })
						EndIf
						SM0->(MsGoto(nRecSM0))
					EndIf
					DUA->(dbSkip())
				EndDo
			EndIf
		EndIf

		DTW->(dbSetOrder(6))
		DTW->(dbSeek(xFilial("DTW")+DUD->DUD_FILORI+DUD->DUD_VIAGEM+DUD->DUD_FILDCA+"zz",.T.))
		DTW->(dbSkip(-1))
		If DTW->(!Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_FILATI) == DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_FILDCA) 
			cSequen := DTW->DTW_SEQUEN
		Else
			cSequen := "zz"
		EndIf

		DTW->(dbSetOrder(1))
		If DTW->(MsSeek(xFilial("DTW")+DUD->DUD_FILORI+DUD->DUD_VIAGEM))
			While DTW->(!Eof()) .And. DTW->DTW_FILIAL == xFilial("DTW") .And.;
												DTW->DTW_FILORI == DUD->DUD_FILORI .And.;
												DTW->DTW_VIAGEM == DUD->DUD_VIAGEM 

				cNomeFil := ""

				If DTW->DTW_STATUS == "2" .And. DTW->DTW_SEQUEN <= cSequen

					//-- Verifica se a saida da viagem ocorreu na filial de destino.
					If DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS)) .And. ; //-- Transporte
						DTW->DTW_ATIVID == cAtivSai .And. ; //-- Saida de Viagem
						nPosFilDes == Ascan( aFilDca, { |x| x[3] == DTW->DTW_FILATI } ) //-- Filial de Atividade
						DTW->(DbSkip())
						Loop
					EndIf

					If SM0->(MsSeek(SM0->M0_CODIGO+DTW->DTW_FILATI))
						cNomeFil := SM0->M0_FILIAL
					EndIf

					AAdd(aOcor,{DTW->DTW_DATREA,;
										Transform(DTW->DTW_HORREA,PesqPict('DTW','DTW_HORREA')),;
										DTW->DTW_ATIVID+"-"+Tabela("L3",DTW->DTW_ATIVID,.F.),;
										DTW->DTW_FILATI+"-"+cNomeFil,;
										DTW->DTW_FILORI+" "+DTW->DTW_VIAGEM,;
										DTW->DTW_SERTMS+"-"+TmsValField("DTW->DTW_SERTMS",.F.),;
										"DTW",;
										DTW->(Recno()),;
										""})
				EndIf

				SM0->(MsGoto(nRecSM0))

				DTW->(dbSkip())

			EndDo

		EndIf

		DUD->(dbSkip())

	EndDo

EndIf

//-- Retorna um array contendo a data, hora e ultimo posicionamento da ultima viagem
aPosici := TmsPosAtu( /*cCodVei*/ ,  DT6->DT6_FILVGA , DT6->DT6_NUMVGA, DT6->DT6_FILDOC  , DT6->DT6_DOC , DT6->DT6_SERIE  )	

cDatPos 	:= aPosici[1] //-- Data do ultimo posicionamento
cHorPos	:= aPosici[2] //-- Hora do ultimo posicionamento 
cPosici	:= aPosici[3] //-- Ultimo posicionamento		 	

CursorArrow()

If Len(aOcor) > 0

	aOcor := aSort(aOcor,,,{|x,y| Dtos(x[1])+x[2] < Dtos(y[1])+y[2] })

	//-- Ponto para Troca a descricao das atividades de Operacoes / Ocorrencias
	If lTm500TR3
		aOcoUsr := ExecBlock("TM500TR3",.F.,.F.,{aOcor})
		If ValType(aOcoUsr) == 'A' .And. Len(aOcoUsr) > 0
			aOcor := AClone(aOcoUsr)
		EndIf
	EndIf

	If !lArray //-- Não retorna Array
		aObjects := {} 
		If !Empty(cPosici) 
			nTamAltu := 85
		EndIf
		AAdd( aObjects, { 100, nTamAltu , .T., .T. , .T. } )
		AAdd( aObjects, { 100, 15 , .T., .T. , .T. } )

		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 } 
		aPosObj := MsObjSize( aInfo, aObjects , .T. ) 
	
		DEFINE MSDIALOG oDlgOcor FROM aSize[7], 000 TO aSize[6],aSize[5] TITLE STR0049 OF oMainWnd PIXEL   //"Operacoes / Ocorrencias"
	
			@ aPosObj[1,1],aPosObj[1,2] LISTBOX oOcor VAR cVar Fields HEADER	STR0047,;	//"Data"
																									STR0048,;   //"Hora"
																									STR0050,; 	//"Operacao/Ocorrencia"
																									STR0044,;  	//"Filial"
																									STR0045,;  	//"Viagem"
																									STR0052 ;  	//"Serv. Transporte"
																									SIZE aPosObj[1,3],aPosObj[1,4] OF oDlgOcor PIXEL
			oOcor:SetArray(aOcor)
			oOcor:bLine:={ ||{aOcor[oOcor:nAT,1],;
									aOcor[oOcor:nAT,2],;
									aOcor[oOcor:nAT,3],;
									aOcor[oOcor:nAT,4],;
									aOcor[oOcor:nAT,5],;
									aOcor[oOcor:nAT,6]}}
	
		   If !Empty(cPosici)  
		   	oPanel :=  TPanel():New( aPosObj[2,1], aPosObj[2,2],, oDlgOcor , Nil,.T.,,,,aPosObj[2,3], aPosObj[2,4],,)  //-- Ultimo Posicionamento
		   	
				tSay():New(003,005,{||STR0184} , oPanel,,,,,,.T.,,,100,9)
				
				tSay():New(015,005,{||DAV->( RetTitle("DAV_DATPOS"))},oPanel,,,,,,.T.,,,50,9) //"Dt. Posici."
				tGet():New(013,055,{|u| cDatPos },oPanel,50,9,PesqPict("DAV","DAV_DATPOS"),,,,,,,.T.,,,,,,,.T.,,,'cDatPos')    
				
				tSay():New(030,005,{||DAV->( RetTitle("DAV_HORPOS"))},oPanel,,,,,,.T.,,,50,9) //"Hr. Posici."
				tGet():New(028,055,{|u| cHorPos },oPanel,30,9,PesqPict("DAV","DAV_HORPOS"),,,,,,,.T.,,,,,,,.T.,,,'cHorPos') 
				
				tSay():New(045,005,{||DAV->( RetTitle("DAV_POSICI"))},oPanel,,,,,,.T.,,,50,9) //"Localização"
				tGet():New(041,055,{|u| cPosici },oPanel,  aPosObj[2,3] - 55 ,9,"@!",,,,,,,.T.,,,,,,,.T.,,,'cPosici') 		 
			EndIf

			oOcor:Refresh()
	
		ACTIVATE MSDIALOG  oDlgOcor ON INIT EnchoiceBar( oDlgOcor, { || nOpca := 1,oDlgOcor:End()}, {||oDlgOcor:End()},,aButtons)
	Else
		xRet := aClone(aOcor)
	EndIf
EndIf

RestArea(aAreaDT6)
RestArea(aAreaDUA)
RestArea(aArea)

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return xRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500VTr³ Autor ³ Henry Fila            ³ Data ³19.11.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualizacoes das ocorrencias e operacoes                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA500VTr()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Tabela (DTW ou DUA)                                 ³±±
±±³          ³ ExpC2: Recno da tabela desejada                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa500VTr(cTabela,nRecTab)

Local aArea    := GetArea()
Local aAreaDTW := DTW->(GetArea())
Local aAreaDUA := DUA->(GetArea())

Do Case
	Case cTabela == "DTW" 
		DTW->(MsGoto(nRecTab))
		AxVisual(cTabela,nRecTab,2)
	Case cTabela  == "DUA"
		DUA->(MsGoto(nRecTab))
		Tmsa360Mnt(cTabela,nRecTab,2)
EndCase


RestArea(aAreaDTW)
RestArea(aAreaDUA)
RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Can³ Autor ³ Henry Fila            ³ Data ³19.11.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida permissao para cancelamento                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA500Can()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Filial do Documento                                 ³±±
±±³          ³ ExpC2: Numero do documento                                 ³±±
±±³          ³ ExpC3: Serie do documento                                  ³±±
±±³          ³ ExpC4: Filial original                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tms500Can(cFilDoc,cDoc,cSerie,cFilOri)

Local lCancela := .T.
Local aArea    := GetArea()
Local aAreaDUD := DUD->(GetArea())
Local cFilSE1  := ""
Local cFilSF2  := ""
Local cPrefixo := ""
Local cTMSMFat := GetMV("MV_TMSMFAT",,"") //-- Modo de Faturamento:1-Faturamento a partir do SE1;2=Faturamento a partir do DT6
Local aPerfil  := {}
Local cDocFat  := ''
Local lFatSE1  := cTMSMFat == '1'

DEFAULT cFilDoc := DT6->DT6_FILDOC
DEFAULT cDoc    := DT6->DT6_DOC
DEFAULT cSerie  := DT6->DT6_SERIE
DEFAULT cFilOri := cFilAnt

DUD->(dbSetOrder(1))
If DUD->(MsSeek(xFilial("DUD")+cFilDoc+cDoc+cSerie+cFilOri))
	If !Empty(DUD->DUD_VIAGEM)
		Help(" ",1,"TMSA50028") //Existe viagem para este conhecimento de frete
		lCancela := .F.
	EndIf
EndIf

If lCancela
	//* Permite cancelamento
	If DT6->DT6_FILDOC != cFilAnt
		Help( " ", 1, "TMSA50031",, DT6->DT6_FILDOC, 5, 1 )	//Cancelamento deve ser realizado na filial de origem
		lCancela := .F.
	EndIf

	If	DT6->DT6_PRIPER != StrZero(2,Len(DT6->DT6_PRIPER))
		Help('',1,'TMSA50035')	//"Cancelamento nao permitido em documentos de 1o percurso"
		lCancela := .F.
	EndIf

EndIf

If lCancela

	If !lFatSE1 //-- Pelo DT6
		//-- Obtem o perfil do cliente para verificar quais documentos possuem tratamento diferenciado no 
		//-- faturamento:
		aPerfil := TmsPerfil(DT6->DT6_CLICAL,DT6->DT6_LOJCAL,,,DT6->DT6_CLIREM,DT6->DT6_LOJREM,DT6->DT6_CLIDES,DT6->DT6_LOJDES)
		cDocFat := aPerfil[47]
		If AllTrim(cDocFat) == '*'
			lFatSE1 := .T.
		Else
			lFatSE1 := DT6->DT6_DOCTMS $ cDocFat
		EndIf
	EndIf

	Do Case
		Case DT6->DT6_DOCTMS == StrZero(6, Len(DT6->DT6_DOCTMS)) .And. !(DT6->DT6_STATUS $ "1/C")  
			Help(" ",1,"TMSA50029") //Documento nao esta em aberto
			lCancela := .F.
		Case !Empty( DT6->DT6_DOCSEG )
			Help(" ",1,"TMSA50053",,STR0019 + DT6->DT6_DOC + " / " + STR0076 + DT6->DT6_DOCSEG,2,1) //"Ha fechamento de seguro para este docto"
			lCancela := .F.
		Case !lFatSE1 //-- Faturamento realizado pelo DT6
			If  !Empty(DT6->DT6_NUM) 
				Help(" ",1,"TMSA50054",,DT6->DT6_FILDOC+ "/" + DT6->DT6_DOC+ "/" + DT6->DT6_SERIE + STR0075,2,1) //"Ja foi gerada Fatura para o CTRC : "###"A Exclusao deste CTRC nao sera efetuada"
				lCancela := .F.
			EndIf
		Case lFatSE1 //-- Faturamento realizado pelo SE1
			cFilSF2	 := Iif(Empty(xFilial('SF2')), xFilial('SF2'), DT6->DT6_FILDOC)
			cFilSE1	 := Iif(Empty(xFilial('SE1')), xFilial('SE1'), DT6->DT6_FILDOC)
			SF2->(DbSetOrder(1))
			SF2->(MsSeek( cFilSF2 + DT6->DT6_DOC + DT6->DT6_SERIE ))
			cPrefixo := Padr( If(Empty(SF2->F2_PREFIXO),&(GETMV("MV_1DUPREF")),SF2->F2_PREFIXO),  Len( SE1->E1_PREFIXO ) )
			SE1->(DbSetOrder(1))
			If SE1->(MsSeek(cFilSE1+cPrefixo+DT6->DT6_DOC))
				If ROUND(SE1->E1_SALDO,2) <> ROUND(SE1->E1_VALOR,2) .Or. SE1->E1_SITUACA <> StrZero(0,Len(SE1->E1_SITUACA))
					Help(" ",1,"TMSA50055",,STR0019 + DT6->DT6_DOC + '/' + DT6->DT6_SERIE,2,1) //"O Titulo do documento esta baixado ou nao esta em carteira"
					lCancela := .F.
				EndIf
			EndIf
	EndCase
EndIf

RestArea(aAreaDUD)
RestArea(aArea)

Return( lCancela )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Tmsa500Leg³ Autor ³ Henry Fila            ³ Data ³23/01/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Exibe a legenda dos status                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa500Leg(cCor, cDesc)

Local aLegenda := {	{ "BR_VERDE"	, STR0056 },; //"Em Aberto"
					{ "BR_VERMELHO"	, STR0057 + ' / ' + STR0083 },; //"Carregado" ### "Indicado para Coleta"
					{ "BR_AMARELO"	, STR0058 + ' / ' + STR0291 },; //"Em Transito" ### "Coleta em Processo"
					{ "BR_LARANJA"	, STR0059 + ' / ' + STR0084 },; //"Chegada Parcial" ### "Documento Informado"
					{ "BR_AZUL"		, STR0060 + ' / ' + STR0085 },; //"Chegada Final" ### "Encerrada"
					{ "BR_CINZA"	, STR0061 },; //"Indicado para Entrega"
					{ "BR_MARRON"	, STR0062 },; //"Entregue"
					{ "BR_PINK"		, STR0178 },; //"Entrega Parcial"
					{ "BR_PRETO"	, STR0151 },; //"Ordem de Coleta Cancelada"
					{ "BR_BRANCO"	, STR0183 },; //"Retorno Total"
					{ "BR_CANCEL"	, STR0163 },; // "CTRC Anulado"
					{ "PMSEDT4"		, STR0192 },; //"Cancelamento SEFAZ Aguardando"
					{ "PMSEDT3"		, STR0193 },; //"Cancelamento SEFAZ Autorizado"
					{ "PMSEDT1"		, STR0194 } } //"Cancelamento SEFAZ Nao Autorizado"
Default cCor := ""
Default cDesc:= ""

If !Empty(cCor)  
	AAdd( aLegenda, {cCor, cDesc } ) 
EndIf	
BrwLegenda( cCadastro, STR0063, aLegenda  )  //"Status"
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Ali³ Autor ³ Eduardo de Souza      ³ Data ³ 26/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao Documentos Alianca.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500Ali()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Ali()
Local cMensag   := ""
Local lDocAli   := .F.
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local nOpcA     := 0
Local cParceiro := ""
Local cCombo1   := ""
Local cCombo2   := ""
Local cFilDpc   := Space(Len(DTC->DTC_FILDPC))
Local cCtrDpc   := Space(Len(DTC->DTC_CTRDPC))
Local aCombo1   := {STR0144,STR0145}
Local aCombo2   := {}
Local aSize     := MsAdvSize( .F. )
Local cFilTit   := ''
Local cAliTit   := ''
Local cCtrTit   := ''
Local cFilAli   := Space(Len(DVL->DVL_FILPAR))
Local nCombo1   := 0
Local nCombo2   := 0
Local oCombo1
Local oCombo2
Local aSX5 		:= {}
Local nI		:= 0

If Type("lMsErroAuto") == "U"
	Private lMsErroAuto:= .F.
EndIf

If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

TmsKeyOff(aSetKey)
If TmsDocAli(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
	cMensag := OemToAnsi(STR0065) // "O servico atual do documento e Alianca, deseja tornar o documento para Transporte ou Entrega normal ?"
Else
	cMensag := OemToAnsi(STR0066) // "O servico atual do documento nao e Alianca, deseja tornar o documento Entrega Alianca ?"
	lDocAli := .T.
EndIf

If lTM500Auto .Or. MsgYesNo(cMensag,OemToAnsi(STR0067)) // "Atencao !"

	//-- Tornar Documento Alianca
	If lDocAli
		cAliTit := RetTitle("DVL_FILPAR")
		cFilTit := RetTitle("DTC_FILDPC")
		cCtrTit := RetTitle("DTC_CTRDPC")
		
		aSX5 := FwGetSX5("MI")
		For nI := 1 to Len(aSX5)
			AAdd(aCombo2,  AllTrim(aSX5[nI][4])  )
		Next
		
		If !lTM500Auto
			AAdd( aObjects, { 100, 080, .T., .F. } )
			AAdd( aObjects, { 100, 100, .T., .T. } )
			aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ] / 2 , aSize[ 4 ] / 4 , 3, 2 } 
			aPosObj := MsObjSize( aInfo, aObjects ) 
	
			DEFINE MSDIALOG oDlgRep TITLE STR0068 From aSize[7],00 to aSize[6] / 2.35  ,aSize[5] / 2 Of oMainWnd PIXEL //"Copia de Ajustes"
	
				@ aPosObj[1,1]+11,003 to aPosObj[2,1]-2,aPosObj[2,4] OF oDlgRep PIXEL
	
				@ 18,008 SAY STR0143 SIZE 50,7 OF oDlgRep PIXEL 	 //"Percurso"
				@ 18,050	 MSCOMBOBOX oCombo1 VAR cCombo1 ITEMS aCombo1 VALID If(oCombo1:nAt == 1, ( cFilDpc := Space(Len(DTC->DTC_FILDPC))  ) == "0" .Or. ( cFilAli := Space(Len(DVL->DVL_FILPAR))  ) == "0" .Or. ( cCtrDpc := Space(Len(DTC->DTC_CTRDPC))  ) == "0" .Or. .T. ,.T.) ;
				  SIZE 62 ,7 OF oDlgRep PIXEL
				Eval(oCombo1:bChange := {|| nCombo1 := oCombo1:nAt})
	
				@ 30,008 SAY cAliTit SIZE 30,7 OF oDlgRep PIXEL	 //"Filial Desp."
				@ 30,050 MsGet cFilAli VALID ( cFilDpc := Posicione("DVL",2,xFilial("DVL") + cFilAli,"DVL_FILALI ") ) == "00" .Or. .T. ;
				PICTURE "@!" SIZE 20,7 OF oDlgRep PIXEL WHEN oCombo1:nAt == 2
	
				@ 42,008 SAY cFilTit SIZE 30,7 OF oDlgRep PIXEL	 //"Filial Desp."
				@ 42,050 MsGet cFilDpc F3 "DVL" Valid Vazio(cFilDpc) .Or. !Empty( cFilAli := Tmsa500Val(cFilDpc) ) ;
				PICTURE "@!"  SIZE 20,7 OF oDlgRep PIXEL WHEN oCombo1:nAt == 2
	
				@ 54,008 SAY cCtrTit SIZE 30,7 OF oDlgRep PIXEL	 //"Ctrc Alianca"
				@ 54,050 MsGet cCtrDpc  VALID .T. PICTURE "@!"  SIZE 20,7 OF oDlgRep PIXEL WHEN oCombo1:nAt == 2
	
				@ 66,008 SAY STR0069 SIZE 50,7 OF oDlgRep PIXEL	 //"Parceiro"
				@ 66,050 MSCOMBOBOX oCombo2 VAR cCombo2 ITEMS aCombo2 SIZE 62 ,7 OF oDlgRep PIXEL
				Eval(oCombo2:bChange := {|| nCombo2 := oCombo2:nAt})
	
			ACTIVATE MSDIALOG oDlgRep CENTERED ON INIT EnchoiceBar(oDlgRep,{|| Iif( Tma500TAli(oCombo1:nAt,cFilAli,cFilDpc,cCtrDpc,oCombo2:nAt),( nOpcA := 1, oDlgRep:End() ),(nOpca := 0 ) ) },{||oDlgRep:End()})

		Else
			nPercurso := Get500Aut("NPERCURDOC",,0)
			If nPercurso == 2
				cFilDpc   := Get500Aut("CFILDPCDOC",,"")
				//-- A validação do cFilDpc 
				cFilAli   := Tmsa500Val(cFilDpc)
				
				cCtrDpc   := Get500Aut("CCTRDPCDOC",,"")
				nCombo2   := Get500Aut("NPARCEIDOC",,0)
				//-- Na opção automática, deve-se adicionar validação dos comboBoxes pois os mesmos são obrigatórios na interface e não possuem validação na interface, por esta razão.
				If nCombo2 <= 0 .Or. nCombo2 > Len(aCombo2)
					Help("",1,'Obrigat2',,)
					AutoGrLog(STR0255) //--"[NPARCEIDOC] => Informe um parceiro válido"
					AutoGrLog(VarInfo(STR0069,aCombo2,,.F.)) //"Parceiro"
				EndIf
			//-- Na opção automática, deve-se adicionar validação dos comboBoxes pois os mesmos são obrigatórios na interface e não possuem validação na interface, por esta razão.
			ElseIf nPercurso <> 1 .And. nPercurso <> 2
				Help("",1,'Obrigat2',,)
				AutoGrLog(STR0256) //--"[NPERCUDOC] => Informe 1 para 1° percurso ou 2 para 2° percurso"
			EndIf
			//-- Validação TOk 
			If !lMsErroAuto
				Tma500TAli(nPercurso,cFilAli,cFilDpc,cCtrDpc,nCombo2)
			EndIf
			
			//-- A funcao Help alimenta a variável lMsErroAuto e, portanto, se houve chamada à função Help, ocorreu erro e não ocorrerá a gravação
			nOpcA := Iif(!lMsErroAuto,1,0)
		EndIf
	EndIf
	If !lDocAli .Or. nOpcA == 1
		If nOpca == 1
			cParceiro := StrZero(nCombo2,Len(DTC->DTC_ALIANC))
		EndIf
		Processa( {|lEnd| A500AtuAli(lDocAli,cParceiro,cFilAli,cFilDpc,cCtrDpc) }, cCadastro, OemToAnsi(STR0071), .F. ) // "Atualizando Documento..."
	EndIf

EndIf

TmsKeyOn(aSetKey)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A500AtuAli³ Autor ³ Eduardo de Souza      ³ Data ³ 27/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza documento (Alianca)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A500AtuAli(ExpL1,ExpC1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Tornar Docto Alianca                               ³±±
±±³          ³ ExpC1 - Parceiro                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A500AtuAli(lDocAli,cParceiro,cFilAli,cFilDpc,cCtrDpc)

Local aAreaDTC   := DTC->(GetArea())
Local aAreaDT6   := DT6->(GetArea())
Local aAreaDUD   := DUD->(GetArea())
Local nCodAlter  := 16384 //-- Utilizado no Sincronizador de Dados
Local nCodDelete := 32768 //-- Utilizado no Sincronizador de Dados
Local nModo      := 0
Local cStatusDT6 := ""
Local lTMSA500ALI:= ExistBlock( "TMSA500ALI" )
Local lRet       := .T.
Local cSeekDe5   := ''
//-- Atualiza o campo Alianca para as Notas Fiscais
DTC->(DbSetOrder(3))
Begin Transaction
If DTC->(MsSeek(xFilial("DTC")+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE))
	dbSelectArea("DE5")
	dbSetOrder(3)
	If MsSeek(cSeekDE5 := xFilial("DE5") + cFilDpc + cCtrDpc + StrZero(1,Len(DE5->DE5_STATUS)) )
		While DE5->( !Eof() ) .And. cSeekDE5 == DE5->( DE5_FILIAL + DE5_FILDPC + DE5_CTRDPC + DE5_STATUS )
			Reclock("DE5",.F.)
			If lDocAli
				DE5->DE5_STATUS := StrZero(2,Len(DE5->DE5_STATUS))
			Else
				DE5->DE5_STATUS := StrZero(1,Len(DE5->DE5_STATUS))
			EndIf
			DE5->( MsUnlock() )
			DE5->( dbSkip() )
		EndDo
	EndIf
	While DTC->(!Eof()) .And. DTC->DTC_FILIAL + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE == ;
			xFilial("DTC") + M->DT6_FILDOC + M->DT6_DOC + M->DT6_SERIE
		RecLock("DTC",.F.)
		If lDocAli
			DTC->DTC_ALIANC := cParceiro
			DTC->DTC_FILDPC := cFilDpc
			DTC->DTC_CTRDPC := cCtrDpc
			nModo := nCodAlter
		Else
			nModo     := nCodDelete
			DTC->DTC_ALIANC := CriaVar("DTC_ALIANC",.F.)
			DTC->DTC_FILDPC := CriaVar("DTC_FILDPC",.F.)
			DTC->DTC_CTRDPC := CriaVar("DTC_CTRDPC",.F.)
			cParceiro := DTC->DTC_ALIANC
		EndIf
		MsUnlock()
		DTC->(DbSkip())
	EndDo
	//-- Atualiza documento
	DT6->(DbSetOrder(1))
	If DT6->(MsSeek(xFilial("DT6")+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE))
		RecLock("DT6",.F.)
		If lDocAli
			DT6->DT6_ALIANC := cParceiro
		Else
			DT6->DT6_ALIANC := CriaVar("DT6_ALIANC",.F.)
		EndIf
		MsUnlock()
	EndIf
EndIf
//-- Ponto de Entrada utilizado para atualizar os dados referente o sincronizador
//   antes de atualizar o servico do transporte
If lRet .And. lTMSA500ALI
	ExecBlock("TMSA500ALI",.F.,.F.,{nModo, M->DT6_FILDOC, M->DT6_DOC, M->DT6_SERIE, cParceiro})
EndIf
//-- Atualiza o Documento para Entrega em Filial Alianca
If lRet
	DUD->(DbSetOrder(1))
	If DUD->(MsSeek(xFilial("DUD")+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE+cFilAnt))
		While DUD->(!Eof()) .And. DUD->DUD_FILIAL + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE + DUD->DUD_FILORI == ;
			xFilial("DUD") + M->DT6_FILDOC + M->DT6_DOC + M->DT6_SERIE + cFilAnt
			If DUD->DUD_STATUS == StrZero(1, Len(DUD->DUD_STATUS))
				RecLock("DUD",.F.)
				If lDocAli
					DUD->DUD_SERTMS := Strzero(3, Len(DUD->DUD_SERTMS)) //-- Entrega
					cStatusDT6      := Strzero(5, Len(DT6->DT6_STATUS)) //-- Chegada Final
				Else
					If cFilAnt == Posicione("DT6",1,xFilial("DT6")+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE,"DT6_FILDES")
						DUD->DUD_SERTMS := Strzero(3, Len(DUD->DUD_SERTMS)) //-- Entrega
						cStatusDT6      := Strzero(5, Len(DT6->DT6_STATUS)) //-- Chegada Final
					Else
						DUD->DUD_SERTMS := Strzero(2, Len(DUD->DUD_SERTMS)) //-- Transporte
						cStatusDT6      := Strzero(4, Len(DT6->DT6_STATUS)) //-- Chegada Parcial
					EndIf
				EndIf
				MsUnlock()
			EndIf
			//-- Atualiza o Status do documento
			If DT6->(MsSeek(xFilial("DT6")+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))
				If DT6->DT6_STATUS == Strzero(4, Len(DT6->DT6_STATUS)) .Or. ;
					DT6->DT6_STATUS == Strzero(5, Len(DT6->DT6_STATUS))
					RecLock("DT6",.F.)
					DT6->DT6_STATUS := cStatusDT6
					MsUnlock()
				EndIf
			EndIf
			DUD->(DbSkip())
		EndDo
	EndIf
EndIf
End Transaction
RestArea( aAreaDTC )
RestArea( aAreaDT6 )
RestArea( aAreaDUD )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA500Trp³ Autor ³ Eduardo de Souza      ³ Data ³ 09/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Manutencao de transporte do documento.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500Trp()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA500Trp()

Local lRetPE       := .T.
Local oDlg
Local nOpcao       := 1
Local cReadOld
Local lContinua

Private cTipTraDUD := ""
Private cSerTmsDUD := ""

If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

DUD->(DbSetOrder(1))
If DUD->(MsSeek(xFilial("DUD")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE+cFilAnt))

	cTipTraDUD := DUD->DUD_TIPTRA
	cSerTmsDUD := DUD->DUD_SERTMS

	If !lTM500Auto
		DEFINE MSDIALOG oDlg FROM 00,00 TO 130,490 PIXEL TITLE STR0076 // "Manutencao de Transporte"
			
			@ 05,05 SAY STR0079 PIXEL // "De Serv. Transp."
			@ 05,60 MSGET DUD->DUD_SERTMS WHEN .F. SIZE 10, 07 OF oDlg PIXEL
			@ 05,80 MSGET TMSValField("DUD->DUD_SERTMS",.F.) WHEN .F. SIZE 100, 07 OF oDlg PIXEL
	
			@ 20,05 SAY STR0080 PIXEL // "Para Serv. Transp."
			@ 20,60 MSGET cSerTmsDUD F3 "DLH" SIZE 10, 07 OF oDlg PIXEL ;
				VALID CheckSx3("DUD_SERTMS",cSerTMSDUD) .And. TmsA500Srv(cSerTmsDUD)
			@ 20,80 MSGET TMSValField("cSerTmsDUD",.F.) WHEN .F. SIZE 100, 07 OF oDlg PIXEL
	
			@ 35,05 SAY STR0077 PIXEL // "De Tip. Transp."
			@ 35,60 MSGET DUD->DUD_TIPTRA WHEN .F. SIZE 10, 07 OF oDlg PIXEL
			@ 35,80 MSGET TMSValField("DUD->DUD_TIPTRA",.F.) WHEN .F. SIZE 100, 07 OF oDlg PIXEL
	
			@ 50,05 SAY STR0078 PIXEL // "Para Tip. Transp."
			@ 50,60 MSGET cTipTraDUD F3 "DLG" SIZE 10, 07 OF oDlg PIXEL ;
				VALID CheckSx3("DUD_TIPTRA",cTipTraDUD)
			@ 50,80 MSGET TMSValField("cTipTraDUD",.F.) WHEN .F. SIZE 100, 07 OF oDlg PIXEL
	
			DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (nOpcao := 1,oDlg:End())
			DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION (nOpcao := 0,oDlg:End())
	
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		//-- Guarda o "ponteiro" da variável de memória atual
		cReadOld := ReadVar()
		
		//-- Valida se preenchou corretamente
		If !(lContinua := !Empty(Get500Aut("CSERTMSDOC",,"")) .Or. !Empty(Get500Aut("CTIPTRADOC",,"")))
		 	Help("",1,'Obrigat2',,OemToAnsi(STR0195+ " "+ STR0052 + " / " + STR0078)) //-- "Informe o valor digitado para:"##"Serv. Transporte" ##"Para Tip. Transp."
		EndIf
		
		//-- Valida o Serviço
		If lContinua .And. !Empty(Get500Aut("CSERTMSDOC",,""))
		
			__ReadVar  := "cSerTmsDUD" 
			cSerTmsDUD := Get500Aut("CSERTMSDOC",,"")

			lContinua  := TmsA500Srv(cSerTmsDUD)
		EndIf
		

		//-- Valida o tipo de transporte
		If lContinua .And. !Empty(Get500Aut("CTIPTRADOC",,""))
			__ReadVar  := "cTipTraDUD" 
			cTipTraDUD := Get500Aut("CTIPTRADOC",,"")
			lContinua  := CheckSx3("DUD_TIPTRA",cTipTraDUD)
		EndIf
		
		nOpcA := Iif(lContinua, 1, 0)
		
		If !lContinua
			Help( " ", 1, "TMSA500D2")	//-- "Operação incompleta. " ## "A operação não foi bem-sucedida."
		EndIf
		
		//-- Retorna o "ponteiro" da variável de memória
		__ReadVar := cReadOld 
	EndIf

	If nOpcao == 1
		If ExistBlock("TM500BLQ")  	//-- Bloqueia a alteracao do Servico de Transporte quando a Filial de Origem for diferente da Filial Destino.
			If ValType( lRetPE := ExecBlock('TM500BLQ',.F.,.F.)) <> "L"
				lRetPE := .T.
			EndIf
		EndIf
		If lRetPE
			RecLock("DUD",.F.)
			DUD->DUD_TIPTRA := cTipTraDUD
			DUD->DUD_SERTMS := cSerTmsDUD
			MsUnlock()
		EndIf
	EndIf
Else
	Help("",1,"TMSA50043") // "Nao existem movimento de viagem para este documento."
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA500Srv³ Autor ³ Eduardo de Souza      ³ Data ³ 09/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida Servico de Coleta.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500Srv(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Servico de Transporte                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA500Srv(cSerTmsDUD)

If cSerTmsDUD == "1"
	Help("",1,"TMSA50044") //"O Servico nao podera ser Coleta."
	Return( .F. )
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA500Viag³ Autor ³ Eduardo de Souza     ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna as viagens do documento                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500Viag()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Viag()
Local lRet		:= .T.
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

cQuery := " SELECT DUD.DUD_VIAGEM "
cQuery += " FROM " + RetSqlName('DFV') + " DFV," + RetSqlName('DUD') + " DUD"
cQuery += " WHERE "
cQuery += "	    DFV.DFV_FILIAL  = '" + xFilial("DFV")  + "' "
cQuery += " AND DFV.DFV_FILDOC  = '" + DT6->DT6_FILDOC + "' "
cQuery += " AND DFV.DFV_DOC     = '" + DT6->DT6_DOC    + "' "
cQuery += " AND DFV.DFV_SERIE   = '" + DT6->DT6_SERIE  + "' "
cQuery += " AND DFV.DFV_STATUS  <> '" + StrZero( 9, Len( DFV->DFV_STATUS ) ) + "'"
cQuery += " AND DFV.D_E_L_E_T_  <> '*'"
cQuery += " AND DUD.DUD_FILIAL  = '" + xFilial("DUD")  + "' "
cQuery += " AND DUD.DUD_FILDOC  = DFV.DFV_FILDOC "
cQuery += " AND DUD.DUD_DOC     = DFV.DFV_DOC "
cQuery += " AND DUD.DUD_SERIE   = DFV.DFV_SERIE "
cQuery += " AND DUD.DUD_VIAGEM  <> '  '"
cQuery += " AND DUD.D_E_L_E_T_  <> '*'"

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
If (cAliasQry)->(!Eof()) .And. Empty((cAliasQry)->DUD_VIAGEM)
	Help( " ", 1, "TMSA50092")	// Doc. de Redespacho, sem viagem !.
	lRet := .F.
EndIf
(cAliasQry)->( dbCloseArea() )

If lRet
	TmsAllViag(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
EndIf
//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA500Man ³ Autor ³ Eduardo de Souza     ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o manifesto do documento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500Man()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Man()

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

If !Empty(DT6->DT6_NUMVGA)
	TmsVisManif(DT6->DT6_FILVGA,DT6->DT6_NUMVGA)
Else
	Help('',1,'TMSA50032') //"Carregamento nao executado!"
EndIf

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA500Tab ³ Autor ³ Eduardo de Souza     ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza a tabela de frete do documento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500Tab()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Tab()
Local cFildoc := DT6->DT6_FILDOC
Local cDocto  := DT6->DT6_DOC
Local cSerie  := DT6->DT6_SERIE

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)
If DT6->DT6_TABFRE <> M->DT6_TABFRE .Or. DT6->DT6_TIPTAB <> M->DT6_TIPTAB .Or. Empty(M->DT6_TABFRE)
	Help( " ", 1, "TMSA50090")	//"Visualizacao da tabela permitida somente apos a gravacao do documento"
Else

    //- Se for uma solicitacao de coleta busca documento de frete pela solicitacao.
    If DT6->DT6_SERIE == 'COL'
	   TmsVisTabel(cFildoc,cDocto,cSerie,'1')
	Else
	   TmsVisTabel(cFildoc,cDocto,cSerie,'2')
	EndIf

EndIf
//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Cmp³ Autor ³ Alex Egydio           ³ Data ³20.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclui no vetor afrete, componentes que nao foram          ³±±
±±³          ³ calculados no documento original. Usado no complemento     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tabela de frete                                    ³±±
±±³          ³ ExpC2 - Tipo da Tabela de frete                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Cmp(cTabFre,cTipTab)

Local aAreaAnt := GetArea()
Local aAreaDT3 := DT3->(GetArea())
Local aAreaDTL := DTL->(GetArea())
Local cSeek    := ''
Local lAchou   := .F.
Local lCalMin  := .T.      
Local lCamposRat:= DT8->(ColumnPos("DT8_PERRAT")) > 0

DT3->(DbSetOrder(1))
DVE->(DbSetOrder(1))
If	DVE->(MsSeek(cSeek := xFilial('DVE')+cTabFre+cTipTab))
	While DVE->(!Eof() .And. DVE->DVE_FILIAL + DVE->DVE_TABFRE + DVE->DVE_TIPTAB == cSeek)
		If	AScan(aFrete,{|x|x[3]==DVE->DVE_CODPAS})==0 .And. DT3->(MsSeek(xFilial('DT3')+DVE->DVE_CODPAS))
			lAchou := .T.
			//-- Formato do vetor aFrete
			//
			//-- aFrete[01] = Descricao do componente
			//-- aFrete[02] = Valor do componente
			//-- aFrete[03] = Codigo do componente
			//-- aFrete[04] = Item SD2. Atualizado pelas funcoes que geram o SD2
			//-- aFrete[05] = Na cotacao eh gravado o valor do imposto do componente
			//-- aFrete[06] = Total do componente ( valor + imposto )
			//-- aFrete[07] = Codigo da regiao origem
			//-- aFrete[08] = Codigo da regiao destino
			//-- aFrete[09] = Tabela de Frete
			//-- aFrete[10] = Tipo da Tabela de Frete
			//-- aFrete[11] = Sequencia da Tabela de Frete
			//-- aFrete[12] = Forca a linha totalizadora para a ultima linha
			//-- aFrete[13] = Desconto dado ao valor do componente
			//-- aFrete[14] = Acrescimo dado ao valor do componente
			//-- aFrete[15] = Indica se o componente foi calculado com o valor minimo. "1"= Sim, "2"= Nao
			//----Rateio----------                                                  |
			//-- aFrete[16] = Indica o criterio de calculo do componente- Peso, Volume,|
			//--              Quantidade                                               |
			//-- aFrete[17] = Produto                                                  |
			//-- aFrete[18] = Codigo do Serviço                                        |
			//-- aFrete[19] = Codigo do Cliente                                        |
			//-- aFrete[20] = Loja do cliente                                          |
			//-- aFrete[21] = % Calculado de Rateio para o Componente de Frete         |
			AAdd( aFrete, { AllTrim(DT3->DT3_DESCRI), 0, DT3->DT3_CODPAS, '', 0, 0, Space(Len(DT8->DT8_CDRORI)), Space(Len(DT8->DT8_CDRDES)), '', '', '','00', 0, 0, Iif(lCalMin, StrZero(2,Len(DT8->DT8_CALMIN)) ,"2"),'','','','','', Iif(lCamposRat,TransForm( 0, PesqPict('DT8','DT8_PERRAT')),0) } )
		EndIf
		DVE->(DbSkip())
	EndDo
	
	//-- Tratamento Rentabilidade/Ocorrencia
	//-- Inclui Componente Da Rotina TMSA152
	If IsInCallStack("Tmsa152Ger")
		//-- Verifica Se Vetor aFrete Contém o Componente Necessário
		If AScan(aFrete,{|x|x[3] == DT2->DT2_CDPASR }) == 0
			//-- Componentes De Frete
			DbSelectArea("DT3")
			DbSetOrder(1)
			If MsSeek( FWxFilial("DT3") + DT2->DT2_CDPASR , .F. )
				AAdd( aFrete, { AllTrim(DT3->DT3_DESCRI), 0, DT3->DT3_CODPAS, '', 0, 0, Space(Len(DT8->DT8_CDRORI)), Space(Len(DT8->DT8_CDRDES)), '', '', '','00', 0, 0, Iif(lCalMin, StrZero(2,Len(DT8->DT8_CALMIN)) ,"2"),'','','','','', Iif(lCamposRat,TransForm( 0, PesqPict('DT8','DT8_PERRAT')),0) } )
			EndIf
		EndIf
	EndIf
			
	If	lAchou
		ASort(aFrete,,,{|x,y| x[12] + x[3] < y[12] + y[3] })
	EndIf
EndIf

RestArea(aAreaDT3)
RestArea(aAreaDTL)
RestArea(aAreaAnt)
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Alq³ Autor ³ Alex Egydio           ³ Data ³20.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Obtem a aliquota de icm. Usado no 'complemento' para       ³±±
±±³          ³ componentes que nao foram calculados no documento original ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do componente                               ³±±
±±³          ³ ExpN1 = Valor sugerido para o componente                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Alq(cCodPas,nValComp)

Local aRegra	:= {}
Local cPrImp	:= Posicione('DUI',1,xFilial('DUI')+cDocTms,'DUI_CODPRO')
Local cTes		:= ''
Local cTipNFC	:= '' 
Local cEstVei   := '' 
Local nAliqICM	:= 0
Local cSeqIns	:= TMSSeqIns(M->DT6_FILDOC,M->DT6_DOC,M->DT6_SERIE)

If M->DT6_DOCTMS == StrZero( 6, Len( DT6->DT6_DOCTMS ) )	 //-- Devolucao
	cTipNFC := '1'
Else
	cTipNFC := Posicione('DTC',3,xFilial('DTC')+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE,'DTC_TIPNFC')
EndIf


//-- Busca o estado do veículo quando o lote possuir viagem vinculada  
DTP->(dbSetOrder(2))
If DTP->(MsSeek(xFilial('DTP')+DT6->DT6_FILORI+DT6->DT6_LOTNFC))
	If !Empty(DTP->DTP_VIAGEM)
		DTR->(dbSetOrder(1))
		If DTR->(MsSeek(xFilial('DTR')+DTP->DTP_FILORI+DTP->DTP_VIAGEM))
			DA3->(dbSetOrder(1))
			If DA3->(MsSeek(xFilial("DA3")+DTR->DTR_CODVEI))
				cEstVei := DA3->DA3_ESTPLA
			EndIf
		EndIf
	EndIf
EndIf

aRegra := TmsRegTrib(cDocTms,M->DT6_TIPFRE,cCodPas,M->DT6_CLIDEV,M->DT6_LOJDEV,M->DT6_CDRDES,.T.,cTipNFC,cSeqIns,cEstVei)

If	! Empty( aRegra )
	cTes := aRegra[ 1 ]
EndIf

nAliqICM := TmsCalcImp( M->DT6_CLIDEV, M->DT6_LOJDEV, cPrImp, 'CTR', 'TMSA500', cTes, 1, 0, 0, TamSX3('DT8_VALPAS')[2] )[3]

If	nAliqICM > 0
	nAliqICM := ((100 - nAliqICM)/100)
Else
	nAliqICM := 0
EndIf

Return( nAliqICM )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Frt³ Autor ³ Alex Egydio           ³ Data ³25.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Usado no 'complemento e devolucao' para recalcular o frete ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Frt(nOpcX)

Local aErrCal := {}
Local aFrtBkp := AClone(aFrtAux)
Local aContrt := {}
Local cNContr := M->DT6_NCONTR
Local cTabFre := M->DT6_TABFRE
Local cTipTab := M->DT6_TIPTAB
Local cSeqTab := M->DT6_SEQTAB
Local cTabAlt := ''
Local cTipAlt := ''
Local cTipNFC := '0'
Local lCliGen := .F.
Local lAjuAut := .F.
Local nCntFor := 0
Local nSeek      := 0
Local nVezes     := 0
Local nVlrFrt    := 0
Local nCntFrt    := 0
Local cCompEnt   := SuperGetMv('MV_COMPENT',,'')
Local aTipVei    := {}
Local cSeqIns    := ''
Local cCodPro    := Space(Len(SB1->B1_COD))
Local lExistPerf := DUO->(ColumnPos("DUO_TPCALC")) > 0
Static lTM500REE := ExistBlock("TM500REE")
Local cOrdem	:= '  '		//-- O cOrdem foi inicializado com 2 espacos para forcar o componente de Reentrega p/1a linha
Local cSeqAlt    := ''
Local aFreAlt    := {}
Local nSeekAlt   := 0
Local lTabAlt    := .F.
Local cExcTDA    := ""
Local cDEVTDA    := ""
Local cRemTDA    := ""
Local cDesTDA    := ""
Local cSeqDes    := ""
Local lFoundSA1  := .F.
Local aAreaAnt   := GetArea()
Local lInvOri    := DTC->(ColumnPos("DTP_INVORI")) > 0

If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

//-- Devolucao. Inverte o tipo de frete para pesquisar o contrato
If	cDocTms == StrZero(6,Len(cDocTms))
	If	! TmsA500DC5(M->DT6_SERVIC)
		Return( .F. )
	EndIf
	//-- Obtem dados do contrato
	If	! TmsA500Ctr(@aContrt,M->DT6_CLICAL,M->DT6_LOJCAL,M->DT6_SERVIC,M->DT6_TIPFRE,nOpcX)
		Return( .F. )
	EndIf
	cNContr := aContrt[1,1]
	cTabFre := aContrt[1,3]
	cTipTab := aContrt[1,4]
	cTabAlt := aContrt[1,15]
	cTipAlt := aContrt[1,16]
	lCliGen := aContrt[1,17]
	lAjuAut := aContrt[1,18]==StrZero(1,Len(DUO->DUO_AJUOBR))
	
	cDEVTDA := aContrt[1,28]
EndIf

//-- Obtem o tipo de veiculo
aTipVei := TMSA500TPV()

If	!( cDocTms $ "7;D" )
 	
 	dbSelectArea("DTC")
 	DTC->(dbSetOrder(3))
 	If (DTC->(MsSeek(xFilial("DTC")+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE+M->DT6_SERVIC+Posicione('DTC',3,xFilial('DTC')+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE,'DTC_CODPRO'))))
 	     cExcTDA  := DTC->DTC_EXCTDA
	     cSeqDes  := DTC->DTC_SQEDES
 	EndIf
    
    dbSelectArea("SA1")
	lFoundSA1 := StaticCall(TMSA200, TMSA200Cli, DT6->DT6_CLIREM, DT6->DT6_LOJREM) 
	If lFoundSA1    //posiciona na tabela SA1
		cRemTDA := SA1->A1_TDA	                    //-- 81 Rementente TEM TDA
	Else
		cRemTDA := ""  			                    //-- 81 Rementente TEM TDA
	EndIf 
	
	dbSelectArea("DUL")
	If !Empty(cSeqDes)
		DUL->(dbSetOrder(2))
		If DUL->(MSseek(xFilial("DUL") + DT6->DT6_CLIDES + DT6->DT6_LOJDES + cSeqDes))
			cDesTDA := DUL->DUL_TDA	                //-- 82 Destinatario TEM TDA - Sequencia
		Else
			cDesTDA := ""                           //-- 82 Destinatario TEM TDA - Sequencia
		EndIf
	Else
	    lFoundSA1 := StaticCall(TMSA200, TMSA200Cli, M->DT6_CLIDES, DT6->DT6_LOJDES) 
	    // 
		If lFoundSA1 //posiciona na tabela SA1
			cRemTDA := SA1->A1_TDA                  //-- 81 Rementente TEM TDA
		Else
			cRemTDA := ""                           //-- 82 Rementente TEM TDA
		EndIf
	EndIf
	
	dbSelectArea("DUD")
	DUD->(DbSetOrder(1))
	If DUD->(MsSeek(xFilial("DUD")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE+cFilAnt))
		cTipTra := DUD->DUD_TIPTRA
		cSerTms := DUD->DUD_SERTMS
	EndIf
	DUD->(DbCloseArea())
	
	RESTAREA(aAreaAnt)
   
	aFrete := {}
	aFrete := TMSCalFret(cTabFre,cTipTab,@cSeqTab,M->DT6_CDRORI,M->DT6_CDRCAL,M->DT6_CLICAL,M->DT6_LOJCAL,;
				Posicione('DTC',3,xFilial('DTC')+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE,'DTC_CODPRO'),M->DT6_SERVIC,cSerTms,cTipTra,;
				cNContr,@aErrCal,,M->DT6_VALMER,M->DT6_PESO,M->DT6_PESOM3,,M->DT6_QTDVOL,,M->DT6_BASSEG,M->DT6_METRO3,,,,,,lCliGen,;
				lAjuAut,,M->DT6_QTDUNI,,,,aValInf,aTipVei,cDocTms,,,,,,,,,,,,,,,cExcTDA,cDEVTDA,cDesTDA,cRemTDA,,,,,,,,,;
				DT6->DT6_CODNEG,,,,,(lInvOri .And. Posicione('DTC',3,xFilial('DTC')+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE,'DTC_INVORI') == '1'),,,,,,If(Len(aContrt[1])>=53,aContrt[ 1, 53 ],''))					
Else //-- Calcula Reentrega
	If Len(aFrete) > 0
		cSerTMS := StrZero(3,Len(DT6->DT6_SERTMS))
		nSeek   := Ascan(aFrete,{|x| x[3] == 'TF'})
		If aPerfil[53] == '2' //-- Considera valor do frete sem imposto
			nVlrFrt := aFrete[nSeek,2]
		Else
			nVlrFrt := aFrete[nSeek,6]
		EndIf
		For nCntFrt := 1 to Len(aFrete)
			If (nSeek := aScan(aDesconto,{|x| x[6] == aFrete[nCntFrt][3]}) ) > 0 
				aDesconto[nSeek,2] := aFrete[nCntFrt,2] 
			ElseIf aFrete[nCntFrt,2] > 0
				AAdd(aDesconto,{aFrete[nCntFrt,1],aFrete[nCntFrt,2],0,0,0,aFrete[nCntFrt,3] })
			EndIf
			aFrete[nCntFrt,2]  := 0
		Next
		If aPerfil[31] == 0 //-- Nao existe valor fixo de reentrega
			nVezes := If((DT6->DT6_REENTR + 1)<=3,(DT6->DT6_REENTR + 1),4)
			M->DT6_PERDCO := aPerfil[nVezes + 25]
			TMS500Perg(.f.)
			If Len(aPerfil) > 0 .AND. lExistPerf .AND. aPerfil[54] == "2" //Cálculo "Por Trecho"
				nDescon := 100 //considera 100% do valor do frete para o trecho
			Else	
				nDescon := M->DT6_PERDCO
			Endif	
			nValDig := (nVlrFrt * nDescon / 100)
		Else
			nValDig := aPerfil[31]
			nDescon := nValDig / nVlrFrt * 100
		EndIf
	
		// verifica se o valor digitado seja menor que o estipulado o sistema calcula o valor minimo e despreza o digitado
		If aPerfil[48] > 0 .And. nValDig < aPerfil[48] // Valor Minimo de Cobranca
			nValDig := aPerfil[48]
			nDescon := nValDig / nVlrFrt * 100
		EndIf
	
		// verifica se o valor digitado seja maior que o estipulado o sistema calcula o valor maximo e despreza o digitado
		If aPerfil[30] > 0 .And. nValDig > aPerfil[30] // Valor Maximo de Cobranca
			nValDig := aPerfil[30]
			nDescon := nValDig / nVlrFrt * 100
		EndIf
	
		nSeek := Ascan(aFrete,{|x| x[3] == cCompEnt})
		If nSeek == 0 .And. nOpcX == 5 ///Reentrega
			nSeek := Ascan(aFrtAux,{|x| x[3] == cCompEnt})
			If nSeek > 0
				AAdd(aFrete,{Posicione('DT3',1,xFilial('DT3') + GetMV('MV_COMPENT'),'DT3_DESCRI'),0,GetMV('MV_COMPENT'),'',0,0,'','','','','',cOrdem,0,0, StrZero(2,Len(DT8->DT8_CALMIN)),'','','','','', 0 })
				ASort(aFrete,,,{|x,y| x[12] + x[3] < y[12] + y[3] })
			EndIf
		EndIf			
		If nSeek > 0
			aFrete[nSeek,2]  := nValDig
			aFrete[nSeek,7]  := Space(Len(DT8->DT8_CDRORI))
			aFrete[nSeek,8]  := Space(Len(DT8->DT8_CDRDES))
			aFrete[nSeek,12] := '00'
		EndIf
		nSeek := Ascan(aFrete,{|x| x[3] == 'TF' })
		If nSeek > 0
			aFrete[nSeek,2]  := nValDig
			aFrete[nSeek,12] := '00'
		EndIf
	EndIf
	If(lTM500REE)
	aDesc := ExecBlock('TM500REE',.F.,.F.,{aFrete})
		If ValType(aDesc) == "A"
			aFrete := aClone(aDesc)
		EndIf
	EndIf
EndIf

nSeek := Ascan( aFrete,{|x| x[3] == 'TF' })
If	cDocTms == StrZero(6,Len(cDocTms))
	If !Empty(cTabAlt)
		aFreAlt := {}
		aFreAlt := TMSCalFret(cTabAlt,cTipAlt,@cSeqAlt,M->DT6_CDRORI,M->DT6_CDRCAL,M->DT6_CLICAL,M->DT6_LOJCAL,;
		Posicione('DTC',3,xFilial('DTC')+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE,'DTC_CODPRO'),; 
		M->DT6_SERVIC,cSerTms,cTipTra,cNContr,@aErrCal,,M->DT6_VALMER,M->DT6_PESO,M->DT6_PESOM3,,M->DT6_QTDVOL,,;
		Iif(DT6->(FieldPos('DT6_BASSEG'))>0,M->DT6_BASSEG,0),Iif(DT6->(FieldPos('DT6_METRO3'))>0,M->DT6_METRO3,0),,,,,,lCliGen,lAjuAut,,;
		Iif(DT6->(FieldPos('DT6_QTDUNI'))>0,M->DT6_QTDUNI,0),,,,aValInf,aTipVei,cDocTms,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,;
		(lInvOri .And. Posicione('DTC',3,xFilial('DTC')+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE,'DTC_INVORI') == '1'),,,,,,If(Len(aContrt[1])>=53,aContrt[ 1, 53 ],''))
	
		nSeekAlt := Ascan( aFreAlt,{|x| x[3] == 'TF' })
	
		If	nSeekAlt >= 1 .And. aFreAlt[nSeekAlt,2] >= 1
			lTabAlt := .F.
			//-- Considera o maior valor obtido entre as tabelas de frete e alternativa.
			If aFreAlt[nSeekAlt,2] > aFrete[nSeek,2]
				aFrete   := {}
				aFrete   := aClone( aFreAlt )
				cTabFre  := cTabAlt
				cTipTab  := cTipAlt
				cSeqTab  := cSeqAlt
				lTabAlt  := .T.
				nSeek := Ascan( aFrete,{|x| x[3] == 'TF' })
			EndIf
		EndIf
	EndIf
EndIf

If	nSeek <= 0 .Or. aFrete[nSeek,2] <= 0 .Or. nSeek != Len(aFrete) .Or. ! Empty(aErrCal)
	If	nSeek <= 0 .Or. aFrete[nSeek,2] <= 0
		AAdd(aErrCal,{STR0119,'00',''}) //"Valor do frete zerado"
	ElseIf nSeek != Len(aFrete)
		AAdd(aErrCal,{STR0120,'00',''}) //'Falha na linha totalizadora da composicao do frete'
	EndIf
    
	If	! Empty( aErrCal ) 
		TmsMsgErr( aErrCal,,lTM500Auto )
	EndIf

	aFrete := AClone(aFrtBkp)
	Return( .F. )
EndIf
M->DT6_SEQTAB := cSeqTab

If M->DT6_DOCTMS == StrZero( 6, Len( DT6->DT6_DOCTMS ) )	 //-- Devolucao
	cTipNFC := '1'
	cCodPro := DTC->DTC_CODPRO
Else
	cTipNFC := Posicione('DTC',3,xFilial('DTC')+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE,'DTC_TIPNFC')
	cCodPro := DTC->DTC_CODPRO
EndIf
cSeqIns := TMSSeqIns(M->DT6_FILDOC,M->DT6_DOC,M->DT6_SERIE)

TmsA040Imp(aFrete,M->DT6_CLIDEV,M->DT6_LOJDEV,cDocTms,M->DT6_TIPFRE,M->DT6_CDRCAL,.T.,,,Posicione("SA1",1,xFilial("SA1")+M->DT6_CLIDES+M->DT6_LOJDES,"A1_TIPO"),,M->DT6_CDRORI,,,M->DT6_CLIREM,M->DT6_LOJREM,M->DT6_CLIDES,M->DT6_LOJDES,,,cTipNFC,cCodPro,cSeqIns)
//-- Formato do vetor aDesconto
//-- aDesconto[01] = Descricao do componente
//-- aDesconto[02] = Valor original do componente com imposto
//-- aDesconto[03] = Valor do complemento
//-- aDesconto[04] = Valor do imposto
//-- aDesconto[05] = Valor + Imposto
//-- aDesconto[06] = Codigo do componente
For nCntFor := 1 To Len(aDesconto)
	nSeek := AScan(aFrete,{|x|x[3]==aDesconto[nCntFor,6]})
	If	nSeek > 0
		If nOpcX == 4 //Devolução
			aDesconto[nCntFor,2]:=aFrete[nSeek,2]
		Endif
		aDesconto[nCntFor,3]:=aFrete[nSeek,2]
		aDesconto[nCntFor,4]:=aFrete[nSeek,5]
		aDesconto[nCntFor,5]:=aFrete[nSeek,6]
	Else
		nSeek := AScan(aFrtAux,{|x|x[3]==aDesconto[nCntFor,6]})
		If	nSeek > 0
			AAdd(aFrete,AClone(aFrtAux[nSeek]))
			aFrete[Len(aFrete),2]:=0
			aFrete[Len(aFrete),5]:=0
			aFrete[Len(aFrete),6]:=0
			aDesconto[nCntFor,3]:=0
			aDesconto[nCntFor,4]:=0
			aDesconto[nCntFor,5]:=0
		EndIf
	EndIf
Next
//-- Forca a linha totalizadora para a ultima posicao do vetor aFrete
ASort(aFrete,,,{|x,y| x[12] + x[3] < y[12] + y[3] })
//-- Devolucao
If	cDocTms == StrZero(6,Len(cDocTms))
	//-- Desconsidere o calculo da funcao TmsA500vld
	lTabela := .T.

	nSeek	:= AScan(aFrete,{|x| x[3]=='TF' })
	If	nSeek > 0
		nValDig := aFrete[nSeek,6]
		If	Type('oValDco') == 'O'
			oValDco:Refresh()
		EndIf
	EndIf
	nSeek	:= AScan(aFrtAux,{|x| x[3]=='TF' })
	//-- Calcula o percentual
	If	nSeek > 0
		nDescon := (nValDig / aFrtAux[nSeek,6])*100
		If	Type('oPerDco') == 'O'
			oPerDco:Refresh()
		EndIf
	EndIf
EndIf

If	Type('oLbxEsp') == 'O'
	oLbxEsp:Refresh()
EndIf
If Type('oLbx') == 'O'
	//-- Apresenta a composicao do frete
	TmsViewFrt('9')
	oLbx:Refresh()
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Oco³ Autor ³ Eduardo de Souza      ³ Data ³ 03/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se existe ocorrencia de retorno de documento.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500Oco(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Serie do Documento                                 ³±±
±±³          ³ ExpC4 - Filial Origem                                      ³±±
±±³          ³ ExpC5 - Viagem do Documento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA500Oco(cFilDoc,cDocto,cSerie,cFilOri,cViagem)

Local cSeek     := ''
Local cQuery    := ''
Local cAliasQry := ''
Local lRet      := .F.
Local aAreaDUA  := DUA->(GetArea())

DUA->(DbSetOrder(4))
If DUA->(MsSeek(cSeek:= xFilial("DUA")+cFilDoc+cDocto+cSerie))
	While DUA->(!Eof()) .And. DUA->DUA_FILIAL + DUA->DUA_FILDOC + DUA->DUA_DOC + DUA->DUA_SERIE == cSeek
		DT2->(DbSetOrder(1))
		DT2->(MsSeek(xFilial("DT2")+DUA->DUA_CODOCO))
		If DT2->DT2_TIPOCO == StrZero(4,Len(DT2->DT2_TIPOCO)) .Or.;
		  (DT2->DT2_TIPOCO == StrZero(19,Len(DT2->DT2_TIPOCO)) .And. Iif( DUA->(ColumnPos("DUA_RECDEP")) > 0, DUA->DUA_RECDEP == '1',.f.)) .Or.; //-- Requisito Receitas/Despesas Ocorrências
		  (DT2->DT2_TIPOCO == StrZero(20,Len(DT2->DT2_TIPOCO)) .And. Iif( DUA->(ColumnPos("DUA_RECDEP")) > 0, DUA->DUA_RECDEP == '1',.f.)) .Or.; //-- Requisito Receitas/Despesas Ocorrências
		  (DT2->DT2_TIPOCO == StrZero(6,Len(DT2->DT2_TIPOCO)) .And. DT2->DT2_TIPPND == StrZero(4,Len(DT2->DT2_TIPPND)))
			lRet := .T.
		EndIf
		DUA->(DbSkip())
	EndDo
EndIf

If !lRet
	If !Empty(cFilOri) .And. !Empty(cViagem)
		cAliasQry := GetNextAlias()
		cQuery := " SELECT COUNT(DUA.DUA_FILIAL) QTDE "
		cQuery += "   FROM  " + RetSqlName("DUA") + " DUA "
		cQuery += "   JOIN  " + RetSqlName("DT2") + " DT2 "
		cQuery += "     ON  DUA.DUA_FILIAL = '" + xFilial("DUA") + "' "
		cQuery += "     AND DUA.DUA_FILORI = '" + cFilOri + "' "
		cQuery += "     AND DUA.DUA_VIAGEM = '" + cViagem + "' "
		cQuery += "     AND DUA.D_E_L_E_T_ = ' ' "
		cQuery += "     AND DT2.DT2_FILIAL = '" + xFilial("DT2") + "' "
		cQuery += "     AND DT2.DT2_CODOCO = DUA.DUA_CODOCO "
		cQuery += "     AND ((DT2.DT2_TIPOCO = '" + StrZero(4,Len(DT2->DT2_TIPOCO)) + "' "
		cQuery += "           OR (DT2.DT2_TIPOCO = '" + StrZero(6,Len(DT2->DT2_TIPOCO)) + "' "
		cQuery += "           AND DT2.DT2_TIPPND = '" + StrZero(4,Len(DT2->DT2_TIPPND)) + "')) "

		//-- Requisito Receitas/Despesas Ocorrências
		If DUA->(ColumnPos("DUA_RECDEP")) > 0
			cQuery += "           OR "
			cQuery += "           (( DT2.DT2_TIPOCO = '" + StrZero(19,Len(DT2->DT2_TIPOCO)) + "' "
			cQuery += "           OR DT2.DT2_TIPOCO = '" + StrZero(20,Len(DT2->DT2_TIPOCO)) + "') AND DUA.DUA_RECDEP = '1'))
		Else
			cQuery += " ) " 
		EndIf	

		cQuery += "     AND DT2.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		If (cAliasQry)->(!Eof()) .And. (cAliasQry)->QTDE > 0
			lRet := .T.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
EndIf

RestArea( aAreaDUA )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Tot³ Autor ³ Alex Egydio           ³ Data ³16.06.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo da composicao de frete                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Determina a acao do calculo                        ³±±
±±³          ³ ExpN1 = Valor digitado no complemento                      ³±±
±±³          ³ ExpN2 = Posicao do componente no qual foi digitado ExpN1   ³±±
±±³          ³ ExpN3 = Total do Frete na Reentrega e Devolucao            ³±±
±±³          ³ ExpN4 = Opcao de manutencao;                               ³±±
±±³          ³         4 = Devolucao                                      ³±±
±±³          ³         5 = Reentrega                                      ³±±
±±³          ³         6 = Devolucao                                      ³±±
±±³          ³        10 = Complemento de Imposto                         ³±±
±±³          ³ ExpC2 - Codigo do fornecedor                       ( AWB ) ³±±
±±³          ³ ExpC3 - Loja   do fornecedor                       ( AWB ) ³±±
±±³          ³ ExpC4 - Filial de destino da ultima regiao da rota ( AWB ) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA500Tot(cAcao,nValor,nItem,nTFrete,nOpcx,cCodCia,cLojCia,cFilDes,lFretInf,cCodProd)

Local cComp  	:= ''
Local nCntFor	:= 0
Local nSeek		:= 0
Local cTipoNF	:= ''  //-- 'N' (Docto. Normal) / 'I' (Complemento de Imposto)
Local cTipNFC	:= '0' //-- Tipo da Nota Fiscal : '0' (Normal) / '1' (Devoluncao) / '2' (SubContratacao)
Local cSeqIns	:= ''
Local cEstVei	:= ''
Local cCodPro	:= Space(Len(SB1->B1_COD))
Local lCamposRat:= DT8->(ColumnPos("DT8_PERRAT")) > 0
Local lIdentDoc := DTC->(ColumnPos("DTC_DOCTMS")) > 0
Local lBasCal   := DUO->(ColumnPos("DUO_BASCAL")) > 0
Local nTotFrt   := 0
Local nDifArred := 0
Local nDecVal   := TamSX3("DT8_VALPAS")[2]
Local aPerfil	:= {}
Local lAgrImp   := .T. 

DEFAULT nValor 	:= 0
DEFAULT nItem  	:= 0
DEFAULT nTFrete	:= 0
DEFAULT cCodCia	:= ''
DEFAULT cLojCia	:= ''
DEFAULT cFilDes	:= ''
DEFAULT lFretInf:= .F.
DEFAULT cCodProd:= ''

If nOpcx == 10 // Complemento de Imposto
	cTipoNF := 'I'
EndIf

If Type("cDocTms") == "U"
    cDocTms := ''
EndIf

//-- Formato do vetor aDesconto
//-- aDesconto[01] = Descricao do componente
//-- aDesconto[02] = Valor original do componente com imposto
//-- aDesconto[03] = Valor do complemento
//-- aDesconto[04] = Valor do imposto
//-- aDesconto[05] = Valor + Imposto
//-- aDesconto[06] = Codigo do componente
//-- Transfere composicao do vetor aDesconto p/ aFrete. Utilizado no Complemento

If lBasCal .And. nOpcx == 6 //-- Complemento
	aPerfil := TmsPerfil(DT6->DT6_CLICAL,DT6->DT6_LOJCAL,,,DT6->DT6_CLIREM,DT6->DT6_LOJREM,DT6->DT6_CLIDES,DT6->DT6_LOJDES)
	If aPerfil[66] == "2" //--> Base Calc. 2-Sem Imposto
		lAgrImp  := .F. 
	EndIf
EndIf  

If	cAcao == '1'
	For nCntFor := 1 To Len(aDesconto)
		nSeek := AScan(aFrete,{|x|x[3]==aDesconto[nCntFor,6]})
		If	aDesconto[nCntFor,6]!='TF' .And. nSeek > 0
			If lFretInf .And. nOpcx != 15  //Se for Frete Informado altera apenas o componente digitado. 
			 	If nCntFor == nItem
			 		aFrete[nSeek,2] := nValor				
			 	EndIf			
			Else
				If	nCntFor != nItem
					If nOpcx != 15 .And. lAgrImp
						aFrete[nSeek,2] := aDesconto[nCntFor,5]
					Else
						aFrete[nSeek,2] := aDesconto[nCntFor,3]
					EndIf
				Else
					aFrete[nSeek,2] := nValor
				EndIf
			EndIf 	
			aFrete[nSeek,5] := 0
			aFrete[nSeek,6] := 0
			If lCamposRat .And. Len(aFrete[nSeek]) >=21
				aFrete[nSeek,21] := 0
			EndIf
		EndIf
	Next
//-- Atualiza a composicao com o valor digitado. Utilizado na Reentrega e Devolucao
ElseIf cAcao == '2'
	If nOpcx == 10
		cComp := GetMV('MV_COMPIMP')
	Else
		cComp := GetMV('MV_COMPENT')
	EndIf
	//-- Preenche o vetor q apresenta a composicao de frete
	For nCntFor := 1 To Len(aFrete)
		If nOpcx == 5 .Or. nOpcx == 10
			//-- Reentrega
			If	aFrete[nCntFor,3] == cComp
				//-- Se nao digitou valor proposto e digitou percentual, aplicar o percentual sobre o valor total do frete
				If nValDig <= 0
					nValDig := NoRound( nTFrete * nDescon, nDecVal)
				EndIf
				//-- Qdo. for Reentrega e estiver posicionado no componente definido para reentrega adiciona o valor digitado
				aFrete[nCntFor,2] := nValDig
			Else
				aFrete[nCntFor,2] := 0
				aFrete[nCntFor,2] := 0
				aFrete[nCntFor,2] := 0
			EndIf
		Else
			//-- Devolucao
			aFrete[nCntFor,2] := NoRound( aFrete[ nCntFor, 6 ] * nDescon, nDecVal)
		EndIf

		If 	aFrete[nCntFor,3] <> "TF"
			nTotFrt += aFrete[nCntFor,2]
		EndIf
	Next
	//-- Corrige Arredondamento
	If Type("nValDig") != "U" .And. nValDig > 0 .And. nValDig > nTotFrt
		nDifArred := nValDig - nTotFrt
		aEval(aFrete, {|aFrtCmp| Iif( nDifArred > 0 .And. aFrtCmp[2] > 0 .And. aFrtCmp[3] <> "TF", ;
		  							  (aFrtCmp[2] += 1/(10^nDecVal), nDifArred -= 1/(10^nDecVal)),;
										Nil) })
	EndIf
//-- Calcula impostos e obtem o valor do frete sem imposto
ElseIf cAcao == '3' 
	If	Empty(cCodCia)
		If !lFretInf
			If nOpcx == 6 .or. nOpcx == 13 //--Complemento ou Substituição
				//-- Busca o estado do veículo quando o lote possuir viagem vinculada  
				DTP->(dbSetOrder(2))
				If DTP->(MsSeek(xFilial('DTP')+DT6->DT6_FILORI+DT6->DT6_LOTNFC))
					If !Empty(DTP->DTP_VIAGEM)
						DTR->(dbSetOrder(1))
						If DTR->(MsSeek(xFilial('DTR')+DTP->DTP_FILORI+DTP->DTP_VIAGEM))
							DA3->(dbSetOrder(1))
							If DA3->(MsSeek(xFilial("DA3")+DTR->DTR_CODVEI))
								cEstVei := DA3->DA3_ESTPLA
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			If M->DT6_DOCTMS == StrZero( 6, Len( DT6->DT6_DOCTMS ) )	 //-- Devolucao
				cTipNFC := '1'
				cCodPro := DTC->DTC_CODPRO
			Else
				cTipNFC := Posicione('DTC',3,xFilial('DTC')+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE,'DTC_TIPNFC')
				cCodPro := DTC->DTC_CODPRO
				If Empty(cTipNFC)
					cTipNFC  := '0'
				EndIf
			EndIf

			cSeqIns := TMSSeqIns(M->DT6_FILDOC,M->DT6_DOC,M->DT6_SERIE)
			//-- Impostos obtidos no frete a receber
			TmsA040Imp(aFrete,M->DT6_CLIDEV,M->DT6_LOJDEV,cDocTms,M->DT6_TIPFRE,M->DT6_CDRCAL,.T.,,,Posicione("SA1",1,xFilial("SA1")+M->DT6_CLIDES+M->DT6_LOJDES,"A1_TIPO"),lAgrImp,M->DT6_CDRORI,,,M->DT6_CLIREM,M->DT6_LOJREM,M->DT6_CLIDES,M->DT6_LOJDES,cTipoNF,,cTipNFC,cCodPro,cSeqIns,,cEstVei)
  		Else 

			AEval(aCols,{|a,n| cCodPro := Iif(!GDDeleted(n),GDFieldGet('DTC_CODPRO', n),cCodPro) } )
			cTipNFC := M->DTC_TIPNFC
			If Empty(cCodPro)
				cCodPro := cCodProd
			EndIf
  		    
			//-- Impostos obtidos para calculo do frete informado           
  		 	If lIdentDoc .And. IsInCallStack("TMSA050") .And. nOpcx == 15 .And. Empty(cDocTms)
  		 		cDocTms := TMSTipDoc(M->DTC_CDRORI,M->DTC_CDRCAL)
  		 	ElseIf lIdentDoc .And. nOpcX <> 15 .And. Empty(cDocTms)
  		 		cDocTms := TMSTipDoc(M->DT6_CDRORI,M->DT6_CDRCAL)
  		 	Else
  		 		cDocTms := Posicione('DC5',1,xFilial('DC5') + M->DTC_SERVIC,'DC5_DOCTMS')
				If Empty (cDocTms)
				   	cDocTms := M->DTC_DOCTMS
				EndIf
  		    EndIf
  		    TmsA040Imp(aFrete,M->DTC_CLIDEV,M->DTC_LOJDEV,cDocTms,M->DTC_TIPFRE,M->DTC_CDRCAL,.T.,,,Posicione("SA1",1,xFilial("SA1")+M->DTC_CLIDES+M->DTC_LOJDES,"A1_TIPO"),,M->DTC_CDRORI,,,M->DTC_CLIREM,M->DTC_LOJREM,M->DTC_CLIDES,M->DTC_LOJDES,cTipoNF,,cTipNFC,cCodPro,cSeqIns,,)
  		EndIf
	Else
		//-- Impostos obtidos no frete a pagar ( AWB )
		TmsA040Imp(aFrete,cCodCia,cLojCia,cDocTms,'','',.T.,,cFilDes,Posicione('SA2',1,xFilial('SA2')+cCodCia+cLojCia,'A2_TIPO'),.T.)
	EndIf
//-- Transfere a composicao do vetor aFrete p/ aDesconto
ElseIf cAcao == '4'
	//-- Formato do vetor aDesconto
	//-- aDesconto[01] = Descricao do componente
	//-- aDesconto[02] = Valor original do componente com imposto
	//-- aDesconto[03] = Valor do complemento
	//-- aDesconto[04] = Valor do imposto
	//-- aDesconto[05] = Valor + Imposto
	//-- aDesconto[06] = Codigo do componente
	For nCntFor := 1 To Len(aDesconto)
		nSeek := AScan(aFrete,{|x|x[3]==aDesconto[nCntFor,6]})
		If	nSeek > 0
			aDesconto[nCntFor,3]:=aFrete[nSeek,2]
			aDesconto[nCntFor,4]:=aFrete[nSeek,5]
			aDesconto[nCntFor,5]:=aFrete[nSeek,6]
		EndIf
	Next
//-- Compatibiliza os Vetores aFrete e aDesconto
ElseIf cAcao == '5'
	//-- Atualiza vetor aFrete
	For nCntFor := 1 To Len(aDesconto)
		nSeek := AScan(aFrete,{|x|x[3]==aDesconto[nCntFor,6]})
		If	nSeek == 0
			DT3->(DbSetOrder(1))
			DT3->(MsSeek(xFilial('DT3') + aDesconto[nCntFor,6]))
			AAdd(aFrete,{DT3->DT3_DESCRI,0,aDesconto[nCntFor,6],0,0,0,Space(Len(DT6->DT6_CDRORI)),;
							 Space(Len(DT6->DT6_CDRDES)),Space(Len(DT0->DT0_TABFRE)),;
							 Space(Len(DT0->DT0_TIPTAB)),Space(Len(DVC->DVC_SEQTAB)),"00",0,0, StrZero(2,Len(DT8->DT8_CALMIN)),DT3->DT3_FAIXA, '', '', '', '', 0, '', '' })
		EndIf
	Next nCntFor
	aFrete := aSort(aFrete,,,{|x,y| x[3] < y[3]})
	//-- Atualiza vetor aDesconto
	For nCntFor := 1 To Len(aFrete)
		nSeek := AScan(aDesconto,{|x|x[6]==aFrete[nCntFor,3]})
		If	nSeek == 0
			DT3->(DbSetOrder(1))
			DT3->(MsSeek(xFilial('DT3') + aFrete[nCntFor,3]))
			AAdd(aDesconto,{DT3->DT3_DESCRI,0,0,0,0,aFrete[nCntFor,3],,,0,0})
		EndIf
	Next nCntFor
	aDesconto := aSort(aDesconto,,,{|x,y| x[6] < y[6]})
EndIf 

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Ctr³ Autor ³ Alex Egydio           ³ Data ³27.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Obtem dados do contrato                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Vetor contendo dados do contrato @                 ³±±
±±³          ³ ExpC1 - Cliente de calculo                                 ³±±
±±³          ³ ExpC2 - Loja                                               ³±±
±±³          ³ ExpC3 - Codigo do servico                                  ³±±
±±³          ³ ExpC4 - Tipo de frete                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Ctr(aContrt,cCliCal,cLojCal,cSrv,cTipFre,nOpcX)
//-- Devolucao. Inverte o tipo de frete para pesquisar o contrato
If	cDocTms == StrZero(6,Len(cDocTms))
	If	cTipFre == StrZero(1,Len(cTipFre))
		cTipFre := StrZero(2,Len(cTipFre))
	Else
		cTipFre := StrZero(1,Len(cTipFre))
	EndIf
EndIf
//-- Obtem dados do contrato                                                     
If nOpcX == 6 .or. nOpcX == 5//Reentrega utiliza mesmo contrato do documento original.
	aContrt := TMSContrat(cCliCal,cLojCal,DT6->DT6_DATEMI,cSrv,.F.,cTipFre,,,,,,,,,,,,,,,.T.,DT6->DT6_CODNEG,DT6->DT6_NCONTR)
Else                                                                                                     
	aContrt := TMSContrat(cCliCal,cLojCal,,cSrv,.F.,cTipFre,,,,,,,,,,,,,,,,DT6->DT6_CODNEG)
EndIf
If Empty( aContrt )
	Help( ' ', 1, 'TMSA20005',,STR0026 + cCliCal + ' / ' + cLojCal + STR0123 +TMSRetCbx('AAM_TIPFRE',cTipFre),5,11) //-- Contrato nao encontrado (AAM).###' / Tp.Frete: '###"Cliente : "
	Return( .F. )
EndIf
//-- Se nao encontrou a tabela de frete
If	Empty( aContrt[ 1, 3 ] )
	Help( ' ', 1, 'TMSA20022',,STR0026 + Iif( aContrt[ 1, 17 ], STR0121, STR0122 + cCliCal + '/' + cLojCal + STR0123 +TMSRetCbx('AAM_TIPFRE',cTipFre) ) + STR0023 + cSrv,4,1)		//-- Tabela de frete nao especificada no contrato (DUX).###"Cliente : "###" generico "###"/loja: "###" / Tp.Frete: "###' Servico : '
	Return( .F. )
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500DC5³ Autor ³ Alex Egydio           ³ Data ³27.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Posiciona o servico                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do servico                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500DC5(cSrv)

Local lRet := .T.

DC5->(DbSetOrder(1))
If	! DC5->(MsSeek(xFilial('DC5') + cSrv))
	Help( ' ', 1, 'TMSA50011',,STR0023 + cSrv,4,1) //-- Servico nao encontrado. (DC5) //'Servico: '
	lRet := .F.
EndIf
//-- Essa funcao deve deixar o registro posicionado no servico enviado como parametro.
//-- Nao use a funcao restarea

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Lot³ Autor ³ Alex Egydio           ³ Data ³20.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lote de Entrada de Notas Fiscais (Rotina automatica)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Numero do lote de entrada de N.F do cliente        ³±±
±±³          ³ ExpL1 - .T. = Exclui o lote                                ³±±
±±³          ³         .F. = Se o nr.do lote passado como parametro nao   ³±±
±±³          ³         for localizado no DTP, gera um novo nr. de lote    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Lot(cLotNfc,lCancela,nOpcX)

Local aCab		:= {}
Local cRet		:= ''
Local lTMSCTe	:= SuperGetMv( "MV_TMSCTE", .F., .F. )
Local lTM500LOT	:= ExistBlock("TM500LOT")	//-- Permite adicionar botoes.
Local cRetLot	:= ""
Local cAltTip	:= "3"
Local aRotAnt   := aRotina

DEFAULT lCancela	:= .F.
DEFAULT nOpcX		:= 0

If Type("lMsErroAuto") == "U"
	Private lMsErroAuto := .F. //-- Utilizada na funcao MsExecAuto()
EndIf
If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

If lTM500LOT
	cRetLot := ExecBlock('TM500LOT',.F.,.F.,{nOpcx,cLotNfc})
	If ValType(cRetLot) == "C" .And. !Empty(cRetLot)
		cAltTip := cRetLot
	EndIf
EndIf

// Complemento -> Manter o mesmo tipo do lote original
If nOpcX == 6
	DTP->(DbSetOrder(2)) //DTP_FILIAL+DTP_FILORI+DTP_LOTNFC
	If	DTP->(MsSeek(xFilial('DTP')+cFilAnt+cLotNfc))
		cAltTip := DTP->DTP_TIPLOT
	EndIf
EndIf

If	lCancela
	DTP->(DbSetOrder(2)) //DTP_FILIAL+DTP_FILORI+DTP_LOTNFC
	If	DTP->(MsSeek(xFilial('DTP')+cFilAnt+cLotNfc))
		AAdd(aCab,{'DTP_FILORI',cFilAnt,Nil})
		AAdd(aCab,{'DTP_LOTNFC',cLotNfc,Nil})
		MsExecAuto({|x,y|TmsA170(x,y)},aCab,5)
	EndIf
Else
	DTP->(DbSetOrder(2)) //DTP_FILIAL+DTP_FILORI+DTP_LOTNFC
	If	!DTP->(MsSeek(xFilial('DTP')+cFilAnt+cLotNfc)) .Or.;
	     DTP->DTP_STATUS != StrZero(3,Len(DTP->DTP_STATUS)) .Or.; //-- Nao estiver calculado
		 (nOpcX == 6 .And. M->DT6_TIPTRA =="4")
		AAdd(aCab,{'DTP_QTDLOT',1,Nil})
		AAdd(aCab,{'DTP_QTDDIG',1,Nil})
		If lTMSCTe
			Aadd(aCab,{'DTP_TIPLOT',cAltTip,NIL}) // Lote Eletronico
		EndIf
		AAdd(aCab,{'DTP_STATUS','3',Nil})	//-- Status 3 Calculado
		MsExecAuto({|x,y|cRet := TmsA170(x,y)},aCab,3)
		If lMsErroAuto .And. !lTM500Auto
			MostraErro()
		Else
			cLotNfc := cRet
		EndIf
	ElseIf lTMSCTe
		If	DTP->(MsSeek(xFilial('DTP')+cFilAnt+cLotNfc))
			If DTP->DTP_TIPLOT == '3' .Or. DTP->DTP_TIPLOT == '4'
				AAdd(aCab,{'DTP_QTDLOT',1,Nil})
				AAdd(aCab,{'DTP_QTDDIG',1,Nil})
				Aadd(aCab,{'DTP_TIPLOT',cAltTip,NIL})
				AAdd(aCab,{'DTP_STATUS','3',Nil})	//-- Status 3 Calculado

				MsExecAuto({|x,y|cRet := TmsA170(x,y)},aCab,3)

				If lMsErroAuto .And. !lTM500Auto
					MostraErro()
				Else
					cLotNfc := cRet
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

cLoteCte := cLotNfc

aRotina := aRotAnt

Return( cLotNfc )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500VTit³ Autor ³ Eduardo de Souza     ³ Data ³ 19/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza dados da fatura                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500VTit(ExpA1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo a fatura                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA500VTit(aArraySE1)

Local cTipo := AllTrim(GetMv("MV_TIPFAT",, "")) // Tipo da Fatura.

SE1->(DbSetOrder(1))

If SE1->(MsSeek(xFilial("SE1")+aArraySE1[1]+aArraySE1[2]+aArraySE1[3]+aArraySE1[4]))
	If AllTrim(SE1->E1_TIPO) == cTipo
		DbSelectArea("SE1")
		Fa281Visua("SE1")
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA500AWB ³ Autor ³ Eduardo de Souza     ³ Data ³ 08/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna a AWB do documento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500AWB()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500AWB()

Local cAliasNew  := GetNextAlias()
Local cQuery     := ""
Local bBloco     := {||.F.}
Local lRet       := .F.

SaveInter() //-- Salva Area

cQuery := " SELECT DTX_NUMAWB , DTX_DIGAWB , DTX_CODCIA , DTX_LOJCIA"
cQuery += "   FROM " + RetSQLName("DUD") + " DUD "
cQuery += "   JOIN " + RetSQLName("DTX") + " DTX "
cQuery += "     ON DTX_FILIAL = '" + xFilial("DTX") + "' "
cQuery += "     AND DTX_FILMAN = DUD_FILMAN "
cQuery += "     AND DTX_MANIFE = DUD_MANIFE "
cQuery += "     AND DTX_SERMAN = DUD_SERMAN "
cQuery += "     AND DTX.D_E_L_E_T_ = ' ' "
cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD")  + "' "
cQuery += "     AND DUD_FILDOC = '" + DT6->DT6_FILDOC + "' "
cQuery += "     AND DUD_DOC    = '" + DT6->DT6_DOC    + "' "
cQuery += "     AND DUD_SERIE  = '" + DT6->DT6_SERIE  + "' "
cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

While (cAliasNew)->(!Eof())
	DTV->(DbSetOrder(1))
	bBloco := { || DTV->(MsSeek(xFilial("DTV")+(cAliasNew)->DTX_NUMAWB+(cAliasNew)->DTX_CODCIA+(cAliasNew)->DTX_LOJCIA )) }
	bBloco := { || DTV->(MsSeek(xFilial("DTV")+(cAliasNew)->DTX_NUMAWB+(cAliasNew)->DTX_DIGAWB+(cAliasNew)->DTX_CODCIA+(cAliasNew)->DTX_LOJCIA )) }
	If Eval(bBloco)
		lRet:=.T.
		TMSA320Mnt("DTV",DTV->(Recno()), 2)
	EndIf
	(cAliasNew)->(dbSkip())
EndDo

If !lRet
	Help("",1,"TMSA50048") //"AWB nao encontrada"
EndIf

(cAliasNew)->(DbCloseArea())

RestInter() //-- Restaura Area

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMSStatCol ³ Autor ³ Eduardo de Souza     ³ Data ³ 15/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida o status da solicitacao de coleta                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSStatCol()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSStatCol(cFilDoc,cDoc,cSerie,cStatus)

Local lRet := .F.

If cSerie == 'COL' .And. ;
	cStatus == Alltrim(Posicione("DT5",4,xFilial("DT5")+cFilDoc+cDoc+cSerie,"DT5_STATUS"))
	lRet := .T.
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Com³ Autor ³Patricia A. Salomao    ³ Data ³15.08.05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Visualiza os Documentos Complementares                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA500Comp()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa500Comp(cFilDoc,cDoc,cSerie)

Local cQuery   := ''
Local aDocs    := {}
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local aArea    := GetArea()
Local aAreaDT6 := DT6->(GetArea())
Local aSize    := MsAdvSize(.T.)
Local aButtons := {{'RELATORIO'	,{|| TMA500DocC(aDocs[oDocs:nAt,1],aDocs[oDocs:nAt,2],aDocs[oDocs:nAt,3]) } ,STR0104, STR0073} } //-- 'Visualiza Documento' 
Local oDlgOcor
Local oDocs
Private cAliasQry:= GetNextAlias()  //-- Variavel utilizada pela TMSValField()

If Type("aSetKey") == "U"
   Private aSetKey := {}
EndIf

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

CursorWait()

cQuery := " SELECT DT6_FILDCO,DT6_DOCDCO,DT6_SERDCO,DT6_FILDOC,DT6_DOC,DT6_SERIE,DT6_DOCTMS,DT6_DATEMI,DT6_HOREMI "
cQuery += " FROM " + RetSqlName("DT6")
cQuery += " WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "   AND DT6_FILDCO = '" + cFilDoc+ "' "
cQuery += "   AND DT6_DOCDCO = '" + cDoc   + "' "
cQuery += "   AND DT6_SERDCO = '" + cSerie + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

TCSetField(cAliasQry,"DT6_DATEMI" ,"D",TamSx3("DT6_DATEMI")[1],TamSx3("DT6_DATEMI")[2])

Do While !(cAliasQry)->(Eof())
	AAdd(aDocs,{(cAliasQry)->DT6_FILDOC,(cAliasQry)->DT6_DOC,(cAliasQry)->DT6_SERIE,(cAliasQry)->DT6_DATEMI,;
				(cAliasQry)->DT6_HOREMI,TmsValField("(cAliasQry)->DT6_DOCTMS",.F.)})
	(cAliasQry)->(dbSkip())
EndDo

CursorArrow()

If Len(aDocs) > 0


	aDocs := aSort(aDocs,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] })

	aObjects := {}
	AAdd( aObjects, { 100, 100 , .T., .T.,.T. } )

	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 } 
	aPosObj := MsObjSize( aInfo, aObjects) 

	DEFINE MSDIALOG oDlgDocs FROM aSize[7], 000 TO aSize[6],aSize[5] TITLE STR0102 OF oMainWnd PIXEL   //"Documentos Complementares

		@ aPosObj[1,1], aPosObj[1,2] LISTBOX oDocs VAR cVar Fields HEADER	RetTitle("DT6_FILDCO"),;
																			RetTitle("DT6_DOCDCO"),;
																			RetTitle("DT6_SERDCO"),;
																			RetTitle("DT6_DATEMI"),;
																			RetTitle("DT6_HOREMI"),;
																			RetTitle("DT6_DESDOC") ;
																			SIZE  aPosObj[1,3], aPosObj[1,4] OF oDlgOcor PIXEL
		oDocs:SetArray(aDocs)
		oDocs:bLine:={ ||{aDocs[oDocs:nAT,1],;
									aDocs[oDocs:nAT,2],;
									aDocs[oDocs:nAT,3],;
									aDocs[oDocs:nAT,4],;
									TransForm(aDocs[oDocs:nAT,5],PesqPict("DT6","DT6_HOREMI")) ,;
									aDocs[oDocs:nAT,6]}}
		oDocs:Refresh()

	ACTIVATE MSDIALOG  oDlgDocs ON INIT EnchoiceBar( oDlgDocs, { || nOpca := 1,oDlgDocs:End()}, {||oDlgDocs:End()},,aButtons)	
Else
	Help( " ", 1, "TMSA50056") //"Nao existe Documentos Complementares para este Documento"
EndIf

(cAliasQry)->( DbCloseArea() )

RestArea(aAreaDT6)
RestArea(aArea)

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMS500DocC³ Autor ³Patricia A. Salomao    ³ Data ³15.08.05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Visualiza o Documento Complementar                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA500DocC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1- Filial Documento                                     ³±±
±±³          ³ExpC2- No. do Documento                                     ³±±
±±³          ³ExpC3- Serie do Documento                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA500DocC(cFilDoc,cDoc,cSerie)

Local aArea     := GetArea()
Local aAreaDT6  := DT6->(GetArea())
Local lExibImp  := SuperGetMv("MV_TMSCFIS",,.T.)

Default cFilDoc := ''
Default cDoc    := ''
Default cSerie  := ''

// Verifica se só mostrará a aba de composição do frete quando vindo da consulta de Tracking
If IsInCallStack("TMSC020")
	lExibImp := SuperGetMv("MV_TMSCTRA",,.T.)
EndIf
//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

//-- Salva Area
SaveInter()

DT6->(dbSetOrder(1))
If DT6->(MsSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie))
	cCadastro := STR0001
	If lExibImp
		TMSA500Mnt("DT6",DT6->(Recno()),2)
	Else
		FWExecView (, "TMSC030" , 1 , ,{|| .F. }, , , , , , , ) 
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaDT6)
RestInter() //-- Restaura Area

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Ref³ Autor ³ Valdemar Roberto      ³ Data ³10.01.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera documentos de refaturamento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA500Ref()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expc1 - Filial de Origem do Lote                           ³±±
±±³          ³ Expc2 - Numero do Lote                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500Ref(cFilOri,cLotNfc)
Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObjH  := {}
Local aButtons  := {}
Local aHDocto   := {}
Local aTam      := {}
Local aAlter    := {}
Local aCab      := {}
Local aItens    := {}
Local aPerfil   := {}
Local aParQry   := {}
Local aAreaDTC  := {}
Local aDocImp   := {}
Local cLbx1     := ""
Local cNumCmp   := ""
Local cOcoBRef  := ""
Local cCmpRef   := ""
Local cCliRem   := ""
Local cLojRem   := ""
Local cCdrOri   := GetMV("MV_CDRORI")
Local cMotivo   := GetMV("MV_OBSREFA")
Local lRet      := .T.
Local lUsaNfs   := SuperGetMv('MV_TMSUNFS',,.F.)  //-- Filial utiliza nota fiscal ?
Local nCont     := 0
Local nSemImp   := 0
Local nComImp   := 0
Local nOpca     := 0
Local lEnd      := .F.
Local oDlgEsp
Local lProcRef	:= .T.

Private cDocTms	  := ''
Private cSerie	  := ''
Private cPrdImp	  := ''
Private cSerTms   := ''
Private cTipTra   := ''
Private cLoteAut  := ''
Private cTipMan   := '1'
Private aDocRef   := {}
Private aHeader   := {}
Private aCols     := {}
Private aValInf   := {}
Private aCtrRef   := {}
Private oNoMarked := LoadBitmap(GetResources(),'LBNO')
Private oMarked   := LoadBitmap(GetResources(),'LBOK')
Private oLbx1

Default cFilOri := ""
Default cLotNfc := ""

If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

DTP->(DbSetOrder(2)) //DTP_FILIAL+DTP_FILORI+DTP_LOTNFC
If	DTP->(MsSeek(xFilial('DTP')+cFilOri+cLotNfc))
	If lRet
		If DTP->DTP_STATUS != '2'
			Help(" ",1,"TMSA50064",,,5,1) //-- Status do lote diferente de digitado.
			lRet := .F.
		EndIf
	EndIf
	DTC->(DbSetOrder(1))
	If	!DTC->(MsSeek(xFilial('DTC')+cFilOri+cLotNfc)) //-- Existem doctos no lote?
		Help(" ",1,"TMSA50065",,,5,1) //-- Nenhum documento foi digitado no lote.
		lRet := .F.
	EndIf
	If lRet
		cCliRem := DTC->DTC_CLIREM
		cLojRem := DTC->DTC_LOJREM
		aPerfil := TmsPerfil(DTC->DTC_CLIDEV,DTC->DTC_LOJDEV,,,DTC->DTC_CLIREM,DTC->DTC_LOJREM,DTC->DTC_CLIDES,DTC->DTC_LOJDES)
		If aPerfil[34] == "2" // Cliente nao paga refaturamento?
			Help(" ",1,"TMSA50066",,DT6->DT6_CLIDEV + "/" + DT6->DT6_LOJDEV,5,1 ) //-- Cliente não paga refaturamento. Verifique o perfil do cliente :
			lRet := .F.
		EndIf
	EndIf
	If lRet
		cOcoBRef := Left(GetMV("MV_OCOBREF")+Space(Len(DUA->DUA_CODOCO)),Len(DUA->DUA_CODOCO))
		If Empty(cOcoBRef)
			Help(" ",1,"TMSA50067",,,5,1) //-- Ocorrencia de baixa por refaturamento não está definido nos parametros.
			lRet := .F.
		EndIf
	EndIf
	If lRet
		cCmpRef := GetMV("MV_COMPREF")
		If Empty(cCmpRef)
			Help(" ",1,"TMSA50068",,,5,1) //-- Componente de refaturamento não está definido nos parametros.
			lRet := .F.
		EndIf
	EndIf
	If lRet
		DT3->(dbSetOrder(1))
		If !(DT3->(MsSeek(xFilial("DT3") + cCmpRef)))
			Help(" ",1,"TMSA50069",,,5,1) //-- Componente de refaturamento não está cadastrado.
			lRet := .F.
		EndIf
	EndIf
Else
	lRet := .F.
EndIf

If lRet
	//-- Carrega query do list
	AAdd(aParQry,DTC->DTC_CLIREM)
	AAdd(aParQry,DTC->DTC_LOJREM)
	aDocRef := TmsA500Qry(1,aParQry)

	If Len(aDocRef) == 0 //-- Nao achou nenhum documento
		Help(" ",1,"TMSA50070",,,5,1) //-- Nenhum documento foi localizado.
		lRet := .F.
	EndIf

	If lRet
		AEval(aDocRef,{|x| nComImp += x[10]})
		If nComImp < aPerfil[36] // Valor dos documentos originais menor que o valor minimo?
			Help(" ",1,"TMSA50071",,,5,1) //-- Valor dos documentos originais menor que o mínimo cadastrado no perfil.
			lRet := .F.
		EndIf
	EndIf

	If lRet
		//-- Carrega Header do List
		AAdd(aHDocto,' ' )
		AAdd(aHDocto,FWX3TITULO('DT6_FILDOC'))
		AAdd(aHDocto,FWX3TITULO('DT6_DOC'))
		AAdd(aHDocto,FWX3TITULO('DT6_SERIE'))
		AAdd(aHDocto,FWX3TITULO('DT6_DATEMI'))
		AAdd(aHDocto,FWX3TITULO('DT6_PESO'))
		AAdd(aHDocto,FWX3TITULO('DT6_VALMER'))
		AAdd(aHDocto,FWX3TITULO('DT6_QTDVOL'))
		AAdd(aHDocto,STR0127)
		AAdd(aHDocto,STR0128)
		AAdd(aHDocto,FWX3TITULO('DT6_DOCTMS'))

		//-- Carrega Header da Getdados
		aTam := TamSX3("DTC_CLIDES")
		AAdd(aHeader,{RetTitle("DTC_CLIDES"),"DTC_CLIDES",PesqPict("DTC","DTC_CLIDES",aTam[1]),aTam[1],aTam[2],"",USADO,"C","DTC"," "})
		aTam := TamSX3("DTC_LOJDES")
		AAdd(aHeader,{RetTitle("DTC_LOJDES"),"DTC_LOJDES",PesqPict("DTC","DTC_LOJDES",aTam[1]),aTam[1],aTam[2],"",USADO,"C","DTC"," "})
		aTam := TamSX3("DTC_NOMDES")
		AAdd(aHeader,{RetTitle("DTC_NOMDES"),"DTC_NOMDES",PesqPict("DTC","DTC_NOMDES",aTam[1]),aTam[1],aTam[2],"",USADO,"C","DTC"," "})
		aTam := TamSX3("DTC_NUMNFC")
		AAdd(aHeader,{RetTitle("DTC_NUMNFC"),"DTC_NUMNFC",PesqPict("DTC","DTC_NUMNFC",aTam[1]),aTam[1],aTam[2],"",USADO,"C","DTC"," "})
		aTam := TamSX3("DTC_SERNFC")
		AAdd(aHeader,{RetTitle("DTC_SERNFC"),"DTC_SERNFC",PesqPict("DTC","DTC_SERNFC",aTam[1]),aTam[1],aTam[2],"",USADO,"C","DTC"," "})
		aTam := TamSX3("DTC_PESO")
		AAdd(aHeader,{RetTitle("DTC_PESO")  ,"DTC_PESO"  ,PesqPict("DTC","DTC_PESO"  ,aTam[1]),aTam[1],aTam[2],"",USADO,"C","DTC"," "})
		aTam := TamSX3("DTC_VALOR")
		AAdd(aHeader,{RetTitle("DTC_VALOR") ,"DTC_VALOR" ,PesqPict("DTC","DTC_VALOR" ,aTam[1]),aTam[1],aTam[2],"",USADO,"C","DTC"," "})
		aTam := TamSX3("DTC_QTDVOL")
		AAdd(aHeader,{RetTitle("DTC_QTDVOL"),"DTC_QTDVOL",PesqPict("DTC","DTC_QTDVOL",aTam[1]),aTam[1],aTam[2],"",USADO,"C","DTC"," "})
		aTam := TamSX3("DT6_VALTOT")
		AAdd(aHeader,{STR0129               ,"VALFRETE"  ,PesqPict("DT6","DT6_VALTOT",aTam[1]),aTam[1],aTam[2],"",USADO,"C","DT6"," "})
		AAdd (aAlter,"VALFRETE")

		//-- Carrega query da Getdados
		AAdd(aParQry,cFilOri)
		AAdd(aParQry,cLotNfc)
		aCols := TmsA500Qry(2,aParQry)

		//-- Monta a Getdados e o List
		aSize  := MsAdvSize(.T.)
		aObjects	:= {}
		AAdd(aObjects,{100,50,.T.,.T.,.T.})							//-- Horizontal superior
		AAdd(aObjects,{100,50,.T.,.T.,.T.})							//-- Horizontal inferior
		aInfo	:= {aSize[1],aSize[2],aSize[3],aSize[4],5,5}
		aPosObjH	:= MsObjSize(aInfo,aObjects,.T.,.F.)

		aPosObjH[1][1] := 17
		aPosObjH[1][2] := 5
		aPosObjH[1][3] := 498
		aPosObjH[1][4] := 130

		aPosObjH[2][1] := 152
		aPosObjH[2][2] := 5
		aPosObjH[2][3] := 290
		aPosObjH[2][4] := 503

		AAdd(aButtons,{'PESQUISA',{||TmsA500Psq(1)},STR0002}) //Pesquisar

		DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL

			// List
			@ aPosObjH[1,1], aPosObjH[1,2] LISTBOX oLbx1 VAR cLbx1 FIELDS HEADER aHDocto[1],aHDocto[2],aHDocto[3],aHDocto[4],aHDocto[5],;
			aHDocto[6],aHDocto[7],aHDocto[8],aHDocto[9],aHDocto[10],aHDocto[11]  SIZE aPosObjH[1,3], aPosObjH[1,4] OF oDlgEsp ON DBLCLICK (TmsA500Tck(aPerfil[35],@nSemImp)) PIXEL
			oLbx1:SetArray(aDocRef)
			// Monta o bLine do listbox
			TmsA500bLi()

			// Get Dados
			o1Get:= MSGetDados():New( aPosObjH[2,1], aPosObjH[2,2], aPosObjH[2,3], aPosObjH[2,4],4,"TMSA500LinOk",'TMSA500TudOK',,.F.,aAlter,,,Len(aCols),,,,Nil)

		ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| IIF(o1Get:TudoOk(),(nOpcA:=1,oDlgEsp:End()),)},{||oDlgEsp:End()},,aButtons)

		If	nOpca == 1
			cLoteAut := cLotNfc
			//-- Numero da composicao
			DT6->(DbSetOrder(9))
			While lRet
				cNumCmp := GetSX8Num('DT6','DT6_NUMCMP',,9)
				If DT6->(!MsSeek(xFilial("DT6")+cNumCmp))
					lRet := .F.
				EndIf
				ConfirmSX8()
			EndDo

			For nCont := 1 to Len(aDocRef)
				If aDocRef[nCont,1]
					DT6->(DbSetOrder(1))
					If DT6->(MsSeek(xFilial('DT6')+aDocRef[nCont,2]+aDocRef[nCont,3]+aDocRef[nCont,4]))
						RegToMemory('DT6',.F.)
						Exit
					EndIf
				EndIf
			Next nCont

			Begin Transaction

			//-- Gera Novos Documentos
			For nCont := 1 to Len(aCols)
				//-- Le Nota Fiscal do Cliente
				DTC->(DbSetOrder(5))
				If DTC->(MsSeek(xFilial('DTC')+cCliRem+cLojRem+aCols[nCont,4]+aCols[nCont,5]))
					//-- Troca dados do documento original
					M->DT6_QTDVOL := aCols[nCont,8]
					M->DT6_VOLORI := aCols[nCont,8]
					M->DT6_PESO   := aCols[nCont,6]
					M->DT6_PESCOB := aCols[nCont,6]
					M->DT6_VALMER := aCols[nCont,7]
					M->DT6_CDRORI := cCdrOri
					M->DT6_FILORI := cFilAnt
					M->DT6_LOTNFC := cLotNfc
					M->DT6_NUMCMP := cNumCmp
					M->DT6_CLIDES := DTC->DTC_CLIDES
					M->DT6_LOJDES := DTC->DTC_LOJDES
					M->DT6_FIMP   := StrZero(0,Len(DT6->DT6_FIMP)) // Nao Impresso

					//-- Define tipo de documento
					If lUsaNfs .And. cCdrOri == AllTrim(DTC->DTC_CDRDES)
						cDocTms := "5"
					Else
						cDocTms := "2"
					EndIf

					TmsA500TOk(.F.,8,"",DTC->DTC_SERVIC)

					//-- Monta Vetor da Composicao do Frete
					aFrete := {}
					AAdd(aFrete,{AllTrim(DT3->DT3_DESCRI),aCols[nCont,9],DT3->DT3_CODPAS,'',0,aCols[nCont,9],Space(Len(cCdrOri)),Space(Len(SA1->A1_CDRDES)),'','','','00',0,0})
					AAdd(aFrete,{'Total do Frete'        ,aCols[nCont,9],'TF'           ,'',0,aCols[nCont,9],Space(Len(cCdrOri)),Space(Len(SA1->A1_CDRDES)),'','','','ZZ',0,0})
					aAreaDTC := DTC->(GetArea())
					aCtrRef  := TmsA500Doc(@lEnd,4,.T.)
					RestArea(aAreaDTC)

					If Len(aCtrRef) > 0
						//-- Atualiza Nota Fiscal
						RecLock('DTC',.F.)
						DTC->DTC_FILDOC := cFilAnt
						DTC->DTC_DOC    := aCtrRef[1]
						DTC->DTC_SERIE  := aCtrRef[2]
						DTC->(MsUnLock())
						If nCont == 1
							AAdd(aDocImp,{ STR0130 + " " + DTP->DTP_LOTNFC,,}) //"Favor imprimir os documentos do lote "
						EndIf

						cMotivo += DT6->DT6_FILDOC+"-"+DT6->DT6_DOC+"-"+DT6->DT6_SERIE + ", "
					Else
						lProcRef := .F.
					EndIf
				EndIf
			Next nCont

			If lProcRef
				//-- Atualiza Documentos Originais
				For nCont := 1 to Len(aDocRef)
					If aDocRef[nCont,1]
						DT6->(DbSetOrder(1))
						If	DT6->(MsSeek(xFilial('DT6')+aDocRef[nCont,2]+aDocRef[nCont,3]+aDocRef[nCont,4]))

							//-- Cabecalho da Ocorrencia
							AAdd(aCab,{"DUA_FILORI",Space(Len(DUA->DUA_FILORI)),Nil})
							AAdd(aCab,{"DUA_VIAGEM",Space(Len(DUA->DUA_VIAGEM)),Nil})

							//-- Itens da Ocorrencia
							AAdd(aItens,{	{"DUA_SEQOCO",StrZero(1,Len(DUA->DUA_SEQOCO)),Nil},;
											{"DUA_DATOCO",dDataBase                       ,Nil},;
											{"DUA_HOROCO",Left(StrTran(Time(),":",""),4) ,Nil},;
											{"DUA_CODOCO",cOcoBRef                        ,Nil},;
											{"DUA_MOTIVO",cMotivo                         ,Nil},;
											{"DUA_RECEBE",""                              ,Nil},;
											{"DUA_SERTMS",StrZero(3,Len(DUA->DUA_SERTMS)),Nil},;
											{"DUA_FILDOC",DT6->DT6_FILDOC                 ,Nil},;
											{"DUA_DOC"   ,DT6->DT6_DOC                    ,Nil},;
											{"DUA_SERIE" ,DT6->DT6_SERIE                  ,Nil},;
											{"DUA_QTDOCO",DT6->DT6_QTDVOL                 ,Nil},;
											{"DUA_PESOCO",DT6->DT6_PESO                   ,Nil}})

							//-- Inclusao da Ocorrencia
							MsExecAuto({|x,y,z|Tmsa360(x,y,z)},aCab,aItens,{},3)

							//-- Atualiza Documento Original
							RecLock('DT6',.F.)
							DT6->DT6_FLOREF := cFilOri
							DT6->DT6_LOTREF := cLotNfc
							DT6->(MsUnLock())
						EndIf
					EndIf
				Next nCont

				If Len(cMotivo) > 2
					cMotivo := Left(cMotivo,(Len(cMotivo)-2))
				EndIf

				//-- Atualiza Lote
				RecLock('DTP',.F.)
				DTP->DTP_STATUS := StrZero(3 ,Len(DTP->DTP_STATUS)) // Calculado
				DTP->(MsUnLock())
			EndIf
			End Transaction

		EndIf
	EndIf
EndIf

If !Empty(aDocImp)
	TmsMsgErr(aDocImp,,lTM500Auto)
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500LinOK ³ Autor ³ Valdemar Roberto      ³ Data ³11.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Consistencia da Linha digitada.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA500LinOK()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Logico                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA500                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500LinOK()
Local lRet := .T.

If Empty(GDFieldGet('ValFrete',n))
	Help(" ",1,"TMSA50072",,,5,1) //-- O valor do frete está zerado.
	lRet := .F.
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500TudOK ³ Autor ³ Valdemar Roberto      ³ Data ³11.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Consistencia da digitadacao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA500TudOK()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Logico                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA500                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500TudOK()
Local lRet    := .T.
Local nPesDoc := 0
Local nPesCol := 0
Local nValDoc := 0
Local nValCol := 0
Local nVolDoc := 0
Local nVolCol := 0
Local nCont   := 0

If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

lRet := TMSA500LinOk()

If lRet
	If AScan(aDocRef,{|x|x[1] == .T.}) == 0
		Help(" ",1,"TMSA50073",,,5,1) //-- Nenhum documento foi selecionado.
		lRet := .F.
	EndIf
EndIf

If lRet
	AEval(aCols,{|x| nPesCol += x[6]})
	AEval(aCols,{|x| nValCol += x[7]})
	AEval(aCols,{|x| nVolCol += x[8]})

	For nCont := 1 to Len(aDocRef)
		If aDocRef[nCont,1]
			nPesDoc += aDocRef[nCont,6]
			nValDoc += aDocRef[nCont,7]
			nVolDoc += aDocRef[nCont,8]
		EndIf
	Next nCont

	If nPesCol <> nPesDoc
		If !lTM500Auto .And. !MsgYesNo(STR0124)
			lRet := .F.
		EndIf
	EndIf
	If lRet
		If nValCol <> nValDoc
			If !lTM500Auto .And. !MsgYesNo(STR0125)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet
		If nVolCol <> nVolDoc
			If !lTM500Auto .And. !MsgYesNo(STR0126)
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Tck³ Autor ³ Valdemar Roberto      ³ Data ³10.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera documentos de refaturamento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA500Tck()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500Tck(nPerRef,nSemImp)
Local nRateio   := 0
Local nCont     := 0

Default nPerRef := 0
Default nSemImp := 0

aDocRef[oLbx1:nAT,1] := !aDocRef[oLbx1:nAT,1]

If aDocRef[oLbx1:nAT,1]
	nSemImp += aDocRef[oLbx1:nAT,9]
Else
	nSemImp -= aDocRef[oLbx1:nAT,9]
EndIf

nRateio := ((nSemImp * nPerRef /100) / Len(aCols))

For nCont := 1 to Len(aCols)
	aCols[nCont,9] := nRateio
Next nCont

oLbx1:Refresh()
o1Get:Refresh()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500bLi³ Autor ³ Valdemar Roberto      ³ Data ³10.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza o bLine dos objetos listbox                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA500bLi()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500bLi()
oLbx1:bLine	:= { || { Iif(aDocRef[oLbx1:nAT,1],oMarked,oNoMarked),;
							 aDocRef[oLbx1:nAT,2],;
							 aDocRef[oLbx1:nAT,3],;
							 aDocRef[oLbx1:nAT,4],;
							 aDocRef[oLbx1:nAT,5],;
							 Transform(aDocRef[oLbx1:nAT,6],PesqPict('DT6','DT6_PESO'  )),;
							 Transform(aDocRef[oLbx1:nAT,7],PesqPict('DT6','DT6_VALMER')),;
							 Transform(aDocRef[oLbx1:nAT,8],PesqPict('DT6','DT6_QTDVOL')),;
							 Transform(aDocRef[oLbx1:nAT,9],PesqPict('DT6','DT6_VALFRE')),;
							 Transform(aDocRef[oLbx1:nAT,10],PesqPict('DT6','DT6_VALTOT')),;
							 aDocRef[oLbx1:nAT,11] } }

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Exc³ Autor ³ Valdemar Roberto      ³ Data ³10.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui Lote de NF de Cliente (Refaturamento)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA500Exc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Filial de Origem do Lote de NF do Cliente          ³±±
±±³          ³ cExp2 - Lote de NF do Cliente                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500Exc(cFilOri,cLotNfc)
Local cAliasQry := ""
Local cQuery    := ""
Local cOcoBRef  := Left(GetMV("MV_OCOBREF")+Space(Len(DUA->DUA_CODOCO)),Len(DUA->DUA_CODOCO))

Default cFilOri := ""
Default cLotNfc := ""

cAliasQry := GetNextAlias()
cQuery := "SELECT DT6_FILDOC,DT6_DOC,DT6_SERIE "
cQuery += "  FROM "+RetSqlName("DT6")+ " DT6 "
cQuery += " WHERE DT6_FILIAL = '"+xFilial("DT6")+"'"
cQuery += "   AND DT6_FLOREF = '"+cFilOri+"'"
cQuery += "   AND DT6_LOTREF = '"+cLotNfc+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

While (cAliasQry)->(!Eof())
	DT6->(DbSetOrder(1))
	If DT6->(MsSeek(xFilial("DT6")+(cAliasQry)->(DT6_FILDOC+DT6_DOC+DT6_SERIE)))
		RecLock('DT6',.F.)
		DT6->DT6_DATENT := CtoD("  /  /  ")
		DT6->DT6_STATUS := StrZero(5,Len(DT6->DT6_STATUS)) // Chegada Final
		DT6->DT6_FLOREF := Space(Len(DT6->DT6_FLOREF))
		DT6->DT6_LOTREF := Space(Len(DT6->DT6_LOTREF))
		MsUnLock()
	EndIf
	DUA->(DbSetOrder(3))
	If DUA->(MsSeek(xFilial("DUA")+cOcoBRef+(cAliasQry)->(DT6_FILDOC+DT6_DOC+DT6_SERIE)))
		RecLock('DUA',.F.)
		DUA->(DbDelete())
		MsUnLock()
	EndIf
	(cAliasQry)->(DbSkip())
EndDo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Qry³ Autor ³ Valdemar Roberto      ³ Data ³18.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera querys de refaturamento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA500Qry(ExpN1,ExpA1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Rotina                                             ³±±
±±³          ³ ExpA1 = Array com Parametros para as Querys                ³±±
±±³          ³         [1] - Codigo do Remetente no DTC                   ³±±
±±³          ³         [2] - Loja do Remetente no DTC                     ³±±
±±³          ³         [3] - Filial do Lote de Refaturamento              ³±±
±±³          ³         [4] - Lote de Refaturamento                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500Qry(nRot,aParQry)
Local aQuery    := {}
Local cAliasQry := ""
Local cQuery    := ""

Default nRot    := 0
Default aParQry := {}

If nRot == 1
	//-- Carrega Query do List
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DT6_FILDOC,DT6_DOC,DT6_SERIE,DT6_DATEMI,DT6_PESO,DT6_VALMER,DT6_QTDVOL,DT6_VALFRE,DT6_VALTOT,DT6_DOCTMS"
	cQuery += "  FROM "+RetSqlName("DT6")+" DT6"
	cQuery += " WHERE DT6_FILIAL  = '"+xFilial("DT6")+"'"
	cQuery += "   AND DT6_CLIREM  = '"+aParQry[1]+"'"
	cQuery += "   AND DT6_LOJREM  = '"+aParQry[2]+"'"
	cQuery += "   AND DT6_FILDES  = '"+cFilAnt+"'"
	cQuery += "   AND DT6_STATUS  = '"+StrZero(5,Len(DT6->DT6_STATUS))+"'"
	cQuery += "   AND DT6_TIPFRE	= '"+StrZero(1,Len(DT6->DT6_TIPFRE))+"'"
	cQuery += "   AND DT6.D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	TCSetField(cAliasQry,"DT6_DATEMI","D",8,0)
	TCSetField(cAliasQry,"DT6_PESO"  ,"N",TamSx3("DT6_PESO")[1]  ,TamSx3("DT6_PESO")[2])
	TCSetField(cAliasQry,"DT6_VALMER","N",TamSx3("DT6_VALMER")[1],TamSx3("DT6_VALMER")[2])
	TCSetField(cAliasQry,"DT6_QTDVOL","N",TamSx3("DT6_QTDVOL")[1],TamSx3("DT6_QTDVOL")[2])
	TCSetField(cAliasQry,"DT6_VALFRE","N",TamSx3("DT6_VALFRE")[1],TamSx3("DT6_VALFRE")[2])
	TCSetField(cAliasQry,"DT6_VALTOT","N",TamSx3("DT6_VALTOT")[1],TamSx3("DT6_VALTOT")[2])
	While (cAliasQry)->(!Eof())
		cDocTMS := (cAliasQry)->DT6_DOCTMS
		AAdd(aQuery,{.F.,;
						(cAliasQry)->DT6_FILDOC,;
						(cAliasQry)->DT6_DOC,;
						(cAliasQry)->DT6_SERIE,;
						(cAliasQry)->DT6_DATEMI,;
						(cAliasQry)->DT6_PESO,;
						(cAliasQry)->DT6_VALMER,;
						(cAliasQry)->DT6_QTDVOL,;
						(cAliasQry)->DT6_VALFRE,;
						(cAliasQry)->DT6_VALTOT,;
						TmsValField('cDocTMS',.F.),;
						.F.})
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	dbSelectArea("DT6")
ElseIf nRot == 2
	//-- Carrega Query da Getdados
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DTC_CLIDES,DTC_LOJDES,A1_NOME,DTC_NUMNFC,DTC_SERNFC,DTC_PESO,DTC_VALOR,DTC_QTDVOL"
	cQuery += "  FROM "+RetSqlName("DTC")+" DTC"
	cQuery += "  JOIN "+RetSqlName("SA1")+" SA1"
	cQuery += "    ON  A1_FILIAL      = '"+xFilial("SA1")+"'"
	cQuery += "   AND  A1_COD         = DTC_CLIDES"
	cQuery += "   AND  A1_LOJA        = DTC_LOJDES"
	cQuery += "   AND SA1.D_E_L_E_T_  = ' '"
	cQuery += " WHERE DTC_FILIAL      = '"+xFilial("DTC")+"'"
	cQuery += "   AND DTC_FILORI      = '"+aParQry[3]+"'"
	cQuery += "   AND DTC_LOTNFC      = '"+aParQry[4]+"'"
	cQuery += "   AND DTC.D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	TCSetField(cAliasQry,"DTC_PESO"  ,"N",TamSx3("DTC_PESO")[1]  ,TamSx3("DTC_PESO")[2])
	TCSetField(cAliasQry,"DTC_VALOR" ,"N",TamSx3("DTC_VALOR")[1] ,TamSx3("DTC_VALOR")[2])
	TCSetField(cAliasQry,"DTC_QTDVOL","N",TamSx3("DTC_QTDVOL")[1],TamSx3("DTC_QTDVOL")[2])
	While (cAliasQry)->(!Eof())
		AAdd(aQuery,{(cAliasQry)->DTC_CLIDES,;
						(cAliasQry)->DTC_LOJDES,;
						(cAliasQry)->A1_NOME,;
						(cAliasQry)->DTC_NUMNFC,;
						(cAliasQry)->DTC_SERNFC,;
						(cAliasQry)->DTC_PESO,;
						(cAliasQry)->DTC_VALOR,;
						(cAliasQry)->DTC_QTDVOL,;
						0,;
						.F.})
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	dbSelectArea("DT6")
EndIf

Return( aQuery )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Psq³ Autor ³ Valdemar Roberto      ³ Data ³01.06.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa documentos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA500Psq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Acao da pesquisa.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Psq(cAcao)
Local aCbx		:= {}
Local cCampo	:= ""
Local cOrd		:= ""
Local lSeek		:= .F.
Local nOrdem	:= 1
Local nSeek		:= 0
Local oCbx
Local oDlg
Local oPsqGet

Default cAcao  := 0

cCampo := AllTrim(FWX3TITULO('DT6_FILDOC'))+' + '+AllTrim(FWX3TITULO('DT6_DOC'))+' + '+AllTrim(FWX3TITULO('DT6_SERIE'))
AAdd(aCbx,cCampo)

cCampo := Space(40)

DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0002		//Pesquisar

@ 05,05 COMBOBOX oCbx VAR cOrd ITEMS aCbx SIZE 206,36 PIXEL OF oDlg ON CHANGE nOrdem := oCbx:nAt

@ 22,05 MSGET oPsqGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek := .T.,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If cAcao == 1 //-- Refaturamento
	If	lSeek
		cCampo := AllTrim(cCampo)
		If nOrdem == 1
			//-- Fil.Docto + Docto + Serie
			ASort(aDocRef,,,{|x,y| x[2] + x[3] + x[4] < y[2] + y[3] + y[4]})
			nSeek := Ascan(aDocRef,{|x| PadR(x[2] + x[3] + x[4], Len(cCampo)) == cCampo})
		EndIf
	EndIf
	If	nSeek > 0
		oLbx1:nAT := nSeek
		oLbx1:Refresh()
	EndIf
	oLbx1:SetFocus()
Else //-- Armazenagem
	If	lSeek
		cCampo := AllTrim(cCampo)
		If nOrdem == 1
			//-- Fil.Docto + Docto + Serie
			ASort(aCols,,,{|x,y| x[3] + x[4] + x[5] < y[3] + y[4] + y[5]})
			nSeek := Ascan(aCols,{|x| PadR(x[3] + x[4] + x[5], Len(cCampo)) == cCampo})
		EndIf
	EndIf
	If	nSeek > 0
		n := nSeek
		oGetD:oBrowse:nAt := nSeek
		oGetD:oBrowse:Refresh(.T.)
	EndIf
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Arm ³ Autor ³ Valdemar Roberto     ³ Data ³ 21/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica Pendencia na Armazenagem e Gera Documento de      ³±±
±±³          ³ Armazenagem e Devolucao, se selecionados.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500Arm()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Arm()
Local oDlg
Local cAliasQry := ""
Local cQuery    := ""
Local cOcoArm   := SuperGetMv('MV_OCORARM',,'')
Local cDocArm   := SuperGetMv('MV_TPDCARM',,'')   //-- Quais doctos geram armazenagem
Local cOcoQry   := ""
Local cDocQry   := ""
Local aHlpPor01 := {"Parametro MV_OCORARM não cadastrado..."}
Local aHlpIng01 := {"Parameter MV_OCORARM not registered..."}
Local aHlpEsp01 := {"Parametro MV_OCORARM no cregistrado..."}
Local aHlpPor02 := {"Nenhum documento foi localizado !!!"}
Local aHlpIng02 := {"No document found !!!"}
Local aHlpEsp02 := {"¡No se localizo ningun documento !!!"}
Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aAlter    := {}
Local aButtons  := {}
Local aTam      := {}
Local aLoteAut  := {}
Local aDocImp   := {}
Local nCont     := 0
Local nOpca     := 0
Local nSeqDoc   := 0
Local nQtdDoc   := 0
Local nSeek     := 0
Local lAlianca  := TMSAlianca() //-- Indica se utiliza Alianca
Local aRetPE    :={}

Local aCoors    := FWGetDialogSize(oMainWnd)

Private aHeader  := {}
Private aCols    := {}
Private aFrete   := {}
Private cSerie   := ''
Private cPrdImp  := ''
Private cSerTms  := ''
Private cTipTra  := ''
Private cLoteAut := ''
Private cTipMan  := '1'

//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If !TMSAVerAge("1",DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,,,,,,,,"2",.T.,.T.)
	Return .F.
EndIf

//Estes PutHelp nao estao no inicio do programa pois se referem ao processo de armazenagem, e existe uma rotina
//no TMSA500 que chama diretamente o TMSA500ARM, sem passar pelo TMSA500MNT.
PutHelp("PTMSA50083",aHlpPor01,aHlpIng01,aHlpEsp01,.F.)
PutHelp("PTMSA50084",aHlpPor02,aHlpIng02,aHlpEsp02,.F.)

If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

//-- ExecBlock TM500OCO
//-- Ponto               : Apos obter as ocorrencias dos parametros MV_OCORREE e MV_OCORARM
//-- Parametros Enviados : Array com a seguinte informacao:
//--                       PARAMIXB[01] = Codigo das ocorrencias que geram armazenagem.
//--                       PARAMIXB[02] = Codigo das ocorrencias que geram reentrega.
//--
//-- Retorno Esperado    : Array no seguinte formato:
//--                       aRetPE[01] = Codigo das ocorrencias que geram armazenagem.
//--                       aRetPE[02] = Codigo das ocorrencias que geram reentrega.
If ExistBlock('TM500OCO')
	aRetPE:= ExecBlock("TM500OCO",.F.,.F., {cOcoarm,''})
	If !Empty(aRetPE) .And. len(aRetPE) > 1
		If !Empty(aRetPE[1])
			cOcoarm:=aRetPE[1]
		EndIf
	EndIf
EndIf

If Empty(cOcoArm)
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help(" ",1,"TMSA50083")	//-- "Parametro MV_OCORARM não cadastrado..."
	Return( Nil )
EndIf

//-- Carrega Header da Getdados
aTam := TamSX3("DT6_QTDVOL")
AAdd(aHeader,{STR0135               ,"SEQUENCIA" ,PesqPict("DT6","DT6_QTDVOL",aTam[1]),aTam[1],aTam[2],"",USADO,"C","DT6"," "})
aTam := TamSX3("DT6_TPACAO")
AAdd(aHeader,{RetTitle("DT6_TPACAO"),"DT6_TPACAO",PesqPict("DT6","DT6_TPACAO",aTam[1]),aTam[1],aTam[2],"",USADO,"C","DT6"," "})
aTam := TamSX3("DT6_FILDOC")
AAdd(aHeader,{RetTitle("DT6_FILDOC"),"DT6_FILDOC",PesqPict("DT6","DT6_FILDOC",aTam[1]),aTam[1],aTam[2],"",USADO,"C","DT6"," "})
aTam := TamSX3("DT6_DOC")
AAdd(aHeader,{RetTitle("DT6_DOC")   ,"DT6_DOC"   ,PesqPict("DT6","DT6_DOC"   ,aTam[1]),aTam[1],aTam[2],"",USADO,"C","DT6"," "})
aTam := TamSX3("DT6_SERIE")	
AAdd(aHeader,{RetTitle("DT6_SERIE") ,"DT6_SERIE" ,PesqPict("DT6","DT6_SERIE" ,aTam[1]),aTam[1],aTam[2],"",USADO,"C","DT6"," "})
aTam := TamSX3("A1_NOME")
AAdd(aHeader,{STR0136               ,"NOMEDEV"   ,PesqPict("SA1","A1_NOME"   ,aTam[1]),aTam[1],aTam[2],"",USADO,"C","SA1"," "})
aTam := TamSX3("DT6_QTDVOL")
AAdd(aHeader,{STR0137               ,"DIASARM"   ,PesqPict("DT6","DT6_QTDVOL",aTam[1]),aTam[1],aTam[2],"",USADO,"C","DT6"," "})
aTam := TamSX3("DT6_DOCTMS")
AAdd(aHeader,{RetTitle("DT6_DOCTMS"),"DT6_DOCTMS",PesqPict("DT6","DT6_DOCTMS",aTam[1]),aTam[1],aTam[2],"",USADO,"C","DT6"," "})

AAdd (aAlter,"DT6_TPACAO")

//-- Ocorrencias que geram armazenagem
cOcoQry += "("
While !Empty(cOcoArm)
	cOcoQry += "'"
	cOcoQry += Left(cOcoArm,Len(DUA->DUA_CODOCO))
	cOcoQry += "'"
	cOcoArm := Substr(cOcoArm,(Len(DUA->DUA_CODOCO)+2))
	If !Empty(cOcoArm)
		cOcoQry += ","
	EndIf
EndDo
cOcoQry += ")"

//-- Documentos que geram armazenagem
cDocQry += "("
While !Empty(cDocArm)
	cDocQry += "'"
	cDocQry += Left(cDocArm,Len(DT6->DT6_DOCTMS))
	cDocQry += "'"
	cDocArm := Substr(cDocArm,(Len(DT6->DT6_DOCTMS)+2))
	If !Empty(cDocArm)
		cDocQry += ","
	EndIf
EndDo
cDocQry += ")"

//-- Carrega Query da Getdados
aCols     := {}
cAliasQry := GetNextAlias()
cQuery := "SELECT DUA_DATOCO,DUA_HOROCO,DUA_CODOCO,DT61.DT6_FILDOC,DT61.DT6_DOC,DT61.DT6_SERIE,DT61.DT6_CLIDEV,"
cQuery += "  DT61.DT6_LOJDEV,DT61.DT6_VALTOT,DT61.DT6_DOCTMS,DT61.DT6_CLIREM,DT61.DT6_LOJREM,DT61.DT6_CLIDES,"
cQuery += "  DT61.DT6_LOJDES "
cQuery += "  FROM "+RetSqlName("DUA")+" DUA"
cQuery += "  JOIN "+RetSqlName("DT6")+" DT61"
cQuery += "    ON DT61.DT6_FILIAL = '"+xFilial("DT6")+"'"
cQuery += "   AND DT61.DT6_FILDOC = DUA_FILDOC"
cQuery += "   AND DT61.DT6_DOC    = DUA_DOC"
cQuery += "   AND DT61.DT6_SERIE  = DUA_SERIE"
cQuery += "   AND DT61.DT6_FILDES = '"+cFilAnt+"'"
cQuery += "   AND DT61.DT6_STATUS = '"+StrZero(5,Len(DT6->DT6_STATUS))+"'"
If cDocQry <> "()"
	cQuery += "   AND DT61.DT6_DOCTMS IN  " + cDocQry
EndIf
cQuery += "   AND DT61.D_E_L_E_T_ = ' '"
cQuery += " WHERE DUA_FILIAL      = '" + xFilial("DUA") + "' "
If cOcoQry <> "()"
	cQuery += "   AND DUA_CODOCO      IN  " + cOcoQry
EndIf
cQuery += "   AND DUA.D_E_L_E_T_  = ' ' "
cQuery += "   AND NOT EXISTS (SELECT 'X' "
cQuery += "                     FROM "+RetSqlName("DT6")+" DT62"
cQuery += "                    WHERE DT62.DT6_FILIAL = '"+xFilial("DT6")+"'"
cQuery += "                      AND DT62.DT6_FILDCO = DUA_FILDOC"
cQuery += "                      AND DT62.DT6_DOCDCO = DUA_DOC"
cQuery += "                      AND DT62.DT6_SERDCO = DUA_SERIE"
cQuery += "                      AND DT62.DT6_DOCTMS IN ('E','F')"
cQuery += "                      AND DT62.D_E_L_E_T_ = ' ')"
cQuery += " ORDER BY DT6_FILDOC,DT6_DOC,DT6_SERIE,DUA_DATOCO,DUA_HOROCO"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
TCSetField(cAliasQry,"DUA_DATOCO","D",8,0)
TCSetField(cAliasQry,"DT6_VALTOT","N",TamSx3("DT6_VALTOT")[1],TamSx3("DT6_VALTOT")[2])

While (cAliasQry)->(!Eof())
	aPerfil := TmsPerfil((cAliasQry)->DT6_CLIDEV,(cAliasQry)->DT6_LOJDEV,,,(cAliasQry)->DT6_CLIREM,(cAliasQry)->DT6_LOJREM,(cAliasQry)->DT6_CLIDES,(cAliasQry)->DT6_LOJDES)
	// Cliente paga armazenagem, e valor do documento maior ou igual ao minimo, e quantidade de dias no armazem maior que o periodo maximo.
	If aPerfil[38] == "1" .And. DT6->DT6_VALTOT >= aPerfil[43] .And. (dDataBase - (cAliasQry)->DUA_DATOCO) >= aPerfil[40]
		nSeqDoc ++
		SA1->(dbSetOrder(1))
		SA1->(MsSeek(xFilial("SA1")+(cAliasQry)->(DT6_CLIDEV+DT6_LOJDEV)))
		AAdd(aCols,{nSeqDoc,;
						"0",;
						(cAliasQry)->DT6_FILDOC,;
						(cAliasQry)->DT6_DOC,;
						(cAliasQry)->DT6_SERIE,;
						SA1->A1_NOME,;
						(dDataBase - (cAliasQry)->DUA_DATOCO),;
						(cAliasQry)->DT6_DOCTMS,;
						.F.})
	EndIf
	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(dbCloseArea())
dbSelectArea("DT6")

aCols := aSort(aCols,,,{|x,y| x[3]+x[4]+x[5] < y[3]+y[4]+x[5]})

If Len(aCols) == 0
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help(" ",1,"TMSA50084")	//-- "Nenhum documento foi localizado !!!"
	Return( Nil )
EndIf

aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T.} )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

aPosObj[1][1] := 35
aPosObj[1][2] := 5
aPosObj[1][3] := aCoors[3] 
aPosObj[1][4] := aCoors[4] 

AAdd(aButtons,{'PESQUISA',{||TmsA500Psq(2)},STR0002}) //Pesquisar

cCadastro += " - " + STR0084
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	oGetD := MSGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],3,'AllWaysTrue','AllWaysTrue',,.T.,aAlter,,,Len(aCols),,,,Nil)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetD:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()},,aButtons)

If nOpca == 1
	For nCont := 1 to Len(aCols)
		If aCols[nCont,2] $ "123"
			nSeek := Ascan(aLoteAut,{|x|x[1]==aCols[nCont,8]})
			If nSeek == 0
				cLoteAut := TmsA500Lot(StrZero(0,Len(DT6->DT6_LOTNFC)))
				AAdd (aLoteAut,{aCols[nCont,8],cLoteAut,1,1})
			Else
				cLoteAut := aLoteAut[nSeek][2]
				aLoteAut[nSeek][3] ++
				aLoteAut[nSeek][4] ++
			EndIf
			DT6->(dbSetOrder(1))
			DT6->(MsSeek(xFilial("DT6")+aCols[nCont,3]+aCols[nCont,4]+aCols[nCont,5]))
			lPenArm := .T.
		EndIf
		If aCols[nCont,2] $ "13" // Devolucao ou Ambos
			TMSA500Mnt("DT6",DT6->(Recno()),3)
			nQtdDoc ++
		EndIf
		If aCols[nCont,2] $ "23" // Armazenagem ou Ambos
			nDiaArm := aCols[nCont,7]
			TMSA500Mnt("DT6",DT6->(Recno()),Iif(lAlianca,10,9))
			nQtdDoc ++
		EndIf
	Next nCont
EndIf

For nCont := 1 To Len(aLoteAut)
	DTP->(dbSetOrder(2)) //DTP_FILIAL+DTP_FILORI+DTP_LOTNFC
	If DTP->(MsSeek(xFilial("DTP")+cFilAnt+aLoteAut[nCont][2]))
		RecLock("DTP",.F.)
		DTP->DTP_QTDLOT := aLoteAut[nCont][3]
		DTP->DTP_QTDDIG := aLoteAut[nCont][4]
		MsUnlock()
		AAdd(aDocImp,{STR0130 + " " + DTP->DTP_LOTNFC,,})
	EndIf
Next nA

If !Empty(aDocImp)
	TmsMsgErr(aDocImp,,lTM500Auto)
EndIf

cLoteAut  := ""

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Anu ³ Autor ³ N3-DL                ³ Data ³ 16/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera Anulacao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA500Anu()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Anu( cAlias, nReg, nOpcx , lEvDesac )
Local aAreaAnt   := GetArea()
Local aAreaDTQ   := DTQ->(GetArea())
Local aAreaDUD   := DUD->(GetArea())
Local aAreaDT6   := DT6->(GetArea())
Local aAreaDUY   := DUY->(GetArea())
Local lHelp      := .F.
Local aCab       := {}
Local aItens     := {}
Local aItem      := {}
Local cItem      := "1"
Local cNumNF     := Space(Len(SF1->F1_DOC))
Local cSerieNF   := Space(Len(SF1->F1_SERIE))
Local cChvNFe    := Space(Len(SF1->F1_CHVNFE))	
Local lContrib   := .F.
Local lExistNF   := .F. 
Local cEspecie   := Space(Len(SF1->F1_ESPECIE))	
Local cInscr     := ""
Local cContrib   := ""
Local cAliasSD2  := ""
Local nOpcAnul   := 0
Local nSldDev    := 0
Local nCntFor    := 0
Local dDatFech   := MVUlmes()
Local dDatFTMS   := GetMv("MV_DATATMS",.F.,CtoD(''))
Local dDatFFIN   := GetMV("MV_DATAFIN",.F.,CtoD(''))
Local lTMSCTe    := SuperGetMv( "MV_TMSCTE", .F., .F. )
Local cTipoNF    := SuperGetMV("MV_TPNRNFS") 
Local cTESAnula  := SuperGetMv("MV_TESANUL",,"")
Local cTESAnula2 := SuperGetMv("MV_TESANU2",,"")
Local cTMSMFat   := GetMV("MV_TMSMFAT",,"")
Local cMv_Estado := SuperGetMV("MV_ESTADO",.F.,"")
Local CDOCTMS    := "M"
Local dDatEmis   := dDataBase //"Data de Emissão."
Local cAliasChv
Local oDlgAnul
Local lRet     		:= .T.
Local aAreaSF3   	:= SF3->(GetArea())
Local cTesAnu    	:= ""
Local cDesacordo 	:= ""	
Local cUFOriTR  	:= ""
Local cMUOriTR 		:= ""
Local cUFDesTR 		:= ""
Local cMUDesTR    	:= ""
Local cTESDEV		:= ""
Local lMultSerie    := FindFunction("TmsSerie")
Local aDataBase     := {}
Local cHoraRMT      := ""

Default lEvDesac	:= .F. 	//-- Indica se trata-se de um evento de desacordo

If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

DbSelectArea("DT6")

dbSelectArea("SF2")
dbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
MsSeek(DT6->(DT6_FILORI+DT6_DOC+DT6_SERIE))

Private cSerie	:= ''
If Type("lMsErroAuto") == "U"
	Private lMsErroAuto := .F. //-- Utilizada na funcao MsExecAuto()
EndIf
//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If !TMSAVerAge("1",DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,,,,,,,,"2",.T.,.T.)
	Return .F.
EndIf

If lTMSCTe .And. DT6->DT6_IDRCTE <> '100' .And. ( Alltrim(DT6->DT6_DOCTMS) != StrZero( 5, Len( DT6->DT6_DOCTMS ) ) .And.;    //--Nota Fiscal de Serv. de Transp.
                                                  Alltrim(DT6->DT6_DOCTMS) != Replicate('D', Len( DT6->DT6_DOCTMS ) ) .And.; //--Nota Fiscal de Reentrega
                                                  Alltrim(DT6->DT6_DOCTMS) != Replicate('F', Len( DT6->DT6_DOCTMS ) ) .And.; //--Nota Fiscal de Armazenagem
                                                  Alltrim(DT6->DT6_DOCTMS) != Replicate('G', Len( DT6->DT6_DOCTMS ) ) )      //--Nota Fiscal de Complemento

	DTP->(DbSetOrder(2)) //DTP_FILIAL+DTP_FILORI+DTP_LOTNFC
	If	DTP->(MsSeek(xFilial('DTP')+DT6->DT6_FILORI+DT6->DT6_LOTNFC))
		If DTP->DTP_TIPLOT == '3' .Or. DTP->DTP_TIPLOT == '4'
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help( " ", 1, "TMSA50100")	// "Doc Original ainda nao esta autorizado.
			RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
			Return( .F. )
		EndIf
	EndIf
EndIf

If (Date()-DT6->DT6_DATEMI) > 60
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
   Help( " ", 1, "TMSA500B6") //"Ct-e não pode ser Anulado, pois ultrapassou o prazo de Anulacao de 60 dias"       
	RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
   Return( .F. )
EndIf


//-- PE utilizado para validar a execucao da rotina.
If lTM500OK
	lRet := ExecBlock("TM500OK",.F.,.F.,{12})
	If ValType(lRet) # "L"
		lRet := .T.
	EndIf	
EndIf

If !lRet
	RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Return( .F. )
EndIf

cAliasChv :=  GetNextAlias()
cQuery := " SELECT 1 "  
cQuery += "   FROM " +  RetSqlName('DT6') + " DT6 " +CRLF 
cQuery += "  WHERE DT6.DT6_FILIAL = '" + xFilial('DT6') + "'" +CRLF
cQuery += "		AND DT6.DT6_FILDCO = '" + DT6->DT6_FILORI + "'" +CRLF 
cQuery += "		AND DT6.DT6_DOCDCO = '" + DT6->DT6_DOC + "'" +CRLF
cQuery += "		AND DT6.DT6_SERDCO = '" + DT6->DT6_SERIE + "'" +CRLF
cQuery += "		AND DT6.DT6_DOCTMS <> '6'
cQuery += "		AND DT6.D_E_L_E_T_ = ' '
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasChv, .F., .T.)

If (!(cAliasChv)->(Eof()))
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help( " ", 1, "TMSA500B1")	// Anulação não permitida. Documento possui CT-e complementar
	(cAliasChv)->(DbCloseArea())
	RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
	Return( .F. )
EndIf
(cAliasChv)->(DbCloseArea())
RestArea(aAreaAnt)

//-- Verifica a data de execucao
If !lTM500Auto .And. GetNewPar("MV_NFCHGDT",.F.) //-- Informa se a data base do sistema deve ser alterada, se a data do sistema operacional for alterada, na preparacao do documento de saida.
	If MsDate()==dDataBase+1
		If MsgYesNo(STR0181,OemToAnsi(STR0067)) //"O sistema identificou a troca da data do sistema operacional, deseja atualizar a data base do sistema?"###"Atencao !"
			dDataBase := MsDate()
		EndIf
	EndIf
EndIf
If dDataBase <= dDatFech
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help ( " ", 1, "FECHTO" ) //"Nao pode ser digitado movimento com data anterior a ultima data de fechamento (virada de saldos)"
	RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
	Return( .F. )
EndIf
If !Empty(dDatFTMS)
	If dDataBase <= dDatFTMS
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help ( " ", 1, "FECHATMS" )
		RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
		Return( .F. )
	EndIf
EndIf
If !Empty(dDatFFIN)
	If dDataBase < dDatFFIN
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help ( " ", 1, "DTMOVFIN" )
		RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
		Return( .F. )
	EndIf
EndIf
If !Empty(GetMV("MV_DATAFIS",,""))
	If !FisChkDt(dDataBase)
		RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( .F. )
	EndIf
EndIf

If ( DT6->DT6_DOCTMS != "2" .And. DT6->DT6_DOCTMS != "7" .And. ;
				DT6->DT6_DOCTMS != "9" .And. DT6->DT6_DOCTMS != "6" .And. ;
				DT6->DT6_DOCTMS != "E" .And. DT6->DT6_DOCTMS != "A" .And. DT6->DT6_DOCTMS != "P")
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help( ' ', 1, 'TMSA50014',,STR0008 + DT6->DT6_DOC + STR0014 + DT6->DT6_SERIE,4,1)	//-- Manutencao permitida somente em conhecimento //'Docto: '###' Serie: '
	RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
	Return( .F. )
EndIf
If	DT6->DT6_STATUS <> StrZero(7, Len(DT6->DT6_STATUS) )
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help( " ", 1, 'TMSA50094') //-- A anulação é permitida somente para documentos entregues.
	RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
	Return( .F. )
Else
	//--Verifica a situacao atual do documento da viagem
	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX(R_E_C_N_O_) DUDRecNo"
	cQuery += " FROM " + RetSqlTab("DUD")
	cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD")  + "'"
	cQuery += "   AND DUD.DUD_FILDOC = '" + DT6->DT6_FILDOC + "'"
	cQuery += "   AND DUD.DUD_DOC    = '" + DT6->DT6_DOC    + "'"
	cQuery += "   AND DUD.DUD_SERIE  = '" + DT6->DT6_SERIE  + "'"
	cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )
	DUD->( DbGoTo( (cAliasQry)->DUDRecNo ) )
	(cAliasQry)->( DbCloseArea() )
	dbSelectArea("DT6")
EndIf

If DT6->DT6_DOCTMS == Replicate('M', Len( DT6->DT6_DOCTMS ) ) // CTRC Anulacao
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help( " ", 1, "TMSA50097")	// "Este documento é de anulação, portanto não é possível gerar outro documento de anulação."
	RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
	Return( .F. )
EndIf

If DT6->DT6_FILDOC != cFilAnt
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help( " ", 1, "TMSA50095")	// "Anulacao permitida somente na filial de origem."
	RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
	Return( .F. )
EndIf

//-- Pesquisa a TES que o CT-e foi gerado, para encontrar uma TES de entrada caso esteja cofigurada,
//no cadastro de TES campo F4_TESDV. Caso não esteja configurado, o sistema irá pegar dos parametros,
// MV_TESANUL e MV_TESANU2
cAliasSD2 := GetNextAlias()
cQuery := "SELECT SD2.D2_TES,SD2.R_E_C_N_O_  SD2RECNO "
cQuery += "FROM "+RetSqlName("SD2")+" SD2 "
cQuery += "WHERE "
cQuery += "SD2.D2_FILIAL  = '" + DT6->DT6_FILDOC  + "' AND "
cQuery += "SD2.D2_DOC     = '" + DT6->DT6_DOC     + "' AND "
cQuery += "SD2.D2_SERIE   = '" + DT6->DT6_SERIE   + "' AND "
cQuery += "SD2.D2_CLIENTE = '" + DT6->DT6_CLIDEV  + "' AND "
cQuery += "SD2.D2_LOJA    = '" + DT6->DT6_LOJDEV  + "' AND "
cQuery += "SD2.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)

If (cAliasSD2)->(!EOF())
	cTESDEV := (cAliasSD2)->D2_TES
EndIf
If SF4->(DbSeek(xFilial("SF4")+cTESDEV)) 
	If !Empty(SF4->F4_TESDV)
		cTESAnu := SF4->F4_TESDV
	EndIf
EndIf
(cAliasSD2)->(dbCloseArea())
	
If Empty(cTESAnu)
	If Empty(cTESAnula) .Or. Empty(cTESAnula2)
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help( " ", 1, "TMSA50098") // "O Parametro MV_TESANUL nao esta preenchido.
		RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
		Return( .F. )
	Else
		DbSelectArea("SF4")
		DbSetOrder(1)
		If !SF4->(DbSeek(xFilial("SF4")+cTESAnula)) .Or. SF4->F4_TIPO != "E"  .Or. SF4->F4_DUPLIC != "S"
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help( " ", 1, "TMSA50099") // "Não existe este código na tabela de TES ou a TES informada no parametro MV_TESANUL, não é do tipo Entrada"
			RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
			Return( .F. )
		EndIf
		If !SF4->(DbSeek(xFilial("SF4")+cTESAnula2)) .Or. SF4->F4_TIPO != "E"  .Or. SF4->F4_DUPLIC != "N"
			Help( " ", 1, "TMSA500D5") // "Não existe este código na tabela de TES ou a TES informada no parametro MV_TESANUL, não é do tipo Entrada"
			RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
			Return( .F. )
		EndIf
	EndIf
EndIf

If Empty(cTESAnu)
	If !Empty(DT6->DT6_NUM) .And. !Empty(DT6->DT6_PREFIX) .And. !Empty(DT6->DT6_TIPO)
		cTESAnu  := SuperGetMv("MV_TESANUL",,"")
	Else
		cTESAnu  := SuperGetMv("MV_TESANU2",,"")
	EndIf
EndIf

aAreaDT6 := DT6->(GetArea())
DT6->(dbSetOrder(8))
If	DT6->(MsSeek(cSeek := xFilial("DT6") + DT6_FILDOC + DT6_DOC + DT6_SERIE))
	While DT6->(!Eof() .And. DT6_FILIAL + DT6_FILDCO + DT6_DOCDCO + DT6_SERDCO == cSeek)
		If DT6->DT6_DOCTMS == cDocTMS
			lHelp := .T.
			Exit
		EndIf
		DT6->(dbSkip())
	EndDo
EndIf
RestArea(aAreaDT6)
If lHelp
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help(" ",1,"TMSA50019") // "Ja existe uma devolucao OU UMA ANULACAO para esse documento"
	RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
	Return( .F. )
EndIf

//-- Verifica se cliente e contribuinte do ICMS
cInscr   := Posicione("SA1", 1, xFilial("SA1") + DT6->DT6_CLIDEV + DT6->DT6_LOJDEV,"A1_INSCR")
cContrib := Posicione("SA1", 1, xFilial("SA1") + DT6->DT6_CLIDEV + DT6->DT6_LOJDEV,"A1_CONTRIB")
If	Alltrim(cContrib) == "2" .Or. Empty(cInscr) .Or. Alltrim(Upper(cInscr)) $ "ISENT" .Or. ;
	Alltrim(Upper(cInscr)) $ "RG"
	lContrib := .F.
Else
	lContrib := .T.
EndIf
// ------------------------------------------------------------------------------------------------ //
// Ponto de entrada: TM500CON - Alterar tratamento para Cliente contribuinte / não contribuinte.    //
// Criado ponto de entrada TM500CON na rotina de Manutenção de Documentos / Anulação (TMSA500) para // 
// definir geração documento de devolução para clientes contribuintes do ICMS com formulário próprio//
// similar ao gerado para clientes não contribuinte do ICMS.                                        //
// Este ponto de entrada altera funcionalidade definida através do convenio SINIEF 02/08.           //
// Lógico (default .F.), onde.F. para geração de documento de devolução com formulário próprio.     //
// ------------------------------------------------------------------------------------------------ //
If lTm500CON
	lContrib := ExecBlock("TM500CON",.F.,.F.)
	If ValType(lContrib) <> "L"
		lContrib := .F.
	EndIf
EndIf

//-- Posiciona configuracao de documentos para obter a Serie do Documento de Anulacao.
DUI->(DbSetOrder(1))
If	DUI->(!MsSeek( xFilial("DUI") + "M", .F.))
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help(" ", 1, "TMSA50006",,STR0019 + "M",4,1) //-- Documento nao encontrado na configuracao de documentos. (DUI) //'Documento: '
	RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
	Return( .F. )
EndIf

aAreaDT6 := DT6->(GetArea())
cAliasChv :=  GetNextAlias()

cQuery := " SELECT 1 "  
cQuery += "   FROM " +  RetSqlName('SD1') + " SD1 " +CRLF 
cQuery += "  WHERE SD1.D1_FILIAL = '" + xFilial('SD1') + "'" +CRLF
cQuery += "		AND SD1.D1_NFORI = '" + DT6->DT6_DOC + "'" +CRLF 
cQuery += "		AND SD1.D1_SERIORI = '" + DT6->DT6_SERIE + "'" +CRLF
cQuery += "		AND SD1.D_E_L_E_T_ = ' '
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasChv, .F., .T.)

If (!(cAliasChv)->(Eof()))
	lExistNF := .T.
Else
	lExistNF := .F.
EndIf

(cAliasChv)->(DbCloseArea())
RestArea(aAreaDT6)

If !lExistNF
	If !Empty(DT6->DT6_NUM) .And. !Empty(DT6->DT6_PREFIX) .And. !Empty(DT6->DT6_TIPO) .And. !SF4->F4_DUPLIC == 'S'
	   	DbSelectArea("SF4")
		DbSetOrder(1)
		If !SF4->(DbSeek(xFilial("SF4")+cTESAnula)) .Or. SF4->F4_TIPO != "E"  .Or. SF4->F4_DUPLIC != "S"
			Help(' ', 1, 'TMSA500122',," " + AllTrim(DT6->DT6_NUM) + "/" + AllTrim(DT6->DT6_PREFIX) + "/" + AllTrim(DT6->DT6_TIPO) + CRLF + STR0247,2,13) //"Documento possui fatura. : "###". Configure a TES para gerar duplicata.. "
			RestArea(aAreaAnt) //-- É preciso restaurar a área quando fecha um alias de query, senão causa não-conformidades quando ExecAuto
			lRet := .F.
		EndIf
		If Empty(cTESAnu)
			cTESAnu  := SuperGetMv("MV_TESANUL",,"")
		EndIf
	Else	   		
		If Empty(cTESAnu)
			cTESAnu  := SuperGetMv("MV_TESANU2",,"")
		EndIf
	EndIf
	
	If !lRet
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return 
	EndIf

	//-- Verifica se informou serie para origem em outra filial.
	If !Empty(DUI->DUI_SEROUT)
		If DUY->(MsSeek(xFilial("DUY")+DT6->DT6_CDRORI))
			If	cMv_Estado <> DUY->DUY_EST
				cSerie := DUI->DUI_SEROUT
			EndIf
		EndIf
	EndIf

	If lMultSerie  
		cSerie := TmsSerie(cSerie, DT6->DT6_NCONTR, DT6->DT6_CODNEG, DT6->DT6_SERVIC)
	EndIf
	
	cSerie := DUI->DUI_SERIE
	_cObsComp := ''

	If FindFunction('TMSHoraRMT')
		aDataBase:= TMSHoraRMT(cMv_Estado,.F.)
		If Len(aDataBase) > 0
			cHoraRMT  := aDataBase[2]
			dDatEmis  := STOD(aDataBase[1]) 	
		EndIf
	EndIf

	If !lTM500Auto
		//-- Caso Cliente devedor nao seja contribuinte do ICMS e Esteja gerando documento de anulacao gera NF de entrada
		DEFINE MSDIALOG oDlgAnul TITLE OemToAnsi(STR0168) FROM 0,0 TO 380,300 OF oDlgAnul PIXEL //"NF de Anulação"
		
			@ 06, 06 TO 110,145 LABEL OemToAnsi(STR0169) OF oDlgAnul PIXEL //"Informe o Número e Série da NF do cliente."
		
			@ 20, 15 SAY OemToAnSi(STR0170) SIZE 45,8 PIXEL OF oDlgAnul //"Número da NF"
			@ 30, 15 MSGET cNumNF	PICTURE PesqPict("SF1","F1_DOC")	WHEN lContrib .And. UPPER(cDesacordo) <> "SIM" SIZE 45,10 PIXEL OF oDlgAnul
		
			@ 20, 65 SAY OemToAnsi(STR0171) SIZE 45,8 PIXEL OF oDlgAnul //"Série da NF"
			@ 30, 65 MSGET cSerieNF	PICTURE PesqPict("SF1","F1_SERIE")	WHEN lContrib .And. UPPER(cDesacordo) <> "SIM" SIZE 20,10 PIXEL OF oDlgAnul
			
			@ 20, 100 SAY OemToAnsi(STR0224) SIZE 45,8 PIXEL OF oDlgAnul //"Especie Doc."
			@ 30, 100 MSGET cEspecie Picture PesqPict('SF1','F1_ESPECIE') F3 CpoRetF3('F1_ESPECIE');
			  VALID !Empty(cEspecie) .AND. ExistCpo("SX5", "42" + cEspecie) WHEN lContrib .And. UPPER(cDesacordo) <> "SIM" SIZE 35,10 PIXEL OF oDlgAnul
			  
			@ 50, 15 SAY OemToAnsi(STR0236) SIZE 45,8 PIXEL OF oDlgAnul //"Data de Emissão."
			@ 60, 15 MSGET dDatEmis Picture PesqPict('SF1','F1_EMISSAO') F3 CpoRetF3('F1_EMISSAO');
			 VALID !Empty(dDatEmis) .Or. dDatEmis > dDataBase WHEN lContrib .And. UPPER(cDesacordo) <> "SIM"  SIZE 45,10 PIXEL OF oDlgAnul
						
			@ 50, 85 SAY OemToAnsi(STR0263) SIZE 65,8 PIXEL OF oDlgAnul //Evento Desacordo		
			@ 60, 85 MSCOMBOBOX oComboBo1 VAR cDesacordo ITEMS { STR0275 , STR0274 } WHEN lContrib SIZE 45, 010 OF oDlgAnul COLORS 0, 16777215 PIXEL //-- Não , Sim
			
		  	@ 80, 15 SAY OemToAnsi("Chave NFE") SIZE 45,8 PIXEL OF oDlgAnul //"Chave da DANFE"
			@ 90, 15 MSGET cChvNFe	PICTURE PesqPict("SF1","F1_CHVNFE")	WHEN lContrib .And. UPPER(cDesacordo) <> "SIM" SIZE 126,10 PIXEL OF oDlgAnul
	
			@ 115, 06 SAY OemToAnsi(STR0191) SIZE 45,8 PIXEL OF oDlgAnul //"Motivo"
			@ 125, 06 GET oGet VAR _cObsComp MEMO SIZE 139,40 PIXEL OF oDlgAnul
		
			DEFINE SBUTTON FROM 173,  90 TYPE 1 ACTION {||nOpcAnul := 1 , lEvDesac := Iif(Upper(cDesacordo) == "SIM" , .T. , .F. ) , If((!Empty(cNumNF) .And. !Empty(cSerieNF) .And. !Empty(cEspecie) .And. !Empty(_cObsComp) .Or. !lContrib .Or. lEvDesac),oDlgAnul:End(),MsgAlert(OemToAnsi(STR0172)))} ENABLE OF oDlgAnul //"Preencha os campos Número, Série e Espécie Doc. e Motivo"
			DEFINE SBUTTON FROM 173, 120 TYPE 2 ACTION {||nOpcAnul := 0, oDlgAnul:End()} ENABLE OF oDlgAnul
		ACTIVATE MSDIALOG oDlgAnul CENTER
	Else
		If lContrib .And. !lEvDesac
			cNumNf    := Get500Aut("F1_DOC",,"")
			cSerieNF  := Get500Aut("F1_SERIE",,"")
			cEspecie  := Get500Aut("F1_ESPECIE",,"")
			dDatEmis  := Get500Aut("F1_EMISSAO",,CtoD(''))
			cChvNFe   := Get500Aut("F1_CHVNFE",,"")
		EndIf
		_cObsComp := Get500Aut("F1_MENNOTA",,"")
		
		nOpcAnul := 1
		 If lContrib .And. !lEvDesac .And. (Empty(cNumNF) .Or. Empty(cSerieNF) .Or. Empty(cEspecie) .Or. Empty(_cObsComp))
		 	Help("",1,'Obrigat2',,OemToAnsi(STR0172)) //"Preencha os campos Número, Série e Espécie Doc. e Motivo"
		 	AutoGrLog(STR0257) //--"Quando o contribuinte, necessário preencher os dados da NF do cliente (Nro., Série, Espécie, Emissão e Chave)."
		 	lRet := .F.
		 	nOpcAnul := 0
		 EndIf
	EndIf
	
	If nOpcAnul == 1
		
		If lContrib .And. !lEvDesac
			cSerie := cSerieNF
		Else
		   	cEspecie := A460Especie(cSerie) 
			cNumNF   := NxtSX5Nota(IIf(!Empty(cSerie), cSerie, DT6->DT6_SERIE),.T.,cTipoNF)
		EndIf

		aAreaDUY := DUY->(GetArea())
		If SF1->(ColumnPos('F1_UFORITR')) > 0
			If DUY->(MsSeek(xFilial("DUY")+DT6->DT6_CDRORI))
				cUFOriTR := DUY->DUY_EST
				cMUOriTR := DUY->DUY_CODMUN
			EndIf
	
			If DUY->(MsSeek(xFilial("DUY")+DT6->DT6_CDRCAL))
				cUFDesTR := DUY->DUY_EST
				cMUDesTR := DUY->DUY_CODMUN
			EndIf
		EndIf
		RestArea(aAreaDUY)

		Begin Transaction
			RecLock('DT6',.F.)
			DT6->DT6_STATUS := StrZero(9,Len(DT6->DT6_STATUS)) // Anulacao
			MsUnLock()
			//-- Execauto MATA103 NF de Devolucao -
			AAdd( aCab, { "F1_DOC"    , cNumNF		 						, Nil } ) // Numero da NF         : Obrigatorio
			AAdd( aCab, { "F1_SERIE"  , cSerie		 						, Nil } ) // Serie da NF          : Obrigatorio
			AAdd( aCab, { "F1_TIPO"   , "D"			 						, Nil } ) // Tipo da NF           : Obrigatorio
			AAdd( aCab, { "F1_FORNECE", DT6->DT6_CLIDEV						, Nil } ) // Codigo do Fornecedor : Obrigatorio
			AAdd( aCab, { "F1_LOJA"   , DT6->DT6_LOJDEV		 				, Nil } ) // Loja do Fornecedor   : Obrigatorio
			AAdd( aCab, { "F1_EMISSAO", dDatEmis			 				, Nil } ) // Emissao da NF        : Obrigatorio
			AAdd( aCab, { "F1_FORMUL" , If(lContrib .And. !lEvDesac ,"N","S")				, Nil } ) // Formulario
			AAdd( aCab, { "F1_ESPECIE", cEspecie							, Nil } ) // Especie
			AAdd( aCab, { "F1_MENNOTA", _cObsComp							, Nil } ) // Mensagem para nota
			AAdd( aCab, { "F1_TPCTE"  , "A"									, Nil } ) // Tipo CTE - A = Anulacao
			AAdd( aCab, { "F1_CHVNFE" , cChvNFe			  					, Nil } ) // Chave da DANFE
			AAdd( aCab, { "F1_HORA"   , Iif(!Empty(cHoraRMT),cHoraRMT,Time())   , Nil } ) // Hora Emissao
			AAdd( aCab, { "F1_CLIDEST", DT6->DT6_CLIDES  				    	, Nil } ) // Cliente Destinatario
			AAdd( aCab, { "F1_LOJDEST", DT6->DT6_LOJDES	  				    	, Nil } ) // Loja do Destinatário
			AAdd( aCab, { "F1_ESTDES" , cUFDesTR                            	, Nil } ) // UF do Destinatário

			If SF1->(ColumnPos('F1_UFORITR')) > 0
				/* Origem x Destino do transporte - Ato Cotepe 48 */
				Aadd(aCab, {"F1_MUORITR" , cMUOriTR  				  , Nil } )
				Aadd(aCab, {"F1_UFORITR" , cUFOriTR 				  , Nil } )
				Aadd(aCab, {"F1_MUDESTR" , cMUDesTR 				  , Nil } )
				Aadd(aCab, {"F1_UFDESTR" , cUFDesTR    				  , Nil } )
			EndIf

			//-- Monta itens da nota de devolucao.
			SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			aStruSD2  := SD2->(dbStruct())
			cAliasSD2 := GetNextAlias()
			cQuery := "SELECT SD2.*,SD2.R_E_C_N_O_  SD2RECNO "
			cQuery += "FROM "+RetSqlName("SD2")+" SD2 "
			cQuery += "WHERE "
			cQuery += "SD2.D2_FILIAL  = '" + SF2->F2_FILIAL  + "' AND "
			cQuery += "SD2.D2_DOC     = '" + SF2->F2_DOC     + "' AND "
			cQuery += "SD2.D2_SERIE   = '" + SF2->F2_SERIE   + "' AND "
			cQuery += "SD2.D2_CLIENTE = '" + SF2->F2_CLIENTE + "' AND "
			cQuery += "SD2.D2_LOJA    = '" + SF2->F2_LOJA    + "' AND "
			cQuery += "SD2.D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY "+SqlOrder(SD2->(IndexKey()))
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
			For nCntFor := 1 To Len(aStruSD2)
				If aStruSD2[nCntFor][2]<>"C"
					TcSetField(cAliasSD2,aStruSD2[nCntFor][1],aStruSD2[nCntFor][2],aStruSD2[nCntFor][3],aStruSD2[nCntFor][4])
				EndIf
			Next nCntFor
			While (cAliasSD2)->(!EOF())
				nSldDev := (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
				AAdd( aItens, { "D1_ITEM"   , StrZero(Val(cItem),Len(SD1->D1_ITEM))						, Nil } ) // Item
				AAdd( aItens, { "D1_COD"    , (cAliasSD2)->D2_COD										, Nil } ) // Codigo do Produto
				AAdd( aItens, { "D1_VUNIT"  , (cAliasSD2)->D2_PRCVEN									, Nil } ) // Valor Unitario
				AAdd( aItens, { "D1_QUANT"  , nSldDev													, Nil } ) // Quantidade
				If (cAliasSD2)->D2_QTDEDEV == 0
					AAdd( aItens, { "D1_TOTAL"  , (cAliasSD2)->D2_TOTAL  + (cAliasSD2)->D2_DESCON + (cAliasSD2)->D2_DESCZFR		, Nil } ) // Valor Total
					AAdd( aItens, { "D1_VALDESC", (cAliasSD2)->D2_DESCON + (cAliasSD2)->D2_DESCZFR		, Nil } ) // Desconto
				Else
					AAdd( aItens, { "D1_TOTAL"  , A410Arred(nSldDev*(cAliasSD2)->D2_PRCVEN,"D1_TOTAL")	, Nil } ) // Valor Total
					AAdd( aItens, { "D1_VALDESC", A410Arred((cAliasSD2)->D2_DESCON/(cAliasSD2)->D2_QUANT*nSldDev,"D1_VALDESC")	, Nil } ) // Desconto
				EndIf
				
				DbSelectArea("SF4")
				SF4->(DbSetOrder(1))
				If SF4->(DbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)) 
					If !Empty(SF4->F4_TESDV)
						AAdd( aItens, { "D1_TES"    , SF4->F4_TESDV	    								, Nil } ) // TES
					Else
						AAdd( aItens, { "D1_TES"    , cTESAnu	    									, Nil } ) // TES
					EndIf
				Else
					AAdd( aItens, { "D1_TES"    , cTESAnu	    										, Nil } ) // TES
				EndIf
				
				AAdd( aItens, { "D1_NFORI"  , (cAliasSD2)->D2_DOC	   									, Nil } ) // NF de Origem
				AAdd( aItens, { "D1_SERIORI", (cAliasSD2)->D2_SERIE  				 					, Nil } ) // Serie de Origem
				AAdd( aItens, { "D1_ITEMORI", StrZero(Val((cAliasSD2)->D2_ITEM),Len(SD2->D2_ITEM))	, Nil } ) // Item Origem
				AAdd( aItem, aItens )
				cItem := Soma1(cItem)
				aItens := {}
				(cAliasSD2)->(DbSkip())
			EndDo
			(cAliasSD2)->(dbCloseArea())
			DbSelectArea("DT6")
			//-- Início de transação
			//-- Modificado o local do inicio da transação pois ocorria um erro de 
			//-- dupla abertura de transação.
			If Len(aItem) > 0
				If !lTM500Auto
					MsgRun( STR0161, STR0162, {|| MsExecAuto({|w,x,y,z|Mata103(w,x,y,z)},aCab,aItem,3,.F.) }) //"Gerando NF de Anulação" ### "Aguarde..."
				Else
					MsExecAuto({|w,x,y,z|Mata103(w,x,y,z)},aCab,aItem,3,.F.)  
				EndIf
			EndIf
			If lMsErroAuto
				lRet := .F.
				DisarmTransaction()
				If !lTM500Auto
					MostraErro()
				EndIf
			Else
				//-- Posiciona na SF3 e chama integração com DATASUL
				SF3->(DbSetOrder(4)) //-- F3_FILIAL+F3_CLIFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
				If SF3->(DbSeek(xFilial("SF3") + SF1->(F1_FORNECE + F1_LOJA + F1_DOC + F1_SERIE),.T.))
					If SF3->F3_FORMUL != "S"
						TMSAE76()
					EndIf
				EndIf
			EndIf
		End Transaction
	EndIf
Else
	RecLock('DT6',.F.)
	DT6->DT6_STATUS := StrZero(9,Len(DT6->DT6_STATUS)) // Anulacao
	MsUnLock()
EndIf

//Precisa zerar a observacao digitada por ser static
_cObsComp := ''

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

RestArea(aAreaSF3)
RestArea(aAreaDTQ)
RestArea(aAreaDUD)
RestArea(aAreaAnt)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A500TipVei³ Autor ³Eduardo de Souza       ³ Data ³ 07/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Informar os Tipos de Veiculo que serao utilizados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A500TipVei()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±³          ³ExpC1 - Filial Documento                                    ³±±
±±³          ³ExpC2 - Documento                                           ³±±
±±³          ³ExpC3 - Serie                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA500                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A500TipVei(nOpcx,cFilDoc,cDocto,cSerie,lTela)

Local nOpcA    := 0
Local nCntFor  := 0
Local oDlgEsp
Local aAreas   := {DVU->(GetArea()),GetArea()}
Local oDWTStru := FwFormStruct(2,"DWT")
Local ni       := 1

Default lTela := .T.
//-- Salva as variaveis utilizadas na GetDados Anterior.
SaveInter()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

n       := 1
aCols   := {}
aHeader := {}

//-- Montagem do aHeader
If Len(aHeaderDWT) == 0

    While ni <= Len(oDWTStru:aFields)
        
        AAdd(aHeader,{ TRIM(FWX3TITULO(oDWTStru:aFields[ni][1]))			,; //| Titulo do campo
						AllTrim(oDWTStru:aFields[ni][1])					,; //| campo
						X3Picture(oDWTStru:aFields[ni][1])					,; //| picture
						TamSx3(oDWTStru:aFields[ni][1])[1]					,; //| tamanho
						TamSX3(oDWTStru:aFields[ni][1])[2]					,; //| decimal
						GetSx3Cache(oDWTStru:aFields[ni][1],"X3_VALID")		,; //| valid
                        GetSx3Cache(oDWTStru:aFields[ni][1],"X3_USADO") 	,; //| usado
						GetSx3Cache(oDWTStru:aFields[ni][1],"X3_TIPO")		,; //| tipo
						GetSx3Cache(oDWTStru:aFields[ni][1],"X3_ARQUIVO")	,; //| arquivo
						GetSx3Cache(oDWTStru:aFields[ni][1],"X3_CONTEXT")	,; //| context 
						GetSx3Cache(oDWTStru:aFields[ni][1],"X3_CBOX")		,; //| BOX
						GetSx3Cache(oDWTStru:aFields[ni][1],"X3_RELACAO")}) //| Relacao/Ini.Padrao

		ni ++
    EndDo
    aHeaderDWT := Aclone(aHeader)
Else
    aHeader := Aclone(aHeaderDWT)
EndIf

nPosItem  := Ascan(aHeaderDWT, {|x| AllTrim(x[2]) == 'DWT_ITEM' })

//-- Montagem do aCols
If nOpcx == 4 .Or. nOpcx == 5 .and. Empty(aColsDWT) .And. !lTela
    DTC->(dbSetOrder(3)) //-- DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO                                                                                                   
    If DTC->(MsSeek(xFilial("DTC")+DT6->DT6_FILDOC+DT6_DOC+DT6_SERIE))
	    DVU->(dbSetOrder(2)) //-- DVU_FILIAL+DVU_FILORI+DVU_LOTNFC+DVU_NUMNFC+DVU_SERNFC+DVU_CLIREM+DVU_LOJREM+DVU_ITEM
	    If DVU->(MsSeek(xFilial("DVU")+DT6->DT6_FILORI+DT6->DT6_LOTNFC+DTC->DTC_NUMNFC+DTC->DTC_SERNFC))
	        aColsDWT := {}
	        While DVU->(!Eof()) .And. DVU->(DVU_FILIAL+DVU_FILORI+DVU_LOTNFC) == xFilial("DVU")+DT6->DT6_FILORI+DT6->DT6_LOTNFC .And. DVU->(DVU_LOTNFC+DVU_NUMNFC+DVU_SERNFC) == DTC->(DTC_LOTNFC+DTC_NUMNFC+DTC_SERNFC)
	        	 If nCntFor := aScan(aColsDWT,{|x| x[GdFieldpos("DWT_TIPVEI",aHeaderDWT)] == DVU->DVU_TIPVEI}) > 0
	        	 	aColsDWT[nCntFor][GdFieldpos("DWT_QTDVEI",aHeaderDWT)] += DVU->DVU_QTDVEI
	        	 Else
	        	 	AAdd(aColsDWT,Array(Len(aHeaderDWT)+1))
	
	            	For nCntFor := 1 To Len(aHeaderDWT)
		                If AllTrim(aHeaderDWT[nCntFor,2]) == "DWT_FILDOC"
		                    aColsDWT[Len(aColsDWT),nCntFor] := cFilDoc
		                ElseIf AllTrim(aHeaderDWT[nCntFor,2]) == "DWT_DOC"
		                    aColsDWT[Len(aColsDWT),nCntFor] := cDocto
		                ElseIf AllTrim(aHeaderDWT[nCntFor,2]) == "DWT_SERIE"
		                    aColsDWT[Len(aColsDWT),nCntFor] := cSerie
		                ElseIf  aHeaderDWT[nCntFor,10] != "V" .And. DVU->(ColumnPos("DVU_"+SubsTr(aHeaderDWT[nCntFor,2],5))) >0
		                    aColsDWT[Len(aColsDWT),nCntFor]:= DVU->&("DVU_"+SubsTr(aHeaderDWT[nCntFor,2],5))
		                ElseIf aHeaderDWT[nCntFor,2] == "DWT_DESVEI"
		                    aColsDWT[Len(aColsDWT),nCntFor]:= Posicione('DUT',1,xFilial('DUT')+ DVU->DVU_TIPVEI,'DUT_DESCRI')
		                Else
		                    aColsDWT[Len(aColsDWT),nCntFor]:= CriaVar(aHeaderDWT[nCntFor][2])    
		                EndIf
		            Next nCntFor
		            aColsDWT[Len(aColsDWT),Len(aHeaderDWT)+1]:= .F.
		         EndIf
	            DVU->(dbSkip())
	        EndDo
	    EndIf
	EndIf
    
ElseIf !Empty(aColsDWT) 
    aCols := aClone(aColsDWT)
Else
    DWT->(dbSetOrder(1))
    If DWT->(MsSeek(xFilial("DWT")+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE))
        aColsDWT := {}
        While DWT->(!Eof()) .And. DWT->DWT_FILIAL+DWT->DWT_FILDOC+DWT->DWT_DOC+DWT->DWT_SERIE == xFilial("DWT") + M->DT6_FILDOC + M->DT6_DOC + M->DT6_SERIE
 
            AAdd(aColsDWT,Array(Len(aHeaderDWT)+1))
            For nCntFor := 1 To Len(aHeaderDWT)
                If  aHeaderDWT[nCntFor,10] != "V"
                    aColsDWT[Len(aColsDWT),nCntFor]:=DWT->(FieldGet(FieldPos(aHeaderDWT[nCntFor,2])))
                Else
                    aColsDWT[Len(aColsDWT),nCntFor]:=CriaVar(aHeaderDWT[nCntFor,2])
                EndIf
            Next nCntFor
            aColsDWT[Len(aColsDWT),Len(aHeaderDWT)+1]:= .F.
            DWT->(dbSkip())
        EndDo
        aCols := aClone(aColsDWT)
    ElseIf Empty(aCols)
        AAdd(aCols,Array(Len(aHeaderDWT)+1))
        For nCntFor := 1 to Len(aHeaderDWT)
            aCols[1][nCntFor] := CriaVar(aHeaderDWT[nCntFor][2])
        Next nCntFor
        aCols[1][nPosItem] := StrZero(1,Len(DWT->DWT_ITEM))
        aCols[1][Len(aHeaderDWT)+1] := .F.
    EndIf
EndIf

If lTela
    DEFINE MSDIALOG oDlgEsp FROM 94 ,104 TO 310,590 TITLE STR0142 Of oMainWnd PIXEL //"Tipos de Veiculo Nota Fiscal"

        oGetD := MSGetDados():New(30,2,105,243,If(nOpcx<>2,3,nOpcx),'A500TipLOk()','AllwaysTrue()','+DWT_ITEM',IIf(nOpcx<>2,.T.,Nil),,,,100)
        @ 6  ,116 SAY '' Of oDlgEsp PIXEL SIZE 26 ,9
        @ 18 ,3   SAY STR0034 + ': ' Of oDlgEsp PIXEL SIZE 56 ,9 //"Documento :"
        @ 18 ,45  SAY cFilDoc+' / '+cDocto+' / '+cSerie Of oDlgEsp PIXEL SIZE 50 ,9

    ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||IIF(oGetD:TudoOk(),(nOpcA:=1,oDlgEsp:End()),(nOpcA:=0))},{||oDlgEsp:End()} )

    If nOpcA == 1
        aColsDWT := aClone(aCols)
    EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura as Variaveis da GetDados Anterior                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestInter()

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

//-- Restaura as areas
aEval(aAreas,{|xArea| RestArea(xArea)})

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A500TipLOk³ Autor ³Eduardo de Souza       ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao das linhas digitadas na GetDados de Tp. de Veiculo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A500TipLOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA500                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A500TipLOk()

Local lRet := .T.

//-- Analisa se ha itens duplicados na GetDados
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	lRet := GDCheckKey( { 'DWT_TIPVEI' } , 4 )
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Val ³ Autor ³Wellington A Santos   ³ Data ³ 10/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validacao do campo filial parceira                          ³±±
±±³          ³retorna a filial da alianca para gatilhar no outro campo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TmsA500Val()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExcpC1 - Conteudo do campo FilDpc na tela                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa500Val(cConteudo)
Local cRet     := Space(Len(DVL->DVL_FILPAR) )

If ExistCpo("DVL", cConteudo, 1 )
	dbSelectArea("DVK")
	dbSetOrder(1)
	If MsSeek(xFilial("DVK")+DT6->DT6_CDRDES + cConteudo)
		cRet := Posicione("DVL",1,xFilial("DVL") + cConteudo,"DVL_FILPAR")
	Else
		Help(" ",1,"TMSA50039") //-- Nao existe Filial Alianca destino configurada.
	EndIf
EndIf
Return( cRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmA500TAli ³ Autor ³ Valdemar Roberto     ³ Data ³ 21/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Tudo Ok na tela para informar documento e filial alianca    ³±±
±±³          ³para quando esta passando um documento para ser alianca     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmA500TAli(nPercurso,cFilAli,cFilDpc,cCtrDpc,nParceiro)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExpN1 - Percurso do conhecimento 1= primeiro 2=segundo     ³±±
±±³          ³cExpC1 - Filial Alianca                                     ³±±
±±³          ³cExpC2 - Filial Despachante                                 ³±±
±±³          ³cExpC3 - CTRC Alianca                                       ³±±
±±³          ³nExpN2 - Parceiro utilizado no conhecimento                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmA500TAli(nPercurso,cFilAli,cFilDpc,cCtrDpc,nParceiro)
Local lRet := .T.
If nPercurso == 2 .And.  ( Empty(cFilDpc) .Or. Empty(cCtrDpc) .Or. Empty(cFilAli) )
	Help("",1,'Obrigat2',,)
	lRet := .F.
EndIf
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Obs³ Autor ³ Rodolfo K Rosseto     ³ Data ³03.04.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Observacao do CTRC de Complemento                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA500Obs                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500Obs(nOpcx)

Local oDlgObs
Local nOpcao   := 0
Local cObsMsg  := _cObsComp

DEFINE MSDIALOG oDlgObs TITLE STR0146 FROM 15,20 TO 25,62 //"Observacao"

@ 0.5,0.7  GET oGet VAR _cObsComp OF oDlgObs MEMO SIZE 150,40

If nOpcx == 2 .Or. nOpcx == 7
	oGet :lReadOnly:= .T.
EndIf

DEFINE SBUTTON FROM 52,100 TYPE 1 OF oDlgObs ENABLE ACTION (nOpcao := 1,oDlgObs:End())
DEFINE SBUTTON FROM 52,128 TYPE 2 OF oDlgObs ENABLE ACTION (nOpcao := 0,oDlgObs:End())

ACTIVATE MSDIALOG oDlgObs CENTERED

If nOpcao == 0
	_cObsComp := cObsMsg
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tm500BLin ³ Autor ³ Rodolfo K Rosseto     ³ Data ³30.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os campos a serem exibidos na tela                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExpN1 - Posicao do Array na chamada da funcao              ³±±
±±³          ³aExpA2 - Array com os campos do ListBox                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tm500BLin                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tm500BLin(nAt,aList)

Local abLine    := {}
Local nCont     := 0

If nAt > Len(aList)
	Return( abLine )
EndIf

For nCont := 1 To Len(aList[nAT])
	AAdd( abLine, aList[nAT,nCont])
Next nCont

Return( abLine )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transacao a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef(lVisual,lAlianca)
Local lTMSCTe 	:= SuperGetMv( "MV_TMSCTE", .F., .F. )

Private aRotina   := {	{STR0002,'AxPesqui'   , 0, 1,0,.F. },; //'Pesquisar'
						{   STR0003,'TmsA500Mnt' , 0, 2,0,Nil } } //'Visualizar'

Private aRotCCE   := {	{STR0206 	,'TMSAE90'      , 0, 2,0,Nil } 	  ,; //'Carta de Correção'
						{   STR0207	,'TMS500Exp(2)', 0, 2,0,Nil }    ,; //'Exporta XML da Carta de Correção'
						{   STR0208	,'mntCCe()'     , 0, 2,0,Nil } }    //'Exporta XML da Carta de Correção'

Private aRotDES := {	{   STR0264	,'TMSPedMDes' , 0, 16,0,Nil } }    //'Monitor Ev. Des'

Private aCteAnula := {   {STR0240,'TmsA500Anu'  , 0, 12,0,.F. },; //'Gera Anulação'
						{    STR0241,'CanAnula'    , 0, 14,0,Nil } }  //'Can. Anulação'

Private aMntTransp	:= {   {STR0303,'TmsA500Mnt'  , 0, 9,0,Nil },; //'Manut. Transp. por Doc.'
							{ STR0304,'T500QryDoc()' , 0, 16,0,Nil } }  //'Manut. Transp. em Lote'
 
If Type("lTM500Auto") == "U"
	lTM500Auto := .F.
EndIf

If	! lVisual       

	AAdd( aRotina, {STR0004,'TmsA500Cob', 0, 4,0,Nil } ) //'Devolucao'
	AAdd( aRotina, {STR0005,'TmsA500Cob', 0, 5,0,Nil } ) //'Reentrega'
	AAdd( aRotina, {STR0006,'TmsA500Cob', 0, 6,0,Nil } ) //'Complemento'
	AAdd( aRotina, {STR0054,'TmsA500Mnt', 0, 7,0,Nil } ) //"Cancelamento"
	If lAlianca
		AAdd( aRotina, {STR0064,'TmsA500Mnt', 0, 8,0,Nil } ) //"Manut. Alianca"
	EndIf

	//--Manut Transp. 
	If ExistFunc("TMA500AX1") .And. TMA500AX1()
		If !lTM500Auto
			AAdd( aRotina, {STR0072, aMntTransp  , 0, 9   ,0,Nil } ) //"Manut. Transp."
		Else
			aEval(aMntTransp,{|aItSubMnu| aAdd(aRotina,aClone(aItSubMnu)) })
		EndIf
	Else 
		AAdd( aRotina, {STR0072,'TmsA500Mnt', 0, 9	,0,Nil } ) //"Manut. Transp"
	EndIf 
	AAdd( aRotina, {STR0105,'TmsA500Mnt', 0, 10	,0,Nil } ) //"Complemento de Impostos"
	AAdd( aRotina, {STR0131,'TmsA500Mnt', 0, 11	,0,Nil } ) //"Armazenagem"
	AAdd( aRotina, {STR0132,'TmsA500Arm', 0, 4	,0,Nil } ) //"Pendênc Armaz"
	If !lTM500Auto
		AAdd( aRotina, {STR0160, aCteAnula  , 0, 15   ,0,Nil } ) //"Anulacao"
	Else
		aEval(aCteAnula,{|aItSubMnu| aAdd(aRotina,aClone(aItSubMnu)) })
	EndIf
	Aadd( aRotina, {STR0180,'TmsA500Mnt', 0, 13,0,NIL } ) //"Substituicao"
EndIf
AAdd( aRotina, {STR0106,"MsDocument", 0, 4,0,Nil } ) //"Bco.Conhecimento"
AAdd( aRotina, {STR0055,'TmsA500Leg()', 0, 7,0,.F. } ) //"Legenda"
If !lTM500Auto
	AAdd( aRotina, {STR0205, aRotCCE	 , 0, 2,0,Nil } ) //'Carta de Correção'
Else
	aEval(aRotCCE,{|aItSubMnu| aAdd(aRotina,aClone(aItSubMnu)) })
EndIf
AAdd( aRotina, {STR0263, aRotDES	, 0, 15,0,Nil } ) //'Ev. Desacordo'

If lTMSCTe
	AAdd( aRotina, {STR0175, "TMSAE70(2)", 0 ,2 } ) //"Ct-e"
EndIf

AAdd( aRotina, {STR0074, "TmsA500Comp(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)", 0 ,2 } ) //"Doc. Com."

//-- Chamada da tela de histórico do MDF-e
If TableIndic("DLH",.F.) .And. ExistFunc("TMSA190A(2)")
	Aadd(aRotina, { STR0286, "TMSA190A(2)" ,0, 2 }) //"Histórico MDF-e"
EndIf 	

If ExistBlock("TM500MNU")
	ExecBlock("TM500MNU",.F.,.F.)
EndIf

Return( aRotina )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Seg³ Autor ³Wellington A Santos    ³ Data ³18/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualizacao de indenizacoes vinculadas ao documento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa500Seg()

Local aArea      := GetArea()
Local aAreaDUB   := DUB->(GetArea())
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}
Local oListBox
Local aSize      := MsAdvSize(.T.)
Local cSeekDUB   := xFilial("DUB") + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE
Local bSeekDUB   := { || DUB->DUB_FILIAL + DUB->DUB_FILDOC + DUB->DUB_DOC + DUB->DUB_SERIE }
Local aHeadTst   := {}
Local oDlgInden
Local aHeadBkp
Local aColsBkp
Local nCount
Local aNoFields := {}
Local aRet      := {}
//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

If type("aHeader") == "A" .And. type("aCols") == "A"
	aHeadBkp := Aclone(aHeader)
	aColsBkp := Aclone(aCols)
	aHeader  := {}
	aCols    := {}
Else
	Private aHeader := {}
	Private aCols   := {}
EndIf
CursorWait()

AAdd(aNoFields,"DUB_ITEM")
AAdd(aNoFields,"DUB_ESTORN")

//-- Monta aHeader e aCols
aRet := TMSFillGetDados( 2, "DUB", 3 , cSeekDUB , bSeekDUB,,aNoFields,,,,.T.)

For nCount := 1 To Len(aHeader)
	AAdd( aHeadTst , aHeader[nCount,1] )
Next nCount

CursorArrow()

If Len(aRet) > 0

	aObjects := {}
	AAdd( aObjects, { 100, 100 , .T., .T.,.T. } )

	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ] / 1.5 , 0, 0 }
	aPosObj := MsObjSize( aInfo, aObjects)

	DEFINE MSDIALOG oDlgInden FROM aSize[7], 000 TO aSize[6]/1.35 ,aSize[5]  TITLE STR0149 OF oMainWnd PIXEL   //"Indeniz."

	oListBox := TWBrowse():New( aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4] , Nil, ;
                                 aHeadTst, Nil, oDlgInden, Nil, Nil, Nil,,,,,,,,,, "ARRAY", .T. )
	oListBox:SetArray( aCols )
	oListBox:bLine:= &('{ || Tm500BLin(oListBox:nAT,aCols) }')
	ACTIVATE MSDIALOG oDlgInden CENTERED ON INIT EnchoiceBar( oDlgInden, { || nOpca := 1,oDlgInden:End()}, {||oDlgInden:End()},,)
Else
	Help( " ", 1,'TMSA50091')	//-- "Não há dados para esta operação"
EndIf

RestArea(aAreaDUB)
RestArea(aArea)

If Valtype(aHeadBkp) == "A" .And. Valtype(aColsBkp) == "A"
	aHeader := Aclone(aHeadBkp)
	aCols   := Aclone(aColsBkp)
EndIf
//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500Pen³ Autor ³Helio Novais           ³ Data ³03/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualizacao de Pendencias   vinculadas ao documento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA500Pen()

Local cTitulo   := STR0003
Local cAlias    := "DUU"
Local cFiltro   := ""
Local aCampos   := {}
Local aOldRot   := aRotina
Local aRotina   := {}
Local oDUUStru  := FwFormStruct(2,cAlias) 
Local nx        := 1
Private nOpcSel := 0

AAdd( aRotina, { STR0003,"TMSA540Mnt",0,2} )

//-- Define os campos do Browse.

While nx <= Len(oDUUStru:aFields)
	If GetSX3Cache(oDUUStru:aFields[nx,1],"X3_BROWSE") == "S"
		AAdd( aCampos, oDUUStru:aFields[nx,1] )
	EndIf
	nx ++
EndDo

DUU->(DbSetOrder(3))
cFiltro := '"'+xFilial("DUU")+M->DT6_FILDOC+M->DT6_DOC+M->DT6_SERIE+'"'
MaWndBrowse(0,0,300,600,cTitulo,cAlias,aCampos,aRotina,,cFiltro,cFiltro,.T.)

aRotina := aOldRot

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500RED³ Autor ³ Andre Godoi           ³ Data ³12.12.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carregar o Redespachante do Documento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA500RED()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500RED()
Local cAliasNew  := GetNextAlias()
Local cQuery     := ''
Local aARea  		:= GetArea()

cQuery := "SELECT DFV.DFV_NUMRED, DFV.DFV_CODFOR, DFV.DFV_LOJFOR, SA2.A2_NOME "
cQuery += "  FROM " + RetSqlName("DFV") + " DFV "
cQuery += "       INNER JOIN " + RetSqlName("SA2") + " SA2 ON (SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND SA2.A2_COD = DFV.DFV_CODFOR AND SA2.A2_LOJA = DFV.DFV_LOJFOR) "
cQuery += " WHERE DFV.DFV_FILDOC = '" + M->DT6_FILDOC + "' AND DFV.DFV_DOC = '" + M->DT6_DOC + "' AND DFV.DFV_SERIE = '" + M->DT6_SERIE + "' AND DFV.D_E_L_E_T_ = ' '"
cQuery += "   AND DFV.DFV_NUMRED = (SELECT (MAX(DFV_1.DFV_NUMRED)) FROM " + RetSqlName("DFV") + " DFV_1 "
cQuery += "   WHERE DFV_1.DFV_FILDOC = '" + M->DT6_FILDOC + "' AND DFV_1.DFV_DOC = '" + M->DT6_DOC + "' AND DFV_1.DFV_SERIE = '" + M->DT6_SERIE + "' AND DFV_1.D_E_L_E_T_ = ' ')"
cQuery += " AND SA2.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

If (cAliasNew)->(!Eof())
		M->DT6_NUMRED	:= (cAliasNew)->DFV_NUMRED
		M->DT6_CODRED	:= (cAliasNew)->DFV_CODFOR
		M->DT6_LOJRED	:= (cAliasNew)->DFV_LOJFOR
		M->DT6_NOMRED	:= (cAliasNew)->A2_NOME
EndIf
(cAliasNew)->(dBCloseArea())

RestArea(aArea)
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmA500MIC  ³ Autor ³ Richard Anderson     ³ Data ³ 04/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna os MIC/DTA do documento                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmA500MIC()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmA500MIC()

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

If !Empty(DT6->DT6_NUMVGA)
	TmsVisMIC(DT6->DT6_FILVGA,DT6->DT6_NUMVGA)
Else
	Help('',1,'TMSA50032') //"Carregamento nao executado!"
EndIf

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TmA500FPais³ Autor ³ Richard Anderson    ³ Data ³30.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe o Frete por Pais do Documento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpC1 - Filial do Documento                               ³±±
±±³          ³ cExpC2 - No. Documento                                     ³±±
±±³          ³ cExpC3 - Serie do Documento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmA500FPais(cFilDoc,cDoc,cSerie)                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmA500FPais(cFilDoc,cDocto,cSerie)

Local cTitulo   := STR0152 //"Frete por País"
Local cAlias    := "DI9"
Local cFiltro   := ""
Local aCampos   := {}
Local aOldRot   := aRotina
Local aRotina   := {}
Local lPesq     := .F.
Local oDI9Stru  := FwFormStruct(2,cAlias)
Local nx        := 1
Private nOpcSel := 0

//-- Define os campos do Browse.

While nx <= Len(oDI9Stru:aFields)
	If GetSX3Cache(oDI9Stru:aFields[nx,1], "X3_BROWSE") == "S"
		AAdd( aCampos, oDI9Stru:aFields[nx,1] )
	EndIf
	nx ++
EndDo

DI9->(dbSetOrder(2))

cFiltro := '"'+xFilial("DI9")+cFilDoc+cDocto+cSerie+'"'
MaWndBrowse(0,0,300,600,cTitulo,cAlias,aCampos,aRotina,,cFiltro,cFiltro,.T.,,,,,,,,lPesq)

aRotina := aOldRot

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TmA500FDAF ³ Autor ³ Richard Anderson    ³ Data ³30.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe o Frete CIF/FOB                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExpC1 - Filial do Documento                       		  ³±±
±±³          ³ cExpC2 - No. Documento                                     ³±±
±±³          ³ cExpC3 - Serie do Documento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmA500FDAF(cFilDoc,cDoc,cSerie)                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmA500FDAF(cFilDoc,cDocto,cSerie)

Local cTitulo   := STR0154 //"Frete CIF/FOB"
Local cAlias    := "DIA"
Local cFiltro   := ""
Local aCampos   := {}
Local aOldRot   := aRotina
Local aRotina   := {}
Local lPesq     := .F.
Local oDIAStru  := FwFormStruct(2,cAlias)
Local nx        := 1

Private nOpcSel := 0

//-- Define os campos do Browse.
While nx <= Len(oDIAStru:aFields)
	If GetSX3Cache(oDIAStru:aFields[nx,1],"X3_BROWSE") == "S"
		AAdd( aCampos, oDIAStru:aFields[nx,1] )
	EndIf
	nx ++
EndDo

DIA->(dbSetOrder(2))
cFiltro := '"'+xFilial("DIA")+cFilDoc+cDocto+cSerie+'"'
MaWndBrowse(0,0,300,600,cTitulo,cAlias,aCampos,aRotina,,cFiltro,cFiltro,.T.,,,,,,,,lPesq)

aRotina := aOldRot

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TM500CDoc ºAutor  ³Telso Carneiro      º Data ³  31/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualizacao do custo do Documento                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA500                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM500CDoc(oDlgEsp)

Local cCadastro := STR0190 //-- "Custo do Documento"
Local oPanSoma
Local oDlgCusto
//-- Calcula as dimensoes dos objetos.
Local aSize    := MsAdvSize( .T. )
Local oListBox
Local aHDados  := {}
Local aDados   := {}
Local cQuery   := ''
Local cAliasQry:= CriaTrab(Nil,.F.)
Local nCont    := 0
Local oTot1
Local oTot2
Local oTot3
Local oTot4
Local oTot5
Local nTota1 := 0
Local nTota2 := 0
Local nTota3 := 0
Local nTota4 := 0
Local nTota5 := 0
Local aARea  := GetArea()

SaveInter()

AAdd(aHDados,"Item")
AAdd(aHDados,RetTitle("DFN_CODDES") )
AAdd(aHDados,RetTitle("DT7_DESCRI") )
AAdd(aHDados,RetTitle("DFN_CUSTO1") )
AAdd(aHDados,RetTitle("DFN_CUSTO2") )
AAdd(aHDados,RetTitle("DFN_CUSTO3") )
AAdd(aHDados,RetTitle("DFN_CUSTO4") )
AAdd(aHDados,RetTitle("DFN_CUSTO5") )

cQuery := "SELECT DFN.*, DT7.DT7_DESCRI "
cQuery += " FROM "+RetSqlName("DFN")+" DFN "
cQuery += " 	JOIN "+RetSqlName("DT7")+" DT7 ON DT7.DT7_CODDES = DFN.DFN_CODDES "
cQuery += " WHERE DFN.DFN_FILIAL = '"+xFilial("DFN")+"' "
cQuery += "   AND DFN.DFN_FILDOC = '"+DT6->DT6_FILDOC+"' "
cQuery += "   AND DFN.DFN_DOC    = '"+DT6->DT6_DOC+"' "
cQuery += "   AND DFN.DFN_SERIE  = '"+DT6->DT6_SERIE+"' "
cQuery += "   AND DFN.D_E_L_E_T_ = ' '"
cQuery += "   AND DT7.DT7_FILIAL = '"+xFilial("DT7")+"' "
cQuery += "   AND DT7.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY DFN_IDCTMS, DFN_CODDES"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

TCSetField(cAliasQry,"DFN_CUSTO1","N",TamSx3("DFN_CUSTO1")[1],TamSx3("DFL_CUSTO1")[2])
TCSetField(cAliasQry,"DFN_CUSTO2","N",TamSx3("DFN_CUSTO2")[1],TamSx3("DFL_CUSTO2")[2])
TCSetField(cAliasQry,"DFN_CUSTO3","N",TamSx3("DFN_CUSTO3")[1],TamSx3("DFL_CUSTO3")[2])
TCSetField(cAliasQry,"DFN_CUSTO4","N",TamSx3("DFN_CUSTO4")[1],TamSx3("DFL_CUSTO4")[2])
TCSetField(cAliasQry,"DFN_CUSTO5","N",TamSx3("DFN_CUSTO5")[1],TamSx3("DFL_CUSTO5")[2])

nTota1 := 0
nTota2 := 0
nTota3 := 0
nTota4 := 0
nTota5 := 0
nCont++
While (cAliasQry)->(!Eof())
	AAdd(aDados,{StrZero(nCont++,2),(cAliasQry)->DFN_CODDES,(cAliasQry)->DT7_DESCRI,(cAliasQry)->DFN_CUSTO1,(cAliasQry)->DFN_CUSTO2,(cAliasQry)->DFN_CUSTO3,(cAliasQry)->DFN_CUSTO4,(cAliasQry)->DFN_CUSTO5 })
	nTota1 += (cAliasQry)->DFN_CUSTO1
	nTota2 += (cAliasQry)->DFN_CUSTO2
	nTota3 += (cAliasQry)->DFN_CUSTO3
	nTota4 += (cAliasQry)->DFN_CUSTO4
	nTota5 += (cAliasQry)->DFN_CUSTO5
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())
RestArea(aArea)

If Empty(aDados)
	Help('',1,'TMSA50092')
Else

	DEFINE MSDIALOG oDlgCusto TITLE cCadastro FROM aSize[7],00 TO (aSize[6]/1.5),aSize[5] PIXEL

	oListBox := TWBrowse():New( aSize[7],00,aSize[6],aSize[5],,aHDados,,oDlgCusto,,,,,,,,,,,,,"ARRAY",.T.)
	oListBox:SetArray( aDados )

	// Ajusta alinhamento do TWBrowse para pegar o dialogo inteiro
	oListBox:Align := CONTROL_ALIGN_ALLCLIENT
	oListBox:bLine := {|| aDados[oListBox:nAT] }

	@000,000 MSPANEL oPanSoma PROMPT STR0189 SIZE 025,030 OF oDlgCusto //-- "Totais"
	oPanSoma:Align := CONTROL_ALIGN_BOTTOM

	@ 10, 05 SAY RetTitle("DFN_CUSTO1")  SIZE 43, 10 OF oPanSoma PIXEL COLOR CLR_BLUE
	@ 10, 45 MSGET oTot1 VAR nTota1 PICTURE PesqPict('DFN','DFN_CUSTO1') When .F. SIZE 50, 10 OF oPanSoma PIXEL

	@ 10,105 SAY RetTitle("DFN_CUSTO2")  SIZE 43, 10 OF oPanSoma PIXEL COLOR CLR_BLUE
	@ 10,145 MSGET oTot2 VAR nTota2 PICTURE PesqPict('DFN','DFN_CUSTO2') When .F. SIZE 50, 10 OF oPanSoma PIXEL

	@ 10,205 SAY RetTitle("DFN_CUSTO3")  SIZE 43, 10 OF oPanSoma PIXEL COLOR CLR_BLUE
	@ 10,245 MSGET oTot3 VAR nTota3 PICTURE PesqPict('DFN','DFN_CUSTO3') When .F. SIZE 50, 10 OF oPanSoma PIXEL

	@ 10,305 SAY RetTitle("DFN_CUSTO4")  SIZE 43, 10 OF oPanSoma PIXEL COLOR CLR_BLUE
	@ 10,345 MSGET oTot4 VAR nTota4 PICTURE PesqPict('DFN','DFN_CUSTO4') When .F. SIZE 50, 10 OF oPanSoma PIXEL

	@ 10,405 SAY RetTitle("DFN_CUSTO5")  SIZE 43, 10 OF oPanSoma PIXEL COLOR CLR_BLUE
	@ 10,445 MSGET oTot5 VAR nTota5 PICTURE PesqPict('DFN','DFN_CUSTO5') When .F. SIZE 50, 10 OF oPanSoma PIXEL

	ACTIVATE MSDIALOG oDlgCusto ON INIT EnchoiceBar(oDlgCusto,{|| oDlgCusto:End() }, {|| oDlgCusto:End() } )
EndIf

RestInter()
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA500FILº Autor ³Andre Sperandio     º Data ³  23/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna Filial do documento de Reentrega                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA500                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500FIL()

Local cAliasNew := GetNextAlias()
Local cQuery    := ''
Local cFilDT6   := ''

cQuery := "SELECT DT6_FILDES  "
cQuery += "  FROM " +RetSqlName("DT6")+ " DT6 "
cQuery += "  JOIN " +RetSqlName("DUD")+ " DUD "
cQuery += "    ON DUD_FILIAL = '" +xFilial("DUD")+ "'"
cQuery += "   AND DUD_FILDOC = DT6_FILDOC "
cQuery += "   AND DUD_DOC    = DT6_DOC    "
cQuery += "   AND DUD_SERIE  = DT6_SERIE  "
cQuery += "   AND DUD_FILVGE <> ' '       "
cQuery += "   AND DUD_NUMVGE <> ' '       "
cQuery += "   AND DUD.D_E_L_E_T_ = ' '    "
cQuery += " WHERE DT6_FILDES = '" +cFilAnt+ "'"
cQuery += "   AND DT6_FILIAL = '" +xFilial("DT6")+ "'"
cQuery += "   AND DT6.D_E_L_E_T_ = ' '    "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

If (cAliasNew)->(!Eof())
	If DT6->DT6_FILDES = cFilAnt 
		cFilDT6 := DT6->DT6_FILDES
	Else
		cFilDT6 := DT6->DT6_FILORI
	EndIf
EndIf

(cAliasNew)->(dbCloseArea())

Return( cFilDT6 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA500RDPº Autor ³Andre Godoi         º Data ³  06/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o Doc. e' de Redespacho.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Logico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500RDP()

Local cAliasNew := GetNextAlias()
Local cQuery    := ''
Local lRet      := .T.

cQuery := "SELECT DFV.DFV_NUMRED  "
cQuery += "  FROM " + RetSqlName("DFV")+ " DFV "
cQuery += "  WHERE "
cQuery += "	      DFV.DFV_FILIAL = '" + xFilial("DFV") + "'"
cQuery += "   AND DFV.DFV_FILDOC = '" + DT6->DT6_FILDOC + "' "
cQuery += "   AND DFV.DFV_DOC    = '" + DT6->DT6_DOC    + "' "
cQuery += "   AND DFV.DFV_SERIE  = '" + DT6->DT6_SERIE  + "' "
cQuery += "   AND DFV.DFV_STATUS <>'" + StrZero( 9, Len( DFV->DFV_STATUS ) ) + "'"
cQuery += "   AND DFV.D_E_L_E_T_ <>'*'"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

If (cAliasNew)->(Eof())
	lRet := .F.
EndIf
(cAliasNew)->(dBCloseArea())

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA500CBX³ Autor ³ N3-DL                 ³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ X3_CBOX do campo DT6_STATUS                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA500CBX()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA500                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500CBX()
Local cRet := ""
Local nCnt := 0
Local aRet := TMSValField("DT6_STATUS",.F.,,.F.,.T.)

If ValType(aRet) == "A"
	For nCnt := 1 To Len(aRet)
		If !Empty(cRet)
			cRet += ";"
		EndIf
		cRet += aRet[nCnt,01] + "=" + aRet[nCnt,2]
	Next nCnt
EndIf

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tmsa500NFCºAutor  ³Microsiga           º Data ³  14/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz os vinculos dos CTRCs de Reentrega e Devolucao com os    º±±
±±º          ³Documetos do cliente nao entregue (DTC_NFENTR == '2')       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500NFC( cFilDoc, cDoc, cSerie, cNewFilDoc, cNewDoc, cNewSerie )

Local cQuery    := ""
Local cAliasDTC := ""
Local lmvPar03	:= VldExistX1('TMA500'/*Grupo do pergunte*/,'03'/*Ordem Parametro*/)
Local lDTCOK	:= DTC->(ColumnPos("DTC_OK")) > 0
Local lDTCRee	:= DTC->(ColumnPos("DTC_DOCREE")) > 0
Local aArea     := GetArea()

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""

TMS500Perg(.f.)
cAliasDTC := GetNextAlias()
If 	lmvPar03 .AND. MV_PAR03 == 1 //Geração por NF
cQuery := " SELECT DTC_FILORI, DTC_LOTNFC, DTC_NUMNFC, DTC_SERNFC, DTC_CODPRO, DTC_QTDVOL, DTC_CLIREM, DTC_LOJREM, DTC_PESO, DTC_VALOR, DTC_METRO3, DTC_PESOM3 "
	cQuery += "		FROM " + RetSqlName("DTC")
	cQuery += "		WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
	cQuery += "		  AND DTC_DOC = '" + cDoc + "' "
	cQuery += "		  AND DTC_SERIE = '" + cSerie + "' "
	cQuery += "		  AND DTC_FILDOC = '" + cFilDoc + "' "
	If !IsInCallStack("TMSA152")
		cQuery += "		  AND DTC_NFENTR = '2' "
	EndIf
	If lDTCOK
		cQuery += "		  AND DTC_OK <> '' "
	EndIf
	cQuery += "		  AND D_E_L_E_T_ = '' "
Else	
	cQuery := " SELECT DTC_FILORI, DTC_LOTNFC, DTC_NUMNFC, DTC_SERNFC, DTC_CODPRO, DTC_QTDVOL, DTC_CLIREM, DTC_LOJREM, DTC_PESO, DTC_VALOR, DTC_METRO3, DTC_PESOM3 "
	cQuery += "		FROM " + RetSqlName("DTC")
	cQuery += "		WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
	cQuery += "		  AND DTC_DOC = '" + cDoc + "' "
	cQuery += "		  AND DTC_SERIE = '" + cSerie + "' "
	cQuery += "		  AND DTC_FILDOC = '" + cFilDoc + "' "
	If !IsInCallStack("TMSA152")
		cQuery += "		  AND DTC_NFENTR = '2' "
	EndIf
	cQuery += "		  AND D_E_L_E_T_ = '' "		
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC)

While (cAliasDTC)->(!Eof())
	RecLock("DY4", .T.)
	DY4->DY4_FILIAL := xFilial("DY4")
	DY4->DY4_FILORI := (cAliasDTC)->DTC_FILORI
	DY4->DY4_LOTNFC := (cAliasDTC)->DTC_LOTNFC
	DY4->DY4_NUMNFC := (cAliasDTC)->DTC_NUMNFC
	DY4->DY4_SERNFC := (cAliasDTC)->DTC_SERNFC
	DY4->DY4_CODPRO := (cAliasDTC)->DTC_CODPRO
	DY4->DY4_QTDVOL := (cAliasDTC)->DTC_QTDVOL
	DY4->DY4_CLIREM := (cAliasDTC)->DTC_CLIREM
	DY4->DY4_LOJREM := (cAliasDTC)->DTC_LOJREM
	DY4->DY4_FILDOC := cNewFilDoc
	DY4->DY4_SERIE  := cNewSerie
	DY4->DY4_DOC    := cNewDoc

	MsUnLock()
	
	//desmarca a Nota Fiscal para uso em uma próxima reentrega/devolução
	If lDTCOK
		dbSelectArea("DTC")
		dbSetOrder( 2 ) //Filial+NumNf+SerNfc+CliRem+LojRem+Produto+Fil.Ori.+LoteNfc
		If MsSeek(xFilial("DTC")+(cAliasDTC)->DTC_NUMNFC+(cAliasDTC)->DTC_SERNFC+(cAliasDTC)->DTC_CLIREM+;
		(cAliasDTC)->DTC_LOJREM+(cAliasDTC)->DTC_CODPRO+(cAliasDTC)->DTC_FILORI+(cAliasDTC)->DTC_LOTNFC)  
			RecLock("DTC", .F.)			
			If lDTCRee
				DTC->DTC_DOCREE := "1"	
			Endif 
			DTC->DTC_OK := SPACE(Len(DTC->DTC_OK)) 
			DTC->(MsUnLock())
		EndIf	
	EndIf	
		
	(cAliasDTC)->(DbSkip())
EndDo

RestArea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tmsa500AGDºAutor  ³Marcelo Coutinho    º Data ³  14/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Montar folder com os dados do agendamento de entrega       º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa500Agd(oWnd,aPosWnd)

Local aArea		:= GetArea()
Local aPosAgd  := {}
Local aBrwAgd  := {}
Local aHeadAgd := {}
Local aTamHead	:= {}
Local aCpoAgd	:= {}
Local nX       := 0
Local nY       := 0
Local oAgdEntr

Local aRetPrd  := RetSx3Box( Posicione('SX3', 2, 'DYD_PRDAGD', 'X3CBox()' ),,, Len(DYD->DYD_PRDAGD))
Local aRetTipo := RetSx3Box( Posicione('SX3', 2, 'DYD_TIPAGD', 'X3CBox()' ),,, Len(DYD->DYD_TIPAGD))

Aadd( aCpoAgd, "DYD_NUMAGD" )
Aadd( aCpoAgd, "DYD_ITEAGD" )
Aadd( aCpoAgd, "DYD_TIPAGD" )
Aadd( aCpoAgd, "DYD_DATAGD" )
Aadd( aCpoAgd, "DYD_PRDAGD" )
Aadd( aCpoAgd, "DYD_INIAGD" )
Aadd( aCpoAgd, "DYD_FIMAGD" )
Aadd( aCpoAgd, "DYD_DTCAGD" )
Aadd( aCpoAgd, "DYD_USUAGD" )
Aadd( aCpoAgd, "DYD_NOMUSR" )
Aadd( aCpoAgd, "DYD_MOTAGD" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os campos                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nX := 1 To Len(aCpoAgd)
	
	If X3USO(GetSx3Cache(aCpoAgd[nX],"X3_USADO")) 
		Aadd(aBrwAgd,{ aCpoAgd[nX],;
					   CriaVar(aCpoAgd[nX],.F.),;
					   GetSX3Cache(aCpoAgd[nX],"X3_PICTURE"),;
					   GetSX3Cache(aCpoAgd[nX],"X3_TITULO" ),;
					   GetSX3Cache(aCpoAgd[nX],"X3_TAMANHO")})
	EndIf
	
Next nX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o cabecalho com os titulos do DYD                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aBrwAGD)
	aadd(aHeadAgd,aBrwAgd[nX][4])
	If aBrwAgd[nX][5] > Len(aBrwAgd[nX][4])
		aadd(aTamHead,aBrwAgd[nX][5]*3)
	Else
		aadd(aTamHead,Len(aBrwAgd[nX][4])*3)
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os itens de visualizacao da ListBox.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPosAgd   := TMSA018Fil()
aItensAgd := {}

If Len(aPosAgd) = 0 // se nao existir registro inclui apenas o cabecalho com o nome dos campos
	Aadd( aItensAgd, Array(Len(aCpoAgd)))
Else
	For nX := 1 To Len(aPosAgd)
	
		DYD->(dbGoTo(aPosAgd[nX][1]))
	
		Aadd( aItensAgd, Array(Len(aCpoAgd)))
	
		For nY := 1 To Len(aBrwAgd)
	
			If aBrwAgd[nY,1] == "DYD_PRDAGD"
	
				aItensAgd[Len(aItensAgd)][nY] := aRetPrd[  Ascan( aRetPrd , { |x| AllTrim(x[2]) == AllTrim(DYD->(&(aBrwAgd[nY,1])))} ), 3 ]
	
			ElseIf aBrwAgd[nY,1] == "DYD_TIPAGD"
	
				aItensAgd[Len(aItensAgd)][nY] := aRetTipo[ Ascan( aRetTipo, { |x| AllTrim(x[2]) == AllTrim(DYD->(&(aBrwAgd[nY,1])))} ), 3 ]
	
				
			ElseIf aBrwAgd[nY,1] == "DYD_NOMUSR"
	
				aItensAgd[Len(aItensAgd)][nY] := USRRETNAME(DYD->DYD_USUAGD)
	
			Else
				If !Empty(aBrwAgd[nY,3])
					aItensAgd[Len(aItensAgd)][nY] := Transform( DYD->(&(aBrwAgd[nY,1])), aBrwAgd[nY,3])
	   		Else
					aItensAgd[Len(aItensAgd)][nY] := DYD->(&(aBrwAgd[nY,1]))
				EndIf
			EndIf
		Next nY
	Next nX
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o objeto listbox com os dados                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oAgdEntr := TWBrowse():New( aPosWnd[1],aPosWnd[2],aPosWnd[3],aPosWnd[4],,aHeadAgd,aTamHead,oWnd,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oAgdEntr:SetArray(aItensAgd)
oAgdEntr:bLine	:= { || { aItensAgd[oAgdEntr:nAT,1],;
								 aItensAgd[oAgdEntr:nAT,2],;
								 aItensAgd[oAgdEntr:nAT,3],;
								 aItensAgd[oAgdEntr:nAT,4],;
								 aItensAgd[oAgdEntr:nAT,5],;
								 aItensAgd[oAgdEntr:nAT,6],;
								 aItensAgd[oAgdEntr:nAT,7],;
								 aItensAgd[oAgdEntr:nAT,8],;
								 aItensAgd[oAgdEntr:nAT,9],;
								 aItensAgd[oAgdEntr:nAT,10],;
								 aItensAgd[oAgdEntr:nAT,11]}}


oAgdEntr:lAutoEdit := .F.

RestArea(aArea)

Return ( oAgdEntr )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Tms500LAgd³ Autor ³ Marcelo Coutinho      ³ Data ³12/01/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Exibe a legenda dos Agendamentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tms500LAgd()

Local aLegenda := {	{ "BR_VERDE"	, STR0185   },; //"Ativo"
							{ "BR_AMARELO"	, STR0186 	},; //"Histórico"
							{ "BR_PRETO"	, STR0187 	} } //"Cancelado"

BrwLegenda( "", STR0182 , aLegenda  )  //"Agendamento de Entrega"

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ T500ConfVl     ºAutor  ³ Rafael Souza  º Data ³  25/09/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe mensagem de confirmacao do valor do frete            º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Static Function T500ConfVl(nOpca) 

Local 	lTmsa050 := IsIncallStack(AllTrim('TMSA050'))	

Default nOpca 	 := 0

If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

If lTmsa050 .And. !lTM500Auto
	If MsgYesNo('Deseja assumir o valor do frete?',OemToAnsi(STR0067))
		nOpcA := 1
	EndIf	
Else
	nOpcA := 1		
EndIf            
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMsa500Cor     ºAutor  ³ Leandro Paulino³Data ³  17/11/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna as cores utilizadas na legenda      		           º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function TMsa500Cor()

Local aCores := {}

AAdd(aCores,{ "DT6_STATUS == '1' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'1')","BR_VERDE"    }) //-- Em aberto
AAdd(aCores,{ "DT6_STATUS == '2' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'2')","BR_VERMELHO" }) //-- Carregado ### Indicado para Coleta
AAdd(aCores,{ "DT6_STATUS == '3' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'3')","BR_AMARELO"  }) //-- Em transito
AAdd(aCores,{"(DT6_STATUS == '4' .And. DT6_SERIE <> 'COL' ) .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'5')","BR_LARANJA" }) //-- Chegada parcial ### Documento Informado
AAdd(aCores,{"(DT6_STATUS == '5' .And. DT6_SERIE <> 'COL' ) .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'4')","BR_AZUL"    }) //-- Chegada final   ### Encerrada
AAdd(aCores,{ "DT6_STATUS == '6'","BR_CINZA"	})	//-- Indicado p/ entrega
AAdd(aCores,{ "DT6_STATUS == '7'","BR_MARRON"	})	//-- Entregue
AAdd(aCores,{"TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'9')","BR_PRETO"	})	//-- Ordem de Coleta Cancelada
AAdd(aCores,{ "DT6_STATUS == '8'","BR_PINK"		})	//Entrega Parcial
AAdd(aCores,{ "DT6_STATUS == '9'","BR_CANCEL"	})	//Anulado
AAdd(aCores,{ "DT6_STATUS == 'A'","BR_BRANCO"	})	//Retorno Total
AAdd(aCores,{ "DT6_STATUS == 'B'","PMSEDT4"		})	//Cancelamento SEFAZ Aguardando
AAdd(aCores,{ "DT6_STATUS == 'C'","PMSEDT3"		})	//Cancelamento SEFAZ Autorizado
AAdd(aCores,{ "DT6_STATUS == 'D'","PMSEDT1"		})	//Cancelamento SEFAZ Nao Autorizado

Return aCores

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Tms500GFE      ºAutor  ³ Katia         º Data ³  22/10/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe valores calculados pelo SIGAGFE                      º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao SIGAGFE       		                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function Tms500GFE(oWnd,aPosWnd)

Local aArea		:= GetArea()
Local aBrwGfe   := {}
Local aHeadAgd  := {}
Local aTamHead	:= {}
Local aCpoGfe	:= {}
Local nX        := 0
Local oDadoGFE  := Nil       

Aadd( aCpoGfe, {"DESCRICAO" ,""		 ,35})    //Descricao
Aadd( aCpoGfe, {"QTDNOTA"   ,STR0201,12})     //Qtde Notas
Aadd( aCpoGfe, {"QTDVOL"    ,STR0202,14})     //Qtde Volumes
Aadd( aCpoGfe, {"PESO"      ,STR0203,18})     //Peso Real
Aadd( aCpoGfe, {"VALORMER"  ,STR0204,22})     //Valor Mercadoria
Aadd( aCpoGfe, {"VALOR"     ,STR0016,22})     //Valor
Aadd( aCpoGfe, {"IMPOSTO"   ,STR0017,18})     //Imposto
Aadd( aCpoGfe, {"VLRIMP"    ,STR0018,22})     //Valor + Imposto
Aadd( aCpoGfe, {"PORCENTAGEM","%"	,10})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os campos                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aCpoGfe)
  	Aadd(aBrwGfe,{aCpoGfe[nX][1],,,aCpoGfe[nX][2],aCpoGfe[nX][3]})
Next nX                          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o cabecalho com os titulos do DYD                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aBrwGfe)
	aadd(aHeadAgd,aBrwGfe[nX][4])
	If aBrwGfe[nX][5] > Len(aBrwGfe[nX][4])
		aadd(aTamHead,aBrwGfe[nX][5]*3)
	Else
		aadd(aTamHead,Len(aBrwGfe[nX][4])*3)
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os itens de visualizacao da ListBox.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aItensGfe:= Tms500GWM()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o objeto listbox com os dados                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aItensGfe) > 0 
	oDadoGFE:= TWBrowse():New( aPosWnd[1],aPosWnd[2],aPosWnd[3],aPosWnd[4],,aHeadAgd,aTamHead,oWnd,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oDadoGFE:SetArray(aItensGfe)
	oDadoGFE:bLine	:= { || { aItensGfe[oDadoGFE:nAT,10],;
								aItensGfe[oDadoGFE:nAT,2],;
								aItensGfe[oDadoGFE:nAT,3],;
								TransForm(aItensGfe[oDadoGFE:nAT,4],PesqPict('DT6','DT6_PESO')) ,;
								TransForm(aItensGfe[oDadoGFE:nAT,5],PesqPict('DT6','DT6_VALMER')) ,;
								TransForm(aItensGfe[oDadoGFE:nAT,6],PesqPict('GWM','GWM_VLFRET')) ,;
								TransForm(aItensGfe[oDadoGFE:nAT,7],PesqPict('GWM','GWM_VLICMS')) ,;
								TransForm(aItensGfe[oDadoGFE:nAT,8],PesqPict('GWM','GWM_VLFRET')) ,;
								aItensGfe[oDadoGFE:nAT,9]}}
EndIf
	
RestArea(aArea)
Return ( oDadoGFE )                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Tms500GWM      ºAutor  ³ Katia         º Data ³  22/10/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta array para exibicao dos valores do GFE               º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao SIGAGFE       		                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function Tms500GWM()
Local nPos       := 0
Local aRet       := {}
Local cQuery     := ""
Local aAreaAtu   := GetArea()
Local cAliasDTC  := ""
Local cTPDCTMS   := SuperGetMV("MV_TPDCTMS",,"") 
Local cCdTpDc    := Padr(cTPDCTMS,Len(GW1->GW1_CDTPDC)) //SubStr(Posicione("SX5",1,xFilial("SX5")+"MQ"+cTPDCTMS+"S","X5_DESCRI"),1,TamSx3("GW1_CDTPDC")[1])
Local cEmisDc    := ""
Local lNumProp   := Iif(FindFunction("GFEEMITMP"),GFEEMITMP(),.F.)      //Parametro Numeracao
Local nGW8Qtde   := 0
Local nGW8PesoR  := 0
Local nGW8Valor  := 0                
Local nQtdNota   := 0
Local cCriRat    := GetNewPar("MV_CRIRAT", "1")

cAliasDTC := GetNextAlias()
cQuery := " SELECT DTC.DTC_NUMNFC, DTC.DTC_SERNFC, DTC.DTC_CLIREM, DTC.DTC_LOJREM, SUM(DTC.DTC_QTDVOL) QTDVOL, " + CRLF
cQuery += "	  SUM(DTC.DTC_PESO) NPESO,  SUM(DTC.DTC_VALOR) NVALOR" + CRLF
cQuery += "   FROM " + RetSqlName('DTC') + " DTC " + CRLF
cQuery += "  WHERE DTC.DTC_FILIAL	= '" + xFilial('DTC') + "'" + CRLF
If !Empty(DT6->DT6_DOCDCO)
	cQuery += "    AND DTC.DTC_FILDOC   = '" + DT6->DT6_FILDCO + "'" + CRLF
	cQuery += "    AND DTC.DTC_DOC      = '" + DT6->DT6_DOCDCO + "'" + CRLF
	cQuery += "    AND DTC.DTC_SERIE    = '" + DT6->DT6_SERDCO + "'" + CRLF
Else
	cQuery += "    AND DTC.DTC_FILDOC   = '" + DT6->DT6_FILDOC + "'" + CRLF
	cQuery += "    AND DTC.DTC_DOC      = '" + DT6->DT6_DOC    + "'" + CRLF
	cQuery += "    AND DTC.DTC_SERIE    = '" + DT6->DT6_SERIE  + "'" + CRLF
EndIf
cQuery += "  AND DTC.D_E_L_E_T_ = ' '" + CRLF
cQuery += "  GROUP BY DTC.DTC_NUMNFC, DTC.DTC_SERNFC, DTC.DTC_CLIREM, DTC.DTC_LOJREM " + CRLF
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDTC, .F., .T.)
While (cAliasDTC)->(!Eof())
	If lNumProp
		If FindFunction("GFEM011COD")
			cEmisDc:= GFEM011COD((cAliasDTC)->DTC_CLIREM,(cAliasDTC)->DTC_LOJREM,1,,) 
		EndIf
	Else
		cEmisDc:= Posicione("SA1",1,xFilial("SA1")+(cAliasDTC)->DTC_CLIREM+(cAliasDTC)->DTC_LOJREM,"A1_CGC") 
	EndIf    
    nQtdNota += 1
    
    //--- Total Frete a Receber - TMS
	If ( nPos := Ascan( aRet, { | e | e[1] == '0' } ) ) >  0
		aRet[nPos][2] := nQtdNota
		aRet[nPos][3] += (cAliasDTC)->QTDVOL                   
		aRet[nPos][4] += (cAliasDTC)->NPESO
		aRet[nPos][5] += (cAliasDTC)->NVALOR
	Else
		Aadd( aRet,{'0',nQtdNota,(cAliasDTC)->QTDVOL,(cAliasDTC)->NPESO,(cAliasDTC)->NVALOR,DT6->DT6_VALFRE,DT6->DT6_VALIMP,DT6->DT6_VALTOT,0,STR0198})    
	EndIf
        
	GW1->( dbSetOrder(1) ) 
	If GW1->( dbSeek( xFilial("GW1")+PadR(cCDTPDC,Len(GW1->GW1_CDTPDC))+cEmisDc+PadR((cAliasDTC)->DTC_SERNFC,Len(GW1->GW1_SERDC))+PadR((cAliasDTC)->DTC_NUMNFC,Len(GW1->GW1_NRDC)) ))		
		GW8->( dbSetOrder(1) )
		GW8->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC +GW1->GW1_NRDC ) )
		While !GW8->( Eof() ) .And. GW8->GW8_FILIAL == GW1->GW1_FILIAL .And. ;
			   GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .And. ;
			   GW8->GW8_EMISDC == GW1->GW1_EMISDC .And. ;
			   GW8->GW8_SERDC  == GW1->GW1_SERDC  .And. ;
			   GW8->GW8_NRDC   == GW1->GW1_NRDC
			   
			    nGW8Qtde += GW8->GW8_QTDE
  			    nGW8PesoR+= GW8->GW8_PESOR
   			    nGW8Valor+= GW8->GW8_VALOR			    
				GW8->(dbSkip())
		EndDo	  
	    
		GWM->( dbSetOrder(2) )
		GWM->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
		While !GWM->( Eof() ) .And. GWM->GWM_FILIAL == GW1->GW1_FILIAL .And. ;
		       GWM->GWM_CDTPDC == GW1->GW1_CDTPDC .And. ;
		       GWM->GWM_EMISDC == GW1->GW1_EMISDC .And. ;
		       GWM->GWM_SERDC  == GW1->GW1_SERDC  .And. ;
		       GWM->GWM_NRDC   == GW1->GW1_NRDC
		       
			If GWM->GWM_TPDOC == '1'                //--- Total Frete Provisao - Parceiro
				If ( nPos := Ascan( aRet, { | e | e[1] == '1' } ) ) > 0                                         
					aRet[nPos][2] := nQtdNota                    
					aRet[nPos][3] := nGW8Qtde                   
					aRet[nPos][4] := nGW8PesoR          
					aRet[nPos][5] := nGW8Valor              
					If cCriRat == "1"	// Peso da mercadoria					
						aRet[nPos][6] += (GWM->GWM_VLFRET - GWM->GWM_VLICMS)              		
						aRet[nPos][7] += GWM->GWM_VLICMS
						aRet[nPos][8] += GWM->GWM_VLFRET              		
					ElseIf cCriRat == "2"	// Valor da mercadoria
						aRet[nPos][6] += (GWM->GWM_VLFRE1 - GWM->GWM_VLICM1)              
						aRet[nPos][7] += GWM->GWM_VLICM1
						aRet[nPos][8] += GWM->GWM_VLFRE1              
					ElseIf cCriRat == "3"	// Volume da mercadoria
						aRet[nPos][6] += (GWM->GWM_VLFRE2 - GWM->GWM_VLICM2)              
						aRet[nPos][7] += GWM->GWM_VLICM2
						aRet[nPos][8] += GWM->GWM_VLFRE2
					ElseIf cCriRat == "4"	// Quantidade de itens
						aRet[nPos][6] += (GWM->GWM_VLFRE3 - GWM->GWM_VLICM3)
						aRet[nPos][7] += GWM->GWM_VLICM3
						aRet[nPos][8] += GWM->GWM_VLFRE3
					Endif
					aRet[nPos][9] := Round((aRet[nPos][8] / DT6->DT6_VALFRE * 100 ),2)
				Else   
					If cCriRat == '1'
						Aadd( aRet,{'1',nQtdNota,nGW8Qtde,nGW8PesoR,nGW8Valor,GWM->GWM_VLFRET - GWM->GWM_VLICMS,GWM->GWM_VLICMS,GWM->GWM_VLFRET,Round((GWM->GWM_VLFRET / DT6->DT6_VALFRE * 100),2),STR0199})     
					ElseIf cCriRat == '2'  
						Aadd( aRet,{'1',nQtdNota,nGW8Qtde,nGW8PesoR,nGW8Valor,GWM->GWM_VLFRE1 - GWM->GWM_VLICM1,GWM->GWM_VLICM1,GWM->GWM_VLFRE1,Round((GWM->GWM_VLFRE1 / DT6->DT6_VALFRE * 100),2),STR0199})     					
					ElseIf cCriRat == '3'
						Aadd( aRet,{'1',nQtdNota,nGW8Qtde,nGW8PesoR,nGW8Valor,GWM->GWM_VLFRE2 - GWM->GWM_VLICM2,GWM->GWM_VLICM2,GWM->GWM_VLFRE2,Round((GWM->GWM_VLFRE2 / DT6->DT6_VALFRE * 100),2),STR0199})     										
					ElseIf cCriRat == '4'
						Aadd( aRet,{'1',nQtdNota,nGW8Qtde,nGW8PesoR,nGW8Valor,GWM->GWM_VLFRE3 - GWM->GWM_VLICM3,GWM->GWM_VLICM3,GWM->GWM_VLFRE3,Round((GWM->GWM_VLFRE3 / DT6->DT6_VALFRE * 100),2),STR0199})     															
					EndIf	
				EndIf							 				                       				
			ElseIf GWM->GWM_TPDOC == '2'             //--- Total Frete Devido - Parceiro
				If ( nPos := Ascan( aRet, { | e | e[1] == '2' } ) ) > 0
					aRet[nPos][2] := nQtdNota
					aRet[nPos][3] := nGW8Qtde                   
					aRet[nPos][4] := nGW8PesoR          
					aRet[nPos][5] := nGW8Valor              					
					If cCriRat == "1"	// Peso da mercadoria					
						aRet[nPos][6] += (GWM->GWM_VLFRET - GWM->GWM_VLICMS)
						aRet[nPos][7] += GWM->GWM_VLICMS
						aRet[nPos][8] += GWM->GWM_VLFRET 
					ElseIf cCriRat == "2"	// Valor da mercadoria
						aRet[nPos][6] += (GWM->GWM_VLFRE1 - GWM->GWM_VLICM1)
						aRet[nPos][7] += GWM->GWM_VLICM1
						aRet[nPos][8] += GWM->GWM_VLFRE1
					ElseIf cCriRat == "3"	// Volume da mercadoria
						aRet[nPos][6] += (GWM->GWM_VLFRE2 - GWM->GWM_VLICM2)
						aRet[nPos][7] += GWM->GWM_VLICM2
						aRet[nPos][8] += GWM->GWM_VLFRE2
					ElseIf cCriRat == "4"	// Quantidade de itens
						aRet[nPos][6] += (GWM->GWM_VLFRE3 - GWM->GWM_VLICM3)
						aRet[nPos][7] += GWM->GWM_VLICM3
						aRet[nPos][8] += GWM->GWM_VLFRE3
					Endif
					aRet[nPos][9] := Round((aRet[nPos][8] / DT6->DT6_VALFRE * 100 ),2)
				Else
					If cCriRat == '1'
						Aadd( aRet,{'2',nQtdNota,nGW8Qtde,nGW8PesoR,nGW8Valor,GWM->GWM_VLFRET - GWM->GWM_VLICMS,GWM->GWM_VLICMS,GWM->GWM_VLFRET,Round((GWM->GWM_VLFRET / DT6->DT6_VALFRE * 100),2),STR0200})     
					ElseIf cCriRat == '2'
						Aadd( aRet,{'2',nQtdNota,nGW8Qtde,nGW8PesoR,nGW8Valor,GWM->GWM_VLFRE1 - GWM->GWM_VLICM1,GWM->GWM_VLICM1,GWM->GWM_VLFRE1,Round((GWM->GWM_VLFRE1 / DT6->DT6_VALFRE * 100),2),STR0200})     
					ElseIf cCriRat == '3'
						Aadd( aRet,{'2',nQtdNota,nGW8Qtde,nGW8PesoR,nGW8Valor,GWM->GWM_VLFRE2 - GWM->GWM_VLICM2,GWM->GWM_VLICM2,GWM->GWM_VLFRE2,Round((GWM->GWM_VLFRE2 / DT6->DT6_VALFRE * 100),2),STR0200})     					
					ElseIf cCriRat == '4'
						Aadd( aRet,{'2',nQtdNota,nGW8Qtde,nGW8PesoR,nGW8Valor,GWM->GWM_VLFRE3 - GWM->GWM_VLICM3,GWM->GWM_VLICM3,GWM->GWM_VLFRE3,Round((GWM->GWM_VLFRE3 / DT6->DT6_VALFRE * 100),2),STR0200})     					
					EndIf	
				EndIf			
			EndIf
			
			GWM->(dbSkip())
		EndDo
	EndIf
	(cAliasDTC)->(dbSkip())
EndDo
(cAliasDTC)->(dbCloseArea()) 
                
If Empty(aRet)  
	Aadd( aRet,{'0',,DT6->DT6_QTDVOL,DT6->DT6_PESO,DT6->DT6_VALMER,DT6->DT6_VALFRE,DT6->DT6_VALIMP,DT6->DT6_VALTOT,0,STR0198})    
EndIf

RestArea(aAreaAtu)
	 	   
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ mntCCeºAutor  ³ Fabio Marchiori Sampaioº Data ³  06/02/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega o Monitor dos eventos da carta de correção         º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CC-e para CTE                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Function mntCCe ()

Local nRecno := 0

	//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
	If !TMSAVerAge("1",DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,,,,,,,,"2",.T.,.T.)
		Return .F.
	EndIf

	DbSelectArea('SF2')
	DbSetOrder(1)
	If (DbSeek(xFilial('SF2') + DT6->DT6_DOC + DT6->DT6_SERIE))
		If !Empty(SF2->F2_IDCCE)
			nRecno := SF2->(RECNO())
			SpedCCeMnt("SF2",nRecno,3,.T.)
		Else
			Help( ,, 'HELP',, "Não há evento de carta de correção, para esse documento.", 1, 0)      
		EndIF
	Else
		Help( ,, 'HELP',, "Verifique se a filial e o número do documento estão corretos.", 1, 0)      
	EndIF

	//-- Limpa marcas dos agendamentos
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf

Return()

Static Function UsaColaboracao(cModelo)
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
endif
return (lUsa)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Tms500SLNF     ºAutor  ³ Ramon Prado   º Data ³  02/12/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.³Carrega na tela as Notas Fiscais a partir do documento de Transp.º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tms500SLNF(nOpc)
Local aArea		:= getArea()
Local lRetEnd		:= .F.
Local cFilDoc		:= ""
Local cDoc			:= ""
Local cSerie		:= ""
Local aOldRot		:= aRotina
Local cOldCad		:= cCadastro
Local lDTCRee		:= DTC->(ColumnPos("DTC_DOCREE")) > 0
Local cQuery		:= ""
Local cAliasQry		:= ""   

If Type("lMsErroAuto") == "U"
	Private lMsErroAuto:= .F.
EndIf
If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

l500Proc := .F.
aRotina := {}
cCadastro := STR0225 //"Seleção das Notas Fiscais do cliente para geração do documento de reentrega ou devolução"
AAdd( aRotina, { STR0003,"TmsA500Mnt",0,2} ) // "Visualizar"
AAdd( aRotina, { STR0258,"TmsA500CAR",0,3} ) // "Confirmar"

Private nOpcB := nOpc

If !Empty(M->DT6_FILDCO) .And. !Empty(M->DT6_DOCDCO) .And. !Empty(M->DT6_SERDCO)
	cFilDoc	:= M->DT6_FILDCO
	cDoc		:= M->DT6_DOCDCO
	cSerie		:= M->DT6_SERDCO
Else
	cFilDoc	:= M->DT6_FILDOC
	cDoc		:= M->DT6_DOC	
	cSerie		:= M->DT6_SERIE
EndIf

cAliasQry := GetNextAlias()
cQuery := " SELECT DTC_FILDOC,DTC_DOC"
cQuery += " FROM " + RetSqlTab("DTC")
cQuery += " WHERE DTC_FILIAL = '" + xFilial("DTC") + "'"
cQuery += "   AND DTC_FILDOC = '" + cFilDoc + "'"
cQuery += "   AND DTC_DOC    = '" + cDoc + "'"		
cQuery += "   AND DTC_SERIE    = '" + cSerie + "'"		
If !IsInCallStack("TMSA152")
	cQuery += "   AND DTC_NFENTR <> '1' "
	If lDTCRee
		cQuery += "   AND DTC_DOCREE <> '1' "
	EndIf
EndIf
cQuery += "   AND DTC.D_E_L_E_T_ = '' "	

cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

If (cAliasQry)->(EOF()) //não posicionou em nenhuma nota fiscal	
	lRetEnd := .T.
	Help( " ", 1, "TMSA500B8")	// "Não Existe Nota Fiscal a apresentar na tela. Verifique se há notas bloqueadas"
Endif

If !lRetEnd 
	If !lTM500Auto
		// Instanciamento do classe
		oMark := FWMarkBrowse():New() 
		
		// Definição da tabela a ser utilizada
		oMark:SetAlias('DTC')
			
		// Define a titulo do browse de marcacao
		oMark:SetDescription(STR0225) //--"Seleção das Notas Fiscais do cliente para geração do documento de reentrega ou devolução"
		
		// Define o campo que sera utilizado para a marcação
		oMark:SetFieldMark( 'DTC_OK' ) 
		
		// Definição do filtro de aplicacao
		oMark:SetFilterDefault( "DTC_FILIAL== '" + xFilial("DTC") +"' .And. DTC_FILDOC== '" + cFilDoc+ "' .And. DTC_DOC == '" + cDoc + "' .And. DTC_SERIE == '"+ cSerie +"' .And. DTC_NFENTR<>'1' "+If(lDTCRee,".And. DTC_DOCREE=='2' "," "))
		
		//Adiciona Legenda	
		oMark:AddLegend( "DTC->DTC_NFENTR == '3'", "RED"    , STR0242	)	//'Bloqueado'				 
		
		//Adiciona Legenda	
		oMark:AddLegend( "DTC->DTC_NFENTR == '2'", "Green"    , STR0243	)	//'Nao Entregue'
		
		//Valida a marcacao do registro	
		oMark:SetValid({|oMark| A500VldMrk(oMark)})  	
		
		// Ativacao da classe
		oMark:Activate()
	Else
		TmsA500CAR(,,2)
	EndIf
Endif

If !l500Proc
	lRetEnd := .T.
Endif

aRotina := aOldRot
cCadastro := cOldCad

(cAliasQry)->(DbCloseArea())		

RestArea(aArea)
Return lRetEnd

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TmsA500CAR     ºAutor  ³ Ramon Prado   º Data ³  03/12/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.³Função chamada na confirmacao da selecao de NFS de reentrega ou  º±±
±±ºDevolucao								   						      º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TmsA500CAR(cAlias,nRecno,nOpca)
Local aArea := getArea()
Local aClFre := {}	
Local aSays		:= {}
Local cCadOld	:= cCadastro 

cCadastro := STR0226 //"Seleção de Notas Fiscais de Reentrega ou Devolução"

Aadd( aSays, STR0227 )  //"Este programa tem como objetivo, confirmar a seleção das Notas Fiscais de Reentrega"
Aadd( aSays, STR0228 )  //"ou Devolução"

If nOpca == 2
	Processa( { | lEnd | aClFre := a500Proc( @lEnd) }, cCadastro,STR0229, .T. ) //"Confirmando Seleção de Notas Fiscais"
    If l500Proc
		CloseBrowse()
		aFrete := aClone(aClFre)
	Endif		
EndIf

cCadastro := cCadOld

RestArea(aArea)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VldExistX1     ºAutor  ³ Ramon Prado   º Data ³  05/12/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.³Verifica se existe no dicionário o parametro do pergunte 			º±± 
±±ºParametros:	cPergunte - Grupo do param - exemplo TMA500				º±±
±±º					cOrdParam - Ordem do param - exemplo 03					º±±	
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldExistX1(cPergunte,cOrdParam)
Local lRet := .T.
/*14/02/2018 - Função mantida por questão de compatibilidade, a mesma deve ser removida nas proxima resese expedida*/
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ a500Proc     ºAutor  ³ Ramon Prado   º Data ³  10/12/14	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.³Rotina de processamento do cálculo de reentrega ou devolução     º±± 
±±ºParametros:	lEnd - valor lógico que indica fim do processamento		º±±	
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a500Proc(lEnd)
Local aArea	:= getArea()
Local aAreaDUD := {}
Local cCliRem	:= DT6->DT6_CLIREM
Local cLojRem	:= DT6->DT6_LOJREM
Local cCliDes	:= DT6->DT6_CLIDES
Local cLojDes	:= DT6->DT6_LOJDES
Local cCliCal	:= DT6->DT6_CLICAL
Local cLojCal	:= DT6->DT6_LOJCAL
Local cTipFre	:= DT6->DT6_TIPFRE
Local cCdROri	:= DT6->DT6_CDRORI
Local cCdRCal   := M->DT6_CDRCAL
Local cSqeDes	:= ""
Local cCliDev	:= DT6->DT6_CLIDEV
Local cLojDev	:= DT6->DT6_LOJDEV
Local cCdrDes	:= M->DT6_CDRDES
Local nKm		:= ""  
Local cFilDoc	:= DT6->DT6_FILDOC
Local cDoc		:= DT6->DT6_DOC
Local cSerie	:= DT6->DT6_SERIE
Local cDesSrv := ""
Local lRotAuto := .F.
Local lMostra := .T.
Local aErrCal	:= {}
Local aTipVei	:= {}
Local aContrat	:= {}
Local aRetFrt   := {}
Local cOrdem	:= '  '		//-- O cOrdem foi inicializado com 2 espacos para forcar o componente de Reentrega p/1a linha
Local cCompEnt  := PadR(AllTrim(GetMV('MV_COMPENT')),TamSx3("DT3_CODPAS")[1])
Local cNContr 	:= "" 
Local cTabFre 	:= "" 
Local cTipTab 	:= ""
Local cTabAlt 	:= ""
Local cTipAlt 	:= "" 
Local cSeqTab 	:= "" 
Local cTipNFC 	:= ""
Local cSeqIns	:= ''
Local cQuery	:= ''
Local cAliasQry	:= ''
Local cQuery2	:= ''
Local cAliasQry2:= ''
Local lCliGen 	:= .F.
Local lAjuAut 	:= .F.
Local lRateio		:= .F.
Local cCodPro   := "" 
Local cSerTms	:= ""
Local cTipTra	:= ""
Local nValMer		:= 0
Local nPeso		:= 0 
Local nQtdVol		:= 0
Local nQtdUni		:= 0
Local nPesoM3		:= 0
Local nMetro3 		:= 0
Local lExistPerf	:= DUO->(FieldPos("DUO_TPCALC")) > 0
Local lDTCOK		:= DTC->(FieldPos("DTC_OK")) > 0
Local lMark			:= .F.
Local lDTC			:= .F.   
Local lDTCRee		:= DTC->(FieldPos("DTC_DOCREE")) > 0
Local lTM500ORI  	:= ExistBlock("TM500ORI")
Local lInvOri    	:= .F.

Default lEnd := .F.

Private aItContrat  := {}

If Type("lTM500Auto") == "U"
	Private lTM500Auto := .F.
EndIf

If !lTM500Auto
	cMarca	 := oMark:Mark()   // Marca da FwMarkBrowse
Else
	cMarca	 := GetMark() 
	lRotAuto := .T.
	lMostra  := .F.
EndIf

//desmarca marcacoes diferentes da marca atual
A500ApgMrk(cFilDoc,cDoc,cSerie,cMarca)
	
cTipTra	:= DT6->DT6_TIPTRA
cServic	:= M->DT6_SERVIC
			
aPerfil := TmsPerfil(cCliDev,cLojDev,,,cCliRem,cLojRem,cCliDes,cLojDes)

If Len(aPerfil) > 0 .AND. lExistPerf .AND. aPerfil[54] == "2" .AND. nOpcB != 4 //Cálculo "Por Trecho" .AND. Operação diferente de Devolução
	
	//--Verifica os registros da DUD gerados a partir do doc original da DT6
	cAliasQry := GetNextAlias()
	
	cQuery := " SELECT (MAX(R_E_C_N_O_)) R_E_C_N_O_"
	cQuery += " FROM " + RetSqlTab("DUD")
	cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
	cQuery += "   AND DUD_FILDOC = '" + cFilDoc + "'"
	cQuery += "   AND DUD_DOC    = '" + cDoc + "'"
	cQuery += "   AND DUD_SERIE  = '" + cSerie + "'"
	cQuery += "   AND DUD.D_E_L_E_T_ = '' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )
		
	If (cAliasQry)->(!Eof()) .And. (cAliasQry)->R_E_C_N_O_ > 0
		aAreaDUD := DUD->( GetArea() )
		DUD->(dbGoto((cAliasQry)->R_E_C_N_O_))		
		cSerTms	:= DUD->DUD_SERTMS
		RestArea( aAreaDUD )				
	EndIf	
	(cAliasQry)->( DbCloseArea() )
Endif

cAliasQry2 := GetNextAlias()
cQuery2 := " SELECT DTC_NUMNFC,DTC_SERNFC,DTC_CLIREM,DTC_LOJREM,DTC_CODPRO,DTC_FILORI,DTC_LOTNFC"
cQuery2 += " FROM " + RetSqlTab("DTC")
cQuery2 += " WHERE DTC_FILIAL = '" + xFilial("DTC") + "'"
cQuery2 += "   AND DTC_FILDOC = '" + cFilDoc + "'"
cQuery2 += "   AND DTC_DOC    = '" + cDoc + "'"		
cQuery2 += "   AND DTC_SERIE    = '" + cSerie + "'"		
If !IsInCallStack("TMSA152") 
	cQuery2 += "   AND DTC_NFENTR = '2' "
	If lDTCRee
		cQuery2 += "   AND DTC_DOCREE = '2' "
	EndIf
EndIf
cQuery2 += "   AND DTC.D_E_L_E_T_ = '' "	

cQuery2 := ChangeQuery(cQuery2)
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery2), cAliasQry2, .F., .T. )

If !lEnd
	While (cAliasQry2)->(!EOF())		
		DbSelectArea("DTC")
		DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto				
		If DTC->(MsSeek(xFilial("DTC")+(cAliasQry2)->DTC_NUMNFC+(cAliasQry2)->DTC_SERNFC+(cAliasQry2)->DTC_CLIREM+(cAliasQry2)->DTC_LOJREM+(cAliasQry2)->DTC_CODPRO+(cAliasQry2)->DTC_FILORI+(cAliasQry2)->DTC_LOTNFC)) 
			If lTM500Auto 
				If  DTC->(Get500NfAu(DTC_NUMNFC,DTC_SERNFC,DTC_CLIREM,DTC_LOJREM,DTC_CODPRO,DTC_FILORI,DTC_LOTNFC)) > 0 .And. A500VldMrk()
			   		lDTC :=.T.
					RecLock("DTC",.F.)
					DTC->DTC_OK := cMarca
					DTC->(MsUnlock()) 							
				EndIf 
			Else
				lDTC :=.T.
			 	If oMark:IsInvert()   //inverte marcacao
					If DTC->DTC_OK == cMarca
						RecLock("DTC",.F.)
						DTC->DTC_OK := SPACE(Len(DTC->DTC_OK))
						DTC->(MsUnlock())					   		
					Else
						RecLock("DTC",.F.)
						DTC->DTC_OK := cMarca
						DTC->(MsUnlock()) 							
					EndIf	
				EndIf
    		EndIf
			If lDTCOK .AND. cMarca == DTC->DTC_OK
				lMark := .T. //Indica que pelo menos um registro foi marcado	
				l500Proc := .T. //Indica que havera processamento			
				nQtdVol += DTC->DTC_QTDVOL
				nPeso   += DTC->DTC_PESO
				nValMer += DTC->DTC_VALOR
				nQtdUni += DTC->DTC_QTDUNI
				nPesoM3 += DTC->DTC_PESOM3
				nMetro3 += DTC->DTC_METRO3								
				cCodPro := DTC->DTC_CODPRO				
			Endif	
		EndIf
		(cAliasQry2)->(DbSkip())			
	EndDo
	
	If lMark == .F.
		Help( " ", 1, "TMSA500B8")	// "Nenhuma Nota Fiscal foi selecionada na tela
		l500Proc := .F.	
	Endif
		
	If l500Proc		
		M->DT6_QTDVOL := nQtdVol
		M->DT6_PESO	:= nPeso
		M->DT6_VALMER := nValMer
		M->DT6_QTDUNI := nQtdUni
		M->DT6_METRO3 := nMetro3
		M->DT6_PESOM3 := nPesoM3
	Endif
			
	If lDTC .And. Len(aPerfil) > 0 .AND. lExistPerf .AND. aPerfil[54] == "1" //cálculo "por percentual"
		cSerTms	:= DTC->DTC_SERTMS
		cServic	:= DTC->DTC_SERVIC
		If nOpcB != 4 //Devolução
			cTipNFC := DTC->DTC_TIPNFC		
		Endif
	EndIf
	
	If lDTC
		lInvOri := DTC->(ColumnPos("DTP_INVORI")) > 0 .And. DTC->DTC_INVORI == '1'
	EndIf
	
	If l500Proc .And. Len(aPerfil) > 0 .AND. lExistPerf .AND. aPerfil[54] == "2" //cálculo "por trecho"
		cCdROri := M->DT6_CDRORI
	EndIf
	
	If l500Proc .And. !lRetVld .AND. nOpcB == 4 //Devolução
		cServic := M->DT6_SERVIC  //Utiliza O serviço do doc Original //desconsidera cálculo por trecho		
		cTipNFC := "1"
	ElseIf nOpcB == 4 //Devolução
		cTipNFC := "1"
	Endif	
	
	If l500Proc	
		If lRetVld
			aContrat := TMSContrat(cCliCal, cLojCal,,cServic,, cTipFre)
			If Len(aContrat) > 0 .And. !Empty(aContrat[1,1])
				cNContr := aContrat[1,1]
				cTabFre := aContrat[1,3]
				cTipTab := aContrat[1,4]
				cTabAlt := aContrat[1,15]
				cTipAlt := aContrat[1,16]
			Else
				lRetVld := .F.
			EndIf
		Else
			cNContr := M->DT6_NCONTR
			cTabFre := M->DT6_TABFRE
			cTipTab := M->DT6_TIPTAB		
		EndIf	
	EndIf
	
	If nOpcB == 4 .And. !lTM500ORI //devolução
		cCliRem	:= M->DT6_CLIREM
		cLojRem	:= M->DT6_LOJREM
		cCliDes	:= M->DT6_CLIDES
		cLojDes	:= M->DT6_LOJDES
		cCliCal	:= M->DT6_CLICAL
		cLojCal	:= M->DT6_LOJCAL
		cTipFre	:= M->DT6_TIPFRE				
		cCliDev	:= M->DT6_CLIDEV
		cLojDev	:= M->DT6_LOJDEV				
	EndIf
	
	If l500Proc .And. lRetVld .AND. Len(aPerfil) > 0 .AND. lExistPerf .AND. aPerfil[54] == "2" .AND. nOpcB != 4 //Cálculo "Por Trecho" .AND. Operação diferente de Devolução
		If cCdrOri != DT6->DT6_CDRORI  //regiao de origem da Reentrega diferente de região do documento original
			cServic := "" 	
			A500PsqSrv(	"DTC",  cCliCal, cLojCal,  cSerTMS, cTipTra,aItContrat,;
			lMostra, cTipFre, lRotAuto, /*cDocTms*/"", , cTabFre,;
			cTipTab,,,cCdrOri, cCdrDes,,;
			lRateio,,,,,,@cServic,@cDesSrv)
		Endif			
	Endif						

	If l500Proc .And. !lEnd .AND. lRetVld 
		If!Empty(cServic)
			aTipVei := TMSA500TPV() 
			If Len(aContrat) > 0 .AND. Len(aPerfil) > 0 .AND. lExistPerf .AND. aPerfil[54] != "2" //diferente de "por trecho "
				aRetFrt := {}
				nKm := TMSDistRot(,.F.,cCdROri,cCdRCal,cTipTra,cCliDev,cLojDev,DTC->DTC_DISTIV == '1')
				aRetFrt := TMSCalFret(cTabFre,cTipTab,@cSeqTab,cCdROri,cCdRCal,cCliCal,cLojCal,cCodPro,;
				cServic,cSerTms,cTipTra,cNContr,@aErrCal,,nValMer,nPeso,nPesoM3,,nQtdVol,,0,nMetro3,,,nKm,,,lCliGen,lAjuAut,,nQtdUni,,,,aValInf,aTipVei,cDocTms,,,,,,,,,,,,,,,,,,,,cCliDes,cLojDes,cSqeDes,;
				,,,,,,,,,lInvOri,,,,,,If(Len(aContrat[1])>=53,aContrat[ 1, 53 ],''))
			Else
				If	Len(aContrat) > 0 .AND. Len(aPerfil) > 0 .AND. lExistPerf .AND. aPerfil[54] == "2" //"Por Trecho"
					nKm := TMSDistRot(,.F.,cCdROri,cCdRCal,cTipTra,cCliDev,cLojDev,DTC->DTC_DISTIV == '1')
					aRetFrt := {}
					aRetFrt := TMSCalFret(cTabFre,cTipTab,@cSeqTab,cCdROri,cCdRCal,cCliCal,cLojCal,cCodPro,;
					cServic,cSerTms,cTipTra,cNContr,@aErrCal,,nValMer,nPeso,nPesoM3,,nQtdVol,,0,nMetro3,,,nKm,,,lCliGen,lAjuAut,,nQtdUni,,,,aValInf,aTipVei,cDocTms,,,,,,,,,,,,,,,,,,,,cCliDes,cLojDes,cSqeDes,;
					,,,,,,,,,lInvOri,,,,,,If(Len(aContrat[1])>=53,aContrat[ 1, 53 ],'') )
				Endif				
			EndIf	
			
			TmsA040Imp(aRetFrt,cCliDev,cLojDev,cDocTms,cTipFre,cCdrDes,.T.,,,Posicione("SA1",1,xFilial("SA1")+cCliDes+cLojDes,"A1_TIPO"),,cCdROri,,,cCliRem,cLojRem,cCliDes,cLojDes,,,If(Empty(cTipNFC),NIL,cTipNFC),cCodPro,cSeqIns)
		   	
			//-- Reentrega
			If	nOpcB == 5
				AAdd(aRetFrt,{Posicione('DT3',1,xFilial('DT3') + cCompEnt,'DT3_DESCRI'),; // [01]
								0,;                                                       // [02]
								cCompEnt,;                                                // [03]
								'',;                                                      // [04]
								0,;                                                       // [05]
								0,;                                                       // [06]
								'',;                                                      // [07]
								'',;                                                      // [08]
								'',;                                                      // [09]
								'',;                                                      // [10]
								'',;                                                      // [11]
								cOrdem,;                                                  // [12]
								0,;                                                       // [13]
								0,;                                                       // [14]
								StrZero(2,Len(DT8->DT8_CALMIN)),;                         // [15]
								'',;                                                      // [16]
								'',;                                                      // [17]
								'',;                                                      // [18]
								'',;                                                      // [19]
								'',;                                                      // [20]
								 0 })                                                     // [21]
			EndIf

			//-- Forca a linha totalizadora para a ultima posicao do vetor aRetFrt
			ASort(aRetFrt,,,{|x,y| x[12] + x[3] < y[12] + y[3] })		
		Else
			Help( " ", 1, "TMSA500B7")	// "O serviço não foi localizado no contrato do cliente"
			lRetVld := .F.
		EndIf	
	Endif
Endif
(cAliasQry2)->(DbCloseArea())		

RestArea(aArea)
Return aRetFrt

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A500CalDsc     ºAutor  ³ Ramon Prado   º Data ³  18/12/14	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.³Rotina que calcula o Desconto para casos em que a Reentrega ou   º±±
±±ºDesc.³Devolução é parcial - por geração de NF							   º±±	
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A500CalDsc(nOpcx,lPrimComp,lFretInf)
Local nCntFor := 1


//-- Formato do vetor aDesconto
//-- aDesconto[01] = Descricao do componente
//-- aDesconto[02] = Valor original do componente com imposto
//-- aDesconto[03] = Valor do complemento/reentrega
//-- aDesconto[04] = Valor do imposto
//-- aDesconto[05] = Valor + Imposto
//-- aDesconto[06] = Codigo do componente
aDesconto := {}
For nCntFor := 1 To Len(aFrete)
	If nOpcX == 5 .Or. nOpcX == 11 			//-- Reentrega ou Armazenagem
		AAdd(aDesconto,{aFrete[nCntFor,1],aFrete[nCntFor,2],0,0,0,aFrete[nCntFor,3] })
	ElseIf nOpcX == 6  .Or. nOpcX == 10	  //-- Complemento
		//-- O Vetor afrtori contem a composicao original do documento
		nSeek := AScan(aFrtOri,{|x|x[3]==aFrete[nCntFor,3]})
		If	lPrimComp
			AAdd(aDesconto,{aFrete[nCntFor,1],Iif(nSeek>0,aFrtOri[nSeek,6],0),0,0,0,aFrete[nCntFor,3]})
		Else
			AAdd(aDesconto,{aFrete[nCntFor,1],Iif(nSeek>0,aFrtOri[nSeek,6],0),aFrete[nCntFor,2],aFrete[nCntFor,5],aFrete[nCntFor,6],aFrete[nCntFor,3]})
		EndIf
	ElseIf lFretInf
		If lEdita
			AAdd(aDesconto,{aFrete[nCntFor,1],aFrete[nCntFor,2],0,0,0,aFrete[nCntFor,3]})
		Else
			AAdd(aDesconto,{aFrete[nCntFor,1],aFrete[nCntFor,2],0,aFrete[nCntFor,5],aFrete[nCntFor,6],aFrete[nCntFor,3]})
		EndIf
	Else
		AAdd(aDesconto, {aFrete[nCntFor, 1], aFrete[nCntFor, 6], 0, 0, 0,aFrete[nCntFor,3]})
	EndIf
Next

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A500PsqSrv³ Autor ³ Ramon Prado		       ³ Data ³17.01.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Tela contendo todos os Servicos contidos no Contrato  ³±±
±±³          ³do Cliente                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A500PsqSrv(ExpC1, ExpC2, ExpC3, ExpC4, ExpC5, ExpA1, ExpL1)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Alias                                               ³±±
±±³          ³ExpC2 - Codigo do Cliente                                   ³±±
±±³          ³ExpC3 - Loja do Cliente                                     ³±±
±±³          ³ExpC4 - Servico de Transporte                               ³±±
±±³          ³ExpC5 - Tipo de Transporte                                  ³±±
±±³          ³ExpA1 - Array que contera os Servicos                       ³±±
±±³          ³ExpL1 - Valida se Mostra ou Nao a GetDados                  ³±±
±±³          ³ExpC6 - Tipo do Frete                                       ³±±
±±³          ³ExpL2 - Verif. se esta sendo chamada por Rotina Automatica  ³±±
±±³          ³ExpC7 - Preenche o vetor aitcontrat com os servicos do      ³±±
±±³          ³        tipo de documento de transporte contidos em ExpC7   ³±±
±±³          ³ExpL3 - .T. = Verifica contrato do cliente generico         ³±±
±±³          ³ExpC8 - Tabela de frete                                     ³±±
±±³          ³ExpC9 - Tipo da tabela de frete                             ³±±
±±³          ³ExpCA - 1 = Considera a vigencia atual do contrato          ³±±
±±³          ³        2 = Considera a proxima vigencia do contrato        ³±±
±±³          ³ExpL4 - .T. = Apresenta help                                ³±±
±±³          ³ExpCA - Codigo da Regiao de Origem                          ³±±
±±³          ³ExpCB - Codigo da Regiao de Destino                         ³±±
±±³          ³ExpL5 - Verificar se a função é chamada pelo portal TMS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A500PsqSrv(	cAlias,  cCodCli, cLojCli,  cSerTMS, cTipTra,    aItContrat,;
						lMostra, cTipFre, lRotAuto, cDocTms, lChkCliGen, cTabFre,;
						cTipTab, cVigCon, lHelp,    cCdrOri, cCdrDes,    lPortalTMS,;
						lRateio, cBACRAT, cCRIRAT,  cPRORAT, cTABRAT,    cTIPRAT,cServic,cDesSrv)

Static oOk,oNo,oBr
Static lSelServ   := SuperGetMv("MV_SELSERV",.F.,.T.)

Local aArea       := GetArea()
Local cCadOld     := Iif(Type("cCadastro") <> "U",cCadastro,"")
Local nOpca       := 0
Local cQuery      := ""
Local cAliasQry   := ""
Local cItem       := ""		//-- Variavel utilizada para retorno da string
Local lAddItContr := .T.	//-- Controla se adiciona servicos no vetor aItContrat
Local aContrat    := {}
Local lRet        := .T.
Local oDlgEsp
Local oItem

Private cTDocTms    := ""

Default cAlias      := ""
Default cCodCli     := ""
Default cLojCli     := ""
Default cSerTMS     := ""
Default cTipTra     := ""
Default aItContrat  := {}
Default lMostra     := .T.
Default cTipFre     := '3'
Default lRotAuto    := .F.
Default cDocTms     := ''
Default lChkCliGen  := .T.
Default cTabFre     := ''
Default cTipTab     := ''
Default cVigCon     := '1'
Default lHelp       := .T.
Default cCdrOri     := ''
Default cCdrDes     := ''
Default lPortalTMS  := .F.
Default lRateio		:= .F.
Default cBACRAT		:= ""
Default cCRIRAT		:= ""
Default cPRORAT		:= ""
Default cTABRAT		:= ""
Default cTIPRAT		:= ""

If lRateio .And. ( (DUX->(FieldPos("DUX_BACRAT")) == 0) .Or. (DUX->(FieldPos("DUX_CRIRAT")) == 0) .Or. (DUX->(FieldPos("DUX_PRORAT")) == 0))
	lRateio := .F.
EndIf

aItContrat := {}
//-- A variavel private cTDocTms foi criada para uso da funcao TmsValField
cTDocTms   := cDocTms
cCadastro  := STR0033 + Iif(Empty(cDocTms),'',' p/ '+TmsValField('cTDocTms',.F.)) //"Escolha o Servico"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura do array que Contem os Servicos do Contrato       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 1 Marcado (.T. ou .F.)
// 2 Titulo("0") ou Item("1")
// 3 Codigo do Servico
// 4 Descricao do Servico

aContrat := TMSContrat(cCodCli,cLojCli,,,lHelp,cTipFre,lChkCliGen,cVigCon,,,,,cTipTra)

If Len(aContrat) > 0
	cAliasQry := GetNextAlias()
	cQuery := "   SELECT DUX_SERVIC, DUX_TABFRE, DUX_TIPTAB, DUX_TABALT, DUX_TIPALT, DUX.R_E_C_N_O_ RECDUX,"
	cQuery += "          DC5_SERTMS, DC5_TIPTRA, DC5_DOCTMS, MAX(DC5.R_E_C_N_O_) RECDC5"
	cQuery += "     FROM " + RetSqlName("DUX") + " DUX, " + RetSqlName("DC5") + " DC5 "
	cQuery += "    WHERE DUX_FILIAL = '" + xFilial("DUX") + "' "
	cQuery += "      AND DUX_NCONTR = '" + aContrat[1, 1] + "' "
	If lPortalTMS
		cQuery += "  AND DUX_PORTMS = '1'"
	EndIf
	
	cQuery += "      AND DUX.D_E_L_E_T_ = ' ' "	
	cQuery += "      AND DC5_FILIAL = '" + xFilial("DC5") + "' "
	cQuery += "      AND DC5_SERVIC = DUX_SERVIC"
	cQuery += "      AND DC5_DOCTMS <> '3'" // Tipo de documento diferente de AWB
	If !Empty(cSerTms)
		cQuery += "      AND DC5_SERTMS = '" + cSerTMS + "' "
	EndIf
	If !Empty(cTipTra)
		cQuery += "      AND DC5_TIPTRA = '" + cTipTra + "' "
	EndIf
	cQuery += "      AND DC5.D_E_L_E_T_ = ' ' "	
	cQuery += "   GROUP BY DUX_SERVIC, DUX_TABFRE, DUX_TIPTAB, DUX_TABALT, DUX_TIPALT, DUX.R_E_C_N_O_ ,"
	cQuery += "          DC5_SERTMS, DC5_TIPTRA, DC5_DOCTMS"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	While (cAliasQry)->(!Eof())
		If	Iif(Empty(cDocTms),.T.,(cAliasQry)->DC5_DOCTMS $ cDocTms)
			//-- Obtem o codigo do servico referente a tabela de frete ou tabela de frete alternativa
			If !Empty(cTabFre) .And. !Empty(cTipTab)
				lAddItContr := .F.
				//-- Obtem servicos referente a tabela de frete desejada
				If	(cAliasQry)->(DUX_TABFRE + DUX_TIPTAB) == cTabFre + cTipTab
					lAddItContr := .T.
				//-- Obtem servicos referente a tabela de frete alternativa desejada
				ElseIf (cAliasQry)->(DUX_TABALT + DUX_TIPALT) == cTabFre + cTipTab
					//-- Verifica se a tabela de frete alternativa esta ativa ou dentro da vigencia
					lAddItContr := TmsTbAtiva( cTabFre, cTipTab, .F. )
				EndIf
			EndIf      
			lRet := TmsTbAtiva( (cAliasQry)->DUX_TABFRE , (cAliasQry)->DUX_TIPTAB , .F. )
			DUX->( DbGoto((cAliasQry)->RECDUX) )
			DC5->( DbGoto((cAliasQry)->RECDC5) )
			
			If	lRet
				AAdd(aItContrat,{.F.,"1",(cAliasQry)->DUX_SERVIC, Tabela("L4",(cAliasQry)->DUX_SERVIC,.F.),(cAliasQry)->DC5_DOCTMS})
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso exista mais de um Servico                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aItContrat) > 0  .And. !lRotAuto
		//--Somente mostra a janela de selecao de servicos quando:
		//--1o) Houver mais de um servico para selecao e o contrato esteja configurado para selecao de servicos igual a "DIGITADO"
		//--2o) Houver mais de um servico para selecao e o contrato esteja configurado para selecao de servicos igual a "AUTOMATICA", porem com o parametro "MV_SELSERV" habilitado
		//--3o) Chamada da selecao de servicos esta sendo realizada atraves do <F3> no campo de servicos
		If	lMostra .And. Len(aItContrat) > 1 .And. ;
			(aContrat[1,21] == "1" .Or.;
			(aContrat[1,21] == "2" .And. lSelServ))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Le na resource os bitmaps utilizados no Listbox p/ sele‡ao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oOk := If(oOk==Nil,LoadBitmap( GetResources(), "LBOK"),oOk)
			oNo := If(oNo==Nil,LoadBitmap( GetResources(), "LBNO"),oNo)
			oBr := If(oBr==Nil,LoadBitmap( GetResources(), "NADA"),oBr)
				
			DEFINE MSDIALOG oDlgEsp TITLE cCadastro From 150,200 To 600,800 OF oMainWnd PIXEL

				@ 05,10 LISTBOX oItem VAR cOpc Fields HEADER "",STR0034,STR0035 SIZE 250,215 ON DBLCLICK (aItContrat:=TrocaItCF(oItem:nAt,aItContrat),oItem:Refresh(),(If(ItTudOk(aItContrat,@cItem),(nOpca:=1,oDlgEsp:End()),))) NOSCROLL OF oDlgEsp PIXEL //"Servico"###"Descricao"
				oItem:SetArray(aItContrat)
				oItem:bLine := { || {If(aItContrat[oItem:nAt,2]=="0",oBr,If(aItContrat[oItem:nAt,1],oOk,oNo)),aItContrat[oItem:nAt,3],aItContrat[oItem:nAt,4]}}
				oItem:bHeaderClick := {|oObj,nCol|	If(nCol==2,aSort(aItContrat,,, {|x,y| x[3] < y[3]}),;
													If(nCol==3,aSort(aItContrat,,, {|x,y| x[4] < y[4]}),)),;
													oItem:SetFocus(),oItem:Refresh()}
				DEFINE SBUTTON FROM 03,265 TYPE 1 ACTION (If(ItTudOk(aItContrat,@cItem),(nOpca:=1,oDlgEsp:End()),)) ENABLE OF oDlgEsp
				
				DEFINE SBUTTON FROM 18,265 TYPE 2 ACTION { || oDlgEsp:End() } ENABLE OF oDlgEsp
				
			
			ACTIVATE MSDIALOG oDlgEsp

			//Valida se Confirmou algum item ou se Item selecionado anteriormente participa da lista apresentada, quando altera DTC_SERTMS ou DTC_TIPTRA a lista eh modificada
			If nOpcA == 1 .OR. Ascan(aItContrat,{|x| AllTrim(x[3]) == cItem}) > 0
				cServic := cItem
				cDesSrv := Tabela("L4",cItem,.F.)
				VAR_IXB                 := cItem
				M->DT6_SERVIC := cItem
			Else
				VAR_IXB := "" //Limpa valor
			EndIf

		ElseIf Len(aItContrat) == 1  //Se o Contrato tiver apenas 1 servico informado, sugerir o mesmo automatic//e
			//--Consiste o servico em relacao a regiao de origem X destino.
			//--Caso as regioes sejam identicas (Mesmo municipio), nao gatilha
			//--um servico de transporte cujo docto.
			//--de transporte seja diferente de (5) - Nota Fiscal Serv. Transp.
			If	cCdrOri == cCdrDes .And. aItContrat[1][5] == StrZero(5,Len(DC5->DC5_DOCTMS)) .OR.;
				cCdrOri <> cCdrDes .And. aItContrat[1][5] <> StrZero(5,Len(DC5->DC5_DOCTMS))
				cServic := aItContrat[1][3]
				VAR_IXB := aItContrat[1][3]
				M->DT6_SERVIC := aItContrat[1][3]
			Else
				cServic := aItContrat[1][3]
				M->DT6_SERVIC := aItContrat[1][3]
				VAR_IXB := ""
			EndIf
		EndIf
	EndIf
EndIf
If (Type("cCadastro") <> "U")
	cCadastro := cCadOld
EndIf
RestArea(aArea)
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A500VldMrk     ºAutor  ³ Ramon Prado   º Data ³  10/08/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.³Funcao que valida a Marcacao do registro						    º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A500VldMrk(oMark)
Local lRet := .T.

If DTC->DTC_NFENTR == '3'
	Help( " ", 1, "TMSA500C0")	// "O Doc. do cliente selecionado esta bloqueado"
	If lTM500Auto
		AutoGrLog("["+DTC->(IndexKey())+"] => "+DTC->&(IndexKey()))
	EndIf
	lRet := .F.	
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CanAnulaºAutor  Fabio Marchiori Sampaioº Data ³  30/07/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cancela CTe de Anulção                                     º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Function CanAnula ()

Local cQuery		:= ""
Local cAliasSD1		:= ""
Local lContrib		:= .T.
Local cInscr		:= ""
Local cContrib		:= ""
Local aAreaDT6      := ""
Local cChave 		:= ""
Local lRet          := .T.
Local aAreaSF3      := SF3->(GetArea())
Local aAreaDJQ      := DJQ->(GetArea())
Local aAreaDJR      := DJR->(GetArea())
Local aAreaSD1      := SD1->(GetArea())
Local aArea         := GetArea()
Local cCliSF3       := ""
Local cLojSF3       := ""
Local cDocSF3       := ""
Local cSerSF3       := ""
Local cSeekDJR      := ""

	If Type("lTM500Auto") == "U"
		Private lTM500Auto := .F.
	EndIf
	//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
	If !TMSAVerAge("1",DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,,,,,,,,"2",.T.,.T.)
		Return .F.
	EndIf

	//+------------------------------------------------------------------------------
	//| Verifica se Documento de Anulação ainda esta transmitido ou aguardando retorno
	//| de Cancelamento.
	//+------------------------------------------------------------------------------
	dbSelectArea("SD1")
	SD1->(DbSetOrder(19)) //D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA                                                                                                                	
	If SD1->(MsSeek(xFilial("SD1")+DT6->DT6_DOC+DT6->DT6_SERIE+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV)) 
		dbSelectArea("SF3")
		SF3->(DbSetOrder(4)) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE                                                                                                                
		If SF3->(MsSeek(xFilial("SF3")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_DOC+SD1->D1_SERIE))
			While SF3->(!Eof()) .And. SF3->(F3_CLIEFOR + F3_LOJA + F3_NFISCAL + F3_SERIE) == SD1->(D1_FORNECE + D1_LOJA + D1_DOC + D1_SERIE)
				If SF3->F3_CODRSEF == '100' .And. AllTrim(SF3->F3_TIPO) = 'D'
					Help ( " ", 1, STR0285 )
					Return .F.
				EndIf
				If SF3->F3_CODRSEF == "103" .Or. AllTrim(SF3->F3_CODRET) == "T" .And. AllTrim(SF3->F3_TIPO) = 'D'
					//  ( [ uPar1 ] [ uPar2 ] [ cCampo ] [ cNome ] [ cMensagem ] [ nLinha1 ] [ nColuna ] [ lPop ] [ uPar9 ] [ uPar10 ] [ uPar11 ] [ lGravaLog ][aSoluc] )
					Help(" ",1,"TMSA500CAN-01",,STR0287,4,11;
							,; //lPop
							,; //uPar9
							,; //uPar10
							,; //uPar11
							,; //lGravaLog
							,;
							{{STR0288 + CHR(10) + CHR(13)},{STR0289}})  //aSoluc
					Return .F.
				EndIf
			SF3->(DbSkip())
			EndDo
		EndIf	
	EndIf
	
	aAreaDT6 := DT6->(GetArea())
	cChave   := xFilial('DT6')+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE
	DT6->(DbSetOrder(8)) //DT6_FILIAL+DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO
	If DT6->(MsSeek(cChave)) .And. !(DT6->DT6_DOCTMS == 'J' .And. DT6->DT6_TIPFRE == '3')
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help(' ', 1, 'TMSA500121',," " + DT6->DT6_FILDOC + "/" + DT6->DT6_DOC + "/" + DT6->DT6_SERIE + CRLF + STR0244,2,13) //"Ja existe um CT-e de substituição para este documento. : "###". A Exclusao nao sera efetuada .... "		
		RestArea(aAreaDT6)
		Return .F.
	EndIf
	RestArea(aAreaDT6)

	//Verifica se cliente e contribuinte do ICMS
	cInscr   := Posicione('SA1', 1, xFilial('SA1') + DT6->DT6_CLIDEV + DT6->DT6_LOJDEV,'A1_INSCR')
	cContrib := Posicione('SA1', 1, xFilial('SA1') + DT6->DT6_CLIDEV + DT6->DT6_LOJDEV,'A1_CONTRIB')
	If	Alltrim(cContrib) == "2" .Or. Empty(cInscr) .Or. Alltrim(Upper(cInscr)) $ "ISENT" .Or. ;
		Alltrim(Upper(cInscr)) $ "RG"
		lContrib := .F.
	Else
		lContrib := .T.
	EndIf

	//Caso seja cancelamento de um documento de anulacao
	//Exclui NF de Entrada.
	If DT6->DT6_STATUS == Replicate('9',Len(DT6->DT6_STATUS)) 

		If lTM500Auto .Or. MsgYesNo(STR0237)			
			
			cAliasSD1 := GetNextAlias()
	
			cQuery := "SELECT SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE"
			cQuery += " FROM " + RetSqlName("SD1") + " SD1"
			cQuery += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND"
			cQuery += " SD1.D1_FORNECE  = '" + DT6->DT6_CLIDEV + "' AND"
			cQuery += " SD1.D1_LOJA = '" + DT6->DT6_LOJDEV + "' AND"
			cQuery += " SD1.D1_TIPO = 'D' AND"
			cQuery += " SD1.D1_NFORI = '" + DT6_DOC + "' AND"
			cQuery += " SD1.D1_SERIORI = '" + DT6_SERIE + "' AND"
			cQuery += " SD1.D_E_L_E_T_ = ' ' "
	
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSD1, .F., .T.)
	
			lMsErroAuto := .F.
			
			aCab 	:= {}
			aItem	:= {}
			aItens	:= {}
			If (cAliasSD1)->(!Eof())
		
				AAdd( aCab, { "F1_DOC"    , (cAliasSD1)->D1_DOC	, Nil } )	// Numero da NF : Obrigatorio
				AAdd( aCab, { "F1_SERIE"  , (cAliasSD1)->D1_SERIE	, Nil } )	// Serie da NF  : Obrigatorio
				AAdd( aCab, { "F1_TIPO"   , "D"						, Nil } )	// Tipo da NF   : Obrigatorio
				AAdd( aCab, { "F1_FORNECE", DT6->DT6_CLIDEV			, Nil } )	// Codigo do Fornecedor : Obrigatorio
				AAdd( aCab, { "F1_LOJA"   , DT6->DT6_LOJDEV			, Nil } )	// Loja do Fornecedor   : Obrigatorio
		
				DbSelectArea("SD1")
				SD1->(DbSetOrder(1))
				SD1->(DbSeek( cSeek := (cAliasSD1)->D1_FILIAL+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV ))

				cCliSF3 := DT6->DT6_CLIDEV
				cLojSF3 := DT6->DT6_LOJDEV
				cDocSF3 := (cAliasSD1)->D1_DOC
				cSerSF3 := (cAliasSD1)->D1_SERIE

				//-- Exclui tabela de historico de integrações
				SF3->(DbSetOrder(4)) //-- F3_FILIAL+F3_CLIFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
				If SF3->(DbSeek(xFilial("SF3") + cCliSF3 + cLojSF3 + cDocSF3 + cSerSF3,.T.))
					DJQ->(DbSetOrder(1))
					If DJQ->(DbSeek(xFilial("DJQ") + "SF3" + "6" + xFilial("SF3") + cDocSF3 + cSerSF3))
						DJR->(DbSetOrder(1))
						If DJR->(DbSeek(cSeekDJR := xFilial("DJR") + "SF3" + "6" + PadR(xFilial("SF3") + cDocSF3 + cSerSF3,TamSX3("DJR_CONTEU")[1]) + ;
																				   PadR("Autenticacao",TamSX3("DJR_CODOPE")[1])))
							While DJR->(!Eof()) .And. DJR->(DJR_FILIAL + DJR_ALIAS + DJR_INDICE + DJR_CONTEU + DJR_CODOPE) == cSeekDJR
								RecLock("DJR",.F.)
								DJR->(DbDelete())
								DJR->(MsUnlock())
								DJR->(DbSkip())
							EndDo
							RecLock("DJQ",.F.)
							DJQ->(DbDelete())
							DJQ->(MsUnlock())
							DJQ->(DbSkip())
						EndIf
					EndIf
				EndIf
	
				While SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cSeek 
		
					AAdd( aItens, { "D1_COD"  , SD1->D1_COD			, Nil } )	// Codigo do Produto
					AAdd( aItens, { "D1_QUANT", SD1->D1_QUANT		, Nil } )	// Quantidade
					AAdd( aItens, { "D1_VUNIT", SD1->D1_VUNIT		, Nil } )	// Valor Unitario
					AAdd( aItens, { "D1_TOTAL", SD1->D1_TOTAL		, Nil } )	// Valor Total
		
					AAdd( aItem, aItens )
					aItens := {}
					SD1->(DbSkip())
				EndDo
				(cAliasSD1)->(dbCloseArea())
				DbSelectArea("DT6")
	
				If !lTM500Auto
					MsgRun( STR0164  , STR0162 , {|| MsExecAuto({|w,x,y,z|Mata103(w,x,y,z)},aCab,aItem,5,.F.) }) //"Excluindo NF de Anulação" ### "Aguarde..."
				Else
					MsExecAuto({|w,x,y,z|Mata103(w,x,y,z)},aCab,aItem,5,.F.)
				EndIf
			Else
				(cAliasSD1)->(dbCloseArea())
			EndIf
			If lMsErroAuto
				lRet := .F.
				If !lTM500Auto
					MostraErro()
				EndIf
			Else
				aAreaDT6 := DT6->(GetArea())
				DT6->(dbSetOrder(1))
				If DT6->(MsSeek(xFilial('DT6') + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE))
					RecLock("DT6",.F.)
					DT6->DT6_STATUS := "7"
					MsUnLock()
				EndIf
				RestArea(aAreaDT6)
				
				If !lTM500Auto
					If !Empty(aCab)
						MsgAlert(STR0238 + aCab[1][2] + STR0239)
					Else
						MsgAlert(STR0239)
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		Help( " ", 1, "TMSA500D1")	//-- "Cancelamento da Anulação não permitida. " ## "Documento não está com status Cancelado"
		lRet := .F.
	EndIf
	//-- Limpa marcas dos agendamentos
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf

	RestArea(aAreaDJR)
	RestArea(aAreaDJQ)
	RestArea(aAreaSF3)
	RestArea(aAreaSD1)
	RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA500Whe   ³ Autor ³Valdemar Roberto       ³ Data ³09.02.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Muda o When dos Campos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA500Whe()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±      
±±³Retorno   ³ Logico                                                        ³±±      
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±      
±±³ Uso      ³ TMSA500                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSA500Whe(cCampo)
Local lRet := .T.

DEFAULT cCampo := ReadVar()

If cCampo $ "M->DT6_SQEDES"
	If !(M->DT6_DESCAL $ "34")
		lRet := .F. 
	EndIf 
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A500ApgMrk	  ºAutor  ³ Ramon       º Data ³  20/08/15	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍFUÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Apaga marcas anteriores no DTC_OK				ÍÍÍÍÍÍÍÍÍÍº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function	A500ApgMrk(cFilDoc,cDoc,cSerie,cMarca)
Local cQuery	:= ""
Local cAliasQry	:= "" 
Local lDTCRee	:= DTC->(ColumnPos("DTC_DOCREE")) > 0
Local lDTCOK	:= DTC->(ColumnPos("DTC_OK")) > 0  
Local aArea		:= GetArea()
Local aAreaDTC	:= DTC->(GetArea())

cAliasQry := GetNextAlias()
cQuery := " SELECT DTC_NUMNFC,DTC_SERNFC,DTC_CLIREM,DTC_LOJREM,DTC_CODPRO,DTC_FILORI,DTC_LOTNFC "
cQuery += " FROM " + RetSqlTab("DTC")
cQuery += " WHERE DTC_FILIAL = '" + xFilial("DTC") + "'"
cQuery += "   AND DTC_FILDOC = '" + cFilDoc + "'"
cQuery += "   AND DTC_DOC    = '" + cDoc + "'"		
cQuery += "   AND DTC_SERIE    = '" + cSerie + "'"		
If !IsInCallStack("TMSA152")
	cQuery += "   AND DTC_NFENTR <> '1' "
	If lDTCRee
		cQuery += "   AND DTC_DOCREE = '2' "
	EndIf
EndIf
If lDTCOK
	cQuery += "   AND DTC_OK <> '" + cMarca + "' AND DTC_OK <> '' "		
Endif	
cQuery += "   AND DTC.D_E_L_E_T_ = '' "	

cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

While (cAliasQry)->(!EOF()) //não posicionou em nenhuma nota fiscal	
	
	DbSelectArea("DTC")
	DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto+Fil.Ori+Lote Nf				
	If DTC->(MsSeek(xFilial("DTC")+(cAliasQry)->(DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM+DTC_CODPRO+DTC_FILORI+DTC_LOTNFC)))		
		RecLock("DTC",.F.)
		DTC->DTC_OK := SPACE(Len(DTC->DTC_OK)) 
		DTC->(MsUnlock())
	Endif
	(cAliasQry)->(DbSkip())
	
EndDo

(cAliasQry)->(DbCloseArea())

RestArea(aAreaDTC)
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMS500Exp ºAutor Valdemar Roberto      º Data ³  08/03/16  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama funcao de exportacao de carta de correção            º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Function TMS500Exp(nAcao)

Default nAcao := 0

//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If !TMSAVerAge("1",DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,,,,,,,,"2",.T.,.T.)
	Return .F.
EndIf

If nAcao == 1 .Or. nAcao == 2
	SpedExport(nAcao)
EndIf

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Get500Aut	  ºAutor  ³ Daniel Leme º Data ³  28/05/16	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍFUÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Busca os dados enviados nos arrays da ExecAuto             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Get500Aut(cCpo,nItem,uDefault,aItSeek)
Local nPosAux := 0
Local uRet

Default nItem   := 1
Default aItSeek := aAutoItens

If (nPosAux := aScan(aItSeek[nItem],{|x| AllTrim(Upper(x[1])) == AllTrim(Upper(cCpo)) }) )  > 0
	uRet :=	aItSeek[nItem][nPosAux][2]
ElseIf uDefault != Nil
	uRet := uDefault
EndIf

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Get500NfAu     ºAutor  ³ Daniel Leme º Data ³  08/06/16	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍFUÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Busca nf enviada no array da ExecAuto                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Get500NfAu(cNumNFC,cSerNFC,cCliRem,cLojRem,cCodPro,cFilOri,cLotNfc)
Local nRet := 0 

aEval(aAutoNfs,{ |x,nCnt| Iif( Get500Aut("DTC_NUMNFC",nCnt,"",aAutoNfs) + ;
							   Get500Aut("DTC_SERNFC",nCnt,"",aAutoNfs) + ;
							   Get500Aut("DTC_CLIREM",nCnt,"",aAutoNfs) + ;
							   Get500Aut("DTC_LOJREM",nCnt,"",aAutoNfs) + ;
							   Get500Aut("DTC_CODPRO",nCnt,"",aAutoNfs) + ;
							   Get500Aut("DTC_FILORI",nCnt,"",aAutoNfs) + ;
							   Get500Aut("DTC_LOTNFC",nCnt,"",aAutoNfs) == cNumNFC+cSerNFC+cCliRem+cLojRem+cCodPro+cFilOri+cLotNfc ;
							  , nRet := nCnt;
							  , Nil )})
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMS500Perg
@descricao	: Carrega Perguntas Do TMSA500
@author Eduardo Alberti
@since  Mar/2017
@version 12
/*/
//-------------------------------------------------------------------
Function TMS500Perg(lMostra)

	Default lMostra := .f.

	Pergunte("TMA500",lMostra)

	//-- Tratamento rotina automática
	//-- Força a Geração Ser Sempre Por NF quando é passado array de NF's e, por Documento, quando não é passado o Array.
	If Type("lTM500Auto") != "U" .And. lTM500Auto 
		If Type("aAutoNfs") == "A" .And. !Empty(aAutoNfs)
			MV_PAR03 := 1 //-- Por Nf
		Else
			MV_PAR03 := 2 //-- Por Docto
		EndIf
	EndIf

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA500GAT
@descricao	: Gatilho de campos
@author Katia
@since  Mar/2017
@version 12
/*/
//-------------------------------------------------------------------	
Function TMSA500GAT(cCampo)
Local cRet		:= ""
Local aArea		:= GetArea()
Local cSqeOri	:= Space(TamSx3("DT5_SQEREM")[1])
Local cSqeDes	:= Space(TamSx3("DT5_SQEDES")[1])
Local cCliExp	:= Space(TamSx3("DT5_CLIREM")[1])
Local cLojExp	:= Space(TamSx3("DT5_LOJREM")[1])
Local cCliRec	:= Space(TamSx3("DT5_CLIDES")[1])
Local cLojRec	:= Space(TamSx3("DT5_LOJDES")[1])


Default cCampo:= ReadVar()

If cCampo $ "DT6_ORICAL"
	If M->DT6_ORICAL == '0'  //Outros
		cRet:= cCdrOriPE     //Conteudo do Ponto de Entrada TM500ORI
	ElseIf M->DT6_ORICAL == '2'  //Cliente
		cRet:= DT6->DT6_CDRCAL
	Else
		cRet:= PadR(GetMV('MV_CDRORI',,''),Len(DUY->DUY_GRPVEN))
	EndIf	
ElseIf cCampo $ "DT6_DESCAL"
	
	If M->DT6_DESCAL == '1'  //Filial
		cRet:= PadR(GetMV('MV_CDRORI',,''),Len(DUY->DUY_GRPVEN))
		If M->DT6_DOCTMS == '6' .And. DT6->(ColumnPos("DT6_CLIREC")) > 0
			M->DT6_CLIREC := CriaVar("DT5_CLIDES",.F.)
			M->DT6_LOJREC := CriaVar("DT5_LOJDES",.F.)
		EndIf

	ElseIf M->DT6_DESCAL == '2'  //Cliente
		cRet:= Posicione('SA1', 1, xFilial('SA1') + DT6->DT6_CLIREM + DT6->DT6_LOJREM,'A1_CDRDES')
		
		If M->DT6_DOCTMS == '6' //-- Devolucao
			cRet:= TMSA500SOL(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,@cSqeOri,@cSqeDes,@cCliExp,@cLojExp,@cCliRec,@cLojRec)
			If DT6->(ColumnPos("DT6_SQEDES")) > 0
				M->DT6_SQEDES := cSqeOri
			EndIf
			If DT6->(ColumnPos("DT6_CLIREC")) > 0
				M->DT6_CLIREC := Iif(!Empty(cCliExp),cCliExp,DT6->DT6_CLIREM)
				M->DT6_LOJREC := Iif(!Empty(cLojExp),cCliExp,DT6->DT6_LOJREM)
			EndIf
		EndIf

	ElseIf M->DT6_DESCAL == '3'  //Coleta
		cRet:= TMSA500SOL(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,@cSqeOri,@cSqeDes,@cCliExp,@cLojExp,@cCliRec,@cLojRec)
		//-- Se Documento for devolucao inverte Seq.End.Remetente e passa a ser o Recebedor(Seq.End.Destinatario)
		//-- totest-7-Reentrega...
		If M->DT6_DOCTMS == '6'
			If DT6->(ColumnPos("DT6_SQEDES")) > 0
				M->DT6_SQEDES := cSqeOri
			EndIf
			If DT6->(ColumnPos("DT6_CLIREC")) > 0
				M->DT6_CLIREC := Iif(!Empty(cCliExp),cCliExp,Iif(!Empty(DT6->DT6_CLIEXP),DT6->DT6_CLIEXP,DT6->DT6_CLIREM))
				M->DT6_LOJREC := Iif(!Empty(cLojExp),cLojExp,Iif(!Empty(DT6->DT6_LOJEXP),DT6->DT6_LOJEXP,DT6->DT6_LOJREM))
			EndIf
			//--Atualiza e Valida Seq.Endereco
			If DUL->(MsSeek(xFilial("DUL")+M->DT6_CLIDES+M->DT6_LOJDES+M->DT6_SQEDES))
				M->DT6_CDRCAL := DUL->DUL_CDRDES
			Else
				If DT6->(ColumnPos("DT6_SQEDES")) > 0
					M->DT6_SQEDES := CriaVar("DT6_SQEDES",.F.)
				EndIf
			EndIf

		Else
			If DT6->(ColumnPos("DT6_SQEDES")) > 0
				M->DT6_SQEDES := Iif(!Empty(cSqeDes),cSqeDes,DT6->DT6_SQEDES) //-- Obem sequencia Endereco da coleta, o contrario da informado no CTRC
			EndIf
			If DT6->(ColumnPos("DT6_CLIREC")) > 0
				M->DT6_CLIREC := Iif(!Empty(cCliRec),cCliRec,DT6->DT6_CLIREC)
				M->DT6_LOJREC := Iif(!Empty(cLojRec),cLojRec,DT6->DT6_LOJREC)
			EndIf
		EndIf

	Else //-- Outros
		If M->DT6_DOCTMS == "6"
			If DT6->(ColumnPos("DT6_SQEDES")) > 0
				M->DT6_SQEDES := CriaVar("DT6_SQEDES",.F.) //--Limpa Seq.End. para que o usuário informe
			EndIf
			If DT6->(ColumnPos("DT6_CLIREC")) > 0
				M->DT6_CLIREC := Iif(!Empty(DT6->DT6_CLIEXP),DT6->DT6_CLIEXP,DT6->DT6_CLIREM) //-- Se Expedidor foi digitado na NF Entrada(Sem Sol.Col. Informado) usa o Expedidor do DT6, do contrario usa o Remetente.
				M->DT6_LOJREC := Iif(!Empty(DT6->DT6_LOJEXP),DT6->DT6_LOJEXP,DT6->DT6_LOJREM)
			EndIf
		Else
			cRet:= Posicione('SA1', 1, xFilial('SA1') + DT6->DT6_CLIREM + DT6->DT6_LOJREM,'A1_CDRDES')
		EndIf

	EndIf 
EndIf

RestArea(aArea)
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA500SOL
@descricao	: Retorna a Regiao de Origem da Solicitacao de Coleta
@author Katia
@since  Mar/2017
@version 12
/*/
//-------------------------------------------------------------------
Function TMSA500SOL(cFilDoc,cDoc,cSerie,cSeqRem,cSeqDes,cCliExp,cLojExp,cCliRec,cLojRec)

Local cRet		:= ""
Local lAchouDTC	:= .F.
Local cFilDT5	:= xFilial("DT5")
Local cSeekDT5	:= ""
Local aAreas	:= { GetArea() , DUL->(GetArea()) }

Default cFilDoc	:= ""
Default cDoc	:= ""
Default cSerie	:= ""
Default cSeqRem := Space(Len(DT5->DT5_SQEREM))
Default cSeqDes := Space(Len(DT5->DT5_SQEREM))
Default cCliExp := "" 
Default cLojExp := "" 
Default cCliRec := "" 
Default cLojRec := "" 

If FindFunction("TmsPsqDY4") .And. TmsPsqDY4(cFilDoc,cDoc,cSerie)		
	DY4->(dbSetOrder(1))
	If DY4->(MsSeek(xFilial("DY4")+cFilDoc+cDoc+cSerie))
		DbSelectArea("DTC")
		DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto				
		If DTC->(MsSeek(xFilial("DTC")+DY4->DY4_NUMNFC+DY4->DY4_SERNFC+DY4->DY4_CLIREM+DY4->DY4_LOJREM+DY4->DY4_CODPRO)) .And. !Empty(DTC->DTC_NUMSOL)
			lAchouDTC := .T.		
		Endif
	EndIf	
Else
	DTC->(dbSetOrder(3))
	If DTC->(MsSeek(xFilial("DTC")+cFilDoc+cDoc+cSerie)) .And. !Empty(DTC->DTC_NUMSOL) 
		lAchouDTC := .T.	
	EndIf	
EndIf

If lAchouDTC
	DT5->(dbSetOrder(1))
	If !Empty(xFilial("DT5"))
		cFilDT5 := DTC->DTC_FILORI
	EndIf

	If !Empty(DTC->DTC_FILCFS)
		cFilDT5  := IIf(Empty(cFilDT5), cFilDT5, DTC->DTC_FILCFS)
		cSeekDT5 := cFilDT5+DTC->DTC_FILCFS+DTC->DTC_NUMSOL
	Else
		cSeekDT5 := cFilDT5+DTC->DTC_FILORI+DTC->DTC_NUMSOL
	EndIf

	If DT5->(MsSeek(cSeekDT5))
		cRet    := DT5->DT5_CDRORI
		//-- Busca Codigo do Expedidor e Seq.End.Remetente
		cSeqRem := DT5->DT5_SQEREM
		DUL->(DbSetOrder(2))
		If DUL->(MsSeek(xFilial("DUL") + DT5->(DT5_CLIREM + DT5_LOJREM) + cSeqRem))
			cCliExp := DUL->DUL_CODRED
			cLojExp := DUL->DUL_LOJRED
		EndIf
		
		//-- Busca Codigo do Recebedor e Seq.End.Destinatario.
		cSeqDes := IIf(!Empty(DTC->DTC_SQEDES),DTC->DTC_SQEDES,DT5->DT5_SQEDES)
		DUL->(DbSetOrder(2))
		If DUL->(MsSeek(xFilial("DUL") + DT5->(DT5_CLIDES + DT5_LOJDES) + cSeqDes))
			cCliRec := DUL->DUL_CODRED
			cLojRec := DUL->DUL_LOJRED
		EndIf

	EndIf
EndIf

AEval(aAreas,{|x| RestArea(x) })

Return cRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA500Cob
@descricao	: Chamada de menu à Cobranca de Tentativa de Entrega ou Cobrança de Retorno
@author Daniel Leme
@since  Jun/2017
@version 12
/*/
//-------------------------------------------------------------------
Function TMSA500Cob( cAlias, nReg, nOpcx )

Local nOpca			:= 0

//-- Reentrega ou Devolução
If	aRotina[ nOpcx, 4 ] == 5 .Or. aRotina[ nOpcx, 4 ] == 4  .Or. aRotina[ nOpcx, 4 ] == 6
	If "TMSA500" $ FunName() .And. !IsInCallStack("TMSA152")
		lCobDoc:= A500CobPrc(DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE,Iif(aRotina[ nOpcx, 4 ] ==5,'19',Iif(aRotina[ nOpcx, 4 ] ==6,'16','20')))
		If lCobDoc
			Return( nOpca)
		Else
			TMSA500Mnt(cAlias, nReg, nOpcx)
		EndIf
	Else
		TMSA500Mnt(cAlias, nReg, nOpcx)
	EndIf
EndIf

Return nOpca

//-------------------------------------------------------------------
/*/{Protheus.doc} A500CobPrc
@descricao	: Processo para Cobranca de Tentativa de Entrega e Cobrança de Retorno  
@author Katia
@since  Jun/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function A500CobPrc(cFilDoc,cDoc,cSerie,cCodOco)

Local lRet     := .T.
Local aParSX1  := {}
Local aArea    := GetArea()
Local aAreaDT6 := DT6->(GetArea())

Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""
Default cCodOco:= ""

//-- Verifica Se Existem Registros Disponíveis Para Processamento No TMSA152

aAdd( aParSX1 , Space(TamSx3("DTQ_VIAGEM")[1])   ) //-- 01 Viagem De
aAdd( aParSX1 , Repl('z',TamSx3("DTQ_VIAGEM")[1])) //-- 02 Viagem Até
aAdd( aParSX1 , dDataBase - 090                  ) //-- 03 Data De:
aAdd( aParSX1 , dDataBase                        ) //-- 04 Data Até
aAdd( aParSX1 , cFilDoc                          ) //-- 05 Filial De
aAdd( aParSX1 , cFilDoc                          ) //-- 06 Filial Até
aAdd( aParSX1 , cDoc                             ) //-- 07 Documento De:
aAdd( aParSX1 , cDoc                             ) //-- 08 Documento Até
aAdd( aParSX1 , cSerie                           ) //-- 09 Série De:
aAdd( aParSX1 , cSerie                           ) //-- 10 Série Até
aAdd( aParSX1 , 1                                ) //-- 11 Status Registro
aAdd( aParSX1 , cCodOco                          ) //-- 12 Tipo Ocorr. De
aAdd( aParSX1 , cCodOco                          ) //-- 13 Tipo Ocorr. Até

cFunOld := FunName()
SetFunName("TMSA152")
//-- Mostra Browse De Documentos Complementares
lRet := TMSA152(aParSX1,.F.)
SetFunName(cFunOld)

//-- Nao existindo documentos para geração, retorna para seguir com o processo normal do TMSA500
RestArea(aArea)
RestArea(aAreaDT6)

Return lRet

/*/{Protheus.doc} A500VldCli
//Valida Troca do devedor
@author caio.y
@since 16/11/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function A500VldCli()
Local aAreas     := {SA1->(GetArea()),GetArea()}
Local aCNPJs     := {}
Local lRet       := .T. 
Local nCntFor1   := 0
Local cCliDevAtu := M->DT6_CLIDEV
Local cLojDevAtu := M->DT6_LOJDEV
Local cCliDevOld := DT6->DT6_CLIDEV
Local cLojDevOld := DT6->DT6_LOJDEV
Local cUFDevAtu  := Posicione("SA1",1,xFilial("SA1") + cCliDevAtu + cLojDevAtu,"A1_EST")
Local cUFDevOld  := Posicione("SA1",1,xFilial("SA1") + cCliDevOld + cLojDevOld,"A1_EST")

BaseCNPJ({{DT6->DT6_CLIDEV,DT6->DT6_LOJDEV},;
		  {M->DT6_CLIDEV  ,M->DT6_LOJDEV},;
		  {DT6->DT6_CLIREM,DT6->DT6_LOJREM},;
		  {DT6->DT6_CLIDES,DT6->DT6_LOJDES},;
		  {DT6->DT6_CLICON,DT6->DT6_LOJCON},;
		  {DT6->DT6_CLIDPC,DT6->DT6_LOJDPC},;
		  {DT6->DT6_CLIEXP,DT6->DT6_LOJEXP},;
		  {DT6->DT6_CLIREC,DT6->DT6_LOJREC}},@aCNPJs)

If aCNPJs[1] != aCNPJs[2]	//-- Anterior diferente do atual
	For nCntFor1 := 3 To 8
		If aCNPJs[2] == aCNPJs[nCntFor1]	//-- Atual participou do CTe anterior
			lRet := .T.
			Exit
		EndIf
	Next nCntFor1
Else
	If cUFDevOld == cUFDevAtu
		lRet	:= .T. 
	Else
		lRet	:= .F. 
		Help( " ", 1, "TMSA500F2")	// Informe um tomador de serviço da mesma UF e que conste no documento principal 
	EndIF
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500CONFEC³ Autor ³Alex Amaral         ³ Data ³08.11.17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula o Decréscimo ou acrescimo do Frete Inf             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Total do frete original                            ³±±
±±³          ³ ExpN2 = Item do complemento                                ³±±
±±³          ³ ExpN3 = Opcao de manutencao                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500COTFEC(aFrete,nItem, nValor,aDesconto)

Local nCntFor	  := 0
Local nSeek	  := 0           
Local nDigitado := 0
                               
Default nValor	:= 0
Default nItem		:= 0
Default aFrete	:= {}
Default aDesconto	:= {}

Private aDescBkp	:= {}

	If IsInCallStack("TMSA500ShowGet")
		aDesconto[ nItem, 8] := nValor
		nDigitado := nValor
	ElseIf !IsInCallStack("TmsA040Dsc")
		aDesconto[ nItem, 8] := nValor
	EndIf
	
	//-- Se o Valor Informado for MAIOR que o Valor do Componente, calcula o % de Acrescimo do Item
	If	aDesconto[ nItem, 8] > aDesconto[ nItem, 2]
		aDesconto[ nItem, 10] := ( 100 * ( aDesconto[ nItem, 8] / aDesconto[ nItem, 2]) ) - 100
		aDesconto[ nItem, 9 ] := 0
		
	Else  //-- Calcula o % de Desconto do Item
		aDesconto[ nItem, 9 ] := (1 - ( aDesconto[ nItem, 8] / aDesconto[ nItem, 2] ) ) * 100
		aDesconto[ nItem, 10] := 0		
		
	EndIf
	  
	//-- Atualiza vetor aFrete
	For nCntFor := 1 To Len(aDesconto)
		nSeek := AScan(aFrete,{|x|x[3]==aDesconto[nCntFor,6]})
		If	nSeek > 0 
			aFrete[nSeek,13] := Iif( nCntFor == nItem, aDesconto[nCntFor, 09], 0)
			aFrete[nSeek,14] := Iif( nCntFor == nItem, aDesconto[nCntFor, 10], 0)			
		EndIf
	Next nCntFor	
	
Return(aFrete,aDesconto )
//----------------------------------------------------------------------------------------
Function TMSA500TPV 
Local aTipoVeic := {}
Local nPosTpVei := {}
Local nPosQtVei := {}
Local nCntFor := 0
Local nSeek := 0

	//-- Obtem o tipo de veiculo
	aTipoVeic := {}
	nPosTpVei := Ascan( aHeaderDWT, { |x| AllTrim(x[2]) == 'DWT_TIPVEI' } )
	nPosQtVei := Ascan( aHeaderDWT, { |x| AllTrim(x[2]) == 'DWT_QTDVEI' } )
	For nCntFor := 1 To Len(aColsDWT)
		If !aColsDWT[nCntFor][Len(aColsDWT[nCntFor])]
			nSeek := AScan(aTipoVeic,{ |x| x[1] == aColsDWT[nCntFor][nPosTpVei] })
			If	nSeek > 0
				aTipoVeic[nSeek,2] += aColsDWT[nCntFor][nPosQtVei] 
			Else
				AAdd(aTipoVeic,{ aColsDWT[nCntFor][nPosTpVei], aColsDWT[nCntFor][nPosQtVei] })
			EndIf
		EndIf
	Next
Return aTipoVeic

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA500DREE³ Autor ³Alex Amaral         ³ Data ³08/05/18    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Desmarca a Nota Fiscal para uso em uma próxima Reentrega   ³±±
±±³Descricao ³ Documetos do cliente nao entregue (DTC_NFENTR == '2')      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento.                               ³±±
±±³          ³ ExpC2 - Documento Original .                               ³±±
±±³          ³ ExpC3 - Serie do Documento Origiral.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA500DREE(cFilDco,cDocDco,cSerDco)

Local cQuery    := ""
Local cAliasDTC := ""
Local lDTCRee	  := DTC->(ColumnPos("DTC_DOCREE")) > 0
Local aArea     := GetArea()

Default cFilDco := ""
Default cDocDco := ""
Default cSerDco := ""

cAliasDTC := GetNextAlias()
cQuery := " SELECT DTC_FILORI, DTC_LOTNFC, DTC_NUMNFC, DTC_SERNFC, DTC_CODPRO, DTC_QTDVOL, DTC_CLIREM, DTC_LOJREM, DTC_PESO, DTC_VALOR, DTC_METRO3, DTC_PESOM3 "
cQuery += "		FROM " + RetSqlName("DTC")
cQuery += "		WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
cQuery += "		  AND DTC_DOC = '" + cDocDco + "' "
cQuery += "		  AND DTC_SERIE = '" + cSerDco + "' "
cQuery += "		  AND DTC_FILDOC = '" + cFilDco + "' "
If !IsInCallStack("TMSA152")
	cQuery += "		  AND DTC_NFENTR = '2' "
EndIf
cQuery += "		  AND D_E_L_E_T_ = '' "	

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC)

While (cAliasDTC)->(!Eof())
	//---Desmarca a Nota Fiscal para uso em uma próxima reentrega---//	
	dbSelectArea("DTC")
	dbSetOrder( 2 ) //Filial+NumNf+SerNfc+CliRem+LojRem+Produto+Fil.Ori.+LoteNfc
	If MsSeek(xFilial("DTC")+(cAliasDTC)->DTC_NUMNFC+(cAliasDTC)->DTC_SERNFC+(cAliasDTC)->DTC_CLIREM+;
	(cAliasDTC)->DTC_LOJREM+(cAliasDTC)->DTC_CODPRO+(cAliasDTC)->DTC_FILORI+(cAliasDTC)->DTC_LOTNFC)  
		RecLock("DTC", .F.)			
		If lDTCRee
			DTC->DTC_DOCREE := "2"	
		Endif 			
	EndIf				
	(cAliasDTC)->(DbSkip())
EndDo

RestArea(aArea)
Return

/*/{Protheus.doc} A500TESCmp()
	(long_description)
	@type  Static Function A500TESCmp()
	@author user
	@since 08/06/2018
	@version version 1.0
	@param vetor de aFrete, array, informe o array na mesma estrutura do adesconto/afrete retornado pelo TMSCALFRET()
	@return return, array, retorna array de 3 posições contendo o [1]-código da TES;[2]-A descrição da TES;[3]-CFOP
	@example
	(examples)
	@see (links_or_references)
	/*/
Function A500TESCmp(cDocTms,cTipFre,cCliDev,cLojDev,cCdrOri,cCdrDes,cProduto,lConsig,cTipNFC,aDesconto,cClides,clojDes)
Local aResult     := {}
Local nx          := 1
Local aRegra      := {}
Local cComponent  := ""

Default cProduto  := ""
Default lConsig   := .F.
Default cClides	  := ""
Default clojDes   := "" 

	For nx := 1 To Len(aDesconto)

					Aadd(aResult,{"","","","",""}) //-- [1]TES; [2]DESCR.TES; [3]CFOP;

					If IsInCallStack("TMSA500DSC")
						cComponent := aDesconto[nx,6]
					ElseIf IsIncallStack("TMSA040DSC")
						cComponent := aDesconto[nx,11]
					ElseIf IsInCallStack("TMSA040VFRT") .Or. IsInCallStack("TMS200BSCR") //--estrutura do vetor sao identicas na posição 3-cod.componente.
						cComponent := aDesconto[nx,03]
					EndIf
					//-- Obtem as inforamcoes da TES
					If cComponent <> "TF"
						aRegra := getTESCF(cDOCTMS,cTIPFRE,cComponent,cCliDev,cLojDev,cCDRORI,cCdrDes,cProduto,lConsig,cTipNFC,,cClides,clojDes)
						If Len(aRegra) > 0
							aResult[nx][1] := aRegra[1]
							aResult[nx][2] := aRegra[2]
							aResult[nx][3] := aRegra[3]
							aResult[nx][4] := aRegra[4]
							aResult[nx][5] := aRegra[5]
						EndIf
					EndIf
	Next nx

Return aResult

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³getTESCF   ³ Autor ³Tiago dos Santos    ³ Data ³08/05/18    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Encontra a TES correta                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function getTESCF(cDOCTMS,cTIPFRE,CodPas,cCliDev,cLojDev,cCDRORI,cCdrDes,cProduto,lConsig,cTipNFC,cSeqIns,cClides,cLojDes)
Local aResult     := {"","","","",""}
Local aRegra      := {}
Local aAreaSF4    := SF4->(GetArea())
Local cUfOri      := Posicione("DUY",1,xFilial("DUY")+cCdrOri,"DUY_EST")
Local cUfDes      := Posicione("DUY",1,xFilial("DUY")+cCdrDes,"DUY_EST")
Local lRegPorComp := .F.
Local aTSX5       := {}
Local cCfop		  := ""
Local aDadosCfo   := {}

Default cProduto  := ""
Default cSeqIns   := ""
Default cClides   := ""
Default cLojDes   := ""

	aRegra  := TmsRegTrib( cDocTms                    ,; // Doc.TMS
							cTipFre                   ,; // Tipo Frete
							CodPas                    ,; // CodPas
							cCliDev                   ,; // Cli. Dev.
							cLojDev                   ,; // Loja Dev.
							cUfDes					  ,; // Reg.Destino
												      ,; // lHelp
							cProduto                  ,; // PRoduto
							@lRegPorComp              ,; // Regiao por componente
							cUfOri                    ,; // UF Origem
							lConsig                   ,; // Consignatario ****
							cTipNFC                   ,; // Tipo NFC
							cSeqIns                   ,; // Seq.Ins ***
														) // UF Veiculo
	If Len(aRegra) > 0
		SF4->(DbSetorder(1))
		If SF4->(MsSeek(xFilial("SF4")+aRegra[1]))
			//-- Monta os dados do array para enviar a MaFisCfo()
			SA1->(dbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1")+cClides+cLojDes))
				Aadd(aDadosCfo,{"OPERNF"	,"S"})
				Aadd(aDadosCfo,{"TPCLIFOR"	,SA1->A1_TIPO})
				Aadd(aDadosCfo,{"UFDEST"	,SA1->A1_EST})
				Aadd(aDadosCfo,{"INSCR"		,SA1->A1_INSCR})
				Aadd(aDadosCfo,{"CONTR"		,SA1->A1_CONTRIB})
				Aadd(aDadosCfo,{"UFORIGEM"	,cUfOri})
				Aadd(aDadosCfo,{"UFDEST"	,cUfDes})
		
				cCfop := SF4->F4_CF
				//-- Inicializa a funcao fiscal
				MaFisEnd()
				MaFisIni(cCliDes,;						//-- Codigo Cliente/Fornecedor
						cLojDes,;						//-- Loja do Cliente/Fornecedor
						Iif(cDocTms=='3','F','C'),;	//-- C=Cliente/F=Fornecedor
						'N',;							//-- Tipo da NF
						'F'/*cTipoCli*/,;						//-- Tipo do Cliente/Fornecedor
						Nil,;
						Nil,;
						Nil,;
						Nil,;
						'TMSA040')
				cCfop := MaFisCfo(,cCfop,aDadosCfo)
				
			EndIf 

			aResult[1] := SF4->F4_CODIGO
			aResult[2] := SF4->F4_TEXTO
			aResult[3] := Iif(!Empty(cCfop),cCfop,SF4->F4_CF)
			aResult[4] := SF4->F4_SITTRIB
			aTSX5      := FWGetSX5("S2",PADR(SF4->F4_SITTRIB,TamSX3("X5_CHAVE")[1]))
			aResult[5] := Iif(Len(aTSX5) > 0,aTSX5[1][4],"")
		EndIf
	EndIf

	RestArea(aAreaSF4)

Return aResult

/*/{Protheus.doc} TMSA500NCC
//Valida geração de NCC na anulação - chamado pelo MATA103
@author Daniel Leme
@since 16/05/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function TMSA500NCC()
Local lRet := .T.

If IsInCallStack("TmsA500Anu")
	lRet := !Empty(DT6->DT6_NUM) //-- Na Anulação só gera NCC se o CT-e anulado possuir fatura.
EndIf

Return lRet

/*/{Protheus.doc} TMSRECDUD
//Retorna o ultimo Recno do documento na DUD
@author Katia
@since 03/09/2020
@version 12.1.27
@param cFilDoc, cDoc, cSerie
@return nRecno
@type function
/*/
Function TMSRECDUD(cFilDoc,cDoc,cSerie)
Local cAliasQry := GetNextAlias()
Local cQuery    := ''
Local aAreaDUD  := DUD->(GetArea())
Local nRecDUD   := 0

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""

cQuery := " SELECT MAX(R_E_C_N_O_) DUDRecNo"
cQuery += " FROM " + RetSqlTab("DUD")
cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD")  + "'"
cQuery += "   AND DUD.DUD_FILDOC = '" + cFilDoc + "'"
cQuery += "   AND DUD.DUD_DOC    = '" + cDoc    + "'"
cQuery += "   AND DUD.DUD_SERIE  = '" + cSerie  + "'"
cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )
If (cAliasQry)->(!Eof()) 
	nRecDUD:= (cAliasQry)->DUDRecNo 
EndIf
(cAliasQry)->(dbCloseArea())

RestArea(aAreaDUD)
Return nRecDUD

/*/{Protheus.doc} TMSDOCFIL
//Valida a Filial do Documento 
@author Katia
@since 03/09/2020
@version 12.1.27
@param nRecno (Recno DUD)
@return lRet
@type function
/*/
Function TMSDOCFIL(nRecDUD)
Local aAreaDUD  := DUD->(GetArea())
Local lRet      := .F.

Default nRecDUD := 0

DUD->( DbGoTo(nRecDUD))
If DUD->DUD_FILORI == cFilAnt .Or. DUD->DUD_FILATU == cFilAnt
	lRet:= .T.
EndIf

RestArea(aAreaDUD)
Return lRet


/*/{Protheus.doc} T500Filter
//Filtro para o Browse
@author Katia
@since 04/05/2021
@version 12.1.33
@type Static function
/*/
Static Function T500Filter(cFiltro)
	
oBrowseDT6:SetFilterDefault( "@" + 	T500MntSql(cFiltro, cFilFilOri, cFilFilDes, dFilDataDe, dFilDataAte, cFilCodCli, cFilLojCli, lFilCliRem,;
lFilCliDes, lFilCliCon, lFilCliDpc, cFilNumNFC, cFilSerNFC, cFilPfxFat, cFilNroFat, cFilTipFat, cFilNroVge, cFaturado ))

Return

/*/{Protheus.doc} T500Clear
//Limpa Tela e Filtro do Browse
@author Katia
@since 04/05/2021
@version 12.1.33
@type Static function
/*/
Static Function T500Clear(cFiltro)

cFilFilOri := Space(TamSX3("DT6_FILORI")[1])
cFilFilDes := Space(TamSX3("DT6_FILDES")[1])
dFilDataAte:= CtoD('')
dFilDataDe := CtoD('')
cFilCodCli := Space(TamSX3("DT6_CLIREM")[1])
cFilLojCli := Space(TamSX3("DT6_LOJREM")[1])
lFilCliRem := .F. 
lFilCliDes := .F.
lFilCliCon := .F.
lFilCliDpc := .F.
cFilNumNFC := Space(TamSX3("DTC_NUMNFC")[1])
cFilSerNFC := Space(TamSX3("DTC_SERNFC")[1])
cFilPfxFat := Space(TamSX3("DT6_PREFIX")[1])
cFilNroFat := Space(TamSX3("DT6_NUM")[1])
cFilTipFat := Space(TamSX3("DT6_TIPO")[1])
cFilNroVge := Space(TamSX3("DTQ_VIAGEM")[1])
cFaturado  := aIteFat[1]

T500Filter(cFiltro)  

Return

/*/{Protheus.doc} T500MntBrw
//Monta o Browse da Folder Inferior
@author Katia
@since 04/05/2021
@version 12.1.33
@type Static function
/*/
Static Function T500MntBrw(oBrowFld,oBrowAlias,cAlias,cRotina,cTitulo,aRelacto,aLegBrw,nDialog,cFilBrw)
Local nI        := 0

Default aLegBrw:= {}
Default cFilBrw  := ""
	
	oBrowFld:SetAlias(cAlias)   //Tabela
	oBrowFld:SetOwner(oFolders:aDialogs[nDialog])
	oBrowFld:SetMenuDef('')
	oBrowFld:SetProfileID(cAlias)
	oBrowFld:DisableDetails()
	oBrowFld:SetFixedBrowse(.F.)
	oBrowFld:SetMainProc(cRotina)
	oBrowFld:SetIgnoreARotina(.T.) // Ignora aRotina na construção das opções de menu

	//--- Monta as Legendas
	For nI:= 1 to Len(aLegBrw)
		oBrowFld:AddLegend(aLegBrw[nI][1], aLegBrw[nI][2], aLegBrw[nI][3])
	Next nI
	
	If !Empty(cFilBrw)
		oBrowFld:SetFilterDefault(cFilBrw)
	EndIf

	oBrowFld:Activate()

	oRelac:= FWBrwRelation():New()
	oRelac:AddRelation(oBrowAlias, oBrowFld, aRelacto)
	oRelac:Activate()
Return


/*/{Protheus.doc} T500AtuBrw
//Atualização do browser na troca de folder
@author Katia
@since 04/05/2021
@version 12.1.33
@type Static function
/*/
Function T500AtuBrw(nFolder)
	Do Case
		Case nFolder == 0
			oBrowseDT6:Refresh()
		Case nFolder == 1			
			oBrowseDUD:Refresh()			
		Case nFolder == 2			
			oBrowseDTW:Refresh()
		Case nFolder == 3			
			oBrowseDUA:Refresh()	
		Case nFolder == 4
			oBrowseDUU:Refresh()
		Case nFolder == 5
			oBrowseSE1:Refresh()
		Case nFolder == 6
			oBrowseDTC:Refresh()
	EndCase
Return .T.

/*/{Protheus.doc} UpdFolder
//Redimensiona o tamanho do Browse inferior
@author Katia
@since 20/05/2021
@version 12.1.33
@type Static function
/*/
Static Function UpdFolder( oFolders, oInferior )
	oFolders:Move(oFolders:nTop,oFolders:nLeft,oFolders:nWidth,oInferior:nClientHeight)
	If Valtype(oBrowseDT6) <> "U"
		oBrowseDT6:Refresh()
	EndIf
	If Valtype(oBrowseDUD) <> "U"
		oBrowseDUD:Refresh()
	EndIf			
	If Valtype(oBrowseDTW) <> "U"
		oBrowseDTW:Refresh()
	EndIf
	If Valtype(oBrowseDUA) <> "U"
		oBrowseDUA:Refresh()
	EndIf
	If Valtype(oBrowseDUU) <> "U"
		oBrowseDUU:Refresh()
	EndIf
	If Valtype(oBrowseSE1) <> "U"
		oBrowseSE1:Refresh()
	EndIf
	If Valtype(oBrowseDTC) <> "U"
		oBrowseDTC:Refresh()
	EndIf
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

Static Function CriaBrow( nFolder )

Local aLegBrw	:= {}

Default nFolder := 1

Do Case
	Case nFolder == 2 .AND. Valtype(oBrowseDTW) == "U"
		//---- Operações
		aRelacto:= {{"DTW_FILIAL","xFilial('DTW')" },{"DTW_FILORI","DUD_FILORI"},{"DTW_VIAGEM","DUD_VIAGEM"}} 
		aLegBrw:= TF68LegDTW()

		oBrowseDTW:= FWMBrowse():New()
		oBrowseDTW:AddButton(STR0003,{|| T500VisOpe() },,2,,.F.) //Visualizar 
		T500MntBrw(oBrowseDTW,oBrowseDUD,'DTW','TMSA350',STR0292, aRelacto, aLegBrw, 2)  //Operações
		
	Case nFolder == 3 .AND. Valtype(oBrowseDUA) == "U"
		//---- Ocorrencias
		aRelacto:= {{"DUA_FILIAL","xFilial('DUA')" },{"DUA_FILDOC","DT6_FILDOC"},{"DUA_DOC","DT6_DOC"},{"DUA_SERIE","DT6_SERIE"}}

		oBrowseDUA:= FWMBrowse():New()
		oBrowseDUA:AddButton( STR0003, { || SetFunName('TMSA360'),TMSA360Mnt('DUA', DUA->(Recno()), 2, DUA->DUA_FILORI, DUA->DUA_VIAGEM )  },,2,,.F.) 
		T500MntBrw(oBrowseDUA,oBrowseDT6,'DUA','TMSA360', STR0046 ,aRelacto,, 3)	//Ocorrências

	Case nFolder == 4 .AND. Valtype(oBrowseDUU) == "U"
		//--- Pendencias/Indenizações
		aRelacto:= {{"DUU_FILIAL","xFilial('DUU')" },{"DUU_FILDOC","DT6_FILDOC"},{"DUU_DOC","DT6_DOC"},{"DUU_SERIE","DT6_SERIE"}} 
		
		oBrowseDUU:= FWMBrowse():New()
		oBrowseDUU:AddButton(STR0150,{|| T500VisPnd("P") },,2,,.F.)   //Pendencia  
		oBrowseDUU:AddButton(STR0148,{|| T500VisPnd("I") },,2,,.F.)  //Indeniz.
		T500MntBrw(oBrowseDUU,oBrowseDT6,'DUU','TMSA540',AllTrim(STR0150)+ '/ ' + AllTrim(STR0149),aRelacto,, 4)  //Pendencias/Indenizações

	Case nFolder == 5 .AND. Valtype(oBrowseSE1) == "U"
		//---- Faturas
		If Empty(DT6->DT6_FILDEB)
			aRelacto:= {{"E1_FILIAL","xFilial('SE1')"},{"E1_CLIENTE","DT6_CLIDEV"},{"E1_LOJA","DT6_LOJDEV"},{"E1_PREFIXO","DT6_PREFIX"},{"E1_NUM","DT6_NUM"},{"E1_TIPO","DT6_TIPO"}}
		Else
			aRelacto:= {{"E1_FILIAL","DT6_FILDEB"},{"E1_CLIENTE","DT6_CLIDEV"},{"E1_LOJA","DT6_LOJDEV"},{"E1_PREFIXO","DT6_PREFIX"},{"E1_NUM","DT6_NUM"},{"E1_TIPO","DT6_TIPO"}}
		EndIf
		aLegBrw:= TF68LegSE1()

		oBrowseSE1:= FWMBrowse():New()
		oBrowseSE1:AddButton('Visualizar',{|| TmsA850Vis('SE1',SE1->(Recno()),2) },,2,,.F.) 
		T500MntBrw(oBrowseSE1,oBrowseDT6,'SE1','TMSA850',STR0293,aRelacto,aLegBrw, 5)  //Faturas

	Case nFolder == 6 .AND. Valtype(oBrowseDTC) == "U"
		//---- Notas Fiscais 
		aRelacto:= {{"DTC_FILIAL","xFilial('DTC')"},{"DTC_FILDOC","DT6_FILDOC"},{"DTC_DOC","DT6_DOC"},{"DTC_SERIE","DT6_SERIE"}}

		oBrowseDTC:= FWMBrowse():New()
		oBrowseDTC:AddButton(STR0003,{|| T500VisNF() },,2,,.F.)    //Visualizar
		T500MntBrw(oBrowseDTC,oBrowseDT6,'DTC','TMSA050',STR0294,aRelacto, ,6) //Notas Fiscais
EndCase

Return .T.

/*
{Protheus.doc} BaseCNPJ
Retorna a base do CNPJ dos clientes participantes do CTe
@author Valdemar Roberto Mognon
@since 22/10/2021
@version 12.1.33
@type Static function
*/
Static Function BaseCNPJ(aClientes,aCNPJs)
Local aAreas   := {SA1->(GetArea()),GetArea()}
Local nCntFor1 := 0

SA1->(DbSetOrder(1))
For nCntFor1 := 1 To Len(aClientes)
	If !Empty(aClientes[nCntFor1,1]) .And. !Empty(aClientes[nCntFor1,2])
		If SA1->(DbSeek(xFilial("SA1") + aClientes[nCntFor1,1] + aClientes[nCntFor1,2]))
			Aadd(aCNPJs,Iif(SA1->A1_PESSOA == "J",Left(SA1->A1_CGC,8),SA1->A1_CGC))
		Else
			Aadd(aCNPJs,Space(8))
		EndIf
	Else
		Aadd(aCNPJs,Space(8))
	EndIf
Next nCntFor1

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*/{Protheus.doc} TMA500AX1
//TODO Função que verifica se existe o pergunte TMA500A cadastrado. 
@author Rafael Souza
@since 30/11/2021
@type function
/*/
Function TMA500AX1()

    Local oObj := FWSX1Util():New()
    Local lRet := .F.

    oObj:AddGroup("TMA500A")
    oObj:SearchGroup()
    lRet := Len(oObj:GetGroup("TMA500A")[2]) > 0

    FreeObj(oObj)
    
Return lRet


/*/{Protheus.doc} TMATIPNFC
//TODO Função Para resolver os casos quando há mais de um anulação/substitução.
@author Fabio Marchiori Sampaio
@since 30/12/2021
@type function
/*/
Static Function TMATIPNFC()

Local cTipNFC     := Posicione("DTC",1,xFilial("DTC")+DT6->(DT6_FILORI+DT6_LOTNFC),"DTC_TIPNFC")
Local lAnuSubs    := .T.
Local cFilDco     := DT6->DT6_FILDCO
Local cDocDco     := DT6->DT6_DOCDCO
Local cSerDco     := DT6->DT6_SERDCO

If Empty(cTipNFC)
	If (DT6->DT6_DOCTMS = "P") .And. !Empty(cDocDco) .And. !Empty(cSerDco) //Para resolver os casos quando há mais de um anulação/substitução.
		aArea := GetArea()

		While lAnuSubs
			DbSelectArea("DT6")
			DbSetOrder(1)
			If Dbseek(xFilial("DT6")+cFilDco+cDocDco+cSerDco)
				If !Empty(DT6->DT6_DOCDCO) .And. !Empty(DT6->DT6_SERDCO) 
					cFilDco := DT6->DT6_FILDCO
					cDocDco := DT6->DT6_DOCDCO
					cSerDco := DT6->DT6_SERDCO	
					lAnuSubs := .T.
				Else
					lAnuSubs := .F.
					cTipNFC  := Posicione("DTC",1,xFilial("DTC")+DT6->(DT6_FILORI+DT6_LOTNFC),"DTC_TIPNFC")	
				EndIf
			Else
				lAnuSubs := .F.
				cTipNFC  := Posicione("DTC",1,xFilial("DTC")+DT6->(DT6_FILORI+DT6_LOTNFC),"DTC_TIPNFC")
			EndIf
		EndDo
		RestArea(aArea)
	EndIf
EndIf 

Return cTipNFC
