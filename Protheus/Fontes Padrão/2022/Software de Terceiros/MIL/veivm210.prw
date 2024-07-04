// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 4      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"

#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#DEFINE DATAFLUXO				1
#DEFINE ENTRADAS				2
#DEFINE SAIDAS					3
#DEFINE SALDODIA				4
#DEFINE VARIACAODIA				5
#DEFINE ENTRADASACUMULADAS		6
#DEFINE SAIDASACUMULADAS 		7
#DEFINE SALDOACUMULADO 			8
#DEFINE VARIACAOACUMULADA		9

Static cGetVersao := GetVersao(.f.,.f.)

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006248_1"

Function VEIVM210()
Return

Function FC020DMSCOMPRA(cAliasDMSCompra,aTotais,lRegua,nMoeda,aPeriodo,cFilIni,cFilFin,lConsDtBase,lFiliais,aSelFil,nPosTotal )

	LOCAL cNumPed
	Local nValTot :=0
	Local nValIpi :=0
	Local nPrcCompra
	LOCAL dData
	LOCAL nTotDesc
	LOCAL cFilDe
	LOCAL cFilAte
	LOCAL cSaveFil := cFilAnt
	LOCAL aSaveArea:= SM0->(GetArea())
	LOCAL nAscan
	Local dDataFluxo
	LOCAL nDespFrete := 0
	LOCAL nInc		 := 0

	LOCAL aSM0		:= AdmAbreSM0()
	Local aAuxSM0	:={}
	Local cLstFiliais := ""
	Local aCachDt	:= {}

	LOCAL nI := 0
	LOCAL cQuery
	LOCAL aStru := VQ0->(dbStruct())
	LOCAL lVQ0_FLUXO := ( VQ0->(FieldPos("VQ0_FLUXO")) > 0 )
	
	Local dDatRef := ctod("")
	Local aData := {}
	Local nPos  := 0
	Local aDataAux := {}
	Local dDataAux := ""
	
	Local cMV_GRUVEI := Padr(GetMv("MV_GRUVEI"),TamSX3("B1_GRUPO")[1])

	DEFAULT nMoeda := 1
	DEFAULT cFilIni := Space( FWGETTAMFILIAL)
	DEFAULT cFilFin := Replicate( "Z", FWGETTAMFILIAL)
	DEFAULT lConsDtBase := .f.
	DEFAULT lFiliais := .F.
	DEFAULT aSelFil := {}
	DEFAULT nPosTotal := 11

	//----------------------------------//
	If mv_par03 == 2		// por empresa
		cFilDe := cFilIni
		cFilAte := cFilFin
	Else						// por filial
		cFilDe := cFilAnt
		cFilAte := cFilAnt
	Endif

	If cGetVersao < "12"
		nPosTotal := 12
		If lFiliais
			cLstFiliais := ArrayToStr(aSelFil)
		EndIf
	EndIf

	For nInc := 1 To Len( aSM0 )
		If aSM0[nInc][1] == cEmpAnt .AND. ;
			If( EMPTY(cLstFiliais),;
				(Alltrim(aSM0[nInc][2]) >= Alltrim(cFilDe) .and. Alltrim(aSM0[nInc][2]) <= Alltrim(cFilAte)),;
				(aSM0[nInc][2] $ cLstFiliais);
				)

			cFilAnt := aSM0[nInc][2]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ler Pedidos de Compra													  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("VQ0")
			VQ0->(dbSetOrder(1))
			cQuery := "SELECT VQ0.* "
			cQuery += "  FROM " + RetSqlName("VQ0") + " VQ0"
			cQuery += "  LEFT JOIN " + RetSqlName("SB1") + " SB1"
			cQuery += "    ON  SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
			cQuery += "    AND SB1.B1_GRUPO = '"+cMV_GRUVEI+"'"
			cQuery += "    AND SB1.B1_CODITE = VQ0.VQ0_CHAINT"
			cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
			cQuery += "  WHERE VQ0.VQ0_FILIAL = '" + xFilial("VQ0") + "'"
			cQuery += "    AND VQ0.VQ0_FILPED = '" + cFilAnt + "'"
			If lVQ0_FLUXO
				cQuery += "    AND VQ0.VQ0_FLUXO IN (' ','S') "
			EndIf			
			cQuery += "    AND VQ0.D_E_L_E_T_ = ' ' "
			cQuery += "    AND ( SB1.B1_COD IS NULL "  
			cQuery += "     OR SB1.B1_COD NOT IN "
			cQuery += "      ( SELECT SD1.D1_COD "
			cQuery += "          FROM " + RetSqlName("SD1") + " SD1"
			cQuery += "          JOIN " + RetSqlName("SF4") + " SF4"
			cQuery += "            ON  SF4.F4_FILIAL = '" + xFilial("SF4") + "'"
			cQuery += "            AND SF4.F4_CODIGO = SD1.D1_TES"
			cQuery += "            AND SF4.F4_OPEMOV = '01'"
			cQuery += "            AND SF4.D_E_L_E_T_ = ' ' "
			cQuery += "          WHERE SD1.D1_COD = SB1.B1_COD " // QUALQUER FILIAL - BUSCA SOMENTE PELO CODIGO DO PRODUTO VEICULO
			cQuery += "            AND SD1.D_E_L_E_T_ = ' ' )"
			cQuery += "      )"

			dbSelectArea("VQ0")
			dbCloseArea()
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'VQ0', .F., .T.)

			For nI := 1 to Len(aStru)
				If aStru[nI,2] != 'C'
					TCSetField('VQ0', aStru[nI,1], aStru[nI,2],aStru[nI,3],aStru[nI,4])
				Endif
			Next

			While VQ0->(!Eof()) .and. VQ0->VQ0_FILIAL == xFilial("VQ0")

				cNumPed := VQ0->VQ0_NUMPED
				nValTot := 0
				nDespFrete := 0

				If lRegua != Nil .and. lRegua
					IncProc("Processando Pedidos de Compra de Maquinas") // "Processando Pedidos de Compra de Maquinas"
				Endif

				If lVQ0_FLUXO
					dDatRef := VQ0->VQ0_DATFLU // Data para entrar no Fluxo
				Else
					dDatRef := VQ0->VQ0_DATPED // Data do Pedido
				EndIf

				dData := dDatRef
				nPos := Ascan(aData, { |x| x[1] == dDatRef } )
				If nPos == 0
					dData := DataValida(dDatRef)
					aadd(aData, {dDatRef, dData})
				EndIf

				If !lConsDtBase
					If nPos > 0
						dData := adata[nPos][2]
					Endif
				Else
					dData := Iif( dDatRef < dDataBase, dDataBase, dData )
				Endif

				nPrcCompra 	:= VQ0->VQ0_VALCUS

				nDespFrete := 0
				nValTot	  := ( nPrcCompra ) + nDespFrete
				nValIPI	  := 0

				nValTot  += nValIPI

				nL := Ascan(aDMSCompras,{|e| e[1] == dData } )
				IF nL == 0
					AADD(aDMSCompras,{ dData , nValTot })
				Else
					aDMSCompras[nL][2] += nValTot
				EndIf

				// Se foi enviado o arquivo temporario para geracao do fluxo
				// de caixa analitico, gera o pedido de compra neste arquivo
				If cAliasDMSCompra != Nil
					DbSelectArea(cAliasDMSCompra)
					dDataFluxo := dData
					nAscan := Ascan(aPeriodo, {|e| e[1] == dDataFluxo})
					// Se a data do pedido ja venceu, insere na primeira data do fluxo
					If dDataFluxo < aPeriodo[1][1]
						dDataFluxo := aPeriodo[1][1]
						nAscan := 1
					Endif
					If nAscan > 0
						If !dbSeek(dTos(dDataFluxo) + VQ0->VQ0_CODIGO)
							RecLock(cAliasDMSCompra,.T.)
							(cAliasDMSCompra)->DATAX  := dDataFluxo
							(cAliasDMSCompra)->Periodo:= aPeriodo[nAscan][2]

							(cAliasDMSCompra)->NUMERO  := VQ0->VQ0_CODIGO
							(cAliasDMSCompra)->PEDFAB  := VQ0->VQ0_NUMPED
							(cAliasDMSCompra)->EMISSAO := dDatRef
							(cAliasDMSCompra)->CHASSI  := VQ0->VQ0_CHASSI
							(cAliasDMSCompra)->MODELO  := VQ0->VQ0_CODMAR+" "+VQ0->VQ0_MODVEI

						Else
							RecLock(cAliasDMSCompra,.F.)
						Endif
						(cAliasDMSCompra)->SALDO += VQ0->VQ0_VALCUS

						// Pesquisa na matriz de totais, os totais de pedidos de compra
						// da data de trabalho.
						If aTotais # Nil
							nAscan := Ascan( aTotais[nPosTotal], {|e| e[1] == (cAliasDMSCompra)->DATAX})
							If nAscan == 0
								Aadd( aTotais[nPosTotal], { (cAliasDMSCompra)->DATAX , VQ0->VQ0_VALCUS })
							Else
								aTotais[nPosTotal][nAscan][2] += VQ0->VQ0_VALCUS //(cAliasPc)->SALDO // Totaliza os pedidos de compra
							Endif
						Endif
					Endif
				EndIf

				VQ0->(dbSkip())

			Enddo
			dbSelectArea("VQ0")
			dbCloseArea()
			ChKFile("VQ0")
			dbSelectArea("VQ0")
			dbSetOrder(1)
		EndIf
	Next

	cFilAnt := cSaveFil // recupera variavel cFilAnt

	aSize(aData, 0 )
	aData := NIL
	aSize(aCachDt, 0)
	aCachDt := NIL

Return .T.


Function FC020DMSVENDA(cAliasDMSVenda,aTotais,lRegua,nMoeda,aPeriodo,cFilIni,cFilFin,lConsDtBase,lFiliais,aSelFil,nPosTotal)

	LOCAL cNumPed
	Local nValTot :=0
	Local nValIpi :=0
	Local nPrcCompra
	LOCAL dData
	LOCAL nTotDesc
	LOCAL cFilDe
	LOCAL cFilAte
	LOCAL cSaveFil := cFilAnt
	LOCAL aSaveArea:= SM0->(GetArea())
	LOCAL nAscan
	Local dDataFluxo
	LOCAL nDespFrete := 0
	LOCAL nInc		 := 0

	LOCAL aSM0		:= AdmAbreSM0()
	Local aAuxSM0	:={}
	Local cLstFiliais := ""
	Local aCachDt	:= {}

	LOCAL nI := 0
	LOCAL cQuery
	LOCAL aStru := VS9->(dbStruct())
	LOCAL lVV0_FLUXO  := ( VV0->(FieldPos("VV0_FLUXO"))  > 0 )
	LOCAL lVV0_TIPDOC := ( VV0->(FieldPos("VV0_TIPDOC")) > 0 )

	Local aData := {}
	Local nPos  := 0
	Local aDataAux := {}
	Local dDataAux := ""

	DEFAULT nMoeda := 1
	DEFAULT cFilIni := "  "
	DEFAULT cFilFin := "zz"
	DEFAULT lConsDtBase := .f.
	DEFAULT lFiliais := .F.
	DEFAULT aSelFil := {}
	DEFAULT nPosTotal := 12

	//----------------------------------//
	If mv_par03 == 2		// por empresa
		cFilDe := cFilIni
		cFilAte := cFilFin
	Else						// por filial
		cFilDe := cFilAnt
		cFilAte := cFilAnt
	Endif

	If cGetVersao < "12"
		nPosTotal := 13
	EndIf

	If lFiliais
		cLstFiliais := ArrayToStr(aSelFil)
	EndIf

	For nInc := 1 To Len( aSM0 )
		If aSM0[nInc][1] == cEmpAnt .AND. ;
			If( EMPTY(cLstFiliais),;
				(Alltrim(aSM0[nInc][2]) >= Alltrim(cFilDe) .and. Alltrim(aSM0[nInc][2]) <= Alltrim(cFilAte)),;
				(aSM0[nInc][2] $ cLstFiliais);
				)

			cFilAnt := aSM0[nInc][2]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ler Pedidos de Compra													  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("VS9")
			VS9->(dbSetOrder(1))
			cQuery := "SELECT VS9.* , VV9.VV9_CODCLI , VV9.VV9_LOJA , VV9.VV9_NOMVIS , SA1.A1_NOME "
			cQuery += " FROM " + RetSQLName("VV0") + " VV0" 
			cQuery += " JOIN " + RetSQLName("VS9") + " VS9 "
			cQuery += "     ON  VS9.VS9_FILIAL = '" + xFilial("VS9" ) + "' " 
			cQuery += "     AND VS9.VS9_TIPOPE = 'V' "
			cQuery += "     AND VS9.VS9_NUMIDE = VV0.VV0_NUMTRA "
			cQuery += "     AND VS9.D_E_L_E_T_ = ' ' "
			cQuery += " JOIN " + RetSQLName("VV9") + " VV9 "
			cQuery += "     ON  VV9.VV9_FILIAL = VV0.VV0_FILIAL "
			cQuery += "     AND VV9.VV9_NUMATE = VV0.VV0_NUMTRA "
			cQuery += "     AND VV9.VV9_STATUS <> 'C' "
			cQuery += "     AND VV9.D_E_L_E_T_ = ' ' "
			cQuery += " LEFT JOIN " + RetSQLName("SA1") + " SA1 "
			cQuery += "     ON  SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
			cQuery += "     AND SA1.A1_COD = VV9.VV9_CODCLI "
			cQuery += "     AND SA1.A1_LOJA = VV9.VV9_LOJA "
			cQuery += "     AND SA1.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE VV0.VV0_FILIAL = '" + xFilial("VV0") + "' "
			cQuery += "     AND VV0.VV0_OPEMOV = '0'"
			cQuery += "     AND VV0.VV0_NUMNFI = ' '"
			cQuery += "     AND VV0.VV0_SERNFI = ' '"
			If lVV0_FLUXO
				cQuery += " AND VV0.VV0_FLUXO  = 'S'"
			EndIf
			If lVV0_TIPDOC
				cQuery += " AND VV0.VV0_TIPDOC <> '2'"
			EndIf
			cQuery += "     AND VV0.D_E_L_E_T_ = ' '"
			cQuery += " ORDER BY VS9.VS9_DATPAG , VS9.VS9_NUMIDE , VS9.VS9_TIPPAG"
			dbSelectArea("VS9")
			dbCloseArea()
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'VS9', .F., .T.)

			For nI := 1 to Len(aStru)
				If aStru[nI,2] != 'C'
					TCSetField('VS9', aStru[nI,1], aStru[nI,2],aStru[nI,3],aStru[nI,4])
				Endif
			Next

			While VS9->(!Eof()) .and. VS9->VS9_FILIAL == xFilial("VS9")

				cNumPed := VS9->VS9_NUMIDE
				nValTot := 0
				nDespFrete := 0

				If lRegua != Nil .and. lRegua
					IncProc("Processando Pedidos de Venda de Maquinas") // "Processando Pedidos de Venda de Maquinas"
				Endif

				dData := VS9->VS9_DATPAG
				nPos := Ascan(aData, { |x| x[1] == VS9->VS9_DATPAG } )
				If nPos == 0
					dData := DataValida(VS9->VS9_DATPAG)
					aadd(aData, {VS9->VS9_DATPAG, dData})
				EndIf

				If !lConsDtBase
					If nPos > 0
						dData := adata[nPos][2]
					Endif
				Else
					dData := Iif( VS9->VS9_DATPAG < dDataBase, dDataBase, dData )
				Endif

				nDespFrete := 0
				nValTot	  := VS9->VS9_VALPAG
				nValIPI	  := 0

				nValTot  += nValIPI

				nL := Ascan(aDMSVendas,{|e| e[1] == dData } )
				IF nL == 0
					AADD(aDMSVendas,{ dData , nValTot })
				Else
					aDMSVendas[nL][2] += nValTot
				EndIf

				// Se foi enviado o arquivo temporario para geracao do fluxo
				// de caixa analitico, gera o pedido de compra neste arquivo
				If cAliasDMSVenda != Nil
					DbSelectArea(cAliasDMSVenda)
					dDataFluxo := dData
					nAscan := Ascan(aPeriodo, {|e| e[1] == dDataFluxo})
					// Se a data do pedido ja venceu, insere na primeira data do fluxo
					If dDataFluxo < aPeriodo[1][1]
						dDataFluxo := aPeriodo[1][1]
						nAscan := 1
					Endif
					If nAscan > 0
						If !dbSeek(dTos(dDataFluxo) + VS9->VS9_NUMIDE)
							RecLock(cAliasDMSVenda,.T.)
							(cAliasDMSVenda)->DATAX  := dDataFluxo
							(cAliasDMSVenda)->Periodo:= aPeriodo[nAscan][2]
							(cAliasDMSVenda)->NUMERO    := VS9->VS9_NUMIDE
							(cAliasDMSVenda)->EMISSAO   := VS9->VS9_DATPAG
							(cAliasDMSVenda)->CLIFOR    := VS9->VV9_CODCLI
							(cAliasDMSVenda)->LOJACLI   := VS9->VV9_LOJA
							(cAliasDMSVenda)->NomCliFor := IIf(!Empty(VS9->A1_NOME),VS9->A1_NOME,VS9->VV9_NOMVIS)
						Else
							RecLock(cAliasDMSVenda,.F.)
						Endif
						(cAliasDMSVenda)->SALDO += VS9->VS9_VALPAG

						// Pesquisa na matriz de totais, os totais de pedidos de compra
						// da data de trabalho.
						If aTotais # Nil
							nAscan := Ascan( aTotais[nPosTotal], {|e| e[1] == (cAliasDMSVenda)->DATAX})
							If nAscan == 0
								Aadd( aTotais[nPosTotal], { (cAliasDMSVenda)->DATAX , VS9->VS9_VALPAG })
							Else
								aTotais[nPosTotal][nAscan][2] += VS9->VS9_VALPAG //(cAliasPc)->SALDO // Totaliza os pedidos de venda
							Endif
						Endif
					Endif
				EndIf

				VS9->(dbSkip())

			Enddo
			dbSelectArea("VS9")
			dbCloseArea()
			ChKFile("VS9")
			dbSelectArea("VS9")
			dbSetOrder(1)
		EndIf
	Next

	cFilAnt := cSaveFil // recupera variavel cFilAnt

	aSize(aData, 0 )
	aData := NIL
	aSize(aCachDt, 0)
	aCachDt := NIL

Return .T.

Function VM210FluxoAna(cTipo)

	Local aAuxHeader := {}

	Do Case
	Case cTipo == "MAQ_COMPRA"
		Aadd( aAuxHeader , { "Numero"               , "Numero"    , ""                 , TamSx3("VQ0_CODIGO")[1] , 0 , ".F.", USADO, "C",, "V" } ) // "Numero"
		Aadd( aAuxHeader , { RetTitle("VQ0_NUMPED") , "Pedido"    , ""                 , TamSx3("VQ0_NUMPED")[1] , 0 , ".F.", USADO, "C",, "V" } ) // "Pedido"
		Aadd( aAuxHeader , { "Dt. Pagto."           , "Emissao"   , ""                 , 8                       , 0 , ".F.", USADO, "C",, "V" } ) // "Emissao"
		Aadd( aAuxHeader , { "Chassi"               , "Chassi"    , ""                 , TamSx3("VQ0_CHASSI")[1] , 0 , ".F.", USADO, "C",, "V" } ) // "Chassi"
		Aadd( aAuxHeader , { "Marca/Modelo"         , "Modelo"    , ""                 , TamSx3("VQ0_CODMAR")[1]+TamSx3("VQ0_MODVEI")[1] , 0 , ".F.", USADO, "C",, "V" } ) // "Marca/Modelo"
		Aadd( aAuxHeader , { "Valor"                , "Saldo"     , "@e 999,999,999.99", 15                      , 2 , ".T.", USADO, "N",, "V" } ) // "Valor"
		Aadd( aAuxHeader , { ""						, "CampoNulo" , ""                 , 1                       , 0 , ".T.", USADO, "C",, "V" } )

	Case cTipo == "MAQ_VENDA"
		Aadd( aAuxHeader , { "Numero"               , "Numero"    , ""                 ,  , 0 , ".F.", USADO, "C",, "V" } ) //"Numero"
		Aadd( aAuxHeader , { RetTitle("VV0_NUMTRA") , "Pedido"    , ""                 ,  , 0 , ".F.", USADO, "C",, "V" } ) //"Cliente"
		Aadd( aAuxHeader , { "Emissão"              , "Emissao"   , ""                 , 8                             , 0 , ".F.", USADO, "C",, "V" } ) //"Emissao"
		Aadd( aAuxHeader , { RetTitle("VV0_CODCLI") , "CliFor"    , ""                 , TamSX3("VV0_CODCLI")[1]  , 0, ".F.", USADO, "C",, "V" } ) //"Cliente"
		Aadd( aAuxHeader , { RetTitle("VV0_LOJA"  ) , "LojaCli"   , ""                 , TamSX3("VV0_LOJA"  )[1]  , 0, ".F.", USADO, "C",, "V" } ) //"Nome"
		Aadd( aAuxHeader , { RetTitle("VV0_NOMCLI") , "NomCliFor" , ""                 , TamSX3("VV0_NOMCLI")[1]  , 0, ".F.", USADO, "C",, "V" } ) //"Loja Cliente"
		Aadd( aAuxHeader , { "Valor"                , "Saldo"     , "@e 999,999,999.99", 15                            , 2 , ".T.", USADO, "N",, "V" } ) //"Valor"
		Aadd( aAuxHeader , { ""                     , "CampoNulo" , ""                 , 1                             , 0 , ".T.", USADO, "C",, "V" } )
	End Do

Return aAuxHeader

Function VM210CriaTmpAna(cTipo)

	Local aCposArquivo := {}
	Local cAliasAna := ""

	Do Case
	Case cTipo == "MAQ_COMPRA"
		Aadd( aCposArquivo , { "Periodo", "C",  25, 0 } )
		Aadd( aCposArquivo , { "DATAX"  , "D", 08, 0} )
		Aadd( aCposArquivo , { "NUMERO" , "C", TamSx3("VQ0_CODIGO")[1], 0 } )
		Aadd( aCposArquivo , { "PEDFAB" , "C", TamSx3("VQ0_NUMPED")[1], 0 } )
		Aadd( aCposArquivo , { "EMISSAO", "D",  8, 0 } )
		Aadd( aCposArquivo , { "CHASSI" , "C", TamSx3("VQ0_CHASSI")[1], 0 } )
		Aadd( aCposArquivo , { "MODELO" , "C", TamSx3("VQ0_MODVEI")[1], 0 } )
		Aadd( aCposArquivo , { "SALDO"  , "N", TamSx3("VQ0_VALCUS")[1]  , TamSx3("VQ0_VALCUS")[2] } )
		Aadd( aCposArquivo , { "CHAVE"  , "C", 40, 0 } )
		Aadd( aCposArquivo , { "Apelido", "C", 10, 0 } )

		cAliasAna := "cArqAnaDMSCp"  // Alias do arquivo analitico

	Case cTipo == "MAQ_VENDA"

		Aadd( aCposArquivo , { "Periodo", "C",  25, 0 } )
		Aadd( aCposArquivo , { "DATAX"  , "D", 08, 0} )
		Aadd( aCposArquivo , { "NUMERO" , "C", TamSx3("VV0_NUMTRA")[1], 0 } )
		Aadd( aCposArquivo , { "CLIFOR" , "C", TamSx3("E5_CLIFOR")[1], 0 } )
		Aadd( aCposArquivo , { "LOJACLI", "C", TamSx3("C5_LOJAENT")[1], 0 } )
		Aadd( aCposArquivo , { "NomCliFor", "C", TamSx3("A1_NOME")[1], 0 } )
		Aadd( aCposArquivo , { "EMISSAO", "D",  8, 0 } )
		Aadd( aCposArquivo , { "SALDO"  , "N", TamSx3("VQ0_VALCUS")[1]  , TamSx3("VQ0_VALCUS")[2] } )
		Aadd( aCposArquivo , { "CHAVE"  , "C", 40, 0 } )
		Aadd( aCposArquivo , { "Apelido", "C", 10, 0 } )

		cAliasAna := "cArqAnaDMSVd"  // Alias do arquivo analitico
	End Do

Return { aCposArquivo , cAliasAna }


Function VM210Visual( cAlias , nRecNo )
/*	Local cFilSALVA := cFilAnt
	If cAlias == "VV0" .and. nRecNo > 0
		DbSelectArea("VV0")
		DbGoTo(nRecNo)	
		cFilAnt := left(VV0->VV0_FILIAL,TamSX3("VV0_FILIAL")[1])
		DbSelectArea("VV9")
		DbSetOrder(1)
		If DbSeek( xFilial("VV9") + cAtend )
		If !FM_PILHA("VEIXX002") .and. !FM_PILHA("VEIXX030")
			VEIXX002(NIL,NIL,NIL,2,)
			EndIf
		EndIf
	EndIf
	cFilAnt := cFilSALVA
*/
Return