#Include "PROTHEUS.CH"
#INCLUDE "OFIC240.CH"

/*/{Protheus.doc} OFIC240
Consulta Tempo Total das Conferencias

@author Andre Luis Almeida
@since 11/11/2021
/*/
Function OFIC240()
//
Local aSize      := FWGetDialogSize( oMainWnd )
Local aTpConf    := {"","1="+STR0002,"2="+STR0003,"3="+STR0004,"4="+STR0005} // NF de Entrada / Oficina / Orçamentos / Volume de Entrada
Local nLin       := 0
Local nCol       := 0
Local oFilHelp   := DMS_FilialHelper():New()
Local aBotEnch   := {}
//
Private aVetCon  := {}
Private aVetSta  := {}
Private aVetObs  := {}
Private cTpConf  := ""
Private aTitCon  := OC2400021_TitulosCOLUNAS(1) // Colunas das Conferencias
Private aTitSta  := OC2400021_TitulosCOLUNAS(2) // Colunas dos Status da Conferencia
Private aTitObs  := OC2400021_TitulosCOLUNAS(3) // Colunas da Observacao da Conferencia
Private dDtIni   := dDataBase-day(dDataBase)+1
Private dDtFin   := dDataBase
Private aFilPerm := oFilHelp:GetAllFilPermis(.f.)
Private cCadastro := STR0001 // Consulta Tempo Total das Conferências
Private cFilUsuario := cFilAnt

If len(aFilPerm) > 1
	aAdd(aFilPerm,"") // Adicionar um registro em branco para trazer todas as Filiais juntas
	aSort(aFilPerm)
EndIf

AADD(aBotEnch, {"ANALITIC" ,{|| OC2400081_TempoMedio() }, STR0030 } ) // Tempo Médio referente ao Filtro

OC2400031_LEVANTA(.f.)

DEFINE MSDIALOG oDlgOFIC240 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] TITLE STR0001 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta Tempo Total das Conferências

	oTPanDOW := TPanel():New(0,0,"",oDlgOFIC240,NIL,.T.,.F.,NIL,NIL,100,(oDlgOFIC240:nClientHeight/4)-25,.T.,.F.)
	oTPanDOW:Align := CONTROL_ALIGN_BOTTOM

	oTPanTOP := TPanel():New(0,0,"",oDlgOFIC240,NIL,.T.,.F.,NIL,NIL,100,(oDlgOFIC240:nClientHeight/4)-25,.T.,.F.)
	oTPanTOP:Align := CONTROL_ALIGN_BOTTOM

	oScrollFilt := TScrollBox():New( oTPanTOP , 0, 0, 25, 25, .t. /* lVertical */ , .f. /* lHorizontal */ , .f. /* lBorder */ )
	oScrollFilt:Align := CONTROL_ALIGN_TOP

	oTPanESQ := TPanel():New(0,0,"",oTPanDOW,NIL,.T.,.F.,NIL,NIL,(oDlgOFIC240:nClientWidth/3)-1,(oDlgOFIC240:nClientHeight/4)-25,.T.,.F.)
	oTPanESQ:Align := CONTROL_ALIGN_LEFT

	oTPanDIR := TPanel():New(0,0,"",oTPanDOW,NIL,.T.,.F.,NIL,NIL,(oDlgOFIC240:nClientWidth/6)-1,(oDlgOFIC240:nClientHeight/4)-25,.T.,.F.)
	oTPanDIR:Align := CONTROL_ALIGN_RIGHT

	nLin := 2
	nCol := 5
	oSayTip := tSay():New( nLin  , nCol, {|| STR0006 } , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE, 080, 020) // Tipo de Conferência de Peças
	oCmbTip := TComboBox():New(nLin+8, nCol,{|u|if(PCount()>0,cTpConf:=u,cTpConf)},aTpConf,80,08,oScrollFilt,,{||.t.},,,,.T.,,,,{|| .t. },,,,,'cTpConf')
	nCol += 85
	oSayDtI := tSay():New( nLin  , nCol, {|| STR0007 } , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE, 080, 020) // Data Inicial
	oGetDtI := TGet():New( nLin+8, nCol, { | u | If( PCount() == 0, dDtIni , dDtIni := u ) },oScrollFilt,060, 008, "@D" ,{ || .t. },,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtIni",,,,)
	nCol += 65
	oSayDtF := tSay():New( nLin  , nCol, {|| STR0008 } , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE, 080, 020) // Data Final
	oGetDtF := TGet():New( nLin+8, nCol, { | u | If( PCount() == 0, dDtFin , dDtFin := u ) },oScrollFilt,060, 008, "@D" ,{ || .t. },,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtFin",,,,)
	nCol += 65
	oSayFil := tSay():New( nLin  , nCol, {|| STR0011 } , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE, 080, 020) // Filial
	oCmbFil := TComboBox():New(nLin+8, nCol,{ | u | If( PCount() == 0, cFilUsuario , cFilUsuario := u )},aFilPerm,70,08,oScrollFilt,,{||.t.},,,,.T.,,,,{|| .t. },,,,,'cFilUsuario')
	nCol += 75
	oButFil := TButton():New( nLin+6, nCol, STR0013 ,oScrollFilt,{|| OC2400031_LEVANTA(.t.) }, 40,12,,,.F.,.T.,.F.,,.F.,{ || !Empty(cTpConf) },,.F. ) // Filtrar

	oBrwCon := FWBrowse():New()
	oBrwCon:SetOwner(oTPanTOP)
	oBrwCon:SetDescription(STR0001) // Consulta Tempo Total das Conferências
	oBrwCon:SetProfileID("T")
	oBrwCon:SetDataArray()
	oBrwCon:SetColumns(OC2400011_MontaCol(1,aTitCon))
	oBrwCon:SetArray(aVetCon)
	oBrwCon:Activate() // Ativação do Browse
	oBrwCon:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oBrwSta := FWBrowse():New()
	oBrwSta:SetOwner(oTPanESQ)
	oBrwSta:SetDescription(STR0025) // Status da Conferência selecionada
	oBrwSta:SetProfileID("T")
	oBrwSta:SetDataArray()
	oBrwSta:SetColumns(OC2400011_MontaCol(2,aTitSta))
	oBrwSta:SetArray(aVetSta)
	oBrwSta:Activate() // Ativação do Browse
	oBrwSta:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oBrwObs := FWBrowse():New()
	oBrwObs:SetOwner(oTPanDIR)
	oBrwObs:SetDescription(STR0026) // Observações da Conferência selecionada
	oBrwObs:SetProfileID("T")
	oBrwObs:SetDataArray()
	oBrwObs:SetColumns(OC2400011_MontaCol(3,aTitObs))
	oBrwObs:SetArray(aVetObs)
	oBrwObs:Activate() // Ativação do Browse
	oBrwObs:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// Carregar o Change no Final da Montagem da Tela
	oBrwCon:SetChange( { || OC2400061_Levanta_Status_Conferencia( oBrwCon:nAt ) } )
	//

ACTIVATE MSDIALOG oDlgOFIC240 ON INIT EnchoiceBar(oDlgOFIC240,{ || oDlgOFIC240:End() }, { || oDlgOFIC240:End() },,aBotEnch)

Return()

/*/{Protheus.doc} OC2400011_MontaCol
Adicao das Colunas do Browse

@author Andre Luis Almeida
@since 11/11/2021
/*/
Static Function OC2400011_MontaCol(nTp,aHeader)
Local aColunas, oColuna
Local cSetData
Local nHeader := 0
Default aHeader := {}
aColunas := {}
For nHeader := 1 To Len(aHeader)
	// Instancia a Classe
	oColuna := FWBrwColumn():New()
	// Definições Básicas do Objeto
	oColuna:SetAlign(If(aHeader[nHeader][6] == "R", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT))
	oColuna:SetEdit(.F.)
	// Definições do Dado apresentado
	oColuna:SetSize(aHeader[nHeader][3])
	oColuna:SetTitle(aHeader[nHeader][1])
	oColuna:SetType(aHeader[nHeader][2])
	oColuna:SetPicture(aHeader[nHeader][4])
	//
	If nTp == 1 // Conferencia
		cSetData := "{|| oBrwCon:Data():GetArray()[oBrwCon:AT()][" + cValToChar(aHeader[nHeader][5]) + "] }"
	ElseIf nTp == 2 // Status
		cSetData := "{|| oBrwSta:Data():GetArray()[oBrwSta:AT()][" + cValToChar(aHeader[nHeader][5]) + "] }"
	ElseIf nTp == 3 // Observacao
		cSetData := "{|| oBrwObs:Data():GetArray()[oBrwObs:AT()][" + cValToChar(aHeader[nHeader][5]) + "] }"
	EndIf
	oColuna:SetData(&(cSetData))
	//
	aAdd(aColunas, oColuna)
Next nHeader
Return aColunas

/*/{Protheus.doc} OC2400021_TitulosCOLUNAS
Retorna Titulos/Tipos/Tamanhos/Mascara das Colunas do Browse

@author Andre Luis Almeida
@since 11/11/2021
/*/
Static Function OC2400021_TitulosCOLUNAS(nTp)
Local aRetCol := {}
Local nCol    := 0
Do Case
	Case nTp == 1 // Conferencias
		aAdd(aRetCol, {STR0011,"C", 10,"@!"             , ++nCol,"L"}) // Filial
		aAdd(aRetCol, {""     ,"C", 15,""               , ++nCol,"L"})
		aAdd(aRetCol, {""     ,"C", 15,""               , ++nCol,"L"})
		aAdd(aRetCol, {STR0007,"D", 05,"@D"             , ++nCol,"R"}) // Data Inicial
		aAdd(aRetCol, {STR0009,"C", 05,"@R 99:99:99"    , ++nCol,"R"}) // Hora Inicial
		aAdd(aRetCol, {STR0008,"D", 05,"@D"             , ++nCol,"R"}) // Data Final
		aAdd(aRetCol, {STR0010,"C", 05,"@R 99:99:99"    , ++nCol,"R"}) // Hora Final
		aAdd(aRetCol, {STR0012,"C", 05,"@!"             , ++nCol,"R"}) // Tempo Total
	Case nTp == 2 // Status
		aAdd(aRetCol, {""     ,"C", 15,""               , ++nCol,"L"})
		aAdd(aRetCol, {STR0007,"D", 05,"@D"             , ++nCol,"R"}) // Data Inicial
		aAdd(aRetCol, {STR0009,"C", 05,"@R 99:99:99"    , ++nCol,"R"}) // Hora Inicial
		aAdd(aRetCol, {STR0008,"D", 05,"@D"             , ++nCol,"R"}) // Data Final
		aAdd(aRetCol, {STR0010,"C", 05,"@R 99:99:99"    , ++nCol,"R"}) // Hora Final
		aAdd(aRetCol, {STR0012,"C", 05,"@!"             , ++nCol,"R"}) // Tempo Total
		aAdd(aRetCol, {"%"    ,"C", 05,"@!"             , ++nCol,"R"}) // %
	Case nTp == 3 // Observacao
		aAdd(aRetCol, {""     ,"C", 15,""               , ++nCol,"L"})
		aAdd(aRetCol, {""     ,"N", 05,"@EZ 999,999,999", ++nCol,"R"})
EndCase
Return aRetCol

/*/{Protheus.doc} OC2400031_LEVANTA
Levanta Dados para incluir registros no Browse 

@author Andre Luis Almeida
@since 11/11/2021
/*/
Static Function OC2400031_LEVANTA(lRefresh)
Local cQuery   := ""
Local cQAlSQL  := "SQLCONF"
Local nPos     := 0
Local nCntFil  := 0
Local cTabP    := "" // Tabela Principal
Local cCpos    := ""
Local nQtdColunas := len(aTitCon)+1 // Colunas + RecNo
Local cFilBkp  := cFilAnt
Local cNamTab  := ""
Local cNamSA2  := ""
Local cNamVS1  := ""
Local cNamSA1  := ""
Local cNamVCX  := ""
Local cConcat  := FG_CONVSQL("CONCATENA")
//
aVetCon := {}
//
Do Case 
	Case cTpConf == "1" // Conferencia de NF de Entrada
		cTabP := "VN4"
		cCpos := "'"+STR0014+" '"+cConcat+" VN4.VN4_DOC "+cConcat+"' - '"+cConcat+" VN4.VN4_SERIE AS COL1 , " // NF:
		cCpos += "VN4.VN4_FORNEC "+cConcat+"'-'"+cConcat+" VN4.VN4_LOJA "+cConcat+"' '"+cConcat+" SA2.A2_NOME AS COL2 , "
		cCpos += "VN4.VN4_DATINI AS DATINI , VN4.VN4_HORINI AS HORINI , VN4.VN4_DATFIN AS DATFIN , VN4.VN4_HORFIN AS HORFIN , VN4.R_E_C_N_O_ AS REC "
	Case cTpConf == "2" // Conferencia Oficina
		cTabP := "VN6"
		cCpos := "'"+STR0015+" '"+cConcat+" VN6.VN6_CODSOL AS COL1 , " // Solicitação
		cCpos += "'"+STR0027+" '"+cConcat+" VN6.VN6_NUMOSV AS COL2 , " // OS:
		cCpos += "VN6.VN6_DATINI AS DATINI , VN6.VN6_HORINI AS HORINI , VN6.VN6_DATFIN AS DATFIN , VN6.VN6_HORFIN AS HORFIN , VN6.R_E_C_N_O_ AS REC "
	Case cTpConf == "3" // Conferencia de Orcamentos
		cTabP := "VN5"
		cCpos := "'"+STR0016+" '"+cConcat+" VN5.VN5_NUMORC AS COL1 , " // Orçamento:
		cCpos += "SA1.A1_COD "+cConcat+"'-'"+cConcat+" SA1.A1_LOJA "+cConcat+"' '"+cConcat+" SA1.A1_NOME AS COL2 , "
		cCpos += "VN5.VN5_DATINI AS DATINI , VN5.VN5_HORINI AS HORINI , VN5.VN5_DATFIN AS DATFIN , VN5.VN5_HORFIN AS HORFIN , VN5.R_E_C_N_O_ AS REC "
	Case cTpConf == "4" // Conferencia de Volume de Entrada
		cTabP := "VN7"
		cCpos := "'"+STR0017+" '"+cConcat+" VN7.VN7_VOLUME AS COL1 , " // Volume:
		cCpos += "SA2.A2_COD "+cConcat+"'-'"+cConcat+" SA2.A2_LOJA "+cConcat+"' '"+cConcat+" SA2.A2_NOME AS COL2 , "
		cCpos += "VN7.VN7_DATINI AS DATINI , VN7.VN7_HORINI AS HORINI , VN7.VN7_DATFIN AS DATFIN , VN7.VN7_HORFIN AS HORFIN , VN7.R_E_C_N_O_ AS REC "
EndCase
//
If !Empty(cTabP)
	//
	cNamTab := RetSQLName(cTabP)
	cNamSA2 := RetSQLName("SA2")
	cNamVS1 := RetSQLName("VS1")
	cNamSA1 := RetSQLName("SA1")
	cNamVCX := RetSQLName("VCX")
	//
	For nCntFil := 1 to len(aFilPerm)
		//
		If Empty(aFilPerm[nCntFil])
			Loop // Pula linha em branco do Vetor de Filiais
		EndIf
		//
		If Empty(cFilUsuario)
			cFilAnt := aFilPerm[nCntFil]
		Else
			cFilAnt := cFilUsuario
		EndIf
		//
		cQuery := "SELECT DISTINCT "+cCpos
		cQuery += "  FROM "+cNamTab+" "+cTabP+" "
		Do Case 
			Case cTpConf == "1" // Conferencia de NF de Entrada
				cQuery += "  JOIN "+cNamSA2+" SA2 "
				cQuery += "    ON SA2.A2_FILIAL = '"+xFilial("SA2")+"'"
				cQuery += "   AND SA2.A2_COD = VN4.VN4_FORNEC"
				cQuery += "   AND SA2.A2_LOJA = VN4.VN4_LOJA"
				cQuery += "   AND SA2.D_E_L_E_T_ = ' '"
			Case cTpConf == "3" // Conferencia de Orcamentos
				cQuery += "  JOIN "+cNamVS1+" VS1 "
				cQuery += "    ON VS1.VS1_FILIAL = '"+xFilial("VS1")+"'"
				cQuery += "   AND VS1.VS1_NUMORC = VN5.VN5_NUMORC"
				cQuery += "   AND VS1.D_E_L_E_T_ = ' '"
				cQuery += "  JOIN "+cNamSA1+" SA1 "
				cQuery += "    ON SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
				cQuery += "   AND SA1.A1_COD = VS1.VS1_CLIFAT"
				cQuery += "   AND SA1.A1_LOJA = VS1.VS1_LOJA"
				cQuery += "   AND SA1.D_E_L_E_T_ = ' '"
			Case cTpConf == "4" // Conferencia de Volume de Entrada
				cQuery += "  JOIN "+cNamVCX+" VCX "
				cQuery += "    ON VCX.VCX_FILIAL = '"+xFilial("VCX")+"'"
				cQuery += "   AND VCX.VCX_VOLUME = VN7.VN7_VOLUME"
				cQuery += "   AND VCX.D_E_L_E_T_ = ' '"
				cQuery += "  JOIN "+cNamSA2+" SA2 "
				cQuery += "    ON SA2.A2_FILIAL = '"+xFilial("SA2")+"'"
				cQuery += "   AND SA2.A2_COD = VCX.VCX_FORNEC"
				cQuery += "   AND SA2.A2_LOJA = VCX.VCX_LOJA"
				cQuery += "   AND SA2.D_E_L_E_T_ = ' '"
		EndCase			
		cQuery += " WHERE "+cTabP+"."+cTabP+"_FILIAL = '"+xFilial(cTabP)+"'"
		cQuery += "   AND "+cTabP+"."+cTabP+"_DATINI >= '"+dtos(dDtIni)+"'"
		cQuery += "   AND "+cTabP+"."+cTabP+"_DATFIN <= '"+dtos(dDtFin)+"'"
		cQuery += "   AND "+cTabP+"."+cTabP+"_DATFIN <> ' '"
		cQuery += "   AND "+cTabP+".D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY "+cTabP+"."+cTabP+"_DATINI , "+cTabP+"."+cTabP+"_HORINI "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
		While !(cQAlSQL)->(Eof())
			aAdd(aVetCon,array(nQtdColunas))
			nPos := len(aVetCon)
			aVetCon[ nPos , 1 ] := cFilAnt
			aVetCon[ nPos , 2 ] := (cQAlSQL)->( COL1 ) // Coluna 1 de descrição
			aVetCon[ nPos , 3 ] := (cQAlSQL)->( COL2 ) // Coluna 2 de descrição
			aVetCon[ nPos , 4 ] := stod((cQAlSQL)->( DATINI ))
			aVetCon[ nPos , 5 ] := (cQAlSQL)->( HORINI )
			aVetCon[ nPos , 6 ] := stod((cQAlSQL)->( DATFIN ))
			aVetCon[ nPos , 7 ] := (cQAlSQL)->( HORFIN )
			aVetCon[ nPos , 8 ] := OC2400041_SOMAHORA( (cQAlSQL)->( DATINI ) , (cQAlSQL)->( DATFIN ) , (cQAlSQL)->( HORINI ) , (cQAlSQL)->( HORFIN ) )
			aVetCon[ nPos , 9 ] := (cQAlSQL)->( REC )
			(cQAlSQL)->(dbSkip())
		EndDo
		(cQAlSQL)->(dbCloseArea())
		//
		If !Empty(cFilUsuario)
			Exit
		EndIf
		//
	Next
	//
	cFilAnt := cFilBkp
	//
EndIf
//
OC2400091_CriaLinhaEmBranco()
//
If lRefresh
	oBrwCon:nAt := 1
	oBrwCon:SetArray(aVetCon)
	oBrwCon:Refresh()
	oBrwCon:GoTop()
	OC2400061_Levanta_Status_Conferencia( oBrwCon:nAt )
EndIf

Return

/*/{Protheus.doc} OC2400041_SOMAHORA
Calculo -> Soma de Horas

@author Andre Luis Almeida
@since 11/11/2021
/*/
Static Function OC2400041_SOMAHORA( sDtIni , sDtFin , cHrIni , cHrFin )
Local cTempo := ""
Local nDias  := stod(sDtFin) - stod(sDtIni)
Local aTam1  := OC2400051_TAMHRMNSG(cHrIni)
Local aTam2  := OC2400051_TAMHRMNSG(cHrFin)
Local nHras  := val(substr(cHrFin,aTam2[1,1],aTam2[1,2])) - val(substr(cHrIni,aTam1[1,1],aTam1[1,2]))
Local nMins  := val(substr(cHrFin,aTam2[2,1],aTam2[2,2])) - val(substr(cHrIni,aTam1[2,1],aTam1[2,2]))
Local nSegs  := val(substr(cHrFin,aTam2[3,1],aTam2[3,2])) - val(substr(cHrIni,aTam1[3,1],aTam1[3,2]))
While nSegs < 0
	nMins--
	nSegs += 60
EndDo
While nMins < 0
	nHras--
	nMins += 60
EndDo
While nHras < 0
	nDias--
	nHras += 24
EndDo
nHras += (nDias*24)
If nHras < 100
	cTempo := strzero(nHras,2)
ElseIf nHras < 1000
	cTempo := strzero(nHras,3)
ElseIf nHras < 10000
	cTempo := strzero(nHras,4)
EndIf
cTempo += ":"+strzero(nMins,2)+":"+strzero(nSegs,2)
Return cTempo

/*/{Protheus.doc} OC2400051_TAMHRMNSG
Retorna o tamanho do formato das Horas:Minutos:Segundos

@author Andre Luis Almeida
@since 11/11/2021
/*/
Static Function OC2400051_TAMHRMNSG(cString)
Local aRetTam := {}
Local nPos    := 0
Local nCntFor := 0
aAdd(aRetTam,{nPos+1,0})
For nCntFor := 1 to 2 // Horas : Minutos : Segundos
	nPos := At(":",cString)
	If nCntFor == 1 // Tamanho da Hora pode variar
		aRetTam[len(aRetTam),2] := nPos - aRetTam[len(aRetTam),1]
	EndIf
	aAdd(aRetTam,{nPos+1,2})
	cString := stuff(cString,nPos,1,"x")
Next
Return aRetTam

/*/{Protheus.doc} OC2400061_Levanta_Status_Conferencia
Levanta os Status da Conferencia posicionada

@author Andre Luis Almeida
@since 11/11/2021
/*/
Static Function OC2400061_Levanta_Status_Conferencia( nLinha )
	Local cQuery  := ""
	Local cQAlSQL := "VM2SQL"
	Local nPos    := 0
	Local cStatus := ""
	Local cFilBkp := cFilAnt
	Local cCodVM2 := ""
	Local cTabC   := "" // Tabela Cabeçalho
	Local cTabI   := "" // Tabela Itens
	Local dDatIni := ctod("")
	Local cHorIni := ""
	Local aTam    := 0
	Local nTmpTot := 0
	Local nTmpLin := 0
	//
	aVetSta := {}
	aVetObs := {}
	//
	If len(aVetCon) > 0 .and. aVetCon[ nLinha , 9 ] > 0
		//
		cFilAnt := aVetCon[ nLinha , 1 ]
		//
		aAdd(aVetSta,array(7))
		nPos := len(aVetSta)
		aVetSta[ nPos , 1 ] := STR0018 // Tempo Total da Conferência
		aVetSta[ nPos , 2 ] := aVetCon[ nLinha , 4 ]
		aVetSta[ nPos , 3 ] := aVetCon[ nLinha , 5 ]
		aVetSta[ nPos , 4 ] := aVetCon[ nLinha , 6 ]
		aVetSta[ nPos , 5 ] := aVetCon[ nLinha , 7 ]
		aVetSta[ nPos , 6 ] := aVetCon[ nLinha , 8 ]
		aVetSta[ nPos , 7 ] := "100,0 %"
		//
		dDatIni := aVetCon[ nLinha , 4 ]
		cHorIni := aVetCon[ nLinha , 5 ]
		//
		aTam := OC2400051_TAMHRMNSG(aVetCon[ nLinha , 8 ])
		nTmpTot := ( ( val( substr( aVetCon[ nLinha , 8 ],aTam[1,1],aTam[1,2]) ) * 60 ) * 60 ) // Horas em Segundos - Total
		nTmpTot += ( ( val( substr( aVetCon[ nLinha , 8 ],aTam[2,1],aTam[2,2]) ) * 60 )      ) // Minutos em Segundos - Total
		nTmpTot += ( ( val( substr( aVetCon[ nLinha , 8 ],aTam[3,1],aTam[3,2]) )      )      ) // Minutos em Segundos - Total
		//
		cQuery := "SELECT VM2.VM2_STATUS , VM2.VM2_DATSTA , VM2.VM2_HORSTA , VM2.VM2_CODIGO "
		Do Case 
			Case cTpConf == "1" // Conferencia de NF de Entrada
				cTabC := "VM0"
				cTabI := "VM1"
				cQuery += "  FROM "+RetSQLName("VN4")+" VN4"
				cQuery += "  JOIN "+RetSQLName("VM0")+" VM0"
				cQuery += "    ON VM0.VM0_FILIAL = '"+xFilial("VM0")+"'"
				cQuery += "   AND VM0.VM0_DOC = VN4.VN4_DOC"
				cQuery += "   AND VM0.VM0_SERIE = VN4.VN4_SERIE"
				cQuery += "   AND VM0.VM0_FORNEC = VN4.VN4_FORNEC"
				cQuery += "   AND VM0.VM0_LOJA = VN4.VN4_LOJA"
				cQuery += "   AND VM0.D_E_L_E_T_ = ' '"
				cQuery += "  JOIN "+RetSQLName("VM2")+" VM2"
				cQuery += "    ON VM2.VM2_FILIAL = '"+xFilial("VM2")+"'"
				cQuery += "   AND VM2.VM2_CODIGO = VM0.VM0_CODIGO"
				cQuery += "   AND VM2.VM2_TIPO = '1'"
				cQuery += "   AND VM2.VM2_STATUS <> '1'"
				cQuery += "   AND VM2.D_E_L_E_T_ = ' '"
				cQuery += " WHERE VN4.R_E_C_N_O_ = "+Alltrim(str(aVetCon[oBrwCon:nAt,9]))
			Case cTpConf == "2" // Conferencia Oficina
				cTabC := "VM3"
				cTabI := "VM4"
				cQuery += "  FROM "+RetSQLName("VN6")+" VN6"
				cQuery += "  JOIN "+RetSQLName("VM3")+" VM3"
				cQuery += "    ON VM3.VM3_FILIAL = '"+xFilial("VM3")+"'"
				cQuery += "   AND VM3.VM3_CODIGO = VN6.VN6_CODSOL"
				cQuery += "   AND VM3.VM3_NUMOSV = VN6.VN6_NUMOSV"
				cQuery += "   AND VM3.D_E_L_E_T_ = ' '"
				cQuery += "  JOIN "+RetSQLName("VM2")+" VM2"
				cQuery += "    ON VM2.VM2_FILIAL = '"+xFilial("VM2")+"'"
				cQuery += "   AND VM2.VM2_CODIGO = VM3.VM3_CODIGO"
				cQuery += "   AND VM2.VM2_TIPO = '2'"
				cQuery += "   AND VM2.VM2_STATUS <> '1'"
				cQuery += "   AND VM2.D_E_L_E_T_ = ' '"
				cQuery += " WHERE VN6.R_E_C_N_O_ = "+Alltrim(str(aVetCon[oBrwCon:nAt,9]))
			Case cTpConf == "3" // Conferencia de Orcamentos
				cTabC := "VM5"
				cTabI := "VM6"
				cQuery += "  FROM "+RetSQLName("VN5")+" VN5"
				cQuery += "  JOIN "+RetSQLName("VM5")+" VM5"
				cQuery += "    ON VM5.VM5_FILIAL = '"+xFilial("VM5")+"'"
				cQuery += "   AND VM5.VM5_NUMORC = VN5.VN5_NUMORC"
				cQuery += "   AND VM5.D_E_L_E_T_ = ' '"
				cQuery += "  JOIN "+RetSQLName("VM2")+" VM2"
				cQuery += "    ON VM2.VM2_FILIAL = '"+xFilial("VM2")+"'"
				cQuery += "   AND VM2.VM2_CODIGO = VM5.VM5_CODIGO"
				cQuery += "   AND VM2.VM2_TIPO = '3'"
				cQuery += "   AND VM2.VM2_STATUS <> '1'"
				cQuery += "   AND VM2.D_E_L_E_T_ = ' '"
				cQuery += " WHERE VN5.R_E_C_N_O_ = "+Alltrim(str(aVetCon[oBrwCon:nAt,9]))
			Case cTpConf == "4" // Conferencia de Volume de Entrada
				cTabC := "VM7"
				cTabI := "VM8"
				cQuery += "  FROM "+RetSQLName("VN7")+" VN7"
				cQuery += "  JOIN "+RetSQLName("VM7")+" VM7"
				cQuery += "    ON VM7.VM7_FILIAL = '"+xFilial("VM7")+"'"
				cQuery += "   AND VM7.VM7_VOLUME = VN7.VN7_VOLUME"
				cQuery += "   AND VM7.D_E_L_E_T_ = ' '"
				cQuery += "  JOIN "+RetSQLName("VM2")+" VM2"
				cQuery += "    ON VM2.VM2_FILIAL = '"+xFilial("VM2")+"'"
				cQuery += "   AND VM2.VM2_CODIGO = VM7.VM7_CODIGO"
				cQuery += "   AND VM2.VM2_TIPO = '4'"
				cQuery += "   AND VM2.VM2_STATUS <> '1'"
				cQuery += "   AND VM2.D_E_L_E_T_ = ' '"
				cQuery += " WHERE VN7.R_E_C_N_O_ = "+Alltrim(str(aVetCon[oBrwCon:nAt,9]))
		EndCase
		cQuery += " ORDER BY VM2.R_E_C_N_O_ "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !(cQAlSQL)->(Eof())
			cStatus := ""
			Do Case
				Case (cQAlSQL)->( VM2_STATUS ) == "2"
					cStatus := STR0019 // Aguardando Inicio da Conferência
				Case (cQAlSQL)->( VM2_STATUS ) == "3"
					cStatus := STR0020 // Conferência dos Itens
				Case (cQAlSQL)->( VM2_STATUS ) == "4"
					cStatus := STR0021+" - "+STR0028 // Aguardando Aprovação - OK
				Case (cQAlSQL)->( VM2_STATUS ) == "5"
					cStatus := STR0021+" - "+STR0029 // Aguardando Aprovação - Reprovada
			EndCase
			aAdd(aVetSta,array(7))
			nPos := len(aVetSta)
			aVetSta[ nPos , 1 ] := cStatus
			aVetSta[ nPos , 2 ] := dDatIni
			aVetSta[ nPos , 3 ] := cHorIni
			aVetSta[ nPos , 4 ] := stod((cQAlSQL)->( VM2_DATSTA ))
			aVetSta[ nPos , 5 ] := (cQAlSQL)->( VM2_HORSTA )
			aVetSta[ nPos , 6 ] := OC2400041_SOMAHORA( dtos(dDatIni) , (cQAlSQL)->( VM2_DATSTA ) , cHorIni , (cQAlSQL)->( VM2_HORSTA ) ) // Tempo por Linha de Status
			//
			aTam := OC2400051_TAMHRMNSG(aVetSta[ nPos , 6 ])
			nTmpLin := ( ( val( substr( aVetSta[ nPos , 6 ],aTam[1,1],aTam[1,2]) ) * 60 ) * 60 ) // Horas em Segundos - Linha
			nTmpLin += ( ( val( substr( aVetSta[ nPos , 6 ],aTam[2,1],aTam[2,2]) ) * 60 )      ) // Minutos em Segundos - Linha
			nTmpLin += ( ( val( substr( aVetSta[ nPos , 6 ],aTam[3,1],aTam[3,2]) )      )      ) // Minutos em Segundos - Linha
			//
			aVetSta[ nPos , 7 ] := Transform(( ( nTmpLin / nTmpTot ) * 100 ),"@E 999.9")+" %"
			//
			dDatIni := aVetSta[ nPos , 4 ]
			cHorIni := aVetSta[ nPos , 5 ]
			//
			cCodVM2 := (cQAlSQL)->( VM2_CODIGO )
			//
			(cQAlSQL)->(dbSkip())
		EndDo
		(cQAlSQL)->(dbCloseArea())
		//
		OC2400071_Levanta_Observacao_Conferencia( nLinha , cCodVM2 , cTabC , cTabI ) // Montar Observacoes da Conferencia
		//
		cFilAnt := cFilBkp
		//
	EndIf
	//
	OC2400091_CriaLinhaEmBranco()
	//
	oBrwSta:SetArray(aVetSta)
	oBrwSta:Refresh()
	oBrwSta:GoTop()
	//
	oBrwObs:SetArray(aVetObs)
	oBrwObs:Refresh()
	oBrwObs:GoTop()
	//
Return

/*/{Protheus.doc} OC2400071_Levanta_Observacao_Conferencia
Levanta Observacao (Qtdes) da Conferencia posicionada

@author Andre Luis Almeida
@since 12/11/2021
/*/
Static Function OC2400071_Levanta_Observacao_Conferencia( nLinha , cCodVM2 , cTabC , cTabI )
	Local cQAlSQL := "AUXSQL"
	Local cQuery  := ""
	//
	cQuery := "SELECT COUNT(*) "
	cQuery += "  FROM "+RetSQLName(cTabI)
	cQuery += " WHERE "+cTabI+"_FILIAL='"+xFilial(cTabI)+"'"
	cQuery += "   AND "+cTabI+"_COD"+cTabC+"='"+cCodVM2+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	aAdd(aVetObs,{STR0022,FM_SQL(cQuery)}) // Numero de Itens
	//
	cQuery := "SELECT SUM("+cTabI+"_QTORIG) "
	cQuery += "  FROM "+RetSQLName(cTabI)
	cQuery += " WHERE "+cTabI+"_FILIAL='"+xFilial(cTabI)+"'"
	cQuery += "   AND "+cTabI+"_COD"+cTabC+"='"+cCodVM2+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	aAdd(aVetObs,{STR0023,FM_SQL(cQuery)}) // Quantidade Total de Itens
	//
	If cTpConf == "4" // Conferencia por Volume - Mostrar todas as NFs que fazem parte do Volume
		aAdd(aVetObs,{STR0024,0}) // Quantidade de Notas Fiscais no Volume
		cQuery := "SELECT DISTINCT VCX_DOC , VCX_SERIE "
		cQuery += "  FROM "+RetSQLName("VCX")
		cQuery += " WHERE VCX_FILIAL = '"+xFilial("VCX")+"'"
		cQuery += "   AND VCX_VOLUME = '"+right(aVetCon[nLinha,2],GeTSX3Cache("VCX_VOLUME","X3_TAMANHO"))+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY VCX_DOC , VCX_SERIE "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !(cQAlSQL)->(Eof())
			aVetObs[3,2]++
			aAdd(aVetObs,{" - "+STR0014+" "+(cQAlSQL)->( VCX_DOC )+" - "+(cQAlSQL)->( VCX_SERIE ),0}) // NF:
			(cQAlSQL)->(dbSkip())
		EndDo
		(cQAlSQL)->(dbCloseArea())
	EndIf
	//
Return

/*/{Protheus.doc} OC2400081_TempoMedio
Tempo Médio referente ao Filtro

@author Andre Luis Almeida
@since 22/11/2021
/*/
Static Function OC2400081_TempoMedio()
Local nCntFor := 1
Local nHor    := 0
Local nMin    := 0
Local nSeg    := 0
Local nPos    := 0
Local nInt    := 0
Local nSob    := 0
Local nQtd    := len(aVetCon)
Local cTempo  := ""
If nQtd > 0
	For nCntFor := 1 to nQtd
		If !Empty(aVetCon[ nCntFor , 8 ])
			nSeg += val(right( aVetCon[ nCntFor , 8 ] , 2 ))
			If nSeg >= 60
				nMin += 1
				nSeg -= 60
			EndIf
			nMin += val(left( right( aVetCon[ nCntFor , 8 ] , 5 ) , 2 ))
			If nMin >= 60
				nHor += 1
				nMin -= 60
			EndIf
			nPos := At(":",aVetCon[ nCntFor , 8 ]) - 1 // Posicao final da Hora
			nHor += val(left( aVetCon[ nCntFor , 8 ] , nPos ))
		EndIf
	Next
	// Media do Tempo
	// Segundos
	nSeg := int(nSeg/nQtd)
	// Minutos
	nInt := int(nMin/nQtd)
	nSob := ( (nMin/nQtd) - nInt )
	nSeg += ( nSob*60 )
	nMin := nInt
	// Horas
	nInt := int(nHor/nQtd)
	nSob := ( (nHor/nQtd) - nInt )
	nMin += ( nSob*60 )
	nHor := nInt
	//
	If nHor < 100
		cTempo := strzero(nHor,2)
	Else
		cTempo := alltrim(str(nHor))
	EndIf
	cTempo += ":"+strzero(nMin,2)+":"+strzero(nSeg,2)
	MsgInfo( cTempo , STR0030 ) // Tempo Médio referente ao Filtro
EndIf
Return

/*/{Protheus.doc} OC2400091_CriaLinhaEmBranco
Cria linha em branco nos vetores

@author Andre Luis Almeida
@since 02/12/2021
/*/
Static Function OC2400091_CriaLinhaEmBranco()
Local nPos := 0
Local nQtdColunas := len(aTitCon)+1 // Colunas + RecNo
If len(aVetCon) == 0
	aAdd(aVetCon,array(nQtdColunas))
	nPos := len(aVetCon)
	aVetCon[ nPos , 1 ] := ""
	aVetCon[ nPos , 2 ] := ""
	aVetCon[ nPos , 3 ] := ""
	aVetCon[ nPos , 4 ] := ctod("")
	aVetCon[ nPos , 5 ] := ""
	aVetCon[ nPos , 6 ] := ctod("")
	aVetCon[ nPos , 7 ] := ""
	aVetCon[ nPos , 8 ] := ""
	aVetCon[ nPos , 9 ] := 0
EndIf
If len(aVetSta) == 0
	aAdd(aVetSta,array(7))
	nPos := len(aVetSta)
	aVetSta[ nPos , 1 ] := ""
	aVetSta[ nPos , 2 ] := cTod("")
	aVetSta[ nPos , 3 ] := ""
	aVetSta[ nPos , 4 ] := ctod("")
	aVetSta[ nPos , 5 ] := ""
	aVetSta[ nPos , 6 ] := ""
	aVetSta[ nPos , 7 ] := ""
EndIf
If len(aVetObs) == 0
	aAdd(aVetObs,{"",0})
EndIf
Return