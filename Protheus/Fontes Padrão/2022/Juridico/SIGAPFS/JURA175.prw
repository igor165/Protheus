#INCLUDE "JURA175.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
Para execução via schedule, chamar a JURA175() - será executada a importação
e a exportação.
Via menu é chamada a JURA175I() e JURA175E() para que seja executado via
Processa().
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA175
Função chamada via schedule para chamada das rotinas de importação e
exportação.

@author Cristina Cintra

@since 28/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA175()

Return JURA175IE(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA175IE
Faz a chamada da importação e da exportação para execução via schedule.

@author Cristina Cintra

@since 28/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA175IE(lShedule)
	Default lShedule := .F.
	JURA175EXP(,,lShedule)
	JURA175IMP(,,lShedule)
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA175I
Importação de despesas - tarifador.

@author wellington.coelho

@since 05/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA175I()
	Processa( { || JURA175IMP() }, STR0025, STR0026, .F. ) //"Aguarde"###"Importando despesas..."
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA175E
Exportação de cadastros - tarifador.

@author wellington.coelho

@since 05/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA175E()
	Processa( { || JURA175EXP() }, STR0025, STR0027, .F. ) //"Aguarde"###"Exportando cadastros..."
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Parâmetros para execução via Job.

@author Cristina Cintra

@since 16/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
Local aOrd   := {}
Local aParam := {}

aParam := { "P"              , ;          // Tipo R para relatorio P para processo
							"PARAMDEF"       , ;          // Pergunte do relatorio, caso nao use passar ParamDef
							""               , ;          // Alias
							aOrd             , ;          // Array de ordens
						}

If .F. // Apenas para nao dar mensagem na compilação
	SchedDef()
EndIf

Return aParam

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA175EXP
Verifica se existe configuração de arquivo tarifador e gera arquivo texto
para exportação.

@author wellington.coelho

@since 05/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA175EXP(lAutomato, cPathDir, lSchedule)

Local cQuery    := ""
Local cResQRY   := GetNextAlias()
Local cQryNYU   := ""
Local cResNYU   := ""
Local aStruct   := {}
Local nI        := 0
Local cLinha    := ""
Local cDirExp   := ""
Local nHandle   := 0
Local lContinua := .T.
Local lJob      := .T.

Default lAutomato := .F.
Default cPathDir  := GetSrvProfString( "StartPath" , "" )
Default lSchedule := .F.

	If !lAutomato
		If !IsInCallStack("CheckTask") .And. !lSchedule
			lContinua := ApMsgYesNo( STR0017, STR0016 ) //"ATENÇÃO:" "Tem certeza que deseja fazer a exportação dos cadastros para o tarifador?"
			lJob := .F.
		EndIf
	EndIf

	If lContinua
		cQuery := " SELECT NYU.R_E_C_N_O_ RECNONYU " 		+ CRLF
		cQuery += " FROM " + RetSqlName("NYU") +" NYU, " + CRLF
		cQuery += + RetSqlName("NYT") +" NYT " + CRLF
		cQuery += " WHERE  " + CRLF
		cQuery += " NYU.D_E_L_E_T_ 		= ' '"  + CRLF
		cQuery += " AND NYU.NYU_FILIAL	= '" + xFilial("NYU") + "'" + CRLF
		cQuery += " AND NYU.NYU_ATIVO	= '1'"  + CRLF
		cQuery += " AND NYT.D_E_L_E_T_ 	= ' '"  + CRLF
		cQuery += " AND NYT_FILIAL	 	= '" + xFilial("NYT") + "'" + CRLF
		cQuery += " AND NYT_ATIVO	 	= '1'"	 + CRLF
		cQuery += " AND NYT_COD	 		= NYU_CODCFG"	 	+ CRLF

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cResQRY,.T.,.T.)

		While !(cResQRY)->(EOF())
			NYU->(DbGoto((cResQRY)->RECNONYU))
			cQryNYU := NYU->NYU_SQL
			cDirExp := Alltrim(NYU->NYU_ARQUI)
			cQryNYU := ChangeQuery(cQryNYU)
			cResNYU := GetNextAlias()

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryNYU),cResNYU,.T.,.T.)

			aStruct := (cResNYU)->( dbStruct() )
				nHandle := FCREATE( cPathDir + cDirExp, 0 ) //Quando se trata de job, só é possível enxergar o startpath

			While !(cResNYU)->(EOF())
				For nI := 1 to Len(aStruct) //For de campos da query do campo Memo
					Do Case
						Case aStruct[nI][2] == 'C'
							cLinha	+= Alltrim((cResNYU)->&(aStruct[nI][1]))
						Case aStruct[nI][2] == 'N'
							cLinha	+= Alltrim(Str((cResNYU)->&(aStruct[nI][1])))
						Case aStruct[nI][2] == 'D'
							cLinha	+= Alltrim(DtoS((cResNYU)->&(aStruct[nI][1])))
						OtherWise
							cLinha	+= Alltrim(AllToChar((cResNYU)->&(aStruct[nI][1])))
					EndCase
				Next nI

				FWrite( nHandle, cLinha+ CRLF )
				cLinha := ""
				(cResNYU)->(DbSkip()) //Linhas da Query do Memo
			EndDo

			FCLOSE( nHandle )
			(cResNYU)->(DbCloseArea())
			(cResQRY)->(DbSkip())

		EndDo

		(cResQRY)->(DbCloseArea())
	EndIf

	If !lJob .And. !lAutomato
		ApMsgInfo(STR0021) //"Exportação concluída!"
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA175IMP
Importação de arquivos de despesas do tarifador.

@author Cristina Cintra
@since 07/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA175IMP(lAutomato, cPathDir, lSchedule)
Local aArea         := GetArea()
Local cQuery        := ""
Local cDiretorio    := ""
Local cDesp         := ""
Local cExtensao     := ""
Local cArqBusca     := ""
Local cMsg          := ""
Local cCliente      := ""
Local cLoja         := ""
Local cCaso         := ""
Local cTpDesp       := ""
Local cSigla        := ""
Local dData         := cToD("")
Local nValor        := ""
Local nQtd          := ""
Local cEscri        := ""
Local cIdPart       := ""
Local cIdioma       := ""
Local cCodPart      := ""
Local cTpIdPart     := ""
Local cCodDesp      := ""
Local cStart        := ""
Local cMsgFim       := ""
Local cFone         := ""
Local cDesRe        := ""
Local lOk           := .T.
Local aCfgDesp      := {}
Local aErro         := {}
Local aDados        := {}
Local aPart         := {}
Local nI            := 0
Local nJ            := 0
Local nX            := 0
Local nHandle       := 0
Local nRamal        := 0
Local nDura         := 0
Local cMoeNac       := SuperGetMV( 'MV_JMOENAC',, '01' ) //Moeda Nacional
Local lIntFinanc    := NYV->(ColumnPos("NYV_CNATUR")) > 0 .And. SuperGetMV("MV_JURXFIN",, .F.) //Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
Local oModel        := Iif(lIntFinanc, FWLoadModel("JURA241"), FWLoadModel("JURA049"))
Local lContinua     := .T.
Local lJob          := .T.
Local lTudoOk       := .T.
Local cNaturOri     := ""
Local nTaxa         := 0
Local cHistpad      := SuperGetMv("MV_JHISTTR", .F., "")
Local cNaturDes     := ""
Local cTitle        := ""
Local cBxTPosPag    := ""
Local cCliEsc       := AvKey(SuperGetMV("MV_JURTS9",,"" ), "A1_COD")   // Informe o código do Cliente que representa o escritório.
Local cLojEsc       := AvKey(SuperGetMV("MV_JURTS10",,"" ), "A1_LOJA") // Informe a Loja do Cliente que representa o escritório.
Local cErroMsg      := ""
Local lAviso        := .F.
Local aAvisoMsg     := {}
Local aErroModel    := {}
Local cNmArquivo    := ""
Local cNmArqAvis    := ""
Local cNmArqErro    := ""
Local cInconsist    := ""
Local lIdConfig     := .F. // Indica se o Id Part está na Configuração (.T.) ou no cabeçalho
Local lCommit       := .T.
Local cStatus       := ""
Local lLojaAuto     := SuperGetMv("MV_JLOJAUT", .F., "2") == "1" //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lAprovLanc    := SuperGetMv("MV_JAPRTAR",    , "2") == "1" .And. NYX->(ColumnPos("NYX_STATUS")) > 0 // Define se os lançamentos do tarifador irão passar por aprovação
Local lInconsist    := .F. // Indica que há alguma inconsistência no lançamento
Local nTamLoja      := TamSX3('A1_LOJA')[1]

Private lMsErroAuto := .F.

Default lAutomato   := .F.
Default cPathDir    := ""
Default lSchedule   := .F.

	If !IsInCallStack("CheckTask") .And. !lSchedule
		If lIntFinanc
			cNaturDes := JurBusNat("5") //Busca a Natureza de despesa de cliente

			If Empty(cNaturDes)
				cTitle     := AllTrim(RetTitle('ED_CCJURI'))
				cBxTPosPag := JurInfBox('ED_CCJURI', '5', '3')
				JurMsgErro( I18n(STR0030,{cTitle,cBxTPosPag}),,; //"Não foi encontrado nenhuma Natureza com o campo '#1' = '#2' para gerar despesa."
					I18n(STR0031,{cTitle,cBxTPosPag})) //"Cadastre uma Natureza com o campo '#1' = '#2'."
				lContinua := .F.
			EndIf

			If lContinua .And. Empty(cHistpad)
				JurMsgErro(STR0029,,STR0028) //"Não foi definido um histórico padrão para importação." /"Defina um histórico padrão no parâmetro MV_JHISTTR."
				lContinua := .F.
			EndIf
		EndIf

		If !lAutomato 
			lContinua := lContinua .And. ApMsgYesNo( STR0018, STR0016 ) //"ATENÇÃO:" "Tem certeza que deseja fazer a importação das despesas para o tarifador?"
			lJob      := .F.
		EndIf
	EndIf

	If lContinua
		cQuery := " SELECT NYV.R_E_C_N_O_ RECNONYV FROM " 		+ CRLF
		cQuery += " " + RetSqlName("NYV") + " NYV, " + RetSqlName("NYT") + " NYT " + CRLF
		cQuery += " WHERE NYV.NYV_FILIAL 	= '" + xFilial("NYV") + "' " + CRLF
		cQuery += " AND NYT.NYT_FILIAL = NYV.NYV_FILIAL " + CRLF
		cQuery += " AND NYT.NYT_COD = NYV.NYV_CODCFG "	+ CRLF
		cQuery += " AND NYT.NYT_ATIVO	= '1' " + CRLF
		cQuery += " AND NYV.D_E_L_E_T_ = ' ' "  + CRLF
		cQuery += " AND NYT.D_E_L_E_T_ = ' ' "  + CRLF
		cQuery += " AND (NYV.NYV_FIMCLI + NYV.NYV_FIMLOJ + NYV.NYV_FIMCAS + NYV.NYV_FIMSIG + NYV.NYV_FIMRAM + "
		cQuery += " NYV.NYV_FIMTEL + NYV.NYV_FIMDTA + NYV.NYV_FIMVAL + NYV.NYV_FIMHOR + NYV.NYV_FIMDES + "
		cQuery += " NYV.NYV_FIMESC + NYV.NYV_FIMQTD + NYV.NYV_FIMDUR) > 0 "

		aCfgDesp := JurSQL(cQuery, {"RECNONYV"} )

		If Len(aCfgDesp) > 0

			For nI := 1 To Len(aCfgDesp)
				NYV->(DbGoto(aCfgDesp[nI][1]))

				If lIntFinanc
					cNaturOri  := NYV->NYV_CNATUR
					nTaxa      := NYV->NYV_TAXA
				EndIf
				cStart     := GetSrvProfString( "StartPath" , "" )
				cDiretorio := cStart + Alltrim(NYV->NYV_DIAIMP)
				cPrefixo   := Left(NYV->NYV_ARQIMP, At(".",NYV->NYV_ARQIMP) - 1)
				cExtensao  := Substr(NYV->NYV_ARQIMP, At(".",NYV->NYV_ARQIMP) + 1, 3)
				Iif(!lAutomato, cArqBusca  := cDiretorio + cPrefixo + "*." + cExtensao, cArqBusca  := cPathDir + cPrefixo + "." + cExtensao)
				If NYV->(ColumnPos("NYV_IDPART")) > 0
					lIdConfig  := .T.
				Else
					cTpIdPart    := JurGetDados('NYT', 1, xFilial('NYT') + NYV->NYV_CODCFG,'NYT_IDPART') //Forma débito particular: 1=Sigla;2=Chapa;3=Ramal
				EndIf

				aArquivos  := Directory(cArqBusca)

				If !Empty(aArquivos)
					//Verifica as posições das informações obrigatórias para a criação de despesa, de já estiver inválida, nem varre os arquivos
					If !(NYV->NYV_FIMCLI > 0 .And. NYV->NYV_FIMCAS > 0 .And. NYV->NYV_FIMSIG > 0 .And. NYV->NYV_FIMDTA > 0 .And. ;
								NYV->NYV_FIMVAL > 0 .And. NYV->NYV_FIMQTD > 0)
						cMsgFim += STR0003 + Alltrim(NYV->NYV_TIPO) + STR0004 + CRLF //"A configuração de importação de despesas (NYV) do tipo "+NYV->NYV_TIPO+" não possui posições válidas para informações obrigatórias, como Cliente, Loja, Caso, etc."
						Loop
					EndIf

					For nJ := 1 To Len(aArquivos)

						aDados     := {}
						cMsg       := ""
						lOk        := .T.
						cNmArquivo := aArquivos[nJ][1]
						cNmArqAvis := STR0041 + "_" + Lower(cNmArquivo) // "Aviso"

						BEGIN TRANSACTION
							Iif(!lAutomato, FT_FUSE(cDiretorio + cNmArquivo), FT_FUSE(cPathDir + cNmArquivo))
							FT_FGOTOP()

							If !lJob .And. !lAutomato
								ProcRegua(FT_FLastRec())
							EndIf

							While !FT_FEOF()
								//Repasse do conteúdo das posições para variáveis
								cDesp := FT_FREADLN()
								If !Empty(cDesp)
									cCliente   := Alltrim(Substr(cDesp, NYV->NYV_INICLI, (NYV->NYV_FIMCLI - NYV->NYV_INICLI) + 1))
									If lLojaAuto .Or. ( NYV->NYV_INILOJ == 0 .And. NYV->NYV_FIMLOJ == 0 )
										cLoja  := StrZero(0, nTamLoja)
									Else
										cLoja  := Alltrim(Substr(cDesp, NYV->NYV_INILOJ, (NYV->NYV_FIMLOJ - NYV->NYV_INILOJ) + 1))
									EndIf
									cCaso      := Alltrim(Substr(cDesp, NYV->NYV_INICAS, (NYV->NYV_FIMCAS - NYV->NYV_INICAS) + 1))
									cIdPart    := Alltrim(Substr(cDesp, NYV->NYV_INISIG, (NYV->NYV_FIMSIG - NYV->NYV_INISIG) + 1))
									cTpDesp    := Alltrim(NYV->NYV_TIPO)
									dData      := JTransData(Alltrim(Substr(cDesp, NYV->NYV_INIDTA, (NYV->NYV_FIMDTA - NYV->NYV_INIDTA) + 1)), NYV->NYV_PICTDT)
									nValor     := Val(StrTran(Alltrim(Substr(cDesp, NYV->NYV_INIVAL, (NYV->NYV_FIMVAL - NYV->NYV_INIVAL) + 1)),",","."))
									nQtd       := Val(Alltrim(Substr(cDesp, NYV->NYV_INIQTD, (NYV->NYV_FIMQTD - NYV->NYV_INIQTD) + 1)))
									cNmArqErro := Alltrim( UPPER(Left(NYV->NYV_ARQERR, At(".",NYV->NYV_ARQERR) - 1)))
									nRamal     := Iif(NYV->NYV_FIMRAM > 0, Val(Alltrim(Substr(cDesp, NYV->NYV_INIRAM, (NYV->NYV_FIMRAM - NYV->NYV_INIRAM) + 1))), 0)
									Iif(nQtd <= 0, nQtd := 1, )
									Iif(NYV->NYV_FIMESC > 0, cEscri := Substr(cDesp, NYV->NYV_INIESC, (NYV->NYV_FIMESC - NYV->NYV_INIESC) + 1), )

									//Validação das informações
									Iif(!(JExistCpo('SA1', cCliente+cLoja) .And. JurGetDados('NUH',1,xFilial('NUH')+cCliente+cLoja,'NUH_PERFIL') == '1'), cMsg += STR0014 + cDesp + CRLF + STR0005 + CRLF, ) //"Linha: " "ERRO: Cliente/Loja inválido."
									Iif(!(J175VLDCAS(cCliente, cLoja, cCaso, dData)), cMsg += STR0014 + cDesp + CRLF + STR0006 + CRLF, ) //"Linha: " "ERRO: Caso inválido. Verifique se o caso existe, se o caso está andamento, caso encerrado se o lançamento está dentro do período permitido para lançamentos em caso encerrado, ou ainda se há pré-fatura para o período da despesa."

									If lIdConfig
										cTpIdPart := NYV->NYV_IDPART
									EndIf

									If cTpIdPart == "2" // Chapa
										cCodPart  := JurGetDados('NUR', 4, xFilial('NUR') + cIdPart, 'NUR_CPART')
										cSigla    := JurGetDados('RD0', 1, xFilial('RD0') + cCodPart, 'RD0_SIGLA')

									ElseIf cTpIdPart == "1" // Sigla
										cCodPart  := JurGetDados('RD0', 9, xFilial('RD0') + cIdPart, 'RD0_CODIGO')
										cSigla    := Iif(Empty(cCodPart), "", cIdPart)

									ElseIf cTpIdPart == "3" // Ramal
										cIdPart := cValToChar(nRamal)
										aPart   := J034BusRml(cIdPart, '')
										If !Empty(aPart)
											cCodPart  := aPart[1][1]
											cSigla    := JurGetDados('RD0', 1, xFilial('RD0') + cCodPart, 'RD0_SIGLA')
										Else
											cCodPart := ""
											cSigla   := ""
										EndIf
									EndIf

									Iif(!(J175VLDSIG(dData, cCodPart)), cMsg += STR0014 + cDesp + CRLF + STR0007 + CRLF, ) //"Linha: " "ERRO: Participante inválido. Verifique se o participante está como Participante do Jurídico ou ainda se já consta como demitido na data do lançamento."
									Iif(!(JExistCpo('NRH', cTpDesp) .And. JurGetDados('NRH', 1, xFilial('NRH') + cTpDesp, 'NRH_ATIVO') == '1'), cMsg += STR0014 + cDesp + CRLF + STR0011 + CRLF, ) //"Linha: " "ERRO: Tipo de Despesa inválido."
									Iif(Empty(dData) .Or. Valtype(dData) <> "D", cMsg += STR0014 + cDesp + CRLF + STR0008 + CRLF, ) //"Linha: " "ERRO: Data inválida."
									Iif(Valtype(nValor) <> "N" .Or. nValor == 0, cMsg += STR0014 + cDesp + CRLF + STR0009 + CRLF, ) //"Linha: " "ERRO: Valor inválido."
									Iif(Valtype(nQtd) <> "N" .Or. nQtd == 0, cMsg += STR0014 + cDesp + CRLF + STR0010 + CRLF, ) //"Linha: " "ERRO: Quantidade inválida."

									If Empty(cMsg) .Or. lAprovLanc
										//Retorna a descrição da despesa considerando a seguinte regra: buscar
										//o idioma do caso (NVE_CIDIO) na tabela NYY - Descrição por idioma.
										//Uma vez encontrado, se no campo NYY_DESC não tiver colchetes, utilizar o
										//conteúdo deste campo. Caso contrário, substituir as informações entre
										//colchetes com o conteúdo proveniente do aquivo.
										cIdioma := JurGetDados('NVE',1,xFilial('NVE')+cCliente+cLoja+cCaso,'NVE_CIDIO')

										NYY->(DbSetOrder(2)) //NYY_FILIAL+NYY_CODCFG+NYY_CIDIOM
										If NYY->(DbSeek(xFilial('NYY') + NYV->NYV_CODCFG + cIdioma))
											cDescri := Alltrim(NYY->NYY_DESC)
											If At("[", cDescri) > 0
												cDescri := StrTran(cDescri, "[CLIENTE]"   , cCliente)
												cDescri := StrTran(cDescri, "[LOJA]"      , cLoja)
												cDescri := StrTran(cDescri, "[CASO]"      , cCaso)
												cDescri := StrTran(cDescri, "[SIGLA]"     , cSigla)
												cDescri := StrTran(cDescri, "[RAMAL]"     , cValToChar(nRamal))
												cDescri := StrTran(cDescri, "[TELEFONE]"  , Alltrim(Substr(cDesp, NYV->NYV_INITEL, (NYV->NYV_FIMTEL - NYV->NYV_INITEL) + 1)))
												cDescri := StrTran(cDescri, "[DATA]"      , DtoC(dData))
												cDescri := StrTran(cDescri, "[VALOR]"     , Alltrim(Str(nValor)))
												cDescri := StrTran(cDescri, "[HORA]"      , Alltrim(Substr(cDesp, NYV->NYV_INIHOR, (NYV->NYV_FIMHOR - NYV->NYV_INIHOR) + 1)))
												cDescri := StrTran(cDescri, "[DESCRICAO]" , Alltrim(Substr(cDesp, NYV->NYV_INIDES, (NYV->NYV_FIMDES - NYV->NYV_INIDES) + 1)))
												cDescri := StrTran(cDescri, "[ESCRITORIO]", cEscri)
												cDescri := StrTran(cDescri, "[QUANTIDADE]", Str(nQtd))
												cDescri := StrTran(cDescri, "[TIPO]"      , cTpDesp)
												cDescri := StrTran(cDescri, "[DURACAO]"   , Alltrim(Substr(cDesp, NYV->NYV_INIDUR, (NYV->NYV_INIDUR - NYV->NYV_INIDUR) + 1)))
											EndIf
										Else
											cDescri := Alltrim(Substr(cDesp, NYV->NYV_INIDES, (NYV->NYV_FIMDES - NYV->NYV_INIDES) + 1))
										EndIf

										Iif(NYV->NYV_FIMTEL > 0, cFone  := Alltrim(Substr(cDesp, NYV->NYV_INITEL, (NYV->NYV_FIMTEL - NYV->NYV_INITEL) + 1)),)
										Iif(NYV->NYV_FIMDUR > 0, nDura  := Val(Alltrim(Substr(cDesp, NYV->NYV_INIDUR, (NYV->NYV_FIMDUR - NYV->NYV_INIDUR) + 1))),)
										Iif(NYV->NYV_FIMDES > 0, cDesRe := Alltrim(Substr(cDesp, NYV->NYV_INIDES, (NYV->NYV_FIMDES - NYV->NYV_INIDES) + 1)),)

										//Preenche o array com os dados da linha do arquivo
										aAdd(aDados, {cCliente, cLoja, cCaso, cMoeNac, nValor, cTpDesp, nQtd, cSigla, cDescri,;
											   cCodPart, nRamal, cFone, nDura, cEscri, NYV->NYV_TAXA, cDesRe, dData})		
									EndIf
								EndIf

								FT_FSKIP()

								If !lJob .And. !lAutomato
									IncProc()
								EndIf
							EndDo

							If !lAprovLanc .And. !(Empty(cMsg)) // Grava o arquivo com os erros encontrados
								nHandle := Iif(!lAutomato, FCreate( cDiretorio + Strtran(cNmArquivo, UPPER(cPrefixo), cNmArqErro ), 0 ), FCreate( cPathDir + Strtran(cNmArquivo, UPPER(cPrefixo), cNmArqErro ), 0 ))
								FWrite( nHandle, STR0013 + cDiretorio + cNmArquivo + CRLF + cMsg + CRLF ) //"Arquivo: "
								FClose( nHandle )

								DisarmTransaction()
								While __lSX8
									RollBackSX8()
								EndDo
								FT_FUSE()
								lTudoOk := .F.

							Else   //Grava os registros do arquivo na NYW e NYX, e cria a despesa OHB

								//NYW - tarifador – Arquivos
								RecLock("NYW",.T.)
								NYW->NYW_FILIAL := xFilial("NYW")
								NYW->NYW_COD    := GETSXENUM("NYW","NYW_COD")
								NYW->NYW_DATA   := JSToFormat(DtoS(Date()),'DD-MM-YYYY')+" "+ Time()
								NYW->NYW_TIPO   := NYV->NYV_TIPO
								NYW->NYW_ARQUI  := cNmArquivo
								NYW->(MsUnlock())
								ConfirmSX8()

								For nX := 1 To Len(aDados)

									cCodDesp   := ""
									cInconsist := ""
									//Grava a despesa no PFS
									If cCliEsc != aDados[nX][1] .Or. cLojEsc != aDados[nX][2] .Or. lAprovLanc

										lCommit := !lAprovLanc // Se NÃO estivar habilitada a aprovação, o commit deverá ser executado
										If lIntFinanc
											cCodDesp := J175GeLanc(@oModel, aDados[nX], cNaturOri, nTaxa, @aErroModel, '',lCommit)
										Else
											cCodDesp := J175GeDesp(@oModel, aDados[nX], nTaxa, @aErroModel, lCommit)
										EndIf
										If !Empty(aErroModel)
											If lAprovLanc
												// Tratamento para não considerar cliente representante como inconsistência
												If cCliEsc != aDados[nX][1] .Or. cLojEsc != aDados[nX][2]
													lInconsist := .T. // Indica que há alguma inconsistência no lançamento
												EndIf
												cInconsist := STR0043 + CRLF // "Inconsistência:"
												cInconsist += Iif(Empty(aErroModel[4]), "", STR0044 + aErroModel[4] + CRLF) // "Campo: "
												cInconsist += Iif(Empty(aErroModel[6]), "", STR0045 + aErroModel[6] + CRLF) // "Erro: "
												cInconsist += Iif(Empty(aErroModel[7]), "", STR0046 + aErroModel[7] + CRLF) // "Solução: "
											Else
												lOk     := .F.
												lTudoOk := .F.
												//DisarmTransaction()
												aAdd(aErro, {cValToChar(nX), AClone(aErroModel)})
											EndIf
											JurFreeArr(@aErroModel)
										EndIf
									Else
										cErroMsg := STR0032 + CRLF // "Não é possível gerar despesa para o cliente que representa o escritório."
										cErroMsg += i18N(STR0033, {"MV_JURTS9", "MV_JURTS10"}) // "Verifique os parâmetros '#1' e '#2'."
										aAdd(aAvisoMsg, {cValToChar(nX), cErroMsg})
										lAviso := .T.
									EndIf
									If lAprovLanc
										If lInconsist // Indica que há alguma inconsistência no lançamento
											cStatus := "1" // "Inconsistência"
										Else
											If JurGetDados("NUH", 1, xFilial("NUH") + aDados[nX][1] + aDados[nX][2], "NUH_JUSTAP") == "1" .Or. ;
											   cCliEsc == aDados[nX][1] .And. cLojEsc == aDados[nX][2]
												cStatus := "2" // "Não Revisado"
											Else
												cStatus := "4" // "Revisado Automaticamente"
											EndIf
										EndIf

										lInconsist := .F.
									EndIf
									
									If lOk
										//NYX – tarifador – Arquivos detalhes
										RecLock("NYX",.T.)
										NYX->NYX_FILIAL := xFilial("NYX")
										NYX->NYX_CODARQ := NYW->NYW_COD
										NYX->NYX_COD    := StrZero(nX, TamSX3('NYX_COD')[1])
										NYX->NYX_CCLIEN := aDados[nX][1]
										NYX->NYX_CLOJA  := aDados[nX][2]
										NYX->NYX_CCASO  := aDados[nX][3]
										NYX->NYX_MOEDA  := aDados[nX][4]
										NYX->NYX_VALOR  := aDados[nX][5]
										NYX->NYX_TPDESP := aDados[nX][6]
										NYX->NYX_QTDE   := aDados[nX][7]
										NYX->NYX_SIGLA  := aDados[nX][8]
										NYX->NYX_DESCR  := aDados[nX][9]
										If lAprovLanc
											NYX->NYX_STATUS := cStatus
											NYX->NYX_DATAIM := Date()
											NYX->NYX_HORAIM := Time()
										Else
											NYX->NYX_DESP   := cCodDesp
											NYX->NYX_STATUS := "5"
										EndIf
										NYX->NYX_RAMAL  := aDados[nX][11]
										NYX->NYX_TELEFO := aDados[nX][12]
										NYX->NYX_DURTEL := aDados[nX][13]
										NYX->NYX_ESCR   := aDados[nX][14]
										NYX->NYX_TAXA   := aDados[nX][15]
										NYX->NYX_DESCR1 := aDados[nX][16]
										NYX->NYX_DATA   := aDados[nX][17]
										If NYX->(ColumnPos("NYX_INCONS")) > 0
											NYX->NYX_INCONS := cInconsist
										EndIf
										NYX->(MsUnlock())
										ConfirmSX8()
									EndIf
								Next nX

								FT_FUSE()

								If lOk
									If __COPYFILE( cDiretorio + cNmArquivo, cStart + Alltrim(NYV->NYV_DIRIMP) + Alltrim(cNmArquivo) ) //Move o arquivo para a pasta de importados
										FErase( cDiretorio + cNmArquivo )
									Else
										nHandle := FCreate( cDiretorio + Strtran(cNmArquivo, UPPER(cPrefixo), cNmArqErro ), 0 )
										FWrite( nHandle, STR0013 + cDiretorio + cNmArquivo + CRLF + STR0015 + CRLF ) //"Arquivo: " "ERRO: Não foi possível mover o arquivo para o diretório de arquivos importados, apesar da importação ter sido feita com sucesso."
										FClose( nHandle )
									EndIf

									If lAviso
										nHandle := FCreate( cDiretorio + cNmArqAvis, 0 )
										For nX := 1 To Len(aAvisoMsg)
											cErroMsg := i18N(STR0034, {cDiretorio + cNmArquivo, aAvisoMsg[nX][1]}) + CRLF // "Arquivo: #1 - Linha: #2"
											cErroMsg += aAvisoMsg[nX][2] + CRLF
											cErroMsg += CRLF + Replicate( "-", 65 ) + CRLF + CRLF
											FWrite(nHandle, cErroMsg)
										Next nX
										FClose(nHandle)
										JurFreeArr(@aAvisoMsg)
									EndIf
								Else
									nHandle := FCreate( cDiretorio + Strtran(cNmArquivo, UPPER(cPrefixo), cNmArqErro ), 0 )

									For nX := 1 To Len(aErro)
										cErroMsg := i18N(STR0034, {cDiretorio + cNmArquivo, aErro[nX][1]}) + CRLF // "Arquivo: #1 - Linha: #2"
										cErroMsg += i18N(STR0035 , {aErro[nX][2][5]}) + CRLF // "Rotina: #1"
										cErroMsg += i18N(STR0036   , {aErro[nX][2][6]}) + CRLF // "Erro: #1"
										If !Empty(aErro[nX][2][7])
											cErroMsg += i18N(STR0037, {aErro[nX][2][7]}) + CRLF // "Solução: #1"
										EndIf
										cErroMsg +=  CRLF + Replicate( "-", 65 ) + CRLF + CRLF
										FWrite(nHandle, cErroMsg)
									Next nX
									FClose(nHandle)
									JurFreeArr(@aErro)
								EndIf
							EndIf
						END TRANSACTION
					Next
				EndIf
			Next

		Else
			If !lJob
				cMsgFim := STR0023 //"Não há configurações de despesas válidas para realizar a importação!"
			EndIf
		EndIf

		If !lJob .And. !lAutomato
			If Empty(cMsgFim)
				If lTudoOk
					If lAviso
						ApMsgInfo(STR0038 + CRLF + STR0042) // "Importação concluída com resalvas!" "Consulte o log para mais informações."
					Else
						ApMsgInfo(STR0022) // "Importação concluída com sucesso!"
					EndIf
				Else
					ApMsgInfo(STR0040 + CRLF + STR0042) // "Importação com erros"  "Consulte o log para mais informações."
				EndIf
			Else
				ApMsgInfo(cMsgFim)
			EndIf
		EndIf

	EndIf

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J175VLDSIG
Validação da Sigla do Participante proveniente do arquivo tarifador.

@Param dDtLanc   Data da despesa que está sendo importada para validar
                 caso o participante esteja demitido.
@Param cCodPart  Código do Participante.

@Return lRet     .T./.F. As informações são válidas ou não

@author Cristina Cintra
@since 09/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J175VLDSIG(dDtLanc, cCodPart)
Local lRet       := .T.
Local dDtDemis   := cTod("")
Local aDados     := {}
Local cTpJur     := ""

Default dDtLanc  := cToD("")
Default cCodPart := ""

	If Empty(cCodPart)
		lRet := .F.

	Else
		aDados :=  JurGetDados('RD0', 1, xFilial('RD0') + cCodPart, {'RD0_TPJUR', 'RD0_DTADEM'})

		If Empty(aDados)
			lRet := .F.
		Else
			cTpJur   := aDados[1]
			dDtDemis := aDados[2]

			lRet := cTpJur == "1"

			If lRet .And. !Empty(dDtDemis) .And. !Empty(dDtLanc)
				lRet := dDtDemis >= dDtLanc
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J175VLDCAS
Validação do Caso da Despesa proveniente do arquivo tarifador.

@Param   cCliente    	Cliente do caso para validação.
@Param   cLoja       	Loja do caso para validação.
@Param   cCaso       	Caso para validação.
@Param   dData        Data da despesa que está sendo importada.

@Return  lRet			.T./.F. As informações são válidas ou não

@author Cristina Cintra
@since 12/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J175VLDCAS(cCliente, cLoja, cCaso, dData)
Local aArea     := GetArea()
Local aResul    := {}
Local lRet      :=  .T.
Local dDataEnc  := Date()
Local dDtMaxLan := Date()
Local cQuery    := ""

Default cCliente := ""
Default cLoja    := ""
Default cCaso    := ""
Default dData    := cToD("")

	lRet := JExistCpo("NVE", cCliente+cLoja+cCaso,1)

	If lRet
		If !(JurGetDados('NVE',1,xFilial('NVE')+cCliente+cLoja+cCaso,'NVE_SITUAC') == '1')
			dDataEnc  := JurGetDados('NVE',1,xFilial('NVE')+cCliente+cLoja+cCaso,'NVE_DTENCE')
			dDtMaxLan := JRetDtEnc( dDataEnc, SuperGetMV('MV_JLANC1',,0))
			lRet := dData <= dDtMaxLan

			If lRet

				cQuery := " SELECT NX1.R_E_C_N_O_ RECNO FROM " 		+ CRLF
				cQuery += " " + RetSqlName("NX1") + " NX1, " + RetSqlName("NX0") + " NX0 " + CRLF
				cQuery += " WHERE NX1.NX1_FILIAL 	= '" + xFilial("NX1") + "' " + CRLF
				cQuery += " AND NX1.NX1_FILIAL = NX0.NX0_FILIAL " + CRLF
				cQuery += " AND NX1.NX1_CPREFT = NX0.NX0_COD "	+ CRLF
				cQuery += " AND NX1.NX1_CCLIEN  = '" + cCliente + "' " + CRLF
				cQuery += " AND NX1.NX1_CLOJA  = '" + cLoja + "' " + CRLF
				cQuery += " AND NX1.NX1_CCASO  = '" + cCaso + "' " + CRLF
				cQuery += " AND NX0.NX0_SITUAC IN ('2','3','4','5','7','9','A','B') " + CRLF
				cQuery += " AND NX0.NX0_DESP = '1' " + CRLF
				cQuery += " AND '" + DtoS(dData) + "' >= NX0.NX0_DINIDP " + CRLF
				cQuery += " AND '" + DtoS(dData) + "' <= NX0.NX0_DFIMDP " + CRLF
				cQuery += " AND NX0.D_E_L_E_T_ = ' ' "  + CRLF
				cQuery += " AND NX1.D_E_L_E_T_ = ' ' "  + CRLF

				aResul := JurSQL(cQuery, {"RECNO"} )

				lRet := Len(aResul) == 0

			EndIf
		EndIf
	EndIf

	RestArea( aArea )

Return lRet

//------------------------------------------------------------------------
/*/{Protheus.doc} AvaliaQry

Avalia a Query

@author Ernani Forastieri
@since 15/08/2011
@version P11
/*/
//------------------------------------------------------------------------
Function AvaliaQry( cQuery )
Local aArea        := GetArea()
Local bBlock       := ErrorBlock( { | e | cDescription := e:Description, CheckError( e ) } )
Local cAliasQry    := ''
Local cDescription := ''
Local lRet         := .T.

cQuery := Upper( AllTrim( cQuery ) )

Begin Sequence
     cAliasQry := GetNextAlias()
     dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T.)

Recover

     lRet := .F.

End Sequence

ErrorBlock( bBlock )

If lRet
     dbSelectArea( cAliasQry )
     (cAliasQry)->( dbCloseArea() )
Else
     If FwViewActive() <> NIL
         Help( ,, STR0019,, I18N( STR0020 + CRLF + cDescription, {cDescription} ), 1, 0 )
     EndIf

EndIf

RestArea( aArea )

Return lRet


//------------------------------------------------------------------------
/*/{Protheus.doc} CheckError

@author Ernani Forastieri
@since 15/08/2011
@version P11
/*/
//------------------------------------------------------------------------
Static Function CheckError( e )
//If e:GenCode > 0
//   Help( ,, "Inconsistência",,"ERR_FORM",, e:Description, 3, 1 )
//EndIf
Break
Return NIL

//------------------------------------------------------------------------
/*/{Protheus.doc} J175GeLanc
Função para gerar lançamento na importação

@param oModel    , Modelo de dados do JURA241
@param aDados    , Dados do tarifador
@param cNaturOri , Natureza de origem para gerar o lançamento
@param nTaxa     , Taxa do tarifador
@param aErroModel, Array para armazenar o erro (passar como referência)
@param cPartDbtP , Força gerar um lançamento de débito pessoal para o participante
@param lCommit   , Salvar a laçamento

@author Bruno Ritter
@since 30/01/2018
@version 1.0
/*/
//------------------------------------------------------------------------
Function J175GeLanc(oModel, aDados, cNaturOri, nTaxa, aErroModel, cPartDbtP, lCommit)
Local oModelOHB  := Nil
Local cCodPart   := aDados[10]
Local cSigla     := JurGetDados("RD0", 1, xFilial("RD0") + cCodPart, "RD0_SIGLA")
Local cEscrPart  := JurPartHst(cCodPart, aDados[17], "NUS_CESCR" )
Local cCusto     := JurPartHst(cCodPart, aDados[17], "NUS_CC" )
Local lValido    := .T.
Local cHistpad   := SuperGetMv("MV_JHISTTR", .F., "")
Local aRetNVE    := {}
Local lDebitoPes := .F.
Local cSiglaDbtP := ""
Local cNatDbtPes := ""
Local aErro      := {}
Local cCodDesp   := ""
Local cFilialNew := ""
Local cFilOld    := cFilAnt
Local cEscri     := ""  
Local cCCNatOri  := JurGetDados("SED", 1, xFilial("SED") + cNaturOri, "ED_CCJURI")
Local cNaturDes  := ""

Default cPartDbtP := ""

	If !Empty(cPartDbtP)
		lDebitoPes := .T.
	Else
		aRetNVE := JurGetDados("NVE", 1, xFilial("NVE") + aDados[1] + aDados[2] + aDados[3], {"NVE_DBTPES", "NVE_CPTDBT"} )
		If !Empty(aRetNVE) .And. Len(aRetNVE) >= 2
			lDebitoPes := aRetNVE[1] == "1"
			cPartDbtP  := aRetNVE[2]
		EndIf
	EndIf

	If lDebitoPes
		If !Empty(cPartDbtP)
			cSiglaDbtP := JurGetDados("RD0", 1, xFilial("RD0") + cPartDbtP, "RD0_SIGLA")
		Else
			cSiglaDbtP := cSigla
			cPartDbtP  := aDados[10]
		EndIf
		cEscri := JurGetDados("NUR", 1, xFilial("NUR") + cPartDbtP, "NUR_CESCR")
	Else
		If !Empty(aDados[14])
			cEscri := aDados[14]
		Else
			cEscri := SupergetMv("MV_JESCTAR", , "")
		EndIf
		
		cNaturDes := JurBusNat("5") //Busca a Natureza de despesa de cliente
	EndIf

	If !Empty(cEscri)
		cFilialNew := JurGetDados("NS7", 1, xFilial("NS7") + cEscri, "NS7_CFILIA")
	EndIf

	If !Empty(cFilialNew)
		cFilAnt := cFilialNew
	EndIf

	oModel:SetOperation( 3 )
	oModel:Activate()
	oModelOHB := oModel:GetModel("OHBMASTER")

	//-------------------------------------------------------------//
	// Define a origem do lançamento
	//-------------------------------------------------------------//
	lValido := lValido .And. oModelOHB:SetValue("OHB_ORIGEM", "3") //Tarifador
	//-------------------------------------------------------------//
	// Dados da natureza de origem
	//-------------------------------------------------------------//
	lValido := lValido .And. oModelOHB:SetValue("OHB_NATORI", cNaturOri)
	Do Case
		Case cCCNatOri $ "1|2" .Or. (Empty(cCCNatOri) .And. !Empty(cEscrPart)) //Escritório|Centro de Custo|Vazio
			lValido := lValido .And. oModelOHB:SetValue("OHB_CESCRO", cEscrPart)

			If cCCNatOri == "2" .Or. (Empty(cCCNatOri) .And. !Empty(cCusto)) //Centro de Custo|Vazio
				lValido := lValido .And. oModelOHB:SetValue("OHB_CCUSTO", cCusto)
			EndIf

		Case cCCNatOri == "3" //Profissional
			lValido := lValido .And. oModelOHB:SetValue("OHB_SIGLAO", cSigla)
	EndCase

	//-------------------------------------------------------------//
	// Dados da natureza de Destino
	//-------------------------------------------------------------//
	If lDebitoPes
		cNatDbtPes := J159PrtNat(cPartDbtP, .T., .F., @aErro)

		If !Empty(aErro) .And. Len(aErro) >= 2
			lValido := .F.
			oModel:SetErrorMessage(,, oModelOHB:GetId(),, ProcName(0), aErro[1], aErro[2],, )
		EndIf

		lValido := lValido .And. oModelOHB:SetValue("OHB_NATDES", cNatDbtPes)
		lValido := lValido .And. oModelOHB:SetValue("OHB_SIGLAD", cSiglaDbtP)

	Else
		lValido := lValido .And. oModelOHB:SetValue("OHB_NATDES", cNaturDes)
		lValido := lValido .And. oModelOHB:SetValue("OHB_CCLID ", aDados[1]) 
		lValido := lValido .And. oModelOHB:SetValue("OHB_CLOJD ", aDados[2]) 
		lValido := lValido .And. oModelOHB:SetValue("OHB_CCASOD", aDados[3]) 
		lValido := lValido .And. oModelOHB:SetValue("OHB_CTPDPD", aDados[6]) 
		lValido := lValido .And. oModelOHB:SetValue("OHB_QTDDSD", aDados[7]) 
		lValido := lValido .And. oModelOHB:SetValue("OHB_DTDESP", aDados[17])
		lValido := lValido .And. oModelOHB:SetValue("OHB_DURTEL", aDados[13])
	EndIf

	//-------------------------------------------------------------//
	// Outros dados
	//-------------------------------------------------------------//
	lValido := lValido .And. oModelOHB:SetValue("OHB_SIGLA" , cSigla)
	lValido := lValido .And. oModelOHB:SetValue("OHB_DTLANC", Date())
	lValido := lValido .And. oModelOHB:SetValue("OHB_CMOELC", aDados[4])
	lValido := lValido .And. oModelOHB:SetValue("OHB_VALOR" , Iif(nTaxa == 0, aDados[5], (aDados[5] + (aDados[5] * (nTaxa / 100))) ))
	lValido := lValido .And. oModelOHB:SetValue("OHB_CHISTP", cHistpad)
	lValido := lValido .And. oModelOHB:SetValue("OHB_HISTOR", aDados[9])
	lValido := lValido .And. oModelOHB:SetValue("OHB_FILORI", cFilAnt)

	If oModel:VldData()
		If lCommit
			If oModel:CommitData()
				cCodDesp   := oModel:GetValue("OHBMASTER","OHB_CDESPD")
			EndIf
		EndIf
	Else
		aErroModel := oModel:GetErrorMessage(.T.)
	EndIf

	oModel:DeActivate()

	cFilAnt := cFilOld

Return cCodDesp

//------------------------------------------------------------------------
/*/{Protheus.doc} J175GeDesp
Função para gerar Despesas

@param oModel    , Modelo de dados do JURA049
@param aDados    , Dados do tarifador
@param nTaxa     , Taxa do tarifador
@param aErroModel, Array para armazenar o erro (passar como referência)
@param lCommit   , Salvar a Despesa

@author Anderson Carvalho \ Bruno Ritter
@since 01/07/2019
/*/
//------------------------------------------------------------------------
Function J175GeDesp(oModel, aDados, nTaxa, aErroModel, lCommit)
	Local lValido   := .T.
	Local cCodDesp  := ""
	Default lCommit := .T.

	oModel:SetOperation( 3 )
	oModel:Activate()
	lValido := lValido .And. oModel:SetValue("NVYMASTER", "NVY_CCLIEN", aDados[1])
	lValido := lValido .And. oModel:SetValue("NVYMASTER", "NVY_CLOJA" , aDados[2])
	lValido := lValido .And. oModel:SetValue("NVYMASTER", "NVY_CCASO" , aDados[3])
	lValido := lValido .And. oModel:SetValue("NVYMASTER", "NVY_DATA"  , aDados[17])
	lValido := lValido .And. oModel:SetValue("NVYMASTER", "NVY_SIGLA" , aDados[8])
	lValido := lValido .And. oModel:SetValue("NVYMASTER", "NVY_CPART" , aDados[10])
	lValido := lValido .And. oModel:SetValue("NVYMASTER", "NVY_CTPDSP", aDados[6])
	lValido := lValido .And. oModel:SetValue("NVYMASTER", "NVY_CMOEDA", aDados[4])
	lValido := lValido .And. oModel:SetValue("NVYMASTER", "NVY_VALOR" , Iif(nTaxa == 0, aDados[5], (aDados[5] + (aDados[5] * (nTaxa / 100))) ))
	lValido := lValido .And. oModel:SetValue("NVYMASTER", "NVY_QTD"   , aDados[7])
	lValido := lValido .And. oModel:SetValue("NVYMASTER", "NVY_DESCRI", aDados[9])
	lValido := lValido .And. oModel:SetValue("NVYMASTER", "NVY_DURTEL", aDados[13])

	If oModel:VldData()
	
		If lCommit
			If oModel:CommitData()
				cCodDesp := oModel:GetValue("NVYMASTER","NVY_COD")
			EndIf
		EndIf
	Else
		aErroModel := oModel:GetErrorMessage(.T.)
	EndIf

	oModel:DeActivate()

Return cCodDesp
