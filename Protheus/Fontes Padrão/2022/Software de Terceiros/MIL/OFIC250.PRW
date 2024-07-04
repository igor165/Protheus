#Include "PROTHEUS.CH"
#INCLUDE "OFIC250.CH"

/*/{Protheus.doc} OFIC250
Consulta de Tempos por Status do Orçamento

@author Andre Luis Almeida
@since 01/12/2021
/*/
Function OFIC250(cParOrc)
//
Local aSize      := FWGetDialogSize( oMainWnd )
Local nLin       := 0
Local nCol       := 0
Local oFilHelp   := DMS_FilialHelper():New()
Local aBotEnch   := {}
Local cFilBkp    := cFilAnt
//
Private cFilOrc  := cFilAnt
Private cNumOrc  := space(GeTSX3Cache("VS1_NUMORC","X3_TAMANHO"))
Private cTipOrc  := ""
Private aTipOrc  := {"","1="+STR0002,"2="+STR0003,"3="+STR0004} // Orçamento Balcão / Orçamento Oficina / Transferência
Private aVetOrc  := {}
Private aVetSta  := {}
Private aTitOrc  := OC2500021_TitulosCOLUNAS(1) // Colunas dos Orcamentos
Private aTitSta  := OC2500021_TitulosCOLUNAS(2) // Colunas dos Status do Orcamento
Private dDtIni   := dDataBase-day(dDataBase)+1
Private dDtFin   := dDataBase
Private aCpoMark := {}
Private aFilPerm := oFilHelp:GetAllFilPermis(.f.)
Private cCadastro := STR0001 // Consulta de Tempos por Status do Orçamento
Default cParOrc := ""

If !Empty(cParOrc) // Filtrar o Orcamento individual
	cCadastro += " - "+cParOrc
	DbSelectArea("VS1")
	DbSetOrder(1)
	If !DbSeek( xFilial("VS1") + cParOrc )
		Return()
	EndIf
	aFilPerm := {cFilAnt}
	cNumOrc := cParOrc
	dDtIni  := VS1->VS1_DATORC
	dDtFin  := VS1->VS1_DATORC
	cTipOrc := VS1->VS1_TIPORC
	aAdd(aCpoMark,.t.) // Listar Orcamentos Faturados/Exportados para a OS
	aAdd(aCpoMark,.t.) // Listar Orcamentos Em Aberto
	aAdd(aCpoMark,.t.) // Listar Orcamentos Cancelados
Else // Consulta Padrao - Listar somente os Orcamentos com STATUS Faturado e Exportados para a OS
	aAdd(aCpoMark,.t.) // Listar Orcamentos Faturados/Exportados para a OS
	aAdd(aCpoMark,.f.) // Nao listar Orcamentos Em Aberto
	aAdd(aCpoMark,.f.) // Nao listar Orcamentos Cancelados
	If len(aFilPerm) > 1
		aAdd(aFilPerm,"") // Adicionar um registro em branco para trazer todas as Filiais juntas
		aSort(aFilPerm)
	EndIf
EndIf

OC2500031_LEVANTA(.f.)

DEFINE MSDIALOG oDlgOFIC250 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] TITLE cCadastro OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta de Tempos por Status do Orçamento

	If Empty(cParOrc)

		oTPanDOW := TPanel():New(0,0,"",oDlgOFIC250,NIL,.T.,.F.,NIL,NIL,100,(oDlgOFIC250:nClientHeight/4)-25,.T.,.F.)
		oTPanDOW:Align := CONTROL_ALIGN_BOTTOM

		oTPanStatus := TPanel():New(0,0,"",oTPanDOW,NIL,.T.,.F.,NIL,NIL,100,(oDlgOFIC250:nClientHeight/4)-25,.T.,.F.)
		oTPanStatus:Align := CONTROL_ALIGN_ALLCLIENT

		oTPanTOP := TPanel():New(0,0,"",oDlgOFIC250,NIL,.T.,.F.,NIL,NIL,100,(oDlgOFIC250:nClientHeight/4)-25,.T.,.F.)
		oTPanTOP:Align := CONTROL_ALIGN_BOTTOM

		oScrollFilt := TScrollBox():New( oTPanTOP , 0, 0, 25, 25, .t. /* lVertical */ , .f. /* lHorizontal */ , .f. /* lBorder */ )
		oScrollFilt:Align := CONTROL_ALIGN_TOP

		nLin := 2
		nCol := 5
		oSayFil := tSay():New( nLin  , nCol, {|| STR0005 } , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE,80,20) // Filial
		oCmbFil := TComboBox():New(nLin+09, nCol,{ | u | If( PCount() == 0, cFilOrc , cFilOrc := u )},aFilPerm,70,08,oScrollFilt,,{||.t.},{ || OC2500121_Valid_Filial(cFilBkp) },,,.T.,,,,{ || .t. },,,,,'cFilOrc')
		nCol += 75
		oSayOrc := tSay():New( nLin  , nCol, {|| STR0006 } , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE,80,20) // Orçamento
		oGetOrc := TGet():New( nLin+09, nCol, { | u | If( PCount() == 0, cNumOrc , cNumOrc := u ) },oScrollFilt,45,08, "@!" ,{ || OC2500111_Valid_Numero_Orcamento() },,,,.F.,,.T.,,.F.,{ || .t. },.F.,.F.,,.F.,.F. ,,"cNumOrc",,,,)
		oGetOrc:cF3 := "VS1ORC"
		nCol += 50
		oSayTip := tSay():New( nLin  , nCol, {|| STR0007 } , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE,80,20) // Tipo
		oCmbTip := TComboBox():New(nLin+09, nCol,{ | u | If( PCount() == 0, cTipOrc , cTipOrc := u )},aTipOrc,75,08,oScrollFilt,,{||.t.},,,,.T.,,,,{ || Empty(cNumOrc) },,,,,'cTipOrc')
		nCol += 80
		oSayDtI := tSay():New( nLin  , nCol, {|| STR0008 } , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE,80,20) // Data Inicial
		oGetDtI := TGet():New( nLin+09, nCol, { | u | If( PCount() == 0, dDtIni , dDtIni := u ) },oScrollFilt,50,08, "@D" ,{ || .t. },,,,.F.,,.T.,,.F.,{ || Empty(cNumOrc) },.F.,.F.,,.F.,.F. ,,"dDtIni",,,,)
		nCol += 55
		oSayDtF := tSay():New( nLin  , nCol, {|| STR0009 } , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE,80,20) // Data Final
		oGetDtF := TGet():New( nLin+09, nCol, { | u | If( PCount() == 0, dDtFin , dDtFin := u ) },oScrollFilt,50,08, "@D" ,{ || .t. },,,,.F.,,.T.,,.F.,{ || Empty(cNumOrc) },.F.,.F.,,.F.,.F. ,,"dDtFin",,,,)
		nCol += 55
		oChkFin := TCheckBox():New( nLin-02, nCol, STR0010 , { | U | IF( PCOUNT() == 0, aCpoMark[1] , aCpoMark[1] := U ) } , oScrollFilt, 110,10,,,,,,,,.T., STR0011 ,,{ || Empty(cNumOrc) } ) // Faturados/Exportados para a OS / Marque para listar os Orçamentos Faturados e Exportados para a Ordem de Serviço
		oChkAbe := TCheckBox():New( nLin+05, nCol, STR0012 , { | U | IF( PCOUNT() == 0, aCpoMark[2] , aCpoMark[2] := U ) } , oScrollFilt, 110,10,,,,,,,,.T., STR0013 ,,{ || Empty(cNumOrc) } ) // Em Aberto / Marque para listar os Orçamentos Em Aberto
		oChkCan := TCheckBox():New( nLin+12, nCol, STR0014 , { | U | IF( PCOUNT() == 0, aCpoMark[3] , aCpoMark[3] := U ) } , oScrollFilt, 110,10,,,,,,,,.T., STR0015 ,,{ || Empty(cNumOrc) } ) // Cancelados / Marque para listar os Orçamentos Cancelados
		nCol += 105
		oButFil := TButton():New( nLin+05, nCol, STR0016 ,oScrollFilt,{|| OC2500031_LEVANTA(.t.) },40,12,,,.F.,.T.,.F.,,.F.,{ || .t. },,.F. ) // Filtrar

		oBrwOrc := FWBrowse():New()
		oBrwOrc:SetOwner(oTPanTOP)
		oBrwOrc:SetDescription(STR0018) // Orçamentos
		oBrwOrc:SetProfileID("T")
		oBrwOrc:SetDataArray()
		oBrwOrc:SetColumns(OC2500011_MontaCol(1,aTitOrc))
		oBrwOrc:SetArray(aVetOrc)
		oBrwOrc:Activate() // Ativação do Browse
		oBrwOrc:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwOrc:SetChange( { || OC2500061_Levanta_Status_Orcamento( oBrwOrc:nAt , .t. ) } )
		oBrwOrc:SetDoubleClick ( { || OC2500091_Visualizar_Orcamento( oBrwOrc:nAt ) } )

	Else

		oTPanStatus := TPanel():New(0,0,"",oDlgOFIC250,NIL,.T.,.F.,NIL,NIL,100,100,.T.,.F.)
		oTPanStatus:Align := CONTROL_ALIGN_ALLCLIENT

	EndIf

	oBrwSta := FWBrowse():New()
	oBrwSta:SetOwner(oTPanStatus)
	oBrwSta:SetDescription(STR0019) // Mudanças no Status do Orçamento selecionado
	oBrwSta:SetProfileID("T")
	oBrwSta:SetDataArray()
	oBrwSta:SetColumns(OC2500011_MontaCol(2,aTitSta))
	oBrwSta:SetArray(aVetSta)
	oBrwSta:Activate() // Ativação do Browse
	oBrwSta:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlgOFIC250 ON INIT EnchoiceBar(oDlgOFIC250,{ || oDlgOFIC250:End() }, { || oDlgOFIC250:End() },,aBotEnch)

cFilAnt := cFilBkp

Return()

/*/{Protheus.doc} OC2500011_MontaCol
Adicao das Colunas do Browse

@author Andre Luis Almeida
@since 01/12/2021
/*/
Static Function OC2500011_MontaCol(nTp,aHeader)
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
	If nTp == 1 // Orcamento
		cSetData := "{|| oBrwOrc:Data():GetArray()[oBrwOrc:AT()][" + cValToChar(aHeader[nHeader][5]) + "] }"
	ElseIf nTp == 2 // Status
		cSetData := "{|| oBrwSta:Data():GetArray()[oBrwSta:AT()][" + cValToChar(aHeader[nHeader][5]) + "] }"
	EndIf
	oColuna:SetData(&(cSetData))
	//
	aAdd(aColunas, oColuna)
Next nHeader
Return aColunas

/*/{Protheus.doc} OC2500021_TitulosCOLUNAS
Retorna Titulos/Tipos/Tamanhos/Mascara das Colunas do Browse

@author Andre Luis Almeida
@since 01/12/2021
/*/
Static Function OC2500021_TitulosCOLUNAS(nTp)
Local aRetCol := {}
Local nCol    := 0
Do Case
	Case nTp == 1 // Orcamentos
		aAdd(aRetCol, {STR0005,"C", 12,""           , ++nCol,"L"}) // Filial
		aAdd(aRetCol, {STR0006,"C", 12,""           , ++nCol,"L"}) // Orçamento
		aAdd(aRetCol, {STR0017,"D", 12,"@D"         , ++nCol,"L"}) // Data
		aAdd(aRetCol, {STR0007,"C", 17,""           , ++nCol,"L"}) // Tipo
		aAdd(aRetCol, {STR0020,"C", 20,""           , ++nCol,"L"}) // Status atual
		aAdd(aRetCol, {STR0021,"C", 20,""           , ++nCol,"L"}) // Cliente
	Case nTp == 2 // Status
		aAdd(aRetCol, {STR0022,"C", 20,""           , ++nCol,"L"}) // Status
		aAdd(aRetCol, {STR0008,"D", 05,"@D"         , ++nCol,"L"}) // Data Inicial
		aAdd(aRetCol, {STR0023,"C", 05,"@R 99:99:99", ++nCol,"L"}) // Hora Inicial
		aAdd(aRetCol, {STR0009,"D", 05,"@D"         , ++nCol,"L"}) // Data Final
		aAdd(aRetCol, {STR0024,"C", 05,"@R 99:99:99", ++nCol,"L"}) // Hora Final
		aAdd(aRetCol, {STR0025,"C", 05,""           , ++nCol,"L"}) // Tempo Total
		aAdd(aRetCol, {"%"    ,"C", 05,""           , ++nCol,"R"}) // %
		aAdd(aRetCol, {STR0026,"C", 20,""           , ++nCol,"L"}) // Observação
EndCase
Return aRetCol

/*/{Protheus.doc} OC2500031_LEVANTA
Levanta Dados para incluir registros no Browse 

@author Andre Luis Almeida
@since 01/12/2021
/*/
Static Function OC2500031_LEVANTA(lRefresh)
Local cQuery   := ""
Local cQAlSQL  := "SQLCONF"
Local nPos     := 0
Local nCntFil  := 0
Local nQtdColunas := len(aTitOrc)+1 // Colunas + RecNo
Local cFilBkp  := cFilAnt
Local cNamVS1  := RetSQLName("VS1")
Local cNamSA1  := RetSQLName("SA1")
//
aVetOrc := {}
//
For nCntFil := 1 to len(aFilPerm)
	//
	If Empty(aFilPerm[nCntFil])
		Loop // Pula linha em branco do Vetor de Filiais
	EndIf
	//
	If Empty(cFilOrc)
		cFilAnt := aFilPerm[nCntFil]
	Else
		cFilAnt := cFilOrc
	EndIf
	//
	cQuery := "SELECT VS1.VS1_NUMORC , VS1.VS1_TIPORC , VS1.VS1_STATUS , SA1.A1_COD , SA1.A1_LOJA , SA1.A1_NOME , VS1.VS1_DATORC , VS1.R_E_C_N_O_ AS RECVS1"
	cQuery += "  FROM "+cNamVS1+" VS1 "
	cQuery += "  JOIN "+cNamSA1+" SA1 "
	cQuery += "    ON SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
	cQuery += "   AND SA1.A1_COD = VS1.VS1_CLIFAT"
	cQuery += "   AND SA1.A1_LOJA = VS1.VS1_LOJA"
	cQuery += "   AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE VS1.VS1_FILIAL = '"+xFilial("VS1")+"'"
	If !Empty(cNumOrc)
		cQuery += " AND VS1.VS1_NUMORC='"+cNumOrc+"'"
	EndIf
	cQuery += "   AND VS1.VS1_DATORC >= '"+dtos(dDtIni)+"'"
	cQuery += "   AND VS1.VS1_DATORC <= '"+dtos(dDtFin)+"'"
	If !Empty(cTipOrc)
		cQuery += " AND VS1.VS1_TIPORC='"+cTipOrc+"'"
	Else
		cQuery += " AND VS1.VS1_TIPORC IN ('1','2','3') " // 1=Balcão / 2=Oficina / 3=Transferência
	EndIf
	Do Case // Tik's dos Status
		Case  aCpoMark[1] .and. !aCpoMark[2] .and. !aCpoMark[3] // Somente Faturados/Exportados para a OS
			cQuery += " AND VS1.VS1_STATUS IN ('X','I') "
		Case  aCpoMark[1] .and. !aCpoMark[2] .and.  aCpoMark[3] // Faturados/Exportados para a OS e Cancelados
			cQuery += " AND VS1.VS1_STATUS IN ('X','I','C') "
		Case  aCpoMark[1] .and.  aCpoMark[2] .and. !aCpoMark[3] // Todos menos os Cancelados
			cQuery += " AND VS1.VS1_STATUS <> 'C'"
		Case !aCpoMark[1] .and. !aCpoMark[2] .and. !aCpoMark[3] // Nenhuma selecao realizada - NAO TRAZER REGISTRO
			cQuery += " AND VS1.VS1_STATUS = 'NAO_LEVANTAR_DADOS' "
		Case !aCpoMark[1] .and. !aCpoMark[2] .and.  aCpoMark[3] // Somente Orcamentos Cancelados
			cQuery += " AND VS1.VS1_STATUS = 'C' "
		Case !aCpoMark[1] .and.  aCpoMark[2] .and. !aCpoMark[3] // Somente Orcamentos Em Aberto
			cQuery += " AND VS1.VS1_STATUS NOT IN ('X','I','C') "
		Case !aCpoMark[1] .and.  aCpoMark[2] .and.  aCpoMark[3] // Orcamentos Em Aberto e Cancelados
			cQuery += " AND VS1.VS1_STATUS NOT IN ('X','I') "
	EndCase
	cQuery += "   AND VS1.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VS1.VS1_NUMORC "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
	While !(cQAlSQL)->(Eof())
		aAdd(aVetOrc,array(nQtdColunas))
		nPos := len(aVetOrc)
		aVetOrc[ nPos , 1 ] := cFilAnt
		aVetOrc[ nPos , 2 ] := (cQAlSQL)->( VS1_NUMORC )
		aVetOrc[ nPos , 3 ] := stod((cQAlSQL)->( VS1_DATORC ))
		aVetOrc[ nPos , 4 ] := OC2500071_Descricao_Tipo( (cQAlSQL)->( VS1_TIPORC ) )
		aVetOrc[ nPos , 5 ] := OC2500081_Descricao_Status( (cQAlSQL)->( VS1_STATUS ) )
		aVetOrc[ nPos , 6 ] := (cQAlSQL)->( A1_COD ) +"-"+ (cQAlSQL)->( A1_LOJA ) +" "+ (cQAlSQL)->( A1_NOME )
		aVetOrc[ nPos , 7 ] := (cQAlSQL)->( RECVS1 )
		(cQAlSQL)->(dbSkip())
	EndDo
	(cQAlSQL)->(dbCloseArea())
	//
	If !Empty(cFilOrc)
		Exit
	EndIf
	//
Next
//
cFilAnt := cFilBkp
//
OC2500101_CriaLinhaEmBranco()
//
If lRefresh
	oBrwOrc:nAt := 1
	oBrwOrc:SetArray(aVetOrc)
	oBrwOrc:Refresh()
	oBrwOrc:GoTop()
EndIf
//
OC2500061_Levanta_Status_Orcamento( 1 , lRefresh )
//
Return

/*/{Protheus.doc} OC2500041_SOMAHORA
Calculo -> Soma de Horas

@author Andre Luis Almeida
@since 01/12/2021
/*/
Static Function OC2500041_SOMAHORA( sDtIni , sDtFin , cHrIni , cHrFin )
Local cTempo := ""
Local nDias  := stod(sDtFin) - stod(sDtIni)
Local aTam1  := OC2500051_TAMHRMNSG(cHrIni)
Local aTam2  := OC2500051_TAMHRMNSG(cHrFin)
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

/*/{Protheus.doc} OC2500051_TAMHRMNSG
Retorna o tamanho do formato das Horas:Minutos:Segundos

@author Andre Luis Almeida
@since 01/12/2021
/*/
Static Function OC2500051_TAMHRMNSG(cString)
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

/*/{Protheus.doc} OC2500061_Levanta_Status_Orcamento
Levanta os Status da Conferencia posicionada

@author Andre Luis Almeida
@since 01/12/2021
/*/
Static Function OC2500061_Levanta_Status_Orcamento( nLinha , lRefresh )
	Local cQuery  := ""
	Local cQAlSQL := "SQLVN8"
	Local nPos    := 1
	Local cFilBkp := cFilAnt
	Local aTam    := 0
	Local nTmpTot := 0
	Local nTmpLin := 0
	//
	aVetSta := {}
	//
	If len(aVetOrc) > 0 .and. aVetOrc[ nLinha , 7 ] > 0
		//
		cFilAnt := aVetOrc[ nLinha , 1 ]
		//
		cQuery := "SELECT COUNT(*) "
 		cQuery += "  FROM "+RetSQLName("VS3")
		cQuery += " WHERE VS3_FILIAL = '"+xFilial("VS3")+"'"
		cQuery += "   AND VS3_NUMORC = '"+aVetOrc[ nLinha , 2 ]+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		//
		aAdd(aVetSta,array(8))
		aVetSta[ 1 , 1 ] := STR0025 // Tempo Total
		aVetSta[ 1 , 2 ] := cTod("")
		aVetSta[ 1 , 3 ] := ""
		aVetSta[ 1 , 4 ] := ctod("")
		aVetSta[ 1 , 5 ] := ""
		aVetSta[ 1 , 6 ] := ""
		aVetSta[ 1 , 7 ] := "100,0 %"
		aVetSta[ 1 , 8 ] := STR0027+": "+Alltrim(str(FM_SQL(cQuery))) // Número de Itens
		//
		cQuery := "SELECT VN8_STATUS , VN8_DATSTA , VN8_HORSTA , VN8_OBSSTA "
 		cQuery += "  FROM "+RetSQLName("VN8")
		cQuery += " WHERE VN8_FILIAL = '"+xFilial("VN8")+"'"
		cQuery += "   AND VN8_NUMORC = '"+aVetOrc[ nLinha , 2 ]+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY VN8_CODIGO"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !(cQAlSQL)->(Eof())
			//
			aAdd(aVetSta,array(8))
			nPos := len(aVetSta)
			aVetSta[ nPos , 1 ] := OC2500081_Descricao_Status( (cQAlSQL)->( VN8_STATUS ) )
			aVetSta[ nPos , 2 ] := stod((cQAlSQL)->( VN8_DATSTA ))
			aVetSta[ nPos , 3 ] := (cQAlSQL)->( VN8_HORSTA )
			aVetSta[ nPos , 4 ] := cTod("")
			aVetSta[ nPos , 5 ] := ""
			aVetSta[ nPos , 6 ] := "" // Tempo por Linha de Status
			aVetSta[ nPos , 7 ] := "" // %
			aVetSta[ nPos , 8 ] := (cQAlSQL)->( VN8_OBSSTA )
			If nPos > 2
				aVetSta[ nPos-1 , 4 ] := aVetSta[ nPos , 2 ] // Preenche a Data Final com a Inicial do Proximo Status
				aVetSta[ nPos-1 , 5 ] := aVetSta[ nPos , 3 ] // Preenche a Hora Final com a Inicial do Proximo Status
			EndIf
			//
			(cQAlSQL)->(dbSkip())
		EndDo
		(cQAlSQL)->(dbCloseArea())
		//
		If len(aVetSta) > 1
			//
			nPos := len(aVetSta)
			aVetSta[    1 , 2 ] := aVetSta[    2 , 2 ]
			aVetSta[    1 , 3 ] := aVetSta[    2 , 3 ]
			aVetSta[    1 , 4 ] := aVetSta[ nPos , 2 ]
			aVetSta[    1 , 5 ] := aVetSta[ nPos , 3 ]
			aVetSta[ nPos , 4 ] := aVetSta[ nPos , 2 ]
			aVetSta[ nPos , 5 ] := aVetSta[ nPos , 3 ]
			//
			For nPos := 1 to ( len(aVetSta)-1 )
				aVetSta[ nPos , 6 ] := OC2500041_SOMAHORA( dtos(aVetSta[ nPos , 2 ]) , dtos(aVetSta[ nPos , 4 ]) , aVetSta[ nPos , 3 ] , aVetSta[ nPos , 5 ] ) // Tempo por Linha de Status
				aTam := OC2500051_TAMHRMNSG(aVetSta[ nPos , 6 ])
				nTmpLin := ( ( val( substr( aVetSta[ nPos , 6 ],aTam[1,1],aTam[1,2]) ) * 60 ) * 60 ) // Horas em Segundos - Linha
				nTmpLin += ( ( val( substr( aVetSta[ nPos , 6 ],aTam[2,1],aTam[2,2]) ) * 60 )      ) // Minutos em Segundos - Linha
				nTmpLin += ( ( val( substr( aVetSta[ nPos , 6 ],aTam[3,1],aTam[3,2]) )      )      ) // Minutos em Segundos - Linha
				If nPos == 1 // Linha Total
					nTmpTot := nTmpLin // Totalizador ( utilizado nos % das demais linhas )
				EndIf
				aVetSta[ nPos , 7 ] := Transform(( ( nTmpLin / nTmpTot ) * 100 ),"@E 999.9")+" %"
			Next
			//
			aVetSta[ len(aVetSta) , 4 ] := cTod("")
			aVetSta[ len(aVetSta) , 5 ] := ""
			//
		EndIf
		//
		cFilAnt := cFilBkp
		//
	EndIf
	//
	OC2500101_CriaLinhaEmBranco()
	//
	If lRefresh
		oBrwSta:SetArray(aVetSta)
		oBrwSta:Refresh()
		oBrwSta:GoTop()
	EndIf
	//
Return

/*/{Protheus.doc} OC2500071_Descricao_Tipo
Retorna o Tipo de Orcamento

@author Andre Luis Almeida
@since 01/12/2021
/*/
Static Function OC2500071_Descricao_Tipo( cTipRet )
Do Case
	Case cTipRet == "1"
		cTipRet := STR0002 // Orçamento Balcão
	Case cTipRet == "2"
		cTipRet := STR0003 // Orçamento Oficina
	Case cTipRet == "3"
		cTipRet := STR0004 // Transferência
EndCase
Return cTipRet

/*/{Protheus.doc} OC2500081_Descricao_Status
Retorna a Descricao dos Status do Orcamento

@author Andre Luis Almeida
@since 01/12/2021
/*/
Static Function OC2500081_Descricao_Status( cStaRet )
Local cFaseConfer := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Do Case
	Case cStaRet == "0"
		cStaRet := STR0028 // Digitado
	Case cStaRet == "2"
		cStaRet := STR0029 // Margem Pendente
	Case cStaRet == "3"
		cStaRet := STR0030 // Avaliação de Crédito
	Case cStaRet == cFaseConfer
		cStaRet := STR0031 // Conferência dos Itens
	Case cStaRet == "5"
		cStaRet := STR0032 // Liberação da Divergência
	Case cStaRet $ "RT"
		cStaRet := STR0033 // Aguardando Reserva
	Case cStaRet == "G"
		cStaRet := STR0043 // Aguardando outro Orçamento
	Case cStaRet == "F"
		cStaRet := STR0034 // Liberado para Faturamento
	Case cStaRet == "P"
		cStaRet := STR0035 // Pendente para OS
	Case cStaRet == "L"
		cStaRet := STR0036 // Liberado para OS
	Case cStaRet == "I"
		cStaRet := STR0037 // Exportados para a OS
	Case cStaRet == "C"
		cStaRet := STR0038 // Cancelado
	Case cStaRet == "X"
		cStaRet := STR0039 // Faturado
EndCase
Return cStaRet

/*/{Protheus.doc} OC2500091_Visualizar_Orcamento
Visualiza o Orcamento

@author Andre Luis Almeida
@since 02/12/2021
/*/
Static Function OC2500091_Visualizar_Orcamento( nLinha )
Local cFilBkp     := cFilAnt
Private cCadastro := STR0006 // Orçamento
If len(aVetOrc) > 0 .and. aVetOrc[ nLinha , 7 ] > 0
	cFilAnt := aVetOrc[ nLinha , 1 ]
	DbSelectArea("VS1")
	DbSetOrder(1)
	If DbSeek( xFilial("VS1") + aVetOrc[ nLinha , 2 ] )
		OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
	EndIf
	cFilAnt := cFilBkp
EndIf
Return()

/*/{Protheus.doc} OC2500101_CriaLinhaEmBranco
Cria linha em branco nos vetores

@author Andre Luis Almeida
@since 02/12/2021
/*/
Static Function OC2500101_CriaLinhaEmBranco()
Local nPos := 0
Local nQtdColunas := len(aTitOrc)+1 // Colunas + RecNo
If len(aVetOrc) == 0
	aAdd(aVetOrc,array(nQtdColunas))
	nPos := len(aVetOrc)
	aVetOrc[ nPos , 1 ] := ""
	aVetOrc[ nPos , 2 ] := ""
	aVetOrc[ nPos , 3 ] := ctod("")
	aVetOrc[ nPos , 4 ] := ""
	aVetOrc[ nPos , 5 ] := ""
	aVetOrc[ nPos , 6 ] := ""
	aVetOrc[ nPos , 7 ] := 0
EndIf
If len(aVetSta) == 0
	aAdd(aVetSta,array(8))
	nPos := len(aVetSta)
	aVetSta[ nPos , 1 ] := ""
	aVetSta[ nPos , 2 ] := ctod("")
	aVetSta[ nPos , 3 ] := ""
	aVetSta[ nPos , 4 ] := ctod("")
	aVetSta[ nPos , 5 ] := ""
	aVetSta[ nPos , 6 ] := "" // Tempo por Linha de Status
	aVetSta[ nPos , 7 ] := "" // %
	aVetSta[ nPos , 8 ] := ""
EndIf
Return

/*/{Protheus.doc} OC2500111_Valid_Numero_Orcamento
Valid do Nro do Orcamento

@author Andre Luis Almeida
@since 02/12/2021
/*/
Static Function OC2500111_Valid_Numero_Orcamento()
Local lRet := .t.
If !Empty(cNumOrc)
	If !Empty(cFilOrc)
		cFilAnt := cFilOrc
	EndIf
	DbSelectArea("VS1")
	DbSetOrder(1)
	If dbSeek( xFilial("VS1") + cNumOrc )
		If VS1->VS1_TIPORC $ "123"
			If Empty(cFilOrc)
				cFilOrc := cFilAnt
			EndIf
			dDtIni  := VS1->VS1_DATORC
			dDtFin  := VS1->VS1_DATORC
			cTipOrc := VS1->VS1_TIPORC
			aCpoMark[1] := .t. // Listar Orcamentos Faturados/Exportados para a OS
			aCpoMark[2] := .t. // Listar Orcamentos Em Aberto
			aCpoMark[3] := .t. // Listar Orcamentos Cancelados
		Else
			MsgStop(STR0041,STR0040) // Tipo de Orçamento inválido. Impossivel continuar. / Atenção
			lRet := .f.
		EndIf
	Else
		MsgStop(STR0042,STR0040) // Orçamento não encontrado. Impossivel continuar. / Atenção
		lRet := .f.
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OC2500121_Valid_Filial
Valid da Filial

@author Andre Luis Almeida
@since 02/12/2021
/*/
Static Function OC2500121_Valid_Filial(cFilBkp)
If !Empty(cFilOrc)
	cFilAnt := cFilOrc
Else
	cFilAnt := cFilBkp
EndIf
Return .t.