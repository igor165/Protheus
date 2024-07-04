#INCLUDE "FIVEWIN.CH"
#INCLUDE "APVT100.CH"
#INCLUDE "OFIA350.CH"

/*/{Protheus.doc} OFIA350
Coletor/Leitor VT100 - Conferencia por Volume de Entrada

@author Andre Luis Almeida
@since 19/08/2021
@version undefined

@type function
/*/
Function OFIA350()
Local lVAI_APRCON := ( VAI->(FieldPos("VAI_APRCON")) <> 0 ) // Usuario Aprova Conferencia? 
Private nCodSB1 := GetSX3Cache("B1_CODBAR","X3_TAMANHO")
Private cCodSB1 := space(nCodSB1)
Private nLinT1  := 1 // Linha posicionada na Tela 1
Private nLinT3  := 1 // Linha posicionada na Tela 3
Private nTamCol := VTMaxCol() // Qtde maxima de Colunas no Display do Coletor
Private nTamLin := VTMaxRow() // Qtde maxima de Linhas no Display do Coletor
Private nPosOpc := 1 // Posicao no Menu de Opcoes
Private aVM8    := {} // VM8 do Volume selecionado - Itens
Private nQtdDias := 7 // Dias a Retroagir
Private lVerGrupo := ( GetNewPar("MV_MIL0119","2") == "2" ) // COLETOR DE DADOS NA CONF.DE ITENS - VISUALIZA: 1 = CODIGO DO ITEM / 2 = GRUPO + CODIGO DO ITEM
Private cOpcItNov := GetNewPar("MV_MIL0139","0") // Conf.Entrada - Item nao Encontrado no Volume ( 0=Nao Permite / 1=Perg se Inclui Item / 2=Inclui automaticamente o Item )
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
OA3500011_TELA1(.t.,.t.) // T1 - Escolher qual Volume de Entrada sera conferido
//
Return

/*/{Protheus.doc} OA3500011_TELA1
T1 - Escolher qual Volume de Entrada sera conferido

@author Andre Luis Almeida
@since 19/08/2021
@version undefined

@type function
/*/
Static Function OA3500011_TELA1(lPergDias,lPergVol) // T1 - Escolher qual Volume de Entrada sera conferido
Local cJaConf  := ""
Local nPos     := 0
Local nTamVol  := GetSX3Cache("VCX_VOLUME","X3_TAMANHO")
Local cVolume  := space(nTamVol)
Local aSize    := {nTamCol}
Local aColunas := {STR0001} // Conf.Volume Entrada
Local aLinhas  := {}
Local aRecVCX  := {}
Local cCodVM7  := ""
Local cQuery   := ""
Local cQIRec   := ""
Local cQFRec   := ""
Local cQISta   := ""
Local cQFSta   := ""
Local cQAlVCX  := "SQLVCX"
Local cQAlREC  := "SQLREC"
Local cQAlVM8  := "SQLVM8"
Local lTravouVCX := .t.
Local nCntFor  := 0
Local aNFsVol  := {}
Local lFuncTempo  := ExistFunc("OA3600011_Tempo_Total_Conferencia_NF_Entrada")
Default lPergDias := .f.
Default lPergVol  := .f.
//
cQIRec := "SELECT R_E_C_N_O_ AS RECVCX "
cQIRec += "  FROM " + RetSqlName("VCX")
cQIRec += " WHERE VCX_FILIAL = '" + xFilial("VCX") + "' "
cQIRec += "   AND VCX_VOLUME = '"
//
cQFRec += "'  AND D_E_L_E_T_ = ' '"
//
cQISta := "SELECT VM7_STATUS "
cQISta += "  FROM " + RetSqlName("VM7")
cQISta += " WHERE VM7_FILIAL = '" + xFilial("VM7") + "' "
cQISta += "   AND VM7_VOLUME = '"
//
cQFSta += "'  AND D_E_L_E_T_ = ' ' "
cQFSta += " ORDER BY VM7_CODIGO DESC"
//
While .t.
	//
	aLinhas := {}
	aRecVCX := {}
	nPos    := 0
	//
	If lPergVol
		cVolume := OA3500101_QualVolume(nTamVol)
		If cVolume == "ESC"
			Exit
		EndIf
	EndIf
	If lPergDias .and. Empty(cVolume)
		If !OA3500081_DiasRetroagir() // Tela Pergunta a Qtde de Dias a Retroagir para levantamento das NFs de Entrada que fazem parte do Volume
			lPergDias := .t.
			lPergVol := .t.
			Loop
		EndIf
	EndIf
	//
	cQuery := "SELECT DISTINCT VCX.VCX_VOLUME "
	cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
	cQuery += " WHERE VCX.VCX_FILIAL = '" + xFilial("VCX") + "' "
	If !Empty(cVolume)
		cQuery += "   AND VCX.VCX_VOLUME = '"+cVolume+"' "
	EndIf
	cQuery += "   AND VCX.D_E_L_E_T_ = ' ' "
	//
	cQuery += "AND NOT EXISTS ( "
	cQuery += "SELECT VM7.VM7_VOLUME "
	cQuery += "  FROM " + RetSqlName("VM7") + " VM7 "
	cQuery += " WHERE VM7.VM7_FILIAL ='" + xFilial("VM7") + "' "
	cQuery += "   AND VM7.VM7_STATUS IN ('3','4') "
	cQuery += "   AND VM7.VM7_VOLUME = VCX.VCX_VOLUME "
	cQuery += "   AND VM7.D_E_L_E_T_ = ' ') "
	//
	cQuery += "AND EXISTS ( "
	cQuery += "SELECT SD1.D1_DOC "
	cQuery += "  FROM " + RetSqlName("SD1") + " SD1 "
	cQuery += "  LEFT JOIN " + RetSqlName("SF4") + " SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_=' '"
	cQuery += " WHERE SD1.D1_FILIAL  ='" + xFilial("SD1") + "' "
	cQuery += "   AND SD1.D1_DOC     = VCX.VCX_DOC "
	cQuery += "   AND SD1.D1_SERIE   = VCX.VCX_SERIE "
	cQuery += "   AND SD1.D1_FORNECE = VCX.VCX_FORNEC "
	cQuery += "   AND SD1.D1_LOJA    = VCX.VCX_LOJA "
	cQuery += "   AND SD1.D1_COD     = VCX.VCX_COD "
	cQuery += "   AND SD1.D1_ITEM    = VCX.VCX_ITEM "
	If Empty(cVolume)
		cQuery += "   AND SD1.D1_DTDIGIT >= '"+dtos(dDatabase-nQtdDias)+"'"
	EndIf
	cQuery += "   AND ( SD1.D1_TES = ' ' OR SF4.F4_ESTOQUE='S' ) "
	cQuery += "   AND SD1.D_E_L_E_T_ = ' ' ) "
	//
	cQuery += "AND NOT EXISTS ( "
	cQuery += "SELECT VM0.VM0_DOC "
	cQuery += "  FROM " + RetSqlName("VM0") + " VM0 "
	cQuery += " WHERE VM0.VM0_FILIAL = '" + xFilial("VM0") + "' "
	cQuery += "   AND VM0.VM0_DOC    = VCX.VCX_DOC "
	cQuery += "   AND VM0.VM0_SERIE  = VCX.VCX_SERIE "
	cQuery += "   AND VM0.VM0_FORNEC = VCX.VCX_FORNEC "
	cQuery += "   AND VM0.VM0_LOJA   = VCX.VCX_LOJA "
	cQuery += "   AND VM0.VM0_STATUS IN ('1','2','3','4') "
	cQuery += "   AND VM0.D_E_L_E_T_ = ' ')"
	//
	cQuery += " ORDER BY VCX.VCX_VOLUME "
	//
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVCX , .F., .T. )
	While !( cQAlVCX )->( Eof() )
		//
		cJaConf := IIf(FM_SQL(cQISta+( cQAlVCX )->( VCX_VOLUME )+cQFSta)=="2","*"," ") // Conferido Parcialmente
		aAdd(aLinhas,{ cJaConf+right( ( cQAlVCX )->( VCX_VOLUME ),nTamCol-1) })
		aAdd(aRecVCX,{ ( cQAlVCX )->( VCX_VOLUME ) , { } })
		nPos++
		//
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, ( cQIRec +( cQAlVCX )->( VCX_VOLUME )+cQFRec ) ), cQAlREC , .F., .T. )
		While !( cQAlREC )->(Eof())
			aAdd(aRecVCX[nPos,2],{ .f. , ( cQAlREC )->( RECVCX ) })
			( cQAlREC )->(DbSkip())
		EndDo
		( cQAlREC )->(dbCloseArea())
		//
		( cQAlVCX )->( DbSkip() )
	EndDo
	( cQAlVCX )->( DbCloseArea() )
	DbSelectArea("VCX")
	OA3500061_LimpaTelaColetor()
	If len(aLinhas) > 0
		If nLinT1 > len(aLinhas)
			nLinT1 := 1 // Volta para o primeiro registro da Tela 1 ( Volumes Entrada )
		EndIf
		nPos := 0
		If len(aLinhas) > 1 .or. Empty(cVolume)
			nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nLinT1) // Lista os Volumes Entrada
		Else
			nPos := 1
		EndIf
		If nPos > 0
			nLinT1 := nPos // Posiciona no registro da Tela 1 ( Volumes Entrada )
			nLinT3 := 1 // Posiciona no primeiro registro da Tela 3 ( Itens )
			If !Empty(aRecVCX[nPos,1])
				//
				If ExistBlock("OA350SEL")
					If !ExecBlock("OA350SEL",.f.,.f.,{ aRecVCX[nPos,1] }) // Pode selecionar o Volume ?
						lPergDias := .f.
						lPergVol := !Empty(cVolume)
						Loop
					EndIf
				EndIf
				//
				aVM8 := {} // Limpar Itens
				//
				If ExistFunc("OA3630011_Tempo_Total_Conferencia_Volume_Entrada")
					OA3630011_Tempo_Total_Conferencia_Volume_Entrada( 1 , aRecVCX[nPos,1] ) // 1=Iniciar o Tempo Total da Conferencia de Volume de Entrada caso não exista o registro
				EndIf
				//
				aNFsVol := OA3400051_NFsporVolume( aRecVCX[nPos,1] , .f. )
				For nCntFor := 1 to len(aNFsVol)
					If lFuncTempo
						OA3600011_Tempo_Total_Conferencia_NF_Entrada( 1 , aNFsVol[nCntFor,1] , aNFsVol[nCntFor,2] , aNFsVol[nCntFor,3] , aNFsVol[nCntFor,4] ) // 1=Iniciar o Tempo Total da Conferencia de NF de Entrada caso não exista o registro
					EndIf
					If nPos > 0 .and. !Empty(OM3900125_ExisteConferencia( aClone(aNFsVol[nCntFor]) , .t. )) // Verifica se ja existe a Conferencia de NF
						VTAlert(STR0004,STR0002) // Existe NF dentro deste Volume que ja foi para Conferencia individual. / Atencao
						nPos := 0
					EndIf
				Next
				//
				If nPos > 0
					DbSelectArea("VCX")
					For nCntFor := 1 to len(aRecVCX[nPos,2])
						VCX->(DbGoto(aRecVCX[nPos,2,nCntFor,2]))
						If !SimpleLock() // No coletor utilizar SimpleLock ao inves de SoftLock - Travar todos os Registros do VCX
							//
							VTAlert(STR0005,STR0002) // Volume encontra-se Bloqueado por outro usuario! / Atencao
							//
							lTravouVCX := .f.
							Exit
						Else
							aRecVCX[nPos,2,nCntFor,1] := .t. // Travou VCX
						EndIf
					Next
					If lTravouVCX
						//
						cCodVM7 := OA3400121_ExisteConferencia( aRecVCX[nPos,1] , .t. ) // Verifica se existe o VM7
						If Empty(cCodVM7)
							cCodVM7 := OA3400091_GravaRegistroConferencia( aRecVCX[nPos,1] , "2" ) // Criar VM7/VM8
						EndIf
						VM7->(DbSeek(xfilial("VM7") + cCodVM7 ) )
						//
						cQuery := "SELECT SB1.R_E_C_N_O_ AS RECSB1 , "
						cQuery += "       VM8.R_E_C_N_O_ AS RECVM8 , "
						cQuery += "       SB1.B1_GRUPO   , "
						cQuery += "       SB1.B1_CODITE  , "
						cQuery += "       VM8.VM8_QTORIG , "
						cQuery += "       VM8.VM8_QTCONF , "
						cQuery += "       SB1.B1_COD       "
						cQuery += "  FROM "+RetSQLName("VM8")+" VM8"
						cQuery += "  JOIN "+RetSqlName("SB1")+" SB1"
						cQuery += "       ON  SB1.B1_FILIAL='"+xFilial("SB1")+"'"
						cQuery += "       AND SB1.B1_COD=VM8.VM8_COD"
						cQuery += "       AND SB1.D_E_L_E_T_=' '"
						cQuery += " WHERE VM8.VM8_FILIAL = '"+xFilial("VM8")+"'"
						cQuery += "   AND VM8.VM8_CODVM7 = '"+cCodVM7+"'"
						cQuery += "   AND VM8.D_E_L_E_T_ = ' '"
						cQuery += " ORDER BY "+IIf(lVerGrupo,"SB1.B1_GRUPO , ","")+"SB1.B1_CODITE"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVM8 , .F., .T. )
						While !( cQAlVM8 )->( Eof() )
							aAdd(aVM8,{ ( cQAlVM8 )->( RECSB1 )     ,;
										( cQAlVM8 )->( B1_GRUPO )   ,;
										( cQAlVM8 )->( B1_CODITE )  ,;
										( cQAlVM8 )->( VM8_QTORIG ) ,;
										( cQAlVM8 )->( VM8_QTCONF ) ,;
										( cQAlVM8 )->( B1_COD )     ,;
										( cQAlVM8 )->( RECVM8 )     })
							( cQAlVM8 )->( DbSkip() )
						EndDo
						( cQAlVM8 )->( DbCloseArea() )
						DbSelectArea("VM8")
						OA3500111_TelaMenuOpcoes() // Menu de Opcoes
						//
					EndIf
					//
					DbSelectArea("VCX")
					For nCntFor := 1 to len(aRecVCX[nPos,2])
						If aRecVCX[nPos,2,nCntFor,1] // Estava Travado
							VCX->(DbGoto(aRecVCX[nPos,2,nCntFor,2]))
							VCX->(MsUnlock()) // Retirar SimpleLock dos VCX
						EndIf
					Next
					//
				EndIf
			EndIf
			nLinT3 := 1 // Posiciona no primeiro registro da Tela 3 ( Itens )
			lPergDias := .f.
			lPergVol := !Empty(cVolume)
		Else
			lPergDias := .t.
			lPergVol := .t.
		EndIf
	Else
		VtBeep(3) // 3 Beep ERRO
		If !Empty(cVolume)	
			VTAlert(STR0006,STR0002) // Volume nao encontrado! / Atencao
		Else
			VTAlert(STR0007,STR0002) // Nao existe Volume de Entrada para Conferir. / Atencao
		EndIf
		lPergDias := .t.
		lPergVol := !Empty(cVolume)
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA3500021_TELA2
T2 - Escolher qual Item que sera Conferido

@author Andre Luis Almeida
@since 19/08/2021
@version undefined

@type function
/*/
Static Function OA3500021_TELA2(cNForn) // T2 - Escolher qual Item que sera Conferido
Local cEndUltSB1 := ""
//
While .t.
	//
	If !OA3500141_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM7
		Exit
	EndIf
	//
	cCodSB1 := space(nCodSB1)
	OA3500061_LimpaTelaColetor()
	//
	@ 00, 00 VTSay PadR(STR0001, nTamCol) // Conf.Volume Entrada
	@ 01, 00 VTSay PadR(right(VM7->VM7_VOLUME,nTamCol),nTamCol)
	@ 02, 00 VTSay PadR(cNForn,nTamCol)
	@ 03, 00 VTSay repl("-", nTamCol)
	@ 06, 00 VTSay PadR(cEndUltSB1,nTamCol) // Endereço do Ultimo SB1
	@ 04, 00 VTSay PadR(STR0008, nTamCol) // Bipar Cod.Barras
	@ 05, 00 VTGet cCodSB1 Valid OA3500051_PosicionaSB1comCODBAR(.t.,.t.)
	VTRead
	//
	If OA3500141_VerificaStatus() .and. VTLastKey() <> 27 // Verifica o Status se pode Continuar na Conferencia VM7 e Diferente de ESC
		If !Empty(cCodSB1)
			cEndUltSB1 := ""
			If !Empty(SB1->B1_COD) .and. !Localiza(SB1->B1_COD)
				SB5->(DbSetOrder(1))
				SB5->(DbSeek( xFilial("SB5")+SB1->B1_COD))
				cEndUltSB1 := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")+" "+FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
			EndIf
		Else
			OA3500031_TELA3(.f.)
		EndIf
	Else
		Exit
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA3500031_TELA3
T3 - Mostrar todos os Itens do Volume de Entrada

@author Andre Luis Almeida
@since 19/08/2021
@version undefined

@type function
/*/
Static Function OA3500031_TELA3(lItemEspec) // T3 - Mostrar todos os Itens do Volume de Entrada
Local nPos     := 0
Local cJaConf  := ""
Local nCntFor  := 0
Local aSize    := {nTamCol}
Local aColunas := {STR0009} // Selecionar Item
Local aLinhas  := {}
Default lItemEspec := .f.
//
While .t.
	//
	If !OA3500141_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM7
		Exit
	EndIf
	//
	aLinhas  := {}
	//
	For	nCntFor := 1 to len(aVM8)
		cJaConf := IIf( aVM8[nCntFor,5] > 0 , "*" , " " ) // Verifica se o Item ja foi Conferido
		aAdd(aLinhas,{ cJaConf + IIf(lVerGrupo,aVM8[nCntFor,2],"") + aVM8[nCntFor,3] })
	Next
	DbSelectArea("VM8")
	If len(aLinhas) > 0
		If lItemEspec
			Exit
		Else
			aAdd(aLinhas,{ repl("-",nTamCol) })
			aAdd(aLinhas,{ STR0010 }) // Finaliza Confer. ?
			OA3500061_LimpaTelaColetor()
			If nLinT3 > len(aLinhas)
				nLinT3 := 1 // Volta para o primeiro registro da Tela 3 ( Itens )
			EndIf
			nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nLinT3) // Lista os Itens
			If OA3500141_VerificaStatus() .and. nPos > 0 // Verifica o Status se pode Continuar na Conferencia VM7
				If nPos == len(aLinhas) // Finaliza Confer. ?
					If OA3500041_FinalizaConferencia() // Finaliza / Grava Conferencia
						Exit
					EndIf
				ElseIf nPos <> ( len(aLinhas) -1 ) // Diferente de tracos - Item a Item
					nLinT3 := nPos // Posiciona no registro da Tela 3 ( Itens )
					If OA3500071_SomaQTD( nPos , .t. , 0 ) // SOMA QTDE
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
		VTAlert(STR0011+CHR(13)+CHR(10)+; // Volume
				VM7->VM7_VOLUME+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0012,STR0002) // Nenhum Item encontrado. / Atencao
		Exit
	EndIf
	//
	lItemEspec := .f.
	//
EndDo
//
Return

/*/{Protheus.doc} OA3500041_FinalizaConferencia
Finaliza a Conferencia - Gravacao VM8

@author Andre Luis Almeida
@since 19/08/2021
@version undefined

@type function
/*/
Static Function OA3500041_FinalizaConferencia()
Local lRet      := .t.
Local lOkConf   := .f.
Local nCntFor   := 0
Local cEmailDiv := ""
If !VtYesNo(STR0013,STR0014,.t.) // Deseja Finalizar a Conferencia do Volume de Entrada? / Finalizar?
	lRet := .f.
EndIf
If lRet
	OA3400261_LimpaItensZerados( VM7->VM7_CODIGO , "2" )
	OA3400311_GravaConferenciaZerada( VM7->VM7_CODIGO , "2" )
	OA3400231_VerificaDivergencias( VM7->VM7_CODIGO , "2" )
	If lUtilAprova .or. VM7->VM7_DIVERG == "0"
		If VM7->VM7_DIVERG == "1" // Tem Divergencia
			If !VtYesNo(STR0015,STR0016,.t.) // Existem divergencias na Conferencia. / Deseja continuar?
				lRet := .f.
			EndIf
		Else
			lOkConf := .t.
		EndIf
		If lRet
			OA3400111_StatusConferencia( VM7->VM7_CODIGO , "3" , "2" )
		EndIf
	Else
		VTAlert(STR0015,STR0002) // Existem divergencias na Conferencia. / Atencao
		lRet := .f.
	EndIf
	If lRet .and. VM7->VM7_DIVERG == "0" // NAO TEM DIVERGENCIA
		OA3400211_GravaObservacaoConferencia( STR0017+" "+Transform(dDataBase,"@D")+" "+left(time(),5)+" "+__CUSERID+"-"+left(Alltrim(UsrRetName(__CUSERID)),15) , "2" ) // Aprovado automaticamente via Coletor
		OA3400111_StatusConferencia( VM7->VM7_CODIGO , "4" , "2" )
		If ExistFunc("OA3630011_Tempo_Total_Conferencia_Volume_Entrada")
			OA3630011_Tempo_Total_Conferencia_Volume_Entrada( 0 , VM7->VM7_VOLUME ) // 0=Finalizar o Tempo Total da Conferencia de Volume Entrada
		EndIf
		OA3400301_ChamaPEaposAprovReprov( "1" )
		lOkConf := .t.
	EndIf
	If VM7->VM7_DIVERG == "1" // Tem Divergencias
		For	nCntFor := 1 to len(aVM8)
			SB1->(DbGoTo(aVM8[nCntFor,01]))
			VM8->(DbGoTo(aVM8[nCntFor,07]))
			cEmailDiv += "<tr>"
			cEmailDiv += "<td width=25%><font size=2 face='verdana,arial' Color=#0000cc>"+SB1->B1_GRUPO+" "+SB1->B1_CODITE+"</font></td>"
			cEmailDiv += "<td width=40%><font size=2 face='verdana,arial' Color=#0000cc>"+SB1->B1_DESC+"</font></td>"
			cEmailDiv += "<td width=35%><font size=2 face='verdana,arial' Color="
			If aVM8[nCntFor,04] <> aVM8[nCntFor,05]
				If VM8->VM8_QTORIG == 0
					cEmailDiv += "red>"+STR0018 // Item nao existente no Volume
				Else
					cEmailDiv += "red>"+STR0019 // Item com divergencia
					cEmailDiv += " "+STR0020+" "+Alltrim(Transform(aVM8[nCntFor,04],VM8->(X3PICTURE("VM8_QTORIG")))) // Qtd.Volume:
					cEmailDiv += " - "+STR0021+" "+Alltrim(Transform(aVM8[nCntFor,05],VM8->(X3PICTURE("VM8_QTCONF")))) // Qtd.Conf.:
				EndIf
			Else
				cEmailDiv += "#0000cc>"+STR0022 // ok
			EndIf
			cEmailDiv += " - "+VM8->VM8_USRCON+" "+Alltrim(FM_SQL("SELECT VAI_NOMTEC FROM "+RetSQLName("VAI")+" WHERE VAI_FILIAL='"+xFilial("VAI")+"' AND VAI_CODUSR='"+VM8->VM8_USRCON+"' AND D_E_L_E_T_=' '"))
			cEmailDiv += " </font></td>"
			cEmailDiv += "</tr>"
		Next
	EndIf
EndIf
If !lRet
	Return .f. // Caso cancelou ou tem problema na Conferencia e nao possui controle de conferencia
EndIf
//
If lOkConf // Conferencia OK - Liberar automaticamente para dar Entrada na NF
	VTAlert(STR0023+CHR(13)+CHR(10)+; // Volume de Entrada
			VM7->VM7_VOLUME+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
			STR0024,STR0002) // Conferencia Finalizada. / Atencao
Else
	If !Empty(cEmailDiv) // Enviar E-mail
		OA3400251_EMAIL( cEmailDiv , VM7->VM7_VOLUME , "2" )
		VTAlert(STR0023+CHR(13)+CHR(10)+; // Volume de Entrada
				VM7->VM7_VOLUME+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0024+" "+STR0025,STR0002) // Conferencia Finalizada. / Aguardando Aprovacao das divergencias. / Atencao
	EndIf
EndIf
If ExistBlock("OA350DOK")
	ExecBlock("OA350DOK",.f.,.f.,{ lOkConf , VM7->VM7_VOLUME }) // PE apos Conferencia ( com ou sem divergencia )
EndIf
Return .t.

/*/{Protheus.doc} OA3500051_PosicionaSB1comCODBAR
Valida se o Item existe no SB1/NF de Entrada
Caso exista, verifica a quantidade atraves do Codigo de Barras (EAN13/EAN14/EAN128) e SOMA na Digitacao

@author Andre Luis Almeida
@since 19/08/2021
@version undefined
@return lRet , logico, Indica se o Item existe no SB1/NF de Entrada

@type function
/*/
Static Function OA3500051_PosicionaSB1comCODBAR(lAtuQtd,lAtuEnd) // Posicionar no SB1 com Codigo de Barras e Verificar se o Item esta na NF de Entrada
Local nLinha    := 0
Local lRet      := .t.
Local nQtdSomar := 0
Local aProduto  := {}
Local oPeca     := DMS_Peca():New()
Local lPosSB1   := .t.
Default lAtuQtd := .t.
Default lAtuEnd := .f.
If OA3500141_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM7
	If !Empty(cCodSB1)
		//
		aProduto := oPeca:LeCodBarras(cCodSB1) // Leitura do Codigo de Barras
		//
		If Len(aProduto) > 0
			DbSelectArea("SB1")
			DbSetOrder(1)
			If !Empty(aProduto[1]) .and. DbSeek(xFilial("SB1")+aProduto[1])
				If lAtuQtd // Atualiza QTDE
					nQtdSomar := aProduto[2]
					If nQtdSomar == 0 // Qtde por Embalagem Zerada
						nQtdSomar := 1 // Somar Qtde 1 nos Bips
					EndIf
				EndIf
				nLinha := aScan(aVM8,{|x| x[1] == SB1->(RecNo()) }) // Se posicionar no Item correspondente
				If nLinha <= 0
					If cOpcItNov == "0" // Item nao Encontrado na NF de Entrada ( 0=Nao Permite )
						cCodSB1 := space(nCodSB1)
						VTGetRefresh("cCodSB1")
						lRet := .f.
						VtBeep(3) // 3 Beep ERRO
						VTAlert(STR0018,STR0002) // Item nao existente no Volume / Atencao
						If lAtuEnd
							@ 07, 00 VTSay PadR("",nTamCol) // Endereço do Ultimo SB1
						EndIf
					ElseIf cOpcItNov == "1" // Item nao Encontrado na NF de Entrada ( 1=Pergunta se Inclui Item )
						If VtYesNo(STR0018,STR0016) // Item nao existente no Volume / Deseja Continuar?
							nLinha := OA3500131_AdicionaRegistroVM8() // Adiciona Item na tabela VM8 e vetor aVM8
						Else
							cCodSB1 := space(nCodSB1)
							VTGetRefresh("cCodSB1")
							lRet := .f.
							If lAtuEnd
								@ 07, 00 VTSay PadR("",nTamCol) // Endereço do Ultimo SB1
							EndIf
						EndIf
					ElseIf cOpcItNov == "2" // Item nao Encontrado na NF de Entrada ( 2=Inclui automaticamente o Item )
						nLinha := OA3500131_AdicionaRegistroVM8() // Adiciona Item na tabela VM8 e vetor aVM8
					EndIf
				EndIf
				If nLinha > 0
					If lAtuQtd // Atualiza QTDE
						lRet := OA3500071_SomaQTD( nLinha , .f. , nQtdSomar ) // Somar Qtde
					Else
						lRet := OA3500071_SomaQTD( nLinha , .t. , 0 ) // Somar Qtde
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
			VTAlert(STR0026,STR0002) // Item nao encontrado no Cadastro de Produtos. / Atencao
			If lAtuEnd
				@ 07, 00 VTSay PadR("",nTamCol) // Endereço do Ultimo SB1
			EndIf
		EndIf
	EndIf
Else
	cCodSB1 := space(nCodSB1)
	VTGetRefresh("cCodSB1")
	lRet := .f.
EndIf
FreeObj(oPeca)
Return lRet

/*/{Protheus.doc} OA3500061_LimpaTelaColetor
Limpa a Tela do Coletor 

@author Andre Luis Almeida
@since 19/08/2021
@version undefined

@type function
/*/
Static Function OA3500061_LimpaTelaColetor() // Limpa Tela
Local ni := 0
VTCLEARBUFFER()
VTClear() // Limpa Tela
For ni := 1 to nTamLin
	@ ni, 00 VTSay repl(" ",nTamCol)
Next
Return

/*/{Protheus.doc} OA3500071_SomaQTD
Soma e chama funcao para preencher Quantidade na Conferencia da NF de Entrada

@author Andre Luis Almeida
@since 19/08/2021
@version undefined
@param nLinha, numerico, Linha do Vetor aVM8 ( itens da NF de Entrada )
@param lTelaQtd, logico, Abre Tela para o usuario preencher a Quantidade Digitada?
@param nQtdSomar, numerico, Quantidade a Somar na Digitacao
@return lRet, logico, Indica se a Digitacao foi OK ou foi dado ESC

@type function
/*/
Static Function OA3500071_SomaQTD( nLinha , lTelaQtd , nQtdSomar ) // Somar Qtde
Local nQtd := aVM8[nLinha,5]
Local lRet := .t.
If OA3500141_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM7
	If lTelaQtd // Tela Qtde
		SB1->(DbGoto(aVM8[nLinha,1]))
		OA3500061_LimpaTelaColetor()
		@ 00, 00 VTSay PadR(SB1->B1_GRUPO, nTamCol)
		@ 01, 00 VTSay PadR(SB1->B1_CODITE, nTamCol)
		@ 02, 00 VTSay PadR(SB1->B1_DESC, nTamCol)
		If !Localiza(SB1->B1_COD)
			SB5->(DbSetOrder(1))
			SB5->(DbSeek( xFilial("SB5")+SB1->B1_COD))
			@ 03, 00 VTSay PadR(FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")+" "+FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"), nTamCol)
		Else
			@ 03, 00 VTSay PadR(STR0027, nTamCol) // Item Enderecado
		EndIf
		@ 04, 00 VTSay repl("-", nTamCol)
		@ 05, 00 VTSay PadR(STR0028, nTamCol) // Quantidade?
		@ 06, 00 VTGet nQtd Valid nQtd>=0
		VTRead
		If VTLastKey() == 27 // ESC
			lRet := .f.
		EndIf
	EndIf
	If lRet
		//
		aVM8[nLinha,5] := nQtd+nQtdSomar
		OA3400281_GravaQtdConferida( aVM8[nLinha,7] , aVM8[nLinha,5] , "2" )
		OA3400111_StatusConferencia( VM7->VM7_CODIGO , "2" , "2" )
		If !lTelaQtd
			VtBeep(1) // 1 Beep OK
		EndIf
		//
	EndIf
Else
	lRet := .f.
EndIf
Return lRet

/*/{Protheus.doc} OA3500081_DiasRetroagir
Tela Pergunta a Qtde de Dias a Retroagir para levantamento das NFs de Entrada

@author Andre Luis Almeida
@since 19/08/2021
@version undefined
@return lRet, logico, Indica se informou os dias ou foi dado ESC

@type function
/*/
Static Function OA3500081_DiasRetroagir()
Local lRet := .t.
OA3500061_LimpaTelaColetor()
@ 00, 00 VTSay PadR(STR0001, nTamCol) // Conf.Volume Entrada
@ 01, 00 VTSay repl("-", nTamCol)
@ 02, 00 VTSay PadR(Transform(dDataBase,"@D"), nTamCol)
@ 04, 00 VTSay PadR(STR0029, nTamCol) // Dias a retroagir?
@ 05, 00 VTGet nQtdDias Picture "@E 999999" Valid nQtdDias>=0
VTRead
If VTLastKey() == 27 // ESC
	lRet := .f.
EndIf
Return lRet

/*/{Protheus.doc} OA3500091_TelaQualItemConferir
Escolher qual Item que sera Conferido

@author Andre Luis Almeida
@since 19/08/2021
@version undefined

@type function
/*/
Static Function OA3500091_TelaQualItemConferir(cNForn) // Escolher qual Item que sera Conferido
//
cCodSB1 := space(nCodSB1)
OA3500061_LimpaTelaColetor()
//
@ 00, 00 VTSay PadR(STR0001, nTamCol) // Conf.Volume Entrada
@ 01, 00 VTSay PadR(right(VM7->VM7_VOLUME,nTamCol),nTamCol)
@ 02, 00 VTSay PadR(cNForn,nTamCol)
@ 03, 00 VTSay repl("-", nTamCol)
@ 04, 00 VTSay PadR(STR0030, nTamCol) // Qual Item?
@ 05, 00 VTGet cCodSB1 Valid OA3500051_PosicionaSB1comCODBAR(.f.,.f.)
VTRead
//
If VTLastKey() <> 27 // Diferente de ESC
	If Empty(cCodSB1)
		OA3500031_TELA3(.f.) // Mostrar todos os Itens da NF Entrada
	Else
		OA3500031_TELA3(.t.) // Mostrar todos os Itens da NF Entrada ( escolher Item Especifico )
	EndIf
EndIf
//
Return

/*/{Protheus.doc} OA3500101_QualVolume
Tela Pergunta o Volume

@author Andre Luis Almeida
@since 19/08/2021
@version undefined
@return cRet, caracter, Volume

@type function
/*/
Static Function OA3500101_QualVolume(nTam)
Local cRet := space(nTam)
OA3500061_LimpaTelaColetor()
@ 00, 00 VTSay PadR(STR0001, nTamCol) // Conf.Volume Entrada
@ 01, 00 VTSay repl("-", nTamCol)
@ 02, 00 VTSay PadR(STR0031, nTamCol) // Digite
@ 04, 00 VTSay PadR(STR0023, nTamCol) // Volume de Entrada
@ 05, 00 VTGet cRet Picture "@!"
VTRead
If VTLastKey() == 27 // ESC
	cRet := "ESC"
EndIf
Return cRet

/*/{Protheus.doc} OA3500111_TelaMenuOpcoes
Menu de Opcoes

@author Andre Luis Almeida
@since 19/08/2021
@version undefined

@type function
/*/
Static Function OA3500111_TelaMenuOpcoes() // Menu de Opcoes
Local aLinhas  := {}
Local aSize    := {nTamCol}
Local aColunas := {""}
Local cQuery   := ""
Local cNForn   := ""
//
cQuery := "SELECT SA2.A2_NOME "
cQuery += "  FROM "+RetSQLName("VCX")+" VCX "
cQuery += "  JOIN "+RetSQLName("SA2")+" SA2 ON ( SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD=VCX.VCX_FORNEC AND SA2.A2_LOJA=VCX.VCX_LOJA AND SA2.D_E_L_E_T_=' ' ) "
cQuery += " WHERE VCX.VCX_FILIAL='"+xFilial("VCX")+"'"
cQuery += "   AND VCX.VCX_VOLUME='"+VM7->VM7_VOLUME+"'"
cQuery += "   AND VCX.D_E_L_E_T_=' '"
cNForn := PadR(FM_SQL(cQuery), nTamCol)
aColunas := { cNForn }
//
aAdd(aLinhas,{ STR0032 }) // Todos os Itens
aAdd(aLinhas,{ STR0033 }) // Selecionar Item
aAdd(aLinhas,{ STR0034 }) // Itens com Diverg
aAdd(aLinhas,{ STR0010 }) // Finaliza Confer. ?
//
While .t.
	//
	If !OA3500141_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM7
		Exit
	EndIf
	//
	OA3500061_LimpaTelaColetor()
	@ 00, 00 VTSay PadR(STR0001, nTamCol) // Conf.Volume Entrada
	@ 01, 00 VTSay PadR(right(VM7->VM7_VOLUME,nTamCol), nTamCol)
	nPosOpc := VTaBrowse(2,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nPosOpc) // Lista os Itens
	//
	If OA3500141_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM7
		If nPosOpc > 0
			If nPosOpc == 1 // Todos os Itens
				OA3500021_TELA2(cNForn) // T2 - TODOS OS ITENS
			ElseIf nPosOpc == 2 // Selecionar Item
				OA3500091_TelaQualItemConferir(cNForn) // Escolher qual Item que sera Conferido
			ElseIf nPosOpc == 3 // Itens com Diverg
				OA3500121_ListaItensDivergentes()
			Else // Finaliza Confer. ?
				If OA3500041_FinalizaConferencia() // Finaliza Conferencia
					Exit
				EndIf
			EndIf
		Else
			nPosOpc := 1
			Exit
		EndIf
	Else
		Exit
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA3500121_ListaItensDivergentes
Lista os Itens com Divergencia

@author Andre Luis Almeida
@since 19/08/2021
@version undefined

@type function
/*/
Static Function OA3500121_ListaItensDivergentes() // Lista Itens com Divergencia
Local aSize    := {nTamCol}
Local aColunas := {STR0034} // Itens com Diverg
Local aLinhas := {}
Local aLinDiv := {}
Local nCntFor := 0
Local nPosIte := 0
Local cJaConf := ""
//
While .t.
	//
	If !OA3500141_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM7
		Exit
	EndIf
	//
	aLinhas := {}
	aLinDiv := {}
	//
	For nCntFor := 1 to len(aVM8)
		If aVM8[nCntFor,4] <> aVM8[nCntFor,5]
			cJaConf := IIf( aVM8[nCntFor,5] > 0 , "*" , " " ) // Verifica se o Item ja foi Conferido
			aAdd(aLinhas,{ cJaConf + IIf(lVerGrupo,aVM8[nCntFor,2],"") + aVM8[nCntFor,3] })
			aAdd(aLinDiv,nCntFor) // Linha relacionada ao vetor aVM8
		EndIf
	Next
	OA3500061_LimpaTelaColetor()
	If Len(aLinhas) > 0
		aAdd(aLinhas,{ repl("-",nTamCol) })
		aAdd(aLinhas,{ STR0010 }) // Finaliza Confer. ?
		nPosIte := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,1) // Lista os Itens
		If OA3500141_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM7
			If nPosIte > 0
				If nPosIte == len(aLinhas) // Finaliza Confer. ?
					If OA3500041_FinalizaConferencia() // Finaliza / Grava Conferencia
						Exit
					EndIf
				ElseIf nPosIte <> ( len(aLinhas) -1 ) // Diferente de tracos - Item a Item
					If !OA3500071_SomaQTD( aLinDiv[nPosIte] , .t. , 0 ) // DIGITA QTDE PARA ITEM ESPECIFICO
						Exit
					EndIf
				EndIf
			Else
				Exit
			EndIf
		Else
			Exit
		EndIf
	Else
		VTAlert(STR0035,STR0002) // Nenhum Item com Divergencia encontrado! Atencao
		Exit
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA3500131_AdicionaRegistroVM8
Adiciona Item no Vetor aVM8 e na Tabela VM8

@author Andre Luis Almeida
@since 19/08/2021
@version undefined

@type function
/*/
Static Function OA3500131_AdicionaRegistroVM8() // Adiciona Item na tabela VM8 e vetor aVM8
Local nLinha := 0
aAdd(aVM8,{ SB1->(RecNo()) ,;
			SB1->B1_GRUPO  ,;
			SB1->B1_CODITE ,;
			0              ,;
			0              ,;
			SB1->B1_COD    ,;
			0              })
nLinha := len(aVM8)
aVM8[nLinha,7] := OA3400191_AdicionaRegistroVM8( nLinha ) // Adiciona na Tabela VM8
Return nLinha

/*/{Protheus.doc} OA3500141_VerificaStatus
Verifica o Status se pode Continuar na Conferencia VM7

@author Andre Luis Almeida
@since 19/08/2021
@version undefined

@type function
/*/
Static Function OA3500141_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM7
Local lRet := .f.
If VM7->VM7_STATUS $ "1/2" // Status igual a Pendente ou Conferido Parcialmente
	lRet := .t.
EndIf
Return lRet