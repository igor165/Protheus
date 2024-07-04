#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "OFIC060.CH"

/*/{Protheus.doc} OFIC060()
Consulta de Interesses Pecas/Servicos Oficina

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
@return NIL
/*/
Function OFIC060(cPAREmp,aPAREmp,aPARFil)
Local aObjects    := {} , aInfo := {}, aPos := {}
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local oFont1      := TFont():New(,10,20,,.F.,,,,,,,,,,,)
Local nCont       := 0
Local nLinha      := 0
Local lDClik      := .f.
Local aTpGraf     := {"1="+STR0009,"2="+"%"} // Qtde. / %
Local lCEVOUT     := ( VAI->(FieldPos("VAI_CEVOUT")) <> 0 )
Local aNewBot     := {}
Local aBotAux     := {}
Local aFilAtu     := FWArrFilAtu()
Private aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Private aTpTotal  := {"1="+STR0002,"2="+STR0003,"3="+STR0004,"4="+STR0005,"5="+STR0006,"6="+STR0007,"7="+STR0008} // Fase Oportunidade / Cliente / Nivel Importância / Tipo de Midia / Vendedor / Motivo Cancelamento / Etapas do Funil de Venda
Private lMarcar   := .f.
Private lMarMot   := .f.
Private aVetEmp   := {}
Private aEmpr     := {} // Empresas Consolidadas
Private cEmpr     := "" // Nome da Empresa
//
Private cCodCli       := space(TamSX3("VDL_CODCLI")[1])
Private cLojCli       := space(TamSX3("VDL_LOJCLI")[1])
Private cCdPros       := space(TamSX3("VDL_CDPROS")[1])
Private cLjPros       := space(TamSX3("VDL_LJPROS")[1])
Private cNomCli       := ""
Private dDtIIni       := (dDataBase-day(dDataBase))+1
Private dDtIFin       := dDataBase+30
Private dDtLIni       := dDtIIni
Private dDtLFin       := dDtIFin
Private cNivImp       := space(TamSX3("VDL_NIVIMP")[1])
Private M->VDL_PERFIL := space(TamSX3("VDL_PERFIL")[1]) // VX5
Private M->VDI_CAMPOP := space(TamSX3("VDI_CAMPOP")[1]) // VX5
Private cCodFas       := space(TamSX3("VDI_CODFAS")[1])
Private cCodVen       := space(TamSX3("VDI_CODVEN")[1])
Private cTipCon       := " "
Private aTipCon       := X3CBOXAVET("VDI_TIPCON","1")
Private M->VDI_TIPMID := space(TamSX3("VDI_TIPMID")[1]) // VX5

Private cIBGE         := space(TamSX3("A1_IBGE")[1])
Private cMunCli       := space(TamSX3("A1_MUN")[1])
Private cUFCli        := space(TamSX3("A1_EST")[1])
Private cTpPcSr       := ""

Private cCodEta       := space(TamSX3("VDK_CODETA")[1])
Private aCliPros      := {"","1="+STR0003,"2="+STR0010} // Cliente / Prospect
Private cCliPros      := "1"
Private cMotivo       := "000022" // Tipo de motivo - utilizado na consulta de Motivos de Cancelamentos
Private cMotCan       := space(TamSX3("VDI_MOTCAN")[1])
Private cTpTotal      := "1"
Private cTpGraf       := "1"
Private nMaxGraf      := 99
Private aDadosGraf    := {}
Private cTitGraf      := ""
Private dDatRef       := dDataBase
//
Private aFiltros := {cCodCli,cLojCli,cNomCli,dDtIIni,dDtIFin,dDtLIni,dDtLFin,cNivImp,M->VDL_PERFIL,M->VDI_CAMPOP,cCodFas,cCodVen,cTipCon,M->VDI_TIPMID,cMotCan,cTpTotal,cTpGraf,nMaxGraf,cCdPros,cLjPros,cCliPros,dDatRef,cCodEta,cIBGE,cMunCli,cUFCli,cTpPcSr}
//
Private aInteres := {}
Private aTotais  := {}
Private aAnalit  := {}
Private oGrafPeq
Private oGrafAna
//
Private cOrdVet  := "0C"
//
Default cPAREmp  := ""
Default aPAREmp  := aEmpr
Default aPARFil  := aFiltros
//
aFiltros := aPARFil
OC0600021_SalvarVoltarFiltro(2)
//
DbSelectArea("VAI")
DbSetOrder(4)
DbSeek(xFilial("VAI")+__cUserID)
If lCEVOUT .and. VAI->VAI_CEVOUT<>"1"
	cCodVen := VAI->VAI_CODVEN
EndIf
aEmpr := aPAREmp
If !Empty(cPAREmp)
	cEmpr := " - "+STR0013+": " // Consolidado
	aEmpr := OC0600081_FILIAIS() // Levantamento das Filiais
	If len(aEmpr) == 0
		MsgAlert(STR0012,STR0011) // Nao existem dados para esta Consulta! / Atencao
		Return
	EndIf
Else
	aAdd(aEmpr,{ cFilAnt , aFilAtu[SM0_FILIAL] })
EndIf
If len(aEmpr) == 1 .and. (aEmpr[1,2]==aFilAtu[SM0_FILIAL])
	cEmpr := " - "+Alltrim(FWFilialName())+" ( "+aFilAtu[SM0_FILIAL]+" )"
EndIf
aInfo := { aSizeHalf[ 1 ] , aSizeHalf[ 2 ] , aSizeHalf[ 3 ] , aSizeHalf[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 100 , .T. , .T. } ) // TELA
aAdd( aObjects, { 0 , 150 , .T. , .F. } ) // Totalizadores / Grafico
aPos := MsObjSize( aInfo, aObjects )
//
If ( ExistBlock("OC060BOT") )
	aBotAux := ExecBlock("OC060BOT",.F.,.F.)
	If ( ValType(aBotAux) == "A" )
		aNewBot := aClone(aBotAux)
	EndIf
EndIf
AADD(aNewBot,{"IMPRESSAO",{|| OC0600031_Imprimir(1) } , STR0014 } ) // Impressao Interesses
AADD(aNewBot,{"IMPRESSAO",{|| OC0600031_Imprimir(2) } , STR0015 } ) // Impressao Resumo
//
OC0600051_FILTRAR(0)
//
OC0600191_F7(.t.)
//
DEFINE MSDIALOG oIntOFC060 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Interesses Peças/Serviços Oficina
oIntOFC060:lEscClose := .F.
//
oTPanelFiltr := TPanel():New(aPos[1,1],aPos[1,2],"",oIntOFC060,NIL,.T.,.F.,NIL,NIL,180,aPos[1,3]-aPos[1,1],.T.,.F.)
oScrollFiltr := TScrollBox():New( oTPanelFiltr , 01 , 01 , 01 ,01 , .t. , , .t. )
oScrollFiltr:Align := CONTROL_ALIGN_ALLCLIENT

oTPanelInter := TPanel():New(aPos[1,1],aPos[1,2]+182,"",oIntOFC060,NIL,.T.,.F.,NIL,NIL,aPos[1,4]-aPos[1,2]-182,aPos[1,3]-aPos[1,1],.T.,.F.)

//
If !Empty(cCodCli+cLojCli)
	cCliPros := "1" // Cliente
	OC0600101_PosicionaClienteProspect("CL",.f.)
ElseIf !Empty(cCdPros+cLjPros)
	cCliPros := "2" // Prospect
	OC0600101_PosicionaClienteProspect("PR",.f.)
EndIf
nLinha  := 07
@ nLinha,065 SAY STR0016 SIZE 40,10 FONT oFont1 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Filtros
nLinha  += 20
@ nLinha,005 MSCOMBOBOX oCliPros VAR cCliPros ITEMS aCliPros ON CHANGE OC0600111_SelecionaClienteProspect() SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,060 MSGET oCodCli VAR cCodCli SIZE 035,08 OF oScrollFiltr VALID ( OC0600101_PosicionaClienteProspect("CL",.t.) .and. OC0600021_SalvarVoltarFiltro(1) ) F3 "SA1" PIXEL COLOR CLR_BLUE
@ nLinha,095 MSGET oLojCli VAR cLojCli SIZE 015,08 OF oScrollFiltr VALID ( OC0600101_PosicionaClienteProspect("CL",.t.) .and. OC0600021_SalvarVoltarFiltro(1) ) PIXEL COLOR CLR_BLUE
@ nLinha,060 MSGET oCdPros VAR cCdPros SIZE 035,08 OF oScrollFiltr VALID ( OC0600101_PosicionaClienteProspect("PR",.t.) .and. OC0600021_SalvarVoltarFiltro(1) ) F3 "SUS" PIXEL COLOR CLR_BLUE
@ nLinha,095 MSGET oLjPros VAR cLjPros SIZE 015,08 OF oScrollFiltr VALID ( OC0600101_PosicionaClienteProspect("PR",.t.) .and. OC0600021_SalvarVoltarFiltro(1) ) PIXEL COLOR CLR_BLUE
@ nLinha,060 MSGET oTodCli VAR STR0017 PICTURE "@!" SIZE 100,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE WHEN .f. // TODOS OS CLIENTES E PROSPECTS
nLinha += 12
@ nLinha,060 MSGET oNomCli VAR cNomCli SIZE 100,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE WHEN .f.
oCodCli:lVisible := .f.
oLojCli:lVisible := .f.
oTodCli:lVisible := .f.
oCdPros:lVisible := .f.
oLjPros:lVisible := .f.
If cCliPros == "1" // Cliente
	oCodCli:lVisible := .t.
	oLojCli:lVisible := .t.
ElseIf cCliPros == "2" // Prospect
	oCdPros:lVisible := .t.
	oLjPros:lVisible := .t.
Else
	oTodCli:lVisible := .t.
	oNomCli:lVisible := .f.
EndIf
nLinha += 12
@ nLinha,005 SAY STR0018 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Dt.Interesse
@ nLinha,060 MSGET oDtIIni VAR dDtIIni VALID ( OC0600021_SalvarVoltarFiltro(1) ) SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,108 SAY STR0020 SIZE 10,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // a
@ nLinha,114 MSGET oDtIFin VAR dDtIFin VALID ( ( dDtIIni <= dDtIFin ) .and. OC0600021_SalvarVoltarFiltro(1) ) SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0019 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Dt.Limite
@ nLinha,060 MSGET oDtLIni VAR dDtLIni VALID ( OC0600021_SalvarVoltarFiltro(1) ) SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,108 SAY STR0020 SIZE 10,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // a
@ nLinha,114 MSGET oDtLFin VAR dDtLFin VALID ( ( dDtLIni <= dDtLFin ) .and. OC0600021_SalvarVoltarFiltro(1) ) SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0021 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Nivel Importancia
@ nLinha,060 MSGET oNivImp VAR cNivImp VALID ( OC0600021_SalvarVoltarFiltro(1) ) SIZE 15,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,095 SAY STR0022 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Perfil
@ nLinha,114 MSGET oPerfil VAR M->VDL_PERFIL VALID ( ( vazio() .or. ExistCpo("VX5","025"+M->VDL_PERFIL) ) .and. OC0600021_SalvarVoltarFiltro(1) ) F3 "VX5" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0023 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Campanha
@ nLinha,060 MSGET oCampOp VAR M->VDI_CAMPOP VALID ( ( vazio() .or. ExistCpo("VX5","026"+M->VDI_CAMPOP) ) .and. OC0600021_SalvarVoltarFiltro(1) ) F3 "VX5" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0024 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Etapa Funil
@ nLinha,060 MSGET oCodEta VAR cCodEta VALID ( OC0600021_SalvarVoltarFiltro(1) ) F3 "VQTB" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0002 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Fase Oportunidade
@ nLinha,060 MSGET oCodFas VAR cCodFas VALID ( ( vazio() .or. ExistCpo("VDK",cCodFas) ) .and. OC0600021_SalvarVoltarFiltro(1) ) F3 "VDKFAS" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0006 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Vendedor
@ nLinha,060 MSGET oCodVen VAR cCodVen VALID ( ( vazio() .or. ExistCpo("SA3",cCodVen) ) .and. OC0600021_SalvarVoltarFiltro(1) ) F3 "SA3" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0025 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Tipo de Contato
@ nLinha,060 MSCOMBOBOX oTipCon VAR cTipCon ITEMS aTipCon VALID ( OC0600021_SalvarVoltarFiltro(1) ) SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0005 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Tipo de Midia
@ nLinha,060 MSGET oTipMid VAR M->VDI_TIPMID VALID ( ( vazio() .or. ExistCpo("VX5","027"+M->VDI_TIPMID) ) .and. OC0600021_SalvarVoltarFiltro(1) ) F3 "VX5" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0007 SIZE 100,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Motivo Cancelamento
@ nLinha,060 MSGET oMotCan VAR cMotCan VALID ( ( vazio() .or. FG_SEEK("VS0","'000022'+cMotCan",1,.f.) ) .and. OC0600021_SalvarVoltarFiltro(1) .and. OC0600131_MotivoCancelamento(1)) F3 "VS0" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,110 CHECKBOX oMarMot VAR lMarMot PROMPT STR0026 OF oScrollFiltr ON CLICK OC0600131_MotivoCancelamento(0) SIZE 50,08 PIXEL // Todos Motivos
nLinha += 12
@ nLinha,005 SAY STR0027 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Municipio
@ nLinha,060 MSGET oIBGE VAR cIBGE VALID ( OC0600011_ValidIBGEUF(1) .and. OC0600021_SalvarVoltarFiltro(1) ) F3 "AM1" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,120 SAY STR0028 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // UF
@ nLinha,135 MSGET oUFCli VAR cUFCli VALID ( OC0600011_ValidIBGEUF(2) .and. OC0600021_SalvarVoltarFiltro(1) ) F3 "12" SIZE 25,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE WHEN Empty(cIBGE)
nLinha += 12
@ nLinha,060 MSGET oMunCli VAR cMunCli SIZE 100,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE WHEN .f.
nLinha += 12
@ nLinha,005 SAY STR0029 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Data Referencia
@ nLinha,060 MSGET oDatRef VAR dDatRef VALID ( naovazio() .and. OC0600021_SalvarVoltarFiltro(1) ) SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0030 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Tipo
@ nLinha,060 MSCOMBOBOX oTpPcSr VAR cTpPcSr ITEMS {"","1="+STR0031,"2="+STR0032} VALID ( OC0600021_SalvarVoltarFiltro(1) ) SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
nLinha += 12
@ nLinha,40 BUTTON oFiltrar PROMPT UPPER(STR0033) OF oScrollFiltr SIZE 30,10 PIXEL ACTION Processa( {|| OC0600051_FILTRAR(1) } ) // Filtrar
@ nLinha,90 BUTTON oEmpr    PROMPT UPPER(STR0034) OF oScrollFiltr SIZE 30,10 PIXEL ACTION (lDClik:=.t.,oIntOFC060:End()) // Filiais
nLinha += 12
@ nLinha,001 SAY "." SIZE 00,00 OF oScrollFiltr PIXEL COLOR CLR_WHITE // somente para deixar espaço embaixo dos botoes: [FILTRAR] [FILIAIS]

@ 001,001 LISTBOX oLbInteres FIELDS HEADER 	STR0003 ,; // Cliente
											STR0035 ,; // Nome
											STR0036 ,; // Telefone
											STR0019 ,; // Dt.Limite
											STR0002 ,; // Fase Oportunidade
											STR0037 ; // Descrição do Interesse
											COLSIZES 35,100,55,40,120,120 SIZE 001,001 OF oTPanelInter ON DBLCLICK OC0600121_VisualizaDetalheInteresse(aInteres[oLbInteres:nAt,07],aInteres[oLbInteres:nAt,08],aInteres[oLbInteres:nAt,11]) PIXEL
oLbInteres:SetArray(aInteres)
oLbInteres:bLine := { || { aInteres[oLbInteres:nAt,01] ,;
aInteres[oLbInteres:nAt,02] ,;
aInteres[oLbInteres:nAt,03] ,;
Transform(aInteres[oLbInteres:nAt,04],"@D") ,;
aInteres[oLbInteres:nAt,05] ,;
aInteres[oLbInteres:nAt,06] }}
oLbInteres:Align := CONTROL_ALIGN_ALLCLIENT
oLbInteres:bHeaderClick := {|oObj,nCol| OC0600041_OrdenaVetorInteresses(nCol) , }
//
@ aPos[2,1]+00,aPos[2,2] MSCOMBOBOX oTpTotal VAR cTpTotal ITEMS aTpTotal VALID ( OC0600021_SalvarVoltarFiltro(1) .and. OC0600061_TOTAIS(0) ) SIZE 181,08 OF oIntOFC060 PIXEL COLOR CLR_BLUE
@ aPos[2,1]+12,aPos[2,2] LISTBOX oLbTotais FIELDS HEADER "",STR0009,"%" COLSIZES 117,27,25 SIZE 180,126 OF oIntOFC060 ON DBLCLICK OC0600071_TotalStatus(oLbTotais:nAt) PIXEL // Qtde / %
oLbTotais:SetArray(aTotais)
oLbTotais:bLine := { || { aTotais[oLbTotais:nAt,01] , FG_AlinVlrs(Transform(aTotais[oLbTotais:nAt,2],"@E 999,999")) , FG_AlinVlrs(Transform((aTotais[oLbTotais:nAt,2]/aTotais[1,2])*100,"@E 999.9"))+" %" }}
oLbTotais:bHeaderClick := {|oObj,nCol| OC0600061_TOTAIS(nCol) , }
//
@ aPos[2,1]+141,aPos[2,2]+003 SAY STR0038 SIZE 50,08 OF oIntOFC060 PIXEL COLOR CLR_BLUE // Tipo de Grafico:
@ aPos[2,1]+140,aPos[2,2]+045 MSCOMBOBOX oTpGraf VAR cTpGraf ITEMS aTpGraf VALID ( OC0600021_SalvarVoltarFiltro(1) .and. OC0600061_TOTAIS(0) ) SIZE 40,08 OF oIntOFC060 PIXEL COLOR CLR_BLUE
@ aPos[2,1]+141,aPos[2,2]+097 SAY STR0039 SIZE 70,08 OF oIntOFC060 PIXEL COLOR CLR_BLUE //Qtde maxima de colunas:
@ aPos[2,1]+140,aPos[2,2]+161 MSGET oMaxGraf VAR nMaxGraf VALID ( nMaxGraf >= 1 .and. OC0600021_SalvarVoltarFiltro(1) .and. OC0600061_TOTAIS(0) ) PICTURE "@E 99" SIZE 20,08 OF oIntOFC060 PIXEL COLOR CLR_BLUE
//
@ aPos[2,1],aPos[2,2]+182 SCROLLBOX oGrafPeq SIZE 150,(aPos[2,4]-185) OF oIntOFC060 BORDER PIXEL
//
OC0600061_TOTAIS(0)
//
// BOTAO: VISUALIZA GRAFICO EM TELA CHEIA
@ aPos[2,1]+05,aPos[2,4]-55 BUTTON oGrafTela PROMPT UPPER(STR0040) OF oIntOFC060 SIZE 50,15 PIXEL ACTION FG_NEWGRAF(,cTitGraf+" ( "+IIf(cTpGraf=="1",STR0009,"%")+" )",aDadosGraf,.t.,IIf(cTpGraf=="1","@E 999,999,999","@E 999.9 %"))
//
ACTIVATE MSDIALOG oIntOFC060 ON INIT EnchoiceBar(oIntOFC060,{|| oIntOFC060:End() },{|| oIntOFC060:End() },,aNewBot)
//
OC0600191_F7(.f.)
//
If lDClik
	OFIC060(cEmpr,aEmpr,aFiltros)
EndIf
Return

/*/{Protheus.doc} OC0600011_ValidIBGEUF()
Consulta IBGE - Municipio / UF

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
@return lRet - logico
/*/
Static Function OC0600011_ValidIBGEUF(nTp)
Local lRet := .t.
If nTp == 1 // IBGE
	If !Empty(cIBGE)
		VAM->(DbSetOrder(1))
		If VAM->(DbSeek(xFilial("VAM")+cIBGE))
			cMunCli := VAM->VAM_DESCID
			cUFCli  := VAM->VAM_ESTADO
		Else
			lRet := .f.
		EndIf
	Else
		cMunCli := ""
	EndIf
ElseIf nTp == 2 // UF
	If !Empty(cUFCli)
		SX5->(DbSetOrder(1))
		If !SX5->(DbSeek(xFilial("SX5")+"12"+cUFCli))
			lRet := .f.
		EndIf
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OC0600021_SalvarVoltarFiltro()
Salvar/Voltar Filtro

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
@return lRet - logico
/*/
Static Function OC0600021_SalvarVoltarFiltro(nTp)
If nTp == 1 // Salvar Filtro
	aFiltros := {cCodCli,cLojCli,cNomCli,dDtIIni,dDtIFin,dDtLIni,dDtLFin,cNivImp,M->VDL_PERFIL,M->VDI_CAMPOP,cCodFas,cCodVen,cTipCon,M->VDI_TIPMID,cMotCan,cTpTotal,cTpGraf,nMaxGraf,cCdPros,cLjPros,cCliPros,dDatRef,cCodEta,cIBGE,cMunCli,cUFCli,cTpPcSr}
Else // Voltar Filtro
	cCodCli       := aFiltros[01]
	cLojCli       := aFiltros[02]
	cNomCli       := aFiltros[03]
	dDtIIni       := aFiltros[04]
	dDtIFin       := aFiltros[05]
	dDtLIni       := aFiltros[06]
	dDtLFin       := aFiltros[07]
	cNivImp       := aFiltros[08]
	M->VDL_PERFIL := aFiltros[09]
	M->VDI_CAMPOP := aFiltros[10]
	cCodFas       := aFiltros[11]
	cCodVen       := aFiltros[12]
	cTipCon       := aFiltros[13]
	M->VDI_TIPMID := aFiltros[14]
	cMotCan       := aFiltros[15]
	cTpTotal      := aFiltros[16]
	cTpGraf       := aFiltros[17]
	nMaxGraf      := aFiltros[18]
	cCdPros       := aFiltros[19]
	cLjPros       := aFiltros[20]
	cCliPros      := aFiltros[21]
	dDatRef       := aFiltros[22]
	cCodEta       := aFiltros[23]
	cIBGE         := aFiltros[24]
	cMunCli       := aFiltros[25]
	cUFCli        := aFiltros[26]
	cTpPcSr       := aFiltros[27]
EndIf
Return .t.

/*/{Protheus.doc} OC0600031_Imprimir()
Impressao dos Interesses Relacionados / Resumo / Historicos

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
/*/
Static Function OC0600031_Imprimir(nTp)
Local ni      := 0
Local nj      := 0
Local aOrd    := {}
Local cDesc1  := STR0041+" - "+STR0042 // Oportunidade Peças/Serviços Oficina / Interesses
Local cDesc2  := ""
Local cDesc3  := ""
Local wnrel   := "OFIC060"
Local cString := "VDL"
Local cPerg   := ""
Private aIntCab      := {}
Private aIntIte      := {}
Private titulo       := STR0042 // Interesses
Private nLin         := 80
Private lAbortPrint  := .F.
Private limite       := 120
Private tamanho      := "G"
Private Cabec1       := ""
Private Cabec2       := ""
Private nTipo        := 15
Private aReturn      := { STR0043, 1, STR0044, 1, 2, 1, "", 1}  //Zebrado # Administracao
Private nLastKey     := 0
Private m_pag        := 01
//
If nTp == 1 // Interesses
//
	aAdd(aIntCab,{STR0003,"C",  35,"@!"}) // Cliente
	aAdd(aIntCab,{STR0035,"C", 100,"@!"}) // Nome
	aAdd(aIntCab,{STR0036,"C",  40,"@!"}) // Telefone
	aAdd(aIntCab,{STR0019,"D",  35,"@D"}) // Dt.Limite
	aAdd(aIntCab,{STR0002,"C",  70,"@!"}) // Fase Oportunidade
	aAdd(aIntCab,{STR0045,"C", 100,"@!"}) // Interesse
	//
	For ni := 1 to len(aInteres)
		aAdd(aIntIte,{ aInteres[ni,01] , aInteres[ni,02] , aInteres[ni,03] , aInteres[ni,04] , aInteres[ni,05] , aInteres[ni,06] })
	Next
	//
	If ExistBlock("OC060IMP")
		ExecBlock("OC060IMP",.F.,.F.,{nTp})
	EndIf
	//
	FGX_VISINT( STR0041 , STR0042 , aIntCab , aIntIte , .t. ) // Oportunidade Peças/Serviços Oficina - Interesses
//
ElseIf nTp == 2 // Resumo
//
	ni := ascan(aTpTotal,cTpTotal)
	If ni > 0
		aAdd(aIntCab,{aTpTotal[ni],"C",155,"@!"}) // Titulo
	Else
		aAdd(aIntCab,{"","C",155,"@!"})
	EndIf
	aAdd(aIntCab,{STR0009,"N",50,"@E 999,999"}) // Qtde
	aAdd(aIntCab,{"%"    ,"N",50,"@E 999.9"})   // %
	//
	For ni := 1 to len(aTotais)
		aAdd(aIntIte,{ aTotais[ni,01] , aTotais[ni,02] , (aTotais[ni,2]/aTotais[1,2])*100  })
	Next
	//
	If ExistBlock("OC060IMP")
		ExecBlock("OC060IMP",.F.,.F.,{nTp})
	EndIf
	//
	FGX_VISINT( STR0041 , STR0046 , aIntCab , aIntIte , .t. ) // Oportunidade Peças/Serviços Oficina - Resumo
//
ElseIf nTp == 3 // Ficha completa do Interesse/Historicos
//
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)
	If nLastKey == 27
		Return
	EndIf
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	EndIf
	nCol  := 0
	cImpr := ""
	For ni := 1 to len(aImpEnchoice)
		If nLin > 64
			nLin  := cabec(cDesc1,cabec1,cabec2,wnrel,Tamanho,nTipo)+1
		EndIf
        nCol++
		cImpr += left(Alltrim(aImpEnchoice[ni,1])+": "+aImpEnchoice[ni,2]+space(72),72)+" "
		If nCol == 3		
			@ nLin++,00 PSAY cImpr
			nCol  := 0
			cImpr := ""
		EndIf
	Next
	If nCol > 0
		@ nLin++,00 PSAY cImpr
	EndIf
	//
	nLin++
	nLin++
	If nLin > 60
		nLin  := cabec(cDesc1,cabec1,cabec2,wnrel,Tamanho,nTipo)+1
	EndIf
	@ nLin++,00 PSAY STR0047 // Historico Interesse
	nLin++
	nCol  := 0
	cImpr := ""
	For ni := 1 to len(aHeader1)
		If !(aHeader1[ni,2] $ "VED_OBSERV")
			If nLin > 64
				nLin  := cabec(cDesc1,cabec1,cabec2,wnrel,Tamanho,nTipo)+1
			EndIf
			If aHeader1[ni,8] == "D"
				nTam := len(Transform(dDataBase,"@D"))
			ElseIf aHeader1[ni,8] == "N"
				nTam := len(Transform(0,aHeader1[ni,3]))
			Else
				nTam := aHeader1[ni,4]
			EndIf
			nCol += nTam+1
			If nCol > 220
				nCol -= nTam+1
				@ nLin++,00 PSAY cImpr
				cImpr := ""
				nCol := 0
			Else
				cImpr += left(aHeader1[ni,1]+space(nTam),nTam)+" "
			EndIf
		EndIf
	Next
	If nCol > 0
		@ nLin++,00 PSAY cImpr
	EndIf
	//
	nCol  := 0
	cImpr := ""
	For nj := 1 to len(aCols1)
		If nLin > 62
			nLin  := cabec(cDesc1,cabec1,cabec2,wnrel,Tamanho,nTipo)+1
		EndIf
		nCol  := 0
		cImpr := ""
		For ni := 1 to len(aHeader1)
			If !(aHeader1[ni,2] $ "VED_OBSERV")
				If aHeader1[ni,8] == "D"
					aHeader1[ni,3] := "@D"
					nTam := len(Transform(dDataBase,"@D"))
				ElseIf aHeader1[ni,8] == "N"
					nTam := len(Transform(0,aHeader1[ni,3]))
				Else
					nTam := aHeader1[ni,4]
				EndIf
				nCol += nTam+1
				If nCol > 220
					nCol -= nTam+1
					@ nLin++,00 PSAY cImpr
					cImpr := ""
					nCol := 0
				Else
					If !Empty(aHeader1[ni,3])
						cImpr += left(Transform(aCols1[nj,ni],aHeader1[ni,3])+space(nTam),nTam)+" "
					Else
						cImpr += left(aCols1[nj,ni]+space(nTam),nTam)+" "
					EndIf
				EndIf
			EndIf
		Next
		If nCol > 0
			@ nLin++,00 PSAY cImpr
		EndIf
	Next
	SET DEVICE TO SCREEN
	If aReturn[5]==1
		DbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	EndIf
	MS_FLUSH()
//
EndIf
//
Return

/*/{Protheus.doc} OC0600041_OrdenaVetorInteresses()
Ordenar VETOR

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
/*/
Static Function OC0600041_OrdenaVetorInteresses(nCol)
If strzero(nCol,1) == left(cOrdVet,1)
	If right(cOrdVet,1) == "C"
		cOrdVet := strzero(nCol,1)+"D" // Decrescente
	Else
		cOrdVet := strzero(nCol,1)+"C" // Crescente
	EndIf
Else
	cOrdVet := strzero(nCol,1)+"C" // Crescente
EndIf
If right(cOrdVet,1) == "C"
	aSort(aInteres,,,{|x,y| x[nCol] < y[nCol] })
Else
	aSort(aInteres,,,{|x,y| x[nCol] > y[nCol] })
EndIf
oLbInteres:Refresh()
oLbInteres:SetFocus()
Return

/*/{Protheus.doc} OC0600051_FILTRAR()
Filtra Registros de Interesse

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
/*/
Static Function OC0600051_FILTRAR(nTp)
Local cBkpFilAnt  := cFilAnt
Local nCont       := 0
Local cQuery      := ""
Local cQAlias     := "SQLVDIVDJVDL"
Local nRecVDL     := 0
Local nRecTab     := 0
Local cVDK_DESFAS := ""
Local cCod        := ""
Local cNom        := ""
Local cFon        := ""
Local nCntTab     := 0
Local cTab        := ""
Local cHis        := ""
Local cAux1       := ""
Local cAux2       := ""
Local cAux3       := ""
Local cAux4       := ""
Local cAux5       := ""
Local cAux6       := ""
Local cAux7       := ""
Local dAux        := dDataBase
//
aInteres := {}
//
ProcRegua(len(aEmpr))
For nCont := 1 to Len(aEmpr)
	cFilAnt := aEmpr[nCont,1]
	IncProc(STR0048) // Levantando... 
	For nCntTab := 1 to 2
		If nCntTab == 1 // Balcao
			If cTpPcSr == "2"
				Loop // Pular Peças se escolheu Serviços
			EndIf
			cTab := "VDI" // Interesse
			cHis := "VED" // Historico
		Else // Oficina
			If cTpPcSr == "1"
				Loop // Pular Serviços se escolheu Peças
			EndIf
			cTab := "VDJ" // Interesse
			cHis := "VEE" // Historico
		EndIf
		//
		cQuery := "SELECT VDL.R_E_C_N_O_ AS RECVDL , "+cTab+".R_E_C_N_O_ AS RECTAB , "+cHis+".R_E_C_N_O_ AS RECHIS , VDK.R_E_C_N_O_ AS RECVDK "
		cQuery += "  FROM "+RetSqlName(cTab)+" "+cTab+" "
		cQuery += "  JOIN "+RetSqlName("VDL")+" VDL ON ( VDL.VDL_FILIAL="+cTab+"."+cTab+"_FILIAL AND VDL.VDL_CODOPO="+cTab+"."+cTab+"_CODOPO AND VDL.D_E_L_E_T_=' ' ) "
		cQuery += "  JOIN "+RetSqlName(cHis)+" "+cHis+" ON ( "+cHis+"."+cHis+"_FILIAL="+cTab+"."+cTab+"_FILIAL AND "+cHis+"."+cHis+"_CODINT="+cTab+"."+cTab+"_CODINT AND "+cHis+"."+cHis+"_CODOPO="+cTab+"."+cTab+"_CODOPO AND "+cHis+".D_E_L_E_T_=' ' ) "
		cQuery += "  LEFT JOIN "+RetSqlName("VDK")+" VDK ON ( VDK.VDK_FILIAL='"+xFilial("VDK")+"' AND VDK.VDK_CODFAS="+cHis+"."+cHis+"_CODFAS AND VDK.D_E_L_E_T_=' ' ) "
		cQuery += " WHERE "+cTab+"."+cTab+"_FILIAL='"+xFilial(cTab)+"'"
		cQuery += "   AND "+cHis+"."+cHis+"_DATHIS<='"+dtos(dDatRef)+"'"
		cQuery += "   AND "+cTab+"."+cTab+"_DATINT>='"+dtos(dDtIIni)+"'"
		cQuery += "   AND "+cTab+"."+cTab+"_DATINT<='"+dtos(dDtIFin)+"'"
		cQuery += "   AND "+cTab+"."+cTab+"_DATLIM>='"+dtos(dDtLIni)+"'"
		cQuery += "   AND "+cTab+"."+cTab+"_DATLIM<='"+dtos(dDtLFin)+"'"
		If !Empty(cNivImp)
			cQuery += " AND VDL.VDL_NIVIMP='"+cNivImp+"'"
		EndIf
		If !Empty(M->VDL_PERFIL)
			cQuery += " AND VDL.VDL_PERFIL='"+M->VDL_PERFIL+"'"
		EndIf
		If !Empty(M->VDI_CAMPOP)
			cQuery += " AND "+cTab+"."+cTab+"_CAMPOP='"+M->VDI_CAMPOP+"'"
		EndIf	
		If !Empty(cTipCon)
			cQuery += " AND "+cTab+"."+cTab+"_TIPCON='"+cTipCon+"'"
		EndIf	
		If !Empty(M->VDI_TIPMID)
			cQuery += " AND "+cTab+"."+cTab+"_TIPMID='"+M->VDI_TIPMID+"'"
		EndIf
		cQuery += "   AND "+cTab+".D_E_L_E_T_=' '"
		cQuery += " ORDER BY VDL.R_E_C_N_O_ , "+cTab+".R_E_C_N_O_ , "+cHis+".R_E_C_N_O_ DESC"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
		Do While !( cQAlias )->( Eof() )
			If nRecVDL == ( cQAlias )->( RECVDL ) .and. nRecTab == ( cQAlias )->( RECTAB )
				( cQAlias )->( DbSkip() )
				Loop
			EndIf
			//
			cVDK_DESFAS := ""
			If ( cQAlias )->( RECVDK ) > 0
				DbSelectArea("VDK")
				DbGoTo(( cQAlias )->( RECVDK ))
				If !Empty(cCodEta) .and. VDK->VDK_CODETA<>cCodEta
					( cQAlias )->( DbSkip() )
					Loop
				EndIf
				cVDK_DESFAS := VDK->VDK_CODFAS+"-"+VDK->VDK_DESFAS
			Else
				If !Empty(cCodEta)
					( cQAlias )->( DbSkip() )
					Loop
				EndIf
			EndIf
			//
			nRecVDL := ( cQAlias )->( RECVDL )
			DbSelectArea("VDL")
			DbGoTo(nRecVDL)
			nRecTab := ( cQAlias )->( RECTAB )
			DbSelectArea(cTab)
			DbGoTo(nRecTab)
			DbSelectArea(cHis)
			nRecHis := ( cQAlias )->( RECHIS )
			DbGoTo(nRecHis)
			//
			If cHis == "VED"
				If !Empty(cCodFas) .and. VED->VED_CODFAS<>cCodFas
					( cQAlias )->( DbSkip() )
					Loop	
				EndIf
				If !Empty(cCodVen) .and. VED->VED_CODVEN<>cCodVen
					( cQAlias )->( DbSkip() )
					Loop	
				EndIf
				If !Empty(cMotCan) .and. VED->VED_MOTCAN<>cMotCan
					( cQAlias )->( DbSkip() )
					Loop
				Elseif lMarMot .and. Empty(VED->VED_MOTCAN)
					( cQAlias )->( DbSkip() )
					Loop
				EndIf
				cAux1 := VED->VED_CODCLI
				cAux2 := VED->VED_LOJCLI
				cAux3 := VED->VED_CDPROS
				cAux4 := VED->VED_LJPROS
				cAux5 := STR0049+" "+Alltrim(VDI->VDI_DESITE) // Peca:
				cAux6 := VDI->VDI_CODOPO
				cAux7 := VDI->VDI_CODINT
				dAux  := VDI->VDI_DATLIM
			Else
				If !Empty(cCodFas) .and. VEE->VEE_CODFAS<>cCodFas
					( cQAlias )->( DbSkip() )
					Loop	
				EndIf
				If !Empty(cCodVen) .and. VEE->VEE_CODVEN<>cCodVen
					( cQAlias )->( DbSkip() )
					Loop	
				EndIf
				If !Empty(cMotCan) .and. VEE->VEE_MOTCAN<>cMotCan
					( cQAlias )->( DbSkip() )
					Loop
				Elseif lMarMot .and. Empty(VEE->VEE_MOTCAN)
					( cQAlias )->( DbSkip() )
					Loop
				EndIf
				cAux1 := VEE->VEE_CODCLI
				cAux2 := VEE->VEE_LOJCLI
				cAux3 := VEE->VEE_CDPROS
				cAux4 := VEE->VEE_LJPROS
				cAux5 := STR0050+" "+Alltrim(VDJ->VDJ_DESSER) // Serviço:
				cAux6 := VDJ->VDJ_CODOPO
				cAux7 := VDJ->VDJ_CODINT
				dAux  := VDJ->VDJ_DATLIM
			EndIf

			Do Case
				Case !Empty(cCodCli) .and. !Empty(cCdPros) // Trazer Cliente e Prospect
					If ( cAux1<>cCodCli .or. ( !Empty(cLojCli) .and. cAux2<>cLojCli ) ) .and. ( cAux3<>cCdPros .or. ( !Empty(cLjPros) .and. cAux4<>cLjPros ) )
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
				Case !Empty(cCodCli) // Trazer somente o Cliente
					If ( cAux1<>cCodCli .or. ( !Empty(cLojCli) .and. cAux2<>cLojCli ) )
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
				Case !Empty(cCdPros) // Trazer somente o Prospect
					If ( cAux3<>cCdPros .or. ( !Empty(cLjPros) .and. cAux4<>cLjPros ) )
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
				Case cCliPros == "1" // Trazer todos os Clientes
					If Empty(cAux1)
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
				Case cCliPros == "2" // Trazer todos os Prospects
					If Empty(cAux3)
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
			EndCase

			cCod := ""
			cNom := ""
			cFon := ""
			If !Empty(cAux1+cAux2)
				SA1->(DbSetOrder(1))
				SA1->(DbSeek(xFilial("SA1")+cAux1+cAux2))
				If !Empty(cIBGE) .and. SA1->A1_IBGE <> cIBGE
					( cQAlias )->( DbSkip() )
					Loop
				ElseIf !Empty(cUFCli) .and. SA1->A1_EST <> cUFCli
					( cQAlias )->( DbSkip() )
					Loop
				EndIf
				cCod := cAux1+"-"+cAux2
				cNom := Alltrim(SA1->A1_NOME)
				cFon := SA1->A1_DDD+" "+SA1->A1_TEL
			ElseIf !Empty(cAux3+cAux4)
				SUS->(DbSetOrder(1))
				SUS->(DbSeek(xFilial("SUS")+cAux3+cAux4))
				If !Empty(cMunCli) .and. Alltrim(SUS->US_MUN) <> Alltrim(cMunCli)
					( cQAlias )->( DbSkip() )
					Loop
				ElseIf !Empty(cUFCli) .and. SUS->US_EST <> cUFCli
					( cQAlias )->( DbSkip() )
					Loop
				EndIf
				cCod := cAux3+"-"+cAux4
				cNom := Alltrim(SUS->US_NOME)+" "+"("+STR0010+")" // Prospect 
				cFon := SUS->US_DDD+" "+SUS->US_TEL
			EndIf		

			aAdd(aInteres,{	cCod ,;
							cNom ,;
							cFon ,;
							dAux ,;
							cVDK_DESFAS ,;
							cAux5 ,;
							cAux6 ,;
							cAux7 ,;
							nRecVDL ,;
							nRecTab ,;
							cFilAnt ,;
							nRecHis ,;
							cTab ,;
							cHis })

			( cQAlias )->( DbSkip() )
		EndDo
		( cQAlias )->( dbCloseArea() )
	Next
Next
cFilAnt := cBkpFilAnt
//
DbSelectArea("VDI")
//
If len(aInteres) <= 0
	aAdd(aInteres,{"","","",ctod(""),"","","","",0,0,"",0})
EndIf
//
If nTp > 0
	oLbInteres:nAt := 1
	oLbInteres:SetArray(aInteres)
	oLbInteres:bLine := { || { aInteres[oLbInteres:nAt,01] ,;
	aInteres[oLbInteres:nAt,02] ,;
	aInteres[oLbInteres:nAt,03] ,;
	Transform(aInteres[oLbInteres:nAt,04],"@D") ,;
	aInteres[oLbInteres:nAt,05] ,;
	aInteres[oLbInteres:nAt,06] }}
	oLbInteres:Refresh()
	OC0600061_TOTAIS(0)
EndIf
Return

/*/{Protheus.doc} OC0600061_TOTAIS()
Totalizar e Grafico

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
/*/
Static Function OC0600061_TOTAIS(nCol)
Local cPesq       := ""
Local nPos        := 0
Local nPosAux     := 0
Local ni          := 0
Local cAux1       := ""
Local cAux2       := ""
Local cAux3       := ""
Local cAux4       := ""
Local cStatusVS1  := ""
Default nCol      := 0
//
aDadosGraf := {}
cTitGraf   := ""
//
Do Case
	Case cTpTotal == "1" // Fase
		cTitGraf := STR0002 // Fase Oportunidade
	Case cTpTotal == "2" // Cliente
		cTitGraf := STR0003 // Cliente
	Case cTpTotal == "3" // Nivel Importancia
		cTitGraf := STR0021 // Nivel Importancia
	Case cTpTotal == "4" // Tipo de Midia
		cTitGraf := STR0005 // Tipo de Midia
	Case cTpTotal == "5" // Vendedor
		cTitGraf := STR0006 // Vendedor
	Case cTpTotal == "6" // Motivo Cancelamento
		cTitGraf := STR0007 // Motivo Cancelamento
	Case cTpTotal == "7" // Etapas do Funil de Vendas
		cTitGraf := STR0008 // Etapas do Funil de Venda
EndCase
//
If nCol == 0
	aTotais := {}
	aAdd(aTotais,{STR0051,0,1,"1"}) // Total Geral
	aAnalit := {}
	aAdd(aAnalit,{STR0052,0,STR0051}) // Em andamento
	aAdd(aAnalit,{STR0053,0,STR0051}) // Faturado
	aAdd(aAnalit,{STR0054,0,STR0051}) // Cancelado
	For ni := 1 to len(aInteres)
		If aInteres[ni,9] > 0 .and. aInteres[ni,10] > 0 .and. aInteres[ni,12] > 0
			//
			DbSelectArea("VDL")
			DbGoTo(aInteres[ni,9])
			DbSelectArea(aInteres[ni,13])
			DbGoTo(aInteres[ni,10])
			DbSelectArea(aInteres[ni,14])
			DbGoTo(aInteres[ni,12])
			cStatusVS1 := ""
			If aInteres[ni,13] == "VDI"
				If !Empty(VDI->VDI_FILORC+VDI->VDI_NUMORC)
					VS1->(DbSetOrder(1))
					VS1->(DbSeek(VDI->VDI_FILORC+VDI->VDI_NUMORC))
					cStatusVS1 := VS1->VS1_STATUS
				EndIf
			Else
				If !Empty(VDJ->VDJ_FILORC+VDJ->VDJ_NUMORC)
					VS1->(DbSetOrder(1))
					VS1->(DbSeek(VDJ->VDJ_FILORC+VDJ->VDJ_NUMORC))
					cStatusVS1 := VS1->VS1_STATUS
				EndIf
			EndIf
			//
			Do Case
				Case cTpTotal == "1" // Fase
					If aInteres[ni,14] == "VED"
						cAux1 := VED->VED_CODFAS
					Else
						cAux1 := VEE->VEE_CODFAS
					EndIf
					VDK->(DbSetOrder(1))
					VDK->(DbSeek(xFilial("VDK")+cAux1))
					cPesq := cAux1+" - "+VDK->VDK_DESFAS
				Case cTpTotal == "2" // Cliente            
					If aInteres[ni,14] == "VED"
						cAux1 := VED->VED_CODCLI
						cAux2 := VED->VED_LOJCLI
						cAux3 := VED->VED_CDPROS
						cAux4 := VED->VED_LJPROS
					Else
						cAux1 := VEE->VEE_CODCLI
						cAux2 := VEE->VEE_LOJCLI
						cAux3 := VEE->VEE_CDPROS
						cAux4 := VEE->VEE_LJPROS
					EndIf
					If !Empty(cAux1+cAux2)
						SA1->(DbSetOrder(1))
						SA1->(DbSeek(xFilial("SA1")+cAux1+cAux2))
						cPesq := cAux1+"-"+cAux2+" "+SA1->A1_NOME
					ElseIf !Empty(cAux3+cAux4)
						SUS->(DbSetOrder(1))
						SUS->(DbSeek(xFilial("SUS")+cAux3+cAux4))
						cPesq := cAux3+"-"+cAux4+" "+SUS->US_NOME
					EndIf
				Case cTpTotal == "3" // Nivel Importancia
					cPesq := VDL->VDL_NIVIMP
				Case cTpTotal == "4" // Tipo de Midia
					If aInteres[ni,13] == "VDI"
						cAux1 := VDI->VDI_TIPMID
					Else
						cAux1 := VDJ->VDJ_TIPMID
					EndIf
					VX5->(DbSetOrder(1))
					VX5->(DbSeek(xFilial("VX5")+"027"+cAux1))
					cPesq := cAux1+" - "+VX5->VX5_DESCRI
				Case cTpTotal == "5" // Vendedor
					If aInteres[ni,14] == "VED"
						cAux1 := VED->VED_CODVEN
					Else
						cAux1 := VEE->VEE_CODVEN
					EndIf
					SA3->(DbSetOrder(1))
					SA3->(DbSeek(xFilial("SA3")+cAux1))
					cPesq := cAux1+" - "+SA3->A3_NOME
				Case cTpTotal == "6" // Motivo Cancelamento
					If aInteres[ni,14] == "VED"
						cAux1 := VED->VED_MOTCAN
					Else
						cAux1 := VEE->VEE_MOTCAN
					EndIf
					VS0->(DbSetOrder(1))
					VS0->(DbSeek(xFilial("VS0")+'000022'+cAux1))
					cPesq := cAux1+" - "+VS0->VS0_DESMOT
				Case cTpTotal == "7" // Etapas do Funil de Vendas
					If aInteres[ni,14] == "VED"
						cAux1 := VED->VED_CODFAS
					Else
						cAux1 := VEE->VEE_CODFAS
					EndIf
					VDK->(DbSetOrder(1))
					VDK->(DbSeek(xFilial("VDK")+cAux1))
					cPesq := ""
					VQT->(DbSetOrder(1))
					VQT->(DbSeek(xFilial("VQT")+VDK->VDK_CODETA))
					cPesq := VQT->VQT_SEQUEN+" "+VDK->VDK_CODETA+" - "+VQT->VQT_DESCRI
			EndCase
			nPos := aScan(aTotais,{|x| x[1] == cPesq })
			If nPos <= 0
				aAdd(aTotais,{cPesq,0,0,"2"})
				nPos := len(aTotais)
			EndIf
			aTotais[nPos,2]++
			aTotais[1,2]++
			//
			nPosAux := aScan(aAnalit,{|x| x[3] == cPesq })
			If nPosAux <= 0
				nPosAux := len(aAnalit)+1
				aAdd(aAnalit,{STR0052,0,cPesq}) // Em andamento
				aAdd(aAnalit,{STR0053,0,cPesq}) // Faturado
				aAdd(aAnalit,{STR0054,0,cPesq}) // Cancelado
			EndIf
			If aInteres[ni,14] == "VED"
				cAux1 := VED->VED_MOTCAN
			Else
				cAux1 := VEE->VEE_MOTCAN
			EndIf
			If !Empty(cAux1) .or. cStatusVS1 == "C" // Cancelado
				aAnalit[nPosAux+2,2]++
				aAnalit[3,2]++ // Total
			ElseIf cStatusVS1 == "F" // Faturado
				aAnalit[nPosAux+1,2]++
				aAnalit[2,2]++ // Total
			Else // Em andamento
				aAnalit[nPosAux+0,2]++
				aAnalit[1,2]++ // Total
			EndIf
			//
		EndIf
	Next
EndIf
If cTpTotal == "0" // Etapas do Funil de Vendas
	If nCol == 0
		nCol := 1
	EndIf
EndIf
If nCol == 1
	aSort(aTotais,,,{|x,y| x[4]+x[1]+strzero(99999999-x[2],8) < y[4]+y[1]+strzero(99999999-y[2],8) }) // Titulo Crescente + Ordem Decrescente
Else
	aSort(aTotais,,,{|x,y| x[4]+strzero(99999999-x[2],8)+x[1] < y[4]+strzero(99999999-y[2],8)+y[1] }) // Ordem Decrescente + Titulo Crescente
EndIf
oLbTotais:nAt := 1
oLbTotais:SetArray(aTotais)
oLbTotais:bLine := { || { aTotais[oLbTotais:nAt,01] , FG_AlinVlrs(Transform(aTotais[oLbTotais:nAt,2],"@E 999,999")) , FG_AlinVlrs(Transform((aTotais[oLbTotais:nAt,2]/aTotais[1,2])*100,"@E 999.9"))+" %" }}
oLbTotais:Refresh()
For ni := 2 to len(aTotais)
	If ni < ( nMaxGraf+2 )
		Aadd( aDadosGraf , { aTotais[ni,02] , aTotais[ni,01] } )
	ElseIf ni == ( nMaxGraf+2 )
		Aadd( aDadosGraf , { aTotais[ni,02] , STR0055 } ) // Demais
	Else
		aDadosGraf[len(aDadosGraf),1] += aTotais[ni,02]
	EndIf
Next
If len(aDadosGraf) <= 0
	aAdd( aDadosGraf , { 0 , "" } )
EndIf
For ni := 1 to len(aDadosGraf)
	aDadosGraf[ni,02] := left(aDadosGraf[ni,02],22)
	If cTpGraf == "2" // %
		aDadosGraf[ni,01] := round( ( aDadosGraf[ni,01] / aTotais[1,02] ) * 100 , 1 )
	EndIf
Next
FG_NEWGRAF(oGrafPeq,cTitGraf+" ( "+IIf(cTpGraf=="1",STR0009,"%")+" )",aDadosGraf,.F.,IIf(cTpGraf=="1","@E 999,999,999","@E 999.9 %"))
oGrafPeq:LREADONLY := .T.
Return

/*/{Protheus.doc} OC0600071_TotalStatus()
Totaliza/Grafico: Em andamento / Faturado / Cancelado

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
/*/
Static Function OC0600071_TotalStatus(nLinha)
Local aObjects   := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {} 
Local aSizeAut   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntAna    := 0
Local aLbGrafA   := {}
Local aDBGrafA   := {}
Local cTitTela   := ""
nCntAna := ascan(aTpTotal,cTpTotal)
If nCntAna > 0
	cTitTela := substr(aTpTotal[nCntAna],3)
EndIf
aAdd(aLbGrafA,{STR0051,0,0}) // Total Geral
For nCntAna := 1 to Len(aAnalit)
	If aAnalit[nCntAna,3] == aTotais[nLinha,01]
   		aAdd(aLbGrafA,aClone(aAnalit[nCntAna]))
   		aLbGrafA[1,2] += aAnalit[nCntAna,2]
 	EndIf
Next
Aadd( aDBGrafA , { round( ( aLbGrafA[2,02] / aLbGrafA[1,02] ) * 100 , 1 ) , aLbGrafA[2,01] } ) // Em andamento
Aadd( aDBGrafA , { round( ( aLbGrafA[3,02] / aLbGrafA[1,02] ) * 100 , 1 ) , aLbGrafA[3,01] } ) // Faturado
Aadd( aDBGrafA , { round( ( aLbGrafA[4,02] / aLbGrafA[1,02] ) * 100 , 1 ) , aLbGrafA[4,01] } ) // Cancelado
//
AAdd( aObjects, { 01, 65 , .T. , .F. } )
AAdd( aObjects, { 01, 00 , .T. , .T. } )
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)
//
DEFINE MSDIALOG oTotAFC FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE (cTitTela+" - "+aTotais[nLinha,01]) OF oMainWnd PIXEL
@ aPosObj[1,1],aPosObj[1,2] LISTBOX oLbGrafA FIELDS HEADER aTotais[nLinha,01],STR0009,"%" COLSIZES 117,27,25 SIZE aPosObj[1,4],aPosObj[1,3]-aPosObj[1,1] OF oTotAFC PIXEL // Qtde / %
oLbGrafA:SetArray(aLbGrafA)
oLbGrafA:bLine := { || { aLbGrafA[oLbGrafA:nAt,01] , FG_AlinVlrs(Transform(aLbGrafA[oLbGrafA:nAt,2],"@E 999,999")) , FG_AlinVlrs(Transform((aLbGrafA[oLbGrafA:nAt,2]/aLbGrafA[1,02])*100,"@E 999.9"))+" %" }}
@ aPosObj[2,1],aPosObj[2,2] SCROLLBOX oGrafAna SIZE aPosObj[2,3]-aPosObj[2,1],aPosObj[2,4] OF oTotAFC BORDER PIXEL
FG_NEWGRAF(oGrafAna,aTotais[nLinha,01]+" ( % )",aDBGrafA,.F.,"@E 999.9 %")
oGrafAna:LREADONLY := .T.
ACTIVATE MSDIALOG oTotAFC CENTER ON INIT (EnchoiceBar(oTotAFC,{|| oTotAFC:End() },{ || oTotAFC:End()},,))
Return

/*/{Protheus.doc} OC0600081_FILIAIS()
Levanta Filiais

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
/*/
Static Function OC0600081_FILIAIS()
Local aVetAux    := {}
Local ni         := {}
Local cBkpFilAnt := cFilAnt
Local nCont      := 0
Local aFilAtu    := {}
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aFilAtu := FWArrFilAtu()
	ni := aScan(aEmpr,{|x| x[1] == cFilAnt })
	aAdd( aVetEmp, { (ni>0) , cFilAnt , aFilAtu[SM0_FILIAL] , FWFilialName() })
Next
cFilAnt := cBkpFilAnt
If Len(aVetEmp) > 1
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 250,400 TITLE STR0034 PIXEL // Filiais
	@ 001,001 LISTBOX oLbEmp FIELDS HEADER "",STR0056,STR0035 COLSIZES 10,15,50 SIZE 165,120 OF oDlgEmp ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL // Filial / Nome
	oLbEmp:SetArray(aVetEmp)
	oLbEmp:bLine := { || {  IIf(aVetEmp[oLbEmp:nAt,1],oOk,oNo) ,;
	aVetEmp[oLbEmp:nAt,3],;
	aVetEmp[oLbEmp:nAt,4] }}
	DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp
	@ 002, 002 CHECKBOX oMacTod VAR lMarcar PROMPT "" OF oDlgEmp ON CLICK IIf( OC0600091_TikFilial(lMarcar ) , .t. , ( lMarcar:=!lMarcar , oDlgEmp:Refresh() ) ) 	SIZE 70,08 PIXEL COLOR CLR_BLUE
	ACTIVATE MSDIALOG oDlgEmp CENTER
EndIf
If len(aVetEmp) == 1
	aVetEmp[1,1] := .t.
EndIf
For ni := 1 to len(aVetEmp)
	If aVetEmp[ni,1]
		aAdd( aVetAux, { aVetEmp[ni,2] , aVetEmp[ni,3] })
		cEmpr += Alltrim(aVetEmp[ni,2])+", "
	EndIf
Next
If len(aVetAux) > 1
	cEmpr := substr(cEmpr,1,len(cEmpr)-2)
EndIf
Return aVetAux

/*/{Protheus.doc} OC0600091_TikFilial()
TIK no ListBox da Empresa/Filiais

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
/*/
Static Function OC0600091_TikFilial(lMarcar)
Local ni := 0
Default lMarcar := .f.
For ni := 1 to Len(aVetEmp)
	If lMarcar
		aVetEmp[ni,1] := .t.
	Else
		aVetEmp[ni,1] := .f.
	EndIf
Next
oLbEmp:SetFocus()
oLbEmp:Refresh()
Return .t.

/*/{Protheus.doc} OC0600101_PosicionaClienteProspect()
Seleciona Cliente

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
/*/
Static Function OC0600101_PosicionaClienteProspect(cTipo,lRefresh)
Local cQuery  := ""
Local nRecAux := 0
Local lRet    := .f.
If cTipo == "CL"  // Verifica Cliente+Loja
	cNomCli := space(100)
	If !Empty(cCodCli)
		cQuery  := "SELECT R_E_C_N_O_ FROM "+RetSqlName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+cCodCli+"' "+IIf(!Empty(cLojCli),"AND A1_LOJA='"+cLojCli+"' ","")+"AND D_E_L_E_T_=' '"
		nRecAux := FM_SQL(cQuery)
		If nRecAux > 0
			lRet := .t.
			DbSelectArea("SA1")
			DbGoTo(nRecAux)
			cNomCli := SA1->A1_NOME
			cQuery  := "SELECT R_E_C_N_O_ FROM "+RetSqlName("SUS")+" WHERE US_FILIAL='"+xFilial("SUS")+"' AND US_CODCLI='"+cCodCli+"' "+IIf(!Empty(cLojCli),"AND US_LOJACLI='"+cLojCli+"' ","")+"AND D_E_L_E_T_=' '"
			nRecAux := FM_SQL(cQuery)
			If nRecAux > 0
				DbSelectArea("SUS")
				DbGoTo(nRecAux)
				cCdPros := SUS->US_COD
				If !Empty(cLojCli)
					cLjPros := SUS->US_LOJA
				EndIf
			Else
				cCdPros := space(TamSX3("US_COD")[1])
				cLjPros := space(TamSX3("US_LOJA")[1])
			EndIf
		EndIf
	Else
		cLojCli := space(TamSX3("A1_LOJA")[1])
		lRet := .t.
	EndIf
	If lRefresh
		oNomCli:Refresh()
	EndIf
ElseIf cTipo == "PR"  // Verifica Prospect+Loja
	cNomCli := space(100)
	If !Empty(cCdPros)
		cQuery  := "SELECT R_E_C_N_O_ FROM "+RetSqlName("SUS")+" WHERE US_FILIAL='"+xFilial("SUS")+"' AND US_COD='"+cCdPros+"' "+IIf(!Empty(cLjPros),"AND US_LOJA='"+cLjPros+"' ","")+"AND D_E_L_E_T_=' '"
		nRecAux := FM_SQL(cQuery)
		If nRecAux > 0
			lRet := .t.
			DbSelectArea("SUS")
			DbGoTo(nRecAux)
			cNomCli := SUS->US_NOME
			cCodCli := SUS->US_CODCLI
			If !Empty(cLjPros)
				cLojCli := SUS->US_LOJACLI
			EndIf
		Else
			cCodCli := space(TamSX3("A1_COD")[1])
			cLojCli := space(TamSX3("A1_LOJA")[1])
		EndIf
	Else
		cLjPros := space(TamSX3("US_LOJA")[1])
		lRet := .t.
	EndIf
	If lRefresh
		oNomCli:Refresh()
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OC0600111_SelecionaClienteProspect()
Cliente ou Prospect

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
/*/
Static Function OC0600111_SelecionaClienteProspect()
oCodCli:lVisible := .f.
oLojCli:lVisible := .f.
oCdPros:lVisible := .f.
oLjPros:lVisible := .f.
oTodCli:lVisible := .f.
oNomCli:lVisible := .t.
If cCliPros == "1" // Cliente
	oCodCli:lVisible := .t.
	oLojCli:lVisible := .t.
	OC0600101_PosicionaClienteProspect("CL",.t.)
	oCodCli:SetFocus()
ElseIf cCliPros == "2" // Prospect
	oCdPros:lVisible := .t.
	oLjPros:lVisible := .t.
	OC0600101_PosicionaClienteProspect("PR",.t.)
	oCdPros:SetFocus()
Else // Todos Cliente e Prospect
	oTodCli:lVisible := .t.
	oNomCli:lVisible := .f.
EndIf
oCodCli:Refresh()
oLojCli:Refresh()
oCdPros:Refresh()
oLjPros:Refresh()
Return .t.

/*/{Protheus.doc} OC0600121_VisualizaDetalheInteresse()
Visualiza Interesse detalhadamente

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
/*/
Static Function OC0600121_VisualizaDetalheInteresse(cCodOpo,cCodInt,cFAnt)
Local aObjects    := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut    := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor     := 0
Local nTempo      := 0
Local nDias       := 0
Local cCFas       := ""
Local dData       := ctod("")
Local nHora       := 0
Local dDtPx       := ctod("")
Local nHrPx       := 0
Local nLinha      := 0
Local i           := 0
Local bCampo      := { |nCPO| Field(nCPO) }
Local lImpr       := .f.
Local _ni         := 0
Local aNewBot     := {}
Local cBkpFilAnt  := cFilAnt // Salvar Filial
Local cAliasAUX   := "SQLAUX"
Local cImpr       := ""
Local cAux        := ""
//
Local cVDL_PERFIL := M->VDL_PERFIL // Salva variavel
Local cVDI_CAMPOP := M->VDI_CAMPOP // Salva variavel
Local cVDI_TIPMID := M->VDI_TIPMID // Salva variavel
//
Private oFnt3   := TFont():New( "Arial", , 14,.t. )
Private aCpoEnchoice := {} 
Private aImpEnchoice := {}
Private aCols1       := {} , aHeader1 := {}
Private INCLUI       := .f.
Private aRotina      := {{"","axPesqui",0,1},{"","",0,2}}

If Empty(cCodOpo+cCodInt)
	Return .t.
EndIf

AADD(aNewBot,{"IMPRESSAO",{|| OC0600031_Imprimir(3) } , STR0057 } ) // Impressao

aObjects := {}
AAdd( aObjects , { 000, 50 , .T. , .T. } ) // Enchoice ( Oportunidade / Interesse )
AAdd( aObjects , { 000, 50 , .T. , .T. } ) // aCols ( Historico Interesse )

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)

nOpcE := 2

cFilAnt := cFAnt // Mudar para filial do registro

dbSelectArea("VDL")
dbSetOrder(1)
dbSeek(xFilial("VDL")+cCodOpo)
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VDL")
While !Eof().and.(x3_arquivo=="VDL")
	lImpr := .f.
	If X3USO(x3_usado).and.cNivel>=x3_nivel
		AADD(aCpoEnchoice,x3_campo)
		lImpr := .t.
	Endif
	If SX3->X3_CONTEXT == "V"
		&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
	Else
		If !Empty(SX3->X3_CBOX)
			&("M->"+x3_campo) := X3CBOXDESC(x3_campo,&("VDL->"+Alltrim(x3_campo)))
		Else
			&("M->"+x3_campo) := &("VDL->"+Alltrim(x3_campo))
		EndIf
	EndIf
	If lImpr
		AADD(aImpEnchoice,{SX3->X3_TITULO,Transform(&("M->"+x3_campo),SX3->X3_PICTURE),SX3->X3_TAMANHO})
	EndIf
	DbSkip()
EndDo

dbSelectArea("VDI")
dbSetOrder(1)
If dbSeek(xFilial("VDI")+cCodOpo+cCodInt) // Interesse de Peça
	cTab := "VDI"
	cHis := "VED"
Else
	dbSelectArea("VDJ")
	dbSetOrder(1)
	dbSeek(xFilial("VDJ")+cCodOpo+cCodInt) // Interesse de Serviço
	cTab := "VDJ"
	cHis := "VEE"
EndIf
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cTab)
While !Eof().and.(x3_arquivo==cTab)
	lImpr := .f.
	If X3USO(x3_usado).and.cNivel>=x3_nivel .and. !(Alltrim(x3_campo) $ [VDI_CODOPO/VDI_OBSERV/VDJ_CODOPO/VDJ_OBSERV/])
		AADD(aCpoEnchoice,x3_campo)
		lImpr := .t.
	Endif
	If SX3->X3_CONTEXT == "V"
		&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
	Else
		If !Empty(SX3->X3_CBOX)
			&("M->"+x3_campo) := X3CBOXDESC(x3_campo,&(cTab+"->"+Alltrim(x3_campo)))
		Else
			&("M->"+x3_campo) := &(cTab+"->"+Alltrim(x3_campo))
		EndIf
	EndIf
	If lImpr
		AADD(aImpEnchoice,{SX3->X3_TITULO,Transform(&("M->"+x3_campo),SX3->X3_PICTURE),SX3->X3_TAMANHO})
	EndIf
	DbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado1:=0
dbSelectArea("SX3")
dbSeek(cHis)
While !Eof().And.(x3_arquivo==cHis)
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !( Alltrim(x3_campo) $ "VED_CODIGO/VED_CODOPO/VED_CODINT/VEE_CODIGO/VEE_CODOPO/VEE_CODINT/" )
		nUsado1++
		Aadd(aHeader1,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
	Endif
	dbSkip()
End
cQuery := "SELECT R_E_C_N_O_ AS REC"
cQuery += "  FROM " + RetSqlName(cHis)
cQuery += " WHERE "+cHis+"_FILIAL='"+xFilial(cHis)+"'"
cQuery += "   AND "+cHis+"_CODINT='"+cCodInt+"'"
cQuery += "   AND "+cHis+"_CODOPO='"+cCodOpo+"'"
cQuery += "   AND D_E_L_E_T_=' '"
cQuery += " ORDER BY "+cHis+"_CODIGO"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasAUX, .T., .T. )
aCols1 := {}
nReg1 := 1
Do While !( cAliasAUX )->( Eof() )
	If cHis == "VED"
		VED->(dbGoto(( cAliasAUX )->REC))
		cAux := VED->VED_CODFAS
	Else
		VEE->(dbGoto(( cAliasAUX )->REC))
		cAux := VEE->VEE_CODFAS
	EndIf
	VDK->(dbSetOrder(1))
	VDK->(dbSeek(xFilial("VDK")+cAux))
	Aadd(aCols1, Array(Len(aHeader1)+1) )
	nReg1 := len(aCols1)
	aCols1[nReg1,nUsado1+1]:=.F.
	For _ni:=1 to nUsado1
		aCols1[nReg1,_ni] := CriaVar(aHeader1[_ni,2])
		If aHeader1[_ni,2] <> cHis+"_TEMPO"
			xConteudo := &(cHis+"->"+aHeader1[_ni,2])
			If !Empty(xConteudo)
				aCols1[nReg1,FG_POSVAR(aHeader1[_ni,2],"aHeader1")] := xConteudo
			EndIf
		EndIf
	Next
	( cAliasAUX )->(DbSkip())
Enddo
( cAliasAUX )->( dbCloseArea() )
DbSelectArea(cHis)
//
If len(aCols1) > 0
	For i := 1 to Len(aCols1)
		dDtPx  := ctod("")
		nTempo := 0
		nDias  := 0
		dData  := aCols1[i,FG_POSVAR(cHis+"_DATHIS","aHeader1")]
		nHora  := val(aCols1[i,FG_POSVAR(cHis+"_HORHIS","aHeader1")])
		cCFas  := aCols1[i,FG_POSVAR(cHis+"_CODFAS","aHeader1")]
		i++
		if i <= Len(aCols1)
			dDtPx   := aCols1[i,FG_POSVAR(cHis+"_DATHIS","aHeader1")]
			nHrPx   := val(aCols1[i,FG_POSVAR(cHis+"_HORHIS","aHeader1")])
		Else
			dDtPx   := dDataBase
			nHrPx   := val(substr(Time(),1,2)+substr(Time(),4,2))
		EndIf
		If !Empty(dDtPx)
			nDias := dDtPx - dData
			if nDias == 0
				nTempo := ( int(nHrPx/100) + (nHrPx % 100)/60 ) - ( int(nHora/100) + (nHora % 100)/60 )
				nTempo := round( int(nTempo) * 100 + (nTempo % 1) * 60 , 0 )
			Else
				nTempo := ( int(nHrPx/100) + (nHrPx % 100)/60 ) - ( int(nHora/100) + (nHora % 100)/60 )
				if nTempo < 0
					nDias  -= 1
					nTempo += 24
				Endif
				nTempo := round( int(nTempo) * 100 + (nTempo % 1) * 60 , 0 )
			Endif
		Endif
		i--
		If nTempo <> 0
			aCols1[i,FG_POSVAR(cHis+"_TEMPO","aHeader1")] := Alltrim(str(nDias))+" "+STR0058+" "+transform(strzero(nTempo,4),"@R 99:99")+"h" // dia(s) e / h
		Else
			aCols1[i,FG_POSVAR(cHis+"_TEMPO","aHeader1")] := ""
		EndIf
	Next
Else
	Aadd(aCols1, Array(Len(aHeader1)+1) )
	aCols1[1,nUsado1+1]:=.F.
	For _ni:=1 to nUsado1
		aCols1[1,_ni]:=CriaVar(aHeader1[_ni,2])
	Next
EndIf
//
DEFINE MSDIALOG oDlgVis FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0059 OF oMainWnd PIXEL // Detalhes do Interesse
oScrolVis := TScrollBox():New( oDlgVis , aPos[1,1] , aPos[1,2] , aPos[1,3]-aPos[1,1] , aPos[1,4] , .t. , , .t. )
For i := 1 to Len(aCpoEnchoice) STEP 2
	nLinha++
	if Len(aCpoEnchoice) >= i+0
		FSX_POSCPO(aCpoEnchoic[i+0],"oCPO"+strzero(i+0,3),012*nLinha,(aPos[1,2]/1)+5,045,,,,,"oScrolVis")
	Endif
	if Len(aCpoEnchoice) >= i+1
		FSX_POSCPO(aCpoEnchoic[i+1],"oCPO"+strzero(i+1,3),012*nLinha,(aPos[1,4]/2)+0,045,,,,,"oScrolVis")
	Endif
Next
oFolderGD := TFolder():New(aPos[2,1],aPos[2,2],{STR0047},{}, oDlgVis,,,,.t.,.f.,aPos[2,4],aPos[2,3]-aPos[2,1])
oGetDados1 := MsNewGetDados():New(0,0,aPos[2,3]-aPos[2,1]-20,aPos[2,4]-aPos[2,2],0,"AlwaysTrue()","AlwaysTrue()",,{},,999,"AlwaysTrue()",,"AlwaysTrue()",oFolderGD:aDialogs[1],aHeader1,aCols1)
ACTIVATE MSDIALOG oDlgVis CENTER ON INIT EnchoiceBar(oDlgVis,{|| oDlgVis:End() },{|| oDlgVis:End() },,aNewBot)
//
cFilAnt := cBkpFilAnt // Voltar Filial salva
//
M->VDL_PERFIL := cVDL_PERFIL // Volta variavel salva
M->VDI_CAMPOP := cVDI_CAMPOP // Volta variavel salva
M->VDI_TIPMID := cVDI_TIPMID // Volta variavel salva
//
Return .t.

/*/{Protheus.doc} OC0600131_MotivoCancelamento()
Motivo do Cancelamento - Tik  

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
/*/
Static Function OC0600131_MotivoCancelamento(nTp)
If nTp == 0
	If lMarMot
		cMotCan := space(TamSX3("VDI_MOTCAN")[1])
		oMotCan:Refresh()
	EndIf
ElseIf nTp == 1 
	If !Empty(cMotCan)
		lMarMot := .f.
		oMarMot:Refresh()
	EndIf
EndIf
Return .t.

/*/{Protheus.doc} OC0600141_FUNIL()
Funil das Oportunidades - Etapas dos Interesses

@author Andre Luis Almeida
@since 18/02/2019
@version 1.0
/*/
Function OC0600141_FUNIL()
Local oSize      := FwDefSize():New(.f.) // SEM enchoicebar
Local nLinha     := 0
Local oFont1     := TFont():New(,10,20,,.F.,,,,,,,,,,,)
Local oFont2     := TFont():New(,08,16,,.F.,,,,,,,,,,,)
Local oPanel1
Local oDlgChart
Local nCntFor    := 0
Local lAllFil    := .f.
Local aFilSelect := {}
Local aFilAtu    := {}
Local aFilAux    := {}
Local aParametros := {}
Private oChart
Private aSerie   := {}
Private oOkTik     := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik     := LoadBitmap( GetResources() , "LBNO" )
Private cFiltroVX5 := "026" // Filtro da Campanha
aParametros := {	dDataBase-day(dDataBase)+1 ,;
					dDataBase ,;
					dDataBase ,;
					space(TamSX3("VED_CODVEN")[1]) ,;
					space(TamSX3("VDL_CODCLI")[1]) ,;
					space(TamSX3("VDL_LOJCLI")[1]) ,;
					space(TamSX3("VDL_CDPROS")[1]) ,; 
					space(TamSX3("VDL_LJPROS")[1]) ,;
					space(TamSX3("VDI_CAMPOP")[1]) ,;
					cFilAnt ,;
					"" }
aFilAtu := FWArrFilAtu()
aFilAux := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
For nCntFor := 1 to len(aFilAux)
	aAdd(aFilSelect,{ ( lAllFil .or. aParametros[10] == aFilAux[nCntFor] ) , aFilAux[nCntFor] })
Next
//
OC0600191_F7(.f.)
//
// Calcula as dimensões dos objetos
oSize:lLateral := .T. // Cálculo vertical
oSize:AddObject("FILTROS", 120 , 0 , .F., .T.) // Adiciona Filtros
oSize:AddObject("FUNIL"  ,   0 , 0 , .T., .T.) // Adiciona Grafico Funil
// Dispara o cálculo
oSize:Process()
//
DEFINE MSDIALOG oDlgChart TITLE STR0060 ; // Funil de Peças/Serviços Oficina - Oportunidades - Etapas dos Interesses
	FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] PIXEL

	oPanelFiltr := TPanel():New(	oSize:GetDimension("FILTROS", "LININI") ,;
									oSize:GetDimension("FILTROS", "COLINI") ,;
									"",oDlgChart,NIL,.T.,.F.,NIL,NIL,;
									oSize:GetDimension("FILTROS", "COLEND") ,;
									oSize:GetDimension("FILTROS", "LINEND")-oSize:GetDimension("FILTROS", "LININI") ,;
									.T.,.F.)

	nLinha := 07
	@ nLinha,40 SAY UPPER(STR0016) SIZE 40,10 FONT oFont1 OF oPanelFiltr PIXEL COLOR CLR_BLUE // FILTROS
	nLinha += 20
	@ nLinha,05 SAY STR0061 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Data Inicial
	@ nLinha,45 MSGET oDtIInt VAR aParametros[01] PICTURE "@D" SIZE 50,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0062 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Data Final
	@ nLinha,45 MSGET oDtFInt VAR aParametros[02] PICTURE "@D" SIZE 50,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0063 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Data Corte
	@ nLinha,45 MSGET oDtCInt VAR aParametros[03] PICTURE "@D" SIZE 50,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0006 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Vendedor
	@ nLinha,45 MSGET oVdCInt VAR aParametros[04] PICTURE "@!" F3 "SA3" SIZE 40,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0003 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Cliente
	@ nLinha,45 MSGET oCdClie VAR aParametros[05] PICTURE "@!" F3 "SA1" SIZE 40,8 PIXEL OF oPanelFiltr HASBUTTON
	@ nLinha,85 MSGET oLjClie VAR aParametros[06] PICTURE "@!" SIZE 20,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0010 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Prospect
	@ nLinha,45 MSGET oCdPrsc VAR aParametros[07] PICTURE "@!" F3 "SUS" SIZE 40,8 PIXEL OF oPanelFiltr HASBUTTON
	@ nLinha,85 MSGET oLjPrsc VAR aParametros[08] PICTURE "@!" SIZE 20,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0023 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Campanha
	@ nLinha,45 MSGET oCampan VAR aParametros[09] PICTURE "@!" F3 "VX5AUX" SIZE 40,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0030 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Tipo
	@ nLinha,45 MSCOMBOBOX oTpPecSer VAR aParametros[11] ITEMS {"","1="+STR0031,"2="+STR0032} SIZE 50,8 PIXEL OF oPanelFiltr // Pecas / Servicos
	nLinha += 12
	oLbFiliais := TWBrowse():New( nLinha,;
								005,;
								100,;
								65,;
								,,,oPanelFiltr,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
	oLbFiliais:addColumn( TCColumn():New( "", { || IIf(aFilSelect[oLbFiliais:nAt,1],oOkTik,oNoTik) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Tik
	oLbFiliais:addColumn( TCColumn():New( STR0034 , { || aFilSelect[oLbFiliais:nAt,02] } ,,,, "LEFT" ,  60 ,.F.,.F.,,,,.F.,) ) // Filiais
	oLbFiliais:nAt := 1
	oLbFiliais:SetArray(aFilSelect)
	oLbFiliais:bLDblClick   := { || ( aFilSelect[oLbFiliais:nAt,1] := !aFilSelect[oLbFiliais:nAt,1] ) }
	oLbFiliais:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lAllFil := !lAllFil , aEval(aFilSelect,{|x| x[1] := lAllFil }) , oLbFiliais:Refresh() ) , .t. ) , }

	nLinha += 80
	@ nLinha,35 BUTTON oFiltrar PROMPT STR0033 OF oPanelFiltr SIZE 48,10 PIXEL ACTION OC0600151_MontaGrafico( aParametros , aFilSelect , .t. ) // Filtrar

	oPanelChart := TPanel():New(	oSize:GetDimension("FUNIL", "LININI") ,;
									oSize:GetDimension("FUNIL", "COLINI") ,;
									"",oDlgChart,,,,,,;
									oSize:GetDimension("FUNIL", "COLEND") ,;
									oSize:GetDimension("FUNIL", "LINEND")-oSize:GetDimension("FUNIL", "LININI") )

	oChartFactory := FWChartFactory():New()
	oChart := oChartFactory:getInstance( 05 )
	oChart:SetOwner(oPanelChart)

	oChart:setTitle(STR0060, CONTROL_ALIGN_CENTER) // Funil de Peças/Serviços Oficina - Oportunidades - Etapas dos Interesses
	oChart:setLegend( CONTROL_ALIGN_BOTTOM )
	oChart:setMask( " *@* " )
	oChart:setPicture( "@E 999,999,999" )

	OC0600151_MontaGrafico( aParametros , aFilSelect , .f. )

	oChart:SetSerieAction({ |nSerie| OC0600161_ClickGrafico( nSerie , aParametros , aFilSelect ) })

	oChart:oChart:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)

	oChart:Activate()

	//
ACTIVATE DIALOG oDlgChart
//
OC0600191_F7(.t.)
//
Return

/*/{Protheus.doc} OC0600151_MontaGrafico
Monta Grafico do Funil

@author Andre
@since 08/06/2018
@version undefined

@type function
/*/
Static Function OC0600151_MontaGrafico( aParametros , aFilSelect , lRefresh )
Local cQuery  := ""
Local cQAlias := "SQLFUNIL"
Local nCntFor := 0
Local nPosAux := 0
Local nTab    := 0
Local cTab    := ""
Local cHis    := ""
Local aAux    := {}
Local cBkpFilAnt := cFilAnt
//
aSerie := {}
//
If lRefresh
	oChart:DeActivate() // Limpar as Series do Grafico
EndIf

For nCntFor := 1 to len(aFilSelect)

	If aFilSelect[nCntFor,1]

		cFilAnt := aFilSelect[nCntFor,2]

		For nTab := 1 to 2

			If nTab == 1
				If aParametros[11] == "2"
					Loop // Pular Peças se escolheu Serviços
				EndIf
				cTab := "VDI" // Pecas
				cHis := "VED" // Historico
			Else
				If aParametros[11] == "1"
					Loop // Pular Serviços se escolheu Peças
				EndIf
				cTab := "VDJ" // Servicos 
				cHis := "VEE" // Historico
			EndIf

			cQuery := "SELECT VQT_SEQUEN , VQT_CODIGO , VQT_DESCRI , COUNT(*) AS QTD "
			cQuery += "FROM ( "
			cQuery += "   SELECT VQT.VQT_SEQUEN , VQT.VQT_CODIGO , VQT.VQT_DESCRI , "+cTab+".R_E_C_N_O_ "
			cQuery += "   FROM "+RetSqlName("VDL")+" VDL "
			cQuery += "   JOIN "+RetSqlName(cTab)+" "+cTab+" ON "+cTab+"."+cTab+"_FILIAL = VDL.VDL_FILIAL AND "+cTab+"."+cTab+"_CODOPO = VDL.VDL_CODOPO AND "+cTab+".D_E_L_E_T_ = ' ' "
			cQuery += "   JOIN "+RetSqlName(cHis)+" "+cHis+" ON "+cHis+"."+cHis+"_FILIAL = VDL.VDL_FILIAL AND "+cHis+"."+cHis+"_CODINT = "+cTab+"."+cTab+"_CODINT AND "+cHis+".D_E_L_E_T_ = ' ' "
			cQuery += "   JOIN "+RetSqlName("VDK")+" VDK ON VDK.VDK_FILIAL = '"+xFilial("VDK")+"' AND VDK.VDK_CODFAS = "+cHis+"."+cHis+"_CODFAS AND VDK.VDK_TIPFAS = '3' AND VDK.D_E_L_E_T_ = ' ' "
			cQuery += "   JOIN "+RetSqlName("VQT")+" VQT ON VQT.VQT_FILIAL = '"+xFilial("VQT")+"' AND VQT.VQT_CODIGO = VDK.VDK_CODETA AND VQT.VQT_TIPETA = '3' AND VQT.D_E_L_E_T_ = ' ' "
			cQuery += OC0600171_MotaWHEREdoFunil( aParametros , cTab , cHis ) // Filtros do SQL do Funil
			cQuery += "   GROUP BY VQT.VQT_SEQUEN , VQT.VQT_CODIGO , VQT.VQT_DESCRI , "+cTab+".R_E_C_N_O_ ) TB_UNICOS_ETAPA "
			cQuery += "GROUP BY VQT_SEQUEN , VQT_CODIGO , VQT_DESCRI "
			cQuery += "ORDER BY VQT_SEQUEN , VQT_CODIGO "
			//
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
			Do While !( cQAlias )->( Eof() )
				nPosAux := aScan(aAux,{|x| x[1] == ( cQAlias )->( VQT_CODIGO ) })
				If nPosAux == 0
					aAdd(aAux,{ ( cQAlias )->( VQT_CODIGO ) , ( cQAlias )->( VQT_DESCRI ) , 0 })
					nPosAux := len(aAux)
				EndIf
				aAux[nPosAux,3] += ( cQAlias )->( QTD )
				( cQAlias )->( DbSkip() )
			EndDo
			( cQAlias )->( dbCloseArea() )

		Next

	EndIf

Next

cFilAnt := cBkpFilAnt

For nCntFor := 1 to len(aAux)
	oChart:addSerie( aAux[nCntFor,1]+" - "+aAux[nCntFor,2] , aAux[nCntFor,3] )
	aAdd(aSerie, aAux[nCntFor,1] )
Next

If lRefresh
	oChart:Activate()
EndIf

Return

/*/{Protheus.doc} OC0600161_ClickGrafico
Click no Grafico do Funil

@author Andre
@since 08/06/2018
@version undefined

@type function
/*/
Static Function OC0600161_ClickGrafico( nSerie , aParametros , aFilSelect )
Local cQuery  := ""
Local cQAlias := "SQLFUNIL"
Local cCod    := ""
Local cLoj    := ""
Local cNom    := ""
Local nTab    := 0
Local cTab    := ""
Local cHis    := ""
Local nCntFor := 0
Local aAnalGraf   := {}
Local cBkpFilAnt  := cFilAnt
Local nAux        := 0
Local cVQT_SEQUEN := ""
Local cQuebra     := ""
Local nPosEtapa   := 0
Local aFasEtapa   := {}

If nSerie <> 0

	nSerie := val(right(str(nSerie),1))

	For nCntFor := 1 to len(aFilSelect)

		If aFilSelect[nCntFor,1]

			cFilAnt := aFilSelect[nCntFor,2]

			cVQT_SEQUEN := FM_SQL("SELECT VQT_SEQUEN FROM "+RetSqlName("VQT")+" WHERE VQT_FILIAL='"+xFilial("VQT")+"' AND VQT_CODIGO='"+aSerie[nSerie]+"' AND VQT_TIPETA='3' AND D_E_L_E_T_=' ' ")
			nPosEtapa := 1
			aFasEtapa := {}
			cQuery := " SELECT VQT.VQT_SEQUEN , VQT.VQT_CODIGO , VDK.VDK_CODFAS "
			cQuery += "   FROM "+RetSqlName("VDK")+" VDK "
			cQuery += "   JOIN "+RetSqlName("VQT")+" VQT ON VQT.VQT_FILIAL = '"+xFilial("VQT")+"' AND VQT.VQT_CODIGO = VDK.VDK_CODETA AND VQT.VQT_TIPETA = '3' AND VQT.VQT_SEQUEN>='"+cVQT_SEQUEN+"' AND VQT.D_E_L_E_T_ = ' ' "
			cQuery += "  WHERE VDK.VDK_FILIAL = '"+xFilial("VDK")+"'"
			cQuery += "    AND VDK.VDK_TIPFAS = '3' "
			cQuery += "    AND VDK.D_E_L_E_T_ = ' ' "
			cQuery += "  ORDER BY VQT.VQT_SEQUEN , VQT.VQT_CODIGO "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
			Do While !( cQAlias )->( Eof() )
				nAux := aScan(aFasEtapa,{|x| x[1] + x[2] == ( cQAlias )->( VQT_SEQUEN ) + ( cQAlias )->( VQT_CODIGO ) })
				If nAux == 0
					aAdd(aFasEtapa,{ ( cQAlias )->( VQT_SEQUEN ) , ( cQAlias )->( VQT_CODIGO ) , "'"+( cQAlias )->( VDK_CODFAS )+"'" })
					If ( cQAlias )->( VQT_SEQUEN ) == cVQT_SEQUEN
						nPosEtapa := len(aFasEtapa)
					EndIf
				Else
					aFasEtapa[nAux,3] += ",'"+( cQAlias )->( VDK_CODFAS )+"'"
				EndIf
				( cQAlias )->( DbSkip() )
			EndDo
			( cQAlias )->( dbCloseArea() )

			//
				For nTab := 1 to 2

					If nTab == 1
						If aParametros[11] == "2"
							Loop // Pular Peças se escolheu Serviços
						EndIf
						cTab := "VDI" // Pecas
						cHis := "VED" // Historico
					Else
						If aParametros[11] == "1"
							Loop // Pular Serviços se escolheu Peças
						EndIf
						cTab := "VDJ" // Servicos 
						cHis := "VEE" // Historico
					EndIf

					cQuery := " SELECT DISTINCT "
					cQuery += "        VDL.VDL_CODOPO , "
					cQuery += "        "+cTab+"."+cTab+"_CODINT AS CODINT , "
					cQuery += "        "+cTab+"."+cTab+"_DATINT AS DATINT , "
					cQuery += "        VDL.VDL_CODCLI , VDL.VDL_LOJCLI , SA1.A1_NOME , "
					cQuery += "        VDL.VDL_CDPROS , VDL.VDL_LJPROS , SUS.US_NOME , "
					cQuery += "        "+cTab+"."+cTab+"_CODFAS AS CODFAS , VDK.VDK_DESFAS , "
					If cTab == "VDI"
						cQuery += "    VDI.VDI_DESITE AS INTERESSE"
					ElseIf cTab == "VDJ"
						cQuery += "    VDJ.VDJ_DESSER AS INTERESSE"
					EndIf
					cQuery += "   FROM "+RetSqlName("VDL")+" VDL "
					cQuery += "   JOIN "+RetSqlName(cTab)+" "+cTab+" ON "+cTab+"."+cTab+"_FILIAL = VDL.VDL_FILIAL AND "+cTab+"."+cTab+"_CODOPO = VDL.VDL_CODOPO AND "+cTab+".D_E_L_E_T_ = ' ' "
					cQuery += "   JOIN "+RetSqlName(cHis)+" "+cHis+" ON "+cHis+"."+cHis+"_FILIAL = VDL.VDL_FILIAL AND "+cHis+"."+cHis+"_CODINT = "+cTab+"."+cTab+"_CODINT AND "+cHis+".D_E_L_E_T_ = ' ' "
					cQuery += "   JOIN "+RetSqlName("VDK")+" VDK ON VDK.VDK_FILIAL = '"+xFilial("VDK")+"' AND VDK.VDK_CODFAS = "+cTab+"."+cTab+"_CODFAS AND VDK.VDK_TIPFAS = '3' AND VDK.VDK_CODETA = '"+aSerie[nSerie]+"' AND VDK.D_E_L_E_T_ = ' ' "
					cQuery += "   LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VDL.VDL_CODCLI AND SA1.A1_LOJA=VDL.VDL_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
					cQuery += "   LEFT JOIN "+RetSqlName("SUS")+" SUS ON ( SUS.US_FILIAL='"+xFilial("SUS")+"' AND SUS.US_COD=VDL.VDL_CDPROS AND SUS.US_LOJA=VDL.VDL_LJPROS AND SUS.D_E_L_E_T_=' ' ) "
					cQuery += OC0600171_MotaWHEREdoFunil( aParametros , cTab , cHis ) // Filtros do SQL do Funil
					cQuery += "    AND "+cHis+"."+cHis+"_CODFAS IN ("+aFasEtapa[nPosEtapa,3]+")"
					cQuery += "  ORDER BY VDL.VDL_CODOPO , "+cTab+"."+cTab+"_CODINT "
					//
					cQuebra := "INICIAL"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
					Do While !( cQAlias )->( Eof() )
						If cQuebra == ( cQAlias )->( VDL_CODOPO ) + ( cQAlias )->( CODINT )
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
						cCod := ""
						cLoj := ""
						cNom := ""
						If !Empty( ( cQAlias )->( VDL_CODCLI ) )
							cTip := " (1)"
							cCod := ( cQAlias )->( VDL_CODCLI )
							cLoj := ( cQAlias )->( VDL_LOJCLI )
							cNom := ( cQAlias )->( A1_NOME )
						Else
							cTip := " (2)"
							cCod := ( cQAlias )->( VDL_CDPROS )
							cLoj := ( cQAlias )->( VDL_LJPROS )
							cNom := ( cQAlias )->( US_NOME )
						EndIf

						nAux := aScan(aFasEtapa,{|x| ( cQAlias )->( CODFAS ) $ x[3] }) // Verifica Posicao da Etapa para validar a sequencia da Etapa

						aAdd(aAnalGraf,{stod( ( cQAlias )->( DATINT ) ) ,;
										cCod + "-" + cLoj +" "+ Alltrim(cNom) + cTip ,;
										( cQAlias )->( CODFAS ) +" "+ ( cQAlias )->( VDK_DESFAS ) ,;
										IIf(nTab==1,STR0049,STR0050)+" "+( cQAlias )->( INTERESSE ) ,; 
										( cQAlias )->( VDL_CODOPO ) ,;
										( cQAlias )->( CODINT ) ,;
										cFilAnt ,;
										IIf(( aFasEtapa[nAux,1] <> aFasEtapa[nPosEtapa,1] ),"1","0") })

						cQuebra := ( cQAlias )->( VDL_CODOPO ) + ( cQAlias )->( CODINT )
						( cQAlias )->( DbSkip() )
					EndDo
					( cQAlias )->( dbCloseArea() )

				Next
			//
		
		EndIf

	Next

	aSort(aAnalGraf,,,{|x,y| x[8]+dtos(x[1])+x[5]+x[6] < y[8]+dtos(y[1])+y[5]+y[6] }) // Ordenar Interesses

	cFilAnt := cBkpFilAnt

	OC0600181_AnaliticoFunil( aAnalGraf , aSerie[nSerie] )

	cFilAnt := cBkpFilAnt

EndIf
Return

/*/{Protheus.doc} OC0600171_MotaWHEREdoFunil
Monta WHERE dos Filtros do SQL do Funil

@author Andre
@since 08/06/2018
@version undefined

@type function
/*/
Static Function OC0600171_MotaWHEREdoFunil( aParametros , cTab , cHis )
Local cRet := ""
cRet += "  WHERE VDL_FILIAL = '"+xFilial("VDL")+"'"
If !Empty(aParametros[05]) // Codigo Cliente
	cRet += " AND VDL.VDL_CODCLI = '"+aParametros[05]+"'"
EndIf
If !Empty(aParametros[06]) // Loja Cliente
	cRet += " AND VDL.VDL_LOJCLI = '"+aParametros[06]+"'"
EndIf
If !Empty(aParametros[07]) // Codigo Prospect
	cRet += " AND VDL.VDL_CDPROS = '"+aParametros[07]+"'"
EndIf
If !Empty(aParametros[08]) // Loja Prospect
	cRet += " AND VDL.VDL_LJPROS = '"+aParametros[08]+"'"
EndIf
If !Empty(aParametros[01]) // Data Inicial de Interesse
	cRet += " AND "+cTab+"."+cTab+"_DATINT >= '"+dtos(aParametros[01])+"'"
EndIf
If !Empty(aParametros[02]) // Data Final de Interesse
	cRet += " AND "+cTab+"."+cTab+"_DATINT <= '"+dtos(aParametros[02])+"'"
EndIf
If !Empty(aParametros[09]) // Campanha
	cRet += " AND "+cTab+"."+cTab+"_CAMPOP = '"+aParametros[09]+"'"
EndIf
If !Empty(aParametros[03]) // Data de Corte de Historico
	cRet += " AND "+cHis+"."+cHis+"_DATHIS <= '"+dtos(aParametros[03])+"'"
EndIf
If !Empty(aParametros[04]) // Vendedor
	cRet += " AND "+cHis+"."+cHis+"_CODVEN = '"+aParametros[04]+"'"
EndIf
cRet += " AND VDL.D_E_L_E_T_ = ' '"
Return cRet

/*/{Protheus.doc} OC0600181_AnaliticoFunil
Lista Interesses da Etapa selecionada no Funil

@author Andre
@since 08/06/2018
@version undefined

@type function
/*/
Static Function OC0600181_AnaliticoFunil( aAnalGraf , cCodEtapa )
Local oSize       := FwDefSize():New(.t.) // COM enchoicebar
Private cCadastro := ""
Private oAtuEtapa := LoadBitmap( GetResources() , "BR_BRANCO" )
Private oPrxEtapa := LoadBitmap( GetResources() , "BR_VERDE" )

oSize:lLateral := .F. // Cálculo vertical
oSize:AddObject("ALL", 0 , 0 , .T., .T.)
oSize:Process()
//
VQT->(DbSetOrder(1))
VQT->(DbSeek(xFilial("VQT")+cCodEtapa))
cCadastro := STR0001+" - "+STR0064+" "+cCodEtapa+" - "+VQT->VQT_DESCRI // Interesses Peças/Serviços Oficina / Etapa:
//
DEFINE MSDIALOG oDlgAnalit TITLE cCadastro ;
							FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] PIXEL
	oLbAnalit := TWBrowse():New(oSize:GetDimension("ALL","LININI"),;
								oSize:GetDimension("ALL","COLINI"),;
								oSize:GetDimension("ALL","COLEND")-oSize:GetDimension("ALL","COLINI"),;
								oSize:GetDimension("ALL","LINEND")-oSize:GetDimension("ALL","LININI")-15,;
								,,, oDlgAnalit,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
	oLbAnalit:addColumn( TCColumn():New( "", { || IIf(oLbAnalit:aArray[ oLbAnalit:nAt , 8 ]=="1",oPrxEtapa,oAtuEtapa) } ,,,,"LEFT" ,12,.T.,.F.,,,,.F.,) )
	oLbAnalit:addColumn( TCColumn():New( STR0056 , { || oLbAnalit:aArray[ oLbAnalit:nAt , 7 ] },,,,"LEFT" ,80,.F.,.F.,,,,.F.,) )
	oLbAnalit:addColumn( TCColumn():New( STR0018 , { || Transform( oLbAnalit:aArray[ oLbAnalit:nAt , 1 ] ,"@D") },,,,"LEFT" ,45,.F.,.F.,,,,.F.,) )
	oLbAnalit:addColumn( TCColumn():New( STR0003+" (1)"+" / "+STR0010+" (2)" , { || oLbAnalit:aArray[ oLbAnalit:nAt , 2 ] },,,,"LEFT" ,150,.F.,.F.,,,,.F.,) )
	oLbAnalit:addColumn( TCColumn():New( STR0065 , { || oLbAnalit:aArray[ oLbAnalit:nAt , 3 ] },,,,"LEFT" ,150,.F.,.F.,,,,.F.,) )
	oLbAnalit:addColumn( TCColumn():New( STR0045 , { || oLbAnalit:aArray[ oLbAnalit:nAt , 4 ] },,,,"LEFT" ,150,.F.,.F.,,,,.F.,) )
	oLbAnalit:bLDblClick := { || OC0600121_VisualizaDetalheInteresse( aAnalGraf[oLbAnalit:nAt,5] , aAnalGraf[oLbAnalit:nAt,6] , aAnalGraf[oLbAnalit:nAt,07] ) }
	oLbAnalit:SetArray(aAnalGraf)
	oLbAnalit:Refresh()

	@ oSize:GetDimension("ALL","LINEND")-10,005 BITMAP oxBran RESOURCE "BR_BRANCO" OF oDlgAnalit NOBORDER SIZE 10,10 when .f. PIXEL
	@ oSize:GetDimension("ALL","LINEND")-10,015 SAY (STR0064+" "+cCodEtapa+" - "+VQT->VQT_DESCRI) SIZE 200,8 OF oDlgAnalit PIXEL COLOR CLR_BLACK // Etapa:

	@ oSize:GetDimension("ALL","LINEND")-10,205 BITMAP oxCinz RESOURCE "BR_VERDE" OF oDlgAnalit NOBORDER SIZE 10,10 when .f. PIXEL
	@ oSize:GetDimension("ALL","LINEND")-10,215 SAY (STR0066) SIZE 200,8 OF oDlgAnalit PIXEL COLOR CLR_BLACK // Passaram para Etapas posteriores

ACTIVATE DIALOG oDlgAnalit ON INIT EnchoiceBar(oDlgAnalit,{|| oDlgAnalit:End() },{|| oDlgAnalit:End() },,)
//
Return

/*/{Protheus.doc} OC0600191_F7
Habilita / Desabilita tecla F7 ( Funil dos Interesses de Pecas/Servicos Oficina )

@author Andre Luis Almeida
@since 23/01/2019
/*/
Static Function OC0600191_F7( lHabilita )
If !IsInCallStack('OFIA120') // NAO for Oportunidades Agrupadas
	If lHabilita
		SetKey(VK_F7,{|| OC0600141_FUNIL() })
	Else
		SetKey(VK_F7, Nil )
	EndIf
EndIf
Return