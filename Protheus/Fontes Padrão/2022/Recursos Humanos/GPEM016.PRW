#INCLUDE "TOTVS.CH"
#INCLUDE "CALPLANO.CH"

Static aOfusca
Static aFldRel
Static lOfusca
Static lUPDDIFPLA	:= IsInCallStack("U_UPDDIFPLA")
Static lTemCCT

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    	³ GPEM016    ³ Autor ³ Leandro Drumond       	      ³ Data ³ 26/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o 	³ Calculo do Plano de Saude                                    			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   	³ GPEM016()                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      	³ Generico ( DOS e Windows )                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data     ³ FNC			³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Leandro Dr.  ³07/02/2012³M12RH01         ³Unificacao da Folha.                  		³±±
±±³				³		   ³RHU210_03_07	³Calculo do Plano de Saude por Roteiro		³±±
±±³Raquel Hager ³05/06/2014³TPTBN8     	 	³Inclusao de replicas versao 11  com itens  ³±±
±±³             ³          ³                ³do eSocial.					            ³±±
±±³Renan Borges ³28/08/2014³TQGQIE          ³Ajuste para informar que foi calculado a   ³±±
±±³				³		   ³				³co-participação ou reembolso, mesmo quando ³±±
±±³				³		   ³				³já tenha acabado o período deste plano,    ³±±
±±³				³		   ³				³verificando se o plano de saude está na ta-³±±
±±³				³		   ³				³bela de histórico de alterações de planos  ³±±
±±³				³		   ³				³de saude (RHN).                            ³±±
±±³Cícero Alves ³20/07/2015³TSMTCS          ³Alteração para permitir mais de um plano 	³±±
±±³				³		   ³				³com o mesmo tipo e fornecedor.				³±±
±±³Allyson M    ³01/09/2015³TTBHWJ          ³Ajuste no calculo de plano do tipo 5 (faixa³±±
±±³				³		   ³				³salarial/etaria) p/ verificar a faixa certa³±±
±±³Raquel H     ³12/01/2016³TTYXXD          ³Ajuste na geracao de log para dependente   ³±±
±±³				³		   ³				³ de acordo com campo RB_PLSAUDE.           ³±±
±±³Raquel H     ³14/01/2016³TTYXXD          ³Ajuste na geracao de log para dependente   ³±±
±±³				³		   ³				³para verificar todos os dependentes.       ³±±
±±³Raquel H     ³02/02/2016³TUGBDW          ³Ajuste na geracao de log para dependente   ³±±
±±³				³		   ³				³para verificar todos dependentes e depois  ³±±
±±³				³		   ³				³a tabela de planos ativos para dependentes.³±±
±±³Raquel H     ³11/02/2016³TUGBDW          ³Ajuste na geracao de log para dependente.  ³±±
±±³Flavio C     ³05/07/2016³TVO417          ³Transformando functions em fórmulas-CALCPLS³±±
±±³Allyson M    ³18/01/2017³MRH-1404        ³Ajuste p/ cálculo de valor fixo			³±±
±±³Cecília C.   ³12/07/2017³DRHPAG-3642³Ajuste no cálculo do plano de saúde por fai-³±±
±±³				³		   ³				³xa etária para acessar corretamente a tabela³±±
±±³				³		   ³				³S009.                                       ³±±
±±³Rafael R.    ³10/10/2017³DRHPAG-6163		³Criada função para buscar plano de saúde de ³±±
±±³				³		   ³				³dependentes.								 ³±±
±±³João Balbino ³24/11/2017³DRHPAG-6163		³Ajuste na função para buscar plano de saúde ³±±
±±³				³		   ³				³de dependentes.							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM016()
Local aArea	:= GetArea()

Gpem020() //Chama a rotina de calculo

RestArea(aArea)

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fChkPlano      ³Autor³  Leandro Drumond  ³ Data ³26/03/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Valida se funcionario possui plano de saude                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Calculo do Plano de Saude                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fChkPlano()
Local aArea 	:= GetArea()
Local lRet		:= .T.

DEFAULT aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
DEFAULT aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
DEFAULT lOfusca		:= Len(aFldRel) > 0

DbSelectArea("RHK")

If!( DbSeek(SRA->RA_FILIAL + SRA->RA_MAT ) ) //Se não encontrar na RHK procura na RHN, histórico de planos de saudes.
	DbSelectArea("RHN")
	DbSetOrder(1)
	If DbSeek(SRA->RA_FILIAL + SRA->RA_MAT) //Procura na RHN se há um histórico referente a um plano de saúde expirado.
		While !Eof() .and. RHN->RHN_FILIAL + RHN->RHN_MAT == SRA->RA_FILIAL + SRA->RA_MAT
			If (RHN->RHN_OPERAC + RHN->RHN_TPALT == "2" + "04")
				lRet := .T.
			EndIf
			DbSkip()
		EndDo
	EndIf

	// Se encontrou registro na RHN mas o plano do funcionário não esta ativo, grava a mensagem no log.
	If !lRet
		If SRA->RA_PLSAUDE == "1"
			AddLogExecRot( Substr(SRA->RA_FILIAL + "  " + SRA->RA_MAT + "-" + If(lOfusca, Replicate('*',15), SRA->RA_NOME),1,45) + " - " + OemToAnsi(STR0038))		//"Cadastro de funcionários com informação de que funcionário possui plano de saúde, porém não existe plano ativo."
		EndIf

		lRet := .F.
	EndIf
EndIf

If lRet .and. SRA->RA_SITFOLH == "D" .and. AnoMes(SRA->RA_DEMISSA) == cPeriodo//Se foi demitido no mês atual
	DbSelectArea("RHR")
	If DbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cPeriodo)
		While RHR->( !Eof() .and. RHR_FILIAL + RHR_MAT + RHR_COMPPG == SRA->RA_FILIAL + SRA->RA_MAT + cPeriodo)
			If RHR->RHR_TIPO == "2" //Se calculo foi alterado não calcula plano de saúde novamente, pois beneficio já foi integrado na rescisão.
				AddLogExecRot( Substr(SRA->RA_FILIAL + "  " + SRA->RA_MAT + "-" + If(lOfusca, Replicate('*',15), SRA->RA_NOME),1,45) + " - " + OemToAnsi(STR0040))		//"Funcionário esta demitido e possui lançamentos alterados. Cálculo não foi realizado."
				lRet := .F.
				Exit
			EndIf
			If RHR->RHR_INTFOL == "1"
				AddLogExecRot( Substr(SRA->RA_FILIAL + "  " + SRA->RA_MAT + "-" + If(lOfusca, Replicate('*',15), SRA->RA_NOME),1,45) + " - " + OemToAnsi(STR0041))		//"Funcionário esta demitido e a integração já havia sido integrada. Cálculo não foi realizado."
				lRet := .F.
				Exit
			EndIf
			DbSkip()
		EndDo
	EndIf
EndIf

RestArea(aArea)

Return(	lRet)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fDelCalcPlan   ³Autor³  Leandro Drumond  ³ Data ³26/03/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Deletar o Calculo anterior da Competencia a Calcular        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Calculo do Plano de Saude                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fDelCalcPlan()

Local aArea := GetArea()
Local cQuery
Local cNameDB
Local cDelet
Local cSqlName := InitSqlName( "RHR" )

If !lUPDDIFPLA
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³O banco DB2 nao aceita o nome da tabela apos o comando DELETE			 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cNameDB	:= Upper(TcGetDb())

	cQuery := "DELETE "

	cDelet 	:= "RHR.D_E_L_E_T_ = ' ' "

	If ( cNameDB $ "INFORMIX" )
			cDelet := cSqlName +  ".D_E_L_E_T_ = ' ' "
	EndIf

	If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
		cQuery += cSqlName
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³O Informix precisa do nome da tabela ao inves do Alias no comando DELETE³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If ( cNameDB $ "INFORMIX" )
		cQuery += " FROM " + cSqlName
	Else
		cQuery += " FROM " + cSqlName + " RHR"
		cSqlName := "RHR"
	EndIf

	cQuery += " WHERE " + cSqlName + ".RHR_FILIAL = '" + SRA->RA_FILIAL + "'"
	cQuery += " AND " + cSqlName + ".RHR_MAT = '" + SRA->RA_MAT + "'"
	cQuery += " AND " + cSqlName + ".RHR_COMPPG = '" + cAnoMes + "'"
	cQuery += " AND " + cDelet

	TcSqlExec( cQuery )
EndIf

RestArea( aArea )

Return( .T. )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fLogPLS       ³Autor³  Leandro Drumond  ³ Data ³26/03/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Grava Log Calculo Plano Saude								        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Calculo do Plano de Saude                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fLogPLS(aLog)
Local aArea			:= GetArea()
Local aTitle		:= {}
Local nX			:= 0

Aadd( aTitle, OemToAnsi( STR0009 ))	// "Tabela nao Cadastrada ou Valores fora da Faixa"
Aadd( aTitle, OemToAnsi( STR0018 ))	// "Dependentes e Agregados não calculados"
Aadd( aTitle, OemToAnsi( STR0026 ))	// "Titular possui mais de um plano com mesmo Fornecedor"
Aadd( aTitle, OemToAnsi( STR0028 ))	// "Titular possui plano de saúde com Período Inicial e Final divergente do Mês e Ano do cálculo"
Aadd( aTitle, OemToAnsi( STR0027 ))	// "Titular nao possui plano de saúde ativo para o Mês e Ano do cálculo"
Aadd( aTitle, OemToAnsi( STR0034 ))	// "Co-participação ou reembolso calculado mesmo com plano de saude expirado"

If !Empty(aLog[1])
	AddLogExecRot( aTitle[1] )
	For nX := 1 to Len(aLog[1])
		AddLogExecRot( aLog[1][nX])
	Next nX
EndIf

If !Empty(aLog[2])
	AddLogExecRot( aTitle[2] )
	For nX := 1 to Len(aLog[2])
		AddLogExecRot( aLog[2][nX])
	Next nX
EndIf

If !Empty(aLog[3])
	AddLogExecRot( aTitle[3] )
	For nX := 1 to Len(aLog[3])
		AddLogExecRot( aLog[3][nX])
	Next nX
EndIf

If !Empty(aLog[4])
	AddLogExecRot( aTitle[4] )
	For nX := 1 to Len(aLog[4])
		AddLogExecRot( aLog[4][nX])
	Next nX
EndIf

If !Empty(aLog[5])
	AddLogExecRot( aTitle[5] )
	For nX := 1 to Len(aLog[5])
		AddLogExecRot( aLog[5][nX])
	Next nX
EndIf

If !Empty(aLog[6])
	AddLogExecRot( aTitle[6] )
	For nX := 1 to Len(aLog[6])
		AddLogExecRot( aLog[6][nX])
	Next nX
EndIf

RestArea(aArea)

Return .T.

/*/{Protheus.doc} fCalcPlano
Efetua o Cálculo e Retornar apenas o valor
@author Mauricio Takakura
@since 17/10/2011
@param nTipo, numeric, 1 - Titular; 2 - Dependente; 3 - Agregado
@param cTpForn, characters, "1" - Assistência médica; "2" - Assistência Odontológico
@param cCodForn, characters, Código do fornecedor
@param cTpPlan, characters, 1 - Faixa Salarial; 2 - Faixa etária; 3 - Valor fixo; 4 - Porcentagem sobre salario; 5 - Faixa salarial/etária
@param cCodPlan, characters, Código do plano
@param dDtRef, date, Data de referência
@param dDtNasc, date, Data de nascimento do funcionário
@param nVlrFunc, numeric, Valor do funcionário (dever ser passado por referência)
@param nVlrEmpr, numeric, Valor da empresa (dever ser passado por referência)
@param cFilProc, characters, Filial para busca
/*/
Function fCalcPlano( nTipo, cTpForn, cCodForn, cTpPlan, cCodPlan, dDtRef, dDtNasc, nVlrFunc, nVlrEmpr, cFilProc )

	Local cTab
	Local cTpLogForn
	Local cTpLogPlano

	Local dDataTab		:= dDtRef
	Local dRefBkp		:= dDtRef
	
	Local lRet			:= .T.
	Local lCarTabFol	:= .T.

	Local nLinha
	Local nLinTab
	Local nColVlr
	Local nColPorc
	Local nColTeto
	Local nBusca
	Local nValor
	Local nPercentual
	Local nTeto
	Local nSal			:= 0
	Local nValorPlano	:= 0
	Local nValRed		:= 0
	Local cIdadeDesc	:= SuperGetMv( "MV_PLSBASI",, "1" )
	Local lCalcula		:= .T.

	Static lGPM016A
	Static lGPM016PL
	Static lGPM016TM

	DEFAULT lGPM016A 	:= Existblock("GPM016A",.F.,.F.)
	DEFAULT lGPM016PL	:= ExistBlock("GPM016PL",.F.,.F.)
	DEFAULT lGPM016TM	:= ExistBlock("GPM016TM",.F.,.F.)
	DEFAULT aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	DEFAULT aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
	DEFAULT lOfusca		:= Len(aFldRel) > 0

	If lUPDDIFPLA .And. nTipoTab == 2
		dDataRef	:= dDataAtu
	EndIf

	If SRA->RA_SITFOLH == "D" .And. cAnoMes >= AnoMes( SRA->RA_DEMISSA )
		lCalcula := lRet := .F.
	EndIf

	If lCalcula
		If cTpForn == "1"		// Assistencia Medica
			If cTpPlan == "1"
				cTab := "S008"
			ElseIf cTpPlan == "2"
				cTab := "S009"
			ElseIf cTpPlan == "3"
				cTab := "S028"
			ElseIf cTpPlan == "4"
				cTab := "S029"
			ElseIf cTpPlan == "5"
				cTab := "S059"
			ElseIf cTpPlan == "6"
				cTab := "S140"
			EndIf
			cTpLogForn := OemToAnsi( STR0011 ) // "Assistência Medica"
		Else					// Assistencia Odontologica
			If cTpPlan == "1"
				cTab := "S013"
			ElseIf cTpPlan == "2"
				cTab := "S014"
			ElseIf cTpPlan == "3"
				cTab := "S030"
			ElseIf cTpPlan == "4"
				cTab := "S031"
			ElseIf cTpPlan == "5"
				cTab := "S060"
			ElseIf cTpPlan == "6"
				cTab := "S141"
			EndIf
			cTpLogForn := OemToAnsi( STR0012 ) // "Assistência Odontologica"
		EndIf

		//Ajuste para verificar se utiliza salario base ou salario incorporado
		If ! P_SALINC
			If (SRA->RA_CATFUNC = "H")
				nBusca := SRA->RA_HRSMES * SRA->RA_SALARIO
			Else
				nBusca := nSalMes
			EndIf
		Else
			nBusca := nSalMes
		EndIf

		If P_lPPEAtiv .And. P_RedSalB
			fInssResEx()
			If !fSalRed(@nValRed, Nil, Nil, nBusca)
				Return .F.
			EndIf
			nBusca -= nValRed
		EndIf

		//Executa ponto de entrada GPM016A para alterar o valor da variável nBusca
		If lGPM016A
			nValor := Execblock("GPM016A",.F.,.F.)
			If ValType(nValor) == "N" .and. nValor > 0
				nBusca := nValor
			EndIf
		EndIf

		If !lUPDDIFPLA .And. cPeriodo >= "202009" .And. cPeriodo <= "202012"
			cIdadeDesc	:= "1"
			dDataTab 	:= sToD("20200801")
		EndIf

		// Se for por Faixa Etaria, calcular a idade
		If cTpPlan == "2"
			nBusca := Year( dDataTab ) - Year( dDtNasc )
			If Month( dDtNasc ) > Month( dDataTab ) .OR. ( cIdadeDesc == "2" .AND. (Month( dDtNasc )== Month( dDataTab )))
				nBusca--
			EndIf
		EndIf

		If cTpPlan == "1" .or. cTpPlan == "2"

			If nTipo == 1 // Titular
				nColVlr 	:= 7
				nColPorc	:= 10
			ElseIf nTipo == 2 // Dependente
				nColVlr 	:= 8
				nColPorc	:= 11
			ElseIf nTipo == 3 // Agregado
				nColVlr 	:= 9
				nColPorc	:= 12
			EndIf

			nLinTab := 0
			If ( nLinha := fPosTab( cTab, cCodForn, "=", 13, cCodPlan, "=", 4, , , @nLinTab, lCarTabFol, cFilProc, nBusca, "<=", 6, ,{1,2,3,7} ) ) > 0
				nValor 		:= fTabela(cTab, nLinha, nColVlr, Iif( lUPDDIFPLA, dDataRef, Nil), cFilProc)
				nValorPlano := nValor
				If lGPM016PL
					nValor := ExecBlock("GPM016PL",.F.,.F.,{nValor, cTpPlan})
					nValor := If(ValType(nValor) <> "N", nValorPlano, nValor)
				EndIf
				nPercentual := fTabela(cTab,nLinha,nColPorc,,cFilProc) / 100
				nVlrFunc  	:= Round( nValor * nPercentual, 2 )		// Arredondamento para nao dar diferenca entre calculo e valor total do plano
				nVlrEmpr	:= Max(nValorPlano - nVlrFunc,0)
				If nVlrEmpr == 0
					nVlrFunc := nValorPlano
				EndIf
			EndIf

			If cTpPlan == "1"
				cTpLogPlano := OemToAnsi( STR0014 ) //"Faixa Salarial"
			ElseIf cTpPlan == "2"
				cTpLogPlano := OemToAnsi( STR0015 ) //"Faixa Etaria"
			EndIf

		ElseIf cTpPlan == "3"

			cTpLogPlano := OemToAnsi( STR0016 ) //"Valor Fixo"
			If nTipo == 1 // Titular
				nColVlr 	:= 6
				nColPorc	:= 9
			ElseIf nTipo == 2 // Dependente
				nColVlr 	:= 7
				nColPorc	:= 10
			ElseIf nTipo == 3 // Agregado
				nColVlr 	:= 8
				nColPorc	:= 11
			EndIf

			nLinTab := 0
			If ( nLinha := fPosTab( cTab, cCodForn, "=", 12, cCodPlan, "=", 4, , , @nLinTab, lCarTabFol, cFilProc ) ) > 0
				nValor		:= fTabela(cTab,nLinha,nColVlr,,cFilProc)

				nValorPlano := nValor
				If lGPM016PL
					nValor := ExecBlock("GPM016PL",.F.,.F.,{nValor, cTpPlan})
					nValor := If(ValType(nValor) <> "N", nValorPlano, nValor)
				EndIf

				nPercentual	:= fTabela(cTab,nLinha,nColPorc,,cFilProc)
				nVlrFunc	:= nPercentual
				nVlrEmpr	:= Max(nValor - nPercentual,0)
			Elseif ( nLinha := fPosTab( cTab, cCodForn, "=", 12, cCodPlan, "=", 4, , , @nLinTab, .F., Space(FWGETTAMFILIAL), Space(FWGETTAMFILIAL), "=", 1 ) ) > 0 
				nValor		:= fTabela(cTab,nLinha,nColVlr,,Space(FWGETTAMFILIAL))

				nValorPlano := nValor
				If lGPM016PL
					nValor := ExecBlock("GPM016PL",.F.,.F.,{nValor, cTpPlan})
					nValor := If(ValType(nValor) <> "N", nValorPlano, nValor)
				EndIf

				nPercentual	:= fTabela(cTab,nLinha,nColPorc,,Space(FWGETTAMFILIAL))
				nVlrFunc	:= nPercentual
				nVlrEmpr	:= Max(nValor - nPercentual,0)
			EndIf

		ElseIf cTpPlan == "4"

			cTpLogPlano := OemToAnsi( STR0017 ) //"Porcentagem sobre Salario"
			If nTipo == 1 // Titular
				nColVlr 	:= 6
				nColPorc	:= 9
				nColTeto	:= 10
			ElseIf nTipo == 2 // Dependente
				nColVlr 	:= 7
				nColPorc	:= 11
				nColTeto	:= 12
			ElseIf nTipo == 3 // Agregado
				nColVlr 	:= 8
				nColPorc	:= 13
				nColTeto	:= 14
			EndIf

			nLinTab := 0
			If ( nLinha := fPosTab( cTab, cCodForn, "=", 15, cCodPlan, "=", 4, , , @nLinTab, lCarTabFol, cFilProc ) ) > 0
				If ( nLinha := fPosTab(cTab, cCodPlan,"=",4,,,,,nLinTab,,,cFilProc) ) > 0

					// nValor eh o valor do plano de saude a pagar
					nValor		:= fTabela(cTab,nLinha,nColVlr,,cFilProc)

					nValorPlano := nValor
					If lGPM016PL
						nValor := ExecBlock("GPM016PL",.F.,.F.,{nValor, cTpPlan})
						nValor := If(ValType(nValor) <> "N", nValorPlano, nValor)
					EndIf

					nPercentual	:= fTabela(cTab,nLinha,nColPorc,,cFilProc) / 100
					nTeto		:= fTabela(cTab,nLinha,nColTeto,,cFilProc)

					// O valor a pagar do funcionario eh sobre o salario do mes
					nVlrFunc	:= ( nBusca * nPercentual )

					If nVlrFunc > nTeto
						nVlrFunc := nTeto
					EndIf

					nVlrEmpr := nValor - (If( nVlrFunc <= nTeto, nVlrFunc, nTeto ))
				EndIf
			EndIf

		ElseIf cTpPlan == "5"

			cTpLogPlano := OemToAnsi( STR0033 ) //"Salarial/Etaria"

			If nTipo == 1 // Titular
				nColVlr 	:= 8
				nColPorc	:= 11
			ElseIf nTipo == 2 // Dependente
				nColVlr 	:= 9
				nColPorc	:= 12
			ElseIf nTipo == 3 // Agregado
				nColVlr 	:= 10
				nColPorc	:= 13
			EndIf

			nLinTab := 0
			If ( nLinha := fPosTab( cTab, cCodForn, "=", 14, cCodPlan, "=", 4, , , @nLinTab, lCarTabFol, cFilProc, , ,, ,{1,2,3,15,5,7,8} ) ) > 0
				nSal	:= nBusca
				nBusca := Year( dDataTab ) - Year( dDtNasc )
		        If Month( dDtNasc ) > Month( dDataTab ) .OR. ( cIdadeDesc == "2" .AND. (Month( dDtNasc )== Month( dDataTab )))
		             nBusca--
				EndIf
				If ( nLinha := fPosTab(cTab, cCodPlan, "=", 4, nSal, "<=", 6, Nil, , @nLinTab, Nil, cFilProc, nBusca, "<=", 7, ,{1,2,3,15,5,7,8} ) ) > 0
					nValor 		:= fTabela(cTab, nLinha, nColVlr, Iif( lUPDDIFPLA, dDataRef, Nil), cFilProc)

					nValorPlano := nValor
					If lGPM016PL
						nValor := ExecBlock("GPM016PL",.F.,.F.,{nValor, cTpPlan})
						nValor := If(ValType(nValor) <> "N", nValorPlano, nValor)
					EndIf
					nPercentual := fTabela(cTab,nLinha,nColPorc,,cFilProc) / 100
					nVlrFunc  	:= Round( nValor * nPercentual, 2 )		// Arredondamento para nao dar diferenca entre calculo e valor total do plano
					nVlrEmpr	:= Max(nValorPlano - nVlrFunc,0)
					If nVlrEmpr == 0
						nVlrFunc := nValorPlano
					EndIf
				EndIf

			EndIf

		ElseIf cTpPlan == "6"

			cTpLogPlano := OemToAnsi( STR0042 ) //"Salarial/Tempo"

			If nTipo == 1 // Titular
				nColVlr 	:= 8
				nColPorc	:= 11
			ElseIf nTipo == 2 // Dependente
				nColVlr 	:= 9
				nColPorc	:= 12
			ElseIf nTipo == 3 // Agregado
				nColVlr 	:= 10
				nColPorc	:= 13
			EndIf

			nLinTab := 0
			If ( nLinha := fPosTab( cTab, cCodForn, "=", 14, cCodPlan, "=", 4, , , @nLinTab, lCarTabFol, cFilProc, , ,, ,{1,2,3,15,5,7,8} ) ) > 0
				nSal	:= nBusca
				nBusca 	:= Year( dDataTab ) - Year( SRA->RA_ADMISSA )
		        If Month( SRA->RA_ADMISSA ) > Month( dDataTab )
		             nBusca--
				EndIf

				If lGPM016TM
					nBusca := ExecBlock("GPM016TM", .F., .F., {nBusca})
				EndIf

				If ( nLinha := fPosTab(cTab, cCodPlan, "=", 4, nSal, "<=", 6, Nil, , @nLinTab, Nil, cFilProc, nBusca, "<=", 7, ,{1,2,3,15,5,7,8} ) ) > 0
					nValor 		:= fTabela(cTab, nLinha, nColVlr, Iif( lUPDDIFPLA, dDataRef, Nil), cFilProc)

					nValorPlano := nValor
					If lGPM016PL
						nValor := ExecBlock("GPM016PL",.F.,.F.,{nValor, cTpPlan})
						nValor := If(ValType(nValor) <> "N", nValorPlano, nValor)
					EndIf
					nPercentual := fTabela(cTab,nLinha,nColPorc,,cFilProc) / 100
					nVlrFunc  	:= Round( nValor * nPercentual, 2 )		// Arredondamento para nao dar diferenca entre calculo e valor total do plano
					nVlrEmpr	:= Max(nValorPlano - nVlrFunc,0)
					If nVlrEmpr == 0
						nVlrFunc := nValorPlano
					EndIf
				EndIf

			EndIf
		EndIf

		If nLinha == 0
			aAdd( aLog[1], Substr(SRA->RA_FILIAL + "  " + SRA->RA_MAT + "-" + If(lOfusca, Replicate('*',15), SRA->RA_NOME),1,45) + " - " + ;
							cTpLogForn + " - " +; //"Assistencia Medica" ou "Assistencia Odontologica"
							cTpLogPlano + " - " +; // "Faixa Salarial" ou "Faixa Etaria" ou "Valor Fixo" ou "Porcentagem sobre Salario"
							OemToAnsi(STR0010) + " " + cCodPlan  ) //"Codigo
			lRet := .F.
		EndIf

		// Apos Primeira Carga, atualiza para .F. para nao carregar a cada funcionario
		lCarTabFol := .F.
	EndIf

	If lUPDDIFPLA
		dDataRef	:= dRefBkp
	EndIf

Return( lRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fGravaCalc		³Autor³  Mauricio Takakura³ Data ³17/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Gravacao do calculo                                         ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³CALPLANO                                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fGravaCalc(cOrigem, cCodDepAgr, cTipoLan, cTpForn, cCodForn, cTpPlan, cPlano, cPD, nVlrFun, nVlrEmp, lCopReemb )
Local aArea		:= GetArea()
Local lRHRTipo	:= RHR->( FieldPos( "RHR_TIPO" ) # 0 )

DEFAULT lCopReemb := .F.	// Coparticipacao/Reembolso - Padrao eh False, pois esta var somente vira com True para regs da Tab. RHO
DEFAULT lTemCCT	  := RHR->(ColumnPos("RHR_CODCCT")) > 0

If !lUPDDIFPLA
	DbSelectArea( "RHR" )
	DbSetOrder( 1 )
	DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + 	cAnoMes + cOrigem + cCodDepAgr + cTipoLan + cTpForn + cCodForn + cTpPlan + cPlano + cPD, .F. )

	If Eof()
		RHR->( RecLock( "RHR" , .T. ) )
		RHR->RHR_FILIAL := SRA->RA_FILIAL
		RHR->RHR_MAT 	:= SRA->RA_MAT
	Else
		RHR->( RecLock( "RHR" , .F. ) )
	EndIf

	RHR->RHR_DATA 		:= dDataBase
	RHR->RHR_ORIGEM 	:= cOrigem
	RHR->RHR_CODIGO		:= cCodDepAgr
	RHR->RHR_TPLAN		:= cTipoLan
	RHR->RHR_TPFORN		:= cTpForn
	RHR->RHR_CODFOR  	:= cCodForn
	RHR->RHR_TPPLAN		:= cTpPlan
	RHR->RHR_PLANO		:= cPlano
	RHR->RHR_PD			:= cPD

	// Qdo for informacao de Coparticipacao/Reembolso, deve-se somar os valores lancados na tabela RHO
	If lCopReemb
		RHR->RHR_VLRFUN	+= nVlrFun
		RHR->RHR_VLREMP	+= nVlrEmp
	Else
		RHR->RHR_VLRFUN	:= nVlrFun
		RHR->RHR_VLREMP	:= nVlrEmp
	EndIf

	RHR->RHR_COMPPG		:= cAnoMes

	// Grava novo Campo RHR_Tipo = 1-Calculado
	If lRHRTipo
		RHR->RHR_TIPO := "1"
	EndIf

	If lTemCCT .and. !Empty(SRA->RA_SINDICA)
		RHR->RHR_CODCCT := fBuscaCCT(SRA->RA_SINDICA)
	EndIf

	MsUnlock()
Else
	aAdd( aLancs, { cPeriodo, cOrigem, cCodDepAgr, cTipoLan, cTpForn, cCodForn, cTpPlan, cPlano, cPD, nVlrFun, nVlrEmp } )
EndIf

RestArea( aArea )

Return( .T. )

/*/{Protheus.doc} fBusPlDep
Busca Planos de Saúde de Dependentes
@author Rafael Reis
@since 10/10/2017
@param cMatTit, characters, descricao
@param cTpForn, characters, descricao
@param cCodForn, characters, descricao
@param cSrbCod, characters, descricao
@return aReturn, Array, descrição
/*/
Function fBusPlDep(cMatTit, cTpForn, cCodForn, cSrbCod, cCodPlano)

	Local aReturn		:= {}
	Local lRHLDatFim	:= .F.

	DEFAULT cCodPlano   := ""

	DbSelectArea( "RHL" )

	lRHLDatFim := RHL->(ColumnPos("RHL_DATFIM")) > 0

	RHL->(dbSetOrder( RetOrdem( "RHL", "RHL_FILIAL+RHL_MAT+RHL_TPFORN+RHL_CODFOR+RHL_CODIGO" ) ))

	If RHL->(dbSeek(xFilial("RHL", SRA->RA_FILIAL) + cMatTit ))
		While RHL->(RHL_FILIAL+RHL_MAT) == SRA->RA_FILIAL+cMatTit
			If !Empty(cCodPlano) .and. cCodPlano <> RHL->RHL_PLANO
				RHL->(dbSkip())
				Loop
			EndIf

			If RHL_TPFORN + RHL_CODFOR + RHL_CODIGO == cTpForn + cCodForn + cSrbCod
				If lRHLDatFim
					Aadd( aReturn, { RHL->RHL_TPFORN, RHL->RHL_CODFOR, RHL->RHL_CODIGO, RHL->RHL_TPCALC, RHL->RHL_TPPLAN, RHL->RHL_PLANO, RHL->RHL_PERINI, RHL->RHL_PERFIM, RHL->RHL_DATFIM } )
					//					1					2				3				4				5					6				7				8				9
				Else
					Aadd( aReturn, { RHL->RHL_TPFORN, RHL->RHL_CODFOR, RHL->RHL_CODIGO, RHL->RHL_TPCALC, RHL->RHL_TPPLAN, RHL->RHL_PLANO, RHL->RHL_PERINI, RHL->RHL_PERFIM } )
					//					1					2				3				4				5					6				7				8
				EndIf
			EndIf
			RHL->(dbSkip())
		EndDo
	EndIf

Return aReturn


/*/{Protheus.doc} PropPLA
Realiza a proporcinalização do cálculo do plano de saúde de acordo com a data fim informada no cadastro de planos ativos, gerando as verbas com a diferença no cálculo da folha de da rescisão
@author cicero.pereira
@since 24/11/2017
@version 12.1.17
/*/
Function PropPLA()

	Local aArea			:= GetArea()
	Local c1PdDfEmpT	:= ""	// ID: 1426 - Base parte Empresa Diferença Assist.Medica
	Local c1PdDfEmpD	:= ""	// ID: 1427 - Base parte Empresa Diferença Assist.Medica Dep/Agreg.
	Local c2PdDfEmpT	:= ""	// ID: 1428 - Base parte Empresa Diferença Assist.Odontologica
	Local c2PdDfEmpD	:= ""	// ID: 1429 - Base parte Empresa Diferença Assist.Odontologica Dep/Agreg.
	Local cPdDif		:= ""	// Verbas para pagamento da diferença
	Local cPdEmpDif		:= ""
	Local aPLAFim		:= {}	// Informações dos planos que tiverem a data fim preenchidas
	Local aValDif		:= {}
	Local nI, nPos
	Local nVlrDif		:= 0
	Local nVlrEmpDif	:= 0
	Local nVlrFunDif	:= 0

	Local lRHKDatFim	:= .F.

	DbSelectArea( "RHK" )
	lRHKDatFim := RHK->(ColumnPos("RHK_DATFIM")) > 0 .And. Len(aCodFol) >= 1429

	If lRHKDatFim

		c1PdDfEmpT := aCodFol[1426,1]	// Verba de base parte empresa Assistência Médica do Titular (Diferença)
		c1PdDfEmpD := aCodFol[1427,1]	// Verba de base parte empresa Assistência Médica dos Dependentes e Agregados (Diferença)
		c2PdDfEmpT := aCodFol[1428,1]	// Verba de base parte empresa Assistência Odontológica do Titular (Diferença)
		c2PdDfEmpD := aCodFol[1429,1]	// Verba de base parte empresa Assistência Odontológica dos Dependentes e Agregados (Diferença)

		// Busca os códigos das verbas no cadastro de planos ativos
		// Verifica se a data fim está preenchida para o titular
		RHK->(DbSetOrder(1))
		RHK->(DbSeek( SRA->(RA_FILIAL + RA_MAT)))

		While ! RHK->(Eof()) .And. RHK->(RHK_FILIAL + RHK_MAT) == SRA->(RA_FILIAL + RA_MAT)

			If Empty(RHK->RHK_DATFIM) // Se a data final do titular não estiver preenchida busca nos planos ativos dos dependentes e agregados

				//Busca na tabela de planos ativos dos Dependentes
				dbSelectArea("RHL")
				RHL->(dbSetOrder(1))
				RHL->(dbSeek(RHK->(RHK_FILIAL + RHK_MAT + RHK_TPFORN + RHK_CODFOR)))
				While ! RHL->(Eof()) .And. RHL->(RHL_FILIAL + RHL_MAT + RHL_TPFORN + RHL_CODFOR) == RHK->(RHK_FILIAL + RHK_MAT + RHK_TPFORN + RHK_CODFOR)

					If ! Empty(RHL->RHL_DATFIM) .And. AnoMes( RHL->RHL_DATFIM) == cPeriodo
						Posicione("RHR", 1, RHL->(RHL_FILIAL + RHL_MAT + cPeriodo + "2" + RHL_CODIGO + "1" + RHL_TPFORN + RHL_CODFOR + RHL_TPPLAN + RHL_PLANO ), "RHR_VLRFUN")
						Aadd(aPLAFim, { RHR->RHR_ORIGEM, RHR->RHR_PD, RHR->RHR_VLRFUN, RHR->RHR_VLREMP, RHL->RHL_DATFIM, RHK->RHK_PDDIFT, RHK->RHK_PDDIFD, RHK->RHK_TPFORN })
					EndIf

					RHL->(dbSkip())

				EndDo

				//Busca na tabela dos planos ativos dos Agregados
				dbSelectArea("RHM")
				RHM->(dbSetOrder(1))
				RHM->(dbSeek(RHK->(RHK_FILIAL + RHK_MAT + RHK_TPFORN + RHK_CODFOR)))
				While ! RHM->(Eof()) .And. RHM->(RHM_FILIAL + RHM_MAT + RHM_TPFORN + RHM_CODFOR) == RHK->(RHK_FILIAL + RHK_MAT + RHK_TPFORN + RHK_CODFOR)

					If ! Empty(RHM->RHM_DATFIM) .And. AnoMes( RHM->RHM_DATFIM ) == cPeriodo
						Posicione("RHR", 1, RHM->(RHM_FILIAL + RHM_MAT + cPeriodo + "3" + RHM_CODIGO + "1" + RHM_TPFORN + RHM_CODFOR + RHM_TPPLAN + RHM_PLANO), "RHR_VLRFUN" )
						Aadd(aPLAFim, { RHR->RHR_ORIGEM, RHR->RHR_PD, RHR->RHR_VLRFUN, RHR->RHR_VLREMP, RHM->RHM_DATFIM, RHK->RHK_PDDIFT, RHK->RHK_PDDIFD, RHK->RHK_TPFORN })
					EndIf

					RHM->(dbSkip())

				EndDo

			Else
				dbSelectArea("RHR")
				RHR->( dbSetOrder( 1 ))
				RHR->( dbSeek( RHK->( RHK_FILIAL + RHK_MAT + cPeriodo )))
				While ! RHR->(Eof()) .And. RHR->(RHR_FILIAL + RHR_MAT + RHR_COMPPG) == RHK->( RHK_FILIAL + RHK_MAT + cPeriodo )

					If RHR->(RHR_TPLAN + RHR_TPFORN + RHR_CODFOR ) == "1" + RHK->( RHK_TPFORN + RHK_CODFOR ) .And. AnoMes( RHK->RHK_DATFIM ) == cPeriodo
						Aadd(aPLAFim, { RHR->RHR_ORIGEM, RHR->RHR_PD, RHR->RHR_VLRFUN, RHR->RHR_VLREMP, RHK->RHK_DATFIM, RHK->RHK_PDDIFT, RHK->RHK_PDDIFD, RHK->RHK_TPFORN })
					EndIf

					RHR->(dbSkip())

				EndDo

			EndIf

			RHK->(dbSkip())

		EndDo

		For nI := 1 To Len(aPLAFim)

			If aPLAFim[nI][1] == "1"												// Titular
				nPos := Ascan(aPd, {|x| x[1] ==  aPLAFim[nI][6]})
				cPdDif := aPLAFim[nI][6]											// Verba de Provento para a diferênça do titular
				cPdEmpDif := If( aPLAFim[nI][8] == "1", c1PdDfEmpT, c2PdDfEmpT)		// Assistência Médica ou Assistência Odontológica

			Else																	// Dependentes e agregados
				nPos := Ascan(aPd, {|x| x[1] ==  aPLAFim[nI][7]})
				cPdDif := aPLAFim[nI][7]											// Verba de Provento para a diferênça dos Dependentes e Agregados
				cPdEmpDif := If( aPLAFim[nI][8] == "1", c1PdDfEmpD, c2PdDfEmpD )	// Assistência Médica ou Assistência Odontológica
			EndIf

			If nPos == 0 // Se não encontrou a verba de diferença

				nVlrFunDif := Round( ( aPLAFim[nI][3] / Day(LastDay(aPLAFim[nI][5]))) * DateDiffDay(aPLAFim[nI][5], LastDay(aPLAFim[nI][5])), 2 )	// Valor funcionário / Dias do mês * (último dia do mês - dia da data final)
				nVlrDif := (aPLAFim[nI][3] + aPLAFim[nI][4]) / Day(LastDay(aPLAFim[nI][5])) * DateDiffDay(aPLAFim[nI][5], LastDay(aPLAFim[nI][5]))	// (Valor funcionário + Valor empresa) / Dias do mês * (último dia do mês - dia da data final)
				nVlrEmpDif := nVlrDif - nVlrFunDif

				// Valor Funcionário
				If (nPos := aScan(aValDif, {|x| x[1] == cPdDif})) > 0
					aValDif[nPos][2] += nVlrFunDif
				Else
					Aadd(aValDif, {cPdDif, nVlrFunDif})
				EndIf

				// Valor Empresa
				If (nPos := aScan(aValDif, {|x| x[1] == cPdEmpDif})) > 0
					aValDif[nPos][2] += nVlrEmpDif
				Else
					Aadd(aValDif, {cPdEmpDif, nVlrEmpDif})
				EndIf

			EndIf

		Next

		For nI := 1 To Len(aValDif)
			If aValDif[nI][2] > 0
				fMatriz(aValDif[nI][1], aValDif[nI][2])
			EndIf
		Next

	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} fAtuRHOTet
Atualiza campos RHO_SALDO e RHO_PERORI
@author Allyson Mesashi
@since 21/09/2021
/*/
Function fAtuRHOTet()

If RHO->( RecLock( "RHO" , .F. ) )
	RHO->RHO_SALDO	:= RHO->RHO_VLRFUN
	RHO->RHO_PERORI	:= "1"
	RHO->( MsUnlock() )
EndIf

Return

/*/{Protheus.doc} fBuscaCCT
Busca o código da CCT associado ao sindicato
@author Leandro Drumond
@since 02/06/2022
/*/
Static Function fBuscaCCT(cSindicato)
Local aArea		:= GetArea()
Local cRet		:= ""

DbSelectArea("RCE")
RCE->(DbSetOrder(1))

If RCE->(DbSeek(xFilial("RCE") + cSindicato))
	cRet := RCE->RCE_CCT
EndIf

RestArea(aArea)

Return cRet
