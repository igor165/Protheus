// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 13     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch" 
#include "VEIVC220.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVC220 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta de Pesquisa de Satisfacao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVC220(cPAREmp,aPAREmp,cPARFil1,cPARFil2,dPARFil3,dPARFil4,cPARFil5,cPARFil6)
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cBkpFilAnt:= cFilAnt
Local lDClik    := .f.
Local nCont     := 0
Private lMarcar := .f.
Private lImpr   := .t.
Private aPerg   := {}
Private aResp   := {}
Private aEsta   := {}
Private aRespTotal := {}
Private cTipPes := space(len(VCJ->VCJ_TIPPES))
Private cDesPes := ""
Private dDatIni := (dDataBase-day(dDataBase))+1
Private dDatFin := dDataBase
Private cCodPes := space(6)
Private cNivImp := space(2)
Private aFilAtu := FWArrFilAtu()
Private aSM0    := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Private aEmpFil := {}
Private aVetEmp := {}
Private aEmpr   := {} // Empresas Consolidadas
Private cEmpr   := "" // Nome da Empresa
//
Default cPAREmp  := ""
Default aPAREmp  := aEmpr 
Default cPARFil1 := cTipPes
Default cPARFil2 := cDesPes
Default dPARFil3 := dDatIni
Default dPARFil4 := dDatFin
Default cPARFil5 := cCodPes
Default cPARFil6 := cNivImp
//
cTipPes := cPARFil1
cDesPes := cPARFil2
dDatIni := dPARFil3
dDatFin := dPARFil4
cCodPes := cPARFil5
cNivImp := cPARFil6
//
If len(aSM0) > 0
	For nCont := 1 to Len(aSM0)
		cFilAnt := aSM0[nCont]
		aAdd( aEmpFil , { cFilAnt , FWFilialName() })
	Next
	cFilAnt := cBkpFilAnt
EndIf
aEmpr := aPAREmp
If !Empty(cPAREmp)
	cEmpr := " - "+STR0026+": " // Consolidado
	aEmpr := FS_FILIAIS() // Levantamento das Filiais
	If len(aEmpr) == 0
		MsgAlert(STR0028,STR0027) // Não existem dados para esta Consulta! / Atencao
		Return
	EndIf
Else
	aAdd(aEmpr,{ cFilAnt , aFilAtu[SM0_FILIAL] })
EndIf
If len(aEmpr) == 1 .and. (aEmpr[1,2]==aFilAtu[SM0_FILIAL])
	cEmpr := " - "+Alltrim(FWFilialName())+" ( "+aFilAtu[SM0_FILIAL]+" )"
EndIf
aInfo := { aSizeHalf[ 1 ] , aSizeHalf[ 2 ] , aSizeHalf[ 3 ] , aSizeHalf[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 30 , .T. , .F. } ) // Filtro no topo
aAdd( aObjects, { 0 , 40 , .T. , .T. } ) // Perguntas 
aAdd( aObjects, { 0 , 40 , .T. , .T. } ) // Respostas 
aPos := MsObjSize( aInfo, aObjects )
Processa( {|| FS_FILTRA(0) } )
DEFINE MSDIALOG oPesquisas FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL // Pesquisa de Satisfacao
	oPesquisas:lEscClose := .F.
	@ aPos[1,1],aPos[1,2] TO aPos[2,1]-003,aPos[1,4] LABEL STR0002 OF oPesquisas PIXEL // Filtro
	@ aPos[1,1]+008,aPos[1,2]+005 SAY STR0003 SIZE 50,10 OF oPesquisas PIXEL COLOR CLR_BLUE // Tipo
	@ aPos[1,1]+016,aPos[1,2]+005 MSGET oTipPes VAR cTipPes VALID FS_VALSX5() F3 "PS" PICTURE "@!" SIZE 20,08 OF oPesquisas PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+016,aPos[1,2]+035 MSGET oDesPes VAR cDesPes PICTURE "@!" SIZE 115,08 OF oPesquisas PIXEL COLOR CLR_BLUE WHEN .f.
	@ aPos[1,1]+008,aPos[1,2]+154 SAY STR0004 SIZE 50,10 OF oPesquisas PIXEL COLOR CLR_BLUE // Periodo
	@ aPos[1,1]+016,aPos[1,2]+154 MSGET oDatIni VAR dDatIni VALID FS_NAOIMP() PICTURE "@D" SIZE 40,08 OF oPesquisas PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+018,aPos[1,2]+198 SAY STR0005 SIZE 50,10 OF oPesquisas PIXEL COLOR CLR_BLUE // a
	@ aPos[1,1]+016,aPos[1,2]+204 MSGET oDatFin VAR dDatFin VALID FS_NAOIMP() PICTURE "@D" SIZE 40,08 OF oPesquisas PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+008,aPos[1,2]+250 SAY STR0009 SIZE 50,10 OF oPesquisas PIXEL COLOR CLR_BLUE // Codigo
	@ aPos[1,1]+016,aPos[1,2]+250 MSGET oCodPes VAR cCodPes PICTURE "@!" SIZE 40,08 OF oPesquisas PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+008,aPos[1,2]+297 SAY STR0032 SIZE 70,10 OF oPesquisas PIXEL COLOR CLR_BLUE // Niv.Imp.Cliente
	@ aPos[1,1]+016,aPos[1,2]+297 MSGET oNivImp VAR cNivImp PICTURE "@!" SIZE 20,08 OF oPesquisas PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+006,aPos[1,4]-060 BUTTON oFiltrar  PROMPT STR0006 OF oPesquisas SIZE 27,10 PIXEL ACTION Processa( {|| lImpr := .t. , FS_FILTRA(1) } ) // Filtrar
	@ aPos[1,1]+006,aPos[1,4]-030 BUTTON oEmpr     PROMPT STR0029 OF oPesquisas SIZE 27,10 PIXEL ACTION (lDClik:=.t.,oPesquisas:End()) // Filiais
	@ aPos[1,1]+018,aPos[1,4]-060 BUTTON oImprimir PROMPT STR0007 OF oPesquisas SIZE 27,10 PIXEL ACTION Processa( {|| FS_IMPRIMIR() } ) WHEN lImpr // Imprimir
	@ aPos[1,1]+018,aPos[1,4]-030 BUTTON oSair     PROMPT STR0008 OF oPesquisas SIZE 27,10 PIXEL ACTION oPesquisas:End() // Sair
	@ aPos[2,1],aPos[2,2] LISTBOX oLbPerg FIELDS HEADER STR0010,STR0003,STR0011 COLSIZES aPos[2,4]-265,150,50 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1] OF oPesquisas ON CHANGE FS_RESPOSTAS(1,aPerg[oLbPerg:nAt,1],aPerg[oLbPerg:nAt,5]) ON DBLCLICK Processa( {|| FS_ANALIT(oLbPerg:nAt,0) } ) PIXEL // Perguntas / Tipo / Respostas
	oLbPerg:SetArray(aPerg)
	oLbPerg:bLine := { || { IIf(!Empty(aPerg[oLbPerg:nAt,5])," - ","")+aPerg[oLbPerg:nAt,02] , aPerg[oLbPerg:nAt,04] , IIf(!Empty(aPerg[oLbPerg:nAt,5]),FG_AlinVlrs(Transform(aPerg[oLbPerg:nAt,03],"@E 9,999,999")),"") }}
	@ aPos[3,1],aPos[3,2] LISTBOX oLbResp FIELDS HEADER STR0011,STR0012,"%" COLSIZES (aPos[3,4]/2)-120,50,30 SIZE (aPos[3,4]/2),aPos[3,3]-aPos[3,1] OF oPesquisas ON DBLCLICK Processa( {|| FS_ANALIT(oLbPerg:nAt,oLbResp:nAt) } ) PIXEL // Respostas / Qtde 
	oLbResp:SetArray(aResp)
	oLbResp:bLine := { || { aResp[oLbResp:nAt,02] , IIf(aResp[oLbResp:nAt,03]>0,FG_AlinVlrs(Transform(aResp[oLbResp:nAt,03],"@E 9,999,999")),"") , IIf(aResp[oLbResp:nAt,03]>0,FG_AlinVlrs(Transform((aResp[oLbResp:nAt,03]/aPerg[oLbPerg:nAt,03])*100,"@E 9999.99")+" %"),"") }}
	@ aPos[3,1],(aPos[3,4]/2)+5 LISTBOX oLbEsta FIELDS HEADER STR0013,STR0012,"%" COLSIZES (aPos[3,4]/2)-120,50,30 SIZE (aPos[3,4]/2)-4,aPos[3,3]-aPos[3,1] OF oPesquisas PIXEL // Estatistica da Pesquisa de Satisfacao / Qtde
	oLbEsta:SetArray(aEsta)
	oLbEsta:bLine := { || { aEsta[oLbEsta:nAt,02] , IIf(aEsta[oLbEsta:nAt,03]>0,FG_AlinVlrs(Transform(aEsta[oLbEsta:nAt,03],"@E 9,999,999")),"") , IIf(aEsta[oLbEsta:nAt,03]>0,FG_AlinVlrs(Transform((aEsta[oLbEsta:nAt,03]/aEsta[1,03])*100,"@E 9999.99")+" %"),"") }}
	oLbPerg:SetFocus()
ACTIVATE MSDIALOG oPesquisas
If lDClik
	VEIVC220(cEmpr,aEmpr,cTipPes,cDesPes,dDatIni,dDatFin,cCodPes,cNivImp)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALSX5³ Autor ³  Andre Luis Almeida   ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida TIPO DE PESQUISA - SX5                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALSX5()
Local lRet := .t.
cDesPes := ""
If !Empty(cTipPes)
	lRet := .f.
	SX5->(DbSetOrder(1))
	If SX5->(DbSeek(xFilial("SX5")+"PS"+cTipPes))
		lRet := .t.
		cDesPes := SX5->X5_DESCRI
	EndIf
EndIf
FS_NAOIMP()
oDesPes:Refresh()
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_NAOIMP³ Autor ³  Andre Luis Almeida   ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Nao deixar Imprimir Relacao das Perguntas e Respostas      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_NAOIMP()
	lImpr := .f.
	oImprimir:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILTRA³ Autor ³  Andre Luis Almeida   ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra Perguntas ( VCJ ) e Respostas ( VCK )               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRA(nTp)
Local cQuery     := ""
Local cQAlSQL    := "ALIASSQL"
Local cResp      := ""
Local cPerg      := ""
Local nPos       := 0
Local ni         := 0
Local nCont      := 0
Local nPosTot    := 0
Local cMesmaOri  := "INICIAL"
Local cBkpFilAnt := cFilAnt
aPerg := {}
aRespTotal := {}
aEsta := {}
If !Empty(cTipPes)
	For nCont := 1 to Len(aEmpr)
		cFilAnt := aEmpr[nCont,1]
		//
		aAdd( aPerg , { "999999" , UPPER(STR0030)+": "+cFilAnt , 0 , "" , "" } ) // FILIAL
		nPosTot := len(aPerg)
		cMesmaOri := "INICIAL"
		//
		cQuery := "SELECT VCK.* , VCJ.* FROM "+RetSqlName("VC1")+" VC1 "
		cQuery += "JOIN " +RetSqlName("VCK")+ " VCK ON (VCK.VCK_FILIAL='"+xFilial("VCK")+"' AND VCK.VCK_ORIGEM = VC1.VC1_ORIGEM AND VCK.D_E_L_E_T_=' ') "
		cQuery += "JOIN " +RetSqlName("VCJ")+ " VCJ ON (VCJ.VCJ_FILIAL='"+xFilial("VCJ")+"' AND VCK.VCK_CODPER=VCJ.VCJ_CODPER AND " + IIF(!Empty(cCodPes),"VCJ.VCJ_CODPES ='"+cCodPes+"' AND ","")
		cQuery += "VCJ.VCJ_TIPPES='"+cTipPes+"' AND VCJ.D_E_L_E_T_=' ') "
		cQuery += "WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND VC1.VC1_DATAGE >= '"+dtos(dDatIni)+"' AND VC1.VC1_DATAGE <= '"+dtos(dDatFin)+"' AND "
		Do Case
			Case cTipPes == "001" // Veiculos
				cQuery += "VC1.VC1_TIPORI='V' AND "
			Case cTipPes == "002" // Oficina
				cQuery += "VC1.VC1_TIPORI='O' AND "
			Case cTipPes == "003" // Balcao
				cQuery += "VC1.VC1_TIPORI='B' AND "
			Case cTipPes == "004" // CEV
				cQuery += "VC1.VC1_TIPORI='C' AND "
		EndCase
		cQuery += "VC1.D_E_L_E_T_=' ' ORDER BY VCJ.VCJ_TIPPES , VCJ.VCJ_CODPER , VCK.VCK_ORIGEM "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			If cMesmaOri == ( cQAlSQL )->( VCJ_TIPPES ) + ( cQAlSQL )->( VCJ_CODPER ) + ( cQAlSQL )->( VCK_ORIGEM )
				( cQAlSQL )->( DbSkip() )
				Loop
			EndIf
			cMesmaOri := ( cQAlSQL )->( VCJ_TIPPES ) + ( cQAlSQL )->( VCJ_CODPER ) + ( cQAlSQL )->( VCK_ORIGEM )
			If !Empty(cNivImp)
				// Necessario posicionar no SA1 para validar o Nivel de Importancia
				FS_POSSA1( ( cQAlSQL )->( VCJ_TIPPES ) , ( cQAlSQL )->( VCK_ORIGEM ) ) // Posiciona no SA1 da Origem
				If !FS_VLDNIVIMP( SA1->A1_COD , SA1->A1_LOJA ) // Valida Nivel de Importancia do Cliente
					( cQAlSQL )->( DbSkip() )
					Loop
				EndIf
			EndIf
			cPerg := ( cQAlSQL )->( VCJ_CODPER )
			nPos := aScan(aPerg, {|x| x[1] == cPerg })
			If nPos <= 0
				SX5->(DbSetOrder(1))
				SX5->(DbSeek(xFilial("SX5")+"PS"+( cQAlSQL )->( VCJ_TIPPES )))
				aAdd(aPerg,{ cPerg , ( cQAlSQL )->( VCJ_PERGUN ) , 0 , ( cQAlSQL )->( VCJ_TIPPES )+"-"+SX5->X5_DESCRI , cFilAnt })
				nPos := len(aPerg)
			EndIf
			aPerg[nPos,3]++
			aPerg[nPosTot,3]++
			If !Empty(( cQAlSQL )->( VCK_RESPOS ))
				cPerg += ( cQAlSQL )->( VCK_RESPOS )
		    Else
				cPerg += UPPER(( cQAlSQL )->( VCK_OBSERV ))
		    EndIf
			nPos := aScan(aRespTotal, {|x| x[1] == cPerg })
			If nPos <= 0
				If !Empty(( cQAlSQL )->( VCK_RESPOS ))
					cResp := ( cQAlSQL )->( VCJ_OPCOES )
					ni := at((( cQAlSQL )->( VCK_RESPOS )+"="),cResp)
					If ni > 0
						cResp := substr(cResp,ni+2)
						ni := len(cResp)+1
						If at(";",cResp) > 0
							ni := at(";",cResp)-1
							If ni < 1
								ni := 1
							EndIf
						EndIf
						cResp := Alltrim(substr(cResp,1,ni))
					Else
						cResp := ""
					EndIf
					aAdd(aRespTotal,{ cPerg , ( cQAlSQL )->( VCK_RESPOS )+" - "+cResp , 0 , 1 , cFilAnt })
				Else
					aAdd(aRespTotal,{ cPerg , UPPER(( cQAlSQL )->( VCK_OBSERV )) , 0 , 2 , cFilAnt })
				EndIf
				nPos := len(aRespTotal)
			EndIf
			aRespTotal[nPos,3]++
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		FS_ESTAT(nTp)
	Next
	cFilAnt := cBkpFilAnt
EndIf
If Len(aPerg) <= 0 
	aAdd( aPerg , { "999999" , "" , 0 , "" , "" } )
EndIf
Asort(aRespTotal,,,{|x,y| x[3] > y[3] })
If nTp > 0
	oLbPerg:nAt := 1
	oLbPerg:SetArray(aPerg)
	oLbPerg:bLine := { || { IIf(!Empty(aPerg[oLbPerg:nAt,5])," - ","")+aPerg[oLbPerg:nAt,02] , aPerg[oLbPerg:nAt,04] , IIf(!Empty(aPerg[oLbPerg:nAt,5]),FG_AlinVlrs(Transform(aPerg[oLbPerg:nAt,03],"@E 9,999,999")),"") }}
	oLbPerg:Refresh()
	FS_RESPOSTAS(nTp,aPerg[oLbPerg:nAt,01])
EndIf
If len(aEsta) <= 0
	aAdd( aEsta , { "" , "" , 0 } ) // Estatisticas
EndIf
Asort(aEsta,,,{|x,y| STRZERO(100000-x[4],6)+STRZERO(x[3],6) > STRZERO(100000-y[4],6)+STRZERO(y[3],6)  })
If nTp > 0
	oLbEsta:SetArray(aEsta)
	oLbEsta:bLine := { || { aEsta[oLbEsta:nAt,02] , IIf(aEsta[oLbEsta:nAt,03]>0,FG_AlinVlrs(Transform(aEsta[oLbEsta:nAt,03],"@E 9,999,999")),"") , IIf(aEsta[oLbEsta:nAt,03]>0,FG_AlinVlrs(Transform((aEsta[oLbEsta:nAt,03]/aEsta[1,03])*100,"@E 9999.99")+" %"),"") }}
	oLbEsta:Refresh()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_RESPOSTAS³ Autor ³  Andre Luis Almeida ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza Respostas correspondentes a Pergunta selecionada ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RESPOSTAS(nTp,cPerg,cFilLinha)
Local ni := 0
aResp := {}
For ni := 1 to len(aRespTotal)
	If left(aRespTotal[ni,1],len(cPerg)) == cPerg .and. aRespTotal[ni,5] == cFilLinha
		aAdd( aResp , aClone(aRespTotal[ni]) ) // Respostas
	EndIf
Next
If len(aResp) <= 0
	aAdd( aResp , { "" , "" , 0 , 0 , "" } ) // Respostas
EndIf
If nTp > 0
	oLbResp:nAt := 1
	oLbResp:SetArray(aResp)
	oLbResp:bLine := { || { aResp[oLbResp:nAt,02] , IIf(aResp[oLbResp:nAt,03]>0,FG_AlinVlrs(Transform(aResp[oLbResp:nAt,03],"@E 9,999,999")),"") , IIf(aResp[oLbResp:nAt,03]>0,FG_AlinVlrs(Transform((aResp[oLbResp:nAt,03]/aPerg[oLbPerg:nAt,03])*100,"@E 9999.99")+" %"),"") }}
	oLbResp:refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ANALIT³ Autor ³  Andre Luis Almeida   ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lista Analiticamente as Origens das Respostas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ANALIT(nLinPerg,nLinResp)
Local cOrig     := ""
Local lOk       := .t.
Local cQuery    := ""
Local cQAlSQL   := "ALIASSQL"
Local ni        := 0
Local cPerg     := ""
Local cResp     := ""
Local cRespost  := ""
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cMesmaOri := "INICIAL"
Local cBkpFilAnt:= cFilAnt
Local cTitFilt  := ""
Private cObserv := ""
Private aAnalit := {}
If Empty(aPerg[nLinPerg,5]) // Total Geral
	Return()
EndIf
aInfo := { aSizeHalf[ 1 ] , aSizeHalf[ 2 ] , aSizeHalf[ 3 ] , aSizeHalf[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 40 , .T. , .F. } ) // Filtro no topo
aAdd( aObjects, { 0 , 40 , .T. , .T. } ) // Analitico 
aAdd( aObjects, { 0 , 40 , .T. , .F. } ) // Observacao Resposta
aPos := MsObjSize( aInfo, aObjects )
//
cPerg   := aPerg[nLinPerg,2]
cFilAnt := aPerg[nLinPerg,5]
cTitFilt:= ( STR0002+" - "+UPPER(STR0030)+": "+cFilAnt )
//
cQuery := "SELECT VCK.* , VCJ.* FROM "+RetSqlName("VC1")+" VC1 "
cQuery += "JOIN " +RetSqlName("VCK")+ " VCK ON (VCK.VCK_FILIAL='"+xFilial("VCK")+"' AND VCK.VCK_ORIGEM = VC1.VC1_ORIGEM AND "
If nLinResp > 0
	cResp := aResp[nLinResp,2]
	If aResp[nLinResp,4] == 1 // Selecao (Combo)
		cQuery += "VCK.VCK_RESPOS='"+left(aResp[nLinResp,2],1)+"' AND "
	Else // Texto
		cQuery += "VCK.VCK_RESPOS=' ' AND "
	EndIf
EndIf
cQuery += "VCK.D_E_L_E_T_=' ') "
cQuery += "JOIN " +RetSqlName("VCJ")+ " VCJ ON (VCJ.VCJ_FILIAL='"+xFilial("VCJ")+"' AND VCK.VCK_CODPER=VCJ.VCJ_CODPER AND VCJ.VCJ_CODPER='"+aPerg[nLinPerg,1]+"' AND "
cQuery += "VCJ.D_E_L_E_T_=' ') "
cQuery += "WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND VC1.VC1_DATAGE >= '"+dtos(dDatIni)+"' AND VC1.VC1_DATAGE <= '"+dtos(dDatFin)+"' AND "
Do Case
	Case cTipPes == "001" // Veiculos
		cQuery += "VC1.VC1_TIPORI='V' AND "
	Case cTipPes == "002" // Oficina
		cQuery += "VC1.VC1_TIPORI='O' AND "
	Case cTipPes == "003" // Balcao
		cQuery += "VC1.VC1_TIPORI='B' AND "
	Case cTipPes == "004" // CEV
		cQuery += "VC1.VC1_TIPORI='C' AND "
EndCase
cQuery += "VC1.D_E_L_E_T_=' ' ORDER BY VCJ.VCJ_TIPPES , VCJ.VCJ_CODPER , VCK.VCK_ORIGEM "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	lOk := .t.
	If nLinResp > 0
		lOk := .f.
		If !Empty(( cQAlSQL )->( VCK_RESPOS )) .or. Alltrim(UPPER(( cQAlSQL )->( VCK_OBSERV )))==Alltrim(aResp[nLinResp,2])
			lOk := .t.
		EndIf	
	EndIf
	If lOk
		If cMesmaOri == ( cQAlSQL )->( VCJ_TIPPES ) + ( cQAlSQL )->( VCJ_CODPER ) + ( cQAlSQL )->( VCK_ORIGEM )
			( cQAlSQL )->( DbSkip() )
			Loop
		EndIf
		cMesmaOri := ( cQAlSQL )->( VCJ_TIPPES ) + ( cQAlSQL )->( VCJ_CODPER ) + ( cQAlSQL )->( VCK_ORIGEM )
		cOrig := ""
		Do Case
			Case ( cQAlSQL )->( VCJ_TIPPES ) == "001"
				cOrig := "V" // Veiculos
			Case ( cQAlSQL )->( VCJ_TIPPES ) == "002"
				cOrig := "O" // Oficina
			Case ( cQAlSQL )->( VCJ_TIPPES ) == "003"
				cOrig := "B" // Balcao
			Case ( cQAlSQL )->( VCJ_TIPPES ) == "004"
				cOrig := "C" // CEV
		EndCase
		// Necessario posicionar no SA1 para validar o Nivel de Importancia e tambem adicionar no vetor aAnalit (em baixo)
		FS_POSSA1( ( cQAlSQL )->( VCJ_TIPPES ) , ( cQAlSQL )->( VCK_ORIGEM ) ) // Posiciona no SA1 da Origem
		If !Empty(cNivImp)
			If !FS_VLDNIVIMP( SA1->A1_COD , SA1->A1_LOJA ) // Valida Nivel de Importancia do Cliente
				( cQAlSQL )->( DbSkip() )
				Loop
			EndIf
		EndIf
		cRespost := ""
		If !Empty(( cQAlSQL )->( VCK_RESPOS ))
			cRespost := ( cQAlSQL )->( VCJ_OPCOES )
			ni := at((( cQAlSQL )->( VCK_RESPOS )+"="),cRespost)
			If ni > 0
				cRespost := substr(cRespost,ni+2)
				ni := len(cRespost)+1
				If at(";",cRespost) > 0
					ni := at(";",cRespost)-1
					If ni < 1
						ni := 1
					EndIf
				EndIf
				cRespost := Alltrim(substr(cRespost,1,ni))
			Else
				cRespost := ""
			EndIf
			cRespost := ( cQAlSQL )->( VCK_RESPOS )+" - "+cRespost
		Else
			cRespost := UPPER(( cQAlSQL )->( VCK_OBSERV ))
		EndIf
		aAdd(aAnalit,{ stod(( cQAlSQL )->( VCK_DATPES )) , ( cQAlSQL )->( VCK_ORIGEM ) , SA1->A1_COD+"-"+SA1->A1_LOJA+" "+SA1->A1_NOME , cOrig , cRespost , UPPER(( cQAlSQL )->( VCK_OBSERV )) , cFilAnt })
	EndIf
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
cFilAnt := cBkpFilAnt
If len(aAnalit) <= 0
	aAdd(aAnalit,{ctod(""),"","","","","",""})
EndIf
DEFINE MSDIALOG oAnalPesq FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0001 OF oMainWnd PIXEL // Pesquisa de Satisfacao
	oAnalPesq:lEscClose := .F.
	@ aPos[1,1],aPos[1,2] TO aPos[2,1]-003,aPos[1,4] LABEL cTitFilt OF oAnalPesq PIXEL // Filtro
	@ aPos[1,1]+007,aPos[1,2]+005 MSGET oFiltro VAR aPerg[nLinPerg,4] PICTURE "@!" SIZE 200,08 OF oAnalPesq PIXEL COLOR CLR_BLUE WHEN .f.
	@ aPos[1,1]+008,aPos[1,2]+217 SAY STR0004 SIZE 50,10 OF oAnalPesq PIXEL COLOR CLR_BLUE // Periodo
	@ aPos[1,1]+007,aPos[1,2]+240 MSGET oDatIni VAR dDatIni PICTURE "@D" SIZE 40,08 OF oAnalPesq PIXEL COLOR CLR_BLUE WHEN .f.
	@ aPos[1,1]+008,aPos[1,2]+284 SAY STR0005 SIZE 50,10 OF oAnalPesq PIXEL COLOR CLR_BLUE // a
	@ aPos[1,1]+007,aPos[1,2]+290 MSGET oDatFin VAR dDatFin PICTURE "@D" SIZE 40,08 OF oAnalPesq PIXEL COLOR CLR_BLUE WHEN .f.
	@ aPos[1,1]+017,aPos[1,2]+005 MSGET oPerg VAR cPerg PICTURE "@!" SIZE 325,08 OF oAnalPesq PIXEL COLOR CLR_BLUE WHEN .f.
	@ aPos[1,1]+027,aPos[1,2]+005 MSGET oResp VAR cResp PICTURE "@!" SIZE 325,08 OF oAnalPesq PIXEL COLOR CLR_BLUE WHEN .f.
	@ aPos[1,1]+007,aPos[1,4]-045 BUTTON oSair PROMPT STR0008 OF oAnalPesq SIZE 40,10 PIXEL ACTION oAnalPesq:End() // Sair
	@ aPos[2,1],aPos[2,2] LISTBOX oLbAnal FIELDS HEADER STR0015,STR0016,STR0017,STR0018 COLSIZES 40,40,120,200 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1] OF oAnalPesq  ON CHANGE FS_OBSRESP(aAnalit[oLbAnal:nAt,06]) ON DBLCLICK FS_VERORIG(oLbAnal:nAt) PIXEL // Data Pesquisa / Origem / Cliente / Resposta
	oLbAnal:SetArray(aAnalit)
	oLbAnal:bLine := { || { Transform(aAnalit[oLbAnal:nAt,01],"@D") , aAnalit[oLbAnal:nAt,02] , aAnalit[oLbAnal:nAt,03] , aAnalit[oLbAnal:nAt,05] }}
	@ aPos[3,1],aPos[3,2] GET oObserv VAR cObserv OF oAnalPesq MEMO SIZE aPos[3,4]-2,aPos[3,3]-aPos[3,1] PIXEL READONLY MEMO
ACTIVATE MSDIALOG oAnalPesq
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_OBSRESP³ Autor ³  Andre Luis Almeida   ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra Observacao da Resposta                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OBSRESP(cObsResp)
cObserv := cObsResp
oObserv:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERORIG³ Autor ³  Andre Luis Almeida   ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza Origem ( Veiculo / Balcao / Oficina / CEV )      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERORIG(nLinha)  // Ver origem do CEV (Atendimento/OS/Orcamento)    
Local cBkpFilAnt:= cFilAnt
Private Inclui  := .f. // Variavel INTERNA utilizada no VEIVM011
Private Altera  := .f. // Variavel INTERNA utilizada no VEIVM011
Private lEmiNfi := .t. // Variavel INTERNA utilizada no VEIVM011
Private lNegPag := .t. // Variavel INTERNA utilizada no VEIVM011
Private lLibVei := .f. // Variavel INTERNA utilizada no VEIVM011
Private lAutFat := .f. // Variavel INTERNA utilizada no VEIVM011
Private _lVerBotoes := .f. // Variavel INTERNA utilizada no VEIVM011
Private cCampo  := ""
Private nOpc    := 2
Private bFiltraBrw := {|| Nil}
Private aCampos := {}
Private cCadastro := ""
Private aNewBot := {}
Private aRotina := {{"","PesqV011", 0, 1} ,;
		  			{"","ATEND011", 0, 2} ,;
					{"","ATEND011", 0, 3} ,;
					{"","ATEND011", 0, 4} ,;
					{"","ATEND011", 0, 5}}
If !Empty(aAnalit[nLinha,2]+aAnalit[nLinha,4])
	cFilAnt := aAnalit[nLinha,7]
	Do Case
		Case aAnalit[nLinha,4] == "O" // Oficina 
			aRotina := { { "" ,"axPesqui", 0 , 1},;   && Pesquisar
		               { "" ,"OC060"   , 0 , 2}}    && Visualizar
			cCadastro := STR0019 // Ordem de Servico
			DbSelectArea("VO1")                         
			DbSetOrder(1)
			If DbSeek(xFilial("VO1") + left(aAnalit[nLinha,2],8) )
				OC060("VO1",Recno(),2)
			EndIf
		Case aAnalit[nLinha,4] == "B" // Balcao
			cCadastro := STR0020 // Orcamento
			DbSelectArea("VS1")                         
			DbSetOrder(1)
			If DbSeek(xFilial("VS1") + left(aAnalit[nLinha,2],8) )
				OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
			EndIf
		Case aAnalit[nLinha,4] == "V" // Veiculos
			DbSelectArea("VV9")
			DbSetOrder(1)
			If DbSeek( xFilial("VV9") + left(aAnalit[nLinha,2],10) )
				If !FM_PILHA("VEIXX002") .and. !FM_PILHA("VEIXX030")
					VEIXX002(NIL,NIL,NIL,2,)
				EndIf
			EndIf
		Case aAnalit[nLinha,4] == "C" // CEV
			DbSelectArea("VC1")
			DbSetOrder(1)
			DbGoTo( val(aAnalit[nLinha,2]) )
			AxVisual("VC1",VC1->( RECNO() ),2,)
	EndCase
	cFilAnt := cBkpFilAnt
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMPRIMIR³ Autor ³  Andre Luis Almeida  ³ Data ³ 07/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao das Perguntas, Respostas e Estatistica           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR()
Local ni       := 0
Local nj       := 0
Local nPerg    := 0
Local cQuebra1 := ""
Private cDesc1 := ""
Private cDesc2 := ""
Private cDesc3 := ""
Private tamanho:= "M"
Private limite := 132
Private cString:= "VCK"
Private titulo := STR0001 // Pesquisa de Satisfacao
Private cabec1 := left(STR0003+": "+cTipPes+"-"+cDesPes+space(66),66)+right(space(66)+STR0004+": "+Transform(dDatIni,"@D")+" "+STR0005+" "+Transform(dDatFin,"@D"),66) // Tipo / Periodo / a
Private cabec2 := left(STR0010+space(132),132-25)+right(space(25)+STR0021,25) // Perguntas / Respostas Percentual
Private aReturn:= {"",1,"",1,2,1,"",1}  
Private nomeprog:= "VEIVC220"
Private nLastKey:= 0
nomeprog := SetPrint(cString,nomeprog,nil,titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
	Return
EndIf     
SetDefault(aReturn,cString)
nLin  := 60
m_pag := 1
Set Printer to &nomeprog
Set Printer On
Set Device  to Printer
For ni := 1 to len(aPerg)
	If nLin >= 55
		nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
	EndIf
	If cQuebra1 <> aPerg[ni,4]
		cQuebra1 := aPerg[ni,4]
		nLin++
		@ nLin++, 00 PSAY aPerg[ni,4]
		nPerg := 0
	EndIf
	If Empty(aPerg[ni,5])
		nLin++
		@ nLin++, 00 PSAY left(aPerg[ni,2]+space(132),132)
		nPerg := 0
	Else
		nLin++
		nPerg++
		@ nLin++, 00 PSAY left(space(2)+strzero(nPerg,len(alltrim(str(len(aPerg)))))+") "+aPerg[ni,2]+space(132),132-20)+Transform(aPerg[ni,3],"@E 9,999,999")+"    100,00%"
		For nj := 1 to len(aRespTotal)
			If left(aRespTotal[nj,1],len(aPerg[ni,1])) == aPerg[ni,1]
				@ nLin++, 00 PSAY left(space(5)+aRespTotal[nj,2]+space(132),132-20)+Transform(aRespTotal[nj,3],"@E 9,999,999")+Transform((aRespTotal[nj,3]/aPerg[ni,3])*100,"@E 9999999.99")+"%"
			EndIf
		Next
	EndIf
Next
nLin   := 60
cabec2 := left(STR0013+space(132),132-25)+right(space(25)+STR0022,25) // Estatistica da Pesquisa de Satisfacao / Qtde Percentual
For ni := 1 to len(aEsta)
	If nLin >= 55
		nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
	EndIf
	@ nLin++, 00 PSAY left(aEsta[ni,02]+space(132),132-20)+Transform(aEsta[ni,03],"@E 9,999,999")+Transform((aEsta[ni,3]/aEsta[1,3])*100,"@E 9999999.99")+"%"
Next
Set Printer to
Set Device to Screen
If aReturn[5] == 1
	OurSpool( nomeprog )
EndIf
MS_Flush()
Return()  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ESTAT ³ Autor ³  Andre Luis Almeida   ³ Data ³ 16/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Estatistica da Pesquisa de Satisfacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ESTAT(nTp)
Local nPos    := 0
Local cDescr  := ""
Local cQuery  := ""
Local cQAlSQL := "SQLVC1"
Local nExistP := 0
Local cTpPesq := ""
Local cTipAge := ""
Local cOrigem := ""
Local cTipOri := ""
Local cMOTPNR := "X"
Local cDesMot := ""
Local cMesmaOri := "INICIAL"
cQuery := "SELECT VC1.VC1_TIPAGE , VC1.VC1_ORIGEM , VC1.VC1_TIPORI , VC1.VC1_CODCLI , VC1.VC1_LOJA , VC1.VC1_MOTPNR "
cQuery += "FROM "+RetSqlName("VC1")+" VC1 "
cQuery += "WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND VC1.VC1_DATAGE>='"+dtos(dDatIni)+"' AND VC1.VC1_DATAGE<='"+dtos(dDatFin)+"' AND VC1.D_E_L_E_T_=' ' ORDER BY VC1.VC1_ORIGEM "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	nExistP := 0
	cTpPesq := ""
	cTipAge := ( cQAlSQL )->( VC1_TIPAGE )
	cOrigem := ( cQAlSQL )->( VC1_ORIGEM )
	cTipOri := ( cQAlSQL )->( VC1_TIPORI )
	If !Empty(( cQAlSQL )->( VC1_MOTPNR ))
		cMOTPNR := ( cQAlSQL )->( VC1_MOTPNR )
	Else
		cMOTPNR := "X"
	EndIf
	If cTipOri == "V" // Veiculos
		cTpPesq := "001"
	ElseIf cTipOri == "O" // Oficina
		cTpPesq := "002"
	ElseIf cTipOri == "B" // Balcao
		cTpPesq := "003"
	Else // cTipOri == "C" // CEV
		cTpPesq := "004"
	EndIf
	If !Empty(cNivImp)
		// Necessario posicionar no SA1 para validar o Nivel de Importancia
		FS_POSSA1( cTpPesq , cOrigem ) // Posiciona no SA1 da Origem
		If !FS_VLDNIVIMP( SA1->A1_COD , SA1->A1_LOJA ) // Valida Nivel de Importancia do Cliente
			( cQAlSQL )->( DbSkip() )
			Loop
		EndIf
	EndIf
	If cTipPes == cTpPesq // Tipo de Pesquisa selecionado igual ao tipo de Pesquisa do VC1
		nExistP := VCA100EXIS(cTpPesq,cTipAge,cOrigem,( cQAlSQL )->( VC1_CODCLI ),( cQAlSQL )->( VC1_LOJA )) // Existencia da Pesquisa de Satisfacao
		If nExistP <> 0 // Existe Pesquisa de Satisfacao
			If cOrigem == cMesmaOri // Mesma Origem - Pula registro
				( cQAlSQL )->( DbSkip() )
				Loop
			EndIf
			cMesmaOri := cOrigem
			nPos := aScan(aEsta, {|x| x[1] == "00" })
			If nPos <= 0
				aAdd( aEsta , { "00" , STR0014 , 0 , 0} ) // TOTAL GERAL
				nPos := len(aEsta)
			EndIf
			aEsta[nPos,3]++
			nPos := aScan(aEsta, {|x| x[1] == strzero(nExistP,1)+"0" })
			If nPos <= 0
				aAdd( aEsta , { strzero(nExistP,1)+"0" , IIf(nExistP==2,STR0023,STR0024) , 0 , IIf(nExistP==2,1,2)  } ) // Realizadas / Nao Realizadas
				nPos := len(aEsta)
			EndIf
			aEsta[nPos,3]++
			If nExistP == 1 // Nao Realizadas
				cDesMot := space(5)+" - "+STR0025 // Sem Motivo
				If cMOTPNR <> "X"
					VS0->(DbSetOrder(1))
					VS0->(MsSeek(xFilial("VS0")+"000007"+cMOTPNR))
					cDesMot := space(5)+" - "+cMOTPNR+" - "+left(VS0->VS0_DESMOT,30)
				EndIf		
				nPos := aScan(aEsta, {|x| x[1] == strzero(nExistP,1)+cMOTPNR })
				If nPos <= 0
					aAdd( aEsta , { strzero(nExistP,1)+cMOTPNR , cDesMot , 0 , 3} ) // Motivo 
					nPos := len(aEsta)
				EndIf
				aEsta[nPos,3]++
			EndIf
		EndIf
	EndIf
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILIAIS³ Autor ³  Andre Luis Almeida   ³ Data ³ 10/10/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Filiais                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 250,400 TITLE STR0029 PIXEL // Filiais
	@ 001,001 LISTBOX oLbEmp FIELDS HEADER (""),STR0030,STR0031 COLSIZES 10,15,50 SIZE 165,120 OF oDlgEmp ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL // Filial / Nome
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
Return(aVetAux)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK     ³ Autor ³  Andre Luis Almeida ³ Data ³ 10/10/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ TIK no ListBox da Empresa/Filiais                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_TIK(lMarcar)
Local ni := 0
Default lMarcar := .f.
For ni := 1 to Len(aVetEmp)
	aVetEmp[ni,1] := lMarcar
Next
oLbEmp:SetFocus()
oLbEmp:Refresh()
Return(.t.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_POSSA1  ³ Autor ³  Andre Luis Almeida ³ Data ³ 21/02/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Posicionamento no Cliente SA1 da Origem                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_POSSA1( _cTipPesq , _cOrigem )
// Posicionar no Cliente SA1
Do Case
	Case _cTipPesq == "001"
		DbSelectArea("VV9")
		DbSetOrder(1)
		DbSeek(xFilial("VV9")+_cOrigem)	
		DbSelectArea("SA1")
		DbSetOrder(1)
		MsSeek( xFilial("SA1") + VV9->VV9_CODCLI + VV9->VV9_LOJA )
	Case _cTipPesq == "002"
		DbSelectArea("VO1")
		DbSetOrder(1)
		DbSeek(xFilial("VO1")+_cOrigem)	
		DbSelectArea("SA1")
		DbSetOrder(1)
		MsSeek( xFilial("SA1") + VO1->VO1_PROVEI + VO1->VO1_LOJPRO )
	Case _cTipPesq == "003"
		DbSelectArea("VS1")
		DbSetOrder(1)
		DbSeek(xFilial("VS1")+_cOrigem)	
		DbSelectArea("SA1")
		DbSetOrder(1)
		MsSeek( xFilial("SA1") + VS1->VS1_CLIFAT + VS1->VS1_LOJA )
	Case _cTipPesq == "004"
		DbSelectArea("VC1")
		DbSetOrder(1)
		DbGoTo( val( _cOrigem ) )
		DbSelectArea("SA1")
		DbSetOrder(1)
		MsSeek( xFilial("SA1") + VC1->VC1_CODCLI + VC1->VC1_LOJA )
EndCase
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VLDNIVIMP³ Autor ³  Andre Luis Almeida ³ Data ³ 21/02/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do Nivel de Importancia do Cliente ( Filtro )    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_VLDNIVIMP( cCodCli , cLojCli )
Local lRet := .t.
DbSelectArea("VCF")
DbSetOrder(1)
MsSeek( xFilial("VCF") + cCodCli + cLojCli )
If VCF->VCF_NIVIMP <> cNivImp // Filtro por Nivel de Importacia do Cliente
	lRet := .f.
EndIf
Return lRet