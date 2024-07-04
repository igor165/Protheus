#Include "PROTHEUS.CH"
#INCLUDE "OFIC120.CH"

/*/{Protheus.doc} OFIC120
Consulta Eficiencia das Conferencias

@author Andre Luis Almeida
@since 19/11/2019
@version 1.0

@type function
/*/
Function OFIC120(cTpFiltrar)
//
Local aSize      := FWGetDialogSize( oMainWnd )
Local aTpConf    := {"","1="+STR0002,"2="+STR0003,"3="+STR0004,"4="+STR0033} // NF de Entrada / Oficina / Orçamentos / Volume de Entrada
Local nLin       := 0
Local nCol       := 0
Local oFilHelp   := DMS_FilialHelper():New()
Local aBotEnch   := {}
//
Private aVetEfic := {}
Private cTpConf  := ""
Private aTitCol  := OC1200021_TitulosCOLUNAS(1) // Colunas Eficiencia
Private dDtIni   := dDataBase-day(dDataBase)+1
Private dDtFin   := dDataBase
Private oGrafPeq
Private aDadosGraf := {}
Private aFilPerm   := oFilHelp:GetAllFilPermis(.f.)
Private cFilUsuario := cFilAnt
Private cConferente := Space(8)
Private cCadastro := STR0001 // Eficiência das Conferências

Default cTpFiltrar := ""
If !Empty(cTpFiltrar)
	cTpConf := cTpFiltrar // Ja vir Filtrado o Tipo de Conferencia - NAO DEIXAR MUDAR
EndIf

If len(aFilPerm) > 1
	aAdd(aFilPerm,"") // Adicionar um registro em branco para trazer todas as Filiais juntas
	aSort(aFilPerm)
EndIf

OC1200031_LEVANTA(.f.)

SetKey(VK_F7,{ || OC1200071_Tela_F7_Analitico() })
AADD(aBotEnch, {"ANALITIC" ,{|| OC1200071_Tela_F7_Analitico() }, "<F7> "+STR0030 } ) // Visualizar Dados Analiticamente

DEFINE MSDIALOG oDlgOFIC120 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] TITLE STR0001 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Eficiência das Conferências

	oTPanDOW := TPanel():New(0,0,"",oDlgOFIC120,NIL,.T.,.F.,NIL,NIL,100,(oDlgOFIC120:nClientHeight/4)-25,.T.,.F.)
	oTPanDOW:Align := CONTROL_ALIGN_BOTTOM

	oTPanTOP := TPanel():New(0,0,"",oDlgOFIC120,NIL,.T.,.F.,NIL,NIL,100,(oDlgOFIC120:nClientHeight/4)-25,.T.,.F.)
	oTPanTOP:Align := CONTROL_ALIGN_BOTTOM

	oScrollFilt := TScrollBox():New( oTPanTOP , 0, 0, 25, 25, .t. /* lVertical */ , .f. /* lHorizontal */ , .f. /* lBorder */ )
	oScrollFilt:Align := CONTROL_ALIGN_TOP

	nLin := 2
	nCol := 5
	oSayTip := tSay():New( nLin  , nCol, {|| STR0005 } , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE, 080, 020) // Tipo de Conferência de Peças
	oCmbTip := TComboBox():New(nLin+8, nCol,{|u|if(PCount()>0,cTpConf:=u,cTpConf)},aTpConf,80,08,oScrollFilt,,{||.t.},,,,.T.,,,,{|| Empty(cTpFiltrar) },,,,,'cTpConf')
	nCol += 90
	oSayDtI := tSay():New( nLin  , nCol, {|| STR0006 } , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE, 080, 020) // Data Inicial
	oGetDtI := TGet():New( nLin+8, nCol, { | u | If( PCount() == 0, dDtIni , dDtIni := u ) },oScrollFilt,060, 008, "@D" ,{ || .t. },,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtIni",,,,)
	nCol += 70
	oSayDtF := tSay():New( nLin  , nCol, {|| STR0007 } , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE, 080, 020) // Data Final
	oGetDtF := TGet():New( nLin+8, nCol, { | u | If( PCount() == 0, dDtFin , dDtFin := u ) },oScrollFilt,060, 008, "@D" ,{ || .t. },,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtFin",,,,)
	nCol += 70
	oSayUser := tSay():New( nLin  , nCol, {|| STR0028  } , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE, 080, 020) // Conferente
	oGetUser := TGet():New( nLin+8, nCol, { | u | If( PCount() > 0, cConferente := u,cConferente) },oScrollFilt, 060, 008, "@!",{ || .T. },,,,.F.,,.T.,,.F.,{ || .T. },,,,,,"USR","cConferente",,,,)
	nCol += 70
	oSayFil := tSay():New( nLin  , nCol, {|| STR0029 } , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE, 080, 020) //Filial
	oCmbFil := TComboBox():New(nLin+8, nCol,{|u| If( PCount() > 0, cFilUsuario := u,cFilUsuario)},aFilPerm,50,08,oScrollFilt,,{||.t.},,,,.T.,,,,{|| Empty(cTpFiltrar) },,,,,'cFilUsuario')
	nCol += 70
	oButFil := TButton():New( nLin+6, nCol, STR0008 ,oScrollFilt,{|| OC1200031_LEVANTA(.t.) }, 40,12,,,.F.,.T.,.F.,,.F.,{ || !Empty(cTpConf) },,.F. ) // Filtrar

	oBrwEfic := FWBrowse():New()
	oBrwEfic:SetOwner(oTPanTOP)
	oBrwEfic:SetDescription(STR0001) // Eficiência das Conferências
	oBrwEfic:SetProfileID("T")
	oBrwEfic:SetDataArray()
	oBrwEfic:SetColumns(OC1200011_MontaCol(1,aTitCol))
	oBrwEfic:SetArray(aVetEfic)
	oBrwEfic:SetDoubleClick( { || OC1200061_GRAFICO() } )
	oBrwEfic:Activate() // Ativação do Browse
	oBrwEfic:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrwEfic:Refresh()
	oBrwEfic:GoTop()

	@ 5,5 SCROLLBOX oGrafPeq SIZE 100,100 OF oTPanDOW BORDER PIXEL
	oGrafPeq:Align := CONTROL_ALIGN_ALLCLIENT

	OC1200061_GRAFICO()

ACTIVATE MSDIALOG oDlgOFIC120 ON INIT EnchoiceBar(oDlgOFIC120,{ || oDlgOFIC120:End() }, { || oDlgOFIC120:End() },,aBotEnch)

SetKey(VK_F7, nil)

Return()

/*/{Protheus.doc} OC1200011_MontaCol
Adicao das Colunas do Browse

@author Andre Luis Almeida
@since 19/11/2019
@version 1.0

@type function
/*/
Static Function OC1200011_MontaCol(nTp,aHeader)
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
	If nTp == 1 // Eficiencia
		cSetData := "{|| oBrwEfic:Data():GetArray()[oBrwEfic:AT()][" + cValToChar(aHeader[nHeader][5]) + "] }"
	Else // Analitico
		cSetData := "{|| oBrwAna:Data():GetArray()[oBrwAna:AT()][" + cValToChar(aHeader[nHeader][5]) + "] }"
	EndIf
	oColuna:SetData(&(cSetData))
	//
	aAdd(aColunas, oColuna)
Next nHeader
Return aColunas

/*/{Protheus.doc} OC1200021_TitulosCOLUNAS
Retorna Titulos/Tipos/Tamanhos/Mascara das Colunas do Browse

@author Andre Luis Almeida
@since 19/11/2019
@version 1.0

@type function
/*/
Static Function OC1200021_TitulosCOLUNAS(nTp)
Local aRetCol := {}
Local nCol    := 0
//
If nTp == 1 // Eficiencia
	aADD(aRetCol, {STR0010,"C", 40,"@!"            , ++nCol,"L"}) // Agrupador
	aADD(aRetCol, {STR0011,"N", 05,"@E 999,999,999", ++nCol,"R"}) // Qtd.Documentos
	aADD(aRetCol, {STR0012,"N", 05,"@R 999.9 %"    , ++nCol,"R"}) // % Qtd.Documentos
Else // Analitico
	Do Case 
		Case cTpConf == "1" // Conferencia NF Entrada
			aADD(aRetCol, {STR0002+" + "+STR0031,"C", 40,"@!"            , ++nCol,"L"}) // NF de Entrada / Fornecedor
		Case cTpConf == "2" // Conferencia Oficina
			aADD(aRetCol, {STR0032,"C", 40,"@!"            , ++nCol,"L"}) // Ordem de Serviço
		Case cTpConf == "3" // Conferencia Orcamentos
			aADD(aRetCol, {STR0004,"C", 40,"@!"            , ++nCol,"L"}) // Orçamento
		Case cTpConf == "4" // Conferencia Volume de Entrada
			aADD(aRetCol, {STR0033,"C", 40,"@!"            , ++nCol,"L"}) // Volume de Entrada
	EndCase
EndIf
aADD(aRetCol, {STR0013,"N", 05,"@E 999,999,999",++nCol,"R"}) // Qtd.Conferencias
aADD(aRetCol, {STR0014,"N", 05,"@R 999.9 %"    ,++nCol,"R"}) // % Qtd.Conferencias
aADD(aRetCol, {STR0015,"N", 05,"@E 999,999,999",++nCol,"R"}) // Qtd.Conf.Aprovadas
aADD(aRetCol, {STR0016,"N", 05,"@R 999.9 %"    ,++nCol,"R"}) // % Qtd.Conf.Aprovadas
aADD(aRetCol, {STR0017,"N", 05,"@E 999,999,999",++nCol,"R"}) // Qtd.Conf.Reprovadas
aADD(aRetCol, {STR0018,"N", 05,"@R 999.9 %"    ,++nCol,"R"}) // % Qtd.Conf.Reprovadas
aADD(aRetCol, {STR0019,"N", 05,"@E 999,999,999",++nCol,"R"}) // Qtd.Itens
aADD(aRetCol, {STR0020,"N", 05,"@R 999.9 %"    ,++nCol,"R"}) // % Qtd.Itens
aADD(aRetCol, {STR0021,"N", 05,"@E 999,999,999",++nCol,"R"}) // Qtd.Itens Bipados
aADD(aRetCol, {STR0022,"N", 05,"@R 999.9 %"    ,++nCol,"R"}) // % Qtd.Itens Bipados
aADD(aRetCol, {STR0023,"C", 05,"@!"            ,++nCol,"R"}) // Tempo Total
aADD(aRetCol, {STR0024,"N", 05,"@R 999.9 %"    ,++nCol,"R"}) // % Tempo Total
If nTp == 1 // Eficiencia
	aADD(aRetCol, {STR0025,"C", 05,"@!"            ,++nCol,"R"}) // Tempo Medio
	aADD(aRetCol, {STR0026,"N", 05,"@R 999.9 %"    ,++nCol,"R"}) // % Tempo Medio
EndIf
//
Return aRetCol

/*/{Protheus.doc} OC1200031_LEVANTA
Levanta Dados para incluir registros no Browse 

@author Andre Luis Almeida
@since 19/11/2019
@version 1.0

@type function
/*/
Static Function OC1200031_LEVANTA(lRefresh)
Local cQuery   := ""
Local cQAlSQL  := "SQLEFIC"
Local nTamUser := GetSX3Cache("VAI_CODUSR","X3_TAMANHO")
Local nPos     := 0
Local nCntFor  := 0
Local nCntFil  := 0
Local nHras    := 0
Local nMins    := 0
Local nSegs    := 0
Local aTam1    := {}
Local nLinSeg  := 0
Local nTotSeg  := 0
Local cTabP    := "" // Tabela PAI
Local cTabF    := "" // Tabela FILHO
Local cCposAgr := ""
Local cFROM    := ""
Local cWHERE   := ""
Local nQtdColunas := len(aTitCol)
Local cFilBkp  := cFilAnt
//
aVetEfic := {}
//
aAdd(aVetEfic,array(nQtdColunas))
For nCntFor := 1 to nQtdColunas
	If aTitCol[nCntFor,2] == "N"
		aVetEfic[1,nCntFor] := 0
	Else
		aVetEfic[1,nCntFor] := ""
	EndIf
Next
aVetEfic[1,1] := STR0027 // TOTAL GERAL
//
Do Case 
	Case cTpConf == "1" // Conferencia NF de Entrada
		cTabP    	:= "VM0"
		cTabF    	:= "VM1"
		cCposAgr 	:= "VM1.VM1_USRCON , VM0.VM0_DOC , VM0.VM0_SERIE , VM0.VM0_FORNEC , VM0.VM0_LOJA"
	Case cTpConf == "2" // Conferencia Oficina
		cTabP    	:= "VM3"
		cTabF    	:= "VM4"
		cCposAgr 	:= "VM4.VM4_USRCON , VM3.VM3_NUMOSV"
	Case cTpConf == "3" // Conferencia de Orcamentos
		cTabP    	:= "VM5"
		cTabF    	:= "VM6"
		cCposAgr 	:= "VM6.VM6_USRCON , VM5.VM5_NUMORC"
	Case cTpConf == "4" // Conferencia Volume de Entrada
		cTabP    	:= "VM7"
		cTabF    	:= "VM8"
		cCposAgr 	:= "VM8.VM8_USRCON , VM7.VM7_VOLUME"
EndCase
//
If !Empty(cTabP+cTabF)
	//
	nTamUser += len(cFilAnt)+1
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
		// FROM PADRAO
		cFROM := "  FROM "+RetSQLName(cTabF)+" "+cTabF+" "
		cFROM += "  JOIN "+RetSQLName(cTabP)+" "+cTabP+" ON ( "+cTabP+"."+cTabP+"_FILIAL="+cTabF+"."+cTabF+"_FILIAL AND "+cTabP+"."+cTabP+"_CODIGO="+cTabF+"."+cTabF+"_COD"+cTabP+" AND "+cTabP+"."+cTabP+"_STATUS IN ('3','4') AND "+cTabP+".D_E_L_E_T_ = ' ' ) "
		//
		// WHERE PADRAO
		cWHERE := " WHERE "+cTabF+"."+cTabF+"_FILIAL = '"+xFilial(cTabF)+"'"
		cWHERE += "   AND "+cTabF+"."+cTabF+"_DATINI >= '"+dtos(dDtIni)+"'"
		cWHERE += "   AND "+cTabF+"."+cTabF+"_DATFIN <= '"+dtos(dDtFin)+"'"
		If !Empty(cConferente)
			cWHERE += "	  AND "+cTabF+"."+cTabF+"_USRCON = '"+cConferente+"'"
		EndIf
		cWHERE += "   AND "+cTabF+".D_E_L_E_T_ = ' '"
		//
		//
		////////////////////////////////////////////////////////////
		// QUANTIDADES                                            //
		////////////////////////////////////////////////////////////
		//
		cQuery := "SELECT "+cTabF+"."+cTabF+"_USRCON AS USRCON ,"
		cQuery += "       VAI.VAI_NOMTEC ,"
		cQuery += "       COUNT(*) AS QTDTOT ,"
		cQuery += "       SUM("+cTabF+"."+cTabF+"_QTCONF) AS QTCONF "
		cQuery += cFROM  // FROM PADRAO
		cQuery += "  LEFT JOIN "+RetSQLName("VAI")+" VAI ON ( VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODUSR="+cTabF+"."+cTabF+"_USRCON AND VAI.D_E_L_E_T_=' ' ) "
		cQuery += cWHERE // WHERE PADRAO
		cQuery += " GROUP BY "+cTabF+"."+cTabF+"_USRCON , VAI.VAI_NOMTEC "
		cQuery += " ORDER BY "+cTabF+"."+cTabF+"_USRCON , VAI.VAI_NOMTEC "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
		While !(cQAlSQL)->(Eof())
			aAdd(aVetEfic,array(nQtdColunas))
			nPos := len(aVetEfic)
			For nCntFor := 1 to nQtdColunas
				If aTitCol[nCntFor,2] == "N"
					aVetEfic[nPos,nCntFor] := 0
				Else
					aVetEfic[nPos,nCntFor] := ""
				EndIf
			Next
			aVetEfic[ nPos ,  1 ] := cFilAnt+" "+(cQAlSQL)->( USRCON )+" - "+(cQAlSQL)->( VAI_NOMTEC )
			aVetEfic[ nPos , 10 ] += (cQAlSQL)->( QTDTOT )
			aVetEfic[    1 , 10 ] += (cQAlSQL)->( QTDTOT )
			aVetEfic[ nPos , 12 ] += (cQAlSQL)->( QTCONF )
			aVetEfic[    1 , 12 ] += (cQAlSQL)->( QTCONF )
			(cQAlSQL)->(dbSkip())
		EndDo
		(cQAlSQL)->(dbCloseArea())
		//
		cQuery := "SELECT TEMP."+cTabF+"_USRCON AS USRCON ,"
		cQuery += "       TEMP."+cTabP+"_STATUS AS STATUS ,"
		cQuery += "       COUNT(*) AS QTDTOT "
		cQuery += "  FROM ( "
		cQuery += "    SELECT "+cTabF+"."+cTabF+"_USRCON , "+cTabP+"."+cTabP+"_STATUS , "+cTabF+"."+cTabF+"_COD"+cTabP+" "
		cQuery += "      FROM "+RetSQLName(cTabF)+" "+cTabF+" "
		cQuery += "      JOIN "+RetSQLName(cTabP)+" "+cTabP+" ON ( "+cTabP+"."+cTabP+"_FILIAL="+cTabF+"."+cTabF+"_FILIAL AND "+cTabP+"."+cTabP+"_CODIGO="+cTabF+"."+cTabF+"_COD"+cTabP+" AND "+cTabP+"."+cTabP+"_STATUS IN ('4','5') AND "+cTabP+".D_E_L_E_T_ = ' ' ) "
		cQuery += cWHERE // WHERE PADRAO
		cQuery += "     GROUP BY "+cTabF+"."+cTabF+"_USRCON , "+cTabP+"."+cTabP+"_STATUS , "+cTabF+"."+cTabF+"_COD"+cTabP+" "
		cQuery += ") TEMP"
		cQuery += " GROUP BY TEMP."+cTabF+"_USRCON , TEMP."+cTabP+"_STATUS "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
		While !(cQAlSQL)->(Eof())
			nPos := aScan(aVetEfic,{|x| left(x[1],nTamUser) == cFilAnt+" "+(cQAlSQL)->( USRCON ) })
			If nPos > 0
				If (cQAlSQL)->( STATUS ) == '4' // Aprovados
					aVetEfic[ nPos ,  6 ] += (cQAlSQL)->( QTDTOT )
					aVetEfic[    1 ,  6 ] += (cQAlSQL)->( QTDTOT )
				Else // Reprovados
					aVetEfic[ nPos ,  8 ] += (cQAlSQL)->( QTDTOT )
					aVetEfic[    1 ,  8 ] += (cQAlSQL)->( QTDTOT )
				EndIf
			EndIf
			(cQAlSQL)->(dbSkip())
		EndDo
		(cQAlSQL)->(dbCloseArea())
		//
		cQuery := "SELECT TEMP."+cTabF+"_USRCON AS USRCON ,"
		cQuery += "       COUNT(*) AS QTDTOT "
		cQuery += "  FROM ( "
		cQuery += "    SELECT "+cTabF+"."+cTabF+"_USRCON , "+cTabF+"."+cTabF+"_COD"+cTabP+" "
		cQuery += cFROM  // FROM PADRAO
		cQuery += cWHERE // WHERE PADRAO
		cQuery += "     GROUP BY "+cTabF+"."+cTabF+"_USRCON , "+cTabF+"."+cTabF+"_COD"+cTabP+" "
		cQuery += ") TEMP"
		cQuery += " GROUP BY TEMP."+cTabF+"_USRCON"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
		While !(cQAlSQL)->(Eof())
			nPos := aScan(aVetEfic,{|x| left(x[1],nTamUser) == cFilAnt+" "+(cQAlSQL)->( USRCON ) })
			aVetEfic[ nPos ,  4 ] += (cQAlSQL)->( QTDTOT )
			aVetEfic[    1 ,  4 ] += (cQAlSQL)->( QTDTOT )
			(cQAlSQL)->(dbSkip())
		EndDo
		(cQAlSQL)->(dbCloseArea())
		//
		cQuery := "SELECT TEMP."+cTabF+"_USRCON AS USRCON ,"
		cQuery += "       COUNT(*) AS QTDTOT "
		cQuery += "  FROM ("
		cQuery += "    SELECT "+cCposAgr
		cQuery += cFROM  // FROM PADRAO
		cQuery += cWHERE // WHERE PADRAO
		cQuery += "     GROUP BY "+cCposAgr
		cQuery += ") TEMP"
		cQuery += " GROUP BY TEMP."+cTabF+"_USRCON"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
		While !(cQAlSQL)->(Eof())
			nPos := aScan(aVetEfic,{|x| left(x[1],nTamUser) == cFilAnt+" "+(cQAlSQL)->( USRCON ) })
			aVetEfic[ nPos ,  2 ] += (cQAlSQL)->( QTDTOT )
			aVetEfic[    1 ,  2 ] += (cQAlSQL)->( QTDTOT )
			(cQAlSQL)->(dbSkip())
		EndDo
		(cQAlSQL)->(dbCloseArea())
		//
		////////////////////////////////////////////////////////////
		// HORAS                                                  //
		////////////////////////////////////////////////////////////
		//
		cQuery := "SELECT "+cTabF+"."+cTabF+"_USRCON AS USRCON ,"
		cQuery += "       "+cTabF+"."+cTabF+"_DATINI AS DATINI ,"
		cQuery += "       "+cTabF+"."+cTabF+"_HORINI AS HORINI ,"
		cQuery += "       "+cTabF+"."+cTabF+"_DATFIN AS DATFIN ,"
		cQuery += "       "+cTabF+"."+cTabF+"_HORFIN AS HORFIN  "
		cQuery += cFROM  // FROM PADRAO
		cQuery += cWHERE // WHERE PADRAO
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
		While !(cQAlSQL)->(Eof())
			nPos := aScan(aVetEfic,{|x| left(x[1],nTamUser) == cFilAnt+" "+(cQAlSQL)->( USRCON ) })
			aVetEfic[ nPos , 14 ] := OC1200041_SOMAHORA( (cQAlSQL)->( DATINI ) , (cQAlSQL)->( DATFIN ) , (cQAlSQL)->( HORINI ) , (cQAlSQL)->( HORFIN ) , aVetEfic[nPos,14] )
			aVetEfic[    1 , 14 ] := OC1200041_SOMAHORA( (cQAlSQL)->( DATINI ) , (cQAlSQL)->( DATFIN ) , (cQAlSQL)->( HORINI ) , (cQAlSQL)->( HORFIN ) , aVetEfic[   1,14] )
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
////////////////////////////////////////////////////////////
// CALCULAR PERCENTUAIS                                   //
////////////////////////////////////////////////////////////
//
For nCntFor := 1 to len(aVetEfic)
	//
	aVetEfic[nCntFor,03] := ( aVetEfic[nCntFor,02] / aVetEfic[1,02] ) * 100
	aVetEfic[nCntFor,05] := ( aVetEfic[nCntFor,04] / aVetEfic[1,04] ) * 100
	aVetEfic[nCntFor,07] := ( aVetEfic[nCntFor,06] / aVetEfic[1,06] ) * 100
	aVetEfic[nCntFor,09] := ( aVetEfic[nCntFor,08] / aVetEfic[1,08] ) * 100
	aVetEfic[nCntFor,11] := ( aVetEfic[nCntFor,10] / aVetEfic[1,10] ) * 100
	aVetEfic[nCntFor,13] := ( aVetEfic[nCntFor,12] / aVetEfic[1,12] ) * 100
	//
	If !Empty(aVetEfic[nCntFor,14])
		//
		aTam1 := OC1200051_TAMHRMNSG(aVetEfic[      1,14])
		nTotSeg := ( ( val( substr( aVetEfic[      1,14],aTam1[1,1],aTam1[1,2]) ) * 60 ) * 60 ) // Horas em Segundos - Total
		nTotSeg += ( ( val( substr( aVetEfic[      1,14],aTam1[2,1],aTam1[2,2]) ) * 60 )      ) // Minutos em Segundos - Total
		nTotSeg += ( ( val( substr( aVetEfic[      1,14],aTam1[3,1],aTam1[3,2]) )      )      ) // Minutos em Segundos - Total
		//
		aTam1 := OC1200051_TAMHRMNSG(aVetEfic[nCntFor,14])
		nLinSeg := ( ( val( substr( aVetEfic[nCntFor,14],aTam1[1,1],aTam1[1,2]) ) * 60 ) * 60 ) // Horas em Segundos - Linha
		nLinSeg += ( ( val( substr( aVetEfic[nCntFor,14],aTam1[2,1],aTam1[2,2]) ) * 60 )      ) // Minutos em Segundos - Linha
		nLinSeg += ( ( val( substr( aVetEfic[nCntFor,14],aTam1[3,1],aTam1[3,2]) )      )      ) // Minutos em Segundos - Linha
		aVetEfic[nCntFor,15] := ( nLinSeg / nTotSeg ) * 100
		//
		nHras := (                                   val( substr( aVetEfic[nCntFor,14],aTam1[1,1],aTam1[1,2]) ) / aVetEfic[nCntFor,4] )
		nMins := ( ( nHras - int(nHras) ) * 60 ) + ( val( substr( aVetEfic[nCntFor,14],aTam1[2,1],aTam1[2,2]) ) / aVetEfic[nCntFor,4] )
		nSegs := ( ( nMins - int(nMins) ) * 60 ) + ( val( substr( aVetEfic[nCntFor,14],aTam1[3,1],aTam1[3,2]) ) / aVetEfic[nCntFor,4] )
		If nHras < 100
			aVetEfic[nCntFor,16] := strzero(int(nHras),2)
		ElseIf nHras < 1000
			aVetEfic[nCntFor,16] := strzero(int(nHras),3)
		ElseIf nHras < 10000
			aVetEfic[nCntFor,16] := strzero(int(nHras),4)
		EndIf
		aVetEfic[nCntFor,16] += ":"+strzero(int(nMins),2)+":"+strzero(int(nSegs),2)
		//
	EndIf
	//
	If !Empty(aVetEfic[nCntFor,16])
		//
		aTam1 := OC1200051_TAMHRMNSG(aVetEfic[      1,16])
		nTotSeg := ( ( val( substr( aVetEfic[      1,16],aTam1[1,1],aTam1[1,2]) ) * 60 ) * 60 ) // Horas em Segundos - Total
		nTotSeg += ( ( val( substr( aVetEfic[      1,16],aTam1[2,1],aTam1[2,2]) ) * 60 )      ) // Minutos em Segundos - Total
		nTotSeg += ( ( val( substr( aVetEfic[      1,16],aTam1[3,1],aTam1[3,2]) )      )      ) // Minutos em Segundos - Total
		//
		aTam1 := OC1200051_TAMHRMNSG(aVetEfic[nCntFor,16])
		nLinSeg := ( ( val( substr( aVetEfic[nCntFor,16],aTam1[1,1],aTam1[1,2]) ) * 60 ) * 60 ) // Horas em Segundos - Linha
		nLinSeg += ( ( val( substr( aVetEfic[nCntFor,16],aTam1[2,1],aTam1[2,2]) ) * 60 )      ) // Minutos em Segundos - Linha
		nLinSeg += ( ( val( substr( aVetEfic[nCntFor,16],aTam1[3,1],aTam1[3,2]) )      )      ) // Minutos em Segundos - Linha
		aVetEfic[nCntFor,17] := ( nLinSeg / nTotSeg ) * 100
		//
	EndIf
Next
//
If lRefresh
	oBrwEfic:SetArray(aVetEfic)
	oBrwEfic:Refresh()
	oBrwEfic:GoTop()
	OC1200061_GRAFICO()
EndIf

Return

/*/{Protheus.doc} OC1200041_SOMAHORA
Calculo -> Soma de Horas

@author Andre Luis Almeida
@since 19/11/2019
@version 1.0

@type function
/*/
Static Function OC1200041_SOMAHORA( sDtIni , sDtFin , cHrIni , cHrFin , cVlrInicial )
Local cTempo := ""
Local nDias  := stod(sDtFin) - stod(sDtIni)
Local aTam1  := OC1200051_TAMHRMNSG(cHrIni)
Local aTam2  := OC1200051_TAMHRMNSG(cHrFin)
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
If !Empty(cVlrInicial)
	aTam1  := OC1200051_TAMHRMNSG(cVlrInicial)
	aTam2  := OC1200051_TAMHRMNSG(cTempo)
	nHras := val(substr(cVlrInicial,aTam1[1,1],aTam1[1,2])) + val(substr(cTempo,aTam2[1,1],aTam2[1,2]))
	nMins := val(substr(cVlrInicial,aTam1[2,1],aTam1[2,2])) + val(substr(cTempo,aTam2[2,1],aTam2[2,2]))
	nSegs := val(substr(cVlrInicial,aTam1[3,1],aTam1[3,2])) + val(substr(cTempo,aTam2[3,1],aTam2[3,2]))
	While nSegs > 60
		nMins++
		nSegs -= 60
	EndDo
	While nMins > 60
		nHras++
		nMins -= 60
	EndDo
	If nHras < 100
		cTempo := strzero(nHras,2)
	ElseIf nHras < 1000
		cTempo := strzero(nHras,3)
	ElseIf nHras < 10000
		cTempo := strzero(nHras,4)
	EndIf
	cTempo += ":"+strzero(nMins,2)+":"+strzero(nSegs,2)
EndIf
Return cTempo

/*/{Protheus.doc} OC1200051_TAMHRMNSG
Retorna o tamanho do formato das Horas:Minutos:Segundos

@author Andre Luis Almeida
@since 19/11/2019
@version 1.0

@type function
/*/
Static Function OC1200051_TAMHRMNSG(cString)
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

/*/{Protheus.doc} OC1200061_GRAFICO
Montagem do Grafico na Tela

@author Andre Luis Almeida
@since 19/11/2019
@version 1.0

@type function
/*/
Static Function OC1200061_GRAFICO()
Local cMasc   := "@E 999,999,999"
Local nCntFor := 0
Local nColGraf := oBrwEfic:ColPos(.t.) // Coluna Selecionada para montagem do Grafico
If nColGraf <= 1 .or. nColGraf >= 14
	nColGraf := 2
EndIf
aDadosGraf := {}
For nCntFor := 1 to len(aVetEfic)
	If aVetEfic[nCntFor,01] <> STR0027 // TOTAL GERAL
		Aadd( aDadosGraf , { aVetEfic[nCntFor,nColGraf] , left(aVetEfic[nCntFor,01],25) } )
	EndIf
Next
If len(aDadosGraf) <= 0
	aAdd( aDadosGraf , { 0 , "" } )
EndIf
If at("%",aTitCol[nColGraf,1]) > 0
	cMasc := "@E 999.9 %"
EndIf
FG_NEWGRAF(oGrafPeq,aTitCol[nColGraf,1],aDadosGraf,.F.,cMasc)
oGrafPeq:LREADONLY := .T.
Return

/*/{Protheus.doc} OC1200071_Tela_F7_Analitico
Monta Tela com os dados referente a linha posicionada no Browse

@author Andre Luis Almeida
@since 04/05/2021
@version 1.0

@type function
/*/
Static Function OC1200071_Tela_F7_Analitico()
Local aSize   := FWGetDialogSize( oMainWnd )
Local nLinha  := oBrwEfic:AT()
Local cLinha  := aVetEfic[nLinha,1]
Local nTamFil := GetSX3Cache("VM2_FILIAL","X3_TAMANHO")
Local nTamUsr := GetSX3Cache("VAI_CODUSR","X3_TAMANHO")
Local cFilPar := substr(cLinha,1,nTamFil)
Local cUsrPar := substr(cLinha,nTamFil+2,nTamUsr)
Local aVetAna := {}
Private aAnaCol := OC1200021_TitulosCOLUNAS(2) // Colunas Analitico
Private cCadastro := STR0001+" - <F7> "+STR0030 // Eficiência das Conferências / Visualizar Dados Analiticamente
SetKey(VK_F7, nil)
If cLinha <> STR0027 // Diferente do TOTAL
	//	
	aVetAna := OC1200081_Levanta_Dados_Analiticos( cFilPar , cUsrPar )
	//
	DEFINE MSDIALOG oAnaOFIC120 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] TITLE (STR0001+" - <F7> "+STR0030) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Eficiência das Conferências / Visualizar Dados Analiticamente
		oTPanAna := TPanel():New(0,0,"",oAnaOFIC120,NIL,.T.,.F.,NIL,NIL,100,(oAnaOFIC120:nClientHeight/2)-50,.T.,.F.)
		oTPanAna:Align := CONTROL_ALIGN_BOTTOM
		oBrwAna := FWBrowse():New()
		oBrwAna:SetOwner(oTPanAna)
		oBrwAna:SetDescription(STR0029+": "+cFilPar+" - "+STR0028+": "+substr(cLinha,nTamFil+2)) // Filial / Conferente
		oBrwAna:SetProfileID("T")
		oBrwAna:SetDataArray()
		oBrwAna:SetColumns(OC1200011_MontaCol(2,aAnaCol))
		oBrwAna:SetArray(aVetAna)
		oBrwAna:Activate() // Ativação do Browse
		oBrwAna:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	ACTIVATE MSDIALOG oAnaOFIC120 ON INIT EnchoiceBar(oAnaOFIC120,{ || oAnaOFIC120:End() }, { || oAnaOFIC120:End() })
EndIf
SetKey(VK_F7,{ || OC1200071_Tela_F7_Analitico() })
Return

/*/{Protheus.doc} OC1200081_Levanta_Dados_Analiticos
Levanta Dados Analiticos

@author Andre Luis Almeida
@since 05/05/2021
@version 1.0

@type function
/*/
Static Function OC1200081_Levanta_Dados_Analiticos( cFilPar , cUsrPar )
Local cQuery   := ""
Local cQAlSQL  := "SQLANALITICO"
Local cTabP    := "" // Tabela PAI
Local cTabF    := "" // Tabela FILHO
Local cCposAgr := ""
Local cCposTmp := ""
Local cFROM    := ""
Local cWHERE   := ""
Local nPos     := 0
Local nCntFor  := 0
Local cFilBkp  := cFilAnt
Local aRetAna  := {}
Local aTam1    := {}
Local nLinSeg  := 0
Local nTotSeg  := 0
//
Do Case 
	Case cTpConf == "1" // Conferencia NF de Entrada
		cTabP    	:= "VM0"
		cTabF    	:= "VM1"
		cCposAgr 	:= "VM0.VM0_DOC , VM0.VM0_SERIE , VM0.VM0_FORNEC , VM0.VM0_LOJA , SA2.A2_NOME "
		cCposTmp 	:= "TEMP.VM0_DOC , TEMP.VM0_SERIE , TEMP.VM0_FORNEC , TEMP.VM0_LOJA , TEMP.A2_NOME "
	Case cTpConf == "2" // Conferencia Oficina
		cTabP    	:= "VM3"
		cTabF    	:= "VM4"
		cCposAgr 	:= "VM3.VM3_NUMOSV"
		cCposTmp 	:= "TEMP.VM3_NUMOSV"
	Case cTpConf == "3" // Conferencia de Orcamentos
		cTabP    	:= "VM5"
		cTabF    	:= "VM6"
		cCposAgr 	:= "VM5.VM5_NUMORC"
		cCposTmp 	:= "TEMP.VM5_NUMORC"
	Case cTpConf == "4" // Conferencia Volume de Entrada
		cTabP    	:= "VM7"
		cTabF    	:= "VM8"
		cCposAgr 	:= "VM7.VM7_VOLUME"
		cCposTmp 	:= "TEMP.VM7_VOLUME"
EndCase
//
aAdd(aRetAna,{STR0027,0,0,0,0,0,0,0,0,0,0,0,0}) // TOTAL GERAL
//
If !Empty(cTabP+cTabF)
	//
	cFilAnt := cFilPar
	//
	// FROM PADRAO
	cFROM := "  FROM "+RetSQLName(cTabF)+" "+cTabF+" "
	cFROM += "  JOIN "+RetSQLName(cTabP)+" "+cTabP+" ON ( "+cTabP+"."+cTabP+"_FILIAL="+cTabF+"."+cTabF+"_FILIAL AND "+cTabP+"."+cTabP+"_CODIGO="+cTabF+"."+cTabF+"_COD"+cTabP+" AND "+cTabP+"."+cTabP+"_STATUS IN ('3','4') AND "+cTabP+".D_E_L_E_T_ = ' ' ) "
	If cTpConf == "1" // Conferencia NF de Entrada
		cFROM += " LEFT JOIN "+RetSQLName("SA2")+" SA2 ON ( SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD=VM0.VM0_FORNEC AND SA2.A2_LOJA=VM0.VM0_LOJA AND SA2.D_E_L_E_T_ = ' ' ) "
	EndIf
	//
	// WHERE PADRAO
	cWHERE := " WHERE "+cTabF+"."+cTabF+"_FILIAL = '"+xFilial(cTabF)+"'"
	cWHERE += "   AND "+cTabF+"."+cTabF+"_DATINI >= '"+dtos(dDtIni)+"'"
	cWHERE += "   AND "+cTabF+"."+cTabF+"_DATFIN <= '"+dtos(dDtFin)+"'"
	cWHERE += "	  AND "+cTabF+"."+cTabF+"_USRCON = '"+cUsrPar+"'"
	cWHERE += "   AND "+cTabF+".D_E_L_E_T_ = ' '"
	//
	////////////////////////////////////////////////////////////
	// QUANTIDADES                                            //
	////////////////////////////////////////////////////////////
	cQuery := "SELECT "+cCposAgr+" ,"
	cQuery += "       COUNT(*) AS QTDTOT ,"
	cQuery += "       SUM("+cTabF+"."+cTabF+"_QTCONF) AS QTCONF "
	cQuery += cFROM  // FROM PADRAO
	cQuery += cWHERE // WHERE PADRAO
	cQuery += " GROUP BY "+cCposAgr
	cQuery += " ORDER BY "+cCposAgr
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
	While !(cQAlSQL)->(Eof())
		aAdd(aRetAna,{"",0,0,0,0,0,0,0,0,0,0,0,0})
		nPos := len(aRetAna)
		Do Case
			Case cTpConf == "1" // Conferencia NF de Entrada
				aRetAna[ nPos , 1 ] := (cQAlSQL)->( VM0_DOC )+"-"+(cQAlSQL)->( VM0_SERIE )+" "+(cQAlSQL)->( VM0_FORNEC )+"-"+(cQAlSQL)->( VM0_LOJA )+" "+(cQAlSQL)->( A2_NOME )
			Case cTpConf == "2" // Conferencia Oficina
				aRetAna[ nPos , 1 ] := (cQAlSQL)->( VM3_NUMOSV )
			Case cTpConf == "3" // Conferencia de Orcamentos
				aRetAna[ nPos , 1 ] := (cQAlSQL)->( VM5_NUMORC )
			Case cTpConf == "4" // Conferencia Volume de Entrada
				aRetAna[ nPos , 1 ] := (cQAlSQL)->( VM7_VOLUME )
		EndCase
		aRetAna[ nPos , 08 ] += (cQAlSQL)->( QTDTOT )
		aRetAna[    1 , 08 ] += (cQAlSQL)->( QTDTOT )
		aRetAna[ nPos , 10 ] += (cQAlSQL)->( QTCONF )
		aRetAna[    1 , 10 ] += (cQAlSQL)->( QTCONF )
		(cQAlSQL)->(dbSkip())
	EndDo
	(cQAlSQL)->(dbCloseArea())
	//
	cQuery := "SELECT "+cCposTmp+" , TEMP."+cTabP+"_STATUS AS STATUS ,"
	cQuery += "       COUNT(*) AS QTDTOT "
	cQuery += "  FROM ( "
	cQuery += "    SELECT "+cCposAgr+" , "+cTabP+"."+cTabP+"_STATUS , "+cTabF+"."+cTabF+"_COD"+cTabP+" "
	cQuery += "      FROM "+RetSQLName(cTabF)+" "+cTabF+" "
	cQuery += "      JOIN "+RetSQLName(cTabP)+" "+cTabP+" ON ( "+cTabP+"."+cTabP+"_FILIAL="+cTabF+"."+cTabF+"_FILIAL AND "+cTabP+"."+cTabP+"_CODIGO="+cTabF+"."+cTabF+"_COD"+cTabP+" AND "+cTabP+"."+cTabP+"_STATUS IN ('4','5') AND "+cTabP+".D_E_L_E_T_ = ' ' ) "
	If cTpConf == "1" // Conferencia NF de Entrada
		cQuery += " LEFT JOIN "+RetSQLName("SA2")+" SA2 ON ( SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD=VM0.VM0_FORNEC AND SA2.A2_LOJA=VM0.VM0_LOJA AND SA2.D_E_L_E_T_ = ' ' ) "
	EndIf
	cQuery += cWHERE // WHERE PADRAO
	cQuery += "     GROUP BY "+cCposAgr+" , "+cTabP+"."+cTabP+"_STATUS , "+cTabF+"."+cTabF+"_COD"+cTabP+" "
	cQuery += ") TEMP"
	cQuery += " GROUP BY "+cCposTmp+" , TEMP."+cTabP+"_STATUS"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
	While !(cQAlSQL)->(Eof())
		// Posicionamento
		Do Case
			Case cTpConf == "1" // Conferencia NF de Entrada
				nPos := aScan(aRetAna,{|x| x[1] == (cQAlSQL)->( VM0_DOC )+"-"+(cQAlSQL)->( VM0_SERIE )+" "+(cQAlSQL)->( VM0_FORNEC )+"-"+(cQAlSQL)->( VM0_LOJA )+" "+(cQAlSQL)->( A2_NOME ) })
			Case cTpConf == "2" // Conferencia Oficina
				nPos := aScan(aRetAna,{|x| x[1] == (cQAlSQL)->( VM3_NUMOSV ) })
			Case cTpConf == "3" // Conferencia de Orcamentos
				nPos := aScan(aRetAna,{|x| x[1] == (cQAlSQL)->( VM5_NUMORC ) })
			Case cTpConf == "4" // Conferencia Volume de Entrada
				nPos := aScan(aRetAna,{|x| x[1] == (cQAlSQL)->( VM7_VOLUME ) })
		EndCase
		If nPos > 0
			If (cQAlSQL)->( STATUS ) == '4' // Aprovados
				aRetAna[ nPos ,  4 ] += (cQAlSQL)->( QTDTOT )
				aRetAna[    1 ,  4 ] += (cQAlSQL)->( QTDTOT )
			Else // Reprovados
				aRetAna[ nPos ,  6 ] += (cQAlSQL)->( QTDTOT )
				aRetAna[    1 ,  6 ] += (cQAlSQL)->( QTDTOT )
			EndIf
		EndIf
		(cQAlSQL)->(dbSkip())
	EndDo
	(cQAlSQL)->(dbCloseArea())
	//
	cQuery := "SELECT "+cCposTmp+" , COUNT(*) AS QTDTOT "
	cQuery += "  FROM ( "
	cQuery += "    SELECT "+cCposAgr+" , "+cTabF+"."+cTabF+"_COD"+cTabP+" "
	cQuery += cFROM  // FROM PADRAO
	cQuery += cWHERE // WHERE PADRAO
	cQuery += "     GROUP BY "+cCposAgr+" , "+cTabF+"."+cTabF+"_COD"+cTabP+" "
	cQuery += ") TEMP"
	cQuery += " GROUP BY "+cCposTmp
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
	While !(cQAlSQL)->(Eof())
		// Posicionamento
		Do Case
			Case cTpConf == "1" // Conferencia NF de Entrada
				nPos := aScan(aRetAna,{|x| x[1] == (cQAlSQL)->( VM0_DOC )+"-"+(cQAlSQL)->( VM0_SERIE )+" "+(cQAlSQL)->( VM0_FORNEC )+"-"+(cQAlSQL)->( VM0_LOJA )+" "+(cQAlSQL)->( A2_NOME ) })
			Case cTpConf == "2" // Conferencia Oficina
				nPos := aScan(aRetAna,{|x| x[1] == (cQAlSQL)->( VM3_NUMOSV ) })
			Case cTpConf == "3" // Conferencia de Orcamentos
				nPos := aScan(aRetAna,{|x| x[1] == (cQAlSQL)->( VM5_NUMORC ) })
			Case cTpConf == "4" // Conferencia Volume de Entrada
				nPos := aScan(aRetAna,{|x| x[1] == (cQAlSQL)->( VM7_VOLUME ) })
		EndCase
		aRetAna[ nPos ,  2 ] += (cQAlSQL)->( QTDTOT )
		aRetAna[    1 ,  2 ] += (cQAlSQL)->( QTDTOT )
		(cQAlSQL)->(dbSkip())
	EndDo
	(cQAlSQL)->(dbCloseArea())
	//
	////////////////////////////////////////////////////////////
	// HORAS                                                  //
	////////////////////////////////////////////////////////////
	//
	cQuery := "SELECT "+cCposAgr+" , "
	cQuery += "       "+cTabF+"."+cTabF+"_DATINI AS DATINI ,"
	cQuery += "       "+cTabF+"."+cTabF+"_HORINI AS HORINI ,"
	cQuery += "       "+cTabF+"."+cTabF+"_DATFIN AS DATFIN ,"
	cQuery += "       "+cTabF+"."+cTabF+"_HORFIN AS HORFIN  "
	cQuery += cFROM  // FROM PADRAO
	cQuery += cWHERE // WHERE PADRAO
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
	While !(cQAlSQL)->(Eof())
		// Posicionamento
		Do Case
			Case cTpConf == "1" // Conferencia NF de Entrada
				nPos := aScan(aRetAna,{|x| x[1] == (cQAlSQL)->( VM0_DOC )+"-"+(cQAlSQL)->( VM0_SERIE )+" "+(cQAlSQL)->( VM0_FORNEC )+"-"+(cQAlSQL)->( VM0_LOJA )+" "+(cQAlSQL)->( A2_NOME ) })
			Case cTpConf == "2" // Conferencia Oficina
				nPos := aScan(aRetAna,{|x| x[1] == (cQAlSQL)->( VM3_NUMOSV ) })
			Case cTpConf == "3" // Conferencia de Orcamentos
				nPos := aScan(aRetAna,{|x| x[1] == (cQAlSQL)->( VM5_NUMORC ) })
			Case cTpConf == "4" // Conferencia Volume de Entrada
				nPos := aScan(aRetAna,{|x| x[1] == (cQAlSQL)->( VM7_VOLUME ) })
		EndCase
		aRetAna[ nPos , 12 ] := OC1200041_SOMAHORA( (cQAlSQL)->( DATINI ) , (cQAlSQL)->( DATFIN ) , (cQAlSQL)->( HORINI ) , (cQAlSQL)->( HORFIN ) , aRetAna[nPos,12] )
		aRetAna[    1 , 12 ] := OC1200041_SOMAHORA( (cQAlSQL)->( DATINI ) , (cQAlSQL)->( DATFIN ) , (cQAlSQL)->( HORINI ) , (cQAlSQL)->( HORFIN ) , aRetAna[   1,12] )
		(cQAlSQL)->(dbSkip())
	EndDo
	(cQAlSQL)->(dbCloseArea())
	//
	cFilAnt := cFilBkp
	//
EndIf
//
////////////////////////////////////////////////////////////
// CALCULAR PERCENTUAIS                                   //
////////////////////////////////////////////////////////////
//
For nCntFor := 1 to len(aRetAna)
	//
	aRetAna[nCntFor,03] := ( aRetAna[nCntFor,02] / aRetAna[1,02] ) * 100
	aRetAna[nCntFor,05] := ( aRetAna[nCntFor,04] / aRetAna[1,04] ) * 100
	aRetAna[nCntFor,07] := ( aRetAna[nCntFor,06] / aRetAna[1,06] ) * 100
	aRetAna[nCntFor,09] := ( aRetAna[nCntFor,08] / aRetAna[1,08] ) * 100
	aRetAna[nCntFor,11] := ( aRetAna[nCntFor,10] / aRetAna[1,10] ) * 100
	//
	If !Empty(aRetAna[nCntFor,12])
		//
		aTam1 := OC1200051_TAMHRMNSG(aRetAna[      1,12])
		nTotSeg := ( ( val( substr( aRetAna[      1,12],aTam1[1,1],aTam1[1,2]) ) * 60 ) * 60 ) // Horas em Segundos - Total
		nTotSeg += ( ( val( substr( aRetAna[      1,12],aTam1[2,1],aTam1[2,2]) ) * 60 )      ) // Minutos em Segundos - Total
		nTotSeg += ( ( val( substr( aRetAna[      1,12],aTam1[3,1],aTam1[3,2]) )      )      ) // Minutos em Segundos - Total
		//
		aTam1 := OC1200051_TAMHRMNSG(aRetAna[nCntFor,12])
		nLinSeg := ( ( val( substr( aRetAna[nCntFor,12],aTam1[1,1],aTam1[1,2]) ) * 60 ) * 60 ) // Horas em Segundos - Linha
		nLinSeg += ( ( val( substr( aRetAna[nCntFor,12],aTam1[2,1],aTam1[2,2]) ) * 60 )      ) // Minutos em Segundos - Linha
		nLinSeg += ( ( val( substr( aRetAna[nCntFor,12],aTam1[3,1],aTam1[3,2]) )      )      ) // Minutos em Segundos - Linha
		aRetAna[nCntFor,13] := ( nLinSeg / nTotSeg ) * 100
		//
	EndIf
	//
Next
//
Return aClone(aRetAna)