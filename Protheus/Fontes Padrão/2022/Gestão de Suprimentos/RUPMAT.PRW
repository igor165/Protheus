#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"
#Include 'TOPConn.ch'
#Include "Fileio.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} RUP_COM
Função de compatibilização do release incremental. Esta função é relativa ao módulo Compras
@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA

@Author Jose Delmondes
@since 19/05/2015
@version P12
/*/
//-------------------------------------------------------------------
Function RUP_COM( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

Local cRelLoop		:= ""
Local nRelease		:= 0

//-- Regra geral : só executar atualização quando release de partida diferente do release de chegada
If !( cRelStart == cRelFinish )

	//-- Através do controle de cModo, é possível escolher entre processos que devem rodar para
	//-- todo o grupo de empresa ( cModo = 1 ) ou processos que serão disparados por grupo + filial
	If cMode == "2"
		For nRelease := Val( cRelStart ) + 1 to Val( cRelFinish )
			//-- Aqui é criado o código de release que está processando "no momento"
			cRelLoop := StrZero( nRelease, 3 )
		Next nRelease
	EndIf
EndIf

If cVersion == "12" .And. Val(cRelFinish) > 6
	If cMode == "1"		// cMode == 1 -> Executado uma vez por Grupo de empresa
		COMSX3GRP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz) //Atualizar SX3 por grupo de empresa
		COMSX6GRP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz) //Atualizar SX6 por grupo de empresa
		COMSX7GRP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz) //Atualizar SX7 por grupo de empresa
		COMSX9GRP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz) //Atualizar SX9 por grupo de empresa
		COMSX1GRP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz) //Atualizar SX1 por grupo de empresa
		COMDICFIL(cVersion, cMode, cRelStart, cRelFinish, cLocaliz) //Atualiza dicionario
	EndIf
Endif

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} COMSX6GRP()
Ajuste MV_HORARMT a partir da release 12.5

@author Leonardo Quintania
@since 29/08/2015
@version P12
/*/
//--------------------------------------------------------------------
Static Function COMSX6GRP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
Local lHoraRMT	:= SuperGetMv("MV_HORARMT",.F.,.F.)
Local lDicInDB 	:= MPDicInDB()
Local lAltBco	:= .F.
Local lAlTpDocDb:= .F.

//Verifica de dicionario esta no banco de dados ou system
// .T. = Banco de dados
// .F. = System

dbSelectArea("SX6")
SX6->(dbSetOrder(1))

If Val(cRelFinish) < 27
	//Previsão de tratamentos separados em blocos devido possibilidade de existência do parâmetro para empresas e filiais distintas.
	//Tratamento Referente Filial Em Branco
	If 	SX6->(MsSeek(Replicate(" ", FwSizeFilial())+"MV_HORARMT"))
		If SX6->X6_TIPO != "C"
			If !lDicInDB
				If RecLock("SX6",.F.)
					SX6->X6_TIPO	:= "C"
					SX6->X6_DESCRIC	:= "Horário gravado nos campos F1_HORA/F2_HORA."
					SX6->X6_DESC1 	:= "1=Horario do SmartClient; 2=Horario do servidor;"
					SX6->X6_DESC2	:= "3=Fuso horário da filial corrente;"
					SX6->X6_DSCSPA 	:= "Tiempo para grabarse con campos F1_HORA / F2_HORA"
					SX6->X6_DSCSPA1	:= "1=Tiempo de SmartClient; 2=Tiempo de servidor;"
					SX6->X6_DSCSPA2	:= "3=Zona horaria de la rama actual;"
					SX6->X6_DSCENG 	:= "Time to be recorded with F1_HORA / F2_HORA fields"
					SX6->X6_DSCENG1	:= "1=Time of SmartClient; 2=Server hours;"
					SX6->X6_DSCENG2	:= "3=Time zone of the current branch;"
					If lHoraRMT
						SX6->X6_CONTEUD 	:= "1"
						SX6->X6_CONTSPA 	:= "1"
						SX6->X6_CONTENG 	:= "1"
					Else
						SX6->X6_CONTEUD 	:= "2"
						SX6->X6_CONTSPA 	:= "2"
						SX6->X6_CONTENG 	:= "2"
					EndIf
					SX6->(MsUnlock())
				Endif
			Else
				lAltBco := .T.
			Endif
		EndIf
	EndIf

	//Tratamento Referente Empresa
	If 	SX6->(MsSeek(PadR(FwCompany(),FwSizeFilial())+"MV_HORARMT"))
		If SX6->X6_TIPO != "C"
			If !lDicInDB
				If RecLock("SX6",.F.)
					SX6->X6_TIPO	:= "C"
					SX6->X6_DESCRIC	:= "Horário gravado nos campos F1_HORA/F2_HORA."
					SX6->X6_DESC1 	:= "1=Horario do SmartClient; 2=Horario do servidor;"
					SX6->X6_DESC2	:= "3=Fuso horário da filial corrente;"
					SX6->X6_DSCSPA 	:= "Tiempo para grabarse con campos F1_HORA / F2_HORA"
					SX6->X6_DSCSPA1	:= "1=Tiempo de SmartClient; 2=Tiempo de servidor;"
					SX6->X6_DSCSPA2	:= "3=Zona horaria de la rama actual;"
					SX6->X6_DSCENG 	:= "Time to be recorded with F1_HORA / F2_HORA fields"
					SX6->X6_DSCENG1	:= "1=Time of SmartClient; 2=Server hours;"
					SX6->X6_DSCENG2	:= "3=Time zone of the current branch;"
					If lHoraRMT
						SX6->X6_CONTEUD 	:= "1"
						SX6->X6_CONTSPA 	:= "1"
						SX6->X6_CONTENG 	:= "1"
					Else
						SX6->X6_CONTEUD 	:= "2"
						SX6->X6_CONTSPA 	:= "2"
						SX6->X6_CONTENG 	:= "2"
					EndIf
					SX6->(MsUnlock())
				Endif
			Else
				lAltBco := .T.
			Endif
		EndIf
	EndIf

	//Tratamento Referente Empresa + Filial
	If 	SX6->(MsSeek(PadR(FwCompany()+FwUnitBusiness(),FwSizeFilial())+"MV_HORARMT"))
		If SX6->X6_TIPO != "C"
			If !lDicInDB
				If RecLock("SX6",.F.)
					SX6->X6_TIPO	:= "C"
					SX6->X6_DESCRIC	:= "Horário gravado nos campos F1_HORA/F2_HORA."
					SX6->X6_DESC1 	:= "1=Horario do SmartClient; 2=Horario do servidor;"
					SX6->X6_DESC2	:= "3=Fuso horário da filial corrente;"
					SX6->X6_DSCSPA 	:= "Tiempo para grabarse con campos F1_HORA / F2_HORA"
					SX6->X6_DSCSPA1	:= "1=Tiempo de SmartClient; 2=Tiempo de servidor;"
					SX6->X6_DSCSPA2	:= "3=Zona horaria de la rama actual;"
					SX6->X6_DSCENG 	:= "Time to be recorded with F1_HORA / F2_HORA fields"
					SX6->X6_DSCENG1	:= "1=Time of SmartClient; 2=Server hours;"
					SX6->X6_DSCENG2	:= "3=Time zone of the current branch;"
					If lHoraRMT
						SX6->X6_CONTEUD 	:= "1"
						SX6->X6_CONTSPA 	:= "1"
						SX6->X6_CONTENG 	:= "1"
					Else
						SX6->X6_CONTEUD 	:= "2"
						SX6->X6_CONTSPA 	:= "2"
						SX6->X6_CONTENG 	:= "2"
					EndIf
					SX6->(MsUnlock())
				Endif
			Else
				lAltBco := .T.
			Endif
		EndIf
	EndIf

	//Código Completo da Filial Atual
	If 	SX6->(MsSeek(FwCodFil()+"MV_HORARMT"))
		If SX6->X6_TIPO != "C"
			If !lDicInDB
				If RecLock("SX6",.F.)
					SX6->X6_TIPO	:= "C"
					SX6->X6_DESCRIC	:= "Horário gravado nos campos F1_HORA/F2_HORA."
					SX6->X6_DESC1 	:= "1=Horario do SmartClient; 2=Horario do servidor;"
					SX6->X6_DESC2	:= "3=Fuso horário da filial corrente;"
					SX6->X6_DSCSPA 	:= "Tiempo para grabarse con campos F1_HORA / F2_HORA"
					SX6->X6_DSCSPA1	:= "1=Tiempo de SmartClient; 2=Tiempo de servidor;"
					SX6->X6_DSCSPA2	:= "3=Zona horaria de la rama actual;"
					SX6->X6_DSCENG 	:= "Time to be recorded with F1_HORA / F2_HORA fields"
					SX6->X6_DSCENG1	:= "1=Time of SmartClient; 2=Server hours;"
					SX6->X6_DSCENG2	:= "3=Time zone of the current branch;"
					If lHoraRMT
						SX6->X6_CONTEUD 	:= "1"
						SX6->X6_CONTSPA 	:= "1"
						SX6->X6_CONTENG 	:= "1"
					Else
						SX6->X6_CONTEUD 	:= "2"
						SX6->X6_CONTSPA 	:= "2"
						SX6->X6_CONTENG 	:= "2"
					EndIf
					SX6->(MsUnlock())
				Endif
			Else
				lAltBco := .T.
			Endif
		EndIf
	EndIf

	If lAltBco
		cUpd := " UPDATE " + MPSysSqlName("SX6")
		cUpd += " SET X6_TIPO 		= 'C', "
		cUpd += "     X6_DESCRIC 	= 'Horário gravado nos campos F1_HORA/F2_HORA.', "
		cUpd += "     X6_DESC1 		= '1=Horario do SmartClient; 2=Horario do servidor;', "
		cUpd += "     X6_DESC2 		= '3=Fuso horário da filial corrente;', "
		cUpd += "     X6_DSCSPA 	= 'Tiempo para grabarse con campos F1_HORA / F2_HORA', "
		cUpd += "     X6_DSCSPA1 	= '1=Tiempo de SmartClient; 2=Tiempo de servidor;', "
		cUpd += "     X6_DSCSPA2 	= '3=Zona horaria de la rama actual;', "
		cUpd += "     X6_DSCENG 	= 'Time to be recorded with F1_HORA / F2_HORA fields', "
		cUpd += "     X6_DSCENG1 	= '1=Time of SmartClient; 2=Server hours;', "
		cUpd += "     X6_DSCENG2 	= '3=Time zone of the current branch;', "
		cUpd += " 	  X6_CONTEUD 	= (CASE WHEN RTRIM(LTRIM(UPPER(X6_CONTEUD))) LIKE '%T%' THEN '1' ELSE '2' END), "
		cUpd += " 	  X6_CONTSPA 	= (CASE WHEN RTRIM(LTRIM(UPPER(X6_CONTSPA))) LIKE '%T%' THEN '1' ELSE '2' END), "
		cUpd += " 	  X6_CONTENG 	= (CASE WHEN RTRIM(LTRIM(UPPER(X6_CONTENG))) LIKE '%T%' THEN '1' ELSE '2' END) "
		cUpd += " WHERE X6_VAR 		= 'MV_HORARMT' "
		cUpd += " 	AND X6_TIPO 	!= 'C' "
		cUpd += " 	AND D_E_L_E_T_ 	= '' "
		TCSqlExec(cUpd)
	EndIf

	// Ajuste Teste Sistêmico pois o valid do parametro MV_ALTPDOC estava com a funcao A114VALDOC que nao existe
	If SX6->(MsSeek(Replicate(" ", FwSizeFilial())+"MV_ALTPDOC"))
		// Tratamento referente filial em branco
		If !Empty(SX6->X6_VALID)
			If lDicInDB
				lAlTpDocDb := .T.
			ElseIf RecLock("SX6",.F.)
				SX6->X6_VALID := " "
				SX6->(MsUnlock())
			EndIf
		EndIf
	EndIf
	If SX6->(MsSeek(PadR(FwCompany(),FwSizeFilial())+"MV_ALTPDOC"))
		// Tratamento referente empresa
		If !Empty(SX6->X6_VALID)
			If lDicInDB
				lAlTpDocDb := .T.
			ElseIf RecLock("SX6",.F.)
				SX6->X6_VALID := " "
				SX6->(MsUnlock())
			EndIf
		EndIf
	EndIf
	If SX6->(MsSeek(PadR(FwCompany()+FwUnitBusiness(),FwSizeFilial())+"MV_ALTPDOC"))
		// Tratamento referente empresa + filial
		If !Empty(SX6->X6_VALID)
			If lDicInDB
				lAlTpDocDb := .T.
			ElseIf RecLock("SX6",.F.)
				SX6->X6_VALID := " "
				SX6->(MsUnlock())
			EndIf
		EndIf
	EndIf
	If SX6->(MsSeek(FwCodFil()+"MV_ALTPDOC"))
		// Código completo da filial atual
		If !Empty(SX6->X6_VALID)
			If lDicInDB
				lAlTpDocDb := .T.
			ElseIf RecLock("SX6",.F.)
				SX6->X6_VALID := " "
				SX6->(MsUnlock())
			EndIf
		EndIf
	EndIf
	If lAlTpDocDb
		cUpd := "UPDATE " + MPSysSqlName("SX6")
		cUpd += " SET X6_VALID = ' '"
		cUpd += " WHERE X6_VAR = 'MV_ALTPDOC'"
		cUpd += " AND X6_VALID <> ' '"
		cUpd += " AND D_E_L_E_T_ = ' '"
		TCSqlExec(cUpd)
	EndIf
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} COMSX7GRP
RUP Solicitante de Compras.
@author Bruno Melo
@since 25/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------

Function COMSX7GRP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

	Local lDicInDB := MPDicInDB()

	//Verifica de dicionario esta no banco de dados ou system
	// .T. = Banco de dados
	// .F. = System

	DbSelectArea("SX7")
	SX7->(DbSetOrder(1))

	If Val(cRelFinish) < 27
		If SX7->(dbSeek("AI_PRODUTO"))
			If !"A084Gatilh" $ SX7->X7_REGRA
				If !lDicInDB
					If Reclock("SX7",.F.)
						SX7->X7_REGRA := "A084Gatilh()"
						SX7->(MsUnlock())
					Endif
				Else
					cUpd := " UPDATE " + MPSysSqlName("SX7")
					cUpd += " SET X7_REGRA 		= 'A084Gatilh()' "
					cUpd += " WHERE X7_CAMPO	= 'AI_PRODUTO' "
					cUpd += " 	AND D_E_L_E_T_ 	= '' "
					TCSqlExec(cUpd)
				Endif
			EndIf
		EndIf

		If SX7->(dbSeek("AI_GRUPO"))
			If !"A084GatGrp" $ SX7->X7_REGRA
				If !lDicInDB
					If Reclock("SX7",.F.)
						SX7->X7_REGRA := "A084GatGrp()"
						SX7->(MsUnlock())
					Endif
				Else
					cUpd := " UPDATE " + MPSysSqlName("SX7")
					cUpd += " SET X7_REGRA 		= 'A084GatGrp()' "
					cUpd += " WHERE X7_CAMPO	= 'AI_GRUPO' "
					cUpd += " 	AND D_E_L_E_T_ 	= '' "
					TCSqlExec(cUpd)
				Endif
			EndIf
		EndIf
	Endif

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} RUP_EST
Função de compatibilização do release incremental.
Esta função é relativa ao módulo Estoque

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução.
					1=Por grupo de empresas
					2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA

@author Flavio Lopes Rasta
@since 22/03/2016
@version P12
/*/
//-------------------------------------------------------------------
Function RUP_EST(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

If cMode == "1"		// cMode == 1 -> Executado uma vez por Grupo de empresa

	//Atualiza SX3
	AtuEstSx3(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

	//Atualiza SX6
	AtuEstSx6(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

	If Val(cRelStart) <= 27 .and. cRelFinish >= "017"
		FS2DBH7H9()
		//-- Atualiza SX9
		AtuEstSx9(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

		//Atualiza perguntas
		AtuEstSX1(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

	EndIf

EndIf

If !( cRelStart == cRelFinish )
	If cMode == "2"	// cMode == 2 -> Executado uma vez por FILIAL
		If cVersion < "12" //-- Migração da 11 para 12
			#IFDEF TOP
				BeginSQL Alias "SB2TMP"
					SELECT
						DISTINCT B2_FILIAL, B2_LOCAL
					FROM
						%Table:SB2% SB2
					WHERE
						SB2.B2_FILIAL=%xFilial:SB2% AND
						SB2.%NotDel%
				EndSQL

				SB2->(dbSetOrder(2))
				While SB2TMP->(!Eof())
					If !(NNR->(dbSeek(xFilial("NNR")+SB2TMP->B2_LOCAL)))
						SB2->(dbSeek(xFilial("SB2")+SB2TMP->B2_LOCAL))
						RecLock("NNR",.T.)   // Inclusao dos armazens encontrados na Tabela SB2, Conforme a filial cadastrada.
						NNR->NNR_FILIAL	:= xFilial("NNR")
						NNR->NNR_CODIGO	:= SB2->B2_LOCAL
						NNR->NNR_TIPO	:= If(Empty(SB2->B2_TIPO),"1",SB2->B2_TIPO)
						NNR->NNR_DESCRI	:= If(Empty(SB2->B2_LOCALIZ),"Armazém " +SB2->B2_LOCAL,SB2->B2_LOCALIZ)
						MsUnlock()
					EndIf
					SB2TMP->(dbSkip())
				EndDo
				SB2TMP->(dbCloseArea())
			#ENDIF
		Endif

		//Atualiza documentos SC e AE gerados por SA para versões acima da 12.1.14
		If cVersion == "12" .And. Val(cRelFinish) > 14 .And. Val(cRelFinish) < 18

			//Executa comando para criar tabela, caso não exista
			DbSelectArea("DHN")

			If TableInDic( "DHN", .F. )

				//Atualiza SCs na DHN
				AtuSCnaDhn()

				//Atualiza AEs na DHN
				AtuAEnaDhn()
			EndIf

		EndIf

	Endif

Endif

Return NIL

/*/{Protheus.doc} COMDICFIL
Ajuste no campo CR_GRUPO para gravar o grupo de aprovação
assim não ocorrendo erro ao tentar liberar o documento

@author Rodrigo M Pontes
@since 21/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------

Function COMDICFIL(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

Local cQuery	:= ""
Local cUpd		:= ""
Local cCodigo	:= ""
Local cDescri	:= ""
Local cUlFilial	:= ""
Local cCompModoF:= ""
Local cCompModoU:= ""
Local cCompModoE:= ""
Local cAliasSAL := GetNextAlias()
Local lDicInDB 	:= MPDicInDB()

If Val(cRelFinish) < 27
	#IFDEF TOP
		If Select("LIBPC") > 0
			LIBPC->(DbCloseArea())
		Endif

		//Ajuste nos documentos (Pedido de compra)
		cQuery := " SELECT C7.C7_APROV,"
		cQuery += "        CR.CR_NUM,"
		cQuery += "        CR.CR_FILIAL"
		cQuery += " FROM " + RetSqlName("SCR") + " CR"
		cQuery += "        JOIN " + RetSqlName("SC7") + " C7"
		cQuery += "          ON C7.D_E_L_E_T_ = ' '"
		cQuery += "             AND C7.C7_NUM = CR.CR_NUM"
		cQuery += "             AND C7.C7_FILIAL = '" + xFilial("SC7") + "'"
		cQuery += "             AND C7.C7_APROV <> ''"
		cQuery += " WHERE  CR.D_E_L_E_T_ = ' '"
		cQuery += "        AND CR.CR_GRUPO = ''"
		cQuery += "        AND CR.CR_TIPO = 'PC'"
		cQuery += "        AND CR.CR_FILIAL = '" + xFilial("SCR") + "'"
		cQuery += " GROUP  BY C7.C7_APROV,"
		cQuery += "           CR.CR_NUM,"
		cQuery += "           CR.CR_FILIAL"

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"LIBPC", .F., .T.)

		DbSelectArea("LIBPC")
		While LIBPC->(!EOF())
			cUpd := " UPDATE " + RetSqlName("SCR")
			cUpd += " SET CR_GRUPO = '" + LIBPC->C7_APROV + "'"
			cUpd += " WHERE CR_NUM = '" + LIBPC->CR_NUM + "'"
			cUpd += " AND CR_FILIAL = '" + LIBPC->CR_FILIAL + "'"

			TCSqlExec(cUpd)
			LIBPC->(DbSkip())
		Enddo

		LIBPC->(DbCloseArea())
	#ENDIF

	If ChkFile("DHL") .AND. ChkFile("SAL") .AND. ChkFile("SAK") //Verifica Existência da tabela DHL, SAL e SAK no ambiente

		cCodigo	:= Padl("",TamSX3("AL_PERFIL")[1],"0")

		DbSelectArea("SAL")
		DbSelectArea("DHL")
		DHL->(DbGoTop())

		If DHL->(Eof())//Se não há dados na DHL, corrige compartilhamento para ser igual ao da SAK
			DHL->(DbCloseArea())

			DbSelectArea("SX2")
			If SX2->(DbSeek("SAK"))
				cCompModoF	:= SX2->X2_MODO
				cCompModoU	:= SX2->X2_MODOUN
				cCompModoE	:= SX2->X2_MODOEMP

				If lDicInDB
					cUpd := " UPDATE " + MPSysSqlName("SX2")
					cUpd += " SET X2_MODO 		= '"+cCompModoF+"', "
					cUpd += "     X2_MODOUN 	= '"+cCompModoU+"', "
					cUpd += "     X2_MODOEMP 	= '"+cCompModoE+"' "
					cUpd += " WHERE X2_CHAVE 	= 'DHL' "
					cUpd += " 	AND D_E_L_E_T_ 	= '' "
					TCSqlExec(cUpd)
				Else
					If SX2->(DbSeek("DHL"))
						If RecLock("SX2",.F.)
							cCompModoF	:= SX2->X2_MODO
							cCompModoU	:= SX2->X2_MODOUN
							cCompModoE	:= SX2->X2_MODOEMP
							SX2->(MsUnlock())
						Endif
					EndIf
				EndIf
			EndIf
			DbSelectArea("DHL")
		EndIf

		// Varre os Aprovadores (SAK)
		DbSelectArea("SAK")
		SAK->(DbGoTop())
		While SAK->(!Eof())
			If cUlFilial != SAK->AK_FILIAL
				cUlFilial	:= SAK->AK_FILIAL
				cCodigo		:= Padl("",TamSX3("AL_PERFIL")[1],"0")
			EndIf

			cQuery := "SELECT R_E_C_N_O_ REC"
			cQuery += " FROM "+RetSqlName("SAL")+" SAL"
			cQuery += " WHERE (SAL.AL_FILIAL = '" + FWUpFunFil("SAL",SAK->AK_FILIAL) + "')"//Função similar a xFilial preparada para utilização via RUP
			cQuery += " AND (SAL.AL_APROV = '" + SAK->AK_COD  + "') "
			cQuery += " AND (SAL.AL_USER = '"  + SAK->AK_USER + "') "
			cQuery += " AND (SAL.AL_PERFIL = ' ') "
			cQuery += " AND (SAL.D_E_L_E_T_ <> '*')"
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSAL,.T.,.T.)

			(cAliasSAL)->(DbGoTop())
			IF (cAliasSAL)->(!Eof())//Existe Grupo de Aprovação Sem Perfil

				//Atribui Próximo Código Não Utilizado Nesta Filial
				cCodigo	:= Soma1(cCodigo)
				While DHL->(DbSeek( FWUpFunFil("DHL",SAK->AK_FILIAL) + cCodigo ))
					cCodigo	:= Soma1(cCodigo)
				EndDo

				// Insere Perfil
				cDescri	:= SubStr( AllTrim(SAK->AK_COD) + " " +  AllTrim(SAK->AK_NOME) , 1 , TamSX3("DHL_DESCRI")[1] )
				If RecLock("DHL",.T.)
					DHL->DHL_FILIAL	:= FWUpFunFil("DHL",SAK->AK_FILIAL)
					DHL->DHL_COD	:= cCodigo
					DHL->DHL_DESCRI	:= cDescri
					DHL->DHL_LIMMIN	:= SAK->AK_LIMMIN
					DHL->DHL_LIMMAX	:= SAK->AK_LIMMAX
					DHL->(MsUnlock())
				Endif

				//Atualiza Perfil no Grupo de Aprovação
				While (cAliasSAL)->(!Eof())
					SAL->(DbGoTo( (cAliasSAL)->REC ))
					If RecLock("SAL",.F.)
						SAL->AL_PERFIL := cCodigo
						SAL->(MsUnlock())
					Endif
					(cAliasSAL)->(DbSkip())
				Enddo
			EndIf
			(cAliasSAL)->(DbCloseArea())

			SAK->(DbSkip())
		Enddo
	EndIf
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FS2DBH7H9
Função para migrar os dados das tabelas SH7 e SH9 do FileSystem para o Banco
@author Alexandre Gimenez
@since 26/06/2017
@version 1.0
/*/
//------------------------------------------------------------------
Static Function FS2DBH7H9()

FS2DBCalen("SH7")
FS2DBCalen("SH9")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FS2DBH7H9
Função para migrar os dados das tabelas SH7 e SH9 do FileSystem para o Banco
@author Alexandre Gimenez
@since 26/06/2017
@version 1.0
/*/
//------------------------------------------------------------------
Static Function FS2DBCalen(cTabela)
Local cPath		:= ""
Local cArq		:= ""
Local cExt		:= GetDBExtension()
Local cAliasOld	:= GetNextAlias()
Local aStru		:= {}
Local nX		:= 0

//Identificar Local da tabela em arquivo.
DbSelectArea("SX2")
DbSetOrder(1)
If SX2->(dbSeek(cTabela))
	cPath := Alltrim(SX2->X2_PATH)
	cArq  := Alltrim(SX2->X2_ARQUIVO)
EndIf

If File(cPath+cArq+cExt) .And. ChkFile(cTabela)
	//Conecta a tabela em disco
	DBUseArea( .T. , __LocalDriver , cPath+cArq , cAliasOld , , .T. )
	aStru := (cTabela)->(dbStruct())
	(cTabela)->(DbGoTop())
	If (cTabela)->(EOF())
		//Grava dados do Arquivo local no tabela nova no banco
		While !((cAliasOld)->(EOF()))
			RecLock(cTabela,.T.)
				For nX := 1 To Len(aStru)
					IF (aStru[nX,1]) == "H7_ALOC"
						(cTabela)->H7_ALOC := Bin2Str((cAliasOld)->H7_ALOC)
					ElseIf (aStru[nX,1]) == "H9_ALOC"
						(cTabela)->H9_ALOC := Bin2Str((cAliasOld)->H9_ALOC)
					Else
						(cTabela)->&(aStru[nX,1]) := (cAliasOld)->&(aStru[nX,1])
					EndIf
				Next nX
			(cTabela)->(MsUnlock())
			(cAliasOld)->(DbSkip())
		End
	EndIf
EndIf

Return

/*/{Protheus.doc} AtuSCnaDhn
//Atualiza registros das Solicitações de Compras (SC1)
no Documentos da Biblioteca (DHN)

@author José Eulálio
@since 30/08/2017
@version 1.0
/*/
Static Function AtuSCnaDhn()
Local cQryDHN := GetNextAlias()

#IFDEF TOP
	BeginSQL Alias cQryDHN

		SELECT
			CQ_FILIAL	,
			CQ_NUM		,
			CQ_ITEM		,
			C1_FILIAL	,
			CQ_NUMSC	,
			C1_ITEM		,
			CQ_QUANT	,
			C1_QUANT
		FROM
			%Table:SCQ% SCQ
		JOIN
			%Table:SC1% SC1
		ON
			CQ_NUMSC = C1_NUM AND
			CQ_FILIAL = C1_FILIAL
		LEFT JOIN
			%Table:DHN% DHN
		ON
			DHN_DOCDES = CQ_NUMSC AND
			DHN_FILDES = CQ_FILIAL
		WHERE
			DHN_DOCDES IS NULL AND
			CQ_NUMSC <> %Exp:' '% AND
			SCQ.%NotDel% AND
			SC1.%NotDel% AND
			( DHN.%NotDel% OR DHN.D_E_L_E_T_ IS NULL )

	EndSQL

	While !(cQryDHN)->(Eof())
		Reclock("DHN",.T.)
			DHN->DHN_FILIAL	:= (cQryDHN)->CQ_FILIAL
			DHN->DHN_TIPO	:= '1'
			DHN->DHN_ROTINA	:= 'MATA106'
			DHN->DHN_FILORI	:= (cQryDHN)->CQ_FILIAL
			DHN->DHN_DOCORI	:= (cQryDHN)->CQ_NUM
			DHN->DHN_ITORI	:= (cQryDHN)->CQ_ITEM
			DHN->DHN_FILDES	:= (cQryDHN)->C1_FILIAL
			DHN->DHN_DOCDES	:= (cQryDHN)->CQ_NUMSC
			DHN->DHN_ITDES	:= (cQryDHN)->C1_ITEM
			DHN->DHN_QTDATE	:= (cQryDHN)->CQ_QUANT
			DHN->DHN_QTDTOT	:= (cQryDHN)->C1_QUANT
		DHN->(MsUnlock())
		(cQryDHN)->(DbSkip())
	EndDo

	(cQryDHN)->(dbCloseArea())
#ENDIF

Return

/*/{Protheus.doc} AtuAEnaDhn
//Atualiza registros das Autorizações de Entrega (SC7)
no Documentos da Biblioteca (DHN)

@author José Eulálio
@since 30/08/2017
@version 1.0
/*/
Static Function AtuAEnaDhn()
Local cQryDHN := GetNextAlias()

#IFDEF TOP
	BeginSQL Alias cQryDHN

		SELECT
			CQ_FILIAL	,
			CQ_NUM		,
			CQ_ITEM		,
			C7_FILIAL	,
			CQ_NUMAE	,
			C7_ITEM		,
			CQ_QUANT	,
			C7_QUANT
		FROM
			%Table:SCQ% SCQ
		JOIN
			%Table:SC7% SC7
		ON
			CQ_NUMAE = C7_NUM AND
			CQ_FILIAL = C7_FILIAL
		LEFT JOIN
			%Table:DHN% DHN
		ON
			DHN_DOCDES = CQ_NUMAE AND
			DHN_FILDES = CQ_FILIAL
		WHERE
			DHN_DOCDES IS NULL AND
			CQ_NUMAE <> %Exp:' '% AND
			SCQ.%NotDel% AND
			SC7.%NotDel% AND
			( DHN.%NotDel% OR DHN.D_E_L_E_T_ IS NULL )

	EndSQL

	While !(cQryDHN)->(Eof())
		Reclock("DHN",.T.)
			DHN->DHN_FILIAL	:= (cQryDHN)->CQ_FILIAL
			DHN->DHN_TIPO	:= '3'
			DHN->DHN_ROTINA	:= 'MATA106'
			DHN->DHN_FILORI	:= (cQryDHN)->CQ_FILIAL
			DHN->DHN_DOCORI	:= (cQryDHN)->CQ_NUM
			DHN->DHN_ITORI	:= (cQryDHN)->CQ_ITEM
			DHN->DHN_FILDES	:= (cQryDHN)->C7_FILIAL
			DHN->DHN_DOCDES	:= (cQryDHN)->CQ_NUMAE
			DHN->DHN_ITDES	:= (cQryDHN)->C7_ITEM
			DHN->DHN_QTDATE	:= (cQryDHN)->CQ_QUANT
			DHN->DHN_QTDTOT	:= (cQryDHN)->C7_QUANT
		DHN->(MsUnlock())
		(cQryDHN)->(DbSkip())
	EndDo

	(cQryDHN)->(dbCloseArea())
#ENDIF

Return

/*/{Protheus.doc} COMSX3GRP
//Atualiza dicionario SX3

@author Rodrigo Pontes
@since 30/08/2017
@version 1.0
/*/

Function COMSX3GRP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
	Local aArea		:= GetArea()
	Local cUsado	:= ""
	Local cUpd		:= ""
	Local cValid	:= ""
	Local lDicInDB 	:= MPDicInDB()
	
	//Verifica de dicionario esta no banco de dados ou system
	// .T. = Banco de dados
	// .F. = System

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))

	//Propriedade de campo usado pelo sistema
	If SX3->(DbSeek("D1_COD"))
		cUsado := SX3->X3_USADO
	Endif
	
	If Val(cRelFinish) < 27
		If !lDicInDB
			If SX3->(DbSeek("C8_DESCRI"))
				If !("A150INICPAD" $ AllTrim(SX3->X3_RELACAO)) .Or. !("A150INICPAD" $ AllTrim(SX3->X3_INIBRW)) .And. FindFunction("A150INICPAD")
					If RecLock("SX3",.F.)
						SX3->X3_RELACAO	:= "A150INICPAD('P')"
						SX3->X3_INIBRW	:= "A150INICPAD('B')"
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("AK_TIPO"))
				If RecLock("SX3",.F.)
					SX3->X3_USADO := cUsado
					SX3->(MsUnlock())
				Endif
			Endif

			If SX3->(DbSeek("D1_VALFRE"))
				If RecLock("SX3",.F.)
					SX3->X3_USADO := cUsado
					SX3->(MsUnlock())
				Endif

				If !("A140DespGat()" $ AllTrim(SX3->X3_VALID))
					If RecLock("SX3",.F.)
						SX3->X3_VALID := AllTrim(SX3->X3_VALID) + " .And. A140DespGat()"
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("D1_VUNIT"))
				If AllTrim(SX3->X3_VALID) == 'A103TOLER().And.NaoVazio().AND.Positivo().And.MaFisRef("IT_PRCUNI","MT100",M->D1_VUNIT)'
					If RecLock("SX3",.F.)
						SX3->X3_VALID := 'A103TOLER().And.MaFisRef("IT_PRCUNI","MT100",M->D1_VUNIT)'
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("D1_QUANT"))
				If AllTrim(SX3->X3_VALID) == 'A103TOLER().And.Positivo().And.A100SegUm().And.MaFisRef("IT_QUANT","MT100",M->D1_QUANT)'
					If RecLock("SX3",.F.)
						SX3->X3_VALID := 'A103TOLER().And.A100SegUm().And.MaFisRef("IT_QUANT","MT100",M->D1_QUANT)'
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("DBK_EC05DB"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC05DB,,'05') .Or. M->DBK_EC05DB=='*'"
					If RecLock("SX3",.F.)
						SX3->X3_VALID := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC05DB"),,"05") .Or. FwFldGet("DBK_EC05DB")=="*"'
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("DBK_EC05CR"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC05CR,,'05') .Or. M->DBK_EC05CR=='*'"
					If RecLock("SX3",.F.)
						SX3->X3_VALID := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC05CR"),,"05") .Or. FwFldGet("DBK_EC05CR")=="*"'
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("DBK_EC06DB"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC06DB,,'06') .Or. M->DBK_EC06DB=='*'"
					If RecLock("SX3",.F.)
						SX3->X3_VALID := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC06DB"),,"06") .Or. FwFldGet("DBK_EC06DB")=="*"'
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("DBK_EC06CR"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC06CR,,'06') .Or. M->DBK_EC06CR=='*'"
					If RecLock("SX3",.F.)
						SX3->X3_VALID := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC06CR"),,"06") .Or. FwFldGet("DBK_EC06CR")=="*"'
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("DBK_EC07DB"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC07DB,,'07') .Or. M->DBK_EC07CR=='*'"
					If RecLock("SX3",.F.)
						SX3->X3_VALID := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC07DB"),,"07") .Or. FwFldGet("DBK_EC07DB")=="*"'
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("DBK_EC07CR"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC07CR,,'07') .Or. M->DBK_EC07CR=='*'"
					If RecLock("SX3",.F.)
						SX3->X3_VALID := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC07CR"),,"07") .Or. FwFldGet("DBK_EC07CR")=="*"'
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("DBK_EC08DB"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC08DB,,'08') .Or. M->DBK_EC08DB=='*'"
					If RecLock("SX3",.F.)
						SX3->X3_VALID := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC08DB"),,"08") .Or. FwFldGet("DBK_EC08DB")=="*"'
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("DBK_EC08CR"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC08CR,,'08') .Or. M->DBK_EC08CR=='*'"
					If RecLock("SX3",.F.)
						SX3->X3_VALID := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC08CR"),,"08") .Or. FwFldGet("DBK_EC08CR")=="*"'
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("DBK_EC09DB"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC09DB,,'09') .Or. M->DBK_EC09DB=='*'"
					If RecLock("SX3",.F.)
						SX3->X3_VALID := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC09DB"),,"09") .Or. FwFldGet("DBK_EC09DB")=="*"'
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("DBK_EC09CR"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC09CR,,'09') .Or. M->DBK_EC09CR=='*'"
					If RecLock("SX3",.F.)
						SX3->X3_VALID := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC09CR"),,"09") .Or. FwFldGet("DBK_EC09CR")=="*"'
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("CKO_FILPRO"))
				If SX3->X3_GRPSXG <> "033"
					If RecLock("SX3",.F.)
						SX3->X3_GRPSXG := "033"
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("A2_REPRCGC"))
				If AllTrim(SX3->X3_VALID) <> "vazio() .or. cgc(M->A2_REPRCGC)"
					If RecLock("SX3",.F.)
						SX3->X3_VALID := "vazio() .or. cgc(M->A2_REPRCGC)"
						SX3->(MsUnlock())
					Endif
				Endif
			Endif

			If SX3->(DbSeek("DF_PE")) .And. AllTrim(SX3->X3_RELACAO) == 'Posicione("SB1",1,xFilial("SB1")+M->DF_PRODUTO,"B1_PE")'
				If RecLock("SX3",.F.)
					SX3->X3_RELACAO := 'RetFldProd(SB1->B1_COD,"B1_PE")'
					SX3->(MsUnlock())
				Endif
			EndIf

			If SX3->(DbSeek("C8_BASESOL"))
				If RecLock("SX3",.F.)
					SX3->X3_USADO := cUsado
					SX3->(MsUnlock())
				Endif
			EndIf

			If SX3->(DbSeek("C8_VALSOL"))
				If RecLock("SX3",.F.)
					SX3->X3_USADO := cUsado
					SX3->(MsUnlock())
				Endif
			EndIf

			If SX3->(DbSeek("DS_NOMEFOR"))
				If RecLock("SX3",.F.)
					SX3->X3_WHEN := ".F."
					SX3->(MsUnlock())
				Endif
			EndIf

			If SX3->(DbSeek("DT_QTSEGUM")) .And. SX3->X3_VISUAL == "V"
				If RecLock("SX3",.F.)
					SX3->X3_VISUAL	:= "A"
					SX3->X3_VALID	:= 'COLVLSEGUM()'
					SX3->(MsUnlock())
				Endif
			Endif
		Else
			If SX3->(DbSeek("C8_DESCRI"))
				If !("A150INICPAD" $ AllTrim(SX3->X3_RELACAO)) .Or. !("A150INICPAD" $ AllTrim(SX3->X3_INIBRW)) .And. FindFunction("A150INICPAD")
					cInicP	:= 'A150INICPAD("P")'
					cInicB	:= 'A150INICPAD("B")'
					cUpd := " UPDATE " + MPSysSqlName("SX3")
					cUpd += " SET X3_RELACAO = '" + cInicP + "'"
					cUpd += " ,   X3_INIBRW = '" + cInicB + "'"
					cUpd += " WHERE X3_CAMPO = 'C8_DESCRI'"
					cUpd += " AND D_E_L_E_T_ = ' '"

					TCSqlExec(cUpd)
				Endif
			Endif

			If SX3->(DbSeek("AK_TIPO"))
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_USADO = '" + cUsado + "'"
				cUpd += " WHERE X3_CAMPO = 'AK_TIPO'"
				cUpd += " AND D_E_L_E_T_ = ' '"

				TCSqlExec(cUpd)
			Endif

			If SX3->(DbSeek("D1_VALFRE"))
				If !("A140DespGat()" $ AllTrim(SX3->X3_VALID))
					cValid := AllTrim(SX3->X3_VALID) + ".And. A140DespGat()"
				Else
					cValid := AllTrim(SX3->X3_VALID)
				Endif

				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_USADO = '" + cUsado + "'"
				cUpd += " ,   X3_VALID = '" + cValid + "'"
				cUpd += " WHERE X3_CAMPO = 'D1_VALFRE'"
				cUpd += " AND D_E_L_E_T_ = ' '"

				TCSqlExec(cUpd)
			Endif

			If SX3->(DbSeek("D1_VUNIT"))
				If AllTrim(SX3->X3_VALID) == 'A103TOLER().And.NaoVazio().AND.Positivo().And.MaFisRef("IT_PRCUNI","MT100",M->D1_VUNIT)'
					cValid := 'A103TOLER().And.MaFisRef("IT_PRCUNI","MT100",M->D1_VUNIT)'

					cUpd := " UPDATE " + MPSysSqlName("SX3")
					cUpd += " SET X3_VALID = '" + cValid + "'"
					cUpd += " WHERE X3_CAMPO = 'D1_VUNIT'"
					cUpd += " AND D_E_L_E_T_ = ' '"

					TCSqlExec(cUpd)
				Endif
			Endif

			If SX3->(DbSeek("D1_QUANT"))
				If AllTrim(SX3->X3_VALID) == 'A103TOLER().And.Positivo().And.A100SegUm().And.MaFisRef("IT_QUANT","MT100",M->D1_QUANT)'
					cValid := 'A103TOLER().And.A100SegUm().And.MaFisRef("IT_QUANT","MT100",M->D1_QUANT)'

					cUpd := " UPDATE " + MPSysSqlName("SX3")
					cUpd += " SET X3_VALID = '" + cValid + "'"
					cUpd += " WHERE X3_CAMPO = 'D1_QUANT'"
					cUpd += " AND D_E_L_E_T_ = ' '"

					TCSqlExec(cUpd)
				Endif
			Endif

			If SX3->(DbSeek("CKO_FILPRO"))
				If SX3->X3_GRPSXG <> "033"
					cUpd := " UPDATE " + MPSysSqlName("SX3")
					cUpd += " SET X3_GRPSXG = '033'"
					cUpd += " WHERE X3_CAMPO = 'CKO_FILPRO'"
					cUpd += " AND D_E_L_E_T_ = ' '"

					TCSqlExec(cUpd)
				Endif
			Endif

			If SX3->(DbSeek("A2_REPRCGC"))
				If AllTrim(SX3->X3_VALID) <> "vazio() .or. cgc(M->A2_REPRCGC)"
					cUpd := " UPDATE " + MPSysSqlName("SX3")
					cUpd += " SET X3_VALID = 'vazio() .or. cgc(M->A2_REPRCGC)'"
					cUpd += " WHERE X3_CAMPO = 'A2_REPRCGC'"
					cUpd += " AND D_E_L_E_T_ = ' '"
				Endif
			Endif
			If SX3->(DbSeek("DF_PE"))
				If AllTrim(SX3->X3_RELACAO) == 'Posicione("SB1",1,xFilial("SB1")+M->DF_PRODUTO,"B1_PE")'
					cUpd := " UPDATE " + MPSysSqlName("SX3")
					cUpd += " SET X3_RELACAO = '" + 'RetFldProd(SB1->B1_COD,"B1_PE")' + "'"
					cUpd += " WHERE X3_CAMPO = 'DF_PE' "
					cUpd += " AND X3_RELACAO = '" + 'Posicione("SB1",1,xFilial("SB1")+M->DF_PRODUTO,"B1_PE")' + "'"
					cUpd += " AND D_E_L_E_T_ 	= ' ' "
					TCSqlExec(cUpd)
				EndIf
			EndIf
			If SX3->(DbSeek("C8_BASESOL"))
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_USADO = '" + cUsado + "'"
				cUpd += " WHERE X3_CAMPO = 'C8_BASESOL'"
				cUpd += " AND D_E_L_E_T_ = ' '"

				TCSqlExec(cUpd)
			EndIf
			If SX3->(DbSeek("C8_VALSOL"))
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_USADO = '" + cUsado + "'"
				cUpd += " WHERE X3_CAMPO = 'C8_VALSOL'"
				cUpd += " AND D_E_L_E_T_ = ' '"

				TCSqlExec(cUpd)
			EndIf
			If SX3->(DbSeek("DS_NOMEFOR"))
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_WHEN = '.F.' "
				cUpd += " WHERE X3_CAMPO = 'DS_NOMEFOR'"
				cUpd += " AND D_E_L_E_T_ = ' '"

				TCSqlExec(cUpd)
			EndIf

			If SX3->(DbSeek("DBK_EC05DB"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC05DB,,'05') .Or. M->DBK_EC05DB=='*'"
				cValid := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC05DB"),,"05") .Or. FwFldGet("DBK_EC05DB")=="*"'
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_VALID ='" + cValid + "'"
				cUpd += " WHERE X3_CAMPO = 'DBK_EC05DB'"
				cUpd += " AND D_E_L_E_T_ = ' '"
				TCSqlExec(cUpd)
				Endif
			EndIf

			If SX3->(DbSeek("DBK_EC05CR"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC05CR,,'05') .Or. M->DBK_EC05CR=='*'"
				cValid := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC05CR"),,"05") .Or. FwFldGet("DBK_EC05CR")=="*"'
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_VALID ='" + cValid + "'"
				cUpd += " WHERE X3_CAMPO = 'DBK_EC05CR'"
				cUpd += " AND D_E_L_E_T_ = ' '"
				TCSqlExec(cUpd)
				Endif
			EndIf

			If SX3->(DbSeek("DBK_EC06DB"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC06DB,,'06') .Or. M->DBK_EC06DB=='*'"
				cValid := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC06DB"),,"06") .Or. FwFldGet("DBK_EC06DB")=="*"'
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_VALID ='" + cValid + "'"
				cUpd += " WHERE X3_CAMPO = 'DBK_EC06DB'"
				cUpd += " AND D_E_L_E_T_ = ' '"
				TCSqlExec(cUpd)
				Endif
			EndIf

			If SX3->(DbSeek("DBK_EC06CR"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC06CR,,'06') .Or. M->DBK_EC06CR=='*'"
				cValid := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC06CR"),,"06") .Or. FwFldGet("DBK_EC06CR")=="*"'
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_VALID ='" + cValid + "'"
				cUpd += " WHERE X3_CAMPO = 'DBK_EC06CR'"
				cUpd += " AND D_E_L_E_T_ = ' '"
				TCSqlExec(cUpd)
				Endif
			EndIf

			If SX3->(DbSeek("DBK_EC07DB"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC07DB,,'07') .Or. M->DBK_EC07CR=='*'"
				cValid := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC07DB"),,"07") .Or. FwFldGet("DBK_EC07DB")=="*"'
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_VALID ='" + cValid + "'"
				cUpd += " WHERE X3_CAMPO = 'DBK_EC07DB'"
				cUpd += " AND D_E_L_E_T_ = ' '"
				TCSqlExec(cUpd)
				Endif
			EndIf

			If SX3->(DbSeek("DBK_EC07CR"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC07CR,,'07') .Or. M->DBK_EC07CR=='*'"
				cValid := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC07CR"),,"07") .Or. FwFldGet("DBK_EC07CR")=="*"'
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_VALID ='" + cValid + "'"
				cUpd += " WHERE X3_CAMPO = 'DBK_EC07CR'"
				cUpd += " AND D_E_L_E_T_ = ' '"
				TCSqlExec(cUpd)
				Endif
			EndIf

			If SX3->(DbSeek("DBK_EC08DB"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC08DB,,'08') .Or. M->DBK_EC08DB=='*'"
				cValid := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC08DB"),,"08") .Or. FwFldGet("DBK_EC08DB")=="*"'
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_VALID ='" + cValid + "'"
				cUpd += " WHERE X3_CAMPO = 'DBK_EC08DB'"
				cUpd += " AND D_E_L_E_T_ = ' '"
				TCSqlExec(cUpd)
				Endif
			EndIf

			If SX3->(DbSeek("DBK_EC08CR"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC08CR,,'08') .Or. M->DBK_EC08CR=='*'"
				cValid := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC08CR"),,"08") .Or. FwFldGet("DBK_EC08CR")=="*"'
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_VALID ='" + cValid + "'"
				cUpd += " WHERE X3_CAMPO = 'DBK_EC08CR'"
				cUpd += " AND D_E_L_E_T_ = ' '"
				TCSqlExec(cUpd)
				Endif
			EndIf

			If SX3->(DbSeek("DBK_EC09DB"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC09DB,,'09') .Or. M->DBK_EC09DB=='*'"
				cValid := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC09DB"),,"09") .Or. FwFldGet("DBK_EC09DB")=="*"'
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_VALID ='" + cValid + "'"
				cUpd += " WHERE X3_CAMPO = 'DBK_EC09DB'"
				cUpd += " AND D_E_L_E_T_ = ' '"
				TCSqlExec(cUpd)
				Endif
			EndIf

			If SX3->(DbSeek("DBK_EC09CR"))
				If AllTrim(SX3->X3_VALID) == "Vazio() .Or. CTB105EntC(,M->DBK_EC09CR,,'09') .Or. M->DBK_EC09CR=='*'"
				cValid := 'Vazio() .Or. CTB105EntC(FwFldGet("DBK_EC09CR"),,"09") .Or. FwFldGet("DBK_EC09CR")=="*"'
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_VALID ='" + cValid + "'"
				cUpd += " WHERE X3_CAMPO = 'DBK_EC09CR'"
				cUpd += " AND D_E_L_E_T_ = ' '"
				TCSqlExec(cUpd)
				Endif
			EndIf

			If SX3->(DbSeek("DT_QTSEGUM")) .And. SX3->X3_VISUAL == "V"
				cUpd := " UPDATE " + MPSysSqlName("SX3")
				cUpd += " SET X3_VISUAL = 'A' "
				cUpd += " ,   X3_VALID	= 'COLVLSEGUM()'"
				cUpd += " WHERE X3_CAMPO = 'DT_QTSEGUM' "
				cUpd += " AND X3_VISUAL = 'V' "
				cUpd += " AND D_E_L_E_T_ 	= ' ' "
				TCSqlExec(cUpd)
			Endif

		Endif

		If cPaisLoc == "BRA"
			UpdSA2Ord()
		EndIf
	Endif

	If Val(cRelFinish) < 2310 
		If SX3->(DbSeek("A5_CODPRCA"))
			cUpd := " UPDATE " + MPSysSqlName("SX3")
			cUpd += " SET X3_F3 = ''"
			cUpd += " WHERE X3_CAMPO = 'A5_CODPRCA' "
			cUpd += " AND D_E_L_E_T_ 	= ' ' "
			TCSqlExec(cUpd)
		Endif
	Endif

	RestArea(aArea)

Return

//--------------------------------------------------------------------------
/*/{Protheus.doc} AtuEstSx3
Atualiza SX3

@author José Eulálio
@since 27/09/2017
@version 1.0
/*/
//--------------------------------------------------------------------------
Function AtuEstSx3(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
Local aAreaSX3 	:= SX3->(GetArea())
Local cUsadoOpc	:= ""
Local cReservOpc  := ""
Local lRelease    := ""

//Atualiza X3_RELACAO do campo C5_MODANP
If cVersion == "12" .And. Val(cRelStart) <= 27 .And. Val(cRelFinish) > 14
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("C5_MODANP")) .And. !(Empty(SX3->X3_RELACAO))
		If RecLock("SX3",.F.)
			SX3->X3_RELACAO := ""
			SX3->(MsUnlock())
		Endif
	EndIf
EndIf

lRelease := cVersion == "12" .And. Val(cRelStart) <= 17 .And. Val(cRelFinish) == 17
If lRelease .AND. SX3->( dbSeek("CP_QUANT") ) //Este campo eh opcional e permite alterar
	cUsadoOpc	:= SX3->X3_USADO
	cReservOpc	:= SX3->X3_RESERV
EndIf

If cVersion == "12" .And. Val(cRelStart) <= 17 .And. Val(cRelFinish) == 17
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("CP_NRBPIMS")) .And. SX3->X3_USADO # cUsadoOpc
		If RecLock("SX3",.F.)
			SX3->X3_USADO 	:= cUsadoOpc
			SX3->X3_RESERV	:= cReservOpc
			SX3->(MsUnlock())
		Endif
	EndIf
EndIf

RestArea(aAreaSX3)

Return


//--------------------------------------------------------------------------
/*/{Protheus.doc} AtuEstSx9
Atualiza SX9

@author Totvs
@since 27/09/2017
@version 1.0
/*/
//--------------------------------------------------------------------------
Function AtuEstSx9(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
Local aAreaSX9	:= SX9->(GetArea())

//Exclui relacionamentos
If cVersion == "12" .And. Val(cRelStart) <= 27 .And. Val(cRelFinish) > 14 .And. Val(cRelFinish) < 18
	SX9->(DbSetOrder(1)) // X9_DOM
	If SX9->(DbSeek("SB1")) //-- Apagar B1_PRDORI
		While SX9->(!Eof())
			If (cPaisLoc # "BRA" .And. AllTrim(SX9->(X9_CDOM+X9_DOM+X9_EXPCDOM)) == "SB1SB1B1_PRDORI") .Or. ;
			   (cPaisLoc # "BRA" .And. AllTrim(SX9->(X9_CDOM+X9_DOM+X9_EXPCDOM)) == "SS5SB1S5_COD" 	) .Or.  ;
				(AllTrim(SX9->(X9_CDOM+X9_DOM+X9_EXPCDOM)) == "SS5SB1S5_CODITE")
				Reclock("SX9",.F.)
				SX9->( DbDelete() )
				SX9->(MsUnlock())
			EndIf
			SX9->(DbSkip())
		EndDo
	EndIf
	If cPaisLoc # "BRA"
		SX9->(DbSetOrder(2)) // X9_CDOM+X9_DOM
		If SX9->(DbSeek("SD3SA2")) //-- Apagar D3_CODFOR
			Reclock("SX9",.F.)
			SX9->( DbDelete() )
			SX9->(MsUnlock())
		EndIf
	EndIf
EndIf
RestArea(aAreaSX9)
Return

//--------------------------------------------------------------------------
/*/{Protheus.doc} COMSX9GRP
Atualiza SX3

@author Totvs
@since 28/12/2017
@version 1.0
/*/
//--------------------------------------------------------------------------
Function COMSX9GRP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
Local aAreaSX9	:= SX9->(GetArea())
Local lDelSAL	:= .F.

//Exclui relacionamentos
SX9->(DbSetOrder(1)) // X9_DOM

If Val(cRelFinish) < 27
	If SX9->(DbSeek("SA2")) //-- Apagar relacionamento SA2 x DUD
		While SX9->(!Eof()) .and. AllTrim(SX9->X9_DOM) == "SA2"
			If (AllTrim(SX9->(X9_DOM+X9_CDOM)) == "SA2DUD")
				If Reclock("SX9",.F.)
					SX9->(DbDelete())
					SX9->(MsUnlock())
				Endif
			EndIf
			SX9->(DbSkip())
		EndDo
	EndIf

	If SX9->(DbSeek("DUD")) //-- Apagar relacionamento DUD x SA2
		While SX9->(!Eof()) .and. AllTrim(SX9->X9_DOM) == "DUD"
			If (AllTrim(SX9->(X9_DOM+X9_CDOM)) == "DUDSA2")
				If Reclock("SX9",.F.)
					SX9->(DbDelete())
					SX9->(MsUnlock())
				Endif
			EndIf
			SX9->(DbSkip())
		EndDo
	EndIf

	If SX9->(DbSeek("DBL")) //-- Apagar relacionamento DBL x SCR
		While SX9->(!Eof()) .and. AllTrim(SX9->X9_DOM) == "DBL"
			If (AllTrim(SX9->(X9_DOM+X9_CDOM)) == "DBLSCR")
				If Reclock("SX9",.F.)
					SX9->(DbDelete())
					SX9->(MsUnlock())
				Endif
			EndIf
			SX9->(DbSkip())
		EndDo
	EndIf

	If SX9->(DbSeek("SAL"))//-- Apagar relacionamentos indevidos SAL
		While SX9->(!Eof()) .and. AllTrim(SX9->X9_DOM) == "SAL"
			lDelSAL := .F.

			//-- Apagar relacionamento SAL x SCR
			If (AllTrim(SX9->(X9_DOM+X9_CDOM)) == "SALSCR")
				If Reclock("SX9",.F.)
					SX9->(DbDelete())
					SX9->(MsUnlock())
				Endif

				SX9->(DbSeek("SAL"))
				lDelSAL := .T.
			EndIf

			//-- Apagar relacionamento SAL x SC7
			If (AllTrim(SX9->(X9_DOM+X9_CDOM)) == "SALSC7")
				If Reclock("SX9",.F.)
					SX9->(DbDelete())
					SX9->(MsUnlock())
				Endif

				SX9->(DbSeek("SAL"))
				lDelSAL := .T.
			EndIf

			//-- Apagar relacionamento SAL x SCY
			If (AllTrim(SX9->(X9_DOM+X9_CDOM)) == "SALSCY")
				If Reclock("SX9",.F.)
					SX9->(DbDelete())
					SX9->(MsUnlock())
				Endif

				SX9->(DbSeek("SAL"))
				lDelSAL := .T.
			EndIf

			If !lDelSAL
				SX9->(DbSkip())
			EndIF
		EndDo
	EndIf

	If SX9->(DbSeek("SA2")) //-- Apagar relacionamento SA2 x SF1 para X9_EXPCDOM = F1_FORRET ou F1_FORENT
		While SX9->(!Eof()) .and. AllTrim(SX9->X9_DOM) == "SA2"
			If (AllTrim(SX9->(X9_DOM+X9_CDOM)) == "SA2SF1")
				If AllTrim(SX9->X9_EXPDOM) == "A2_COD" .And. (AllTrim(SX9->X9_EXPCDOM) == "F1_FORRET" .Or. AllTrim(SX9->X9_EXPCDOM) == "F1_FORENT")
					If Reclock("SX9",.F.)
						SX9->(DbDelete())
						SX9->(MsUnlock())
					Endif
				EndIf
			EndIf
			SX9->(DbSkip())
		EndDo
	EndIf

	If SX9->(DbSeek("SAJ")) //-- Apagar relacionamento SAJ para X9_CDOM = SS4,SY1, SC1, SC8, SCY, SAI, SB1, SC
		While SX9->(!Eof()) .and. AllTrim(SX9->X9_DOM) == "SAJ"
			If AllTrim(SX9->X9_EXPDOM) == "AJ_GRCOM" .And. (AllTrim(SX9->X9_EXPCDOM) $ "S4_GRUPCOM|Y1_GRUPCOM|C1_GRUPCOM|C8_GRUPCOM|CY_GRUPCOM|AI_GRUPCOM|B1_GRUPCOM|C7_GRUPCOM")
				If Reclock("SX9",.F.)
					SX9->(DbDelete())
					SX9->(MsUnlock())
				Endif
			EndIf
			SX9->(DbSkip())
		EndDo
	EndIf
Endif

If Val(cRelFinish) < 33
	If SX9->(DbSeek("SAI")) //-- Apagar relacionamento SAI X SC1
		While SX9->(!Eof()) .and. AllTrim(SX9->X9_DOM) == "SAI"
			If AllTrim(SX9->X9_EXPDOM) == "AI_USER" .And. AllTrim(SX9->X9_EXPCDOM) =="C1_USER"
				If Reclock("SX9",.F.)
					SX9->(DbDelete())
					SX9->(MsUnlock())
				Endif
			EndIf
			SX9->(DbSkip())
		EndDo
	EndIf
Endif

RestArea(aAreaSX9)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuEstSX1
Atualiza perguntas

@author José Eulálio
@since 12/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function AtuEstSX1(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
Local aRegs	:= {}
Local cPerg	:= PadR("CPR001",Len(SX1->X1_GRUPO))
Local nX		:= 0
Local nY		:= 0

AADD(aRegs,{cPerg,"01","Mes............... ?","","","mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""		,"",""})
AADD(aRegs,{cPerg,"02","Ano............... ?","","","mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""		,"",""})
AADD(aRegs,{cPerg,"03","Path Gravacao..... ?","","","mv_ch3","C",30,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""		,"",""})
AADD(aRegs,{cPerg,"04","Reprocessa Arquivo ?","","","mv_ch4","N",01,0,0,"C","","mv_par04","Sim","","","","","Nao","","","","","","","","","","","","","","","","",""		,"","","",""})
AADD(aRegs,{cPerg,"05","Produto De ....... ?","","","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SB1"	,"",""})
AADD(aRegs,{cPerg,"06","Produto Ate ...... ?","","","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SB1"	,"",""})
AADD(aRegs,{cPerg,"07","Poder Terceiros... ?","","","mv_ch7","N",01,0,0,"C","","mv_par07","Sim","","","","","Nao","","","","","","","","","","","","","","","","","",""	,"","",""})
AADD(aRegs,{cPerg,"08","Filial De ........ ?","","","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""	,""})
AADD(aRegs,{cPerg,"09","Filial Ate ....... ?","","","mv_ch9","C",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""	,""})
AADD(aRegs,{cPerg,"10","Armazem De........ ?","","","mv_cha","C",02,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","",""	,""})
AADD(aRegs,{cPerg,"11","Armazem Ate....... ?","","","mv_chb","C",02,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","",""	,""})

For nX := 1 to Len(aRegs)
	If ! SX1->(DbSeek(cPerg+aRegs[nX,2]))
		RecLock("SX1",.T.)
		For nY := 1 to FCount()
			If nY <= Len(aRegs[nX])
				FieldPut(nY,aRegs[nX,nY])
			EndIf
		Next nY
		MsUnlock()
	EndIf
Next nX
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} COMSX1GRP
Atualiza perguntas MTR110

@author Leandro Nishihata
@since 16/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function COMSX1GRP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

Local aRegs		:= {}
Local cPerg		:= PadR("MTR110",Len(SX1->X1_GRUPO))
Local nX		:= 0
Local nY		:= 0
Local lDicInDB	:= MPDicInDB()

If Val(cRelFinish) < 27
	AADD(aRegs,{cPerg,"12","Qual Moeda ?                  ","¿Que Moneda ?                 ","Currency ?                    ","MV_CH1","N",01,0,0,"G","","MV_PAR12 ","","","","","","","","","","","","","","","","","","","","","","","","","SM2","",""})

	If !lDicInDB
		For nX := 1 to Len(aRegs)
			If  SX1->(DbSeek(cPerg+aRegs[nX,2]))
				If RecLock("SX1",.F.)
					For nY := 1 to FCount()
						If nY <= Len(aRegs[nX])
							SX1->(FieldPut(nY,aRegs[nX,nY]))
						EndIf
					Next nY
					SX1->(MsUnlock())
				Endif
			EndIf
		Next nX
	Else
		cUpd := " UPDATE " + MPSysSqlName("SX1")
		cUpd += " SET X1_VARIAVL = 'MV_CH1', "
		cUpd += " 	  X1_PRESEL	 = '0',"
		cUpd += " 	  X1_GSC	 = 'G',"
		cUpd += " 	  X1_VAR01   = 'MV_PAR12',"
		cUpd += " 	  X1_DEF01   = ' ',"
		cUpd += " 	  X1_DEFSPA1 = ' ',"
		cUpd += " 	  X1_DEFENG1 = ' ',"
		cUpd += " 	  X1_CNT01   = ' ',"
		cUpd += " 	  X1_DEF02   = ' ',"
		cUpd += " 	  X1_DEFSPA2 = ' ',"
		cUpd += " 	  X1_DEFENG2 = ' ',"
		cUpd += " 	  X1_CNT02   = ' ',"
		cUpd += " 	  X1_DEF03   = ' ',"
		cUpd += " 	  X1_DEFSPA3 = ' ',"
		cUpd += " 	  X1_DEFENG3 = ' ',"
		cUpd += " 	  X1_CNT03   = ' ',"
		cUpd += " 	  X1_DEF04   = ' ',"
		cUpd += " 	  X1_DEFSPA4 = ' ',"
		cUpd += " 	  X1_DEFENG4 = ' ',"
		cUpd += " 	  X1_CNT04   = ' ',"
		cUpd += " 	  X1_DEF05   = ' ',"
		cUpd += " 	  X1_DEFSPA5 = ' ',"
		cUpd += " 	  X1_DEFENG5 = ' ',"
		cUpd += " 	  X1_CNT05   = ' ',"
		cUpd += " 	  X1_F3   	 = 'SM2',"
		cUpd += " 	  X1_PYME    = ' '"
		cUpd += " WHERE X1_GRUPO = 'MTR110' "
		cUpd += " AND X1_ORDEM = '12' "
		cUpd += " AND D_E_L_E_T_ 	= '' "
		TCSqlExec(cUpd)
	Endif
Endif

Return

//--------------------------------------------------------------------------------------
//-------------------------------------------------------------------
/*/{Protheus.doc} AtuFlagDev
//Ajusta conteúdo default do parâmetro MV_FLAGDEV para T

@since 01/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Function AtuFlagDev()

Local lDicInDB := MPDicInDB()

DbSelectArea("SX6")
DbSetOrder(1)

//Tratamento Referente Filial Em Branco
If 	SX6->(MsSeek(Replicate(" ", FwSizeFilial())+"MV_FLAGDEV"))
	If !lDicInDB
		Reclock("SX6",.F.)
			SX6->X6_CONTEUD := "T"
			SX6->X6_CONTSPA := "T"
			SX6->X6_CONTENG := "T"
		MsUnlock()
	Else
		cUpd := " UPDATE " + MPSysSqlName("SX6")
		cUpd += " SET X6_CONTEUD = 'T' "
		cUpd += " ,X6_CONTSPA = 'T' "
		cUpd += " ,X6_CONTENG = 'T' "
		cUpd += " WHERE X6_VAR = 'MV_FLAGDEV' "
		cUpd += " AND X6_CONTEUD = 'F' "
		cUpd += " AND D_E_L_E_T_ 	= '' "
		TCSqlExec(cUpd)
	Endif
EndIf

//Tratamento Referente Empresa
If 	SX6->(MsSeek(PadR(FwCompany(),FwSizeFilial())+"MV_FLAGDEV"))
	If !lDicInDB
		Reclock("SX6",.F.)
			SX6->X6_CONTEUD := "T"
			SX6->X6_CONTSPA := "T"
			SX6->X6_CONTENG := "T"
		MsUnlock()
	Else
		cUpd := " UPDATE " + MPSysSqlName("SX6")
		cUpd += " SET X6_CONTEUD = 'T' "
		cUpd += " ,X6_CONTSPA = 'T' "
		cUpd += " ,X6_CONTENG = 'T' "
		cUpd += " WHERE X6_VAR = 'MV_FLAGDEV' "
		cUpd += " AND X6_CONTEUD = 'F' "
		cUpd += " AND D_E_L_E_T_ 	= '' "
		TCSqlExec(cUpd)
	Endif
EndIf

//Tratamento Referente Empresa + Filial
If 	SX6->(MsSeek(PadR(FwCompany()+FwUnitBusiness(),FwSizeFilial())+"MV_FLAGDEV"))
	If !lDicInDB
		Reclock("SX6",.F.)
			SX6->X6_CONTEUD := "T"
			SX6->X6_CONTSPA := "T"
			SX6->X6_CONTENG := "T"
		MsUnlock()
	Else
		cUpd := " UPDATE " + MPSysSqlName("SX6")
		cUpd += " SET X6_CONTEUD = 'T' "
		cUpd += " ,X6_CONTSPA = 'T' "
		cUpd += " ,X6_CONTENG = 'T' "
		cUpd += " WHERE X6_VAR = 'MV_FLAGDEV' "
		cUpd += " AND X6_CONTEUD = 'F' "
		cUpd += " AND D_E_L_E_T_ 	= '' "
		TCSqlExec(cUpd)
	Endif
EndIf

//Código Completo da Filial Atual
If 	SX6->(MsSeek(FwCodFil()+"MV_FLAGDEV"))
	If !lDicInDB
		Reclock("SX6",.F.)
			SX6->X6_CONTEUD := "T"
			SX6->X6_CONTSPA := "T"
			SX6->X6_CONTENG := "T"
		MsUnlock()
	Else
		cUpd := " UPDATE " + MPSysSqlName("SX6")
		cUpd += " SET X6_CONTEUD = 'T' "
		cUpd += " ,X6_CONTSPA = 'T' "
		cUpd += " ,X6_CONTENG = 'T' "
		cUpd += " WHERE X6_VAR = 'MV_FLAGDEV' "
		cUpd += " AND X6_CONTEUD = 'F' "
		cUpd += " AND D_E_L_E_T_ 	= '' "
		TCSqlExec(cUpd)
	Endif
EndIf

Return

//--------------------------------------------------------------------------
/*/{Protheus.doc} AtuSx3SAL
Atualiza a propriedade do campo AL_USERSUP de Alterar para Visualizar

@author Totvs
@since 11/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------------
Function AtuSx3SAL()
Local lDicInDB := MPDicInDB()

//Atualiza X3_VISUAL do campo AL_USERSUP
DbSelectArea("SX3")
DbSetOrder(2)
If !lDicInDB
	If SX3->(DbSeek("AL_USERSUP")) .And. SX3->X3_VISUAL == "A"
		If RecLock("SX3",.F.)
			SX3->X3_VISUAL := "V"
			SX3->(MsUnlock())
		Endif
	EndIf
Else
	cUpd := " UPDATE " + MPSysSqlName("SX3")
	cUpd += " SET X3_VISUAL = 'V' "
	cUpd += " WHERE X3_CAMPO = 'AL_USERSUP' "
	cUpd += " AND X3_VISUAL = 'A' "
	cUpd += " AND D_E_L_E_T_ 	= '' "
	TCSqlExec(cUpd)
Endif

Return

/*/{Protheus.doc} UpdSA2Ord
	Atualiza a ordem dos campos da SA2 para garantir
	que os campos A2_BANCO, A2_AGENCIA, A2_DVAGE, A2_NUMCON e A2_DVCTA
	estejam sempre em sequencia para o correto funcionamento da consulta
	da tabela FIL(Fornecedores x CC).
@author PHILIPE.POMPEU
@since 23/05/2019
@return Nil, Nulo
/*/
Static Function UpdSA2Ord()
	Local aCampos := {'A2_AGENCIA', 'A2_DVAGE', 'A2_NUMCON','A2_DVCTA'}
	Local lUpdOrdem := .F.
	Local nPos := 0
	Local nSoma	:= 0
	Local cOrdOri := ""
	Local cNovaOrdem := ""
	Local nI := 0

	SX3->(DbSetOrder(1))//X3_ARQUIVO+X3_ORDEM
	If(SX3->(DbSeek("SA2")))
		While ( SX3->(!Eof() .And. X3_ARQUIVO == 'SA2') )
			If(lUpdOrdem)
				If((nPos := aScan(aCampos, AllTrim(SX3->X3_CAMPO))) == 0)
					cNovaOrdem := Soma1(cNovaOrdem)
					RecLock("SX3", .F.)
					SX3->X3_ORDEM := cNovaOrdem //A partir de Banco+4, reordena todos os campos.
					SX3->(MsUnlock())
				EndIf
			ElseIf(SX3->(AllTrim(X3_CAMPO) == 'A2_BANCO'))
				lUpdOrdem := .T.
				cOrdOri := SX3->X3_ORDEM //Guarda a ordem do Banco
				nSoma := Len(aCampos) + 1//Garante que 4 posicoes apos banco estarao reservadas
				cNovaOrdem := cOrdOri
				While(nSoma > 0)
					cNovaOrdem := Soma1(cNovaOrdem)
					nSoma--
				EndDo
			EndIf
			SX3->(dbSkip())
		EndDo

		For nI:= 1 to Len(aCampos)
			nSoma := nI
			cNovaOrdem := cOrdOri
			While(nSoma > 0)
				cNovaOrdem := Soma1(cNovaOrdem)
				nSoma--
			EndDo

			SX3->(DbSetOrder(1)) //X3_ARQUIVO+X3_ORDEM
			If(SX3->(DbSeek("SA2" + cNovaOrdem)))
				RecLock("SX3", .F.)
				SX3->X3_ORDEM := Soma1(SX3->X3_ORDEM)
				SX3->(MsUnlock())
			EndIf

			SX3->(DbSetOrder(2))//X3_CAMPO
			If(SX3->(DbSeek(aCampos[nI])))
				RecLock("SX3", .F.)
				SX3->X3_ORDEM := cNovaOrdem
				SX3->(MsUnlock())
			EndIf
		Next nI
	EndIf
Return Nil

//--------------------------------------------------------------------------
/*/{Protheus.doc} AtuEstSx6
Atualiza SX6
/*/
//--------------------------------------------------------------------------
Function AtuEstSx6(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

	Local aAreaSX6  := SX6->(GetArea())
	Local cParamSX6 := ""

	// Exclusao do parametro MV_FIFOENT
	cParamSX6 := "MV_FIFOENT"
	EstDelSX6(cParamSX6)

	// Exclusao do parametro MV_A330DRV
	cParamSX6 := "MV_A330DRV"
	EstDelSX6(cParamSX6)

	RestArea(aAreaSX6)

Return

//--------------------------------------------------------------------------
/*/{Protheus.doc} EstDelSX6
Exclusao de parametro SX6
/*/
//--------------------------------------------------------------------------
Static Function EstDelSX6(cParamSX6)

	Default cParamSX6 := ""

	DbSelectArea("SX6")
	SX6->(dbSetOrder(1))

	// Tratamento referente a filial em branco
	If SX6->(MsSeek(Replicate(" ", FwSizeFilial()) + cParamSX6))
		RecLock("SX6", .F.)
		SX6->(DbDelete())
		SX6->(MsUnlock())
	EndIf

	// Tratamento referente a empresa
	If SX6->(MsSeek(PadR(FwCompany(), FwSizeFilial()) + cParamSX6))
		RecLock("SX6", .F.)
		SX6->(DbDelete())
		SX6->(MsUnlock())
	EndIf

	// Tratamento referente a Empresa + Unidade de Negocio
	If SX6->(MsSeek(PadR(FwCompany() + FwUnitBusiness(), FwSizeFilial()) + cParamSX6))
		RecLock("SX6", .F.)
		SX6->(DbDelete())
		SX6->(MsUnlock())
	EndIf

	// Tratamento referente ao codigo completo da filial atual
	If SX6->(MsSeek(FwCodFil() + cParamSX6))
		RecLock("SX6", .F.)
		SX6->(DbDelete())
		SX6->(MsUnlock())
	EndIf

Return
