// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 12     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch" 
#include "VEIVC200.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVC200 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 25/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Gerencial de F&I                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVC200(cPAREmp,aPAREmp,dPARDtI,dPARDtF,cPARAgr,cPARSta,cPARTNU)
Local lDClik    := .f.
Local aFWArrFilAtu := FWArrFilAtu()
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private lMarcar := .f.
Private cAgrupa := STR0033 // Banco
Private aAgrupa := IIf(GetNewPar("MV_AVEIMAX",1)==1,{STR0033,STR0034,STR0035,STR0036,STR0037,STR0012},{STR0033,STR0034,STR0037,STR0012}) // Banco / Tabela F&I / Grupo Modelo / Modelo / Vendedor / Filial   //   Banco / Tabela F&I / Vendedor / Filial
Private cStatus := STR0016 // Finalizados
Private aStatus := {STR0016,STR0017} // Finalizados / Nao Finalizados
Private cVeiTNU := STR0014 // Todos Veiculos
Private aVeiTNU := {STR0014,STR0027,STR0028} // Todos Veiculos / Novos / Usados
Private aFISalva:= {}
Private aFITotal:= {}
Private aFIAtend:= {}
Private aVetEmp := {}
Private aEmpr   := {} // Empresas Consolidadas
Private cEmpr   := "" // Nome da Empresa
Private dDatIni := (dDataBase-day(dDataBase))+1
Private dDatFin := dDataBase
Default dPARDtI := dDatIni // Dt.Inicial
Default dPARDtF := dDatFin // Dt.Final
Default cPARAgr := cAgrupa // Agrupador
Default cPARSta := cStatus // Status
Default cPARTNU := cVeiTNU // Todos Veiculos / Novos / Usados
Default cPAREmp := ""
Default aPAREmp := aEmpr
DEFINE FONT oTitTela NAME "Arial" SIZE 10,13 BOLD
// Levanta Todas Filiais //
aEmpr := aPAREmp
If !Empty(cPAREmp)
	cEmpr := " - "+STR0005+": " // Consolidado
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
cAgrupa := cPARAgr
cStatus := cPARSta
cVeiTNU := cPARTNU
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  10 , .T. , .F. } ) // Filtro no topo
aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox Bancos
aPos := MsObjSize( aInfo, aObjects )
Processa( {|| FS_FILTRAR(0) } )
DEFINE MSDIALOG oConsFandI FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta Gerencial de F&I
	oConsFandI:lEscClose := .F.
	@ aPos[2,1],aPos[2,2] LISTBOX oLbFITotal FIELDS HEADER STR0019 ,; // Agrupador
														STR0015 ,; // Vlr.Venda Total
														STR0020 ,; // Financiado x Venda
														STR0021 ,; // Vlr.Venda
														STR0022 ,; // Vlr.Financiado
														STR0023 ,; // Retorno Vlr.Financiado
														STR0024 ,; // TAC Vlr.Financiado
														STR0025 ;  // PLUS Vlr.Financiado
														COLSIZES 140,68,68,68,68,68,68,68 SIZE aPos[2,4]-2,aPos[2,3]-aPos[1,3]-2 OF oConsFandI PIXEL ON DBLCLICK Processa( {|| FS_ATEND(aFITotal[oLbFITotal:nAt,1]) } )
	oLbFITotal:SetArray(aFITotal)
	oLbFITotal:bLine := { || { aFITotal[oLbFITotal:nAt,2] ,;
     	                	IIf(aFITotal[oLbFITotal:nAt,11]<>0,FG_AlinVlrs(Transform(aFITotal[oLbFITotal:nAt,11],"@E 999,999,999,999.99"))+Transform((aFITotal[oLbFITotal:nAt,11]/aFITotal[1,11])*100,"@E 9999.9")+"%","") ,;
     	                	IIf(aFITotal[oLbFITotal:nAt,10]<>0,FG_AlinVlrs(Transform(aFITotal[oLbFITotal:nAt,3],"@E 999,999,999")+" / "+Transform(aFITotal[oLbFITotal:nAt,10],"@E 999,999,999"))+Transform((aFITotal[oLbFITotal:nAt,3]/aFITotal[oLbFITotal:nAt,10])*100,"@E 9999.9")+"%","") ,;
     	                	IIf(aFITotal[oLbFITotal:nAt,4]<>0,FG_AlinVlrs(Transform(aFITotal[oLbFITotal:nAt,4],"@E 999,999,999,999.99"))+Transform((aFITotal[oLbFITotal:nAt,4]/aFITotal[oLbFITotal:nAt,11])*100,"@E 9999.9")+"%","") ,;
     	                	IIf(aFITotal[oLbFITotal:nAt,5]<>0,FG_AlinVlrs(Transform(aFITotal[oLbFITotal:nAt,5],"@E 999,999,999,999.99"))+Transform((aFITotal[oLbFITotal:nAt,5]/aFITotal[1,5])*100,"@E 9999.9")+"%","") ,;
     	                	IIf(aFITotal[oLbFITotal:nAt,6]<>0,FG_AlinVlrs(Transform(aFITotal[oLbFITotal:nAt,6],"@E 999,999,999,999.99"))+Transform((aFITotal[oLbFITotal:nAt,6]/aFITotal[oLbFITotal:nAt,5])*100,"@E 9999.9")+"%","") ,;
     	                	IIf(aFITotal[oLbFITotal:nAt,7]<>0,FG_AlinVlrs(Transform(aFITotal[oLbFITotal:nAt,7],"@E 999,999,999,999.99"))+Transform((aFITotal[oLbFITotal:nAt,7]/aFITotal[oLbFITotal:nAt,5])*100,"@E 9999.9")+"%","") ,;
     	                	IIf(aFITotal[oLbFITotal:nAt,8]<>0,FG_AlinVlrs(Transform(aFITotal[oLbFITotal:nAt,8],"@E 999,999,999,999.99"))+Transform((aFITotal[oLbFITotal:nAt,8]/aFITotal[oLbFITotal:nAt,5])*100,"@E 9999.9")+"%","") }}
	@ aPos[1,1]+1,aPos[1,2]+000 SAY (STR0019+":") SIZE 40,10 OF oConsFandI PIXEL COLOR CLR_BLUE // Agrupador
	@ aPos[1,1]+0,aPos[1,2]+029 MSCOMBOBOX oAgrupa VAR cAgrupa ITEMS aAgrupa VALID Processa( {|| FS_FILTRAR(1) } ) SIZE 50,08 OF oConsFandI PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+1,aPos[1,2]+085 SAY (STR0029+":") SIZE 40,10 OF oConsFandI PIXEL COLOR CLR_BLUE // Atendimentos
	@ aPos[1,1]+0,aPos[1,2]+121 MSCOMBOBOX oStatus VAR cStatus ITEMS aStatus VALID Processa( {|| FS_FILTRAR(1) } ) SIZE 55,08 OF oConsFandI PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+1,aPos[1,2]+182 SAY (STR0006+":") SIZE 40,10 OF oConsFandI PIXEL COLOR CLR_BLUE // Periodo
	@ aPos[1,1]+0,aPos[1,2]+202 MSGET oDatIni VAR dDatIni VALID( dDatIni <= dDataBase ) SIZE 40,06 OF oConsFandI PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+1,aPos[1,2]+244 SAY STR0007 SIZE 10,10 OF oConsFandI PIXEL COLOR CLR_BLUE // ate
	@ aPos[1,1]+0,aPos[1,2]+255 MSGET oDatFin VAR dDatFin VALID( dDatIni <= dDatFin ) SIZE 40,06 OF oConsFandI PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+0,aPos[1,2]+298 BUTTON oOk PROMPT STR0008 OF oConsFandI SIZE 17,09 PIXEL ACTION Processa( {|| FS_FILTRAR(1) } ) // OK
	@ aPos[1,1]+0,aPos[1,2]+317 MSCOMBOBOX oVeiTNU VAR cVeiTNU ITEMS aVeiTNU VALID Processa( {|| FS_VEITNU(1) } ) SIZE 50,08 OF oConsFandI PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+0,aPos[1,2]+369 BUTTON oGrafico PROMPT STR0038 OF oConsFandI SIZE 60,10 PIXEL ACTION FS_GRAFICO() // Grafico Financiamento
	@ aPos[1,1]+0,aPos[1,4]-043 BUTTON oEmpr PROMPT UPPER(STR0009) OF oConsFandI SIZE 23,10 PIXEL ACTION (lDClik:=.t.,oConsFandI:End()) // Filiais
	@ aPos[1,1]+0,aPos[1,4]-018 BUTTON oGrpSair PROMPT STR0010 OF oConsFandI SIZE 18,10 PIXEL ACTION oConsFandI:End() // SAIR
ACTIVATE MSDIALOG oConsFandI
If lDClik
	VEIVC200(cEmpr,aEmpr,dDatIni,dDatFin,cAgrupa,cStatus,cVeiTNU)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILTRAR ³ Autor ³  Andre Luis Almeida ³ Data ³ 25/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra Periodo                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAR(nTp)
Local cQuery   := ""
Local cQAlAux  := "SQLAUX" // SQL Auxiliar
Local cQAlVV09 := "SQLVV09" // VV0 / VV9
Local cFilSALVA:= cFilAnt
Local nEmpr    := 0
Local nPos     := 0
Local nPosAnt  := 0
Local nTot     := 0
Local nVlrVda  := 0
Local nVlrFin  := 0
Local nVlrRet  := 0
Local nVlrTAC  := 0
Local nVlrPlu  := 0
Local cCompara := ""
Local cDescr   := ""
Local cx       := "" // Variavel utilizada no vetor para Sort


aFITotal := {}
aFIAtend := {}
aAdd(aFITotal,{"1"+space(40)+" ",STR0026,0,0,0,0,0,0,"",0,0}) // TOTAL GERAL
aAdd(aFITotal,{"1"+space(40)+"0",STR0026+" ( "+UPPER(STR0027)+" )",0,0,0,0,0,0,"",0,0}) // TOTAL GERAL ( NOVOS )
aAdd(aFITotal,{"1"+space(40)+"1",STR0026+" ( "+UPPER(STR0028)+" )",0,0,0,0,0,0,"",0,0}) // TOTAL GERAL ( USADOS )
ProcRegua(len(aEmpr)+2)
IncProc(STR0018) // Levantando...
For nEmpr := 1 to len(aEmpr)
	IncProc(STR0018) // Levantando...
	cFilAnt := aEmpr[nEmpr,1]
	cQuery := "SELECT VV0.VV0_NUMTRA , VV0.VV0_TIPFAT , VV0.VV0_VALTOT , VV0.VV0_VALFIN , VV0.VV0_VTXRET , VV0.VV0_VCUSFN , VV0.VV0_VALTAC , VV0.VV0_VCOMFN "
	Do Case 
		Case cAgrupa == STR0033 // Banco
			cQuery += ", VV0.VV0_CODBCO "
		Case cAgrupa == STR0034 // Tabela F&I
			cQuery += ", VV0.VV0_CODBCO , VV0.VV0_TABFAI "
		Case cAgrupa == STR0035 // Grupo Modelo
			cQuery += ", VV0.VV0_CODMAR , VV0.VV0_GRUMOD "
		Case cAgrupa == STR0036 // Modelo
			cQuery += ", VV0.VV0_CODMAR , VV0.VV0_GRUMOD , VV0.VV0_MODVEI "
		Case cAgrupa == STR0037 // Vendedor
			cQuery += ", VV0.VV0_CODVEN "
	EndCase
	cQuery += "FROM "+RetSqlName("VV0")+" VV0 "
	cQuery += "INNER JOIN "+RetSqlName("VV9")+" VV9 ON VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND "
	If cStatus == STR0016 // Finalizados
		cQuery += "VV9.VV9_STATUS IN ('F','T') AND "
	Else // If cStatus == STR0017 // Nao Finalizados
		cQuery += "VV9.VV9_STATUS IN ('O','L','A','P') AND "
	EndIf
	cQuery += "VV9.D_E_L_E_T_=' ' "
	cQuery += "WHERE VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_OPEMOV IN (' ','0') AND VV0.VV0_DATMOV>='"+dtos(dDatIni)+"' AND VV0.VV0_DATMOV<='"+dtos(dDatFin)+"' AND "
	cQuery += "VV0.VV0_TIPFAT IN ('0','1') AND VV0.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV09, .F., .T. )
	Do While !( cQAlVV09 )->( Eof() )
		cx := "2"
		Do Case
			Case cAgrupa == STR0033 // Banco
				cCompara := ( cQAlVV09 )->( VV0_CODBCO )
				If Empty(cCompara)
					cx := "3"
				EndIf
				nPos := aScan(aFITotal,{|x| x[1] == cx+left(cCompara+space(40),40)+" " })
				If nPos <= 0
					cDescr := ( cQAlVV09 )->( VV0_CODBCO )
					cQuery := "SELECT SA6.A6_NOME FROM "+RetSqlName("SA6")+" SA6 WHERE SA6.A6_FILIAL='"+xFilial("SA6")+"' AND SA6.A6_COD='"+( cQAlVV09 )->( VV0_CODBCO )+"' AND SA6.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
					If !( cQAlAux )->( Eof() )
						cDescr += " - "+left(( cQAlAux )->( A6_NOME ),15)
					Else
						cDescr :=  STR0030 // Sem Financiamento
					EndIf
					( cQAlAux )->( dbCloseArea() )
			   	EndIf
			Case cAgrupa == STR0034 // Tabela F&I
				cCompara := ( cQAlVV09 )->( VV0_CODBCO )+( cQAlVV09 )->( VV0_TABFAI )
				If Empty(cCompara)
					cx := "3"
				EndIf
				nPos := aScan(aFITotal,{|x| x[1] == cx+left(cCompara+space(40),40)+" " })
				If nPos <= 0
					cDescr := ( cQAlVV09 )->( VV0_CODBCO )
					cQuery := "SELECT SA6.A6_NOME FROM "+RetSqlName("SA6")+" SA6 WHERE SA6.A6_FILIAL='"+xFilial("SA6")+"' AND SA6.A6_COD='"+( cQAlVV09 )->( VV0_CODBCO )+"' AND SA6.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
					If !( cQAlAux )->( Eof() )
						cDescr += " - "+left(( cQAlAux )->( A6_NOME ),15)
						cDescr += " / "+STR0032+": "+( cQAlVV09 )->( VV0_TABFAI ) // Tabela
					Else
						cDescr := STR0030 // Sem Financiamento
					EndIf
					( cQAlAux )->( dbCloseArea() )
		   		EndIf
			Case cAgrupa == STR0035 // Grupo Modelo
				cCompara := ( cQAlVV09 )->( VV0_CODMAR )+left(( cQAlVV09 )->( VV0_GRUMOD),6)
				nPos := aScan(aFITotal,{|x| x[1] == cx+left(cCompara+space(40),40)+" " })
				If nPos <= 0
					cDescr := ( cQAlVV09 )->( VV0_CODMAR )+" "+left(( cQAlVV09 )->( VV0_GRUMOD),6)
					cQuery := "SELECT VVR.VVR_DESCRI FROM "+RetSqlName("VVR")+" VVR WHERE VVR.VVR_FILIAL='"+xFilial("VVR")+"' AND VVR.VVR_CODMAR='"+( cQAlVV09 )->( VV0_CODMAR )+"' AND VVR.VVR_GRUMOD='"+left(( cQAlVV09 )->( VV0_GRUMOD ),6)+"' AND VVR.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
					If !( cQAlAux )->( Eof() )
						cDescr += " - "+( cQAlAux )->( VVR_DESCRI )
					EndIf
					( cQAlAux )->( dbCloseArea() )
			   	EndIf
			Case cAgrupa == STR0036 // Modelo
				cCompara := ( cQAlVV09 )->( VV0_CODMAR )+left(( cQAlVV09 )->( VV0_GRUMOD),6)+( cQAlVV09 )->( VV0_MODVEI )
				nPos := aScan(aFITotal,{|x| x[1] == cx+left(cCompara+space(40),40)+" " })
				If nPos <= 0
					cDescr := ( cQAlVV09 )->( VV0_CODMAR )+" "+left(( cQAlVV09 )->( VV0_GRUMOD),6)+" "+Alltrim(( cQAlVV09 )->( VV0_MODVEI ))
					cQuery := "SELECT VV2.VV2_DESMOD FROM "+RetSqlName("VV2")+" VV2 WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR='"+( cQAlVV09 )->( VV0_CODMAR )+"' AND VV2.VV2_MODVEI='"+( cQAlVV09 )->( VV0_MODVEI )+"' AND VV2.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
					If !( cQAlAux )->( Eof() )
						cDescr += " - "+( cQAlAux )->( VV2_DESMOD )
					EndIf
					( cQAlAux )->( dbCloseArea() )
			   	EndIf
			Case cAgrupa == STR0037 // Vendedor
				cCompara := ( cQAlVV09 )->( VV0_CODVEN )
				nPos := aScan(aFITotal,{|x| x[1] == cx+left(cCompara+space(40),40)+" " })
				If nPos <= 0
					cDescr := ( cQAlVV09 )->( VV0_CODVEN )
					cQuery := "SELECT SA3.A3_NOME FROM "+RetSqlName("SA3")+" SA3 WHERE SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD='"+( cQAlVV09 )->( VV0_CODVEN )+"' AND SA3.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
					If !( cQAlAux )->( Eof() )
						cDescr += " - "+( cQAlAux )->( A3_NOME )
					EndIf
					( cQAlAux )->( dbCloseArea() )
			   	EndIf
			Case cAgrupa == STR0012 // Filial
				cCompara := cFilAnt
				nPos := aScan(aFITotal,{|x| x[1] == cx+left(cCompara+space(40),40)+" " })
				If nPos <= 0
					cDescr := cFilAnt+" - "+FWFilialName()
			   	EndIf			
		EndCase
		If nPos <= 0
			aAdd(aFITotal,{cx+left(cCompara+space(40),40)+" ",cDescr,0,0,0,0,0,0,"",0,0})
			nPos := len(aFITotal)
			aAdd(aFITotal,{cx+left(cCompara+space(40),40)+"0",cDescr,0,0,0,0,0,0,"( "+UPPER(STR0027)+" )"+" - ",0,0}) // ( NOVOS ) 
			aAdd(aFITotal,{cx+left(cCompara+space(40),40)+"1",cDescr,0,0,0,0,0,0,"( "+UPPER(STR0028)+" )"+" - ",0,0}) // ( USADOS )
		EndIf
		nVlrVda := ( cQAlVV09 )->( VV0_VALTOT ) // Vlr.Venda
		nVlrFin := 0 // Vlr.Financiado
		nVlrRet := 0 // Retorno
		nVlrTAC := 0 // TAC
		nVlrPlu := 0 // PLUS
		// Total Geral //
		nTot := 1 // Total
		aFITotal[nTot,10]++ // Qtde Total
		aFITotal[nTot,11] += nVlrVda // Valor Total
        // Agrupador //
		aFITotal[nPos,10]++ // Qtde
		aFITotal[nPos,11] += nVlrVda // Vlr.Venda
		nPosAnt := nPos
		nPos++ // Novos
		nTot := 2 // Total Novos
		If ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Usados
			nPos++ // Usados
			nTot := 3 // Total Usados
		EndIf
		aFITotal[nTot,10]++ // Qtde Total ( Novos / Usados )
		aFITotal[nTot,11] += nVlrVda // Valor Total
		// Agrupador ( Novos / Usados ) //
		aFITotal[nPos,10]++ // Qtde
		aFITotal[nPos,11] += nVlrVda // Vlr.Venda
		If ( cQAlVV09 )->( VV0_VALFIN ) > 0
			nVlrFin := ( cQAlVV09 )->( VV0_VALFIN ) // Vlr.Financiado
			nVlrRet := ( ( cQAlVV09 )->( VV0_VTXRET ) - ( cQAlVV09 )->( VV0_VCUSFN ) ) // Retorno
			nVlrTAC := ( cQAlVV09 )->( VV0_VALTAC ) // TAC
			nVlrPlu := ( cQAlVV09 )->( VV0_VCOMFN ) // PLUS
			// Total Geral //
			nTot := 1
			aFITotal[nTot,3]++ // Qtde
			aFITotal[nTot,4] += nVlrVda // Vlr.Venda
			aFITotal[nTot,5] += nVlrFin // Vlr.Financiado
			aFITotal[nTot,6] += nVlrRet // Retorno
			aFITotal[nTot,7] += nVlrTAC // TAC
			aFITotal[nTot,8] += nVlrPlu // PLUS
			nPos := nPosAnt
	        // Agrupador //
			aFITotal[nPos,3]++ // Qtde
			aFITotal[nPos,4] += nVlrVda // Vlr.Venda
			aFITotal[nPos,5] += nVlrFin // Vlr.Financiado
			aFITotal[nPos,6] += nVlrRet // Retorno
			aFITotal[nPos,7] += nVlrTAC // TAC
			aFITotal[nPos,8] += nVlrPlu // PLUS
			nPos++ // Novos
			nTot := 2 // Total Novos
			If ( cQAlVV09 )->( VV0_TIPFAT ) == "1" // Usados
				nPos++ // Usados
				nTot := 3 // Total Usados
			EndIf
			// Total Geral ( Novos / Usados ) //
			aFITotal[nTot,3]++ // Qtde
			aFITotal[nTot,4] += nVlrVda // Vlr.Venda
			aFITotal[nTot,5] += nVlrFin // Vlr.Financiado
			aFITotal[nTot,6] += nVlrRet // Retorno
			aFITotal[nTot,7] += nVlrTAC // TAC
			aFITotal[nTot,8] += nVlrPlu // PLUS
			// Agrupador ( Novos / Usados ) //
			aFITotal[nPos,3]++ // Qtde
			aFITotal[nPos,4] += nVlrVda // Vlr.Venda
			aFITotal[nPos,5] += nVlrFin // Vlr.Financiado
			aFITotal[nPos,6] += nVlrRet // Retorno
			aFITotal[nPos,7] += nVlrTAC // TAC
			aFITotal[nPos,8] += nVlrPlu // PLUS
		EndIf
		// Atendimentos //
		aAdd(aFIAtend,{cx+left(cCompara+space(40),40)+( cQAlVV09 )->( VV0_TIPFAT ),aEmpr[nEmpr,1]+" - "+FWFilialName(),( cQAlVV09 )->( VV0_NUMTRA ),nVlrVda,nVlrFin,nVlrRet,nVlrTAC,nVlrPlu,""})
		//////////////////
	   	( cQAlVV09 )->( DbSkip() )
	EndDo
	( cQAlVV09 )->( dbCloseArea() )
Next
IncProc(STR0018) // Levantando...
cFilAnt := cFilSALVA
aSort(aFITotal,1,,{|x,y| x[1] < y[1] }) // Ordenar Vetor
aFISalva := aClone(aFITotal)
FS_VEITNU(nTp)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VEITNU  ³ Autor ³  Andre Luis Almeida ³ Data ³ 25/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Todos Veiculos / Novos / Usados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VEITNU(nTp)
Local ni := 0
Local ci := ""
aFITotal := {}
For ni := 1 to len(aFISalva)
	ci := substr(aFISalva[ni,1],42,1)
	If ( ci==" " .and. cVeiTNU==STR0014 ) .or. ( ci=="0" .and. cVeiTNU==STR0027 ) .or. ( ci=="1" .and. cVeiTNU==STR0028 ) // Todos Veiculos / Novos / Usados
		aAdd(aFITotal,aClone(aFISalva[ni]))
	EndIf
Next
If nTp > 0
	oLbFITotal:nAt := 1
	oLbFITotal:SetArray(aFITotal)
	oLbFITotal:bLine := { || { aFITotal[oLbFITotal:nAt,2] ,;
     	                	IIf(aFITotal[oLbFITotal:nAt,11]<>0,FG_AlinVlrs(Transform(aFITotal[oLbFITotal:nAt,11],"@E 999,999,999,999.99"))+Transform((aFITotal[oLbFITotal:nAt,11]/aFITotal[1,11])*100,"@E 9999.9")+"%","") ,;
     	                	IIf(aFITotal[oLbFITotal:nAt,10]<>0,FG_AlinVlrs(Transform(aFITotal[oLbFITotal:nAt,3],"@E 999,999,999")+" / "+Transform(aFITotal[oLbFITotal:nAt,10],"@E 999,999,999"))+Transform((aFITotal[oLbFITotal:nAt,3]/aFITotal[oLbFITotal:nAt,10])*100,"@E 9999.9")+"%","") ,;
     	                	IIf(aFITotal[oLbFITotal:nAt,4]<>0,FG_AlinVlrs(Transform(aFITotal[oLbFITotal:nAt,4],"@E 999,999,999,999.99"))+Transform((aFITotal[oLbFITotal:nAt,4]/aFITotal[oLbFITotal:nAt,11])*100,"@E 9999.9")+"%","") ,;
     	                	IIf(aFITotal[oLbFITotal:nAt,5]<>0,FG_AlinVlrs(Transform(aFITotal[oLbFITotal:nAt,5],"@E 999,999,999,999.99"))+Transform((aFITotal[oLbFITotal:nAt,5]/aFITotal[1,5])*100,"@E 9999.9")+"%","") ,;
     	                	IIf(aFITotal[oLbFITotal:nAt,6]<>0,FG_AlinVlrs(Transform(aFITotal[oLbFITotal:nAt,6],"@E 999,999,999,999.99"))+Transform((aFITotal[oLbFITotal:nAt,6]/aFITotal[oLbFITotal:nAt,5])*100,"@E 9999.9")+"%","") ,;
     	                	IIf(aFITotal[oLbFITotal:nAt,7]<>0,FG_AlinVlrs(Transform(aFITotal[oLbFITotal:nAt,7],"@E 999,999,999,999.99"))+Transform((aFITotal[oLbFITotal:nAt,7]/aFITotal[oLbFITotal:nAt,5])*100,"@E 9999.9")+"%","") ,;
     	                	IIf(aFITotal[oLbFITotal:nAt,8]<>0,FG_AlinVlrs(Transform(aFITotal[oLbFITotal:nAt,8],"@E 999,999,999,999.99"))+Transform((aFITotal[oLbFITotal:nAt,8]/aFITotal[oLbFITotal:nAt,5])*100,"@E 9999.9")+"%","") }}
	oLbFITotal:Refresh()
	oLbFITotal:SetFocus()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  FS_ATEND  | Autor ³  Andre Luis Almeida ³ Data ³ 27/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Atendimentos do SELECIONADO                        |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATEND(cPesquisa)
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lTot      := .f.
Local ni        := 0
Local nTot      := 0
Local aFIVerAte := {}
DEFINE FONT oTitTela NAME "Arial" SIZE 11,13 BOLD
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0, 10, .T., .f. } ) // Filtro no topo
aAdd( aObjects, { 0, 30, .T., .T. } ) // ListBox Atendimentos
aPos := MsObjSize( aInfo, aObjects )
ProcRegua(len(aFIAtend))
aAdd(aFIVerAte,aClone(aFITotal[oLbFITotal:nAt]))
aFIVerAte[1,2] := STR0026+" ( "+Alltrim(str(aFIVerAte[1,10]))+" "+STR0029+" )" // TOTAL GERAL / Atendimentos
aFIVerAte[1,3] := ""
aFIVerAte[1,4] := 0
aFIVerAte[1,5] := 0
aFIVerAte[1,6] := 0
aFIVerAte[1,7] := 0
aFIVerAte[1,8] := 0
For ni := 1 to len(aFIAtend)
	IncProc(STR0018) // Levantando...
	lTot := .f.
	If left(cPesquisa,1) == "3" // Nao Informados (Banco/Tabela)
		If left(aFIAtend[ni,1],1) == "3"
			If substr(cPesquisa,42,1) <> " " // ( Novos/ Usados )
				If cPesquisa == aFIAtend[ni,1]
					aAdd(aFIVerAte,aClone(aFIAtend[ni]))
					lTot := .t.
				EndIf
			Else // Total
				aAdd(aFIVerAte,aClone(aFIAtend[ni]))
				lTot := .t.
			EndIf
		EndIf
	Else
		If !Empty(substr(cPesquisa,2,40)) // Agrupados
			If substr(cPesquisa,42,1) <> " " // ( Novos/ Usados )
				If cPesquisa == aFIAtend[ni,1]
					aAdd(aFIVerAte,aClone(aFIAtend[ni]))
					lTot := .t.
				EndIf
			Else // Total
				If left(cPesquisa,41) == left(aFIAtend[ni,1],41)
					aAdd(aFIVerAte,aClone(aFIAtend[ni]))
					lTot := .t.
				EndIf
			EndIf
		Else // Total Geral 
			If substr(cPesquisa,42,1) <> " "
				If substr(cPesquisa,42,1) == substr(aFIAtend[ni,1],42,1)
					aAdd(aFIVerAte,aClone(aFIAtend[ni])) // ( Novos / Usados )
					lTot := .t.
				EndIf
			Else
				aAdd(aFIVerAte,aClone(aFIAtend[ni])) // Total
				lTot := .t.
			EndIf
		EndIf
	EndIf
	If lTot // Totalizar
		aFIVerAte[1,4] += aFIVerAte[len(aFIVerAte),4]
		aFIVerAte[1,5] += aFIVerAte[len(aFIVerAte),5]
		aFIVerAte[1,6] += aFIVerAte[len(aFIVerAte),6]
		aFIVerAte[1,7] += aFIVerAte[len(aFIVerAte),7]
		aFIVerAte[1,8] += aFIVerAte[len(aFIVerAte),8]
	EndIf
Next
IncProc(STR0018) // Levantando...
DEFINE MSDIALOG oConsFIAte FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta Gerencial de F&I
	@ aPos[1,1]+001,aPos[1,2] SAY (aFITotal[oLbFITotal:nAt,9]+Alltrim(aFITotal[oLbFITotal:nAt,2])) SIZE 500,10 OF oConsFIAte PIXEL COLOR CLR_RED FONT oTitTela
	@ aPos[2,1],aPos[2,2] LISTBOX oLbFIVerAte FIELDS HEADER (STR0012) ,; // Filial
														STR0029 ,; // Atendimentos
														STR0021 ,; // Vlr.Venda
														STR0022 ,; // Vlr.Financiado
														STR0023 ,; // Retorno Vlr.Financiado
														STR0024 ,; // TAC Vlr.Financiado
														STR0025 ;  // PLUS Vlr.Financiado
														COLSIZES 150,75,75,75,75,75,75 SIZE aPos[2,4]-2,aPos[2,3]-aPos[1,3]-2 OF oConsFIAte PIXEL ON DBLCLICK FS_VERATEND(aFIVerAte[oLbFIVerAte:nAt,2],aFIVerAte[oLbFIVerAte:nAt,3],oLbFIVerAte:nAt)
	oLbFIVerAte:SetArray(aFIVerAte)
	oLbFIVerAte:bLine := { || { aFIVerAte[oLbFIVerAte:nAt,2] , aFIVerAte[oLbFIVerAte:nAt,3] ,;
     	                	IIf(aFIVerAte[oLbFIVerAte:nAt,4]>0,FG_AlinVlrs(Transform(aFIVerAte[oLbFIVerAte:nAt,4],"@E 999,999,999,999.99"))+Transform((aFIVerAte[oLbFIVerAte:nAt,4]/aFIVerAte[1,4])*100,"@E 9999.99")+"%","") ,;
     	                	IIf(aFIVerAte[oLbFIVerAte:nAt,5]>0,FG_AlinVlrs(Transform(aFIVerAte[oLbFIVerAte:nAt,5],"@E 999,999,999,999.99"))+Transform((aFIVerAte[oLbFIVerAte:nAt,5]/aFIVerAte[1,5])*100,"@E 9999.99")+"%","") ,;
     	                	IIf(aFIVerAte[oLbFIVerAte:nAt,6]>0,FG_AlinVlrs(Transform(aFIVerAte[oLbFIVerAte:nAt,6],"@E 999,999,999,999.99"))+Transform((aFIVerAte[oLbFIVerAte:nAt,6]/aFIVerAte[oLbFIVerAte:nAt,5])*100,"@E 9999.99")+"%","") ,;
     	                	IIf(aFIVerAte[oLbFIVerAte:nAt,7]>0,FG_AlinVlrs(Transform(aFIVerAte[oLbFIVerAte:nAt,7],"@E 999,999,999,999.99"))+Transform((aFIVerAte[oLbFIVerAte:nAt,7]/aFIVerAte[oLbFIVerAte:nAt,5])*100,"@E 9999.99")+"%","") ,;
     	                	IIf(aFIVerAte[oLbFIVerAte:nAt,8]>0,FG_AlinVlrs(Transform(aFIVerAte[oLbFIVerAte:nAt,8],"@E 999,999,999,999.99"))+Transform((aFIVerAte[oLbFIVerAte:nAt,8]/aFIVerAte[oLbFIVerAte:nAt,5])*100,"@E 9999.99")+"%","") }}
	@ aPos[1,1],aPos[1,4]-027 BUTTON oGrpSair PROMPT STR0010 OF oConsFIAte SIZE 27,10 PIXEL ACTION oConsFIAte:End() // SAIR
ACTIVATE MSDIALOG oConsFIAte
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERATEND | Autor ³  Andre Luis Almeida ³ Data ³ 27/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza Atendimento (VEIXX002)                           |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERATEND(cEmpFil,cAtend,nLinha)
Local cFilSALVA   := cFilAnt
Private cCadastro := STR0029 // Atendimentos
If nLinha > 1
	cFilAnt := left(cEmpFil,len(cFilAnt))
	DbSelectArea("VV9")
	DbSetOrder(1)
	If DbSeek( xFilial("VV9") + cAtend )
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
±±³Funcao    ³ FS_GRAFICO | Autor ³  Andre Luis Almeida ³ Data ³ 27/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grafico da Consulta F&I                                    |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAFICO()
Local ci       := ""
Local ni       := 0
Local aGrafico := {}
If len(aFITotal) > 0
	For ni := 1 to len(aFITotal)
		If aFITotal[ni,5] > 0
			If ni == 1
				ci := STR0031 // MEDIA GERAL
			Else
				ci := Alltrim(left(aFITotal[ni,2],20))
			EndIf
			Aadd(aGrafico,{round((((aFITotal[ni,6]+aFITotal[ni,7]+aFITotal[ni,8])/aFITotal[ni,5])*100),2),ci,})
		EndIf
	Next
	If len(aGrafico) > 0
		FG_GRAFICO(,STR0001+" - "+aFITotal[1,9]+Alltrim(aFITotal[1,2])+"   "+STR0039,,,,,aGrafico,4) // Consulta Gerencial de F&I - (   R E T O R N O    x    F I N A N C I A M E N T O   )   %	
	Else
		MsgStop(STR0003,STR0002) // Nao existem dados para esta Consulta ! / Atencao
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILIAIS³ Autor ³  Andre Luis Almeida   ³ Data ³ 27/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Filiais                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILIAIS()
Local aVetAux      := {}
Local ni           := {}
Local aFilAtu      := FWArrFilAtu()
Local aSM0         := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt   := cFilAnt
Local nCont        := 0
Local aFWArrFilAtu := {}
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aFWArrFilAtu := FWArrFilAtu()
	ni := aScan(aEmpr,{|x| x[1] == cFilAnt })
	aAdd( aVetEmp, { (ni>0) , cFilAnt , aFWArrFilAtu[SM0_FILIAL] , FWFilialName() })
Next
cFilAnt := cBkpFilAnt
If Len(aVetEmp) > 1
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 250,400 TITLE STR0009 PIXEL // Filiais
	@ 001,001 LISTBOX oLbEmp FIELDS HEADER "",STR0012,STR0013 COLSIZES 10,15,50 SIZE 165,120 OF oDlgEmp ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK    ³ Autor ³  Andre Luis Almeida  ³ Data ³ 27/01/10 ³±±
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
	If lMarcar
		aVetEmp[ni,1] := .t.
	Else
		aVetEmp[ni,1] := .f.
	EndIf
Next
oLbEmp:SetFocus()
oLbEmp:Refresh()
Return(.t.)