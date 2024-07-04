#INCLUDE "FIVEWIN.CH"
#INCLUDE "APVT100.CH"
#INCLUDE "OFIC090.CH"

/*/{Protheus.doc} OFIC090
Coletor/Leitor VT100 - Painel de Novas Conferencias - Saida / Entrada

@author Andre Luis Almeida
@since 30/09/2019
@version undefined

@type function
/*/
Function OFIC090()
Local nTamCol   := VTMaxCol() // Qtde maxima de Colunas no Display do Coletor
Local nTamLin   := VTMaxRow() // Qtde maxima de Linhas no Display do Coletor
Local nQtd      := 0
Local cFaseConf := Alltrim(GetNewPar("MV_MIL0095","4")) // Saida - Orcamento - Fase de Conferencia
Local lPrimVez  := .t.
Local lENTNOVAS := .f.
Local lOrcNOVOS := .f.
Local lOSsNOVAS := .f.
Local nPosMenu  := 0
Local aLinhas   := {}
Local aSize     := {nTamCol}
Local aColunas  := { STR0001 } // Pesquisar
Local cQryENT   := ""
Local cQryOrc   := ""
Local cQryOSs   := ""
Private aNFEs   := {}
Private aOrcs   := {}
Private aOSs    := {}
//
aAdd(aLinhas,{ STR0002 }) // Todas Conferencias
aAdd(aLinhas,{ STR0009 }) // Conf. Entradas
aAdd(aLinhas,{ STR0010 }) // Conf. Orcamentos
aAdd(aLinhas,{ STR0011 }) // Conf. Oficina
//
nPosMenu := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,1) // Lista de Opcoes
OC0900041_LIMPATELA(nTamLin,nTamCol)
//
If nPosMenu == 1 .or. nPosMenu == 2
	cQryENT := "SELECT DISTINCT SF1.R_E_C_N_O_ AS RECSF1 "
	cQryENT += "  FROM "+RetSQLName("SF1")+" SF1 "
	cQryENT += " WHERE SF1.F1_FILIAL  = '"+xFilial("SF1")+"'"
	cQryENT += "   AND SF1.F1_DTDIGIT >= '"+dtos(dDatabase-7)+"'"
	cQryENT += "   AND SF1.F1_STATUS  = ' '"
	cQryENT += "   AND SF1.D_E_L_E_T_ = ' '"
	cQryENT += "   AND EXISTS ( "
	cQryENT += 				" SELECT SD1.D1_DOC "
	cQryENT += 				" FROM " + RetSqlName("SD1") + " SD1 "
	cQryENT += 				" LEFT JOIN " + RetSqlName("SF4") + " SF4 ON ( SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_=' ' )"
	cQryENT += 				" WHERE SD1.D1_FILIAL ='" + xFilial("SD1") + "' "
	cQryENT += 				" AND SD1.D1_DOC = SF1.F1_DOC "
	cQryENT += 				" AND SD1.D1_SERIE = SF1.F1_SERIE "
	cQryENT += 				" AND SD1.D1_FORNECE = SF1.F1_FORNECE "
	cQryENT += 				" AND SD1.D1_LOJA = SF1.F1_LOJA "
	cQryENT += 				" AND ( SD1.D1_TES = ' ' OR SF4.F4_ESTOQUE='S' ) "
	cQryENT += 				" AND SD1.D_E_L_E_T_ = ' '"
	If ExistBlock("OMSQLSD1")
		cQryENT += ExecBlock("OMSQLSD1",.f.,.f.,{"3"}) // Ponto de Entrada para completar o SQL de Levantamento das NFs de Entrada a Conferir
	EndIf
	cQryENT += ") "
EndIf
//
If nPosMenu == 1 .or. nPosMenu == 3
	cQryOrc := "SELECT VS1.VS1_FILIAL , VS1.VS1_NUMORC "
	cQryOrc += "  FROM "+RetSQLName("VS1")+" VS1 "
	cQryOrc += "  LEFT JOIN "+RetSqlName("VM5")+" VM5 "
	cQryOrc += "       ON  VM5.VM5_FILIAL='"+xFilial("VM5")+"'"
	cQryOrc += "       AND VM5.VM5_NUMORC=VS1.VS1_NUMORC"
	cQryOrc += "       AND VM5.D_E_L_E_T_=' '"
	cQryOrc += " WHERE VS1.VS1_FILIAL = '"+xFilial("VS1")+"'"
	cQryOrc += "   AND VS1.VS1_STATUS = '"+cFaseConf+"'"
	cQryOrc += "   AND ("
	cQryOrc += "             VS1.VS1_STARES IN ('1','2')"
	cQryOrc += "          OR ( VS1.VS1_STARES NOT IN ('1','2') AND VS1.VS1_DATVAL >= '"+dtos(dDatabase)+"' )"
	cQryOrc += "          OR VS1.VS1_TIPORC = '3'"
	cQryOrc += "       )" 
	cQryOrc += "   AND VS1.D_E_L_E_T_ = ' '"
	cQryOrc += "   AND ( VM5.VM5_STATUS IS NULL OR VM5.VM5_STATUS IN ('1','2') ) " // Nao encontrado VM5 ou Status igual a Pendente ou Conferido Parcialmente
EndIf
//
If nPosMenu == 1 .or. nPosMenu == 4
	cQryOSs := "SELECT VM3_CODIGO "
	cQryOSs += "  FROM "+RetSQLName("VM3")
	cQryOSs += " WHERE VM3_FILIAL = '"+xFilial("VM3")+"'"
	cQryOSs += "   AND VM3_STATUS IN ('1','2')"
	cQryOSs += "   AND D_E_L_E_T_ = ' '"
EndIf
//
While nPosMenu > 0
	nQtd++
	If nQtd == 1
		cMsg := ""
		If !Empty(cQryENT)
			lENTNOVAS := OC0900021_TemNovaEntrada(cQryENT,lPrimVez) // ENTRADAS - NFs Entrada + Volumes Entrada
		EndIf
		If !Empty(cQryOrc)
			lOrcNOVOS := OC0900011_TemNovoOrcamento(cQryOrc,lPrimVez) // SAIDAS - Orcamentos
		EndIf
		If !Empty(cQryOSs)
			lOSsNOVAS := OC0900031_TemNovaOS(cQryOSs,lPrimVez) // SAIDAS - Oficina OSs
		EndIf
	ElseIf nQtd == 4 .or. nQtd == 7 .or. nQtd == 10 .or. nQtd == 13
		cMsg := ""
	ElseIf nQtd == 15
		nQtd := 0
	EndIf
	cMsg += "."
	If lENTNOVAS // Novas Entradas
		If VtAlert(STR0013,STR0005,,1000,IIf(cMsg==".",2,0)) == 27 // 27 = ESC // Acesse a rotina de Conferencia de Entrada (NF Entrada ou Volume Entrada) / Novas Conferencias
			Exit
		EndIf
	EndIf
	If lOrcNOVOS // Novos Orcamentos
		If VtAlert(STR0007,STR0005,,1000,IIf(cMsg==".",2,0)) == 27 // 27 = ESC // Acesse a rotina de Conferencia de Saida (Orcamentos) / Novas Conferencias
			Exit
		EndIf
	EndIf
	If lOSsNOVAS // Novas OSs
		If VtAlert(STR0012,STR0005,,1000,IIf(cMsg==".",2,0)) == 27 // 27 = ESC // Acesse a rotina de Conferencia de OS (Oficina) / Novas Conferencias
			Exit
		EndIf
	EndIf
	If !lENTNOVAS .and. !lOrcNOVOS .and. !lOSsNOVAS
		If VtAlert(CHR(13)+CHR(10)+STR0006+cMsg,STR0005,,1000,0) == 27 // 27 = ESC // Verificando / Novas Conferencias
			Exit
		EndIf
	EndIf
	lPrimVez := .f.
EndDo
Return

/*/{Protheus.doc} OC0900011_TemNovoOrcamento
Levanta Saidas ( VS1 - Orcamentos )

@author Andre Luis Almeida
@since 30/09/2019
@version undefined

@type function
/*/
Static Function OC0900011_TemNovoOrcamento(cQuery,lPrimVez)
Local nCntFor := 0
Local cQAlAux := "SQLAUX"
Local aTemp   := {}
Local lRet    := .f.
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
While !( cQAlAux )->( Eof() )
	aAdd(aTemp , ( cQAlAux )->( VS1_FILIAL ) + ( cQAlAux )->( VS1_NUMORC ) )
	( cQAlAux )->( DbSkip() )
EndDo
( cQAlAux )->( DbCloseArea() )
If lPrimVez
	lRet := .f.
Else
	For nCntFor := 1 to len(aTemp)
		If ascan(aOrcs,aTemp[nCntFor]) == 0
			lRet := .t.
			Exit
		EndIf
	Next
EndIf
aOrcs := aClone(aTemp)
Return lRet

/*/{Protheus.doc} OC0900021_TemNovaEntrada
Levanta Entradas ( NFs Entrada / Volumes Entrada )

@author Andre Luis Almeida
@since 30/09/2019
@version undefined

@type function
/*/
Static Function OC0900021_TemNovaEntrada(cQuery,lPrimVez)
Local nCntFor := 0
Local cQAlAux := "SQLAUX"
Local aTemp   := {}
Local lRet    := .f.
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
While !( cQAlAux )->( Eof() )
	aAdd(aTemp , ( cQAlAux )->( RECSF1 ) )
	( cQAlAux )->( DbSkip() )
EndDo
( cQAlAux )->( DbCloseArea() )
If lPrimVez
	lRet := .f.
Else
	For nCntFor := 1 to len(aTemp)
		If ascan(aNFEs,aTemp[nCntFor]) == 0
			lRet := .t.
			Exit
		EndIf
	Next
EndIf
aNFEs := aClone(aTemp)
Return lRet

/*/{Protheus.doc} OC0900031_TemNovaOS
Levanta Saidas OSs ( VM3 - Oficina OS )

@author Andre Luis Almeida
@since 12/11/2019
@version undefined

@type function
/*/
Static Function OC0900031_TemNovaOS(cQuery,lPrimVez)
Local nCntFor := 0
Local cQAlAux := "SQLAUX"
Local aTemp   := {}
Local lRet    := .f.
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
While !( cQAlAux )->( Eof() )
	aAdd(aTemp , ( cQAlAux )->( VM3_CODIGO ) )
	( cQAlAux )->( DbSkip() )
EndDo
( cQAlAux )->( DbCloseArea() )
If lPrimVez
	lRet := .f.
Else
	For nCntFor := 1 to len(aTemp)
		If ascan(aOSs,aTemp[nCntFor]) == 0
			lRet := .t.
			Exit
		EndIf
	Next
EndIf
aOSs := aClone(aTemp)
Return lRet

/*/{Protheus.doc} OC0900041_LIMPATELA
Limpa Tela do Coletor/Leitor

@author Andre Luis Almeida
@since 01/10/2019
@version undefined

@type function
/*/
Static Function OC0900041_LIMPATELA(nTamLin,nTamCol) // Limpa Tela
Local ni := 0
VTCLEARBUFFER()
VTClear() // Limpa Tela
For ni := 1 to nTamLin
	@ ni, 00 VTSay repl(" ",nTamCol)
Next
Return