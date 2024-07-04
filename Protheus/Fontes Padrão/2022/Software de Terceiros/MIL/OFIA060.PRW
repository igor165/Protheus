#INCLUDE "FIVEWIN.CH"
#INCLUDE "APVT100.CH"
#INCLUDE "OFIA060.CH"

/*/{Protheus.doc} OFIA060
Coletor/Leitor VT100 - Conferencia de NF de Entrada - Pre-Nota

@author Andre Luis Almeida
@since 01/10/2018
@version undefined

@type function
/*/
Function OFIA060()
Local lVAI_APRCON := ( VAI->(FieldPos("VAI_APRCON")) <> 0 ) // Usuario Aprova Conferencia? 
Private nCodSB1 := TamSx3("B1_CODBAR")[1]
Private cCodSB1 := space(nCodSB1)
Private nLinT1  := 1 // Linha posicionada na Tela 1
Private nLinT3  := 1 // Linha posicionada na Tela 3
Private nTamCol := VTMaxCol() // Qtde maxima de Colunas no Display do Coletor
Private nTamLin := VTMaxRow() // Qtde maxima de Linhas no Display do Coletor
Private nPosOpc := 1 // Posicao no Menu de Opcoes
Private aVM1    := {} // VM1 da NF de Entrada selecionada - Itens
Private nQtdDias := 7 // Dias a Retroagir 
Private lNFTransf := .f. // NF de Entrada é uma Transferencia?
Private lVerGrupo := ( GetNewPar("MV_MIL0119","2") == "2" ) // COLETOR DE DADOS NA CONF.DE ITENS - VISUALIZA: 1 = CODIGO DO ITEM / 2 = GRUPO + CODIGO DO ITEM
Private cOpcItNov := GetNewPar("MV_MIL0139","0") // Conf.Entrada - Item nao Encontrado na NF ( 0=Nao Permite / 1=Perg se Inclui Item / 2=Inclui automaticamente o Item )
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                        //
// Parametro para controlar comportamento da rotina de conferencia: XYZ, onde:                                                            //
//                                                                                                                                        //
// X = Traz os Itens na Tela e indica se o item ja esta conferido (legenda/cores)        -->   0 = Nao            /   1 = Sim (default)   //
// Y = Mostra o campo de Qtde de Itens na propria tela de digitacao do codigo de barras  -->   0 = Nao            /   1 = Sim (default)   //
// Z = Utiliza Controle de Aprovação da Conferencia de Itens de Entrada                  -->   0 = Nao (default)  /   1 = Sim             //
//                                                                                                                                        //
Private lUtilAprova := ( substr(GetNewPar("MV_MIL0091","110"),3,1) == "1" ) // COLETOR DE DADOS utiliza apenas a 3a.posicao do parametro    //
//                                                                                                                                        //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID)) // Posiciona no VAI do usuario logado
If lVAI_APRCON .and. VAI->VAI_APRCON == "1" // Aprovacao
	VtBeep(3) // 3 Beep ERRO
	VTAlert(STR0003,STR0002) // Usuario Aprovador, opcao nao disponivel no coletor. / Atencao
	Return
EndIf
//
OA0600011_TELA1(.t.,.t.) // T1 - Escolher qual NF de Entrada sera conferida
//
Return

/*/{Protheus.doc} OA0600011_TELA1
T1 - Escolher qual NF de Entrada sera conferida

@author Andre Luis Almeida
@since 01/10/2018
@version undefined

@type function
/*/
Static Function OA0600011_TELA1(lPergDias,lPergNF) // T1 - Escolher qual NF de Entrada sera conferida
Local cJaConf  := ""
Local lOkConf  := .t.
Local nPos     := 0
Local nTamNF   := TamSx3("F1_DOC")[1]
Local nTamSer  := TamSx3("F1_SERIE")[1]
Local cNroNF   := space(nTamNF+nTamSer)
Local aSize    := {nTamCol}
Local aColunas := {STR0001} // Confer. NF Entrada
Local aLinhas  := {}
Local aRecSF1  := {}
Local cCodVM0  := ""
Local cQuery   := ""
Local cQAlSF1  := "SQLSF1"
Local cQAlVM1  := "SQLVM1"
Local nCntFor  := 0
Local aVolumes := {}
Local aNotaFiscal := Array(4)
Default lPergDias := .f.
Default lPergNF   := .f.
//
While .t.
	//
	aLinhas  := {}
	aRecSF1  := {}
	//
	If lPergNF
		cNroNF := OA0600101_QualNF(nTamNF+nTamSer)
		If cNroNF == "ESC"
			Exit
		EndIf
	EndIf
	If lPergDias .and. Empty(cNroNF)
		If !OA0600081_DiasRetroagir() // Tela Pergunta a Qtde de Dias a Retroagir para levantamento das NFs de Entrada
			lPergDias := .t.
			lPergNF := .t.
			Loop
		EndIf
	EndIf
	cQuery := "SELECT SF1.F1_FILIAL  ,"
	cQuery += "       SF1.F1_DOC     ,"
	cQuery += "       SF1.F1_SERIE   ,"
	cQuery += "       SF1.F1_FORNECE ,"
	cQuery += "       SF1.F1_LOJA    ,"
	cQuery += "       SF1.F1_TIPO    ,"
	cQuery += "       SF1.R_E_C_N_O_ AS RECSF1 ,"
	cQuery += "       VM0.VM0_STATUS "
	cQuery += "  FROM "+RetSQLName("SF1")+" SF1"
	cQuery += "  LEFT JOIN "+RetSqlName("VM0")+" VM0"
	cQuery += "       ON  VM0.VM0_FILIAL='"+xFilial("VM0")+"'"
	cQuery += "       AND VM0.VM0_DOC=SF1.F1_DOC"
	cQuery += "       AND VM0.VM0_SERIE=SF1.F1_SERIE"
	cQuery += "       AND VM0.VM0_FORNEC=SF1.F1_FORNECE"
	cQuery += "       AND VM0.VM0_LOJA=SF1.F1_LOJA"
	cQuery += "       AND VM0.D_E_L_E_T_=' '"
	cQuery += " WHERE SF1.F1_FILIAL = '"+xFilial("SF1")+"'"
	If !Empty(cNroNF)
		cQuery += "   AND SF1.F1_DOC = '"+substr(cNroNF,1,nTamNF)+"'"
		If len(Alltrim(cNroNF)) > nTamNF
			cQuery += "   AND SF1.F1_SERIE = '"+substr(cNroNF,nTamNF+1,nTamSer)+"'"
		EndIf
	Else
		cQuery += "   AND SF1.F1_DTDIGIT >= '"+dtos(dDatabase-nQtdDias)+"'"
	EndIf
	cQuery += "   AND SF1.F1_STATUS = ' '"
	cQuery += "   AND SF1.D_E_L_E_T_ = ' '"
	cQuery += "   AND ( VM0.VM0_STATUS IS NULL OR VM0.VM0_STATUS IN ('1','2') ) " // Nao encontrado VM0 ou Status igual a Pendente ou Conferido Parcialmente
	cQuery += "   AND EXISTS ( "
	cQuery += 				" SELECT SD1.D1_DOC "
	cQuery += 				" FROM " + RetSqlName("SD1") + " SD1 "
	cQuery += 				" LEFT JOIN " + RetSqlName("SF4") + " SF4 ON ( SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_=' ' )"
	cQuery += 				" WHERE SD1.D1_FILIAL ='" + xFilial("SD1") + "' "
	cQuery += 				" AND SD1.D1_DOC = SF1.F1_DOC "
	cQuery += 				" AND SD1.D1_SERIE = SF1.F1_SERIE "
	cQuery += 				" AND SD1.D1_FORNECE = SF1.F1_FORNECE "
	cQuery += 				" AND SD1.D1_LOJA = SF1.F1_LOJA "
	cQuery += 				" AND ( SD1.D1_TES = ' ' OR SF4.F4_ESTOQUE='S' ) "
	cQuery += 				" AND SD1.D_E_L_E_T_ = ' '"
	If ExistBlock("OMSQLSD1")
		cQuery += ExecBlock("OMSQLSD1",.f.,.f.,{"2"}) // Ponto de Entrada para completar o SQL de Levantamento das NFs de Entrada a Conferir
	EndIf
	cQuery += ")"
	cQuery += " ORDER BY SF1.F1_DOC , SF1.F1_SERIE "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSF1 , .F., .T. )
	While !( cQAlSF1 )->( Eof() )
		//
		If ( cQAlSF1 )->( F1_TIPO ) <> "D"
			cQuery := "SELECT A2_NOME "
			cQuery += "  FROM "+RetSQLName("SA2")
			cQuery += " WHERE A2_FILIAL='"+xFilial("SA2")+"'"
			cQuery += "   AND A2_COD='"+( cQAlSF1 )->( F1_FORNECE )+"'"
			cQuery += "   AND A2_LOJA='"+( cQAlSF1 )->( F1_LOJA )+"'"
			cQuery += "   AND D_E_L_E_T_=' '"
		Else
			cQuery := "SELECT A1_NOME "
			cQuery += "  FROM "+RetSQLName("SA1")
			cQuery += " WHERE A1_FILIAL='"+xFilial("SA1")+"'"
			cQuery += "   AND A1_COD='"+( cQAlSF1 )->( F1_FORNECE )+"'"
			cQuery += "   AND A1_LOJA='"+( cQAlSF1 )->( F1_LOJA )+"'"
			cQuery += "   AND D_E_L_E_T_=' '"
		EndIf
		cJaConf := IIf(( cQAlSF1 )->( VM0_STATUS )=="2","*"," ") // Conferido Parcialmente
		aAdd(aLinhas,{ left( cJaConf+( cQAlSF1 )->( F1_DOC )+" "+( cQAlSF1 )->( F1_SERIE )+" "+FM_SQL(cQuery),nTamCol) })
		aAdd(aRecSF1,( cQAlSF1 )->( RECSF1 ))
		//
		( cQAlSF1 )->( DbSkip() )
	EndDo
	( cQAlSF1 )->( DbCloseArea() )
	DbSelectArea("SF1")
	OA0600061_LimpaTelaColetor()
	If len(aLinhas) > 0
		If nLinT1 > len(aLinhas)
			nLinT1 := 1 // Volta para o primeiro registro da Tela 1 ( NFs Entrada )
		EndIf
		If len(aLinhas) > 1 .or. Empty(cNroNF)
			nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nLinT1) // Lista as NFs Entrada
		Else
			nPos := 1
		EndIf
		If nPos > 0
			nLinT1 := nPos // Posiciona no registro da Tela 1 ( NFs Entrada )
			nLinT3 := 1 // Posiciona no primeiro registro da Tela 3 ( Itens )
			If aRecSF1[nPos] > 0
				//
				aVM1 := {} // Limpar Itens
				//
				DbSelectArea("SF1")
				SF1->(DbGoTo(aRecSF1[nPos]))
				//
				If ExistBlock("OA060SEL")
					If !ExecBlock("OA060SEL",.f.,.f.,{ SF1->F1_DOC , SF1->F1_SERIE , SF1->F1_FORNECE , SF1->F1_LOJA }) // Pode selecionar a NF ?
						lPergDias := .f.
						lPergNF := !Empty(cNroNF)
						Loop
					EndIf
				EndIf
				//
				If ExistFunc("OA3600011_Tempo_Total_Conferencia_NF_Entrada")
					OA3600011_Tempo_Total_Conferencia_NF_Entrada( 1 , SF1->F1_DOC , SF1->F1_SERIE , SF1->F1_FORNECE , SF1->F1_LOJA ) // 1=Iniciar o Tempo Total da Conferencia de NF de Entrada caso não exista o registro
				EndIf
				//
				aVolumes := OA3400041_VolumesporNF( SF1->F1_DOC , SF1->F1_SERIE , SF1->F1_FORNECE , SF1->F1_LOJA )
				For nCntFor := 1 to len(aVolumes)
					If ExistFunc("OA3630011_Tempo_Total_Conferencia_Volume_Entrada")
						OA3630011_Tempo_Total_Conferencia_Volume_Entrada( 1 , aVolumes[nCntFor,1] ) // 1=Iniciar o Tempo Total da Conferencia de Volume de Entrada caso não exista o registro
					EndIf
					If !Empty(aVolumes[nCntFor,2]) // Existe Conferencia para o Volume
						lOkConf := .f.
					EndIf
				Next
				If !lOkConf
					VTAlert(STR0038,STR0002) // Esta NF contem um Volume que ja foi para Conferencia. / Atencao
					nPos := 0
				EndIf
				//
				If nPos > 0
					//
					lNFTransf := .f.
					If SF1->F1_TIPO <> "D"
						cQuery := "SELECT R_E_C_N_O_ AS RECSF2"
						cQuery += "  FROM "+RetSQLName("SF2")
						cQuery += " WHERE F2_FILIAL  = '"+SF1->F1_FILORIG+"'"
						cQuery += "   AND F2_DOC     = '"+SF1->F1_DOC+"'"
						cQuery += "   AND F2_SERIE   = '"+SF1->F1_SERIE+"'"
						cQuery += "   AND F2_FILDEST = '"+SF1->F1_FILIAL+"'"
						cQuery += "   AND D_E_L_E_T_ = ' '"
						If FM_SQL(cQuery) > 0
							lNFTransf := .t. // NF de Transferencia de outra Filial
						EndIf
					EndIf
					//
					DbSelectArea("SF1")
					If !SimpleLock() // No coletor utilizar SimpleLock ao inves de SoftLock
						//
						VTAlert(STR0034,STR0002) // NF de Entrada encontra-se Bloqueada por outro usuario! / Atencao
						//
					Else
						//
						aNotaFiscal[1] := SF1->F1_DOC
						aNotaFiscal[2] := SF1->F1_SERIE
						aNotaFiscal[3] := SF1->F1_FORNECE
						aNotaFiscal[4] := SF1->F1_LOJA
						cCodVM0 := OM3900125_ExisteConferencia( aNotaFiscal , .f. ) // Verifica se existe o VM0
						If Empty(cCodVM0)
							cCodVM0 := OM3900095_GravaRegistroConferencia( aNotaFiscal , "2" ) // Criar VM0/VM1
						EndIf
						VM0->(DbSeek(xfilial("VM0") + cCodVM0 ) )
						//
						cQuery := "SELECT SB1.R_E_C_N_O_ AS RECSB1 , "
						cQuery += "       VM1.R_E_C_N_O_ AS RECVM1 , "
						cQuery += "       SB1.B1_GRUPO   , "
						cQuery += "       SB1.B1_CODITE  , "
						cQuery += "       VM1.VM1_QTORIG , "
						cQuery += "       VM1.VM1_QTCONF , "
						cQuery += "       SB1.B1_COD       "
						cQuery += "  FROM "+RetSQLName("VM1")+" VM1"
						cQuery += "  JOIN "+RetSqlName("SB1")+" SB1"
						cQuery += "       ON  SB1.B1_FILIAL='"+xFilial("SB1")+"'"
						cQuery += "       AND SB1.B1_COD=VM1.VM1_COD"
						cQuery += "       AND SB1.D_E_L_E_T_=' '"
						cQuery += " WHERE VM1.VM1_FILIAL = '"+xFilial("VM1")+"'"
						cQuery += "   AND VM1.VM1_CODVM0 = '"+cCodVM0+"'"
						cQuery += "   AND VM1.D_E_L_E_T_ = ' '"
						cQuery += " ORDER BY "+IIf(lVerGrupo,"SB1.B1_GRUPO , ","")+"SB1.B1_CODITE"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVM1 , .F., .T. )
						While !( cQAlVM1 )->( Eof() )
							aAdd(aVM1,{ ( cQAlVM1 )->( RECSB1 )     ,;
										( cQAlVM1 )->( B1_GRUPO )   ,;
										( cQAlVM1 )->( B1_CODITE )  ,;
										( cQAlVM1 )->( VM1_QTORIG ) ,;
										( cQAlVM1 )->( VM1_QTCONF ) ,;
										( cQAlVM1 )->( B1_COD )     ,;
										( cQAlVM1 )->( RECVM1 )     })
							( cQAlVM1 )->( DbSkip() )
						EndDo
						( cQAlVM1 )->( DbCloseArea() )
						DbSelectArea("VM1")
						OA0600111_TelaMenuOpcoes() // Menu de Opcoes
						//
						SF1->(MsUnlock()) // Retirar SimpleLock do SF1
						//
					EndIf
				EndIf
			EndIf
			nLinT3 := 1 // Posiciona no primeiro registro da Tela 3 ( Itens )
			lPergDias := .f.
			lPergNF := !Empty(cNroNF)
		Else
			lPergDias := .t.
			lPergNF := .t.
		EndIf
	Else
		VtBeep(3) // 3 Beep ERRO
		If !Empty(cNroNF)
			VTAlert(STR0023,STR0002) // Nro.NF + Serie nao encontrada! / Atencao
		Else
			VTAlert(STR0004,STR0002) // Nao existe NF de Entrada para Conferir. / Atencao
		EndIf
		lPergDias := .t.
		lPergNF := !Empty(cNroNF)
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA0600021_TELA2
T2 - Escolher qual Item que sera Conferido

@author Andre Luis Almeida
@since 01/10/2018
@version undefined

@type function
/*/
Static Function OA0600021_TELA2(cNForn,cDtInv) // T2 - Escolher qual Item que sera Conferido
Local cEndUltSB1 := ""
//
While .t.
	//
	If !OA0600141_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM0
		Exit
	EndIf
	//
	cCodSB1 := space(nCodSB1)
	OA0600061_LimpaTelaColetor()
	//
	@ 00, 00 VTSay PadR(STR0001, nTamCol) // Confer. NF Entrada
	@ 01, 00 VTSay PadR(SF1->F1_DOC+"  "+SF1->F1_SERIE, nTamCol)
	@ 02, 00 VTSay PadR(cNForn,nTamCol)
	@ 03, 00 VTSay PadR(cDtInv,nTamCol)
	@ 04, 00 VTSay repl("-", nTamCol)
	@ 07, 00 VTSay PadR(cEndUltSB1,nTamCol) // Endereço do Ultimo SB1
	@ 05, 00 VTSay PadR(STR0022, nTamCol) // Bipar Cod.Barras
	@ 06, 00 VTGet cCodSB1 Valid OA0600051_PosicionaSB1comCODBAR(.t.,.t.)
	VTRead
	//
	If VTLastKey() <> 27 // Diferente de ESC
		If !Empty(cCodSB1)
			cEndUltSB1 := ""
			If !Empty(SB1->B1_COD) .and. !Localiza(SB1->B1_COD)
				SB5->(DbSetOrder(1))
				SB5->(DbSeek( xFilial("SB5")+SB1->B1_COD))
				cEndUltSB1 := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")+" "+FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
			EndIf
		Else
			OA0600031_TELA3(.f.)
		EndIf
	Else
		Exit
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA0600031_TELA3
T3 - Mostrar todos os Itens da NF de Entrada

@author Andre Luis Almeida
@since 01/10/2018
@version undefined

@type function
/*/
Static Function OA0600031_TELA3(lItemEspec) // T3 - Mostrar todos os Itens da NF de Entrada
Local nPos     := 0
Local cJaConf  := ""
Local nCntFor  := 0
Local aSize    := {nTamCol}
Local aColunas := {STR0007} // Selecionar Item
Local aLinhas  := {}
Default lItemEspec := .f.
//
While .t.
	//
	If !OA0600141_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM0
		Exit
	EndIf
	//
	aLinhas  := {}
	//
	For	nCntFor := 1 to len(aVM1)
		cJaConf := IIf( aVM1[nCntFor,5] > 0 , "*" , " " ) // Verifica se o Item ja foi Conferido
		aAdd(aLinhas,{ cJaConf + IIf(lVerGrupo,aVM1[nCntFor,2],"") + aVM1[nCntFor,3] })
	Next
	DbSelectArea("VM1")
	If len(aLinhas) > 0
		If lItemEspec
			Exit
		Else
			aAdd(aLinhas,{ repl("-",nTamCol) })
			aAdd(aLinhas,{ STR0008 }) // Finaliza Confer. ?
			OA0600061_LimpaTelaColetor()
			If nLinT3 > len(aLinhas)
				nLinT3 := 1 // Volta para o primeiro registro da Tela 3 ( Itens )
			EndIf
			nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nLinT3) // Lista os Itens
			If nPos > 0
				If nPos == len(aLinhas) // Finaliza Confer. ?
					If OA0600041_FinalizaConferencia() // Finaliza / Grava Conferencia
						Exit
					EndIf
				ElseIf nPos <> ( len(aLinhas) -1 ) // Diferente de tracos - Item a Item
					nLinT3 := nPos // Posiciona no registro da Tela 3 ( Itens )
					If OA0600071_SomaQTD( nPos , .t. , 0 ) // SOMA QTDE
						If len(aLinhas) > nLinT3
							nLinT3++ // Pula linha automaticamente na Tela 3
						Else
							nLinT3 := 1 // Volta para o primeiro registro da Tela 3 ( Itens )
						EndIf
					Else
						Exit
					EndIf
				EndIf
			Else
				Exit
			EndIf
		EndIf
	Else
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0011+CHR(13)+CHR(10)+;
				SF1->F1_DOC+"  "+SF1->F1_SERIE+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0013,STR0002) // NF de Entrada / Nenhum Item encontrado. / Atencao
		Exit
	EndIf
	//
	lItemEspec := .f.
	//
EndDo
//
Return

/*/{Protheus.doc} OA0600041_FinalizaConferencia
Finaliza a Conferencia - Gravacao VM1

@author Andre Luis Almeida
@since 08/10/2018
@version undefined

@type function
/*/
Static Function OA0600041_FinalizaConferencia()
Local lRet      := .t.
Local lOkConf   := .f.
Local nCntFor   := 0
Local cEmailDiv := ""
Local cNForn := ""
If !VtYesNo(STR0010,STR0009,.t.) // Deseja Finalizar a Conferencia dos Itens da NF de Entrada? / Finalizar?
	lRet := .f.
EndIf
If lRet
	OM3900265_LimpaItensZerados( VM0->VM0_CODIGO , "2" )
	OM3900311_GravaConferenciaZerada( VM0->VM0_CODIGO , "2" )
	OM3900235_VerificaDivergencias( VM0->VM0_CODIGO , "2" )
	If lUtilAprova .or. VM0->VM0_DIVERG == "0"
		If VM0->VM0_DIVERG == "1" // Tem Divergencia
			If !VtYesNo(STR0015,STR0014,.t.) // Existem divergencias na Conferencia. / Deseja continuar?
				lRet := .f.
			EndIf
		Else
			lOkConf := .t.
		EndIf
		If lRet
			OM3900115_StatusConferencia( VM0->VM0_CODIGO , "3" , "2" )
		EndIf
	Else
		VTAlert(STR0015,STR0002) // Existem divergencias na Conferencia. / Atencao
		lRet := .f.
	EndIf
	If lRet .and. VM0->VM0_DIVERG == "0" // NAO TEM DIVERGENCIA
		OM3900215_GravaObservacaoConferencia( STR0036+" "+Transform(dDataBase,"@D")+" "+left(time(),5)+" "+__CUSERID+"-"+left(Alltrim(UsrRetName(__CUSERID)),15) , "2" ) // Aprovado automaticamente via Coletor
		OM3900115_StatusConferencia( VM0->VM0_CODIGO , "4" , "2" )
		If ExistFunc("OA3600011_Tempo_Total_Conferencia_NF_Entrada")
			OA3600011_Tempo_Total_Conferencia_NF_Entrada( 0 , VM0->VM0_DOC , VM0->VM0_SERIE , VM0->VM0_FORNEC , VM0->VM0_LOJA ) // 0=Finalizar o Tempo Total da Conferencia de NF Entrada
		EndIf
		OM3900301_ChamaPEaposAprovReprov( "1" )
		lOkConf := .t.
	EndIf
	If VM0->VM0_DIVERG == "1" // Tem Divergencias
		For	nCntFor := 1 to len(aVM1)
			SB1->(DbGoTo(aVM1[nCntFor,01]))
			VM1->(DbGoTo(aVM1[nCntFor,07]))
			cEmailDiv += "<tr>"
			cEmailDiv += "<td width=25%><font size=2 face='verdana,arial' Color=#0000cc>"+SB1->B1_GRUPO+" "+SB1->B1_CODITE+"</font></td>"
			cEmailDiv += "<td width=40%><font size=2 face='verdana,arial' Color=#0000cc>"+SB1->B1_DESC+"</font></td>"
			cEmailDiv += "<td width=35%><font size=2 face='verdana,arial' Color="
			If aVM1[nCntFor,04] <> aVM1[nCntFor,05]
				If VM1->VM1_QTORIG == 0
					cEmailDiv += "red>"+STR0035 // Item não existente na NF
				Else
					cEmailDiv += "red>"+STR0016 // Item com divergencia
					cEmailDiv += " "+STR0027+" "+Alltrim(Transform(aVM1[nCntFor,04],VM1->(X3PICTURE("VM1_QTORIG")))) // Qtd.NF:
					cEmailDiv += " - "+STR0028+" "+Alltrim(Transform(aVM1[nCntFor,05],VM1->(X3PICTURE("VM1_QTCONF")))) // Qtd.Conf.:
				EndIf
			Else
				cEmailDiv += "#0000cc>"+STR0026 // ok
			EndIf
			cEmailDiv += " - "+VM1->VM1_USRCON+" "+Alltrim(FM_SQL("SELECT VAI_NOMTEC FROM "+RetSQLName("VAI")+" WHERE VAI_FILIAL='"+xFilial("VAI")+"' AND VAI_CODUSR='"+VM1->VM1_USRCON+"' AND D_E_L_E_T_=' '"))
			cEmailDiv += " </font></td>"
			cEmailDiv += "</tr>"
		Next
	EndIf
EndIf
If !lRet
	Return .f. // Caso cancelou ou tem problema na Conferencia e nao possui controle de conferencia
EndIf
//
SF1->(MsUnlock()) // Retirar SimpleLock do SF1
//
If lOkConf // Conferencia OK - Liberar automaticamente para dar Entrada na NF
	VTAlert(STR0011+CHR(13)+CHR(10)+;
			VM0->VM0_DOC+"  "+VM0->VM0_SERIE+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
			STR0012,STR0002) // NF de Entrada / Conferencia Finalizada. / Atencao
Else
	If !Empty(cEmailDiv) // Enviar E-mail
		SF1->(DbSetOrder(1))
		SF1->(DbSeek(xFilial("SF1")+VM0->VM0_DOC+VM0->VM0_SERIE+VM0->VM0_FORNEC+VM0->VM0_LOJA))
		If SF1->F1_TIPO <> "D"
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+VM0->VM0_FORNEC+VM0->VM0_LOJA))
			cNForn := Left(SA2->A2_NOME,40)						
		Else
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+VM0->VM0_FORNEC+VM0->VM0_LOJA))
			cNForn := Left(SA1->A1_NOME,40)
		EndIf
		OM3900021_EMAIL( cEmailDiv , ( VM0->VM0_DOC+"-"+VM0->VM0_SERIE ) , ( VM0->VM0_FORNEC+"-"+VM0->VM0_LOJA+" "+cNForn ) , "2" )
		VTAlert(STR0011+CHR(13)+CHR(10)+;
				VM0->VM0_DOC+"  "+VM0->VM0_SERIE+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0012+" "+STR0020,STR0002) // NF de Entrada / Conferencia Finalizada. / Aguardando Aprovacao das divergencias. / Atencao
	EndIf
EndIf
If ExistBlock("OA060DOK")
	SF1->(DbSetOrder(1))
	SF1->(DbSeek( xFilial("SF1") + VM0->VM0_DOC + VM0->VM0_SERIE + VM0->VM0_FORNEC + VM0->VM0_LOJA ))
	ExecBlock("OA060DOK",.f.,.f.,{ lOkConf , SF1->(RecNo()) }) // PE apos Conferencia ( com ou sem divergencia )
EndIf
Return .t.

/*/{Protheus.doc} OA0600051_PosicionaSB1comCODBAR
Valida se o Item existe no SB1/NF de Entrada
Caso exista, verifica a quantidade atraves do Codigo de Barras (EAN13/EAN14/EAN128) e SOMA na Digitacao

@author Andre Luis Almeida
@since 01/10/2018
@version undefined
@return lRet , logico, Indica se o Item existe no SB1/NF de Entrada

@type function
/*/
Static Function OA0600051_PosicionaSB1comCODBAR(lAtuQtd,lAtuEnd) // Posicionar no SB1 com Codigo de Barras e Verificar se o Item esta na NF de Entrada
Local nLinha    := 0
Local lRet      := .t.
Local nQtdSomar := 0
Local aProduto  := {}
Local oPeca     := DMS_Peca():New()
Local lPosSB1   := .t.
Default lAtuQtd := .t.
Default lAtuEnd := .f.
If !Empty(cCodSB1)
	//
	aProduto := oPeca:LeCodBarras(cCodSB1) // Leitura do Codigo de Barras
	//
	If Len(aProduto) > 0
		DbSelectArea("SB1")
		DbSetOrder(1)
		If !Empty(aProduto[1]) .and. DbSeek(xFilial("SB1")+aProduto[1])
			If lAtuQtd // Atualiza QTDE
				If lNFTransf // Se for NF de Transferencia
					nQtdSomar := 1 // Somar Qtde 1 nos Bips
				Else
					nQtdSomar := aProduto[2]
					If nQtdSomar == 0 // Qtde por Embalagem Zerada
						nQtdSomar := 1 // Somar Qtde 1 nos Bips
					EndIf
				EndIf
			EndIf
			nLinha := aScan(aVM1,{|x| x[1] == SB1->(RecNo()) }) // Se posicionar no Item correspondente
			If nLinha <= 0
				If cOpcItNov == "0" // Item nao Encontrado na NF de Entrada ( 0=Nao Permite )
					cCodSB1 := space(nCodSB1)
					VTGetRefresh("cCodSB1")
					lRet := .f.
					VtBeep(3) // 3 Beep ERRO
					VTAlert(STR0017,STR0002) // Item nao encontrado nesta NF de Entrada. / Atencao
					If lAtuEnd
						@ 07, 00 VTSay PadR("",nTamCol) // Endereço do Ultimo SB1
					EndIf
				ElseIf cOpcItNov == "1" // Item nao Encontrado na NF de Entrada ( 1=Pergunta se Inclui Item )
					If VtYesNo(STR0017,STR0037) // Deseja Continuar?
						nLinha := OA0600131_AdicionaRegistroVM1() // Adiciona Item na tabela VM1 e vetor aVM1
					Else
						cCodSB1 := space(nCodSB1)
						VTGetRefresh("cCodSB1")
						lRet := .f.
						If lAtuEnd
							@ 07, 00 VTSay PadR("",nTamCol) // Endereço do Ultimo SB1
						EndIf
					EndIf
				ElseIf cOpcItNov == "2" // Item nao Encontrado na NF de Entrada ( 2=Inclui automaticamente o Item )
					nLinha := OA0600131_AdicionaRegistroVM1() // Adiciona Item na tabela VM1 e vetor aVM1
				EndIf
			EndIf
			If nLinha > 0
				If lAtuQtd // Atualiza QTDE
					lRet := OA0600071_SomaQTD( nLinha , .f. , nQtdSomar ) // Somar Qtde
				Else
					lRet := OA0600071_SomaQTD( nLinha , .t. , 0 ) // Somar Qtde
				EndIf
			EndIf
		Else
			lPosSB1 := .f.
		EndIf
	Else
		lPosSB1 := .f.
	EndIf
	If !lPosSB1 // Item nao Encontrado no SB1
		cCodSB1 := space(nCodSB1)
		VTGetRefresh("cCodSB1")
		lRet := .f.
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0018,STR0002) // Item nao encontrado no Cadastro de Produtos. / Atencao
		If lAtuEnd
			@ 07, 00 VTSay PadR("",nTamCol) // Endereço do Ultimo SB1
		EndIf
	EndIf
EndIf
FreeObj(oPeca)
Return lRet

/*/{Protheus.doc} OA0600061_LimpaTelaColetor
Limpa a Tela do Coletor 

@author Andre Luis Almeida
@since 01/10/2018
@version undefined

@type function
/*/
Static Function OA0600061_LimpaTelaColetor() // Limpa Tela
Local ni := 0
VTCLEARBUFFER()
VTClear() // Limpa Tela
For ni := 1 to nTamLin
	@ ni, 00 VTSay repl(" ",nTamCol)
Next
Return

/*/{Protheus.doc} OA0600071_SomaQTD
Soma e chama funcao para preencher Quantidade na Conferencia da NF de Entrada

@author Andre Luis Almeida
@since 01/10/2018
@version undefined
@param nLinha, numerico, Linha do Vetor aVM1 ( itens da NF de Entrada )
@param lTelaQtd, logico, Abre Tela para o usuario preencher a Quantidade Digitada?
@param nQtdSomar, numerico, Quantidade a Somar na Digitacao
@return lRet, logico, Indica se a Digitacao foi OK ou foi dado ESC

@type function
/*/
Static Function OA0600071_SomaQTD( nLinha , lTelaQtd , nQtdSomar ) // Somar Qtde
Local nQtd := aVM1[nLinha,5]
Local lRet := .t.
If lTelaQtd // Tela Qtde
	SB1->(DbGoto(aVM1[nLinha,1]))
	OA0600061_LimpaTelaColetor()
	@ 00, 00 VTSay PadR(SB1->B1_GRUPO, nTamCol)
	@ 01, 00 VTSay PadR(SB1->B1_CODITE, nTamCol)
	@ 02, 00 VTSay PadR(SB1->B1_DESC, nTamCol)
	If !Localiza(SB1->B1_COD)
		SB5->(DbSetOrder(1))
		SB5->(DbSeek( xFilial("SB5")+SB1->B1_COD))
		@ 03, 00 VTSay PadR(FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")+" "+FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"), nTamCol)
	Else
		@ 03, 00 VTSay PadR(STR0029, nTamCol) // Item Enderecado
	EndIf
	@ 04, 00 VTSay repl("-", nTamCol)
	@ 05, 00 VTSay PadR(STR0019, nTamCol) // Quantidade?
	@ 06, 00 VTGet nQtd Valid nQtd>=0
	VTRead
	If VTLastKey() == 27 // ESC
		lRet := .f.
	EndIf
EndIf
If lRet
	//
	aVM1[nLinha,5] := nQtd+nQtdSomar
	OM3900285_GravaQtdConferida( aVM1[nLinha,7] , aVM1[nLinha,5] , "2" )
	OM3900115_StatusConferencia( VM0->VM0_CODIGO , "2" , "2" )
	If !lTelaQtd
		VtBeep(1) // 1 Beep OK
	EndIf
	//
EndIf
Return lRet

/*/{Protheus.doc} OA0600081_DiasRetroagir
Tela Pergunta a Qtde de Dias a Retroagir para levantamento das NFs de Entrada

@author Andre Luis Almeida
@since 27/11/2018
@version undefined
@return lRet, logico, Indica se informou os dias ou foi dado ESC

@type function
/*/
Static Function OA0600081_DiasRetroagir()
Local lRet := .t.
OA0600061_LimpaTelaColetor()
@ 00, 00 VTSay PadR(STR0001, nTamCol) // Confer. NF Entrada
@ 01, 00 VTSay repl("-", nTamCol)
@ 02, 00 VTSay PadR(Transform(dDataBase,"@D"), nTamCol)
@ 04, 00 VTSay PadR(STR0021, nTamCol) // Dias a retroagir?
@ 05, 00 VTGet nQtdDias Picture "@E 999999" Valid nQtdDias>=0
VTRead
If VTLastKey() == 27 // ESC
	lRet := .f.
EndIf
Return lRet


/*/{Protheus.doc} OA0600091_TelaQualItemConferir
Escolher qual Item que sera Conferido

@author Andre Luis Almeida
@since 07/03/2019
@version undefined

@type function
/*/
Static Function OA0600091_TelaQualItemConferir(cNForn,cDtInv) // Escolher qual Item que sera Conferido
//
cCodSB1 := space(nCodSB1)
OA0600061_LimpaTelaColetor()
//
@ 00, 00 VTSay PadR(STR0001, nTamCol) // Confer. NF Entrada
@ 01, 00 VTSay PadR(SF1->F1_DOC+"  "+SF1->F1_SERIE, nTamCol)
@ 02, 00 VTSay PadR(cNForn,nTamCol)
@ 03, 00 VTSay PadR(cDtInv,nTamCol)
@ 04, 00 VTSay repl("-", nTamCol)
@ 05, 00 VTSay PadR(STR0006, nTamCol) // Qual Item?
@ 06, 00 VTGet cCodSB1 Valid OA0600051_PosicionaSB1comCODBAR(.f.,.f.)
VTRead
//
If VTLastKey() <> 27 // Diferente de ESC
	If Empty(cCodSB1)
		OA0600031_TELA3(.f.) // Mostrar todos os Itens da NF Entrada
	Else
		OA0600031_TELA3(.t.) // Mostrar todos os Itens da NF Entrada ( escolher Item Especifico )
	EndIf
EndIf
//
Return

/*/{Protheus.doc} OA0600101_QualNF
Tela Pergunta o Nro da NF + Serie

@author Andre Luis Almeida
@since 23/03/2019
@version undefined
@return cRet, caracter, Nro+Serie da NF

@type function
/*/
Static Function OA0600101_QualNF(nTam)
Local cRet := space(nTam)
OA0600061_LimpaTelaColetor()
@ 00, 00 VTSay PadR(STR0001, nTamCol) // Confer. NF Entrada
@ 01, 00 VTSay repl("-", nTamCol)
@ 02, 00 VTSay PadR(STR0024, nTamCol) // Digite
@ 04, 00 VTSay PadR(STR0025, nTamCol) // Nro.NF + Serie
@ 05, 00 VTGet cRet Picture "@!"
VTRead
If VTLastKey() == 27 // ESC
	cRet := "ESC"
EndIf
Return cRet

/*/{Protheus.doc} OA0600111_TelaMenuOpcoes
Menu de Opcoes

@author Andre Luis Almeida
@since 02/10/2019
@version undefined

@type function
/*/
Static Function OA0600111_TelaMenuOpcoes() // Menu de Opcoes
Local aLinhas  := {}
Local aSize    := {nTamCol}
Local cNForn   := ""
Local xDtInv   := Transform( SF1->F1_EMISSAO , "@D" ) // Converter Data
Local cDtInv   := STR0005+" "+left( xDtInv , 6 ) + right( xDtInv , 2 ) // Emissao:
Local aColunas := { cDtInv }
//
aAdd(aLinhas,{ STR0030 }) // Todos os Itens
aAdd(aLinhas,{ STR0031 }) // Selecionar Item
aAdd(aLinhas,{ STR0032 }) // Itens com Diverg
aAdd(aLinhas,{ STR0008 }) // Finaliza Confer. ?
//
If SF1->F1_TIPO <> "D"
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
	cNForn := PadR(SA2->A2_NOME,nTamCol)
Else
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))
	cNForn := PadR(SA1->A1_NOME,nTamCol)
EndIf
aColunas := { cNForn }
//
While .t.
	//
	If !OA0600141_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM0
		Exit
	EndIf
	//
	OA0600061_LimpaTelaColetor()
	@ 00, 00 VTSay PadR(STR0001, nTamCol) // Confer. NF Entrada
	@ 01, 00 VTSay PadR(SF1->F1_DOC+"  "+SF1->F1_SERIE, nTamCol)
	nPosOpc := VTaBrowse(2,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nPosOpc) // Lista os Itens
	If nPosOpc > 0
		If nPosOpc == 1 // Todos os Itens
			OA0600021_TELA2(cNForn,cDtInv) // T2 - TODOS OS ITENS
		ElseIf nPosOpc == 2 // Selecionar Item
			OA0600091_TelaQualItemConferir(cNForn,cDtInv) // Escolher qual Item que sera Conferido
		ElseIf nPosOpc == 3 // Itens com Diverg
			OA0600121_ListaItensDivergentes()
		Else // Finaliza Confer. ?
			If OA0600041_FinalizaConferencia() // Finaliza Conferencia
				Exit
			EndIf
		EndIf
	Else
		nPosOpc := 1
		Exit
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA0600121_ListaItensDivergentes
Lista os Itens com Divergencia

@author Andre Luis Almeida
@since 02/10/2019
@version undefined

@type function
/*/
Static Function OA0600121_ListaItensDivergentes() // Lista Itens com Divergencia
Local aSize    := {nTamCol}
Local aColunas := {STR0032} // Itens com Diverg
Local aLinhas := {}
Local aLinDiv := {}
Local nCntFor := 0
Local nPosIte := 0
Local cJaConf := ""
//
While .t.
	//
	If !OA0600141_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM0
		Exit
	EndIf
	//
	aLinhas := {}
	aLinDiv := {}
	//
	For nCntFor := 1 to len(aVM1)
		If aVM1[nCntFor,4] <> aVM1[nCntFor,5]
			cJaConf := IIf( aVM1[nCntFor,5] > 0 , "*" , " " ) // Verifica se o Item ja foi Conferido
			aAdd(aLinhas,{ cJaConf + IIf(lVerGrupo,aVM1[nCntFor,2],"") + aVM1[nCntFor,3] })
			aAdd(aLinDiv,nCntFor) // Linha relacionada ao vetor aVM1
		EndIf
	Next
	OA0600061_LimpaTelaColetor()
	If Len(aLinhas) > 0
		aAdd(aLinhas,{ repl("-",nTamCol) })
		aAdd(aLinhas,{ STR0008 }) // Finaliza Confer. ?
		nPosIte := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,1) // Lista os Itens
		If nPosIte > 0
			If nPosIte == len(aLinhas) // Finaliza Confer. ?
				If OA0600041_FinalizaConferencia() // Finaliza / Grava Conferencia
					Exit
				EndIf
			ElseIf nPosIte <> ( len(aLinhas) -1 ) // Diferente de tracos - Item a Item
				If !OA0600071_SomaQTD( aLinDiv[nPosIte] , .t. , 0 ) // DIGITA QTDE PARA ITEM ESPECIFICO
					Exit
				EndIf
			EndIf
		Else
			Exit
		EndIf
	Else
		VTAlert(STR0033,STR0002) // Nenhum Item com Divergencia encontrado! Atencao
		Exit
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA0600131_AdicionaRegistroVM1
Adiciona Item no Vetor aVM1 e na Tabela VM1

@author Andre Luis Almeida
@since 15/10/2019
@version undefined

@type function
/*/
Static Function OA0600131_AdicionaRegistroVM1() // Adiciona Item na tabela VM1 e vetor aVM1
Local nLinha := 0
aAdd(aVM1,{ SB1->(RecNo()) ,;
			SB1->B1_GRUPO  ,;
			SB1->B1_CODITE ,;
			0              ,;
			0              ,;
			SB1->B1_COD    ,;
			0              })
nLinha := len(aVM1)
aVM1[nLinha,7] := OM3900195_AdcionaRegistroVM1( nLinha ) // Adiciona na Tabela VM1
Return nLinha

/*/{Protheus.doc} OA0600141_VerificaStatus
Verifica o Status se pode Continuar na Conferencia VM0

@author Andre Luis Almeida
@since 19/12/2019
@version undefined

@type function
/*/
Static Function OA0600141_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM0
Local lRet := .f.
If VM0->VM0_STATUS $ "1/2" // Status igual a Pendente ou Conferido Parcialmente
	lRet := .t.
EndIf
Return lRet