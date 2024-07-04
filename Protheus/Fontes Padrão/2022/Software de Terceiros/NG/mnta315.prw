#INCLUDE "mnta315.ch"
#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA315
Programa para Distribuicao de Solicitacao de Servico em lote
@author Ricardo Dal Ponte
@since 09/01/2007
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTA315()

	Local aTMPFIELD
	Local bTMPFUNC
	Local cTMPBRW

	Local aNGBEGINPRM := NGBEGINPRM()

	//Verifica se o update de facilities foi aplicado
	If FindFunction("MNTUPDFAC") .And. MNTUPDFAC(.F.)
		ShowHelpDlg(STR0046, {STR0047},1,{STR0048}) //"ATEN��O" ## "O sistema est� utilizando o M�dulo Facilities. Desta forma, a distribui��o em lote deve ser realizada atrav�s da rotina de Distribui��o." ## "Ser� redirecionado para a rotina de Distribui��o."
		MNTA296()
		Return .F.
	EndIf

	Private asMenu

	asMenu := NGRIGHTCLICK("MNTA315")

	Private cTRB315 := GetNextAlias()
	Private oTmpTbl1

	Private aVETINR := {}
	Private cPESQUI := ""
	Private aPESQUI := {STR0001,;  //"Solicita��o"
						STR0002,;  //"Bem/Localiza��o+Servi�o"
						STR0003,;  //"Bem/Localiza��o+Centro Custo+Servi�o"
						STR0004,;  //"Bem/Localiza��o+Data Abertura"
						STR0005,;  //"Solicitante+Servi�o"
						STR0006,;  //"Solicitante+Centro Custo+Servi�o"
						STR0007,;  //"Solicitante+Servi�o+Data Abertura"
						STR0008,;  //"Data Abertura+Solicitante"
						STR0009,;  //"Data Abertura+Centro Custo"
						STR0010,;  //"Servi�o+Centro Custo"
						STR0011}   //"Servi�o+Data Abertura"

	Private aPESQUIF := {"TQB_SOLICI"                             ,;
						 "TQB_CODBEM+TQB_NOMSER"                  ,;
						 "TQB_CODBEM+TQB_NMCUST+TQB_NOMSER"       ,;
						 "TQB_CODBEM+DTOS(TQB_DTABER)"            ,;
						 "TQB_NMSOLI+TQB_NOMSER"                  ,;
						 "TQB_NMSOLI+TQB_NMCUST+TQB_NOMSER"       ,;
						 "TQB_NMSOLI+TQB_NOMSER+DTOS(TQB_DTABER)" ,;
						 "DTOS(TQB_DTABER)+TQB_NMSOLI"            ,;
						 "DTOS(TQB_DTABER)+TQB_NMCUST"            ,;
						 "TQB_NOMSER+TQB_NMCUST"                  ,;
						 "TQB_NOMSER+DTOS(TQB_DTABER)"            }

	Private aCpos      := {}
	Private aCampos    := {}
	Private aRotina    := MenuDef()
	Private cInd1TRB
	Private cMarca
	Private cPAlta     := "1"
	Private cPMedia    := "2"
	Private cPBaixa    := "3"
	Private lSH1       := .F.
	Private lALLMARK   := .F.
	Private bFiltraBrw := {|| Nil}

	Private cCadastro := Oemtoansi(STR0012) //"Distribui��o de Solicita��o de Servico em Lote"
	Private lDigServ  := .T.
	Private lLEABRE   := .F.
	Private lLEFECHA  := .T.
	Private lTEMFACI  := .F.
	Private lSSClassi := .T.
	Private lSSPriori := .T.

	Private aHeader   := {}
	Private cARQUISAI := "XXX"
	Private cPROGRAMA := "MNTA315"
	Private cMarcaEK
	Private cMEMOCHF
	Private cMEMOTEF
	PrivaTe cMEMOTES

	//CRIA ARQUIVO TEMPORARIO
	A315WDET()
	//POPULA TEMPORARIO
	A315ADET()

	dbSelectArea(cTRB315)
	dbSetOrder(12)
	dbGoTop()

	//cMarca   := GetMark()
	cMarcaEK := GetMark()

	MarkBrow(cTRB315,"TQB_MKBROW",,aCpos,,cMarcaEK,'A315ALLMAR(cTRB315)',,,,'A315UNIMAR(cTRB315)')

	oTmpTbl1:Delete()

	Set Filter To

	//+---------------------------------------------------+
	//| Devolve variaveis armazenadas (NGRIGHTCLICK)      |
	//+---------------------------------------------------+
	NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA315DIS
Distribuicao da solicitacao de servico
@author Ricardo Dal Ponte
@since 06/12/2006
@version undefined
@param cCADNOV, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function MNTA315DIS(cCADNOV)

	Local nContX
	Local nContY
	Local cMsgSS    := ""
	Local cDesc     := ""
	Local lEnvWorkf := .F.
	Local lMNTA3153 	:= ExistBlock("MNTA3153")
	Local aSolici   := {}
	Local aOfusc    := {}
	Local nX        := 0
	Local nSolic    := 0
	Local aDistri   := {}
	Local lRPORel17 := IIf(GetRPORelease() <= '12.1.017', .T., .F.) // Release menor ou igual a 17
	Local oGet1
	// [LGPD] Se as funcionalidades, referentes � LGPD, podem ser utilizadas
	Local lLgpd := FindFunction( 'FWPDCanUse' ) .And. FwPdCanUse( .T. )
	Local lEmail := .F.
	Local lNomExe := .F.

	Private cNMRESP  := Space(40)
	Private cCDSERV  := Space(Len(TQ3->TQ3_CDSERV))
	Private cNMSERV  := Space(Len(TQ3->TQ3_NMSERV))
	Private cCDEXEC  := Space(Len(TQ4->TQ4_CDEXEC))
	Private cNMEXEC  := Space(Len(TQ4->TQ4_NMEXEC))
	Private cDESCSS  := Space(80)
	Private aPRIORI  := {}
	PrivaTe cPriori  := ''
	Private oMenu

	If lLgpd
		// [LGPD] Caso o usu�rio n�o possua acesso ao(s) campo(s), deve-se ofusc�-lo(s)
		aOfusc := FwProtectedDataUtil():UsrAccessPDField( __CUSERID, { 'TQ4_EMAIL1', 'TQ4_NMEXEC' } )
		lEmail := Ascan( aOfusc, { |x|  AllTrim(x) == 'TQ4_EMAIL1' } ) == 0
		lNomExe := Ascan( aOfusc, { |x|  AllTrim(x) == 'TQ4_NMEXEC' } ) == 0
	EndIf

	aPRIORI := {STR0013, STR0014, STR0015, ""} //"Alta"###"Media"###"Baixa"###"Sem op��o"

	//--inicio--SS 027048 //
	//Na SS 027048 foi solicitado um ponto de entrada para mostrar registros de todas as filiais na distribui��o de SS.
	//Por�m para distribuir em lote � necess�rio fazer diversas valida��es, visto que pode distruibir de filiais diferente.
	//Nesse caso, o a filial logada � jogada para uma filial de bkp.
	cFilAntBkp := cFilAnt
	//---fim----SS 027048 //

	Private cServ     := ""
	Private lPreenche := .T.
	dbSelectArea(cTRB315)
	dbGoTop()
	While !Eof()
		If (cTRB315)->TQB_MKBROW = cMarcaEK

			//--inicio--SS 027048 //
			//Considera para como filial logada a filial do registro da linha da get dados. A variavel cFilAnt influencia no retorno da dos xFilial,
			//por isso � feita essa valida��o, para sempre validar conforme a filial do registro.
			cFilAnt := (cTRB315)->TQB_FILIAL
			//---fim----SS 027048 //

			dbSelectArea("TQB")
			dbSetOrder (1)
			If dbSeek(xFilial("TQB")+(cTRB315)->TQB_SOLICI)
				If Empty(cServ)
					cServ := TQB->TQB_CDSERV
				EndIf
				If cServ != TQB->TQB_CDSERV
					lPreenche := .F.
				EndIf

				nPos := aSCAN(aSolici,{|x| x[1] == TQB->TQB_CODBEM})
				If nPos > 0
					aAdd(aSolici[nPos],TQB->TQB_SOLICI)
				Else
					aAdd(aSolici,{TQB->TQB_CODBEM,TQB->TQB_SOLICI})
				EndIf
			EndIf
		EndIf
		dbSelectArea(cTRB315)
		dbSkip()
	EndDo

	cFilAnt := cFilAntBkp

	For nContX := 1 To Len(aSolici)
		If Len(aSolici[nContX]) > 2
			For nContY := 2 To Len(aSolici[nContX])
				cMsgSS += "- SS "+aSolici[nContX,nContY]+CHR(13)
			Next nConY
		EndIf

		If !Empty(cMsgSS)
			If !APMSGNOYES(STR0037+CHR(13)+;  //"Foram selecionadas Solicita��es de Servi�o com duplicidade no Bem/Localiza��o"
			STR0038+"'"+AllTrim(aSolici[nContX,1])+"' "+STR0039+AllTrim(NGRETTITULO('TQB_CDSERV'))+":"+; //"para "##"que ser�o distribu�das com o mesmo "
			CHR(13)+cMsgSS+CHR(13)+STR0040,STR0041) //"Deseja prosseguir com a distribui��o?"##"Duplicidade de S.S."
				Return .F.
			Else
				cMsgSS := ""
			EndIf
		EndIf
	Next nContX

	If lPreenche .And. !Empty(cServ)
		cCDSERV := cServ
		A315EXV(cCDSERV)
	EndIf

	nOPCA := 0
	If Len(cCDEXEC) > 15

		DEFINE MSDIALOG oDLGB TITLE OemToAnsi(STR0012) From 15,20 To 34,109 OF oMainWnd //"Distribui��o de Solicita��o de Servico em Lote"
		oDLGB:lMaximized := .t.
		oPanel := TPanel():New(0, 0, Nil, oDLGB, Nil, .T., .F., Nil, Nil, 0, 0, .T., .F. )
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		@ 0.5,01  SAY OemToAnsi(STR0016) SIZE 6,7 OF oPanel 							//"Supervisor"
		@ 0.4,06  MSGET cNMRESP Picture '@!' SIZE 150,7 When .F. OF oPanel

		@ 1.5,01  SAY OemToAnsi(STR0017) SIZE 6,7 COLOR CLR_HBLUE OF oPanel 			//"Tipo Servico"
		@ 1.4,06  MSGET cCDSERV Picture '@!' SIZE 30,7 F3 "TQ3" OF oPanel Valid If(Empty(cCDSERV),.t.,ExistCpo('TQ3',cCDSERV)) .And. A315EXV(cCDSERV) HASBUTTON
		@ 1.5,19  SAY OemToAnsi(STR0018)SIZE 6,7 OF oPanel  							//"Nome Servico"
		@ 1.4,26  MSGET cNMSERV Picture '@!' SIZE 138,7 When .F. OF oPanel

		@ 2.5,01  SAY OemToAnsi(STR0019) SIZE 6,7 COLOR CLR_HBLUE OF oPanel 			//"Executante"
		@ 2.4,06  MSGET cCDEXEC Picture '@!' SIZE 96,7 F3 "TQ4" OF oPanel Valid If(Empty(cCDEXEC),.t.,ExistCpo('TQ4',cCDEXEC)) .And. A315EXEC(cCDEXEC) HASBUTTON
		@ 2.5,19  SAY OemToAnsi(STR0020) SIZE 6,7 OF oPanel 							//"Nome Executante"
		@ 2.4,26  MSGET oGet1 Var cNMEXEC Picture '@!' SIZE 138,7 When .F. OF oPanel
		If lNomExe
			oGet1:lObfuscate := .T.
			oGet1:bWhen := {|| .F. }
		EndIf

		If X3Obrigat("TQB_PRIORI")
			@ 3.5,01  SAY OemToAnsi(STR0021) SIZE 6,7 COLOR CLR_HBLUE OF oPanel 		//"Prioridade"
		Else
			@ 3.5,01  SAY OemToAnsi(STR0021) SIZE 6,7 COLOR CLR_BLACK OF oPanel 		//"Prioridade"
		EndIf
		@ 3.4,06  MSCOMBOBOX cPRIORI ITEMS aPRIORI SIZE 70,12 OF oPanel

		@ 4.5,01  SAY OemToAnsi(STR0022) SIZE 6,7 OF oPanel 							//"Servico"
		@ 4.4,06  GET cDESCSS MULTILINE SIZE 297,55 OF oPanel

	Else

		DEFINE MSDIALOG oDLGB TITLE OemToAnsi(STR0012) From 15,20 To 34,103 OF oMainWnd //"Distribui��o de Solicita��o de Servico em Lote"
		oDLGB:lMaximized := .t.
		oPanel := TPanel():New(0, 0, Nil, oDLGB, Nil, .T., .F., Nil, Nil, 0, 0, .T., .F. )
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		@ 0.5,01  SAY OemToAnsi(STR0016) SIZE 6,7 OF oPanel  							//"Supervisor"
		@ 0.4,06  MSGET cNMRESP Picture '@!' SIZE 150,7 When .F. OF oPanel

		@ 1.5,01  SAY OemToAnsi(STR0017) SIZE 6,7 COLOR CLR_HBLUE OF oPanel  			//"Tipo Servico"
		@ 1.4,06  MSGET cCDSERV Picture '@!' SIZE 30,7 F3 "TQ3" OF oPanel Valid If(Empty(cCDSERV),.t.,ExistCpo('TQ3',cCDSERV)) .And. A315EXV(cCDSERV) HASBUTTON
		@ 1.5,15  SAY OemToAnsi(STR0018)SIZE 6,7 OF oPanel   							//"Nome Servico"
		@ 1.4,22  MSGET cNMSERV Picture '@!' SIZE 145,7 When .F. OF oPanel

		@ 2.5,01  SAY OemToAnsi(STR0019) SIZE 6,7 COLOR CLR_HBLUE OF oPanel  			//"Executante"
		@ 2.4,06  MSGET cCDEXEC Picture '@!' SIZE 64,7 F3 "TQ4" OF oPanel Valid If(Empty(cCDEXEC),.t.,ExistCpo('TQ4',cCDEXEC)) .And. A315EXEC(cCDEXEC) HASBUTTON
		@ 2.5,15  SAY OemToAnsi(STR0020) SIZE 6,7 OF oPanel  							//"Nome Executante"
		@ 2.4,22  MSGET oGet1 Var cNMEXEC Picture '@!' SIZE 145,7 When .F. OF oPanel
		If lNomExe
			oGet1:lObfuscate := .T.
			oGet1:bWhen := {|| .F. }
		EndIf

		If X3Obrigat("TQB_PRIORI")
			@ 3.5,01  SAY OemToAnsi(STR0021) SIZE 6,7 COLOR CLR_HBLUE OF oPanel  		//"Prioridade"
		Else
			@ 3.5,01  SAY OemToAnsi(STR0021) SIZE 6,7 COLOR CLR_BLACK OF oPanel  		//"Prioridade"
		EndIf
		@ 3.4,06  MSCOMBOBOX cPRIORI ITEMS aPRIORI SIZE 70,12 OF oPanel

		@ 4.5,01  SAY OemToAnsi(STR0022) SIZE 6,7 OF oPanel 		 					//"Servico"
		@ 4.4,06  GET cDESCSS MULTILINE SIZE 272,55 OF oPanel

	EndIf

	NGPOPUP(aSMenu,@oMenu,oPanel)
	oPanel:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oPanel)}

	ACTIVATE MSDIALOG oDLGB ON INIT EnchoiceBar(oDLGB,{||nOPCA:=1,IIf(!A315OKD(aSolici, @aDistri),nOPCA:= 0,oDLGB:End())},{||oDLGB:End()})

	INCLUI   := .F.
	lDigServ := .T.

	If nOPCA = 1
		dbSelectArea(cTRB315)
		dbGoTop()

		While !Eof()
			If (cTRB315)->TQB_MKBROW = cMarcaEK
				dbSelectArea("TQB")
				dbSetOrder (1)

				//--inicio--SS 027048 #
				//Considera para como filial logada a filial do registro da linha da get dados. A variavel cFilAnt influencia no retorno da dos xFilial,
				//por isso � feita essa valida��o, para sempre validar conforme a filial do registro.
				cFilAnt := (cTRB315)->TQB_FILIAL
				//---fim----SS 027048 #

				If dbSeek(xFilial("TQB")+(cTRB315)->TQB_SOLICI)

					//--inicio--SS 027048 #
					//Caso o cliente esteja utilizando o ponto de entrada, ser� obrig�torio ter o Executante e o C�digo de Servi�o tanto na filial logada,
					//quanto na filial do registro que ta sendo distribuido.
					If lMNTA3153
						dbSelectArea("TQ3")
						dbSetOrder(1)
						If !dbSeek(xFilial("TQ3") + cCDSERV)
							MsgStop(STR0049 + (cTRB315)->TQB_SOLICI + Chr(13) + Chr(10) + ; // "N�o foi possivel fazer a distribui��o da seguinte SS: "
							Chr(13) + Chr(13) + STR0050     + Chr(13) + Chr(10) +         ; // "Motivo: O c�digo de servi�o, n�o existe na filial. "
							STR0051 + cCDSERV + STR0052 + xFilial("TQ3"))                   // "Solu��o: Incluir o c�digo de servi�o " + " na filial "
							dbSelectArea(cTRB315)
							dbSkip()
							Loop
						Else
							If !NGSEEKCPO("TQ4",cCDEXEC,1,(cTRB315)->TQB_FILIAL,.F.)
								MsgStop(STR0049   + (cTRB315)->TQB_SOLICI + Chr(13) + Chr(10) + ; // "N�o foi possivel fazer a distribui��o da seguinte SS: "
								Chr(13) + Chr(13) + STR0053  + Chr(13)    + Chr(10) +           ; // "Motivo: O executante n�o existe na filial. "
								STR0054 + Alltrim(cCDEXEC)   + STR0052    + xFilial("TQ3"))       // "Solu��o: Incluir o executante " + " na filial "
								dbSelectArea(cTRB315)
								dbSkip()
								Loop
							EndIf
						EndIf
					EndIf
					//---fim----SS 027048 #

					cDesc := AllTrim(Msmm(TQB->TQB_CODMSS,,,,3))
					cDesc += CRLF+cDESCSS
					//Condi��o para gravar "branco" (campo n�o preenchido)
					nPriori := aSCAN(aPRIORI, {|x| x == cPRIORI})
					If nPriori == 4 //O 4 � uma op��o que n�o existe no TQB_PRIORI que fica como "indefinido" na legenda
						cPriori := ""
					Else
						cPriori := Alltrim(Str(aSCAN(aPRIORI, {|x| x == cPRIORI})))
					EndIf

					If lRPORel17
						RecLock("TQB",.F.)

						TQB->TQB_CDSERV := cCDSERV
						TQB->TQB_CDEXEC := cCDEXEC
						TQB->TQB_PRIORI := cPriori
						TQB->TQB_SOLUCA := "D"

						MSMM(TQB->TQB_CODMSS,,,cDesc,1,,,"TQB","TQB_CODMSS")

						TQB->(MsUnLock())
					EndIf

					RecLock(cTRB315,.F.)
					(cTRB315)->( dbDelete() )
					(cTRB315)->(MsUnLock())

					If lRPORel17
						lEnvWorkf := MNTW040((cTRB315)->TQB_SOLICI,cCDEXEC,cCDSERV)//Workflow disparado para o Executante da S.S.
					EndIf
				EndIf
			EndIf

			dbSelectArea(cTRB315)
			dbSkip()
		End

		If !lRPORel17
			// Faz a grava��o
			nSolic := Len(aDistri)
			If nSolic > 0
				For nX := 1 To nSolic
					aDistri[nX]:assign() // M�todo para Distribui��o.
				Next nX
			EndIf
		EndIf

	EndIf

	cFilAnt := cFilAntBkp

	If lEnvWorkf
		If lEmail
			MsgInfo(STR0036+".") // "Aviso da Distribui��o de S.S. enviado para o executante"
		Else
			MsgInfo(STR0036+": "+AllTrim(NGSEEK("TQ4",cCDEXEC,1,"TQ4_EMAIL1"))+".") //"Aviso da Distribui��o de S.S. enviado para o executante"
		EndIf
	EndIf

	dbSelectArea(cTRB315)
	dbGoTop()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A315EXV
Carrega Responsavel da Solicitacao de Servico
@author Ricardo Dal Ponte
@since 29/01/07
@version undefined
@param cCdServ, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function A315EXV(cCdServ)

	Local cRetCdResp := ""
	Local cAlias     := Alias()
	Local cSavOrd    := IndexOrd()
	Local cCodUser   := CriaVar("AN_USER")

	dbSelectArea("TQ3")
	dbSetOrder(1)

	cNMSERV    := ""

	If dbSeek(xFilial("TQ3")+cCdServ)
		cRetCdResp := TQ3->TQ3_CDRESP
		cNMSERV    := TQ3->TQ3_NMSERV
	Endif

	PswOrder(2)

	If PswSeek(cRetCdResp)
		cCodUser := PswRet(1)[1][1]
	EndIf

	dbSelectArea(cAlias)
	dbSetOrder(cSavOrd)

	cNMRESP := Alltrim(SubStr(UsrFullName(cCodUser), 1, 40))

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A315EXEC
Executante  da Solicitacao de Servico
@author Ricardo Dal Ponte
@since 29/01/07
@version undefined
@param cCDEXEC, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function A315EXEC(cCDEXEC)

	dbSelectArea("TQ4")
	dbSetOrder(1)

	cNMEXEC    := ""

	If dbSeek(xFilial("TQ4")+cCDEXEC)
		cNMEXEC := TQ4->TQ4_NMEXEC
	Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A315OKD
Consistencia final antes da distribuicao
@author Ricardo Dal Ponte
@since 29/01/2007
@version undefined
@type function
@param aSolici, array, array de solicita��es para validar.
@param aDistri, array, ser� adicionado os objetos para distribui��o na Classe.
/*/
//---------------------------------------------------------------------
Static Function A315OKD(aSolici, aDistri)

	Local nTamTot := Len(aSolici)
	Local nTam2   := 0
	Local nInd    := 0
	Local nInd2   := 0
	Local oTQB    := Nil // Classe de S.S.

	Local aArea     := GetArea()
	Local aBENS     := {}
	Local lRet      := .T.
	Local nRegTQB   := TQB->(RecNo())
	Local nCont
	Local nQtdD     := 0
	Local lRPORel17 := IIf(GetRPORelease() <= '12.1.017', .T., .F.) // Release menor ou igual a 17

	Default aDistri := {}

	If !lRPORel17

		For nInd := 1 To nTamTot
			nTam2   := Len(aSolici[nInd])
			For nInd2 := 2 To nTam2

				oTQB := MntSR():New()
				// Determina a opera��o de Altera��o.
				oTQB:setOperation(4)

				// N�o apresenta mensagens condicionais
				oTQB:setAsk(.F.)

				oTQB:Load( { xFilial("TQB") + aSolici[nInd][nInd2] } )

				// Transfere os valores do Objeto para a Mem�ria.
				oTQB:setValue("TQB_CDSERV", cCDSERV)
				oTQB:setValue("TQB_CDEXEC", cCDEXEC)

				// Define que � o processo de distribui��o
				oTQB:setValue( 'TQB_SOLUCA', 'D' ) 

				// Define prioridade da solicita��o
				oTQB:setValue( 'TQB_PRIORI', IIf( ( nPriori := aScan( aPriori, { |x| x == cPriori } ) ) == 4, '', AllTrim( Str( nPriori ) ) ) )

				// Concatena observa��o do processo de distribui��o com o j� contido na abertura da S.S.
				oTQB:setValue( 'TQB_DESCSS', Trim( MSMM( TQB->TQB_CODMSS, , , , 3 ) ) + CRLF + Trim( cDESCSS ) )

				//Verifica se os registros s�o v�lidos para realizar a inclus�o
				If !oTQB:valid()
					oTQB:showHelp()
					oTQB:Free()
					lRet := .F.
					exit
				Else
					aAdd(aDistri, oTQB)
				EndIf
			Next nInd2
		Next nInd

	Else

		//Para melhorar a mensagem foram feitas tr�s condi��es
		If Empty(cCDSERV)
			MsgInfo(STR0055,STR0024) //"Campo Servi�o n�o informado."###"N�O CONFORMIDADE"
			Return .F.
		ElseIf Empty(cCDEXEC)
			MsgInfo(STR0056,STR0024) //"Campo Executante n�o informado."###"N�O CONFORMIDADE"
			Return .F.
		ElseIf (X3Obrigat("TQB_PRIORI") .And. Empty(cPRIORI))
			MsgInfo(STR0057,STR0024) //"Campo Prioridade n�o informado."###"N�O CONFORMIDADE"
			Return .F.
		EndIf

		dbSelectArea(cTRB315)
		dbGoTop()
		While !Eof()
			If (cTRB315)->TQB_MKBROW = cMarcaEK
				dbSelectArea("TQB")
				dbSetOrder (1)
				If dbSeek(xFilial("TQB")+(cTRB315)->TQB_SOLICI)
					nPos := aSCAN(aBENS,{|x| x == TQB->TQB_CODBEM})
					If nPos == 0
						aAdd(aBENS,(cTRB315)->TQB_CODBEM)
					EndIf
				EndIf
			EndIf
			dbSelectArea(cTRB315)
			dbSkip()
		EndDo

		For nCont := 1 To Len(aBENS)
			nQtdD := 0
			If lRet
				//ALERTA DUPLICIDADE DE SS (CODBEM+CDSERV)
				dbSelectArea("TQB")
				dbSetOrder(05)
				dbSeek(xFilial("TQB")+aBENS[nCont],.T.)
				While lRet .And. !Eof() .And. TQB->TQB_FILIAL == xFilial("TQB") .And. TQB->TQB_CODBEM == aBENS[nCont]
					If TQB->TQB_CDSERV == cCDSERV .And. TQB->TQB_SOLUCA == "D" //somente distribuidas
						nQtdD++
					EndIf
					dbSkip()
				EndDo
				If nQtdD > 0
					If !APMSGYESNO(STR0042+CHR(13)+; 						   //"Existe pelo menos uma Solicita��o de Servi�o distribu�da"
					STR0043+" '"+AllTrim(aBENS[nCont])+"' "+STR0044+CHR(13)+;  //"para o mesmo bem/localiza��o"##"e servi�o desta S.S."
					STR0045,STR0041) 										   //"Deseja confirmar a distribui��o?"##"Duplicidade de S.S."
						lRet := .F.
					EndIf
				EndIf
			Else
				Exit
			EndIf
		Next nCont

		TQB->(dbGoTo(nRegTQB))
		RestArea(aArea)

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional
@author Ricardo Dal Ponte
@since 29/11/2006
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aROTINA := {{STR0025,"A315Pq()"     , 0, 1},;  //"Pesquisar"
					  {STR0026,"A315CHASS()"  , 0, 2},;  //"Visualizar"
					  {STR0027,"MNTA315DIS()" , 0, 4}}   //"Distribuir"

	//+---------------------------------------------------------------------+
	//| Parametros do array a Rotina:                                       |
	//|             1. Nome a aparecer no cabecalho                         |
	//|             2. Nome da Rotina associada                             |
	//|             3. Reservado                                            |
	//|             4. Tipo de Transa��o a ser efetuada:                    |
	//|             	1 - Pesquisa e Posiciona em um Banco de Dados       |
	//|                 2 - Simplesmente Mostra os Campos                   |
	//|                 3 - Inclui registros no Bancos de Dados             |
	//|                 4 - Altera o registro corrente                      |
	//|                 5 - Remove o registro corrente do Banco de Dados    |
	//|             5. Nivel de acesso                                      |
	//|             6. Habilita Menu Funcional                              |
	//+---------------------------------------------------------------------+

	If ExistBlock("MNTA3151")
		_aRotina := ExecBlock("MNTA3151",.F.,.F.,{aRotina})
		If (ValType(_aRotina) == "A")
			aRotina := ACLONE(_aRotina)
		EndIf
	EndIf

Return(aRotina)

//---------------------------------------------------------------------
/*/{Protheus.doc} A315WDET
Cria Arquivos Temporarios para o detalhamento das SS
@author Ricardo Dal Ponte
@since 25/01/2007
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function A315WDET()

	aCampos := ()

	dbselectArea("TQB")
	dbGoTop()

	aCampos := DbStruct()
	Aadd(aCampos,{"TQB_MKBROW", "C", 2 , 0})
	Aadd(aCampos,{"TRB_FILIAL", "C", 2 , 0})
	Aadd(aCampos,{"TQB_NMTIPO", "C", 11, 0})
	Aadd(aCampos,{"TQB_NOMEBM", "C", 23, 0})
	Aadd(aCampos,{"TQB_NMCUST", "C", 23, 0})
	Aadd(aCampos,{"TQB_NOMCTR", "C", 20, 0})
	Aadd(aCampos,{"TQB_NOMLOC", "C", 20, 0})
	Aadd(aCampos,{"TQB_NOMSER", "C", 20, 0})
	Aadd(aCampos,{"TQB_NMSOLI", "C", 20, 0})

	//Intancia classe FWTemporaryTable
	oTmpTbl1:= FWTemporaryTable():New( cTRB315, aCampos )

	oTmpTbl1:AddIndex( "Ind01" , {"TQB_SOLICI"}                            )
	oTmpTbl1:AddIndex( "Ind02" , {"TQB_CODBEM","TQB_NOMSER"}               )
	oTmpTbl1:AddIndex( "Ind03" , {"TQB_CODBEM","TQB_NMCUST","TQB_NOMSER"}  )
	oTmpTbl1:AddIndex( "Ind04" , {"TQB_CODBEM","TQB_DTABER"}               )
	oTmpTbl1:AddIndex( "Ind05" , {"TQB_NMSOLI","TQB_NOMSER"}               )
	oTmpTbl1:AddIndex( "Ind06" , {"TQB_NMSOLI","TQB_NMCUST","TQB_NOMSER"}  )
	oTmpTbl1:AddIndex( "Ind07" , {"TQB_NMSOLI","TQB_NOMSER","TQB_DTABER"}  )
	oTmpTbl1:AddIndex( "Ind08" , {"TQB_DTABER","TQB_NMSOLI"} 			   )
	oTmpTbl1:AddIndex( "Ind19" , {"TQB_DTABER","TQB_NMCUST"} 		   	   )
	oTmpTbl1:AddIndex( "Ind10" , {"TQB_NOMSER","TQB_NMCUST"}			   )
	oTmpTbl1:AddIndex( "Ind11" , {"TQB_NOMSER","TQB_DTABER"}			   )
	oTmpTbl1:AddIndex( "Ind12" , {"TQB_CDSERV","TQB_SOLICI"}			   )

	//Cria a tabela temporaria
	oTmpTbl1:Create()

	aCpos := {}
	aaDD(aCpos,{"TQB_MKBROW", NIL, ""})
	Aadd(aCpos,{"TQB_SOLICI", NIL, NGSEEKDIC("SX3","TQB_SOLICI",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_NMTIPO", NIL, NGSEEKDIC("SX3","TQB_TIPOSS",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_CDSERV", NIL, NGSEEKDIC("SX3","TQB_CDSERV",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_NOMSER", NIL, NGSEEKDIC("SX3","TQB_NMSERV",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_CODBEM", NIL, NGSEEKDIC("SX3","TQB_CODBEM",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_NOMEBM", NIL, NGSEEKDIC("SX3","TQB_NOMBEM",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_NMCUST", NIL, NGSEEKDIC("SX3","TQB_CCUSTO",2,"X3_TITULO")+Space(5)})
	Aadd(aCpos,{"TQB_NOMCTR", NIL, NGSEEKDIC("SX3","TQB_CENTRA",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_NOMLOC", NIL, NGSEEKDIC("SX3","TQB_LOCALI",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_DTABER", NIL, NGSEEKDIC("SX3","TQB_DTABER",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_HOABER", NIL, NGSEEKDIC("SX3","TQB_HOABER",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_RAMAL" , NIL, NGSEEKDIC("SX3","TQB_RAMAL" ,2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_NMSOLI", NIL, NGSEEKDIC("SX3","TQB_CDSOLI",2,"X3_TITULO")})

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A315ADET
Popula arquivo temporario
@author Ricardo Dal Ponte
@since 25/01/2007
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function A315ADET()

	dbSelectArea("TQB")
	dbSetOrder (1)

	cChave  := IndexKey()
	cFilPRI := ""

	//--inicio--SS 027048 #
	// Ponto de Entrada para alterar filtro da filial.
	If ExistBlock("MNTA3153")
		cFilPRI := ExecBlock("MNTA3153",.F.,.F.)
	Else
		cFilPRI := " TQB_FILIAL == '"+xFilial('TQB')+"' .And. "
	EndIf
	//---fim----SS 027048 #

	cFilPRI +="TQB_SOLUCA == 'A'"

	If ExistBlock("MNTA3152")
		_cFil := ExecBlock("MNTA3152",.F.,.F.)
		If (ValType(_cFil) == "C")
			cFilPRI += _cFil
		EndIf
	EndIf

	dbSelectArea("TQB")
	dbGoTop()

	While !Eof()

		If &cFilPRI.

			dbSelectArea(cTRB315)
			Reclock((cTRB315),.T.)

			(cTRB315)->TQB_FILIAL := TQB->TQB_FILIAL
			(cTRB315)->TQB_SOLICI := TQB->TQB_SOLICI
			(cTRB315)->TQB_TIPOSS := TQB->TQB_TIPOSS

			If  (cTRB315)->TQB_TIPOSS  = "B"
				(cTRB315)->TQB_NMTIPO := STR0029 //"Bem"
			EndIf

			If  (cTRB315)->TQB_TIPOSS  = "L"
				(cTRB315)->TQB_NMTIPO := STR0030 //"Localiza��o"
			EndIf

			(cTRB315)->TQB_CODBEM := TQB->TQB_CODBEM
			(cTRB315)->TQB_CCUSTO := TQB->TQB_CCUSTO
			(cTRB315)->TQB_CENTRA := TQB->TQB_CENTRA
			(cTRB315)->TQB_LOCALI := TQB->TQB_LOCALI

			//CARREGA DESCRICOES
			A315BEMLOC(TQB->TQB_TIPOSS)

			(cTRB315)->TQB_DTABER := TQB->TQB_DTABER
			(cTRB315)->TQB_HOABER := TQB->TQB_HOABER
			(cTRB315)->TQB_RAMAL  := TQB->TQB_RAMAL

			(cTRB315)->TQB_CDSERV := TQB->TQB_CDSERV
			(cTRB315)->TQB_NOMSER := ""

			dbSelectArea("TQ3")
			dbSetOrder(1)

			If dbSeek((cTRB315)->TQB_FILIAL+(cTRB315)->TQB_CDSERV)
				(cTRB315)->TQB_NOMSER := SubStr(TQ3->TQ3_NMSERV,1,20)
			EndIf

			(cTRB315)->TQB_CDSOLI := TQB->TQB_CDSOLI
			(cTRB315)->TQB_NMSOLI := UsrRetName((cTRB315)->TQB_CDSOLI)
			(cTRB315)->(MsUnlock())
		EndIf

		dbSelectArea("TQB")
		dbSkip()
	End

	DbSelectArea("TQB")
	Set Filter To

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A315BEMLOC
Retorno da descricao do bem/localizacao
@author Ricardo Dal Ponte
@since 27/01/2007
@version undefined
@param cTIPOS, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function A315BEMLOC(cTIPOS)

	If cTIPOS = "B"
		If !NGSEEKCPO("ST9",(cTRB315)->TQB_CODBEM,1,(cTRB315)->TQB_FILIAL,.T.)
			Return .T.
		Endif

		(cTRB315)->TQB_NOMEBM  := NGSEEK("ST9",(cTRB315)->TQB_CODBEM,1,"T9_NOME"   ,(cTRB315)->TQB_FILIAL)
		(cTRB315)->TQB_NMCUST  := NGSEEK("CTT",(cTRB315)->TQB_CCUSTO,1,"CTT_DESC01",(cTRB315)->TQB_FILIAL)
		(cTRB315)->TQB_NOMLOC  := NGSEEK("TPS",(cTRB315)->TQB_LOCALI,1,"TPS_NOME"  ,(cTRB315)->TQB_FILIAL)
		(cTRB315)->TQB_NOMCTR  := NGSEEK("SHB",(cTRB315)->TQB_CENTRA,1,"HB_NOME"   ,(cTRB315)->TQB_FILIAL)
	Else
		dbSelectArea("TAF")
		dbSetOrder (7)
		If !dbSeek((cTRB315)->TQB_FILIAL+"X2"+Substr((cTRB315)->TQB_CODBEM,1,3))
			Return .T.
		Endif
		If cTIPOS = "L"
			(cTRB315)->TQB_NOMEBM := TAF->TAF_NOMNIV
			(cTRB315)->TQB_NMCUST := NGSEEK("CTT",(cTRB315)->TQB_CCUSTO,1,"CTT_DESC01",(cTRB315)->TQB_FILIAL)
			(cTRB315)->TQB_NOMCTR := NGSEEK("SHB",(cTRB315)->TQB_CENTRA,1,"HB_NOME"   ,(cTRB315)->TQB_FILIAL)
			(cTRB315)->TQB_NOMLOC := Space(Len((cTRB315)->TQB_LOCALI))
		Endif
	Endif

Return .T.


//---------------------------------------------------------------------
/*/{Protheus.doc} A315ALLMAR
Marca/Desmarca todos os registros do browse
@author Ricardo Dal Ponte
@since 27/01/07
@version undefined
@param cAlias, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function A315ALLMAR(cAlias)

	CursorWait()

	dbSelectArea(cAlias)
	nRecno := &(cAlias)->(Recno())
	dbGoTop()

	While !Eof()
		RecLock(cAlias,.F.)
		If lALLMARK = .T.
			&(cAlias)->(TQB_MKBROW) := "  "
		Else
			&(cAlias)->(TQB_MKBROW) := cMarcaEK
		EndIf
		&(cAlias)->(MsUnLock())
		dbSkip()
	End

	lALLMARK := !lALLMARK
	&(cAlias)->(dbGoto(nRecno))

	CursorArrow()
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A315UNIMAR
Marca/Desmarca o registro do browse
@author Ricardo Dal Ponte
@since 27/01/07
@version undefined
@param cAlias, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function A315UNIMAR(cAlias)

	CursorWait()

	dbSelectArea(cAlias)

	RecLock(cAlias,.F.)
	If &(cAlias)->(TQB_MKBROW) = cMarcaEK
		&(cAlias)->(TQB_MKBROW) := "  "
	Else
		&(cAlias)->(TQB_MKBROW) := cMarcaEK
	Endif
	&(cAlias)->(MsUnLock())

	CursorArrow()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A315CHASS
Abre a Visualizacao da Solicitacao de Servico
@author Ricardo Dal Ponte
@since 27/01/07
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function A315CHASS()

	Local aNao
	Local nRecnoTRBD
	Local nSOLICI
	Local lFacilities := SuperGetMv("MV_NG1FAC",.F.,"2") == '1'

	dbSelectArea(cTRB315)
	nRecnoTRBD := (cTRB315)->(Recno())
	nSOLICI    := (cTRB315)->TQB_SOLICI

	If Empty(nSOLICI)
		MsgInfo(STR0031,STR0032) //"Nenhuma Solicita��o de Servi�o foi selecionada para visualiza��o."###"INFORMA��O"
		Return .T.
	EndIf
	aNao	  := {"TQB_OBSATE","TQB_OBSPRA"}
	//Se n�o utilizar Facilities dever� remover estes campos da tela
	If !lFacilities
		aAdd(aNao, "TQB_LOCALI")
		aAdd(aNao, "TQB_NOMLOC")
	EndIf
	aChoice	  := NGCAMPNSX3("TQB",aNao)

	aRotina   := {{STR0025 ,"AxPesqui",0,1},; //"Pesquisar"
				  {STR0026 ,"NGCAD01" ,0,2}}  //"Visualizar"

	cCadastro := OemtoAnsi(STR0033)           //"Visualiza��o da Solicita��o de Servi�o"

	CursorWait()

	dbSelectArea("TQB")
	dbSetOrder (1)
	dbSeek(xFilial("TQB")+nSOLICI)

	NGCAD01('TQB',Recno(),2)
	CursorArrow()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A315Pq
Pesquisas genericas
@author Jorge Queiroz
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function A315Pq()

	Local oPanel

	Private CFILTRO := Space(60)

	cPESQUI := aPESQUI[1]
	nOPCA   := 0

	DEFINE MSDIALOG oDLGC TITLE OemToAnsi(STR0034) From 10,14 To 20,58 OF oMainWnd //"Distribui��o de Solicita��o de Servico em Lote - Pesquisa"

	@ 1.6,01  SAY OemToAnsi(STR0025+":") SIZE 6,7 COLOR CLR_BLUE OF oDLGC          //"Pesquisar"
	@ 2.4,01  MSCOMBOBOX cPESQUI ITEMS aPESQUI SIZE 125,12 OF oDLGC
	@ 3.4,01  MSGET cFILTRO Picture '@!' SIZE 160,7 OF oDLGC
	@ 5.4,29.5  Button STR0035 Size 50,12 Action (oDLGC:End()) OF oDLGC           //"&Pesquisar"


	ACTIVATE MSDIALOG oDLGC ON INIT EnchoiceBar(oDLGC,{||nOPCA:=1,oDLGC:End()},{||oDLGC:End()})

	INCLUI := .F.
	lDigServ := .T.
	nPOS := aSCAN(aPESQUI, {|x| x == cPESQUI})

	dbSelectArea(cTRB315)
	dbSetOrder(nPOS)

	dbSeek(Alltrim(cFILTRO),.T.)
	cFILCMP := ""

Return
