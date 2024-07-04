#Include "TMSME10.CH"
#Include "PROTHEUS.CH"

Static lTME10CPO  := ExistBlock("TME10CPO")
Static lTME10VLI  := ExistBlock("TME10VLI")	// -- Permite o cancelamento da gravacao de todos arquivos configurados, qdo diferente do princ.
Static lTME10GRV  := ExistBlock("TME10GRV")	// -- Pto Logo apos a gravacao do arquivo.
Static lTME10Vld  := ExistBlock("TME10VLD")
Static lTME10FIM  := ExistBlock("TME10FIM") // Ponto de Entrada posicionado no termino do processamento de Importacao
Static cNumMrp    := ""
Static aRepMrp    := {}

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSME10  ³ Autor ³ Eduardo de Souza      ³ Data ³ 23/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ EDI - Importacao (Recebimento)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSME10()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                  ATUALIZACOES - VIDE SOURCE SAFE                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSME10()

Local cPerg    := "TMME10"
Local cIndex   := ""
Local cFiltro  := ""
Local cArqInd  := CriaTrab(,.F.)
Local cNomArq  := ""
Local aAreaDEC := DEC->(GetArea())
Local nCnt     := 0
Local aNomArq  := {}
Local cNomeAr  := ""
Local aFiles   := {}
Local lFatAuto := .F.
Local lCGCDEV  := DEB->(ColumnPos("DEB_CGCDEV")) > 0 
Local cTempPre := ""
Local oTrabPre := Nil
Local aTrbCpos := {}
Local aPreFat  := Nil

Local lTMSEDIIM := ExistBlock("TMSEDIIM")

Private lMsErroAuto := .F.
Private cCadastro   := STR0001 // "EDI - Recebimento"
Private cDirRec     := AllTrim(GetMv("MV_EDIDIRR"))
Private cDirMov     := AllTrim(GetMv("MV_EDIRMOV"))
Private lRet        := .t.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica/Inclui barra no final do diretorio.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Right(cDirRec,1) # "\"
	cDirRec += "\"
Endif

If Right(cDirMov,1) # "\"
	cDirMov += "\"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Pergunte a ser utilizado. Todos perguntes devem comecar ³
//³ com Cliente De / Loja De / Cliente Ate / Loja Ate, para verifica-  ³
//³ cao na amarracao Cliente x Layout.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock("TMSEDIREC"))
	cPerg := AllTrim(ExecBlock("TMSEDIREC",.F.,.F.))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Pergunte(cPerg,.T.)

	DbSelectArea("DEC")
	DbSetOrder(1)

	cIndex	:= DEC->(IndexKey())

	cFiltro := 'DEC_FILIAL == "' + xFilial("DEC") + '" .And. '
	cFiltro += 'DEC_CODCLI + DEC_LOJCLI >= "' + mv_par01 + mv_par02 + '" .And. '
	cFiltro += 'DEC_CODCLI + DEC_LOJCLI <= "' + mv_par03 + mv_par04 + '"'

	IndRegua("DEC",cArqInd,cIndex,,cFiltro,STR0002) //"Selecionando Registros..."
	DbGotop()

	While DEC->(!Eof())	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o tipo do Layout eh Recebimento. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Posicione("DE9",1,xFilial("DE9")+DEC->DEC_CODLAY,"DE9_TIPLAY") == "2" // Recebimento
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida se o nome do Arquivo eh valido.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TMSME10Mac(DEC->DEC_NOMARQ,@cNomArq)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada que permite alterar o nome do Arquivo. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lTMSEDIIM
					cNomArq := ExecBlock("TMSEDIIM",.F.,.F.,cNomArq)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se o conteudo do nome do arquivo eh palavra cha-³
				//³ ve. Ex: Nome Arquivo: "SIGA", encontrado SIGA3500.TXT    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !File(cDirRec+cNomArq)
				
					aDir(cDirRec+"*.*",aFiles) //-- Retorna todos arquivos do Diretorio.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Busca nos arquivos a Palavra Chave.                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len(aFiles) > 0
						For nCnt:= 1 To Len(aFiles)
							If At(cNomArq,aFiles[nCnt]) > 0
								aAdd(aNomArq,aFiles[nCnt])
							EndIf
						Next nCnt
					EndIf
				
				Else
					aDir(cDirRec+cNomArq,aNomArq)
				EndIf
		
				//-- Verifica no perfil do cliente se a Pré-fatura deve ser Chamada
				lFatAuto := .F.
				If lCGCDEV
					aPerfil := TmsPerfil(DEC->DEC_CODCLI,DEC->DEC_LOJCLI,,.F.)
					If Len(aPerfil) >= 61 .And. ValType(aPerfil[61]) == "A" .And. Len(aPerfil[61]) >= 7 .And. aPerfil[61][2] == "1"
						lFatAuto := .T.
						/* Cria tabela Temporária do Alias */
						cTempPre := GetNextAlias()
						oTrabPre := FWTemporaryTable():New( cTempPre )						
						
						aAdd(aTrbCpos,{ "DEB_OK"     ,"C", TamSX3("DUD_OK"    )[1], TamSX3("DUD_OK"    )[2]} ) 
						aAdd(aTrbCpos,{ "DEB_CGCDEV" ,"C", TamSX3("DEB_CGCDEV")[1], TamSX3("DEB_CGCDEV")[2]} ) 
						aAdd(aTrbCpos,{ "DEB_NUMPRE" ,"C", TamSX3("DEB_NUMPRE")[1], TamSX3("DEB_NUMPRE")[1]} ) 
						oTrabPre:SetFields( aTrbCpos )
					
						oTrabPre:AddIndex("01", {"DEB_CGCDEV","DEB_NUMPRE"} )

						oTrabPre:Create()
					EndIf
				EndIf

				For nCnt:= 1 To Len(aNomArq)
		
					cNomeAr := aNomArq[nCnt]
					Processa({|| TMSME10Proc(DEC->DEC_CODLAY,cNomeAr,lFatAuto,oTrabPre)})

				Next nCnt

				If lFatAuto
					Eval({|| aPreFat := {}, Tmsae45Doc( oTrabPre:GetRealName(), @aPreFat), Tmsae45Prc(aPreFat,1), aPreFat := {}})
					oTrabPre:Delete()
					aTrbCpos := {}
				EndIf
			Else
				AutoGRLog(DEC->DEC_CODLAY + " - " + STR0004 + ": " +AllTrim(Posicione("SA1",1,xFilial("SA1")+DEC->DEC_CODCLI+DEC->DEC_LOJCLI,"A1_NOME")) + " - " + STR0013) //"Cliente" ### "O nome do Arquivo, nao foi configurado corretamente no cadastro Cliente x Layout"
			EndIf
		EndIf

		DbSelectArea("DEC")
		DbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga o Arquivo de Trabalho.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArqInd += OrDbagExt()
	Delete File &(cArqInd)

	RetIndex ( "DEC" )
	RestArea ( aAreaDEC )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apresenta o Log na Tela.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//-- Apresenta Tela De Registros MRP Que Não Puderam Ser Reprocessados
	If Len(aRepMrp) > 0
		TMSA019Prc( aRepMrp , 2 )
	ElseIf lMSErroAuto
		MostraErro()
	EndIf
EndIf

//-- Ponto de entrada ao termino da rotina de Importacao
If lTME10FIM
	ExecBlock("TME10FIM", .F., .F. )
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSME10Proc³ Autor ³ Eduardo de Souza     ³ Data ³ 23/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Importacao para arquivos TXT                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSME10Proc()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSME10()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSME10Proc(cCodLay,cNomArq,lFatAuto,oTrabPre)

Local aAreaDE0    := DE0->(GetArea())
Local aNomArq     := {}
Local nCnt        := 0
Local cAliasReg   := ""
Local cChvReg     := ""
Local cValidReg   := ""
Local nOrdReg     := 0
Local lPriRegAtu  := .T.
Local cIdtReg     := ""
Local aDadosPrinc := {}
Local nPos        := 0
Local lErrImp     := .F.
Local nPosErr     := 0
Local lTMSEDICImp := Iif(ExistBlock("TMSEDICImp"),ExecBlock("TMSEDICImp",.F.,.F.),.F.)
Local aAliasPrinc := Iif(ExistBlock("TMSEDIALI") ,ExecBlock("TMSEDIALI" ,.F.,.F.,{cCodLay}),"")
Local lRegDupl    := .F.
Local aMRP        := {}
Local aPrwDF0     := {}
Local aPrwDF1     := {}
Local aPrwDF2     := {}
Local aRecDDD     := {}
Local cFileLog    := Alltrim(NomeAutoLog())
Local EDIFile	  := GFEXFILE():New()
Local lTME10ATU := ExistBlock("TME10ATU")
Local lTME10ARQ := ExistBlock("TME10ARQ")

Default lFatAuto := .F.
Default oTrabPre := Nil

//O retorno do Ponto de Entrada "TMSEDIALI" devera ser um array
//[N][1] - Alias
//[N][2] - Ordem
//[N][3] - Chave (IndexKey() do alias, pois, a montagem da chave sera efetuada na gravacao)
//[N][4] - Validacao

Private aCpoKEYSEC	 := {}
Private aGrvPrinc    := {}
Private cLinTxt      := ""
Private __cEDILinTxt := ""
Private __aItensEDI  := {}
Private lImportOk    := .T.

aadd(aNomArq, cNomArq)

If ValType(aAliasPrinc) <> "A"
	aAliasPrinc := {}
EndIf

//-- Limpa Logs Antigos
If File( cFileLog ) .And. !Empty( cFileLog ) 
	Ferase( cFileLog )
EndIf	

DbSelectArea("DE0")
DbSetOrder(2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Importa todos arquivos encontrados.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCnt:= 1 To Len(aNomArq)

	If File(cDirRec+aNomArq[nCnt])

		lPriRegAtu := .T.
		lImportOk  := .T.
		nPosErr    := 0
		lErrImp    := .F.
		cNumMrp    := ""

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Abre arquivo texto e Posiciona no inicio do arquivo. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		EDIFile:Clear()
		EDIFile:Open(cDirRec+aNomArq[nCnt])
		ProcRegua(EDIFile:nQtdeLin)		

		//-- Inicializa o Controle Transacional (TTS)
		Begin Transaction

			While !EDIFile:FEof() .And. lImportOk
	
				IncProc()
	
				//-- Verifica se o arquivo
				If Empty(AllTrim(EDIFile:Line()))
					EDIFile:FNext()
					Loop
				EndIf
	
				__cEDILinTxt := EDIFile:Line()
				cLinTxt      := __cEDILinTxt
	
				If Empty(cIdtReg)
					//-- Controla Identificador de Registro
					If DEC->(FieldPos("DEC_IDENTI")) > 0
						If DEC->DEC_IDENTI == "1" .And. DEC->(FieldPos("DEC_TAMIDT")) > 0
							cIdtReg := Substr(cLinTxt,1,DEC->DEC_TAMIDT)
						EndIf
					Else
						cIdtReg := Substr(cLinTxt,1,Len(DE0->DE0_IDTREG))
					EndIf
				EndIf
	
				//-- Retorna os dados principais para continuar a importacao do arquivo.
				If lErrImp
					If ( nPos := Ascan( aDadosPrinc, { |x| x[1] == cIdtReg }) ) > 0
						If nPos == 1
							lPriRegAtu := .T.
							aGrvPrinc  := {}
							aCpoKEYSEC := {}
						ElseIf nPos <= nPosErr
							aGrvPrinc  := AClone(aDadosPrinc[nPos-1,2])
						Else
							EDIFile:FNext()
				   		cIdtReg := ""
							Loop
						EndIf 
					   lErrImp := .F.
					Else
						EDIFile:FNext()
			   		cIdtReg := ""
						Loop
					EndIf
				EndIf
	
				DbSelectArea("DE0")
				DbSetOrder(2) //-- DE0_FILIAL+DE0_CODLAY+DE0_IDTREG
				If MsSeek(xFilial("DE0")+cCodLay+cIdtReg)
	
					If lPriRegAtu
						If !Empty(DE0->DE0_ALIAS)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Valida Alias                                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If FindFunction("ALIASINDIC") .And. AliasInDic(DE0->DE0_ALIAS)
								cAliasReg := DE0->DE0_ALIAS
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Verifica se Existe a Ordem Selecionada.     	     ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If Val(DE0->DE0_POSORD) > 0 .And. !Empty(&(cAliasReg)->(IndexKey(Val(DE0->DE0_POSORD))))
									nOrdReg := Val(DE0->DE0_POSORD)
								Else
									nOrdReg := 1
								EndIf
	
								If !Empty(AllTrim(DE0->DE0_POSCHV))
									cChvReg := AllTrim(DE0->DE0_POSCHV)
								EndIf
	
								If !Empty(DE0->DE0_VALID)
									cValidReg := AllTrim(DE0->DE0_VALID)
								EndIf
								lPriRegAtu := .F.
							EndIf
							//-- Armazena chave para gravacao dos alias principais
	 						Aadd( aAliasPrinc, { cAliasReg, nOrdReg, cChvReg, cValidReg } )
						EndIf
				    EndIf
					If !lPriRegAtu
						
						//-- Gravação da Linha
						If !TMSME10Atu(cCodLay,DE0->DE0_CODREG,cLinTxt,aNomArq[nCnt],aAliasPrinc,lFatAuto,oTrabPre) .And. lTMSEDICImp
							lImportOk := .T.
							lErrImp   := .T.
						EndIf
						
						//-- Armazena informacoes do registro atual, para continuacao da importacao, no caso de erro.
						If lTMSEDICImp
							If ( nPosErr := Ascan( aDadosPrinc, { |x| x[1] == DE0->DE0_IDTREG })) > 0 .And. !lErrImp
								If nPosErr == 1
									aDadosPrinc := {}
									Aadd( aDadosPrinc, { DE0->DE0_IDTREG, AClone(aGrvPrinc) } )
								Else
									aDadosPrinc[nPosErr,2] := AClone(aGrvPrinc)
								EndIf
							ElseIf nPosErr == 0
								Aadd( aDadosPrinc, { DE0->DE0_IDTREG, AClone(aGrvPrinc) } )
							EndIf
						EndIf
					EndIf
			    EndIf
	
				//-- Verifica se existe registro complementar
				If lErrImp .Or. lPriRegAtu .Or. Empty(DE0->DE0_CODRCP)
					EDIFile:FNext()
		   			cIdtReg := ""
				Else
					cIdtReg := Posicione("DE0",1,xFilial("DE0")+cCodLay+DE0->DE0_CODRCP,"DE0_IDTREG")
				EndIf
			EndDo
	
		   	If !TMSME10Vld(aAliasPrinc)
				lRegDupl := .T.
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Na finalizacao da importacao, grava as ultimas infor-³
			//³ macoes do arquivo.                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aGrvPrinc) > 0 .And. !lPriRegAtu .And. !lRegDupl
				ME10GrvArq(aAliasPrinc,lFatAuto,oTrabPre)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada utilizado para atualizacao de dados  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lTME10ATU
					ExecBlock("TME10ATU",.F.,.F., { cNomArq })
				EndIf
			EndIf
	
			If lTME10ARQ
				ExecBlock("TME10ARQ",.F.,.F., { cNomArq })
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nao Encontrado Alias para importacao                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lPriRegAtu
				AutoGRLog(aNomArq[nCnt]+" - "+DEC->DEC_CODLAY + " - " + STR0004 + ": " +AllTrim(Posicione("SA1",1,xFilial("SA1")+DEC->DEC_CODCLI+DEC->DEC_LOJCLI,"A1_NOME")) + " - " + STR0003) //"Cliente" ### "Nao foi encontrado o Alias na configuracao do Layout para realizacao da importacao dos arquivos."
				lImportOk := .F.
			EndIf
	
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Importacao realizada com sucesso                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lImportOk .And. !lRegDupl
				AutoGRLog(aNomArq[nCnt]+" - "+DEC->DEC_CODLAY + " - " + STR0004 + ": " +AllTrim(Posicione("SA1",1,xFilial("SA1")+DEC->DEC_CODCLI+DEC->DEC_LOJCLI,"A1_NOME")) + " - " + STR0015) //"Cliente" ### "Importacao realizada com sucesso!!!!"
			EndIf

		//-- Finaliza Controle Transacional (TTS)
		End Transaction

		If lImportOk .Or. lRegDupl
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Copia o arquivo p/ outro diretorio e apaga do atual. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			__CopyFile(cDirRec+aNomArq[nCnt],cDirMov+aNomArq[nCnt])
			If File(cDirMov+aNomArq[nCnt])
				FErase(cDirRec+aNomArq[nCnt])
			Endif

		EndIf

		//----------------------------------------------------------------------------
		// Rotina Sera Executada Somente Se O Campo Duo_Ageaut Estiver Criado No
		// Dicionario De Dados (TMSA019)
		//----------------------------------------------------------------------------
		DbSelectArea("DUO")
		If lImportOk .And. ( ColumnPos("DUO_AGEAUT") > 0 )
		
			DbSelectArea("DE0")
			DbSetOrder(2) //-- DE0_FILIAL+DE0_CODLAY+DE0_IDTREG
			If MsSeek(xFilial("DE0") + cCodLay ) .And. DE0->DE0_ALIAS $ "DDD|DDE"
				
				TMSAgAUT( DEC->DEC_CODCLI, DEC->DEC_LOJCLI, cCodLay, Nil, @aPrwDF0, @aPrwDF1, @aPrwDF2, @aRecDDD )
				
				If !Empty(cNumMrp)
					aAdd( aMRP ,{ cNumMrp })
				EndIf	
			EndIf
		EndIf	
	EndIf
Next nCnt

//-- Se Vetores De Preview Estiverem Carregados, Gerar Tela
If Len(aPrwDF0) > 0 

	TmsAF74( aPrwDF0, aPrwDF1, aPrwDF2, aRecDDD )

EndIf

//-- Mostra Tela De Resultado Do Processamento (Somente Para MRP)
If FindFunction("TMSA019") .And. Len(aMrp) > 0
	TMSA019Prc(aMrp)
EndIf

RestArea ( aAreaDE0 )

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSME10Atu ³ Autor ³ Eduardo de Souza     ³ Data ³ 23/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza Arquivo de Importacao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSME10Atu()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSME10                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSME10Atu(cCodLay,cCodReg,cLinTxt,cNomArq,aAliasPrinc,lFatAuto,oTrabPre)

Local   lValid    := .F.
Local   cCampo    := ""
Local   aGrvAux   := {}
Local   aGrvCpos  := {}
Local   nPosA     := 0
Local   lRet      := .T.
Local   nX        := 0
Local   nCnt      := 0
Local   aCpoTemp  := {}
Local	cAlias	  := ""

Default lFatAuto := .F.
Default oTrabPre := Nil

Private __XEdiCont
Private __cNomArq := cNomArq

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Importa os dados, conforme Itens config. p/ Layout.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("DE1")
DbSetOrder(2)
If MSSeek(xFilial("DE1")+cCodLay+cCodReg)
	While !Eof() .And. DE1_FILIAL+DE1_CODLAY+DE1_CODREG == xFilial("DE0")+cCodLay+cCodReg .And. lImportOk

		lValid := .T.

		If !Empty(DE1->DE1_ALIAS)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o Alias Existe                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If FindFunction("ALIASINDIC") .And. AliasInDic(DE1->DE1_ALIAS)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valida se o campo configurado existe.                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (DE1->DE1_ALIAS)->(FieldPos(AllTrim(DE1->DE1_CAMPO))) > 0

					cCampo	   := SubStr(cLinTxt,Val(DE1->DE1_POSINI),DE1->DE1_LAYTAM)
					__XEdiCont := cCampo

					If !Empty(DE1->DE1_REGRA)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Valida Regra                                 	     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !TMSME10Mac(AllTrim(DE1->DE1_REGRA),@cCampo)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Existe problema na Regra do campo                    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							AutoGRLog(cNomArq + " - " + STR0014 + " " +(DE1->DE1_ALIAS)+"->"+(DE1->DE1_CAMPO) + " " + STR0009 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG + "- " + STR0018 + ": " + __XEdiCont) // "Existe problema na regra do campo" ### "configurado no registro:"
							lImportOk := .F.
							Exit
						EndIf
						__XEdiCont := cCampo
					EndIf

					If ValType((DE1->DE1_ALIAS)->&(DE1->DE1_CAMPO)) $ "D"		// Data
						If ValType(cCampo) <> "D"
							cCampo	:=	StoD(SubStr(cCampo,5,4)+SubStr(cCampo,3,2)+SubStr(cCampo,1,2))
						EndIf
					ElseIf ValType((DE1->DE1_ALIAS)->&(DE1->DE1_CAMPO)) == "N"	// Numerico
						cDec := "1"
						For nX := 1 To DE1->DE1_LAYDEC
							cDec := cDec + "0"
						Next nX
						If ValType(cCampo) <> "N"
							cCampo := Val(cCampo)/Val(cDec)
						Else
							cCampo := cCampo/Val(cDec)
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se exise Validacao.                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(DE1->DE1_VALID)
						TMSME10Mac(AllTrim(DE1->DE1_VALID),@lValid)
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Armazena Informacoes para Gravacao.                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lValid

						If Ascan(aAliasPrinc, { |x| x[1] == DE1->DE1_ALIAS}) > 0
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Armazena dados do Alias Principal.                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (nPosA := aScan(aGrvPrinc,{|x| AllTrim(UPPER(x[2])) == AllTrim(DE1->DE1_CAMPO)})) == 0
								aAdd(aGrvPrinc,{DE1->DE1_ALIAS,DE1->DE1_CAMPO,cCampo,Valtype(cCampo),DE1->DE1_LAYTAM,DE1->DE1_LAYDEC})

								If (DE1->(ColumnPos("DE1_ITESEC")) > 0) 
									If !Empty(DE1->DE1_ITESEC)
										aCpoTemp := STRTOKARR (DE1->DE1_ITESEC, "," )

										For nCnt := 1 To Len(aCpoTemp)
											If !Empty(AllTrim( aCpoTemp[ nCnt ] )) .And. aScan(aCpoKEYSEC,{|x| AllTrim(UPPER(x[2])) == AllTrim( aCpoTemp[ nCnt ] ) } ) == 0
												cAlias := GetSx3Cache(aCpoTemp[ nCnt ],"X3_ARQUIVO")
												aAdd(aCpoKEYSEC, { cAlias, AllTrim( aCpoTemp[ nCnt ] ), cCampo, Val(DE1->DE1_POSORD), DE1->DE1_POSCHV} )
											EndIf

										Next nCnt
									EndIf
								EndIf

							Else
								If!TMSME10Vld(aAliasPrinc,nPosA,cCampo)
									lRet := .F.
								EndIf

								If lRet
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Quando encontrar registro ja inserido no array, grava³
									//³ informacoes no arquivo.                              ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									ME10GrvArq(aAliasPrinc,lFatAuto,oTrabPre)
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Copia dados necessarios para a proxima gravacao.     ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aGrvAux := {}
								For nCnt:= 1 To nPosA-1
									aAdd(aGrvAux,{})
								Next nCnt
								aCopy(aGrvPrinc,aGrvAux,1,nPosA-1)
								aGrvPrinc := aClone(aGrvAux)
								
								If Len(aGrvPrinc) == 0 
									aCpoKEYSEC := {}
								EndIf

								aAdd(aGrvPrinc,{DE1->DE1_ALIAS,DE1->DE1_CAMPO,cCampo,Valtype(cCampo),DE1->DE1_LAYTAM,DE1->DE1_LAYDEC})

								If (DE1->(ColumnPos("DE1_ITESEC")) > 0)
									If !Empty(DE1->DE1_ITESEC)
										aCpoTemp := STRTOKARR (DE1->DE1_ITESEC, "," )

										For nCnt := 1 To Len(aCpoTemp)
											If !Empty(AllTrim( aCpoTemp[ nCnt ] )) .And. aScan(aCpoKEYSEC,{|x| AllTrim(UPPER(x[2])) == AllTrim( aCpoTemp[ nCnt ] ) } ) == 0
												cAlias := GetSx3Cache(aCpoTemp[ nCnt ],"X3_ARQUIVO")  
												aAdd(aCpoKEYSEC, { cAlias, AllTrim( aCpoTemp[ nCnt ] ), cCampo, Val(DE1->DE1_POSORD), DE1->DE1_POSCHV} )
											EndIf

										Next nCnt
									EndIf
								EndIf

								aGrvAux   := {}
							EndIf

							//---------------------------------------------------------//
							//-- Gravação Adicional De Campos De Controle Do Sistema --//
							//---------------------------------------------------------//
							
							//-- Verifica De Tabela é 'DDD'
							If Ascan(aAliasPrinc, { |x| x[1] == 'DDD'}) > 0
							
								//-- Verifica Se Campo Já Existe No Vetor De Gravação
								If aScan(aGrvPrinc,{|x| AllTrim(UPPER(x[2])) == "DDD_ARQUIV"}) == 0
									aAdd(aGrvPrinc,{ "DDD" , "DDD_ARQUIV" , cNomArq , "C" , TamSX3("DDD_ARQUIV")[1] , 0 })
								EndIf
								
								//-- Verifica Se Campo Já Existe No Vetor De Gravação
								If aScan(aGrvPrinc,{|x| AllTrim(UPPER(x[2])) == "DDD_CODLAY"}) == 0
									aAdd(aGrvPrinc,{ "DDD" , "DDD_CODLAY" , cCodLay , "C" , TamSX3("DDD_CODLAY")[1] , 0 })
								EndIf
							EndIf	
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Armazena dados de Alias diferente do Principal.      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aAdd(aGrvCpos,{DE1->DE1_ALIAS,DE1->DE1_CAMPO,cCampo,Val(DE1->DE1_POSORD),DE1->DE1_POSCHV})
						EndIf
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Nao atendeu a validacao do campo                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						AutoGRLog(cNomArq + " - " + STR0011 + " " +(DE1->DE1_ALIAS)+"->"+(DE1->DE1_CAMPO) + " " + STR0012 + " " + STR0009 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Nao foi possivel a importacao do Campo" ### "por nao atender a validacao" ### "configurado no registro:"
						lImportOk := .F.
						Exit
					EndIf
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Campo nao existe                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AutoGRLog(cNomArq + " - " + STR0010 + " " +(DE1->DE1_ALIAS)+"->"+(DE1->DE1_CAMPO) + " " + STR0009 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Nao Existe o Campo" ### "configurado no registro:"
					lImportOk := .F.
					Exit
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Alias nao existe                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AutoGRLog(cNomArq + " - " + STR0008 + " " +DE1->DE1_ALIAS + " " + STR0009 + " "+AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Nao Existe o Alias" ### "configurado no registro:"
				lImportOk := .F.
				Exit
			EndIf
		EndIf
		__XEdiCont := ""
		DbSelectArea("DE1")
		DbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava todos arquivos config. diferente do Alias Princ.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aGrvCpos) > 0 .And. lImportOk
		ME10GrvCpos(aGrvCpos,cNomArq)
	EndIf

EndIf

Return lImportOk

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSME10Mac³ Autor ³ Eduardo de Souza      ³ Data ³ 30/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina verificadora da macro digitada.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSME10Mac()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSME10                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSME10Mac(cMacro,xResult)

Local bBlock := ErrorBlock()

Private lRet:=.T.

If Empty(cMacro)
    Return .T.
Endif

Begin Sequence
	xResult := &cMacro
End Sequence

ErrorBlock(bBlock)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ME10GrvArq³ Autor ³ Eduardo de Souza      ³ Data ³ 30/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Informacoes no Arquivo                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ME10GrvArq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSME10                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ME10GrvArq(aAliasPrinc,lFatAuto,oTrabPre)

Local lValidReg := .F.
Local lValidMrp := .T.
Local cCpo      := ""
Local cChvArq   := ""
Local aAreaAnt  := {}
Local nPosA     := 0
Local nCnt      := 0
Local n2Cnt     := 0
Local cValidReg := ""
Local cChvReg   := ""
Local nOrdReg   := 0
Local cAliasReg := ""
Local aGrvOri   := aClone(aGrvPrinc)
Local nSeek     := 0
Local nPosIni   := 0
Local nPosFim   := 0

Default lFatAuto := .F.
Default oTrabPre := Nil

aGrvPrinc := Asort(aGrvPrinc,,,{|x,y| x[1] > y[1] })

For n2Cnt := 1 To Len(aAliasPrinc)

	cChvArq   := ""
	cAliasReg := aAliasPrinc[n2Cnt,1] // Alias
	nOrdReg   := aAliasPrinc[n2Cnt,2] // Ordem
	cChvReg	 := aAliasPrinc[n2Cnt,3] // Chave
	cValidReg := aAliasPrinc[n2Cnt,4] // Validacao
	aAreaAnt  := (cAliasReg)->(GetArea())

	DbSelectArea(cAliasReg)
	DbSetOrder(nOrdReg)

	//-- Atualiza a Chave da Pesquisa
	While !Empty(cChvReg)
		cCpo:= SubStr(cChvReg,1,At("+",cChvReg)-1)
		//-- Se nao encontrou "+", atualiza o ultimo item da chv

		If "(" $ cCpo .Or. ")" $ cCpo
		   nPosIni := At("(",cCpo) + 1
		   nPosFim := ( At(")",cCpo) ) - nPosIni
		   cCpo := Substr(cCpo, nPosIni, nPosFim )
		EndIf

 		If Empty(cCpo)
			cCpo    := cChvReg  
			If "(" $ cCpo .Or. ")" $ cCpo
			   nPosIni := At("(",cCpo) + 1
			   nPosFim := ( At(")",cCpo) ) - nPosIni
			   cCpo := Substr(cCpo, nPosIni, nPosFim )
			EndIf   
			cChvReg := ""
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se eh filial, se nao atualiza a nova chave  ³
		//³ com os dados encontrados no array.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If At("_FILIAL",cCpo) > 0
			cChvArq+= xFilial(cAliasReg)
		Else 
			If (nPosA := aScan(aGrvPrinc,{|x| AllTrim(UPPER(x[2])) == AllTrim(cCpo) })) > 0  
				If aGrvPrinc[nPosA,4] == "D"
					cChvArq += Dtos( aGrvPrinc[nPosA,3])
				ElseIf aGrvPrinc[nPosA,4] == "N"
					cChvArq += Str( aGrvPrinc[nPosA,3], aGrvPrinc[nPosA,5], aGrvPrinc[nPosA,6] )
				Else
					cChvArq+= aGrvPrinc[nPosA,3]
				EndIf
			EndIf
		EndIf
		cChvReg:= SubStr(cChvReg,At("+",cChvReg)+1)
	EndDo

	//-- Localiza o alias no array principal para gravacao.
	nSeek := Ascan( aGrvPrinc, { |x| x[1] == cAliasReg } )

	If !Empty(nSeek) .And. !Empty(cChvArq) .And. MsSeek(cChvArq)
		
		//-- Verifica No MetaDado De Trata-Se Do MRP
		If cAliasReg == 'DDD'

			//-- Se Status Do Registro Igual a Processado (3), Não Reprocessa Registro
			If DDD->DDD_STATUS == '3'

				lValidMrp := .F.
				
				//-- Gera Vetor De Informação Dos MRPs Com Status '3' Que Não Podem Ser Reprocessados
				If aScan( aRepMrp , {|x| (x[2]) == DDD->(Recno()) } ) == 0 
					aAdd( aRepMrp , { DDD->DDD_NUMMRP , DDD->(Recno()) })
				EndIf				
			EndIf
		ElseIf	cAliasReg == 'DDE'					

			//-- Posiciona No Cabeçalho Da Tabela Do MRP
			DbSelectArea("DDD")
			DbSetOrder(1) //-- DDD_FILIAL+DTOS(DDD_DATAGE)+DDD_HORAGE+DDD_CLIDES+DDD_LOJDES+DDD_SQEDES+DDD_CLIREM+DDD_LOJREM+DDD_SQEREM
			MsSeek( xFilial("DDD") + DtoS(DDE->DDE_DATAGE) + DDE->DDE_HORAGE + DDE->DDE_CLIDES + DDE->DDE_LOJDES + DDE->DDE_SQEDES + DDE->DDE_CLIREM + DDE->DDE_LOJREM + DDE->DDE_SQEREM )
					
			//-- Se Status Do Registro Igual a Processado (3), Não Reprocessa Registro
			If DDD->DDD_STATUS == '3'

				lValidMrp := .F.
				
				//-- Gera Vetor De Informação Dos MRPs Com Status '3' Que Não Podem Ser Reprocessados
				If aScan( aRepMrp , {|x| (x[2]) == DDD->(Recno()) } ) == 0 
					aAdd( aRepMrp , { DDD->DDD_NUMMRP , DDD->(Recno()) })
				EndIf				
			EndIf
		EndIf		
		
		//-- Se o campo estiver preenchido, valida os registros.
		If !Empty(cValidReg)
			TMSME10Mac(cValidReg,@lValidReg)
		Else
			lValidReg := .T.
		EndIf
		
		//-- Altera Registro
		If lValidReg .And. lValidMrp
			RecLock(cAliasReg,.F.)
			For nCnt := nSeek To Len(aGrvPrinc)
				If aGrvPrinc[nCnt,1] == cAliasReg
					(cAliasReg)->(&(aGrvPrinc[nCnt,2])):= aGrvPrinc[nCnt,3]
				Else
					Exit
				EndIf
			Next nCnt
			
			//-- Gravação Automática Dos Campos DDD_NUMMRP e DDE_NUMMRP (TMSA019)
			If cAliasReg $ 'DDD|DDE'
				If Empty(cNumMrp)
					cNumMrp := GetSx8Num("DDD","DDD_NUMMRP")
					ConfirmSx8()
				EndIf
				
				If 	cAliasReg == "DDD"
					If (DDD->(FieldPos("DDD_NUMMRP")) > 0)
						Replace DDD->DDD_NUMMRP With cNumMrp
					EndIf
				ElseIf cAliasReg == "DDE"
					If (DDE->(FieldPos("DDE_NUMMRP")) > 0)
						Replace DDE->DDE_NUMMRP With cNumMrp
					EndIf
				EndIf
			EndIf			
			
			(cAliasReg)->(MsUnlock())

			If lFatAuto .And. cAliasReg == "DEB"
				ME10TmpPre(oTrabPre)
			EndIf

		EndIf
		
	Else
		//-- Inclui Registro
		RecLock(cAliasReg,.T.)
		(cAliasReg)->(&(Iif(Left(cAliasReg,1) == "S",Right(cAliasReg,2),cAliasReg)+"_FILIAL")) := xFilial(cAliasReg)
		For nCnt := nSeek To Len(aGrvPrinc)
			If aGrvPrinc[nCnt,1] == cAliasReg
				(cAliasReg)->(&(aGrvPrinc[nCnt,2])):= aGrvPrinc[nCnt,3]
			Else
				Exit
			EndIf
		Next nCnt

		//-- Gravação Automática Dos Campos DDD_NUMMRP e DDE_NUMMRP (TMSA019)
		If cAliasReg $ 'DDD|DDE'
			If Empty(cNumMrp)
				cNumMrp := GetSx8Num("DDD","DDD_NUMMRP")
				ConfirmSx8()
			EndIf
				
			If 	cAliasReg == "DDD"
				If (DDD->(ColumnPos("DDD_NUMMRP")) > 0)
					Replace DDD->DDD_NUMMRP With cNumMrp
				EndIf
			ElseIf cAliasReg == "DDE"
				If (DDE->(ColumnPos("DDE_NUMMRP")) > 0)
					Replace DDE->DDE_NUMMRP With cNumMrp
				EndIf
			EndIf
		EndIf			

		(cAliasReg)->(MsUnlock())

		If lFatAuto .And. cAliasReg == "DEB"
			ME10TmpPre(oTrabPre)
		EndIf

		If lTME10GRV 	// -- Pto Logo apos a gravacao do arquivo.
			ExecBlock("TME10GRV", .F., .F.,{cAliasReg})
		EndIf
	EndIf

	RestArea( aAreaAnt )
Next n2Cnt

aGrvPrinc := aClone(aGrvOri)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ME10GrvCpos³ Autor ³ Eduardo de Souza     ³ Data ³ 26/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava todos arquivos configurados, qdo diferente do princ. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ME10GrvCpos(ExpA1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpA1 - Campos a serem gravados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSME10                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ME10GrvCpos(aGrvCpos,cNomArq)

Local nCnt      := 0
Local nCount	:= 0
Local cAliasAnt := ""
Local aArea     := GetArea()
Local aAreaAnt  := {}
Local lPulaReg  := .F.
Local lRet		 := .T.
Local nPosicao	:= 0

If lTME10VLI // -- Permite o cancelamento da gravacao de todos arquivos configurados, qdo diferente do princ.
	lRet:= ExecBlock("TME10VLI",.F.,.F.,{aGrvCpos,DE0->DE0_IDTREG})
	If ValType(lRet) == 'L' .And. !lRet
		Return
	EndIf
EndIf

//---------------------------------------------------------
//³ Adicionar Os Campos Chave Que Serao Herdados Do Alias
//³ Principal Ao Alias Secundario 						 
//---------------------------------------------------------
If Len(aCpoKEYSEC) > 0 
	For nCount := 1 To Len(aCpoKEYSEC)
		nPosicao := 0
		nPosicao := Ascan( aGrvCpos, { |x| x[2] == AllTrim(aCpoKEYSEC[ nCount ][2]) } )
		
		//---------------------------------------------------------
		// Caso O Campo Existente No Alias Principal Seja
		// Encontrado No Vetor Do Alias Secundario
		//---------------------------------------------------------
		If nPosicao > 0
			If Empty( AllTrim(aGrvCpos[ nPosicao ][3]) )
				aGrvCpos[ nPosicao ][3] := aCpoKEYSEC[ nCount ][3]
			EndIf
		Else
			aAdd( aGrvCpos, aCpoKEYSEC[ nCount ])
		EndIf
	Next nCount
EndIf

Asort(aGrvCpos,,,{|x,y| x[1]+AllTrim(Str(x[4]))+x[5] > y[1]+AllTrim(Str(y[4]))+y[5] })

For nCnt:= 1 To Len(aGrvCpos)

	DbSelectArea(aGrvCpos[nCnt,1])
	aAreaAnt  := GetArea()
	cAliasAnt := aGrvCpos[nCnt,1]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Existe a Ordem Selecionada.     	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aGrvCpos[nCnt,4] > 0 .And. !Empty(IndexKey(aGrvCpos[nCnt,4]))
		DbSetOrder(aGrvCpos[nCnt,4])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a chave esta preenchida.        	     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(AllTrim(aGrvCpos[nCnt,5]))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os campos informados na config. do Layout.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(&(aGrvCpos[nCnt,5]))
				Exit
			EndIf
				
			If MsSeek(&(aGrvCpos[nCnt,5]))
			
				//-- Verifica No MetaDado De Trata-Se Do MRP
				If aGrvCpos[1,1] $ 'DDD|DDE'
					
					//-- Posiciona No Cabeçalho Da Tabela Do MRP
					DbSelectArea("DDD")
					DbSetOrder(1) //-- DDD_FILIAL+DTOS(DDD_DATAGE)+DDD_HORAGE+DDD_CLIDES+DDD_LOJDES+DDD_SQEDES+DDD_CLIREM+DDD_LOJREM+DDD_SQEREM
					MsSeek( xFilial("DDD") + DtoS(DDE->DDE_DATAGE) + DDE->DDE_HORAGE + DDE->DDE_CLIDES + DDE->DDE_LOJDES + DDE->DDE_SQEDES + DDE->DDE_CLIREM + DDE->DDE_LOJREM + DDE->DDE_SQEREM )
					
					//-- Se Status Do Registro Igual a Processado (3), Não Reprocessa Registro
					If DDD->DDD_STATUS == '3'
						Exit
					EndIf
				EndIf		
			
				RecLock(aGrvCpos[nCnt,1],.F.)

			Else

				RecLock(aGrvCpos[nCnt,1],.T.)	

			EndIf

			For nCnt:= nCnt To Len(aGrvCpos)
				If aGrvCpos[nCnt,1] == cAliasAnt
					(aGrvCpos[nCnt,1])->&(aGrvCpos[nCnt,2]) := aGrvCpos[nCnt,3]
				Else
					RestArea ( aAreaAnt )
					nCnt--
					Exit
				EndIf				
			Next nCnt		
			
			//-- Gravação Automática Dos Campos DDD_NUMMRP e DDE_NUMMRP
			If aGrvCpos[1,1] $ 'DDD|DDE'
				If Empty(cNumMrp)
					cNumMrp := GetSx8Num("DDD","DDD_NUMMRP")
					ConfirmSx8()
				EndIf
				
				If 	aGrvCpos[1,1] == "DDD"
					If (DDD->(ColumnPos("DDD_NUMMRP")) > 0)
						Replace DDD->DDD_NUMMRP With cNumMrp
					EndIf
				ElseIf aGrvCpos[1,1] == "DDE"
					If (DDE->(ColumnPos("DDE_NUMMRP")) > 0)
						Replace DDE->DDE_NUMMRP With cNumMrp
					EndIf
				EndIf
			EndIf		  		
			
			MsUnlock()		

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de Entrada utilizado para atualizacao de dados  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTME10CPO
				ExecBlock("TME10CPO",.F.,.F., { cNomArq, aGrvCpos })
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chave para o Alias nao existe                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AutoGRLog(cNomArq + " - " + STR0005 + " " + aGrvCpos[nCnt,1] + " " + STR0006 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Chave para o Alias" ### "nao configurada no registro:"
			lPulaReg  := .T.
			lImportOk := .F.
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ordem para a chave nao existe                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AutoGRLog(cNomArq + " - " + STR0007 + " " +aGrvCpos[nCnt,1] + " " + STR0006 + " " +AllTrim(DE0->DE0_CODLAY)+"/"+DE0->DE0_CODREG) // "Ordem da Chave para o Alias" ### "nao configurada no registro:"
		lPulaReg  := .T.
		lImportOk := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao encontrar chave ou ordem da chave de posiciona-³
	//³mento, pula o registro. 							     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPulaReg
		For nCnt:= nCnt To Len(aGrvCpos)
			If aGrvCpos[nCnt,1] <> cAliasAnt
				RestArea ( aAreaAnt )
				nCnt--
				Exit
			EndIf
		Next nCnt
		lPulaReg := .F.
	EndIf

Next nCnt

RestArea ( aArea )

If Len(aAreaAnt) > 0
	RestArea ( aAreaAnt )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSME10VldºAutor  ³Raphael Zampieri    º Data ³24/06/2009   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se existe registro gravado na tabela DE5            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSME10Vld(aAliasPrinc,nPosA,cCampo)
Local 	lRet      	:= .T.
Local 	nPosCGC   	:= 0  
Local 	nPosDoc   	:= 0  
Local 	nPosSer   	:= 0   
Local 	n2Cnt     	:= 0  
Local 	cConteudo 	:= ""   
Local 	cAliasReg 	:= ""
Local    nPosPrd     := 0
Default	nPosA		:= 0
Default cCampo		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada utilizado para validar a atualizacao dos dados.   ³
//³ se o ponto de entrada existir a validação será feita por ele nao   ³
//³ irá ser chamada a função TMSME10VLD.							   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTME10VLD
	lRet := ExecBlock("TME10VLD",.F.,.F.,{nPosA,cCampo})
ElseIf aScan( aAliasPrinc, { | x |  x[1] == "DE5" } ) > 0 // ASM 26/10/2012 --> Checar somente se houver alias do DE5

	For n2Cnt := 1 To Len(aAliasPrinc)
		lRet:= .T.

		cAliasReg := aAliasPrinc[n2Cnt,1]
		nPosCGC := aScan(aGrvPrinc,{|x| x[2] == cAliasReg+"_CGCREM"})
		nPosDoc := aScan(aGrvPrinc,{|x| x[2] == cAliasReg+"_DOC   "})
		nPosSer := aScan(aGrvPrinc,{|x| x[2] == cAliasReg+"_SERIE "})
		nPosPrd := aScan(aGrvPrinc,{|x| x[2] == cAliasReg+"_CODPRO"})

		If nPosCGC > 0 .And. nPosDoc > 0 .And. nPosSer > 0
			cConteudo := xFilial(cAliasReg)+PadR(aGrvPrinc[nPosCGC,3],Len(&(cAliasReg+'->'+cAliasReg+"_CGCREM")))+ ;
			               PadR(aGrvPrinc[nPosDoc,3],Len(&(cAliasReg+'->'+cAliasReg+"_DOC")))+ ;
	    	               PadR(aGrvPrinc[nPosSer,3],Len(&(cAliasReg+'->'+cAliasReg+"_SERIE")))

			DbSelectArea(cAliasReg)
			DbSetOrder(1)
			If (cAliasReg)->(DbSeek(cConteudo))
				While (cAliasReg)->(! Eof()) .And. &(cAliasReg+'->'+cAliasReg+"_FILIAL +" + cAliasReg+'->'+cAliasReg+"_CGCREM +" + cAliasReg+'->'+cAliasReg+"_DOC +" + cAliasReg+'->'+cAliasReg+"_SERIE" ) == cConteudo
					If nPosPrd > 0
						If &(cAliasReg+'->'+cAliasReg+"_CODPRO") == PadR(aGrvPrinc[nPosPrd,3],Len(&(cAliasReg+'->'+cAliasReg+"_CODPRO"))) 
							lRet:= .F.
							Exit
						EndIf
					Else
						lRet:= .F.
						Exit
					EndIf
					(cAliasReg)->(DbSkip())
				EndDo
			EndIf

			If !lRet
				AutoGRLog( STR0016 + aGrvPrinc[nPosDoc,3] + "/" + aGrvPrinc[nPosSer,3] + STR0017 + aGrvPrinc[nPosCGC,3] )
			EndIf
		Else
			lRet := .F.
			If nPosCGC == 0
				AutoGRLog(STR0010+" "+cAliasReg+"_CGCREM "+STR0009)
			EndIf
			If nPosDoc == 0
				AutoGRLog(STR0010+" "+cAliasReg+"_DOC "+STR0009)
			EndIf
			If nPosSer == 0
				AutoGRLog(STR0010+" "+cAliasReg+"_SERIE "+STR0009)
			EndIf
			If nPosPrd == 0
				AutoGRLog(STR0010+" "+cAliasReg+"_CODPRO"+STR0009)
			EndIf
		EndIf
	Next n2Cnt
EndIf

Return lRet

Static Function ME10TmpPre(oTrabPre)
Local cInsert := ""
(oTrabPre:GetAlias())->(DbSetOrder(1))
If !(oTrabPre:GetAlias())->(DbSeek(DEB->DEB_CGCDEV+DEB->DEB_NUMPRE))
	cInsert := "INSERT INTO " + oTrabPre:GetRealName() + " (DEB_OK,DEB_CGCDEV,DEB_NUMPRE) "
	cInsert += " Values ('XX','" + DEB->DEB_CGCDEV + "','"+ DEB->DEB_NUMPRE+"' ) "			
	TcSqlExec(cInsert)
EndIf
Return