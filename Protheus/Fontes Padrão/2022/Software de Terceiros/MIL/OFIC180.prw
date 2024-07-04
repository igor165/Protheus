#INCLUDE "FIVEWIN.CH"
#INCLUDE "APVT100.CH"
#INCLUDE "OFIC180.CH"

/*/{Protheus.doc} OFIC180
Coletor/Leitor VT100 - Painel de Ultimas Conferencias - Saida / Entrada

@author Andre Luis Almeida
@since 04/06/2020
@version undefined

@type function
/*/
Function OFIC180()
Local nTamCol   := VTMaxCol() // Qtde maxima de Colunas no Display do Coletor
Local nTamLin   := VTMaxRow() // Qtde maxima de Linhas no Display do Coletor
Local nQtdReg   := 10 // Qtde Default
Local aVetReg   := {}
Local aSize     := {nTamCol}
Local aColunas  := { STR0001 } // Ultimas Conferencias
Local nPos      := 0
Local aLinhas   := {}
Local nCntFor   := 0
Local cTitulo   := STR0001 // Ultimas Conferencias
//
aAdd(aLinhas,{ STR0002 }) // Todas Conferencias
aAdd(aLinhas,{ STR0003 }) // Conf. Entradas
aAdd(aLinhas,{ STR0004 }) // Conf. Oficina
aAdd(aLinhas,{ STR0005 }) // Conf. Orcamentos
//
nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,1) // Lista de Opcoes
OC1800041_LIMPATELA(nTamLin,nTamCol)
//
If nPos > 0
	//
	Do Case
		Case nPos == 2
			cTitulo := STR0006 // Ult.Conf.Entradas
		Case nPos == 3
			cTitulo := STR0007 // Ult.Conf.Oficina
		Case nPos == 4
			cTitulo := STR0008 // Ult.Conf.Orcamentos
	EndCase
	aColunas  := { cTitulo }
	//
	nQtdReg := OC1800051_QtdeRegistros(cTitulo,nQtdReg,nTamCol)
	OC1800041_LIMPATELA(nTamLin,nTamCol)
	//
	If nPos == 1 .or. nPos == 2 // 1=Todos ou 2=Entradas ( NFs / Volumes )
		aVetReg := OC1800011_LevantaEntradas(aVetReg,nQtdReg,nTamCol,nPos)
	EndIf
	//
	If nPos == 1 .or. nPos == 3 // 1=Todos ou 3=OSs
		aVetReg := OC1800021_LevantaOficina(aVetReg,nQtdReg,nTamCol,nPos)
	EndIf
	//
	If nPos == 1 .or. nPos == 4 // 1=Todos ou 4=Orcamentos
		aVetReg := OC1800031_LevantaOrcamentos(aVetReg,nQtdReg,nTamCol,nPos)
	EndIf
	//
	If nPos == 1 .or. nPos == 2 // 1=Todos ou 2=Entradas ( NFs / Volumes )
		aSort(aVetReg,1,,{|x,y| x[3] > y[3] }) // Ordenar decrescente pela Data/Hora Conferencia
	EndIf
	//
	aLinhas := {}
	For nCntFor := 1 to len(aVetReg)
		aAdd(aLinhas,{ aVetReg[nCntFor,4] }) // Todas Conferencias
		If len(aLinhas) == nQtdReg
			Exit
		EndIf
	Next
	//
	nPos := 1
	While .t.
		nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nPos) // Lista de Opcoes
		OC1800041_LIMPATELA(nTamLin,nTamCol)
		If nPos > 0
			OC1800061_MostraConferencia(aLinhas,nPos,aVetReg,nTamCol) // Mostrar Registro da Conferencia
			OC1800041_LIMPATELA(nTamLin,nTamCol)
		Else
			Exit
		EndIf
	EndDo
	//
EndIf
//
Return

/*/{Protheus.doc} OC1800011_LevantaEntradas
Levanta Registros de Entrada

@author Andre Luis Almeida
@since 05/06/2020
@version undefined

@type function
/*/
Static Function OC1800011_LevantaEntradas(aVetReg,nQtdReg,nTamCol,nPos)
Local oSqlHlp := DMS_SqlHelper():New()
Local cQuery  := ""
Local cQAlAux := "SQLAUX"
Local cAux    := ""
Local cTipo   := ""
//
cQuery := "SELECT VM0.VM0_CODIGO , VM0.VM0_DOC , VM0.VM0_SERIE , VM0.VM0_FORNEC , VM0.VM0_LOJA , VM0.VM0_STATUS , SF1.F1_TIPO ,"
cQuery += "  MAX(VM1.VM1_DATFIN "+FG_CONVSQL("CONCATENA")+" VM1.VM1_HORFIN) AS MAXDTHR "
cQuery += "  FROM "+RetSQLName("VM1")+" VM1 "
cQuery += "  JOIN "+RetSQLName("VM0")+" VM0 ON VM0.VM0_FILIAL=VM1.VM1_FILIAL AND VM0.VM0_CODIGO=VM1.VM1_CODVM0 AND VM0.D_E_L_E_T_=' ' "
cQuery += "  JOIN "+RetSQLName("SF1")+" SF1 ON SF1.F1_FILIAL='"+xFilial("SF1")+"' AND SF1.F1_DOC=VM0.VM0_DOC AND SF1.F1_SERIE=VM0.VM0_SERIE AND SF1.F1_FORNECE=VM0.VM0_FORNEC AND SF1.F1_LOJA=VM0.VM0_LOJA AND SF1.D_E_L_E_T_=' ' "
cQuery += " WHERE VM1.VM1_FILIAL='"+xFilial("VM1")+"' AND VM1.VM1_USRCON <> ' ' AND VM1.D_E_L_E_T_=' ' "
cQuery += " GROUP BY VM0.VM0_CODIGO , VM0.VM0_DOC , VM0.VM0_SERIE , VM0.VM0_FORNEC , VM0.VM0_LOJA , VM0.VM0_STATUS , SF1.F1_TIPO "
cQuery += " ORDER BY MAXDTHR DESC"
cQuery := oSqlHlp:TOPFunc(cQuery,nQtdReg)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
While !( cQAlAux )->( Eof() )
	If ( cQAlAux )->( F1_TIPO ) <> "D"
		cQuery := "SELECT A2_NOME "
		cQuery += "  FROM "+RetSQLName("SA2")
		cQuery += " WHERE A2_FILIAL='"+xFilial("SA2")+"'"
		cQuery += "   AND A2_COD='"+( cQAlAux )->( VM0_FORNEC )+"'"
		cQuery += "   AND A2_LOJA='"+( cQAlAux )->( VM0_LOJA )+"'"
		cQuery += "   AND D_E_L_E_T_=' '"
		cTipo  := "E" // Entrada
	Else
		cQuery := "SELECT A1_NOME "
		cQuery += "  FROM "+RetSQLName("SA1")
		cQuery += " WHERE A1_FILIAL='"+xFilial("SA1")+"'"
		cQuery += "   AND A1_COD='"+( cQAlAux )->( VM0_FORNEC )+"'"
		cQuery += "   AND A1_LOJA='"+( cQAlAux )->( VM0_LOJA )+"'"
		cQuery += "   AND D_E_L_E_T_=' '"
		cTipo  := "D" // Devolucao
	EndIf
	cAux := FM_SQL(cQuery)
	// 1 - NF Entrada
	aAdd(aVetReg , { "1" ,;
					 ( cQAlAux )->( VM0_CODIGO ) ,;
					 ( cQAlAux )->( MAXDTHR ) ,;
					 left( cTipo +" "+ ( cQAlAux )->( VM0_DOC )+" "+( cQAlAux )->( VM0_SERIE )+" "+cAux,nTamCol) ,;
					 ( cQAlAux )->( VM0_STATUS ) ,;
					 IIf(cTipo=="E",STR0009,STR0010) +" "+ ( cQAlAux )->( VM0_DOC )+" "+( cQAlAux )->( VM0_SERIE ) ,; // NF / Dev.
					 cAux } )
	( cQAlAux )->( DbSkip() )
EndDo
( cQAlAux )->( DbCloseArea() )
//
cQuery := "SELECT VM7.VM7_CODIGO , VM7.VM7_VOLUME , VM7.VM7_STATUS ,"
cQuery += "  MAX(VM8.VM8_DATFIN "+FG_CONVSQL("CONCATENA")+" VM8.VM8_HORFIN) AS MAXDTHR "
cQuery += "  FROM "+RetSQLName("VM8")+" VM8 "
cQuery += "  JOIN "+RetSQLName("VM7")+" VM7 ON VM7.VM7_FILIAL=VM8.VM8_FILIAL AND VM7.VM7_CODIGO=VM8.VM8_CODVM7 AND VM7.D_E_L_E_T_=' ' "
cQuery += " WHERE VM8.VM8_FILIAL='"+xFilial("VM8")+"' AND VM8.VM8_USRCON <> ' ' AND VM8.D_E_L_E_T_=' ' "
cQuery += " GROUP BY VM7.VM7_CODIGO , VM7.VM7_VOLUME , VM7.VM7_STATUS "
cQuery += " ORDER BY MAXDTHR DESC"
cQuery := oSqlHlp:TOPFunc(cQuery,nQtdReg)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
While !( cQAlAux )->( Eof() )
	cQuery := "SELECT SA2.A2_NOME "
	cQuery += "  FROM "+RetSQLName("VCX")+" VCX "
	cQuery += "  JOIN "+RetSQLName("SA2")+" SA2 ON ( SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD=VCX.VCX_FORNEC AND SA2.A2_LOJA=VCX.VCX_LOJA AND SA2.D_E_L_E_T_=' ' ) "
	cQuery += " WHERE VCX.VCX_FILIAL='"+xFilial("VCX")+"'"
	cQuery += "   AND VCX.VCX_VOLUME='"+( cQAlAux )->( VM7_VOLUME )+"'"
	cQuery += "   AND VCX.D_E_L_E_T_=' '"
	cAux := FM_SQL(cQuery)
	// 4 - Volume Entrada
	aAdd(aVetReg , { "4" ,;
					 ( cQAlAux )->( VM7_CODIGO ) ,;
					 ( cQAlAux )->( MAXDTHR ) ,;
					 "V "+right( ( cQAlAux )->( VM7_VOLUME ),nTamCol-2) ,;
					 ( cQAlAux )->( VM7_STATUS ) ,;
					 right( ( cQAlAux )->( VM7_VOLUME ),nTamCol) ,; // Volume
					 cAux } )
	( cQAlAux )->( DbSkip() )
EndDo
( cQAlAux )->( DbCloseArea() )
//
Return aVetReg

/*/{Protheus.doc} OC1800021_LevantaOficina
Levanta Registros de Oficina

@author Andre Luis Almeida
@since 05/06/2020
@version undefined

@type function
/*/
Static Function OC1800021_LevantaOficina(aVetReg,nQtdReg,nTamCol,nPos)
Local oSqlHlp   := DMS_SqlHelper():New()
Local cQuery    := ""
Local cQAlAux   := "SQLAUX"
//
cQuery := "SELECT VM3.VM3_CODIGO , VM3.VM3_NUMOSV , VM3.VM3_STATUS , SA1.A1_NOME , "
cQuery += "  MAX(VM4.VM4_DATFIN "+FG_CONVSQL("CONCATENA")+" VM4.VM4_HORFIN) AS MAXDTHR "
cQuery += "  FROM "+RetSQLName("VM4")+" VM4 "
cQuery += "  JOIN "+RetSQLName("VM3")+" VM3 ON VM3.VM3_FILIAL=VM4.VM4_FILIAL AND VM3.VM3_CODIGO=VM4.VM4_CODVM3 AND VM3.D_E_L_E_T_=' ' "
cQuery += "  JOIN "+RetSQLName("VO1")+" VO1 ON VO1.VO1_FILIAL = '"+xFilial("VO1")+"' AND VO1.VO1_NUMOSV = VM3.VM3_NUMOSV AND VO1.D_E_L_E_T_ = ' '"
cQuery += "  LEFT JOIN "+RetSQLName("VV1")+" VV1 ON VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1.VV1_CHAINT = VO1.VO1_CHAINT AND VV1.D_E_L_E_T_ = ' '"
cQuery += "  LEFT JOIN "+RetSQLName("SA1")+" SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = VV1.VV1_PROATU AND SA1.A1_LOJA = VV1.VV1_LJPATU AND SA1.D_E_L_E_T_ = ' '"
cQuery += " WHERE VM4.VM4_FILIAL='"+xFilial("VM4")+"' AND VM4.VM4_USRCON <> ' ' AND VM4.D_E_L_E_T_=' ' "
cQuery += " GROUP BY VM3.VM3_CODIGO , VM3.VM3_NUMOSV , VM3.VM3_STATUS , SA1.A1_NOME "
cQuery += " ORDER BY MAXDTHR DESC"
cQuery := oSqlHlp:TOPFunc(cQuery,nQtdReg)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
While !( cQAlAux )->( Eof() )
	// 2 - Oficina
	aAdd(aVetReg,{	 "2" ,;
					 ( cQAlAux )->( VM3_CODIGO ) ,;
					 ( cQAlAux )->( MAXDTHR ) ,;
					 left( IIf(nPos==1,"O ","") + ( cQAlAux )->( VM3_NUMOSV )+"-"+( cQAlAux )->( VM3_CODIGO )+" "+( cQAlAux )->( A1_NOME ),nTamCol) ,;
					 ( cQAlAux )->( VM3_STATUS ) ,;
					 ( cQAlAux )->( VM3_NUMOSV )+"-"+( cQAlAux )->( VM3_CODIGO ) ,;
					 ( cQAlAux )->( A1_NOME ) } )
	( cQAlAux )->( DbSkip() )
EndDo
( cQAlAux )->( DbCloseArea() )
//
Return aVetReg

/*/{Protheus.doc} OC1800031_LevantaOrcamentos
Levanta Registros de Orcamentos

@author Andre Luis Almeida
@since 05/06/2020
@version undefined

@type function
/*/
Static Function OC1800031_LevantaOrcamentos(aVetReg,nQtdReg,nTamCol,nPos)
Local oSqlHlp   := DMS_SqlHelper():New()
Local cQuery    := ""
Local cQAlAux   := "SQLAUX"
//
cQuery := "SELECT VM5.VM5_CODIGO , VM5.VM5_NUMORC , VS1.VS1_TIPORC , VS1.VS1_FILDES , VS1.VS1_NCLIFT , VM5.VM5_STATUS , "
cQuery += "  MAX(VM6.VM6_DATFIN "+FG_CONVSQL("CONCATENA")+" VM6.VM6_HORFIN) AS MAXDTHR "
cQuery += "  FROM "+RetSQLName("VM6")+" VM6 "
cQuery += "  JOIN "+RetSQLName("VM5")+" VM5 ON VM5.VM5_FILIAL=VM6.VM6_FILIAL AND VM5.VM5_CODIGO=VM6.VM6_CODVM5 AND VM5.D_E_L_E_T_=' ' "
cQuery += "  JOIN "+RetSQLName("VS1")+" VS1 ON VS1.VS1_FILIAL = '"+xFilial("VS1")+"' AND VS1.VS1_NUMORC = VM5.VM5_NUMORC AND VS1.D_E_L_E_T_ = ' '"
cQuery += " WHERE VM6.VM6_FILIAL='"+xFilial("VM6")+"' AND VM6.VM6_USRCON <> ' ' AND VM6.D_E_L_E_T_=' ' "
cQuery += " GROUP BY VM5.VM5_CODIGO , VM5.VM5_NUMORC , VS1.VS1_TIPORC , VS1.VS1_FILDES , VS1.VS1_NCLIFT , VM5.VM5_STATUS "
cQuery += " ORDER BY MAXDTHR DESC"
cQuery := oSqlHlp:TOPFunc(cQuery,nQtdReg)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
While !( cQAlAux )->( Eof() )
	// 3 - Orcamentos
	If ( cQAlAux )->( VS1_TIPORC ) == "3" // Transferencia
		aAdd(aVetReg,{	 "3" ,;
						 ( cQAlAux )->( VM5_CODIGO ) ,;
						 ( cQAlAux )->( MAXDTHR ) ,;
						 left( "T"+" "+( cQAlAux )->( VM5_NUMORC )+" "+Alltrim(( cQAlAux )->( VS1_FILDES ))+" "+( cQAlAux )->( VS1_NCLIFT ),nTamCol) ,;
						 ( cQAlAux )->( VM5_STATUS ) ,;
						 STR0012+" "+( cQAlAux )->( VM5_NUMORC ) ,; // Transf.
						 Alltrim(( cQAlAux )->( VS1_FILDES ))+" "+( cQAlAux )->( VS1_NCLIFT ) } )
	Else // Balcao / Oficina
		aAdd(aVetReg,{	 "3" ,;
						 ( cQAlAux )->( VM5_CODIGO ) ,;
						 ( cQAlAux )->( MAXDTHR ) ,;
						 left( IIf(( cQAlAux )->( VS1_TIPORC )=="1","B","O")+" "+( cQAlAux )->( VM5_NUMORC )+" "+( cQAlAux )->( VS1_NCLIFT ),nTamCol) ,;
						 ( cQAlAux )->( VM5_STATUS ) ,;
						 IIf(( cQAlAux )->( VS1_TIPORC )=="1",STR0013,STR0014)+" "+( cQAlAux )->( VM5_NUMORC ) ,; // Balcao / Oficina
						 ( cQAlAux )->( VS1_NCLIFT ) } )
	EndIf
	( cQAlAux )->( DbSkip() )
EndDo
( cQAlAux )->( DbCloseArea() )
//
Return aVetReg

/*/{Protheus.doc} OC1800041_LIMPATELA
Limpa Tela do Coletor/Leitor

@author Andre Luis Almeida
@since 04/06/2020
@version undefined

@type function
/*/
Static Function OC1800041_LIMPATELA(nTamLin,nTamCol) // Limpa Tela
Local ni := 0
VTCLEARBUFFER()
VTClear() // Limpa Tela
For ni := 1 to nTamLin
	@ ni, 00 VTSay repl(" ",nTamCol)
Next
Return

/*/{Protheus.doc} OC1800051_QtdeRegistros
Tela Pergunta a Qtde de Registros Mostrar

@author Andre Luis Almeida
@since 05/06/2020
@version undefined
@return nQtdReg, numerico, Indica a quantidade a apresentar

@type function
/*/
Static Function OC1800051_QtdeRegistros(cTitulo,nQtdReg,nTamCol)
@ 00, 00 VTSay PadR(cTitulo, nTamCol)
@ 01, 00 VTSay repl("-", nTamCol)
@ 03, 00 VTSay PadR(STR0015, nTamCol) // Qtde de Registros?
@ 04, 00 VTGet nQtdReg Picture "@E 999" Valid nQtdReg>=0
VTRead
Return nQtdReg

/*/{Protheus.doc} OC1800061_MostraConferencia
Tela Pergunta a Qtde de Registros Mostrar

@author Andre Luis Almeida
@since 05/06/2020
@version undefined

@type function
/*/
Static Function OC1800061_MostraConferencia(aLinhas,nPos,aVetReg,nTamCol)
Local oSqlHlp := DMS_SqlHelper():New()
Local cTitulo := ""
Local cStatus := STR0016+" " // Status:
Local cOk     := ">"
Local cQuery  := ""
Local cAux1   := ""
Local cAux2   := ""
Local cAux3   := ""
Local cAux4   := ""
Local cAux5   := ""
Local cQAlAux := "SQLAUX"
Local cAlPai  := ""
Local cAlFil  := ""
//
Do Case
	Case aVetReg[nPos,1] == "1" // NF Entrada
		cTitulo := STR0022 // Conf. NF Entradas
		cAlPai := "VM0"
		cAlFil := "VM1"
	Case aVetReg[nPos,1] == "2" // Oficina
		cTitulo := STR0004 // Conf. Oficina
		cAlPai := "VM3"
		cAlFil := "VM4"
	Case aVetReg[nPos,1] == "3" // Orcamento
		cTitulo := STR0005 // Conf. Orcamentos
		cAlPai := "VM5"
		cAlFil := "VM6"
	Case aVetReg[nPos,1] == "4" // Volume Entrada
		cTitulo := STR0023 // Conf. Volume Entradas
		cAlPai := "VM7"
		cAlFil := "VM8"
EndCase
//
Do Case
	Case aVetReg[nPos,5] == "1"
		cStatus += STR0017 // Pendente
	Case aVetReg[nPos,5] == "2"
		cStatus += STR0018 // Parcial
	Case aVetReg[nPos,5] == "3"
		cStatus += STR0019 // Finalizada
	Case aVetReg[nPos,5] == "4"
		cStatus += STR0020 // Aprovada
	Case aVetReg[nPos,5] == "5"
		cStatus += STR0021 // Reprovada
EndCase
cAux1 := substr(aVetReg[nPos,7],            1,nTamCol)
cAux2 := substr(aVetReg[nPos,7],(nTamCol*1)+1,nTamCol)
cAux3 := substr(aVetReg[nPos,7],(nTamCol*2)+1,nTamCol)
//
cQuery := "SELECT "+cAlFil+"_USRCON AS USRCON , "
cQuery += "  MAX("+cAlFil+"_DATFIN "+FG_CONVSQL("CONCATENA")+" "+cAlFil+"_HORFIN) AS MAXDTHR "
cQuery += "  FROM "+RetSQLName(cAlFil)
cQuery += " WHERE "+cAlFil+"_FILIAL='"+xFilial(cAlFil)+"' AND "+cAlFil+"_COD"+cAlPai+"='"+aVetReg[nPos,2]+"' AND D_E_L_E_T_=' ' "
cQuery += " GROUP BY "+cAlFil+"_USRCON "
cQuery += " ORDER BY MAXDTHR DESC"
cQuery := oSqlHlp:TOPFunc(cQuery,3)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
If !( cQAlAux )->( Eof() )
	cAux4 := substr(( cQAlAux )->( MAXDTHR ),7,2)+"/"+substr(( cQAlAux )->( MAXDTHR ),5,2)+"/"+substr(( cQAlAux )->( MAXDTHR ),3,2)+" "+substr(( cQAlAux )->( MAXDTHR ),9,5)
	cAux5 := left(UPPER(UsrRetName(( cQAlAux )->( USRCON ))),nTamCol-1)
EndIf
( cQAlAux )->( DbCloseArea() )
DbSelectArea(cAlPai)
@ 00, 00 VTSay PadR(cTitulo, nTamCol)
@ 01, 00 VTSay PadR(aVetReg[nPos,6],nTamCol)
@ 02, 00 VTSay PadR(cStatus,nTamCol)
@ 03, 00 VTSay PadR(cAux1,nTamCol)
@ 04, 00 VTSay PadR(cAux2,nTamCol)
@ 05, 00 VTSay PadR(cAux3,nTamCol)
@ 06, 00 VTSay PadR(cAux4,nTamCol)
@ 07, 00 VTSay PadR(cAux5,nTamCol-1)
@ 07, (nTamCol-1) VTGet cOk Picture "@!"
VTRead
Return