// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 31     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "VEIVC170.CH" 

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006886_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVC170 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 14/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Painel de Vendas de Veiculos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVC170(cPAREmp,aPAREmp,dPARDtI,dPARDtF,nPARTpF)
Local aFWArrFilAtu := FWArrFilAtu()
Local oFilHelp   := DMS_FilialHelper():New()
Local aSM0       := oFilHelp:GetAllFilPermis(.f.)
Local cBkpFilAnt := cFilAnt
Local lDClik     := .f.
Local aObjects   := {}, aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCont      := 0
Private lTIPMOV	 := ( VV0->(FieldPos("VV0_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )
Private aMes     := {} // MES
Private aDia     := {} // DIA
Private aMod     := {} // GRUPO MODELO
Private aMedM    := {} // Valor Medio MES
Private aMedG    := {} // Valor Medio GRUPO MODELO
Private aVetDev  := {} // Devolucoes
Private lMarcar  := .f.
Private nOpcNeg  := 2
Private aVetEmp  := {}
Private aEmpr    := {} // Empresas Consolidadas
Private cEmpr    := "" // Nome da Empresa
Private cTitulo  := ""
Private cFiltro  := ""
Private nAcresFin := 0
Private dDatIni  := ctod("01/"+strzero(month(dDataBase),2)+"/"+right(strzero(year(dDataBase)-1,4),2))
Private dDatFin  := dDataBase
Private cComboV  := ""
Private nTipFil  := 1
Private aEmpTot  := {}
Private cFilTot  := ""  
Private nOpcao   := "0"
Private nOpcao1  := "0"
Private cGruVei  := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Default dPARDtI  := dDatIni
Default dPARDtF  := dDatFin
Default cPAREmp  := ""
Default aPAREmp  := aEmpr
Default nPARTpF  := 1
nTipFil := nPARTpF // Tipo de Filial
DEFINE FONT oTitTela NAME "Arial" SIZE 10,13 BOLD
DbSelectArea("VV9")
// Levanta Todas Filiais //
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aAdd( aEmpTot , { cFilAnt , xFilial("VV9") })
	cFilTot += "'"+xFilial("VV9")+"',"
Next
If len(cFilTot) > 0
	cFilTot := left(cFilTot,len(cFilTot)-1)
EndIf
cFilAnt := cBkpFilAnt
aEmpr := aPAREmp
If !Empty(cPAREmp)
	cEmpr := " - "+STR0005+" " // Consolidado
	aEmpr := FS_FILIAIS() // Levantamento das Filiais
	If len(aEmpr) == 0
		MsgAlert(STR0003,STR0002) // Nao existem dados para esta Consulta ! / Atencao
		Return
	EndIf
Else
	aAdd(aEmpr,{ cFilAnt , aFWArrFilAtu[SM0_FILIAL] })
EndIf
If len(aEmpr) == 1 .and. (aEmpr[1,1]==cFilAnt)
	cEmpr := " - "+Alltrim(FWFilialName())+" ( "+cFilAnt+" )"
EndIf
dDatIni := dPARDtI
dDatFin := dPARDtF
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  10 , .T. , .F. } ) // Filtro no topo
aAdd( aObjects, { 0 , 130 , .T. , .F. } ) // ListBox mes
aAdd( aObjects, { 0 ,  29 , .T. , .F. } ) // ListBox Media Mes
aAdd( aObjects, { 0 ,  30 , .T. , .T. } ) // ListBox dias
aPos := MsObjSize( aInfo, aObjects )
Processa( {|| FS_FILTRAMES(0) } )
MENU oMTpGVC170 POPUP  // Menu Tipo de Grafico
	MENUITEM STR0041 Action (FS_GRAFICO("1",oLbMes:nAt)) // Valor
	MENUITEM STR0047 Action (FS_GRAFICO("2",oLbMes:nAt)) // Qtd.Veic
ENDMENU
MENU oMTpRVC170 POPUP  // Menu Tipo de Grafico
	MENUITEM STR0018 Action (FS_RANKING("1",oLbMes:nAt)) // Propostas Aprovadas
	MENUITEM STR0016 Action (FS_RANKING("2",oLbMes:nAt)) // Vlr Total das Vendas
	MENUITEM STR0017 Action (FS_RANKING("3",oLbMes:nAt)) // Vlr Venda Direta
	MENUITEM STR0063 Action (FS_RANKING("4",oLbMes:nAt)) // Vlr. Vendas + Venda Direta
ENDMENU

MENU oMTpDVC170 POPUP  // Menu Tipo de Grafico
	MENUITEM STR0056 Action (FS_FILTRAMES(1,"1")) // "Devolução das Vendas no Período"
	MENUITEM STR0057 Action (FS_FILTRAMES(1,"2")) // "Todas das Devoluções no Período"
	MENUITEM STR0058 Action (FS_FILTRAMES(1,"3")) // "s/ Devolução"
ENDMENU
DEFINE MSDIALOG oNegVei FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta Gerencial de Veiculos
	oNegVei:lEscClose := .F.
	@ aPos[1,1]+001,aPos[1,2]+005 SAY STR0006 SIZE 30,08 OF oNegVei PIXEL COLOR CLR_BLUE // Periodo:
	@ aPos[1,1]+000,aPos[1,2]+030 MSGET oDatIni VAR dDatIni VALID( dDatIni <= dDataBase ) SIZE 40,08 OF oNegVei PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+001,aPos[1,2]+076 SAY STR0007 SIZE 10,08 OF oNegVei PIXEL COLOR CLR_BLUE // ate
	@ aPos[1,1]+000,aPos[1,2]+090 MSGET oDatFin VAR dDatFin VALID( dDatIni <= dDatFin ) SIZE 40,08 OF oNegVei PIXEL COLOR CLR_BLUE
	@ aPos[1,1],aPos[1,2]+135 BUTTON oOk PROMPT STR0008 OF oNegVei SIZE 18,09 PIXEL ACTION Processa( {|| FS_FILTRAMES(1) } ) // OK
	@ aPos[1,1],aPos[1,4]-320 BUTTON oTipRank PROMPT STR0051 OF oNegVei SIZE 70,10 PIXEL ACTION FS_TIPRANK( oTipRank , aPos[1,1] , 10 , oMTpRVC170 ) // Ranking Vendedores
	@ aPos[1,1],aPos[1,4]-245 BUTTON oTipGraf PROMPT STR0045 OF oNegVei SIZE 45,10 PIXEL ACTION FS_TIPGRAF( oTipGraf , aPos[1,1] , 10 , oMTpGVC170 ) // Tipo Grafico
	@ aPos[1,1],aPos[1,4]-195 BUTTON oFilx PROMPT STR0049 OF oNegVei SIZE 45,10 PIXEL ACTION FS_FILxFIL(aMes[oLbMes:nAt,1]) // Filial x Filiais
	@ aPos[1,1],aPos[1,4]-145 BUTTON oTipDev PROMPT STR0059 OF oNegVei SIZE 45,10 PIXEL ACTION FS_DEVOLU( oTipDev , aPos[1,1] , 10 , oMTpDVC170 ) // Tipo Devolucao
	@ aPos[1,1],aPos[1,4]-095 BUTTON oEmpr PROMPT UPPER(STR0009) OF oNegVei SIZE 45,10 PIXEL ACTION (lDClik:=.t.,oNegVei:End()) // Filiais
	@ aPos[1,1],aPos[1,4]-045 BUTTON oGrpSair PROMPT STR0010 OF oNegVei SIZE 45,10 PIXEL ACTION oNegVei:End() // SAIR
	@ aPos[2,1],aPos[2,2] LISTBOX oLbMes FIELDS HEADER (STR0011),; // Ano / Mes
														(STR0012+" ("+STR0047+")"),; // Novos Prop.Aprovadas (Qtd.Veic)
														(STR0013+" ("+STR0047+")"),; // Novos Vlr Vendas (Qtd.Veic)
														(STR0014+" ("+STR0047+")"),; // Usados Prop.Aprovadas (Qtd.Veic)
														(STR0015+" ("+STR0047+")"),; // Usados Vlr Vendas (Qtd.Veic)
														(STR0016+" ("+STR0047+")"),; // Vlr Total das Vendas (Qtd.Veic)
														(STR0017+" ("+STR0047+")") ; // Vlr Venda Direta (Qtd.Veic)
														COLSIZES 50,90,90,90,90,90,90 SIZE aPos[2,4]-2,aPos[2,3]-15 OF oNegVei PIXEL ON DBLCLICK Processa( {|| FS_ANALIT(aMes[oLbMes:nAt,1],1) } ) ON CHANGE FS_FILTRADIA(aMes[oLbMes:nAt,1],aMes[oLbMes:nAt,2])
	oLbMes:SetArray(aMes)
	oLbMes:bLine := { || { aMes[oLbMes:nAt,2] ,;
     	                	IIf(aMes[oLbMes:nAt,04]<>0,FG_AlinVlrs(Transform(aMes[oLbMes:nAt,03],"@E 9999,999,999.99"))+" ("+Transform(aMes[oLbMes:nAt,04],"@E 999999")+") "+FG_AlinVlrs(Transform((aMes[oLbMes:nAt,03]/aMes[1,03])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aMes[oLbMes:nAt,06]<>0,FG_AlinVlrs(Transform(aMes[oLbMes:nAt,05],"@E 9999,999,999.99"))+" ("+Transform(aMes[oLbMes:nAt,06],"@E 999999")+") "+FG_AlinVlrs(Transform((aMes[oLbMes:nAt,05]/aMes[1,05])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aMes[oLbMes:nAt,08]<>0,FG_AlinVlrs(Transform(aMes[oLbMes:nAt,07],"@E 9999,999,999.99"))+" ("+Transform(aMes[oLbMes:nAt,08],"@E 999999")+") "+FG_AlinVlrs(Transform((aMes[oLbMes:nAt,07]/aMes[1,07])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aMes[oLbMes:nAt,10]<>0,FG_AlinVlrs(Transform(aMes[oLbMes:nAt,09],"@E 9999,999,999.99"))+" ("+Transform(aMes[oLbMes:nAt,10],"@E 999999")+") "+FG_AlinVlrs(Transform((aMes[oLbMes:nAt,09]/aMes[1,09])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aMes[oLbMes:nAt,11]<>0,FG_AlinVlrs(Transform(aMes[oLbMes:nAt,11],"@E 9999,999,999.99"))+" ("+Transform(aMes[oLbMes:nAt,12],"@E 999999")+") "+FG_AlinVlrs(Transform((aMes[oLbMes:nAt,11]/aMes[1,11])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aMes[oLbMes:nAt,14]<>0,FG_AlinVlrs(Transform(aMes[oLbMes:nAt,13],"@E 9999,999,999.99"))+" ("+Transform(aMes[oLbMes:nAt,14],"@E 999999")+") "+FG_AlinVlrs(Transform((aMes[oLbMes:nAt,13]/aMes[1,13])*100,"@E 999")+"%"),"") }}
	@ aPos[3,1],aPos[3,2] LISTBOX oLbMedM FIELDS HEADER (STR0048),; // Valor Medio
														(STR0012),; // Novos Prop.Aprovadas
														(STR0013),; // Novos Vlr Vendas
														(STR0014),; // Usados Prop.Aprovadas
														(STR0015),; // Usados Vlr Vendas
														(STR0016),; // Vlr Total das Vendas
														(STR0017) ; // Vlr Venda Direta
														COLSIZES 50,90,90,90,90,90,90 SIZE aPos[3,4]-2,30 OF oNegVei PIXEL WHEN .f.
	oLbMedM:SetArray(aMedM)
	oLbMedM:bLine := { || { aMedM[oLbMedM:nAt,1] ,;
     	                	FG_AlinVlrs(Transform(aMedM[oLbMedM:nAt,02],"@EZ 9999,999,999.99")) ,;
     	                	FG_AlinVlrs(Transform(aMedM[oLbMedM:nAt,03],"@EZ 9999,999,999.99")) ,;
     	                	FG_AlinVlrs(Transform(aMedM[oLbMedM:nAt,04],"@EZ 9999,999,999.99")) ,;
     	                	FG_AlinVlrs(Transform(aMedM[oLbMedM:nAt,05],"@EZ 9999,999,999.99")) ,;
     	                	FG_AlinVlrs(Transform(aMedM[oLbMedM:nAt,06],"@EZ 9999,999,999.99")) ,;
     	                	FG_AlinVlrs(Transform(aMedM[oLbMedM:nAt,07],"@EZ 9999,999,999.99")) }}
	@ aPos[4,1],aPos[4,2] LISTBOX oLbDia FIELDS HEADER (STR0028),; // Dia
														(STR0012+" ("+STR0047+")"),; // Novos Prop.Aprovadas (Qtd.Veic)
														(STR0013+" ("+STR0047+")"),; // Novos Vlr Vendas (Qtd.Veic)
														(STR0014+" ("+STR0047+")"),; // Usados Prop.Aprovadas (Qtd.Veic)
														(STR0015+" ("+STR0047+")"),; // Usados Vlr Vendas (Qtd.Veic)
														(STR0016+" ("+STR0047+")"),; // Vlr Total das Vendas (Qtd.Veic)
														(STR0017+" ("+STR0047+")") ; // Vlr Venda Direta (Qtd.Veic)
														COLSIZES 50,90,90,90,90,90,90 SIZE aPos[4,4]-2,aPos[4,3]-aPos[3,3]-2 OF oNegVei PIXEL ON DBLCLICK Processa( {|| FS_ANALIT(aDia[oLbDia:nAt,1],2) } )
	oLbDia:SetArray(aDia)
	oLbDia:bLine := { || { aDia[oLbDia:nAt,2] ,;
     	                	IIf(aDia[oLbDia:nAt,04]<>0,FG_AlinVlrs(Transform(aDia[oLbDia:nAt,03],"@E 9999,999,999.99"))+" ("+Transform(aDia[oLbDia:nAt,04],"@E 999999")+") "+FG_AlinVlrs(Transform((aDia[oLbDia:nAt,03]/aMes[oLbMes:nAt,03])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aDia[oLbDia:nAt,06]<>0,FG_AlinVlrs(Transform(aDia[oLbDia:nAt,05],"@E 9999,999,999.99"))+" ("+Transform(aDia[oLbDia:nAt,06],"@E 999999")+") "+FG_AlinVlrs(Transform((aDia[oLbDia:nAt,05]/aMes[oLbMes:nAt,05])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aDia[oLbDia:nAt,08]<>0,FG_AlinVlrs(Transform(aDia[oLbDia:nAt,07],"@E 9999,999,999.99"))+" ("+Transform(aDia[oLbDia:nAt,08],"@E 999999")+") "+FG_AlinVlrs(Transform((aDia[oLbDia:nAt,07]/aMes[oLbMes:nAt,07])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aDia[oLbDia:nAt,10]<>0,FG_AlinVlrs(Transform(aDia[oLbDia:nAt,09],"@E 9999,999,999.99"))+" ("+Transform(aDia[oLbDia:nAt,10],"@E 999999")+") "+FG_AlinVlrs(Transform((aDia[oLbDia:nAt,09]/aMes[oLbMes:nAt,09])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aDia[oLbDia:nAt,11]<>0,FG_AlinVlrs(Transform(aDia[oLbDia:nAt,11],"@E 9999,999,999.99"))+" ("+Transform(aDia[oLbDia:nAt,12],"@E 999999")+") "+FG_AlinVlrs(Transform((aDia[oLbDia:nAt,11]/aMes[oLbMes:nAt,11])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aDia[oLbDia:nAt,14]<>0,FG_AlinVlrs(Transform(aDia[oLbDia:nAt,13],"@E 9999,999,999.99"))+" ("+Transform(aDia[oLbDia:nAt,14],"@E 999999")+") "+FG_AlinVlrs(Transform((aDia[oLbDia:nAt,13]/aMes[oLbMes:nAt,13])*100,"@E 999")+"%"),"") }}
ACTIVATE MSDIALOG oNegVei
If lDClik
	VEIVC170(cEmpr,aEmpr,dDatIni,dDatFin,nTipFil)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILTRAMES³ Autor ³  Andre Luis Almeida ³ Data ³ 14/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra Periodo MESES                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAMES(nTp,nOpcao)
Local cQuery   := ""
Local cQAlVV09 := "SQLVV09" // VV0 / VV9
Local cFilSALVA:= cFilAnt
Local nValor   := 0
Local nEmpr    := 0
Local nLin     := 0
Local nCol     := 0
Local ni       := 0
Local nt       := ( dDatFin - dDatIni ) + 1
Local dDtRef   := dDatIni
Local cMudaMes := ""
Default nOpcao := "0"
nOpcao1 := nOpcao 
aMes := {}
aAdd( aMes, { "******" , STR0029 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } )  // TOTAL PERIODO
For ni := nt to 1 step -1
	dDtRef := dDatIni+(ni-1)
	If cMudaMes <> left(dtos(dDtRef),6)
		cMudaMes := left(dtos(dDtRef),6)
		aAdd( aMes, { cMudaMes , left(cMudaMes,4)+" "+FG_CMONTH(dDtRef) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } ) // ANO MES
	EndIf
Next
ProcRegua(len(aEmpr)+2)
IncProc(STR0020) // Levantando...
For nEmpr := 1 to len(aEmpr)
	IncProc(STR0020) // Levantando...
	cFilAnt := aEmpr[nEmpr,1]
	cQuery := "SELECT VV9.VV9_STATUS , VV0.VV0_DATMOV , VV0.VV0_TIPFAT , COUNT(*) QTD , SUM(VVA.VVA_VALMOV) VALOR , SUM(SD2.D2_TOTAL) COMPLEMENTO "
	cQuery += "FROM "+RetSqlName("VV0")+" VV0 "
	cQuery += "JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.VV9_STATUS IN ('F','T','O','L') AND VV9.D_E_L_E_T_=' ' ) "
	cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VVA.VVA_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("SD2")+" SD2 ON ( SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_NFORI=VV0.VV0_NUMNFI AND SD2.D2_SERIORI=VV0.VV0_SERNFI AND SD2.D2_COD=SB1.B1_COD AND SD2.D2_TIPO='C' AND SD2.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE "
	If nTipFil == 1 // Filial do Arquivo
		cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
	Else
		cQuery += "( "
		cQuery += "( VV0.VV0_FILIAL IN ("+cFilTot+") AND VV9.VV9_FILNEG='"+xFilial("VV9")+"' ) "
		cQuery += "OR "
		cQuery += "( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV9.VV9_FILNEG=' ' ) "
		cQuery += ") AND "
	EndIf
	cQuery += "VV0.VV0_OPEMOV IN (' ','0','8') AND "
	cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
	cQuery += "VV0.VV0_TIPFAT IN ('0','1','2') AND "
	If lTIPMOV
		cQuery += "VV0.VV0_TIPMOV IN (' ','0') AND  "
	EndIf
	cQuery += "VV0.D_E_L_E_T_=' ' "
	cQuery += "GROUP BY VV9.VV9_STATUS , VV0.VV0_DATMOV , VV0.VV0_TIPFAT , VVA.VVA_VALMOV "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )
	Do While !( cQAlVV09 )->( Eof() )
		nLin := aScan(aMes,{|x| x[1] == left(( cQAlVV09 )->( VV0_DATMOV ),6) })
		If ( cQAlVV09 )->( VV0_TIPFAT ) == "2" // Faturamento Direto -> Vlr Venda Direta (Qtd.Veic) - 13/14
			nCol := 13
		Else
			If ( cQAlVV09 )->( VV9_STATUS ) $ "F/T" // Finalizado
				If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Normal Novo -> FT Novos Vlr Vendas (Qtd.Veic) - 5/6
					nCol := 5
				Else//If ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Normal Usado -> FT Usados Vlr Vendas (Qtd.Veic) - 9/10
					nCol := 9
				EndIf
			ElseIf ( cQAlVV09 )->( VV9_STATUS ) $ "O/L" // Pre-Aprovado / Aprovado
				If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Normal Novo -> OL Novos Propostas Aprovadas (Qtd.Veic) - 3/4
			    	nCol := 3
				Else//If ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Normal Usado -> OL Usados Propostas Aprovadas (Qtd.Veic) - 7/8
					nCol := 7
				EndIf
			EndIf
		EndIf
		nValor := ( cQAlVV09 )->( VALOR ) + ( cQAlVV09 )->( COMPLEMENTO )
		nQtd := ( cQAlVV09 )->( QTD ) 
		aMes[1,nCol] += nValor
		aMes[1,nCol+1]+= nQtd
		aMes[nLin,nCol] += nValor
		aMes[nLin,nCol+1]+= nQtd
		If nCol == 5 .or. nCol == 9 // Totalizar Vendas qdo Venda de Novos ou Usados -> FT Vlr Total das Vendas (Qtd.Veic) - 11/12
			nCol := 11
			aMes[1,nCol] += nValor
			aMes[1,nCol+1]+= nQtd
			aMes[nLin,nCol] += nValor
			aMes[nLin,nCol+1]+= nQtd
		EndIf
	   	( cQAlVV09 )->( DbSkip() )
	EndDo
	( cQAlVV09 )->( dbCloseArea() )
	if nOpcao1 <> "0" .and. nOpcao1 <> "3"
		// Devolucoes de venda 
		cQuery := "SELECT VV9.VV9_STATUS , SD1.D1_EMISSAO ,  VV0.VV0_DATMOV , VV0.VV0_TIPFAT , VVA.VVA_VALMOV "
		cQuery += "FROM "+RetSqlName("VV0")+" VV0 "
		cQuery += "JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.VV9_STATUS IN ('F','T') AND VV9.D_E_L_E_T_=' ' ) "
		cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' ) "
		cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VVA.VVA_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
		cQuery += "JOIN "+RetSqlName("SD1")+" SD1 ON ( SD1.D1_FILIAL=VV0.VV0_FILIAL AND SD1.D1_NFORI=VV0.VV0_NUMNFI AND SD1.D1_SERIORI=VV0.VV0_SERNFI AND SD1.D1_COD=SB1.B1_COD AND SD1.D1_TIPO='D' AND "
		if nOpcao1 == "2"
			cQuery += "SD1.D1_EMISSAO>='"+dtos(dDatIni)+"' AND SD1.D1_EMISSAO<='"+dtos(dDatFin)+"' AND "
		Endif
		cQuery += "SD1.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE "
		If nTipFil == 1 // Filial do Arquivo
			cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
		Else	
			cQuery += "( "
			cQuery += "( VV0.VV0_FILIAL IN ("+cFilTot+") AND VV9.VV9_FILNEG='"+xFilial("VV9")+"' ) "
			cQuery += "OR "
			cQuery += "( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV9.VV9_FILNEG=' ' ) "
			cQuery += ") AND "
		EndIf
		cQuery += "VV0.VV0_OPEMOV IN (' ','0','8') AND " 
		if nOpcao1 <> "2"
			cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
		Endif	
		cQuery += "VV0.VV0_TIPFAT IN ('0','1','2') AND "
		If lTIPMOV
			cQuery += "VV0.VV0_TIPMOV IN (' ','0') AND "
		EndIf
		cQuery += "VV0.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )
		Do While !( cQAlVV09 )->( Eof() )
			If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Normal Novo -> FT Novos Vlr Vendas (Qtd.Veic) - 5/6
				nCol := 5
			Else//If ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Normal Usado -> FT Usados Vlr Vendas (Qtd.Veic) - 9/10
				nCol := 9
			EndIf
			if nOpcao1 <> "2"
				nLin := aScan(aMes,{|x| x[1] == left(( cQAlVV09 )->( VV0_DATMOV ),6) })
			Else
				nLin := aScan(aMes,{|x| x[1] == left(( cQAlVV09 )->( D1_EMISSAO ),6) })
			Endif	
			nValor := ( cQAlVV09 )->( VVA_VALMOV )
			aMes[1,nCol] -= nValor
			aMes[1,nCol+1]--
			aMes[nLin,nCol] -= nValor
			aMes[nLin,nCol+1]--
			nCol := 11
			aMes[1,nCol] -= nValor
			aMes[1,nCol+1]--
			aMes[nLin,nCol] -= nValor
			aMes[nLin,nCol+1]--
	   		( cQAlVV09 )->( DbSkip() )
		EndDo
		( cQAlVV09 )->( dbCloseArea() )
    Endif
Next
IncProc(STR0020) // Levantando...
cFilAnt := cFilSALVA
If nTp > 0
	oLbMes:nAt := 1
	oLbMes:SetArray(aMes)
	oLbMes:bLine := { || { aMes[oLbMes:nAt,2] ,;
     	                	IIf(aMes[oLbMes:nAt,04]<>0,FG_AlinVlrs(Transform(aMes[oLbMes:nAt,03],"@E 9999,999,999.99"))+" ("+Transform(aMes[oLbMes:nAt,04],"@E 999999")+") "+FG_AlinVlrs(Transform((aMes[oLbMes:nAt,03]/aMes[1,03])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aMes[oLbMes:nAt,06]<>0,FG_AlinVlrs(Transform(aMes[oLbMes:nAt,05],"@E 9999,999,999.99"))+" ("+Transform(aMes[oLbMes:nAt,06],"@E 999999")+") "+FG_AlinVlrs(Transform((aMes[oLbMes:nAt,05]/aMes[1,05])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aMes[oLbMes:nAt,08]<>0,FG_AlinVlrs(Transform(aMes[oLbMes:nAt,07],"@E 9999,999,999.99"))+" ("+Transform(aMes[oLbMes:nAt,08],"@E 999999")+") "+FG_AlinVlrs(Transform((aMes[oLbMes:nAt,07]/aMes[1,07])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aMes[oLbMes:nAt,10]<>0,FG_AlinVlrs(Transform(aMes[oLbMes:nAt,09],"@E 9999,999,999.99"))+" ("+Transform(aMes[oLbMes:nAt,10],"@E 999999")+") "+FG_AlinVlrs(Transform((aMes[oLbMes:nAt,09]/aMes[1,09])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aMes[oLbMes:nAt,11]<>0,FG_AlinVlrs(Transform(aMes[oLbMes:nAt,11],"@E 9999,999,999.99"))+" ("+Transform(aMes[oLbMes:nAt,12],"@E 999999")+") "+FG_AlinVlrs(Transform((aMes[oLbMes:nAt,11]/aMes[1,11])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aMes[oLbMes:nAt,14]<>0,FG_AlinVlrs(Transform(aMes[oLbMes:nAt,13],"@E 9999,999,999.99"))+" ("+Transform(aMes[oLbMes:nAt,14],"@E 999999")+") "+FG_AlinVlrs(Transform((aMes[oLbMes:nAt,13]/aMes[1,13])*100,"@E 999")+"%"),"") }}
	oLbMes:Refresh()
	oLbMes:SetFocus()
	FS_FILTRADIA(aMes[oLbMes:nAt,1],aMes[oLbMes:nAt,2])
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILTRADIA| Autor ³  Andre Luis Almeida ³ Data ³ 14/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra DIAS atraves do MES SELECIONADO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRADIA(cAnoMes,cTitListBox)
Local cQuery   := ""
Local cQAlVV09 := "SQLVV09" // VV0 / VV9
Local cFilSALVA:= cFilAnt
Local dDtIMes  := dDataBase
Local dDtFMes  := dDataBase
Local dDtRef   := dDataBase
Local aVetAux  := {}
Local ni       := 0
Local nt       := 0
Local nValor   := 0
Local nEmpr    := 0
Local nLin     := 0
Local nCol     := 0
aDia := {}
If cAnoMes <> "******"
	dDtIMes := ctod("01/"+right(cAnoMes,2)+"/"+right(left(cAnoMes,4),2)) // 1o.Dia do Mes
	dDtFMes := ctod("25/"+right(cAnoMes,2)+"/"+right(left(cAnoMes,4),2))+10
	dDtFMes := ( dDtFMes - day(dDtFMes) ) // Ultimo Dia do Mes
	nt := ( dDtFMes - dDtIMes ) + 1
	For ni := 1 to nt
		dDtRef := dDtIMes+(ni-1)
		aAdd( aDia, { dtos(dDtRef) , strzero(day(dDtRef),2)+" - "+DIASEMANA(dDtRef) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 } ) // DIA
	Next
	For nEmpr := 1 to len(aEmpr)
		cFilAnt := aEmpr[nEmpr,1]
		cQuery := "SELECT VV9.VV9_STATUS , VV0.VV0_DATMOV , VV0.VV0_TIPFAT , COUNT(*) QTD , SUM(VVA.VVA_VALMOV) VALOR , SUM(SD2.D2_TOTAL) COMPLEMENTO "
		cQuery += "FROM "+RetSqlName("VV0")+" VV0 "
		cQuery += "JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.VV9_STATUS IN ('F','T','O','L') AND VV9.D_E_L_E_T_=' ' ) "
		cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VVA.VVA_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSqlName("SD2")+" SD2 ON ( SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_NFORI=VV0.VV0_NUMNFI AND SD2.D2_SERIORI=VV0.VV0_SERNFI AND SD2.D2_COD=SB1.B1_COD AND SD2.D2_TIPO='C' AND SD2.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE "
		If nTipFil == 1 // Filial do Arquivo
			cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
		Else
			cQuery += "( "
			cQuery += "( VV0.VV0_FILIAL IN ("+cFilTot+") AND VV9.VV9_FILNEG='"+xFilial("VV9")+"' ) "
			cQuery += "OR "
			cQuery += "( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV9.VV9_FILNEG=' ' ) "
			cQuery += ") AND "
		EndIf
		cQuery += "VV0.VV0_OPEMOV IN (' ','0','8') AND "
		If left(dtos(dDatIni),6) == cAnoMes // Se for o ANO MES da Data Inicial, utilizar ela.
			cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND "
		Else
			cQuery += "VV0.VV0_DATMOV>='"+dtos(dDtIMes)+"' AND "
		EndIf
		If left(dtos(dDatFin),6) == cAnoMes // Se for o ANO MES da Data Final, utilizar ela.
			cQuery += "VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
		Else
			cQuery += "VV0.VV0_DATMOV<='"+dtos(dDtFMes)+"' AND "
		EndIf
		cQuery += "VV0.VV0_TIPFAT IN ('0','1','2') AND "
		If lTIPMOV
			cQuery += "VV0.VV0_TIPMOV IN (' ','0') AND "
		EndIf
		cQuery += "VV0.D_E_L_E_T_=' ' "
		cQuery += "GROUP BY VV9.VV9_STATUS , VV0.VV0_DATMOV , VV0.VV0_TIPFAT , VVA.VVA_VALMOV "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )
		Do While !( cQAlVV09 )->( Eof() )
			nLin := day(stod(( cQAlVV09 )->( VV0_DATMOV )))
			If ( cQAlVV09 )->( VV0_TIPFAT ) == "2" // Faturamento Direto -> Vlr Venda Direta (Qtd.Veic) - 13/14
				nCol := 13
			Else
				If ( cQAlVV09 )->( VV9_STATUS ) $ "F/T" // Finalizado
					If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Normal Novo -> FT Novos Vlr Vendas (Qtd.Veic) - 5/6
						nCol := 5
					Else//If ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Normal Usado -> FT Usados Vlr Vendas (Qtd.Veic) - 9/10
						nCol := 9
					EndIf
				ElseIf ( cQAlVV09 )->( VV9_STATUS ) $ "O/L" // Pre-Aprovado / Aprovado
					If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Normal Novo -> OL Novos Propostas Aprovadas (Qtd.Veic) - 3/4
				    	nCol := 3
					Else//If ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Normal Usado -> OL Usados Propostas Aprovadas (Qtd.Veic) - 7/8
						nCol := 7
					EndIf
				EndIf
			EndIf
			nValor := ( cQAlVV09 )->( VALOR ) + ( cQAlVV09 )->( COMPLEMENTO )
			nQtd   := ( cQAlVV09 )->( QTD ) 
			aDia[nLin,nCol] += nValor
			aDia[nLin,nCol+1]+= nQtd
			If nCol == 5 .or. nCol == 9 // Totalizar Vendas qdo Venda de Novos ou Usados -> FT Vlr Total das Vendas (Qtd.Veic) - 11/12
				nCol := 11
				aDia[nLin,nCol] += nValor
				aDia[nLin,nCol+1]+= nQtd
			EndIf
		   	( cQAlVV09 )->( DbSkip() )
		EndDo
		( cQAlVV09 )->( dbCloseArea() )

		If nOpcao1 <> "0" .and. nOpcao1 <> "3"
			// Devolucao de venda
			cQuery := "SELECT VV9.VV9_STATUS , SD1.D1_EMISSAO , VV0.VV0_DATMOV , VV0.VV0_TIPFAT , VVA.VVA_VALMOV "
			cQuery += "FROM "+RetSqlName("VV0")+" VV0 "
			cQuery += "JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.VV9_STATUS IN ('F','T') AND VV9.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VVA.VVA_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+RetSqlName("SD1")+" SD1 ON ( SD1.D1_FILIAL=VV0.VV0_FILIAL AND SD1.D1_NFORI=VV0.VV0_NUMNFI AND SD1.D1_SERIORI=VV0.VV0_SERNFI AND SD1.D1_COD=SB1.B1_COD AND SD1.D1_TIPO='D' AND "
			if nOpcao1 == "2"
				If left(dtos(dDatIni),6) == cAnoMes // Se for o ANO MES da Data Inicial, utilizar ela.
					cQuery += "SD1.D1_EMISSAO>='"+dtos(dDatIni)+"' AND "
				Else
					cQuery += "SD1.D1_EMISSAO>='"+dtos(dDtIMes)+"' AND "
				EndIf
				If left(dtos(dDatFin),6) == cAnoMes // Se for o ANO MES da Data Final, utilizar ela.
					cQuery += "SD1.D1_EMISSAO<='"+dtos(dDatFin)+"' AND "
				Else
					cQuery += "SD1.D1_EMISSAO<='"+dtos(dDtFMes)+"' AND "
				EndIf
			Endif
			cQuery += "SD1.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE "
			If nTipFil == 1 // Filial do Arquivo
				cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
			Else	
				cQuery += "( "
				cQuery += "( VV0.VV0_FILIAL IN ("+cFilTot+") AND VV9.VV9_FILNEG='"+xFilial("VV9")+"' ) "
				cQuery += "OR "
				cQuery += "( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV9.VV9_FILNEG=' ' ) "
				cQuery += ") AND "
			EndIf
			cQuery += "VV0.VV0_OPEMOV IN (' ','0','8') AND "
			if nOpcao1 <> "2"
				If left(dtos(dDatIni),6) == cAnoMes // Se for o ANO MES da Data Inicial, utilizar ela.
					cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND "
				Else
					cQuery += "VV0.VV0_DATMOV>='"+dtos(dDtIMes)+"' AND "
				EndIf
				If left(dtos(dDatFin),6) == cAnoMes // Se for o ANO MES da Data Final, utilizar ela.
					cQuery += "VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
				Else
					cQuery += "VV0.VV0_DATMOV<='"+dtos(dDtFMes)+"' AND "
				EndIf
            Endif
			cQuery += "VV0.VV0_TIPFAT IN ('0','1','2') AND "
			If lTIPMOV
				cQuery += "VV0.VV0_TIPMOV IN (' ','0') AND "
			EndIf
			cQuery += "VV0.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )
			Do While !( cQAlVV09 )->( Eof() )
				if nOpcao1 <> "2"
					nLin := day(stod(( cQAlVV09 )->( VV0_DATMOV )))
				Else
					nLin := day(stod(( cQAlVV09 )->( D1_EMISSAO )))
				Endif	
				If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Normal Novo -> FT Novos Vlr Vendas (Qtd.Veic) - 5/6
					nCol := 5
				Else//If ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Normal Usado -> FT Usados Vlr Vendas (Qtd.Veic) - 9/10
					nCol := 9
				EndIf
				nValor := ( cQAlVV09 )->( VVA_VALMOV )
				aDia[nLin,nCol] -= nValor
				aDia[nLin,nCol+1]--
				If nCol == 5 .or. nCol == 9 // Totalizar Vendas qdo Venda de Novos ou Usados -> FT Vlr Total das Vendas (Qtd.Veic) - 11/12
					nCol := 11
					aDia[nLin,nCol] -= nValor
					aDia[nLin,nCol+1]--
				EndIf
			   	( cQAlVV09 )->( DbSkip() )
			EndDo
			( cQAlVV09 )->( dbCloseArea() )
    	Endif
	Next
EndIf
cFilAnt := cFilSALVA
aVetAux := {} // Deixar apenas registros (linha listbox) com valores
For ni := 1 to len(aDia)
	If ( aDia[ni,04]+aDia[ni,06]+aDia[ni,08]+aDia[ni,10]+aDia[ni,12]+aDia[ni,14] ) <> 0
		aAdd(aVetAux,{ aDia[ni,01] , aDia[ni,02] , aDia[ni,03] , aDia[ni,04] , aDia[ni,05] , aDia[ni,06] , aDia[ni,07] , aDia[ni,08] , aDia[ni,09] , aDia[ni,10] , aDia[ni,11] , aDia[ni,12] , aDia[ni,13] , aDia[ni,14] })
	EndIf
Next
aDia := aClone(aVetAux)
FS_MEDIA("M") // Valor Medio MES
If len(aDia) <= 0
	aAdd( aDia, { aMes[oLbMes:nAt,1] , aMes[oLbMes:nAt,2] , aMes[oLbMes:nAt,3] , aMes[oLbMes:nAt,4] , aMes[oLbMes:nAt,5] , aMes[oLbMes:nAt,6] , aMes[oLbMes:nAt,7] , aMes[oLbMes:nAt,8] , aMes[oLbMes:nAt,9] , aMes[oLbMes:nAt,10] , aMes[oLbMes:nAt,11] , aMes[oLbMes:nAt,12] , aMes[oLbMes:nAt,13] , aMes[oLbMes:nAt,14] } ) // TOTAL PERIODO
EndIf
oLbDia:SetArray(aDia)
oLbDia:bLine := { || { aDia[oLbDia:nAt,2] ,;
     	                	IIf(aDia[oLbDia:nAt,04]<>0,FG_AlinVlrs(Transform(aDia[oLbDia:nAt,03],"@E 9999,999,999.99"))+" ("+Transform(aDia[oLbDia:nAt,04],"@E 999999")+") "+FG_AlinVlrs(Transform((aDia[oLbDia:nAt,03]/aMes[oLbMes:nAt,03])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aDia[oLbDia:nAt,06]<>0,FG_AlinVlrs(Transform(aDia[oLbDia:nAt,05],"@E 9999,999,999.99"))+" ("+Transform(aDia[oLbDia:nAt,06],"@E 999999")+") "+FG_AlinVlrs(Transform((aDia[oLbDia:nAt,05]/aMes[oLbMes:nAt,05])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aDia[oLbDia:nAt,08]<>0,FG_AlinVlrs(Transform(aDia[oLbDia:nAt,07],"@E 9999,999,999.99"))+" ("+Transform(aDia[oLbDia:nAt,08],"@E 999999")+") "+FG_AlinVlrs(Transform((aDia[oLbDia:nAt,07]/aMes[oLbMes:nAt,07])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aDia[oLbDia:nAt,10]<>0,FG_AlinVlrs(Transform(aDia[oLbDia:nAt,09],"@E 9999,999,999.99"))+" ("+Transform(aDia[oLbDia:nAt,10],"@E 999999")+") "+FG_AlinVlrs(Transform((aDia[oLbDia:nAt,09]/aMes[oLbMes:nAt,09])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aDia[oLbDia:nAt,11]<>0,FG_AlinVlrs(Transform(aDia[oLbDia:nAt,11],"@E 9999,999,999.99"))+" ("+Transform(aDia[oLbDia:nAt,12],"@E 999999")+") "+FG_AlinVlrs(Transform((aDia[oLbDia:nAt,11]/aMes[oLbMes:nAt,11])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aDia[oLbDia:nAt,14]<>0,FG_AlinVlrs(Transform(aDia[oLbDia:nAt,13],"@E 9999,999,999.99"))+" ("+Transform(aDia[oLbDia:nAt,14],"@E 999999")+") "+FG_AlinVlrs(Transform((aDia[oLbDia:nAt,13]/aMes[oLbMes:nAt,13])*100,"@E 999")+"%"),"") }}
oLbDia:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ANALIT  | Autor ³  Andre Luis Almeida ³ Data ³ 14/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Analitico por GRUPO DE MODELO atraves MES/DIA SELECIONADO  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ANALIT(cAnoMes,nTp)
Local aObjects      := {} , aInfo := {}, aPos := {}
Local aSizeHalf     := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cTitTela      := ""
Local cQuery        := "" // Query do SQL de Venda (VV9/VV0)
Local cQuVVF        := "" // Query do SQL de Compra (VVF/VVG)
Local cQAlVV09      := "SQLVV09" // VV0 / VV9
Local cQAlVVR       := "SQLVVR"  // VVR
Local cQAlVVFG      := "SQLVVFG" // VVF / VVG
Local cQAlVV12      := "SQLVV12"  // VV1 / VV2
Local cFilSALVA     := cFilAnt
Local dDtAux        := dDataBase
Local nLin          := 0
Local nCol          := 0
Local ni            := 0
Local nEmpr         := 0
Local dDtI          := dDataBase
Local dDtF          := dDataBase
Local oArrHelp      := Mil_ArrayHelper():New()
Local cIdxGrpModels := "8******"
Local cIdxDevNovos  := "3******"
Local cIdxDevUsados := "5******"
Local nIdx          := 0 // usado nos For's
Local aComboV       := {STR0022,STR0023,STR0027} // Veiculos Novos / Veiculos Usados / Total Veiculos
If Empty(cComboV)
	cComboV := STR0022 // Veiculos Novos
EndIf
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 10 , .T. , .F. } ) // Filtro no topo
aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox Grupo
aAdd( aObjects, { 0 , 29 , .T. , .F. } ) // ListBox Media Mes
aPos := MsObjSize( aInfo, aObjects )
aMod := {}

aAdd( aMod, { "1******"     , STR0021                                , 000 , 000 , 000 , 000 , 000 , 000 } ) // Venda Total de Veiculos
aAdd( aMod, { "2******"     , "   -  " + STR0022                     , 000 , 000 , 000 , 000 , 000 , 000 } ) // Veiculos Novos 
If(nOpcao1 <> '3' .AND. nOpcao1 <> '0') // Se selecionou qualquer tipo de devolucao
	aAdd( aMod, { cIdxDevNovos  , "   -  " + STR0022 + ' ' + STR0062 , 000 , 000 , 001 , 000 , 000 , 000 } ) // Veiculos Novos Dev.
EndIf
aAdd( aMod, { "4******"     , "   -  " + STR0023                     , 000 , 000 , 000 , 000 , 000 , 000 } ) // Veiculos Usados
If(nOpcao1 <> '3' .AND. nOpcao1 <> '0') // Se selecionou qualquer tipo de devolucao
	aAdd( aMod, { cIdxDevUsados , "   -  " + STR0023 + ' ' + STR0062 , 000 , 000 , 001 , 000 , 000 , 000 } ) // Veiculos Usados Dev.
EndIf
aAdd( aMod, { "6******"     , STR0024                                , 000 , 000 , 000 , 000 , 000 , 000 } ) // Venda Direta
aAdd( aMod, { "7******"     , ""                                     , 000 , 000 , 000 , 000 , 000 , 000 } ) // Linha em branco
aAdd( aMod, { cIdxGrpModels , STR0025                                , 000 , 000 , 000 , 000 , 000 , 000 } ) // Titulo: Marca / Grupo do Modelo

ProcRegua(len(aEmpr)+2)
IncProc(STR0020) // Levantando...
For nEmpr := 1 to len(aEmpr)
	IncProc(STR0020) // Levantando...
	cFilAnt := aEmpr[nEmpr,1]
	// VENDA //
	cQuVVF := ""
	cQuery := "SELECT VV9.VV9_STATUS , VV0.VV0_DATMOV , VV0.VV0_TIPFAT , VVA.VVA_CODMAR , VVA.VVA_GRUMOD , COUNT(*) QTD ,SUM(VVA.VVA_VALMOV) VALOR , SUM(SD2.D2_TOTAL) COMPLEMENTO "
	cQuery += "FROM "+RetSqlName("VV0")+" VV0 "
	cQuery += "JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.VV9_STATUS IN ('F','T','O','L') AND VV9.D_E_L_E_T_=' ' ) "
	cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VVA.VVA_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("SD2")+" SD2 ON ( SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_NFORI=VV0.VV0_NUMNFI AND SD2.D2_SERIORI=VV0.VV0_SERNFI AND SD2.D2_COD=SB1.B1_COD AND SD2.D2_TIPO='C' AND SD2.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE "
	If nTipFil == 1 // Filial do Arquivo
		cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
	Else
		cQuery += "( "
		cQuery += "( VV0.VV0_FILIAL IN ("+cFilTot+") AND VV9.VV9_FILNEG='"+xFilial("VV9")+"' ) "
		cQuery += "OR "
		cQuery += "( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV9.VV9_FILNEG=' ' ) "
		cQuery += ") AND "
	EndIf
	cQuery += " VV0.VV0_OPEMOV IN (' ','0','8') AND "
	If cAnoMes <> "******"
		If nTp == 1 // MES
			If left(dtos(dDatIni),6) == cAnoMes // Se for o ANO MES da Data Inicial, utilizar ela.
				cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND "
				cQuVVF += "VVF.VVF_DATEMI>='"+dtos(dDatIni)+"' AND "
				cTitTela := Transform(dDatIni,"@D")+" "+STR0007+" " // ate
				dDtI := dDatIni
			Else
				cQuery += "VV0.VV0_DATMOV>='"+cAnoMes+"01' AND "
				cQuVVF += "VVF.VVF_DATEMI>='"+cAnoMes+"01' AND "
				cTitTela := Transform(stod(cAnoMes+"01"),"@D")+" "+STR0007+" " // ate
				dDtI := stod(cAnoMes+"01")
			EndIf
			If left(dtos(dDatFin),6) == cAnoMes // Se for o ANO MES da Data Final, utilizar ela.
				cQuery += "VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
				cQuVVF += "VVF.VVF_DATEMI<='"+dtos(dDatFin)+"' AND "
				cTitTela += Transform(dDatFin,"@D")
				dDtF := dDatFin
			Else
				dDtAux := ctod("25/"+right(cAnoMes,2)+"/"+right(left(cAnoMes,4),2))+10
				dDtAux := ( dDtAux - day(dDtAux) ) // Ultimo Dia do Mes
				cQuery += "VV0.VV0_DATMOV<='"+dtos(dDtAux)+"' AND "
				cQuVVF += "VVF.VVF_DATEMI<='"+dtos(dDtAux)+"' AND "
				cTitTela += Transform(dDtAux,"@D")
				dDtF := dDtAux
			EndIf
		ElseIf nTp == 2 // DIA
			cQuery += "VV0.VV0_DATMOV='"+cAnoMes+"' AND "
			cQuVVF += "VVF.VVF_DATEMI='"+cAnoMes+"' AND "
			cTitTela := Transform(stod(cAnoMes),"@D")+" - "+DIASEMANA(stod(cAnoMes))
			dDtI := stod(cAnoMes)
			dDtF := stod(cAnoMes)
		EndIf
	Else
		cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
		cQuVVF += "VVF.VVF_DATEMI>='"+dtos(dDatIni)+"' AND VVF.VVF_DATEMI<='"+dtos(dDatFin)+"' AND "
		cTitTela := Transform(dDatIni,"@D")+" "+STR0007+" "+Transform(dDatFin,"@D") // ate
		dDtI := dDatIni
		dDtF := dDatFin
	EndIf
	cQuery += "VV0.VV0_TIPFAT IN ('0','1','2') AND "
	If lTIPMOV
		cQuery += "VV0.VV0_TIPMOV IN (' ','0') AND "
	EndIf
	cQuery += "VV0.D_E_L_E_T_=' ' "
	cQuery += "GROUP BY VV9.VV9_STATUS , VV0.VV0_DATMOV , VV0.VV0_TIPFAT , VVA.VVA_CODMAR , VVA.VVA_GRUMOD , VVA.VVA_VALMOV "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )
	Do While !( cQAlVV09 )->( Eof() )
		nLin := 1
		If ( cQAlVV09 )->( VV0_TIPFAT ) == "2" // Faturamento Direto -> Vlr Venda Direta (Qtd.Veic)
		  if(nOpcao1 <> '3' .AND. nOpcao1 <> '0')
		    nLin := 6
		  else
				nLin := 4
			EndIf
		Else
			If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Normal Novo -> FT Novos Vlr Vendas (Qtd.Veic)
				If cComboV == STR0023 // Veiculos Usados
				   	( cQAlVV09 )->( DbSkip() )
					Loop
				EndIf
				nLin := 2
			Else//If ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Normal Usado -> FT Usados Vlr Vendas (Qtd.Veic)
				If cComboV == STR0022 // Veiculos Novos
				   	( cQAlVV09 )->( DbSkip() )
					Loop
				EndIf
				if(nOpcao1 <> '3' .AND. nOpcao1 <> '0')
					nLin := 4
				else
					nLin := 3
				endif
			EndIf
		EndIf
		If ( cQAlVV09 )->( VV9_STATUS ) $ "F/T" // Finalizado
			nCol := 5
		ElseIf ( cQAlVV09 )->( VV9_STATUS ) $ "O/L" // Pre-Aprovado / Aprovado
			nCol := 3
		EndIf
		nValor := ( cQAlVV09 )->( VALOR ) + ( cQAlVV09 )->( COMPLEMENTO )
		nQtd   := ( cQAlVV09 )->( QTD ) 
		aMod[nLin,nCol] += nValor
		aMod[nLin,nCol+1]+= nQtd
		If nLin == 2 .OR. nLin == 3 // Totalizar Veiculos (Novos/Usados)
			aMod[1,nCol] += nValor
			aMod[1,nCol+1]+= nQtd
		EndIf
		nLin := aScan(aMod,{|x| x[1] == cIdxGrpModels + left(( cQAlVV09 )->( VVA_CODMAR )+( cQAlVV09 )->( VVA_GRUMOD )+space(35),35) })
		If nLin <= 0
			// GRUPO DO MODELO //
			cQuery := "SELECT VVR.VVR_DESCRI FROM "+RetSqlName("VVR")+" VVR WHERE VVR.VVR_FILIAL='"+xFilial("VVR")+"' AND "
			cQuery += "VVR.VVR_CODMAR='"+( cQAlVV09 )->( VVA_CODMAR )+"' AND VVR.VVR_GRUMOD='"+( cQAlVV09 )->( VVA_GRUMOD )+"' AND VVR.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlVVR, .F., .T. )
			aAdd( aMod, { cIdxGrpModels + left(( cQAlVV09 )->( VVA_CODMAR )+( cQAlVV09 )->( VVA_GRUMOD )+space(35),35) , space(3)+( cQAlVV09 )->( VVA_CODMAR )+" - "+Alltrim(( cQAlVV09 )->( VVA_GRUMOD ))+" - "+Alltrim(( cQAlVVR )->( VVR_DESCRI )) , 0 , 0 , 0 , 0 , 0 , 0 , ( cQAlVV09 )->( VVA_CODMAR ), ( cQAlVV09 )->( VVA_GRUMOD ),""} ) // Grupo de Modelo
			( cQAlVVR )->( dbCloseArea() )
			nLin := len(aMod)
		EndIf
		aMod[nLin,nCol] += nValor
		aMod[nLin,nCol+1]+= nQtd
	   	( cQAlVV09 )->( DbSkip() )
	EndDo
	( cQAlVV09 )->( dbCloseArea() )
	// COMPRA //
	cQuery := "SELECT VVF.VVF_VALMOV , VVG.VVG_ESTVEI , VVG.VVG_CHAINT FROM "+RetSqlName("VVF")+" VVF "
	cQuery += "JOIN "+RetSqlName("VVG")+" VVG ON VVG.VVG_FILIAL=VVF.VVF_FILIAL AND VVG.VVG_TRACPA=VVF.VVF_TRACPA AND VVG.D_E_L_E_T_=' ' "
	cQuery += "JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=VVG.VVG_CODTES AND SF4.F4_ESTOQUE='S' AND SF4.D_E_L_E_T_=' ' "
	cQuery += "WHERE VVF.VVF_FILIAL='"+xFilial("VVF")+"' AND VVF.VVF_OPEMOV='0' AND "+cQuVVF+" VVF.VVF_SITNFI='1' AND VVF.D_E_L_E_T_=' '"
	If lTIPMOV
		cQuery += " AND VVF.VVF_TIPMOV IN (' ','0') "
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVFG, .F., .T. )
	Do While !( cQAlVVFG )->( Eof() )
		If ( cQAlVVFG )->( VVG_ESTVEI ) == "0" // Normal Novo -> FT Novos Vlr Vendas (Qtd.Veic)
			If cComboV == STR0023 // Escapa Veiculos Usados
			   	( cQAlVVFG )->( DbSkip() )
				Loop
			EndIf
			nLin := 2
		Else//If ( cQAlVVFG )->( VVG_ESTVEI ) == "1" // Normal Usado -> FT Usados Vlr Vendas (Qtd.Veic)
			If cComboV == STR0022 // Escapa Veiculos Novos
			   	( cQAlVVFG )->( DbSkip() )
				Loop
			EndIf
			nLin := 4
		EndIf
		nValor := ( cQAlVVFG )->( VVF_VALMOV )
		aMod[nLin,7] += nValor
		aMod[nLin,8]++
		// Totalizar Veiculos (Novos/Usados)
		aMod[1,7] += nValor
		aMod[1,8]++
		// VEICULO/MODELO VV1/VV2 //
		cQuery := "SELECT VV1.VV1_CODMAR , VV2.VV2_GRUMOD FROM "+RetSqlName("VV1")+" VV1 , "+RetSqlName("VV2")+" VV2 WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT='"+( cQAlVVFG )->( VVG_CHAINT )+"' AND "
		cQuery += "VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV1.D_E_L_E_T_=' ' AND VV2.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlVV12, .F., .T. )
		nLin := aScan(aMod,{|x| x[1] == cIdxGrpModels + left(( cQAlVV12 )->( VV1_CODMAR )+( cQAlVV12 )->( VV2_GRUMOD )+space(35),35) })
		If nLin <= 0
			// GRUPO DO MODELO //
			cQuery := "SELECT VVR.VVR_DESCRI FROM "+RetSqlName("VVR")+" VVR WHERE VVR.VVR_FILIAL='"+xFilial("VVR")+"' AND "
			cQuery += "VVR.VVR_CODMAR='"+( cQAlVV12 )->( VV1_CODMAR )+"' AND VVR.VVR_GRUMOD='"+( cQAlVV12 )->( VV2_GRUMOD )+"' AND VVR.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlVVR, .F., .T. )
			aAdd( aMod, { cIdxGrpModels + left(( cQAlVV12 )->( VV1_CODMAR )+( cQAlVV12 )->( VV2_GRUMOD )+space(35),35) , space(3)+( cQAlVV12 )->( VV1_CODMAR )+" - "+Alltrim(( cQAlVV12 )->( VV2_GRUMOD ))+" - "+Alltrim(( cQAlVVR )->( VVR_DESCRI )) , 0 , 0 , 0 , 0 , 0 , 0 , ( cQAlVV12 )->( VV1_CODMAR ) , ( cQAlVV12 )->( VV2_GRUMOD ),""} ) // Grupo de Modelo
			( cQAlVVR )->( dbCloseArea() )
			nLin := len(aMod)
		EndIf
		( cQAlVV12 )->( dbCloseArea() )
		aMod[nLin,7] += nValor
		aMod[nLin,8]++
	   	( cQAlVVFG )->( DbSkip() )
	EndDo
	( cQAlVVFG )->( dbCloseArea() )
Next
cFilAnt := cFilSALVA
IncProc(STR0020) // Levantando...
ni := 0

If(nOpcao1 <> '3' .AND. nOpcao1 <> '0') // Esse If verifica se tem algum tipo de devolucao selecionada 
	oDevs      := Mil_Devolucoes():New()
	aSumNovos  := Mil_DataContainer():New({})
	aSumUsados := Mil_DataContainer():New({})
	
	If cComboV == STR0023 .OR. cComboV == STR0027 //usados?
		aData := {                  ;
			{'Novos?'     ,     .F.}, ;
			{'DataInicial', IIF(!Empty(dDtI), dDtI, dDatIni)}, ;
			{'DataFinal'  , IIF(!Empty(dDtF), dDtF, dDatFin)}, ;
			{'Filiais'    , oArrHelp:Map(aEmpr, { |el| el[1] })}, ;
			{'Tipo'       , IIF(nOpcao1 == '1', 'Venda', 'Devolucao')};
		}
		aUsados := oDevs:Todos( Mil_DataContainer():New(aData) ) //Dados de devolução de veiculos usados
		aSumUsados := Mil_DataContainer():New(aUsados)
		nIdxDevUsados := ASCAN(aMod, { |el| el[1] == cIdxDevUsados })
		aMod[nIdxDevUsados][5] := aSumUsados:Sum('VVA_VALMOV') * -1
		aMod[nIdxDevUsados][6] := aSumUsados:Count({|el| !Empty(el:GetValue('VVA_VALMOV')) }) // Número de veículos
		aMod[nIdxDevUsados][7] := 0 // Número de veículos
		aMod[nIdxDevUsados][8] := 0 // Número de veículos
	EndIf

	If cComboV == STR0022 .OR. cComboV == STR0027 //novos?
		aData := {                  ;
			{'Novos?'     ,     .T.}, ;
			{'DataInicial', IIF(!Empty(dDtI), dDtI, dDatIni)}, ;
			{'DataFinal'  , IIF(!Empty(dDtF), dDtF, dDatFin)}, ;
			{'Filiais'    , oArrHelp:Map(aEmpr, { |el| el[1] })}, ;
			{'Tipo'       , IIF(nOpcao1 == '1', 'Venda', 'Devolucao')};
		}
		aNovos  := oDevs:Todos( Mil_DataContainer():New(aData) ) //Dados de devolução de veiculos novos
		aSumNovos  := Mil_DataContainer():New(aNovos)
		nIdxDevNovos  := ASCAN(aMod, { |el| el[1] == cIdxDevNovos  })
		aMod[nIdxDevNovos][5] := aSumNovos:Sum('VVA_VALMOV') * -1
		aMod[nIdxDevNovos][6] := aSumNovos:Count({|el| !Empty(el:GetValue('VVA_VALMOV')) }) // Número de veículos
		aMod[nIdxDevNovos][7] := 0 // valor de compras sempre 0 para devs
		aMod[nIdxDevNovos][8] := 0 // quantidade de compras sempre 0 para devs
	EndIf

	aModelos := VC170GetModels(aMod, cIdxGrpModels)

	For nIdx := 1 to len(aModelos)
		VC170PutDevolMod(aMod, aModelos[nIdx], aSumNovos, aSumUsados) // insere no array da tela os elementos de devolucao novos
	Next

	For nIdx := 1 to len(aModelos)
		VC170PutVlLiqMod(aMod, aModelos[nIdx], aSumNovos, aSumUsados) // insere no array da tela os elementos de vendas - devolucoes (Total Liquido)
	Next
	
EndIf

aMod[1][5] := 0
aMod[1][6] := 0
for nIdx := 1 to len(aMod)
	// os numeros abaixo forma colocados a mão no array que representam o total
	// a ser somado, foi utilizado dessa forma pois a soma não estava ok.
	if LEFT(aMod[nIdx,1],1) $ '2,3,4,5' 
		aMod[1][5] += aMod[nIdx,5]
		if aMod[nIdx,5] > 0 // positivo venda
			aMod[1][6] += aMod[nIdx,6]
		else // negativo devolucao
			aMod[1][6] -= aMod[nIdx,6]
		end
	else
		loop
	end
next

aSort(aMod,1,,{|x,y| x[1] + "AA" + x[2] < y[1] + "AA" + y[2] })

DEFINE MSDIALOG oGruMod FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta Gerencial de Veiculos
	oGruMod:lEscClose := .F.
	@ aPos[1,1]+2,aPos[1,2]+3 SAY cTitTela SIZE 350,08 OF oGruMod PIXEL COLOR CLR_RED FONT oTitTela
	@ aPos[1,1],aPos[1,4]-230 BUTTON oBotMAPA PROMPT STR0034 OF oGruMod SIZE 180,10 PIXEL ACTION Processa( {|| FS_MAPA(aMod[oLbMod:nAt,1],dDtI,dDtF,aMod[oLbMod:nAt,04]+aMod[oLbMod:nAt,06],Alltrim(cTitTela)+" - "+Alltrim(aMod[oLbMod:nAt,2]), aMod[oLbMod:nAt]) } ) // Visualiza MAPA:
	@ aPos[1,1],aPos[1,4]-045 BUTTON oGrpSair PROMPT STR0010 OF oGruMod SIZE 45,10 PIXEL ACTION oGruMod:End() // SAIR
	@ aPos[2,1],aPos[2,2] LISTBOX oLbMod FIELDS HEADER (""),;
														(STR0018+" ("+STR0047+")"),; // Propostas Aprovadas (Qtd.Veic)
														(STR0016+" ("+STR0047+")"),; // Vlr Total das Vendas (Qtd.Veic)
														(STR0019+" ("+STR0047+")") ; // Vlr Total das Compras (Qtd.Veic)
														COLSIZES aPos[2,4]-300,90,90,90 SIZE aPos[2,4]-2,aPos[2,3]-15 OF oGruMod PIXEL ON CHANGE (FS_TXTBOTAO(aMod[oLbMod:nAt,1],aMod[oLbMod:nAt,2]),FS_MEDIA("G")) ON DBLCLICK FS_ATEND(cAnoMes, aMod[oLbMod:nAt,1],dDtI,dDtF,cTitTela+" ( "+Alltrim(aMod[oLbMod:nAt,2])+" )",aMod[oLbMod:nAt],oLbMod:nColPos)
	oLbMod:SetArray(aMod)
	oLbMod:bLine := { || { aMod[oLbMod:nAt,2] ,;
     	                	IIf(aMod[oLbMod:nAt,04]<>0,FG_AlinVlrs(Transform(aMod[oLbMod:nAt,03],"@E 9999,999,999.99"))+" ("+Transform(aMod[oLbMod:nAt,04],"@E 999999") + ") " + FG_AlinVlrs(Transform( VC170Percent((aMod[2][3] + aMod[4][3]), aMod[oLbMod:nAt][3]) ,"@E 999") + "%"),"") ,;
     	                	IIf(aMod[oLbMod:nAt,06]<>0,FG_AlinVlrs(Transform(aMod[oLbMod:nAt,05],"@E 9999,999,999.99"))+" ("+Transform(aMod[oLbMod:nAt,06],"@E 999999") + ") " + FG_AlinVlrs(Transform( VC170Percent((aMod[2][5] + aMod[4][5]), aMod[oLbMod:nAt][5]) ,"@E 999") + "%"),"") ,;
     	                	IIf(aMod[oLbMod:nAt,08]<>0,FG_AlinVlrs(Transform(aMod[oLbMod:nAt,07],"@E 9999,999,999.99"))+" ("+Transform(aMod[oLbMod:nAt,08],"@E 999999") + ") " + FG_AlinVlrs(Transform( VC170Percent((aMod[2][7] + aMod[4][7]), aMod[oLbMod:nAt][7]) ,"@E 999") + "%"),"") }}
	@ aPos[3,1],aPos[3,2] LISTBOX oLbMedG FIELDS HEADER (STR0048),; // Valor Medio
														(STR0018),; // Propostas Aprovadas
														(STR0016),; // Vlr Total das Vendas
														(STR0019) ; // Vlr Total das Compras
														COLSIZES aPos[3,4]-300,90,90,90 SIZE aPos[3,4]-2,30 OF oGruMod PIXEL WHEN .f.
	oLbMedG:SetArray(aMedG)
	oLbMedG:bLine := { || { aMedG[oLbMedG:nAt,1] ,;
     	                	FG_AlinVlrs(Transform(aMedG[oLbMedG:nAt,02],"@EZ 9999,999,999.99")) ,;
     	                	FG_AlinVlrs(Transform(aMedG[oLbMedG:nAt,03],"@EZ 9999,999,999.99")) ,;
     	                	FG_AlinVlrs(Transform(aMedG[oLbMedG:nAt,04],"@EZ 9999,999,999.99")) }}
	@ aPos[1,1],aPos[1,4]-300 MSCOMBOBOX oComboV VAR cComboV ITEMS aComboV VALID (ni:=1,oGruMod:End()) SIZE 65,07 OF oGruMod PIXEL COLOR CLR_BLUE
ACTIVATE MSDIALOG oGruMod
If ni > 0
	FS_ANALIT(cAnoMes,nTp)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    VC170Percent    | Autor ³  Vinicius Gati ³ Data ³ 23/04/14   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula a porcentagem dos valores passados                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VC170Percent(nCemPerc, nVal)
	Local nPercent := 0
	If(nVal != 0)
		If(nVal < 0)
			nVal := nVal * -1
		EndIf
		nPercent := (nVal*100)/nCemPerc
	EndIf
Return nPercent

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    VC170GetModels    | Autor ³  Vinicius Gati ³ Data ³ 23/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os modelos de veiculos vendidos no periodo         |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VC170GetModels(aData, cIdxPrefix)
	Local aResults := {}
	Local nSizeIdx := Len(cIdxPrefix) // tamanho do indice (string)
	//Verifica se tem o indice e se o tamanho é maior pois quando é um modelo a formula é indice+modelo no 1 elemento do array aData
	AEVAL(aData, {|el| if( left(el[1], nSizeIdx) == cIdxPrefix .AND. Len(el[1]) > nSizeIdx, AADD(aResults, el), Nil) })
Return aResults

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    VC170PutDevolMod    | Autor ³  Vinicius Gati ³  Data ³ 23/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Insere row com dados do modelo abaixo do modelo em si         |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÜÜÜÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÄÄÄßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VC170PutDevolMod(aData, aModelo, aTotNovos, aTotUsados)
	Local nNewIdx    := 0
	Local cIdxPrefix := VC170ClearModDes(aModelo[2]) // remove o formato base para encontrar o modelo
	Local nIdx       := ASCAN(aData, {|el| VC170ClearModDes(el[2]) == cIdxPrefix})
	Local bFilter    := { |el| !Empty(el:GetValue('VVA_VALMOV')) .AND. VC170ClearModDes(el:GetValue('VVA_CODMAR') + el:GetValue('VVA_GRUMOD') + el:GetValue('VVR_DESCRI'))  == cIdxPrefix }	
	Local nSumNovos  := aTotNovos:Sum('VVA_VALMOV', bFilter)
	Local nCntNovos  := aTotNovos:Count(bFilter)
	Local nSumUsados := aTotUsados:Sum('VVA_VALMOV', bFilter)
	Local nCntUsados := aTotUsados:Count(bFilter)
	Local nSumTotal  := nSumNovos + nSumUsados
	Local nCntTotal  := nCntNovos + nCntUsados

	AADD(aData, Nil)
	AINS(aData, nIdx)                                      // Insere novo elemento prox do modelo
	aData[nIdx]        := ACLONE(aData[nIdx + 1])          // Copia o modelo
	aData[nIdx + 1][3] := 0                                // Insere o total de devolucoes (novos)
	aData[nIdx + 1][5] := nSumTotal * -1                   // Insere o total de devolucoes (usados)
	aData[nIdx + 1][4] := 0                                // Insere a Qtd total de devolucoes (novos)
	aData[nIdx + 1][6] := nCntTotal                        // Insere a Qtd total de devolucoes (usados)
	aData[nIdx + 1][7] := 0                                // zerando valores nao utilizados
	aData[nIdx + 1][8] := 0                                // ...
	aData[nIdx + 1][2] := aData[nIdx][2] + ' - ' + STR0062 // label de devolucoes
	If Len(aData[nIdx + 1]) > 10 // Tamanho Max do vetor aMod
		aData[nIdx + 1][11] := "DEV"
	EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    VC170PutVlLiqMod    | Autor ³  Vinicius Gati ³  Data ³ 23/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Insere row com dados do modelo abaixo do modelo em si         |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÜÜÜÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÄÄÄßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VC170PutVlLiqMod(aData, aModelo, aTotNovos, aTotUsados)
	Local nNewIdx    := 0
	Local cIdxPrefix := VC170ClearModDes(aModelo[2]) // remove o formato base para encontrar o modelo
	Local nIdx       := ASCAN(aData, {|el| VC170ClearModDes(el[2]) == cIdxPrefix})
	AADD(aData, Nil)
	AINS(aData, nIdx)                                      // Insere novo elemento prox do modelo
	aData[nIdx]        := ACLONE(aData[nIdx + 1])          // Copia o modelo
	aData[nIdx + 1][3] := 0                                // Insere o total de vendas - devolucoes (novos)
	aData[nIdx + 1][5] := (aData[nIdx-1][5]-(aData[nIdx][5] * - 1)) // Insere o total de vendas - devolucoes (usados)
	aData[nIdx + 1][4] := 0                                // Insere a Qtd total de vendas - devolucoes (novos)
	aData[nIdx + 1][6] := (aData[nIdx-1][6]-aData[nIdx][6])// Insere o total de vendas - devolucoes (usados)
	aData[nIdx + 1][7] := 0                                // zerando valores nao utilizados
	aData[nIdx + 1][8] := 0                                // ...
	aData[nIdx + 1][2] := STR0064 // " --- Total"
	If Len(aData[nIdx + 1]) > 10 // Tamanho Max do vetor aMod
		aData[nIdx + 1][11] := "TOT"
	EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    VC170ClearModDes  | Autor ³  Vinicius Gati ³ Data ³ 23/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa os dados do modelo para posicionar corretamente      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VC170ClearModDes(cStr)
	Local cResult := STRTRAN(STRTRAN(cStr, ' - ', ''), ' ', '')
Return cResult

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_TXTBOTAO | Autor ³  Andre Luis Almeida ³ Data ³ 14/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Altera TEXTO do Botao Visualiza MAPA                       |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TXTBOTAO(cTipo,cTexto)
If ( cTipo <> "5******" )
	oBotMAPA:cCaption := STR0034+" "+left(Alltrim(cTexto),40) // "Visualiza MAPA:"
	oBotMAPA:lActive  := .t.
Else
	oBotMAPA:cCaption := STR0034 // "Visualiza MAPA:"
	oBotMAPA:lActive  := .f.
EndIf
If(Len(aMod[oLbMod:nAt]) > 10 .and. aMod[oLbMod:nAt,11] $ "DEV.TOT") //Desabilita botao quando estiver posicionado na linha de Devolucao e Total
	oBotMAPA:lActive  := .f.
EndIf
oBotMAPA:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  FS_MEDIA  | Autor ³  Andre Luis Almeida ³ Data ³ 30/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula Valores Medios do ListBox ( MES ou GRUPO MODELO )  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MEDIA(cTp)
	If cTp == "M" // MES
		aMedM := {} // Valor Medio ( MES )
		aAdd( aMedM , { Alltrim(aMes[oLbMes:nAt,02]) , (aMes[oLbMes:nAt,03]/aMes[oLbMes:nAt,04]) , (aMes[oLbMes:nAt,05]/aMes[oLbMes:nAt,06]) , (aMes[oLbMes:nAt,07]/aMes[oLbMes:nAt,08]) , (aMes[oLbMes:nAt,09]/aMes[oLbMes:nAt,10]) , IIF(aMes[oLbMes:nAt,12]<>0,(aMes[oLbMes:nAt,11]/aMes[oLbMes:nAt,12]),aMes[oLbMes:nAt,11]) , (aMes[oLbMes:nAt,13]/aMes[oLbMes:nAt,14])} )
		oLbMedM:SetArray(aMedM)
		oLbMedM:bLine := { || { aMedM[oLbMedM:nAt,1] ,;
	    	                	FG_AlinVlrs(Transform(aMedM[oLbMedM:nAt,02],"@EZ 9999,999,999.99")) ,;
	    	                	FG_AlinVlrs(Transform(aMedM[oLbMedM:nAt,03],"@EZ 9999,999,999.99")) ,;
	    	                	FG_AlinVlrs(Transform(aMedM[oLbMedM:nAt,04],"@EZ 9999,999,999.99")) ,;
	    	                	FG_AlinVlrs(Transform(aMedM[oLbMedM:nAt,05],"@EZ 9999,999,999.99")) ,;
	    	                	FG_AlinVlrs(Transform(aMedM[oLbMedM:nAt,06],"@EZ 9999,999,999.99")) ,;
	    	                	FG_AlinVlrs(Transform(aMedM[oLbMedM:nAt,07],"@EZ 9999,999,999.99")) }}
		oLbMedM:Refresh()
	ElseIf cTp == "G" // GRUPO DO MODELO
		aMedG := {} // Valor Medio ( GRUPO MODELO )
		aAdd( aMedG , { IIf(aMod[oLbMod:nAt,1]<>"5******",Alltrim(aMod[oLbMod:nAt,2]),"") , (aMod[oLbMod:nAt,03]/aMod[oLbMod:nAt,04]) , (aMod[oLbMod:nAt,05]/aMod[oLbMod:nAt,06]) , (aMod[oLbMod:nAt,07]/aMod[oLbMod:nAt,08]) } )
		oLbMedG:SetArray(aMedG)
		oLbMedG:bLine := { || { aMedG[oLbMedG:nAt,1] ,;
	    	                	FG_AlinVlrs(Transform(aMedG[oLbMedG:nAt,02],"@EZ 9999,999,999.99")) ,;
	    	                	FG_AlinVlrs(Transform(aMedG[oLbMedG:nAt,03],"@EZ 9999,999,999.99")) ,;
	    	                	FG_AlinVlrs(Transform(aMedG[oLbMedG:nAt,04],"@EZ 9999,999,999.99")) }}
		oLbMedG:Refresh()
	EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  FS_MAPA   | Autor ³  Andre Luis Almeida ³ Data ³ 14/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ MAPA - Monta MAPA de Avaliacoes em SQL                     |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MAPA(cModVei,dDtI,dDtF,nQtd,cTitMapa, aDados)
Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lFazLevant := .t.
Local cont       := 0
Local ii         := 0
Local bCampo     := { |nCPO| Field(nCPO) }
Local cGrupVei   := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Local cQuery     := ""
Local cQAlVV09   := "SQLATVEI" // VV0 / VVA / VV9
Local cQAlVOQ    := "SQLVOQ" // VOQ
Local cFilSALVA  := cFilAnt
Local nEmpr      := 0
Local aVOQ       := {}
Local aFormul    := {}
Local aMap       := {}
Private cCodMap  := "" // Mapa de Avaliacao para o Painel de Vendas de Veiculos em SQL (VV0/VVA)
Private cTipAva  := "1" //Veiculos
Private cCpoDiv  := "    1"
Private aStru    := {}
Private aErrAva  := {}
Private cSimVda  := "V"
Private cMoedCor := GetMv("MV_SIMB1")
Private cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
Private cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))

cCodMap := GetNewPar("MV_MAPPVV","")

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 10 , .T. , .F. } ) // Botao Visualiza MAPA
aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox MAPA
aPos := MsObjSize( aInfo, aObjects )
lLevCam := .f.
ProcRegua(len(aEmpr)+2)
If !Empty(cCodMap)
	dbSelectArea("VS5")
	dbSetOrder(1)
	if dbSeek(xFilial("VS5")+cCodMap)
		IncProc(STR0020) // Levantando...
		If cModVei <> "5******"
			If nQtd > 1500
				lFazLevant := .f.
				If MsgYesNo(STR0036,STR0002) // Este processo podera levar alguns segundos, Deseja continuar? / Atencao
					lFazLevant := .t.
				EndIf
			EndIf
			If lFazLevant
				For nEmpr := 1 to len(aEmpr)
					IncProc(STR0020) // Levantando...
					cFilAnt := aEmpr[nEmpr,1]
					aVOQ := {}
					// Levanta todo MAPA DE AVALIACAO //
					cQuery := "SELECT VOQ.VOQ_TIPFAT , VOQ.VOQ_ANASIN , VOQ.VOQ_DESAVA , VOQ.VOQ_CLAAVA , VOQ.VOQ_CODIGO , VOQ.VOQ_SINFOR , VOQ.VOQ_PRIFAI ,VOQ.VOQ_SEGFAI , VOQ.VOQ_FUNADI , VOQ.VOQ_CODIMF , VOQ.VOQ_CTATOT , VEG.VEG_FORMUL "
					cQuery += "FROM "+RetSqlName("VOQ")+" VOQ , "+RetSqlName("VEG")+" VEG WHERE "
					cQuery += "VOQ.VOQ_FILIAL='"+xFilial("VOQ")+"' AND VOQ.VOQ_CODMAP='"+cCodMap+"' AND VOQ.VOQ_INDATI='1' AND VOQ.D_E_L_E_T_=' ' AND "
					cQuery += "VEG.VEG_FILIAL='"+xFilial("VEG")+"' AND VEG.VEG_CODIGO=VOQ.VOQ_CODIGO AND VEG.D_E_L_E_T_=' ' ORDER BY VOQ.VOQ_CLAAVA "
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlVOQ, .F., .T. )
					Do While !( cQAlVOQ )->( Eof() )
						aadd(aVOQ,{ ( cQAlVOQ )->( VOQ_TIPFAT ) ,; // 1
									 ( cQAlVOQ )->( VOQ_CLAAVA ) ,; // 2
									  IIf(( cQAlVOQ )->( VOQ_ANASIN )#"0",Space(7)+( cQAlVOQ )->( VOQ_DESAVA ),( cQAlVOQ )->( VOQ_DESAVA )),; // 3
									  ( cQAlVOQ )->( VOQ_ANASIN ),; // 4
									  ( cQAlVOQ )->( VOQ_CODIGO ),; // 5
									  ( cQAlVOQ )->( VOQ_SINFOR ),; // 6
									  ( cQAlVOQ )->( VOQ_PRIFAI ),; // 7
									  ( cQAlVOQ )->( VOQ_SEGFAI ),; // 8
									  ( cQAlVOQ )->( VOQ_FUNADI ),; // 9
									  ( cQAlVOQ )->( VOQ_CODIMF ),; //10
									  ( cQAlVOQ )->( VOQ_CTATOT ),; //11
									  Alltrim(( cQAlVOQ )->( VEG_FORMUL ))}) //12
					   	( cQAlVOQ )->( DbSkip() )
					EndDo
					( cQAlVOQ )->( dbCloseArea() )
					cQuery := "SELECT VV0.* , VVA.* , VV1.VV1_TRACPA , SB1.B1_COD FROM "+RetSqlName("VV0")+" VV0 "
					cQuery += "JOIN "+RetSqlName("VV9")+" VV9 ON VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.VV9_STATUS IN ('F','T','O','L') AND VV9.D_E_L_E_T_=' ' "
					cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' "
					cQuery += "JOIN "+RetSqlName("VV1")+" VV1 ON VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VVA.VVA_CHAINT AND VV1.D_E_L_E_T_=' ' "
					cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGrupVei+"' AND SB1.B1_CODITE=VV1.VV1_CHAINT AND SB1.D_E_L_E_T_=' ' "
					cQuery += "WHERE "
					If nTipFil == 1 // Filial do Arquivo
						cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
					Else
						cQuery += "( "
						cQuery += "( VV0.VV0_FILIAL IN ("+cFilTot+") AND VV9.VV9_FILNEG='"+xFilial("VV9")+"' ) "
						cQuery += "OR "
						cQuery += "( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV9.VV9_FILNEG=' ' ) "
						cQuery += ") AND "
					EndIf
					cQuery += "VV0.VV0_OPEMOV IN (' ','0','8') AND VV0.VV0_DATMOV>='"+dtos(dDtI)+"' AND VV0.VV0_DATMOV<='"+dtos(dDtF)+"' AND "
					
					// Verifica o tipo
					If cModVei <> "1******"
						If LEFT(cModVei, 7) == "6******" // Faturamento Direto
							cQuery += "VV0.VV0_TIPFAT='2' AND "
						ElseIf LEFT(cModVei, 7) == "2******" .OR. LEFT(cModVei, 7) == "3******"
							cQuery += "VV0.VV0_TIPFAT='0' AND "   // Veiculo Novo ou Dev Veic Novo
						ElseIf LEFT(cModVei, 7) == "4******" .OR. LEFT(cModVei, 7) == "5******"
							cQuery += "VV0.VV0_TIPFAT='1' AND " // Veiculo Usado
						ElseIf LEN(aDados) > 8 // Marca / Grupo do Modelo
							cModelo  := aDados[ 9]
							cGModelo := aDados[10]
							cQuery += "VV0.VV0_TIPFAT IN ('0','1','2') AND VVA.VVA_CODMAR='"+cModelo+"' AND VVA.VVA_GRUMOD='"+cGModelo+"' AND "
						EndIf
					Else
						cQuery += "VV0.VV0_TIPFAT IN ('0','1','2') AND "
					EndIf
					If lTIPMOV
						cQuery += "VV0.VV0_TIPMOV IN (' ','0') AND "
					EndIf
					cQuery += "VV0.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )
					Do While !( cQAlVV09 )->( Eof() )
						If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Normal Novo -> FT Novos Vlr Vendas (Qtd.Veic)
							If cComboV == STR0023 // Veiculos Usados
							   	( cQAlVV09 )->( DbSkip() )
								Loop
							EndIf
						ElseIf ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Normal Usado -> FT Usados Vlr Vendas (Qtd.Veic)
							If cComboV == STR0022 // Veiculos Novos
							   	( cQAlVV09 )->( DbSkip() )
								Loop
							EndIf
						EndIf
						aStru   := {}
						aFormul := {}
						For ii := 1 to len(aVOQ) // Utiliza VOQ (MAPA AVALIACAO) pelo TIPFAT
							If ( cQAlVV09 )->( VV0_TIPFAT ) $ aVOQ[ii,1]
	 							aadd(aStru,{ ( cQAlVV09 )->( VV0_NUMTRA ),;	// 1
	 											( cQAlVV09 )->( VV1_TRACPA ),;	// 2
				 								( cQAlVV09 )->( B1_COD ),;		// 3
				 								aVOQ[ii,2],; 					// 4
				 								aVOQ[ii,3],; 					// 5
				 								aVOQ[ii,4],; 					// 6
				 								aVOQ[ii,5],; 					// 7
				 								aVOQ[ii,6],; 					// 8
				 								0,; 							// 9
				 								0,; 							//10
												( cQAlVV09 )->( VVA_CHASSI ),; //11
												0,; 							//12
												0,; 							//13
												.f.,; 							//14
												aVOQ[ii,7],; 					//15
												aVOQ[ii,8],; 					//16
												aVOQ[ii,9],; 					//17
												aVOQ[ii,10],; 					//18
												stod(( cQAlVV09 )->( VV0_DATMOV )),; // 19
												0,; 							//20
												0,; 							//21
												aVOQ[ii,11]}) 					//22
								aadd(aFormul,{aVOQ[ii,12],aVOQ[ii,12],aVOQ[ii,5],aVOQ[ii,5]}) // Formulas ( Moeda Normal / Moeda Forte )
							EndIf
						Next
						//Calcula os valores do vetor
						FG_CalcVlrs(aStru,,,.f.,aFormul,.t.)
						If len(aStru) == 0 .or. Empty(aStru[1,1])
							MsgInfo(STR0003,STR0002) // Nao existem dados para esta Consulta ! / Atencao
							Exit
						Endif
						For ii := 1 to Len(aStru)
							cont := aScan(aMap,{|x| x[1] == aStru[ii,4] })
		                    If cont <= 0
								aadd(aMap,{aStru[ii,4],aStru[ii,5],0,0,0,0,0,0}) // Mapa
								cont := len(aMap)
							EndIf
							If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Veiculo Novo
								aMap[cont,3] += aStru[ii,9]
							Else // Veiculo Usado
								aMap[cont,5] += aStru[ii,9]
							EndIf
							aMap[cont,7] += aStru[ii,9] // Total (Novo/Usado)
						Next
					   	( cQAlVV09 )->( DbSkip() )
					EndDo
					( cQAlVV09 )->( dbCloseArea() )
				Next
			EndIf
		EndIf
	Else
		MsgInfo(STR0030,STR0002) //Mapa de veiculos nao cadastrado! / Atencao
	EndIf
Else
	MsgInfo(STR0030+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"MV_MAPPVV",STR0002) //Mapa de veiculos nao cadastrado! / Atencao
EndIf
cFilAnt := cFilSALVA
IncProc(STR0020) // Levantando...
If len(aMap) <= 0
	aadd(aMap,{"","",0,0,0,0,0,0}) // Mapa
EndIf
For ii := 1 to len(aMap)
	aMap[ii,4] := ( aMap[ii,3] / aMap[1,3] ) * 100
	aMap[ii,6] := ( aMap[ii,5] / aMap[1,5] ) * 100
	aMap[ii,8] := ( aMap[ii,7] / aMap[1,7] ) * 100
Next
IncProc(STR0020) // Levantando...
DEFINE MSDIALOG oMapaAval FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta Gerencial de Veiculos
	@ aPos[1,1]+2,aPos[1,2]+3 SAY (STR0026+": "+cTitMapa) SIZE aPos[1,4]-60,08 OF oMapaAval PIXEL COLOR CLR_RED FONT oTitTela // Mapa:
	@ aPos[1,1],aPos[1,4]-045 BUTTON oGrpSair PROMPT STR0010 OF oMapaAval SIZE 45,10 PIXEL ACTION oMapaAval:End() // SAIR
	@ aPos[2,1],aPos[2,2] LISTBOX oLbMap FIELDS HEADER (STR0026),; // Mapa
														(STR0022),; // Veiculos Novos
														(STR0023),; // Veiculos Usados
														(STR0027) ; // Total Veiculos
														COLSIZES aPos[2,4]-300,90,90,90 SIZE aPos[2,4]-2,aPos[2,3]-aPos[1,3]-2 OF oMapaAval PIXEL
	oLbMap:SetArray(aMap)
	oLbMap:bLine := { || { aMap[oLbMap:nAt,02] ,;
     	                	IIf(aMap[oLbMap:nAt,03]<>0,FG_AlinVlrs(Transform(aMap[oLbMap:nAt,03],"@E 9999,999,999.99"))+" "+FG_AlinVlrs(Transform(aMap[oLbMap:nAt,04],"@E 9999.9")+"%"),"") ,;
     	                	IIf(aMap[oLbMap:nAt,05]<>0,FG_AlinVlrs(Transform(aMap[oLbMap:nAt,05],"@E 9999,999,999.99"))+" "+FG_AlinVlrs(Transform(aMap[oLbMap:nAt,06],"@E 9999.9")+"%"),"") ,;
     	                	IIf(aMap[oLbMap:nAt,07]<>0,FG_AlinVlrs(Transform(aMap[oLbMap:nAt,07],"@E 9999,999,999.99"))+" "+FG_AlinVlrs(Transform(aMap[oLbMap:nAt,08],"@E 9999.9")+"%"),"") }}
ACTIVATE MSDIALOG oMapaAval
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  FS_ATEND  | Autor ³  Andre Luis Almeida ³ Data ³ 14/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Atendimentos dos TOTAIS ou MODELO SELECIONADO      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATEND(cAnoMes, cModVei,dDtI,dDtF,cTitTela,aDados,nColClick)
	Local aObjects  := {} , aInfo := {}, aPos := {}
	Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	Local aAtend    := {}
	Local cQuery    := ""
	Local cQAlVV09  := "SQLVV09" // VV0 / VV9
	Local cQAlSA1   := "SQLSA1"  // SA1
	Local cTpAtend  := ""
	Local nValor    := 0
	Local nCompl    := 0
	Local cFilSALVA := cFilAnt
	Local nEmpr     := 0
	Local lVV9FILVDA:= ( VV9->(FieldPos("VV9_FILNEG")) > 0 )
	// Identicacao de Devolucao ou Nao
	Local cTipOper  := If(Len(aDados) > 10, aDados[11],"")
	Local lFazer    := .T.

	If nColClick == 4 
		Return()
	EndIf

	// O problema aqui é que para definir se mostra ou não dados é de acordo com
	// uma string nesse array e ele começar com um numero, se for de 1 a 6 deve 
	// mostrar, se for mais, deve fazer algumas verificações antes de mostrar.
	if LEFT(aDados[1],1) $ '1,2,3,4,5,6'
		lFazer := .T.
	// Preciso verificar se o array tem tamanho suficiente para checagem e dados
	// caso não tenha não busca dados...
	elseif LEN(aDados) < 11
		lFazer := .F.
	// Caso tenha tamanho vamos para as checagens
	else
		// Possui essa descricao? se sim nao fará, essa descrição não contem 
		// filtro valido
		if aDados[2] == "Marca / Grupo do Modelo"
			lFazer := .F.
		end
		// nao está vazio os dados ou é um total (que pode ser vazio em caso 
		// de devolucao) pode fazer
		//
		// verifica se é um total de modelo que foi zerado por devolução?
		if ! Empty(aDados[3]+aDados[4]+aDados[5]+aDados[6]+aDados[7]+aDados[8]) ; 
			.OR. ( '8******' $ aDados[1] .and. aDados[2] == " --- Total" )
			lFazer := .T.
		else // não faz consulta
			lFazer := .F.
		end
	end

	if lFazer
		if Empty(cTipOper)
			cTipOper := IIF( 'DEVOL' $ UPPER(cTitTela), 'DEV', 'VEN' )
			cTipOper := IIF( 'TOTAL' $ UPPER(cTitTela), 'TOTAL', cTipOper )
		end
	
		aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
		aAdd( aObjects, { 0, 10, .T., .f. } ) // Filtro no topo
		aAdd( aObjects, { 0, 30, .T., .T. } ) // ListBox Atendimentos
		aPos := MsObjSize( aInfo, aObjects )
		ProcRegua(len(aEmpr)+2)
		IncProc(STR0020) // Levantando...
	
		if cTipOper == "TOTAL" .OR. cTipOper == "TOT"
			FS_LEVDADOS( 'VEN'    , cModVei , dDtI , dDtF , aDados , cAnoMes , @aAtend , nColClick )
			FS_LEVDADOS( 'DEV'    , cModVei , dDtI , dDtF , aDados , cAnoMes , @aAtend , nColClick )
		else
			FS_LEVDADOS( cTipOper , cModVei , dDtI , dDtF , aDados , cAnoMes , @aAtend , nColClick )
		end
	
		IncProc(STR0020) // Levantando...
	End

	//se não era pra fazer ou fez mas não tem dados
	If ! lFazer .OR. len(aAtend) == 0
		MsgStop(STR0003,STR0002) // Nao existem dados para esta Consulta ! / Atencao
		Return()
	EndIf

	aSort(aAtend,1,,{|x,y| x[1]+x[2] < y[1]+y[2] })
	DEFINE MSDIALOG oAteVeic FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta Gerencial de Veiculos
		oAteVeic:lEscClose := .F.
		@ aPos[1,1]+2,aPos[1,2]+3 SAY cTitTela SIZE 350,08 OF oAteVeic PIXEL COLOR CLR_RED FONT oTitTela
		@ aPos[1,1],aPos[1,4]-45 BUTTON oGrpSair PROMPT STR0010 OF oAteVeic SIZE 45,10 PIXEL ACTION oAteVeic:End() // SAIR
		@ aPos[2,1],aPos[2,2] LISTBOX oLbAtend FIELDS HEADER STR0054,;		// Filial da NF
															STR0038,;			// Atendimento
															STR0055,;			// Filial da Negociacao
															STR0042,;			// Tipo
															STR0039,;			// Data
															STR0040,;			// Cliente
															STR0041,;			// Valor
															STR0065,;			// Complemento NF
															STR0037;			// Veiculo / Chassi
															COLSIZES 60,40,60,40,25,120,45,45,120 SIZE aPos[2,4]-2,aPos[2,3]-15 OF oAteVeic PIXEL ON DBLCLICK FS_VERATEND(aAtend[oLbAtend:nAt,1],aAtend[oLbAtend:nAt,2])
		oLbAtend:SetArray(aAtend)
		oLbAtend:bLine := { || { ;
			aAtend[oLbAtend:nAt,1] ,;
			aAtend[oLbAtend:nAt,2] ,;
			aAtend[oLbAtend:nAt,7] ,;
			aAtend[oLbAtend:nAt,8] ,;
			Transform(aAtend[oLbAtend:nAt,3],"@D") ,;
			aAtend[oLbAtend:nAt,4] ,;
			FG_AlinVlrs(Transform(aAtend[oLbAtend:nAt,5],"@E 9999,999,999.99")) ,;
			FG_AlinVlrs(Transform(aAtend[oLbAtend:nAt,9],"@E 9999,999,999.99")) ,;
			aAtend[oLbAtend:nAt,6] ;
		}}
	ACTIVATE MSDIALOG oAteVeic
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEVDADOS| Autor ³  Vinicius Gati      ³ Data ³ 27/02/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Traz dados de venda/devolucao de veiculos                  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function FS_LEVDADOS(cTipOper,cModVei,dDtI,dDtF,aDados,cAnoMes,aAtend,nColClick)
	Local cQuery     := ""
	Local cQAlVV09   := "SQLVV09" // VV0 / VV9
	Local cQAlSA1    := "SQLSA1"  // SA1
	Local cTpAtend   := ""
	Local nValor     := 0
	Local nTotFiltro := 0
	Local nCompl     := 0
	Local cFilSALVA  := cFilAnt
	Local nEmpr      := 0
	Local lVV9FILVDA := ( VV9->(FieldPos("VV9_FILNEG")) > 0 )

	// 1 e 2 é usado para filtarr devolucoes 
	// se não foi selecionado opcao de devolucao
	// não deve conter devolucao no filtro de total
	if cTipOper $ 'DEV' .and. ( nOpcao1 != '1' .and. nOpcao1 != '2' )
		return {}
	end

	For nEmpr := 1 to len(aEmpr)
		IncProc(STR0020) // Levantando...
		cFilAnt := aEmpr[nEmpr,1]
		cQuery := " SELECT VV0.VV0_TIPFAT , VV9.VV9_FILIAL , VV0.VV0_NUMTRA , VV0.VV0_DATMOV , VV9.VV9_CODCLI , VV9.VV9_LOJA , VV9.VV9_NOMVIS , VV9.VV9_STATUS , VVA.VVA_CHASSI , VVA.VVA_CODMAR , VVA.VVA_MODVEI "
		If lVV9FILVDA
			cQuery += ", VV9.VV9_FILNEG "
		EndIf
		cQuery += ", SUM(VVA.VVA_VALMOV) VALOR "
		If cTipOper <> "DEV"
			cQuery += ", SUM(SD2.D2_TOTAL) COMPLEMENTO "
		EndIf
		cQuery += "FROM "+RetSqlName("VV0")+" VV0 "
		If cTipOper <> "DEV"
			cQuery += "JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND "
			Do Case
				Case nColClick == 1 // Vendas e Propostas
					cQuery += "VV9.VV9_STATUS IN ('F','T','O','L')"
				Case nColClick == 2 // Propostas
					cQuery += "VV9.VV9_STATUS IN ('O','L')"
				Case nColClick == 3 // Vendas
					cQuery += "VV9.VV9_STATUS IN ('F','T')"
			EndCase
			cQuery += " AND VV9.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' ) "
			cQuery += "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VVA.VVA_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
			cQuery += "LEFT JOIN "+RetSqlName("SD2")+" SD2 ON ( SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_NFORI=VV0.VV0_NUMNFI AND SD2.D2_SERIORI=VV0.VV0_SERNFI AND SD2.D2_COD=SB1.B1_COD AND SD2.D2_TIPO='C' AND SD2.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE "
			If nTipFil == 1 // Filial do Arquivo
				cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
			Else
				cQuery += "( "
				cQuery += "( VV0.VV0_FILIAL IN ("+cFilTot+") AND VV9.VV9_FILNEG='"+xFilial("VV9")+"' ) "
				cQuery += "OR "
				cQuery += "( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV9.VV9_FILNEG=' ' ) "
				cQuery += ") AND "
			EndIf
			cQuery += "VV0.VV0_OPEMOV IN (' ','0','8') AND "
			cQuery += "VV0.VV0_DATMOV>='"+dtos(dDtI)+"' AND VV0.VV0_DATMOV<='"+dtos(dDtF)+"' AND "
			If cAnoMes <> "******"
				cQuery += " VV0.VV0_DATMOV like '"+cAnoMes+"%' AND "
			end
			// Verifica o tipo
			If cModVei <> "1******"
				If LEFT(cModVei, 7) == "6******" // Faturamento Direto
					cQuery += "VV0.VV0_TIPFAT='2' AND "
				ElseIf LEFT(cModVei, 7) == "2******" .OR. LEFT(cModVei, 7) == "3******"
					cQuery += "VV0.VV0_TIPFAT='0' AND "   // Veiculo Novo ou Dev Veic Novo
				ElseIf LEFT(cModVei, 7) == "4******" .OR. LEFT(cModVei, 7) == "5******"
					cQuery += "VV0.VV0_TIPFAT='1' AND " // Veiculo Usado
				ElseIf LEN(aDados) > 8 // Marca / Grupo do Modelo
					cModelo  := aDados[ 9]
					cGModelo := aDados[10]
					cQuery += "VV0.VV0_TIPFAT IN ('0','1','2') AND VVA.VVA_CODMAR='"+cModelo+"' AND VVA.VVA_GRUMOD='"+cGModelo+"' AND "
				EndIf
			Else
				cQuery += "VV0.VV0_TIPFAT IN ('0','1') AND " //,'2'
			EndIf
			If lTIPMOV
				cQuery += "VV0.VV0_TIPMOV IN (' ','0') AND "
			EndIf		
			cQuery += "VV0.D_E_L_E_T_=' '"
			cQuery += "GROUP BY VV0.VV0_TIPFAT , VV9.VV9_FILIAL , VV0.VV0_NUMTRA , VV0.VV0_DATMOV , VV9.VV9_CODCLI , VV9.VV9_LOJA , VV9.VV9_NOMVIS , VV9.VV9_STATUS , VVA.VVA_CHASSI , VVA.VVA_CODMAR , VVA.VVA_MODVEI "
			If lVV9FILVDA
				cQuery += ", VV9.VV9_FILNEG "
			EndIf
			cQuery += ", VVA.VVA_VALMOV "
		Else
			cQuery += "JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.VV9_STATUS IN ('F','T') AND VV9.D_E_L_E_T_=' '  ) "
			cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VVA.VVA_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
			cQuery += "JOIN "+RetSqlName("SD1")+" SD1 ON ( SD1.D1_FILIAL=VV0.VV0_FILIAL AND SD1.D1_NFORI=VV0.VV0_NUMNFI AND SD1.D1_SERIORI=VV0.VV0_SERNFI AND SD1.D1_COD=SB1.B1_COD AND SD1.D1_TIPO='D' AND "
			if nOpcao1 == "2"
				cQuery += "SD1.D1_EMISSAO>='"+dtos(dDtI)+"' AND SD1.D1_EMISSAO<='"+dtos(dDtF)+"' AND "
				If cAnoMes <> "******"
					cQuery += " SD1.D1_EMISSAO like '"+cAnoMes+"%' AND "
				end
			Endif
			cQuery += "SD1.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE "
			If nTipFil == 1 // Filial do Arquivo
				cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
			Else	
				cQuery += "( "
				cQuery += "( VV0.VV0_FILIAL IN ("+cFilTot+") AND VV9.VV9_FILNEG='"+xFilial("VV9")+"' ) "
				cQuery += "OR "
				cQuery += "( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV9.VV9_FILNEG=' ' ) "
				cQuery += ") AND "
			EndIf
			cQuery += "VV0.VV0_OPEMOV IN (' ','0','8') AND " 
			if nOpcao1 <> "2"
				cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
				If cAnoMes <> "******"
					cQuery += " VV0.VV0_DATMOV like '"+cAnoMes+"%' AND "
				end
			Endif	
			// Verifica o tipo
			If cModVei <> "1******"
				If LEFT(cModVei, 7) == "6******" // Faturamento Direto
					cQuery += "VV0.VV0_TIPFAT='2' AND "
				ElseIf LEFT(cModVei, 7) == "2******" .OR. LEFT(cModVei, 7) == "3******"
					cQuery += "VV0.VV0_TIPFAT='0' AND "   // Veiculo Novo ou Dev Veic Novo
				ElseIf LEFT(cModVei, 7) == "4******" .OR. LEFT(cModVei, 7) == "5******"
					cQuery += "VV0.VV0_TIPFAT='1' AND " // Veiculo Usado
				ElseIf LEN(aDados) > 8 // Marca / Grupo do Modelo
					cModelo  := aDados[ 9]
					cGModelo := aDados[10]
					cQuery += "VV0.VV0_TIPFAT IN ('0','1','2') AND VVA.VVA_CODMAR='"+cModelo+"' AND VVA.VVA_GRUMOD='"+cGModelo+"' AND "
				EndIf
			Else
				cQuery += "VV0.VV0_TIPFAT IN ('0','1') AND "// ,'2'
			EndIf
			If lTIPMOV
				cQuery += "VV0.VV0_TIPMOV IN (' ','0') AND "
			EndIf
			cQuery += "VV0.D_E_L_E_T_=' '"
			cQuery += "GROUP BY VV0.VV0_TIPFAT , VV9.VV9_FILIAL , VV0.VV0_NUMTRA , VV0.VV0_DATMOV , VV9.VV9_CODCLI , VV9.VV9_LOJA , VV9.VV9_NOMVIS , VV9.VV9_STATUS , VVA.VVA_CHASSI , VVA.VVA_CODMAR , VVA.VVA_MODVEI "
			If lVV9FILVDA
				cQuery += ", VV9.VV9_FILNEG "
			EndIf
			cQuery += ", VVA.VVA_VALMOV "
		EndIf
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )
		Do While !( cQAlVV09 )->( Eof() )
			If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Normal Novo -> FT Novos Vlr Vendas (Qtd.Veic)
				If cComboV == STR0023 // Veiculos Usados
					( cQAlVV09 )->( DbSkip() )
					Loop
				EndIf
			ElseIf ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Normal Usado -> FT Usados Vlr Vendas (Qtd.Veic)
				If cComboV == STR0022 // Veiculos Novos
					( cQAlVV09 )->( DbSkip() )
					Loop
				EndIf
			EndIf
			nValor := ( cQAlVV09 )->( VALOR )
			nCompl := 0
			If cTipOper <> "DEV"
				nCompl := ( cQAlVV09 )->( COMPLEMENTO )
			Else
				nValor := nValor * -1
			EndIf
			nTotFiltro += nValor
			cTpAtend := ""
			If ( cQAlVV09 )->( VV9_STATUS ) $ "F/T" // Finalizado
				cTpAtend := STR0043 // Venda
			ElseIf ( cQAlVV09 )->( VV9_STATUS ) $ "O/L" // Pre-Aprovado / Aprovado
				cTpAtend := STR0044 // Proposta
			EndIf
			If !Empty( ( cQAlVV09 )->( VV9_CODCLI ) + ( cQAlVV09 )->( VV9_LOJA ) )
				// Posiciona no SA1 para mostrar A1_NOME
				cQuery := "SELECT SA1.A1_NOME FROM "+RetSqlName("SA1")+" SA1 WHERE "
				cQuery += "SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD='"+( cQAlVV09 )->( VV9_CODCLI )+"' AND SA1.A1_LOJA='"+( cQAlVV09 )->( VV9_LOJA )+"' AND SA1.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA1, .F., .T. )
				Aadd(aAtend,{ ( cQAlVV09 )->( VV9_FILIAL ) , ( cQAlVV09 )->( VV0_NUMTRA ) , Transform(stod(( cQAlVV09 )->( VV0_DATMOV )),"@D") , ( cQAlVV09 )->( VV9_CODCLI )+"-"+( cQAlVV09 )->( VV9_LOJA )+" "+left(( cQAlSA1 )->( A1_NOME ),25) , nValor , ( Alltrim(( cQAlVV09 )->( VVA_CODMAR )+" "+( cQAlVV09 )->( VVA_MODVEI ))+" ( "+Alltrim(( cQAlVV09 )->( VVA_CHASSI ))+" )" ) , IIF(lVV9FILVDA.and.!Empty(( cQAlVV09 )->( VV9_FILNEG )),( cQAlVV09 )->( VV9_FILNEG ),( cQAlVV09 )->( VV9_FILIAL )) , cTpAtend , nCompl })
				( cQAlSA1 )->( dbCloseArea() )
			Else
				Aadd(aAtend,{ ( cQAlVV09 )->( VV9_FILIAL ) , ( cQAlVV09 )->( VV0_NUMTRA ) , Transform(stod(( cQAlVV09 )->( VV0_DATMOV )),"@D") , left(( cQAlVV09 )->( VV9_NOMVIS ),30) , nValor , ( Alltrim(( cQAlVV09 )->( VVA_CODMAR )+" "+( cQAlVV09 )->( VVA_MODVEI ))+" ( "+Alltrim(( cQAlVV09 )->( VVA_CHASSI ))+" )" ) , IIF(lVV9FILVDA.and.!Empty(( cQAlVV09 )->( VV9_FILNEG )),( cQAlVV09 )->( VV9_FILNEG ),( cQAlVV09 )->( VV9_FILIAL )) , cTpAtend , nCompl })
			EndIf
		   ( cQAlVV09 )->( DbSkip() )
		EndDo
		( cQAlVV09 )->( dbCloseArea() )
	Next
	
	cFilAnt := cFilSALVA
Return aAtend

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERATEND | Autor ³  Andre Luis Almeida ³ Data ³ 14/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza Atendimento VEIXX002                             |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERATEND(cFilAte,cAtend)
Local cFilSALVA   := cFilAnt
Local nPos        := aScan(aEmpTot, {|x| x[2] == cFilAte }) // Verifica qual cFilAnt eh da Filial
Private cCadastro := (STR0038) // Atendimento
If nPos > 0
	cFilAnt := left(aEmpTot[nPos,1],len(cFilAnt))
	DbSelectArea("VV9")
	DbSetOrder(1)
	If DbSeek( cFilAte + cAtend )
		If !FM_PILHA("VEIXX002") .and. !FM_PILHA("VEIXX030")
			VEIXX002(NIL,NIL,NIL,2,)
		EndIf
	EndIf
EndIf
cFilAnt := cFilSALVA
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIPGRAF | Autor ³  Andre Luis Almeida ³ Data ³ 29/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tipo de Grafico (Valor/Qtd.Veic)                           |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIPGRAF( oObj , nX , nY , oMTpGVC170 )
oMTpGVC170:Activate( nX, nY, oObj )
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GRAFICO | Autor ³  Andre Luis Almeida ³ Data ³ 29/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza Grafico                                          |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAFICO(cTp,nL)
Local aGrafico := {}
Local cTitGraf := ""
Local nGraf := 4 // 10
Local ni := 0
Local nd := IIf(cTp=="1",1000,1) // divisao
Local ns := IIf(cTp=="1",0,1) // Valor ou Qtd.Veic (Posicao no Vetor)
If nL == 1 // TOTAL
	cTitGraf := aMes[nL,2]+" "+Transform(dDatIni,"@D")+" "+STR0007+" "+Transform(dDatFin,"@D")+" ( "+IIf(cTp=="1",STR0046,STR0047)+" )"+cEmpr // Titulo Grafico // Valores em Milhar
	For ni := 2 to len(aMes)
		Aadd(aGrafico,{int(((aMes[ni,03+ns]+aMes[ni,07+ns])/nd)),aMes[ni,2],CLR_RED})
		Aadd(aGrafico,{int((aMes[ni,11+ns]/nd)),aMes[ni,2],CLR_GREEN})
		Aadd(aGrafico,{int((aMes[ni,13+ns]/nd)),aMes[ni,2],CLR_YELLOW})
	Next
Else // MES
	cTitGraf := aMes[nL,2]+" ( "+IIf(cTp=="1",STR0046,STR0047)+" )"+cEmpr // Titulo Grafico // Valores em Milhar
	For ni := 1 to len(aDia)
		Aadd(aGrafico,{int(((aDia[ni,03+ns]+aDia[ni,07+ns])/nd)),left(aDia[ni,2],2),CLR_RED})
		Aadd(aGrafico,{int((aDia[ni,11+ns]/nd)),left(aDia[ni,2],2),CLR_GREEN})
		Aadd(aGrafico,{int((aDia[ni,13+ns]/nd)),left(aDia[ni,2],2),CLR_YELLOW})
	Next
EndIf
If len(aGrafico) > 0
    FG_GRAFICO(,cTitGraf+" "+STR0035,,,,,aGrafico,nGraf) // ( VERMELHO=Propostas / VERDE=Vendas / AMARELO=Venda Direta )
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIPRANK | Autor ³  Andre Luis Almeida ³ Data ³ 25/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tipo de Ranking Vendedor                                   |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIPRANK( oObj , nX , nY , oMTpRVC170 )
oMTpRVC170:Activate( nX, nY, oObj )
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_RANKING | Autor ³  Andre Luis Almeida ³ Data ³ 25/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza Ranking dos Vendedores                           |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RANKING(cTp,nL)
Local cTitRank := ""
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cTitTela := ""
Local cQuery   := "" // Query do SQL de Venda (VV9/VV0)
Local cQAlVV09 := "SQLVV09" // VV0 / VV9
Local cQAlSA3  := "SQLSA3"  // SA3
Local cFilSALVA:= cFilAnt
Local dDtAux   := dDataBase
Local ni       := 0
Local nEmpr    := 0
Local dDtI     := dDataBase
Local dDtF     := dDataBase
Local cSQLStat := ""
Local cSQLTFat := ""
Local lSA3Exclus := .f.
Private aRanking := {}
Private aRankNov := {}
Private aRankUsa := {}
//
If FWModeAccess("SA3",3) == "E" // Verifica se o SA3 esta exclusivo
	lSA3Exclus := .t.
EndIf
//
If cTp == "1" // Propostas Aprovadas
	cTitRank := STR0018 // Propostas Aprovadas
	cSQLStat := "VV9.VV9_STATUS IN ('O','L')"
	cSQLTFat := "VV0.VV0_TIPFAT IN ('0','1')"
ElseIf cTp == "2" // Total das Vendas
	cTitRank := STR0016 // Vlr Total das Vendas
	cSQLStat := "VV9.VV9_STATUS IN ('F','T')"
	cSQLTFat := "VV0.VV0_TIPFAT IN ('0','1')"
ElseIf cTp == "3" // Venda Direta
	cTitRank := STR0017 // Vlr Venda Direta
	cSQLStat := "VV9.VV9_STATUS IN ('F','T','O','L')"
	cSQLTFat := "VV0.VV0_TIPFAT='2'"
ElseIf cTp == "4" // Total das Vendas + Venda Direta
	cTitRank := STR0063 // Vlr Venda +  Venda Direta
	cSQLStatD := "VV9.VV9_STATUS IN ('F','T')"
	cSQLTFatD := "VV0.VV0_TIPFAT IN ('0','1')"
	cSQLStatV := "VV9.VV9_STATUS IN ('F','T','O','L')"
	cSQLTFatV := "VV0.VV0_TIPFAT='2'"
EndIf
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 10 , .T. , .F. } ) // Filtro no topo
aAdd( aObjects, { 0 , 30 , .T. , .T. } ) // ListBox Total
If cTp <> "3" // Propostas e Vendas ( diferente de Venda Direta )
	aAdd( aObjects, { 0 , 30 , .T. , .T. } ) // ListBox Novos
	aAdd( aObjects, { 0 , 30 , .T. , .T. } ) // ListBox Usados
EndIf
aPos := MsObjSize( aInfo, aObjects )
Aadd(aRanking,{0,cTitRank,0,0,0,0,""})
Aadd(aRankNov,{0,cTitRank,0,0,0,0,STR0022}) // Veiculos Novos
Aadd(aRankUsa,{0,cTitRank,0,0,0,0,STR0023}) // Veiculos Usados
ProcRegua(len(aEmpr)+2)
IncProc(STR0020) // Levantando...
For nEmpr := 1 to len(aEmpr)
	IncProc(STR0020) // Levantando...
	cFilAnt := aEmpr[nEmpr,1]
	// VENDA //
	cQuery := "SELECT VV9.VV9_STATUS , VV0.VV0_DATMOV , VV0.VV0_TIPFAT , VV0.VV0_CODVEN , COUNT(*) QTD , SUM(VVA.VVA_VALMOV) VALOR , SUM(SD2.D2_TOTAL) COMPLEMENTO "
	cQuery += "FROM "+RetSqlName("VV0")+" VV0 "
	cQuery += "JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA "
	if cTp <> "4"
		cQuery +=  "AND "+cSQLStat
	Endif	
	cQuery += " AND VV9.D_E_L_E_T_=' ' ) "
	cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VVA.VVA_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("SD2")+" SD2 ON ( SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_NFORI=VV0.VV0_NUMNFI AND SD2.D2_SERIORI=VV0.VV0_SERNFI AND SD2.D2_COD=SB1.B1_COD AND SD2.D2_TIPO='C' AND SD2.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE "
	If nTipFil == 1 // Filial do Arquivo
		cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
	Else
		cQuery += "( "
		cQuery += "( VV0.VV0_FILIAL IN ("+cFilTot+") AND VV9.VV9_FILNEG='"+xFilial("VV9")+"' ) "
		cQuery += "OR "
		cQuery += "( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV9.VV9_FILNEG=' ' ) "
		cQuery += ") AND "
	EndIf
	cQuery += "VV0.VV0_OPEMOV IN (' ','0','8') AND "
	If aMes[nL,1] <> "******"
		If left(dtos(dDatIni),6) == aMes[nL,1] // Se for o ANO MES da Data Inicial, utilizar ela.
			cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND "
			cTitTela := Transform(dDatIni,"@D")+" "+STR0007+" " // ate
			dDtI := dDatIni
		Else
			cQuery += "VV0.VV0_DATMOV>='"+aMes[nL,1]+"01' AND "
			cTitTela := Transform(stod(aMes[nL,1]+"01"),"@D")+" "+STR0007+" " // ate
			dDtI := stod(aMes[nL,1]+"01")
		EndIf
		If left(dtos(dDatFin),6) == aMes[nL,1] // Se for o ANO MES da Data Final, utilizar ela.
			cQuery += "VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
			cTitTela += Transform(dDatFin,"@D")
			dDtF := dDatFin
		Else
			dDtAux := ctod("25/"+right(aMes[nL,1],2)+"/"+right(left(aMes[nL,1],4),2))+10
			dDtAux := ( dDtAux - day(dDtAux) ) // Ultimo Dia do Mes
			cQuery += "VV0.VV0_DATMOV<='"+dtos(dDtAux)+"' AND "
			cTitTela += Transform(dDtAux,"@D")
			dDtF := dDtAux
		EndIf
	Else
		cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
		cTitTela := Transform(dDatIni,"@D")+" "+STR0007+" "+Transform(dDatFin,"@D") // ate
		dDtI := dDatIni
		dDtF := dDatFin
	EndIf
	if cTp <> "4"
		cQuery += cSQLTFat+" AND "
	Else 
		cQuery += "(("+cSQLStatD+" AND "+cSQLTFatD+")"+" OR ("+cSQLStatV+" AND "+cSQLTFatV+"))  AND "
	Endif
	If lTIPMOV
		cQuery += "VV0.VV0_TIPMOV IN (' ','0') AND "
	EndIf
	cQuery += "VV0.D_E_L_E_T_=' ' "
	cQuery += "GROUP BY VV9.VV9_STATUS , VV0.VV0_DATMOV , VV0.VV0_TIPFAT , VV0.VV0_CODVEN , VVA.VVA_VALMOV "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )
	Do While !( cQAlVV09 )->( Eof() )
		nPos := aScan(aRanking, {|x| x[2] == IIf(lSA3Exclus,aEmpr[nEmpr,1]+" ","")+( cQAlVV09 )->( VV0_CODVEN ) })
		If nPos == 0
			cQuery := "SELECT SA3.A3_NOME FROM "+RetSqlName("SA3")+" SA3 WHERE SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD='"+( cQAlVV09 )->( VV0_CODVEN )+"' AND SA3.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA3, .F., .T. )
			Aadd(aRanking,{ 1 , IIf(lSA3Exclus,aEmpr[nEmpr,1]+" ","")+( cQAlVV09 )->( VV0_CODVEN ) , 0 , 0 , 0 , 0 , ( cQAlSA3 )->( A3_NOME )})
			Aadd(aRankNov,{ 1 , IIf(lSA3Exclus,aEmpr[nEmpr,1]+" ","")+( cQAlVV09 )->( VV0_CODVEN ) , 0 , 0 , 0 , 0 , ( cQAlSA3 )->( A3_NOME ) })
			Aadd(aRankUsa,{ 1 , IIf(lSA3Exclus,aEmpr[nEmpr,1]+" ","")+( cQAlVV09 )->( VV0_CODVEN ) , 0 , 0 , 0 , 0 , ( cQAlSA3 )->( A3_NOME ) })
			( cQAlSA3 )->( dbCloseArea() )
			nPos := len(aRanking)
		EndIf
		nValor := ( cQAlVV09 )->( VALOR ) + ( cQAlVV09 )->( COMPLEMENTO )
		nQtd := ( cQAlVV09 )->( QTD ) 
		aRanking[1,3]    += nValor
		aRanking[nPos,3] += nValor
		aRanking[1,5]    += nQtd
		aRanking[nPos,5] += nQtd
		If ( cQAlVV09 )->( VV0_TIPFAT ) <> "2" // Venda ( diferente de Faturamento Direto )
			If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Normal Novo -> FT Novos Vlr Vendas (Qtd.Veic)
				aRankNov[1,3]    += nValor
				aRankNov[nPos,3] += nValor
				aRankNov[1,5]    += nQtd
				aRankNov[nPos,5] += nQtd
			Else//If ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Normal Usado -> FT Usados Vlr Vendas (Qtd.Veic)
				aRankUsa[1,3]    += nValor
				aRankUsa[nPos,3] += nValor
				aRankUsa[1,5]    += nQtd
				aRankUsa[nPos,5] += nQtd
			EndIf
		EndIf
	   	( cQAlVV09 )->( DbSkip() )
	EndDo
	( cQAlVV09 )->( dbCloseArea() )

	// Devolucao de venda
	if nOpcao1 <> "0" .and. nOpcao1 <> "3"
		cQuery := "SELECT VV9.VV9_STATUS , SD1.D1_EMISSAO , VV0.VV0_DATMOV , VV0.VV0_TIPFAT , VVA.VVA_VALMOV , VV0.VV0_CODVEN "
		cQuery += "FROM "+RetSqlName("VV0")+" VV0 "
		cQuery += "JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA "
		if cTp <> "4"
			cQuery += "AND "+cSQLStat
		Endif
		cQuery += " AND VV9.D_E_L_E_T_=' ' ) "
		cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' ) "
		cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VVA.VVA_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
		cQuery += "JOIN "+RetSqlName("SD1")+" SD1 ON ( SD1.D1_FILIAL=VV0.VV0_FILIAL AND SD1.D1_NFORI=VV0.VV0_NUMNFI AND SD1.D1_SERIORI=VV0.VV0_SERNFI AND SD1.D1_COD=SB1.B1_COD AND SD1.D1_TIPO='D' AND "
		if nOpcao1 == "2"
			If aMes[nL,1] <> "******"
				If left(dtos(dDatIni),6) == aMes[nL,1] // Se for o ANO MES da Data Inicial, utilizar ela.
					cQuery += "SD1.D1_EMISSAO>='"+dtos(dDatIni)+"' AND "
				Else
					cQuery += "SD1.D1_EMISSAO>='"+aMes[nL,1]+"01' AND "
				EndIf
				If left(dtos(dDatFin),6) == aMes[nL,1] // Se for o ANO MES da Data Final, utilizar ela.
					cQuery += "SD1.D1_EMISSAO<='"+dtos(dDatFin)+"' AND "
				Else
					cQuery += "SD1.D1_EMISSAO<='"+dtos(dDtAux)+"' AND "
			    Endif
			EndIf
		Else
			if nOpcao1 <> "2"
				cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
		    Endif
			cTitTela := Transform(dDatIni,"@D")+" "+STR0007+" "+Transform(dDatFin,"@D") // ate
			dDtI := dDatIni
			dDtF := dDatFin
		EndIf
		cQuery += "SD1.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE "
		If nTipFil == 1 // Filial do Arquivo
			cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
		Else
			cQuery += "( "
			cQuery += "( VV0.VV0_FILIAL IN ("+cFilTot+") AND VV9.VV9_FILNEG='"+xFilial("VV9")+"' ) "
			cQuery += "OR "
			cQuery += "( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV9.VV9_FILNEG=' ' ) "
			cQuery += ") AND "
		EndIf
		cQuery += "VV0.VV0_OPEMOV IN (' ','0','8') AND "
		If aMes[nL,1] <> "******"
			If left(dtos(dDatIni),6) == aMes[nL,1] // Se for o ANO MES da Data Inicial, utilizar ela.
				if nOpcao1 <> "2"
					cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND "  
				Endif	
				cTitTela := Transform(dDatIni,"@D")+" "+STR0007+" " // ate
				dDtI := dDatIni
			Else
				if nOpcao1 <> "2"
					cQuery += "VV0.VV0_DATMOV>='"+aMes[nL,1]+"01' AND "
			    Endif
				cTitTela := Transform(stod(aMes[nL,1]+"01"),"@D")+" "+STR0007+" " // ate
				dDtI := stod(aMes[nL,1]+"01")
			EndIf
			If left(dtos(dDatFin),6) == aMes[nL,1] // Se for o ANO MES da Data Final, utilizar ela.
				if nOpcao1 <> "2"
					cQuery += "VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
			    Endif
				cTitTela += Transform(dDatFin,"@D")
				dDtF := dDatFin
			Else
				dDtAux := ctod("25/"+right(aMes[nL,1],2)+"/"+right(left(aMes[nL,1],4),2))+10
				dDtAux := ( dDtAux - day(dDtAux) ) // Ultimo Dia do Mes
				if nOpcao1 <> "2"
					cQuery += "VV0.VV0_DATMOV<='"+dtos(dDtAux)+"' AND "
			    Endif
				cTitTela += Transform(dDtAux,"@D")
				dDtF := dDtAux
			EndIf
		Else
			if nOpcao1 <> "2"
				cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
		    Endif
			cTitTela := Transform(dDatIni,"@D")+" "+STR0007+" "+Transform(dDatFin,"@D") // ate
			dDtI := dDatIni
			dDtF := dDatFin
		EndIf
		if cTp <> "4"
			cQuery += cSQLTFat+" AND "
		Else 
			cQuery += "(("+cSQLStatD+" AND "+cSQLTFatD+")"+" OR ("+cSQLStatV+" AND "+cSQLTFatV+")) AND "
		Endif
		If lTIPMOV
			cQuery += "VV0.VV0_TIPMOV IN (' ','0') AND "
		EndIf
		cQuery += "VV0.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )
		Do While !( cQAlVV09 )->( Eof() )
			nPos := aScan(aRanking, {|x| x[2] == IIf(lSA3Exclus,aEmpr[nEmpr,1]+" ","")+( cQAlVV09 )->( VV0_CODVEN ) })
			If nPos == 0
				cQuery := "SELECT SA3.A3_NOME FROM "+RetSqlName("SA3")+" SA3 WHERE SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD='"+( cQAlVV09 )->( VV0_CODVEN )+"' AND SA3.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA3, .F., .T. )
				Aadd(aRanking,{ 1 , IIf(lSA3Exclus,aEmpr[nEmpr,1]+" ","")+( cQAlVV09 )->( VV0_CODVEN ) , 0 , 0 , 0 , 0 , ( cQAlSA3 )->( A3_NOME )})
				Aadd(aRankNov,{ 1 , IIf(lSA3Exclus,aEmpr[nEmpr,1]+" ","")+( cQAlVV09 )->( VV0_CODVEN ) , 0 , 0 , 0 , 0 , ( cQAlSA3 )->( A3_NOME ) })
				Aadd(aRankUsa,{ 1 , IIf(lSA3Exclus,aEmpr[nEmpr,1]+" ","")+( cQAlVV09 )->( VV0_CODVEN ) , 0 , 0 , 0 , 0 , ( cQAlSA3 )->( A3_NOME ) })
				( cQAlSA3 )->( dbCloseArea() )
				nPos := len(aRanking)
			EndIf
			nValor := ( cQAlVV09 )->( VVA_VALMOV )
			aRanking[1,3]    -= nValor
			aRanking[nPos,3] -= nValor
			aRanking[1,5]    -= 1
			aRanking[nPos,5] -= 1
			If ( cQAlVV09 )->( VV0_TIPFAT ) <> "2" // Venda ( diferente de Faturamento Direto )
				If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Normal Novo -> FT Novos Vlr Vendas (Qtd.Veic)
					aRankNov[1,3]    -= nValor
					aRankNov[nPos,3] -= nValor
					aRankNov[1,5]    -= 1
					aRankNov[nPos,5] -= 1
				Else//If ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Normal Usado -> FT Usados Vlr Vendas (Qtd.Veic)
					aRankUsa[1,3]    -= nValor
					aRankUsa[nPos,3] -= nValor
					aRankUsa[1,5]    -= 1
					aRankUsa[nPos,5] -= 1
				EndIf
			EndIf
	   		( cQAlVV09 )->( DbSkip() )
		EndDo
		( cQAlVV09 )->( dbCloseArea() )
	Endif	
Next
cFilAnt := cFilSALVA
IncProc(STR0020) // Levantando...
For ni := 1 to len(aRanking)
	aRankNov[ni,4] := aRanking[ni,3]
	aRankNov[ni,6] := aRanking[ni,5]
	aRankUsa[ni,4] := aRanking[ni,3]
	aRankUsa[ni,6] := aRanking[ni,5]
Next
//
FS_ORDRANK(0,cTp) // Ordena Ranking
//
DEFINE MSDIALOG oRank FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta Gerencial de Veiculos
	oRank:lEscClose := .F.
	@ aPos[1,1]+2,aPos[1,2]+3 SAY cTitTela SIZE 400,08 OF oRank PIXEL COLOR CLR_RED FONT oTitTela
	@ aPos[1,1],aPos[1,4]-045 BUTTON oGrpSair PROMPT STR0010 OF oRank SIZE 45,10 PIXEL ACTION oRank:End() // SAIR

	// TOTAL //
	@ aPos[2,1],aPos[2,2] LISTBOX oLbRanking FIELDS HEADER STR0052,STR0053,STR0060+aRanking[1,2],"% "+STR0060,"",STR0061+aRanking[1,2],"% "+STR0061,"" COLSIZES 20,150,70,40,40,70,40,40 SIZE aPos[2,4]-2,aPos[2,3]-15 OF oRank PIXEL // Rank / Vendedor
	oLbRanking:SetArray(aRanking)
	oLbRanking:bLine := { || { IIf(aRanking[oLbRanking:nAt,1]<>0,strzero(aRanking[oLbRanking:nAt,1],4)," ") ,;
								aRanking[oLbRanking:nAt,2]+" - "+aRanking[oLbRanking:nAt,7] ,;
	    	            		FG_AlinVlrs(Transform(aRanking[oLbRanking:nAt,3],"@E 999,999,999,999.99")) ,;
	    	            		FG_AlinVlrs(Transform((aRanking[oLbRanking:nAt,3]/aRanking[1,3])*100,"@E 99999")+"%") ,;
		    	            	FG_AlinVlrs(space(10)) ,;
		    	            	FG_AlinVlrs(Transform(aRanking[oLbRanking:nAt,5],"@E 999,999,999,999")) ,;
		    	            	FG_AlinVlrs(Transform((aRanking[oLbRanking:nAt,5]/aRanking[1,5])*100,"@E 99999")+"%") ,;
	    		            	FG_AlinVlrs(space(10)) }}
	oLbRanking:bHeaderClick := {|oObj,nCol| FS_ORDRANK(nCol,cTp) , }

	If cTp <> "3" // Propostas e Vendas ( diferente de Venda Direta )

		// NOVOS //
		@ aPos[3,1],aPos[3,2] LISTBOX oLbRankNov FIELDS HEADER STR0052,STR0053,STR0060+STR0022,"% "+STR0060,("% "+STR0060+STR0053),STR0061+STR0022,"% "+STR0061,("% "+STR0061+STR0053) COLSIZES 20,150,70,40,40,70,40,40 SIZE aPos[3,4]-2,aPos[2,3]-15 OF oRank PIXEL // Rank / Vendedor / Veiculos Novos / % Vendedor
		oLbRankNov:SetArray(aRankNov)
		oLbRankNov:bLine := { || { IIf(aRankNov[oLbRankNov:nAt,1]<>0,strzero(aRankNov[oLbRankNov:nAt,1],4)," ") ,;
									aRankNov[oLbRankNov:nAt,2]+" - "+aRankNov[oLbRankNov:nAt,7],;
	     	            			FG_AlinVlrs(Transform(aRankNov[oLbRankNov:nAt,3],"@E 999,999,999,999.99")) ,;
	     	            			FG_AlinVlrs(Transform((aRankNov[oLbRankNov:nAt,3]/aRankNov[1,3])*100,"@E 99999")+"%")  ,;
									FG_AlinVlrs(Transform((aRankNov[oLbRankNov:nAt,3]/aRankNov[oLbRankNov:nAt,4])*100,"@E 99999")+"%") ,;
	     	            			FG_AlinVlrs(Transform(aRankNov[oLbRankNov:nAt,5],"@E 999,999,999,999")) ,;
	     	            			FG_AlinVlrs(Transform((aRankNov[oLbRankNov:nAt,5]/aRankNov[1,5])*100,"@E 99999")+"%")  ,;
									FG_AlinVlrs(Transform((aRankNov[oLbRankNov:nAt,5]/aRankNov[oLbRankNov:nAt,6])*100,"@E 99999")+"%") }}
		oLbRankNov:bHeaderClick := {|oObj,nCol| FS_ORDRANK(nCol,cTp) , }
									
		// USADOS //
		@ aPos[4,1],aPos[4,2] LISTBOX oLbRankUsa FIELDS HEADER STR0052,STR0053,STR0060+STR0023,"% "+STR0060,("% "+STR0060+STR0053),STR0061+STR0023,"% "+STR0061,("% "+STR0061+STR0053) COLSIZES 20,150,70,40,40,70,40,40 SIZE aPos[4,4]-2,aPos[2,3]-15 OF oRank PIXEL // Rank / Vendedor / Veiculos Usados / % Vendedor
		oLbRankUsa:SetArray(aRankUsa)
		oLbRankUsa:bLine := { || { IIf(aRankUsa[oLbRankUsa:nAt,1]<>0,strzero(aRankUsa[oLbRankUsa:nAt,1],4)," ") ,;
									aRankUsa[oLbRankUsa:nAt,2]+" - "+aRankUsa[oLbRankUsa:nAt,7] ,;
	     	            			FG_AlinVlrs(Transform(aRankUsa[oLbRankUsa:nAt,3],"@E 999,999,999,999.99")) ,;
	     	            			FG_AlinVlrs(Transform((aRankUsa[oLbRankUsa:nAt,3]/aRankUsa[1,3])*100,"@E 99999")+"%")  ,;
									FG_AlinVlrs(Transform((aRankUsa[oLbRankUsa:nAt,3]/aRankUsa[oLbRankUsa:nAt,4])*100,"@E 99999")+"%") ,;
	     	            			FG_AlinVlrs(Transform(aRankUsa[oLbRankUsa:nAt,5],"@E 999,999,999,999")) ,;
	     	            			FG_AlinVlrs(Transform((aRankUsa[oLbRankUsa:nAt,5]/aRankUsa[1,5])*100,"@E 99999")+"%")  ,;
									FG_AlinVlrs(Transform((aRankUsa[oLbRankUsa:nAt,5]/aRankUsa[oLbRankUsa:nAt,6])*100,"@E 99999")+"%") }}
		oLbRankUsa:bHeaderClick := {|oObj,nCol| FS_ORDRANK(nCol,cTp) , }

	EndIf
ACTIVATE MSDIALOG oRank
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ORDRANK | Autor ³  Andre Luis Almeida ³ Data ³ 21/03/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ordenar vetores do Ranking                                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ORDRANK(nCol,cTp)
Local ni   := 0
Local nPos := 0
//
For ni := 1 to len(aRanking)
	If aRanking[ni,1] > 1
		aRanking[ni,1] := 1
 	EndIf
Next
For ni := 1 to len(aRankNov)
	If aRankNov[ni,1] > 1
		aRankNov[ni,1] := 1
 	EndIf
Next
For ni := 1 to len(aRankUsa)
	If aRankUsa[ni,1] >= 1
		aRankUsa[ni,1] := 1
 	EndIf
Next
//
If nCol <= 5 // Valor
	aSort(aRanking,1,,{|x,y| (1000000000-x[1])+x[3] > (1000000000-y[1])+y[3] })
	aSort(aRankNov,1,,{|x,y| (1000000000-x[1])+x[3] > (1000000000-y[1])+y[3] })
	aSort(aRankUsa,1,,{|x,y| (1000000000-x[1])+x[3] > (1000000000-y[1])+y[3] })
Else // Qtde
	aSort(aRanking,1,,{|x,y| (1000000000-x[1])+x[5] > (1000000000-y[1])+y[5] })
	aSort(aRankNov,1,,{|x,y| (1000000000-x[1])+x[5] > (1000000000-y[1])+y[5] })
	aSort(aRankUsa,1,,{|x,y| (1000000000-x[1])+x[5] > (1000000000-y[1])+y[5] })
EndIf
nPos := 1
For ni := 1 to len(aRanking)
	If aRanking[ni,1] == 1
		aRanking[ni,1] := nPos++
 	EndIf
Next
nPos := 1
For ni := 1 to len(aRankNov)
	If aRankNov[ni,1] == 1
		aRankNov[ni,1] := nPos++
 	EndIf
Next
nPos := 1
For ni := 1 to len(aRankUsa)
	If aRankUsa[ni,1] == 1
		aRankUsa[ni,1] := nPos++
 	EndIf
Next
//
If nCol > 0
	oLbRanking:SetArray(aRanking)
	oLbRanking:bLine := { || { IIf(aRanking[oLbRanking:nAt,1]<>0,strzero(aRanking[oLbRanking:nAt,1],4)," ") ,;
								aRanking[oLbRanking:nAt,2]+" - "+aRanking[oLbRanking:nAt,7] ,;
	    	            		FG_AlinVlrs(Transform(aRanking[oLbRanking:nAt,3],"@E 999,999,999,999.99")) ,;
	    	            		FG_AlinVlrs(Transform((aRanking[oLbRanking:nAt,3]/aRanking[1,3])*100,"@E 99999")+"%") ,;
		    	            	FG_AlinVlrs(space(10)) ,;
		    	            	FG_AlinVlrs(Transform(aRanking[oLbRanking:nAt,5],"@E 999,999,999,999")) ,;
		    	            	FG_AlinVlrs(Transform((aRanking[oLbRanking:nAt,5]/aRanking[1,5])*100,"@E 99999")+"%") ,;
	    		            	FG_AlinVlrs(space(10)) }}
	oLbRanking:Refresh()
	If cTp <> "3" // Propostas e Vendas ( diferente de Venda Direta )
		// NOVOS //
		oLbRankNov:SetArray(aRankNov)
		oLbRankNov:bLine := { || { IIf(aRankNov[oLbRankNov:nAt,1]<>0,strzero(aRankNov[oLbRankNov:nAt,1],4)," ") ,;
									aRankNov[oLbRankNov:nAt,2]+" - "+aRankNov[oLbRankNov:nAt,7],;
	     	            			FG_AlinVlrs(Transform(aRankNov[oLbRankNov:nAt,3],"@E 999,999,999,999.99")) ,;
	     	            			FG_AlinVlrs(Transform((aRankNov[oLbRankNov:nAt,3]/aRankNov[1,3])*100,"@E 99999")+"%")  ,;
									FG_AlinVlrs(Transform((aRankNov[oLbRankNov:nAt,3]/aRankNov[oLbRankNov:nAt,4])*100,"@E 99999")+"%") ,;
	     	            			FG_AlinVlrs(Transform(aRankNov[oLbRankNov:nAt,5],"@E 999,999,999,999")) ,;
	     	            			FG_AlinVlrs(Transform((aRankNov[oLbRankNov:nAt,5]/aRankNov[1,5])*100,"@E 99999")+"%")  ,;
									FG_AlinVlrs(Transform((aRankNov[oLbRankNov:nAt,5]/aRankNov[oLbRankNov:nAt,6])*100,"@E 99999")+"%") }}
		oLbRankNov:Refresh()
		// USADOS //
		oLbRankUsa:SetArray(aRankUsa)
		oLbRankUsa:bLine := { || { IIf(aRankUsa[oLbRankUsa:nAt,1]<>0,strzero(aRankUsa[oLbRankUsa:nAt,1],4)," ") ,;
									aRankUsa[oLbRankUsa:nAt,2]+" - "+aRankUsa[oLbRankUsa:nAt,7] ,;
	     	            			FG_AlinVlrs(Transform(aRankUsa[oLbRankUsa:nAt,3],"@E 999,999,999,999.99")) ,;
	     	            			FG_AlinVlrs(Transform((aRankUsa[oLbRankUsa:nAt,3]/aRankUsa[1,3])*100,"@E 99999")+"%")  ,;
									FG_AlinVlrs(Transform((aRankUsa[oLbRankUsa:nAt,3]/aRankUsa[oLbRankUsa:nAt,4])*100,"@E 99999")+"%") ,;
	     	            			FG_AlinVlrs(Transform(aRankUsa[oLbRankUsa:nAt,5],"@E 999,999,999,999")) ,;
	     	            			FG_AlinVlrs(Transform((aRankUsa[oLbRankUsa:nAt,5]/aRankUsa[1,5])*100,"@E 99999")+"%")  ,;
									FG_AlinVlrs(Transform((aRankUsa[oLbRankUsa:nAt,5]/aRankUsa[oLbRankUsa:nAt,6])*100,"@E 99999")+"%") }}
		oLbRankUsa:Refresh()
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILxFIL | Autor ³  Andre Luis Almeida ³ Data ³ 30/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Comparacao da Filial x Filiais                             |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILxFIL(cAnoMes,nTp)
Local oFilHelp  := DMS_FilialHelper():New()
Local aSM0      := oFilHelp:GetAllFilPermis(.f.)
Local cFilSALVA := cFilAnt
Local nCont     := 0
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cTitTela  := ""
Local cQuery    := "" // Query do SQL de Venda (VV9/VV0)
Local cQAlVV09  := "SQLVV09" // VV0 / VV9
Local dDtAux    := dDataBase
Local nLin      := 0
Local nCol      := 0
Local ni        := 0
Local nEmpr     := 0
Local dDtI      := dDataBase
Local dDtF      := dDataBase
Local aEmpresa  := {}
DEFINE FONT oTitTela NAME "Arial" SIZE 11,15 BOLD
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 10 , .T. , .F. } ) // Filtro no topo
aAdd( aObjects, { 0 , 30 , .T. , .T. } ) // ListBox Empresas
aPos := MsObjSize( aInfo, aObjects )
aAdd( aEmpresa , { ""    , STR0029        , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) // TOTAL PERIODO
aAdd( aEmpresa , { cFilAnt , FWFilialName() , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) // Filial Atual
aAdd( aEmpresa , { ""    , STR0050        , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) // Demais Filiais
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	If cFilAnt <> cFilSALVA
		aAdd( aEmpresa , { cFilAnt , FWFilialName() , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) // Filiais
	EndIf
Next
ProcRegua(len(aEmpresa)+2)
IncProc(STR0020) // Levantando...
For nEmpr := 1 to len(aEmpresa)
	IncProc(STR0020) // Levantando...
	If aEmpresa[nEmpr,1] <> ""
		cFilAnt := aEmpresa[nEmpr,1]
		// VENDA //
		cQuery := "SELECT VV9.VV9_STATUS , VV0.VV0_TIPFAT , COUNT(*) QTD , SUM(VVA.VVA_VALMOV) VALOR , SUM(SD2.D2_TOTAL) COMPLEMENTO "
		cQuery += "FROM "+RetSqlName("VV0")+" VV0 "
		cQuery += "JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.VV9_STATUS IN ('F','T','O','L') AND VV9.D_E_L_E_T_=' ' ) "
		cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VVA.VVA_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSqlName("SD2")+" SD2 ON ( SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_NFORI=VV0.VV0_NUMNFI AND SD2.D2_SERIORI=VV0.VV0_SERNFI AND SD2.D2_COD=SB1.B1_COD AND SD2.D2_TIPO='C' AND SD2.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE "
		If nTipFil == 1 // Filial do Arquivo
			cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
		Else
			cQuery += "( "
			cQuery += "( VV0.VV0_FILIAL IN ("+cFilTot+") AND VV9.VV9_FILNEG='"+xFilial("VV9")+"' ) "
			cQuery += "OR "
			cQuery += "( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV9.VV9_FILNEG=' ' ) "
			cQuery += ") AND "
		EndIf
		cQuery += "VV0.VV0_OPEMOV IN (' ','0','8') AND "
	  	If cAnoMes <> "******"
			If left(dtos(dDatIni),6) == cAnoMes // Se for o ANO MES da Data Inicial, utilizar ela.
				cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND "
				cTitTela := STR0049+" - "+Transform(dDatIni,"@D")+" "+STR0007+" " // Filial x Filiais / ate
				dDtI := dDatIni
			Else
				cQuery += "VV0.VV0_DATMOV>='"+cAnoMes+"01' AND "
				cTitTela := STR0049+" - "+Transform(stod(cAnoMes+"01"),"@D")+" "+STR0007+" " // Filial x Filiais / ate
				dDtI := stod(cAnoMes+"01")
			EndIf
			If left(dtos(dDatFin),6) == cAnoMes // Se for o ANO MES da Data Final, utilizar ela.
				cQuery += "VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
				cTitTela += Transform(dDatFin,"@D")
				dDtF := dDatFin
			Else
				dDtAux := ctod("25/"+right(cAnoMes,2)+"/"+right(left(cAnoMes,4),2))+10
				dDtAux := ( dDtAux - day(dDtAux) ) // Ultimo Dia do Mes
				cQuery += "VV0.VV0_DATMOV<='"+dtos(dDtAux)+"' AND "
				cTitTela += Transform(dDtAux,"@D")
				dDtF := dDtAux
			EndIf
		Else
			cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
			cTitTela := STR0049+" - "+Transform(dDatIni,"@D")+" "+STR0007+" "+Transform(dDatFin,"@D") // Filial x Filiais / ate
			dDtI := dDatIni
			dDtF := dDatFin
		EndIf
		cQuery += "VV0.VV0_TIPFAT IN ('0','1','2') AND "
		If lTIPMOV
			cQuery += "VV0.VV0_TIPMOV IN (' ','0') AND "
		EndIf
		cQuery += "VV0.D_E_L_E_T_=' ' "
		cQuery += "GROUP BY VV9.VV9_STATUS , VV0.VV0_TIPFAT , VVA.VVA_VALMOV "
		nLin := aScan(aEmpresa,{|x| x[1] == cFilAnt })
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )
		Do While !( cQAlVV09 )->( Eof() )
			If ( cQAlVV09 )->( VV0_TIPFAT ) == "2" // Faturamento Direto -> Vlr Venda Direta (Qtd.Veic) - 13/14
				nCol := 13
			Else
				If ( cQAlVV09 )->( VV9_STATUS ) $ "F/T" // Finalizado
					If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Normal Novo -> FT Novos Vlr Vendas (Qtd.Veic) - 5/6
						nCol := 5
					Else//If ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Normal Usado -> FT Usados Vlr Vendas (Qtd.Veic) - 9/10
						nCol := 9
					EndIf
				ElseIf ( cQAlVV09 )->( VV9_STATUS ) $ "O/L" // Pre-Aprovado / Aprovado
					If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Normal Novo -> OL Novos Propostas Aprovadas (Qtd.Veic) - 3/4
				    	nCol := 3
					Else//If ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Normal Usado -> OL Usados Propostas Aprovadas (Qtd.Veic) - 7/8
						nCol := 7
					EndIf
				EndIf
			EndIf
			nValor := ( cQAlVV09 )->( VALOR ) + ( cQAlVV09 )->( COMPLEMENTO )
			nQtd   := ( cQAlVV09 )->( QTD ) 			
			aEmpresa[1,nCol] += nValor  
			aEmpresa[1,nCol+1]+= nQtd
			aEmpresa[nLin,nCol] += nValor
			aEmpresa[nLin,nCol+1]+= nQtd
			If nLin > 3
				aEmpresa[3,nCol] += nValor
				aEmpresa[3,nCol+1]+= nQtd
			EndIf
		   	( cQAlVV09 )->( DbSkip() )
		EndDo
		( cQAlVV09 )->( dbCloseArea() )
		if nOpcao1 <> "0" .and. nOpcao1 <> "3"
			// Devolucoes de venda 
			cQuery := "SELECT VV9.VV9_STATUS , VV0.VV0_TIPFAT , VVA.VVA_VALMOV "
			cQuery += "FROM "+RetSqlName("VV0")+" VV0 "
			cQuery += "JOIN "+RetSqlName("VV9")+" VV9 ON VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.VV9_STATUS IN ('F','T') AND VV9.D_E_L_E_T_=' ' "
			cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' "
			cQuery += "JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D1_FILIAL=VV0.VV0_FILIAL AND SD1.D1_NFORI=VV0.VV0_NUMNFI AND SD1.D1_SERIORI=VV0.VV0_SERNFI AND SD1.D1_COD=SB1.B1_COD AND SD1.D1_TIPO='D' AND "
			if nOpcao1 == "2"
		  		If cAnoMes <> "******"
					If left(dtos(dDatIni),6) == cAnoMes // Se for o ANO MES da Data Inicial, utilizar ela.
						cQuery += "SD1.D1_EMISSAO>='"+dtos(dDatIni)+"' AND "
					Else
						cQuery += "SD1.D1_EMISSAO>='"+cAnoMes+"01' AND "
					EndIf
					If left(dtos(dDatFin),6) == cAnoMes // Se for o ANO MES da Data Final, utilizar ela.
						cQuery += "SD1.D1_EMISSAO<='"+dtos(dDatFin)+"' AND "
					Else
						cQuery += "SD1.D1_EMISSAO<='"+dtos(dDtAux)+"' AND "
					EndIf
				Else
					cQuery += "SD1.D1_EMISSAO>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
				EndIf
			Endif
			cQuery += "SD1.D_E_L_E_T_=' ' "
			cQuery += "WHERE "
			If nTipFil == 1 // Filial do Arquivo
				cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
			Else
				cQuery += "( "
				cQuery += "( VV0.VV0_FILIAL IN ("+cFilTot+") AND VV9.VV9_FILNEG='"+xFilial("VV9")+"' ) "
				cQuery += "OR "
				cQuery += "( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV9.VV9_FILNEG=' ' ) "
				cQuery += ") AND "
			EndIf
			cQuery += "VV0.VV0_OPEMOV IN (' ','0','8') AND "
	  		If cAnoMes <> "******"
				If left(dtos(dDatIni),6) == cAnoMes // Se for o ANO MES da Data Inicial, utilizar ela.
					if nOpcao1 <> "2"
						cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND "
				    Endif
					cTitTela := STR0049+" - "+Transform(dDatIni,"@D")+" "+STR0007+" " // Filial x Filiais / ate
					dDtI := dDatIni
				Else
					if nOpcao1 <> "2"
						cQuery += "VV0.VV0_DATMOV>='"+cAnoMes+"01' AND "
				    Endif
					cTitTela := STR0049+" - "+Transform(stod(cAnoMes+"01"),"@D")+" "+STR0007+" " // Filial x Filiais / ate
					dDtI := stod(cAnoMes+"01")
				EndIf
				If left(dtos(dDatFin),6) == cAnoMes // Se for o ANO MES da Data Final, utilizar ela.
					if nOpcao1 <> "2"
						cQuery += "VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
				    Endif
					cTitTela += Transform(dDatFin,"@D")
					dDtF := dDatFin
				Else
					dDtAux := ctod("25/"+right(cAnoMes,2)+"/"+right(left(cAnoMes,4),2))+10
					dDtAux := ( dDtAux - day(dDtAux) ) // Ultimo Dia do Mes
					if nOpcao1 <> "2"
						cQuery += "VV0.VV0_DATMOV<='"+dtos(dDtAux)+"' AND "
					Endif	
					cTitTela += Transform(dDtAux,"@D")
					dDtF := dDtAux
				EndIf
			Else
				if nOpcao1 <> "2"
					cQuery += "VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "                   
				Endif	
				cTitTela := STR0049+" - "+Transform(dDatIni,"@D")+" "+STR0007+" "+Transform(dDatFin,"@D") // Filial x Filiais / ate
				dDtI := dDatIni
				dDtF := dDatFin
			EndIf
			cQuery += "VV0.VV0_TIPFAT IN ('0','1','2') AND "
			If lTIPMOV
				cQuery += "VV0.VV0_TIPMOV IN (' ','0') AND "
			EndIf
			cQuery += "VV0.D_E_L_E_T_=' '"
			nLin := aScan(aEmpresa,{|x| x[1] == cFilAnt })
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )
			Do While !( cQAlVV09 )->( Eof() )
				If ( cQAlVV09 )->( VV9_STATUS ) $ "F/T" // Finalizado
					If ( cQAlVV09 )->( VV0_TIPFAT ) == "0" // Normal Novo -> FT Novos Vlr Vendas (Qtd.Veic) - 5/6
						nCol := 5
					Else//If ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Normal Usado -> FT Usados Vlr Vendas (Qtd.Veic) - 9/10
						nCol := 9
					EndIf
					nValor := ( cQAlVV09 )->( VVA_VALMOV )
					aEmpresa[1,nCol] -= nValor
					aEmpresa[1,nCol+1]--
					aEmpresa[nLin,nCol] -= nValor
					aEmpresa[nLin,nCol+1]--
					If nLin > 3
						aEmpresa[3,nCol] -= nValor
						aEmpresa[3,nCol+1]--
					EndIf
				   	( cQAlVV09 )->( DbSkip() )
				Endif   	
			EndDo
			( cQAlVV09 )->( dbCloseArea() )
        Endif
	EndIf

Next
IncProc(STR0020) // Levantando...
cFilAnt := cFilSALVA
DEFINE MSDIALOG oFilxFil FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta Gerencial de Veiculos
	oFilxFil:lEscClose := .F.
	@ aPos[1,1]+2,aPos[1,2]+3 SAY cTitTela SIZE 350,08 OF oFilxFil PIXEL COLOR CLR_RED FONT oTitTela
	@ aPos[1,1],aPos[1,4]-45 BUTTON oGrpSair PROMPT STR0010 OF oFilxFil SIZE 45,10 PIXEL ACTION oFilxFil:End() // SAIR
	@ aPos[2,1],aPos[2,2] LISTBOX oLbEmp FIELDS HEADER (STR0032),; // Filial
														(STR0012+" ("+STR0047+")"),; // Novos Prop.Aprovadas (Qtd.Veic)
														(STR0013+" ("+STR0047+")"),; // Novos Vlr Vendas (Qtd.Veic)
														(STR0014+" ("+STR0047+")"),; // Usados Prop.Aprovadas (Qtd.Veic)
														(STR0015+" ("+STR0047+")"),; // Usados Vlr Vendas (Qtd.Veic)
														(STR0016+" ("+STR0047+")"),; // Vlr Total das Vendas (Qtd.Veic)
														(STR0017+" ("+STR0047+")") ; // Vlr Venda Direta (Qtd.Veic)
														COLSIZES 50,90,90,90,90,90,90 SIZE aPos[2,4]-2,aPos[2,3]-15 OF oFilxFil PIXEL
	oLbEmp:SetArray(aEmpresa)
	oLbEmp:bLine := { || { IIf(oLbEmp:nAt>3,Alltrim(aEmpresa[oLbEmp:nAt,1])+" ","")+aEmpresa[oLbEmp:nAt,2] ,;
     	                	IIf(aEmpresa[oLbEmp:nAt,04]<>0,FG_AlinVlrs(Transform(aEmpresa[oLbEmp:nAt,03],"@E 9999,999,999.99"))+" ("+Transform(aEmpresa[oLbEmp:nAt,04],"@E 999999")+") "+FG_AlinVlrs(Transform((aEmpresa[oLbEmp:nAt,03]/aEmpresa[1,03])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aEmpresa[oLbEmp:nAt,06]<>0,FG_AlinVlrs(Transform(aEmpresa[oLbEmp:nAt,05],"@E 9999,999,999.99"))+" ("+Transform(aEmpresa[oLbEmp:nAt,06],"@E 999999")+") "+FG_AlinVlrs(Transform((aEmpresa[oLbEmp:nAt,05]/aEmpresa[1,05])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aEmpresa[oLbEmp:nAt,08]<>0,FG_AlinVlrs(Transform(aEmpresa[oLbEmp:nAt,07],"@E 9999,999,999.99"))+" ("+Transform(aEmpresa[oLbEmp:nAt,08],"@E 999999")+") "+FG_AlinVlrs(Transform((aEmpresa[oLbEmp:nAt,07]/aEmpresa[1,07])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aEmpresa[oLbEmp:nAt,10]<>0,FG_AlinVlrs(Transform(aEmpresa[oLbEmp:nAt,09],"@E 9999,999,999.99"))+" ("+Transform(aEmpresa[oLbEmp:nAt,10],"@E 999999")+") "+FG_AlinVlrs(Transform((aEmpresa[oLbEmp:nAt,09]/aEmpresa[1,09])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aEmpresa[oLbEmp:nAt,11]<>0,FG_AlinVlrs(Transform(aEmpresa[oLbEmp:nAt,11],"@E 9999,999,999.99"))+" ("+Transform(aEmpresa[oLbEmp:nAt,12],"@E 999999")+") "+FG_AlinVlrs(Transform((aEmpresa[oLbEmp:nAt,11]/aEmpresa[1,11])*100,"@E 999")+"%"),"") ,;
     	                	IIf(aEmpresa[oLbEmp:nAt,14]<>0,FG_AlinVlrs(Transform(aEmpresa[oLbEmp:nAt,13],"@E 9999,999,999.99"))+" ("+Transform(aEmpresa[oLbEmp:nAt,14],"@E 999999")+") "+FG_AlinVlrs(Transform((aEmpresa[oLbEmp:nAt,13]/aEmpresa[1,13])*100,"@E 999")+"%"),"") }}
ACTIVATE MSDIALOG oFilxFil
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILIAIS³ Autor ³  Andre Luis Almeida   ³ Data ³ 14/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Filiais                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILIAIS()
Local aVetAux      := {}
Local ni           := {}
Local oFilHelp     := DMS_FilialHelper():New()
Local aSM0         := oFilHelp:GetAllFilPermis(.f.)
Local cBkpFilAnt   := cFilAnt
Local nCont        := 0
Local aFWArrFilAtu := {}
Local nOpcRadio    := nTipFil // Opcao Radio: Tipo de Filial ( Filial de Atendimento / Filial de Venda )
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aFWArrFilAtu := FWArrFilAtu()
	ni := aScan(aEmpr,{|x| x[1] == cFilAnt })
	aAdd( aVetEmp, { (ni>0) , cFilAnt , aFWArrFilAtu[SM0_FILIAL] , FWFilialName() })
Next
cFilAnt := cBkpFilAnt
If Len(aVetEmp) > 0
	If len(aVetEmp) == 1
		aVetEmp[1,1] := .t.
	EndIf
	DEFINE MSDIALOG oDlgEmp FROM 01,01 TO 280,400 TITLE STR0009 PIXEL // Filiais
	@ 001,003 RADIO oOpcRadio VAR nOpcRadio 3D SIZE 150,20 PROMPT STR0054,STR0055 OF oDlgEmp PIXEL WHEN ( VV9->(FieldPos("VV9_FILNEG")) > 0 ) // Filial da NF / Filial da Negociacao
	@ 021,001 LISTBOX oLbEmp FIELDS HEADER "",STR0032,STR0033 COLSIZES 10,25,50 SIZE 200,118 OF oDlgEmp ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL
	oLbEmp:SetArray(aVetEmp)
	oLbEmp:bLine := { || {  IIf(aVetEmp[oLbEmp:nAt,1],oOk,oNo) ,;
	aVetEmp[oLbEmp:nAt,3],;
	aVetEmp[oLbEmp:nAt,4] }}
	oLbEmp:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lMarcar := !lMarcar , FS_TIK(lMarcar) ) ,Nil) , }
	DEFINE SBUTTON FROM 004,170 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp
	ACTIVATE MSDIALOG oDlgEmp CENTER
	nTipFil := nOpcRadio // Tipo de Filial
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
Return(aVetAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK    ³ Autor ³  Andre Luis Almeida  ³ Data ³ 14/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marcar todas as Filiais                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(lMarcar)
Local ni := 0
Default lMarcar := .f.
For ni := 1 to Len(aVetEmp)
	aVetEmp[ni,1] := lMarcar
Next
oLbEmp:SetFocus()
oLbEmp:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_DEVOLU ³ Autor ³ Thiago ³ 			  Data ³ 28/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento das devolucoes.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DEVOLU( oObj , nX , nY , oMTpDVC170 )
oMTpDVC170:Activate( nX, nY, oObj )
Return()
