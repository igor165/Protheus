// …ÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕª
// ∫ Versao ∫ 22     ∫
// »ÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕº

#Include "Protheus.ch"
#Include "VEICC680.CH"
#INCLUDE "FWMVCDEF.CH"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥VEICC680≥ Autor ≥ Andre Luis Almeida       ≥ Data ≥ 05/10/99 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Consulta Oportunidades/Interesses                           ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VEICC680(cPAREmp,aPAREmp,aPARFil)
Local aObjects    := {} , aInfo := {}, aPos := {}
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local oFont1      := TFont():New(,10,20,,.F.,,,,,,,,,,,)
Local nCont       := 0
Local nLinha      := 0
Local lDClik      := .f.
Local aTpGraf     := {"1="+STR0026,"2="+"%"}
Local lCEVOUT     := ( VAI->(FieldPos("VAI_CEVOUT")) <> 0 )
Local aNewBot     := {}
Local aBotAux     := {}
Local aFilAtu     := FWArrFilAtu()
Private aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Private aTpTotal  := {"1="+STR0013,"2="+STR0017+" / "+STR0018,"3="+STR0006,"4="+STR0010,"5="+STR0016,"6="+STR0014,"7="+STR0021,"8="+STR0040,"9="+STR0042,"0="+STR0061}
Private lMarcar   := .f.
Private lMarMot   := .f.
Private lMarFin   := .f.
Private lMarFas   := .f.
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
Private M->VDM_CAMPOP := space(TamSX3("VDM_CAMPOP")[1]) // VX5
Private cCodFas       := space(TamSX3("VDM_CODFAS")[1])
Private cCodVen       := space(TamSX3("VDM_CODVEN")[1])
Private cTipCon       := " "
Private aTipCon       := X3CBOXAVET("VDM_TIPCON","1")
Private M->VDM_TIPMID := space(TamSX3("VDM_TIPMID")[1]) // VX5
Private cCodMar       := space(TamSX3("VDM_CODMAR")[1])
Private cGruMod       := space(TamSX3("VV2_GRUMOD")[1])
Private cModVei       := space(TamSX3("VDM_MODVEI")[1])
Private cCorVei       := space(TamSX3("VDM_CORVEI")[1])
Private cIBGE         := space(TamSX3("A1_IBGE")[1])
Private cMunCli       := space(TamSX3("A1_MUN")[1])
Private cUFCli        := space(TamSX3("A1_EST")[1])
Private M->VDM_FASFIN := space(TamSX3("VDM_FASFIN")[1]) // VX5
Private cCCliBc       := space(TamSX3("VDM_CCLIBC")[1])
Private cLCliBc       := space(TamSX3("VDM_LCLIBC")[1])
Private cCodBco       := space(TamSX3("VDM_CODBCO")[1])
Private M->VDM_DECVDA := space(TamSX3("VDM_DECVDA")[1]) // VX5
Private lVDK_CODETA   := ( VDK->(FieldPos("VDK_CODETA")) > 0 )
Private cCodEta       := IIf(lVDK_CODETA,space(TamSX3("VDK_CODETA")[1]),"")
Private aCliPros      := {"","1="+STR0006,"2="+STR0054} // Cliente / Prospect
Private cCliPros      := "1"
Private cMotivo       := "000011" // Tipo de motivo - utilizado na consulta de Motivos de Cancelamentos
Private cMotCan       := space(TamSX3("VDM_MOTCAN")[1])
Private cTpTotal      := "1"
Private cTpGraf       := "1"
Private nMaxGraf      := 99
Private aDadosGraf    := {}
Private cTitGraf      := ""
Private cTpVeic       := space(TamSX3("VV2_TIPVEI")[1])
Private dDatRef       := dDataBase
//
Private aFiltros := {cCodCli,cLojCli,cNomCli,dDtIIni,dDtIFin,dDtLIni,dDtLFin,cNivImp,M->VDL_PERFIL,M->VDM_CAMPOP,cCodFas,cCodVen,cTipCon,M->VDM_TIPMID,cCodMar,cModVei,cCorVei,cMotCan,cTpTotal,cTpGraf,nMaxGraf,M->VDM_FASFIN,cGruMod,cCdPros,cLjPros,cCliPros,cTpVeic,dDatRef,cCodEta,cIBGE,cMunCli,cUFCli}
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
FS_SLVFILT(2)
//
DbSelectArea("VAI")
DbSetOrder(4)
DbSeek(xFilial("VAI")+__cUserID)
If lCEVOUT .and. VAI->VAI_CEVOUT<>"1"
	cCodVen := VAI->VAI_CODVEN
EndIf
aEmpr := aPAREmp
If !Empty(cPAREmp)
	cEmpr := " - "+STR0005+": " // Consolidado
	aEmpr := FS_FILIAIS() // Levantamento das Filiais
	If len(aEmpr) == 0
		MsgAlert(STR0004,STR0003) // Nao existem dados para esta Consulta ! / Atencao
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
If ( ExistBlock("VC680BOT") )
	aBotAux := ExecBlock("VC680BOT",.F.,.F.)
	If ( ValType(aBotAux) == "A" )
		aNewBot := aClone(aBotAux)
	EndIf
EndIf
AADD(aNewBot,{"IMPRESSAO",{|| FS_IMPRIMIR(1) } , STR0063 } ) // Impressao Interesses
AADD(aNewBot,{"IMPRESSAO",{|| FS_IMPRIMIR(2) } , STR0064 } ) // Impressao Resumo
//
FS_FILTRAR(0)
//
VCC680011_F7(.t.)
//
DEFINE MSDIALOG oIntVCC680 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Oportunidade de Negocios
oIntVCC680:lEscClose := .F.
//
oTPanelFiltr := TPanel():New(aPos[1,1],aPos[1,2],"",oIntVCC680,NIL,.T.,.F.,NIL,NIL,180,aPos[1,3]-aPos[1,1],.T.,.F.)
oScrollFiltr := TScrollBox():New( oTPanelFiltr , 01 , 01 , 01 ,01 , .t. , , .t. )
oScrollFiltr:Align := CONTROL_ALIGN_ALLCLIENT

oTPanelInter := TPanel():New(aPos[1,1],aPos[1,2]+182,"",oIntVCC680,NIL,.T.,.F.,NIL,NIL,aPos[1,4]-aPos[1,2]-182,aPos[1,3]-aPos[1,1],.T.,.F.)

//
If !Empty(cCodCli+cLojCli)
	cCliPros := "1" // Cliente
	FS_VCC680C("CL",.f.)
ElseIf !Empty(cCdPros+cLjPros)
	cCliPros := "2" // Prospect
	FS_VCC680C("PR",.f.)
EndIf
nLinha  := 07
@ nLinha,065 SAY STR0071 SIZE 40,10 FONT oFont1 OF oScrollFiltr PIXEL COLOR CLR_BLUE // FILTROS
nLinha  += 20
@ nLinha,005 MSCOMBOBOX oCliPros VAR cCliPros ITEMS aCliPros ON CHANGE FS_CLIPROS() SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,060 MSGET oCodCli VAR cCodCli SIZE 035,08 OF oScrollFiltr VALID ( FS_VCC680C("CL",.t.) .and. FS_SLVFILT(1) ) F3 "SA1" PIXEL COLOR CLR_BLUE
@ nLinha,095 MSGET oLojCli VAR cLojCli SIZE 015,08 OF oScrollFiltr VALID ( FS_VCC680C("CL",.t.) .and. FS_SLVFILT(1) ) PIXEL COLOR CLR_BLUE
@ nLinha,060 MSGET oCdPros VAR cCdPros SIZE 035,08 OF oScrollFiltr VALID ( FS_VCC680C("PR",.t.) .and. FS_SLVFILT(1) ) F3 "SUS" PIXEL COLOR CLR_BLUE
@ nLinha,095 MSGET oLjPros VAR cLjPros SIZE 015,08 OF oScrollFiltr VALID ( FS_VCC680C("PR",.t.) .and. FS_SLVFILT(1) ) PIXEL COLOR CLR_BLUE
@ nLinha,060 MSGET oTodCli VAR STR0055 PICTURE "@!" SIZE 100,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE WHEN .f.
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
@ nLinha,005 SAY STR0007 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Dt.Interesse
@ nLinha,060 MSGET oDtIIni VAR dDtIIni VALID ( FS_SLVFILT(1) ) SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,108 SAY STR0009  SIZE 10,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // a
@ nLinha,114 MSGET oDtIFin VAR dDtIFin VALID ( ( dDtIIni <= dDtIFin ) .and. FS_SLVFILT(1) ) SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0008 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Dt.Limite
@ nLinha,060 MSGET oDtLIni VAR dDtLIni VALID ( FS_SLVFILT(1) ) SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,108 SAY STR0009  SIZE 10,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // a
@ nLinha,114 MSGET oDtLFin VAR dDtLFin VALID ( ( dDtLIni <= dDtLFin ) .and. FS_SLVFILT(1) ) SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0010 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Nivel Importancia
@ nLinha,060 MSGET oNivImp VAR cNivImp VALID ( FS_SLVFILT(1) ) SIZE 15,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,095 SAY STR0011 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Perfil
@ nLinha,114 MSGET oPerfil VAR M->VDL_PERFIL VALID ( ( vazio() .or. ExistCpo("VX5","025"+M->VDL_PERFIL) ) .and. FS_SLVFILT(1) ) F3 "VX5" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0012 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Campanha
@ nLinha,060 MSGET oCampOp VAR M->VDM_CAMPOP VALID ( ( vazio() .or. ExistCpo("VX5","026"+M->VDM_CAMPOP) ) .and. FS_SLVFILT(1) ) F3 "VX5" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0058 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Decis„o Venda
@ nLinha,060 MSGET oCampDV VAR M->VDM_DECVDA VALID ( ( vazio() .or. ExistCpo("VX5","044"+M->VDM_DECVDA) ) .and. FS_SLVFILT(1) ) F3 "VX5" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0062 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Etapa Funil
@ nLinha,060 MSGET oCodEta VAR cCodEta VALID ( FS_SLVFILT(1) ) F3 "VQT" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE WHEN lVDK_CODETA

nLinha += 12
@ nLinha,005 SAY STR0013 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Fase Oportunidade
@ nLinha,060 MSGET oCodFas VAR cCodFas VALID ( ( vazio() .or. ExistCpo("VDK",cCodFas) ) .and. FS_SLVFILT(1) .and. FS_VLCHEKBOX(3) ) F3 "VDKFAS" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,110 CHECKBOX oMarFas VAR lMarFas PROMPT STR0051 OF oScrollFiltr ON CLICK FS_MARKA(3) SIZE 50,08 PIXEL
nLinha += 12
@ nLinha,005 SAY STR0014 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Vendedor
@ nLinha,060 MSGET oCodVen VAR cCodVen VALID ( ( vazio() .or. ExistCpo("SA3",cCodVen) ) .and. FS_SLVFILT(1) ) F3 "SA3" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0015 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Tipo de Contato
@ nLinha,060 MSCOMBOBOX oTipCon VAR cTipCon ITEMS aTipCon VALID ( FS_SLVFILT(1) ) SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0016 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Tipo de Midia
@ nLinha,060 MSGET oTipMid VAR M->VDM_TIPMID VALID ( ( vazio() .or. ExistCpo("VX5","027"+M->VDM_TIPMID) ) .and. FS_SLVFILT(1) ) F3 "VX5" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0040 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Fase Financiamento
@ nLinha,060 MSGET oFasFin VAR M->VDM_FASFIN VALID ( ( vazio() .or. ExistCpo("VX5","031"+M->VDM_FASFIN) ) .and. FS_SLVFILT(1) .and. FS_VLCHEKBOX(2) ) F3 "VX5" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,110 CHECKBOX oMarFin VAR lMarFin PROMPT STR0041 OF oScrollFiltr ON CLICK FS_MARKA(2) SIZE 50,08 PIXEL
nLinha += 12
@ nLinha,005 SAY STR0057 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Cliente Banco
@ nLinha,060 MSGET oCCliBc VAR cCCliBc VALID ( ( vazio() .or. ExistCpo("SA1",cCCliBc+Alltrim(cLCliBc)) ) .and. FS_SLVFILT(1) ) F3 "SA1" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,107 MSGET oLCliBc VAR cLCliBc VALID ( ( vazio() .or. ExistCpo("SA1",cCCliBc+cLCliBc) ) .and. FS_SLVFILT(1) ) SIZE 20,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0020 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Banco
@ nLinha,060 MSGET oCodBco VAR cCodBco VALID ( ( vazio() .or. ExistCpo("SA6",cCodBco) ) .and. FS_SLVFILT(1) ) F3 "A62" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0021 SIZE 100,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Motivo Cancelamento
@ nLinha,060 MSGET oMotCan VAR cMotCan VALID ( ( vazio() .or. FG_SEEK("VS0","'000011'+cMotCan",1,.f.) ) .and. FS_SLVFILT(1) .and. FS_VLCHEKBOX(1)) F3 "VS0" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,110 CHECKBOX oMarMot VAR lMarMot PROMPT STR0037 OF oScrollFiltr ON CLICK FS_MARKA(1) SIZE 50,08 PIXEL
nLinha += 12
@ nLinha,005 SAY STR0017 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Marca
@ nLinha,060 MSGET oCodMar VAR cCodMar VALID ( ( vazio() .or. FG_SEEK("VE1","cCodMar",1,.f.) ) .and. FS_SLVFILT(1) ) F3 "VE1" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0052 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Grupo
@ nLinha,060 MSGET oGruMod VAR cGruMod VALID ( FS_SLVFILT(1) ) F3 "VVR" SIZE 40,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0018 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Modelo
@ nLinha,060 MSGET oModVei VAR cModVei VALID ( FS_SLVFILT(1) ) F3 "VV2" SIZE 100,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0056 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Tipo de Veiculo
@ nLinha,060 MSGET oTpVeic VAR cTpVeic VALID ( FS_SLVFILT(1) ) F3 "VV8" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0019 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Cor
@ nLinha,060 MSGET oCorVei VAR cCorVei VALID ( FS_SLVFILT(1) ) F3 "VVC" SIZE 40,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
@ nLinha,005 SAY STR0069 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Municipio
@ nLinha,060 MSGET oIBGE VAR cIBGE VALID ( FS_IBGE(1) .and. FS_SLVFILT(1) ) F3 "AM1" SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
@ nLinha,120 SAY STR0070 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // UF
@ nLinha,135 MSGET oUFCli VAR cUFCli VALID ( FS_IBGE(2) .and. FS_SLVFILT(1) ) F3 "12" SIZE 25,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE WHEN Empty(cIBGE)
nLinha += 12
@ nLinha,060 MSGET oMunCli VAR cMunCli SIZE 100,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE WHEN .f.
nLinha += 12
@ nLinha,005 SAY STR0059 SIZE 50,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE // Data Referencia
@ nLinha,060 MSGET oDatRef VAR dDatRef VALID ( naovazio() .and. FS_SLVFILT(1) ) SIZE 45,08 OF oScrollFiltr PIXEL COLOR CLR_BLUE
nLinha += 12
nLinha += 12
@ nLinha,40 BUTTON oFiltrar PROMPT UPPER(STR0022) OF oScrollFiltr SIZE 30,10 PIXEL ACTION Processa( {|| FS_FILTRAR(1) } ) // Filtrar
@ nLinha,90 BUTTON oEmpr    PROMPT UPPER(STR0023) OF oScrollFiltr SIZE 30,10 PIXEL ACTION (lDClik:=.t.,oIntVCC680:End()) // Filiais
nLinha += 12
@ nLinha,001 SAY "." SIZE 00,00 OF oScrollFiltr PIXEL COLOR CLR_WHITE // somente para deixar espaÁo embaixo dos botoes: [FILTRAR] [FILIAIS]

@ 001,001 LISTBOX oLbInteres FIELDS HEADER 	STR0006 ,; // Cliente
											STR0025 ,; // Nome
											STR0024 ,; // Telefone
											STR0008 ,; // Dt.Limite
											STR0013 ,; // Fase Oportunidade
											STR0017 ,; // Marca
											STR0052 ,; // Grupo
											STR0018 ,; // Modelo
											STR0019 ,; // Cor
											STR0026 ; // Qtde
											COLSIZES 35,100,55,40,120,20,25,80,50,40 SIZE 001,001 OF oTPanelInter ON DBLCLICK VCC680VER(aInteres[oLbInteres:nAt,11],aInteres[oLbInteres:nAt,12],aInteres[oLbInteres:nAt,15]) PIXEL
oLbInteres:SetArray(aInteres)
oLbInteres:bLine := { || { aInteres[oLbInteres:nAt,01] ,;
aInteres[oLbInteres:nAt,02] ,;
aInteres[oLbInteres:nAt,03] ,;
Transform(aInteres[oLbInteres:nAt,04],"@D") ,;
aInteres[oLbInteres:nAt,05] ,;
aInteres[oLbInteres:nAt,06] ,;
aInteres[oLbInteres:nAt,07] ,;
aInteres[oLbInteres:nAt,08] ,;
aInteres[oLbInteres:nAt,09] ,;
FG_AlinVlrs(Transform(aInteres[oLbInteres:nAt,10],"@E 999,999")) }}
oLbInteres:Align := CONTROL_ALIGN_ALLCLIENT
oLbInteres:bHeaderClick := {|oObj,nCol| FS_ORDVET(nCol) , }
//
@ aPos[2,1]+00,aPos[2,2] MSCOMBOBOX oTpTotal VAR cTpTotal ITEMS aTpTotal VALID ( FS_SLVFILT(1) .and. FS_TOTAIS(0) ) SIZE 181,08 OF oIntVCC680 PIXEL COLOR CLR_BLUE
@ aPos[2,1]+12,aPos[2,2] LISTBOX oLbTotais FIELDS HEADER "",STR0026,"%" COLSIZES 117,27,25 SIZE 180,126 OF oIntVCC680 ON DBLCLICK FS_TOTAFC(oLbTotais:nAt) PIXEL // Qtde / %
oLbTotais:SetArray(aTotais)
oLbTotais:bLine := { || { aTotais[oLbTotais:nAt,01] , FG_AlinVlrs(Transform(aTotais[oLbTotais:nAt,2],"@E 999,999")) , FG_AlinVlrs(Transform((aTotais[oLbTotais:nAt,2]/aTotais[1,2])*100,"@E 999.9"))+" %" }}
oLbTotais:bHeaderClick := {|oObj,nCol| FS_TOTAIS(nCol) , }
//
@ aPos[2,1]+141,aPos[2,2]+003 SAY STR0028 SIZE 50,08 OF oIntVCC680 PIXEL COLOR CLR_BLUE // Tipo de Grafico:
@ aPos[2,1]+140,aPos[2,2]+045 MSCOMBOBOX oTpGraf VAR cTpGraf ITEMS aTpGraf VALID ( FS_SLVFILT(1) .and. FS_TOTAIS(0) ) SIZE 40,08 OF oIntVCC680 PIXEL COLOR CLR_BLUE
@ aPos[2,1]+141,aPos[2,2]+097 SAY STR0029 SIZE 70,08 OF oIntVCC680 PIXEL COLOR CLR_BLUE //Qtde maxima de colunas:
@ aPos[2,1]+140,aPos[2,2]+161 MSGET oMaxGraf VAR nMaxGraf VALID ( nMaxGraf >= 1 .and. FS_SLVFILT(1) .and. FS_TOTAIS(0) ) PICTURE "@E 99" SIZE 20,08 OF oIntVCC680 PIXEL COLOR CLR_BLUE
//
@ aPos[2,1],aPos[2,2]+182 SCROLLBOX oGrafPeq SIZE 150,(aPos[2,4]-185) OF oIntVCC680 BORDER PIXEL
//
FS_TOTAIS(0)
//
// BOTAO: VISUALIZA GRAFICO EM TELA CHEIA
@ aPos[2,1]+05,aPos[2,4]-55 BUTTON oGrafTela PROMPT UPPER(STR0053) OF oIntVCC680 SIZE 50,15 PIXEL ACTION FG_NEWGRAF(,cTitGraf+" ( "+IIf(cTpGraf=="1",STR0026,"%")+" )",aDadosGraf,.t.,IIf(cTpGraf=="1","@E 999,999,999","@E 999.9 %"))
//
ACTIVATE MSDIALOG oIntVCC680 ON INIT EnchoiceBar(oIntVCC680,{|| oIntVCC680:End() },{|| oIntVCC680:End() },,aNewBot)
//
VCC680011_F7(.f.)
//
If lDClik
	VEICC680(cEmpr,aEmpr,aFiltros)
EndIf
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_IBGE  ≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 29/03/16 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ IBGE - Municipio / UF                                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_IBGE(nTp)
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

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_SLVFILT≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 17/07/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Salvar/Voltar Filtro                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_SLVFILT(nTp)
If nTp == 1 // Salvar Filtro
	aFiltros := {cCodCli,cLojCli,cNomCli,dDtIIni,dDtIFin,dDtLIni,dDtLFin,cNivImp,M->VDL_PERFIL,M->VDM_CAMPOP,cCodFas,cCodVen,cTipCon,M->VDM_TIPMID,cCodMar,cModVei,cCorVei,cMotCan,cTpTotal,cTpGraf,nMaxGraf,M->VDM_FASFIN,cGruMod,cCdPros,cLjPros,cCliPros,cTpVeic,dDatRef,cCodEta,cIBGE,cMunCli,cUFCli}
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
	M->VDM_CAMPOP := aFiltros[10]
	cCodFas       := aFiltros[11]
	cCodVen       := aFiltros[12]
	cTipCon       := aFiltros[13]
	M->VDM_TIPMID := aFiltros[14]
	cCodMar       := aFiltros[15]
	cModVei       := aFiltros[16]
	cCorVei       := aFiltros[17]
	cMotCan       := aFiltros[18]
	cTpTotal      := aFiltros[19]
	cTpGraf       := aFiltros[20]
	nMaxGraf      := aFiltros[21]
	M->VDM_FASFIN := aFiltros[22]
	cGruMod       := aFiltros[23]
	cCdPros       := aFiltros[24]
	cLjPros       := aFiltros[25]
	cCliPros      := aFiltros[26]
	cTpVeic       := aFiltros[27]
	dDatRef       := aFiltros[28]
	cCodEta       := aFiltros[29]
	cIBGE         := aFiltros[30]
	cMunCli       := aFiltros[31]
	cUFCli        := aFiltros[32]
EndIf
Return .t.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_IMPRIMIR≥ Autor ≥ Andre Luis Almeida    ≥ Data ≥ 13/11/15 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Impressao dos Interesses Relacionados / Resumo / Historicos ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_IMPRIMIR(nTp)
Local ni      := 0
Local nj      := 0
Local aOrd    := {}
Local cDesc1  := STR0001+" - "+STR0002
Local cDesc2  := ""
Local cDesc3  := ""
Local wnrel   := "VEICC680"
Local cString := "VDL"
Local cPerg   := ""
Private aIntCab      := {}
Private aIntIte      := {}
Private titulo       := STR0002
Private nLin         := 80
Private lAbortPrint  := .F.
Private limite       := 120
Private tamanho      := "G"
Private Cabec1       := ""
Private Cabec2       := ""
Private nTipo        := 15
Private aReturn      := { STR0065, 1, STR0066, 1, 2, 1, "", 1}  //Zebrado # Administracao
Private nLastKey     := 0
Private m_pag        := 01
//
If nTp == 1 // Interesses
//
	aAdd(aIntCab,{STR0006,"C", 35,"@!"}) // Cliente
	aAdd(aIntCab,{STR0025,"C",100,"@!"}) // Nome
	aAdd(aIntCab,{STR0024,"C", 40,"@!"}) // Telefone
	aAdd(aIntCab,{STR0008,"D", 35,"@D"}) // Dt.Limite
	aAdd(aIntCab,{STR0013,"C", 70,"@!"}) // Fase Oportunidade
	aAdd(aIntCab,{STR0017,"C", 35,"@!"}) // Marca
	aAdd(aIntCab,{STR0052,"C", 35,"@!"}) // Grupo
	aAdd(aIntCab,{STR0018,"C", 50,"@!"}) // Modelo
	aAdd(aIntCab,{STR0019,"C", 40,"@!"}) // Cor
	aAdd(aIntCab,{STR0026,"N",50,"@E 999,999"}) // Qtde
	//
	For ni := 1 to len(aInteres)
		aAdd(aIntIte,{ aInteres[ni,01] , aInteres[ni,02] , aInteres[ni,03] , aInteres[ni,04] , aInteres[ni,05] , aInteres[ni,06] , aInteres[ni,07] , aInteres[ni,08] , aInteres[ni,09] , aInteres[ni,10] })
	Next
	//
	If ExistBlock("VC680IMP")
		ExecBlock("VC680IMP",.F.,.F.,{nTp})
	EndIf
	//
	FGX_VISINT( STR0001 , STR0002 , aIntCab , aIntIte , .t. ) // Oportunidade de Negocios - Interesses
//
ElseIf nTp == 2 // Resumo
//
	ni := ascan(aTpTotal,cTpTotal)
	If ni > 0
		aAdd(aIntCab,{aTpTotal[ni],"C",155,"@!"}) // Titulo
	Else
		aAdd(aIntCab,{"","C",155,"@!"})
	EndIf
	aAdd(aIntCab,{STR0026,"N",50,"@E 999,999"}) // Qtde
	aAdd(aIntCab,{"%"    ,"N",50,"@E 999.9"})   // %
	//
	For ni := 1 to len(aTotais)
		aAdd(aIntIte,{ aTotais[ni,01] , aTotais[ni,02] , (aTotais[ni,2]/aTotais[1,2])*100  })
	Next
	//
	If ExistBlock("VC680IMP")
		ExecBlock("VC680IMP",.F.,.F.,{nTp})
	EndIf
	//
	FGX_VISINT( STR0001 , STR0067 , aIntCab , aIntIte , .t. ) // Oportunidade de Negocios - Resumo
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
	@ nLin++,00 PSAY STR0038 // Historico Interesse
	nLin++
	nCol  := 0
	cImpr := ""
	For ni := 1 to len(aHeader1)
		If !(aHeader1[ni,2] $ "VDN_OBSERV")
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
			If !(aHeader1[ni,2] $ "VDN_OBSERV")
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
	nLin++
	nLin++
	If nLin > 60
		nLin  := cabec(cDesc1,cabec1,cabec2,wnrel,Tamanho,nTipo)+1
	EndIf
	@ nLin++,00 PSAY STR0039 // Historico Financiamento
	nLin++
	nCol  := 0
	cImpr := ""
	For ni := 1 to len(aHeader2)
		If !(aHeader2[ni,2] $ "VDN_OBSERV")
			If nLin > 64
				nLin  := cabec(cDesc1,cabec1,cabec2,wnrel,Tamanho,nTipo)+1
			EndIf
			If aHeader2[ni,8] == "D"
				nTam := len(Transform(dDataBase,"@D"))
			ElseIf aHeader2[ni,8] == "N"
				nTam := len(Transform(0,aHeader2[ni,3]))
			Else
				nTam := aHeader2[ni,4]
			EndIf
			nCol += nTam+1
			If nCol > 220
				nCol -= nTam+1
				@ nLin++,00 PSAY cImpr
				cImpr := ""
				nCol := 0
			Else
				cImpr += left(aHeader2[ni,1]+space(nTam),nTam)+" "
			EndIf
		EndIf
	Next
	If nCol > 0
		@ nLin++,00 PSAY cImpr
	EndIf
	//
	nCol  := 0
	cImpr := ""
	For nj := 1 to len(aCols2)
		If nLin > 62
			nLin  := cabec(cDesc1,cabec1,cabec2,wnrel,Tamanho,nTipo)+1
		EndIf
		nCol  := 0
		cImpr := ""
		For ni := 1 to len(aHeader2)
			If !(aHeader2[ni,2] $ "VDN_OBSERV")
				If aHeader2[ni,8] == "D"
					aHeader2[ni,3] := "@D"
					nTam := len(Transform(dDataBase,"@D"))
				ElseIf aHeader2[ni,8] == "N"
					nTam := len(Transform(0,aHeader2[ni,3]))
				Else
					nTam := aHeader2[ni,4]
				EndIf
				nCol += nTam+1
				If nCol > 220
					nCol -= nTam+1
					@ nLin++,00 PSAY cImpr
					cImpr := ""
					nCol := 0
				Else
					If !Empty(aHeader2[ni,3])
						cImpr += left(Transform(aCols2[nj,ni],aHeader2[ni,3])+space(nTam),nTam)+" "
					Else
						cImpr += left(aCols2[nj,ni]+space(nTam),nTam)+" "
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

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_ORDVET≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 17/07/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Ordenar VETOR                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_ORDVET(nCol)
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

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_FILTRAR≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 17/07/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Filtra Registros de Interesse                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_FILTRAR(nTp)
Local cBkpFilAnt  := cFilAnt
Local nCont       := 0
Local cQuery      := ""
Local cQAlias     := "SQLVDMVDL"
Local nRecVDL     := 0
Local nRecVDM     := 0
Local nRecVDN     := 0
Local cVDK_FIMFAS := ""
Local cVDK_DESFAS := ""
Local cVV2_GRUMOD := ""
Local cVV2_DESMOD := ""
Local cCod        := ""
Local cNom        := ""
Local cFon        := ""
Local lVDN_CODOPO := ( VDN->(FieldPos("VDN_CODOPO")) > 0 )
//
aInteres := {}
//
ProcRegua(len(aEmpr))
For nCont := 1 to Len(aEmpr)
	cFilAnt := aEmpr[nCont,1]
	IncProc(STR0030) // Levantando... 
	//
	cQuery := "SELECT VDL.R_E_C_N_O_ AS RECVDL , VDM.R_E_C_N_O_ AS RECVDM , VDN.R_E_C_N_O_ AS RECVDN , VV2.R_E_C_N_O_ AS RECVV2 , VDK.R_E_C_N_O_ AS RECVDK "
	cQuery += "FROM "+RetSqlName("VDM")+" VDM "
	cQuery += "JOIN "+RetSqlName("VDL")+" VDL ON ( VDL.VDL_FILIAL=VDM.VDM_FILIAL AND VDL.VDL_CODOPO=VDM.VDM_CODOPO AND VDL.D_E_L_E_T_=' ' ) "
	cQuery += "JOIN "+RetSqlName("VDN")+" VDN ON ( VDN.VDN_FILIAL=VDM.VDM_FILIAL AND VDN.VDN_CODINT=VDM.VDM_CODINT AND "
	If lVDN_CODOPO
		cQuery += "( VDN.VDN_CODOPO=VDM.VDM_CODOPO OR VDN.VDN_CODOPO=' ' ) AND "
	EndIf
	cQuery += "VDN.VDN_TIPHIS='1' AND VDN.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VDM.VDM_CODMAR AND VV2.VV2_MODVEI=VDM.VDM_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("VDK")+" VDK ON ( VDK.VDK_FILIAL='"+xFilial("VDK")+"' AND VDK.VDK_CODFAS=VDN.VDN_CODFAS AND VDK.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VDM.VDM_FILIAL='"+xFilial("VDM")+"' AND "
	cQuery += "VDN.VDN_DATHIS<='"+dtos(dDatRef)+"' AND "
	cQuery += "VDM.VDM_DATINT>='"+dtos(dDtIIni)+"' AND VDM.VDM_DATINT<='"+dtos(dDtIFin)+"' AND "
	cQuery += "VDM.VDM_DATLIM>='"+dtos(dDtLIni)+"' AND VDM.VDM_DATLIM<='"+dtos(dDtLFin)+"' AND "
	If !Empty(cNivImp)
		cQuery += "VDL.VDL_NIVIMP='"+cNivImp+"' AND "
	EndIf
	If !Empty(M->VDL_PERFIL)
		cQuery += "VDL.VDL_PERFIL='"+M->VDL_PERFIL+"' AND "
	EndIf
	If !Empty(M->VDM_CAMPOP)
		cQuery += "VDM.VDM_CAMPOP='"+M->VDM_CAMPOP+"' AND "
	EndIf	
	If !Empty(cTipCon)
		cQuery += "VDM.VDM_TIPCON='"+cTipCon+"' AND "
	EndIf	
	If !Empty(M->VDM_TIPMID)
		cQuery += "VDM.VDM_TIPMID='"+M->VDM_TIPMID+"' AND "
	EndIf
	If !Empty(cCodMar)
		cQuery += "VDM.VDM_CODMAR='"+cCodMar+"' AND "
	EndIf
	If !Empty(cGruMod)
		cQuery += "VV2.VV2_GRUMOD='"+cGruMod+"' AND "
	EndIf	
	If !Empty(cModVei)
		cQuery += "VDM.VDM_MODVEI='"+cModVei+"' AND "
	EndIf	
	If !Empty(cTpVeic)
		cQuery += "VV2.VV2_TIPVEI='"+cTpVeic+"' AND "
	EndIf
	If !Empty(cCorVei)
		cQuery += "VDM.VDM_CORVEI='"+cCorVei+"' AND "
	EndIf
	cQuery += "VDM.D_E_L_E_T_=' ' ORDER BY VDL.R_E_C_N_O_ , VDM.R_E_C_N_O_ , VDN.R_E_C_N_O_ DESC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() )
		If nRecVDL == ( cQAlias )->( RECVDL ) .and. nRecVDM == ( cQAlias )->( RECVDM )
			( cQAlias )->( DbSkip() )
			Loop
		EndIf
		nRecVDL := ( cQAlias )->( RECVDL )
		nRecVDM := ( cQAlias )->( RECVDM )	
		nRecVDN := ( cQAlias )->( RECVDN )	
        DbSelectArea("VDN")
        DbGoTo(nRecVDN)
		//
		Do Case
			Case !Empty(cCodCli) .and. !Empty(cCdPros) // Trazer Cliente e Prospect
				If ( VDN->VDN_CODCLI<>cCodCli .or. ( !Empty(cLojCli) .and. VDN->VDN_LOJCLI<>cLojCli ) ) .and. ( VDN->VDN_CDPROS<>cCdPros .or. ( !Empty(cLjPros) .and. VDN->VDN_LJPROS<>cLjPros ) )
					( cQAlias )->( DbSkip() )
					Loop
                EndIf
			Case !Empty(cCodCli) // Trazer somente o Cliente
				If ( VDN->VDN_CODCLI<>cCodCli .or. ( !Empty(cLojCli) .and. VDN->VDN_LOJCLI<>cLojCli ) )
					( cQAlias )->( DbSkip() )
					Loop
                EndIf
			Case !Empty(cCdPros) // Trazer somente o Prospect
				If ( VDN->VDN_CDPROS<>cCdPros .or. ( !Empty(cLjPros) .and. VDN->VDN_LJPROS<>cLjPros ) )
					( cQAlias )->( DbSkip() )
					Loop
                EndIf
			Case cCliPros == "1" // Trazer todos os Clientes
				If Empty(VDN->VDN_CODCLI)
					( cQAlias )->( DbSkip() )
					Loop
                EndIf
			Case cCliPros == "2" // Trazer todos os Prospects
				If Empty(VDN->VDN_CDPROS)
					( cQAlias )->( DbSkip() )
					Loop
                EndIf
		EndCase
		//
		If !Empty(cCodFas) .and. VDN->VDN_CODFAS<>cCodFas
			( cQAlias )->( DbSkip() )
			Loop	
		EndIf
		If !Empty(cCodVen) .and. VDN->VDN_CODVEN<>cCodVen
			( cQAlias )->( DbSkip() )
			Loop	
		EndIf
		If !Empty(M->VDM_FASFIN) .and. VDN->VDN_FASFIN<>M->VDM_FASFIN
			( cQAlias )->( DbSkip() )
			Loop
		ElseIf lMarFin .and. Empty(VDN->VDN_FASFIN)
			( cQAlias )->( DbSkip() )
			Loop
		EndIf
		If !Empty(cCCliBc) .and. VDN->VDN_CCLIBC<>cCCliBc
			( cQAlias )->( DbSkip() )
			Loop
		EndIf
		If !Empty(cLCliBc) .and. VDN->VDN_LCLIBC<>cLCliBc
			( cQAlias )->( DbSkip() )
			Loop
		EndIf	
		If !Empty(cCodBco) .and. VDN->VDN_CODBCO<>cCodBco
			( cQAlias )->( DbSkip() )
			Loop
		EndIf
		If !Empty(M->VDM_DECVDA) .and. VDN->VDN_DECVDA<>M->VDM_DECVDA
			( cQAlias )->( DbSkip() )
			Loop
		EndIf
		If !Empty(cMotCan) .and. VDN->VDN_MOTCAN<>cMotCan
			( cQAlias )->( DbSkip() )
			Loop
		Elseif lMarMot .and. Empty(VDN->VDN_MOTCAN)
			( cQAlias )->( DbSkip() )
			Loop
		EndIf
		cVDK_FIMFAS := ""
		cVDK_DESFAS := ""
		If ( cQAlias )->( RECVDK ) > 0
			DbSelectArea("VDK")
			DbGoTo(( cQAlias )->( RECVDK ))
			If !Empty(cCodEta) .and. VDK->VDK_CODETA<>cCodEta
				( cQAlias )->( DbSkip() )
				Loop
			EndIf
			cVDK_FIMFAS := VDK->VDK_FIMFAS
			cVDK_DESFAS := VDK->VDK_DESFAS
		Else
			If !Empty(cCodEta)
				( cQAlias )->( DbSkip() )
				Loop
			EndIf
		EndIf
		If lMarFas .and. cVDK_FIMFAS<>'1'
			( cQAlias )->( DbSkip() )
			Loop
		EndIf
		DbSelectArea("VDL")
		DbGoTo(nRecVDL)
		DbSelectArea("VDM")
		DbGoTo(nRecVDM)
		cNome := ""
		cFone := ""
		If !Empty(VDN->VDN_CODCLI+VDN->VDN_LOJCLI)
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+VDN->VDN_CODCLI+VDN->VDN_LOJCLI))
			If !Empty(cIBGE) .and. SA1->A1_IBGE <> cIBGE
				( cQAlias )->( DbSkip() )
				Loop
			ElseIf !Empty(cUFCli) .and. SA1->A1_EST <> cUFCli
				( cQAlias )->( DbSkip() )
				Loop
			EndIf
			cCod := VDN->VDN_CODCLI+"-"+VDN->VDN_LOJCLI
			cNom := Alltrim(VDN->VDN_NOMCLI)
			cFon := SA1->A1_DDD+" "+SA1->A1_TEL
		ElseIf !Empty(VDN->VDN_CDPROS+VDN->VDN_LJPROS)
			SUS->(DbSetOrder(1))
			SUS->(DbSeek(xFilial("SUS")+VDN->VDN_CDPROS+VDN->VDN_LJPROS))
			If !Empty(cMunCli) .and. Alltrim(SUS->US_MUN) <> Alltrim(cMunCli)
				( cQAlias )->( DbSkip() )
				Loop
			ElseIf !Empty(cUFCli) .and. SUS->US_EST <> cUFCli
				( cQAlias )->( DbSkip() )
				Loop
			EndIf
			cCod := VDN->VDN_CDPROS+"-"+VDN->VDN_LJPROS
			cNom := Alltrim(VDN->VDN_NOMCLI)+" "+STR0060 // (Prospect) 
			cFon := SUS->US_DDD+" "+SUS->US_TEL
		EndIf
		cVV2_GRUMOD := ""
		cVV2_DESMOD := ""
		If ( cQAlias )->( RECVV2 ) > 0
			DbSelectArea("VV2")
			DbGoTo(( cQAlias )->( RECVV2 ))
			cVV2_GRUMOD := VV2->VV2_GRUMOD
			cVV2_DESMOD := VV2->VV2_DESMOD
  		EndIf
		aAdd(aInteres,{	cCod ,;
						cNom ,;
						cFon ,;
						VDM->VDM_DATLIM ,;
						VDN->VDN_CODFAS+"-"+cVDK_DESFAS ,;
						Alltrim(VDM->VDM_CODMAR) ,;
						Alltrim(cVV2_GRUMOD) ,;
						Alltrim(VDM->VDM_MODVEI)+"-"+cVV2_DESMOD ,;
						Alltrim(VDM->VDM_CORVEI) ,;
						VDM->VDM_QTDINT ,;
						VDM->VDM_CODOPO ,;
						VDM->VDM_CODINT ,;
						nRecVDL ,;
						nRecVDM ,;
						cFilAnt ,;
						nRecVDN })
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
Next
cFilAnt := cBkpFilAnt
//
DbSelectArea("VDM")
//
If len(aInteres) <= 0
	aAdd(aInteres,{"","","",ctod(""),"","","","","",0,"","",0,0,"",0})
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
	aInteres[oLbInteres:nAt,06] ,;
	aInteres[oLbInteres:nAt,07] ,;
	aInteres[oLbInteres:nAt,08] ,;
	aInteres[oLbInteres:nAt,09] ,;
	FG_AlinVlrs(Transform(aInteres[oLbInteres:nAt,10],"@E 999,999")) }}
	oLbInteres:Refresh()
	FS_TOTAIS(0)
EndIf
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥ FS_TOTAIS≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 17/07/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Totalizar e Grafico                                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_TOTAIS(nCol)
Local cPesq       := ""
Local nPos        := 0
Local nPosAux     := 0
Local ni          := 0
Local cStatusVV9  := ""
Default nCol      := 0
//
aDadosGraf := {}
cTitGraf   := ""
//
Do Case
	Case cTpTotal == "1" // Fase
		cTitGraf := STR0013 // Fase Oportunidade
	Case cTpTotal == "2" // Marca / Modelo
		cTitGraf := STR0017+" / "+STR0018 // Marca / Modelo
	Case cTpTotal == "3" // Cliente
		cTitGraf := STR0006 // Cliente
	Case cTpTotal == "4" // Nivel Importancia
		cTitGraf := STR0010 // Nivel Importancia
	Case cTpTotal == "5" // Tipo de Midia
		cTitGraf := STR0016 // Tipo de Midia
	Case cTpTotal == "6" // Vendedor
		cTitGraf := STR0014 // Vendedor
	Case cTpTotal == "7" // Motivo Cancelamento
		cTitGraf := STR0021 // Motivo Cancelamento
	Case cTpTotal == "8" // Fase Financiamento
		cTitGraf := STR0040 // Fase Financiamento
	Case cTpTotal == "9" // Interesses x Atendimentos
		cTitGraf := STR0042 // Interesses x Atendimentos
	Case cTpTotal == "0" // Etapas do Funil de Vendas
		cTitGraf := STR0061 // Etapas do Funil de Venda
EndCase
//
If nCol == 0
	aTotais := {}
	aAdd(aTotais,{STR0031,0,1,"1"}) // Total Geral
	aAnalit := {}
	aAdd(aAnalit,{STR0048,0,STR0031}) // Em andamento
	aAdd(aAnalit,{STR0049,0,STR0031}) // Faturado
	aAdd(aAnalit,{STR0050,0,STR0031}) // Cancelado
	For ni := 1 to len(aInteres)
		If aInteres[ni,13] > 0 .and. aInteres[ni,14] > 0 .and. aInteres[ni,16] > 0
			//
			DbSelectArea("VDL")
			DbGoTo(aInteres[ni,13])
			DbSelectArea("VDM")
			DbGoTo(aInteres[ni,14])
			DbSelectArea("VDN")
			DbGoTo(aInteres[ni,16])
			cStatusVV9 := ""
			If !Empty(VDM->VDM_FILATE+VDM->VDM_NUMATE)
				VV9->(DbSetOrder(1))
				VV9->(DbSeek(VDM->VDM_FILATE+VDM->VDM_NUMATE))
				cStatusVV9 := VV9->VV9_STATUS
			EndIf
			//
			Do Case
				Case cTpTotal == "1" // Fase
					VDK->(DbSetOrder(1))
					VDK->(DbSeek(xFilial("VDK")+VDN->VDN_CODFAS))
					cPesq := VDN->VDN_CODFAS+" - "+VDK->VDK_DESFAS
				Case cTpTotal == "2" // Marca / Modelo
					cPesq := Alltrim(VDM->VDM_CODMAR)+" - "+Alltrim(VDM->VDM_MODVEI)
				Case cTpTotal == "3" // Cliente            
					If !Empty(VDN->VDN_CODCLI+VDN->VDN_LOJCLI)
						cPesq := VDN->VDN_CODCLI+"-"+VDN->VDN_LOJCLI+" "+VDN->VDN_NOMCLI
					ElseIf !Empty(VDN->VDN_CDPROS+VDN->VDN_LJPROS)
						cPesq := VDN->VDN_CDPROS+"-"+VDN->VDN_LJPROS+" "+VDN->VDN_NOMCLI
					EndIf
				Case cTpTotal == "4" // Nivel Importancia
					cPesq := VDL->VDL_NIVIMP
				Case cTpTotal == "5" // Tipo de Midia
					VX5->(DbSetOrder(1))
					VX5->(DbSeek(xFilial("VX5")+"027"+VDM->VDM_TIPMID))
					cPesq := VDM->VDM_TIPMID+" - "+VX5->VX5_DESCRI
				Case cTpTotal == "6" // Vendedor
					SA3->(DbSetOrder(1))
					SA3->(DbSeek(xFilial("SA3")+VDN->VDN_CODVEN))
					cPesq := VDN->VDN_CODVEN+" - "+SA3->A3_NOME
				Case cTpTotal == "7" // Motivo Cancelamento
					VS0->(DbSetOrder(1))
					VS0->(DbSeek(xFilial("VS0")+'000011'+VDN->VDN_MOTCAN))
					cPesq := VDN->VDN_MOTCAN+" - "+VS0->VS0_DESMOT
				Case cTpTotal == "8" // Fase Financiamento
					VX5->(DbSetOrder(1))
					VX5->(DbSeek(xFilial("VX5")+"031"+VDN->VDN_FASFIN))
					cPesq := VDN->VDN_FASFIN+" - "+VX5->VX5_DESCRI
				Case cTpTotal == "9" // Interesses x Atendimentos
					If !Empty(cStatusVV9)
						cPesq := STR0043+" "+X3CBOXDESC("VV9_STATUS",cStatusVV9) // Atend.
					Else
						cPesq := STR0044 // Sem Atendimento
	                EndIf
				Case cTpTotal == "0" // Etapas do Funil de Vendas
					VDK->(DbSetOrder(1))
					VDK->(DbSeek(xFilial("VDK")+VDN->VDN_CODFAS))
					cPesq := ""
					If lVDK_CODETA
						VQT->(DbSetOrder(1))
						VQT->(DbSeek(xFilial("VQT")+VDK->VDK_CODETA))
						cPesq := VQT->VQT_SEQUEN+" "+VDK->VDK_CODETA+" - "+VQT->VQT_DESCRI
					EndIf
			EndCase
			nPos := aScan(aTotais,{|x| x[1] == cPesq })
			If nPos <= 0
				aAdd(aTotais,{cPesq,0,0,"2"})
				nPos := len(aTotais)
			EndIf
			aTotais[nPos,2] += aInteres[ni,10]
			aTotais[1,2]    += aInteres[ni,10]
			//
			nPosAux := aScan(aAnalit,{|x| x[3] == cPesq })
			If nPosAux <= 0
				nPosAux := len(aAnalit)+1
				aAdd(aAnalit,{STR0048,0,cPesq}) // Em andamento
				aAdd(aAnalit,{STR0049,0,cPesq}) // Faturado
				aAdd(aAnalit,{STR0050,0,cPesq}) // Cancelado
			EndIf
			If !Empty(VDN->VDN_MOTCAN) .or. cStatusVV9 == "C" // Cancelado
				aAnalit[nPosAux+2,2] += aInteres[ni,10]
				aAnalit[3,2] += aInteres[ni,10] // Total
			ElseIf cStatusVV9 == "F" // Faturado ( Atendimento Finalizado )
				aAnalit[nPosAux+1,2] += aInteres[ni,10]
				aAnalit[2,2] += aInteres[ni,10] // Total
			Else // Em andamento
				aAnalit[nPosAux+0,2] += aInteres[ni,10]
				aAnalit[1,2] += aInteres[ni,10] // Total
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
		Aadd( aDadosGraf , { aTotais[ni,02] , STR0032 } ) // Demais
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
FG_NEWGRAF(oGrafPeq,cTitGraf+" ( "+IIf(cTpGraf=="1",STR0026,"%")+" )",aDadosGraf,.F.,IIf(cTpGraf=="1","@E 999,999,999","@E 999.9 %"))
oGrafPeq:LREADONLY := .T.
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_TOTAFC≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 20/10/14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Totaliza/Grafico: Em andamento / Faturado / Cancelado      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_TOTAFC(nLinha)
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
aAdd(aLbGrafA,{STR0031,0,0}) // Total Geral
For nCntAna := 1 to Len(aAnalit)
	If aAnalit[nCntAna,3] == aTotais[nLinha,01]
   		aAdd(aLbGrafA,aClone(aAnalit[nCntAna]))
   		aLbGrafA[1,2] += aAnalit[nCntAna,2]
 	EndIf
Next
Aadd( aDBGrafA , { round( ( aLbGrafA[2,02] / aLbGrafA[1,02] ) * 100 , 1 ) , aLbGrafA[2,01] } ) // Em andamento
Aadd( aDBGrafA , { round( ( aLbGrafA[3,02] / aLbGrafA[1,02] ) * 100 , 1 ) , aLbGrafA[3,01] } )  // Faturado
Aadd( aDBGrafA , { round( ( aLbGrafA[4,02] / aLbGrafA[1,02] ) * 100 , 1 ) , aLbGrafA[4,01] } )    // Cancelado
//
AAdd( aObjects, { 01, 65 , .T. , .F. } )
AAdd( aObjects, { 01, 00 , .T. , .T. } )
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)
//
DEFINE MSDIALOG oTotAFC FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE (cTitTela+" - "+aTotais[nLinha,01]) OF oMainWnd PIXEL
@ aPosObj[1,1],aPosObj[1,2] LISTBOX oLbGrafA FIELDS HEADER aTotais[nLinha,01],STR0026,"%" COLSIZES 117,27,25 SIZE aPosObj[1,4],aPosObj[1,3]-aPosObj[1,1] OF oTotAFC PIXEL // Qtde / %
oLbGrafA:SetArray(aLbGrafA)
oLbGrafA:bLine := { || { aLbGrafA[oLbGrafA:nAt,01] , FG_AlinVlrs(Transform(aLbGrafA[oLbGrafA:nAt,2],"@E 999,999")) , FG_AlinVlrs(Transform((aLbGrafA[oLbGrafA:nAt,2]/aLbGrafA[1,02])*100,"@E 999.9"))+" %" }}
@ aPosObj[2,1],aPosObj[2,2] SCROLLBOX oGrafAna SIZE aPosObj[2,3]-aPosObj[2,1],aPosObj[2,4] OF oTotAFC BORDER PIXEL
FG_NEWGRAF(oGrafAna,aTotais[nLinha,01]+" ( % )",aDBGrafA,.F.,"@E 999.9 %")
oGrafAna:LREADONLY := .T.
ACTIVATE MSDIALOG oTotAFC CENTER ON INIT (EnchoiceBar(oTotAFC,{|| oTotAFC:End() },{ || oTotAFC:End()},,))
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FS_FILIAIS≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 17/07/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Levanta Filiais                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_FILIAIS()
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
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 250,400 TITLE STR0023 PIXEL // Filiais
	@ 001,001 LISTBOX oLbEmp FIELDS HEADER  (""),STR0027,STR0025 COLSIZES 10,15,50 SIZE 165,120 OF oDlgEmp ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL // Filial / Nome
	oLbEmp:SetArray(aVetEmp)
	oLbEmp:bLine := { || {  IIf(aVetEmp[oLbEmp:nAt,1],oOk,oNo) ,;
	aVetEmp[oLbEmp:nAt,3],;
	aVetEmp[oLbEmp:nAt,4] }}
	DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp
	@ 002, 002 CHECKBOX oMacTod VAR lMarcar PROMPT "" OF oDlgEmp ON CLICK IIf( FS_TIK(lMarcar ) , .t. , ( lMarcar:=!lMarcar , oDlgEmp:Refresh() ) ) 	SIZE 70,08 PIXEL COLOR CLR_BLUE
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

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_TIK     ≥ Autor ≥  Andre Luis Almeida ≥ Data ≥ 17/07/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ TIK no ListBox da Empresa/Filiais                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function FS_TIK(lMarcar)
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

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_VCC680C ≥ Autor ≥  Andre Luis Almeida ≥ Data ≥ 18/07/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Seleciona Cliente                                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function FS_VCC680C(cTipo,lRefresh)
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

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao   ≥FS_CLIPROS≥ Autor ≥ Andre Luis Almeida     ≥ Data ≥ 02/09/15 ≥±±
±±√ƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao≥ Cliente ou Prospect                                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_CLIPROS()
oCodCli:lVisible := .f.
oLojCli:lVisible := .f.
oCdPros:lVisible := .f.
oLjPros:lVisible := .f.
oTodCli:lVisible := .f.
oNomCli:lVisible := .t.
If cCliPros == "1" // Cliente
	oCodCli:lVisible := .t.
	oLojCli:lVisible := .t.
	FS_VCC680C("CL",.t.)
	oCodCli:SetFocus()
ElseIf cCliPros == "2" // Prospect
	oCdPros:lVisible := .t.
	oLjPros:lVisible := .t.
	FS_VCC680C("PR",.t.)
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


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ VCC680VER  ≥ Autor ≥  Thiago             ≥ Data ≥ 18/07/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Visualiza Interesse detalhadamente                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function VCC680VER(cCodOpo,cCodInt,cFAnt)
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
Local nOpcao      := 0
Local aCposAux    := {}
Local aVldCpos    := {}
Local cCposH1     := ""
Local cCposH2     := ""
Local nX          := 0
Local aNewBot     := {}
Local lVCM680GH   := ExistBlock("VCM680GH")
Local cBkpFilAnt  := cFilAnt // Salvar Filial
Local cAliasVDN   := "SQLVDN"
Local cImpr       := ""
//
Local lVDN_CODOPO := ( VDN->(FieldPos("VDN_CODOPO")) > 0 )
//
Local cVDL_PERFIL := M->VDL_PERFIL // Salva variavel
Local cVDM_CAMPOP := M->VDM_CAMPOP // Salva variavel
Local cVDM_TIPMID := M->VDM_TIPMID // Salva variavel
Local cVDM_FASFIN := M->VDM_FASFIN // Salva variavel
Local cVDM_DECVDA := M->VDM_DECVDA // Salva variavel
//
Private oFnt3   := TFont():New( "Arial", , 14,.t. )
Private aCpoEnchoice := {} 
Private aImpEnchoice := {}
Private aCols1       := {} , aHeader1 := {}
Private aCols2       := {} , aHeader2 := {}
Private INCLUI       := .f.
Private aRotina      := {{"","axPesqui",0,1},{"","",0,2}}

If Empty(cCodOpo+cCodInt)
	Return .t.
EndIf

If (ExistBlock("VCC680ABT")) // Ponto de Entrada para adicionar opÁıes no Menu
	aNewBot := ExecBlock("VCC680ABT", .f., .f., {aNewBot})
EndIf

AADD(aNewBot,{"IMPRESSAO",{|| FS_IMPRIMIR(3) } , STR0068 } ) // Impressao

aObjects := {}
AAdd( aObjects , { 000, 50 , .T. , .T. } ) // Enchoice ( Oportunidade / Interesse )
AAdd( aObjects , { 000, 50 , .T. , .T. } ) // aCols ( Historico Interesse / Historico Financiamento )

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)

nOpcE := 2

cFilAnt := cFAnt // Mudar para filial do registro

dbSelectArea("VDM")
dbSetOrder(1)
dbSeek(xFilial("VDM")+cCodOpo+cCodInt)
If !Empty(VDM->VDM_FILATE+VDM->VDM_NUMATE)
	nOpcao := Aviso(STR0042,STR0045+" ?", { STR0046 , STR0047 } ) // Interesses x Atendimentos / Visualizar / Interesse / Atendimento
	If nOpcao == 2 // Atendimento
		VV9->(DbSetOrder(1))
		VV9->(DbSeek(VDM->VDM_FILATE+VDM->VDM_NUMATE))
		If !FM_PILHA("VEIXX002") .and. !FM_PILHA("VEIXX030")
			cCadastro := STR0047 // Atendimento
			VEIXX002(NIL,NIL,NIL,2,)
		EndIf
		cFilAnt := cBkpFilAnt // Voltar Filial
		Return
	ElseIf nOpcao <> 1 // Cancelou Tela
		cFilAnt := cBkpFilAnt // Voltar Filial
		Return .t.
	EndIf
EndIf

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

dbSelectArea("VDM")
dbSetOrder(1)
dbSeek(xFilial("VDM")+cCodOpo+cCodInt)
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VDM")
While !Eof().and.(x3_arquivo=="VDM")
	lImpr := .f.
	If X3USO(x3_usado).and.cNivel>=x3_nivel .and. !(Alltrim(x3_campo) $ [VDM_CODOPO/VDM_CODINT/VDM_OBSERV/])   
		AADD(aCpoEnchoice,x3_campo)
		lImpr := .t.
	Endif
	If SX3->X3_CONTEXT == "V"
		&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
	Else
		If !Empty(SX3->X3_CBOX)
			&("M->"+x3_campo) := X3CBOXDESC(x3_campo,&("VDM->"+Alltrim(x3_campo)))
		Else
			&("M->"+x3_campo) := &("VDM->"+Alltrim(x3_campo))
		EndIf
	EndIf
	If lImpr
		AADD(aImpEnchoice,{SX3->X3_TITULO,Transform(&("M->"+x3_campo),SX3->X3_PICTURE),SX3->X3_TAMANHO})
	EndIf
	DbSkip()
EndDo

If lVCM680GH // Campos do VDM que foram gravados nos Historicos
	aCposAux := ExecBlock("VCM680GH",.f.,.f.) // Retorno do PE "VCM680GH" deve ser um Vetor ( aCposAux )
	// aCposAux[1] = Campos do VDM que foram gravados nos Historicos das Fases do Interesse
	// aCposAux[2] = Campos do VDM que foram gravados nos Historicos das Fases de Financiamento
	If ValType(aCposAux) <> "A"
		aCposAux := {,}
	EndIf
	aVldCpos := aClone(aCposAux)
	aCposAux := {{},{}}
	If len(aVldCpos) >= 1
		For nX := 1 to len(aVldCpos[1])
			If VDN->(FieldPos("VDN_"+substr(aVldCpos[1,nX],5))) > 0
				aAdd(aCposAux[1],"VDN_"+substr(aVldCpos[1,nX],5))
				cCposH1 += "VDN_"+substr(aVldCpos[1,nX],5)
			EndIf
		Next
	EndIf
	If len(aVldCpos) >= 2
		For nX := 1 to len(aVldCpos[2])
			If VDN->(FieldPos("VDN_"+substr(aVldCpos[2,nX],5))) > 0
				aAdd(aCposAux[2],"VDN_"+substr(aVldCpos[2,nX],5))
				cCposH2 += "VDN_"+substr(aVldCpos[2,nX],5)
			EndIf
		Next
	EndIf
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria aHeader e aCols da GetDados                             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
nUsado1:=0
nUsado2:=0
dbSelectArea("SX3")
dbSeek("VDN")
While !Eof().And.(x3_arquivo=="VDN")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !( Alltrim(x3_campo) $ "VDN_TIPHIS/VDN_CODHIS/VDN_CODINT/VDN_USUHIS/VDN_CODVEN/VDN_FASFIN/VDN_DFASFI/VDN_CODBCO/VDN_NOMBCO/VDN_CODAGE/VDN_NOMGER/VDN_NROTEL/VDN_NOMCID/VDN_LINCRE/VDN_CCLIBC/VDN_LCLIBC/"+cCposH2 )
		nUsado1++
		Aadd(aHeader1,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
	Endif
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !( Alltrim(x3_campo) $ "VDN_TIPHIS/VDN_CODHIS/VDN_CODINT/VDN_USUHIS/VDN_CODVEN/VDN_CODFAS/VDN_DESFAS/VDN_OBSERV/VDN_CODCLI/VDN_LOJCLI/VDN_NOMCLI/VDN_DESMOT/VDN_NOMVEN/VDN_MOTCAN/VDN_VLRMON/VDN_VLROFE/VDN_VLRCLI/VDN_VLRVDA/VDN_DATVDA/VDN_VLRCOM/VDN_QTDUSA/VDN_VLRUSA/VDN_DECVDA/"+cCposH1 )
		nUsado2++
		Aadd(aHeader2,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
	Endif
	dbSkip()
End
cQuery := "SELECT R_E_C_N_O_ AS RECVDN"
cQuery += "  FROM " + RetSqlName( "VDN" ) 
cQuery += " WHERE VDN_FILIAL='"+xFilial("VDN")+"'"
cQuery += "   AND VDN_CODINT='"+VDM->VDM_CODINT+"'"
If lVDN_CODOPO
	cQuery += " AND ( VDN_CODOPO='"+VDM->VDM_CODOPO+"' OR VDN_CODOPO=' ' )"
EndIf
cQuery += "   AND D_E_L_E_T_=' ' ORDER BY VDN_CODHIS"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVDN, .T., .T. )
aCols1 := {}
aCols2 := {}
nReg1 := 1
nReg2 := 1
Do While !( cAliasVDN )->( Eof() )
	VDN->(dbGoto(( cAliasVDN )->RECVDN))
	VDK->(dbSetOrder(1))
	VDK->(dbSeek(xFilial("VDK")+VDN->VDN_CODFAS))
	If VDN->VDN_TIPHIS <> "2"
		Aadd(aCols1, Array(Len(aHeader1)+1) )
		aCols1[1,nUsado1+1]:=.F.
		For _ni:=1 to nUsado1
			aCols1[nReg1,_ni]:=CriaVar(aHeader1[_ni,2])
		Next
		aCols1[nReg1,FG_POSVAR("VDN_CODFAS","aHeader1")] := VDN->VDN_CODFAS
		aCols1[nReg1,FG_POSVAR("VDN_DESFAS","aHeader1")] := VDK->VDK_DESFAS
		aCols1[nReg1,FG_POSVAR("VDN_DATHIS","aHeader1")] := VDN->VDN_DATHIS
		aCols1[nReg1,FG_POSVAR("VDN_HORHIS","aHeader1")] := VDN->VDN_HORHIS
		aCols1[nReg1,FG_POSVAR("VDN_NOMUSU","aHeader1")] := FM_SQL("SELECT VAI_NOMUSU FROM "+RetSQLName("VAI")+" WHERE VAI_FILIAL='"+xFilial("VAI")+"' AND VAI_CODUSR='"+VDN->VDN_USUHIS+"' AND D_E_L_E_T_=' '")
		aCols1[nReg1,FG_POSVAR("VDN_OBSERV","aHeader1")] := VDN->VDN_OBSERV
		aCols1[nReg1,FG_POSVAR("VDN_CODCLI","aHeader1")] := VDN->VDN_CODCLI
		aCols1[nReg1,FG_POSVAR("VDN_LOJCLI","aHeader1")] := VDN->VDN_LOJCLI
		aCols1[nReg1,FG_POSVAR("VDN_NOMCLI","aHeader1")] := VDN->VDN_NOMCLI
		aCols1[nReg1,FG_POSVAR("VDN_VLRMON","aHeader1")] := VDN->VDN_VLRMON
		aCols1[nReg1,FG_POSVAR("VDN_VLROFE","aHeader1")] := VDN->VDN_VLROFE
		aCols1[nReg1,FG_POSVAR("VDN_VLRCLI","aHeader1")] := VDN->VDN_VLRCLI
		aCols1[nReg1,FG_POSVAR("VDN_VLRVDA","aHeader1")] := VDN->VDN_VLRVDA
		aCols1[nReg1,FG_POSVAR("VDN_DATVDA","aHeader1")] := VDN->VDN_DATVDA
		aCols1[nReg1,FG_POSVAR("VDN_VLRCOM","aHeader1")] := VDN->VDN_VLRCOM
		aCols1[nReg1,FG_POSVAR("VDN_QTDUSA","aHeader1")] := VDN->VDN_QTDUSA
		aCols1[nReg1,FG_POSVAR("VDN_VLRUSA","aHeader1")] := VDN->VDN_VLRUSA
		aCols1[nReg1,FG_POSVAR("VDN_DECVDA","aHeader1")] := VDN->VDN_DECVDA
		VS0->(dbSetOrder(1))
		VS0->(dbSeek(xFilial("VS0")+"000011"+VDN->VDN_MOTCAN))
		aCols1[nReg1,FG_POSVAR("VDN_DESMOT","aHeader1")] := VS0->VS0_DESMOT
		SA3->(dbSetOrder(1))
		SA3->(dbSeek(xFilial("SA3")+VDN->VDN_CODVEN))
		aCols1[nReg1,FG_POSVAR("VDN_NOMVEN","aHeader1")] := SA3->A3_NOME
		//
		If len(aCposAux) >= 1
			For nX := 1 to len(aCposAux[1])
				aCols1[nReg1,FG_POSVAR(aCposAux[1,nX],"aHeader1")] := &("VDN->"+aCposAux[1,nX])
			Next
		EndIf
		//
		aCols1[nReg1,Len(aCols1[1])] := .f.
		nReg1++
	Else
		Aadd(aCols2, Array(Len(aHeader2)+1) )
		aCols2[1,nUsado2+1]:=.F.
		For _ni:=1 to nUsado2
			aCols2[nReg2,_ni]:=CriaVar(aHeader2[_ni,2])
		Next
		aCols2[nReg2,FG_POSVAR("VDN_FASFIN","aHeader2")] := VDN->VDN_FASFIN 
		if FG_POSVAR("VDN_DFASFI","aHeader2") > 0 		
			dbSelectArea("VX5")
			dbSetOrder(1)
			dbSeek(xFilial("VX5")+"031"+VDN->VDN_FASFIN) 
			aCols2[nReg2,FG_POSVAR("VDN_DFASFI","aHeader2")] := VX5->VX5_DESCRI
		Endif	
		aCols2[nReg2,FG_POSVAR("VDN_DATHIS","aHeader2")] := VDN->VDN_DATHIS
		aCols2[nReg2,FG_POSVAR("VDN_HORHIS","aHeader2")] := VDN->VDN_HORHIS
		aCols2[nReg2,FG_POSVAR("VDN_NOMUSU","aHeader2")] := FM_SQL("SELECT VAI_NOMUSU FROM "+RetSQLName("VAI")+" WHERE VAI_FILIAL='"+xFilial("VAI")+"' AND VAI_CODUSR='"+VDN->VDN_USUHIS+"' AND D_E_L_E_T_=' '")
		aCols2[nReg2,FG_POSVAR("VDN_CCLIBC","aHeader2")] := VDN->VDN_CCLIBC
		aCols2[nReg2,FG_POSVAR("VDN_LCLIBC","aHeader2")] := VDN->VDN_LCLIBC
		aCols2[nReg2,FG_POSVAR("VDN_NCLIBC","aHeader2")] := FM_SQL("SELECT A1_NOME FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+VDN->VDN_CCLIBC+"' AND A1_LOJA='"+VDN->VDN_LCLIBC+"' AND D_E_L_E_T_=' '")
		aCols2[nReg2,FG_POSVAR("VDN_CODBCO","aHeader2")] := VDN->VDN_CODBCO
		aCols2[nReg2,FG_POSVAR("VDN_NOMBCO","aHeader2")] := VDN->VDN_NOMBCO
		aCols2[nReg2,FG_POSVAR("VDN_CODAGE","aHeader2")] := VDN->VDN_CODAGE
		aCols2[nReg2,FG_POSVAR("VDN_NOMGER","aHeader2")] := VDN->VDN_NOMGER
		aCols2[nReg2,FG_POSVAR("VDN_NROTEL","aHeader2")] := VDN->VDN_NROTEL
		aCols2[nReg2,FG_POSVAR("VDN_NOMCID","aHeader2")] := VDN->VDN_NOMCID
		aCols2[nReg2,FG_POSVAR("VDN_LINCRE","aHeader2")] := VDN->VDN_LINCRE
		//
		If len(aCposAux) >= 2
			For nX := 1 to len(aCposAux[2])
				aCols2[nReg2,FG_POSVAR(aCposAux[2,nX],"aHeader2")] := &("VDN->"+aCposAux[2,nX])
			Next
		EndIf
		//
		aCols2[nReg2,Len(aCols2[1])] := .f.
		nReg2++
	EndIf
	( cAliasVDN )->(DbSkip())
Enddo
( cAliasVDN )->( dbCloseArea() )
DbSelectArea("VDN")
//
If len(aCols1) > 0
	For i := 1 to Len(aCols1)
		dDtPx  := ctod("")
		nTempo := 0
		nDias  := 0
		dData  := aCols1[i,FG_POSVAR("VDN_DATHIS","aHeader1")]
		nHora  := aCols1[i,FG_POSVAR("VDN_HORHIS","aHeader1")]
		cCFas  := aCols1[i,FG_POSVAR("VDN_CODFAS","aHeader1")]
		i++
		if i <= Len(aCols1)
			dDtPx   := aCols1[i,FG_POSVAR("VDN_DATHIS","aHeader1")]
			nHrPx   := aCols1[i,FG_POSVAR("VDN_HORHIS","aHeader1")]
		Else
			VDK->(DbSetOrder(1))
			VDK->(DbSeek(xFilial("VDK")+cCFas))
			If VDK->VDK_FIMFAS <> "1"
				dDtPx   := dDataBase
				nHrPx   := val(substr(Time(),1,2)+substr(Time(),4,2))
			EndIf
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
			aCols1[i,FG_POSVAR("VDN_TEMPO","aHeader1")] := Alltrim(str(nDias))+" "+STR0033+" "+transform(strzero(nTempo,4),"@R 99:99")+STR0034 // dia(s) e / h
		Else
			aCols1[i,FG_POSVAR("VDN_TEMPO","aHeader1")] := STR0036 // Fase final
		EndIf
	Next
Else
	Aadd(aCols1, Array(Len(aHeader1)+1) )
	aCols1[1,nUsado1+1]:=.F.
	For _ni:=1 to nUsado1
		aCols1[nReg1,_ni]:=CriaVar(aHeader1[_ni,2])
	Next
EndIf
//
If len(aCols2) > 0
	For i := 1 to Len(aCols2)
		dDtPx  := ctod("")
		nTempo := 0
		nDias  := 0
		dData  := aCols2[i,FG_POSVAR("VDN_DATHIS","aHeader2")]
		nHora  := aCols2[i,FG_POSVAR("VDN_HORHIS","aHeader2")]
		i++
		if i <= Len(aCols2)
			dDtPx   := aCols2[i,FG_POSVAR("VDN_DATHIS","aHeader2")]
			nHrPx   := aCols2[i,FG_POSVAR("VDN_HORHIS","aHeader2")]
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
			aCols2[i,FG_POSVAR("VDN_TEMPO","aHeader2")] := Alltrim(str(nDias))+" "+STR0033+" "+transform(strzero(nTempo,4),"@R 99:99")+STR0034 // dia(s) e / h
		EndIf
	Next
Else
	Aadd(aCols2, Array(Len(aHeader2)+1) )
	aCols2[1,nUsado2+1]:=.F.
	For _ni:=1 to nUsado2
		aCols2[nReg2,_ni]:=CriaVar(aHeader2[_ni,2])
	Next
EndIf
//
DEFINE MSDIALOG oDlgVis FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0035 OF oMainWnd PIXEL // Detalhes do Interesse
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
oFolderGD := TFolder():New(aPos[2,1],aPos[2,2],{STR0038,STR0039},{}, oDlgVis,,,,.t.,.f.,aPos[2,4],aPos[2,3]-aPos[2,1])
oGetDados1 := MsNewGetDados():New(0,0,aPos[2,3]-aPos[2,1]-20,aPos[2,4]-aPos[2,2],0,"AlwaysTrue()","AlwaysTrue()",,{},,999,"AlwaysTrue()",,"AlwaysTrue()",oFolderGD:aDialogs[1],aHeader1,aCols1)
oGetDados2 := MsNewGetDados():New(0,0,aPos[2,3]-aPos[2,1]-20,aPos[2,4]-aPos[2,2],0,"AlwaysTrue()","AlwaysTrue()",,{},,999,"AlwaysTrue()",,"AlwaysTrue()",oFolderGD:aDialogs[2],aHeader2,aCols2)
ACTIVATE MSDIALOG oDlgVis CENTER ON INIT EnchoiceBar(oDlgVis,{|| oDlgVis:End() },{|| oDlgVis:End() },,aNewBot)
//
cFilAnt := cBkpFilAnt // Voltar Filial salva
//
M->VDL_PERFIL := cVDL_PERFIL // Volta variavel salva
M->VDM_CAMPOP := cVDM_CAMPOP // Volta variavel salva
M->VDM_TIPMID := cVDM_TIPMID // Volta variavel salva
M->VDM_FASFIN := cVDM_FASFIN // Volta variavel salva
M->VDM_DECVDA := cVDM_DECVDA // Volta variavel salva
//
Return .t.

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_MARKA   ≥ Autor ≥  Thiago             ≥ Data ≥ 31/07/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Limpa campo motiva se cheekbox estiver marcado.            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function FS_MARKA(nTp)
If nTp == 1
	If lMarMot
		cMotCan := space(TamSX3("VDM_MOTCAN")[1])
		oMotCan:Refresh()
	EndIf
ElseIf nTp == 2
	If lMarFin
		M->VDM_FASFIN := space(TamSX3("VDM_FASFIN")[1])
		oFasFin:Refresh()
	EndIf
ElseIf nTp == 3
	If lMarFas
		cCodFas := space(TamSX3("VDM_CODFAS")[1])
		oCodFas:Refresh()
	EndIf
EndIf
Return .t.

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FS_VLCHEKBOX≥ Autor ≥  Thiago             ≥ Data ≥ 31/07/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Valida se o cheekbox esta marcado.				          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function FS_VLCHEKBOX(nTp)
If nTp == 1 
	If !Empty(cMotCan)
		lMarMot := .f.
		oMarMot:Refresh()
	EndIf
ElseIf nTp == 2 
	If !Empty(M->VDM_FASFIN)
		lMarFin := .f.
		oMarFin:Refresh()
	EndIf
ElseIf nTp == 3 
	If !Empty(cCodFas)
		lMarFas := .f.
		oMarFas:Refresh()
	EndIf
EndIf
Return .t.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥VCC680FUNIL≥ Autor ≥ Andre Luis Almeida   ≥ Data ≥ 04/06/18 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Funil das Oportunidades - Etapas dos Interesses            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VCC680FUNIL()
Local oSize      := FwDefSize():New(.f.) // SEM enchoicebar
Local nLinha     := 0
Local oFont1     := TFont():New(,10,20,,.F.,,,,,,,,,,,)
Local oFont2     := TFont():New(,08,16,,.F.,,,,,,,,,,,)
Local oPanel1
Local oPanel2
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
					space(TamSX3("VDN_CODVEN")[1]) ,;
					space(TamSX3("VDL_CODCLI")[1]) ,;
					space(TamSX3("VDL_LOJCLI")[1]) ,;
					space(TamSX3("VDL_CDPROS")[1]) ,; 
					space(TamSX3("VDL_LJPROS")[1]) ,;
					space(TamSX3("VDM_CODMAR")[1]) ,;
					space(TamSX3("VDM_MODVEI")[1]) ,;
					space(TamSX3("VDM_CAMPOP")[1]) ,;
					cFilAnt }
aFilAtu := FWArrFilAtu()
aFilAux := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
For nCntFor := 1 to len(aFilAux)
	aAdd(aFilSelect,{ ( lAllFil .or. aParametros[12] == aFilAux[nCntFor] ) , aFilAux[nCntFor] })
Next
//
VCC680011_F7(.f.)
//
// Calcula as dimensıes dos objetos
oSize:lLateral := .T. // C·lculo vertical
oSize:AddObject("FILTROS", 120 , 0 , .F., .T.) // Adiciona Filtros
oSize:AddObject("FUNIL"  ,   0 , 0 , .T., .T.) // Adiciona Grafico Funil
// Dispara o c·lculo
oSize:Process()
//
DEFINE MSDIALOG oDlgChart TITLE STR0079 ; // Funil de Veiculos/M·quinas - Oportunidades - Etapas dos Interesses
	FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] PIXEL

	oPanelFiltr := TPanel():New(	oSize:GetDimension("FILTROS", "LININI") ,;
									oSize:GetDimension("FILTROS", "COLINI") ,;
									"",oDlgChart,NIL,.T.,.F.,NIL,NIL,;
									oSize:GetDimension("FILTROS", "COLEND") ,;
									oSize:GetDimension("FILTROS", "LINEND")-oSize:GetDimension("FILTROS", "LININI") ,;
									.T.,.F.)

	nLinha := 07
	@ nLinha,40 SAY STR0071 SIZE 40,10 FONT oFont1 OF oPanelFiltr PIXEL COLOR CLR_BLUE // FILTROS
	nLinha += 20
	@ nLinha,05 SAY STR0072 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Data Inicial
	@ nLinha,45 MSGET oDtIInt VAR aParametros[01] PICTURE "@D" SIZE 50,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0073 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Data Final
	@ nLinha,45 MSGET oDtFInt VAR aParametros[02] PICTURE "@D" SIZE 50,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0074 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Data Corte
	@ nLinha,45 MSGET oDtCInt VAR aParametros[03] PICTURE "@D" SIZE 50,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0014 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Vendedor
	@ nLinha,45 MSGET oVdCInt VAR aParametros[04] PICTURE "@!" F3 "SA3" SIZE 40,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0006 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Cliente
	@ nLinha,45 MSGET oCdClie VAR aParametros[05] PICTURE "@!" F3 "SA1" SIZE 40,8 PIXEL OF oPanelFiltr HASBUTTON
	@ nLinha,85 MSGET oLjClie VAR aParametros[06] PICTURE "@!" SIZE 20,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0054 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Prospect
	@ nLinha,45 MSGET oCdPrsc VAR aParametros[07] PICTURE "@!" F3 "SUS" SIZE 40,8 PIXEL OF oPanelFiltr HASBUTTON
	@ nLinha,85 MSGET oLjPrsc VAR aParametros[08] PICTURE "@!" SIZE 20,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0017 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Marca
	@ nLinha,45 MSGET oCodMar VAR aParametros[09] PICTURE "@!" F3 "VE1" SIZE 40,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0018 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Modelo
	@ nLinha,45 MSGET oModVei VAR aParametros[10] PICTURE "@!" F3 "VV2" SIZE 60,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	@ nLinha,05 SAY STR0012 SIZE 50,10 FONT oFont2 OF oPanelFiltr PIXEL COLOR CLR_BLUE // Campanha
	@ nLinha,45 MSGET oCampan VAR aParametros[11] PICTURE "@!" F3 "VX5AUX" SIZE 40,8 PIXEL OF oPanelFiltr HASBUTTON
	nLinha += 12
	oLbFiliais := TWBrowse():New( nLinha,;
								005,;
								100,;
								65,;
								,,,oPanelFiltr,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
	oLbFiliais:addColumn( TCColumn():New( "", { || IIf(aFilSelect[oLbFiliais:nAt,1],oOkTik,oNoTik) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Tik
	oLbFiliais:addColumn( TCColumn():New( STR0023 , { || aFilSelect[oLbFiliais:nAt,02] } ,,,, "LEFT" ,  60 ,.F.,.F.,,,,.F.,) ) // Filiais
	oLbFiliais:nAt := 1
	oLbFiliais:SetArray(aFilSelect)
	oLbFiliais:bLDblClick   := { || ( aFilSelect[oLbFiliais:nAt,1] := !aFilSelect[oLbFiliais:nAt,1] ) }
	oLbFiliais:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lAllFil := !lAllFil , aEval(aFilSelect,{|x| x[1] := lAllFil }) , oLbFiliais:Refresh() ) , .t. ) , }

	nLinha += 80
	@ nLinha,35 BUTTON oFiltrar PROMPT STR0022 OF oPanelFiltr SIZE 48,10 PIXEL ACTION FS_MONTAGRAF( aParametros , aFilSelect , .t. ) // Filtrar

	oPanelChart := TPanel():New(	oSize:GetDimension("FUNIL", "LININI") ,;
									oSize:GetDimension("FUNIL", "COLINI") ,;
									"",oDlgChart,,,,,,;
									oSize:GetDimension("FUNIL", "COLEND") ,;
									oSize:GetDimension("FUNIL", "LINEND")-oSize:GetDimension("FUNIL", "LININI") )

	oChartFactory := FWChartFactory():New()
	oChart := oChartFactory:getInstance( 05 )
	oChart:SetOwner(oPanelChart)

	oChart:setTitle(STR0079, CONTROL_ALIGN_CENTER) // Funil de Veiculos/M·quinas - Oportunidades - Etapas dos Interesses
	oChart:setLegend( CONTROL_ALIGN_BOTTOM )
	oChart:setMask( " *@* " )
	oChart:setPicture( "@E 999,999,999" )

	FS_MONTAGRAF( aParametros , aFilSelect , .f. )

	oChart:SetSerieAction({ |nSerie| FS_CLICKGRAF( nSerie , aParametros , aFilSelect ) })

	oChart:oChart:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)

	oChart:Activate()

	//
ACTIVATE DIALOG oDlgChart
//
VCC680011_F7(.t.)
//
Return

/*/{Protheus.doc} FS_MONTAGRAF
Monta Grafico do Funil

@author Andre
@since 08/06/2018
@version undefined

@type function
/*/
Static Function FS_MONTAGRAF( aParametros , aFilSelect , lRefresh )
Local cQuery  := ""
Local cQAlias := "SQLFUNIL"
Local nCntFor := 0
Local nPosAux := 0
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

		cQuery := "SELECT VQT_SEQUEN , VQT_CODIGO , VQT_DESCRI , COUNT(*) AS QTD "
		cQuery += "FROM ( "
		cQuery += "   SELECT VQT.VQT_SEQUEN , VQT.VQT_CODIGO , VQT.VQT_DESCRI , VDM.R_E_C_N_O_ "
		cQuery += "   FROM "+RetSqlName("VDL")+" VDL "
		cQuery += "   JOIN "+RetSqlName("VDM")+" VDM ON VDM.VDM_FILIAL = VDL.VDL_FILIAL AND VDM.VDM_CODOPO = VDL.VDL_CODOPO AND VDM.D_E_L_E_T_ = ' ' "
		cQuery += "   JOIN "+RetSqlName("VDN")+" VDN ON VDN.VDN_FILIAL = VDL.VDL_FILIAL AND VDN.VDN_CODINT = VDM.VDM_CODINT AND VDN.VDN_CODCLI = VDL.VDL_CODCLI AND VDN.VDN_LOJCLI = VDL.VDL_LOJCLI AND VDN.D_E_L_E_T_ = ' ' "
		cQuery += "   JOIN "+RetSqlName("VDK")+" VDK ON VDK.VDK_FILIAL = '"+xFilial("VDK")+"' AND VDK.VDK_CODFAS = VDN.VDN_CODFAS AND VDK.VDK_TIPFAS IN (' ','1') AND VDK.D_E_L_E_T_ = ' ' "
		cQuery += "   JOIN "+RetSqlName("VQT")+" VQT ON VQT.VQT_FILIAL = '"+xFilial("VQT")+"' AND VQT.VQT_CODIGO = VDK.VDK_CODETA AND VQT.VQT_TIPETA IN (' ','1') AND VQT.D_E_L_E_T_ = ' ' "
		cQuery += FS_SQLWHERE( aParametros ) // Filtros do SQL do Funil
		cQuery += "   GROUP BY VQT.VQT_SEQUEN , VQT.VQT_CODIGO , VQT.VQT_DESCRI , VDM.R_E_C_N_O_ ) TB_UNICOS_ETAPA "
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

/*/{Protheus.doc} FS_CLICKGRAF
Click no Grafico do Funil

@author Andre
@since 08/06/2018
@version undefined

@type function
/*/
Static Function FS_CLICKGRAF( nSerie , aParametros , aFilSelect )
Local cQuery  := ""
Local cQAlias := "SQLFUNIL"
Local cCod    := ""
Local cLoj    := ""
Local cNom    := ""
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

			cVQT_SEQUEN := FM_SQL("SELECT VQT_SEQUEN FROM "+RetSqlName("VQT")+" WHERE VQT_FILIAL='"+xFilial("VQT")+"' AND VQT_CODIGO='"+aSerie[nSerie]+"' AND VQT_TIPETA IN (' ','1') AND D_E_L_E_T_=' ' ")
			nPosEtapa := 1
			aFasEtapa := {}
			cQuery := " SELECT VQT.VQT_SEQUEN , VQT.VQT_CODIGO , VDK.VDK_CODFAS "
			cQuery += "   FROM "+RetSqlName("VDK")+" VDK "
			cQuery += "   JOIN "+RetSqlName("VQT")+" VQT ON VQT.VQT_FILIAL = '"+xFilial("VQT")+"' AND VQT.VQT_CODIGO = VDK.VDK_CODETA AND VQT.VQT_TIPETA IN (' ','1') AND VQT.VQT_SEQUEN>='"+cVQT_SEQUEN+"' AND VQT.D_E_L_E_T_ = ' ' "
			cQuery += "  WHERE VDK.VDK_FILIAL = '"+xFilial("VDK")+"'"
			cQuery += "    AND VDK.VDK_TIPFAS IN (' ','1')"
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
				cQuery := " SELECT DISTINCT "
				cQuery += "        VDL.VDL_CODOPO , "
				cQuery += "        VDM.VDM_CODINT , "
				cQuery += "        VDM.VDM_DATINT , "
				cQuery += "        VDL.VDL_CODCLI , VDL.VDL_LOJCLI , SA1.A1_NOME , "
				cQuery += "        VDL.VDL_CDPROS , VDL.VDL_LJPROS , SUS.US_NOME , "
				cQuery += "        VDM.VDM_CODFAS , VDK.VDK_DESFAS , "
				cQuery += "        VDM.VDM_CODMAR , VDM.VDM_MODVEI "
				cQuery += "   FROM "+RetSqlName("VDL")+" VDL "
				cQuery += "   JOIN "+RetSqlName("VDM")+" VDM ON VDM.VDM_FILIAL = VDL.VDL_FILIAL AND VDM.VDM_CODOPO = VDL.VDL_CODOPO and VDM.D_E_L_E_T_ = ' ' "
				cQuery += "   JOIN "+RetSqlName("VDN")+" VDN ON VDN.VDN_FILIAL = VDL.VDL_FILIAL AND VDN.VDN_CODINT = VDM.VDM_CODINT AND VDN.VDN_CODCLI = VDL.VDL_CODCLI AND VDN.VDN_LOJCLI = VDL.VDL_LOJCLI AND VDN.D_E_L_E_T_ = ' ' "
				cQuery += "   JOIN "+RetSqlName("VDK")+" VDK ON VDK.VDK_FILIAL = '"+xFilial("VDK")+"' AND VDK.VDK_CODFAS = VDM.VDM_CODFAS AND VDK.VDK_TIPFAS IN (' ','1') AND VDK.D_E_L_E_T_ = ' ' "
				cQuery += "   LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VDL.VDL_CODCLI AND SA1.A1_LOJA=VDL.VDL_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
				cQuery += "   LEFT JOIN "+RetSqlName("SUS")+" SUS ON ( SUS.US_FILIAL='"+xFilial("SUS")+"' AND SUS.US_COD=VDL.VDL_CDPROS AND SUS.US_LOJA=VDL.VDL_LJPROS AND SUS.D_E_L_E_T_=' ' ) "
				cQuery += FS_SQLWHERE( aParametros ) // Filtros do SQL do Funil
				cQuery += "    AND VDN.VDN_CODFAS IN ("+aFasEtapa[nPosEtapa,3]+")"
				cQuery += "  ORDER BY VDL.VDL_CODOPO , VDM.VDM_CODINT "
				//
				cQuebra := "INICIAL"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
				Do While !( cQAlias )->( Eof() )
					If cQuebra == ( cQAlias )->( VDL_CODOPO ) + ( cQAlias )->( VDM_CODINT )
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

					nAux := aScan(aFasEtapa,{|x| ( cQAlias )->( VDM_CODFAS ) $ x[3] }) // Verifica Posicao da Etapa para validar a sequencia da Etapa

					aAdd(aAnalGraf,{stod( ( cQAlias )->( VDM_DATINT ) ) ,;
									cCod + "-" + cLoj +" "+ Alltrim(cNom) + cTip ,;
									( cQAlias )->( VDM_CODFAS ) +" "+ ( cQAlias )->( VDK_DESFAS ) ,;
									( cQAlias )->( VDM_CODMAR ) ,;
									Alltrim(( cQAlias )->( VDM_MODVEI )) +" - "+FM_SQL("SELECT VV2_DESMOD FROM "+RetSqlName("VV2")+" WHERE VV2_FILIAL='"+xFilial("VV2")+"' AND VV2_CODMAR='"+( cQAlias )->( VDM_CODMAR )+"' AND VV2_MODVEI='"+( cQAlias )->( VDM_MODVEI )+"' AND D_E_L_E_T_=' '") ,;
									( cQAlias )->( VDL_CODOPO ) ,;
									( cQAlias )->( VDM_CODINT ) ,;
									cFilAnt ,;
									IIf(( aFasEtapa[nAux,1] <> aFasEtapa[nPosEtapa,1] ),"1","0") })

					cQuebra := ( cQAlias )->( VDL_CODOPO ) + ( cQAlias )->( VDM_CODINT )
					( cQAlias )->( DbSkip() )
				EndDo
				( cQAlias )->( dbCloseArea() )
			//

		EndIf

	Next

	aSort(aAnalGraf,,,{|x,y| x[9]+dtos(x[1])+x[6]+x[7] < y[9]+dtos(y[1])+y[6]+y[7] }) // Ordenar Interesses

	cFilAnt := cBkpFilAnt

	FS_TELANALIT( aAnalGraf , aSerie[nSerie] )

	cFilAnt := cBkpFilAnt

EndIf
Return

/*/{Protheus.doc} FS_SQLWHERE
Monta WHERE dos Filtros do SQL do Funil

@author Andre
@since 08/06/2018
@version undefined

@type function
/*/
Static Function FS_SQLWHERE( aParametros )
Local cRet := ""
cRet += "  WHERE VDL_FILIAL = '"+xFilial("VDL")+"' "
If !Empty(aParametros[01]) // Data Inicial de Interesse
	cRet += " AND VDM.VDM_DATINT >= '"+dtos(aParametros[01])+"'"
EndIf
If !Empty(aParametros[02]) // Data Final de Interesse
	cRet += " AND VDM.VDM_DATINT <= '"+dtos(aParametros[02])+"'"
EndIf
If !Empty(aParametros[03]) // Data de Corte de Historico
	cRet += " AND VDN.VDN_DATHIS <= '"+dtos(aParametros[03])+"'"
EndIf
If !Empty(aParametros[04]) // Vendedor
	cRet += " AND VDN.VDN_CODVEN = '"+aParametros[04]+"'"
EndIf
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
If !Empty(aParametros[09]) // Marca Veiculo
	cRet += " AND VDM.VDM_CODMAR = '"+aParametros[09]+"'"
EndIf
If !Empty(aParametros[10]) // Modelo Veiculo
	cRet += " AND VDM.VDM_MODVEI = '"+aParametros[10]+"'"
EndIf
If !Empty(aParametros[11]) // Campanha
	cRet += " AND VDM.VDM_CAMPOP = '"+aParametros[11]+"'"
EndIf
cRet += "     AND VDL.D_E_L_E_T_ = ' ' "
Return cRet

/*/{Protheus.doc} FS_TELANALIT
Lista Interesses da Etapa selecionada no Funil

@author Andre
@since 08/06/2018
@version undefined

@type function
/*/
Static Function FS_TELANALIT( aAnalGraf , cCodEtapa )
Local oSize       := FwDefSize():New(.t.) // COM enchoicebar
Private cCadastro := ""
Private oAtuEtapa := LoadBitmap( GetResources() , "BR_BRANCO" )
Private oPrxEtapa := LoadBitmap( GetResources() , "BR_VERDE" )

oSize:lLateral := .F. // C·lculo vertical
oSize:AddObject("ALL", 0 , 0 , .T., .T.)
oSize:Process()
//
VQT->(DbSetOrder(1))
VQT->(DbSeek(xFilial("VQT")+cCodEtapa))
cCadastro := STR0080+" - "+STR0077+" "+cCodEtapa+" - "+VQT->VQT_DESCRI // Interesses VeÌculos/M·quinas / Etapa:
//
DEFINE MSDIALOG oDlgAnalit TITLE cCadastro ;
							FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] PIXEL
	oLbAnalit := TWBrowse():New(oSize:GetDimension("ALL","LININI"),;
								oSize:GetDimension("ALL","COLINI"),;
								oSize:GetDimension("ALL","COLEND")-oSize:GetDimension("ALL","COLINI"),;
								oSize:GetDimension("ALL","LINEND")-oSize:GetDimension("ALL","LININI")-15,;
								,,, oDlgAnalit,,,,,,,,,,,,.F.,,.T.,,.F.,,, )

	oLbAnalit:addColumn( TCColumn():New( "", { || IIf(oLbAnalit:aArray[ oLbAnalit:nAt , 9 ]=="1",oPrxEtapa,oAtuEtapa) } ,,,,"LEFT" ,12,.T.,.F.,,,,.F.,) )
	oLbAnalit:addColumn( TCColumn():New( STR0027 , { || oLbAnalit:aArray[ oLbAnalit:nAt , 8 ] },,,,"LEFT" ,80,.F.,.F.,,,,.F.,) )
	oLbAnalit:addColumn( TCColumn():New( STR0007 , { || Transform( oLbAnalit:aArray[ oLbAnalit:nAt , 1 ] ,"@D") },,,,"LEFT" ,45,.F.,.F.,,,,.F.,) )
	oLbAnalit:addColumn( TCColumn():New( STR0006+" (1)"+" / "+STR0054+" (2)" , { || oLbAnalit:aArray[ oLbAnalit:nAt , 2 ] },,,,"LEFT" ,150,.F.,.F.,,,,.F.,) )
	oLbAnalit:addColumn( TCColumn():New( STR0078 , { || oLbAnalit:aArray[ oLbAnalit:nAt , 3 ] },,,,"LEFT" ,150,.F.,.F.,,,,.F.,) )
	oLbAnalit:addColumn( TCColumn():New( STR0017 , { || oLbAnalit:aArray[ oLbAnalit:nAt , 4 ] },,,,"LEFT" ,25,.F.,.F.,,,,.F.,) )
	oLbAnalit:addColumn( TCColumn():New( STR0018 , { || oLbAnalit:aArray[ oLbAnalit:nAt , 5 ] },,,,"LEFT" ,150,.F.,.F.,,,,.F.,) )
	oLbAnalit:bLDblClick := { || VCC680VER( aAnalGraf[oLbAnalit:nAt,6] , aAnalGraf[oLbAnalit:nAt,7] , aAnalGraf[oLbAnalit:nAt,08] ) }
	oLbAnalit:SetArray(aAnalGraf)
	oLbAnalit:Refresh()

	@ oSize:GetDimension("ALL","LINEND")-10,005 BITMAP oxBran RESOURCE "BR_BRANCO" OF oDlgAnalit NOBORDER SIZE 10,10 when .f. PIXEL
	@ oSize:GetDimension("ALL","LINEND")-10,015 SAY (STR0077+" "+cCodEtapa+" - "+VQT->VQT_DESCRI) SIZE 200,8 OF oDlgAnalit PIXEL COLOR CLR_BLACK // Etapa:

	@ oSize:GetDimension("ALL","LINEND")-10,205 BITMAP oxCinz RESOURCE "BR_VERDE" OF oDlgAnalit NOBORDER SIZE 10,10 when .f. PIXEL
	@ oSize:GetDimension("ALL","LINEND")-10,215 SAY (STR0081) SIZE 200,8 OF oDlgAnalit PIXEL COLOR CLR_BLACK // Passaram para Etapas posteriores

ACTIVATE DIALOG oDlgAnalit ON INIT EnchoiceBar(oDlgAnalit,{|| oDlgAnalit:End() },{|| oDlgAnalit:End() },,)
//
Return

/*/{Protheus.doc} VCC680011_F7
Habilita / Desabilita tecla F7 ( Funil dos Interesses de Veiculos )

@author Andre Luis Almeida
@since 23/01/2019
/*/
Static Function VCC680011_F7( lHabilita )
If !IsInCallStack('OFIA120') // NAO for Oportunidades Agrupadas
	If lHabilita
		SetKey(VK_F7,{|| VCC680FUNIL() })
	Else
		SetKey(VK_F7, Nil )
	EndIf
EndIf
Return